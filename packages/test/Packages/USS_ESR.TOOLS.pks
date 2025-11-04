/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.TOOLS
IS
    -- Author  : VANO
    -- Created : 04.06.2021 11:39:44
    -- Purpose : Допоміжні функції

    gINSTANCE_LOCK_NAME   VARCHAR2 (100);
    g_save_job_messages   INTEGER := 1;

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    SUBTYPE t_msg IS VARCHAR2 (4000);

    TYPE r_message IS RECORD
    (
        msg_tp         VARCHAR2 (10),
        msg_tp_name    VARCHAR2 (20),
        msg_text       VARCHAR2 (4000)
    );

    TYPE t_messages IS TABLE OF r_message;

    TYPE t_org_ids IS TABLE OF NUMBER (5);

    TYPE r_pib IS RECORD
    (
        LN    VARCHAR2 (100),
        fn    VARCHAR2 (100),
        mn    VARCHAR2 (100)
    );

    TYPE t_str_array IS TABLE OF VARCHAR2 (32767);

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    FUNCTION request_lock_with_timeout (
        p_descr               IN VARCHAR2,
        p_error_msg           IN VARCHAR2,
        p_timeout             IN NUMBER DEFAULT 0,
        p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    PROCEDURE release_lock (p_lock_handler IN t_lockhandler);

    PROCEDURE Sleep (p_sec NUMBER);

    FUNCTION GetCurrRoot
        RETURN NUMBER;

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER;

    FUNCTION GetCurrOrgAcc
        RETURN NUMBER;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2;

    FUNCTION GetCurrOblOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgAccMode
        RETURN VARCHAR2;

    FUNCTION GetCurrWu
        RETURN NUMBER;

    FUNCTION GetCurrWut
        RETURN NUMBER;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2;

    FUNCTION GetCurrUserTp
        RETURN VARCHAR2;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetOrgSName (p_org_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetOrgRegName (p_org_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetOrgName (p_org_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION CheckUserRole (p_role VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION CheckUserRoleStr (p_role VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION is_role_assigned (p_role VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE HANDLE_DNET_CONNECTION (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL);

    PROCEDURE handle_dnet_connection_ex (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL);

    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE;

    --Генерує нову сесію, якщо не передано, і не чіпає, якщо передане не пусте.
    FUNCTION GetHistSessionEX (p_hs histsession.hs_id%TYPE)
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionCmes
        RETURN histsession.hs_id%TYPE;

    -- виводить суму як текст
    FUNCTION SUM_TO_TEXT (P_SUM           NUMBER,
                          P_IS_COP        VARCHAR2 DEFAULT 'T',
                          P_IS_CURRENCY   VARCHAR2 DEFAULT 'T',
                          P_COP_AS_TEXT   VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2;

    -- виводить копійки від суми як текст
    FUNCTION SUM_COP_TO_TEXT (P_SUM NUMBER)
        RETURN VARCHAR2;


    -- виводить кількість як текст
    FUNCTION QNT_TO_TEXT (P_SUM NUMBER)
        RETURN VARCHAR2;

    -- повертає підстроку по роздільному знаку в вказаному проміжку
    FUNCTION GET_SUBSTR (p_str          IN VARCHAR2,
                         p_substr       IN VARCHAR2,
                         p_start_indx   IN NUMBER,
                         p_end_indx     IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    PROCEDURE add_message (p_messages   IN OUT t_messages,
                           p_msg_tp     IN     VARCHAR2,
                           p_msg_text   IN     VARCHAR2);

    PROCEDURE JobSaveMessage (p_mess VARCHAR2, p_type VARCHAR2 DEFAULT 'I');

    PROCEDURE SubmitSchedule (p_jb             OUT DECIMAL,
                              p_subsys             VARCHAR2,
                              p_wjt                VARCHAR2,
                              p_what               VARCHAR2,
                              p_nextdate           DATE DEFAULT SYSDATE,
                              p_interval           VARCHAR2 DEFAULT NULL,
                              p_schema_name        VARCHAR2 := 'USS_ESR',
                              p_end_date           DATE DEFAULT NULL,
                              p_is_immediate       BOOLEAN := TRUE);

    PROCEDURE GetScheduleStatus (p_jb     IN     NUMBER,
                                 p_main      OUT SYS_REFCURSOR,
                                 p_msg       OUT SYS_REFCURSOR);

    PROCEDURE GetScheduleData (p_jb_id IN NUMBER, p_blob OUT BLOB);

    PROCEDURE RPT_RESET;

    -- Перенесено з ikis_finzvit
    --Функція кодування в BASE64 (наприклад для подальшого вкладення в EML-формат як attachment)
    FUNCTION ConvertBlobToBase64 (p_in_data       IN BLOB,
                                  p_need_carret      INTEGER := 1)
        RETURN CLOB;

    FUNCTION ConvertClobToBase64 (p_clob CLOB)
        RETURN CLOB;

    FUNCTION ConvertClobFromBase64 (p_clob CLOB)
        RETURN CLOB;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB;

    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION decode_base64_utf8 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION b64_encode (p_clob CLOB)
        RETURN CLOB;

    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB;

    FUNCTION ConvertC2BUTF8 (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB;

    FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2)
        RETURN CLOB;

    FUNCTION PasteBlob (p_dest BLOB, p_ins_data BLOB, p_signature VARCHAR2)
        RETURN BLOB;

    FUNCTION get_clob_substr (p_clob CLOB, p_start NUMBER, p_stop NUMBER)
        RETURN CLOB;

    -- Вирізаємо значення атрибута в інший клоб
    FUNCTION get_xmlattr_clob (p_xml_clob   CLOB,
                               p_attr       VARCHAR2,
                               p_nth        NUMBER:= 1)
        RETURN CLOB;

    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB;

    FUNCTION hash_md5 (p_blob BLOB)
        RETURN VARCHAR2;

    FUNCTION unZip (p_blob BLOB)
        RETURN BLOB;

    -- io  #89670
    PROCEDURE unZip2 (p_zip_blob    IN     BLOB,
                      p_file_blob      OUT BLOB,
                      p_file_name      OUT VARCHAR2);

    FUNCTION toZip2 (p_file_blob IN BLOB, p_file_name IN VARCHAR2)
        RETURN BLOB;

    -- перевіряємо чи є вхідний p_xml_clob кодованим в UTF8
    FUNCTION checkUTF8 (p_xml_clob CLOB)
        RETURN VARCHAR2;

    FUNCTION GetOpfuParam (p_optp_code IN VARCHAR2, p_orgp_org IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION least2 (p_dt1 DATE, p_dt2 DATE)
        RETURN DATE;

    FUNCTION greatest2 (p_dt1 DATE, p_dt2 DATE)
        RETURN DATE;

    FUNCTION part_of_month (p_month        DATE,
                            p_part_start   DATE,
                            p_part_stop    DATE)
        RETURN NUMBER;

    --Частина періоду
    FUNCTION p_o_p (p_full_start   DATE,
                    p_full_stop    DATE,
                    p_part_start   DATE,
                    p_part_stop    DATE)
        RETURN NUMBER
        DETERMINISTIC;

    --Частина періоду можливо частково перетинає повний
    FUNCTION p_o_p2 (p_full_start   DATE,
                     p_full_stop    DATE,
                     p_part_start   DATE,
                     p_part_stop    DATE)
        RETURN NUMBER
        DETERMINISTIC;

    FUNCTION PR (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2;

    FUNCTION PL (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2;

    FUNCTION ReplUKRSmb2Dos (l_txt VARCHAR2, p_convert_symb VARCHAR2:= 'F')
        RETURN VARCHAR2;

    FUNCTION ggp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION glp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION ggpd (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN DATE;

    FUNCTION ggpn (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION GMText (p_message VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION GetCurrOrgTree
        RETURN t_org_ids
        PIPELINED;

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL);

    FUNCTION split_clob (p_value       IN CLOB,
                         p_delimiter   IN VARCHAR2 DEFAULT ',')
        RETURN ot_clob_table
        PIPELINED;

    PROCEDURE list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                p_list VARCHAR2);

    PROCEDURE org_list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                    p_list VARCHAR2);

    -- #84545: головна адреса
    FUNCTION get_main_addr (p_ap_id    IN NUMBER,
                            p_ap_tp    IN VARCHAR2,
                            p_sc_id    IN NUMBER,
                            p_nst_id   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    -- #85247: головна адреса CC
    FUNCTION get_main_addr_ss (p_ap_id   IN NUMBER,
                               p_ap_tp   IN VARCHAR2,
                               p_sc_id   IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Split_Pib (p_Pib IN VARCHAR2, p_Pib_Split OUT r_Pib);

    FUNCTION GetStartPackageName (p_call_stack IN CLOB)
        RETURN VARCHAR2;

    FUNCTION GetAuditStack (p_call_stack IN CLOB)
        RETURN VARCHAR2;


    --Переведення тексту в дату/час з поверненням NULL, якщо хоч якесь виключення
    FUNCTION tdate (p_dt VARCHAR2, p_format VARCHAR2:= 'DD.MM.YYYY')
        RETURN DATE;

    --Переведення тексту в число з поверненням NULL, якщо хоч якесь виключення
    FUNCTION tnumber (p_number              VARCHAR2,
                      p_format              VARCHAR2 DEFAULT '999999999999D999',
                      p_decimal_separator   VARCHAR2 DEFAULT '.')
        RETURN NUMBER;

    -- Додавання мясців до дати з урахування, що день наодження '28.02' повинен звлишатися таким і в високосному році.
    FUNCTION ADD_MONTHS_LEAP (p_dt DATE, p_months NUMBER)
        RETURN DATE;

    -- least без null як мінімального значення
    FUNCTION least_nn (dt1   DATE,
                       dt2   DATE DEFAULT NULL,
                       dt3   DATE DEFAULT NULL,
                       dt4   DATE DEFAULT NULL,
                       dt5   DATE DEFAULT NULL,
                       dt6   DATE DEFAULT NULL)
        RETURN DATE;

    --
    PROCEDURE LOG (p_src              VARCHAR2,
                   p_obj_tp           VARCHAR2,
                   p_obj_id           NUMBER,
                   p_regular_params   VARCHAR2,
                   p_lob_param        CLOB DEFAULT NULL);

    PROCEDURE logSes (p_src              VARCHAR2,
                      p_regular_params   VARCHAR2,
                      p_lob_param        CLOB DEFAULT NULL);

    PROCEDURE Start_Log_Ses_Id (p_Src IN VARCHAR2, p_Obj_Id IN NUMBER);

    PROCEDURE Stop_Log_Ses_Id;

    -- p_mode = 0 - керівника з облікової політики
    -- p_mode = 1 - особу, що затверджує з облікової політики
    FUNCTION get_acc_setup_pib (p_mode       IN NUMBER,
                                p_pib_mode   IN NUMBER DEFAULT 1,
                                p_org        IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    -- p_mode = 0 - керівника з облікової політики
    -- p_mode = 1 - особу, що затверджує з облікової політики
    FUNCTION get_acc_setup_pos (p_mode IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE validate_param (p_val VARCHAR2);

    PROCEDURE raise_exception (p_cnt INTEGER, p_msg VARCHAR2);

    PROCEDURE set_nls;

    FUNCTION split_str (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN t_str_array
        PIPELINED;

    FUNCTION split_str2 (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN VARCHAR2
        SQL_MACRO;

    FUNCTION Clear_Name (p_Name IN VARCHAR2)
        RETURN VARCHAR2;
END TOOLS;
/


GRANT EXECUTE ON USS_ESR.TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.TOOLS TO II01RC_USS_ESR_AP_COPY
/

GRANT EXECUTE ON USS_ESR.TOOLS TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.TOOLS TO II01RC_USS_ESR_RPT
/

GRANT EXECUTE ON USS_ESR.TOOLS TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.TOOLS TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.TOOLS TO LMOSTOVENKO
/

GRANT EXECUTE ON USS_ESR.TOOLS TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.TOOLS TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:50:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.TOOLS
IS
    g_curr_org         NUMBER;
    g_curr_root        NUMBER;

    g_Log_Ses_Src      VARCHAR2 (50);
    g_Log_Ses_Obj_Id   NUMBER;


    PROCEDURE init_tools
    IS
    BEGIN
        gINSTANCE_LOCK_NAME := 'USS_ESR:';
        g_curr_org := GetCurrOrg;
    END;

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => 'BUSY',
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        RETURN l_lock_handler;
    END request_lock;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => p_error_msg,
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => p_release_on_commit);

        RETURN l_lock_handler;
    END request_lock;

    FUNCTION request_lock_with_timeout (
        p_descr               IN VARCHAR2,
        p_error_msg           IN VARCHAR2,
        p_timeout             IN NUMBER DEFAULT 0,
        p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => p_error_msg,
            p_lockhandler         => l_lock_handler,
            p_timeout             => p_timeout,
            p_release_on_commit   => p_release_on_commit);

        RETURN l_lock_handler;
    END request_lock_with_timeout;


    PROCEDURE release_lock (p_lock_handler IN t_lockhandler)
    IS
    BEGIN
        IF p_lock_handler IS NOT NULL
        THEN
            ikis_sys.ikis_lock.releace_lock (p_lock_handler);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END release_lock;

    PROCEDURE Sleep (p_sec NUMBER)
    IS
    BEGIN
        IKIS_LOCK.sleep (p_sec);
    END;


    FUNCTION GetCurrRoot
        RETURN NUMBER
    IS
    BEGIN
        --!!! Увага! Це коректно працюватиме лише якщо для кожної сесії ДО аутентифікації буде виконано DBMS_SESSION.RESET_PACKAGES.
        IF g_curr_root IS NULL
        THEN
            BEGIN
                SELECT org_id
                  INTO g_curr_org
                  FROM (    SELECT org_id, CONNECT_BY_ISLEAF AS leaf
                              FROM v_opfu
                        START WITH org_id = g_curr_org
                        CONNECT BY PRIOR org_org = org_id)
                 WHERE leaf = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_curr_org := NULL;
            END;
        END IF;

        RETURN g_curr_root;
    END;

    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_ESR_CONTEXT.GetContext (USS_ESR_CONTEXT.gORG));
    END;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        --  ikis_sysweb.ikis_debug_pipe.WriteMsg(g_curr_org);
        SELECT org_name
          INTO l_name
          FROM v_opfu
         WHERE org_id = g_curr_org;

        RETURN l_name;
    END;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id =
               TO_NUMBER (USS_ESR_CONTEXT.GetContext (USS_ESR_CONTEXT.gORG));

        RETURN l_org_to;
    END;

    FUNCTION GetCurrOrgAcc
        RETURN NUMBER
    IS
        l_org_acc   NUMBER;
    BEGIN
        SELECT MAX (t.org_acc_org)
          INTO l_org_acc
          FROM v_opfu t
         WHERE org_id =
               TO_NUMBER (USS_ESR_CONTEXT.GetContext (USS_ESR_CONTEXT.gORG));

        RETURN l_org_acc;
    END;

    FUNCTION GetCurrOblOrg
        RETURN NUMBER
    IS
        l_curr_org   NUMBER;
        l_curr_to    NUMBER;
        l_result     NUMBER;
    BEGIN
        l_curr_to := GetCurrOrgTo;
        l_curr_org := GetCurrOrg;

        IF l_curr_to = 30
        THEN
            l_result := NULL;
        ELSIF l_curr_to IN (31)
        THEN
            l_result := l_curr_org;
        ELSIF l_curr_to IN (32, 33, 34)
        THEN
                SELECT org_id
                  INTO l_result
                  FROM ikis_sys.v_opfu z
                 WHERE org_to = 31
            START WITH org_id = l_curr_org
            CONNECT BY PRIOR org_org = org_id;
        ELSE
            l_result := NULL;
        END IF;

        RETURN l_result;
    END;

    FUNCTION GetCurrOrgAccMode
        RETURN VARCHAR2
    IS
        l_org_to    NUMBER;
        l_obl_org   NUMBER;
        l_result    VARCHAR2 (250);
    BEGIN
        RETURN ikis_common.GetOpfuParam ('ACC_MODE', GetCurrOblOrg);
    END;


    FUNCTION GetCurrWu
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_ESR_CONTEXT.GetContext ('uid'));
    END;

    FUNCTION GetCurrWut
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_ESR_CONTEXT.GetContext ('USERTP'));
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN USS_ESR_CONTEXT.GetContext (USS_ESR_CONTEXT.gLogin);
    END;

    FUNCTION GetCurrUserTp
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN USS_ESR_CONTEXT.GetContext ('USERTPCODE');
    END;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_pib       VARCHAR2 (250);
        l_curr_wu   NUMBER;
    BEGIN
        l_curr_wu := GetCurrWu;

        SELECT wu_pib
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = l_curr_wu;

        RETURN l_pib;
    END;


    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_login   VARCHAR2 (250);
    BEGIN
        SELECT wu_login
          INTO l_login
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_login;
    END;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_pib   VARCHAR2 (250);
    BEGIN
        IF P_WU_ID IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT MAX (wu_pib)
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_pib;
    END;

    FUNCTION GetOrgSName (p_org_id NUMBER)
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT REPLACE (
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (
                                                           REPLACE (
                                                               REPLACE (
                                                                   REPLACE (
                                                                       REPLACE (
                                                                           REPLACE (
                                                                               REPLACE (
                                                                                   REPLACE (
                                                                                       REPLACE (
                                                                                           REPLACE (
                                                                                               REPLACE (
                                                                                                   REPLACE (
                                                                                                       REPLACE (
                                                                                                           UPPER (
                                                                                                               REPLACE (
                                                                                                                   org_name,
                                                                                                                   '  ',
                                                                                                                   ' ')),
                                                                                                           'СТРУКТУРНИЙ ПІДРОЗДІЛ ВИКОНАВЧОГО ОРГАНУ ',
                                                                                                           'СПВО '),
                                                                                                       'ОБЛАСНОЇ ДЕРЖАВНОЇ АДМІНІСТРАЦІЇ ',
                                                                                                       ' ОДА'),
                                                                                                   ' ОБЛАСНОЇ ДЕРЖАВНОЇ АДМІНІСТРАЦІЇ',
                                                                                                   ' ОДА'),
                                                                                               'УПРАВЛІННЯ СОЦІАЛЬНОГО РОЗВИТКУ ',
                                                                                               'УСР '),
                                                                                           'ДЕПАРТАМЕНТ СОЦПОЛІТИКИ ',
                                                                                           'ДСП '),
                                                                                       'УПРАВЛІННЯ СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                                       'УСП '),
                                                                                   'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ТА МОЛОДІЖНОЇ ПОЛІТИКИ ',
                                                                                   'ДСМП '),
                                                                               'ДЕПАРТАМЕНТ ПРАЦІ ТА СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                               'ДПСП '),
                                                                           'ОБЛАСНИЙ ЦЕНТР ПО НАРАХУВАННЮ ТА ЗДІЙСНЕННЮ СОЦІАЛЬНИХ ВИПЛАТ',
                                                                           'ОЦНЗСВ'),
                                                                       'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                       'ДСП '),
                                                                   'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ТА СІМЕЙНОЇ ПОЛІТИКИ ',
                                                                   'ДССП '),
                                                               'ДЕПАРТАМЕНТ ПРАЦІ ТА СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                                                               'ДПСЗН '),
                                                           'ВИКОНАВЧОГО КОМІТЕТУ ',
                                                           'ВК '),
                                                       'ОБ''ЄДНАНА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                                       'ОТГ'),
                                                   'СЕЛИЩНА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                                   'СТГ'),
                                               'МІСЬКА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                               'МТГ'),
                                           'СІЛЬСЬКА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                           'СТГ'),
                                       'УПРАВЛІННЯ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                                       'УСЗН '),
                                   'УПРАВЛІННЯ СОЦІАЛЬНОГО ЗАХИСТУ ',
                                   'УСЗ '),
                               'ДЕПАРТАМЕНТ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ТА ПИТАНЬ АТО ',
                               'ДСЗН ТА ПАТО '),
                           'ДЕПАРТАМЕНТ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                           'ДСЗН '),
                       'МІСЬКОЇ РАДИ',
                       'МР'),
                   'МІСЬКОЇ ДЕРЖАВНОЇ АДМІНІСТРАЦІЇ',
                   'МДА')
          INTO l_name
          FROM v_opfu t
         WHERE 1 = 1 AND org_id = p_org_id;

        RETURN l_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetOrgRegName (p_org_id NUMBER)
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT CASE
                   WHEN org_id IN (53000, 54000) THEN 'м. ' || reg_name
                   WHEN org_id IN (54300) THEN reg_name
                   ELSE reg_name || ' обл.'
               END
          INTO l_name
          FROM (SELECT org_id,
                       (SELECT p.orgp_value
                          FROM ikis_sys.v_opfu_param p
                         WHERE p.orgp_optp = 6 AND p.orgp_org = org_id)    AS reg_name
                  FROM (    SELECT CONNECT_BY_ROOT org_id AS root_org, t.*
                              FROM v_opfu t
                        CONNECT BY org_id = PRIOR org_org
                        START WITH t.org_id = p_org_id)
                 WHERE org_to = 31
                UNION ALL                                        -- IC #115343
                SELECT org_id,
                       (SELECT op.orgp_value
                          FROM ikis_sys.v_opfu_param op
                         WHERE op.orgp_optp = 6 AND op.orgp_org = o.org_id)    AS reg_name
                  FROM v_opfu o
                 WHERE org_id = p_org_id AND org_to = 81);

        RETURN l_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetOrgName (p_org_id NUMBER)
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (250);
    BEGIN
        SELECT MAX (Org_Name)
          INTO l_Name
          FROM v_Opfu o
         WHERE o.Org_Id = p_Org_Id;

        RETURN l_Name;
    END;

    FUNCTION CheckUserRole (p_role VARCHAR2)
        RETURN BOOLEAN
    IS
        l_user_info    SYS_REFCURSOR;
        l_user_roles   SYS_REFCURSOR;
        l_wr_id        NUMBER;
        l_wr_name      VARCHAR2 (200);
        l_wr_wut       VARCHAR2 (200);
        l_wr_descr     VARCHAR2 (2000);
    BEGIN
        ikis_sysweb.ikis_dnet_auth.GetUserInfo (
            p_session_id   => USS_ESR_CONTEXT.GetContext ('SESSION'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_roles
                INTO l_wr_id,
                     l_wr_name,
                     l_wr_wut,
                     l_wr_descr;

            EXIT WHEN l_user_roles%NOTFOUND;

            IF l_wr_name = UPPER (p_role)
            THEN
                CLOSE l_user_roles;

                RETURN TRUE;
            END IF;
        --DBMS_OUTPUT.PUT_LINE ( l_wr_id||'   '||l_wr_name||'   '||l_wr_wut );
        END LOOP;

        CLOSE l_user_roles;

        RETURN FALSE;
    END;

    FUNCTION CheckUserRoleStr (p_role VARCHAR2)
        RETURN VARCHAR2
    IS
        l_user_info    SYS_REFCURSOR;
        l_user_roles   SYS_REFCURSOR;
        l_wr_id        NUMBER;
        l_wr_name      VARCHAR2 (200);
        l_wr_wut       VARCHAR2 (200);
        l_wr_descr     VARCHAR2 (2000);
    BEGIN
        ikis_sysweb.ikis_dnet_auth.GetUserInfo (
            p_session_id   => USS_ESR_CONTEXT.GetContext ('SESSION'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_roles
                INTO l_wr_id,
                     l_wr_name,
                     l_wr_wut,
                     l_wr_descr;

            EXIT WHEN l_user_roles%NOTFOUND;

            IF l_wr_name = UPPER (p_role)
            THEN
                CLOSE l_user_roles;

                RETURN 'T';
            END IF;
        --DBMS_OUTPUT.PUT_LINE ( l_wr_id||'   '||l_wr_name||'   '||l_wr_wut );
        END LOOP;

        CLOSE l_user_roles;

        RETURN 'F';
    END;

    FUNCTION is_role_assigned (p_role VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        --dbms_output.put_line('TOOLS.GetCurrLogin='||TOOLS.GetCurrLogin);
        --dbms_output.put_line('p_role='||p_role);
        --dbms_output.put_line('TOOLS.GetCurrUserTp='||TOOLS.GetCurrUserTp);
        RETURN ikis_sysweb.is_role_assigned (TOOLS.GetCurrLogin,
                                             p_role,
                                             TOOLS.GetCurrUserTp);
    END;

    PROCEDURE HANDLE_DNET_CONNECTION (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_esr_context.SetDnetesrContext (p_session_id, p_ip_address);
        DBMS_SESSION.set_identifier (p_absolute_url);
        init_tools;
    END;

    PROCEDURE handle_dnet_connection_ex (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_esr_context.SetDnetEsrContext (p_session_id, p_ip_address);
        DBMS_SESSION.set_identifier (p_absolute_url);
        init_tools;
    END;

    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE
    IS
        l_hs      histsession.hs_id%TYPE;
        l_hs_wu   histsession.hs_wu%TYPE;
        l_hs_cu   histsession.hs_cu%TYPE;
    BEGIN
        l_hs_wu := USS_ESR_CONTEXT.GetContext ('ussuid');

        IF l_hs_wu IS NULL
        THEN
            l_hs_wu := USS_ESR_CONTEXT.GetContext ('uid');
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_hs_wu);
        END IF;

        IF l_hs_wu IS NULL
        THEN
            l_hs_wu := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');
        END IF;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_hs_wu);
        l_hs_cu := Ikis_Rbm.Tools.Getcurrentcu;

        INSERT INTO histsession (hs_id,
                                 hs_wu,
                                 hs_dt,
                                 hs_cu)
             VALUES (0,
                     l_hs_wu,
                     SYSDATE,
                     l_hs_cu)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    --Генерує нову сесію, якщо не передано, і не чіпає, якщо передане не пусте.
    FUNCTION GetHistSessionEX (p_hs histsession.hs_id%TYPE)
        RETURN histsession.hs_id%TYPE
    IS
    BEGIN
        IF p_hs IS NOT NULL
        THEN
            RETURN p_hs;
        ELSE
            RETURN GetHistSession;
        END IF;
    END;

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := GetHistSession;

        COMMIT;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION GetHistSessionCmes
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_cu, hs_dt)
             VALUES (0, ikis_rbm.tools.GetCurrentCu, SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSessionCmes: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION get_clean_blob
        RETURN BLOB
    IS
        l_result   BLOB;
    BEGIN
        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);
        RETURN l_result;
    END;


    FUNCTION GET_HUNDRED_AS_TEXT (P_SUM               DECIMAL,
                                  P_IS_WOMEN_ENDING   NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_res     VARCHAR2 (1000);
        l_val     DECIMAL;
        l_temp1   VARCHAR (100);
        l_temp2   VARCHAR (100);
    BEGIN
        l_val := TRUNC (P_SUM);

        IF (    MOD (l_val, 10) != 0
            AND (MOD (l_val, 100) < 1 OR MOD (l_val, 100) > 19))
        THEN
            SELECT t.DIC_NAME, t.DIC_SNAME
              INTO l_temp1, l_temp2
              FROM uss_ndi.v_ddn_digits t
             WHERE t.DIC_CODE = MOD (l_val, 10);

            l_res :=
                CASE WHEN P_IS_WOMEN_ENDING = 1 THEN l_temp2 ELSE l_temp1 END;
            l_val := l_val - MOD (l_val, 10);
        END IF;

        IF (MOD (l_val, 100) != 0)
        THEN
            SELECT t.DIC_NAME, t.DIC_SNAME
              INTO l_temp1, l_temp2
              FROM uss_ndi.v_ddn_digits t
             WHERE t.DIC_CODE = MOD (l_val, 100);

            l_res :=
                   CASE
                       WHEN P_IS_WOMEN_ENDING = 1 THEN l_temp2
                       ELSE l_temp1
                   END
                || ' '
                || l_res;
            l_val := l_val - MOD (l_val, 100);
        END IF;

        IF (MOD (l_val, 1000) != 0)
        THEN
            SELECT t.DIC_NAME, t.DIC_SNAME
              INTO l_temp1, l_temp2
              FROM uss_ndi.v_ddn_digits t
             WHERE t.DIC_CODE = MOD (l_val, 1000);

            l_res :=
                   CASE
                       WHEN P_IS_WOMEN_ENDING = 1 THEN l_temp2
                       ELSE l_temp1
                   END
                || ' '
                || l_res;
        END IF;

        RETURN l_res;
    END;

    -- виводить суму як текст
    FUNCTION SUM_TO_TEXT (P_SUM           NUMBER,
                          P_IS_COP        VARCHAR2 DEFAULT 'T',
                          P_IS_CURRENCY   VARCHAR2 DEFAULT 'T',
                          P_COP_AS_TEXT   VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2
    IS
        l_res        VARCHAR2 (10000);
        l_val        NUMBER := P_SUM;
        l_mod        NUMBER;
        l_is_minus   NUMBER := 0;
    BEGIN
        IF (P_SUM IS NULL)
        THEN
            RETURN NULL;
        END IF;

        IF (P_SUM < 0)
        THEN
            l_is_minus := 1;
            l_val := ABS (P_SUM);
        END IF;

        IF (P_IS_COP = 'T')
        THEN
            l_mod := TRUNC ((l_val - TRUNC (l_val)) * 100);
            l_res :=
                   CASE
                       WHEN l_mod = 0
                       THEN
                           '00'
                       ELSE
                           CASE
                               WHEN P_COP_AS_TEXT = 'T'
                               THEN
                                   TRIM (GET_HUNDRED_AS_TEXT (l_mod, 1))
                               ELSE
                                   LPAD (l_mod, 2, '0')
                           END
                   END
                || ' '
                || 'КОП.';
        END IF;

        l_res := CASE WHEN P_IS_CURRENCY = 'T' THEN 'ГРН. ' END || l_res;

        l_val := TRUNC (l_val);
        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res := TRIM (GET_HUNDRED_AS_TEXT (l_mod, 1)) || ' ' || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod, 1))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТИСЯЧА'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТИСЯЧІ'
                       ELSE
                           'ТИСЯЧ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЙОН'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЙОНИ'
                       ELSE
                           'МІЛЬЙОНІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЯРД'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЯРДИ'
                       ELSE
                           'МІЛЬЯРДІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЙОН'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЙОНИ'
                       ELSE
                           'ТРИЛЬЙОНІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЯРД'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЯРДИ'
                       ELSE
                           'ТРИЛЬЯРДІВ'
                   END
                || ' '
                || l_res;
        END IF;

        IF (l_is_minus = 1)
        THEN
            l_res := '- ' || l_res;
        END IF;

        RETURN LOWER (l_res);
    END;

    -- виводить суму як текст
    FUNCTION SUM_COP_TO_TEXT (P_SUM NUMBER)
        RETURN VARCHAR2
    IS
        l_res        VARCHAR2 (10000);
        l_val        NUMBER := P_SUM;
        l_mod        NUMBER;
        l_is_minus   NUMBER := 0;
    BEGIN
        IF (P_SUM IS NULL)
        THEN
            RETURN NULL;
        END IF;

        IF (P_SUM < 0)
        THEN
            l_is_minus := 1;
            l_val := ABS (P_SUM);
        END IF;

        l_mod := TRUNC ((l_val - TRUNC (l_val)) * 100);
        l_res :=
            CASE
                WHEN l_mod = 0
                THEN
                    'нуль'
                ELSE
                    CASE
                        WHEN 1 = 1 THEN TRIM (GET_HUNDRED_AS_TEXT (l_mod, 1))
                        ELSE LPAD (l_mod, 2, '0')
                    END
            END;

        RETURN LOWER (l_res);
    END;

    -- виводить кількість як текст
    FUNCTION QNT_TO_TEXT (P_SUM NUMBER)
        RETURN VARCHAR2
    IS
        l_res        VARCHAR2 (10000);
        l_val        NUMBER := P_SUM;
        l_mod        NUMBER;
        l_is_minus   NUMBER := 0;
    BEGIN
        IF (P_SUM IS NULL)
        THEN
            RETURN NULL;
        END IF;

        IF (P_SUM < 0)
        THEN
            l_is_minus := 1;
            l_val := ABS (P_SUM);
        END IF;

        l_mod := TRUNC ((l_val - TRUNC (l_val)) * 100);

        IF (l_mod != 0)
        THEN
            l_res := TRIM (GET_HUNDRED_AS_TEXT (l_mod)) || ' сотих';
        END IF;

        l_val := TRUNC (l_val);
        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || CASE
                       WHEN LENGTH (l_res) > 0
                       THEN
                           CASE
                               WHEN     MOD (l_mod, 10) = 1
                                    AND (   MOD (l_mod, 100) < 11
                                         OR MOD (l_mod, 100) > 19)
                               THEN
                                   ' ціла і '
                               ELSE
                                   ' цілих і '
                           END
                       ELSE
                           ''
                   END
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod, 1))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТИСЯЧА'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТИСЯЧІ'
                       ELSE
                           'ТИСЯЧ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЙОН'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЙОНИ'
                       ELSE
                           'МІЛЬЙОНІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЯРД'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'МІЛЬЯРДИ'
                       ELSE
                           'МІЛЬЯРДІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЙОН'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЙОНИ'
                       ELSE
                           'ТРИЛЬЙОНІВ'
                   END
                || ' '
                || l_res;
        END IF;

        l_mod := MOD (l_val, 1000);
        l_val := TRUNC (l_val / 1000);

        IF (l_mod != 0)
        THEN
            l_res :=
                   TRIM (GET_HUNDRED_AS_TEXT (l_mod))
                || ' '
                || CASE
                       WHEN     MOD (l_mod, 10) = 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЯРД'
                       WHEN     MOD (l_mod, 10) < 5
                            AND MOD (l_mod, 10) > 1
                            AND (   MOD (l_mod, 100) < 11
                                 OR MOD (l_mod, 100) > 19)
                       THEN
                           'ТРИЛЬЯРДИ'
                       ELSE
                           'ТРИЛЬЯРДІВ'
                   END
                || ' '
                || l_res;
        END IF;

        IF (l_is_minus = 1)
        THEN
            l_res := '- ' || l_res;
        END IF;

        RETURN LOWER (l_res);
    END;

    -- повертає підстроку по роздільному знаку в вказаному проміжку
    FUNCTION GET_SUBSTR (p_str          IN VARCHAR2,
                         p_substr       IN VARCHAR2,
                         p_start_indx   IN NUMBER,
                         p_end_indx     IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_res        VARCHAR2 (4000);
        l_str        VARCHAR (4000);
        l_end_indx   NUMBER := NVL (p_end_indx, LENGTH (p_str));
    BEGIN
        l_str := p_str || p_substr;

        SELECT SUBSTR (l_str,
                       INSTR (SUBSTR (l_str, 1, p_start_indx),
                              p_substr,
                              -1,
                              1),
                         INSTR (SUBSTR (l_str, 1, l_end_indx),
                                ' ',
                                -1,
                                1)
                       - INSTR (SUBSTR (l_str, 1, p_start_indx),
                                ' ',
                                -1,
                                1))
          INTO l_res
          FROM DUAL;

        RETURN l_res;
    END;

    PROCEDURE add_message (p_messages   IN OUT t_messages,
                           p_msg_tp     IN     VARCHAR2,
                           p_msg_text   IN     VARCHAR2)
    IS
        l_msg   r_message;
    BEGIN
        l_msg.msg_tp := p_msg_tp;

        CASE p_msg_tp
            WHEN 'E'
            THEN
                l_msg.msg_tp_name := 'Помилка';
            WHEN 'W'
            THEN
                l_msg.msg_tp_name := 'Попередження';
            WHEN 'I'
            THEN
                l_msg.msg_tp_name := 'Інформаційне';
            ELSE
                l_msg.msg_tp_name := '-';
        END CASE;

        l_msg.msg_text := p_msg_text;
        p_messages.EXTEND ();
        p_messages (p_messages.COUNT) := l_msg;
    END;

    PROCEDURE JobSaveMessage (p_mess VARCHAR2, p_type VARCHAR2 DEFAULT 'I')
    IS
    BEGIN
        IF g_save_job_messages = 1
        THEN
            ikis_sysweb_schedule.SaveMessage (p_mess, p_type);
        ELSE
            DBMS_OUTPUT.put_line (
                SYSTIMESTAMP || ' : ' || p_type || ' : ' || p_mess);
        END IF;
    END;

    PROCEDURE SubmitSchedule (p_jb             OUT DECIMAL,
                              p_subsys             VARCHAR2,
                              p_wjt                VARCHAR2,
                              p_what               VARCHAR2,
                              p_nextdate           DATE DEFAULT SYSDATE,
                              p_interval           VARCHAR2 DEFAULT NULL,
                              p_schema_name        VARCHAR2 := 'USS_ESR',
                              p_end_date           DATE DEFAULT NULL,
                              p_is_immediate       BOOLEAN := TRUE)
    IS
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('TOOLS.SubmitSchedule');
        ikis_sysweb.ikis_sysweb_schedule.submitschedule (
            p_jb            => p_jb,
            p_subsys        => p_subsys,
            p_wjt           => p_wjt,
            p_what          => p_what,
            p_nextdate      => p_nextdate,
            p_interval      => p_interval,
            p_schema_name   => p_schema_name,
            p_end_date      => p_end_date);

        IF p_is_immediate
        THEN
            ikis_sysweb_schedule.enablejob_univ (p_jb);
        END IF;
    END;

    PROCEDURE GetScheduleStatus (p_jb     IN     NUMBER,
                                 p_main      OUT SYS_REFCURSOR,
                                 p_msg       OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sysweb.ikis_sysweb_schedule.GetStatus (p_jb, p_main, p_msg);
    END;

    PROCEDURE GetScheduleData (p_jb_id IN NUMBER, p_blob OUT BLOB)
    IS
    BEGIN
        ikis_sysweb.IKIS_SYSWEB_SCHEDULE.GetAppData (p_jb_id, p_blob);
    END;

    PROCEDURE RPT_RESET
    IS
    BEGIN
        ROLLBACK;

        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DBMS_SESSION.RESET_PACKAGE ();
    END;


    -- Перенесено з ikis_finzvit
    FUNCTION ConvertBlobToBase64 (p_in_data       IN BLOB,
                                  p_need_carret      INTEGER := 1)
        RETURN CLOB
    AS
        l_buf_size      INTEGER := 12288;
        l_buf           RAW (32767);
        l_length        INTEGER;
        l_loops         INTEGER;
        l_pos           INTEGER := 1;
        l_encoded_raw   RAW (32767);
        l_encoded_vc2   VARCHAR2 (32767);
        l_result        CLOB;
    BEGIN
        l_length := DBMS_LOB.getLength (p_in_data);

        IF l_length > l_buf_size
        THEN
            l_loops := ROUND ((l_length / l_buf_size) + 0.5);
        ELSE
            l_loops := 1;
        END IF;

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        FOR i IN 1 .. l_loops
        LOOP
            IF l_pos > l_length
            THEN
                CONTINUE;
            END IF;

            DBMS_LOB.READ (p_in_data,
                           l_buf_size,
                           l_pos,
                           l_buf);
            l_encoded_raw := UTL_ENCODE.base64_encode (l_buf);
            l_encoded_vc2 := UTL_RAW.cast_to_varchar2 (l_encoded_raw);
            DBMS_LOB.writeAppend (l_result,
                                  LENGTH (l_encoded_vc2),
                                  l_encoded_vc2);
            l_pos := l_pos + l_buf_size;
        END LOOP;

        IF p_need_carret = 1
        THEN
            DBMS_LOB.writeAppend (l_result, 1, CHR (10));
        END IF;

        RETURN l_result;
    END;

    FUNCTION ConvertClobToBase64 (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32767;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_encode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;

    FUNCTION ConvertClobFromBase64 (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32767;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_decode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB
    IS
        v_clob             CLOB;
        v_result           CLOB;
        v_offset           INTEGER;
        v_chunk_size       BINARY_INTEGER := (48 / 4) * 3;
        v_buffer_varchar   VARCHAR2 (48);
        v_buffer_raw       RAW (48);
    BEGIN
        IF p_blob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        /*  dbms_lob.createtemporary(v_clob, true);
          v_offset := 1;
          FOR I IN 1 .. ceil(dbms_lob.getlength(p_blob_in) / v_chunk_size) LOOP
            dbms_lob.read(p_blob_in, v_chunk_size, v_offset, v_buffer_raw);
            v_buffer_raw := utl_encode.base64_encode(v_buffer_raw);
            v_buffer_varchar := utl_raw.cast_to_varchar2(v_buffer_raw);
            dbms_lob.writeappend(v_clob, length(v_buffer_varchar), v_buffer_varchar);
            v_offset := v_offset + v_chunk_size;
        --    dbms_output.put_line(i||to_char(sysdate, '-MI:SS'));
          END LOOP;
          v_result := v_clob;
          dbms_lob.freetemporary(v_clob);*/
        v_result := b64_encode (ConvertB2C (p_blob_in));
        RETURN v_result;
    END encode_base64;


    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB
    IS
        v_blob             BLOB;
        v_result           BLOB;
        v_offset           INTEGER;
        v_buffer_size      BINARY_INTEGER := 48;
        v_buffer_varchar   VARCHAR2 (48);
        v_buffer_raw       RAW (48);
    BEGIN
        IF p_clob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        /*  dbms_lob.createtemporary(v_blob, true);
          v_offset := 1;
          FOR I IN 1 .. ceil(dbms_lob.getlength(p_clob_in) / v_buffer_size) LOOP
            dbms_lob.read(p_clob_in, v_buffer_size, v_offset, v_buffer_varchar);
            v_buffer_raw := utl_raw.cast_to_raw(v_buffer_varchar);
            v_buffer_raw := utl_encode.base64_decode(v_buffer_raw);
            dbms_lob.writeappend(v_blob, utl_raw.length(v_buffer_raw), v_buffer_raw);
            v_offset := v_offset + v_buffer_size;
          END LOOP;
          v_result := v_blob;
          dbms_lob.freetemporary(v_blob);*/
        v_result := ConvertC2B (b64_decode (p_clob_in));
        RETURN v_result;
    END decode_base64;

    FUNCTION decode_base64_utf8 (p_clob_in IN CLOB)
        RETURN BLOB
    IS
        v_result   BLOB;
    BEGIN
        IF p_clob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        v_result := ConvertC2BUTF8 (b64_decode (p_clob_in));
        RETURN v_result;
    END;

    FUNCTION b64_encode (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 21000;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_encode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN REPLACE (l_clob, CHR (13) || CHR (10), '');
    --RETURN l_clob;
    END;

    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32400;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_decode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;

    FUNCTION ConvertC2BUTF8 (p_src CLOB)
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;

        l_result         BLOB;
    BEGIN
        l_clob_offset := 1;
        l_blob_offset := 1;
        l_lang_context := DBMS_LOB.default_lang_ctx;

        DBMS_LOB.createtemporary (l_result, TRUE);
        DBMS_LOB.convertToBlob (l_result,
                                p_src,
                                DBMS_LOB.lobmaxsize,
                                l_blob_offset,
                                l_clob_offset,
                                NLS_CHARSET_ID ('UTF8'),
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;

        l_result         BLOB;
    BEGIN
        l_clob_offset := 1;
        l_blob_offset := 1;
        l_lang_context := DBMS_LOB.default_lang_ctx;

        DBMS_LOB.createtemporary (l_result, TRUE);
        DBMS_LOB.convertToBlob (l_result,
                                p_src,
                                DBMS_LOB.lobmaxsize,
                                l_blob_offset,
                                l_clob_offset,
                                DBMS_LOB.default_csid,
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB
    IS
        l_clob           CLOB;
        l_dest_offsset   INTEGER := 1;
        l_src_offsset    INTEGER := 1;
        l_lang_context   INTEGER := DBMS_LOB.default_lang_ctx;
        l_warning        INTEGER;
    BEGIN
        IF p_src IS NULL
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.createTemporary (lob_loc => l_clob, cache => FALSE);

        DBMS_LOB.converttoclob (dest_lob       => l_clob,
                                src_blob       => p_src,
                                amount         => DBMS_LOB.lobmaxsize,
                                dest_offset    => l_dest_offsset,
                                src_offset     => l_src_offsset,
                                blob_csid      => DBMS_LOB.default_csid,
                                lang_context   => l_lang_context,
                                warning        => l_warning);

        RETURN l_clob;
    END;


    /*FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2) RETURN CLOB
    IS
      l_result CLOB;
      i INTEGER;
      ln INTEGER;
      i_start INTEGER;
      i_stop INTEGER;
    BEGIN
      i := 1;
      ln := dbms_lob.getlength(p_dest);

      DBMS_LOB.createTemporary(l_result, TRUE);
      DBMS_LOB.OPEN(l_result, DBMS_LOB.LOB_ReadWrite);

      WHILE i < ln
      LOOP
        i_start := dbms_lob.instr(p_dest, p_signature, i, 1);
        IF i_start > 0 THEN
          i_stop := i_start + LENGTH(p_signature) - 1;
          dbms_lob.writeappend(l_result, i_start - i, dbms_lob.substr(p_dest, i_start - i, i));
          dbms_lob.append(l_result, p_ins_data);
          i := i_stop + 1;
        ELSE
          dbms_lob.writeappend(l_result, ln - i, dbms_lob.substr(p_dest, ln - i, i));
          i := ln;
        END IF;
      END LOOP;
      RETURN l_result;
    END;*/

    FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2)
        RETURN CLOB
    IS
        l_result   CLOB;
        l_tmp      CLOB;
        i          INTEGER;
        LN         INTEGER;
        i_start    INTEGER;
        i_stop     INTEGER;
    BEGIN
        i := 1;
        LN := DBMS_LOB.getlength (p_dest);

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        WHILE i < LN
        LOOP
            i_start :=
                DBMS_LOB.INSTR (p_dest,
                                p_signature,
                                i,
                                1);

            IF i_start > 0
            THEN
                i_stop := i_start + LENGTH (p_signature) - 1;
                DBMS_LOB.createTemporary (l_tmp, TRUE);
                DBMS_LOB.OPEN (l_tmp, DBMS_LOB.LOB_ReadWrite);
                DBMS_LOB.COPY (l_tmp, p_dest, i_start - i);
                --dbms_lob.writeappend(l_result, i_start - i, dbms_lob.substr(p_dest, i_start - i, i));
                DBMS_LOB.append (l_result, l_tmp);
                DBMS_LOB.append (l_result, p_ins_data);
                i := i_stop + 1;
            ELSE
                DBMS_LOB.createTemporary (l_tmp, TRUE);
                DBMS_LOB.OPEN (l_tmp, DBMS_LOB.LOB_ReadWrite);
                DBMS_LOB.COPY (l_tmp,
                               p_dest,
                               LN - i + 1,
                               1,
                               i);
                --dbms_lob.writeappend(l_result, ln - i + 1, dbms_lob.substr(p_dest, ln - i + 1, i));
                DBMS_LOB.append (l_result, l_tmp);
                i := LN;
            END IF;
        END LOOP;

        RETURN l_result;
    END;

    FUNCTION PasteBlob (p_dest BLOB, p_ins_data BLOB, p_signature VARCHAR2)
        RETURN BLOB
    IS
        l_result   BLOB;
        i          INTEGER;
        LN         INTEGER;
        i_start    INTEGER;
        i_stop     INTEGER;
    BEGIN
        i := 1;
        LN := DBMS_LOB.getlength (p_dest);

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        WHILE i < LN
        LOOP
            i_start :=
                DBMS_LOB.INSTR (p_dest,
                                UTL_RAW.cast_to_raw (p_signature),
                                i,
                                1);

            IF i_start > 0
            THEN
                i_stop :=
                    i_start + LENGTH (UTL_RAW.cast_to_raw (p_signature)) - 1;
                DBMS_LOB.writeappend (
                    l_result,
                    i_start - i,
                    DBMS_LOB.SUBSTR (p_dest, i_start - i, i));
                DBMS_LOB.append (l_result, p_ins_data);
                i := i_stop + 1;
            ELSE
                DBMS_LOB.writeappend (l_result,
                                      LN - i,
                                      DBMS_LOB.SUBSTR (p_dest, LN - i, i));
                i := LN;
            END IF;
        END LOOP;

        RETURN l_result;
    END;

    FUNCTION get_clob_substr (p_clob CLOB, p_start NUMBER, p_stop NUMBER)
        RETURN CLOB
    IS
        l_part           NUMBER;
        l_portion        NUMBER;
        l_new_clob       CLOB;
        l_buff           CLOB;
        l_portion_size   NUMBER := 10000;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_new_clob, CACHE => TRUE);
        DBMS_LOB.OPEN (lob_loc     => l_new_clob,
                       open_mode   => DBMS_LOB.lob_readwrite);
        l_part := 1;

        WHILE (p_start + (l_part - 1) * l_portion_size <                 /*=*/
                                                         p_stop)
        LOOP
            l_portion :=
                LEAST (l_portion_size,
                       p_stop - p_start - (l_part - 1) * l_portion_size);
            l_buff :=                             /*utl_raw.cast_to_varchar2*/
                (DBMS_LOB.SUBSTR (p_clob,
                                  l_portion,
                                  p_start + (l_part - 1) * l_portion_size));
            l_part := l_part + 1;
            DBMS_LOB.writeappend (l_new_clob,
                                  DBMS_LOB.getlength ((l_buff)), /*utl_raw.cast_to_raw*/
                                  (l_buff));
        END LOOP;

        RETURN l_new_clob;
    END;

    -- Вирізаємо значення атрибута в інший клоб
    FUNCTION get_xmlattr_clob (p_xml_clob   CLOB,
                               p_attr       VARCHAR2,
                               p_nth        NUMBER:= 1)
        RETURN CLOB
    IS
        l_part           NUMBER;
        l_portion        NUMBER;
        l_new_clob       CLOB;
        l_buff           CLOB;
        l_portion_size   NUMBER := 10000;
        l_stop           NUMBER;
        l_start          NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_new_clob, CACHE => TRUE);
        DBMS_LOB.OPEN (lob_loc     => l_new_clob,
                       open_mode   => DBMS_LOB.lob_readwrite);
        l_start :=
              DBMS_LOB.INSTR (lob_loc   => p_xml_clob,
                              pattern   => '<' || p_attr || '>', /*offset => 1,*/
                              nth       => p_nth)
            + DBMS_LOB.getlength ('<' || p_attr || '>');
        l_stop :=
            DBMS_LOB.INSTR (lob_loc   => p_xml_clob,
                            pattern   => '</' || p_attr || '>', /*offset => 1,*/
                            nth       => p_nth)                       /* - 1*/
                                               ;
        l_new_clob := get_clob_substr (p_xml_clob, l_start, l_stop);
        RETURN l_new_clob;
    END;


    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB
    IS
        l_blob            BLOB;
        l_clob            CLOB;
        l_dest_offset     INTEGER := 1;
        l_source_offset   INTEGER := 1;
        l_lang_context    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
        l_warning         INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
    BEGIN
        DBMS_LOB.CREATETEMPORARY (l_blob, TRUE);
        DBMS_LOB.CONVERTTOBLOB (dest_lob       => l_blob,
                                src_clob       => p_clob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => 0,
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        l_dest_offset := 1;
        l_source_offset := 1;
        l_lang_context := DBMS_LOB.DEFAULT_LANG_CTX;
        DBMS_LOB.CREATETEMPORARY (l_clob, TRUE);
        DBMS_LOB.CONVERTTOCLOB (dest_lob       => l_clob,
                                src_blob       => l_blob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => NLS_CHARSET_ID ('UTF8'),
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        RETURN l_clob;
    END;

    FUNCTION hash_md5 (p_blob BLOB)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN sys.DBMS_CRYPTO.HASH (p_blob, 2                    /*HASH_MD5*/
                                              );
    END;

    FUNCTION unZip (p_blob BLOB)
        RETURN BLOB
    IS
        l_blob    BLOB;
        l_files   ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
    BEGIN
        --ikis_sysweb.ikis_web_jutil.getStrmsFromZip(p_blob, l_files);
        BEGIN
            ikis_sysweb.ikis_web_jutil.getStrmsFromZip (p_blob, l_files);
        EXCEPTION
            WHEN OTHERS
            THEN          -- 20210714 -- проблеми з розпаковкою деяких архівів
                ikis_sysweb.ikis_web_jutil.getStrmsFromZipCyr (p_blob,
                                                               l_files);
        END;

        IF l_files.COUNT > 1
        THEN
            raise_application_error (-20000,
                                     'Архів містить більше одного файла!');
        ELSIF l_files.COUNT = 0
        THEN
            raise_application_error (-20000,
                                     'Не вдалося розархівувати файл!');
        END IF;

        RETURN l_files (l_files.LAST).content;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'TOOLS.unZip:'
                || l_files.COUNT
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- io  #89670
    PROCEDURE unZip2 (p_zip_blob    IN     BLOB,
                      p_file_blob      OUT BLOB,
                      p_file_name      OUT VARCHAR2)
    IS
        l_blob    BLOB;
        l_files   ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
    BEGIN
        BEGIN
            ikis_sysweb.ikis_web_jutil.getStrmsFromZip (p_zip_blob, l_files);
        EXCEPTION
            WHEN OTHERS
            THEN          -- 20210714 -- проблеми з розпаковкою деяких архівів
                ikis_sysweb.ikis_web_jutil.getStrmsFromZipCyr (p_zip_blob,
                                                               l_files);
        END;

        IF l_files.COUNT > 1
        THEN
            raise_application_error (-20000,
                                     'Архів містить більше одного файла!');
        ELSIF l_files.COUNT = 0
        THEN
            raise_application_error (-20000,
                                     'Не вдалося розархівувати файл!');
        END IF;

        p_file_blob := l_files (l_files.LAST).content;
        p_file_name := l_files (l_files.LAST).filename;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'TOOLS.unZip2:'
                || l_files.COUNT
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION toZip2 (p_file_blob IN BLOB, p_file_name IN VARCHAR2)
        RETURN BLOB
    IS
        l_blob    BLOB;
        l_files   ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
    BEGIN
        l_files.EXTEND;
        l_files (l_files.LAST) :=
            ikis_sysweb.t_some_file_info (p_file_name, p_file_blob);

        IF l_files.COUNT > 0
        THEN
            l_blob := ikis_sysweb.ikis_web_jutil.getzipfromstrms (l_files);
        END IF;

        RETURN l_blob;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'TOOLS.toZip2:'
                || l_files.COUNT
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- перевіряємо чи є вхідний p_xml_clob кодованим в UTF8
    -- поки по <?XML VERSION="1.0" ENCODING="UTF-8"?>
    FUNCTION checkUTF8 (p_xml_clob CLOB)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE
                   WHEN DBMS_LOB.INSTR (UPPER (p_xml_clob),
                                        'ENCODING="UTF-8"') >
                        0
                   THEN
                       'T'
                   ELSE
                       'F'
               END;
    END;

    FUNCTION GetOpfuParam (p_optp_code IN VARCHAR2, p_orgp_org IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ikis_sys.ikis_common.GetOpfuParam (
                   p_optp_code   => p_optp_code,
                   p_orgp_org    => p_orgp_org);
    END;

    FUNCTION least2 (p_dt1 DATE, p_dt2 DATE)
        RETURN DATE
    IS
    BEGIN
        IF p_dt1 IS NULL
        THEN
            RETURN p_dt2;
        END IF;

        IF p_dt2 IS NULL
        THEN
            RETURN p_dt1;
        END IF;

        RETURN LEAST (p_dt1, p_dt2);
    END;

    FUNCTION greatest2 (p_dt1 DATE, p_dt2 DATE)
        RETURN DATE
    IS
    BEGIN
        IF p_dt1 IS NULL
        THEN
            RETURN p_dt2;
        END IF;

        IF p_dt2 IS NULL
        THEN
            RETURN p_dt1;
        END IF;

        RETURN GREATEST (p_dt1, p_dt2);
    END;

    FUNCTION part_of_month (p_month        DATE,
                            p_part_start   DATE,
                            p_part_stop    DATE)
        RETURN NUMBER
    IS
    BEGIN
        IF    p_part_start IS NULL
           OR p_part_stop IS NULL
           OR p_month IS NULL
           OR TRUNC (p_month, 'MM') <> TRUNC (p_part_start, 'MM')
           OR TRUNC (p_month, 'MM') <> TRUNC (p_part_stop, 'MM')
        THEN
            RETURN 0;
        END IF;

        RETURN   (p_part_stop - p_part_start + 1)
               / (  ADD_MONTHS (TRUNC (p_month, 'MM'), 1)
                  - TRUNC (p_month, 'MM'));
    END;

    --Частина періоду - частина всередині повного
    FUNCTION p_o_p (p_full_start   DATE,
                    p_full_stop    DATE,
                    p_part_start   DATE,
                    p_part_stop    DATE)
        RETURN NUMBER
        DETERMINISTIC
    IS
    BEGIN
        IF    p_part_start IS NULL
           OR p_part_stop IS NULL                            --пусті - помилка
           OR p_full_start IS NULL
           OR p_full_stop IS NULL                            --пусті - помилка
           OR p_part_start > p_part_stop      --початок більше кінця - помилка
           OR p_full_start > p_full_stop      --початок більше кінця - помилка
           OR NOT (    p_part_start BETWEEN p_full_start AND p_full_stop --частина не повністю всередині повного - помилка
                   AND p_part_stop BETWEEN p_full_start AND p_full_stop)
        THEN
            RETURN 0;
        END IF;

        RETURN   (p_part_stop - p_part_start + 1)
               / (p_full_stop - p_full_start + 1);
    END;

    --Частина періоду можливо частково перетинає повний
    FUNCTION p_o_p2 (p_full_start   DATE,
                     p_full_stop    DATE,
                     p_part_start   DATE,
                     p_part_stop    DATE)
        RETURN NUMBER
        DETERMINISTIC
    IS
        l_part_start   DATE;
        l_part_stop    DATE;
    BEGIN
        IF    p_full_start IS NULL
           OR p_full_stop IS NULL                            --пусті - помилка
           OR p_part_start IS NULL
           OR p_part_stop IS NULL                            --пусті - помилка
           OR p_full_start > p_full_stop      --початок більше кінця - помилка
           OR p_part_start > p_part_stop      --початок більше кінця - помилка
           OR p_full_stop < p_part_start      --якщо не пертинаються - помилка
           OR p_full_start > p_part_stop      --якщо не пертинаються - помилка
        THEN
            RETURN 0;
        END IF;

        --Початок part-а приводимо до початку FULL-а
        IF p_part_start < p_full_start
        THEN
            l_part_start := p_full_start;
        ELSE
            l_part_start := p_part_start;
        END IF;

        --Кінець part-а приводимо до кінця FULL-а
        IF p_part_stop > p_full_stop
        THEN
            l_part_stop := p_full_stop;
        ELSE
            l_part_stop := p_part_stop;
        END IF;

        RETURN   (l_part_stop - l_part_start + 1)
               / (p_full_stop - p_full_start + 1);
    END;

    FUNCTION PR (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD (NVL (p_buff, ' '), p_width, ' ');
    END;

    FUNCTION PL (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN RPAD (NVL (p_buff, ' '), p_width, ' ');
    END;

    FUNCTION ReplUKRSmb2Dos (l_txt VARCHAR2, p_convert_symb VARCHAR2:= 'F')
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_convert_symb = 'F'
        THEN
            RETURN l_txt;
        ELSIF p_convert_symb = 'K' --  #78357 Кабінет банку - кодування змінено
        THEN
            RETURN REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (l_txt,
                                                                '¦',
                                                                CHR (892)),
                                                       '’',
                                                       ''''),
                                                   'І',
                                                   CHR (73)),
                                               'і',
                                               CHR (105)),
                                           'Ї',
                                           CHR (ASCII ('Є') + 5)),
                                       'ї',
                                       CHR (ASCII ('є') + 5)),
                                   'Є',
                                   CHR (170)),
                               'є',
                               CHR (186)),
                           'Ґ',
                           'Г'),
                       'ґ',
                       'г');
        ELSE
            RETURN REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   l_txt,
                                                   'І',
                                                   CHR (ASCII ('І') + 239)),
                                               'і',
                                               CHR (ASCII ('і') + 239)),
                                           'Ї',
                                           CHR (ASCII ('Ї') + 1)),
                                       'ї',
                                       CHR (ASCII ('ї') + 248)),
                                   'Є',
                                   CHR (ASCII ('Є') + 5)),
                               'є',
                               CHR (ASCII ('є') + 5)),
                           'Ґ',
                           CHR (ASCII ('Ґ') + 5)),
                       'ґ',
                       CHR (ASCII ('ґ') + 6));
        END IF;
    /*  IF p_convert_symb = 'F'
        THEN RETURN l_txt;
      ELSE return replace(replace(replace(replace(
                  replace(replace(replace(replace(
                    l_txt,
                    'І', chr(Ascii('І')+239)),
                    'і', chr(Ascii('і')+239)),
                    'Ї', chr(Ascii('Ї')+1)),
                    'ї', chr(Ascii('ї')+248)),
                    'Є', chr(Ascii('Є')+5)),
                    'є', chr(Ascii('є')+5)),
                    'Ґ', chr(Ascii('Ґ')+5)),
                    'ґ', chr(Ascii('ґ')+6));
      END IF;*/
    END;

    FUNCTION ggp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   paramsesr.prm_value%TYPE;
    BEGIN
        SELECT prm_value
          INTO l_rez
          FROM paramsesr
         WHERE prm_code = p_code;

        RETURN l_rez;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION glp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   paramsesr.prm_value%TYPE;
        l_org   NUMBER := GetCurrOrg;
    BEGIN
        SELECT prm_value
          INTO l_rez
          FROM paramsesr t
         WHERE prm_code = p_code AND t.com_org = l_org;

        RETURN l_rez;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION ggpd (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        RETURN TO_DATE (tools.ggp (p_code, p_dt), 'DD.MM.YYYY');
    END;

    FUNCTION ggpn (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        RETURN TO_NUMBER (tools.ggp (p_code, p_dt));
    END;

    FUNCTION GMText (p_message VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_ndi.Rdm$msg_Template.Getmessagetext (p_message);
    END;

    FUNCTION GetCurrOrgTree
        RETURN t_org_ids
        PIPELINED
    IS
    BEGIN
        FOR xx IN (SELECT u_org FROM tmp_org)
        LOOP
            PIPE ROW (xx.u_org);
        END LOOP;
    END;

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        IF p_message IS NULL
        THEN
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER'));
        ELSE
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER')
                    || '#'
                    || p_message);
        END IF;
    END;

    FUNCTION split_clob (p_value       IN CLOB,
                         p_delimiter   IN VARCHAR2 DEFAULT ',')
        RETURN ot_clob_table
        PIPELINED
    IS
        v_start   PLS_INTEGER;
        v_next    PLS_INTEGER;
        v_len     PLS_INTEGER;
    BEGIN
        v_start := 1;

        LOOP
            v_next := DBMS_LOB.INSTR (p_value, p_delimiter, v_start);
            v_len :=
                  CASE v_next
                      WHEN 0 THEN LENGTH (p_value) + 1
                      ELSE v_next
                  END
                - v_start;
            PIPE ROW (SUBSTR (p_value, v_start, v_len));
            EXIT WHEN v_next = 0;
            v_start := v_next + LENGTH (p_delimiter);
        END LOOP;
    END;

    PROCEDURE list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                p_list VARCHAR2)
    IS
    BEGIN
        IF p_mode = 3
        THEN
            DELETE FROM tmp_work_ids3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids3 (x_id)
                    SELECT   0
                           + REGEXP_SUBSTR (p_list,
                                            '[^,]+',
                                            1,
                                            LEVEL)    AS x_id
                      FROM DUAL
                CONNECT BY REGEXP_SUBSTR (p_list,
                                          '[^,]+',
                                          1,
                                          LEVEL)
                               IS NOT NULL;
        ELSIF p_mode = 4
        THEN
            DELETE FROM tmp_work_ids4
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids4 (x_id)
                    SELECT   0
                           + REGEXP_SUBSTR (p_list,
                                            '[^,]+',
                                            1,
                                            LEVEL)    AS x_id
                      FROM DUAL
                CONNECT BY REGEXP_SUBSTR (p_list,
                                          '[^,]+',
                                          1,
                                          LEVEL)
                               IS NOT NULL;
        END IF;
    END;

    PROCEDURE org_list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                    p_list VARCHAR2)
    IS
    BEGIN
        IF p_mode = 3
        THEN
            DELETE FROM tmp_work_ids3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids3 (x_id)
                WITH
                    lst
                    AS
                        (    SELECT   0
                                    + REGEXP_SUBSTR (p_list,
                                                     '[^,]+',
                                                     1,
                                                     LEVEL)    AS x_org
                               FROM DUAL
                         CONNECT BY REGEXP_SUBSTR (p_list,
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                        IS NOT NULL)
                SELECT org_id
                  FROM ikis_sys.opfu, lst
                 WHERE     org_to = 32
                       AND org_st = 'A'
                       AND x_org IN (org_id, org_org);
        END IF;
    END;

    -- #84545: головна адреса
    FUNCTION get_main_addr (p_ap_id    IN NUMBER,
                            p_ap_tp    IN VARCHAR2,
                            p_sc_id    IN NUMBER,
                            p_nst_id   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (
                      CASE
                          WHEN n.nda_id IN (597, 1783, 8439)
                          THEN
                              (SELECT MAX (st.nsrt_name || ' ' || z.ns_name)
                                 FROM uss_ndi.v_ndi_street  z
                                      LEFT JOIN uss_ndi.v_ndi_street_type st
                                          ON (st.nsrt_id = z.ns_nsrt)
                                WHERE z.ns_id = a.apda_val_id)
                          WHEN     n.nda_id IN (596, 1784, 8441)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'буд. '
                          WHEN     n.nda_id IN (595, 1787, 8442)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'корп. '
                          WHEN     n.nda_id IN (594, 1780, 8443)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'кв. '
                          ELSE
                              ''
                      END
                   || CASE
                          WHEN n.nda_id IN (597, 1783, 8439) THEN ''
                          ELSE a.Apda_Val_String
                      END,
                   ', ')
               WITHIN GROUP (ORDER BY n.Nda_Order)
          INTO l_str
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON     a.Apda_Apd = d.Apd_Id
                      AND d.Apd_Ndt =
                          CASE
                              WHEN COALESCE (p_nst_id, -1) = 664 THEN 605
                              WHEN COALESCE (p_nst_id, -1) = 21 THEN 10314
                              ELSE 600
                          END
                      AND d.apd_app IN
                              (SELECT p.app_id
                                 FROM v_ap_person p
                                WHERE     p.app_ap = p_ap_id
                                      AND p.app_tp =
                                          CASE
                                              WHEN p_ap_tp IN ('A',
                                                               'U',
                                                               'O',
                                                               'PP')
                                              THEN
                                                  'O'
                                              ELSE
                                                  'Z'
                                          END
                                      AND p.app_sc = p_sc_id
                                      AND p.history_status = 'A')
                      AND d.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON     a.Apda_Nda = n.Nda_Id
                      AND n.Nda_Nng =
                          CASE
                              WHEN COALESCE (p_nst_id, -1) = 664 THEN 60
                              ELSE 2
                          END
         WHERE     a.Apda_Ap = p_ap_id
               AND a.History_Status = 'A'
               AND n.nda_id NOT IN (2304);

        RETURN l_str;
    END;

    -- #85247: головна адреса CC
    FUNCTION get_main_addr_ss (p_ap_id   IN NUMBER,
                               p_ap_tp   IN VARCHAR2,
                               p_sc_id   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (
                      CASE
                          WHEN n.nda_id IN (                         /*1879,*/
                                            1974, 1645, 1632)
                          THEN
                              (SELECT MAX (st.nsrt_name || ' ' || z.ns_name)
                                 FROM uss_ndi.v_ndi_street  z
                                      LEFT JOIN uss_ndi.v_ndi_street_type st
                                          ON (st.nsrt_id = z.ns_nsrt)
                                WHERE z.ns_id = a.apda_val_id)
                          WHEN     n.nda_id IN (                     /*1880,*/
                                                1975,
                                                1637,
                                                1648,
                                                8254)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'буд. '
                          WHEN     n.nda_id IN (                     /*1881,*/
                                                1976,
                                                2454,
                                                1654,
                                                8255)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'корп. '
                          WHEN     n.nda_id IN (                     /*1882,*/
                                                1977,
                                                2455,
                                                1659,
                                                8256)
                               AND a.Apda_Val_String IS NOT NULL
                          THEN
                              'кв. '
                          ELSE
                              ''
                      END
                   || CASE
                          WHEN n.nda_id IN (                         /*1879,*/
                                            1974, 1645, 1632) THEN ''
                          ELSE a.Apda_Val_String
                      END,
                   ', ')
               WITHIN GROUP (ORDER BY n.Nda_Order)
          INTO l_str
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON     a.Apda_Apd = d.Apd_Id
                      AND d.Apd_Ndt IN (605                            /*801*/
                                           ,
                                        802,
                                        803,
                                        1015)
                      AND d.apd_app IN
                              (SELECT p.app_id
                                 FROM v_ap_person p
                                WHERE     p.app_ap = p_ap_id
                                      AND p.app_tp IN ('Z',
                                                       'OS',
                                                       'OR',
                                                       'AF')
                                      AND (   p_sc_id IS NULL
                                           OR p.app_sc = p_sc_id)
                                      AND p.history_status = 'A')
                      AND d.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n ON a.Apda_Nda = n.Nda_Id
         WHERE     a.Apda_Ap = p_ap_id
               AND a.History_Status = 'A'
               AND ( --d.Apd_Ndt = 801 AND nda_id IN (1874, 1873, 1879, 1878, 1880, 1881, 1882)
                           -- #87775
                           d.Apd_Ndt = 605
                       AND nda_id IN (1618,
                                      1625,
                                      1632,
                                      1640,
                                      1648,
                                      1654,
                                      1659)
                       AND EXISTS
                               (SELECT *
                                  FROM ap_document z
                                 WHERE     z.apd_ap = d.apd_ap
                                       AND z.history_status = 'A'
                                       AND z.apd_ndt = 801)
                    OR     d.Apd_Ndt = 802
                       AND nda_id IN (1969,
                                      1968,
                                      1974,
                                      1973,
                                      1975,
                                      1976,
                                      1977)
                    OR     d.Apd_Ndt = 803
                       AND nda_id IN (1545,
                                      1494,
                                      1645,
                                      1596,
                                      1637,
                                      2454,
                                      2455)
                    OR     d.Apd_Ndt = 1015
                       AND nda_id IN (8251,
                                      8253,
                                      8254,
                                      8255,
                                      8256));

        RETURN l_str;
    END;

    PROCEDURE Split_Pib (p_Pib IN VARCHAR2, p_Pib_Split OUT r_Pib)
    IS
        l_Pib     VARCHAR2 (250);
        l_Part1   VARCHAR2 (100);
        l_Part2   VARCHAR2 (100);
        l_Part3   VARCHAR2 (100);
        l_Part4   VARCHAR2 (100);
    BEGIN
        --l_Pib := REPLACE(p_Pib, '  ', '');
        l_Pib := p_Pib;

            SELECT UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 1
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END))),
                   UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 2
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END))),
                   UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 3
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END))),
                   UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 4
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END)))
              INTO l_Part1,
                   l_Part2,
                   l_Part3,
                   l_Part4
              FROM DUAL
        CONNECT BY REGEXP_SUBSTR (l_Pib,
                                  '[^ ]+',
                                  1,
                                  LEVEL)
                       IS NOT NULL;

        IF l_Part4 IS NULL
        THEN
            p_Pib_Split.LN := l_Part1;
            p_Pib_Split.Fn := l_Part2;
            p_Pib_Split.Mn := l_Part3;
        ELSE
            --Ім'я та прізвище можуть бути подвійним. При цьому згідно інформації від Мінюсту:
            ---* Подвійне прізвище ЗАВЖДИ записується через дефіс;
            ---* Подвійне ім'я ПОТРІБНО записувати через дефіс
            ---- (під "потрібно" скоріш за все мається на увазі, що може бути через дефіс, але не обовязково,
            ---- тобто це не правило, а скоріше рекомендація);

            --Спираючись на ці правила, якщо після розбивки ПІБа на частини через пробіл маємо не 3 а 4 частини,
            --першу частину завжди вважаємо прізвищем
            p_Pib_Split.LN := l_Part1;
            --а другу та третю частину - ім'ям
            p_Pib_Split.Fn := l_Part2 || ' ' || l_Part3;
            p_Pib_Split.Mn := l_Part4;
        END IF;
    END;

    --Переведення тексту в дату/час з поверненням NULL, якщо хоч якесь виключення
    FUNCTION tdate (p_dt VARCHAR2, p_format VARCHAR2:= 'DD.MM.YYYY')
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (p_dt, p_format);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --Переведення тексту в число з поверненням NULL, якщо хоч якесь виключення
    FUNCTION tnumber (p_number              VARCHAR2,
                      p_format              VARCHAR2 DEFAULT '999999999999D999',
                      p_decimal_separator   VARCHAR2 DEFAULT '.')
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (
                   p_number,
                   p_format,
                      'NLS_NUMERIC_CHARACTERS='''
                   || p_decimal_separator
                   || ' ''');
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- Додавання мясців до дати з урахування, що день наодження '28.02' повинен звлишатися таким і в високосному році.
    FUNCTION ADD_MONTHS_LEAP (p_dt DATE, p_months NUMBER)
        RETURN DATE
    AS
        l_ret   DATE;
    BEGIN
        l_ret := ADD_MONTHS (p_dt, p_months);

        IF     TO_CHAR (l_ret, 'dd.mm') = '29.02'
           AND TO_CHAR (P_dt, 'dd.mm') = '28.02'
        THEN
            RETURN l_ret - 1;
        END IF;

        RETURN l_ret;
    END;

    -- least без null як мінімального значення
    FUNCTION least_nn (dt1   DATE,
                       dt2   DATE DEFAULT NULL,
                       dt3   DATE DEFAULT NULL,
                       dt4   DATE DEFAULT NULL,
                       dt5   DATE DEFAULT NULL,
                       dt6   DATE DEFAULT NULL)
        RETURN DATE
    AS
        ret   DATE;

        -----------------------------------------------------
        PROCEDURE compare (ret_dt IN OUT DATE, val_dt IN DATE)
        IS
        BEGIN
            IF ret_dt IS NULL
            THEN
                ret_dt := val_dt;
            ELSIF val_dt IS NOT NULL AND val_dt < ret_dt
            THEN
                ret_dt := val_dt;
            END IF;
        END;
    -----------------------------------------------------
    BEGIN
        ret := dt1;
        compare (ret, dt2);
        compare (ret, dt3);
        compare (ret, dt4);
        compare (ret, dt5);
        compare (ret, dt6);
        RETURN ret;
    END;

    PROCEDURE LOG (p_src              VARCHAR2,
                   p_obj_tp           VARCHAR2,
                   p_obj_id           NUMBER,
                   p_regular_params   VARCHAR2,
                   p_lob_param        CLOB DEFAULT NULL)
    IS
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (UPPER (p_src),
                                         UPPER (p_obj_tp),
                                         p_obj_id,
                                         p_regular_params,
                                         p_lob_param);
    END;

    PROCEDURE logSes (p_src              VARCHAR2,
                      p_regular_params   VARCHAR2,
                      p_lob_param        CLOB DEFAULT NULL)
    IS
    BEGIN
        LOG (p_src,
             g_Log_Ses_Src,
             g_Log_Ses_Obj_Id,
             p_regular_params,
             p_lob_param);
    END;

    PROCEDURE Start_Log_Ses_Id (p_Src IN VARCHAR2, p_Obj_Id IN NUMBER)
    IS
    BEGIN
        g_Log_Ses_Src := p_Src;
        g_Log_Ses_Obj_Id := p_Obj_Id;
    END;

    PROCEDURE Stop_Log_Ses_id
    IS
    BEGIN
        g_Log_Ses_Src := NULL;
        g_Log_Ses_Obj_Id := NULL;
    END;

    -- ПІБ з налаштувань облікової політики
    -- p_mode = 0 - керівника з облікової політики
    -- p_mode = 1 - особу, що затверджує з облікової політики
    -- p_org  - com_org для якого потрібно визначити ПІБ  #97222 io 20240117
    FUNCTION get_acc_setup_pib (p_mode       IN NUMBER,
                                p_pib_mode   IN NUMBER DEFAULT 1,
                                p_org        IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_pib         VARCHAR2 (1000);
        l_org         NUMBER := NVL (p_org, getcurrorg);
        l_field       VARCHAR2 (50)
            := CASE
                   WHEN p_mode = 0 THEN 'acs_Fnc_Signer'
                   WHEN p_mode = 1 THEN 'acs_Fnc_Bt_Allow'
               END;
        l_pib_field   VARCHAR2 (500)
            := CASE
                   WHEN p_pib_mode = 0
                   THEN
                       'f.fnc_ln || '' '' || f.fnc_fn || '' '' || f.fnc_mn '
                   WHEN p_pib_mode = 1
                   THEN
                       'f.fnc_ln || '' '' || substr(f.fnc_fn, 1, 1) || ''. '' || substr(f.fnc_mn, 1, 1) || ''.'' '
               END;
    BEGIN
        EXECUTE IMMEDIATE '
  SELECT max(' || l_pib_field || ')
    FROM uss_ndi.v_ndi_acc_setup t
    JOIN uss_ndi.v_ndi_functionary f ON (f.fnc_id = t.' || l_field || ')
   WHERE t.com_org = :1
  '
            INTO l_pib
            USING l_org;

        RETURN l_Pib;
    END;

    -- ПОСАДА з налаштувань облікової політики
    -- p_mode = 0 - керівника з облікової політики
    -- p_mode = 1 - особу, що затверджує з облікової політики
    FUNCTION get_acc_setup_pos (p_mode IN NUMBER)
        RETURN VARCHAR2
    IS
        l_pib     VARCHAR2 (1000);
        l_org     NUMBER := getcurrorg;
        l_field   VARCHAR2 (50)
            := CASE
                   WHEN p_mode = 0 THEN 'acs_Fnc_Signer'
                   WHEN p_mode = 1 THEN 'acs_Fnc_Bt_Allow'
               END;
    BEGIN
        EXECUTE IMMEDIATE '
  SELECT max(f.fnc_post)
    FROM uss_ndi.v_ndi_acc_setup t
    JOIN uss_ndi.v_ndi_functionary f ON (f.fnc_id = t.' || l_field || ')
   WHERE t.com_org = :1
  '
            INTO l_pib
            USING l_org;

        RETURN l_pib;
    END;

    --========================================
    PROCEDURE validate_param (p_val VARCHAR2)
    IS
        l_val   VARCHAR2 (4000);
        l_cnt   NUMBER;
    BEGIN
        IF Ikis_Sysweb.IKIS_HTMLDB_COMMON.validate_param (p_val) > 0
        THEN
            raise_application_error (-20000, 'Помилка вхідних данних!');
        END IF;
    END;

    --========================================

    PROCEDURE raise_exception (p_cnt INTEGER, p_msg VARCHAR2)
    IS
    BEGIN
        IF p_cnt > 0
        THEN
            raise_application_error (-20000, p_msg);
        END IF;
    END;

    FUNCTION GetStartPackageName (p_call_stack IN CLOB)
        RETURN VARCHAR2
    IS
        TYPE t_rows IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_rows   t_rows;
        l_res    VARCHAR2 (1000);
        l_row    VARCHAR2 (1000);
        l_idx    NUMBER;
    BEGIN
        WITH rws AS (SELECT p_call_stack str FROM DUAL)
        SELECT VALUE     AS row_data
          BULK COLLECT INTO l_rows
          FROM (    SELECT REGEXP_SUBSTR (str,
                                          '[^' || CHR (10) || ']+',
                                          1,
                                          LEVEL)    VALUE
                      FROM rws
                CONNECT BY LEVEL <=
                             LENGTH (str)
                           - LENGTH (REPLACE (str, CHR (10)))
                           + 1)
         WHERE TRIM (VALUE) IS NOT NULL;

        IF l_rows.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        l_idx := l_rows.COUNT;

        WHILE l_row IS NULL AND l_idx > 0
        LOOP
            l_row := l_rows (l_idx);

            IF l_row IS NOT NULL
            THEN
                IF INSTR (LOWER (l_row), 'anonymous') > 0
                THEN
                    l_row := NULL;
                END IF;
            END IF;

            l_idx := l_idx - 1;
        END LOOP;

        BEGIN
              SELECT substring
                INTO l_res
                FROM (SELECT ROWNUM rn, substring
                        FROM (    SELECT TRIM (REGEXP_SUBSTR (l_row,
                                                              '[^' || ' ' || ']+',
                                                              1,
                                                              LEVEL))    AS substring
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (l_row,
                                                        '[^' || ' ' || ']+',
                                                        1,
                                                        LEVEL)
                                             IS NOT NULL))
            ORDER BY rn DESC
               FETCH FIRST 1 ROWS ONLY;

            RETURN l_res;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN NULL;
        END;
    END;

    FUNCTION GetAuditStack (p_call_stack IN CLOB)
        RETURN VARCHAR2
    IS
        TYPE t_rows IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_rows      t_rows;
        l_res       VARCHAR2 (1000);
        l_row       VARCHAR2 (1000);
        l_row_res   VARCHAR2 (1000);
    BEGIN
        WITH rws AS (SELECT p_call_stack str FROM DUAL)
        SELECT VALUE     AS row_data
          BULK COLLECT INTO l_rows
          FROM (    SELECT REGEXP_SUBSTR (str,
                                          '[^' || CHR (10) || ']+',
                                          1,
                                          LEVEL)    VALUE
                      FROM rws
                CONNECT BY LEVEL <=
                             LENGTH (str)
                           - LENGTH (REPLACE (str, CHR (10)))
                           + 1)
         WHERE TRIM (VALUE) IS NOT NULL;

        IF l_rows.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        FOR i IN 4 .. l_rows.COUNT
        LOOP
            l_row := l_rows (i);

            SELECT LISTAGG (substring, ' ')
              INTO l_row_res
              FROM (SELECT ROWNUM    rn,
                           CASE
                               WHEN ROWNUM = 2
                               THEN
                                   LPAD (substring, 10, ' ') || '   '
                               ELSE
                                   substring
                           END       substring
                      FROM (    SELECT TRIM (REGEXP_SUBSTR (l_row,
                                                            '[^' || ' ' || ']+',
                                                            1,
                                                            LEVEL))    AS substring
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (l_row,
                                                      '[^' || ' ' || ']+',
                                                      1,
                                                      LEVEL)
                                           IS NOT NULL))
             WHERE rn > 1;

            l_res := l_res || l_row_res || CHR (10);
        END LOOP;

        RETURN l_Res;
    END;

    PROCEDURE set_nls
    IS
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');
    END;



    FUNCTION split_str (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN t_str_array
        PIPELINED
    AS
        l_str   LONG := p_str || p_delim;
        l_n     NUMBER;
    BEGIN
        LOOP
            l_n := INSTR (l_str, p_delim);
            EXIT WHEN (NVL (l_n, 0) = 0);
            PIPE ROW (LTRIM (RTRIM (SUBSTR (l_str, 1, l_n - 1))));
            l_str := SUBSTR (l_str, l_n + 1);
        END LOOP;

        RETURN;
    END split_str;

    FUNCTION split_str2 (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN VARCHAR2
        SQL_MACRO
    IS
    BEGIN
        RETURN q'{
    select trim(regexp_substr(p_str,'[^' || p_delim || ']+', 1, level)) as substring
    from dual
    connect by regexp_substr(p_str, '[^' || p_delim || ']+', 1, level) is not null
  }';
    END split_str2;

    FUNCTION Clear_Name (p_Name IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REGEXP_REPLACE (
                   TRIM (
                       TRANSLATE (UPPER (p_Name),
                                  'ETIOPAHKXCBM’',
                                  'ЕТІОРАНКХСВМ''')),
                   '[^ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЇІЄҐ'' -]');
    END;
BEGIN
    -- Initialization
    init_tools;
END TOOLS;
/