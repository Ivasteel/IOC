/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$CALENDAR
IS
    -- Author  : OLEKSII
    -- Created : 05.11.2023 20:08:02
    -- Purpose :


    TYPE r_AT_CALENDAR IS RECORD
    (
        ATC_ID                 AT_CALENDAR.ATC_ID%TYPE, --Ід запису календаря виконання плану
        ATC_AT                 AT_CALENDAR.ATC_AT%TYPE, --Ід рішення/договору/акту
        ATC_ATIP               AT_CALENDAR.ATC_ATIP%TYPE, --Ід заходу щодо надання соціальної послуги
        ATC_DESC               AT_CALENDAR.ATC_DESC%TYPE,
        ATC_START_DT           AT_CALENDAR.ATC_START_DT%TYPE,              --З
        ATC_STOP_DT            AT_CALENDAR.ATC_STOP_DT%TYPE,              --По
        ATC_IS_KM_OK           AT_CALENDAR.ATC_IS_KM_OK%TYPE, --Відмітка виконання заходу від КМ
        ATC_KM_NOTES           AT_CALENDAR.ATC_KM_NOTES%TYPE,    --Примітки КМ
        ATC_IS_PERSON_OK       AT_CALENDAR.ATC_IS_PERSON_OK%TYPE, --Відмітка виконання заходу від Отримувача
        ATC_PERSON_NOTES       AT_CALENDAR.ATC_PERSON_NOTES%TYPE, --Примітки Отримувача
        ATC_ATD_SIGN_KM        AT_CALENDAR.ATC_ATD_SIGN_KM%TYPE, --Ід скану підпису КМ
        ATC_ATD_SIGN_PERSON    AT_CALENDAR.ATC_ATD_SIGN_PERSON%TYPE, --Ід скану підпису особи-отримувача
        HISTORY_STATUS         AT_CALENDAR.HISTORY_STATUS%TYPE, --history_status
        ATC_HS_INS             AT_CALENDAR.ATC_HS_INS%TYPE,  --Сесія створення
        ATC_HS_DEL             AT_CALENDAR.ATC_HS_DEL%TYPE,  --Сесія видалення
        ATC_HS_KM_OK           AT_CALENDAR.ATC_HS_KM_OK%TYPE, --Сесія підтвердження виконання КМ
        ATC_HS_PERSON_OK       AT_CALENDAR.ATC_HS_PERSON_OK%TYPE, --Сесія підтвердження виконання Отримувачем
        ATC_SC                 AT_CALENDAR.ATC_SC%TYPE,
        ATC_CU                 AT_CALENDAR.ATC_CU%TYPE,
        ATC_RNSPM              AT_CALENDAR.ATC_RNSPM%TYPE,
        ATC_SRC                AT_CALENDAR.ATC_SRC%TYPE,
        New_Id                 NUMBER,
        Deleted                NUMBER
    );

    --TYPE t_AT_CALENDAR IS TABLE OF r_AT_CALENDAR;

    TYPE r_at_nst IS RECORD
    (
        x_id     at_individual_plan.atip_id%TYPE,
        x_nst    at_individual_plan.atip_nst%TYPE
    );

    TYPE t_at_nst IS TABLE OF r_at_nst;

    --====================================================--
    TYPE r_Message IS RECORD
    (
        Msg_Tp         VARCHAR2 (10),
        Msg_Tp_Name    VARCHAR2 (20),
        Msg_Text       VARCHAR2 (4000)
    );

    TYPE t_Messages IS TABLE OF r_Message;

    g_Messages   t_Messages;

    --====================================================--
    -- Перелік подій по ОСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_Rc (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              res_cur         OUT SYS_REFCURSOR);

    --====================================================--
    -- Перелік подій НСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_Pr (p_owner_id   IN     NUMBER,
                              p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_cu_id      IN     NUMBER DEFAULT NULL,
                              res_cur         OUT SYS_REFCURSOR);

    --====================================================--
    -- Перелік подій КМ
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_cm (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_at_id      IN     NUMBER,
                              -- p_fb_num IN VARCHAR2,
                              res_cur         OUT SYS_REFCURSOR);

    --====================================================--
    -- Перегляд внесеної інформації щодо підтвердження надання соціальної послуги відповідно до укладеного договору в кабінеті ОСП
    --   Фільтри пошуку
    --1) Дата індивідуального плану з
    --2) Дата індивідуального плану по
    --3) Назва соціальної послуги ( nst_id за  uss_ndi.v_ndi_service_type)
    --4) Дата надання соціальної послуги з
    --5) Дата надання соціальної послуги по
    --====================================================--
    PROCEDURE get_journal_Rc_Ok (p_atc_dt_start    IN     DATE,
                                 p_atc_dt_stop     IN     DATE,
                                 p_ATIP_nst        IN     NUMBER,
                                 p_ATIP_dt_start   IN     DATE,
                                 p_ATIP_dt_stop    IN     DATE,
                                 res_cur              OUT SYS_REFCURSOR);

    --====================================================--
    --Перегляд внесеної інформації щодо підтвердження надання соціальної послуги відповідно до укладеного договору в кабінеті НСП
    --   Фільтри пошуку
    --0) id ОСП
    --1) Дата індивідуального плану з
    --2) Дата індивідуального плану по
    --3) Назва соціальної послуги ( nst_id за  uss_ndi.v_ndi_service_type)
    --4) Дата надання соціальної послуги з
    --5) Дата надання соціальної послуги по
    --====================================================--
    PROCEDURE get_journal_Pr_Ok (
        p_owner_id        IN     NUMBER,
        p_atc_dt_start    IN     DATE,
        p_atc_dt_stop     IN     DATE,
        p_ATIP_nst        IN     NUMBER,
        p_ATIP_dt_start   IN     DATE,
        p_ATIP_dt_stop    IN     DATE,
        p_cu_id           IN     NUMBER DEFAULT NULL,
        res_cur              OUT SYS_REFCURSOR);

    --====================================================--
    -- Перегляд інформації щодо підтвердженного наданя послуг по договору
    --   Фільтри пошуку
    --1) id договору
    --====================================================--
    PROCEDURE get_journal_service_ok (p_at_id   IN     NUMBER,
                                      res_cur      OUT SYS_REFCURSOR);

    --====================================================--
    --   Збереження інформації Календар виконання індивідуального плану по договору
    --====================================================--
    PROCEDURE Save_AT_CALENDAR (
        p_ATC_ID                    AT_CALENDAR.ATC_ID%TYPE,
        p_ATC_AT                    AT_CALENDAR.ATC_AT%TYPE,
        p_ATC_ATIP                  AT_CALENDAR.ATC_ATIP%TYPE,
        p_ATC_DESC                  AT_CALENDAR.ATC_DESC%TYPE,
        p_ATC_START_DT              AT_CALENDAR.ATC_START_DT%TYPE,
        p_ATC_STOP_DT               AT_CALENDAR.ATC_STOP_DT%TYPE,
        p_ATC_IS_KM_OK              AT_CALENDAR.ATC_IS_KM_OK%TYPE,
        p_ATC_KM_NOTES              AT_CALENDAR.ATC_KM_NOTES%TYPE,
        p_ATC_ATD_SIGN_KM           AT_CALENDAR.ATC_ATD_SIGN_KM%TYPE,
        p_ATC_ATD_SIGN_PERSON       AT_CALENDAR.ATC_ATD_SIGN_PERSON%TYPE,
        p_HISTORY_STATUS            AT_CALENDAR.HISTORY_STATUS%TYPE,
        p_ATC_SC                    AT_CALENDAR.ATC_SC%TYPE,
        p_ATC_CU                    AT_CALENDAR.ATC_CU%TYPE,
        p_ATC_RNSPM                 AT_CALENDAR.ATC_RNSPM%TYPE,
        p_ATC_SRC                   AT_CALENDAR.ATC_SRC%TYPE,
        p_New_Id                OUT NUMBER,
        p_Atc_Del_Reason            AT_CALENDAR.ATC_DEL_REASON%TYPE DEFAULT NULL);

    -- Запис календарю.
    PROCEDURE get_card (p_atc_id IN NUMBER, res_cur OUT SYS_REFCURSOR);


    FUNCTION Get_At_Ip_Name (p_At_Id      IN NUMBER,
                             p_is_error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2;

    -- список іп по іду договору
    PROCEDURE Get_IP_By_TCTR (p_atc_id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    --====================================================--
    --Для обраної події підтвердити надання соціальної послуги, заповнивши певні атрибути
    --0) id запису календаря
    --1) відмітки ОСП
    --3) Помилки, якщо є
    --====================================================--
    PROCEDURE Set_Ok_Rc (p_Atc_Id         IN     NUMBER,
                         p_person_notes   IN     VARCHAR2,
                         p_Messages          OUT SYS_REFCURSOR);

    --====================================================--
    --Для обраної події вказати не надання послуги.
    --0) id запису календаря
    --1) відмітки ОСП
    --3) Помилки, якщо є
    --====================================================--
    PROCEDURE Set_Ref_Rc (p_Atc_Id         IN     NUMBER,
                          p_person_notes   IN     VARCHAR2,
                          p_Messages          OUT SYS_REFCURSOR);

    --====================================================--
    --
    --====================================================--
    PROCEDURE Init_CALENDAR (p_ip_id NUMBER);

    PROCEDURE Init_Calendar_PDSP (p_at_id NUMBER);
