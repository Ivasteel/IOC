/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_SRC_DISABILITY_ASOPD
    BEFORE INSERT
    ON uss_esr.src_disability_asopd
    FOR EACH ROW
BEGIN
    IF (:NEW.sda_id = 0) OR (:NEW.sda_id IS NULL)
    THEN
        :NEW.sda_id := ID_src_disability_asopd (:NEW.sda_id);
    END IF;
END;
/
