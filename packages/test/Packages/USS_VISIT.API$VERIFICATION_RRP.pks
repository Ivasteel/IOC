/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_RRP
IS
    -- Author  : SERHII
    -- Created : 09.10.2024 12:36:46
    -- Purpose : Запити до Реєстру речових прав (Державний реєстр речових прав на нерухоме майно)
    /*
      -- Public type declarations
      TYPE < TypeName > IS < Datatype >;

      -- Public constant declarations
      < ConstantName > CONSTANT < Datatype > := < VALUE >;

      -- Public variable declarations
      < VariableName > < Datatype >;
    */
    -- NRT_MAKE_FUNC of NRT_ID = 000 for NDI_VERIFICATION_TYPE.NVT_ID = 000
    FUNCTION Reg_Get_Subj_Realty_Info (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;
END Api$Verification_RRP;
/


/* Formatted on 8/12/2025 5:59:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_RRP
IS
    /*
      -- Private type declarations
      TYPE < TypeName > IS < Datatype >;

      -- Private constant declarations
      < ConstantName > CONSTANT < Datatype > := < VALUE >;

      -- Private variable declarations
      < VariableName > < Datatype >;
    */

    -- NRT_MAKE_FUNC
    /*
        FUNCTION Reg_Get_Subj_Realty(p_Rn_Nrt      IN NUMBER,
                                  p_Obj_Id      IN NUMBER,
                                  p_Error       OUT VARCHAR2) RETURN NUMBER IS

       l_Rn_Id        NUMBER;
       l_Ap_Id        NUMBER;
       l_Ap_Reg_Dt    DATE;
       l_Ap_Tp        Appeal.Ap_Tp%TYPE;
       l_Apd_Ndt      Ap_Document.Apd_Ndt%TYPE;
       l_App_Inn      Ap_Person.App_Inn%TYPE;
       l_App_Fn       Ap_Person.App_Fn%TYPE;
       l_App_Mn       Ap_Person.App_Mn%TYPE;
       l_App_Ln       Ap_Person.App_Ln%TYPE;
       l_App_Sc       Ap_Person.App_Sc%TYPE;

     BEGIN

       l_App_Inn := '2599403115';



       Ikis_Rbm.Api$Request_RRP.Reg_Get_Subj_Realty(p_Rn_Nrt        => p_Rn_Nrt,
                                                    p_Sc_Id         => l_App_Sc,
                                                    p_Rnokpp        => l_App_Inn,
                                                    p_Last_Name     => l_App_Ln,
                                                    p_First_Name    => l_App_Fn,
                                                    p_Middle_Name   => l_App_Mn,
                                                    p_Rn_Id         => l_Rn_Id);

       l_Rn_Id := -1;
       RETURN(l_Rn_Id);
     END Reg_Get_Subj_Realty;
    */


    FUNCTION Reg_Get_Subj_Realty_Info (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        --l_Executor_Wu  NUMBER;
        l_Hs        NUMBER;
        l_Rn_Id     NUMBER;
        l_Ap_Id     NUMBER;
        --l_Ap_Reg_Dt    DATE;
        l_Ap_Tp     Appeal.Ap_Tp%TYPE;
        l_Apd_Ndt   Ap_Document.Apd_Ndt%TYPE;
        l_App_Inn   Ap_Person.App_Inn%TYPE;
        l_App_Fn    Ap_Person.App_Fn%TYPE;
        l_App_Mn    Ap_Person.App_Mn%TYPE;
        l_App_Ln    Ap_Person.App_Ln%TYPE;

        l_App_Sc    Ap_Person.App_Sc%TYPE;
        l_Ln        VARCHAR2 (100);
        l_Fn        VARCHAR2 (100);
        l_Mn        VARCHAR2 (100);

        l_Doc_Ser   VARCHAR2 (20);
        l_Doc_Num   VARCHAR2 (50);
    --l_UNZR         VARCHAR2(15);
    --l_No_IPN       VARCHAR2(1);
    BEGIN
        --l_Hs := Tools.GetHistSessionA;

        BEGIN
            SELECT p.App_Ap,
                   COALESCE (
                       Api$appeal.Get_Person_Inn_Doc (p_App_Id => p.App_Id),
                       p.App_Inn),
                   p.App_Fn,
                   p.App_Mn,
                   p.App_Ln,
                   p.App_Sc
              --, a.Com_Wu, a.Ap_Tp
              INTO l_Ap_Id,
                   l_App_Inn,
                   l_App_Fn,
                   l_App_Mn,
                   l_App_Ln,
                   l_App_Sc
              --, l_Executor_Wu, l_Ap_Tp
              FROM Ap_Person p JOIN Appeal a ON p.App_Ap = a.Ap_Id
             WHERE p.App_Id = p_Obj_Id;

            IF l_App_Inn IS NULL
            THEN
                SELECT Apd_Ndt,
                       Api$appeal.Get_Attr_Val_String (Apd_Id, 'DSN'),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'FN'),
                            l_App_Fn),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'MN'),
                            l_App_Mn),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'LN'),
                            l_App_Ln)
                  --, Api$appeal.Get_Attr_Val_Dt(Apd_Id, 'BDT')
                  INTO l_Apd_Ndt,
                       l_App_Inn,
                       l_App_Fn,
                       l_App_Mn,
                       l_App_Ln
                  --, l_App_Birth_Dt
                  FROM (SELECT d.Apd_Id, d.Apd_Ndt
                          FROM Ap_Document d
                         WHERE     d.Apd_App = p_Obj_Id
                               AND d.History_Status = 'A'
                               AND d.Apd_Ndt IN (6, 7)
                         FETCH FIRST ROW ONLY);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        -- USS_VISIT.Api$verification.Write_Vf_Log (...)

        Ikis_Rbm.Api$Request_RRP.Reg_Get_Subj_Realty_Info (
            p_Sc_Id         => l_App_Sc,
            p_Rnokpp        => l_App_Inn,
            p_Last_Name     => l_App_Ln,
            p_First_Name    => l_App_Fn,
            p_Middle_Name   => l_App_Mn,
            p_Doc_Ser       => l_Doc_Ser,
            p_Doc_Num       => l_Doc_Num,
            p_Rn_Nrt        => p_Rn_Nrt,
            p_Rn_Hs_Ins     => l_Hs,
            p_Rn_Src        => Api$appeal.c_Src_Vst,
            p_Rn_Id         => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'uss_visit.Api$Verification_RRP.Reg_Get_Subj_Realty: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END Reg_Get_Subj_Realty_Info;
/*
  -----------------------------------------------------------------
  --  Реєстрація запиту на верифікацію свідоцтва про народження
  -----------------------------------------------------------------
  FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req(p_Rn_Nrt      IN NUMBER,
                                                 p_Obj_Id      IN NUMBER,
                                                 p_Error       OUT VARCHAR2,
                                                 p_Cert_Number IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_Rn_Id            NUMBER;
    l_Sc_Id            NUMBER;
    l_Cert_Serial      VARCHAR2(10);
    l_Cert_Number      VARCHAR2(50);
    l_Child_Birth_Dt   DATE;
    l_Child_Pib        VARCHAR2(250);
    l_Child_Surname    VARCHAR2(250);
    l_Child_Name       VARCHAR2(250);
    l_Child_Patronymic VARCHAR2(250);
  BEGIN
    IF Api$verification.Skip_Vf_By_Src(p_Apd_Id => p_Obj_Id) THEN
      RETURN NULL;
    END IF;

    l_Cert_Number := Nvl(p_Cert_Number, Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'DSN'));
    IF l_Cert_Number IS NOT NULL THEN
      l_Cert_Serial := Substr(l_Cert_Number, 1, Length(l_Cert_Number) - 6);
      l_Cert_Number := Substr(l_Cert_Number, Length(l_Cert_Number) - 5, 6);
    END IF;
    l_Child_Birth_Dt := Api$appeal.Get_Attr_Val_Dt(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'BDT');
    l_Child_Pib := Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'PIB');
    Split_Pib(l_Child_Pib, l_Child_Surname, l_Child_Name, l_Child_Patronymic);

    IF l_Cert_Serial IS NULL
       OR l_Cert_Number IS NULL
       OR (l_Child_Birth_Dt IS NULL AND (l_Child_Name IS NULL OR l_Child_Surname IS NULL)) THEN
      p_Error := 'Не вказано';
      Tools.Add_Err(l_Cert_Serial IS NULL, 'серію документа', p_Error);
      Tools.Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
      Tools.Add_Err(l_Child_Birth_Dt IS NULL, 'дату народження дитини', p_Error);
      Tools.Add_Err(l_Child_Surname IS NULL, 'прізвище дитини', p_Error);
      Tools.Add_Err(l_Child_Name IS NULL, 'ім’я дитини', p_Error);
      Tools.Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
      p_Error := Rtrim(p_Error, ',') || '. Створення запиту неможливе';
      RETURN NULL;
    END IF;

    l_Sc_Id := Api$appeal.Get_Doc_Owner_Sc(p_Obj_Id);

    IF l_Child_Birth_Dt IS NOT NULL THEN
      Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Birth_Date_Req(p_Cert_Tp     => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                                                                       p_Cert_Role   => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                                                                       p_Cert_Serial => l_Cert_Serial,
                                                                       p_Cert_Number => l_Cert_Number,
                                                                       p_Date_Birth  => l_Child_Birth_Dt,
                                                                       p_Sc_Id       => l_Sc_Id,
                                                                       p_Rn_Nrt      => p_Rn_Nrt,
                                                                       p_Rn_Hs_Ins   => NULL,
                                                                       p_Rn_Src      => Api$appeal.c_Src_Vst,
                                                                       p_Rn_Id       => l_Rn_Id);
    ELSE
      Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Names_Req(p_Cert_Tp     => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                                                                  p_Cert_Role   => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                                                                  p_Cert_Serial => l_Cert_Serial,
                                                                  p_Cert_Number => l_Cert_Number,
                                                                  p_Surname     => l_Child_Surname,
                                                                  p_Name        => l_Child_Name,
                                                                  p_Patronymic  => l_Child_Patronymic,
                                                                  p_Sc_Id       => l_Sc_Id,
                                                                  p_Rn_Nrt      => 27, --todo: додати поле nvt_nrt_alt?
                                                                  p_Rn_Hs_Ins   => NULL,
                                                                  p_Rn_Src      => Api$appeal.c_Src_Vst,
                                                                  p_Rn_Id       => l_Rn_Id);
    END IF;
    RETURN l_Rn_Id;
  END;


*/
BEGIN
    -- Initialization
    NULL;
END Api$Verification_RRP;
/