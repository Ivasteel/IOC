/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_DN_EXCLUDE
    BEFORE INSERT
    ON uss_ndi.ndi_nst_dn_exclude
    FOR EACH ROW
BEGIN
    IF (:NEW.nnde_id = 0) OR (:NEW.nnde_id IS NULL)
    THEN
        :NEW.nnde_id := ID_ndi_nst_dn_exclude (:NEW.nnde_id);
    END IF;
END;
/
