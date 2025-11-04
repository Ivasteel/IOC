/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_EXCHANGE_SYSTEM
    BEFORE INSERT
    ON uss_ndi.ndi_exchange_system
    FOR EACH ROW
BEGIN
    IF (:NEW.nes_id = 0) OR (:NEW.nes_id IS NULL)
    THEN
        :NEW.nes_id := ID_ndi_exchange_system (:NEW.nes_id);
    END IF;
END;
/
