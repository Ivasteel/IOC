/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_OS_EDUCATION_LV
    BEFORE INSERT
    ON uss_ndi.ndi_os_Education_lv
    FOR EACH ROW
BEGIN
    IF (:NEW.ose_id = 0) OR (:NEW.ose_id IS NULL)
    THEN
        :NEW.ose_id := ID_ndi_os_Education_lv (:NEW.ose_id);
    END IF;
END;
/
