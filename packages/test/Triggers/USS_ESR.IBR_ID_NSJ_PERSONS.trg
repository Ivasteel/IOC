/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_PERSONS
    BEFORE INSERT
    ON uss_esr.nsj_persons
    FOR EACH ROW
BEGIN
    IF (:NEW.njp_id = 0) OR (:NEW.njp_id IS NULL)
    THEN
        :NEW.njp_id := ID_nsj_persons (:NEW.njp_id);
    END IF;
END;
/
