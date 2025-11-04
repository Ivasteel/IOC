/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$FIND
IS
    -- Author  : USER
    -- Created : 31.07.2024 20:36:19
    -- Purpose :

    FUNCTION get_app_column (p_app_id IN NUMBER, p_column IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_histsession_dt (p_hs_Id IN NUMBER)
        RETURN DATE;
END API$FIND;
/


GRANT EXECUTE ON USS_VISIT.API$FIND TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.API$FIND TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.API$FIND TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.API$FIND TO USS_RNSP
/


/* Formatted on 8/12/2025 5:59:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$FIND
IS
    FUNCTION get_app_column (p_app_id IN NUMBER, p_column IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (500);
    BEGIN
        EXECUTE IMMEDIATE   'select '
                         || p_column
                         || ' from ap_person where app_id=:app'
            INTO l_res
            USING p_app_id;

        RETURN l_res;
    END;

    FUNCTION get_histsession_dt (p_hs_Id IN NUMBER)
        RETURN DATE
    IS
        l_dt   DATE;
    BEGIN
        SELECT t.hs_dt
          INTO l_dt
          FROM histsession t
         WHERE t.hs_id = p_hs_id;

        RETURN l_dt;
    END;
END API$FIND;
/