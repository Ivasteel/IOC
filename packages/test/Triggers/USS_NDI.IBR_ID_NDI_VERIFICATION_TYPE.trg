/* Formatted on 8/12/2025 5:55:58 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_VERIFICATION_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_verification_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nvt_id = 0) OR (:NEW.nvt_id IS NULL)
    THEN
        :NEW.nvt_id := ID_ndi_verification_type (:NEW.nvt_id);
    END IF;
END;
/
