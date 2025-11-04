/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_CALC_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nst_calc_config
    FOR EACH ROW
BEGIN
    IF (:NEW.ncc_id = 0) OR (:NEW.ncc_id IS NULL)
    THEN
        :NEW.ncc_id := ID_ndi_nst_calc_config (:NEW.ncc_id);
    END IF;
END;
/
