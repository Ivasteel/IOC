/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.DEVS_TEST_CUR2 (
    pChar_param   IN     CHAR,
    pNum_param    IN     NUMBER,
    pDate_param   IN     DATE,
    rescur           OUT PKG_TYPE_FORRET.retcursor)
AS
BEGIN
    OPEN rescur FOR
        SELECT pChar_param AS a1, pNum_param AS a2, pDate_param AS a3
          FROM APPT_DUAL;
END DEVS_TEST_CUR2;
/


GRANT EXECUTE ON IKIS_SYS.DEVS_TEST_CUR2 TO II01RC_IKIS_DESIGN
/
