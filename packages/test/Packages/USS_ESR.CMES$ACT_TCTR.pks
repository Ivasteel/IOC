/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_TCTR
IS
    -- Author  : SHOSTAK
    -- Created : 27.06.2023 7:25:57 PM
    -- Purpose : Робота з типовим договором про надання соціальних послуг

    Pkg               CONSTANT VARCHAR2 (30) := 'CMES$ACT_TCTR';

    c_Tctr_Form_Ndt   CONSTANT NUMBER := 858;

    TYPE r_Act IS RECORD
    (
        At_Pc              Act.At_Pc%TYPE,
        At_Dt              TIMESTAMP,
        At_Org             Act.At_Org%TYPE,
        At_Sc              Act.At_Sc%TYPE,
        At_Ap              Act.At_Ap%TYPE,
        At_Rnspm           Act.At_Rnspm%TYPE,
        at_live_address    act.at_live_address%TYPE,
        At_Decision        NUMBER,
        At_Calc_Tp         VARCHAR2 (1000)
    );

    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER);

    FUNCTION get_ss_cnt (p_At_Id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Attrs      IN     CLOB,
                        p_At_Persons    IN     CLOB,
                        p_At_Services   IN     CLOB,
                        p_At_Signers    IN     CLOB);

    FUNCTION Get_Receiver_Ndt (p_At_Id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,
                           p_At_Dt_Stop     IN     DATE,
                           p_At_Num         IN     VARCHAR2,
                           p_At_St          IN     VARCHAR2,
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Acts              OUT SYS_REFCURSOR,
                           p_Attrs             OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Rc (p_At_Dt_Start   IN     DATE,
                           p_At_Dt_Stop    IN     DATE,
                           p_At_Num        IN     VARCHAR2,
                           p_At_St         IN     VARCHAR2,
                           --4) Надавач соціальних послуг з яким укладено договір
                           p_Nsp_Name      IN     VARCHAR2,
                           --6) Наявність документів на підпис
                           p_Need_Sign     IN     VARCHAR2,
                           p_Acts             OUT SYS_REFCURSOR,
                           p_Attrs            OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           --4) ПІБ відповідальної особи, якою сформовано Договір
                           p_Creator_Pib     IN     VARCHAR2,
                           --5) ПІБ отримувача соціальної послуги
                           p_Receiver_Pib    IN     VARCHAR2,
                           --6) ПІБ законного представника / уповноваженої особи ОСП
                           p_Agent_Pib       IN     VARCHAR2,
                           --8) Наявність документів на підпис
                           p_Need_Sign       IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Acts               OUT SYS_REFCURSOR,
                           p_Attrs              OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR,
                              p_Attrs              OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Svc_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Services_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Send_To_Rc (p_At_Id IN NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Cancel_Reason IN VARCHAR2);

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Decline_Reason IN VARCHAR2);

    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     );

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER);
END Cmes$act_Tctr;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_TCTR TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_TCTR TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_TCTR TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_TCTR TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_TCTR
IS
    g_Nda_Map   Api$act.t_Nda_Map;


    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;


    PROCEDURE logS (p_src VARCHAR2, p_regular_params VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        BEGIN
            l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        tools.logSes (
            Pkg || '.' || UPPER (p_src),
               'cu_Id='
            || l_Cu_Id
            || CHR (13)
            || CHR (10)
            || 'sc_Id='
            || l_Sc_Id
            || CHR (13)
            || CHR (10)
            || p_regular_params);
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
               AND d.Atd_Ndt = c_Tctr_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => c_Tctr_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => l_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => c_Tctr_Form_Ndt,
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
                     c_Tctr_Form_Ndt,
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

        g_Nda_Map (3592) := 'At_Sign_Address';
        g_Nda_Map (2820) := 'At_Spec_Name';
        g_Nda_Map (3691) := 'At_Spec_Position';
        -- g_Nda_Map(2819) := 'At_Rnsp_Name'; -- НЕ ТОЙ ДОКУМЕНТ
        -- g_Nda_Map(3694) := 'At_Rnsp_Name_Short'; -- НЕ ТОЙ ДОКУМЕНТ
        g_Nda_Map (3593) := 'At_Rnsp_Addres_Fact';
        g_Nda_Map (3594) := 'At_Rnsp_Phone';
        g_Nda_Map (3595) := 'At_Rsnp_Iban';
        g_Nda_Map (3596) := 'At_Rnsp_Edrpou';
        --g_Nda_Map(3597) := 'At_Receiver_Address_Reg';
        --g_Nda_Map(3598) := 'At_Receiver_Address_Fact';
        g_Nda_Map (3599) := 'At_Receiver_Rnokpp';
        --g_Nda_Map(3600) := 'At_Receiver_Phone';

        g_Nda_Map (3614) := 'At_Rnsp_Doc_Ndt';
        g_Nda_Map (3615) := 'At_Rnsp_Doc_Num';
        g_Nda_Map (3616) := 'At_Receiver_Doc_Ndt';
        g_Nda_Map (3617) := 'At_Receiver_Doc_Num';

        g_Nda_Map (3692) := 'At_Service_Tarif_Sum';
        g_Nda_Map (3693) := 'At_Service_Act_Sum';
        g_Nda_Map (8455) := 'At_Non_State_Sector_Money';

        g_Nda_Map (8472) := 'At_Rnsp_Spec_Position';
    END;

    -----------------------------------------------------------
    --        ЗБЕРЕЖЕННЯ ДОГОВОРУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id         IN OUT NUMBER,
                        p_At_Src        IN     VARCHAR2,
                        p_Act           IN     CLOB,
                        p_At_Attrs      IN     CLOB,
                        p_At_Persons    IN     CLOB,
                        p_At_Services   IN     CLOB,
                        p_At_Signers    IN     CLOB)
    IS
        l_Cu_Id             NUMBER;
        l_At_Cu             NUMBER;
        l_At_St_Old         VARCHAR2 (10);
        l_Already_Exist     NUMBER;
        l_Act               r_Act;
        l_Persons           Api$act.t_At_Persons;
        l_Services          Api$act.t_At_Services;
        l_Signers           Api$act.t_At_Signers;
        l_Atd_Id            NUMBER;
        l_Attrs             Api$act.t_At_Document_Attrs;
        l_pdsp_id           NUMBER;
        l_ats_forbid        NUMBER;
        l_ats_forbid_list   VARCHAR2 (2000);
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        tools.set_nls ();

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

        IF     l_Act.At_Decision IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Decision)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано рішення по іншому надавачу');
        END IF;

        --Редагування договору
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

            IF NVL (l_At_St_Old, '-') <> 'DN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування договру в поточному статусі заборонено');
            END IF;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'TCTR'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_Rnspm = l_Act.At_Rnspm
               AND a.At_St NOT IN ('DR', 'DD')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Already_Exist = 1
        THEN
            Raise_Application_Error (-20000,
                                     'По цьому випадку вже існує договір');
        END IF;

        SELECT MAX (at_id)
          INTO l_pdsp_id
          FROM act
         WHERE at_tp = 'PDSP' AND at_ap = l_Act.At_Ap;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Services := Api$act.Parse_Services (p_At_Services);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (p_At_Id             => p_At_Id,
                          p_At_Tp             => 'TCTR',
                          p_At_Pc             => l_Act.At_Pc,
                          p_At_Num            => NULL,
                          p_At_Dt             => l_Act.At_Dt,
                          p_At_Org            => l_Act.At_Org,
                          p_At_Sc             => l_Act.At_Sc,
                          p_At_Rnspm          => l_Act.At_Rnspm,
                          p_At_Rnp            => NULL,
                          p_At_Ap             => l_Act.At_Ap,
                          p_At_St             => 'DN',
                          p_At_Src            => p_At_Src,
                          p_At_Main_Link_Tp   => 'DECISION',
                          p_At_Main_Link      => l_Act.At_Decision,
                          p_At_Notes          => l_Act.At_Calc_Tp,
                          p_At_Live_Address   => l_act.at_live_address,
                          p_At_Cu             => l_Cu_Id,
                          p_New_Id            => p_At_Id);

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Services (p_At_Id => p_At_Id, p_Services => l_Services);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);

        --#117081
        SELECT COUNT (1),
               LISTAGG (nst.nst_name || '(' || nst.nst_id || ')', ',')
          INTO l_ats_forbid, l_ats_forbid_list
          FROM at_service  ats
               JOIN uss_Ndi.v_Ndi_Service_Type nst ON ats_nst = nst_id
         WHERE     ats_at = p_At_Id
               AND ats_nst IN (401, 403, 420)
               AND ats.HISTORY_STATUS = 'A'
               AND nst.history_status = 'A';

        IF l_ats_forbid = 1
        THEN
            Raise_Application_Error (
                -20000,
                   'В документ заборонено додавати послуги ['
                || l_ats_forbid_list
                || ']');
        END IF;


        Map_Nda2act;
        l_Atd_Id := Get_Form_Doc (p_At_Id);
        Api$act.Save_Attributes (p_At_Id     => p_At_Id,
                                 p_Atd_Id    => l_Atd_Id,
                                 p_Attrs     => l_Attrs,
                                 p_Nda_Map   => g_Nda_Map);

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (p_at_id    => p_At_Id,
                                  p_ndt_id   => c_Tctr_Form_Ndt);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'DN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_At_Id     => p_At_Id,
                                p_Atd_Ndt   => c_Tctr_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => c_Tctr_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;


    -----------------------------------------------------------
    --          ОТРИМАННЯ ТИПУ ДОКУМЕНТУ ОСП
    -----------------------------------------------------------
    FUNCTION Get_Receiver_Ndt (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ndt_Id   NUMBER;
    BEGIN
        SELECT apd_ndt
          INTO l_Ndt_Id
          FROM (  SELECT apd_ndt
                    FROM (SELECT dd.apd_ndt,
                                 (SELECT COUNT (1)
                                    FROM ap_document_attr dda
                                   WHERE     dda.apda_apd = dd.apd_id
                                         AND dda.apda_val_string =
                                             Uss_Person.Api$sc_Tools.get_doc_num (
                                                 a.At_Sc))    qty
                            FROM Act a
                                 JOIN appeal al ON a.at_ap = al.ap_id
                                 JOIN ap_person app
                                     ON     app.app_ap = al.ap_id
                                        AND app.app_sc = a.at_sc
                                 JOIN ap_document dd ON dd.apd_app = app.app_id
                           WHERE a.At_Id = p_At_Id)
                ORDER BY qty DESC, apd_ndt)
         WHERE ROWNUM = 1;

        RETURN l_Ndt_Id;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION get_ss_cnt (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM act pdsp JOIN at_service s ON (s.ats_at = pdsp.at_id)
         WHERE     pdsp.at_id = p_At_Id
               AND s.history_status = 'A'
               AND s.ats_ss_term = 'P'
               AND s.ats_st IN ('P', 'SG')
               AND s.ats_nst NOT IN (401, 403, 420);

        RETURN l_cnt;
    END;

    -----------------------------------------------------------
    --          ОТРИМАННЯ ОСНОВНИХ ДАНИХ ДОГОВОРУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   NULL         /*Api$act.Get_At_Spec_Name(a.At_Wu, a.At_Cu)*/
                       AS At_Spec_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   /*a.At_Main_Link AS At_Ip,*/
                   a.At_Notes
                       AS At_Calc_Tp,
                   a.At_Main_Link
                       AS At_Decision,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   Uss_esr.Cmes$act_Tctr.Get_Receiver_Ndt (a.At_Id)
                       AS at_receiver_doc_ndt,
                   Uss_Person.Api$sc_Tools.get_doc_num (a.At_Sc)
                       AS at_receiver_doc_num,
                   Uss_Person.Api$sc_Tools.get_numident (a.At_Sc)
                       AS at_receiver_rnokpp,
                   CASE
                       WHEN r.RNSPM_TP = 'O'
                       THEN
                           r.RNSPS_LAST_NAME
                       ELSE
                              r.RNSPS_LAST_NAME
                           || ' '
                           || r.RNSPS_FIRST_NAME
                           || ' '
                           || r.RNSPS_MIDDLE_NAME
                   END
                       AS At_Rnsp_Name,
                   r.RNSPS_NUMIDENT
                       AS At_Rnsp_Edrpou,
                   r.RNSPO_PHONE
                       AS At_Rnsp_Phone,
                   CASE
                       WHEN get_ss_cnt (a.at_main_link) > 1
                       THEN
                           (SELECT MAX (z.at_id)
                              FROM act z
                             WHERE     z.at_main_link = a.at_main_link
                                   AND z.at_tp = 'IP'
                                   AND z.at_st NOT IN ('ID', 'IR', 'IA'))
                       ELSE
                           (SELECT MAX (ip.at_id)
                              FROM act  zp                             -- PDSP
                                   JOIN act z ON (z.at_main_link = zp.at_id) -- AVOP
                                   JOIN act ip ON (ip.at_main_link = z.at_id) -- IP
                             WHERE     zp.at_id = a.at_main_link
                                   AND z.at_tp = 'AVOP'
                                   AND ip.at_tp = 'IP'
                                   AND ip.at_st NOT IN ('ID', 'IR', 'IA'))
                   END
                       AS at_ip_id,
                   api$act.Get_Atd_Attach_Source (a.at_id, c_tctr_form_ndt)
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Tctr_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Rnsp.v_Rnsp r ON a.At_Rnspm = r.Rnspm_Id
             WHERE a.At_Id = p_At_Id AND A.AT_TP = 'TCTR';
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ ДОГОВОРІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Ip,
                   a.At_Notes
                       AS At_Calc_Tp,
                   a.At_Main_Link
                       AS At_Decision,
                   d.At_Num
                       AS At_Decision_Num,
                   --11) ПІБ отримувача соціальної послуги #91585
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   Uss_esr.Cmes$act_Tctr.Get_Receiver_Ndt (a.At_Id)
                       AS at_receiver_doc_ndt,
                   Uss_Person.Api$sc_Tools.get_doc_num (a.At_Sc)
                       AS at_receiver_doc_num,
                   Uss_Person.Api$sc_Tools.get_numident (a.At_Sc)
                       AS at_receiver_rnokpp,
                   --12) ПІБ законного представника / уповноваженої особи ОСП #91585
                    (SELECT Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc)
                       FROM Ap_Person p
                      WHERE     p.App_Ap = a.At_Ap
                            AND p.history_status = 'A'
                            AND p.App_Tp = 'Z'
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM Ap_Person Pp
                                      WHERE     Pp.App_Ap = a.At_Ap
                                            AND Pp.History_Status = 'A'
                                            AND Pp.App_Tp = 'OS'))
                       AS At_Agent_Pib,
                   api$act.Get_Atd_Attach_Source (a.at_id, c_tctr_form_ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Tctr_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Rnsp.v_Rnsp r ON a.At_Rnspm = r.Rnspm_Id
                   LEFT JOIN Act d ON a.At_Main_Link = d.At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ДОГОВОРІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,
                           p_At_Dt_Stop     IN     DATE,
                           p_At_Num         IN     VARCHAR2,
                           p_At_St          IN     VARCHAR2,
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Acts              OUT SYS_REFCURSOR,
                           p_Attrs             OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_Cm',
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
                || p_At_Ap);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'TCTR'
                   AND a.At_Cu = l_Cu_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap);

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ДОГОВОРІВ ДЛЯ ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Rc (p_At_Dt_Start   IN     DATE,
                           p_At_Dt_Stop    IN     DATE,
                           p_At_Num        IN     VARCHAR2,
                           p_At_St         IN     VARCHAR2,
                           --4) Надавач соціальних послуг з яким укладено договір
                           p_Nsp_Name      IN     VARCHAR2,
                           --6) Наявність документів на підпис
                           p_Need_Sign     IN     VARCHAR2,
                           p_Acts             OUT SYS_REFCURSOR,
                           p_Attrs            OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_Rc',
            p_obj_tp   => 'CMES_CU_SC',
            p_obj_id   => l_Cu_Sc,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ' p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_At_St='
                || p_At_St
                || ' p_Nsp_Name='
                || p_Nsp_Name
                || ' p_Need_Sign='
                || p_Need_Sign);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, де поточний користувач є серед підписантів,
        --та які хоч раз переводились до стану "Очікує підписання"
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM At_Signers s
                                 WHERE     s.Ati_At = a.At_Id
                                       AND s.History_Status = 'A'
                                       AND s.Ati_Sc = l_Cu_Sc))
                   AND a.At_Tp = 'TCTR'
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   --За постановкою ЖХ видаєо тільки договора що укладені обома сторонами
                   AND a.At_St NOT IN ('DN',
                                       'DD',
                                       'DR',
                                       'DV',
                                       'DS')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   --region #111073
                   --AND EXISTS (SELECT 1
                   --       FROM At_Log l
                   --      WHERE l.Atl_At = a.At_Id
                   --        AND l.Atl_St = 'DV')
                   --end region #111073

                   AND (   p_Nsp_Name IS NULL
                        OR UPPER (
                               Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)) LIKE
                               UPPER (p_Nsp_Name) || '%')
                   --6) Наявність документів на підпис
                   AND (   NVL (p_Need_Sign, 'F') = 'F'
                        OR EXISTS
                               (SELECT 1
                                  FROM Act i
                                 WHERE     i.At_Ap = a.At_Ap
                                       AND a.At_Rnspm = i.At_Rnspm
                                       AND i.At_St IN ('IK')));

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ДОГОВОРІВ ДЛЯ НАДАВАЧА #91585
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           --4) ПІБ відповідальної особи, якою сформовано Договір
                           p_Creator_Pib     IN     VARCHAR2,
                           --5) ПІБ отримувача соціальної послуги
                           p_Receiver_Pib    IN     VARCHAR2,
                           --6) ПІБ законного представника / уповноваженої особи ОСП
                           p_Agent_Pib       IN     VARCHAR2,
                           --8) Наявність документів на підпис
                           p_Need_Sign       IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Acts               OUT SYS_REFCURSOR,
                           p_Attrs              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');
        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_Pr',
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
                || ' p_Creator_Pib='
                || p_Creator_Pib
                || ' p_Receiver_Pib='
                || p_Receiver_Pib
                || ' p_Agent_Pib='
                || p_Agent_Pib
                || ' p_Need_Sign='
                || p_Need_Sign);

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_Pr',
                       p_obj_tp           => 'CMES_OWNER_ID',
                       p_obj_id           => p_Cmes_Owner_Id,
                       p_regular_params   => 'Insufficient privileges.');
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Rnspm = p_Cmes_Owner_Id
                   AND a.At_Tp = 'TCTR'
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   --За постановкою ЖХ видаєо тільки договора що укладені обома сторонами
                   AND a.At_St NOT IN ('DN',
                                       'DD',
                                       'DR',
                                       'DV',
                                       'DS')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   --8) Наявність документів на підпис
                   AND (   NVL (p_Need_Sign, 'F') = 'F'
                        OR EXISTS
                               (SELECT 1
                                  FROM Act i
                                 WHERE     i.At_Ap = a.At_Ap
                                       AND a.At_Rnspm = i.At_Rnspm
                                       AND i.At_St IN ('IK')
                                UNION ALL
                                SELECT 1
                                  FROM At_Links  l
                                       JOIN Act La
                                           ON     l.Atk_At = La.At_Id
                                              AND La.At_St IN
                                                      ('NV', 'MV.N', 'RS.N')
                                 WHERE     l.Atk_Link_At = a.At_Id
                                       AND l.Atk_Tp = 'TCTR'
                                UNION ALL
                                SELECT 1
                                  FROM Act Aa
                                 WHERE     Aa.At_Main_Link = a.At_Id
                                       AND Aa.At_St IN ('EV', 'TV')))
                   --4) ПІБ відповідальної особи, якою сформовано Договір
                   AND (   p_Creator_Pib IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM Ikis_Rbm.v_Cmes_Users u
                                 WHERE     u.Cu_Id = a.At_Cu
                                       AND UPPER (u.Cu_Pib) LIKE
                                               UPPER (p_Creator_Pib) || '%'))
                   --5) ПІБ отримувача соціальної послуги
                   AND (   p_Receiver_Pib IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM Uss_Person.v_Sc_Info i
                                 WHERE     i.Sco_Id = a.At_Sc
                                       AND UPPER (
                                                  i.Sco_Ln
                                               || ' '
                                               || i.Sco_Fn
                                               || ' '
                                               || i.Sco_Ln) LIKE
                                               UPPER (p_Receiver_Pib) || '%'))
                   --6) ПІБ законного представника / уповноваженої особи ОСП
                   AND (   p_Agent_Pib IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM Ap_Person  p
                                       JOIN Uss_Person.v_Sc_Info i
                                           ON p.App_Sc = i.Sco_Id
                                 WHERE     p.App_Ap = a.At_Ap
                                       AND p.App_Tp IN ('OR', 'OP', 'AF')
                                       AND UPPER (
                                                  i.Sco_Ln
                                               || ' '
                                               || i.Sco_Fn
                                               || ' '
                                               || i.Sco_Ln) LIKE
                                               UPPER (p_Agent_Pib) || '%'));

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
    --    ОТРИМАННЯ ПЕРЕЛІКУ ДОГОВОРІВ ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR,
                              p_Attrs              OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap, a.At_Main_Link
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'DR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'TCTR'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               --#107427
                               AND a.At_St NOT IN ('DD', 'DN'))
                 WHERE Rn = 1;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap, a.At_Main_Link
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'DR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'TCTR'
                               --#107427
                               AND a.At_St NOT IN ('DD', 'DN')
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
                                               AND l.Atl_St IN ('DV', 'DS')))
                 WHERE Rn = 1;
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_TCTR.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
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
    --         ОТРИМАННЯ ПОСЛУГ
    -----------------------------------------------------------
    PROCEDURE Get_Services (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*,
                   t.Nst_Name                                          AS Ats_Nst_Name,
                   m.Dic_Name                                          AS Ats_Ss_Method_Name,
                   At.Dic_Name                                         AS Ats_Ss_Address_Tp_Name,
                   St.Dic_Name                                         AS Ats_St_Name,
                   uss_rnsp.api$find.get_address_name (s.ats_rnspa)    AS ats_rnspa_name
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
                   JOIN Uss_Ndi.v_Ddn_Tctr_Ats_St St
                       ON s.Ats_St = St.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Ss_Method m
                       ON s.Ats_Ss_Method = m.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Rnsp_Adr_Tp At
                       ON s.Ats_Ss_Address_Tp = At.Dic_Value
             WHERE s.Ats_At = p_At_Id AND s.history_status = 'A';
    END;

    PROCEDURE Get_Services_By_Ap (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.nst_id, t.Nst_Name AS Ats_Nst_Name
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
                   JOIN Act a ON s.ats_at = a.at_id
             WHERE     a.at_ap = p_Ap_Id
                   AND a.at_tp = 'TCTR'
                   AND s.history_status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ДОГОВОРУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Svc_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_TCTR.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => NULL);
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'TCTR');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Get_Services (p_At_Id, p_Svc_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Attributes (p_At_Id, p_Attrs_Cur);
    END;

    -----------------------------------------------------------
    --     ПОБУДОВА ДРУКОВАНОЇ ФОРМИ
    -----------------------------------------------------------
    FUNCTION Build_Form (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        l_Jbr_Id   NUMBER;
        l_Result   BLOB;
        l_Atd_Id   NUMBER;

        --Використовувати для полів, які зберігаються в атрибути документа
        --(перелік можна подивитись в процедурі Map_Nda2act)
        FUNCTION Attr_Str (p_Field VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN Api$act.Get_Attr_Val_Str (p_Atd_Id    => l_Atd_Id,
                                             p_Field     => p_Field,
                                             p_Nda_Map   => g_Nda_Map);
        END;
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'TCTR_FORM',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);
        Map_Nda2act;

        FOR Rec
            IN (SELECT a.*, d.Atd_Id
                  FROM Act  a
                       JOIN At_Document d
                           ON     a.At_Id = d.Atd_At
                              AND d.Atd_Ndt = c_Tctr_Form_Ndt
                              AND d.History_Status = 'A'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            l_Atd_Id := Rec.Atd_Id;
            Rdm$rtfl_Univ.Addparam ('at_num', Rec.At_Num);
            Rdm$rtfl_Univ.Addparam ('at_dt',
                                    TO_CHAR (Rec.At_Dt, 'dd.mm.yyyy'));
            Rdm$rtfl_Univ.Addparam ('at_sign_address',
                                    Attr_Str ('at_sign_address'));
            Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                             p_Rpt_Blob   => l_Result);

            RETURN l_Result;
        END LOOP;
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
                               p_Form_Ndt    => c_Tctr_Form_Ndt,
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
            p_Form_Ndt               => c_Tctr_Form_Ndt,
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ ДОГОВОРУ
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
                               p_At_Prj_St         => 'DN',
                               p_Form_Ndt          => l_Ndt_Id, --c_Tctr_Form_Ndt,
                               p_Form_Build_Proc   => l_Build_Proc, --'Api$act_Rpt.Build_Tctr',
                               p_Doc_Cur           => p_Doc_Cur);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => c_Tctr_Form_Ndt,
                              p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
    BEGIN
        Api$act.Get_Form_Doc_Src (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => c_Tctr_Form_Ndt,
                                  p_Doc_Src   => p_Doc_Src);
    END;

    -----------------------------------------------------------
    -- "ВІДПРАВКА" ДОГОВОРУ ДО ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Send_To_Rc (p_At_Id IN NUMBER, p_Messages OUT SYS_REFCURSOR)
    IS
        --l_doc_Attach_Src VARCHAR2(10);
        l_st   VARCHAR2 (10) := 'DV';
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Send_To_Rc');
        Check_Act_Access (p_At_Id);

        --Виконуємо зміну статуса лише у разі, якщо проект акту пройшов всі контролі
        IF Api$act_Validation.Validate_Act (p_At_Id, p_Messages)
        THEN
            /*Get_Form_Doc_Src(p_at_id, l_doc_Attach_Src);
            IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T') THEN
              l_st := 'DS';
              Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id, p_Ndt_Id => c_Tctr_Form_Ndt);
            ELSIF (l_doc_Attach_Src = 'TABLET' AND l_is_used = 'T' AND Api$act.Is_All_Signed(p_At_Id => p_At_Id, p_Ati_Tp => 'RC')) THEN
              l_st := 'DS';
            END IF;*/
            api$act.Handle_Cm_Sign (p_at_id,
                                    l_st,
                                    'DS',
                                    c_tctr_form_ndt,
                                    l_st);

            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'DN',
                p_At_St_New   => l_st,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка договору отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ ДОГОВОРУ
    -- ОТРИМУВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Rc');
        Cmes$act.Set_Signed_Rc (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => c_Tctr_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'DV',
                p_At_St_New   => 'DS',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ ДОГОВОРУ
    -- НАДАВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Tools.Start_Log_Ses_Id ('TCTR', p_At_Id);
        logS ('Set_Signed_Pr', 'p_At_Id = ' || p_At_Id);

        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => c_Tctr_Form_Ndt,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'DS',
            p_At_St_New   => 'DT',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        --Для всіх рішень по зверненню до якого привязаний акт з таким самим НСП
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St = 'SI'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);
        END LOOP;

        -- Це костиль, але зараз немає часу розбиратись, чому не відпрацювало  корректно
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'PDSP'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            CMES$CALENDAR.Init_Calendar_PDSP (Rec.Decision_Id);
        END LOOP;

        --Для всіх індивідуальних планів по зверненню до якого привязаний акт з таким самим НСП
        FOR Rec
            IN (SELECT d.At_Id     AS Ip_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'IP'
                              AND d.At_St = 'IP'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус інд. плану на "Діючий план"
            UPDATE Act a
               SET a.At_St = 'IT'
             WHERE a.At_Id = Rec.Ip_Id AND a.At_St = 'IP';

            IF SQL%ROWCOUNT = 1
            THEN
                Api$act.Write_At_Log (
                    p_Atl_At        => Rec.Ip_Id,
                    p_Atl_Hs        => Tools.Gethistsessioncmes (),
                    p_Atl_St        => 'IT',
                    p_Atl_Message   => CHR (38) || '254',
                    p_Atl_St_Old    => 'IP');
            END IF;
        END LOOP;

        Tools.Stop_Log_Ses_Id;
    END;


    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ В СТАН
    -- "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Cancel_Reason IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Canceled');

        IF p_Cancel_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину скасування');
        END IF;

        Cmes$act.Check_Act_Access_Cm (p_At_Id);

        Api$act.Set_At_St (
            p_At_Id          => p_At_Id,
            p_At_St_Old      => 'DN',
            p_At_St_New      => 'DD',
            p_Log_Msg        => CHR (38) || '230#' || p_Cancel_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД ДОГОВОРУ В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Decline_Reason IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_At_St   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Declined');

        IF p_Decline_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину відхилення');
        END IF;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_At_St := Api$act.Get_At_St (p_At_Id);

        IF    --Якщо стан акту "Очікує підписання" - дозволяемо змінювати стан, лише якщо поточний користувач є серед підписантів
              (    l_At_St = 'DV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'DS'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'DR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'DR',
                p_Atl_Message   => CHR (38) || '231#' || p_Decline_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;

    -----------------------------------------------------------
    --    ПЕРЕНАЗНАЧЕННЯ ДОГОВОРУ НА ІНШОГО КЕЙС МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     )
    IS
        l_At_St       VARCHAR2 (10);
        l_At_Rnspm    NUMBER;
        l_Old_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Change_Act_Cm');

        SELECT a.At_Rnspm, a.At_Cu
          INTO l_At_Rnspm, l_Old_Cu_Id
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Дозволяємо виконання операції лише для користувача надавача за яким закріплено акт
        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => l_At_Rnspm,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

           UPDATE Act a
              SET a.At_Cu = p_New_Cu_Id
            WHERE a.At_Id = p_At_Id
        RETURNING a.At_St
             INTO l_At_St;

        --#113948
        UPDATE At_Calendar ac
           SET ac.atc_cu = p_New_Cu_Id
         WHERE ac.atc_at = p_At_Id AND ac.atc_is_km_ok IS NULL;

        Api$act.Write_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Hs        => Tools.Gethistsessioncmes (),
            p_Atl_St        => l_At_St,
            p_Atl_Message   =>
                   CHR (38)
                || '241#'
                || Ikis_Rbm.Tools.Getcupib (l_Old_Cu_Id)
                || '#'
                || Ikis_Rbm.Tools.Getcupib (p_New_Cu_Id),
            p_Atl_St_Old    => NULL);
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
END Cmes$act_Tctr;
/