/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ESR_ACTION
IS
    -- Author  : OLEKSII
    -- Created : 19.10.2021 10:24:39
    -- Purpose : Обработка очереди на копирование из Visit в ESR


    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --==========================================
    PROCEDURE Start_Queue;

    PROCEDURE Stop_Queue;

    --==========================================
    PROCEDURE preparewrite_visit_ap_aps_log (
        p_ap_id         appeal.ap_id%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_wu            histsession.hs_wu%TYPE:= NULL);

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    PROCEDURE PrepareWrite_Visit_ap_log (
        p_pdl_pd        pd_log.pdl_pd%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_WU            histsession.hs_wu%TYPE:= NULL);

    PROCEDURE preparewrite_visit_ap_log (
        p_eva_ap        esr2visit_actions.eva_ap%TYPE,
        p_eva_st_old    esr2visit_actions.eva_st_old%TYPE,
        p_eva_pd        esr2visit_actions.eva_pd%TYPE,
        p_eva_message   esr2visit_actions.eva_message%TYPE);

    PROCEDURE preparewrite_visit_ap_st (
        p_eva_ap        esr2visit_actions.eva_ap%TYPE,
        p_eva_st_new    esr2visit_actions.eva_st_new%TYPE,
        p_eva_message   esr2visit_actions.eva_message%TYPE,
        p_hs_ins        esr2visit_actions.eva_hs_ins%TYPE);

    --#87281  2023.06.01
    PROCEDURE preparewrite_visit_at_log (
        p_atl_at        at_log.atl_at%TYPE,
        p_atl_message   at_log.atl_message%TYPE,
        p_atl_tp        at_log.atl_tp%TYPE:= 'SYS',
        p_wu            histsession.hs_wu%TYPE:= NULL);



    PROCEDURE copy_pdo_2apd (p_ap_id      IN appeal.ap_id%TYPE,
                             p_list_ndt      VARCHAR2);

    PROCEDURE copy_esr2visit_doc741 (p_ap_id IN appeal.ap_id%TYPE);

    /*
      PROCEDURE write_Visit_ap_log(
                             p_pdl_pd      pd_log.pdl_pd%TYPE,
                             p_apl_message ap_log.apl_message%TYPE,
                             p_apl_tp      ap_log.apl_tp%TYPE := 'SYS',
                             p_WU          histsession.hs_wu%TYPE := NULL);
    */
    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE PrepareCopy_ESR2Visit (
        p_ap        appeal.ap_id%TYPE,
        p_ST_OLD    esr2visit_actions.eva_st_old%TYPE,
        p_message   esr2visit_actions.eva_message%TYPE);

    --==========================================
    --  Обработка очереди
    --  Commit;
    --==========================================
    PROCEDURE Copy_ESR2Visit;

    FUNCTION Get_esr2visit_html (p_ap NUMBER)
        RETURN XMLTYPE;
END API$ESR_Action;
/


