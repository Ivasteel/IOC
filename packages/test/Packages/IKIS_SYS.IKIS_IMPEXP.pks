/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_IMPEXP
    AUTHID CURRENT_USER
IS
    -- Author  : YURA_A
    -- Created : 29.01.2004 16:03:26
    -- Purpose : Import and export utilites for IKIS

    FUNCTION CheckBeforeBackup (p_pref VARCHAR2)
        RETURN NUMBER;

    FUNCTION PrepareBeforeBackup (p_pref         VARCHAR2,
                                  p_schema       VARCHAR2,
                                  p_rep_id   OUT NUMBER)
        RETURN NUMBER;

    FUNCTION PostBackup (p_pref VARCHAR2, p_schema VARCHAR2, p_rep_id NUMBER)
        RETURN NUMBER;

    FUNCTION PostRecover (p_pref        VARCHAR2,
                          p_schema      VARCHAR2,
                          p_issaverep   VARCHAR2 DEFAULT 'NOSAVE')
        RETURN NUMBER;

    FUNCTION CheckBeforeRecovery (p_pref VARCHAR2)
        RETURN NUMBER;

    PROCEDURE TempSaveRepData (p_v1   VARCHAR2,
                               p_v2   VARCHAR2,
                               p_v3   VARCHAR2,
                               p_v4   VARCHAR2,
                               p_v5   VARCHAR2);

    PROCEDURE CheckUpgradePosibility (p_pref VARCHAR2);

    FUNCTION DROPIKIS (p_isbackup VARCHAR2 DEFAULT 'NOBACKUP')
        RETURN NUMBER;

    FUNCTION DB_INFO
        RETURN NUMBER;

    FUNCTION RMCert (p_pref VARCHAR2)
        RETURN NUMBER;

    FUNCTION PrepareRMCert (p_pref VARCHAR2)
        RETURN NUMBER;

    FUNCTION UnloadRole (p_pref VARCHAR2)
        RETURN NUMBER;

    FUNCTION UnloadRep (p_pref VARCHAR2, p_rep_id NUMBER)
        RETURN NUMBER;

    FUNCTION RestartLoadFULLERS (p_pref VARCHAR2)
        RETURN NUMBER;
