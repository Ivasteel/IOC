/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_DN_MONTH_USAGE
    BEFORE INSERT
    ON uss_esr.dn_month_usage
    FOR EACH ROW
BEGIN
    IF (:NEW.dnu_id = 0) OR (:NEW.dnu_id IS NULL)
    THEN
        :NEW.dnu_id := ID_dn_month_usage (:NEW.dnu_id);
    END IF;
END;
/
