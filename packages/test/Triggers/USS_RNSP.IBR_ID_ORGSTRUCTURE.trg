/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_ORGSTRUCTURE
    BEFORE INSERT
    ON uss_rnsp.orgstructure
    FOR EACH ROW
BEGIN
    IF (:NEW.os_id = 0) OR (:NEW.os_id IS NULL)
    THEN
        :NEW.os_id := ID_orgstructure (:NEW.os_id);
    END IF;
END;
/
