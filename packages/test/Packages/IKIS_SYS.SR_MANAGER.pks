/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.sr_MANAGER
IS
    -- Author  : RYABA
    -- Created : 16.06.2003 16:10:00
    -- Purpose : Робота з кліентом та створення пакаджів контролю

    PROCEDURE GenerateGroup (p_group IN NUMBER, p_res OUT CLOB);

    PROCEDURE CreateMsgParamResult (p_msg IN NUMBER, p_res OUT CLOB);

    PROCEDURE InsertCntrMsg (
        p_msg_cntr       IN     sr_controls.cntr_id%TYPE,
        p_msg_type       IN     ikis_messages.ipm_tp%TYPE,
        p_msg            IN     ikis_messages.ipm_message%TYPE,
        p_msg_number     IN     sr_control_msg.msg_number%TYPE,
        p_msg_res_type   IN     sr_control_msg.msg_res_type%TYPE,
        p_msg_order      IN     sr_control_msg.msg_order%TYPE,
        p_ipm_id            OUT ikis_messages.ipm_id%TYPE);

    PROCEDURE InsertGrpMsg (
        p_msg_grp     IN     sr_groups.grp_id%TYPE,
        p_msg_type    IN     ikis_messages.ipm_tp%TYPE,
        p_gm          IN     ikis_messages.ipm_message%TYPE,
        p_gm_type     IN     sr_groups_msg.gm_msg_type%TYPE,
        p_gm_number   IN     sr_groups_msg.gm_number%TYPE,
        p_gm_order    IN     sr_groups_msg.gm_order%TYPE,
        p_ipm_id         OUT ikis_messages.ipm_id%TYPE);

    PROCEDURE DeleteCntrMsg (p_ipm_id IN ikis_messages.ipm_id%TYPE);

    PROCEDURE DeleteGrpMsg (p_ipm_id IN ikis_messages.ipm_id%TYPE);
END sr_MANAGER;
/


CREATE OR REPLACE PUBLIC SYNONYM SR_MANAGER FOR IKIS_SYS.SR_MANAGER
/


