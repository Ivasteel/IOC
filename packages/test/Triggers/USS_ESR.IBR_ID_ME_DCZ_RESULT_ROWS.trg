/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_DCZ_RESULT_ROWS
    BEFORE INSERT
    ON uss_esr.me_dcz_result_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mdsr_id = 0) OR (:NEW.mdsr_id IS NULL)
    THEN
        :NEW.mdsr_id := ID_me_dcz_result_rows (:NEW.mdsr_id);
    END IF;
END;
/
