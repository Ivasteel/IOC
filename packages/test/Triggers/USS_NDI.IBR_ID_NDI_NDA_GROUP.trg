/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NDA_GROUP
    BEFORE INSERT
    ON uss_ndi.ndi_nda_group
    FOR EACH ROW
BEGIN
    IF (:NEW.nng_id = 0) OR (:NEW.nng_id IS NULL)
    THEN
        :NEW.nng_id := ID_ndi_nda_group (:NEW.nng_id);
    END IF;
END;
/
