/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_EM_EDUCATION
    BEFORE INSERT
    ON uss_rnsp.em_education
    FOR EACH ROW
BEGIN
    IF (:NEW.eme_id = 0) OR (:NEW.eme_id IS NULL)
    THEN
        :NEW.eme_id := ID_em_education (:NEW.eme_id);
    END IF;
END;
/
