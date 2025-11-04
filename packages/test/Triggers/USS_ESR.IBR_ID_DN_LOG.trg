/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_DN_LOG
    BEFORE INSERT
    ON uss_esr.dn_log
    FOR EACH ROW
BEGIN
    IF (:NEW.dnl_id = 0) OR (:NEW.dnl_id IS NULL)
    THEN
        :NEW.dnl_id := ID_dn_log (:NEW.dnl_id);
    END IF;
END;
/
