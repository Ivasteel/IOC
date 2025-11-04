/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_VPPUN_RESULT_ROWS
    BEFORE INSERT
    ON uss_esr.me_vppun_result_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mvsr_id = 0) OR (:NEW.mvsr_id IS NULL)
    THEN
        :NEW.mvsr_id := ID_me_vppun_result_rows (:NEW.mvsr_id);
    END IF;
END;
/
