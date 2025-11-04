/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_KATOTTG
    BEFORE INSERT
    ON uss_ndi.ndi_katottg
    FOR EACH ROW
BEGIN
    IF (:NEW.kaot_id = 0) OR (:NEW.kaot_id IS NULL)
    THEN
        :NEW.kaot_id := ID_ndi_katottg (:NEW.kaot_id);
    END IF;
END;
/
