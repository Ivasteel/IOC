/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCV_ANSWER
    BEFORE INSERT
    ON uss_person.scv_answer
    FOR EACH ROW
BEGIN
    IF (:NEW.scva_id = 0) OR (:NEW.scva_id IS NULL)
    THEN
        :NEW.scva_id := ID_scv_answer (:NEW.scva_id);
    END IF;
END;
/
