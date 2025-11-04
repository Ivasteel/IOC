/* Formatted on 8/12/2025 6:06:29 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_FINZVIT.DID_BUDGET_PFU_STATUS (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            l_curval := p_id;
        ELSE
            SELECT SQ_DID_BUDGET_PFU_STATUS.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_DID_BUDGET_PFU_STATUS.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
