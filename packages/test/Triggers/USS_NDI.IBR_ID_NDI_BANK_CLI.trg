/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BANK_CLI
    BEFORE INSERT
    ON uss_ndi.ndi_bank_cli
    FOR EACH ROW
BEGIN
    IF (:NEW.nbi_id = 0) OR (:NEW.nbi_id IS NULL)
    THEN
        :NEW.nbi_id := ID_ndi_bank_cli (:NEW.nbi_id);
    END IF;
END;
/