/* Formatted on 8/12/2025 5:49:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ESR_ACTION
IS
    g_hs   histsession.hs_id%TYPE;

    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --==========================================
    PROCEDURE Start_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsesr
           SET prm_value = '1'
         WHERE prm_code = 'CE2V';

        COMMIT;
    END;

    --==========================================
    PROCEDURE Stop_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsesr
           SET prm_value = '0'
         WHERE prm_code = 'CE2V';

        COMMIT;
    END;

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    --#73634 2021.12.02
    PROCEDURE write_Visit_ap_log (
        p_pdl_pd        pd_log.pdl_pd%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_WU            histsession.hs_wu%TYPE:= NULL)
    IS
        CURSOR ap IS
            SELECT ap_id, ap_st
              FROM appeal JOIN pc_decision ON ap_id = pd_ap
             WHERE pd_id = p_pdl_pd;
    BEGIN
        FOR p IN ap
        LOOP
            uss_visit.api$ap_processing.Write_Log (p.Ap_Id,
                                                   p.Ap_St,
                                                   p_Apl_Message,
                                                   p.Ap_St,
                                                   p_apl_tp,
                                                   p_WU);
        END LOOP;

        NULL;
    END;

    --==========================================
    --  Логирование
    --==========================================
    PROCEDURE LOG (p_eva       esr2visit_actions.eva_id%TYPE,
                   p_message   eva_log.eval_message%TYPE)
    IS
    BEGIN
        IF g_hs IS NULL
        THEN
            g_hs := TOOLS.GetHistSession ();
        END IF;

        INSERT INTO eva_log (eval_id,
                             eval_eva,
                             eval_hs,
                             eval_message)
             VALUES (0,
                     p_eva,
                     g_hs,
                     p_message);
    END;

    --==========================================
    PROCEDURE LogA (p_message eva_log.eval_message%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        LOG (NULL, p_message);
        COMMIT;
    END;

    --==========================================
    --Перевірка та отримання додаткових данних для логів звернення
    --#113797
    --==========================================
    PROCEDURE GetLogDetails (
        p_eva_message     IN     VARCHAR2,
        p_eva_pd_st_new   IN     VARCHAR2,
        p_pd_id           IN     uss_esr.pc_decision.pd_id%TYPE,
        p_pd_dt              OUT uss_esr.pc_decision.pd_dt%TYPE,
        p_pd_start_dt        OUT uss_esr.pc_decision.pd_start_dt%TYPE,
        p_pd_end_dt          OUT uss_esr.pc_decision.pd_stop_dt%TYPE,
        p_pd_sum             OUT uss_esr.pd_payment.pdp_sum%TYPE)
    IS
        l_count   NUMBER;
    BEGIN
        --Для звернень із Дії отримуємо додаткову інформації по рішеню
        --та повідомленю "Передано для формування виплатних відомостей"
        IF p_eva_message = '&' || '38' AND p_eva_pd_st_new = 'S'
        THEN
            SELECT COUNT (*)
              INTO l_count
              FROM uss_esr.pc_decision, uss_esr.appeal
             WHERE pd_id = p_pd_id AND pd_ap = ap_id AND ap_src = 'DIIA';

            IF l_count > 0
            THEN
                SELECT pd.pd_dt,
                       pd.pd_start_dt,
                       pd.pd_stop_dt,
                       (SELECT SUM (pdp.pdp_sum)
                          FROM uss_esr.pd_payment pdp
                         WHERE     pdp.pdp_pd = pd_id
                               AND pdp.history_status = 'A'
                               AND TRUNC (SYSDATE) BETWEEN pdp.pdp_start_dt
                                                       AND pdp.pdp_stop_dt)    AS pdp_sum
                  INTO p_pd_dt,
                       p_pd_start_dt,
                       p_pd_end_dt,
                       p_pd_sum
                  FROM uss_esr.pc_decision pd
                 WHERE pd.pd_id = p_pd_id;
            END IF;
        END IF;
    END;

    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE PrepareCopy_ESR2Visit (
        p_ap        appeal.ap_id%TYPE,
        p_ST_OLD    esr2visit_actions.eva_st_old%TYPE,
        p_message   esr2visit_actions.eva_message%TYPE)
    IS
        l_EVA   NUMBER;
    BEGIN
        g_hs := TOOLS.GetHistSession ();

        SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

        INSERT INTO esr2visit_actions (eva_id,
                                       eva_ap,
                                       eva_tp,
                                       eva_st_new,
                                       eva_st_old,
                                       eva_message,
                                       eva_hs_ins,
                                       eva_hs_exec)
            SELECT l_eva,
                   Ap_Id,
                   Ap_TP,
                   Ap_St,
                   p_ST_OLD,
                   p_message,
                   g_hs,
                   (CASE
                        WHEN ap_tp = 'V' AND ap_src = 'ASOPD' THEN g_hs
                        ELSE -1
                    END)
              FROM Appeal
             WHERE Ap_Id = p_Ap;

        IF SQL%ROWCOUNT > 0
        THEN
            LOG (l_eva, CHR (38) || '24#' || p_ap);
        ELSE
            LOG (NULL, CHR (38) || '25#' || p_ap);
        END IF;
    END;

    --==========================================
    PROCEDURE preparewrite_visit_ap_aps_log (
        p_ap_id         appeal.ap_id%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_wu            histsession.hs_wu%TYPE:= NULL)
    IS
        l_eva   NUMBER;

        CURSOR ap IS
            SELECT ap_id,
                   ap_tp,
                   ap_st,
                   'P'     AS x_st
              FROM appeal JOIN ap_service ON aps_ap = ap_id
             WHERE ap_id = p_ap_id;
    BEGIN
        g_hs := tools.gethistsession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

            INSERT INTO esr2visit_actions (eva_id,
                                           eva_ap,
                                           eva_tp,
                                           eva_st_new,
                                           eva_st_old,
                                           eva_message,
                                           eva_hs_ins,
                                           eva_pd_st_new,
                                           eva_hs_exec)
                 VALUES (l_eva,
                         p_ap_id,
                         p.ap_tp,
                         p.ap_st,
                         p.ap_st,
                         p_apl_message,
                         g_hs,
                         p.x_st,
                         -1);
        END LOOP;
    END;

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    --#73634 2021.12.02
    PROCEDURE preparewrite_visit_ap_log (
        p_pdl_pd        pd_log.pdl_pd%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_wu            histsession.hs_wu%TYPE:= NULL)
    IS
        l_eva   NUMBER;

        CURSOR ap IS
            SELECT ap_id,
                   ap_tp,
                   ap_st,
                   pd_id,
                   pd_st,
                   ap_src
              FROM appeal JOIN pc_decision ON ap_id = pd_ap
             WHERE pd_id = p_pdl_pd;
    BEGIN
        g_hs := tools.gethistsession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

            IF p.ap_tp = 'V' AND p.ap_src = 'ASOPD'
            THEN
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_pd,
                                               eva_pd_st_new,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p.ap_st,
                             p.ap_st,
                             p_apl_message,
                             g_hs,
                             p.pd_id,
                             p.pd_st,
                             g_hs);
            ELSE
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_pd,
                                               eva_pd_st_new,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p.ap_st,
                             p.ap_st,
                             p_apl_message,
                             g_hs,
                             p.pd_id,
                             p.pd_st,
                             -1);
            END IF;

            IF SQL%ROWCOUNT > 0
            THEN
                LOG (l_eva, CHR (38) || '24#' || p.ap_id);
            ELSE
                LOG (NULL, CHR (38) || '25#' || p.ap_id);
            END IF;
        END LOOP;
    END;

    --#87281  2023.06.01
    PROCEDURE preparewrite_visit_at_log (
        p_atl_at        at_log.atl_at%TYPE,
        p_atl_message   at_log.atl_message%TYPE,
        p_atl_tp        at_log.atl_tp%TYPE:= 'SYS',
        p_wu            histsession.hs_wu%TYPE:= NULL)
    IS
        l_eva   NUMBER;

        CURSOR ap IS
            SELECT ap_id,
                   ap_tp,
                   ap_st,
                   at_id,
                   at_st
              FROM appeal JOIN act ON ap_id = at_ap
             WHERE at_id = p_atl_at;
    BEGIN
        g_hs := tools.gethistsession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

            INSERT INTO esr2visit_actions (eva_id,
                                           eva_ap,
                                           eva_tp,
                                           eva_st_new,
                                           eva_st_old,
                                           eva_message,
                                           eva_hs_ins,
                                           eva_at,
                                           eva_at_st_new,
                                           eva_hs_exec)
                 VALUES (l_eva,
                         p.ap_id,
                         p.ap_tp,
                         p.ap_st,
                         p.ap_st,
                         p_atl_message,
                         g_hs,
                         p.at_id,
                         p.at_st,
                         -1);

            IF SQL%ROWCOUNT > 0
            THEN
                LOG (l_eva, CHR (38) || '24#' || p.ap_id);
            ELSE
                LOG (NULL, CHR (38) || '25#' || p.ap_id);
            END IF;
        END LOOP;
    END;


    PROCEDURE preparewrite_visit_ap_log (
        p_eva_ap        esr2visit_actions.eva_ap%TYPE,
        p_eva_st_old    esr2visit_actions.eva_st_old%TYPE,
        p_eva_pd        esr2visit_actions.eva_pd%TYPE,
        p_eva_message   esr2visit_actions.eva_message%TYPE)
    IS
        l_eva   NUMBER;

        CURSOR ap IS
            SELECT ap_id,
                   ap_tp,
                   ap_st,
                   pd_id,
                   pd_st,
                   ap_src
              FROM appeal, pc_decision
             WHERE ap_id = p_eva_ap AND pd_id = p_eva_pd;
    BEGIN
        g_hs := tools.gethistsession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

            IF p.ap_tp = 'V' AND p.ap_src = 'ASOPD'
            THEN
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_pd,
                                               eva_pd_st_new,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p.ap_st,
                             p_eva_st_old,
                             p_eva_message,
                             g_hs,
                             p.pd_id,
                             p.pd_st,
                             g_hs);
            ELSE
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_pd,
                                               eva_pd_st_new,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p.ap_st,
                             p_eva_st_old,
                             p_eva_message,
                             g_hs,
                             p.pd_id,
                             p.pd_st,
                             -1);
            END IF;

            IF SQL%ROWCOUNT > 0
            THEN
                LOG (l_eva, CHR (38) || '24#' || p.ap_id);
            ELSE
                LOG (NULL, CHR (38) || '25#' || p.ap_id);
            END IF;
        END LOOP;
    END;

    PROCEDURE preparewrite_visit_ap_st (
        p_eva_ap        esr2visit_actions.eva_ap%TYPE,
        p_eva_st_new    esr2visit_actions.eva_st_new%TYPE,
        p_eva_message   esr2visit_actions.eva_message%TYPE,
        p_hs_ins        esr2visit_actions.eva_hs_ins%TYPE)
    IS
        l_eva   NUMBER;

        CURSOR ap IS
            SELECT ap_id,
                   ap_tp,
                   ap_st,
                   ap_src
              FROM appeal
             WHERE ap_id = p_eva_ap;
    BEGIN
        g_hs := tools.gethistsession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_esr2visit_actions.NEXTVAL INTO l_eva FROM DUAL;

            IF p.ap_tp = 'V' AND p.ap_src = 'ASOPD'
            THEN
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p_eva_st_new,
                             p.ap_st,
                             p_eva_message,
                             p_hs_ins,
                             p_hs_ins);
            ELSE
                INSERT INTO esr2visit_actions (eva_id,
                                               eva_ap,
                                               eva_tp,
                                               eva_st_new,
                                               eva_st_old,
                                               eva_message,
                                               eva_hs_ins,
                                               eva_hs_exec)
                     VALUES (l_eva,
                             p.ap_id,
                             p.ap_tp,
                             p_eva_st_new,
                             p.ap_st,
                             p_eva_message,
                             p_hs_ins,
                             -1);
            END IF;

            IF SQL%ROWCOUNT > 0
            THEN
                LOG (l_eva, CHR (38) || '24#' || p.ap_id);
            ELSE
                LOG (NULL, CHR (38) || '25#' || p.ap_id);
            END IF;
        END LOOP;
    END;

    -- info:   Копіювання в звернення підписаного документа-рішення
    -- params: p_pd_id - ідентифікатор рішення
    -- note:   #77050, підписання друкованої форми, #82581
    PROCEDURE copy_decision_2visit (p_ap_id   IN appeal.ap_id%TYPE,
                                    p_pd_id   IN pc_decision.pd_id%TYPE)
    IS
        v_apd_id    ap_document.apd_id%TYPE;
        v_apda_id   ap_document_attr.apda_id%TYPE;
    BEGIN
        FOR c
            IN (SELECT pdo_id,
                       pdo_doc,
                       pdo_dh,
                       pdo_app,
                       pdo_aps
                  FROM pd_document
                 WHERE     pdo_ap = p_ap_id
                       AND pdo_pd = p_pd_id
                       AND pdo_ndt = 10051
                       AND history_status = 'A'
                       AND pdo_apd IS NULL)
        LOOP
            v_apd_id :=
                uss_visit.api$ap_processing.create_decision_doc (p_ap_id,
                                                                 c.pdo_doc,
                                                                 c.pdo_dh);

            IF v_apd_id > 0
            THEN
                INSERT INTO ap_document (apd_id,
                                         apd_ap,
                                         apd_app,
                                         apd_ndt,
                                         apd_doc,
                                         apd_dh,
                                         history_status,
                                         apd_vf,
                                         apd_aps)
                     VALUES (v_apd_id,
                             p_ap_id,
                             c.pdo_app,
                             10051,
                             c.pdo_doc,
                             c.pdo_dh,
                             'A',
                             NULL,
                             c.pdo_aps);

                FOR ca
                    IN (SELECT pdoa_nda,
                               pdoa_val_int,
                               pdoa_val_sum,
                               pdoa_val_id,
                               pdoa_val_dt,
                               pdoa_val_string
                          FROM pd_document_attr
                         WHERE     pdoa_pdo = c.pdo_id
                               AND pdoa_pd = p_pd_id
                               AND history_status = 'A')
                LOOP
                    v_apda_id :=
                        uss_visit.api$ap_processing.add_decision_attr (
                            p_ap_id             => p_ap_id,
                            p_apd_id            => v_apd_id,
                            p_apda_nda          => ca.pdoa_nda,
                            p_apda_val_int      => ca.pdoa_val_int,
                            p_apda_val_dt       => ca.pdoa_val_dt,
                            p_apda_val_string   => ca.pdoa_val_string,
                            p_apda_val_id       => ca.pdoa_val_id,
                            p_apda_val_sum      => ca.pdoa_val_sum);

                    IF v_apda_id > 0
                    THEN
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_int,
                                                      apda_val_sum,
                                                      apda_val_id,
                                                      apda_val_dt,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (v_apda_id,
                                     p_ap_id,
                                     v_apd_id,
                                     ca.pdoa_nda,
                                     ca.pdoa_val_int,
                                     ca.pdoa_val_sum,
                                     ca.pdoa_val_id,
                                     ca.pdoa_val_dt,
                                     ca.pdoa_val_string,
                                     'A');
                    END IF;
                END LOOP;

                UPDATE pd_document
                   SET pdo_apd = v_apd_id
                 WHERE pdo_id = c.pdo_id;
            END IF;
        END LOOP;
    END;


    --==========================================
    PROCEDURE copy_pdo_2apd (p_ap_id      IN appeal.ap_id%TYPE,
                             p_pd_id      IN pc_decision.pd_id%TYPE,
                             p_list_ndt      VARCHAR2,
                             p_Com_Wu        NUMBER)
    IS
        v_apd_id    ap_document.apd_id%TYPE;
        v_apda_id   ap_document_attr.apda_id%TYPE;
        l_doc_atr   SYS_REFCURSOR;

        CURSOR doc IS
            WITH
                ndt_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_list_ndt,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS id_ndt
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_list_ndt, '[^,]*'))
                                + 1)
            SELECT pdo_id,
                   pdo_ndt,
                   pdo_doc,
                   pdo_dh,
                   pdo_app,
                   pdo_aps
              FROM pd_document JOIN ndt_list ON pdo_ndt = id_ndt
             WHERE     pdo_ap = p_ap_id
                   AND pdo_pd = p_pd_id
                   AND history_status = 'A'  /*
                     AND pdo_apd IS NULL*/
                                           ;
    BEGIN
        FOR c IN doc
        LOOP
            OPEN l_doc_atr FOR
                SELECT pdoa.pdoa_nda,
                       pdoa.pdoa_val_int,
                       pdoa.pdoa_val_sum,
                       pdoa.pdoa_val_id,
                       pdoa.pdoa_val_dt,
                       pdoa.pdoa_val_string
                  FROM pd_document_attr pdoa
                 WHERE pdoa.pdoa_pdo = c.pdo_id AND pdoa.history_status = 'A';

            uss_visit.api$ap_processing.Create_document (p_ap_id,
                                                         c.pdo_ndt,
                                                         c.pdo_Doc,
                                                         c.pdo_Dh,
                                                         p_Com_Wu,
                                                         l_doc_atr);
        END LOOP;
    END;

    --==========================================
    PROCEDURE copy_pdo_2apd (p_ap_id      IN appeal.ap_id%TYPE,
                             p_list_ndt      VARCHAR2)
    IS
        v_apd_id    ap_document.apd_id%TYPE;
        v_apda_id   ap_document_attr.apda_id%TYPE;
        l_doc_atr   SYS_REFCURSOR;

        CURSOR doc IS
            WITH
                ndt_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_list_ndt,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS id_ndt
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_list_ndt, '[^,]*'))
                                + 1)
            SELECT pdo_id,
                   pdo_ndt,
                   pdo_doc,
                   pdo_dh,
                   pdo_app,
                   pdo_aps
              FROM pd_document JOIN ndt_list ON pdo_ndt = id_ndt
             WHERE pdo_ap = p_ap_id AND history_status = 'A';
    BEGIN
        FOR c IN doc
        LOOP
            OPEN l_doc_atr FOR
                SELECT pdoa.pdoa_nda,
                       pdoa.pdoa_val_int,
                       pdoa.pdoa_val_sum,
                       pdoa.pdoa_val_id,
                       pdoa.pdoa_val_dt,
                       pdoa.pdoa_val_string
                  FROM pd_document_attr pdoa
                 WHERE pdoa.pdoa_pdo = c.pdo_id AND pdoa.history_status = 'A';

            uss_visit.api$ap_processing.Create_document (p_ap_id,
                                                         c.pdo_ndt,
                                                         c.pdo_Doc,
                                                         c.pdo_Dh,
                                                         NULL,
                                                         l_doc_atr);
        END LOOP;
    END;

    --==========================================
    PROCEDURE copy_atd_2apd (p_ap_id      IN appeal.ap_id%TYPE,
                             p_at_id      IN act.at_id%TYPE,
                             p_list_ndt      VARCHAR2,
                             p_Com_Wu        NUMBER)
    IS
        v_atd_id    at_document.atd_id%TYPE;
        v_atda_id   at_document_attr.atda_id%TYPE;
        l_doc_atr   SYS_REFCURSOR;

        CURSOR doc IS
            WITH
                ndt_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_list_ndt,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS id_ndt
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_list_ndt, '[^,]*'))
                                + 1)
            SELECT atd_id,
                   atd_ndt,
                   atd_doc,
                   atd_dh                               --, atd_app--, atd_aps
              FROM at_document JOIN ndt_list ON atd_ndt = id_ndt
             WHERE atd_at = p_at_id AND history_status = 'A' /*
                                     AND pdo_apd IS NULL*/
                                                            ;
    BEGIN
        FOR c IN doc
        LOOP
            OPEN l_doc_atr FOR
                SELECT atda.atda_nda,
                       atda.atda_val_int,
                       atda.atda_val_sum,
                       atda.atda_val_id,
                       atda.atda_val_dt,
                       atda.atda_val_string
                  FROM at_document_attr atda
                 WHERE atda.atda_atd = c.atd_id AND atda.history_status = 'A';

            uss_visit.api$ap_processing.Create_document (p_ap_id,
                                                         c.atd_ndt,
                                                         c.atd_Doc,
                                                         c.atd_Dh,
                                                         p_Com_Wu,
                                                         l_doc_atr);
        END LOOP;
    END;

    --==========================================
    PROCEDURE copy_esr2visit_return
    IS
        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst     AS eva_nst,
                   pd_is_signed
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        --#73983 2021.12.09
        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.return_appeal_to_editing (
                p.eva_ap,
                p.eva_message,
                p.hs_wu);
        END LOOP;

        --запит на копіювання
        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;

        LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
    END;

    --==========================================
    PROCEDURE copy_esr2visit_reject
    IS
        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst     AS eva_nst,
                   pd_is_signed
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        --#73983 2021.12.09
        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.return_appeal_to_reject (
                p.eva_ap,
                p.eva_message,
                p.hs_wu);
        END LOOP;

        --запит на копіювання
        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;

        LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
    END;

    --==========================================
    -- #79662  2022.08.29
    PROCEDURE copy_esr2visit_done
    IS
        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst                                        AS eva_nst,
                   pd_is_signed,
                   (SELECT 1
                      FROM ap_service
                     WHERE aps_ap = eva_ap AND aps_nst = 981)    AS Is10227
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        --raise_application_error(-20002, 'copy_esr2visit_done;');

        FOR p IN esr2visit
        LOOP
            --#87140  Передача посилання на сформований в ЄСР файл рішення до ініціативної картки ЄСП
            IF     p.eva_nst BETWEEN 400 AND 499
               AND p.eva_pd_st_new IN ('P',
                                       'O.P',
                                       'V',
                                       'O.V',
                                       'O.S')
            THEN
                copy_pdo_2apd (p.eva_ap,
                               p.eva_pd,
                               '851,853,854',
                               p.hs_wu);
            ELSIF p.is10227 > 0
            THEN
                copy_pdo_2apd (p.eva_ap, '10227');
            END IF;

            copy_esr2visit_doc741 (p.eva_ap);

            IF p.eva_ap > 0
            THEN
                uss_visit.api$ap_processing.Return_Appeal_To_Done (
                    p.eva_ap,
                    p.eva_message,
                    p.hs_wu);
            END IF;
        END LOOP;

        --запит на копіювання
        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    --      log(NULL, chr(38) || '27#' || SQL%ROWCOUNT);
    END;

    --==========================================
    --#87281
    PROCEDURE copy_esr2visit_R
    IS
        l_apl_tp   ap_log.apl_tp%TYPE := 'SYS';

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_at_st_new,
                   eva_at
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN act ON at_id = eva_at
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.write_log (p.eva_ap,
                                                   p.eva_st_new,
                                                   p.eva_message,
                                                   p.eva_st_old,
                                                   l_apl_tp,
                                                   p.hs_wu,
                                                   NULL,
                                                   p.eva_at_st_new);
            copy_atd_2apd (p.eva_ap,
                           p.eva_at,
                           '862',
                           p.hs_wu);
        END LOOP;

        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    END;

    --==========================================
    PROCEDURE copy_esr2visit_log
    IS
        l_apl_tp   ap_log.apl_tp%TYPE := 'SYS';

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst     AS eva_nst,
                   pd_is_signed,
                   eva_tp
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        FOR p IN esr2visit
        LOOP
            DECLARE
                l_pd_dt         uss_esr.pc_decision.pd_dt%TYPE;
                l_pd_start_dt   uss_esr.pc_decision.pd_start_dt%TYPE;
                l_pd_end_dt     uss_esr.pc_decision.pd_stop_dt%TYPE;
                l_pd_sum        uss_esr.pd_payment.pdp_sum%TYPE;
            BEGIN
                --#113797
                GetLogDetails (p_eva_message     => p.eva_message,
                               p_eva_pd_st_new   => p.eva_pd_st_new,
                               p_pd_id           => p.eva_pd,
                               p_pd_dt           => l_pd_dt,
                               p_pd_start_dt     => l_pd_start_dt,
                               p_pd_end_dt       => l_pd_end_dt,
                               p_pd_sum          => l_pd_sum);

                uss_visit.api$ap_processing.write_log (p.eva_ap,
                                                       p.eva_st_new,
                                                       p.eva_message,
                                                       p.eva_st_old,
                                                       l_apl_tp,
                                                       p.hs_wu,
                                                       p.eva_nst,
                                                       p.eva_pd_st_new,
                                                       l_pd_dt,
                                                       l_pd_start_dt,
                                                       l_pd_end_dt,
                                                       l_pd_sum);

                --#77050/#78724 копіювання документів-рішень
                IF     p.eva_pd IS NOT NULL
                   AND p.eva_nst IN (664,
                                     269,
                                     268,
                                     267,
                                     265,
                                     249,
                                     248)
                   AND p.pd_is_signed = 'T'
                THEN
                    copy_decision_2visit (p.eva_ap, p.eva_pd);
                END IF;

                --#87140  Передача посилання на сформований в ЄСР файл рішення до ініціативної картки ЄСП
                IF     p.eva_nst BETWEEN 400 AND 499
                   AND p.eva_pd_st_new IN ('P',
                                           'O.P',
                                           'V',
                                           'O.V',
                                           'O.S')
                THEN
                    copy_pdo_2apd (p.eva_ap,
                                   p.eva_pd,
                                   '851,853,854',
                                   p.hs_wu);
                END IF;
            END;
        END LOOP;

        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    END;

    --==========================================
    PROCEDURE copy_esr2visit_aps_log
    IS
        l_apl_tp   ap_log.apl_tp%TYPE := 'SYS';

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   aps_nst     AS eva_nst
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN ap_service ON aps_ap = eva_ap
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.write_log (p.eva_ap,
                                                   p.eva_st_new,
                                                   p.eva_message,
                                                   p.eva_st_old,
                                                   l_apl_tp,
                                                   p.hs_wu,
                                                   p.eva_nst,
                                                   p.eva_pd_st_new);
        END LOOP;

        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    END;

    --==========================================
    PROCEDURE copy_esr2visit_log_at
    IS
        l_apl_tp   ap_log.apl_tp%TYPE := 'SYS';

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_at,
                   eva_at_st_new,
                   CASE
                       WHEN eva_message LIKE CHR (38) || '153%' THEN 1
                       ELSE 0
                   END    AS IsSendDoc
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.write_log_at (p.eva_ap,
                                                      p.eva_st_new,
                                                      p.eva_message,
                                                      p.eva_st_old,
                                                      l_apl_tp,
                                                      p.hs_wu);

            --#87140  Передача посилання на сформований в ЄСР файл рішення до ініціативної картки ЄСП
            IF p.IsSendDoc = 1
            THEN
                copy_atd_2apd (p.eva_ap,
                               p.eva_at,
                               '851,853,854',
                               p.hs_wu);
            END IF;
        END LOOP;

        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    END;

    --==========================================
    PROCEDURE copy_esr2visit_log_O
    IS
        l_apl_tp   ap_log.apl_tp%TYPE := 'SYS';

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst     AS eva_nst,
                   pd_is_signed
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        g_hs := NVL (g_hs, tools.gethistsession ());

        FOR p IN esr2visit
        LOOP
            uss_visit.api$ap_processing.write_log (p.eva_ap,
                                                   p.eva_st_new,
                                                   p.eva_message,
                                                   p.eva_st_old,
                                                   l_apl_tp,
                                                   p.hs_wu,
                                                   p.eva_nst,
                                                   p.eva_pd_st_new);
        END LOOP;

        UPDATE esr2visit_actions eva
           SET eva.eva_hs_exec = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = eva.eva_ap)
               AND eva_hs_exec = -1;
    END;

    -- info:   Копіювання в звернення сформованого документа
    -- params: p_pd_id - ідентифікатор рішення
    -- note:   #78825
    PROCEDURE copy_esr2visit_doc741 (p_ap_id IN appeal.ap_id%TYPE)
    IS
    BEGIN
        FOR c
            IN (SELECT pdo_apd, pdo_doc, pdo_dh
                  FROM pd_document
                 WHERE     pdo_ap = p_ap_id
                       AND pdo_ndt = 741
                       AND history_status = 'A')
        LOOP
            uss_visit.api$ap_processing.update_document_pdf (c.pdo_apd,
                                                             c.pdo_doc,
                                                             c.pdo_dh);
        END LOOP;
    END;

    /*
      PROCEDURE copy_esr2visit_doc10227(p_ap_id IN appeal.ap_id%TYPE) IS
      BEGIN
        FOR c IN (SELECT pdo_apd, pdo_doc, pdo_dh
                    FROM pd_document
                   WHERE pdo_ap = p_ap_id
                     AND pdo_ndt = 10227
                     AND history_status = 'A')
        LOOP
          uss_visit.api$ap_processing.update_document_pdf(c.pdo_apd, c.pdo_doc, c.pdo_dh);
        END LOOP;
      END;
    */
    --==========================================
    --  Копирование в ESR
    --==========================================
    PROCEDURE copy_esr2visit
    IS
        copyingallowed   VARCHAR2 (20);
        l_lock_handle    tools.t_lockhandler;
        sqlrowcount      NUMBER;

        CURSOR esr2visit IS
            SELECT eva_ap,
                   eva_message,
                   eva_st_new,
                   eva_st_old,
                   hs_wu,
                   eva_pd_st_new,
                   eva_pd,
                   pd_nst     AS eva_nst,
                   pd_is_signed,
                   eva_id
              FROM esr2visit_actions
                   JOIN tmp_work_ids ON eva_ap = x_id
                   LEFT JOIN histsession ON hs_id = eva_hs_ins
                   LEFT JOIN pc_decision ON pd_id = eva_pd
             WHERE eva_hs_exec = -1;
    BEGIN
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        --Перевіремо, чи дозволено працовати
        SELECT NVL (MAX (prm_value), '0')
          INTO copyingallowed
          FROM paramsesr p
         WHERE prm_code = 'CE2V';

        IF copyingallowed != '1'
        THEN
            RETURN;
        END IF;

        --Блокуємо чергу
        l_lock_handle := tools.request_lock (p_descr => 'Copy_ESR2Visit');

        --Збираємо звернення з черги на передaчу лога
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp = 'SS'
                   AND eva.eva_st_new NOT IN ('P', 'X')
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            copy_esr2visit_log_at;
        END IF;

        --Збираємо звернення з черги
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('REG')
                   AND eva.eva_st_old = 'O'
                   AND eva.eva_pd_st_new = 'P'
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);
            copy_esr2visit_aps_log;
        END IF;

        --Збираємо звернення з черги на повернення до редагування
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('V',
                                      'VV',
                                      'A',
                                      'U',
                                      'SS',
                                      'IA',
                                      'O',
                                      'PP')
                   AND eva.eva_st_new = 'P'
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;                    -- #74045 2021.12.13

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);
            copy_esr2visit_return;
        END IF;

        --Збираємо звернення з черги на повернення для відхилення
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('V',
                                      'A',
                                      'U',
                                      'SS',
                                      'IA',
                                      'O',
                                      'PP')
                   AND eva.eva_st_new = 'X'
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;                    -- #74045 2021.12.13

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);
            copy_esr2visit_reject;
        END IF;

        --#87281
        --Збираємо звернення з черги на статус "Виконано" "Відмовлено" для ap_tp IN ('R.OS', 'R.GS')
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE eva.eva_tp IN ('R.OS', 'R.GS') --eva.eva_st_new IN ('R.OS', 'R.GS')
                                                  AND eva.eva_hs_exec = -1;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);
            copy_esr2visit_R;
        END IF;


        --Збираємо звернення з черги на передaчу лога
        --Окремо для рішень, які відмовлено
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva JOIN pc_decision ON pd_id = eva_pd
             WHERE     eva.eva_tp IN ('V')
                   AND (eva.eva_st_new IN ('V') OR eva.eva_pd_st_new IN ('V'))
                   AND pd_nst IN (664,
                                  269,
                                  268,
                                  267,
                                  265,
                                  249,
                                  248)
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            copy_esr2visit_log;
        END IF;

        --Збираємо звернення з черги на статус "Виконано"
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE /*eva.eva_tp IN ('V', 'A', 'U', 'SS', 'IA', 'O')
               AND*/
                   /*(eva.eva_st_new = 'V' OR eva.eva_pd_st_new IN ('O.P', 'V') )*/
                       (   eva.eva_st_new = 'V'
                        OR eva.eva_pd_st_new = 'O.P'
                        OR (    eva.eva_pd_st_new = 'V'
                            AND eva.eva_tp NOT IN ('IA')) --#88501 для єДопомоги при відмові по рішенню звернення повинно бути відхилено
                                                         )
                   AND eva.eva_tp NOT IN ('D')
                   AND eva.eva_hs_exec = -1;             -- #79662  2022.08.29

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);

            ---raise_application_error(-20002, 'Збираємо звернення з черги на статус "Виконано"');

            copy_esr2visit_done;
        END IF;

        --Збираємо звернення з черги на передaчу лога
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('V',
                                      'A',
                                      'U',
                                      'IA',
                                      'DD')                          --#115547
                   AND eva.eva_st_new NOT IN ('P', 'V')
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            copy_esr2visit_log;
        END IF;

        /**/
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('CH_RES')
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            copy_esr2visit_log;
        END IF;

        /**/
        --Збираємо звернення з черги на передaчу лога
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva.eva_ap
              FROM esr2visit_actions eva
             WHERE     eva.eva_tp IN ('O')
                   AND eva.eva_st_new != 'P'
                   AND eva.eva_hs_exec = -1
                   AND eva.eva_ap > 0;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            copy_esr2visit_log_O;
        END IF;

        --Збираємо звернення з черги на передaчу сформованого документа #78825
        --#114023
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT eva_ap
              FROM esr2visit_actions
             WHERE eva_tp = 'D' AND eva_st_new = 'V' AND eva_hs_exec = -1;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            g_hs := tools.gethistsession ();
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);

            FOR c IN esr2visit
            LOOP
                --log(c.eva_id, '12345');
                copy_esr2visit_doc741 (c.eva_ap);
                -- #114023 список типів документів для довідок з qr-кодом
                copy_pdo_2apd (p_ap_id      => c.eva_ap,
                               p_list_ndt   => '10372, 10374');
                --log(c.eva_id, 'qwerty');
                uss_visit.api$ap_processing.return_appeal_to_done (
                    c.eva_ap,
                    c.eva_message,
                    c.hs_wu);
            END LOOP;

            UPDATE esr2visit_actions
               SET eva_hs_exec = g_hs
             WHERE     eva_hs_exec = -1
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = eva_ap);

            LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
        END IF;

        tools.release_lock (p_lock_handler => l_lock_handle);
    --COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20000
            THEN
                loga (CHR (38) || '28#' || 'Чергу заблоковано');
            ELSE
                loga (CHR (38) || '28#' || SQLCODE || ' : ' || SQLERRM);

                IF l_lock_handle IS NOT NULL
                THEN
                    tools.release_lock (p_lock_handler => l_lock_handle);
                END IF;
            END IF;
    END;

    FUNCTION Get_esr2visit_html (p_ap NUMBER)
        RETURN XMLTYPE
    AS
        html   XMLTYPE;
    BEGIN
        WITH
            tr
            AS
                (  SELECT e.eva_ap,
                          XMLAGG (XMLELEMENT (
                                      "tr",
                                      XMLCONCAT (
                                          XMLELEMENT ("td", e.eva_id),
                                          XMLELEMENT ("td", e.eva_st_new),
                                          XMLELEMENT ("td", e.eva_st_old),
                                          XMLELEMENT ("td", e.eva_message),
                                          XMLELEMENT ("td", e.eva_pd),
                                          XMLELEMENT ("td", e.eva_pd_st_new),
                                          XMLELEMENT ("td", e.eva_hs_ins),
                                          XMLELEMENT (
                                              "td",
                                              (SELECT TO_CHAR (
                                                          h.hs_dt,
                                                          'dd.mm.yy hh24:mi:ss')
                                                 FROM histsession h
                                                WHERE h.hs_id = e.eva_hs_ins)),
                                          XMLELEMENT ("td", e.eva_hs_exec),
                                          XMLELEMENT (
                                              "td",
                                              (SELECT TO_CHAR (
                                                          h.hs_dt,
                                                          'dd.mm.yy hh24:mi:ss')
                                                 FROM histsession h
                                                WHERE h.hs_id = e.eva_hs_exec))))
                                  ORDER BY e.eva_id)    AS xml_tr
                     FROM esr2visit_actions e
                    WHERE e.eva_ap = p_ap
                 GROUP BY e.eva_ap),
            tbl
            AS
                (SELECT eva_ap,
                        XMLELEMENT (
                            "table",
                            XMLATTRIBUTES (1 AS "border"),
                            XMLCONCAT (
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('40%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('10%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('5%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('10%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "th",
                                    XMLELEMENT (
                                        "tr",
                                        XMLCONCAT (
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_id'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_st_new'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_st_old'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_message'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'eva_pd'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'eva_pd_st_new'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_hs_ins'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'dt_ins'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'vea_hs_exec'),
                                            XMLELEMENT (
                                                "td",
                                                XMLATTRIBUTES (
                                                    'center' AS "align"),
                                                'dt_exec')))),
                                XMLELEMENT ("tb", xml_tr)))    AS xml_table
                   FROM tr)
        SELECT xml_table
          INTO html
          FROM tbl;

        RETURN html;
    END;
END API$ESR_Action;
/