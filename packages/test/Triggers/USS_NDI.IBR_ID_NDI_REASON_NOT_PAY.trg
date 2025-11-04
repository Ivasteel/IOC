/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REASON_NOT_PAY
    BEFORE INSERT
    ON uss_ndi.ndi_reason_not_pay
    FOR EACH ROW
BEGIN
    IF (:NEW.rnp_id = 0) OR (:NEW.rnp_id IS NULL)
    THEN
        :NEW.rnp_id := ID_ndi_reason_not_pay (:NEW.rnp_id);
    END IF;
END;
/
