/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_CHARGEBACK_BUDGETING
IS
    PROCEDURE LockForChargeback;

    PROCEDURE InsertChargeback (
        p_CB_ID                 CHARGEBACK_BUDGETING.CB_ID%TYPE,
        p_CB_REGION_CODE        CHARGEBACK_BUDGETING.CB_REGION_CODE%TYPE,
        p_CB_BANK_MFO_REC       CHARGEBACK_BUDGETING.CB_BANK_MFO_REC%TYPE,
        p_CB_BANK_NAME_REC      CHARGEBACK_BUDGETING.CB_BANK_NAME_REC%TYPE,
        p_CB_PERSONAL_ACCOUNT   CHARGEBACK_BUDGETING.CB_PERSONAL_ACCOUNT%TYPE,
        p_CB_PENSIONER_NAME     CHARGEBACK_BUDGETING.CB_PENSIONER_NAME%TYPE,
        p_CB_PERIOD_FROM        CHARGEBACK_BUDGETING.CB_PERIOD_FROM%TYPE,
        p_CB_PERIOD_TO          CHARGEBACK_BUDGETING.CB_PERIOD_TO%TYPE,
        p_CB_NOTE               CHARGEBACK_BUDGETING.CB_NOTE%TYPE,
        p_CB_PENSION_SYSTEM     CHARGEBACK_BUDGETING.CB_PENSION_SYSTEM%TYPE,
        p_CB_STATUS             CHARGEBACK_BUDGETING.CB_STATUS%TYPE);

    PROCEDURE UpdateChargeback (
        p_CB_ID                 CHARGEBACK_BUDGETING.CB_ID%TYPE,
        p_CB_REGION_CODE        CHARGEBACK_BUDGETING.CB_REGION_CODE%TYPE,
        p_CB_BANK_MFO_REC       CHARGEBACK_BUDGETING.CB_BANK_MFO_REC%TYPE,
        p_CB_BANK_NAME_REC      CHARGEBACK_BUDGETING.CB_BANK_NAME_REC%TYPE,
        p_CB_PERSONAL_ACCOUNT   CHARGEBACK_BUDGETING.CB_PERSONAL_ACCOUNT%TYPE,
        p_CB_PENSIONER_NAME     CHARGEBACK_BUDGETING.CB_PENSIONER_NAME%TYPE,
        p_CB_PERIOD_FROM        CHARGEBACK_BUDGETING.CB_PERIOD_FROM%TYPE,
        p_CB_PERIOD_TO          CHARGEBACK_BUDGETING.CB_PERIOD_TO%TYPE,
        p_CB_NOTE               CHARGEBACK_BUDGETING.CB_NOTE%TYPE,
        p_CB_PENSION_SYSTEM     CHARGEBACK_BUDGETING.CB_PENSION_SYSTEM%TYPE,
        p_CB_STATUS             CHARGEBACK_BUDGETING.CB_STATUS%TYPE);
