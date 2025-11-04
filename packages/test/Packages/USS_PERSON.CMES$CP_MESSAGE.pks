/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.CMES$CP_MESSAGE
IS
    -- Author  : BOGDAN
    -- Created : 04.10.2023 15:53:29
    -- Purpose : АПІ листування для кабінетів отримувачів

    -- #92545: реєстр повідомлень для отримувача СП в межах сутності
    PROCEDURE get_obj_FO_messages (
        p_cpm_obj_tp   IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id   IN     cp_message.cpm_obj_id%TYPE,
        res_cur           OUT SYS_REFCURSOR);

    --“Отримувач” (елемент список з множиною значень “ОСЗН”, “Надавач СП”),
    --“Дата відправки листа” (елемент “дата”),
    --ознака “Непрочитані” (елемент ChekBox).
    -- #92545: реєстр повідомлень для отримувача СП
    PROCEDURE get_FO_messages (
        p_cpm_recipient_tp   IN     cp_message.cpm_recipient_tp%TYPE,
        p_cpm_recipient_id   IN     cp_message.cpm_recipient_id%TYPE,
        p_cpm_send_dt        IN     cp_message.cpm_send_dt%TYPE,
        p_has_unread         IN     VARCHAR2,                           -- T/F
        res_cur                 OUT SYS_REFCURSOR);

    --“Відправник” (елемент список з множиною значень “Отримувач СП”, “Кейс-менеджер”)
    --“Дата відправки листа” (елемент “дата”),
    --ознака “Непрочитані” (елемент ChekBox).
    -- #92545: реєстр повідомлень для надавача СП
    PROCEDURE get_NSP_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_sender_tp   IN     cp_message.cpm_sender_tp%TYPE,
        p_cpm_sender_id   IN     cp_message.cpm_sender_id%TYPE,
        p_cpm_send_dt     IN     cp_message.cpm_send_dt%TYPE,
        p_has_unread      IN     VARCHAR2,                              -- T/F
        res_cur              OUT SYS_REFCURSOR);

    -- #92545: реєстр повідомлень для надавача СП в межах сутності
    PROCEDURE get_obj_NSP_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_obj_tp      IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id      IN     cp_message.cpm_obj_id%TYPE,
        res_cur              OUT SYS_REFCURSOR);

    -- #92545: реєстр повідомлень для Кейс менеджера
    PROCEDURE get_Cm_messages (p_Cmes_Owner_Id   IN     NUMBER,
                               res_cur              OUT SYS_REFCURSOR);

    -- #92545: реєстр повідомлень для Кейс менеджера в межах сутності
    PROCEDURE get_obj_Cm_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_obj_tp      IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id      IN     cp_message.cpm_obj_id%TYPE,
        res_cur              OUT SYS_REFCURSOR);

    -- встановлення ознаки прочитано на повідомлення
    -- потрібно викликати при будь-якому відкритті листа в гілці листів.
    -- для рутового проставляється при відкритті основної картки автоматично
    PROCEDURE set_readed (p_cmp_id IN NUMBER, p_usr_tp IN VARCHAR2 -- константа: ОСП - SC, НСП - CU_NSP, КМ - CU_KM
                                                                  );

    -- #92545: картка повідомлення
    PROCEDURE get_message_card (p_cmp_id     IN     NUMBER,
                                p_usr_tp     IN     VARCHAR2, -- константа: ОСП - SC, НСП - CU_NSP, КМ - CU_KM
                                p_root_cur      OUT SYS_REFCURSOR, -- дані по рутовому листу
                                p_tree_cur      OUT SYS_REFCURSOR -- всі листи в цій гілці
                                                                 );

    -- #92545: Створити нове вихідне повідомлення або відповідь на поточне повідомлення
    PROCEDURE Create_CP_MESSAGE (
        p_CPM_ID                    CP_MESSAGE.CPM_ID%TYPE, -- ід поточного повідомлення
        p_CPM_RECIPIENT_TP          CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
        p_CPM_RECIPIENT_ID          CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        --p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
        --p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
        p_CPM_TOPIC                 CP_MESSAGE.CPM_TOPIC%TYPE,
        p_CPM_MESSAGE               CP_MESSAGE.CPM_MESSAGE%TYPE,
        p_CPM_HEADERS               CP_MESSAGE.CPM_HEADERS%TYPE,
        p_CPM_OBJ_TP                CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
        p_CPM_OBJ_ID                CP_MESSAGE.CPM_OBJ_ID%TYPE,
        p_usr_tp             IN     VARCHAR2, -- константа: ОСП - SC, НСП - CU_NSP, КМ - CU_KM
        p_New_Id                OUT CP_MESSAGE.CPM_ID%TYPE);
