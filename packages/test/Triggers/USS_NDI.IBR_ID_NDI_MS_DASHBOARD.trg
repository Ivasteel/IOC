/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MS_DASHBOARD
    BEFORE INSERT
    ON uss_ndi.ndi_ms_dashboard
    FOR EACH ROW
BEGIN
    IF (:NEW.dsb_id = 0) OR (:NEW.dsb_id IS NULL)
    THEN
        :NEW.dsb_id := ID_ndi_ms_dashboard (:NEW.dsb_id);
    END IF;
END;
/
