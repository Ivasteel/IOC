/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_KAOT_STATE
    BEFORE INSERT
    ON uss_ndi.ndi_kaot_state
    FOR EACH ROW
BEGIN
    IF (:NEW.kaots_id = 0) OR (:NEW.kaots_id IS NULL)
    THEN
        :NEW.kaots_id := ID_ndi_kaot_state (:NEW.kaots_id);
    END IF;
END;
/
