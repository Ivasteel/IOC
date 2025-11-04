/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NB_CONTRACT
    BEFORE INSERT
    ON uss_ndi.ndi_nb_contract
    FOR EACH ROW
BEGIN
    IF (:NEW.nbc_id = 0) OR (:NEW.nbc_id IS NULL)
    THEN
        :NEW.nbc_id := ID_ndi_nb_contract (:NEW.nbc_id);
    END IF;
END;
/
