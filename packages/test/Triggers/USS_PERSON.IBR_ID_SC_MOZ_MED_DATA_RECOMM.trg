/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_MOZ_MED_DATA_RECOMM
    BEFORE INSERT
    ON uss_person.sc_moz_med_data_recomm
    FOR EACH ROW
BEGIN
    IF (:NEW.scmm_id = 0) OR (:NEW.scmm_id IS NULL)
    THEN
        :NEW.scmm_id := ID_sc_moz_med_data_recomm (:NEW.scmm_id);
    END IF;
END;
/
