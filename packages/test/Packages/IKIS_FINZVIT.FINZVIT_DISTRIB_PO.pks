/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_DISTRIB_PO
IS
    -- Author  : MAXYM
    -- Created : 27.11.2017 11:25:15
    -- Purpose : Налагодження створення платіжних доручень з розподілу

    PROCEDURE GetDistribPoSetup (
        p_DSM_ID   IN     distrib_po_setup_main.dsm_id%TYPE,
        p_main        OUT SYS_REFCURSOR,
        p_lines       OUT SYS_REFCURSOR);

    PROCEDURE SetDistribPoSetupMain (
        p_DSM_ID       IN     distrib_po_setup_main.dsm_id%TYPE,
        --  p_DSM_ORG   NUMBER(14)                     Орган ПФУ
        p_DSM_DPPA     IN     distrib_po_setup_main.DSM_DPPA%TYPE,
        p_DSM_DPG      IN     distrib_po_setup_main.DSM_DPG%TYPE,
        p_DSM_ID_new      OUT distrib_po_setup_main.dsm_id%TYPE);

    PROCEDURE SetDistribPoSetupLine (
        p_DSL_ID     IN distrib_po_setup_line.dsl_id%TYPE,
        p_DSL_DSM    IN distrib_po_setup_line.DSL_DSM%TYPE,
        p_DSL_ORG    IN distrib_po_setup_line.DSL_ORG%TYPE,
        p_DSL_DPPA   IN distrib_po_setup_line.DSL_DPPA%TYPE);

    PROCEDURE DeleteDistribPoSetupMain (
        p_DSM_ID   IN distrib_po_setup_line.dsl_id%TYPE);

    PROCEDURE DeleteDistribPoSetupLine (
        p_DSL_ID   IN distrib_po_setup_line.dsl_id%TYPE);

    PROCEDURE PrepareLines (
        p_DSM_ID   IN     distrib_po_setup_main.dsm_id%TYPE,
        p_res         OUT SYS_REFCURSOR);
