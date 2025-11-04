/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_LOCATION
    BEFORE INSERT
    ON uss_esr.pc_location
    FOR EACH ROW
BEGIN
    IF (:NEW.pl_id = 0) OR (:NEW.pl_id IS NULL)
    THEN
        :NEW.pl_id := ID_pc_location (:NEW.pl_id);
    END IF;
END;
/
