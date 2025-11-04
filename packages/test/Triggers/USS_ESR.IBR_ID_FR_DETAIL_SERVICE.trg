/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FR_DETAIL_SERVICE
    BEFORE INSERT
    ON uss_esr.fr_detail_service
    FOR EACH ROW
BEGIN
    IF (:NEW.frs_id = 0) OR (:NEW.frs_id IS NULL)
    THEN
        :NEW.frs_id := ID_fr_detail_service (:NEW.frs_id);
    END IF;
END;
/
