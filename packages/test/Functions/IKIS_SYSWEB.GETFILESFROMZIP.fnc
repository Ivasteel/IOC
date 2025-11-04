/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.GetFilesFromZip (p_dir   IN VARCHAR2,
                                                        p_zip   IN VARCHAR2)
    RETURN VARCHAR2
AS
    LANGUAGE JAVA
    NAME 'zip_util.GetFilesFromZip (java.lang.String,java.lang.String) return java.lang.String' ;
--!!!
/
