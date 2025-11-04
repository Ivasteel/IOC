/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_UNIT
    BEFORE INSERT
    ON "USS_NDI"."NDI_UNIT_TO_DELETE"
    FOR EACH ROW
BEGIN
    IF (:NEW.nu_id = 0) OR (:NEW.nu_id IS NULL)
    THEN
        :NEW.nu_id := ID_ndi_unit (:NEW.nu_id);
    END IF;
END;
/
