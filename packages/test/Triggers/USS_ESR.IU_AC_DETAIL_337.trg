/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IU_AC_DETAIL_337
    BEFORE INSERT OR UPDATE
    ON uss_esr.AC_DETAIL
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF :new.acd_npt = 337
    THEN
        raise_application_error (
            '-20000',
            '—проба використати 1006 (id=337)  код виплати! ƒаний код повинен бути перекодований в коди виплат, прив`€заний до конкретних послуг!');
    --!!! без перекодировки - невозможно простым алгоритмом идентифицировать суммы (прив€зка к услугам/типам ведомостей)!!!
    END IF;
END IU_AC_DETAIL_337;
/
