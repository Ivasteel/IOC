/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_OS_SPECIALIZATION
    BEFORE INSERT
    ON uss_ndi.ndi_os_specialization
    FOR EACH ROW
BEGIN
    IF (:NEW.oss_id = 0) OR (:NEW.oss_id IS NULL)
    THEN
        :NEW.oss_id := ID_ndi_os_specialization (:NEW.oss_id);
    END IF;
END;
/
