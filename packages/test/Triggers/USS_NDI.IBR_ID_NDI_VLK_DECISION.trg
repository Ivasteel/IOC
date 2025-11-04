/* Formatted on 8/12/2025 5:55:58 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_VLK_DECISION
    BEFORE INSERT
    ON uss_ndi.ndi_vlk_decision
    FOR EACH ROW
BEGIN
    IF (:NEW.nvd_id = 0) OR (:NEW.nvd_id IS NULL)
    THEN
        :NEW.nvd_id := ID_ndi_vlk_decision (:NEW.nvd_id);
    END IF;
END;
/
