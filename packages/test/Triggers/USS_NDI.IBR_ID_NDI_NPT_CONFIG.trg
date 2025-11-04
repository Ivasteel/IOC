/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NPT_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_npt_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nptc_id = 0) OR (:NEW.nptc_id IS NULL)
    THEN
        :NEW.nptc_id := ID_ndi_npt_config (:NEW.nptc_id);
    END IF;
END;
/
