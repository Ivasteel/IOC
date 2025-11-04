/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_UXP_FILES
    BEFORE INSERT
    ON ikis_rbm.uxp_files
    FOR EACH ROW
BEGIN
    IF (:NEW.uf_id = 0) OR (:NEW.uf_id IS NULL)
    THEN
        :NEW.uf_id := ID_uxp_files (:NEW.uf_id);
    END IF;
END;
/
