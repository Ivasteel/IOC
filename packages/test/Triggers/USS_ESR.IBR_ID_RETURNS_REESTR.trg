/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RETURNS_REESTR
    BEFORE INSERT
    ON uss_esr.returns_reestr
    FOR EACH ROW
BEGIN
    IF (:NEW.rr_id = 0) OR (:NEW.rr_id IS NULL)
    THEN
        :NEW.rr_id := ID_returns_reestr (:NEW.rr_id);
    END IF;
END;
/
