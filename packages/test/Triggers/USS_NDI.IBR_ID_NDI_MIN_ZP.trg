/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MIN_ZP
    BEFORE INSERT
    ON uss_ndi.ndi_min_zp
    FOR EACH ROW
BEGIN
    IF (:NEW.nmz_id = 0) OR (:NEW.nmz_id IS NULL)
    THEN
        :NEW.nmz_id := ID_ndi_min_zp (:NEW.nmz_id);
    END IF;
END;
/
