/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PCO_DETAIL
    BEFORE INSERT
    ON uss_esr.pco_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.pcod_id = 0) OR (:NEW.pcod_id IS NULL)
    THEN
        :NEW.pcod_id := ID_pco_detail (:NEW.pcod_id);
    END IF;
END;
/
