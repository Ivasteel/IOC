/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_CARS
    BEFORE INSERT
    ON uss_person.sc_cars
    FOR EACH ROW
BEGIN
    IF (:NEW.scap_id = 0) OR (:NEW.scap_id IS NULL)
    THEN
        :NEW.scap_id := ID_sc_cars (:NEW.scap_id);
    END IF;
END;
/
