/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FEEDBACK
    BEFORE INSERT
    ON uss_esr.feedback
    FOR EACH ROW
BEGIN
    IF (:NEW.fb_id = 0) OR (:NEW.fb_id IS NULL)
    THEN
        :NEW.fb_id := ID_feedback (:NEW.fb_id);
    END IF;
END;
/
