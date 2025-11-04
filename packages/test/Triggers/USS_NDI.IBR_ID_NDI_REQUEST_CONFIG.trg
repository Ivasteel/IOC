/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REQUEST_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_request_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nrc_id = 0) OR (:NEW.nrc_id IS NULL)
    THEN
        :NEW.nrc_id := ID_ndi_request_config (:NEW.nrc_id);
    END IF;
END;
/
