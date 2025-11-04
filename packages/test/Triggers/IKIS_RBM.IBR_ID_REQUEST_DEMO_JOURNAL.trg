/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_REQUEST_DEMO_JOURNAL
    BEFORE INSERT
    ON ikis_rbm.request_demo_journal
    FOR EACH ROW
BEGIN
    IF (:NEW.rdj_id = 0) OR (:NEW.rdj_id IS NULL)
    THEN
        :NEW.rdj_id := ID_request_demo_journal (:NEW.rdj_id);
    END IF;
END;
/
