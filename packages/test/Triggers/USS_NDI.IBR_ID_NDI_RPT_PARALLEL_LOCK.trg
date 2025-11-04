/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RPT_PARALLEL_LOCK
    BEFORE INSERT
    ON uss_ndi.ndi_rpt_parallel_lock
    FOR EACH ROW
BEGIN
    IF (:NEW.ndpl_id = 0) OR (:NEW.ndpl_id IS NULL)
    THEN
        :NEW.ndpl_id := ID_ndi_rpt_parallel_lock (:NEW.ndpl_id);
    END IF;
END;
/
