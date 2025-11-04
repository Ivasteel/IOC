/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$CP_MESSAGE
IS
    -- Author  : OLEKSII
    -- Created : 27.09.2023 10:39:49
    -- Purpose : Обмін повідомленями

    Pkg   CONSTANT VARCHAR2 (50) := 'API$ACT';

    TYPE R_CP_MESSAGE IS RECORD
    (
        CPM_ID                CP_MESSAGE.CPM_ID%TYPE,
        CPM_CPM_ROOT          CP_MESSAGE.CPM_CPM_ROOT%TYPE,
        CPM_CPM_PREV          CP_MESSAGE.CPM_CPM_PREV%TYPE,
        CPM_SENDER_TP         CP_MESSAGE.CPM_SENDER_TP%TYPE,
        CPM_SENDER_ID         CP_MESSAGE.CPM_SENDER_ID%TYPE,
        CPM_RECIPIENT_TP      CP_MESSAGE.CPM_RECIPIENT_TP%TYPE,
        CPM_RECIPIENT_ID      CP_MESSAGE.CPM_RECIPIENT_ID%TYPE,
        CPM_ROOT_SENDER_TP    CP_MESSAGE.CPM_ROOT_SENDER_TP%TYPE,
        CPM_ROOT_SENDER_ID    CP_MESSAGE.CPM_ROOT_SENDER_ID%TYPE,
        CPM_CREATE_DT         CP_MESSAGE.CPM_CREATE_DT%TYPE,
        CPM_SEND_DT           CP_MESSAGE.CPM_SEND_DT%TYPE,
        CPM_TOPIC             CP_MESSAGE.CPM_TOPIC%TYPE,
        CPM_MESSAGE           CP_MESSAGE.CPM_MESSAGE%TYPE,
        CPM_OBJ_TP            CP_MESSAGE.CPM_OBJ_TP%TYPE,
        CPM_OBJ_ID            CP_MESSAGE.CPM_OBJ_ID%TYPE,
        CPM_ROOT_OBJ_TP       CP_MESSAGE.CPM_ROOT_OBJ_TP%TYPE,
        CPM_ROOT_OBJ_ID       CP_MESSAGE.CPM_ROOT_OBJ_ID%TYPE,
        HISTORY_STATUS        CP_MESSAGE.HISTORY_STATUS%TYPE,
        CPM_HEADERS           CP_MESSAGE.CPM_HEADERS%TYPE,
        New_Id                NUMBER
    );

    TYPE T_CP_MESSAGE IS TABLE OF R_CP_MESSAGE;

    TYPE R_CP_REANDINGS IS RECORD
    (
        CPR_ID            CP_REANDINGS.CPR_ID%TYPE,
        CPR_READERS_TP    CP_REANDINGS.CPR_READERS_TP%TYPE,
        CPR_READERS_ID    CP_REANDINGS.CPR_READERS_ID%TYPE,
        CPR_READ_DT       CP_REANDINGS.CPR_READ_DT%TYPE,
        CPR_CPM           CP_REANDINGS.CPR_CPM%TYPE,
        New_Id            NUMBER
    );

    TYPE T_CP_REANDINGS IS TABLE OF R_CP_REANDINGS;

    --====================================================--
    --   Наіменування відправника/отримувача повідомлення
    --====================================================--
    FUNCTION Get_S_R_name (p_tp VARCHAR2, p_id NUMBER)
        RETURN VARCHAR2;

    --====================================================--
    --   Перелік повідомлень по tmp_work_ids, cpm_id = x_id
    --====================================================--
    PROCEDURE Get_Message_List (p_Res OUT SYS_REFCURSOR);

    --====================================================--
    --   Перелік читачів по tmp_work_ids, cpк_cpm = x_id
    --====================================================--
    PROCEDURE Get_Reandings_List (p_Res OUT SYS_REFCURSOR);

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
        p_New_Id               OUT CP_MESSAGE.CPM_ID%TYPE);

    --====================================================--
    --   Збереження читача
    --====================================================--
    PROCEDURE Save_CP_REANDINGS (
        p_CPR_ID               CP_REANDINGS.CPR_ID%TYPE,
        p_CPR_READERS_TP       CP_REANDINGS.CPR_READERS_TP%TYPE,
        p_CPR_READERS_ID       CP_REANDINGS.CPR_READERS_ID%TYPE,
        p_CPR_READ_DT          CP_REANDINGS.CPR_READ_DT%TYPE,
        p_CPR_CPM              CP_REANDINGS.CPR_CPM%TYPE,
        p_New_Id           OUT CP_REANDINGS.CPR_ID%TYPE);
