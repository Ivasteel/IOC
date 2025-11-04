/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PR_BLOCKED_ACD
    BEFORE INSERT
    ON uss_esr.pr_blocked_acd
    FOR EACH ROW
BEGIN
    IF (:NEW.prsa_id = 0) OR (:NEW.prsa_id IS NULL)
    THEN
        :NEW.prsa_id := ID_pr_blocked_acd (:NEW.prsa_id);
    END IF;
END;
/
