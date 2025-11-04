/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FB_DOCUMENT
    BEFORE INSERT
    ON uss_esr.fb_document
    FOR EACH ROW
BEGIN
    IF (:NEW.fbd_id = 0) OR (:NEW.fbd_id IS NULL)
    THEN
        :NEW.fbd_id := ID_fb_document (:NEW.fbd_id);
    END IF;
END;
/
