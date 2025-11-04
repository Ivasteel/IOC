/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_OTHER_INFO
    BEFORE INSERT
    ON uss_esr.nsj_other_info
    FOR EACH ROW
BEGIN
    IF (:NEW.njo_id = 0) OR (:NEW.njo_id IS NULL)
    THEN
        :NEW.njo_id := ID_nsj_other_info (:NEW.njo_id);
    END IF;
END;
/
