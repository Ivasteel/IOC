/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_WARES
    BEFORE INSERT
    ON uss_esr.at_wares
    FOR EACH ROW
BEGIN
    IF (:NEW.atw_id = 0) OR (:NEW.atw_id IS NULL)
    THEN
        :NEW.atw_id := ID_at_wares (:NEW.atw_id);
    END IF;
END;
/
