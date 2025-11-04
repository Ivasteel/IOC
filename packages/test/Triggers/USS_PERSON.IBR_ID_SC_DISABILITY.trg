/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_DISABILITY
    BEFORE INSERT
    ON uss_person.sc_disability
    FOR EACH ROW
BEGIN
    IF (:NEW.scy_id = 0) OR (:NEW.scy_id IS NULL)
    THEN
        :NEW.scy_id := ID_sc_disability (:NEW.scy_id);
    END IF;
END;
/
