/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_EDIT
IS
    -- Author  : VANO
    -- Created : 14.04.2022 15:43:56
    -- Purpose : Функції ведення реєстру

    -- Зміна статусу
    PROCEDURE ChangeStatus (
        p_RNSPSR_RNSPM    IN RNSP_STATUS_REGISTER.RNSPSR_RNSPM%TYPE,
        p_RNSPSR_DATE     IN RNSP_STATUS_REGISTER.RNSPSR_DATE%TYPE,
        p_RNSPSR_REASON   IN RNSP_STATUS_REGISTER.RNSPSR_REASON%TYPE,
        p_RNSPSR_ST       IN RNSP_STATUS_REGISTER.RNSPSR_ST%TYPE,
        p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE);

    -- Функції для створення нового зрізу історії. Порядок визову важливий.
    -- 1. Початок редагування
    PROCEDURE StartEdit (p_RNSPM_id        IN RNSP_MAIN.RNSPM_id%TYPE,
                         p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE,
                         p_RNSPM_NUM       IN RNSP_MAIN.RNSPM_NUM%TYPE,
                         p_RNSPM_DATE_IN   IN RNSP_MAIN.RNSPM_DATE_IN%TYPE,
                         p_RNSPM_TP        IN RNSP_MAIN.RNSPM_TP%TYPE,
                         p_oper_type          VARCHAR2);

    -- 2. Збереження адреси
    PROCEDURE SaveAddress (
        p_rnsps_id            IN     NUMBER,
        p_RNSPA_ID            IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN     RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN     RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN     RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN     RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN     RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN     RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN     rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN     rnsp_address.rnspa_tp%TYPE,
        p_new_id                 OUT RNSP_ADDRESS.RNSPA_ID%TYPE);


    PROCEDURE moveAddress (p_rnsps_id   IN NUMBER,
                           p_RNSPA_ID   IN RNSP_ADDRESS.RNSPA_ID%TYPE);

    -- 3. Збереження додаткових параметрів
    PROCEDURE SaveOthers (
        p_RNSPO_ID                 IN     RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN     RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN     RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN     RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN     RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN     RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN     RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE,
        p_new_id                      OUT RNSP_OTHER.RNSPO_ID%TYPE);

    -- 4. Збереження головних параметрів зрізу
    PROCEDURE SaveState (
        --   p_RNSPS_ID in RNSP_STATE.RNSPS_ID%type,
        /*p_RNSPS_RNSPA               in RNSP_STATE.RNSPS_RNSPA%type,
        p_RNSPS_RNSPA1              in RNSP_STATE.RNSPS_RNSPA1%type,
        p_RNSPS_RNSPA2              in RNSP_STATE.RNSPS_RNSPA2%type,
        p_RNSPS_RNSPA3              in RNSP_STATE.RNSPS_RNSPA3%type,
        p_RNSPS_RNSPA4              in RNSP_STATE.RNSPS_RNSPA4%type,*/
        p_RNSPS_NUMIDENT              IN     RNSP_STATE.RNSPS_NUMIDENT%TYPE,
        p_RNSPS_IS_NUMIDENT_MISSING   IN     RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING%TYPE,
        p_RNSPS_PASS_SERIA            IN     RNSP_STATE.RNSPS_PASS_SERIA%TYPE,
        p_RNSPS_PASS_NUM              IN     RNSP_STATE.RNSPS_PASS_NUM%TYPE,
        p_RNSPS_LAST_NAME             IN     RNSP_STATE.RNSPS_LAST_NAME%TYPE,
        p_RNSPS_FIRST_NAME            IN     RNSP_STATE.RNSPS_FIRST_NAME%TYPE,
        p_RNSPS_MIDDLE_NAME           IN     RNSP_STATE.RNSPS_MIDDLE_NAME%TYPE,
        p_RNSPS_GENDER                IN     RNSP_STATE.RNSPS_GENDER%TYPE,
        p_RNSPS_DATE_BIRTH            IN     RNSP_STATE.RNSPS_DATE_BIRTH%TYPE,
        p_RNSPS_NC                    IN     RNSP_STATE.RNSPS_NC%TYPE,
        p_RNSPS_RNSPO                 IN     RNSP_STATE.RNSPS_RNSPO%TYPE,
        p_RNSPS_OWNERSHIP             IN     RNSP_STATE.RNSPS_OWNERSHIP%TYPE,
        p_RNSPS_EDR_STATE             IN     RNSP_STATE.RNSPS_EDR_STATE%TYPE,
        p_new_id                         OUT RNSP_STATE.RNSPS_ID%TYPE);

    -- 5. Збереження послуг
    PROCEDURE SaveService (
        p_RNSPDS_ID             IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN     RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN     RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN     RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN     RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN     RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN     RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN     RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN     RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN     RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN     RNSP_DICT_SERVICE.rnspds_is_standards%TYPE,
        p_new_id                   OUT RNSP_DICT_SERVICE.RNSPDS_ID%TYPE);

    -- 5. Збереження документів
    PROCEDURE SaveDocumentLink (p_DH_ID IN NUMBER);

    -- 6. Збереження критеріїв
    PROCEDURE SaveCriteria (p_aprl_id IN NUMBER, p_result IN VARCHAR2);

    -- 7. Завершення редагування історії
    PROCEDURE EndEdit (p_RNSPM_id OUT RNSP_MAIN.RNSPM_id%TYPE);
