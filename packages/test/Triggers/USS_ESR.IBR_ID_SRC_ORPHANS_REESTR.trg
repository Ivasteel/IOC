/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_ORPHANS_REESTR
    BEFORE INSERT
    ON uss_esr.src_orphans_reestr
    FOR EACH ROW
BEGIN
    IF (:NEW.sor_id = 0) OR (:NEW.sor_id IS NULL)
    THEN
        :NEW.sor_id := ID_src_orphans_reestr (:NEW.sor_id);
    END IF;
END;
/
