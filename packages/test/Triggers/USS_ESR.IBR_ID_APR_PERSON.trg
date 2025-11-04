/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_APR_PERSON
    BEFORE INSERT
    ON uss_esr.apr_person
    FOR EACH ROW
BEGIN
    IF (:NEW.aprp_id = 0) OR (:NEW.aprp_id IS NULL)
    THEN
        :NEW.aprp_id := ID_apr_person (:NEW.aprp_id);
    END IF;
END;
/
