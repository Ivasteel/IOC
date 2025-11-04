/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_IN_EXP_ITEMS
    BEFORE INSERT
    ON uss_ndi.ndi_in_exp_items
    FOR EACH ROW
BEGIN
    IF (:NEW.nie_id = 0) OR (:NEW.nie_id IS NULL)
    THEN
        :NEW.nie_id := ID_ndi_in_exp_items (:NEW.nie_id);
    END IF;
END;
/
