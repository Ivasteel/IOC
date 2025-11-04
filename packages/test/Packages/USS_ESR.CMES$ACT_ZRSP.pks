/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_ZRSP
IS
    -- Author  : BOGDAN
    -- Created : 18.10.2023 13:01:10
    -- Purpose : АПІ акту «Звіт за результатами соціального супроводу сім’ї/особи»

    Pkg          CONSTANT VARCHAR2 (30) := 'CMES$ACT_ZRSP';

    c_Form_Ndt   CONSTANT NUMBER := 859;

    TYPE r_Act_Zrsp IS RECORD
    (
        At_Pc                 Act.At_Pc%TYPE,
        At_Dt                 TIMESTAMP,
        At_Org                Act.At_Org%TYPE,
        At_Sc                 Act.At_Sc%TYPE,
        At_Rnspm              Act.At_Rnspm%TYPE,
        At_Ap                 Act.At_Ap%TYPE,
        At_Case_Class         Act.At_Case_Class%TYPE,
        At_Action_Start_Dt    TIMESTAMP,
        At_Action_Stop_Dt     TIMESTAMP,
        At_Notes              Act.At_Notes%TYPE,
        At_Family_Info        Act.At_Family_Info%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Conclusion_Tp      Act.At_Conclusion_Tp%TYPE,
        At_Form_Tp            Act.At_Form_Tp%TYPE,
        At_Decision           NUMBER
    );

    FUNCTION Get_Act_File (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_At_Ndt_Name (p_At_Id      IN NUMBER,
                              p_is_error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2;

    -----------------------------------------------------------
    --        ЗБЕРЕЖЕННЯ АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Sections   IN     CLOB,
                        p_At_Signers    IN     CLOB,
                        p_At_Results    IN     CLOB,
                        p_At_Persons    IN     CLOB);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_at_main_link    IN     NUMBER,
                           p_at_pc           IN     NUMBER,
                           p_at_ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Rc (P_TCTR_ID       IN     NUMBER,
                           p_At_Dt_Start   IN     DATE,
                           p_At_Dt_Stop    IN     DATE,
                           p_At_Num        IN     VARCHAR2,
                           p_Doc_Tp        IN     VARCHAR2,
                           p_Cu_Pib        IN     VARCHAR2,
                           p_At_Src        IN     VARCHAR2,
                           p_is_sign       IN     VARCHAR2,
                           p_Res              OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (P_TCTR_ID         IN     NUMBER,
                           p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_Doc_Tp          IN     VARCHAR2,
                           p_Cu_Pib          IN     VARCHAR2,
                           p_At_Src          IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    --------------------------------------------------------------
    --   Отримання картки рішення для надавача
    --------------------------------------------------------------
    PROCEDURE Get_Act_Card_Pr (p_At_Id        IN     NUMBER,
                               p_Act             OUT SYS_REFCURSOR,
                               p_Docs            OUT SYS_REFCURSOR,
                               p_Docs_Attr       OUT SYS_REFCURSOR,
                               p_Docs_Files      OUT SYS_REFCURSOR);

    --------------------------------------------------------------
    --   Отримання картки рішення для отримувача
    --------------------------------------------------------------
    PROCEDURE Get_Act_Card_Rc (p_At_Id         IN     NUMBER,
                               p_Act              OUT SYS_REFCURSOR,
                               p_Docs             OUT SYS_REFCURSOR,
                               p_Docs_Attr        OUT SYS_REFCURSOR,
                               p_Docs_Files       OUT SYS_REFCURSOR,
                               p_Signers_Cur      OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ для КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR,
                            p_Persons_Cur        OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ "ЗВІТ ЗА
    -- ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ "ЗВІТ ЗА
    -- ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" ОТРИМУВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    --------------------------------------------------------------
    -- ПЕРЕВОД АКТУ "ЗВІТ ЗА ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" В СТАН
    -- "СКАСОВАНО"
    --------------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    --------------------------------------------------------------
    -- ПЕРЕВОД АКТУ "ЗВІТ ЗА ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" В СТАН
    -- "ВІДХИЛЕНО"
    --------------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);
END CMES$ACT_ZRSP;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_ZRSP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ZRSP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ZRSP TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ZRSP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_ZRSP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Zrsp
    IS
        l_Result   r_Act_Zrsp;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Zrsp', TRUE)
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

    -----------------------------------------------------------
    --        ЗБЕРЕЖЕННЯ АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Sections   IN     CLOB,
                        p_At_Signers    IN     CLOB,
                        p_At_Results    IN     CLOB,
                        p_At_Persons    IN     CLOB)
    IS
        l_Cu_Id           NUMBER;
        l_At_Cu           NUMBER;
        l_At_St_Old       VARCHAR2 (10);
        l_Already_Exist   NUMBER;
        l_At_Tctr_Id      NUMBER;
        l_Act             r_Act_Zrsp;
        l_Persons         Api$act.t_At_Persons;
        l_Sections        Api$act.t_At_Sections;
        l_Signers         Api$act.t_At_Signers;
        l_Results         Api$act.t_At_Results;
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        l_Act := Parse_Act (p_Act);

        IF     l_Act.At_Rnspm IS NOT NULL
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_SPEC')
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_CM')
        THEN
            Raise_Application_Error (-20000, 'Некоректно вакзано надавача');
        END IF;

        --Редагування акту
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

            IF NVL (l_At_St_Old, '-') <> 'LN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування акту в поточному статусі заборонено');
            END IF;
        END IF;

        /*  SELECT *
          INTO l_Already_Exist
          FROM (
        SELECT COUNT(CASE WHEN ati_is_signed = 'T' THEN 1 END) AS signed,
               COUNT(*) AS all_signers
          FROM Act a
          JOIN At_Signers s
            ON a.At_Id = s.Ati_At
           AND s.History_Status = 'A'
         WHERE a.At_Tp = 'APOP'
           AND a.at_ap = l_Act.at_ap
          -- AND s.ati_is_signed = 'F'
          ;

        IF l_Already_Exist = 0 THEN
          Raise_Application_Error(-20000,
                                  'Акт "звіт за даними соціального супроводу" не можна створювати. Типовий договір про надання СП ще не підписано!');
        END IF;

           */


        SELECT COUNT (*), MAX (a.At_Id)
          INTO l_Already_Exist, l_At_Tctr_Id
          FROM Act a
         WHERE     a.At_Tp = 'TCTR'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St IN ('DT')
               AND a.At_Id <> NVL (p_At_Id, -1);


        IF l_Already_Exist = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Акт "звіт за даними соціального супроводу" не можна створювати. Типовий договір про надання СП ще не підписано!');
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'ZRSP'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('LR', 'LD')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Already_Exist = 1
        THEN
            Raise_Application_Error (
                -20000,
                'По цьому випадку вже існує звіт за даними соціального супроводу');
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Sections := Api$act.Parse_Sections (p_At_Sections);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Results := Api$act.Parse_At_Results (p_At_Results);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'ZRSP',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Ap               => l_Act.At_Ap,
            p_At_St               => 'LN',
            p_At_Src              => p_At_Src,
            p_At_Case_Class       => l_Act.At_Case_Class,
            p_At_Main_Link_Tp     => 'DECISION',
            p_At_Main_Link        => l_Act.At_Decision,
            p_At_Action_Start_Dt   =>
                NULLIF (l_Act.At_Action_Start_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Action_Stop_Dt   =>
                NULLIF (l_Act.At_Action_Stop_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Notes            => l_Act.At_Notes,
            p_At_Family_Info      => l_Act.At_Family_Info,
            p_At_Live_Address     => l_Act.At_Live_Address,
            p_At_Cu               => l_Cu_Id,
            p_At_Conclusion_Tp    => l_Act.At_Conclusion_Tp,
            p_At_Form_Tp          => l_Act.At_Form_Tp,
            p_New_Id              => p_At_Id);


        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Sections (p_At_Id      => p_At_Id,
                               p_Sections   => l_Sections,
                               p_Persons    => l_Persons);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);
        Api$act.Save_At_Results (p_At_Id => p_At_Id, p_Results => l_Results);

        Api$act.Add_At_Link (p_At_Id, l_At_Tctr_Id, 'TCTR');

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (p_at_id => p_At_Id, p_ndt_id => c_Form_Ndt);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'LN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    FUNCTION Get_At_Ndt_Name (p_At_Id      IN NUMBER,
                              p_Is_Error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2
    IS
        l_Ndt_Id     NUMBER;
        l_Ndt_Name   Uss_Ndi.v_Ndi_Document_Type.Ndt_Name%TYPE;
    BEGIN
        l_Ndt_Id :=
            Api$act.Define_Print_Form_Ndt (
                p_At_Id   => p_At_Id,
                p_Raise_If_Undefined   =>
                    CASE WHEN p_Is_Error = 'T' THEN TRUE ELSE FALSE END);

        IF l_Ndt_Id IS NOT NULL
        THEN
            SELECT t.Ndt_Name
              INTO l_Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = l_Ndt_Id;
        END IF;

        RETURN l_Ndt_Name;
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   api$act.Get_Atd_Attach_Source (a.at_id, c_Form_Ndt)
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Zrsp_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
             WHERE a.At_Id = p_At_Id;
    END;

    /*PROCEDURE Get_Act_Pr(p_At_Id IN NUMBER,
                         p_Res   OUT SYS_REFCURSOR) IS
      l_At_Direction VARCHAR2(10);
    BEGIN
      SELECT Api$appeal.Get_Ap_Doc_Str(p_Ap_Id => a.At_Ap, p_Nda_Class => 'DIRECTION')
        INTO l_At_Direction
        FROM Act a
       WHERE a.At_Id = p_At_Id;

      OPEN p_Res FOR
        SELECT a.At_Id, a.At_Num, a.At_Dt, a.At_Src, s.Dic_Name AS At_Src_Name, a.At_St, St.Dic_Name AS At_St_Name, a.At_Pc, a.At_Ap,
               a.At_Org, o.Org_Name AS At_Org_Name,
               --Код файлу друкованої форми
               Get_Act_File(a.At_Id, c_Form_Ndt) AS At_Form_File, Get_At_Ndt_Name(a.At_Id, 'F') AS At_Ndt_Name,
               -- Назва НСП
               Api$act.Get_At_Rnspm(a.At_Rnspm) AS At_Rnspm_Pib, a.At_Rnspm,
               --Отримувач (щодо кого)
               Uss_Person.Api$sc_Tools.Get_Pib(a.At_Sc) AS At_Sc_Pib, a.At_Sc AS At_Sc,
               -- ПІБ яка сформувала
               Api$act.Get_At_Spec_Name(a.At_Wu, a.At_Cu) AS Spec_Pib,
               -- Посада особи, яка сформувала
               Api$act.Get_At_Spec_Position(a.At_Wu, a.At_Cu, a.At_Rnspm) AS Spec_Position
          FROM Act a
          JOIN Uss_Ndi.v_Ddn_Ap_Src s
            ON a.At_Src = s.Dic_Value
          JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St
            ON a.At_St = St.Dic_Value
          JOIN Opfu o
            ON a.At_Org = o.Org_Id
         WHERE a.At_Id = p_At_Id;
    END;*/

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnspm_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   api$act.Get_Atd_Attach_Source (a.at_id, c_Form_Ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Zrsp_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_at_main_link    IN     NUMBER,
                           p_at_pc           IN     NUMBER,
                           p_at_ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ZRSP'
                   AND (a.At_Cu = l_Cu_Id)
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND NVL (a.At_Case_Class, '-') =
                       NVL (p_At_Case_Class, NVL (a.At_Case_Class, '-'))
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Rc (p_Tctr_Id       IN     NUMBER,
                           p_At_Dt_Start   IN     DATE,
                           p_At_Dt_Stop    IN     DATE,
                           p_At_Num        IN     VARCHAR2,
                           p_Doc_Tp        IN     VARCHAR2,
                           p_Cu_Pib        IN     VARCHAR2,
                           p_At_Src        IN     VARCHAR2,
                           p_Is_Sign       IN     VARCHAR2,
                           p_Res              OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, де поточний користувач є серед підписантів,
        --та які хоч раз переводились до стану "Очікує підписання"
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act  a
                   JOIN At_Links l ON (a.At_Id = l.Atk_At)
                   JOIN At_Signers s
                       ON a.At_Id = s.Ati_At AND s.History_Status = 'A'
                   LEFT JOIN Ikis_Rbm.v_Cmes_Users Cu ON (a.At_Cu = Cu.Cu_Id)
             WHERE     a.At_Tp = 'ZRSP'
                   AND s.Ati_Sc = l_Cu_Sc
                   AND l.Atk_Tp = 'TCTR'
                   AND l.Atk_Link_At = p_Tctr_Id
                   -- AND a.At_Sc = l_Cu_Sc
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_Cu_Pib IS NULL
                        OR UPPER (Cu.Cu_Pib) LIKE UPPER (p_Cu_Pib) || '%')
                   AND (p_At_Src IS NULL OR a.At_Src = p_At_Src)
                   AND (   p_Is_Sign IS NULL
                        OR     p_Is_Sign = 'T'
                           AND EXISTS
                                   (SELECT 1
                                      FROM At_Log l
                                     WHERE     l.Atl_At = a.At_Id
                                           AND l.Atl_St = 'LV'));

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_Tctr_Id         IN     NUMBER,
                           p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_Doc_Tp          IN     VARCHAR2,
                           p_Cu_Pib          IN     VARCHAR2,
                           p_At_Src          IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act  a
                   JOIN At_Links l ON (a.At_Id = l.Atk_At)
                   LEFT JOIN Ikis_Rbm.v_Cmes_Users Cu ON (a.At_Cu = Cu.Cu_Id)
             WHERE     a.At_Tp = 'ZRSP'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   AND l.Atk_Tp = 'TCTR'
                   AND l.Atk_Link_At = p_Tctr_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_Cu_Pib IS NULL
                        OR UPPER (Cu.Cu_Pib) LIKE UPPER (p_Cu_Pib) || '%')
                   AND (p_At_Src IS NULL OR a.At_Src = p_At_Src);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ РЕЗУЛЬТАТУ ІНДИВІДУАЛЬНОГО ПЛАНУ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Results (p_At_Id         IN     NUMBER,
                           p_Results_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Results_Cur FOR
            SELECT t.*,
                   p.Atip_Desc                                              AS Atr_Atip_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (t.Atr_Redirect_Rnspm)    AS Atr_Redirect_Rnspm_Name
              FROM At_Results  t
                   JOIN At_Individual_Plan p ON (p.Atip_Id = t.Atr_Atip)
             WHERE t.Atr_At = p_At_Id;
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

    -----------------------------------------------------------
    --        ОТРИМАННЯ ВКЛАДЕНЬ ДОКУМЕНТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.Atd_Id,
                   d.Atd_Doc                          AS Doc_Id,
                   d.Atd_Dh                           AS Dh_Id,
                   f.File_Code,
                   f.File_Name,
                   f.File_Mime_Type,
                   f.File_Size,
                   f.File_Hash,
                   f.File_Create_Dt,
                   f.File_Description,
                   s.File_Code                        AS File_Sign_Code,
                   s.File_Hash                        AS File_Sign_Hash,
                   (SELECT LISTAGG (Fs.File_Code, ',')
                               WITHIN GROUP (ORDER BY Ss.Dats_Id)
                      FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                           JOIN Uss_Doc.v_Files Fs
                               ON Ss.Dats_Sign_File = Fs.File_Id
                     WHERE Ss.Dats_Dat = a.Dat_Id)    AS File_Signs,
                   a.Dat_Num
              FROM At_Document  d
                   JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                   LEFT JOIN Uss_Doc.v_Files s ON a.Dat_Sign_File = s.File_Id
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
                                   AND NVL (Sg.Ati_Is_Signed, 'F') = 'F');
    END;

    --------------------------------------------------------------
    --   Отримання картки рішення для надавача
    --------------------------------------------------------------
    PROCEDURE Get_Act_Card_Pr (p_At_Id        IN     NUMBER,
                               p_Act             OUT SYS_REFCURSOR,
                               p_Docs            OUT SYS_REFCURSOR,
                               p_Docs_Attr       OUT SYS_REFCURSOR,
                               p_Docs_Files      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act);
        Api$act.Get_Documents (p_At_Id, p_Docs);
        Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
        Get_Doc_Files (p_At_Id, p_Docs_Files);
    END;


    --------------------------------------------------------------
    --   Отримання картки рішення для отримувача
    --------------------------------------------------------------
    PROCEDURE Get_Act_Card_Rc (p_At_Id         IN     NUMBER,
                               p_Act              OUT SYS_REFCURSOR,
                               p_Docs             OUT SYS_REFCURSOR,
                               p_Docs_Attr        OUT SYS_REFCURSOR,
                               p_Docs_Files       OUT SYS_REFCURSOR,
                               p_Signers_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act);
        Api$act.Get_Documents (p_At_Id, p_Docs);
        Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
        Get_Doc_Files (p_At_Id, p_Docs_Files);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR,
                            p_Persons_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Results (p_At_Id, p_Results_Cur);
        Api$act.Get_Persons (p_At_Id, p_Persons_Cur);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);
        Api$act.Get_Form_File (p_At_Id       => p_At_Id,
                               p_Form_Ndt    => c_Form_Ndt,
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
            p_Form_Ndt               => c_Form_Ndt,
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);
        Api$act.Get_Form_File (
            p_At_Id             => p_At_Id,
            p_At_Prj_St         => 'LN',
            p_Form_Ndt          => c_Form_Ndt,
            p_Form_Build_Proc   => 'Api$Act_Rpt.ACT_DOC_859_R1',
            p_Doc_Cur           => p_Doc_Cur);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => c_Form_Ndt,
                              p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
    BEGIN
        Api$act.Get_Form_Doc_Src (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => c_Form_Ndt,
                                  p_Doc_Src   => p_Doc_Src);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ "ЗВІТ ЗА
    -- ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        --l_doc_Attach_Src VARCHAR2(10);
        l_st   VARCHAR2 (10) := 'LV';
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => c_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            /*Get_Form_Doc_Src(p_at_id, l_doc_Attach_Src);
            IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T') THEN
              l_st := 'LS';
              Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id, p_Ndt_Id => c_Form_Ndt);
            ELSIF (l_doc_Attach_Src = 'TABLET' AND l_is_used = 'T' AND Api$act.Is_All_Signed(p_At_Id => p_At_Id, p_Ati_Tp => 'RC')) THEN
              l_st := 'LS';
            END IF;*/
            api$act.Handle_Cm_Sign (p_at_id,
                                    l_st,
                                    'LS',
                                    Api$act.Define_Print_Form_Ndt (p_At_Id),
                                    l_st);

            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'LN',
                p_At_St_New   => l_st,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ "ЗВІТ ЗА
    -- ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" ОТРИМУВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Rc');
        Cmes$act.Set_Signed_Rc (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => c_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'LV',
                p_At_St_New   => 'LS',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;


    --------------------------------------------------------------
    -- ПЕРЕВОД АКТУ "ЗВІТ ЗА ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" В СТАН
    -- "СКАСОВАНО"
    --------------------------------------------------------------
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
            p_At_St_Old      => 'LN',
            p_At_St_New      => 'LD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    --------------------------------------------------------------
    -- ПЕРЕВОД АКТУ "ЗВІТ ЗА ДАНИМИ СОЦІАЛЬНОГО СУПРОВОДУ" В СТАН
    -- "ВІДХИЛЕНО"
    --------------------------------------------------------------
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

        IF    --Якщо стан акту "Проект" - дозволяемо змінювати стан, лише якщо поточний користувач кейс-менеджер
              (l_At_St = 'LN' AND Cmes$act.Check_Act_Access_Cm (p_At_Id))
           OR --Якщо стан акту "Очікує підписання" - дозволяемо змінювати стан, лише якщо поточний користувач отримувач
              (    l_At_St = 'LV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'CM'))
        THEN
            UPDATE Act a
               SET a.At_St = 'LR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'LR',
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;
BEGIN
    NULL;
END Cmes$act_Zrsp;
/