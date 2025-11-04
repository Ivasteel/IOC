/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_ADDRESS
    BEFORE INSERT
    ON uss_person.sc_address
    FOR EACH ROW
BEGIN
    IF (:NEW.sca_id = 0) OR (:NEW.sca_id IS NULL)
    THEN
        :NEW.sca_id := ID_sc_address (:NEW.sca_id);
    END IF;
END;
/
