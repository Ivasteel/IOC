/* Formatted on 8/12/2025 6:00:10 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_VISIT.Pib (p_Ln   VARCHAR2,
                                          p_Fn   VARCHAR2,
                                          p_Mn   VARCHAR2)
    RETURN VARCHAR2
IS
BEGIN
    RETURN UPPER (TRIM (p_Ln) || ' ' || TRIM (p_Fn) || ' ' || TRIM (p_Mn));
END Pib;
/
