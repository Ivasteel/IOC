/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NT_TEMPLATE_GROUP
    BEFORE INSERT
    ON uss_ndi.ndi_nt_template_group
    FOR EACH ROW
BEGIN
    IF (:NEW.ntg_id = 0) OR (:NEW.ntg_id IS NULL)
    THEN
        :NEW.ntg_id := ID_ndi_nt_template_group (:NEW.ntg_id);
    END IF;
END;
/
