/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_AT_PRINT_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_at_print_config
    FOR EACH ROW
BEGIN
    IF (:NEW.napc_id = 0) OR (:NEW.napc_id IS NULL)
    THEN
        :NEW.napc_id := ID_ndi_at_print_config (:NEW.napc_id);
    END IF;
END;
/
