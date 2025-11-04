/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_DPSU
IS
    -- Author  : KELATEV
    -- Created : 20.02.2025 16:44:52
    -- Purpose : Запити до ДПСУ

    Package_Name               CONSTANT VARCHAR2 (50) := 'API$REQUEST_DPSU';

    c_Urt_Find_Last_Crossing   CONSTANT NUMBER := 144;
    c_Pt_Birth_Dt              CONSTANT NUMBER := 87;
    c_Pt_Reason                CONSTANT NUMBER := 242;

    TYPE r_Last_Crossing IS RECORD
    (
        Id           NUMBER,
        Datecross    DATE,
        Fioukr       VARCHAR2 (1000),
        Fiolat       VARCHAR2 (1000),
        Fiorus       VARCHAR2 (1000),
        Dateborn     DATE,
        Sex          VARCHAR2 (10),
        Docnameid    NUMBER,            --Ndi_Decoding_Config(NDT_ID,DPSU,USS)
        Stateid      NUMBER,             --Ndi_Decoding_Config(NC_ID,DPSU,USS)
        Naprid       VARCHAR2 (10),                                      --I/O
        Paspnom      VARCHAR2 (100),
        Codeusel     NUMBER,                               --V_DDN_CROSS_POINT
        Transport    VARCHAR2 (100)
    );

    PROCEDURE Reg_Find_Last_Crossing_Request (p_Sc_Id        IN     NUMBER,
                                              p_Fn           IN     VARCHAR2,
                                              p_Ln           IN     VARCHAR2,
                                              p_Mn           IN     VARCHAR2,
                                              p_Date_Birth   IN     DATE,
                                              p_Wu_Id        IN     NUMBER,
                                              p_Src          IN     VARCHAR2,
                                              p_Rn_Id           OUT NUMBER);

    FUNCTION Build_Find_Last_Crossing_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Find_Last_Crossing_Resp (p_Response IN CLOB)
        RETURN r_Last_Crossing;
END Api$request_Dpsu;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DPSU TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DPSU TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DPSU TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DPSU TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DPSU TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_DPSU
IS
    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Передавання від ДПСУ даних про перетин державного кордону особами (інформація про перетин за останні 90 (дев’яносто) днів) за реквізитами
    -- #111336
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Find_Last_Crossing_Request (p_Sc_Id        IN     NUMBER,
                                              p_Fn           IN     VARCHAR2,
                                              p_Ln           IN     VARCHAR2,
                                              p_Mn           IN     VARCHAR2,
                                              p_Date_Birth   IN     DATE,
                                              p_Wu_Id        IN     NUMBER,
                                              p_Src          IN     VARCHAR2,
                                              p_Rn_Id           OUT NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Find_Last_Crossing,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => p_Sc_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Fn,
                                            p_Rnpi_Ln    => p_Ln,
                                            p_Rnpi_Mn    => p_Mn,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Date_Birth);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Передавання від ДПСУ даних про перетин державного кордону особами (інформація про перетин за останні 90 (дев’яносто) днів) за реквізитами
    -- #111336
    ---------------------------------------------------------------------------
    FUNCTION Build_Find_Last_Crossing_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request       Uxp_Request%ROWTYPE;
        l_Birth_Dt          DATE;
        l_Request_Payload   CLOB;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT Json_Object (
                   'fioukr' VALUE
                       TRIM (
                           i.Rnpi_Ln || ' ' || i.Rnpi_Fn || ' ' || i.Rnpi_Mn),
                   'dateborn' VALUE TO_CHAR (l_Birth_Dt, 'dd.mm.yyyy'),
                   'reason' VALUE '1',
                   'paspnom' VALUE p.Rnp_Doc_Seria || p.Rnp_Doc_Number)    Request_Data
          INTO l_Request_Payload
          FROM Ikis_Rbm.Uxp_Request  r
               LEFT JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               LEFT JOIN Ikis_Rbm.Rnp_Identity_Info i
                   ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Request_Payload;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- Передавання від ДПСУ даних про перетин державного кордону особами (інформація про перетин за останні 90 (дев’яносто) днів) за реквізитами
    -- #111336
    --------------------------------------------------------------------
    FUNCTION Parse_Find_Last_Crossing_Resp (p_Response IN CLOB)
        RETURN r_Last_Crossing
    IS
        l_Resp   r_Last_Crossing;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              'R_LAST_CROSSING',
                                              'dd.mm.yyyy hh24:mi:ss')
                USING IN p_Response, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;
END Api$request_Dpsu;
/