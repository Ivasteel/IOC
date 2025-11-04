/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_MINFIN_RESULT_ROWS
    BEFORE INSERT
    ON uss_esr.me_minfin_result_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mesr_id = 0) OR (:NEW.mesr_id IS NULL)
    THEN
        :NEW.mesr_id := ID_me_minfin_result_rows (:NEW.mesr_id);
    END IF;
END;
/
