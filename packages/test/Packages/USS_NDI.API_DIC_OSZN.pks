/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API_DIC_OSZN
IS
    -- Author  : BOGDAN
    -- Created : 18.09.2023 16:36:24
    -- Purpose : Інтерфейси по веденню кадрового забезпечення ОСЗН

    --===============================================
    --                NDI_FUNCTIONARY
    --===============================================

    PROCEDURE Save_Functionary (
        p_FNC_ID           IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
        p_COM_ORG          IN     NDI_FUNCTIONARY.COM_ORG%TYPE,
        p_FNC_FN           IN     NDI_FUNCTIONARY.FNC_FN%TYPE,
        p_FNC_LN           IN     NDI_FUNCTIONARY.FNC_LN%TYPE,
        p_FNC_MN           IN     NDI_FUNCTIONARY.FNC_MN%TYPE,
        p_FNC_POST         IN     NDI_FUNCTIONARY.FNC_POST%TYPE,
        p_FNC_PHONE        IN     NDI_FUNCTIONARY.FNC_PHONE%TYPE,
        p_FNC_TP           IN     NDI_FUNCTIONARY.FNC_TP%TYPE,
        p_HISTORY_STATUS   IN     NDI_FUNCTIONARY.HISTORY_STATUS%TYPE,
        p_FNC_NOC          IN     NDI_FUNCTIONARY.FNC_NOC%TYPE,
        p_FNC_NSP          IN     NDI_FUNCTIONARY.FNC_NSP%TYPE,
        p_FNC_BIRTH_DT     IN     NDI_FUNCTIONARY.FNC_BIRTH_DT%TYPE,
        p_FNC_RNOKPP       IN     NDI_FUNCTIONARY.FNC_RNOKPP%TYPE,
        p_FNC_GENDER       IN     NDI_FUNCTIONARY.FNC_GENDER%TYPE,
        p_FNC_ST           IN     NDI_FUNCTIONARY.FNC_ST%TYPE,
        p_FNC_START_DT     IN     NDI_FUNCTIONARY.FNC_START_DT%TYPE,
        p_FNC_STOP_DT      IN     NDI_FUNCTIONARY.FNC_STOP_DT%TYPE,
        p_new_id              OUT NDI_FUNCTIONARY.FNC_ID%TYPE);

    PROCEDURE Delete_Functionary (
        p_FNC_ID           NDI_FUNCTIONARY.FNC_ID%TYPE,
        p_History_Status   NDI_FUNCTIONARY.HISTORY_STATUS%TYPE);


    --===============================================
    --                NDI_POSITION
    --===============================================

    PROCEDURE save_position (p_NSP_ID     IN     NDI_POSITION.NSP_ID%TYPE,
                             p_NSP_NAME   IN     NDI_POSITION.NSP_NAME%TYPE,
                             p_NSP_CODE   IN     NDI_POSITION.NSP_CODE%TYPE,
                             p_NSP_ST     IN     NDI_POSITION.NSP_ST%TYPE,
                             p_COM_ORG    IN     NDI_POSITION.COM_ORG%TYPE,
                             p_new_id        OUT NDI_POSITION.NSP_ID%TYPE);

    PROCEDURE Delete_position (p_nsp_id NDI_POSITION.NSP_ID%TYPE);


    --===============================================
    --                NDI_POSITION
    --===============================================

    PROCEDURE save_org_chart (
        p_NOC_ID           IN     NDI_ORG_CHART.NOC_ID%TYPE,
        p_NOC_NOC_MASTER   IN     NDI_ORG_CHART.NOC_NOC_MASTER%TYPE,
        p_NOC_SHORT_NAME   IN     NDI_ORG_CHART.NOC_SHORT_NAME%TYPE,
        p_NOC_UNIT_NAME    IN     NDI_ORG_CHART.NOC_UNIT_NAME%TYPE,
        p_NOC_ST           IN     NDI_ORG_CHART.NOC_ST%TYPE,
        p_NOC_ADDRESS      IN     NDI_ORG_CHART.NOC_ADDRESS%TYPE,
        p_NOC_PHONE        IN     NDI_ORG_CHART.NOC_PHONE%TYPE,
        p_COM_ORG          IN     NDI_ORG_CHART.COM_ORG%TYPE,
        p_new_id              OUT NDI_ORG_CHART.NOC_ID%TYPE);

    PROCEDURE Delete_org_chart (p_noc_id NDI_ORG_CHART.NOC_ID%TYPE);

    -------------------------------------------------------
    ---          NDI_OS_POSITION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Зберегти посаду працівників НСП
    PROCEDURE SET_OS_POSITION (
        p_OSP_ID           IN     NDI_OS_POSITION.OSP_ID%TYPE,
        p_OSP_NAME         IN     NDI_OS_POSITION.OSP_NAME%TYPE,
        p_OSP_CODE         IN     NDI_OS_POSITION.OSP_CODE%TYPE,
        p_OSP_TP           IN     NDI_OS_POSITION.OSP_TP%TYPE,
        p_OSP_SPECIALIST   IN     NDI_OS_POSITION.OSP_SPECIALIST%TYPE,
        p_new_id              OUT NDI_OS_POSITION.OSP_ID%TYPE);

    -- Видалити посаду працівників НСП
    PROCEDURE DELETE_OS_POSITION (p_osp_id NDI_OS_POSITION.OSP_ID%TYPE);

    -------------------------------------------------------
    ---       NDI_OS_SPECIALIZATION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Зберегти cпеціалізацію працівників НСП
    PROCEDURE SET_OS_SPEC (
        p_OSS_ID     IN     NDI_OS_SPECIALIZATION.OSS_ID%TYPE,
        p_OSS_NAME   IN     NDI_OS_SPECIALIZATION.OSS_NAME%TYPE,
        p_new_id        OUT NDI_OS_SPECIALIZATION.OSS_ID%TYPE);

    -- Видалити cпеціалізацію працівників НСП
    PROCEDURE Delete_OS_SPEC (p_oss_id NDI_OS_SPECIALIZATION.OSS_ID%TYPE);
