/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MS_RECIPIENT
    BEFORE INSERT
    ON uss_ndi.ndi_ms_recipient
    FOR EACH ROW
BEGIN
    IF (:NEW.rec_id = 0) OR (:NEW.rec_id IS NULL)
    THEN
        :NEW.rec_id := ID_ndi_ms_recipient (:NEW.rec_id);
    END IF;
END;
/
