/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PS_CHANGES
    BEFORE INSERT
    ON uss_esr.ps_changes
    FOR EACH ROW
BEGIN
    IF (:NEW.psc_id = 0) OR (:NEW.psc_id IS NULL)
    THEN
        :NEW.psc_id := ID_ps_changes (:NEW.psc_id);
    END IF;
END;
/
