/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_FTP_SEARCH_CONFIG
    BEFORE INSERT
    ON ikis_rbm.ftp_search_config
    FOR EACH ROW
BEGIN
    IF (:NEW.fc_id = 0) OR (:NEW.fc_id IS NULL)
    THEN
        :NEW.fc_id := ID_ftp_search_config (:NEW.fc_id);
    END IF;
END;
/
