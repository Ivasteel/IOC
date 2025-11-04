/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_PAYMENT_CODES
    BEFORE INSERT
    ON uss_ndi.ndi_payment_codes
    FOR EACH ROW
BEGIN
    IF (:NEW.npc_id = 0) OR (:NEW.npc_id IS NULL)
    THEN
        :NEW.npc_id := ID_ndi_payment_codes (:NEW.npc_id);
    END IF;
END;
/
