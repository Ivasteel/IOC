/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DELIVERY_DAY
    BEFORE INSERT
    ON uss_ndi.ndi_delivery_day
    FOR EACH ROW
BEGIN
    IF (:NEW.ndd_id = 0) OR (:NEW.ndd_id IS NULL)
    THEN
        :NEW.ndd_id := ID_ndi_delivery_day (:NEW.ndd_id);
    END IF;
END;
/
