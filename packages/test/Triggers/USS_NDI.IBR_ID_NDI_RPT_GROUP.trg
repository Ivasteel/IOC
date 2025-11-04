/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RPT_GROUP
    BEFORE INSERT
    ON uss_ndi.ndi_rpt_group
    FOR EACH ROW
BEGIN
    IF (:NEW.nrg_id = 0) OR (:NEW.nrg_id IS NULL)
    THEN
        :NEW.nrg_id := ID_ndi_rpt_group (:NEW.nrg_id);
    END IF;
END;
/
