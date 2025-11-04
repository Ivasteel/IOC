/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_MESSENGER_UTL
IS
    -- Author  : YURA_A
    -- Created : 10.02.2005 12:56:10
    -- Purpose : API керування статусами повімоленнь

    ----------------------------------------
    -- YURA_A 10.02.2005 13:22:47
    ----------------------------------------
    -- Назначение : переводит в следующий статус сообщение для указанного подписчика
    -- Параметры  :
    -- 1: ИД сообщения, ИД пользователя из ikis_users_attr
    -- !!! автономная транзакция
    PROCEDURE SetNextState (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 );

    ----------------------------------------
    -- YURA_A 10.02.2005 13:22:47
    ----------------------------------------
    -- Назначение : переводит в следующий статус сообщение для указанного подписчика
    -- Параметры  :
    -- 2. ИД субскрайбера (msg$subscraber.ms_id)
    -- !!! автономная транзакция
    PROCEDURE SetNextStateL (p_ms msg$subscraber.ms_id%TYPE);

    ----------------------------------------
    -- YURA_A 21.03.2005 18:15:58
    ----------------------------------------
    -- Назначение : подсчет кол-ва сообщений на пользователе
    -- для автостартующего броузера
    -- Параметры  : кол-во задач
    PROCEDURE CheckMessages (p_cnt OUT NUMBER);

    ----------------------------------------
    -- YURA_A 21.03.2005 18:16:02
    ----------------------------------------
    -- Назначение : показать историю изменений статуса задания для пользователя
    -- Параметры  :
    -- 1. ид из msg$message (сообщение)
    -- 2. ид пользователя в ИКИСе
    -- 3. ОПФУ
    -- 4. текст содержит текстовое представление истории переходов
    PROCEDURE ShowHistory (
        p_mes            msg$subscraber.ms_mes%TYPE,
        p_iusr_id        msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org       msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL, -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
        p_hist       OUT VARCHAR2);
