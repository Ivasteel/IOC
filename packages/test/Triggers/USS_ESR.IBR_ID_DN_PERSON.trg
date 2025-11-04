/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_DN_PERSON
    BEFORE INSERT
    ON uss_esr.dn_person
    FOR EACH ROW
BEGIN
    IF (:NEW.dnp_id = 0) OR (:NEW.dnp_id IS NULL)
    THEN
        :NEW.dnp_id := ID_dn_person (:NEW.dnp_id);
    END IF;
END;
/
