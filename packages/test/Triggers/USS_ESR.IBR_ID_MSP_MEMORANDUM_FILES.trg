/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_MSP_MEMORANDUM_FILES
    BEFORE INSERT
    ON uss_esr.msp_memorandum_files
    FOR EACH ROW
BEGIN
    IF (:NEW.mm_id = 0) OR (:NEW.mm_id IS NULL)
    THEN
        :NEW.mm_id := ID_msp_memorandum_files (:NEW.mm_id);
    END IF;
END;
/
