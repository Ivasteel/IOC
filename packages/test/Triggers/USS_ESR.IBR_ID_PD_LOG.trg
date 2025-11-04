/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_LOG
    BEFORE INSERT
    ON uss_esr.pd_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pdl_id = 0) OR (:NEW.pdl_id IS NULL)
    THEN
        :NEW.pdl_id := ID_pd_log (:NEW.pdl_id);
    END IF;
END;
/
