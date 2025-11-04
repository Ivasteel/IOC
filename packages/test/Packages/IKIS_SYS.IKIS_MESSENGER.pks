/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_MESSENGER
IS
    -- Author  : YURA_A
    -- Created : 10.02.2005 12:56:10
    -- Purpose : API керування системою повімоленнь

    ----------------------------------------
    -- YURA_A 10.02.2005 13:00:44
    ----------------------------------------
    -- Назначение : Создать сообщение
    -- Параметры  : соотв полям msg$message: дата просрочки, приоритет, заголовок
    -- возвращает ИД нового сообщения
    -- !!! транзакцией не управляет
    FUNCTION CreateMessage (p_boundary_dt   msg$message.mes_boundary_dt%TYPE,
                            p_priority      msg$message.mes_priority%TYPE,
                            p_caption       msg$message.mes_caption%TYPE)
        RETURN msg$message.mes_id%TYPE;

    ----------------------------------------
    -- YURA_A 10.02.2005 13:19:47
    ----------------------------------------
    -- Назначение : Добавить параметр к сообщению
    -- Параметры  : указывать ИД сообщения, значение, тип,имя (для SETPARAM), порядковый номер
    -- см справочник v_dds_msg_par_tp
    -- прим. TEXT - значение отображается как текст в броузере
    -- !!! транзакцией не управляет
    PROCEDURE AddParam (
        p_mes     msg$message_parval.mpv_mes%TYPE,
        p_value   msg$message_parval.mpv_value%TYPE,
        p_tp      msg$message_parval.mpv_tp%TYPE,
        p_name    msg$message_parval.mpv_name%TYPE,
        p_order   msg$message_parval.mpv_order%TYPE DEFAULT NULL -- если нулл то поставить следующий номер
                                                                );

    ----------------------------------------
    -- KYB 29.04.2005 10:27:42
    ----------------------------------------
    -- Назначение : Изменить параметр сообщения
    -- Параметры  : указывать ИД сообщения,
    --              старые: значение, тип,имя (для SETPARAM), порядковый номер
    --              новые:  значение, тип,имя (для SETPARAM), порядковый номер
    -- см справочник v_dds_msg_par_tp
    -- прим. TEXT - значение отображается как текст в броузере
    -- !!! транзакцией не управляет
    PROCEDURE EditParam (
        p_mes         msg$message_parval.mpv_mes%TYPE,
        p_value_old   msg$message_parval.mpv_value%TYPE,
        p_tp_old      msg$message_parval.mpv_tp%TYPE,
        p_name_old    msg$message_parval.mpv_name%TYPE,
        p_order_old   msg$message_parval.mpv_order%TYPE DEFAULT NULL,
        p_value_new   msg$message_parval.mpv_value%TYPE,
        p_tp_new      msg$message_parval.mpv_tp%TYPE,
        p_name_new    msg$message_parval.mpv_name%TYPE,
        p_order_new   msg$message_parval.mpv_order%TYPE DEFAULT NULL);

    ----------------------------------------
    -- YURA_A 10.02.2005 13:21:18
    ----------------------------------------
    -- Назначение : Добавить подписчика к сообщению
    -- Параметры  : указывать ИД сообщение и ИД пользователя из ikis_users_attr
    -- !!! транзакцией не управляет
    PROCEDURE AddSubscr (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 );

    ----------------------------------------
    -- Ryaba 10.02.2005 13:21:18
    ----------------------------------------
    -- Назначение : Поставить статут "Новое" для подписчика
    -- Параметры  : указывать ИД сообщение и ИД пользователя из ikis_users_attr
    -- !!! транзакцией не управляет
    PROCEDURE ReNewSubscr (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 );

    ----------------------------------------
    -- KYB 06.05.2005 11:17:23
    ----------------------------------------
    -- Назначение : Скасувати повідомлення, якщо не "Оброблено"
    -- Параметры  : ид из msg$message (сообщение)
    PROCEDURE CancelMessage (p_mes msg$subscraber.ms_mes%TYPE);
END IKIS_MESSENGER;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_MESSENGER FOR IKIS_SYS.IKIS_MESSENGER
/


GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSENGER TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_MESSENGER
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;
    msgNotActiveUser      NUMBER := 3875;

    exNotActiveUser       EXCEPTION;

    ----------------------------------------
    -- YURA_A 10.02.2005 13:00:44
    ----------------------------------------
    -- Назначение : Создать сообщение
    -- Параметры  : соотв полям msg$message: дата просрочки, приоритет, заголовок
    -- возвращает ИД нового сообщения
    FUNCTION CreateMessage (p_boundary_dt   msg$message.mes_boundary_dt%TYPE,
                            p_priority      msg$message.mes_priority%TYPE,
                            p_caption       msg$message.mes_caption%TYPE)
        RETURN msg$message.mes_id%TYPE
    IS
        l_id   msg$message.mes_id%TYPE;
    BEGIN
        SAVEPOINT msgcm$one;

        INSERT INTO msg$message (mes_id,
                                 mes_que_dt,
                                 mes_boundary_dt,
                                 mes_priority,
                                 mes_caption)
             VALUES (0,
                     SYSDATE,
                     p_boundary_dt,
                     p_priority,
                     p_caption)
          RETURNING mes_id
               INTO l_id;

        RETURN l_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO msgcm$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_MESSENGER.CreateMessage',
                    CHR (10) || SQLERRM));
    END;

    ----------------------------------------
    -- YURA_A 10.02.2005 13:19:47
    ----------------------------------------
    -- Назначение : Добавить параметр к сообщению
    -- Параметры  : указывать ИД сообщения, значение, тип,имя (для SETPARAM), порядковый номер
    -- см справочник v_dds_msg_par_tp
    -- прим. TEXT - значение отображается как текст в броузере
    PROCEDURE AddParam (
        p_mes     msg$message_parval.mpv_mes%TYPE,
        p_value   msg$message_parval.mpv_value%TYPE,
        p_tp      msg$message_parval.mpv_tp%TYPE,
        p_name    msg$message_parval.mpv_name%TYPE,
        p_order   msg$message_parval.mpv_order%TYPE DEFAULT NULL -- если нулл то поставить следующий номер
                                                                )
    IS
        l_order   msg$message_parval.mpv_order%TYPE;
    BEGIN
        SAVEPOINT msgap$one;

        IF p_order IS NULL
        THEN
            SELECT COUNT (1) + 1
              INTO l_order
              FROM msg$message_parval
             WHERE mpv_mes = p_mes;
        ELSE
            l_order := p_order;
        END IF;

        INSERT INTO msg$message_parval (mpv_id,
                                        mpv_mes,
                                        mpv_order,
                                        mpv_value,
                                        mpv_tp,
                                        mpv_name)
             VALUES (0,
                     p_mes,
                     l_order,
                     p_value,
                     p_tp,
                     p_name);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO msgap$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.AddParam',
                                               CHR (10) || SQLERRM));
    END;

    ----------------------------------------
    -- KYB 29.04.2005 10:27:42
    ----------------------------------------
    -- Назначение : Изменить параметр сообщения
    -- Параметры  : указывать ИД сообщения, значение, тип,имя (для SETPARAM), порядковый номер
    -- см справочник v_dds_msg_par_tp
    -- прим. TEXT - значение отображается как текст в броузере
    -- !!! транзакцией не управляет
    PROCEDURE EditParam (
        p_mes         msg$message_parval.mpv_mes%TYPE,
        p_value_old   msg$message_parval.mpv_value%TYPE,
        p_tp_old      msg$message_parval.mpv_tp%TYPE,
        p_name_old    msg$message_parval.mpv_name%TYPE,
        p_order_old   msg$message_parval.mpv_order%TYPE DEFAULT NULL,
        p_value_new   msg$message_parval.mpv_value%TYPE,
        p_tp_new      msg$message_parval.mpv_tp%TYPE,
        p_name_new    msg$message_parval.mpv_name%TYPE,
        p_order_new   msg$message_parval.mpv_order%TYPE DEFAULT NULL)
    IS
    BEGIN
        SAVEPOINT msgep$one;

        UPDATE msg$message_parval
           SET mpv_value = p_value_new,
               mpv_tp = p_tp_new,
               mpv_name = p_name_new,
               mpv_order = p_order_new
         WHERE     mpv_mes = p_mes
               AND NVL (mpv_value, '~') = NVL (p_value_old, '~')
               AND NVL (mpv_tp, '~') = NVL (p_tp_old, '~')
               AND NVL (mpv_name, '~') = NVL (p_name_old, '~')
               AND mpv_order = NVL (p_order_old, mpv_order);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO msgep$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.EditParam',
                                               CHR (10) || SQLERRM));
    END;

    ----------------------------------------
    -- YURA_A 10.02.2005 13:21:18
    ----------------------------------------
    -- Назначение : Добавить подписчика к сообщению
    -- Параметры  : указывать ИД сообщение и ИД пользователя из ikis_users_attr
    PROCEDURE AddSubscr (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 )
    IS
        l_org   msg$subscraber.ms_iusr_org%TYPE;
        l_cnt   NUMBER;
    BEGIN
        SAVEPOINT msgas$one;
        l_org := NVL (p_iusr_org, ikis_common.GetAP_IKIS_OPFU);

        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_users_attr d
         WHERE     d.iusr_id = p_iusr_id
               AND d.iusr_org = l_org
               AND d.iusr_st IN
                       (ikis_const.v_dds_user_st_A,
                        ikis_const.v_dds_user_st_L);

        IF l_cnt = 1
        THEN
            INSERT INTO msg$subscraber (ms_id,
                                        ms_iusr_id,
                                        ms_mes,
                                        ms_iusr_org,
                                        ms_st,
                                        ms_st_dt)
                 VALUES (0,
                         p_iusr_id,
                         p_mes,
                         l_org,
                         ikis_const.v_dds_msg_st_N,
                         SYSDATE);
        ELSE
            RAISE exNotActiveUser;
        END IF;
    EXCEPTION
        WHEN exNotActiveUser
        THEN
            ROLLBACK TO msgas$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActiveUser));
        WHEN OTHERS
        THEN
            ROLLBACK TO msgas$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.AddSubscr',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE ReNewSubscr (
        p_mes        msg$subscraber.ms_mes%TYPE,
        p_iusr_id    msg$subscraber.ms_iusr_id%TYPE,
        p_iusr_org   msg$subscraber.ms_iusr_org%TYPE DEFAULT NULL -- если нулл то ставится текущий ОПФУ (закладка на репликацию)
                                                                 )
    IS
        l_org   msg$subscraber.ms_iusr_org%TYPE;
        l_cnt   NUMBER;
    BEGIN
        SAVEPOINT msgrns$one;
        l_org := NVL (p_iusr_org, ikis_common.GetAP_IKIS_OPFU);

        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_users_attr d
         WHERE     d.iusr_id = p_iusr_id
               AND d.iusr_org = l_org
               AND d.iusr_st IN
                       (ikis_const.v_dds_user_st_A,
                        ikis_const.v_dds_user_st_L);

        IF l_cnt = 1
        THEN
            UPDATE msg$subscraber
               SET ms_st = ikis_const.v_dds_msg_st_N
             WHERE     ms_iusr_id = p_iusr_id
                   AND ms_mes = p_mes
                   AND ms_iusr_org =
                       CASE
                           WHEN p_iusr_org IS NULL
                           THEN
                               TO_CHAR (ikis_common.GetAP_IKIS_OPFU)
                           ELSE
                               TO_CHAR (p_iusr_org)
                       END;
        ELSE
            RAISE exNotActiveUser;
        END IF;
    EXCEPTION
        WHEN exNotActiveUser
        THEN
            ROLLBACK TO msgrns$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActiveUser));
        WHEN OTHERS
        THEN
            ROLLBACK TO msgrns$one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_MESSENGER.ReNewSubscr',
                                               CHR (10) || SQLERRM));
    END;


    PROCEDURE CancelMessage (p_mes msg$subscraber.ms_mes%TYPE)
    IS
    BEGIN
        SAVEPOINT CM_sp1;

        FOR curSub
            IN (SELECT *
                  FROM msg$subscraber
                 WHERE     ms_mes = p_mes
                       AND NOT ms_st = ikis_const.v_dds_msg_st_E)
        LOOP
            UPDATE msg$subscraber
               SET ms_st = ikis_const.v_dds_msg_st_C, ms_st_dt = SYSDATE
             WHERE ms_id = curSub.ms_id;
        END LOOP;

        INSERT INTO msg$message_hst (mh_id,
                                     mh_st,
                                     mh_ms,
                                     mh_st_dt)
             VALUES (0,
                     ikis_const.v_dds_msg_st_C,
                     NULL,
                     SYSDATE);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO CM_sp1;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_MESSENGER.CancelMessage',
                    CHR (10) || SQLERRM));
    END;
END IKIS_MESSENGER;
/