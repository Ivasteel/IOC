/* Formatted on 8/12/2025 6:06:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_BUDGET_ITEM
AS
    PROCEDURE LockForBudgetItem;

    PROCEDURE DeleteBudgetItem (p_BI_ID IN BUDGET_ITEM.BI_ID%TYPE);

    PROCEDURE InsertBudgetItem (
        P_BI_NAME              BUDGET_ITEM.BI_NAME%TYPE,
        P_BI_GROUP             BUDGET_ITEM.BI_GROUP%TYPE,
        P_BI_PERIOD_FROM       BUDGET_ITEM.BI_PERIOD_FROM%TYPE,
        P_BI_PERIOD_TO         BUDGET_ITEM.BI_PERIOD_TO%TYPE,
        P_BI_TYPE              BUDGET_ITEM.BI_TYPE%TYPE,
        P_BI_SORT              BUDGET_ITEM.BI_SORT%TYPE,
        P_BI_ID            OUT BUDGET_ITEM.BI_ID%TYPE);

    PROCEDURE UpdateBudgetItem (
        P_BI_NAME          BUDGET_ITEM.BI_NAME%TYPE,
        P_BI_GROUP         BUDGET_ITEM.BI_GROUP%TYPE,
        P_BI_PERIOD_FROM   BUDGET_ITEM.BI_PERIOD_FROM%TYPE,
        P_BI_PERIOD_TO     BUDGET_ITEM.BI_PERIOD_TO%TYPE,
        P_BI_TYPE          BUDGET_ITEM.BI_TYPE%TYPE,
        P_BI_SORT          BUDGET_ITEM.BI_SORT%TYPE,
        P_BI_ID            BUDGET_ITEM.BI_ID%TYPE);
END FINZVIT_BUDGET_ITEM;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_BUDGET_ITEM TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_BUDGET_ITEM
IS
    -- Author  : SHEPEL
    -- Created : 16.10.2018 16:05:57
    -- Purpose :

    PROCEDURE LockForBudgetItem
    IS
        l_handler   VARCHAR2 (100);
        l_org       NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_year      PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
    BEGIN
        ikis_sys.ikis_lock.Request_Lock (
            p_errmessage          =>
                'З статтями бюджету зараз працює інший користувач. Зачекайте та повторіть операцію.',
            p_lockhandler         => l_handler,
            p_release_on_commit   => TRUE,
            p_timeout             => 20,
            p_permanent_name      => 'FZPO',
            p_var_name            => l_org || '_' || l_year);
    END;

    PROCEDURE DeleteBudgetItem (p_BI_ID IN BUDGET_ITEM.BI_ID%TYPE)
    IS
        l_count   NUMBER (10);
    BEGIN
        SELECT COUNT (*)
          INTO l_count
          FROM BUDGET_ITEM
         WHERE BI_GROUP = p_BI_ID;

        IF (l_count >= 1)
        THEN
            raise_application_error (
                -20000,
                'Не можливо видалити запис, бо є залежні записи');
        END IF;

        DELETE FROM BUDGET_ITEM
              WHERE BUDGET_ITEM.BI_ID = p_BI_ID;
    END;

    PROCEDURE InsertBudgetItem (
        P_BI_NAME              BUDGET_ITEM.BI_NAME%TYPE,
        P_BI_GROUP             BUDGET_ITEM.BI_GROUP%TYPE,
        P_BI_PERIOD_FROM       BUDGET_ITEM.BI_PERIOD_FROM%TYPE,
        P_BI_PERIOD_TO         BUDGET_ITEM.BI_PERIOD_TO%TYPE,
        P_BI_TYPE              BUDGET_ITEM.BI_TYPE%TYPE,
        P_BI_SORT              BUDGET_ITEM.BI_SORT%TYPE,
        P_BI_ID            OUT BUDGET_ITEM.BI_ID%TYPE)
    IS
    BEGIN
        INSERT INTO BUDGET_ITEM (BI_NAME,
                                 BI_GROUP,
                                 BI_PERIOD_FROM,
                                 BI_PERIOD_TO,
                                 BI_TYPE,
                                 BI_SORT)
             VALUES (P_BI_NAME,
                     P_BI_GROUP,
                     P_BI_PERIOD_FROM,
                     P_BI_PERIOD_TO,
                     P_BI_TYPE,
                     P_BI_SORT)
          RETURNING BI_ID
               INTO P_BI_ID;
    END;

    PROCEDURE UpdateBudgetItem (
        P_BI_NAME          BUDGET_ITEM.BI_NAME%TYPE,
        P_BI_GROUP         BUDGET_ITEM.BI_GROUP%TYPE,
        P_BI_PERIOD_FROM   BUDGET_ITEM.BI_PERIOD_FROM%TYPE,
        P_BI_PERIOD_TO     BUDGET_ITEM.BI_PERIOD_TO%TYPE,
        P_BI_TYPE          BUDGET_ITEM.BI_TYPE%TYPE,
        P_BI_SORT          BUDGET_ITEM.BI_SORT%TYPE,
        P_BI_ID            BUDGET_ITEM.BI_ID%TYPE)
    IS
    BEGIN
        UPDATE BUDGET_ITEM
           SET BI_NAME = P_BI_NAME,
               BI_GROUP = P_BI_GROUP,
               BI_PERIOD_FROM = P_BI_PERIOD_FROM,
               BI_PERIOD_TO = P_BI_PERIOD_TO,
               BI_TYPE = P_BI_TYPE,
               BI_SORT = P_BI_SORT
         WHERE BI_ID = P_BI_ID;
    END;
END FINZVIT_BUDGET_ITEM;
/