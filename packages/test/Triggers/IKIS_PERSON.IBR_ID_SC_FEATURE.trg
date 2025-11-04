/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_FEATURE
    BEFORE INSERT
    ON IKIS_PERSON.sc_feature
    FOR EACH ROW
BEGIN
    IF (:NEW.scf_id = 0) OR (:NEW.scf_id IS NULL)
    THEN
        :NEW.scf_id := ID_sc_feature (:NEW.scf_id);
    END IF;
END;
/
