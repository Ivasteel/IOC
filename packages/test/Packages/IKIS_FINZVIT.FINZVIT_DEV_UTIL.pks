/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_DEV_UTIL
IS
    -- Author  : MAXYM
    -- Created : 11.10.2018 16:16:27
    -- Purpose : Функции необходимые для разработки. В пром не участвуют

    FUNCTION GetConstraintNPF6FromDescription (
        description   IN VARCHAR2,
        report_code   IN VARCHAR2 := 'F6PF_R')
        RETURN VARCHAR2
        DETERMINISTIC;

    PROCEDURE InsertPf6Constraint (c VARCHAR2, rc VARCHAR2:= 'F6PF_R');

    -- Запихиваем контроли списком с разделителем "новая строка"
    PROCEDURE InsertPf6ConstraintList (p_clob   IN CLOB,
                                       rc          VARCHAR2 := 'F6PF_R');
END FINZVIT_DEV_UTIL;
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_DEV_UTIL
IS
    FUNCTION GetConstraintNPF6FromDescription (description   IN VARCHAR2,
                                               report_code   IN VARCHAR2)
        RETURN VARCHAR2
        DETERMINISTIC
    IS
        res   VARCHAR2 (2000);
    BEGIN
        res := REPLACE (description, ' ', '');
        res :=
            REGEXP_REPLACE (
                res,
                '(ряд)([[:digit:].]{1,})(_)(кол)([[:digit:].]{1,})',
                'CELL("' || report_code || '","\2","\5")');
        RETURN '(' || res || ')';
    END;

    -- Запихиваем контроли списком с разделителем "новая строка"
    PROCEDURE InsertPf6ConstraintList (p_clob   IN CLOB,
                                       rc          VARCHAR2 := 'F6PF_R')
    IS
        l_offset         PLS_INTEGER := 1;
        l_line           VARCHAR2 (32767);
        l_total_length   PLS_INTEGER := LENGTH (p_clob);
        l_line_length    PLS_INTEGER;
    BEGIN
        WHILE l_offset <= l_total_length
        LOOP
            l_line_length := INSTR (p_clob, CHR (10), l_offset) - l_offset;

            IF l_line_length < 0
            THEN
                l_line_length := l_total_length + 1 - l_offset;
            END IF;

            l_line := SUBSTR (p_clob, l_offset, l_line_length);
            --do line processing
            DBMS_OUTPUT.put_line (l_line);
            InsertPf6Constraint (REPLACE (TRIM (l_line), '.', ''), rc);
            DBMS_OUTPUT.put_line ('-----');
            l_offset := l_offset + l_line_length + 1;
        END LOOP;
    END;

    PROCEDURE InsertPf6Constraint (c VARCHAR2, rc VARCHAR2:= 'F6PF_R')
    IS
        v            VARCHAR2 (2000) := c;
        rn           VARCHAR2 (200);
        f            VARCHAR2 (2000)
            := finzvit_dev_util.GetConstraintNPF6FromDescription (
                   SUBSTR (c, INSTR (c, ':') + 1));
        packId       NUMBER;
        id           NUMBER;
        checkCount   PLS_INTEGER;
    BEGIN
        SELECT rt_name
          INTO rn
          FROM rpt_template
         WHERE rt_code = rc;

        SELECT r2pt_pt
          INTO packId
          FROM rpt_in_pack_template, rpt_template
         WHERE r2pt_rt = rt_id AND rt_code = rc;

        --  v := replace(v, '_____(назва звіту)', rn);
        v := REPLACE (v, ' умова для звіту ___(назва звіту)', '');
        DBMS_OUTPUT.put_line (v);
        DBMS_OUTPUT.put_line (f);

        SELECT COUNT (*)
          INTO checkCount
          FROM rpt_pack_constraints
         WHERE     CAST (rpc_constraint AS VARCHAR2 (2000)) = f
               AND rpc_pt = packId;

        IF checkCount = 0
        THEN
            SELECT MAX (rpc_id) + 10 INTO id FROM rpt_pack_constraints;

            INSERT INTO rpt_pack_constraints (rpc_id,
                                              rpc_message,
                                              rpc_constraint,
                                              rpc_ord,
                                              rpc_tp,
                                              rpc_pt,
                                              rpc_is_active)
                 VALUES (id,
                         v,
                         f,
                         100,
                         'E',
                         packId,
                         'T');

            DBMS_OUTPUT.put_line ('Додано контроль ' || id);
        ELSE
            DBMS_OUTPUT.put_line ('Контроль вже існує');
        END IF;
    END;
END FINZVIT_DEV_UTIL;
/