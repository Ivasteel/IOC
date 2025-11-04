/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_STREET_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_street_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nsrt_id = 0) OR (:NEW.nsrt_id IS NULL)
    THEN
        :NEW.nsrt_id := ID_ndi_street_type (:NEW.nsrt_id);
    END IF;
END;
/
