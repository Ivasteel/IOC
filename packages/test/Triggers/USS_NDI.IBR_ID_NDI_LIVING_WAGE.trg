/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_LIVING_WAGE
    BEFORE INSERT
    ON uss_ndi.ndi_living_wage
    FOR EACH ROW
BEGIN
    IF (:NEW.lgw_id = 0) OR (:NEW.lgw_id IS NULL)
    THEN
        :NEW.lgw_id := ID_ndi_living_wage (:NEW.lgw_id);
    END IF;
END;
/
