/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_LGOT_SET1
    BEFORE INSERT
    ON uss_esr.src_lgot_set1
    FOR EACH ROW
BEGIN
    IF (:NEW.sls_id = 0) OR (:NEW.sls_id IS NULL)
    THEN
        :NEW.sls_id := ID_src_lgot_set1 (:NEW.sls_id);
    END IF;
END;
/
