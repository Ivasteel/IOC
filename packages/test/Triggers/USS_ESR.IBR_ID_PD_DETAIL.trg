/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_DETAIL
    BEFORE INSERT
    ON uss_esr.pd_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.pdd_id = 0) OR (:NEW.pdd_id IS NULL)
    THEN
        :NEW.pdd_id := ID_pd_detail (:NEW.pdd_id);
    END IF;
END;
/
