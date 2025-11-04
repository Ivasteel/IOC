/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.DEVS_ACCESS
IS
    gtr_DEVS_USER       DECIMAL := NULL;
    gtr_DEVS_USER_ADM   VARCHAR2 (1) := NULL;

    FUNCTION ds_CanAccess (p_resource VARCHAR2, p_operation VARCHAR2)
        RETURN NUMBER;

    PROCEDURE OnLogSetCurrUser (pUSER NUMBER);

    FUNCTION OnLogGetCurrUserID
        RETURN NUMBER;

    PROCEDURE CheckLoginFromComp;
END DEVS_ACCESS;
/


CREATE OR REPLACE PUBLIC SYNONYM DEVS_ACCESS FOR IKIS_SYS.DEVS_ACCESS
/


GRANT EXECUTE ON IKIS_SYS.DEVS_ACCESS TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.DEVS_ACCESS TO II01RC_IKIS_SUPERUSER
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.DEVS_ACCESS
AS
    msgHostConnectErr       NUMBER := 3534;
    msgNO_IKIS_USER_FOUND   NUMBER := 764;


    FUNCTION ds_CanAccess (p_resource VARCHAR2, p_operation VARCHAR2)
        RETURN NUMBER
    IS
        p_result   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        IF gtr_DEVS_USER_ADM = 'Y'
        THEN
            p_result := 1;
        ELSE
            --+ Автор: KYB 05.09.2003 14:43:07
            --  Описание: Перенос контроля прав доступа с DEVS на ORACLE

            SELECT DECODE (COUNT (*), 0, 0, 1)
              INTO p_result
              FROM v_all_accessed_rsrc_attr
             WHERE rat_rsrc = p_resource AND rat_stp = p_operation;
        --- Автор: KYB 05.09.2003 14:43:59

        END IF;

        debug.f ('Result %s', p_result);
        RETURN p_result;
    END ds_CanAccess;

    PROCEDURE OnLogSetCurrUser (pUSER NUMBER)
    AS
    BEGIN
        debug.f ('Start procedure');

        gtr_DEVS_USER := pUSER;

        debug.f ('gtr_DEVS_USER %s', gtr_DEVS_USER);

        --+ Автор: KYB 05.09.2003 14:43:07
        --  Описание: Перенос контроля прав доступа с DEVS на ORACLE

        SELECT iu_is_admin INTO gtr_DEVS_USER_ADM FROM v_ikis_users_curr;

        IF gtr_DEVS_USER_ADM = 'Y'
        THEN
            NULL;
        ELSE
            gtr_DEVS_USER_ADM := 'N';
        END IF;
    --- Автор: KYB 05.09.2003 14:43:07

    END OnLogSetCurrUser;

    FUNCTION OnLogGetCurrUserID
        RETURN NUMBER
    IS
    BEGIN
        RETURN gtr_DEVS_USER;
    END OnLogGetCurrUserID;

    PROCEDURE CheckLoginFromComp
    IS
        l_comps      VARCHAR2 (2000);
        l_log_host   VARCHAR2 (100);
    BEGIN
        BEGIN
            SELECT REPLACE (UPPER (TRIM (iu_comps)), ' ', ',')
              INTO l_comps
              FROM v_ikis_users_curr;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_comps := '';
        END;

        IF TRIM (l_comps) IS NOT NULL
        THEN
            l_log_host :=
                   ','
                || UPPER (ikis_changes_utl.GetSessionParam ('HOST'))
                || ',';
            l_comps := ',' || l_comps || ',';

            IF INSTR (l_comps, l_log_host) = 0
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgHostConnectErr));
            END IF;
        END IF;
    END;
END DEVS_ACCESS;
/