END API$CP_MESSAGE;
/


/* Formatted on 8/12/2025 5:56:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$CP_MESSAGE
IS
    --====================================================--
    --   Наіменування відправника/отримувача повідомлення
    --====================================================--
    FUNCTION Get_S_R_name (p_tp VARCHAR2, p_id NUMBER)
        RETURN VARCHAR2
    IS
        ret   VARCHAR2 (2000);
    BEGIN
        CASE p_tp
            WHEN 'SC'
            THEN
                ret := api$sc_tools.GET_PIB (P_SC_ID => p_id);
            WHEN 'CU'
            THEN
                SELECT CU_PIB
                  INTO ret
                  FROM ikis_rbm.v_cmes_users
                 WHERE cu_id = p_id;
            WHEN 'CU_KM'
            THEN
                SELECT CU_PIB
                  INTO ret
                  FROM ikis_rbm.v_cmes_users
                 WHERE cu_id = p_id;
            WHEN 'CU_NSP'
            THEN
                SELECT CU_PIB
                  INTO ret
                  FROM ikis_rbm.v_cmes_users
                 WHERE cu_id = p_id;
            WHEN 'WU'
            THEN
                SELECT wu_pib
                  INTO ret
                  FROM ikis_sysweb.V$ALL_USERS
                 WHERE wu_id = p_id;
            WHEN 'OPFU'
            THEN
                SELECT org_name
                  INTO ret
                  FROM v_opfu
                 WHERE org_id = p_id;
            WHEN 'NSP'
            THEN
                SELECT MAX (
                           CASE
                               WHEN r.RNSPM_TP = 'O'
                               THEN
                                   NVL (rnsps_first_name, rnsps_last_name)
                               WHEN     r.RNSPM_TP = 'F'
                                    AND rnsps_middle_name IS NOT NULL
                               THEN
                                      rnsps_last_name
                                   || ' '
                                   || rnsps_first_name
                                   || ' '
                                   || rnsps_middle_name
                               WHEN     r.RNSPM_TP = 'F'
                                    AND rnsps_first_name IS NOT NULL
                               THEN
                                   rnsps_first_name
                               WHEN r.RNSPM_TP = 'F'
                               THEN
                                   rnsps_last_name
                           END)    AS pib
                  INTO ret
                  FROM uss_rnsp.v_rnsp r
                 WHERE rnspm_id = p_id;
            ELSE
                NULL;
        END CASE;

        RETURN ret;
    END;

    --====================================================--
    --   Перелік повідомлень по tmp_work_ids, cpm_id = x_id
    --====================================================--
    PROCEDURE Get_Message_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT cpm.cpm_id,
                   cpm.cpm_cpm_root,
                   cpm.cpm_cpm_prev,
                   cpm.cpm_sender_tp,
                   S.DIC_SNAME
                       AS cpm_sender_tp_name,
                   cpm.cpm_sender_id,
                   api$cp_message.Get_S_R_name (cpm.cpm_sender_tp,
                                                cpm.cpm_sender_id)
                       AS cpm_sender_name,
                   cpm.cpm_recipient_tp,
                   R.DIC_SNAME
                       AS cpm_recipient_tp_name,
                   cpm.cpm_recipient_id,
                   api$cp_message.Get_S_R_name (cpm.cpm_recipient_tp,
                                                cpm.cpm_recipient_id)
                       AS cpm_recipient_name,
                   cpm.cpm_root_sender_tp,
                   Ss.DIC_SNAME
                       AS cpm_root_sender_tp_name,
                   cpm.cpm_root_sender_id,
                   api$cp_message.Get_S_R_name (cpm.cpm_root_sender_tp,
                                                cpm.cpm_root_sender_id)
                       AS cpm_root_sender_name,
                   cpm.cpm_create_dt,
                   cpm.cpm_send_dt,
                   cpm.cpm_topic,
                   cpm.cpm_message,
                   cpm.cpm_obj_tp,
                   O.DIC_SNAME
                       AS cpm_obj_tp_name,
                   cpm.cpm_obj_id,
                   cpm.cpm_root_obj_tp,
                   Oo.DIC_SNAME
                       AS cpm_root_obj_tp_name,
                   cpm.cpm_root_obj_id,
                   cpm.history_status,
                   cpm.cpm_headers
              FROM tmp_work_ids
                   JOIN CP_MESSAGE cpm ON cpm_id = x_id
                   JOIN uss_ndi.V_DDN_CP_SNDR_TP S
                       ON S.DIC_CODE = cpm.cpm_sender_tp
                   JOIN uss_ndi.V_DDN_CP_SNDR_TP SS
                       ON Ss.DIC_CODE = cpm.cpm_root_sender_tp
                   JOIN uss_ndi.v_Ddn_Cp_Rcpnt_Tp R
                       ON R.DIC_CODE = cpm.cpm_recipient_tp
                   LEFT JOIN uss_ndi.v_Ddn_Cp_Obj_Tp O
                       ON O.DIC_CODE = cpm.cpm_obj_tp
                   LEFT JOIN uss_ndi.v_Ddn_Cp_Obj_Tp Oo
                       ON Oo.DIC_CODE = cpm.cpm_root_obj_tp
             WHERE cpm.history_status = 'A';
    END;

    --====================================================--
    --   Перелік читачів по tmp_work_ids, cpк_cpm = x_id
    --====================================================--
    PROCEDURE Get_Reandings_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT cpr.cpr_id,
                   cpr.cpr_readers_tp,
                   R.DIC_SNAME
                       AS cpr_readers_tp_name,
                   cpr.cpr_readers_id,
                   api$cp_message.Get_S_R_name (cpr.cpr_readers_tp,
                                                cpr.cpr_readers_id)
                       AS cpr_readers_name,
                   cpr.cpr_read_dt,
                   cpr.cpr_cpm
              FROM tmp_work_ids
                   JOIN CP_REANDINGS cpr ON cpr_cpm = x_id
                   JOIN uss_ndi.v_Ddn_Cp_Rcpnt_Tp R
                       ON R.DIC_CODE = cpr.cpr_readers_id;
    END;

    /*
      --====================================================--
      --   Парсінг
      --====================================================--
      FUNCTION Parse(p_Type_Name    IN VARCHAR2,
                     p_Clob_Input   IN BOOLEAN DEFAULT TRUE,
                     p_Has_Root_Tag IN BOOLEAN DEFAULT TRUE) RETURN VARCHAR2 IS
      BEGIN
        RETURN Type2xmltable(Pkg, p_Type_Name, TRUE, p_Clob_Input, p_Has_Root_Tag);
      END;
      --====================================================--
      --   Парсінг повідомлення
      --====================================================--
      FUNCTION Parse_CP_MESSAGE(p_Xml IN CLOB) RETURN R_CP_MESSAGE IS
        l_Result r_Act;
      BEGIN
        IF p_Xml IS NULL THEN
          RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse('R_CP_MESSAGE')
          INTO l_Result
          USING p_Xml;

        RETURN l_Result;
      EXCEPTION
        WHEN OTHERS THEN
          Raise_Application_Error(-20000,
                                  'Помилка парсингу повідомлення: ' || Chr(13) || SQLERRM || Chr(13) || Dbms_Utility.Format_Error_Backtrace);
      END;
    */
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
        IF NVL (p_CPM_ID, -1) < 0
        THEN
            p_New_Id := Sq_Id_CP_MESSAGE.NEXTVAL;

            INSERT INTO CP_MESSAGE (CPM_ID,
                                    CPM_CPM_ROOT,
                                    CPM_CPM_PREV,
                                    CPM_SENDER_TP,
                                    CPM_SENDER_ID,
                                    CPM_RECIPIENT_TP,
                                    CPM_RECIPIENT_ID,
                                    CPM_ROOT_SENDER_TP,
                                    CPM_ROOT_SENDER_ID,
                                    CPM_CREATE_DT,
                                    CPM_SEND_DT,
                                    CPM_TOPIC,
                                    CPM_MESSAGE,
                                    CPM_OBJ_TP,
                                    CPM_OBJ_ID,
                                    CPM_ROOT_OBJ_TP,
                                    CPM_ROOT_OBJ_ID,
                                    HISTORY_STATUS,
                                    CPM_HEADERS)
                 VALUES (p_New_Id,
                         p_CPM_CPM_ROOT,
                         p_CPM_CPM_PREV,
                         p_CPM_SENDER_TP,
                         p_CPM_SENDER_ID,
                         p_CPM_RECIPIENT_TP,
                         p_CPM_RECIPIENT_ID,
                         p_CPM_ROOT_SENDER_TP,
                         p_CPM_ROOT_SENDER_ID,
                         p_CPM_CREATE_DT,
                         p_CPM_SEND_DT,
                         p_CPM_TOPIC,
                         p_CPM_MESSAGE,
                         p_CPM_OBJ_TP,
                         p_CPM_OBJ_ID,
                         p_CPM_ROOT_OBJ_TP,
                         p_CPM_ROOT_OBJ_ID,
                         p_HISTORY_STATUS,
                         p_CPM_HEADERS);
        ELSE
            p_New_Id := p_CPM_ID;

            UPDATE CP_MESSAGE m
               SET m.CPM_CPM_ROOT = p_CPM_CPM_ROOT,
                   m.CPM_CPM_PREV = p_CPM_CPM_PREV,
                   m.CPM_SENDER_TP = p_CPM_SENDER_TP,
                   m.CPM_SENDER_ID = p_CPM_SENDER_ID,
                   m.CPM_RECIPIENT_TP = p_CPM_RECIPIENT_TP,
                   m.CPM_RECIPIENT_ID = p_CPM_RECIPIENT_ID,
                   m.CPM_ROOT_SENDER_TP = p_CPM_ROOT_SENDER_TP,
                   m.CPM_ROOT_SENDER_ID = p_CPM_ROOT_SENDER_ID,
                   m.CPM_CREATE_DT = p_CPM_CREATE_DT,
                   m.CPM_SEND_DT = p_CPM_SEND_DT,
                   m.CPM_TOPIC = p_CPM_TOPIC,
                   m.CPM_MESSAGE = p_CPM_MESSAGE,
                   m.CPM_OBJ_TP = p_CPM_OBJ_TP,
                   m.CPM_OBJ_ID = p_CPM_OBJ_ID,
                   m.CPM_ROOT_OBJ_TP = p_CPM_ROOT_OBJ_TP,
                   m.CPM_ROOT_OBJ_ID = p_CPM_ROOT_OBJ_ID,
                   m.HISTORY_STATUS = p_HISTORY_STATUS,
                   m.CPM_HEADERS = p_CPM_HEADERS
             WHERE m.CPM_ID = p_CPM_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження читача
    --====================================================--
    PROCEDURE Save_CP_REANDINGS (
        p_CPR_ID               CP_REANDINGS.CPR_ID%TYPE,
        p_CPR_READERS_TP       CP_REANDINGS.CPR_READERS_TP%TYPE,
        p_CPR_READERS_ID       CP_REANDINGS.CPR_READERS_ID%TYPE,
        p_CPR_READ_DT          CP_REANDINGS.CPR_READ_DT%TYPE,
        p_CPR_CPM              CP_REANDINGS.CPR_CPM%TYPE,
        p_New_Id           OUT CP_REANDINGS.CPR_ID%TYPE)
    IS
    BEGIN
        IF NVL (p_CPR_ID, -1) < 0
        THEN
            p_New_Id := Sq_Id_CP_REANDINGS.NEXTVAL;

            INSERT INTO CP_REANDINGS (CPR_ID,
                                      CPR_READERS_TP,
                                      CPR_READERS_ID,
                                      CPR_READ_DT,
                                      CPR_CPM)
                 VALUES (p_CPR_ID,
                         p_CPR_READERS_TP,
                         p_CPR_READERS_ID,
                         p_CPR_READ_DT,
                         p_CPR_CPM);
        ELSE
            p_New_Id := p_CPR_ID;

            UPDATE CP_REANDINGS r
               SET r.CPR_READERS_TP = p_CPR_READERS_TP,
                   r.CPR_READERS_ID = p_CPR_READERS_ID,
                   r.CPR_READ_DT = p_CPR_READ_DT,
                   r.CPR_CPM = p_CPR_CPM
             WHERE r.CPR_ID = p_CPR_ID;
        END IF;
    END;
END API$CP_MESSAGE;
/