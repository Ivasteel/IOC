/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_ID_IKIS_USER_ACTIVITY
    BEFORE INSERT
    ON ikis_sys.IKIS_USER_ACTIVITY
    FOR EACH ROW
BEGIN
    IF (:NEW.iua_id = 0) OR (:NEW.iua_id IS NULL)
    THEN
        :NEW.iua_id := ID_IKIS_USER_ACTIVITY (:NEW.iua_id);
    END IF;
END;
/
