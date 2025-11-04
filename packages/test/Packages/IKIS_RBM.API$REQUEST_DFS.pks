/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_DFS
IS
    -- Author  : SHOSTAK
    -- Created : 17.07.2021 12:09:50
    -- Purpose : Запити до ДФС(реєстрація + зчитування даних запиту)

    Package_Name                       VARCHAR2 (100) := 'API$REQUEST_DFS';

    c_Pt_Request_Basis        CONSTANT NUMBER := 171;
    c_Pt_Birth_Dt             CONSTANT NUMBER := 87;

    c_Pt_Period_Begin         CONSTANT NUMBER := 167;
    c_Pt_Period_End           CONSTANT NUMBER := 168;

    c_Pt_Application_Number   CONSTANT NUMBER := 172;
    c_Pt_Application_Date     CONSTANT NUMBER := 173;

    c_Pt_Dfs_Rnokpp_Ndt_Id    CONSTANT NUMBER := 6;

    c_Err_Internal            CONSTANT VARCHAR2 (10) := '1000';
    c_Err_Bad_Req             CONSTANT VARCHAR2 (10) := '1004';
    c_Err_Not_Found           CONSTANT VARCHAR2 (10) := '1001';
    c_Err_In_Process          CONSTANT VARCHAR2 (10) := '1002';
    c_Err_Answer_Gived        CONSTANT VARCHAR2 (10) := '1003';

    --#97366 22.01.2024
    c_Dfs_Default_User_Id     CONSTANT NUMBER := 97478714;
    c_Vs_Test1_User_Id        CONSTANT NUMBER := 97478894;

    FUNCTION Getdpscomwu
        RETURN NUMBER;

    PROCEDURE Reg_Income_Sources_Query_Req (
        p_Basis_Request   IN     VARCHAR2,
        p_Executor_Wu     IN     NUMBER,
        p_Sc_Id           IN     NUMBER,
        p_Rnokpp          IN     VARCHAR2,
        p_Last_Name       IN     VARCHAR2,
        p_First_Name      IN     VARCHAR2,
        p_Middle_Name     IN     VARCHAR2,
        p_Date_Birth      IN     DATE,
        p_Period_Begin    IN     DATE,
        p_Period_End      IN     DATE,
        p_Rn_Nrt          IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins       IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src          IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id              OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Income_Sources_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Handle_Income_Sources_Query_Resp (
        p_Ur_Id            IN     NUMBER,
        p_Response         IN     CLOB,
        p_Error            IN OUT VARCHAR2,
        p_Repeat              OUT VARCHAR2,
        p_Subreq_Created      OUT VARCHAR2,
        p_Subreq_Nrt       IN     NUMBER,
        p_Rn_Src           IN     VARCHAR2);

    PROCEDURE Reg_Income_Sources_Answer_Req (
        p_Application_Number   IN     VARCHAR2,
        p_Application_Date     IN     VARCHAR2,
        p_Url_Parent           IN     Uxp_Req_Links.Url_Parent%TYPE,
        p_Rn_Nrt               IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src               IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                   OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Income_Sources_Answer_Data (
        p_Ur_Id   IN Uxp_Request.Ur_Id%TYPE)
        RETURN CLOB;


    PROCEDURE Reg_Create_Dfs_Rnokpp_Req (
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
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2,
        p_Wu          IN     NUMBER);

    FUNCTION Get_Dfs_Rnokpp_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Me_Income_Sources_Query_Req (
        p_Me_Id        IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Ur_Plan_Dt   IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Me_Income_Sources_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;
END Api$request_Dfs;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DFS TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_DFS
IS
    FUNCTION Get_Prm_Value (p_Param IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Param_Rbm.Prm_Value%TYPE;
    BEGIN
        SELECT p.Prm_Value
          INTO l_Result
          FROM Param_Rbm p
         WHERE p.Prm_Code = p_Param;

        RETURN l_Result;
    END;

    ------------------------------------------------------------------------------
    --      Отримання реквізитів виконавця запиту
    ------------------------------------------------------------------------------
    PROCEDURE Get_Executor_Info (p_Executor_Wu         IN     NUMBER,
                                 p_Executor_Rnokpp        OUT VARCHAR2,
                                 p_Executor_Fullname      OUT VARCHAR2,
                                 p_Executor_Org           OUT NUMBER)
    IS
        l_Username   VARCHAR2 (50);
        l_Wut        NUMBER;
        l_Org_Org    NUMBER;
        l_Trc        NUMBER;
    BEGIN
        Ikis_Sysweb.Get_User_Attr (p_Wu_Id      => p_Executor_Wu,
                                   p_Username   => l_Username,
                                   p_Pib        => p_Executor_Fullname,
                                   p_Wut        => l_Wut,
                                   p_Org        => p_Executor_Org,
                                   p_Org_Org    => l_Org_Org,
                                   p_Trc        => l_Trc,
                                   p_Numid      => p_Executor_Rnokpp);

        --ІД картка БК
        IF p_Executor_Rnokpp LIKE 'П%'
        THEN
            p_Executor_Rnokpp := SUBSTR (p_Executor_Rnokpp, 2, 9);
        --Паспорт БК
        ELSIF p_Executor_Rnokpp LIKE 'БК%'
        THEN
            p_Executor_Rnokpp := SUBSTR (p_Executor_Rnokpp, 3, 8);
        END IF;
    END;

    ------------------------------------------------------------------------------
    --      Реєєстрація запиту до ДФС для отримання інформації про доходи особи
    --                 (ініціалізація розрахунку)
    ------------------------------------------------------------------------------
    PROCEDURE Reg_Income_Sources_Query_Req (
        p_Basis_Request   IN     VARCHAR2,
        p_Executor_Wu     IN     NUMBER,
        p_Sc_Id           IN     NUMBER,
        p_Rnokpp          IN     VARCHAR2,
        p_Last_Name       IN     VARCHAR2,
        p_First_Name      IN     VARCHAR2,
        p_Middle_Name     IN     VARCHAR2,
        p_Date_Birth      IN     DATE,
        p_Period_Begin    IN     DATE,
        p_Period_End      IN     DATE,
        p_Rn_Nrt          IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins       IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src          IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id              OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => NULL,
            p_Ur_Create_Wu   => p_Executor_Wu,
            p_Ur_Ext_Id      => NULL,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => p_Rn_Nrt,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
            p_New_Rn_Id      => p_Rn_Id);

        --Зберігаємо інформацію про особу
        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Rnokpp,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_First_Name,
                                            p_Rnpi_Ln    => p_Last_Name,
                                            p_Rnpi_Mn    => p_Middle_Name,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Date_Birth);

        --Зберігаємо підставу для запиту
        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Pt_Request_Basis,
            p_Rnc_Val_String   => p_Basis_Request);
        --Зберігаємо період за який запитуємо дані
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_Begin,
                                         p_Rnc_Val_Dt   => p_Period_Begin);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_End,
                                         p_Rnc_Val_Dt   => p_Period_End);
    END;

    ------------------------------------------------------------------------------
    --      Отримання даних для відправки запиту до ДФС для отримання
    --                інформації про доходи особи
    --                 (ініціалізація розрахунку)
    ------------------------------------------------------------------------------
    FUNCTION Get_Income_Sources_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request         Uxp_Request%ROWTYPE;
        l_Birth_Dt            DATE;
        l_Basis_Request       VARCHAR2 (4000);
        l_Period_Begin        DATE;
        l_Period_End          DATE;
        l_Executor_Edrpou     VARCHAR2 (13);
        l_Executor_Rnokpp     VARCHAR2 (10);
        l_Executor_Fullname   VARCHAR2 (250);
        l_Executor_Org        NUMBER;
        l_Request_Payload     XMLTYPE;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Birth_Dt);
        l_Basis_Request :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Request_Basis);
        l_Period_Begin :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Period_Begin);
        l_Period_End :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Period_End);

        --#97366 22.01.2024
        l_Uxp_Request.Ur_Create_Wu :=
            NVL (l_Uxp_Request.Ur_Create_Wu, GetDPSComWU);

        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            Get_Executor_Info (p_Executor_Wu         => l_Uxp_Request.Ur_Create_Wu,
                               p_Executor_Rnokpp     => l_Executor_Rnokpp,
                               p_Executor_Fullname   => l_Executor_Fullname,
                               p_Executor_Org        => l_Executor_Org);
        ELSE
            l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
            l_Executor_Fullname := Get_Prm_Value ('DPS_EXECUTOR_PIB');
        END IF;

        IF l_Executor_Edrpou IS NULL
        THEN
            l_Executor_Edrpou := Get_Prm_Value ('DPS_EXECUTOR_EDRPOU');
        END IF;

        SELECT XMLELEMENT (
                   "InfoIncomeSourcesDRFOQueryRequest",
                   XMLELEMENT ("IDrequest", l_Uxp_Request.Ur_Rn),
                   XMLELEMENT ("basis_request", l_Basis_Request),
                   XMLELEMENT (
                       "ExecutorInfo",
                       XMLELEMENT ("ExecutorEDRPOUcode", l_Executor_Edrpou),
                       XMLELEMENT ("ExecutorRNOKPP", l_Executor_Rnokpp),
                       XMLELEMENT ("ExecutorFullName", l_Executor_Fullname)),
                   XMLELEMENT (
                       "person",
                       XMLELEMENT ("RNOKPP", p.Rnp_Inn),
                       XMLELEMENT ("last_name", i.Rnpi_Ln),
                       XMLELEMENT ("first_name", i.Rnpi_Fn),
                       XMLELEMENT ("middle_name", i.Rnpi_Mn),
                       CASE
                           WHEN l_Birth_Dt IS NOT NULL
                           THEN
                               XMLELEMENT (
                                   "date_birth",
                                   TO_CHAR (l_Birth_Dt, 'yyyy-mm-dd'))
                       END),
                   XMLELEMENT ("residense"),
                   XMLELEMENT (
                       "period",
                       XMLELEMENT ("period_begin_quarter",
                                   TO_CHAR (l_Period_Begin, 'Q')),
                       XMLELEMENT ("period_begin_year",
                                   TO_CHAR (l_Period_Begin, 'yyyy')),
                       XMLELEMENT ("period_end_quarter",
                                   TO_CHAR (l_Period_End, 'Q')),
                       XMLELEMENT ("period_end_year",
                                   TO_CHAR (l_Period_End, 'yyyy'))))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Uxp_Request.Ur_Rn;

        RETURN l_Request_Payload.Getclobval ();
    END;

    ------------------------------------------------------------------------------
    -- Обробка відповіді на запит до ДФС для отримання інформації про доходи особи
    --                 (ініціалізація розрахунку)
    ------------------------------------------------------------------------------
    PROCEDURE Handle_Income_Sources_Query_Resp (
        p_Ur_Id            IN     NUMBER,
        p_Response         IN     CLOB,
        p_Error            IN OUT VARCHAR2,
        p_Repeat              OUT VARCHAR2,
        p_Subreq_Created      OUT VARCHAR2,
        p_Subreq_Nrt       IN     NUMBER,
        p_Rn_Src           IN     VARCHAR2)
    IS
        l_Rn_Id   NUMBER;
    BEGIN
        p_Repeat := 'F';

        FOR Rec
            IN (               SELECT *
                                 FROM XMLTABLE (
                                          '/*'
                                          PASSING Xmltype (p_Response)
                                          COLUMNS Application_Number    VARCHAR2 (100) PATH 'applicationNumber',
                                                  Application_Date      VARCHAR2 (30) PATH 'applicationDate',
                                                  Result                VARCHAR2 (50) PATH 'Info/result',
                                                  Error                 VARCHAR2 (10) PATH 'error',
                                                  Errormsg              VARCHAR2 (4000) PATH 'errorMsg'))
        LOOP
            --Технічна помилка
            IF Rec.Error = c_Err_Internal
            THEN
                --Вказуємо, що запит необхідно повторити
                p_Repeat := 'T';
                RETURN;
            --Некоректний формат запиту
            ELSIF Rec.Error = c_Err_Bad_Req
            THEN
                p_Error := Rec.Errormsg;
                RETURN;
            -- Не знайшли дані у реєстрі
            ELSIF Rec.Result = '4'
            THEN
                p_Error := CHR (38) || '284';
                RETURN;
            END IF;

            --Реєструємо запит на отримання даних
            Reg_Income_Sources_Answer_Req (
                p_Application_Number   => Rec.Application_Number,
                p_Application_Date     => Rec.Application_Date,
                p_Url_Parent           => p_Ur_Id,
                p_Rn_Nrt               => p_Subreq_Nrt,
                p_Rn_Src               => p_Rn_Src,
                p_Rn_Id                => l_Rn_Id);
            p_Subreq_Created := 'T';
        END LOOP;
    END;

    ------------------------------------------------------------------------------
    --     Реєєстрація запиту до ДФС для отримання інформації про доходи особи
    --                 (отримання відповіді)
    ------------------------------------------------------------------------------
    PROCEDURE Reg_Income_Sources_Answer_Req (
        p_Application_Number   IN     VARCHAR2,
        p_Application_Date     IN     VARCHAR2,
        p_Url_Parent           IN     Uxp_Req_Links.Url_Parent%TYPE,
        p_Rn_Nrt               IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src               IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                   OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id          NUMBER;
        l_Url_Root       NUMBER;
        l_Root_Request   Uxp_Request%ROWTYPE;
    BEGIN
        l_Url_Root :=
            Api$uxp_Request.Get_Root_Request (p_Ur_Id => p_Url_Parent);

        IF l_Url_Root IS NULL
        THEN
            l_Url_Root := p_Url_Parent;
        END IF;

        l_Root_Request := Api$uxp_Request.Get_Request (l_Url_Root);

        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE + INTERVAL '1' MINUTE,
            p_Ur_Urt         => NULL,
            p_Ur_Create_Wu   => l_Root_Request.Ur_Create_Wu,
            p_Ur_Ext_Id      => NULL,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => p_Rn_Nrt,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Hs_Ins      => NULL,
            p_New_Rn_Id      => p_Rn_Id);

        Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_Id,
                                           p_Url_Root     => l_Url_Root,
                                           p_Url_Parent   => p_Url_Parent);

        --Зберігаємо параметри запиту
        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Pt_Application_Number,
            p_Rnc_Val_String   => p_Application_Number);

        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Pt_Application_Date,
            p_Rnc_Val_String   => p_Application_Date);
    END;

    ------------------------------------------------------------------------------
    --      Отримання даних для відправки запиту до ДФС для отримання
    --                інформації про доходи особи
    --                 (отримання відповіді)
    ------------------------------------------------------------------------------
    FUNCTION Get_Income_Sources_Answer_Data (
        p_Ur_Id   IN Uxp_Request.Ur_Id%TYPE)
        RETURN CLOB
    IS
        l_Uxp_Request          Uxp_Request%ROWTYPE;
        l_Application_Number   VARCHAR2 (100);
        l_Application_Date     VARCHAR2 (30);
        l_Request_Payload      XMLTYPE;
        l_Executor_Rnokpp      VARCHAR2 (10);
        l_Executor_Fullname    VARCHAR2 (250);
        l_Executor_Org         NUMBER;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);
        l_Application_Number :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Application_Number);

        l_Application_Date :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Application_Date);

        --#97366 22.01.2024
        l_Uxp_Request.Ur_Create_Wu :=
            NVL (l_Uxp_Request.Ur_Create_Wu, GetDPSComWU);

        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            Get_Executor_Info (p_Executor_Wu         => l_Uxp_Request.Ur_Create_Wu,
                               p_Executor_Rnokpp     => l_Executor_Rnokpp,
                               p_Executor_Fullname   => l_Executor_Fullname,
                               p_Executor_Org        => l_Executor_Org);
        ELSE
            l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
            l_Executor_Fullname := Get_Prm_Value ('DPS_EXECUTOR_PIB');
        END IF;

        SELECT XMLELEMENT (
                   "InfoIncomeSourcesDRFOAnswerRequest",
                   XMLELEMENT ("applicationNumber", l_Application_Number),
                   XMLELEMENT ("applicationDate", l_Application_Date),
                   XMLELEMENT ("ExecutorRNOKPP", l_Executor_Rnokpp),
                   XMLELEMENT ("ExecutorFullName", l_Executor_Fullname))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval ();
    END;


    --------------------------------------------------------------------
    --  Реєстрація запиту до ДПС (верифікація РНОКПП)
    --------------------------------------------------------------------
    PROCEDURE Reg_Create_DFS_RNOKPP_Req (
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
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2,
        p_Wu          IN     NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => p_Wu,
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
                                    p_Rnp_Ndt          => c_Pt_Dfs_Rnokpp_ndt_id,
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
    END;

    FUNCTION GetDPSComWU
        RETURN NUMBER
    IS
        l_Qty   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Qty
          FROM global_name
         WHERE global_name = 'SONYA12PDB.DEV.UA';

        IF l_Qty > 0
        THEN
            RETURN c_Dfs_Default_User_Id;
        END IF;

        /*
        SELECT COUNT(1)
        INTO l_Qty
        FROM global_name
        WHERE global_name = 'USSTEST1.MSP.CA.PFU';

        IF l_Qty > 0 THEN
          RETURN c_VS_Test1_User_Id;
        END IF;
        */
        RETURN NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION Get_DFS_RNOKPP_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request         Uxp_Request%ROWTYPE;
        l_Birth_Dt            DATE;
        l_Executor_Edrpou     VARCHAR2 (13);
        l_Executor_Rnokpp     VARCHAR2 (10);
        l_Executor_Fullname   VARCHAR2 (250);
        l_Executor_Org        NUMBER;
        l_Request_Payload     XMLTYPE;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Birth_Dt);

        --#97366 22.01.2024
        l_Uxp_Request.Ur_Create_Wu :=
            NVL (l_Uxp_Request.Ur_Create_Wu, GetDPSComWU);

        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            Get_Executor_Info (p_Executor_Wu         => l_Uxp_Request.Ur_Create_Wu,
                               p_Executor_Rnokpp     => l_Executor_Rnokpp,
                               p_Executor_Fullname   => l_Executor_Fullname,
                               p_Executor_Org        => l_Executor_Org);
        ELSE
            l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
            l_Executor_Fullname := Get_Prm_Value ('DPS_EXECUTOR_PIB');
        END IF;

        IF l_Executor_Edrpou IS NULL
        THEN
            l_Executor_Edrpou := Get_Prm_Value ('DPS_EXECUTOR_EDRPOU');
        END IF;

        SELECT XMLELEMENT (
                   "ser:InfoRNOKPPDRFORequest",
                   Xmlattributes (
                       'http://www.talend.org/service/' AS "xmlns:ser"),
                   XMLELEMENT ("ExecutorEDRPOUcode", l_Executor_Edrpou),
                   XMLELEMENT ("ExecutorRNOKPP", l_Executor_Rnokpp),
                   XMLELEMENT ("ExecutorFullName", l_Executor_Fullname),
                   XMLELEMENT (
                       "RNOKPP",
                       NVL (p.Rnp_Inn, p.rnp_doc_seria || p.rnp_doc_number)),
                   XMLELEMENT ("last_name", i.Rnpi_Ln),
                   XMLELEMENT ("first_name", i.Rnpi_Fn),
                   XMLELEMENT ("middle_name", i.Rnpi_Mn),
                   CASE
                       WHEN l_Birth_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date_birth",
                                       TO_CHAR (l_Birth_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Uxp_Request.Ur_Rn;

        RETURN l_Request_Payload.Getclobval ();
    END;


    ------------------------------------------------------------------------------
    --      Реєєстрація запиту до ДФС для отримання інформації
    --         про доходи особи із масових розрахунків
    --                 (ініціалізація розрахунку)
    -- #107929
    ------------------------------------------------------------------------------
    PROCEDURE Reg_Me_Income_Sources_Query_Req (
        p_Me_Id        IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Ur_Plan_Dt   IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id               NUMBER;
        c_Pt_Me_Id   CONSTANT NUMBER := 489;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Ur_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => 116,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => NULL,
                                              p_New_Rn_Id      => p_Rn_Id);
    END;

    ------------------------------------------------------------------------------
    --      Отримання даних для відправки запиту до ДФС для отримання
    --          інформації про доходи особи із масових розрахунків
    --                 (ініціалізація розрахунку)
    -- #107929
    ------------------------------------------------------------------------------
    FUNCTION Get_Me_Income_Sources_Query_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request         Uxp_Request%ROWTYPE;
        l_Executor_Edrpou     VARCHAR2 (13);
        l_Executor_Rnokpp     VARCHAR2 (10);
        l_Executor_Fullname   VARCHAR2 (250);
        l_Executor_Org        NUMBER;
        l_Request_Payload     XMLTYPE;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
        l_Executor_Fullname := Get_Prm_Value ('DPS_EXECUTOR_PIB');
        l_Executor_Edrpou := Get_Prm_Value ('DPS_EXECUTOR_EDRPOU');

        SELECT XMLELEMENT (
                   "InfoIncomeSourcesDRFOQueryRequest",
                   XMLELEMENT ("IDrequest", l_Uxp_Request.Ur_Rn),
                   XMLELEMENT ("basis_request", 2),
                   XMLELEMENT (
                       "ExecutorInfo",
                       XMLELEMENT ("ExecutorEDRPOUcode", l_Executor_Edrpou),
                       XMLELEMENT ("ExecutorRNOKPP", l_Executor_Rnokpp),
                       XMLELEMENT ("ExecutorFullName", l_Executor_Fullname)),
                   XMLELEMENT (
                       "person",
                       XMLELEMENT (
                           "RNOKPP",
                           NVL (r.mirr_numident,
                                r.mirr_doc_ser || r.mirr_doc_num)),
                       XMLELEMENT ("last_name", r.mirr_ln),
                       XMLELEMENT ("first_name", r.mirr_fn),
                       XMLELEMENT ("middle_name", r.mirr_mn),
                       CASE
                           WHEN r.mirr_birth_dt IS NOT NULL
                           THEN
                               XMLELEMENT (
                                   "date_birth",
                                   TO_CHAR (r.mirr_birth_dt, 'yyyy-mm-dd'))
                       END),
                   XMLELEMENT ("residense"),
                   XMLELEMENT (
                       "period",
                       XMLELEMENT ("period_begin_quarter",
                                   TO_CHAR (r.mirr_period_start_dt, 'Q')),
                       XMLELEMENT ("period_begin_year",
                                   TO_CHAR (r.mirr_period_start_dt, 'yyyy')),
                       XMLELEMENT ("period_end_quarter",
                                   TO_CHAR (r.mirr_period_stop_dt, 'Q')),
                       XMLELEMENT ("period_end_year",
                                   TO_CHAR (r.mirr_period_stop_dt, 'yyyy'))))
          INTO l_Request_Payload
          FROM Uss_Esr.v_Me_Income_Request_Rows  r,
               Uss_Esr.v_Me_Income_Request_Src   s
         WHERE r.Mirr_Id = s.Mirs_Mirr AND s.Mirs_Rn = l_Uxp_Request.Ur_Rn;

        RETURN l_Request_Payload.Getclobval ();
    END;
END Api$request_Dfs;
/