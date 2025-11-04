/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.get_dir_list (
    p_directory   IN VARCHAR2)
AS
    LANGUAGE JAVA
    NAME 'DirList.getList(java.lang.String)' ;
/
