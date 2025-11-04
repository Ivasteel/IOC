/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_ID_LOCAL_PROCEDURE_CALL_LOG
    BEFORE INSERT
    ON ikis_sys.local_procedure_call_log
    FOR EACH ROW
BEGIN
    IF (:NEW.lpcl_id = 0) OR (:NEW.lpcl_id IS NULL)
    THEN
        :NEW.lpcl_id := ID_local_procedure_call_log (:NEW.lpcl_id);
    END IF;
END;
/
