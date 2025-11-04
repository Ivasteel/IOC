/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_UXP_REQ_TYPES
    BEFORE INSERT
    ON uss_ndi.ndi_uxp_req_types
    FOR EACH ROW
BEGIN
    IF (:NEW.urt_id = 0) OR (:NEW.urt_id IS NULL)
    THEN
        :NEW.urt_id := ID_ndi_uxp_req_types (:NEW.urt_id);
    END IF;
END;
/
