/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$APP_EXCHANGE_PFU
IS
    -- Author  : Ivashchuk
    -- Created : 20.05.2022 11:45:41
    -- Purpose :

    -- info:  реєстрація та обробка запиту від ПФУ
    -- params: p_Request_Id NUMBER – ІД запиту(в журналі IKIS_RBM.UXP_REQUEST);
    --         p_Request_Body CLOB – тіло запиту
    --         результат - CLOB з прикладними даними відповіді(теоретично може бути пустим)
    -- note: На боці ЄІССС  реалізувати функцію, де результатом буде CLOB з прикладними даними відповіді(теоретично може бути пустим), а параметрами:
    FUNCTION Handle_PFU_Request_Resp (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB;

    -- info:  реєстрація запиту та формуваня конверта при "відправці" з інтерфейсу ПЕОД
    -- params:  p_pkt_ids - перелік ід вибраних пакетів через кому
    -- note:
    FUNCTION register_pkt_request (p_pkt_ids VARCHAR2)
        RETURN NUMBER;

    -- info: функція для отримання даних запиту
    -- params:  p_ur_id - ідентифікатор запиту в журналі IKIS_RBM.UXP_REQUEST.
    -- note:
    FUNCTION get_pkt_request_data (p_ur_id NUMBER)
        RETURN CLOB;

    -- info: процедура обробки відповіді на запит
    -- params:  p_ur_id - ідентифікатор запиту в журналі IKIS_RBM.UXP_REQUEST.
    --          p_Response IN CLOB,--Відповідь на запиту
    --          p_Error    IN OUT VARCHAR2 --Помилка, що виникла під час відправки або обробки запиту
    -- note:
    PROCEDURE Handle_Pkt_Request_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);
END rdm$app_exchange_pfu;
/


GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE_PFU TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE_PFU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$APP_EXCHANGE_PFU
IS
    exFormXml     EXCEPTION;
    exWrapXml     EXCEPTION;
    exProcError   EXCEPTION;

    -- info:  реєстрація та обробка запиту від ПФУ
    -- params: p_Request_Id NUMBER – ІД запиту(в журналі IKIS_RBM.UXP_REQUEST);
    --         p_Request_Body CLOB – тіло запиту
    --         результат - CLOB з прикладними даними відповіді(теоретично може бути пустим)
    -- note: На боці ЄІССС  реалізувати функцію, де результатом буде CLOB з прикладними даними відповіді(теоретично може бути пустим), а параметрами:
    -- p_Request_Id NUMBER – ІД запиту(в журналі IKIS_RBM.UXP_REQUEST);
    -- p_Request_Body CLOB – тіло запиту
    FUNCTION Handle_PFU_Request_Resp (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_pkt           NUMBER;
        l_irl_Id        NUMBER;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_pkt_xml       XMLTYPE;
        l_pkt_data      BLOB;
        l_res_clob      CLOB;
        l_pkt_row       packet%ROWTYPE;
        l_pc_npc        NUMBER;
    BEGIN
        --l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn(p_Ur_Id => p_Ur_Id);


        --Зберігаємо запит
        /* l_irl_Id := RDM$IC_REQUESTS_LOG.insert_uss_requests_log(
                                                      p_request_id   => p_Request_Id,
                                                      p_rq_code      => 'uss.pkt',
                                                      p_Request_Body => p_Request_Body,
                                                      p_irl_message  => null);*/

        l_pkt_xml := xmltype (p_Request_Body);

        --Парсимо відповідь
        BEGIN
            FOR pp
                IN (       SELECT x_pkt_pfu,
                                  x_pkt_uss,
                                  x_pkt_type,
                                  x_pkt_sys,
                                  x_pkt_name,
                                  x_data
                             FROM XMLTABLE (
                                      '/get_packet_req/packet'
                                      PASSING l_pkt_xml
                                      COLUMNS x_pkt_pfu     NUMBER (14) PATH 'pkt_id',
                                              x_pkt_sys     NUMBER (14) PATH 'pkt_sys',
                                              x_pkt_type    NUMBER (14) PATH 'pkt_type',
                                              x_pkt_uss     NUMBER (14) PATH 'pkt_uss',
                                              x_pkt_name    VARCHAR (50) PATH 'pkt_name',
                                              x_data        CLOB PATH 'pkt_data'))
            LOOP
                l_pkt_data := NULL;

                BEGIN
                    l_pkt_data := ikis_rbm.tools.               /*b64_decode*/
                                                 decode_base64       /*_utf8*/
                                                               (pp.x_data);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        --dbms_output.put_line('Помилка зчитування base64-контвертованого вмісту пакета p_Request_Id = '||p_Request_Id||', pkt_id='||pp.x_pkt_id);
                        l_res_clob :=
                               'Помилка зчитування base64-контвертованого вмісту пакета p_Request_Id = '
                            || p_Request_Id
                            || ', pkt_id='
                            || pp.x_pkt_pfu;
                        EXIT;
                END;

                SELECT p.*
                  INTO l_pkt_row
                  FROM packet p
                 WHERE pkt_id = pp.x_pkt_uss;

                SELECT pc_npc
                  INTO l_pc_npc
                  FROM packet_content c
                 WHERE pc_pkt = pp.x_pkt_uss;

                BEGIN
                    -- реєструємо пакет
                    l_pkt :=
                        ikis_rbm.RDM$PACKET.insert_packet (
                            p_Pkt_Pat         =>
                                CASE
                                    WHEN pp.x_pkt_type = 102            /*78*/
                                                             THEN 102
                                    WHEN pp.x_pkt_type = 103            /*79*/
                                                             THEN 103
                                    ELSE 102                              --??
                                END,
                            p_Pkt_Nes         => 101,
                            p_Pkt_Org         => l_pkt_row.pkt_org,
                            p_Pkt_St          => 'N',
                            p_Pkt_Create_Wu   => NULL,
                            p_Pkt_Create_Dt   => SYSDATE,
                            p_Pkt_Change_Wu   => NULL,
                            p_Pkt_Change_Dt   => NULL,
                            p_Pkt_Rec         => l_pkt_row.pkt_rec,
                            p_Pkt_Rm          => NULL);
                    --dbms_output.put_line(cc.ef_id||': '||l_pkt||', tt='|| TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SSxFF'));
                    ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content (
                        p_pc_pkt             => l_pkt,
                        p_pc_tp              => 'F',
                        p_pc_name            => pp.x_pkt_name,
                        p_pc_data            => l_pkt_data,
                        p_pc_pkt_change_wu   => NULL,
                        p_pc_pkt_change_dt   => SYSDATE,
                        p_pc_visual_data     => NULL,
                        p_pc_main_tag_name   => NULL,
                        p_pc_data_name       => NULL,
                        p_pc_ecp_list_name   => NULL,
                        p_pc_ecp_name        => NULL,
                        p_pc_ecp_alg         => NULL,
                        p_pc_src_entity      => pp.x_pkt_pfu,
                        p_pc_header          => NULL,
                        p_pc_encrypt_data    => NULL,
                        p_pc_npc             => l_pc_npc);

                    ikis_rbm.Rdm$packet_Links.insert_packet_LINKS (
                        p_pl_pkt_in    => l_pkt,
                        p_pl_pkt_out   => pp.x_pkt_uss);

                    -- Оновлюємо статус вихідного пакета з SND на RCV
                    IF l_pkt_row.pkt_st = 'SND'
                    THEN
                        ikis_rbm.Rdm$packet.Set_Packet_State (
                            p_Pkt_Id          => l_pkt_row.pkt_id,
                            p_Pkt_St          => 'RCV',
                            p_Pkt_Change_Wu   => NULL,
                            p_Pkt_Change_Dt   => SYSDATE);
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        --dbms_output.put_line('Помилка реєстрації пакета ПЕОД по p_Request_Id = '||p_Request_Id||', pkt_id='||pp.x_pkt_id);
                        l_res_clob :=
                               'Помилка реєстрації пакета ПЕОД по p_Request_Id = '
                            || p_Request_Id
                            || ', pkt_id='
                            || pp.x_pkt_pfu;
                        EXIT;
                END;
            END LOOP;
        EXCEPTION
            WHEN OTHERS
            THEN
                --dbms_output.put_line('Помилка обробки запита p_Request_Id = '||p_Request_Id);
                l_res_clob :=
                    'Помилка обробки запита p_Request_Id = ' || p_Request_Id;
        END;

        RDM$IC_REQUESTS_LOG.set_ic_requests_log_st (
            p_irl_id        => l_irl_id,
            p_irl_st        => CASE WHEN l_res_clob IS NULL THEN 'P' ELSE 'E' END,
            p_irl_message   => SUBSTR (l_res_clob, 1, 500));


        IF NVL (DBMS_LOB.getlength (l_res_clob), 0) = 0
        THEN
            RETURN l_res_clob;
        ELSE
            RAISE exProcError;
        END IF;
    EXCEPTION
        WHEN exProcError
        THEN
            raise_application_error (-20000, l_res_clob);
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка обробки запита p_Request_Id = '
                || p_Request_Id
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- info:  реєстрація запиту та формуваня конверта при "відправці" з інтерфейсу ПЕОД
    -- params:  p_pkt_ids - перелік ід вибраних пакетів через кому
    -- note: Зареєструвати запит. Для цього викликається процедура IKIS_RBM.Api$uxp_Request.Register_Out_Request, з такими параметрами:
    -- p_Rn_Nrt - тип запиту. У твоєму випадку 29;
    -- p_Rn_Src - код джерела запиту. З довідником тут трохи плутанина, тому передавай просто 'RBM';
    -- p_Rn_Hs_Ins - посилання на HISTSESSION(не обов’язково);
    -- p_Ur_Ext_Id - зовнішній ідентифікатор запиту(не обов’язково);
    -- p_Ur_Id - ІД запиту(вихідний параметр).
    -- реєстрація запиту та формуваня конверта при "відправці"
    -- Відправка виконується по обраному переліку пакетів.
    -- відповідно, заданий перелік прив'язуємо до ід запиту та формуємо xml-конверт
    -- UR_ID - це ідентифікатор запиту в журналі IKIS_RBM.UXP_REQUEST.
    FUNCTION register_pkt_request (p_pkt_ids VARCHAR2)
        RETURN NUMBER
    IS
        l_pkt_cnt     NUMBER;
        l_ur_id       NUMBER;
        l_hs_id       NUMBER;
        l_res_xml     XMLTYPE;
        l_res_clob    CLOB;
        l_wu          NUMBER
            := SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUID);
        l_max_size    NUMBER;
        l_pkts_size   NUMBER;
    BEGIN
        -- #94697 io 20231214 у Трембіти є обмеження в 100МБ на запит. з урахуванням base64
        SELECT NVL (MAX (TRIM (prm_value                     /* #97139 * 3/4*/
                                        )), 50)
          INTO l_max_size
          FROM param_rbm p
         WHERE     p.prm_code = 'TREM_EXCH_MAXSIZE'
               AND p.prm_st = 'L'
               AND SYSDATE BETWEEN prm_start_dt
                               AND NVL (prm_stop_dt,
                                        TO_DATE ('01.01.2999', 'dd.mm.yyyy'));

        SELECT COUNT (1),
               ROUND (SUM (DBMS_LOB.getlength (pc_data)) / 1024 / 1024, 2)
          INTO l_pkt_cnt, l_pkts_size
          FROM ikis_rbm.packet  p
               JOIN ikis_rbm.packet_content c ON pc_pkt = pkt_id
         --join uss_ndi.v_ndi_packet_type t on pkt_pat = pat_id and t.pat_direction = 'O'
         WHERE     pkt_st IN ('NVP')
               AND pkt_pat = 101
               AND pkt_id IN (    SELECT REGEXP_SUBSTR (text,
                                                        '[^(\,)]+',
                                                        1,
                                                        LEVEL)    AS z_rdt_id
                                    FROM (SELECT p_pkt_ids AS text FROM DUAL)
                              CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                '[^(\,)]+',
                                                                1,
                                                                LEVEL)) > 0)
               AND NOT EXISTS
                       (                        --відсутній непомилковий запит
                        SELECT 1
                          FROM ic_requests_log r, packet_processing pp
                         WHERE     irl_ur = pp_ur
                               AND pp_pkt = pkt_id
                               AND irl_st != 'E');

        IF l_pkt_cnt = 0
        THEN                                  -- відсутні пакети для відправки
            RETURN NULL;
        END IF;

        INSERT INTO ikis_rbm.tmp_pkt_work (x_pkt, x_pkt_size, x_num) -- #94697 io
            SELECT t.*,
                   TRUNC (
                         SUM (pc_size / 1024 / 1024) OVER (ORDER BY pkt_id)
                       / l_max_size)    x_num
              FROM (SELECT pkt_id, -- #97139 dbms_lob.getlength(pc_data) as pc_size
                           DBMS_LOB.getlength ( /*ikis_rbm.RDM$APP_EXCHANGE.Get_pkt_file(pkt_id)*/
                               XMLELEMENT (
                                   "packet",
                                   XMLELEMENT ("pkt_id", pkt_id),
                                   XMLELEMENT ("pkt_sys", (pkt_nes)),
                                   XMLELEMENT ("pkt_type", (pkt_pat)),
                                   XMLELEMENT ("pkt_name", pc_name),
                                   XMLELEMENT ("pkt_code", '99999'),
                                   XMLELEMENT (
                                       "pkt_data",
                                       ikis_rbm.tools.encode_base64 (
                                           ikis_rbm.RDM$APP_EXCHANGE.Get_pkt_file (
                                               pkt_id)))).getClobVal ())    AS pc_size
                      FROM ikis_rbm.packet  p
                           JOIN ikis_rbm.packet_content c ON pc_pkt = pkt_id
                     WHERE     pkt_st IN ('NVP')
                           AND pkt_pat = 101
                           AND pkt_id IN
                                   (    SELECT REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)    AS z_rdt_id
                                          FROM (SELECT p_pkt_ids     AS text
                                                  FROM DUAL)
                                    CONNECT BY LENGTH (
                                                   REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) >
                                               0)
                           AND NOT EXISTS
                                   (            --відсутній непомилковий запит
                                    SELECT 1
                                      FROM ic_requests_log    r,
                                           packet_processing  pp
                                     WHERE     irl_ur = pp_ur
                                           AND pp_pkt = pkt_id
                                           AND irl_st != 'E')) t;

        IF SQL%ROWCOUNT = 0
        THEN                       -- помилка підготовки пакетів для відправки
            raise_application_error (
                -20000,
                'Помилка підготовки пакетів для відправки!');
        END IF;

        l_hs_id := tools.GetHistSession (p_hs_wu => l_wu);

        -- -- #94697 io  оскільки іноді одержуємо набір пакетів, файл обміну по яких перевищує максимальний розмір
        --               для Трембіти(100мб на 14.12.2023), то розбиваємо на порції
        FOR kk
            IN (  SELECT x_num,
                         COUNT (1)                                    x_cnt,
                         ROUND (SUM (x_pkt_size) / 1024 / 1024, 2)    AS x_size
                    FROM tmp_pkt_work
                GROUP BY x_num
                ORDER BY x_num)
        LOOP
            -- реєстрація запиту
            IKIS_RBM.Api$uxp_Request.Register_Out_Request (
                p_Rn_Nrt      => 29,
                p_Rn_Src      => 'RBM',
                p_Rn_Hs_Ins   => l_hs_id,
                p_Ur_Ext_Id   => NULL,                           -- ef_id  ???
                p_Ur_Id       => l_ur_id);

            INSERT INTO packet_processing (pp_pkt, pp_ur)
                SELECT pkt_id, l_ur_id
                  FROM ikis_rbm.packet  p
                       JOIN ikis_rbm.packet_content c ON pc_pkt = pkt_id
                 WHERE     1 = 1
                       AND pkt_st = 'NVP'
                       AND pkt_pat = 101
                       AND pkt_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS z_rdt_id
                                      FROM (SELECT p_pkt_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0)
                       AND NOT EXISTS
                               (                --відсутній непомилковий запит
                                SELECT 1
                                  FROM ic_requests_log    r,
                                       packet_processing  pp
                                 WHERE     irl_ur = pp_ur
                                       AND pp_pkt = pkt_id
                                       AND irl_st != 'E')
                       AND pkt_id IN (SELECT x_pkt
                                        FROM tmp_pkt_work
                                       WHERE x_num = kk.x_num);

            BEGIN
                SELECT XMLELEMENT (
                           "get_packet_req",
                           XMLELEMENT ("req_date", SYSDATE),
                           XMLAGG (
                               XMLELEMENT (
                                   "packet",
                                   XMLELEMENT ("pkt_id", pkt_id),
                                   XMLELEMENT ("pkt_sys", (pkt_nes)),
                                   XMLELEMENT ("pkt_type", (pkt_pat)),
                                   XMLELEMENT ("pkt_name", pc_name),
                                   XMLELEMENT ("pkt_code", npc.npc_code),
                                   XMLELEMENT (
                                       "pkt_data",
                                       ikis_rbm.tools.encode_base64 (
                                           ikis_rbm.RDM$APP_EXCHANGE.Get_pkt_file (
                                               pkt_id)))))).getClobVal ()
                  INTO l_res_clob
                  FROM ikis_rbm.packet  p
                       JOIN ikis_rbm.packet_content c ON pc_pkt = pkt_id
                       JOIN ikis_rbm.packet_processing pp
                           ON pp_pkt = pkt_id AND pp_ur = l_ur_id
                       LEFT JOIN uss_ndi.v_ndi_payment_codes npc
                           ON npc.npc_id = c.pc_npc
                 WHERE     1 = 1
                       AND pkt_st = 'NVP'
                       AND pkt_pat = 101
                       AND pkt_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS z_rdt_id
                                      FROM (SELECT p_pkt_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0)
                       AND pkt_id IN (SELECT x_pkt
                                        FROM tmp_pkt_work
                                       WHERE x_num = kk.x_num);
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.put_line (
                           'Помилка формування xml: '
                        || CHR (10)
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.FORMAT_ERROR_STACK
                        || ' => '
                        || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                    RAISE exFormXml;
            END;

            /*  begin
                l_res_clob := IKIS_RBM.Api$request_Pfu.Wrap_Common_Request(
                   p_Request_Type => 'IKIS.SendRbmPkg',
                   p_Request_Body => l_res_xml);
                exception
                when others then raise exFormXml;
              end;*/

            INSERT INTO ikis_rbm.IC_REQUESTS_LOG (irl_id,
                                                  irl_pkt,
                                                  irl_rq,
                                                  irl_code,
                                                  irl_data,
                                                  irl_dt,
                                                  irl_st,
                                                  irl_message,
                                                  irl_ur,
                                                  irl_response)
                 VALUES (NULL,
                         NULL,
                         NULL,
                         'get_packet_req',
                         l_res_clob,
                         SYSDATE,
                         'N',
                         NULL,
                         l_ur_id,
                         NULL);
        --return l_res_clob;
        END LOOP;

        RETURN l_ur_id;
    END;


    -- info: функція для отримання даних запиту
    -- params:  p_ur_id - ідентифікатор запиту в журналі IKIS_RBM.UXP_REQUEST.
    -- note: Реалізувати функцію для отримання даних запиту, де вхіднім параметром є  ІД запиту - UR_ID та повертає CLOB з вмістом запиту.
    /*
    НЕ ПОТРІБНО ----При цьому XML з тілом запиту "загортається" у функцію IKIS_RBM.Api$request_Pfu.Wrap_Common_Request, що містить параметри:
    p_Request_Type VARCHAR2 - тип запиту. В твоєму випадку - IKIS.SendRbmPkg;
    p_Request_Body XMLTYPE- XML прикладного запиту;
    */
    FUNCTION get_pkt_request_data (p_ur_id NUMBER)
        RETURN CLOB
    IS
        l_res_xml    XMLTYPE;
        l_res_clob   CLOB;
    BEGIN
        SELECT irl_data
          INTO l_res_clob
          FROM ic_requests_log
         WHERE irl_ur = p_ur_id;

        /* begin
           select
             Xmlelement("get_packet_req",
               Xmlelement("req_date", sysdate),
               xmlagg(
                 Xmlelement("packet",
                   Xmlelement("pkt_id", pkt_id),
                   Xmlelement("pkt_sys", (pkt_nes)),
                   Xmlelement("pkt_type", (pkt_pat)),
                   Xmlelement("pkt_name", pc_name),
                   Xmlelement("pkt_data", ikis_rbm.RDM$APP_EXCHANGE.Get_pkt_file(pkt_id))))
                   ).getClobVal()
           into l_res_clob -- l_res_xml
           from ikis_rbm.packet p
           join ikis_rbm.packet_content c on pc_pkt = pkt_id
           join ikis_rbm.packet_processing on pp_pkt = pkt_id
           where 1=1
             and pkt_st = 'NVP'
             and pkt_pat = 101
             and pp_ur = p_ur_id;
         exception
           when others then raise exFormXml;
         end;*/

        /* без обв'язки
           begin
            l_res_clob := IKIS_RBM.Api$request_Pfu.Wrap_Common_Request(
               p_Request_Type => 'IKIS.SendRbmPkg',
               p_Request_Body => l_res_xml);
            exception
            when others then raise exWrapXml;
          end;*/

        RETURN l_res_clob;
    EXCEPTION
        WHEN exFormXml
        THEN
            raise_application_error (
                -20000,
                'Помилка формування XML-вмісту конверта: ' || SQLERRM);
        WHEN exWrapXml
        THEN
            raise_application_error (
                -20000,
                'Помилка формування конверта: ' || SQLERRM);
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'ikis_rbm.rdm$app_exchange_pfu.get_request_data:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- info: процедура обробки відповіді на запит
    -- params:  p_ur_id - ідентифікатор запиту в журналі IKIS_RBM.UXP_REQUEST.
    --          p_Response IN CLOB,--Відповідь на запиту
    --          p_Error    IN OUT VARCHAR2 --Помилка, що виникла під час відправки або обробки запиту
    -- note: p_Response - це транспортний конверт, щоб його розпарсити можна викликати функцію IKIS_RBM.Api$request_Pfu.Parse_Common_Response, яка поверне рекорд такого вигляду:
    --  TYPE r_Common_Response IS RECORD(
    --    Response_Body    CLOB,
    --    Result_Code      NUMBER,
    --    Result_Tech_Info VARCHAR(4000));
    --Власне Response_Body - це вже і буде прикладна відповідь від сервісу ПФУ.
    --Якщо p_Error прийшов не пустий - шось гепнулось на етапі відправки або обробки запиту на боці ПФУ і тут потрібно вирішувати, чи потрібно щось виконувати якусь прикладну логіку(переключати якісь статуси і т.д.).
    PROCEDURE Handle_Pkt_Request_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_Cert_List     Ikis_Rbm.Api$request_Mju.t_Birth_Cert_List;
        l_Cert          Ikis_Rbm.Api$request_Mju.r_Birth_Certificate;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Child_Pib     VARCHAR2 (250);
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            -- Зберігати в лог ?
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            UPDATE ic_requests_log r
               SET r.irl_message = p_Error, r.irl_st = 'E'
             WHERE irl_ur = p_ur_id;

            RETURN;
        END IF;

        --Зберігаємо відповідь
        UPDATE ic_requests_log r
           SET r.irl_response =
                      irl_response
                   || CHR (10)
                   || NVL (
                          p_Response,
                             'ans:'
                          || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')),
               r.irl_st = 'P'
         WHERE irl_ur = p_ur_id;

        --Парсимо відповідь
        -- ***

        -- оновлюємо статус пакетів запиту на Відправлено
        FOR pp
            IN (SELECT pkt_id
                  FROM packet p, packet_processing pp
                 WHERE     pkt_st = 'NVP'
                       AND pp.pp_pkt = pkt_id
                       AND pp.pp_ur = p_ur_id)
        LOOP
            rdm$packet.Set_Packet_State (p_Pkt_Id          => pp.pkt_id,
                                         p_Pkt_St          => 'SND',
                                         p_Pkt_Change_Wu   => NULL,
                                         p_Pkt_Change_Dt   => SYSDATE);
        END LOOP;
    END;
/*
3. Додати тип запиту до таблиці налаштувань. Тут я вже майже все зробив:
SELECT t.*,
       t.Rowid
  FROM Uss_Ndi.Ndi_Request_Type t
WHERE t.Nrt_Id = 29
Тобі тільки потрібно прописати в NRT_QUERY_FUNC функцію з п.1, а в NRT_WORK_FUNC процедуру з п.2.

*/
BEGIN
    NULL;
END rdm$app_exchange_pfu;
/