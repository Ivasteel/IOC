/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_REJECT_INFO
    BEFORE INSERT
    ON uss_esr.pd_reject_info
    FOR EACH ROW
BEGIN
    IF (:NEW.pri_id = 0) OR (:NEW.pri_id IS NULL)
    THEN
        :NEW.pri_id := ID_pd_reject_info (:NEW.pri_id);
    END IF;
END;
/
