/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_FUNCTIONARY
    BEFORE INSERT
    ON uss_ndi.ndi_functionary
    FOR EACH ROW
BEGIN
    IF (:NEW.fnc_id = 0) OR (:NEW.fnc_id IS NULL)
    THEN
        :NEW.fnc_id := ID_ndi_functionary (:NEW.fnc_id);
    END IF;
END;
/
