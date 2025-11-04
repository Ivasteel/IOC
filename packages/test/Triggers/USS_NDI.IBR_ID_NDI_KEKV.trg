/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_KEKV
    BEFORE INSERT
    ON uss_ndi.ndi_kekv
    FOR EACH ROW
BEGIN
    IF (:NEW.nkv_id = 0) OR (:NEW.nkv_id IS NULL)
    THEN
        :NEW.nkv_id := ID_ndi_kekv (:NEW.nkv_id);
    END IF;
END;
/
