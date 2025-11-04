/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_PARAMS
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    FUNCTION insert_rpt_param (p_rp_rpt         NUMBER,
                               p_rp_nrp         NUMBER,
                               p_rp_numvalue    NUMBER DEFAULT NULL,
                               p_rp_charvalue   VARCHAR2 DEFAULT NULL,
                               p_rp_datevalue   DATE DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE update_rpt_params (p_rp_id          NUMBER,
                                 p_rp_rpt         NUMBER DEFAULT NULL,
                                 p_rp_nrp         NUMBER DEFAULT NULL,
                                 p_rp_numvalue    NUMBER DEFAULT NULL,
                                 p_rp_charvalue   VARCHAR2 DEFAULT NULL,
                                 p_rp_datevalue   DATE DEFAULT NULL);

    PROCEDURE delete_rpt_params (p_rp_id NUMBER);

    PROCEDURE add_rpt_params (p_rpt_id     NUMBER,
                              p_rt_id      NUMBER,
                              p_org_id     NUMBER DEFAULT 28000,
                              p_start_dt   DATE DEFAULT NULL,
                              p_stop_dt    DATE DEFAULT NULL);

    PROCEDURE add_rpt_params_new (p_rpt_id   NUMBER,
                                  p_rt_id    NUMBER,
                                  p_params   API$RPT_XLS.t_params);
END API$RPT_PARAMS;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_PARAMS
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    msgCOMMON_EXCEPTION   NUMBER := 2;

    FUNCTION insert_rpt_param (p_rp_rpt         NUMBER,
                               p_rp_nrp         NUMBER,
                               p_rp_numvalue    NUMBER DEFAULT NULL,
                               p_rp_charvalue   VARCHAR2 DEFAULT NULL,
                               p_rp_datevalue   DATE DEFAULT NULL)
        RETURN NUMBER
    IS
        l_out_id   NUMBER;
    BEGIN
        INSERT INTO RPT_PARAMS (rp_id,
                                rp_rpt,
                                rp_nrp,
                                rp_numvalue,
                                rp_charvalue,
                                rp_datevalue)
             VALUES (0,
                     p_rp_rpt,
                     p_rp_nrp,
                     p_rp_numvalue,
                     p_rp_charvalue,
                     p_rp_datevalue)
          RETURNING rp_id
               INTO l_out_id;

        RETURN l_out_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_PARAMS.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_rpt_params (p_rp_id          NUMBER,
                                 p_rp_rpt         NUMBER DEFAULT NULL,
                                 p_rp_nrp         NUMBER DEFAULT NULL,
                                 p_rp_numvalue    NUMBER DEFAULT NULL,
                                 p_rp_charvalue   VARCHAR2 DEFAULT NULL,
                                 p_rp_datevalue   DATE DEFAULT NULL)
    IS
    BEGIN
        UPDATE RPT_PARAMS
           SET rp_rpt = NVL (p_rp_rpt, rp_rpt),
               rp_nrp = NVL (p_rp_nrp, rp_nrp),
               rp_numvalue = NVL (p_rp_numvalue, rp_numvalue),
               rp_charvalue = NVL (p_rp_charvalue, rp_charvalue),
               rp_datevalue = NVL (p_rp_datevalue, rp_datevalue)
         WHERE rp_id = p_rp_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_PARAMS.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE delete_rpt_params (p_rp_id NUMBER)
    IS
    BEGIN
        DELETE FROM RPT_PARAMS
              WHERE rp_id = p_rp_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_PARAMS.delete: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE add_rpt_params (p_rpt_id     NUMBER,
                              p_rt_id      NUMBER,
                              p_org_id     NUMBER DEFAULT 28000,
                              p_start_dt   DATE DEFAULT NULL,
                              p_stop_dt    DATE DEFAULT NULL)
    IS
        l_id       NUMBER;
        l_prp_id   NUMBER;
    BEGIN
        SELECT MAX (nrp_id)
          INTO l_prp_id
          FROM uss_ndi.v_ndi_rpt_params p
         WHERE nrp_rt = p_rt_id AND p.nrp_code = 'ORG';

        l_id :=
            insert_rpt_param (p_rp_rpt        => p_rpt_id,
                              p_rp_nrp        => l_prp_id,
                              p_rp_numvalue   => p_org_id);

        SELECT MAX (nrp_id)
          INTO l_prp_id
          FROM uss_ndi.v_ndi_rpt_params p
         WHERE nrp_rt = p_rt_id AND p.nrp_code = 'START';

        l_id :=
            insert_rpt_param (p_rp_rpt         => p_rpt_id,
                              p_rp_nrp         => l_prp_id,
                              p_rp_datevalue   => p_start_dt);

        SELECT MAX (nrp_id)
          INTO l_prp_id
          FROM uss_ndi.v_ndi_rpt_params p
         WHERE nrp_rt = p_rt_id AND p.nrp_code = 'STOP';

        l_id :=
            insert_rpt_param (p_rp_rpt         => p_rpt_id,
                              p_rp_nrp         => l_prp_id,
                              p_rp_datevalue   => p_stop_dt);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_PARAMS.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;


    PROCEDURE add_rpt_params_new (p_rpt_id   NUMBER,
                                  p_rt_id    NUMBER,
                                  p_params   API$RPT_XLS.t_params)
    IS
        l_id       NUMBER;
        l_prp_id   NUMBER;
    BEGIN
        FOR xx
            IN (SELECT *
                  FROM TABLE (p_params)  t
                       JOIN uss_ndi.v_ndi_rpt_params p
                           ON (p.nrp_code = t.p_name)
                 WHERE p.nrp_rt = p_rt_id)
        LOOP
            l_id :=
                insert_rpt_param (
                    p_rp_rpt   => p_rpt_id,
                    p_rp_nrp   => xx.nrp_id,
                    p_rp_numvalue   =>
                        CASE WHEN xx.nrp_data_tp = 'N' THEN xx.p_value END,
                    p_rp_charvalue   =>
                        CASE WHEN xx.nrp_data_tp = 'C' THEN xx.p_value END,
                    p_rp_datevalue   =>
                        CASE
                            WHEN xx.nrp_data_tp = 'D'
                            THEN
                                TO_DATE (xx.p_value, 'DD.MM.YYYY')
                        END);
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_PARAMS.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
END API$RPT_PARAMS;
/