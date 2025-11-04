/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_STREET
    BEFORE INSERT
    ON uss_ndi.ndi_street
    FOR EACH ROW
BEGIN
    IF (:NEW.ns_id = 0) OR (:NEW.ns_id IS NULL)
    THEN
        :NEW.ns_id := ID_ndi_street (:NEW.ns_id);
    END IF;
END;
/
