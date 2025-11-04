/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.execcmd (p_command IN VARCHAR2)
    RETURN NUMBER
AS
    LANGUAGE JAVA
    NAME 'exec_os_command.execcmd(java.lang.String)return int' ;         --!!!
/
