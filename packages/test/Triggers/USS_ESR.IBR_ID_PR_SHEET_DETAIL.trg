/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PR_SHEET_DETAIL
    BEFORE INSERT
    ON uss_esr.pr_sheet_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.prsd_id = 0) OR (:NEW.prsd_id IS NULL)
    THEN
        :NEW.prsd_id := ID_pr_sheet_detail (:NEW.prsd_id);
    END IF;
END;
/
