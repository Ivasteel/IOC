/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_MASS_EXCHANGES
    BEFORE INSERT
    ON uss_esr.mass_exchanges
    FOR EACH ROW
BEGIN
    IF (:NEW.me_id = 0) OR (:NEW.me_id IS NULL)
    THEN
        :NEW.me_id := ID_mass_exchanges (:NEW.me_id);
    END IF;
END;
/
