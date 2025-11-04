/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_VERIFICATION
    BEFORE INSERT
    ON uss_person.sc_verification
    FOR EACH ROW
BEGIN
    IF (:NEW.scv_id = 0) OR (:NEW.scv_id IS NULL)
    THEN
        :NEW.scv_id := ID_sc_verification (:NEW.scv_id);
    END IF;
END;
/
