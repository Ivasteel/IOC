/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.RDM$MSG_TEMPLATE
IS
    -- Author  : VANO
    -- Created : 14.06.2021 14:12:46
    -- Purpose : Функції роботи з шаблонами повідомлень

    --Повідомлення в системі можуть зберігатись у вигляді закодованих даних з посиланням на шаблон.
    --Підтримуються такі способи кодування:
    --1. Починається з символу &. Далі слідує номер шаблона з таблиці ndi_msg_template.
    --   Далі ідуть дані, розділені символом # в порядку, які потрібний для заповлення шаблону,
    --   в якому також розташовані символи # - зазвичай даних повинно бути стільки ж, скільки в шаблоні символів #.
    --   Приклад №1: дані=&15#Іванов#23, шаблон15=Бігун # посів загальне місце # в заліку.
    --2. Відрізняєтся від першого способу можливістю посилання на значення з довідника.
    --   Щоб зберегти в повідомлення посилання на значення з довідника необхідно
    --   після символу # вказати @ та ід запису в таблиці ndi_dict_config,
    --   що містить SQL для вичитування значень з цього довідника
    --   потім ще раз @ та ід з довідника
    --При виводі даних протоколів/повідомленнь, відповідно пишеться View, який містить таке:
    --SELECT RDM$MSG_TEMPLATE.GetMessageText(udl_message) AS udl_message FROM ud_log
    --Функція перекодування нічого не робить, якщо не знаходить першим символом повідомлення ключові символи

    --Повертає повідомлення в залежності від складу даних p_message
    FUNCTION Getmessagetext (p_Message IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Очищення кеша шаблонів
    PROCEDURE Resetcache;
END Rdm$msg_Template;
/


GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_DOC
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.RDM$MSG_TEMPLATE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.RDM$MSG_TEMPLATE
IS
    TYPE cash_table_type IS TABLE OF VARCHAR2 (4000)
        INDEX BY VARCHAR2 (40);

    TYPE cache_dic_type IS TABLE OF cash_table_type
        INDEX BY VARCHAR2 (40);

    g_templates            cash_table_type;
    g_dic_cache            cache_dic_type;

    c_template1   CONSTANT VARCHAR2 (1) := '&';
    c_template2   CONSTANT VARCHAR2 (1) := '@';
    c_variable    CONSTANT VARCHAR2 (1) := '#';

    --c_eq CONSTANT varchar2(1) := '=';

    FUNCTION GetTemplateStr (p_id_template VARCHAR2)
        RETURN VARCHAR2
    IS
        --отримуємо шаблон з messagetemplates по id шаблона (використовуємо кеш).
        l_id_template   NUMBER;
        l_msg_text      ndi_msg_template.nmt_text%TYPE;
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
                l_msg_text := g_templates (l_id_template);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT nmt_text
                          INTO l_msg_text
                          FROM ndi_msg_template
                         WHERE nmt_id = l_id_template;

                        g_templates (l_id_template) := l_msg_text;
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
    END GetTemplateStr;

    FUNCTION getValueFromDic (p_dic VARCHAR2, p_id VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Dic_Val   VARCHAR2 (250);
        l_Ndc_Sql   Ndi_Dict_Config.Ndc_Sql%TYPE;
    BEGIN
        SELECT c.Ndc_Sql
          INTO l_Ndc_Sql
          FROM Ndi_Dict_Config c
         WHERE c.Ndc_Id = TO_NUMBER (p_Dic);

        EXECUTE IMMEDIATE   'SELECT NAME FROM('
                         || l_Ndc_Sql
                         || ') WHERE ID = :p_id'
            INTO l_Dic_Val
            USING p_id;

        RETURN l_Dic_Val;
    END getValueFromDic;


    FUNCTION getDic (p_dic VARCHAR2)
        RETURN VARCHAR2
    IS
        l_dic              VARCHAR2 (10);
        l_dic_id_row       NUMBER;
        l_dic_id_row_str   VARCHAR (50);                   --для символьних id
        l_msg_text         VARCHAR2 (4000);
        l_cnt              NUMBER := 0;
    BEGIN
        IF p_dic IS NULL
        THEN
            RETURN NULL;
        ELSE
            --розбиваємо на параметр довідника та id стрічки
            FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                                  '[^' || c_template2 || ']+',
                                                  1,
                                                  LEVEL)    str
                              FROM (SELECT p_dic str FROM DUAL) t
                        CONNECT BY INSTR (str,
                                          c_template2,
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
                --raise_application_error(-20000,l_dic||'|'||l_dic_id_row_str);
                l_msg_text := g_dic_cache (l_dic) (l_dic_id_row_str);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        --одержання даних з довідників
                        l_msg_text :=
                            getValueFromDic (l_dic, l_dic_id_row_str);
                        g_dic_cache (l_dic) (l_dic_id_row_str) := l_msg_text;
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
    FUNCTION GetMsgByTemplate (p_template IN VARCHAR2--,p_tp IN VARCHAR2
                                                     )
        RETURN VARCHAR2
    IS
        l_cnt             NUMBER := 0;
        l_template_text   VARCHAR2 (4000);
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
                    l_template_text := GetTemplateStr (cur.str);
                ELSE
                    IF SUBSTR (cur.str, 1, 1) = c_template2
                    THEN                                  --p_tp = c_template2
                        l_template_text :=
                            REGEXP_REPLACE (l_template_text,
                                            c_variable,
                                            getDic (cur.str),
                                            1,
                                            1);
                    ELSE
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
    END GetMsgByTemplate;

    --проводить розбивку на шаблони (передбачається, що повідомлення може скаладатись з декількох шаблонів
    FUNCTION GetMsgText (p_message IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_msg   VARCHAR2 (4000);
    BEGIN
        FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                              '[^' || c_template1 /*||'|'||c_template2*/
                                                                  || ']+',
                                              1,
                                              LEVEL)    str,
                               REGEXP_SUBSTR (str,
                                              '[' || c_template1 /*||'|'||c_template2*/
                                                                 || ']',
                                              1,
                                              LEVEL)    tp
                          FROM (SELECT p_message str FROM DUAL) t
                    CONNECT BY INSTR (str,
                                      c_template1       /*||'|'||c_template2*/
                                                 ,
                                      1,
                                      LEVEL) > 0)
        LOOP
            l_msg := l_msg || GetMsgByTemplate (cur.str           /*, cur.tp*/
                                                       );
        END LOOP;

        RETURN l_msg;
    END GetMsgText;

    --Повертає повідомлення в залежності від складу даних p_message
    FUNCTION GetMessageText (p_message IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_msg_text   VARCHAR2 (4000);
    BEGIN
        IF p_message IS NULL
        THEN
            RETURN NULL;
        ELSE
            --Якщо параметр містить починається з символу "початок шаблону"
            IF SUBSTR (p_message, 1, 1) IN (c_template1      /*, c_template2*/
                                                       )
            THEN
                l_msg_text := GetMsgText (p_message);
            ELSE
                --якщо текст протоколу не починається з &
                l_msg_text := p_message;
            END IF;
        END IF;

        RETURN l_msg_text;
    END GetMessageText;

    --Очищення кеша шаблонів
    PROCEDURE ResetCache
    IS
    BEGIN
        g_templates.delete ();
        g_dic_cache.delete ();
    END;
END RDM$MSG_TEMPLATE;
/