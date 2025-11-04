/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RR_LIST
    BEFORE INSERT
    ON uss_esr.rr_list
    FOR EACH ROW
BEGIN
    IF (:NEW.rrl_id = 0) OR (:NEW.rrl_id IS NULL)
    THEN
        :NEW.rrl_id := ID_rr_list (:NEW.rrl_id);
    END IF;
END;
/
