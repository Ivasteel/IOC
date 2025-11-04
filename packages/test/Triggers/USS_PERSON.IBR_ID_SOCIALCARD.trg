/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SOCIALCARD
    BEFORE INSERT
    ON uss_person.SocialCard
    FOR EACH ROW
BEGIN
    IF (:NEW.sc_id = 0) OR (:NEW.sc_id IS NULL)
    THEN
        :NEW.sc_id := ID_SocialCard (:NEW.sc_id);
    END IF;
END;
/
