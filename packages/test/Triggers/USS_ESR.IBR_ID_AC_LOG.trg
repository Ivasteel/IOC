/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AC_LOG
    BEFORE INSERT
    ON uss_esr.ac_log
    FOR EACH ROW
BEGIN
    IF (:NEW.acl_id = 0) OR (:NEW.acl_id IS NULL)
    THEN
        :NEW.acl_id := ID_ac_log (:NEW.acl_id);
    END IF;
END;
/