END CMES$CALENDAR;
/


GRANT EXECUTE ON USS_ESR.CMES$CALENDAR TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$CALENDAR TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$CALENDAR TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$CALENDAR TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$CALENDAR
IS
    Pkg    VARCHAR2 (50) := 'CMES$CALENDAR';
    g_13   VARCHAR2 (10) := CHR (13) || CHR (10);


    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    --====================================================--
    PROCEDURE LOG (p_src              VARCHAR2,
                   p_regular_params   VARCHAR2,
                   p_obj_tp           VARCHAR2 DEFAULT NULL,
                   p_obj_id           NUMBER DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        BEGIN
            l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        tools.LOG (
            Pkg || '.' || UPPER (p_src),
            p_obj_tp,
            p_obj_id,
               'cu_Id='
            || l_Cu_Id
            || CHR (13)
            || CHR (10)
            || 'sc_Id='
            || l_Sc_Id
            || CHR (13)
            || CHR (10)
            || p_regular_params);
    END;

    PROCEDURE logS (p_src VARCHAR2, p_regular_params VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        BEGIN
            l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        tools.logSes (
            Pkg || '.' || UPPER (p_src),
               'cu_Id='
            || l_Cu_Id
            || CHR (13)
            || CHR (10)
            || 'sc_Id='
            || l_Sc_Id
            || CHR (13)
            || CHR (10)
            || p_regular_params);
    END;

    --====================================================--
    PROCEDURE Add_Message (p_Msg_Text      IN VARCHAR2,
                           p_Msg_Tp        IN VARCHAR2,
                           p_Msg_Tp_Name   IN VARCHAR2)
    IS
        l_Msg   r_Message;
    BEGIN
        l_Msg.Msg_Text := p_Msg_Text;
        l_Msg.Msg_Tp := p_Msg_Tp;
        l_Msg.Msg_Tp_Name := p_Msg_Tp_Name;
        g_Messages.EXTEND ();
        g_Messages (g_Messages.COUNT) := l_Msg;
    END;

    --====================================================--
    PROCEDURE Add_Warning (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        Add_Message (p_Msg_Text, 'W', 'Попередження');
    END;

    --====================================================--
    PROCEDURE Add_Error (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        Add_Message (p_Msg_Text, 'E', 'Помилка');
    END;

    --====================================================--
    FUNCTION Error_Exists
        RETURN BOOLEAN
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM TABLE (g_Messages)
         WHERE Msg_Tp IN ('F', 'E');

        RETURN l_Result = 1;
    END;

    --====================================================--
    --   Парсинг
    --====================================================--
    FUNCTION Parse (p_Type_Name      IN VARCHAR2,
                    p_Clob_Input     IN BOOLEAN DEFAULT TRUE,
                    p_Has_Root_Tag   IN BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Type2xmltable (Pkg,
                              p_Type_Name,
                              TRUE,
                              p_Clob_Input,
                              p_Has_Root_Tag);
    END;

    --====================================================--
    --   Парсинг Календар
    --====================================================--
    FUNCTION Parse_CALENDAR (p_Xml IN CLOB)
        RETURN r_AT_CALENDAR
    IS
        l_Result   r_AT_CALENDAR;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('t_AT_CALENDAR')
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу Календар виконання індивідуального плану по договору: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --====================================================--
    --   Збереження інформації Календар виконання індивідуального плану по договору
    --====================================================--
    PROCEDURE Save_AT_CALENDAR (
        p_ATC_ID                    AT_CALENDAR.ATC_ID%TYPE,
        p_ATC_AT                    AT_CALENDAR.ATC_AT%TYPE,
        p_ATC_ATIP                  AT_CALENDAR.ATC_ATIP%TYPE,
        p_ATC_DESC                  AT_CALENDAR.ATC_DESC%TYPE,
        p_ATC_START_DT              AT_CALENDAR.ATC_START_DT%TYPE,
        p_ATC_STOP_DT               AT_CALENDAR.ATC_STOP_DT%TYPE,
        p_ATC_IS_KM_OK              AT_CALENDAR.ATC_IS_KM_OK%TYPE,
        p_ATC_KM_NOTES              AT_CALENDAR.ATC_KM_NOTES%TYPE,
        p_ATC_ATD_SIGN_KM           AT_CALENDAR.ATC_ATD_SIGN_KM%TYPE,
        p_ATC_ATD_SIGN_PERSON       AT_CALENDAR.ATC_ATD_SIGN_PERSON%TYPE,
        p_HISTORY_STATUS            AT_CALENDAR.HISTORY_STATUS%TYPE,
        p_ATC_SC                    AT_CALENDAR.ATC_SC%TYPE,
        p_ATC_CU                    AT_CALENDAR.ATC_CU%TYPE,
        p_ATC_RNSPM                 AT_CALENDAR.ATC_RNSPM%TYPE,
        p_ATC_SRC                   AT_CALENDAR.ATC_SRC%TYPE,
        p_New_Id                OUT NUMBER,
        p_Atc_Del_Reason            AT_CALENDAR.ATC_DEL_REASON%TYPE DEFAULT NULL)
    IS
        Curr_rec      AT_CALENDAR%ROWTYPE;
        l_ATC_SC      AT_CALENDAR.ATC_SC%TYPE;
        l_ATC_CU      AT_CALENDAR.ATC_CU%TYPE;
        l_ATC_RNSPM   AT_CALENDAR.ATC_RNSPM%TYPE;
        l_ATC_AT      AT_CALENDAR.ATC_AT%TYPE;
        l_DDL         VARCHAR2 (10);
        l_hs          NUMBER;
        l_Cu_Id       NUMBER;
        l_Sc_Id       NUMBER;
    BEGIN
        --raise_application_error(-20000, 'p_ATC_CU='|| p_ATC_CU || ';p_ATC_SC='||p_ATC_SC);
        Write_Audit ('Save_AT_CALENDARS');
        l_hs := tools.GetHistSession ();
        --І хто це в нас працює?
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        -- Яка операція?
        CASE
            WHEN NVL (p_ATC_ID, -1) <= 0
            THEN
                l_DDL := 'I';
            WHEN NVL (p_ATC_ID, -1) > 0 AND NVL (p_HISTORY_STATUS, 'A') = 'A'
            THEN
                l_DDL := 'U';
            WHEN NVL (p_ATC_ID, -1) > 0 AND NVL (p_HISTORY_STATUS, 'A') = 'H'
            THEN
                l_DDL := 'D';
        END CASE;

        IF l_DDL IN ('U', 'D')
        THEN
            SELECT *
              INTO Curr_rec
              FROM AT_CALENDAR
             WHERE ATC_ID = p_ATC_ID;
        END IF;

        IF NVL (p_ATC_ATIP, -1) > 0 AND NVL (p_ATC_ATIP, -1) <= 0
        THEN
            SELECT MAX (tctr.at_id)
              INTO l_ATC_AT
              FROM at_individual_plan  atip
                   JOIN act ip ON atip_at = ip.at_id
                   JOIN act tctr
                       ON     tctr.at_ap = ip.at_ap
                          AND tctr.at_tp = 'TCTR'
                          AND tctr.at_st = 'DT'
                   JOIN at_service ats
                       ON     ATs.Ats_At = tctr.at_id
                          AND ats.ats_nst = atip.atip_nst
                          AND ats.history_status = 'A'
             WHERE atip.atip_id = p_ATC_ATIP;
        ELSIF                                 /*nvl(p_ATC_ATIP,-1) <= 0 AND */
              NVL (p_ATC_AT, -1) > 0
        THEN
            l_ATC_AT := p_ATC_AT;
        END IF;


        /*
        Для кабінету ОСП додати функції:
        - редагування/внесення змін у існуючі події
        - додання події --- нагадування ОСП самому собі щось зробити (наприклад, зателефонувати КМу)
        - видалення події --- якщо автором її створення є сам ОСП

        Для кабінету НСП додати:
        - розподіл календарів по конкретному кейс - менеджеру
        - додання нової події:
        -- з прив'язкою до договору - для конкретного ОСП + КМа, який веде випадок
        -- без прив'язки до договору - тільки для КМа (наприклад подія медіації)
        */

        IF p_ATC_SRC NOT IN ('PORTAL', 'CMES', 'NSP')
        THEN
            Raise_Application_Error (
                -20000,
                'Параметр p_ATC_SRC повинен бути в (''PORTAL'', ''CMES'', ''NSP'')!');
        ELSIF p_ATC_SRC = 'PORTAL'
        THEN                                                      -- отримувач
            IF l_DDL IN ('I') AND NVL (p_ATC_ATIP, -1) > 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'Надавач може додавати подіі тільки по собі!!');
            ELSIF     l_DDL IN ('D')
                  AND (   curr_rec.atc_src != 'PORTAL'
                       OR (    curr_rec.atc_src = 'PORTAL'
                           AND curr_rec.atc_sc != l_sc_id))
            THEN
                Raise_Application_Error (
                    -20000,
                    'Надавач може видаляти тільки свої подіі!');
            END IF;

            l_ATC_SC := l_Sc_Id;
        ELSIF p_ATC_SRC = 'CMES'
        THEN                                                              --КМ
            l_ATC_SC := P_atc_Sc;
            l_ATC_CU := P_atc_cu;
            l_ATC_RNSPM := P_atc_rnspm;
        ELSIF p_ATC_SRC = 'NSP'
        THEN                                                        -- надавач
            l_ATC_SC := P_atc_Sc;
            l_ATC_CU := P_atc_cu;
            l_ATC_RNSPM := P_atc_rnspm;
        END IF;

        -- Якщо є прив'язка до календарного плану, то працюємо по ній
        IF p_atc_atip IS NOT NULL
        THEN
            SELECT a.at_rnspm, a.at_sc, ip.atip_cu
              INTO l_ATC_RNSPM, l_ATC_SC, l_ATC_CU
              FROM v_AT_INDIVIDUAL_PLAN ip JOIN act a ON a.at_id = ip.atip_at
             WHERE ip.atip_id = p_atc_atip;
        ELSIF l_ATC_AT IS NOT NULL
        THEN
            Api$Act.Check_At_Tp (l_ATC_AT, 'TCTR');

            SELECT a.at_rnspm, a.at_sc, a.at_cu
              INTO l_ATC_RNSPM, l_ATC_SC, l_ATC_CU
              FROM act a
             WHERE a.at_id = l_ATC_AT;
        END IF;

        IF NVL (p_ATC_ID, -1) <= 0
        THEN
            l_hs := tools.GetHistSession ();

            INSERT INTO AT_CALENDAR (ATC_ID,
                                     ATC_AT,
                                     ATC_ATIP,
                                     ATC_START_DT,
                                     ATC_STOP_DT,
                                     ATC_ATD_SIGN_KM,
                                     ATC_ATD_SIGN_PERSON,
                                     HISTORY_STATUS,
                                     ATC_HS_INS,
                                     ATC_SC,
                                     ATC_CU,
                                     ATC_RNSPM,
                                     ATC_SRC,
                                     ATC_DESC)
                 VALUES (0,
                         l_ATC_AT,
                         p_ATC_ATIP,
                         p_ATC_START_DT,
                         p_ATC_STOP_DT,
                         p_ATC_ATD_SIGN_KM,
                         p_ATC_ATD_SIGN_PERSON,
                         'A',
                         l_hs,
                         l_ATC_SC,
                         l_ATC_CU,
                         l_ATC_RNSPM,
                         p_ATC_SRC,
                         p_ATC_DESC)
              RETURNING ATC_ID
                   INTO p_New_Id;
        ELSIF p_HISTORY_STATUS = 'H'
        THEN
            p_New_Id := p_ATC_ID;

            UPDATE AT_CALENDAR t
               SET t.History_Status = 'H',
                   t.atc_hs_del = l_hs,
                   t.atc_del_reason = p_Atc_Del_Reason
             WHERE t.ATC_ID = p_ATC_ID;
        ELSE
            p_New_Id := p_ATC_ID;

            UPDATE AT_CALENDAR t
               SET t.ATC_AT = l_ATC_AT,
                   t.ATC_ATIP = p_ATC_ATIP,
                   t.Atc_Desc = p_ATC_DESC,
                   t.ATC_START_DT = p_ATC_START_DT,
                   t.ATC_STOP_DT = p_ATC_STOP_DT,
                   t.ATC_IS_KM_OK = p_ATC_IS_KM_OK,
                   t.ATC_KM_NOTES = p_ATC_KM_NOTES,
                   --t.ATC_IS_PERSON_OK      = p_ATC_IS_PERSON_OK,
                   --t.ATC_PERSON_NOTES      = p_ATC_PERSON_NOTES,
                   t.ATC_ATD_SIGN_KM = p_ATC_ATD_SIGN_KM,
                   t.ATC_ATD_SIGN_PERSON = p_ATC_ATD_SIGN_PERSON,
                   t.ATC_SC = l_ATC_SC,
                   t.ATC_CU = l_ATC_CU,
                   t.ATC_RNSPM = l_ATC_RNSPM
             WHERE t.ATC_ID = p_ATC_ID;
        END IF;
    END;

    --====================================================--
    --   Збереження інформації Календар виконання індивідуального плану по договору
    --====================================================--
    /*
      PROCEDURE Save_AT_CALENDAR(  p_Atc_ID          AT_CALENDAR.ATC_ID%TYPE,
                                    p_CALENDAR     IN CLOB
                                 ) IS
        l_AT_CALENDAR  CMES$CALENDAR.r_AT_CALENDAR;
        l_hs           NUMBER;
      BEGIN
        Write_Audit('Save_AT_CALENDARS');
        l_hs  := tools.GetHistSession();

        l_AT_CALENDAR := Parse_CALENDAR(p_CALENDAR);

        -- Якщо є прив'язка до календарного плану, то працюємо по ній
        IF l_AT_CALENDAR.atc_atip IS NOT NULL THEN
          SELECT a.at_rnspm, a.at_sc, ip.atip_cu
            INTO l_AT_CALENDAR.ATC_RNSPM, l_AT_CALENDAR.ATC_SC, l_AT_CALENDAR.ATC_CU
          FROM v_AT_INDIVIDUAL_PLAN ip
            JOIN act a ON a.at_id = ip.atip_at
          WHERE ip.atip_id = l_AT_CALENDAR.atc_atip;
        ELSIF l_AT_CALENDAR.atc_at IS NOT NULL THEN
          SELECT a.at_rnspm, a.at_sc, a.at_cu
            INTO l_AT_CALENDAR.ATC_RNSPM, l_AT_CALENDAR.ATC_SC, l_AT_CALENDAR.ATC_CU
          FROM act a
          WHERE a.at_id = l_AT_CALENDAR.atc_at;
        END IF;

        IF l_AT_CALENDAR.Deleted = 1 THEN
          UPDATE AT_CALENDAR t
             SET t.History_Status = 'H',
                 t.atc_hs_del     = l_hs
          WHERE t.ATC_ID = l_AT_CALENDAR.ATC_ID;
        ELSE
          Save_AT_CALENDAR(
              p_ATC_ID                => l_AT_CALENDAR.ATC_ID,
              p_ATC_AT                => l_AT_CALENDAR.ATC_AT,
              p_ATC_ATIP              => l_AT_CALENDAR.ATC_ATIP,
              p_ATC_DESC              => l_AT_CALENDAR.ATC_DESC,
              p_ATC_START_DT          => l_AT_CALENDAR.ATC_START_DT,
              p_ATC_STOP_DT           => l_AT_CALENDAR.ATC_STOP_DT,
              p_ATC_IS_KM_OK          => l_AT_CALENDAR.ATC_IS_KM_OK,
              p_ATC_KM_NOTES          => l_AT_CALENDAR.ATC_KM_NOTES,
              p_ATC_ATD_SIGN_KM       => l_AT_CALENDAR.ATC_ATD_SIGN_KM,
              p_ATC_ATD_SIGN_PERSON   => l_AT_CALENDAR.ATC_ATD_SIGN_PERSON,
              p_HISTORY_STATUS        => l_AT_CALENDAR.HISTORY_STATUS,
              p_ATC_SC                => l_AT_CALENDAR.ATC_SC,
              p_ATC_CU                => l_AT_CALENDAR.ATC_CU,
              p_ATC_RNSPM             => l_AT_CALENDAR.ATC_RNSPM,
              p_ATC_SRC               => l_AT_CALENDAR.ATC_SRC,
              p_New_Id                => l_AT_CALENDAR.New_Id
             );
        END IF;
      END;
    */
    --====================================================--
    -- Перелік подій
    --====================================================--
    PROCEDURE get_journal (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT c.atc_id,
                   c.atc_at,
                   c.atc_atip,
                   c.atc_desc,
                   c.atc_start_dt,
                   c.atc_stop_dt,
                   c.atc_is_km_ok,
                   c.atc_km_notes,
                   c.atc_is_person_ok,
                   c.atc_person_notes,
                   c.atc_atd_sign_km,
                   c.atc_atd_sign_person,
                   c.history_status,
                   c.atc_hs_ins,
                   c.atc_hs_del,
                   c.atc_hs_km_ok,
                   c.atc_hs_person_ok,
                   c.atc_sc,
                   uss_person.api$sc_tools.GET_PIB (c.atc_sc)
                       AS atc_sc_pib,
                   c.atc_cu,
                   Ikis_Rbm.Tools.Getcupib (c.atc_cu)
                       AS atc_cu_pib,
                   c.ATC_SRC,
                   c.atc_rnspm,
                   CASE
                       WHEN c.atc_atip IS NULL THEN 'Календарний план'
                       ELSE 'Довільна подія'
                   END
                       AS atc_src_name,
                   a.at_num,
                   a.at_dt,
                   a.at_sc,
                   uss_person.api$sc_tools.GET_PIB (a.at_sc)
                       AS at_sc_pib,
                   ip.atip_cu,
                   Ikis_Rbm.Tools.Getcupib (ip.atip_cu)
                       AS atip_cu_pib,
                   ip.atip_nst,
                   s.nst_name
                       AS atip_nst_name,
                   ip.atip_place,
                   ip.atip_desc,
                   ip.atip_nsa,
                   na.nsa_name
                       AS atip_nsa_name,
                   ip.atip_nsa_hand_name,
                   ip.atip_start_dt,
                   ip.atip_stop_dt,
                   ai.at_action_start_dt,
                   ai.at_action_stop_dt
              FROM Tmp_Work_Ids  t
                   JOIN AT_calendar c
                       ON c.atc_id = t.x_Id AND c.history_status = 'A'
                   LEFT JOIN v_act a ON a.at_id = c.atc_at             -- TCTR
                   LEFT JOIN v_AT_INDIVIDUAL_PLAN ip
                       ON ip.atip_id = c.atc_atip
                   LEFT JOIN v_act ai ON ai.at_id = ip.atip_at           -- IP
                   LEFT JOIN uss_ndi.v_ndi_service_type s
                       ON s.nst_id = ip.atip_nst
                   LEFT JOIN uss_ndi.v_ndi_nst_activities na
                       ON ip.atip_nsa = na.nsa_id;
    END;

    --====================================================--
    -- Перелік подій по ОСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_Rc (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              res_cur         OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('get_journal_Rc');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        LOG (
            'get_journal_Rc',
               'p_atc_dt_start='
            || p_dt_start
            || g_13
            || 'p_atc_dt_stop='
            || p_dt_stop);


        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM at_calendar c
             WHERE     c.atc_sc = l_Sc_Id
                   AND (p_dt_start IS NULL OR p_dt_start <= c.atc_start_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= c.atc_start_dt);


        get_journal (res_cur);
    END;


    --====================================================--
    -- Перегляд внесеної інформації щодо підтвердження надання соціальної послуги відповідно до укладеного договору в кабінеті ОСП
    --   Фільтри пошуку
    --1) Дата індивідуального плану з
    --2) Дата індивідуального плану по
    --3) Назва соціальної послуги ( nst_id за  uss_ndi.v_ndi_service_type)
    --4) Дата надання соціальної послуги з
    --5) Дата надання соціальної послуги по
    --====================================================--
    PROCEDURE get_journal_Rc_Ok (p_atc_dt_start    IN     DATE,
                                 p_atc_dt_stop     IN     DATE,
                                 p_ATIP_nst        IN     NUMBER,
                                 -- #103120 хочуть фільтр по договору...
                                 p_ATIP_dt_start   IN     DATE,
                                 p_ATIP_dt_stop    IN     DATE,
                                 res_cur              OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('get_journal_Rc_Ok');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);


        LOG (
            'get_journal_Rc_Ok',
               'p_atc_dt_start='
            || p_atc_dt_start
            || g_13
            || 'p_atc_dt_stop='
            || p_atc_dt_stop
            || g_13
            || 'p_ATIP_nst='
            || p_ATIP_nst
            || g_13
            || 'p_ATIP_dt_start='
            || p_ATIP_dt_start
            || g_13
            || 'p_ATIP_dt_stop='
            || p_ATIP_dt_stop);


        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM at_calendar c
             WHERE     c.atc_sc = l_Sc_Id
                   AND c.atc_is_km_ok = 'T'
                   AND c.atc_is_person_ok IS NULL
                   AND (   p_atc_dt_start IS NULL
                        OR p_atc_dt_start <= c.atc_start_dt)
                   AND (   p_atc_dt_stop IS NULL
                        OR p_atc_dt_stop >= c.atc_start_dt)
                   AND (   (p_ATIP_nst IS NULL) -- AND p_ATIP_dt_start IS NULL AND p_ATIP_dt_stop  IS NULL)
                        OR EXISTS
                               (SELECT 1
                                  FROM v_AT_INDIVIDUAL_PLAN  ip
                                       JOIN act a ON a.at_id = ip.atip_at
                                 WHERE     ip.atip_id = c.atc_atip
                                       AND ip.history_status = 'A'
                                       AND (   p_ATIP_nst IS NULL
                                            OR p_ATIP_nst = ip.atip_nst)-- AND (p_ATIP_dt_start IS NULL OR p_ATIP_dt_start <= a.at_action_start_dt)
                                                                        --AND (p_ATIP_dt_stop  IS NULL OR p_ATIP_dt_stop  >= a.at_action_start_dt)
                                                                        ))
                   AND (   (    p_ATIP_dt_start IS NULL
                            AND p_ATIP_dt_stop IS NULL)
                        OR EXISTS
                               (SELECT 1
                                  FROM act a
                                 WHERE     1 = 1
                                       AND a.at_id = c.atc_at
                                       AND (   p_ATIP_dt_start IS NULL
                                            OR p_ATIP_dt_start <= a.at_dt)
                                       AND (   p_ATIP_dt_stop IS NULL
                                            OR p_ATIP_dt_stop >= a.at_dt)));

        get_journal (res_cur);
    END;

    --====================================================--
    -- Перегляд інформації щодо підтвердженного наданя послуг по договору
    --   Фільтри пошуку
    --1) id договору
    --====================================================--
    PROCEDURE get_journal_service_ok (p_at_id   IN     NUMBER,
                                      res_cur      OUT SYS_REFCURSOR)
    IS
    --    l_Cu_Id NUMBER;
    BEGIN
        Write_Audit ('get_journal_service_ok');
        --    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        --    l_Sc_Id := Ikis_Rbm.Tools.GetCuSc(l_Cu_Id);

        LOG ('get_journal_service_ok', 'p_at_id=' || p_at_id);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM at_calendar c
             WHERE     (   EXISTS
                               (SELECT 1
                                  FROM act  TCTR
                                       JOIN at_service ats
                                           ON ats.ats_at = TCTR.at_id
                                       JOIN act a ON a.at_ap = TCTR.at_ap
                                       JOIN v_AT_INDIVIDUAL_PLAN ip
                                           ON     a.at_id = ip.atip_at
                                              AND ip.history_status = 'A'
                                 WHERE     TCTR.at_id = p_at_id
                                       AND TCTR.at_tp = 'TCTR'
                                       AND ip.atip_id = c.atc_atip
                                       AND ip.atip_nst = ats.ats_nst/*
                                                                    UNION ALL
                                                                    SELECT 1
                                                                    FROM  act TCTR
                                                                    JOIN act a ON tctr.at_ap = a.at_ap
                                                                    WHERE TCTR.at_id = p_at_id
                                                                       AND TCTR.at_tp = 'TCTR'
                                                                       AND c.atc_at = a.at_id
                                                                    */
                                                                    )
                        OR c.atc_at = p_at_id)
                   AND c.atc_is_person_ok IN ('T', 'F');

        get_journal (res_cur);
    END;

    --====================================================--
    -- Перелік подій НСП
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_Pr (p_owner_id   IN     NUMBER,
                              p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_cu_id      IN     NUMBER DEFAULT NULL,
                              res_cur         OUT SYS_REFCURSOR)
    IS
    --    l_Cu_Id NUMBER;
    BEGIN
        Write_Audit ('get_journal_Pr');
        --    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        LOG (
            'get_journal_Pr',
               'p_owner_id='
            || p_owner_id
            || g_13
            || 'p_dt_start='
            || p_dt_start
            || g_13
            || 'p_dt_stop='
            || p_dt_stop);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM at_calendar c
             WHERE     c.atc_rnspm = p_owner_id
                   AND c.history_status = 'A'
                   AND (P_Cu_Id IS NULL OR c.atc_cu = P_Cu_Id)
                   AND (p_dt_start IS NULL OR p_dt_start <= c.atc_start_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= c.atc_start_dt);

        get_journal (res_cur);
    END;

    --====================================================--
    --Перегляд внесеної інформації щодо підтвердження надання соціальної послуги відповідно до укладеного договору в кабінеті НСП
    --   Фільтри пошуку
    --0) id ОСП
    --1) Дата індивідуального плану з
    --2) Дата індивідуального плану по
    --3) Назва соціальної послуги ( nst_id за  uss_ndi.v_ndi_service_type)
    --4) Дата надання соціальної послуги з
    --5) Дата надання соціальної послуги по
    --====================================================--
    PROCEDURE get_journal_Pr_Ok (
        p_owner_id        IN     NUMBER,
        p_atc_dt_start    IN     DATE,
        p_atc_dt_stop     IN     DATE,
        p_ATIP_nst        IN     NUMBER,
        -- #103120 хочуть фільтр по договору...
        p_ATIP_dt_start   IN     DATE,
        p_ATIP_dt_stop    IN     DATE,
        p_cu_id           IN     NUMBER DEFAULT NULL,
        res_cur              OUT SYS_REFCURSOR)
    IS
    --    l_Cu_Id NUMBER;
    BEGIN
        Write_Audit ('get_journal_Ok_Pr');
        --    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        LOG (
            'get_journal_Pr_Ok',
               'p_owner_id=    '
            || p_owner_id
            || g_13
            || 'p_atc_dt_start='
            || p_atc_dt_start
            || g_13
            || 'p_atc_dt_stop= '
            || p_atc_dt_stop
            || g_13
            || 'p_ATIP_nst='
            || p_ATIP_nst
            || g_13
            || 'p_ATIP_dt_start='
            || p_ATIP_dt_start
            || g_13
            || 'p_ATIP_dt_stop='
            || p_ATIP_dt_stop
            || g_13
            || 'p_cu_id=    '
            || p_cu_id);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM at_calendar c
             WHERE     EXISTS
                           (SELECT 1
                              FROM act a
                             WHERE     c.atc_at = a.at_id
                                   AND a.at_rnspm = p_owner_id)
                   AND (c.atc_is_km_ok = 'T' OR c.atc_is_person_ok = 'T')
                   AND (P_Cu_Id IS NULL OR c.atc_cu = P_Cu_Id)
                   AND (   p_atc_dt_start IS NULL
                        OR p_atc_dt_start <= c.atc_start_dt)
                   AND (   p_atc_dt_stop IS NULL
                        OR p_atc_dt_stop >= c.atc_start_dt)
                   AND (   (p_ATIP_nst IS NULL) -- AND p_ATIP_dt_start IS NULL AND p_ATIP_dt_stop  IS NULL)
                        OR EXISTS
                               (SELECT 1
                                  FROM v_AT_INDIVIDUAL_PLAN  ip
                                       JOIN act a ON a.at_id = ip.atip_at
                                 WHERE     ip.atip_id = c.atc_atip
                                       AND ip.history_status = 'A'
                                       AND a.at_rnspm = p_owner_id
                                       AND (   p_ATIP_nst IS NULL
                                            OR p_ATIP_nst = ip.atip_nst)--  AND (p_ATIP_dt_start IS NULL OR p_ATIP_dt_start <= a.at_action_start_dt)
                                                                        --   AND (p_ATIP_dt_stop  IS NULL OR p_ATIP_dt_stop  >= a.at_action_start_dt)
                                                                        ))
                   AND (   (    p_ATIP_dt_start IS NULL
                            AND p_ATIP_dt_stop IS NULL)
                        OR EXISTS
                               (SELECT 1
                                  FROM act a                           -- tctr
                                 WHERE     1 = 1
                                       AND a.at_id = c.atc_at
                                       AND (   p_ATIP_dt_start IS NULL
                                            OR p_ATIP_dt_start <= a.at_dt)
                                       AND (   p_ATIP_dt_stop IS NULL
                                            OR p_ATIP_dt_stop >= a.at_dt)));


        get_journal (res_cur);
    END;

    --====================================================--
    -- Перелік подій КМ
    -- 1. Дата подання оцінки з
    -- 2. Дата подання оцінки по
    --====================================================--
    PROCEDURE get_journal_cm (p_dt_start   IN     DATE,
                              p_dt_stop    IN     DATE,
                              p_at_id      IN     NUMBER,
                              --p_fb_num IN VARCHAR2,
                              res_cur         OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('get_journal_cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        LOG (
            'get_journal_cm',
               'p_atc_dt_start='
            || p_dt_start
            || g_13
            || 'p_atc_dt_stop= '
            || p_dt_stop
            || g_13
            || 'p_at_id= '
            || p_at_id);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо події закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT c.atc_id
              FROM At_calendar c
             WHERE     (   c.atc_cu = l_Cu_Id
                        --#108664
                        OR (   EXISTS
                                   (SELECT 1
                                      FROM ikis_rbm.v_cu_users2roles r
                                     WHERE     r.cu2r_cr = 6
                                           AND c.atc_rnspm =
                                               r.cu2r_cmes_owner_id
                                           AND r.cu2r_cu = l_Cu_Id
                                           AND r.history_status = 'A')
                            OR (c.atc_cu IS NULL AND p_at_id IS NOT NULL) --#113118
                                                                         ))
                   AND (p_dt_start IS NULL OR p_dt_start <= c.atc_start_dt)
                   AND (p_dt_stop IS NULL OR p_dt_stop >= c.atc_start_dt)
                   AND (p_at_id IS NULL OR p_at_id = c.atc_at);

        get_journal (res_cur);
    END;

    --====================================================--
    FUNCTION Get_At_Ip_Name (p_At_Id      IN NUMBER,
                             p_is_error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2
    IS
        l_Ndt_Id     NUMBER;
        l_Ndt_Name   Uss_Ndi.v_Ndi_Document_Type.Ndt_Name%TYPE;
    BEGIN
        l_Ndt_Id :=
            Api$act.Define_Print_Form_Ndt (
                p_At_Id   => p_At_Id,
                p_Raise_If_Undefined   =>
                    CASE WHEN p_is_error = 'T' THEN TRUE ELSE FALSE END);

        IF l_Ndt_Id IS NOT NULL
        THEN
            SELECT t.Ndt_Name
              INTO l_Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = l_Ndt_Id;
        END IF;

        RETURN l_Ndt_Name;
    END;

    --====================================================--
    --  ОТРИМАННЯ ПЕРЕЛІКУ IP(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    --====================================================--
    PROCEDURE Get_IP_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   Src.Dic_Name
                       AS At_Src_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Avop,
                   --Ким сформовано індивідуальний план
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Найменування організації
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Індивідуальний план надання соціальної послуги щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Найменування індивідуального плану
                   Get_At_Ip_Name (a.At_Id, 'F')
                       AS At_Ndt_Name,
                   --Послуга
                   Sv.Ats_Nst
                       AS At_Nst,
                   t.Nst_Name
                       AS At_Nst_Name,
                   --Рішення
                   l.Atk_Link_At
                       AS At_Decision
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Ip_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.At_Src = Src.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Service Sv
                       ON a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON Sv.Ats_Nst = t.Nst_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'DECISION';
    END;

    PROCEDURE Get_IP_By_TCTR (p_atc_id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT DISTINCT ip.at_id
              FROM at_individual_plan  atip
                   JOIN act ip ON atip_at = ip.at_id
                   JOIN act tctr
                       ON     tctr.at_ap = ip.at_ap
                          AND tctr.at_tp = 'TCTR'
                          AND tctr.at_st = 'DT'
                   JOIN at_service ats
                       ON     ATs.Ats_At = tctr.at_id
                          AND ats.ats_nst = atip.atip_nst
                          AND ats.history_status = 'A'
             WHERE     tctr.at_id = p_atc_id
                   AND NVL (atip.history_status, 'A') = 'A';

        Get_IP_List (p_Res);
    END;

    -- Запис календарю.
    PROCEDURE get_card (p_atc_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT c.atc_id,
                   c.atc_at,
                   c.atc_atip,
                   c.atc_desc,
                   c.atc_start_dt,
                   c.atc_stop_dt,
                   c.atc_is_km_ok,
                   c.atc_km_notes,
                   c.atc_is_person_ok,
                   c.atc_person_notes,
                   c.atc_atd_sign_km,
                   c.atc_atd_sign_person,
                   c.history_status,
                   c.atc_hs_ins,
                   c.atc_hs_del,
                   c.atc_hs_km_ok,
                   c.atc_hs_person_ok,
                   a.at_num,
                   a.at_dt,
                   c.atc_sc,
                   uss_person.api$sc_tools.GET_PIB (c.atc_sc)
                       AS atc_sc_pib,
                   a.at_sc,
                   uss_person.api$sc_tools.GET_PIB (a.at_sc)
                       AS at_sc_pib,
                   ip.atip_cu,
                   Ikis_Rbm.Tools.Getcupib (ip.atip_cu)
                       AS atip_cu_pib,
                   ip.atip_nst,
                   s.nst_name
                       AS atip_nst_name,
                   ip.atip_place,
                   ip.atip_desc,
                   ip.atip_nsa,
                   na.nsa_name
                       AS atip_nsa_name,
                   ip.atip_nsa_hand_name
              FROM AT_calendar  c
                   LEFT JOIN v_act a ON a.at_id = c.atc_at
                   LEFT JOIN v_AT_INDIVIDUAL_PLAN ip
                       ON ip.atip_id = c.atc_atip
                   LEFT JOIN uss_ndi.v_ndi_service_type s
                       ON s.nst_id = ip.atip_nst
                   LEFT JOIN uss_ndi.v_ndi_nst_activities na
                       ON ip.atip_nsa = na.nsa_id
             WHERE c.atc_id = p_atc_id AND NVL (c.history_status, 'A') = 'A';
    END;

    /*
      PROCEDURE Set_Ok_Cm(p_Atc_Id    IN NUMBER,
                          p_km_notes  IN VARCHAR2,
                          p_Messages OUT SYS_REFCURSOR) IS
        l_Cu_Id NUMBER;
        l_hs    NUMBER;
        l_atip_cu      NUMBER;
        l_atc_is_km_ok VARCHAR2(10);
      BEGIN
        Write_Audit('Set_Ok_Cm');
        g_Messages := t_Messages();
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;


        BEGIN
          SELECT ip.atip_cu, c.atc_is_km_ok
            INTO l_atip_cu, l_atc_is_km_ok
          FROM At_calendar c
          LEFT JOIN v_AT_INDIVIDUAL_PLAN ip ON ip.atip_id = c.atc_atip AND ip.history_status = 'A'
          WHERE c.atc_id = p_Atc_Id;
        EXCEPTION WHEN no_data_found THEN
          Add_Error('Не знайдено запису календаря');
        END;

        IF l_atip_cu != l_Cu_Id THEN
          Add_Error('Запис іншого КМ');
        END IF;

        IF l_atc_is_km_ok = 'T' THEN
          Add_Error('Запис календарю вже підтвержено КМ');
        END IF;

        l_hs := tools.GetHistSession();

        IF NOT Error_Exists THEN
          UPDATE At_calendar c SET
            c.atc_is_km_ok = 'T',
            c.atc_km_notes = p_km_notes,
            c.atc_hs_km_ok = l_hs
          WHERE c.atc_id = p_Atc_Id;
        END IF;


        OPEN p_Messages FOR
          SELECT *
            FROM TABLE(g_Messages) t
           ORDER BY Decode(t.Msg_Tp, 'F', 1, 'E', 1, 2);

      END;
    */

    --====================================================--
    --Для обраної події підтвердити надання соціальної послуги, заповнивши певні атрибути
    --0) id запису календаря
    --1) відмітки ОСП
    --3) Помилки, якщо є
    --====================================================--

    PROCEDURE Set_Ok_Rc (p_Atc_Id         IN     NUMBER,
                         p_person_notes   IN     VARCHAR2,
                         p_Messages          OUT SYS_REFCURSOR)
    IS
        l_Cu_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_hs                 NUMBER;
        l_at_sc              NUMBER;
        l_atc_is_km_ok       VARCHAR2 (10);
        l_atc_is_person_ok   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Ok_Rc');
        g_Messages := t_Messages ();
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        Tools.Start_Log_Ses_Id (p_Src => 'ATC_ID', p_Obj_Id => p_Atc_Id);
        LOG (
            'Set_Ok_Rc',
               'p_Atc_Id='
            || p_Atc_Id
            || g_13
            || 'p_person_notes   ='
            || p_person_notes);

        BEGIN
            SELECT a.at_sc, c.atc_is_km_ok, c.atc_is_person_ok
              INTO l_at_sc, l_atc_is_km_ok, l_atc_is_person_ok
              FROM At_calendar c JOIN v_act a ON a.at_id = c.atc_at
             WHERE c.atc_id = p_Atc_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Add_Error ('Не знайдено запису календаря');
                LOG ('Set_Ok_Rc', 'Не знайдено запису календаря');
        END;

        IF l_at_sc != l_Sc_Id
        THEN
            --      Add_Error('Запис іншого отримувача СП');
            LOG (
                'Set_Ok_Rc',
                   'Запис іншого отримувача СП l_at_sc = '
                || l_at_sc
                || '   l_Sc_Id = '
                || l_Sc_Id);
        END IF;

        IF l_atc_is_km_ok != 'T'
        THEN
            Add_Error ('Запис календарю не підтвержено КМ');
            LOG ('Set_Ok_Rc', 'Запис календарю не підтвержено КМ');
        END IF;

        IF l_atc_is_person_ok = 'T'
        THEN
            Add_Error ('Запис календарю вже підтвержено отримувачем СП');
            LOG ('Set_Ok_Rc',
                 'Запис календарю вже підтвержено отримувачем СП');
        END IF;

        l_hs := tools.GetHistSession ();
        Tools.Stop_Log_Ses_Id ();

        IF NOT Error_Exists
        THEN
            UPDATE At_calendar c
               SET c.atc_is_person_ok = 'T',
                   c.atc_person_notes = p_person_notes,
                   c.atc_hs_person_ok = l_hs
             WHERE c.atc_id = p_Atc_Id;
        END IF;


        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (g_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2);
    END;

    --====================================================--
    --Для обраної події вказати не надання послуги.
    --0) id запису календаря
    --1) відмітки ОСП
    --3) Помилки, якщо є
    --====================================================--

    PROCEDURE Set_Ref_Rc (p_Atc_Id         IN     NUMBER,
                          p_person_notes   IN     VARCHAR2,
                          p_Messages          OUT SYS_REFCURSOR)
    IS
        l_Cu_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_hs                 NUMBER;
        l_at_sc              NUMBER;
        l_atc_is_km_ok       VARCHAR2 (10);
        l_atc_is_person_ok   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Ref_Rc');
        g_Messages := t_Messages ();
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);

        Tools.Start_Log_Ses_Id (p_Src => 'ATC_ID', p_Obj_Id => p_Atc_Id);
        LOG (
            'Set_Ref_Rc',
               'p_Atc_Id='
            || p_Atc_Id
            || g_13
            || 'p_person_notes   ='
            || p_person_notes);

        BEGIN
            SELECT a.at_sc, c.atc_is_km_ok, c.atc_is_person_ok
              INTO l_at_sc, l_atc_is_km_ok, l_atc_is_person_ok
              FROM At_calendar c JOIN v_act a ON a.at_id = c.atc_at
             WHERE c.atc_id = p_Atc_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Add_Error ('Не знайдено запису календаря');
                LOG ('Set_Ref_Rc', 'Не знайдено запису календаря');
        END;

        IF l_at_sc != l_Sc_Id
        THEN
            Add_Error ('Запис іншого отримувача СП');
            LOG ('Set_Ref_Rc', 'Запис іншого отримувача СП');
        END IF;

        IF l_atc_is_km_ok != 'T'
        THEN
            Add_Error ('Запис календарю не підтвержено КМ');
            LOG ('Set_Ref_Rc', 'Запис календарю не підтвержено КМ');
        END IF;

        IF l_atc_is_person_ok = 'T'
        THEN
            Add_Error ('Запис календарю вже підтвержено отримувачем СП');
            LOG ('Set_Ref_Rc',
                 'Запис календарю вже підтвержено отримувачем СП');
        END IF;

        l_hs := tools.GetHistSession ();
        Tools.Stop_Log_Ses_Id ();

        IF NOT Error_Exists
        THEN
            UPDATE At_calendar c
               SET c.atc_is_person_ok = 'F',
                   c.atc_person_notes = p_person_notes,
                   c.atc_hs_person_ok = l_hs
             WHERE c.atc_id = p_Atc_Id;
        END IF;


        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (g_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2);
    END;


    /*
    Необхідно реалізувати функціонал додавання подій в календарі ОСП та КМ в момент отримання договором статусу (SS).
    В момент, коли договір отримує статус (SS), в календарі для користувачів КМ та ОСП, які закріплені за договором, додати запис подій, які закріплені в інд плані.
    Для КМ - відображати один календар з подіями щодо всіх ОСП.
    Для ОСП - бачить тільки свої події.

    ==================
    При встановленні PDSP статусу SS необхідно вносити дані в «Календар подій» КМа та ОСП, заповнюючи дані:
    1) для першого запису в at_calendar
    - atc_at
    - atc_atip = atip_nsa - Ід заходу щодо надання соціальної послуги
    - atc_start_dt = at_action_start_dt – початкова дата надання послуг
    - atc_stop_dt = at_action_stop_dt – кінцева дата надання послуг
    2) для наступних записів в at_calendar
    - atc_at
    - atc_atip = atip_nsa
    - atc_start_dt = atc_start_dt + atip_period
    - atc_stop_dt = atc_start_dt + atip_period

    Кількість «наступних» сформованих подій має = atip_qnt

    Відповідно до ТЗ, в усіх кабінетах повинна бути наявною можливість редагування календаря та додавання нових подій.
    */
    --====================================================--
    --
    --====================================================--
    /*
    PROCEDURE Init_CALENDAR_BKP (p_ip_id    NUMBER
                            ) IS
      l_nst                 t_at_nst;
      l_hs                  NUMBER := tools.GetHistSession;
    BEGIN
      Write_Audit('Init_CALENDAR');

      SELECT p.atip_id, p.atip_nst BULK COLLECT
        INTO l_nst
      FROM at_individual_plan p
      WHERE p.atip_at = p_ip_id
        AND p.history_status = 'A'
        AND NOT EXISTS (SELECT 1
                        FROM AT_CALENDAR
                        WHERE ATC_ATIP = p.atip_id);

      IF l_nst IS NOT NULL THEN
        FOR i IN 1 .. l_nst.count LOOP
            INSERT INTO AT_CALENDAR(ATC_ID,
                                    ATC_AT,
                                    ATC_ATIP,
                                    ATC_START_DT,
                                    ATC_STOP_DT,
                                    HISTORY_STATUS,
                                    ATC_HS_INS,
                                    ATC_SC,
                                    ATC_CU,
                                    ATC_RNSPM,
                                    ATC_SRC)
            WITH ip AS (SELECT a.at_id, a.at_ap, a.at_sc, a.at_cu, a.at_RNSPM, a.at_action_start_dt, a.at_action_stop_dt,
                               p.atip_id,p.atip_nsa,p.atip_place,p.atip_period, p.atip_qnt,p.atip_cu,
                               p.atip_exprections,p.atip_nst,p.atip_nsa_det
                        FROM act a
                          JOIN at_individual_plan p ON p.atip_at = at_id AND p.history_status = 'A'
                        WHERE a.at_id    = p_ip_id
                          AND p.atip_nst = l_nst(i).x_nst
                       )
            SELECT 0,
                   --ip.at_id,
                   (SELECT max(at_id)
                      FROM act TCTR
                      JOIN at_service ats ON ats.ats_at = TCTR.at_id
                      WHERE TCTR.at_tp = 'TCTR'
                        AND TCTR.at_ap = ip.at_ap
                        AND ip.atip_nst = ats.ats_nst
                   ) as x_at_id,
                   ip.atip_id,
                   CASE ip.atip_period
                     WHEN 'D' THEN ip.at_action_start_dt + level - 1
                     WHEN 'W' THEN ip.at_action_start_dt + 7 * (level - 1)
                     WHEN 'M' THEN ADD_MONTHS(ip.at_action_start_dt, level-1)
                   END AS x_start_dt,
                   NULL AS x_stop_dt,
                   'A',
                   l_hs,
                   at_sc,
                   at_cu,
                   at_RNSPM,
                   'NSP'
            FROM ip
            CONNECT BY level <=  ip.atip_qnt;
        END LOOP;
      END IF;

    END;
    */
    PROCEDURE Init_CALENDAR (p_ip_id NUMBER)
    IS
        l_hs              NUMBER := tools.GetHistSession;
        l_Tctr_at_id      ACT.AT_ID%TYPE;
        l_Start_Dt        DATE;
        l_Stop_Dt         DATE;
        l_Days_In_Month   NUMBER;
        l_Qty             NUMBER;
    BEGIN
        Write_Audit ('Init_CALENDAR');
        logS ('Init_Calendar', 'p_ip_id = ' || p_ip_id);
        API$ACT.Check_At_Tp (p_At_Id => p_ip_id, p_At_Tp => 'IP');

        FOR Rec
            IN (SELECT p.atip_id,
                       p.atip_nsa,
                       p.atip_place,
                       CASE
                           WHEN p.atip_period IN ('D', 'W', 'M')
                           THEN
                               p.atip_period
                           ELSE
                               c.nddc_dest
                       END                atip_period,
                       NVL (
                           CASE
                               WHEN p.atip_period IN ('D', 'W', 'M')
                               THEN
                                   p.atip_qnt
                               ELSE
                                   c.nddc_val_int
                           END,
                           1)             atip_qnt,
                       p.atip_cu,
                       p.atip_exprections,
                       p.atip_nst,
                       p.atip_nsa_det,
                       a.at_id,
                       a.at_ap,
                       a.at_sc,
                       a.at_cu,
                       a.at_RNSPM,
                       p.atip_start_dt    at_action_start_dt,
                       p.atip_stop_dt     at_action_stop_dt
                  FROM at_individual_plan  p
                       JOIN act a ON a.at_id = p.atip_at
                       LEFT JOIN uss_Ndi.V_ndi_decoding_config c
                           ON     c.nddc_tp = 'APCC_CFG'
                              AND p.atip_period = c.nddc_src
                 WHERE     p.atip_at = p_ip_id
                       AND p.history_status = 'A'
                       AND CASE
                               WHEN p.atip_period IN ('D', 'W', 'M')
                               THEN
                                   p.atip_period
                               ELSE
                                   c.nddc_dest
                           END
                               IS NOT NULL)
        LOOP
            logS (
                'Init_Calendar',
                   'Rec.atip_id='
                || Rec.atip_id
                || ' Rec.at_ap='
                || Rec.at_ap
                || ' Rec.atip_nst='
                || Rec.atip_nst
                || ' Rec.Atip_Period='
                || Rec.Atip_Period);

            SELECT MAX (at_id)
              INTO l_Tctr_at_id
              FROM act TCTR JOIN at_service ats ON ats.ats_at = TCTR.at_id
             WHERE     TCTR.AT_TP = 'TCTR'
                   AND TCTR.AT_AP = Rec.at_ap
                   AND ats.ats_nst = Rec.atip_nst
                   AND ats.history_status = 'A';

            logS ('Init_Calendar', 'l_Tctr_at_id=' || l_Tctr_at_id);

            IF l_Tctr_at_id IS NOT NULL
            THEN
                DELETE FROM AT_CALENDAR
                      WHERE ATC_ATIP = Rec.atip_id;

                l_Qty := SQL%ROWCOUNT;
                logS ('Init_Calendar', 'l_Qty_Del=' || l_Qty);
                l_Qty := 0;

                --Разово
                IF Rec.Atip_Period = 'ONCE'
                THEN
                    INSERT INTO AT_CALENDAR (ATC_ID,
                                             ATC_AT,
                                             ATC_ATIP,
                                             ATC_START_DT,
                                             ATC_STOP_DT,
                                             HISTORY_STATUS,
                                             ATC_HS_INS,
                                             ATC_SC,
                                             ATC_CU,
                                             ATC_RNSPM,
                                             ATC_SRC)
                        SELECT 0,
                               l_Tctr_at_id,
                               Rec.atip_id,
                               Rec.at_action_start_dt,
                               Rec.at_action_stop_dt,
                               'A',
                               l_hs,
                               Rec.at_sc,
                               Rec.at_cu,
                               Rec.at_RNSPM,
                               'NSP'
                          FROM DUAL;

                    l_Qty := SQL%ROWCOUNT;
                --Кожного дня
                ELSIF Rec.Atip_Period = 'D'
                THEN
                    INSERT INTO AT_CALENDAR (ATC_ID,
                                             ATC_AT,
                                             ATC_ATIP,
                                             ATC_START_DT,
                                             ATC_STOP_DT,
                                             HISTORY_STATUS,
                                             ATC_HS_INS,
                                             ATC_SC,
                                             ATC_CU,
                                             ATC_RNSPM,
                                             ATC_SRC)
                        SELECT 0,
                               l_Tctr_at_id,
                               Rec.atip_id,
                               x_start_dt,
                               x_stop_dt,
                               'A',
                               l_hs,
                               Rec.at_sc,
                               Rec.at_cu,
                               Rec.at_RNSPM,
                               'NSP'
                          FROM (    SELECT Rec.at_action_start_dt + LEVEL - 1
                                               x_start_dt,
                                           Rec.at_action_start_dt + LEVEL - 1
                                               x_stop_dt
                                      FROM DUAL
                                CONNECT BY LEVEL <=
                                           (  Rec.at_action_stop_dt
                                            - Rec.at_action_start_dt)) a,
                               (    SELECT 1
                                      FROM DUAL
                                CONNECT BY LEVEL <= Rec.atip_qnt);

                    l_Qty := SQL%ROWCOUNT;
                --Кожного тижня
                ELSIF Rec.Atip_Period = 'W'
                THEN
                    FOR Periods
                        IN (    SELECT   Rec.at_action_start_dt
                                       + 7 * (LEVEL - 1)
                                       + CASE WHEN LEVEL > 1 THEN 1 ELSE 0 END
                                           x_start_dt,
                                       Rec.at_action_start_dt + 7 * (LEVEL)
                                           x_stop_dt
                                  FROM DUAL
                            CONNECT BY LEVEL <=
                                       CEIL (
                                             (  Rec.at_action_stop_dt
                                              - Rec.at_action_start_dt)
                                           / 7))
                    LOOP
                        FOR vI IN 1 .. Rec.Atip_Qnt
                        LOOP
                            l_Start_Dt := Periods.x_start_dt;
                            l_Stop_Dt := Periods.x_stop_dt;

                            IF vI = Rec.Atip_Qnt
                            THEN
                                l_Stop_Dt := Periods.x_stop_dt;
                            ELSE
                                l_Stop_Dt :=
                                      Periods.x_start_dt
                                    + TRUNC (7 / Rec.Atip_Qnt);
                            END IF;

                            IF l_Start_Dt <= Rec.at_action_stop_dt
                            THEN
                                IF l_Stop_Dt > Rec.at_action_stop_dt
                                THEN
                                    l_Stop_Dt := Rec.at_action_stop_dt;
                                END IF;

                                INSERT INTO AT_CALENDAR (ATC_ID,
                                                         ATC_AT,
                                                         ATC_ATIP,
                                                         ATC_START_DT,
                                                         ATC_STOP_DT,
                                                         HISTORY_STATUS,
                                                         ATC_HS_INS,
                                                         ATC_SC,
                                                         ATC_CU,
                                                         ATC_RNSPM,
                                                         ATC_SRC)
                                     VALUES (0,
                                             l_Tctr_at_id,
                                             Rec.atip_id,
                                             l_Start_Dt,
                                             l_Stop_Dt,
                                             'A',
                                             l_hs,
                                             Rec.at_sc,
                                             Rec.at_cu,
                                             Rec.at_RNSPM,
                                             'NSP');

                                l_Qty := NVL (l_Qty, 0) + SQL%ROWCOUNT;
                            END IF;

                            Periods.x_start_dt :=
                                Periods.x_start_dt + TRUNC (7 / Rec.Atip_Qnt);
                        END LOOP;
                    END LOOP;
                --Крожного місяця
                ELSIF Rec.Atip_Period = 'M'
                THEN
                    FOR Periods
                        IN (    SELECT ADD_MONTHS (Rec.at_action_start_dt,
                                                   LEVEL - 1)                        x_start_dt,
                                       ADD_MONTHS (Rec.at_action_start_dt, LEVEL)    x_stop_dt
                                  FROM DUAL
                            CONNECT BY LEVEL <=
                                       CEIL (
                                           MONTHS_BETWEEN (
                                               Rec.at_action_stop_dt,
                                               Rec.at_action_start_dt)))
                    LOOP
                        l_Days_In_Month :=
                            CAST (
                                TO_CHAR (LAST_DAY (Periods.x_start_dt), 'DD')
                                    AS INT);

                        FOR vI IN 1 .. Rec.Atip_Qnt
                        LOOP
                            l_Start_Dt := Periods.x_start_dt;
                            l_Stop_Dt := Periods.x_stop_dt;

                            IF vI = Rec.Atip_Qnt
                            THEN
                                l_Stop_Dt := Periods.x_stop_dt;
                            ELSE
                                l_Stop_Dt :=
                                      Periods.x_start_dt
                                    + TRUNC (l_Days_In_Month / Rec.Atip_Qnt);
                            END IF;

                            IF l_Start_Dt <= Rec.at_action_stop_dt
                            THEN
                                IF l_Stop_Dt > Rec.at_action_stop_dt
                                THEN
                                    l_Stop_Dt := Rec.at_action_stop_dt;
                                END IF;

                                INSERT INTO AT_CALENDAR (ATC_ID,
                                                         ATC_AT,
                                                         ATC_ATIP,
                                                         ATC_START_DT,
                                                         ATC_STOP_DT,
                                                         HISTORY_STATUS,
                                                         ATC_HS_INS,
                                                         ATC_SC,
                                                         ATC_CU,
                                                         ATC_RNSPM,
                                                         ATC_SRC)
                                     VALUES (0,
                                             l_Tctr_at_id,
                                             Rec.atip_id,
                                             l_Start_Dt,
                                             l_Stop_Dt,
                                             'A',
                                             l_hs,
                                             Rec.at_sc,
                                             Rec.at_cu,
                                             Rec.at_RNSPM,
                                             'NSP');

                                l_Qty := NVL (l_Qty, 0) + SQL%ROWCOUNT;
                            END IF;

                            Periods.x_start_dt :=
                                  Periods.x_start_dt
                                + TRUNC (l_Days_In_Month / Rec.Atip_Qnt);
                        END LOOP;
                    END LOOP;
                END IF;

                logS ('Init_Calendar', 'l_Qty=' || l_Qty);
            END IF;
        END LOOP;
    END;

    PROCEDURE Init_Calendar_PDSP (p_at_id NUMBER)
    IS
    BEGIN
        logS ('Init_Calendar_PDSP', 'p_at_id = ' || p_at_id);

        FOR Rec
            IN (SELECT i.at_id     AS ip_id
                  FROM act  a
                       JOIN act i ON a.at_ap = i.at_ap AND i.at_tp = 'IP'
                 WHERE a.at_id = p_at_id)
        LOOP
            Init_Calendar (Rec.ip_id);
        END LOOP;
    END;
BEGIN
    NULL;
END CMES$CALENDAR;
/