/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RC_CANDIDATE_ATTR
    BEFORE INSERT
    ON uss_esr.rc_candidate_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.rcca_id = 0) OR (:NEW.rcca_id IS NULL)
    THEN
        :NEW.rcca_id := ID_rc_candidate_attr (:NEW.rcca_id);
    END IF;
END;
/
