/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.GetMessageNum (p_ipm_id        NUMBER,
                                                   p_ipm_errcode   NUMBER)
    RETURN VARCHAR2
IS
BEGIN
    RETURN 'IKIS-' || NVL (LPAD (P_IPM_ERRCODE, 6, '0'), P_IPM_ID || '-ID');
END;
/
