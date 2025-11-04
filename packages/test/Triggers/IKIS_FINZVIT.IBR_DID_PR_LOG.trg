/* Formatted on 8/12/2025 6:06:34 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_FINZVIT.IBR_DID_PR_LOG
    BEFORE INSERT
    ON ikis_finzvit.pr_log
    FOR EACH ROW
BEGIN
    :NEW.prl_id := DID_pr_log (:NEW.prl_id);
END;
/
