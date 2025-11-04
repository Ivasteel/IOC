/* Formatted on 8/12/2025 5:55:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_CP_ROUTINGS
    BEFORE INSERT
    ON uss_ndi.ndi_cp_routings
    FOR EACH ROW
BEGIN
    IF (:NEW.NCPR_ID = 0) OR (:NEW.NCPR_ID IS NULL)
    THEN
        :NEW.NCPR_ID := ID_ndi_cp_routings (:NEW.NCPR_ID);
    END IF;
END;
/
