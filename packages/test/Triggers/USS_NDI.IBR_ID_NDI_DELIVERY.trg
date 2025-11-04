/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_ndi_delivery
    BEFORE INSERT
    ON uss_ndi.ndi_delivery
    FOR EACH ROW
BEGIN
    IF (:NEW.nd_id = 0) OR (:NEW.nd_id IS NULL)
    THEN
        :NEW.nd_id := ID_ndi_delivery (:NEW.nd_id);
    END IF;
END;
/
