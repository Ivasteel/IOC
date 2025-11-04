/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IU_DEDUCTION_DN_DPP
    BEFORE INSERT
    ON uss_esr.deduction
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF :new.dn_dpp IS NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба заповнити пустим значенням отримувача відрахування (dn_dpp). Надішліть розробнику скріншот з додатковою інформацією!');
    END IF;
--  IF :new.pdp_stop_dt IS NULL THEN
--    raise_application_error('-20000', 'Спроба заповнити пустим значенням закінчення строку дії (pdp_stop_dt) призначення. Надішліть розробнику скріншот з додатковою інформацією!');
--  END IF;
END IU_pd_payment_history_status;
/
