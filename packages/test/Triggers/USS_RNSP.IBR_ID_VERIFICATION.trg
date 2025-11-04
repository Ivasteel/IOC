/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_VERIFICATION
    BEFORE INSERT
    ON uss_rnsp.verification
    FOR EACH ROW
BEGIN
    IF (:NEW.vf_id = 0) OR (:NEW.vf_id IS NULL)
    THEN
        :NEW.vf_id := ID_verification (:NEW.vf_id);
    END IF;
END;
/
