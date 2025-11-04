/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CMES
    BEFORE INSERT
    ON uss_ndi.ndi_cmes
    FOR EACH ROW
BEGIN
    IF (:NEW.cmes_id = 0) OR (:NEW.cmes_id IS NULL)
    THEN
        :NEW.cmes_id := ID_ndi_cmes (:NEW.cmes_id);
    END IF;
END;
/
