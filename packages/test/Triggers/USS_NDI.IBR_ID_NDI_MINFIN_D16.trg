/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MINFIN_D16
    BEFORE INSERT
    ON uss_ndi.ndi_minfin_d16
    FOR EACH ROW
BEGIN
    IF (:NEW.d16_id = 0) OR (:NEW.d16_id IS NULL)
    THEN
        :NEW.d16_id := ID_ndi_minfin_d16 (:NEW.d16_id);
    END IF;
END;
/
