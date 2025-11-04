/* Formatted on 8/12/2025 6:10:54 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_RBM.Get_Crypto_Params
    RETURN VARCHAR2
IS
    v_Result           VARCHAR2 (32000);
    v_Http_Proxy_Url   VARCHAR2 (4000);
    v_Proxy_Address    VARCHAR2 (4000);
    v_Proxy_Port       VARCHAR2 (4000);
    v_File_Storage     VARCHAR2 (4000);
    v_Agent_Port       VARCHAR2 (4000);
BEGIN
    v_Http_Proxy_Url := Ikis_Sys.Ikis_Common.Getapptparam ('IKS_RBM_PROXY');
    v_Proxy_Address :=
        Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_PROXY_ADDR');
    v_Proxy_Port :=
        Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_PROXY_PORT');
    v_File_Storage := Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CERT_STORAGE');
    v_Agent_Port :=
        Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_AGENT_PORT');

    v_Result :=
           '{"httpProxyUrl":"'
        || v_Http_Proxy_Url
        || '","proxyAddress": "'
        || v_Proxy_Address
        || '", "proxyPort": "'
        || v_Proxy_Port
        || '",'
        || '"fileStorage": "'
        || v_File_Storage
        || '", "agentPort": "'
        || v_Agent_Port
        || '"}';

    RETURN v_Result;
END Get_Crypto_Params;
/


GRANT EXECUTE ON IKIS_RBM.GET_CRYPTO_PARAMS TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.GET_CRYPTO_PARAMS TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.GET_CRYPTO_PARAMS TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_RBM.GET_CRYPTO_PARAMS TO PORTAL_PROXY
/
