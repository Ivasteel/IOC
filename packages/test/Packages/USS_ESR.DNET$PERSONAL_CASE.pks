/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PERSONAL_CASE
IS
    -- Author  : BOGDAN
    -- Created : 27.07.2021 12:21:32
    -- Purpose : ЕОС

    --Атрибути докумена

    Package_Name   VARCHAR2 (100) := 'DNET$PERSONAL_CASE';

    TYPE r_Pd_Document_Attr IS RECORD
    (
        Pdoa_Id            Pd_Document_Attr.Pdoa_Id%TYPE,
        Pdoa_Nda           Pd_Document_Attr.Pdoa_Nda%TYPE,
        Pdoa_Val_String    Pd_Document_Attr.Pdoa_Val_String%TYPE,
        Pdoa_Val_Int       Pd_Document_Attr.Pdoa_Val_Int%TYPE,
        Pdoa_Val_Dt        TIMESTAMP,
        Pdoa_Val_Id        Pd_Document_Attr.Pdoa_Val_Id%TYPE,
        Pdoa_Val_Sum       Pd_Document_Attr.Pdoa_Val_Sum%TYPE,
        Pdoa_Pdo           Pd_Document_Attr.Pdoa_Pdo%TYPE,
        Deleted            NUMBER
    );

    TYPE t_Pd_Document_Attrs IS TABLE OF r_Pd_Document_Attr;

    -- #70663: журнал особових справ
    PROCEDURE Get_Journal (p_Pc_Num               IN     VARCHAR2,
                           p_Sc_Unique            IN     VARCHAR2,
                           p_Sc_Numident          IN     VARCHAR2,
                           p_Sc_Pib               IN     VARCHAR2,
                           p_Pc_Create_Dt_Start   IN     DATE,
                           p_Pc_Create_Dt_Stop    IN     DATE,
                           p_Aps_Nst              IN     NUMBER,
                           p_Pdp_Npt              IN     NUMBER,
                           p_Org_Id               IN     NUMBER,
                           p_Is_Decision_Active   IN     VARCHAR2,
                           -- передвстановлені фільтри від Підготовка до масового нарахування
                           p_Pd_Nst               IN     NUMBER,
                           p_Month                IN     DATE,
                           p_Nis_Id               IN     NUMBER,
                           p_Mode                 IN     NUMBER,
                           Res_Cur                   OUT SYS_REFCURSOR);

    -- #77394: Реєстр отримувачів соціальних послуг
    PROCEDURE Get_Journal_Sp (p_Pc_Num               IN     VARCHAR2, -- № ЕОС
                              p_Sc_Unique            IN     VARCHAR2, --ЄСР ІД
                              p_Sc_Numident          IN     VARCHAR2, --РНОКПП
                              p_Sc_Pib               IN     VARCHAR2,    --ПІБ
                              p_Pc_Create_Dt_Start   IN     DATE, --Створено з
                              p_Pc_Create_Dt_Stop    IN     DATE, --Створено по
                              p_Aps_Nst              IN     NUMBER, --Соціальна послуга
                              p_Scd_Ser_Num          IN     VARCHAR2, --Серія  та номер паспорту
                              p_Rnspm_Id             IN     NUMBER, -- Надавач
                              p_is_blocked           IN     VARCHAR2, -- (T/F) Припинено надання соціальних послуг
                              p_org_id               IN     NUMBER,    -- ОСЗН
                              Res_Cur                   OUT SYS_REFCURSOR);

    -- #70663: картка особової справи
    PROCEDURE Get_Card (p_Pc_Id     IN     NUMBER,
                        Info_Cur       OUT SYS_REFCURSOR,
                        Doc_Cur        OUT SYS_REFCURSOR,
                        Attr_Cur       OUT SYS_REFCURSOR,
                        Files_Cur      OUT SYS_REFCURSOR,
                        Dec_Cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Card_Sc (p_sc_id IN NUMBER, p_cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Main_Info (p_Pc_Id IN NUMBER, Info_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Documents (p_Pc_Id     IN     NUMBER,
                             Doc_Cur        OUT SYS_REFCURSOR,
                             Attr_Cur       OUT SYS_REFCURSOR,
                             Files_Cur      OUT SYS_REFCURSOR);

    -- #70749: список документів по зверненню
    PROCEDURE Get_Documents_Ap (p_Ap_Id     IN     NUMBER,
                                Doc_Cur        OUT SYS_REFCURSOR,
                                Attr_Cur       OUT SYS_REFCURSOR,
                                Files_Cur      OUT SYS_REFCURSOR);

    -- 74847 : список документів по зверненню
    -- params: p_ap_id       - ідентифікатор обращения
    -- params: p_first_ap_id - ідентифікатор первичного обращения
    PROCEDURE Get_Documents (p_Ap_Id         IN     NUMBER,
                             p_First_Ap_Id   IN     NUMBER,
                             Doc_Cur            OUT SYS_REFCURSOR,
                             Attr_Cur           OUT SYS_REFCURSOR,
                             Files_Cur          OUT SYS_REFCURSOR);

    PROCEDURE Get_Decisions (p_Pc_Id IN NUMBER, Dec_Cur OUT SYS_REFCURSOR);

    -- info: налаштування атрибутів по типу документа
    -- params:
    -- note:
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------
    --                   ДОВІДНИК ГРУП АТРИБУТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR);

    -- журнал зміни статусів звернення
    PROCEDURE Get_Ap_Log (p_Ap_Id            Appeal.Ap_Id%TYPE,
                          p_Log_Cursor   OUT SYS_REFCURSOR);

    -- інформація по виплаті
    PROCEDURE Get_Decision_Info (p_Pd_Id   IN     NUMBER,
                                 Res_Cur      OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------
    --                   ДЕРЖ УТРИМАННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_State_Withholdings (p_Pc_Id        Personalcase.Pc_Id%TYPE,
                                      p_Sa_Cur   OUT SYS_REFCURSOR,
                                      p_Pc_Cur   OUT SYS_REFCURSOR);

    -- Протокол обробки Держ.утримання
    PROCEDURE GET_ALIMONY_LOG (P_PS_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------
    --                   ВІДРАХУВАННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Deductions (p_Pc_Id         Personalcase.Pc_Id%TYPE,
                              p_Dn_Cur    OUT SYS_REFCURSOR,
                              p_Dnd_Cur   OUT SYS_REFCURSOR);

    PROCEDURE Get_Deduction_Log (p_Dn_Id   IN     NUMBER,
                                 Res_Cur      OUT SYS_REFCURSOR);

    -- #83453
    PROCEDURE Get_Overpayment (p_Pc_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Queue_Recalc (p_Paq_Pc   IN     NUMBER,
                                Res_Cur       OUT SYS_REFCURSOR);


    --======================================================--
    --  Продвинути стан відарахування
    --======================================================--
    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE);

    --======================================================--
    --  Продвинути стан держутримання
    --======================================================--
    PROCEDURE Approve_State_Alimony (p_Ps_Id Pc_State_Alimony.Ps_Id%TYPE);

    --======================================================--
    --  Повернути стан відрахування на попереднью позицію
    --======================================================--
    PROCEDURE reject_deduction (p_dn_id       pc_state_alimony.ps_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL);

    --======================================================--
    --  Повернути стан держутримання на попереднью позицію
    --======================================================--
    PROCEDURE Reject_State_Alimony (p_Ps_Id       Pc_State_Alimony.Ps_Id%TYPE,
                                    p_Reason   IN VARCHAR2 := NULL);

    --======================================================--
    --  #101154: Закрити держутримання
    --======================================================--
    PROCEDURE close_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE);

    --======================================================--
    --  #101154: Відновити держутримання
    --======================================================--
    PROCEDURE reopen_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE);

    PROCEDURE Get_Soc_Services (p_Pc_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    --------------------------------------------------------------------------
    --     Реєстраційна справа отримувача #78140
    --------------------------------------------------------------------------
    PROCEDURE Get_Rec_Info (p_Pc_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    --------------------------------------------------------------------------
    ---------------------Інформація про звернення та рішення #78140
    --------------------------------------------------------------------------
    PROCEDURE Get_App_Dec_Info (p_Pc_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    -- #81063: "Історія перебування в ОСЗН"
    PROCEDURE Get_Org_History (p_Pc_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    PROCEDURE Register_Doc_Hist (p_Doc_Id NUMBER, p_Dh_Id OUT NUMBER);

    -- #81511: Оцінка потреб
    PROCEDURE Get_Needs_Doc (p_Pd_Id    IN     NUMBER,
                             p_Flag        OUT NUMBER,
                             Doc_Cur       OUT SYS_REFCURSOR,
                             Attr_Cur      OUT SYS_REFCURSOR,
                             File_Cur      OUT SYS_REFCURSOR);

    -- #86235: Документи рішення
    PROCEDURE Get_Ss_Docs (p_Pd_Id    IN     NUMBER,
                           p_mode     IN     NUMBER, -- 0 - призначення, 1 - відхилення
                           p_Flag        OUT NUMBER,
                           Doc_Cur       OUT SYS_REFCURSOR,
                           Attr_Cur      OUT SYS_REFCURSOR,
                           File_Cur      OUT SYS_REFCURSOR,
                           Sign_Cur      OUT SYS_REFCURSOR);

    -- #86235: додавання підписанта до документу
    PROCEDURE Add_Signer (p_Pdo_Id   IN NUMBER,
                          p_Pd_Id    IN NUMBER,
                          p_Wu_Id    IN NUMBER DEFAULT NULL);

    -- #86235: проставлення ознаки підпису документа користувачем
    PROCEDURE Set_Doc_Signed (p_Pdo_Id IN NUMBER);

    --  #86235: Список документів які можна створити
    PROCEDURE Get_Doc_Tp_List (p_Pd_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    -- #89729: Список документів які можна створити
    -- Підписання SS-рішень про відмову в наданні СП
    PROCEDURE get_rej_doc_tp_list (p_pd_id   IN     NUMBER,
                                   res_cur      OUT SYS_REFCURSOR);

    -- #86235: створення нового документу
    PROCEDURE Create_Doc (p_Ndt_Id    IN     NUMBER,
                          p_Pd_Id     IN     NUMBER,
                          p_Pdo_Doc   IN     NUMBER,
                          p_Pdo_Dh    IN     NUMBER,
                          p_Pdo_Id       OUT NUMBER);

    -- #86235: створення вкладення для документу
    PROCEDURE Create_Doc_Attach (p_Pdo_Id IN NUMBER, p_Blob OUT BLOB);

    -- #86235: видача інформації для формування підпису
    PROCEDURE Get_Sign_Attach_Info (p_Pdo_Id   IN     NUMBER,
                                    Res_Cur       OUT SYS_REFCURSOR);

    FUNCTION Fill_Attrs_850 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs;

    FUNCTION Fill_Attrs_851 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs;

    FUNCTION Fill_Attrs_852 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs;

    FUNCTION Fill_Attrs_853 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs;

    FUNCTION Fill_Attrs_854 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs;

    -- #81511: Оцінка потреб, збереження
    PROCEDURE Save_Document (p_Pdo_Id     IN OUT NUMBER,
                             p_Pd_Id      IN     NUMBER,
                             p_Ap_Id      IN     NUMBER,
                             p_Doc_Id     IN     NUMBER,
                             p_Dh_Id      IN     NUMBER,
                             p_Pdo_App    IN     NUMBER,
                             p_Pdo_Ndt    IN     NUMBER,
                             p_Attr_Xml   IN     CLOB,
                             p_File_Xml   IN     CLOB);

    -- #81511: Оцінка потреб, видалення
    PROCEDURE Delete_Document (p_Pdo_Id IN NUMBER);

    -- #84104
    PROCEDURE Get_Pr_Sheet_By_Pc (p_Pc_Id   IN     NUMBER,
                                  Res_Cur      OUT SYS_REFCURSOR);

    -- #84489
    PROCEDURE Get_Deduction_Persons (p_Dn_Id   IN     NUMBER,
                                     Res_Cur      OUT SYS_REFCURSOR);

    -- #98731
    PROCEDURE get_dcz_sc_tab (p_sc_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- #105029: В картці СРКО додати закладку "Сім'я"
    PROCEDURE get_sc_family_info (p_sc_Id   IN     NUMBER,
                                  res_cur      OUT SYS_REFCURSOR);

    -- #112784: В картці СРКО додати закладку "Родинні зв'язки"
    PROCEDURE get_sc_veteran_family_info (p_sc_Id   IN     NUMBER,
                                          res_cur      OUT SYS_REFCURSOR);

    --Перенесення ЕОС у вказаний ОСЗН
    PROCEDURE move_pc_to_other_org (p_pc_id     personalcase.pc_id%TYPE,
                                    p_new_org   personalcase.com_org%TYPE,
                                    p_reason    VARCHAR2);
END Dnet$personal_Case;
/


GRANT EXECUTE ON USS_ESR.DNET$PERSONAL_CASE TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PERSONAL_CASE TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PERSONAL_CASE
IS
    -- #70663: журнал особових справ
    PROCEDURE GET_JOURNAL (P_PC_NUM               IN     VARCHAR2,
                           P_SC_UNIQUE            IN     VARCHAR2,
                           P_SC_NUMIDENT          IN     VARCHAR2,
                           P_SC_PIB               IN     VARCHAR2,
                           P_PC_CREATE_DT_START   IN     DATE,
                           P_PC_CREATE_DT_STOP    IN     DATE,
                           P_APS_NST              IN     NUMBER,
                           P_PDP_NPT              IN     NUMBER,
                           P_Org_Id               IN     NUMBER,
                           P_IS_DECISION_ACTIVE   IN     VARCHAR2,
                           -- передвстановлені фільтри від Підготовка до масового нарахування
                           p_pd_nst               IN     NUMBER,
                           p_month                IN     DATE,
                           p_nis_id               IN     NUMBER,
                           p_mode                 IN     NUMBER,
                           RES_CUR                   OUT SYS_REFCURSOR)
    IS
        l_pib        VARCHAR2 (250);
        l_sql        VARCHAR2 (4000)
            := ' WITH flt AS
             (SELECT :1 as P_PC_NUM,
                     :2 as P_SC_UNIQUE,
                     :3 as P_SC_NUMIDENT,
                     :4 as P_SC_PIB,
                     :5 as P_PC_CREATE_DT_START,
                     :6 as P_PC_CREATE_DT_STOP,
                     :7 as P_APS_NST,
                     :8 as P_PDP_NPT,
                     :9 as P_Org_Id,
                     :10 as P_IS_DECISION_ACTIVE,
                     :11 as p_pd_nst,
                     :12 as p_month,
                     :13 as p_nis_id
              FROM dual
             )
        SELECT t.*,
               sc.sc_id,
               sc.sc_unique,
               i.sci_ln || '' '' || i.sci_fn || '' '' || i.sci_mn AS sc_pib,
               --ІПН
              (SELECT p.Scd_Seria || p.Scd_Number
                 FROM uss_person.v_Sc_Document p
                WHERE p.Scd_Sc = sc.Sc_Id
                      AND p.Scd_Ndt = 5
                      AND p.Scd_St IN (''A'', ''1'')
                ORDER BY To_Number(p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS SC_Numdent,
                st.DIC_SNAME AS Pc_St_Name
        FROM flt f,
          v_personalcase t
          JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.pc_sc)
          JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
          JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
          JOIN uss_ndi.v_ddn_pc_st st ON (st.DIC_VALUE = t.pc_st)
        WHERE 1 = 1
          and rownum < 502';
        l_nis_part   VARCHAR2 (500) := '';
    BEGIN
        tools.validate_param (P_PC_NUM);
        tools.validate_param (P_SC_UNIQUE);
        tools.validate_param (P_SC_NUMIDENT);
        tools.validate_param (P_SC_PIB);
        tools.validate_param (P_IS_DECISION_ACTIVE);


        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        IF P_PC_NUM IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.pc_num LIKE f.P_PC_NUM ||''%''';
        END IF;

        IF P_Org_Id IS NOT NULL AND p_mode IS NULL
        THEN
            l_sql := l_sql || ' AND t.com_org = f.P_Org_Id';
        END IF;

        IF P_SC_UNIQUE IS NOT NULL
        THEN
            l_sql := l_sql || ' AND sc.sc_unique LIKE f.P_SC_UNIQUE ||''%''';
        END IF;

        IF P_PC_CREATE_DT_START IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.pc_create_dt >= f.P_PC_CREATE_DT_START';
        END IF;

        IF P_PC_CREATE_DT_STOP IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.pc_create_dt <= f.P_PC_CREATE_DT_STOP';
        END IF;

        IF P_APS_NST IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND exists (SELECT *
                                      FROM v_appeal z
                                      JOIN v_ap_service zs ON (zs.aps_ap = z.ap_id)
                                     WHERE z.ap_pc = t.pc_Id
                                       AND zs.aps_nst = f.P_APS_NST )';
        END IF;

        IF P_PDP_NPT IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND exists (SELECT *
                                      FROM v_pc_decision z
                                      JOIN v_pd_payment zp ON (zp.pdp_pd = z.pd_id)
                                     WHERE z.pd_pc = t.pc_Id
                                       AND zp.history_status = ''A''
                                       AND zp.pdp_npt = f.P_PDP_NPT )';
        END IF;

        IF P_IS_DECISION_ACTIVE = 'T'
        THEN
            l_sql := l_sql || ' AND exists (SELECT *
                                      FROM v_pc_decision z
                                     WHERE z.pd_pc = t.pc_Id
                                       AND z.pd_st in (''S''))';
        END IF;

        IF P_SC_PIB IS NOT NULL
        THEN
            --l_pib := REPLACE(P_SC_PIB, '''', '''''');
            l_sql :=
                   l_sql
                || ' AND upper(i.sci_ln || '' '' || i.sci_fn || '' '' || i.sci_mn) LIKE upper(f.P_SC_PIB) || ''%'' ';
        END IF;

        IF P_SC_NUMIDENT IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND EXISTS (SELECT *
                                      FROM uss_person.v_Sc_Document p
                                     WHERE p.Scd_Sc = sc.Sc_Id
                                       AND p.Scd_Ndt = 5
                                       AND p.Scd_St IN (''A'', ''1'')
                                       AND p.Scd_Number LIKE f.P_SC_NUMIDENT || ''%'')';
        END IF;

        IF (p_nis_id IS NOT NULL)
        THEN
            l_nis_part :=
                'AND EXISTS (SELECT * FROM uss_ndi.v_ndi_nis_users zz WHERE zz.nisu_wu = x.com_wu and zz.nisu_nis = f.p_nis_id )';
        END IF;

        IF (p_mode = 1)
        THEN
            l_sql :=
                   l_sql
                || ' and exists (SELECT *
                                        FROM pc_decision x
                                        WHERE pd_nst = f.p_pd_nst
                                          AND x.com_org = f.P_Org_Id
                                          AND ((pd_start_dt <= LAST_DAY(f.p_month) AND pd_stop_dt >=  f.p_month )
                                            OR pd_start_dt IS NULL)
                                          and x.pd_pc = t.pc_id
                                          '
                || l_nis_part
                || '
                                          AND pd_st NOT IN (''V''))';
        END IF;

        IF (p_mode = 2)
        THEN
            l_sql :=
                   l_sql
                || ' and exists (SELECT *
                                        FROM pc_decision x
                                        WHERE pd_nst = f.p_pd_nst
                                          AND x.com_org = f.P_Org_Id
                                          AND ((pd_start_dt <= LAST_DAY(f.p_month) AND pd_stop_dt >=  f.p_month )
                                            OR pd_start_dt IS NULL)
                                          and x.pd_pc = t.pc_id
                                          '
                || l_nis_part
                || '
                                          AND pd_st IN (''S''))';
        END IF;

        IF (p_mode = 3)
        THEN
            l_sql :=
                   l_sql
                || ' and exists (SELECT *
                                         FROM accrual z, ac_detail, uss_ndi.v_ndi_npt_config, pc_decision x
                                        WHERE z.com_org = f.P_Org_Id
                                          AND acd_ac = ac_id
                                          --AND acd_op = 1
                                          AND acd_op not BETWEEN 278 AND 284
                                          and ac_pc = t.pc_id
                                          and acd_pd = x.pd_id
                                          AND acd_npt = nptc_npt
                                          AND nptc_nst = f.p_pd_nst
                                          AND ac_month = f.p_month
                                          AND ac_detail.history_status = ''A''
                                          '
                || l_nis_part
                || '
                                          )';
        END IF;

        IF (p_mode = 4)
        THEN
            l_sql :=
                   l_sql
                || ' and exists (SELECT *
                                        FROM pc_decision x
                                        WHERE pd_nst = f.p_pd_nst
                                          AND x.com_org =  f.P_Org_Id
                                          AND ((pd_start_dt <= LAST_DAY(f.p_month) AND pd_stop_dt >=  f.p_month )
                                            OR pd_start_dt IS NULL)
                                          and x.pd_pc = t.pc_id
                                          '
                || l_nis_part
                || '
                                          AND pd_st IN (''S''))';

            l_sql :=
                   l_sql
                || ' and not exists (SELECT *
                                         FROM accrual z, ac_detail q, uss_ndi.v_ndi_npt_config, pc_decision x
                                        WHERE z.com_org = f.P_Org_Id
                                          AND acd_ac = ac_id
                                          --AND acd_op = 1
                                          AND acd_op not BETWEEN 278 AND 284
                                          and q.acd_pd = x.pd_id
                                          and ac_pc = t.pc_id
                                          AND acd_npt = nptc_npt
                                          '
                || l_nis_part
                || '
                                          AND nptc_nst = f.p_pd_nst
                                          AND ac_month = f.p_month
                                          AND q.history_status = ''A'')';
        END IF;

        IF (p_mode = 5)
        THEN
            l_sql :=
                   l_sql
                || ' and exists (SELECT *
                                         FROM pr_sheet prs
                                         join payroll pr on (prs_pr = pr_id)
                                         join uss_ndi.v_ndi_npt_config on (nptc_npt = prs_npt)
                                        WHERE pr.com_org = f.P_Org_Id
                                           AND nptc_nst = f.p_pd_nst
                                           and prs.prs_pc = t.pc_id
                                           AND pr_month = f.p_month
                                          and nvl(prs_st, ''NA'') = ''NA'')';
        END IF;

        --raise_application_error(-20000, l_sql);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_sql);

        OPEN res_cur FOR l_sql
            USING P_PC_NUM,
        P_SC_UNIQUE,
        P_SC_NUMIDENT,
        P_SC_PIB,
        P_PC_CREATE_DT_START,
        P_PC_CREATE_DT_STOP,
        P_APS_NST,
        P_PDP_NPT,
        P_Org_Id,
        P_IS_DECISION_ACTIVE,
        p_pd_nst,
        p_month,
        p_nis_id;
    END;



    -- #77394: Реєстр отримувачів соціальних послуг
    PROCEDURE GET_JOURNAL_SP (P_PC_NUM               IN     VARCHAR2, -- № ЕОС
                              P_SC_UNIQUE            IN     VARCHAR2, --ЄСР ІД
                              P_SC_NUMIDENT          IN     VARCHAR2, --РНОКПП
                              P_SC_PIB               IN     VARCHAR2,    --ПІБ
                              P_PC_CREATE_DT_START   IN     DATE, --Створено з
                              P_PC_CREATE_DT_STOP    IN     DATE, --Створено по
                              P_APS_NST              IN     NUMBER, --Соціальна послуга
                              p_scd_ser_num          IN     VARCHAR2, --Серія  та номер паспорту
                              P_RNSPM_ID             IN     NUMBER, -- Надавач
                              p_is_blocked           IN     VARCHAR2, -- (T/F) Припинено надання соціальних послуг
                              p_org_id               IN     NUMBER,    -- ОСЗН
                              RES_CUR                   OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
        l_sql   VARCHAR2 (10000)
            := ' WITH flt AS
             (SELECT :1 as P_PC_NUM,
                     :2 as P_SC_UNIQUE,
                     :3 as P_SC_NUMIDENT,
                     :4 as P_SC_PIB,
                     :5 as P_PC_CREATE_DT_START,
                     :6 as P_PC_CREATE_DT_STOP,
                     :7 as P_APS_NST,
                     :8 as P_SCD_SER_NUM,
                     :9 as P_RNSPM_ID,
                     :10 as P_Org_Id,
                     :11 as l_org
              FROM dual
             )
        SELECT t.*,
               sc.sc_id,
               sc.sc_unique,
               i.sci_ln || '' '' || i.sci_fn || '' '' || i.sci_mn AS sc_pib,
               --ІПН
              (SELECT p.Scd_Seria || p.Scd_Number
                 FROM uss_person.v_Sc_Document p
                WHERE p.Scd_Sc = sc.Sc_Id
                      AND p.Scd_Ndt = 5
                      AND p.Scd_St IN (''A'', ''1'')
                ORDER BY To_Number(p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS SC_Numdent,
                st.DIC_SNAME AS Pc_St_Name
          FROM flt f,
            v_personalcase t
            JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.pc_sc)
            JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
            JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
            JOIN uss_ndi.v_ddn_pc_st st ON (st.DIC_VALUE = t.pc_st)
          WHERE 1 = 1
            and rownum < 502
            and (/* exists ( select pd_id as id
                             from uss_esr.pc_decision pcd
                             JOIN uss_ndi.v_ndi_ap_nst_config nanc ON (nanc.nanc_nst = pcd.pd_nst)
                            where pcd.pd_pc = t.pc_id
                              and nanc.nanc_ap_tp = ''SS''
                              and ( pcd.pd_st = ''P'' OR pcd.pd_st = ''O.P'')
                              AND not exists ( select *
                                               from uss_esr.ap_document apd
                                               where apd.apd_ap = pcd.pd_ap
                                                 and apd.history_status = ''A''
                                                 and apd.apd_ndt = 802   )
                              AND exists ( select *
                                           from uss_esr.ap_document apd
                                           where apd.apd_ap = pcd.pd_ap
                                             and apd.history_status = ''A''
                                             and apd.apd_ndt IN (801, 803)  )
                              )

               or */exists ( select at_id as id
                             from uss_esr.act at
                             join uss_esr.at_service s on (s.ats_at = at.at_id)
                             JOIN uss_ndi.v_ndi_ap_nst_config nanc ON (nanc.nanc_nst = s.ats_nst)
                            where at.at_pc = t.pc_id
                              and nanc.nanc_ap_tp = ''SS''
                              and at.at_org = f.l_org
                              and ( at.at_st in (''SA'', ''SGO'', ''O.SA'', ''SP2'', ''SV'', ''SI'', ''SS'', ''SGA'', ''SGM'', ''SU'', ''SJ''))
                              )
                 )
            ';
    BEGIN
        --      raise_application_error(-20000, 'GET_JOURNAL_SP');
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        tools.validate_param (P_PC_NUM);
        tools.validate_param (P_SC_UNIQUE);
        tools.validate_param (P_SC_NUMIDENT);
        tools.validate_param (P_SC_PIB);
        tools.validate_param (p_scd_ser_num);
        tools.validate_param (p_is_blocked);

        IF P_PC_NUM IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.pc_num LIKE f.P_PC_NUM || ''%''';
        END IF;

        IF P_SC_UNIQUE IS NOT NULL
        THEN
            l_sql := l_sql || ' AND sc.sc_unique LIKE f.P_SC_UNIQUE || ''%''';
        END IF;

        IF p_org_id IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.com_org = f.p_org_id';
        ELSE
            l_sql :=
                   l_sql
                || ' and ( t.com_org in (select u_org from tmp_org)
            or '
                || l_org
                || ' in (/*( select pcd.com_org
                                       from uss_esr.pc_decision pcd
                                       JOIN uss_ndi.v_ndi_ap_nst_config nanc ON (nanc.nanc_nst = pcd.pd_nst)
                                      where pcd.pd_pc = t.pc_id
                                        and nanc.nanc_ap_tp = ''SS''
                                        and ( pcd.pd_st = ''P'' OR pcd.pd_st = ''O.P'')
                                        AND not exists ( select *
                                                         from uss_esr.ap_document apd
                                                         where apd.apd_ap = pcd.pd_ap
                                                           and apd.history_status = ''A''
                                                           and apd.apd_ndt = 802   )
                                        AND exists ( select *
                                                     from uss_esr.ap_document apd
                                                     where apd.apd_ap = pcd.pd_ap
                                                       and apd.history_status = ''A''
                                                       and apd.apd_ndt IN (801, 803)  )
                                     union*/
                                     select at.at_org
                                       from uss_esr.act at
                                       join uss_esr.at_service s on (s.ats_at = at.at_id)
                                       JOIN uss_ndi.v_ndi_ap_nst_config nanc ON (nanc.nanc_nst = s.ats_nst)
                                      where at.at_pc = t.pc_id
                                        and nanc.nanc_ap_tp = ''SS''
                                        and at.at_org = f.l_org
                                        and  at.at_st in (''SA'', ''SGO'', ''O.SA'', ''SP2'', ''SV'', ''SI'', ''SS'', ''SGA'', ''SGM'', ''SU'', ''SJ'')
                                   )
                                ) ';
        END IF;

        IF P_PC_CREATE_DT_START IS NOT NULL
        THEN
            l_sql :=
                l_sql || ' AND t.pc_create_dt >= f.P_PC_CREATE_DT_START ';
        END IF;

        IF P_PC_CREATE_DT_STOP IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.pc_create_dt <= f.P_PC_CREATE_DT_STOP ';
        END IF;

        IF P_APS_NST IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND exists (SELECT *
                                      FROM v_appeal z
                                      JOIN v_ap_service zs ON (zs.aps_ap = z.ap_id)
                                     WHERE z.ap_pc = t.pc_Id
                                       AND zs.aps_nst = f.P_APS_NST )';
        END IF;

        IF p_scd_ser_num IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || 'AND exists (SELECT *
                                 FROM uss_person.v_socialcard sc
                                 JOIN uss_person.v_sc_document sd on (t.pc_sc=sd.scd_sc/* and sd.scd_ndt = 6 or sd.scd_ndt = 7*/)
                                 join uss_ndi.v_ndi_document_type zt on (zt.ndt_id = sd.scd_ndt)
                                WHERE (sc.sc_id = t.pc_sc)
                                  and zt.ndt_ndc = 13
                                  AND (sd.scd_seria || sd.scd_number = f.p_scd_ser_num ))';
        END IF;

        IF P_RNSPM_ID IS NOT NULL
        THEN
            /*l_sql := l_sql||' AND exists (SELECT *
                                           FROM ap_document_attr apda
                                          JOIN ap_document apd
                                           ON (apd.apd_id = apda.apda_apd)
                                          JOIN v_appeal ap
                                           ON (apd.apd_ap = ap.ap_id)
                                          WHERE apda.apda_nda = 1872
                                          AND ap.ap_pc = t.pc_id
                                          AND apda.apda_val_id = f.p_rnspm_id )';*/
            l_sql :=
                   l_sql
                || ' AND exists (SELECT *
                                     FROM v_act z
                                    WHERE z.at_pc = t.pc_id
                                      AND z.at_rnspm = f.p_rnspm_id
                                      and z.at_st in (''SA'', ''SGO'', ''O.SA'', ''SP2'', ''SV'', ''SI'', ''SS'', ''SGA'', ''SGM'', ''SU'', ''SJ'')
                                    )';
        END IF;

        IF P_SC_PIB IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND upper(i.sci_ln || '' '' || i.sci_fn || '' '' || i.sci_mn) LIKE upper(f.P_SC_PIB) || ''%''';
        END IF;

        IF P_SC_NUMIDENT IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND EXISTS (SELECT *
                                      FROM uss_person.v_Sc_Document p
                                     WHERE p.Scd_Sc = sc.Sc_Id
                                       AND p.Scd_Ndt = 5
                                       AND p.Scd_St IN (''A'', ''1'')
                                       AND p.Scd_Number LIKE f.P_SC_NUMIDENT || ''%'')';
        END IF;

        IF NVL (p_is_blocked, 'F') = 'T'
        THEN
            l_sql := l_sql || ' AND EXISTS (SELECT 1
                                      FROM uss_esr.act at
                                     WHERE at_pc = t.pc_id
                                       AND at_st = ''RA''
                                       and at_tp = ''RSTOPSS''
                                       and at_org = f.l_org
                                    )';
        /*ELSE
          l_sql := l_sql||' AND NOT EXISTS (SELECT 1
                                          FROM uss_esr.act at
                                         WHERE at_pc = t.pc_id
                                           AND at_st = ''RA''
                                           and at_tp = ''RSTOPSS''
                                           and at_org = f.l_org
                                        )';*/
        END IF;

        INSERT INTO tmp_lob (x_id, x_clob)
             VALUES (12345, l_sql);

        --raise_application_error(-20000, l_sql);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_sql);

        --    OPEN res_cur FOR l_sql;
        OPEN res_cur FOR l_sql
            USING P_PC_NUM,
        P_SC_UNIQUE,
        P_SC_NUMIDENT,
        P_SC_PIB,
        P_PC_CREATE_DT_START,
        P_PC_CREATE_DT_STOP,
        P_APS_NST,
        p_scd_ser_num,
        P_RNSPM_ID,
        P_Org_Id,
        tools.GetCurrOrg;
    END;



    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id - ідентифікатор обращения
    -- note: mode - 0 - pc_id, 1 - ap_id
    PROCEDURE Get_Documents_Files (p_mode    IN     NUMBER,
                                   p_Pc_Id          NUMBER,
                                   p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM v_appeal t JOIN v_Ap_Document d ON (d.apd_ap = t.ap_id)
             WHERE     (   p_mode = 0 AND t.ap_pc = p_pc_id
                        OR p_mode = 1 AND t.ap_id = p_pc_id
                        OR 1 = 2)
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id       - ідентифікатор обращения
    -- params: p_first_ap_id - ідентифікатор первичного обращения
    PROCEDURE Get_Documents_Files2 (P_AP_ID         IN     NUMBER,
                                    P_FIRST_AP_ID   IN     NUMBER,
                                    p_Res              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM v_appeal t JOIN v_Ap_Document d ON (d.apd_ap = t.ap_id)
             WHERE     (t.ap_id = p_ap_id OR t.ap_id = p_first_ap_id)
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    -- #70663: картка особової справи
    PROCEDURE GET_CARD (P_PC_ID     IN     NUMBER,
                        INFO_CUR       OUT SYS_REFCURSOR,
                        DOC_CUR        OUT SYS_REFCURSOR,
                        ATTR_CUR       OUT SYS_REFCURSOR,
                        FILES_CUR      OUT SYS_REFCURSOR,
                        DEC_CUR        OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        --raise_application_error(-20000, p_pc_id);
        OPEN info_cur FOR
            SELECT t.*,
                   op.org_name                   AS com_org_name,
                   sc.sc_id,
                   sc.sc_unique,
                      i.sci_ln
                   || ' '
                   || i.sci_fn
                   || ' '
                   || i.sci_mn                   AS sc_pib,
                   --ІПН
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM uss_person.v_Sc_Document p
                        WHERE     p.Scd_Sc = sc.Sc_Id
                              AND p.Scd_Ndt = 5
                              AND p.Scd_St IN ('A', '1')
                     ORDER BY TO_NUMBER (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Sc_Numdent,
                   st.DIC_SNAME                  AS Pc_St_Name
              FROM v_personalcase  t
                   JOIN v_opfu op ON (op.org_id = t.com_org)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.pc_sc)
                   JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                   JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
                   JOIN uss_ndi.v_ddn_pc_st st ON (st.DIC_VALUE = t.pc_st)
             WHERE t.pc_id = p_pc_id;


        OPEN DOC_CUR FOR
            SELECT d.*,
                   t.ap_num
                       AS apd_ap_name,
                   uss_person.api$sc_tools.GET_PIB (pp.app_sc)
                       AS apd_app_name,
                   tp.ndt_name
                       AS apd_ndt_name,
                   (SELECT MAX (a.Apda_Val_String)     AS Apda_Val_String
                      FROM V_Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A')
                       AS apd_Seria_Num,
                   st.DIC_SNAME
                       AS Apd_Vf_Name
              FROM v_personalcase  pc
                   JOIN v_appeal t ON (t.ap_pc = pc.pc_id)
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_person pp
                       ON (pp.app_ap = t.ap_id AND d.apd_app = pp.app_id)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = d.apd_ndt)
                   LEFT JOIN v_verification v ON (v.vf_id = d.apd_vf)
                   LEFT JOIN uss_ndi.v_ddn_vf_st st
                       ON (st.DIC_VALUE = v.vf_st)
             WHERE pc.pc_id = p_pc_id;


        OPEN ATTR_CUR FOR
            SELECT attr.*
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_document_attr attr ON (attr.apda_apd = d.apd_id)
             WHERE t.ap_pc = p_pc_id;

        Get_Documents_Files (0, p_pc_id, files_cur);

        OPEN DEC_CUR FOR
            SELECT d.*,
                   pa.pa_num                             AS Pd_Pa_Name,
                   st.nst_code || ' ' || st.nst_name     AS Pd_Nst_Name,
                   pt.npt_code || ' ' || pt.npt_name     AS Pdp_Ndt_Name,
                   p.pdp_sum,
                   p.pdp_start_dt,
                   p.pdp_stop_dt
              FROM v_pc_decision_by_pc  d
                   JOIN v_pc_account pa ON (pa.pa_id = d.pd_pa)
                   JOIN uss_ndi.v_ndi_service_type st
                       ON (st.nst_id = d.pd_nst)
                   JOIN v_pd_payment p
                       ON (p.pdp_pd = d.pd_id AND p.history_status = 'A')
                   JOIN uss_ndi.v_ndi_payment_type pt
                       ON (pt.npt_id = p.pdp_npt)
             WHERE d.pd_pc = P_PC_ID;
    END;


    PROCEDURE Get_Card_Sc (p_sc_id IN NUMBER, p_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_cur FOR
            SELECT sc.sc_id,
                   sc.sc_unique,
                   i.sci_ln,
                   i.sci_fn,
                   i.sci_mn,
                   --ІПН
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM uss_person.v_Sc_Document p
                        WHERE     p.Scd_Sc = sc.Sc_Id
                              AND p.Scd_Ndt = 5
                              AND p.Scd_St IN ('A', '1')
                     ORDER BY TO_NUMBER (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Sc_Numdent
              FROM uss_person.v_socialcard  sc
                   JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                   JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
             WHERE sc.sc_id = p_sc_id;
    END;

    PROCEDURE get_main_info (p_pc_id IN NUMBER, info_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        --raise_application_error(-20000, p_pc_id);
        OPEN info_cur FOR
            SELECT t.*,
                   op.org_name                   AS com_org_name,
                   sc.sc_id,
                   op.org_to,
                   sc.sc_unique,
                      i.sci_ln
                   || ' '
                   || i.sci_fn
                   || ' '
                   || i.sci_mn                   AS sc_pib,
                   --ІПН
                    (  SELECT p.scd_seria || p.scd_number
                         FROM uss_person.v_sc_document p
                        WHERE     p.scd_sc = sc.sc_id
                              AND p.scd_ndt = 5
                              AND p.scd_st IN ('A', '1')
                     ORDER BY TO_NUMBER (p.scd_start_dt) DESC
                        FETCH FIRST ROW ONLY)    AS sc_numdent,
                   st.dic_sname                  AS pc_st_name
              FROM v_personalcase  t
                   JOIN v_opfu op ON (op.org_id = t.com_org)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.pc_sc)
                   JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                   JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
                   JOIN uss_ndi.v_ddn_pc_st st ON (st.dic_value = t.pc_st)
             WHERE t.pc_id = p_pc_id;
    END;

    PROCEDURE GET_DOCUMENTS (P_PC_ID     IN     NUMBER,
                             DOC_CUR        OUT SYS_REFCURSOR,
                             ATTR_CUR       OUT SYS_REFCURSOR,
                             FILES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN DOC_CUR FOR
            SELECT d.*,
                   t.ap_num
                       AS apd_ap_name,
                   uss_person.api$sc_tools.GET_PIB (pp.app_sc)
                       AS apd_app_name,
                   atp.DIC_NAME
                       AS apd_app_tp_name,
                   tp.ndt_name
                       AS apd_ndt_name,
                   (SELECT MAX (a.Apda_Val_String)     AS Apda_Val_String
                      FROM V_Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A')
                       AS apd_Seria_Num,
                   st.DIC_SNAME
                       AS Apd_Vf_Name
              FROM v_personalcase  pc
                   JOIN v_appeal t ON (t.ap_pc = pc.pc_id)
                   JOIN v_ap_document d
                       ON (d.apd_ap = t.ap_id AND d.History_Status = 'A')
                   JOIN v_ap_person pp
                       ON (pp.app_ap = t.ap_id AND d.apd_app = pp.app_id)
                   LEFT JOIN uss_ndi.v_ddN_app_tp atp
                       ON (atp.DIC_VALUE = pp.app_tp)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = d.apd_ndt)
                   LEFT JOIN v_verification v ON (v.vf_id = d.apd_vf)
                   LEFT JOIN uss_ndi.v_ddn_vf_st st
                       ON (st.DIC_VALUE = v.vf_st)
             WHERE pc.pc_id = p_pc_id;


        OPEN ATTR_CUR FOR
            SELECT attr.*
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_document_attr attr ON (attr.apda_apd = d.apd_id)
             WHERE t.ap_pc = p_pc_id AND attr.history_status = 'A';

        Get_Documents_Files (0, p_pc_id, files_cur);
    END;

    -- #70749: список документів по зверненню
    PROCEDURE GET_DOCUMENTS_AP (P_AP_ID     IN     NUMBER,
                                DOC_CUR        OUT SYS_REFCURSOR,
                                ATTR_CUR       OUT SYS_REFCURSOR,
                                FILES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN DOC_CUR FOR
            SELECT d.*,
                   t.ap_num
                       AS apd_ap_name,
                   uss_person.api$sc_tools.GET_PIB (pp.app_sc)
                       AS apd_app_name,
                   tp.ndt_name
                       AS apd_ndt_name,
                   (SELECT a.Apda_Val_String
                      FROM V_Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A')
                       AS apd_Seria_Num,
                   st.DIC_SNAME
                       AS Apd_Vf_Name
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   LEFT JOIN v_ap_person pp
                       ON (pp.app_ap = t.ap_id AND d.apd_app = pp.app_id)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = d.apd_ndt)
                   LEFT JOIN v_verification v ON (v.vf_id = d.apd_vf)
                   LEFT JOIN uss_ndi.v_ddn_vf_st st
                       ON (st.DIC_VALUE = v.vf_st)
             WHERE t.ap_id = p_ap_id AND d.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_document_attr attr ON (attr.apda_apd = d.apd_id)
             WHERE t.ap_id = p_ap_id AND attr.history_status = 'A';

        Get_Documents_Files (1, p_ap_id, files_cur);
    END;

    -- 74847 : список документів по зверненню
    -- params: p_ap_id       - ідентифікатор обращения
    -- params: p_first_ap_id - ідентифікатор первичного обращения
    PROCEDURE GET_DOCUMENTS (P_AP_ID         IN     NUMBER,
                             P_FIRST_AP_ID   IN     NUMBER,
                             DOC_CUR            OUT SYS_REFCURSOR,
                             ATTR_CUR           OUT SYS_REFCURSOR,
                             FILES_CUR          OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN DOC_CUR FOR
            SELECT d.*,
                   t.ap_num
                       AS apd_ap_name,
                   uss_person.api$sc_tools.GET_PIB (pp.app_sc)
                       AS apd_app_name,
                   atp.DIC_NAME
                       AS apd_app_tp_name,
                   tp.ndt_name
                       AS apd_ndt_name,
                   (SELECT MAX (a.Apda_Val_String)
                      FROM V_Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A')
                       AS apd_Seria_Num,
                   st.DIC_SNAME
                       AS Apd_Vf_Name
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   LEFT JOIN v_ap_person pp
                       ON (pp.app_ap = t.ap_id AND d.apd_app = pp.app_id)
                   LEFT JOIN uss_ndi.v_ddN_app_tp atp
                       ON (atp.DIC_VALUE = pp.app_tp)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = d.apd_ndt)
                   LEFT JOIN v_verification v ON (v.vf_id = d.apd_vf)
                   LEFT JOIN uss_ndi.v_ddn_vf_st st
                       ON (st.DIC_VALUE = v.vf_st)
             WHERE     (t.ap_id = p_ap_id OR t.ap_id = p_first_ap_id)
                   AND d.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*
              FROM v_appeal  t
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_document_attr attr ON (attr.apda_apd = d.apd_id)
             WHERE     (t.ap_id = p_ap_id OR t.ap_id = p_first_ap_id)
                   AND attr.history_status = 'A';

        Get_Documents_Files2 (p_ap_id, p_first_ap_id, files_cur);
    END;


    PROCEDURE GET_Decisions (P_PC_ID IN NUMBER, DEC_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN DEC_CUR FOR
              SELECT d.*,
                     pa.pa_num                             AS Pd_Pa_Name,
                     pa.pa_org,
                     st.nst_code || ' ' || st.nst_name     AS Pd_Nst_Name,
                     pt.npt_code || ' ' || pt.npt_name     AS Pdp_Ndt_Name,
                     p.pdp_sum,
                     p.pdp_start_dt,
                     p.pdp_stop_dt,
                     pst.DIC_NAME                          AS pd_st_name
                FROM v_pc_decision_by_pc d
                     JOIN v_pc_account pa ON (pa.pa_id = d.pd_pa)
                     JOIN uss_ndi.v_ndi_service_type st
                         ON (st.nst_id = d.pd_nst)
                     JOIN v_pd_payment p
                         ON (p.pdp_pd = d.pd_id AND p.history_status = 'A')
                     JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = p.pdp_npt)
                     LEFT JOIN uss_ndi.v_ddn_pd_st pst
                         ON (pst.dic_value = d.pd_st)
               WHERE d.pd_pc = P_PC_ID
            ORDER BY p.pdp_start_dt DESC;
    END;

    -- #83453
    PROCEDURE GET_OVERPAYMENT (p_pc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
        l_org      NUMBER := tools.getcurrorg;
        l_pc_org   NUMBER;
    BEGIN
        SELECT CASE
                   WHEN p.org_acc_org = l_org THEN 1
                   WHEN p.org_id = l_org THEN 1
                   ELSE 0
               END
          INTO l_pc_org
          FROM v_personalcase t JOIN v_opfu p ON (p.org_id = t.com_org)
         WHERE t.pc_id = p_pc_id;

        IF (l_pc_org = 1)
        THEN
            OPEN res_cur FOR
                SELECT dn.*,
                       ddu.dic_sname
                           AS dn_unit_name,
                       h.hs_dt
                           AS dn_hs_dt,
                       dpp.dpp_name
                           AS dn_dpp_name,
                       dds.dic_sname
                           AS dn_st_name,
                       ndn.ndn_name
                           AS dn_ndn_name,
                       r.DIC_NAME
                           AS dn_reason_name,
                       pc.pc_num,
                       st.nst_name,
                       uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                           AS ap_pib,
                       ap.ap_num,
                       pa.pa_num
                  FROM deduction                   dn,
                       uss_ndi.v_ddn_dn_unit       ddu,
                       histsession                 h,
                       uss_ndi.v_ndi_pay_person    dpp,
                       uss_ndi.v_ddn_dn_st         dds,
                       uss_ndi.v_ndi_deduction     ndn,
                       appeal                      ap,
                       personalcase                pc,
                       pc_account                  pa,
                       uss_ndi.v_ddn_dn_reason     r,
                       uss_ndi.v_ndi_service_type  st
                 WHERE     dn.dn_unit = ddu.dic_value(+)
                       AND dn.dn_hs_return = h.hs_id(+)
                       AND dn.dn_dpp = dpp.dpp_id(+)
                       AND dn.dn_st = dds.dic_value(+)
                       AND dn.dn_ndn = ndn.ndn_id(+)
                       AND dn.dn_pc = pc.pc_id(+)
                       AND dn.dn_pa = pa.pa_id(+)
                       AND dn.dn_ap = ap.ap_id(+)
                       AND pa.pa_nst = st.nst_id(+)
                       AND dn.dn_reason = r.DIC_VALUE(+)
                       AND dn_tp IN ('R', 'HM')
                       AND pc.pc_id = p_pc_id;
        ELSE
            OPEN res_cur FOR
                SELECT dn.*,
                       ddu.dic_sname
                           AS dn_unit_name,
                       h.hs_dt
                           AS dn_hs_dt,
                       dpp.dpp_name
                           AS dn_dpp_name,
                       dds.dic_sname
                           AS dn_st_name,
                       ndn.ndn_name
                           AS dn_ndn_name,
                       r.DIC_NAME
                           AS dn_reason_name,
                       pc.pc_num,
                       st.nst_name,
                       uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                           AS ap_pib,
                       ap.ap_num,
                       pa.pa_num
                  FROM v_deduction_by_pc           dn,
                       uss_ndi.v_ddn_dn_unit       ddu,
                       histsession                 h,
                       uss_ndi.v_ndi_pay_person    dpp,
                       uss_ndi.v_ddn_dn_st         dds,
                       uss_ndi.v_ndi_deduction     ndn,
                       appeal                      ap,
                       personalcase                pc,
                       pc_account                  pa,
                       uss_ndi.v_ddn_dn_reason     r,
                       uss_ndi.v_ndi_service_type  st
                 WHERE     dn.dn_unit = ddu.dic_value(+)
                       AND dn.dn_hs_return = h.hs_id(+)
                       AND dn.dn_dpp = dpp.dpp_id(+)
                       AND dn.dn_st = dds.dic_value(+)
                       AND dn.dn_ndn = ndn.ndn_id(+)
                       AND dn.dn_pc = pc.pc_id(+)
                       AND dn.dn_pa = pa.pa_id(+)
                       AND dn.dn_ap = ap.ap_id(+)
                       AND pa.pa_nst = st.nst_id(+)
                       AND dn.dn_reason = r.DIC_VALUE(+)
                       AND dn_tp IN ('R', 'HM')
                       AND pc.pc_id = p_pc_id;
        END IF;
    END;


    -- info: налаштування атрибутів по типу документа
    -- params:
    -- note:
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Nda_Cur FOR
            SELECT Nda.Nda_Id,
                   NVL (Nda.Nda_Name, Pt.Pt_Name)
                       AS Nda_Name,
                   Nda.Nda_Is_Key,
                   Nda.Nda_Ndt,
                   Nda.Nda_Order,
                   Nda.Nda_Pt,
                   Nda.Nda_Is_Req,
                   Nda.Nda_Def_Value,
                   Nda.Nda_Can_Edit,
                   Nda.Nda_Need_Show,
                   Pt.Pt_Id,
                   Pt.Pt_Code,
                   Pt.Pt_Name,
                   Pt.Pt_Ndc,
                   Pt.Pt_Edit_Type,
                   Pt.Pt_Data_Type,
                   Ndc.Ndc_Code,
                   NVL (Nda.Nda_Nng, -1)
                       AS Nda_Nng,
                   (SELECT MAX (z.nnv_condition)
                      FROM uss_ndi.v_ndi_nda_validation z
                     WHERE z.nnv_nda = nda.nda_id AND z.nnv_tp = 'MASK')
                       AS Mask_Setup,
                   (SELECT COALESCE (MAX (z.nnv_condition), 'F')
                      FROM uss_ndi.v_ndi_nda_validation z
                     WHERE z.nnv_nda = nda.nda_id AND z.nnv_tp = 'RESET')
                       AS Can_Reset
              FROM Uss_Ndi.v_Ndi_Document_Attr  Nda
                   JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                   LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config Ndc
                       ON Ndc.Ndc_Id = Pt.Pt_Ndc
             WHERE Nda_Ndt = p_Ndt_Id;
    END;

    ---------------------------------------------------------------------
    --                   ДОВІДНИК ГРУП АТРИБУТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Nng_Cur FOR
            SELECT -1                      AS Nng_Id,
                   'Основні параметри'     AS Nng_Name,
                   'T'                     AS Nng_Open_By_Def,
                   0                       AS Nng_Order
              FROM DUAL
            UNION ALL
            SELECT g.Nng_Id,
                   g.Nng_Name,
                   g.Nng_Open_By_Def,
                   g.Nng_Order
              FROM Uss_Ndi.v_Ndi_Nda_Group g
            ORDER BY Nng_Order;
    END;

    -- журнал зміни статусів звернення
    PROCEDURE get_ap_log (p_ap_id            appeal.ap_id%TYPE,
                          p_log_cursor   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_log_cursor FOR
              SELECT v_ap_log.apl_id                                          AS log_id,
                     v_ap_log.apl_ap                                          AS log_obj,
                     v_ap_log.apl_tp                                          AS log_tp,
                     v_histsession.hs_dt                                      AS log_hs_dt,
                     o.dic_name                                               AS log_st_old_name,
                     n.dic_name                                               AS log_st_name,
                     tools.getuserlogin (hs_wu)                               AS log_hs_author,
                     uss_ndi.rdm$msg_template.getmessagetext (apl_message)    AS log_message
                FROM v_appeal,
                     v_ap_log,
                     uss_ndi.v_ddn_ap_st n,
                     uss_ndi.v_ddn_ap_st o,
                     v_histsession
               WHERE     apl_st = n.dic_value(+)
                     AND apl_st_old = o.dic_value(+)
                     AND apl_hs = hs_id(+)
                     AND apl_ap = ap_id
                     AND apl_ap = p_ap_id
            ORDER BY hs_dt, apl_id;
    END;

    -- інформація по виплаті
    PROCEDURE GET_DECISION_INFO (P_PD_ID   IN     NUMBER,
                                 RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.*,
                   pa.pa_num,
                   pa.pa_org,
                   nst.nst_code || ' ' || nst.nst_name
                       AS pd_nst_name,
                   st.DIC_SNAME
                       AS pd_st_name,
                   ap.ap_id,
                   ap.ap_pc,
                   ap.ap_src_id,
                   ap.ap_tp,
                   ap.ap_reg_dt,
                   ap.ap_src,
                   ap.ap_st,
                   ap.ap_is_second,
                   ap.ap_num,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = ap.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                       AS app_main_pib,
                   uss_person.api$sc_tools.get_numident (pc.pc_sc)
                       AS App_Numident,
                   tools.get_main_addr (ap.ap_id,
                                        ap.ap_tp,
                                        pc.pc_sc,
                                        nst.nst_id)
                       AS App_Main_Address,
                   pc.pc_num,
                   pc.pc_sc,
                   NVL (
                       (  SELECT    TO_CHAR (pdap_start_dt, 'DD.MM.YYYY')
                                 || '-'
                                 || TO_CHAR (pdap_stop_dt, 'DD.MM.YYYY')
                            FROM pd_accrual_period pp
                           WHERE pdap_pd = t.pd_id AND pp.history_status = 'A'
                        ORDER BY pdap_start_dt DESC
                           FETCH FIRST ROW ONLY),          -- OPERVEIEV #80462
                          'очік: '
                       || TO_CHAR (pd_start_dt, 'DD.MM.YYYY')
                       || '-'
                       || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                       AS pd_real_period,
                   (CASE
                        WHEN     COALESCE (t.pd_is_signed, 'F') = 'F'
                             AND t.pd_st IN ('P', 'V')
                             AND t.pd_nst IN (664,
                                              269,
                                              268,
                                              267,
                                              265,
                                              249,
                                              248)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS approve_with_sign, --#77050/#78724: 1 - кнопка "Затвердити з підписом ЕЦП" доступна/ 0 - НІ
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_PD_SUSPEND_REASON z
                     WHERE z.DIC_VALUE = t.pd_suspend_reason)
                       AS pd_suspend_reason_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_ap_src z
                     WHERE z.DIC_VALUE = ap.ap_src)
                       AS ap_src_name,
                   (SELECT MAX (zp.rnp_name)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS pd_pcb_name,
                   (SELECT MAX (zp.rnp_pnp_tp)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_pnp_tp,
                   (SELECT MAX (zp.rnp_code)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_code,
                   CASE
                       WHEN t.pd_st = 'MOVE'
                       THEN
                           tools.GetUserLogin (t.com_wu)
                   END
                       AS User_Login,
                   (SELECT SUM (zq.pdp_sum)
                      FROM pd_payment zq
                     WHERE zq.pdp_pd = t.pd_id AND zq.pdp_npt = 180)
                       AS help_sum
              FROM v_pc_decision_by_pc  t
                   JOIN uss_ndi.v_ddn_pd_st st ON (st.DIC_VALUE = t.pd_st)
                   JOIN uss_ndi.v_ndi_service_type nst
                       ON (nst.nst_id = t.pd_nst)
                   JOIN pc_account pa ON (pa.pa_id = t.pd_pa)
                   JOIN uss_esr.appeal ap ON (ap.ap_id = t.pd_ap)
                   JOIN v_personalcase pc ON (pc.pc_id = ap.ap_pc)
             WHERE pd_id = p_pd_id;
    END;

    ---------------------------------------------------------------------
    --                   ДЕРЖ УТРИМАННЯ
    ---------------------------------------------------------------------
    PROCEDURE get_state_withholdings (p_pc_id        personalcase.pc_id%TYPE,
                                      p_sa_cur   OUT SYS_REFCURSOR,
                                      p_pc_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        --state alimony
        OPEN p_sa_cur FOR
            SELECT sa.ps_id,
                   pp.dpp_name,
                   pp.dpp_tax_code,
                   pp.dpp_address,                -- назва код адресса закладу
                   sa.ps_start_dt,
                   sa.ps_stop_dt,                                  --Діє з..п;
                   ap.ap_num,
                   ap.ap_reg_dt,           --№ + дата звернення (ps_ap) appeal
                   h.hs_dt, --tools.GetHistSession, --Час створення (ps_hs_ins -> histsession)
                   sa.ps_st,
                   ps.dic_name                                 AS ps_st_name, --Стан (uss_ndi.v_ddn_ps_st)
                   ps_sc,
                   uss_person.api$sc_tools.GET_PIB (ps_sc)     AS ps_sc_pib
              FROM pc_state_alimony  sa
                   LEFT JOIN uss_ndi.v_ndi_pay_person pp
                       ON pp.dpp_id = sa.ps_dpp
                   LEFT JOIN appeal ap ON ap.ap_id = sa.ps_ap
                   LEFT JOIN histsession h ON h.hs_id = sa.ps_hs_ins
                   LEFT JOIN uss_ndi.v_ddn_ps_st ps
                       ON ps.dic_value = sa.ps_st
             WHERE sa.ps_pc = p_pc_id;

        OPEN p_pc_cur FOR
              SELECT cg.psc_id,
                     cg.psc_ps,
                     cg.psc_start_dt,
                     cg.psc_stop_dt,                              --Діє з..по;
                     ap.ap_num                AS Psc_Ap_Num,
                     ap.ap_reg_dt             AS Psc_Ap_Reg_Dt, --№ + дата звернення (psc_ap);
                     cg.psc_tp,
                     pt.DIC_NAME              AS Psc_Tp_Name, --Причина зміни стану (psc_tp -> uss_ndi.v_ddn_psc_tp);
                     ppa.dppa_description     AS Psc_Dppa_Desc,
                     cg.psc_dppa              AS Psc_Dppa,
                     ppa.dppa_account         AS Psc_Dppa_Account, --Рахунок (psc_dppa -> uss_ndi.ndi_pay_person_acc);
                     h.hs_dt,     --Час створення (psc_hs_ins -> histsession);
                     cg.psc_st,
                     ps.dic_name              AS Psc_St_Name --Стан (uss_ndi.v_ddn_psc_st);
                FROM ps_changes cg
                     JOIN pc_state_alimony ON ps_id = psc_ps
                     LEFT JOIN histsession h ON h.hs_id = cg.psc_hs_ins
                     LEFT JOIN appeal ap ON ap.ap_id = cg.psc_ap
                     LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                         ON ppa.dppa_id = cg.psc_dppa
                     LEFT JOIN uss_ndi.v_ddn_psc_st ps
                         ON ps.dic_value = cg.psc_st
                     LEFT JOIN uss_ndi.v_ddn_psc_tp pt
                         ON pt.dic_value = cg.psc_tp
               WHERE cg.history_status = 'A' AND ps_pc = p_pc_id
            ORDER BY psc_stop_dt DESC;
    END;

    -- Протокол обробки Держ.утримання
    PROCEDURE GET_ALIMONY_LOG (P_PS_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT T.PSL_ID
                         AS LOG_ID,
                     T.PSL_PS
                         AS LOG_OBJ,
                     T.PSL_TP
                         AS LOG_TP,
                     ST.DIC_NAME
                         AS LOG_ST_NAME,
                     STO.DIC_NAME
                         AS LOG_ST_OLD_NAME,
                     HS.HS_DT
                         AS LOG_HS_DT,
                     NVL (TOOLS.GETUSERLOGIN (HS.HS_WU), 'Автоматично')
                         AS LOG_HS_AUTHOR,
                     USS_NDI.RDM$MSG_TEMPLATE.GETMESSAGETEXT (T.PSL_MESSAGE)
                         AS LOG_MESSAGE
                FROM PS_LOG T
                     LEFT JOIN USS_NDI.v_ddn_psc_st ST
                         ON (ST.DIC_VALUE = T.PSL_ST)
                     LEFT JOIN USS_NDI.v_ddn_psc_st STO
                         ON (STO.DIC_VALUE = T.PSL_ST_OLD)
                     LEFT JOIN V_HISTSESSION HS ON (HS.HS_ID = T.PSL_HS)
               WHERE T.PSL_PS = P_PS_ID
            ORDER BY HS.HS_DT;
    END;


    ---------------------------------------------------------------------
    --                   ВІДРАХУВАННЯ
    ---------------------------------------------------------------------

    PROCEDURE get_deductions (p_pc_id         personalcase.pc_id%TYPE,
                              p_dn_cur    OUT SYS_REFCURSOR,
                              p_dnd_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN p_dn_cur FOR
            SELECT dn.*,
                   ddu.dic_sname     AS dn_unit_name,
                   h.hs_dt           AS dn_hs_dt,
                   dpp.dpp_name      AS dn_dpp_name,
                   dds.dic_sname     AS dn_st_name,
                   ndn.ndn_name      AS dn_ndn_name
              FROM v_deduction_by_pc         dn,
                   uss_ndi.v_ddn_dn_unit     ddu,
                   histsession               h,
                   uss_ndi.v_ndi_pay_person  dpp,
                   uss_ndi.v_ddn_dn_st       dds,
                   uss_ndi.v_ndi_deduction   ndn
             WHERE     dn.dn_pc = p_pc_id
                   AND dn.dn_unit = ddu.dic_value
                   AND dn.dn_hs_return = h.hs_id(+)
                   AND dn.dn_dpp = dpp.dpp_id(+)
                   AND dn.dn_st = dds.dic_value(+)
                   AND dn.dn_ndn = ndn.ndn_id(+);

        OPEN p_dnd_cur FOR
              SELECT dnd.*,
                     --Одиниця
                     ddu.dic_sname                      AS dnd_tp_name,
                     --Банк стягувача/отримувача
                     dppa.dppa_nb                       AS dnd_dppa_nb,
                     nb.nb_mfo                          AS dnd_dppa_nb_mfo,
                     nb.nb_sname                        AS dnd_dppa_nb_name,
                     nb.nb_mfo || ' ' || nb.nb_sname    AS dnd_dppa_nb_mfoname,
                     --Рахунок стягувача/отримувача
                     dppa.dppa_account                  AS dnd_dppa_account
                FROM v_dn_detail                 dnd,
                     uss_ndi.v_ddn_dn_unit       ddu,
                     uss_ndi.v_ndi_pay_person_acc dppa,
                     uss_ndi.v_ndi_bank          nb,
                     v_deduction_by_pc           dn
               WHERE     dnd.dnd_tp = ddu.dic_value(+)
                     AND dnd.dnd_dppa = dppa.dppa_id(+)
                     AND dppa.dppa_nb = nb.nb_id(+)
                     AND dnd_dn = dn_id
                     AND dnd.history_status = 'A'
                     AND dn_pc = p_pc_id
            ORDER BY dnd.dnd_stop_dt DESC;
    END;

    PROCEDURE get_deduction_log (p_dn_id   IN     NUMBER,
                                 res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.dnl_id                                                   AS log_id,
                     t.dnl_dn                                                   AS log_obj,
                     t.dnl_tp                                                   AS log_tp,
                     st.dic_name                                                AS log_st_name,
                     sto.dic_name                                               AS log_st_old_name,
                     hs.hs_dt                                                   AS log_hs_dt,
                     tools.getuserlogin (hs.hs_wu)                              AS log_hs_author,
                     uss_ndi.rdm$msg_template.getmessagetext (t.dnl_message)    AS log_message
                FROM dn_log t
                     LEFT JOIN uss_ndi.v_ddn_dn_st st
                         ON (st.dic_value = t.dnl_st)
                     LEFT JOIN uss_ndi.v_ddn_dn_st sto
                         ON (sto.dic_value = t.dnl_st_old)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.dnl_hs)
               WHERE t.dnl_dn = p_dn_id
            ORDER BY hs.hs_dt;
    END;

    ---------------------------------------------------------------------
    --                   ВІДРАХУВАННЯ
    ---------------------------------------------------------------------
    PROCEDURE get_queue_recalc (p_paq_pc   IN     NUMBER,
                                res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
              SELECT paq_id            AS paq_id,
                     -- PERSONALCASE
                     paq_pc            AS paq_pc,
                     paq_tp            AS paq_tp,
                     dpt.DIC_SNAME     AS paq_tp_name,
                     paq_start_dt      AS paq_start_dt,
                     paq_stop_dt       AS paq_stop_dt,
                     -- PC_DECISION
                     paq_pd            AS paq_pd,
                     pd.pd_num         AS paq_pd_num,
                     -- DEDUCTION
                     paq_dn            AS paq_dn,
                     a.ap_num          AS paq_dn_ap_num,
                     dps.DIC_SNAME     AS paq_st_name,
                     -- HISTSESSION
                     hs.hs_dt          AS paq_hs_dt
                FROM V_PC_ACCRUAL_QUEUE paq
                     LEFT JOIN uss_ndi.v_ddn_paq_tp dpt
                         ON (dpt.DIC_VALUE = paq.paq_tp)
                     LEFT JOIN uss_esr.v_pc_decision_by_pc pd
                         ON (pd.pd_id = paq.paq_pd)
                     LEFT JOIN uss_esr.v_deduction d ON (d.dn_id = paq.paq_dn)
                     LEFT JOIN uss_esr.v_appeal a ON (a.ap_id = d.dn_ap)
                     LEFT JOIN uss_ndi.v_ddn_paq_st dps
                         ON (dps.DIC_VALUE = paq.paq_st)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = paq.paq_hs_ins)
               WHERE paq.paq_pc = p_paq_pc
            ORDER BY hs.HS_DT;
    END;

    --======================================================--
    --  Продвинути стан відарахування
    --======================================================--
    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$DEDUCTION.approve_deduction (p_dn_id);
    END;

    --======================================================--
    --  Продвинути стан держутримання
    --======================================================--
    PROCEDURE approve_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$PC_STATE_ALIMONY.approve_state_alimony (p_ps_id);
    END;

    --======================================================--
    --  Повернути стан відрахування на попереднью позицію
    --======================================================--
    PROCEDURE reject_deduction (p_dn_id       pc_state_alimony.ps_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$DEDUCTION.reject_deduction (p_dn_id, p_reason);
    END;

    --======================================================--
    --  Повернути стан держутримання на попереднью позицію
    --======================================================--
    PROCEDURE reject_state_alimony (p_ps_id       pc_state_alimony.ps_id%TYPE,
                                    p_reason   IN VARCHAR2 := NULL)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$PC_STATE_ALIMONY.reject_state_alimony (p_ps_id, p_reason);
    END;

    --======================================================--
    --  #101154: Закрити держутримання
    --======================================================--
    PROCEDURE close_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$PC_STATE_ALIMONY.close_state_alimony (p_ps_id);
    END;

    --======================================================--
    --  #101154: Відновити держутримання
    --======================================================--
    PROCEDURE reopen_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);
        API$PC_STATE_ALIMONY.reopen_state_alimony (p_ps_id);
    END;

    ---------------------------------------------------------------------
    --                   Соціальні послуги tab
    ---------------------------------------------------------------------
    PROCEDURE get_soc_services (p_pc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            /*SELECT d.*,
                   st.nst_code || ' ' || st.nst_name AS pd_nst_name,
                   t.pde_val_string AS provider_name
              FROM v_pc_decision d
              JOIN uss_ndi.v_ndi_service_type st
                ON (st.nst_id = d.pd_nst)
              JOIN v_appeal ap
                ON (ap.ap_id = d.pd_ap)
              LEFT JOIN pd_features t
                ON (t.pde_pd = d.pd_id)
              JOIN uss_ndi.v_ndi_pd_feature_type ft
                ON (ft.nft_id = t.pde_nft AND ft.nft_pt = 288)
             WHERE d.pd_pc = p_pc_id
               AND ap.ap_tp IN ('SS');*/
            /*   - № рішення
      - Дата затвердження рішення
      - Тип послуги
      - Надавач
      - № договору – договори у статусі SS
      - Дата укладення договору
      - Адреса надання*/
            SELECT t.at_num,
                   t.at_id,
                   (SELECT MIN (h.hs_dt)
                      FROM AT_log  L
                           JOIN uss_esr.histsession h
                               ON h.hs_id = L.ATL_HS
                     WHERE     atl_at = t.at_id
                           AND L.ATL_MESSAGE LIKE
                                   CHR (38) || '17'
                           AND l.atl_st IN ('SA', 'SD'))
                       AS at_dt,
                   (SELECT LISTAGG (st.nst_name, ', ')
                               WITHIN GROUP (ORDER BY st.nst_order)
                      FROM at_service  s
                           JOIN uss_ndi.v_ndi_service_type st
                               ON (st.nst_id = s.ats_nst)
                     WHERE s.ats_at = t.at_id AND s.history_status = 'A')
                       AS at_nst_list,
                   uss_rnsp.api$find.Get_Nsp_Name (t.at_rnspm)
                       AS at_rnspm_name,
                   at.at_num
                       AS at_tctr_num,
                   (SELECT MIN (h.hs_dt)
                      FROM AT_log  L
                           JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
                     WHERE atl_at = at.at_id AND l.atl_st IN ('DT'))
                       AS at_tctr_dt,
                   (SELECT MAX (dic_name)
                      FROM uss_ndi.v_ddn_at_tctr_st st
                     WHERE st.dic_value = at.at_st)
                       AS at_tctr_st_name
              FROM v_act  t
                   LEFT JOIN v_act at
                       ON (    at.at_main_link = t.at_id
                           AND at.at_tp = 'TCTR'
                           AND at.at_st IN ('DT', 'DPU', 'DP'))
             WHERE t.at_pc = p_pc_id AND t.at_tp IN ('PDSP');
    END;

    --------------------------------------------------------------------------
    --     Реєстраційна справа отримувача #78140
    --------------------------------------------------------------------------
    PROCEDURE get_rec_info (p_pc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.get_pib (pp.app_sc)
                       AS sc_main_pib,
                   --ІПН
                    (  SELECT p.scd_seria || p.scd_number
                         FROM uss_person.v_sc_document p
                        WHERE     p.scd_sc = sc.sc_id
                              AND p.scd_ndt = 5
                              AND p.scd_st IN ('A', '1')
                     ORDER BY TO_NUMBER (p.scd_start_dt) DESC
                        FETCH FIRST ROW ONLY)
                       AS sc_numident,
                   --#78891
                    (SELECT a.apda_val_string
                       FROM ap_document_attr  a
                            JOIN ap_document d ON a.apda_apd = d.apd_id
                      WHERE     a.apda_ap = ap.ap_id
                            AND (d.apd_ndt = 605 AND a.apda_nda = 825)
                      FETCH FIRST ROW ONLY)
                       AS apda_work_study_place,
                   (SELECT a.apda_val_dt
                      FROM ap_document_attr  a
                           JOIN ap_document d ON a.apda_apd = d.apd_id
                     WHERE     a.apda_ap = ap.ap_id
                           AND (   (d.apd_ndt = 6 AND a.apda_nda = 606)
                                OR (d.apd_ndt = 7 AND a.apda_nda = 607)
                                OR (d.apd_ndt = 37 AND a.apda_nda = 91)
                                OR (d.apd_ndt = 805 AND a.apda_nda = 1843)
                                OR (d.apd_ndt = 806 AND a.apda_nda = 1827)
                                OR (d.apd_ndt = 807 AND a.apda_nda = 1828)
                                OR (d.apd_ndt = 808 AND a.apda_nda = 1863))
                     FETCH FIRST ROW ONLY)
                       AS apda_birth_dt,
                   (CASE
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE     a.apda_ap = ap.ap_id
                                         AND (d.apd_ndt IN (6, 7, 37)))
                        THEN
                            'Україна'
                        ELSE
                            (SELECT a.apda_val_string
                               FROM ap_document_attr  a
                                    JOIN ap_document d
                                        ON a.apda_apd = d.apd_id
                              WHERE     a.apda_ap = ap.ap_id
                                    AND (   (    d.apd_ndt = 806
                                             AND a.apda_nda = 2237)
                                         OR (    d.apd_ndt = 807
                                             AND a.apda_nda = 2238)
                                         OR (    d.apd_ndt = 808
                                             AND a.apda_nda = 2104))
                                    AND a.history_status = 'A'
                              FETCH FIRST ROW ONLY)
                    END)
                       AS apda_nationality,
                   g.dic_sname
                       AS sc_gender,
                   /* (SELECT listagg(CASE WHEN a.apda_nda NOT IN (1879, 1974)THEN n.nda_name || ' ' END || a.apda_val_string, ' ') within GROUP(ORDER BY n.nda_order)
                       FROM ap_document_attr a
                       JOIN ap_document d
                         ON a.apda_apd = d.apd_id
                        --#81175
                        AND ((d.apd_ndt = 801 AND a.apda_nda IN ( 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882)) OR
                            (d.apd_ndt = 802 AND a.apda_nda IN (1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977)))
                        AND d.history_status = 'A'
                       JOIN uss_ndi.v_ndi_document_attr n
                         ON a.apda_nda = n.nda_id
                      WHERE a.apda_ap = ap.ap_id
                        AND a.history_status = 'A'
                        AND a.apda_val_string IS NOT NULL) AS apda_main_address,*/
                   tools.get_main_addr_ss (ap.ap_id, ap.ap_tp, t.pc_sc)
                       AS apda_main_address,
                   (SELECT a.apda_val_string
                      FROM ap_document_attr  a
                           JOIN ap_document d ON a.apda_apd = d.apd_id
                     WHERE     a.apda_ap = ap.ap_id
                           AND (   (d.apd_ndt = 801 AND a.apda_nda = 1883)
                                OR (d.apd_ndt = 802 AND a.apda_nda = 1978))
                           AND a.history_status = 'A'
                     FETCH FIRST ROW ONLY)
                       AS apda_phone_number,
                   app_tp.dic_sname
                       AS pc_app_tp_name
              FROM v_personalcase  t
                   JOIN v_opfu op ON (op.org_id = t.com_org)
                   JOIN uss_esr.v_appeal ap
                       ON (ap.ap_pc = t.pc_id AND ap.ap_tp = 'SS')
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.pc_sc)
                   JOIN v_ap_person pp
                       ON (    sc.sc_id = pp.app_sc
                           AND (   pp.app_ap = ap.ap_id
                                OR (    pp.app_tp = 'FM'
                                    AND EXISTS
                                            (SELECT a.apda_id
                                               FROM ap_document_attr  a
                                                    JOIN ap_document d
                                                        ON a.apda_apd =
                                                           d.apd_id
                                              WHERE     a.apda_ap = ap.ap_id
                                                    AND (   (    d.apd_ndt =
                                                                 801
                                                             AND a.apda_nda =
                                                                 1868)
                                                         OR (    d.apd_ndt =
                                                                 802
                                                             AND a.apda_nda =
                                                                 1944)
                                                         OR (    d.apd_ndt =
                                                                 803
                                                             AND a.apda_nda =
                                                                 2033))
                                                    AND a.apda_val_string =
                                                        'FM'))))
                   JOIN uss_person.v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                   JOIN uss_person.v_sc_identity i ON (i.sci_id = ch.scc_sci)
                   JOIN uss_ndi.v_ddn_pc_st st ON (st.dic_value = t.pc_st)
                   LEFT JOIN uss_ndi.v_ddn_gender g
                       ON (g.dic_value = i.sci_gender)
                   LEFT JOIN uss_ndi.v_ddn_app_tp app_tp
                       ON (app_tp.dic_value = pp.app_tp)
             WHERE t.pc_id = p_pc_id;               -- 2161; --11909;-- 11769;
    END;

    --------------------------------------------------------------------------
    ---------------------Інформація про звернення та рішення #78140
    --------------------------------------------------------------------------

    PROCEDURE get_app_dec_info (p_pc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   CASE
                       WHEN is_needs1 = 'T' OR is_needs2 = 'T' THEN 'T'
                       ELSE 'F'
                   END    app_is_needs
              FROM (SELECT ap.ap_reg_dt
                               AS ap_reg_dt,
                           uss_person.api$sc_tools.get_pib (pn.app_sc)
                               AS ap_report_name,
                           ap.com_org || ' ' || op.org_name
                               AS com_org_name,
                           pd.pd_num
                               AS ap_pd_num,
                           pd.pd_dt
                               AS ap_pd_dt,
                           NVL (
                               (SELECT a.apda_val_string
                                  FROM ap_document_attr  a
                                       JOIN ap_document d
                                           ON a.apda_apd = d.apd_id
                                 WHERE     a.apda_ap = ap.ap_id
                                       AND (   (    d.apd_ndt = 818
                                                AND a.apda_nda = 2061)
                                            OR (    d.apd_ndt = 819
                                                AND a.apda_nda = 2039))),
                               (SELECT a.pdoa_val_string
                                  FROM pd_document_attr  a
                                       JOIN pd_document d
                                           ON a.pdoa_pdo = d.pdo_id
                                 WHERE     d.pdo_ap = ap.ap_id
                                       AND a.pdoa_pd = pd.pd_id
                                       AND (   (    d.pdo_ndt = 818
                                                AND a.pdoa_nda = 2061)
                                            OR (    d.pdo_ndt = 819
                                                AND a.pdoa_nda = 2039))))
                               AS is_needs1,
                           -- #84253
                            (SELECT CASE
                                        WHEN COUNT (*) > 0 THEN 'T'
                                        ELSE 'F'
                                    END
                               FROM ap_document d
                              WHERE d.apd_ap = ap.ap_id AND d.apd_ndt = 803)
                               AS is_needs2
                      FROM v_pc_decision_by_pc  pd
                           JOIN appeal ap ON (ap.ap_id = pd.pd_ap)
                           JOIN v_ap_person pn
                               ON (pn.app_ap = ap.ap_id AND pn.app_tp = 'Z')
                           JOIN v_opfu op ON (op.org_id = ap.com_org)
                     WHERE     pd.pd_pc = p_pc_id
                           AND (pd.pd_st = 'P' OR pd.pd_st = 'O.P')) t;
    END;

    -- #81063: "Історія перебування в ОСЗН"
    PROCEDURE get_org_history (p_pc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
              SELECT t.*,
                     hs.hs_dt                        AS pl_hs_dt,
                     s.pca_doc_num                   AS pl_pca_num,
                     s.pca_doc_dt                    AS pl_pca_dt,
                     p.org_name                      AS pl_org_name,
                     tools.GetUserPib (hs.hs_wu)     AS Pl_Hs_Wu_Pib
                FROM v_pc_location t
                     JOIN histsession hs ON (hs.hs_id = t.pl_hs_ins)
                     JOIN v_opfu p ON (p.org_id = t.pl_org)
                     LEFT JOIN v_pc_attestat s ON (s.pca_id = t.pl_pca)
               WHERE t.pl_pc = p_pc_id AND t.history_status = 'A'
            ORDER BY t.pl_start_dt DESC;
    END;


    PROCEDURE Register_Doc_Hist (p_Doc_Id NUMBER, p_Dh_Id OUT NUMBER)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PERSONAL_CASE.Register_Doc_Hist');
        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => p_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => NULL,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   =>
                Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => Tools.Getcurrwu,
            p_Dh_Src         => 'VST',
            p_New_Id         => p_Dh_Id);
    END;


    -- info:   Выбор информации об документах (файлы)
    PROCEDURE Get_Pd_Docs_Files (P_PD_ID   IN     NUMBER,
                                 p_mode    IN     NUMBER,
                                 p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT d.pdo_dh
              FROM v_pd_document d
             WHERE     d.pdo_pd = P_PD_ID
                   AND (   p_mode = 0 AND d.pdo_ndt IN (804, 818, 819)
                        OR     p_mode = 1
                           AND d.pdO_ndt IN (850,
                                             851,
                                             852,
                                             853,
                                             854))
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Signed_Attachments (p_Res => p_Res);
    --Uss_Doc.Api$documents.Get_Attachments(p_Doc_Id => NULL, p_Dh_Id => NULL, p_Res => p_Res, p_Params_Mode => 3);
    END;


    -- #81511: Оцінка потреб
    PROCEDURE get_needs_doc (p_pd_id    IN     NUMBER,
                             p_flag        OUT NUMBER,
                             doc_cur       OUT SYS_REFCURSOR,
                             attr_cur      OUT SYS_REFCURSOR,
                             file_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        SELECT CASE
                   WHEN (SELECT COUNT (*)
                           FROM ap_document z
                          WHERE     z.apd_ap = t.pd_ap
                                AND z.apd_ndt = 803
                                AND z.history_status = 'A') >
                        0
                   THEN
                       0
                   WHEN t.pd_st = 'R0'
                   THEN
                       1
                   WHEN (SELECT COUNT (*)
                           FROM ap_document z
                          WHERE     z.apd_ap = t.pd_ap
                                AND z.apd_ndt IN (804, 818, 819)
                                AND z.history_status = 'A') <
                        3
                   THEN
                       1
                   WHEN (SELECT COUNT (*)
                           FROM ap_document_attr  zz
                                JOIN ap_document zzd
                                    ON (zzd.apd_id = zz.apda_apd)
                          WHERE     zz.apda_ap = t.pd_ap
                                AND (       zzd.apd_ndt = 801
                                        AND zz.apda_nda = 1870
                                        AND zz.apda_val_string = 'F'
                                     OR     zzd.apd_ndt = 802
                                        AND zz.apda_nda = 1947
                                        AND zz.apda_val_string = 'F')) >
                        0
                   THEN
                       1
                   ELSE
                       0
               END    AS Is_Rnsp_Need_Doc
          INTO p_flag
          FROM Pc_Decision t
         WHERE t.pd_id = p_pd_id;

        OPEN doc_cur FOR
            SELECT t.*, tp.ndt_name AS pdo_ndt_name
              FROM pd_Document  t
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = t.pdo_ndt)
             WHERE     t.pdo_pd = p_pd_id
                   AND t.pdo_ndt IN (804, 818, 819)
                   AND t.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*, d.pdo_doc AS doc_id
              FROM v_pd_document  d
                   JOIN v_pd_document_attr attr ON (attr.pdoa_pdo = d.pdo_id)
             WHERE     d.pdo_pd = p_pd_id
                   AND d.pdo_ndt IN (804, 818, 819)
                   AND attr.history_status = 'A';

        Get_Pd_Docs_Files (p_pd_id, 0, file_cur);
    END;

    -- #86235: Документи рішення
    PROCEDURE get_ss_docs (p_pd_id    IN     NUMBER,
                           p_mode     IN     NUMBER, -- 0 - призначення, 1 - відхилення
                           p_flag        OUT NUMBER,
                           doc_cur       OUT SYS_REFCURSOR,
                           attr_cur      OUT SYS_REFCURSOR,
                           file_cur      OUT SYS_REFCURSOR,
                           sign_cur      OUT SYS_REFCURSOR)
    IS
        l_wu   NUMBER := tools.GetCurrWu;
    BEGIN
        SELECT CASE
                   WHEN p_mode = 1 AND f3 < 2 THEN 1
                   WHEN p_mode = 0 AND f1 < 5 AND (f2 > 0 OR f4 > 0) THEN 1
                   ELSE 0
               END    AS can_add_doc
          INTO p_flag
          FROM (SELECT (SELECT COUNT (*)
                          FROM pd_document t
                         WHERE     t.pdo_pd = p_pd_id
                               AND t.pdo_ndt IN (850,
                                                 851,
                                                 852,
                                                 853,
                                                 854)
                               AND t.history_status = 'A')          AS f1,
                       (SELECT COUNT (*)
                          FROM pd_document t
                         WHERE     t.pdo_pd = p_pd_id
                               AND t.pdo_ndt IN (850, 851)
                               AND t.history_status = 'A')          AS f3,
                       (SELECT COUNT (*)
                          FROM pc_decision  t
                               JOIN ap_document d ON (d.apd_ap = t.pd_ap)
                               JOIN ap_document_attr a
                                   ON (a.apda_apd = d.apd_id)
                         WHERE     t.pd_id = p_pd_id
                               AND d.apd_ndt = 801
                               AND d.history_status = 'A'
                               AND a.apda_nda = 1870
                               AND a.history_status = 'A'
                               AND (   a.apda_val_string IS NULL
                                    OR a.apda_val_string = 'F'))    AS f2,
                       (SELECT COUNT (*)
                          FROM pc_decision  t
                               JOIN ap_document d ON (d.apd_ap = t.pd_ap)
                         WHERE     t.pd_id = p_pd_id
                               AND d.apd_ndt = 836
                               AND d.history_status = 'A')          AS f4
                  FROM DUAL) t;

        OPEN doc_cur FOR
            SELECT t.*,
                   tp.ndt_name                                  AS pdo_ndt_name,
                   (SELECT CASE
                               WHEN COUNT (*) > 0 THEN 'T'
                               ELSE 'F'
                           END
                      FROM pd_signers z
                     WHERE     z.pdi_pdo = t.pdo_id
                           AND z.history_status = 'A'
                           AND z.pdi_wu = l_wu
                           AND (   z.pdi_is_signed IS NULL
                                OR z.pdi_is_signed = 'F')
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM pd_signers q
                                     WHERE     q.pdi_pdo =
                                               z.pdi_pdo
                                           AND q.history_status =
                                               'A'
                                           AND (   q.pdi_is_signed
                                                       IS NULL
                                                OR q.pdi_is_signed =
                                                   'F')
                                           AND q.pdi_order <
                                               z.pdi_order))    AS can_sign,
                   (SELECT CASE WHEN COUNT (*) = 1 THEN 'T' ELSE 'F' END
                      FROM pd_signers z
                     WHERE     z.pdi_pdo = t.pdo_id
                           AND z.history_status = 'A'
                           AND (   z.pdi_is_signed IS NULL
                                OR z.pdi_is_signed = 'F'))      AS last_sign,
                   CASE
                       WHEN     p_mode = 1
                            AND t.pdo_ndt IN (850, 854)
                            AND d.pd_st IN ('R0', 'O.R0')
                       THEN
                           'T'
                       WHEN     p_mode = 0
                            AND t.pdo_ndt IN (850)
                            AND d.pd_st IN ('R0')
                       THEN
                           'T'
                       WHEN     p_mode = 0
                            AND t.pdo_ndt IN (854)
                            AND d.pd_st = 'O.R0'
                       THEN
                           'T'
                       WHEN t.pdo_ndt IN (851, 852, 853) AND d.pd_st = 'WD'
                       THEN
                           'T'
                       WHEN     p_mode = 1
                            AND t.pdo_ndt IN (851)
                            AND d.pd_st IN ('AV', 'O.AV')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END                                          AS can_delete
              FROM pd_Document  t
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = t.pdo_ndt)
                   JOIN pc_decision d ON (d.pd_id = t.pdo_pd)
             WHERE     t.pdo_pd = p_pd_id
                   AND t.pdo_ndt IN (850,
                                     851,
                                     852,
                                     853,
                                     854)
                   AND t.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*, d.pdo_doc AS doc_id
              FROM v_pd_document  d
                   JOIN v_pd_document_attr attr ON (attr.pdoa_pdo = d.pdo_id)
             WHERE     d.pdo_pd = p_pd_id
                   AND d.pdo_ndt IN (850,
                                     851,
                                     852,
                                     853,
                                     854)
                   AND attr.history_status = 'A';

        Get_Pd_Docs_Files (p_pd_id, 1, file_cur);

        OPEN sign_cur FOR
            SELECT t.*,
                   (SELECT MAX (z.wu_login)
                      FROM v$w_users_4gic z
                     WHERE z.wu_id = t.pdi_wu)    AS wu_Pib
              FROM pd_signers t
             WHERE t.pdi_pd = p_pd_id AND t.history_status = 'A';
    END;

    -- #86235: додавання підписанта до документу
    PROCEDURE add_signer (p_pdo_id   IN NUMBER,
                          p_pd_id    IN NUMBER,
                          p_wu_id    IN NUMBER DEFAULT NULL)
    IS
        l_wu    NUMBER := COALESCE (p_wu_id, tools.GetCurrWu);
        l_cnt   NUMBER;
    BEGIN
        --якщо повторне додавання
        FOR c
            IN (SELECT 1
                  FROM pd_signers
                 WHERE     pdi_pd = p_pd_id
                       AND pdi_pdo = p_pdo_id
                       AND pdi_wu = l_wu
                       AND history_status = 'A')
        LOOP
            raise_application_error (-20000,
                                     'Повторне додавання підписанта!');
        END LOOP;

        SELECT COUNT (*)
          INTO l_cnt
          FROM pd_signers t
         WHERE     t.pdi_pd = p_pd_id
               AND t.pdi_pdo = p_pdo_id
               AND t.history_status = 'A';


        INSERT INTO pd_signers t (pdi_pd,
                                  pdi_pdo,
                                  pdi_wu,
                                  pdi_is_signed,
                                  history_status,
                                  pdi_order)
             VALUES (p_pd_id,
                     p_pdo_id,
                     l_wu,
                     'F',
                     'A',
                     NVL (l_cnt, 0) + 1);
    END;

    -- #86235: проставлення ознаки підпису документа користувачем
    PROCEDURE set_doc_signed (p_pdo_id IN NUMBER)
    IS
        v_pd_id      pc_decision.pd_id%TYPE;
        v_pdo_ndt    pd_document.pdo_ndt%TYPE;
        v_pdo_st     pd_document.history_status%TYPE;
        v_rows_cnt   PLS_INTEGER;
    BEGIN
        SELECT pdo_pd, pdo_ndt, history_status
          INTO v_pd_id, v_pdo_ndt, v_pdo_st
          FROM pd_document
         WHERE pdo_id = p_pdo_id;

        IF v_pdo_st = 'A'
        THEN
            UPDATE pd_signers t
               SET t.pdi_is_signed = 'T', t.pdi_sign_dt = SYSDATE
             WHERE     t.pdi_pdo = p_pdo_id
                   AND t.history_status = 'A'
                   AND t.pdi_wu = tools.GetCurrWu
                   AND COALESCE (t.pdi_is_signed, 'F') = 'F';

            v_rows_cnt := SQL%ROWCOUNT;

            IF v_rows_cnt = 0
            THEN
                raise_application_error (-20000,
                                         'Неуспішне підписання документа!');
            END IF;

            --проставлення ознаки підписання в рішення
            IF v_pdo_ndt IN (850, 852) AND v_rows_cnt > 0
            THEN
                UPDATE pc_decision
                   SET pd_is_signed = 'T'
                 WHERE pd_id = v_pd_id AND COALESCE (pd_is_signed, 'F') = 'F';
            END IF;
        ELSE
            raise_application_error (
                -20000,
                'Неможливо підписати неактуальний документ!');
        END IF;
    END;

    -- #86235: Список документів які можна створити
    PROCEDURE get_doc_tp_list (p_pd_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
        l_has_r1   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_OPER') = TRUE THEN 1
                   ELSE 0
               END;
        l_has_r2   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_APPROVE') = TRUE
                   THEN
                       1
                   ELSE
                       0
               END;
        l_org_to   NUMBER := tools.GetCurrOrgTo;
    BEGIN
        /*1) ndt_id in (850):
        - рішення по зверненню має статус R0
        - на вкладці рішення «Надавач» ознака «Надати в інтернатному закладі» = Ні
        - на вкладці рішення «Надавач» ознака «Передати на область» = Ні
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
        - користувач рівня ТГ/району
        2) ndt_id in (851):
        - рішення по зверненню має статус WD
        - на вкладці рішення «Надавач» ознака «Надати в інтернатному закладі» = Ні
        - на вкладці рішення «Надавач» ознака «Передати на область» = Ні
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
        - користувач рівня ТГ/району
        3) ndt_id in (852, 853):
        - рішення по зверненню має статус WD
        - на вкладці рішення «Надавач» ознака «Надати в інтернатному закладі» = Так
        - на вкладці рішення «Надавач» ознака «Передати на область» = Так
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
        - користувач рівня ТГ/району
        4) ndt_id in (854):
        Варіант 1:
        - рішення по зверненню має статус R0
        - на вкладці рішення «Надавач» ознака «Надати в інтернатному закладі» = Так
        - на вкладці рішення «Надавач» ознака «Передати на область» = Ні
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
        - користувач рівня ТГ/району
        Варіант 2:
        - рішення по зверненню має статус O.R0
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
        - користувач рівня області */

        OPEN res_cur FOR
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (850)
                   AND l_has_r1 = 1
                   AND l_org_to IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision  z
                                   LEFT JOIN pd_features f1
                                       ON (    f1.pde_pd = z.pd_id
                                           AND f1.pde_nft = 32)
                                   LEFT JOIN pd_features f2
                                       ON (    f2.pde_pd = z.pd_id
                                           AND f2.pde_nft = 33)
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st = 'R0'
                                   AND (   f1.pde_val_string IS NULL
                                        OR f1.pde_val_string = 'F')
                                   AND (   f2.pde_val_string IS NULL
                                        OR f2.pde_val_string = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id)
            UNION
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (851)
                   AND l_has_r2 = 1
                   AND l_org_to IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision  z
                                   LEFT JOIN pd_features f1
                                       ON (    f1.pde_pd = z.pd_id
                                           AND f1.pde_nft = 32)
                                   LEFT JOIN pd_features f2
                                       ON (    f2.pde_pd = z.pd_id
                                           AND f2.pde_nft = 33)
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st = 'WD'
                                   AND (   f1.pde_val_string IS NULL
                                        OR f1.pde_val_string = 'F')
                                   AND (   f2.pde_val_string IS NULL
                                        OR f2.pde_val_string = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id)
            UNION
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (852, 853)
                   AND l_has_r2 = 1
                   AND l_org_to IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision  z
                                   LEFT JOIN pd_features f1
                                       ON (    f1.pde_pd = z.pd_id
                                           AND f1.pde_nft = 32)
                                   LEFT JOIN pd_features f2
                                       ON (    f2.pde_pd = z.pd_id
                                           AND f2.pde_nft = 33)
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st = 'WD'
                                   AND f1.pde_val_string = 'T'
                                   AND f2.pde_val_string = 'T')
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id)
            UNION
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (854)
                   AND l_has_r1 = 1
                   AND l_org_to IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision  z
                                   LEFT JOIN pd_features f1
                                       ON (    f1.pde_pd = z.pd_id
                                           AND f1.pde_nft = 32)
                                   LEFT JOIN pd_features f2
                                       ON (    f2.pde_pd = z.pd_id
                                           AND f2.pde_nft = 33)
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st = 'R0'
                                   AND f1.pde_val_string = 'T'
                                   AND (   f2.pde_val_string IS NULL
                                        OR f2.pde_val_string = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id)
            UNION
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (854)
                   AND l_has_r1 = 1
                   AND l_org_to IN (31)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision z
                             WHERE z.pd_id = P_PD_ID AND z.pd_st = 'O.R0')
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id);
    END;

    -- #89729: Список документів які можна створити
    -- Підписання SS-рішень про відмову в наданні СП
    PROCEDURE get_rej_doc_tp_list (p_pd_id   IN     NUMBER,
                                   res_cur      OUT SYS_REFCURSOR)
    IS
        l_has_r1   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_OPER') = TRUE THEN 1
                   ELSE 0
               END;
        l_has_r2   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_APPROVE') = TRUE
                   THEN
                       1
                   ELSE
                       0
               END;
        l_org_to   NUMBER := tools.GetCurrOrgTo;
    BEGIN
        /*1) ndt_id in (850):
            - десіжини:
            -- рішення по зверненню має статус R0/O.R0
            -- відсутній документ, який намагаються створити, у статусі ‘A’
            -- користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            -- користувач рівня ТГ/району/області
            - акти: (тут немає)
            -- рішення по зверненню має статус SR
            -- відсутній документ, який намагаються створити, у статусі ‘A’
            -- користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            -- користувач рівня ТГ/району/області
         2) ndt_id in (851):
            - рішення по зверненню має статус AV/O.AV
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
            - користувач рівня ТГ/району/області
            - акти: (тут немає)
            -- рішення по зверненню має статус SN/O.SN
            -- відсутній документ, який намагаються створити, у статусі ‘A’
            -- користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            -- користувач рівня ТГ/району/області */

        OPEN res_cur FOR
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (850)
                   AND l_has_r1 = 1
                   AND l_org_to IN (31, 32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision z
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st IN ('R0', 'O.R0'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id)
            UNION
            SELECT t.ndt_id             AS id,
                   ndt_is_have_scan     AS code,
                   t.ndt_name           AS NAME
              FROM uss_ndi.v_ndi_document_type t
             WHERE     t.ndt_id IN (851)
                   AND l_has_r2 = 1
                   AND l_org_to IN (31, 32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM pc_decision z
                             WHERE     z.pd_id = P_PD_ID
                                   AND z.pd_st IN ('AV', 'O.AV'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_document zz
                             WHERE     zz.pdo_pd = p_pd_id
                                   AND zz.history_status = 'A'
                                   AND zz.pdo_ndt = t.ndt_id);
    END;

    -- #86235: створення нового документу
    PROCEDURE create_doc (p_ndt_id    IN     NUMBER,
                          p_pd_id     IN     NUMBER,
                          p_pdo_doc   IN     NUMBER,
                          p_pdo_dh    IN     NUMBER,
                          p_pdo_id       OUT NUMBER)
    IS
    BEGIN
        --#86747 перевірка наявності ініціативного документа
        IF p_ndt_id IN (850,
                        851,
                        852,
                        853,
                        854)
        THEN
            FOR c
                IN (SELECT (SELECT ndt_name
                              FROM uss_ndi.v_ndi_document_type t
                             WHERE ndt_id = 801)         AS init_ndt_name,
                           (SELECT ndt_name
                              FROM uss_ndi.v_ndi_document_type t
                             WHERE ndt_id = p_ndt_id)    AS ndt_name
                      FROM (SELECT COUNT (1)     AS ndt801
                              FROM v_pc_decision
                                   JOIN v_ap_document
                                       ON     apd_ap = pd_ap
                                          AND apd_ndt = 801
                                          AND history_status = 'A'
                             WHERE pd_id = p_pd_id
                            HAVING COUNT (1) = 0))
            LOOP
                raise_application_error (
                    -20000,
                       'Заборонено створювати документ "'
                    || c.ndt_name
                    || '" якщо в зверненні відсутній документ "'
                    || c.init_ndt_name
                    || '"!');
            END LOOP;
        END IF;

        save_document (p_pdo_id,
                       p_pd_id,
                       NULL,
                       p_pdo_doc,
                       p_pdo_dh,
                       NULL,
                       p_ndt_id,
                       NULL,
                       NULL);
    END;

    -- #86235: створення вкладення для документу
    PROCEDURE create_doc_attach (p_pdo_id IN NUMBER, p_blob OUT BLOB)
    IS
        v_pdo_pd    pd_document.pdo_pd%TYPE;
        v_pdo_ndt   pd_document.pdo_ndt%TYPE;
    BEGIN
        SELECT d.pdo_pd, d.pdo_ndt
          INTO v_pdo_pd, v_pdo_ndt
          FROM v_pd_document d
         WHERE pdo_id = p_pdo_id;

        p_blob :=
            dnet$pd_reports.get_decision_doc_attach (p_pd_id    => v_pdo_pd,
                                                     p_ndt_id   => v_pdo_ndt);

        IF DBMS_LOB.getlength (p_blob) = 0
        THEN
            raise_application_error (-20000, 'Вкладення не сформовано!');
        END IF;
    END;

    -- #86235: видача інформації для формування підпису
    PROCEDURE get_sign_attach_info (p_pdo_id   IN     NUMBER,
                                    res_cur       OUT SYS_REFCURSOR)
    IS
        v_curr_org   NUMBER (14) := tools.getcurrorg;
    BEGIN
        OPEN res_cur FOR
            SELECT o.org_code || TO_CHAR (pd.pd_dt, 'YYYY') || d.pdo_id
                       AS barcode,
                      o.org_name
                   || ';'
                   || pd.pd_num
                   || ' від '
                   || TO_CHAR (pd.pd_dt, 'DD.MM.YYYY')
                       AS qrcode,
                   o.org_name,
                   TO_CHAR (pd.pd_dt, 'DD.MM.YYYY') || ' ' || pd.pd_num
                       AS card_info,
                      (SELECT t.ndt_name
                         FROM uss_ndi.v_ndi_document_type t
                        WHERE t.ndt_id = d.pdo_ndt)
                   || ' '
                   || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                   || '.pdf'
                       AS filename,
                   NULL /*dnet$pd_reports.get_decision_doc_attach(p_pd_id => d.pdo_pd, p_ndt_id => d.pdo_ndt)*/
                       AS content,
                   d.pdo_doc,
                   d.pdo_dh
              FROM v_pd_document  d
                   JOIN v_pc_decision pd ON pd.pd_id = d.pdo_pd
                   JOIN ikis_sysweb.v$v_opfu_all o ON o.org_id = v_curr_org
             WHERE     d.pdo_id = p_pdo_id
                   AND d.pdo_ndt IN (850,
                                     851,
                                     852,
                                     853,
                                     854)
                   AND d.history_status = 'A';
    END;

    PROCEDURE Add_Attr (p_Attrs     IN OUT t_Pd_Document_Attrs,
                        p_Pdo_Id    IN     NUMBER,
                        p_Nda_Id    IN     NUMBER,
                        p_Val_Str   IN     VARCHAR2 DEFAULT NULL,
                        p_Val_Dt    IN     DATE DEFAULT NULL,
                        p_Val_Id    IN     NUMBER DEFAULT NULL,
                        p_Val_Sum   IN     NUMBER DEFAULT NULL,
                        p_Val_Int   IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF p_Attrs IS NULL
        THEN
            p_Attrs := t_Pd_Document_Attrs ();
        END IF;

        IF     p_Val_Str IS NULL
           AND p_Val_Dt IS NULL
           AND p_Val_Id IS NULL
           AND p_Val_Sum IS NULL
           AND p_Val_Int IS NULL
        THEN
            RETURN;
        END IF;

        p_Attrs.EXTEND ();
        p_Attrs (p_Attrs.COUNT).Pdoa_Pdo := p_Pdo_Id;
        p_Attrs (p_Attrs.COUNT).Pdoa_Nda := p_Nda_Id;
        p_Attrs (p_Attrs.COUNT).Pdoa_Val_String := p_Val_Str;
        p_Attrs (p_Attrs.COUNT).Pdoa_Val_Dt := p_Val_Dt;
        p_Attrs (p_Attrs.COUNT).Pdoa_Val_Id := p_Val_Id;
        p_Attrs (p_Attrs.COUNT).Pdoa_Val_Sum := p_Val_Sum;
        p_Attrs (p_Attrs.COUNT).Pdoa_Val_Int := p_Val_Int;
    END;

    FUNCTION Get_Attr_Val_Str (p_Pd_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Pd_Document_Attr.Pdoa_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Pdoa_Val_String)
          INTO l_Result
          FROM Pd_Document_Attr  a
               JOIN Pd_Document d
                   ON     a.Pdoa_Pdo = d.Pdo_Id
                      AND d.History_Status = 'A'
                      AND d.Pdo_Pd = p_Pd_Id
         WHERE     a.Pdoa_Pd = p_Pd_Id
               AND a.Pdoa_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_App_Sci (p_Ap_Id IN NUMBER, p_App_Tp IN VARCHAR2)
        RETURN Uss_Person.v_Sc_Identity%ROWTYPE
    IS
        l_Sci   Uss_Person.v_Sc_Identity%ROWTYPE;
    BEGIN
        SELECT i.*
          INTO l_Sci
          FROM Ap_Person  p
               JOIN Uss_Person.v_Sc_Change c ON p.App_Scc = c.Scc_Id
               JOIN Uss_Person.v_Sc_Identity i ON c.Scc_Sci = i.Sci_Id
         WHERE     p.App_Ap = p_Ap_Id
               AND p.History_Status = 'A'
               AND p.App_Tp = p_App_Tp
         FETCH FIRST ROW ONLY;

        RETURN l_Sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Sci;
    END;

    --повертає персону з переважним типом p_App_Tp, у разі відсутності - кого попало
    FUNCTION Get_App_Sci_2 (p_Ap_Id IN NUMBER, p_App_Tp IN VARCHAR2)
        RETURN Uss_Person.v_Sc_Identity%ROWTYPE
    IS
        l_Sci   Uss_Person.v_Sc_Identity%ROWTYPE;
    BEGIN
          SELECT i.*
            INTO l_Sci
            FROM Ap_Person p
                 JOIN Uss_Person.v_Sc_Change c ON p.App_Scc = c.Scc_Id
                 JOIN Uss_Person.v_Sc_Identity i ON c.Scc_Sci = i.Sci_Id
           WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A'
        ORDER BY DECODE (p.App_Tp, p_App_Tp, 0, 1)
           FETCH FIRST ROW ONLY;

        RETURN l_Sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Sci;
    END;

    FUNCTION Get_Pd_Feature_Str (p_Pd_Id IN NUMBER, p_Nft_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Pd_Features.Pde_Val_String%TYPE;
    BEGIN
        SELECT MAX (f.Pde_Val_String)
          INTO l_Result
          FROM Pd_Features f
         WHERE f.Pde_Pd = p_Pd_Id AND f.Pde_Nft = p_Nft_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Pd_Feature_Id (p_Pd_Id IN NUMBER, p_Nft_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   Pd_Features.Pde_Val_Id%TYPE;
    BEGIN
        SELECT MAX (f.Pde_Val_Id)
          INTO l_Result
          FROM Pd_Features f
         WHERE f.Pde_Pd = p_Pd_Id AND f.Pde_Nft = p_Nft_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Pd_Reject_Rsn_List (p_Pd_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (r.Njr_Name, ', ') WITHIN GROUP (ORDER BY r.Njr_Order)
          INTO l_result
          FROM Pd_Reject_Info  i
               JOIN Uss_Ndi.v_Ndi_Reject_Reason r ON i.Pri_Njr = r.Njr_Id
         WHERE i.Pri_Pd = p_Pd_Id AND r.History_Status = 'A';

        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION Fill_Attrs_850 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs
    IS
        l_Pd            Pc_Decision%ROWTYPE;
        l_Ap            Appeal%ROWTYPE;
        l_Sci_z         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os        Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Pd_Calc       Pd_Income_Calc%ROWTYPE;
        l_Spec_Wu       NUMBER;
        l_Spec_Wu_Pib   Tools.r_Pib;
        l_Boss_Wu       NUMBER;
        l_Boss_Wu_Pib   Tools.r_Pib;
        l_Attrs         t_Pd_Document_Attrs;
    BEGIN
        --Отримуємо інформацію про рішення
        SELECT *
          INTO l_Pd
          FROM Pc_Decision d
         WHERE d.Pd_Id = p_Pd_Id;

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_Pd.Pd_Ap;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_Pd.Pd_Ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_Pd.Pd_Ap, 'OS');

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_Pd_Calc
              FROM Pd_Income_Calc c
             WHERE c.Pic_Pd = p_Pd_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про спеціаліста та керівника
        BEGIN
            --#86997
            SELECT MAX (DECODE (rn, 1, pdi_wu))       FIRST_VALUE,
                   MAX (DECODE (rn, cnt, pdi_wu))     LAST_VALUE
              INTO l_Spec_Wu, l_Boss_Wu
              FROM (SELECT s.pdi_wu,
                           ROW_NUMBER ()
                               OVER (ORDER BY NVL (s.pdi_order, s.pdi_id))
                               rn,
                           COUNT (*) OVER ()
                               cnt
                      FROM pd_signers s, pd_document d
                     WHERE     s.pdi_pd = p_pd_id
                           AND s.history_status = 'A'
                           --and d.pdo_id = p_Pdo_Id
                           AND d.pdo_id = s.pdi_pdo
                           AND d.history_status = 'A'
                           AND d.pdo_ndt = 850);

            Tools.Split_Pib (Tools.Getuserpib (l_Spec_Wu), l_Spec_Wu_Pib);
            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2934,
                  p_Val_Dt   => l_Pd.Pd_Dt);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2935,
                  p_Val_Str   => l_Pd.Pd_Num);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2936,
                  p_Val_Str   => tools.GetOrgName (l_Pd.Com_Org),
                  p_Val_Id    => l_Pd.Com_Org);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2937,
                  p_Val_Dt   => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2938,
                  p_Val_Str   => l_Ap.Ap_Num);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2939,
                  p_Val_Str   => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2940,
                  p_Val_Str   => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2941,
                  p_Val_Str   => l_Sci_z.Sci_Mn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2942,
                  p_Val_Str   => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2943,
                  p_Val_Str   => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2944,
                  p_Val_Str   => l_Sci_Os.Sci_Mn);
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2945,
            p_Val_Str   =>
                COALESCE (Get_Attr_Val_Str (p_Pd_Id, 2039),
                          Get_Attr_Val_Str (p_Pd_Id, 2061)));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2946,
                  p_Val_Id    => Get_Pd_Feature_Id (p_Pd_Id, 9),
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 9));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2947,
                  p_Val_Sum   => l_Pd_Calc.Pic_Total_Income_6m);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2948,
                  p_Val_Sum   => l_Pd_Calc.Pic_Month_Income);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2949,
                  p_Val_Sum   => l_Pd_Calc.Pic_Member_Month_Income);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2950,
                  p_Val_Sum   => l_Pd_Calc.Pic_Limit);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2951,
                  p_Val_Id   => l_Pd.Pd_Nst);
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2952,
            p_Val_Str   =>
                CASE
                    WHEN l_Pd.Pd_St IN ('PV', 'AV', 'V') THEN 'F'
                    ELSE 'T'
                END);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2953,
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 10));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2954,
                  p_Val_Str   => Get_Pd_Reject_Rsn_List (p_pd_id));
        --Add_Attr(l_Attrs, p_Pdo_Id, 3082); --посада спеціаліста з опрацювання заяв
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2955,
                  p_Val_Str   => l_Spec_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2956,
                  p_Val_Str   => l_Spec_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2957,
                  p_Val_Str   => l_Spec_Wu_Pib.Mn);
        --Add_Attr(l_Attrs, p_Pdo_Id, 3083); --посада керівника
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2958,
                  p_Val_Str   => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2959,
                  p_Val_Str   => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2960,
                  p_Val_Str   => l_Boss_Wu_Pib.Mn);
        RETURN l_Attrs;
    END;

    FUNCTION Fill_Attrs_851 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs
    IS
        l_Pd            Pc_Decision%ROWTYPE;
        l_Sci_z         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os        Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu       NUMBER;
        l_Boss_Wu_Pib   Tools.r_Pib;
        l_Attrs         t_Pd_Document_Attrs;
    BEGIN
        --Отримуємо інформацію про рішення
        SELECT *
          INTO l_Pd
          FROM Pc_Decision d
         WHERE d.Pd_Id = p_Pd_Id;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_Pd.Pd_Ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_Pd.Pd_Ap, 'OS');

        --Отримуємо інформацію про підписанта(керівника)
        BEGIN
              SELECT s.Pdi_Wu
                INTO l_Boss_Wu
                FROM Pd_Signers s
               WHERE s.Pdi_Pd = p_Pd_Id AND s.History_Status = 'A'
            ORDER BY NVL (s.pdi_order, s.pdi_id) DESC
               FETCH FIRST ROW ONLY;

            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2975,
                  p_Val_Id    => l_Pd.Com_Org,
                  p_Val_Str   => tools.GetOrgName (l_Pd.Com_Org));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2961,
                  p_Val_Dt   => l_Pd.Pd_Dt);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2962,
                  p_Val_Str   => l_Pd.Pd_Num);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2963,
                  p_Val_Str   => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2964,
                  p_Val_Str   => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2965,
                  p_Val_Str   => l_Sci_z.Sci_Mn);
        --Індекс
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2966,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_Pd.Pd_Ap, 801, 1886),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1886));
        --КАТОТТГ
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2967,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_Pd.Pd_Ap, 801, 1885),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1885));
        -- Вулиця
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2968,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_Pd.Pd_Ap, 801, 1891),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1891));
        --Будинок
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2969,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1892));
        --Корпус
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2970,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1893));
        --Квартира
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2971,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_Pd.Pd_Ap, 801, 1894));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2972,
                  p_Val_Str   => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2973,
                  p_Val_Str   => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2974,
                  p_Val_Str   => l_Sci_Os.Sci_Mn);
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            2997,
            p_Val_Str   =>
                CASE
                    WHEN l_Pd.Pd_St IN ('PV', 'AV', 'V') THEN 'F'
                    ELSE 'T'
                END);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3084,
                  p_Val_Id    => Get_Pd_Feature_Id (p_Pd_Id, 9),
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 9));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2976,
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 10));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2977,
                  Get_Pd_Reject_Rsn_List (p_Pd_Id));
        --Add_Attr(l_Attrs, p_Pdo_Id, 3085);--посада керівника
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2978,
                  p_Val_Str   => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2979,
                  p_Val_Str   => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2980,
                  p_Val_Str   => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    FUNCTION Fill_Attrs_852 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs
    IS
        l_Pd             Pc_Decision%ROWTYPE;
        l_Ap             Appeal%ROWTYPE;
        l_Org_Name       VARCHAR2 (250);
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_z          Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
        l_Attrs          t_Pd_Document_Attrs;
    BEGIN
        --Отримуємо інформацію про рішення
        SELECT *
          INTO l_Pd
          FROM Pc_Decision d
         WHERE d.Pd_Id = p_Pd_Id;

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_Pd.Pd_Ap;

        --Отримуємо назву СПСЗН
        SELECT o.Org_Name, Oo.Org_Name, Oo.Org_Id
          INTO l_Org_Name, l_Org_Org_Name, l_Org_Org_Id
          FROM v_Opfu o LEFT JOIN v_Opfu Oo ON o.Org_Org = Oo.Org_Id
         WHERE o.Org_Id = l_Pd.Com_Org;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_Pd.Pd_Ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_Pd.Pd_Ap, 'OS');

        --Отримуємо інформацію про підписанта(керівника)
        BEGIN
              SELECT s.Pdi_Wu
                INTO l_Boss_Wu
                FROM Pd_Signers s
               WHERE s.Pdi_Pd = p_Pd_Id AND s.History_Status = 'A'
            ORDER BY NVL (s.pdi_order, s.pdi_id) DESC
               FETCH FIRST ROW ONLY;

            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2982,
                  p_Val_Id    => l_Org_Org_Id,
                  p_Val_Str   => l_Org_Org_Name);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2983,
                  p_Val_Str   => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2984,
                  p_Val_Str   => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2985,
                  p_Val_Str   => l_Sci_z.Sci_Mn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2986,
                  p_Val_Dt   => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2987,
                  p_Val_Str   => l_Ap.Ap_Num);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2988,
                  p_Val_Id    => l_Pd.Com_Org,
                  p_Val_Str   => l_Org_Name);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2989,
                  p_Val_Str   => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2990,
                  p_Val_Str   => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2991,
                  p_Val_Str   => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2992,
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 10));
        --Add_Attr(l_Attrs, p_Pdo_Id, 2993);--посада підписанта
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2994,
                  p_Val_Str   => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2995,
                  p_Val_Str   => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2996,
                  p_Val_Str   => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    FUNCTION Fill_Attrs_853 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs
    IS
        CURSOR c_pd IS
            SELECT d.pd_ap,
                   d.pd_pc,
                   d.Com_Org,
                   o.org_name,
                   o.org_to,
                   p.app_id,
                   p.app_tp
              FROM pc_decision   d,
                   personalcase  pc,
                   Ap_Person     p,
                   v_opfu        o
             WHERE     d.pd_id = p_Pd_Id
                   AND pc.pc_id = d.pd_pc
                   AND p.app_sc = pc.pc_sc
                   AND p.app_ap = d.pd_ap
                   AND o.org_id = d.com_org;

        l_pd             c_pd%ROWTYPE;
        --l_Pd           Pc_Decision%ROWTYPE;
        l_Ap             Appeal%ROWTYPE;
        l_Pd_Calc        Pd_Income_Calc%ROWTYPE;
        --l_Org_Name     VARCHAR2(250);
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_z          Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
        l_Attrs          t_Pd_Document_Attrs;
    BEGIN
        --Отримуємо інформацію про рішення
        --SELECT * INTO l_Pd FROM Pc_Decision d WHERE d.Pd_Id = p_Pd_Id;
        OPEN c_pd;

        FETCH c_pd INTO l_pd;

        CLOSE c_pd;

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_Pd.Pd_Ap;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci_2 (l_Pd.Pd_Ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci_2 (l_Pd.Pd_Ap, 'OS');

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_Pd_Calc
              FROM Pd_Income_Calc c
             WHERE c.Pic_Pd = p_Pd_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про підписанта(керівника)
        BEGIN
              SELECT s.Pdi_Wu
                INTO l_Boss_Wu
                FROM Pd_Signers s
               WHERE s.Pdi_Pd = p_Pd_Id AND s.History_Status = 'A'
            ORDER BY NVL (s.pdi_order, s.pdi_id) DESC
               FETCH FIRST ROW ONLY;

            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF l_pd.org_to > 31
        THEN
                SELECT MAX (CASE WHEN po.org_to IN (31, 34) THEN po.org_name END)
                  INTO l_Org_Org_Name
                  FROM opfu po
                 WHERE po.org_st = 'A'
            START WITH po.org_id = l_pd.com_org
            CONNECT BY PRIOR po.org_org = po.org_id;
        ELSE
            l_Org_Org_Name := l_pd.org_name;
        END IF;

        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2998,
                  p_Val_Str   => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  2999,
                  p_Val_Str   => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3000,
                  p_Val_Str   => l_Sci_z.Sci_Mn);

        --Місце фактичного проживання
        /*--Індекс
        Add_Attr(l_Attrs,
                 p_Pdo_Id,
                 3001,
                 p_Val_Id  => Api$appeal.Get_Ap_z_Doc_Id(l_Pd.Pd_Ap, 801, 1886),
                 p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1886));
        --КАТОТТГ
        Add_Attr(l_Attrs,
                 p_Pdo_Id,
                 3002,
                 p_Val_Id  => Api$appeal.Get_Ap_z_Doc_Id(l_Pd.Pd_Ap, 801, 1885),
                 p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1885));
        -- Вулиця
        Add_Attr(l_Attrs,
                 p_Pdo_Id,
                 3003,
                 p_Val_Id  => Api$appeal.Get_Ap_z_Doc_Id(l_Pd.Pd_Ap, 801, 1891),
                 p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1891));
        --Будинок
        Add_Attr(l_Attrs, p_Pdo_Id, 3004, p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1892));
        --Корпус
        Add_Attr(l_Attrs, p_Pdo_Id, 3005, p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1893));
        --Квартира
        Add_Attr(l_Attrs, p_Pdo_Id, 3006, p_Val_Str => Api$appeal.Get_Ap_z_Doc_String(l_Pd.Pd_Ap, 801, 1894));*/

        --Місце фактичного проживання #86997
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3001,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1625)); --Індекс
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3002,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1618)); --КАТОТТГ
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3003,
            p_Val_Str   =>
                COALESCE (
                    Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1632),
                    Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1640))); -- Вулиця
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3004,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1648)); --Будинок
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3005,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1654)); --Корпус
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3006,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1659)); --Квартира



        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3007,
                  p_Val_Id    => l_Pd.Com_Org,
                  p_Val_Str   => l_pd.Org_Name); --найменування СПСЗН місцевого рівня
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3008,
                  p_Val_Dt   => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3009,
                  p_Val_Str   => l_Ap.Ap_Num);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3010,
                  p_Val_Id    => l_Org_Org_Id,
                  p_Val_Str   => l_Org_Org_Name); --найменування СПСЗН обласного рівня
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3011,
                  p_Val_Dt   => SYSDATE);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3012,
                  p_Val_Str   => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3013,
                  p_Val_Str   => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3014,
                  p_Val_Str   => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3015,
                  p_Val_Sum   => l_Pd_Calc.Pic_Member_Month_Income);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3016,
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 10));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3017,
                  p_Val_Str   => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3018,
                  p_Val_Str   => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3019,
                  p_Val_Str   => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    FUNCTION Fill_Attrs_854 (p_Pd_Id IN NUMBER, p_Pdo_Id IN NUMBER)
        RETURN t_Pd_Document_Attrs
    IS
        TYPE tAdr IS RECORD
        (
            indx     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --Індекс
            katot    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,          --КАТОТТГ
            strit    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --вулиця
            bild     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,          --будинок
            korp     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --Корпус
            apart    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE          --квартира
        );

        rAdr_reg         tAdr;
        rAdr_fakt        tAdr;

        CURSOR c_ftr IS
            SELECT MAX (DECODE (pde_nft, 3, f.pde_val_string))
                       AS a_3026,                         --група інвалідності
                   MAX (DECODE (pde_nft, 9, f.pde_val_string))
                       AS a_3021,  --найменування інтернатної установи/закладу
                   MAX (DECODE (pde_nft, 9, f.pde_val_id))
                       AS a_3021_id,
                   MAX (DECODE (pde_nft, 11, f.pde_val_dt))
                       AS a_3048,                      --Термін перебування по
                   MAX (DECODE (pde_nft, 12, f.pde_val_dt))
                       AS a_3047,                       --Термін перебування з
                   MAX (DECODE (pde_nft, 13, f.pde_val_dt))
                       AS a_3045,                       --Строк дії путівки по
                   MAX (DECODE (pde_nft, 14, f.pde_val_dt))
                       AS a_3044,                        --Строк дії путівки з
                   MAX (DECODE (pde_nft, 81, f.pde_val_string))
                       AS a_3046                            -- Тип перебування
              FROM pd_features f
             WHERE     f.pde_pd = p_Pd_Id
                   AND f.pde_nft IN (3,
                                     9,
                                     11,
                                     12,
                                     13,
                                     14,
                                     81);

        l_ftr            c_ftr%ROWTYPE;

        CURSOR c_pd IS
            SELECT d.pd_ap,
                   d.pd_pc,
                   d.Com_Org,
                   p.app_id,
                   p.app_tp
              FROM pc_decision d, personalcase pc, Ap_Person p
             WHERE     d.pd_id = p_Pd_Id
                   AND pc.pc_id = d.pd_pc
                   AND p.app_sc = pc.pc_sc
                   AND p.app_ap = d.pd_ap;

        l_pd             c_pd%ROWTYPE;
        --l_Pd           Pc_Decision%ROWTYPE;

        l_Pd_Calc        Pd_Income_Calc%ROWTYPE;
        l_Org_Name       VARCHAR2 (250);
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_birth_dt       DATE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu2       NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
        l_Boss_Wu_Pib2   Tools.r_Pib;
        l_Attrs          t_Pd_Document_Attrs;
    BEGIN
        --Отримуємо інформацію про рішення
        --SELECT * INTO l_Pd FROM Pc_Decision d WHERE d.Pd_Id = p_Pd_Id;
        OPEN c_pd;

        FETCH c_pd INTO l_pd;

        CLOSE c_pd;

        --Отримуємо назву СПСЗН
        SELECT o.Org_Name, Oo.Org_Name, Oo.Org_Id
          INTO l_Org_Name, l_Org_Org_Name, l_Org_Org_Id
          FROM v_Opfu o LEFT JOIN v_Opfu Oo ON o.Org_Org = Oo.Org_Id
         WHERE o.Org_Id = l_Pd.Com_Org;

        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci_2 (l_Pd.Pd_Ap, l_pd.app_tp);

        --день народження
        SELECT MAX (i.sco_birth_dt)
          INTO l_birth_dt
          FROM uss_person.v_sc_info i
         WHERE i.sco_id = l_Sci_Os.sci_sc;

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_Pd_Calc
              FROM Pd_Income_Calc c
             WHERE c.Pic_Pd = p_Pd_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про підписанта(керівника) СПСЗН
        BEGIN
              SELECT s.pdi_wu
                INTO l_boss_wu
                FROM pd_signers s, pd_document d
               WHERE     s.pdi_pd = p_pd_id
                     AND s.history_status = 'A'
                     AND d.pdo_id = p_Pdo_Id
                     AND s.history_status = 'A'
                     AND d.pdo_id = s.pdi_pdo
                     AND d.history_status = 'A'
                     AND d.pdo_ndt = 854
            ORDER BY NVL (s.pdi_order, s.pdi_id) DESC
               FETCH FIRST ROW ONLY;

            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про керівника підрозділу з питань діяльності інтернатних установ
        BEGIN
              SELECT s.pdi_wu
                INTO l_boss_wu2
                FROM pd_signers s, pd_document d
               WHERE     s.pdi_pd = p_pd_id
                     AND s.history_status = 'A'
                     AND d.pdo_id = p_Pdo_Id
                     AND s.history_status = 'A'
                     AND d.pdo_id = s.pdi_pdo
                     AND d.history_status = 'A'
                     AND d.pdo_ndt = 854
            ORDER BY NVL (s.pdi_order, s.pdi_id)
               FETCH FIRST ROW ONLY;

            Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu2), l_Boss_Wu_Pib2);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        -- дані путівки, ets
        OPEN c_ftr;

        FETCH c_ftr INTO l_ftr;

        CLOSE c_ftr;

        --Місце фактичного проживання
        rAdr_fakt.indx :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1625);
        rAdr_fakt.katot :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1618);
        rAdr_fakt.strit :=
            COALESCE (
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1632),
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1640));
        rAdr_fakt.bild :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1648);
        rAdr_fakt.korp :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1654);
        rAdr_fakt.apart :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1659);
        --Реєстрація
        rAdr_reg.indx :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1489);
        rAdr_reg.katot :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1488);
        rAdr_reg.strit :=
            COALESCE (
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1490),
                Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1591));
        rAdr_reg.bild :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1599);
        rAdr_reg.korp :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1605);
        rAdr_reg.apart :=
            Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1611);

        Add_Attr (l_Attrs, p_Pdo_Id, 3020);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3021,
                  p_Val_Id    => l_ftr.a_3021_id,
                  p_Val_Str   => l_ftr.a_3021);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3022,
                  p_Val_Str   => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3023,
                  p_Val_Str   => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3024,
                  p_Val_Str   => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3025,
                  p_Val_Dt   => l_birth_dt);
        Add_Attr (
            l_Attrs,
            p_Pdo_Id,
            3026,
            p_Val_Str   =>
                COALESCE (
                    Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 1790),
                    Api$appeal.Get_Ap_Doc_Str (l_Pd.Pd_Ap, l_Pd.App_Tp, 349),
                    l_ftr.a_3026));                       --група інвалідності
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3027,
                  p_Val_Str   => Get_Pd_Feature_Str (p_Pd_Id, 10));
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3028,
                  p_Val_Sum   => l_Pd_Calc.Pic_Member_Month_Income);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3029,
                  p_Val_Sum   => l_Pd_Calc.Pic_Limit);
        Add_Attr (l_Attrs, p_Pdo_Id, 3030); --"Виплата" - зараз це константа "державної соціальної допомоги" у звіті
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3031,
                  p_Val_Str   => l_Org_Name);            --виплата проводиться

        --Місце фактичного проживання
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3032,
                  p_Val_Str   => rAdr_fakt.indx);                     --Індекс
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3033,
                  p_Val_Str   => rAdr_fakt.katot);                   --КАТОТТГ
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3034,
                  p_Val_Str   => rAdr_fakt.strit);                   -- Вулиця
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3035,
                  p_Val_Str   => rAdr_fakt.bild);                    --Будинок
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3036,
                  p_Val_Str   => rAdr_fakt.korp);                     --Корпус
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3037,
                  p_Val_Str   => rAdr_fakt.apart);                  --Квартира

        --Реєстрація
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3038,
                  p_Val_Str   => rAdr_reg.indx);                      --Індекс
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3039,
                  p_Val_Str   => rAdr_reg.katot);                    --КАТОТТГ
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3040,
                  p_Val_Str   => rAdr_reg.strit);                    -- Вулиця
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3041,
                  p_Val_Str   => rAdr_reg.bild);                     --Будинок
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3042,
                  p_Val_Str   => rAdr_reg.korp);                      --Корпус
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3043,
                  p_Val_Str   => rAdr_reg.apart);                   --Квартира


        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3044,
                  p_Val_Dt   => l_ftr.a_3044);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3045,
                  p_Val_Dt   => l_ftr.a_3045);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3046,
                  p_Val_Str   => l_ftr.a_3046);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3047,
                  p_Val_Dt   => l_ftr.a_3047);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3048,
                  p_Val_Dt   => l_ftr.a_3048);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3049,
                  p_Val_Dt   => SYSDATE);
        Add_Attr (l_Attrs, p_Pdo_Id, 3050); --Посада керівника підрозділу з питань діяльності інтернатних установ
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3051,
                  p_Val_Str   => l_Boss_Wu_Pib2.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3052,
                  p_Val_Str   => l_Boss_Wu_Pib2.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3053,
                  p_Val_Str   => l_Boss_Wu_Pib2.Mn);
        Add_Attr (l_Attrs, p_Pdo_Id, 3055);           --Посада керівника СПСЗН
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3056,
                  p_Val_Str   => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3057,
                  p_Val_Str   => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs,
                  p_Pdo_Id,
                  3058,
                  p_Val_Str   => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;


    PROCEDURE Save_Document (p_Pdo_Id     IN OUT NUMBER,
                             p_Pd_Id      IN     NUMBER,
                             p_Ap_Id      IN     NUMBER,
                             p_Doc_Id     IN     NUMBER,
                             p_Dh_Id      IN     NUMBER,
                             p_Pdo_App    IN     NUMBER,
                             p_Pdo_Ndt    IN     NUMBER,
                             p_Attr_Xml   IN     CLOB,
                             p_File_Xml   IN     CLOB)
    IS
        l_Attr     t_Pd_Document_Attrs;
        p_New_Id   NUMBER := p_Pdo_Id;
        l_New_Id   NUMBER;
    BEGIN
        IF (p_Pdo_Id IS NULL OR p_Pdo_Id < 0)
        THEN
            SELECT COUNT (*)
              INTO l_New_Id
              FROM Pd_Document t
             WHERE     t.Pdo_Pd = p_Pd_Id
                   AND t.Pdo_Ndt = p_Pdo_Ndt
                   AND t.History_Status = 'A';

            IF (l_New_Id > 0)
            THEN
                Raise_Application_Error (
                    -20000,
                    'Документ такого типу вже створений. Будь-ласка, редагуйте його!');
            END IF;

            Api$documents.Save_Pd_Document (NULL,
                                            p_Doc_Id,
                                            p_Dh_Id,
                                            p_Ap_Id,
                                            p_Pdo_App,
                                            NULL,
                                            NULL,
                                            p_Pdo_Ndt,
                                            p_Pd_Id,
                                            p_New_Id);
        ELSE
            SELECT COUNT (*)
              INTO l_New_Id
              FROM Pd_Document t
             WHERE     t.Pdo_Pd = p_Pd_Id
                   AND t.Pdo_Ndt = p_Pdo_Ndt
                   AND t.Pdo_Id != p_Pdo_Id
                   AND t.History_Status = 'A';

            IF (l_New_Id > 0)
            THEN
                Raise_Application_Error (
                    -20000,
                    'Документ такого типу вже створений. Будь-ласка, редагуйте його!');
            END IF;

            Api$documents.Save_Pd_Document (p_Pdo_Id,
                                            p_Doc_Id,
                                            p_Dh_Id,
                                            p_Ap_Id,
                                            p_Pdo_App,
                                            NULL,
                                            NULL,
                                            p_Pdo_Ndt,
                                            p_Pd_Id,
                                            p_New_Id);
        END IF;

        p_Pdo_Id := p_New_Id;

        IF p_Pdo_Ndt IN (850,
                         851,
                         852,
                         853,
                         854)
        THEN
            EXECUTE IMMEDIATE   'BEGIN :p_Attrs := uss_esr.DNET$PERSONAL_CASE.Fill_Attrs_'
                             || p_Pdo_Ndt
                             || '(p_Pd_Id=>:p_Pd_Id, p_Pdo_Id=>:p_Pdo_Id); END;'
                USING OUT l_Attr, IN p_Pd_Id, IN p_Pdo_Id;
        ELSE
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Pd_Document_Attrs',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Attr
                USING p_Attr_Xml;
        END IF;

        FOR Rec
            IN (SELECT a.Deleted,
                       NVL (a.Pdoa_Id, Da.Pdoa_Id)     AS Pdoa_Id,
                       a.Pdoa_Nda,
                       a.Pdoa_Val_Int                  AS Val_Int,
                       a.Pdoa_Val_Dt                   AS Val_Dt,
                       a.Pdoa_Val_String               AS Val_String,
                       a.Pdoa_Val_Id                   AS Val_Id,
                       a.Pdoa_Val_Sum                  AS Val_Sum
                  FROM TABLE (l_Attr)  a
                       LEFT JOIN Pd_Document_Attr Da
                           ON     Da.Pdoa_Pdo = p_Pdo_Id
                              AND a.Pdoa_Nda = Da.Pdoa_Nda
                              AND Da.History_Status = 'A')
        LOOP
            IF Rec.Deleted = 1 AND Rec.Pdoa_Id > 0
            THEN
                --Видаляємо атрибут
                Api$documents.Delete_Pd_Document_Attr (p_Id => Rec.Pdoa_Id);
            ELSE
                Api$documents.Save_Pd_Document_Attr (
                    p_Pdoa_Id           => Rec.Pdoa_Id,
                    p_Pdoa_Pdo          => p_Pdo_Id,
                    p_Pdoa_Pd           => p_Pd_Id,
                    p_Pdoa_Nda          => Rec.Pdoa_Nda,
                    p_Pdoa_Val_Int      => Rec.Val_Int,
                    p_Pdoa_Val_Dt       => Rec.Val_Dt,
                    p_Pdoa_Val_String   => Rec.Val_String,
                    p_Pdoa_Val_Id       => Rec.Val_Id,
                    p_Pdoa_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_New_Id);
            END IF;
        END LOOP;

        IF p_File_Xml IS NOT NULL
        THEN
            --Зберігаємо вкладення документа
            Uss_Doc.Api$documents.Save_Attach_List (
                p_Doc_Id        => p_Doc_Id,
                p_Dh_Id         => NULL,
                p_Attachments   => Xmltype (p_File_Xml));
        END IF;
    END;

    PROCEDURE delete_document (p_pdo_Id IN NUMBER)
    IS
    BEGIN
        --!!!12.06.2023 підписані документи можуть видалятись
        --обробка підписантів документа
        /*FOR c IN (SELECT COUNT(CASE s.pdi_is_signed WHEN 'T' THEN s.pdi_id END) AS signed,
                         COUNT(CASE coalesce(s.pdi_is_signed, 'F') WHEN 'F' THEN s.pdi_id END) AS not_signed
                    FROM v_pd_signers s
                   WHERE s.pdi_pdo = p_pdo_id
                     AND s.history_status = 'A'
                     AND EXISTS (SELECT 1
                                   FROM v_pd_document d
                                  WHERE d.pdo_id = p_pdo_id
                                    AND d.pdo_ndt IN (850, 851, 852, 853, 854)
                                    AND d.history_status = 'A')) LOOP
          IF c.signed > 1 AND c.not_signed = 0 THEN
            raise_application_error(-20000, 'Заборонено видаляти підписаний документ!');
          ELSE
            UPDATE pd_signers SET history_status = 'H' WHERE pdi_pdo = p_pdo_id AND history_status = 'A';

            --зняття ознаки підписання в рішення
            FOR c1 IN (SELECT d.pdo_pd
                         FROM v_pd_document d
                        WHERE d.pdo_id = p_pdo_id
                          AND d.pdo_ndt IN (850, 852)
                          AND d.history_status = 'A')
            LOOP
              UPDATE pc_decision
                 SET pd_is_signed = 'F'
               WHERE pd_id = c1.pdo_pd
                 AND pd_is_signed = 'T';
            END LOOP;
          END IF;
        END LOOP;*/

        --зняття ознаки підписання в рішення
        UPDATE pc_decision
           SET pd_is_signed = 'F'
         WHERE     pd_is_signed = 'T'
               AND EXISTS
                       (SELECT 1
                          FROM v_pd_document
                         WHERE     pdo_id = p_pdo_id
                               AND pdo_ndt IN (850,
                                               851,
                                               852,
                                               853,
                                               854)
                               AND history_status = 'A'
                               AND pdo_pd = pd_id);

        UPDATE pd_signers
           SET history_status = 'H'
         WHERE pdi_pdo = p_pdo_id AND history_status = 'A';

        api$documents.delete_pd_document (p_pdo_id);
    END;

    -- #84104
    PROCEDURE GET_PR_SHEET_BY_PC (P_PC_ID   IN     NUMBER,
                                  RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.*,
                     tp.DIC_SNAME
                         AS prs_tp_name,
                        '№'
                     || t.prs_remit_num
                     || ' від '
                     || TO_CHAR (t.prs_remit_dt, 'DD.MM.YYYY')
                         AS Prs_Remit_Dt_Num,
                     t.prs_ln || ' ' || t.prs_fn || ' ' || t.prs_mn
                         AS prs_pib,
                     b.nb_mfo || ' ' || b.nb_name
                         AS Prs_Nb_Name,
                     --npt_code AS prs_npt_code,
                     --npt_name AS prs_npt_name,
                      (SELECT MAX (z.DIC_NAME)
                         FROM uss_ndi.v_ddn_prs_st z
                        WHERE z.DIC_VALUE = t.prs_st)
                         AS prs_st_name,
                     (SELECT MAX (z.DIC_NAME)
                        FROM uss_ndi.v_ddn_pr_st z
                       WHERE z.DIC_VALUE = pr.pr_st)
                         AS pr_st_name,
                     pr.pr_st,
                     pr_Pay_Tp,
                        nd.nd_code
                     || ' '
                     || nd.nd_comment
                     || CASE
                            WHEN po.npo_id IS NOT NULL
                            THEN
                                   ' ('
                                || po.npo_index
                                || ' '
                                || po.npo_address
                                || ')'
                        END
                         AS prs_nd_name,
                     uss_person.api$sc_tools.get_vpo_num (pc.pc_sc)
                         AS vpo_num,
                     -- p.npt_id,
                     -- p.npt_code || ' ' || p.npt_name AS prs_npt_name
                     с.npc_code || ' ' || с.npc_name
                         AS pr_Npc_Name,
                     pr.com_org
                         AS pr_org_name,
                     pr.com_org
                         AS pr_org,
                     pr.pr_npc,
                     pr.pr_month,
                     CASE
                         WHEN (SELECT COUNT (*)
                                 FROM payroll_reestr z
                                WHERE z.pe_pr = pr_id) > 0
                         THEN
                             1
                         ELSE
                             0
                     END
                         AS pr_has_pe,
                     (SELECT MAX (zp.com_org_src)
                        FROM payroll_reestr z
                             JOIN pay_order zp ON (zp.po_id = z.pe_po)
                       WHERE z.pe_pr = t.prs_pr)
                         AS pe_org
                FROM pr_sheet t
                     JOIN payroll pr ON (pr.pr_id = t.prs_pr)
                     LEFT JOIN personalcase pc ON (pc.pc_id = t.prs_pc)
                     LEFT JOIN uss_ndi.v_ddn_prs_tp tp
                         ON (tp.DIC_VALUE = t.prs_tp)
                     LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.prs_nb)
                     -- LEFT JOIN uss_ndi.v_ndi_payment_type p ON (p.npt_id = t.prs_npt)
                     LEFT JOIN uss_ndi.v_ndi_payment_codes с
                         ON (с.npc_id = pr.pr_npc)
                     LEFT JOIN uss_ndi.v_ndi_delivery nd
                         ON (nd.nd_id = t.prs_nd)
                     LEFT JOIN uss_ndi.v_ndi_post_office po
                         ON (po.npo_id = nd.nd_npo)
               WHERE prs_pc = P_PC_ID
            ORDER BY                 /* p.npt_code || ' ' || p.npt_name ASC,*/
                     t.prs_pay_dt DESC;
    END;

    -- #84489
    PROCEDURE get_deduction_persons (p_dn_id   IN     NUMBER,
                                     res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.dnp_sc)    AS dnp_pib,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_inv_state z
                     WHERE z.DIC_VALUE = t.dnp_inv_state)        AS dnp_inv_state_name
              FROM dn_person t
             WHERE t.dnp_dn = p_dn_id AND t.history_status = 'A';
    END;

    -- #98731
    PROCEDURE get_dcz_sc_tab (p_sc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR /*WITH props AS
                          (SELECT to_date('01011900', 'ddmmyyyy') dt
                             FROM dual)
                         SELECT t.*
                           FROM Uss_Esr.Me_Dcz_Result_Rows t
                          WHERE Mdsr_Sc = p_sc_id
                            AND NOT EXISTS (SELECT 1
                                   FROM Uss_Esr.Me_Dcz_Result_Rows t2, props
                                  WHERE t.mdsr_sc = t2.mdsr_sc
                                    AND t.mdsr_id < t2.mdsr_id
                                    AND nvl(t.mdsr_d_start, props.dt) = nvl(t2.mdsr_d_start, props.dt)
                                    AND nvl(t.mdsr_d_sb, props.dt) = nvl(t2.mdsr_d_sb, props.dt)
                                    AND nvl(t.mdsr_d_work, props.dt) = nvl(t2.mdsr_d_work, props.dt)
                                    AND nvl(t.mdsr_d_voucher, props.dt) = nvl(t2.mdsr_d_voucher, props.dt)
                                    AND nvl(t.mdsr_d_end, props.dt) = nvl(t2.mdsr_d_end, props.dt)
                                    AND nvl(t.mdsr_d_stop, props.dt) = nvl(t2.mdsr_d_stop, props.dt));*/
                         SELECT DISTINCT t.mdsr_d_start,
                                         t.mdsr_d_sb,
                                         t.mdsr_d_work,
                                         t.mdsr_d_voucher,
                                         t.mdsr_d_end,
                                         t.mdsr_d_stop
                           FROM Uss_Esr.Me_Dcz_Result_Rows t
                          WHERE Mdsr_Sc = p_sc_id;
    END;

    -- #105029: В картці СРКО додати закладку "Сім'я"
    PROCEDURE get_sc_family_info (p_sc_Id   IN     NUMBER,
                                  res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            WITH
                dat
                AS
                    (SELECT d.*
                       FROM ap_person  f
                            JOIN pc_decision d
                                ON (   d.pd_ap = f.app_ap
                                    OR d.pd_ap_reason = f.app_ap)
                      WHERE     f.app_sc = p_sc_Id
                            AND d.pd_st IN ('S', 'PS')
                            AND f.history_status = 'A')
            SELECT DISTINCT
                   d.pd_id,
                   ap.app_sc
                       AS sc_id,
                   d.pd_num || ' (' || s.nst_name || ')'
                       AS pd_info,
                   CASE WHEN ap.app_sc = p_sc_Id THEN st.DIC_NAME END
                       AS pd_St_Name,
                   CASE WHEN ap.app_sc = p_sc_Id THEN com_org END
                       AS com_org,
                   CASE
                       WHEN ap.app_sc = p_sc_Id
                       THEN
                           NVL (
                               TRIM (
                                   BOTH '-' FROM
                                       (SELECT    TO_CHAR (
                                                      MIN (pdap_start_dt),
                                                      'DD.MM.YYYY')
                                               || '-'
                                               || TO_CHAR (
                                                      MAX (pdap_stop_dt),
                                                      'DD.MM.YYYY')
                                          FROM pd_accrual_period pp
                                         WHERE     pdap_pd = d.pd_id
                                               AND pp.history_status = 'A')),
                                  'очік: '
                               || TO_CHAR (pd_start_dt, 'DD.MM.YYYY')
                               || '-'
                               || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                   END
                       AS Pd_Real_Period,
                   atp.DIC_NAME
                       AS pdf_tp_name,
                   sc.sc_unique,
                   uss_person.api$sc_tools.GET_PIB (sc.sc_id)
                       AS pib,
                   (SELECT zr.DIC_NAME
                      FROM ap_person  zp
                           JOIN ap_document zd ON (zd.apd_app = zp.app_id)
                           JOIN ap_document_attr az
                               ON (az.apda_apd = zd.apd_id)
                           JOIN uss_ndi.V_DDN_RELATION_TP zr
                               ON (zr.DIC_VALUE = az.apda_val_string)
                     WHERE     zp.app_ap = d.pd_ap
                           AND az.history_status = 'A'
                           AND zp.history_status = 'A'
                           AND zd.history_status = 'A'
                           AND az.apda_nda = 649
                           AND zp.app_sc = ap.app_sc
                     FETCH FIRST ROW ONLY)
                       AS relation_tp_name,
                   CASE WHEN ap.app_sc = p_sc_Id THEN 1 ELSE 0 END
                       AS is_original
              FROM dat  d
                   JOIN uss_ndi.v_ndi_service_type s ON (s.nst_id = d.pd_nst)
                   --join pd_family f on (d.pd_id = f.pdf_pd)
                   JOIN ap_person ap
                       ON (ap.app_ap = d.pd_ap OR ap.app_ap = d.pd_ap_reason)
                   JOIN uss_ndi.v_ddn_app_tp atp
                       ON (atp.DIC_VALUE = ap.app_tp)
                   --join uss_ndi.v_ddn_pdf_tp tp on (tp.DIC_VALUE = f.pdf_tp)
                   JOIN uss_ndi.v_Ddn_Pd_St st ON (st.DIC_VALUE = d.pd_st)
                   --join personalcase pc on (pc.pc_sc = f.pdf_sc)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = ap.app_sc)
             --order by decode (f.pdf_sc, p_sc_Id, 1, 10), ap.app_id asc
             WHERE ap.history_status = 'A';
    END;

    -- #112784: В картці СРКО додати закладку "Родинні зв'язки"
    PROCEDURE get_sc_veteran_family_info (p_sc_Id   IN     NUMBER,
                                          res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            WITH
                dat
                AS
                    (SELECT p.*
                       FROM ap_person f JOIN appeal p ON (p.ap_id = f.app_ap)
                      WHERE     f.app_sc = p_sc_Id
                            AND p.ap_tp = 'REG'
                            AND EXISTS
                                    (SELECT *
                                       FROM ap_service s
                                      WHERE     s.aps_ap = p.ap_id
                                            AND s.history_status = 'A'
                                            AND s.aps_nst = 1141)
                            --and p.ap_st in () -- лише верифіковане звернення попадає сюди, тож напевно статус неважливий
                            AND f.history_status = 'A')
              SELECT DISTINCT
                     d.ap_id,
                     d.ap_reg_dt,
                     ap.app_sc
                         AS sc_id,
                     CASE WHEN ap.app_sc = p_sc_Id THEN com_org END
                         AS com_org,
                        '№'
                     || d.ap_num
                     || ' від '
                     || TO_CHAR (d.ap_reg_Dt, 'DD.MM.YYYY')
                         AS Ap_Info,
                     --atp.DIC_NAME as app_tp_name,
                     sc.sc_unique,
                     uss_person.api$sc_tools.GET_PIB (ap.app_sc)
                         AS pib,
                     uss_person.api$sc_tools.GET_BIRTHDATE (ap.app_sc)
                         AS birthdate,
                     (SELECT zr.DIC_NAME
                        FROM ap_person zp
                             JOIN ap_document zd ON (zd.apd_app = zp.app_id)
                             JOIN ap_document_attr az
                                 ON (az.apda_apd = zd.apd_id)
                             JOIN uss_ndi.V_DDN_RELATION_TP zr
                                 ON (zr.DIC_VALUE = az.apda_val_string)
                       WHERE     zp.app_ap = d.ap_id
                             AND az.history_status = 'A'
                             AND zp.history_status = 'A'
                             AND zd.history_status = 'A'
                             AND az.apda_nda = 649
                             AND zp.app_sc = ap.app_sc
                       FETCH FIRST ROW ONLY)
                         AS relation_tp_name,
                     (SELECT MAX (at.nda_name)
                        FROM ap_document zd
                             JOIN ap_document_attr az
                                 ON (az.apda_apd = zd.apd_id)
                             JOIN uss_ndi.v_ndi_document_attr at
                                 ON (at.nda_id = az.apda_nda)
                       WHERE     zd.apd_ap = d.ap_id
                             AND zd.apd_app = ap.app_id
                             AND az.history_status = 'A'
                             AND zd.history_status = 'A'
                             AND az.apda_nda IN (8421, 8420)
                             AND az.apda_val_string = 'T'
                       FETCH FIRST ROW ONLY)
                         AS app_tp_name,
                     CASE WHEN ap.app_sc = p_sc_Id THEN 1 ELSE 0 END
                         AS is_original
                FROM dat d
                     JOIN ap_person ap ON (ap.app_ap = d.ap_id)
                     --join uss_ndi.v_ddn_app_tp atp on (atp.DIC_VALUE = ap.app_tp)
                     JOIN uss_person.v_socialcard sc ON (sc.sc_id = ap.app_sc)
               WHERE ap.history_status = 'A'
            --and sc.sc_id != p_sc_Id
            ORDER BY d.ap_reg_dt DESC;
    END;

    PROCEDURE move_pc_to_other_org (p_pc_id     personalcase.pc_id%TYPE,
                                    p_new_org   personalcase.com_org%TYPE,
                                    p_reason    VARCHAR2)
    IS
    BEGIN
        IF     TOOLS.GetCurrOrgTo NOT IN (40)
           AND NOT tools.is_role_assigned ('W_ESR_PAYROLL')
        THEN
            raise_application_error (
                -20000,
                'Тільки користувач ІОЦ з роллю "Технолог виплатних відомостей" може виконувати цю функцію!');
        END IF;

        API$PERSONALCASE.move_pc_to_other_org (p_pc_id, p_new_org, p_reason);
    END;
BEGIN
    NULL;
END DNET$PERSONAL_CASE;
/