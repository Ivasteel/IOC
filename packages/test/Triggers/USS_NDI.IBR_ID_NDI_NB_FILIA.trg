/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NB_FILIA
    BEFORE INSERT
    ON uss_ndi.ndi_nb_filia
    FOR EACH ROW
BEGIN
    IF (:NEW.nbf_id = 0) OR (:NEW.nbf_id IS NULL)
    THEN
        :NEW.nbf_id := ID_ndi_nb_filia (:NEW.nbf_id);
    END IF;
END;
/
