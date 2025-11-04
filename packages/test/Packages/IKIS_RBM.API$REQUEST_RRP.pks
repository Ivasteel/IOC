/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_RRP
IS
    -- Author  : SERHII
    -- Created : 21.08.2024 16:51:58
    -- Purpose : Запити до Реєстру речових прав (Державний реєстр речових прав на нерухоме майно)

    -- Структура запита до РРП
    TYPE r_Subj_Search_Inf IS RECORD
    (
        dcSearchAlgorithm    VARCHAR2 (1),
        sbjType              VARCHAR2 (1),
        sbjName              VARCHAR2 (1000),
        sbjCode              VARCHAR2 (10),
        seriesNum            VARCHAR2 (50),
        idEddr               VARCHAR2 (15),
        codeAbsence          VARCHAR2 (1),
        dcSbjRlNames         VARCHAR2 (250)
    );

    /*
    dcSearchAlgorithm 1 String  Тип пошуку
    sbjType 1 String  Тип суб’єкта
    sbjName 0-1 String  Назва/ПІБ
    sbjCode 0-1 String  РНОКПП/ЄДРПОУ
    ?         якщо обрано тип особи = фізична особа, - {10}
    ?         якщо обрано тип особи = юридична особа, - {8, 9, 12}
    seriesNum 0-1 String  Серія, номер документа
    idEddr  0-1 String  УНЗР
    значення повинно відповідати YYYYYYYY-YYYYY, допустимі значення [0-9]та символ -
    codeAbsence 0-1 String  ознака «Код РНОКПП відсутній»
    dcSbjRlNames  0-n String  Роль суб’єкта
    */

    TYPE r_Search_Params IS RECORD
    (
        isShowHistoricalNames    BOOLEAN := FALSE,
        searchType               VARCHAR2 (1) := '2',
        subjectSearchInfo        r_Subj_Search_Inf
    );

    TYPE r_Rrp_Search_Req IS RECORD
    (
        entity          VARCHAR2 (50) := 'rrpExch_external',
        method          VARCHAR2 (50) := 'search',
        SIGN            VARCHAR2 (1000),
        searchParams    r_Search_Params
    );

    -- Public constant declarations
    --<ConstantName> constant <Datatype> := <Value>;

    -- Public variable declarations
    --<VariableName> <Datatype>;


    -- Реєстрація запиту про нерух. майно по суб'єкту
    PROCEDURE Reg_Get_Subj_Realty_Info (
        p_Sc_Id         IN     NUMBER,
        p_Rnokpp        IN     VARCHAR2,
        p_Last_Name     IN     VARCHAR2 DEFAULT NULL,
        p_First_Name    IN     VARCHAR2 DEFAULT NULL,
        p_Middle_Name   IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Ser       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Num       IN     VARCHAR2 DEFAULT NULL,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Subj_Realty_Info (p_Ur_Id IN NUMBER)
        RETURN CLOB;
END Api$Request_RRP;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_RRP TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_RRP TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_RRP TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_RRP TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_RRP
IS
    /*
      -- Private type declarations
      --type <TypeName> is <Datatype>;

      -- Private constant declarations


      -- Private variable declarations
      <VariableName> <Datatype>;


      FUNCTION Get_Subj_Info(p_Sc_Id IN NUMBER) RETURN r_Subj_Search_Inf IS
        l_res   r_Subj_Search_Inf;
      BEGIN
        SELECT sco_ln || sco_fn || sco_mn, sco_numident, sco_pasp_seria || sco_pasp_number
             , NULL, NULL, NULL
             , '1'
             , '2'
        INTO l_res.sbjName, l_res.sbjCode, l_res.seriesNum
             , l_res.idEddr, l_res.codeAbsence, l_res.dcSbjRlNames
             , l_res.sbjType -- Тип суб’єкта
             , l_res.dcSearchAlgorithm -- Тип пошуку за: «частковим співпадінням» (1) або «повним співпадінням» (2)
        FROM uss_person.v_Sc_Info
        WHERE sco_id = p_Sc_Id;

        RETURN(l_res);
      END Get_Subj_Info;
    */
    Package_Name   CONSTANT VARCHAR2 (50) := 'API$REQUEST_RRP';

    PROCEDURE Reg_Get_Subj_Realty_Info (
        p_Sc_Id         IN     NUMBER,
        p_Rnokpp        IN     VARCHAR2,
        p_Last_Name     IN     VARCHAR2 DEFAULT NULL,
        p_First_Name    IN     VARCHAR2 DEFAULT NULL,
        p_Middle_Name   IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Ser       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Num       IN     VARCHAR2 DEFAULT NULL,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Rnokpp,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
                                    p_Rnp_Doc_Number   => p_Doc_Num,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_First_Name,
                                            p_Rnpi_Ln    => p_Last_Name,
                                            p_Rnpi_Mn    => p_Middle_Name,
                                            p_New_Id     => l_Rnpi_Id);
    -- Api$request.Save_Rn_Common_Info(p_Rnc_Rn => p_Rn_Id, p_Rnc_Pt => c_Pt_Birth_Dt, p_Rnc_Val_Dt => p_Date_Birth);

    END Reg_Get_Subj_Realty_Info;

    FUNCTION Get_Subj_Realty_Info (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request   Uxp_Request%ROWTYPE;

        l_Ln            VARCHAR2 (100);
        l_Fn            VARCHAR2 (100);
        l_Mn            VARCHAR2 (100);
        l_Doc_Ser       VARCHAR2 (20);
        l_Doc_Num       VARCHAR2 (50);
        l_UNZR          VARCHAR2 (15);
        l_No_IPN        VARCHAR2 (1);

        l_Search_Par    r_Search_Params;
        l_Req_Payload   CLOB;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        l_Search_Par.isShowHistoricalNames := FALSE;
        l_Search_Par.searchType := '2';                      -- 2: по суб'єкту

        SELECT '1'                                            -- 1:Фіз., 2:Юр.
                  ,
               '2' -- Пошук за: «частковим співпадінням» (1) або «повним співпадінням» (2)
                  ,
               p.Rnp_Inn--, i.rnpi_ln || ' ' || i.rnpi_fn || ' ' || i.rnpi_mn
                        --, p.rnp_doc_seria || p.rnp_doc_number
                        ,
               '"11","25"' -- Роль субєкта (sbjRlName) - власник, довірчий власник
          INTO l_Search_Par.subjectSearchInfo.sbjType,
               l_Search_Par.subjectSearchInfo.dcSearchAlgorithm,
               l_Search_Par.subjectSearchInfo.sbjCode--, l_Search_Par.subjectSearchInfo.sbjName
                                                     --, l_Search_Par.subjectSearchInfo.seriesNum
                                                     ,
               l_Search_Par.subjectSearchInfo.dcSbjRlNames
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Uxp_Request.Ur_Rn;

        EXECUTE IMMEDIATE Type2json (Package_Name,
                                     'R_SEARCH_PARAMS',
                                     'yyyy-mm-dd')
            USING IN l_Search_Par, OUT l_Req_Payload;

        RETURN l_Req_Payload;
    END Get_Subj_Realty_Info;
/*
NRT_QUERY_FUNC
  ----------------------------------------------------------------------
  --     Отримання даних для запиту на отримання свідоцтва
  -- за номером та датою народження
  ----------------------------------------------------------------------
  FUNCTION Get_Get_Cert_By_Num_Role_Birth_Date_Data(p_Ur_Id IN NUMBER) RETURN CLOB IS
    l_Ur_Rn           NUMBER;
    l_Date_Birth      DATE;
    l_Request_Payload Xmltype;
    l_Cert_Tp         NUMBER;
    l_Cert_Role       NUMBER;
    l_Cert_Serial     VARCHAR2(10);
    l_Cert_Number     VARCHAR2(50);
  BEGIN
    l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn(p_Ur_Id);
    l_Date_Birth := Api$request.Get_Rn_Common_Info_Dt(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Birth_Dt);
    l_Cert_Tp := Api$request.Get_Rn_Common_Info_String(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Cert_Tp);
    l_Cert_Role := Api$request.Get_Rn_Common_Info_String(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Cert_Role);
    l_Cert_Serial := Api$request.Get_Rn_Common_Info_String(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Cert_Serial);
    l_Cert_Number := Api$request.Get_Rn_Common_Info_String(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Cert_Number);

    SELECT Xmlelement("CeServiceRequest",
                       Xmlelement("ByParam", l_Cert_Tp),
                       Xmlelement("Role", l_Cert_Role),
                       Xmlelement("DateBirth", To_Char(l_Date_Birth, 'yyyy-mm-dd')),
                       Xmlelement("CertSerial", l_Cert_Serial),
                       Xmlelement("CertNumber", l_Cert_Number))
      INTO l_Request_Payload
      FROM Dual;

    RETURN l_Request_Payload.Getclobval;
  END;
*/

BEGIN
    -- Initialization
    NULL;
END Api$Request_RRP;
/