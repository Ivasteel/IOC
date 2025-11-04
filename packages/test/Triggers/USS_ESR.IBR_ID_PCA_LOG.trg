/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PCA_LOG
    BEFORE INSERT
    ON uss_esr.pca_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pcal_id = 0) OR (:NEW.pcal_id IS NULL)
    THEN
        :NEW.pcal_id := ID_pca_log (:NEW.pcal_id);
    END IF;
END;
/
