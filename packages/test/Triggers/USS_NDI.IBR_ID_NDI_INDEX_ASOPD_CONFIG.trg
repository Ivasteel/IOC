/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_INDEX_ASOPD_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_index_asopd_config
    FOR EACH ROW
BEGIN
    IF (:NEW.niac_id = 0) OR (:NEW.niac_id IS NULL)
    THEN
        :NEW.niac_id := ID_ndi_index_asopd_config (:NEW.niac_id);
    END IF;
END;
/
