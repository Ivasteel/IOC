/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BUDGET
    BEFORE INSERT
    ON uss_ndi.ndi_budget
    FOR EACH ROW
BEGIN
    IF (:NEW.nbu_id = 0) OR (:NEW.nbu_id IS NULL)
    THEN
        :NEW.nbu_id := ID_ndi_budget (:NEW.nbu_id);
    END IF;
END;
/
