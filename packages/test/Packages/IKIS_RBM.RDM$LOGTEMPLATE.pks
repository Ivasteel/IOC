/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$LOGTEMPLATE
IS
    FUNCTION GetLogText (p_protocol IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;
END RDM$LOGTEMPLATE;
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$LOGTEMPLATE
IS
    TYPE cash_table_type IS TABLE OF VARCHAR2 (500)
        INDEX BY VARCHAR2 (20);

    TYPE cash_dic_table_type IS TABLE OF cash_table_type
        INDEX BY VARCHAR2 (20);

    g_protocol_type       cash_table_type;
    g_dic_type            cash_dic_table_type;


    c_template   CONSTANT VARCHAR2 (1) := '&';
    c_variable   CONSTANT VARCHAR2 (1) := '#';
    c_spr        CONSTANT VARCHAR2 (1) := '@';

    FUNCTION GetProtocolStr (p_id_template VARCHAR2)
        RETURN VARCHAR2
    IS
        --отримуємо шаблон з messagetemplates по id шаблона (використовуємо кеш).
        l_id_template   NUMBER;
        l_msg_text      VARCHAR2 (500);
    BEGIN
        IF p_id_template IS NULL
        THEN
            RETURN NULL;
        ELSE
            BEGIN
                l_id_template := TO_NUMBER (p_id_template);
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                           'Невірний формат id шаблона. id_template ='
                        || p_id_template);
            END;

            BEGIN
                l_msg_text := g_protocol_type (l_id_template);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT a.mt_text
                          INTO l_msg_text
                          FROM messagetemplates a
                         WHERE a.mt_id = l_id_template;

                        g_protocol_type (l_id_template) := l_msg_text;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_msg_text :=
                                   'Відсутній шаблон id = '
                                || p_id_template
                                || ' в Довіднику шаблонів.';
                    END;
            END;
        END IF;

        RETURN l_msg_text;
    END GetProtocolStr;

    --отримуємо дані з довідників (використовуємо кеш), вхідний параметр типу '@ZTX@132'
    FUNCTION GetDic (p_dic VARCHAR2)
        RETURN VARCHAR2
    IS
        l_dic              VARCHAR2 (10);
        l_dic_id_row       NUMBER;
        l_dic_id_row_str   VARCHAR (50);                   --для символьних id
        l_msg_text         VARCHAR2 (500);
        l_cnt              NUMBER := 0;
    BEGIN
        IF p_dic IS NULL
        THEN
            RETURN NULL;
        ELSE
            --розбиваємо на параметр довідника та id стрічки
            FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                                  '[^' || c_spr || ']+',
                                                  1,
                                                  LEVEL)    str
                              FROM (SELECT p_dic str FROM DUAL) t
                        CONNECT BY INSTR (str,
                                          c_spr,
                                          1,
                                          LEVEL) > 0)
            LOOP
                IF l_cnt = 0
                THEN
                    l_dic := UPPER (cur.str); --перше значення -> параметр довідника
                ELSE
                    l_dic_id_row_str := cur.str;

                    BEGIN
                        l_dic_id_row := TO_NUMBER (cur.str); --далі id стрічки в довіднику
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;

            --одержання даних з кеша значень довідників
            BEGIN
                l_msg_text := g_dic_type (l_dic) (l_dic_id_row_str);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        --одержання даних з довідників
                        --значення з довідника надбавок ndi_raise, маска 'RAS'
                        IF l_dic = 'RAS'
                        THEN
                            --            SELECT t.ras_name INTO l_msg_text
                            --              FROM v_ndi_raise t WHERE t.ras_id = l_dic_id_row;
                            NULL;
                        END IF;

                        g_dic_type (l_dic) (l_dic_id_row_str) := l_msg_text;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_msg_text := 'Відсутні дані в Довідниках.';
                    END;
            END;
        END IF;

        RETURN l_msg_text;
    END GetDic;

    --проводить розбивку на значення та їх підстановку в шаблон,
    --вхідний параметр типу - '&31#71#27#794.81', або якщо довідник -'&71#@ZTX@132'
    FUNCTION GetMsgTemplate (p_template IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_cnt             NUMBER := 0;
        l_template_text   VARCHAR2 (1000                               /*500*/
                                        );
        l_msg_text        VARCHAR2 (500);
    BEGIN
        IF p_template IS NOT NULL
        THEN
            FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                                  '[^' || c_variable || ']+',
                                                  1,
                                                  LEVEL)    str
                              FROM (SELECT p_template str FROM DUAL) t
                        CONNECT BY INSTR (str,
                                          c_variable,
                                          1,
                                          LEVEL - 1) > 0)
            LOOP
                IF l_cnt = 0
                THEN
                    l_template_text := GetProtocolStr (cur.str);
                ELSE
                    -- перевірка на присутність признака довідника
                    IF SUBSTR (cur.str, 1, 1) = c_spr
                    THEN
                        l_msg_text := GetDic (cur.str);
                        --проводимо підстановку значень з довідника в шаблон
                        l_template_text :=
                            REGEXP_REPLACE (l_template_text,
                                            c_variable,
                                            l_msg_text,
                                            1,
                                            1);
                    ELSE
                        --якщо не з довідника, то проводимо підстановку значень в шаблон
                        l_template_text :=
                            REGEXP_REPLACE (l_template_text,
                                            c_variable,
                                            cur.str,
                                            1,
                                            1);
                    END IF;
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        ELSE
            l_template_text := NULL;
        END IF;

        RETURN l_template_text;
    END GetMsgTemplate;

    --проводить розбивку на шаблони
    FUNCTION GetMsgText (p_protocol IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_msg   VARCHAR2 (                                             /*500*/
                          1000);
    --  l_space VARCHAR2(1);
    BEGIN
        IF p_protocol IS NOT NULL
        THEN
            FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                                  '[^' || c_template || ']+',
                                                  1,
                                                  LEVEL)    str
                              FROM (SELECT p_protocol str FROM DUAL) t
                        CONNECT BY INSTR (str,
                                          c_template,
                                          1,
                                          LEVEL) > 0)
            LOOP
                l_msg := l_msg || GetMsgTemplate (cur.str);
            END LOOP;
        ELSE
            l_msg := NULL;
        END IF;

        RETURN l_msg;
    END GetMsgText;

    --повертає назву стрічки в залежності від даних p_protocol, при відсутності p_protocol по p_row_type
    FUNCTION GetLogText (p_protocol IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_msg_text   VARCHAR2 (                                        /*500*/
                               1000);
    BEGIN
        IF p_protocol IS NULL
        THEN
            RETURN NULL;
        ELSE
            --Якщо параметр містить інформацію з id шаблонів
            IF SUBSTR (p_protocol, 1, 1) = c_template
            THEN
                l_msg_text := GetMsgText (p_protocol);
            ELSE
                --якщо стрічка протоколу не починається з &
                l_msg_text := p_protocol;
            END IF;
        END IF;

        RETURN l_msg_text;
    END GetLogText;
END RDM$LOGTEMPLATE;
/