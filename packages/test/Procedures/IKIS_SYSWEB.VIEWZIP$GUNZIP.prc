/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.ViewZip$GUNZIP (
    p_zip       IN VARCHAR2,
    p_outfile   IN VARCHAR2)
AS
    LANGUAGE JAVA
    NAME 'ViewZip.GUNZIP (java.lang.String,java.lang.String)' ;
/
