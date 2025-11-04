/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_DN_DETAIL
    BEFORE INSERT
    ON uss_esr.dn_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.dnd_id = 0) OR (:NEW.dnd_id IS NULL)
    THEN
        :NEW.dnd_id := ID_dn_detail (:NEW.dnd_id);
    END IF;
END;
/
