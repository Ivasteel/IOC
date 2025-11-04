/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_PARAMSRNSP
    BEFORE INSERT
    ON uss_rnsp.paramsrnsp
    FOR EACH ROW
BEGIN
    IF (:NEW.prm_id = 0) OR (:NEW.prm_id IS NULL)
    THEN
        :NEW.prm_id := ID_paramsrnsp (:NEW.prm_id);
    END IF;
END;
/
