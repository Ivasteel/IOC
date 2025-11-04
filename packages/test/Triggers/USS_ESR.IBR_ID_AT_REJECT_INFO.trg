/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_REJECT_INFO
    BEFORE INSERT
    ON uss_esr.at_reject_info
    FOR EACH ROW
BEGIN
    IF (:NEW.ari_id = 0) OR (:NEW.ari_id IS NULL)
    THEN
        :NEW.ari_id := ID_at_reject_info (:NEW.ari_id);
    END IF;
END;
/
