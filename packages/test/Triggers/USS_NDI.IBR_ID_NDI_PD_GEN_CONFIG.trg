/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PD_GEN_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_pd_gen_config
    FOR EACH ROW
BEGIN
    IF (:NEW.npgc_id = 0) OR (:NEW.npgc_id IS NULL)
    THEN
        :NEW.npgc_id := ID_ndi_pd_gen_config (:NEW.npgc_id);
    END IF;
END;
/
