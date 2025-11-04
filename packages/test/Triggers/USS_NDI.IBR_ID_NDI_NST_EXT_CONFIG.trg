/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_EXT_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nst_ext_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nnec_id = 0) OR (:NEW.nnec_id IS NULL)
    THEN
        :NEW.nnec_id := ID_ndi_nst_ext_config (:NEW.nnec_id);
    END IF;
END;
/
