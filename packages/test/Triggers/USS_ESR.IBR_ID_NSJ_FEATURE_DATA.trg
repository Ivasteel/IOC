/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_FEATURE_DATA
    BEFORE INSERT
    ON uss_esr.nsj_feature_data
    FOR EACH ROW
BEGIN
    IF (:NEW.njfd_id = 0) OR (:NEW.njfd_id IS NULL)
    THEN
        :NEW.njfd_id := ID_nsj_feature_data (:NEW.njfd_id);
    END IF;
END;
/
