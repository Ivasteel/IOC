/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_KATOTTG_HIST
    BEFORE INSERT
    ON uss_ndi.ndi_katottg_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.kaoth_id = 0) OR (:NEW.kaoth_id IS NULL)
    THEN
        :NEW.kaoth_id := ID_ndi_katottg_hist (:NEW.kaoth_id);
    END IF;
END;
/
