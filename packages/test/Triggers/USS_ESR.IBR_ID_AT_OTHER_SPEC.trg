/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_OTHER_SPEC
    BEFORE INSERT
    ON uss_esr.at_other_spec
    FOR EACH ROW
BEGIN
    IF (:NEW.atop_id = 0) OR (:NEW.atop_id IS NULL)
    THEN
        :NEW.atop_id := ID_at_other_spec (:NEW.atop_id);
    END IF;
END;
/
