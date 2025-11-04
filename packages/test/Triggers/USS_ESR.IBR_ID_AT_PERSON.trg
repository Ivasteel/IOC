/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_PERSON
    BEFORE INSERT
    ON uss_esr.at_person
    FOR EACH ROW
BEGIN
    IF (:NEW.atp_id = 0) OR (:NEW.atp_id IS NULL)
    THEN
        :NEW.atp_id := ID_at_person (:NEW.atp_id);
    END IF;
END;
/
