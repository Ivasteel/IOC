/* Formatted on 8/12/2025 6:11:36 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.ZipFilesOnDir (p_dir   IN VARCHAR2,
                                                      p_zip   IN VARCHAR2)
    RETURN VARCHAR2
AS
    LANGUAGE JAVA
    NAME 'zip_util.ZipFilesOnDir (java.lang.String,java.lang.String) return java.lang.String' ;
--!!!
/
