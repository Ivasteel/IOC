/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_VF_LOG
    BEFORE INSERT
    ON uss_esr.vf_log
    FOR EACH ROW
BEGIN
    IF (:NEW.vfl_id = 0) OR (:NEW.vfl_id IS NULL)
    THEN
        :NEW.vfl_id := ID_vf_log (:NEW.vfl_id);
    END IF;
END;
/
