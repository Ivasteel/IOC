/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_RVA_LOG
    BEFORE INSERT
    ON uss_rnsp.rva_log
    FOR EACH ROW
BEGIN
    IF (:NEW.rval_id = 0) OR (:NEW.rval_id IS NULL)
    THEN
        :NEW.rval_id := ID_rva_log (:NEW.rval_id);
    END IF;
END;
/
