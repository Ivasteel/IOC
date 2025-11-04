/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_OP
    BEFORE INSERT
    ON uss_ndi.ndi_op
    FOR EACH ROW
BEGIN
    IF (:NEW.op_id = 0) OR (:NEW.op_id IS NULL)
    THEN
        :NEW.op_id := ID_ndi_op (:NEW.op_id);
    END IF;
END;
/
