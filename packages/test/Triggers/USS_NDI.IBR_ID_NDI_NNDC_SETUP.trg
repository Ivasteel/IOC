/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NNDC_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_nndc_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.nns_id = 0) OR (:NEW.nns_id IS NULL)
    THEN
        :NEW.nns_id := ID_ndi_nndc_setup (:NEW.nns_id);
    END IF;
END;
/
