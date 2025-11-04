/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NDA_GROUP_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nda_group_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nngc_id = 0) OR (:NEW.nngc_id IS NULL)
    THEN
        :NEW.nngc_id := ID_ndi_nda_group_config (:NEW.nngc_id);
    END IF;
END;
/
