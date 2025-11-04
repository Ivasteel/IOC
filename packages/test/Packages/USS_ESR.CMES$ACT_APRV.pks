/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_APRV
IS
    -- Author  : SHOSTAK
    -- Created : 23.11.2023 4:57:28 PM
    -- Purpose :

    Pkg                          VARCHAR2 (50) := 'CMES$ACT_APRV';

    c_At_Tp             CONSTANT VARCHAR2 (10) := 'APRV';
    c_At_Tp_Name        CONSTANT VARCHAR2 (1000) := 'акту про результат візиту';

    c_At_St_Prj         CONSTANT VARCHAR2 (10) := 'BN';
    c_At_St_Canceled    CONSTANT VARCHAR2 (10) := 'BD';
    c_At_St_Declined    CONSTANT VARCHAR2 (10) := 'BR';
    c_At_St_Signed_Cm   CONSTANT VARCHAR2 (10) := 'BV';
    c_At_St_Signed_Rc   CONSTANT VARCHAR2 (10) := 'BS';
    c_At_St_Signed_Pr   CONSTANT VARCHAR2 (10) := 'BP';

    c_Form_Ndt          CONSTANT NUMBER := 869;

    TYPE r_Act IS RECORD
    (
        At_Pc       Act.At_Pc%TYPE,
        At_Dt       TIMESTAMP,
        At_Org      Act.At_Org%TYPE,
        At_Sc       Act.At_Sc%TYPE,
        At_Rnspm    Act.At_Rnspm%TYPE,
        At_Tctr     NUMBER
    );


    PROCEDURE Save_Act (p_At_Id           IN OUT NUMBER,
                        p_At_Src          IN     VARCHAR2,
                        p_Act             IN     CLOB,
                        p_At_Persons      IN     CLOB,
                        p_At_Attrs        IN     CLOB,
                        p_At_Other_Spec   IN     CLOB,
                        p_At_Signers      IN     CLOB);


    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                --Не знаю навіщо, але за постановкою ЖХ потрібні фільтри
                                p_At_Dt_Start     IN     DATE,
                                p_At_Dt_Stop      IN     DATE,
                                p_At_Num          IN     VARCHAR2,
                                p_At_Src          IN     VARCHAR2,
                                p_At_Spec_Name    IN     VARCHAR2,
                                p_Need_Sign       IN     VARCHAR2,
                                p_At_Main_Link    IN     NUMBER,
                                p_At_Pc           IN     NUMBER,
                                p_At_Ap           IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR,
                                p_Attrs              OUT SYS_REFCURSOR);


    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Spec_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur        OUT SYS_REFCURSOR);


    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);


    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);


    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Aprv;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_APRV TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_APRV TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:19 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_APRV
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
    --        ОТРИМАННЯ ІД ДОКУМЕНТА ДРУКОВАНОЇ ФОРМИ
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
               AND d.Atd_Ndt = c_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => c_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                             p_Dh_Doc         => l_Doc_Id,
                                             p_Dh_Sign_Alg    => NULL,
                                             p_Dh_Ndt         => c_Form_Ndt,
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
                     c_Form_Ndt,
                     l_Doc_Id,
                     l_Dh_Id,
                     'A')
          RETURNING Atd_Id
               INTO l_Atd_Id;

        RETURN l_Atd_Id;
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

        g_Nda_Map (2839) := 'At_Analysis';
        g_Nda_Map (2840) := 'At_Conclusion';
        g_Nda_Map (2836) := 'At_Centr';
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id           IN OUT NUMBER,
                        p_At_Src          IN     VARCHAR2,
                        p_Act             IN     CLOB,
                        p_At_Persons      IN     CLOB,
                        p_At_Attrs        IN     CLOB,
                        p_At_Other_Spec   IN     CLOB,
                        p_At_Signers      IN     CLOB)
    IS
        l_Cu_Id        NUMBER;
        l_At_Cu        NUMBER;
        l_At_St_Old    VARCHAR2 (10);
        l_Act          r_Act;
        l_Persons      Api$act.t_At_Persons;
        l_Other_Spec   Api$act.t_At_Other_Spec;
        l_Signers      Api$act.t_At_Signers;
        l_Attrs        Api$act.t_At_Document_Attrs;
        l_Svc_Exists   NUMBER;
        l_Pdsp_St      VARCHAR2 (10);
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

        SELECT SIGN (COUNT (*))
          INTO l_Svc_Exists
          FROM Ap_Service s
         WHERE     s.Aps_Ap = l_Act.At_Tctr
               AND s.Aps_Nst = 418
               AND s.History_Status = 'A'
               --стаус="Надається"
               AND s.Aps_St = 'SG';

        IF l_Svc_Exists <> 1
        THEN
            Raise_Application_Error (
                -20000,
                   'Створення '
                || c_At_Tp_Name
                || ' можливо лише при наявності у договорі послуги "Соціальний супровід сімей, у яких виховуються діти-сироти і діти, позбавлені батьківського піклування"');
        END IF;

        SELECT p.At_St
          INTO l_Pdsp_St
          FROM Act t JOIN Act p ON t.At_Main_Link = p.At_Id
         WHERE t.At_Id = l_Act.At_Tctr;

        IF l_Pdsp_St <> 'SS'
        THEN
            Raise_Application_Error (
                -20000,
                   'Створення '
                || c_At_Tp_Name
                || ' можливо лише якщо рішення про надання в статусі "Договір підписано"');
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

            IF NVL (l_At_St_Old, '-') <> c_At_St_Prj
            THEN
                Raise_Application_Error (
                    -20000,
                       'Редагування '
                    || c_At_Tp_Name
                    || ' в поточному статусі заборонено');
            END IF;
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Other_Spec := Api$act.Parse_Other_Spec (p_At_Other_Spec);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (p_At_Id             => p_At_Id,
                          p_At_Tp             => c_At_Tp,
                          p_At_Pc             => l_Act.At_Pc,
                          p_At_Ap             => NULL,
                          p_At_Num            => NULL,
                          p_At_Dt             => l_Act.At_Dt,
                          p_At_Org            => l_Act.At_Org,
                          p_At_Sc             => l_Act.At_Sc,
                          p_At_Rnspm          => l_Act.At_Rnspm,
                          p_At_St             => c_At_St_Prj,
                          p_At_Src            => p_At_Src,
                          p_At_Main_Link_Tp   => 'TCTR',
                          p_At_Main_Link      => l_Act.At_Tctr,
                          p_At_Cu             => l_Cu_Id,
                          p_New_Id            => p_At_Id);

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Other_Specs (p_At_Id         => p_At_Id,
                                  p_Other_Specs   => l_Other_Spec);
        Api$act.Save_Signers (p_At_Id => p_At_Id, p_Signers => l_Signers);

        Map_Nda2act;
        Api$act.Save_Attributes (p_At_Id     => p_At_Id,
                                 p_Atd_Id    => Get_Form_Doc (p_At_Id),
                                 p_Attrs     => l_Attrs,
                                 p_Nda_Map   => g_Nda_Map);

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (
            p_at_id   => p_At_Id,
            p_ndt_id   =>
                Api$act.Define_Print_Form_Ndt (
                    p_At_Id,
                    p_Raise_If_Undefined   => FALSE));

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => c_At_St_Prj,
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_At_Id     => p_At_Id,
                                p_Atd_Ndt   => c_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => c_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
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
                   --акт щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) акту
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
                   api$act.Get_Atd_Attach_Source (
                       a.at_id,
                       Api$act.Define_Print_Form_Ndt (a.at_id, l_flag))
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Aprv_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ЗА ДОГОВОРОМ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                --Не знаю навіщо, але за постановкою ЖХ потрібні фільтри
                                p_At_Dt_Start     IN     DATE,
                                p_At_Dt_Stop      IN     DATE,
                                p_At_Num          IN     VARCHAR2,
                                p_At_Src          IN     VARCHAR2,
                                p_At_Spec_Name    IN     VARCHAR2,
                                p_Need_Sign       IN     VARCHAR2,
                                p_At_Main_Link    IN     NUMBER,
                                p_At_Pc           IN     NUMBER,
                                p_At_Ap           IN     NUMBER,
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
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN c_At_St_Declined THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Main_Link = p_Tctr_Id
                               AND a.At_Tp = c_At_Tp
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               AND a.At_St <> c_At_St_Canceled
                               AND a.At_Dt BETWEEN NVL (p_At_Dt_Start,
                                                        a.At_Dt)
                                               AND NVL (p_At_Dt_Stop,
                                                        a.At_Dt)
                               AND (   p_At_Num IS NULL
                                    OR a.At_Num LIKE p_At_Num || '%')
                               AND (p_At_Src IS NULL OR a.At_Src = p_At_Src)
                               AND (   NVL (p_Need_Sign, 'F') = 'F'
                                    OR a.At_St = c_At_St_Signed_Rc)
                               AND (   p_At_Main_Link IS NULL
                                    OR a.At_Main_Link = p_At_Main_Link)
                               AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                               AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap)
                               AND (   p_At_Spec_Name IS NULL
                                    OR EXISTS
                                           (SELECT 1
                                              FROM Ikis_Rbm.v_Cmes_Users u
                                             WHERE     u.Cu_Id = a.At_Cu
                                                   AND UPPER (u.Cu_Pib) LIKE
                                                              UPPER (
                                                                  p_At_Spec_Name)
                                                           || '%')))
                 WHERE Rn = 1;
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN c_At_St_Declined THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Main_Link = p_Tctr_Id
                               AND a.At_Tp = c_At_Tp
                               AND a.At_St NOT IN
                                       (c_At_St_Canceled, c_At_St_Prj)
                               AND (   a.At_Sc = l_Sc_Id
                                    OR EXISTS
                                           (SELECT 1
                                              FROM At_Signers s
                                             WHERE     s.Ati_At = a.At_Id
                                                   AND s.History_Status = 'A'
                                                   AND s.Ati_Sc = l_Sc_Id))
                               AND EXISTS
                                       (SELECT 1
                                          FROM At_Log l
                                         WHERE     l.Atl_At = a.At_Id
                                               AND l.Atl_St =
                                                   c_At_St_Signed_Cm)
                               AND a.At_Dt BETWEEN NVL (p_At_Dt_Start,
                                                        a.At_Dt)
                                               AND NVL (p_At_Dt_Stop,
                                                        a.At_Dt)
                               AND (   p_At_Num IS NULL
                                    OR a.At_Num LIKE p_At_Num || '%')
                               AND a.At_Src = NVL (p_At_Src, a.At_Src)
                               AND (   NVL (p_Need_Sign, 'F') = 'F'
                                    OR a.At_St = c_At_St_Signed_Cm)
                               AND a.At_Main_Link =
                                   NVL (p_At_Main_Link, a.At_Main_Link)
                               AND a.At_Pc = NVL (p_At_Pc, a.At_Pc)
                               AND a.At_Ap = NVL (p_At_Ap, a.At_Ap)
                               AND (   p_At_Spec_Name IS NULL
                                    OR EXISTS
                                           (SELECT 1
                                              FROM Ikis_Rbm.v_Cmes_Users u
                                             WHERE     u.Cu_Id = a.At_Cu
                                                   AND UPPER (u.Cu_Pib) LIKE
                                                              UPPER (
                                                                  p_At_Spec_Name)
                                                           || '%')))
                 WHERE Rn = 1;
        END IF;

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
    --          ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
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
                   --акт щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) акту
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
                   api$act.Get_Atd_Attach_Source (
                       a.at_id,
                       Api$act.Define_Print_Form_Ndt (a.at_id, l_flag))
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Aprv_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ЗАЛУЧЕНИХ СПЕЦІАЛІСТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Other_Spec (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Dic_Name AS Atop_Tp_Name
              FROM At_Other_Spec  s
                   JOIN Uss_Ndi.v_Ddn_Atop_Avop_Tp t
                       ON s.Atop_Tp = t.Dic_Value
             WHERE s.Atop_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ КАРТКИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Spec_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Attributes (p_At_Id, p_Attrs_Cur);
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
                               p_At_Prj_St         => c_At_St_Prj,
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
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
    BEGIN
        Api$act.Get_Form_Doc_Src (
            p_At_Id     => p_At_Id,
            p_Atd_Ndt   => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Doc_Src   => p_Doc_Src);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМа
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        --l_doc_Attach_Src VARCHAR2(10);
        l_st   VARCHAR2 (10) := c_At_St_Signed_Cm;
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (p_At_Id => p_At_Id, p_file_code => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            /*Get_Form_Doc_Src(p_at_id, l_doc_Attach_Src);
            IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T') THEN
              l_st := c_At_St_Signed_Rc;
              Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id, p_Ndt_Id => Api$act.Define_Print_Form_Ndt(p_At_Id));
            ELSIF (l_doc_Attach_Src = 'TABLET' AND l_is_used = 'T' AND Api$act.Is_All_Signed(p_At_Id => p_At_Id, p_Ati_Tp => 'RC')) THEN
              l_st := c_At_St_Signed_Rc;
            END IF;*/
            api$act.Handle_Cm_Sign (p_at_id,
                                    l_st,
                                    c_At_St_Signed_Rc,
                                    Api$act.Define_Print_Form_Ndt (p_At_Id),
                                    l_st);

            Api$act.Set_At_St (
                p_At_Id               => p_At_Id,
                p_At_St_Old           => c_At_St_Prj,
                p_At_St_New           => l_st,
                p_At_Action_Stop_Dt   => SYSDATE,
                p_Log_Msg             => CHR (38) || '251',
                p_Wrong_St_Msg        =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Rc');
        Cmes$act.Set_Signed_Rc (p_At_Id => p_At_Id, p_file_code => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => c_At_St_Signed_Cm,
                p_At_St_New   => c_At_St_Signed_Rc,
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id => p_At_Id, p_file_code => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => c_At_St_Signed_Rc,
            p_At_St_New   => c_At_St_Signed_Pr,
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');
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
            p_At_St_Old      => c_At_St_Prj,
            p_At_St_New      => c_At_St_Canceled,
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

        IF    --Якщо стан акту "Очікує підписання" - дозволяемо змінювати стан, лише якщо поточний користувач є серед підписантів
              (    l_At_St = c_At_St_Signed_Cm
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = c_At_St_Signed_Rc
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = c_At_St_Declined
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => c_At_St_Declined,
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
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
END Cmes$act_Aprv;
/