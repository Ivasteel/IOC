/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NORMATIVE_ACT
    BEFORE INSERT
    ON uss_ndi.ndi_normative_act
    FOR EACH ROW
BEGIN
    IF (:NEW.nna_id = 0) OR (:NEW.nna_id IS NULL)
    THEN
        :NEW.nna_id := ID_ndi_normative_act (:NEW.nna_id);
    END IF;
END;
/
