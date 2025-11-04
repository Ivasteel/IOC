/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_UXP_MEMBERS
    BEFORE INSERT
    ON uss_ndi.ndi_uxp_members
    FOR EACH ROW
BEGIN
    IF (:NEW.um_id = 0) OR (:NEW.um_id IS NULL)
    THEN
        :NEW.um_id := ID_ndi_uxp_members (:NEW.um_id);
    END IF;
END;
/
