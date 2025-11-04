/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_VF_ANSWER
    BEFORE INSERT
    ON uss_visit.vf_answer
    FOR EACH ROW
BEGIN
    IF (:NEW.vfa_id = 0) OR (:NEW.vfa_id IS NULL)
    THEN
        :NEW.vfa_id := ID_vf_answer (:NEW.vfa_id);
    END IF;
END;
/
