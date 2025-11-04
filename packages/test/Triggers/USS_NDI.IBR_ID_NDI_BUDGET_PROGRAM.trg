/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BUDGET_PROGRAM
    BEFORE INSERT
    ON uss_ndi.ndi_budget_program
    FOR EACH ROW
BEGIN
    IF (:NEW.nbg_id = 0) OR (:NEW.nbg_id IS NULL)
    THEN
        :NEW.nbg_id := ID_ndi_budget_program (:NEW.nbg_id);
    END IF;
END;
/
