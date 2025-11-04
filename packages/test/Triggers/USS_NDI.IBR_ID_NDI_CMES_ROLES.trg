/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CMES_ROLES
    BEFORE INSERT
    ON uss_ndi.ndi_cmes_roles
    FOR EACH ROW
BEGIN
    IF (:NEW.cr_id = 0) OR (:NEW.cr_id IS NULL)
    THEN
        :NEW.cr_id := ID_ndi_cmes_roles (:NEW.cr_id);
    END IF;
END;
/
