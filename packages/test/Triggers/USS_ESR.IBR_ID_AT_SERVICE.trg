/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_SERVICE
    BEFORE INSERT
    ON uss_esr.at_service
    FOR EACH ROW
BEGIN
    IF (:NEW.ats_id = 0) OR (:NEW.ats_id IS NULL)
    THEN
        :NEW.ats_id := ID_at_service (:NEW.ats_id);
    END IF;
END;
/
