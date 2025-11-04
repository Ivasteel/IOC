/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_DPS_RESULT_ROWS
    BEFORE INSERT
    ON uss_esr.me_dps_result_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mpsr_id = 0) OR (:NEW.mpsr_id IS NULL)
    THEN
        :NEW.mpsr_id := ID_me_dps_result_rows (:NEW.mpsr_id);
    END IF;
END;
/
