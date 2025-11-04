/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_AJAX_WEB_UTIL
IS
    -- Author  : SBOND
    -- Created : 15.03.2016 14:43:10
    -- Purpose : Дополнительные или обновленные интерфейсы с использование AJAX

    PROCEDURE PrintStatus4Ajax (p_jb IN w_jobs.jb_id%TYPE);

    PROCEDURE UpdatePrintStatus4Ajax (p_jb IN w_jobs.jb_id%TYPE);

    PROCEDURE UpdateProtStatus4Ajax (p_jb   IN w_jobs.jb_id%TYPE,
                                     p_jm   IN w_jobs_protocol.jm_id%TYPE);

    /*
    Рисование региона протокола отложеного задания с автообновлением ajax
    Определенные требование к странице:
      Нужен регион типа pl/sql. Он должен быть один на странице (два региона на одной странице не будут правильно работать)
      Нужен appication process который реализует следующее
        1. если ему передают "GETJOBINFO" в качестве параметра x01 то должен вызваться ikis_sysweb.ikis_ajax_web_util.UpdatePrintStatus4Ajax(p_jb_id)
           где p_jb_id параметр x02 (p_jb_id Ид текущего задания)
        2. если ему передают "GETPROTDATA" в качестве параметра x01 то должен вызваться ikis_sysweb.ikis_ajax_web_util.UpdateProtStatus4Ajax(p_jb, p_jm)
           где p_jb параметр x02 и p_jm x03 (p_jb Ид текущего задания, p_jm Ид максимальной записи в протоколе).
    */
    PROCEDURE DrawPrintStatusRegion (
        p_job_id                    IN w_jobs.jb_id%TYPE,     -- jb_id задания
        p_appication_process        IN VARCHAR2,    -- имя процесса приложения
        p_job_id_item_name          IN VARCHAR2, -- имя итема на странице которое хранит jb_id задания
        p_max_self_tic              IN NUMBER := 100, -- максимальное число запросов
        p_start_timeout             IN NUMBER := 1, -- частота запросов в секундах первых тиков (запросов) до p_fade_tic
        p_fade_tic                  IN NUMBER := 10, -- после которых попыток частоту запросов нужно понижать
        p_fade_timeout              IN NUMBER := 5, -- частота запросов в секундах после p_fade_tic
        p_show_elem_after_success   IN VARCHAR2 := NULL, --в случае успешного завершения задания отобразить элемент для выгрузки данных (у элемента не должно быть кондишена так как сабмита
        p_js_when_running           IN VARCHAR2 := NULL,
        p_js_when_success           IN VARCHAR2 := NULL,
        p_js_when_error             IN VARCHAR2 := NULL,
        p_js_other                  IN VARCHAR2 := NULL);

    PROCEDURE getAJAXfor1500;
END IKIS_AJAX_WEB_UTIL;
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_AJAX_WEB_UTIL
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    PROCEDURE PrintStatus4Ajax (p_jb IN w_jobs.jb_id%TYPE)
    IS
        l_start    DATE;
        l_stop     DATE;
        l_status   VARCHAR2 (100);
        l_module   VARCHAR2 (100);
        l_action   VARCHAR2 (100);
        l_job      VARCHAR2 (30);
    BEGIN
        BEGIN
            SELECT x1.jb_start_dt,
                   x1.jb_stop_dt,
                   d1.DIC_SNAME,
                   x1.jb_job_name
              INTO l_start,
                   l_stop,
                   l_status,
                   l_job
              FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                   v_w_jobs_univ x1,                          --- YAP 20081201
                                     v_ddn_wjb_st d1
             WHERE x1.jb_id = p_jb AND x1.jb_status = d1.DIC_VALUE;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_SCHEDULE.PrintStatus4Ajax',
                        CHR (10) || SQLERRM));
        END;

        -- -Frolov
        BEGIN
            SELECT x3.MODULE, x3.ACTION
              INTO l_module, l_action
              FROM USER_SCHEDULER_RUNNING_JOBS x2, v_session x3
             WHERE l_job = x2.JOB_name AND x2.Session_id = x3.SID;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        HTP.p ('<div id="prot" style="margin-top: 10px;">');
        HTP.p (
               'Початок виконання: <b><span id="jbstart">'
            || TO_CHAR (l_start, 'DD.MM.YYYY HH24:MI:SS')
            || '</span></b>');
        HTP.br;
        HTP.p (
               'Завершення виконання: <b><span id="jbend">'
            || TO_CHAR (l_stop, 'DD.MM.YYYY HH24:MI:SS')
            || '</span></b>');
        HTP.br;
        HTP.p (
            'Статус: <b><span id="jbstatus">' || l_status || '</span></b>');
        HTP.br;
        HTP.p (
            'Модуль: <b><span id="jbmodule">' || l_module || '</span></b>');
        HTP.br;
        HTP.p ('Етап: <b><span id="jbaction">' || l_action || '</span></b>');
        HTP.br;
        HTP.BR;
        HTP.p ('<span id=0 style="display:none"></span>');
        HTP.p ('<input id="JM_ID" type="hidden" value="">');
        HTP.p ('</div>');
    END;

    PROCEDURE UpdatePrintStatus4Ajax (p_jb IN w_jobs.jb_id%TYPE)
    IS
        l_start    DATE;
        l_stop     DATE;
        l_status   VARCHAR2 (100);
        l_module   VARCHAR2 (100);
        l_action   VARCHAR2 (100);
        l_job      VARCHAR2 (30);
    --l_is_line integer := 1;
    BEGIN
        BEGIN
            SELECT x1.jb_start_dt,
                   x1.jb_stop_dt,
                   d1.DIC_SNAME,
                   x1.jb_job_name
              INTO l_start,
                   l_stop,
                   l_status,
                   l_job
              FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                   v_w_jobs_univ x1,                          --- YAP 20081201
                                     v_ddn_wjb_st d1
             WHERE x1.jb_id = p_jb AND x1.jb_status = d1.DIC_VALUE;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_SCHEDULE.PrintStatus4Ajax',
                        CHR (10) || SQLERRM));
        END;

        -- -Frolov
        BEGIN
            SELECT x3.MODULE, x3.ACTION
              INTO l_module, l_action
              FROM USER_SCHEDULER_RUNNING_JOBS x2, v_session x3
             WHERE l_job = x2.JOB_name AND x2.Session_id = x3.SID;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;                                        --l_is_line := 0;
        END;

        APEX_UTIL.json_from_sql (
               '
    select '''
            || TO_CHAR (l_stop, 'DD.MM.YYYY HH24:MI:SS')
            || ''' jbend,
      '''
            || TO_CHAR (l_start, 'DD.MM.YYYY HH24:MI:SS')
            || ''' jbstart,
      '''
            || l_status
            || ''' jbstatus,
      '''
            || l_module
            || ''' jbmodule,
      '''
            || l_action
            || ''' jbaction
    from dual ');
    END;

    PROCEDURE UpdateProtStatus4Ajax (p_jb   IN w_jobs.jb_id%TYPE,
                                     p_jm   IN w_jobs_protocol.jm_id%TYPE)
    IS
        l_rows   VARCHAR2 (4000);
    BEGIN
        HTP.p ('{"row":[');

        FOR i
            IN (  SELECT x1.*,
                         x2.*,
                         DECODE (X2.jm_tp,
                                 'I', 'ІНФО',
                                 'E', '<b>ПОМИЛКА</b>',
                                 'W', 'ПОПЕРЕДЖ',
                                 '-')    MES_TP
                    FROM v_w_jobs_univ x1, w_jobs_protocol x2
                   WHERE     x1.jb_id = x2.jm_jb
                         AND x1.jb_id = p_jb
                         AND x2.jm_id > NVL (p_jm, 0)
                ORDER BY x2.jm_ts)
        LOOP
            l_rows :=
                   l_rows
                || '{"RN":"'
                || REPLACE (
                          '<br><span id='
                       || i.jm_id
                       || ' >'
                       || RPAD (I.MES_TP, 16, ' ')
                       || TO_CHAR (I.JM_TS, 'DD.MM.YYYY HH24:MI:SS')
                       || ': <b>'
                       || I.JM_MESSAGE
                       || '</b></span>',
                       '"',
                       '')
                || '"},';
        END LOOP;

        IF NVL (LENGTH (l_rows), 0) > 0
        THEN
            l_rows := SUBSTR (l_rows, 1, LENGTH (l_rows) - 1);
            l_rows := REPLACE (REPLACE (l_rows, CHR (10), ''), CHR (13), '');
        END IF;

        HTP.p (l_rows);
        HTP.p (']}');
    END;


    --Sbond 20160315
    /*
    Рисование региона протокола отложеного задания с автообновлением ajax
    Определенные требование к странице:
      Нужен регион типа pl/sql. Он должен быть один на странице (два региона на одной странице не будут правильно работать)
      Нужен appication process который реализует следующее
        1. если ему передают "GETJOBINFO" в качестве параметра x01 то должен вызваться ikis_sysweb.ikis_ajax_web_util.UpdatePrintStatus4Ajax(p_jb_id)
           где p_jb_id параметр x02 (p_jb_id Ид текущего задания)
        2. если ему передают "GETPROTDATA" в качестве параметра x01 то должен вызваться ikis_sysweb.ikis_ajax_web_util.UpdateProtStatus4Ajax(p_jb, p_jm)
           где p_jb параметр x02 и p_jm x03 (p_jb Ид текущего задания, p_jm Ид максимальной записи в протоколе).
    */
    PROCEDURE DrawPrintStatusRegion (
        p_job_id                    IN w_jobs.jb_id%TYPE,     -- jb_id задания
        p_appication_process        IN VARCHAR2,    -- имя процесса приложения
        p_job_id_item_name          IN VARCHAR2, -- имя итема на странице которое хранит jb_id задания
        p_max_self_tic              IN NUMBER := 100, -- максимальное число запросов
        p_start_timeout             IN NUMBER := 1, -- частота запросов в секундах первых тиков (запросов) до p_fade_tic
        p_fade_tic                  IN NUMBER := 10, -- после которых попыток частоту запросов нужно понижать
        p_fade_timeout              IN NUMBER := 5, -- частота запросов в секундах после p_fade_tic
        p_show_elem_after_success   IN VARCHAR2 := NULL, -- в случае успешного завершения задания отобразить элемент для
       -- выгрузки данных (у элемента не должно быть кондишена так как сабмита
 -- нет и должен стоять стить style="display: none;" если это кнопка то прописать в темплейтах
                                     -- #BUTTON_ATTRIBUTES# если не прописано)
        p_js_when_running           IN VARCHAR2 := NULL,
        p_js_when_success           IN VARCHAR2 := NULL,
        p_js_when_error             IN VARCHAR2 := NULL,
        p_js_other                  IN VARCHAR2 := NULL)
    IS
    BEGIN
        PrintStatus4Ajax (p_jb => p_job_id);
        HTP.p ('<script type="text/javascript">');
        HTP.p (
               '
   var l_cnt = 1;
   var l_timeout = '
            || p_start_timeout * 1000
            || ';
     function UpdateHeadStat() {
      $.post(''wwv_flow.show'',
         {"p_request"      : "APPLICATION_PROCESS='
            || p_appication_process
            || '",
          "p_flow_id"      : '
            || v ('APP_ID')
            || ',
          "p_flow_step_id" : '
            || v ('APP_PAGE_ID')
            || ',
          "p_instance"     : '
            || v ('APP_SESSION')
            || ',
          "x01"            : "GETJOBINFO",
          "x02"            : '
            || v (p_job_id_item_name)
            || ',
          },
          function(data){
            var res = JSON.parse(data);
            $(''#jbend'').text(res.row[0].JBEND);
            $(''#jstart'').text(res.row[0].JBSTART);
            $(''#jbstatus'').text(res.row[0].JBSTATUS);
            $(''#jbmodule'').text(res.row[0].JBMODULE);
            $(''#jbaction'').text(res.row[0].JBACTION);
            if (($(''#jbstatus'').text() == "Завершено")|| ($(''#jbstatus'').text() == "Завершено помилкою")) {
              l_cnt = '
            || p_max_self_tic
            || ';
              '
            || CASE
                   WHEN p_show_elem_after_success IS NOT NULL
                   THEN
                          '
              if ($(''#jbstatus'').text() == "Завершено") {
                $("#'
                       || p_show_elem_after_success
                       || '").css("display", "inline"); '
                   ELSE
                       NULL
               END
            || '
              }
            }
            '
            || CASE
                   WHEN p_js_when_error IS NOT NULL
                   THEN
                          'if ($(''#jbstatus'').text() == "Завершено помилкою") {
               '
                       || p_js_when_error
                       || '
             }'
                   ELSE
                       NULL
               END
            || '
            '
            || CASE
                   WHEN p_js_when_running IS NOT NULL
                   THEN
                       'if ($(''#jbstatus'').text() == "Працює") {
              ' || p_js_when_running || '
            }'
                   ELSE
                       NULL
               END
            || '
              '
            || CASE
                   WHEN p_js_when_success IS NOT NULL
                   THEN
                       'if ($(''#jbstatus'').text() == "Завершено") {
              ' || p_js_when_success || '
            }'
                   ELSE
                       NULL
               END
            || '
          }
      );
    }
     function UpdateProtMes() {
      $.post(''wwv_flow.show'',
         {"p_request"      : "APPLICATION_PROCESS='
            || p_appication_process
            || '",
          "p_flow_id"      : '
            || v ('APP_ID')
            || ',
          "p_flow_step_id" : '
            || v ('APP_PAGE_ID')
            || ',
          "p_instance"     : '
            || v ('APP_SESSION')
            || ',
          "x01"            :  "GETPROTDATA",
          "x02"            : '
            || v (p_job_id_item_name)
            || ',
          "x03"            : $("#JM_ID").val(),
          },
          function(data){
            var res = JSON.parse(data);
            for (i in res.row) {
              $("#prot span:last").after( res.row[i].RN);
            }
            $("#JM_ID").val($("#prot span:last").attr(''id''));
          }
      );
    }
    function refreshprot() {
      UpdateHeadStat();
      UpdateProtMes();
      l_cnt++;
      if (l_cnt < '
            || p_max_self_tic
            || ') {
        setTimeout(arguments.callee,l_timeout);
        if (l_cnt > '
            || p_fade_tic
            || ') {
          l_timeout  = '
            || p_fade_timeout * 1000
            || ';
        }
      }
    }
    refreshprot();
    </script>');
    END;

    PROCEDURE getAJAXfor1500
    IS
        p_sql_str   VARCHAR2 (1000);
        p_job_id    v_w_jobs_univ.jb_id%TYPE;
    BEGIN
        IF (APEX_APPLICATION.g_x01) = '610'
        THEN
            p_job_id := TO_NUMBER (APEX_APPLICATION.g_x02);
            p_sql_str :=
                   '
               SELECT to_char(x1.jb_start_dt, ''dd.mm.yyyy hh24:mi:ss'') jb_start_dt,
                      to_char(x1.jb_stop_dt, ''dd.mm.yyyy hh24:mi:ss'') jb_stop_dt,
                      d1.DIC_SNAME st,
                      DECODE (X2.jm_tp,''I'',''ІНФО'',''E'',''<b>ПОМИЛКА</b>'',''W'',''ПОПЕРЕДЖ'',''-'') MES_TP,
                      to_char(x2.jm_ts, ''dd.mm.yyyy hh24:mi:ss'') jm_ts,
                      x2.jm_message
                 FROM
                      ikis_sysweb.v_w_jobs_univ x1,
                      ikis_sysweb.w_jobs_protocol x2,
                      ikis_sysweb.v_ddn_wjb_st d1
                WHERE x1.jb_id=x2.jm_jb(+)
                  AND x1.jb_id='
                || p_job_id
                || '
                  AND x1.jb_status=d1.DIC_VALUE
                ORDER BY x2.jm_ts, x2.jm_id';
        END IF;

        APEX_UTIL.json_from_sql (p_sql_str);
    END getAJAXfor1500;
END IKIS_AJAX_WEB_UTIL;
/