/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_MOZ_DZR_RECOMM
    BEFORE INSERT
    ON uss_person.sc_moz_dzr_recomm
    FOR EACH ROW
BEGIN
    IF (:NEW.scmd_id = 0) OR (:NEW.scmd_id IS NULL)
    THEN
        :NEW.scmd_id := ID_sc_moz_dzr_recomm (:NEW.scmd_id);
    END IF;
END;
/
