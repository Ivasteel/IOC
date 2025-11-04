/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CALENDAR_BASE
    BEFORE INSERT
    ON uss_ndi.ndi_calendar_base
    FOR EACH ROW
BEGIN
    IF (:NEW.ncb_id = 0) OR (:NEW.ncb_id IS NULL)
    THEN
        :NEW.ncb_id := ID_ndi_calendar_base (:NEW.ncb_id);
    END IF;
END;
/
