/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_ESV_UNLOAD_ROWS
    BEFORE INSERT
    ON uss_esr.me_esv_unload_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.meur_id = 0) OR (:NEW.meur_id IS NULL)
    THEN
        :NEW.meur_id := ID_me_esv_unload_rows (:NEW.meur_id);
    END IF;
END;
/
