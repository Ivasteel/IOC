/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.DEVS_TEST_MRES (p1     IN     VARCHAR,
                                                     p2     IN     NUMBER,
                                                     po1c      OUT VARCHAR,
                                                     po1n      OUT NUMBER)
AS
BEGIN
    po1c := p1;

    IF p2 = 1
    THEN
        raise_application_error (-20001,
                                 'Error in procedure DEVS_TEST_MRES',
                                 FALSE);
    END IF;

    po1n := 12345;
END DEVS_TEST_MRES;
/


GRANT EXECUTE ON IKIS_SYS.DEVS_TEST_MRES TO II01RC_IKIS_DESIGN
/
