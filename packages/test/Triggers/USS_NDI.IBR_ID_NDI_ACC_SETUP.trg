/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_ACC_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_acc_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.acs_id = 0) OR (:NEW.acs_id IS NULL)
    THEN
        :NEW.acs_id := ID_ndi_acc_setup (:NEW.acs_id);
    END IF;
END;
/
