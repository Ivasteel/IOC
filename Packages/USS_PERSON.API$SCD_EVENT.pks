/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SCD_EVENT
IS
    -- Author  : VANO
    -- Created : 25.01.2023 18:31:35
    -- Purpose : Функції фіксації та ведення подій з документами СРКО

    --Реєстрація події отримання нової довідки ВПО
    PROCEDURE make_new_document (
        p_scde_scd       scd_event.scde_scd%TYPE,
        p_scde_dt        scd_event.scde_dt%TYPE,
        p_scde_message   scd_event.scde_message%TYPE);

    --Реєстрація події припинення дії довідки ВПО
    PROCEDURE close_document (p_scde_scd       scd_event.scde_scd%TYPE,
                              p_scde_dt        scd_event.scde_dt%TYPE,
                              p_scde_message   scd_event.scde_message%TYPE);

    --Реєстрація події модифікації документа
    PROCEDURE update_document (p_scde_scd       scd_event.scde_scd%TYPE,
                               p_scde_dt        scd_event.scde_dt%TYPE,
                               p_scde_message   scd_event.scde_message%TYPE);

    PROCEDURE save_doc_error (p_scde_scd       scd_event.scde_scd%TYPE,
                              p_scde_dt        scd_event.scde_dt%TYPE,
                              p_scde_message   scd_event.scde_message%TYPE);

    --Оновлення запису події статусом U та міткою масового перерахунку
    PROCEDURE use_by_rc (p_mode           INTEGER, --1=за p_scde_id, 2=за ідами з табилці tmp_work_ids
                         p_scde_id        scd_event.scde_id%TYPE,
                         p_scde_rc        scd_event.scde_rc%TYPE,
                         p_scde_message   scd_event.scde_message%TYPE);

    FUNCTION tonumber (val VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Execute_Event_VPO (p_id NUMBER DEFAULT NULL);
END API$SCD_EVENT;
/


GRANT EXECUTE ON USS_PERSON.API$SCD_EVENT TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$SCD_EVENT TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SCD_EVENT TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SCD_EVENT TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SCD_EVENT TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SCD_EVENT
IS
    PROCEDURE write_scde_log (p_scdl_scde      scd_log.scdl_scde%TYPE,
                              p_scdl_hs        scd_log.scdl_hs%TYPE,
                              p_scdl_st        scd_log.scdl_st%TYPE,
                              p_scdl_message   scd_log.scdl_message%TYPE,
                              p_scdl_st_old    scd_log.scdl_st_old%TYPE,
                              p_scdl_tp        scd_log.scdl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_scdl_hs, TOOLS.GetHistSession);

        INSERT INTO scd_log (scdl_id,
                             scdl_scde,
                             scdl_hs,
                             scdl_st,
                             scdl_message,
                             scdl_st_old,
                             scdl_tp)
             VALUES (0,
                     p_scdl_scde,
                     l_hs,
                     p_scdl_st,
                     p_scdl_message,
                     p_scdl_st_old,
                     NVL (p_scdl_tp, 'SYS'));
    END;

    --Реєстрація події отримання нової довідки ВПО
    PROCEDURE make_new_document (
        p_scde_scd       scd_event.scde_scd%TYPE,
        p_scde_dt        scd_event.scde_dt%TYPE,
        p_scde_message   scd_event.scde_message%TYPE)
    IS
        l_msg   scd_event.scde_message%TYPE;
    BEGIN
        l_msg := NVL (p_scde_message, CHR (38) || '168');

        INSERT INTO scd_event (scde_id,
                               scde_sc,
                               scde_scd,
                               scde_event,
                               scde_st,
                               scde_dt,
                               scde_message,
                               scde_rc)
            SELECT 0,
                   scd_sc,
                   scd_id,
                   'CR',
                   'E',
                   p_scde_dt,
                   l_msg,
                   NULL
              FROM sc_document
             WHERE scd_id = p_scde_scd;
    END;

    --Реєстрація події припинення дії довідки ВПО
    PROCEDURE close_document (p_scde_scd       scd_event.scde_scd%TYPE,
                              p_scde_dt        scd_event.scde_dt%TYPE,
                              p_scde_message   scd_event.scde_message%TYPE)
    IS
        l_msg   scd_event.scde_message%TYPE;
    BEGIN
        l_msg := NVL (p_scde_message, CHR (38) || '169');

        INSERT INTO scd_event (scde_id,
                               scde_sc,
                               scde_scd,
                               scde_event,
                               scde_st,
                               scde_dt,
                               scde_message,
                               scde_rc)
            SELECT 0,
                   scd_sc,
                   scd_id,
                   'CL',
                   'E',
                   p_scde_dt,
                   l_msg,
                   NULL
              FROM sc_document
             WHERE scd_id = p_scde_scd;
    END;

    --Реєстрація події модифікації документа
    PROCEDURE update_document (p_scde_scd       scd_event.scde_scd%TYPE,
                               p_scde_dt        scd_event.scde_dt%TYPE,
                               p_scde_message   scd_event.scde_message%TYPE)
    IS
        l_msg   scd_event.scde_message%TYPE;
    BEGIN
        l_msg := NVL (p_scde_message, CHR (38) || '271');

        INSERT INTO scd_event (scde_id,
                               scde_sc,
                               scde_scd,
                               scde_event,
                               scde_st,
                               scde_dt,
                               scde_message,
                               scde_rc)
            SELECT 0,
                   scd_sc,
                   scd_id,
                   'UP',
                   'E',
                   p_scde_dt,
                   l_msg,
                   NULL
              FROM sc_document
             WHERE scd_id = p_scde_scd;
    END;

    --Фіксація помилки повязаної з документом
    PROCEDURE save_doc_error (p_scde_scd       scd_event.scde_scd%TYPE,
                              p_scde_dt        scd_event.scde_dt%TYPE,
                              p_scde_message   scd_event.scde_message%TYPE)
    IS
    BEGIN
        INSERT INTO scd_event (scde_id,
                               scde_sc,
                               scde_scd,
                               scde_event,
                               scde_st,
                               scde_dt,
                               scde_message,
                               scde_rc)
            SELECT 0,
                   scd_sc,
                   scd_id,
                   'ER',
                   'E',
                   p_scde_dt,
                   p_scde_message,
                   NULL
              FROM sc_document
             WHERE scd_id = p_scde_scd;
    END;

    PROCEDURE use_by_rc (p_mode           INTEGER, --1=за p_scde_id, 2=за ідами з табилці tmp_work_ids
                         p_scde_id        scd_event.scde_id%TYPE,
                         p_scde_rc        scd_event.scde_rc%TYPE,
                         p_scde_message   scd_event.scde_message%TYPE)
    IS
        l_hs_id   histsession.hs_id%TYPE;
    BEGIN
        IF p_mode = 1
        THEN
            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set1 (x_id1, x_string1)
                SELECT scde_id, scde_st
                  FROM scd_event
                 WHERE scde_id = p_scde_id;
        ELSIF p_mode = 2
        THEN
            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set1 (x_id1, x_string1)
                SELECT scde_id, scde_st
                  FROM scd_event, tmp_work_ids
                 WHERE scde_id = x_id;
        ELSE
            raise_application_error (
                '-20100',
                   'Режим '
                || p_mode
                || ' функцією використання події з документами - не підтримується!');
        END IF;

        UPDATE scd_event
           SET scde_rc = p_scde_rc, scde_st = 'U'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set1
                     WHERE x_id1 = scde_id);

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs_id := TOOLS.GetHistSession;

            FOR xx IN (SELECT x_id1, x_string1 FROM tmp_work_set1)
            LOOP
                write_scde_log (xx.x_id1,
                                l_hs_id,
                                'U',
                                CHR (38) || '145#' || p_scde_rc || '#',
                                xx.x_string1);

                IF p_scde_message IS NOT NULL
                THEN
                    write_scde_log (xx.x_id1,
                                    l_hs_id,
                                    'U',
                                    p_scde_message,
                                    xx.x_string1);
                END IF;
            END LOOP;
        END IF;
    END;

    FUNCTION tonumber (val VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (val);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN -1;
    END;

    PROCEDURE Execute_Event_VPO (p_id NUMBER DEFAULT NULL)
    IS
        l_hs     histsession.hs_id%TYPE;
        l_lock   TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'EXECUTE_EVENT_VPO',
                p_error_msg   =>
                    'В даний момент вже виконується обробка довідок ВПО');

        l_hs := TOOLS.GetHistSession;

        --зальемо черго для обробки
        DELETE FROM TMP_EVENT_VPO
              WHERE 1 = 1;

        DELETE FROM uss_esr.tmp_event2decision
              WHERE 1 = 1;

        IF p_id IS NULL
        THEN
            INSERT INTO TMP_EVENT_VPO (X_SCDE,
                                       X_SC,
                                       X_SCD,
                                       X_DOC,
                                       X_DH,
                                       X_COM_ORG,
                                       X_DOC_DT,
                                       X_CH_ADDR,
                                       X_PC,
                                       X_PC_COM_ORG,
                                       X_ACTION)
                SELECT e.scde_id
                           AS x_scde,
                       e.scde_sc
                           AS x_sc,
                       e.scde_scd
                           AS x_scd,
                       d.scd_doc
                           AS x_doc,
                       d.scd_dh
                           AS x_dh,
                       --a.*,
                       API$SCD_EVENT.tonumber (
                           NVL (
                               (SELECT nddc_code_dest
                                  FROM uss_ndi.v_ndi_decoding_config
                                 WHERE     nddc_tp = 'ORG_MIGR'
                                       AND nddc_code_src =
                                              '5'
                                           || LPAD (
                                                  SUBSTR (
                                                      da_val_string,
                                                      1,
                                                        INSTR (da_val_string,
                                                               '-')
                                                      - 1),
                                                  4,
                                                  '0')),
                                  '5'
                               || LPAD (
                                      SUBSTR (da_val_string,
                                              1,
                                              INSTR (da_val_string, '-') - 1),
                                      4,
                                      '0')))
                           AS x_com_org,
                       (SELECT MAX (aa.da_val_dt)
                          FROM Uss_Doc.v_Doc_Attr2hist  hh
                               JOIN Uss_Doc.v_Doc_Attributes aa
                                   ON hh.Da2h_Da = aa.Da_Id
                         WHERE hh.da2h_dh = scd_dh AND aa.da_nda = 1757)
                           AS x_doc_dt,
                       NVL (
                           (SELECT MAX (aa.da_val_string)
                              FROM Uss_Doc.v_Doc_Attr2hist  hh
                                   JOIN Uss_Doc.v_Doc_Attributes aa
                                       ON hh.Da2h_Da = aa.Da_Id
                             WHERE hh.da2h_dh = scd_dh AND aa.da_nda = 2833),
                           'F')
                           AS x_ch_addr,
                       pc.pc_id
                           AS x_pc,
                       pc.com_org
                           AS x_pc_com_org,
                       'NEW'
                  FROM uss_person.v_scd_event  e
                       JOIN uss_person.v_sc_document d
                           ON scd_id = scde_scd AND scd_ndt = 10052
                       JOIN Uss_Doc.v_Doc_Attr2hist h ON h.da2h_dh = scd_dh
                       JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
                       LEFT JOIN uss_esr.v_personalcase pc
                           ON pc.pc_sc = e.scde_sc
                 WHERE     scde_event = 'CR'
                       AND scde_st = 'E'
                       AND a.da_nda IN (1756)
                       AND da_val_string LIKE '%-%';
        ELSE
            INSERT INTO TMP_EVENT_VPO (X_SCDE,
                                       X_SC,
                                       X_SCD,
                                       X_DOC,
                                       X_DH,
                                       X_COM_ORG,
                                       X_DOC_DT,
                                       X_CH_ADDR,
                                       X_PC,
                                       X_PC_COM_ORG,
                                       X_ACTION)
                SELECT e.scde_id
                           AS x_scde,
                       e.scde_sc
                           AS x_sc,
                       e.scde_scd
                           AS x_scd,
                       d.scd_doc
                           AS x_doc,
                       d.scd_dh
                           AS x_dh,
                       --a.*,
                       API$SCD_EVENT.tonumber (
                           NVL (
                               (SELECT nddc_code_dest
                                  FROM uss_ndi.v_ndi_decoding_config
                                 WHERE     nddc_tp = 'ORG_MIGR'
                                       AND nddc_code_src =
                                              '5'
                                           || LPAD (
                                                  SUBSTR (
                                                      da_val_string,
                                                      1,
                                                        INSTR (da_val_string,
                                                               '-')
                                                      - 1),
                                                  4,
                                                  '0')),
                                  '5'
                               || LPAD (
                                      SUBSTR (da_val_string,
                                              1,
                                              INSTR (da_val_string, '-') - 1),
                                      4,
                                      '0')))
                           AS x_com_org,
                       (SELECT MAX (aa.da_val_dt)
                          FROM Uss_Doc.v_Doc_Attr2hist  hh
                               JOIN Uss_Doc.v_Doc_Attributes aa
                                   ON hh.Da2h_Da = aa.Da_Id
                         WHERE hh.da2h_dh = scd_dh AND aa.da_nda = 1757)
                           AS x_doc_dt,
                       NVL (
                           (SELECT MAX (aa.da_val_string)
                              FROM Uss_Doc.v_Doc_Attr2hist  hh
                                   JOIN Uss_Doc.v_Doc_Attributes aa
                                       ON hh.Da2h_Da = aa.Da_Id
                             WHERE hh.da2h_dh = scd_dh AND aa.da_nda = 2833),
                           'F')
                           AS x_ch_addr,
                       pc.pc_id
                           AS x_pc,
                       pc.com_org
                           AS x_pc_com_org,
                       'NEW'
                  FROM uss_person.v_scd_event  e
                       JOIN uss_person.v_sc_document d
                           ON scd_id = scde_scd AND scd_ndt = 10052
                       JOIN Uss_Doc.v_Doc_Attr2hist h ON h.da2h_dh = scd_dh
                       JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
                       LEFT JOIN uss_esr.v_personalcase pc
                           ON pc.pc_sc = e.scde_sc
                 WHERE     scde_event = 'CR'
                       AND scde_st = 'E'
                       AND a.da_nda IN (1756)
                       AND da_val_string LIKE '%-%'
                       AND scde_id = p_id;
        END IF;

        -- Визначимо тих, кого просто прикрити.
        UPDATE TMP_EVENT_VPO
           SET x_action = 'DEL'
         WHERE x_com_org = x_pc_com_org OR x_pc IS NULL OR x_ch_addr != 'T';

        DELETE FROM uss_person.TMP_EVENT_VPO t
              WHERE     t.x_action = 'NEW'
                    AND t.x_doc_dt !=
                        (SELECT MIN (tt.x_doc_dt)
                           FROM uss_person.TMP_EVENT_VPO tt
                          WHERE tt.x_pc = t.x_pc AND tt.x_action = 'NEW');

        -- Перевіримо на наявність рішень.
        INSERT INTO uss_esr.tmp_event2decision (x_scde,
                                                x_com_org,
                                                x_doc_dt,
                                                x_pc,
                                                x_pc_com_org)
            SELECT t.x_scde,
                   t.x_com_org,
                   t.x_doc_dt,
                   t.x_pc,
                   t.x_pc_com_org
              FROM TMP_EVENT_VPO t
             WHERE t.x_action = 'NEW';

        uss_esr.API$Person2ESR.Check_Decision;

        -- Визначимо тих, в кого немає рішень
        UPDATE TMP_EVENT_VPO t
           SET t.x_action = 'NOT DEC'
         WHERE     EXISTS
                       (SELECT 1
                          FROM uss_esr.tmp_event2decision ted
                         WHERE     ted.x_scde = t.x_scde
                               AND ted.x_cnt_pd = 0
                               AND ted.x_cnt_pd_ps = 0)
               AND t.x_action = 'NEW';


        --прикриємо ті, що не змінювались.
        --з записом в лог події (scd_log) шаблонізованого повідомлення про те, що обробка події Появи нової довідки ВПО нічого не зміює, бо ОСЗН співпаюать;
        UPDATE uss_person.v_scd_event
           SET scde_st = 'A'
         WHERE EXISTS
                   (SELECT 1
                      FROM TMP_EVENT_VPO
                     WHERE scde_id = x_scde AND x_action != 'NEW');

        INSERT INTO scd_log (scdl_id,
                             scdl_scde,
                             scdl_hs,
                             scdl_st,
                             scdl_message,
                             scdl_st_old,
                             scdl_tp)
            SELECT 0,
                   e.x_scde,
                   l_hs,
                   'A',
                   CHR (38) || '187',
                   'CR',
                   'SYS'
              FROM TMP_EVENT_VPO e
             WHERE x_action != 'NEW';

        --Тепер запхаємо в vasit шаблонні звернення
        INSERT INTO uss_visit.tmp_event2appeal (x_scde,
                                                x_sc,
                                                x_scd,
                                                x_doc,
                                                x_dh,
                                                x_com_org,
                                                x_doc_dt,
                                                x_pc)
            SELECT a.x_scde,
                   a.x_sc,
                   a.x_scd,
                   a.x_doc,
                   a.x_dh,
                   a.x_com_org,
                   a.x_doc_dt,
                   a.x_pc
              FROM uss_person.TMP_EVENT_VPO a
             WHERE x_action = 'NEW';

        uss_visit.API$Person2Visit.Event2Appeal;

        DELETE FROM uss_esr.tmp_event2decision
              WHERE 1 = 1;

        INSERT INTO uss_esr.tmp_event2decision (x_scde,
                                                x_com_org,
                                                x_doc_dt,
                                                x_pc,
                                                x_pc_com_org,
                                                x_ap)
            SELECT tea.x_scde,
                   tea.x_com_org,
                   tea.x_doc_dt,
                   t.x_pc,
                   t.x_pc_com_org,
                   tea.x_ap
              FROM uss_visit.tmp_event2appeal  tea
                   JOIN TMP_EVENT_VPO t ON t.x_scde = tea.x_scde;

        uss_esr.API$Person2ESR.Event2Decision;

        --uss_esr.API$Person2ESR.Event2Decision_ps;

        UPDATE uss_person.v_scd_event
           SET scde_st = 'A'
         WHERE EXISTS
                   (SELECT 1
                      FROM TMP_EVENT_VPO
                     WHERE scde_id = x_scde AND x_action = 'NEW');

        INSERT INTO scd_log (scdl_id,
                             scdl_scde,
                             scdl_hs,
                             scdl_st,
                             scdl_message,
                             scdl_st_old,
                             scdl_tp)
            SELECT 0,
                   e.x_scde,
                   l_hs,
                   'A',
                   CHR (38) || '188',
                   'CR',
                   'SYS'
              FROM TMP_EVENT_VPO e
             WHERE x_action = 'NEW';

        TOOLS.release_lock (l_lock);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.release_lock (l_lock);
            RAISE;
    END;
BEGIN
    -- Initialization
    NULL;
END API$SCD_EVENT;
/