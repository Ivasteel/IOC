/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_REQUEST_JOURNAL
    BEFORE INSERT
    ON ikis_rbm.request_journal
    FOR EACH ROW
BEGIN
    IF (:NEW.rn_id = 0) OR (:NEW.rn_id IS NULL)
    THEN
        :NEW.rn_id := ID_request_journal (:NEW.rn_id);
    END IF;
END;
/
