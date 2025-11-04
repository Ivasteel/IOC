/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$CP_MESSAGE
IS
    -- Author  : BOGDAN
    -- Created : 29.09.2023 14:36:06
    -- Purpose : Листування

    -- #92545: вхідні повідомлення
    PROCEDURE get_OPFU_messages (res_cur OUT SYS_REFCURSOR);

    PROCEDURE set_readed (p_cmp_id IN NUMBER);

    -- #92545: картка повідомлення
    PROCEDURE get_message_card (p_cmp_id   IN     NUMBER,
                                root_cur      OUT SYS_REFCURSOR,
                                tree_cur      OUT SYS_REFCURSOR);

    -- #92545: Створити вихідне повідомлення
    PROCEDURE Create_CP_MESSAGE (
        p_CPM_ID                 CP_MESSAGE.CPM_ID%TYPE,
        p_CPM_RECIPIENT_TP       CP_MESSAGE.CPM_RECIPIENT_TP%TYPE,
        p_CPM_RECIPIENT_ID       CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        /* p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE,
         p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,*/
        p_CPM_TOPIC              CP_MESSAGE.CPM_TOPIC%TYPE,
        p_CPM_MESSAGE            CP_MESSAGE.CPM_MESSAGE%TYPE,
        p_CPM_HEADERS            CP_MESSAGE.CPM_HEADERS%TYPE,
        p_New_Id             OUT CP_MESSAGE.CPM_ID%TYPE);
END DNET$CP_MESSAGE;
/


GRANT EXECUTE ON USS_PERSON.DNET$CP_MESSAGE TO DNET_PROXY
/

