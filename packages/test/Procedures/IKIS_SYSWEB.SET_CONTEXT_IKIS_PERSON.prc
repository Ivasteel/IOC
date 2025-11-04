/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.SET_CONTEXT_IKIS_PERSON
IS
/******************************************************************************
   NAME:       SET_CONTEXT_IKIS_PERSON
   PURPOSE: Устанавливает контекст для IKIS_PERSON
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        16.09.2016   vakulenko       1. Created this procedure.

******************************************************************************/
BEGIN
    ikis_sysweb.ikis_web_context.setcontext ('IKIS_PERSON');
END SET_CONTEXT_IKIS_PERSON;
/


GRANT EXECUTE ON IKIS_SYSWEB.SET_CONTEXT_IKIS_PERSON TO IKIS_PERSON
/
