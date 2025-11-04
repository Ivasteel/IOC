/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DELIVERY_REF
    BEFORE INSERT
    ON uss_ndi.ndi_delivery_ref
    FOR EACH ROW
BEGIN
    IF (:NEW.ndr_id = 0) OR (:NEW.ndr_id IS NULL)
    THEN
        :NEW.ndr_id := ID_ndi_delivery_ref (:NEW.ndr_id);
    END IF;
END;
/