END API_DIC_OSZN;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API_DIC_OSZN
IS
    --===============================================
    --                NDI_FUNCTIONARY
    --===============================================

    PROCEDURE Save_Functionary (
        p_FNC_ID           IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
        p_COM_ORG          IN     NDI_FUNCTIONARY.COM_ORG%TYPE,
        p_FNC_FN           IN     NDI_FUNCTIONARY.FNC_FN%TYPE,
        p_FNC_LN           IN     NDI_FUNCTIONARY.FNC_LN%TYPE,
        p_FNC_MN           IN     NDI_FUNCTIONARY.FNC_MN%TYPE,
        p_FNC_POST         IN     NDI_FUNCTIONARY.FNC_POST%TYPE,
        p_FNC_PHONE        IN     NDI_FUNCTIONARY.FNC_PHONE%TYPE,
        p_FNC_TP           IN     NDI_FUNCTIONARY.FNC_TP%TYPE,
        p_HISTORY_STATUS   IN     NDI_FUNCTIONARY.HISTORY_STATUS%TYPE,
        p_FNC_NOC          IN     NDI_FUNCTIONARY.FNC_NOC%TYPE,
        p_FNC_NSP          IN     NDI_FUNCTIONARY.FNC_NSP%TYPE,
        p_FNC_BIRTH_DT     IN     NDI_FUNCTIONARY.FNC_BIRTH_DT%TYPE,
        p_FNC_RNOKPP       IN     NDI_FUNCTIONARY.FNC_RNOKPP%TYPE,
        p_FNC_GENDER       IN     NDI_FUNCTIONARY.FNC_GENDER%TYPE,
        p_FNC_ST           IN     NDI_FUNCTIONARY.FNC_ST%TYPE,
        p_FNC_START_DT     IN     NDI_FUNCTIONARY.FNC_START_DT%TYPE,
        p_FNC_STOP_DT      IN     NDI_FUNCTIONARY.FNC_STOP_DT%TYPE,
        p_new_id              OUT NDI_FUNCTIONARY.FNC_ID%TYPE)
    IS
    BEGIN
        IF p_FNC_ID IS NULL
        THEN
            INSERT INTO NDI_FUNCTIONARY (COM_ORG,
                                         FNC_FN,
                                         FNC_LN,
                                         FNC_MN,
                                         FNC_POST,
                                         FNC_PHONE,
                                         FNC_TP,
                                         HISTORY_STATUS,
                                         FNC_NOC,
                                         FNC_NSP,
                                         FNC_BIRTH_DT,
                                         FNC_RNOKPP,
                                         FNC_GENDER,
                                         FNC_ST,
                                         FNC_START_DT,
                                         FNC_STOP_DT)
                 VALUES (p_COM_ORG,
                         p_FNC_FN,
                         p_FNC_LN,
                         p_FNC_MN,
                         p_FNC_POST,
                         p_FNC_PHONE,
                         p_FNC_TP,
                         p_HISTORY_STATUS,
                         p_FNC_NOC,
                         p_FNC_NSP,
                         p_FNC_BIRTH_DT,
                         p_FNC_RNOKPP,
                         p_FNC_GENDER,
                         p_FNC_ST,
                         p_FNC_START_DT,
                         p_FNC_STOP_DT)
              RETURNING FNC_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_FNC_ID;

            UPDATE NDI_FUNCTIONARY
               SET COM_ORG = p_COM_ORG,
                   FNC_FN = p_FNC_FN,
                   FNC_LN = p_FNC_LN,
                   FNC_MN = p_FNC_MN,
                   FNC_POST = p_FNC_POST,
                   FNC_PHONE = p_FNC_PHONE,
                   FNC_TP = p_FNC_TP,
                   HISTORY_STATUS = p_HISTORY_STATUS,
                   FNC_NOC = p_FNC_NOC,
                   FNC_NSP = p_FNC_NSP,
                   FNC_BIRTH_DT = p_FNC_BIRTH_DT,
                   FNC_RNOKPP = p_FNC_RNOKPP,
                   FNC_GENDER = p_FNC_GENDER,
                   FNC_ST = p_FNC_ST,
                   FNC_START_DT = p_FNC_START_DT,
                   FNC_STOP_DT = p_FNC_STOP_DT
             WHERE FNC_ID = p_FNC_ID;
        END IF;
    END;

    PROCEDURE Delete_Functionary (
        p_FNC_ID           NDI_FUNCTIONARY.FNC_ID%TYPE,
        p_History_Status   NDI_FUNCTIONARY.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_FUNCTIONARY
           SET HISTORY_STATUS = p_History_Status
         WHERE FNC_ID = p_FNC_ID;
    END;


    --===============================================
    --                NDI_POSITION
    --===============================================

    PROCEDURE save_position (p_NSP_ID     IN     NDI_POSITION.NSP_ID%TYPE,
                             p_NSP_NAME   IN     NDI_POSITION.NSP_NAME%TYPE,
                             p_NSP_CODE   IN     NDI_POSITION.NSP_CODE%TYPE,
                             p_NSP_ST     IN     NDI_POSITION.NSP_ST%TYPE,
                             p_COM_ORG    IN     NDI_POSITION.COM_ORG%TYPE,
                             p_new_id        OUT NDI_POSITION.NSP_ID%TYPE)
    IS
    BEGIN
        IF p_NSP_ID IS NULL
        THEN
            INSERT INTO NDI_POSITION (NSP_NAME,
                                      NSP_CODE,
                                      NSP_ST,
                                      COM_ORG)
                 VALUES (p_NSP_NAME,
                         p_NSP_CODE,
                         p_NSP_ST,
                         p_COM_ORG)
              RETURNING NSP_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NSP_ID;

            UPDATE NDI_POSITION
               SET NSP_NAME = p_NSP_NAME,
                   NSP_CODE = p_NSP_CODE,
                   NSP_ST = p_NSP_ST
             WHERE NSP_ID = p_NSP_ID;
        END IF;
    END;

    PROCEDURE Delete_position (p_nsp_id NDI_POSITION.NSP_ID%TYPE)
    IS
    BEGIN
        DELETE FROM v_NDI_POSITION t
              WHERE NSP_ID = p_nsp_id;
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
        p_COM_ORG          IN     NDI_ORG_CHART.COM_ORG%TYPE,
        p_new_id              OUT NDI_ORG_CHART.NOC_ID%TYPE)
    IS
    BEGIN
        IF p_NOC_ID IS NULL
        THEN
            INSERT INTO NDI_ORG_CHART (NOC_NOC_MASTER,
                                       NOC_SHORT_NAME,
                                       NOC_UNIT_NAME,
                                       NOC_ST,
                                       NOC_ADDRESS,
                                       NOC_PHONE,
                                       COM_ORG)
                 VALUES (p_NOC_NOC_MASTER,
                         p_NOC_SHORT_NAME,
                         p_NOC_UNIT_NAME,
                         p_NOC_ST,
                         p_NOC_ADDRESS,
                         p_NOC_PHONE,
                         p_COM_ORG)
              RETURNING NOC_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NOC_ID;

            UPDATE NDI_ORG_CHART
               SET NOC_NOC_MASTER = p_NOC_NOC_MASTER,
                   NOC_SHORT_NAME = p_NOC_SHORT_NAME,
                   NOC_UNIT_NAME = p_NOC_UNIT_NAME,
                   NOC_ST = p_NOC_ST,
                   NOC_ADDRESS = p_NOC_ADDRESS,
                   NOC_PHONE = p_NOC_PHONE
             WHERE NOC_ID = p_NOC_ID;
        END IF;
    END;

    PROCEDURE Delete_org_chart (p_noc_id NDI_ORG_CHART.NOC_ID%TYPE)
    IS
    BEGIN
        DELETE FROM v_NDI_ORG_CHART t
              WHERE NOC_ID = p_noc_id;
    END;


    -------------------------------------------------------
    ---          NDI_OS_POSITION (для ПОРТАЛА)
    -------------------------------------------------------

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
        IF p_OSP_ID IS NULL
        THEN
            INSERT INTO NDI_OS_POSITION (OSP_NAME,
                                         OSP_CODE,
                                         HISTORY_STATUS,
                                         OSP_TP,
                                         OSP_SPECIALIST)
                 VALUES (p_OSP_NAME,
                         p_OSP_CODE,
                         'A',
                         p_OSP_TP,
                         p_OSP_SPECIALIST)
              RETURNING OSP_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_OSP_ID;

            UPDATE NDI_OS_POSITION
               SET OSP_NAME = p_OSP_NAME,
                   OSP_CODE = p_OSP_CODE,
                   OSP_TP = p_OSP_TP,
                   OSP_SPECIALIST = p_OSP_SPECIALIST
             WHERE OSP_ID = p_OSP_ID;
        END IF;
    END;

    -- Видалити посаду працівників НСП
    PROCEDURE DELETE_OS_POSITION (p_osp_id NDI_OS_POSITION.OSP_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_OS_POSITION t
           SET t.history_status = 'H'
         WHERE OSP_ID = p_osp_id;
    END;

    -------------------------------------------------------
    ---       NDI_OS_SPECIALIZATION (для ПОРТАЛА)
    -------------------------------------------------------

    -- Зберегти cпеціалізацію працівників НСП
    PROCEDURE SET_OS_SPEC (
        p_OSS_ID     IN     NDI_OS_SPECIALIZATION.OSS_ID%TYPE,
        p_OSS_NAME   IN     NDI_OS_SPECIALIZATION.OSS_NAME%TYPE,
        p_new_id        OUT NDI_OS_SPECIALIZATION.OSS_ID%TYPE)
    IS
    BEGIN
        IF p_OSS_ID IS NULL
        THEN
            INSERT INTO NDI_OS_SPECIALIZATION (OSS_NAME, HISTORY_STATUS)
                 VALUES (p_OSS_NAME, 'A')
              RETURNING OSS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_OSS_ID;

            UPDATE NDI_OS_SPECIALIZATION
               SET OSS_NAME = p_OSS_NAME
             WHERE OSS_ID = p_OSS_ID;
        END IF;
    END;

    -- Видалити cпеціалізацію працівників НСП
    PROCEDURE Delete_OS_SPEC (p_oss_id NDI_OS_SPECIALIZATION.OSS_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_OS_SPECIALIZATION t
           SET t.history_status = 'H'
         WHERE OSS_ID = p_OSS_ID;
    END;
BEGIN
    NULL;
END API_DIC_OSZN;
/