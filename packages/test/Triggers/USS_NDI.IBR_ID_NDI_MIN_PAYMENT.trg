/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MIN_PAYMENT
    BEFORE INSERT
    ON uss_ndi.ndi_min_payment
    FOR EACH ROW
BEGIN
    IF (:NEW.nmp_id = 0) OR (:NEW.nmp_id IS NULL)
    THEN
        :NEW.nmp_id := ID_ndi_min_payment (:NEW.nmp_id);
    END IF;
END;
/
