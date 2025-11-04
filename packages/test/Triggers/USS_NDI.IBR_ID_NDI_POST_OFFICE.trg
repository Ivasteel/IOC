/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_POST_OFFICE
    BEFORE INSERT
    ON uss_ndi.ndi_post_office
    FOR EACH ROW
BEGIN
    IF (:NEW.npo_id = 0) OR (:NEW.npo_id IS NULL)
    THEN
        :NEW.npo_id := ID_ndi_post_office (:NEW.npo_id);
    END IF;
END;
/
