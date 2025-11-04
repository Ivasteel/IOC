/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PE_LOG
    BEFORE INSERT
    ON uss_esr.pe_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pel_id = 0) OR (:NEW.pel_id IS NULL)
    THEN
        :NEW.pel_id := ID_pe_log (:NEW.pel_id);
    END IF;
END;
/
