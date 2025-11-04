/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_FIN_PAY_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_fin_pay_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nfpc_id = 0) OR (:NEW.nfpc_id IS NULL)
    THEN
        :NEW.nfpc_id := ID_ndi_fin_pay_config (:NEW.nfpc_id);
    END IF;
END;
/
