/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_DATA_IDENT
    BEFORE INSERT
    ON uss_person.sc_pfu_data_ident
    FOR EACH ROW
BEGIN
    IF (:NEW.scdi_id = 0) OR (:NEW.scdi_id IS NULL)
    THEN
        :NEW.scdi_id := ID_sc_pfu_data_ident (:NEW.scdi_id);
    END IF;
END;
/
