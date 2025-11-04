/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FB_SERVICE
    BEFORE INSERT
    ON uss_esr.fb_service
    FOR EACH ROW
BEGIN
    IF (:NEW.fbs_id = 0) OR (:NEW.fbs_id IS NULL)
    THEN
        :NEW.fbs_id := ID_fb_service (:NEW.fbs_id);
    END IF;
END;
/
