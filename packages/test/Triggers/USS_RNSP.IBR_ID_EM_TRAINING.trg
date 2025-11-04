/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_EM_TRAINING
    BEFORE INSERT
    ON uss_rnsp.em_training
    FOR EACH ROW
BEGIN
    IF (:NEW.emt_id = 0) OR (:NEW.emt_id IS NULL)
    THEN
        :NEW.emt_id := ID_em_training (:NEW.emt_id);
    END IF;
END;
/
