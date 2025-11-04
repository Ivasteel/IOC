/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_MOZ_ASSESSMENT
    BEFORE INSERT
    ON uss_person.sc_moz_assessment
    FOR EACH ROW
BEGIN
    IF (:NEW.scma_id = 0) OR (:NEW.scma_id IS NULL)
    THEN
        :NEW.scma_id := ID_sc_moz_assessment (:NEW.scma_id);
    END IF;
END;
/
