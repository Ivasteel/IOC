/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_CBI_WARES
    BEFORE INSERT
    ON uss_person.sc_cbi_wares
    FOR EACH ROW
BEGIN
    IF (:NEW.sccw_id = 0) OR (:NEW.sccw_id IS NULL)
    THEN
        :NEW.sccw_id := ID_sc_cbi_wares (:NEW.sccw_id);
    END IF;
END;
/
