/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CBI_WARE_GROUP
    BEFORE INSERT
    ON uss_ndi.ndi_cbi_ware_group
    FOR EACH ROW
BEGIN
    IF (:NEW.wt_id = 0) OR (:NEW.wt_id IS NULL)
    THEN
        :NEW.wt_id := ID_ndi_cbi_ware_group (:NEW.wt_id);
    END IF;
END;
/
