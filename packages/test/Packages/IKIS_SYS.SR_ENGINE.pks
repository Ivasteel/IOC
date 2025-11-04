/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.SR_ENGINE
    AUTHID CURRENT_USER
IS
    g_Execution   BOOLEAN := FALSE;

    -- Author  : RYABA
    -- Created : 19.06.2003 9:55:34
    -- Purpose : Виконання контролів

    -- begin Юрий Колесников
    -- 21.08.2003
    -- создание задачи для выполнения технологического контроля страхувальників
    -- без добавления ровид контролируемых сущностей
    PROCEDURE Create_insur_cwork (
        pGroup       IN     sr_groups.grp_id%TYPE,          -- группа контооля
        pProtLevel   IN     NUMBER := ikis_const.V_DDS_PROT_LEVEL_3, -- уровень "логирования"
        pFinalize    IN     VARCHAR2 := ikis_const.V_DDS_YN_Y,
        pFinalCode   IN     VARCHAR2 := ikis_const.V_DDS_FINALCODE_A,
        pWork           OUT SR_work.w_Id%TYPE -- идентификатор созданной задачи
                                             );

    --Autor: Ryaba
    --Теж саме, що й попередня, але з загальною назвою
    PROCEDURE Create_sr_work (
        p_group       IN     sr_groups.grp_id%TYPE,         -- группа контооля
        p_protLevel   IN     NUMBER := ikis_const.V_DDS_PROT_LEVEL_3, -- уровень "логирования"
        p_finalize    IN     VARCHAR2 := ikis_const.V_DDS_YN_Y,
        p_finalCode   IN     VARCHAR2 := ikis_const.V_DDS_FINALCODE_A,
        p_work           OUT SR_work.w_Id%TYPE -- идентификатор созданной задачи
                                              );


    ----------------------------------------
    -- Юрий Колесников
    ----------------------------------------
    -- Назначение : Добавление ровид анкет для контроля
    -- Параметры  : ровид, сессия контроля
    PROCEDURE Add_insur_to_cwork (pEssRowID   IN ROWID,
                                  pWorkID     IN sr_work_task.wt_w%TYPE);

    -- end Юрий Колесников


    --Autor: Ryaba
    --Теж саме, що й попередня, але з з агальною завою
    PROCEDURE Add_essid_to_sr_work (p_essRowID   IN ROWID,
                                    p_workID     IN sr_work_task.wt_w%TYPE);

    PROCEDURE Add_sql_to_sr_work (p_sql      IN VARCHAR2,
                                  p_workID   IN sr_work_task.wt_w%TYPE);


    --Autor: Ryaba
    --додає ROWID по запиту
    --запит повинен повертати: ID задачі  ||  ROWID суттєвості
    PROCEDURE Add_list_essid_to_sr_work (
        p_sql      IN VARCHAR2,
        p_workID   IN sr_work_task.wt_w%TYPE);

    --Autor: ryaba
    --Процедура повертає № сеансу протоколу контроля
    PROCEDURE Work_prot_seans (
        p_work         IN     sr_work.w_id%TYPE,
        p_prot_seans      OUT sr_work.w_prot_seans%TYPE);

    ----------------------------------------
    -- Ryaba
    ----------------------------------------
    -- Запуск процедуры контроля с закрытием транзакции
    PROCEDURE Execute_cs_work (
        pWork         IN SR_work.w_Id%TYPE,
        p_protseans   IN ikis_protocol.prot_seans%TYPE := 0);

    -- То же без закрытия транзакции
    PROCEDURE Execute_cs_work_wot (
        pWork           IN SR_work.w_Id%TYPE,
        p_protseans     IN ikis_protocol.prot_seans%TYPE := 0,
        p_close_seans   IN INTEGER := 1);
END SR_ENGINE;
/


CREATE OR REPLACE PUBLIC SYNONYM SR_ENGINE FOR IKIS_SYS.SR_ENGINE
/


GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO II01RC_SR_CONTROL_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.SR_ENGINE
IS
    -- Author  : RYABA
    -- Created : 19.06.2003 9:55:34

    --головна група контроля
    GGroupMaster                 NUMBER;
    GFinalCode                   CHAR (1);
    GProtLevel                   CHAR (1);
    GFinalyze                    CHAR (1);
    GWork                        NUMBER;
    g_SR_ProtSeans               NUMBER;

    -- Messages for category: COMMON
    msgUNIQUE_VIOLATION          NUMBER := 1;
    msgCOMMON_EXCEPTION          NUMBER := 2;
    msgGroupControlError         NUMBER := 97;
    msgProgramError              NUMBER := 117;

    -- Шаблоны
    tmplPKG_BEGIN                INTEGER := 1;
    tmplPKG_END                  INTEGER := 2;
    tmplPKG_IFCONTROL            INTEGER := 3;
    tmplPKG_UPDATECONTROL        INTEGER := 4;
    tmplPKG_FILLMATRIX           INTEGER := 5;
    tmplPKG_CONTROLCOND          INTEGER := 6;
    tmplPKG_PRECONDITION         INTEGER := 7;
    tmplPKG_EXCEPTIONCONTROL     INTEGER := 8;
    tmplPKG_IFEXCEPTIONCONTROL   INTEGER := 9;

    msgFinalResError             NUMBER := 574;
    msgFinalError                NUMBER := 575;
    msgGroupExecError            NUMBER := 576;
    msgFillMatrisSQL             NUMBER := 877;
    msgEssLocked                 NUMBER := 1042;

    PROT_TYPE_LT                 VARCHAR2 (30) := 'LT';
    PROT_TYPE_DF                 VARCHAR2 (30) := 'DEF';
    PROT_TYPE_CT                 VARCHAR2 (30) := 'CT';

    RESOURCE_BUSY_AND_NOWAIT     EXCEPTION;
    PRAGMA EXCEPTION_INIT (RESOURCE_BUSY_AND_NOWAIT, -54);


    FUNCTION GetNextWork
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT sq_id_sr_work.NEXTVAL INTO l_res FROM DUAL;

        RETURN l_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'GetNextWork',
                                               CHR (10) || SQLERRM));
    END;


    -- + Автор: kyb 21.08.2003
    -- Автор: kyb 21.08.2003
    -- Назначение:
    --   создание задачи для выполнения технологического контроля страхувальників
    PROCEDURE Create_insur_cwork (
        pGroup       IN     sr_groups.grp_id%TYPE,          -- группа контооля
        pProtLevel   IN     NUMBER := ikis_const.V_DDS_PROT_LEVEL_3, -- уровень "логирования"
        pFinalize    IN     VARCHAR2 := ikis_const.V_DDS_YN_Y, --нужно ли выполнять финализацию
        pFinalCode   IN     VARCHAR2 := ikis_const.V_DDS_FINALCODE_A,
        pWork           OUT SR_work.w_Id%TYPE -- вщзвращаемый идентификатор созданной задачи
                                             )
    IS
    BEGIN
        pWork := SR_ENGINE.GetNextWork;

        INSERT INTO SR_work (w_id,
                             w_grp,
                             w_set_time,
                             w_prot_level,
                             w_status,
                             w_finalyze,
                             w_finalcode)
             VALUES (pWork,
                     pGroup,
                     SYSDATE,
                     pProtLevel,
                     ikis_const.V_DDS_WORK_STATUS_S,
                     pFinalize,
                     pFinalCode);

        DELETE FROM sr_matrix;

        DELETE FROM sr_work_task;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'Create_insur_cwork',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE Create_sr_work (
        p_group       IN     sr_groups.grp_id%TYPE,         -- группа контооля
        p_protLevel   IN     NUMBER := ikis_const.V_DDS_PROT_LEVEL_3, -- уровень "логирования"
        p_finalize    IN     VARCHAR2 := ikis_const.V_DDS_YN_Y,
        p_finalCode   IN     VARCHAR2 := ikis_const.V_DDS_FINALCODE_A,
        p_work           OUT SR_work.w_Id%TYPE -- идентификатор созданной задач
                                              )
    IS
    BEGIN
        p_work := SR_ENGINE.GetNextWork;

        INSERT INTO SR_work (w_id,
                             w_grp,
                             w_set_time,
                             w_prot_level,
                             w_status,
                             w_finalyze,
                             w_finalcode)
             VALUES (p_work,
                     p_group,
                     SYSDATE,
                     p_protLevel,
                     ikis_const.V_DDS_WORK_STATUS_S,
                     p_finalize,
                     p_finalCode);

        DELETE FROM sr_matrix;

        DELETE FROM sr_work_task;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'SR_ENGINE.Create_sr_work',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_insur_to_cwork (pEssRowID   IN ROWID,
                                  pWorkID     IN sr_work_task.wt_w%TYPE)
    IS
    BEGIN
        INSERT INTO sr_work_task (wt_w, wt_rowid)
             VALUES (pWorkID, pEssRowID);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'Add_insur_to_cwork',
                                               CHR (10) || SQLERRM));
    END;

    -- - kyb 21.08.2003

    PROCEDURE Add_essid_to_sr_work (p_essRowID   IN ROWID,
                                    p_workID     IN sr_work_task.wt_w%TYPE)
    IS
    BEGIN
        INSERT INTO sr_work_task (wt_w, wt_rowid)
             VALUES (p_workID, p_essRowID);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'SR_ENGINE.Add_essid_to_sr_work',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_list_essid_to_sr_work (
        p_sql      IN VARCHAR2,
        p_workID   IN sr_work_task.wt_w%TYPE)
    IS
        vSQL   VARCHAR2 (4000)
                   := 'insert into sr_work_task(wt_w, wt_rowid) %<SELECT>%';
    BEGIN
        SAVEPOINT one;
        vSQL := REPLACE (vSQL, '%<SELECT>%', p_sql);

        EXECUTE IMMEDIATE vSQL;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'SR_ENGINE.Add_essid_to_sr_work',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_sql_to_sr_work (p_sql      IN VARCHAR2,
                                  p_workID   IN sr_work_task.wt_w%TYPE)
    IS
        vSQL      VARCHAR2 (4000)
                      := 'insert into sr_work_task(wt_w, wt_rowid) %<SELECT>%';
        vSelect   VARCHAR2 (4000);
    BEGIN
        SAVEPOINT one;
        vSelect :=
            REPLACE (UPPER (p_sql), 'SELECT', 'SELECT ' || p_WorkID || ',');
        vSQL := REPLACE (vSQL, '%<SELECT>%', vSelect);

        EXECUTE IMMEDIATE vSQL;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'SR_ENGINE.Add_sql_to_sr_work',
                    CHR (10) || SQLERRM));
    END;



    PROCEDURE Work_prot_seans (
        p_work         IN     sr_work.w_id%TYPE,
        p_prot_seans      OUT sr_work.w_prot_seans%TYPE)
    IS
    BEGIN
        SELECT w_prot_seans
          INTO p_prot_seans
          FROM sr_work
         WHERE w_id = p_work;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'SR_ENGINE.Work_prot_seans',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE ExecControl (pGroup IN sr_groups.grp_id%TYPE)
    IS
        vExecSQL   VARCHAR2 (4000)
            := 'begin sr_group_control_%<GROUP>%.exec_control(:p_work,:p_protlevel,:p_protseans); end;';
    BEGIN
        --dbms_output.put_line('pGroup: '||pGroup);
        vExecSQL := REPLACE (vExecSQL, '%<GROUP>%', TO_CHAR (pGroup));

        BEGIN
            --dbms_output.put_line(vExecSQL);
            EXECUTE IMMEDIATE vExecSQL
                USING SR_ENGINE.GWork, GProtLevel, g_SR_ProtSeans;
        EXCEPTION
            WHEN RESOURCE_BUSY_AND_NOWAIT
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgEssLocked, pGroup));
            WHEN OTHERS
            THEN
                raise_application_error (-20000,
                                         ikis_message_util.GET_MESSAGE (
                                             msgGroupExecError,
                                             pGroup,
                                             CHR (10) || SQLERRM || CHR (10),
                                             vExecSQL));
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgGroupControlError,
                                               pGroup,
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE ExecFinal
    IS
        vExecSQL   VARCHAR2 (4000)
            := 'begin sr_group_control_%<GROUP>%.exec_final(:p_work,:p_finalcode); end;';
    BEGIN
        vExecSQL := REPLACE (vExecSQL, '%<GROUP>%', TO_CHAR (GGroupMaster));

        BEGIN
            --dbms_output.put_line(vExecSQL);
            EXECUTE IMMEDIATE vExecSQL
                USING SR_ENGINE.GWork, GFinalCode;
        EXCEPTION
            WHEN RESOURCE_BUSY_AND_NOWAIT
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgEssLocked,
                                                   GGroupMaster));
            WHEN OTHERS
            THEN
                raise_application_error (-20000,
                                         ikis_message_util.GET_MESSAGE (
                                             msgGroupExecError,
                                             GGroupMaster,
                                             CHR (10) || SQLERRM || CHR (10),
                                             vExecSQL));
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgGroupControlError,
                                               GGroupMaster,
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE ExecAfterFinal
    IS
        vExecSQL   VARCHAR2 (4000)
            := 'begin sr_group_control_%<GROUP>%.EXEC_AFTER_FINAL(:p_work,:p_finalcode); end;';
    BEGIN
        vExecSQL := REPLACE (vExecSQL, '%<GROUP>%', TO_CHAR (GGroupMaster));

        BEGIN
            --dbms_output.put_line(vExecSQL);
            EXECUTE IMMEDIATE vExecSQL
                USING SR_ENGINE.GWork, GFinalCode;
        EXCEPTION
            WHEN RESOURCE_BUSY_AND_NOWAIT
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgEssLocked,
                                                   GGroupMaster));
            WHEN OTHERS
            THEN
                raise_application_error (-20000,
                                         ikis_message_util.GET_MESSAGE (
                                             msgGroupExecError,
                                             GGroupMaster,
                                             CHR (10) || SQLERRM || CHR (10),
                                             vExecSQL));
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgGroupControlError,
                                               GGroupMaster,
                                               CHR (10) || SQLERRM));
    END;


    PROCEDURE FullControl
    IS
    BEGIN
        FOR vGrp IN (  SELECT grpl_grp_depend
                         FROM SR_group_links
                        WHERE grpl_grp_master = GGroupMaster AND grpl_ord < 0
                     ORDER BY grpl_ord)
        LOOP
            --dbms_output.put_line('Depend froup 1 '||vGrp.grpl_grp_depend);
            ExecControl (vGrp.grpl_grp_depend);
        END LOOP;

        --dbms_output.put_line('Main group '||GGroupMaster);
        ExecControl (GGroupMaster);

        FOR vGrp IN (  SELECT grpl_grp_depend
                         FROM SR_group_links
                        WHERE grpl_grp_master = GGroupMaster AND grpl_ord > 0
                     ORDER BY grpl_ord)
        LOOP
            --dbms_output.put_line('Depend froup 2 '||vGrp.grpl_grp_depend);
            ExecControl (vGrp.grpl_grp_depend);
        END LOOP;

        ExecFinal;
        ExecAfterFinal;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'FullControl',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE FillFullMatrix
    IS
        vExecSQL   VARCHAR2 (4000)
            := 'begin sr_group_control_%<GROUP>%.FillMatrix(%<WORK>%); end;';
    BEGIN
        vExecSQL := REPLACE (vExecSQL, '%<WORK>%', SR_ENGINE.GWork);
        vExecSQL := REPLACE (vExecSQL, '%<GROUP>%', TO_CHAR (GGroupMaster));

        EXECUTE IMMEDIATE vExecSQL;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'FillFullMatrix',
                                               CHR (10) || SQLERRM));
    END;


    --+ Автор: YURA_A 29.08.2003 12:28:05
    --  Описание: Этот вариант не завершает транзакцию
    PROCEDURE Execute_cs_work_wot (
        pWork           IN SR_work.w_Id%TYPE,
        p_protseans     IN ikis_protocol.prot_seans%TYPE := 0,
        p_close_seans   IN INTEGER := 1)
    IS
        l_ss   ikis_subsys.ss_code%TYPE;
        l_tp   ikis_prot_type.type_code%TYPE;
    BEGIN
        g_Execution := TRUE;

        DELETE FROM sr_work_groups;

        DELETE FROM sr_matrix;

        GWork := pWork;

        IF p_protseans = 0
        THEN
            l_ss := sr_engine_ex.getworkss (pWork);

            CASE ikis_common.getap_ikis_applevel
                WHEN ikis_common.aldistrict
                THEN
                    l_tp := PROT_TYPE_LT;
                WHEN ikis_common.alregion
                THEN
                    l_tp := prot_type_df;
                WHEN ikis_common.alcenter
                THEN
                    l_tp := prot_type_ct;
                ELSE
                    l_tp := prot_type_df;
            END CASE;

            g_SR_ProtSeans := IKIS_PROTOCOL_UTIL.GETNEWSEANS (l_tp, l_ss);
        ELSE
            g_SR_ProtSeans := p_protseans;
        END IF;

        SELECT w_grp,
               w_finalyze,
               w_finalcode,
               w_prot_level
          INTO GGroupMaster,
               GFinalyze,
               GFinalCode,
               GProtLevel
          FROM SR_work
         WHERE w_id = pWork;

        FillFullMatrix;

        FullControl;

        UPDATE sr_work
           SET w_prot_seans = g_SR_ProtSeans
         WHERE w_id = gWork;

        IF NVL (p_close_seans, 1) = 1
        THEN
            IKIS_PROTOCOL_UTIL.CLOSESEANS (
                IKIS_PROTOCOL_UTIL.GETCURPROTSEANS);
        END IF;

        g_Execution := FALSE;
    --  commit;
    --- Автор: YURA_A 29.08.2003 12:28:30
    EXCEPTION
        WHEN OTHERS
        THEN
            g_Execution := FALSE;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'Execute_cs_work_wot',
                                               CHR (10) || SQLERRM));
    END;

    --+ Автор: YURA_A 29.08.2003 12:28:35
    --  Описание: А этот как и раньше завершает транзакцию
    PROCEDURE Execute_cs_work (
        pWork         IN SR_work.w_Id%TYPE,
        p_protseans   IN ikis_protocol.prot_seans%TYPE := 0)
    IS
    BEGIN
        Execute_cs_work_wot (pWork, p_protseans);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'Execute_cs_work',
                                               CHR (10) || SQLERRM));
    END;
--- Автор: YURA_A 29.08.2003 12:28:51


END SR_ENGINE;
/