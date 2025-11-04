/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.PTEST_RPT (
    pTask_class   IN     CHAR DEFAULT 'B',
    rescur        IN OUT PKG_TYPE_FORRET.retcursor)
AS
BEGIN
    OPEN rescur FOR SELECT *
                      FROM APPT_TASK
                     WHERE dts_class = pTask_class;
END PTEST_RPT;
/


GRANT EXECUTE ON IKIS_SYS.PTEST_RPT TO II01RC_IKIS_DESIGN
/
