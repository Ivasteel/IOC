/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MVS
IS
    -- Author  : USER
    -- Created : 14.12.2023 12:52:28
    -- Purpose : Запити до міністерства внутрішніх справ

    Package_Name                 CONSTANT VARCHAR2 (50) := 'API$REQUEST_MVS';

    c_Result_Answer_Gived        CONSTANT NUMBER := 1;
    c_Result_Person_Not_Found    CONSTANT NUMBER := 2;
    c_Result_Data_Not_Matched    CONSTANT NUMBER := 3;
    c_Result_Fields_Not_Filled   CONSTANT NUMBER := 4;
    c_Result_Other_Error         CONSTANT NUMBER := 9;


    c_Pt_Birth_Dt                CONSTANT NUMBER := 87;
    c_Pt_Gender                  CONSTANT NUMBER := 220;
    c_Req_Guid                   CONSTANT NUMBER := 463;

    TYPE r_Mvs_Response IS RECORD
    (
        Result_Code       NUMBER,
        Result_Content    VARCHAR2 (500),
        Error             NUMBER,
        Error_Message     VARCHAR2 (2000),
        Status            VARCHAR2 (100),
        Unzr              VARCHAR2 (100)
    );


    PROCEDURE Reg_Create_Pass_Req (
        p_Sc_Id       IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Ln          IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Mn          IN     VARCHAR2,
        p_Doc_Tp      IN     NUMBER,
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2,
        p_Gender      IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2);

    FUNCTION Build_Create_Pass_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Create_Pass_Resp (p_Response IN CLOB)
        RETURN r_Mvs_Response;
END Api$request_Mvs;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVS TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MVS
IS
    --------------------------------------------------------------------
    --  Реєстрація запиту на передачу паспортних даних
    --------------------------------------------------------------------
    PROCEDURE Reg_Create_Pass_Req (
        p_Sc_Id       IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Ln          IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Mn          IN     VARCHAR2,
        p_Doc_Tp      IN     NUMBER,
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2,
        p_Gender      IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2)
    IS
        l_Ur_Id      NUMBER;
        l_Rnp_Id     NUMBER;
        l_Rnpi_Id    NUMBER;
        l_Req_Guid   VARCHAR2 (50)
            := REGEXP_REPLACE (SYS_GUID (),
                               '(.{8})(.{4})(.{4})(.{4})(.{12})',
                               '\1-\2-\3-\4-\5');
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Sc_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => p_Doc_Tp,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
                                    p_Rnp_Doc_Number   => p_Doc_Num,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Fn,
                                            p_Rnpi_Ln    => p_Ln,
                                            p_Rnpi_Mn    => p_Mn,
                                            p_New_Id     => l_Rnpi_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Birthday);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Gender,
                                         p_Rnc_Val_String   => p_Gender);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Req_Guid,
                                         p_Rnc_Val_String   => l_Req_Guid);
    END;

    --------------------------------------------------------------------
    --  Формування даних для запиту на передачу паспортних даних
    --------------------------------------------------------------------
    FUNCTION Build_Create_Pass_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Req   CLOB;
    BEGIN
        SELECT    'idRequest='
               || p_Ur_Id
               || '&dateRequest='
               || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
               ||                                                           --
                  '&last='
               || i.Rnpi_Ln
               ||                                                           --
                  '&first='
               || i.Rnpi_Fn
               ||                                                           --
                  CASE
                      WHEN TRIM (Rnpi_Mn) IS NOT NULL
                      THEN
                          '&middle=' || i.Rnpi_Mn
                  END
               ||                                                           --
                  CASE
                      WHEN TRIM (p.Rnp_Inn) IS NOT NULL
                      THEN
                          '&rnokpp_num=' || p.Rnp_Inn
                  END
               ||                                                           --
                  '&type_doc='
               || Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'NDT_ID',
                                             p_Nddc_Src        => 'USS',
                                             p_Nddc_Dest       => 'MVS',
                                             p_Nddc_Code_Src   => p.Rnp_Ndt /*AS Ndt_Id*/
                                                                           )
               ||                                                           --
                  CASE
                      WHEN TRIM (p.Rnp_Doc_Seria) IS NOT NULL
                      THEN
                          '&ser=' || p.Rnp_Doc_Seria
                  END
               ||                                                           --
                  '&num='
               || p.Rnp_Doc_Number
               ||                                                           --
                  '&birth_date='
               || TO_CHAR (
                      Api$request.Get_Rn_Common_Info_Dt (
                          p_Rnc_Rn   => p.Rnp_Rn,
                          p_Rnc_Pt   => Api$request_Mvs.c_Pt_Birth_Dt),
                      'YYYY-MM-DD')
               ||                                                           --
                  '&gender='
               || NVL (
                      Uss_Ndi.Tools.Decode_Dict (
                          p_Nddc_Tp     => 'GENDER',
                          p_Nddc_Src    => 'USS',
                          p_Nddc_Dest   => 'MVS',
                          p_Nddc_Code_Src   =>
                              Api$request.Get_Rn_Common_Info_String (
                                  p_Rnc_Rn   => p.Rnp_Rn,
                                  p_Rnc_Pt   => Api$request_Mvs.c_Pt_Gender)),
                      0                                         /*не вказано*/
                       )    Request_Data
          INTO l_Req
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req;
    END;

    --------------------------------------------------------------------
    --  Парсинг відповіді на запит на передачу паспортних даних
    --------------------------------------------------------------------
    FUNCTION Parse_Create_Pass_Resp (p_Response IN CLOB)
        RETURN r_Mvs_Response
    IS
        l_Resp   r_Mvs_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            SELECT Result_Code,
                   Result_Content,
                   Error,
                   Error_Message,
                   Status,
                   Unzr
              INTO l_Resp.Result_Code,
                   l_Resp.Result_Content,
                   l_Resp.Error,
                   l_Resp.Error_Message,
                   l_Resp.Status,
                   l_Resp.Unzr
              FROM JSON_TABLE (
                       p_Response,
                       '$'
                       COLUMNS (
                           Result_Code NUMBER PATH '$.result',
                           Result_Content
                               VARCHAR2 (500)
                               PATH '$.result_content',
                           Error NUMBER PATH '$.error',
                           Error_Message
                               VARCHAR2 (2000)
                               PATH '$.error_message',
                           Status VARCHAR2 (100) PATH '$.status',
                           Unzr VARCHAR2 (100) PATH '$.unzr')) t;
        END IF;

        RETURN l_Resp;
    END;
END Api$request_Mvs;
/