--procedure RecoverIkisUser(p_pref varchar2);
END IKIS_IMPEXP;
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_IMPEXP
IS
    TYPE TRefCursor IS REF CURSOR;

    TYPE TSubsysTable IS TABLE OF VARCHAR2 (255)
        INDEX BY BINARY_INTEGER;

    g_tool_ver            VARCHAR2 (10) := '1.4.1.1';
    g_fullver             VARCHAR2 (10) := '1.4.1';
    g_fullver_prev        VARCHAR2 (10) := '1.3.1';
    --g_version varchar2(10):=substr(g_fullver,1,5);
    g_pref                VARCHAR2 (4) := 'IKIS';

    g_column              NUMBER := 75;

    g_p                   NUMBER
        :=   1 * 1e7
           + 2 * 1e6
           + 3 * 1e5
           + 4 * 1e4
           + 5 * 1e3
           + 6 * 1e2
           + 7 * 1e1
           + 8;
    g_p1                  NUMBER
        :=   3 * 1e7
           + 8 * 1e6
           + 9 * 1e5
           + 4 * 1e4
           + 1 * 1e3
           + 1 * 1e2
           + 7 * 1e1
           + 4;

    g_ss_lst              VARCHAR2 (1000)
        := '''<PREF>_SYS'',''<PREF>_NDI'',''<PREF>_RZO'',''<PREF>_ERS'',''<PREF>_ERSP''';
    g_preulst             VARCHAR2 (1000) := '''<PREF>_SU'',''<PREF>_REPL''';

    exTOVNotExist         EXCEPTION;
    PRAGMA EXCEPTION_INIT (exTOVNotExist, -942);

    exRepMalformed        EXCEPTION;
    exBackupNotComplete   EXCEPTION;
    exNotLastBackup       EXCEPTION;
    exNotEnoughtBackup    EXCEPTION;

    --Переменные для хранения таймстампов бекапов
    g_TS_STR              NUMBER := 0;
    g_TS_STR1             NUMBER := -1;

    --Переменные для загрузки бекапа репозитария
    g_v1                  VARCHAR2 (4000);
    g_v2                  VARCHAR2 (4000);
    g_v3                  VARCHAR2 (4000);
    g_v4                  VARCHAR2 (4000);
    g_v5                  VARCHAR2 (4000);

    PROCEDURE SetMessageLog (p_msg VARCHAR2)
    IS
    BEGIN
        IF p_msg IS NOT NULL
        THEN
            FOR i IN 1 .. TRUNC (LENGTH (p_msg) / 248) + 1
            LOOP
                DBMS_OUTPUT.put_line (SUBSTR (p_msg, (i - 1) * 248 + 1, 248));
            END LOOP;
        ELSE
            DBMS_OUTPUT.put_line ('');
        END IF;
    END;

    PROCEDURE Banner (p_caption VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        SetMessageLog (RPAD ('*', g_column, '*'));
        SetMessageLog (
               RPAD ('** IKIS Database Tools ver. ' || g_fullver,
                     g_column - 2,
                     ' ')
            || '**');
        SetMessageLog (RPAD ('*', g_column, '*'));
        SetMessageLog ('');

        IF p_caption IS NOT NULL
        THEN
            SetMessageLog (RPAD ('-', g_column, '-'));
            SetMessageLog (
                RPAD ('** ' || p_caption, g_column - 2, ' ') || '**');
            SetMessageLog (RPAD ('-', g_column, '-'));
            SetMessageLog ('');
        END IF;
    END;

    FUNCTION GetIkisVer (p_pref VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (50);
    BEGIN
        EXECUTE IMMEDIATE   'begin :a:='
                         || p_pref
                         || '_sys.ikis_common.getap_ikis_pfu_version; end;'
            USING OUT l_res;

        RETURN l_res;
    END;

    FUNCTION CheckBeforeBackup (p_pref VARCHAR2)
        RETURN NUMBER
    IS
        l_ver   VARCHAR2 (100);
    BEGIN
        Banner (
            'Процедура перевірки можливості створення логічної резервної копії ІКІС.');
        SetMessageLog (
            'Перевірка можливості створення логічної копії ІКІС...');
        --execute immediate 'begin :a:='||p_pref||'_sys.ikis_common.getap_ikis_pfu_version; end;' using out l_ver;
        l_ver := GetIkisVer (p_pref);

        --+Yura_AP  2005-06-10 Будет бекапить две версии ИКИСа
        IF NOT (   SUBSTR (l_ver, 1, 5) = SUBSTR (g_fullver, 1, 5)
                OR SUBSTR (l_ver, 1, 5) = SUBSTR (g_fullver_prev, 1, 5))
        THEN
            raise_application_error (
                -20000,
                   'Невідповідна версія ПЗ. Поточна '
                || SUBSTR (l_ver, 1, INSTR (l_ver, '.', -1) - 1)
                || '. Необхідна версія: '
                || g_fullver
                || ' або '
                || g_fullver_prev);
        END IF;

        SetMessageLog ('Створення логічної резервної копії можливе.');
        --+yura_ap 2005-06-10 создание таблицы репозитария бекапов
        SetMessageLog ('Додаткове налагодження.');

        BEGIN
            EXECUTE IMMEDIATE   'create table '
                             || p_pref
                             || '_sys.ikis_backups (ib_id number primary key, ib_tss timestamp,'
                             || 'ib_tse timestamp, ib_tools_ver varchar2(50),'
                             || 'ib_val1 varchar2(500), ib_val2 varchar2(500),'
                             || 'ib_emessage varchar2(4000),ib_sysver varchar2(50),'
                             || 'ib_chksum varchar2(4000)) tablespace ikis_sys_tbs';
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog (
                    'Попередження при додатковом налагодженні 1: ' || SQLERRM);
        END;

        BEGIN
            EXECUTE IMMEDIATE   'create sequence '
                             || p_pref
                             || '_sys.sq_ikis_backups_id';
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog (
                    'Попередження при додатковом налагодженні 2: ' || SQLERRM);
        END;

        RETURN 0;
    END;

    FUNCTION CheckBeforeRecovery (p_pref VARCHAR2)
        RETURN NUMBER
    IS
        l_cnt1     NUMBER;
        l_cnt2     NUMBER;
        l_usrlst   VARCHAR2 (4000);
        l_pref     VARCHAR2 (10);
    BEGIN
        Banner (
            'Процедура перевірки можливості відновлення ІКІС з логічної резервної копії.');
        SetMessageLog (
            'Перевірка можливості відновлення ІКІС з логічної резервної копії...');

        IF p_pref IS NOT NULL
        THEN
            l_pref := UPPER (p_pref);
            l_usrlst :=
                   REPLACE (g_ss_lst, '<PREF>', l_pref)
                || ','
                || REPLACE (g_preulst, '<PREF>', l_pref);

            --l_usrlst:= ''''||l_pref||'_SYS'','''||l_pref||'_NDI'','''||l_pref||'_RZO'','''||l_pref||'_ERS'','''||l_pref||'_ERSP'','''||l_pref||'_SU'','''||l_pref||'_REPL''';
            EXECUTE IMMEDIATE   'begin select count(*) into :l_cnt1 from dba_users x where x.username in ('
                             || l_usrlst
                             || '); end;'
                USING OUT l_cnt1;

            EXECUTE IMMEDIATE   'begin select count(*) into :l_cnt2 from dba_roles y where y.role like upper('''
                             || p_pref
                             || ''')||''%''; end;'
                USING OUT l_cnt2;

            IF l_cnt1 > 0
            THEN
                SetMessageLog (
                       'ПОМИЛКА! Знайдено компоненти попереднього екземпляру ІКІС: '
                    || UPPER (l_pref));
            END IF;

            IF l_cnt2 > 0
            THEN
                SetMessageLog (
                       'ПОМИЛКА! Знайдено системні компоненти попереднього екземпляру ІКІС: '
                    || UPPER (l_pref));
            END IF;

            IF l_cnt1 + l_cnt2 > 0
            THEN
                --raise_application_error(-20000,'Неможливо провести відновлення з логічної копії');
                SetMessageLog (
                    'ПОМИЛКА! Неможливо провести відновлення з логічної копії в наслідок знайдених компонентів попереднього екземплару ІКІС.');
                RETURN 1;
            ELSE
                SetMessageLog ('Відновлення з логічної копії можливе.');
                RETURN 0;
            END IF;
        ELSE
            SetMessageLog (
                'ПОМИЛКА! Відновлення з логічної копії неможливе. Префікс не вказано');
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetMessageLog (
                   'Помилка при перевірці можливості відновлення з логічної копії: '
                || CHR (10)
                || SQLERRM);
            RETURN 1;
    END;

    PROCEDURE SaveExcLogMessage (p_pref   VARCHAR2,
                                 p_msg1   VARCHAR2,
                                 p_msg2   VARCHAR2 DEFAULT NULL,
                                 p_msg3   VARCHAR2 DEFAULT NULL,
                                 p_msg4   VARCHAR2 DEFAULT NULL,
                                 p_msg5   VARCHAR2 DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_sql   VARCHAR2 (4000);
    BEGIN
        l_sql :=
               'insert into '
            || p_pref
            || '_sys.ikis_exception_log '
            || '(iel_id, iel_ipm, iel_paramvalue1,iel_paramvalue2,iel_paramvalue3,iel_paramvalue4,iel_paramvalue5,iel_date) values '
            || '(0, 117, '''
            || p_msg1
            || ''','''
            || p_msg2
            || ''','''
            || p_msg3
            || ''','''
            || p_msg4
            || ''','''
            || p_msg5
            || ''', sysdate)';

        EXECUTE IMMEDIATE l_sql;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'Помилка при спробі збереження повідомлення: '
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION EncriptData (p_pref VARCHAR2, p_data VARCHAR2, p_key VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (32760);
    BEGIN
        EXECUTE IMMEDIATE   'begin :l_res:='
                         || p_pref
                         || '_sys.ikis_crypt.encryptraw(utl_raw.cast_to_raw(:p_data),utl_raw.cast_to_raw(:p_key)); end;'
            USING OUT l_res, IN p_data, IN p_key;

        RETURN l_res;
    END;

    FUNCTION DecriptData (p_pref VARCHAR2, p_data VARCHAR2, p_key VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (32760);
    BEGIN
        EXECUTE IMMEDIATE   'begin :l_out:='
                         || p_pref
                         || '_sys.ikis_crypt.decryptraw(:data,utl_raw.cast_to_raw(:p)); end;'
            USING OUT l_res, IN p_data, IN p_key;

        l_res := UTL_RAW.cast_to_varchar2 (l_res);
        RETURN l_res;
    END;

    FUNCTION PrepareBeforeBackup (p_pref         VARCHAR2,
                                  p_schema       VARCHAR2,
                                  p_rep_id   OUT NUMBER)
        RETURN NUMBER
    IS
        l_data            VARCHAR2 (32765);
        exRepos           EXCEPTION;
        exNotConsistent   EXCEPTION;
        l_err             VARCHAR2 (1000);
    BEGIN
        Banner ('Процедура підготовки ІКІС до резервного копіювання.');
        SetMessageLog (
               'Підготовка екземпляру ІКІС "'
            || p_pref
            || '" до резервного копіювання');
        SetMessageLog ('Створення запису репозитарію...');

        DECLARE
            s1       NUMBER;
            s2       NUMBER;
            l_s1     VARCHAR2 (1000);
            l_s2     VARCHAR2 (1000);
            l_ts     TIMESTAMP;
            l_chs    VARCHAR2 (1000);
            l_iver   VARCHAR2 (50);
        BEGIN
            EXECUTE IMMEDIATE   'begin :s1:='
                             || p_pref
                             || '_sys.ikis_obmf.getstr; :s2:='
                             || p_pref
                             || '_sys.ikis_obmf.getstr1; end;'
                USING OUT s1, OUT s2;

            IF NOT (s1 = s2)
            THEN
                RAISE exNotConsistent;
            END IF;

            l_s1 := EncriptData (p_pref, TO_CHAR (s1), g_p1);
            l_s2 := EncriptData (p_pref, TO_CHAR (s2), g_p1);
            l_ts := SYSTIMESTAMP;
            l_chs :=
                EncriptData (
                    p_pref,
                    l_s1 || l_s2 || TO_CHAR (l_ts, 'ddmmyyyyhh24missff9'),
                    g_p1);
            l_iver := GetIkisVer (p_pref);

            EXECUTE IMMEDIATE   'insert into '
                             || p_pref
                             || '_sys.ikis_backups '
                             || '  (ib_id, ib_tss, ib_tools_ver,ib_sysver, ib_val1, ib_val2, ib_chksum) '
                             || 'values '
                             || '  ('
                             || p_pref
                             || '_sys.sq_ikis_backups_id.nextval, :v_ib_tss, :v_ib_tools_ver, :v_ib_sysver, :v_ib_val1, :v_ib_val2, :v_ib_chksum) returning ib_id into :p_rep_id'
                USING IN l_ts,
                      IN g_tool_ver,
                      IN l_iver,
                      IN l_s1,
                      IN l_s2,
                      IN l_chs
                RETURNING INTO p_rep_id;

            COMMIT;
        EXCEPTION
            WHEN exNotConsistent
            THEN
                RAISE exNotConsistent;
            WHEN OTHERS
            THEN
                l_err := SQLERRM;
                RAISE exRepos;
        END;

        SetMessageLog ('Етап перший...');

        BEGIN
            EXECUTE IMMEDIATE   'begin '
                             || p_pref
                             || '_sys.ikis_ddl.checkddl; end;';

            SetMessageLog (
                'Знайдено, що попередня сесія резервного копіювання завершилася аварійно...');
            SetMessageLog (
                'Відновлено стан даних для виконання резервного копіювання');
        EXCEPTION
            WHEN OTHERS
            THEN
                EXECUTE IMMEDIATE   'begin :l_data:='
                                 || p_pref
                                 || '_sys.ikis_crypt.encryptraw(utl_raw.cast_to_raw(''CAN_DDL''),utl_raw.cast_to_raw(''12345678'')); end;'
                    USING OUT l_data;

                EXECUTE IMMEDIATE   'begin '
                                 || p_pref
                                 || '_sys.ikis_parameter_util.addparameter(''DDL_PWD'',''IKIS_SYS'',:l_data); end;'
                    USING IN l_data;
        END;

        SetMessageLog ('Етап перший виконано');
        SetMessageLog ('Етап другий...');

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl1 disable';

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl2 disable';

        SetMessageLog ('Етап другий виконано');
        SaveExcLogMessage (p_pref,
                           'Start Logical Backup',
                           g_fullver,
                           p_pref);
        RETURN 0;
    EXCEPTION
        WHEN exNotConsistent
        THEN
            SetMessageLog (
                'ПОМИЛКА!: порушення консистентності БД ІКІС в розподіленій системі.');
            RETURN 1;
        WHEN exRepos
        THEN
            SetMessageLog (
                   'Помилка при підготовці до логічного резервного копіювання ІКІС (операції з репозитарієм): '
                || CHR (10)
                || l_err);
            RETURN 1;
        WHEN OTHERS
        THEN
            SetMessageLog (
                   'Помилка при підготовці до логічного резервного копіювання ІКІС: '
                || CHR (10)
                || SQLERRM);
            RETURN 1;
    END;

    FUNCTION UnloadRep (p_pref VARCHAR2, p_rep_id NUMBER)
        RETURN NUMBER
    IS
        l_pref   VARCHAR2 (10) := UPPER (p_pref);
        l_crs    TRefCursor;
        l_out    VARCHAR2 (1000);

        l_s1     VARCHAR2 (1000);
        l_s2     VARCHAR2 (1000);
        l_ts1    TIMESTAMP;
        l_ts2    TIMESTAMP;
        l_chs    VARCHAR2 (1000);
    BEGIN
        DBMS_OUTPUT.enable (1000000);

        OPEN l_crs FOR
               'select ib_tss,ib_tse,ib_val1,ib_val2,ib_chksum '
            || '  from '
            || l_pref
            || '_sys.ikis_backups y '
            || ' where y.ib_id='
            || p_rep_id;

        LOOP
            FETCH l_crs
                INTO l_ts1,
                     l_ts2,
                     l_s1,
                     l_s2,
                     l_chs;

            EXIT WHEN l_crs%NOTFOUND;
            DBMS_OUTPUT.put_line ('variable l_reprec1 varchar2(1000)');
            DBMS_OUTPUT.put_line ('variable l_reprec2 varchar2(1000)');
            DBMS_OUTPUT.put_line ('variable l_reprec3 varchar2(1000)');
            DBMS_OUTPUT.put_line ('variable l_reprec4 varchar2(1000)');
            DBMS_OUTPUT.put_line ('variable l_reprec5 varchar2(1000)');
            --    dbms_output.put_line('variable l_return varchar2(10)');
            DBMS_OUTPUT.put_line ('begin');
            DBMS_OUTPUT.put_line (
                   ':l_reprec1:='''
                || EncriptData (l_pref, l_ts1, g_p1)
                || ''';');
            DBMS_OUTPUT.put_line (
                   ':l_reprec2:='''
                || EncriptData (l_pref, l_ts2, g_p1)
                || ''';');
            DBMS_OUTPUT.put_line (':l_reprec3:=''' || l_s1 || ''';');
            DBMS_OUTPUT.put_line (':l_reprec4:=''' || l_s2 || ''';');
            DBMS_OUTPUT.put_line (':l_reprec5:=''' || l_chs || ''';');
            DBMS_OUTPUT.put_line ('ikis_impexp.TempSaveRepData(');
            DBMS_OUTPUT.put_line ('p_v1 => :l_reprec1, ');
            DBMS_OUTPUT.put_line ('p_v2 => :l_reprec2, ');
            DBMS_OUTPUT.put_line ('p_v3 => :l_reprec3, ');
            DBMS_OUTPUT.put_line ('p_v4 => :l_reprec4, ');
            DBMS_OUTPUT.put_line ('p_v5 => :l_reprec5); ');
            DBMS_OUTPUT.put_line ('end;');
            DBMS_OUTPUT.put_line ('/');
        END LOOP;

        CLOSE l_crs;

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            SetMessageLog (
                   'Помилка при вивантаженні інформації з репозитарію резервних копій ІКІС'
                || CHR (10)
                || SQLERRM);
            RETURN 1;
    END;

    PROCEDURE TempSaveRepData (p_v1   VARCHAR2,
                               p_v2   VARCHAR2,
                               p_v3   VARCHAR2,
                               p_v4   VARCHAR2,
                               p_v5   VARCHAR2)
    IS
    BEGIN
        g_v1 := p_v1;
        g_v2 := p_v2;
        g_v3 := p_v3;
        g_v4 := p_v4;
        g_v5 := p_v5;
    END;

    PROCEDURE CheckBackupTS (p_pref   VARCHAR2,
                             p_v1     VARCHAR2,
                             p_v2     VARCHAR2,
                             p_v3     VARCHAR2,
                             p_v4     VARCHAR2,
                             p_v5     VARCHAR2)
    IS
        l_crs            TRefCursor;
        l_ib_id          NUMBER;
        l_ib_tss         TIMESTAMP;
        l_ib_tse         TIMESTAMP;
        l_ib_tools_ver   VARCHAR2 (50);
        l_ib_val1        VARCHAR2 (500);
        l_ib_val2        VARCHAR2 (500);
        l_ib_emessage    VARCHAR2 (4000);
        l_ib_chksum      VARCHAR2 (4000);
        l_ib_sysver      VARCHAR2 (50);

        lr_notinstall    BOOLEAN := FALSE;
    BEGIN
        l_ib_tss := DecriptData (p_pref, p_v1, g_p1);
        l_ib_tse := DecriptData (p_pref, p_v2, g_p1);

        l_ib_val1 := DecriptData (p_pref, p_v3, g_p1);
        l_ib_val2 := DecriptData (p_pref, p_v4, g_p1);


        IF NOT (EncriptData (
                    p_pref,
                       p_v3
                    || p_v4
                    || TO_CHAR (l_ib_tss, 'ddmmyyyyhh24missff9')
                    || TO_CHAR (l_ib_tse, 'ddmmyyyyhh24missff9'),
                    g_p1) =
                p_v5)
        THEN
            RAISE exRepMalformed;
        END IF;

        CheckUpgradePosibility (p_pref);

        IF    NOT (g_TS_STR = l_ib_val1)
           OR NOT (g_TS_STR1 = l_ib_val2)
           OR NOT (g_TS_STR = g_TS_STR1)
           OR NOT (l_ib_val1 = l_ib_val2)
        THEN
            RAISE exNotEnoughtBackup;
        END IF;
    --  return 0;
    EXCEPTION
        WHEN exNotEnoughtBackup
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Логічна резервна копія в каталозі відновлення (.\_input) не співпадає с останньою в репозитарію.');
        WHEN exRepMalformed
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Дані в репозитарії резервної копії зпоплюжені.');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка при перевірці репозиторію перед очищенням БД: '
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE CheckUpgradePosibility (p_pref VARCHAR2)
    IS
        l_crs            TRefCursor;
        l_ib_id          NUMBER;
        l_ib_tss         TIMESTAMP;
        l_ib_tse         TIMESTAMP;
        l_ib_tools_ver   VARCHAR2 (50);
        l_ib_val1        VARCHAR2 (500);
        l_ib_val2        VARCHAR2 (500);
        l_ib_emessage    VARCHAR2 (4000);
        l_ib_chksum      VARCHAR2 (4000);
        l_ib_sysver      VARCHAR2 (50);
        s1               NUMBER;
        s2               NUMBER;
        s2_1             VARCHAR2 (1000);
    BEGIN
        EXECUTE IMMEDIATE   'begin :s1:='
                         || p_pref
                         || '_sys.ikis_obmf.getstr; :s2:='
                         || p_pref
                         || '_sys.ikis_obmf.getstr1; end;'
            USING OUT s1, OUT s2_1;

        BEGIN
            s2 := TO_NUMBER (s2_1);
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (-20000, 'Invalid string 1');
        END;

        OPEN l_crs FOR
               'select ib_id,ib_tss,ib_tse,ib_val1,ib_val2,ib_chksum,ib_tools_ver,ib_sysver,ib_emessage '
            || '  from '
            || p_pref
            || '_sys.ikis_backups y '
            || ' order by ib_id desc';

        LOOP
            FETCH l_crs
                INTO l_ib_id,
                     l_ib_tss,
                     l_ib_tse,
                     l_ib_val1,
                     l_ib_val2,
                     l_ib_chksum,
                     l_ib_tools_ver,
                     l_ib_sysver,
                     l_ib_emessage;

            EXIT WHEN l_crs%NOTFOUND;

            IF l_ib_tse IS NULL
            THEN
                RAISE exBackupNotComplete;
            END IF;

            IF NOT (EncriptData (
                        p_pref,
                           l_ib_val1
                        || l_ib_val2
                        || TO_CHAR (l_ib_tss, 'ddmmyyyyhh24missff9')
                        || TO_CHAR (l_ib_tse, 'ddmmyyyyhh24missff9'),
                        g_p1) =
                    l_ib_chksum)
            THEN
                RAISE exRepMalformed;
            END IF;

            l_ib_val1 := DecriptData (p_pref, l_ib_val1, g_p1);
            l_ib_val2 := DecriptData (p_pref, l_ib_val2, g_p1);

            g_TS_STR := l_ib_val1;
            g_TS_STR1 := l_ib_val2;

            IF    NOT (TO_NUMBER (l_ib_val1) = s1)
               OR NOT (TO_NUMBER (l_ib_val2) = s2)
            THEN
                RAISE exNotLastBackup;
            END IF;

            EXIT WHEN 1 = 1;
        END LOOP;

        CLOSE l_crs;

        SetMessageLog (
            'В репозиторію існує інформація про логічну резернву копію:.');
        SetMessageLog (
               RPAD ('Копіювання розпочато:', 40, '.')
            || TO_CHAR (l_ib_tss, 'DD/MM/YYYY HH24:MI:SS'));
        SetMessageLog (
               RPAD ('Копіювання завершено:', 40, '.')
            || TO_CHAR (l_ib_tse, 'DD/MM/YYYY HH24:MI:SS'));
        SetMessageLog (
            RPAD ('Версія IKIS DB Tools:', 40, '.') || l_ib_tools_ver);
        SetMessageLog (
            RPAD ('Версія системи ІКІС-ЄРС:', 40, '.') || l_ib_sysver);
    EXCEPTION
        WHEN exTOVNotExist
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Репозитарій логічних копій не знайдено');
        WHEN exBackupNotComplete
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Останній сеанс резервного копіювання не завершено. Повторіть операцію логічного резервного копіювання.');
        WHEN exRepMalformed
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Дані в репозитарії зпоплюжені.');
        WHEN exNotLastBackup
        THEN
            raise_application_error (
                -20000,
                'ПОМИЛКА! Після створення резервної копії відбувалися сеанси обміну з центру. Необхідно заново створити логічну резервну копію');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка при перевірці репозиторію (upgrade): '
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION UnloadRole (p_pref VARCHAR2)
        RETURN NUMBER
    IS
        l_pref   VARCHAR2 (10) := UPPER (p_pref);
        l_usr    VARCHAR2 (30);
        l_role   VARCHAR2 (30);
        l_crs    TRefCursor;
        l_out    VARCHAR2 (1000);
    BEGIN
        DBMS_OUTPUT.enable (1000000);

        OPEN l_crs FOR
               'select x.grantee,substr(x.granted_role,instr(x.granted_role,'''
            || l_pref
            || ''')+length('''
            || l_pref
            || ''')) '
            || '  from dba_role_privs x, '
            || l_pref
            || '_sys.v_ikis_users y '
            || ' where x.grantee=y.iu_username and y.iu_status<>''D'''
            || '   and y.iu_username not like ''%\_SU'' escape ''\'' '
            || '   and y.iu_username not like ''%\_REPL'' escape ''\'' '
            || '   and x.granted_role not like ''%\_ROOT_ROLE'' escape ''\''';

        LOOP
            FETCH l_crs INTO l_usr, l_role;

            EXIT WHEN l_crs%NOTFOUND;

            EXECUTE IMMEDIATE   'begin :l_out:='
                             || l_pref
                             || '_sys.ikis_crypt.encryptraw(utl_raw.cast_to_raw(:data),utl_raw.cast_to_raw(:p)); end;'
                USING OUT l_out, IN l_usr || '|' || l_role, IN g_p;

            DBMS_OUTPUT.put_line (
                'insert into l_role values(''' || l_out || ''');');
        END LOOP;

        DBMS_OUTPUT.put_line ('commit;');

        CLOSE l_crs;

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            SetMessageLog (
                'Помилка при вивантаженні інформації про призначення ролей користувачам ІКІС');
            RETURN 1;
    END;

    PROCEDURE RecoverUserRole (p_pref VARCHAR2)
    IS
        l_pref   VARCHAR2 (10) := UPPER (p_pref);
        l_data   VARCHAR2 (2000);
        l_out    VARCHAR2 (2000);
        l_usr    VARCHAR2 (30);
        l_role   VARCHAR2 (30);
        l_crs    TRefCursor;
    BEGIN
        SetMessageLog (
            'Підготовка до відновлення призняченнь ролей користувачам ІКІС.');

        OPEN l_crs FOR 'select data from l_role';

        LOOP
            FETCH l_crs INTO l_out;

            EXIT WHEN l_crs%NOTFOUND;

            EXECUTE IMMEDIATE   'begin :l_out:='
                             || l_pref
                             || '_sys.ikis_crypt.decryptraw(:data,utl_raw.cast_to_raw(:p)); end;'
                USING OUT l_data, IN l_out, IN g_p;

            l_data := UTL_RAW.cast_to_varchar2 (l_data);
            l_usr := SUBSTR (l_data, 1, INSTR (l_data, '|') - 1);
            l_role := SUBSTR (l_data, INSTR (l_data, '|') + 1);

            EXECUTE IMMEDIATE   'begin '
                             || l_pref
                             || '_sys.ikis_security.grantikisrole(:l_usr,:l_role);end;'
                USING IN l_usr, IN l_role;

            SetMessageLog (
                   'Відновлено призначення користувачеві '
                || l_usr
                || ' ролі '
                || p_pref
                || l_role);
        END LOOP;

        CLOSE l_crs;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetMessageLog (
                'Помилка при відновленні призначення ролей користувачам ІКІС');
    END;

    FUNCTION PostBackup (p_pref VARCHAR2, p_schema VARCHAR2, p_rep_id NUMBER)
        RETURN NUMBER
    IS
        exRepos   EXCEPTION;
        l_err     VARCHAR2 (1000);
    BEGIN
        Banner (
            ' Процедура підготовки ІКІС до роботи після резервного копіювання.');
        SetMessageLog (
               'Підготовка екземпляру ІКІС '
            || p_pref
            || ' до роботи після резервного копіювання');
        SetMessageLog ('Створення запису репозитарію...');

        DECLARE
            s1       NUMBER;
            s2       NUMBER;
            l_s1     VARCHAR2 (1000);
            l_s2     VARCHAR2 (1000);
            l_s11    VARCHAR2 (1000);
            l_s12    VARCHAR2 (1000);

            l_ts     TIMESTAMP;
            l_ts1    TIMESTAMP;
            l_chs    VARCHAR2 (1000);
            l_chs1   VARCHAR2 (1000);
        BEGIN
            IF p_rep_id IS NULL
            THEN
                SetMessageLog ('Пустій ідентифікатор запису репозитарію');
            END IF;

            EXECUTE IMMEDIATE   'begin :s1:='
                             || p_pref
                             || '_sys.ikis_obmf.getstr; :s2:='
                             || p_pref
                             || '_sys.ikis_obmf.getstr1; end;'
                USING OUT s1, OUT s2;

            IF NOT (s1 = s2)
            THEN
                SetMessageLog (
                    'Попередження: порушення консистентності БД ІКІС в розподіленій системі.');
            END IF;

            l_s1 := EncriptData (p_pref, TO_CHAR (s1), g_p1);
            l_s2 := EncriptData (p_pref, TO_CHAR (s2), g_p1);

            EXECUTE IMMEDIATE   'begin '
                             || '  select ib_tss,ib_val1,ib_val2,ib_chksum '
                             || '  into :v_ib_tss, :v_ib_val1, :v_ib_val2, :v_ib_chksum '
                             || '  from '
                             || p_pref
                             || '_sys.ikis_backups where ib_id=:p_rep_id; '
                             || 'end; '
                USING OUT l_ts1,
                      OUT l_s11,
                      OUT l_s12,
                      OUT l_chs1,
                      IN p_rep_id;

            IF NOT (    EncriptData (
                            p_pref,
                               l_s1
                            || l_s2
                            || TO_CHAR (l_ts1, 'ddmmyyyyhh24missff9'),
                            g_p1) =
                        l_chs1
                    AND l_s11 = EncriptData (p_pref, TO_CHAR (s1), g_p1)
                    AND l_s12 = EncriptData (p_pref, TO_CHAR (s2), g_p1))
            THEN
                raise_application_error (-20000,
                                         'Запис ' || p_rep_id || ' змінено.');
            END IF;

            l_ts := SYSTIMESTAMP;
            l_chs :=
                EncriptData (
                    p_pref,
                       l_s1
                    || l_s2
                    || TO_CHAR (l_ts1, 'ddmmyyyyhh24missff9')
                    || TO_CHAR (l_ts, 'ddmmyyyyhh24missff9'),
                    g_p1);


            EXECUTE IMMEDIATE   'update '
                             || p_pref
                             || '_sys.ikis_backups set '
                             || 'ib_tse=:v_ib_tse, '
                             || 'ib_chksum=:v_ib_chksum '
                             || 'where ib_id=:p_rep_id'
                USING l_ts, l_chs, p_rep_id;

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_err := SQLERRM;
                RAISE exRepos;
        END;

        EXECUTE IMMEDIATE 'begin ' || p_pref || '_sys.ikis_ddl.endddl; end;';

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl1 enable';

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl2 enable';

        SaveExcLogMessage (p_pref,
                           'Stop Logical Backup',
                           g_fullver,
                           p_pref);
        RETURN 0;
    EXCEPTION
        WHEN exRepos
        THEN
            SetMessageLog (
                   'Помилка при проведенні підготовки до роботи після логічного резервного копіювання: помилка при роботі з репозитарієм'
                || CHR (10)
                || l_err);
            RETURN 1;
        WHEN OTHERS
        THEN
            SetMessageLog (
                   'Помилка при проведенні підготовки до роботи після логічного резервного копіювання: '
                || CHR (10)
                || SQLERRM);
            RETURN 1;
    END;

    PROCEDURE SetCorrectPreInstUserInfo (p_pref VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        --Установка статуса удален старым записям о служебных пользователях
        EXECUTE IMMEDIATE   'update '
                         || p_pref
                         || '_sys.ikis_users_attr x '
                         || 'set x.iusr_st=''D'', x.iusr_stop_dt=sysdate '
                         || 'where x.iusr_internal=''Y'' and x.iusr_id not in (select user_id from dba_users)';

        COMMIT;
        SaveExcLogMessage (p_pref,
                           'End Recover Internal User',
                           g_fullver,
                           p_pref);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'Помилка при спробі збереження інформації про внутрішніх користувачів: '
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE RecoverIkisUser (p_pref VARCHAR2)
    IS
        usr        TRefCursor;
        l_login    VARCHAR2 (30);
        l_name     VARCHAR2 (1000);
        l_numid    VARCHAR2 (1000);
        l_id_old   NUMBER;
        l_id_new   NUMBER;
    BEGIN
        EXECUTE IMMEDIATE   'delete from '
                         || p_pref
                         || '_sys.ikis_users_attr where iusr_st=''D''';

        COMMIT;

        OPEN usr FOR
               'select x.iusr_login,x.iusr_id,x.iusr_name,x.iusr_numident from '
            || p_pref
            || '_sys.ikis_users_attr x where x.iusr_internal=''N'' and x.iusr_st=''A''';

        LOOP
            FETCH usr
                INTO l_login,
                     l_id_old,
                     l_name,
                     l_numid;

            EXIT WHEN usr%NOTFOUND;
            SetMessageLog (
                'Спроба відновити користувача ІКІС: ' || l_login || '...');

            BEGIN
                --+YuraAP 2005-02-08 используем существующего пользователя только если ИД и логин совпадают
                --execute immediate 'begin select user_id into :a from dba_users where user_id=:l_id_old; end;' using out l_id_new, in l_id_old;
                EXECUTE IMMEDIATE 'begin select user_id into :a from dba_users where user_id=:l_id_old and username=:l_usrnm; end;'
                    USING OUT l_id_new, IN l_id_old, l_login;

                ---YuraAP 2005-02-08
                SetMessageLog (
                    'Користувача знайдено серед існуючих на сервері БД.');

                EXECUTE IMMEDIATE   'begin '
                                 || p_pref
                                 || '_sys.ikis_security.grantikisrootrole('''
                                 || l_login
                                 || '''); end;';

                SetMessageLog ('Користувачу призначено кореневу роль ІКІС.');
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SetMessageLog (
                            'Тимчасова зміна ІД запису про користувача');

                        EXECUTE IMMEDIATE   'update '
                                         || p_pref
                                         || '_sys.ikis_users_attr set iusr_id=-1*iusr_id where iusr_id='
                                         || l_id_old;

                        COMMIT;
                        SetMessageLog (
                            'Змінено ' || l_id_old || ' на ' || -1 * l_id_old);
                    END;
                WHEN OTHERS
                THEN
                    RAISE;
            END;

            SetMessageLog (
                'Відновлення користувача ІКІС: ' || l_login || ' завершено.');
            SetMessageLog ('');
            SaveExcLogMessage (p_pref,
                               'Recover User',
                               g_fullver,
                               p_pref,
                               l_login,
                               l_id_new);
        END LOOP;

        CLOSE usr;

        OPEN usr FOR
               'select x.iusr_login,x.iusr_id,x.iusr_name,x.iusr_numident from '
            || p_pref
            || '_sys.ikis_users_attr x where x.iusr_id<0 and x.iusr_internal=''N'' and x.iusr_st=''A''';

        LOOP
            FETCH usr
                INTO l_login,
                     l_id_old,
                     l_name,
                     l_numid;

            EXIT WHEN usr%NOTFOUND;
            SetMessageLog (
                   'Відтворення користувача з тимчасово зміненими ІД: '
                || l_login);

            EXECUTE IMMEDIATE   'begin '
                             || p_pref
                             || '_sys.ikis_admin_utl.create_ikis_user(p_iu_username => :p_iu_username, '
                             || '                                  p_iu_password => :p_iu_password, '
                             || '                                  p_iu_name => :p_iu_name, '
                             || '                                  p_iu_numident => :p_iu_numident, '
                             || '                                  p_uid => :p_uid); '
                             || 'end;'
                USING IN l_login,
                      IN l_login,
                      IN l_name,
                      IN l_numid,
                      OUT l_id_new;

            SetMessageLog ('Користувача ' || l_login || ' створено заново');

            EXECUTE IMMEDIATE   'update '
                             || p_pref
                             || '_sys.ikis_users_attr x  set x.iusr_st=''D'' where x.iusr_id=:l_id_old'
                USING IN l_id_old;

            SetMessageLog (
                   'Попередній запис про користувача '
                || l_login
                || ' скасовано');
            SetMessageLog (
                   'Спроба відновити інформацію про користувача '
                || l_login
                || ' ...');

            --    execute immediate 'update '||p_pref||'_sys.ikis_users_attr set iusr_id=:new where iusr_id=:old' using in l_id_new, in l_id_old;
            --    SetMessageLog('Відновлен інформацію про користувача.');
            EXECUTE IMMEDIATE   'update '
                             || p_pref
                             || '_ers.fga_dep2users set dep2usr_usr=:new where dep2usr_usr=:old'
                USING IN l_id_new, IN -1 * l_id_old;

            COMMIT;
            SetMessageLog (
                   'Відновлено інформацію про дільниці користувача '
                || l_login
                || '.');
        END LOOP;

        CLOSE usr;
    END;

    FUNCTION PostRecover (p_pref        VARCHAR2,
                          p_schema      VARCHAR2,
                          p_issaverep   VARCHAR2 DEFAULT 'NOSAVE')
        RETURN NUMBER
    IS
    BEGIN
        Banner (
            'Процедура підготовки до роботи ІКІС після відновлення з логічної резервної копії.');
        SetMessageLog (
               'Підготовка екземпляру ІКІС '
            || p_pref
            || ' до роботи після відновлення з резервної копії');
        --  execute immediate 'begin '||p_pref||'_sys.ikis_ddl.endddl; end;';
        SetMessageLog ('Перший етап...');

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl1 enable';

        EXECUTE IMMEDIATE   'alter trigger '
                         || p_pref
                         || '_sys.ibr_lock_ddl2 enable';

        SetMessageLog ('Перший етап завершено');
        SetMessageLog ('Другий етап...');
        SetCorrectPreInstUserInfo (p_pref);
        SetMessageLog ('Другий етап завершено');
        SetMessageLog ('Третій етап...');
        RecoverIkisUser (p_pref);
        SetMessageLog ('Третій етап завершено');
        SetMessageLog ('Четвертий етап...');
        RecoverUserRole (p_pref);
        SetMessageLog ('Четвертий етап завершено');
        SetMessageLog ('П"ятий етап...');

        EXECUTE IMMEDIATE   'begin '
                         || p_pref
                         || '_sys.ikis_obmf.install; end;';

        SetMessageLog ('П"ятий етап завершено');

        IF p_issaverep = 'SAVEREPOS'
        THEN
            SetMessageLog (
                'Шостий етап (збереження запису в репозитарію)...');
            g_v2 := DecriptData (p_pref, g_v2, g_p1);

            EXECUTE IMMEDIATE   'update '
                             || p_pref
                             || '_sys.ikis_backups set '
                             || 'ib_tse=:v_ib_tse, '
                             || 'ib_chksum=:v_ib_chksum '
                             || 'where ib_id=(select max(ib_id) from '
                             || p_pref
                             || '_sys.ikis_backups)'
                USING g_v2, g_v5;

            COMMIT;
            SetMessageLog ('Шостий етап завершено');
        END IF;

        SetMessageLog ('End Recover from Logical Backup');
        SaveExcLogMessage (p_pref,
                           'End Recover from Logical Backup',
                           g_fullver,
                           p_pref);
        COMMIT;
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetMessageLog (
                   'Помилка при проведенні додаткового налагодження після відновлення з резервної копії: '
                || CHR (10)
                || SQLERRM);
            ROLLBACK;
            RETURN 1;
    END;

    PROCEDURE Clear_IkisDB (p_pref VARCHAR2)
    IS
        l_subsys_table       TSubsysTable;
        l_scount             NUMBER := 1;
        subsys_not_created   EXCEPTION;
        PRAGMA EXCEPTION_INIT (subsys_not_created, -1918);
        a                    TRefCursor;
        b                    TRefCursor;
        role_name            VARCHAR2 (30);
        l_pref               VARCHAR2 (30) := LOWER (p_pref);
    BEGIN
        SetMessageLog ('Prepare to start clearing process...');

        BEGIN
            OPEN a FOR
                'select ss_owner from ikis_sys.ikis_subsys where ss_owner is not null order by ss_owner';

            LOOP
                FETCH a INTO l_subsys_table (l_scount);

                EXIT WHEN a%NOTFOUND;
                SetMessageLog (
                       'Prepare to drop subsystem '
                    || UPPER (l_subsys_table (l_scount)));
                l_scount := l_scount + 1;
            END LOOP;

            CLOSE a;

            l_scount := l_scount - 1;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Information about subsystem is absent');
            WHEN OTHERS
            THEN
                RAISE;
        END;

        IF l_subsys_table.COUNT > 0
        THEN
            FOR i IN l_subsys_table.FIRST .. l_subsys_table.LAST
            LOOP
                BEGIN
                    SetMessageLog (
                           'Drop registered subsystem '
                        || UPPER (l_subsys_table (i)));

                    EXECUTE IMMEDIATE   'drop user '
                                     || l_subsys_table (i)
                                     || ' cascade';
                EXCEPTION
                    WHEN subsys_not_created
                    THEN
                        NULL;
                    WHEN OTHERS
                    THEN
                        RAISE;
                END;
            END LOOP;
        END IF;

        SetMessageLog ('Drop not registered subsystem...');

        OPEN a FOR
               'select x.username from dba_users x where x.username in ('
            || REPLACE (g_ss_lst, '<PREF>', l_pref)
            || ')';

        LOOP
            FETCH a INTO role_name;

            EXIT WHEN a%NOTFOUND;
            SetMessageLog ('Drop not registered subsystem ' || role_name);

            EXECUTE IMMEDIATE 'drop user ' || role_name || ' cascade';
        END LOOP;

        CLOSE a;

        SetMessageLog ('Drop preinstalled users...');

        BEGIN
            EXECUTE IMMEDIATE 'drop user ikis_repl cascade';

            EXECUTE IMMEDIATE 'drop user ikis_su cascade';

            NULL;
        EXCEPTION
            WHEN subsys_not_created
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE;
        END;

        SetMessageLog ('Drop others components...');

        OPEN b FOR
               'select role from dba_roles  where upper(role) like '''
            || p_pref
            || '%''';

        LOOP
            FETCH b INTO role_name;

            EXIT WHEN b%NOTFOUND;

            EXECUTE IMMEDIATE 'drop role ' || role_name;
        END LOOP;

        SetMessageLog ('Clear process complete.');
    END;

    FUNCTION DROPIKIS (p_isbackup VARCHAR2 DEFAULT 'NOBACKUP')
        RETURN NUMBER
    IS
        l_param_ver         VARCHAR2 (255);
        l_systems_ver_cnt   NUMBER;
        l_subsyss_ver_cnt   NUMBER;
        l_db                VARCHAR2 (30);
        l_ver               VARCHAR2 (20) := g_fullver;
        l_par               VARCHAR2 (100);
        l_par1              VARCHAR2 (100);
        l_par2              VARCHAR2 (100);
        l_par3              VARCHAR2 (100);
        l_pref              VARCHAR2 (4) := g_pref;
        l_level             NUMBER := 1;
    BEGIN
        Banner ('Процедура очищення БД ІКІС.');

        --Проверка имени БД (чтобы не снести девелоперскую)
        SELECT UPPER (SYS_CONTEXT ('USERENV', 'DB_NAME')) INTO l_db FROM DUAL;

        IF l_db = 'GLASHA'
        THEN
            raise_application_error (
                -20000,
                'Заборонено вилучати ІКІС із БД з назвою: ' || l_db);
        END IF;


        IF p_isbackup = 'BACKUPONPLACE'
        THEN
            CheckBackupTS (g_pref,
                           g_v1,
                           g_v2,
                           g_v3,
                           g_v4,
                           g_v5);
        ELSE
            BEGIN
                --Проверка версии
                BEGIN
                    l_par := 'IKIS_PFU_VERSION';

                    EXECUTE IMMEDIATE   'begin '
                                     || 'select aptprm_value '
                                     || 'into :1 '
                                     || 'from '
                                     || l_pref
                                     || '_sys.appt_params '
                                     || 'where aptprm_name=:par; end;'
                        USING OUT l_param_ver, IN l_par;

                    l_par := l_pref;

                    EXECUTE IMMEDIATE   'begin '
                                     || 'select count(*) '
                                     || 'into  :1 '
                                     || 'from '
                                     || l_pref
                                     || '_sys.appt_systems '
                                     || 'where s_code like :par||''%'' '
                                     || '  and not (substr(s_version,1,instr(s_version,''.'',-1)-1)=:ver); end;'
                        USING OUT l_systems_ver_cnt, IN l_par, IN l_ver;

                    EXECUTE IMMEDIATE   'begin '
                                     || 'select count(*) '
                                     || 'into :1 '
                                     || 'from '
                                     || l_pref
                                     || '_sys.appt_subsyss '
                                     || 'where ss_s like :par||''%'' '
                                     || '  and ss_version is not null '
                                     || '  and not (substr(ss_version,1,instr(ss_version,''.'',-1)-1)=:ver); end;'
                        USING OUT l_subsyss_ver_cnt, IN l_par, IN l_ver;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        raise_application_error (
                            -20000,
                               'Помилка першого етапу перевірки можливості видалення БД ІКІС.'
                            || CHR (10)
                            || SQLERRM);
                END;

                IF NOT (    SUBSTR (l_param_ver,
                                    1,
                                    INSTR (l_param_ver, '.', -1) - 1) =
                            l_ver
                        AND l_systems_ver_cnt = 0
                        AND l_subsyss_ver_cnt = 0)
                THEN
                    raise_application_error (
                        -20000,
                        'Неможливо виконати очищення БД ІКІС.');
                END IF;

                --Проверка уровня установки ПО (в центре удалять нельзя)
                BEGIN
                    EXECUTE IMMEDIATE   'begin if '
                                     || l_pref
                                     || '_sys.ikis_common.getap_ikis_applevel='
                                     || l_pref
                                     || '_sys.ikis_common.alcenter then :a:=1; else :a:=0; end if; end;'
                        USING OUT l_level;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        raise_application_error (
                            -20000,
                               'Помилка другого етапу перевірки можливості видалення БД ІКІС.'
                            || CHR (10)
                            || SQLERRM);
                END;

                IF l_level = 1
                THEN
                    raise_application_error (
                        -20000,
                        'Неможливо виконати очищення БД ІКІС в центрі.');
                END IF;

                --Проверка статуса загрузки в районе
                BEGIN
                    l_par1 := 'LOAD_STATUS_RAJON';
                    l_par2 := 'IKIS_ERS';

                    EXECUTE IMMEDIATE   'begin '
                                     || l_pref
                                     || '_sys.ikis_parameter_util.getparameter(:par1,:par2,:par3); end;'
                        USING IN l_par1, IN l_par2, OUT l_par3;

                    EXECUTE IMMEDIATE   'begin if '
                                     || l_pref
                                     || '_ers.ikis_const.v_ddi_load_st_rajon_99=:par then :a:=1; else :a:=0; end if; end;'
                        USING IN l_par3, OUT l_level;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        raise_application_error (
                            -20000,
                               'Помилка третього етапу перевірки можливості видалення БД ІКІС.'
                            || CHR (10)
                            || SQLERRM);
                END;

                IF l_level = 1
                THEN
                    --Проверка флага КАН_ДДЛ
                    EXECUTE IMMEDIATE   'begin '
                                     || l_pref
                                     || '_sys.ikis_ddl.checkddl; end;';
                --raise_application_error(-20000, 'Неможливо виконати очищення БД ІКІС - існують промислові дані.');
                END IF;
            END;
        END IF;

        Clear_IkisDB (g_pref);

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetMessageLog (
                'Помилка при очищенні ІКІС: ' || CHR (10) || SQLERRM);
            RETURN 1;
    END;

    FUNCTION PrepareRMCert (p_pref VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        Banner ('Процедура підготовки до очищення сертифікатів ІКІС.');

        BEGIN
            EXECUTE IMMEDIATE   'grant all on directory '
                             || p_pref
                             || 'CTLDIR to system';

            SetMessageLog ('Перший етап виконано.');
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog ('Перший етап завершенo з помилкою');
        END;

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 1;
    END;

    FUNCTION RMCert (p_pref VARCHAR2)
        RETURN NUMBER
    IS
        fCertDir     VARCHAR2 (10) := UPPER (p_pref) || 'CTLDIR';
        fCertFileI   VARCHAR2 (14) := UPPER (p_pref) || 'certi.ctc';
        fCertFileO   VARCHAR2 (14) := UPPER (p_pref) || 'certo.ctc';
        l_file       UTL_FILE.file_type;
    BEGIN
        Banner ('Процедура очищення сертифікатів ІКІС.');
        SetMessageLog ('Підготовка до очищення сертифікатів ІКІС...');

        BEGIN
            EXECUTE IMMEDIATE 'delete from ' || p_pref || '_sys.ikis_cert';

            SetMessageLog ('Перший етап виконано.');
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog ('Перший етап завершенo з помилкою');
        END;

        BEGIN
            UTL_FILE.fremove (fCertDir, fCertFileI);
            SetMessageLog ('Другий етап виконано.');
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog ('Другий етап завершенo з помилкою');
        END;

        BEGIN
            UTL_FILE.fremove (fCertDir, fCertFileO);
            SetMessageLog ('Третій етап виконано.');
        EXCEPTION
            WHEN OTHERS
            THEN
                SetMessageLog ('Третій етап завершенo з помилкою');
        END;

        COMMIT;
        SetMessageLog ('Зміни збережено.');
        SetMessageLog ('Очищення сертифікатів завершено.');
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            SetMessageLog (
                   'Помилка при очищенні сертифікатів ІКІС: '
                || CHR (10)
                || SQLERRM);
            RETURN 1;
    END;

    FUNCTION DB_INFO
        RETURN NUMBER
    IS
        usr    TRefCursor;
        l_f1   VARCHAR2 (1000);
        l_f2   VARCHAR2 (1000);
        l_f3   VARCHAR2 (1000);
        l_f4   VARCHAR2 (1000);
        l_f5   VARCHAR2 (1000);
    BEGIN
        Banner ('Процедура збору інформації про БД ІКІС');
        SetMessageLog (RPAD ('*', 50, '*'));
        SetMessageLog (
               '* '
            || RPAD ('USER NAME', 23, ' ')
            || '| '
            || RPAD ('ACCOUNT STATUS', 22, ' ')
            || '*');
        SetMessageLog ('*' || RPAD ('-', 48, '-') || '*');

        OPEN usr FOR
            'select username,account_status from dba_users order by username';

        LOOP
            FETCH usr INTO l_f1, l_f2;

            EXIT WHEN usr%NOTFOUND;
            SetMessageLog (
                   '* '
                || RPAD (l_f1, 23, ' ')
                || '| '
                || RPAD (l_f2, 22, ' ')
                || '*');
            NULL;
        END LOOP;

        CLOSE usr;

        SetMessageLog (RPAD ('*', 50, '*'));

        SetMessageLog ('');
        SetMessageLog (RPAD ('*', 50, '*'));
        SetMessageLog ('* ' || RPAD ('ROLE NAME', 47, ' ') || '*');
        SetMessageLog ('*' || RPAD ('-', 48, '-') || '*');

        OPEN usr FOR 'select x.role from dba_roles x order by x.role';

        LOOP
            FETCH usr INTO l_f1;

            EXIT WHEN usr%NOTFOUND;
            SetMessageLog ('* ' || RPAD (l_f1, 47, ' ') || '*');
            NULL;
        END LOOP;

        CLOSE usr;

        SetMessageLog (RPAD ('*', 50, '*'));

        l_f1 := NULL;
        l_f4 := NULL;
        SetMessageLog ('');
        SetMessageLog (RPAD ('*', 80, '*'));
        SetMessageLog ('* ' || RPAD ('OBJECTS', 77, ' ') || '*');

        OPEN usr FOR
               'select x.owner,x.object_type,x.status, count(x.object_id) from dba_objects x '
            || 'where x.owner like ''IKIS%'' group by x.owner,x.object_type,x.status';

        LOOP
            FETCH usr
                INTO l_f1,
                     l_f2,
                     l_f3,
                     l_f5;

            EXIT WHEN usr%NOTFOUND;

            IF NOT (NVL (l_f1, '*') = NVL (l_f4, '*'))
            THEN
                SetMessageLog ('*' || RPAD ('-', 78, '-') || '*');
            END IF;

            l_f4 := l_f1;
            SetMessageLog (
                   '* '
                || RPAD (l_f1, 30, ' ')
                || '|'
                || RPAD (l_f2, 20, ' ')
                || '|'
                || RPAD (l_f3, 16, ' ')
                || '|'
                || RPAD (l_f5, 8, ' ')
                || '*');
        END LOOP;

        CLOSE usr;

        SetMessageLog (RPAD ('*', 80, '*'));

        RETURN 0;
    END;

    FUNCTION RestartLoadFULLERS (p_pref VARCHAR2)
        RETURN NUMBER
    IS
        l_data   VARCHAR2 (20);
    BEGIN
        Banner ('Відновлення можливості завантаження ЄРС-Україна');
        SetMessageLog ('Перевірка стана завантаження...');

        EXECUTE IMMEDIATE   'begin '
                         || p_pref
                         || '_sys.ikis_parameter_util.getparameter(:parname,''IKIS_ERS'',:l_data); end;'
            USING IN 'LOAD_STATUS_RAJON', OUT l_data;

        SetMessageLog ('Перевірку проведено.');

        IF l_data = '51'
        THEN
            l_data := '0';
            SetMessageLog (
                'Встановлення можливості завантаження ЄРС-Україна.');

            EXECUTE IMMEDIATE   'begin '
                             || p_pref
                             || '_sys.ikis_parameter_util.editparameter(:parname,''IKIS_ERS'',:l_data); end;'
                USING IN 'LOAD_STATUS_RAJON', IN l_data;

            SetMessageLog ('Встановлено.');
        ELSE
            SetMessageLog (
                   'Стан завантаження невідповідає допустимому ('
                || l_data
                || ').');
        END IF;

        RETURN 0;
    END;
END IKIS_IMPEXP;
/