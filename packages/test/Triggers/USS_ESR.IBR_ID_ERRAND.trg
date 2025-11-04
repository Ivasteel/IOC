/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ERRAND
    BEFORE INSERT
    ON uss_esr.errand
    FOR EACH ROW
BEGIN
    IF (:NEW.ed_id = 0) OR (:NEW.ed_id IS NULL)
    THEN
        :NEW.ed_id := ID_errand (:NEW.ed_id);
    END IF;
END;
/
