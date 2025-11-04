/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NPT_ED_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_npt_ed_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nedc_id = 0) OR (:NEW.nedc_id IS NULL)
    THEN
        :NEW.nedc_id := ID_ndi_npt_ed_config (:NEW.nedc_id);
    END IF;
END;
/
