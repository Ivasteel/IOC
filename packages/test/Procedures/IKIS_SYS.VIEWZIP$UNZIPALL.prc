/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.ViewZip$UNZIPALL (
    p_zip      IN VARCHAR2,
    p_outdir   IN VARCHAR2)
AS
    LANGUAGE JAVA
    NAME 'ViewZip.UNZIPALL (java.lang.String,java.lang.String)' ;
--!!!
/
