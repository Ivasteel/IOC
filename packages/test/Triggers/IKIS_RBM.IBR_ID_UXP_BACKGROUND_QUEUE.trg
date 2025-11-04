/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_UXP_BACKGROUND_QUEUE
    BEFORE INSERT
    ON ikis_rbm.uxp_background_queue
    FOR EACH ROW
BEGIN
    IF (:NEW.ubq_id = 0) OR (:NEW.ubq_id IS NULL)
    THEN
        :NEW.ubq_id := ID_uxp_background_queue (:NEW.ubq_id);
    END IF;
END;
/
