/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$APP_EXCHANGE_PPVP
IS
    -- Author  : OLEG
    -- Created : 23.09.2020 12:58:21
    -- Purpose : Обробка вхідних пакетів

    --------------------------------------------------
    --Обробка вхідних пакетів-квитанцій
    --------------------------------------------------
    PROCEDURE process_input_responses;

    --------------------------------------------------
    --Обробка вхідних пакетів
    --------------------------------------------------
    PROCEDURE process_input_packages;

    --------------------------------------------------
    -- Повертає значення параметру з таблиці ikis_rbm.param_rbm
    --------------------------------------------------
    FUNCTION get_param (p_param_name VARCHAR2, p_format VARCHAR2)
        RETURN DATE;
--------------------------------------------------
END rdm$app_exchange_PPVP;
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$APP_EXCHANGE_PPVP
IS
    --------------------------------------------------
    --Обробка вхідних пакетів-квитанцій
    --------------------------------------------------
    PROCEDURE process_input_responses
    IS
        l_file_idn       VARCHAR2 (15);
        l_cnt_tosend     NUMBER;
        --Дата початку завантаження вхідних пакетів з ПЕОД до ППВП(крім pt_id=22)
        l_peod2ppvp_dt   DATE := get_param ('PEOD2PPVP_DT', 'dd.mm.yyyy');
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        DBMS_OUTPUT.put_line (TO_CHAR (l_peod2ppvp_dt, 'dd.mm.yyyy'));

        DELETE FROM tmp_exchangefiles_m2;

        FOR pp
            IN (SELECT ROW_NUMBER ()
                           OVER (PARTITION BY pl_pkt_out
                                 ORDER BY p.pkt_create_dt ASC)
                           rn,
                       (SELECT COUNT (*)
                          FROM ikis_rbm.packet_links  pl2
                               JOIN ikis_rbm.packet p2
                                   ON     p2.pkt_id = pl2.pl_pkt_in
                                      AND p2.pkt_st = 'PRC'
                         --where pl2.pl_pkt_out = pl.pl_pkt_out) as  prc_cnt,
                         WHERE     pl2.pl_pkt_out = pl.pl_pkt_out
                               AND p2.pkt_pt = p.pkt_pt)
                           AS prc_cnt,
                       CASE
                           WHEN pc.pc_file_idn IS NULL
                           THEN
                               pc.pc_data
                           ELSE
                               ikis_sysweb.ikis_file_archive.getFile (
                                   pc.pc_file_idn)
                       END
                           pc_data_blob,
                       pl_pkt_out,
                       (SELECT pc_src_entity
                          FROM ikis_rbm.packet_content
                         WHERE pc_pkt = pl_pkt_out)
                           AS parent_src_entity,
                       p.*,
                       pc.*
                  FROM ikis_rbm.packet  p
                       JOIN ikis_rbm.packet_content pc
                           ON pc.pc_pkt = p.pkt_id
                       JOIN ikis_rbm.packet_links pl
                           ON pl.pl_pkt_in = p.pkt_id
                 WHERE     p.pkt_st = 'N'
                       --and p.pkt_create_dt >= to_date('22.12.2020','dd.mm.yyyy')
                       AND p.pkt_create_dt >= l_peod2ppvp_dt
                       AND p.pkt_pt IN (29, --death_reply_ppvp ПСП: Відповідь банку ППВП ПСП Відповідь ППВП 4 A I
                                            31, --verification_state_ppvp ВД: Повідомлення про обробку пакету верифікації ідентифікаційних даних ППВП ВД Відповідь банку ППВП 4 A I
                                                23 --payrollpassport_answer_ppvp Квитанція банку про опрацювання файлу зі списками ППВП Квитанція ВВ ППВП 4 A I
                                                  ))
        LOOP
            -- Запвантаження нових, коли надыйшло вперше
            IF pp.prc_cnt = 0 AND pp.rn = 1 AND pp.pkt_st = 'N'
            THEN
                BEGIN
                    -- Заливаємо файл в ППВП. Вся подальша обробка - на стороні ППВП.
                    l_file_idn :=
                        ikis_sysweb.ikis_file_archive.putFile (
                            p_wfs_code    => 'PPVP1',
                            p_filename    => pp.pc_name,
                            p_org         => pp.pkt_org,
                            p_wu          => NULL,
                            p_file_data   => pp.pc_data_blob);

                    INSERT INTO tmp_exchangefiles_m2 (ef_id,
                                                      ef_psp,
                                                      ef_wu,
                                                      ef_org,
                                                      ef_name,
                                                      ef_data,
                                                      ef_visual_data,
                                                      ef_header,
                                                      ef_main_tag_name,
                                                      ef_data_name,
                                                      ef_ecp_list_name,
                                                      ef_ecp_name,
                                                      ef_ecp_alg,
                                                      ef_st,
                                                      ef_dt,
                                                      ef_ident_data,
                                                      ef_rec,
                                                      ef_ef)
                         VALUES (0,
                                 NULL,
                                 NULL,
                                 pp.pkt_org,
                                 pp.pc_name,
                                 pp.pc_data_blob,
                                 pp.pc_visual_data,
                                 pp.pc_header,
                                 pp.pc_main_tag_name,
                                 pp.pc_data_name,
                                 pp.pc_ecp_list_name,
                                 pp.pc_ecp_name,
                                 pp.pc_ecp_alg,
                                 pp.pkt_st,
                                 pp.pkt_create_dt,
                                 NULL,
                                 pp.pkt_rec,
                                 pp.parent_src_entity);


                    rdm$packet.set_packet_state (v_pkt_id          => pp.pkt_id,
                                                 v_pkt_st          => 'PRC',
                                                 v_pkt_change_wu   => NULL,
                                                 v_pkt_change_dt   => SYSDATE);

                    ikis_rbm.rdm$log_packet.insert_message (
                        p_lp_pkt       => pp.pkt_id,
                        p_lp_atp       => 'PRCS',
                        p_lp_comment   => '&15' || '(pkt_st =>PRC)');
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        rdm$packet.set_packet_state (
                            v_pkt_id          => pp.pkt_id,
                            v_pkt_st          => 'M',
                            v_pkt_change_wu   => NULL,
                            v_pkt_change_dt   => SYSDATE);

                        ikis_rbm.rdm$log_packet.insert_message (
                            p_lp_pkt       => pp.pkt_id,
                            p_lp_atp       => 'PRCS',
                            p_lp_comment   => '&115#' || '(pkt_st =>M)');
                END;
            -- Переведення нових у статус видалено,
            -- коли квитанції по первинних пакетах вже були раніше
            ELSIF pp.pkt_st = 'N'
            THEN
                rdm$packet.set_packet_state (v_pkt_id          => pp.pkt_id,
                                             v_pkt_st          => 'D',
                                             v_pkt_change_wu   => NULL,
                                             v_pkt_change_dt   => SYSDATE);

                ikis_rbm.rdm$log_packet.insert_message (
                    p_lp_pkt       => pp.pkt_id,
                    p_lp_atp       => 'PRCS',
                    p_lp_comment   => '&6' || '(pkt_st =>D)');
            END IF;
        END LOOP;

        SELECT COUNT (*) INTO l_cnt_tosend FROM tmp_exchangefiles_m2;

        IF l_cnt_tosend > 0
        THEN
            ikis_ppvp.get_rbm_packets_n;
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'RDM$APP_EXCHANGE_PPVP.process_input_responses:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END process_input_responses;

    --------------------------------------------------
    --Обробка вхідних пакетів
    --------------------------------------------------
    PROCEDURE process_input_packages
    IS
        l_cnt_tosend     NUMBER;
        --Дата початку завантаження вхідних пакетів з ПЕОД до ППВП(крім pt_id=22)
        l_peod2ppvp_dt   DATE := get_param ('PEOD2PPVP_DT', 'dd.mm.yyyy');
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        DELETE FROM tmp_exchangefiles_m2;

        FOR pp
            IN (SELECT p.*, pc.*
                  FROM packet p JOIN packet_content pc ON pc_pkt = pkt_id
                 WHERE     pkt_pt IN (10, --changeacc_ppvp Заміна рахунків ППВП ЗР ППВП I
                                          12 --notreceive_ppvp Не отримання коштів в банку ППВП НК ППВП I
                                            )
                       AND pkt_st = 'N'
                       --        and pkt_st = 'NVP'
                       --        and pc_ecp_check = 'T'
                       --        and p.pkt_create_dt >= to_date('22.12.2020','dd.mm.yyyy')
                       AND p.pkt_create_dt >= l_peod2ppvp_dt)
        LOOP
            BEGIN
                -- Заливаємо файл в ППВП. Вся подальша обробка - на стороні ППВП.
                INSERT INTO tmp_exchangefiles_m2 (ef_id,
                                                  ef_psp,
                                                  ef_wu,
                                                  ef_org,
                                                  ef_name,
                                                  ef_data,
                                                  ef_visual_data,
                                                  ef_header,
                                                  ef_main_tag_name,
                                                  ef_data_name,
                                                  ef_ecp_list_name,
                                                  ef_ecp_name,
                                                  ef_ecp_alg,
                                                  ef_st,
                                                  ef_dt,
                                                  ef_ident_data,
                                                  ef_rec,
                                                  ef_ef)
                     VALUES (0,
                             NULL,
                             NULL,
                             pp.pkt_org,
                             pp.pc_name,
                             pp.pc_data,
                             pp.pc_visual_data,
                             pp.pc_header,
                             pp.pc_main_tag_name,
                             pp.pc_data_name,
                             pp.pc_ecp_list_name,
                             pp.pc_ecp_name,
                             NULL,
                             pp.pkt_st,
                             pp.pkt_create_dt,
                             NULL,
                             pp.pkt_rec,
                             NULL);


                rdm$packet.set_packet_state (v_pkt_id          => pp.pkt_id,
                                             v_pkt_st          => 'PRC',
                                             v_pkt_change_wu   => NULL,
                                             v_pkt_change_dt   => SYSDATE);

                ikis_rbm.rdm$log_packet.insert_message (
                    p_lp_pkt       => pp.pkt_id,
                    p_lp_atp       => 'PRCS',
                    p_lp_comment   => '&15' || '(pkt_st =>PRC)');
            EXCEPTION
                WHEN OTHERS
                THEN
                    rdm$packet.set_packet_state (v_pkt_id          => pp.pkt_id,
                                                 v_pkt_st          => 'M',
                                                 v_pkt_change_wu   => NULL,
                                                 v_pkt_change_dt   => SYSDATE);

                    ikis_rbm.rdm$log_packet.insert_message (
                        p_lp_pkt   => pp.pkt_id,
                        p_lp_atp   => 'PRCS',
                        p_lp_comment   =>
                               '&115#'
                            || '(pkt_st =>M)'
                            || SQLERRM
                            || CHR (10)
                            || DBMS_UTILITY.FORMAT_ERROR_STACK
                            || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            END;
        END LOOP;

        SELECT COUNT (*) INTO l_cnt_tosend FROM tmp_exchangefiles_m2;

        IF l_cnt_tosend > 0
        THEN
            ikis_ppvp.get_rbm_packets_n;
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'RDM$APP_EXCHANGE.processPostPaymentReplyPVP:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END process_input_packages;

    --------------------------------------------------
    -- Повертає значення параметру з таблиці ikis_rbm.param_rbm
    --------------------------------------------------
    FUNCTION get_param (p_param_name VARCHAR2, p_format VARCHAR2)
        RETURN DATE
    IS
        l_value   DATE;
    BEGIN
        SELECT TO_DATE (MAX (prm_value), p_format)
          INTO l_value
          FROM ikis_rbm.param_rbm p
         WHERE     prm_code = p_param_name
               AND prm_st = 'L'
               AND prm_start_dt <= SYSDATE
               AND (prm_stop_dt IS NULL OR prm_stop_dt > SYSDATE);

        RETURN l_value;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN l_value;
    END;
END rdm$app_exchange_PPVP;
/