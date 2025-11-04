/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_VOUCHERES
    BEFORE INSERT
    ON uss_person.sc_voucheres
    FOR EACH ROW
BEGIN
    IF (:NEW.scas_id = 0) OR (:NEW.scas_id IS NULL)
    THEN
        :NEW.scas_id := ID_sc_voucheres (:NEW.scas_id);
    END IF;
END;
/
