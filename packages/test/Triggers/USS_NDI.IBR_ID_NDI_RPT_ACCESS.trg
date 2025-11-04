/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RPT_ACCESS
    BEFORE INSERT
    ON uss_ndi.ndi_rpt_access
    FOR EACH ROW
BEGIN
    IF (:NEW.ra_id = 0) OR (:NEW.ra_id IS NULL)
    THEN
        :NEW.ra_id := ID_ndi_rpt_access (:NEW.ra_id);
    END IF;
END;
/
