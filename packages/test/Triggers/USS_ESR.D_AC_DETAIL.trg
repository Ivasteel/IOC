/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.D_AC_DETAIL
    BEFORE DELETE
    ON uss_esr.AC_DETAIL
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF :old.acd_prsd IS NOT NULL OR :old.acd_prsd_sa IS NOT NULL
    THEN
        raise_application_error (
            '-20000',
            'Спроба видалити рядок нарахувань, який включено у відомості!');
    --!!! Этого категорически нельзя делать. Строка ушла на выплату в ОЩАД.
    END IF;
END D_AC_DETAIL;
/
