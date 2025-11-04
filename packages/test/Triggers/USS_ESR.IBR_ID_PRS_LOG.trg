/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PRS_LOG
    BEFORE INSERT
    ON uss_esr.prs_log
    FOR EACH ROW
BEGIN
    IF (:NEW.prsl_id = 0) OR (:NEW.prsl_id IS NULL)
    THEN
        :NEW.prsl_id := ID_prs_log (:NEW.prsl_id);
    END IF;
END;
/
