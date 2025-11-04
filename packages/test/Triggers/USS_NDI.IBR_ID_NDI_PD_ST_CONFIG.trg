/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PD_ST_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_pd_st_config
    FOR EACH ROW
BEGIN
    IF (:NEW.npsc_id = 0) OR (:NEW.npsc_id IS NULL)
    THEN
        :NEW.npsc_id := ID_ndi_pd_st_config (:NEW.npsc_id);
    END IF;
END;
/
