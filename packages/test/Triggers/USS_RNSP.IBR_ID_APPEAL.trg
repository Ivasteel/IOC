/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_APPEAL
    BEFORE INSERT
    ON uss_rnsp.appeal
    FOR EACH ROW
BEGIN
    IF (:NEW.ap_id = 0) OR (:NEW.ap_id IS NULL)
    THEN
        :NEW.ap_id := ID_appeal (:NEW.ap_id);
    END IF;
END;
/
