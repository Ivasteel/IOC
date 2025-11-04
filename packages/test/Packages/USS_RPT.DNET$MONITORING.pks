/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.DNET$MONITORING
IS
    -- Author  : SHOSTAK
    -- Created : 13.03.2023 4:18:43 PM
    -- Purpose :

    c_Wdg_Tp_Text       CONSTANT VARCHAR2 (10) := 'T';
    c_Wdg_Tp_Problems   CONSTANT VARCHAR2 (10) := 'P';
    c_Wdg_Tp_Chart      CONSTANT VARCHAR2 (10) := 'R';

    PROCEDURE Get_Dashboards (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Dashboard_Data (p_Dsb_Id             IN     NUMBER,
                                  p_Dsb_Name              OUT VARCHAR2,
                                  p_Self_Checks           OUT SYS_REFCURSOR,
                                  p_Widgets               OUT SYS_REFCURSOR,
                                  p_Problems              OUT SYS_REFCURSOR,
                                  p_Time_Series_Cols      OUT SYS_REFCURSOR,
                                  p_Time_Series_Data      OUT SYS_REFCURSOR);

    PROCEDURE Acknowledge_Event (p_Evt_Id    IN NUMBER,
                                 p_Trg_Id    IN NUMBER,
                                 p_Message   IN VARCHAR2);
END Dnet$monitoring;
/


GRANT EXECUTE ON USS_RPT.DNET$MONITORING TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.DNET$MONITORING
IS
    PROCEDURE Check_Access
    IS
        l_Wut        NUMBER;
        l_Wut_Code   Ikis_Sysweb.v_Full_User_Types.Wut_Code%TYPE;
    BEGIN
        l_Wut := Uss_Rpt_Context.Getcontext ('usertp');

        SELECT Wut_Code
          INTO l_Wut_Code
          FROM Ikis_Sysweb.v_Full_User_Types
         WHERE Wut_Id = l_Wut;

        IF NOT Ikis_Sysweb.Is_Role_Assigned (
                   Uss_Rpt_Context.Getcontext (
                       Uss_Rpt.Uss_Rpt_Context.Glogin),
                   'W_ESR_DEV',
                   l_Wut_Code)
        THEN
            Raise_Application_Error (-20000,
                                     'Недостатньо прав для перегляду');
        END IF;
    END;

    --------------------------------------------------------------
    --  Отримання переліку дашбордів
    --------------------------------------------------------------
    PROCEDURE Get_Dashboards (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR   SELECT d.Dsb_Id,
                                d.Dsb_Name,
                                d.Dsb_Order,
                                d.Dsb_Default
                           FROM Uss_Ndi.v_Ndi_Ms_Dashboard d
                          WHERE d.History_Status = 'A'
                       ORDER BY d.Dsb_Order;
    END;

    --------------------------------------------------------------
    --  Отримання даних для діаграм-часових рядів
    --------------------------------------------------------------
    PROCEDURE Get_Time_Series (p_Dsb_Id             IN     NUMBER,
                               p_Time_Series_Cols      OUT SYS_REFCURSOR,
                               p_Time_Series_Data      OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB := '';
    BEGIN
        OPEN p_Time_Series_Cols FOR
            SELECT w.Wdg_Id,
                      'y_Axis_'
                   || ROW_NUMBER ()
                          OVER (PARTITION BY w.Wdg_Id ORDER BY m.Mtr_Id)
                       AS Col,
                   M2.M2w_Chart_Label
                       AS Col_Name
              FROM Ms_Widget  w
                   JOIN Ms_Mtr2wdg M2 ON w.Wdg_Id = M2.M2w_Wdg
                   JOIN Ms_Metric m ON M2.M2w_Mtr = m.Mtr_Id
             WHERE     w.Wdg_Dsb = p_Dsb_Id
                   AND w.Wdg_Tp = c_Wdg_Tp_Chart
                   AND w.History_Status = 'A';

        FOR Wdg
            IN (SELECT *
                  FROM Ms_Widget w
                 WHERE     w.Wdg_Dsb = p_Dsb_Id
                       AND w.Wdg_Tp = c_Wdg_Tp_Chart
                       AND w.History_Status = 'A')
        LOOP
            DECLARE
                l_Wdg_Sql   CLOB := '';
            BEGIN
                FOR Mtr IN (  SELECT M2.*, ROWNUM AS Rn
                                FROM Ms_Mtr2wdg M2
                               WHERE M2.M2w_Wdg = Wdg.Wdg_Id
                            ORDER BY M2.M2w_Id)
                LOOP
                    l_Wdg_Sql :=
                           l_Wdg_Sql
                        || 'UNION ALL
      SELECT '
                        || Wdg.Wdg_Id
                        || ' as WDG_ID,
             '
                        || CASE Wdg.Wdg_Chart_Step
                               WHEN 'M'
                               THEN
                                   'To_Char(Mtrf_Collect_Start, ''DD.MM HH24:MI'')'
                               WHEN 'H'
                               THEN
                                   'To_Char(Mtrf_Collect_Start, ''DD.MM HH24'')'
                               WHEN 'D'
                               THEN
                                   'To_Char(Mtrf_Collect_Start, ''DD.MM'')'
                           END
                        || ' AS x_Axis,
               Trunc(Mtrf_Collect_Start, '''
                        || CASE Wdg.Wdg_Chart_Step
                               WHEN 'M' THEN 'MI'
                               WHEN 'H' THEN 'HH24'
                               WHEN 'D' THEN 'DD'
                           END
                        || ''') AS Dt,
               ''y_Axis_'
                        || Mtr.Rn
                        || ''' AS COL,
               Nvl(Mtrf_Val_Num, 0) AS Mtrf_Val_Num
      FROM Ms_Metric_Fact
      WHERE Mtrf_Mtr='
                        || Mtr.M2w_Mtr
                        || ' AND Mtrf_Collect_Start BETWEEN '
                        || Mtr.M2w_Chart_Start_Expr
                        || ' AND '
                        || NVL (Mtr.M2w_Chart_Stop_Expr, 'SYSDATE')
                        || CHR (13)
                        || CHR (10);
                END LOOP;

                l_Wdg_Sql := LTRIM (l_Wdg_Sql, 'UNION ALL');

                IF DBMS_LOB.Getlength (l_Wdg_Sql) > 0
                THEN
                    l_Wdg_Sql :=
                           'UNION ALL SELECT * FROM('
                        || l_Wdg_Sql
                        || ') PIVOT ('
                        || Wdg.Wdg_Chart_Agg_Func
                        || '(Mtrf_Val_Num) FOR COL IN(''y_Axis_1'' as y_Axis_1, ''y_Axis_2'' as y_Axis_2, ''y_Axis_3'' as y_Axis_3, ''y_Axis_4'' as y_Axis_4, ''y_Axis_5'' as y_Axis_5, ''y_Axis_6'' as y_Axis_6))'
                        || CHR (13)
                        || CHR (10);
                    l_Sql := l_Sql || l_Wdg_Sql || CHR (13) || CHR (10);
                END IF;
            END;
        END LOOP;

        l_Sql := LTRIM (l_Sql, 'UNION ALL');

        IF DBMS_LOB.Getlength (l_Sql) > 0
        THEN
            l_Sql := 'SELECT * FROM(' || l_Sql || ') ORDER BY WDG_ID, DT';
            DBMS_OUTPUT.Put_Line (l_Sql);

            OPEN p_Time_Series_Data FOR l_Sql;
        --
        ELSE
            OPEN p_Time_Series_Data FOR SELECT NULL     AS Wdg_Id
                                          FROM DUAL
                                         WHERE 1 = 2;
        END IF;
    END;

    --------------------------------------------------------------
    --  Отримання переліку проблем для дашборда
    --------------------------------------------------------------
    PROCEDURE Get_Problems (p_Dsb_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT w.Wdg_Id,
                     e.Evt_Dt,
                     e.Evt_Id,
                     t.Trg_Id,
                     t.Trg_Name,
                     CASE t.Trg_Severiry
                         WHEN 'W' THEN 'warning'
                         WHEN 'E' THEN 'danger'
                         WHEN 'C' THEN 'critical'
                     END                                 AS Trg_Severiry,
                     -- W-попередження, E-помилка, C-критична помилка
                     s.Dic_Name                          AS Trg_Severiry_Name,
                        t.Trg_Details
                     || (SELECT    CHR (13)
                                || CHR (10)
                                || 'Підтверджено користувачем '
                                || u.Wu_Pib
                                || ' '
                                || TO_CHAR (Hs.Hs_Dt,
                                            'dd.mm.yyyy hh24:mi:ss')
                                || CASE
                                       WHEN a.Ack_Message
                                                IS NOT NULL
                                       THEN
                                              'Коментар: '
                                           || a.Ack_Message
                                   END
                           FROM Ms_Ack a
                                JOIN Histsession Hs
                                    ON a.Ack_Hs = Hs.Hs_Id
                                JOIN Ikis_Sysweb.V$all_Users u
                                    ON Hs.Hs_Wu = u.Wu_Id
                          WHERE a.Ack_Evt = e.Evt_Id)    AS Trg_Details
                FROM Ms_Widget w
                     JOIN Ms_Trigger t
                         ON     ',' || REPLACE (w.Wdg_Trigger_Tags, ' ') || ',' LIKE
                                    '%,' || t.Trg_Tag || ',%'
                            AND t.History_Status = 'A'
                            AND t.Trg_State =
                                Api$monitoring.c_Trg_State_Problem
                     JOIN Ms_Event e ON t.Trg_Last_Evt = e.Evt_Id
                     JOIN Uss_Ndi.v_Ddn_Trg_Severity s
                         ON t.Trg_Severiry = s.Dic_Value
               WHERE     w.Wdg_Dsb = p_Dsb_Id
                     AND w.History_Status = 'A'
                     AND w.Wdg_Tp = c_Wdg_Tp_Problems
            --Сортуємо проблемні тригери в рамках віджета за рівнем важливості
            ORDER BY w.Wdg_Id,
                     DECODE (t.Trg_Severiry,  'C', 1,  'E', 2,  'W', 3) ASC,
                     e.Evt_Dt DESC;
    END;

    --------------------------------------------------------------
    --  Отримання переліку віджетів для дашборда
    --------------------------------------------------------------
    PROCEDURE Get_Widgets (p_Dsb_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT w.Wdg_Id,
                   w.Wdg_Dsb,
                   w.Wdg_Title,
                   w.Wdg_Tp,
                   w.Wdg_Mtr,
                   w.Wdg_Trigger_Tags,
                   w.Wdg_Chart_Config,
                   CASE WHEN w.Wdg_Tp = c_Wdg_Tp_Chart THEN 'LINE' --Поки реалізовуємо один тип чартів - часові ряди
                                                                   --якщо знадобляться інші - додати после в таблицю Ms_Widget
                                                                   END
                       AS Wdg_Chart_Tp,
                   w.Wdg_Order,
                   w.Wdg_Width,
                   w.Wdg_Height,
                   w.Wdg_Col_Num,
                   w.Wdg_Row_Num,
                   COALESCE (
                       TO_CHAR (m.Mtr_Val_Num),
                       TO_CHAR (m.Mtr_Val_Dt, 'dd.mm.yyyy hh24:mi:ss'),
                       NULLIF (m.Mtr_Val_Str, Api$monitoring.c_Mtr_Invalid))
                       AS Mtr_Val
              FROM Ms_Widget  w
                   LEFT JOIN Ms_Metric m
                       ON w.Wdg_Tp = c_Wdg_Tp_Text AND w.Wdg_Mtr = m.Mtr_Id
             WHERE w.Wdg_Dsb = p_Dsb_Id AND w.History_Status = 'A';
    END;

    --------------------------------------------------------------
    --  Отримання інформації про проблеми
    --  в роботі системи моніторингу
    --------------------------------------------------------------
    PROCEDURE Get_Self_Checks (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT    'Останній збір метрик виконувався потоком №'
                   || SUBSTR (m.Mtr_Code, 10, LENGTH (m.Mtr_Code) - 9)
                   || ' '
                   || TO_CHAR (m.Mtr_Val_Dt, 'dd.mm.yyyy hh24:mi')    AS MESSAGE
              FROM Ms_Metric m
             WHERE     m.Mtr_Tp = Api$monitoring.c_Mtr_Tp_System
                   AND m.Mtr_Code LIKE 'COLLECTOR%'
                   AND m.Mtr_Val_Dt + INTERVAL '30' MINUTE < SYSDATE
            UNION ALL
            SELECT    'Останнє оновленя стану тригерів було '
                   || TO_CHAR (m.Mtr_Val_Dt, 'dd.mm.yyyy hh24:mi')    AS MESSAGE
              FROM Ms_Metric m
             WHERE     m.Mtr_Tp = Api$monitoring.c_Mtr_Tp_System
                   AND m.Mtr_Code = 'REFRESHER'
                   AND m.Mtr_Val_Dt + INTERVAL '10' MINUTE < SYSDATE
            UNION ALL
            SELECT    'Помилка збору метрики '
                   || m.Mtr_Code
                   || ': '
                   || m.Mtr_Details
              FROM Ms_Metric m
             WHERE     m.History_Status = 'A'
                   AND m.Mtr_Val_Str = Api$monitoring.c_Mtr_Invalid
            UNION ALL
            SELECT    'Помилка оновлення стану тригера '
                   || t.Trg_Name
                   || ': '
                   || t.Trg_Details
              FROM Ms_Trigger t
             WHERE     t.History_Status = 'A'
                   AND t.Trg_State = Api$monitoring.c_Trg_State_Invalid;
    END;

    --------------------------------------------------------------
    --  Отримання даних та налаштувань для дашбору
    --------------------------------------------------------------
    PROCEDURE Get_Dashboard_Data (p_Dsb_Id             IN     NUMBER,
                                  p_Dsb_Name              OUT VARCHAR2,
                                  p_Self_Checks           OUT SYS_REFCURSOR,
                                  p_Widgets               OUT SYS_REFCURSOR,
                                  p_Problems              OUT SYS_REFCURSOR,
                                  p_Time_Series_Cols      OUT SYS_REFCURSOR,
                                  p_Time_Series_Data      OUT SYS_REFCURSOR)
    IS
    BEGIN
        -- Check_Access;

        SELECT t.Dsb_Name
          INTO p_Dsb_Name
          FROM Uss_Ndi.v_Ndi_Ms_Dashboard t
         WHERE t.Dsb_Id = p_Dsb_Id;

        Get_Self_Checks (p_Self_Checks);
        Get_Widgets (p_Dsb_Id, p_Widgets);
        Get_Problems (p_Dsb_Id, p_Problems);
        Get_Time_Series (p_Dsb_Id,
                         p_Time_Series_Cols   => p_Time_Series_Cols,
                         p_Time_Series_Data   => p_Time_Series_Data);
    END;

    -------------------------------------------------------
    --  Підтвердження події користувачем
    -------------------------------------------------------
    PROCEDURE Acknowledge_Event (p_Evt_Id    IN NUMBER,
                                 p_Trg_Id    IN NUMBER,
                                 p_Message   IN VARCHAR2)
    IS
    BEGIN
        Api$monitoring.Acknowledge_Event (p_Evt_Id    => p_Evt_Id,
                                          p_Trg_Id    => p_Trg_Id,
                                          p_Message   => p_Message,
                                          p_Hs_Id     => Tools.Gethistsession);
    END;
END Dnet$monitoring;
/