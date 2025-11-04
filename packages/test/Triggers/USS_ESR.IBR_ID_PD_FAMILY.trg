/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_FAMILY
    BEFORE INSERT
    ON uss_esr.pd_family
    FOR EACH ROW
BEGIN
    IF (:NEW.pdf_id = 0) OR (:NEW.pdf_id IS NULL)
    THEN
        :NEW.pdf_id := ID_pd_family (:NEW.pdf_id);
    END IF;
END;
/
