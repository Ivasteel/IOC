/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_INDIVIDUAL_PLAN
    BEFORE INSERT
    ON uss_esr.at_individual_plan
    FOR EACH ROW
BEGIN
    IF (:NEW.atip_id = 0) OR (:NEW.atip_id IS NULL)
    THEN
        :NEW.atip_id := ID_at_individual_plan (:NEW.atip_id);
    END IF;
END;
/
