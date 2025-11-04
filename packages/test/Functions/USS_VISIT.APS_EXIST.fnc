/* Formatted on 8/12/2025 6:00:10 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_VISIT.Aps_Exist (p_Aps_Ap         IN NUMBER,
                                                p_Aps_Nst_List   IN VARCHAR2)
    RETURN BOOLEAN
IS
    l_Aps_Exists   NUMBER;
BEGIN
    SELECT SIGN (COUNT (*))
      INTO l_Aps_Exists
      FROM Ap_Service s
     WHERE     s.Aps_Ap = p_Aps_Ap
           AND s.Aps_Nst IN
                   (SELECT TO_NUMBER (COLUMN_VALUE)
                      FROM XMLTABLE (p_Aps_Nst_List))
           AND s.History_Status = 'A';

    RETURN l_Aps_Exists = 1;
END Aps_Exist;
/
