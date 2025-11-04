/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REJECT_REASON
    BEFORE INSERT
    ON uss_ndi.ndi_reject_reason
    FOR EACH ROW
BEGIN
    IF (:NEW.njr_id = 0) OR (:NEW.njr_id IS NULL)
    THEN
        :NEW.njr_id := ID_ndi_reject_reason (:NEW.njr_id);
    END IF;
END;
/
