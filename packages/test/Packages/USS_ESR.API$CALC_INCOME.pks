/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$CALC_INCOME
IS
    gLogSesID   VARCHAR2 (50);

    -- Author  : OLEKSII
    -- Created : 22.10.2021 10:09:32
    -- Purpose :
    TYPE Record_Calc_Result IS RECORD
    (
        fact_sum     NUMBER,
        calc_koef    NUMBER,
        calc_sum     NUMBER,
        LogTrue      VARCHAR2 (2000),
        LogFalse     VARCHAR2 (2000)
    );

    TYPE Table_Calc_Result IS TABLE OF Record_Calc_Result;

    /*
      Type Type_Rec_Anketa_Z is Record
        (
        pd_id     number(14),
        app_id    number(14),
        app_tp    varchar2(20),
        FamilyConnect       varchar2(20),   --Ступінь родинного зв’язку
        Adopter             varchar2(20),   --Усиновлювач
        Guardian            varchar2(20),   --опікун
        Trustee             varchar2(20),   --піклувальник
        Еducator            varchar2(20),   --Вихователь
        Alone               varchar2(20),   --Одинокий/Одинока
        Widow               varchar2(20),   --Вдова/Вдовець
        NotSalary           varchar2(20),   --Перебуває у відпустці без збереження заробітної плати
        Disability          varchar2(20),   --Особа з інвалідністю
        DisabilityFromChild varchar2(20),   --Особа з інвалідністю з дитинства
        DisabilityGroup     varchar2(20),   --Група інвалідності
        DisabilityReason    varchar2(20),   --причина інвалідності
        CarriedPayments     varchar2(20),   --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
        Workable            varchar2(20),   --Працездатний
        NotWorkable         varchar2(20),   --Не працездатний
        NotWorking          varchar2(20),   --Не працює
        Studying            varchar2(20),   --Навчається
        Military            varchar2(20),   --Проходить військову службу
        CaringChildUnder3   varchar2(20),   --Доглядає за дитиною до 3-х років
        CaringChildUnder6   varchar2(20),   --Доглядає за дитиною до 6-х років
        MaternityLeave      varchar2(20),   --Перебуває у відпустці у зв’язку з вагітністю та пологами
        StudyingForm        varchar2(20),   --форма навчання
        BirthDay            DATE            --День народження
        );
      type Table_Anketa_Z  is table of Type_Rec_Anketa_Z;
      g_Anketa_Z  Table_Anketa_Z := Table_Anketa_Z();

      PROCEDURE Set_Anketa;
      Function Get_Anketa return Table_Anketa_Z PIPELINED;
      */

    FUNCTION ToDate (p_val VARCHAR2)
        RETURN DATE;

    FUNCTION ToNumber (p_val VARCHAR2)
        RETURN NUMBER;

    FUNCTION Calc03124 (P_SUM_PFU   NUMBER,
                        P_SUM_DPS   NUMBER,
                        P_SUM_APR   NUMBER,
                        P_SUM_DOV   NUMBER,
                        P_SUM_HND   NUMBER)
        RETURN NUMBER;

    FUNCTION Calc00231 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER;

    --=======================================--
    --  Розрахунок розрахункового доходу згідно правил по рядку.
    --  Відразу формується лог.
    --=======================================--
    FUNCTION Calc (P_NST         NUMBER,
                   P_TP          VARCHAR2,
                   P_EXCH_TP     VARCHAR2,
                   P_SUM_PFU     NUMBER,
                   P_SUM_DPS     NUMBER,
                   P_SUM_APR     NUMBER,
                   P_SUM_DOV     NUMBER,
                   P_SUM_HND     NUMBER,
                   P_SUM_EISSS   NUMBER,
                   P_MIN_ZP      NUMBER,
                   P_TICS_BD     NUMBER,
                   p_us_tp       VARCHAR2)
        RETURN Table_Calc_Result
        PIPELINED;


    FUNCTION CheckApp (p_pd       NUMBER,
                       p_app_sc   NUMBER,
                       p_tp       VARCHAR2,
                       p_nst      NUMBER)
        RETURN NUMBER;

    FUNCTION GetCheckAddressAppId (p_at IN NUMBER)
        RETURN NUMBER;

    FUNCTION CheckApp_at (p_at NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER;

    PROCEDURE calc_income_for_pd (p_mode              INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id             pc_decision.pd_id%TYPE,
                                  Is_Alt_period       INTEGER DEFAULT 0, --1 = працюємо по V_NDI_NST_INCOME_CONFIG.nic_1month_alg_alt, інакше = V_NDI_NST_INCOME_CONFIG.nic_1month_alg
                                  p_messages      OUT SYS_REFCURSOR);

    --=======================================--
    --  Розрахунок доходу для акту
    --=======================================--
    PROCEDURE calc_income_for_at (p_mode           INTEGER, --1=з p_at_id, 2=з таблиці tmp_work_ids
                                  p_at_id          act.at_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR);

    PROCEDURE Cleat_At_Income_Calc (p_At_Id IN NUMBER);

    PROCEDURE Test (id NUMBER, alt_period NUMBER);

    PROCEDURE Test_at (id NUMBER);
END API$Calc_Income;
/


/* Formatted on 8/12/2025 5:48:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$CALC_INCOME
IS
    /*
    v_ddn_apri_t
    v_ddn_api_use_tp
    NDI_INCOME_TP_CONFIG
    */

    g_messages   TOOLS.t_messages := TOOLS.t_messages ();

    --=======================================--
    --
    --=======================================--
    PROCEDURE LOG (p_pid NUMBER, p_message VARCHAR2)
    IS
    BEGIN
        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
             VALUES (0, p_pid, '' || CHR (38));
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION ToDate (p_val VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (p_val, 'yyyy-mm-dd');
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION ToNumber (p_val VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (p_val, '999999999.99');
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --=======================================--
    --
    --=======================================--
    PROCEDURE GetLogStr (Masc            NUMBER,
                         str         OUT VARCHAR,
                         strFalse    OUT VARCHAR,
                         P_SUM_PFU       NUMBER,
                         P_SUM_DPS       NUMBER,
                         P_SUM_APR       NUMBER,
                         P_SUM_DOV       NUMBER,
                         P_SUM_HND       NUMBER)
    IS
    BEGIN
        IF BITAND (Masc, 16) != 0 AND P_SUM_PFU IS NOT NULL
        THEN
            str :=
                   str
                || ', '
                || 'ПФУ '
                || TO_CHAR (P_SUM_PFU, 'FM999999990.90');
        ELSIF BITAND (Masc, 16) = 0 AND P_SUM_PFU IS NOT NULL
        THEN
            strFalse :=
                   strFalse
                || ', '
                || 'ПФУ '
                || TO_CHAR (P_SUM_PFU, 'FM999999990.90');
        END IF;

        IF BITAND (Masc, 8) != 0 AND P_SUM_DPS IS NOT NULL
        THEN
            str :=
                   str
                || ', '
                || 'ДПС '
                || TO_CHAR (P_SUM_DPS, 'FM999999990.90');
        ELSIF BITAND (Masc, 8) = 0 AND P_SUM_DPS IS NOT NULL
        THEN
            strFalse :=
                   strFalse
                || ', '
                || 'ДПС '
                || TO_CHAR (P_SUM_DPS, 'FM999999990.90');
        END IF;

        IF BITAND (Masc, 4) != 0 AND P_SUM_APR IS NOT NULL
        THEN
            str :=
                   str
                || ', '
                || 'Декларація '
                || TO_CHAR (P_SUM_APR, 'FM999999990.90');
        ELSIF BITAND (Masc, 4) = 0 AND P_SUM_APR IS NOT NULL
        THEN
            strFalse :=
                   strFalse
                || ', '
                || 'Декларація '
                || TO_CHAR (P_SUM_APR, 'FM999999990.90');
        END IF;

        IF BITAND (Masc, 2) != 0 AND P_SUM_DOV IS NOT NULL
        THEN
            str :=
                   str
                || ', '
                || 'Довідка '
                || TO_CHAR (P_SUM_DOV, 'FM999999990.90');
        ELSIF BITAND (Masc, 2) = 0 AND P_SUM_DOV IS NOT NULL
        THEN
            strFalse :=
                   strFalse
                || ', '
                || 'Довідка '
                || TO_CHAR (P_SUM_DOV, 'FM999999990.90');
        END IF;

        IF BITAND (Masc, 1) != 0 AND P_SUM_HND IS NOT NULL
        THEN
            str :=
                   str
                || ', '
                || 'Ручний '
                || TO_CHAR (P_SUM_HND, 'FM999999990.90');
        ELSIF BITAND (Masc, 1) = 0 AND P_SUM_HND IS NOT NULL
        THEN
            strFalse :=
                   strFalse
                || ', '
                || 'Ручний '
                || TO_CHAR (P_SUM_HND, 'FM999999990.90');
        END IF;

        str := LTRIM (str, ', ');
        strFalse := LTRIM (strFalse, ', ');
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION CalcNDI (P_SUM_PFU       NUMBER,
                      P_SUM_DPS       NUMBER,
                      P_SUM_APR       NUMBER,
                      P_SUM_DOV       NUMBER,
                      P_SUM_HND       NUMBER,
                      str         OUT VARCHAR2,
                      strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_PFU IS NOT NULL OR P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_PFU, 0) + NVL (P_SUM_DPS, 0);
                GetLogStr (16 + 8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        RETURN calc_sum;
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION Calc11230 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_PFU IS NOT NULL OR P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_PFU, 0) + NVL (P_SUM_DPS, 0);
                GetLogStr (16 + 8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01230 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := P_SUM_DPS;
                GetLogStr (8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01231 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DPS IS NOT NULL OR P_SUM_HND IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_DPS, 0) + NVL (P_SUM_HND, 0);
                GetLogStr (8 + 1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        /*
            if P_SUM_DPS is not null or P_SUM_HND is not null Then
               calc_sum := nvl(P_SUM_DPS,0) + nvl(P_SUM_HND,0);
            else
               calc_sum := coalesce(P_SUM_APR,P_SUM_DOV,0);
            end if;
        */
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00231 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_HND, 0);
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc03120 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := P_SUM_DPS;
                GetLogStr (8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --return coalesce(P_SUM_APR, P_SUM_DOV,P_SUM_DPS,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc03124 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    -- 16 8 4 2 1
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := P_SUM_DPS;
                GetLogStr (8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --return coalesce(P_SUM_APR, P_SUM_DOV,P_SUM_DPS,0);
        RETURN calc_sum;
    END;

    FUNCTION Calc03124 (P_SUM_PFU   NUMBER,
                        P_SUM_DPS   NUMBER,
                        P_SUM_APR   NUMBER,
                        P_SUM_DOV   NUMBER,
                        P_SUM_HND   NUMBER)
        RETURN NUMBER
    IS
        str        VARCHAR2 (200);
        strFalse   VARCHAR2 (200);
    BEGIN
        RETURN Calc03124 (P_SUM_PFU,
                          P_SUM_DPS,
                          P_SUM_APR,
                          P_SUM_DOV,
                          P_SUM_HND,
                          str,
                          strFalse);
    END;

    --=======================================--
    FUNCTION Calc00000 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        GetLogStr (0,
                   str,
                   strFalse,
                   P_SUM_PFU,
                   P_SUM_DPS,
                   P_SUM_APR,
                   P_SUM_DOV,
                   P_SUM_HND);
        RETURN 0;
    END;

    --=======================================--
    FUNCTION Calc00120 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --  return coalesce(P_SUM_APR, P_SUM_DOV,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01110 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN    P_SUM_DPS IS NOT NULL
                 OR NVL (P_SUM_APR, 0) != 0
                 OR P_SUM_DOV IS NOT NULL
            THEN
                calc_sum :=
                      NVL (P_SUM_DPS, 0)
                    + NVL (P_SUM_APR, 0)
                    + NVL (P_SUM_DOV, 0);
                GetLogStr (8 + 4 + 2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return nvl(P_SUM_DPS,0) + nvl(P_SUM_APR,0) + nvl(P_SUM_DOV,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01100 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DPS IS NOT NULL OR NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := NVL (P_SUM_DPS, 0) + NVL (P_SUM_APR, 0);
                GetLogStr (8 + 4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return nvl(P_SUM_DPS,0) + nvl(P_SUM_APR,0) + nvl(P_SUM_DOV,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00123 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_APR, P_SUM_DOV,P_SUM_HND,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00102 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_APR, P_SUM_HND,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00100 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_APR, 0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc10234 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_PFU IS NOT NULL
            THEN
                calc_sum := P_SUM_PFU;
                GetLogStr (16,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_PFU, P_SUM_APR, P_SUM_DOV, P_SUM_HND, 0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01000 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := P_SUM_DPS;
                GetLogStr (8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_DPS, 0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc10230 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_PFU IS NOT NULL
            THEN
                calc_sum := P_SUM_PFU;
                GetLogStr (16,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;   --    return coalesce(P_SUM_PFU, P_SUM_APR, P_SUM_DOV, 0);

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc10020 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_PFU IS NOT NULL
            THEN
                calc_sum := P_SUM_PFU;
                GetLogStr (16,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;   --    return coalesce(P_SUM_PFU, P_SUM_APR, P_SUM_DOV, 0);

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00010 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;   --    return coalesce(P_SUM_PFU, P_SUM_APR, P_SUM_DOV, 0);

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00011 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DOV IS NOT NULL OR P_SUM_HND IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_DOV, 0) + NVL (P_SUM_HND, 0);
                GetLogStr (2 + 1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;   --    return coalesce(P_SUM_PFU, P_SUM_APR, P_SUM_DOV, 0);

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc00001 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        --    return coalesce(P_SUM_APR, P_SUM_HND,0);
        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc01342 (P_SUM_PFU       NUMBER,
                        P_SUM_DPS       NUMBER,
                        P_SUM_APR       NUMBER,
                        P_SUM_DOV       NUMBER,
                        P_SUM_HND       NUMBER,
                        str         OUT VARCHAR2,
                        strFalse    OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_DPS IS NOT NULL
            THEN
                calc_sum := NVL (P_SUM_DPS, 0);
                GetLogStr (8,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_HND IS NOT NULL
            THEN
                calc_sum := P_SUM_HND;
                GetLogStr (1,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN NVL (P_SUM_APR, 0) != 0
            THEN
                calc_sum := P_SUM_APR;
                GetLogStr (4,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            WHEN P_SUM_DOV IS NOT NULL
            THEN
                calc_sum := P_SUM_DOV;
                GetLogStr (2,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
            ELSE
                calc_sum := 0;
                GetLogStr (0,
                           str,
                           strFalse,
                           P_SUM_PFU,
                           P_SUM_DPS,
                           P_SUM_APR,
                           P_SUM_DOV,
                           P_SUM_HND);
        END CASE;

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc_EISSS (P_SUM_EISSS       NUMBER,
                         str           OUT VARCHAR2,
                         strFalse      OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        CASE
            WHEN P_SUM_EISSS IS NOT NULL
            THEN
                calc_sum := P_SUM_EISSS;
                str :=
                       str
                    || ', '
                    || 'ЕІССС '
                    || TO_CHAR (P_SUM_EISSS, 'FM999999990.90');
            ELSE
                calc_sum := 0;
                strFalse :=
                       strFalse
                    || ', '
                    || 'ЕІССС '
                    || TO_CHAR (P_SUM_EISSS, 'FM999999990.90');
        END CASE;

        str := LTRIM (str, ', ');
        strFalse := LTRIM (strFalse, ', ');

        RETURN calc_sum;
    END;

    --=======================================--
    FUNCTION Calc_EISSS_ (P_SUM_EISSS       NUMBER,
                          str           OUT VARCHAR2,
                          strFalse      OUT VARCHAR2)
        RETURN NUMBER
    IS
        calc_sum   NUMBER;
    BEGIN
        calc_sum := 0;
        strFalse :=
               strFalse
            || ', '
            || 'ЕІССС '
            || TO_CHAR (P_SUM_EISSS, 'FM999999990.90');

        str := LTRIM (str, ', ');
        strFalse := LTRIM (strFalse, ', ');

        RETURN calc_sum;
    END;

    --=======================================--
    --
    --=======================================--
    /*Function CalcFact( P_TP         varchar2,
             P_SUM_PFU    number,
             P_SUM_DPS    number,
             P_SUM_APR    number,
             P_SUM_DOV    number,
             P_SUM_HND    number,
             P_MIN_ZP     number
                                            ) return number is
      calc_sum     number;
    Begin
      Case
      when P_TP =  '1' Then
           calc_sum := Calc11230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '2' Then
           calc_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND) * 0.3;
      when P_TP =  '3' Then
           calc_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '4' Then
           calc_sum := Calc03120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '5' Then
           calc_sum := Calc00000(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '6' Then
           calc_sum := Calc01231(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '7' Then
           calc_sum := Calc00120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '8' Then
           calc_sum := Calc01110(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP =  '9' Then
           calc_sum := Calc00123(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '11' Then
           calc_sum := Calc00120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '12' Then
           calc_sum := Calc00120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '13' Then
           calc_sum := Calc00000(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '14' Then
           calc_sum := Calc00123(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '15' Then
           calc_sum := P_MIN_ZP * CalcKoef( P_TP );
      when P_TP = '16' Then
           calc_sum := P_MIN_ZP * CalcKoef( P_TP );
      when P_TP = '17' Then
           calc_sum := P_MIN_ZP * CalcKoef( P_TP );
      when P_TP = '18' Then
           calc_sum := 0;--Calc00100(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '19' Then
           calc_sum := Calc00102(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '20' Then
           calc_sum := Calc00100(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '21' Then
           calc_sum := Calc10234(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '22' Then
           calc_sum := Calc01000(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '23' Then
           calc_sum := Calc10230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '24' Then
           calc_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '25' Then
           calc_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '26' Then
           calc_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '27' Then
           calc_sum := Calc00000(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      when P_TP = '28' Then
           calc_sum := 0;--Calc00120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND);
      else
           null;
      end case;
      return calc_sum;
    End;*/
    --=======================================--
    --
    --=======================================--
    FUNCTION Calc_267 (P_TP           VARCHAR2,
                       P_SUM_PFU      NUMBER,
                       P_SUM_DPS      NUMBER,
                       P_SUM_APR      NUMBER,
                       P_SUM_DOV      NUMBER,
                       P_SUM_HND      NUMBER,
                       P_SUM_EISSS    NUMBER,
                       P_MIN_ZP       NUMBER,
                       P_TICS_BD      NUMBER,
                       P_us_tp_koef   NUMBER)
        RETURN Record_Calc_Result
    IS
        l_Calc_Result   Record_Calc_Result;
    BEGIN
        CASE
            WHEN P_TP = '1'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc11230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '2'
            THEN
                l_Calc_Result.calc_koef := 0.3;
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                      l_Calc_Result.fact_sum
                    * l_Calc_Result.calc_koef
                    * P_us_tp_koef;
            WHEN P_TP = '3'
            THEN
                --#75268 20222.02.03
                --l_Calc_Result.fact_sum := Calc01230(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND, l_Calc_Result.LogTrue, l_Calc_Result.LogFalse);
                l_Calc_Result.fact_sum :=
                    Calc01342 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '4'
            THEN
                --l_Calc_Result.fact_sum := Calc03120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND, l_Calc_Result.LogTrue, l_Calc_Result.LogFalse);
                --dbms_output_put_lines('P_SUM_HND = '||P_SUM_HND);
                l_Calc_Result.fact_sum :=
                    Calc03124 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '5'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '6'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00231 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '7'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00120 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '8'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01110 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '9'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '11'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00120 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '12'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00120 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '13'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '14'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '15'
            THEN
                l_Calc_Result.calc_koef := 1;
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    P_MIN_ZP * l_Calc_Result.calc_koef * P_us_tp_koef;
                l_Calc_Result.LogTrue :=
                       'Мін ЗП '
                    || TO_CHAR (P_MIN_ZP, 'FM999999990.90')
                    || ' '
                    || l_Calc_Result.LogTrue;
                l_Calc_Result.LogFalse := NULL;
            WHEN P_TP = '16'
            THEN
                l_Calc_Result.calc_koef := 2;
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    P_MIN_ZP * l_Calc_Result.calc_koef * P_us_tp_koef;
                l_Calc_Result.LogTrue :=
                       'Мін ЗП '
                    || TO_CHAR (P_MIN_ZP, 'FM999999990.90')
                    || ' '
                    || l_Calc_Result.LogTrue;
                l_Calc_Result.LogFalse := NULL;
            WHEN P_TP = '17'
            THEN
                l_Calc_Result.calc_koef := 3;
                l_Calc_Result.calc_sum :=
                    P_MIN_ZP * l_Calc_Result.calc_koef * P_us_tp_koef;
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.LogTrue :=
                       'Мін ЗП '
                    || TO_CHAR (P_MIN_ZP, 'FM999999990.90')
                    || ' '
                    || l_Calc_Result.LogTrue;
                l_Calc_Result.LogFalse := NULL;
            WHEN P_TP = '18'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00100 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := 0;
            WHEN P_TP = '19'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '20'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00100 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '21'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc10234 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '22'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '23'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc10230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '24'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '25'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '26'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);

                CASE P_TICS_BD
                    WHEN 1
                    THEN
                        l_Calc_Result.calc_sum := 0;
                    ELSE
                        l_Calc_Result.calc_sum :=
                            l_Calc_Result.fact_sum * P_us_tp_koef;
                END CASE;
            WHEN P_TP = '27'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '28'
            THEN
                --l_Calc_Result.fact_sum := Calc00120(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND, l_Calc_Result.LogTrue, l_Calc_Result.LogFalse);
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := 0;
            WHEN P_TP = '36'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00001 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := 0;
            WHEN P_TP = '37'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP IN ('38',
                          '39',                                      /*'40',*/
                          '41',
                          '42',
                          '43',
                          '44',
                          '45',
                          '46',
                          '47',
                          '48',
                          '49',
                          '50',
                          '51',
                          '52',
                          '53',
                          '54',
                          '55')
            THEN
                l_Calc_Result.fact_sum :=
                    Calc_EISSS (P_SUM_EISSS,
                                l_Calc_Result.LogTrue,
                                l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP IN ('40',
                          '56',
                          '57',
                          '58',
                          '59',
                          '60',
                          '61',
                          '61')
            THEN
                l_Calc_Result.fact_sum :=
                    Calc_EISSS_ (P_SUM_EISSS,
                                 l_Calc_Result.LogTrue,
                                 l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := 0;
            ELSE
                NULL;
        END CASE;

        RETURN l_Calc_Result;
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION Calc_268 (P_TP           VARCHAR2,
                       P_SUM_PFU      NUMBER,
                       P_SUM_DPS      NUMBER,
                       P_SUM_APR      NUMBER,
                       P_SUM_DOV      NUMBER,
                       P_SUM_HND      NUMBER,
                       P_MIN_ZP       NUMBER,
                       P_us_tp_koef   NUMBER)
        RETURN Record_Calc_Result
    IS
        l_Calc_Result   Record_Calc_Result;
    BEGIN
        CASE
            WHEN P_TP IN ('2',
                          '3',
                          '7',
                          '8',
                          '9',
                          '10',
                          '11',
                          '12',
                          '13',
                          '14',
                          '15',
                          '16',
                          '17',
                          '18',
                          '19',
                          '20',
                          '21',
                          '22',
                          '23',
                          '24',
                          '25',
                          '26',
                          '27')
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '1'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc10020 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '4'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00010 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '5'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00010 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '6'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00011 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            WHEN P_TP = '28'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00010 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := 0;
            WHEN P_TP = '37'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum :=
                    l_Calc_Result.fact_sum * P_us_tp_koef;
            ELSE
                NULL;
        END CASE;

        RETURN l_Calc_Result;
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION Calc_4xx (P_TP        VARCHAR2,
                       P_SUM_PFU   NUMBER,
                       P_SUM_DPS   NUMBER,
                       P_SUM_APR   NUMBER,
                       P_SUM_DOV   NUMBER,
                       P_SUM_HND   NUMBER,
                       P_MIN_ZP    NUMBER)
        RETURN Record_Calc_Result
    IS
        l_Calc_Result   Record_Calc_Result;
    BEGIN
        CASE
            WHEN P_TP = '1'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc11230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '2'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '3'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '4'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '6'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01231 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '7'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '8'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01100 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '9'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '10'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00001 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '11'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00120 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '12'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00120 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            --    when P_TP = '13' Then
            --         l_Calc_Result.fact_sum := Calc00000(P_SUM_PFU, P_SUM_DPS, P_SUM_APR, P_SUM_DOV, P_SUM_HND, l_Calc_Result.LogTrue, l_Calc_Result.LogFalse);
            --         l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '14'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00123 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '15'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '16'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '17'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '19'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00102 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '20'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc00100 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '21'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc10234 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '22'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '23'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc10230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '24'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '26'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01230 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '29'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '30'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '31'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '32'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '33'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            WHEN P_TP = '35'
            THEN
                l_Calc_Result.fact_sum :=
                    Calc01000 (P_SUM_PFU,
                               P_SUM_DPS,
                               P_SUM_APR,
                               P_SUM_DOV,
                               P_SUM_HND,
                               l_Calc_Result.LogTrue,
                               l_Calc_Result.LogFalse);
                l_Calc_Result.calc_sum := l_Calc_Result.fact_sum;
            ELSE
                NULL;
        END CASE;

        RETURN l_Calc_Result;
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION Calc (P_NST         NUMBER,
                   P_TP          VARCHAR2,
                   P_EXCH_TP     VARCHAR2,
                   P_SUM_PFU     NUMBER,
                   P_SUM_DPS     NUMBER,
                   P_SUM_APR     NUMBER,
                   P_SUM_DOV     NUMBER,
                   P_SUM_HND     NUMBER,
                   P_SUM_EISSS   NUMBER,
                   P_MIN_ZP      NUMBER,
                   P_TICS_BD     NUMBER,
                   p_us_tp       VARCHAR2)
        RETURN Table_Calc_Result
        PIPELINED
    IS
        l_Calc_Result   Record_Calc_Result;
        L_us_tp_koef    NUMBER;
    BEGIN
        /*
        STO= (100%) враховується 100%
        PNS= (0%) Пенсія, щодо осіб, які не включено в склад сім'ї
        WRK= (50%) працевлаштування
        SLL= (0%) кошти, від продажу єдиного житла у разі купівлі іншого

        У зазначеному стовпці користувачу буде надано можливість обрати одну із особливостей врахування доходів, а саме:
        №1. Пенсія, щодо осіб, які не включено в склад сім'ї - для такої особливості враховувати 0% від доходу, в рядку якого обранно особливість
        №2. Працевлаштування - для такої особливості враховувати 50% від доходу, навпроти якого обранно особливість
        №3. Кошти, від продажу, що єдиного житла у разі купівлі іншого - для такої особливості враховувати 0% від доходу, в рядку якого обранно особливість

        Особливість №1 застосовується лише для доходів з DIC_CODE=1 в V_DDN_APRI_TP
        Особливість №2 застосовується лише для доходів з DIC_CODE=або 3, або 15, або 16, або 17, або 22, або 26 а в V_DDN_APRI_TP
        Особливість №3 застосовується лише для доходів з DIC_CODE=8, у якого код доходу від ДПС 104 (чи 104 треба ще уточнити)

        */
        --dbms_output.put_line('p_us_tp = '||p_us_tp);
        --dbms_output.put_line('P_TP = '||P_TP);
        --dbms_output.put_line('P_NST = '||P_NST);
        L_us_tp_koef :=
            CASE
                WHEN p_us_tp = 'PNS' AND P_TP = '1'
                THEN
                    0
                WHEN     p_us_tp = 'WRK'
                     AND P_TP IN ('3',
                                  '15',
                                  '16',
                                  '17',
                                  '22',
                                  '26')
                THEN
                    0.5
                WHEN p_us_tp = 'SLL' AND P_EXCH_TP = '104'
                THEN
                    0
                WHEN p_us_tp = 'NOT_TP_42'
                THEN
                    0
                ELSE
                    1
            END;

        --dbms_output.put_line('L_us_tp_koef = '||L_us_tp_koef);
        /*
        tics_exch_tp
        */
        CASE
            WHEN P_NST IN (664)
            THEN
                l_Calc_Result :=
                    Calc_267 (P_TP,
                              P_SUM_PFU,
                              P_SUM_DPS,
                              P_SUM_APR,
                              P_SUM_DOV,
                              P_SUM_HND,
                              P_SUM_EISSS,
                              P_MIN_ZP,
                              P_TICS_BD,
                              L_us_tp_koef);
            WHEN P_NST IN (267, 249)
            THEN
                l_Calc_Result :=
                    Calc_267 (P_TP,
                              P_SUM_PFU,
                              P_SUM_DPS,
                              P_SUM_APR,
                              P_SUM_DOV,
                              P_SUM_HND,
                              P_SUM_EISSS,
                              P_MIN_ZP,
                              P_TICS_BD,
                              L_us_tp_koef);
            WHEN P_NST IN (268, 275)
            THEN
                l_Calc_Result :=
                    Calc_268 (P_TP,
                              P_SUM_PFU,
                              P_SUM_DPS,
                              P_SUM_APR,
                              P_SUM_DOV,
                              P_SUM_HND,
                              P_MIN_ZP,
                              L_us_tp_koef);
            WHEN P_NST BETWEEN 400 AND 499
            THEN
                l_Calc_Result :=
                    Calc_4xx (P_TP,
                              P_SUM_PFU,
                              P_SUM_DPS,
                              P_SUM_APR,
                              P_SUM_DOV,
                              P_SUM_HND,
                              P_MIN_ZP);
            ELSE
                NULL;
        END CASE;

        l_Calc_Result.calc_koef := L_us_tp_koef;

        --dbms_output.put_line('l_Calc_Result = ['||l_Calc_Result.fact_sum||', '||l_Calc_Result.calc_koef||', '||l_Calc_Result.calc_sum||']');
        PIPE ROW (l_Calc_Result);
    END;

    --=======================================--
    --
    --=======================================--
    FUNCTION CheckApp267 (p_pd NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER
    IS
        ret   NUMBER := 0;
    BEGIN
        IF p_tp IN ('Z', 'FP')
        THEN
            ret := 1;
        ELSIF p_tp IN ('FM')
        THEN
            WITH
                age
                AS
                    (SELECT calc_dt,
                            FamilyConnect,
                            Disability,
                            DisabilityGroup,
                            DisabilityReason,
                            NVL (
                                TRUNC (
                                    MONTHS_BETWEEN (SYSDATE, birthday) / 12,
                                    0),
                                -1)    age_year
                       FROM TABLE (api$anketa.Get_Anketa)
                      WHERE     app_tp = 'FM'
                            AND app_sc = p_app_sc
                            AND pd_id = p_pd)
            SELECT 1
              INTO ret
              FROM age age
             WHERE    age.FamilyConnect = 'HW'
                   OR age.FamilyConnect = 'OTHER'
                   OR (    age.age_year BETWEEN 0 AND 18
                       AND age.FamilyConnect IN ('B', 'UB')) --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB') --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                       AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                           p_app_sc,
                                                           98,
                                                           690,
                                                           calc_dt,
                                                           'O') IN ('D', 'U') --якщо є довідка про навчання та форма навчання=денна або дуальна
                                                                             )
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB')
                       AND age.Disability = 'T'       --«особа з інвалідністю»
                       AND age.DisabilityGroup = '1' --666  Група інвалідності
                                                    )
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB')
                       AND age.Disability = 'T'       --«особа з інвалідністю»
                       AND age.DisabilityGroup = '2' --666  Група інвалідності
                       AND age.DisabilityReason = 'ID' --причина інвалідності= «Інвалідність з дитинства»
                                                      )
                   OR (    age.FamilyConnect IN ('PILM', 'PILF', 'P') --«Батько/мати» або «Свекор/свекруха» або «Тесть/теща»
                       AND API$ACCOUNT.get_docx_string (p_pd,
                                                        p_app_sc,
                                                        605,
                                                        663,
                                                        calc_dt,
                                                        '-') = 'T' --Не працює
                       AND API$ACCOUNT.get_docx_string (p_pd,
                                                        p_app_sc,
                                                        605,
                                                        665,
                                                        calc_dt,
                                                        '-') = 'T' --Не працездатний
                                                                  );
        ELSE
            ret := 0;
        END IF;

        RETURN ret;
    END;

    --=======================================--
    FUNCTION CheckApp249 (p_pd NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER
    IS
        ret   NUMBER := 0;
    BEGIN
        IF p_tp IN ('Z')
        THEN
            ret := 1;
        ELSIF p_tp IN ('FM')
        THEN
            WITH
                age
                AS
                    (SELECT calc_dt,
                            FamilyConnect,
                            Disability,
                            DisabilityGroup,
                            DisabilityReason,
                            NVL (
                                TRUNC (
                                    MONTHS_BETWEEN (SYSDATE, birthday) / 12,
                                    0),
                                -1)    age_year
                       FROM TABLE (api$anketa.Get_Anketa)
                      WHERE     app_tp = 'FM'
                            AND app_sc = p_app_sc
                            AND pd_id = p_pd)
            SELECT 1
              INTO ret
              FROM age
             WHERE    age.FamilyConnect = 'HW'
                   OR age.FamilyConnect = 'OTHER'
                   OR (    age.age_year BETWEEN 0 AND 18
                       AND age.FamilyConnect IN ('B', 'UB'))
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB') --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                       AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                           p_app_sc,
                                                           98,
                                                           690,
                                                           calc_dt,
                                                           'O') IN ('D', 'U') --якщо є довідка про навчання та форма навчання=денна або дуальна
                                                                             )
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB')
                       AND age.Disability = 'T'       --«особа з інвалідністю»
                       AND age.DisabilityGroup = '1' --666  Група інвалідності
                                                    )
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB')
                       AND age.Disability = 'T'       --«особа з інвалідністю»
                       AND age.DisabilityGroup = '2' --666  Група інвалідності
                       AND age.DisabilityReason = 'ID' --причина інвалідності= «Інвалідність з дитинства»
                                                      )
                   OR (    age.FamilyConnect IN ('PILM', 'PILF', 'P') --«Батько/мати» або «Свекор/свекруха» або «Тесть/теща»
                       AND API$ACCOUNT.get_docx_string (p_pd,
                                                        p_app_sc,
                                                        605,
                                                        663,
                                                        calc_dt,
                                                        '-') = 'T' --Не працює
                       AND API$ACCOUNT.get_docx_string (p_pd,
                                                        p_app_sc,
                                                        605,
                                                        665,
                                                        calc_dt,
                                                        '-') = 'T' --Не працездатний
                                                                  );
        ELSIF p_tp IN ('FP')
        THEN
            WITH
                age
                AS
                    (SELECT calc_dt,
                            FamilyConnect,
                            Disability,
                            DisabilityGroup,
                            DisabilityReason,
                            NVL (
                                TRUNC (
                                    MONTHS_BETWEEN (SYSDATE, birthday) / 12,
                                    0),
                                -1)    age_year
                       FROM TABLE (api$anketa.Get_Anketa)
                      WHERE     app_tp = 'FP'
                            AND app_sc = p_app_sc
                            AND pd_id = p_pd)
            SELECT 1
              INTO ret
              FROM age
             WHERE    (    age.age_year BETWEEN 0 AND 18
                       AND age.FamilyConnect IN ('B', 'UB'))
                   OR (    age.age_year > 18
                       AND age.FamilyConnect IN ('B', 'UB') --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                       AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                           p_app_sc,
                                                           98,
                                                           690,
                                                           calc_dt,
                                                           'O') IN ('D', 'U') --якщо є довідка про навчання та форма навчання=денна або дуальна
                                                                             );
        ELSE
            ret := 0;
        END IF;

        RETURN ret;
    END;

    --=======================================--
    FUNCTION CheckApp268 (p_pd NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER
    IS
        ret   NUMBER := 0;
    BEGIN
        IF p_tp IN ('FP')
        THEN
            ret := 1;
        ELSE
            ret := 0;
        END IF;

        RETURN ret;
    END;

    --=======================================--
    FUNCTION CheckApp4xx (p_pd NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER
    IS
        ret   NUMBER := 0;
    BEGIN
        WITH
            age
            AS
                (SELECT FamilyConnect,
                        Disability,
                        DisabilityGroup,
                        DisabilityReason,
                        AgeYear,
                        calc_dt
                   --nvl(trunc(months_between (sysdate, birthday )/12,0),-1) age_year
                   FROM TABLE (api$anketa.Get_Anketa)
                  WHERE                                   /*app_tp='FM'  and*/
                        app_sc = p_app_sc AND pd_id = p_pd)
        SELECT CASE
                   WHEN     p_tp IN ('Z')
                        AND API$CALC_RIGHT.get_docx_list_cnt (p_pd,
                                                              p_app_sc,
                                                              '801,836',
                                                              age.calc_dt) >
                            0
                   THEN
                       1
                   WHEN     p_tp IN ('OS')
                        AND API$CALC_RIGHT.get_docx_list_cnt (p_pd,
                                                              p_app_sc,
                                                              '801,802,836',
                                                              age.calc_dt) >
                            0
                   THEN
                       1
                   WHEN     p_tp IN ('FM')
                        AND (   age.FamilyConnect = 'HW' -- Особа має ступінь родинного зв’язку nda_id = 649 «Дружина/чоловік»
                             OR -- Особа має вік < 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7 і
                                -- ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                                (    age.AgeYear BETWEEN 0 AND 18
                                 AND age.FamilyConnect IN ('B', 'UB'))
                             OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                                -- якщо є «Довідка про навчання» ndt_id = 98 та форма навчання nda_id in (690) = «Денна» або «Дуальна» і
                                -- ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                                (    age.AgeYear > 18
                                 AND age.FamilyConnect IN ('B', 'UB') --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                                 AND API$CALC_RIGHT.get_docx_string (
                                         p_pd,
                                         p_app_sc,
                                         98,
                                         690,
                                         calc_dt,
                                         'O') IN ('D', 'U') --якщо є довідка про навчання та форма навчання=денна або дуальна
                                                           )
                             OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                                -- зазначено «особа з інвалідністю» 1 групи і ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                                (    age.AgeYear > 18
                                 AND age.FamilyConnect IN ('B', 'UB')
                                 AND age.Disability = 'T' --«особа з інвалідністю»
                                 AND age.DisabilityGroup = '1' --666  Група інвалідності
                                                              )
                             OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                                -- зазначено «особа з інвалідністю» 2 групи та «Інвалідність з дитинства» і ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                                (    age.AgeYear > 18
                                 AND age.FamilyConnect IN ('B', 'UB')
                                 AND age.Disability = 'T' --«особа з інвалідністю»
                                 AND age.DisabilityGroup = '2' --666  Група інвалідності
                                 AND age.DisabilityReason = 'ID' --причина інвалідності= «Інвалідність з дитинства»
                                                                )
                             OR -- Особа має ступінь родинного зв’язку nda_id = 649 «Батько/мати» або «Свекор/свекруха» або «Тесть/теща» і
                                -- ознака роботи (зайнятості) «Працює» = «Ні»
                                (    age.FamilyConnect IN
                                         ('PILM', 'PILF', 'P') --«Батько/мати» або «Свекор/свекруха» або «Тесть/теща»
                                 AND API$ACCOUNT.get_docx_string (p_pd,
                                                                  p_app_sc,
                                                                  605,
                                                                  663,
                                                                  calc_dt,
                                                                  '-') = 'T' --Не працює
                                                                            ))
                   THEN
                       1
                   WHEN p_tp IN ('FP')
                   THEN
                       1
                   ELSE
                       0
               END
          INTO ret
          FROM age;

        IF ret = 1
        THEN
            SELECT CASE
                       WHEN NotWorkable = 'T' OR MainTenance = 'T' THEN 0
                       ELSE 1
                   END
              INTO ret
              FROM TABLE (api$anketa.Get_Anketa)
             WHERE app_sc = p_app_sc AND pd_id = p_pd;
        END IF;

        RETURN ret;
    END;

    --=======================================--
    FUNCTION GetCheckAddressAppId (p_at IN NUMBER)
        RETURN NUMBER
    IS
        l_ap_id           NUMBER;
        l_ServiceNeeded   VARCHAR2 (100);
        l_ServiceTo       VARCHAR2 (100);
        l_res             NUMBER;
    BEGIN
        SELECT at_ap
          INTO l_ap_id
          FROM act
         WHERE at_id = p_at;

        l_ServiceNeeded := API$APPEAL.Get_Ap_Attr_Str (l_ap_id, 1868);
        l_ServiceTo := API$APPEAL.Get_Ap_Attr_Str (l_ap_id, 1895);

        IF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'Z'
        THEN
            SELECT MAX (app_id)
              INTO l_res
              FROM TABLE (api$anketa.Get_Anketa_AT) age
             WHERE at_id = p_at AND app_tp = 'Z';
        ELSIF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'B'
        THEN
            SELECT MAX (app_id)
              INTO l_res
              FROM TABLE (api$anketa.Get_Anketa_AT) age
             WHERE at_id = p_at AND app_tp = 'Z';
        ELSIF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'CHRG'
        THEN
            SELECT MAX (app_id)
              INTO l_res
              FROM TABLE (api$anketa.Get_Anketa_AT) age
             WHERE at_id = p_at AND app_tp = 'OS';
        ELSIF l_ServiceNeeded = 'FM' AND l_ServiceTo = 'FM'
        THEN
            BEGIN
                SELECT app_id
                  INTO l_res
                  FROM (  SELECT app_id
                            FROM TABLE (api$anketa.Get_Anketa_AT) age
                           WHERE at_id = p_at AND app_tp IN ('Z', 'AF')
                        ORDER BY CASE
                                     WHEN app_tp = 'Z' THEN 1
                                     WHEN app_tp = 'AF' THEN 2
                                 END)
                 WHERE ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        END IF;

        RETURN l_res;
    END;

    FUNCTION CheckApp_at (p_at NUMBER, p_app_sc NUMBER, p_tp VARCHAR2)
        RETURN NUMBER
    IS
        ret                         NUMBER := 0;
        l_App_Address_Id            NUMBER;
        l_Is_Person_Address_Equal   NUMBER;
    BEGIN
        l_App_Address_Id := GetCheckAddressAppId (p_at);

        FOR age IN (SELECT age.*,
                           p_tp                                              AS atp_tp,
                           API$APPEAL.Get_Attr_801_ChkQty (age.AT_AP,
                                                           age.APP_SRC,
                                                           age.ServiceNeeded,
                                                           age.ServiceTo)    isAttr801
                      FROM TABLE (api$anketa.Get_Anketa_AT) age
                     WHERE app_sc = p_app_sc AND at_id = p_at)
        LOOP
            IF     age.app_tp IN ('Z')
               AND (   API$APPEAL.get_doc_list_cnt (age.app_id, '836') > 0
                    OR --#102180 3)
                       (    age.MainInitNdt = 801
                        AND age.ap_tp IN ('SS')
                        AND age.ServiceNeeded = 'FM'
                        AND age.ServiceTo = 'FM')
                    OR --#102180 2)
                       (    age.MainInitNdt = 801
                        AND age.ap_tp IN ('SS')
                        AND age.ServiceNeeded = 'Z'
                        AND age.ServiceTo = 'B'
                        AND (age.AgeYear_os < 18 OR age.disability_os = 'T'))
                    OR --#102180  1)
                       (    age.MainInitNdt = 801
                        AND age.ap_tp IN ('SS')
                        AND age.ServiceNeeded = 'Z'
                        AND age.ServiceTo = 'Z'))
            THEN
                ret := 1;
            ELSIF     age.app_tp IN ('OS')
                  AND (   API$APPEAL.Get_ap_doc_list_cnt (age.at_ap,
                                                          '802,836') >
                          0
                       OR --#102180  2)
                          (    age.MainInitNdt = 801
                           AND age.ap_tp IN ('SS')
                           AND age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'B'
                           AND (   age.AgeYear_os < 18
                                OR age.disability_os = 'T'))
                       OR --#102180  3)
                          (    age.MainInitNdt = 801
                           AND age.ap_tp IN ('SS')
                           AND age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'CHRG'))
            THEN
                ret := 1;
            ELSIF     age.app_tp IN ('OR')
                  AND (   API$APPEAL.Get_ap_doc_list_cnt (age.at_ap,
                                                          '802,836') >
                          0
                       OR --#102180  3)
                          (    age.MainInitNdt = 801
                           AND age.ap_tp IN ('SS')
                           AND age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'CHRG'))
            THEN
                ret := 1;
            ELSIF age.app_tp IN ('FM')
            THEN
                IF age.MainInitNdt = 801 AND age.ap_tp IN ('SS')
                THEN
                    l_Is_Person_Address_Equal :=
                        API$APPEAL.Is_Person_Address_Equal (l_App_Address_Id,
                                                            age.APP_ID);

                    IF    (                                       --#102180 1)
                               age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'Z'
                           AND l_Is_Person_Address_Equal > 0)
                       OR --#102180 2)
                          (    age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'B'
                           AND l_Is_Person_Address_Equal > 0)
                       OR --#102180 3)
                          (    age.ServiceNeeded = 'Z'
                           AND age.ServiceTo = 'CHRG'
                           AND l_Is_Person_Address_Equal > 0)
                       OR --#102180 4)
                          (    age.ServiceNeeded = 'FM'
                           AND age.ServiceTo = 'FM'
                           AND l_Is_Person_Address_Equal > 0)
                    THEN
                        ret := 1;
                    END IF;
                ELSIF (   age.FamilyConnect = 'HW' -- Особа має ступінь родинного зв’язку nda_id = 649 «Дружина/чоловік»
                       OR -- Особа має вік < 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7 і
                          -- ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                          (    age.AgeYear BETWEEN 0 AND 18
                           AND age.FamilyConnect IN ('B', 'UB'))
                       OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                          -- якщо є «Довідка про навчання» ndt_id = 98 та форма навчання nda_id in (690) = «Денна» або «Дуальна» і
                          -- ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                          (    age.AgeYear > 18
                           AND age.FamilyConnect IN ('B', 'UB') --Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
                           AND API$APPEAL.get_doc_string (age.app_id,
                                                          98,
                                                          690,
                                                          'O') IN ('D', 'U') --якщо є довідка про навчання та форма навчання=денна або дуальна
                                                                            )
                       OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                          -- зазначено «особа з інвалідністю» 1 групи і ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                          (    age.AgeYear > 18
                           AND age.FamilyConnect IN ('B', 'UB')
                           AND age.Disability = 'T'   --«особа з інвалідністю»
                           AND age.DisabilityGroup = '1' --666  Група інвалідності
                                                        )
                       OR -- Особа має вік >= 18 років за даними документа «Свідоцтво про народження дитини» ndt_id = 37 або «ID картка» ndt_id = 7,
                          -- зазначено «особа з інвалідністю» 2 групи та «Інвалідність з дитинства» і ступінь родинного зв’язку nda_id in (649) = «Син/донька» або «Усиновлений/усиновлена»
                          (    age.AgeYear > 18
                           AND age.FamilyConnect IN ('B', 'UB')
                           AND age.Disability = 'T'   --«особа з інвалідністю»
                           AND age.DisabilityGroup = '2' --666  Група інвалідності
                           AND age.DisabilityReason = 'ID' --причина інвалідності= «Інвалідність з дитинства»
                                                          )
                       OR -- Особа має ступінь родинного зв’язку nda_id = 649 «Батько/мати» або «Свекор/свекруха» або «Тесть/теща» і
                          -- ознака роботи (зайнятості) «Працює» = «Ні»
                          (    age.FamilyConnect IN ('PILM', 'PILF', 'P') --«Батько/мати» або «Свекор/свекруха» або «Тесть/теща»
                           AND age.NotWorking = 'T'                --Не працює
                                                   ))
                THEN
                    ret := 1;
                END IF;
            ELSIF age.app_tp IN ('FP')
            THEN
                ret := 1;
            END IF;
        /*
        dbms_output.put_line('---------------------------------');
        dbms_output.put_line('p_at = '||p_at);
        dbms_output.put_line('p_app_sc = '||p_app_sc);
        dbms_output.put_line('age.ap_tp = '||age.ap_tp);
        dbms_output.put_line('age.app_src = '||age.app_src);
        dbms_output.put_line('age.app_tp = '||age.app_tp);
        dbms_output.put_line('age.APP_ID_Z = '||l_App_Id_Z);
        dbms_output.put_line('age.APP_ID = '||age.APP_ID);
        dbms_output.put_line('age.ServiceNeeded = '||age.ServiceNeeded);
        dbms_output.put_line('age.ServiceTo = '||age.ServiceTo);
        dbms_output.put_line('age.isAttr801 = '||age.isAttr801);
        dbms_output.put_line('l_Is_Person_Address_Equal = '||l_Is_Person_Address_Equal);
        dbms_output.put_line('age.MainInitNdt = '||age.MainInitNdt);
        dbms_output.put_line('ret = '||ret);
        */
        END LOOP;


        RETURN ret;
    END;

    --=======================================--
    FUNCTION CheckApp (p_pd       NUMBER,
                       p_app_sc   NUMBER,
                       p_tp       VARCHAR2,
                       p_nst      NUMBER)
        RETURN NUMBER
    IS
        ret   NUMBER := 0;
    BEGIN
        /*
        3.2. Особи у зверненні, які мають ознаку «Член сім’ї» та відповідають одній із умов:
        • В Анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено «Дружина/чоловік»;
        • Вік<=18 років за даними документа «Свідоцтво про народження» або «ІД-картка» і в анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
        • Вік > 18 років за даними документа «Свідоцтво про народження» або «ІД-картка», якщо є довідка про навчання та форма навчання=денна або дуальна і в анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
        • Вік > 18 років за даними документа «Свідоцтво про народження» або «ІД-картка», в анкеті в «ознака роботи/зайнятість» зазначено «особа з інвалідністю» і в «Інформації про інвалідність» зазначено 1 група і в анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
        • Вік > 18 років за даними документа «Свідоцтво про народження» або «ІД-картка», в анкеті в «ознака роботи/зайнятість» зазначено «особа з інвалідністю» і в «Інформації про інвалідність» зазначено 2 група і в причина інвалідності= «Інвалідність з дитинства» і в анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено «Син/донька» або «Усиновлений/усиновлена»;
        • В анкеті в Атрибуті «Ступінь родинного зв’язку» зазначено
        «Батько/мати» або «Свекор/свекруха» або «Тесть/теща» і в анкеті зазначено «Непрацездатний» і «Не працює».
        */
        CASE
            WHEN p_nst = 267
            THEN
                ret := CheckApp267 (p_pd, p_app_sc, p_tp);
            WHEN p_nst = 249
            THEN
                ret := CheckApp249 (p_pd, p_app_sc, p_tp);
            WHEN p_nst = 268
            THEN
                ret := CheckApp268 (p_pd, p_app_sc, p_tp);
            WHEN p_nst = 275
            THEN
                ret := CheckApp268 (p_pd, p_app_sc, p_tp);
            WHEN p_nst BETWEEN 400 AND 499
            THEN
                ret := CheckApp4xx (p_pd, p_app_sc, p_tp);
            ELSE
                IF p_tp IN ('Z', 'FP', 'FM')
                THEN
                    ret := 1;
                ELSE
                    ret := 0;
                END IF;
        END CASE;

        RETURN ret;
    END;

    --=======================================--
    PROCEDURE cleare_pd_income (p_pd_id NUMBER)
    IS
    BEGIN
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid.pid_id
                           FROM pd_income_calc  pic
                                JOIN pd_income_detail pid
                                    ON pid.pid_pic = pic.pic_id
                          WHERE pic.pic_pd = p_pd_id);

        DELETE FROM pd_income_detail
              WHERE pid_pic IN (SELECT pic.pic_id
                                  FROM pd_income_calc pic
                                 WHERE pic.pic_pd = p_pd_id);

        UPDATE pd_income_calc c
           SET c.pic_total_income_6m = NULL,
               c.pic_plot_income_6m = NULL,
               c.pic_month_income = NULL,
               c.pic_members_number = NULL,
               c.pic_member_month_income = NULL,
               c.pic_limit = NULL
         WHERE pic_pd = p_pd_id;
    END;

    --=======================================--
    PROCEDURE cleare_at_income (p_at_id NUMBER)
    IS
    BEGIN
        DELETE FROM at_income_log
              WHERE ail_aid IN
                        (SELECT aid.aid_id
                           FROM at_income_calc  aic
                                JOIN at_income_detail aid
                                    ON aid.aid_aic = aic.aic_id
                          WHERE aic.aic_at = p_at_id);

        DELETE FROM at_income_detail
              WHERE aid_aic IN (SELECT aic.aic_id
                                  FROM at_income_calc aic
                                 WHERE aic.aic_at = p_at_id);

        UPDATE at_income_calc c
           SET c.aic_total_income_6m = NULL,
               c.aic_plot_income_6m = NULL,
               c.aic_month_income = NULL,
               c.aic_members_number = NULL,
               c.aic_member_month_income = NULL,
               c.aic_limit = NULL
         WHERE aic_at = p_at_id;
    END;

    --=======================================--
    --  Перевірка діапазону дат доходу
    --=======================================--
    FUNCTION Check_Income_Date (Is_Alt_period NUMBER)
        RETURN BOOLEAN
    IS
        l_curr_year   VARCHAR2 (10);
        l_prev_year   VARCHAR2 (10);
        l_start_dt    DATE;
        l_stop_dt     DATE;
        l_err         VARCHAR2 (2000);
        l_cnt         NUMBER;
        l_ret         BOOLEAN := TRUE;
    BEGIN
        IF Is_Alt_period != 0
        THEN
            RETURN l_ret;
        END IF;

        FOR rec IN (SELECT pd_id, ap_reg_dt
                      FROM tmp_work_ids
                           JOIN pc_decision ON x_id = pd_id
                           JOIN appeal ON ap_id = pd_ap
                     WHERE pd_nst IN (267, 249))
        LOOP
            l_curr_year := TO_CHAR (rec.ap_reg_dt, 'yyyy');
            l_prev_year := TO_CHAR (rec.ap_reg_dt, 'yyyy') - 1;

            CASE
                WHEN TRUNC (rec.ap_reg_dt, 'mm') BETWEEN TO_DATE (
                                                                '01.08.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                                '31.10.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                THEN
                    l_start_dt :=
                        TO_DATE ('01.01.' || l_curr_year, 'dd.mm.yyyy');
                    l_stop_dt :=
                        TO_DATE ('30.06.' || l_curr_year, 'dd.mm.yyyy');
                    --Якщо місяць звернення дорівнює 08, 09, 10 поточного року, то період, за який вносяться доходи не може виходити за межі періоду з 01.01.<поточний рік> по 30.06.<поточний рік>
                    l_err :=
                           'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з 01.01.'
                        || l_curr_year
                        || ' по 30.06.'
                        || l_curr_year
                        || '. Виправте помилковий період.';
                WHEN TRUNC (rec.ap_reg_dt, 'mm') BETWEEN TO_DATE (
                                                                '01.01.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                                '31.01.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                THEN
                    l_start_dt :=
                        TO_DATE ('01.04.' || l_prev_year, 'dd.mm.yyyy');
                    l_stop_dt :=
                        TO_DATE ('30.09.' || l_prev_year, 'dd.mm.yyyy');
                    l_err :=
                        'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з  01.04 поточного року  по  30.09 поточного року для звернень за 11,12 місяці, а для звернень за 01 місяці за період з 01.04 минулого року по 30.09 минулого року. Виправте помилковий період.';
                WHEN TRUNC (rec.ap_reg_dt, 'mm') BETWEEN TO_DATE (
                                                                '01.11.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                                '31.12.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                THEN
                    l_start_dt :=
                        TO_DATE ('01.04.' || l_curr_year, 'dd.mm.yyyy');
                    l_stop_dt :=
                        TO_DATE ('30.09.' || l_curr_year, 'dd.mm.yyyy');
                    --Якщо місяць звернення дорівнює 11, 12, 01, то період, за то період, за який вносяться доходи не може виходити за межі  з 01.04.<поточний рік, для звернень поданих у 11 та 12 місяцях,
                    -- (поточний рік-1), для звернень поданих у першому місяці> по 30.09.<поточний рік, для звернень поданих у 11 та 12 місяцях, (поточний рік-1), для звернень поданих у першому місяці>
                    -- Коментар:  якщо звернення від 12.11.2022, то період за який можна вносити доходи входить з 01.04.2022 по 30.09.2022
                    -- (користувач може внести весь період або кілька записів які належать до періоду з 01.04.2022 по 30.09.2022),
                    -- а якщо звернення від 15.01.2023, то період за який можна вносити доходи входить у період з 01.04.2022 по 30.09.2022
                    --'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з  01.04 поточного року  по  30.09 поточного року для звернень за 11,12 місяці, а для звернень за 01 місяці за період з  01.04 минулого року  по  30.09 минулого року. Виправте помилковий період.'
                    l_err :=
                        'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з  01.04 поточного року  по  30.09 поточного року для звернень за 11,12 місяці, а для звернень за 01 місяці за період з 01.04 минулого року по 30.09 минулого року. Виправте помилковий період.';
                WHEN TRUNC (rec.ap_reg_dt, 'mm') BETWEEN TO_DATE (
                                                                '01.02.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                                '30.04.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                THEN
                    l_start_dt :=
                        TO_DATE ('01.07.' || l_prev_year, 'dd.mm.yyyy');
                    l_stop_dt :=
                        TO_DATE ('31.12.' || l_prev_year, 'dd.mm.yyyy');
                    --Якщо місяць звернення дорівнює 02, 03, 04, то період, за який вносиься дохід не має виходити за межі з 01.07.< (поточний рік-1)> по 31.12.< (поточний рік-1)>
                    l_err :=
                           'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з  01.07.'
                        || l_prev_year
                        || ' по 31.12.'
                        || l_prev_year
                        || '';
                WHEN TRUNC (rec.ap_reg_dt, 'mm') BETWEEN TO_DATE (
                                                                '01.05.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                                '31.07.'
                                                             || l_curr_year,
                                                             'dd.mm.yyyy')
                THEN
                    l_start_dt :=
                        TO_DATE ('01.10.' || l_prev_year, 'dd.mm.yyyy');
                    l_stop_dt :=
                        TO_DATE ('31.03.' || l_curr_year, 'dd.mm.yyyy');
                    --Якщо місяць звернення дорівнює 05, 06, 07, то період, за який вносиься дохід не має виходити за межі з 01.10.< (поточний рік-1)> по  31.03.<поточний рік>
                    l_err :=
                           'Неправильно заповнено період, за який вносяться доходи, доходи можливо вносити за період з 01.10.'
                        || l_prev_year
                        || ' по 31.03.'
                        || l_curr_year
                        || '';
                ELSE
                    NULL;
            END CASE;

            DBMS_OUTPUT.put_line (
                'start_dt = ' || TO_CHAR (l_start_dt, 'dd.mm.yyyy'));
            DBMS_OUTPUT.put_line (
                'stop_dt  = ' || TO_CHAR (l_stop_dt, 'dd.mm.yyyy'));

            SELECT COUNT (1)
              INTO l_cnt
              FROM pd_income_src
             WHERE     pis_pd = rec.pd_id
                   AND (   pis_start_dt NOT BETWEEN l_start_dt AND l_stop_dt
                        OR pis_stop_dt NOT BETWEEN l_start_dt AND l_stop_dt)
                   AND pis_src = 'HND';

            IF l_cnt > 0
            THEN
                l_ret := FALSE;
                TOOLS.add_message (g_messages, 'E', l_err);
                cleare_pd_income (rec.pd_id);
            END IF;

            SELECT COUNT (1)
              INTO l_cnt
              FROM pd_income_src
             WHERE     pis_pd = rec.pd_id
                   AND (pis_start_dt IS NULL OR pis_stop_dt IS NULL)
                   AND pis_src = 'HND';

            IF l_cnt > 0
            THEN
                l_ret := FALSE;
                TOOLS.add_message (
                    g_messages,
                    'E',
                    'Не заповнено періоди, за які вносяться доходи');
                cleare_pd_income (rec.pd_id);
            END IF;
        --Не заповнено періоди, за які вносяться доходи

        END LOOP;

        RETURN l_ret;
    END;

    --=======================================--
    FUNCTION Check_Income_Date_at
        RETURN BOOLEAN
    IS
        l_ret   BOOLEAN := TRUE;
    BEGIN
        RETURN l_ret;
    END;

    --=======================================--
    --  Сформужмо та сберігаємо лог розрахунку
    --=======================================--
    PROCEDURE Set_Calc_Log
    IS
    BEGIN
        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
              SELECT 0,
                     pid.pid_id,
                        CHR (38)
                     || '33#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (dat.DIC_SNAME || ' ' || tics.tics_logtrue,
                                 ', ')
                        WITHIN GROUP (ORDER BY pid.pid_id)
                FROM pd_income_detail pid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = pid.pid_app
                            AND tics.tics_pic = pid.pid_pic
                            AND tics.tics_month = pid.pid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE     tics.tics_logtrue IS NOT NULL
                     AND tics.tics_koef IS NULL
                     AND (   (    tics.tics_tp NOT IN (5, 27, 28)
                              AND tics.tics_nst = 267)
                          OR tics.tics_nst != 267)
            GROUP BY pid.pid_id, tics.tics_month;

        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
              SELECT 0,
                     pid.pid_id,
                        CHR (38)
                     || '35#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (dat.DIC_SNAME || ' ' || tics.tics_logtrue,
                                 ', ')
                        WITHIN GROUP (ORDER BY pid.pid_id)
                FROM pd_income_detail pid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = pid.pid_app
                            AND tics.tics_pic = pid.pid_pic
                            AND tics.tics_month = pid.pid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE     tics.tics_logtrue IS NOT NULL
                     AND tics.tics_koef IS NULL
                     AND tics.tics_tp IN (5, 27, 28)
                     AND (tics.tics_tp IN (5, 27, 28) AND tics.tics_nst = 267)
            GROUP BY pid.pid_id, tics.tics_month;

        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
              SELECT 0,
                     pid.pid_id,
                        CHR (38)
                     || '34#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (
                               dat.DIC_SNAME
                            || ' ('
                            || TO_CHAR (tics.tics_koef, 'FM90.90')
                            || ') '
                            || tics.tics_logtrue,
                            ', ')
                        WITHIN GROUP (ORDER BY pid.pid_id)
                FROM pd_income_detail pid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = pid.pid_app
                            AND tics.tics_pic = pid.pid_pic
                            AND tics.tics_month = pid.pid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE     tics.tics_logtrue IS NOT NULL
                     AND tics.tics_koef IS NOT NULL
            GROUP BY pid.pid_id, tics.tics_month;

        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
              SELECT 0,
                     pid.pid_id,
                        CHR (38)
                     || '35#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (dat.DIC_SNAME || ' ' || tics.tics_logfalse,
                                 ', ')
                        WITHIN GROUP (ORDER BY pid.pid_id)
                FROM pd_income_detail pid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = pid.pid_app
                            AND tics.tics_pic = pid.pid_pic
                            AND tics.tics_month = pid.pid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE tics.tics_logfalse IS NOT NULL
            GROUP BY pid.pid_id, tics.tics_month;
    END;

    --=======================================--
    PROCEDURE Set_Calc_Log_at
    IS
    BEGIN
        INSERT INTO at_income_log (ail_id, ail_aid, ail_message)
              SELECT 0,
                     aid.aid_id,
                        CHR (38)
                     || '33#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (dat.DIC_SNAME || ' ' || tics.tics_logtrue,
                                 ', ')
                        WITHIN GROUP (ORDER BY aid.aid_id)
                FROM at_income_detail aid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = aid.aid_app
                            AND tics.tics_aic = aid.aid_aic
                            AND tics.tics_month = aid.aid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE tics.tics_logtrue IS NOT NULL AND tics.tics_koef IS NULL
            GROUP BY aid.aid_id, tics.tics_month;

        INSERT INTO at_income_log (ail_id, ail_aid, ail_message)
              SELECT 0,
                     aid.aid_id,
                        CHR (38)
                     || '34#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (
                               dat.DIC_SNAME
                            || ' ('
                            || TO_CHAR (tics.tics_koef, 'FM90.90')
                            || ') '
                            || tics.tics_logtrue,
                            ', ')
                        WITHIN GROUP (ORDER BY aid.aid_id)
                FROM at_income_detail aid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = aid.aid_app
                            AND tics.tics_aic = aid.aid_aic
                            AND tics.tics_month = aid.aid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE     tics.tics_logtrue IS NOT NULL
                     AND tics.tics_koef IS NOT NULL
            GROUP BY aid.aid_id, tics.tics_month;

        INSERT INTO at_income_log (ail_id, ail_aid, ail_message)
              SELECT 0,
                     aid.aid_id,
                        CHR (38)
                     || '35#'
                     || TO_CHAR (tics.tics_month, 'dd.mm.yyyy')
                     || '#'
                     || ' '
                     || LISTAGG (dat.DIC_SNAME || ' ' || tics.tics_logfalse,
                                 ', ')
                        WITHIN GROUP (ORDER BY aid.aid_id)
                FROM at_income_detail aid
                     JOIN tmp_income_calc_src tics
                         ON     tics.tics_app = aid.aid_app
                            AND tics.tics_aic = aid.aid_aic
                            AND tics.tics_month = aid.aid_month
                     JOIN uss_ndi.v_ddn_apri_tp dat
                         ON dat.DIC_CODE = tics.tics_tp
               WHERE tics.tics_logfalse IS NOT NULL
            GROUP BY aid.aid_id, tics.tics_month;
    END;

    --=======================================--
    --  Розрахунок доходу для рішення
    --=======================================--
    PROCEDURE calc_income_for_pd (p_mode              INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id             pc_decision.pd_id%TYPE,
                                  Is_Alt_period       INTEGER DEFAULT 0,
                                  p_messages      OUT SYS_REFCURSOR)
    IS
        l_cnt   INTEGER;
        l_hs    histsession.hs_id%TYPE;
    BEGIN
        g_messages.delete;

        IF p_mode = 1 AND p_pd_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE pd_id = p_pd_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, pc_decision
             WHERE x_id = pd_id;
        END IF;

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                g_messages,
                'E',
                'В функцію розрахунку середньомісячного доходу не передано ідентифікаторів проектів рішень!');
            RETURN;
        ELSIF NOT Check_Income_Date (Is_Alt_period)
        THEN
            RETURN;
        END IF;

        DELETE FROM TMP_INCOME_CALC_MONTHS
              WHERE 1 = 1;

        DELETE FROM TMP_INCOME_CALC_SRC1
              WHERE 1 = 1;

        DELETE FROM TMP_INCOME_CALC_SRC
              WHERE 1 = 1;

        l_hs := TOOLS.GetHistSession;

        --Створюємо запис "розрахунку"
        MERGE INTO pd_income_calc
             USING (SELECT 0                                           AS x_id,
                           SYSDATE                                     AS x_dt,
                           pd_pc                                       AS x_pc,
                           pd_id                                       AS x_pd,
                           (SELECT MAX (pin_id)
                              FROM pd_income_session
                             WHERE pin_pd = pd_id AND pin_st = 'E')    AS x_pin
                      FROM tmp_work_ids JOIN pc_decision ON x_id = pd_id)
                ON (pic_pd = x_pd AND pic_pin = x_pin)
        WHEN MATCHED
        THEN
            UPDATE SET pic_dt = x_dt, pic_pc = x_pc
        WHEN NOT MATCHED
        THEN
            INSERT     (pic_id,
                        pic_dt,
                        pic_pc,
                        pic_pd,
                        pic_pin)
                VALUES (0,
                        x_dt,
                        x_pc,
                        x_pd,
                        x_pin);

        --Чистимо лог
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid.pid_id
                           FROM tmp_work_ids
                                JOIN pd_income_calc pic ON pic.pic_pd = x_id
                                JOIN pd_income_detail pid
                                    ON pid.pid_pic = pic.pic_id);

        -- Заповниму анкети для подальшого використання
        api$anketa.Set_Anketa;

        --NIC_1MONTH_ALG
        --Пишему в тимчасову таблицю розрахунку записи по місяцях
        INSERT INTO TMP_INCOME_CALC_Months (Ticm_AP,
                                            Ticm_Ap_Tp,
                                            Ticm_Pd,
                                            Ticm_nst,
                                            Ticm_Pic,
                                            Ticm_APP,
                                            Ticm_Sc,
                                            Ticm_Month,
                                            Ticm_Min_Zp,
                                            Ticm_Vpo,
                                            Ticm_ap_reg_dt)
            WITH
                periods
                AS
                    (    SELECT LEVEL     AS x_month
                           FROM DUAL
                     CONNECT BY LEVEL < 13),
                months
                AS
                    (SELECT pd_id                               AS r_pd,
                            pd_nst                              AS r_nst,
                            ap_tp                               AS r_ap_tp,
                            pd_ap                               AS r_ap,
                            pic_id                              AS r_pic,
                            (SELECT MAX (app.app_id)
                               FROM ap_person app
                              WHERE     app.app_ap IN (pd_ap, pd_ap_reason)
                                    AND app.history_status = 'A'
                                    AND app.app_sc = tpp_sc)    AS r_app,
                            tpp_sc                              AS r_sc,
                            ap_reg_dt,
                            CASE
                                WHEN pin.pin_tp = 'RC'
                                THEN
                                    ADD_MONTHS (
                                        TRUNC (rc.rc_month, 'MM'),
                                        -(  x_month
                                          + API$PC_DECISION.get_month_start (
                                                rc.rc_month,
                                                nic_1month_alg)))
                                WHEN Is_Alt_period = 1
                                THEN
                                    ADD_MONTHS (
                                        TRUNC (ap_reg_dt, 'MM'),
                                        -(  x_month
                                          + API$PC_DECISION.get_month_start (
                                                ap_reg_dt,
                                                nic_1month_alg_alt)))
                                ELSE
                                    ADD_MONTHS (
                                        TRUNC (ap_reg_dt, 'MM'),
                                        -(  x_month
                                          + API$PC_DECISION.get_month_start (
                                                ap_reg_dt,
                                                nic_1month_alg)))
                            END                                 AS r_month,
                            CASE
                                WHEN pin.pin_tp = 'RC'
                                THEN
                                    ADD_MONTHS (
                                        TRUNC (rc.rc_month, 'MM'),
                                        -(  1
                                          + API$PC_DECISION.get_month_start (
                                                rc.rc_month,
                                                nic_1month_alg)))
                                WHEN Is_Alt_period = 1
                                THEN
                                    ADD_MONTHS (
                                        TRUNC (ap_reg_dt, 'MM'),
                                        -(  1
                                          + API$PC_DECISION.get_month_start (
                                                ap_reg_dt,
                                                nic_1month_alg_alt)))
                                ELSE
                                    ADD_MONTHS (
                                        TRUNC (ap_reg_dt, 'MM'),
                                        -(  1
                                          + API$PC_DECISION.get_month_start (
                                                ap_reg_dt,
                                                nic_1month_alg)))
                            END                                 AS r_month_min_zp
                       FROM tmp_work_ids
                            JOIN pc_decision ON x_id = pd_id
                            JOIN pd_income_session pin
                                ON pin_pd = pd_id AND pin.pin_st = 'E'
                            LEFT JOIN recalculates rc ON rc_id = pin.pin_rc
                            LEFT JOIN uss_ndi.V_NDI_NST_INCOME_CONFIG
                                ON pd_nst = nic_nst,
                            pd_income_calc,
                            periods,
                            appeal,
                            tmp_pa_persons  tpp
                      WHERE     pic_pd = pd_id
                            AND pic_pin = pin_id
                            AND pd_ap = ap_id
                            AND pd_id = tpp_pd
                            AND x_month <= nic_months
                            AND API$Calc_Income.CheckApp (pd_id,
                                                          tpp_sc,
                                                          tpp.tpp_app_tp,
                                                          pd_nst) = 1)
            SELECT r_ap,
                   r_ap_tp,
                   r_pd,
                   r_nst,
                   r_pic,
                   r_app,
                   r_sc,
                   r_month,
                   (SELECT MAX (nmz_month_sum)
                      FROM uss_ndi.v_ndi_min_zp
                     WHERE     r_month_min_zp >= nmz_start_dt
                           AND (   r_month_min_zp <= nmz_stop_dt
                                OR nmz_stop_dt IS NULL)
                           AND history_status = 'A')    AS nmz_month_sum,
                   --ознака документу, що підтвержує ВПО, в активному статусі 'A'
                   (CASE r_nst
                        WHEN 249
                        THEN
                            API$ACCOUNT.get_docx_string (r_pd,
                                                         r_sc,
                                                         10052,
                                                         1855,
                                                         ap_reg_dt,
                                                         '-')
                        ELSE
                            'F'
                    END)                                AS x_VPO,
                   ap_reg_dt
              FROM months;

        --#101167
        /*
        Для звернень за допомогою з Ід=249 з датою подання заяви після 01.03.2024 не застосовувати коефіцієнти 0,5 і 0,25 до доходів особи,
        у випадку, якщо в особи наявний документ  з Ід=10308 "Інформація про період перебування особи за кордоном" і одночасно виконуються такі умови:
        В атрибуті  Ід=8375 «День повернення з-за кордону» зазначено дату після 24.02.2022
        Різниця між датами в атрибутах Ід=8375 «День повернення з-за кордону» і Ід=8374  «День виїзду за кордон» більше рівне 90 днів
        */
        UPDATE TMP_INCOME_CALC_Months t
           SET Ticm_Vpo = 'A'
         WHERE     t.ticm_nst = '249'
               AND t.ticm_vpo != 'A'
               AND API$ACCOUNT.get_docx_dt (t.ticm_pd,
                                            t.ticm_sc,
                                            10308,
                                            8375,
                                            Ticm_ap_reg_dt) >
                   TO_DATE ('24.02.2022', 'dd.mm.yyyy')
               AND ABS (  API$ACCOUNT.get_docx_dt (t.ticm_pd,
                                                   t.ticm_sc,
                                                   10308,
                                                   8375,
                                                   Ticm_ap_reg_dt)
                        - API$ACCOUNT.get_docx_dt (t.ticm_pd,
                                                   t.ticm_sc,
                                                   10308,
                                                   8374,
                                                   Ticm_ap_reg_dt)) >= 90;

        /*
                INSERT INTO TMP_INCOME_CALC_SRC1(TICS1_PD,
                                                 TICS1_NST,
                                                 TICS1_PIC,
                                                 TICS1_APP,
                                                 TICS1_MONTH,
                                                 TICS1_TP,
                                                 TICS1_EXCH_TP,
                                                 TICS1_MIN_ZP,
                                                 TICS1_USE_TP,
                                                 TICS1_ESV_MIN,
                                                 TICS1_SUM,
                                                 TICS1_LOG,
                                                 TICS1_SRC,
                                                 TICS1_ORDER
                                                )
                WITH bd AS (select apd_id as aim_apd, apd_ap as aim_ap, apd_app as aim_app,
                                   API$Calc_Income.ToDate (  substr(trim(COLUMN_VALUE),1,instr(trim(COLUMN_VALUE),'=')-1)) aim_month,
                                   CASE substr(trim(COLUMN_VALUE),instr(trim(COLUMN_VALUE),'=')+1)
                                      WHEN 'T' THEN 1 ELSE 0 END AS aim_val
                            from ap_document
                                 join ap_document_attr a on a.apda_apd=apd_id and a.apda_nda=4359 and a.history_status='A',
                                 xmltable(('"'      || REPLACE(  regexp_replace(a.apda_val_string,chr(13)||'|'||chr(10),'')  , ',', '","')      || '"'))
                            where apd_ndt=10246 and ap_document.history_status='A'
                           ),
                     pd_income_src_month AS
                           (select pis_id, pis_pd, pis_app,
                                   CASE PIS_SRC
                                     WHEN 'EISSS'     THEN 'EISSS'
                                     WHEN 'EISSS.NPT' THEN 'EISSS'
                                   ELSE PIS_SRC
                                   END AS PIS_SRC,
                                   PIS_TP, PIS_EXCH_TP, pis_esv_min , pis_final_sum, pis_stop_dt, pis_start_dt, pis.pis_use_tp, pis_sc,
                                   NVL( pis_final_sum / (MONTHS_BETWEEN(TRUNC(pis_stop_dt, 'MM'), TRUNC(pis_start_dt, 'MM')) + 1 ) , 0) AS x_fact_sum
                            from pd_income_src pis
                              JOIN tmp_work_ids ON x_id = pis.pis_pd
                              JOIN pd_income_session pin ON pin_id = pis.pis_pin AND pin.pin_st = 'E'
                           ),
                     TMP_INCOME AS
                           (  SELECT ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_sc, ticm_month, PIS_SRC as r_SRC, PIS_TP as x_tp, ticm_min_zp as r_min_zp,
                                     NVL(SUM(x_fact_sum), 0) AS x_fact_sum,
                                     pis_use_tp  AS x_use_tp,
                                     (CASE pis_exch_tp WHEN '104' THEN '104' ELSE '' END) AS x_exch_tp
                              FROM  TMP_INCOME_CALC_Months
                                    left join pd_income_src_month on ticm_pd = pis_pd and ticm_sc = pis_sc and ticm_month BETWEEN pis_start_dt AND pis_stop_dt
                              GROUP BY ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_sc, ticm_month, Ticm_Min_Zp, PIS_SRC, PIS_TP, pis_use_tp,
                                       (CASE pis_exch_tp WHEN '104' THEN '104' ELSE '' END)
                              union all
                              SELECT ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_sc, ticm_month, 'DOV' as r_SRC, aim_tp as r_tp, ticm_min_zp as r_min_zp,
                                     nvl(aim_sum,0) as  x_fact_sum,
                                     'STO' AS x_use_tp,
                                     ''    AS x_exch_tp
                              from TMP_INCOME_CALC_Months
                                   join v_apd_income_month  on aim_app = ticm_app  and aim_month=ticm_month
                              union all
                              SELECT ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_sc, ticm_month, 'BD' as r_SRC, '26' as r_tp, ticm_min_zp as r_min_zp,
                                     nvl(aim_val,0) as  x_fact_sum,
                                     'STO' AS x_use_tp,
                                     ''    AS x_exch_tp
                              from TMP_INCOME_CALC_Months
                                   join bd  on aim_app = ticm_app  and aim_month=ticm_month
                           )
                select ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_month, x_tp, x_exch_tp, r_min_zp, x_use_tp,
                       x_esv_min,
                       x_fact_sum,
                       x_log,
                       r_src,
                       x_order
                From (  SELECT ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_sc, ticm_month, r_SRC, x_tp, r_min_zp,
                               (SELECT max(pis_esv_min)
                                from pd_income_src_month
                                where ticm_pd = pis_pd and ticm_app = pis_app
                                  and ticm_month BETWEEN pis_start_dt AND pis_stop_dt
                               ) AS x_esv_min,
                               x_fact_sum,
                               x_use_tp,
                               x_exch_tp,
                               CASE r_src
                                 WHEN 'PFU'   THEN 'ПФУ '
                                 WHEN 'DPS'   THEN 'ДПС '
                                 WHEN 'APR'   THEN 'Декларація '
                                 WHEN 'DOV'   THEN 'Довідка '
                                 WHEN 'HND'   THEN 'Ручний '
                                 WHEN 'EISSS' THEN 'ЕІССС '
                                 WHEN 'BD'    THEN ''
                               END AS x_log,
                               CASE r_src
                                 WHEN 'PFU'   THEN to_number(o.nio_pfu_order)
                                 WHEN 'DPS'   THEN to_number(o.nio_dps_order)
                                 WHEN 'APR'   THEN to_number(o.nio_apr_order)
                                 WHEN 'DOV'   THEN to_number(o.nio_dov_order)
                                 WHEN 'HND'   THEN to_number(o.nio_hnd_order)
                                 WHEN 'EISSS' THEN to_number(o.nio_eisss_order)
                                 WHEN 'BD'    THEN NULL
                               END AS x_order
                        FROM  TMP_INCOME
                          JOIN uss_ndi.v_ndi_nst_income_order o ON nio_nst = Ticm_nst AND nio_apri_tp = x_tp
                        WHERE x_tp is not null
                      )
        --        GROUP BY ticm_pd, Ticm_nst, ticm_pic, ticm_app, ticm_month, x_tp, x_exch_tp, r_min_zp, x_use_tp,
        --               x_esv_min, x_log, r_src, x_order
                ;
        */
        -- олд
        --Пишему в тимчасову таблицю розрахунку всі записи, які повинні були розрахуватись
        INSERT INTO TMP_INCOME_CALC_SRC (TICS_PD,
                                         TICS_NST,
                                         TICS_PIC,
                                         TICS_APP,
                                         TICS_MONTH,
                                         TICS_TP,
                                         TICS_EXCH_TP,
                                         TICS_MIN_ZP,
                                         TICS_USE_TP,
                                         TICS_ESV_MIN,
                                         TICS_SUM_PFU,
                                         TICS_SUM_DPS,
                                         TICS_SUM_APR,
                                         TICS_SUM_DOV,
                                         TICS_SUM_HND,
                                         TICS_SUM_EISSS,
                                         TICS_BD)
            WITH
                bd
                AS
                    (SELECT apd_id
                                AS aim_apd,
                            apd_ap
                                AS aim_ap,
                            apd_app
                                AS aim_app,
                            API$Calc_Income.ToDate (
                                SUBSTR (TRIM (COLUMN_VALUE),
                                        1,
                                        INSTR (TRIM (COLUMN_VALUE), '=') - 1))
                                aim_month,
                            CASE SUBSTR (
                                     TRIM (COLUMN_VALUE),
                                     INSTR (TRIM (COLUMN_VALUE), '=') + 1)
                                WHEN 'T'
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                AS aim_val
                       FROM ap_document
                            JOIN ap_document_attr a
                                ON     a.apda_apd = apd_id
                                   AND a.apda_nda = 4359
                                   AND a.history_status = 'A',
                            XMLTABLE (
                                (   '"'
                                 || REPLACE (
                                        REGEXP_REPLACE (
                                            a.apda_val_string,
                                            CHR (13) || '|' || CHR (10),
                                            ''),
                                        ',',
                                        '","')
                                 || '"'))
                      WHERE     apd_ndt = 10246
                            AND ap_document.history_status = 'A'),
                pd_income_src_month
                AS
                    (SELECT pis_id,
                            pis_pd,
                            pis_app,
                            CASE PIS_SRC
                                WHEN 'EISSS' THEN 'EISSS'
                                WHEN 'EISSS.NPT' THEN 'EISSS'
                                ELSE PIS_SRC
                            END       AS PIS_SRC,
                            PIS_TP,
                            PIS_EXCH_TP,
                            pis_esv_min,
                            pis_final_sum,
                            pis_stop_dt,
                            pis_start_dt,
                            pis.pis_use_tp,
                            pis_sc,
                            NVL (
                                  pis_final_sum
                                / (  MONTHS_BETWEEN (
                                         TRUNC (pis_stop_dt, 'MM'),
                                         TRUNC (pis_start_dt, 'MM'))
                                   + 1),
                                0)    AS x_fact_sum
                       FROM pd_income_src  pis
                            JOIN tmp_work_ids ON x_id = pis.pis_pd
                            JOIN pd_income_session pin
                                ON pin_id = pis.pis_pin AND pin.pin_st = 'E')
            SELECT ticm_pd,
                   Ticm_nst,
                   ticm_pic,
                   ticm_app,
                   ticm_month,
                   x_tp,
                   x_exch_tp,
                   r_min_zp,
                   x_use_tp,
                   (SELECT MAX (pis_esv_min)
                      FROM pd_income_src_month
                     WHERE     ticm_pd = pis_pd
                           AND ticm_app = pis_app
                           AND ticm_month BETWEEN pis_start_dt
                                              AND pis_stop_dt--                  and PIS_SRC = 'PFU'
                                                             )
                       AS x_esv_min,
                   "TICS_SUM_PFU",
                   "TICS_SUM_DPS",
                   "TICS_SUM_APR",
                   "TICS_SUM_DOV",
                   "TICS_SUM_HND",
                   "TICS_SUM_EISSS",
                   "TICS_BD"
              FROM (  SELECT ticm_pd,
                             Ticm_nst,
                             ticm_pic,
                             ticm_app,
                             ticm_sc,
                             ticm_month,
                             PIS_SRC                      AS r_SRC,
                             PIS_TP                       AS x_tp,
                             ticm_min_zp                  AS r_min_zp,
                             NVL (SUM (x_fact_sum), 0)    AS x_fact_sum,
                             pis_use_tp                   AS x_use_tp,
                             (CASE pis_exch_tp
                                  WHEN '104' THEN '104'
                                  ELSE ''
                              END)                        AS x_exch_tp
                        FROM TMP_INCOME_CALC_Months
                             LEFT JOIN pd_income_src_month
                                 ON     ticm_pd = pis_pd
                                    AND ticm_sc = pis_sc
                                    AND ticm_month BETWEEN pis_start_dt
                                                       AND pis_stop_dt
                    GROUP BY ticm_pd,
                             Ticm_nst,
                             ticm_pic,
                             ticm_app,
                             ticm_sc,
                             ticm_month,
                             Ticm_Min_Zp,
                             PIS_SRC,
                             PIS_TP,
                             pis_use_tp,
                             (CASE pis_exch_tp
                                  WHEN '104' THEN '104'
                                  ELSE ''
                              END)
                    UNION ALL
                    SELECT ticm_pd,
                           Ticm_nst,
                           ticm_pic,
                           ticm_app,
                           ticm_sc,
                           ticm_month,
                           'DOV'                AS r_SRC,
                           aim_tp               AS r_tp,
                           ticm_min_zp          AS r_min_zp,
                           NVL (aim_sum, 0)     AS x_fact_sum,
                           'STO'                AS x_use_tp,
                           ''                   AS x_exch_tp
                      FROM TMP_INCOME_CALC_Months
                           JOIN v_apd_income_month
                               ON     aim_app = ticm_app
                                  AND aim_month = ticm_month
                    UNION ALL
                    SELECT ticm_pd,
                           Ticm_nst,
                           ticm_pic,
                           ticm_app,
                           ticm_sc,
                           ticm_month,
                           'BD'                 AS r_SRC,
                           '26'                 AS r_tp,
                           ticm_min_zp          AS r_min_zp,
                           NVL (aim_val, 0)     AS x_fact_sum,
                           'STO'                AS x_use_tp,
                           ''                   AS x_exch_tp
                      FROM TMP_INCOME_CALC_Months
                           JOIN bd
                               ON     aim_app = ticm_app
                                  AND aim_month = ticm_month)
                       PIVOT (
                             MAX (x_fact_sum)
                             FOR r_src
                             IN ('PFU' AS "TICS_SUM_PFU",
                                'DPS' AS "TICS_SUM_DPS",
                                'APR' AS "TICS_SUM_APR",
                                'DOV' AS "TICS_SUM_DOV",
                                'HND' AS "TICS_SUM_HND",
                                'EISSS' AS "TICS_SUM_EISSS",
                                'BD' AS "TICS_BD"))
             WHERE x_tp IS NOT NULL;


        /*
           --Пишему в тимчасову таблицю розрахунку всі записи, які повинні були розрахуватись
              INSERT INTO TMP_INCOME_CALC_SRC(TICS_PD,
                                           TICS_NST,
                                           TICS_PIC,
                                           TICS_APP,
                                           TICS_MONTH,
                                           TICS_TP,
                                           TICS_EXCH_TP,
                                           TICS_MIN_ZP,
                                           TICS_USE_TP,
                                           TICS_ESV_MIN,
                                           TICS_SUM_PFU,
                                           TICS_SUM_DPS,
                                           TICS_SUM_APR,
                                           TICS_SUM_DOV,
                                           TICS_SUM_HND,
                                           TICS_SUM_EISSS,
                                           TICS_BD)
                select tics1_pd, tics1_nst, tics1_pic, tics1_app, tics1_month, tics1_tp, tics1_exch_tp, tics1_min_zp, tics1_use_tp,
                       tics1_esv_min,
                       "TICS_SUM_PFU", "TICS_SUM_DPS", "TICS_SUM_APR", "TICS_SUM_DOV","TICS_SUM_HND","TICS_SUM_EISSS","TICS_BD"
                From ( SELECT tics1_pd, tics1_nst, tics1_pic, tics1_app, tics1_month, tics1_tp, tics1_exch_tp, tics1_min_zp, tics1_use_tp, tics1_esv_min,
                              tics1_sum, tics1_src
                       FROM TMP_INCOME_CALC_SRC1
                     )
                pivot
                ( MAX(tics1_sum)
                FOR tics1_src in ('PFU'   as "TICS_SUM_PFU",
                                    'DPS'   as "TICS_SUM_DPS",
                                    'APR'   as "TICS_SUM_APR",
                                    'DOV'   as "TICS_SUM_DOV",
                                    'HND'   as "TICS_SUM_HND",
                                    'EISSS' as "TICS_SUM_EISSS",
                                    'BD'    as "TICS_BD")
                );
        */


        --92828
        --Не враховувати дохід з DIC_CODE=3 (заробітна плата) для тих, хто отримував допомогу по безробіттю під час карантину для послуг з Ід=249 і 267
        UPDATE TMP_INCOME_CALC_SRC t
           SET TICS_SUM_PFU = CASE WHEN TICS_SUM_PFU > 0 THEN 0 END,
               TICS_SUM_DPS = CASE WHEN TICS_SUM_DPS > 0 THEN 0 END,
               TICS_SUM_APR = CASE WHEN TICS_SUM_APR > 0 THEN 0 END,
               TICS_SUM_DOV = CASE WHEN TICS_SUM_DOV > 0 THEN 0 END,
               TICS_SUM_HND = CASE WHEN TICS_SUM_HND > 0 THEN 0 END
         WHERE     TICS_TP = 3
               AND TICS_NST IN (249, 267, 664)
               AND TICS_MONTH <= TO_DATE ('30.06.2023', 'dd.mm.yyyy')
               AND EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC t21
                         WHERE     t21.TICS_TP = 21
                               AND t21.tics_pd = t.tics_pd
                               AND t21.tics_app = t.tics_app
                               AND t21.tics_month > t.tics_month)
               AND EXISTS
                       (SELECT 1
                          FROM TABLE (api$Anketa.Get_Anketa) Ank
                         WHERE     Ank.pd_id = t.tics_pd
                               AND EXISTS
                                       (SELECT 1
                                          FROM ap_person
                                         WHERE     app_id = tics_app
                                               AND app_sc = Ank.app_sc)
                               AND API$ACCOUNT.get_docx_string (Ank.pd_id,
                                                                Ank.app_sc,
                                                                10198,
                                                                4361,
                                                                calc_dt,
                                                                '-') =
                                   'PART_ONE'
                               AND API$ACCOUNT.get_docx_dt (Ank.pd_id,
                                                            Ank.app_sc,
                                                            10198,
                                                            4363,
                                                            calc_dt) <=
                                   TO_DATE ('30.06.2023', 'dd.mm.yyyy'));

        --SELECT * FROM uss_ndi.V_DDN_UNEMPL_BNFTS
        --Якщо в атрибуту з Ід=4361 "Виплата допомоги по безробіттю згідно:" документу "Довідка про перебування на обліку у статусі безробітного у центрі зайнятості" Ід=10198
        --буде зазначено "частина перша статті 22" і в атрибутах з Ід=4362 по Ід=4363 зазначено період до 30.06.2023,
        --то в такому випадку для розрахунку середньомісчного сукупного доходу необхідно НЕ врахувати дохід з DIC_CODE=3,
        --який особа отримувала до отримання допомоги по безробіттю.

        -- включаємо суму лише для тих, зто в кварталі хоча б в одному місяці отримує допомогу ВПО Ід=664 і малозабезпечених apri_tp=42
        UPDATE TMP_INCOME_CALC_SRC t
           SET t.tics_use_tp = 'NOT_TP_42'
         WHERE     TICS_TP = 40
               AND TICS_NST = 664
               AND NOT EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC t21
                         WHERE     t21.TICS_TP = 42
                               AND t21.tics_pd = t.tics_pd
                               AND t21.tics_app = t.tics_app);

        --Розрахуємо сумму, що потрібно включити до доходу
        UPDATE TMP_INCOME_CALC_SRC tics
           SET (tics.tics_fact_sum,
                tics.tics_calc_sum,
                tics.tics_koef,
                tics.tics_LogTrue,
                tics.tics_LogFalse) =
                   (SELECT fact_sum,
                           calc_sum,
                           calc_koef,
                           LogTrue,
                           LogFalse
                      FROM TABLE (API$Calc_Income.Calc (TICS_NST,
                                                        TICS_TP,
                                                        TICS_EXCH_TP,
                                                        TICS_SUM_PFU,
                                                        TICS_SUM_DPS,
                                                        TICS_SUM_APR,
                                                        TICS_SUM_DOV,
                                                        TICS_SUM_HND,
                                                        TICS_SUM_EISSS,
                                                        TICS_MIN_ZP,
                                                        TICS_BD,
                                                        tics_use_tp)));

        --Розрахуємо та додамо відсутні суми по стипендіях
        /*    --Заблоковано за #114355
              MERGE INTO TMP_INCOME_CALC_SRC
                USING (select m.ticm_PD as x_PD, m.ticm_pic as x_PIC, m.ticm_nst as x_nst, m.ticm_app as x_APP, m.ticm_month as x_MONTH, '4' as x_TP,
                               m.ticm_min_zp as x_min_zp,
                               0.25 as x_KOEF
                        from TMP_INCOME_CALC_months m
                        where m.ticm_nst in (267, 249, 664)
                              and not (m.ticm_nst = 249 AND m.ticm_vpo='A')
                              and not exists (select 1 from TMP_INCOME_CALC_SRC tics1
                                              where tics1.tics_tp IN (28)
                                                    and tics1.tics_app  = m.ticm_app
                                                    and tics1.tics_pd   = m.ticm_pd
                                                    and tics1.tics_month= m.ticm_month
                                              )
                              and  exists (select 1 from TMP_INCOME_CALC_SRC tics1
                                           where tics1.tics_tp=4
                                                 and tics1.tics_app= m.ticm_app
                                                 and tics1.tics_pd = m.ticm_pd
                                           )
                       )
                ON (TICS_PIC=x_pic and TICS_APP=x_app and TICS_MONTH=x_month and TICS_TP=x_tp)
                WHEN NOT MATCHED THEN
                  INSERT (TICS_PD,TICS_PIC,TICS_NST,TICS_APP,TICS_MONTH,TICS_TP,TICS_KOEF, TICS_min_zp)
                     VALUES (x_PD,x_PIC,X_NST,x_APP,x_MONTH,x_TP,x_KOEF, x_min_zp);
        */
        --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
        --RETURN;



        UPDATE TMP_INCOME_CALC_SRC tics
           SET tics_calc_sum = tics_min_zp * tics_koef
         --             tics_calc_sum=tics_min_zp * 0.25,
         --             tics_koef=0.25
         WHERE     tics_tp = 4
               AND NVL (tics_calc_sum, 0) = 0
               AND tics_nst IN (267, 249, 664)
               AND NOT EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC tics1
                         WHERE     tics1.tics_tp = 28
                               AND tics1.tics_app = tics.tics_app
                               AND tics1.tics_pd = tics.tics_pd
                               AND tics1.tics_month = tics.tics_month)
               AND NOT EXISTS
                       (SELECT 1
                          FROM TABLE (api$Anketa.Get_Anketa) Ank
                         WHERE     Ank.pd_id = tics_pd
                               --AND Ank.app_ = tics_app
                               AND EXISTS
                                       (SELECT 1
                                          FROM ap_person
                                         WHERE     app_id = tics_app
                                               AND app_sc = Ank.app_sc)
                               --                                  AND API$CALC_RIGHT.get_docx_string(Ank.pd_id, Ank.app_sc, 98, 690,calc_dt,'O') IN ('D','U')
                               AND NVL (
                                       TRUNC (
                                             MONTHS_BETWEEN (tics_month,
                                                             Ank.birthday)
                                           / 12,
                                           0),
                                       -1) <
                                   18);

        --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
        --RETURN;

        --Пишему в тимчасову помясячну таблицю розрахунку всі записи, які повинні були розрахуватись з розбивкою по видах доходу
        INSERT INTO tmp_income_calc (tic_pd,
                                     tic_nst,
                                     tic_pic,
                                     tic_sc,
                                     tic_app,
                                     tic_month,
                                     tic_fact_sum,
                                     tic_calc_sum,
                                     tic_calc_sum_koef,
                                     tic_min_zp,
                                     tic_koef)
            SELECT m.ticm_PD,
                   m.ticm_nst,
                   m.ticm_pic,
                   m.ticm_sc,
                   m.ticm_app,
                   m.ticm_month,
                   src.fact_sum,
                   src.calc_sum,
                   src.calc_sum_k,
                   NULL, --case when src.koef is not null then m.ticm_min_zp else null end  as x_min_zp,
                   NULL                                             --src.koef
              FROM TMP_INCOME_CALC_months  m
                   LEFT JOIN
                   (  SELECT tics.tics_pd,
                             tics.tics_app,
                             tics.tics_month,
                             SUM (tics.tics_fact_sum)    fact_sum,
                             SUM (tics.tics_calc_sum)    calc_sum,
                             MAX (tics.tics_koef)        koef,
                             SUM (
                                 CASE
                                     WHEN tics_tp = 3
                                     THEN
                                         tics_calc_sum / 82 * 100
                                     ELSE
                                         tics_calc_sum
                                 END)                    AS calc_sum_k
                        FROM TMP_INCOME_CALC_SRC tics
                    GROUP BY tics.tics_pd, tics.tics_app, tics.tics_month)
                   SRC
                       ON     m.ticm_pd = src.tics_pd
                          AND m.ticm_month = src.tics_month
                          AND m.ticm_app = src.tics_app;

        /*При призначенні допомоги, на етапі розрахунку доходів в "Дані помісячного розрахунку" для кожного учасника звернення,
        в стовпчику "Cума розрахована" розбивати загальну суму для розрахунку на рівні частини (на відповідну кількість місяців).*/
        UPDATE tmp_income_calc l
           SET (l.tic_fact_sum, l.tic_calc_sum) =
                   (SELECT AVG (NVL (tic_fact_sum, 0)),
                           AVG (NVL (tic_calc_sum, 0))
                      FROM tmp_income_calc ll
                     WHERE ll.tic_pd = l.tic_pd AND ll.tic_app = l.tic_app)
         WHERE l.tic_nst IN (268, 275);

        --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
        --RETURN;

        --Після того як за даними декларації, обмінів, довідок, ручного вводу для кожного із учасників звернення за кожен місяць розраховано
        --суму, необхідно визначити періоди, у яких необхідно враховувати суму 0,5 мінімальної з/п:
        --1. 0,5 мінімальної з/п за місяць розраховувати для тих осіб, у яких в Анкеті зазначено «Не працює» та «Працездатний» та
        --    розрахований дохід=0 або «пусто» або менше ніж 0,5 мінімальної з/п, крім місяців, у яких в осіб, є один із видів допомог:
        --    «Пенсія», де сума для розрахунку<>0,
        --   «Допомога по безробіттю»,  де сума для розрахунку <>0,
        --   «Стипендія», де сума для розрахунку <>0,
        --   «Допомога», де сума для розрахунку <>0,
        --   «Строкова військова служба», де сума<>0,
        --   «Соціальна стипендія», де сума для розрахунку =0.
        --   «Соціальна виплата (допомога), яка не враховується для розрахунку», де сума для розрахунку = 0
        UPDATE tmp_income_calc tic
           SET (tic.tic_koef, tic.tic_min_zp, tic.tic_calc_sum) =
                   (SELECT 0.5, m.ticm_min_zp, m.ticm_min_zp * 0.5
                      FROM TMP_INCOME_CALC_months m
                     WHERE     m.ticm_pd = tic.tic_pd
                           AND m.ticm_month = tic.tic_month
                           AND m.ticm_app = tic.tic_app)
         WHERE     tic.tic_nst IN (267, 249, 664)
               AND NOT EXISTS
                       (SELECT m.ticm_min_zp
                          FROM TMP_INCOME_CALC_months m
                         WHERE     m.ticm_pd = tic.tic_pd
                               AND m.ticm_month = tic.tic_month
                               AND m.ticm_app = tic.tic_app
                               AND m.ticm_nst = 249
                               AND m.ticm_vpo = 'A')
               AND NVL (tic.tic_calc_sum_koef, 0) <
                     0.5
                   * (SELECT m.ticm_min_zp
                        FROM TMP_INCOME_CALC_months m
                       WHERE     m.ticm_pd = tic.tic_pd
                             AND m.ticm_month = tic.tic_month
                             AND m.ticm_app = tic.tic_app)
               AND (    (SELECT NVL (SUM (NVL (tics.tics_calc_sum, 0)), 0)    calc_sum
                           FROM TMP_INCOME_CALC_SRC tics
                          WHERE     tic.tic_pd = tics.tics_pd
                                AND tic.tic_month = tics.tics_month
                                AND tic.tic_app = tics.tics_app
                                --and tic.tic_pd = tics.ticm_pd
                                --and tic.tic_sc = tics.ticm_sc
                                AND tics.tics_tp IN (1, -- «Пенсія», де сума для розрахунку<>0,
                                                     21, -- «Допомога по безробіттю»,  де сума для розрахунку <>0,
                                                     4, --  «Стипендія», де сума для розрахунку <>0,
                                                     6, --  «Допомога», де сума для розрахунку <>0,
                                                     25) -- «Строкова військова служба», де сума<>0,
                                                        ) =
                        0
                    AND NOT EXISTS
                            (SELECT 1
                               FROM TMP_INCOME_CALC_SRC tics
                              WHERE     tic.tic_pd = tics.tics_pd
                                    AND tic.tic_month = tics.tics_month
                                    AND tic.tic_app = tics.tics_app
                                    AND tics.tics_tp IN ('28', '36')) -- «Соціальна стипендія», де сума для розрахунку =0.
                                                                     )
               AND NOT EXISTS
                       (SELECT 1
                          FROM TABLE (api$Anketa.Get_Anketa) Ank
                         WHERE                            --Ank.app_id=tic_app
                                   Ank.pd_id = tic_pd
                               AND Ank.app_sc = tic_sc
                               AND (   Ank.NotWorkable = 'T' --Не Працездатний
                                    OR NVL (
                                           TRUNC (
                                                 MONTHS_BETWEEN (
                                                     SYSDATE,
                                                     Ank.birthday)
                                               / 12,
                                               0),
                                           -1) BETWEEN 0
                                                   AND 18
                                    OR NVL (
                                           TRUNC (
                                                 MONTHS_BETWEEN (
                                                     SYSDATE,
                                                     Ank.birthday)
                                               / 12,
                                               0),
                                           -1) >=
                                       60
                                    OR (    API$CALC_RIGHT.get_docx_string (
                                                Ank.pd_id,
                                                Ank.app_sc,
                                                98,
                                                690,
                                                calc_dt,
                                                'O') IN ('D', 'U')
                                        AND NVL (
                                                TRUNC (
                                                      MONTHS_BETWEEN (
                                                          SYSDATE,
                                                          Ank.birthday)
                                                    / 12,
                                                    0),
                                                -1) >
                                            18))) --Улучшение #73484 2021.11.25
               AND NOT EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC t21
                         WHERE     t21.TICS_TP = 21
                               AND t21.tics_pd = tic.tic_pd
                               AND t21.tics_app = tic.tic_app
                               AND t21.tics_month > tic.tic_month
                               AND tic.tic_fact_sum = 0) --92828  Не враховувати дохід з DIC_CODE=3 (заробітна плата) для тих, хто отримував допомогу по безробіттю під час карантину для послуг з Ід=249 і 267
               AND NOT EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC t21
                         WHERE     t21.TICS_BD = 1
                               AND t21.tics_pd = tic.tic_pd
                               AND t21.tics_app = tic.tic_app
                               AND t21.tics_month = tic.tic_month)     --92828
               AND NOT EXISTS
                       (SELECT 1
                          FROM TMP_INCOME_CALC_SRC tics
                         WHERE     tic.tic_pd = tics.tics_pd
                               AND tic.tic_month = tics.tics_month
                               AND tic.tic_app = tics.tics_app
                               AND (   tics.tics_tp IN ('38',
                                                        '39',        /*'40',*/
                                                        '41',
                                                        '42',
                                                        '43',
                                                        '44',
                                                        '45',
                                                        '46',
                                                        '47',
                                                        '48',
                                                        '49',
                                                        '50',
                                                        '51',
                                                        '52',
                                                        '53',
                                                        '54',
                                                        '55')
                                    OR     tics.tics_tp IN ('40')
                                       AND tics.tics_use_tp = 'STO' --'NOT_TP_42'
                                                                   )) -- #108734 НЕ застосовувати коефіцієнт 0,5, у місяцях, у яких в осіб є вид допомоги, який зазначений як в цьому рядку
                                                                     /*AND NOT EXISTS (SELECT COUNT(x_month)
                                                                                     FROM (SELECT t_.tics_month AS x_month,
                                                                                                  SUM(CASE t_.tics_esv_min WHEN 'T' THEN 1 ELSE 0 END) AS Is_esv_min
                                                                                           FROM TMP_INCOME_CALC_SRC t_
                                                                                           WHERE t_.tics_pd = tic.tic_pd
                                                                                             AND t_.tics_app = tic.tic_app
                                                                                           GROUP BY t_.tics_month
                                                                                          )
                                                                                     WHERE Is_esv_min > 0
                                                                                     HAVING COUNT(x_month) >= 3
                                                                                    )*/
                                                                      -- #94444 Не застосовувати коефіцієнт 0,5 у випадку сплати ЄСВ за 3 місяці під час розрахунку доходів (для послуг з Ід=249 і 267)
                        -- #95807 Відмінити зміни зроблені згідно задачі 94444
        ;


        --1.5.  0,25 розміру мінімальної заробітної плати, - для осіб,   у яких:
        --розрахований дохід=0 або «пусто»
        --та вік >= 18 років
        --та наявний документ "Довідка про навчання", у яких в атрибуті форма навчання зазначено "денна" або "дуальна" формою

        UPDATE tmp_income_calc tic
           SET (tic.tic_koef, tic.tic_min_zp, tic.tic_calc_sum) =
                   (SELECT 0.25, m.ticm_min_zp, m.ticm_min_zp * 0.25
                      FROM TMP_INCOME_CALC_months m
                     WHERE     m.ticm_pd = tic.tic_pd
                           AND m.ticm_month = tic.tic_month
                           AND m.ticm_app = tic.tic_app)
         WHERE     tic.tic_nst IN (267, 249, 664)
               AND NVL (tic.tic_calc_sum, 0) = 0
               AND NOT (tic.tic_nst = 249 AND NVL (tic.tic_fact_sum, 0) > 0)
               AND NOT EXISTS
                       (SELECT m.ticm_min_zp
                          FROM TMP_INCOME_CALC_months m
                         WHERE     m.ticm_pd = tic.tic_pd
                               AND m.ticm_month = tic.tic_month
                               AND m.ticm_app = tic.tic_app
                               AND m.ticm_nst = 249
                               AND m.ticm_vpo = 'A')
               AND EXISTS
                       (SELECT 1
                          FROM TABLE (api$Anketa.Get_Anketa) Ank
                         WHERE     Ank.pd_id = tic_pd
                               AND Ank.app_sc = tic_sc
                               AND API$CALC_RIGHT.get_docx_string (
                                       Ank.pd_id,
                                       Ank.app_sc,
                                       98,
                                       690,
                                       calc_dt,
                                       'O') IN ('D', 'U')
                               --AND nvl(trunc(months_between (tic_month, Ank.birthday )/12,0),-1) >= 18
                               AND Ank.AgeYear >= 18) --Улучшение #88230  2023.06.17
                                                     ;



        --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
        --RETURN;

        --2. 0,5 мінімальної з/п за місяць розраховувати для тих осіб, які в Анкеті зазначені як особа,
        --    яка здійснює догляд за дитиною до 6-ти річного віку в період догляду за дитиною до 6 років за даними довідки,
        ---   якщо доходи в цей період =0 або пусто.
        UPDATE tmp_income_calc tic
           SET tic.tic_koef = 0.5,
               tic.tic_min_zp =
                   (SELECT m.ticm_min_zp
                      FROM TMP_INCOME_CALC_months m
                     WHERE     m.ticm_pd = tic.tic_pd
                           AND m.ticm_month = tic.tic_month
                           AND m.ticm_app = tic.tic_app)
         WHERE     API$APPEAL.get_doc_string (tic_app,
                                              605,
                                              654,
                                              'F') = 'T' --Доглядає за дитиною до 6-ти років
               AND tic.tic_nst IN (267, 249, 664)
               AND tic.tic_calc_sum = 0
               AND API$APPEAL.get_doc_string (tic_app, 10029, 875)
                       IS NOT NULL
               AND API$APPEAL.get_doc_string (tic_app, 10029, 876)
                       IS NOT NULL
               AND tic.tic_month BETWEEN API$APPEAL.get_doc_string (tic_app,
                                                                    10029,
                                                                    875)
                                     AND API$APPEAL.get_doc_string (tic_app,
                                                                    10029,
                                                                    876)
               AND NOT EXISTS
                       (SELECT m.ticm_min_zp
                          FROM TMP_INCOME_CALC_months m
                         WHERE     m.ticm_pd = tic.tic_pd
                               AND m.ticm_month = tic.tic_month
                               AND m.ticm_app = tic.tic_app
                               AND m.ticm_nst = 249
                               AND m.ticm_vpo = 'A');

        UPDATE tmp_income_calc tic
           SET tic.tic_calc_sum = tic.tic_min_zp * tic.tic_koef
         WHERE NVL (tic.tic_koef, 0) != 0 AND tic.tic_nst IN (267, 249, 664);



        --Видаляємо з деталей розрахунку непотрібні записи (наприклад, користувач зняв позначку pis_is_use
        DELETE FROM pd_income_detail
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_income_calc
                          WHERE pid_pic = tic_pic)             /*
AND NOT EXISTS (SELECT 1
        FROM tmp_income_calc
        WHERE pid_pic = tic_pic
         AND pid_app = tic_app
         AND pid_month = tic_month)*/
                                                  ;

        --Оновлюємо/пишемо в таблицю деталей розрахунку необхідні записи
        MERGE INTO pd_income_detail
             USING (SELECT 0                AS x_id,
                           tic_pic          AS x_pic,
                           app_sc           AS x_sc,
                           tic_app          AS x_app,
                           tic_month        AS x_month,
                           tic_fact_sum     AS x_fact_sum,
                           tic_calc_sum     AS x_calc_sum,
                           tic_min_zp       AS x_min_zp,
                           tic_koef         AS x_koef,
                           'T'              AS x_is_family_member,
                           pic_pin          AS x_pin
                      FROM tmp_income_calc
                           JOIN ap_person
                               ON     tic_app = app_id
                                  AND ap_person.history_status = 'A'
                           JOIN pd_income_calc ON pic_id = tic_pic)
                ON (    pid_pic = x_pic
                    AND pid_app = x_app
                    AND pid_month = x_month)
        WHEN MATCHED
        THEN
            UPDATE SET pid_fact_sum = x_fact_sum,
                       pid_calc_sum = x_calc_sum,
                       pid_min_zp = x_min_zp,
                       pid_koef = x_koef,
                       pid_is_family_member = x_is_family_member,
                       pid_pin = x_pin
        WHEN NOT MATCHED
        THEN
            INSERT     (pid_id,
                        pid_pic,
                        pid_sc,
                        pid_app,
                        pid_month,
                        pid_fact_sum,
                        pid_calc_sum,
                        pid_min_zp,
                        pid_koef,
                        pid_is_family_member,
                        pid_pin)
                VALUES (x_id,
                        x_pic,
                        x_sc,
                        x_app,
                        x_month,
                        x_fact_sum,
                        x_calc_sum,
                        x_min_zp,
                        x_koef,
                        x_is_family_member,
                        x_pin);

        --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
        --RETURN;

        ---Заливаем лог расчёта
        Set_Calc_Log;

        --Розраховуємо показники сукупного доходу 267,249
        UPDATE pd_income_calc
           SET (pic_total_income_6m,
                pic_month_income,
                pic_plot_income_6m,
                pic_members_number,
                pic_member_month_income) =
                   (SELECT SUM (NVL (pid_calc_sum, 0)),
                           ROUND (SUM (NVL (pid_calc_sum, 0)) / 6, 2),
                           0,
                           COUNT (DISTINCT pid_app),
                           CASE
                               WHEN COUNT (DISTINCT pid_app) > 0
                               THEN
                                   ROUND (
                                         ROUND (
                                             SUM (NVL (pid_calc_sum, 0)) / 6,
                                             2)
                                       / COUNT (DISTINCT pid_app),
                                       2)
                               ELSE
                                   0
                           END
                      FROM pd_income_detail
                     WHERE pid_pic = pic_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids, pc_decision
                     WHERE     pic_pd = x_id
                           AND pd_id = x_id
                           AND pic_pd = pd_id
                           AND pd_nst IN (267, 249));

        --Розраховуємо показники сукупного доходу 664
        UPDATE pd_income_calc
           SET (pic_total_income_6m,
                pic_month_income,
                pic_plot_income_6m,
                pic_members_number,
                pic_member_month_income) =
                   (SELECT SUM (NVL (pid_calc_sum, 0)),
                           ROUND (SUM (NVL (pid_calc_sum, 0)) / 3, 2),
                           0,
                           COUNT (DISTINCT pid_app),
                           CASE
                               WHEN COUNT (DISTINCT pid_app) > 0
                               THEN
                                   ROUND (
                                         ROUND (
                                             SUM (NVL (pid_calc_sum, 0)) / 3,
                                             2)
                                       / COUNT (DISTINCT pid_app),
                                       2)
                               ELSE
                                   0
                           END
                      FROM pd_income_detail
                     WHERE pid_pic = pic_id)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pic_pd = x_id)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision
                         WHERE pic_pd = pd_id AND pd_nst IN (664));

        /*
                WHERE EXISTS (SELECT 1
                              FROM tmp_work_ids, pc_decision
                              WHERE pic_pd = x_id
                                AND pic_pd = pd_id
                                AND pd_nst in ( 664));
        */
        --Розраховуємо показники сукупного доходу 268
        UPDATE pd_income_calc
           SET (pic_total_income_6m,
                pic_month_income,
                pic_plot_income_6m,
                pic_members_number,
                pic_member_month_income) =
                   (SELECT SUM (NVL (pid_calc_sum, 0)),
                           ROUND (SUM (NVL (pid_calc_sum, 0)) / 6, 2),
                           0,
                           COUNT (DISTINCT pid_app),
                           CASE
                               WHEN COUNT (DISTINCT pid_app) > 0
                               THEN
                                   ROUND (
                                         ROUND (
                                             SUM (NVL (pid_calc_sum, 0)) / 6,
                                             2)
                                       / COUNT (DISTINCT pid_app),
                                       2)
                               ELSE
                                   0
                           END
                      FROM pd_income_detail
                     WHERE pid_pic = pic_id)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pic_pd = x_id)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision
                         WHERE pic_pd = pd_id AND pd_nst IN (268, 275));

        /*
                WHERE EXISTS (SELECT 1
                              FROM tmp_work_ids, pc_decision
                              WHERE pic_pd = x_id
                                AND pic_pd = pd_id
                                AND pd_nst  IN (268, 275));
        */
        --Розраховуємо показники сукупного доходу 4xx
        UPDATE pd_income_calc
           SET (pic_total_income_6m,
                pic_month_income,
                pic_plot_income_6m,
                pic_members_number,
                pic_member_month_income) =
                   (SELECT SUM (NVL (pid_calc_sum, 0)),
                           ROUND (SUM (NVL (pid_calc_sum, 0)) / 3, 2),
                           0,
                           COUNT (DISTINCT pid_app),
                           CASE
                               WHEN COUNT (DISTINCT pid_app) > 0
                               THEN
                                   ROUND (
                                         ROUND (
                                             SUM (NVL (pid_calc_sum, 0)) / 6,
                                             2)
                                       / COUNT (DISTINCT pid_app),
                                       2)
                               ELSE
                                   0
                           END
                      FROM pd_income_detail
                     WHERE pid_pic = pic_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids, pc_decision
                     WHERE     pic_pd = x_id
                           AND pd_id = x_id
                           AND pic_pd = pd_id
                           AND pd_nst BETWEEN 400 AND 499);

        UPDATE pd_income_calc
           SET pic_member_month_income =
                   pic_month_income / pic_members_number
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids, pc_decision
                     WHERE     pic_pd = x_id
                           AND pd_id = x_id
                           AND pic_pd = pd_id
                           AND pd_nst BETWEEN 400 AND 499);


        UPDATE pd_income_calc
           SET PIC_LIMIT =
                   (SELECT CASE
                               WHEN     pic_member_month_income >
                                        lw.living_wage * 2
                                    AND pic_member_month_income <=
                                        lw.living_wage * 4
                               THEN
                                     pic_member_month_income
                                   - lw.living_wage * 2
                               ELSE
                                   NULL
                           END
                      FROM (SELECT MAX (
                                       CASE
                                           WHEN Ank.AgeYear < 6
                                           THEN
                                               lw.lgw_6year_sum
                                           WHEN Ank.AgeYear < 18
                                           THEN
                                               lw.lgw_18year_sum
                                           WHEN    Ank.Workable = 'F'
                                                OR Ank.NotWorkable = 'T'
                                           THEN
                                               lw.lgw_work_unable_sum
                                           ELSE
                                               lw.lgw_work_able_sum
                                       END)    AS living_wage
                              FROM TABLE (api$Anketa.Get_Anketa)  Ank
                                   JOIN uss_ndi.v_ndi_living_wage lw
                                       ON     Ank.calc_dt >= lw.lgw_start_dt
                                          AND (   Ank.calc_dt <=
                                                  lw.lgw_stop_dt
                                               OR lw.lgw_stop_dt IS NULL)
                                   JOIN pc_decision pd ON pd.pd_id = pic_pd
                                   JOIN personalcase pc
                                       ON     pc_id = pd_pc
                                          AND pc_sc = ank.app_sc
                             WHERE     Ank.pd_id = pic_pd
                                   AND lw.history_status = 'A') lw)
         WHERE     EXISTS
                       (SELECT 1
                          FROM pc_decision
                         WHERE pic_pd = pd_id AND pd_nst BETWEEN 400 AND 499)
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pic_pd = x_id);



        TOOLS.add_message (g_messages,
                           'W',
                           'Розрахунок сукупного доходу завершено!!');


        FOR xx IN (SELECT x_id FROM tmp_work_ids)
        LOOP
            API$PC_DECISION.write_pd_log (xx.x_id,
                                          l_hs,
                                          'R0',
                                          CHR (38) || '14',
                                          NULL);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    --=======================================--
    --  Розрахунок доходу для акту
    --=======================================--
    PROCEDURE calc_income_for_at (p_mode           INTEGER, --1=з p_at_id, 2=з таблиці tmp_work_ids
                                  p_at_id          act.at_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR)
    IS
        l_cnt   INTEGER;
        l_hs    histsession.hs_id%TYPE;
    BEGIN
        gLogSesID := TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS');
        g_messages.delete;

        IF p_mode = 1 AND p_at_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT at_id
                  FROM act
                 WHERE at_id = p_at_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, act
             WHERE x_id = at_id;
        END IF;

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                g_messages,
                'E',
                'В функцію розрахунку середньомісячного доходу не передано ідентифікаторів проектів рішень!');
        ELSIF NOT Check_Income_Date_at
        THEN
            NULL;
        ELSE
            l_hs := TOOLS.GetHistSession;

            --Створюємо запис "розрахунку"
            MERGE INTO at_income_calc
                 USING (SELECT 0           AS x_id,
                               SYSDATE     AS x_dt,
                               at_pc       AS x_pc,
                               at_id       AS x_at
                          FROM tmp_work_ids, act
                         WHERE x_id = at_id)
                    ON (aic_at = x_at)
            WHEN MATCHED
            THEN
                UPDATE SET aic_dt = x_dt, aic_pc = x_pc
            WHEN NOT MATCHED
            THEN
                INSERT     (aic_id,
                            aic_dt,
                            aic_pc,
                            aic_at)
                    VALUES (0,
                            x_dt,
                            x_pc,
                            x_at);

            --Чистимо лог
            DELETE FROM at_income_log
                  WHERE ail_aid IN
                            (SELECT aid.aid_id
                               FROM tmp_work_ids
                                    JOIN at_income_calc aic
                                        ON aic.aic_at = x_id
                                    JOIN at_income_detail aid
                                        ON aid.aid_aic = aic.aic_id);

            -- Заповниму анкети для подальшого використання
            api$anketa.Set_Anketa_AT;

            --NIC_1MONTH_ALG
            --Пишему в тимчасову таблицю розрахунку записи по місяцях
            INSERT INTO TMP_INCOME_CALC_Months (Ticm_AP,
                                                Ticm_Ap_Tp,
                                                Ticm_At,
                                                Ticm_nst,
                                                Ticm_Aic,
                                                Ticm_APP,
                                                Ticm_Sc,
                                                Ticm_Month,
                                                Ticm_Min_Zp)
                WITH
                    periods
                    AS
                        (    SELECT LEVEL     AS x_month
                               FROM DUAL
                         CONNECT BY LEVEL < 13),
                    months
                    AS
                        (SELECT at_id                            AS r_at, /*pd_nst*/
                                400                              AS r_nst,
                                ap_tp                            AS r_ap_tp,
                                at_ap                            AS r_ap,
                                aic_id                           AS r_aic,
                                app_id                           AS r_app,
                                app_sc                           AS r_sc,
                                ap_reg_dt,
                                ADD_MONTHS (
                                    TRUNC (ap_reg_dt, 'MM'),
                                    -(  x_month
                                      + API$PC_DECISION.get_month_start (
                                            ap_reg_dt,
                                            nic_1month_alg)))    AS r_month,
                                ADD_MONTHS (
                                    TRUNC (ap_reg_dt, 'MM'),
                                    -(  1
                                      + API$PC_DECISION.get_month_start (
                                            ap_reg_dt,
                                            nic_1month_alg)))    AS r_month_min_zp
                           FROM tmp_work_ids
                                JOIN Act ON x_id = at_id
                                LEFT JOIN uss_ndi.V_NDI_NST_INCOME_CONFIG
                                    ON nic_nst = 400,        --pd_nst=nic_nst,
                                at_income_calc,
                                periods,
                                appeal,
                                ap_person
                          WHERE     aic_at = at_id
                                AND at_ap = ap_id
                                AND x_month <= nic_months
                                AND at_ap = app_ap
                                AND ap_person.history_status = 'A'
                                AND API$Calc_Income.CheckApp_at (at_id,
                                                                 App_sc,
                                                                 app_tp) =
                                    1)
                SELECT r_ap,
                       r_ap_tp,
                       r_at,
                       r_nst,
                       r_aic,
                       r_app,
                       r_sc,
                       r_month,
                       (SELECT MAX (nmz_month_sum)
                          FROM uss_ndi.v_ndi_min_zp
                         WHERE     r_month_min_zp >= nmz_start_dt
                               AND (   r_month_min_zp <= nmz_stop_dt
                                    OR nmz_stop_dt IS NULL)
                               AND history_status = 'A')    AS nmz_month_sum
                  FROM months;

            --Пишему в тимчасову таблицю розрахунку всі записи, які повинні були розрахуватись
            INSERT INTO TMP_INCOME_CALC_SRC (TICS_AT,
                                             TICS_NST,
                                             TICS_AIC,
                                             TICS_APP,
                                             TICS_MONTH,
                                             TICS_TP,
                                             TICS_MIN_ZP,
                                             TICS_SUM_PFU,
                                             TICS_SUM_DPS,
                                             TICS_SUM_APR,
                                             TICS_SUM_DOV,
                                             TICS_SUM_HND)
                WITH
                    income_src_month
                    AS
                        (SELECT ais_id,
                                ais_at,
                                ais_app,
                                AIS_SRC,
                                AIS_TP,
                                Ais_final_sum,
                                ais_stop_dt,
                                ais_start_dt,
                                NVL (
                                      ais_final_sum
                                    / (  MONTHS_BETWEEN (
                                             TRUNC (ais_stop_dt, 'MM'),
                                             TRUNC (ais_start_dt, 'MM'))
                                       + 1),
                                    0)    AS x_fact_sum
                           FROM at_income_src ais)
                SELECT ticm_at,
                       Ticm_nst,
                       ticm_aic,
                       ticm_app,
                       ticm_month,
                       r_tp,
                       r_min_zp,
                       "TICS_SUM_PFU",
                       "TICS_SUM_DPS",
                       "TICS_SUM_APR",
                       "TICS_SUM_DOV",
                       "TICS_SUM_HND"
                  FROM (  SELECT ticm_at,
                                 Ticm_nst,
                                 ticm_aic,
                                 ticm_app,
                                 ticm_month,
                                 AIS_SRC                       AS r_SRC,
                                 AIS_TP                        AS r_tp,
                                 ticm_min_zp                   AS r_min_zp,
                                 NVL (SUM (x_fact_sum), 0)     AS x_fact_sum
                            FROM TMP_INCOME_CALC_Months
                                 LEFT JOIN income_src_month
                                     ON     ticm_at = ais_at
                                        AND ticm_app = ais_app
                                        AND ticm_month BETWEEN ais_start_dt
                                                           AND ais_stop_dt
                        GROUP BY ticm_at,
                                 Ticm_nst,
                                 ticm_aic,
                                 ticm_app,
                                 ticm_month,
                                 Ticm_Min_Zp,
                                 AIS_SRC,
                                 AIS_TP
                        UNION ALL
                          SELECT ticm_at,
                                 Ticm_nst,
                                 ticm_aic,
                                 ticm_app,
                                 ticm_month,
                                 api_src                       AS r_SRC,
                                 api_tp                        AS r_tp,
                                 ticm_min_zp                   AS r_min_zp,
                                 NVL (SUM (x_fact_sum), 0)     AS x_fact_sum
                            FROM TMP_INCOME_CALC_Months
                                 LEFT JOIN v_ap_income_month
                                     ON     ticm_app = api_app
                                        AND ticm_month BETWEEN api_start_dt
                                                           AND api_stop_dt
                                        AND (   (    Ticm_Ap_Tp = 'V'
                                                 AND NVL (api_use_tp, 'V') IN
                                                         ('V', 'VS'))
                                             OR (    Ticm_Ap_Tp = 'SS'
                                                 AND NVL (api_use_tp, 'V') IN
                                                         ('S', 'VS')))
                        GROUP BY ticm_at,
                                 Ticm_nst,
                                 ticm_aic,
                                 ticm_app,
                                 ticm_month,
                                 Ticm_Min_Zp,
                                 api_src,
                                 api_tp
                        UNION ALL
                        SELECT ticm_at,
                               Ticm_nst,
                               ticm_aic,
                               ticm_app,
                               ticm_month,
                               'DOV'                AS r_SRC,
                               aim_tp               AS r_tp,
                               ticm_min_zp          AS r_min_zp,
                               NVL (aim_sum, 0)     AS x_fact_sum
                          FROM TMP_INCOME_CALC_Months
                               JOIN v_apd_income_month
                                   ON     aim_app = ticm_app
                                      AND aim_month = ticm_month)
                           PIVOT (
                                 MAX (x_fact_sum)
                                 FOR r_src
                                 IN ('PFU' AS "TICS_SUM_PFU",
                                    'DPS' AS "TICS_SUM_DPS",
                                    'APR' AS "TICS_SUM_APR",
                                    'DOV' AS "TICS_SUM_DOV",
                                    'HND' AS "TICS_SUM_HND"))
                 WHERE r_tp IS NOT NULL;

            --Розрахуємо сумму, що потрібно включити до доходу
            UPDATE TMP_INCOME_CALC_SRC tics
               SET (tics.tics_fact_sum,
                    tics.tics_calc_sum,
                    tics.tics_koef,
                    tics.tics_LogTrue,
                    tics.tics_LogFalse) =
                       (SELECT fact_sum,
                               calc_sum,
                               calc_koef,
                               LogTrue,
                               LogFalse
                          FROM TABLE (API$Calc_Income.Calc (TICS_NST,
                                                            TICS_TP,
                                                            TICS_EXCH_TP,
                                                            TICS_SUM_PFU,
                                                            TICS_SUM_DPS,
                                                            TICS_SUM_APR,
                                                            TICS_SUM_DOV,
                                                            TICS_SUM_HND,
                                                            NULL,
                                                            TICS_MIN_ZP,
                                                            TICS_BD,
                                                            'STO')));


            --Пишему в тимчасову помясячну таблицю розрахунку всі записи, які повинні були розрахуватись з розбивкою по видах доходу
            INSERT INTO tmp_income_calc (tic_at,
                                         tic_nst,
                                         tic_aic,
                                         tic_sc,
                                         tic_app,
                                         tic_month,
                                         tic_fact_sum,
                                         tic_calc_sum,
                                         tic_min_zp,
                                         tic_koef)
                SELECT m.ticm_at,
                       m.ticm_nst,
                       m.ticm_aic,
                       m.ticm_sc,
                       m.ticm_app,
                       m.ticm_month,
                       src.fact_sum,
                       src.calc_sum,
                       CASE
                           WHEN src.koef IS NOT NULL THEN m.ticm_min_zp
                           ELSE NULL
                       END    AS x_min_zp,
                       src.koef
                  FROM TMP_INCOME_CALC_months  m
                       LEFT JOIN
                       (  SELECT tics.tics_at,
                                 tics.tics_app,
                                 tics.tics_month,
                                 SUM (tics.tics_fact_sum)     fact_sum,
                                 SUM (tics.tics_calc_sum)     calc_sum,
                                 MAX (tics.tics_koef)         koef
                            FROM TMP_INCOME_CALC_SRC tics
                        GROUP BY tics.tics_at, tics.tics_app, tics.tics_month)
                       SRC
                           ON     m.ticm_at = src.tics_at
                              AND m.ticm_month = src.tics_month
                              AND m.ticm_app = src.tics_app;

            -- #111980
            --Нормативка: НАКАЗ від 17.05.2022 № 150, п. 5.9)
            --для розрахунку середньомісячного сукупного доходу за кожний місяць, у якому відсутні доходи, враховуються:
            --1) один розмір прожиткового мінімуму для непрацездатних осіб, установлений на кінець періоду, за який враховуються доходи:
            -- - для отримувачів соціальних послуг, які не мали доходів або доходи яких були меншими від одного розміру прожиткового мінімуму для непрацездатних осіб, установленого на кінець періоду, за який враховуються доходи
            -- - для отримувачів соціальних послуг, що зареєстровані як безробітні у філії регіонального центру зайнятості та не отримували допомогу по безробіттю
            --2) один розмір мінімальної заробітної плати, встановлений на кінець періоду, за який враховуються доходи:
            -- - для працездатних членів сім’ї отримувача соціальних послуг, які не мали доходів або доходи яких були меншими від одного розміру мінімальної заробітної плати, встановленого на кінець періоду, за який враховуються доходи
            /*
                  Update tmp_income_calc tic Set
                     (tic.tic_koef, tic.tic_min_zp, tic.tic_calc_sum)
                     = (select 1, m.ticm_min_zp, m.ticm_min_zp
                        from TMP_INCOME_CALC_months m
                        where m.ticm_at=tic.tic_at and m.ticm_month=tic.tic_month and m.ticm_sc=tic.tic_sc
                       )
                  where 1=1
                    and EXISTS (select 1, m.ticm_min_zp, m.ticm_min_zp
                                from TMP_INCOME_CALC_months m
                                where m.ticm_at=tic.tic_at
                                  and m.ticm_month=tic.tic_month
                                  and m.ticm_sc=tic.tic_sc
                                  and (tic.tic_calc_sum IS NULL OR tic.tic_calc_sum < m.ticm_min_zp)
                               )
                    AND EXISTS (SELECT 1
                                FROM TABLE(api$Anketa.Get_Anketa_at) Ank
                                WHERE Ank.at_id  = tic_at
                                  AND Ank.app_sc = tic_sc
                                  AND Ank.NotWorkable='F'--Не Працездатний
                                  AND Ank.AGEYEAR BETWEEN 18 AND 59
                               )
                  ;
            */
            --Видаляємо з деталей розрахунку непотрібні записи (наприклад, користувач зняв позначку pis_is_use
            DELETE FROM at_income_detail
                  WHERE EXISTS
                            (SELECT 1
                               FROM tmp_income_calc
                              WHERE aid_aic = tic_aic);

            --Оновлюємо/пишемо в таблицю деталей розрахунку необхідні записи
            MERGE INTO at_income_detail
                 USING (SELECT 0               AS x_id,
                               tic_aic         AS x_aic,
                               app_sc          AS x_sc,
                               tic_app         AS x_app,
                               tic_month       AS x_month,
                               tic_fact_sum    AS x_fact_sum,
                               CASE
                                   WHEN     NVL (tic_calc_sum, 0) <
                                            tic_min_zp
                                        AND API$APPEAL.Get_Doc_String (
                                                app_id,
                                                605,
                                                664,
                                                'F') = 'T'
                                   THEN
                                       tic_min_zp
                                   ELSE
                                       tic_calc_sum
                               END             AS x_calc_sum,
                               tic_min_zp      AS x_min_zp,
                               tic_koef        AS x_koef,
                               'T'             AS x_is_family_member       --,
                          --aic_pin AS x_pin
                          FROM tmp_income_calc
                               JOIN ap_person
                                   ON     tic_app = app_id
                                      AND ap_person.history_status = 'A'
                               LEFT JOIN at_income_calc ON aic_id = tic_pic)
                    ON (    aid_aic = x_aic
                        AND aid_app = x_app
                        AND aid_month = x_month)
            WHEN MATCHED
            THEN
                UPDATE SET aid_fact_sum = x_fact_sum,
                           aid_calc_sum = x_calc_sum,
                           aid_min_zp = x_min_zp,
                           aid_koef = x_koef,
                           aid_is_family_member = x_is_family_member       --,
            --pid_pin = x_pin
            WHEN NOT MATCHED
            THEN
                INSERT     (aid_id,
                            aid_aic,
                            aid_sc,
                            aid_app,
                            aid_month,
                            aid_fact_sum,
                            aid_calc_sum,
                            aid_min_zp,
                            aid_koef,
                            aid_is_family_member                 /*, pid_pin*/
                                                )
                    VALUES (x_id,
                            x_aic,
                            x_sc,
                            x_app,
                            x_month,
                            x_fact_sum,
                            x_calc_sum,
                            x_min_zp,
                            x_koef,
                            x_is_family_member                     /*, x_pin*/
                                              );


            --OPEN p_Messages FOR SELECT * FROM TABLE(g_messages);
            --RETURN;

            ---Заливаем лог расчёта
            Set_Calc_Log_at;

            --Розраховуємо показники сукупного доходу 4xx
            UPDATE at_income_calc
               SET (aic_total_income_6m,
                    aic_month_income,
                    aic_plot_income_6m,
                    aic_members_number,
                    aic_member_month_income) =
                       (SELECT SUM (NVL (aid_calc_sum, 0)),
                               ROUND (SUM (NVL (aid_calc_sum, 0)) / 3, 2),
                               0,
                               COUNT (DISTINCT aid_app),
                               CASE
                                   WHEN COUNT (DISTINCT aid_app) > 0
                                   THEN
                                       ROUND (
                                             ROUND (
                                                   SUM (
                                                       NVL (aid_calc_sum, 0))
                                                 / 6,
                                                 2)
                                           / COUNT (DISTINCT aid_app),
                                           2)
                                   ELSE
                                       0
                               END
                          FROM at_income_detail
                         WHERE aid_aic = aic_id)
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE aic_at = x_id);

            UPDATE at_income_calc
               SET aic_member_month_income =
                       aic_month_income / aic_members_number
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE aic_at = x_id);


            UPDATE at_income_calc
               SET AIC_LIMIT =
                       (SELECT CASE
                                   WHEN     aic_member_month_income >
                                            lw.living_wage * 2
                                        AND aic_member_month_income <=
                                            lw.living_wage * 4
                                   THEN
                                         aic_member_month_income
                                       - lw.living_wage * 2
                                   ELSE
                                       NULL
                               END
                          FROM (SELECT MAX (
                                           CASE
                                               WHEN Ank.AgeYear < 6
                                               THEN
                                                   lw.lgw_6year_sum
                                               WHEN Ank.AgeYear < 18
                                               THEN
                                                   lw.lgw_18year_sum
                                               WHEN    Ank.Workable = 'F'
                                                    OR Ank.NotWorkable = 'T'
                                               THEN
                                                   lw.lgw_work_unable_sum
                                               ELSE
                                                   lw.lgw_work_able_sum
                                           END)    AS living_wage
                                  FROM TABLE (api$Anketa.Get_Anketa_at)  Ank
                                       JOIN uss_ndi.v_ndi_living_wage lw
                                           ON     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                 WHERE     lw.history_status = 'A'
                                       AND Ank.at_id = aic_at) lw)
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE aic_at = x_id);



            TOOLS.add_message (g_messages,
                               'W',
                               'Розрахунок сукупного доходу завершено!!');
        END IF;

        FOR xx IN (SELECT x_id FROM tmp_work_ids)
        LOOP
            API$ACT.write_at_log (xx.x_id,
                                  l_hs,
                                  'R0',
                                  CHR (38) || '14',
                                  NULL);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    PROCEDURE Cleat_At_Income_Calc (p_At_Id IN NUMBER)
    IS
    BEGIN
        DELETE FROM at_income_log
              WHERE EXISTS
                        (SELECT 1
                           FROM at_income_detail
                          WHERE     ail_aid = aid_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM at_income_calc
                                          WHERE     aid_aic = aic_id
                                                AND aic_at = p_At_Id));

        DELETE FROM at_income_detail
              WHERE EXISTS
                        (SELECT 1
                           FROM at_income_calc
                          WHERE aid_aic = aic_id AND aic_at = p_At_Id);

        DELETE FROM at_income_calc
              WHERE aic_at = p_At_Id;
    END;

    --+++++++++++++++++++++
    PROCEDURE Test (id NUMBER, alt_period NUMBER)
    IS
        p_messages   SYS_REFCURSOR;

        PROCEDURE fetch2andclose (rc IN SYS_REFCURSOR)
        IS
            msg_tp        VARCHAR2 (10);
            msg_tp_name   VARCHAR2 (20);
            msg_text      VARCHAR2 (4000);
        BEGIN
            LOOP
                FETCH rc INTO msg_tp, msg_tp_name, msg_text;

                EXIT WHEN rc%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE (
                    msg_tp || '   ' || msg_tp_name || '   ' || msg_text);
            END LOOP;

            CLOSE rc;
        END;
    BEGIN
        IF id IS NULL
        THEN
            calc_income_for_pd (2,
                                NULL,
                                alt_period,
                                p_messages);
        ELSE
            calc_income_for_pd (1,
                                id,
                                alt_period,
                                p_messages);
        END IF;
    --    fetch2andclose ( p_messages);
    --    dbms_output_decision_info(id);
    --    commit;
    END;

    --+++++++++++++++++++++
    PROCEDURE Test_at (id NUMBER)
    IS
        p_messages   SYS_REFCURSOR;

        PROCEDURE fetch2andclose (rc IN SYS_REFCURSOR)
        IS
            msg_tp        VARCHAR2 (10);
            msg_tp_name   VARCHAR2 (20);
            msg_text      VARCHAR2 (4000);
        BEGIN
            LOOP
                FETCH rc INTO msg_tp, msg_tp_name, msg_text;

                EXIT WHEN rc%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE (
                    msg_tp || '   ' || msg_tp_name || '   ' || msg_text);
            END LOOP;

            CLOSE rc;
        END;
    BEGIN
        IF id IS NULL
        THEN
            calc_income_for_at (2, NULL, p_messages);
        ELSE
            calc_income_for_at (1, id, p_messages);
        END IF;

        fetch2andclose (p_messages);
    --    dbms_output_decision_info(id);
    --    commit;
    END;
--+++++++++++++++++++++


END API$Calc_Income;
/