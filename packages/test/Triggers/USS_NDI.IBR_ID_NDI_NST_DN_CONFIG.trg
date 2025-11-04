/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_DN_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nst_dn_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nnnc_id = 0) OR (:NEW.nnnc_id IS NULL)
    THEN
        :NEW.nnnc_id := ID_ndi_nst_dn_config (:NEW.nnnc_id);
    END IF;
END;
/
