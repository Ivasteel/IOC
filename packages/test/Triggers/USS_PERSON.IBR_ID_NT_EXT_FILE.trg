/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_EXT_FILE
    BEFORE INSERT
    ON uss_person.nt_ext_file
    FOR EACH ROW
BEGIN
    IF (:NEW.nte_id = 0) OR (:NEW.nte_id IS NULL)
    THEN
        :NEW.nte_id := ID_nt_ext_file (:NEW.nte_id);
    END IF;
END;
/
