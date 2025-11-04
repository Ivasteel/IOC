/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PENSION
    BEFORE INSERT
    ON uss_person.sc_pension
    FOR EACH ROW
BEGIN
    IF (:NEW.scp_id = 0) OR (:NEW.scp_id IS NULL)
    THEN
        :NEW.scp_id := ID_sc_pension (:NEW.scp_id);
    END IF;
END;
/
