/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_SERVICE_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_service_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nst_id = 0) OR (:NEW.nst_id IS NULL)
    THEN
        :NEW.nst_id := ID_ndi_service_type (:NEW.nst_id);
    END IF;
END;
/
