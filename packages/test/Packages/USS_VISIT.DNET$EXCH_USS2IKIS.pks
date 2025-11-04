/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$EXCH_USS2IKIS
IS
    -- Author  : SHOSTAK
    -- Created : 31.08.2021 22:22:17
    -- Purpose :

    c_Nrt_Search_Person   CONSTANT NUMBER := 24;
    c_Src_Rzo             CONSTANT NUMBER := '13';

    PROCEDURE Reg_Visit_Req (p_Ur_Ext_Id    IN NUMBER,
                             p_Sc_Id        IN NUMBER,
                             p_Visit_Tp     IN VARCHAR2,
                             p_Numident     IN VARCHAR2,
                             p_Ln           IN VARCHAR2,
                             p_Fn           IN VARCHAR2,
                             p_Mn           IN VARCHAR2,
                             p_Doc_Number   IN VARCHAR2);

    PROCEDURE Handle_Reg_Visit_Resp (p_Ur_Id            IN     NUMBER,
                                     p_Response         IN     CLOB,
                                     p_Error            IN OUT VARCHAR2,
                                     p_Repeat              OUT VARCHAR2,
                                     p_Subreq_Created      OUT VARCHAR2);

    PROCEDURE Set_Ape_Error (p_Id        Ap_Execution.Ape_Id%TYPE,
                             p_Message   Ap_Log.Apl_Message%TYPE);

    PROCEDURE Save_Ape_Result (p_Id       Appeal.Ap_Id%TYPE,
                               p_Doc_Id   Ap_Document.Apd_Doc%TYPE,
                               p_Dh_Id    Ap_Document.Apd_Dh%TYPE);

    --Проставлення у чергу на відправку довідки про пільги
    PROCEDURE Reg_Appeal_Bnf01_Send (p_ap_id IN NUMBER);

    -------------------------------------------------------------------------------
    --  Отримання даних для запиту на отримання результату виконання звернення
    -------------------------------------------------------------------------------
    --FUNCTION Get_Appeal_Bnf01_Data(p_ap_id IN NUMBER) RETURN CLOB;
    PROCEDURE Get_Appeal_Bnf01_Data (p_ap_id            IN     NUMBER,
                                     p_operation_type   IN     VARCHAR2,
                                     p_res                 OUT SYS_REFCURSOR,
                                     p_res_files           OUT SYS_REFCURSOR);
END Dnet$exch_Uss2ikis;
/


