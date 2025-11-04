/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NPO_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_npo_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nnc_id = 0) OR (:NEW.nnc_id IS NULL)
    THEN
        :NEW.nnc_id := ID_ndi_npo_config (:NEW.nnc_id);
    END IF;
END;
/
