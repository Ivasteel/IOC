/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_CONST_SUM
    BEFORE INSERT
    ON uss_ndi.ndi_nst_const_sum
    FOR EACH ROW
BEGIN
    IF (:NEW.nncs_id = 0) OR (:NEW.nncs_id IS NULL)
    THEN
        :NEW.nncs_id := ID_ndi_nst_const_sum (:NEW.nncs_id);
    END IF;
END;
/
