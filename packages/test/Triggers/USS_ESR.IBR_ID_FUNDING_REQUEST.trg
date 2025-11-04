/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FUNDING_REQUEST
    BEFORE INSERT
    ON uss_esr.funding_request
    FOR EACH ROW
BEGIN
    IF (:NEW.fr_id = 0) OR (:NEW.fr_id IS NULL)
    THEN
        :NEW.fr_id := ID_funding_request (:NEW.fr_id);
    END IF;
END;
/
