/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PARAMSESR
    BEFORE INSERT
    ON uss_esr.paramsesr
    FOR EACH ROW
BEGIN
    IF (:NEW.prm_id = 0) OR (:NEW.prm_id IS NULL)
    THEN
        :NEW.prm_id := ID_paramsesr (:NEW.prm_id);
    END IF;
END;
/
