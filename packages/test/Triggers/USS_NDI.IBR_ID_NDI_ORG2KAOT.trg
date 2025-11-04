/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_ORG2KAOT
    BEFORE INSERT
    ON uss_ndi.ndi_org2kaot
    FOR EACH ROW
BEGIN
    IF (:NEW.nok_id = 0) OR (:NEW.nok_id IS NULL)
    THEN
        :NEW.nok_id := ID_ndi_org2kaot (:NEW.nok_id);
    END IF;
END;
/
