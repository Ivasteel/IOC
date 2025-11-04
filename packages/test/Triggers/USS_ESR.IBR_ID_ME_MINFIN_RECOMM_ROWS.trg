/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_MINFIN_RECOMM_ROWS
    BEFORE INSERT
    ON uss_esr.me_minfin_recomm_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.merc_id = 0) OR (:NEW.merc_id IS NULL)
    THEN
        :NEW.merc_id := ID_me_minfin_recomm_rows (:NEW.merc_id);
    END IF;
END;
/
