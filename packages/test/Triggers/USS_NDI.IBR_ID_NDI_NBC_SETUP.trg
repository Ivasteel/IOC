/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NBC_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_nbc_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.nbcs_id = 0) OR (:NEW.nbcs_id IS NULL)
    THEN
        :NEW.nbcs_id := ID_ndi_nbc_setup (:NEW.nbcs_id);
    END IF;
END;
/
