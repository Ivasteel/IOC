/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_UXP_ACCESS
    BEFORE INSERT
    ON uss_ndi.ndi_uxp_access
    FOR EACH ROW
BEGIN
    IF (:NEW.nua_id = 0) OR (:NEW.nua_id IS NULL)
    THEN
        :NEW.nua_id := ID_ndi_uxp_access (:NEW.nua_id);
    END IF;
END;
/
