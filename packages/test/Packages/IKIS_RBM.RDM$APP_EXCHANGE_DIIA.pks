/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$APP_EXCHANGE_DIIA
IS
    -- Author  : oivashchuk
    -- Created : 14.12.2020 12:43:11
    -- Purpose : Обмін пакетами зі списками на виплату одноразової матеріальної допомоги COVID19

    PROCEDURE GenPaketsFromTMPTable;

    -- процедура генерації пакетів Covid19
    --    p_ext_id           - ід файлу в ikis_person
    --    p_file_name        -  назва файлу    ??? COVID19listDDMMYYYY
    --    p_lines_diia       – загальна кількість рядків у списку що надійшов від порталу Дія;
    --    p_lines_exclusion  – кількість рядків зі списку порталу Дія які не пройшли підтвердження в ПФУ.
    --    p_total_sum_paid   – сума зарахування в пакеті (сума, яка підлягає зарахуванню на рахунки отримувачів допомоги, тобто: total_sum_paid = ?SumaCOVID19list – ?SumaCOVID19exclusion)
    --    p_data_diia        - BLOB, без base64 -- інформація отримана від порталу Дія (файл COVID19listDDMMYYYY.json та його КЕП) в base64-кодуванні попередньо заархівованй у ZIP-архів;
    --    p_data_exclusion   - файл COVID19exclusionDDMMYYYYHHMM.csv, що містить перелік записів які потрібно виключити з  COVID19listDDMMYYYY.json
    --    p_pkt_id           - ід пакету ПЕОД  ikis_rbm.packet.pkt_id
    PROCEDURE GenPaketsCovid19 (p_ext_id            IN     NUMBER,
                                p_file_name         IN     VARCHAR2,
                                p_lines_diia        IN     NUMBER,
                                p_lines_exclusion   IN     NUMBER,
                                p_total_sum_paid    IN     NUMBER,
                                p_data_diia         IN     BLOB,
                                p_data_exclusion    IN     BLOB,
                                p_pkt_id               OUT NUMBER);
END RDM$APP_EXCHANGE_DIIA;
/


GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE_DIIA TO IKIS_PERSON
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$APP_EXCHANGE_DIIA
IS
    PROCEDURE GenPaketsFromTMPTable
    IS
        l_pkt          packet.pkt_id%TYPE;
        l_sysdate      DATE := TRUNC (SYSDATE);
        l_mil2fin_on   VARCHAR2 (10);
    BEGIN
        NULL;
    /*  FOR cc IN (SELECT *
                 FROM tmp_exchangefiles_m1)
      LOOP
        l_pkt := ikis_rbm.RDM$PACKET.insert_packet(case
                                                     when cc.ef_main_tag_name = 'paymentlists' then 1
                                                     when cc.ef_main_tag_name = 'deadlists' then 5
                                                     when cc.ef_main_tag_name = 'verify' then 25--- ivashchuk 20170302 #21037
                                                   end, --- ivashchuk 20160816 #16916
                                                   --1,
                                                   1, cc.com_org, 'N',
                                                   NULL, SYSDATE, NULL, NULL, cc.ef_rec);
        ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content(l_pkt, 'F', cc.ef_name, cc.ef_data,
                                                          NULL, SYSDATE, cc.ef_visual_data, cc.ef_main_tag_name,
                                                          cc.ef_data_name, cc.ef_ecp_list_name, cc.ef_ecp_name, cc.ef_ecp_alg,
                                                          cc.ef_id, cc.ef_header);
      END LOOP;
    */
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$APP_EXCHANGE_DIIA.GenPaketsFromTMPTable:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;


    -- процедура генерації пакетів Covid19
    --    p_ext_id           - ід файлу в ikis_person
    --    p_file_name        -  назва файлу    ??? COVID19listDDMMYYYY
    --    p_lines_diia       – загальна кількість рядків у списку що надійшов від порталу Дія;
    --    p_lines_exclusion  – кількість рядків зі списку порталу Дія які не пройшли підтвердження в ПФУ.
    --    p_total_sum_paid   – сума зарахування в пакеті (сума, яка підлягає зарахуванню на рахунки отримувачів допомоги, тобто: total_sum_paid = ?SumaCOVID19list – ?SumaCOVID19exclusion)
    --    p_data_diia        - BLOB, без base64 -- інформація отримана від порталу Дія (файл COVID19listDDMMYYYY.json та його КЕП) в base64-кодуванні попередньо заархівованй у ZIP-архів;
    --    p_data_exclusion   - файл COVID19exclusionDDMMYYYYHHMM.csv, що містить перелік записів які потрібно виключити з  COVID19listDDMMYYYY.json
    --    p_pkt_id           - ід пакету ПЕОД  ikis_rbm.packet.pkt_id
    PROCEDURE GenPaketsCovid19 (p_ext_id            IN     NUMBER,
                                p_file_name         IN     VARCHAR2,
                                p_lines_diia        IN     NUMBER,
                                p_lines_exclusion   IN     NUMBER,
                                p_total_sum_paid    IN     NUMBER,
                                p_data_diia         IN     BLOB,
                                p_data_exclusion    IN     BLOB,
                                p_pkt_id               OUT NUMBER)
    IS
        l_pkt           packet.pkt_id%TYPE;
        l_pt_id         packet_type.pt_id%TYPE;
        l_rec_tp        recipient.rec_tp%TYPE;
        l_rec_id        recipient.rec_id%TYPE := 7;         -- Тільки Ощад!!!!
        l_header        packet_content.pc_header%TYPE;
        l_visual_data   CLOB;
        l_pkt_cnt       NUMBER;
        l_pkt_id        NUMBER;
        exPktExists     EXCEPTION;
        l_pkt_dt        DATE := SYSDATE;
    BEGIN
        -- перевірка на повторнк формування пакета по файлу
        SELECT COUNT (1), MAX (pkt_id)
          INTO l_pkt_cnt, l_pkt_id
          FROM packet p JOIN packet_content pc ON pc.pc_pkt = p.pkt_id
         WHERE     p.pkt_es = 7
               AND p.pkt_pt = 71
               AND pc.pc_src_entity = p_ext_id
               AND pkt_st != 'D';

        IF l_pkt_cnt > 0
        THEN
            RAISE exPktExists;
        END IF;

        /*   select rec_id into l_rec_id
           from recipient
           where rec_code  = '';*/
        --   <lines_diia>25</lines_diia><lines_exclusion>13</lines_exclusion><total_sum_paid>96000</total_sum_paid>
        --• date_cr - дата створення пакету(в форматі ddmmyyyy)
        --• lines_diia – загальна кількість рядків у списку що надійшов від порталу Дія;
        --• lines_exclusion – кількість рядків зі списку порталу Дія які не пройшли підтвердження в ПФУ.
        --• total_sum_paid – сума зарахування в пакеті (сума, яка підлягає зарахуванню на рахунки отримувачів допомоги, тобто: total_sum_paid = ?SumaCOVID19list – ?SumaCOVID19exclusion)

        SELECT    XMLELEMENT ("date_cr", TO_CHAR (l_pkt_dt, 'ddmmyyyy'))
               || XMLELEMENT ("lines_diia", p_lines_diia)
               || XMLELEMENT ("lines_exclusion", p_lines_exclusion)
               || XMLELEMENT ("total_sum_paid", p_total_sum_paid)
          INTO l_header
          FROM DUAL;

        l_visual_data :=
               '<h1>'
            || p_file_name
            || '</h1>'
            || CHR (10)
            || '<p>'
            || 'К-ть рядків у списку, що надійшов від порталу Дія: '
            || p_lines_diia
            || '</p>'
            || CHR (10)
            || '<p>'
            || 'К-ть рядків, які не пройшли підтвердження в ПФУ: '
            || p_lines_exclusion
            || '</p>'
            || CHR (10)
            || '<p>'
            || 'Сума зарахування в пакеті: '
            || p_total_sum_paid
            || '</p>';
        l_pkt :=
            ikis_rbm.RDM$PACKET.insert_packet (71,
                                               7,
                                               28000            /*cc.com_org*/
                                                    ,
                                               'N',
                                               NULL,
                                               l_pkt_dt,
                                               NULL,
                                               NULL,
                                               l_rec_id);

        ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content (
            p_pc_pkt             => l_pkt,
            p_pc_tp              => 'F',
            p_pc_name            => p_file_name,
            p_pc_data            => UTL_COMPRESS.lz_compress (p_data_exclusion),
            p_pc_pkt_change_wu   => NULL,
            p_pc_pkt_change_dt   => l_pkt_dt,
            p_pc_visual_data     => l_visual_data,
            p_pc_main_tag_name   => 'list_covid19',
            p_pc_data_name       => 'file_data',
            p_pc_ecp_list_name   => 'ecp_list',
            p_pc_ecp_name        => 'ecp',
            p_pc_ecp_alg         => 'MD',
            p_pc_src_entity      => p_ext_id,
            p_pc_header          => l_header /*,
               p_pc_encrypt_data  => p_data_diia*/
                                            );

        UPDATE PACKET_CONTENT
           SET pc_encrypt_data = p_data_diia
         WHERE pc_pkt = l_pkt;

        p_pkt_id := l_pkt;
    EXCEPTION
        WHEN exPktExists
        THEN
            raise_application_error (
                -20000,
                   'По файлу <id='
                || p_ext_id
                || '> уже сформовано пакет <pkt_id='
                || l_pkt_id
                || '>');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'ikis_rbm.RDM$APP_EXCHANGE_DIIA.GenPaketsCovid19:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END GenPaketsCovid19;
BEGIN
    NULL;
END RDM$APP_EXCHANGE_DIIA;
/