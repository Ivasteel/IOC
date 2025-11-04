/* Formatted on 8/12/2025 6:00:10 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_VISIT.Aps_Exists (p_Aps_Ap    IN NUMBER,
                                                 p_Aps_Nst   IN NUMBER)
    RETURN BOOLEAN
IS
    l_Aps_Exists   NUMBER;
BEGIN
    SELECT SIGN (COUNT (*))
      INTO l_Aps_Exists
      FROM Ap_Service s
     WHERE     s.Aps_Ap = p_Aps_Ap
           AND s.Aps_Nst = p_Aps_Nst
           AND s.History_Status = 'A';

    RETURN l_Aps_Exists = 1;
END Aps_Exists;
/
