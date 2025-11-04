/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NSSS2DSZN
    BEFORE INSERT
    ON uss_ndi.ndi_nsss2dszn
    FOR EACH ROW
BEGIN
    IF (:NEW.n2d_id = 0) OR (:NEW.n2d_id IS NULL)
    THEN
        :NEW.n2d_id := ID_ndi_nsss2dszn (:NEW.n2d_id);
    END IF;
END;
/
