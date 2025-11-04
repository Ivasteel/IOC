/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.Set_Context_Ikis_Exchea
IS
BEGIN
    Ikis_Web_Context.Setcontext (p_App_Name => 'IKIS_EXCHEA');
END Set_Context_Ikis_Exchea;
/
