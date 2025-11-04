/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_FEATURE_HIST
    BEFORE INSERT
    ON uss_person.sc_feature_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.scs_id = 0) OR (:NEW.scs_id IS NULL)
    THEN
        :NEW.scs_id := ID_sc_feature_hist (:NEW.scs_id);
    END IF;
END;
/