GRANT EXECUTE ON USS_PERSON.DNET$CP_MESSAGE TO II01RC_USS_PERSON_WEB
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$CP_MESSAGE
IS
    -- #92545: вхідні повідомлення
    PROCEDURE get_OPFU_messages (res_cur OUT SYS_REFCURSOR)
    IS
        l_wu    NUMBER := tools.GetCurrWu;
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        OPEN res_cur FOR
              SELECT t.*,
                     stp.DIC_NAME
                         AS cpm_sender_tp_name,
                     api$cp_message.Get_S_R_name (t.cpm_sender_tp,
                                                  t.cpm_sender_id)
                         AS cpm_sender_name,
                     (SELECT COUNT (*)
                        FROM cp_message z
                       WHERE (z.cpm_cpm_root = t.cpm_id OR z.cpm_id = t.cpm_id))
                         AS all_messages,        -- всього повідомлень в гілці
                     (SELECT COUNT (*)
                        FROM cp_message z
                       WHERE     (   z.cpm_cpm_root = t.cpm_id
                                  OR z.cpm_id = t.cpm_id)
                             AND NOT EXISTS
                                     (SELECT *
                                        FROM cp_reandings r
                                       WHERE     r.cpr_cpm = z.cpm_id
                                             AND r.cpr_readers_tp = 'WU'
                                             AND r.cpr_readers_id = l_wu))
                         AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_SNDR_TP stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               WHERE     (    t.cpm_recipient_id = l_org
                          AND t.cpm_recipient_tp = 'OPFU'/*or t.cpm_recipient_id = l_wu
                                                         AND t.cpm_recipient_tp = 'WU'*/
                                                         )
                     AND t.history_status = 'A'
                     AND t.cpm_cpm_prev IS NULL
            ORDER BY t.cpm_create_dt DESC;
    END;

    PROCEDURE set_readed (p_cmp_id IN NUMBER)
    IS
        l_wu    NUMBER := tools.GetCurrWu;
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM cp_reandings t
         WHERE     t.cpr_cpm = p_cmp_id
               AND t.cpr_readers_tp = 'WU'
               AND t.cpr_readers_id = l_Wu;

        IF (l_cnt = 0)
        THEN
            INSERT INTO cp_reandings t (cpr_readers_tp,
                                        cpr_readers_id,
                                        cpr_read_dt,
                                        cpr_cpm)
                 VALUES ('WU',
                         l_Wu,
                         SYSDATE,
                         p_cmp_id);
        END IF;
    END;

    -- #92545: картка повідомлення
    PROCEDURE get_message_card (p_cmp_id   IN     NUMBER,
                                root_cur      OUT SYS_REFCURSOR,
                                tree_cur      OUT SYS_REFCURSOR)
    IS
        l_wu   NUMBER := tools.getcurrwu;
    BEGIN
        -- встановлення ознаки прочитано
        set_readed (p_cmp_id);

        /*    OPEN res_cur FOR
              SELECT t.*,
                     rtp.DIC_NAME AS cpm_recipient_tp_name,
                     api$cp_message.Get_S_R_name(t.cpm_recipient_tp, t.cpm_recipient_id) AS cpm_recipient_name,
                     stp.DIC_NAME AS cpm_sender_tp_name,
                     api$cp_message.Get_S_R_name(t.cpm_sender_tp, t.cpm_sender_id) AS cpm_sender_name
                FROM cp_message t
                JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
                JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
               WHERE t.cpm_id = p_cmp_id
                 AND t.history_status = 'A'
                 AND t.cpm_cpm_prev IS NULL
               ORDER BY t.cpm_create_dt DESC;
               */
        OPEN root_cur FOR
              SELECT t.cpm_id,
                     t.cpm_cpm_root,
                     t.cpm_sender_tp,
                     t.cpm_sender_id,
                     stp.DIC_NAME
                         AS cpm_sender_tp_name,
                     api$cp_message.Get_S_R_name (t.cpm_sender_tp,
                                                  t.cpm_sender_id)
                         AS cpm_sender_name,
                     t.cpm_recipient_tp,
                     t.cpm_recipient_id,
                     t.cpm_topic,
                     t.cpm_message,
                     t.cpm_create_dt,
                     t.cpm_send_dt,
                     t.cpm_obj_tp,
                     t.cpm_obj_id
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_SNDR_TP stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               /*JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)*/
               WHERE     t.cpm_id = p_cmp_id
                     AND t.cpm_cpm_prev IS NULL
                     AND t.history_status = 'A'
            ORDER BY t.cpm_create_dt DESC;

        OPEN tree_cur FOR
              SELECT t.*,
                     rtp.DIC_NAME
                         AS cpm_recipient_tp_name,
                     api$cp_message.Get_S_R_name (
                         t.cpm_recipient_tp,
                         t.cpm_recipient_id)
                         AS cpm_recipient_name,
                     stp.DIC_NAME
                         AS cpm_sender_tp_name,
                     api$cp_message.Get_S_R_name (t.cpm_sender_tp,
                                                  t.cpm_sender_id)
                         AS cpm_sender_name,
                     CASE (SELECT COUNT (*)
                             FROM cp_reandings r
                            WHERE     r.cpr_cpm = t.cpm_id
                                  AND r.cpr_readers_tp = 'WU'
                                  AND r.cpr_readers_id = l_wu)
                         WHEN 0
                         THEN
                             'F'
                         ELSE
                             'T'
                     END
                         AS is_readed
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_SNDR_TP stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
                     LEFT JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp
                         ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
               WHERE t.cpm_cpm_root = p_cmp_id AND t.history_status = 'A'
            ORDER BY t.cpm_create_dt DESC;
    END;

    --====================================================--
    --   Збереження повідомлення
    --====================================================--
    PROCEDURE Save_CP_MESSAGE (
        p_CPM_ID                   CP_MESSAGE.CPM_ID%TYPE,
        p_CPM_CPM_ROOT             CP_MESSAGE.CPM_CPM_ROOT%TYPE,
        p_CPM_CPM_PREV             CP_MESSAGE.CPM_CPM_PREV%TYPE,
        p_CPM_SENDER_TP            CP_MESSAGE.CPM_SENDER_TP%TYPE,
        p_CPM_SENDER_ID            CP_MESSAGE.CPM_SENDER_ID%TYPE,
        p_CPM_RECIPIENT_TP         CP_MESSAGE.CPM_RECIPIENT_TP%TYPE,
        p_CPM_RECIPIENT_ID         CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        p_CPM_ROOT_SENDER_TP       CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE,
        p_CPM_ROOT_SENDER_ID       CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
        p_CPM_CREATE_DT            CP_MESSAGE.CPM_CREATE_DT%TYPE,
        p_CPM_SEND_DT              CP_MESSAGE.CPM_SEND_DT%TYPE,
        p_CPM_TOPIC                CP_MESSAGE.CPM_TOPIC%TYPE,
        p_CPM_MESSAGE              CP_MESSAGE.CPM_MESSAGE%TYPE,
        p_CPM_OBJ_TP               CP_MESSAGE.CPM_OBJ_TP%TYPE,
        p_CPM_OBJ_ID               CP_MESSAGE.CPM_OBJ_ID%TYPE,
        p_CPM_ROOT_OBJ_TP          CP_MESSAGE.CPM_ROOT_OBJ_TP%TYPE,
        p_CPM_ROOT_OBJ_ID          CP_MESSAGE.CPM_ROOT_OBJ_ID%TYPE,
        p_HISTORY_STATUS           CP_MESSAGE.HISTORY_STATUS%TYPE,
        p_CPM_HEADERS              CP_MESSAGE.CPM_HEADERS%TYPE,
        p_New_Id               OUT CP_MESSAGE.CPM_ID%TYPE)
    IS
    BEGIN
        api$cp_message.Save_CP_MESSAGE (
            p_CPM_ID               => p_CPM_ID,
            p_CPM_CPM_ROOT         => p_CPM_CPM_ROOT,
            p_CPM_CPM_PREV         => p_CPM_CPM_PREV,
            p_CPM_SENDER_TP        => p_CPM_SENDER_TP,
            p_CPM_SENDER_ID        => p_CPM_SENDER_ID,
            p_CPM_RECIPIENT_TP     => p_CPM_RECIPIENT_TP,
            p_CPM_RECIPIENT_ID     => p_CPM_RECIPIENT_ID,
            p_CPM_ROOT_SENDER_TP   => p_CPM_ROOT_SENDER_TP,
            p_CPM_ROOT_SENDER_ID   => p_CPM_ROOT_SENDER_ID,
            p_CPM_CREATE_DT        => p_CPM_CREATE_DT,
            p_CPM_SEND_DT          => p_CPM_SEND_DT,
            p_CPM_TOPIC            => p_CPM_TOPIC,
            p_CPM_MESSAGE          => p_CPM_MESSAGE,
            p_CPM_OBJ_TP           => p_CPM_OBJ_TP,
            p_CPM_OBJ_ID           => p_CPM_OBJ_ID,
            p_CPM_ROOT_OBJ_TP      => p_CPM_ROOT_OBJ_TP,
            p_CPM_ROOT_OBJ_ID      => p_CPM_ROOT_OBJ_ID,
            p_HISTORY_STATUS       => p_HISTORY_STATUS,
            p_CPM_HEADERS          => p_CPM_HEADERS,
            p_New_Id               => p_New_Id);
    END;

    -- #92545: Створити вихідне повідомлення
    PROCEDURE Create_CP_MESSAGE (
        p_CPM_ID                 CP_MESSAGE.CPM_ID%TYPE,
        p_CPM_RECIPIENT_TP       CP_MESSAGE.CPM_RECIPIENT_TP%TYPE,
        p_CPM_RECIPIENT_ID       CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        /* p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE,
         p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,*/
        p_CPM_TOPIC              CP_MESSAGE.CPM_TOPIC%TYPE,
        p_CPM_MESSAGE            CP_MESSAGE.CPM_MESSAGE%TYPE,
        p_CPM_HEADERS            CP_MESSAGE.CPM_HEADERS%TYPE,
        p_New_Id             OUT CP_MESSAGE.CPM_ID%TYPE)
    IS
        l_row   cp_message%ROWTYPE;
        l_wu    NUMBER := tools.GetCurrWu;
    BEGIN
        IF (p_CPM_RECIPIENT_ID IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Потрібно заповнити отримувача повідомлення!');
        END IF;

        IF (p_cpm_id IS NOT NULL)
        THEN
            SELECT *
              INTO l_row
              FROM cp_message t
             WHERE t.cpm_id = p_CPM_ID;

            l_row.cpm_cpm_root := NVL (l_row.cpm_cpm_root, p_CPM_ID);
            l_row.cpm_root_sender_tp :=
                NVL (l_row.cpm_root_sender_tp, l_row.cpm_sender_tp);
            l_row.cpm_root_sender_id :=
                NVL (l_row.cpm_root_sender_id, l_row.cpm_sender_id);
            l_row.cpm_root_obj_tp :=
                NVL (l_row.cpm_root_obj_tp, l_row.cpm_obj_tp);
            l_row.cpm_root_obj_id :=
                NVL (l_row.cpm_root_obj_id, l_row.cpm_obj_id);
            l_row.cpm_cpm_prev := p_CPM_ID;
        ELSE
            l_row.cpm_root_sender_tp := 'WU';
            l_row.cpm_root_sender_id := l_wu;
        END IF;

        api$cp_message.Save_CP_MESSAGE (
            p_CPM_ID               => NULL,
            p_CPM_CPM_ROOT         => l_row.cpm_cpm_root,
            p_CPM_CPM_PREV         => l_row.cpm_cpm_prev,
            p_CPM_SENDER_TP        => 'WU',
            p_CPM_SENDER_ID        => l_wu,
            p_CPM_RECIPIENT_TP     => p_CPM_RECIPIENT_TP,
            p_CPM_RECIPIENT_ID     => p_CPM_RECIPIENT_ID,
            p_CPM_ROOT_SENDER_TP   => l_row.cpm_root_sender_tp,
            p_CPM_ROOT_SENDER_ID   => l_row.cpm_root_sender_id,
            p_CPM_CREATE_DT        => SYSDATE,
            p_CPM_SEND_DT          => SYSDATE,
            p_CPM_TOPIC            => p_CPM_TOPIC,
            p_CPM_MESSAGE          => p_CPM_MESSAGE,
            p_CPM_OBJ_TP           => l_row.cpm_obj_tp,
            p_CPM_OBJ_ID           => l_row.cpm_obj_id,
            p_CPM_ROOT_OBJ_TP      => l_row.cpm_root_obj_tp,
            p_CPM_ROOT_OBJ_ID      => l_row.cpm_root_obj_id,
            p_HISTORY_STATUS       => 'A',
            p_CPM_HEADERS          => p_CPM_HEADERS,
            p_New_Id               => p_New_Id);


        -- встановлення ознаки прочитано
        set_readed (p_new_id);
    END;
BEGIN
    NULL;
END DNET$CP_MESSAGE;
/