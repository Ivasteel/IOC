/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ED_LOG
    BEFORE INSERT
    ON uss_esr.ed_log
    FOR EACH ROW
BEGIN
    IF (:NEW.edl_id = 0) OR (:NEW.edl_id IS NULL)
    THEN
        :NEW.edl_id := ID_ed_log (:NEW.edl_id);
    END IF;
END;
/
