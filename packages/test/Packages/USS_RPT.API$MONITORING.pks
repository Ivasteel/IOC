/* Formatted on 8/12/2025 5:58:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$MONITORING
IS
    -- Author  : SHOSTAK
    -- Created : 13.03.2023 1:37:49 PM
    -- Purpose :

    c_Src_Monitoring          CONSTANT VARCHAR2 (10) := '40';

    c_Mtr_Tp_Scalar           CONSTANT VARCHAR2 (10) := 'S';
    c_Mtr_Tp_System           CONSTANT VARCHAR2 (10) := 'SYS';

    c_Trg_State_Ok            CONSTANT VARCHAR2 (10) := 'OK';
    c_Trg_State_Problem       CONSTANT VARCHAR2 (10) := 'PROBLEM';
    c_Trg_State_Invalid       CONSTANT VARCHAR2 (10) := 'INVALID';

    c_Default_Fact_Lifetime   CONSTANT VARCHAR2 (10) := '5d';

    c_Mtr_Invalid             CONSTANT VARCHAR2 (10) := 'INVALID';

    PROCEDURE Collect_Metrics (p_Thread IN NUMBER);

    FUNCTION Define_Trigger_State (p_Trg IN OUT NOCOPY Ms_Trigger%ROWTYPE)
        RETURN VARCHAR2;

    PROCEDURE Refresh_Triggers;

    PROCEDURE Acknowledge_Event (p_Evt_Id    IN NUMBER,
                                 p_Trg_Id    IN NUMBER,
                                 p_Message   IN VARCHAR2,
                                 p_Hs_Id     IN NUMBER);

    FUNCTION Get_Mtr_Error_Cnt
        RETURN NUMBER;

    FUNCTION Get_Mtr_Error_Details
        RETURN VARCHAR2;

    FUNCTION Get_Trg_Error_Cnt
        RETURN NUMBER;

    FUNCTION Get_Trg_Error_Details
        RETURN VARCHAR2;

    FUNCTION Get_Mtr_Val_Dt (p_Mtr_Code IN VARCHAR2)
        RETURN DATE;

    FUNCTION Get_Mtr_Val_Num (p_Mtr_Code IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Mtr_Details (p_Mtr_Code IN VARCHAR2)
        RETURN VARCHAR2;
END Api$monitoring;
/


/* Formatted on 8/12/2025 5:58:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$MONITORING
IS
    -------------------------------------------------------
    --  Збереження помилки збору метрики
    -------------------------------------------------------
    PROCEDURE Save_Collect_Error (p_Mtr_Id IN NUMBER, p_Error IN VARCHAR2)
    IS
    BEGIN
        UPDATE Ms_Metric m
           SET m.Mtr_Details = p_Error, m.Mtr_Val_Str = c_Mtr_Invalid
         WHERE m.Mtr_Id = p_Mtr_Id;
    END;

    -------------------------------------------------------
    --Збереження останньої дати виконання джоба моніторингу
    -------------------------------------------------------
    PROCEDURE Save_Last_Job_Dt (p_Mtr_Code          IN VARCHAR2, --Код службової метрики для фіксації останньої дати виконання джоба
                                p_Mtr_Description   IN VARCHAR2 --Опис службової метрики для фіксації останньої дати виконання джоба
                                                               )
    IS
        l_Mtr_Id   NUMBER;
    BEGIN
        SELECT MAX (m.Mtr_Id)
          INTO l_Mtr_Id
          FROM Ms_Metric m
         WHERE m.Mtr_Code = p_Mtr_Code;

        IF l_Mtr_Id IS NULL
        THEN
            INSERT INTO Ms_Metric (Mtr_Id,
                                   Mtr_Code,
                                   Mtr_Description,
                                   Mtr_Tp,
                                   Mtr_Val_Dt,
                                   History_Status)
                 VALUES (0,
                         p_Mtr_Code,
                         p_Mtr_Description,
                         c_Mtr_Tp_System,
                         SYSDATE,
                         'A');
        ELSE
            UPDATE Ms_Metric m
               SET m.Mtr_Val_Dt = SYSDATE
             WHERE m.Mtr_Id = l_Mtr_Id;
        END IF;
    END;

    -------------------------------------------------------
    --  Видалення історії метрик
    -------------------------------------------------------
    PROCEDURE Clear_Fact (p_Mtr IN OUT NOCOPY Ms_Metric%ROWTYPE)
    IS
        l_Interval   VARCHAR2 (10);
        l_Unit       VARCHAR2 (10);
    BEGIN
        IF p_Mtr.Mtr_Fact_Lifetime = '0'
        THEN
            RETURN;
        END IF;

        p_Mtr.Mtr_Fact_Lifetime :=
            NVL (p_Mtr.Mtr_Fact_Lifetime, c_Default_Fact_Lifetime);

        --Визначаємо одиницю вимірування, яку вказано в налаштуваннях періоду зберігання історії
        l_Unit :=
            UPPER (
                SUBSTR (p_Mtr.Mtr_Fact_Lifetime,
                        LENGTH (p_Mtr.Mtr_Fact_Lifetime),
                        1));

        IF l_Unit NOT IN ('H', 'D')
        THEN
            Raise_Application_Error (
                -20000,
                   'В полі MTR_FACT_LIFETIME некоректно вказано одиницю вимірювання для періоду зберігання істроії метрики '
                || NVL (p_Mtr.Mtr_Code, TO_CHAR (p_Mtr.Mtr_Id))
                || '. Дозволяються такі одиниці: D - день, H - година');
        END IF;

        l_Unit :=
            CASE l_Unit
                WHEN 'D' THEN 'DAY'
                WHEN 'H' THEN 'HOUR'
                ELSE 'DAY'
            END;

        --Виззначаємо інтервал, який вказано в налаштуваннях періоду зберігання історії
        l_Interval :=
            SUBSTR (p_Mtr.Mtr_Fact_Lifetime,
                    1,
                    LENGTH (p_Mtr.Mtr_Fact_Lifetime) - 1);

        IF NOT REGEXP_LIKE (l_Interval, '^[0-9]{1,10}$')
        THEN
            Raise_Application_Error (
                -20000,
                   'В полі MTR_FACT_LIFETIME некоректно вказано період зберігання істроії метрики '
                || NVL (p_Mtr.Mtr_Code, TO_CHAR (p_Mtr.Mtr_Id)));
        END IF;

        --Видаляємо історію старше періоду, що вказано в налаштуваннях
        DELETE FROM Ms_Metric_Fact f
              WHERE     f.Mtrf_Mtr = p_Mtr.Mtr_Id
                    AND   f.Mtrf_Collect_Start
                        + NUMTODSINTERVAL (l_Interval, l_Unit) <=
                        SYSDATE;
    EXCEPTION
        WHEN OTHERS
        THEN
            Save_Collect_Error (
                p_Mtr.Mtr_Id,
                SQLERRM || CHR (10) || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -------------------------------------------------------
    -- Збір метрики зі скалярним(точковим) типом значення
    -------------------------------------------------------
    PROCEDURE Collect_Scalar (p_Mtr IN OUT NOCOPY Ms_Metric%ROWTYPE)
    IS
        l_Collect_Start   DATE;
        l_Cur_Id          INTEGER;
        l_Columns         DBMS_SQL.Desc_Tab;
        l_Columns_Cnt     PLS_INTEGER;
        l_Sql_Result      NUMBER;
        l_Fetch           NUMBER;
        l_Val_Num         NUMBER;
        l_Val_Str         Ms_Metric.Mtr_Val_Str%TYPE;
        l_Val_Dt          DATE;
        l_Details         VARCHAR2 (4000);
    BEGIN
        l_Collect_Start := SYSDATE;
        l_Cur_Id := DBMS_SQL.Open_Cursor;

        BEGIN
            --Парсимо та виконуємо запит для збору метрики, який вказано в налаштуваннях
            DBMS_SQL.Parse (l_Cur_Id,
                            p_Mtr.Mtr_Collect_Query,
                            DBMS_SQL.Native);
            l_Sql_Result := DBMS_SQL.Execute (l_Cur_Id);

            BEGIN
                DBMS_SQL.Describe_Columns (l_Cur_Id,
                                           l_Columns_Cnt,
                                           l_Columns);
            EXCEPTION
                WHEN OTHERS
                THEN
                    IF SQLCODE = -6502
                    THEN
                        Raise_Application_Error (
                            -20000,
                               'В запиті для метрики '
                            || NVL (p_Mtr.Mtr_Code, p_Mtr.Mtr_Id)
                            || ' потрібно вказати аліас для поля');
                    END IF;

                    RAISE;
            END;

            IF l_Sql_Result <> 0
            THEN
                Raise_Application_Error (
                    -20000,
                       'Запит для метрики '
                    || NVL (p_Mtr.Mtr_Code, p_Mtr.Mtr_Id)
                    || ' повернув повернув помилку: '
                    || l_Sql_Result);
            END IF;

            FOR i IN 1 .. l_Columns_Cnt
            LOOP
                CASE l_Columns (i).Col_Type
                    WHEN DBMS_TYPES.Typecode_Number
                    THEN
                        DBMS_SQL.Define_Column (l_Cur_Id, i, l_Val_Num);
                    WHEN DBMS_TYPES.Typecode_Date
                    THEN
                        DBMS_SQL.Define_Column (l_Cur_Id, i, l_Val_Dt);
                    WHEN DBMS_TYPES.Typecode_Char
                    THEN
                        DBMS_SQL.Define_Column (l_Cur_Id,
                                                i,
                                                l_Val_Str,
                                                4000);
                    WHEN DBMS_TYPES.Typecode_Varchar
                    THEN
                        DBMS_SQL.Define_Column (l_Cur_Id,
                                                i,
                                                l_Val_Str,
                                                4000);
                    WHEN DBMS_TYPES.Typecode_Varchar2
                    THEN
                        DBMS_SQL.Define_Column (l_Cur_Id,
                                                i,
                                                l_Val_Str,
                                                4000);
                    ELSE
                        Raise_Application_Error (
                            -20000,
                               'Тип першого поля в запиті для метрики '
                            || NVL (p_Mtr.Mtr_Code, p_Mtr.Mtr_Id)
                            || ' не підтримується');
                END CASE;
            END LOOP;

            l_Fetch := DBMS_SQL.Fetch_Rows (l_Cur_Id);

            IF l_Fetch = 0
            THEN
                Raise_Application_Error (
                    -20000,
                       'Запит для метрики '
                    || NVL (p_Mtr.Mtr_Code, p_Mtr.Mtr_Id)
                    || ' повернув 0 рядків. Щоб уникнути цього, використовуйте агрегуючі COUNT/MIN/MAX/AVG функції в запиті');
            END IF;

            --Зберігаємо результат запиту у змінну в залежності від типу даних поля
            CASE l_Columns (1).Col_Type
                WHEN DBMS_TYPES.Typecode_Number
                THEN
                    DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 1, l_Val_Num);
                WHEN DBMS_TYPES.Typecode_Date
                THEN
                    DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 1, l_Val_Dt);
                WHEN DBMS_TYPES.Typecode_Char
                THEN
                    DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 1, l_Val_Str);
                WHEN DBMS_TYPES.Typecode_Varchar
                THEN
                    DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 1, l_Val_Str);
                WHEN DBMS_TYPES.Typecode_Varchar2
                THEN
                    DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 1, l_Val_Str);
                ELSE
                    Raise_Application_Error (
                        -20000,
                           'Тип першого поля в запиті для метрики '
                        || NVL (p_Mtr.Mtr_Code, p_Mtr.Mtr_Id)
                        || ' не підтримується');
            END CASE;

            IF     l_Columns_Cnt > 1
               AND l_Columns (2).Col_Type IN
                       (DBMS_TYPES.Typecode_Char,
                        DBMS_TYPES.Typecode_Varchar,
                        DBMS_TYPES.Typecode_Varchar2)
            THEN
                --Зберігаємо(за наявністю) у змінну додаткову інформацію щодо поточного значення метрики
                --Raise_Application_Error(-20000, l_Columns(2).Col_Type);
                DBMS_SQL.COLUMN_VALUE (l_Cur_Id, 2, l_Details);
            END IF;

            DBMS_SQL.Close_Cursor (l_Cur_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_SQL.Close_Cursor (l_Cur_Id);
                RAISE;
        END;

        --Зберігаємо поточне значення метрики
        UPDATE Ms_Metric m
           SET m.Mtr_Val_Num = l_Val_Num,
               m.Mtr_Val_Dt = l_Val_Dt,
               m.Mtr_Val_Str = l_Val_Str,
               m.Mtr_Details = l_Details,
               m.Mtr_Collect_Start = l_Collect_Start,
               m.Mtr_Collect_Stop = SYSDATE
         WHERE m.Mtr_Id = p_Mtr.Mtr_Id;

        IF NVL (p_Mtr.Mtr_Fact_Lifetime, c_Default_Fact_Lifetime) <> '0'
        THEN
            --Зберігаємо значення метрики до історії
            INSERT INTO Ms_Metric_Fact (Mtrf_Id,
                                        Mtrf_Mtr,
                                        Mtrf_Collect_Start,
                                        Mtrf_Collect_Stop,
                                        Mtrf_Val_Dt,
                                        Mtrf_Val_Str,
                                        Mtrf_Val_Num,
                                        Mtrf_Details)
                 VALUES (0,
                         p_Mtr.Mtr_Id,
                         l_Collect_Start,
                         SYSDATE,
                         l_Val_Dt,
                         l_Val_Str,
                         l_Val_Num,
                         l_Details);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            Save_Collect_Error (
                p_Mtr.Mtr_Id,
                SQLERRM || CHR (10) || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -------------------------------------------------------
    --  Визначення чи не настав час збору метрики
    -------------------------------------------------------
    FUNCTION Is_Time_To_Collect (p_Mtr IN OUT NOCOPY Ms_Metric%ROWTYPE)
        RETURN BOOLEAN
    IS
        l_Interval   VARCHAR2 (10);
        l_Unit       VARCHAR2 (10);
    BEGIN
        --Визначаємо одиницю вимірювання, яку вказано в налаштуваннях інтервалу збору метрики
        l_Unit :=
            UPPER (
                SUBSTR (p_Mtr.Mtr_Interval, LENGTH (p_Mtr.Mtr_Interval), 1));

        IF l_Unit NOT IN ('M', 'H')
        THEN
            Raise_Application_Error (
                -20000,
                   'В полі MTR_INTERVAL некоректно вказано одиницю вимірювання для інтервалу сбору метрики '
                || NVL (p_Mtr.Mtr_Code, TO_CHAR (p_Mtr.Mtr_Id))
                || '. Дозволяються такі одиниці: M - хвилина, H - година');
        END IF;

        l_Unit :=
            CASE l_Unit
                WHEN 'M' THEN 'MINUTE'
                WHEN 'H' THEN 'HOUR'
                ELSE 'MINUTE'
            END;

        --Визначаємо інтервал, який вказано в налаштуваннях інтервалу збору метрики
        l_Interval :=
            SUBSTR (p_Mtr.Mtr_Interval, 1, LENGTH (p_Mtr.Mtr_Interval) - 1);

        IF NOT REGEXP_LIKE (l_Interval, '^[0-9]{1,10}$')
        THEN
            Raise_Application_Error (
                -20000,
                   'В полі MTR_INTERVAL некоректно вказано інтервал сбору метрики '
                || NVL (p_Mtr.Mtr_Code, TO_CHAR (p_Mtr.Mtr_Id)));
        END IF;

        RETURN   NVL (p_Mtr.Mtr_Collect_Stop,
                      TO_DATE ('01.01.2023', 'dd.mm.yyyy'))
               + NUMTODSINTERVAL (TO_NUMBER (l_Interval), l_Unit) <=
               SYSDATE;
    EXCEPTION
        WHEN OTHERS
        THEN
            Save_Collect_Error (
                p_Mtr.Mtr_Id,
                SQLERRM || CHR (10) || DBMS_UTILITY.Format_Error_Backtrace);
            RETURN FALSE;
    END;

    -------------------------------------------------------
    --  Збереження останньої дати виконання джоба
    --  збору метрик
    -------------------------------------------------------
    PROCEDURE Save_Last_Collect_Time (p_Thread IN NUMBER)
    IS
    BEGIN
        Save_Last_Job_Dt (
            p_Mtr_Code   => 'COLLECTOR' || p_Thread,
            p_Mtr_Description   =>
                   'Службова метрика для фіксації останньої дати відпрацювання джобу №'
                || p_Thread
                || ' сбору метрик');
    END;

    -------------------------------------------------------
    --  Збір метрик
    -------------------------------------------------------
    PROCEDURE Collect_Metrics (p_Thread IN NUMBER)
    IS
    BEGIN
        FOR Mtr
            IN (SELECT *
                  FROM Ms_Metric m
                 WHERE     m.Mtr_Collect_Thread = p_Thread
                       AND m.History_Status = 'A'
                       AND m.Mtr_Tp <> c_Mtr_Tp_System)
        LOOP
            IF NOT Is_Time_To_Collect (Mtr)
            THEN
                CONTINUE;
            END IF;

            IF Mtr.Mtr_Tp = c_Mtr_Tp_Scalar
            THEN
                Collect_Scalar (Mtr);
            END IF;

            Clear_Fact (Mtr);
            COMMIT;

            Save_Last_Collect_Time (p_Thread);
            COMMIT;
        END LOOP;

        Save_Last_Collect_Time (p_Thread);
        COMMIT;
    END;

    -------------------------------------------------------
    --  Збереження останньої дати виконання джоба
    --  оновлення стану тригерів
    -------------------------------------------------------
    PROCEDURE Save_Last_Refresh_Time
    IS
    BEGIN
        Save_Last_Job_Dt (
            p_Mtr_Code   => 'REFRESHER',
            p_Mtr_Description   =>
                'Службова метрика для фіксації останньої дати відпрацювання джобу оновлення стану тригерів');
    END;

    -------------------------------------------------------
    --  Відправка повідомлень про подію
    -------------------------------------------------------
    PROCEDURE Send_Event_Notifications (p_Trg_Id    IN NUMBER,
                                        p_Trg_Tag   IN VARCHAR2,
                                        p_Evt_Id    IN NUMBER,
                                        p_Title     IN VARCHAR2,
                                        p_Message   IN VARCHAR2)
    IS
    BEGIN
        FOR Rec IN (SELECT s.Sub_Rec
                      FROM Ms_Subscription s
                     WHERE s.Sub_Trg = p_Trg_Id OR s.Sub_Trg_Tag = p_Trg_Tag)
        LOOP
            DECLARE
                l_Ntm_Id   NUMBER;
            BEGIN
                Uss_Person.Api$nt_Api.Sendmonitoringmessage (
                    p_Rec_Id   => Rec.Sub_Rec,
                    p_Source   => c_Src_Monitoring,
                    p_Title    => p_Title,
                    p_Text     => p_Message,
                    p_Ntm_Id   => l_Ntm_Id);

                INSERT INTO Ms_Notification (Nt_Id,
                                             Nt_Evt,
                                             Nt_Rec,
                                             Nt_Ntm)
                     VALUES (0,
                             p_Evt_Id,
                             Rec.Sub_Rec,
                             l_Ntm_Id);
            END;
        END LOOP;
    END;

    -------------------------------------------------------
    --  Визначення додаткової інформації
    --  щодо поточного стану тригера
    -------------------------------------------------------
    FUNCTION Define_Trigger_Details (p_Trg IN OUT NOCOPY Ms_Trigger%ROWTYPE)
        RETURN VARCHAR2
    IS
        l_Expression   VARCHAR2 (4000);
        l_Details      Ms_Trigger.Trg_Details_Expr%TYPE;
    BEGIN
        IF p_Trg.Trg_Details_Expr IS NULL
        THEN
            RETURN NULL;
        END IF;

        l_Expression := p_Trg.Trg_Details_Expr;


        FOR Rec IN (    SELECT REGEXP_SUBSTR (Str,
                                              '[@]{1}[NDS]{1}[:]{1}[A-Z_0-9]+',
                                              1,
                                              LEVEL)    Str
                          FROM (SELECT l_Expression AS Str FROM DUAL) t
                    CONNECT BY INSTR (Str,
                                      '@',
                                      1,
                                      LEVEL - 1) > 0)
        LOOP
            IF Rec.Str NOT LIKE '@_:%'
            THEN
                CONTINUE;
            END IF;

            l_Expression :=
                REPLACE (
                    l_Expression,
                    Rec.Str,
                       'Api$monitoring.Get_Mtr_Val_'
                    || CASE SUBSTR (Rec.Str, 2, 1)
                           WHEN 'N' THEN 'Num'
                           WHEN 'D' THEN 'Dt'
                           WHEN 'S' THEN 'Str'
                       END
                    || '('''
                    || REGEXP_REPLACE (Rec.Str, '[@]{1}[NDS]{1}[:]{1}')
                    || ''')');
        END LOOP;


        l_Expression := 'BEGIN :details := ' || l_Expression || '; END;';

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Details;

        RETURN l_Details;
    END;

    -------------------------------------------------------
    --  Визначення поточного стану тригера
    -------------------------------------------------------
    FUNCTION Define_Trigger_State (p_Trg IN OUT NOCOPY Ms_Trigger%ROWTYPE)
        RETURN VARCHAR2
    IS
        l_Expression   VARCHAR2 (4000);
        l_Is_Problem   BOOLEAN;
    BEGIN
        IF p_Trg.Trg_State_Expr IS NULL
        THEN
            RETURN NULL;
        END IF;

        l_Expression := p_Trg.Trg_State_Expr;

        FOR Rec IN (    SELECT REGEXP_SUBSTR (Str,
                                              '[@]{1}[NDS]{1}[:]{1}[A-Z_0-9]+',
                                              1,
                                              LEVEL)    Str
                          FROM (SELECT l_Expression AS Str FROM DUAL) t
                    CONNECT BY INSTR (Str,
                                      '@',
                                      1,
                                      LEVEL - 1) > 0)
        LOOP
            IF Rec.Str NOT LIKE '@_:%'
            THEN
                CONTINUE;
            END IF;

            l_Expression :=
                REPLACE (
                    l_Expression,
                    Rec.Str,
                       'Api$monitoring.Get_Mtr_Val_'
                    || CASE SUBSTR (Rec.Str, 2, 1)
                           WHEN 'N' THEN 'Num'
                           WHEN 'D' THEN 'Dt'
                           WHEN 'S' THEN 'Str'
                       END
                    || '('''
                    || REGEXP_REPLACE (Rec.Str, '[@]{1}[NDS]{1}[:]{1}')
                    || ''')');
        END LOOP;

        l_Expression := 'BEGIN :is_problem := ' || l_Expression || '; END;';
        DBMS_OUTPUT.Put_Line (l_Expression);

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Is_Problem;

        RETURN CASE
                   WHEN l_Is_Problem THEN c_Trg_State_Problem
                   ELSE c_Trg_State_Ok
               END;
    END;

    -------------------------------------------------------
    --  Отримання назви рівня важливості тригера
    -------------------------------------------------------
    FUNCTION Get_Severity_Name (p_Serverity IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        SELECT s.Dic_Sname
          INTO l_Result
          FROM Uss_Ndi.v_Ddn_Trg_Severity s
         WHERE s.Dic_Value = p_Serverity;

        RETURN l_Result;
    END;

    -------------------------------------------------------
    --  Оновлення поточного стану тригера
    -------------------------------------------------------
    PROCEDURE Refresh_Trigger_State (p_Trg IN OUT NOCOPY Ms_Trigger%ROWTYPE)
    IS
        l_State        Ms_Trigger.Trg_State%TYPE;
        l_Details      Ms_Trigger.Trg_Details%TYPE;
        l_Evt_Id       NUMBER;
        l_Message      VARCHAR2 (4000);
        l_State_Name   VARCHAR2 (100);
        l_Title        VARCHAR (200);
        l_Error        VARCHAR2 (4000);
    BEGIN
        --Отримуємо поточний стан тригера за допомогою булевого виразу,
        --що прописано в налаштуваннях
        l_State := Define_Trigger_State (p_Trg);

        IF l_State IS NULL
        THEN
            RETURN;
        END IF;

        IF     l_State IN (c_Trg_State_Problem)
           AND p_Trg.Trg_Details_Expr IS NOT NULL
        THEN
            --Отримуємо додаткову інформацію щодо поточного стану тригера
            --за допомогою виразу, що прописано в налаштуваннях
            l_Details := Define_Trigger_Details (p_Trg);
        END IF;

        --Оновлюємо стан тригера якщо він змінився
        UPDATE Ms_Trigger t
           SET t.Trg_State = l_State, t.Trg_Details = l_Details
         WHERE t.Trg_Id = p_Trg.Trg_Id AND NVL (t.Trg_State, 'U') <> l_State;

        --Якщо зафіксовано зміну стану тригера
        IF SQL%ROWCOUNT > 0
        THEN
            --Створюємо подію щодо зміни стану тригера
            INSERT INTO Ms_Event (Evt_Id,
                                  Evt_Dt,
                                  Evt_Trg,
                                  Evt_Trg_State,
                                  Evt_Details)
                 VALUES (0,
                         SYSDATE,
                         p_Trg.Trg_Id,
                         l_State,
                         l_Details)
              RETURNING Evt_Id
                   INTO l_Evt_Id;

            --Зберігаємо посилання на подію до тригера
            UPDATE Ms_Trigger t
               SET t.Trg_Last_Evt = l_Evt_Id
             WHERE t.Trg_Id = p_Trg.Trg_Id;

            SELECT s.Dic_Sname
              INTO l_State_Name
              FROM Uss_Ndi.v_Ddn_Trg_State s
             WHERE s.Dic_Value = l_State;

            l_Title :=
                   'Моніторинг ЄІССС: '
                || CASE
                       WHEN l_State = c_Trg_State_Ok THEN 'Проблему вирішено'
                       ELSE Get_Severity_Name (p_Trg.Trg_Severiry)
                   END;

            l_Message :=
                   'Тригер '
                || p_Trg.Trg_Name
                || ' перейшов у стан "'
                || l_State_Name
                || '"'
                || CASE
                       WHEN l_Details IS NOT NULL
                       THEN
                              CHR (13)
                           || CHR (10)
                           || CHR (13)
                           || CHR (10)
                           || 'Деталі:'
                           || CHR (13)
                           || CHR (10)
                           || l_Details
                   END;

            --Відправляємо повідомлення з інформацією про подію отримувачам,
            --що підписані на цей тригер
            Send_Event_Notifications (p_Trg_Id    => p_Trg.Trg_Id,
                                      p_Trg_Tag   => p_Trg.Trg_Tag,
                                      p_Evt_Id    => l_Evt_Id,
                                      p_Title     => l_Title,
                                      p_Message   => l_Message);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_Error :=
                SQLERRM || CHR (10) || DBMS_UTILITY.Format_Error_Backtrace;

            UPDATE Ms_Trigger t
               SET t.Trg_State = c_Trg_State_Invalid, t.Trg_Details = l_Error
             WHERE t.Trg_Id = p_Trg.Trg_Id;
    END;

    -------------------------------------------------------
    --  Перевірка стану тригерів
    -------------------------------------------------------
    PROCEDURE Refresh_Triggers
    IS
    BEGIN
        FOR Trg IN (SELECT *
                      FROM Ms_Trigger t
                     WHERE t.History_Status = 'A')
        LOOP
            Refresh_Trigger_State (Trg);
            COMMIT;

            Save_Last_Refresh_Time;
            COMMIT;
        END LOOP;
    END;

    -------------------------------------------------------
    --  Підтвердження події користувачем
    -------------------------------------------------------
    PROCEDURE Acknowledge_Event (p_Evt_Id    IN NUMBER,
                                 p_Trg_Id    IN NUMBER,
                                 p_Message   IN VARCHAR2,
                                 p_Hs_Id     IN NUMBER)
    IS
        l_Trg_Tag    Ms_Trigger.Trg_Tag%TYPE;
        l_Trg_Name   Ms_Trigger.Trg_Name%TYPE;
        l_Title      VARCHAR2 (100);
        l_Message    VARCHAR2 (4000);
        l_Wu_Pib     VARCHAR2 (300);
    BEGIN
        INSERT INTO Ms_Ack (Ack_Id,
                            Ack_Evt,
                            Ack_Hs,
                            Ack_Message)
             VALUES (0,
                     p_Evt_Id,
                     p_Hs_Id,
                     p_Message);

        SELECT t.Trg_Tag, t.Trg_Name
          INTO l_Trg_Tag, l_Trg_Name
          FROM Ms_Trigger t
         WHERE t.Trg_Id = p_Trg_Id;

        SELECT u.Wu_Pib
          INTO l_Wu_Pib
          FROM Histsession  s
               JOIN Ikis_Sysweb.V$all_Users u ON u.Wu_Id = s.Hs_Wu
         WHERE s.Hs_Id = p_Hs_Id;

        l_Title := 'Моніторинг ЄІССС: Підтверждення';
        l_Message :=
               'Користувач '
            || l_Wu_Pib
            || ' підтвердив проблему '
            || l_Trg_Name
            || '.'
            || CASE
                   WHEN p_Message IS NOT NULL THEN 'Коментар: ' || p_Message
               END;

        Send_Event_Notifications (p_Trg_Id    => p_Trg_Id,
                                  p_Trg_Tag   => l_Trg_Tag,
                                  p_Evt_Id    => p_Evt_Id,
                                  p_Title     => l_Title,
                                  p_Message   => l_Message);
    END;

    --------------------------------------------------------------
    --  Отримання кількості метрик при зборі яких виникли помилки
    --  (внутрішня перевірка працездатності системи моніторингу)
    --------------------------------------------------------------
    FUNCTION Get_Mtr_Error_Cnt
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Result
          FROM Ms_Metric m
         WHERE m.Mtr_Val_Str = c_Mtr_Invalid AND m.History_Status = 'A';

        RETURN l_Result;
    END;

    --------------------------------------------------------------
    --  Отримання переліку метрик при зборі яких виникли помилки
    --  (внутрішня перевірка працездатності системи моніторингу)
    --------------------------------------------------------------
    FUNCTION Get_Mtr_Error_Details
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT    'Виникли помилки збору метрик '
               || LISTAGG (m.Mtr_Code, ', ') WITHIN GROUP (ORDER BY Mtr_Code)
          INTO l_Result
          FROM Ms_Metric m
         WHERE m.Mtr_Val_Str = c_Mtr_Invalid AND m.History_Status = 'A';

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --  Отримання кількості тригерів при оновлені яких виникли помилки
    --  (внутрішня перевірка працездатності системи моніторингу)
    -------------------------------------------------------------------
    FUNCTION Get_Trg_Error_Cnt
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Result
          FROM Ms_Trigger t
         WHERE t.Trg_State = c_Trg_State_Invalid AND t.History_Status = 'A';

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --  Отримання переліку тригерів при оновлені яких виникли помилки
    --  (внутрішня перевірка працездатності системи моніторингу)
    -------------------------------------------------------------------
    FUNCTION Get_Trg_Error_Details
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT    'Виникли помилки оновлення тригерів "'
               || LISTAGG (t.Trg_Name, '", "')
                      WITHIN GROUP (ORDER BY Trg_Name)
               || '"'
          INTO l_Result
          FROM Ms_Trigger t
         WHERE t.Trg_State = c_Trg_State_Invalid AND t.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Mtr_Val_Dt (p_Mtr_Code IN VARCHAR2)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (m.Mtr_Val_Dt)
          INTO l_Result
          FROM Ms_Metric m
         WHERE m.Mtr_Code = p_Mtr_Code;

        RETURN l_Result;
    END;

    FUNCTION Get_Mtr_Val_Num (p_Mtr_Code IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (m.Mtr_Val_Num)
          INTO l_Result
          FROM Ms_Metric m
         WHERE m.Mtr_Code = p_Mtr_Code;

        RETURN l_Result;
    END;

    FUNCTION Get_Mtr_Details (p_Mtr_Code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Ms_Metric.Mtr_Details%TYPE;
    BEGIN
        SELECT MAX (m.Mtr_Details)
          INTO l_Result
          FROM Ms_Metric m
         WHERE m.Mtr_Code = p_Mtr_Code;

        RETURN l_Result;
    END;
END Api$monitoring;
/