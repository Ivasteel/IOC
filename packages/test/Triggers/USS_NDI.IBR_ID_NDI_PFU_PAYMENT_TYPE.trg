/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PFU_PAYMENT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_pfu_payment_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nppt_id = 0) OR (:NEW.nppt_id IS NULL)
    THEN
        :NEW.nppt_id := ID_ndi_pfu_payment_type (:NEW.nppt_id);
    END IF;
END;
/
