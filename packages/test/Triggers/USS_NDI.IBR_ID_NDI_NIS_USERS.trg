/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NIS_USERS
    BEFORE INSERT
    ON uss_ndi.ndi_nis_users
    FOR EACH ROW
BEGIN
    IF (:NEW.nisu_id = 0) OR (:NEW.nisu_id IS NULL)
    THEN
        :NEW.nisu_id := ID_ndi_nis_users (:NEW.nisu_id);
    END IF;
END;
/
