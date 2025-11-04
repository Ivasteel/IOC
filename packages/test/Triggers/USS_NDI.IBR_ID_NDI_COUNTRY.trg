/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_COUNTRY
    BEFORE INSERT
    ON uss_ndi.ndi_country
    FOR EACH ROW
BEGIN
    IF (:NEW.nc_id = 0) OR (:NEW.nc_id IS NULL)
    THEN
        :NEW.nc_id := ID_ndi_country (:NEW.nc_id);
    END IF;
END;
/
