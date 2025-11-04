/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$RNSP_EDIT
IS
    -- Author  : MAXYM
    -- Created : 14.06.2021 17:57:28
    -- Purpose : Реєстр надавачів соціальних послуг

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

    PROCEDURE move_address (p_rnsps_id   IN NUMBER,
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
END API$RNSP_EDIT;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$RNSP_EDIT
IS
    gRnspmId    NUMBER;
    gRnspsId    NUMBER;
    gHsId       NUMBER;
    gOperType   VARCHAR2 (1);

    -- I-вставка M-нова історія E-виправлення поточної історії
    -- Status E NOT SUPPORTED!!!!

    PROCEDURE Clear
    IS
    BEGIN
        gRnspmId := NULL;
        gRnspsId := NULL;
        gOperType := NULL;
        gHsId := NULL;
    END;

    PROCEDURE checkStart
    IS
    BEGIN
        IF (gOperType IS NULL OR gRnspmId IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Не розпочато редагування картки.');
        END IF;
    END;

    PROCEDURE checkEdit
    IS
    BEGIN
        checkStart ();

        IF (NOT gOperType IN ('I', 'M'-- , 'E'
                                      ))
        THEN
            raise_application_error (
                -20000,
                'Операція ' || gOperType || ' не дозволяє редагування даних.');
        END IF;
    END;

    PROCEDURE lockAndSetCurrent (
        p_RNSPM_id        IN RNSP_MAIN.RNSPM_id%TYPE,
        p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE)
    IS
        l_version   RNSP_MAIN.RNSPM_VERSION%TYPE;
    BEGIN
            SELECT RNSPM_VERSION
              INTO l_version
              FROM rnsp_main
             WHERE RNSPM_id = p_RNSPM_id
        FOR UPDATE WAIT 20;

        IF (l_version != p_RNSPM_VERSION)
        THEN
            raise_application_error (
                -20000,
                'Запис зазнав змін. Почніть операцію наново.');
        END IF;

        UPDATE rnsp_main
           SET RNSPM_VERSION = l_version + 1
         WHERE RNSPM_id = p_rnspm_id;
    END;

    PROCEDURE activeLayerToHistory (p_RNSPM_id IN RNSP_MAIN.RNSPM_id%TYPE)
    IS
    BEGIN
        UPDATE rnsp_state
           SET history_status = 'H'
         WHERE rnsps_rnspm = p_RNSPM_id AND history_status = 'A';
    END;

    PROCEDURE ChangeStatus (
        p_RNSPSR_RNSPM    IN RNSP_STATUS_REGISTER.RNSPSR_RNSPM%TYPE,
        p_RNSPSR_DATE     IN RNSP_STATUS_REGISTER.RNSPSR_DATE%TYPE,
        p_RNSPSR_REASON   IN RNSP_STATUS_REGISTER.RNSPSR_REASON%TYPE,
        p_RNSPSR_ST       IN RNSP_STATUS_REGISTER.RNSPSR_ST%TYPE,
        p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE)
    IS
        l_rnspsr_id   NUMBER;
    BEGIN
        lockAndSetCurrent (p_RNSPSR_RNSPM, p_RNSPM_VERSION);

        --raise_application_error(-20000, 'p_RNSPSR_ST = '||p_RNSPSR_ST|| '  p_RNSPSR_DATE = '||p_RNSPSR_DATE);

        IF p_RNSPSR_ST = 'A'
        THEN
            UPDATE rnsp_main
               SET rnspm_st = p_RNSPSR_ST,
                   rnspm_date_in = TRUNC (SYSDATE),           --p_RNSPSR_DATE,
                   rnspm_date_out = NULL
             /*
                      rnspm_date_out =(CASE
                                       WHEN rnspm_date_out IS NOT NULL AND rnspm_date_out <= p_RNSPSR_DATE THEN
                                            NULL
                                       ELSE
                                            rnspm_date_out
                                       END)
             */
             WHERE rnspm_id = p_RNSPSR_RNSPM;
        ELSE
            UPDATE rnsp_main
               SET rnspm_st = p_RNSPSR_ST, rnspm_date_out = p_RNSPSR_DATE
             WHERE rnspm_id = p_RNSPSR_RNSPM;
        END IF;

        PRIV$rnsp_status_register.save (
            p_rnspsr_id       => NULL,
            p_rnspsr_rnspm    => p_RNSPSR_RNSPM,
            p_rnspsr_date     => p_rnspsr_date,
            p_rnspsr_reason   => p_rnspsr_reason,
            p_rnspsr_hs       => TOOLS.GetHistSession,
            p_rnspsr_st       => p_rnspsr_st,
            p_new_id          => l_rnspsr_id);
    END;

    PROCEDURE StartEdit (p_RNSPM_id        IN RNSP_MAIN.RNSPM_id%TYPE,
                         p_RNSPM_VERSION   IN RNSP_MAIN.RNSPM_VERSION%TYPE,
                         p_RNSPM_NUM       IN RNSP_MAIN.RNSPM_NUM%TYPE,
                         p_RNSPM_DATE_IN   IN RNSP_MAIN.RNSPM_DATE_IN%TYPE,
                         p_RNSPM_TP        IN RNSP_MAIN.RNSPM_TP%TYPE,
                         p_oper_type          VARCHAR2)
    IS
        l_rnspm_id    NUMBER;
        l_rnspsr_id   NUMBER;
    BEGIN
        Clear;
        gHsId := TOOLS.GetHistSession;

        IF p_oper_type = 'I'
        THEN
            INSERT INTO rnsp_main (rnspm_num,
                                   rnspm_date_in,
                                   rnspm_date_out,
                                   rnspm_st,
                                   rnspm_version,
                                   rnspm_tp)
                 VALUES (p_rnspm_num,
                         p_rnspm_date_in,
                         NULL,
                         'A',
                         1,
                         p_rnspm_tp)
              RETURNING rnspm_id
                   INTO l_rnspm_id;

            PRIV$rnsp_status_register.save (
                p_rnspsr_id       => NULL,
                p_rnspsr_rnspm    => l_rnspm_id,
                p_rnspsr_date     => p_RNSPM_DATE_IN,
                p_rnspsr_reason   => NULL,
                p_rnspsr_hs       => gHsId,
                p_rnspsr_st       => 'A',
                p_new_id          => l_rnspsr_id);
        ELSE
            l_rnspm_id := p_RNSPM_id;

            lockAndSetCurrent (p_RNSPM_id, p_RNSPM_VERSION);
            activeLayerToHistory (p_RNSPM_id);
        END IF;

        gOperType := p_oper_type;
        gRnspmId := l_rnspm_id;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
            IF (INSTR (SQLERRM, 'XAK_RNSP_MAIN_NUM') > 0)
            THEN
                raise_application_error (
                    -20000,
                       'Вже зареєстровано запис в РНСП з номером '
                    || p_RNSPM_NUM);
            ELSE
                RAISE;
            END IF;
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
        checkEdit;

        IF (    p_RNSPA_ID IS NOT NULL
            AND PRIV$rnsp_address.isnochanges (
                    p_rnspa_id            => p_rnspa_id,
                    p_rnspa_kaot          => p_rnspa_kaot,
                    p_rnspa_index         => p_rnspa_index,
                    p_rnspa_street        => p_rnspa_street,
                    p_rnspa_building      => p_rnspa_building,
                    p_rnspa_korp          => p_rnspa_korp,
                    p_rnspa_appartement   => p_rnspa_appartement,
                    p_Rnspa_Notes         => p_Rnspa_Notes,
                    p_Rnspa_Tp            => p_Rnspa_Tp))
        THEN
            p_new_id := p_RNSPA_ID;
        ELSE
            PRIV$rnsp_address.save (
                p_rnspa_id            => NULL,
                p_rnspa_kaot          => p_rnspa_kaot,
                p_rnspa_index         => p_rnspa_index,
                p_rnspa_street        => p_rnspa_street,
                p_rnspa_building      => p_rnspa_building,
                p_rnspa_korp          => p_rnspa_korp,
                p_rnspa_appartement   => p_rnspa_appartement,
                p_Rnspa_Notes         => p_Rnspa_Notes,
                p_Rnspa_Tp            => p_Rnspa_Tp,
                p_new_id              => p_new_id);
            move_address (p_rnsps_id, p_new_id);
        END IF;
    END;

    PROCEDURE move_address (p_rnsps_id   IN NUMBER,
                            p_RNSPA_ID   IN RNSP_ADDRESS.RNSPA_ID%TYPE)
    IS
        l_tp   VARCHAR2 (10);
    BEGIN
        SELECT t.rnspa_tp
          INTO l_tp
          FROM rnsp_address t
         WHERE t.rnspa_id = p_rnspa_id;

        IF (l_tp = 'U')
        THEN
            UPDATE rnsp_state t
               SET t.rnsps_rnspa = p_RNSPA_ID
             WHERE t.rnsps_id = p_rnsps_id;
        END IF;

        INSERT INTO rnsp2address (rnsp2a_rnsps, rnsp2a_rnspa)
             VALUES (p_rnsps_id, p_RNSPA_ID);
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
        checkEdit;

        IF (    p_RNSPO_ID IS NOT NULL
            AND PRIV$rnsp_other.isnochanges (
                    p_rnspo_id                 => p_rnspo_id,
                    p_rnspo_prop_form          => p_rnspo_prop_form,
                    p_rnspo_union_tp           => p_rnspo_union_tp,
                    p_rnspo_phone              => p_rnspo_phone,
                    p_rnspo_email              => p_rnspo_email,
                    p_rnspo_web                => p_rnspo_web,
                    p_rnspo_service_location   => p_rnspo_service_location))
        THEN
            p_new_id := p_rnspo_id;
        ELSE
            PRIV$rnsp_other.save (
                p_rnspo_id                 => NULL,
                p_rnspo_prop_form          => p_rnspo_prop_form,
                p_rnspo_union_tp           => p_rnspo_union_tp,
                p_rnspo_phone              => p_rnspo_phone,
                p_rnspo_email              => p_rnspo_email,
                p_rnspo_web                => p_rnspo_web,
                p_rnspo_service_location   => p_rnspo_service_location,
                p_new_id                   => p_new_id);
        END IF;
    END;

    PROCEDURE SaveState (
        --   p_RNSPS_ID in RNSP_STATE.RNSPS_ID%type,
        /*  p_RNSPS_RNSPA               in RNSP_STATE.RNSPS_RNSPA%type,
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
        checkEdit;

        priv$rnsp_state.save (
            p_rnsps_id                    => NULL,
            p_rnsps_rnspm                 => gRnspmId,
            p_rnsps_rnspa                 => NULL,
            /*p_rnsps_rnspa1              => p_rnsps_rnspa1,
            p_rnsps_rnspa2              => p_rnsps_rnspa2,
            p_rnsps_rnspa3              => p_rnsps_rnspa3,
            p_rnsps_rnspa4              => p_rnsps_rnspa4,*/
            p_rnsps_numident              => p_rnsps_numident,
            p_rnsps_is_numident_missing   => p_rnsps_is_numident_missing,
            p_rnsps_pass_seria            => p_rnsps_pass_seria,
            p_rnsps_pass_num              => p_rnsps_pass_num,
            p_rnsps_last_name             => p_rnsps_last_name,
            p_rnsps_first_name            => p_rnsps_first_name,
            p_rnsps_middle_name           => p_rnsps_middle_name,
            p_rnsps_gender                => p_rnsps_gender,
            p_rnsps_date_birth            => p_rnsps_date_birth,
            p_rnsps_nc                    => p_rnsps_nc,
            p_rnsps_rnspo                 => p_rnsps_rnspo,
            p_rnsps_hs                    => gHsId,
            p_history_status              => 'A',
            p_RNSPS_OWNERSHIP             => p_RNSPS_OWNERSHIP,
            p_RNSPS_EDR_STATE             => p_RNSPS_EDR_STATE,
            p_new_id                      => p_new_id);
        gRnspsId := p_new_id;
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
        checkEdit ();

        IF (    p_RNSPDS_ID IS NOT NULL
            AND priv$rnsp_dict_service.isnochanges (
                    p_rnspds_id             => p_rnspds_id,
                    p_rnspds_nst            => p_rnspds_nst,
                    p_rnspds_content        => p_rnspds_content,
                    p_rnspds_condition      => p_rnspds_condition,
                    p_RNSPDS_SUM            => p_RNSPDS_SUM,
                    p_RNSPDS_IZM            => p_RNSPDS_IZM,
                    p_RNSPDS_CNT            => p_RNSPDS_CNT,
                    p_RNSPDS_CAN_URGANT     => p_RNSPDS_CAN_URGANT,
                    p_RNSPDS_IS_INROOM      => p_RNSPDS_IS_INROOM,
                    p_RNSPDS_IS_INNURSING   => p_RNSPDS_IS_INNURSING,
                    p_rnspds_is_standards   => p_rnspds_is_standards))
        THEN
            p_new_id := p_RNSPDS_ID;
        ELSE
            priv$rnsp_dict_service.save (
                p_rnspds_id             => NULL,
                p_rnspds_nst            => p_rnspds_nst,
                p_rnspds_content        => p_rnspds_content,
                p_rnspds_condition      => p_rnspds_condition,
                p_RNSPDS_SUM            => p_RNSPDS_SUM,
                p_RNSPDS_IZM            => p_RNSPDS_IZM,
                p_RNSPDS_CNT            => p_RNSPDS_CNT,
                p_RNSPDS_CAN_URGANT     => p_RNSPDS_CAN_URGANT,
                p_RNSPDS_IS_INROOM      => p_RNSPDS_IS_INROOM,
                p_RNSPDS_IS_INNURSING   => p_RNSPDS_IS_INNURSING,
                p_rnspds_is_standards   => p_rnspds_is_standards,
                p_new_id                => p_new_id);
        END IF;

        INSERT INTO rnsp2service (rnsp2s_rnsps, rnsp2s_rnspds)
             VALUES (gRnspsId, p_new_id);
    END;

    PROCEDURE SaveDocumentLink (p_DH_ID IN NUMBER)
    IS
    BEGIN
        INSERT INTO rnsp2doc (rnsp2d_rnsps, rnsp2d_dh)
             VALUES (gRnspsId, p_DH_ID);
    END;

    PROCEDURE SaveCriteria (p_aprl_id IN NUMBER, p_result IN VARCHAR2)
    IS
        l_hs   NUMBER := tools.GetHistSession;
    BEGIN
        --raise_application_error(-20000, 'p_aprl_id='||p_aprl_id||';p_result='||p_result);
        UPDATE ap_right_log t
           SET t.aprl_result = p_result, t.aprl_hs_rewrite = l_hs
         WHERE t.aprl_id = p_aprl_id;

        API$CHECK_RIGHT.Calck_aps_result (p_aprl_id);
    END;

    PROCEDURE EndEdit (p_RNSPM_id OUT RNSP_MAIN.RNSPM_id%TYPE)
    IS
    BEGIN
        checkEdit ();
        p_RNSPM_id := gRnspmId;
        Clear ();
    END;
END API$RNSP_EDIT;
/