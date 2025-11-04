/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_ATTESTAT
    BEFORE INSERT
    ON uss_esr.pc_attestat
    FOR EACH ROW
BEGIN
    IF (:NEW.pca_id = 0) OR (:NEW.pca_id IS NULL)
    THEN
        :NEW.pca_id := ID_pc_attestat (:NEW.pca_id);
    END IF;
END;
/
