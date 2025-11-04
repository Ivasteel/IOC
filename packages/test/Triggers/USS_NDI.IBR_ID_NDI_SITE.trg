/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_SITE
    BEFORE INSERT
    ON uss_ndi.ndi_site
    FOR EACH ROW
BEGIN
    IF (:NEW.nis_id = 0) OR (:NEW.nis_id IS NULL)
    THEN
        :NEW.nis_id := ID_ndi_site (:NEW.nis_id);
    END IF;
END;
/
