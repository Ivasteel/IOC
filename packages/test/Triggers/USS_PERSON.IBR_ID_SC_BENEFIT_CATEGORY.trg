/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_BENEFIT_CATEGORY
    BEFORE INSERT
    ON uss_person.sc_benefit_category
    FOR EACH ROW
BEGIN
    IF (:NEW.scbc_id = 0) OR (:NEW.scbc_id IS NULL)
    THEN
        :NEW.scbc_id := ID_sc_benefit_category (:NEW.scbc_id);
    END IF;
END;
/
