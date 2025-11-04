/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AC_DETAIL
    BEFORE INSERT
    ON uss_esr.ac_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.acd_id = 0) OR (:NEW.acd_id IS NULL)
    THEN
        :NEW.acd_id := ID_ac_detail (:NEW.acd_id);
    END IF;
END;
/
