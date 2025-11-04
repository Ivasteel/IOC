/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PD_ROW_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_pd_row_type
    FOR EACH ROW
BEGIN
    IF (:NEW.ndp_id = 0) OR (:NEW.ndp_id IS NULL)
    THEN
        :NEW.ndp_id := ID_ndi_pd_row_type (:NEW.ndp_id);
    END IF;
END;
/
