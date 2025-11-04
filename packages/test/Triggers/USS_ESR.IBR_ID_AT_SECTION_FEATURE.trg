/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_SECTION_FEATURE
    BEFORE INSERT
    ON uss_esr.at_section_feature
    FOR EACH ROW
BEGIN
    IF (:NEW.atef_id = 0) OR (:NEW.atef_id IS NULL)
    THEN
        :NEW.atef_id := ID_at_section_feature (:NEW.atef_id);
    END IF;
END;
/
