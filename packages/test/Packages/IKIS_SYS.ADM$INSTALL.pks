/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ADM$INSTALL
IS
    -- Author  : YURA_A
    -- Created : 22.06.2007 13:56:40
    -- Purpose : Install purposes

    -- Дропает таблицы буффера репликатора, заменяет их синонимами на соотв. глобал тепм таблицы
    PROCEDURE ReplaceReplBuffer2Synonym (p_repl_user          VARCHAR2,
                                         p_repl_alias         VARCHAR2,
                                         p_repl_script_name   VARCHAR2,
                                         p_target_schema      VARCHAR2);

    --для спова все делает
    PROCEDURE CreateDefaultSyn4SPOV;
END ADM$INSTALL;
/


/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ADM$INSTALL
IS
    --'unload_spov_pzv_to_center'

    /*************************************
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS]

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS\001]

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS\002]

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS\003]

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS\004]

    [HKEY_CURRENT_USER\Software\Atlas\rsreplicator\NUIDS\005]

    *************************************/

    PROCEDURE SM (p_message VARCHAR2)
    IS
    BEGIN
        DBMS_OUTPUT.put_line (
            TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || ': ' || p_message);
    END;

    PROCEDURE ReplaceReplBuffer2Synonym (p_repl_user          VARCHAR2,
                                         p_repl_alias         VARCHAR2,
                                         p_repl_script_name   VARCHAR2,
                                         p_target_schema      VARCHAR2)
    IS
    BEGIN
        IF ikis_common.GetAP_IKIS_APPLEVEL = ikis_common.alCenter
        THEN
            FOR i
                IN (SELECT un_tb_name
                      FROM ikis_sys.un_tables
                     WHERE un_tb_id IN
                               (SELECT un_lt_tb_id
                                  FROM ikis_sys.un_link_tables
                                 WHERE un_lt_sc_id IN
                                           (SELECT un_sc_id
                                              FROM ikis_sys.un_scenaries
                                             WHERE un_sc_name =
                                                   p_repl_script_name)))
            LOOP
                sm (
                       'Start processing table: '
                    || i.un_tb_name
                    || ' with alias '
                    || p_repl_alias);

                BEGIN
                    EXECUTE IMMEDIATE   'drop table '
                                     || p_repl_user
                                     || '.univ_'
                                     || p_repl_alias
                                     || '_'
                                     || i.un_tb_name;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        sm (SQLERRM);
                END;

                BEGIN
                    EXECUTE IMMEDIATE   'create or replace synonym '
                                     || p_repl_user
                                     || '.univ_'
                                     || p_repl_alias
                                     || '_'
                                     || i.un_tb_name
                                     || ' for '
                                     || p_target_schema
                                     || '.'
                                     || i.un_tb_name;

                    EXECUTE IMMEDIATE   'grant insert, update, delete, select on '
                                     || p_target_schema
                                     || '.'
                                     || i.un_tb_name
                                     || ' to '
                                     || p_repl_user;

                    sm ('End processing table: ' || i.un_tb_name);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        sm (
                               '******ERROR! Of processing table: '
                            || i.un_tb_name);
                        sm ('******  ' || SQLERRM);
                END;
            END LOOP;
        ELSE
            raise_application_error (-20000,
                                     'Must run on center level only.');
        END IF;
    END;

    PROCEDURE CreateDefaultSyn4SPOV
    IS
    BEGIN
        adm$install.replacereplbuffer2synonym (
            p_repl_user          => 'IKIS_REPL',
            p_repl_alias         => '001',
            p_repl_script_name   => 'unload_spov_pzv_to_center',
            p_target_schema      => 'IKIS_SPOV');
        adm$install.replacereplbuffer2synonym (
            p_repl_user          => 'IKIS_REPL',
            p_repl_alias         => '002',
            p_repl_script_name   => 'unload_spov_pzv_to_center',
            p_target_schema      => 'IKIS_SPOV');
        adm$install.replacereplbuffer2synonym (
            p_repl_user          => 'IKIS_REPL',
            p_repl_alias         => '003',
            p_repl_script_name   => 'unload_spov_pzv_to_center',
            p_target_schema      => 'IKIS_SPOV');
        adm$install.replacereplbuffer2synonym (
            p_repl_user          => 'IKIS_REPL',
            p_repl_alias         => '004',
            p_repl_script_name   => 'unload_spov_pzv_to_center',
            p_target_schema      => 'IKIS_SPOV');
        adm$install.replacereplbuffer2synonym (
            p_repl_user          => 'IKIS_REPL',
            p_repl_alias         => '005',
            p_repl_script_name   => 'unload_spov_pzv_to_center',
            p_target_schema      => 'IKIS_SPOV');
    END;
END ADM$INSTALL;
/