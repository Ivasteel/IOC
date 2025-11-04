/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_ACTIVITIES
    BEFORE INSERT
    ON uss_ndi.ndi_nst_activities
    FOR EACH ROW
BEGIN
    IF (:NEW.nsa_id = 0) OR (:NEW.nsa_id IS NULL)
    THEN
        :NEW.nsa_id := ID_ndi_nst_activities (:NEW.nsa_id);
    END IF;
END;
/
