/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.spUpdateDemoDTP (
    p_adt_id           IN appt_demo_dtp.adt_id%TYPE,
    p_adt_varlenstr    IN appt_demo_dtp.adt_varlenstr%TYPE,
    p_adt_fixstr       IN appt_demo_dtp.adt_fixstr%TYPE,
    p_adt_char         IN appt_demo_dtp.adt_char%TYPE,
    p_adt_date         IN appt_demo_dtp.adt_date%TYPE,
    p_adt_decimal      IN appt_demo_dtp.adt_decimal%TYPE,
    p_adt_decimal_dr   IN appt_demo_dtp.adt_decimal_dr%TYPE,
    p_adt_bigstr       IN appt_demo_dtp.adt_bigstr%TYPE,
    p_adt_bigstr1      IN appt_demo_dtp.adt_bigstr1%TYPE)
    RETURN VARCHAR
IS
BEGIN
    IF p_adt_decimal_dr IS NOT NULL
    THEN
        IF p_adt_decimal_dr = 1
        THEN
            raise_application_error (
                -20000,
                'Error in sp on update adt_decimal_dr must be null');
        ELSE
            RETURN 'Error in sp on update adt_decimal_dr must be null';
        END IF;
    END IF;

    UPDATE appt_demo_dtp
       SET adt_varlenstr = p_adt_varlenstr,
           adt_fixstr = p_adt_fixstr,
           adt_char = p_adt_char,
           adt_date = p_adt_date,
           adt_decimal = p_adt_decimal,
           adt_bigstr = p_adt_bigstr,
           adt_bigstr1 = p_adt_bigstr1
     WHERE adt_id = p_adt_id;

    RETURN '';
END spUpdateDemoDTP;
/
