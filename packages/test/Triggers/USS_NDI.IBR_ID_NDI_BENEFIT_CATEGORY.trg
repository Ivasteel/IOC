/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BENEFIT_CATEGORY
    BEFORE INSERT
    ON uss_ndi.ndi_benefit_category
    FOR EACH ROW
BEGIN
    IF (:NEW.nbc_id = 0) OR (:NEW.nbc_id IS NULL)
    THEN
        :NEW.nbc_id := ID_ndi_benefit_category (:NEW.nbc_id);
    END IF;
END;
/
