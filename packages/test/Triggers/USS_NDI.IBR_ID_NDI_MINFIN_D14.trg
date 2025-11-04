/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_MINFIN_D14
    BEFORE INSERT
    ON uss_ndi.ndi_minfin_d14
    FOR EACH ROW
BEGIN
    IF (:NEW.d14_id = 0) OR (:NEW.d14_id IS NULL)
    THEN
        :NEW.d14_id := ID_ndi_minfin_d14 (:NEW.d14_id);
    END IF;
END;
/
