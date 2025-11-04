/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_SCPP_FAMILY
    BEFORE INSERT
    ON uss_person.sc_scpp_family
    FOR EACH ROW
BEGIN
    IF (:NEW.scpf_id = 0) OR (:NEW.scpf_id IS NULL)
    THEN
        :NEW.scpf_id := ID_sc_scpp_family (:NEW.scpf_id);
    END IF;
END;
/
