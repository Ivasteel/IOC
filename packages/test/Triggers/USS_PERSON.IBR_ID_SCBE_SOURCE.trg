/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCBE_SOURCE
    BEFORE INSERT
    ON uss_person.scbe_source
    FOR EACH ROW
BEGIN
    IF (:NEW.scbs_id = 0) OR (:NEW.scbs_id IS NULL)
    THEN
        :NEW.scbs_id := ID_scbe_source (:NEW.scbs_id);
    END IF;
END;
/
