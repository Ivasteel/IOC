/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSP_SC_JOURNAL
    BEFORE INSERT
    ON uss_esr.nsp_sc_journal
    FOR EACH ROW
BEGIN
    IF (:NEW.nsj_id = 0) OR (:NEW.nsj_id IS NULL)
    THEN
        :NEW.nsj_id := ID_nsp_sc_journal (:NEW.nsj_id);
    END IF;
END;
/
