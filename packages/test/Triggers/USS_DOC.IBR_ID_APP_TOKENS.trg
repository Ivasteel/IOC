/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_APP_TOKENS
    BEFORE INSERT
    ON uss_doc.app_tokens
    FOR EACH ROW
BEGIN
    IF (:NEW.apt_id = 0) OR (:NEW.apt_id IS NULL)
    THEN
        :NEW.apt_id := ID_app_tokens (:NEW.apt_id);
    END IF;
END;
/
