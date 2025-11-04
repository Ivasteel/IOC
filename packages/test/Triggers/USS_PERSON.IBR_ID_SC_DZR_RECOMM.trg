/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_DZR_RECOMM
    BEFORE INSERT
    ON uss_person.sc_dzr_recomm
    FOR EACH ROW
BEGIN
    IF (:NEW.scdr_id = 0) OR (:NEW.scdr_id IS NULL)
    THEN
        :NEW.scdr_id := ID_sc_dzr_recomm (:NEW.scdr_id);
    END IF;
END;
/
