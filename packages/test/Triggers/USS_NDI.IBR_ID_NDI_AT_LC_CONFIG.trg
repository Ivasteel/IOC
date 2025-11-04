/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AT_LC_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_at_lc_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nalc_id = 0) OR (:NEW.nalc_id IS NULL)
    THEN
        :NEW.nalc_id := ID_ndi_at_lc_config (:NEW.nalc_id);
    END IF;
END;
/
