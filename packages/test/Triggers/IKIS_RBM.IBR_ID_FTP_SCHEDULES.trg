/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_FTP_SCHEDULES
    BEFORE INSERT
    ON ikis_rbm.ftp_schedules
    FOR EACH ROW
BEGIN
    IF (:NEW.fs_id = 0) OR (:NEW.fs_id IS NULL)
    THEN
        :NEW.fs_id := ID_ftp_schedules (:NEW.fs_id);
    END IF;
END;
/
