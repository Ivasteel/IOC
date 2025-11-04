/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_MOZ_ZOZ
    BEFORE INSERT
    ON uss_person.sc_moz_zoz
    FOR EACH ROW
BEGIN
    IF (:NEW.scmz_id = 0) OR (:NEW.scmz_id IS NULL)
    THEN
        :NEW.scmz_id := ID_sc_moz_zoz (:NEW.scmz_id);
    END IF;
END;
/
