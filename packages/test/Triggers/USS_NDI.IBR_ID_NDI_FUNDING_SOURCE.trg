/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_FUNDING_SOURCE
    BEFORE INSERT
    ON uss_ndi.ndi_funding_source
    FOR EACH ROW
BEGIN
    IF (:NEW.nfs_id = 0) OR (:NEW.nfs_id IS NULL)
    THEN
        :NEW.nfs_id := ID_ndi_funding_source (:NEW.nfs_id);
    END IF;
END;
/
