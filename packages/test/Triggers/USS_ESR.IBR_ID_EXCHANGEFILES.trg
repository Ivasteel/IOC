/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_EXCHANGEFILES
    BEFORE INSERT
    ON uss_esr.exchangefiles
    FOR EACH ROW
BEGIN
    IF (:NEW.ef_id = 0) OR (:NEW.ef_id IS NULL)
    THEN
        :NEW.ef_id := ID_exchangefiles (:NEW.ef_id);
    END IF;
END;
/
