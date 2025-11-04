/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_COMMON
IS
    -- Author  : MAXYM
    -- Created : 12.10.2017 10:09:49
    -- Purpose :

    FUNCTION Is_OBI_Enabled
        RETURN BOOLEAN;

    PROCEDURE Disable_OBI;

    PROCEDURE Enable_OBI;

    FUNCTION GetNextChangeTs
        RETURN NUMBER;
END FINZVIT_COMMON;
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_COMMON
IS
    gEnabledOBI   BOOLEAN := TRUE;

    FUNCTION Is_OBI_Enabled
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN gEnabledOBI;
    END;

    PROCEDURE Disable_OBI
    IS
    BEGIN
        gEnabledOBI := FALSE;
    END;

    PROCEDURE Enable_OBI
    IS
    BEGIN
        gEnabledOBI := TRUE;
    END;

    FUNCTION GetNextChangeTs
        RETURN NUMBER
    IS
        l_curval   NUMBER;
    BEGIN
        SELECT SQ_OBI_TS.NEXTVAL INTO l_curval FROM DUAL;

        RETURN l_curval;
    END;
END FINZVIT_COMMON;
/