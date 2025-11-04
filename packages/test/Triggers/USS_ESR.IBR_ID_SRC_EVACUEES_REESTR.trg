/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_EVACUEES_REESTR
    BEFORE INSERT
    ON uss_esr.src_evacuees_reestr
    FOR EACH ROW
BEGIN
    IF (:NEW.ser_id = 0) OR (:NEW.ser_id IS NULL)
    THEN
        :NEW.ser_id := ID_src_evacuees_reestr (:NEW.ser_id);
    END IF;
END;
/
