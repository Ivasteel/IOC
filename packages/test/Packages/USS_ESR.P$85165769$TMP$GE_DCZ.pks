/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.P$85165769$TMP$GE_DCZ
IS
    -- Author  : KELATEV
    -- Created : 02.02.2024 11:27:20
    -- Purpose : Верифікація в ДЦЗ #97845

    Pkg   VARCHAR2 (100) := 'API$MASS_EXCHANGE_DCZ';

    --METHODS
    FUNCTION Short_Str (p_Str                    IN VARCHAR2,
                        p_Length                 IN NUMBER,
                        p_Truncation_Indicator   IN VARCHAR2 := '...')
        RETURN VARCHAR2;

    PROCEDURE Prepare_Me_Rows (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Make_Me_Packet (p_Me_Tp          Mass_Exchanges.Me_Tp%TYPE,
                              p_Me_Month       Mass_Exchanges.Me_Month%TYPE,
                              p_Me_Id      OUT Mass_Exchanges.Me_Id%TYPE,
                              p_Me_Jb      OUT Mass_Exchanges.Me_Jb%TYPE);

    PROCEDURE Make_Exchange_File (p_Me_Id       Mass_Exchanges.Me_Id%TYPE,
                                  p_Jb_Id   OUT Exchangefiles.Ef_Kv_Pkt%TYPE);

    PROCEDURE Create_File_Request_Job (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Parse_File_Response (p_Pkt_Id Ikis_Rbm.v_Packet.Pkt_Id%TYPE);
END P$85165769$TMP$GE_DCZ;
/
