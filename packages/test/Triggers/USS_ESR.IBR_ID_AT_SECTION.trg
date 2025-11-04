/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_SECTION
    BEFORE INSERT
    ON uss_esr.at_section
    FOR EACH ROW
BEGIN
    IF (:NEW.ate_id = 0) OR (:NEW.ate_id IS NULL)
    THEN
        :NEW.ate_id := ID_at_section (:NEW.ate_id);
    END IF;
END;
/