GRANT EXECUTE ON USS_VISIT.DNET$EXCH_USS2IKIS TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.DNET$EXCH_USS2IKIS TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$EXCH_USS2IKIS
IS
    -------------------------------------------------------------------------------
    --               Реєстрація запиту на реєстрацію звернення
    -------------------------------------------------------------------------------
    PROCEDURE Reg_Visit_Req (p_Ur_Ext_Id    IN NUMBER,
                             p_Sc_Id        IN NUMBER,
                             p_Visit_Tp     IN VARCHAR2,
                             p_Numident     IN VARCHAR2,
                             p_Ln           IN VARCHAR2,
                             p_Fn           IN VARCHAR2,
                             p_Mn           IN VARCHAR2,
                             p_Doc_Number   IN VARCHAR2)
    IS
        l_Rn_Id   NUMBER;
    BEGIN
        Ikis_Rbm.Api$request_Pfu.Reg_Visit_Req (
            p_Rn_Nrt       => 18,
            p_Rn_Hs_Ins    => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src       => Api$appeal.c_Src_Vst,
            p_Rn_Id        => l_Rn_Id,
            p_Ur_Ext_Id    => p_Ur_Ext_Id,
            p_Sc_Id        => p_Sc_Id,
            p_Visit_Tp     => p_Visit_Tp,
            p_Numident     => p_Numident,
            p_Ln           => p_Ln,
            p_Fn           => p_Fn,
            p_Mn           => p_Mn,
            p_Doc_Seria    => NULL,
            p_Doc_Number   => p_Doc_Number);
    END;

    ---------------------------------------------------------------------------
    --        Обробка відповіді на запит на реєстрацію звернення
    ---------------------------------------------------------------------------
    PROCEDURE Handle_Reg_Visit_Resp (p_Ur_Id            IN     NUMBER,
                                     p_Response         IN     CLOB,
                                     p_Error            IN OUT VARCHAR2,
                                     p_Repeat              OUT VARCHAR2,
                                     p_Subreq_Created      OUT VARCHAR2)
    IS
        l_Ape_Id             Ap_Execution.Ape_Id%TYPE;
        l_Response_Body      CLOB;
        l_Response_Payload   CLOB;
        l_Ap_Id              Appeal.Ap_Id%TYPE;
        l_Hs                 Histsession.Hs_Id%TYPE;
        l_Hs_Rbm             NUMBER;
        l_Appeal_Old         Appeal%ROWTYPE;
        l_Vst_Id             NUMBER;
        l_Rn_Id              NUMBER;
    BEGIN
        l_Ape_Id := Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --TODO: уточнити, можливо має сенс повторювати запит
            Set_Ape_Error (
                l_Ape_Id,
                'Технічна помилка під час відправки запиту на довідку');
            p_Repeat := 'F';
            RETURN;
        END IF;

              --Парсимо відповідь
              SELECT Resp_Body
                INTO l_Response_Body
                FROM XMLTABLE ('/*'
                               PASSING Xmltype (p_Response)
                               COLUMNS Resp_Body    CLOB PATH 'Body');

        l_Response_Payload := Tools.B64_Decode (l_Response_Body);

           SELECT Vst_Id, Error
             INTO l_Vst_Id, p_Error
             FROM XMLTABLE (
                      '/*'
                      PASSING Xmltype (l_Response_Payload)
                      COLUMNS Vst_Id    NUMBER PATH 'Visit_Id',
                              Answer    VARCHAR2 (4000) PATH 'Answer',
                              Error     VARCHAR2 (4000) PATH 'Error');

        IF p_Error IS NOT NULL
        THEN
            Set_Ape_Error (l_Ape_Id, p_Error);
            RETURN;
        END IF;

        --Встановлюємо статус "Формування довідки" для запиту в стані "Заведено"
        UPDATE Ap_Execution
           SET Ape_St = 'N', Ape_Ext_Ident = l_Vst_Id
         WHERE Ape_Id = l_Ape_Id;

        --Отримуємо ІД звернення
        SELECT s.Aps_Ap
          INTO l_Ap_Id
          FROM Ap_Execution e JOIN Ap_Service s ON e.Ape_Aps = s.Aps_Id
         WHERE e.Ape_Id = l_Ape_Id;

        SELECT *
          INTO l_Appeal_Old
          FROM Appeal
         WHERE Ap_Id = l_Ap_Id;

        --Встановлюємо статус "Формування довідки" для зверення "Верифіковано" типу "Довідка"
        UPDATE Appeal
           SET Ap_St = 'FD'
         WHERE Ap_Id = l_Ap_Id AND Ap_Tp = 'D' AND Ap_St = 'VO';

        l_Hs := Tools.Gethistsession ();

        INSERT INTO Ap_Log (Apl_Id,
                            Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_St_Old,
                            Apl_Message,
                            Apl_Tp)
            SELECT 0,
                   Ap_Id,
                   l_Hs,
                   Ap_St,
                   l_Appeal_Old.Ap_St,
                      CHR (38)
                   || '6#'
                   || Nrc_Remote_Code
                   || '#'
                   || App_Fn
                   || ' '
                   || App_Mn
                   || ' '
                   || App_Ln
                   || '#'
                   || App_Inn,
                   'SYS'
              FROM Ap_Execution,
                   Ap_Person,
                   Uss_Ndi.v_Ndi_Request_Config,
                   Appeal
             WHERE     Ape_Id = l_Ape_Id
                   AND Ape_App = App_Id
                   AND Ape_Nrc = Nrc_Id
                   AND App_Ap = Ap_Id;

        l_Hs_Rbm := Ikis_Rbm.Tools.Gethistsession (NULL);
        --Реєструємо запит на отримання результату обробки звернення в ІКІС
        Ikis_Rbm.Api$request_Pfu.Reg_Visit_Result_Req (
            p_Rn_Nrt      => 19,
            p_Rn_Hs_Ins   => l_Hs_Rbm,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id,
            p_Ur_Ext_Id   => l_Ape_Id,
            p_Visit_Id    => l_Vst_Id);

        p_Subreq_Created := 'T';

        COMMIT;
    END;

    PROCEDURE Check_Ap_Status (p_Ap_Id   Appeal.Ap_Id%TYPE,
                               p_Hs_Id   Histsession.Hs_Id%TYPE:= NULL)
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        l_Hs := NVL (p_Hs_Id, Tools.Gethistsession ());

        UPDATE Appeal
           SET Ap_St = 'V'
         WHERE     Ap_Id = p_Ap_Id
               AND Ap_St = 'FD'
               AND (SELECT COUNT (*)
                      FROM Ap_Execution, Ap_Service
                     WHERE     Aps_Ap = Ap_Id
                           AND Ape_Aps = Aps_Id
                           AND Ape_St IN ('EV', 'ER', 'V')) =
                   (SELECT COUNT (*)
                      FROM Ap_Execution, Ap_Service
                     WHERE Aps_Ap = Ap_Id AND Ape_Aps = Aps_Id);

        IF SQL%ROWCOUNT > 0
        THEN
            --#73983 2021,12,09
            Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                                  p_Apl_Hs        => l_Hs,
                                  p_Apl_St        => 'V',
                                  p_Apl_Message   => CHR (38) || '7',
                                  p_Apl_St_Old    => 'FD');
        END IF;
    END;

    PROCEDURE Check_Aps_Status (p_Aps_Id Ap_Service.Aps_Id%TYPE)
    IS
    BEGIN
        --Встановлюємо статус "Помилка" для послуг "Формування довідки", якщо э хоч одна помилка і всі оброблені
        UPDATE Ap_Service
           SET Aps_St = 'ERR'
         WHERE     Aps_Id = p_Aps_Id
               AND (Aps_St IS NULL OR Aps_St IN ('1', 'FD'))
               AND EXISTS
                       (SELECT 1
                          FROM Appeal
                         WHERE     Ap_St = 'FD'
                               AND Ap_Tp = 'D'
                               AND Ap_Id = Aps_Ap)
               AND (SELECT COUNT (*)
                      FROM Ap_Execution
                     WHERE Ape_Aps = Aps_Id AND Ape_St IN ('EV', 'ER')) > 0
               AND (SELECT COUNT (*)
                      FROM Ap_Execution
                     WHERE Ape_Aps = Aps_Id AND Ape_St IN ('EV', 'ER', 'V')) =
                   (SELECT COUNT (*)
                      FROM Ap_Execution
                     WHERE Ape_Aps = Aps_Id);

        --Встановлюємо статус "Виконано" для послуг "Формування довідки", якщо э хоч одна помилка і всі оброблені
        UPDATE Ap_Service
           SET Aps_St = '2'
         WHERE     Aps_Id = p_Aps_Id
               AND (Aps_St IS NULL OR Aps_St IN ('1', 'FD'))
               AND EXISTS
                       (SELECT 1
                          FROM Appeal
                         WHERE     Ap_St = 'FD'
                               AND Ap_Tp = 'D'
                               AND Ap_Id = Aps_Ap)
               AND (SELECT COUNT (*)
                      FROM Ap_Execution
                     WHERE Ape_Aps = Aps_Id AND Ape_St IN ('V')) =
                   (SELECT COUNT (*)
                      FROM Ap_Execution
                     WHERE Ape_Aps = Aps_Id);
    END;

    PROCEDURE Set_Ape_Error (p_Id        Ap_Execution.Ape_Id%TYPE,
                             p_Message   Ap_Log.Apl_Message%TYPE)
    IS
        l_Hs             Histsession.Hs_Id%TYPE;
        l_Ap_Execution   Ap_Execution%ROWTYPE;
        l_Ap_Service     Ap_Service%ROWTYPE;
        l_Ap_Person      Ap_Person%ROWTYPE;
        l_Appeal_Old     Appeal%ROWTYPE;
        l_Config         Uss_Ndi.v_Ndi_Request_Config%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Ap_Execution
          FROM Ap_Execution
         WHERE Ape_Id = p_Id;

        SELECT *
          INTO l_Ap_Service
          FROM Ap_Service
         WHERE Aps_Id = l_Ap_Execution.Ape_Aps;

        SELECT *
          INTO l_Ap_Person
          FROM Ap_Person
         WHERE App_Id = l_Ap_Execution.Ape_App;

        SELECT *
          INTO l_Config
          FROM Uss_Ndi.v_Ndi_Request_Config
         WHERE Nrc_Id = l_Ap_Execution.Ape_Nrc;

        SELECT *
          INTO l_Appeal_Old
          FROM Appeal
         WHERE Ap_Id = l_Ap_Service.Aps_Ap;

        UPDATE Ap_Execution
           SET Ape_St = 'EV'
         WHERE Ape_St IN ('N') AND Ape_Id = p_Id;

        UPDATE Ap_Execution
           SET Ape_St = 'ER'
         WHERE Ape_St IN ('R') AND Ape_Id = p_Id;

        l_Hs := Tools.Gethistsession ();

        INSERT INTO Ap_Log (Apl_Id,
                            Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_St_Old,
                            Apl_Message,
                            Apl_Tp)
            SELECT 0,
                   Ap_Id,
                   l_Hs,
                   Ap_St,
                   l_Appeal_Old.Ap_St,
                      CHR (38)
                   || '8#'
                   || l_Config.Nrc_Remote_Code
                   || '#'
                   || l_Ap_Person.App_Fn
                   || ' '
                   || l_Ap_Person.App_Mn
                   || ' '
                   || l_Ap_Person.App_Ln
                   || '#'
                   || l_Ap_Person.App_Inn
                   || '#'
                   || p_Message,
                   'SYS'
              FROM Ap_Execution, Ap_Person, Appeal
             WHERE Ape_Id = p_Id AND Ape_App = App_Id AND App_Ap = Ap_Id;

        Check_Aps_Status (l_Ap_Service.Aps_Id);
        Check_Ap_Status (l_Ap_Service.Aps_Ap, l_Hs);

        COMMIT;
    END;

    PROCEDURE Save_Ape_Result (p_Id       Appeal.Ap_Id%TYPE,
                               p_Doc_Id   Ap_Document.Apd_Doc%TYPE,
                               p_Dh_Id    Ap_Document.Apd_Dh%TYPE)
    IS
        l_Ap           Appeal.Ap_Id%TYPE;
        l_Aps_Id       Ap_Service.Aps_Id%TYPE;
        l_Hs           Histsession.Hs_Id%TYPE;
        l_Appeal_Old   Appeal%ROWTYPE;
    BEGIN
        SELECT Aps_Ap, Aps_Id
          INTO l_Ap, l_Aps_Id
          FROM Ap_Service, Ap_Execution
         WHERE Ape_Id = p_Id AND Ape_Aps = Aps_Id;

        SELECT *
          INTO l_Appeal_Old
          FROM Appeal
         WHERE Ap_Id = l_Ap;

        UPDATE Ap_Execution
           SET Ape_St = 'V'
         WHERE Ape_Id = p_Id AND Ape_St = 'N';

        INSERT INTO Ap_Document (Apd_Id,
                                 Apd_Ap,
                                 Apd_App,
                                 Apd_Ndt,
                                 Apd_Doc,
                                 Apd_Dh)
            SELECT 0,
                   App_Ap,
                   Ape_App,
                   Nrc_Ndt,
                   p_Doc_Id,
                   p_Dh_Id
              FROM Ap_Execution, Ap_Person, Uss_Ndi.v_Ndi_Request_Config
             WHERE Ape_Id = p_Id AND Ape_App = App_Id AND Ape_Nrc = Nrc_Id;

        l_Hs := Tools.Gethistsession ();

        INSERT INTO Ap_Log (Apl_Id,
                            Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_St_Old,
                            Apl_Message,
                            Apl_Tp)
            SELECT 0,
                   Ap_Id,
                   l_Hs,
                   Ap_St,
                   l_Appeal_Old.Ap_St,
                      CHR (38)
                   || '9#'
                   || Nrc_Remote_Code
                   || '#'
                   || App_Fn
                   || ' '
                   || App_Mn
                   || ' '
                   || App_Ln
                   || '#'
                   || App_Inn,
                   'SYS'
              FROM Ap_Execution,
                   Ap_Person,
                   Uss_Ndi.v_Ndi_Request_Config,
                   Appeal
             WHERE     Ape_Id = p_Id
                   AND Ape_App = App_Id
                   AND Ape_Nrc = Nrc_Id
                   AND App_Ap = Ap_Id;

        Check_Aps_Status (l_Aps_Id);
        Check_Ap_Status (l_Ap, l_Hs);

        COMMIT;
    END;

    --Проставлення у чергу на відправку довідки про пільги
    PROCEDURE Reg_Appeal_Bnf01_Send (p_ap_id IN NUMBER)
    IS
        c_Rn_Nrt   CONSTANT NUMBER := 72;
        c_Ur_Urt   CONSTANT NUMBER := 72;
        l_Ur_Id             NUMBER;
        l_ap_src            appeal.ap_tp%TYPE;
        l_Rn_Id             NUMBER (14);
        l_ap_tp             appeal.ap_tp%TYPE;
        l_ap_ext_ident      appeal.ap_ext_ident%TYPE;
    BEGIN
        SELECT ap.ap_src, ap.ap_tp, ap.ap_ext_ident
          INTO l_ap_src, l_ap_tp, l_ap_ext_ident
          FROM appeal ap
         WHERE ap.ap_id = p_ap_id;

        IF l_ap_src = 'PFU' AND l_ap_tp = 'D' AND l_ap_ext_ident IS NOT NULL
        THEN
            ikis_rbm.Api$uxp_Request.Register_Out_Request (
                p_Ur_Plan_Dt     => SYSDATE,
                p_Ur_Urt         => c_Ur_Urt,
                p_Ur_Create_Wu   => NULL,
                p_Ur_Ext_Id      => p_ap_id,
                p_Ur_Body        => NULL,
                p_New_Id         => l_Ur_Id,
                p_Rn_Nrt         => c_Rn_Nrt,
                p_Rn_Src         => l_ap_src,
                p_Rn_Hs_Ins      => NULL,
                p_New_Rn_Id      => l_Rn_Id);
        --Ikis_Rbm.Api$request.Save_Rn_Common_Info(p_Rnc_Rn => l_Rn_Id, p_Rnc_Pt => c_ap_vf, p_Rnc_Val_Id => l_ap_vf);
        END IF;
    END;



    -------------------------------------------------------------------------------
    --  Отримання даних для запиту на отримання результату виконання звернення
    -------------------------------------------------------------------------------
    PROCEDURE Get_Appeal_Bnf01_Data (p_ap_id            IN     NUMBER,
                                     p_operation_type   IN     VARCHAR2,
                                     p_res                 OUT SYS_REFCURSOR,
                                     p_res_files           OUT SYS_REFCURSOR)
    IS
        l_Request_Body_xml         XMLTYPE;
        l_Request_files_xml        XMLTYPE;
        c_OperationType   CONSTANT VARCHAR2 (100) := 'ADD_INFO_BNF01_FILES';
        l_IdIn                     NUMBER (14);
        l_objid                    NUMBER (14);
        l_Message                  VARCHAR2 (4000);
        l_Status                   NUMBER (14);
        l_UserMessage              VARCHAR2 (4000);
        l_is_dovidka_exist         PLS_INTEGER := 0;
        l_ap_st                    VARCHAR2 (100);
        l_file_size                NUMBER (14);
        l_file_name                VARCHAR2 (4000);
        l_is_error_file            NUMBER (14) := 0;
    BEGIN
        IF p_operation_type = c_OperationType
        THEN
            SELECT NVL (ap.ap_ext_ident, 0), ap.ap_st
              INTO l_objid, l_ap_st
              FROM appeal ap
             WHERE ap.ap_id = p_ap_id AND ap.ap_src = 'PFU';

            l_IdIn := p_ap_id;

            SELECT COUNT (*), MAX (f.file_size), MAX (f.file_name)
              INTO l_is_dovidka_exist, l_file_size, l_file_name
              FROM uss_visit.Ap_Document  d
                   JOIN Uss_Doc.v_Doc_Attachments a ON d.Apd_Dh = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
             WHERE     d.Apd_Ap = p_ap_id
                   AND d.history_status = 'A'
                   AND f.File_Id IS NOT NULL
                   AND d.apd_ndt = 10227;

            IF l_is_dovidka_exist = 1
            THEN
                IF INSTR (UPPER (l_file_name), 'ERROR') > 0
                THEN
                    l_is_error_file := 1;
                END IF;
            END IF;

            IF l_is_dovidka_exist = 1 AND l_is_error_file = 0
            THEN
                l_Status := 1;
            ELSE
                l_Status := 0;
            END IF;

            IF l_Status = 0 AND l_is_error_file = 1
            THEN
                l_Message := 'Довідка не надається';
                l_UserMessage := 'Довідка не надається';
            ELSIF (l_Status = 0 AND l_is_dovidka_exist = 0)
            THEN
                l_Message := 'Помилка верифікації звернення';
                l_UserMessage := 'Помилка верифікації звернення у МСП';
            ELSE
                l_Message := '';
                l_UserMessage := '';
            END IF;

            OPEN p_res FOR
                SELECT p_ap_id              AS "IdIn",
                       p_operation_type     AS "OperationType",
                       l_objid              AS "ObjId",
                       l_Message            AS "Message",
                       l_Status             AS "Status",
                       l_UserMessage        AS "UserMessage"
                  FROM DUAL;

            OPEN p_res_files FOR
                SELECT f.file_id        "IdFile",
                       NULL             "FileCode",
                       f.file_name      AS "FileName",
                       f.file_code      AS "CeaCode",
                       fs.file_name     AS FileNameSign,
                       fs.file_code     AS CeaCodeSign
                  FROM Ap_Document  d
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON d.Apd_Dh = a.Dat_Dh
                       JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                       LEFT JOIN Uss_Doc.v_Files fs
                           ON a.dat_sign_file = fs.File_Id
                 WHERE     d.Apd_Ap = p_ap_id
                       AND d.history_status = 'A'
                       AND f.File_Id IS NOT NULL
                       AND l_Status = 1;
        END IF;
    END;
END Dnet$exch_Uss2ikis;
/