/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_REQUEST
    BEFORE INSERT
    ON uss_esr.at_request
    FOR EACH ROW
BEGIN
    IF (:NEW.atrq_id = 0) OR (:NEW.atrq_id IS NULL)
    THEN
        :NEW.atrq_id := ID_at_request (:NEW.atrq_id);
    END IF;
END;
/
