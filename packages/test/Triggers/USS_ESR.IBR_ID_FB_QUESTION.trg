/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FB_QUESTION
    BEFORE INSERT
    ON uss_esr.fb_question
    FOR EACH ROW
BEGIN
    IF (:NEW.fbq_id = 0) OR (:NEW.fbq_id IS NULL)
    THEN
        :NEW.fbq_id := ID_fb_question (:NEW.fbq_id);
    END IF;
END;
/
