/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PAY_PERSON
    BEFORE INSERT
    ON uss_ndi.ndi_pay_person
    FOR EACH ROW
BEGIN
    IF (:NEW.dpp_id = 0) OR (:NEW.dpp_id IS NULL)
    THEN
        :NEW.dpp_id := ID_ndi_pay_person (:NEW.dpp_id);
    END IF;
END;
/
