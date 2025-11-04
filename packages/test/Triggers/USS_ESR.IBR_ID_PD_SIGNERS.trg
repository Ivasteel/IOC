/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_SIGNERS
    BEFORE INSERT
    ON uss_esr.pd_signers
    FOR EACH ROW
BEGIN
    IF (:NEW.pdi_id = 0) OR (:NEW.pdi_id IS NULL)
    THEN
        :NEW.pdi_id := ID_pd_signers (:NEW.pdi_id);
    END IF;
END;
/
