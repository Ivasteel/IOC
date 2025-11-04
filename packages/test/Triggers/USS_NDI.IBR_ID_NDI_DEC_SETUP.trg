/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DEC_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_dec_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.nds_id = 0) OR (:NEW.nds_id IS NULL)
    THEN
        :NEW.nds_id := ID_ndi_dec_setup (:NEW.nds_id);
    END IF;
END;
/
