/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_OAUTH_TOKEN
    BEFORE INSERT
    ON ikis_rbm.cu_oauth_token
    FOR EACH ROW
BEGIN
    IF (:NEW.cot_id = 0) OR (:NEW.cot_id IS NULL)
    THEN
        :NEW.cot_id := ID_cu_oauth_token (:NEW.cot_id);
    END IF;
END;
/
