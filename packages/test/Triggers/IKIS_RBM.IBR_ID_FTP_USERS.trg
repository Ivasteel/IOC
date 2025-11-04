/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_FTP_USERS
    BEFORE INSERT
    ON ikis_rbm.ftp_users
    FOR EACH ROW
BEGIN
    IF (:NEW.fu_id = 0) OR (:NEW.fu_id IS NULL)
    THEN
        :NEW.fu_id := ID_ftp_users (:NEW.fu_id);
    END IF;
END;
/
