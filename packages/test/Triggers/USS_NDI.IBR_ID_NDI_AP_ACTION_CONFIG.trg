/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AP_ACTION_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_ap_action_config
    FOR EACH ROW
BEGIN
    IF (:NEW.naac_id = 0) OR (:NEW.naac_id IS NULL)
    THEN
        :NEW.naac_id := ID_ndi_ap_action_config (:NEW.naac_id);
    END IF;
END;
/
