/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PFU_REJECT_REASON
    BEFORE INSERT
    ON uss_ndi.ndi_pfu_reject_reason
    FOR EACH ROW
BEGIN
    IF (:NEW.nprj_id = 0) OR (:NEW.nprj_id IS NULL)
    THEN
        :NEW.nprj_id := ID_ndi_pfu_reject_reason (:NEW.nprj_id);
    END IF;
END;
/
