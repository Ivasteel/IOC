/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PR_SHEET
    BEFORE INSERT
    ON uss_esr.pr_sheet
    FOR EACH ROW
BEGIN
    IF (:NEW.prs_id = 0) OR (:NEW.prs_id IS NULL)
    THEN
        :NEW.prs_id := ID_pr_sheet (:NEW.prs_id);
    END IF;
END;
/
