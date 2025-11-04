/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_CP_REANDINGS
    BEFORE INSERT
    ON uss_person.cp_reandings
    FOR EACH ROW
BEGIN
    IF (:NEW.cpr_id = 0) OR (:NEW.cpr_id IS NULL)
    THEN
        :NEW.cpr_id := ID_cp_reandings (:NEW.cpr_id);
    END IF;
END;
/
