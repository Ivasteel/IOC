/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$RNSP_ACTION
IS
    -- Author  : OLEKSII
    -- Created : 19.10.2021 10:24:39
    -- Purpose : Обработка очереди на копирование из Visit в ESR

    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --==========================================
    PROCEDURE Start_Queue;

    PROCEDURE Stop_Queue;

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    PROCEDURE PrepareWrite_Visit_ap_log (
        p_apl_ap        ap_log.apl_ap%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_WU            histsession.hs_wu%TYPE:= NULL);

    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE PrepareCopy_RNSP2Visit (
        p_ap        appeal.ap_id%TYPE,
        p_ST_OLD    rnsp2visit_actions.rva_st_old%TYPE,
        p_message   rnsp2visit_actions.rva_message%TYPE);

    --==========================================
    --  Обработка очереди
    --  Commit;
    --==========================================
    PROCEDURE Copy_doc_RNSP2Visit730 (p_ap_id    appeal.ap_id%TYPE,
                                      p_Com_Wu   appeal.com_wu%TYPE);

    PROCEDURE Copy_RNSP2Visit;
END API$RNSP_Action;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$RNSP_ACTION
IS
    g_hs   histsession.hs_id%TYPE;

    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --==========================================
    PROCEDURE Start_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsrnsp
           SET prm_value = '1'
         WHERE prm_code = 'CR2V';

        COMMIT;
    END;

    --==========================================
    PROCEDURE Stop_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsrnsp
           SET prm_value = '0'
         WHERE prm_code = 'CR2V';

        COMMIT;
    END;

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    --#73634 2021.12.02
    PROCEDURE write_Visit_ap_log (
        p_apl_ap        ap_log.apl_ap%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_WU            histsession.hs_wu%TYPE:= NULL)
    IS
        CURSOR ap IS
            SELECT ap_id, ap_st
              FROM appeal
             WHERE ap_id = p_apl_ap;
    BEGIN
        FOR p IN ap
        LOOP
            uss_visit.api$ap_processing.Write_Log (p.Ap_Id,
                                                   p.Ap_St,
                                                   p_Apl_Message,
                                                   p.Ap_St,
                                                   p_apl_tp,
                                                   p_WU);
        END LOOP;

        NULL;
    END;

    --==========================================
    --  Логирование
    --==========================================
    PROCEDURE LOG (p_rva       RNSP2visit_actions.rva_id%TYPE,
                   p_message   rva_log.rval_message%TYPE)
    IS
    BEGIN
        IF g_hs IS NULL
        THEN
            g_hs := TOOLS.GetHistSessionA ();
        END IF;

        INSERT INTO rva_log (rval_id,
                             rval_rva,
                             rval_hs,
                             rval_message)
             VALUES (0,
                     p_rva,
                     g_hs,
                     p_message);
    END;

    --==========================================
    PROCEDURE LogA (p_message rva_log.rval_message%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        LOG (NULL, p_message);
        COMMIT;
    END;

    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE PrepareCopy_RNSP2Visit (
        p_ap        appeal.ap_id%TYPE,
        p_ST_OLD    rnsp2visit_actions.rva_st_old%TYPE,
        p_message   rnsp2visit_actions.rva_message%TYPE)
    IS
        l_RVA   NUMBER;
    BEGIN
        g_hs := TOOLS.GetHistSession ();

        SELECT sq_id_rnsp2visit_actions.NEXTVAL INTO l_rva FROM DUAL;

        INSERT INTO rnsp2visit_actions (rva_id,
                                        rva_ap,
                                        rva_tp,
                                        rva_st_new,
                                        rva_st_old,
                                        rva_message,
                                        rva_hs_ins,
                                        rva_hs_exec)
            SELECT l_rva,
                   Ap_Id,
                   Ap_TP,
                   Ap_St,
                   p_ST_OLD,
                   p_message,
                   g_hs,
                   -1
              FROM Appeal
             WHERE Ap_Id = p_Ap;

        IF SQL%ROWCOUNT > 0
        THEN
            LOG (l_rva, CHR (38) || '24#' || p_ap);
        ELSE
            LOG (NULL, CHR (38) || '25#' || p_ap);
        END IF;
    END;

    --==========================================
    --  Логирование в Visit.ap_log
    --==========================================
    --#73634 2021.12.02
    PROCEDURE PrepareWrite_Visit_ap_log (
        p_apl_ap        ap_log.apl_ap%TYPE,
        p_apl_message   ap_log.apl_message%TYPE,
        p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS',
        p_WU            histsession.hs_wu%TYPE:= NULL)
    IS
        l_RVA   NUMBER;

        CURSOR ap IS
            SELECT ap_id, Ap_TP, ap_st
              FROM appeal
             WHERE ap_id = p_apl_ap;
    BEGIN
        g_hs := TOOLS.GetHistSession ();

        FOR p IN ap
        LOOP
            SELECT sq_id_rnsp2visit_actions.NEXTVAL INTO l_rva FROM DUAL;

            INSERT INTO rnsp2visit_actions (rva_id,
                                            rva_ap,
                                            rva_tp,
                                            rva_st_new,
                                            rva_st_old,
                                            rva_message,
                                            rva_hs_ins,
                                            rva_hs_exec)
                 VALUES (l_rva,
                         p.Ap_Id,
                         p.Ap_TP,
                         p.Ap_St,
                         p.Ap_ST,
                         p_apl_message,
                         g_hs,
                         -1);

            IF SQL%ROWCOUNT > 0
            THEN
                LOG (l_rva, CHR (38) || '24#' || p.ap_id);
            ELSE
                LOG (NULL, CHR (38) || '25#' || p.ap_id);
            END IF;
        END LOOP;
    END;

    PROCEDURE Copy_doc_RNSP2Visit730 (p_ap_id    appeal.ap_id%TYPE,
                                      p_Com_Wu   appeal.com_wu%TYPE)
    IS
        l_Apd_Doc   ap_Document.Apd_Doc%TYPE;
        l_Apd_Dh    ap_Document.apd_Dh%TYPE;
        l_doc_atr   SYS_REFCURSOR;
    BEGIN
        FOR data_rec
            IN (SELECT rnd.rnd_id, rnd.rnd_doc, rnd.rnd_dh
                  FROM rn_document rnd
                 WHERE     rnd_ap = p_ap_id
                       AND rnd_ndt = 730
                       AND rnd.history_status = 'A')
        LOOP
            l_Apd_Doc := data_rec.rnd_doc;
            l_Apd_Dh := data_rec.rnd_dh;

            OPEN l_doc_atr FOR SELECT rnda.rnda_nda,
                                      rnda.rnda_val_int,
                                      rnda.rnda_val_sum,
                                      rnda.rnda_val_id,
                                      rnda.rnda_val_dt,
                                      rnda.rnda_val_string
                                 FROM rn_document_attr rnda
                                WHERE     rnda.rnda_rnd = data_rec.rnd_id
                                      AND rnda.rnda_nda IN (1112,
                                                            1113,
                                                            1114,
                                                            1115,
                                                            1116,
                                                            1117,
                                                            1118,
                                                            1119)
                                      AND rnda.history_status = 'A';
        END LOOP;

        dbms_output_put_lines (l_Apd_Doc);
        dbms_output_put_lines (l_Apd_Dh);
        dbms_output_put_lines (p_Com_Wu);

        uss_visit.api$ap_processing.Create_document730 (p_ap_id,
                                                        l_Apd_Doc,
                                                        l_Apd_Dh,
                                                        p_Com_Wu,
                                                        l_doc_atr);
    END;

    --==========================================
    PROCEDURE Copy_doc_RNSP2Visit740 (p_ap_id    appeal.ap_id%TYPE,
                                      p_Com_Wu   appeal.com_wu%TYPE)
    IS
        l_Apd_id    ap_Document.Apd_Doc%TYPE;
        l_Apd_Doc   ap_Document.Apd_Doc%TYPE;
        l_Apd_Dh    ap_Document.apd_Dh%TYPE;
    BEGIN
        FOR data_rec
            IN (SELECT rnd.rnd_doc, rnd.rnd_dh, rnd.rnd_apd
                  FROM rn_document rnd
                 WHERE     rnd_ap = p_ap_id
                       AND rnd_ndt = 740
                       AND rnd.history_status = 'A')
        LOOP
            l_Apd_id := data_rec.rnd_apd;
            l_Apd_Doc := data_rec.rnd_doc;
            l_Apd_Dh := data_rec.rnd_dh;
        END LOOP;

        dbms_output_put_lines (l_Apd_Doc);
        dbms_output_put_lines (l_Apd_Dh);
        dbms_output_put_lines (p_Com_Wu);

        uss_visit.api$ap_processing.Update_document_pdf (l_Apd_id,
                                                         l_Apd_Doc,
                                                         l_Apd_Dh);
    END;

    --==========================================
    --  Копирование в Visit
    --==========================================
    PROCEDURE Copy_RNSP2Visit
    IS
        CopyingAllowed   VARCHAR2 (20);
        l_Lock_Handle    Tools.t_Lockhandler;
        l_apl_tp         ap_log.apl_tp%TYPE := 'SYS';
        sqlrowcount      NUMBER;

        CURSOR ESR2VISIT IS
            SELECT rva_ap,
                   rva_message,
                   rva_st_new,
                   rva_st_old,
                   hs.hs_wu,
                   hs.hs_id
              FROM RNSP2VISIT_ACTIONS
                   JOIN tmp_work_ids ON rva_ap = x_id
                   LEFT JOIN histsession hs ON hs.hs_id = RVA_HS_INS
             WHERE rva_hs_exec = -1;
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        --Перевіремо, чи дозволено працовати
        SELECT NVL (MAX (prm_value), '0')
          INTO CopyingAllowed
          FROM paramsrnsp p
         WHERE prm_code = 'CR2V';

        IF CopyingAllowed != '1'
        THEN
            RETURN;
        END IF;

        --Блокуємо чергу
        l_Lock_Handle := Tools.Request_Lock (p_Descr => 'Copy_RNSP2Visit');

        --
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        --
        --Збираємо звернення з черги на повернення до редагування
        --
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT rva.rva_ap
              FROM RNSP2VISIT_ACTIONS rva
             WHERE     rva.rva_tp IN ('G')
                   AND rva.rva_st_new IN ('B', 'X')
                   AND rva.rva_hs_exec = -1;              -- #74045 2021.12.13

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            g_hs := TOOLS.GetHistSession ();
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);

            --#73983 2021.12.09
            FOR p IN ESR2VISIT
            LOOP
                uss_visit.api$ap_processing.return_appeal_to_editing (
                    p.rva_ap,
                    p.rva_message,
                    p.hs_wu);
                Copy_doc_RNSP2Visit730 (p.rva_ap, p.hs_wu);
            END LOOP;

            --запит на копіювання
            UPDATE RNSP2VISIT_ACTIONS rva
               SET rva.rva_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = rva.rva_ap)
                   AND rva_hs_exec = -1;

            LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
        END IF;

        --
        --Збираємо звернення з черги, що підтвержено
        --
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT rva.rva_ap
              FROM RNSP2VISIT_ACTIONS rva
             WHERE     rva.rva_tp IN ('G')
                   AND rva.rva_st_new IN ('WI', 'V')
                   AND rva.rva_hs_exec = -1;              -- #74045 2021.12.13

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            g_hs := TOOLS.GetHistSession ();
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);

            --#73983 2021.12.09
            FOR p IN ESR2VISIT
            LOOP
                uss_visit.api$ap_processing.return_appeal_to_done (
                    p.rva_ap,
                    p.rva_message,
                    p.hs_wu);
                Copy_doc_RNSP2Visit730 (p.rva_ap, p.hs_wu);
                api$find.Write_Log (p.rva_ap,
                                    p.hs_id,
                                    p.rva_st_new,
                                    p.rva_message,
                                    p.rva_st_old,
                                    l_apl_tp);
            END LOOP;

            --запит на копіювання
            UPDATE RNSP2VISIT_ACTIONS rva
               SET rva.rva_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = rva.rva_ap)
                   AND rva_hs_exec = -1;

            LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
        END IF;

        --
        --Збираємо звернення з черги, що підтвержено
        --
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT rva.rva_ap
              FROM RNSP2VISIT_ACTIONS rva
             WHERE     rva.rva_tp IN ('D')
                   AND rva.rva_st_new IN ('WI', 'V')
                   AND rva.rva_hs_exec = -1;              -- #74045 2021.12.13

        sqlrowcount := SQL%ROWCOUNT;

        --log(null, ' D  WI V > '||sqlrowcount);

        IF sqlrowcount > 0
        THEN
            g_hs := TOOLS.GetHistSession ();
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);

            --#73983 2021.12.09
            FOR p IN ESR2VISIT
            LOOP
                uss_visit.api$ap_processing.return_appeal_to_done (
                    p.rva_ap,
                    p.rva_message,
                    p.hs_wu);
                Copy_doc_RNSP2Visit740 (p.rva_ap, p.hs_wu);
                api$find.Write_Log (p.rva_ap,
                                    p.hs_id,
                                    p.rva_st_new,
                                    p.rva_message,
                                    p.rva_st_old,
                                    l_apl_tp);
            END LOOP;

            --запит на копіювання
            UPDATE RNSP2VISIT_ACTIONS rva
               SET rva.rva_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = rva.rva_ap)
                   AND rva_hs_exec = -1;

            LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
        END IF;



        --Збираємо звернення з черги на передaчу лога
        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT rva.rva_ap
              FROM RNSP2VISIT_ACTIONS rva
             WHERE     rva.rva_tp IN ('G')
                   AND rva.rva_st_new NOT IN ('B', 'X')
                   AND rva.rva_hs_exec = -1;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount > 0
        THEN
            g_hs := NVL (g_hs, TOOLS.GetHistSession ());

            FOR p IN ESR2VISIT
            LOOP
                uss_visit.api$ap_processing.Write_Log (p.rva_ap,
                                                       p.rva_st_new,
                                                       p.rva_message,
                                                       p.rva_st_old,
                                                       l_apl_tp,
                                                       p.hs_wu);
            END LOOP;

            UPDATE RNSP2VISIT_ACTIONS rva
               SET rva.rva_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = rva.rva_ap)
                   AND rva_hs_exec = -1;
        END IF;


        Tools.release_lock (p_lock_handler => l_Lock_Handle);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20000
            THEN
                logA (CHR (38) || '28#' || 'Чергу заблоковано');
            ELSE
                logA (CHR (38) || '28#' || SQLCODE || ' : ' || SQLERRM);

                IF l_Lock_Handle IS NOT NULL
                THEN
                    Tools.release_lock (p_lock_handler => l_Lock_Handle);
                END IF;
            END IF;
    END;
END API$RNSP_Action;
/