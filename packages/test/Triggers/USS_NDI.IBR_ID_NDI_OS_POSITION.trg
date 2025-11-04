/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_OS_POSITION
    BEFORE INSERT
    ON uss_ndi.ndi_os_position
    FOR EACH ROW
BEGIN
    IF (:NEW.osp_id = 0) OR (:NEW.osp_id IS NULL)
    THEN
        :NEW.osp_id := ID_ndi_os_position (:NEW.osp_id);
    END IF;
END;
/
