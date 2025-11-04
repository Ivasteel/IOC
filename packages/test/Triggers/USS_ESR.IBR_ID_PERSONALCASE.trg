/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PERSONALCASE
    BEFORE INSERT
    ON uss_esr.PersonalCase
    FOR EACH ROW
BEGIN
    IF (:NEW.pc_id = 0) OR (:NEW.pc_id IS NULL)
    THEN
        :NEW.pc_id := ID_PersonalCase (:NEW.pc_id);
    END IF;
END;
/
