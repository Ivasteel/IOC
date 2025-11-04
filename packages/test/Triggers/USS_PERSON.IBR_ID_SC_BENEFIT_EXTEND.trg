/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_BENEFIT_EXTEND
    BEFORE INSERT
    ON uss_person.sc_benefit_extend
    FOR EACH ROW
BEGIN
    IF (:NEW.scbe_id = 0) OR (:NEW.scbe_id IS NULL)
    THEN
        :NEW.scbe_id := ID_sc_benefit_extend (:NEW.scbe_id);
    END IF;
END;
/
