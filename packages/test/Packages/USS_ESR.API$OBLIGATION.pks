/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$OBLIGATION
IS
    -- Групова ініціалізація kolio
    PROCEDURE group_init (
        p_ids                  IN VARCHAR2,
        p_cto_reestr_num       IN obligation.cto_reestr_num%TYPE,
        p_cto_dksu_get_dt      IN obligation.cto_dksu_get_dt%TYPE,
        p_cto_dksu_unload_dt   IN obligation.cto_dksu_unload_dt%TYPE,
        p_cto_acc_oper         IN obligation.cto_acc_oper%TYPE,
        p_cto_nfs              IN obligation.cto_nfs%TYPE,
        p_cto_cto_ur           IN obligation.cto_cto_ur%TYPE,
        p_cto_last_pay_dt      IN obligation.cto_last_pay_dt%TYPE,
        p_cto_term_dt          IN obligation.cto_term_dt%TYPE);

    -- Отримати запис по ідентифікатору
    PROCEDURE getobligation (p_id    IN     obligation.cto_id%TYPE,
                             p_res      OUT SYS_REFCURSOR);

    -- отримати дані по юр. зобовязанню на основі якого створюється фін. зобовязання
    PROCEDURE get_new_fin_obligation_on_legal (
        p_id    IN     obligation.cto_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE saveupdateobligation (
        p_cto_id                IN     obligation.cto_id%TYPE,
        p_cto_cto_ur            IN     obligation.cto_cto_ur%TYPE,
        p_cto_cto_main          IN     obligation.cto_cto_main%TYPE,
        p_cto_dppa_own          IN     obligation.cto_dppa_own%TYPE,
        p_cto_dppa_ca           IN     obligation.cto_dppa_ca%TYPE,
        p_cto_nkv               IN     obligation.cto_nkv%TYPE,
        p_cto_nfs               IN     obligation.cto_nfs%TYPE,
        p_cto_dpp               IN     obligation.cto_dpp%TYPE,
        p_cto_reestr_num        IN     obligation.cto_reestr_num%TYPE,
        p_cto_reestr_dt         IN     obligation.cto_reestr_dt%TYPE,
        p_cto_pdv_tp            IN     obligation.cto_pdv_tp%TYPE,
        p_cto_sum_without_pdv   IN     obligation.cto_sum_without_pdv%TYPE,
        p_cto_sum_pdv           IN     obligation.cto_sum_pdv%TYPE,
        p_cto_sum               IN     obligation.cto_sum%TYPE,
        p_cto_comment           IN     obligation.cto_comment%TYPE,
        p_cto_oper_tp           IN     obligation.cto_oper_tp%TYPE,
        p_cto_last_pay_dt       IN     obligation.cto_last_pay_dt%TYPE,
        p_cto_repayment_dt      IN     obligation.cto_repayment_dt%TYPE,
        p_cto_is_prev_budget    IN     obligation.cto_is_prev_budget%TYPE,
        p_cto_dt                IN     obligation.cto_dt%TYPE,
        p_cto_num               IN     obligation.cto_num%TYPE,
        p_cto_is_publish        IN     obligation.cto_is_publish%TYPE,
        p_cto_ess_conditions    IN     obligation.cto_ess_conditions%TYPE,
        p_cto_dksu_get_dt       IN     obligation.cto_dksu_get_dt%TYPE,
        p_cto_acc_oper          IN     obligation.cto_acc_oper%TYPE,
        p_cto_dksu_unload_dt    IN     obligation.cto_dksu_unload_dt%TYPE,
        p_cto_term_dt           IN     obligation.cto_term_dt%TYPE,
        p_src                   IN     VARCHAR2, --тип сохраняемого зобов'язання
        p_new_id                   OUT obligation.cto_id%TYPE);

    -- Вилучити kolio
    PROCEDURE delete_obligation (p_ids IN VARCHAR2);

    -- Затвердити kolio
    PROCEDURE approve_obligation (p_id obligation.cto_id%TYPE);

    -- Затвердити групу зобовязань kolio
    PROCEDURE approve_obligations (p_ids IN VARCHAR2);

    -- Сторнувати групу зобовязань kolio
    PROCEDURE reverse_obligations (p_ids IN VARCHAR2);

    -- Список за фільтром
    PROCEDURE queryobligationslist (
        p_cto_nfs                   IN     NUMBER,
        p_cto_dpp                   IN     NUMBER,
        p_cto_reestr_num            IN     VARCHAR2,
        p_cto_oper_tp               IN     VARCHAR2,
        p_cto_dt_from               IN     DATE,
        p_cto_dt_to                 IN     DATE,
        p_cto_num                   IN     VARCHAR2,
        p_cto_st                    IN     VARCHAR2,
        p_cto_dksu_unload_dt_from   IN     DATE,
        p_cto_dksu_unload_dt_to     IN     DATE,
        p_src                       IN     VARCHAR2,        --тип зобов'язаннь
        p_res                          OUT SYS_REFCURSOR);
END api$obligation;
/


/* Formatted on 8/12/2025 5:49:07 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$OBLIGATION
IS
    -- Групова ініціалізація kolio
    PROCEDURE group_init (
        p_ids                  IN VARCHAR2,
        p_cto_reestr_num       IN obligation.cto_reestr_num%TYPE,
        p_cto_dksu_get_dt      IN obligation.cto_dksu_get_dt%TYPE,
        p_cto_dksu_unload_dt   IN obligation.cto_dksu_unload_dt%TYPE,
        p_cto_acc_oper         IN obligation.cto_acc_oper%TYPE,
        p_cto_nfs              IN obligation.cto_nfs%TYPE,
        p_cto_cto_ur           IN obligation.cto_cto_ur%TYPE,
        p_cto_last_pay_dt      IN obligation.cto_last_pay_dt%TYPE,
        p_cto_term_dt          IN obligation.cto_term_dt%TYPE)
    IS
        /* CURSOR ids IS
        SELECT regexp_substr(text, '[^(\,)]+', 1, LEVEL) AS cto
         FROM (SELECT p_ids AS text FROM dual)
        CONNECT BY length(regexp_substr(text, '[^(\,)]+', 1, LEVEL)) > 0;*/
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        UPDATE obligation t
           SET t.cto_reestr_num = NVL (p_cto_reestr_num, cto_reestr_num),
               t.cto_dksu_get_dt = NVL (p_cto_dksu_get_dt, cto_dksu_get_dt),
               t.cto_dksu_unload_dt =
                   NVL (p_cto_dksu_unload_dt, cto_dksu_unload_dt),
               t.cto_acc_oper = NVL (p_cto_acc_oper, cto_acc_oper),
               t.cto_nfs = NVL (p_cto_nfs, cto_nfs),
               t.cto_cto_ur = NVL (p_cto_cto_ur, cto_cto_ur),
               t.cto_last_pay_dt = NVL (p_cto_last_pay_dt, cto_last_pay_dt),
               t.cto_term_dt = NVL (p_cto_term_dt, cto_term_dt)
         WHERE     1 = 1
               AND com_org = l_org
               AND cto_id IN (    SELECT REGEXP_SUBSTR (text,
                                                        '[^(\,)]+',
                                                        1,
                                                        LEVEL)    AS cto
                                    FROM (SELECT p_ids AS text FROM DUAL)
                              CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                '[^(\,)]+',
                                                                1,
                                                                LEVEL)) > 0);
    /* FOR id IN ids LOOP
       IF p_cto_reestr_num IS NOT NULL THEN
         UPDATE obligation SET cto_reestr_num = p_cto_reestr_num WHERE cto_id = id.cto and com_org = tools.getcurrorg;
       END IF;
       IF p_cto_dksu_get_dt IS NOT NULL THEN
         UPDATE obligation SET cto_dksu_get_dt = p_cto_dksu_get_dt WHERE cto_id = id.cto and com_org = tools.getcurrorg;
       END IF;
       IF p_cto_dksu_unload_dt IS NOT NULL THEN
         UPDATE obligation SET cto_dksu_unload_dt = p_cto_dksu_unload_dt WHERE cto_id = id.cto and com_org = tools.getcurrorg;
       END IF;
       IF p_cto_acc_oper IS NOT NULL THEN
         UPDATE obligation SET cto_acc_oper = p_cto_acc_oper WHERE cto_id = id.cto and com_org = tools.getcurrorg;
       END IF;
       IF p_cto_nfs IS NOT NULL THEN
         UPDATE obligation SET cto_nfs = p_cto_nfs WHERE cto_id = id.cto and com_org = tools.getcurrorg;
       END IF;
     END LOOP;*/
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE getobligation (p_id    IN     obligation.cto_id%TYPE,
                             p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT o.cto_id,
                   o.cto_cto_ur,
                   o.cto_cto_main,
                   o.cto_tp,
                   o.cto_dppa_own,
                   o.cto_dppa_ca,
                   o.cto_nkv,
                   o.cto_nfs,
                   o.cto_dpp,
                   o.cto_reestr_num,
                   o.cto_reestr_dt,
                   o.cto_pdv_tp,
                   o.cto_sum_without_pdv,
                   o.cto_sum_pdv,
                   o.cto_sum,
                   o.cto_comment,
                   o.cto_oper_tp,
                   o.cto_last_pay_dt,
                   o.cto_repayment_dt,
                   o.cto_is_prev_budget,
                   o.cto_dt,
                   o.cto_num,
                   o.cto_st,
                   o.cto_is_publish,
                   o.cto_ess_conditions,
                   o.cto_dksu_get_dt,
                   o.cto_acc_oper,
                   o.cto_dksu_unload_dt,
                   o.cto_term_dt,
                   pp.dpp_name
                       AS dpp_name,                --Прописное имя контрагента
                   (SELECT o2.cto_num
                      FROM obligation o2
                     WHERE o2.cto_id = o.cto_cto_ur)
                       AS cto_cto_name, --номер юр. зобовязання, которое привязано к фин. зобовязанню
                   (SELECT TO_CHAR (o2.cto_dt, 'DD.MM.YYYY')
                      FROM obligation o2
                     WHERE o2.cto_id = o.cto_cto_ur)
                       AS cto_cto_dt, --дата юр. зобовязання, которое привязано к фин. зобовязанню
                   (SELECT COUNT (o2.cto_id)
                      FROM obligation o2
                     WHERE o2.cto_cto_ur = o.cto_id)
                       AS financial_obl_cnt,
                   (SELECT COUNT (o2.cto_id)
                      FROM obligation o2
                     WHERE o2.cto_cto_main = o.cto_id)
                       AS correcting_obl_cnt,
                   (SELECT MAX (o2.cto_sum)
                      FROM obligation o2
                     WHERE o2.cto_id = o.cto_cto_ur)
                       AS legal_total_sum,
                     (SELECT NVL (MAX (o2.cto_sum), 0)
                        FROM obligation o2
                       WHERE o2.cto_id = o.cto_cto_ur)
                   - (SELECT NVL (SUM (o2.cto_sum), 0)
                        FROM obligation o2
                       WHERE o2.cto_cto_ur = o.cto_cto_ur)
                       AS legal_remainder
              FROM obligation  o
                   LEFT JOIN uss_ndi.v_ndi_pay_person pp
                       ON pp.dpp_id = o.cto_dpp
                   LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                       ON ppa.dppa_id = o.cto_dppa_ca
             WHERE o.cto_id = p_id AND o.com_org = tools.getcurrorg;
    END;

    -- отримати дані по юр. зобовязанню на основі якого створюється фін. зобовязання
    PROCEDURE get_new_fin_obligation_on_legal (
        p_id    IN     obligation.cto_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT NULL                                 AS cto_id,
                   p_id                                 AS cto_cto_ur,
                   o.cto_cto_main,
                   'FIN_OBLIG'                          AS cto_tp,
                   o.cto_dppa_own,
                   o.cto_dppa_ca,
                   o.cto_nkv,
                   o.cto_nfs,
                   o.cto_dpp,
                   ''                                   AS cto_reestr_num,
                   NULL                                 AS cto_reestr_dt,
                   o.cto_pdv_tp,
                   o.cto_sum_without_pdv,
                   o.cto_sum_pdv,
                   o.cto_sum,
                   o.cto_comment,
                   'FIN_OBL'                            AS cto_oper_tp,
                   o.cto_last_pay_dt,
                   o.cto_repayment_dt,
                   o.cto_is_prev_budget,
                   TO_CHAR (SYSDATE, 'YYYY-MM-DD')      AS cto_dt,
                   ''                                   AS cto_num,
                   'IP'                                 AS cto_st,
                   o.cto_is_publish,
                   o.cto_ess_conditions,
                   o.cto_dksu_get_dt,
                   'GET'                                AS cto_acc_oper,
                   NULL                                 AS cto_dksu_unload_dt,
                   o.cto_term_dt,
                   pp.dpp_name                          AS dpp_name, --Прописное имя контрагента
                   (SELECT o2.cto_num
                      FROM obligation o2
                     WHERE o2.cto_id = p_id)            AS cto_cto_name, --номер юр. зобовязання, которое привязано к фин. зобовязанню
                   (SELECT COUNT (o2.cto_id)
                      FROM obligation o2
                     WHERE o2.cto_cto_ur = o.cto_id)    AS financial_obl_cnt
              FROM obligation  o
                   LEFT JOIN uss_ndi.v_ndi_pay_person pp
                       ON pp.dpp_id = o.cto_dpp
                   LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                       ON ppa.dppa_id = o.cto_dppa_ca
             WHERE cto_id = p_id;
    END;

    -- Зберегти
    PROCEDURE saveupdateobligation (
        p_cto_id                IN     obligation.cto_id%TYPE,
        p_cto_cto_ur            IN     obligation.cto_cto_ur%TYPE,
        p_cto_cto_main          IN     obligation.cto_cto_main%TYPE,
        p_cto_dppa_own          IN     obligation.cto_dppa_own%TYPE,
        p_cto_dppa_ca           IN     obligation.cto_dppa_ca%TYPE,
        p_cto_nkv               IN     obligation.cto_nkv%TYPE,
        p_cto_nfs               IN     obligation.cto_nfs%TYPE,
        p_cto_dpp               IN     obligation.cto_dpp%TYPE,
        p_cto_reestr_num        IN     obligation.cto_reestr_num%TYPE,
        p_cto_reestr_dt         IN     obligation.cto_reestr_dt%TYPE,
        p_cto_pdv_tp            IN     obligation.cto_pdv_tp%TYPE,
        p_cto_sum_without_pdv   IN     obligation.cto_sum_without_pdv%TYPE,
        p_cto_sum_pdv           IN     obligation.cto_sum_pdv%TYPE,
        p_cto_sum               IN     obligation.cto_sum%TYPE,
        p_cto_comment           IN     obligation.cto_comment%TYPE,
        p_cto_oper_tp           IN     obligation.cto_oper_tp%TYPE,
        p_cto_last_pay_dt       IN     obligation.cto_last_pay_dt%TYPE,
        p_cto_repayment_dt      IN     obligation.cto_repayment_dt%TYPE,
        p_cto_is_prev_budget    IN     obligation.cto_is_prev_budget%TYPE,
        p_cto_dt                IN     obligation.cto_dt%TYPE,
        p_cto_num               IN     obligation.cto_num%TYPE,
        p_cto_is_publish        IN     obligation.cto_is_publish%TYPE,
        p_cto_ess_conditions    IN     obligation.cto_ess_conditions%TYPE,
        p_cto_dksu_get_dt       IN     obligation.cto_dksu_get_dt%TYPE,
        p_cto_acc_oper          IN     obligation.cto_acc_oper%TYPE,
        p_cto_dksu_unload_dt    IN     obligation.cto_dksu_unload_dt%TYPE,
        p_cto_term_dt           IN     obligation.cto_term_dt%TYPE,
        p_src                   IN     VARCHAR2,
        p_new_id                   OUT obligation.cto_id%TYPE)
    IS
        p_cto_tp    VARCHAR2 (10);                          --тип зобов'язання
        p_com_org   NUMBER;
        p_cto_st    VARCHAR2 (10);
    BEGIN
        IF p_src = 'Legal'
        THEN
            p_cto_tp := 'LEG_OBLIG';
        ELSE
            p_cto_tp := 'FIN_OBLIG';
        END IF;

        IF p_cto_id IS NULL
        THEN
            p_com_org := tools.getcurrorg;
            p_cto_st := 'IP';                           --Документ редагується

            INSERT INTO obligation (cto_cto_ur,
                                    cto_cto_main,
                                    cto_tp,
                                    cto_dppa_own,
                                    cto_dppa_ca,
                                    cto_nkv,
                                    cto_nfs,
                                    cto_dpp,
                                    cto_reestr_num,
                                    cto_reestr_dt,
                                    cto_pdv_tp,
                                    cto_sum_without_pdv,
                                    cto_sum_pdv,
                                    cto_sum,
                                    cto_comment,
                                    cto_oper_tp,
                                    cto_last_pay_dt,
                                    cto_repayment_dt,
                                    cto_is_prev_budget,
                                    cto_dt,
                                    cto_num,
                                    cto_st,
                                    com_org,
                                    cto_is_publish,
                                    cto_ess_conditions,
                                    cto_dksu_get_dt,
                                    cto_acc_oper,
                                    cto_dksu_unload_dt,
                                    cto_term_dt,
                                    cto_hs_upd)
                 VALUES (p_cto_cto_ur,
                         p_cto_cto_main,
                         p_cto_tp,
                         p_cto_dppa_own,
                         p_cto_dppa_ca,
                         p_cto_nkv,
                         p_cto_nfs,
                         p_cto_dpp,
                         p_cto_reestr_num,
                         p_cto_reestr_dt,
                         p_cto_pdv_tp,
                         p_cto_sum_without_pdv,
                         p_cto_sum_pdv,
                         p_cto_sum,
                         p_cto_comment,
                         p_cto_oper_tp,
                         p_cto_last_pay_dt,
                         p_cto_repayment_dt,
                         p_cto_is_prev_budget,
                         p_cto_dt,
                         p_cto_num,
                         p_cto_st,
                         p_com_org,
                         'F',
                         p_cto_ess_conditions,
                         p_cto_dksu_get_dt,
                         p_cto_acc_oper,
                         p_cto_dksu_unload_dt,
                         p_cto_term_dt,
                         tools.gethistsession)
              RETURNING cto_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_cto_id;

            UPDATE obligation
               SET cto_cto_ur = p_cto_cto_ur,
                   cto_cto_main = p_cto_cto_main,
                   cto_dppa_own = p_cto_dppa_own,
                   cto_dppa_ca = p_cto_dppa_ca,
                   cto_nkv = p_cto_nkv,
                   cto_nfs = p_cto_nfs,
                   cto_dpp = p_cto_dpp,
                   cto_reestr_num = p_cto_reestr_num,
                   cto_reestr_dt = p_cto_reestr_dt,
                   cto_pdv_tp = p_cto_pdv_tp,
                   cto_sum_without_pdv = p_cto_sum_without_pdv,
                   cto_sum_pdv = p_cto_sum_pdv,
                   cto_sum = p_cto_sum,
                   cto_comment = p_cto_comment,
                   cto_oper_tp = p_cto_oper_tp,
                   cto_last_pay_dt = p_cto_last_pay_dt,
                   cto_repayment_dt = p_cto_repayment_dt,
                   cto_is_prev_budget = p_cto_is_prev_budget,
                   cto_dt = p_cto_dt,
                   cto_num = p_cto_num,
                   cto_is_publish = p_cto_is_publish,
                   cto_ess_conditions = p_cto_ess_conditions,
                   cto_dksu_get_dt = p_cto_dksu_get_dt,
                   cto_acc_oper = p_cto_acc_oper,
                   cto_dksu_unload_dt = p_cto_dksu_unload_dt,
                   cto_term_dt = p_cto_term_dt,
                   cto_hs_upd = tools.gethistsession
             WHERE cto_id = p_cto_id AND com_org = tools.getcurrorg;
        END IF;
    END;

    -- Вилучити kolio
    PROCEDURE delete_obligation (p_ids IN VARCHAR2)
    IS
        main_cto_cnt   NUMBER; --кол корегуючих зобовязань у этого зобовязання
        fin_obl_cnt    NUMBER;         --кол фин зобовзянь у этого зобовязання

        CURSOR ids IS
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)    AS cto
                  FROM (SELECT p_ids AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;
    BEGIN
        FOR id IN ids
        LOOP
            SELECT COUNT (cto_id)
              INTO main_cto_cnt
              FROM obligation
             WHERE cto_cto_main = id.cto;

            SELECT COUNT (cto_id)
              INTO fin_obl_cnt
              FROM obligation
             WHERE cto_cto_ur = id.cto;

            IF main_cto_cnt = 0 AND fin_obl_cnt = 0
            THEN --у зобовязання нет коригуючих зобовязань и нет финансовых зобовязань
                DELETE FROM obligation
                      WHERE     cto_id = id.cto
                            AND cto_st = 'IP'
                            AND com_org = tools.getcurrorg;
            END IF;
        END LOOP;
    END;

    -- Затвердити kolio
    PROCEDURE approve_obligation (p_id obligation.cto_id%TYPE)
    IS
    BEGIN
        UPDATE obligation
           SET cto_st = 'AP', cto_hs_upd = tools.gethistsession
         WHERE cto_id = p_id AND com_org = tools.getcurrorg;
    END;

    -- Затвердити групу зобовязань kolio
    PROCEDURE approve_obligations (p_ids IN VARCHAR2)
    IS
    BEGIN
        UPDATE obligation
           SET cto_st = 'AP', cto_hs_upd = tools.gethistsession
         WHERE     com_org = tools.getcurrorg
               AND cto_id IN (    SELECT REGEXP_SUBSTR (text,
                                                        '[^(\,)]+',
                                                        1,
                                                        LEVEL)    AS z_rdt_id
                                    FROM (SELECT p_ids AS text FROM DUAL)
                              CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                '[^(\,)]+',
                                                                1,
                                                                LEVEL)) > 0);
    END;

    -- Сторнувати групу зобовязань kolio
    PROCEDURE reverse_obligations (p_ids IN VARCHAR2)
    IS
    BEGIN
        UPDATE obligation
           SET cto_st = 'IP', cto_hs_upd = tools.gethistsession
         WHERE     com_org = tools.getcurrorg
               AND cto_id IN (    SELECT REGEXP_SUBSTR (text,
                                                        '[^(\,)]+',
                                                        1,
                                                        LEVEL)    AS z_rdt_id
                                    FROM (SELECT p_ids AS text FROM DUAL)
                              CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                '[^(\,)]+',
                                                                1,
                                                                LEVEL)) > 0);
    END;

    -- Список за фільтром
    PROCEDURE queryobligationslist (
        p_cto_nfs                   IN     NUMBER,
        p_cto_dpp                   IN     NUMBER,
        p_cto_reestr_num            IN     VARCHAR2,
        p_cto_oper_tp               IN     VARCHAR2,
        p_cto_dt_from               IN     DATE,
        p_cto_dt_to                 IN     DATE,
        p_cto_num                   IN     VARCHAR2,
        p_cto_st                    IN     VARCHAR2,
        p_cto_dksu_unload_dt_from   IN     DATE,
        p_cto_dksu_unload_dt_to     IN     DATE,
        p_src                       IN     VARCHAR2,         --тип зобов'язань
        p_res                          OUT SYS_REFCURSOR)
    IS
        p_cto_tp   VARCHAR2 (10);
    BEGIN
        IF p_src = 'Legal'
        THEN
            p_cto_tp := 'LEG_OBLIG';                                --юридичне
        ELSE
            p_cto_tp := 'FIN_OBLIG';                              --финансовое
        END IF;

        OPEN p_res FOR
            SELECT o.cto_id,
                   o.cto_cto_ur,
                   o.cto_cto_main,
                   o.cto_tp,
                   o.cto_dppa_own,
                   o.cto_dppa_ca,
                   k.nkv_sname                            AS cto_nkv,
                   nfs.nfs_name                           AS cto_nfs,
                   pp.dpp_name                            AS cto_dpp,
                   o.cto_reestr_num,
                   o.cto_reestr_dt,
                   o.cto_pdv_tp,
                   o.cto_sum_without_pdv,
                   o.cto_sum_pdv,
                   o.cto_sum,
                   o.cto_comment,
                   cot.dic_sname                          AS cto_oper_tp,
                   o.cto_last_pay_dt,
                   o.cto_repayment_dt,
                   o.cto_is_prev_budget,
                   o.cto_dt,
                   o.cto_num,
                   o.cto_st,
                   cs.dic_sname                           AS cto_st_str,
                   o.com_org,
                   o.cto_is_publish,
                   o.cto_ess_conditions,
                   o.cto_dksu_get_dt,
                   o.cto_acc_oper,
                   o.cto_dksu_unload_dt,
                   o.cto_term_dt,
                   (SELECT COUNT (o2.cto_id)
                      FROM obligation o2
                     WHERE o2.cto_cto_ur = o.cto_id)      AS financial_obl_cnt,
                   (SELECT COUNT (o2.cto_id)
                      FROM obligation o2
                     WHERE o2.cto_cto_main = o.cto_id)    AS correcting_obl_cnt
              FROM obligation  o
                   LEFT JOIN uss_ndi.v_ndi_funding_source nfs
                       ON nfs.nfs_id = o.cto_nfs
                   LEFT JOIN uss_ndi.v_ndi_pay_person pp
                       ON pp.dpp_id = o.cto_dpp
                   LEFT JOIN uss_ndi.v_ndi_kekv k ON k.nkv_id = o.cto_nkv
                   LEFT JOIN uss_ndi.v_ddn_cto_st cs
                       ON cs.dic_value = o.cto_st
                   LEFT JOIN uss_ndi.v_ddn_cto_oper_tp cot
                       ON cot.dic_value = o.cto_oper_tp
             WHERE     p_cto_tp = o.cto_tp
                   AND o.com_org = tools.getcurrorg
                   AND (p_cto_num IS NULL OR o.cto_num LIKE p_cto_num || '%')
                   AND (p_cto_nfs IS NULL OR o.cto_nfs = p_cto_nfs)
                   AND (   p_cto_oper_tp IS NULL
                        OR o.cto_oper_tp = p_cto_oper_tp)
                   AND (p_cto_st IS NULL OR o.cto_st = p_cto_st)
                   AND (   p_cto_dt_from IS NULL
                        OR TRUNC (o.cto_dt) >=
                           TO_DATE (
                                  ''
                               || TO_CHAR (p_cto_dt_from, 'DD.MM.YYYY')
                               || '',
                               'DD.MM.YYYY'))
                   AND (   p_cto_dt_to IS NULL
                        OR TRUNC (o.cto_dt) <=
                           TO_DATE (
                                  ''
                               || TO_CHAR (p_cto_dt_to, 'DD.MM.YYYY')
                               || '',
                               'DD.MM.YYYY'))
                   AND (p_cto_dpp IS NULL OR o.cto_dpp = p_cto_dpp)
                   AND (   p_cto_reestr_num IS NULL
                        OR o.cto_reestr_num LIKE p_cto_reestr_num || '%')
                   AND (   p_cto_dksu_unload_dt_from IS NULL
                        OR TRUNC (o.cto_dksu_unload_dt) >=
                           TO_DATE (
                                  ''
                               || TO_CHAR (p_cto_dksu_unload_dt_from,
                                           'DD.MM.YYYY')
                               || '',
                               'DD.MM.YYYY'))
                   AND (   p_cto_dksu_unload_dt_to IS NULL
                        OR TRUNC (o.cto_dksu_unload_dt) <=
                           TO_DATE (
                                  ''
                               || TO_CHAR (p_cto_dksu_unload_dt_to,
                                           'DD.MM.YYYY')
                               || '',
                               'DD.MM.YYYY'));
    END;
END api$obligation;
/