/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AP_NST_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_ap_nst_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nanc_id = 0) OR (:NEW.nanc_id IS NULL)
    THEN
        :NEW.nanc_id := ID_ndi_ap_nst_config (:NEW.nanc_id);
    END IF;
END;
/
