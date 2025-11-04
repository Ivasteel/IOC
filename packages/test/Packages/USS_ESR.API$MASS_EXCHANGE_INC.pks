/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE_INC
IS
    -- Author  : KELATEV
    -- Created : 05.09.2024 15:25:27
    -- Purpose : Масове отримання доходів з ДПС та ПФУ #107929
    Pkg                    VARCHAR2 (100) := 'API$MASS_EXCHANGE_INC';

    --Me_St--V_DDN_ME_ST
    --E = Створено
    --E = Готовий до передачі
    --P = Передано в підсистему обміну
    --L = Отримано відповідь

    --Mirr_St = A/H - особи (запитувані дані)
    --Misr_St = A/H - доходи особи (відповідь)

    --V_DDN_MIRS_ST - запити та відповіді сервісів
    c_St_Mirs_Sent         Me_Income_Request_Src.Mirs_St%TYPE := 'P'; -- Передано в підсистему обміну
    c_St_Mirs_Received     Me_Income_Request_Src.Mirs_St%TYPE := 'K'; -- Отримано
    c_St_Mirs_Uncomplete   Me_Income_Request_Src.Mirs_St%TYPE := 'U'; -- Неповні/помилкові дані

    --V_DDN_MIRS_SRC_TP - джерела даних
    с_Mirs_Src_Tp_Dps     Me_Income_Request_Src.Mirs_Src_Tp%TYPE := 'DPS';
    с_Mirs_Src_Tp_Pfu     Me_Income_Request_Src.Mirs_Src_Tp%TYPE := 'PFU';


    PROCEDURE Prepare_Me_Rows (p_Me_Id IN Mass_Exchanges.Me_Id%TYPE);

    FUNCTION Parse_Pfu_Sum (p_Str IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Pfu_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Dps_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2);

    FUNCTION Parse_Dps_Start_Dt (p_Quarter IN VARCHAR2, p_Year IN VARCHAR2)
        RETURN DATE;

    FUNCTION Parse_Dps_Stop_Dt (p_Quarter IN VARCHAR2, p_Year IN VARCHAR2)
        RETURN DATE;

    PROCEDURE Handle_Dps_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    PROCEDURE Calc_Current_State (p_Me_Id IN NUMBER, p_Level IN NUMBER);
END Api$mass_Exchange_Inc;
/


GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_INC TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_INC TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_INC TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_INC TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_INC TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:07 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE_INC
IS
    g_Pt_Me_Id           CONSTANT NUMBER := 489;
    g_Pt_Rn_Id           CONSTANT NUMBER := 490;
    g_Pt_Res_Dt          CONSTANT NUMBER := 491;
    g_Debug_Pipe                  BOOLEAN := FALSE;

    g_Start_Time         CONSTANT VARCHAR2 (5) := '23:00';
    g_Stop_Time          CONSTANT VARCHAR2 (5) := '06:00';
    --ПФУ кожні 2 секунди, по 100 осіб за запит
    g_Pfu_Batch_Size     CONSTANT NUMBER := 100;
    g_Pfu_Delay_Second   CONSTANT NUMBER := 2;
    --ДФС кожні 10 секунди, по 70 запитів по одній особі в секунду
    g_Dfs_Batch_Size     CONSTANT NUMBER := 70;
    g_Dfs_Delay_Second   CONSTANT NUMBER := 10;

    TYPE t_Date_Arr IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;

    --=====================================================================
    --Пошук com_org особи, для Журнал можливих проблем з СРКО
    FUNCTION Get_Sc_Org (p_Sc_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        --Шукаємо організацію особи
        SELECT MAX (Com_Org)
          INTO l_Result
          FROM Uss_Esr.Personalcase
         WHERE Pc_Sc = p_Sc_Id;

        --Інакше відправляємо до ІОЦ
        l_Result := NVL (l_Result, 50001);

        RETURN l_Result;
    END;

    --=====================================================================
    --Прорахування всіх запусків по якомусь отримувачу
    FUNCTION Calc_Run_Request (p_Item_Cnt       IN NUMBER,
                               p_Batch_Size     IN NUMBER,
                               p_Start_Dt       IN DATE,
                               p_Start_Time     IN VARCHAR2,
                               p_Stop_Time      IN VARCHAR2,
                               p_Delay_Second   IN NUMBER)
        RETURN t_Date_Arr
    IS
        l_Result         t_Date_Arr;
        l_Start_Dt       DATE;
        l_Stop_Dt        DATE;
        l_Run_Per_Hour   NUMBER;
        l_Run_Norm       NUMBER; --кількість запусків у звичайний день (з 23:00 до 06:00)
        l_Run_D5         NUMBER; --кількість запусків у пятницю (з 20:00 до 00:00)
        l_Run_D6         NUMBER; --кількість запусків у суботу (з 00:00 до 00:00)
        l_Run_D7         NUMBER; --кількість запусків у неділю (з 00:00 неділі до 06:00 понеділка)
        l_Days           NUMBER; --кількість днів скільки займе процес за звичаних умов (без прискорення у вихідні)
        l_Batch_Cnt      NUMBER;                   --кількість партій (всього)
    BEGIN
        l_Start_Dt :=
            TO_DATE (TO_CHAR (p_Start_Dt, 'yyyymmdd') || p_Start_Time,
                     'yyyymmddhh24:mi');

        IF p_Start_Time > p_Stop_Time
        THEN
            l_Stop_Dt :=
                TO_DATE (TO_CHAR (p_Start_Dt + 1, 'yyyymmdd') || p_Stop_Time,
                         'yyyymmddhh24:mi');
        ELSE
            l_Stop_Dt :=
                TO_DATE (TO_CHAR (p_Start_Dt, 'yyyymmdd') || p_Stop_Time,
                         'yyyymmddhh24:mi');
        END IF;

        l_Run_Per_Hour := (60 / p_Delay_Second)      /*запусків за 1 хвилину*/
                                                * 60;   /*хвилин за 1 годину*/
        l_Run_Norm := l_Run_Per_Hour * ((l_Stop_Dt - l_Start_Dt) * 24);
        l_Run_D5 := l_Run_Per_Hour * 4;
        l_Run_D6 := l_Run_Per_Hour * 24;
        l_Run_D7 := l_Run_Per_Hour * ((l_Stop_Dt - TRUNC (l_Start_Dt)) * 24);
        l_Days := CEIL (p_Item_Cnt / (l_Run_Norm * p_Batch_Size));
        l_Batch_Cnt := CEIL (p_Item_Cnt / p_Batch_Size);

       <<outer>>
        FOR i IN 1 .. l_Days
        LOOP
            DECLARE
                l_Day           DATE;
                l_Day_Week      VARCHAR2 (1);
                l_Start_Time    VARCHAR2 (5);
                l_Run_Per_Day   NUMBER;
            BEGIN
                l_Day := TRUNC (p_Start_Dt) + i - 1;
                l_Day_Week := TO_CHAR (l_Day, 'd');
                l_Start_Time :=
                    CASE
                        WHEN    (l_Day_Week = '5' AND i < l_Days)
                             OR (l_Day_Week = '6' AND i = 1)
                        THEN
                            --у п'ятницю короткий день
                            --або роблять запуск у суботу
                            --якщо п'ятницю останній запланований день - ігноруємо, щоб працював у штатному режимі (23:00-06:00)
                            '20:00'
                        WHEN l_Day_Week = '6' AND i > 1
                        THEN
                            --у суботу працює весь день від початку дня
                            '00:00'
                        WHEN l_Day_Week = '7' AND i > 1
                        THEN
                            --у неділю працює весь день від початку дня
                            '00:00'
                        ELSE
                            --у інші дня працює за встановленім розкладом
                            p_Start_Time
                    END;
                l_Run_Per_Day :=
                    CASE
                        WHEN    (l_Day_Week = '5' AND i < l_Days)
                             OR (l_Day_Week = '6' AND i = 1)
                        THEN
                            --обробка невеликого шматка
                            --зазвичай в п'ятницю від 20:00 до 00:00, бо в суботу буде працювати увесь день
                            --якщо п'ятницю останній запланований день - ігноруємо, щоб працював у штатному режимі (23:00-06:00)
                            --якщо запуск стартують у суботу - 20:00-00:00, бо в неділю буде працювати увесь день
                            l_Run_D5
                        WHEN l_Day_Week = '6' AND i > 1
                        THEN
                            --у суботу працює увесь день - 00:00-24:00
                            l_Run_D6
                        WHEN l_Day_Week = '7' AND i > 1
                        THEN
                            --у неділю працює від 00:00 неділі до 06:00 понеділка
                            l_Run_D7
                        ELSE
                            l_Run_Norm
                    END;

                FOR j IN 1 .. l_Run_Per_Day
                LOOP
                    l_Result (l_Result.COUNT + 1) :=
                          TO_DATE (
                              TO_CHAR (l_Day, 'yyyymmdd') || l_Start_Time,
                              'yyyymmddhh24:mi')
                        + j / 24 / l_Run_Per_Hour;

                    EXIT OUTER WHEN l_Result.COUNT >= l_Batch_Cnt;
                END LOOP;
            END;
        END LOOP;

        RETURN l_Result;
    END;

    --=====================================================================
    --отримання інформації про останній запланований запит
    FUNCTION Get_Last_Plan_Request (p_Rn_Id IN NUMBER)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (r.Ur_Plan_Dt)
          INTO l_Result
          FROM Me_Income_Request_Src t, Ikis_Rbm.v_Uxp_Request r
         WHERE     (t.Mirs_Me, t.Mirs_Src_Tp) = (SELECT Mirs_Me, Mirs_Src_Tp
                                                   FROM Me_Income_Request_Src
                                                  WHERE Mirs_Rn = p_Rn_Id)
               AND r.Ur_Rn = t.Mirs_Rn;

        RETURN l_Result;
    END;

    --=====================================================================
    --Отримання кількість запланованих запусків на певну дату
    FUNCTION Get_Dfs_Count_Plan_Request (p_Date IN DATE)
        RETURN NUMBER
    IS
        l_Count   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Count
          FROM Ikis_Rbm.v_Uxp_Request r
         WHERE Ur_Plan_Dt = p_Date AND r.Ur_Urt = 116;

        RETURN l_Count;
    END;

    --=====================================================================
    --Прорахунок, куди можна перенести запуск
    FUNCTION Calc_Next_Run_Request (p_Last_Dt        IN DATE,
                                    p_Start_Time     IN VARCHAR2,
                                    p_Stop_Time      IN VARCHAR2,
                                    p_Delay_Second   IN NUMBER)
        RETURN DATE
    IS
    BEGIN
        --нічний запуск
        IF p_Start_Time > p_Stop_Time
        THEN
            --Якщо в поточному періоді є ще місце то додаємо в цей період
            IF    TO_CHAR (p_Last_Dt, 'hh24:mi') < p_Stop_Time
               OR TO_CHAR (p_Last_Dt, 'hh24:mi') >= p_Start_Time
            THEN
                RETURN p_Last_Dt + NUMTODSINTERVAL (p_Delay_Second, 'second');
            ELSE
                --в іншому випадку додаємо в новий період
                RETURN   TO_DATE (
                             TO_CHAR (p_Last_Dt, 'ddmmyyyy') || p_Start_Time,
                             'ddmmyyyyhh24:mi')
                       + NUMTODSINTERVAL (p_Delay_Second, 'second');
            END IF;
        ELSE
            --дневний запуск
            IF TO_CHAR (p_Last_Dt, 'hh24:mi') < p_Stop_Time
            THEN
                RETURN p_Last_Dt + NUMTODSINTERVAL (p_Delay_Second, 'second');
            ELSE
                RETURN   TO_DATE (
                                TO_CHAR (p_Last_Dt + 1, 'ddmmyyyy')
                             || p_Start_Time,
                             'ddmmyyyyhh24:mi')
                       + NUMTODSINTERVAL (p_Delay_Second, 'second');
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Створюємо повторний прорахунок, якщо небуло повної обробки, через 1 годину
    -----------------------------------------------------------------
    PROCEDURE Run_Calc_Current_State (p_Me_Id IN NUMBER, p_Level IN NUMBER)
    IS
        l_Me_Jb   NUMBER;
        l_Sql     VARCHAR2 (1000);
    BEGIN
        l_Sql :=
               'begin uss_esr.Api$mass_Exchange_Inc.Calc_Current_State('
            || p_Me_Id
            || ', '
            || p_Level
            || '); end;';
        Tools.Submitschedule (p_Jb         => l_Me_Jb,
                              p_Subsys     => 'USS_ESR',
                              p_Wjt        => 'ME_ROWS_PREPARE',
                              p_What       => l_Sql,
                              p_Nextdate   => SYSDATE + 1 / 24);
    END;

    -----------------------------------------------------------------
    -- процедура підготовки даних
    -----------------------------------------------------------------
    PROCEDURE Prepare_Me_Rows (p_Me_Id IN Mass_Exchanges.Me_Id%TYPE)
    IS
        l_Me_Month      Mass_Exchanges.Me_Month%TYPE;
        l_Me_Tp         Mass_Exchanges.Me_Tp%TYPE;
        l_Rc_Start_Dt   DATE;
        l_Roor_Dt       DATE;
        l_Start_Dt      DATE;
        l_Stop_Dt       DATE;
        l_Cnt           PLS_INTEGER;
        l_Hs            Histsession.Hs_Id%TYPE := Tools.Gethistsession;
    BEGIN
        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', START');
        END IF;

        SELECT TRUNC (Me_Month, 'MM'), Me_Tp
          INTO l_Me_Month, l_Me_Tp
          FROM Mass_Exchanges
         WHERE Me_Id = p_Me_Id;

        IF l_Me_Tp = 'INC2'
        THEN
            --знаходимо останній запуск Основного отримання доходу
            SELECT MAX (Hs.Hs_Dt)
              INTO l_Rc_Start_Dt
              FROM Mass_Exchanges Me, Uss_Esr.Histsession Hs
             WHERE     Me_Tp = 'INC'
                   AND TRUNC (Me_Month, 'MM') = l_Me_Month
                   AND Me.Me_Hs_Ins = Hs_Id;
        END IF;

        --якщо початкова дата буде відсутня то буде братися перерахунки за Rc_Month=l_Me_Month, створені в будь який час (навіть в попередньому місяці)

        l_Roor_Dt := TRUNC (ADD_MONTHS (l_Me_Month, -1), 'Q');
        l_Start_Dt := ADD_MONTHS (l_Roor_Dt, -3);
        l_Stop_Dt := l_Roor_Dt - 1;

        INSERT INTO Me_Income_Request_Rows (Mirr_Id,
                                            Mirr_Me,
                                            Mirr_Pd,
                                            Mirr_Sc,
                                            Mirr_Ip_Unique,
                                            Mirr_Ln,
                                            Mirr_Fn,
                                            Mirr_Mn,
                                            Mirr_Numident,
                                            Mirr_Doc_Tp,
                                            Mirr_Doc_Ser,
                                            Mirr_Doc_Num,
                                            Mirr_Birth_Dt,
                                            Mirr_Period_Start_Dt,
                                            Mirr_Period_Stop_Dt,
                                            Mirr_St)
            SELECT Mirr_Id,
                   p_Me_Id                 AS Mirr_Me,
                   Mirr_Pd,
                   Mirr_Sc,
                   Mirr_Ip_Unique,
                   Mirr_Ln,
                   Mirr_Fn,
                   Mirr_Mn,
                   Mirr_Numident,
                   Scd_Pass.Scd_Ndt        AS Mirr_Doc_Tp,
                   Scd_Pass.Scd_Seria      AS Mirr_Doc_Ser,
                   Scd_Pass.Scd_Number     AS Mirr_Doc_Num,
                   Mirr_Birth_Dt,
                   l_Start_Dt              AS Mirr_Period_Start_Dt,
                   l_Stop_Dt               AS Mirr_Period_Stop_Dt,
                   'E'                     AS Mirr_St
              FROM (  SELECT 0
                                 AS Mirr_Id,
                             Pd_Id
                                 AS Mirr_Pd,
                             Pdf_Sc
                                 AS Mirr_Sc,
                             NULL
                                 AS Mirr_Ip_Unique,
                             Sci.Sci_Ln
                                 AS Mirr_Ln,
                             Sci.Sci_Fn
                                 AS Mirr_Fn,
                             Sci.Sci_Mn
                                 AS Mirr_Mn,
                             (SELECT NVL2 (Scd_Ipn.Scd_Number,
                                           LPAD (Scd_Ipn.Scd_Number, 10, '0'),
                                           NULL)
                                FROM Uss_Person.v_Sc_Document Scd_Ipn
                               WHERE     Scd_Ipn.Scd_Sc = Sc.Sc_Id
                                     AND Scd_Ipn.Scd_Ndt = 5
                                     AND Scd_Ipn.Scd_St = '1')
                                 AS Mirr_Numident,
                             Pdf.Pdf_Birth_Dt
                                 AS Mirr_Birth_Dt,
                             (  SELECT Scd_Id
                                  FROM Uss_Person.v_Sc_Document
                                 WHERE     Scd_Ndt IN (6,
                                                       7,
                                                       8,
                                                       9)
                                       AND Scd_St = '1'
                                       AND Scd_Sc = Sc_Id
                              ORDER BY Scd_Ndt
                                 FETCH FIRST 1 ROW ONLY)
                                 x_Scd_Id,
                             ROW_NUMBER ()
                                 OVER (PARTITION BY Pd.Com_Org ORDER BY Pd_Id)
                                 AS Rn
                        FROM Uss_Esr.Pc_Decision      Pd,
                             Uss_Esr.Pd_Accrual_Period Pdap,
                             Uss_Esr.Pd_Family        Pdf,
                             Uss_Person.v_Socialcard  Sc,
                             Uss_Person.v_Sc_Change   Scc,
                             Uss_Person.v_Sc_Identity Sci
                       WHERE     Pd_St IN ('S', 'PS')
                             AND Pd.Pd_Nst = 664
                             AND Pdap_Pd = Pd_Id
                             AND Pdap.History_Status = 'A'
                             AND l_Me_Month BETWEEN TRUNC (Pdap.Pdap_Start_Dt,
                                                           'MM')
                                                AND Pdap.Pdap_Stop_Dt
                             AND Pdf.Pdf_Pd = Pd_Id
                             AND Pdf.History_Status = 'A'
                             AND l_Me_Month >= Pdf.Pdf_Start_Dt
                             AND (   l_Me_Month <= Pdf.Pdf_Stop_Dt
                                  OR Pdf.Pdf_Stop_Dt IS NULL)
                             AND EXISTS
                                     (SELECT 1
                                        FROM Uss_Esr.Pd_Payment Pdp,
                                             Uss_Esr.Pd_Detail Pdd
                                       WHERE     Pdp.Pdp_Pd = Pd_Id
                                             AND Pdp.History_Status = 'A'
                                             AND l_Me_Month BETWEEN TRUNC (
                                                                        Pdp.Pdp_Start_Dt,
                                                                        'MM')
                                                                AND Pdp.Pdp_Stop_Dt
                                             AND Pdd.Pdd_Pdp = Pdp.Pdp_Id
                                             AND l_Me_Month BETWEEN TRUNC (
                                                                        Pdd.Pdd_Start_Dt,
                                                                        'MM')
                                                                AND Pdd.Pdd_Stop_Dt
                                             AND Pdp_Rc IN
                                                     (SELECT Rc_Id
                                                        FROM Uss_Esr.Recalculates
                                                             Rc,
                                                             Uss_Esr.Histsession
                                                             Hs
                                                       WHERE     Rc_Tp =
                                                                 'S_VPO_13_6'
                                                             AND Rc_Month =
                                                                 l_Me_Month
                                                             AND Rc.Rc_Hs_Ins =
                                                                 Hs.Hs_Id
                                                             AND (   l_Rc_Start_Dt
                                                                         IS NULL
                                                                  OR Hs.Hs_Dt >=
                                                                     l_Rc_Start_Dt))
                                             AND Pdd_Ndp IN (290, 300)
                                             AND Pdd_Value > 0)
                             --
                             AND Sc.Sc_Id = Pdf_Sc
                             AND Scc.Scc_Id = Sc.Sc_Scc
                             AND Scc.Scc_Sci = Sci.Sci_Id
                    ORDER BY Rn),
                   Uss_Person.v_Sc_Document  Scd_Pass
             WHERE Scd_Pass.Scd_Id = x_Scd_Id;

        l_Cnt := SQL%ROWCOUNT;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', INSERTED: ' || l_Cnt);
        END IF;

        UPDATE Mass_Exchanges m
           SET m.Me_Count = l_Cnt, m.Me_St = Api$mass_Exchange.c_St_Me_Exists -- Створено
         WHERE Me_Id = p_Me_Id;

        Api$mass_Exchange.Write_Me_Log (
            p_Mel_Me        => p_Me_Id,
            p_Mel_Hs        => l_Hs,
            p_Mel_St        => Api$mass_Exchange.c_St_Me_Exists,
            p_Mel_Message   => 'Завершено формування пакету',
            p_Mel_St_Old    => Api$mass_Exchange.c_St_Me_Creating);

        UPDATE Mass_Exchanges
           SET Me_Count = l_Cnt, Me_St = Api$mass_Exchange.c_St_Me_Ready2send
         WHERE Me_Id = p_Me_Id;

        Api$mass_Exchange.Write_Me_Log (
            p_Mel_Me        => p_Me_Id,
            p_Mel_St        => Api$mass_Exchange.c_St_Me_Ready2send,
            p_Mel_Message   => 'Почато формування запитів обміну',
            p_Mel_St_Old    => Api$mass_Exchange.c_St_Me_Exists);

        DECLARE
            l_Pfu_Plan_Dt   t_Date_Arr;
            l_Dfs_Plan_Dt   t_Date_Arr;
        BEGIN
            --ПФУ кожні 2 секунди, по 100 осіб за запит
            l_Pfu_Plan_Dt :=
                Calc_Run_Request (p_Item_Cnt       => l_Cnt,
                                  p_Batch_Size     => g_Pfu_Batch_Size,
                                  p_Start_Dt       => SYSDATE,
                                  p_Start_Time     => g_Start_Time,
                                  p_Stop_Time      => g_Stop_Time,
                                  p_Delay_Second   => g_Pfu_Delay_Second);
            --ДФС кожні 10 секунди, по 70 запитів по одній особі в секунду
            l_Dfs_Plan_Dt :=
                Calc_Run_Request (p_Item_Cnt       => l_Cnt,
                                  p_Batch_Size     => g_Dfs_Batch_Size,
                                  p_Start_Dt       => SYSDATE,
                                  p_Start_Time     => g_Start_Time,
                                  p_Stop_Time      => g_Stop_Time,
                                  p_Delay_Second   => g_Dfs_Delay_Second);

            IF CEIL (l_Cnt / g_Pfu_Batch_Size) != l_Pfu_Plan_Dt.COUNT
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не правильно прорахован план для ПФЦ');
            END IF;

            IF CEIL (l_Cnt / g_Dfs_Batch_Size) != l_Dfs_Plan_Dt.COUNT
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не правильно прорахован план для ДПС');
            END IF;

            --PFU
            INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
                SELECT   -1
                       * CEIL (
                               ROW_NUMBER () OVER (ORDER BY Mirr_Id)
                             / g_Pfu_Batch_Size),
                       Mirr_Id
                  FROM Me_Income_Request_Rows
                 WHERE Mirr_Me = p_Me_Id;

            FOR i IN 1 .. l_Pfu_Plan_Dt.COUNT
            LOOP
                DECLARE
                    l_Rn_Id   NUMBER;
                BEGIN
                    Ikis_Rbm.Api$request_Pfu.Reg_Me_Incomes_Req (
                        p_Me_Id        => p_Me_Id,
                        p_Ur_Plan_Dt   => l_Pfu_Plan_Dt (i),
                        p_Ur_Ext_Id    => p_Me_Id,
                        p_Rn_Src       => 'USS',
                        p_Rn_Id        => l_Rn_Id);

                    UPDATE Tmp_Work_Set1
                       SET x_Id1 = l_Rn_Id
                     WHERE x_Id1 = -1 * i;
                END;
            END LOOP;

            INSERT INTO Me_Income_Request_Src (Mirs_Id,
                                               Mirs_Me,
                                               Mirs_Mirr,
                                               Mirs_Rn,
                                               Mirs_Src_Tp,
                                               Mirs_Answer_Code,
                                               Mirs_Answer_Text,
                                               Mirs_St)
                SELECT 0,
                       p_Me_Id,
                       x_Id2,
                       x_Id1,
                       с_Mirs_Src_Tp_Pfu,
                       NULL,
                       NULL,
                       'P'
                  FROM Tmp_Work_Set1;

            --DPS
            INSERT INTO Tmp_Work_Set2 (x_Id1, x_Id2, x_Id3)
                SELECT -1 * Group_i,
                       ROW_NUMBER ()
                           OVER (PARTITION BY Group_i ORDER BY Mirr_Id)
                           AS Group_j,
                       Mirr_Id
                  FROM (SELECT CEIL (
                                     ROW_NUMBER () OVER (ORDER BY Mirr_Id)
                                   / g_Dfs_Batch_Size)    AS Group_i,
                               Mirr_Id
                          FROM Me_Income_Request_Rows
                         WHERE Mirr_Me = p_Me_Id);

           <<outloop>>
            FOR i IN 1 .. l_Dfs_Plan_Dt.COUNT
            LOOP
                FOR j IN 1 .. g_Dfs_Batch_Size
                LOOP
                    DECLARE
                        l_Rn_Id        NUMBER;
                        l_Can_Insert   NUMBER;
                    BEGIN
                        SELECT COUNT (*)
                          INTO l_Can_Insert
                          FROM Tmp_Work_Set2
                         WHERE x_Id1 = -1 * i AND x_Id2 = j;

                        EXIT Outloop WHEN l_Can_Insert = 0;

                        Ikis_Rbm.Api$request_Dfs.Reg_Me_Income_Sources_Query_Req (
                            p_Me_Id        => p_Me_Id,
                            p_Ur_Plan_Dt   => l_Dfs_Plan_Dt (i),
                            p_Ur_Ext_Id    => p_Me_Id,
                            p_Rn_Src       => 'USS',
                            p_Rn_Id        => l_Rn_Id);

                        UPDATE Tmp_Work_Set2
                           SET x_Id1 = l_Rn_Id
                         WHERE x_Id1 = -1 * i AND x_Id2 = j;
                    END;
                END LOOP;
            END LOOP;

            INSERT INTO Me_Income_Request_Src (Mirs_Id,
                                               Mirs_Me,
                                               Mirs_Mirr,
                                               Mirs_Rn,
                                               Mirs_Src_Tp,
                                               Mirs_Answer_Code,
                                               Mirs_Answer_Text,
                                               Mirs_St)
                SELECT 0,
                       p_Me_Id,
                       x_Id3,
                       x_Id1,
                       с_Mirs_Src_Tp_Dps,
                       NULL,
                       NULL,
                       'P'
                  FROM Tmp_Work_Set2;
        END;

        UPDATE Mass_Exchanges
           SET Me_St = Api$mass_Exchange.c_St_Me_Sent
         WHERE Me_Id = p_Me_Id;

        Api$mass_Exchange.Write_Me_Log (
            p_Mel_Me        => p_Me_Id,
            p_Mel_St        => Api$mass_Exchange.c_St_Me_Sent,
            p_Mel_Message   => 'Завершено формування запитів обміну',
            p_Mel_St_Old    => Api$mass_Exchange.c_St_Me_Ready2send);

        --Створюємо прорахуно поточного стану обміну
        Run_Calc_Current_State (p_Me_Id => p_Me_Id, p_Level => 0);
    END;

    -----------------------------------------------------------------
    --Суми з ПФУ приходять у незвичному варіанті
    --123456 – це 1234,56 ГРН
    -----------------------------------------------------------------
    FUNCTION Parse_Pfu_Sum (p_Str IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF p_Str IS NULL
        THEN
            RETURN NULL;
        END IF;

        RETURN Tools.Tnumber (
                      SUBSTR (p_Str, 0, LENGTH (p_Str) - 2)
                   || '.'
                   || SUBSTR (p_Str, -2),
                   '9999999999D99',
                   '.');
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ПФУ для отриманян масових доходів
    -----------------------------------------------------------------
    PROCEDURE Handle_Pfu_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id             NUMBER;
        l_Me_Id             NUMBER;
        l_Common_Response   Ikis_Rbm.Api$request_Pfu.r_Common_Response;
        l_Hs                Histsession.Hs_Id%TYPE := Tools.Gethistsession;
        l_Src_Name          VARCHAR2 (200);
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            UPDATE Me_Income_Request_Src s
               SET Mirs_Answer_Code = NULL,
                   s.Mirs_Answer_Text = p_Error,
                   Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
             WHERE s.Mirs_Rn = l_Rn_Id;

            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        SELECT Dic_Name
          INTO l_Src_Name
          FROM Uss_Ndi.v_Ddn_Mirs_Src_Tp
         WHERE Dic_Value = с_Mirs_Src_Tp_Pfu;

        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        --отримуємо ідентифікатор масового обміну
        l_Me_Id :=
            Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id => p_Ur_Id);

        IF l_Me_Id IS NULL
        THEN
            UPDATE Me_Income_Request_Src s
               SET Mirs_Answer_Code = NULL,
                   s.Mirs_Answer_Text = 'Не вдалось визначити misr_me',
                   Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
             WHERE s.Mirs_Rn = l_Rn_Id;

            Raise_Application_Error (
                -20000,
                   'Не вдалось визначити misr_me для Rn_Id: '
                || TO_CHAR (l_Rn_Id));
        END IF;

        l_Common_Response :=
            Ikis_Rbm.Api$request_Pfu.Parse_Common_Response (
                p_Response   => p_Response);

        --В <EXTERNAL_ID> приходить Rn_Id
        FOR Res_Root
            IN (           SELECT Ext_Id,
                                  Tools.Tdate (Result_Date, 'ddmmyyyyhh24miss')
                                      Result_Date,
                                  Persons_Answer
                             FROM XMLTABLE (
                                      '//*'
                                      PASSING Xmltype (l_Common_Response.Response_Body)
                                      COLUMNS Ext_Id            NUMBER PATH 'EXTERNAL_ID',
                                              Result_Date       VARCHAR2 (20) PATH 'RESULT_DATE',
                                              Persons_Answer    XMLTYPE PATH 'PERSONS_ANSWER')
                            WHERE Ext_Id IS NOT NULL)
        LOOP
            --В <ID_ISSUE> приходить Mirs_Id
            FOR Res_Person
                IN (      SELECT Id_Issue,
                                 Answer,
                                 Decl_Numb,
                                 Payments
                            FROM XMLTABLE (
                                     '/*/*'
                                     PASSING Res_Root.Persons_Answer
                                     COLUMNS Id_Issue     NUMBER PATH 'ID_ISSUE',
                                             Answer       NUMBER PATH 'ANSWER',
                                             Decl_Numb    NUMBER PATH 'DECL_NUMB',
                                             Payments     XMLTYPE PATH 'PAYMENTS'))
            LOOP
                DECLARE
                    l_Mirr_Sc          Me_Income_Result_Rows.Misr_Sc%TYPE;
                    l_Mirr_Id          Me_Income_Result_Rows.Misr_Mirr%TYPE;
                    l_Answer_Message   VARCHAR2 (2000);
                BEGIN
                    SELECT Mirr_Sc, Mirs_Mirr
                      INTO l_Mirr_Sc, l_Mirr_Id
                      FROM Me_Income_Request_Src, Me_Income_Request_Rows
                     WHERE     Mirs_Me = l_Me_Id
                           AND Mirs_Id = Res_Person.Id_Issue
                           AND Mirr_Id = Mirs_Mirr
                           AND Mirr_Me = l_Me_Id;

                    IF Res_Person.Answer = 1
                    THEN
                        UPDATE Me_Income_Request_Src s
                           SET s.Mirs_Answer_Code = Res_Person.Answer,
                               s.Mirs_Answer_Text = CHR (38) || '308',
                               Mirs_St = Api$mass_Exchange.c_St_Memr_Received
                         WHERE     s.Mirs_Rn = l_Rn_Id
                               AND s.Mirs_Id = Res_Person.Id_Issue;
                    ELSE
                        l_Answer_Message :=
                               CHR (38)
                            || CASE Res_Person.Answer
                                   WHEN 2 THEN '309'
                                   WHEN 3 THEN '310'
                                   WHEN 4 THEN '311'
                                   ELSE '107'
                               END;

                        UPDATE Me_Income_Request_Src s
                           SET s.Mirs_Answer_Code = Res_Person.Answer,
                               s.Mirs_Answer_Text = l_Answer_Message,
                               Mirs_St =
                                   Api$mass_Exchange.c_St_Memr_Uncomplete
                         WHERE     s.Mirs_Rn = l_Rn_Id
                               AND s.Mirs_Id = Res_Person.Id_Issue;

                        DECLARE
                            l_Spp_Id             NUMBER;
                            l_Answer_Recommend   VARCHAR2 (200);
                        BEGIN
                            Uss_Person.Api$sc_Possible_Problems.Insert_Sc_Possible_Problems (
                                p_Spp_Id         => l_Spp_Id,
                                p_Spp_Sc         => l_Mirr_Sc,
                                p_Spp_Tp         => NULL,
                                p_Spp_Src_Info   =>
                                       CHR (38)
                                    || '313#'
                                    || l_Src_Name
                                    || '#'
                                    || Res_Person.Answer
                                    || '#'
                                    || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                           l_Answer_Message)
                                    || '#'
                                    || l_Answer_Recommend,
                                p_Spp_Init_Org   => Get_Sc_Org (l_Mirr_Sc));
                        END;
                    END IF;

                    IF Res_Person.Answer = 1
                    THEN
                        INSERT INTO Me_Income_Result_Rows (
                                        Misr_Id,
                                        Misr_Me,
                                        Misr_Mirr,
                                        Misr_Mirs,
                                        Misr_Sc,
                                        Misr_Pfu_Month,
                                        Misr_Pfu_Sum_Payment,
                                        Misr_Pfu_Symp_Type,
                                        Misr_Pfu_Soc_f_Kod,
                                        Misr_Pfu_Code_Insurer,
                                        Misr_Pfu_Pay_Insurer,
                                        Misr_Pfu_Pay_Insurer_Ozn,
                                        Misr_Pfu_Is_Pens,
                                        Misr_St,
                                        Misr_Pfu_Apri_Tp)
                                        SELECT 0,
                                               l_Me_Id,
                                               l_Mirr_Id,
                                               Res_Person.Id_Issue,
                                               l_Mirr_Sc,
                                               Tools.Tdate (Month_Income, 'ddmmyyyy')
                                                   AS Misr_Pfu_Month,
                                               Parse_Pfu_Sum (Sum_Payment)
                                                   AS Misr_Pfu_Sum_Payment,
                                               Symp_Type
                                                   AS Misr_Pfu_Symp_Type,
                                               Soc_f_Kod
                                                   AS Misr_Pfu_Soc_f_Kod,
                                               Code_Insurer
                                                   AS Misr_Pfu_Code_Insurer,
                                               DECODE (Pay_Insurer,
                                                       1, 'T',
                                                       0, 'F',
                                                       Pay_Insurer)
                                                   AS Misr_Pfu_Pay_Insurer,
                                               DECODE (Pay_Insurer_Ozn,
                                                       1, 'T',
                                                       0, 'F',
                                                       Pay_Insurer_Ozn)
                                                   AS Misr_Pfu_Pay_Insurer_Ozn,
                                               Is_Pens
                                                   AS Misr_Pfu_Is_Pens,
                                               'A'
                                                   AS Misr_St,
                                               (SELECT MAX (Nitc_Apri_Tp)
                                                  FROM Uss_Ndi.v_Ndi_Income_Tp_Config
                                                 WHERE     History_Status = 'A'
                                                       AND Nitc_Src = 'PFU'
                                                       AND Nitc_Exch_Tp = Symp_Type
                                                       AND Nitc_Api_Use_Tp IN ('V', 'VS'))
                                                   AS Misr_Pfu_Apri_Tp
                                          FROM XMLTABLE (
                                                   '/*/*'
                                                   PASSING Res_Person.Payments
                                                   COLUMNS Month_Income       VARCHAR2 (8) PATH 'MONTH',
                                                           Sum_Payment        VARCHAR2 (12) PATH 'SUM_PAYMENT',
                                                           Symp_Type          VARCHAR2 (10) PATH 'SYMP_TYPE',
                                                           Soc_f_Kod          VARCHAR2 (10) PATH 'SOC_F_KOD',
                                                           Code_Insurer       VARCHAR2 (10) PATH 'CODE_INSURER',
                                                           Pay_Insurer        VARCHAR2 (10) PATH 'PAY_INSURER',
                                                           Pay_Insurer_Ozn    VARCHAR2 (10) PATH 'PAY_INSURER_OZN',
                                                           Is_Pens            NUMBER PATH 'IS_PENS');
                    END IF;
                END;
            END LOOP;
        END LOOP;
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для отримання доходів
    --                 (ініціалізація розрахунку)
    -----------------------------------------------------------------
    PROCEDURE Handle_Dps_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2)
    IS
        c_Subreq_Nrt   CONSTANT NUMBER := 117; --тип підзапиту на отримання даних
        l_Rn_Id                 NUMBER;
        l_Repeat                VARCHAR2 (10);
        l_Subreq_Created        VARCHAR2 (10);
    BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NULL
        THEN
            Ikis_Rbm.Api$request_Dfs.Handle_Income_Sources_Query_Resp (
                p_Ur_Id            => p_Ur_Id,
                p_Response         => p_Response,
                p_Error            => p_Error,
                p_Repeat           => l_Repeat,
                p_Subreq_Created   => l_Subreq_Created,
                p_Subreq_Nrt       => c_Subreq_Nrt,
                p_Rn_Src           => 'USS');

            --в разі помилки змінюємо статус
            IF p_Error IS NOT NULL
            THEN
                UPDATE Me_Income_Request_Src s
                   SET Mirs_Answer_Code = NULL,
                       s.Mirs_Answer_Text = p_Error,
                       Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
                 WHERE s.Mirs_Rn = l_Rn_Id;
            END IF;

            IF l_Repeat = 'T'
            THEN
                DECLARE
                    l_Delay_Seconds   NUMBER := 300;
                    l_Last_Dt         DATE;
                    l_Last_Count      NUMBER;
                    l_New_Dt          DATE;
                BEGIN
                    --Якщо технічна помилка сталася на вихідний, в ДФС її зможуть полагодити лише у понеділок
                    --У вихідні відпрацьовується багато запитів, щоб не навантажувати понеділок - переносимо в кінець списку
                    IF TO_CHAR (SYSDATE, 'd') IN ('6', '7')
                    THEN
                        l_Last_Dt :=
                            Get_Last_Plan_Request (p_Rn_Id => l_Rn_Id);
                        l_Last_Count :=
                            Get_Dfs_Count_Plan_Request (l_Last_Dt);

                        IF l_Last_Count > 100
                        THEN
                            --В ДПС сказали що не можна робити більше 100 запитів в секунду, бо їх система ляже
                            l_New_Dt :=
                                Calc_Next_Run_Request (
                                    p_Last_Dt        => l_Last_Dt,
                                    p_Start_Time     => g_Start_Time,
                                    p_Stop_Time      => g_Stop_Time,
                                    p_Delay_Second   => g_Dfs_Delay_Second);
                        ELSE
                            l_New_Dt := l_Last_Dt;
                        END IF;

                        IF l_New_Dt < SYSDATE
                        THEN
                            l_New_Dt :=
                                SYSDATE + NUMTODSINTERVAL (300, 'second');
                        END IF;

                        l_Delay_Seconds :=
                            CEIL ((l_New_Dt - SYSDATE) * 24 * 60 * 60);
                    END IF;

                    Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                        p_Ur_Id           => p_Ur_Id,
                        p_Delay_Seconds   => l_Delay_Seconds,
                        p_Delay_Reason    => p_Error);
                END;
            END IF;
        ELSE
            UPDATE Me_Income_Request_Src s
               SET Mirs_Answer_Code = NULL,
                   s.Mirs_Answer_Text = p_Error,
                   Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
             WHERE s.Mirs_Rn = l_Rn_Id;

            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;
    END;

    FUNCTION Is_Number (p_String IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Num   NUMBER;
    BEGIN
        l_Num := TO_NUMBER (p_String);
        RETURN TRUE;
    EXCEPTION
        WHEN VALUE_ERROR
        THEN
            RETURN FALSE;
    END;

    FUNCTION Parse_Dps_Start_Dt (p_Quarter IN VARCHAR2, p_Year IN VARCHAR2)
        RETURN DATE
    IS
        l_Quarter   VARCHAR2 (1000) := TRIM (UPPER (p_Quarter));
    BEGIN
        IF NOT Is_Number (p_Year)
        THEN
            RETURN NULL;
        ELSIF    LENGTH (l_Quarter) = 0
              OR (    LENGTH (l_Quarter) > 0
                  AND NOT Is_Number (SUBSTR (l_Quarter, 1, 1)))
        THEN
            RETURN NULL;
        ELSIF LENGTH (l_Quarter) = 1
        THEN
            RETURN TO_DATE (
                          '01.'
                       || LPAD (
                              '' || ((0 + SUBSTR (l_Quarter, 1, 1)) * 3 - 2),
                              2,
                              '0')
                       || '.'
                       || LPAD (TRIM (p_Year), 4, '0'),
                       'DD.MM.YYYY');
        ELSE
            RETURN TO_DATE (
                          '01.'
                       || CASE SUBSTR (l_Quarter, 5)
                              WHEN 'СІЧЕНЬ' THEN '01'
                              WHEN 'ЛЮТИЙ' THEN '02'
                              WHEN 'БЕРЕЗЕНЬ' THEN '03'
                              WHEN 'КВІТЕНЬ' THEN '04'
                              WHEN 'ТРАВЕНЬ' THEN '05'
                              WHEN 'ЧЕРВЕНЬ' THEN '06'
                              WHEN 'ЛИПЕНЬ' THEN '07'
                              WHEN 'СЕРПЕНЬ' THEN '08'
                              WHEN 'ВЕРЕСЕНЬ' THEN '09'
                              WHEN 'ЖОВТЕНЬ' THEN '10'
                              WHEN 'ЛИСТОПАД' THEN '11'
                              WHEN 'ГРУДЕНЬ' THEN '12'
                          END
                       || '.'
                       || LPAD (p_Year, 4, '0'),
                       'DD.MM.YYYY');
        END IF;
    END;

    FUNCTION Parse_Dps_Stop_Dt (p_Quarter IN VARCHAR2, p_Year IN VARCHAR2)
        RETURN DATE
    IS
        l_Quarter   VARCHAR2 (1000) := TRIM (UPPER (p_Quarter));
    BEGIN
        IF NOT Is_Number (p_Year)
        THEN
            RETURN NULL;
        ELSIF    LENGTH (l_Quarter) = 0
              OR (    LENGTH (l_Quarter) > 0
                  AND NOT Is_Number (SUBSTR (l_Quarter, 1, 1)))
        THEN
            RETURN NULL;
        ELSIF LENGTH (l_Quarter) = 1
        THEN
            RETURN LAST_DAY (
                       TO_DATE (
                              '01.'
                           || LPAD (
                                  '' || ((0 + SUBSTR (l_Quarter, 1, 1)) * 3),
                                  2,
                                  '0')
                           || '.'
                           || LPAD (TRIM (p_Year), 4, '0'),
                           'DD.MM.YYYY'));
        ELSE
            RETURN LAST_DAY (
                       TO_DATE (
                              '01.'
                           || CASE SUBSTR (l_Quarter, 5)
                                  WHEN 'СІЧЕНЬ' THEN '01'
                                  WHEN 'ЛЮТИЙ' THEN '02'
                                  WHEN 'БЕРЕЗЕНЬ' THEN '03'
                                  WHEN 'КВІТЕНЬ' THEN '04'
                                  WHEN 'ТРАВЕНЬ' THEN '05'
                                  WHEN 'ЧЕРВЕНЬ' THEN '06'
                                  WHEN 'ЛИПЕНЬ' THEN '07'
                                  WHEN 'СЕРПЕНЬ' THEN '08'
                                  WHEN 'ВЕРЕСЕНЬ' THEN '09'
                                  WHEN 'ЖОВТЕНЬ' THEN '10'
                                  WHEN 'ЛИСТОПАД' THEN '11'
                                  WHEN 'ГРУДЕНЬ' THEN '12'
                              END
                           || '.'
                           || LPAD (p_Year, 4, '0'),
                           'DD.MM.YYYY'));
        END IF;
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для отримання доходів
    --                 (отримання відповіді)
    -----------------------------------------------------------------
    PROCEDURE Handle_Dps_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
        l_Ur_Root         NUMBER;
        l_Rn_Id           NUMBER;
        l_Me_Id           NUMBER;
        l_Res_Rn          NUMBER (14);
        l_Error_Message   VARCHAR2 (4000);

        l_Mirr_Sc         NUMBER;
        l_Mirs_Id         NUMBER;
        l_Mirr_Id         NUMBER;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            UPDATE Me_Income_Request_Src s
               SET Mirs_Answer_Code = NULL,
                   s.Mirs_Answer_Text = p_Error,
                   Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
             WHERE s.Mirs_Rn = l_Rn_Id;

            COMMIT;
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        --Отримуємо ІД кореневого запиту
        l_Ur_Root :=
            Ikis_Rbm.Api$uxp_Request.Get_Root_Request (p_Ur_Id => p_Ur_Id);
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => l_Ur_Root);

        --отримуємо ідентифікатор масового обміну
        l_Me_Id :=
            Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id => l_Ur_Root);

        IF l_Me_Id IS NULL
        THEN
            UPDATE Me_Income_Request_Src s
               SET Mirs_Answer_Code = NULL,
                   s.Mirs_Answer_Text = 'Не вдалось визначити misr_me',
                   Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
             WHERE s.Mirs_Rn = l_Rn_Id;

            Raise_Application_Error (
                -20000,
                   'Не вдалось визначити misr_me для Rn_Id: '
                || TO_CHAR (l_Rn_Id));
        END IF;

        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Res          NUMBER PATH 'Info/result',
                                         Rnokpp       VARCHAR2 (20) PATH 'Info/RNOKPP',
                                         Error        VARCHAR2 (10) PATH 'error',
                                         Error_Msg    VARCHAR2 (4000) PATH 'errorMsg',
                                         Sources      XMLTYPE PATH 'SourcesOfIncome'))
        LOOP
            IF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_Not_Found
            THEN
                --ТЕХНІЧНА ПОМИЛКА(НА БОЦІ ДФС)
                UPDATE Me_Income_Request_Src s
                   SET s.Mirs_Answer_Code = Rec.Error,
                       s.Mirs_Answer_Text = Rec.Error_Msg,
                       Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
                 WHERE s.Mirs_Rn = l_Rn_Id;

                RETURN;
            ELSIF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_In_Process
            THEN
                --ЗАПИТ В ОБРОБЦІ
                UPDATE Me_Income_Request_Src s
                   SET s.Mirs_Answer_Code = Rec.Error,
                       s.Mirs_Answer_Text = Rec.Error_Msg,
                       Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
                 WHERE s.Mirs_Rn = l_Rn_Id;

                --Включаємо запит знову в чергу - бо обробка в фоні автоматом виключає з черги
                DECLARE
                    l_Ur   Ikis_Rbm.v_Uxp_Request%ROWTYPE;
                BEGIN
                    l_Ur :=
                        Ikis_Rbm.Api$uxp_Request.Get_Request (
                            p_Ur_Id   => p_Ur_Id);

                    IF l_Ur.Ur_St = 'OK'
                    THEN
                        Ikis_Rbm.Api$uxp_Request.Repeat_Out_Request (
                            p_Ur_Id   => p_Ur_Id);
                    END IF;
                END;

                --Встановлюємо ознаку для сервіса, що запит необхідно надіслати повторно
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 30,
                    p_Delay_Reason    => Rec.Error_Msg);
            ELSIF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_Answer_Gived
            THEN
                --НА ЗАПИТ ВЖЕ НАДАНО ВІДПОВІДЬ
                UPDATE Me_Income_Request_Src s
                   SET s.Mirs_Answer_Code = Rec.Error,
                       s.Mirs_Answer_Text = Rec.Error_Msg,
                       Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
                 WHERE s.Mirs_Rn = l_Rn_Id;

                --Встановлюємо ознаку для сервіса, що батківський запит необхідно надіслати повторно
                Ikis_Rbm.Api$uxp_Request.Repeat_Out_Request (
                    p_Ur_Id   => l_Ur_Root);
                RETURN;
            END IF;

            SELECT Mirr_Sc, Mirs_Id, Mirs_Mirr
              INTO l_Mirr_Sc, l_Mirs_Id, l_Mirr_Id
              FROM Me_Income_Request_Rows, Me_Income_Request_Src
             WHERE     Mirr_Me = l_Me_Id
                   AND Mirr_Id = Mirs_Mirr
                   AND Mirs_Rn = l_Rn_Id --в ДПС Rn унікальний у кожної особи, бо в одному запиті - одна особа
                   AND Mirs_Me = l_Me_Id;

            IF NVL (Rec.Res, 4) = 4 AND Rec.Rnokpp IS NOT NULL
            THEN
                UPDATE Me_Income_Request_Src s
                   SET s.Mirs_Answer_Code = Rec.Res,
                       s.Mirs_Answer_Text =
                           CASE Rec.Res WHEN 4 THEN CHR (38) || '284' END,
                       Mirs_St =
                           CASE Rec.Res
                               WHEN 4
                               THEN
                                   Api$mass_Exchange.c_St_Memr_Uncomplete
                               ELSE
                                   Api$mass_Exchange.c_St_Memr_Received
                           END
                 WHERE s.Mirs_Rn = l_Rn_Id;

                FOR Rec_Income
                    IN (           SELECT *
                                     FROM XMLTABLE (
                                              '/*'
                                              PASSING Rec.Sources
                                              COLUMNS Income_Taxes      XMLTYPE PATH 'IncomeTaxes',
                                                      Tax_Agent         VARCHAR2 (1000) PATH 'TaxAgent',
                                                      Name_Tax_Agent    VARCHAR2 (250) PATH 'NameTaxAgent'))
                LOOP
                    INSERT INTO Me_Income_Result_Rows (
                                    Misr_Id,
                                    Misr_Me,
                                    Misr_Mirr,
                                    Misr_Mirs,
                                    Misr_Sc,
                                    Misr_St,
                                    Misr_Dfs_Income_Accrued,
                                    Misr_Dfs_Paid,
                                    Misr_Dfs_Tax_Charged,
                                    Misr_Dfs_Tax_Transferred,
                                    Misr_Dfs_Sign_Privilege,
                                    Misr_Dfs_Employment_Dt,
                                    Misr_Dfs_Dismissal_Dt,
                                    Misr_Dfs_Period_Quarter,
                                    Misr_Dfs_Period_Year,
                                    Misr_Dfs_Result_Income,
                                    Misr_Dfs_Tax_Agent,
                                    Misr_Dfs_Name_Tax_Agent,
                                    Misr_Dfs_Exch_Tp,
                                    Misr_Dfs_Apri_Tp,
                                    Misr_Dfs_Start_Dt,
                                    Misr_Dfs_Stop_Dt)
                                          SELECT 0,
                                                 l_Me_Id,
                                                 l_Mirr_Id,
                                                 l_Mirs_Id,
                                                 l_Mirr_Sc,
                                                 'A'
                                                     AS Misr_St,
                                                 Tools.Tnumber (Incomeaccrued,
                                                                '999999999999D99',
                                                                '.')
                                                     AS Misr_Dfs_Income_Accrued,
                                                 Tools.Tnumber (Incomepaid,
                                                                '999999999999D99',
                                                                '.')
                                                     AS Misr_Dfs_Paid,
                                                 Tools.Tnumber (Taxcharged,
                                                                '999999999999D99',
                                                                '.')
                                                     AS Misr_Dfs_Tax_Charged,
                                                 Tools.Tnumber (Taxtransferred,
                                                                '999999999999D99',
                                                                '.')
                                                     AS Misr_Dfs_Tax_Transferred,
                                                 Signofincomeprivilege
                                                     AS Misr_Dfs_Sign_Privilege,
                                                 Tools.Tdate (Dateofemployment, 'yyyy-mm-dd')
                                                     AS Misr_Dfs_Employment_Dt,
                                                 Tools.Tdate (Dateofdismissal, 'yyyy-mm-dd')
                                                     AS Misr_Dfs_Dismissal_Dt,
                                                 Period_Quarter
                                                     AS Misr_Dfs_Period_Quarter,
                                                 Period_Year
                                                     AS Misr_Dfs_Period_Year,
                                                 Result_Income
                                                     AS Misr_Dfs_Result_Income,
                                                 Rec_Income.Tax_Agent
                                                     AS Misr_Dfs_Tax_Agent,
                                                 Rec_Income.Name_Tax_Agent
                                                     AS Misr_Dfs_Name_Tax_Agent,
                                                 CASE SUBSTR (Signofincomeprivilege, 1, 3)
                                                     WHEN 'Пер'
                                                     THEN
                                                         'ФОП 1'
                                                     WHEN 'Дру'
                                                     THEN
                                                         'ФОП 2'
                                                     WHEN 'Тре'
                                                     THEN
                                                         'ФОП 3'
                                                     WHEN 'Чет'
                                                     THEN
                                                         'ФОП 4'
                                                     ELSE
                                                         TO_CHAR (
                                                             Tools.Tnumber (
                                                                 SUBSTR (Signofincomeprivilege,
                                                                         1,
                                                                         3)))
                                                 END
                                                     AS Misr_Dfs_Exch_Tp,
                                                 (SELECT MAX (Nitc_Apri_Tp)
                                                    FROM Uss_Ndi.v_Ndi_Income_Tp_Config
                                                   WHERE     History_Status = 'A'
                                                         AND Nitc_Src = 'DPS'
                                                         AND Nitc_Exch_Tp =
                                                             SUBSTR (Signofincomeprivilege,
                                                                     1,
                                                                     3)
                                                         AND Nitc_Api_Use_Tp IN ('V', 'VS'))
                                                     AS Misr_Dfs_Apri_Tp,
                                                 Parse_Dps_Start_Dt (
                                                     p_Quarter   => Period_Quarter,
                                                     p_Year      => Period_Year)
                                                     AS Misr_Dfs_Start_Dt,
                                                 Parse_Dps_Stop_Dt (
                                                     p_Quarter   => Period_Quarter,
                                                     p_Year      => Period_Year)
                                                     AS Misr_Dfs_Stop_Dt
                                            FROM XMLTABLE (
                                                     '/*'
                                                     PASSING Rec_Income.Income_Taxes
                                                     COLUMNS Incomeaccrued            VARCHAR2 (20) PATH 'IncomeAccrued',
                                                             Incomepaid               VARCHAR2 (20) PATH 'IncomePaid',
                                                             Taxcharged               VARCHAR2 (20) PATH 'TaxCharged',
                                                             Taxtransferred           VARCHAR2 (20) PATH 'TaxTransferred',
                                                             Signofincomeprivilege    VARCHAR2 (100) PATH 'SignOfIncomePrivilege',
                                                             Dateofemployment         VARCHAR2 (12) PATH 'DateOfEmployment',
                                                             Dateofdismissal          VARCHAR2 (12) PATH 'DateOFDismissal',
                                                             Period_Quarter           VARCHAR2 (20) PATH 'period_quarter',
                                                             Period_Year              VARCHAR2 (10) PATH 'period_year',
                                                             Result_Income            VARCHAR2 (10) PATH 'result_income');
                END LOOP;
            ELSE
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                l_Error_Message :=
                       CHR (38)
                    || CASE Rec.Res
                           WHEN 5 THEN '98'
                           WHEN 6 THEN '99'
                           WHEN 7 THEN '100'
                           WHEN 8 THEN '101'
                           WHEN 9 THEN '102'
                           WHEN 10 THEN '103'
                           WHEN 11 THEN '104'
                           WHEN 12 THEN '105'
                           WHEN 13 THEN '106'
                           ELSE '107'
                       END;

                UPDATE Me_Income_Request_Src s
                   SET s.Mirs_Answer_Code = Rec.Res,
                       s.Mirs_Answer_Text = l_Error_Message,
                       Mirs_St = Api$mass_Exchange.c_St_Memr_Uncomplete
                 WHERE s.Mirs_Rn = l_Rn_Id;

                DECLARE
                    l_Spp_Id             NUMBER;
                    l_Src_Name           VARCHAR2 (200);
                    l_Answer_Recommend   VARCHAR2 (200);
                BEGIN
                    SELECT Dic_Name
                      INTO l_Src_Name
                      FROM Uss_Ndi.v_Ddn_Mirs_Src_Tp
                     WHERE Dic_Value = с_Mirs_Src_Tp_Pfu;

                    Uss_Person.Api$sc_Possible_Problems.Insert_Sc_Possible_Problems (
                        p_Spp_Id         => l_Spp_Id,
                        p_Spp_Sc         => l_Mirr_Sc,
                        p_Spp_Tp         => NULL,
                        p_Spp_Src_Info   =>
                               CHR (38)
                            || '313#'
                            || l_Src_Name
                            || '#'
                            || Rec.Res
                            || '#'
                            || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                   l_Error_Message)
                            || '#'
                            || l_Answer_Recommend,
                        p_Spp_Init_Org   => Get_Sc_Org (l_Mirr_Sc));
                END;
            END IF;
        END LOOP;

        l_Res_Rn := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        -- зберігаємо Me_Id в журнал відповіді щоб полегшити відладку
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => l_Res_Rn,
                                                  p_Rnc_Pt        => g_Pt_Me_Id,
                                                  p_Rnc_Val_Int   => l_Me_Id);
        --в журнал запиту зберігаємо дату і Ід відповіді
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => l_Rn_Id,
                                                  p_Rnc_Pt       => g_Pt_Res_Dt,
                                                  p_Rnc_Val_Dt   => SYSDATE);
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => l_Rn_Id,
                                                  p_Rnc_Pt        => g_Pt_Rn_Id,
                                                  p_Rnc_Val_Int   => l_Res_Rn);
    END;

    -----------------------------------------------------------------
    -- Прорахунок поточного стану обміну та оновлення статусу
    -----------------------------------------------------------------
    PROCEDURE Calc_Current_State (p_Me_Id IN NUMBER, p_Level IN NUMBER)
    IS
        l_Prev_St      Mass_Exchanges.Me_St%TYPE;
        l_New_St       Mass_Exchanges.Me_St%TYPE;
        l_Create_Dt    DATE;
        l_Req_Total    NUMBER;
        l_Req_Loaded   NUMBER;
    BEGIN
        --Міксимальний час рекурсивної функції 14 днів, кожну годину (орієнтовно 340 запусків)
        IF p_Level > 1000
        THEN
            RETURN;
        END IF;

        SELECT Me_St, Me_St, h.Hs_Dt
          INTO l_Prev_St, l_New_St, l_Create_Dt
          FROM Mass_Exchanges m, Histsession h
         WHERE Me_Id = p_Me_Id AND h.Hs_Id = m.Me_Hs_Ins;

        --Якщо обмін працює більше двух неділь, автоматично рахуємо його виконаним
        IF l_Create_Dt < SYSDATE - 14
        THEN
            UPDATE Mass_Exchanges
               SET Me_St = Api$mass_Exchange.c_St_Me_Loaded
             WHERE Me_Id = p_Me_Id;

            RETURN;
        END IF;

        SELECT COUNT (*), COUNT (DECODE (Mirs_St, 'P', NULL, 1))
          INTO l_Req_Total, l_Req_Loaded
          FROM Me_Income_Request_Src t
         WHERE t.Mirs_Me = p_Me_Id;

        IF l_Req_Total = l_Req_Loaded
        THEN
            UPDATE Mass_Exchanges
               SET Me_St = Api$mass_Exchange.c_St_Me_Loaded
             WHERE Me_Id = p_Me_Id;

            RETURN;
        END IF;

        --Створюємо повторний прорахунок, через 1 годину
        Run_Calc_Current_State (p_Me_Id => p_Me_Id, p_Level => p_Level + 1);
    END;
END Api$mass_Exchange_Inc;
/