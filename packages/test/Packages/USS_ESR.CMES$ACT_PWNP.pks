/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_PWNP
IS
    -- Author  : SHOSTAK
    -- Created : 14.09.2023 7:30:53 PM
    -- Purpose : Робота з попередження про припинення надання СП #91941


    Pkg   VARCHAR2 (50) := 'CMES$ACT_PWNP';

    TYPE r_Act IS RECORD
    (
        At_Pc              Act.At_Pc%TYPE,
        At_Dt              TIMESTAMP,
        At_Org             Act.At_Org%TYPE,
        At_Sc              Act.At_Sc%TYPE,
        At_Rnspm           Act.At_Rnspm%TYPE,
        At_Rnp             Act.At_Rnp%TYPE,
        At_Terminate_Dt    Act.At_Action_Stop_Dt%TYPE,
        At_Live_Address    Act.At_Live_Address%TYPE,
        At_Tctr            NUMBER
    );

    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Signers     IN     CLOB,
                        p_At_Documents   IN     CLOB DEFAULT NULL,
                        p_At_Attrs       IN     CLOB DEFAULT NULL);

    PROCEDURE Save_At_Message_Received (p_At_Id                 IN NUMBER,
                                        p_At_Message_Received   IN VARCHAR2);

    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Pwnp;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_PWNP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_PWNP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:23 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_PWNP
