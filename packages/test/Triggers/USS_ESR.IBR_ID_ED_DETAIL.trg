/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ED_DETAIL
    BEFORE INSERT
    ON uss_esr.ed_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.edd_id = 0) OR (:NEW.edd_id IS NULL)
    THEN
        :NEW.edd_id := ID_ed_detail (:NEW.edd_id);
    END IF;
END;
/
