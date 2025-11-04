/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_LGW_SUB_LEVEL
    BEFORE INSERT
    ON uss_ndi.ndi_lgw_sub_level
    FOR EACH ROW
BEGIN
    IF (:NEW.nlsl_id = 0) OR (:NEW.nlsl_id IS NULL)
    THEN
        :NEW.nlsl_id := ID_ndi_lgw_sub_level (:NEW.nlsl_id);
    END IF;
END;
/
