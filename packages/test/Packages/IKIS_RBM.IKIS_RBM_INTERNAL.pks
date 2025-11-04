/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_INTERNAL
IS
    -- Author  : SBOND
    -- Created : 01.07.2015 18:49:09
    -- Purpose :

    FUNCTION Is_OBI_Enabled
        RETURN BOOLEAN;

    PROCEDURE Disable_OBI;

    PROCEDURE Enable_OBI;

    PROCEDURE ExceptionRbm (p_par1   VARCHAR2 DEFAULT NULL,
                            p_par2   VARCHAR2 DEFAULT NULL,
                            p_par3   VARCHAR2 DEFAULT NULL,
                            p_par4   VARCHAR2 DEFAULT NULL,
                            p_par5   VARCHAR2 DEFAULT NULL,
                            p_par6   VARCHAR2 DEFAULT NULL,
                            p_par7   VARCHAR2 DEFAULT NULL);
END ikis_rbm_internal;
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_INTERNAL
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    gEnabledOBI           BOOLEAN := TRUE;

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

    PROCEDURE ExceptionRbm (p_par1   VARCHAR2 DEFAULT NULL,
                            p_par2   VARCHAR2 DEFAULT NULL,
                            p_par3   VARCHAR2 DEFAULT NULL,
                            p_par4   VARCHAR2 DEFAULT NULL,
                            p_par5   VARCHAR2 DEFAULT NULL,
                            p_par6   VARCHAR2 DEFAULT NULL,
                            p_par7   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        raise_application_error (-20000,
                                 ikis_sys.ikis_message_util.GET_MESSAGE (
                                     msgCOMMON_EXCEPTION,
                                     p_par1,
                                     p_par2,
                                     p_par3,
                                     p_par4,
                                     p_par5,
                                     p_par6,
                                     p_par7,
                                     'IKIS_RBM'));
    END;
END ikis_rbm_internal;
/