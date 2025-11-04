/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AP_SUB_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_ap_sub_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nasc_id = 0) OR (:NEW.nasc_id IS NULL)
    THEN
        :NEW.nasc_id := ID_ndi_ap_sub_config (:NEW.nasc_id);
    END IF;
END;
/
