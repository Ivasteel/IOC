/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_ADM_BLOCKED_CODE
    BEFORE INSERT
    ON uss_person.nt_adm_blocked_code
    FOR EACH ROW
BEGIN
    IF (:NEW.nta_id = 0) OR (:NEW.nta_id IS NULL)
    THEN
        :NEW.nta_id := ID_nt_adm_blocked_code (:NEW.nta_id);
    END IF;
END;
/
