/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_INCOME_SRC
    BEFORE INSERT
    ON uss_esr.at_income_src
    FOR EACH ROW
BEGIN
    IF (:NEW.ais_id = 0) OR (:NEW.ais_id IS NULL)
    THEN
        :NEW.ais_id := ID_at_income_src (:NEW.ais_id);
    END IF;
END;
/
