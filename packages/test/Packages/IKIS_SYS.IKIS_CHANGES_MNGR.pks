/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_CHANGES_MNGR
IS
    -- Author  : RYABA
    -- Created : 24.10.2004 11:03:10
    -- Purpose : Робота по веденню аудиту

    PROCEDURE GenerateSchemaAudit (
        p_subsys   IN     ikis_subsys.ss_code%TYPE,
        p_data        OUT CLOB);

    PROCEDURE RefreshSchema (p_subsys IN ikis_subsys.ss_code%TYPE);
END IKIS_CHANGES_MNGR;
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_CHANGES_MNGR
IS
    tmplVALUE_FIELD          NUMBER := 4;
    tmplPACKAGE              NUMBER := 3;
    tmplUPDATE_TYPE          NUMBER := 5;
    tmplTRIGGER_BODY         NUMBER := 1;
    tmplUPDATE_VALUE_FIELD   NUMBER := 21;

    PROCEDURE GenerateSchemaAudit (
        p_subsys   IN     ikis_subsys.ss_code%TYPE,
        p_data        OUT CLOB)
    IS
        l_param_list          CLOB;
        l_update_param_list   CLOB;
        l_tmpl_value          CLOB;
        l_tmpl_update_value   CLOB;
        l_tmpl_pkg            CLOB;
        l_tmpl_trig           CLOB;
        l_tmpl_update_type    CLOB;
        l_value               CLOB;
        l_update_value        CLOB;
        l_cur_pkg             CLOB;
        l_old_params          CLOB;
        l_new_params          CLOB;
        l_old_new_params      CLOB;
        l_key_field           VARCHAR2 (30);
        l_update_key_field    VARCHAR2 (30);
        l_hist_exists         BOOLEAN;
        l_ins_trig            CLOB;
        l_upd_trig            CLOB;
        l_del_trig            CLOB;
        l_table               CLOB;
        l_action              VARCHAR2 (100);
        l_counter             NUMBER := 1;
        l_counter_start       NUMBER;
    BEGIN
        SELECT ict_templ
          INTO l_tmpl_value
          FROM ikis_changes_templ
         WHERE ict_id = tmplVALUE_FIELD;

        SELECT ict_templ
          INTO l_tmpl_update_value
          FROM ikis_changes_templ
         WHERE ict_id = tmplUPDATE_VALUE_FIELD;


        SELECT ict_templ
          INTO l_tmpl_pkg
          FROM ikis_changes_templ
         WHERE ict_id = tmplPACKAGE;

        SELECT ict_templ
          INTO l_tmpl_update_type
          FROM ikis_changes_templ
         WHERE ict_id = tmplUPDATE_TYPE;

        SELECT ict_templ
          INTO l_tmpl_trig
          FROM ikis_changes_templ
         WHERE ict_id = tmplTRIGGER_BODY;

        EXECUTE IMMEDIATE 'truncate table ikis_changes_part';

        FOR vTables IN (  SELECT *
                            FROM ikis_changes_tables
                           WHERE ict_ss_code = p_subsys
                        ORDER BY ict_table_name)
        LOOP
            l_table := NULL;
            l_param_list := NULL;
            l_update_param_list := NULL;
            l_value := NULL;
            l_update_value := NULL;
            l_cur_pkg := NULL;
            l_old_params := NULL;
            l_new_params := NULL;
            l_old_new_params := NULL;
            l_hist_exists := FALSE;
            l_ins_trig := NULL;
            l_upd_trig := NULL;
            l_del_trig := NULL;
            l_key_field := 'Не указан первичнний ключ!';
            l_update_key_field := 'Не указан первичнний ключ!';

            FOR vColumns
                IN (SELECT *
                      FROM ikis_changes_tab_col
                     WHERE     ictc_ss_code = p_subsys
                           AND ictc_table_name = vTables.ict_table_name)
            LOOP
                IF    vColumns.ictc_changes_st = 'Y'
                   OR vColumns.ictc_column_name = 'HISTORY_STATUS'
                   OR vColumns.ictc_primary_key_st = 'Y'
                THEN
                    IF vColumns.ictc_column_name = 'HISTORY_STATUS'
                    THEN
                        l_hist_exists := TRUE;
                    END IF;

                    --Формую список параметрів для процедур
                    IF l_param_list IS NULL
                    THEN
                        l_param_list :=
                               'p_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_update_param_list :=
                               'p_old_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_update_param_list :=
                               l_update_param_list
                            || ','
                            || CHR (10)
                            || 'p_new_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_value :=
                            REPLACE (
                                REPLACE (l_tmpl_value,
                                         '%<FIELD_NAME>%',
                                         vColumns.ictc_column_name),
                                '%<PARAM_NAME>%',
                                'p_' || vColumns.ictc_column_name);
                        l_update_value :=
                            REPLACE (
                                REPLACE (
                                    REPLACE (l_tmpl_update_value,
                                             '%<FIELD_NAME>%',
                                             vColumns.ictc_column_name),
                                    '%<PARAM_OLD_VALUE>%',
                                    'p_old_' || vColumns.ictc_column_name),
                                '%<PARAM_NEW_VALUE>%',
                                'p_new_' || vColumns.ictc_column_name);
                        l_new_params := ':new.' || vColumns.ictc_column_name;
                        l_old_params := ':old.' || vColumns.ictc_column_name;
                        l_old_new_params :=
                            ':old.' || vColumns.ictc_column_name;
                        l_old_new_params :=
                               l_old_new_params
                            || ','
                            || CHR (10)
                            || ':new.'
                            || vColumns.ictc_column_name;
                    ELSE
                        l_param_list :=
                               l_param_list
                            || ','
                            || CHR (10)
                            || 'p_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_update_param_list :=
                               l_update_param_list
                            || ','
                            || CHR (10)
                            || 'p_old_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_update_param_list :=
                               l_update_param_list
                            || ','
                            || CHR (10)
                            || 'p_new_'
                            || vColumns.ictc_column_name
                            || ' in '
                            || vTables.ict_table_name
                            || '.'
                            || vColumns.ictc_column_name
                            || '%type';
                        l_value :=
                               l_value
                            || '||'
                            || CHR (10)
                            || REPLACE (
                                   REPLACE (l_tmpl_value,
                                            '%<FIELD_NAME>%',
                                            vColumns.ictc_column_name),
                                   '%<PARAM_NAME>%',
                                   'p_' || vColumns.ictc_column_name);
                        l_update_value :=
                               l_update_value
                            || '||'
                            || CHR (10)
                            || REPLACE (
                                   REPLACE (
                                       REPLACE (l_tmpl_update_value,
                                                '%<FIELD_NAME>%',
                                                vColumns.ictc_column_name),
                                       '%<PARAM_OLD_VALUE>%',
                                       'p_old_' || vColumns.ictc_column_name),
                                   '%<PARAM_NEW_VALUE>%',
                                   'p_new_' || vColumns.ictc_column_name);
                        l_new_params :=
                               l_new_params
                            || ','
                            || CHR (10)
                            || ':new.'
                            || vColumns.ictc_column_name;
                        l_old_params :=
                               l_old_params
                            || ','
                            || CHR (10)
                            || ':old.'
                            || vColumns.ictc_column_name;
                        l_old_new_params :=
                               l_old_new_params
                            || ','
                            || CHR (10)
                            || ':old.'
                            || vColumns.ictc_column_name;
                        l_old_new_params :=
                               l_old_new_params
                            || ','
                            || CHR (10)
                            || ':new.'
                            || vColumns.ictc_column_name;
                    END IF;
                END IF;

                IF vColumns.ictc_primary_key_st = 'Y'
                THEN
                    l_key_field := 'p_' || vColumns.ictc_column_name;
                    l_update_key_field :=
                        'p_new_' || vColumns.ictc_column_name;
                END IF;
            END LOOP;

            l_cur_pkg := REPLACE (l_tmpl_pkg, '%<PARAM_LIST>%', l_param_list);
            l_counter_start := l_counter;
            l_table := l_cur_pkg;

            WHILE TRIM (l_table) IS NOT NULL
            LOOP
                IF INSTR (UPPER (l_table), 'PROCEDURE') > 0
                THEN
                    l_ins_trig :=
                        SUBSTR (
                            l_table,
                            1,
                              INSTR (UPPER (l_table), 'PROCEDURE')
                            + LENGTH ('PROCEDURE'));
                    l_table :=
                        SUBSTR (l_table,
                                LENGTH (l_ins_trig),
                                LENGTH (l_table));
                ELSE
                    l_ins_trig := l_table;
                    l_table := '';
                END IF;

                INSERT INTO ikis_changes_part (icp_id, icp_code)
                     VALUES (l_counter, l_ins_trig);

                l_counter := l_counter + 1;
            END LOOP;

            FOR vI
                IN (  SELECT ikis_changes_part.*,
                             ikis_changes_part.ROWID     icp_rowid
                        FROM ikis_changes_part
                       WHERE icp_id >= l_counter_start
                    ORDER BY icp_id)
            LOOP
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<UPDATE_PARAM_LIST>%',
                             l_update_param_list);
                vI.icp_code :=
                    REPLACE (vI.icp_code, '%<VALUE_LIST>%', l_value);
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<ESS_CODE>%',
                             vTables.ict_ess_code);
                vI.icp_code :=
                    REPLACE (vI.icp_code, '%<KEY_FIELD>%', l_key_field);
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<UPDATE_KEY_FIELD>%',
                             l_update_key_field);
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<UPDATE_VALUE_LIST>%',
                             l_update_value);
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<OPER_INSERT_TYPE>%',
                             IKIS_NSI_CONST.IKIS_AUD_OPER_1);
                vI.icp_code :=
                    REPLACE (vI.icp_code,
                             '%<TABLE_NAME>%',
                             vTables.ict_table_name);
                vI.icp_code := REPLACE (vI.icp_code, '%<SUBSYS>%', p_subsys);

                IF l_hist_exists
                THEN
                    vI.icp_code :=
                        REPLACE (vI.icp_code,
                                 '%<OPER_UPDATE_TYPE>%',
                                 l_tmpl_update_type);
                ELSE
                    vI.icp_code :=
                        REPLACE (vI.icp_code,
                                 '%<OPER_UPDATE_TYPE>%',
                                 IKIS_NSI_CONST.IKIS_AUD_OPER_2);
                END IF;

                l_table := l_table || vI.icp_code;

                UPDATE ikis_changes_part
                   SET icp_code = vI.icp_code
                 WHERE ikis_changes_part.ROWID = vI.icp_rowid;
            END LOOP;

            l_ins_trig :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_tmpl_trig, '%<FIELD_LIST>%', l_new_params),
                        '%<OPERATION>%',
                        'INSERT'),
                    '%<OPER>%',
                    'INS');
            l_upd_trig :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_tmpl_trig,
                                 '%<FIELD_LIST>%',
                                 l_old_new_params),
                        '%<OPERATION>%',
                        'UPDATE'),
                    '%<OPER>%',
                    'UPD');
            l_del_trig :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_tmpl_trig, '%<FIELD_LIST>%', l_old_params),
                        '%<OPERATION>%',
                        'DELETE'),
                    '%<OPER>%',
                    'DEL');

            FOR vTriggers
                IN (SELECT *
                      FROM ikis_changes_trig_opt
                     WHERE     icto_ss_code = p_subsys
                           AND icto_table_name = vTables.ict_table_name)
            LOOP
                SELECT dic_name
                  INTO l_action
                  FROM v_dds_trig_time
                 WHERE dic_value = vTriggers.icto_action_time;

                IF vTriggers.icto_trig_type = 'I'
                THEN
                    l_ins_trig :=
                        REPLACE (l_ins_trig, '%<ACTION_TIME>%', l_action);
                ELSIF vTriggers.icto_trig_type = 'U'
                THEN
                    l_upd_trig :=
                        REPLACE (l_upd_trig, '%<ACTION_TIME>%', l_action);
                ELSIF vTriggers.icto_trig_type = 'D'
                THEN
                    l_del_trig :=
                        REPLACE (l_del_trig, '%<ACTION_TIME>%', l_action);
                END IF;
            END LOOP;

            l_ins_trig :=
                REPLACE (l_ins_trig,
                         '%<TABLE_NAME>%',
                         vTables.ict_table_name);
            l_ins_trig := REPLACE (l_ins_trig, '%<SUBSYS>%', p_subsys);
            l_upd_trig :=
                REPLACE (l_upd_trig,
                         '%<TABLE_NAME>%',
                         vTables.ict_table_name);
            l_upd_trig := REPLACE (l_upd_trig, '%<SUBSYS>%', p_subsys);
            l_del_trig :=
                REPLACE (l_del_trig,
                         '%<TABLE_NAME>%',
                         vTables.ict_table_name);
            l_del_trig := REPLACE (l_del_trig, '%<SUBSYS>%', p_subsys);

            l_table :=
                   l_table
                || CHR (10)
                || CHR (10)
                || l_ins_trig
                || CHR (10)
                || CHR (10)
                || l_upd_trig
                || CHR (10)
                || CHR (10)
                || l_del_trig;

            p_data := p_data || CHR (10) || CHR (10) || l_table;
        END LOOP;

        COMMIT;
    END;

    PROCEDURE RefreshSchema (p_subsys IN ikis_subsys.ss_code%TYPE)
    IS
    BEGIN
        --синхронізація таблиць
        DELETE FROM ikis_changes_tab_col
              WHERE     ictc_ss_code = p_subsys
                    AND NOT ictc_table_name IN (SELECT table_name
                                                  FROM all_tables
                                                 WHERE owner = p_subsys);

        DELETE FROM ikis_changes_tables
              WHERE     ict_ss_code = p_subsys
                    AND NOT ict_table_name IN (SELECT table_name
                                                 FROM all_tables
                                                WHERE owner = p_subsys);

        --синхронизація колонок
        --Вилучаю зайві колонки
        DELETE FROM ikis_changes_tab_col
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM all_tab_columns
                          WHERE     owner = p_subsys
                                AND table_name = ictc_table_name
                                AND column_name = ictc_column_name);

        --Додаю нові
        INSERT INTO ikis_changes_tab_col (ictc_ss_code,
                                          ictc_table_name,
                                          ictc_column_name,
                                          ictc_changes_st,
                                          ictc_primary_key_st)
            SELECT owner,
                   table_name,
                   column_name,
                   'N',
                   'N'
              FROM all_tab_columns
             WHERE     owner = p_subsys
                   AND NOT EXISTS
                           (SELECT 1
                              FROM ikis_changes_tab_col
                             WHERE     ictc_table_name = table_name
                                   AND ictc_column_name = column_name)
                   AND table_name IN (SELECT ict_table_name
                                        FROM ikis_changes_tables
                                       WHERE ict_ss_code = p_subsys)
                   AND NOT column_name IN ('REPL_TS', 'ITF_CNTR');

        COMMIT;
    END;
END IKIS_CHANGES_MNGR;
/