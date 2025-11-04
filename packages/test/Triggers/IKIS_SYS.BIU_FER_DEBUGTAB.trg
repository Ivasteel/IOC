/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.BIU_FER_DEBUGTAB
    BEFORE INSERT OR UPDATE
    ON ikis_sys.debugtab
    FOR EACH ROW
BEGIN
    :new.modules := UPPER (:new.modules);
    :new.show_date := UPPER (:new.show_date);
    :new.session_id := UPPER (:new.session_id);
    :new.userid := UPPER (:new.userid);

    DECLARE
        l_date   VARCHAR2 (100);
    BEGIN
        l_date := TO_CHAR (SYSDATE, :new.date_format);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20001,
                'Invalid Date Format In Debug Date Format');
    END;
END;
/
