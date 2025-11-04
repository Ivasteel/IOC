/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_DATA_ORDERING
    BEFORE INSERT
    ON uss_esr.pc_data_ordering
    FOR EACH ROW
BEGIN
    IF (:NEW.pco_id = 0) OR (:NEW.pco_id IS NULL)
    THEN
        :NEW.pco_id := ID_pc_data_ordering (:NEW.pco_id);
    END IF;
END;
/