-- todo: delete
/*-- #92326: вхідні повідомлення
PROCEDURE get_input_messages (res_cur OUT SYS_REFCURSOR);

-- #92545: вхідні повідомлення (для НСП)
PROCEDURE get_input_messages_Pr (p_Cmes_Owner_Id IN NUMBER,
                                 res_cur OUT SYS_REFCURSOR);

-- #92545: вхідні повідомлення по сутності
PROCEDURE get_obj_input_messages (p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                  p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                  res_cur OUT SYS_REFCURSOR);

-- #92545: вхідні повідомлення по сутності (для НСП)
PROCEDURE get_obj_input_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                     p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                     p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                     res_cur OUT SYS_REFCURSOR);

-- #92545: вихідні повідомлення
PROCEDURE get_output_messages (res_cur OUT SYS_REFCURSOR);

-- #92545: вихідні повідомлення (для НСП)
PROCEDURE get_output_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                  res_cur OUT SYS_REFCURSOR);

 -- #92545: вихідні повідомлення по сутності
PROCEDURE get_obj_output_messages (p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                   p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                   res_cur OUT SYS_REFCURSOR);

-- #92545: вихідні повідомлення по сутності (для НСП)
PROCEDURE get_obj_output_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                      p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                      p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                      res_cur OUT SYS_REFCURSOR);

-- #92545: картка повідомлення
PROCEDURE get_message_card (p_cmp_id IN number,
                            res_cur OUT SYS_REFCURSOR);

-- #92545: картка повідомлення (для НСП)
PROCEDURE get_message_card_pr (p_cmp_id IN number,
                               p_Cmes_Owner_Id IN NUMBER,
                               res_cur OUT SYS_REFCURSOR);

-- #92545: Створити вихідне повідомлення
PROCEDURE Create_CP_MESSAGE(p_CPM_ID              CP_MESSAGE.CPM_ID%TYPE,
                            p_CPM_RECIPIENT_TP    CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
                            p_CPM_RECIPIENT_ID    CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
                            p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
                            p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
                            p_CPM_TOPIC           CP_MESSAGE.CPM_TOPIC%TYPE,
                            p_CPM_MESSAGE         CP_MESSAGE.CPM_MESSAGE%TYPE,
                            p_CPM_HEADERS         CP_MESSAGE.CPM_HEADERS%TYPE,
                            p_CPM_OBJ_TP          CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
                            p_CPM_OBJ_ID          CP_MESSAGE.CPM_OBJ_ID%TYPE,
                            p_New_Id          OUT CP_MESSAGE.CPM_ID%TYPE);

-- #92545: Створити вихідне повідомлення (для НСП)
PROCEDURE Create_CP_MESSAGE_Pr(p_Cmes_Owner_Id       IN NUMBER,
                               p_CPM_ID              CP_MESSAGE.CPM_ID%TYPE,
                               p_CPM_RECIPIENT_TP    CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
                               p_CPM_RECIPIENT_ID    CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
                               p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
                               p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
                               p_CPM_TOPIC           CP_MESSAGE.CPM_TOPIC%TYPE,
                               p_CPM_MESSAGE         CP_MESSAGE.CPM_MESSAGE%TYPE,
                               p_CPM_HEADERS         CP_MESSAGE.CPM_HEADERS%TYPE,
                               p_CPM_OBJ_TP          CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
                               p_CPM_OBJ_ID          CP_MESSAGE.CPM_OBJ_ID%TYPE,
                               p_New_Id          OUT CP_MESSAGE.CPM_ID%TYPE);*/

END CMES$CP_MESSAGE;
/


GRANT EXECUTE ON USS_PERSON.CMES$CP_MESSAGE TO II01RC_USS_PERSON_PORTAL
/

