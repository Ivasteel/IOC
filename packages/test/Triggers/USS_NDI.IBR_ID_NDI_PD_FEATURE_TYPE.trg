/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PD_FEATURE_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_pd_feature_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nft_id = 0) OR (:NEW.nft_id IS NULL)
    THEN
        :NEW.nft_id := ID_ndi_pd_feature_type (:NEW.nft_id);
    END IF;
END;
/
