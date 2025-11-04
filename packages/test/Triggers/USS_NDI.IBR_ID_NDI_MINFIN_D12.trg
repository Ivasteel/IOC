/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MINFIN_D12
    BEFORE INSERT
    ON uss_ndi.ndi_minfin_d12
    FOR EACH ROW
BEGIN
    IF (:NEW.d12_id = 0) OR (:NEW.d12_id IS NULL)
    THEN
        :NEW.d12_id := ID_ndi_minfin_d12 (:NEW.d12_id);
    END IF;
END;
/
