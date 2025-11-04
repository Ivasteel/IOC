/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_NDIS
IS
    -- Author  : BOGDAN
    -- Created : 31.10.2023 12:37:42
    -- Purpose : Акт  "Направлення сім`ї/особи до іншого суб’єкта"


    Pkg                    VARCHAR2 (50) := 'CMES$ACT_NDIS';

    с_Form_Ndt   CONSTANT NUMBER := 840;

    TYPE r_Act_Ndis IS RECORD
    (
        At_Pc                Act.At_Pc%TYPE,
        At_Dt                TIMESTAMP,
        At_Org               Act.At_Org%TYPE,
        At_Sc                Act.At_Sc%TYPE,
        At_Rnspm             Act.At_Rnspm%TYPE,
        At_Ap                Act.At_Ap%TYPE,
        At_Redirect_Rnspm    Act.At_Redirect_Rnspm%TYPE,
        At_Decision          NUMBER
    );

    /*TYPE r_Act_Ndis IS RECORD(
    At_Pc              Act.At_Pc%TYPE,
    At_Dt              TIMESTAMP,
    At_Org             Act.At_Org%TYPE,
    At_Sc              Act.At_Sc%TYPE,
    At_Rnspm           Act.At_Rnspm%TYPE,
    At_Ap              Act.At_Ap%TYPE,
    At_Case_Class      Act.At_Case_Class%TYPE,
    At_Action_Start_Dt TIMESTAMP,
    At_Action_Stop_Dt  TIMESTAMP,
    At_Notes           Act.At_Notes%TYPE,
    At_Family_Info     Act.At_Family_Info%TYPE,
    At_Live_Address    Act.At_Live_Address%TYPE,
    At_Conclusion_Tp   Act.At_Conclusion_Tp%TYPE,
    At_Form_Tp         Act.At_Form_Tp%TYPE,

    At_Decision NUMBER);*/

    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Services   IN     CLOB,
                        p_At_Persons    IN     CLOB,
                        p_At_Attrs      IN     CLOB,
                        p_At_Signers    IN     CLOB);

    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Pers_Cur          OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card_Pr (p_At_Id        IN     NUMBER,
                               p_Act             OUT SYS_REFCURSOR,
                               p_Docs            OUT SYS_REFCURSOR,
                               p_Docs_Attr       OUT SYS_REFCURSOR,
                               p_Docs_Files      OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Rc (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

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

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     );

    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER);

    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Create_NDIS (P_pdsp_at_id NUMBER);
