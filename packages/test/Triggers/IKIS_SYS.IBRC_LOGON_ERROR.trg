/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBRC_LOGON_ERROR
    AFTER SERVERERROR
    ON DATABASE
    DISABLE
BEGIN
    IF (IS_SERVERERROR (1017))
    THEN
        ikis_changes_utl.change_at (
            999999,
            0,
            6,
            IKIS_CHANGES_UTL.GetSessionParam ('SESSION_USER'));
    END IF;

    NULL;
END;
/
