/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$FIND
IS
    TYPE t_v_rnsp_row IS RECORD
    (
        rnspm_id                     NUMBER (14),
        rnspm_num                    VARCHAR2 (50),
        rnspm_date_in                DATE,
        rnspm_date_out               DATE,
        rnspm_st                     VARCHAR2 (1),
        rnspm_version                INTEGER,
        rnspm_tp                     VARCHAR2 (1),
        rnsps_id                     NUMBER (14),
        rnsps_numident               VARCHAR2 (10),
        rnsps_is_numident_missing    VARCHAR2 (1),
        rnsps_pass_seria             VARCHAR2 (10),
        rnsps_pass_num               VARCHAR2 (10),
        rnsps_last_name              VARCHAR2 (250),
        rnsps_first_name             VARCHAR2 (250),
        rnsps_middle_name            VARCHAR2 (250),
        rnsps_gender                 VARCHAR2 (1),
        rnsps_date_birth             DATE,
        rnsps_nc                     NUMBER (14),
        rnspo_id                     NUMBER (14),
        rnspo_prop_form              VARCHAR2 (10),
        rnspo_union_tp               VARCHAR2 (250),
        rnspo_email                  VARCHAR2 (4000),
        rnspo_phone                  VARCHAR2 (4000),
        rnspo_web                    VARCHAR2 (4000),
        rnspo_service_location       VARCHAR2 (250),
        rnspa_id                     NUMBER (14),
        rnspa_kaot                   NUMBER (14),
        rnspa_index                  VARCHAR2 (5),
        rnspa_street                 VARCHAR2 (250),
        rnspa_building               VARCHAR2 (10),
        rnspa_korp                   VARCHAR2 (10),
        rnspa_appartement            VARCHAR2 (10),
        rnspm_org_tp                 VARCHAR2 (10),
        rnspm_rnspm                  NUMBER (14),
        rnspm_chapter                NUMBER (14),
        rnsps_ownership              VARCHAR2 (10),
        rnspm_ap_edit                NUMBER (14),
        rnsps_edr_state              VARCHAR2 (10),
        rnsps_is_stuff_publish       VARCHAR2 (10)
    );

    TYPE t_v_rnsp IS TABLE OF t_v_rnsp_row;

    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL);

    PROCEDURE getrnspm (
        p_numident           IN     VARCHAR2,
        p_numident_missing   IN     rnsp_state.rnsps_is_numident_missing%TYPE,
        p_num                IN     rnsp_main.rnspm_num%TYPE,
        p_rnspm_org_tp       IN     rnsp_main.rnspm_org_tp%TYPE,
        p_rnspm_id              OUT rnsp_state.rnsps_rnspm%TYPE,
        p_rnspm_st              OUT rnsp_main.rnspm_st%TYPE,
        p_rnspm_tp              OUT rnsp_main.rnspm_tp%TYPE);

    FUNCTION GetRNSPM (p_Edrpou    IN VARCHAR2,
                       p_Ipn       IN VARCHAR2,
                       p_Doc_Num   IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE GetRNSPM_ (
        p_numident           IN     VARCHAR2,
        p_numident_missing   IN     rnsp_state.rnsps_is_numident_missing%TYPE,
        p_num                IN     rnsp_main.rnspm_num%TYPE,
        p_rnspm_org_tp       IN     RNSP_MAIN.rnspm_org_tp%TYPE,
        p_rnspm_id           IN     RNSP_MAIN.rnspm_id%TYPE,
        p_rnspm_rnspm        IN     RNSP_MAIN.rnspm_rnspm%TYPE,
        p_rnspm_st              OUT rnsp_main.rnspm_st%TYPE,
        p_rnspm_tp              OUT rnsp_main.rnspm_tp%TYPE);

    PROCEDURE GetRNSP_all (p_rnspm_id       rnsp_state.rnsps_rnspm%TYPE,
                           p_rnsp       OUT SYS_REFCURSOR,
                           p_addr       OUT SYS_REFCURSOR,
                           p_addr1      OUT SYS_REFCURSOR,
                           p_srv        OUT SYS_REFCURSOR);

    PROCEDURE Query (P_NUMIDENT         VARCHAR2,
                     P_RNOKPP           VARCHAR2,
                     P_RNOKPP_MIS       VARCHAR2,
                     P_PASS_NUM         VARCHAR2,
                     P_RNSP         OUT SYS_REFCURSOR);

    PROCEDURE Update_appeal_ap_ext_ident (
        p_ap_id           appeal.ap_id%TYPE,
        p_ext_ident   OUT appeal.ap_ext_ident%TYPE);

    -- контекстний довідник
    PROCEDURE get_dic (p_ndc_code VARCHAR2, res_cur OUT SYS_REFCURSOR);

    -- контекстний довідник з фільтрацією
    PROCEDURE get_dic_filtered (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);

    -- налаштування модального вікна
    PROCEDURE get_modal_select_setup (p_ndc_code       VARCHAR2,
                                      p_filters    OUT VARCHAR2,
                                      p_columns    OUT VARCHAR2);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE get_modal_select (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE get_cached_dics (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);

    -- info:   Пошук надавача
    -- params: p_rnsps_last_name - Прізвище
    --         p_rnsps_first_name - Ім’я
    --         p_rnsps_middle_name - По батькові
    --         p_rnsps_numident - РНОКПП
    --         p_rnsps_pass_seria - Серія паспорту
    --         p_rnsps_pass_num - Номер паспорту/номер ІД-картки
    --         p_is_fiz_pers - Фізична особа (0-НІ/1-ТАК)
    --         p_max_date_in - "гранична" дата включення надавача в реєстр
    -- note:
    FUNCTION get_nsp (p_rnsps_last_name     IN VARCHAR2,
                      p_rnsps_first_name    IN VARCHAR2,
                      p_rnsps_middle_name   IN VARCHAR2,
                      p_rnsps_numident      IN VARCHAR2,
                      p_rnsps_pass_seria    IN VARCHAR2,
                      p_rnsps_pass_num      IN VARCHAR2,
                      p_is_fiz_pers         IN NUMBER,
                      p_max_date_in            DATE)
        RETURN NUMBER;

    -- info:   Отримання атрибутів надавача
    -- params: p_rnspm_id - ідентифікатор надавача
    -- note:
    PROCEDURE get_nsp_attr (p_rnspm_id                    IN     rnsp_main.rnspm_id%TYPE,
                            p_rnsps_last_name                OUT VARCHAR2,
                            p_rnsps_first_name               OUT VARCHAR2,
                            p_rnsps_middle_name              OUT VARCHAR2,
                            p_rnsps_numident                 OUT VARCHAR2,
                            p_rnsps_is_numident_missing      OUT VARCHAR2,
                            p_rnsps_pass_seria               OUT VARCHAR2,
                            p_rnsps_pass_num                 OUT VARCHAR2);

    FUNCTION Get_Nsp_Numident (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Nsp_Name (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Nsp_Pasp (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Nsp_Email (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Services_Only (p_Rnspm_Id   IN     NUMBER,
                                      p_Res           OUT SYS_REFCURSOR);

    FUNCTION get_main_address (p_rnsps_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_address_name (p_rnspa_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GET_DICT_NAME_BY_ID (P_NDA_ID IN NUMBER, P_NDA_VAL_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_v_rnsp_dict
        RETURN t_v_rnsp
        PIPELINED;
END api$find;
/


GRANT EXECUTE ON USS_RNSP.API$FIND TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO II01RC_USS_RNSP_AP_COPY
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO II01RC_USS_RNSP_INTERNAL
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO II01RC_USS_RNSP_PERSON
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO IKIS_RBM
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO OKOMISAROV
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO SHOST
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO USS_ESR
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO USS_PERSON
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO USS_RPT
/

GRANT EXECUTE ON USS_RNSP.API$FIND TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$FIND
IS
    table_not_found   EXCEPTION;
    PRAGMA EXCEPTION_INIT (table_not_found, -942);

    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL)
    IS
        l_Apl_Hs   Ap_Log.Apl_Hs%TYPE;
    BEGIN
        IF p_Apl_Hs IS NULL
        THEN
            l_Apl_Hs := tools.GetHistSession;
        ELSE
            l_Apl_Hs := p_Apl_Hs;
        END IF;

        INSERT INTO Ap_Log (Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_Message,
                            Apl_St_Old,
                            Apl_Tp)
             VALUES (p_Apl_Ap,
                     p_Apl_Hs,
                     p_Apl_St,
                     p_Apl_Message,
                     p_Apl_St_Old,
                     NVL (p_Apl_Tp, 'SYS'));
    END;

    --============================================================================--
    PROCEDURE GetRNSPM (
        p_numident           IN     VARCHAR2,
        p_numident_missing   IN     rnsp_state.rnsps_is_numident_missing%TYPE,
        p_num                IN     rnsp_main.rnspm_num%TYPE,
        p_rnspm_org_tp       IN     rnsp_main.rnspm_org_tp%TYPE,
        p_rnspm_id              OUT rnsp_state.rnsps_rnspm%TYPE,
        p_rnspm_st              OUT rnsp_main.rnspm_st%TYPE,
        p_rnspm_tp              OUT rnsp_main.rnspm_tp%TYPE)
    IS
    BEGIN
        IF NVL (p_numident_missing, 'F') = 'F'
        THEN
            SELECT MAX (rnsps_rnspm)
              INTO p_rnspm_id
              FROM rnsp_state  rs
                   JOIN rnsp_main rm ON rm.rnspm_id = rs.rnsps_rnspm
             WHERE     rs.rnsps_numident = p_numident
                   AND NVL (rm.rnspm_org_tp, 'PR') =
                       NVL (p_rnspm_org_tp, 'PR')
                   AND rs.history_status = 'A';
        ELSE
            SELECT MAX (rnsps_rnspm)
              INTO p_rnspm_id
              FROM rnsp_state  rs
                   JOIN rnsp_main rm ON rm.rnspm_id = rs.rnsps_rnspm
             WHERE     UPPER (rs.rnsps_pass_seria || rs.rnsps_pass_num) =
                       UPPER (p_numident)
                   AND NVL (rm.rnspm_org_tp, 'PR') =
                       NVL (p_rnspm_org_tp, 'PR')
                   AND rs.history_status = 'A';
        END IF;

        IF p_rnspm_id IS NULL AND p_num IS NOT NULL
        THEN
            SELECT MAX (rm.rnspm_id)
              INTO p_rnspm_id
              FROM rnsp_main rm
             WHERE rm.rnspm_num = p_num AND rm.rnspm_st = 'N';
        END IF;

        IF p_rnspm_id IS NOT NULL
        THEN
            SELECT rnspm_st, rnspm_tp
              INTO p_rnspm_st, p_rnspm_tp
              FROM rnsp_main
             WHERE rnspm_id = p_rnspm_id;
        END IF;
    END;

    --============================================================================--
    FUNCTION GetRNSPM (p_Edrpou    IN VARCHAR2,
                       p_Ipn       IN VARCHAR2,
                       p_Doc_Num   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Rnspm_Id   NUMBER;
    BEGIN
        SELECT MAX (m.Rnspm_Id)
          INTO l_Rnspm_Id
          FROM Uss_Rnsp.Rnsp_State  r
               JOIN Uss_Rnsp.Rnsp_Main m ON r.Rnsps_Rnspm = m.Rnspm_Id
         WHERE     (   r.Rnsps_Numident IN (p_Ipn, p_Edrpou)
                    OR r.Rnsps_Pass_Seria || r.Rnsps_Pass_Num = p_Doc_Num)
               AND r.History_Status = 'A'
               AND m.rnspm_st = 'A'
               AND m.Rnspm_Org_Tp = 'PR';

        RETURN l_Rnspm_Id;
    END;

    --============================================================================--
    PROCEDURE GetRNSPM_ (
        p_numident           IN     VARCHAR2,
        p_numident_missing   IN     rnsp_state.rnsps_is_numident_missing%TYPE,
        p_num                IN     rnsp_main.rnspm_num%TYPE,
        p_rnspm_org_tp       IN     RNSP_MAIN.rnspm_org_tp%TYPE,
        p_rnspm_id           IN     RNSP_MAIN.rnspm_id%TYPE,
        p_rnspm_rnspm        IN     RNSP_MAIN.rnspm_rnspm%TYPE,
        p_rnspm_st              OUT rnsp_main.rnspm_st%TYPE,
        p_rnspm_tp              OUT rnsp_main.rnspm_tp%TYPE)
    IS
        l_rnspm_id   NUMBER;
    BEGIN
        IF NVL (p_rnspm_org_tp, 'PR') = 'PR'
        THEN
            IF NVL (p_numident_missing, 'F') = 'F'
            THEN
                SELECT MAX (rnsps_rnspm)
                  INTO l_rnspm_id
                  FROM rnsp_state  rs
                       JOIN rnsp_main rm
                           ON     rm.rnspm_id = rs.rnsps_rnspm
                              AND rm.rnspm_org_tp = 'PR'
                 WHERE     rs.rnsps_numident = p_numident
                       AND rs.history_status = 'A';
            ELSE
                SELECT MAX (rnsps_rnspm)
                  INTO l_rnspm_id
                  FROM rnsp_state  rs
                       JOIN rnsp_main rm
                           ON     rm.rnspm_id = rs.rnsps_rnspm
                              AND rm.rnspm_org_tp = 'PR'
                 WHERE     UPPER (rs.rnsps_pass_seria || rs.rnsps_pass_num) =
                           UPPER (p_numident)
                       AND rs.history_status = 'A';
            END IF;
        /*
            ELSE
              SELECT MAX(rm.rnspm_id) INTO p_rnspm_id
              FROM rnsp_main rm
              WHERE rm.rnspm_org_tp = 'SL' AND rm.rnspm_rnspm = p_rnspm_rnspm AND rm.rnspm_chapter = p_rnspm_chapter;
        */
        END IF;

        IF p_rnspm_id IS NULL AND p_num IS NOT NULL
        THEN
            SELECT MAX (rm.rnspm_id)
              INTO l_rnspm_id
              FROM rnsp_main rm
             WHERE rm.rnspm_num = p_num AND rm.rnspm_st = 'N';
        END IF;

        IF p_rnspm_id IS NOT NULL
        THEN
            SELECT rnspm_st, rnspm_tp
              INTO p_rnspm_st, p_rnspm_tp
              FROM rnsp_main
             WHERE rnspm_id = p_rnspm_id;
        END IF;
    END;



    --============================================================================--
    PROCEDURE GetRNSP_all (p_rnspm_id       rnsp_state.rnsps_rnspm%TYPE,
                           p_rnsp       OUT SYS_REFCURSOR,
                           p_addr       OUT SYS_REFCURSOR,
                           p_addr1      OUT SYS_REFCURSOR,
                           p_srv        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RNSP FOR
            SELECT m.RNSPM_ID,
                   m.RNSPM_TP,
                   m.rnspm_org_tp,
                   m.rnspm_rnspm,
                   (pr.rnsps_last_name)     AS rnspm_rnspm_name,
                   s.RNSPS_ID,
                   s.RNSPS_NUMIDENT,
                   s.RNSPS_IS_NUMIDENT_MISSING,
                   s.RNSPS_PASS_SERIA,
                   s.RNSPS_PASS_NUM,
                   s.RNSPS_LAST_NAME,
                   s.RNSPS_FIRST_NAME,
                   s.RNSPS_MIDDLE_NAME,
                   s.RNSPS_GENDER,
                   o.RNSPO_ID,
                   o.RNSPO_PROP_FORM,
                   o.RNSPO_UNION_TP,
                   o.RNSPO_EMAIL,
                   o.RNSPO_PHONE,
                   o.RNSPO_WEB,
                   o.RNSPO_SERVICE_LOCATION
              FROM RNSP_MAIN  m
                   JOIN RNSP_STATE s
                       ON     s.RNSPS_RNSPM = m.RNSPM_ID
                          AND s.HISTORY_STATUS = 'A'
                   JOIN RNSP_OTHER o ON o.RNSPO_ID = s.RNSPS_RNSPO
                   LEFT JOIN RNSP_STATE pr
                       ON     pr.RNSPS_RNSPM = m.rnspm_rnspm
                          AND pr.HISTORY_STATUS = 'A'
             WHERE RNSPM_ID = p_rnspm_id;

        OPEN p_addr FOR
            SELECT adr.RNSPA_ID,
                   adr.RNSPA_KAOT,
                   adr.RNSPA_INDEX,
                   adr.RNSPA_STREET,
                   adr.RNSPA_BUILDING,
                   adr.RNSPA_KORP,
                   adr.RNSPA_APPARTEMENT,
                   c.kaot_full_name     AS city_name,
                   o.kaot_full_name     AS region_name,
                   d.kaot_full_name     AS area_name
              FROM RNSP_STATE  s
                   JOIN RNSP_ADDRESS adr ON RNSPS_RNSPA = RNSPA_ID
                   LEFT JOIN uss_ndi.v_ndi_katottg c
                       ON c.kaot_id = adr.RNSPA_KAOT
                   LEFT JOIN uss_ndi.v_ndi_katottg o
                       ON o.kaot_id = c.kaot_kaot_l1
                   LEFT JOIN uss_ndi.v_ndi_katottg d
                       ON d.kaot_id = c.kaot_kaot_l2
             WHERE RNSPS_RNSPM = p_rnspm_id AND HISTORY_STATUS = 'A';

        OPEN p_addr1 FOR
            SELECT adr.RNSPA_ID,
                   adr.RNSPA_KAOT,
                   adr.RNSPA_INDEX,
                   adr.RNSPA_STREET,
                   adr.RNSPA_BUILDING,
                   adr.RNSPA_KORP,
                   adr.RNSPA_APPARTEMENT,
                   c.kaot_full_name     AS city_name,
                   o.kaot_full_name     AS region_name,
                   d.kaot_full_name     AS area_name
              FROM RNSP_STATE  s
                   JOIN RNSP2ADDRESS s2a ON s2a.rnsp2a_rnsps = s.rnsps_id
                   JOIN RNSP_ADDRESS adr
                       ON     adr.rnspa_id = s2a.rnsp2a_rnspa
                          AND adr.rnspa_tp = 'S'
                   LEFT JOIN uss_ndi.v_ndi_katottg c
                       ON c.kaot_id = adr.RNSPA_KAOT
                   LEFT JOIN uss_ndi.v_ndi_katottg o
                       ON o.kaot_id = c.kaot_kaot_l1
                   LEFT JOIN uss_ndi.v_ndi_katottg d
                       ON d.kaot_id = c.kaot_kaot_l2
             WHERE RNSPS_RNSPM = p_rnspm_id AND HISTORY_STATUS = 'A';

        OPEN p_srv FOR
            SELECT srv.rnspds_nst
              FROM RNSP_STATE  s
                   JOIN RNSP2SERVICE s2srv ON s2srv.rnsp2s_rnsps = s.rnsps_id
                   JOIN RNSP_DICT_SERVICE srv
                       ON srv.rnspds_id = s2srv.rnsp2s_rnspds
             WHERE RNSPS_RNSPM = p_rnspm_id AND HISTORY_STATUS = 'A';
    END;



    --============================================================================--
    /*
      FUNCTION Get_Addr (p_rnspa_index VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        RETURN          rtrim(ltrim(TRIM(p_rnspa_index) || ', ' ||
                                       (SELECT (CASE
                                                 WHEN k.kaot_kaot_l1 = k.kaot_id THEN
                                                  NULL
                                                 ELSE
                                                  (SELECT k1.kaot_name || ' ' || t1.dic_sname || ', '
                                                     FROM uss_ndi.v_ndi_katottg k1
                                                     JOIN uss_ndi.v_ddn_kaot_tp t1 ON t1.dic_value = k1.kaot_tp
                                                    WHERE k1.kaot_id = k.kaot_kaot_l1)
                                               END) || (CASE
                                                 WHEN k.kaot_kaot_l2 = k.kaot_id THEN
                                                  NULL
                                                 ELSE
                                                  (SELECT k2.kaot_name || ' ' || t2.dic_sname || ', '
                                                     FROM uss_ndi.v_ndi_katottg k2
                                                     JOIN uss_ndi.v_ddn_kaot_tp t2 ON t2.dic_value = k2.kaot_tp
                                                    WHERE k2.kaot_id = k.kaot_kaot_l2)
                                               END) || k.kaot_full_name || ', '
                                          FROM uss_ndi.v_ndi_katottg k
                                          JOIN uss_ndi.v_ddn_kaot_tp t ON t.dic_code = k.kaot_tp
                                         WHERE k.kaot_id = r.rnspa_kaot) ||
                                        ltrim(TRIM(r.rnspa_street) || ', ' ||
                                              ltrim(rtrim('буд. ' || TRIM(r.rnspa_building), 'буд. ') || ', ' ||
                                                    ltrim(rtrim('копр. ' || TRIM(r.rnspa_korp), 'копр. ') || ', ' ||
                                                          rtrim('кв./оф. ' || TRIM(r.rnspa_appartement), 'кв./оф. '), ', '), ', '), ', '),  ', '),  ', ');


      END;
    */
    -- Список за фільтром
    --============================================================================--
    PROCEDURE Query (P_NUMIDENT         VARCHAR2,
                     P_RNOKPP           VARCHAR2,
                     P_RNOKPP_MIS       VARCHAR2,
                     P_PASS_NUM         VARCHAR2,
                     P_RNSP         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF P_NUMIDENT IS NOT NULL
        THEN
            OPEN P_RNSP FOR
                WITH
                    RNSP
                    AS
                        (SELECT RNSP_MAIN.RNSPM_ID,
                                RNSP_MAIN.RNSPM_NUM,
                                RNSP_MAIN.RNSPM_DATE_IN,
                                RNSP_MAIN.RNSPM_DATE_OUT,
                                RNSP_MAIN.RNSPM_ST,
                                RNSP_MAIN.RNSPM_VERSION,
                                RNSP_MAIN.RNSPM_TP,
                                RNSP_MAIN.rnspm_org_tp,
                                RNSP_MAIN.rnspm_rnspm,
                                RNSP_MAIN.rnspm_chapter,
                                RNSP_STATE.RNSPS_ID,
                                RNSP_STATE.RNSPS_NUMIDENT,
                                RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING,
                                RNSP_STATE.RNSPS_PASS_SERIA,
                                RNSP_STATE.RNSPS_PASS_NUM,
                                RNSP_STATE.RNSPS_LAST_NAME,
                                RNSP_STATE.RNSPS_FIRST_NAME,
                                RNSP_STATE.RNSPS_MIDDLE_NAME,
                                RNSP_STATE.RNSPS_GENDER,
                                RNSP_STATE.RNSPS_DATE_BIRTH,
                                RNSP_STATE.RNSPS_NC,
                                RNSP_OTHER.RNSPO_ID,
                                RNSP_OTHER.RNSPO_PROP_FORM,
                                RNSP_OTHER.RNSPO_UNION_TP,
                                RNSP_OTHER.RNSPO_EMAIL,
                                RNSP_OTHER.RNSPO_PHONE,
                                RNSP_OTHER.RNSPO_WEB,
                                RNSP_OTHER.RNSPO_SERVICE_LOCATION,
                                RNSP_ADDRESS.RNSPA_ID,
                                RNSP_ADDRESS.RNSPA_KAOT,
                                RNSP_ADDRESS.RNSPA_INDEX,
                                RNSP_ADDRESS.RNSPA_STREET,
                                RNSP_ADDRESS.RNSPA_BUILDING,
                                RNSP_ADDRESS.RNSPA_KORP,
                                RNSP_ADDRESS.RNSPA_APPARTEMENT
                           FROM RNSP_MAIN,
                                RNSP_STATE,
                                RNSP_OTHER,
                                RNSP_ADDRESS
                          WHERE     RNSPS_RNSPM = RNSPM_ID
                                AND RNSPS_RNSPO = RNSPO_ID
                                AND RNSPS_RNSPA = RNSPA_ID
                                AND HISTORY_STATUS = 'A')
                SELECT a.RNSPM_ID,
                       CASE
                           WHEN NVL (a.RNSPS_IS_NUMIDENT_MISSING, 'F') = 'T'
                           THEN
                               a.RNSPS_PASS_SERIA || a.RNSPS_PASS_NUM
                           ELSE
                               a.RNSPS_NUMIDENT
                       END              AS RNSPS_NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ
                       --a.RNSPS_FIRST_NAME,-- Повна назва/прізвище
                       --a.RNSPS_MIDDLE_NAME,-- Повна назва/прізвище
                       a.RNSPS_LAST_NAME,              -- Повна назва/прізвище
                       tp.DIC_SNAME     AS TP_name,               -- Тип особи
                       otp.DIC_SNAME    AS org_tp_name, -- Ознака головна/філіал – атрибут з задачі #80964
                       st.DIC_SNAME     AS st_name,                  -- Статус
                       RTRIM (
                           LTRIM (
                                  TRIM (a.rnspa_index)
                               || ', '
                               || (SELECT    (CASE
                                                  WHEN k.kaot_kaot_l1 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k1.kaot_name
                                                              || ' '
                                                              || t1.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k1
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t1
                                                                  ON t1.dic_value =
                                                                     k1.kaot_tp
                                                        WHERE k1.kaot_id =
                                                              k.kaot_kaot_l1)
                                              END)
                                          || (CASE
                                                  WHEN k.kaot_kaot_l2 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k2.kaot_name
                                                              || ' '
                                                              || t2.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k2
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t2
                                                                  ON t2.dic_value =
                                                                     k2.kaot_tp
                                                        WHERE k2.kaot_id =
                                                              k.kaot_kaot_l2)
                                              END)
                                          || k.kaot_full_name
                                          || ', '
                                     FROM uss_ndi.v_ndi_katottg  k
                                          JOIN uss_ndi.v_ddn_kaot_tp t
                                              ON t.dic_code = k.kaot_tp
                                    WHERE k.kaot_id = a.rnspa_kaot)
                               || LTRIM (
                                         TRIM (a.rnspa_street)
                                      || ', '
                                      || LTRIM (
                                                RTRIM (
                                                       'буд. '
                                                    || TRIM (
                                                           a.rnspa_building),
                                                    'буд. ')
                                             || ', '
                                             || LTRIM (
                                                       RTRIM (
                                                              'копр. '
                                                           || TRIM (
                                                                  a.rnspa_korp),
                                                           'копр. ')
                                                    || ', '
                                                    || RTRIM (
                                                              'кв./оф. '
                                                           || TRIM (
                                                                  a.rnspa_appartement),
                                                           'кв./оф. '),
                                                    ', '),
                                             ', '),
                                      ', '),
                               ', '),
                           ', ')        AS Addr
                  FROM RNSP  a                             --uss_rnsp.v_rnsp a
                       JOIN uss_ndi.v_ddn_rnsp_st st
                           ON st.DIC_CODE = a.RNSPM_ST
                       JOIN uss_ndi.v_ddn_rnsp_tp tp
                           ON tp.DIC_CODE = a.RNSPM_TP
                       JOIN uss_ndi.v_ddn_rnsp_org_tp otp
                           ON otp.DIC_CODE = a.rnspm_org_tp
                 WHERE a.RNSPS_NUMIDENT LIKE '%' || P_NUMIDENT || '%';
        ELSIF P_RNOKPP IS NOT NULL
        THEN
            OPEN P_RNSP FOR
                WITH
                    RNSP
                    AS
                        (SELECT RNSP_MAIN.RNSPM_ID,
                                RNSP_MAIN.RNSPM_NUM,
                                RNSP_MAIN.RNSPM_DATE_IN,
                                RNSP_MAIN.RNSPM_DATE_OUT,
                                RNSP_MAIN.RNSPM_ST,
                                RNSP_MAIN.RNSPM_VERSION,
                                RNSP_MAIN.RNSPM_TP,
                                RNSP_MAIN.rnspm_org_tp,
                                RNSP_MAIN.rnspm_rnspm,
                                RNSP_MAIN.rnspm_chapter,
                                RNSP_STATE.RNSPS_ID,
                                RNSP_STATE.RNSPS_NUMIDENT,
                                RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING,
                                RNSP_STATE.RNSPS_PASS_SERIA,
                                RNSP_STATE.RNSPS_PASS_NUM,
                                RNSP_STATE.RNSPS_LAST_NAME,
                                RNSP_STATE.RNSPS_FIRST_NAME,
                                RNSP_STATE.RNSPS_MIDDLE_NAME,
                                RNSP_STATE.RNSPS_GENDER,
                                RNSP_STATE.RNSPS_DATE_BIRTH,
                                RNSP_STATE.RNSPS_NC,
                                RNSP_OTHER.RNSPO_ID,
                                RNSP_OTHER.RNSPO_PROP_FORM,
                                RNSP_OTHER.RNSPO_UNION_TP,
                                RNSP_OTHER.RNSPO_EMAIL,
                                RNSP_OTHER.RNSPO_PHONE,
                                RNSP_OTHER.RNSPO_WEB,
                                RNSP_OTHER.RNSPO_SERVICE_LOCATION,
                                RNSP_ADDRESS.RNSPA_ID,
                                RNSP_ADDRESS.RNSPA_KAOT,
                                RNSP_ADDRESS.RNSPA_INDEX,
                                RNSP_ADDRESS.RNSPA_STREET,
                                RNSP_ADDRESS.RNSPA_BUILDING,
                                RNSP_ADDRESS.RNSPA_KORP,
                                RNSP_ADDRESS.RNSPA_APPARTEMENT
                           FROM RNSP_MAIN,
                                RNSP_STATE,
                                RNSP_OTHER,
                                RNSP_ADDRESS
                          WHERE     RNSPS_RNSPM = RNSPM_ID
                                AND RNSPS_RNSPO = RNSPO_ID
                                AND RNSPS_RNSPA = RNSPA_ID
                                AND HISTORY_STATUS = 'A')
                SELECT a.RNSPM_ID,
                       CASE
                           WHEN NVL (a.RNSPS_IS_NUMIDENT_MISSING, 'F') = 'T'
                           THEN
                               a.RNSPS_PASS_SERIA || a.RNSPS_PASS_NUM
                           ELSE
                               a.RNSPS_NUMIDENT
                       END              AS RNSPS_NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ
                       --a.RNSPS_FIRST_NAME,-- Повна назва/прізвище
                       --a.RNSPS_MIDDLE_NAME,-- Повна назва/прізвище
                       a.RNSPS_LAST_NAME,              -- Повна назва/прізвище
                       tp.DIC_SNAME     AS TP_name,               -- Тип особи
                       otp.DIC_SNAME    AS org_tp_name, -- Ознака головна/філіал – атрибут з задачі #80964
                       st.DIC_SNAME     AS st_name,                  -- Статус
                       RTRIM (
                           LTRIM (
                                  TRIM (a.rnspa_index)
                               || ', '
                               || (SELECT    (CASE
                                                  WHEN k.kaot_kaot_l1 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k1.kaot_name
                                                              || ' '
                                                              || t1.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k1
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t1
                                                                  ON t1.dic_value =
                                                                     k1.kaot_tp
                                                        WHERE k1.kaot_id =
                                                              k.kaot_kaot_l1)
                                              END)
                                          || (CASE
                                                  WHEN k.kaot_kaot_l2 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k2.kaot_name
                                                              || ' '
                                                              || t2.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k2
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t2
                                                                  ON t2.dic_value =
                                                                     k2.kaot_tp
                                                        WHERE k2.kaot_id =
                                                              k.kaot_kaot_l2)
                                              END)
                                          || k.kaot_full_name
                                          || ', '
                                     FROM uss_ndi.v_ndi_katottg  k
                                          JOIN uss_ndi.v_ddn_kaot_tp t
                                              ON t.dic_code = k.kaot_tp
                                    WHERE k.kaot_id = a.rnspa_kaot)
                               || LTRIM (
                                         TRIM (a.rnspa_street)
                                      || ', '
                                      || LTRIM (
                                                RTRIM (
                                                       'буд. '
                                                    || TRIM (
                                                           a.rnspa_building),
                                                    'буд. ')
                                             || ', '
                                             || LTRIM (
                                                       RTRIM (
                                                              'копр. '
                                                           || TRIM (
                                                                  a.rnspa_korp),
                                                           'копр. ')
                                                    || ', '
                                                    || RTRIM (
                                                              'кв./оф. '
                                                           || TRIM (
                                                                  a.rnspa_appartement),
                                                           'кв./оф. '),
                                                    ', '),
                                             ', '),
                                      ', '),
                               ', '),
                           ', ')        AS Addr
                  FROM RNSP  a                             --uss_rnsp.v_rnsp a
                       JOIN uss_ndi.v_ddn_rnsp_st st
                           ON st.DIC_CODE = a.RNSPM_ST
                       JOIN uss_ndi.v_ddn_rnsp_tp tp
                           ON tp.DIC_CODE = a.RNSPM_TP
                       JOIN uss_ndi.v_ddn_rnsp_org_tp otp
                           ON otp.DIC_CODE = a.rnspm_org_tp
                 WHERE a.RNSPS_NUMIDENT LIKE '%' || P_RNOKPP || '%';
        ELSIF P_PASS_NUM IS NOT NULL
        THEN
            OPEN P_RNSP FOR
                WITH
                    RNSP
                    AS
                        (SELECT RNSP_MAIN.RNSPM_ID,
                                RNSP_MAIN.RNSPM_NUM,
                                RNSP_MAIN.RNSPM_DATE_IN,
                                RNSP_MAIN.RNSPM_DATE_OUT,
                                RNSP_MAIN.RNSPM_ST,
                                RNSP_MAIN.RNSPM_VERSION,
                                RNSP_MAIN.RNSPM_TP,
                                RNSP_MAIN.rnspm_org_tp,
                                RNSP_MAIN.rnspm_rnspm,
                                RNSP_MAIN.rnspm_chapter,
                                RNSP_STATE.RNSPS_ID,
                                RNSP_STATE.RNSPS_NUMIDENT,
                                RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING,
                                RNSP_STATE.RNSPS_PASS_SERIA,
                                RNSP_STATE.RNSPS_PASS_NUM,
                                RNSP_STATE.RNSPS_LAST_NAME,
                                RNSP_STATE.RNSPS_FIRST_NAME,
                                RNSP_STATE.RNSPS_MIDDLE_NAME,
                                RNSP_STATE.RNSPS_GENDER,
                                RNSP_STATE.RNSPS_DATE_BIRTH,
                                RNSP_STATE.RNSPS_NC,
                                RNSP_OTHER.RNSPO_ID,
                                RNSP_OTHER.RNSPO_PROP_FORM,
                                RNSP_OTHER.RNSPO_UNION_TP,
                                RNSP_OTHER.RNSPO_EMAIL,
                                RNSP_OTHER.RNSPO_PHONE,
                                RNSP_OTHER.RNSPO_WEB,
                                RNSP_OTHER.RNSPO_SERVICE_LOCATION,
                                RNSP_ADDRESS.RNSPA_ID,
                                RNSP_ADDRESS.RNSPA_KAOT,
                                RNSP_ADDRESS.RNSPA_INDEX,
                                RNSP_ADDRESS.RNSPA_STREET,
                                RNSP_ADDRESS.RNSPA_BUILDING,
                                RNSP_ADDRESS.RNSPA_KORP,
                                RNSP_ADDRESS.RNSPA_APPARTEMENT
                           FROM RNSP_MAIN,
                                RNSP_STATE,
                                RNSP_OTHER,
                                RNSP_ADDRESS
                          WHERE     RNSPS_RNSPM = RNSPM_ID
                                AND RNSPS_RNSPO = RNSPO_ID
                                AND RNSPS_RNSPA = RNSPA_ID
                                AND HISTORY_STATUS = 'A')
                SELECT a.RNSPM_ID,
                       CASE
                           WHEN NVL (a.RNSPS_IS_NUMIDENT_MISSING, 'F') = 'T'
                           THEN
                               a.RNSPS_PASS_SERIA || a.RNSPS_PASS_NUM
                           ELSE
                               a.RNSPS_NUMIDENT
                       END              AS RNSPS_NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ
                       --a.RNSPS_FIRST_NAME,-- Повна назва/прізвище
                       --a.RNSPS_MIDDLE_NAME,-- Повна назва/прізвище
                       a.RNSPS_LAST_NAME,              -- Повна назва/прізвище
                       tp.DIC_SNAME     AS TP_name,               -- Тип особи
                       otp.DIC_SNAME    AS org_tp_name, -- Ознака головна/філіал – атрибут з задачі #80964
                       st.DIC_SNAME     AS st_name,                  -- Статус
                       RTRIM (
                           LTRIM (
                                  TRIM (a.rnspa_index)
                               || ', '
                               || (SELECT    (CASE
                                                  WHEN k.kaot_kaot_l1 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k1.kaot_name
                                                              || ' '
                                                              || t1.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k1
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t1
                                                                  ON t1.dic_value =
                                                                     k1.kaot_tp
                                                        WHERE k1.kaot_id =
                                                              k.kaot_kaot_l1)
                                              END)
                                          || (CASE
                                                  WHEN k.kaot_kaot_l2 =
                                                       k.kaot_id
                                                  THEN
                                                      NULL
                                                  ELSE
                                                      (SELECT    k2.kaot_name
                                                              || ' '
                                                              || t2.dic_sname
                                                              || ', '
                                                         FROM uss_ndi.v_ndi_katottg
                                                              k2
                                                              JOIN
                                                              uss_ndi.v_ddn_kaot_tp
                                                              t2
                                                                  ON t2.dic_value =
                                                                     k2.kaot_tp
                                                        WHERE k2.kaot_id =
                                                              k.kaot_kaot_l2)
                                              END)
                                          || k.kaot_full_name
                                          || ', '
                                     FROM uss_ndi.v_ndi_katottg  k
                                          JOIN uss_ndi.v_ddn_kaot_tp t
                                              ON t.dic_code = k.kaot_tp
                                    WHERE k.kaot_id = a.rnspa_kaot)
                               || LTRIM (
                                         TRIM (a.rnspa_street)
                                      || ', '
                                      || LTRIM (
                                                RTRIM (
                                                       'буд. '
                                                    || TRIM (
                                                           a.rnspa_building),
                                                    'буд. ')
                                             || ', '
                                             || LTRIM (
                                                       RTRIM (
                                                              'копр. '
                                                           || TRIM (
                                                                  a.rnspa_korp),
                                                           'копр. ')
                                                    || ', '
                                                    || RTRIM (
                                                              'кв./оф. '
                                                           || TRIM (
                                                                  a.rnspa_appartement),
                                                           'кв./оф. '),
                                                    ', '),
                                             ', '),
                                      ', '),
                               ', '),
                           ', ')        AS Addr
                  FROM RNSP  a                             --uss_rnsp.v_rnsp a
                       JOIN uss_ndi.v_ddn_rnsp_st st
                           ON st.DIC_CODE = a.RNSPM_ST
                       JOIN uss_ndi.v_ddn_rnsp_tp tp
                           ON tp.DIC_CODE = a.RNSPM_TP
                       JOIN uss_ndi.v_ddn_rnsp_org_tp otp
                           ON otp.DIC_CODE = a.rnspm_org_tp
                 WHERE a.RNSPS_PASS_SERIA || a.RNSPS_PASS_NUM LIKE
                           '%' || P_PASS_NUM || '%';
        END IF;
    END;

    --============================================================================--
    PROCEDURE Update_appeal_ap_ext_ident (
        p_ap_id           appeal.ap_id%TYPE,
        p_ext_ident   OUT appeal.ap_ext_ident%TYPE)
    IS
    BEGIN
        Api$Document.Update_appeal_ap_ext_ident (p_ap_id, p_ext_ident);
    END;


    -- контекстний довідник
    PROCEDURE get_dic (p_ndc_code VARCHAR2, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        DNET$DICTIONARIES_WEB.get_dic (p_ndc_code, res_cur);
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE get_dic_filtered (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        DNET$DICTIONARIES_WEB.get_dic_filtered (p_ndc_code, p_xml, res_cur);
    END;

    -- налаштування модального вікна
    PROCEDURE get_modal_select_setup (p_ndc_code       VARCHAR2,
                                      p_filters    OUT VARCHAR2,
                                      p_columns    OUT VARCHAR2)
    IS
    BEGIN
        dnet$dictionaries_web.get_modal_select_setup (p_ndc_code,
                                                      p_filters,
                                                      p_columns);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE get_modal_select (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        DNET$DICTIONARIES_WEB.get_modal_select (p_ndc_code, p_xml, res_cur);
    END;

    PROCEDURE get_cached_dics (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        DNET$DICTIONARIES_WEB.get_cached_dics (p_sys, p_cursor);
    END;

    -- info:   Пошук надавача
    -- params: p_rnsps_last_name - Прізвище
    --         p_rnsps_first_name - Ім’я
    --         p_rnsps_middle_name - По батькові
    --         p_rnsps_numident - РНОКПП
    --         p_rnsps_pass_seria - Серія паспорту
    --         p_rnsps_pass_num - Номер паспорту/номер ІД-картки
    --         p_is_fiz_pers - Фізична особа (0-НІ/1-ТАК)
    --         p_max_date_in - "гранична" дата включення надавача в реєстр
    -- note:
    FUNCTION get_nsp (p_rnsps_last_name     IN VARCHAR2,
                      p_rnsps_first_name    IN VARCHAR2,
                      p_rnsps_middle_name   IN VARCHAR2,
                      p_rnsps_numident      IN VARCHAR2,
                      p_rnsps_pass_seria    IN VARCHAR2,
                      p_rnsps_pass_num      IN VARCHAR2,
                      p_is_fiz_pers         IN NUMBER,
                      p_max_date_in            DATE)
        RETURN NUMBER
    IS
        v_rnspm_id   rnsp_main.rnspm_id%TYPE;
    BEGIN
        SELECT rnspm_id
          INTO v_rnspm_id
          FROM v_rnsp
         WHERE     rnspm_st = 'A'
               AND rnspm_date_in <= p_max_date_in
               AND (   (    (p_is_fiz_pers = 1 OR rnspm_tp = 'F')
                        AND UPPER (
                                TRIM (
                                    COALESCE (rnsps_last_name,
                                              p_rnsps_last_name,
                                              'NULL'))) =
                            UPPER (
                                TRIM (
                                    COALESCE (p_rnsps_last_name,
                                              rnsps_last_name,
                                              'NULL')))
                        AND UPPER (
                                TRIM (
                                    COALESCE (rnsps_first_name,
                                              p_rnsps_first_name,
                                              'NULL'))) =
                            UPPER (
                                TRIM (
                                    COALESCE (p_rnsps_first_name,
                                              rnsps_first_name,
                                              'NULL')))
                        AND UPPER (
                                TRIM (
                                    COALESCE (rnsps_middle_name,
                                              p_rnsps_middle_name,
                                              'NULL'))) =
                            UPPER (
                                TRIM (
                                    COALESCE (p_rnsps_middle_name,
                                              rnsps_middle_name,
                                              'NULL'))))
                    OR (    p_is_fiz_pers = 0
                        AND rnspm_tp = 'O'
                        AND UPPER (
                                TRIM (
                                    COALESCE (p_rnsps_last_name,
                                              rnsps_last_name,
                                              'NULL'))) IN
                                (UPPER (
                                     TRIM (
                                         COALESCE (rnsps_last_name,
                                                   p_rnsps_last_name,
                                                   'NULL'))),
                                 UPPER (
                                     TRIM (
                                         COALESCE (rnsps_first_name,
                                                   p_rnsps_last_name,
                                                   'NULL'))))))
               AND (   (    COALESCE (rnsps_is_numident_missing, 'F') = 'F'
                        AND TRIM (rnsps_numident) = TRIM (p_rnsps_numident))
                    OR (    COALESCE (rnsps_is_numident_missing, 'T') = 'T'
                        AND COALESCE (p_rnsps_pass_seria, p_rnsps_pass_num)
                                IS NOT NULL
                        AND COALESCE (UPPER (TRIM (rnsps_pass_seria)),
                                      'NULL') =
                            COALESCE (UPPER (TRIM (p_rnsps_pass_seria)),
                                      'NULL')
                        AND UPPER (TRIM (rnsps_pass_num)) =
                            UPPER (TRIM (p_rnsps_pass_num))))
               AND rnspm_tp =
                   (CASE p_is_fiz_pers WHEN 1 THEN 'P' ELSE rnspm_tp END);

        RETURN v_rnspm_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання атрибутів надавача
    -- params: p_rnspm_id - ідентифікатор надавача
    -- note:
    PROCEDURE get_nsp_attr (p_rnspm_id                    IN     rnsp_main.rnspm_id%TYPE,
                            p_rnsps_last_name                OUT VARCHAR2,
                            p_rnsps_first_name               OUT VARCHAR2,
                            p_rnsps_middle_name              OUT VARCHAR2,
                            p_rnsps_numident                 OUT VARCHAR2,
                            p_rnsps_is_numident_missing      OUT VARCHAR2,
                            p_rnsps_pass_seria               OUT VARCHAR2,
                            p_rnsps_pass_num                 OUT VARCHAR2)
    IS
    BEGIN
        SELECT rnsps_last_name,
               rnsps_first_name,
               rnsps_middle_name,
               rnsps_numident,
               rnsps_is_numident_missing,
               rnsps_pass_seria,
               rnsps_pass_num
          INTO p_rnsps_last_name,
               p_rnsps_first_name,
               p_rnsps_middle_name,
               p_rnsps_numident,
               p_rnsps_is_numident_missing,
               p_rnsps_pass_seria,
               p_rnsps_pass_num
          FROM v_rnsp
         WHERE rnspm_id = p_rnspm_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;

    --Отримання РНОКПП/ЕДРПОУ надавача
    FUNCTION Get_Nsp_Name (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (
                   CASE
                       WHEN r.RNSPM_TP = 'O'
                       THEN
                           NVL (rnsps_first_name, rnsps_last_name)
                       WHEN     r.RNSPM_TP = 'F'
                            AND rnsps_middle_name IS NOT NULL
                       THEN
                              rnsps_last_name
                           || ' '
                           || rnsps_first_name
                           || ' '
                           || rnsps_middle_name
                       WHEN r.RNSPM_TP = 'F' AND rnsps_first_name IS NOT NULL
                       THEN
                           rnsps_first_name
                       WHEN r.RNSPM_TP = 'F'
                       THEN
                           rnsps_last_name
                   END)    AS pib
          INTO l_Result
          FROM v_rnsp r
         WHERE rnspm_id = p_rnspm_id;

        RETURN l_Result;
    END;

    --Отримання РНОКПП/ЕДРПОУ надавача
    FUNCTION Get_Nsp_Numident (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Rnsp_State.Rnsps_Numident%TYPE;
    BEGIN
        SELECT MAX (s.Rnsps_Numident)
          INTO l_Result
          FROM Rnsp_State s
         WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Nsp_Pasp (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (20);
    BEGIN
        SELECT MAX (s.Rnsps_Pass_Seria || s.Rnsps_Pass_Num)
          INTO l_Result
          FROM Rnsp_State s
         WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Nsp_Email (p_Rnspm_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Rnsp_Other.Rnspo_Email%TYPE;
    BEGIN
        SELECT MAX (o.Rnspo_Email)
          INTO l_Result
          FROM Rnsp_State s JOIN Rnsp_Other o ON s.Rnsps_Rnspo = o.Rnspo_Id
         WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';

        RETURN l_Result;
    END;

    PROCEDURE Get_Rnsp_Services_Only (p_Rnspm_Id   IN     NUMBER,
                                      p_Res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT nst.nst_id, nst.nst_name
              FROM uss_rnsp.v_rnsp_main  m
                   JOIN uss_rnsp.v_rnsp_state s
                       ON     m.RNSPM_ID = s.RNSPS_RNSPM
                          AND s.HISTORY_STATUS = 'A'
                   JOIN uss_rnsp.v_rnsp2service rs
                       ON s.RNSPS_ID = rs.RNSP2S_RNSPS
                   JOIN uss_rnsp.v_rnsp_dict_service rds
                       ON rs.RNSP2S_RNSPDS = rds.RNSPDS_ID
                   JOIN uss_Ndi.v_Ndi_Service_Type nst
                       ON rds.RNSPDS_NST = nst.nst_id
             WHERE m.rnspm_id = p_Rnspm_Id;
    END;

    FUNCTION get_main_address (p_rnsps_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_id   NUMBER;
    BEGIN
        SELECT MAX (d.RNSPA_ID)
          INTO l_id
          FROM uss_rnsp.v_rnsp_address  d
               JOIN uss_rnsp.v_RNSP2ADDRESS s2a
                   ON d.rnspa_id = s2a.rnsp2a_rnspa
               LEFT JOIN uss_ndi.v_ndi_katottg k
                   ON (k.kaot_id = d.rnspa_kaot)
         WHERE     s2a.rnsp2a_rnsps = p_rnsps_id
               AND d.rnspa_tp = 'S'
               AND ROWNUM < 2;

        IF (l_id IS NULL)
        THEN
            RETURN NULL;
        ELSE
            RETURN get_address_name (l_id);
        END IF;
    END;

    FUNCTION get_address_name (p_rnspa_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_addr   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (
                      CASE
                          WHEN l1_name IS NOT NULL AND l1_name != kaot_name
                          THEN
                              l1_name || ', '
                      END
                   || CASE
                          WHEN l2_name IS NOT NULL AND l2_name != kaot_name
                          THEN
                              l2_name || ', '
                      END
                   || CASE
                          WHEN l3_name IS NOT NULL AND l3_name != kaot_name
                          THEN
                              l3_name || ', '
                      END
                   || CASE
                          WHEN l4_name IS NOT NULL AND l4_name != kaot_name
                          THEN
                              l4_name || ', '
                      END
                   || CASE
                          WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                          THEN
                              l5_name || ', '
                      END
                   || temp_name
                   || ', '
                   || part)
          INTO l_addr
          FROM (SELECT    ''
                       || CASE
                              WHEN d.rnspa_street IS NOT NULL
                              THEN
                                  ' ' || d.rnspa_street
                          END
                       || CASE
                              WHEN d.rnspa_building IS NOT NULL
                              THEN
                                  ', буд. ' || d.rnspa_building
                          END
                       || CASE
                              WHEN d.rnspa_korp IS NOT NULL
                              THEN
                                  ', к. ' || d.rnspa_korp
                          END
                       || CASE
                              WHEN d.rnspa_appartement IS NOT NULL
                              THEN
                                  ', кв. ' || d.rnspa_appartement
                          END              AS part,
                       CASE
                           WHEN Kaot_Kaot_L1 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT X1.KAOT_FULL_NAME
                                  FROM uss_ndi.v_Ndi_Katottg X1
                                 WHERE X1.Kaot_Id = k.Kaot_Kaot_L1)
                       END                 AS l1_name,
                       CASE
                           WHEN Kaot_Kaot_L2 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT X1.KAOT_FULL_NAME
                                  FROM uss_ndi.v_Ndi_Katottg X1
                                 WHERE X1.Kaot_Id = k.Kaot_Kaot_L2)
                       END                 AS l2_name,
                       CASE
                           WHEN Kaot_Kaot_L3 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT X1.KAOT_FULL_NAME
                                  FROM uss_ndi.v_Ndi_Katottg X1
                                 WHERE X1.Kaot_Id = k.Kaot_Kaot_L3)
                       END                 AS l3_name,
                       CASE
                           WHEN Kaot_Kaot_L4 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT X1.KAOT_FULL_NAME
                                  FROM uss_ndi.v_Ndi_Katottg X1
                                 WHERE X1.Kaot_Id = k.Kaot_Kaot_L4)
                       END                 AS l4_name,
                       CASE
                           WHEN Kaot_Kaot_L5 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT X1.KAOT_FULL_NAME
                                  FROM uss_ndi.v_Ndi_Katottg X1
                                 WHERE X1.Kaot_Id = k.Kaot_Kaot_L5)
                       END                 AS l5_name,
                       k.kaot_name,
                       k.kaot_full_name    AS temp_name
                  FROM rnsp_address  d
                       LEFT JOIN uss_ndi.v_ndi_katottg k
                           ON (k.kaot_id = d.rnspa_kaot)
                 WHERE d.rnspa_id = p_rnspa_Id);

        RETURN l_addr;
    END;

    FUNCTION GET_DICT_NAME_BY_ID (P_NDA_ID IN NUMBER, P_NDA_VAL_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Query   VARCHAR2 (32000);
        l_Res     VARCHAR2 (4000);
    BEGIN
        SELECT dc.ndc_sql
          INTO l_Query
          FROM uss_ndi.v_ndi_document_attr  da
               JOIN uss_ndi.v_ndi_param_type pt ON da.nda_pt = pt.pt_id
               JOIN uss_ndi.v_ndi_dict_config dc ON pt.pt_ndc = dc.ndc_id
         WHERE pt.pt_edit_type = 'MF' AND nda_id = P_NDA_ID;

        l_Query :=
            REGEXP_REPLACE (l_Query, 'AND ROWNUM < \d{1,5}', 'AND 1=1');


        l_Query := 'SELECT NAME
       FROM (
       ' || l_Query || '
       )
       WHERE ID = ' || P_NDA_VAL_ID;

        DBMS_OUTPUT.put_line (l_Query);

        EXECUTE IMMEDIATE l_Query
            INTO l_Res;


        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN table_not_found
        THEN
            RETURN NULL;
    END;

    FUNCTION get_v_rnsp_dict
        RETURN t_v_rnsp
        PIPELINED
    IS
    BEGIN
        FOR xx IN (SELECT * FROM v_rnsp)
        LOOP
            PIPE ROW (t_v_rnsp_row (xx.rnspm_id,
                                    xx.rnspm_num,
                                    xx.rnspm_date_in,
                                    xx.rnspm_date_out,
                                    xx.rnspm_st,
                                    xx.rnspm_version,
                                    xx.rnspm_tp,
                                    xx.rnsps_id,
                                    xx.rnsps_numident,
                                    xx.rnsps_is_numident_missing,
                                    xx.rnsps_pass_seria,
                                    xx.rnsps_pass_num,
                                    xx.rnsps_last_name,
                                    xx.rnsps_first_name,
                                    xx.rnsps_middle_name,
                                    xx.rnsps_gender,
                                    xx.rnsps_date_birth,
                                    xx.rnsps_nc,
                                    xx.rnspo_id,
                                    xx.rnspo_prop_form,
                                    xx.rnspo_union_tp,
                                    xx.rnspo_email,
                                    xx.rnspo_phone,
                                    xx.rnspo_web,
                                    xx.rnspo_service_location,
                                    xx.rnspa_id,
                                    xx.rnspa_kaot,
                                    xx.rnspa_index,
                                    xx.rnspa_street,
                                    xx.rnspa_building,
                                    xx.rnspa_korp,
                                    xx.rnspa_appartement,
                                    xx.rnspm_org_tp,
                                    xx.rnspm_rnspm,
                                    xx.rnspm_chapter,
                                    xx.rnsps_ownership,
                                    xx.rnspm_ap_edit,
                                    xx.rnsps_edr_state,
                                    xx.rnsps_is_stuff_publish));
        END LOOP;

        RETURN;
    END get_v_rnsp_dict;
END API$FIND;
/