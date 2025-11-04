/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_REQUEST_DEMO
    BEFORE INSERT
    ON uss_ndi.ndi_request_demo
    FOR EACH ROW
BEGIN
    IF (:NEW.nrd_id = 0) OR (:NEW.nrd_id IS NULL)
    THEN
        :NEW.nrd_id := ID_ndi_request_demo (:NEW.nrd_id);
    END IF;
END;
/
