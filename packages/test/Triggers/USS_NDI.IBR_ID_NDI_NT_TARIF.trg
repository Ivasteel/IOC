/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NT_TARIF
    BEFORE INSERT
    ON uss_ndi.ndi_nt_tarif
    FOR EACH ROW
BEGIN
    IF (:NEW.ntf_id = 0) OR (:NEW.ntf_id IS NULL)
    THEN
        :NEW.ntf_id := ID_ndi_nt_tarif (:NEW.ntf_id);
    END IF;
END;
/
