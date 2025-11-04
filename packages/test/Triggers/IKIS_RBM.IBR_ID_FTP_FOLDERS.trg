/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_FTP_FOLDERS
    BEFORE INSERT
    ON ikis_rbm.ftp_folders
    FOR EACH ROW
BEGIN
    IF (:NEW.ff_id = 0) OR (:NEW.ff_id IS NULL)
    THEN
        :NEW.ff_id := ID_ftp_folders (:NEW.ff_id);
    END IF;
END;
/
