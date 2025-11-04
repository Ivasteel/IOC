/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MONTHS
    BEFORE INSERT
    ON uss_ndi.ndi_months
    FOR EACH ROW
BEGIN
    IF (:NEW.nm_id = 0) OR (:NEW.nm_id IS NULL)
    THEN
        :NEW.nm_id := ID_ndi_months (:NEW.nm_id);
    END IF;
END;
/
