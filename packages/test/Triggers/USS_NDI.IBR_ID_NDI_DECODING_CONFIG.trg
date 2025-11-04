/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DECODING_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_decoding_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nddc_id = 0) OR (:NEW.nddc_id IS NULL)
    THEN
        :NEW.nddc_id := ID_ndi_decoding_config (:NEW.nddc_id);
    END IF;
END;
/
