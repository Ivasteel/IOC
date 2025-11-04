/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NDA_VALIDATION
    BEFORE INSERT
    ON uss_ndi.ndi_nda_validation
    FOR EACH ROW
BEGIN
    IF (:NEW.nnv_id = 0) OR (:NEW.nnv_id IS NULL)
    THEN
        :NEW.nnv_id := ID_ndi_nda_validation (:NEW.nnv_id);
    END IF;
END;
/
