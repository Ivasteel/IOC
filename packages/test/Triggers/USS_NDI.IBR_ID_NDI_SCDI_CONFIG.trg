/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_SCDI_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_scdi_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nsc_id = 0) OR (:NEW.nsc_id IS NULL)
    THEN
        :NEW.nsc_id := ID_ndi_scdi_config (:NEW.nsc_id);
    END IF;
END;
/
