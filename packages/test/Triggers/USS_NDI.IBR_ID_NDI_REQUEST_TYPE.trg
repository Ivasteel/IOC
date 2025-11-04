/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REQUEST_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_request_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nrt_id = 0) OR (:NEW.nrt_id IS NULL)
    THEN
        :NEW.nrt_id := ID_ndi_request_type (:NEW.nrt_id);
    END IF;
END;
/
