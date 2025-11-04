/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_INCOME_CALC
    BEFORE INSERT
    ON uss_esr.pd_income_calc
    FOR EACH ROW
BEGIN
    IF (:NEW.pic_id = 0) OR (:NEW.pic_id IS NULL)
    THEN
        :NEW.pic_id := ID_pd_income_calc (:NEW.pic_id);
    END IF;
END;
/
