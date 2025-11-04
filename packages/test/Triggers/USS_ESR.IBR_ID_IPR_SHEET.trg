/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_IPR_SHEET
    BEFORE INSERT
    ON uss_esr.ipr_sheet
    FOR EACH ROW
BEGIN
    IF (:NEW.iprs_id = 0) OR (:NEW.iprs_id IS NULL)
    THEN
        :NEW.iprs_id := ID_ipr_sheet (:NEW.iprs_id);
    END IF;
END;
/
