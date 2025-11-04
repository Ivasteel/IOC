/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_EMPLOEE
    BEFORE INSERT
    ON uss_rnsp.Emploee
    FOR EACH ROW
BEGIN
    IF (:NEW.em_id = 0) OR (:NEW.em_id IS NULL)
    THEN
        :NEW.em_id := ID_Emploee (:NEW.em_id);
    END IF;
END;
/
