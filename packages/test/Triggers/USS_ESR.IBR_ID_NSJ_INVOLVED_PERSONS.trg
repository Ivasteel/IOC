/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_INVOLVED_PERSONS
    BEFORE INSERT
    ON uss_esr.nsj_involved_persons
    FOR EACH ROW
BEGIN
    IF (:NEW.nji_id = 0) OR (:NEW.nji_id IS NULL)
    THEN
        :NEW.nji_id := ID_nsj_involved_persons (:NEW.nji_id);
    END IF;
END;
/
