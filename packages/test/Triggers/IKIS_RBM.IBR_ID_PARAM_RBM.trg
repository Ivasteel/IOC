/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_PARAM_RBM
    BEFORE INSERT
    ON ikis_rbm.param_rbm
    FOR EACH ROW
BEGIN
    IF (:NEW.prm_id = 0) OR (:NEW.prm_id IS NULL)
    THEN
        :NEW.prm_id := ID_param_rbm (:NEW.prm_id);
    END IF;
END;
/
