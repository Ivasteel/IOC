/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_HIST
    BEFORE INSERT
    ON ikis_rbm.cu_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.ch_id = 0) OR (:NEW.ch_id IS NULL)
    THEN
        :NEW.ch_id := ID_cu_hist (:NEW.ch_id);
    END IF;
END;
/
