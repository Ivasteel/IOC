/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$OBLIGATION
IS
    -- список фин зобовязань для выпадалки "ФЗ" в карточке "Платіжне доручення" kolio
    PROCEDURE fin_obligations_dropdown_list (
        p_po_pay_dt   IN     obligation.cto_dt%TYPE,
        p_res            OUT SYS_REFCURSOR);

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
    PROCEDURE get_obligation (p_id    IN     obligation.cto_id%TYPE,
                              p_res      OUT SYS_REFCURSOR);

    -- отримати дані по юр. зобовязанню на основі якого створюється фін. зобовязання
    PROCEDURE get_new_fin_obligation_on_legal (
        p_id    IN     obligation.cto_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Список за фільтром
    PROCEDURE query_obligation (
        p_cto_dpp                   IN     NUMBER,                --контрагент
        p_cto_reestr_num            IN     VARCHAR2,               --№ реєстру
        p_cto_oper_tp               IN     VARCHAR2,            --Тип операції
        p_cto_dt_from               IN     DATE,            --Дата документу з
        p_cto_dt_to                 IN     DATE,           --Дата документу по
        p_cto_nfs                   IN     NUMBER,      --Джерело фінансування
        p_cto_num                   IN     VARCHAR2,             --№ документу
        p_cto_st                    IN     VARCHAR2,                  --Статус
        p_cto_dksu_unload_dt_from   IN     DATE,  --Дата вивантаження в ДКСУ з
        p_cto_dksu_unload_dt_to     IN     DATE, --Дата вивантаження в ДКСУ по
        p_src                       IN     VARCHAR2, --тип сохраняемого зобов'язання
        p_res                          OUT SYS_REFCURSOR);

    -- Вилучити
    PROCEDURE delete_obligation (p_ids IN VARCHAR2);

    -- Затвердити
    PROCEDURE approve_obligation (p_id obligation.cto_id%TYPE);

    -- Затвердити групу зобовязань kolio
    PROCEDURE approve_obligations (p_ids IN VARCHAR2);

    -- Сторнувати групу зобовязань kolio
    PROCEDURE reverse_obligations (p_ids IN VARCHAR2);

    -- Зберегти
    PROCEDURE save_obligation (
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
END dnet$obligation;
/


GRANT EXECUTE ON USS_ESR.DNET$OBLIGATION TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$OBLIGATION TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$OBLIGATION
IS
    -- перечень ФЗ относительно текущей указанной даты kolio
    PROCEDURE fin_obligations_dropdown_list (
        p_po_pay_dt   IN     obligation.cto_dt%TYPE,
        p_res            OUT SYS_REFCURSOR)
    IS
        dt    DATE;
        dt2   DATE;
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        -- перечень ФЗ для ПД ограничивать: от месяца ПД - минус три и текущий
        dt := ADD_MONTHS (p_po_pay_dt, -3);
        dt := TO_DATE ('01-' || TO_CHAR (dt, 'MM-YYYY'), 'DD-MM-YYYY');
        dt2 := LAST_DAY (SYSDATE);

        OPEN p_res FOR
            SELECT cto_id,
                   cto_dt,
                   cto_num,
                   cto_reestr_dt,
                   cto_reestr_num,
                   cto_sum
              FROM obligation
             WHERE     cto_tp = 'FIN_OBLIG'
                   AND cto_dt >= dt
                   AND cto_dt <= dt2
                   AND com_org = tools.getcurrorg;
    END;

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
    BEGIN
        api$obligation.group_init (
            p_ids                  => p_ids,
            p_cto_reestr_num       => p_cto_reestr_num,
            p_cto_dksu_get_dt      => p_cto_dksu_get_dt,
            p_cto_dksu_unload_dt   => p_cto_dksu_unload_dt,
            p_cto_acc_oper         => p_cto_acc_oper,
            p_cto_nfs              => p_cto_nfs,
            p_cto_cto_ur           => p_cto_cto_ur,
            p_cto_last_pay_dt      => p_cto_last_pay_dt,
            p_cto_term_dt          => p_cto_term_dt);
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE get_obligation (p_id    IN     obligation.cto_id%TYPE,
                              p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.getobligation (p_id => p_id, p_res => p_res);
    END;

    -- отримати дані по юр. зобовязанню на основі якого створюється фін. зобовязання
    PROCEDURE get_new_fin_obligation_on_legal (
        p_id    IN     obligation.cto_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.get_new_fin_obligation_on_legal (p_id    => p_id,
                                                        p_res   => p_res);
    END;

    -- Список за фільтром
    PROCEDURE query_obligation (
        p_cto_dpp                   IN     NUMBER,                --контрагент
        p_cto_reestr_num            IN     VARCHAR2,               --№ реєстру
        p_cto_oper_tp               IN     VARCHAR2,            --Тип операції
        p_cto_dt_from               IN     DATE,            --Дата документу з
        p_cto_dt_to                 IN     DATE,           --Дата документу по
        p_cto_nfs                   IN     NUMBER,      --Джерело фінансування
        p_cto_num                   IN     VARCHAR2,             --№ документу
        p_cto_st                    IN     VARCHAR2,                  --Статус
        p_cto_dksu_unload_dt_from   IN     DATE,  --Дата вивантаження в ДКСУ з
        p_cto_dksu_unload_dt_to     IN     DATE, --Дата вивантаження в ДКСУ по
        p_src                       IN     VARCHAR2, --тип сохраняемого зобов'язання
        p_res                          OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        --    OPEN p_res FOR select * from dual;
        --    raise_application_error(-20000, 'test');
        api$obligation.queryobligationslist (
            p_cto_dpp                   => p_cto_dpp,
            p_cto_reestr_num            => p_cto_reestr_num,
            p_cto_oper_tp               => p_cto_oper_tp,
            p_cto_dt_from               => p_cto_dt_from,
            p_cto_dt_to                 => p_cto_dt_to,
            p_cto_nfs                   => p_cto_nfs,
            p_cto_num                   => p_cto_num,
            p_cto_st                    => p_cto_st,
            p_cto_dksu_unload_dt_from   => p_cto_dksu_unload_dt_from,
            p_cto_dksu_unload_dt_to     => p_cto_dksu_unload_dt_to,
            p_src                       => p_src,
            p_res                       => p_res);
    END;

    -- Вилучити
    PROCEDURE delete_obligation (p_ids IN VARCHAR2)
    IS
    BEGIN
        api$obligation.delete_obligation (p_ids => p_ids);
    END;

    -- Затвердити
    PROCEDURE approve_obligation (p_id obligation.cto_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.approve_obligation (p_id => p_id);
    END;

    -- Затвердити групу зобовязань kolio
    PROCEDURE approve_obligations (p_ids IN VARCHAR2)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.approve_obligations (p_ids => p_ids);
    END;

    -- Сторнувати групу зобовязань kolio
    PROCEDURE reverse_obligations (p_ids IN VARCHAR2)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.reverse_obligations (p_ids => p_ids);
    END;

    -- Зберегти
    PROCEDURE save_obligation (
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
        p_new_id                   OUT obligation.cto_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$OBLIGATION.' || $$PLSQL_UNIT);
        api$obligation.saveupdateobligation (
            p_cto_id                => p_cto_id,
            p_cto_cto_ur            => p_cto_cto_ur,
            p_cto_cto_main          => p_cto_cto_main,
            p_cto_dppa_own          => p_cto_dppa_own,
            p_cto_dppa_ca           => p_cto_dppa_ca,
            p_cto_nkv               => p_cto_nkv,
            p_cto_nfs               => p_cto_nfs,
            p_cto_dpp               => p_cto_dpp,
            p_cto_reestr_num        => p_cto_reestr_num,
            p_cto_reestr_dt         => p_cto_reestr_dt,
            p_cto_pdv_tp            => p_cto_pdv_tp,
            p_cto_sum_without_pdv   => p_cto_sum_without_pdv,
            p_cto_sum_pdv           => p_cto_sum_pdv,
            p_cto_sum               => p_cto_sum,
            p_cto_comment           => p_cto_comment,
            p_cto_oper_tp           => p_cto_oper_tp,
            p_cto_last_pay_dt       => p_cto_last_pay_dt,
            p_cto_repayment_dt      => p_cto_repayment_dt,
            p_cto_is_prev_budget    => p_cto_is_prev_budget,
            p_cto_dt                => p_cto_dt,
            p_cto_num               => p_cto_num,
            p_cto_is_publish        => p_cto_is_publish,
            p_cto_ess_conditions    => p_cto_ess_conditions,
            p_cto_dksu_get_dt       => p_cto_dksu_get_dt,
            p_cto_acc_oper          => p_cto_acc_oper,
            p_cto_dksu_unload_dt    => p_cto_dksu_unload_dt,
            p_cto_term_dt           => p_cto_term_dt,
            p_src                   => p_src,
            p_new_id                => p_new_id);
    END;
END dnet$obligation;
/