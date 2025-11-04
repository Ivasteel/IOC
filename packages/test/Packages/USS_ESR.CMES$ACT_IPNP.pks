/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_IPNP
IS
    -- Author  : SHOSTAK
    -- Created : 18.09.2023 2:40:56 PM
    -- Purpose : Робота з наказами про припинення надання СП 91893

    Pkg                        VARCHAR2 (50) := 'CMES$ACT_IPNP';

    c_Ipnp_Form_Ndt   CONSTANT NUMBER := 861;
    с_Order_Ndt      CONSTANT NUMBER := 864;

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
        At_Tctr            NUMBER,
        At_Rstopss         NUMBER
    );

    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        p_At_Attrs       IN     CLOB,
                        p_At_Signers     IN     CLOB);

    FUNCTION Get_Attr_Val_String (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR,
                                p_Attrs              OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Pers_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR);

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

    PROCEDURE Set_Signed_Pr (p_Atd_Id         NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Ipnp;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_IPNP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_IPNP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_IPNP
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
                   'Помилка парсингу договору: '
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

        g_Nda_Map (3071) := 'At_Order_Doc_Name';
        g_Nda_Map (3073) := 'At_Order_Doc_Num';
        g_Nda_Map (3072) := 'At_Order_Doc_Dt';
        g_Nda_Map (3077) := 'At_Rnp_Info';
    END;

    -----------------------------------------------------------
    --        ОТРИМАННЯ ІД ДОКУМЕНТА
    -----------------------------------------------------------
    FUNCTION Get_Form_Doc (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Cu_Id    NUMBER;
        l_Atd_Id   NUMBER;
        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT MAX (d.Atd_Id)
          INTO l_Atd_Id
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = c_Ipnp_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => c_Ipnp_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => l_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => c_Ipnp_Form_Ndt,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   => 'U',
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => NULL,
            p_Dh_Src         => 'CMES',
            p_Dh_Cu          => l_Cu_Id,
            p_New_Id         => l_Dh_Id);

        INSERT INTO At_Document (Atd_Id,
                                 Atd_At,
                                 Atd_Ndt,
                                 Atd_Doc,
                                 Atd_Dh,
                                 History_Status)
             VALUES (0,
                     p_At_Id,
                     c_Ipnp_Form_Ndt,
                     l_Doc_Id,
                     l_Dh_Id,
                     'A')
          RETURNING Atd_Id
               INTO l_Atd_Id;

        RETURN l_Atd_Id;
    END;

    PROCEDURE Save_Services (p_At_Id NUMBER, p_Tctr_Id NUMBER)
    IS
    BEGIN
        --Видаляємо послуги яких немає в договорі
        UPDATE At_Service s
           SET s.History_Status = 'H'
         WHERE     s.Ats_At = p_At_Id
               AND s.History_Status = 'A'
               AND NOT EXISTS
                       (SELECT 1
                          FROM At_Service St
                         WHERE     St.Ats_At = p_Tctr_Id
                               AND St.Ats_Nst = s.Ats_Nst
                               AND st.history_status = 'A');

        INSERT INTO At_Service (Ats_Id,
                                Ats_At,
                                Ats_Nst,
                                History_Status)
            SELECT 0,
                   p_At_Id,
                   s.Ats_Nst,
                   'A'
              FROM At_Service  s
                   JOIN act t ON (t.at_id = s.ats_at)                  -- tctr
                   JOIN act p ON (p.at_id = t.at_main_link)             --pdsp
                   JOIN at_service sp
                       ON (sp.ats_at = p.at_id AND s.ats_nst = sp.ats_nst)
             WHERE     s.Ats_At = p_Tctr_Id
                   AND s.History_Status = 'A'
                   AND sp.History_Status = 'A'
                   --AND s.Ats_St NOT IN ('SU', 'ST')
                   AND sp.Ats_St IN ('SG') -- статуси змінюються лише в ПДСП. в договорі ні.
                   AND NOT EXISTS
                           (SELECT 1
                              FROM At_Service St
                             WHERE     St.Ats_At = p_At_Id
                                   AND St.Ats_Nst = s.Ats_Nst
                                   AND st.history_status = 'A');
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        p_At_Attrs       IN     CLOB,
                        p_At_Signers     IN     CLOB)
    IS
        l_Cu_Id         NUMBER;
        l_At_Cu         NUMBER;
        l_cnt           NUMBER;
        l_At_St_Old     VARCHAR2 (10);
        l_Act           r_Act;
        l_Persons       Api$act.t_At_Persons;
        l_Signers       Api$act.t_At_Signers;
        l_Documents     Api$act.t_At_Documents;
        l_Atd_Id        NUMBER;
        l_Attrs         Api$act.t_At_Document_Attrs;
        l_Max_Pwnp_Dt   DATE;
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

            IF NVL (l_At_St_Old, '-') <> 'NN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування повідомлення в поточному статусі заборонено');
            END IF;
        END IF;

        IF (l_Act.At_Rstopss IS NOT NULL)
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM Act a
             WHERE     a.At_Tp = 'IPNP'
                   AND a.at_main_link = l_Act.At_Rstopss
                   AND a.At_St NOT IN ('ND', 'NR')
                   AND a.At_Id <> NVL (p_At_Id, -1);

            IF l_cnt > 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'По цьому випадку вже існує акт про припинення надання СП');
            END IF;
        END IF;

        --#112387
        IF l_Act.At_Rnp = 398
        THEN
            SELECT COUNT (1), NVL (MAX (hs_dt), SYSDATE)
              INTO l_cnt, l_Max_Pwnp_Dt
              FROM act
                   JOIN at_log ON at_id = atl_at AND atl_st = 'EP'
                   JOIN histsession ON atl_hs = hs_id
             WHERE     at_tp = 'PWNP'
                   AND at_main_link = l_Act.At_Tctr
                   AND at_main_link_tp = 'TCTR';

            IF l_cnt = 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не існую жодного документу "Повідомлення про рішення припинити надання соціальних послуг" в статусі "Підписано НСП"');
            END IF;

            IF l_cnt = 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не існую жодного документу "Повідомлення про рішення припинити надання соціальних послуг" в статусі "Підписано НСП"');
            END IF;

            --Тимчасово стоіть 1. треба - 15
            IF TRUNC (SYSDATE) - TRUNC (l_Max_Pwnp_Dt) < 1
            THEN
                Raise_Application_Error (
                    -20000,
                    'З часу підписання останнього документу "Повідомлення про рішення припинити надання соціальних послуг" ще не минуло 15 днів');
            END IF;
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        --#100266 Перевірка наявності посилання на файли в архиві
        FOR i IN 1 .. l_Documents.COUNT
        LOOP
            IF l_Documents (i).atd_doc IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Для документу кодом '
                    || l_Documents (i).atd_ndt
                    || ' не вказано посилання на файл в архіві');
            END IF;

            IF l_Documents (i).atd_dh IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Для документу кодом '
                    || l_Documents (i).atd_ndt
                    || ' не вказано посилання версію історії файлу в архіві');
            END IF;
        END LOOP;

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'IPNP',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Ap               =>
                CASE
                    WHEN l_Act.At_Rstopss IS NOT NULL
                    THEN
                        Uss_Esr.Api$act.Get_At_Ap (l_Act.At_Rstopss)
                END,
            p_At_Num              => NULL,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Rnp              => l_Act.At_Rnp,
            p_At_Action_Stop_Dt   => l_Act.At_Terminate_Dt,
            p_At_Live_Address     => l_Act.At_Live_Address,
            p_At_Notes            => NULL,
            p_At_St               => 'NN',
            p_At_Src              => p_At_Src,
            p_At_Main_Link_Tp     => 'RSTOPSS',
            p_At_Main_Link        => l_Act.At_Rstopss,
            p_At_Cu               => l_Cu_Id,
            p_New_Id              => p_At_Id);

        Api$act.Save_Link (p_Atk_At        => p_At_Id,
                           p_Atk_Link_At   => l_Act.At_Tctr,
                           p_Atk_Tp        => 'TCTR');

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);
        Api$act.Save_Signers (p_At_Id       => p_At_Id,
                              p_Signers     => l_Signers,
                              p_Persons     => l_Persons,
                              p_Documents   => l_Documents);

        --Map_Nda2act;
        --l_Atd_Id := Get_Form_Doc(p_At_Id);
        --Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);

        Save_Services (p_At_Id => p_At_Id, p_Tctr_Id => l_Act.At_Tctr);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'NN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
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
                   Api$act.Get_Signer_Position (a.At_Id, 'PR')
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   Tt.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   Tt.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   Tt.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   --Рішення про припинення
                   a.At_Main_Link
                       AS At_Rstopss,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   -- Номер розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Str (p_ap_id    => a.at_ap,
                                                   p_Nda_Id   => 4289)
                       AS act_num_r,
                   -- Дата розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Dt (p_ap_id    => a.at_ap,
                                                  p_Nda_Id   => 4290)
                       AS act_dt_r
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Ipnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act Tt ON l.Atk_Link_At = Tt.At_Id;
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Map_Nda2act;
        --Api$act.Get_Attributes(p_At_Id => p_At_Id, p_Atd_Ndt => c_Ipnp_Form_Ndt, p_Nda_Map => g_Nda_Map, p_Res => p_Res);

        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document_Attr  a
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE a.Atda_At = p_At_Id AND a.History_Status = 'A';
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => c_Ipnp_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ЗА ДОГОВОРОМ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR,
                                p_Attrs              OUT SYS_REFCURSOR)
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
                  FROM At_Links  l
                       JOIN Act a
                           ON     l.Atk_At = a.At_Id
                              AND a.At_Tp = 'IPNP'
                              AND a.At_Rnspm = p_Cmes_Owner_Id
                 WHERE     l.Atk_Link_At = p_Tctr_Id
                       AND l.Atk_Tp = 'TCTR'
                       AND a.At_St <> 'ND';
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM At_Links  l
                       JOIN Act a ON l.Atk_At = a.At_Id AND a.At_Tp = 'IPNP'
                 WHERE     l.Atk_Link_At = p_Tctr_Id
                       AND l.Atk_Tp = 'TCTR'
                       AND a.At_St = 'NP'
                       AND a.At_St <> 'ND'
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
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
    --   ОТРИМАННЯ ПІБ законного представника / уповноваженої особи ОСП
    -----------------------------------------------------------
    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
        SELECT MAX (Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc))
          INTO l_Result
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.App_Tp = 'Z'
               AND NOT EXISTS
                       (SELECT 1
                          FROM Ap_Person Pp
                         WHERE     Pp.App_Ap = p_Ap_Id
                               AND Pp.History_Status = 'A'
                               AND Pp.App_Tp = 'OS');

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_String (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR (4000);
    BEGIN
        SELECT MAX (a.atda_val_string)
          INTO l_res
          FROM At_Document_Attr a
         WHERE     a.Atda_At = p_At_Id
               AND a.atda_nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_res;
    END;

    -----------------------------------------------------------
    --   ОТРИМАННЯ ОСНОВНИХ ДАНИХ ІНФОРМИЦІЇ ПРО ПРИПРИНЕННЯ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
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
                   NVL (Get_Attr_Val_String (a.at_id, 8312),
                        Api$act.Get_Signer_Position (a.At_Id, 'PR'))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   t.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   t.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   t.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   --Рішення про припинення
                   a.At_Main_Link
                       AS At_Rstopss,
                   Get_Attr_Val_String (a.at_id, 3077)
                       AS At_Rnp_Info,
                   Get_Attr_Val_String (a.at_id, 3071)
                       AS at_Order_Doc_Name,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   -- Номер розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Str (p_ap_id    => a.at_ap,
                                                   p_Nda_Id   => 4289)
                       AS act_num_r,
                   -- Дата розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Dt (p_ap_id    => a.at_ap,
                                                  p_Nda_Id   => 4290)
                       AS act_dt_r
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Ipnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act t ON l.Atk_Link_At = t.At_Id
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Pers_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        --Check_Act_Access(p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'IPNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Docs_Files_Cur);
        --Get_Attributes(p_At_Id, p_Attrs_Cur);
        Get_Attributes (p_At_Id => p_At_Id, p_Res => p_Attrs_Cur);
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
    --              ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --        (вже побудованої, з кодами підписів через кому)
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

        IF (l_ndt_Id IN (864))
        THEN
            Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => l_Ndt_Id,
                                  p_Doc       => p_Doc_Cur);
        ELSE
            Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                                   p_At_Prj_St         => 'NN',
                                   p_Form_Ndt          => l_Ndt_Id,
                                   p_Form_Build_Proc   => l_Build_Proc,
                                   p_Doc_Cur           => p_Doc_Cur);
        END IF;
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
    -- "ВІДПРАВКА" АКТУ НАДАВАЧУ НА ПІДПИС
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
                p_At_St_Old   => 'NN',
                p_At_St_New   => 'NV',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Відправка інформації надавачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- СТВОРЕННЯ ТЕХНОЛОГІЧНОГО ЗВЕРНЕННЯ R.GS
    -- (реалізовано за рекомендацією О.Комісарова
    --  для уніфікації опрацювання рішення)
    -----------------------------------------------------------
    PROCEDURE Create_Appeal (p_At_Id IN NUMBER, p_Ap_Id OUT NUMBER)
    IS
        l_Act        Act%ROWTYPE;
        l_Tctr_Id    NUMBER;
        l_Tctr_Num   Act.At_Num%TYPE;
        l_Apd_Id     NUMBER;
        l_Atts       Api$act.t_At_Document_Attrs;
        l_Atd_Ndt    NUMBER;
        l_Atd_id     NUMBER;
    BEGIN
        SELECT *
          INTO l_Act
          FROM Act
         WHERE At_Id = p_At_Id;

        IF l_Act.At_Pc IS NULL
        THEN
            SELECT c.Pc_Id
              INTO l_Act.At_Pc
              FROM Personalcase c
             WHERE c.Pc_Sc = l_Act.At_Sc AND c.Pc_St IN ('R', 'E', 'P');
        END IF;

        INSERT INTO Appeal (Ap_Id,
                            Ap_Pc,
                            Ap_Tp,
                            Ap_Reg_Dt,
                            Ap_Src,
                            Ap_St,
                            Com_Org,
                            Ap_Is_Second,
                            Com_Wu,
                            Ap_Num,
                            Ap_Is_Ext_Process,
                            Ap_Create_Dt,
                            Ap_Dest_Org,
                            Ap_Cu)
             VALUES (0,
                     l_Act.At_Pc,
                     'R.GS',
                     SYSDATE,
                     'CMES',
                     'O',
                     l_Act.At_Org,
                     'F',
                     l_Act.At_Wu,
                     l_Act.At_Id,
                     'F',
                     SYSDATE,
                     l_Act.At_Org,
                     l_Act.At_Cu)
          RETURNING Ap_Id
               INTO p_Ap_Id;

        SELECT l.Atk_Link_At, a.At_Num
          INTO l_Tctr_Id, l_Tctr_Num
          FROM At_Links l JOIN Act a ON l.Atk_Link_At = a.At_Id
         WHERE l.Atk_At = p_At_Id AND l.Atk_Tp = 'TCTR';

        INSERT INTO Ap_Service (Aps_Id,
                                Aps_Ap,
                                Aps_St,
                                History_Status,
                                Aps_Nst)
            --todo: уточнити щодо статусу послуги
            SELECT 0,
                   p_Ap_Id,
                   'N',
                   'A',
                   s.Ats_Nst
              FROM At_Service s
             WHERE s.Ats_At = l_Tctr_Id-- AND s.Ats_St IN ('SG', 'SU')
                                       ;

        INSERT INTO Ap_Person (App_Id,
                               App_Ap,
                               App_Sc,
                               App_Tp,
                               History_Status,
                               App_Scc)
            SELECT 0,
                   p_Ap_Id,
                   p.Atp_Sc,
                   p.Atp_App_Tp,
                   'A',
                   c.Sc_Scc
              FROM At_Person  p
                   JOIN Uss_Person.v_Socialcard c ON p.Atp_Sc = c.Sc_Id
             WHERE p.Atp_At = p_At_Id;

        BEGIN
            --#110881
            SELECT d.atd_id, d.atd_ndt
              INTO l_Atd_id, l_Atd_Ndt
              FROM At_Document d
             WHERE     d.Atd_At = p_At_Id
                   AND d.History_Status = 'A'
                   AND d.Atd_Ndt IN (c_Ipnp_Form_Ndt, с_Order_Ndt);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Raise_Application_Error (
                    -20000,
                       'В акті з ІД ['
                    || p_At_Id
                    || '] не знайдено жодного документу з кодами ['
                    || c_Ipnp_Form_Ndt
                    || ', '
                    || с_Order_Ndt
                    || ']');
            WHEN TOO_MANY_ROWS
            THEN
                Raise_Application_Error (
                    -20000,
                       'В акті з ІД ['
                    || p_At_Id
                    || '] може бути тільки один документ з кодами з переліку ['
                    || c_Ipnp_Form_Ndt
                    || ', '
                    || с_Order_Ndt
                    || ']');
        END;

        DBMS_OUTPUT.put_line (l_Atd_Ndt);

        INSERT INTO Ap_Document (Apd_Id,
                                 Apd_Ap,
                                 Apd_App,
                                 Apd_Ndt,
                                 Apd_Doc,
                                 Apd_Dh,
                                 History_Status)
            SELECT 0,
                   p_Ap_Id,
                   (SELECT p.App_Id
                      FROM Ap_Person p
                     WHERE p.App_Ap = p_Ap_Id AND p.App_Tp = 'Z'),
                   d.Atd_Ndt,
                   d.Atd_Doc,
                   d.Atd_Dh,
                   'A'
              FROM At_Document d
             WHERE d.atd_id = l_Atd_id;

        SELECT d.Apd_Id
          INTO l_Apd_Id
          FROM Ap_Document d
         WHERE d.Apd_Ap = p_Ap_Id AND d.Apd_Ndt = l_Atd_Ndt;

        IF l_Atd_Ndt = c_Ipnp_Form_Ndt
        THEN
            SELECT a.Atda_Nda,
                   a.Atda_Val_Int,
                   a.Atda_Val_Sum,
                   a.Atda_Val_Id,
                   a.Atda_Val_Dt,
                   a.Atda_Val_String,
                   NULL,
                   NULL
              BULK COLLECT INTO l_Atts
              FROM At_Document  d
                   JOIN At_Document_Attr a ON d.Atd_Id = a.Atda_Atd
             WHERE     d.Atd_At = p_At_Id
                   AND d.Atd_Ndt = l_Atd_Ndt
                   AND d.History_Status = 'A'
                   AND a.Atda_Nda IN (3072,                         /*3068, */
                                      3071,
                                      3077,
                                      8312,
                                      8313);

            Api$act.Add_Attr (l_Atts, 3074, p_Val_Str => l_Tctr_Num);
            Api$act.Add_Attr (
                l_Atts,
                3068,
                p_Val_Id    => l_Act.At_Rnspm,
                p_Val_Str   => Uss_Rnsp.Api$find.Get_Nsp_Name (l_Act.At_Rnspm));
            Api$act.Add_Attr (l_Atts, 3076, p_Val_Id => l_Act.At_Rnp);
        --Api$act.Add_Attr(l_Atts, 3078, p_Val_Dt => l_Act.At_Action_Stop_Dt);
        ELSIF l_Atd_Ndt = с_Order_Ndt
        THEN
            SELECT a.Atda_Nda,
                   a.Atda_Val_Int,
                   a.Atda_Val_Sum,
                   a.Atda_Val_Id,
                   a.Atda_Val_Dt,
                   a.Atda_Val_String,
                   NULL,
                   NULL
              BULK COLLECT INTO l_Atts
              FROM At_Document  d
                   JOIN At_Document_Attr a ON d.Atd_Id = a.Atda_Atd
             WHERE     d.Atd_At = p_At_Id
                   AND d.Atd_Ndt = l_Atd_Ndt
                   AND d.History_Status = 'A'
                   AND a.Atda_Nda IN (4288,
                                      4289,
                                      4290,
                                      4291,
                                      3314,
                                      3318);
        END IF;

        FOR xx IN (SELECT * FROM TABLE (l_Atts))
        LOOP
            INSERT INTO Ap_Document_Attr (Apda_Id,
                                          Apda_Ap,
                                          Apda_Apd,
                                          Apda_Nda,
                                          Apda_Val_Int,
                                          Apda_Val_Sum,
                                          Apda_Val_Id,
                                          Apda_Val_Dt,
                                          Apda_Val_String,
                                          History_Status)
                 VALUES (0,
                         p_Ap_Id,
                         l_Apd_Id,
                         xx.Atda_Nda,
                         xx.Atda_Val_Int,
                         xx.Atda_Val_Sum,
                         xx.Atda_Val_Id,
                         xx.Atda_Val_Dt,
                         xx.Atda_Val_String,
                         'A');
        END LOOP;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_Atd_Id         NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_At_Id        NUMBER;
        l_At_By_Ap     NUMBER;
        l_At_Rstopss   NUMBER;
        l_Ap_Id        NUMBER;
        l_Mes          SYS_REFCURSOR;
        l_cnt          NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        l_At_Id := Api$act.Get_Atd_At (p_Atd_Id);
        Cmes$act.Set_Signed_Pr (p_At_Id       => l_At_Id,
                                p_Atd_Id      => p_Atd_Id,
                                p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => l_At_Id, p_Ati_Tp => 'PR')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => l_At_Id,
                p_At_St_Old   => 'NV',
                p_At_St_New   => 'NP',
                p_Log_Msg     => CHR (38) || '253',
                p_Wrong_St_Msg   =>
                    'Затвердження надавачем можливо лише в стані "Очікує підписання"');

            SELECT COUNT (*)
              INTO l_cnt
              FROM act t
             WHERE t.at_id = l_At_Id AND t.at_rnp IN (399, 400);

            IF Api$act.Get_At_Ap (l_At_Id) IS NULL
            THEN
                --Створюємо звернення про припинення R.GS
                Create_Appeal (l_At_Id, l_Ap_Id);

                IF (l_cnt = 0)
                THEN
                    --Створюємо акт
                    Api$act.Init_Act_By_Appeals (p_Mode       => 5,
                                                 p_Ap_Id      => l_Ap_Id,
                                                 p_Messages   => l_Mes);

                    --#110881
                    SELECT At_Id
                      INTO l_At_By_Ap
                      FROM Act
                     WHERE at_ap = l_Ap_Id;

                    Api$act.Copy_At_Documents_Signers_To_New_Act (
                        p_At_Id       => l_At_Id,
                        p_New_At_Id   => l_At_By_Ap);
                END IF;

                UPDATE Act a
                   SET a.At_Ap = l_Ap_Id
                 WHERE a.At_Id = l_At_Id;
            END IF;
        --Отримуємо ІД рішення про припинення
        -- оце зараз лишнє
        /*SELECT a.At_Main_Link
          INTO l_At_Rstopss
          FROM Act a
         WHERE a.At_Id = l_At_Id;

        IF l_At_Rstopss IS NOT NULL THEN
          --Змінюємо стан рішення про припинення
          Api$act.Approve_Act(l_At_Rstopss);
        END IF;*/
        END IF;
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
            p_At_St_Old      => 'NN',
            p_At_St_New      => 'ND',
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
            p_At_St_Old   => 'NV',
            p_At_St_New   => 'NR',
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
END Cmes$act_Ipnp;
/