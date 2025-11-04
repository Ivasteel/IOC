/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_TOOLS
IS
    -- Author  : BOGDAN
    -- Created : 15.07.2021 13:13:31
    -- Purpose : Базові функції на отримання типових даних

    TYPE r_sc_dzr_recomm IS RECORD
    (
        scdr_id           NUMBER,
        scdr_sc           NUMBER,
        scdr_wrn          NUMBER,
        scdr_is_need      VARCHAR2 (10),
        scdr_scd          NUMBER,
        scdr_src          VARCHAR2 (10),
        scdr_src_id       NUMBER,
        history_status    VARCHAR2 (10),
        scdr_src_dt       DATE,
        wrn_shifr         VARCHAR2 (150),
        wrn_name          VARCHAR2 (1000),
        wrn_issue_max     INTEGER,
        wrn_mult_qnt      INTEGER,
        wrn_issue_desc    VARCHAR2 (4000)
    );

    TYPE t_sc_dzr_recomm IS TABLE OF r_sc_dzr_recomm;

    FUNCTION INIT_CAP (P_TEXT IN VARCHAR2)
        RETURN VARCHAR2;

    -- ПІБ особи
    -- P_MODE:
    ---- 0 - повне прізвище
    FUNCTION GET_PIB (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    --ПІБ особи на вказаний стан
    -- P_MODE:
    ---- 0 - повне прізвище
    FUNCTION GET_PIB_SCC (P_SCC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    -- Дата народження
    FUNCTION GET_BIRTHDATE (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN DATE;

    -- Стать (0 - код, 1 - назва)
    FUNCTION GET_GENDER (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    -- Дата смерті
    FUNCTION get_death_dt (p_sc_id IN NUMBER, p_mode IN NUMBER DEFAULT 0)
        RETURN DATE;

    -- info:   Отримання ідентифікаційного коду
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_numident (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    -- info:   Отримання ідентифікаційного коду по зрізу
    -- params: p_scс_id - ідентифікатор зрізу соціальної картки
    -- note:
    FUNCTION get_numident_scc (p_scc_id IN NUMBER)
        RETURN VARCHAR2;

    -- info:   Отримання номеру ідентифікаційного документу
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_doc_num (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    -- info:   Отримання № довідки ВПО
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_vpo_num (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    -- info:   Отримання актуальної адреси
    -- params: p_sc_id - ідентифікатор соціальної картки
    --         p_sca_tp - тип адреси
    -- note:
    FUNCTION get_address (p_sc_id IN NUMBER, p_sca_tp IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_full_address_text (p_sc_id IN NUMBER, p_sca_tp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_phone_mob (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_phone (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_disability_group (p_sc_id   IN NUMBER,
                                   p_date    IN DATE DEFAULT NULL)
        RETURN VARCHAR2;

    -- info:   Отримання категорії інвалідності дитини
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_inv_child (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE get_dzr_by_sc (p_sc_id IN NUMBER, p_res OUT SYS_REFCURSOR);

    FUNCTION get_dzr_attr_value_by_sc (p_sc_id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Passport (p_Sc_Id    IN     NUMBER,
                            p_Ndt         OUT NUMBER,
                            p_Seria       OUT VARCHAR2,
                            p_Number      OUT VARCHAR2);

    FUNCTION get_sc_dzr_recomm (p_sc_id IN NUMBER)
        RETURN t_sc_dzr_recomm
        PIPELINED;

    FUNCTION get_sc_doc (p_sc_id IN NUMBER, p_ndt_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION get_sc_doc_val_str (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_sc_doc_val_id (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION get_sc_doc_val_int (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN NUMBER;
END API$SC_TOOLS;
/


GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO II01RC_USS_PERSON_WEB
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO OPERVIEIEV
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SC_TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_TOOLS
IS
    FUNCTION INIT_CAP (P_TEXT IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (INITCAP (REGEXP_REPLACE (P_TEXT, '[’''`]', '666')),
                        '666',
                        '’');
    END;


    -- ПІБ особи
    -- P_MODE:
    ---- 0 - повне прізвище
    FUNCTION GET_PIB (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (600);
    BEGIN
        SELECT CASE
                   WHEN p_mode = 0
                   THEN
                          INIT_CAP (i.sci_ln)
                       || ' '
                       || INIT_CAP (i.sci_fn)
                       || ' '
                       || INIT_CAP (i.sci_mn)
                   WHEN p_mode = 1
                   THEN
                          INIT_CAP (i.sci_ln)
                       || ' '
                       || UPPER (SUBSTR (i.sci_fn, 1, 1))
                       || '. '
                       || UPPER (SUBSTR (i.sci_mn, 1, 1))
                       || '. '
               END
          INTO l_res
          FROM v_socialcard  t
               JOIN v_sc_change ch ON (ch.scc_id = t.sc_scc)
               JOIN v_sc_identity i ON (i.sci_id = ch.scc_sci)
         WHERE t.sc_id = p_sc_id;

        RETURN l_res;
    END;

    --ПІБ особи на вказаний стан
    -- P_MODE:
    ---- 0 - повне прізвище
    FUNCTION GET_PIB_SCC (P_SCC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (600);
    BEGIN
        SELECT CASE
                   WHEN p_mode = 0
                   THEN
                          INIT_CAP (i.sci_ln)
                       || ' '
                       || INIT_CAP (i.sci_fn)
                       || ' '
                       || INIT_CAP (i.sci_mn)
                   WHEN p_mode = 1
                   THEN
                          INIT_CAP (i.sci_ln)
                       || ' '
                       || UPPER (SUBSTR (i.sci_fn, 1, 1))
                       || '. '
                       || UPPER (SUBSTR (i.sci_mn, 1, 1))
                       || '. '
               END
          INTO l_res
          FROM v_sc_change ch JOIN v_sc_identity i ON (i.sci_id = ch.scc_sci)
         WHERE ch.scc_id = p_scc_id;

        RETURN l_res;
    END;

    -- Дата народження
    FUNCTION GET_BIRTHDATE (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN DATE
    IS
        l_res   DATE;
    BEGIN
        SELECT b.scb_dt
          INTO l_res
          FROM v_socialcard  t
               JOIN v_sc_change ch ON (ch.scc_id = t.sc_scc)
               JOIN v_sc_birth b ON (b.scb_id = ch.scc_scb)
         WHERE t.sc_id = p_sc_id;

        RETURN l_res;
    END;

    -- Стать (0 - код, 1 - назва)
    FUNCTION GET_GENDER (P_SC_ID IN NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (100);
    BEGIN
        SELECT CASE WHEN p_mode = 0 THEN i.sci_gender ELSE g.DIC_NAME END
          INTO l_res
          FROM v_socialcard  t
               JOIN v_sc_change ch ON (ch.scc_id = t.sc_scc)
               JOIN v_sc_identity i ON (i.sci_id = ch.scc_sci)
               LEFT JOIN uss_ndi.v_ddn_gender g
                   ON (g.DIC_VALUE = i.sci_gender)
         WHERE t.sc_id = p_sc_id;

        RETURN l_res;
    END;

    -- Дата смерті
    FUNCTION get_death_dt (p_sc_id IN NUMBER, p_mode IN NUMBER DEFAULT 0)
        RETURN DATE
    IS
        l_res   DATE;
    BEGIN
        SELECT b.sch_dt
          INTO l_res
          FROM v_socialcard  t
               JOIN v_sc_change ch ON (ch.scc_id = t.sc_scc)
               JOIN v_sc_death b ON (b.sch_id = ch.scc_sch)
         WHERE t.sc_id = p_sc_id;

        RETURN l_res;
    END;

    -- info:   Отримання ідентифікаційного коду
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_numident (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   sc_document.scd_number%TYPE;
    BEGIN
        SELECT d.scd_number
          INTO v_res
          FROM v_sc_document d
         WHERE     d.scd_st = '1'
               AND d.scd_ndt IN (5, 10366)
               AND d.scd_sc = p_sc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання ідентифікаційного коду по зрізу
    -- params: p_scс_id - ідентифікатор зрізу соціальної картки
    -- note:
    FUNCTION get_numident_scc (p_scc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   sc_document.scd_number%TYPE;
    BEGIN
        SELECT d.scd_number
          INTO v_res
          FROM v_sc_document d JOIN v_sc_change g ON (g.scc_sc = d.scd_sc)
         WHERE     d.scd_st = '1'
               AND d.scd_ndt IN (5, 10366)
               AND g.scc_id = p_scc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання номеру ідентифікаційного документу
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_doc_num (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (100);
    BEGIN
        SELECT t.scd_seria || t.scd_number
          INTO v_res
          FROM Sc_Document  t
               JOIN uss_ndi.v_ndi_document_type pt ON (pt.ndt_id = t.scd_ndt)
         WHERE     Scd_Sc = P_Sc_Id
               AND pt.ndt_ndc = 13
               AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
               AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
               AND Scd_St IN ('1', 'A')
         FETCH FIRST ROW ONLY;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання № довідки ВПО
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_vpo_num (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   sc_document.scd_number%TYPE;
    BEGIN
        SELECT Uss_Doc.Api$documents.Get_Attr_Val_Str ('DSN', d.scd_dh)
          INTO v_res
          FROM v_sc_document d
         WHERE d.scd_st = '1' AND d.scd_ndt = 10052 AND d.scd_sc = p_sc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання актуальної адреси
    -- params: p_sc_id - ідентифікатор соціальної картки
    --         p_sca_tp - тип адреси
    -- note:
    FUNCTION get_address (p_sc_id IN NUMBER, p_sca_tp IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT    d.sca_city
               || ' '
               || d.sca_street
               || CASE
                      WHEN d.sca_building IS NOT NULL THEN ' буд. '
                      ELSE ' '
                  END
               || d.sca_building
               || CASE
                      WHEN d.sca_apartment IS NOT NULL THEN ' кв. '
                      ELSE ' '
                  END
               || d.sca_apartment
          INTO v_res
          FROM Socialcard s JOIN Sc_Address d ON (d.Sca_Sc = s.sc_id)
         WHERE     s.Sc_Id = p_Sc_Id
               AND d.sca_tp = p_sca_tp
               AND d.history_status = 'A';

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_disability_group (p_sc_id   IN NUMBER,
                                   p_date    IN DATE DEFAULT NULL)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (10);
    BEGIN
        IF p_date IS NULL
        THEN
              SELECT d.scy_group
                INTO v_res
                FROM sc_disability d
               WHERE d.scy_sc = p_sc_id AND d.history_status = 'A'
            ORDER BY d.scy_id DESC
               FETCH FIRST ROW ONLY;
        ELSE
              SELECT d.scy_group
                INTO v_res
                FROM sc_disability d
               WHERE     d.scy_sc = p_sc_id
                     AND p_date BETWEEN d.scy_start_dt
                                    AND NVL (
                                            d.scy_stop_dt,
                                            TO_DATE ('31.12.2999',
                                                     'DD.MM.YYYY'))
            ORDER BY d.scy_id DESC
               FETCH FIRST ROW ONLY;
        END IF;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання категорії інвалідності дитини
    -- params: p_sc_id - ідентифікатор соціальної картки
    -- note:
    FUNCTION get_inv_child (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   sc_document.scd_number%TYPE;
    BEGIN
          SELECT Uss_Doc.Api$documents.Get_Attr_Val_Str (797, d.scd_dh)
            INTO v_res
            FROM sc_document d
           WHERE d.scd_st = '1' AND d.scd_ndt = 200 AND d.scd_sc = p_sc_id
        ORDER BY d.scd_id DESC
           FETCH FIRST ROW ONLY;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_full_address_text (p_sc_id IN NUMBER, p_sca_tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT CASE
                   WHEN kaot_tp = 'B'
                   THEN
                          CASE
                              WHEN TRIM (kaot.l4_kaot_full_name) IS NOT NULL
                              THEN
                                  kaot.l4_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (kaot.l5_kaot_full_name) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN TRIM (kaot.l4_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l5_kaot_full_name
                          END
                       || CASE
                              WHEN     TRIM (kaot.l3_kaot_full_name)
                                           IS NOT NULL
                                   AND kaot.kaot_kaot_l3 <> kaot.kaot_kaot_l4
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l3_kaot_full_name
                          END
                       || CASE
                              WHEN     TRIM (kaot.l2_kaot_full_name)
                                           IS NOT NULL
                                   AND kaot.kaot_kaot_l2 <> kaot.kaot_kaot_l4
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name
                                                  || kaot.l3_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l2_kaot_full_name
                          END
                       || CASE
                              WHEN     TRIM (kaot.l1_kaot_full_name)
                                           IS NOT NULL
                                   AND kaot.kaot_kaot_l1 <> kaot.kaot_kaot_l4
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name
                                                  || kaot.l3_kaot_full_name
                                                  || kaot.l2_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l1_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (sca.sca_street) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN LOWER (TRIM (sca.sca_street)) LIKE
                                                  '%вул%'
                                         THEN
                                             ', '
                                         ELSE
                                             ', вул. '
                                     END
                                  || sca.sca_street
                          END
                       || CASE
                              WHEN TRIM (sca.sca_building) IS NOT NULL
                              THEN
                                  ', буд. ' || sca.sca_building
                          END
                       || CASE
                              WHEN sca.sca_block IS NOT NULL
                              THEN
                                  ', корпус ' || sca.sca_block
                          END
                       || CASE
                              WHEN sca.sca_apartment IS NOT NULL
                              THEN
                                  ', кв. ' || sca.sca_apartment
                          END
                   ELSE
                          CASE
                              WHEN TRIM (kaot.l5_kaot_full_name) IS NOT NULL
                              THEN
                                  kaot.l5_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (kaot.l4_kaot_full_name) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN TRIM (kaot.l5_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l4_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (kaot.l3_kaot_full_name) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l3_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (kaot.l2_kaot_full_name) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name
                                                  || kaot.l3_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l2_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (kaot.l1_kaot_full_name) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN TRIM (
                                                     kaot.l5_kaot_full_name
                                                  || kaot.l4_kaot_full_name
                                                  || kaot.l3_kaot_full_name
                                                  || kaot.l2_kaot_full_name)
                                                  IS NOT NULL
                                         THEN
                                             ', '
                                     END
                                  || kaot.l1_kaot_full_name
                          END
                       || CASE
                              WHEN TRIM (sca.sca_street) IS NOT NULL
                              THEN
                                     CASE
                                         WHEN LOWER (TRIM (sca.sca_street)) LIKE
                                                  '%вул%'
                                         THEN
                                             ', '
                                         ELSE
                                             ', вул. '
                                     END
                                  || sca.sca_street
                          END
                       || CASE
                              WHEN TRIM (sca.sca_building) IS NOT NULL
                              THEN
                                  ', буд. ' || sca.sca_building
                          END
                       || CASE
                              WHEN sca.sca_block IS NOT NULL
                              THEN
                                  ', корпус ' || sca.sca_block
                          END
                       || CASE
                              WHEN sca.sca_apartment IS NOT NULL
                              THEN
                                  ', кв. ' || sca.sca_apartment
                          END
               END    sc_address
          INTO v_res
          FROM uss_person.v_socialcard  sc
               JOIN uss_person.v_sc_address sca
                   ON     sc.sc_id = sca.sca_sc
                      AND sca.sca_tp = p_sca_tp
                      AND sca.history_status = 'A'
               JOIN uss_ndi.mv_ndi_katottg kaot
                   ON sca.sca_kaot = kaot.kaot_id
         WHERE sc.sc_id = p_sc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_phone_mob (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (500);
    BEGIN
        SELECT sct.sct_phone_mob
          INTO v_res
          FROM uss_person.v_socialcard  sc
               JOIN uss_person.v_Sc_Change scc ON sc.sc_scc = scc.scc_id
               JOIN uss_person.v_sc_contact sct ON scc.scc_sct = sct.sct_id
         WHERE sc.sc_id = p_sc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_phone (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (500);
    BEGIN
        SELECT sct.sct_phone_num
          INTO v_res
          FROM uss_person.v_socialcard  sc
               JOIN uss_person.v_Sc_Change scc ON sc.sc_scc = scc.scc_id
               JOIN uss_person.v_sc_contact sct ON scc.scc_sct = sct.sct_id
         WHERE sc.sc_id = p_sc_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --#112827
    PROCEDURE get_dzr_by_sc (p_sc_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT w.wrn_id AS id, w.wrn_name AS name, w.wrn_shifr AS code
              FROM uss_ndi.v_ndi_cbi_wares  w
                   JOIN sc_dzr_recomm r ON w.wrn_id = r.scdr_wrn
             WHERE r.scdr_sc = p_sc_id AND r.history_status = 'A';
    END;

    --#113305
    FUNCTION get_dzr_attr_value_by_sc (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (r.scdr_wrn, ',')
          INTO l_res
          FROM sc_dzr_recomm r
         WHERE r.scdr_sc = p_sc_id AND r.history_status = 'A';

        RETURN l_res;
    END;

    PROCEDURE Get_Passport (p_Sc_Id    IN     NUMBER,
                            p_Ndt         OUT NUMBER,
                            p_Seria       OUT VARCHAR2,
                            p_Number      OUT VARCHAR2)
    IS
    BEGIN
          SELECT p.Scd_Ndt, p.Scd_Seria, p.Scd_Number
            INTO p_Ndt, p_Seria, p_Number
            FROM Sc_Document p
           WHERE     p.Scd_Sc = p_Sc_Id
                 AND p.Scd_Ndt IN (6, 7)
                 AND p.scd_st IN ('A', '1')
        ORDER BY (p.Scd_Start_Dt) DESC
           FETCH FIRST ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    FUNCTION get_sc_dzr_recomm (p_sc_id IN NUMBER)
        RETURN t_sc_dzr_recomm
        PIPELINED
    IS
    BEGIN
        FOR xx
            IN (SELECT t.*,
                       w.wrn_shifr,
                       w.wrn_name,
                       w.wrn_issue_max,
                       w.wrn_mult_qnt,
                       w.wrn_issue_desc
                  FROM sc_dzr_recomm  t
                       JOIN uss_ndi.v_ndi_cbi_wares w
                           ON (w.wrn_id = t.scdr_wrn)
                 WHERE     t.scdr_sc = p_sc_id
                       AND w.wrn_st = 'A'
                       AND t.history_status = 'A')
        LOOP
            PIPE ROW (r_sc_dzr_recomm (xx.scdr_id,
                                       xx.scdr_sc,
                                       xx.scdr_wrn,
                                       xx.scdr_is_need,
                                       xx.scdr_scd,
                                       xx.scdr_src,
                                       xx.scdr_src_id,
                                       xx.history_status,
                                       xx.scdr_src_dt,
                                       xx.wrn_shifr,
                                       xx.wrn_name,
                                       xx.wrn_issue_max,
                                       xx.wrn_mult_qnt,
                                       xx.wrn_issue_desc));
        END LOOP;
    END;

    FUNCTION get_sc_doc (p_sc_id IN NUMBER, p_ndt_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_scd_id   NUMBER;
    BEGIN
        SELECT MAX (t.scd_id)
          INTO l_scd_id
          FROM sc_document t
         WHERE     t.scd_sc = p_sc_id
               AND t.scd_ndt = p_ndt_id
               AND t.scd_st IN ('1', 'A');

        RETURN l_scd_id;
    END;

    FUNCTION get_sc_doc_val_str (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_dh   NUMBER;
    BEGIN
        SELECT MAX (t.scd_dh)
          INTO l_dh
          FROM sc_document t
         WHERE t.scd_id = p_scd_id;

        IF (l_dh IS NULL)
        THEN
            RETURN NULL;
        END IF;

        RETURN Uss_Doc.Api$documents.Get_Attr_Val_Str (p_nda_Id, l_dh);
    END;

    FUNCTION get_sc_doc_val_id (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_dh   NUMBER;
    BEGIN
        SELECT MAX (t.scd_dh)
          INTO l_dh
          FROM sc_document t
         WHERE t.scd_id = p_scd_id;

        IF (l_dh IS NULL)
        THEN
            RETURN NULL;
        END IF;

        RETURN Uss_Doc.Api$documents.Get_Attr_Val_Id (p_nda_Id, l_dh);
    END;

    FUNCTION get_sc_doc_val_int (p_scd_id IN NUMBER, p_nda_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_dh   NUMBER;
    BEGIN
        SELECT MAX (t.scd_dh)
          INTO l_dh
          FROM sc_document t
         WHERE t.scd_id = p_scd_id;

        IF (l_dh IS NULL)
        THEN
            RETURN NULL;
        END IF;

        RETURN Uss_Doc.Api$documents.Get_Attr_Val_Int (p_nda_Id, l_dh);
    END;
BEGIN
    NULL;
END API$SC_TOOLS;
/