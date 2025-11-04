/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_DECLARATION
    BEFORE INSERT
    ON uss_esr.ap_declaration
    FOR EACH ROW
BEGIN
    IF (:NEW.apr_id = 0) OR (:NEW.apr_id IS NULL)
    THEN
        :NEW.apr_id := ID_ap_declaration (:NEW.apr_id);
    END IF;
END;
/
