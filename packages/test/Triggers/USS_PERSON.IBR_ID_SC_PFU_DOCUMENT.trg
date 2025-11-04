/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_DOCUMENT
    BEFORE INSERT
    ON uss_person.sc_pfu_document
    FOR EACH ROW
BEGIN
    IF (:NEW.scpo_id = 0) OR (:NEW.scpo_id IS NULL)
    THEN
        :NEW.scpo_id := ID_sc_pfu_document (:NEW.scpo_id);
    END IF;
END;
/
