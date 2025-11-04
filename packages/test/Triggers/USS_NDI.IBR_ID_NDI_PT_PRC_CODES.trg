/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PT_PRC_CODES
    BEFORE INSERT
    ON uss_ndi.ndi_pt_prc_codes
    FOR EACH ROW
BEGIN
    IF (:NEW.ppc_id = 0) OR (:NEW.ppc_id IS NULL)
    THEN
        :NEW.ppc_id := ID_ndi_pt_prc_codes (:NEW.ppc_id);
    END IF;
END;
/
