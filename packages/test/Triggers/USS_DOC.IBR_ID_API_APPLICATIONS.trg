/* Formatted on 8/12/2025 5:47:13 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_API_APPLICATIONS
    BEFORE INSERT
    ON uss_doc.api_applications
    FOR EACH ROW
BEGIN
    IF (:NEW.app_id = 0) OR (:NEW.app_id IS NULL)
    THEN
        :NEW.app_id := ID_api_applications (:NEW.app_id);
    END IF;
END;
/
