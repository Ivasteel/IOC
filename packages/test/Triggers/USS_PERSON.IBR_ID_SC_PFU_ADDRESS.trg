/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_ADDRESS
    BEFORE INSERT
    ON uss_person.sc_pfu_address
    FOR EACH ROW
BEGIN
    IF (:NEW.scpa_id = 0) OR (:NEW.scpa_id IS NULL)
    THEN
        :NEW.scpa_id := ID_sc_pfu_address (:NEW.scpa_id);
    END IF;
END;
/
