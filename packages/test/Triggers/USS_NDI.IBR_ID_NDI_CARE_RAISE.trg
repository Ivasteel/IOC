/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CARE_RAISE
    BEFORE INSERT
    ON uss_ndi.ndi_care_raise
    FOR EACH ROW
BEGIN
    IF (:NEW.ncr_id = 0) OR (:NEW.ncr_id IS NULL)
    THEN
        :NEW.ncr_id := ID_ndi_care_raise (:NEW.ncr_id);
    END IF;
END;
/
