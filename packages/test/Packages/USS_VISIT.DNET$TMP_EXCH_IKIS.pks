/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$TMP_EXCH_IKIS
IS
    -- Author  : VANO
    -- Created : 02.06.2021 13:49:05
    -- Purpose : Функції тимчасової взаємодії з ІКІС (передача інформаційних зверненнь)

    PROCEDURE set_reg_in_ikis (p_id        ap_execution.ape_id%TYPE,
                               p_ext_id    appeal.ap_ext_ident%TYPE,
                               p_message   ap_log.apl_message%TYPE);

    PROCEDURE set_error (p_id        appeal.ap_id%TYPE,
                         p_message   ap_log.apl_message%TYPE);

    PROCEDURE save_result (p_id       appeal.ap_id%TYPE,
                           p_doc_id   ap_document.apd_doc%TYPE,
                           p_dh_id    ap_document.apd_dh%TYPE);
END DNET$TMP_EXCH_IKIS;
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$TMP_EXCH_IKIS
IS
    PROCEDURE set_reg_in_ikis (p_id        ap_execution.ape_id%TYPE,
                               p_ext_id    appeal.ap_ext_ident%TYPE,
                               p_message   ap_log.apl_message%TYPE)
    IS
        l_ap           appeal.ap_id%TYPE;
        l_hs           histsession.hs_id%TYPE;
        l_appeal_old   appeal%ROWTYPE;
    BEGIN
        SELECT aps_ap
          INTO l_ap
          FROM ap_service, ap_execution
         WHERE ape_id = p_id AND ape_aps = aps_id;

        SELECT *
          INTO l_appeal_old
          FROM appeal
         WHERE ap_id = l_ap;

        --Встановлюємо статус "Формування довідки" для зверення "Верифіковано" типу "Довідка"
        UPDATE appeal
           SET ap_st = 'FD'
         WHERE ap_id = l_ap AND ap_tp = 'D' AND ap_st = 'VO';

        --Встановлюємо статус "Формування довідки" для запиту в стані "Заведено"
        UPDATE ap_execution
           SET ape_st = 'N', ape_ext_ident = p_ext_id
         WHERE ape_id = p_id;

        l_hs := TOOLS.GetHistSession ();

        INSERT INTO ap_log (apl_id,
                            apl_ap,
                            apl_hs,
                            apl_st,
                            apl_st_old,
                            apl_message,
                            apl_tp)
            SELECT 0,
                   ap_id,
                   l_hs,
                   ap_st,
                   l_appeal_old.ap_st,
                      CHR (38)
                   || '6#'
                   || nrc_remote_code
                   || '#'
                   || app_fn
                   || ' '
                   || app_mn
                   || ' '
                   || app_ln
                   || '#'
                   || app_inn,
                   'SYS'
              FROM ap_execution,
                   ap_person,
                   uss_ndi.v_ndi_request_config,
                   appeal
             WHERE     ape_id = p_id
                   AND ape_app = app_id
                   AND ape_nrc = nrc_id
                   AND app_ap = ap_id;

        COMMIT;
    END;

    PROCEDURE check_ap_status (p_ap_id   appeal.ap_id%TYPE,
                               p_hs_id   histsession.hs_id%TYPE:= NULL)
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_hs_id, TOOLS.GetHistSession ());

        UPDATE appeal
           SET ap_st = 'V'
         WHERE     ap_id = p_ap_id
               AND ap_st = 'FD'
               AND (SELECT COUNT (*)
                      FROM ap_execution, ap_service
                     WHERE     aps_ap = ap_id
                           AND ape_aps = aps_id
                           AND ape_st IN ('EV', 'ER', 'V')) =
                   (SELECT COUNT (*)
                      FROM ap_execution, ap_service
                     WHERE aps_ap = ap_id AND ape_aps = aps_id);

        IF SQL%ROWCOUNT > 0
        THEN
            --#73983 2021,12,09
            Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                                  p_Apl_Hs        => l_Hs,
                                  p_Apl_St        => 'V',
                                  p_Apl_Message   => CHR (38) || '7',
                                  p_Apl_St_Old    => 'FD');
        END IF;
    END;

    PROCEDURE check_aps_status (p_aps_id ap_service.aps_id%TYPE)
    IS
    BEGIN
        --Встановлюємо статус "Помилка" для послуг "Формування довідки", якщо э хоч одна помилка і всі оброблені
        UPDATE ap_service
           SET aps_st = 'ERR'
         WHERE     aps_id = p_aps_id
               AND (aps_st IS NULL OR aps_st IN ('1', 'FD'))
               AND EXISTS
                       (SELECT 1
                          FROM appeal
                         WHERE     ap_st = 'FD'
                               AND ap_tp = 'D'
                               AND ap_id = aps_ap)
               AND (SELECT COUNT (*)
                      FROM ap_execution
                     WHERE ape_aps = aps_id AND ape_st IN ('EV', 'ER')) > 0
               AND (SELECT COUNT (*)
                      FROM ap_execution
                     WHERE ape_aps = aps_id AND ape_st IN ('EV', 'ER', 'V')) =
                   (SELECT COUNT (*)
                      FROM ap_execution
                     WHERE ape_aps = aps_id);

        --Встановлюємо статус "Виконано" для послуг "Формування довідки", якщо э хоч одна помилка і всі оброблені
        UPDATE ap_service
           SET aps_st = '2'
         WHERE     aps_id = p_aps_id
               AND (aps_st IS NULL OR aps_st IN ('1', 'FD'))
               AND EXISTS
                       (SELECT 1
                          FROM appeal
                         WHERE     ap_st = 'FD'
                               AND ap_tp = 'D'
                               AND ap_id = aps_ap)
               AND (SELECT COUNT (*)
                      FROM ap_execution
                     WHERE ape_aps = aps_id AND ape_st IN ('V')) =
                   (SELECT COUNT (*)
                      FROM ap_execution
                     WHERE ape_aps = aps_id);
    END;

    PROCEDURE set_error (p_id        appeal.ap_id%TYPE,
                         p_message   ap_log.apl_message%TYPE)
    IS
        l_hs             histsession.hs_id%TYPE;
        l_ap_execution   ap_execution%ROWTYPE;
        l_ap_service     ap_service%ROWTYPE;
        l_ap_person      ap_person%ROWTYPE;
        l_appeal_old     appeal%ROWTYPE;
        l_config         uss_ndi.v_ndi_request_config%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_ap_execution
          FROM ap_execution
         WHERE ape_id = p_id;

        SELECT *
          INTO l_ap_service
          FROM ap_service
         WHERE aps_id = l_ap_execution.ape_aps;

        SELECT *
          INTO l_ap_person
          FROM ap_person
         WHERE app_id = l_ap_execution.ape_app;

        SELECT *
          INTO l_config
          FROM uss_ndi.v_ndi_request_config
         WHERE nrc_id = l_ap_execution.ape_nrc;

        SELECT *
          INTO l_appeal_old
          FROM appeal
         WHERE ap_id = l_ap_service.aps_ap;

        UPDATE ap_execution
           SET ape_st = 'EV'
         WHERE ape_st IN ('N') AND ape_id = p_id;

        UPDATE ap_execution
           SET ape_st = 'ER'
         WHERE ape_st IN ('R') AND ape_id = p_id;


        l_hs := TOOLS.GetHistSession ();

        INSERT INTO ap_log (apl_id,
                            apl_ap,
                            apl_hs,
                            apl_st,
                            apl_st_old,
                            apl_message,
                            apl_tp)
            SELECT 0,
                   ap_id,
                   l_hs,
                   ap_st,
                   l_appeal_old.ap_st,
                      CHR (38)
                   || '8#'
                   || l_config.nrc_remote_code
                   || '#'
                   || l_ap_person.app_fn
                   || ' '
                   || l_ap_person.app_mn
                   || ' '
                   || l_ap_person.app_ln
                   || '#'
                   || l_ap_person.app_inn
                   || '#'
                   || p_message,
                   'SYS'
              FROM ap_execution, ap_person, appeal
             WHERE ape_id = p_id AND ape_app = app_id AND app_ap = ap_id;

        check_aps_status (l_ap_service.aps_id);
        check_ap_status (l_ap_service.aps_ap, l_hs);

        COMMIT;
    END;

    PROCEDURE save_result (p_id       appeal.ap_id%TYPE,
                           p_doc_id   ap_document.apd_doc%TYPE,
                           p_dh_id    ap_document.apd_dh%TYPE)
    IS
        l_ap           appeal.ap_id%TYPE;
        l_aps_id       ap_service.aps_id%TYPE;
        l_hs           histsession.hs_id%TYPE;
        l_appeal_old   appeal%ROWTYPE;
    BEGIN
        SELECT aps_ap, aps_id
          INTO l_ap, l_aps_id
          FROM ap_service, ap_execution
         WHERE ape_id = p_id AND ape_aps = aps_id;

        SELECT *
          INTO l_appeal_old
          FROM appeal
         WHERE ap_id = l_ap;

        UPDATE ap_execution
           SET ape_st = 'V'
         WHERE ape_id = p_id AND ape_st = 'N';

        INSERT INTO ap_document (apd_id,
                                 apd_ap,
                                 apd_app,
                                 apd_ndt,
                                 apd_doc,
                                 apd_dh)
            SELECT 0,
                   app_ap,
                   ape_app,
                   nrc_ndt,
                   p_doc_id,
                   p_dh_id
              FROM ap_execution, ap_person, uss_ndi.v_ndi_request_config
             WHERE ape_id = p_id AND ape_app = app_id AND ape_nrc = nrc_id;

        l_hs := TOOLS.GetHistSession ();

        INSERT INTO ap_log (apl_id,
                            apl_ap,
                            apl_hs,
                            apl_st,
                            apl_st_old,
                            apl_message,
                            apl_tp)
            SELECT 0,
                   ap_id,
                   l_hs,
                   ap_st,
                   l_appeal_old.ap_st,
                      CHR (38)
                   || '9#'
                   || nrc_remote_code
                   || '#'
                   || app_fn
                   || ' '
                   || app_mn
                   || ' '
                   || app_ln
                   || '#'
                   || app_inn,
                   'SYS'
              FROM ap_execution,
                   ap_person,
                   uss_ndi.v_ndi_request_config,
                   appeal
             WHERE     ape_id = p_id
                   AND ape_app = app_id
                   AND ape_nrc = nrc_id
                   AND app_ap = ap_id;

        check_aps_status (l_aps_id);
        check_ap_status (l_ap, l_hs);

        COMMIT;
    END;
BEGIN
    -- Initialization
    NULL;
END DNET$TMP_EXCH_IKIS;
/