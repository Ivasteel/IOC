/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_HISTSESSION
    BEFORE INSERT
    ON uss_ndi.histsession
    FOR EACH ROW
BEGIN
    IF (:NEW.hs_id = 0) OR (:NEW.hs_id IS NULL)
    THEN
        :NEW.hs_id := ID_histsession (:NEW.hs_id);
    END IF;
END;
/