END DNET$RNSP_EDIT;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_EDIT TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_EDIT TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$RNSP_EDIT
IS
    PROCEDURE ChangeStatus (
        p_RNSPSR_RNSPM    IN RNSP_STATUS_REGISTER.RNSPSR_RNSPM%TYPE,
        p_RNSPSR_DATE     IN RNSP_STATUS_REGISTER.RNSPSR_DATE%TYPE,
        p_RNSPSR_REASON   IN RNSP_STATUS_REGISTER.RNSPSR_REASON%TYPE,
        p_RNSPSR_ST       IN RNSP_STATUS_REGISTER.RNSPSR_ST%TYPE,
        p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$RNSP_EDIT.' || $$PLSQL_UNIT);
        API$RNSP_EDIT.ChangeStatus (p_RNSPSR_RNSPM,
                                    p_RNSPSR_DATE,
                                    p_RNSPSR_REASON,
                                    p_RNSPSR_ST,
                                    p_RNSPM_VERSION);
    END;

    PROCEDURE StartEdit (p_RNSPM_id        IN RNSP_MAIN.RNSPM_id%TYPE,
                         p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE,
                         p_RNSPM_NUM       IN RNSP_MAIN.RNSPM_NUM%TYPE,
                         p_RNSPM_DATE_IN   IN RNSP_MAIN.RNSPM_DATE_IN%TYPE,
                         p_RNSPM_TP        IN RNSP_MAIN.RNSPM_TP%TYPE,
                         p_oper_type          VARCHAR2)
    IS
    BEGIN
        tools.WriteMsg ('DNET$RNSP_EDIT.' || $$PLSQL_UNIT);
        API$RNSP_EDIT.StartEdit (p_RNSPM_id,
                                 p_RNSPM_VERSION,
                                 p_RNSPM_NUM,
                                 p_RNSPM_DATE_IN,
                                 p_RNSPM_TP,
                                 p_oper_type);
    END;

    PROCEDURE SaveAddress (
        p_rnsps_id            IN     NUMBER,
        p_RNSPA_ID            IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN     RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN     RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN     RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN     RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN     RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN     RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN     rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN     rnsp_address.rnspa_tp%TYPE,
        p_new_id                 OUT RNSP_ADDRESS.RNSPA_ID%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.SaveAddress (p_rnsps_id,
                                   p_RNSPA_ID,
                                   p_RNSPA_KAOT,
                                   p_RNSPA_INDEX,
                                   p_RNSPA_STREET,
                                   p_RNSPA_BUILDING,
                                   p_RNSPA_KORP,
                                   p_RNSPA_APPARTEMENT,
                                   p_Rnspa_Notes,
                                   p_Rnspa_Tp,
                                   p_new_id);
    END;

    PROCEDURE moveAddress (p_rnsps_id   IN NUMBER,
                           p_RNSPA_ID   IN RNSP_ADDRESS.RNSPA_ID%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.move_address (p_rnsps_id, p_RNSPA_ID);
    END;

    PROCEDURE SaveOthers (
        p_RNSPO_ID                 IN     RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN     RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN     RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN     RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN     RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN     RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN     RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE,
        p_new_id                      OUT RNSP_OTHER.RNSPO_ID%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.SaveOthers (p_RNSPO_ID,
                                  p_RNSPO_PROP_FORM,
                                  p_RNSPO_UNION_TP,
                                  p_RNSPO_PHONE,
                                  p_RNSPO_EMAIL,
                                  p_RNSPO_WEB,
                                  p_RNSPO_SERVICE_LOCATION,
                                  p_new_id);
    END;

    -- 4. Збереження головних параметрів зрізу
    PROCEDURE SaveState (
        --   p_RNSPS_ID in RNSP_STATE.RNSPS_ID%type,
        /* p_RNSPS_RNSPA               in RNSP_STATE.RNSPS_RNSPA%type,
         p_RNSPS_RNSPA1              in RNSP_STATE.RNSPS_RNSPA1%type,
         p_RNSPS_RNSPA2              in RNSP_STATE.RNSPS_RNSPA2%type,
         p_RNSPS_RNSPA3              in RNSP_STATE.RNSPS_RNSPA3%type,
         p_RNSPS_RNSPA4              in RNSP_STATE.RNSPS_RNSPA4%type,*/
        p_RNSPS_NUMIDENT              IN     RNSP_STATE.RNSPS_NUMIDENT%TYPE,
        p_RNSPS_IS_NUMIDENT_MISSING   IN     RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING%TYPE,
        p_RNSPS_PASS_SERIA            IN     RNSP_STATE.RNSPS_PASS_SERIA%TYPE,
        p_RNSPS_PASS_NUM              IN     RNSP_STATE.RNSPS_PASS_NUM%TYPE,
        p_RNSPS_LAST_NAME             IN     RNSP_STATE.RNSPS_LAST_NAME%TYPE,
        p_RNSPS_FIRST_NAME            IN     RNSP_STATE.RNSPS_FIRST_NAME%TYPE,
        p_RNSPS_MIDDLE_NAME           IN     RNSP_STATE.RNSPS_MIDDLE_NAME%TYPE,
        p_RNSPS_GENDER                IN     RNSP_STATE.RNSPS_GENDER%TYPE,
        p_RNSPS_DATE_BIRTH            IN     RNSP_STATE.RNSPS_DATE_BIRTH%TYPE,
        p_RNSPS_NC                    IN     RNSP_STATE.RNSPS_NC%TYPE,
        p_RNSPS_RNSPO                 IN     RNSP_STATE.RNSPS_RNSPO%TYPE,
        p_RNSPS_OWNERSHIP             IN     RNSP_STATE.RNSPS_OWNERSHIP%TYPE,
        p_RNSPS_EDR_STATE             IN     RNSP_STATE.RNSPS_EDR_STATE%TYPE,
        p_new_id                         OUT RNSP_STATE.RNSPS_ID%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.SaveState ( /*p_RNSPS_RNSPA, p_RNSPS_RNSPA1, p_RNSPS_RNSPA2, p_RNSPS_RNSPA3, p_RNSPS_RNSPA4, */
                                 p_RNSPS_NUMIDENT,
                                 p_RNSPS_IS_NUMIDENT_MISSING,
                                 p_RNSPS_PASS_SERIA,
                                 p_RNSPS_PASS_NUM,
                                 p_RNSPS_LAST_NAME,
                                 p_RNSPS_FIRST_NAME,
                                 p_RNSPS_MIDDLE_NAME,
                                 p_RNSPS_GENDER,
                                 p_RNSPS_DATE_BIRTH,
                                 p_RNSPS_NC,
                                 p_RNSPS_RNSPO,
                                 p_RNSPS_OWNERSHIP,
                                 p_RNSPS_EDR_STATE,
                                 p_new_id);
    END;

    PROCEDURE SaveService (
        p_RNSPDS_ID             IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN     RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN     RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN     RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN     RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN     RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN     RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN     RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN     RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN     RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN     RNSP_DICT_SERVICE.rnspds_is_standards%TYPE,
        p_new_id                   OUT RNSP_DICT_SERVICE.RNSPDS_ID%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.SaveService (p_RNSPDS_ID,
                                   p_RNSPDS_NST,
                                   p_RNSPDS_CONTENT,
                                   p_RNSPDS_CONDITION,
                                   p_RNSPDS_SUM,
                                   p_RNSPDS_IZM,
                                   p_RNSPDS_CNT,
                                   p_RNSPDS_CAN_URGANT,
                                   p_RNSPDS_IS_INROOM,
                                   p_RNSPDS_IS_INNURSING,
                                   p_rnspds_is_standards,
                                   p_new_id);
    END;

    PROCEDURE SaveDocumentLink (p_DH_ID IN NUMBER)
    IS
    BEGIN
        API$RNSP_EDIT.SaveDocumentLink (p_DH_ID);
    END;

    PROCEDURE SaveCriteria (p_aprl_id IN NUMBER, p_result IN VARCHAR2)
    IS
    BEGIN
        API$RNSP_EDIT.SaveCriteria (p_aprl_id, p_result);
    END;

    PROCEDURE EndEdit (p_RNSPM_id OUT RNSP_MAIN.RNSPM_id%TYPE)
    IS
    BEGIN
        API$RNSP_EDIT.EndEdit (p_RNSPM_id);
    END;
END DNET$RNSP_EDIT;
/