END Cmes$act_Ndis;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_NDIS TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_NDIS TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_NDIS
IS
    g_Nda_Map   Api$act.t_Nda_Map;

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Ndis
    IS
        l_Result   r_Act_Ndis;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Ndis', TRUE)
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

        g_Nda_Map (4354) := 'At_Add_Info';
        g_Nda_Map (4355) := 'At_Add_Info_Svc';
        g_Nda_Map (4356) := 'At_Complex_Info';
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
               AND d.Atd_Ndt = с_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => с_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                             p_Dh_Doc         => l_Doc_Id,
                                             p_Dh_Sign_Alg    => NULL,
                                             p_Dh_Ndt         => с_Form_Ndt,
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
                     с_Form_Ndt,
                     l_Doc_Id,
                     l_Dh_Id,
                     'A')
          RETURNING Atd_Id
               INTO l_Atd_Id;

        RETURN l_Atd_Id;
    END;

    -----------------------------------------------------------
    --        ЗБЕРЕЖЕННЯ АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Services   IN     CLOB,
                        p_At_Persons    IN     CLOB,
                        p_At_Attrs      IN     CLOB,
                        p_At_Signers    IN     CLOB)
    IS
        l_Cu_Id           NUMBER;
        l_At_Cu           NUMBER;
        l_At_St_Old       VARCHAR2 (10);
        l_Act             r_Act_Ndis;
        l_At_Anpoe_Id     NUMBER;
        l_Already_Exist   NUMBER;
        l_Persons         Api$act.t_At_Persons;
        l_Signers         Api$act.t_At_Signers;
        l_Services        Api$act.t_At_Services;
        l_Atd_Id          NUMBER;
        l_Attrs           Api$act.t_At_Document_Attrs;
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

        IF     l_Act.At_Decision IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Decision)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано рішення по іншому надавачу');
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

            IF NVL (l_At_St_Old, '-') <> 'NN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування акту в поточному статусі заборонено');
            END IF;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'NDIS'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('ND')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Already_Exist = 1
        THEN
            Raise_Application_Error (
                -20000,
                'По цьому випадку вже існує акт направлень сім`ї/особи до іншого суб’єкта');
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'PDSP'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St IN ('SGA');

        IF l_Already_Exist = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Створити акт направлень сім`ї/особи до іншого суб’єкта в поточному стані акту рішення про надання соціальних послуг неможливо.');
        END IF;

        SELECT MAX (At_Id)
          INTO l_At_Anpoe_Id
          FROM Act a
         WHERE     a.At_Tp = 'ANPOE'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St IN ('XP');

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Services := Api$act.Parse_Services (p_At_Services);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (p_At_Id             => p_At_Id,
                          p_At_Tp             => 'NDIS',
                          p_At_Pc             => l_Act.At_Pc,
                          p_At_Ap             => l_Act.At_Ap,
                          p_At_Num            => NULL,
                          p_At_Dt             => l_Act.At_Dt,
                          p_At_Org            => l_Act.At_Org,
                          p_At_Sc             => l_Act.At_Sc,
                          p_At_Rnspm          => l_Act.At_Rnspm,
                          p_At_St             => 'NN',
                          p_At_Src            => p_At_Src,
                          p_At_Main_Link_Tp   => 'DECISION',
                          p_At_Main_Link      => l_Act.At_Decision,
                          p_At_Cu             => l_Cu_Id,
                          p_New_Id            => p_At_Id);

        Api$act.Save_Services (p_At_Id => p_At_Id, p_Services => l_Services);
        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);

        Map_Nda2act;
        l_Atd_Id := Get_Form_Doc (p_At_Id);
        Api$act.Save_Attributes (p_At_Id     => p_At_Id,
                                 p_Atd_Id    => l_Atd_Id,
                                 p_Attrs     => l_Attrs,
                                 p_Nda_Map   => g_Nda_Map);

        Api$act.Add_At_Link (p_At_Id, l_At_Anpoe_Id, 'ANPOE');

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'NN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Ap,
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
                   Api$act.Get_Signer_Position (a.At_Id, 'PR')
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД головного акту
                   a.At_Main_Link
                       AS At_Decision
              /*--Дата припинення надання СП
              a.At_Action_Stop_Dt AS At_Terminate_Dt,
              --Причина припинення надання СП
              a.At_Rnp, r.Rnp_Name AS At_Rnp_Name*/
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Ndis_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   /*LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                   ON a.At_Rnp = r.Rnp_Id*/
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id;
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_At_Id     => p_At_Id,
                                p_Atd_Ndt   => с_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => с_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
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
                   --Рішення щодо кого
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
                   a.at_ap,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   a.At_Main_Link
                       AS At_Decision,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Ndis_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
             WHERE a.At_Id = p_At_Id;
    END;


    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
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
             WHERE     a.At_Tp = 'NDIS'
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
    PROCEDURE Get_Acts_Rc (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Res                OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'NDIS'
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
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND NVL (a.At_Case_Class, '-') =
                       NVL (p_At_Case_Class, NVL (a.At_Case_Class, '-'))
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%');

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER := Ikis_Rbm.Tools.Getcurrentcu;
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
                   JOIN At_Signers s
                       ON a.At_Id = s.Ati_At AND s.History_Status = 'A'
             WHERE     a.At_Tp = 'NDIS'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   AND s.Ati_Cu = l_Cu_Id
                   AND EXISTS
                           (SELECT 1
                              FROM At_Log l
                             WHERE l.Atl_At = a.At_Id AND l.Atl_St = 'NS')
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND NVL (a.At_Case_Class, '-') =
                       NVL (p_At_Case_Class, NVL (a.At_Case_Class, '-'))
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%');

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --    ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id, ROW_NUMBER () OVER (ORDER BY 1) AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'NDIS'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               AND a.At_St <> 'ND');
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'NDIS'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM Ap_Person  p
                                           JOIN Appeal Ap
                                               ON p.App_Ap = Ap.Ap_Id
                                     WHERE     p.App_Ap = a.At_Ap
                                           AND p.App_Sc = l_Sc_Id
                                           AND p.App_Tp = 'Z'
                                           AND p.History_Status = 'A'
                                           --Виключаємо повідомлення про СЖО, тому що немає ніяких підстав відображати заявнику персональні дані членів сім'ї отримувача та інщі деталі щодо ведення випадку
                                           AND NVL (Ap.Ap_Sub_Tp, '-') <>
                                               'SC'))
                       AND a.At_St <> 'ND';
        END IF;

        Get_Act_List (p_Acts);
    END;


    --------------------------------------------------------------
    --           ОТРИМАННЯ ПОСЛУГ
    --------------------------------------------------------------
    PROCEDURE Get_Services (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Nst_Name AS Ats_Nst_Name
              --todo: уточнити щодо статусу
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
             WHERE s.Ats_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;

    -----------------------------------------------------------------------
    -- ОТРИМАННЯ ДАНИХ АКТУ "Направлення сім`ї/особи до іншого суб’єкта"
    -----------------------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Pers_Cur          OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Attributes (p_At_Id, p_Attrs_Cur);
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
    --   Отримання картки рішення для надавача/отримувача
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
                               p_At_Prj_St         => 'NN',
                               p_Form_Ndt          => l_Ndt_Id,
                               p_Form_Build_Proc   => l_Build_Proc,
                               p_Doc_Cur           => p_Doc_Cur);
    END;

    /*
      -----------------------------------------------------------
      --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
      -----------------------------------------------------------
      PROCEDURE Get_Form_File(p_At_Id     IN NUMBER,
                              p_Atd_Dh    OUT NUMBER,
                              p_File_Code OUT VARCHAR2) IS
      BEGIN
        Write_Audit('Get_Form_File');
        Check_Act_Access(p_At_Id);
        Api$act.Get_Form_File(p_At_Id => p_At_Id, p_Form_Ndt => с_Form_Ndt, p_Atd_Dh => p_Atd_Dh, p_File_Code => p_File_Code);
      END;

      -----------------------------------------------------------
      --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
      -----------------------------------------------------------
      PROCEDURE Get_Form_File(p_At_Id   IN NUMBER,
                              p_Doc_Cur OUT SYS_REFCURSOR) IS
      BEGIN
        Write_Audit('Get_Form_File');
        Check_Act_Access(p_At_Id);
        Api$act.Get_Form_File(p_At_Id           => p_At_Id,
                              p_At_Prj_St       => 'NN',
                              p_Form_Ndt        => с_Form_Ndt,
                              p_Form_Build_Proc => 'Api$Act_Rpt.Build_Stub', -- TODO: додати формування
                              p_Doc_Cur         => p_Doc_Cur);
      END;
    */
    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => с_Form_Ndt,
                              p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- ПЕРЕДАЧА НА ПІДПИС КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Check_Act_Access (p_At_Id);
        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'NN',
                p_At_St_New   => 'NS',
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис надавачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ НАДАВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'NS',
            p_At_St_New   => 'NP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Передано на підпис"');
    /*  --Для всіх рішень по зверненню до якого привязаний акт
    FOR Rec IN (SELECT d.At_Id AS Decision_Id
                  FROM Act a
                  JOIN Act d
                    ON a.At_Ap = d.At_Ap
                   AND d.At_Tp = 'PDSP'
                   AND d.At_St = 'SP1'
                 WHERE a.At_Id = p_At_Id)
    LOOP
      --Змінюємо статус рішення
      Api$act.Approve_Act(Rec.Decision_Id);
    END LOOP;*/
    END;

    -----------------------------------------------------------
    -- ПЕРЕВІД АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ В СТАН
    -- "СКАСОВАНО"
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
    --         ПЕРЕНАЗНАЧЕННЯ АКТУ НА ІНШОГО КЕЙС МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     )
    IS
        l_At_St       VARCHAR2 (10);
        l_At_Rnspm    NUMBER;
        l_Old_Cu_Id   NUMBER;
    BEGIN
        --Raise_Application_Error(-20000, 'deprecated');
        Write_Audit ('Change_Act_Cm');

        SELECT a.At_Rnspm, a.At_Cu
          INTO l_At_Rnspm, l_Old_Cu_Id
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Дозволяємо виконання операції лише для користувача надавача за яким закріплено акт
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

           UPDATE Act a
              SET a.At_Cu = p_New_Cu_Id
            WHERE a.At_Id = p_At_Id
        RETURNING a.At_St
             INTO l_At_St;

        Api$act.Write_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Hs        => Tools.Gethistsessioncmes (),
            p_Atl_St        => l_At_St,
            p_Atl_Message   =>
                   CHR (38)
                || '233#'
                || Ikis_Rbm.Tools.Getcupib (l_Old_Cu_Id)
                || '#'
                || Ikis_Rbm.Tools.Getcupib (p_New_Cu_Id),
            p_Atl_St_Old    => NULL);
    END;

    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER)
    IS
    BEGIN
        Api$act.Lock_Act_Form_Nowait (p_Atd_Id);
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

    --===============================================================--
    PROCEDURE Create_NDIS (P_pdsp_at_id NUMBER)
    AS
        --    l_Ap_Id        NUMBER := 43218;
        --    l_Pr_Signer    NUMBER := 201;
        l_File_Content   BLOB;
    BEGIN
        RETURN;

        FOR Rec
            IN (SELECT a.*,
                       c.At_Rnspm,
                       c.At_Id,
                       c.At_Sc,
                       c.At_Cu,
                       c.At_Pc,
                       (SELECT MAX (ats.ati_cu)
                          FROM at_signers ats
                         WHERE ats.ati_at = c.at_id AND ats.ati_tp = 'PR')    AS Pr_Signer
                  FROM Uss_Esr.Appeal  a
                       JOIN Uss_Esr.Act c
                           ON     a.Ap_Id = c.At_Ap
                              AND c.At_Tp = 'PDSP'
                              AND c.At_Rnspm IS NOT NULL
                 WHERE c.At_id = P_pdsp_at_id)
        LOOP
            DECLARE
                l_At_Id             NUMBER;
                l_Ndt_Id            NUMBER;
                l_Atd_Id            NUMBER;
                l_Doc_Id            NUMBER;
                l_Dh_Id             NUMBER;

                l_Ate_Id            NUMBER;

                l_Form_Build_Proc   VARCHAR2 (4000);

                l_File_Id           NUMBER;
                l_File_Code         VARCHAR2 (100);
                l_Dat_Id            NUMBER;
                l_Atp_Id            NUMBER;

                l_Attrs             Uss_Esr.Api$act.t_At_Document_Attrs;
            BEGIN
                l_At_Id := Uss_Esr.Sq_Id_Act.NEXTVAL;
                DBMS_OUTPUT.Put_Line (l_At_Id);

                INSERT INTO Uss_Esr.Act (At_Id,
                                         At_Tp,
                                         At_Sc,
                                         At_Pc,
                                         At_Num,
                                         At_Dt,
                                         At_Org,
                                         At_Rnspm,
                                         At_Ap,
                                         At_St,
                                         At_Src,
                                         At_Case_Class,
                                         At_Main_Link_Tp,
                                         At_Main_Link,
                                         At_Action_Start_Dt,
                                         At_Action_Stop_Dt,
                                         At_Notes,
                                         At_Family_Info,
                                         At_Live_Address,
                                         At_Wu,
                                         At_Cu,
                                         At_Conclusion_Tp,
                                         At_Form_Tp)
                     VALUES (l_At_Id,
                             'NDIS',
                             Rec.At_Sc,
                             Rec.At_Pc,
                             l_At_Id,
                             SYSDATE,
                             Rec.Com_Org,
                             Rec.At_Rnspm,
                             Rec.Ap_Id,
                             'NS',
                             'CMES',
                             NULL,
                             'DECISION',
                             Rec.At_Id,
                             SYSDATE,
                             SYSDATE,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             Rec.At_Cu,
                             NULL,
                             NULL);

                INSERT INTO Uss_Esr.At_Service (Ats_Id,
                                                Ats_At,
                                                Ats_Nst,
                                                History_Status,
                                                Ats_St)
                    SELECT 0,
                           l_At_Id,
                           s.Ats_Nst,
                           s.History_Status,
                           'R'
                      FROM Uss_Esr.At_Service s
                     WHERE s.Ats_At = Rec.At_Id;


                INSERT INTO Uss_Esr.At_Log (Atl_Id,
                                            Atl_At,
                                            Atl_Hs,
                                            Atl_St,
                                            Atl_Tp)
                     VALUES (0,
                             l_At_Id,
                             NULL,
                             'NS',
                             'SYS');

                l_Ndt_Id := 840;

                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => l_Ndt_Id,
                    p_Doc_Actuality   => 'U',
                    p_New_Id          => l_Doc_Id);

                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => l_Ndt_Id,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'U',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => 'CMES',
                    p_Dh_Cu          => Rec.Ap_Cu,
                    p_New_Id         => l_Dh_Id);

                INSERT INTO Uss_Esr.At_Document (Atd_Id,
                                                 Atd_At,
                                                 Atd_Ndt,
                                                 Atd_Doc,
                                                 Atd_Dh,
                                                 History_Status)
                     VALUES (0,
                             l_At_Id,
                             l_Ndt_Id,
                             l_Doc_Id,
                             l_Dh_Id,
                             'A')
                  RETURNING Atd_Id
                       INTO l_Atd_Id;

                --PR
                INSERT INTO Uss_Esr.At_Signers (Ati_Id,
                                                Ati_At,
                                                Ati_Atd,
                                                Ati_Is_Signed,
                                                Ati_Sign_Dt,
                                                History_Status,
                                                Ati_Order,
                                                Ati_Tp,
                                                Ati_Cu)
                     VALUES (0,
                             l_At_Id,
                             l_Atd_Id,
                             'F',
                             NULL,
                             'A',
                             1,
                             'PR',
                             rec.Pr_Signer                     /*l_Pr_Signer*/
                                          );

                INSERT INTO Uss_Esr.At_Person (Atp_Id,
                                               Atp_At,
                                               Atp_Sc,
                                               Atp_Fn,
                                               Atp_Mn,
                                               Atp_Ln,
                                               Atp_Birth_Dt,
                                               Atp_Relation_Tp,
                                               Atp_Is_Disabled,
                                               Atp_Is_Capable,
                                               Atp_Work_Place,
                                               Atp_Is_Adr_Matching,
                                               Atp_Phone,
                                               Atp_Notes,
                                               Atp_Live_Address,
                                               Atp_Tp,
                                               Atp_Cu,
                                               Atp_App_Tp,
                                               Atp_Fact_Address,
                                               History_Status,
                                               Atp_Is_Disordered,
                                               Atp_Disable_Record,
                                               Atp_Capable_Record,
                                               Atp_Disorder_Record,
                                               Atp_Sex,
                                               Atp_Citizenship,
                                               Atp_Is_Selfservice,
                                               Atp_Is_Vpo,
                                               Atp_Is_Orphan,
                                               Atp_Email,
                                               Atp_App)
                    SELECT 0,
                           l_At_Id,
                           p.Atp_Sc,
                           p.Atp_Fn,
                           p.Atp_Mn,
                           p.Atp_Ln,
                           p.Atp_Birth_Dt,
                           p.Atp_Relation_Tp,
                           p.Atp_Is_Disabled,
                           p.Atp_Is_Capable,
                           p.Atp_Work_Place,
                           p.Atp_Is_Adr_Matching,
                           p.Atp_Phone,
                           p.Atp_Notes,
                           p.Atp_Live_Address,
                           p.Atp_Tp,
                           p.Atp_Cu,
                           p.Atp_App_Tp,
                           p.Atp_Fact_Address,
                           p.History_Status,
                           p.Atp_Is_Disordered,
                           p.Atp_Disable_Record,
                           p.Atp_Capable_Record,
                           p.Atp_Disorder_Record,
                           p.Atp_Sex,
                           p.Atp_Citizenship,
                           p.Atp_Is_Selfservice,
                           p.Atp_Is_Vpo,
                           p.Atp_Is_Orphan,
                           p.Atp_Email,
                           p.Atp_App
                      FROM Uss_Esr.At_Person p
                     WHERE p.Atp_At = Rec.At_Id;

                Uss_Esr.Api$act.Add_Attr (
                    l_Attrs,
                    4356,
                    p_Val_Str   =>
                        'у особи СЖО, особа потребує надання послуги');

                Uss_Esr.Api$act.Save_Attributes (p_At_Id    => l_At_Id,
                                                 p_Atd_Id   => l_Atd_Id,
                                                 p_Attrs    => l_Attrs);

                l_Form_Build_Proc := 'Api$Act_Rpt.ACT_DOC_840_R1';

                EXECUTE IMMEDIATE   'select Uss_Esr.'
                                 || l_Form_Build_Proc
                                 || '(:p_At_Id) from dual'
                    INTO l_File_Content
                    USING IN l_At_Id;

                l_File_Code := Uss_Doc.Api$documents.Generate_File_Code;

                Uss_Doc.Api$documents.Save_File (
                    p_File_Id            => NULL,
                    p_File_Thumb         => NULL,
                    p_File_Code          => l_File_Code,
                    p_File_Name          =>
                        'Направлення сім`ї/особи до іншого суб’єкта для надання соціальних послуг.pdf',
                    p_File_Mime_Type     => 'application/pdf',
                    p_File_Description   => NULL,
                    p_File_Create_Dt     => SYSDATE,
                    p_File_Wu            => NULL,
                    p_File_App           => 1,
                    p_File_Hash          =>
                        Ikis_Rbm.Tools.Hash_Md5 (l_File_Content),
                    p_File_Size          =>
                        DBMS_LOB.Getlength (l_File_Content),
                    p_File_Cu            => Rec.At_Cu,
                    p_New_Id             => l_File_Id);

                DBMS_OUTPUT.Put_Line (l_File_Code);
            /*
                    Uss_Cea.Api$file_Content.Save(p_Fc_Id      => l_File_Id,
                                                  p_Fc_Content => l_File_Content,
                                                  p_Fc_Code    => l_File_Code,
                                                  p_New_Id     => l_File_Id);
            */
            /*
                    Uss_Doc.Dnet$documents.Save_Attachment(p_Doc_Id        => l_Doc_Id,
                                                           p_Dat_Num       => 1,
                                                           p_Dat_File      => l_File_Id,
                                                           p_Dat_Dh        => l_Dh_Id,
                                                           p_Dat_Sign_File => NULL,
                                                           p_Dat_Hs        => Uss_Doc.Tools.Gethistsession(p_Hs_Cu => Rec.At_Cu),
                                                           p_New_Id        => l_Dat_Id);
            */
            END;
        END LOOP;
    END;
--===============================================================--
BEGIN
    NULL;
END Cmes$act_Ndis;
/