/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IU_PD_ACCRUAL_PERIOD_SET1
    BEFORE INSERT OR UPDATE
    ON uss_esr.pd_accrual_period
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF :new.pdap_pd IS NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба заповнити пустим значенням посилання на рішення (pdap_pd) строку дії рішення. Надішліть розробнику скріншот з додатковою інформацією!');
    END IF;

    IF :new.pdap_start_dt IS NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба заповнити пустим значенням дату початку (pdap_start_dt) строку дії рішення. Надішліть розробнику скріншот з додатковою інформацією!');
    END IF;

    IF :new.pdap_stop_dt IS NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба заповнити пустим значенням дату закінчення (pdap_stop_dt) строку дії рішення. Надішліть розробнику скріншот з додатковою інформацією!');
    END IF;

    IF :new.history_status IS NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба заповнити пустим значенням стан історичності (history_status) строку дії рішення. Надішліть розробнику скріншот з додатковою інформацією!');
    END IF;
END IU_pd_payment_history_status;
/
