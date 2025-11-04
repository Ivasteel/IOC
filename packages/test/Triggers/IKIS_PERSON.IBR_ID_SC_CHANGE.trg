/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_CHANGE
    BEFORE INSERT
    ON IKIS_PERSON.sc_change
    FOR EACH ROW
BEGIN
    IF (:NEW.scc_id = 0) OR (:NEW.scc_id IS NULL)
    THEN
        :NEW.scc_id := ID_sc_change (:NEW.scc_id);
    END IF;
END;
/
