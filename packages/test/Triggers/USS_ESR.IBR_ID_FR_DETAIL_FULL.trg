/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FR_DETAIL_FULL
    BEFORE INSERT
    ON uss_esr.fr_detail_full
    FOR EACH ROW
BEGIN
    IF (:NEW.frf_id = 0) OR (:NEW.frf_id IS NULL)
    THEN
        :NEW.frf_id := ID_fr_detail_full (:NEW.frf_id);
    END IF;
END;
/
