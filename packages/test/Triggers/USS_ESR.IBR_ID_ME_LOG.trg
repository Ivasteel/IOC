/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_LOG
    BEFORE INSERT
    ON uss_esr.me_log
    FOR EACH ROW
BEGIN
    IF (:NEW.mel_id = 0) OR (:NEW.mel_id IS NULL)
    THEN
        :NEW.mel_id := ID_me_log (:NEW.mel_id);
    END IF;
END;
/
