/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RECIPIENT_MAIL
    BEFORE INSERT
    ON ikis_rbm.RECIPIENT_MAIL
    FOR EACH ROW
BEGIN
    IF (:NEW.rm_id = 0) OR (:NEW.rm_id IS NULL)
    THEN
        :NEW.rm_id := ID_RECIPIENT_MAIL (:NEW.rm_id);
    END IF;
END;
/
