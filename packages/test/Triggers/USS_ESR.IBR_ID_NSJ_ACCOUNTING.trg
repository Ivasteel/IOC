/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_ACCOUNTING
    BEFORE INSERT
    ON uss_esr.nsj_accounting
    FOR EACH ROW
BEGIN
    IF (:NEW.nja_id = 0) OR (:NEW.nja_id IS NULL)
    THEN
        :NEW.nja_id := ID_nsj_accounting (:NEW.nja_id);
    END IF;
END;
/