GRANT EXECUTE ON IKIS_SYS.SR_MANAGER TO II01RC_SR_CONTROL_DESIGN
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.sr_MANAGER
IS
    -- Шаблоны
    tmplPKG_BEGIN                  INTEGER := 1;
    tmplPKG_END                    INTEGER := 2;
    tmplPKG_IFCONTROL              INTEGER := 3;
    tmplPKG_UPDATECONTROL          INTEGER := 4;
    tmplPKG_FILLMATRIX             INTEGER := 5;
    tmplPKG_CONTROLCOND            INTEGER := 6;
    tmplPKG_PRECONDITION           INTEGER := 7;
    tmplPKG_EXCEPTIONCONTROL       INTEGER := 8;
    tmplPKG_IFEXCEPTIONCONTROL     INTEGER := 9;
    tmplPKG_FINALSECTION           INTEGER := 10;
    tmplPKG_COUNTERRFLAG           INTEGER := 42;
    tmplPKG_FINALCODE              INTEGER := 43;
    tmplPKG_UPDATEEXCEPTION        INTEGER := 45;
    tmplPKG_PARAM_CASE             INTEGER := 48;
    tmplPKG_MESSAGE_CASE           INTEGER := 47;
    tmplPKG_PARAM_RESULT           INTEGER := 46;
    tmplPKG_MESSAGE                INTEGER := 66;
    tmplPKG_PARAM                  INTEGER := 67;
    tmplPKG_FINAL_B                INTEGER := 88;
    tmplPKG_FINAL_G                INTEGER := 89;
    tmplPKG_STOP_ESSENCE           INTEGER := 106;
    tmplPKG_USEREXCEPTIONCONTROL   INTEGER := 107;
    tmplPKG_STOPDEPENDCNTRWHERE    INTEGER := 126;
    tmplPKG_STOPCONTROLCONDITION   INTEGER := 127;
    tmplPKG_STOPINSQLWHERE         INTEGER := 146;
    tmplPKG_STOPOUTSQLWHERE        INTEGER := 147;
    tmplPKG_STOPMASTERCNTRWHERE    INTEGER := 148;
    tmplPKG_SETID_ROWS             INTEGER := 148;

    PROCEDURE who_called_me (o_owner    OUT VARCHAR2,
                             o_object   OUT VARCHAR2,
                             o_lineno   OUT NUMBER)
    IS
        --
        l_call_stack   LONG DEFAULT DBMS_UTILITY.format_call_stack;
        l_line         VARCHAR2 (4000);
    BEGIN
        FOR i IN 1 .. 5
        LOOP
            l_call_stack :=
                SUBSTR (l_call_stack, INSTR (l_call_stack, CHR (10)) + 1);
        END LOOP;

        l_line :=
            LTRIM (
                SUBSTR (l_call_stack, 1, INSTR (l_call_stack, CHR (10)) - 1));

        l_line := LTRIM (SUBSTR (l_line, INSTR (l_line, ' ')));

        o_lineno := TO_NUMBER (SUBSTR (l_line, 1, INSTR (l_line, ' ')));
        l_line := LTRIM (SUBSTR (l_line, INSTR (l_line, ' ')));

        l_line := LTRIM (SUBSTR (l_line, INSTR (l_line, ' ')));

        IF l_line LIKE 'block%' OR l_line LIKE 'body%'
        THEN
            l_line := LTRIM (SUBSTR (l_line, INSTR (l_line, ' ')));
        END IF;

        o_owner :=
            LTRIM (RTRIM (SUBSTR (l_line, 1, INSTR (l_line, '.') - 1)));
        o_object := LTRIM (RTRIM (SUBSTR (l_line, INSTR (l_line, '.') + 1)));

        IF o_owner IS NULL
        THEN
            o_owner := USER;
            o_object := 'ANONYMOUS BLOCK';
        END IF;
    END who_called_me;

    PROCEDURE TmplReplace (p_source IN VARCHAR2, p_dest IN VARCHAR2)
    IS
    BEGIN
        FOR vRow
            IN (SELECT sr_pkg_text.*, sr_pkg_text.ROWID FROM sr_pkg_text)
        LOOP
            UPDATE sr_pkg_text
               SET spt_text = REPLACE (vRow.spt_text, p_source, p_dest)
             WHERE sr_pkg_text.ROWID = vRow.ROWID;
        END LOOP;
    END;

    FUNCTION ParseParam (p_param IN CLOB)
        RETURN CLOB
    IS
        l_res               CLOB;
        l_tmp               VARCHAR2 (500);
        l_dest              VARCHAR2 (100);
        l_char              CHAR (1);
        i                   INTEGER;
        l_not_allow_chars   VARCHAR2 (1000)
                                := '!#@|<>=:;?/\,. ()`~№%^&*"' || CHR (10);
    BEGIN
        l_res := p_param;

        LOOP
            EXIT WHEN INSTR (l_res, '%<CUR>%') = 0;
            l_tmp := TRIM (SUBSTR (l_res, INSTR (l_res, '%<CUR>%'), 400));
            l_dest := UPPER (SUBSTR (l_tmp, 9, 100));

            i := 1;

            LOOP
                l_char := SUBSTR (l_dest, i, 1);
                EXIT WHEN INSTR (l_not_allow_chars, l_char) > 0;
                i := i + 1;
            END LOOP;

            l_dest := TRIM (SUBSTR (l_dest, 1, i - 1));
            l_tmp := SUBSTR (l_tmp, 1, 9 + i - 2);

            l_dest := 'Fields(''VLOG.' || l_dest || ''')';
            l_dest := REPLACE (l_dest, CHR (10));
            l_res := REPLACE (l_res, l_tmp, l_dest);
        END LOOP;

        RETURN l_res;
    END;

    PROCEDURE CreateMsgParamResult (p_msg IN NUMBER, p_res OUT CLOB)
    IS
        l_param        CLOB;
        l_param_case   CLOB;
    BEGIN
        p_res := '';

        SELECT tm_templ
          INTO l_param_case
          FROM sr_template
         WHERE tm_id = tmplPKG_PARAM_CASE;

        FOR vParam
            IN (  SELECT *
                    FROM sr_msg_params
                   WHERE     gmp_ptype = 'Q'
                         AND gmp_ipm = p_msg
                         AND gmp_value IS NOT NULL
                         AND LENGTH (gmp_value) > 0
                ORDER BY gmp_num)
        LOOP
            SELECT tm_templ
              INTO l_param
              FROM sr_template
             WHERE tm_id = tmplPKG_PARAM;

            l_param := REPLACE (l_param, '%<PARAMNUM>%', vParam.gmp_num);
            l_param := REPLACE (l_param, '%<PARAMQUERY>%', vParam.gmp_value);
            l_param := ParseParam (l_param);
            p_res :=
                   p_res
                || CHR (10)
                || REPLACE (l_param, '%<PARAM_RESULT>%', 'l_res');
        END LOOP;

        IF LENGTH (p_res) > 0
        THEN
            p_res := REPLACE (l_param_case, '%<PARAM>%', p_res);
        END IF;
    END;

    PROCEDURE GenerateGroup (p_group IN NUMBER, p_res OUT CLOB)
    IS
        l_cur           CLOB;
        l_ErrorFlg      CHAR (1);
        l_WarningFlg    CHAR (1);
        l_depend_flag   CHAR (1);
        l_Cond          CLOB;
        l_Pre           CLOB;
        l_res           CLOB := NULL;
        l_updateres     CLOB;
        l_param_res     CLOB;
        l_param         CLOB;
        l_msg_res       CLOB;
        l_msg           CLOB;
        l_msg_qnt       INTEGER := 0;
        l_needfinal     INTEGER;
        l_ss_code       VARCHAR2 (30);
        l_owner         VARCHAR2 (30);
        l_counter       NUMBER := 1;
        l_parts         NUMBER;

        FUNCTION fillchar (p_qnt IN NUMBER, p_chr IN CHAR)
            RETURN VARCHAR2
        IS
            l_res   VARCHAR2 (2000);
            i       NUMBER;
        BEGIN
            l_res := '';

            FOR i IN 1 .. p_qnt
            LOOP
                l_res := l_res || p_chr;
            END LOOP;

            RETURN l_res;
        END;
    BEGIN
        DELETE FROM sr_pkg_text;

        COMMIT;

        --Вибираю головний шиблон для пакаджу
        SELECT tm_templ
          INTO p_res
          FROM sr_template, sr_groups
         WHERE     UPPER (sr_template.tm_name) =
                   UPPER (sr_groups.grp_tmpl_main)
               AND sr_groups.grp_id = p_group;

        --створення курсору вибору даних для контролю
        FOR l_CurGrp
            IN (SELECT sr_groups.*, ikis_subsys.ss_owner
                  FROM sr_groups, sr_essences, ikis_subsys
                 WHERE     grp_id = p_group
                       AND ss_code = es_ss_code
                       AND es_code = grp_es)
        LOOP
            l_cur := l_CurGrp.grp_fieldsSQL;
            l_cur :=
                REPLACE (l_CurGrp.grp_fieldsSQL,
                         '%<SETID_TABLE>%',
                         'sr_work_groups');
            l_cur := REPLACE (l_cur, '%<SETID_FIELD>%', 'wgs_rowid');
            l_cur :=
                REPLACE (l_cur,
                         '%<SETID_COND>%',
                         'wgs_group=%<GROUPNUMBER>%');
            p_res := REPLACE (p_res, '%<FIELDSSQL>%', l_cur);

            IF l_CurGrp.grp_fieldsSQL IS NULL
            THEN
                p_res := REPLACE (p_res, '%<ESSENCE>%', 'null');
            ELSE
                p_res :=
                    REPLACE (p_res,
                             '%<ESSENCE>%',
                             '''' || l_CurGrp.grp_es || '''');
            END IF;

            p_res := REPLACE (p_res, '%<OWNER>%', l_CurGrp.ss_owner);
        END LOOP;

        l_cur :=
            SUBSTR (p_res, 1, INSTR (p_res, '%<FUNCTION_PARAM_RESULT>%') - 1);

        INSERT INTO sr_pkg_text (spt_id, spt_text)
             VALUES (l_counter, l_cur);

        l_counter := l_counter + 1;

        --Створення функції формування значення параметрів
        SELECT tm_templ
          INTO l_param_res
          FROM sr_template
         WHERE tm_id = tmplPKG_PARAM_RESULT;

        l_cur :=
            SUBSTR (l_param_res, 1, INSTR (l_param_res, '%<MESSAGE>%') - 1);

        INSERT INTO sr_pkg_text (spt_id, spt_text)
             VALUES (l_counter, l_cur);

        l_counter := l_counter + 1;

        --створення коду функції визначення значення параметрів
        SELECT tm_templ
          INTO l_msg_res
          FROM sr_template
         WHERE tm_id = tmplPKG_MESSAGE_CASE;

        SELECT tm_templ
          INTO l_msg
          FROM sr_template
         WHERE tm_id = tmplPKG_MESSAGE;

        FOR vMsg
            IN (  SELECT DISTINCT msg_ipm
                    FROM sr_controls, sr_control_msg, sr_msg_params
                   WHERE     msg_cntr = cntr_id
                         AND cntr_grp = p_group
                         AND msg_ipm = gmp_ipm
                         AND gmp_ptype = 'Q'
                         AND gmp_value IS NOT NULL
                         AND LENGTH (gmp_value) > 0
                ORDER BY msg_ipm)
        LOOP
            IF l_msg_qnt = 0
            THEN
                l_cur :=
                    SUBSTR (l_msg_res,
                            1,
                            INSTR (l_msg_res, '%<MESSAGE>%') - 1);

                INSERT INTO sr_pkg_text (spt_id, spt_text)
                     VALUES (l_counter, l_cur);

                l_counter := l_counter + 1;
            END IF;

            l_msg_qnt := 1;

            l_cur := SUBSTR (l_msg, 1, INSTR (l_msg, '%<PARAM>%') - 1);
            l_cur := REPLACE (l_cur, '%<MESSAGENUM>%', vMsg.msg_ipm);

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, l_cur);

            l_counter := l_counter + 1;

            CreateMsgParamResult (vMsg.msg_ipm, l_param);

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, l_param);

            l_counter := l_counter + 1;

            l_cur :=
                SUBSTR (l_msg,
                        INSTR (l_msg, '%<PARAM>%') + LENGTH ('%<PARAM>%'));

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, l_cur);

            l_counter := l_counter + 1;
        END LOOP;

        IF l_msg_qnt = 1
        THEN
            l_cur :=
                SUBSTR (
                    l_msg_res,
                    INSTR (l_msg_res, '%<MESSAGE>%') + LENGTH ('%<MESSAGE>%'));

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, l_cur);

            l_counter := l_counter + 1;
        END IF;


        l_cur :=
            SUBSTR (
                l_param_res,
                INSTR (l_param_res, '%<MESSAGE>%') + LENGTH ('%<MESSAGE>%'));

        INSERT INTO sr_pkg_text (spt_id, spt_text)
             VALUES (l_counter, l_cur);

        l_counter := l_counter + 1;


        l_cur :=
            SUBSTR (
                p_res,
                  INSTR (p_res, '%<FUNCTION_PARAM_RESULT>%')
                + LENGTH ('%<FUNCTION_PARAM_RESULT>%'));

        INSERT INTO sr_pkg_text (spt_id, spt_text)
             VALUES (l_counter, l_cur);

        l_counter := l_counter + 1;
        l_cur := '';

        --Вибираю умови сортування для поточної суттєвості
        FOR vOrd
            IN (  SELECT *
                    FROM sr_groups_order
                   WHERE     grpo_grp = p_group
                         AND (grpo_value IS NOT NULL OR LENGTH (grpo_value) > 0)
                ORDER BY grpo_num)
        LOOP
            IF vOrd.grpo_type = 'Q'
            THEN
                l_cur :=
                       l_cur
                    || REPLACE (vOrd.grpo_value,
                                '%<PARAM_RESULT>%',
                                'gSortOrder(' || vOrd.grpo_num || ')');
            ELSIF vOrd.grpo_type = 'V'
            THEN
                l_cur :=
                       l_cur
                    || 'gSortOrder('
                    || vOrd.grpo_num
                    || '):='
                    || vOrd.grpo_value;
            ELSE
                l_cur :=
                       l_cur
                    || 'gSortOrder('
                    || vOrd.grpo_num
                    || '):='''
                    || vOrd.grpo_value
                    || '''';
            END IF;

            l_cur := l_cur || ';' || CHR (10);
        END LOOP;

        l_cur := REPLACE (l_cur, '%<CUR>%', 'vCur');

        TmplReplace ('%<MSGORDER>%', l_cur);
        p_res := '';
        l_cur := '';

        SELECT tm_templ
          INTO l_updateres
          FROM sr_template
         WHERE tm_id = tmplPKG_STOPDEPENDCNTRWHERE;

        SELECT tm_templ
          INTO l_cond
          FROM sr_template
         WHERE tm_id = tmplPKG_STOPCONTROLCONDITION;

        SELECT tm_templ
          INTO l_pre
          FROM sr_template
         WHERE tm_id = tmplPKG_STOPINSQLWHERE;

        SELECT tm_templ
          INTO l_msg_res
          FROM sr_template
         WHERE tm_id = tmplPKG_STOPOUTSQLWHERE;


        l_msg_qnt := 0;

        --Формую умови для визначення необхідності припинення контролю
        FOR vGrp IN (SELECT *
                       FROM sr_group_links
                      WHERE grpl_grp_depend = p_group)
        LOOP
            l_cur := vGrp.grpl_cntrsql;
            --выдрал напзвание поля
            l_param :=
                TRIM (SUBSTR (l_cur, 1, INSTR (l_cur, '%<SETID_DATA>%') - 1));
            l_param :=
                TRIM (
                    REPLACE (REPLACE (l_param, 'SELECT', ''), 'DISTINCT', ''));

            l_updateres :=
                REPLACE (
                    REPLACE (l_updateres,
                             '%<MASTERGROUPNUMBER>%',
                             vGrp.grpl_grp_master),
                    '%<ESSFIELDROWID>%',
                    l_param);
            l_cur :=
                REPLACE (
                    REPLACE (
                        REPLACE (REPLACE (l_cur, '%<SETID_DATA>%', ''),
                                 '%<SETID_TABLE>%',
                                 'sr_matrix,sr_controls'),
                        '%<SETID_FIELD>%',
                        'm_rowid'),
                    '%<SETID_COND>%',
                    l_updateres);
            p_res := REPLACE (l_cond, '%<STOPCONTROLCONDITION>%', l_cur);

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, p_res);

            l_counter := l_counter + 1;

            --формирую подзапрос
            l_cur := vGrp.grpl_cntrsql;
            l_cur :=
                REPLACE (
                    REPLACE (SUBSTR (l_cur, INSTR (l_cur, 'FROM')),
                             '%<SETID_TABLE>%',
                             'sr_matrix'),
                    '%<SETID_FIELD>%',
                    'm_rowid');
            l_cur :=
                REPLACE (
                    REPLACE (REPLACE (l_cur, '%<SETID_COND>%', l_pre),
                             '%<ESSFIELDROWID>%',
                             l_param),
                    '%<MAINGROUPNUMBER>%',
                    vGrp.grpl_grp_master);
            l_cur := 'SELECT sr_matrix.m_rowid' || CHR (10) || l_cur;
            p_res := l_cur;

            FOR vGrpIn
                IN (SELECT *
                      FROM sr_group_links
                     WHERE     grpl_grp_master = vGrp.grpl_grp_master
                           AND grpl_stop_flag = IKIS_CONST.V_DDS_YN_Y)
            LOOP
                l_cur := vGrpIn.grpl_cntrsql;

                --выдрал напзвание поля
                l_param :=
                    TRIM (
                        SUBSTR (l_cur,
                                1,
                                INSTR (l_cur, '%<SETID_DATA>%') - 1));
                l_param :=
                    TRIM (
                        REPLACE (REPLACE (l_param, 'SELECT', ''),
                                 'DISTINCT',
                                 ''));

                l_cur :=
                    REPLACE (
                        REPLACE (REPLACE (l_cur, '%<SETID_DATA>%', ''),
                                 '%<SETID_TABLE>%',
                                 'sr_matrix, sr_controls'),
                        '%<SETID_COND>%',
                        l_msg_res);
                l_cur :=
                    REPLACE (REPLACE (l_cur, '%<ESSFIELDROWID>%', l_param),
                             '%<INNERGROUPNUMBER>%',
                             vGrpIn.grpl_grp_depend);

                l_parts := 0;
                l_res := '=%<SETID_FIELD>%';

                WHILE INSTR (l_cur, l_res) = 0
                LOOP
                    l_parts := l_parts + 1;
                    l_res :=
                        '=' || fillchar (l_parts, ' ') || '%<SETID_FIELD>%';
                END LOOP;

                l_cur := REPLACE (l_cur, l_res, ' IN (' || p_res || ')');
                l_cur := REPLACE (l_cond, '%<STOPCONTROLCONDITION>%', l_cur);

                INSERT INTO sr_pkg_text (spt_id, spt_text)
                     VALUES (l_counter, l_cur);

                l_counter := l_counter + 1;
            END LOOP;
        END LOOP;

        SELECT tm_templ
          INTO l_updateres
          FROM sr_template
         WHERE tm_id = tmplPKG_STOPMASTERCNTRWHERE;

        FOR vGrp
            IN (SELECT *
                  FROM sr_group_links
                 WHERE     grpl_grp_master = p_group
                       AND grpl_stop_flag = IKIS_CONST.V_DDS_YN_Y)
        LOOP
            l_cur := vGrp.grpl_cntrsql;

            --выдрал напзвание поля
            l_param :=
                TRIM (SUBSTR (l_cur, 1, INSTR (l_cur, '%<SETID_DATA>%') - 1));
            l_param :=
                TRIM (
                    REPLACE (REPLACE (l_param, 'SELECT', ''), 'DISTINCT', ''));

            l_cur :=
                REPLACE (REPLACE (l_cur, '%<SETID_COND>%', l_updateres),
                         '%<SETID_DATA>%',
                         '');
            l_cur :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_cur,
                                 '%<SETID_TABLE>%',
                                 'sr_matrix, sr_controls'),
                        '%<MASTERGROUPNUMBER>%',
                        vGrp.grpl_grp_depend),
                    '%<SETID_FIELD>%',
                    'vCur.ESSROWID');
            l_cur := REPLACE (l_cur, '%<ESSFIELDROWID>%', l_param);
            p_res := REPLACE (l_cond, '%<STOPCONTROLCONDITION>%', l_cur);

            INSERT INTO sr_pkg_text (spt_id, spt_text)
                 VALUES (l_counter, p_res);

            l_counter := l_counter + 1;
        END LOOP;

        p_res := '';
        l_cur := '';

        --Вибираю код підсистеми
        SELECT es_ss_code
          INTO l_ss_code
          FROM sr_groups, sr_essences
         WHERE grp_es = es_code AND grp_id = p_group;

        --вибираю шаблон для закінчення контролю поточної суттєвості
        SELECT tm_templ
          INTO l_updateres
          FROM sr_template
         WHERE tm_id = tmplPKG_STOP_ESSENCE;

        --Сворюю атомарні контролі
        FOR l_CurCntr
            IN (  SELECT sr_controls.*
                    FROM sr_controls
                   WHERE     cntr_grp = p_group
                         AND cntr_status = ikis_const.v_dds_yn_y
                ORDER BY cntr_order)
        LOOP
            --Вибір типу коду контроля
            IF l_CurCntr.cntr_code_type = ikis_const.v_dds_cntr_cond_type_i
            THEN
                SELECT tm_templ
                  INTO l_cur
                  FROM sr_template
                 WHERE tm_id = tmplPKG_IFCONTROL;
            ELSIF l_CurCntr.cntr_code_type =
                  ikis_const.v_dds_cntr_cond_type_U
            THEN
                SELECT tm_templ
                  INTO l_cur
                  FROM sr_template
                 WHERE tm_id = tmplPKG_UPDATECONTROL;
            ELSIF l_CurCntr.cntr_code_type =
                  ikis_const.v_dds_cntr_cond_type_E
            THEN
                SELECT tm_templ
                  INTO l_cur
                  FROM sr_template
                 WHERE tm_id = tmplPKG_EXCEPTIONCONTROL;
            ELSIF l_CurCntr.cntr_code_type =
                  ikis_const.v_dds_cntr_cond_type_F
            THEN
                SELECT tm_templ
                  INTO l_cur
                  FROM sr_template
                 WHERE tm_id = tmplPKG_IFEXCEPTIONCONTROL;
            ELSIF l_CurCntr.cntr_code_type =
                  ikis_const.v_dds_cntr_cond_type_R
            THEN
                SELECT tm_templ
                  INTO l_cur
                  FROM sr_template
                 WHERE tm_id = tmplPKG_USEREXCEPTIONCONTROL;
            END IF;

            --Чи буде чей контроль впливати на помилковість документу
            SELECT TO_CHAR (CASE WHEN COUNT (*) = 0 THEN '0' ELSE '1' END)
              INTO l_ErrorFlg
              FROM sr_control_msg, ikis_messages
             WHERE     msg_cntr = l_CurCntr.cntr_id
                   AND msg_ipm = ipm_id
                   AND msg_res_type = 'B'
                   AND ipm_tp = IKIS_CONST.V_DDS_MESSAGE_TP_E;

            SELECT TO_CHAR (CASE WHEN COUNT (*) = 0 THEN '0' ELSE '1' END)
              INTO l_WarningFlg
              FROM sr_control_msg, ikis_messages
             WHERE     msg_cntr = l_CurCntr.cntr_id
                   AND msg_ipm = ipm_id
                   AND msg_res_type = 'B'
                   AND ipm_tp = IKIS_CONST.V_DDS_MESSAGE_TP_W;


            IF     (l_CurCntr.cntr_precode = 'Y')
               AND (NOT l_CurCntr.cntr_code_type = 'R')
            THEN
                --попередній розрахунок контроля
                SELECT tm_templ
                  INTO l_Pre
                  FROM sr_template
                 WHERE tm_id = 7;

                l_Pre :=
                    REPLACE (l_Pre,
                             '%<CONDITION>%',
                             TRIM (l_CurCntr.cntr_codeSQL));
                l_cur := REPLACE (l_cur, '%<CONDITION>%', 'vRes=1');
                l_cur := REPLACE (l_cur, '%<CALCCONDITION>%', l_Pre);
            ELSE
                --без попереднього розрахунку
                l_cur :=
                    REPLACE (l_cur,
                             '%<CONDITION>%',
                             TRIM (l_CurCntr.cntr_codeSQL));
                l_cur := REPLACE (l_cur, '%<CALCCONDITION>%', ' ');
            END IF;

            l_cur :=
                REPLACE (l_cur,
                         '%<RAISE_USER_EXCEPTION>%',
                         'raise sr_engine_ex.user_control_exception;');

            IF l_CurCntr.cntr_cntrCond IS NOT NULL
            THEN
                IF LENGTH (TRIM (l_CurCntr.cntr_cntrCond)) > 0
                THEN
                    SELECT tm_templ
                      INTO l_Cond
                      FROM sr_template
                     WHERE tm_id = 6;

                    IF l_CurCntr.cntr_precond = 'Y'
                    THEN
                        --попередній розрахунок умови контроля
                        SELECT tm_templ
                          INTO l_Pre
                          FROM sr_template
                         WHERE tm_id = 7;

                        l_Pre :=
                            REPLACE (l_Pre,
                                     '%<CONDITION>%',
                                     TRIM (l_CurCntr.cntr_cntrCond));
                        l_Cond :=
                            REPLACE (l_Cond, '%<CONTROLCOND>%', 'vRes=1');
                        l_Cond := l_Pre || CHR (13) || l_Cond;
                    ELSE
                        --без попереднього розрахунку умови контроля
                        l_Cond :=
                            REPLACE (l_Cond,
                                     '%<CONTROLCOND>%',
                                     TRIM (l_CurCntr.cntr_cntrCond));
                    END IF;

                    l_cur := REPLACE (l_Cond, '%<CONTROLCODE>%', l_cur);
                END IF;
            END IF;

            IF l_CurCntr.cntr_stop_cntr = IKIS_CONST.V_DDS_CNTR_STOP_S
            THEN
                l_cur :=
                    REPLACE (l_cur, '%<STOP_ESSENCE_CONTROL>%', l_updateres);
            ELSE
                IF l_CurCntr.cntr_code_type =
                   ikis_const.v_dds_cntr_cond_type_U
                THEN
                    l_cur :=
                        REPLACE (l_cur, '%<STOP_ESSENCE_CONTROL>%', 'null;');
                ELSE
                    l_cur := REPLACE (l_cur, '%<STOP_ESSENCE_CONTROL>%', '');
                END IF;
            END IF;

            l_cur := REPLACE (l_cur, '%<ERRORFLAG>%', l_ErrorFlg);
            l_cur := REPLACE (l_cur, '%<WARNINGFLAG>%', l_WarningFlg);
            l_cur := REPLACE (l_cur, '%<CONTROLNUMBER>%', l_CurCntr.cntr_id);
            l_cur :=
                REPLACE (l_cur,
                         '%<CONTROLNAMENUMBER>%',
                         l_CurCntr.cntr_number);
            l_cur := REPLACE (l_cur, '%<CUR>%', 'vCur');

            --додавання коду контрою до загального тексту
            IF l_CurCntr.cntr_codeSQL IS NOT NULL
            THEN
                IF LENGTH (TRIM (l_CurCntr.cntr_codeSQL)) > 0
                THEN
                    INSERT INTO sr_pkg_text (spt_id, spt_text)
                         VALUES (l_counter, l_cur);

                    l_counter := l_counter + 1;
                END IF;
            END IF;
        END LOOP;

        p_res := '';
        l_cur := '';

        ------
        --вибір закінчення пакаджу
        SELECT tm_templ
          INTO p_res
          FROM sr_template
         WHERE tm_id = tmplPKG_END;

        SELECT COUNT (*)
          INTO l_needfinal
          FROM sr_group_final
         WHERE gf_grp = p_group AND NOT gf_finalcond = 'U';

        IF l_needfinal > 0
        THEN
            --Створення секції фіналізації
            SELECT tm_templ
              INTO l_cur
              FROM sr_template
             WHERE tm_id = tmplPKG_FINALSECTION;

            FOR vGrpl
                IN (  SELECT *
                        FROM sr_group_links
                       WHERE     grpl_grp_master = p_group
                             AND grpl_usetofinal = 'Y'
                    ORDER BY grpl_ord)
            LOOP
                SELECT tm_templ
                  INTO l_pre
                  FROM sr_template
                 WHERE tm_id = tmplPKG_COUNTERRFLAG;

                l_cond :=
                    REPLACE (vGrpl.grpl_cntrsql,
                             '%<SETID>%',
                             'vCurEss.m_rowid');
                l_pre := REPLACE (l_pre, '%<GROUPQUERY>%', l_cond);
                l_pre := REPLACE (l_pre, '%<SETID_DATA>%', 'd_rowid');
                l_pre := REPLACE (l_pre, '%<SETID_TABLE>%', 'dual');
                l_pre :=
                    REPLACE (l_pre, '%<SETID_FIELD>%', 'vCurEss.m_rowid');
                l_pre := REPLACE (l_pre, '%<SETID_COND>%', '1=1');
                l_cur := REPLACE (l_cur, '%<COUNTERRFLAG>%', l_pre);
                l_cur :=
                    REPLACE (l_cur, '%<DEPENDGROUP>%', vGrpl.grpl_grp_depend);
            END LOOP;

            l_cur := REPLACE (l_cur, '%<COUNTERRFLAG>%', '');

            p_res := REPLACE (p_res, '%<FINALSECTION>%', l_cur);

            --створення секці фіналізації
            --Прходимось по усім кодам фіналізації
            l_updateres := NULL;

            FOR vSQL IN (  SELECT *
                             FROM sr_group_final
                            WHERE gf_grp = p_group AND NOT gf_finalcond = 'U'
                         ORDER BY gf_number)
            LOOP
                IF NOT vSQL.gf_finalcode = 'U'
                THEN
                    SELECT tm_templ
                      INTO l_cur
                      FROM sr_template
                     WHERE tm_id = tmplPKG_FINALCODE;
                ELSE
                    l_cur := '%<UPDATECODE>%';
                END IF;

                SELECT tm_templ
                  INTO l_pre
                  FROM sr_template
                 WHERE tm_id = tmplPKG_UPDATEEXCEPTION;

                l_pre := REPLACE (l_pre, '%<UPDATEQUERY>%', vSQL.gf_sql);
                l_pre :=
                    REPLACE (l_pre, '%<SETID_FIELD>%', 'vCurEss.m_rowid');
                l_pre := REPLACE (l_pre, '%<CODENUMBER>%', vSQL.gf_number);

                IF vSQL.gf_finalcond = 'B'
                THEN
                    SELECT tm_templ
                      INTO l_res
                      FROM sr_template
                     WHERE tm_id = tmplPKG_FINAL_B;
                ELSIF vSQL.gf_finalcond = 'G'
                THEN
                    SELECT tm_templ
                      INTO l_res
                      FROM sr_template
                     WHERE tm_id = tmplPKG_FINAL_G;
                END IF;

                IF vSQL.gf_msgtype = 'W'
                THEN
                    l_res := REPLACE (l_res, '%<ERRORTYPE>%', 'vWrn');
                ELSIF vSQL.gf_msgtype = 'E'
                THEN
                    l_res := REPLACE (l_res, '%<ERRORTYPE>%', 'vErr');
                END IF;

                l_res := REPLACE (l_res, '%<UPDATECODE>%', l_pre);
                l_cur := REPLACE (l_cur, '%<UPDATECODE>%', l_res);
                l_cur := REPLACE (l_cur, '%<CODE>%', vSQL.gf_finalcode);

                l_updateres := l_updateres || CHR (10) || l_cur;
            END LOOP;

            p_res := REPLACE (p_res, '%<UPDATESECTION>%', l_updateres);
        ELSE
            p_res := REPLACE (p_res, '%<FINALSECTION>%', '');
        END IF;

        --Визначаю необхідність створення заключної секції
        SELECT COUNT (*)
          INTO l_needfinal
          FROM sr_group_final
         WHERE gf_grp = p_group AND gf_finalcond = 'U';

        IF l_needfinal > 0
        THEN
            SELECT tm_templ
              INTO l_updateres
              FROM sr_template
             WHERE tm_id = tmplPKG_FINALCODE;

            SELECT tm_templ
              INTO l_param
              FROM sr_template
             WHERE tm_id = tmplPKG_SETID_ROWS;

            l_param := REPLACE (l_param, '%<GROUPNUMBER>%', 'vGroupNumber');

            l_cur := NULL;

            FOR vSQL IN (  SELECT *
                             FROM sr_group_final
                            WHERE gf_grp = p_group AND gf_finalcond = 'U'
                         ORDER BY gf_number)
            LOOP
                l_pre := NULL;
                l_pre := REPLACE (vSQL.gf_SQL, '%<SETID>%', l_param);
                l_pre := REPLACE (l_pre, '%<SETID_DATA>%', 'wgs_rowid');
                l_pre := REPLACE (l_pre, '%<SETID_TABLE>%', 'SR_WORK_GROUPS');
                l_pre := REPLACE (l_pre, '%<SETID_FIELD>%', 'wgs_rowid');
                l_pre :=
                    REPLACE (l_pre,
                             '%<SETID_COND>%',
                             'wgs_group=vGroupNumber');

                IF NOT vSQL.gf_finalcode = 'U'
                THEN
                    l_pre := REPLACE (l_updateres, '%<UPDATECODE>%', l_pre);
                    l_pre := REPLACE (l_pre, '%<CODE>%', vSQL.gf_finalcode);
                END IF;

                l_cur := l_cur || CHR (10) || CHR (10) || l_pre;
            END LOOP;

            p_res := REPLACE (p_res, '%<EXECSECTION>%', l_cur);
        END IF;

        p_res := REPLACE (p_res, '%<EXECSECTION>%', 'null');

        l_res := NULL;

        FOR vLinkGrp IN (  SELECT *
                             FROM sr_group_links
                            WHERE grpl_grp_master = p_group
                         ORDER BY grpl_ord)
        LOOP
            SELECT tm_templ
              INTO l_cur
              FROM sr_template
             WHERE tm_id = tmplPKG_FILLMATRIX;

            l_cur :=
                REPLACE (l_cur, '%<FILLMATRIXSQL>%', vLinkGrp.grpl_cntrsql);
            l_cur := REPLACE (l_cur, '%<SETID_DATA>%', ', l_DependGroup');
            l_cur := REPLACE (l_cur, '%<SETID_TABLE>%', 'sr_work_task');
            l_cur := REPLACE (l_cur, '%<SETID_FIELD>%', 'wt_rowid');
            l_cur := REPLACE (l_cur, '%<SETID_COND>%', 'wt_w=pWork_id');
            l_cur :=
                REPLACE (l_cur,
                         '%<DEPENDGROUP>%',
                         TO_CHAR (vLinkGrp.grpl_grp_depend));
            l_res := l_res || CHR (10) || l_cur;
        END LOOP;

        p_res := REPLACE (p_res, '%<FILLMATRIXSQL>%', l_res);

        INSERT INTO sr_pkg_text (spt_id, spt_text)
             VALUES (l_counter, p_res);

        l_counter := l_counter + 1;

        TmplReplace ('%<V_CONTROLNUMBER>%', 'vControlNumber');
        TmplReplace ('%<V_GROUPNUMBER>%', 'vGroupNumber');
        TmplReplace ('%<GROUPNUMBER>%', TO_CHAR (p_group));
        TmplReplace ('%<SS_CODE>%', '''' || l_ss_code || '''');
        p_res := '';

        FOR vRow IN (  SELECT *
                         FROM sr_pkg_text
                     ORDER BY spt_id)
        LOOP
            l_parts := INSTR (vRow.spt_text, '%<SETPARAM(');

            WHILE (l_parts > 0)
            LOOP
                l_pre := SUBSTR (vRow.spt_text, 1, l_parts - 1);
                l_cond :=
                    SUBSTR (vRow.spt_text,
                            l_parts + 11,
                            LENGTH (vRow.spt_text));
                l_cur := SUBSTR (l_cond, 1, INSTR (l_cond, ')>%') - 1);
                l_cond :=
                    SUBSTR (l_cond,
                            INSTR (l_cond, ')>%') + 3,
                            LENGTH (l_cond));

                vRow.spt_text :=
                       l_pre
                    || 'SR_ENGINE_EX.SETWORKPARAM(to_number(Fields(''VLOG.WORK_ID'')),'
                    || l_cur
                    || ')'
                    || l_cond;
                l_parts := INSTR (vRow.spt_text, '%<SETPARAM(');
            END LOOP;

            l_parts := INSTR (vRow.spt_text, '%<GETPARAM(');

            WHILE (l_parts > 0)
            LOOP
                l_pre := SUBSTR (vRow.spt_text, 1, l_parts - 1);
                l_cond :=
                    SUBSTR (vRow.spt_text,
                            l_parts + 11,
                            LENGTH (vRow.spt_text));
                l_cur := SUBSTR (l_cond, 1, INSTR (l_cond, ')>%') - 1);
                l_cond :=
                    SUBSTR (l_cond,
                            INSTR (l_cond, ')>%') + 3,
                            LENGTH (l_cond));

                vRow.spt_text :=
                       l_pre
                    || 'SR_ENGINE_EX.GETWORKPARAM(to_number(Fields(''VLOG.WORK_ID'')),'
                    || l_cur
                    || ')'
                    || l_cond;
                l_parts := INSTR (vRow.spt_text, '%<GETPARAM(');
            END LOOP;

            p_res := p_res || CHR (10) || vRow.spt_text;
        END LOOP;

        ROLLBACK;
    END;

    PROCEDURE InsertCntrMsg (
        p_msg_cntr       IN     sr_controls.cntr_id%TYPE,
        p_msg_type       IN     ikis_messages.ipm_tp%TYPE,
        p_msg            IN     ikis_messages.ipm_message%TYPE,
        p_msg_number     IN     sr_control_msg.msg_number%TYPE,
        p_msg_res_type   IN     sr_control_msg.msg_res_type%TYPE,
        p_msg_order      IN     sr_control_msg.msg_order%TYPE,
        p_ipm_id            OUT ikis_messages.ipm_id%TYPE)
    IS
        l_es   ikis_messages.ipm_ss_code%TYPE;
    BEGIN
        SELECT es_ss_code
          INTO l_es
          FROM sr_controls, sr_groups, sr_essences
         WHERE     cntr_id = p_msg_cntr
               AND cntr_grp = grp_id
               AND grp_es = es_code;

        IKIS_MESSAGE_UTIL.ADD_MESSAGE (l_es,
                                       p_msg_type,
                                       p_msg,
                                       'N/A',
                                       'N/A',
                                       'SR_CONTROLS',
                                       'N/A',
                                       p_ipm_id);

        INSERT INTO sr_control_msg (msg_ipm,
                                    msg_cntr,
                                    msg_number,
                                    msg_order,
                                    msg_res_type)
             VALUES (p_ipm_id,
                     p_msg_cntr,
                     p_msg_number,
                     p_msg_order,
                     p_msg_res_type);

        FOR i IN 1 .. 8
        LOOP
            INSERT INTO sr_msg_params (gmp_ipm, gmp_num)
                 VALUES (p_ipm_id, i);
        END LOOP;

        COMMIT;
    END;


    PROCEDURE InsertGrpMsg (
        p_msg_grp     IN     sr_groups.grp_id%TYPE,
        p_msg_type    IN     ikis_messages.ipm_tp%TYPE,
        p_gm          IN     ikis_messages.ipm_message%TYPE,
        p_gm_type     IN     sr_groups_msg.gm_msg_type%TYPE,
        p_gm_number   IN     sr_groups_msg.gm_number%TYPE,
        p_gm_order    IN     sr_groups_msg.gm_order%TYPE,
        p_ipm_id         OUT ikis_messages.ipm_id%TYPE)
    IS
        l_es   ikis_messages.ipm_ss_code%TYPE;
    BEGIN
        SELECT es_ss_code
          INTO l_es
          FROM sr_groups, sr_essences
         WHERE grp_id = p_msg_grp AND grp_es = es_code;

        IKIS_MESSAGE_UTIL.ADD_MESSAGE (l_es,
                                       p_msg_type,
                                       p_gm,
                                       'N/A',
                                       'N/A',
                                       'SR_CONTROLS',
                                       'N/A',
                                       p_ipm_id);

        INSERT INTO sr_groups_msg (gm_ipm,
                                   gm_grp,
                                   gm_msg_type,
                                   gm_number,
                                   gm_order)
             VALUES (p_ipm_id,
                     p_msg_grp,
                     p_gm_type,
                     p_gm_number,
                     p_gm_order);

        FOR i IN 1 .. 8
        LOOP
            INSERT INTO sr_msg_params (gmp_ipm, gmp_num)
                 VALUES (p_ipm_id, i);
        END LOOP;

        COMMIT;
    END;

    PROCEDURE DeleteCntrMsg (p_ipm_id IN ikis_messages.ipm_id%TYPE)
    IS
    BEGIN
        DELETE FROM sr_msg_params
              WHERE gmp_ipm = p_ipm_id;

        DELETE FROM sr_control_msg
              WHERE msg_ipm = p_ipm_id;

        DELETE FROM ikis_messages
              WHERE ipm_id = p_ipm_id;

        COMMIT;
    END;

    PROCEDURE DeleteGrpMsg (p_ipm_id IN ikis_messages.ipm_id%TYPE)
    IS
    BEGIN
        DELETE FROM sr_msg_params
              WHERE gmp_ipm = p_ipm_id;

        DELETE FROM sr_groups_msg
              WHERE gm_ipm = p_ipm_id;

        DELETE FROM ikis_messages
              WHERE ipm_id = p_ipm_id;

        COMMIT;
    END;
END sr_MANAGER;
/