/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NSA_GROUP
    BEFORE INSERT
    ON uss_ndi.ndi_nsa_group
    FOR EACH ROW
BEGIN
    IF (:NEW.nsag_id = 0) OR (:NEW.nsag_id IS NULL)
    THEN
        :NEW.nsag_id := ID_ndi_nsa_group (:NEW.nsag_id);
    END IF;
END;
/
