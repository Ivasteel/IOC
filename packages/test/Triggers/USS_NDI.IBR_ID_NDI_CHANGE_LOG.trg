/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CHANGE_LOG
    BEFORE INSERT
    ON uss_ndi.ndi_change_log
    FOR EACH ROW
BEGIN
    IF (:NEW.ncl_id = 0) OR (:NEW.ncl_id IS NULL)
    THEN
        :NEW.ncl_id := ID_ndi_change_log (:NEW.ncl_id);
    END IF;
END;
/
