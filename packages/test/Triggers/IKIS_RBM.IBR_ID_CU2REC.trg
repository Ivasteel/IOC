/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU2REC
    BEFORE INSERT
    ON ikis_rbm.cu2rec
    FOR EACH ROW
BEGIN
    IF (:NEW.cu2rec_id = 0) OR (:NEW.cu2rec_id IS NULL)
    THEN
        :NEW.cu2rec_id := ID_cu2rec (:NEW.cu2rec_id);
    END IF;
END;
/