END FINZVIT_DISTRIB_PO;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_DISTRIB_PO TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_DISTRIB_PO
IS
    PROCEDURE CheckCanChangeAndLock (
        p_dsm_id   IN distrib_po_setup_main.dsm_id%TYPE)
    IS
        resource_busy   EXCEPTION;
        PRAGMA EXCEPTION_INIT (resource_busy, -54);
        l_row           distrib_po_setup_main%ROWTYPE;
    BEGIN
            SELECT *
              INTO l_row
              FROM distrib_po_setup_main
             WHERE dsm_id = p_dsm_id
        FOR UPDATE WAIT 30;

        IF (l_row.dsm_org !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в дані іншого ОПФУ.');
        END IF;
    EXCEPTION
        WHEN resource_busy
        THEN
            raise_application_error (-20000,
                                     'Дані оновлюються іншим користувачем.');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000, 'Дані не знайдено.');
    END;

    PROCEDURE GetDistribPoSetup (
        p_DSM_ID   IN     distrib_po_setup_main.dsm_id%TYPE,
        p_main        OUT SYS_REFCURSOR,
        p_lines       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_main FOR
            SELECT dsm_id,
                   dsm_org,
                   dsm_dppa,
                   dsm_dpg,
                   g.dpg_tp
              FROM distrib_po_setup_main
                   JOIN dic_distrib_purpose_gr g ON dsm_dpg = g.dpg_id
             WHERE dsm_id = p_DSM_ID;

        OPEN p_lines FOR
              SELECT l.*, ex.*
                FROM distrib_po_setup_line l
                     LEFT JOIN v_pay_person_acc_ex ex
                         ON ex.dppa_id = l.dsl_dppa
               WHERE dsl_dsm = p_DSM_ID
            ORDER BY dsl_id;
    END;

    PROCEDURE PrepareLines (
        p_DSM_ID   IN     distrib_po_setup_main.dsm_id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
        l_dpg_tp   dic_distrib_purpose_gr.dpg_tp%TYPE;
        l_org      distrib_po_setup_main.dsm_org%TYPE;
    BEGIN
        SELECT dsm_org, dpg_tp
          INTO l_org, l_dpg_tp
          FROM distrib_po_setup_main
               JOIN dic_distrib_purpose_gr ON dpg_id = dsm_dpg
         WHERE dsm_id = p_DSM_ID;

        IF (l_dpg_tp = 'T')
        THEN
            OPEN p_res FOR
                SELECT ex.*,
                       p_DSM_ID       AS DSL_DSM,
                       ex.dpp_org     AS DSL_ORG,
                       ex.dppa_id     AS DSL_DPPA
                  FROM v_pay_person_acc_ex ex
                 WHERE ex.dppa_id IN
                           (SELECT MAX (DPPA_ID)
                                   KEEP (DENSE_RANK LAST
                                         ORDER BY DPPA_IS_MAIN, DPPA_ID)
                                   OVER (PARTITION BY DPP_ORG)
                              FROM V_PAY_PERSON_ACC_EX
                             WHERE dpp_org IN (SELECT org_id
                                                 FROM v_opfu
                                                WHERE org_org = l_org));
        ELSE
            OPEN p_res FOR
                SELECT ex.*,
                       p_DSM_ID       AS DSL_DSM,
                       ex.dpp_org     AS DSL_ORG,
                       ex.dppa_id     AS DSL_DPPA
                  FROM v_pay_person_acc_ex ex
                 WHERE ex.dppa_id IN
                           (SELECT MAX (DPPA_ID)
                                   KEEP (DENSE_RANK LAST
                                         ORDER BY DPPA_IS_MAIN, DPPA_ID)
                                   OVER (PARTITION BY DPP_ORG)
                              FROM V_PAY_PERSON_ACC_EX
                             WHERE dpp_org = l_org);
        END IF;
    END;

    PROCEDURE SetDistribPoSetupMain (
        p_DSM_ID       IN     distrib_po_setup_main.dsm_id%TYPE,
        --  p_DSM_ORG   NUMBER(14)                     Орган ПФУ
        p_DSM_DPPA     IN     distrib_po_setup_main.DSM_DPPA%TYPE,
        p_DSM_DPG      IN     distrib_po_setup_main.DSM_DPG%TYPE,
        p_DSM_ID_new      OUT distrib_po_setup_main.dsm_id%TYPE)
    IS
    BEGIN
        IF (p_DSM_ID IS NULL)
        THEN
            INSERT INTO distrib_po_setup_main (dsm_org, dsm_dppa, dsm_dpg)
                 VALUES (
                            SYS_CONTEXT (ikis_finzvit_context.gContext,
                                         ikis_finzvit_context.gOPFU),
                            p_dsm_dppa,
                            p_dsm_dpg)
              RETURNING dsm_id
                   INTO p_DSM_ID_new;
        ELSE
            p_DSM_ID_new := p_DSM_ID;

            CheckCanChangeAndLock (p_dsm_id);

            UPDATE distrib_po_setup_main
               SET dsm_dppa = p_dsm_dppa, dsm_dpg = p_dsm_dpg
             WHERE dsm_id = p_dsm_id;
        END IF;
    END;

    PROCEDURE SetDistribPoSetupLine (
        p_DSL_ID     IN distrib_po_setup_line.dsl_id%TYPE,
        p_DSL_DSM    IN distrib_po_setup_line.DSL_DSM%TYPE,
        p_DSL_ORG    IN distrib_po_setup_line.DSL_ORG%TYPE,
        p_DSL_DPPA   IN distrib_po_setup_line.DSL_DPPA%TYPE)
    IS
    BEGIN
        IF (p_DSL_ID IS NULL)
        THEN
            INSERT INTO distrib_po_setup_line (dsl_dsm, dsl_org, dsl_dppa)
                 VALUES (p_dsl_dsm, p_dsl_org, p_dsl_dppa);
        ELSE
            UPDATE distrib_po_setup_line
               SET                       --               dsl_dsm = p_dsl_dsm,
                   dsl_org = p_dsl_org, dsl_dppa = p_dsl_dppa
             WHERE dsl_id = p_dsl_id AND dsl_dsm = p_dsl_dsm;
        END IF;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
            IF (INSTR (SQLERRM, 'XAK') > 0)
            THEN
                raise_application_error (-20000,
                                         'Є дублі по ОПФУ в одержувачах!');
            END IF;
    END;

    PROCEDURE DeleteDistribPoSetupMain (
        p_DSM_ID   IN distrib_po_setup_line.dsl_id%TYPE)
    IS
    BEGIN
        CheckCanChangeAndLock (p_dsm_id);

        DELETE distrib_po_setup_line
         WHERE dsl_dsm = p_dsm_id;

        DELETE distrib_po_setup_main
         WHERE dsm_id = p_dsm_id;
    END;

    PROCEDURE DeleteDistribPoSetupLine (
        p_DSL_ID   IN distrib_po_setup_line.dsl_id%TYPE)
    IS
    BEGIN
        DELETE distrib_po_setup_line
         WHERE dsl_id = p_dsl_id;
    END;
END FINZVIT_DISTRIB_PO;
/