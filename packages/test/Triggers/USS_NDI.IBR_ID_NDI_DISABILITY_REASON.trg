/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DISABILITY_REASON
    BEFORE INSERT
    ON uss_ndi.ndi_disability_reason
    FOR EACH ROW
BEGIN
    IF (:NEW.ndr_id = 0) OR (:NEW.ndr_id IS NULL)
    THEN
        :NEW.ndr_id := ID_ndi_disability_reason (:NEW.ndr_id);
    END IF;
END;
/
