/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_LOCKTABLE
    AUTHID CURRENT_USER
IS
    -- Author  : YURA_A
    -- Created : 05.08.2003 16:04:14
    -- Purpose : Блокування таблиць в схемах прикладних користувачів

    -- Author  : RYABA  -- Created : 12.07.2003 10:42:37 -- Purpose : Locking table
    PROCEDURE LockTable (p_table      IN     VARCHAR2,
                         p_field      IN     VARCHAR2,
                         p_rowid      IN     VARCHAR2,
                         p_IsLocked      OUT NUMBER);

    PROCEDURE AuditOperaion (p_table         IN VARCHAR2,
                             p_rowid         IN VARCHAR2,
                             p_operation     IN NUMBER,
                             p_id_field      IN VARCHAR2,
                             p_value         IN VARCHAR2,
                             p_rowid_field   IN VARCHAR2 := 'ROWID');

    PROCEDURE ReleaseLock;
END IKIS_LOCKTABLE;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_LOCKTABLE FOR IKIS_SYS.IKIS_LOCKTABLE
/


GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCKTABLE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_LOCKTABLE
IS
    c_EDIT_START               NUMBER := 10;
    c_EDIT_ROLL                NUMBER := 12;
    c_TASK_OUT                 NUMBER := 9;

    msgNO_DEFAULT_ID_FIELD     NUMBER := 3417;

    --+ Author: YURA_A 29.07.2003 11:57:17
    no_default_id_field        EXCEPTION;
    -- Отслеживается занятость ресурса в процедуре LockTable, если невозможно накласть блокировку, то об этом сигнализирует оут параметр p_IsLocked
    -- Если происходит любая другая ошибка, то сообщение возвращается через оут параметр p_result
    RESOURCE_BUSY_AND_NOWAIT   EXCEPTION;
    PRAGMA EXCEPTION_INIT (RESOURCE_BUSY_AND_NOWAIT, -54);

    --- Author: YURA_A 29.07.2003 11:57:19

    -- Author  : RYABA  -- Created : 12.07.2003 10:42:37 -- Purpose : Locking table
    -- Yura_AP: переделано на rowid, и на отлов прочих экзепшнов
    PROCEDURE LockTable (p_table      IN     VARCHAR2,
                         p_field      IN     VARCHAR2,
                         p_rowid      IN     VARCHAR2,
                         p_IsLocked      OUT NUMBER)
    IS
        l_Lock   VARCHAR2 (250)
            := 'select %<FIELD>% from %<TABLE>% where %<FIELD>%=:1 for update nowait';
    BEGIN
        debug.f ('Start procedure');
        l_Lock := REPLACE (l_Lock, '%<TABLE>%', p_table);
        l_Lock := REPLACE (l_Lock, '%<FIELD>%', p_field);

        EXECUTE IMMEDIATE l_Lock
            USING p_rowid;

        p_IsLocked := 0;
        debug.f ('Stop procedure (%s)', p_IsLocked);
    EXCEPTION
        WHEN RESOURCE_BUSY_AND_NOWAIT
        THEN
            p_IsLocked := -1;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'LockTable',
                    SQLERRM));
    END;


    PROCEDURE ReleaseLock
    IS
    BEGIN
        ROLLBACK;
    END;

    PROCEDURE AuditOperaion (p_table         IN VARCHAR2,      --Назва таблиці
                             p_rowid         IN VARCHAR2,
                             p_operation     IN NUMBER,
                             p_id_field      IN VARCHAR2,
                             p_value         IN VARCHAR2,
                             p_rowid_field   IN VARCHAR2 := 'ROWID')
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_ess_id       NUMBER := 0;
        v_field_name   VARCHAR2 (30);
        v_get_id       VARCHAR2 (200)
            := 'SELECT %<FIELD>% FROM %<TABLE>% WHERE %<TABLE>%.%<ROWIDFIELD>%=:P_ROWID';
    BEGIN
        debug.f ('Start AuditOperaion');
        debug.f ('p_table = ' || p_table);
        debug.f ('p_rowid = ' || p_rowid);
        debug.f ('p_operation = ' || p_operation);
        debug.f ('p_id_field = ' || p_id_field);
        debug.f ('p_value = ' || p_value);
        debug.f ('p_rowid_field  = ' || p_rowid_field);

        IF NOT p_rowid = '0'
        THEN
            IF TRIM (p_id_field) IS NULL
            THEN
                BEGIN
                    debug.f ('Selectin id column');

                    SELECT column_name
                      INTO v_field_name
                      FROM all_tab_columns, ikis_subsys
                     WHERE     owner = ss_owner
                           AND table_name = UPPER (p_table)
                           AND column_name LIKE '%\_ID%' ESCAPE '\';
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        RAISE no_default_id_field;
                END;
            ELSE
                v_field_name := p_id_field;
            END IF;

            v_get_id :=
                REPLACE (
                    REPLACE (REPLACE (v_get_id, '%<FIELD>%', v_field_name),
                             '%<TABLE>%',
                             p_table),
                    '%<ROWIDFIELD>%',
                    p_rowid_field);

            BEGIN
                EXECUTE IMMEDIATE v_get_id
                    INTO v_ess_id
                    USING IN p_rowid;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    IF NOT p_operation IN
                               (c_EDIT_START, c_EDIT_ROLL, c_TASK_OUT)
                    THEN
                        RAISE;
                    ELSE
                        v_ess_id := 0;
                    END IF;
            END;
        END IF;

        debug.f ('Log change');
        ikis_changes_utl.ChangeEssCode (p_table,
                                        v_ess_id,
                                        p_operation,
                                        p_value);
        debug.f ('Stop AuditOperaion');
        COMMIT;
    EXCEPTION
        WHEN no_default_id_field
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNO_DEFAULT_ID_FIELD,
                                               p_table));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_LOCKTABLE.AuditOperaion',
                    SQLERRM));
    END;
END IKIS_LOCKTABLE;
/