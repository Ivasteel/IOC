/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SOCIALCARD
    BEFORE INSERT
    ON IKIS_PERSON.SocialCard
    FOR EACH ROW
BEGIN
    IF (:NEW.sc_id = 0) OR (:NEW.sc_id IS NULL)
    THEN
        :NEW.sc_id := ID_SocialCard (:NEW.sc_id);
    END IF;
END;
/
