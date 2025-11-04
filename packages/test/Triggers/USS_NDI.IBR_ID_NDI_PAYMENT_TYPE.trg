/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PAYMENT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_payment_type
    FOR EACH ROW
BEGIN
    IF (:NEW.npt_id = 0) OR (:NEW.npt_id IS NULL)
    THEN
        :NEW.npt_id := ID_ndi_payment_type (:NEW.npt_id);
    END IF;
END;
/
