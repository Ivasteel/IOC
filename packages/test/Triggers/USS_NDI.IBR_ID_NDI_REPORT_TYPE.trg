/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REPORT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_report_type
    FOR EACH ROW
BEGIN
    IF (:NEW.rt_id = 0) OR (:NEW.rt_id IS NULL)
    THEN
        :NEW.rt_id := ID_ndi_report_type (:NEW.rt_id);
    END IF;
END;
/
