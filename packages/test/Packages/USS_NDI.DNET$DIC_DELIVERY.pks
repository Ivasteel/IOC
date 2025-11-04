/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_DELIVERY
IS
    -- инфо по доставочному участку
    PROCEDURE GetDeliveryInfo (p_nd_id   IN     NUMBER,
                               res_cur      OUT SYS_REFCURSOR,
                               day_cur      OUT SYS_REFCURSOR,
                               ref_cur      OUT SYS_REFCURSOR);

    PROCEDURE GetDeliverybyNS (p_ns_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- Отримання інформації щодо доставочної дільниці та дня доставки за адресою
    PROCEDURE GetDeliverybyadress (p_ns_id     IN     NUMBER, -- for test ns_id = 288
                                   p_bld       IN     VARCHAR2,
                                   p_aprt      IN     NUMBER,
                                   p_nd           OUT NUMBER,
                                   p_nd_day       OUT NUMBER,
                                   p_message      OUT VARCHAR2);

    ----------------------------------------
    --------- КАРТКА ДД --------------------

    PROCEDURE delivery_journal (p_nd_code      IN     VARCHAR2,
                                p_nd_comment   IN     VARCHAR2,
                                p_nd_npo       IN     VARCHAR2,
                                p_nd_tp        IN     VARCHAR2,
                                p_org_id       IN     NUMBER,
                                p_kaot_id      IN     NUMBER,
                                p_res             OUT SYS_REFCURSOR);

    PROCEDURE get_delivery_card (p_nd_id   IN     ndi_delivery.nd_id%TYPE,
                                 p_main       OUT SYS_REFCURSOR,
                                 p_days       OUT SYS_REFCURSOR,
                                 p_ref        OUT SYS_REFCURSOR);


    -- збереження доставочної дільниці
    PROCEDURE SET_DELIVERY (P_ND_ID        IN OUT NUMBER,
                            P_ND_CODE      IN     VARCHAR,
                            P_ND_TP        IN     VARCHAR,
                            P_ND_COMMENT   IN     VARCHAR,
                            P_ND_NPO       IN     NUMBER);

    -- видалення (логічне) доставочної дільниці
    PROCEDURE DELETE_DELIVERY (P_ND_ID IN OUT NUMBER);

    -- збереження робочого дня доставочної дільниці
    PROCEDURE SET_DELIVERY_DAY (
        P_NDD_ID    IN OUT NDI_DELIVERY_DAY.NDD_ID%TYPE,
        P_NDD_ND    IN     NDI_DELIVERY_DAY.NDD_ND%TYPE,
        P_NDD_DAY   IN     NDI_DELIVERY_DAY.NDD_DAY%TYPE,
        P_NDD_NPT   IN     NDI_DELIVERY_DAY.NDD_NPT%TYPE);

    -- видалення (логічне) робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_DAY (P_NDD_ID NDI_DELIVERY_DAY.NDD_ID%TYPE);

    -- збереження налаштування робочого дня доставочної дільниці
    PROCEDURE SET_DELIVERY_REF (
        P_NDR_ID          IN OUT NDI_DELIVERY_REF.NDR_ID%TYPE,
        P_NDR_NDD         IN     NDI_DELIVERY_REF.NDR_NDD%TYPE,
        P_NDR_KAOT        IN     NDI_DELIVERY_REF.NDR_KAOT%TYPE,
        P_NDR_NS          IN     NDI_DELIVERY_REF.NDR_NS%TYPE,
        P_NDR_TP          IN     NDI_DELIVERY_REF.NDR_TP%TYPE,
        P_NDR_IS_EVEN     IN     NDI_DELIVERY_REF.NDR_IS_EVEN%TYPE,
        P_NDR_BLD_LIST    IN     NDI_DELIVERY_REF.NDR_BLD_LIST%TYPE,
        P_NDR_APRT_LIST   IN     NDI_DELIVERY_REF.NDR_APRT_LIST%TYPE);

    -- видалення (логічне) налаштування робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_REF (P_NDR_ID NDI_DELIVERY_REF.NDR_ID%TYPE);

    -- #103354: "Змінити відділення"
    PROCEDURE MOVE_DELIVERY_REF (P_ND_TO IN NUMBER, P_NDR_IDS IN VARCHAR2);
END;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_DELIVERY TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DELIVERY TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DELIVERY TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DELIVERY TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DELIVERY TO USS_ESR
/


/* Formatted on 8/12/2025 5:55:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_DELIVERY
IS
    -- инфо по доставочному участку
    PROCEDURE GetDeliveryInfo (p_nd_id   IN     NUMBER,
                               res_cur      OUT SYS_REFCURSOR,
                               day_cur      OUT SYS_REFCURSOR,
                               ref_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT nd.nd_code,
                   nd.nd_tp,
                   dtp.dic_sname     AS nd_tp_name,
                   nd.nd_comment,
                   nd.nd_npo,
                   npo.npo_index,
                   npo.npo_address
              FROM ndi_delivery  nd
                   JOIN ndi_post_office npo ON npo.npo_id = nd.nd_npo
                   JOIN v_ddn_dlvr_tp dtp ON dtp.dic_value = nd.nd_tp
             WHERE nd_id = p_nd_id;

        OPEN day_cur FOR
            SELECT nd.nd_id, ndd.ndd_id, ndd.ndd_day
              FROM ndi_delivery  nd
                   JOIN ndi_delivery_day ndd
                       ON nd.nd_id = ndd.ndd_nd AND ndd.history_status = 'A'
             WHERE nd_id = p_nd_id;

        OPEN ref_cur FOR
            SELECT ndr_id,
                   ndr_ndd,
                   ndr_kaot,
                   --ndr_nu,
                   ndr_ns,
                   ndr_tp,
                   rt.dic_sname           AS ndr_tp_name,
                   --ndr_is_even,
                   --ndr_bld_list,
                   --ndr_aprt_list,
                   --ndr_start,
                   --ndr_start_wu,
                   --ndr_end,
                   --ndr_end_wu,
                   ndr.history_status     AS ndr_st /*,
                        nu.nu_code,
                        nu.nu_name,
                        nu.nu_department,
                        nu.nu_edrpou*/
              FROM ndi_delivery  nd
                   JOIN ndi_delivery_day ndd
                       ON nd.nd_id = ndd.ndd_nd AND ndd.history_status = 'A'
                   JOIN ndi_delivery_ref ndr
                       ON     ndd.ndd_id = ndr.ndr_ndd
                          AND ndr.history_status = 'A'
                   JOIN ndi_post_office npo ON npo.npo_id = nd.nd_npo
                   JOIN v_ddn_dlvr_tp dtp ON dtp.dic_value = nd.nd_tp
                   JOIN v_ddn_dlvr_ref_tp rt ON rt.dic_value = ndr.ndr_tp
                   JOIN ndi_street ns ON ns.ns_id = ndr.ndr_ns
                   JOIN ndi_street_type nst ON nst.nsrt_id = ns.ns_nsrt
             --join ndi_unit nu on nu.nu_id = ndr.ndr_nu
             WHERE nd_id = p_nd_id;
    END;

    -- список домов и квартир по улице
    PROCEDURE GetDeliverybyNS (p_ns_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT /* ndr_id,
                    ndr_ndd, */
                   ndd.ndd_day,
                   ndd_nd,
                   nd.nd_code,
                   nd.nd_tp,
                   dtp.dic_sname     AS nd_tp_name,
                   nd.nd_comment,
                   nd.nd_npo,
                   npo.npo_index,
                   npo.npo_address,
                   /*ndr_kaot,
                   ndr_nu,
                   ndr_ns,
                   ndr_tp, */
                   rt.dic_sname      AS ndr_tp_name /*,
                         ndr_is_even,
                         ndr_bld_list,
                         ndr_aprt_list,
                         ndr_start,
                         ndr_start_wu,
                         ndr_end,
                         ndr_end_wu,
                         ndr.history_status AS ndr_st,
                         nu.nu_code,
                         nu.nu_name,
                         nu.nu_department,
                         nu.nu_edrpou*/
              FROM ndi_delivery_ref  ndr
                   JOIN ndi_delivery_day ndd
                       ON     ndd.ndd_id = ndr.ndr_ndd
                          AND ndd.history_status = 'A'
                   JOIN ndi_delivery nd ON nd.nd_id = ndd.ndd_nd
                   JOIN ndi_post_office npo ON npo.npo_id = nd.nd_npo
                   JOIN v_ddn_dlvr_tp dtp ON dtp.dic_value = nd.nd_tp
                   JOIN v_ddn_dlvr_ref_tp rt ON rt.dic_value = ndr.ndr_tp
             --join ndi_unit nu on nu.nu_id = ndr.ndr_nu
             WHERE ndr.history_status = 'A' AND ndr_ns = p_ns_id;
    END;

    PROCEDURE GetDeliverybyadress (p_ns_id     IN     NUMBER, -- идентификатор улицы -- for test ns_id = 288
                                   p_bld       IN     VARCHAR2,  -- номер дома
                                   p_aprt      IN     NUMBER, -- номер квартиры
                                   p_nd           OUT NUMBER, -- доставочная дельница
                                   p_nd_day       OUT NUMBER, -- день доставки
                                   p_message      OUT VARCHAR2)       -- error
    IS
        PROCEDURE dl (p_ns_id     NUMBER,
                      p_bld       VARCHAR2,
                      p_aprt      NUMBER,
                      p_nd        NUMBER,
                      p_nd_day    NUMBER,
                      p_message   VARCHAR2)
        IS
            PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
            INSERT INTO ndi_delivery_l (ndl_ns,
                                        ndl_bld,
                                        ndl_aprt,
                                        ndl_wu,
                                        ndl_nd,
                                        ndl_day,
                                        ndl_message)
                 VALUES (p_ns_id,
                         p_bld,
                         p_aprt,
                         SYS_CONTEXT ('IKISWEBADM', 'IKISUID'),
                         p_nd,
                         p_nd_day,
                         p_message);

            COMMIT;
        END;
    BEGIN
  FOR rec IN (
  WITH
      virt_rec AS
        (SELECT /*+ materialize */
           ndd.ndd_nd,ndd.ndd_day,ndr.ndr_id,ndr.ndr_ndd,ndr.ndr_kaot,/*ndr.ndr_nu,*/ndr.ndr_ns,
           COALESCE(ndr.ndr_bld_list, '1..9999') ndr_bld_list,
           COALESCE(ndr.ndr_aprt_list, '1..9999') ndr_aprt_list
         FROM ndi_delivery_ref ndr
           JOIN ndi_delivery_day ndd ON ndd.ndd_id = ndr.ndr_ndd
         WHERE ndr.ndr_ns = p_ns_id),
      bld_list AS
        (SELECT /*+ materialize */
           ndd_nd,ndd_day,ndr_id,ndr_ndd,ndr_kaot,/*ndr_nu,*/ndr_ns,
           REGEXP_SUBSTR(ndr_bld_list, '[^;]+', 1, LEVEL) AS bld,
           ndr_aprt_list
         FROM virt_rec CONNECT BY LEVEL <= LENGTH(REGEXP_REPLACE(ndr_bld_list, '[^;]+')) + 1),
      bld_diapazon AS
        (SELECT /*+ materialize */
           ndd_nd,ndd_day,ndr_id,ndr_ndd,ndr_kaot,/*ndr_nu,*/ndr_ns,
           bl.bld,
           SUBSTR(bl.bld, 1, INSTR(bl.bld, '..')-1) AS frst,
           SUBSTR(bl.bld, INSTR(bl.bld, '..')+2, 4) AS lst,
           ndr_aprt_list FROM bld_list bl WHERE bl.bld LIKE '%..%'),
      q AS (SELECT /*+ materialize */ LEVEL lvl FROM DUAL CONNECT BY LEVEL <= 9999)
    SELECT
      bl.ndd_nd,  -- доставочная дельница
      bl.ndd_day, -- день доставки
      bl.ndr_id,  -- ид адреса по дд
      bl.ndr_ndd, -- ид дня
      bl.ndr_kaot,-- город
      --bl.ndr_nu,  -- упсзн
      bl.ndr_ns,  -- улица
      bl.bld,     -- дом
      ndr_aprt_list -- список квартир
    FROM bld_list bl
    WHERE bl.bld NOT LIKE '%..%' AND bl.bld = REGEXP_REPLACE(p_bld,'(\D)+','')
    UNION
    SELECT
      bd.ndd_nd, -- доставочная дельница
      bd.ndd_day, -- день доставки
      bd.ndr_id, -- ид адреса по дд
      bd.ndr_ndd,  -- ид дня
      bd.ndr_kaot,  -- город
      --bd.ndr_nu,   -- упсзн
      bd.ndr_ns,   -- улица
      TO_CHAR(q.lvl),  -- дом
      bd.ndr_aprt_list  -- список квартир
    FROM bld_diapazon bd, q
    WHERE q.lvl BETWEEN bd.frst AND bd.lst AND TO_CHAR(q.lvl) = REGEXP_REPLACE(p_bld,'(\D)+','')
  )
  LOOP
    -- определение квартиры ---------------------------------------------------------------------------------------
    IF p_aprt IS NOT NULL THEN
      FOR rec_aprt IN (
      WITH
        aprt_list AS
          (SELECT /*+ materialize */
             REGEXP_SUBSTR(rec.ndr_aprt_list, '[^;]+', 1, LEVEL) AS aprt
             FROM DUAL CONNECT BY LEVEL <= LENGTH(REGEXP_REPLACE(rec.ndr_aprt_list, '[^;]+')) + 1),
        aprt_diapazon AS
          (SELECT /*+ materialize */
             al.aprt, SUBSTR(al.aprt, 1, INSTR(al.aprt, '..')-1) AS frst,
             SUBSTR(al.aprt, INSTR(al.aprt, '..')+2, 4) AS lst
           FROM aprt_list al WHERE al.aprt LIKE '%..%'),
        q AS (SELECT /*+ materialize */ LEVEL lvl FROM DUAL CONNECT BY LEVEL <= 9999)
      SELECT aprt FROM aprt_list WHERE aprt NOT LIKE '%..%' AND aprt = p_aprt
      UNION
      SELECT TO_CHAR(q.lvl) FROM aprt_diapazon ad, q WHERE q.lvl BETWEEN ad.frst AND ad.lst AND q.lvl = p_aprt)
      LOOP
        p_nd:= rec.ndd_nd;
        p_nd_day:= rec.ndd_day;
      END LOOP;
    ELSE
       p_nd:= rec.ndd_nd;
       p_nd_day:= rec.ndd_day;
    END IF;
  END LOOP;

        IF p_nd IS NULL
        THEN
            p_message :=
                'Дуже прикро, але доставочну дільницю за данною адресою не знайдено!';
        END IF;

        dl (p_ns_id,
            p_bld,
            p_aprt,
            p_nd,
            p_nd_day,
            p_message);
    END;

    ----------------------------------------
    --------- КАРТКА ДД --------------------


    PROCEDURE get_delivery_card (p_nd_id   IN     ndi_delivery.nd_id%TYPE,
                                 p_main       OUT SYS_REFCURSOR,
                                 p_days       OUT SYS_REFCURSOR,
                                 p_ref        OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (6);

        OPEN p_main FOR
            SELECT t.*, o.npo_index || ' ' || o.npo_address AS nd_npo_name
              FROM ndi_delivery  t
                   LEFT JOIN ndi_post_office o ON (o.npo_id = t.nd_npo)
             WHERE     t.history_status =
                       api$dic_visit.c_history_status_actual
                   AND t.nd_id = p_nd_id;

        OPEN p_days FOR SELECT t.*, 0 AS deleted
                          FROM ndi_delivery_day t
                         WHERE t.ndd_nd = p_nd_id AND t.history_status = 'A';

        OPEN p_ref FOR
            SELECT t.*,
                   d.ndd_day
                       AS ndr_Ndd_Name,
                   (SELECT MAX (zz.nsrt_name || ' ' || z.ns_name)
                      FROM v_ndi_street  z
                           JOIN ndi_street_type zz
                               ON (zz.nsrt_id = z.ns_nsrt)
                     WHERE z.ns_id = t.ndr_ns)
                       AS ndr_ns_name,
                   (SELECT MAX (
                               RTRIM (
                                      CASE
                                          WHEN     l1_name
                                                       IS NOT NULL
                                               AND l1_name !=
                                                   kaot_name
                                          THEN
                                              l1_name || ', '
                                      END
                                   || CASE
                                          WHEN     l2_name
                                                       IS NOT NULL
                                               AND l2_name !=
                                                   kaot_name
                                          THEN
                                              l2_name || ', '
                                      END
                                   || CASE
                                          WHEN     l3_name
                                                       IS NOT NULL
                                               AND l3_name !=
                                                   kaot_name
                                          THEN
                                              l3_name || ', '
                                      END
                                   || CASE
                                          WHEN     l4_name
                                                       IS NOT NULL
                                               AND l4_name !=
                                                   kaot_name
                                          THEN
                                              l4_name || ', '
                                      END
                                   || CASE
                                          WHEN     l5_name
                                                       IS NOT NULL
                                               AND l5_name !=
                                                   kaot_name
                                          THEN
                                              l5_name || ', '
                                      END
                                   || name_temp,
                                   ','))
                      FROM (SELECT Kaot_Id,
                                   CASE
                                       WHEN Kaot_Kaot_L1 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT    Dic_Sname
                                                   || ' '
                                                   || X1.Kaot_Name
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1,
                                                   uss_ndi.v_Ddn_Kaot_Tp
                                             WHERE     X1.Kaot_Id =
                                                       m.Kaot_Kaot_L1
                                                   AND Kaot_Tp =
                                                       Dic_Value)
                                   END             AS l1_name,
                                   CASE
                                       WHEN Kaot_Kaot_L2 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT    Dic_Sname
                                                   || ' '
                                                   || X1.Kaot_Name
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1,
                                                   uss_ndi.v_Ddn_Kaot_Tp
                                             WHERE     X1.Kaot_Id =
                                                       m.Kaot_Kaot_L2
                                                   AND Kaot_Tp =
                                                       Dic_Value)
                                   END             AS l2_name,
                                   CASE
                                       WHEN Kaot_Kaot_L3 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT    Dic_Sname
                                                   || ' '
                                                   || X1.Kaot_Name
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1,
                                                   uss_ndi.v_Ddn_Kaot_Tp
                                             WHERE     X1.Kaot_Id =
                                                       m.Kaot_Kaot_L3
                                                   AND Kaot_Tp =
                                                       Dic_Value)
                                   END             AS l3_name,
                                   CASE
                                       WHEN Kaot_Kaot_L4 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT    Dic_Sname
                                                   || ' '
                                                   || X1.Kaot_Name
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1,
                                                   uss_ndi.v_Ddn_Kaot_Tp
                                             WHERE     X1.Kaot_Id =
                                                       m.Kaot_Kaot_L4
                                                   AND Kaot_Tp =
                                                       Dic_Value)
                                   END             AS l4_name,
                                   CASE
                                       WHEN Kaot_Kaot_L5 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT    Dic_Sname
                                                   || ' '
                                                   || X1.Kaot_Name
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1,
                                                   uss_ndi.v_Ddn_Kaot_Tp
                                             WHERE     X1.Kaot_Id =
                                                       m.Kaot_Kaot_L5
                                                   AND Kaot_Tp =
                                                       Dic_Value)
                                   END             AS l5_name,
                                   kaot_name,
                                      tp.Dic_Sname
                                   || ' '
                                   || kaot_name    AS name_temp
                              FROM uss_ndi.v_Ndi_Katottg  m
                                   JOIN uss_ndi.v_Ddn_Kaot_Tp tp
                                       ON m.Kaot_Tp = tp.Dic_Code
                             WHERE Kaot_id = t.ndr_kaot) t)
                       AS ndr_kaot_name,
                   tp.dic_name
                       AS ndr_tp_name,
                   0
                       AS deleted
              FROM ndi_delivery_ref  t
                   JOIN ndi_delivery_day d ON (d.ndd_id = t.ndr_ndd)
                   JOIN v_ddn_dlvr_ref_tp tp ON (tp.dic_value = t.ndr_tp)
             WHERE d.ndd_nd = p_nd_id AND t.history_status = 'A';
    END;

    PROCEDURE delivery_journal (p_nd_code      IN     VARCHAR2,
                                p_nd_comment   IN     VARCHAR2,
                                p_nd_npo       IN     VARCHAR2,
                                p_nd_tp        IN     VARCHAR2,
                                p_org_id       IN     NUMBER,
                                p_kaot_id      IN     NUMBER,
                                p_res             OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (6);

        OPEN p_res FOR
            SELECT nd.nd_id,
                   nd.nd_code,
                   nd.nd_comment,
                   -- NDI_POST_OFFICE
                   nd.nd_npo,
                   nd.nd_tp,
                   dt.dic_sname,
                   po.npo_index || ' ' || po.npo_address     AS npo_address
              FROM ndi_delivery  nd
                   LEFT JOIN v_ddn_dlvr_tp dt ON (dt.dic_code = nd.nd_tp)
                   LEFT JOIN v_ndi_post_office po ON (po.npo_id = nd.nd_npo)
             WHERE     nd.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_nd_comment IS NULL
                        OR nd.nd_comment LIKE '%' || p_nd_comment || '%'
                        OR nd.nd_comment LIKE p_nd_comment || '%')
                   AND (p_nd_code IS NULL OR nd.nd_code = p_nd_code)
                   AND (p_nd_npo IS NULL OR nd.nd_npo = p_nd_npo)
                   AND (p_nd_tp IS NULL OR nd.nd_tp = p_nd_tp)
                   AND (p_org_id IS NULL OR po.npo_org = p_org_id)
                   AND (p_kaot_id IS NULL OR po.npo_kaot = p_kaot_id)
                   AND ROWNUM <= 500;
    END;


    -- збереження доставочної дільниці
    PROCEDURE SET_DELIVERY (P_ND_ID        IN OUT NUMBER,
                            P_ND_CODE      IN     VARCHAR,
                            P_ND_TP        IN     VARCHAR,
                            P_ND_COMMENT   IN     VARCHAR,
                            P_ND_NPO       IN     NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.set_delivery (p_nd_id,
                                       p_nd_code,
                                       p_nd_tp,
                                       p_nd_comment,
                                       p_nd_npo);
    END;


    -- видалення (логічне) доставочної дільниці
    PROCEDURE DELETE_DELIVERY (P_ND_ID IN OUT NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.DELETE_DELIVERY (p_nd_id);
    END;

    -- збереження робочого дня доставочної дільниці
    PROCEDURE SET_DELIVERY_DAY (
        P_NDD_ID    IN OUT NDI_DELIVERY_DAY.NDD_ID%TYPE,
        P_NDD_ND    IN     NDI_DELIVERY_DAY.NDD_ND%TYPE,
        P_NDD_DAY   IN     NDI_DELIVERY_DAY.NDD_DAY%TYPE,
        P_NDD_NPT   IN     NDI_DELIVERY_DAY.NDD_NPT%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.SET_DELIVERY_DAY (p_ndd_id,
                                           p_ndd_nd,
                                           p_ndd_day,
                                           p_ndd_npt);
    END;


    -- видалення (логічне) робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_DAY (P_NDD_ID NDI_DELIVERY_DAY.NDD_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.DELETE_DELIVERY_DAY (p_ndd_id);
    END;

    -- збереження налаштування робочого дня доставочної дільниці
    PROCEDURE SET_DELIVERY_REF (
        P_NDR_ID          IN OUT NDI_DELIVERY_REF.NDR_ID%TYPE,
        P_NDR_NDD         IN     NDI_DELIVERY_REF.NDR_NDD%TYPE,
        P_NDR_KAOT        IN     NDI_DELIVERY_REF.NDR_KAOT%TYPE,
        P_NDR_NS          IN     NDI_DELIVERY_REF.NDR_NS%TYPE,
        P_NDR_TP          IN     NDI_DELIVERY_REF.NDR_TP%TYPE,
        P_NDR_IS_EVEN     IN     NDI_DELIVERY_REF.NDR_IS_EVEN%TYPE,
        P_NDR_BLD_LIST    IN     NDI_DELIVERY_REF.NDR_BLD_LIST%TYPE,
        P_NDR_APRT_LIST   IN     NDI_DELIVERY_REF.NDR_APRT_LIST%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.SET_DELIVERY_REF (p_ndr_id,
                                           p_ndr_ndd,
                                           p_ndr_kaot,
                                           p_ndr_ns,
                                           p_ndr_tp,
                                           p_ndr_is_even,
                                           p_ndr_bld_list,
                                           p_ndr_aprt_list);
    END;

    -- видалення (логічне) налаштування робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_REF (P_NDR_ID NDI_DELIVERY_REF.NDR_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (6);
        api$dic_delivery.DELETE_DELIVERY_REF (P_NDR_ID);
    END;

    -- #103354: "Змінити відділення"
    PROCEDURE MOVE_DELIVERY_REF (P_ND_TO IN NUMBER, P_NDR_IDS IN VARCHAR2)
    IS
        l_ndd_to   NUMBER;
        l_cnt      NUMBER;
    BEGIN
        FOR xx
            IN (SELECT t.ndr_id,
                       d.ndd_id,
                       d.ndd_day,
                       d.ndd_nd,
                       d2.ndd_id     AS ndd_to
                  FROM ndi_delivery_ref  t
                       JOIN ndi_delivery_day d ON (d.ndd_id = t.ndr_ndd)
                       LEFT JOIN ndi_delivery_day d2
                           ON (d2.ndd_day = d.ndd_day AND d2.ndd_nd = p_nd_to)
                 WHERE t.ndr_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS z_rdt_id
                                  FROM (SELECT P_NDR_IDS AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0))
        LOOP
            l_ndd_to := xx.ndd_to;

            IF (l_ndd_to IS NULL)
            THEN
                INSERT INTO ndi_delivery_day (ndd_nd,
                                              ndd_day,
                                              history_status)
                     VALUES (P_ND_TO, xx.ndd_day, 'A')
                  RETURNING ndd_id
                       INTO l_ndd_to;
            END IF;

            UPDATE ndi_delivery_ref t
               SET t.ndr_ndd = l_ndd_to
             WHERE t.ndr_id = xx.ndr_id;

            SELECT COUNT (*)
              INTO l_cnt
              FROM ndi_delivery_ref t
             WHERE t.ndr_ndd = xx.ndd_id AND t.history_status = 'A';

            -- якщо на дату немає вже актуальних маршрутів, видаляємо дату
            IF (l_cnt = 0)
            THEN
                api$dic_delivery.DELETE_DELIVERY_DAY (xx.ndd_id);
            END IF;
        END LOOP;
    END;
END;
/