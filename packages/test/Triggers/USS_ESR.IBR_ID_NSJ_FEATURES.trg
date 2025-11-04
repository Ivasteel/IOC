/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_FEATURES
    BEFORE INSERT
    ON uss_esr.nsj_features
    FOR EACH ROW
BEGIN
    IF (:NEW.njf_id = 0) OR (:NEW.njf_id IS NULL)
    THEN
        :NEW.njf_id := ID_nsj_features (:NEW.njf_id);
    END IF;
END;
/
