/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PARAMSESR
IS
    -- Author  : BOGDAN
    -- Created : 12.09.2022 15:22:35
    -- Purpose : DNET інтерфейс для параметрів ЕСР (#80031)

    -- список параметрів
    PROCEDURE GET_PARAMS (RES_CUR OUT SYS_REFCURSOR);

    -- картка параметру
    PROCEDURE GET_PARAM (P_PRM_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- редагування параметру
    PROCEDURE SET_PARAM (p_prm_id      IN paramsesr.prm_id%TYPE,
                         p_prm_name    IN paramsesr.prm_name%TYPE,
                         p_prm_value   IN paramsesr.prm_value%TYPE);
END DNET$PARAMSESR;
/


GRANT EXECUTE ON USS_ESR.DNET$PARAMSESR TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PARAMSESR TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PARAMSESR
IS
    -- список параметрів
    PROCEDURE GET_PARAMS (RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.*
              FROM paramsesr t
             WHERE t.prm_code IN
                       ('WAR_MARTIAL_LAW_END',
                        'VPO_END_BY_709',
                        'VPO_END_BY_94');
    END;

    -- картка параметру
    PROCEDURE GET_PARAM (P_PRM_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.*,
                   'DATE'                                                   AS prm_element_type,
                   CASE WHEN t.prm_code IN ('VPO_END_BY_709') THEN 1 END    AS is_disabled
              FROM paramsesr t
             WHERE     t.prm_code IN
                           ('WAR_MARTIAL_LAW_END',
                            'VPO_END_BY_709',
                            'VPO_END_BY_94')
                   AND t.prm_id = P_PRM_ID;
    END;


    -- редагування параметру
    PROCEDURE SET_PARAM (p_prm_id      IN paramsesr.prm_id%TYPE,
                         p_prm_name    IN paramsesr.prm_name%TYPE,
                         p_prm_value   IN paramsesr.prm_value%TYPE)
    IS
        l_prm   paramsesr%ROWTYPE;
    BEGIN
        --    IF p_prm_name = 'WAR_MARTIAL_LAW_END' THEN
        --      raise_application_error(-20000, 'Встановлення значень для параметру WAR_MARTIAL_LAW_END тимчасово відключено!');
        --    ELSE
        api$paramsesr.SET_PARAM (p_prm_name, p_prm_value);
    --    END IF;
    END;
BEGIN
    NULL;
END DNET$PARAMSESR;
/