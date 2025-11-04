/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AC_BINDINGS
    BEFORE INSERT
    ON uss_esr.ac_bindings
    FOR EACH ROW
BEGIN
    IF (:NEW.acb_id = 0) OR (:NEW.acb_id IS NULL)
    THEN
        :NEW.acb_id := ID_ac_bindings (:NEW.acb_id);
    END IF;
END;
/
