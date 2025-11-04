/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_SIGNERS
    BEFORE INSERT
    ON uss_esr.at_signers
    FOR EACH ROW
BEGIN
    IF (:NEW.ati_id = 0) OR (:NEW.ati_id IS NULL)
    THEN
        :NEW.ati_id := ID_at_signers (:NEW.ati_id);
    END IF;
END;
/
