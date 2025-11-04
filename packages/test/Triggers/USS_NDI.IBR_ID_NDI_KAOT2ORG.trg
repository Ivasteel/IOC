/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_KAOT2ORG
    BEFORE INSERT
    ON "USS_NDI"."NDI_KAOT2ORG_TO_DEL"
    FOR EACH ROW
BEGIN
    IF (:NEW.nk2o_id = 0) OR (:NEW.nk2o_id IS NULL)
    THEN
        :NEW.nk2o_id := ID_ndi_kaot2org (:NEW.nk2o_id);
    END IF;
END;
/
