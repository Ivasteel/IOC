/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_CALENDAR
    BEFORE INSERT
    ON uss_esr.at_calendar
    FOR EACH ROW
BEGIN
    IF (:NEW.atc_id = 0) OR (:NEW.atc_id IS NULL)
    THEN
        :NEW.atc_id := ID_at_calendar (:NEW.atc_id);
    END IF;
END;
/
