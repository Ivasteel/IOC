/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_BENEFIT_DOCS
    BEFORE INSERT
    ON uss_person.sc_benefit_docs
    FOR EACH ROW
BEGIN
    IF (:NEW.scbd_id = 0) OR (:NEW.scbd_id IS NULL)
    THEN
        :NEW.scbd_id := ID_sc_benefit_docs (:NEW.scbd_id);
    END IF;
END;
/
