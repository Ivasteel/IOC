/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BENEFIT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_benefit_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nbt_id = 0) OR (:NEW.nbt_id IS NULL)
    THEN
        :NEW.nbt_id := ID_ndi_benefit_type (:NEW.nbt_id);
    END IF;
END;
/
