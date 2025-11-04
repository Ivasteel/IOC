/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_HOUSEHOLD
    BEFORE INSERT
    ON uss_person.sc_household
    FOR EACH ROW
BEGIN
    IF (:NEW.schh_id = 0) OR (:NEW.schh_id IS NULL)
    THEN
        :NEW.schh_id := ID_sc_household (:NEW.schh_id);
    END IF;
END;
/
