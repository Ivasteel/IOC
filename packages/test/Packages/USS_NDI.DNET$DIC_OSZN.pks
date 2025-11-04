/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_OSZN
IS
    -- Author  : BOGDAN
    -- Created : 18.09.2023 16:34:09
    -- Purpose : Інтерфейси по веденню кадрового забезпечення ОСЗН

    --===============================================
    --                NDI_FUNCTIONARY
    --===============================================

    PROCEDURE SAVE_FUNCTIONARY (
        P_FNC_ID         IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
        --p_COM_ORG IN NDI_FUNCTIONARY.COM_ORG%TYPE,
        P_FNC_FN         IN     NDI_FUNCTIONARY.FNC_FN%TYPE,
        P_FNC_LN         IN     NDI_FUNCTIONARY.FNC_LN%TYPE,
        P_FNC_MN         IN     NDI_FUNCTIONARY.FNC_MN%TYPE,
        P_FNC_POST       IN     NDI_FUNCTIONARY.FNC_POST%TYPE,
        P_FNC_PHONE      IN     NDI_FUNCTIONARY.FNC_PHONE%TYPE,
        P_FNC_TP         IN     NDI_FUNCTIONARY.FNC_TP%TYPE,
        p_FNC_NOC        IN     NDI_FUNCTIONARY.FNC_NOC%TYPE,
        p_FNC_NSP        IN     NDI_FUNCTIONARY.FNC_NSP%TYPE,
        p_FNC_BIRTH_DT   IN     NDI_FUNCTIONARY.FNC_BIRTH_DT%TYPE,
        p_FNC_RNOKPP     IN     NDI_FUNCTIONARY.FNC_RNOKPP%TYPE,
        p_FNC_GENDER     IN     NDI_FUNCTIONARY.FNC_GENDER%TYPE,
        p_FNC_ST         IN     NDI_FUNCTIONARY.FNC_ST%TYPE,
        p_FNC_START_DT   IN     NDI_FUNCTIONARY.FNC_START_DT%TYPE,
        p_FNC_STOP_DT    IN     NDI_FUNCTIONARY.FNC_STOP_DT%TYPE,
        P_NEW_ID            OUT NDI_FUNCTIONARY.FNC_ID%TYPE);

    PROCEDURE DELETE_FUNCTIONARY (P_FNC_ID NDI_FUNCTIONARY.FNC_ID%TYPE);

    PROCEDURE GET_FUNCTIONARY (P_FNC_ID   IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
                               P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_FUNCTIONARY (p_fnc_fn      IN     VARCHAR2,
                                 p_fnc_ln      IN     VARCHAR2,
                                 p_fnc_mn      IN     VARCHAR2,
                                 p_fnc_nsp     IN     NUMBER,
                                 p_fnc_phone   IN     VARCHAR2,
                                 p_fnc_noc     IN     NUMBER,
                                 p_res            OUT SYS_REFCURSOR);


    --===============================================
    --                NDI_POSITION
    --===============================================

    PROCEDURE save_position (p_nsp_id     IN     ndi_position.nsp_id%TYPE,
                             p_nsp_code   IN     ndi_position.nsp_code%TYPE,
                             p_nsp_name   IN     ndi_position.nsp_name%TYPE,
                             p_nsp_st     IN     ndi_position.nsp_st%TYPE,
                             p_new_id        OUT ndi_position.nsp_id%TYPE);

    PROCEDURE delete_position (p_nsp_id ndi_position.nsp_id%TYPE);

    PROCEDURE get_position (p_nsp_id   IN     ndi_position.nsp_id%TYPE,
                            p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_position (p_res OUT SYS_REFCURSOR);


    --===============================================
    --                NDI_ORG_CHART
    --===============================================

    PROCEDURE save_org_chart (
        p_NOC_ID           IN     NDI_ORG_CHART.NOC_ID%TYPE,
        p_NOC_NOC_MASTER   IN     NDI_ORG_CHART.NOC_NOC_MASTER%TYPE,
        p_NOC_SHORT_NAME   IN     NDI_ORG_CHART.NOC_SHORT_NAME%TYPE,
        p_NOC_UNIT_NAME    IN     NDI_ORG_CHART.NOC_UNIT_NAME%TYPE,
        p_NOC_ST           IN     NDI_ORG_CHART.NOC_ST%TYPE,
        p_NOC_ADDRESS      IN     NDI_ORG_CHART.NOC_ADDRESS%TYPE,
        p_NOC_PHONE        IN     NDI_ORG_CHART.NOC_PHONE%TYPE,
        p_new_id              OUT NDI_ORG_CHART.NOC_ID%TYPE);

    PROCEDURE delete_org_chart (p_noc_id ndi_org_chart.noc_id%TYPE);

    PROCEDURE get_org_chart (p_noc_id   IN     ndi_org_chart.noc_id%TYPE,
                             p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_org_chart (p_res OUT SYS_REFCURSOR);

    -------------------------------------------------------
    ---          NDI_OS_POSITION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Список посад працівників НСП
    PROCEDURE GET_OS_POSITION_LIST (p_res OUT SYS_REFCURSOR);

    -- Картка посади працівників НСП
    PROCEDURE GET_OS_POSITION_CARD (p_osp_id   IN     NUMBER,
                                    p_res         OUT SYS_REFCURSOR);

    -- Зберегти посаду працівників НСП
    PROCEDURE SET_OS_POSITION (
        p_OSP_ID           IN     NDI_OS_POSITION.OSP_ID%TYPE,
        p_OSP_NAME         IN     NDI_OS_POSITION.OSP_NAME%TYPE,
        p_OSP_CODE         IN     NDI_OS_POSITION.OSP_CODE%TYPE,
        p_OSP_TP           IN     NDI_OS_POSITION.OSP_TP%TYPE,
        p_OSP_SPECIALIST   IN     NDI_OS_POSITION.OSP_SPECIALIST%TYPE,
        p_new_id              OUT NDI_OS_POSITION.OSP_ID%TYPE);

    -- Видалити посаду працівників НСП
    PROCEDURE Delete_OS_POSITION (p_osp_id NDI_OS_POSITION.OSP_ID%TYPE);

    -------------------------------------------------------
    ---       NDI_OS_SPECIALIZATION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Список спеціалізацій працівників НСП
    PROCEDURE GET_OS_SPEC_LIST (p_res OUT SYS_REFCURSOR);

    -- Картка cпеціалізації працівників НСП
    PROCEDURE GET_OS_SPEC_CARD (p_oss_id IN NUMBER, p_res OUT SYS_REFCURSOR);

    -- Зберегти cпеціалізацію працівників НСП
    PROCEDURE SET_OS_SPEC (
        p_OSS_ID     IN     NDI_OS_SPECIALIZATION.OSS_ID%TYPE,
        p_OSS_NAME   IN     NDI_OS_SPECIALIZATION.OSS_NAME%TYPE,
        p_new_id        OUT NDI_OS_SPECIALIZATION.OSS_ID%TYPE);

    -- Видалити cпеціалізацію працівників НСП
    PROCEDURE DELETE_OS_SPEC (p_oss_id NDI_OS_SPECIALIZATION.OSS_ID%TYPE);
END DNET$DIC_OSZN;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_OSZN TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_OSZN TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_OSZN TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_OSZN
IS
    --===============================================
    --                NDI_FUNCTIONARY
    --===============================================

    PROCEDURE save_functionary (
        p_fnc_id         IN     ndi_functionary.fnc_id%TYPE,
        --p_COM_ORG IN NDI_FUNCTIONARY.COM_ORG%TYPE,
        p_fnc_fn         IN     ndi_functionary.fnc_fn%TYPE,
        p_fnc_ln         IN     ndi_functionary.fnc_ln%TYPE,
        p_fnc_mn         IN     ndi_functionary.fnc_mn%TYPE,
        p_fnc_post       IN     ndi_functionary.fnc_post%TYPE,
        p_fnc_phone      IN     ndi_functionary.fnc_phone%TYPE,
        p_fnc_tp         IN     ndi_functionary.fnc_tp%TYPE,
        p_FNC_NOC        IN     NDI_FUNCTIONARY.FNC_NOC%TYPE,
        p_FNC_NSP        IN     NDI_FUNCTIONARY.FNC_NSP%TYPE,
        p_FNC_BIRTH_DT   IN     NDI_FUNCTIONARY.FNC_BIRTH_DT%TYPE,
        p_FNC_RNOKPP     IN     NDI_FUNCTIONARY.FNC_RNOKPP%TYPE,
        p_FNC_GENDER     IN     NDI_FUNCTIONARY.FNC_GENDER%TYPE,
        p_FNC_ST         IN     NDI_FUNCTIONARY.FNC_ST%TYPE,
        p_FNC_START_DT   IN     NDI_FUNCTIONARY.FNC_START_DT%TYPE,
        p_FNC_STOP_DT    IN     NDI_FUNCTIONARY.FNC_STOP_DT%TYPE,
        p_new_id            OUT ndi_functionary.fnc_id%TYPE)
    IS
        l_com_org   NUMBER;
    BEGIN
        tools.check_user_and_raise (8);
        l_com_org := tools.getcurrorg;

        API_DIC_OSZN.save_functionary (
            p_fnc_id           => p_fnc_id,
            p_com_org          => l_com_org,
            p_fnc_fn           => p_fnc_fn,
            p_fnc_ln           => p_fnc_ln,
            p_fnc_mn           => p_fnc_mn,
            p_fnc_post         => p_fnc_post,
            p_fnc_phone        => p_fnc_phone,
            p_fnc_tp           => p_fnc_tp,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_FNC_NOC          => p_FNC_NOC,
            p_FNC_NSP          => p_FNC_NSP,
            p_FNC_BIRTH_DT     => p_FNC_BIRTH_DT,
            p_FNC_RNOKPP       => p_FNC_RNOKPP,
            p_FNC_GENDER       => p_FNC_GENDER,
            p_FNC_ST           => p_FNC_ST,
            p_FNC_START_DT     => p_FNC_START_DT,
            p_FNC_STOP_DT      => p_FNC_STOP_DT,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_functionary (p_fnc_id ndi_functionary.fnc_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (8);
        API_DIC_OSZN.delete_functionary (
            p_fnc_id           => p_fnc_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_functionary (p_fnc_id   IN     ndi_functionary.fnc_id%TYPE,
                               p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        OPEN p_res FOR
            SELECT nf.*
              FROM ndi_functionary nf
             WHERE     nf.history_status =
                       api$dic_visit.c_history_status_actual
                   AND fnc_id = p_fnc_id;
    END;

    PROCEDURE query_functionary (p_fnc_fn      IN     VARCHAR2,
                                 p_fnc_ln      IN     VARCHAR2,
                                 p_fnc_mn      IN     VARCHAR2,
                                 p_fnc_nsp     IN     NUMBER,
                                 p_fnc_phone   IN     VARCHAR2,
                                 p_fnc_noc     IN     NUMBER,
                                 p_res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (11);

        OPEN p_res FOR
            SELECT nf.fnc_id,
                   -- OPFU
                   nf.com_org,
                   nf.fnc_fn,
                   nf.fnc_ln,
                   nf.fnc_mn,
                   nf.fnc_post,
                   nf.fnc_phone,
                   nf.fnc_tp,                                -- dft.dic_sname,
                   oc.noc_unit_name     AS noc_name,
                   sp.nsp_name
              FROM v_ndi_functionary  nf
                   -- LEFT JOIN v_ddn_fnc_tp dft ON (dft.dic_code = nf.fnc_tp)
                   LEFT JOIN v_ndi_org_chart oc ON (oc.noc_id = nf.fnc_noc)
                   LEFT JOIN v_ndi_position sp ON (sp.nsp_id = nf.fnc_nsp)
             WHERE     nf.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (p_fnc_fn IS NULL OR --nf.fnc_fn LIKE '%' || p_fnc_fn || '%' OR
                                            nf.fnc_fn LIKE p_fnc_fn || '%')
                   AND (p_fnc_ln IS NULL OR --nf.fnc_ln LIKE '%' || p_fnc_ln || '%' OR
                                            nf.fnc_ln LIKE p_fnc_ln || '%')
                   AND (p_fnc_mn IS NULL OR --nf.fnc_mn LIKE '%' || p_fnc_mn || '%' OR
                                            nf.fnc_mn LIKE p_fnc_mn || '%')
                   /*AND (p_fnc_post IS NULL OR nf.fnc_post LIKE '%' || p_fnc_post || '%' OR
                         nf.fnc_post LIKE p_fnc_post || '%')*/
                   AND (   p_fnc_phone IS NULL
                        OR nf.fnc_phone LIKE '%' || p_fnc_phone || '%')
                   AND (p_fnc_nsp IS NULL OR fnc_nsp = p_fnc_nsp)
                   AND (p_fnc_noc IS NULL OR fnc_noc = p_fnc_noc);
    END;

    --===============================================
    --                NDI_POSITION
    --===============================================

    PROCEDURE save_position (p_nsp_id     IN     ndi_position.nsp_id%TYPE,
                             p_nsp_code   IN     ndi_position.nsp_code%TYPE,
                             p_nsp_name   IN     ndi_position.nsp_name%TYPE,
                             p_nsp_st     IN     ndi_position.nsp_st%TYPE,
                             p_new_id        OUT ndi_position.nsp_id%TYPE)
    IS
        l_com_org   NUMBER;
    BEGIN
        tools.check_user_and_raise (8);
        l_com_org := tools.getcurrorg;

        API_DIC_OSZN.save_position (p_nsp_id     => p_nsp_id,
                                    p_nsp_name   => p_nsp_name,
                                    p_nsp_code   => p_nsp_code,
                                    p_nsp_st     => p_nsp_st,
                                    p_com_org    => l_com_org,
                                    p_new_id     => p_new_id);
    END;

    PROCEDURE delete_position (p_nsp_id ndi_position.nsp_id%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        tools.check_user_and_raise (8);

        SELECT COUNT (*)
          INTO l_cnt
          FROM v_ndi_functionary t
         WHERE t.fnc_nsp = p_nsp_id AND t.fnc_st = 'T';

        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'При активній посадовій особі видалення посади заборонене!');
        END IF;

        API_DIC_OSZN.delete_position (p_nsp_id => p_nsp_id);
    END;

    PROCEDURE get_position (p_nsp_id   IN     ndi_position.nsp_id%TYPE,
                            p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        OPEN p_res FOR SELECT t.*
                         FROM v_ndi_position t
                        WHERE t.nsp_id = p_nsp_id;
    END;

    PROCEDURE query_position (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (11);

        OPEN p_res FOR SELECT t.*
                         FROM v_ndi_position t
                        WHERE 1 = 1 AND t.nsp_st = 'T';
    END;

    --===============================================
    --                NDI_ORG_CHART
    --===============================================

    PROCEDURE save_org_chart (
        p_NOC_ID           IN     NDI_ORG_CHART.NOC_ID%TYPE,
        p_NOC_NOC_MASTER   IN     NDI_ORG_CHART.NOC_NOC_MASTER%TYPE,
        p_NOC_SHORT_NAME   IN     NDI_ORG_CHART.NOC_SHORT_NAME%TYPE,
        p_NOC_UNIT_NAME    IN     NDI_ORG_CHART.NOC_UNIT_NAME%TYPE,
        p_NOC_ST           IN     NDI_ORG_CHART.NOC_ST%TYPE,
        p_NOC_ADDRESS      IN     NDI_ORG_CHART.NOC_ADDRESS%TYPE,
        p_NOC_PHONE        IN     NDI_ORG_CHART.NOC_PHONE%TYPE,
        p_new_id              OUT NDI_ORG_CHART.NOC_ID%TYPE)
    IS
        l_com_org   NUMBER;
    BEGIN
        tools.check_user_and_raise (8);
        l_com_org := tools.getcurrorg;

        API_DIC_OSZN.save_org_chart (p_noc_id           => p_noc_id,
                                     p_NOC_NOC_MASTER   => p_NOC_NOC_MASTER,
                                     p_NOC_SHORT_NAME   => p_NOC_SHORT_NAME,
                                     p_NOC_UNIT_NAME    => p_NOC_UNIT_NAME,
                                     p_NOC_ST           => p_NOC_ST,
                                     p_NOC_ADDRESS      => p_NOC_ADDRESS,
                                     p_NOC_PHONE        => p_NOC_PHONE,
                                     p_com_org          => l_com_org,
                                     p_new_id           => p_new_id);
    END;

    PROCEDURE delete_org_chart (p_noc_id ndi_org_chart.noc_id%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        tools.check_user_and_raise (8);

        SELECT COUNT (*)
          INTO l_cnt
          FROM v_ndi_functionary t
         WHERE t.fnc_noc = p_noc_id AND t.fnc_st = 'T';

        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'При активній посадовій особі видалення оргструктури заборонене!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM v_ndi_org_chart t
         WHERE t.noc_noc_master = p_noc_id;

        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'Видалення оргструктури при наявних дочірніх оргструктурах заборонене!');
        END IF;

        API_DIC_OSZN.delete_org_chart (p_noc_id => p_noc_id);
    END;

    PROCEDURE get_org_chart (p_noc_id   IN     ndi_org_chart.noc_id%TYPE,
                             p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        OPEN p_res FOR SELECT t.*
                         FROM v_ndi_org_chart t
                        WHERE t.noc_id = p_noc_id;
    END;

    PROCEDURE query_org_chart (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (11);

        OPEN p_res FOR SELECT t.*
                         FROM v_ndi_org_chart t
                        WHERE 1 = 1 AND t.noc_st = 'T';
    END;

    -------------------------------------------------------
    ---          NDI_OS_POSITION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Список посад працівників НСП
    PROCEDURE GET_OS_POSITION_LIST (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_OS_POSITION t
                        WHERE t.history_status = 'A';
    END;

    -- Картка посади працівників НСП
    PROCEDURE GET_OS_POSITION_CARD (p_osp_id   IN     NUMBER,
                                    p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_OS_POSITION t
                        WHERE t.osp_id = p_osp_id;
    END;

    -- Зберегти посаду працівників НСП
    PROCEDURE SET_OS_POSITION (
        p_OSP_ID           IN     NDI_OS_POSITION.OSP_ID%TYPE,
        p_OSP_NAME         IN     NDI_OS_POSITION.OSP_NAME%TYPE,
        p_OSP_CODE         IN     NDI_OS_POSITION.OSP_CODE%TYPE,
        p_OSP_TP           IN     NDI_OS_POSITION.OSP_TP%TYPE,
        p_OSP_SPECIALIST   IN     NDI_OS_POSITION.OSP_SPECIALIST%TYPE,
        p_new_id              OUT NDI_OS_POSITION.OSP_ID%TYPE)
    IS
    BEGIN
        api_dic_oszn.set_os_position (p_OSP_ID           => p_OSP_ID,
                                      p_OSP_NAME         => p_OSP_NAME,
                                      p_OSP_CODE         => p_OSP_CODE,
                                      p_OSP_TP           => p_OSP_TP,
                                      p_OSP_SPECIALIST   => p_OSP_SPECIALIST,
                                      p_new_id           => p_new_id);
    END;

    -- Видалити посаду працівників НСП
    PROCEDURE Delete_OS_POSITION (p_osp_id NDI_OS_POSITION.OSP_ID%TYPE)
    IS
    BEGIN
        api_dic_oszn.Delete_OS_POSITION (p_osp_id);
    END;


    -------------------------------------------------------
    ---       NDI_OS_SPECIALIZATION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Список спеціалізацій працівників НСП
    PROCEDURE GET_OS_SPEC_LIST (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_OS_SPECIALIZATION t
                        WHERE t.history_status = 'A';
    END;

    -- Картка cпеціалізації працівників НСП
    PROCEDURE GET_OS_SPEC_CARD (p_oss_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_OS_SPECIALIZATION t
                        WHERE t.oss_id = p_oss_id;
    END;

    -- Зберегти cпеціалізацію працівників НСП
    PROCEDURE SET_OS_SPEC (
        p_OSS_ID     IN     NDI_OS_SPECIALIZATION.OSS_ID%TYPE,
        p_OSS_NAME   IN     NDI_OS_SPECIALIZATION.OSS_NAME%TYPE,
        p_new_id        OUT NDI_OS_SPECIALIZATION.OSS_ID%TYPE)
    IS
    BEGIN
        api_dic_oszn.SET_OS_SPEC (p_OSS_ID     => p_OSS_ID,
                                  p_OSS_NAME   => p_OSS_NAME,
                                  p_new_id     => p_new_id);
    END;

    -- Видалити cпеціалізацію працівників НСП
    PROCEDURE DELETE_OS_SPEC (p_oss_id NDI_OS_SPECIALIZATION.OSS_ID%TYPE)
    IS
    BEGIN
        api_dic_oszn.delete_os_spec (p_oss_id);
    END;
BEGIN
    NULL;
END DNET$DIC_OSZN;
/