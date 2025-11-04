/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AT_FORM_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_at_form_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nafc_id = 0) OR (:NEW.nafc_id IS NULL)
    THEN
        :NEW.nafc_id := ID_ndi_at_form_config (:NEW.nafc_id);
    END IF;
END;
/
