/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_IPR_SHEET_DETAIL
    BEFORE INSERT
    ON uss_esr.ipr_sheet_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.iprsd_id = 0) OR (:NEW.iprsd_id IS NULL)
    THEN
        :NEW.iprsd_id := ID_ipr_sheet_detail (:NEW.iprsd_id);
    END IF;
END;
/
