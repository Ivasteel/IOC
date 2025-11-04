/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NBT_NPPT_SETUP
    BEFORE INSERT
    ON uss_ndi.ndi_nbt_nppt_setup
    FOR EACH ROW
BEGIN
    IF (:NEW.nbpt_id = 0) OR (:NEW.nbpt_id IS NULL)
    THEN
        :NEW.nbpt_id := ID_ndi_nbt_nppt_setup (:NEW.nbpt_id);
    END IF;
END;
/
