/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CHILDREN_SERVICE
    BEFORE INSERT
    ON uss_ndi.ndi_children_service
    FOR EACH ROW
BEGIN
    IF (:NEW.ncs_id = 0) OR (:NEW.ncs_id IS NULL)
    THEN
        :NEW.ncs_id := ID_ndi_children_service (:NEW.ncs_id);
    END IF;
END;
/
