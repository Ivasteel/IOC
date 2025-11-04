/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RNP_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_rnp_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nrpc_id = 0) OR (:NEW.nrpc_id IS NULL)
    THEN
        :NEW.nrpc_id := ID_ndi_rnp_config (:NEW.nrpc_id);
    END IF;
END;
/
