/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.rpt_common (
    OPT_USER_ID          VARCHAR2,
    OPT_UNIQUE           VARCHAR2,
    p_code               VARCHAR2,
    p_where              VARCHAR2,
    OPT_SUBSYS           VARCHAR2,
    p_table       IN OUT IKIS_COMMON.TReportResult)
    AUTHID CURRENT_USER
IS
    l_qry      ikis_scripts.isc_query%TYPE;
    l_where1   ikis_scripts.isc_where%TYPE;
    l_where    VARCHAR2 (10000);
    l_sql      VARCHAR2 (32760);
    i          NUMBER;
BEGIN
    IF p_code IS NULL
    THEN
        raise_application_error (
            -20121,
            'Немає параметрів для виконання процедури звіту',
            FALSE);
    END IF;

    IF p_code IS NOT NULL
    THEN
        SELECT TRIM (isc_query), TRIM (isc_where)
          INTO l_qry, l_where1
          FROM ikis_scripts
         WHERE UPPER (isc_code) = UPPER (p_code);
    END IF;

    IF p_where IS NOT NULL
    THEN
        IF INSTR (l_where1, '<RPT_USE_PAR_LIST_TABLE>') > 0
        THEN
            l_where1 := REPLACE (l_where1, '<RPT_USE_PAR_LIST_TABLE>', '');

            INSERT INTO tt_rpt_cur_par_lst (pc_id, pc_value)
                SELECT rps_id, rps_value
                  FROM ikis_rpt_par_lst
                 WHERE rps_id = p_where;

            DELETE FROM ikis_rpt_par_lst
                  WHERE rps_id = p_where;

            COMMIT;
        END IF;

        l_where := REPLACE (l_where1, '<PARLST>', p_where);
    END IF;

    IF p_where IS NULL AND INSTR (l_where1, '<PARLST>') > 0
    THEN
        l_where := 'and 1=2';
    END IF;

    IF INSTR (l_qry, '<WHERESECTION>') > 0
    THEN
        l_sql := REPLACE (l_qry, '<WHERESECTION>', l_where);
    ELSE
        l_sql := l_qry || ' ' || l_where;
    END IF;

    DECLARE
        l_owner   ikis_subsys.ss_owner%TYPE;
    BEGIN
        SELECT ss_owner
          INTO l_owner
          FROM ikis_subsys
         WHERE ss_code = 'IKIS_ERS';

        EXECUTE IMMEDIATE   'begin '
                         || l_owner
                         || '.fga$utils.init_area_subsys('''
                         || OPT_SUBSYS
                         || '''); end;';
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;

    ikis_common.SetTraceOnRegKey (OPT_SUBSYS);

    BEGIN
        OPEN p_table FOR l_sql;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20121,
                   'Помилка при виконанні запроса звіта'
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || SUBSTR (l_qry, 1, 2000),
                FALSE);
    END;
END rpt_common;
/


CREATE OR REPLACE PUBLIC SYNONYM RPT_COMMON FOR IKIS_SYS.RPT_COMMON
/


GRANT EXECUTE ON IKIS_SYS.RPT_COMMON TO II01RC_IKIS_COMMON
/
