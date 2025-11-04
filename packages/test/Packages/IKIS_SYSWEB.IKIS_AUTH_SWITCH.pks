/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.ikis_auth_switch
IS
    -- Author  : YURA_A
    -- Created : 01.03.2007 16:25:01
    -- Purpose :

    -- Public function and procedure declarations
    FUNCTION IsMaster
        RETURN BOOLEAN;

    FUNCTION IsMaster01
        RETURN NUMBER;
END ikis_auth_switch;
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.ikis_auth_switch
IS
    FUNCTION IsMaster
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN FALSE;                       --временно true; -- мастер система
    END;

    FUNCTION IsMaster01
        RETURN NUMBER
    IS
    BEGIN
        IF IsMaster
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;
END ikis_auth_switch;
/