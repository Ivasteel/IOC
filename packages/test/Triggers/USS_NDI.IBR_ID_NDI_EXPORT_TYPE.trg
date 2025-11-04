/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_EXPORT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_export_type
    FOR EACH ROW
BEGIN
    IF (:NEW.net_id = 0) OR (:NEW.net_id IS NULL)
    THEN
        :NEW.net_id := ID_ndi_export_type (:NEW.net_id);
    END IF;
END;
/
