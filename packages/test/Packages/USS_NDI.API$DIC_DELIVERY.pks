/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_DELIVERY
IS
    -- верифікація на однлзначне визначення доставочної дільниці та дня доставки за адресою
    /*procedure CheckRefDeliveryByNS(
      p_ns in number,
      p_message out varchar2);*/

    ---------------------------------------
    -------------- КАРТКА ДД --------------

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
END;
/


GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_DELIVERY TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_DELIVERY
IS
    -- создание/редактирование доставочного участка
    PROCEDURE SetDelivery (p_nd_id        IN OUT NUMBER,
                           p_nd_code      IN     VARCHAR,
                           p_nd_tp        IN     VARCHAR,
                           p_nd_comment   IN     VARCHAR,
                           p_nd_npo       IN     NUMBER,
                           p_nd_st        IN     VARCHAR,
                           p_nd_day       IN     VARCHAR2,
                           p_nd_address   IN     VARCHAR2)
    IS
    BEGIN
        --if p_nd_id is null then

        --else

        -- end if;
        NULL;
    END;



    /*procedure CheckRefDeliveryByNS(
      p_ns in number,
      p_message out varchar2)
    is
      l_ns_name  ndi_street.ns_name%type;

      ex_EmptyNS exception;
      ex_BadNs   exception;
    begin
      if p_ns is null then
        raise ex_EmptyNS;
      else
        BEGIN
          --#74860  2022.01.24
          --select ns.ns_name into l_ns_name from ndi_street ns where ns.ns_id = p_ns;
          SELECT (CASE WHEN nsrt_name IS NOT NULL THEN nsrt_name||' ' ELSE 'вул. ' END)||'"'||ns_name||'"'
                 INTO l_ns_name
          FROM uss_ndi.v_ndi_street LEFT JOIN uss_ndi.V_NDI_STREET_TYPE ON ns_nsrt = nsrt_id
          WHERE ns_id = p_ns;
        exception when NO_DATA_FOUND then
          raise ex_BadNs;
        end;
      end if;

      p_message:= 'Знайденні дублі для ' ||l_ns_name||':';

      for rec in (
      select
      distinct
        count(distinct aprt) over (partition by vt.bld) as cnt,
        vt.bld
      from (
        with
        virt_rec as
          (select \*+ materialize *\
             ndd.ndd_nd, ndd.ndd_day,ndr.ndr_ndd,ndr.ndr_kaot,\*ndr.ndr_nu*\ '' ndr_nu,ndr.ndr_ns,ndr.ndr_tp,
             coalesce(ndr.ndr_bld_list, '1..999') as ndr_bld_list,
             ndr.ndr_aprt_list as ndr_aprt_list
           from ndi_delivery_ref ndr
             join ndi_delivery_day ndd on ndd.ndd_id = ndr.ndr_ndd
           where ndr.ndr_ns = 288),
        bld_list as
          (select \*+ materialize *\
             ndd_nd, ndd_day, ndr_ndd, ndr_kaot, ndr_nu, ndr_ns, ndr_tp,
             regexp_substr(ndr_bld_list, '[^;]+', 1, level) as bld,
             ndr_aprt_list
           from virt_rec connect by level <= length(regexp_replace(ndr_bld_list, '[^;]+')) + 1),
        bld_diapazon as
          (select \*+ materialize *\
             ndd_nd, ndd_day,ndr_ndd,ndr_kaot,ndr_nu,ndr_ns,ndr_tp,
             bl.bld,
             substr(bl.bld, 1, instr(bl.bld, '..')-1) as frst,
             substr(bl.bld, instr(bl.bld, '..')+2, 4) as lst,
             ndr_aprt_list from bld_list bl where bl.bld like '%..%'),
        q as (select \*+ materialize *\ level lvl from dual connect by level <= 999),
        aprt_list as
          (select
           distinct
             ndd_nd,ndd_day,ndr_ndd,ndr_kaot,ndr_nu,ndr_ns,ndr_tp,bld,
             regexp_substr(ndr_aprt_list, '[^;]+', 1, level) as aprt
           from bld_list
           where ndr_tp = 3
           connect by level <= length(regexp_replace(ndr_aprt_list, '[^;]+')) + 1),
        aprt_diapazon as
          (select \*+ materialize *\
           distinct
             ndd_nd,ndd_day,ndr_ndd,ndr_kaot,ndr_nu,ndr_ns,ndr_tp,bld,aprt,
             substr(ap.aprt, 1, instr(ap.aprt, '..')-1) as st,
             substr(ap.aprt, instr(ap.aprt, '..')+2, 4) as en from aprt_list ap where ap.aprt like '%..%'),
        a as (select \*+ materialize *\ level lvl from dual connect by level <= 999)
        --------------------------------------------------------------------------------
        select distinct
            bl.ndd_nd,  -- доставочная дельница
            bl.ndd_day, -- день доставки
            bl.ndr_ndd, -- ид дня
            bl.ndr_kaot,-- город
            bl.ndr_nu,  -- упсзн
            bl.ndr_ns,  -- улица
            bl.bld,     -- дом
            to_number(al.aprt) as aprt  -- квартира
          from bld_list bl
            join aprt_list al on al.ndd_nd=bl.ndd_nd
                             and al.ndd_day=bl.ndd_day
                             and al.ndr_ndd=bl.ndr_ndd
                             and al.ndr_ns=bl.ndr_ns
                             and al.bld=bl.bld
                             and al.aprt not like '%..%'
          where bl.bld not like '%..%'
          union
          select bl.ndd_nd,bl.ndd_day,bl.ndr_ndd,bl.ndr_kaot,bl.ndr_nu,bl.ndr_ns,bl.bld,a.lvl as aprt
          from bld_list bl
            join aprt_diapazon ad join a on a.lvl between ad.st and ad.en
                 on ad.ndd_nd=bl.ndd_nd
                             and ad.ndd_day=bl.ndd_day
                             and ad.ndr_ndd=bl.ndr_ndd
                             and ad.ndr_ns=bl.ndr_ns
                             and ad.bld=bl.bld
          where bl.bld not like '%..%'
          union
          select
            bd.ndd_nd, bd.ndd_day, bd.ndr_ndd, bd.ndr_kaot, bd.ndr_nu, bd.ndr_ns, to_char(q.lvl), a.lvl as aprt
          from bld_diapazon bd
            join q on q.lvl between bd.frst and bd.lst
            join a on a.lvl between 1 and 999
      ) vt
      group by vt.bld, vt.aprt
      having count(distinct vt.ndr_ndd) > 1
      )
      loop
        p_message:= p_message||chr(10)||'  - буд.'||rec.bld||' знайдено '||rec.cnt||' квартир(у), де неоднозначно вказано доставочну дільницю/дату доставки;';
      end loop;
      p_message:= nullif(p_message, 'Знайденні дублі для ' ||l_ns_name||':');
    end;*/


    ---------------------------------------
    -------------- КАРТКА ДД --------------


    -- збереження доставочної дільниці
    PROCEDURE SET_DELIVERY (P_ND_ID        IN OUT NUMBER,
                            P_ND_CODE      IN     VARCHAR,
                            P_ND_TP        IN     VARCHAR,
                            P_ND_COMMENT   IN     VARCHAR,
                            P_ND_NPO       IN     NUMBER)
    IS
        l_code   VARCHAR2 (10);
    BEGIN
        IF (p_nd_id IS NULL)
        THEN
            IF (p_nd_code = '000')
            THEN
                raise_application_error (
                    -20000,
                    'Створення ДД з кодом "000" заборонено!');
            END IF;

            INSERT INTO NDI_DELIVERY (ND_ID,
                                      ND_CODE,
                                      ND_TP,
                                      ND_COMMENT,
                                      ND_NPO,
                                      ND_ST,
                                      history_status)
                 VALUES (P_ND_ID,
                         P_ND_CODE,
                         P_ND_TP,
                         P_ND_COMMENT,
                         P_ND_NPO,
                         'A',
                         'A')
              RETURNING ND_ID
                   INTO P_ND_ID;
        ELSE
            SELECT t.nd_code
              INTO l_code
              FROM ndi_delivery t
             WHERE t.nd_id = P_ND_ID;

            IF (l_code = '000')
            THEN
                raise_application_error (
                    -20000,
                    'Редагування ДД з кодом "000" заборонено!');
            END IF;

            UPDATE NDI_DELIVERY
               SET ND_CODE = P_ND_CODE,
                   ND_TP = P_ND_TP,
                   ND_COMMENT = P_ND_COMMENT,
                   ND_NPO = P_ND_NPO
             WHERE ND_ID = P_ND_ID;
        END IF;
    END;

    -- видалення (логічне) доставочної дільниці
    PROCEDURE DELETE_DELIVERY (P_ND_ID IN OUT NUMBER)
    IS
        l_flag   NUMBER;
    BEGIN
        SELECT CASE WHEN t.nd_code = '000' THEN 1 ELSE 0 END
          INTO l_flag
          FROM ndi_delivery t
         WHERE t.nd_id = P_ND_ID;

        IF (l_flag = 1)
        THEN
            raise_application_error (
                -20000,
                'Доставочну дільницю з кодом "000" неможливо видалити!');
        END IF;

        UPDATE NDI_DELIVERY
           SET history_status = 'H'
         WHERE ND_ID = P_ND_ID;
    END;

    -- збереження робочого дня доставочної дільниці
    PROCEDURE SET_DELIVERY_DAY (
        P_NDD_ID    IN OUT NDI_DELIVERY_DAY.NDD_ID%TYPE,
        P_NDD_ND    IN     NDI_DELIVERY_DAY.NDD_ND%TYPE,
        P_NDD_DAY   IN     NDI_DELIVERY_DAY.NDD_DAY%TYPE,
        P_NDD_NPT   IN     NDI_DELIVERY_DAY.NDD_NPT%TYPE)
    IS
    BEGIN
        IF P_NDD_ID IS NULL OR p_ndd_id < 0
        THEN
            INSERT INTO NDI_DELIVERY_DAY (NDD_ND,
                                          NDD_DAY,
                                          NDD_NPT,
                                          HISTORY_STATUS)
                 VALUES (P_NDD_ND,
                         P_NDD_DAY,
                         P_NDD_NPT,
                         'A')
              RETURNING NDD_ID
                   INTO P_NDD_ID;
        ELSE
            UPDATE NDI_DELIVERY_DAY
               SET NDD_ND = P_NDD_ND,
                   NDD_DAY = P_NDD_DAY,
                   NDD_NPT = P_NDD_NPT
             WHERE NDD_ID = P_NDD_ID;
        END IF;
    END;

    -- видалення (логічне) робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_DAY (P_NDD_ID NDI_DELIVERY_DAY.NDD_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_DELIVERY_DAY T
           SET T.HISTORY_STATUS = 'H'
         WHERE T.NDD_ID = P_NDD_ID;
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
        IF NVL (P_NDR_ID, -1) < 0
        THEN
            INSERT INTO NDI_DELIVERY_REF (NDR_NDD,
                                          NDR_KAOT,
                                          NDR_NS,
                                          NDR_TP,
                                          NDR_IS_EVEN,
                                          NDR_BLD_LIST,
                                          NDR_APRT_LIST,
                                          HISTORY_STATUS)
                 VALUES (P_NDR_NDD,
                         P_NDR_KAOT,
                         P_NDR_NS,
                         P_NDR_TP,
                         P_NDR_IS_EVEN,
                         P_NDR_BLD_LIST,
                         P_NDR_APRT_LIST,
                         'A')
              RETURNING NDR_ID
                   INTO P_NDR_ID;
        ELSE
            UPDATE NDI_DELIVERY_REF
               SET NDR_NDD = P_NDR_NDD,
                   NDR_KAOT = P_NDR_KAOT,
                   NDR_NS = P_NDR_NS,
                   NDR_TP = P_NDR_TP,
                   NDR_IS_EVEN = NVL (P_NDR_IS_EVEN, NDR_IS_EVEN),
                   NDR_BLD_LIST = P_NDR_BLD_LIST,
                   NDR_APRT_LIST = P_NDR_APRT_LIST
             WHERE NDR_ID = P_NDR_ID;
        END IF;
    END;

    -- видалення (логічне) налаштування робочого дня доставочної дільниці
    PROCEDURE DELETE_DELIVERY_REF (P_NDR_ID NDI_DELIVERY_REF.NDR_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_DELIVERY_REF T
           SET T.HISTORY_STATUS = 'H'
         WHERE T.NDR_ID = P_NDR_ID;
    END;
END;
/