/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_INCOME_TP_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_income_tp_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nitc_id = 0) OR (:NEW.nitc_id IS NULL)
    THEN
        :NEW.nitc_id := ID_ndi_income_tp_config (:NEW.nitc_id);
    END IF;
END;
/
