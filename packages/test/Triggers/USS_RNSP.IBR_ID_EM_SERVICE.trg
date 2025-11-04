/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_EM_SERVICE
    BEFORE INSERT
    ON uss_rnsp.em_service
    FOR EACH ROW
BEGIN
    IF (:NEW.ems_id = 0) OR (:NEW.ems_id IS NULL)
    THEN
        :NEW.ems_id := ID_em_service (:NEW.ems_id);
    END IF;
END;
/
