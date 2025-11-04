/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_DOCUMENT
    BEFORE INSERT
    ON uss_esr.pc_document
    FOR EACH ROW
BEGIN
    IF (:NEW.pcd_id = 0) OR (:NEW.pcd_id IS NULL)
    THEN
        :NEW.pcd_id := ID_pc_document (:NEW.pcd_id);
    END IF;
END;
/
