/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_INCOME_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nst_income_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nic_id = 0) OR (:NEW.nic_id IS NULL)
    THEN
        :NEW.nic_id := ID_ndi_nst_income_config (:NEW.nic_id);
    END IF;
END;
/