IS
    g_Nda_Map   Api$act.t_Nda_Map;

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;


    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act
    IS
        l_Result   r_Act;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act', TRUE)
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу акту: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------
    -- МАПІНГ ПОЛІВ АКТУ ЩО ЗБЕРІГАЮТЬСЯ В АТРИБУТИ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Map_Nda2act
    IS
    BEGIN
        IF g_Nda_Map.COUNT > 0
        THEN
            RETURN;
        END IF;

        g_Nda_Map (8314) := 'At_Head_Position';
        g_Nda_Map (8315) := 'At_Head_Fio';
        --#110438
        g_Nda_Map (8616) := 'At_Message_Received';
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Signers     IN     CLOB,
                        p_At_Documents   IN     CLOB DEFAULT NULL,
                        p_At_Attrs       IN     CLOB DEFAULT NULL)
    IS
        l_Cu_Id       NUMBER;
        l_At_Cu       NUMBER;
        l_At_St_Old   VARCHAR2 (10);
        l_Act         r_Act;
        l_Persons     Api$act.t_At_Persons;
        l_Signers     Api$act.t_At_Signers;
        l_Documents   Api$act.t_At_Documents;
        l_Atd_Id      NUMBER;
        l_Attrs       Api$act.t_At_Document_Attrs;
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        l_Act := Parse_Act (p_Act);

        IF     l_Act.At_Rnspm IS NOT NULL
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_CM')
        THEN
            Raise_Application_Error (-20000, 'Некоректно вакзано надавача');
        END IF;

        IF     l_Act.At_Tctr IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Tctr)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано договір по іншому надавачу');
        END IF;

        IF NVL (p_At_Id, -1) > 0
        THEN
            SELECT a.At_Cu, a.At_St
              INTO l_At_Cu, l_At_St_Old
              FROM Act a
             WHERE a.At_Id = p_At_Id;

            IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
            THEN
                Api$act.Raise_Unauthorized;
            END IF;

            IF NVL (l_At_St_Old, '-') <> 'EN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування повідомлення в поточному статусі заборонено');
            END IF;
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (p_At_Id               => p_At_Id,
                          p_At_Tp               => 'PWNP',
                          p_At_Pc               => l_Act.At_Pc,
                          p_At_Ap               => NULL,
                          p_At_Num              => NULL,
                          p_At_Dt               => l_Act.At_Dt,
                          p_At_Org              => l_Act.At_Org,
                          p_At_Sc               => l_Act.At_Sc,
                          p_At_Rnspm            => l_Act.At_Rnspm,
                          p_At_Rnp              => l_Act.At_Rnp,
                          p_At_Action_Stop_Dt   => l_Act.At_Terminate_Dt,
                          p_At_Live_Address     => l_Act.At_Live_Address,
                          p_At_St               => 'EN',
                          p_At_Src              => p_At_Src,
                          p_At_Main_Link_Tp     => 'TCTR',
                          p_At_Main_Link        => l_Act.At_Tctr,
                          p_At_Cu               => l_Cu_Id,
                          p_New_Id              => p_At_Id);

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);

        Map_Nda2act;
        l_Atd_Id :=
            Api$act.Get_Form_Doc (
                p_At_Id     => p_At_Id,
                p_Atd_Ndt   => Api$act.Define_Print_Form_Ndt (p_At_Id));
        Api$act.Save_Attributes (p_At_Id     => p_At_Id,
                                 p_Atd_Id    => l_Atd_Id,
                                 p_Attrs     => l_Attrs,
                                 p_Nda_Map   => g_Nda_Map);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'EN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    PROCEDURE Save_At_Message_Received (p_At_Id                 IN NUMBER,
                                        p_At_Message_Received   IN VARCHAR2)
    IS
        l_Atd_id   NUMBER;
    BEGIN
        --#110438
        IF p_At_Message_Received NOT IN ('T', 'F')
        THEN
            raise_application_error (
                -20000,
                'Value for parameter p_At_Message_Received must be T or F');
        END IF;

        Api$Act.Check_At_Tp (p_At_Id => p_At_Id, p_At_Tp => 'PWNP');

        BEGIN
            SELECT Atd_id
              INTO l_Atd_Id
              FROM At_Document
             WHERE     Atd_at = p_At_Id
                   AND atd_ndt = 863
                   AND History_status = 'A'
                   AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'No document with NDT_ID=863 added to act');
        END;



        Api$act.Modify_Attribute (
            p_Atda_Id           => NULL,
            p_Atda_At           => p_At_Id,
            p_Atda_Atd          => l_Atd_Id,
            p_Atda_Nda          => 8616,
            p_Atda_Val_Int      => NULL,
            p_Atda_Val_Sum      => NULL,
            p_Atda_Val_Id       => NULL,
            p_Atda_Val_Dt       => NULL,
            p_Atda_Val_String   => p_At_Message_Received);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано форму ведення випадку
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   Api$act.Get_Signer_Position (a.At_Id, 'PR')
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   a.At_Main_Link
                       AS At_Tctr,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   --#110438
                   Api$act.Get_Attr_Val_Field (a.At_Id,
                                               'At_Message_Received',
                                               g_Nda_Map)
                       AS At_Message_Received,
                   api$act.Get_Signer_Dt (a.at_id, 'PR')
                       AS ATI_SIGN_DT,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Pwnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ЗА ДОГОВОРОМ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Tctr');

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND (   Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_SPEC')
                OR Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_CM'))
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     1 = 1
                       AND a.At_Main_Link = p_Tctr_Id
                       AND a.At_Tp = 'PWNP'
                       AND a.At_Rnspm = p_Cmes_Owner_Id
                       AND a.At_St <> 'ED';
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     1 = 1
                       AND a.At_Main_Link = p_Tctr_Id
                       AND a.At_Tp = 'PWNP'
                       AND a.At_St = 'EP'
                       AND a.At_St <> 'ED'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM At_Person p
                                     WHERE     p.Atp_At = a.At_Id
                                           AND p.Atp_Sc = l_Sc_Id
                                           AND p.History_Status = 'A'
                                           AND p.Atp_App_Tp IN ('Z')));
        END IF;

        Get_Act_List (p_Acts);
    END;

    -----------------------------------------------------------
    --          ОТРИМАННЯ ОСНОВНИХ ДАНИХ ПОВІДОМЛЕННЯ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано форму ведення випадку
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   NVL (Api$act.Get_Signer_Position (a.At_Id, 'PR'),
                        api$act.Get_Attr_Val_Str (a.at_id, 8314))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   a.At_Main_Link
                       AS At_Tctr,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   a.at_Pc,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Head_Position',
                                               g_Nda_Map)
                       At_Head_Position,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Head_Fio',
                                               g_Nda_Map)
                       At_Head_Fio,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   --#110438
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Message_Received',
                                               g_Nda_Map)
                       AS At_Message_Received,
                   api$act.Get_Signer_Dt (a.at_id, 'PR')
                       AS Ati_Sign_Dt
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Pwnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
             WHERE a.At_Id = p_At_Id;
    END;


    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Api
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'PWNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Documents (p_At_Id, p_Docs);
        Api$act.Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
        Api$Act.Get_Signed_Doc_Files (p_At_Id, p_Docs_Files);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Portal
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'PWNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id       => p_At_Id,
            p_Form_Ndt    => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Atd_Dh      => p_Atd_Dh,
            p_File_Code   => p_File_Code);
    END;

    ---------------------------------------------------------------
    --             ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --      (вже побудованої, з кодами підписів через кому)
    ---------------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id                  => p_At_Id,
            p_Form_Ndt               => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
        l_Ndt_Id       NUMBER;
        l_Build_Proc   VARCHAR2 (1000);
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        l_Ndt_Id := Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);
        Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                               p_At_Prj_St         => 'EN',
                               p_Form_Ndt          => l_Ndt_Id,
                               p_Form_Build_Proc   => l_Build_Proc,
                               p_Doc_Cur           => p_Doc_Cur);
    END;


    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Form_Doc');
        Api$act.Get_Form_Doc (
            p_At_Id     => p_At_Id,
            p_Atd_Ndt   => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- "ВІДПРАВКА" ПОВІДОМЛЕННЯ НАДАВАЧУ НА ПІДПИМ
    -----------------------------------------------------------
    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Send_To_Pr');
        Check_Act_Access (p_At_Id);

        --Виконуємо зміну статуса лише у разі, якщо проект акту пройшов всі контролі
        IF Api$act_Validation.Validate_Act (p_At_Id, p_Messages)
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'EN',
                p_At_St_New   => 'EV',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Відправка повідомлення надавачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id => p_At_Id, p_file_code => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'EV',
            p_At_St_New   => 'EP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Очікує підписання"');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Canceled');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину скасування');
        END IF;

        Cmes$act.Check_Act_Access_Cm (p_At_Id);

        Api$act.Set_At_St (
            p_At_Id          => p_At_Id,
            p_At_St_Old      => 'EN',
            p_At_St_New      => 'ED',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_At_St   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Declined');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину відхилення');
        END IF;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_At_St := Api$act.Get_At_St (p_At_Id);


        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Відхилення може виконувати лише надавач соц. послуг');
        END IF;

        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'EV',
            p_At_St_New   => 'ER',
            p_Log_Msg     => CHR (38) || '231#' || p_Reason,
            p_Wrong_St_Msg   =>
                'Відхилити можливо лише в стані "Очікує підписання"');
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
END Cmes$act_Pwnp;
/