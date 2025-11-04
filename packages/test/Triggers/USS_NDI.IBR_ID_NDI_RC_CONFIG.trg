/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RC_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_rc_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nrcc_id = 0) OR (:NEW.nrcc_id IS NULL)
    THEN
        :NEW.nrcc_id := ID_ndi_rc_config (:NEW.nrcc_id);
    END IF;
END;
/
