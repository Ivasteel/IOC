/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CBI_WARES
    BEFORE INSERT
    ON uss_ndi.ndi_cbi_wares
    FOR EACH ROW
BEGIN
    IF (:NEW.wrn_id = 0) OR (:NEW.wrn_id IS NULL)
    THEN
        :NEW.wrn_id := ID_ndi_cbi_wares (:NEW.wrn_id);
    END IF;
END;
/
