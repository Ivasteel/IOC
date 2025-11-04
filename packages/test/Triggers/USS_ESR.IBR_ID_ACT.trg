/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ACT
    BEFORE INSERT
    ON uss_esr.act
    FOR EACH ROW
BEGIN
    IF (:NEW.at_id = 0) OR (:NEW.at_id IS NULL)
    THEN
        :NEW.at_id := ID_act (:NEW.at_id);
    END IF;
END;
/
