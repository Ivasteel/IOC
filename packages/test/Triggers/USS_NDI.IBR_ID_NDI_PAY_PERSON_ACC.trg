/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PAY_PERSON_ACC
    BEFORE INSERT
    ON uss_ndi.ndi_pay_person_acc
    FOR EACH ROW
BEGIN
    IF (:NEW.dppa_id = 0) OR (:NEW.dppa_id IS NULL)
    THEN
        :NEW.dppa_id := ID_ndi_pay_person_acc (:NEW.dppa_id);
    END IF;
END;
/
