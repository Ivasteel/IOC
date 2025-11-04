/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_LINKS
    BEFORE INSERT
    ON uss_esr.at_links
    FOR EACH ROW
BEGIN
    IF (:NEW.atk_id = 0) OR (:NEW.atk_id IS NULL)
    THEN
        :NEW.atk_id := ID_at_links (:NEW.atk_id);
    END IF;
END;
/
