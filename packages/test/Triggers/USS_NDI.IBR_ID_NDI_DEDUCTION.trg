/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DEDUCTION
    BEFORE INSERT
    ON uss_ndi.ndi_deduction
    FOR EACH ROW
BEGIN
    IF (:NEW.ndn_id = 0) OR (:NEW.ndn_id IS NULL)
    THEN
        :NEW.ndn_id := ID_ndi_deduction (:NEW.ndn_id);
    END IF;
END;
/
