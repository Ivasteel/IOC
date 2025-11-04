/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NT_INFO_PROVIDER
    BEFORE INSERT
    ON uss_ndi.ndi_nt_info_provider
    FOR EACH ROW
BEGIN
    IF (:NEW.nip_id = 0) OR (:NEW.nip_id IS NULL)
    THEN
        :NEW.nip_id := ID_ndi_nt_info_provider (:NEW.nip_id);
    END IF;
END;
/
