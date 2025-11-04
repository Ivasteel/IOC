/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_SESSION
    BEFORE INSERT
    ON ikis_rbm.cu_session
    FOR EACH ROW
BEGIN
    IF (:NEW.cus_id = 0) OR (:NEW.cus_id IS NULL)
    THEN
        :NEW.cus_id := ID_cu_session (:NEW.cus_id);
    END IF;
END;
/