END;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_CHARGEBACK_BUDGETING TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_CHARGEBACK_BUDGETING
IS
    -- Author  : SHEPEL
    -- Created : 16.10.2018 16:05:57
    -- Purpose :

    PROCEDURE LockForChargeback
    IS
        l_handler   VARCHAR2 (100);
        l_org       NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_year      PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
    BEGIN
        ikis_sys.ikis_lock.Request_Lock (
            p_errmessage          =>
                'З повернутими платіжами зараз працює інший користувач. Зачекайте та повторіть операцію.',
            p_lockhandler         => l_handler,
            p_release_on_commit   => TRUE,
            p_timeout             => 20,
            p_permanent_name      => 'FZPO',
            p_var_name            => l_org || '_' || l_year);
    END;

    PROCEDURE InsertChargeback (
        p_CB_ID                 CHARGEBACK_BUDGETING.CB_ID%TYPE,
        p_CB_REGION_CODE        CHARGEBACK_BUDGETING.CB_REGION_CODE%TYPE,
        p_CB_BANK_MFO_REC       CHARGEBACK_BUDGETING.CB_BANK_MFO_REC%TYPE,
        p_CB_BANK_NAME_REC      CHARGEBACK_BUDGETING.CB_BANK_NAME_REC%TYPE,
        p_CB_PERSONAL_ACCOUNT   CHARGEBACK_BUDGETING.CB_PERSONAL_ACCOUNT%TYPE,
        p_CB_PENSIONER_NAME     CHARGEBACK_BUDGETING.CB_PENSIONER_NAME%TYPE,
        p_CB_PERIOD_FROM        CHARGEBACK_BUDGETING.CB_PERIOD_FROM%TYPE,
        p_CB_PERIOD_TO          CHARGEBACK_BUDGETING.CB_PERIOD_TO%TYPE,
        p_CB_NOTE               CHARGEBACK_BUDGETING.CB_NOTE%TYPE,
        p_CB_PENSION_SYSTEM     CHARGEBACK_BUDGETING.CB_PENSION_SYSTEM%TYPE,
        p_CB_STATUS             CHARGEBACK_BUDGETING.CB_STATUS%TYPE)
    IS
    BEGIN
        INSERT INTO CHARGEBACK_BUDGETING (CB_ID,
                                          CB_REGION_CODE,
                                          CB_BANK_MFO_REC,
                                          CB_BANK_NAME_REC,
                                          CB_PERSONAL_ACCOUNT,
                                          CB_PENSIONER_NAME,
                                          CB_PERIOD_FROM,
                                          CB_PERIOD_TO,
                                          CB_NOTE,
                                          CB_PENSION_SYSTEM,
                                          CB_STATUS)
             VALUES (p_CB_ID,
                     p_CB_REGION_CODE,
                     p_CB_BANK_MFO_REC,
                     p_CB_BANK_NAME_REC,
                     p_CB_PERSONAL_ACCOUNT,
                     p_CB_PENSIONER_NAME,
                     p_CB_PERIOD_FROM,
                     p_CB_PERIOD_TO,
                     p_CB_NOTE,
                     p_CB_PENSION_SYSTEM,
                     p_CB_STATUS);
    END;

    PROCEDURE UpdateChargeback (
        p_CB_ID                 CHARGEBACK_BUDGETING.CB_ID%TYPE,
        p_CB_REGION_CODE        CHARGEBACK_BUDGETING.CB_REGION_CODE%TYPE,
        p_CB_BANK_MFO_REC       CHARGEBACK_BUDGETING.CB_BANK_MFO_REC%TYPE,
        p_CB_BANK_NAME_REC      CHARGEBACK_BUDGETING.CB_BANK_NAME_REC%TYPE,
        p_CB_PERSONAL_ACCOUNT   CHARGEBACK_BUDGETING.CB_PERSONAL_ACCOUNT%TYPE,
        p_CB_PENSIONER_NAME     CHARGEBACK_BUDGETING.CB_PENSIONER_NAME%TYPE,
        p_CB_PERIOD_FROM        CHARGEBACK_BUDGETING.CB_PERIOD_FROM%TYPE,
        p_CB_PERIOD_TO          CHARGEBACK_BUDGETING.CB_PERIOD_TO%TYPE,
        p_CB_NOTE               CHARGEBACK_BUDGETING.CB_NOTE%TYPE,
        p_CB_PENSION_SYSTEM     CHARGEBACK_BUDGETING.CB_PENSION_SYSTEM%TYPE,
        p_CB_STATUS             CHARGEBACK_BUDGETING.CB_STATUS%TYPE)
    IS
    BEGIN
        UPDATE CHARGEBACK_BUDGETING
           SET CB_REGION_CODE = p_CB_REGION_CODE,
               CB_BANK_MFO_REC = p_CB_BANK_MFO_REC,
               CB_BANK_NAME_REC = p_CB_BANK_NAME_REC,
               CB_PERSONAL_ACCOUNT = p_CB_PERSONAL_ACCOUNT,
               CB_PENSIONER_NAME = p_CB_PENSIONER_NAME,
               CB_PERIOD_FROM = p_CB_PERIOD_FROM,
               CB_PERIOD_TO = p_CB_PERIOD_TO,
               CB_NOTE = p_CB_NOTE,
               CB_PENSION_SYSTEM = p_CB_PENSION_SYSTEM,
               CB_STATUS = p_CB_STATUS
         WHERE CB_ID = p_CB_ID;
    END;
END FINZVIT_CHARGEBACK_BUDGETING;
/