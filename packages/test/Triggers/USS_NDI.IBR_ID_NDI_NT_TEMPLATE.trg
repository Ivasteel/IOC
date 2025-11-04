/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NT_TEMPLATE
    BEFORE INSERT
    ON uss_ndi.ndi_nt_template
    FOR EACH ROW
BEGIN
    IF (:NEW.ntt_id = 0) OR (:NEW.ntt_id IS NULL)
    THEN
        :NEW.ntt_id := ID_ndi_nt_template (:NEW.ntt_id);
    END IF;
END;
/
