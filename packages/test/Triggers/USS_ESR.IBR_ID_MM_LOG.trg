/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_MM_LOG
    BEFORE INSERT
    ON uss_esr.mm_log
    FOR EACH ROW
BEGIN
    IF (:NEW.mml_id = 0) OR (:NEW.mml_id IS NULL)
    THEN
        :NEW.mml_id := ID_mm_log (:NEW.mml_id);
    END IF;
END;
/
