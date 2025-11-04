/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.Get_Ca_Data (p_Ca_Id NUMBER)
    RETURN VARCHAR2
IS
    --Получение JSON объекта с настройками АЦСК
    v_Ca   w_Cert_Authority%ROWTYPE;
BEGIN
    SELECT *
      INTO v_Ca
      FROM w_Cert_Authority a
     WHERE a.Wca_Id = p_Ca_Id;

    RETURN    '{"ocspAddress": "'
           || v_Ca.Wca_Ocsp_Address
           || '", "ocspPort": "'
           || v_Ca.Wca_Ocsp_Port
           || '", "ocspPointAddress": "'
           || v_Ca.Wca_Ocsp_Point_Address
           || '", "ocspPointPort": "'
           || v_Ca.Wca_Ocsp_Point_Port
           || '", "tspAddress": "'
           || v_Ca.Wca_Tsp_Address
           || '", "tspPort": "'
           || v_Ca.Wca_Tsp_Port
           || '", "cmpAddress": "'
           || v_Ca.Wca_Cmp_Address
           || '", "cmpPort": "'
           || v_Ca.Wca_Cmp_Port
           || '"}';
END Get_Ca_Data;
/
