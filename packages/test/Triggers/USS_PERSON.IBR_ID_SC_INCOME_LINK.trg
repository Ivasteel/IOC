/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_INCOME_LINK
    BEFORE INSERT
    ON uss_person.sc_income_link
    FOR EACH ROW
BEGIN
    IF (:NEW.sil_id = 0) OR (:NEW.sil_id IS NULL)
    THEN
        :NEW.sil_id := ID_sc_income_link (:NEW.sil_id);
    END IF;
END;
/
