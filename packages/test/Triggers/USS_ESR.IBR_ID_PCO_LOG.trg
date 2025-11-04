/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PCO_LOG
    BEFORE INSERT
    ON uss_esr.pco_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pcol_id = 0) OR (:NEW.pcol_id IS NULL)
    THEN
        :NEW.pcol_id := ID_pco_log (:NEW.pcol_id);
    END IF;
END;
/
