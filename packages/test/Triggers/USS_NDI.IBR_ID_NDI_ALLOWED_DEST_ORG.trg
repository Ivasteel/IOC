/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_ALLOWED_DEST_ORG
    BEFORE INSERT
    ON uss_ndi.ndi_allowed_dest_org
    FOR EACH ROW
BEGIN
    IF (:NEW.nado_id = 0) OR (:NEW.nado_id IS NULL)
    THEN
        :NEW.nado_id := ID_ndi_allowed_dest_org (:NEW.nado_id);
    END IF;
END;
/
