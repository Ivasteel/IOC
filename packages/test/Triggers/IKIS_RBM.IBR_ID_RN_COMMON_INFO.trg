/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RN_COMMON_INFO
    BEFORE INSERT
    ON ikis_rbm.rn_common_info
    FOR EACH ROW
BEGIN
    IF (:NEW.rnc_id = 0) OR (:NEW.rnc_id IS NULL)
    THEN
        :NEW.rnc_id := ID_rn_common_info (:NEW.rnc_id);
    END IF;
END;
/
