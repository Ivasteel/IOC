/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RC_CANDIDATES
    BEFORE INSERT
    ON uss_esr.rc_candidates
    FOR EACH ROW
BEGIN
    IF (:NEW.rcc_id = 0) OR (:NEW.rcc_id IS NULL)
    THEN
        :NEW.rcc_id := ID_rc_candidates (:NEW.rcc_id);
    END IF;
END;
/
