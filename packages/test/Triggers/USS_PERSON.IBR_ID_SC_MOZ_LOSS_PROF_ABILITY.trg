/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_MOZ_LOSS_PROF_ABILITY
    BEFORE INSERT
    ON uss_person.sc_moz_loss_prof_ability
    FOR EACH ROW
BEGIN
    IF (:NEW.scml_id = 0) OR (:NEW.scml_id IS NULL)
    THEN
        :NEW.scml_id := ID_sc_moz_loss_prof_ability (:NEW.scml_id);
    END IF;
END;
/
