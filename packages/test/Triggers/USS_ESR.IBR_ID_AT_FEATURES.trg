/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_FEATURES
    BEFORE INSERT
    ON uss_esr.at_features
    FOR EACH ROW
BEGIN
    IF (:NEW.atf_id = 0) OR (:NEW.atf_id IS NULL)
    THEN
        :NEW.atf_id := ID_at_features (:NEW.atf_id);
    END IF;
END;
/
