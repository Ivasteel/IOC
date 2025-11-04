/* Formatted on 8/12/2025 6:12:49 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_WEBPROXY.apex$team_dev_files_biu
    BEFORE INSERT OR UPDATE
    ON IKIS_WEBPROXY.APEX$TEAM_DEV_FILES
    FOR EACH ROW
DECLARE
    l_filesize_quota   NUMBER := 15728640;
    l_filesize_mb      NUMBER;
BEGIN
    FOR c1 IN (SELECT team_dev_fs_limit
                 FROM apex_workspaces
                WHERE workspace_id = v ('APP_SECURITY_GROUP_ID'))
    LOOP
        l_filesize_quota := c1.team_dev_fs_limit;
        l_filesize_mb := l_filesize_quota / 1048576;
    END LOOP;

    IF :new."ID" IS NULL
    THEN
        SELECT TO_NUMBER (SYS_GUID (), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
          INTO :new.id
          FROM sys.DUAL;
    END IF;

    IF INSERTING
    THEN
        :new.created := LOCALTIMESTAMP;
        :new.created_by := NVL (wwv_flow.g_user, USER);
        :new.updated := LOCALTIMESTAMP;
        :new.updated_by := NVL (wwv_flow.g_user, USER);
        :new.row_version_number := 1;
    ELSIF UPDATING
    THEN
        :new.row_version_number := NVL (:old.row_version_number, 1) + 1;
    END IF;

    IF     (INSERTING OR UPDATING)
       AND NVL (sys.DBMS_LOB.getlength (:new.file_blob), 0) >
           l_filesize_quota
    THEN
        raise_application_error (
            -20000,
            wwv_flow_lang.system_message ('FILE_TOO_LARGE',
                                          TRUNC (l_filesize_mb)));
    END IF;

    IF INSERTING OR UPDATING
    THEN
        :new.updated := LOCALTIMESTAMP;
        :new.updated_by := NVL (wwv_flow.g_user, USER);
    END IF;
END;
/
