/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RECALCULATES
    BEFORE INSERT
    ON uss_esr.ReCalculates
    FOR EACH ROW
BEGIN
    IF (:NEW.rc_id = 0) OR (:NEW.rc_id IS NULL)
    THEN
        :NEW.rc_id := ID_ReCalculates (:NEW.rc_id);
    END IF;
END;
/