END IKIS_MESSENGER_UTL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_MESSENGER_UTL FOR IKIS_SYS.IKIS_MESSENGER_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER_UTL TO II01RC_IKIS_MESSENGER
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_MESSENGER_UTL
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;
    msgEndOfLife          NUMBER := 3873;
    msgInvMesSt           NUMBER := 3874;
    mesInvOpeningType     NUMBER := 4077;
    mesUnknOpeningType    NUMBER := 4078;
    mesTooManyTask        NUMBER := 4079;
    msgNotOwnMess         NUMBER := 4086;


    ----------------------------------------
    -- YURA_A 10.02.2005 13:22:47
    ----------------------------------------
    -- Назначение : переводит в следующий статус сообщение для указанного подписчика
    -- Параметры  :
    -- 1: ИД сообщения, ИД пользователя из ikis_users_attr
    -- 2. ИД субскрайбера (msg$subscraber.ms_id)
    PROCEDURE SetNextState (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 )
    IS
        l_ms    msg$subscraber.ms_id%TYPE;
        l_org   msg$subscraber.ms_iusr_org%TYPE;
    BEGIN
        l_org := NVL (p_iusr_org, ikis_common.GetAP_IKIS_OPFU);

        SELECT ms_id
          INTO l_ms
          FROM msg$subscraber
         WHERE     ms_mes = p_mes
               AND ms_iusr_id = p_iusr_id
               AND ms_iusr_org = l_org;

        SetNextStateL (l_ms);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.SetNextState',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetNextStateL (p_ms msg$subscraber.ms_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        r_subscr          msg$subscraber%ROWTYPE;
        l_next            msg$subscraber.ms_st%TYPE;
        exEndOfLife       EXCEPTION;
        exInqnownStatus   EXCEPTION;
        exNotOwnTask      EXCEPTION;
    BEGIN
        SELECT *
          INTO r_subscr
          FROM msg$subscraber
         WHERE ms_id = p_ms;

        CASE r_subscr.ms_st
            WHEN ikis_const.v_dds_msg_st_N
            THEN
                l_next := ikis_const.v_dds_msg_st_W;
            WHEN ikis_const.v_dds_msg_st_W
            THEN
                l_next := ikis_const.v_dds_msg_st_E;
            WHEN ikis_const.v_dds_msg_st_E
            THEN
                RAISE exEndOfLife;
            ELSE
                RAISE exInqnownStatus;
        END CASE;

        UPDATE msg$subscraber
           SET ms_st = l_next, ms_st_dt = SYSDATE
         WHERE     ms_id = p_ms
               AND ms_iusr_id = getcurrentuserid
               AND ms_iusr_org = ikis_common.GetAP_IKIS_OPFU;

        IF SQL%ROWCOUNT < 1
        THEN
            RAISE exNotOwnTask;
        END IF;

        INSERT INTO msg$message_hst (mh_id,
                                     mh_st,
                                     mh_ms,
                                     mh_st_dt)
             VALUES (0,
                     r_subscr.ms_st,
                     r_subscr.ms_id,
                     r_subscr.ms_st_dt);

        COMMIT;
    EXCEPTION
        WHEN exEndOfLife
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgEndOfLife));
        WHEN exInqnownStatus
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvMesSt));
        WHEN exNotOwnTask
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotOwnMess));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.SetNextState',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckMessages (p_cnt OUT NUMBER)
    IS
        l_org       msg$subscraber.ms_iusr_org%TYPE;
        l_iusr_id   msg$subscraber.ms_iusr_id%TYPE;
    BEGIN
        l_org := ikis_common.GetAP_IKIS_OPFU;
        l_iusr_id := getcurrentuserid;

        SELECT COUNT (1)
          INTO p_cnt
          FROM msg$subscraber
         WHERE     ms_iusr_id = l_iusr_id
               AND ms_iusr_org = l_org
               AND ms_st IN
                       (ikis_const.v_dds_msg_st_N, ikis_const.v_dds_msg_st_W);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_MESSENGER.CheckMessages',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE ShowHistory (
        p_mes            msg$subscraber.ms_mes%TYPE,
        p_iusr_id        msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org       msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL, -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
        p_hist       OUT VARCHAR2)
    IS
        l_hst     VARCHAR2 (1000);
        l_sbscr   msg$subscraber.ms_id%TYPE;
        l_msg     VARCHAR2 (100)
                      := 'Статус<TYPE>: <STATUS>; переведено: <DATE>';
    BEGIN
        SELECT REPLACE (REPLACE (l_msg, '<STATUS>', x2.DIC_SNAME),
                        '<DATE>',
                        TO_CHAR (x1.ms_st_dt, 'DD/MM/YYYY HH24:MI:SS')),
               x1.ms_id
          INTO p_hist, l_sbscr
          FROM msg$subscraber x1, v_dds_msg_st x2
         WHERE     x1.ms_st = x2.DIC_VALUE
               AND x1.ms_mes = p_mes
               AND x1.ms_iusr_id = p_iusr_id
               AND x1.ms_iusr_org =
                   NVL (p_iusr_org, ikis_common.GetAP_IKIS_OPFU);

        p_hist := REPLACE (p_hist, '<TYPE>', ' (поточний)');

        FOR hst IN (  SELECT x2.DIC_SNAME, x3.mh_st_dt
                        FROM msg$message_hst x3, v_dds_msg_st x2
                       WHERE x3.mh_ms = l_sbscr AND x3.mh_st = x2.DIC_VALUE
                    ORDER BY x3.mh_st_dt DESC)
        LOOP
            p_hist :=
                   p_hist
                || CHR (10)
                || REPLACE (
                       REPLACE (
                           REPLACE (l_msg, '<STATUS>', hst.DIC_SNAME),
                           '<DATE>',
                           TO_CHAR (hst.mh_st_dt, 'DD/MM/YYYY HH24:MI:SS')),
                       '<TYPE>',
                       '');
        END LOOP;
    END;
END IKIS_MESSENGER_UTL;
/