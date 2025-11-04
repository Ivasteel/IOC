/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_BANK
    BEFORE INSERT
    ON uss_ndi.ndi_bank
    FOR EACH ROW
BEGIN
    IF (:NEW.nb_id = 0) OR (:NEW.nb_id IS NULL)
    THEN
        :NEW.nb_id := ID_ndi_bank (:NEW.nb_id);
    END IF;
END;
/
