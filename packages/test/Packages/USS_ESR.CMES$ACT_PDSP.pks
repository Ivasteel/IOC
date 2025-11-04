/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_PDSP
IS
    -- Author  : SHOSTAK
    -- Created : 18.07.2023 2:54:17 PM
    -- Purpose : Робота з рішеннями про надання соціальних послуг

    Pkg       CONSTANT VARCHAR2 (30) := 'CMES$ACT_PDSP';

    --Типи підписантів
    c_Signer_Tp_Prov   VARCHAR2 (10) := 'PR';                     --Надавач СП

    PROCEDURE Set_Cm (p_At_Id IN NUMBER,                          --Ід ріщення
                                         p_At_Cu IN NUMBER --Ід користувача КМа, який буде вести випадок
                                                          );

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL);

    FUNCTION Get_Msg_Num (p_Atd_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Messages_Internat_By_Ap (p_Ap_Id   IN     NUMBER,
                                           p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Get_Messages_Req_By_Ap (p_Ap_Id   IN     NUMBER,
                                      p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Get_Messages_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Messages_Rc (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Vouchers_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

    FUNCTION Get_Act_File (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Doc_File (p_Atd_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Approver_Pib (p_At_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act              OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR,
                            p_Services         OUT SYS_REFCURSOR,
                            p_Reject_Info      OUT SYS_REFCURSOR);

    PROCEDURE Check_Right (p_At_Id          IN     NUMBER,
                           p_At_Right_Log      OUT SYS_REFCURSOR,
                           p_Messages          OUT SYS_REFCURSOR);

    PROCEDURE Get_Doc_Types (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Save_Right_Log (p_At_Id IN NUMBER, p_At_Right_Log IN CLOB);

    PROCEDURE Save_Reject_Info (p_At_Id IN NUMBER, p_At_Reject_Info IN CLOB);

    PROCEDURE Init_Decision_Doc (p_At_Id       IN     NUMBER,
                                 p_Doc_Cur        OUT SYS_REFCURSOR,
                                 p_Attrs_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Init_Msg_Doc (p_At_Id       IN     NUMBER,
                            p_Doc_Cur        OUT SYS_REFCURSOR,
                            p_Attrs_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Build_Msg_Form (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Save_Documents (p_At_Id IN NUMBER, p_At_Documents IN CLOB);

    PROCEDURE Set_Doc_Signed (p_Atd_Id IN NUMBER);

    PROCEDURE Approve_Act (p_At_Id IN NUMBER);

    PROCEDURE Regect_Act (p_At_Id IN NUMBER);

    PROCEDURE Regect_Act_Rejet (p_At_Id IN NUMBER);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER);

    PROCEDURE Get_Cm_Ss_Rec_Cnt (p_Cu_Id           IN     NUMBER,
                                 p_Cmes_Owner_Id   IN     NUMBER,
                                 p_Cnt                OUT NUMBER);

    PROCEDURE Get_Cm_Ss_Rec (p_Cu_Id           IN     NUMBER,
                             p_Cmes_Owner_Id   IN     NUMBER,
                             p_Rec_Pib         IN     VARCHAR2,
                             p_Rec_Birth_Dt    IN     DATE,
                             p_Rec_Numident    IN     VARCHAR2,
                             p_Res                OUT SYS_REFCURSOR);

    FUNCTION Is_Role_Assigned (p_Cmes_Owner_Id   IN NUMBER,
                               p_Role            IN VARCHAR2,
                               p_Cu_Id           IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN;

    PROCEDURE Change_Cm (p_Cu_Id_Old       IN NUMBER,
                         p_Cu_Id_New       IN NUMBER,
                         p_Cmes_Owner_Id   IN NUMBER,
                         p_Rec_List        IN CLOB);

    PROCEDURE Copy_Document2Socialcard (p_at act.at_id%TYPE);
END Cmes$act_Pdsp;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_PDSP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_PDSP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_PDSP TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_PDSP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:22 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_PDSP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Is_Role_Assigned (p_Cmes_Owner_Id   IN NUMBER,
                               p_Role            IN VARCHAR2,
                               p_Cu_Id           IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN
    IS
    BEGIN
        IF p_Cu_Id IS NULL
        THEN
            RETURN Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => p_Role);
        ELSE
            RETURN Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cu_Id           => p_Cu_Id,
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => p_Role);
        END IF;
    END;

    FUNCTION Get_At_Rnspm (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_At_Rnspm   NUMBER;
    BEGIN
        SELECT a.At_Rnspm
          INTO l_At_Rnspm
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        RETURN l_At_Rnspm;
    END;

    --------------------------------------------------------------
    --   Встановлення кейс менеджера який буде вести випадок
    --------------------------------------------------------------
    PROCEDURE Set_Cm (p_At_Id IN NUMBER,                          --Ід ріщення
                                         p_At_Cu IN NUMBER --Ід користувача КМа, який буде вести випадок
                                                          )
    IS
        l_At_St      VARCHAR2 (10);
        l_At_Rnspm   NUMBER;
        l_At_Cu      NUMBER;
    BEGIN
        Write_Audit ('Set_Cm');

        SELECT a.At_Rnspm, a.At_Cu, a.At_St
          INTO l_At_Rnspm, l_At_Cu, l_At_St
          FROM Act a
         WHERE a.At_Id = p_At_Id AND a.At_Tp = 'PDSP';

        IF l_At_Cu = p_At_Cu
        THEN
            RETURN;
        END IF;

        IF l_At_St IN ('O', 'W', 'SC')
        THEN
            Raise_Application_Error (
                -20000,
                'Зміна кейс-менеджера в поточному стані рішення заборонена');
        END IF;

        --Дозволяємо виконання операції лише для користувача надавача за яким закріплено акт
        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => l_At_Rnspm,
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF NOT Is_Role_Assigned (p_Cu_Id           => p_At_Cu,
                                 p_Cmes_Owner_Id   => l_At_Rnspm,
                                 p_Role            => 'NSP_CM')
        THEN
            Raise_Application_Error (
                -20000,
                'Обраний кейс-менеджер не закріплений за поточним надавачем');
        END IF;

        CMES$ACT.Set_Cm_Execute (p_At_Id, p_At_Cu);
    END;

    FUNCTION Get_Act_File (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_File_Code   VARCHAR2 (50);
    BEGIN
        SELECT MAX (f.File_Code)
          INTO l_File_Code
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Ndt_Id
               AND d.History_Status = 'A';

        RETURN l_File_Code;
    END;

    FUNCTION Get_Doc_File (p_Atd_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_File_Code   VARCHAR2 (50);
    BEGIN
        SELECT MAX (f.File_Code)
          INTO l_File_Code
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE d.Atd_Id = p_Atd_Id;

        RETURN l_File_Code;
    END;


    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ
    -- (ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        /*
        В ЖЦ внести правку: якщо у зверненні вказано послугу 012.0 «Екстрене (кризове) втручання»
        і при цьому встановлено ознаку nda_id in (1870, 1947) = ‘T’, то цю ознаку необхідно ігнорувати –
        рішення має йти з SC на OKS
        */
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Num,
                   a.At_Dt,
                   a.At_Src,
                   s.Dic_Name
                       AS At_Src_Name,
                   a.At_St,
                   St.Dic_Name
                       AS At_St_Name,
                   a.At_Pc,
                   a.At_Ap,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   a.at_rnspm,
                   --Ким затверджено рішення
                   Get_Approver_Pib (a.At_Id)
                       AS At_Approver_Pib,
                   --Отримувач
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   a.At_Sc
                       AS At_Sc,
                   --Код файлу друкованої форми
                   Get_Act_File (a.At_Id, 842)
                       AS At_Form_File,
                   Api$appeal.Get_Ap_Doc_Str (p_Ap_Id       => a.At_Ap,
                                              p_Nda_Class   => 'DIRECTION')
                       AS At_Direction,
                   (SELECT r.Dic_Name
                      FROM Uss_Ndi.v_Ddn_Ss_Rcp_Ap r
                     WHERE r.Dic_Value =
                           Api$appeal.Get_Ap_Doc_Str (
                               p_Ap_Id       => a.At_Ap,
                               p_Nda_Class   => 'DIRECTION'))
                       AS At_Direction_Name,
                   CASE
                       WHEN     (SELECT COUNT (1)
                                   FROM At_Service Ats
                                  WHERE     Ats.Ats_At = a.At_Id
                                        AND Ats.History_Status = 'A'
                                        AND Ats.Ats_St IN ('R', 'P', 'PP')
                                        AND Ats.Ats_Nst = 420) >
                                0
                            AND a.At_St IN ('SP1')
                       THEN
                           'OKS'                                       --94000
                       WHEN     NVL (
                                    Api$appeal.Get_Ap_o_Doc_String (a.At_Ap,
                                                                    801,
                                                                    1870),
                                    'F') =
                                'T'
                            AND a.At_St = 'SA'
                       THEN
                           'ANPOE'
                       WHEN     (SELECT COUNT (1)
                                   FROM Act Oks
                                  WHERE     Oks.At_Main_Link = a.At_Id
                                        AND Oks.At_Tp = 'OKS'
                                        AND Oks.At_St = 'GP') >
                                0
                            AND a.At_St = 'SA'
                       THEN
                           'ANPK'                                      --94000
                       ELSE
                           NULL
                   END
                       AS Next_Act,
                   -- #95378  дата до статусу зміни стану рішення
                    (SELECT MAX (h.hs_dt)
                       FROM AT_log  L
                            JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
                      WHERE     l.atl_at = a.at_id
                            AND L.ATL_MESSAGE LIKE CHR (38) || '17')
                       AS At_St_dt,
                   -- #101695 Дата затвердження рішення
                    (SELECT MIN (h.hs_dt)
                       FROM AT_log  L
                            JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
                      WHERE     atl_at = a.at_id
                            AND L.ATL_MESSAGE LIKE CHR (38) || '17'
                            AND l.atl_st IN ('SA', 'SD'))
                       AS At_Approve_Dt,
                   a.At_Case_Class,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St ON a.At_St = St.Dic_Value
                   JOIN Opfu o ON a.At_Org = o.Org_Id;
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ ДЛЯ КЕЙС МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,           --ignore
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;                          --301

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_PDSP.Get_Acts_Cm',
            p_obj_tp   => 'CMES_CU_ID',
            p_obj_id   => l_Cu_Id,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ' p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_At_St='
                || p_At_St
                || ' p_At_Main_Link='
                || p_At_Main_Link
                || ' p_At_Pc='
                || p_At_Pc
                || ' p_At_Ap='
                || p_At_Ap
                || ' p_Ap_Is_Correct='
                || p_Ap_Is_Correct,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'PDSP'
                   AND a.At_Cu = l_Cu_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap)
                   AND (   p_Ap_Is_Correct IS NULL
                        OR API$APPEAL.Is_Appeal_Maked_Correct (at_ap) =
                           p_Ap_Is_Correct);

        Get_Act_List (p_Res);
    END;

    FUNCTION Get_Msg_Num (p_Atd_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        SELECT a.Atda_Val_String
          INTO l_Result
          FROM At_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Atda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
         WHERE a.Atda_Atd = p_Atd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;


    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ
    --  (по відфільтрованому списку)
    -----------------------------------------------------------
    PROCEDURE Get_Messages (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            WITH
                Doc
                AS
                    (SELECT t.x_Id                       AS Atd_Id,
                            (  SELECT s.Ati_Id
                                 FROM At_Signers s
                                WHERE     s.Ati_Atd = t.x_Id
                                      AND s.History_Status = 'A'
                             ORDER BY s.Ati_Sign_Dt DESC NULLS LAST
                                FETCH FIRST ROW ONLY)    AS Ati_Id
                       FROM Tmp_Work_Ids t)
            SELECT --Id повідомлення
                   d.Atd_Id
                       AS Msg_Id,
                   --Номер повідомлення
                   Get_Msg_Num (d.Atd_Id)
                       AS Msg_Num,
                   --Дата реєстрації повідомлення
                   h.Dh_Dt
                       AS Msg_Dt,
                   --Джерело
                   h.Dh_Src
                       AS Msg_Src,
                   s.Dic_Name
                       AS Msg_Src_Name,
                   --Статус(позначка про підписання T/F)
                   s.Ati_Is_Signed
                       AS Msg_St,
                   CASE
                       WHEN s.Ati_Is_Signed = 'T' THEN 'Підписано'
                       ELSE 'Очікує підписання'
                   END
                       AS Msg_St_Name,
                   --Ким сформовано повідомлення
                   NVL (Ikis_Rbm.Tools.Getcupib (h.Dh_Cu),
                        Tools.Getuserpib (h.Dh_Wu))
                       AS Msg_Creator_Pib,
                   --Ким затверджено(підписано) повідомлення
                   NVL (Ikis_Rbm.Tools.Getcupib (s.Ati_Cu),
                        Tools.Getuserpib (s.Ati_Wu))
                       AS Msg_Approver_Pib,
                   --Повідомлення щодо кого (отримувач соціальних послуг)
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS Msg_Sc_Pib,
                   --Друкована форма повідомлення
                   Get_Doc_File (d.Atd_Id)
                       AS Msg_Form_File
              FROM Doc  t
                   JOIN At_Document d ON t.Atd_Id = d.Atd_Id
                   JOIN Act a ON a.At_Id = d.Atd_At
                   JOIN At_Signers s ON t.Ati_Id = s.Ati_Id
                   JOIN Uss_Doc.v_Doc_Hist h ON d.Atd_Dh = h.Dh_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON h.Dh_Src = s.Dic_Value;
    END;

    PROCEDURE Get_Messages_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            WITH
                Doc
                AS
                    (SELECT t.x_Id                       AS Atd_Id,
                            (  SELECT s.Ati_Id
                                 FROM At_Signers s
                                WHERE     s.Ati_Atd = t.x_Id
                                      AND s.History_Status = 'A'
                             ORDER BY s.Ati_Sign_Dt DESC NULLS LAST
                                FETCH FIRST ROW ONLY)    AS Ati_Id
                       FROM Tmp_Work_Ids t)
            SELECT --Id повідомлення
                   d.Atd_Id
                       AS Msg_Id,
                   --Номер повідомлення
                   Get_Msg_Num (d.Atd_Id)
                       AS Msg_Num,
                   --Дата реєстрації повідомлення
                   h.Dh_Dt
                       AS Msg_Dt,
                   --Джерело
                   h.Dh_Src
                       AS Msg_Src,
                   s.Dic_Name
                       AS Msg_Src_Name,
                   --Статус(позначка про підписання T/F)
                   s.Ati_Is_Signed
                       AS Msg_St,
                   CASE
                       WHEN s.Ati_Is_Signed = 'T' THEN 'Підписано'
                       ELSE 'Очікує підписання'
                   END
                       AS Msg_St_Name,
                   --Ким сформовано повідомлення
                   NVL (Ikis_Rbm.Tools.Getcupib (h.Dh_Cu),
                        Tools.Getuserpib (h.Dh_Wu))
                       AS Msg_Creator_Pib,
                   --Ким затверджено(підписано) повідомлення
                   NVL (Ikis_Rbm.Tools.Getcupib (s.Ati_Cu),
                        Tools.Getuserpib (s.Ati_Wu))
                       AS Msg_Approver_Pib,
                   --Повідомлення щодо кого (отримувач соціальних послуг)
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS Msg_Sc_Pib,
                   --Друкована форма повідомлення
                   f.file_code
                       AS Msg_Form_File,
                   f.file_name,
                   f.file_mime_type,
                   sf.file_code
                       Msg_Form_File_Sign_Code,
                   sf.file_name
                       Msg_Form_File_Sign_Name,
                   sf.file_mime_type
                       Msg_Form_File_Sign_Mime_Type
              FROM Doc  t
                   JOIN At_Document d ON t.Atd_Id = d.Atd_Id
                   JOIN Act a ON a.At_Id = d.Atd_At
                   JOIN At_Signers s ON t.Ati_Id = s.Ati_Id
                   JOIN Uss_Doc.v_Doc_Hist h ON d.Atd_Dh = h.Dh_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON h.Dh_Src = s.Dic_Value
                   JOIN Uss_Doc.v_Doc_Attachments da ON d.Atd_Dh = da.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON da.Dat_File = f.File_Id
                   JOIN Uss_Doc.v_Files sf ON da.Dat_Sign_File = sf.File_Id
             WHERE s.Ati_Is_Signed = 'T';
    END;


    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ СПСЗН ПРО ПРИЙНЯТТЯ
    --  ОСОБИ НА ОБСЛУГОВУВАННЯ ДО ІНТЕРНАТНОГО ЗАКЛАДУ
    --  (по зверненню)
    -----------------------------------------------------------
    PROCEDURE Get_Messages_Internat_By_Ap (p_Ap_Id   IN     NUMBER,
                                           p_Res        OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Messages_By_Ap');

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        DELETE FROM Tmp_Work_Ids;

        --todo: додати параметр ІД надавача або тип кабінету щоб не робити зайвий запит

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Atd_Id
              FROM Act  a
                   JOIN At_Document d
                       ON     a.At_Id = d.Atd_At
                          AND d.History_Status = 'A'
                          AND d.Atd_Ndt IN (855)
             WHERE     a.At_Ap = p_Ap_Id
                   AND (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Sc = l_Cu_Sc
                                       AND p.App_Tp = 'Z'
                                       AND p.History_Status = 'A'
                                       --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                       AND NVL (Ap.Ap_Sub_Tp, '-') <> 'SC'))
                   AND a.At_Tp = 'PDSP';

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT d.Atd_Id
                  FROM Act  a
                       JOIN At_Document d
                           ON     a.At_Id = d.Atd_At
                              AND d.History_Status = 'A'
                              AND d.Atd_Ndt IN (855)
                       JOIN Ikis_Rbm.v_Cu_Users2roles r
                           ON     r.Cu2r_Cu = l_Cu_Id
                              AND a.At_Rnspm = r.Cu2r_Cmes_Owner_Id
                              AND r.History_Status = 'A'
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON     r.Cu2r_Cr = Cr.Cr_Id
                              AND Cr.Cr_Code = 'NSP_SPEC'
                 WHERE a.At_Ap = p_Ap_Id AND a.At_Tp = 'PDSP';
        END IF;

        Get_Messages (p_Res);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ПРО НАПРАВЛЕННЯ
    --  КЛОПОТАННЯ ПРО ВЛАШТУВАННЯ ОСОБИ З ІНВАЛІДНІСТЮ, ОСОБИ
    --  ПОХИЛОГО ВІКУ ДО ІНТЕРНАТНОЇ(ГО) УСТАНОВИ/ЗАКЛАДУ
    --  (по зверненню)
    -----------------------------------------------------------
    PROCEDURE Get_Messages_Req_By_Ap (p_Ap_Id   IN     NUMBER,
                                      p_Res        OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Messages_By_Ap');

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        DELETE FROM Tmp_Work_Ids;

        --todo: додати параметр ІД надавача або тип кабінету щоб не робити зайвий запит

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Atd_Id
              FROM Act  a
                   JOIN At_Document d
                       ON     a.At_Id = d.Atd_At
                          AND d.History_Status = 'A'
                          AND d.Atd_Ndt IN (853)
             WHERE     a.At_Ap = p_Ap_Id
                   AND (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Sc = l_Cu_Sc
                                       AND p.App_Tp = 'Z'
                                       AND p.History_Status = 'A'
                                       --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                       AND NVL (Ap.Ap_Sub_Tp, '-') <> 'SC'))
                   AND a.At_Tp = 'PDSP';

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT d.Atd_Id
                  FROM Act  a
                       JOIN At_Document d
                           ON     a.At_Id = d.Atd_At
                              AND d.History_Status = 'A'
                              AND d.Atd_Ndt IN (853)
                       JOIN Ikis_Rbm.v_Cu_Users2roles r
                           ON     r.Cu2r_Cu = l_Cu_Id
                              AND a.At_Rnspm = r.Cu2r_Cmes_Owner_Id
                              AND r.History_Status = 'A'
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON     r.Cu2r_Cr = Cr.Cr_Id
                              AND Cr.Cr_Code = 'NSP_SPEC'
                 WHERE a.At_Ap = p_Ap_Id AND a.At_Tp = 'PDSP';
        END IF;

        Get_Messages (p_Res);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ПРО НАДАННЯ/ВІДМОВУ
    --  ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Messages_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Messages_By_Ap');

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        Tools.LOG (
            p_src      => 'USS_ESR.Cmes$act_Pdsp.Get_Messages_By_Ap',
            p_obj_tp   => 'APPEAL',
            p_obj_id   => p_Ap_Id,
            p_regular_params   =>
                'l_Cu_Id=' || l_Cu_Id || ' l_Cu_Sc=' || l_Cu_Sc);

        DELETE FROM Tmp_Work_Ids;

        --todo: додати параметр ІД надавача або тип кабінету щоб не робити зайвий запит

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Atd_Id
              FROM Act  a
                   JOIN At_Document d
                       ON     a.At_Id = d.Atd_At
                          AND d.History_Status = 'A'
                          AND d.Atd_Ndt IN (843, 851)
             WHERE     a.At_Ap = p_Ap_Id
                   AND (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Sc = l_Cu_Sc
                                       AND p.App_Tp = 'Z'
                                       AND p.History_Status = 'A'
                                       --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                       AND NVL (Ap.Ap_Sub_Tp, '-') <> 'SC'))
                   AND a.At_Tp = 'PDSP';

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT d.Atd_Id
                  FROM Act  a
                       JOIN At_Document d
                           ON     a.At_Id = d.Atd_At
                              AND d.History_Status = 'A'
                              AND d.Atd_Ndt IN (843, 851)
                       JOIN Ikis_Rbm.v_Cu_Users2roles r
                           ON     r.Cu2r_Cu = l_Cu_Id
                              AND a.At_Rnspm = r.Cu2r_Cmes_Owner_Id
                              AND r.History_Status = 'A'
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON     r.Cu2r_Cr = Cr.Cr_Id
                              AND Cr.Cr_Code = 'NSP_SPEC'
                 WHERE a.At_Ap = p_Ap_Id AND a.At_Tp = 'PDSP';
        END IF;

        Get_Messages_List (p_Res);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ПРО НАДАННЯ/ВІДМОВУ
    --  ДЛЯ ОСП
    -----------------------------------------------------------
    PROCEDURE Get_Messages_Rc (p_Res OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Messages_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Atd_Id
              FROM Act  a
                   JOIN At_Document d
                       ON     a.At_Id = d.Atd_At
                          AND d.History_Status = 'A'
                          AND d.Atd_Ndt IN (843, 851)
             WHERE     (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Sc = l_Cu_Sc
                                       AND p.App_Tp = 'Z'
                                       AND p.History_Status = 'A'
                                       --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                       AND NVL (Ap.Ap_Sub_Tp, '-') <> 'SC'))
                   AND a.At_Tp = 'PDSP';

        Get_Messages (p_Res);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПУТІВОК
    --  (по відфільтрованому списку)
    -----------------------------------------------------------
    PROCEDURE Get_Vouchers (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            WITH
                Doc
                AS
                    (SELECT t.x_Id                       AS Atd_Id,
                            (  SELECT s.Ati_Id
                                 FROM At_Signers s
                                WHERE     s.Ati_Atd = t.x_Id
                                      AND s.History_Status = 'A'
                             ORDER BY s.Ati_Sign_Dt DESC NULLS LAST
                                FETCH FIRST ROW ONLY)    AS Ati_Id
                       FROM Tmp_Work_Ids t)
            SELECT --Номер повідомлення
                   Get_Msg_Num (d.Atd_Id)
                       AS Voucher_Num,
                   --Дата реєстрації повідомлення
                   h.Dh_Dt
                       AS Voucher_Dt,
                   --Джерело
                   h.Dh_Src
                       AS Voucher_Src,
                   s.Dic_Name
                       AS Voucher_Src_Name,
                   --Статус
                   s.Ati_Is_Signed
                       AS Voucher_St,
                   CASE
                       WHEN s.Ati_Is_Signed = 'T' THEN 'Підписано'
                       ELSE 'Очікує підписання'
                   END
                       AS Voucher_St_Name,
                   --Ким затверджено(підписано) повідомлення
                   NVL (Ikis_Rbm.Tools.Getcupib (s.Ati_Cu),
                        Tools.Getuserpib (s.Ati_Wu))
                       AS Voucher_Approver_Pib,
                   --Повідомлення щодо кого (отримувач соціальних послуг)
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS Voucher_Sc_Pib,
                   --Друкована форма повідомлення
                   Get_Doc_File (d.Atd_Id)
                       AS Voucher_Form_File
              FROM Doc  t
                   JOIN At_Document d ON t.Atd_Id = d.Atd_Id
                   JOIN Act a ON d.Atd_At = a.At_Id
                   JOIN At_Signers s ON t.Ati_Id = s.Ati_Id
                   JOIN Uss_Doc.v_Doc_Hist h ON d.Atd_Dh = h.Dh_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON h.Dh_Src = s.Dic_Value;
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ ПУТІВОК
    --  ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Vouchers_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Vouchers_By_Ap');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        DELETE FROM Tmp_Work_Ids;

        --todo: додати параметр ІД надавача або тип кабінету щоб не робити зайвий запит

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT d.Atd_Id
              FROM Act  a
                   JOIN At_Document d
                       ON     a.At_Id = d.Atd_At
                          AND d.History_Status = 'A'
                          AND d.Atd_Ndt = 854
             WHERE     a.At_Ap = p_Ap_Id
                   AND (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Sc = l_Cu_Sc
                                       AND p.App_Tp = 'Z'
                                       AND p.History_Status = 'A'
                                       --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                       AND NVL (Ap.Ap_Sub_Tp, '-') <> 'SC'))
                   AND a.At_Tp = 'PDSP';

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT d.Atd_Id
                  FROM Act  a
                       JOIN At_Document d
                           ON     a.At_Id = d.Atd_At
                              AND d.History_Status = 'A'
                              AND d.Atd_Ndt = 854
                       JOIN Ikis_Rbm.v_Cu_Users2roles r
                           ON     r.Cu2r_Cu = l_Cu_Id
                              AND a.At_Rnspm = r.Cu2r_Cmes_Owner_Id
                              AND r.History_Status = 'A'
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON     r.Cu2r_Cr = Cr.Cr_Id
                              AND Cr.Cr_Code = 'NSP_SPEC'
                 WHERE a.At_Ap = p_Ap_Id AND a.At_Tp = 'PDSP';
        END IF;

        Get_Vouchers (p_Res);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_PDSP.Get_Acts_Pr',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ' p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_At_St='
                || p_At_St
                || ' p_Ap_Is_Correct='
                || p_Ap_Is_Correct,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Tools.LOG (
                p_src              => 'USS_ESR.CMES$ACT_PDSP.Get_Acts_Pr',
                p_obj_tp           => 'CMES_OWNER_ID',
                p_obj_id           => p_Cmes_Owner_Id,
                p_regular_params   => 'Insufficient privileges.',
                p_lob_param        =>
                    tools.GetStartPackageName (
                        DBMS_UTILITY.FORMAT_CALL_STACK ()));
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'PDSP'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_Ap_Is_Correct IS NULL
                        OR API$APPEAL.Is_Appeal_Maked_Correct (at_ap) =
                           p_Ap_Is_Correct);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --    ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');
        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_PDSP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                'p_Ap_Id=' || p_Ap_Id || ', l_Sc_Id=' || l_Sc_Id,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Is_Role_Assigned (p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Role            => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'PDSP'
                       AND a.At_Rnspm = p_Cmes_Owner_Id;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Sc = l_Sc_Id
                       AND a.At_Tp = 'PDSP';
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_PDSP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                'p_Ap_Id=' || p_Ap_Id || ', l_Sc_Id=' || l_Sc_Id);

        Get_Act_List (p_Acts);
    END;


    FUNCTION Get_Approver_Pib (p_At_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
          SELECT NVL (Ikis_Rbm.Tools.Getcupib (s.Hs_Cu),
                      Tools.Getuserpib (s.Hs_Wu))
            INTO l_Result
            FROM At_Log l JOIN Histsession s ON l.Atl_Hs = s.Hs_Id
           WHERE     l.Atl_At = p_At_Id
                 AND l.Atl_St IN ('SW',
                                  'SN',
                                  'SA',
                                  'SD',
                                  'O.SA',
                                  'O.SD')
        ORDER BY s.Hs_Dt DESC
           FETCH FIRST ROW ONLY;

        RETURN l_Result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    FUNCTION Check_Act_Access (p_At_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Id      NUMBER;
        l_At_Cu      NUMBER;
        l_At_Sc      NUMBER;
        l_At_Rnspm   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;                          --301

        SELECT a.At_Cu, a.At_Rnspm, a.At_Sc
          INTO l_At_Cu, l_At_Rnspm, l_At_Sc
          FROM Act a
         WHERE a.At_Id = p_At_Id AND a.At_Tp = 'PDSP';

        --Дозволено доступ до акту, якщо його закріплено за поточним користувачем
        IF l_At_Cu = l_Cu_Id OR l_At_Sc = Ikis_Rbm.Tools.Getcusc (l_Cu_Id)
        THEN
            RETURN TRUE;
        END IF;

        --Дозволено доступ до акту, якщо поточний користувач має роль "Уповноважений спеціаліст" в кабінеті надавача за яким закріплено акт
        IF    Is_Role_Assigned (p_Cu_Id           => l_Cu_Id,
                                p_Cmes_Owner_Id   => l_At_Rnspm,
                                p_Role            => 'NSP_SPEC')
           OR Is_Role_Assigned (p_Cu_Id           => l_Cu_Id,
                                p_Cmes_Owner_Id   => l_At_Rnspm,
                                p_Role            => 'NSP_ADM')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        IF NOT Check_Act_Access (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;
    END;

    -----------------------------------------------------------
    --        ОТРИМАННЯ АТРИБУТІВ ДОКУМЕНТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Doc_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document  d
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A'
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A';
    END;

    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_At_Direction   VARCHAR2 (10);
    BEGIN
        SELECT Api$appeal.Get_Ap_Doc_Str (p_Ap_Id       => a.At_Ap,
                                          p_Nda_Class   => 'DIRECTION')
          INTO l_At_Direction
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Num,
                   a.At_Dt,
                   a.At_Src,
                   s.Dic_Name
                       AS At_Src_Name,
                   a.At_St,
                   St.Dic_Name
                       AS At_St_Name,
                   a.At_Pc,
                   a.At_Ap,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Ким затверджено рішення
                   Get_Approver_Pib (a.At_Id)
                       AS At_Approver_Pib,
                   --Отримувач
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   a.At_Sc
                       AS At_Sc,
                   --Код файлу друкованої форми
                   Get_Act_File (a.At_Id, 842)
                       AS At_Form_File,
                   --Кому буде направлено рішення на затверження
                   l_At_Direction
                       AS At_Direction,
                   (SELECT r.Dic_Name
                      FROM Uss_Ndi.v_Ddn_Ss_Rcp_Ap r
                     WHERE r.Dic_Value = l_At_Direction)
                       AS At_Direction_Name,
                   --Гранична величина
                    (  SELECT c.Aic_Limit
                         FROM At_Income_Calc c
                        WHERE c.Aic_At = a.At_Id
                     ORDER BY c.Aic_Dt DESC
                        FETCH FIRST ROW ONLY)
                       AS At_Income_Limit,
                   -- #95378  дата до статусу зміни стану рішення
                    (SELECT MAX (h.hs_dt)
                       FROM AT_log  L
                            JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
                      WHERE     atl_at = a.at_id
                            AND L.ATL_MESSAGE LIKE CHR (38) || '17')
                       AS At_St_dt,
                   -- #101695 Дата затвердження рішення
                    (SELECT MIN (h.hs_dt)
                       FROM AT_log  L
                            JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
                      WHERE     atl_at = a.at_id
                            AND L.ATL_MESSAGE LIKE CHR (38) || '17'
                            AND l.atl_st IN ('SA', 'SD'))
                       AS At_Approve_Dt,
                   a.At_Case_Class,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St ON a.At_St = St.Dic_Value
                   JOIN Opfu o ON a.At_Org = o.Org_Id
             WHERE a.At_Id = p_At_Id;
    END;

    --------------------------------------------------------------
    --           ОТРИМАННЯ ПОСЛУГ
    --------------------------------------------------------------
    PROCEDURE Get_Services (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*,
                   t.Nst_Name      AS Ats_Nst_Name,
                   m.Dic_Name      AS Ats_Ss_Method_Name,
                   At.Dic_Name     AS Ats_Ss_Address_Tp_Name,
                   St.Dic_Name     AS Ats_St_Name
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
                   JOIN Uss_Ndi.v_Ddn_Pdsp_Ats_St St
                       ON s.Ats_St = St.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Ss_Method m
                       ON s.Ats_Ss_Method = m.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Rnsp_Adr_Tp At
                       ON s.Ats_Ss_Address_Tp = At.Dic_Value
             WHERE s.Ats_At = p_At_Id AND S.History_Status = 'A';
    END;

    PROCEDURE Get_Reject_Info (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT i.*, r.Njr_Name AS Ari_Njr_Name
              FROM At_Reject_Info  i
                   JOIN Uss_Ndi.v_Ndi_Reject_Reason r ON i.Ari_Njr = r.Njr_Id
             WHERE i.Ari_At = p_At_Id;
    END;

    PROCEDURE Get_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM act  t
               JOIN v_ap_document zd ON (zd.apd_ap = t.at_ap)
               JOIN v_ap_document_attr a1
                   ON (    a1.apda_apd = zd.apd_id
                       AND a1.apda_nda IN (3688,
                                           3687,
                                           3261,
                                           3686))
               JOIN v_ap_document_attr a2
                   ON (    a2.apda_apd = zd.apd_id
                       AND a2.apda_nda IN (1872,
                                           3689,
                                           3263,
                                           3690))
         WHERE     at_id = p_At_Id
               AND zd.apd_ndt IN (801,
                                  802,
                                  835,
                                  836)
               AND a1.apda_val_string = 'G'
               AND a2.apda_val_id IS NOT NULL
               AND a1.history_status = 'A'
               AND a2.history_status = 'A';

        OPEN p_Res FOR
            SELECT *
              FROM (SELECT d.Atd_Id,
                           atd_ndt,
                           d.Atd_Doc                                        AS Doc_Id,
                           d.Atd_Dh                                         AS Dh_Id,
                           f.File_Code,
                           f.File_Name,
                           f.File_Mime_Type,
                           f.File_Size,
                           f.File_Hash,
                           f.File_Create_Dt,
                           f.File_Description,
                           s.File_Code                                      AS File_Sign_Code,
                           s.File_Hash                                      AS File_Sign_Hash,
                           (SELECT LISTAGG (Fs.File_Code, ',')
                                   WITHIN GROUP (ORDER BY
                                                     Ss.Dats_Id)
                              FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                                   JOIN Uss_Doc.v_Files Fs
                                       ON Ss.Dats_Sign_File =
                                          Fs.File_Id
                             WHERE Ss.Dats_Dat = a.Dat_Id)                  AS File_Signs,
                           a.Dat_Num,
                           MAX (a.dat_num) OVER (PARTITION BY d.Atd_Doc)    max_dat_num
                      FROM At_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Atd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                           LEFT JOIN Uss_Doc.v_Files s
                               ON a.Dat_Sign_File = s.File_Id
                     WHERE     d.Atd_At = p_At_Id
                           AND d.History_Status = 'A'
                           --#92377
                           AND EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND Sg.Ati_Is_Signed = 'T')
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND NVL (Sg.Ati_Is_Signed, 'F') =
                                               'F'))
             --#93366
             WHERE     (File_Signs IS NOT NULL OR File_Sign_Code IS NOT NULL)
                   --#109647
                   AND (l_cnt > 0 OR Dat_Num = max_dat_num);
    END;

    --------------------------------------------------------------
    --   Отримання картки рішення
    --------------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act              OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR,
                            p_Services         OUT SYS_REFCURSOR,
                            p_Reject_Info      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_PDSP.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => NULL);
        Api$Act.Check_At_Tp (p_At_Id, 'PDSP');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act);
        Api$act.Get_Documents (p_At_Id, p_Docs);
        Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
        Get_Doc_Files (p_At_Id, p_Docs_Files);
        Get_Services (p_At_Id, p_Services);
        Get_Reject_Info (p_At_Id, p_Reject_Info);
    END;

    --------------------------------------------------------------
    --   Визначення права
    --------------------------------------------------------------
    PROCEDURE Check_Right (p_At_Id          IN     NUMBER,
                           p_At_Right_Log      OUT SYS_REFCURSOR,
                           p_Messages          OUT SYS_REFCURSOR)
    IS
        l_ap_id            NUMBER;
        l_Is_need_income   NUMBER;
    BEGIN
        /* IF NOT Is_Role_Assigned(p_Cmes_Owner_Id => Get_At_Rnspm(p_At_Id), p_Role => 'NSP_SPEC') THEN
          Api$act.Raise_Unauthorized;
        END IF;*/

        IF Api$act.Get_At_St (p_At_Id) <> 'SR'
        THEN
            Raise_Application_Error (
                -20000,
                'Визначення права не можливо в поточному стані');
        END IF;

        SELECT at_ap
          INTO l_ap_id
          FROM act
         WHERE at_id = p_at_id;

        l_Is_need_income := API$APPEAL.GET_ISNEED_INCOME (L_AP_ID);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_PDSP.Check_Right',
            p_obj_tp   => 'APPEAL',
            p_obj_id   => l_ap_id,
            p_regular_params   =>
                   'p_At_Id='
                || p_At_Id
                || ', l_Is_need_income='
                || l_Is_need_income,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        --Розрахунок доходів
        IF l_Is_need_income > 0
        THEN
            Api$calc_Income.Calc_Income_For_At (p_Mode       => 1,
                                                p_At_Id      => p_At_Id,
                                                p_Messages   => p_Messages);

            --Приховуємо інформацію про доходи(в кабінеті не повинна відображатись)
            CLOSE p_Messages;
        ELSE
            API$Calc_Income.Cleat_At_Income_Calc (p_At_Id);
        END IF;

        --Визначення права
        Api$calc_Right_At.Init_Right_For_Act (p_Mode       => 1,
                                              p_At_Id      => p_At_Id,
                                              p_Messages   => p_Messages);

        OPEN p_At_Right_Log FOR
            SELECT l.*, r.Nrr_Name AS At_Nrr_Name
              FROM At_Right_Log  l
                   JOIN Uss_Ndi.v_Ndi_Right_Rule r ON l.Arl_Nrr = r.Nrr_Id
             WHERE l.Arl_At = p_At_Id;
    END;

    --------------------------------------------------------------
    --   Затвердження результатів визначення права
    --------------------------------------------------------------
    PROCEDURE Save_Right_Log (p_At_Id IN NUMBER, p_At_Right_Log IN CLOB)
    IS
        l_At_Right_Log   Api$act.t_At_Right_Log;
    BEGIN
        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => Get_At_Rnspm (p_At_Id),
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF p_At_Right_Log IS NULL
        THEN
            RETURN;
        END IF;

        l_At_Right_Log := Api$act.Parse_Right_Log (p_At_Right_Log);

        IF l_At_Right_Log.COUNT > 0
        THEN
            Api$act.Save_Right_Log (p_At_Id,
                                    l_At_Right_Log,
                                    Tools.Gethistsessioncmes);
        END IF;
    END;

    --------------------------------------------------------------
    --   Збереження причин відмови по послугам
    --------------------------------------------------------------
    PROCEDURE Save_Reject_Info (p_At_Id IN NUMBER, p_At_Reject_Info IN CLOB)
    IS
        l_At_Reject_Info   Api$act.t_At_Reject_Info;
    BEGIN
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF p_At_Reject_Info IS NULL
        THEN
            RETURN;
        END IF;

        l_At_Reject_Info := Api$act.Parse_Reject_Info (p_At_Reject_Info);

        IF l_At_Reject_Info.COUNT > 0
        THEN
            Api$act.Save_Reject_Info (p_At_Id, l_At_Reject_Info);
        END IF;
    END;

    --------------------------------------------------------------
    --   Отримання переліку типів документів доступних для
    -- додавання в залежності від поточного стану рішення
    --------------------------------------------------------------
    PROCEDURE Get_Doc_Types (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_At_St   VARCHAR2 (10);
        l_Ap_Id   NUMBER;
    BEGIN
        SELECT a.At_St, a.At_Ap
          INTO l_At_St, l_Ap_Id
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        OPEN p_Res FOR
            SELECT t.Ndt_Id             AS Id,
                   Ndt_Is_Have_Scan     AS Code,
                   t.Ndt_Name           AS NAME
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE     (   --Рішення
                           (l_At_St IN ('SR') AND t.Ndt_Id IN (842))
                        --Повідомлення
                        OR l_At_St IN ('SW', 'SN') AND t.Ndt_Id IN (843))
                   --#90152
                   AND EXISTS
                           (SELECT 1
                              FROM Appeal  a
                                   JOIN Ap_Document d
                                       ON     a.Ap_Id = d.Apd_Id
                                          AND d.History_Status = 'A'
                                          AND d.Apd_Ndt IN (801, 836)
                             WHERE a.Ap_Id = l_Ap_Id);
    END;

    -----------------------------------------------------------
    --         ФОРМУВАННЯ ДОКУМЕНТУ
    -----------------------------------------------------------
    PROCEDURE Init_Doc (p_At_Id       IN            NUMBER,
                        p_Ndt_Id      IN            NUMBER,
                        p_Attrs       IN OUT NOCOPY Api$act.t_At_Document_Attrs,
                        p_Doc_Cur        OUT        SYS_REFCURSOR,
                        p_Attrs_Cur      OUT        SYS_REFCURSOR)
    IS
        l_Cu_Id    NUMBER;
        l_Atd_Id   NUMBER;
        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        IF Api$appeal.Get_Ap_Doc_Str (
               p_Ap_Id       => Api$act.Get_At_Ap (p_At_Id),
               p_Nda_Class   => 'DIRECTION') =
           'SB'
        THEN
            Raise_Application_Error (
                -20000,
                'Рішення опрацьовується спеціалістами ОСЗН');
        END IF;

        Api$act.Can_Add_Doc (p_At_Id    => p_At_Id,
                             p_Ati_Tp   => 'PR',
                             p_Ndt_Id   => p_Ndt_Id);

        UPDATE At_Document d
           SET d.History_Status = 'H'
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Ndt_Id
               AND d.History_Status = 'A';

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => p_Ndt_Id,
                                             p_Doc_Actuality   => 'A',
                                             p_New_Id          => l_Doc_Id);
        Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                             p_Dh_Doc         => l_Doc_Id,
                                             p_Dh_Sign_Alg    => NULL,
                                             p_Dh_Ndt         => p_Ndt_Id,
                                             p_Dh_Sign_File   => NULL,
                                             p_Dh_Actuality   => 'A',
                                             p_Dh_Dt          => SYSDATE,
                                             p_Dh_Wu          => NULL,
                                             p_Dh_Src         => 'CMES',
                                             p_Dh_Cu          => l_Cu_Id,
                                             p_New_Id         => l_Dh_Id);


        INSERT INTO At_Document (Atd_Id,
                                 Atd_At,
                                 Atd_Ndt,
                                 Atd_Ats,
                                 Atd_Doc,
                                 Atd_Dh,
                                 History_Status)
             VALUES (0,
                     p_At_Id,
                     p_Ndt_Id,
                     NULL,
                     l_Doc_Id,
                     l_Dh_Id,
                     'A')
          RETURNING Atd_Id
               INTO l_Atd_Id;

        Api$act.Save_Attributes (p_At_Id    => p_At_Id,
                                 p_Atd_Id   => l_Atd_Id,
                                 p_Attrs    => p_Attrs);

        INSERT INTO At_Signers (Ati_Id,
                                Ati_At,
                                Ati_Atd,
                                Ati_Is_Signed,
                                History_Status,
                                Ati_Cu,
                                Ati_Tp)
             VALUES (0,
                     p_At_Id,
                     l_Atd_Id,
                     'F',
                     'A',
                     l_Cu_Id,
                     'PR');


        OPEN p_Doc_Cur FOR
            SELECT d.*
              FROM At_Document d
             WHERE d.Atd_Id = l_Atd_Id AND d.History_Status = 'A';

        Api$act.Get_Attributes (p_Atd_Id => l_Atd_Id, p_Res => p_Attrs_Cur);
    END;

    -----------------------------------------------------------
    --     ПОБУДОВА ДРУКОВАНОЇ ФОРМИ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Build_Doc_Form (p_At_Id     IN     NUMBER,
                              p_Ndt_Id    IN     NUMBER,
                              p_Doc_Cur      OUT SYS_REFCURSOR)
    IS
        l_File_Content     BLOB;
        l_Form_Make_Func   VARCHAR2 (1000);
    BEGIN
        Tools.LOG (
            p_Src      => 'Cmes$act_Pdsp.Build_Doc_Form',
            p_Obj_Tp   => '',
            p_Obj_Id   => '',
            p_Regular_Params   =>
                   'p_At_Id = '
                || p_At_Id
                || CHR (13)
                || CHR (10)
                || 'p_Ndt_Id = '
                || p_Ndt_Id
                || CHR (13)
                || CHR (10)
                || 'l_Cu_Id = '
                || Ikis_Rbm.Tools.Getcurrentcu);

        Check_Act_Access (p_At_Id);

        IF Api$appeal.Get_Ap_Doc_Str (
               p_Ap_Id       => Api$act.Get_At_Ap (p_At_Id),
               p_Nda_Class   => 'DIRECTION') =
           'SB'
        THEN
            Raise_Application_Error (
                -20000,
                'Рішення опрацьовується спеціалістами ОСЗН');
        END IF;

        SELECT c.Napc_Form_Make_Prc
          INTO l_Form_Make_Func
          FROM Uss_Ndi.v_Ndi_At_Print_Config c
         WHERE c.Napc_At_Tp = 'PDSP' AND c.Napc_Ndt = p_Ndt_Id;

        Tools.LOG (
            p_Src              => 'Cmes$act_Pdsp.Build_Doc_Form',
            p_Obj_Tp           => '',
            p_Obj_Id           => '',
            p_Regular_Params   => 'l_Form_Make_Func => ' || l_Form_Make_Func);

        EXECUTE IMMEDIATE   'select '
                         || l_Form_Make_Func
                         || '(:p_At_Id) from dual'
            INTO l_File_Content
            USING IN p_At_Id;

        OPEN p_Doc_Cur FOR
            SELECT d.Atd_Id,
                   d.Atd_Ndt,
                   d.Atd_Doc,
                   d.Atd_Dh,
                   l_File_Content     AS File_Content
              FROM At_Document d
             WHERE     d.Atd_At = p_At_Id
                   AND d.Atd_Ndt = p_Ndt_Id
                   AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --         ФОРМУВАННЯ ДОКУМЕНТУ РІШЕННЯ
    -----------------------------------------------------------
    PROCEDURE Init_Decision_Doc (p_At_Id       IN     NUMBER,
                                 p_Doc_Cur        OUT SYS_REFCURSOR,
                                 p_Attrs_Cur      OUT SYS_REFCURSOR)
    IS
        l_Attrs    Api$act.t_At_Document_Attrs;
        l_At       Act%ROWTYPE;
        l_App_Sc   NUMBER;
    BEGIN
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        SELECT a.*
          INTO l_At
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        SELECT p.App_Sc
          INTO l_App_Sc
          FROM Ap_Person p
         WHERE     p.App_Ap = l_At.At_Ap
               AND p.App_Tp = 'Z'
               AND p.History_Status = 'A';

        Api$act.Add_Attr (l_Attrs, 3640, p_Val_Str => l_At.At_Num);
        Api$act.Add_Attr (l_Attrs, 3642, p_Val_Dt => SYSDATE);
        Api$act.Add_Attr (
            l_Attrs,
            3643,
            p_Val_Str   =>
                Uss_Rnsp.Api$find.Get_Nsp_Name (p_Rnspm_Id => l_At.At_Rnspm));
        Api$act.Add_Attr (
            l_Attrs,
            3645,
            p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_App_Sc));
        Api$act.Add_Attr (
            l_Attrs,
            3648,
            p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_At.At_Sc));
        Api$act.Add_Attr (
            l_Attrs,
            3654,
            p_Val_Str   =>
                Ikis_Rbm.Tools.Getcupib (Ikis_Rbm.Tools.Getcurrentcu));


        Init_Doc (p_At_Id       => p_At_Id,
                  p_Ndt_Id      => 842,
                  p_Attrs       => l_Attrs,
                  p_Doc_Cur     => p_Doc_Cur,
                  p_Attrs_Cur   => p_Attrs_Cur);
    END;


    -----------------------------------------------------------
    --         ФОРМУВАННЯ ДОКУМЕНТУ ПОВІДОМЛЕННЯ
    -----------------------------------------------------------
    PROCEDURE Init_Msg_Doc (p_At_Id       IN     NUMBER,
                            p_Doc_Cur        OUT SYS_REFCURSOR,
                            p_Attrs_Cur      OUT SYS_REFCURSOR)
    IS
        l_Attrs        Api$act.t_At_Document_Attrs;
        l_At           Act%ROWTYPE;
        l_App_Sc       NUMBER;
        l_App_Sc_Os    NUMBER;
        l_Val_id       NUMBER;
        l_Val_Str      VARCHAR2 (500);
        l_Val_Str2     VARCHAR2 (4000);
        l_ss_need      VARCHAR2 (10);
        l_ss_provide   VARCHAR2 (10);
    BEGIN
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        SELECT a.*
          INTO l_at
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        SELECT MAX (a1.apda_val_string), MAX (a2.apda_val_string)
          INTO l_ss_need, l_ss_provide
          FROM Act  a
               JOIN ap_document_attr a1
                   ON (    a1.apda_ap = a.at_ap
                       AND a1.apda_nda = 1868
                       AND a1.history_status = 'A')
               JOIN ap_document_attr a2
                   ON (    a2.apda_ap = a.at_ap
                       AND a2.apda_nda = 1895
                       AND a2.history_status = 'A')
         WHERE a.At_Id = p_At_Id;

        Api$act.Add_Attr (l_Attrs, 3657, p_Val_Str => l_At.At_Num);
        Api$act.Add_Attr (l_Attrs, 3658, p_Val_Dt => SYSDATE);
        Api$act.Add_Attr (
            l_Attrs,
            3659,
            p_Val_Str   =>
                Uss_Rnsp.Api$find.Get_Nsp_Name (p_Rnspm_Id => l_At.At_Rnspm),
            p_Val_Id   => l_At.At_Rnspm);
        --Рябченко: не всегда есть участник с типом Z
        --Api$act.Add_Attr(l_Attrs, 3665, p_Val_Str => Uss_Person.Api$sc_Tools.Get_Pib(l_App_Sc), p_Val_Id => l_App_Sc);
        Api$act.Add_Attr (
            l_Attrs,
            3665,
            p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_at.at_sc),
            p_Val_Id    => l_at.at_sc);
        Api$act.Add_Attr (
            l_Attrs,
            3680,
            p_Val_Str   =>
                Ikis_Rbm.Tools.Getcupib (Ikis_Rbm.Tools.Getcurrentcu));

        -- #107731
        IF (l_ss_need = 'Z' AND l_ss_provide = 'Z')
        THEN
            SELECT p.App_Sc
              INTO l_App_Sc
              FROM Ap_Person p
             WHERE     p.App_Ap = l_At.At_Ap
                   AND p.App_Tp = 'Z'
                   AND p.History_Status = 'A';

            Api$act.Add_Attr (
                l_Attrs,
                3674,
                p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_App_Sc),
                p_Val_Id    => l_App_Sc);
        ELSIF (l_ss_need = 'Z' AND l_ss_provide IN ('B', 'CHRG'))
        THEN
            SELECT p.App_Sc
              INTO l_App_Sc_Os
              FROM Ap_Person p
             WHERE     p.App_Ap = l_At.At_Ap
                   AND p.App_Tp = 'OS'
                   AND p.History_Status = 'A';

            Api$act.Add_Attr (
                l_Attrs,
                3674,
                p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_App_Sc_Os),
                p_Val_Id    => l_App_Sc_Os);
        ELSIF (l_ss_need = 'FM' AND l_ss_provide = 'FM')
        THEN
            SELECT LISTAGG (Uss_Person.Api$sc_Tools.Get_Pib (p.atp_sc),
                            ', '
                            ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY 1)
              INTO l_Val_Str2
              FROM At_Person p
             WHERE p.atp_at = p_At_Id AND p.History_Status = 'A';

            Api$act.Add_Attr (l_Attrs, 3674, p_Val_Str => l_Val_Str2);
        ELSE
            Api$act.Add_Attr (
                l_Attrs,
                3674,
                p_Val_Str   => Uss_Person.Api$sc_Tools.Get_Pib (l_At.At_Sc),
                p_Val_Id    => l_At.At_Sc);
        END IF;

        --АДРЕСА--
        --КАТОТТГ
        Api$act.Add_Attr (
            l_Attrs,
            3668,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1618),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1618));
        --Індекс
        Api$act.Add_Attr (
            l_Attrs,
            3669,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1625),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1625));
        --вулиця
        l_Val_id := Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1632);
        l_Val_Str := Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1632);

        IF (l_Val_Str IS NULL)
        THEN
            l_Val_id := Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1640);
            l_Val_Str :=
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1640);
        END IF;

        Api$act.Add_Attr (l_Attrs,
                          3670,
                          p_Val_Id    => l_Val_id,
                          p_Val_Str   => l_Val_Str);
        --будинок
        Api$act.Add_Attr (
            l_Attrs,
            3671,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1648),
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1648));
        --корпус
        Api$act.Add_Attr (
            l_Attrs,
            3672,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1654),
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1654));
        --квартира
        Api$act.Add_Attr (
            l_Attrs,
            3673,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_At.At_Ap, 605, 1659),
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_At.At_Ap, 605, 1659));


        Init_Doc (p_At_Id       => p_At_Id,
                  p_Ndt_Id      => 843,
                  p_Attrs       => l_Attrs,
                  p_Doc_Cur     => p_Doc_Cur,
                  p_Attrs_Cur   => p_Attrs_Cur);
    END;

    -----------------------------------------------------------
    --     ПОБУДОВА ДРУКОВАНОЇ ФОРМИ ПОВІДОМЛЕННЯ
    -----------------------------------------------------------
    PROCEDURE Build_Msg_Form (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        Build_Doc_Form (p_At_Id     => p_At_Id,
                        p_Ndt_Id    => 843,
                        p_Doc_Cur   => p_Doc_Cur);
    END;

    -----------------------------------------------------------
    --     ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ РІШЕННЯ
    -----------------------------------------------------------
    PROCEDURE Save_Documents (p_At_Id IN NUMBER, p_At_Documents IN CLOB)
    IS
        l_At_Documents   Api$act.t_At_Documents;
    BEGIN
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF p_At_Documents IS NULL
        THEN
            RETURN;
        END IF;

        --Парсинг документів
        l_At_Documents := Api$act.Parse_Documents (p_At_Documents);

        IF l_At_Documents.COUNT > 0
        THEN
            FOR i IN 1 .. l_At_Documents.COUNT
            LOOP
                Api$act.Can_Add_Doc (p_At_Id    => p_At_Id,
                                     p_Ati_Tp   => 'PR',
                                     p_Ndt_Id   => l_At_Documents (i).Atd_Ndt);
            END LOOP;

            --Збереження документів
            Api$act.Save_Documents (p_At_Id, l_At_Documents);
        END IF;
    END;

    --------------------------------------------------------------
    --   Збереження відмітки про підписання документа
    --------------------------------------------------------------
    PROCEDURE Set_Doc_Signed (p_Atd_Id IN NUMBER)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        UPDATE At_Signers s
           SET s.Ati_Sign_Dt = SYSDATE, s.Ati_Is_Signed = 'T'
         WHERE     s.Ati_Atd = p_Atd_Id
               AND s.Ati_Cu = l_Cu_Id
               AND s.History_Status = 'A'
               AND s.Ati_Is_Signed = 'F';
    END;

    --------------------------------------------------------------
    --   Затвердження рішення
    --------------------------------------------------------------
    PROCEDURE Approve_Act (p_At_Id IN NUMBER)
    IS
    BEGIN
        Write_Audit ('Approve_Act');

        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => Get_At_Rnspm (p_At_Id),
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        --Встановлення наступного статусу рішення
        Api$act.Approve_Act (p_At_Id);
    END;

    --------------------------------------------------------------
    --   Відхилення рішення
    --------------------------------------------------------------
    PROCEDURE Regect_Act (p_At_Id IN NUMBER)
    IS
        l_At_St        VARCHAR2 (10);
        l_At_St_Name   VARCHAR2 (1000);
    BEGIN
        Write_Audit ('Regect_Act');

        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => Get_At_Rnspm (p_At_Id),
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        --Відхилення
        Api$act.Rejects_Act (p_At_Id     => p_At_Id,
                             p_St        => l_At_St,
                             p_St_Name   => l_At_St_Name);
    END;

    --------------------------------------------------------------
    --   Повернення рішення на доопрацювання
    --------------------------------------------------------------
    PROCEDURE Regect_Act_Rejet (p_At_Id IN NUMBER)
    IS
        l_At_St        VARCHAR2 (10);
        l_At_St_Name   VARCHAR2 (1000);
    BEGIN
        Write_Audit ('Regect_Act_Rejet');

        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => Get_At_Rnspm (p_At_Id),
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        --Відхилення
        Api$act.Reject_Act_Reject (p_At_Id     => p_At_Id,
                                   p_St        => l_At_St,
                                   p_St_Name   => l_At_St_Name);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');
        RETURN Cmes$act.Check_File_Access (p_File_Code   => p_File_Code,
                                           p_Cmes_Id     => p_Cmes_Id);
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ НА ЗРІЗ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER)
    IS
    BEGIN
        Write_Audit ('Set_Atd_Dh');
        Api$act.Set_Atd_Dh (p_Atd_Id, p_Atd_Dh);
    END;

    -----------------------------------------------------------
    --   Отримання кількості отримувачів яких супроводжує КМ
    --   #92403
    -----------------------------------------------------------
    PROCEDURE Get_Cm_Ss_Rec_Cnt (p_Cu_Id           IN     NUMBER,
                                 p_Cmes_Owner_Id   IN     NUMBER,
                                 p_Cnt                OUT NUMBER)
    IS
    BEGIN
        Write_Audit ('Get_Cm_Ss_Rec_Cnt');

        SELECT COUNT (DISTINCT a.At_Sc)
          INTO p_Cnt
          FROM Act a
         WHERE     a.At_Cu = p_Cu_Id
               AND a.At_Rnspm = p_Cmes_Owner_Id
               AND a.At_Tp = 'PDSP';
    END;

    -----------------------------------------------------------
    --   Отримання переліку отримувачів яких супроводжує КМ
    --   #92403
    -----------------------------------------------------------
    PROCEDURE Get_Cm_Ss_Rec (p_Cu_Id           IN     NUMBER,
                             p_Cmes_Owner_Id   IN     NUMBER,
                             p_Rec_Pib         IN     VARCHAR2,
                             p_Rec_Birth_Dt    IN     DATE,
                             p_Rec_Numident    IN     VARCHAR2,
                             p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Cm_Ss_Rec');

        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF NOT Is_Role_Assigned (p_Cu_Id           => p_Cu_Id,
                                 p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Role            => 'NSP_CM')
        THEN
            Raise_Application_Error (
                -20000,
                'Обраний кейс-менеджер не закріплений за поточним надавачем');
        END IF;

        OPEN p_Res FOR
            SELECT DISTINCT a.At_Sc          AS Rec_Sc,
                            i.Sci_Ln         AS Rec_Ln,
                            i.Sci_Fn         AS Rec_Fn,
                            i.Sci_Mn         AS Rec_Mn,
                            b.Scb_Dt         AS Rec_Birth_Dt,
                            d.Scd_Number     AS Rec_Numident
              FROM Act  a
                   JOIN Uss_Person.v_Socialcard c ON a.At_Sc = c.Sc_Id
                   JOIN Uss_Person.v_Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Uss_Person.v_Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
                   LEFT JOIN Uss_Person.v_Sc_Birth b ON Cc.Scc_Scb = b.Scb_Id
                   LEFT JOIN Uss_Person.v_Sc_Document d
                       ON     d.Scd_Sc = a.At_Sc
                          AND d.Scd_Ndt = 5
                          AND d.Scd_St = '1'
             WHERE     a.At_Cu = p_Cu_Id
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   AND a.At_Tp = 'PDSP'
                   AND (   p_Rec_Pib IS NULL
                        OR UPPER (
                               i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn) LIKE
                               UPPER (p_Rec_Pib) || '%')
                   AND (   p_Rec_Numident IS NULL
                        OR d.Scd_Number LIKE p_Rec_Numident || '%')
                   AND (p_Rec_Birth_Dt IS NULL OR b.Scb_Dt = p_Rec_Birth_Dt);
    END;

    -----------------------------------------------------------
    --             Заміна КМа для отримувачів
    --   #92403
    -----------------------------------------------------------
    PROCEDURE Change_Cm (p_Cu_Id_Old       IN NUMBER,
                         p_Cu_Id_New       IN NUMBER,
                         p_Cmes_Owner_Id   IN NUMBER,
                         p_Rec_List        IN CLOB)
    IS
        TYPE r_Act_Info IS RECORD
        (
            At_Id    NUMBER,
            At_St    VARCHAR2 (10)
        );

        TYPE t_At_List IS TABLE OF r_Act_Info;

        l_At_List   t_At_List;
        l_Hs_Id     NUMBER;
    BEGIN
        Write_Audit ('Change_Cm');

        IF NOT Is_Role_Assigned (p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Role            => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF NOT Is_Role_Assigned (p_Cu_Id           => p_Cu_Id_New,
                                 p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Role            => 'NSP_CM')
        THEN
            Raise_Application_Error (
                -20000,
                'Обраний кейс-менеджер не закріплений за поточним надавачем');
        END IF;

        IF p_Rec_List IS NOT NULL AND DBMS_LOB.Getlength (p_Rec_List) > 0
        THEN
            --Отримуємо перелік актів закріплених за КМом з врахуванням обраних отримувачів
            SELECT At_Id, At_St
              BULK COLLECT INTO l_At_List
              FROM Act a
             WHERE     a.At_Cu = p_Cu_Id_Old
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   AND a.At_Sc IN
                           (SELECT TO_NUMBER (COLUMN_VALUE)
                              FROM XMLTABLE (p_Rec_List));
        ELSE
            --Отримуємо перелік актів закріплених за КМом
            SELECT At_Id, At_St
              BULK COLLECT INTO l_At_List
              FROM Act a
             WHERE a.At_Cu = p_Cu_Id_Old AND a.At_Rnspm = p_Cmes_Owner_Id;
        END IF;

        FORALL i IN INDICES OF l_At_List
            UPDATE Act a
               SET a.At_Cu = p_Cu_Id_New
             WHERE a.At_Id = l_At_List (i).At_Id;

        l_Hs_Id := Tools.Gethistsessioncmes ();

        FORALL i IN INDICES OF l_At_List
            INSERT INTO At_Log (Atl_Id,
                                Atl_At,
                                Atl_Hs,
                                Atl_St,
                                Atl_Message,
                                Atl_St_Old,
                                Atl_Tp)
                     VALUES (
                                0,
                                l_At_List (i).At_Id,
                                l_Hs_Id,
                                l_At_List (i).At_St,
                                   CHR (38)
                                || '233#'
                                || Ikis_Rbm.Tools.Getcupib (p_Cu_Id_Old)
                                || '#'
                                || Ikis_Rbm.Tools.Getcupib (p_Cu_Id_New),
                                l_At_List (i).At_St,
                                'SYS');
    END;

    --=============================================================
    --Копирование документов из ЕСР в соцкарточку
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_at act.at_id%TYPE)
    IS
        l_Doc_Attrs    Uss_Person.Api$socialcard.t_Doc_Attrs;
        l_Scd_Id       NUMBER;
        l_new_Id       NUMBER;
        l_ap           APPEAL%ROWTYPE;
        l_attr_value   VARCHAR2 (10);
        l_App_Tp       VARCHAR2 (100);
        l_is_addr_eq   BOOLEAN;

        ------------------------------
        CURSOR adr (p_ap appeal.ap_id%TYPE, p_App_Tp VARCHAR2)
        IS
            SELECT App.App_Ap,
                   App.App_Id,
                   App.App_Sc,
                   App.App_Tp,
                   Apd.apd_id
                       AS apd_id,
                   --1 Адреса реєстрації
                   api$pc_decision.get_attr_id (apd.Apd_Id, 1488)
                       AS r_katottg, -- КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1611)
                       AS r_apartment,    -- Квартира адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1605)
                       AS r_corps,          -- Корпус адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1599)
                       AS r_House,         -- Будинок адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1490)
                       AS r_Strit_id, -- Вулиця адреси реєстрації (довідник) ID V_NDI_STREET
                   NULL
                       AS r_city,            -- Місто адреси реєстрації STRING
                   api$pc_decision.get_attr_id (apd.Apd_Id, 1489)
                       AS r_Index,   -- Індекс адреси реєстрації ID v_mf_index
                   NULL
                       AS r_District,        -- Район адреси реєстрації STRING
                   NULL
                       AS r_region,        -- Область адреси реєстрації STRING
                   NULL
                       AS r_country,        -- Країна адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1591)
                       AS r_Strit, -- Вулиця адреси реєстрації STRING V_NDI_STREET
                   NULL
                       AS r_Strit_tp,          -- Тип вулиці адреси реєстрації
                   --2 Адреса проживання
                   api$pc_decision.get_attr_id (apd.Apd_Id, 1618)
                       AS l_katottg, -- КАТОТТГ адреси проживання ID V_MF_KOATUU_TEST
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1659)
                       AS l_apartment,    -- Квартира адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1654)
                       AS l_corps,          -- Корпус адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1648)
                       AS l_House,         -- Будинок адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1632)
                       AS l_Strit_id, -- Вулиця адреси проживання (довідник) ID V_NDI_STREET
                   NULL
                       AS l_city,            -- Місто адреси проживання STRING
                   api$pc_decision.get_attr_id (apd.Apd_Id, 1625)
                       AS l_Index,   -- Індекс адреси проживання ID v_mf_index
                   NULL
                       AS l_District,        -- Район адреси проживання STRING
                   NULL
                       AS l_region,        -- Область адреси проживання STRING
                   NULL
                       AS l_country,        -- Країна адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1640)
                       AS l_Strit, -- Вулиця адреси проживання STRING V_NDI_STREET
                   NULL
                       AS l_Strit_tp,          -- Тип вулиці адреси проживання
                   api$pc_decision.get_attr_str (apd.Apd_Id, 1673)
                       AS phone,
                   api$pc_decision.get_attr_str (apd.Apd_Id, 3060)
                       AS email
              FROM Ap_Person  App
                   LEFT JOIN Ap_Document Apd
                       ON     Apd.Apd_App = App.App_Id
                          AND Apd.Apd_Ndt = 605
                          AND Apd.History_Status = 'A'
             WHERE     App.App_Ap = p_Ap
                   AND App.App_Tp IN
                           (SELECT COLUMN_VALUE
                              FROM TABLE (
                                       TOOLS.split_str (p_str     => p_App_Tp,
                                                        p_delim   => ',')))
                   AND App.History_Status = 'A'
                   AND App_Sc IS NOT NULL;

        ------------------------------
        CURSOR document (p_ap appeal.ap_id%TYPE, p_App_Tp VARCHAR2)
        IS
            SELECT *
              FROM (SELECT d.Apd_Id,
                           d.Apd_Doc,
                           d.Apd_Dh,
                           d.Apd_Ndt,
                           p.App_Sc,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY d.Apd_App,
                                                t.Ndt_Ndc,
                                                NVL (t.Ndt_Uniq_Group,
                                                     t.Ndt_Id)
                                   ORDER BY t.Ndt_Order)    AS Rn
                      FROM Uss_Esr.Ap_Document  d
                           JOIN Uss_Esr.Ap_Person p
                               ON     d.Apd_App = p.App_Id
                                  AND p.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Type t
                               ON     d.Apd_Ndt = t.Ndt_Id
                                  AND t.Ndt_Copy_Esr_Signed = 'T'
                     WHERE     d.Apd_Ap = p_Ap
                           AND p.App_Tp IN
                                   (SELECT COLUMN_VALUE
                                      FROM TABLE (
                                               TOOLS.split_str (
                                                   p_str     => p_App_Tp,
                                                   p_delim   => ',')))
                           AND t.ndt_ndc IN (2, 13)
                           AND EXISTS
                                   (SELECT 1
                                      FROM Uss_Esr.Ap_Document_Attr  apda
                                           JOIN
                                           Uss_Ndi.v_ndi_document_attr nda
                                               ON nda.nda_id = apda.apda_nda
                                     WHERE     apda.apda_apd = d.apd_id
                                           AND apda.apda_val_string
                                                   IS NOT NULL
                                           AND apda.history_status = 'A')
                           AND d.History_Status = 'A')
             WHERE Rn = 1;
    ------------------------------
    BEGIN
        --#112076
        SELECT *
          INTO l_ap
          FROM Appeal
         WHERE EXISTS
                   (SELECT 1
                      FROM Act
                     WHERE at_ap = ap_id AND at_id = p_at);

        l_attr_value :=
            Api$appeal.Get_Ap_Attr_Str (p_Ap_Id    => l_ap.ap_id,
                                        p_Nda_Id   => 1895);

        IF l_attr_value = 'Z'
        THEN
            l_App_Tp := 'Z';
        ELSIF l_attr_value = 'B'
        THEN
            l_App_Tp := 'Z,OS';
        ELSIF l_attr_value = 'FM'
        THEN
            l_App_Tp := 'Z,OS,FM';
        ELSIF l_attr_value = 'CHRG'
        THEN
            l_App_Tp := 'OR,OS';
        END IF;

        FOR rec IN adr (l_ap.ap_id, l_App_Tp)
        LOOP
            --3 2011  3 3 Місце реєстрації  Місце реєстрації  A 3
            --4 2011  2 2 Місце проживання  Місце проживання  A 2
            --106 1 UA Україна Україна A
            IF rec.apd_id IS NOT NULL
            THEN
                l_is_addr_eq :=
                        NVL (rec.r_katottg, -1) = NVL (rec.l_katottg, -2)
                    AND NVL (rec.r_apartment, '-1') =
                        NVL (rec.l_apartment, '-2')
                    AND NVL (rec.r_corps, '-1') = NVL (rec.l_corps, '-2')
                    AND NVL (rec.r_House, '-1') = NVL (rec.l_House, '-2')
                    AND NVL (rec.r_Index, '-1') = NVL (rec.l_Index, '-2')
                    AND NVL (NVL (rec.r_Strit_id, rec.r_Strit), '-1') =
                        NVL (NVL (rec.l_Strit_id, rec.r_Strit), '-2');

                IF    NVL (rec.r_katottg, -1) != -1
                   OR NVL (rec.r_apartment, '-1') != -1
                   OR NVL (rec.r_corps, '-1') != '-1'
                   OR NVL (rec.r_House, '-1') != '-1'
                   OR NVL (rec.r_Index, '-1') != '-1'
                   OR NVL (NVL (rec.r_Strit_id, rec.r_Strit), '-1') != '-1'
                THEN
                    Uss_Person.Api$socialcard.Save_Sc_Address (
                        p_Sca_Sc          => rec.app_sc,
                        p_Sca_Tp          => 3,
                        p_Sca_Kaot        => rec.r_katottg,
                        p_Sca_Nc          => 1,
                        p_Sca_Country     => NVL (rec.r_country, 'Україна'),
                        p_Sca_Region      => rec.r_region,
                        p_Sca_District    => rec.r_district,
                        p_Sca_Postcode    => rec.r_index,
                        p_Sca_City        => rec.r_city,
                        p_Sca_Street      => NVL (rec.r_strit_id, rec.r_strit),
                        p_Sca_Building    => rec.r_house,
                        p_Sca_Block       => rec.r_corps,
                        p_Sca_Apartment   => rec.r_apartment,
                        p_Sca_Note        => '',
                        p_Sca_Src         => '35',
                        p_Sca_Create_Dt   => SYSDATE,
                        o_Sca_Id          => l_new_Id);
                END IF;


                IF NOT l_is_addr_eq
                THEN
                    IF    NVL (rec.l_katottg, -1) != -1
                       OR NVL (rec.l_apartment, '-1') != -1
                       OR NVL (rec.l_corps, '-1') != '-1'
                       OR NVL (rec.l_House, '-1') != '-1'
                       OR NVL (rec.l_Index, '-1') != '-1'
                       OR NVL (NVL (rec.l_Strit_id, rec.l_Strit), '-1') !=
                          '-1'
                    THEN
                        Uss_Person.Api$socialcard.Save_Sc_Address (
                            p_Sca_Sc          => rec.app_sc,
                            p_Sca_Tp          => 2,
                            p_Sca_Kaot        => rec.l_katottg,
                            p_Sca_Nc          => 1,
                            p_Sca_Country     => NVL (rec.l_country, 'Україна'),
                            p_Sca_Region      => rec.l_region,
                            p_Sca_District    => rec.l_district,
                            p_Sca_Postcode    => rec.l_index,
                            p_Sca_City        => rec.l_city,
                            p_Sca_Street      =>
                                NVL (rec.l_strit_id, rec.l_strit),
                            p_Sca_Building    => rec.l_house,
                            p_Sca_Block       => rec.l_corps,
                            p_Sca_Apartment   => rec.l_apartment,
                            p_Sca_Note        => '',
                            p_Sca_Src         => '35',
                            p_Sca_Create_Dt   => SYSDATE,
                            o_Sca_Id          => l_new_Id);
                    END IF;
                END IF;
            END IF;

            IF rec.phone IS NOT NULL OR rec.email IS NOT NULL
            THEN
                Uss_Person.Api$socialcard.Save_Sc_Contact (
                    p_Scc_Sc          => rec.app_sc,
                    p_Sct_Phone_Mob   => rec.phone,
                    p_Sct_Email       => rec.email);
            END IF;
        END LOOP;

        FOR Rec IN document (l_ap.ap_id, l_App_Tp)
        LOOP
            SELECT a.Apda_Nda,
                   a.Apda_Val_String,
                   a.Apda_Val_Dt,
                   a.Apda_Val_Int,
                   a.Apda_Val_Id
              BULK COLLECT INTO l_Doc_Attrs
              FROM Uss_Esr.Ap_Document_Attr a
             WHERE a.Apda_Apd = rec.apd_id AND a.History_Status = 'A';

            Uss_Person.Api$socialcard.Save_Document (
                p_Sc_Id         => Rec.App_Sc,
                p_Ndt_Id        => Rec.Apd_Ndt,
                p_Doc_Attrs     => l_Doc_Attrs,
                p_Src_Id        => '37',
                p_Src_Code      => 'ESR',
                p_Scd_Note      =>
                    'Створено із звернення громадянина з системи ЄІССС: ЄСР',
                p_Scd_Id        => l_Scd_Id,
                p_Doc_Id        => Rec.Apd_Doc,
                p_Dh_Id         => Rec.Apd_Dh,
                p_Set_Feature   => TRUE                       --TODO: уточнить
                                       );

            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => Rec.App_Sc);
        END LOOP;
    END;
END Cmes$act_Pdsp;
/