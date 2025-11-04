/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DISTRIB_PURPOSE_GR
    BEFORE INSERT
    ON uss_ndi.ndi_distrib_purpose_gr
    FOR EACH ROW
BEGIN
    IF (:NEW.dpg_id = 0) OR (:NEW.dpg_id IS NULL)
    THEN
        :NEW.dpg_id := ID_ndi_distrib_purpose_gr (:NEW.dpg_id);
    END IF;
END;
/
