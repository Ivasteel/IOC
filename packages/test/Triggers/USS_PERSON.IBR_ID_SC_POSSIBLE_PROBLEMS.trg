/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_POSSIBLE_PROBLEMS
    BEFORE INSERT
    ON uss_person.sc_possible_problems
    FOR EACH ROW
BEGIN
    IF (:NEW.spp_id = 0) OR (:NEW.spp_id IS NULL)
    THEN
        :NEW.spp_id := ID_sc_possible_problems (:NEW.spp_id);
    END IF;
END;
/
