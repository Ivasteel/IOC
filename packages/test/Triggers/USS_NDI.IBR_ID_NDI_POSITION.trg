/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_POSITION
    BEFORE INSERT
    ON uss_ndi.ndi_position
    FOR EACH ROW
BEGIN
    IF (:NEW.nsp_id = 0) OR (:NEW.nsp_id IS NULL)
    THEN
        :NEW.nsp_id := ID_ndi_position (:NEW.nsp_id);
    END IF;
END;
/
