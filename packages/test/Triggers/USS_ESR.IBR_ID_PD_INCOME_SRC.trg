/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_INCOME_SRC
    BEFORE INSERT
    ON uss_esr.pd_income_src
    FOR EACH ROW
BEGIN
    IF (:NEW.pis_id = 0) OR (:NEW.pis_id IS NULL)
    THEN
        :NEW.pis_id := ID_pd_income_src (:NEW.pis_id);
    END IF;
END;
/
