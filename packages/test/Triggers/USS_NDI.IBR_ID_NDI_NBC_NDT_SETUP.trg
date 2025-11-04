/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NBC_NDT_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_nbc_ndt_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.nbts_id = 0) OR (:NEW.nbts_id IS NULL)
    THEN
        :NEW.nbts_id := ID_ndi_nbc_ndt_setup (:NEW.nbts_id);
    END IF;
END;
/
