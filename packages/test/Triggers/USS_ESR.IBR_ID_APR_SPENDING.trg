/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_APR_SPENDING
    BEFORE INSERT
    ON uss_esr.apr_spending
    FOR EACH ROW
BEGIN
    IF (:NEW.aprs_id = 0) OR (:NEW.aprs_id IS NULL)
    THEN
        :NEW.aprs_id := ID_apr_spending (:NEW.aprs_id);
    END IF;
END;
/
