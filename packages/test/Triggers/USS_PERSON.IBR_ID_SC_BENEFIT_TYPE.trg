/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_BENEFIT_TYPE
    BEFORE INSERT
    ON uss_person.sc_benefit_type
    FOR EACH ROW
BEGIN
    IF (:NEW.scbt_id = 0) OR (:NEW.scbt_id IS NULL)
    THEN
        :NEW.scbt_id := ID_sc_benefit_type (:NEW.scbt_id);
    END IF;
END;
/