GRANT EXECUTE ON USS_PERSON.CMES$CP_MESSAGE TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.CMES$CP_MESSAGE
IS
    -- #92545: реєстр повідомлень для отримувача СП в межах сутності
    PROCEDURE get_obj_FO_messages (
        p_cpm_obj_tp   IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id   IN     cp_message.cpm_obj_id%TYPE,
        res_cur           OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_sc   NUMBER := ikis_rbm.tools.GetCuSc (l_cu);
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
                                             AND r.cpr_readers_tp = 'SC'
                                             AND r.cpr_readers_id = l_sc))
                         AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                FROM cp_message t
                     --JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
                     JOIN uss_ndi.V_DDN_CP_USER_TP stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               WHERE     t.cpm_sender_id = l_sc
                     AND t.cpm_sender_tp = 'SC'
                     AND t.cpm_obj_tp = p_cpm_obj_tp
                     AND t.cpm_obj_id = p_cpm_obj_id
                     AND t.history_status = 'A'
                     AND t.cpm_cpm_prev IS NULL
            ORDER BY t.cpm_create_dt DESC;
    END;

    --“Отримувач” (елемент список з множиною значень “ОСЗН”, “Надавач СП”),
    --“Дата відправки листа” (елемент “дата”),
    --ознака “Непрочитані” (елемент ChekBox).
    -- #92545: реєстр повідомлень для отримувача СП
    PROCEDURE get_FO_messages (
        p_cpm_recipient_tp   IN     cp_message.cpm_recipient_tp%TYPE,
        p_cpm_recipient_id   IN     cp_message.cpm_recipient_id%TYPE,
        p_cpm_send_dt        IN     cp_message.cpm_send_dt%TYPE,
        p_has_unread         IN     VARCHAR2,                           -- T/F
        res_cur                 OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_sc   NUMBER := ikis_rbm.tools.GetCuSc (l_cu);
    BEGIN
        OPEN res_cur FOR
              SELECT t.*
                FROM (SELECT t.*,
                             stp.DIC_NAME
                                 AS cpm_sender_tp_name,
                             api$cp_message.Get_S_R_name (t.cpm_sender_tp,
                                                          t.cpm_sender_id)
                                 AS cpm_sender_name,
                             (SELECT COUNT (*)
                                FROM cp_message z
                               WHERE (   z.cpm_cpm_root = t.cpm_id
                                      OR z.cpm_id = t.cpm_id))
                                 AS all_messages, -- всього повідомлень в гілці
                             (SELECT COUNT (*)
                                FROM cp_message z
                               WHERE     (   z.cpm_cpm_root = t.cpm_id
                                          OR z.cpm_id = t.cpm_id)
                                     AND NOT EXISTS
                                             (SELECT *
                                                FROM cp_reandings r
                                               WHERE     r.cpr_cpm = z.cpm_id
                                                     AND r.cpr_readers_tp =
                                                         'SC'
                                                     AND r.cpr_readers_id =
                                                         l_sc))
                                 AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                        FROM cp_message t
                             JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                           stp
                                 ON (stp.DIC_VALUE = t.cpm_sender_tp)
                       WHERE     t.cpm_sender_id = l_sc
                             AND t.cpm_sender_tp = 'SC'
                             AND t.history_status = 'A'
                             AND t.cpm_cpm_prev IS NULL
                             AND t.cpm_recipient_tp =
                                 NVL (p_cpm_recipient_tp, t.cpm_recipient_tp)
                             AND t.cpm_recipient_id =
                                 NVL (p_cpm_recipient_id, t.cpm_recipient_id)
                             AND TRUNC (t.cpm_send_dt) =
                                 TRUNC (NVL (p_cpm_send_dt, t.cpm_send_dt))) t
               WHERE     1 = 1
                     AND (   p_has_unread = 'F'
                          OR p_has_unread = 'T' AND t.not_read_messages > 0)
            ORDER BY cpm_create_dt DESC;
    END;

    --“Відправник” (елемент список з множиною значень “Отримувач СП”, “Кейс-менеджер”)
    --“Дата відправки листа” (елемент “дата”),
    --ознака “Непрочитані” (елемент ChekBox).
    -- #92545: реєстр повідомлень для надавача СП
    PROCEDURE get_NSP_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_sender_tp   IN     cp_message.cpm_sender_tp%TYPE,
        p_cpm_sender_id   IN     cp_message.cpm_sender_id%TYPE,
        p_cpm_send_dt     IN     cp_message.cpm_send_dt%TYPE,
        p_has_unread      IN     VARCHAR2,                              -- T/F
        res_cur              OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
    BEGIN
        OPEN res_cur FOR
              SELECT t.*
                FROM (SELECT t.*,
                             stp.DIC_NAME
                                 AS cpm_sender_tp_name,
                             api$cp_message.Get_S_R_name (t.cpm_sender_tp,
                                                          t.cpm_sender_id)
                                 AS cpm_sender_name,
                             (SELECT COUNT (*)
                                FROM cp_message z
                               WHERE (   z.cpm_cpm_root = t.cpm_id
                                      OR z.cpm_id = t.cpm_id))
                                 AS all_messages, -- всього повідомлень в гілці
                             (SELECT COUNT (*)
                                FROM cp_message z
                               WHERE     (   z.cpm_cpm_root = t.cpm_id
                                          OR z.cpm_id = t.cpm_id)
                                     AND NOT EXISTS
                                             (SELECT *
                                                FROM cp_reandings r
                                               WHERE     r.cpr_cpm = z.cpm_id
                                                     AND r.cpr_readers_tp =
                                                         'CU_NSP'
                                                     AND r.cpr_readers_id =
                                                         l_cu))
                                 AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                        FROM cp_message t
                             JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                           stp
                                 ON (stp.DIC_VALUE = t.cpm_sender_tp)
                       WHERE     t.cpm_recipient_id = p_Cmes_Owner_Id
                             AND t.cpm_recipient_tp = 'NSP'
                             AND t.history_status = 'A'
                             AND t.cpm_cpm_prev IS NULL
                             AND t.cpm_sender_tp =
                                 NVL (p_cpm_sender_tp, t.cpm_sender_tp)
                             AND t.cpm_sender_id =
                                 NVL (p_cpm_sender_id, t.cpm_sender_id)
                             AND TRUNC (t.cpm_send_dt) =
                                 TRUNC (NVL (p_cpm_send_dt, t.cpm_send_dt))) t
               WHERE     1 = 1
                     AND (   p_has_unread = 'F'
                          OR p_has_unread = 'T' AND t.not_read_messages > 0)
            ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: реєстр повідомлень для надавача СП в межах сутності
    PROCEDURE get_obj_NSP_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_obj_tp      IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id      IN     cp_message.cpm_obj_id%TYPE,
        res_cur              OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
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
                                             AND r.cpr_readers_tp = 'CU_NSP'
                                             AND r.cpr_readers_id = l_cu))
                         AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                   stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               WHERE     t.cpm_recipient_id = p_Cmes_Owner_Id
                     AND t.cpm_recipient_tp = 'NSP'
                     AND t.history_status = 'A'
                     AND t.cpm_cpm_prev IS NULL
                     AND t.cpm_obj_tp = p_cpm_obj_tp
                     AND t.cpm_obj_id = p_cpm_obj_id
            ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: реєстр повідомлень для Кейс менеджера
    PROCEDURE get_Cm_messages (p_Cmes_Owner_Id   IN     NUMBER,
                               res_cur              OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
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
                                             AND r.cpr_readers_tp = 'CU_KM'
                                             AND r.cpr_readers_id = l_cu))
                         AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                   stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               WHERE     t.cpm_recipient_id = p_Cmes_Owner_Id
                     AND t.cpm_recipient_tp = 'NSP'
                     AND t.history_status = 'A'
                     AND t.cpm_cpm_prev IS NULL
            ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: реєстр повідомлень для Кейс менеджера в межах сутності
    PROCEDURE get_obj_Cm_messages (
        p_Cmes_Owner_Id   IN     NUMBER,
        p_cpm_obj_tp      IN     cp_message.cpm_obj_tp%TYPE,
        p_cpm_obj_id      IN     cp_message.cpm_obj_id%TYPE,
        res_cur              OUT SYS_REFCURSOR)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
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
                                             AND r.cpr_readers_tp = 'CU_KM'
                                             AND r.cpr_readers_id = l_cu))
                         AS not_read_messages -- з них непрочитаних поточним користувачем. якщо це число > 0 то позначати повідомлення як не прочитане
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                   stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
               WHERE     t.cpm_recipient_id = p_Cmes_Owner_Id
                     AND t.cpm_recipient_tp = 'NSP'
                     AND t.history_status = 'A'
                     AND t.cpm_cpm_prev IS NULL
                     AND t.cpm_obj_tp = p_cpm_obj_tp
                     AND t.cpm_obj_id = p_cpm_obj_id
            ORDER BY t.cpm_create_dt DESC;
    END;

    -- TODO: delete
    /*-- #92545: вхідні повідомлення
    PROCEDURE get_input_messages (res_cur OUT SYS_REFCURSOR)
    IS
      l_cu NUMBER := ikis_rbm.tools.GetCurrentCu;
      l_sc NUMBER := ikis_rbm.tools.GetCuSc(l_cu);
    BEGIN
      uss_esr.api$find.get_sc_rnspm_list(l_sc);

      OPEN res_cur FOR
        SELECT t.*,
               stp.DIC_NAME AS cpm_sender_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_sender_tp, t.cpm_sender_id) AS cpm_sender_name,
               r.cpr_id -- ознака прочитаного повідомлення
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
          LEFT JOIN cp_reandings r ON (r.cpr_cpm = t.cpm_id AND r.cpr_readers_id = t.cpm_recipient_id AND r.cpr_readers_tp = 'CU')
         WHERE (t.cpm_recipient_id = l_cu AND t.cpm_recipient_tp = 'CU'
                OR t.cpm_recipient_tp = 'NSP' AND t.cpm_recipient_id IN (SELECT x_id1 FROM uss_esr.tmp_work_set1)
               )
           AND t.history_status = 'A'
         ORDER BY decode(r.cpr_read_dt, NULL, 1, 2), t.cpm_create_dt DESC;
    END;

    -- #92545: вхідні повідомлення (для НСП)
    PROCEDURE get_input_messages_Pr (p_Cmes_Owner_Id IN NUMBER,
                                     res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               stp.DIC_NAME AS cpm_sender_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_sender_tp, t.cpm_sender_id) AS cpm_sender_name,
               r.cpr_id -- ознака прочитаного повідомлення
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
          LEFT JOIN cp_reandings r ON (r.cpr_cpm = t.cpm_id AND r.cpr_readers_id = t.cpm_recipient_id AND r.cpr_readers_tp = 'NSP')
         WHERE t.cpm_recipient_tp = 'NSP' AND t.cpm_recipient_id = p_Cmes_Owner_Id
           AND t.history_status = 'A'
         ORDER BY decode(r.cpr_read_dt, NULL, 1, 2), t.cpm_create_dt DESC;
    END;

    -- #92545: вхідні повідомлення по сутності
    PROCEDURE get_obj_input_messages (p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                      p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                      res_cur OUT SYS_REFCURSOR)
    IS
      l_cu NUMBER := ikis_rbm.tools.GetCurrentCu;
      l_sc NUMBER := ikis_rbm.tools.GetCuSc(l_cu);
    BEGIN
      uss_esr.api$find.get_sc_rnspm_list(l_sc);

      OPEN res_cur FOR
        SELECT t.*,
               stp.DIC_NAME AS cpm_sender_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_sender_tp, t.cpm_sender_id) AS cpm_sender_name,
               r.cpr_id -- ознака прочитаного повідомлення
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
          LEFT JOIN cp_reandings r ON (r.cpr_cpm = t.cpm_id AND r.cpr_readers_id = t.cpm_recipient_id AND r.cpr_readers_tp = 'CU')
         WHERE (t.cpm_recipient_id = l_cu AND t.cpm_recipient_tp = 'CU'
                OR t.cpm_recipient_tp = 'NSP' AND t.cpm_recipient_id IN (SELECT x_id1 FROM uss_esr.tmp_work_set1)
               )
           AND t.history_status = 'A'
           AND t.cpm_obj_tp = p_cpm_obj_tp
           AND t.cpm_obj_id = p_cpm_obj_id
         ORDER BY decode(r.cpr_read_dt, NULL, 1, 2), t.cpm_create_dt DESC;
    END;

    -- #92545: вхідні повідомлення по сутності (для НСП)
    PROCEDURE get_obj_input_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                         p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                         p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                         res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               stp.DIC_NAME AS cpm_sender_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_sender_tp, t.cpm_sender_id) AS cpm_sender_name,
               r.cpr_id -- ознака прочитаного повідомлення
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_SNDR_TP stp ON (stp.DIC_VALUE = t.cpm_sender_tp)
          LEFT JOIN cp_reandings r ON (r.cpr_cpm = t.cpm_id AND r.cpr_readers_id = t.cpm_recipient_id AND r.cpr_readers_tp = 'CU')
         WHERE t.cpm_recipient_tp = 'NSP' AND t.cpm_recipient_id = p_Cmes_Owner_Id
           AND t.history_status = 'A'
           AND t.cpm_obj_tp = p_cpm_obj_tp
           AND t.cpm_obj_id = p_cpm_obj_id
         ORDER BY decode(r.cpr_read_dt, NULL, 1, 2), t.cpm_create_dt DESC;
    END;

    -- #92545: вихідні повідомлення
    PROCEDURE get_output_messages (res_cur OUT SYS_REFCURSOR)
    IS
      l_cu NUMBER := ikis_rbm.tools.GetCurrentCu;
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               rtp.DIC_NAME AS cpm_recipient_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_recipient_tp, t.cpm_recipient_id) AS cpm_recipient_name
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
         WHERE t.cpm_sender_id = l_cu
           AND t.cpm_sender_tp = 'CU'
           AND t.history_status = 'A'
         ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: вихідні повідомлення (для НСП)
    PROCEDURE get_output_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                      res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               rtp.DIC_NAME AS cpm_recipient_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_recipient_tp, t.cpm_recipient_id) AS cpm_recipient_name
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
         WHERE t.cpm_sender_id = p_Cmes_Owner_Id
           AND t.cpm_sender_tp = 'NSP'
           AND t.history_status = 'A'
         ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: вихідні повідомлення по сутності
    PROCEDURE get_obj_output_messages (p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                       p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                       res_cur OUT SYS_REFCURSOR)
    IS
      l_cu NUMBER := ikis_rbm.tools.GetCurrentCu;
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               rtp.DIC_NAME AS cpm_recipient_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_recipient_tp, t.cpm_recipient_id) AS cpm_recipient_name
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
         WHERE t.cpm_sender_id = l_cu
           AND t.cpm_sender_tp = 'CU'
           AND t.history_status = 'A'
           AND t.cpm_obj_tp = p_cpm_obj_tp
           AND t.cpm_obj_id = p_cpm_obj_id
         ORDER BY t.cpm_create_dt DESC;
    END;

    -- #92545: вихідні повідомлення по сутності (для НСП)
    PROCEDURE get_obj_output_messages_pr (p_Cmes_Owner_Id IN NUMBER,
                                          p_cpm_obj_tp IN cp_message.cpm_obj_tp%TYPE,
                                          p_cpm_obj_id IN cp_message.cpm_obj_id%TYPE,
                                          res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
      OPEN res_cur FOR
        SELECT t.*,
               rtp.DIC_NAME AS cpm_recipient_tp_name,
               api$cp_message.Get_S_R_name(t.cpm_recipient_tp, t.cpm_recipient_id) AS cpm_recipient_name
          FROM cp_message t
          JOIN uss_ndi.V_DDN_CP_RCPNT_TP rtp ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
         WHERE t.cpm_sender_id = p_Cmes_Owner_Id
           AND t.cpm_sender_tp = 'NSP'
           AND t.history_status = 'A'
           AND t.cpm_obj_tp = p_cpm_obj_tp
           AND t.cpm_obj_id = p_cpm_obj_id
         ORDER BY t.cpm_create_dt DESC;
    END;
    */

    -- встановлення ознаки прочитано на повідомлення
    -- потрібно викликати при будь-якому відкритті листа в гілці листів.
    -- для рутового проставляється при відкритті основної картки автоматично
    PROCEDURE set_readed (p_cmp_id IN NUMBER, p_usr_tp IN VARCHAR2) -- константа: ОСП - SC, НСП - CU_NSP, КМ - CU_KM
    IS
        l_cu       NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_sc       NUMBER := ikis_rbm.tools.GetCuSc (l_cu);
        l_cnt      NUMBER;
        l_usr_tp   VARCHAR2 (10);
        l_usr_id   NUMBER;
    BEGIN
        l_usr_tp := p_usr_tp;

        IF (l_sc IS NOT NULL AND p_usr_tp = 'SC')
        THEN
            l_usr_id := l_sc;
        ELSE
            l_usr_id := l_cu;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM cp_reandings t
         WHERE     t.cpr_cpm = p_cmp_id
               AND t.cpr_readers_tp = l_usr_tp
               AND t.cpr_readers_id = l_usr_id;

        IF (l_cnt = 0)
        THEN
            INSERT INTO cp_reandings t (cpr_readers_tp,
                                        cpr_readers_id,
                                        cpr_read_dt,
                                        cpr_cpm)
                 VALUES (l_usr_tp,
                         l_usr_id,
                         SYSDATE,
                         p_cmp_id);
        END IF;
    END;

    /*PROCEDURE set_readed_pr(p_Cmes_Owner_Id IN number, p_cmp_id IN NUMBER)
    IS
      l_cnt NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO l_cnt
        FROM cp_reandings t
       WHERE t.cpr_cpm = p_cmp_id
         AND t.cpr_readers_tp = 'NSP'
         AND t.cpr_readers_id = p_Cmes_Owner_Id;

      IF (l_cnt = 0) THEN
        INSERT INTO cp_reandings t
        (cpr_readers_tp, cpr_readers_id, cpr_read_dt, cpr_cpm )
        VALUES
        ('NSP', p_Cmes_Owner_Id, SYSDATE, p_cmp_id);
      END IF;
    END;
    */


    -- #92545: картка повідомлення
    PROCEDURE get_message_card (p_cmp_id     IN     NUMBER,
                                p_usr_tp     IN     VARCHAR2, -- константа: ОСП - SC, НСП - CU_NSP, КМ - CU_KM
                                p_root_cur      OUT SYS_REFCURSOR, -- дані по рутовому листу
                                p_tree_cur      OUT SYS_REFCURSOR -- всі листи в цій гілці
                                                                 )
    IS
        l_cu       NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_sc       NUMBER := ikis_rbm.tools.GetCuSc (l_cu);
        l_usr_tp   VARCHAR2 (10);
        l_usr_id   NUMBER;
    BEGIN
        -- встановлення ознаки прочитано
        set_readed (p_cmp_id, p_usr_tp);

        l_usr_tp := p_usr_tp;

        IF (l_sc IS NOT NULL AND p_usr_tp = 'SC')
        THEN
            l_usr_id := l_sc;
        ELSE
            l_usr_id := l_cu;
        END IF;

        OPEN p_root_cur FOR
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
                     rtp.DIC_NAME
                         AS cpm_recipient_tp_name,
                     api$cp_message.Get_S_R_name (t.cpm_recipient_tp,
                                                  t.cpm_recipient_id)
                         AS cpm_recipient_name,
                     t.cpm_topic,
                     t.cpm_message,
                     t.cpm_create_dt,
                     t.cpm_send_dt,
                     t.cpm_obj_tp,
                     t.cpm_obj_id
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                   stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_RCPNT_TP*/
                                                   rtp
                         ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
               WHERE     t.cpm_id = p_cmp_id
                     AND t.cpm_cpm_prev IS NULL
                     AND t.history_status = 'A'
            ORDER BY t.cpm_create_dt DESC;

        OPEN p_tree_cur FOR
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
                                  AND r.cpr_readers_tp = l_usr_tp
                                  AND r.cpr_readers_id = l_usr_id)
                         WHEN 0
                         THEN
                             'F'
                         ELSE
                             'T'
                     END
                         AS is_readed
                FROM cp_message t
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_SNDR_TP*/
                                                   stp
                         ON (stp.DIC_VALUE = t.cpm_sender_tp)
                     JOIN uss_ndi.V_DDN_CP_USER_TP /*uss_ndi.V_DDN_CP_RCPNT_TP*/
                                                   rtp
                         ON (rtp.DIC_VALUE = t.cpm_recipient_tp)
               WHERE t.cpm_cpm_root = p_cmp_id AND t.history_status = 'A'
            ORDER BY t.cpm_create_dt DESC;
    END;


    /*
     -- #92545: картка повідомлення
     PROCEDURE get_message_card (p_cmp_id IN number,
                                 res_cur OUT SYS_REFCURSOR)
     IS
     BEGIN
       -- встановлення ознаки прочитано
       set_readed(p_cmp_id);

       OPEN res_cur FOR
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
          ORDER BY t.cpm_create_dt DESC;
     END;

     -- #92545: картка повідомлення (для НСП)
     PROCEDURE get_message_card_pr (p_cmp_id IN number,
                                    p_Cmes_Owner_Id IN NUMBER,
                                    res_cur OUT SYS_REFCURSOR)
     IS
     BEGIN
       -- встановлення ознаки прочитано
       set_readed_pr(p_Cmes_Owner_Id, p_cmp_id);

       OPEN res_cur FOR
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
          ORDER BY t.cpm_create_dt DESC;
     END;
     */

    -- #92545: Створити нове вихідне повідомлення або відповідь на поточне повідомлення
    PROCEDURE Create_CP_MESSAGE (
        p_CPM_ID                    CP_MESSAGE.CPM_ID%TYPE, -- ід поточного повідомлення
        p_CPM_RECIPIENT_TP          CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
        p_CPM_RECIPIENT_ID          CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        --p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
        --p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
        p_CPM_TOPIC                 CP_MESSAGE.CPM_TOPIC%TYPE,
        p_CPM_MESSAGE               CP_MESSAGE.CPM_MESSAGE%TYPE,
        p_CPM_HEADERS               CP_MESSAGE.CPM_HEADERS%TYPE,
        p_CPM_OBJ_TP                CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
        p_CPM_OBJ_ID                CP_MESSAGE.CPM_OBJ_ID%TYPE,
        p_usr_tp             IN     VARCHAR2, -- константа: ОСП - SC, юзер НСП - CU_NSP, юзер КМ - CU_KM, сама НСП - NSP
        p_New_Id                OUT CP_MESSAGE.CPM_ID%TYPE)
    IS
        l_row      cp_message%ROWTYPE;
        l_cu       NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_sc       NUMBER := ikis_rbm.tools.GetCuSc (l_cu);
        l_usr_tp   VARCHAR2 (10);
        l_usr_id   NUMBER;
    BEGIN
        IF (p_CPM_RECIPIENT_ID IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Потрібно заповнити отримувача повідомлення!');
        END IF;

        l_usr_tp := p_usr_tp;

        IF (l_sc IS NOT NULL AND p_usr_tp = 'SC')
        THEN
            l_usr_id := l_sc;
        ELSE
            l_usr_id := l_cu;
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
            l_row.cpm_root_sender_tp := l_usr_tp;
            l_row.cpm_root_sender_id := l_usr_id;
            l_row.cpm_obj_tp := p_cpm_obj_tp;
            l_row.cpm_obj_id := p_cpm_obj_id;
        END IF;

        api$cp_message.Save_CP_MESSAGE (
            p_CPM_ID               => NULL,
            p_CPM_CPM_ROOT         => l_row.cpm_cpm_root,
            p_CPM_CPM_PREV         => l_row.cpm_cpm_prev,
            p_CPM_SENDER_TP        => l_usr_tp,
            p_CPM_SENDER_ID        => l_usr_id,
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
        set_readed (p_new_id, p_usr_tp);
    END;
  /*
  -- #92545: Створити вихідне повідомлення
  PROCEDURE Create_CP_MESSAGE(p_CPM_ID              CP_MESSAGE.CPM_ID%TYPE,
                              p_CPM_RECIPIENT_TP    CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
                              p_CPM_RECIPIENT_ID    CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
                              p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
                              p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
                              p_CPM_TOPIC           CP_MESSAGE.CPM_TOPIC%TYPE,
                              p_CPM_MESSAGE         CP_MESSAGE.CPM_MESSAGE%TYPE,
                              p_CPM_HEADERS         CP_MESSAGE.CPM_HEADERS%TYPE,
                              p_CPM_OBJ_TP          CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
                              p_CPM_OBJ_ID          CP_MESSAGE.CPM_OBJ_ID%TYPE,
                              p_New_Id          OUT CP_MESSAGE.CPM_ID%TYPE)
  IS
    l_row cp_message%ROWTYPE;
    l_cu NUMBER :=  ikis_rbm.tools.GetCurrentCu;
  BEGIN
    IF (p_CPM_RECIPIENT_ID IS NULL) THEN
      raise_application_error(-20000, 'Потрібно заповнити отримувача повідомлення!');
    END IF;

    IF (p_cpm_id IS NOT NULL) THEN
      SELECT *
        INTO l_row
        FROM cp_message t
       WHERE t.cpm_id = p_CPM_ID;

      l_row.cpm_cpm_root := nvl(l_row.cpm_cpm_root, p_CPM_ID);
      l_row.cpm_root_sender_tp := nvl(l_row.cpm_root_sender_tp, l_row.cpm_sender_tp);
      l_row.cpm_root_sender_id := nvl(l_row.cpm_root_sender_id, l_row.cpm_sender_id);
      l_row.cpm_root_obj_tp := nvl(l_row.cpm_root_obj_tp, l_row.cpm_obj_tp);
      l_row.cpm_root_obj_id := nvl(l_row.cpm_root_obj_id, l_row.cpm_obj_id);
      l_row.cpm_cpm_prev := p_CPM_ID;
    ELSE
      l_row.cpm_root_sender_tp := 'CU';
      l_row.cpm_root_sender_id := l_cu;
      l_row.cpm_obj_tp := p_cpm_obj_tp;
      l_row.cpm_obj_id := p_cpm_obj_id;
    END IF;

    api$cp_message.Save_CP_MESSAGE(p_CPM_ID                  => NULL,
                                   p_CPM_CPM_ROOT            => l_row.cpm_cpm_root,
                                   p_CPM_CPM_PREV            => l_row.cpm_cpm_prev,
                                   p_CPM_SENDER_TP           => 'CU',
                                   p_CPM_SENDER_ID           => l_cu,
                                   p_CPM_RECIPIENT_TP        => p_CPM_RECIPIENT_TP,
                                   p_CPM_RECIPIENT_ID        => p_CPM_RECIPIENT_ID,
                                   p_CPM_ROOT_SENDER_TP      => l_row.cpm_root_sender_tp,
                                   p_CPM_ROOT_SENDER_ID      => l_row.cpm_root_sender_id,
                                   p_CPM_CREATE_DT           => SYSDATE,
                                   p_CPM_SEND_DT             => NULL,
                                   p_CPM_TOPIC               => p_CPM_TOPIC,
                                   p_CPM_MESSAGE             => p_CPM_MESSAGE,
                                   p_CPM_OBJ_TP              => l_row.cpm_obj_tp,
                                   p_CPM_OBJ_ID              => l_row.cpm_obj_id,
                                   p_CPM_ROOT_OBJ_TP         => l_row.cpm_root_obj_tp,
                                   p_CPM_ROOT_OBJ_ID         => l_row.cpm_root_obj_tp,
                                   p_HISTORY_STATUS          => 'A',
                                   p_CPM_HEADERS             => p_CPM_HEADERS,
                                   p_New_Id                  => p_New_Id)
                                  ;
  END;

  -- #92545: Створити вихідне повідомлення (для НСП)
  PROCEDURE Create_CP_MESSAGE_Pr(p_Cmes_Owner_Id       IN NUMBER,
                                 p_CPM_ID              CP_MESSAGE.CPM_ID%TYPE,
                                 p_CPM_RECIPIENT_TP    CP_MESSAGE.CPM_RECIPIENT_TP%TYPE, -- V_DDN_CP_RCPNT_TP
                                 p_CPM_RECIPIENT_ID    CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
                                 p_CPM_ROOT_SENDER_TP  CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE, -- V_DDN_CP_SNDR_TP
                                 p_CPM_ROOT_SENDER_ID  CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
                                 p_CPM_TOPIC           CP_MESSAGE.CPM_TOPIC%TYPE,
                                 p_CPM_MESSAGE         CP_MESSAGE.CPM_MESSAGE%TYPE,
                                 p_CPM_HEADERS         CP_MESSAGE.CPM_HEADERS%TYPE,
                                 p_CPM_OBJ_TP          CP_MESSAGE.CPM_OBJ_TP%TYPE, -- тип сутності (V_DDN_CP_OBJ_TP)
                                 p_CPM_OBJ_ID          CP_MESSAGE.CPM_OBJ_ID%TYPE,
                                 p_New_Id          OUT CP_MESSAGE.CPM_ID%TYPE)
  IS
    l_row cp_message%ROWTYPE;
  BEGIN
    IF (p_CPM_RECIPIENT_ID IS NULL) THEN
      raise_application_error(-20000, 'Потрібно заповнити отримувача повідомлення!');
    END IF;

    IF (p_cpm_id IS NOT NULL) THEN
      SELECT *
        INTO l_row
        FROM cp_message t
       WHERE t.cpm_id = p_CPM_ID;

      l_row.cpm_cpm_root := nvl(l_row.cpm_cpm_root, p_CPM_ID);
      l_row.cpm_root_sender_tp := nvl(l_row.cpm_root_sender_tp, l_row.cpm_sender_tp);
      l_row.cpm_root_sender_id := nvl(l_row.cpm_root_sender_id, l_row.cpm_sender_id);
      l_row.cpm_root_obj_tp := nvl(l_row.cpm_root_obj_tp, l_row.cpm_obj_tp);
      l_row.cpm_root_obj_id := nvl(l_row.cpm_root_obj_id, l_row.cpm_obj_id);
      l_row.cpm_cpm_prev := p_CPM_ID;
    ELSE
      l_row.cpm_root_sender_tp := 'NSP';
      l_row.cpm_root_sender_id := p_Cmes_Owner_Id;
      l_row.cpm_obj_tp := p_cpm_obj_tp;
      l_row.cpm_obj_id := p_cpm_obj_id;
    END IF;

    api$cp_message.Save_CP_MESSAGE(p_CPM_ID                  => NULL,
                                   p_CPM_CPM_ROOT            => l_row.cpm_cpm_root,
                                   p_CPM_CPM_PREV            => l_row.cpm_cpm_prev,
                                   p_CPM_SENDER_TP           => 'NSP',
                                   p_CPM_SENDER_ID           => p_Cmes_Owner_Id,
                                   p_CPM_RECIPIENT_TP        => p_CPM_RECIPIENT_TP,
                                   p_CPM_RECIPIENT_ID        => p_CPM_RECIPIENT_ID,
                                   p_CPM_ROOT_SENDER_TP      => l_row.cpm_root_sender_tp,
                                   p_CPM_ROOT_SENDER_ID      => l_row.cpm_root_sender_id,
                                   p_CPM_CREATE_DT           => SYSDATE,
                                   p_CPM_SEND_DT             => NULL,
                                   p_CPM_TOPIC               => p_CPM_TOPIC,
                                   p_CPM_MESSAGE             => p_CPM_MESSAGE,
                                   p_CPM_OBJ_TP              => l_row.cpm_obj_tp,
                                   p_CPM_OBJ_ID              => l_row.cpm_obj_id,
                                   p_CPM_ROOT_OBJ_TP         => l_row.cpm_root_obj_tp,
                                   p_CPM_ROOT_OBJ_ID         => l_row.cpm_root_obj_tp,
                                   p_HISTORY_STATUS          => 'A',
                                   p_CPM_HEADERS             => p_CPM_HEADERS,
                                   p_New_Id                  => p_New_Id)
                                  ;
  END;

*/
BEGIN
    NULL;
END CMES$CP_MESSAGE;
/