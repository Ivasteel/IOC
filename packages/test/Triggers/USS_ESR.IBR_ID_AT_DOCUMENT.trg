/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_DOCUMENT
    BEFORE INSERT
    ON uss_esr.at_document
    FOR EACH ROW
BEGIN
    IF (:NEW.atd_id = 0) OR (:NEW.atd_id IS NULL)
    THEN
        :NEW.atd_id := ID_at_document (:NEW.atd_id);
    END IF;
END;
/
