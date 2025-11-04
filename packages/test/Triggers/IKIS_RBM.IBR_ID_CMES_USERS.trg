/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CMES_USERS
    BEFORE INSERT
    ON ikis_rbm.cmes_users
    FOR EACH ROW
BEGIN
    IF (:NEW.cu_id = 0) OR (:NEW.cu_id IS NULL)
    THEN
        :NEW.cu_id := ID_cmes_users (:NEW.cu_id);
    END IF;
END;
/
