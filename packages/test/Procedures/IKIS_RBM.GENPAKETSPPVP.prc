/* Formatted on 8/12/2025 6:10:53 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_RBM.GenPaketsPpvp (p_serv_code IN VARCHAR2)
AS
BEGIN
    -- Call the procedure
    rdm$app_exchange.genpaketsppvp (p_serv_code => p_serv_code);
END;
/
