/* Formatted on 8/12/2025 6:10:53 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_RBM.ExceptionRbm (
    p_par1   VARCHAR2,
    p_par2   VARCHAR2,
    p_par3   VARCHAR2 DEFAULT NULL,
    p_par4   VARCHAR2 DEFAULT NULL,
    p_par5   VARCHAR2 DEFAULT NULL,
    p_par6   VARCHAR2 DEFAULT NULL,
    p_par7   VARCHAR2 DEFAULT NULL)
IS
BEGIN
    ikis_rbm_internal.ExceptionRbm (p_par1,
                                    p_par2,
                                    p_par3,
                                    p_par4,
                                    p_par5,
                                    p_par6,
                                    p_par7);
END ExceptionRbm;
/
