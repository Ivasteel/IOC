/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.common_mon (p_condition   IN     CLOB,
                                                 p_result         OUT CLOB)
IS
    l_user_st       VARCHAR2 (32000);
    l_users_lk      VARCHAR2 (32000);
    l_msg           VARCHAR2 (32000);

    l_is_crytical   BOOLEAN := FALSE;
    l_is_warning    BOOLEAN := FALSE;
    l_is_ok         BOOLEAN := FALSE;

    l_msg1          VARCHAR2 (32000);
    l_msg2          VARCHAR2 (32000);
    l_msg3          VARCHAR2 (32000);
    l_msg4          VARCHAR2 (32000);
    l_msg5          VARCHAR2 (32000);
BEGIN
    FOR cur
        IN (SELECT u.username, u.account_status
              FROM dba_users u
             WHERE     u.username NOT IN ('IKIS_SRVEA')
                   AND u.account_status != 'OPEN'
                   AND (   u.username LIKE '%APEX_PUBLIC%'
                        OR u.username LIKE '%EL_ARCH_PROXY%'
                        OR u.username LIKE '%AUTH%'
                        OR u.username LIKE '%SRV%'
                        OR u.username LIKE '%SERVICE%'
                        OR u.username LIKE '%DNET%'
                        OR u.username LIKE 'IC_WORKER%')
                   AND u.username NOT IN ('DOVIDKA_SERVICE_PROXY_MIL'))
    LOOP
        l_msg :=
               l_msg
            || 'Користувач '
            || cur.username
            || ' має статус '
            || cur.account_status
            || '. ';
        l_is_crytical := TRUE;
    END LOOP;

    FOR cur1
        IN (WITH
                ids
                AS
                    (SELECT /*+Materialize */
                            MIN (b.iel_id)     id
                       FROM ikis_sys.ikis_exception_log b
                      WHERE b.iel_date > SYSDATE - 2 / 24)
            SELECT rn,
                   (   TO_CHAR (t.iel_date, 'dd.mm.yyyy hh24:mi:ss')
                    || ': '
                    || t.iel_paramvalue1
                    || ' '
                    || t.iel_paramvalue2)    msg1,
                   CASE
                       WHEN t.iel_paramvalue2 LIKE ('%ORA-00060%') THEN 'W'
                       ELSE 'E'
                   END                       tp
              FROM (SELECT a.iel_date,
                           a.iel_paramvalue1,
                           a.iel_paramvalue2,
                           ROW_NUMBER () OVER (ORDER BY a.iel_date DESC)    rn
                      FROM ikis_sys.ikis_exception_log a, ids
                     WHERE     1 = 1
                           AND a.iel_id > ids.id
                           AND a.iel_paramvalue1 NOT LIKE
                                   '%DWH$PZV_LOAD_V2.ProcessOPFU%'
                           AND a.iel_paramvalue2 NOT LIKE '%IKIS-000002%'
                           AND (   a.iel_paramvalue2 LIKE '%ORA-00060%'
                                OR a.iel_paramvalue2 LIKE '%lock%'
                                OR a.iel_paramvalue2 LIKE '%TNS:%'
                                OR a.iel_paramvalue2 LIKE '%network%error%'
                                OR a.iel_paramvalue2 LIKE
                                       '%existing state of%'
                                OR a.iel_paramvalue2 LIKE '%ORA-01653%')) t
             WHERE t.rn <= 5)
    LOOP
        IF cur1.tp = 'E'
        THEN
            l_is_crytical := TRUE;
            l_msg := l_msg || cur1.msg1;
        ELSIF cur1.tp = 'W'
        THEN
            IF NOT l_is_crytical
            THEN
                l_is_warning := TRUE;
                l_msg := l_msg || cur1.msg1;
            END IF;
        ELSE
            NULL;
        END IF;

        IF cur1.rn = 1
        THEN
            l_msg1 :=
                REPLACE (
                    REPLACE (REPLACE (cur1.msg1, '"', ''), CHR (10), ' '),
                    CHR (13),
                    '');
        ELSIF cur1.rn = 2
        THEN
            l_msg2 :=
                REPLACE (
                    REPLACE (REPLACE (cur1.msg1, '"', ''), CHR (10), ' '),
                    CHR (13),
                    '');
        ELSIF cur1.rn = 3
        THEN
            l_msg3 :=
                REPLACE (
                    REPLACE (REPLACE (cur1.msg1, '"', ''), CHR (10), ' '),
                    CHR (13),
                    '');
        ELSIF cur1.rn = 4
        THEN
            l_msg4 :=
                REPLACE (
                    REPLACE (REPLACE (cur1.msg1, '"', ''), CHR (10), ' '),
                    CHR (13),
                    '');
        ELSIF cur1.rn = 5
        THEN
            l_msg5 :=
                REPLACE (
                    REPLACE (REPLACE (cur1.msg1, '"', ''), CHR (10), ' '),
                    CHR (13),
                    '');
        ELSE
            NULL;
        END IF;
    END LOOP;

    IF NOT l_is_crytical AND NOT l_is_warning
    THEN
        l_is_ok := TRUE;
    END IF;

    l_msg :=
        REPLACE (REPLACE (REPLACE (l_msg, '"', ''), CHR (10), ' '),
                 CHR (13),
                 '');
    p_Result :=
           'var syslogStats = {
    "isCrytical": '
        || CASE WHEN l_is_crytical THEN 'true' ELSE 'false' END
        || ',
    "inCrytMsg": '
        || CASE WHEN l_is_crytical THEN '"' || l_msg || '"' ELSE 'null' END
        || ',
    "isWarning": '
        || CASE WHEN l_is_warning THEN 'true' ELSE 'false' END
        || ',
    "inWarnMsg": '
        || CASE WHEN l_is_warning THEN '"' || l_msg || '"' ELSE 'null' END
        || ',
    "msg1": "'
        || l_msg1
        || '",
    "msg2": "'
        || l_msg2
        || '",
    "msg3": "'
        || l_msg3
        || '",
    "msg4": "'
        || l_msg4
        || '",
    "msg5": "'
        || l_msg5
        || '",
    "ok": '
        || CASE WHEN l_is_ok THEN 'true' ELSE 'false' END
        || ',
    "statsDate": "'
        || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
        || '"           
  }';
END common_mon;
/
