/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_ORG_CHART
    BEFORE INSERT
    ON uss_ndi.ndi_org_chart
    FOR EACH ROW
BEGIN
    IF (:NEW.noc_id = 0) OR (:NEW.noc_id IS NULL)
    THEN
        :NEW.noc_id := ID_ndi_org_chart (:NEW.noc_id);
    END IF;
END;
/
