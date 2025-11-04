/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_RIGHT_RULE
    BEFORE INSERT
    ON uss_ndi.ndi_right_rule
    FOR EACH ROW
BEGIN
    IF (:NEW.nrr_id = 0) OR (:NEW.nrr_id IS NULL)
    THEN
        :NEW.nrr_id := ID_ndi_right_rule (:NEW.nrr_id);
    END IF;
END;
/
