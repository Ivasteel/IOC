/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REASON_UNLOCK_PAY
    BEFORE INSERT
    ON uss_ndi.ndi_reason_unlock_pay
    FOR EACH ROW
BEGIN
    IF (:NEW.rup_id = 0) OR (:NEW.rup_id IS NULL)
    THEN
        :NEW.rup_id := ID_ndi_reason_unlock_pay (:NEW.rup_id);
    END IF;
END;
/
