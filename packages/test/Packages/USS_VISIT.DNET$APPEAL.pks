/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$APPEAL
IS
    -- Author  : SHOSTAK
    -- Created : 25.05.2021 14:46:52
    -- Purpose :

    Package_Name         CONSTANT VARCHAR2 (100) := 'DNET$APPEAL';

    c_Xml_Dt_Fmt         CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    Msg_Opt_Block_Viol   CONSTANT NUMBER := 6011;

    --Послуги
    TYPE r_Ap_Service IS RECORD
    (
        Aps_Id     Ap_Service.Aps_Id%TYPE,
        Aps_Nst    Ap_Service.Aps_Nst%TYPE,
        Aps_St     Ap_Service.Aps_St%TYPE,
        New_Id     NUMBER,
        Deleted    NUMBER
    );

    TYPE t_Ap_Services IS TABLE OF r_Ap_Service;

    --Учасники
    TYPE r_Ap_Person IS RECORD
    (
        App_Id         Ap_Person.App_Id%TYPE,
        App_Tp         Ap_Person.App_Tp%TYPE,
        App_Inn        Ap_Person.App_Inn%TYPE,
        App_Ndt        Ap_Person.App_Ndt%TYPE,
        App_Doc_Num    Ap_Person.App_Doc_Num%TYPE,
        App_Fn         Ap_Person.App_Fn%TYPE,
        App_Mn         Ap_Person.App_Mn%TYPE,
        App_Ln         Ap_Person.App_Ln%TYPE,
        App_Esr_Num    Ap_Person.App_Esr_Num%TYPE,
        App_Gender     Ap_Person.App_Gender%TYPE,
        App_Sc         Ap_Person.App_Sc%TYPE,
        --#APP_NUM
        App_Num        Ap_Person.App_Num%TYPE,
        New_Id         NUMBER,
        Deleted        NUMBER
    );

    TYPE t_Ap_Persons IS TABLE OF r_Ap_Person;

    --Способи виплат
    TYPE r_Ap_Payment IS RECORD
    (
        Apm_Id              Ap_Payment.Apm_Id%TYPE,
        Apm_Aps             Ap_Payment.Apm_Aps%TYPE,
        Apm_App             Ap_Payment.Apm_App%TYPE,
        Apm_Tp              Ap_Payment.Apm_Tp%TYPE,
        Apm_Index           Ap_Payment.Apm_Index%TYPE,
        Apm_Kaot            Ap_Payment.Apm_Kaot%TYPE,
        Apm_Nb              Ap_Payment.Apm_Nb%TYPE,
        Apm_Account         Ap_Payment.Apm_Account%TYPE,
        Apm_Need_Account    Ap_Payment.Apm_Need_Account%TYPE,
        Apm_Street          Ap_Payment.Apm_Street%TYPE,
        Apm_Ns              Ap_Payment.Apm_Ns%TYPE,
        Apm_Building        Ap_Payment.Apm_Building%TYPE,
        Apm_Block           Ap_Payment.Apm_Block%TYPE,
        Apm_Apartment       Ap_Payment.Apm_Apartment%TYPE,
        Apm_Dppa            Ap_Payment.Apm_Dppa%TYPE,
        Deleted             NUMBER
    );

    TYPE t_Ap_Payments IS TABLE OF r_Ap_Payment;

    --Атрибути докумена
    TYPE r_Ap_Document_Attr IS RECORD
    (
        Apda_Id            Ap_Document_Attr.Apda_Id%TYPE,
        Apda_Nda           Ap_Document_Attr.Apda_Nda%TYPE,
        Apda_Val_String    Ap_Document_Attr.Apda_Val_String%TYPE,
        Apda_Val_Int       Ap_Document_Attr.Apda_Val_Int%TYPE,
        Apda_Val_Dt        TIMESTAMP,
        Apda_Val_Id        Ap_Document_Attr.Apda_Val_Id%TYPE,
        Apda_Val_Sum       Ap_Document_Attr.Apda_Val_Sum%TYPE,
        Apda_Apd           Ap_Document_Attr.Apda_Apd%TYPE,
        Deleted            NUMBER
    );

    TYPE t_Ap_Document_Attrs IS TABLE OF r_Ap_Document_Attr;

    --Документи
    TYPE r_Ap_Document IS RECORD
    (
        Apd_Id             Ap_Document.Apd_Id%TYPE,
        Apd_Ndt            Ap_Document.Apd_Ndt%TYPE,
        Apd_Doc            Ap_Document.Apd_Doc%TYPE,
        Apd_App            Ap_Document.Apd_App%TYPE,
        Apd_Dh             Ap_Document.Apd_Dh%TYPE,
        Apd_Aps            Ap_Document.Apd_Aps%TYPE,
        Attributes         XMLTYPE,
        Apd_Attachments    XMLTYPE,
        Sign_Info          VARCHAR2 (4000),
        Deleted            NUMBER
    );

    TYPE t_Ap_Documents IS TABLE OF r_Ap_Document;

    --Файли докумена
    TYPE r_Doc_Attachment IS RECORD
    (
        File_Code           VARCHAR2 (50),
        File_Name           VARCHAR2 (255),
        File_Mime_Type      VARCHAR2 (255),
        File_Size           NUMBER,
        File_Create_Dt      TIMESTAMP,
        File_Description    VARCHAR2 (255),
        Deleted             NUMBER
    );

    TYPE t_Doc_Attachments IS TABLE OF r_Doc_Attachment;

    ---------------------------------------------
    --           ДЕКЛАРАЦІЯ
    ---------------------------------------------
    --Контейнер декларації
    TYPE r_Declaration_Dto IS RECORD
    (
        Declaration       XMLTYPE,
        Persons           XMLTYPE,
        Incomes           XMLTYPE,
        Land_Plots        XMLTYPE,
        Living_Qurters    XMLTYPE,
        Other_Incomes     XMLTYPE,
        Spendings         XMLTYPE,
        Vehicles          XMLTYPE,
        Alimonies         XMLTYPE
    );

    TYPE r_Ap_Declaration IS RECORD
    (
        Apr_Id           Ap_Declaration.Apr_Id%TYPE,
        Apr_Fn           Ap_Declaration.Apr_Fn%TYPE,
        Apr_Mn           Ap_Declaration.Apr_Mn%TYPE,
        Apr_Ln           Ap_Declaration.Apr_Ln%TYPE,
        Apr_Residence    Ap_Declaration.Apr_Residence%TYPE,
        Com_Org          Ap_Declaration.Com_Org%TYPE,
        Apr_Vf           Ap_Declaration.Apr_Vf%TYPE,
        Apr_Start_Dt     VARCHAR2 (30),          --потом конвертируется в date
        Apr_Stop_Dt      VARCHAR2 (30)           --потом конвертируется в date
    );

    TYPE r_Apr_Person IS RECORD
    (
        Aprp_Id       Apr_Person.Aprp_Id%TYPE,
        Aprp_Apr      Apr_Person.Aprp_Apr%TYPE,
        Aprp_Fn       Apr_Person.Aprp_Fn%TYPE,
        Aprp_Mn       Apr_Person.Aprp_Mn%TYPE,
        Aprp_Ln       Apr_Person.Aprp_Ln%TYPE,
        Aprp_Tp       Apr_Person.Aprp_Tp%TYPE,
        Aprp_Inn      Apr_Person.Aprp_Inn%TYPE,
        Aprp_Notes    Apr_Person.Aprp_Notes%TYPE,
        Aprp_App      Apr_Person.Aprp_App%TYPE,
        New_Id        NUMBER,
        Deleted       NUMBER
    );

    TYPE t_Apr_Persons IS TABLE OF r_Apr_Person;

    TYPE r_Apr_Income IS RECORD
    (
        Apri_Id          Apr_Income.Apri_Id%TYPE,
        Apri_Apr         Apr_Income.Apri_Apr%TYPE,
        Apri_Tp          Apr_Income.Apri_Tp%TYPE,
        Apri_Sum         VARCHAR2 (100),       --потом конвертируется в number
        Apri_Source      Apr_Income.Apri_Source%TYPE,
        Apri_Aprp        Apr_Income.Apri_Aprp%TYPE,
        Apri_Start_Dt    VARCHAR2 (30),          --потом конвертируется в date
        Apri_Stop_Dt     VARCHAR2 (30),          --потом конвертируется в date
        Deleted          NUMBER
    );

    TYPE t_Apr_Incomes IS TABLE OF r_Apr_Income;

    TYPE r_Apr_Land_Plot IS RECORD
    (
        Aprt_Id           Apr_Land_Plot.Aprt_Id%TYPE,
        Aprt_Apr          Apr_Land_Plot.Aprt_Apr%TYPE,
        Aprt_Area         Apr_Land_Plot.Aprt_Area%TYPE,
        Aprt_Ownership    Apr_Land_Plot.Aprt_Ownership%TYPE,
        Aprt_Purpose      Apr_Land_Plot.Aprt_Purpose%TYPE,
        Aprt_Aprp         Apr_Land_Plot.Aprt_Aprp%TYPE,
        Deleted           NUMBER
    );

    TYPE t_Apr_Land_Plots IS TABLE OF r_Apr_Land_Plot;

    TYPE r_Apr_Living_Quarters IS RECORD
    (
        Aprl_Id         Apr_Living_Quarters.Aprl_Id%TYPE,
        Aprl_Apr        Apr_Living_Quarters.Aprl_Apr%TYPE,
        Aprl_Area       Apr_Living_Quarters.Aprl_Area%TYPE,
        Aprl_Qnt        Apr_Living_Quarters.Aprl_Qnt%TYPE,
        Aprl_Address    Apr_Living_Quarters.Aprl_Address%TYPE,
        Aprl_Aprp       Apr_Living_Quarters.Aprl_Aprp%TYPE,
        Aprl_Tp         Apr_Living_Quarters.Aprl_Tp%TYPE,
        Aprl_Ch         Apr_Living_Quarters.Aprl_Ch%TYPE,
        Deleted         NUMBER
    );

    TYPE t_Apr_Living_Quarters IS TABLE OF r_Apr_Living_Quarters;

    TYPE r_Apr_Other_Income IS RECORD
    (
        Apro_Id              Apr_Other_Income.Apro_Id%TYPE,
        Apro_Apr             Apr_Other_Income.Apro_Apr%TYPE,
        Apro_Tp              Apr_Other_Income.Apro_Tp%TYPE,
        Apro_Income_Info     Apr_Other_Income.Apro_Income_Info%TYPE,
        Apro_Income_Usage    Apr_Other_Income.Apro_Income_Usage%TYPE,
        Apro_Aprp            Apr_Other_Income.Apro_Aprp%TYPE,
        Deleted              NUMBER
    );

    TYPE t_Apr_Other_Incomes IS TABLE OF r_Apr_Other_Income;

    TYPE r_Apr_Spending IS RECORD
    (
        Aprs_Id           Apr_Spending.Aprs_Id%TYPE,
        Aprs_Apr          Apr_Spending.Aprs_Apr%TYPE,
        Aprs_Tp           Apr_Spending.Aprs_Tp%TYPE,
        Aprs_Cost_Type    Apr_Spending.Aprs_Cost_Type%TYPE,
        Aprs_Cost         VARCHAR2 (100),      --потом конвертируется в number
        Aprs_Dt           VARCHAR2 (30),         --потом конвертируется в date
        Aprs_Aprp         Apr_Spending.Aprs_Aprp%TYPE,
        Deleted           NUMBER
    );

    TYPE t_Apr_Spendings IS TABLE OF r_Apr_Spending;

    TYPE r_Apr_Vehicle IS RECORD
    (
        Aprv_Id                 Apr_Vehicle.Aprv_Id%TYPE,
        Aprv_Apr                Apr_Vehicle.Aprv_Apr%TYPE,
        Aprv_Car_Brand          Apr_Vehicle.Aprv_Car_Brand%TYPE,
        Aprv_License_Plate      Apr_Vehicle.Aprv_License_Plate%TYPE,
        Aprv_Production_Year    Apr_Vehicle.Aprv_Production_Year%TYPE,
        Aprv_Is_Social_Car      Apr_Vehicle.Aprv_Is_Social_Car%TYPE,
        Aprv_Aprp               Apr_Vehicle.Aprv_Aprp%TYPE,
        Deleted                 NUMBER
    );

    TYPE t_Apr_Vehicles IS TABLE OF r_Apr_Vehicle;

    TYPE r_Apr_Alimony IS RECORD
    (
        Apra_Id                 Apr_Alimony.Apra_Id%TYPE,
        Apra_Apr                Apr_Alimony.Apra_Apr%TYPE,
        Apra_Payer              Apr_Alimony.Apra_Payer%TYPE,
        Apra_Sum                Apr_Alimony.Apra_Sum%TYPE,
        Apra_Is_Have_Arrears    Apr_Alimony.Apra_Is_Have_Arrears%TYPE,
        Apra_Aprp               Apr_Alimony.Apra_Aprp%TYPE,
        Deleted                 NUMBER
    );

    TYPE t_Apr_Alimonies IS TABLE OF r_Apr_Alimony;

    TYPE r_Id IS RECORD
    (
        Id    NUMBER
    );

    TYPE t_Ids IS TABLE OF r_Id;

    TYPE r_Missing_Doc IS RECORD
    (
        Ndt_Id    NUMBER,
        Doc_Id    NUMBER (14),
        Dh_Id     NUMBER (14)
    );

    TYPE t_Missing_Doc IS TABLE OF r_Missing_Doc;

    TYPE t_Ndi_Nst_Doc_Config
        IS TABLE OF Uss_Ndi.v_Ndi_Nst_Doc_Config%ROWTYPE;

    TYPE r_Tmp_Doc_Attr IS RECORD
    (
        Doc_Id             NUMBER,
        Apda_Nda           NUMBER,
        Apda_Val_String    Ap_Document_Attr.Apda_Val_String%TYPE,
        Apda_Val_Int       NUMBER,
        Apda_Val_Dt        DATE,
        Apda_Val_Id        NUMBER,
        Apda_Val_Sum       NUMBER,
        Dh_Id              NUMBER
    );

    TYPE t_Tmp_Doc_Attrs IS TABLE OF r_Tmp_Doc_Attr;

    /*
    PROCEDURE Get_Appeals_List_(p_Ap_Num            IN VARCHAR2,
                                 p_Ap_Reg_Dt_From    IN DATE,
                                 p_Ap_Reg_Dt_To      IN DATE,
                                 p_Ap_Src            IN VARCHAR2,
                                 p_Ap_St             IN VARCHAR2,
                                 p_App_Ln            IN VARCHAR2,
                                 p_App_Fn            IN VARCHAR2,
                                 p_App_Mn            IN VARCHAR2,
                                 p_Ap_Tp             IN VARCHAR2,
                                 p_Mode              IN VARCHAR2,
                                 p_App_Ndt           IN NUMBER,
                                 p_App_Seria_Number  IN VARCHAR2,
                                 p_Ap_Create_Dt_From IN DATE,
                                 p_Ap_Create_Dt_To   IN DATE,
                                 p_Comorg            IN NUMBER, --Орган соціального захисту
                                 p_Res               OUT SYS_REFCURSOR) ;
    */

    --
    PROCEDURE Get_Appeals_List (p_Ap_Num              IN     VARCHAR2,
                                p_Ap_Reg_Dt_From      IN     DATE,
                                p_Ap_Reg_Dt_To        IN     DATE,
                                p_Ap_Src              IN     VARCHAR2,
                                p_Ap_St               IN     VARCHAR2,
                                p_App_Ln              IN     VARCHAR2,
                                p_App_Fn              IN     VARCHAR2,
                                p_App_Mn              IN     VARCHAR2,
                                p_Ap_Tp               IN     VARCHAR2,
                                p_Mode                IN     VARCHAR2,
                                p_App_Ndt             IN     NUMBER,
                                p_App_Seria_Number    IN     VARCHAR2,
                                p_Ap_Create_Dt_From   IN     DATE,
                                p_Ap_Create_Dt_To     IN     DATE,
                                p_Comorg              IN     NUMBER, --Орган соціального захисту
                                p_Aps_Nst             IN     NUMBER,
                                p_Ap_Vf_Name          IN     VARCHAR2, -- kolio Стан верифікації
                                p_Res                    OUT SYS_REFCURSOR);

    -- info:   Выбор всех масивов с информацией по идентификатору ОБРАЩЕНИЯ
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Appeal_Card (p_Ap_Id          IN     NUMBER,
                               Main_Cur            OUT SYS_REFCURSOR,
                               Ser_Cur             OUT SYS_REFCURSOR,
                               Pers_Cur            OUT SYS_REFCURSOR,
                               Docs_Cur            OUT SYS_REFCURSOR,
                               Docs_Attr_Cur       OUT SYS_REFCURSOR,
                               Docs_Files_Cur      OUT SYS_REFCURSOR,
                               Pay_Cur             OUT SYS_REFCURSOR);

    PROCEDURE Get_Doc_File (p_Apd_Id IN NUMBER, p_File OUT BLOB);

    PROCEDURE Get_Appeal (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Services (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Persons (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    FUNCTION Get_Ap_Person (p_Ap_Id NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Person_Pib (p_App_Id NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_Pib (p_Ap_Id        NUMBER,
                             p_ln_attr   IN NUMBER,
                             p_fn_attr   IN NUMBER,
                             p_mn_attr   IN NUMBER,
                             P_MODE      IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Person_Pib_Tp_List (p_Ap_Id       NUMBER,
                                        p_App_Tp   IN VARCHAR2,
                                        P_MODE     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Pib (p_Ap_Id NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Persons (p_Ap_Id NUMBER)
        RETURN t_Ap_Persons;

    FUNCTION Doc_Is_Read_Only (p_Apd_Vf IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Documents (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Register_Doc_Hist (p_Doc_Id NUMBER, p_Dh_Id OUT NUMBER);

    PROCEDURE Get_Signed_Documents_Files (p_Ap_Id       NUMBER,
                                          p_Res     OUT SYS_REFCURSOR);

    PROCEDURE Get_Documents_Files (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Documents_Attr (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Payments (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Docs_By_Sc (p_Sc_Id          NUMBER,
                              p_Docs_Cur   OUT SYS_REFCURSOR,
                              Attrs_Cur    OUT SYS_REFCURSOR,
                              Files_Cur    OUT SYS_REFCURSOR);

    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Missing_Docs (
        p_App_Services      IN     VARCHAR2, --Список типів послуг, що прив’язані до учасника
        p_Ap_Tp             IN     VARCHAR2,
        p_App_Tp            IN     Ap_Person.App_Tp%TYPE,
        p_App_Sc            IN     NUMBER,
        p_App_Ndt           IN     NUMBER,
        p_App_Doc_Num       IN     VARCHAR2,
        p_App_Inn           IN     VARCHAR2,
        p_App_Ln            IN     VARCHAR2,
        p_App_Fn            IN     VARCHAR2,
        p_App_Mn            IN     VARCHAR2,
        p_Ankt_Attributes   IN     CLOB,
        p_App_Documents     IN     VARCHAR2, --Список типів документів, що прив’язані до учасника
        p_Birth_Dt          IN     DATE,
        p_Docs_Cur             OUT SYS_REFCURSOR,
        p_Attrs_Cur            OUT SYS_REFCURSOR,
        p_Files_Cur            OUT SYS_REFCURSOR);

    PROCEDURE Save_Appeal (
        p_Ap_Id            IN     Appeal.Ap_Id%TYPE,
        p_Ap_Is_Second     IN     Appeal.Ap_Is_Second%TYPE,
        p_Is_Unchanged     IN     VARCHAR2,                             -- T/F
        p_Ap_Tp            IN     Appeal.Ap_Tp%TYPE,
        p_Ap_St            IN     Appeal.Ap_St%TYPE,
        p_Obi_Ts           IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Reg_Dt        IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Dest_Org      IN     Appeal.Ap_Dest_Org%TYPE,
        p_Ap_Services      IN     CLOB,
        p_Ap_Persons       IN     CLOB,
        p_Ap_Payments      IN     CLOB,
        p_Ap_Documents     IN     CLOB,
        p_Ap_Declaration   IN     CLOB,
        p_New_Id              OUT Appeal.Ap_Id%TYPE,
        p_Messages            OUT SYS_REFCURSOR,
        p_Ap_Ap_Main       IN     Appeal.Ap_Ap_Main%TYPE DEFAULT NULL);

    PROCEDURE Save_Appeal_Light (
        p_Ap_Id               IN     Appeal.Ap_Id%TYPE,
        p_Ap_Tp               IN     Appeal.Ap_Tp%TYPE,
        p_Ap_St               IN     Appeal.Ap_St%TYPE,
        p_Obi_Ts              IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Reg_Dt           IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Dest_Org         IN     Appeal.Ap_Dest_Org%TYPE,
        p_Ap_Inn              IN     VARCHAR2,
        p_Ap_Inn_Refusal      IN     VARCHAR2,
        p_Ap_FIO              IN     VARCHAR2,
        p_Ap_Is_About_Other   IN     VARCHAR2,
        p_Ap_City             IN     VARCHAR2,
        p_Ap_Street           IN     VARCHAR2,
        p_Ap_Building         IN     VARCHAR2,
        p_Ap_Block            IN     VARCHAR2,
        p_Ap_Flat             IN     VARCHAR2,
        p_Ap_Phone            IN     VARCHAR2,
        p_Ap_Email            IN     VARCHAR2,
        p_Ap_Situation        IN     VARCHAR2,
        p_Ap_Child_Treat      IN     VARCHAR2,
        p_New_Id                 OUT Appeal.Ap_Id%TYPE,
        p_Messages               OUT SYS_REFCURSOR,
        p_Ap_Documents        IN     CLOB DEFAULT NULL,
        p_Ap_City_Name        IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Save_Appeal_Rehab_Tool (
        p_Ap_Id                           IN     Appeal.Ap_Id%TYPE,
        p_Obi_Ts                          IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Dest_Org                     IN     Appeal.Ap_Dest_Org%TYPE, -- ТВ ФСЗОІ куди подається заява (за місцем реєстрації особи)
        p_Ap_LName                        IN     VARCHAR2,    --Прізвище особи
        p_Ap_FName                        IN     VARCHAR2,              --Ім’я
        p_Ap_MName                        IN     VARCHAR2,       --По батькові
        p_Ap_Inn_Refusal                  IN     VARCHAR2, --Ознака відмови від РНОКПП
        p_Ap_Inn                          IN     VARCHAR2,   --РНОКПП заявника
        p_Ap_Live_City                    IN     NUMBER,
        p_Ap_Live_Street                  IN     VARCHAR2,
        p_Ap_Live_Building                IN     VARCHAR2,
        p_Ap_Live_Block                   IN     VARCHAR2,
        p_Ap_Live_Flat                    IN     VARCHAR2,
        p_Ap_Phone                        IN     VARCHAR2,
        p_Ap_Phone_Add                    IN     VARCHAR2,
        p_Ap_Tool_List                    IN     VARCHAR2,
        p_New_Id                             OUT Appeal.Ap_Id%TYPE,
        p_Messages                           OUT SYS_REFCURSOR,
        p_Gender                          IN     VARCHAR2,
        p_Birth_Dt                        IN     DATE,
        p_Ap_Documents                    IN     CLOB,
        p_is_Address_Live_eq_Reg          IN     VARCHAR2,
        p_Ap_Reg_City                     IN     NUMBER,
        p_Ap_Reg_Index                    IN     VARCHAR2,
        p_Ap_Reg_Street                   IN     VARCHAR2,
        p_Ap_Reg_Building                 IN     VARCHAR2,
        p_Ap_Reg_Block                    IN     VARCHAR2,
        p_Ap_Reg_Flat                     IN     VARCHAR2,
        p_Is_Vpo_Exist                    IN     VARCHAR2,
        p_Is_Regf_Addr_Not_Eq_fact_Addr   IN     VARCHAR2,
        p_Is_Vpo_Addr_Eq_Fact_Addr        IN     VARCHAR2,
        p_Ap_Live_Index                   IN     VARCHAR2);

    PROCEDURE Save_Declaration (p_Ap_Id             IN Appeal.Ap_Id%TYPE,
                                p_Com_Org           IN NUMBER,
                                p_Declaration_Dto   IN r_Declaration_Dto,
                                p_Ap_Persons        IN t_Ap_Persons);

    PROCEDURE Save_Note (p_Ap_Id NUMBER, p_Note_Document CLOB);

    PROCEDURE Search_Person (p_Inn          IN     VARCHAR2,
                             p_Doc_Num      IN     VARCHAR2,
                             p_Esr_Num      IN     VARCHAR2,
                             p_Ln           IN     VARCHAR2,
                             p_Fn           IN     VARCHAR2,
                             p_Mn           IN     VARCHAR2,
                             p_Ndt_Id       IN     NUMBER,
                             p_Gender       IN     VARCHAR2,
                             p_Show_Modal      OUT NUMBER,
                             p_Rn_Id           OUT NUMBER,
                             Res_Cur           OUT SYS_REFCURSOR);

    PROCEDURE Get_Person_Search_Result (p_Rn_Id   IN     NUMBER,
                                        p_Rn_St      OUT VARCHAR2,
                                        Res_Cur      OUT SYS_REFCURSOR);

    -- #70852: Создание временной социальной карточки особи при регистрации звернення
    PROCEDURE Create_Person (p_Inn        IN     VARCHAR2,
                             p_Ndt_Id     IN     VARCHAR2,
                             p_Doc_Num    IN     VARCHAR2,
                             p_Fn         IN     VARCHAR2,
                             p_Ln         IN     VARCHAR2,
                             p_Mn         IN     VARCHAR2,
                             p_Esr_Num    IN     VARCHAR2,
                             p_Gender     IN     VARCHAR2,
                             p_Birth_Dt   IN     DATE,
                             p_Mode       IN     NUMBER,
                             p_Sc_Id         OUT NUMBER);

    PROCEDURE Get_Ap_Log (p_Ap_Id            Appeal.Ap_Id%TYPE,
                          p_Log_Cursor   OUT SYS_REFCURSOR);

    -- #69968: вичитка декларації по зверненню
    PROCEDURE Get_Declaration (p_Ap_Id       IN     NUMBER,
                               Decl_Cur         OUT SYS_REFCURSOR,
                               Person_Cur       OUT SYS_REFCURSOR,
                               Inc_Cur          OUT SYS_REFCURSOR,
                               Land_Cur         OUT SYS_REFCURSOR,
                               Living_Cur       OUT SYS_REFCURSOR,
                               Other_Cur        OUT SYS_REFCURSOR,
                               Spend_Cur        OUT SYS_REFCURSOR,
                               Vehicle_Cur      OUT SYS_REFCURSOR,
                               Alimony_Cur      OUT SYS_REFCURSOR);

    -- #70521: "Повернути на довведення"
    PROCEDURE Return_Appeals (p_Ap_Id IN NUMBER);

    -- #117308: "Повернути на довведення для ТГ/ЦНАП"
    PROCEDURE Return_Appeals_Tsnap (p_Ap_Id IN NUMBER);

    -- #81791: "Повернути на СГ"
    PROCEDURE Return_Appeal_To_Sg (p_Ap_Id IN NUMBER);

    PROCEDURE Create_App_By_Attr (p_Ap_id IN APPEAL.AP_ID%TYPE);

    -- створення дублікату звернення
    PROCEDURE Duplicate_Appeal (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER);

    -- #97069: створення дублікату звернення "Звернення іншого батька"
    PROCEDURE Duplicate_Appeal_ANF (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER);

    -- #82496: Визначення необхідності заповнення вкладки «Декларація»
    FUNCTION Get_Isneed_Income (p_Ap_Id NUMBER, p_Ap_Tp VARCHAR2)
        RETURN NUMBER;

    -- #117306 повернення з ОСЗН до org_to ЦНАП/ТГ
    PROCEDURE return_to_tsnap (p_ap_id IN NUMBER, p_msg IN VARCHAR2);

    -- #117321 взяти в роботу в ОСЗН звернення ЦНАП/ТГ
    PROCEDURE get_to_work (p_ap_id IN NUMBER);
END Dnet$appeal;
/


GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO II01RC_USS_VISIT_WEB
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL TO USS_RNSP
/


/* Formatted on 8/12/2025 5:59:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$APPEAL
IS
    PROCEDURE Get_Appeals_List (p_Ap_Num              IN     VARCHAR2,
                                p_Ap_Reg_Dt_From      IN     DATE,
                                p_Ap_Reg_Dt_To        IN     DATE,
                                p_Ap_Src              IN     VARCHAR2,
                                p_Ap_St               IN     VARCHAR2,
                                p_App_Ln              IN     VARCHAR2,
                                p_App_Fn              IN     VARCHAR2,
                                p_App_Mn              IN     VARCHAR2,
                                p_Ap_Tp               IN     VARCHAR2,
                                p_Mode                IN     VARCHAR2,
                                p_App_Ndt             IN     NUMBER,
                                p_App_Seria_Number    IN     VARCHAR2,
                                p_Ap_Create_Dt_From   IN     DATE,
                                p_Ap_Create_Dt_To     IN     DATE,
                                p_Comorg              IN     NUMBER, --Орган соціального захисту
                                p_Aps_Nst             IN     NUMBER,
                                p_Ap_Vf_Name          IN     VARCHAR2, -- kolio Стан верифікації
                                p_Res                    OUT SYS_REFCURSOR)
    IS
        l_View_Role    NUMBER := Tools.Checkcurruserrole ('W_VT_VIEW');
        l_Sql          VARCHAR2 (32000);
        l_1310         VARCHAR2 (20) := CHR (13) || CHR (10);
        Appeal_Filtr   Tmp_Appeal_Filter%ROWTYPE;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Appeals_List');

        DELETE FROM Tmp_Appeal_Filter
              WHERE 1 = 1;

        Appeal_Filtr.Taf_Ap_Num := p_Ap_Num;
        Appeal_Filtr.Taf_Ap_Reg_Dt_From :=
            NVL (p_Ap_Reg_Dt_From, SYSDATE - 130);
        Appeal_Filtr.Taf_Ap_Reg_Dt_To :=
            NVL (p_Ap_Reg_Dt_To, TO_DATE ('01.01.9999', 'DD.MM.YYYY'));
        Appeal_Filtr.Taf_Ap_Create_Dt_From :=
            NVL (p_Ap_Create_Dt_From, SYSDATE - 130);
        Appeal_Filtr.Taf_Ap_Create_Dt_To :=
            NVL (p_Ap_Create_Dt_To, TO_DATE ('01.01.9999', 'DD.MM.YYYY'));
        Appeal_Filtr.Taf_Ap_Src := p_Ap_Src;
        Appeal_Filtr.Taf_Ap_St := p_Ap_St;
        Appeal_Filtr.Taf_App_Ln := p_App_Ln;
        Appeal_Filtr.Taf_App_Fn := p_App_Fn;
        Appeal_Filtr.Taf_App_Mn := p_App_Mn;
        Appeal_Filtr.Taf_Ap_Tp := p_Ap_Tp;
        Appeal_Filtr.Taf_Mode := p_Mode;
        Appeal_Filtr.Taf_App_Ndt := p_App_Ndt;
        Appeal_Filtr.Taf_App_Seria_Number := p_App_Seria_Number;
        Appeal_Filtr.Taf_Comorg := p_Comorg;
        Appeal_Filtr.Taf_Aps_Nst := p_Aps_Nst;
        Appeal_Filtr.Taf_Ap_Vf_Name := p_Ap_Vf_Name; -- kolio Стан верифікації
        --
        Appeal_Filtr.Taf_Org := Tools.Getcurrorg;
        Appeal_Filtr.Taf_Org_To := Tools.Getcurrorgto;
        Appeal_Filtr.Taf_Wu := Tools.Getcurrwu;

        INSERT INTO Tmp_Appeal_Filter
             VALUES Appeal_Filtr;

        --use_ln(f t z)
        --/*+ FIRST_ROWS */
        l_Sql :=
            q'[
      SELECT /*+ FIRST_ROWS index (t i_ap_set1) INDEX(Ap_Person I_APP_FN_SET1 I_APP_LN_SET1 I_APP_MN_SET1) */
             t.*,
             (select St.Dic_Sname  from Uss_Ndi.v_Ddn_Ap_St St   where St.Dic_Value  = t.Ap_St)  AS Ap_St_Name,
             (select Tp.Dic_Sname  from Uss_Ndi.v_Ddn_Ap_Tp Tp   where Tp.Dic_Value  = t.Ap_Tp)  AS Ap_Tp_Name,
             (select Src.Dic_Sname from Uss_Ndi.v_Ddn_Ap_Src Src where Src.Dic_Value = t.Ap_Src) AS Ap_Src_Name,
             Uss_Visit.Dnet$verification.Get_Vf_St_Name(Ap_Vf) AS Ap_Vf_Name,
             Dnet$appeal.Get_Ap_Person(t.Ap_Id)  AS App_Pib,
             Opfu.Org_Code || ' ' || Opfu.Org_Name AS Opfu_Name,
             (SELECT LISTAGG(ST.NST_CODE, ', ') WITHIN GROUP(ORDER BY ST.NST_ORDER)
                FROM V_AP_SERVICE Z
                JOIN USS_NDI.V_NDI_SERVICE_TYPE ST ON (ST.NST_ID = Z.APS_NST)
               WHERE Z.APS_AP = T.AP_ID
                 AND Z.HISTORY_STATUS = 'A') AS NST_LIST
        FROM TMP_appeal_filter f
             JOIN v_Appeal t ON t.Ap_Reg_Dt    BETWEEN f.taf_Ap_Reg_Dt_From AND f.taf_Ap_Reg_Dt_To
                                AND t.Ap_Create_Dt BETWEEN f.taf_Ap_Create_Dt_From AND f.taf_Ap_Create_Dt_To]';

        IF       Appeal_Filtr.Taf_App_Fn
              || Appeal_Filtr.Taf_App_Mn
              || Appeal_Filtr.Taf_App_Ln
                  IS NOT NULL
           OR Appeal_Filtr.Taf_App_Ndt IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             JOIN Uss_Visit.Ap_Person z  on z.App_Ap = t.Ap_Id and z.history_status = 'A' ]';
        END IF;

        l_Sql :=
               l_Sql
            || l_1310
            || q'[             JOIN v_Opfu Opfu         ON t.Com_Org = Opfu.Org_Id
       WHERE rownum < 502 ]';

        IF Appeal_Filtr.Taf_Comorg IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Com_Org = f.taf_Comorg]';
        END IF;

        IF Appeal_Filtr.Taf_Ap_Num IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Ap_Num LIKE f.taf_Ap_Num || '%']';
            l_Sql := REPLACE (l_Sql, '(t i_ap_set1)', '(t i_ap_num)');
        END IF;

        IF Appeal_Filtr.Taf_Ap_Src IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Ap_Src = f.taf_Ap_Src ]';
        END IF;

        IF Appeal_Filtr.Taf_Ap_Tp IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Ap_Tp = f.taf_Ap_Tp ]';
        END IF;

        -- #115342
        IF Appeal_Filtr.Taf_Org_To IN (80, 81)
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Ap_Tp in ('D', 'DD')  ]';
            l_Sql :=
                   l_Sql
                || ' AND EXISTS (select * from ap_service z where z.aps_ap = ap_id and z.history_status = ''A'' and z.aps_nst in (22,61,101) )';
        END IF;

        -- kolio Стан верифікації
        IF Appeal_Filtr.Taf_Ap_Vf_Name IS NOT NULL
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND Uss_Visit.Dnet$verification.Get_Vf_St_Value(Ap_Vf) = f.taf_ap_vf_name ]';
        END IF;

        IF    l_View_Role = 0
           OR     Appeal_Filtr.Taf_Mode IS NOT NULL
              AND Appeal_Filtr.Taf_Mode = -1
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND (t.com_wu = f.taf_wu or Opfu.org_to in (33, 35) and t.ap_dest_org = f.taf_org )]';
        ELSIF l_View_Role = 1
        THEN
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND ( f.taf_org_to IN (32, 33) AND (t.com_org = f.taf_org OR opfu.org_org = f.taf_org OR t.com_wu = f.taf_wu or Opfu.org_to in (33, 35) and t.ap_dest_org = f.taf_org)]';
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[                   OR f.taf_org_to NOT IN (32, 33)]';
            l_Sql := l_Sql || l_1310 || q'[                  )]';
        END IF;

        IF Appeal_Filtr.Taf_Ap_St IS NULL
        THEN
            IF Appeal_Filtr.Taf_Mode = -2
            THEN                                              -- Всі звернення
                NULL;
            ELSIF Appeal_Filtr.Taf_Mode = -1
            THEN                                              -- Мої звернення
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Ap_St IN ('N', 'J', 'W', 'B', 'FD', 'R', 'RR')]';
            ELSIF Appeal_Filtr.Taf_Mode = 1
            THEN                                      -- Звернення на контролі
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Ap_St IN ('F', 'VO', 'A', 'VW', 'VE')]';
            ELSIF Appeal_Filtr.Taf_Mode = 2
            THEN                                   -- Звернення на призначенні
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Ap_St IN ('S', 'O', 'WD')]';
            ELSIF Appeal_Filtr.Taf_Mode = 3
            THEN                                      -- Опрацьовані звернення
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Ap_St IN ('V', 'X', 'D')]';
            ELSIF Appeal_Filtr.Taf_Mode = 4
            THEN                               -- Звернення передані з ТГ/ЦНАП
                l_Sql :=
                    l_Sql || l_1310 || q'[             AND t.Ap_St IN ('J')]';
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Ap_Dest_Org = f.taf_org]';
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[             AND t.Com_Org in (SELECT z.wu_org FROM ikis_sysweb.v$all_users z where z.wu_id = t.com_wu)]';
            END IF;
        ELSE
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[             AND t.Ap_St = f.taf_Ap_St]';
        END IF;

        IF       Appeal_Filtr.Taf_App_Fn
              || Appeal_Filtr.Taf_App_Mn
              || Appeal_Filtr.Taf_App_Ln
                  IS NOT NULL
           OR Appeal_Filtr.Taf_App_Ndt IS NOT NULL
        THEN
            --        l_sql := l_sql || l_1310 || q'[             AND EXISTS (SELECT /*+ FIRST_ROWS INDEX (Ap_Person IFK_APP_AP idx_app_fn idx_app_mn idx_app_ln)*/ 1 ]';
            --        l_sql := l_sql || l_1310 || q'[                         FROM Uss_Visit.Ap_Person z ]';
            --        l_sql := l_sql || l_1310 || q'[                         WHERE z.App_Ap = t.Ap_Id ]';
            l_Sql :=
                   l_Sql
                || l_1310
                || q'[                               AND z.App_Tp IN ('Z', 'O', 'OP') ]';

            IF Appeal_Filtr.Taf_App_Fn IS NOT NULL
            THEN
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[                               AND Lower(z.App_Fn) LIKE Lower(TRIM(f.taf_App_Fn)) || '%' ]';
            END IF;

            IF Appeal_Filtr.Taf_App_Mn IS NOT NULL
            THEN
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[                               AND Lower(z.App_Mn) LIKE Lower(TRIM(f.taf_App_Mn)) || '%' ]';
            END IF;

            IF Appeal_Filtr.Taf_App_Ln IS NOT NULL
            THEN
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[                               AND Lower(z.App_Ln) LIKE Lower(TRIM(f.taf_App_Ln)) || '%' ]';
            END IF;

            IF     Appeal_Filtr.Taf_App_Ndt IS NOT NULL
               AND Appeal_Filtr.Taf_App_Ndt = 5
            THEN
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[                               AND z.App_Inn = Upper(f.taf_App_Seria_Number) ]';
            ELSIF Appeal_Filtr.Taf_App_Ndt IS NOT NULL
            THEN
                l_Sql :=
                       l_Sql
                    || l_1310
                    || q'[                               AND z.App_Ndt = f.taf_App_Ndt AND z.App_Doc_Num = Upper(f.taf_App_Seria_Number) ]';
            END IF;
        --        l_sql := l_sql || l_1310 || q'[                         ) ]';
        END IF;

        IF (Appeal_Filtr.Taf_Aps_Nst IS NOT NULL)
        THEN
            l_Sql :=
                   l_Sql
                || ' AND EXISTS (select * from ap_service z where z.aps_ap = ap_id and z.history_status = ''A'' and z.aps_nst = F.Taf_Aps_Nst )';
        END IF;

        --Dbms_Output.Put_Line(l_Sql);
        --raise_application_error(-20000, l_sql);

        OPEN p_Res FOR l_Sql;
    END;

    PROCEDURE Get_Appeals_List_Old (
        p_Ap_Num              IN     VARCHAR2,
        p_Ap_Reg_Dt_From      IN     DATE,
        p_Ap_Reg_Dt_To        IN     DATE,
        p_Ap_Src              IN     VARCHAR2,
        p_Ap_St               IN     VARCHAR2,
        p_App_Ln              IN     VARCHAR2,
        p_App_Fn              IN     VARCHAR2,
        p_App_Mn              IN     VARCHAR2,
        p_Ap_Tp               IN     VARCHAR2,
        p_Mode                IN     VARCHAR2,
        p_App_Ndt             IN     NUMBER,
        p_App_Seria_Number    IN     VARCHAR2,
        p_Ap_Create_Dt_From   IN     DATE,
        p_Ap_Create_Dt_To     IN     DATE,
        p_Comorg              IN     NUMBER,       --Орган соціального захисту
        p_Res                    OUT SYS_REFCURSOR)
    IS
        l_Org         NUMBER := Tools.Getcurrorg;
        l_View_Role   NUMBER := Tools.Checkcurruserrole ('W_VT_VIEW');
        l_Org_To      NUMBER := Tools.Getcurrorgto;
        l_Wu          NUMBER := Tools.Getcurrwu;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Appeals_List');

        OPEN p_Res FOR
            SELECT t.*,
                   St.Dic_Sname
                       AS Ap_St_Name,
                   Tp.Dic_Sname
                       AS Ap_Tp_Name,
                   Src.Dic_Sname
                       AS Ap_Src_Name,
                   Uss_Visit.Dnet$verification.Get_Vf_St_Name (
                       Ap_Vf)
                       AS Ap_Vf_Name,
                   (SELECT MAX (
                               CASE
                                   WHEN App_Cnt > 1
                                   THEN
                                          '"'
                                       || Pib
                                       || '" та ще '
                                       || TO_CHAR (App_Cnt - 1)
                                   ELSE
                                       Pib
                               END)
                      FROM (SELECT FIRST_VALUE (
                                          p.App_Ln
                                       || ' '
                                       || p.App_Fn
                                       || ' '
                                       || p.App_Mn)
                                       OVER (ORDER BY p.App_Ln)
                                       AS Pib,
                                   COUNT (*) OVER ()
                                       AS App_Cnt
                              FROM Uss_Visit.Ap_Person p
                             WHERE     p.App_Ap = t.Ap_Id
                                   AND p.App_Tp IN ('Z', 'O')
                                   AND p.History_Status = 'A'))
                       AS App_Pib,
                   Opfu.Org_Code || ' ' || Opfu.Org_Name
                       AS Opfu_Name
              FROM v_Appeal  t
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON (St.Dic_Value = t.Ap_St)
                   JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp ON (Tp.Dic_Value = t.Ap_Tp)
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src
                       ON (Src.Dic_Value = t.Ap_Src)
                   LEFT JOIN v_Opfu Opfu ON t.Com_Org = Opfu.Org_Id
             --LEFT JOIN uss_visit.ap_person p ON (p.app_ap = t.ap_id AND z.app_tp = 'Z')
             WHERE     1 = 1
                   AND ROWNUM < 502
                   AND (p_Comorg IS NULL OR t.Com_Org = p_Comorg)
                   AND t.Ap_Reg_Dt BETWEEN NVL (
                                               p_Ap_Reg_Dt_From,
                                               TO_DATE ('01.01.1970',
                                                        'DD.MM.YYYY'))
                                       AND NVL (
                                               p_Ap_Reg_Dt_To,
                                               TO_DATE ('01.01.9999',
                                                        'DD.MM.YYYY'))
                   AND t.Ap_Create_Dt >=
                       NVL (p_Ap_Create_Dt_From,
                            TO_DATE ('01.01.1970', 'DD.MM.YYYY'))
                   AND t.Ap_Create_Dt <
                       NVL2 (p_Ap_Create_Dt_To,
                             p_Ap_Create_Dt_To + 1,
                             TO_DATE ('01.01.9999', 'DD.MM.YYYY'))
                   AND (   p_Ap_Num IS NULL
                        OR t.Ap_Num LIKE '%' || p_Ap_Num || '%')
                   AND t.Ap_Src = NVL (p_Ap_Src, t.Ap_Src)
                   AND t.Ap_Tp = NVL (p_Ap_Tp, t.Ap_Tp)
                   --AND t.Ap_St = Nvl(p_Ap_St, t.Ap_St)

                   -- #78433, #78968
                   AND (   l_View_Role = 0 AND t.Com_Wu = l_Wu
                        OR     l_View_Role = 1
                           AND (       l_Org_To IN (32, 33)
                                   AND (   t.Com_Org = l_Org
                                        OR Opfu.Org_Org = l_Org /*AND t.ap_st NOT IN ('S', 'V' , 'X')*/
                                        OR t.Com_Wu = l_Wu)
                                OR l_Org_To NOT IN (32, 33)))
                   AND (       p_Ap_St IS NULL
                           AND (   p_Mode = -2
                                OR     p_Mode = -1
                                   AND t.Ap_St IN ('N',
                                                   'J',
                                                   'W',
                                                   'B',
                                                   'FD')
                                OR     p_Mode = 1
                                   AND t.Ap_St IN ('F',
                                                   'VO',
                                                   'A',
                                                   'VW',
                                                   'VE')
                                OR p_Mode = 2 AND t.Ap_St IN ('S', 'O', 'WD')
                                OR p_Mode = 3 AND t.Ap_St IN ('V', 'X')
                                OR 1 = 2)
                        OR t.Ap_St = p_Ap_St)
                   /*         AND (p_app_ln IS NULL OR lower(z.app_ln) LIKE '%'|| lower(TRIM(p_app_ln)) ||'%')
                   AND (p_app_ln IS NULL OR lower(z.app_ln) LIKE '%'|| lower(TRIM(p_app_ln)) ||'%')
                   AND (p_app_ln IS NULL OR lower(z.app_ln) LIKE '%'|| lower(TRIM(p_app_ln)) ||'%')*/
                   AND (   p_App_Ln IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = t.Ap_Id
                                       AND z.App_Tp IN ('Z', 'O', 'OP')
                                       AND LOWER (z.App_Ln) LIKE
                                                  '%'
                                               || LOWER (TRIM (p_App_Ln))
                                               || '%'))
                   AND (   p_App_Fn IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = t.Ap_Id
                                       AND z.App_Tp IN ('Z', 'O', 'OP')
                                       AND LOWER (z.App_Fn) LIKE
                                                  '%'
                                               || LOWER (TRIM (p_App_Fn))
                                               || '%'))
                   AND (   p_App_Mn IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = t.Ap_Id
                                       AND z.App_Tp IN ('Z', 'O', 'OP')
                                       AND LOWER (z.App_Mn) LIKE
                                                  '%'
                                               || LOWER (TRIM (p_App_Mn))
                                               || '%'))
                   AND (   p_App_Ndt IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = t.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND (   (    z.App_Ndt = p_App_Ndt
                                                AND p_App_Ndt != 5
                                                AND z.App_Doc_Num =
                                                    UPPER (
                                                        p_App_Seria_Number))
                                            OR (    p_App_Ndt = 5
                                                AND z.App_Inn =
                                                    UPPER (
                                                        p_App_Seria_Number)))));
    END;

    -- info:   Выбор всех масивов с информацией по идентификатору ОБРАЩЕНИЯ
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Appeal_Card (p_Ap_Id          IN     NUMBER,
                               Main_Cur            OUT SYS_REFCURSOR,
                               Ser_Cur             OUT SYS_REFCURSOR,
                               Pers_Cur            OUT SYS_REFCURSOR,
                               Docs_Cur            OUT SYS_REFCURSOR,
                               Docs_Attr_Cur       OUT SYS_REFCURSOR,
                               Docs_Files_Cur      OUT SYS_REFCURSOR,
                               Pay_Cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Appeal_Card');

        Get_Appeal (p_Ap_Id => p_Ap_Id, p_Res => Main_Cur);
        Get_Services (p_Ap_Id => p_Ap_Id, p_Res => Ser_Cur);
        Get_Persons (p_Ap_Id => p_Ap_Id, p_Res => Pers_Cur);
        Get_Documents (p_Ap_Id => p_Ap_Id, p_Res => Docs_Cur);
        Get_Documents_Attr (p_Ap_Id => p_Ap_Id, p_Res => Docs_Attr_Cur);
        -- #109098
        --Get_Signed_Documents_Files(p_Ap_Id => p_Ap_Id, p_Res => Docs_Files_Cur);
        Get_Documents_Files (p_Ap_Id => p_Ap_Id, p_Res => Docs_Files_Cur);
        Get_Payments (p_Ap_Id => p_Ap_Id, p_Res => Pay_Cur);
    END;

    PROCEDURE Get_Doc_File (p_Apd_Id IN NUMBER, p_File OUT BLOB)
    IS
    BEGIN
        SELECT t.Apd_Tmp_To_Del_File
          INTO p_File
          FROM Ap_Document t
         WHERE t.Apd_Id = p_Apd_Id;

        IF (p_File IS NULL)
        THEN
            Raise_Application_Error (-20000,
                                     'Файл не знайдено або він пустий!');
        END IF;
    END;

    -- info:   Выбор информации об обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Appeal (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Org         NUMBER := Tools.Getcurrorg;
        l_Wu          NUMBER := Tools.Getcurrwu;
        l_Org_To      NUMBER := Tools.Getcurrorgto;
        l_View_Role   NUMBER := Tools.Checkcurruserrole ('W_VT_VIEW');
    BEGIN
        OPEN p_Res FOR
            SELECT a.Ap_Id,
                   a.Ap_Num,
                   a.Ap_Reg_Dt,
                   a.Ap_Create_Dt
                       AS Ap_Create_Dt,
                   a.Ap_Src,
                   a.Ap_St,
                   s.Dic_Name
                       AS Ap_St_Name,
                   a.Com_Org,
                   a.Ap_Is_Second,
                   a.Ap_Vf,
                   Uss_Visit.Dnet$verification.Get_Vf_St_Name (
                       a.Ap_Vf)
                       AS Ap_Vf_Name,
                   a.Com_Wu,
                   a.Ap_Tp,
                   a.Ap_Dest_Org,
                   t.Dic_Name
                       AS Ap_Tp_Name,
                   (SELECT DECODE (COUNT (*), 0, 'F', 'T')
                      FROM Ap_Log l
                     WHERE l.Apl_Ap = a.Ap_Id AND l.Apl_St = 'B')
                       AS Ap_Is_Returned,
                   -- #76942
                   a.Ap_Is_Ext_Process,
                   a.Obi_Ts,
                   Src.Dic_Sname
                       AS Ap_Src_Name,
                   -- #77770
                   CASE
                       -- #88575
                       WHEN     a.Ap_Tp = 'IA'
                            AND a.Ap_Src = 'EHLP'
                            AND EXISTS
                                    (SELECT *
                                       FROM Ap_Service z
                                      WHERE     z.Aps_Nst = 732
                                            AND z.Aps_Ap = a.Ap_Id
                                            AND z.History_Status = 'A')
                       THEN
                           'F'
                       WHEN     l_Org_To IN (33, 35)
                            AND a.ap_st IN ('R', 'RR', 'W')
                       THEN
                           'T'
                       WHEN     l_Org_To IN (33, 35)
                            AND a.ap_st NOT IN ('R', 'RR', 'W')
                       THEN
                           'F'
                       WHEN     l_Org_To NOT IN (33, 35)
                            AND a.ap_st IN ('R', 'RR')
                       THEN
                           'F'
                       WHEN a.Com_Org = l_org
                       THEN
                           'T'
                       WHEN a.com_wu = l_wu
                       THEN
                           'T'
                       /*when p.org_to in (33, 35) and a.ap_dest_org in (l_org) and a.ap_st not in ('R', 'RR') then
                         'T'*/
                       ELSE
                           'F'
                   END
                       AS Ap_Can_Edit,
                   -- #78433
                   Get_Isneed_Income (a.Ap_Id, a.Ap_Tp)
                       AS Is_Show_Income,                            -- #82496
                   CASE
                       WHEN USS_ESR.API$FIND.Is_Esr_Appeal_Reg (a.ap_id) > 0
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
                       AS is_esr_reg,                                -- #94426
                   a.ap_ap_main,
                   CASE
                       WHEN     p.org_to IN (33, 35)
                            AND a.ap_dest_org IN (l_org)
                            AND ap_st IN ('J')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
                       AS Is_Can_Return
              FROM v_Appeal  a
                   JOIN Uss_Ndi.v_Ddn_Ap_St s ON a.Ap_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Tp t ON a.Ap_Tp = t.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src
                       ON (Src.Dic_Value = a.Ap_Src)
                   LEFT JOIN v_Opfu p ON (p.Org_Id = a.Com_Org)
             WHERE     a.Ap_Id = p_Ap_Id
                   -- AND (a.com_org = l_org OR a.com_org != l_org AND a.ap_st NOT IN ('S', 'V', 'X')) -- #78433
                   AND (       l_View_Role = 0
                           AND (   a.Com_Wu = l_Wu
                                OR     p.org_to IN (33, 35)
                                   AND l_org = a.ap_dest_org)
                        OR                                           --#117306
                               l_View_Role = 1
                           AND (   l_Org_To NOT IN (32, 33)
                                OR     l_Org_To IN (32, 33)
                                   AND (   a.Com_Org = l_Org
                                        OR a.Com_Wu = l_Wu
                                        OR     p.org_to IN (33, 35)
                                           AND l_org = a.ap_dest_org
                                        OR p.Org_Org = l_Org) /* AND a.ap_st NOT IN ('S', 'V', 'X')*/
                                                             )) -- #78433, #78968
                                                               ;
    END;

    -- info:   Выбор информации об обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Services (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.Aps_Id,
                   s.Aps_Nst,
                   t.Nst_Name       AS Aps_Nst_Name,
                   t.Nst_Legal_Act,
                   --g.Nsg_Id   AS Aps_Kind,
                   s.Aps_St,
                   St.Dic_Sname     AS Aps_St_Name
              FROM Ap_Service  s
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON s.Aps_Nst = t.Nst_Id
                   /*LEFT JOIN Uss_Ndi.v_Ndi_Service_Group g
                   ON g.Nsg_Id = t.Nst_Nsg*/
                   JOIN Uss_Ndi.v_Ddn_Aps_St St ON (St.Dic_Value = s.Aps_St)
             WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A';
    END;

    -- info:   Выбор информации об персонах обращения
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Persons (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT p.App_Id,
                   p.App_Tp,
                   t.Dic_Name
                       AS App_Tp_Name,
                   p.App_Inn,
                   p.App_Ndt,
                   Dt.Ndt_Name
                       AS Ap_Ndt_Name,
                   p.App_Doc_Num,
                   p.App_Fn,
                   p.App_Mn,
                   p.App_Ln,
                   p.App_Esr_Num,
                   p.App_Gender,
                   g.Dic_Name
                       AS App_Gender_Name,
                   p.App_Vf,
                   Uss_Visit.Dnet$verification.Get_Vf_St_Name (p.App_Vf)
                       AS App_Vf_Name,
                   /*(SELECT MAX(c.Pc_Num)
                                                                                                    FROM Uss_Esr.v_Personalcase c
                                                                                                   WHERE p.App_Sc = c.Pc_Sc
                                                                                                 )*/
                   NULL
                       AS Doc_Eos,
                   p.App_Sc,
                   --#APP_NUM
                   p.App_Num
              FROM Ap_Person  p
                   LEFT JOIN Uss_Ndi.v_Ddn_App_Tp t ON p.App_Tp = t.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type Dt
                       ON p.App_Ndt = Dt.Ndt_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Gender g
                       ON p.App_Gender = g.Dic_Value
             WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A';
    END;

    FUNCTION Get_Ap_Person (p_Ap_Id NUMBER)
        RETURN VARCHAR2
    IS
        l_Pib   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (
                   CASE
                       WHEN App_Cnt > 1
                       THEN
                           '"' || Pib || '" та ще ' || TO_CHAR (App_Cnt - 1)
                       ELSE
                           Pib
                   END)
          INTO l_Pib
          FROM (SELECT FIRST_VALUE (
                           p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn)
                           OVER (ORDER BY p.App_Ln)    AS Pib,
                       COUNT (*) OVER ()               AS App_Cnt
                  FROM Uss_Visit.Ap_Person p
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.App_Tp IN ('Z',
                                        'O',
                                        'OR',
                                        'AF',
                                        'ANF')
                       AND p.History_Status = 'A');

        RETURN l_Pib;
    END;

    FUNCTION Get_Ap_Person_Pib (p_App_Id NUMBER, P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_Pib   VARCHAR2 (2000);
    BEGIN
        SELECT CASE
                   WHEN NVL (p_mode, 0) = 0
                   THEN
                          TOOLS.INIT_CAP (app.app_ln)
                       || ' '
                       || TOOLS.INIT_CAP (app.app_fn)
                       || ' '
                       || TOOLS.INIT_CAP (app.app_mn)
                   WHEN NVL (p_mode, 0) = 1
                   THEN
                          TOOLS.INIT_CAP (app.app_ln)
                       || ' '
                       || UPPER (SUBSTR (app.app_fn, 1, 1))
                       || '. '
                       || UPPER (SUBSTR (app.app_mn, 1, 1))
                       || '. '
               END
          INTO l_Pib
          FROM ap_person app
         WHERE app_id = p_App_Id;

        RETURN l_Pib;
    END;

    FUNCTION Get_Ap_Doc_Pib (p_Ap_Id        NUMBER,
                             p_ln_attr   IN NUMBER,
                             p_fn_attr   IN NUMBER,
                             p_mn_attr   IN NUMBER,
                             P_MODE      IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_Pib   VARCHAR2 (2000);
    BEGIN
        SELECT CASE
                   WHEN NVL (p_mode, 0) = 0
                   THEN
                          TOOLS.INIT_CAP (app.app_ln)
                       || ' '
                       || TOOLS.INIT_CAP (app.app_fn)
                       || ' '
                       || TOOLS.INIT_CAP (app.app_mn)
                   WHEN NVL (p_mode, 0) = 1
                   THEN
                          TOOLS.INIT_CAP (app.app_ln)
                       || ' '
                       || UPPER (SUBSTR (app.app_fn, 1, 1))
                       || '. '
                       || UPPER (SUBSTR (app.app_mn, 1, 1))
                       || '. '
               END
          INTO l_Pib
          FROM (SELECT (SELECT apda.apda_val_string
                          FROM ap_document_attr apda
                         WHERE apda_ap = p_Ap_Id AND apda_nda = p_ln_attr)
                           app_ln,
                       (SELECT apda.apda_val_string
                          FROM ap_document_attr apda
                         WHERE apda_ap = p_Ap_Id AND apda_nda = p_fn_attr)
                           app_fn,
                       (SELECT apda.apda_val_string
                          FROM ap_document_attr apda
                         WHERE apda_ap = p_Ap_Id AND apda_nda = p_mn_attr)
                           app_mn
                  FROM DUAL) app;

        RETURN l_Pib;
    END;

    FUNCTION Get_Ap_Person_Pib_Tp_List (p_Ap_Id       NUMBER,
                                        p_App_Tp   IN VARCHAR2,
                                        P_MODE     IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_Pib   VARCHAR2 (2000);
    BEGIN
        SELECT LISTAGG (pib, '; ') WITHIN GROUP (ORDER BY app_num)
          INTO l_Pib
          FROM (SELECT CASE
                           WHEN NVL (p_mode, 0) = 0
                           THEN
                                  TOOLS.INIT_CAP (app.app_ln)
                               || ' '
                               || TOOLS.INIT_CAP (app.app_fn)
                               || ' '
                               || TOOLS.INIT_CAP (app.app_mn)
                           WHEN NVL (p_mode, 0) = 1
                           THEN
                                  TOOLS.INIT_CAP (app.app_ln)
                               || ' '
                               || UPPER (SUBSTR (app.app_fn, 1, 1))
                               || '. '
                               || UPPER (SUBSTR (app.app_mn, 1, 1))
                               || '. '
                       END    pib,
                       app.app_num
                  FROM ap_person app
                 WHERE app_ap = p_Ap_Id AND app_tp = p_app_tp);

        RETURN l_Pib;
    END;

    FUNCTION Get_Ap_Pib (p_Ap_Id NUMBER)
        RETURN VARCHAR2
    IS
        l_qty   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_qty
          FROM ap_document_attr apda
         WHERE apda_ap = p_Ap_Id AND apda_nda = 1964;

        IF l_qty = 1
        THEN
            RETURN COALESCE (Get_Ap_Doc_Pib (p_Ap_Id,
                                             1964,
                                             1965,
                                             1966),
                             Get_Ap_Person_Pib_Tp_List (p_Ap_Id, 'OS'),
                             Get_Ap_Person_Pib_Tp_List (p_Ap_Id, 'FM'));
        ELSE
            RETURN COALESCE (Get_Ap_Person_Pib_Tp_List (p_Ap_Id, 'OS'),
                             Get_Ap_Person_Pib_Tp_List (p_Ap_Id, 'FM'));
        END IF;
    END;


    FUNCTION Get_Ap_Persons (p_Ap_Id NUMBER)
        RETURN t_Ap_Persons
    IS
        l_Res   t_Ap_Persons;
    BEGIN
        SELECT App_Id,
               App_Tp,
               App_Inn,
               App_Ndt,
               App_Doc_Num,
               App_Fn,
               App_Mn,
               App_Ln,
               App_Esr_Num,
               App_Gender,
               App_Sc,
               App_Num,
               NULL,
               NULL
          BULK COLLECT INTO l_Res
          FROM ap_person app
         WHERE app_ap = p_Ap_Id;

        RETURN l_Res;
    END;


    FUNCTION Doc_Is_Read_Only (p_Apd_Vf IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        IF p_Apd_Vf IS NULL
        THEN
            RETURN 'F';
        END IF;

        SELECT NVL (MAX (CASE WHEN v.Vf_Tp = 'SHR' THEN 'T' END), 'F')
          INTO l_Result
          FROM Verification v
         WHERE v.Vf_Id = p_Apd_Vf;

        RETURN l_Result;
    END;

    -- info:   Выбор информации об документах в обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.Apd_Id,
                   d.Apd_Ndt,
                   t.Ndt_Name_Short
                       AS Apd_Ndt_Name,
                   t.Ndt_Is_Vt_Visible
                       AS Is_Shown,
                   d.Apd_Doc,
                   d.Apd_Vf,
                   Uss_Visit.Dnet$verification.Get_Vf_St_Name (
                       d.Apd_Vf)
                       AS Apd_Vf_Name,
                   d.Apd_App,
                   p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn
                       AS Apd_App_Pib,
                   --серія та номер документа
                   NVL (
                       (SELECT MAX (a.Apda_Val_String)
                          FROM Ap_Document_Attr  a
                               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                   ON     a.Apda_Nda = n.Nda_Id
                                      AND n.Nda_Class = 'DSN'
                         WHERE     a.Apda_Apd = d.Apd_Id
                               AND a.History_Status = 'A'),
                       (SELECT (a.Apda_Val_Int)
                          FROM Ap_Document_Attr  a
                               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                   ON     a.Apda_Nda = n.Nda_Id
                                      AND n.Nda_Id = 1112
                         WHERE     a.Apda_Apd = d.Apd_Id
                               AND d.Apd_Ndt = 730
                               AND a.History_Status = 'A'))
                       AS Apd_Serial,
                   d.Apd_Dh,
                   d.Apd_Dh
                       AS Apd_Dh_Old,
                   d.Apd_Aps,
                   (SELECT MAX (Zt.Nst_Id)
                      FROM Ap_Service  z
                           JOIN Uss_Ndi.v_Ndi_Service_Type Zt
                               ON (Zt.Nst_Id = z.Aps_Nst)
                     WHERE z.Aps_Id = d.Apd_Aps)
                       AS Aps_Nst,
                   CASE
                       WHEN d.Apd_Tmp_To_Del_File IS NOT NULL
                       THEN
                           Tools.Convertb2c (d.Apd_Tmp_To_Del_File)
                   END
                       AS Sign_Info,
                   h.Dh_Dt
                       AS Modify_Dt,
                   Doc_Is_Read_Only (p_Apd_Vf => d.Apd_Vf)
                       AS Is_Read_Only
              FROM Ap_Document  d
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type t
                       ON d.Apd_Ndt = t.Ndt_Id
                   LEFT JOIN Ap_Person p ON d.Apd_App = p.App_Id
                   LEFT JOIN Uss_Doc.v_Doc_Hist h ON d.Apd_Dh = h.Dh_Id
             WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';
    END;

    ----------------------------------------
    -- info:   Выбор информации об документах (атрибуты)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Attr (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT Ada.Apda_Id,
                     Ada.Apda_Ap,
                     Ada.Apda_Apd,
                     Ada.Apda_Nda,
                     Ada.Apda_Val_Int,
                     Ada.Apda_Val_Dt,
                     Ada.Apda_Val_String,
                     Ada.Apda_Val_Id,
                     Ada.Apda_Val_Sum,
                     Nda.Nda_Id,
                     Nda.Nda_Name,
                     Nda.Nda_Is_Key,
                     Nda.Nda_Ndt,
                     Nda.Nda_Order,
                     Nda.Nda_Pt,
                     Nda.Nda_Is_Req,
                     Nda.Nda_Def_Value,
                     Nda.Nda_Can_Edit,
                     Nda.Nda_Need_Show,
                     Pt.Pt_Id,
                     Pt.Pt_Code,
                     Pt.Pt_Name,
                     Pt.Pt_Ndc,
                     Pt.Pt_Edit_Type,
                     Pt.Pt_Data_Type
                FROM Ap_Document d
                     JOIN Ap_Document_Attr Ada
                         ON     Ada.Apda_Apd = d.Apd_Id
                            AND Ada.History_Status = 'A'
                     JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                         ON Nda.Nda_Id = Ada.Apda_Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
               WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A'
            ORDER BY Nda.Nda_Order;
    END;

    PROCEDURE Get_Signed_Documents_Files (p_Ap_Id       NUMBER,
                                          p_Res     OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM Ap_Document
             WHERE Apd_Ap = p_Ap_Id AND History_Status = 'A';

        Uss_Doc.Api$documents.Get_Last_Signed_Attachments (p_Res => p_Res);
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Files (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM Ap_Document
             WHERE Apd_Ap = p_Ap_Id AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        --Uss_Doc.Api$documents.Get_Attachments(p_Doc_Id => NULL, p_Dh_Id => NULL, p_Res => p_Res, p_Params_Mode => 3);
        Uss_Doc.Api$documents.Get_Signed_Attachments (p_Res => p_res);
    END;

    -----------------------------------------------------------------------------------------

    -- info:   Выбор информации об способах выплаты в обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Payments (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT p.Apm_Id,
                   p.Apm_Aps,
                   p.Apm_App,
                   p.Apm_Tp,
                   p.Apm_Index,
                   p.Apm_Kaot,
                   k.Kaot_Name        AS Apm_Kaot_Name,
                   p.Apm_Nb,
                   CASE
                       WHEN SUBSTR (p.Apm_Account, 1, 2) = 'UA'
                       THEN
                           SUBSTR (p.Apm_Account, 3)
                       ELSE
                           p.Apm_Account
                   END                AS Apm_Account,
                   -- #74462
                   p.Apm_Need_Account,
                   p.Apm_Street,
                   p.Apm_Ns,
                      (CASE
                           WHEN Nsrt_Name IS NOT NULL THEN Nsrt_Name || ' '
                           ELSE ''
                       END)
                   || Ns.Ns_Name      AS Apm_Ns_Name,
                   --#74860  2022.01.24
                   p.Apm_Building,
                   p.Apm_Block,
                   p.Apm_Apartment,
                   p.Apm_Dppa,
                   Pa.Dppa_Account    AS Apm_Dppa_Name,
                   Pp.Dpp_Tax_Code    AS Apm_Numident
              FROM Ap_Payment  p
                   LEFT JOIN Uss_Ndi.v_Ndi_Katottg k
                       ON (k.Kaot_Id = p.Apm_Kaot)
                   LEFT JOIN Uss_Ndi.v_Ndi_Street Ns ON (Ns.Ns_Id = p.Apm_Ns)
                   LEFT JOIN Uss_Ndi.v_Ndi_Pay_Person_Acc Pa
                       ON (Pa.Dppa_Id = p.Apm_Dppa)
                   LEFT JOIN Uss_Ndi.v_Ndi_Pay_Person Pp
                       ON (Pp.Dpp_Id = Pa.Dppa_Dpp)
                   LEFT JOIN Uss_Ndi.v_Ndi_Street_Type ON Ns_Nsrt = Nsrt_Id
             WHERE p.Apm_Ap = p_Ap_Id AND p.History_Status = 'A';
    END;

    -- info:   Выбор информации об документах в соц карточке
    -- params:
    -- note:
    PROCEDURE Get_Docs_By_Sc (p_Sc_Id          NUMBER,
                              p_Docs_Cur   OUT SYS_REFCURSOR,
                              Attrs_Cur    OUT SYS_REFCURSOR,
                              Files_Cur    OUT SYS_REFCURSOR)
    IS
        --p_sc_id DECIMAL := 685588;
        l_Dh         DECIMAL;
        l_Document   Uss_Person.Api$socialcard.r_Document;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Docs_By_Sc');

        --отримуємо документи з соц.картики (ті, що зберігаються в електронному архиві)
        --uss_person.api$socialcard.get_sc_documents(p_sc_id => p_sc_id, p_documents => l_documents_cursor);

        Uss_Person.Api$socialcard.Get_Sc_Documents (
            p_Sc_Id       => p_Sc_Id,
            p_Ndc_Id      => 13, --shost 30.03.22: по устной постановке КЕВ, в обращение копируются только документы из категории "Верификация особи"
            p_Documents   => p_Docs_Cur);

        --  DELETE FROM uss_doc.tmp_work_ids WHERE 1 = 1;
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT x_Id FROM Uss_Person.Tmp_Work_Ids;

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (
            p_Doc_Id        => l_Document.Apd_Doc,
            p_Dh_Id         => l_Dh,
            p_Res           => Files_Cur,
            p_Params_Mode   => 3);

        --отримуємо атрибути документу з електронного архіву
        Uss_Doc.Api$documents.Get_Attributes (
            p_Doc_Id        => l_Document.Apd_Doc,
            p_Dh_Id         => l_Dh,
            p_Res           => Attrs_Cur,
            p_Params_Mode   => 3);
    END;

    -- info:   Выбор информации об
    -- params:
    -- note:
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Nda_List');

        OPEN p_Nda_Cur FOR
            SELECT Nda.Nda_Id,
                   NVL (Nda.Nda_Name, Pt.Pt_Name)
                       AS Nda_Name,
                   Nda.Nda_Is_Key,
                   Nda.Nda_Ndt,
                   Nda.Nda_Order,
                   Nda.Nda_Pt,
                   Nda.Nda_Is_Req,
                   Nda.Nda_Def_Value,
                   Nda.Nda_Can_Edit,
                   Nda.Nda_Need_Show,
                   Nda.Nda_Class,
                   Pt.Pt_Id,
                   Pt.Pt_Code,
                   Pt.Pt_Name,
                   Pt.Pt_Ndc,
                   Pt.Pt_Edit_Type,
                   Pt.Pt_Data_Type,
                   Ndc.Ndc_Code,
                   NVL (Nda.Nda_Nng, -1)
                       AS Nda_Nng,
                   (SELECT MAX (z.Nnv_Condition)
                      FROM Uss_Ndi.v_Ndi_Nda_Validation z
                     WHERE z.Nnv_Nda = Nda.Nda_Id AND z.Nnv_Tp = 'MASK')
                       AS Mask_Setup,
                   (SELECT MAX (z.Nnv_Condition)
                      FROM Uss_Ndi.v_Ndi_Nda_Validation z
                     WHERE z.Nnv_Nda = Nda.Nda_Id AND z.Nnv_Tp = 'KEY_PRESS')
                       AS Key_Press_Setup,
                   NVL (
                       (SELECT MAX (z.Nnv_Condition)
                          FROM Uss_Ndi.v_Ndi_Nda_Validation z
                         WHERE     z.Nnv_Nda = Nda.Nda_Id
                               AND z.Nnv_Tp = 'MAXLENGTH'),
                       4000)
                       AS Maxlength,
                   (SELECT NVL (MAX (z.Nnv_Condition), 'F')
                      FROM Uss_Ndi.v_Ndi_Nda_Validation z
                     WHERE z.Nnv_Nda = Nda.Nda_Id AND z.Nnv_Tp = 'KEY_PASTE')
                       AS Key_Paste_Setup,
                   (SELECT COALESCE (MAX (z.Nnv_Condition), 'F')
                      FROM Uss_Ndi.v_Ndi_Nda_Validation z
                     WHERE z.Nnv_Nda = Nda.Nda_Id AND z.Nnv_Tp = 'RESET')
                       AS Can_Reset
              FROM Uss_Ndi.v_Ndi_Document_Attr  Nda
                   JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                   LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config Ndc
                       ON Ndc.Ndc_Id = Pt.Pt_Ndc
             WHERE Nda_Ndt = p_Ndt_Id;
    END;

    ---------------------------------------------------------------------
    --                   ДОВІДНИК ГРУП АТРИБУТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Nng_List');

        OPEN p_Nng_Cur FOR
            SELECT -1                      AS Nng_Id,
                   'Основні параметри'     AS Nng_Name,
                   'T'                     AS Nng_Open_By_Def,
                   0                       AS Nng_Order
              FROM DUAL
            UNION ALL
            SELECT g.Nng_Id,
                   g.Nng_Name,
                   g.Nng_Open_By_Def,
                   g.Nng_Order
              FROM Uss_Ndi.v_Ndi_Nda_Group g
            ORDER BY Nng_Order;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ ПОСЛУГ
    ---------------------------------------------------------------------
    PROCEDURE Save_Services (p_Ap_Id         IN     NUMBER,
                             p_Ap_Services   IN OUT t_Ap_Services)
    IS
        l_Ret   NUMBER;
    BEGIN
        FOR i IN 1 .. p_Ap_Services.COUNT
        LOOP
            IF p_Ap_Services (i).Deleted = 1 AND p_Ap_Services (i).Aps_Id > 0
            THEN
                --Видаляємо повязані с послугою способи виплат
                Api$appeal.Delete_Service_Payments (
                    p_Aps_Id   => p_Ap_Services (i).Aps_Id);
                --Видаляємо послугу
                Api$appeal.Delete_Service (p_Id => p_Ap_Services (i).Aps_Id);
            ELSE
                Api$appeal.Save_Service (
                    p_Aps_Id    => p_Ap_Services (i).Aps_Id,
                    p_Aps_Nst   => p_Ap_Services (i).Aps_Nst,
                    p_Aps_Ap    => p_Ap_Id,
                    p_Aps_St    => p_Ap_Services (i).Aps_St,
                    p_New_Id    => p_Ap_Services (i).New_Id);
            END IF;
        END LOOP;

        -- Для відрахування не повинно бути, коли немає послуги. Тому додамо запис без id послуги.
        FOR Rec
            IN (SELECT Ap.Ap_Id
                  FROM Appeal Ap
                 WHERE     Ap.Ap_Id = p_Ap_Id
                       AND Ap.Ap_Tp = 'A'
                       AND NOT EXISTS
                               (SELECT *
                                  FROM Ap_Service Aps
                                 WHERE     Aps.Aps_Ap = Ap.Ap_Id
                                       AND Aps.History_Status = 'A'--AND Aps.Aps_Nst IS NULL
                                                                   ))
        LOOP
            Api$appeal.Save_Service (p_Aps_Id    => -1,
                                     p_Aps_Nst   => NULL,
                                     p_Aps_Ap    => p_Ap_Id,
                                     p_Aps_St    => 'R',
                                     p_New_Id    => l_Ret);
        END LOOP;
    /*
      FOR Rec IN (SELECT Aps.Aps_Id
                    FROM Appeal Ap
                    LEFT JOIN Ap_Service Aps
                      ON Aps.Aps_Ap = Ap.Ap_Id
                         AND Aps.History_Status = 'A'
                   WHERE Ap.Ap_Tp = 'A'
                         AND Aps.Aps_Id IS NULL
                   FETCH FIRST ROW ONLY)
      LOOP
        Api$appeal.Save_Service(p_Aps_Id => -1, p_Aps_Nst => NULL, p_Aps_Ap => p_Ap_Id, p_Aps_St => 'R', p_New_Id => Rec.Aps_Id);
      END LOOP;
    */
    END;

    ---------------------------------------------------------------------
    --                 ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
    ---------------------------------------------------------------------
    PROCEDURE Save_Payments (p_Ap_Id         IN     NUMBER,
                             p_Ap_Payments   IN OUT t_Ap_Payments,
                             p_Ap_Services   IN     t_Ap_Services,
                             p_Ap_Persons    IN     t_Ap_Persons)
    IS
        l_New_Id   NUMBER;
    BEGIN
        FOR Rec
            IN (SELECT p.*,
                       GREATEST (s.Aps_Id, NVL (s.New_Id, -1))      AS Aps_Id,
                       GREATEST (Pr.App_Id, NVL (Pr.New_Id, -1))    AS App_Id
                  FROM TABLE (p_Ap_Payments)  p
                       LEFT JOIN TABLE (p_Ap_Services) s
                           ON p.Apm_Aps = s.Aps_Id
                       LEFT JOIN TABLE (p_Ap_Persons) Pr
                           ON p.Apm_App = Pr.App_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apm_Id > 0
            THEN
                --Видаляємо спосіб виплати
                Api$appeal.Delete_Payment (p_Id => Rec.Apm_Id);
            ELSE
                --#78157 20220622
                IF Rec.Apm_Nb IS NULL AND Rec.Apm_Account IS NOT NULL
                THEN
                    SELECT MAX (b.Nb_Id)
                      INTO Rec.Apm_Nb
                      FROM Uss_Ndi.v_Ndi_Bank b
                     WHERE     b.Nb_Mfo =
                               REGEXP_SUBSTR ('UA' || Rec.Apm_Account,
                                              '[0-9]{6}',
                                              5)
                           AND b.History_Status = 'A';
                END IF;

                Api$appeal.Save_Payment (
                    p_Apm_Id             => Rec.Apm_Id,
                    p_Apm_Ap             => p_Ap_Id,
                    p_Apm_Aps            => Rec.Aps_Id,
                    p_Apm_App            => Rec.App_Id,
                    p_Apm_Tp             => Rec.Apm_Tp,
                    p_Apm_Index          => Rec.Apm_Index,
                    p_Apm_Kaot           => Rec.Apm_Kaot,
                    p_Apm_Nb             => Rec.Apm_Nb,
                    p_Apm_Account        =>
                        CASE
                            WHEN Rec.Apm_Account IS NOT NULL
                            THEN
                                'UA' || Rec.Apm_Account
                            ELSE
                                Rec.Apm_Account
                        END,                                         -- #74462
                    p_Apm_Need_Account   => Rec.Apm_Need_Account,
                    p_Apm_Street         => Rec.Apm_Street,
                    p_Apm_Ns             => Rec.Apm_Ns,
                    p_Apm_Building       => Rec.Apm_Building,
                    p_Apm_Block          => Rec.Apm_Block,
                    p_Apm_Apartment      => Rec.Apm_Apartment,
                    p_Apm_Dppa           => Rec.Apm_Dppa,
                    p_New_Id             => l_New_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --             ЗБЕРЕЖЕННЯ АТРИБУТІВ ДОКУМЕНТА
    ---------------------------------------------------------------------
    PROCEDURE Save_Document_Attrs (p_Ap_Id       IN     NUMBER,
                                   p_Apd_Id      IN     NUMBER,
                                   p_Apd_Attrs   IN OUT t_Ap_Document_Attrs)
    IS
        l_New_Id   NUMBER;
        l_Apd_Ap   Ap_Document.Apd_Ap%TYPE;
    BEGIN
        SELECT Apd_Ap
          INTO l_Apd_Ap
          FROM Ap_Document
         WHERE Apd_Id = p_Apd_Id;

        IF p_Ap_Id <> l_Apd_Ap
        THEN
            Raise_Application_Error (
                -20000,
                'Ід зверення не співпадає з ід-ом документу - помилка збереження!');
        END IF;

        FOR Rec
            IN (SELECT a.Deleted,
                       NVL (a.Apda_Id, Da.Apda_Id)     AS Apda_Id,
                       a.Apda_Nda,
                       a.Apda_Val_Int                  AS Val_Int,
                       a.Apda_Val_Dt                   AS Val_Dt,
                       a.Apda_Val_String               AS Val_String,
                       a.Apda_Val_Id                   AS Val_Id,
                       a.Apda_Val_Sum                  AS Val_Sum
                  FROM TABLE (p_Apd_Attrs)  a
                       LEFT JOIN Ap_Document_Attr Da
                           ON     Da.Apda_Apd = p_Apd_Id
                              AND a.Apda_Nda = Da.Apda_Nda
                              AND Da.History_Status = 'A')
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apda_Id > 0
            THEN
                --Видаляємо атрибут
                Api$appeal.Delete_Document_Attr (p_Id => Rec.Apda_Id);
            ELSE
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => Rec.Apda_Id,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => p_Apd_Id,
                    p_Apda_Nda          => Rec.Apda_Nda,
                    p_Apda_Val_Int      => Rec.Val_Int,
                    p_Apda_Val_Dt       => Rec.Val_Dt,
                    p_Apda_Val_String   => Rec.Val_String,
                    p_Apda_Val_Id       => Rec.Val_Id,
                    p_Apda_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_New_Id);
            END IF;
        END LOOP;
    END;

    FUNCTION Get_Nda_Id (p_Ndt_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Nda_Id   NUMBER;
    BEGIN
        SELECT MAX (a.Nda_Id)
          INTO l_Nda_Id
          FROM Uss_Ndi.v_Ndi_Document_Attr a
         WHERE a.Nda_Ndt = p_Ndt_Id AND a.Nda_Class = p_Nda_Class;

        RETURN l_Nda_Id;
    END;

    ---------------------------------------------------------------------
    --        Отримання переліку відсутніх обов’язкових документів
    --            (викликається пілся "збереження" анкети)
    ---------------------------------------------------------------------
    PROCEDURE Get_Missing_Docs (
        p_App_Services      IN     VARCHAR2, --Список типів послуг, що прив’язані до учасника
        p_Ap_Tp             IN     VARCHAR2,
        p_App_Tp            IN     Ap_Person.App_Tp%TYPE,
        p_App_Sc            IN     NUMBER,
        p_App_Ndt           IN     NUMBER,
        p_App_Doc_Num       IN     VARCHAR2,
        p_App_Inn           IN     VARCHAR2,
        p_App_Ln            IN     VARCHAR2,
        p_App_Fn            IN     VARCHAR2,
        p_App_Mn            IN     VARCHAR2,
        p_Ankt_Attributes   IN     CLOB,
        p_App_Documents     IN     VARCHAR2, --Список типів документів, що прив’язані до учасника
        p_Birth_Dt          IN     DATE,
        p_Docs_Cur             OUT SYS_REFCURSOR,
        p_Attrs_Cur            OUT SYS_REFCURSOR,
        p_Files_Cur            OUT SYS_REFCURSOR)
    IS
        l_App_Services      t_Ids;
        l_App_Documents     t_Ids := t_Ids ();
        l_Ankt_Attributes   t_Ap_Document_Attrs := t_Ap_Document_Attrs ();
        l_Missing_Doc       t_Missing_Doc;
        l_Com_Wu            NUMBER;
        l_Tmp_Attrs         t_Tmp_Doc_Attrs;
        l_Birth_Dt          DATE := p_Birth_Dt;

        PROCEDURE Add_Tmp_Attr (p_Doc_Id      IN NUMBER,
                                p_Dh_Id       IN NUMBER,
                                p_Ndt_Id      IN NUMBER,
                                p_Nda_Class   IN VARCHAR2,
                                p_Val_Str     IN VARCHAR2)
        IS
            l_Tmp_Attr   r_Tmp_Doc_Attr;
        BEGIN
            IF p_Val_Str IS NULL
            THEN
                RETURN;
            END IF;

            l_Tmp_Attr.Apda_Nda := Get_Nda_Id (p_Ndt_Id, p_Nda_Class);

            IF l_Tmp_Attr.Apda_Nda IS NULL
            THEN
                RETURN;
            END IF;

            l_Tmp_Attr.Doc_Id := p_Doc_Id;
            l_Tmp_Attr.Dh_Id := p_Dh_Id;
            l_Tmp_Attr.Apda_Val_String := p_Val_Str;
            l_Tmp_Attrs.EXTEND ();
            l_Tmp_Attrs (l_Tmp_Attrs.COUNT) := l_Tmp_Attr;
        END;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Missing_Docs');

        IF p_App_Tp IS NULL
        THEN
            raise_application_error (-20000, 'Не вказано тип учасника!');
        END IF;

        IF (p_App_Sc IS NOT NULL AND l_Birth_Dt IS NULL)
        THEN
            l_Birth_Dt := Uss_Person.Api$sc_Tools.Get_Birthdate (p_App_Sc);
        END IF;

        --Парсимо перелік типів послуг учасника
        SELECT TO_NUMBER (COLUMN_VALUE)
          BULK COLLECT INTO l_App_Services
          FROM XMLTABLE (RTRIM (p_App_Services, ','));

        --Парсимо перелік типів документів учасника
        IF p_App_Documents IS NOT NULL
        THEN
            SELECT TO_NUMBER (COLUMN_VALUE)
              BULK COLLECT INTO l_App_Documents
              FROM XMLTABLE (RTRIM (p_App_Documents, ','));
        END IF;

        --Парсимо атрибути анкети
        IF DBMS_LOB.Getlength (p_Ankt_Attributes) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Document_Attrs',
                                             TRUE)
                BULK COLLECT INTO l_Ankt_Attributes
                USING p_Ankt_Attributes;
        END IF;

        --Отримуємо відсутні документи по типу послуги + типу учасника + ознакам в анкеті
        WITH
            Missing_Docs
            AS
                (SELECT COALESCE (
                            --Якщо вказано тип документа в реквізитах учасника
                            CASE
                                WHEN p_App_Ndt IS NOT NULL
                                THEN
                                    --обираємо його, якщо він є в переліку альтернативних документів
                                     (SELECT MAX (s.Nns_Ndt)
                                        FROM Uss_Ndi.v_Ndi_Nndc_Setup s
                                       WHERE     s.Nns_Nndc = c.Nndc_Id
                                             AND s.Nns_Tp = 'AD'
                                             AND s.History_Status = 'A'
                                             AND s.Nns_Ndt = p_App_Ndt)
                            END,
                            --Інакше обираємо конкретний тип документа
                            c.Nndc_Ndt,
                            --Або перший документ в рамках категорії
                             (  SELECT t.Ndt_Id
                                  FROM Uss_Ndi.v_Ndi_Document_Type t
                                 WHERE t.Ndt_Ndc = c.Nndc_Ndc
                              ORDER BY t.Ndt_Order
                                 FETCH FIRST ROW ONLY))    AS Nndc_Ndt
                   FROM Uss_Ndi.v_Ndi_Nst_Doc_Config  c
                        LEFT JOIN uss_ndi.v_ndi_document_attr atr
                            ON (atr.nda_id = c.nndc_nda)
                        LEFT JOIN uss_ndi.v_ndi_param_type pt
                            ON (pt.pt_id = atr.nda_pt)
                        LEFT JOIN TABLE (l_App_Documents) d
                            ON    c.Nndc_Ndt = d.Id
                               OR EXISTS
                                      (SELECT NULL
                                         FROM Uss_Ndi.v_Ndi_Nndc_Setup Nns
                                        WHERE     Nns_Nndc = c.Nndc_Id
                                              AND Nns_Ndt = d.Id
                                              AND Nns_Tp = 'AD'
                                              AND Nns.History_Status = 'A')
                               OR (    c.Nndc_Ndc IS NOT NULL
                                   AND EXISTS
                                           (SELECT NULL
                                              FROM Uss_Ndi.v_Ndi_Document_Type
                                                   Dt
                                             WHERE     Dt.Ndt_Ndc =
                                                       c.Nndc_Ndc
                                                   AND Dt.Ndt_Id = d.Id))
                  WHERE     --Послуги
                            (   c.Nndc_Nst IN
                                    (SELECT s.Id
                                       FROM TABLE (l_App_Services) s)
                             OR c.Nndc_Nst IS NULL)
                        --Тип учасника
                        AND (   c.Nndc_App_Tp = p_App_Tp
                             OR c.Nndc_App_Tp IS NULL)
                        --Ознаки та інщі атрибути
                        AND (   c.Nndc_Nda IS NULL
                             OR EXISTS
                                    (SELECT NULL
                                       FROM TABLE (l_Ankt_Attributes) a
                                      WHERE     c.Nndc_Nda = a.Apda_Nda
                                            AND (       a.Apda_Val_String
                                                            IS NULL
                                                    AND c.Nndc_Val_String
                                                            IS NULL
                                                 OR a.Apda_Val_String =
                                                    c.Nndc_Val_String
                                                 OR     pt.pt_edit_type IN
                                                            ('DDLM')
                                                    AND c.Nndc_Val_String IN
                                                            (    SELECT REGEXP_SUBSTR (
                                                                            text,
                                                                            '[^(\,)]+',
                                                                            1,
                                                                            LEVEL)    AS val
                                                                   FROM (SELECT a.Apda_Val_String    AS text
                                                                           FROM DUAL)
                                                             CONNECT BY LENGTH (
                                                                            REGEXP_SUBSTR (
                                                                                text,
                                                                                '[^(\,)]+',
                                                                                1,
                                                                                LEVEL)) >
                                                                        0)))
                             -- #91657: CHECK_DT - ознака перевірки заповнення дати
                             OR EXISTS
                                    (SELECT NULL
                                       FROM TABLE (l_Ankt_Attributes)  a
                                            JOIN Uss_Ndi.v_Ndi_Nndc_Setup s
                                                ON (s.Nns_Nndc = c.Nndc_Id)
                                      WHERE     c.Nndc_Nda = a.Apda_Nda
                                            AND s.Nns_Tp = 'CHECK_DT'
                                            AND s.History_Status = 'A'
                                            AND a.Apda_Val_Dt IS NOT NULL)-- #91657: CHECK_DT_XX - ознака перевірки періоду між поточною датою і вказаною (ХХ років)
                                                                          -- поки прибрав бо задачу уточнюють
                                                                          /* OR EXISTS
                                                                          (SELECT NULL
                                                                             FROM (SELECT Apda_Val_Dt, to_number(REPLACE(s.nns_tp, 'CHECK_DT_', '')) AS years
                                                                                    FROM TABLE(l_Ankt_Attributes) a
                                                                                    JOIN Uss_Ndi.v_Ndi_Nndc_Setup s ON (s.nns_nndc = c.nndc_id)
                                                                                   WHERE c.Nndc_Nda = a.Apda_Nda
                                                                                     AND s.nns_tp LIKE 'CHECK_DT%'
                                                                                     AND s.history_status = 'A'
                                                                                     AND a.Apda_Val_Dt IS NOT NULL
                                                                                  )
                                                                            WHERE (months_between(SYSDATE, apda_val_dt) / 12) >= years)*/
                                                                          )
                        AND c.History_Status = 'A'
                        AND c.Nndc_Is_Req = 'T'
                        AND (c.Nndc_Ap_Tp = p_Ap_Tp OR c.Nndc_Ap_Tp = '*')
                        AND d.Id IS NULL)
        SELECT DISTINCT Nndc_Ndt, d.Scd_Doc, d.Scd_Dh
          BULK COLLECT INTO l_Missing_Doc
          FROM Missing_Docs
               LEFT JOIN Uss_Person.v_Sc_Document d
                   ON     d.Scd_Sc = p_App_Sc
                      AND d.Scd_Ndt = Nndc_Ndt
                      AND d.Scd_St = '1'
                      AND d.Scd_Dh IS NOT NULL;


        -- #91657:  Додавання обов'язкового документу "Посвідчення дитини з багатодітної сім’ї" (NDT_ID 10107)
        -- для учасників звернення за типом "Утиманець" має бути тільки для осіб віком від 6 років.
        FOR Xx
            IN (SELECT d.Scd_Doc, d.Scd_Dh, 10107 AS Ndt_Id
                  FROM TABLE (l_App_Services)  s
                       LEFT JOIN Uss_Person.v_Sc_Document d
                           ON (    d.Scd_Sc = p_App_Sc
                               AND d.Scd_Ndt = 10107
                               AND d.Scd_St = '1')
                 WHERE     s.Id = 862
                       AND p_Ap_Tp = 'V'
                       AND p_App_Tp = 'FP'
                       AND l_Birth_Dt IS NOT NULL
                       AND FLOOR (MONTHS_BETWEEN (SYSDATE, l_Birth_Dt) / 12) >
                           6
                       AND NOT EXISTS
                               (SELECT *
                                  FROM TABLE (l_App_Documents) d
                                 WHERE d.Id = 10107))
        LOOP
            l_Missing_Doc.EXTEND ();
            l_Missing_Doc (l_Missing_Doc.COUNT).Ndt_Id := Xx.Ndt_Id;
            l_Missing_Doc (l_Missing_Doc.COUNT).Doc_Id := Xx.Scd_Doc;
            l_Missing_Doc (l_Missing_Doc.COUNT).Dh_Id := Xx.Scd_Dh;
        END LOOP;

        --#98075: Додавання обов'язкового документу "Постанова про звернення стягнення аліментів" (NDT_ID 603)
        --заповнені атрибути Учасника звернення, автоматично додавати документи
        IF p_Ap_Tp = 'A' AND p_App_Tp = 'O'
        THEN
            FOR c
                IN (SELECT DECODE (p_App_Inn, NULL, 10117, 5)     Ndt_Id,
                           d.Scd_Doc,
                           d.Scd_Dh
                      FROM TABLE (l_App_Services)  s
                           LEFT JOIN Uss_Person.v_Sc_Document d
                               ON     d.Scd_Sc = p_App_Sc
                                  AND d.Scd_Ndt =
                                      DECODE (p_App_Inn, NULL, 10117, 5)
                                  AND d.Scd_St = '1'
                                  AND d.Scd_Dh IS NOT NULL
                     WHERE     s.Id IN (603)
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM TABLE (l_App_Documents) d
                                     WHERE d.Id =
                                           DECODE (p_App_Inn, NULL, 10117, 5)))
            LOOP
                l_Missing_Doc.EXTEND ();
                l_Missing_Doc (l_Missing_Doc.COUNT).Ndt_Id := c.Ndt_Id;
                l_Missing_Doc (l_Missing_Doc.COUNT).Doc_Id := c.Scd_Doc;
                l_Missing_Doc (l_Missing_Doc.COUNT).Dh_Id := c.Scd_Dh;
            END LOOP;
        END IF;


        l_Com_Wu := Tools.Getcurrwu;
        l_Tmp_Attrs := t_Tmp_Doc_Attrs ();

        --Регистрируем документы
        FOR i IN 1 .. l_Missing_Doc.COUNT
        LOOP
            IF l_Missing_Doc (i).Dh_Id IS NULL
            THEN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => l_Missing_Doc (i).Ndt_Id,
                    p_Doc_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_New_Id          => l_Missing_Doc (i).Doc_Id);

                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Missing_Doc (i).Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => NULL,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => l_Com_Wu,
                    p_Dh_Src         => Api$appeal.c_Src_Vst,
                    p_New_Id         => l_Missing_Doc (i).Dh_Id);

                --Якщо вказано не вистачає документа/ІПН який вказали в реквізитах учасника
                --Автоматично заповнюємо атрибут з номером цього документа
                IF     l_Missing_Doc (i).Ndt_Id = p_App_Ndt
                   AND p_App_Doc_Num IS NOT NULL
                THEN
                    Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                                  l_Missing_Doc (i).Dh_Id,
                                  l_Missing_Doc (i).Ndt_Id,
                                  'DSN',
                                  p_App_Doc_Num);
                ELSIF l_Missing_Doc (i).Ndt_Id = 5 AND p_App_Inn IS NOT NULL
                THEN
                    Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                                  l_Missing_Doc (i).Dh_Id,
                                  l_Missing_Doc (i).Ndt_Id,
                                  'DSN',
                                  p_App_Inn);
                END IF;

                Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                              l_Missing_Doc (i).Dh_Id,
                              l_Missing_Doc (i).Ndt_Id,
                              'RNOKPP',
                              p_App_Inn);
                Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                              l_Missing_Doc (i).Dh_Id,
                              l_Missing_Doc (i).Ndt_Id,
                              'LN',
                              p_App_Ln);
                Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                              l_Missing_Doc (i).Dh_Id,
                              l_Missing_Doc (i).Ndt_Id,
                              'FN',
                              p_App_Fn);
                Add_Tmp_Attr (l_Missing_Doc (i).Doc_Id,
                              l_Missing_Doc (i).Dh_Id,
                              l_Missing_Doc (i).Ndt_Id,
                              'MN',
                              p_App_Mn);

                -- #97549,  #97574
                IF (NOT (    INSTR (p_App_Services, '251') > 0
                         AND l_Missing_Doc (i).Ndt_Id IN (37, 114)
                         AND p_App_Tp = 'Z'))
                THEN
                    Add_Tmp_Attr (
                        l_Missing_Doc (i).Doc_Id,
                        l_Missing_Doc (i).Dh_Id,
                        l_Missing_Doc (i).Ndt_Id,
                        'PIB',
                        p_App_Ln || ' ' || p_App_Fn || ' ' || p_App_Mn);
                END IF;

                IF (NOT (INSTR (p_App_Services, '267') > 0))
                THEN
                    Add_Tmp_Attr (
                        l_Missing_Doc (i).Doc_Id,
                        l_Missing_Doc (i).Dh_Id,
                        l_Missing_Doc (i).Ndt_Id,
                        'DPIB',
                        p_App_Ln || ' ' || p_App_Fn || ' ' || p_App_Mn);
                END IF;

                IF (p_App_Tp = 'FP')
                THEN
                    Add_Tmp_Attr (
                        l_Missing_Doc (i).Doc_Id,
                        l_Missing_Doc (i).Dh_Id,
                        l_Missing_Doc (i).Ndt_Id,
                        'FP_PIB',
                        p_App_Ln || ' ' || p_App_Fn || ' ' || p_App_Mn);
                ELSIF (p_App_Tp = 'Z')
                THEN
                    Add_Tmp_Attr (
                        l_Missing_Doc (i).Doc_Id,
                        l_Missing_Doc (i).Dh_Id,
                        l_Missing_Doc (i).Ndt_Id,
                        'Z_PIB',
                        p_App_Ln || ' ' || p_App_Fn || ' ' || p_App_Mn);
                END IF;
            END IF;
        END LOOP;

        OPEN p_Docs_Cur FOR
            SELECT d.Ndt_Id              AS Apd_Ndt,
                   Dt.Ndt_Name_Short     AS Apd_Ndt_Name,
                   d.Doc_Id              AS Apd_Doc,
                   d.Dh_Id               AS Apd_Dh
              FROM TABLE (l_Missing_Doc)  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type Dt
                       ON d.Ndt_Id = Dt.Ndt_Id;

        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        FORALL i IN INDICES OF l_Missing_Doc
            INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
                 VALUES (l_Missing_Doc (i).Dh_Id);

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Files_Cur,
                                               p_Params_Mode   => 3);

        OPEN p_Attrs_Cur FOR
              --отримуємо атрибути документу з електронного архіву
              SELECT *
                FROM (SELECT /*+ index(h IFK_DA2H_DH)*/
                             h.Dh_Doc          AS Doc_Id,
                             Da_Nda            AS Apda_Nda,
                             Da_Val_String     AS Apda_Val_String,
                             Da_Val_Int        AS Apda_Val_Int,
                             Da_Val_Dt         AS Apda_Val_Dt,
                             Da_Val_Id         AS Apda_Val_Id,
                             Da_Val_Sum        AS Apda_Val_Sum,
                             h.Dh_Id           AS Dh_Id
                        FROM Uss_Doc.Tmp_Work_Ids i
                             JOIN Uss_Doc.v_Doc_Hist h ON i.x_Id = h.Dh_Id
                             JOIN Uss_Doc.v_Doc_Attr2hist Ah
                                 ON h.Dh_Id = Ah.Da2h_Dh
                             JOIN Uss_Doc.v_Doc_Attributes a
                                 ON Ah.Da2h_Da = a.Da_Id
                      UNION ALL
                      --Та авто-згернеровані атрибути
                      SELECT Doc_Id,
                             Apda_Nda,
                             Apda_Val_String,
                             Apda_Val_Int,
                             Apda_Val_Dt,
                             Apda_Val_Id,
                             Apda_Val_Sum,
                             Dh_Id
                        FROM TABLE (l_Tmp_Attrs))
                     JOIN Uss_Ndi.v_Ndi_Document_Attr n ON Apda_Nda = n.Nda_Id
            ORDER BY n.Nda_Order;
    --Uss_Doc.Api$documents.Get_Attributes(p_Doc_Id => NULL, p_Dh_Id => NULL, p_Res => p_Attrs_Cur, p_Params_Mode => 3);
    END;

    ---------------------------------------------------------------------
    --                   ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Save_Documents (p_Ap_Id          IN     NUMBER,
                              p_Ap_Documents   IN OUT t_Ap_Documents,
                              p_Ap_Persons     IN     t_Ap_Persons,
                              p_Ap_Services    IN     t_Ap_Services,
                              p_Com_Wu         IN     NUMBER)
    IS
        l_Ap_Document_Attrs   t_Ap_Document_Attrs;
    BEGIN
        FOR Rec
            IN (  SELECT d.*,
                         GREATEST (p.App_Id, NVL (p.New_Id, -1))
                             AS App_Id,
                         GREATEST (s.Aps_Id, NVL (s.New_Id, -1))
                             AS Aps_Id,
                         CASE
                             WHEN     Ad.Apd_Id IS NOT NULL
                                  AND d.Apd_Ndt <> Ad.Apd_Ndt
                             THEN
                                 1
                             ELSE
                                 0
                         END
                             AS Ndt_Changed,
                         p.App_Tp,
                         Doc_Is_Read_Only (p_Apd_Vf => Ad.Apd_Vf)
                             AS Is_Read_Only
                    FROM TABLE (p_Ap_Documents) d
                         LEFT JOIN TABLE (p_Ap_Persons) p
                             ON d.Apd_App = p.App_Id
                         LEFT JOIN TABLE (p_Ap_Services) s
                             ON d.Apd_Aps = s.Aps_Id
                         LEFT JOIN Ap_Document Ad ON d.Apd_Id = Ad.Apd_Id
                ORDER BY CASE
                             --Обрабатываем заяву в конце, т.к. атрибуты заявы сверяеются с атрибутами других документов
                             WHEN d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Zayv
                             THEN
                                 1
                             ELSE
                                 0
                         END)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apd_Id > 0
            THEN
                --Видаляємо документ
                --raise_application_error(-20000, 'YAHOO');
                Api$appeal.Delete_Document (p_Id => Rec.Apd_Id);
            ELSIF Rec.Apd_Id > 0 AND Rec.Is_Read_Only = 'T'
            THEN
                --У документах "тільки для читання" може бути змінено лише посилання на учасника
                UPDATE Ap_Document d
                   SET d.Apd_Ap = p_Ap_Id, d.Apd_App = Rec.App_Id
                 WHERE d.Apd_Id = Rec.Apd_Id;

                UPDATE Ap_Document_Attr a
                   SET a.Apda_Ap = p_Ap_Id
                 WHERE a.Apda_Apd = Rec.Apd_Id;
            ELSE
                IF Rec.Attributes IS NOT NULL
                THEN
                    --Парсимо атрибути документа
                    EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                                     't_Ap_Document_Attrs',
                                                     TRUE,
                                                     FALSE,
                                                     FALSE)
                        BULK COLLECT INTO l_Ap_Document_Attrs
                        USING Rec.Attributes;
                END IF;

                --Зберігаємо документ
                Api$appeal.Save_Document (
                    p_Apd_Id    => Rec.Apd_Id,
                    p_Apd_Ap    => p_Ap_Id,
                    p_Apd_Ndt   => Rec.Apd_Ndt,
                    p_Apd_Doc   => Rec.Apd_Doc,
                    p_Apd_Vf    => NULL,
                    p_Apd_App   => Rec.App_Id,
                    p_New_Id    => Rec.Apd_Id,
                    p_Com_Wu    => p_Com_Wu,
                    p_Apd_Dh    => Rec.Apd_Dh,
                    p_Apd_Aps   => Rec.Aps_Id,
                    p_Apd_Tmp_To_Del_File   =>
                        CASE
                            WHEN Rec.Sign_Info IS NOT NULL
                            THEN
                                Tools.Convertc2b (Rec.Sign_Info)
                        END);

                IF Rec.Ndt_Changed = 1
                THEN
                    --У разі зміни типу документа, видаляємо усі навявні атрибути
                    Api$appeal.Clear_Document_Attrs (p_Apd_Id => Rec.Apd_Id);
                END IF;

                IF Rec.Attributes IS NOT NULL
                THEN
                    --Зберігаємо атрибути документа
                    Save_Document_Attrs (p_Ap_Id       => p_Ap_Id,
                                         p_Apd_Id      => Rec.Apd_Id,
                                         p_Apd_Attrs   => l_Ap_Document_Attrs);
                END IF;

                IF Rec.Apd_Attachments IS NOT NULL
                THEN
                    --Зберігаємо вкладення документа
                    Uss_Doc.Api$documents.Save_Attach_List (
                        p_Doc_Id        => Rec.Apd_Doc,
                        p_Dh_Id         => NULL,
                        p_Attachments   => Rec.Apd_Attachments);
                END IF;
            END IF;
        END LOOP;
    END;

    --#69367
    PROCEDURE Copy_Persons (p_Ap_Id        IN     Appeal.Ap_Id%TYPE,
                            p_Ap_Persons   IN OUT t_Ap_Persons)
    IS
        l_App_Sc           NUMBER;
        l_Prev_Ap          NUMBER;
        l_Min_App_Id       NUMBER;
        l_Copied_Persons   t_Ap_Persons;
    BEGIN
        --Отримуємо Ід соцкартки заявника поточного звернення
        SELECT MAX (z.App_Sc)
          INTO l_App_Sc
          FROM TABLE (p_Ap_Persons) z
         WHERE z.App_Tp = 'Z';

        IF l_App_Sc IS NULL
        THEN
            RETURN;
        END IF;

        --Шукаємо попереднє звернення цього заявника
        SELECT MAX (App_Ap)
          INTO l_Prev_Ap
          FROM (WITH
                    Current_Services
                    AS
                        (SELECT Aps_Nst
                           FROM Ap_Service c
                          WHERE c.Aps_Ap = p_Ap_Id AND c.History_Status = 'A')
                  SELECT z.App_Ap
                    FROM Ap_Person z
                         JOIN Appeal a ON z.App_Ap = a.Ap_Id
                         JOIN Ap_Service s
                             ON a.Ap_Id = s.Aps_Ap AND s.History_Status = 'A'
                   WHERE     z.App_Sc = l_App_Sc
                         AND z.App_Tp = 'Z'
                         AND z.History_Status = 'A'
                         AND z.App_Ap <> p_Ap_Id
                         --в якому є хочаб одна з послуг з поточного звернення
                         AND s.Aps_Nst IN
                                 (SELECT Aps_Nst FROM Current_Services)
                ORDER BY a.Ap_Reg_Dt DESC
                   FETCH FIRST ROW ONLY);



        IF l_Prev_Ap IS NULL
        THEN
            RETURN;
        END IF;

        SELECT NVL (MIN (App_Id), -1)
          INTO l_Min_App_Id
          FROM TABLE (p_Ap_Persons);

        --Отримуємо перелік учасників з попередньго звернення, яких необхідно копіювати в поточне
        SELECT ROW_NUMBER () OVER (ORDER BY p.App_Id) * -1 - l_Min_App_Id,
               p.App_Tp,
               p.App_Inn,
               p.App_Ndt,
               p.App_Doc_Num,
               p.App_Fn,
               p.App_Mn,
               p.App_Ln,
               p.App_Esr_Num,
               p.App_Gender,
               p.App_Sc,
               p.app_num,
               NULL,
               0
          BULK COLLECT INTO l_Copied_Persons
          FROM Ap_Person  p
               LEFT JOIN TABLE (p_Ap_Persons) c ON p.App_Sc = c.App_Sc
         WHERE     p.App_Ap = l_Prev_Ap
               AND p.History_Status = 'A'
               AND c.App_Id IS NULL;

        --Додаємо учасників до переліку в поточному зверненні
        p_Ap_Persons := p_Ap_Persons MULTISET UNION ALL l_Copied_Persons;
    END;

    PROCEDURE Copy_10305_Addresses (p_Ap_Id      IN NUMBER,
                                    p_Nng_From   IN NUMBER,
                                    p_Nng_To     IN NUMBER)
    IS
        l_New_Id   ap_document_attr.apda_id%TYPE;
    BEGIN
        FOR cAddr
            IN (  SELECT nda_order,
                         MAX (CASE WHEN nda_nng = p_Nng_From THEN nda_id END)
                             nda_id_from,
                         MAX (
                             CASE WHEN nda_nng = p_Nng_From THEN da.apda_id END)
                             apda_id_from,
                         MAX (CASE WHEN nda_nng = p_Nng_To THEN nda_id END)
                             nda_id_to,
                         MAX (CASE WHEN nda_nng = p_Nng_To THEN da.apda_id END)
                             apda_id_to,
                         MAX (
                             CASE WHEN nda_nng = p_Nng_To THEN da.apda_nda END)
                             apda_nda_to
                    FROM uss_ndi.v_ndi_document_attr nda
                         LEFT JOIN ap_document_attr da
                             ON apda_ap = p_Ap_Id AND da.apda_nda = nda.nda_id
                   WHERE     nda.nda_ndt = Api$appeal.c_Apd_Ndt_Veteran
                         AND nda.history_status = 'A'
                         AND (nda_nng = p_Nng_From OR nda_nng = p_Nng_To)
                GROUP BY nda_order
                  HAVING MAX (
                             CASE
                                 WHEN nda_nng = p_Nng_From THEN da.apda_id
                             END)
                             IS NOT NULL
                ORDER BY nda_order)
        LOOP
            API$APPEAL.Copy_Document_Attr (
                p_Apda_Id_From   => cAddr.Apda_Id_From,
                p_Apda_Id_To     => cAddr.Apda_Id_To,
                p_Apda_Nda_To    => cAddr.Apda_Nda_To,
                p_New_Id         => l_New_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                     ЗБЕРЕЖЕННЯ ОСІБ
    ---------------------------------------------------------------------
    PROCEDURE Save_Persons (p_Ap_Id        IN     NUMBER,
                            p_Ap_Persons   IN OUT t_Ap_Persons)
    IS
    BEGIN
        FOR i IN 1 .. p_Ap_Persons.COUNT
        LOOP
            IF p_Ap_Persons (i).Deleted = 1 AND p_Ap_Persons (i).App_Id > 0
            THEN
                --Видаляємо повязані з особою способи виплат
                Api$appeal.Delete_Person_Payments (
                    p_App_Id   => p_Ap_Persons (i).App_Id);
                --Відвязуємо особу від документів
                Api$appeal.Detach_Person_Docs (
                    p_App_Id   => p_Ap_Persons (i).App_Id);
                --Видаляемо особу
                Api$appeal.Delete_Person (p_Id => p_Ap_Persons (i).App_Id);
            ELSE
                --Зберігаємо особу
                Api$appeal.Save_Person (
                    p_App_Id        => p_Ap_Persons (i).App_Id,
                    p_App_Ap        => p_Ap_Id,
                    p_App_Tp        => p_Ap_Persons (i).App_Tp,
                    p_App_Inn       => p_Ap_Persons (i).App_Inn,
                    p_App_Ndt       => p_Ap_Persons (i).App_Ndt,
                    p_App_Doc_Num   => UPPER (p_Ap_Persons (i).App_Doc_Num),
                    p_App_Fn        => p_Ap_Persons (i).App_Fn,
                    p_App_Mn        => p_Ap_Persons (i).App_Mn,
                    p_App_Ln        => p_Ap_Persons (i).App_Ln,
                    p_App_Esr_Num   => p_Ap_Persons (i).App_Esr_Num,
                    p_App_Gender    => p_Ap_Persons (i).App_Gender,
                    p_App_Vf        => NULL,
                    p_App_Sc        => p_Ap_Persons (i).App_Sc,
                    p_App_Num       => p_Ap_Persons (i).App_Num,
                    p_New_Id        => p_Ap_Persons (i).New_Id);
            END IF;
        END LOOP;
    END;

    --#110280
    PROCEDURE Save_Person_by_Attr (p_Ap_id    IN     APPEAL.AP_ID%TYPE,
                                   p_App_Tp   IN     AP_PERSON.App_Tp%TYPE,
                                   p_New_Id      OUT AP_PERSON.APP_ID%TYPE)
    IS
    BEGIN
        FOR vPerson
            IN (SELECT MAX (
                           CASE
                               WHEN apda_nda IN (1965) THEN apda_val_string
                           END)    fn,
                       MAX (
                           CASE
                               WHEN apda_nda IN (1966) THEN apda_val_string
                           END)    mn,
                       MAX (
                           CASE
                               WHEN apda_nda IN (1964) THEN apda_val_string
                           END)    LN
                  FROM ap_document_attr
                 WHERE apda_ap = p_Ap_id AND apda_nda IN (1965, 1966, 1964))
        LOOP
            API$APPEAL.Save_Person (p_App_Id        => NULL,
                                    p_App_Ap        => p_Ap_id,
                                    p_App_Tp        => p_App_Tp,
                                    p_App_Inn       => NULL,
                                    p_App_Ndt       => NULL,
                                    p_App_Doc_Num   => NULL,
                                    p_App_Fn        => vPerson.Fn,
                                    p_App_Mn        => vPerson.Mn,
                                    p_App_Ln        => vPerson.LN,
                                    p_App_Esr_Num   => NULL,
                                    p_App_Gender    => NULL,
                                    p_App_Vf        => NULL,
                                    p_App_Sc        => NULL,
                                    p_App_Num       => NULL,
                                    p_New_Id        => p_New_Id);
        END LOOP;
    END;

    --#110280
    PROCEDURE Create_App_By_Attr (p_Ap_id IN APPEAL.AP_ID%TYPE)
    IS
        l_Amnt              NUMBER;
        l_Z_Amnt            NUMBER;
        l_1944_Attr_Value   VARCHAR2 (10);
        l_1946_Attr_Value   VARCHAR2 (10);
        l_app_id            NUMBER;
        l_apd_id            NUMBER;
        l_attr_val_str      VARCHAR2 (10);
        l_Apda_New_Id       NUMBER;
    BEGIN
        IF     Api$verification_Cond.Is_Apd_Exists (p_Ap_id, '802')
           AND Api$Appeal.Get_Ap_Src (p_Ap_id) IN ('PORTAL')
           AND Api$appeal.Get_Ap_Tp (p_Ap_id) IN ('SS')
        THEN
            SELECT COUNT (1), COUNT (CASE WHEN APP_TP = 'Z' THEN 1 END)
              INTO l_Amnt, l_Z_Amnt
              FROM AP_PERSON
             WHERE APP_AP = p_Ap_id AND HISTORY_STATUS = 'A';

            IF l_Amnt = 1 AND l_Z_Amnt = 1
            THEN
                l_1944_Attr_Value :=
                    API$APPEAL.Get_Ap_Attr_Val_Str (p_Ap_id, 1944);
                l_1946_Attr_Value :=
                    API$APPEAL.Get_Ap_Attr_Val_Str (p_Ap_id, 1946);

                IF l_1944_Attr_Value = 'Z' AND l_1946_Attr_Value != 'SA'
                THEN
                    Save_Person_by_Attr (p_Ap_id, 'OS', l_Amnt);
                ELSIF l_1944_Attr_Value = 'FM' AND l_1946_Attr_Value != 'SA'
                THEN
                    Save_Person_by_Attr (p_Ap_id, 'FM', l_Amnt);
                END IF;
            END IF;
        ELSIF     Api$verification_Cond.Is_Apd_Exists (p_Ap_id, '801,802')
              AND Api$Appeal.Get_Ap_Src (p_Ap_id) IN ('PORTAL')
              AND Api$appeal.Get_Ap_Tp (p_Ap_id) IN ('SS')
        THEN
            --#115373

            SELECT MAX (app_id)
              INTO l_app_id
              FROM ap_person app
             WHERE     app.app_tp = 'Z'
                   AND app.history_status = 'A'
                   AND app.app_ap = p_Ap_id;

            IF l_app_id IS NOT NULL
            THEN
                SELECT MAX (apd_id)
                  INTO l_apd_id
                  FROM ap_document apd
                 WHERE     apd_app = l_app_id
                       AND apd.history_status = 'A'
                       AND apd.apd_ndt = 605;

                IF l_apd_id IS NOT NULL
                THEN
                    SELECT MAX (apda.apda_val_string)
                      INTO l_attr_val_str
                      FROM ap_document_attr apda
                     WHERE     apda.apda_apd = l_apd_id
                           AND apda.apda_nda = 649
                           AND apda.history_status = 'A';

                    IF l_attr_val_str IS NULL
                    THEN
                        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                            p_Apda_Ap           => p_Ap_id,
                            p_Apda_Apd          => l_apd_id,
                            p_Apda_Nda          => 649,
                            p_Apda_Val_String   => 'Z',
                            p_New_Id            => l_Apda_New_Id);
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

    ---------------------------------------------------------------------
    --              ЗБЕРЕЖЕННЯ ШАПКИ ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Ap_Declaration (
        p_Ap_Id            IN     Appeal.Ap_Id%TYPE,
        p_Com_Org          IN     NUMBER,
        p_Ap_Persons       IN     t_Ap_Persons,
        p_Ap_Declaration   IN OUT r_Ap_Declaration)
    IS
    BEGIN
        --#70674
        SELECT MAX (App_Ln), MAX (App_Fn), MAX (App_Mn)
          INTO p_Ap_Declaration.Apr_Ln,
               p_Ap_Declaration.Apr_Fn,
               p_Ap_Declaration.Apr_Mn
          FROM (  SELECT *
                    FROM TABLE (p_Ap_Persons)
                   WHERE App_Tp = 'Z' AND NVL (Deleted, 0) = 0
                ORDER BY App_Id
                   FETCH FIRST ROW ONLY);

        Api$appeal.Save_Declaration (
            p_Apr_Id          => p_Ap_Declaration.Apr_Id,
            p_Apr_Ap          => p_Ap_Id,
            p_Apr_Fn          => p_Ap_Declaration.Apr_Fn,
            p_Apr_Mn          => p_Ap_Declaration.Apr_Mn,
            p_Apr_Ln          => p_Ap_Declaration.Apr_Ln,
            p_Apr_Residence   => p_Ap_Declaration.Apr_Residence,
            p_Com_Org         => p_Com_Org,
            p_Apr_Vf          => p_Ap_Declaration.Apr_Vf,
            p_Apr_Start_Dt    =>
                TO_DATE (p_Ap_Declaration.Apr_Start_Dt, c_Xml_Dt_Fmt),
            p_Apr_Stop_Dt     =>
                TO_DATE (p_Ap_Declaration.Apr_Stop_Dt, c_Xml_Dt_Fmt),
            p_New_Id          => p_Ap_Declaration.Apr_Id);
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЧЛЕНІВ РОДИНИ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Persons (p_Apr_Id        IN     Ap_Declaration.Apr_Id%TYPE,
                                p_Apr_Persons   IN OUT t_Apr_Persons,
                                p_Ap_Persons    IN     t_Ap_Persons)
    IS
        l_Apr_App   NUMBER;
    BEGIN
        FOR i IN 1 .. p_Apr_Persons.COUNT
        LOOP
            IF     p_Apr_Persons (i).Deleted = 1
               AND p_Apr_Persons (i).Aprp_Id > 0
            THEN
                --Видаляємо члена родини
                Api$appeal.Delete_Apr_Person (
                    p_Aprp_Id   => p_Apr_Persons (i).Aprp_Id);
            ELSE
                SELECT MAX (GREATEST (p.App_Id, NVL (p.New_Id, -1)))
                  INTO l_Apr_App
                  FROM TABLE (p_Ap_Persons) p
                 WHERE App_Id = p_Apr_Persons (i).Aprp_App;

                --Зберігаємо члена родини
                Api$appeal.Save_Apr_Person (
                    p_Aprp_Id      => p_Apr_Persons (i).Aprp_Id,
                    p_Aprp_Apr     => p_Apr_Id,
                    p_Aprp_Fn      => p_Apr_Persons (i).Aprp_Fn,
                    p_Aprp_Mn      => p_Apr_Persons (i).Aprp_Mn,
                    p_Aprp_Ln      => p_Apr_Persons (i).Aprp_Ln,
                    p_Aprp_Tp      => p_Apr_Persons (i).Aprp_Tp,
                    p_Aprp_Inn     => p_Apr_Persons (i).Aprp_Inn,
                    p_Aprp_Notes   => p_Apr_Persons (i).Aprp_Notes,
                    p_Aprp_App     => l_Apr_App,
                    p_New_Id       => p_Apr_Persons (i).New_Id);
            END IF;
        END LOOP;
    END;

    FUNCTION To_Money (p_Str VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (REPLACE (p_Str, ',', '.'),
                          '9999999999D99999',
                          'NLS_NUMERIC_CHARACTERS=''.,''');
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ДОХОДІВ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Incomes (p_Apr_Id        IN Ap_Declaration.Apr_Id%TYPE,
                                p_Apr_Persons   IN t_Apr_Persons,
                                p_Apr_Incomes   IN t_Apr_Incomes)
    IS
    BEGIN
        FOR Rec
            IN (SELECT i.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Incomes)  i
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON i.Apri_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apri_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Income (p_Apri_Id => Rec.Apri_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Income (
                    p_Apri_Id            => Rec.Apri_Id,
                    p_Apri_Apr           => p_Apr_Id,
                    p_Apri_Ln_Initials   => NULL,
                    p_Apri_Tp            => Rec.Apri_Tp,
                    p_Apri_Sum           => To_Money (Rec.Apri_Sum),
                    p_Apri_Source        => Rec.Apri_Source,
                    p_Apri_Aprp          => Rec.Aprp_Id,
                    p_Apri_Start_Dt      =>
                        TO_DATE (Rec.Apri_Start_Dt, c_Xml_Dt_Fmt),
                    p_Apri_Stop_Dt       =>
                        TO_DATE (Rec.Apri_Stop_Dt, c_Xml_Dt_Fmt),
                    p_New_Id             => Rec.Apri_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЗЕМЕЛЬНИХ ДІЛЯНОК З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Land_Plots (p_Apr_Id           IN Ap_Declaration.Apr_Id%TYPE,
                                   p_Apr_Persons      IN t_Apr_Persons,
                                   p_Apr_Land_Plots   IN t_Apr_Land_Plots)
    IS
    BEGIN
        FOR Rec
            IN (SELECT l.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Land_Plots)  l
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON l.Aprt_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Aprt_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Land_Plot (Aprt_Id => Rec.Aprt_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Land_Plot (
                    p_Aprt_Id            => Rec.Aprt_Id,
                    p_Aprt_Apr           => p_Apr_Id,
                    p_Aprt_Ln_Initials   => NULL,
                    p_Aprt_Area          => Rec.Aprt_Area,
                    p_Aprt_Ownership     => Rec.Aprt_Ownership,
                    p_Aprt_Purpose       => Rec.Aprt_Purpose,
                    p_Aprt_Aprp          => Rec.Aprp_Id,
                    p_New_Id             => Rec.Aprt_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЖИТЛОВИХ ПРИМІЩЕНЬ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Living_Quarters (
        p_Apr_Id                IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons           IN t_Apr_Persons,
        p_Apr_Living_Quarters   IN t_Apr_Living_Quarters)
    IS
    BEGIN
        FOR Rec
            IN (SELECT q.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Living_Quarters)  q
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON q.Aprl_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Aprl_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Living_Quarters (
                    p_Aprl_Id   => Rec.Aprl_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Living_Quarters (
                    p_Aprl_Id            => Rec.Aprl_Id,
                    p_Aprl_Apr           => p_Apr_Id,
                    p_Aprl_Ln_Initials   => NULL,
                    p_Aprl_Area          => Rec.Aprl_Area,
                    p_Aprl_Qnt           => Rec.Aprl_Qnt,
                    p_Aprl_Address       => Rec.Aprl_Address,
                    p_Aprl_Aprp          => Rec.Aprp_Id,
                    p_Aprl_Tp            => Rec.Aprl_Tp,
                    p_Aprl_Ch            => Rec.Aprl_Ch,
                    p_New_Id             => Rec.Aprl_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ДОДАТКОВИХ ДЖЕРЕЛ ІСНУВАННЯ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Other_Incomes (
        p_Apr_Id              IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons         IN t_Apr_Persons,
        p_Apr_Other_Incomes   IN t_Apr_Other_Incomes)
    IS
    BEGIN
        FOR Rec
            IN (SELECT o.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Other_Incomes)  o
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON o.Apro_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apro_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Other_Income (p_Apro_Id => Rec.Apro_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Other_Income (
                    p_Apro_Id             => Rec.Apro_Id,
                    p_Apro_Apr            => p_Apr_Id,
                    p_Apro_Tp             => Rec.Apro_Tp,
                    p_Apro_Income_Info    => Rec.Apro_Income_Info,
                    p_Apro_Income_Usage   => Rec.Apro_Income_Usage,
                    p_Apro_Aprp           => Rec.Aprp_Id,
                    p_New_Id              => Rec.Apro_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ВІДОМОСТЕЙ ПРО ВИТРАТИ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Spendings (p_Apr_Id          IN Ap_Declaration.Apr_Id%TYPE,
                                  p_Apr_Persons     IN t_Apr_Persons,
                                  p_Apr_Spendings   IN t_Apr_Spendings)
    IS
    BEGIN
        FOR Rec
            IN (SELECT s.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Spendings)  s
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON s.Aprs_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Aprs_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Spending (p_Aprs_Id => Rec.Aprs_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Spending (
                    p_Aprs_Id            => Rec.Aprs_Id,
                    p_Aprs_Apr           => p_Apr_Id,
                    p_Aprs_Ln_Initials   => NULL,
                    p_Aprs_Tp            => Rec.Aprs_Tp,
                    p_Aprs_Cost_Type     => Rec.Aprs_Cost_Type,
                    p_Aprs_Cost          => To_Money (Rec.Aprs_Cost),
                    p_Aprs_Dt            =>
                        TO_DATE (Rec.Aprs_Dt, c_Xml_Dt_Fmt),
                    p_Aprs_Aprp          => Rec.Aprp_Id,
                    p_New_Id             => Rec.Aprs_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ТРАНСПОРТНИХ ЗАСОБІВ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Vehicles (p_Apr_Id         IN Ap_Declaration.Apr_Id%TYPE,
                                 p_Apr_Persons    IN t_Apr_Persons,
                                 p_Apr_Vehicles   IN t_Apr_Vehicles)
    IS
    BEGIN
        FOR Rec
            IN (SELECT v.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Vehicles)  v
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON v.Aprv_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Aprv_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Vehicle (p_Aprv_Id => Rec.Aprv_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Vehicle (
                    p_Aprv_Id                => Rec.Aprv_Id,
                    p_Aprv_Apr               => p_Apr_Id,
                    p_Aprv_Ln_Initials       => NULL,
                    p_Aprv_Car_Brand         => Rec.Aprv_Car_Brand,
                    p_Aprv_License_Plate     => Rec.Aprv_License_Plate,
                    p_Aprv_Production_Year   => Rec.Aprv_Production_Year,
                    p_Aprv_Is_Social_Car     => Rec.Aprv_Is_Social_Car,
                    p_Aprv_Aprp              => Rec.Aprp_Id,
                    p_New_Id                 => Rec.Aprv_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ СУМИ АЛІМЕНТІВ
    ---------------------------------------------------------------------

    PROCEDURE Save_Apr_Alimonies (p_Apr_Id          IN Ap_Declaration.Apr_Id%TYPE,
                                  p_Apr_Persons     IN t_Apr_Persons,
                                  p_Apr_Alimonies   IN t_Apr_Alimonies)
    IS
    BEGIN
        FOR Rec
            IN (SELECT v.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Alimonies)  v
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON v.Apra_Aprp = p.Aprp_Id)
        LOOP
            IF Rec.Deleted = 1 AND Rec.Apra_Id > 0
            THEN
                --Видаляємо запис
                Api$appeal.Delete_Apr_Alimony (p_Apra_Id => Rec.Apra_Id);
            ELSE
                --Зберігаємо запис
                Api$appeal.Save_Apr_Alimony (
                    p_Apra_Id                => Rec.Apra_Id,
                    p_Apra_Apr               => p_Apr_Id,
                    p_Apra_Payer             => Rec.Apra_Payer,
                    p_Apra_Sum               => To_Money (Rec.Apra_Sum),
                    p_Apra_Is_Have_Arrears   => Rec.Apra_Is_Have_Arrears,
                    p_Apra_Aprp              => Rec.Aprp_Id,
                    p_New_Id                 => Rec.Apra_Id);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                     ЗБЕРЕЖЕННЯ ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Declaration (p_Ap_Id             IN Appeal.Ap_Id%TYPE,
                                p_Com_Org           IN NUMBER,
                                p_Declaration_Dto   IN r_Declaration_Dto,
                                p_Ap_Persons        IN t_Ap_Persons)
    IS
        l_Ap_Declaration        r_Ap_Declaration;
        l_Apr_Persons           t_Apr_Persons;
        l_Apr_Incomes           t_Apr_Incomes;
        l_Apr_Land_Plots        t_Apr_Land_Plots;
        l_Apr_Living_Quarters   t_Apr_Living_Quarters;
        l_Apr_Other_Incomes     t_Apr_Other_Incomes;
        l_Apr_Spendings         t_Apr_Spendings;
        l_Apr_Vehicles          t_Apr_Vehicles;
        l_Apr_Alimonies         t_Apr_Alimonies;
    BEGIN
        --Парсинг шапки декларації
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         'r_Ap_Declaration',
                                         TRUE,
                                         FALSE)
            INTO l_Ap_Declaration
            USING p_Declaration_Dto.Declaration;

        --Збереження шапки декларації
        Save_Ap_Declaration (p_Ap_Id            => p_Ap_Id,
                             p_Com_Org          => p_Com_Org,
                             p_Ap_Persons       => p_Ap_Persons,
                             p_Ap_Declaration   => l_Ap_Declaration);

        --Парсинг членів родини
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Persons',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Persons
            USING p_Declaration_Dto.Persons;

        --Збереження членів родини
        Save_Apr_Persons (p_Apr_Id        => l_Ap_Declaration.Apr_Id,
                          p_Apr_Persons   => l_Apr_Persons,
                          p_Ap_Persons    => p_Ap_Persons);

        --Парсинг доходів членів родини
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Incomes',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Incomes
            USING p_Declaration_Dto.Incomes;

        --Збереження доходів членів родини
        Save_Apr_Incomes (p_Apr_Id        => l_Ap_Declaration.Apr_Id,
                          p_Apr_Persons   => l_Apr_Persons,
                          p_Apr_Incomes   => l_Apr_Incomes);

        --Парсинг земельних ділянок
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Land_Plots',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Land_Plots
            USING p_Declaration_Dto.Land_Plots;

        --Збереження земельних ділянок
        Save_Apr_Land_Plots (p_Apr_Id           => l_Ap_Declaration.Apr_Id,
                             p_Apr_Persons      => l_Apr_Persons,
                             p_Apr_Land_Plots   => l_Apr_Land_Plots);

        --Парсинг житлових приміщень
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Living_Quarters',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Living_Quarters
            USING p_Declaration_Dto.Living_Qurters;

        --Збереження житлових приміщень
        Save_Apr_Living_Quarters (
            p_Apr_Id                => l_Ap_Declaration.Apr_Id,
            p_Apr_Persons           => l_Apr_Persons,
            p_Apr_Living_Quarters   => l_Apr_Living_Quarters);

        --Парсинг додаткових джерел існування
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Other_Incomes',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Other_Incomes
            USING p_Declaration_Dto.Other_Incomes;

        --Збереження додаткових джерел існування
        Save_Apr_Other_Incomes (p_Apr_Id              => l_Ap_Declaration.Apr_Id,
                                p_Apr_Persons         => l_Apr_Persons,
                                p_Apr_Other_Incomes   => l_Apr_Other_Incomes);

        --Парсинг відомостей про витрати
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Spendings',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Spendings
            USING p_Declaration_Dto.Spendings;

        --Збереження відомостей про витрати
        Save_Apr_Spendings (p_Apr_Id          => l_Ap_Declaration.Apr_Id,
                            p_Apr_Persons     => l_Apr_Persons,
                            p_Apr_Spendings   => l_Apr_Spendings);

        --Парсинг транспортних засобів
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Vehicles',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Vehicles
            USING p_Declaration_Dto.Vehicles;

        --Збереження транспортних засобів
        Save_Apr_Vehicles (p_Apr_Id         => l_Ap_Declaration.Apr_Id,
                           p_Apr_Persons    => l_Apr_Persons,
                           p_Apr_Vehicles   => l_Apr_Vehicles);

        --Парсинг аліментів
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Apr_Alimonies',
                                         TRUE,
                                         FALSE)
            BULK COLLECT INTO l_Apr_Alimonies
            USING p_Declaration_Dto.Alimonies;

        --Збереження аліментів
        Save_Apr_Alimonies (p_Apr_Id          => l_Ap_Declaration.Apr_Id,
                            p_Apr_Persons     => l_Apr_Persons,
                            p_Apr_Alimonies   => l_Apr_Alimonies);
    END;

    ---------------------------------------------------------------------
    --    #100276 ПЕРЕВІРКА БУКВИ серія-номер документа
    -- «Свідоцтво про народження дитини (місце народження в Україні)
    ---------------------------------------------------------------------
    PROCEDURE Check_SS_SERT_NUM (p_ap_id NUMBER)
    IS
    BEGIN
        UPDATE ap_person t
           SET t.app_doc_num = 'І' || SUBSTR (t.app_doc_num, 2)
         WHERE t.app_id IN
                   (SELECT z.app_id
                      FROM ap_person z
                     WHERE     z.app_ap = p_ap_id
                           AND z.app_ndt = 37
                           AND SUBSTR (z.app_doc_num, 1, 1) = '1');

        UPDATE ap_document_attr t
           SET t.apda_val_string = 'І' || SUBSTR (t.apda_val_string, 2)
         WHERE t.apda_id IN
                   (SELECT a.apda_id
                      FROM ap_document  z
                           JOIN ap_document_attr a ON (a.apda_apd = z.apd_id)
                     WHERE     z.apd_ap = p_ap_id
                           AND z.apd_ndt = 37
                           AND a.apda_nda = 90
                           AND SUBSTR (a.apda_val_string, 1, 1) = '1');
    END;

    PROCEDURE Updatexmlsqllog (p_Lxs_Pkg_Name    VARCHAR2,
                               p_Lxs_Type_Name   VARCHAR2,
                               p_Lxs_Xml         CLOB)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Logxmlsql Ddd
           SET Ddd.Lxs_Xml = p_Lxs_Xml
         WHERE     Lxs_Pkg_Name = p_Lxs_Pkg_Name
               AND Lxs_Type_Name = p_Lxs_Type_Name
               AND Lxs_Com_Wu =
                   Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid)
               AND Ddd.Lxs_Xml IS NULL;

        COMMIT;
    END;


    PROCEDURE Save_Appeal_Check (
        p_Ap_Id         IN     Appeal.Ap_Id%TYPE,
        p_Ap_St         IN     Appeal.Ap_St%TYPE,
        p_Ap_Dest_Org   IN     Appeal.Ap_Dest_Org%TYPE,
        p_Is_External      OUT NUMBER,
        p_Ap_St_Old        OUT Appeal.Ap_St%TYPE,
        p_Ap_Com_Org       OUT Appeal.Com_Org%TYPE)
    IS
        l_Err_Cnt             NUMBER;
        l_org_to              NUMBER := tools.GetCurrOrgTo;
        l_Ap_Id               Appeal.Ap_Id%TYPE;
        --l_Ap_St             Appeal.Ap_St%TYPE;
        l_Ap_Reg_Dt           Appeal.Ap_Reg_Dt%TYPE;
        l_Ap_Src              Appeal.Ap_Src%TYPE;
        l_Ap_Is_Ext_Process   Appeal.Ap_Is_Ext_Process%TYPE;
    BEGIN
        p_Is_External := 0;

        -- #94939
        IF (l_org_to = 35 AND p_Ap_Dest_Org IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Потрібно вказати ОСЗН для передачі!');
        END IF;

        IF p_Ap_St = 'VW'
        THEN
            Raise_Application_Error (
                -20000,
                'Заборонено переводити в статус "Виконується верифікація"');
        END IF;

        --20210812: по устной постановке Б.Б.
        IF NVL (p_Ap_Id, 0) > 0
        THEN
            SELECT a.Ap_St,
                   a.Ap_Is_Ext_Process,
                   a.Ap_Reg_Dt,
                   a.Ap_Src,
                   com_org
              INTO p_Ap_St_Old,
                   l_Ap_Is_Ext_Process,
                   l_Ap_Reg_Dt,
                   l_Ap_Src,
                   p_Ap_Com_Org
              FROM Appeal a
             WHERE a.Ap_Id = p_Ap_Id;

            IF p_Ap_St_Old NOT IN ('J',
                                   'N',
                                   'W',
                                   'VE',
                                   'R')
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування звернення в поточному статусі заборонено');
            END IF;

            --20230622: по постановці О.Зиновець
            --20231002: за постановкою О.Зиновець контроль знято
            /*IF l_Ap_Src = Api$appeal.c_Src_Diia THEN
              Raise_Application_Error(-20000,
                                      'Редагування звернень з джерелом "Дія" заборонено');
            END IF;*/

            IF p_Ap_St = Api$appeal.c_Ap_St_Declined
            THEN
                --Відхилено
                SELECT COUNT (1)
                  INTO l_Err_Cnt
                  FROM Ap_Log
                 WHERE Apl_Ap = l_Ap_Id AND Apl_St = 'B';

                IF l_Err_Cnt > 0
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Заборонено відхіляти звернення, по якому є рішення');
                END IF;
            END IF;

            IF    l_Ap_Is_Ext_Process = 'T'
               -- #97841: соцгромада як і дія повинні редагуватись в статусах ('J', 'N', 'W', 'VE')
               OR l_Ap_Src IN
                      (                        /*Api$appeal.c_Src_Community,*/
                       Api$appeal.c_Src_Portal, Api$appeal.c_Src_Ehlp)
            THEN
                -- #81791
                p_Is_External := 1;

                IF p_Ap_St_Old NOT IN ('J', 'N')
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Редагування звернення в поточному статусі в ЄІССС заборонено');
                END IF;
            --Raise_Application_Error(-20000, 'Редагування звернення в ЄІССС заборонено');
            END IF;
        END IF;
    END;

    -- #115963
    PROCEDURE set_dd_dest_org (p_ap_id IN NUMBER)
    IS
        l_is_vpo   VARCHAR2 (10);
        l_kaot     NUMBER;
        l_org_id   NUMBER;
    BEGIN
        SELECT MAX (t.apda_val_string)
          INTO l_is_vpo
          FROM ap_document_attr  t
               JOIN ap_document d ON (d.apd_id = t.apda_apd)
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 605
               AND t.apda_nda = 8786
               AND t.history_status = 'A';

        SELECT MAX (t.apda_val_id)
          INTO l_kaot
          FROM ap_document_attr t
         WHERE     t.apda_ap = p_ap_id
               AND (l_is_vpo = 'T' AND t.apda_nda = 4492 OR t.apda_nda = 8634)
               AND t.history_status = 'A';

        SELECT MAX (p.org_id)
          INTO l_org_id
          FROM uss_ndi.v_ndi_katottg  t
               JOIN uss_ndi.v_NDI_ORG2KAOT o
                   ON (o.nok_kaot = t.kaot_kaot_l1 AND o.history_status = 'A')
               JOIN uss_ndi.v_ndi_nsss2dszn n ON (n.n2d_org_dszn = o.nok_org)
               JOIN v_opfu p ON (p.org_id = n.n2d_org_nsss AND p.org_to = 81)
         WHERE t.kaot_id = l_kaot;

        UPDATE appeal t
           SET t.ap_dest_org = NVL (l_org_id, ap_dest_org)
         WHERE t.ap_id = p_ap_id;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Save_Appeal (
        p_Ap_Id            IN     Appeal.Ap_Id%TYPE,
        p_Ap_Is_Second     IN     Appeal.Ap_Is_Second%TYPE,
        p_Is_Unchanged     IN     VARCHAR2, -- T/F, #69367 - якщо є ознака повторного + ця, то треба скопіювати учасників з попереднього звернення
        p_Ap_Tp            IN     Appeal.Ap_Tp%TYPE,
        p_Ap_St            IN     Appeal.Ap_St%TYPE,
        p_Obi_Ts           IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Reg_Dt        IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Dest_Org      IN     Appeal.Ap_Dest_Org%TYPE,
        p_Ap_Services      IN     CLOB,
        p_Ap_Persons       IN     CLOB,
        p_Ap_Payments      IN     CLOB,
        p_Ap_Documents     IN     CLOB,
        p_Ap_Declaration   IN     CLOB,
        p_New_Id              OUT Appeal.Ap_Id%TYPE,
        p_Messages            OUT SYS_REFCURSOR,
        p_Ap_Ap_Main       IN     Appeal.Ap_Ap_Main%TYPE DEFAULT NULL)
    IS
        l_Hs_Id             NUMBER;
        l_Err_Cnt           NUMBER;
        l_Com_Wu            Appeal.Com_Wu%TYPE;
        l_Com_Org           Appeal.Com_Org%TYPE;
        l_ap_com_org        Appeal.Com_Org%TYPE;
        l_Ap_Id             Appeal.Ap_Id%TYPE;
        l_Ap_Persons        t_Ap_Persons;
        l_Ap_Services       t_Ap_Services;
        l_Ap_Payments       t_Ap_Payments;
        l_Ap_Documents      t_Ap_Documents;
        l_Declaration_Dto   r_Declaration_Dto;
        l_Ap_St             Appeal.Ap_St%TYPE;
        l_Ap_St_Old         Appeal.Ap_St%TYPE;
        l_Ap_Reg_Dt         Appeal.Ap_Reg_Dt%TYPE;
        l_Ap_Src            Appeal.Ap_Src%TYPE;
        l_Messages          Api$validation.t_Messages;
        l_Is_External       NUMBER := 0;
        l_Is_Error_Exists   BOOLEAN := FALSE;
        l_Nst420            NUMBER := 0;
        l_New_Id            NUMBER;
        l_tmp               appeal.ap_st%TYPE;
        l_obi_ts_old        appeal.obi_ts%TYPE;
        l_obi_ts_new        appeal.obi_ts%TYPE;
        l_cnt               NUMBER;
        l_Ap_Dest_Org       appeal.ap_dest_org%TYPE;
    BEGIN
        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', '''. ''');
        Tools.Writemsg ('Dnet$appeal.Save_Appeal');

        l_Com_Wu := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid);
        l_Com_Org := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Gorg);
        l_Hs_Id := Tools.Gethistsessiona;
        l_Ap_Dest_Org :=
            NVL (p_Ap_Dest_Org, CASE WHEN p_Ap_Tp = 'DD' THEN 80000 END);

        Save_Appeal_Check (p_Ap_Id         => p_Ap_Id,
                           p_Ap_St         => p_Ap_St,
                           p_Ap_Dest_Org   => l_Ap_Dest_Org,
                           p_Is_External   => l_Is_External,
                           p_Ap_St_Old     => l_Ap_St_Old,
                           p_ap_com_org    => l_ap_com_org);

        l_Ap_St := NVL (p_Ap_St, Api$appeal.c_Ap_St_Reg_In_Work);

        --Зберігаємо звернення
        Api$appeal.Save_Appeal (
            p_Ap_Id          => p_Ap_Id,
            p_Ap_Num         => NULL,
            p_Ap_Reg_Dt      =>
                CASE
                    --20231002: за постановкою О.Зиновець дата реєстраці для звернень від Дії не редагується
                    WHEN l_Ap_Src = Api$appeal.c_Src_Diia THEN l_Ap_Reg_Dt
                    ELSE NVL (p_Ap_Reg_Dt, TRUNC (SYSDATE)) -- 02/10/2024 serhii: #109232-6 писати поточну якщо пуста
                END,
            p_Ap_Create_Dt   => SYSDATE,
            p_Ap_Src         => Api$appeal.c_Src_Uss,
            p_Ap_St          => l_Ap_St,
            p_Com_Org        => NVL (l_ap_Com_Org, l_Com_Org),
            p_Ap_Is_Second   => NVL (p_Ap_Is_Second, 'F'),
            p_Ap_Vf          => NULL,
            p_Com_Wu         => l_Com_Wu,
            p_Ap_Tp          => p_Ap_Tp,
            p_Ap_Dest_Org    => NVL (l_Ap_Dest_Org, l_Com_Org),
            p_New_Id         => p_New_Id,
            p_Obi_Ts         => p_Obi_Ts,
            p_Ap_Ap_Main     => p_Ap_Ap_Main);

        l_Ap_Id := NVL (p_Ap_Id, p_New_Id);

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src      => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
            p_obj_tp   => UPPER ('Appeal'),
            p_obj_id   => l_Ap_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ' p_Ap_Is_Second='
                || p_Ap_Is_Second
                || ' p_Ap_Tp='
                || p_Ap_Tp
                || ' p_Ap_St='
                || p_Ap_St
                || ' p_Ap_Dest_Org='
                || p_Ap_Dest_Org
                || ' l_Ap_Dest_Org='
                || l_Ap_Dest_Org
                || ' p_Ap_Ap_Main='
                || p_Ap_Ap_Main);
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
            p_obj_tp           => UPPER ('Appeal'),
            p_obj_id           => l_Ap_Id,
            p_regular_params   => 'AP_PERSON',
            p_lob_param        => p_Ap_Persons);
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
            p_obj_tp           => UPPER ('Appeal'),
            p_obj_id           => l_Ap_Id,
            p_regular_params   => 'AP_DOCUMENT',
            p_lob_param        => p_Ap_Documents);
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
            p_obj_tp           => UPPER ('Appeal'),
            p_obj_id           => l_Ap_Id,
            p_regular_params   => 'AP_SERVICE',
            p_lob_param        => p_Ap_Services);

        --  +++++++++++++++++++++++++++   ПОСЛУГИ  ++++++++++++++++++++++++++++++++++
        IF p_Ap_Services IS NOT NULL
        THEN
            --Парсинг послуг
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Services',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Services
                USING p_Ap_Services;

            Updatexmlsqllog (Package_Name, 't_Ap_Services', p_Ap_Services);

            IF (    l_Is_External = 0
                AND NVL (l_Ap_Src, 'USS') <> Api$appeal.c_Src_Diia)
            THEN
                --Зберігаємо послуги
                Save_Services (p_Ap_Id         => l_Ap_Id,
                               p_Ap_Services   => l_Ap_Services);
            END IF;
        END IF;

        -- +++++++++++++++++++++++++++   УЧАСНИКИ   ++++++++++++++++++++++++++++++++++
        IF p_Ap_Persons IS NOT NULL
        THEN
            --Парсинг осіб
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Persons',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Persons
                USING p_Ap_Persons;

            Updatexmlsqllog (Package_Name, 't_Ap_Persons', p_Ap_Persons);

            IF (    l_Is_External = 0
                AND NVL (l_Ap_Src, 'USS') <> Api$appeal.c_Src_Diia)
            THEN
                IF p_Is_Unchanged = 'T' AND p_Ap_Is_Second = 'T'
                THEN
                    --Копіюємо учасників з попереднього звернення
                    Copy_Persons (p_Ap_Id        => l_Ap_Id,
                                  p_Ap_Persons   => l_Ap_Persons);
                END IF;

                --Зберігаємо учасників
                Save_Persons (p_Ap_Id => l_Ap_Id, p_Ap_Persons => l_Ap_Persons);
            END IF;
        END IF;

        --  +++++++++++++++++++++++++++   СПОСОБИ ВИПЛАТ +++++++++++++++++++++++++++
        IF p_Ap_Payments IS NOT NULL
        THEN
            --Парсинг способів виплат
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Payments',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Payments
                USING p_Ap_Payments;

            --Зберігаємо способи виплат
            Save_Payments (p_Ap_Id         => l_Ap_Id,
                           p_Ap_Payments   => l_Ap_Payments,
                           p_Ap_Services   => l_Ap_Services,
                           p_Ap_Persons    => l_Ap_Persons);
        END IF;

        -- +++++++++++++++++++++++++++   ДОКУМЕНТИ +++++++++++++++++++++++++++
        IF p_Ap_Documents IS NOT NULL
        THEN
            --Парсинг документів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Documents',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Documents
                USING p_Ap_Documents;

            Updatexmlsqllog (Package_Name, 't_Ap_Documents', p_Ap_Documents);

            /* INSERT INTO Logxmlsql
            (lxs_xml, lxs_dt )
            VALUES
            (p_Ap_Documents, SYSDATE);*/

            --Зберігаємо документи
            Save_Documents (p_Ap_Id          => l_Ap_Id,
                            p_Ap_Documents   => l_Ap_Documents,
                            p_Ap_Persons     => l_Ap_Persons,
                            p_Ap_Services    => l_Ap_Services,
                            p_Com_Wu         => l_Com_Wu);
        END IF;

        --API$APPEAL.Save_Ap_Main(p_Ap_Id, p_Ap_Ap_Main);


        IF API$VERIFICATION_COND.Is_Apd_Exists (l_Ap_Id,
                                                API$APPEAL.c_Apd_Ndt_Veteran)
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM ap_document  t
                   JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
             WHERE     t.apd_ap = l_Ap_Id
                   AND t.apd_ndt = API$APPEAL.c_Apd_Ndt_Veteran
                   AND t.history_status = 'A'
                   AND a.apda_nda = 8520
                   AND a.history_status = 'A'
                   AND a.apda_val_string = 'T';

            -- #112414
            IF (l_cnt > 0)
            THEN
                Copy_10305_Addresses (p_Ap_Id      => l_Ap_Id,
                                      p_Nng_From   => 2,
                                      p_Nng_To     => 1);
            END IF;
        END IF;



        -- +++++++++++++++++++++++++++  ДЕКЛАРАЦІЯ +++++++++++++++++++++++++++
        IF p_Ap_Declaration IS NOT NULL
        THEN
                        --Парсинг декларації
                        SELECT Declaration,
                               Persons,
                               Incomes,
                               Land_Plots,
                               Living_Quarters,
                               Other_Incomes,
                               Spendings,
                               Vehicles,
                               Alimonies
                          INTO l_Declaration_Dto
                          FROM XMLTABLE (
                                   '/*'
                                   PASSING Xmltype (p_Ap_Declaration)
                                   COLUMNS --
                                           Declaration        XMLTYPE PATH 'Declaration',
                                           Persons            XMLTYPE PATH 'Persons',
                                           Incomes            XMLTYPE PATH 'Incomes',
                                           Land_Plots         XMLTYPE PATH 'LandPlots',
                                           Living_Quarters    XMLTYPE PATH 'LivingQuarters',
                                           Other_Incomes      XMLTYPE PATH 'OtherIncomes',
                                           Spendings          XMLTYPE PATH 'Spendings',
                                           Vehicles           XMLTYPE PATH 'Vehicles',
                                           Alimonies          XMLTYPE PATH 'Alimonies');

            --Збереження декларації
            Save_Declaration (p_Ap_Id             => l_Ap_Id,
                              p_Com_Org           => l_Com_Org,
                              p_Declaration_Dto   => l_Declaration_Dto,
                              p_Ap_Persons        => l_Ap_Persons);
        END IF;

        Api$appeal.Set_Ap_Sub_Tp (l_Ap_Id);

        IF (p_Ap_Tp = 'SS')
        THEN
            Check_SS_SERT_NUM (l_ap_id);
        END IF;

        -- #115963
        IF (p_Ap_Tp = 'DD')
        THEN
            set_dd_dest_org (l_ap_id);
        END IF;

        --#110280
        DNET$APPEAL.Create_App_By_Attr (p_Ap_Id => l_Ap_Id);

        l_Messages :=
            Api$validation.Validate_Appeal (
                p_Ap_Id             => l_Ap_Id,
                p_Warnings          => TRUE,
                p_Raise_Fatal_Err   => FALSE,
                --#103476
                p_Error_To_Warning   =>
                    API$VERIFICATION_COND.Is_Apd_Ap_Tp_Exists (p_Ap_Id,
                                                               '802',
                                                               'SS'));

        IF (    p_Ap_Tp = 'SS'
            AND p_Ap_Ap_Main IS NULL
            AND l_Messages IS NOT NULL)
        THEN
            --#104014
            --Преводим все ошибки в предупреждения
            --Fatal оставляем
            IF l_Messages.COUNT > 0
            THEN
                FOR i IN l_Messages.FIRST .. l_Messages.LAST
                LOOP
                    IKIS_SYS.Ikis_Procedure_Log.LOG (
                        p_src      => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
                        p_obj_tp   => UPPER ('Appeal'),
                        p_obj_id   => l_Ap_Id,
                        p_regular_params   =>
                               'l_Message count='
                            || l_Messages.COUNT
                            || ', iteration i='
                            || i);

                    BEGIN
                        IF l_Messages (i).Msg_Tp = 'E'
                        THEN
                            l_Messages (i).Msg_Tp := 'W';
                            l_Messages (i).Msg_Tp_Name := 'Попередження';
                            l_Is_Error_Exists := TRUE;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            IKIS_SYS.Ikis_Procedure_Log.LOG (
                                p_src              =>
                                    UPPER (
                                        'USS_VISIT.DNET$APPEAL.Save_Appeal'),
                                p_obj_tp           => UPPER ('Appeal'),
                                p_obj_id           => l_Ap_Id,
                                p_regular_params   => 'error : ' || SQLERRM);
                    END;
                END LOOP;

                IF l_Is_Error_Exists
                THEN
                    API$APPEAL.Save_Ap_Correct_Status (l_Ap_Id, 'F');
                END IF;
            END IF;
        END IF;

        --Пишемо повідомлення в журнал
        Api$appeal.Write_Log (
            p_Apl_Ap        => l_Ap_Id,
            p_Apl_Hs        => l_Hs_Id,
            p_Apl_St        => l_Ap_St,
            p_apl_st_old    => l_Ap_St_Old,
            p_Apl_Message   =>
                CASE
                    WHEN p_Ap_Id IS NULL THEN CHR (38) || '1'
                    ELSE CHR (38) || '2'
                END,
            p_Apl_Tp        => 'SYS');

        IF p_Ap_St = Api$appeal.c_Ap_St_Reg
        THEN
            SELECT COUNT (1)
              INTO l_Err_Cnt
              FROM TABLE (l_Messages)
             WHERE Msg_Tp = 'E';

            IF l_Err_Cnt > 0
            THEN
                SELECT ap_st, obi_ts
                  INTO l_tmp, l_obi_ts_old
                  FROM appeal
                 WHERE ap_id = p_Ap_Id;

                UPDATE Appeal
                   SET Ap_St = l_Ap_St_Old
                 WHERE     Ap_Id = p_Ap_Id
                       AND (Ap_St <> l_Ap_St_Old OR Ap_St IS NULL);

                SELECT obi_ts
                  INTO l_obi_ts_new
                  FROM appeal
                 WHERE ap_id = p_Ap_Id;

                IKIS_SYS.Ikis_Procedure_Log.LOG (
                    p_src      => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
                    p_obj_tp   => UPPER ('Appeal'),
                    p_obj_id   => p_Ap_Id,
                    p_regular_params   =>
                           'Оновлюємо статус (1) new_ap_st='
                        || l_Ap_St_Old
                        || ', old_ap_st='
                        || l_tmp
                        || ', new_obi_ts='
                        || l_obi_ts_new
                        || ', old_obi_ts='
                        || l_obi_ts_old
                        || ', from_interface='
                        || p_obi_ts);
            END IF;
        ELSIF p_Ap_St = Api$appeal.c_Ap_St_Declined
        THEN
            --Відхилено
            SELECT COUNT (1)
              INTO l_Err_Cnt
              FROM Ap_Log
             WHERE Apl_Ap = l_Ap_Id AND Apl_St = 'B';

            IF l_Err_Cnt > 0
            THEN
                SELECT ap_st, obi_ts
                  INTO l_tmp, l_obi_ts_old
                  FROM appeal
                 WHERE ap_id = p_Ap_Id;

                UPDATE Appeal
                   SET Ap_St = l_Ap_St_Old
                 WHERE     Ap_Id = p_Ap_Id
                       AND (Ap_St <> l_Ap_St_Old OR Ap_St IS NULL);

                SELECT obi_ts
                  INTO l_obi_ts_new
                  FROM appeal
                 WHERE ap_id = p_Ap_Id;

                IKIS_SYS.Ikis_Procedure_Log.LOG (
                    p_src      => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
                    p_obj_tp   => UPPER ('Appeal'),
                    p_obj_id   => p_Ap_Id,
                    p_regular_params   =>
                           'Оновлюємо статус (1) new_ap_st='
                        || l_Ap_St_Old
                        || ', old_ap_st='
                        || l_tmp
                        || ', new_obi_ts='
                        || l_obi_ts_new
                        || ', old_obi_ts='
                        || l_obi_ts_old
                        || ', from_interface='
                        || p_obi_ts);
            END IF;
        END IF;

        --#106619
        l_Nst420 :=
            Api$verification_Cond.Ap_Aps_Amount (p_Ap_Id          => p_Ap_Id,
                                                 p_Aps_Nst_List   => '420');

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => UPPER ('USS_VISIT.DNET$APPEAL.Save_Appeal'),
            p_obj_tp           => UPPER ('Appeal'),
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'NST420 Amount. l_Nst420=' || l_Nst420);

        --#106619
        IF l_Nst420 > 0
        THEN
            Api$appeal.Save_Exists_Doc_Attr (p_Apda_Ap           => p_Ap_Id,
                                             p_Apda_Nda          => 1870,
                                             p_Apda_Val_String   => 'T',
                                             p_New_Id            => l_New_Id);


            Api$appeal.Save_Exists_Doc_Attr (p_Apda_Ap           => p_Ap_Id,
                                             p_Apda_Nda          => 1947,
                                             p_Apda_Val_String   => 'T',
                                             p_New_Id            => l_New_Id);

            Api$appeal.Save_Exists_Doc_Attr (p_Apda_Ap           => p_Ap_Id,
                                             p_Apda_Nda          => 8263,
                                             p_Apda_Val_String   => 'T',
                                             p_New_Id            => l_New_Id);
        END IF;

        --#111840
        API$Visit_Action.Prepare_Ap_Copy_Visit2ESR (p_ap => l_Ap_Id);

        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (l_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 2,  3);
    EXCEPTION
        WHEN Api$appeal.Ex_Opt_Block_Viol
        THEN
            Raise_Application_Error (
                -20000,
                Ikis_Message_Util.GET_MESSAGE (Msg_Opt_Block_Viol));
    END;

    PROCEDURE Save_Appeal_Light (
        p_Ap_Id               IN     Appeal.Ap_Id%TYPE,
        p_Ap_Tp               IN     Appeal.Ap_Tp%TYPE,
        p_Ap_St               IN     Appeal.Ap_St%TYPE,
        p_Obi_Ts              IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Reg_Dt           IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Dest_Org         IN     Appeal.Ap_Dest_Org%TYPE,
        p_Ap_Inn              IN     VARCHAR2,
        p_Ap_Inn_Refusal      IN     VARCHAR2,
        p_Ap_FIO              IN     VARCHAR2,
        p_Ap_Is_About_Other   IN     VARCHAR2,
        p_Ap_City             IN     VARCHAR2,
        p_Ap_Street           IN     VARCHAR2,
        p_Ap_Building         IN     VARCHAR2,
        p_Ap_Block            IN     VARCHAR2,
        p_Ap_Flat             IN     VARCHAR2,
        p_Ap_Phone            IN     VARCHAR2,
        p_Ap_Email            IN     VARCHAR2,
        p_Ap_Situation        IN     VARCHAR2,
        p_Ap_Child_Treat      IN     VARCHAR2,
        p_New_Id                 OUT Appeal.Ap_Id%TYPE,
        p_Messages               OUT SYS_REFCURSOR,
        p_Ap_Documents        IN     CLOB DEFAULT NULL,
        p_Ap_City_Name        IN     VARCHAR2 DEFAULT NULL)
    IS
        l_Hs_Id          NUMBER;
        l_Ap_Documents   t_Ap_Documents;
        l_Com_Wu         Appeal.Com_Wu%TYPE;
        l_Com_Org        Appeal.Com_Org%TYPE;
        l_ap_Com_Org     Appeal.Com_Org%TYPE;
        l_Ap_Id          Appeal.Ap_Id%TYPE;
        l_Ap_St          Appeal.Ap_St%TYPE;
        l_Ap_Tp          Appeal.Ap_Tp%TYPE;
        l_Messages       Api$validation.t_Messages;
        l_Is_External    NUMBER := 0;
        l_Ln             Ap_Person.App_Ln%TYPE;
        l_Fn             Ap_Person.App_Fn%TYPE;
        l_Mn             Ap_Person.App_Mn%TYPE;
        l_App_Id         Ap_Person.App_Id%TYPE;
        l_App_New_Id     Ap_Person.App_Id%TYPE;
        l_Apd_Id         Ap_Document.Apd_Id%TYPE;
        l_Apd_New_Id     Ap_Document.Apd_Id%TYPE;
        l_Apda_New_Id    Ap_Document_Attr.Apda_Id%TYPE;
        l_Ap_Reg_Dt      VARCHAR2 (100);
        l_Ap_Num         Appeal.Ap_Num%TYPE;
        l_Ap             Appeal%ROWTYPE;
    BEGIN
        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', '''. ''');
        Tools.Writemsg ('Dnet$appeal.Save_Appeal_Light');

        l_Com_Wu := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid);
        l_Com_Org := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Gorg);
        l_Hs_Id := Tools.Gethistsessiona;

        uss_ndi.tools.Check_Dict_Value (NVL (p_Ap_Is_About_Other, 'Z'),
                                        'V_DDN_SS_LVL_MSG_ABOUT');

        Save_Appeal_Check (p_Ap_Id         => p_Ap_Id,
                           p_Ap_St         => p_Ap_St,
                           p_Ap_Dest_Org   => p_Ap_Dest_Org,
                           p_Is_External   => l_Is_External,
                           p_Ap_St_Old     => l_Ap_St,
                           p_ap_com_org    => l_ap_Com_Org);


        l_Ap_St := NVL (p_Ap_St, Api$appeal.c_Ap_St_Reg_In_Work);

        l_Ap_Tp :=
            Api$appeal.Check_Appeal_Tp (
                p_Ap_Tp       => p_Ap_Tp,
                p_Def_Ap_Ap   => API$APPEAL.c_Ap_Tp_SS);

        --Зберігаємо звернення
        Api$appeal.Save_Appeal (
            p_Ap_Id          => p_Ap_Id,
            p_Ap_Num         => NULL,
            p_Ap_Reg_Dt      => NVL (p_Ap_Reg_Dt, SYSDATE),
            p_Ap_Create_Dt   => SYSDATE,
            p_Ap_Src         => Api$appeal.c_Src_Portal, -- Api$appeal.c_Src_Uss,
            p_Ap_St          => l_Ap_St,
            p_Com_Org        => p_Ap_Dest_Org,
            p_Ap_Is_Second   => 'F',
            p_Ap_Vf          => NULL,
            p_Com_Wu         => l_Com_Wu,
            p_Ap_Tp          => l_Ap_Tp,
            p_Ap_Dest_Org    => NVL (p_Ap_Dest_Org, l_Com_Org),
            p_Ap_Sub_Tp      => 'SL',
            p_New_Id         => p_New_Id,
            p_Obi_Ts         => p_Obi_Ts);

        l_Ap_Id := NVL (p_Ap_Id, p_New_Id);

        Tools.LOG (
            p_src              => 'USS_VISIT.DNET$APPEAL.Save_Appeal_Light',
            p_obj_tp           => 'Appeal',
            p_obj_id           => l_Ap_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ' p_Ap_Tp='
                || p_Ap_Tp
                || ' p_Ap_St='
                || p_Ap_St
                || ' p_Ap_Dest_Org='
                || p_Ap_Dest_Org
                || ' p_Ap_Is_About_Other='
                || p_Ap_Is_About_Other
                || ' p_Ap_Child_Treat='
                || p_Ap_Child_Treat
                || ' p_Ap_Inn_Refusal='
                || p_Ap_Inn_Refusal,
            p_lob_param        => p_Ap_Documents);


        SELECT TO_CHAR (ap_reg_dt, 'DD.MM.YYYY'), ap_num
          INTO l_Ap_Reg_Dt, l_Ap_Num
          FROM appeal
         WHERE ap_id = l_Ap_Id;

        SELECT MAX (CASE WHEN rn = 1 THEN string_parts END)    LN,
               MAX (CASE WHEN rn = 2 THEN string_parts END)    Mn,
               LISTAGG (CASE WHEN rn NOT IN (1, 2) THEN string_parts END,
                        ' ')                                   Mn
          INTO l_Ln, l_Fn, l_Mn
          FROM (SELECT ROWNUM rn, string_parts
                  FROM (    SELECT REGEXP_SUBSTR (p_Ap_FIO,
                                                  '[^ ]+',
                                                  1,
                                                  LEVEL)    AS string_parts
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (p_Ap_FIO,
                                                  '[^ ]+',
                                                  1,
                                                  LEVEL)
                                       IS NOT NULL));

        SELECT MAX (App_Id)
          INTO l_App_Id
          FROM Ap_Person
         WHERE App_Ap = l_Ap_Id;

        API$APPEAL.Save_Person (p_App_Id        => l_App_Id,
                                p_App_Ap        => l_Ap_Id,
                                p_App_Tp        => Api$appeal.c_App_Tp_Applicant,
                                p_App_Inn       => p_Ap_Inn,
                                p_App_Ndt       => NULL,
                                p_App_Doc_Num   => NULL,
                                p_App_Fn        => l_Fn,
                                p_App_Mn        => l_Mn,
                                p_App_Ln        => l_Ln,
                                p_App_Esr_Num   => NULL,
                                p_App_Gender    => NULL,
                                p_App_Vf        => NULL,
                                p_App_Sc        => NULL,
                                p_App_Num       => NULL,
                                p_New_Id        => l_App_New_Id);

        l_App_Id := NVL (l_App_Id, l_App_New_Id);

        IF p_Ap_Inn IS NOT NULL
        THEN
            SELECT MAX (Apd_Id)
              INTO l_Apd_Id
              FROM Ap_Document
             WHERE Apd_Ap = l_Ap_Id AND Apd_Ndt = Api$appeal.c_Apd_Ndt_RNOKPP;

            Api$appeal.Save_Document (
                p_Apd_Id    => l_Apd_Id,
                p_Apd_Ap    => l_Ap_Id,
                p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_RNOKPP,
                p_Apd_Doc   => NULL,
                p_Apd_Vf    => NULL,
                p_Apd_App   => l_App_Id,
                p_Com_Wu    => l_Com_Wu,
                p_Apd_Dh    => NULL,
                p_Apd_Aps   => NULL,
                p_New_Id    => l_Apd_New_Id);
            API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                p_Apda_Ap           => l_Ap_Id,
                p_Apda_Apd          => l_Apd_New_Id,
                p_Apda_Nda          => 1,
                p_Apda_Val_String   => p_Ap_Inn,
                p_New_Id            => l_Apda_New_Id);
        END IF;


        SELECT MAX (Apd_Id)
          INTO l_Apd_Id
          FROM Ap_Document
         WHERE Apd_Ap = l_Ap_Id AND Apd_Ndt = Api$appeal.c_Apd_Ndt_Ess_Appeal;

        Api$appeal.Save_Document (
            p_Apd_Id    => l_Apd_Id,
            p_Apd_Ap    => l_Ap_Id,
            p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_Ess_Appeal,
            p_Apd_Doc   => NULL,
            p_Apd_Vf    => NULL,
            p_Apd_App   => l_App_Id,
            p_Com_Wu    => l_Com_Wu,
            p_Apd_Dh    => NULL,
            p_Apd_Aps   => NULL,
            p_New_Id    => l_Apd_New_Id);

        l_Apd_Id := NVL (l_Apd_Id, l_Apd_New_Id);

        IF p_Ap_Documents IS NOT NULL
        THEN
            --Парсинг документів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Documents',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Documents
                USING p_Ap_Documents;

            Updatexmlsqllog (Package_Name, 't_Ap_Documents', p_Ap_Documents);

            FOR Rec IN (SELECT d.*
                          FROM TABLE (l_Ap_Documents) d)
            LOOP
                --Зберігаємо документ
                Api$appeal.Merge_Document (
                    p_Apd_Id    => Rec.Apd_Id,
                    p_Apd_Ap    => l_Ap_Id,
                    p_Apd_Ndt   => Rec.Apd_Ndt,
                    p_Apd_Doc   => Rec.Apd_Doc,
                    p_Apd_Vf    => NULL,
                    p_Apd_App   => l_App_Id,
                    p_New_Id    => Rec.Apd_Id,
                    p_Com_Wu    => l_Com_Wu,
                    p_Apd_Dh    => Rec.Apd_Dh,
                    p_Apd_Aps   => NULL,
                    p_Apd_Tmp_To_Del_File   =>
                        CASE
                            WHEN Rec.Sign_Info IS NOT NULL
                            THEN
                                Tools.Convertc2b (Rec.Sign_Info)
                        END);

                IF Rec.Apd_Attachments IS NOT NULL
                THEN
                    --Зберігаємо вкладення документа
                    Uss_Doc.Api$documents.Save_Attach_List (
                        p_Doc_Id        => Rec.Apd_Doc,
                        p_Dh_Id         => NULL,
                        p_Attachments   => Rec.Apd_Attachments);
                END IF;
            END LOOP;
        END IF;

        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8250,
            p_Apda_Val_String   => NVL (p_Ap_Inn_Refusal, 'F'),
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8259,
            p_Apda_Val_String   => NVL (p_Ap_Is_About_Other, 'Z'),
            p_New_Id            => l_Apda_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Id_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8251,
            p_Apda_Val_Id       => p_Ap_City,
            p_Apda_Val_String   => p_Ap_City_Name,
            p_New_Id            => l_Apda_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8253,
            p_Apda_Val_String   => p_Ap_Street,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8254,
            p_Apda_Val_String   => p_Ap_Building,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8255,
            p_Apda_Val_String   => p_Ap_Block,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8256,
            p_Apda_Val_String   => p_Ap_Flat,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8258,
            p_Apda_Val_String   => p_Ap_Email,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8257,
            p_Apda_Val_String   => p_Ap_Phone,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8262,
            p_Apda_Val_String   => p_Ap_Situation,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_Id,
            p_Apda_Nda          => 8263,
            p_Apda_Val_String   => NVL (p_Ap_Child_Treat, 'F'),
            p_New_Id            => l_Apda_New_Id);

        IF NVL (p_Ap_Id, 0) <= 0 AND p_Ap_Email IS NOT NULL
        THEN
            USS_PERSON.Api$nt_Api.SendRcMessage (
                p_email    => p_Ap_Email,
                p_source   => 'VST',
                p_title    => CHR (38) || '100',
                p_text     =>
                       CHR (38)
                    || '100#regdt='
                    || l_Ap_Reg_Dt
                    || '#num='
                    || l_Ap_num);
        END IF;

        --API$APPEAL.Save_Ap_Main(l_Ap_Id, null);

        SELECT *
          INTO l_ap
          FROM Appeal ap
         WHERE ap.ap_id = l_Ap_Id;

        l_com_org :=
            DNET$APPEAL_PORTAL.Define_Com_Org (l_ap.ap_id,
                                               l_ap.ap_tp,
                                               l_ap.ap_sub_tp);

        UPDATE Appeal ap
           SET com_org = l_com_org, ap_dest_org = l_com_org
         WHERE ap_id = l_Ap_Id;

        --#110280
        DNET$APPEAL.Create_App_By_Attr (p_Ap_Id => p_Ap_Id);

        --Пишемо повідомлення в журнал
        Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                              p_Apl_Hs        => l_Hs_Id,
                              p_Apl_St        => l_Ap_St,
                              p_Apl_Message   => CHR (38) || '2');

        UPDATE Appeal
           SET Ap_St = 'F'
         WHERE Ap_Id = l_Ap_Id AND (Ap_St <> 'F' OR Ap_St IS NULL);

        api$appeal.Write_Log (l_Ap_Id,
                              l_Hs_Id,
                              'F',
                              CHR (38) || '4',
                              l_Ap_St);

        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (l_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2);
    EXCEPTION
        WHEN Api$appeal.Ex_Opt_Block_Viol
        THEN
            Raise_Application_Error (
                -20000,
                Ikis_Message_Util.GET_MESSAGE (Msg_Opt_Block_Viol));
    END;


    --#112827 Add by task
    PROCEDURE Save_Appeal_Rehab_Tool (
        p_Ap_Id                           IN     Appeal.Ap_Id%TYPE,
        p_Obi_Ts                          IN     Appeal.Obi_Ts%TYPE,
        p_Ap_Dest_Org                     IN     Appeal.Ap_Dest_Org%TYPE, -- ТВ ФСЗОІ куди подається заява (за місцем реєстрації особи)
        p_Ap_LName                        IN     VARCHAR2,    --Прізвище особи
        p_Ap_FName                        IN     VARCHAR2,              --Ім’я
        p_Ap_MName                        IN     VARCHAR2,       --По батькові
        p_Ap_Inn_Refusal                  IN     VARCHAR2, --Ознака відмови від РНОКПП
        p_Ap_Inn                          IN     VARCHAR2,   --РНОКПП заявника
        p_Ap_Live_City                    IN     NUMBER,
        p_Ap_Live_Street                  IN     VARCHAR2,
        p_Ap_Live_Building                IN     VARCHAR2,
        p_Ap_Live_Block                   IN     VARCHAR2,
        p_Ap_Live_Flat                    IN     VARCHAR2,
        p_Ap_Phone                        IN     VARCHAR2,
        p_Ap_Phone_Add                    IN     VARCHAR2,
        p_Ap_Tool_List                    IN     VARCHAR2,
        p_New_Id                             OUT Appeal.Ap_Id%TYPE,
        p_Messages                           OUT SYS_REFCURSOR,
        p_Gender                          IN     VARCHAR2,
        p_Birth_Dt                        IN     DATE,
        p_Ap_Documents                    IN     CLOB,
        p_is_Address_Live_eq_Reg          IN     VARCHAR2,
        p_Ap_Reg_City                     IN     NUMBER,
        p_Ap_Reg_Index                    IN     VARCHAR2,
        p_Ap_Reg_Street                   IN     VARCHAR2,
        p_Ap_Reg_Building                 IN     VARCHAR2,
        p_Ap_Reg_Block                    IN     VARCHAR2,
        p_Ap_Reg_Flat                     IN     VARCHAR2,
        p_Is_Vpo_Exist                    IN     VARCHAR2,
        p_Is_Regf_Addr_Not_Eq_fact_Addr   IN     VARCHAR2,
        p_Is_Vpo_Addr_Eq_Fact_Addr        IN     VARCHAR2,
        p_Ap_Live_Index                   IN     VARCHAR2)
    IS
        l_Hs_Id             NUMBER;
        l_Sc_Unique         VARCHAR2 (100);
        l_Sc_Id             NUMBER;
        l_Com_Wu            Appeal.Com_Wu%TYPE;
        l_Com_Org           Appeal.Com_Org%TYPE;
        l_ap_Com_Org        Appeal.Com_Org%TYPE;
        l_Ap_Id             Appeal.Ap_Id%TYPE;
        l_Ap_St             Appeal.Ap_St%TYPE := Api$appeal.c_Ap_St_Reg;
        l_Ap_Tp             Appeal.Ap_Tp%TYPE := API$APPEAL.c_Ap_Tp_DD;
        l_Ap_Sub_Tp         Appeal.Ap_Sub_Tp%TYPE := API$APPEAL.c_Ap_Sub_Tp_SZ;
        l_Messages          Api$validation.t_Messages;
        l_Is_External       NUMBER := 0;
        l_App_Id            Ap_Person.App_Id%TYPE;
        l_App_New_Id        Ap_Person.App_Id%TYPE;
        l_Apd_New_Id        Ap_Document.Apd_Id%TYPE;
        l_Apda_New_Id       Ap_Document_Attr.Apda_Id%TYPE;
        l_Aps_New_Id        Ap_Service.Aps_Id%TYPE;
        l_Apda_8617_value   VARCHAR2 (10)
            := CASE
                   WHEN TRIM (p_Ap_Tool_List) IS NOT NULL THEN 'T'
                   ELSE 'F'
               END;
        l_Ap_Tool_List      VARCHAR2 (1000) := TRIM (p_Ap_Tool_List);
        l_Gender            VARCHAR2 (10);
        l_Ndt               NUMBER;
        l_Seria             VARCHAR2 (50);
        l_Number            VARCHAR2 (50);
        l_Birth_Dt          DATE;
        l_Birth_Nda         NUMBER;
        l_Dsn_Nda           NUMBER;
        l_Ap_Documents      t_Ap_Documents;
    BEGIN
        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', '''. ''');
        Tools.Writemsg ('Dnet$appeal.Save_Appeal_Rehab_Tool');

        IF NOT REGEXP_LIKE (l_Ap_Tool_List, '^[0-9]+(,[0-9]+)*$')
        THEN
            Raise_application_error (
                -20000,
                   'Значення параметру p_Ap_Tool_List повинно містити перелік чисел через кому. Поточне значення параметру ['
                || p_Ap_Tool_List
                || '] не відповідає цій вимозі');
        END IF;


        l_Com_Wu := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid);
        l_Com_Org := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Gorg);
        l_Hs_Id := Tools.Gethistsessiona;

        Save_Appeal_Check (p_Ap_Id         => p_Ap_Id,
                           p_Ap_St         => l_Ap_St,
                           p_Ap_Dest_Org   => p_Ap_Dest_Org,
                           p_Is_External   => l_Is_External,
                           p_Ap_St_Old     => l_Ap_St,
                           p_ap_com_org    => l_ap_Com_Org);


        l_Ap_St := Api$appeal.c_Ap_St_Reg;
        --Зберігаємо звернення
        Api$appeal.Save_Appeal (
            p_Ap_Id          => p_Ap_Id,
            p_Ap_Num         => NULL,
            p_Ap_Reg_Dt      => SYSDATE,
            p_Ap_Create_Dt   => SYSDATE,
            p_Ap_Src         => Api$appeal.c_Src_Portal, -- Api$appeal.c_Src_Uss,
            p_Ap_St          => l_Ap_St,
            p_Com_Org        => p_Ap_Dest_Org,
            p_Ap_Is_Second   => 'F',
            p_Ap_Vf          => NULL,
            p_Com_Wu         => l_Com_Wu,
            p_Ap_Tp          => l_Ap_Tp,
            p_Ap_Dest_Org    => NVL (p_Ap_Dest_Org, l_Com_Org),
            p_Ap_Sub_Tp      => l_Ap_Sub_Tp,
            p_New_Id         => p_New_Id,
            p_Obi_Ts         => p_Obi_Ts);

        l_Ap_Id := NVL (p_Ap_Id, p_New_Id);

        Tools.LOG (
            p_src              => 'USS_VISIT.DNET$APPEAL.Save_Appeal_Rehab_Tool',
            p_obj_tp           => 'Appeal',
            p_obj_id           => l_Ap_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ' p_Ap_Dest_Org='
                || p_Ap_Dest_Org
                || ' p_Ap_Inn_Refusal='
                || p_Ap_Inn_Refusal
                || ' p_Ap_Inn='
                || p_Ap_Inn
                || ' p_Ap_LName='
                || p_Ap_LName
                || ' p_Ap_FName='
                || p_Ap_FName
                || ' p_Ap_MName='
                || p_Ap_MName
                || ' p_Gender='
                || p_Gender
                || ' p_Birth_Dt='
                || TO_CHAR (p_Birth_Dt, 'DD.MM.YYYY')
                || ' l_Ap_Tool_List='
                || l_Ap_Tool_List
                || ' p_Is_Vpo_Exist='
                || p_Is_Vpo_Exist
                || ' p_Is_Regf_Addr_Not_Eq_fact_Addr='
                || p_Is_Regf_Addr_Not_Eq_fact_Addr
                || ' p_Is_Vpo_Addr_Eq_Fact_Addr='
                || p_Is_Vpo_Addr_Eq_Fact_Addr
                || ' p_is_Address_Live_eq_Reg='
                || p_is_Address_Live_eq_Reg
                || ' p_Ap_Live_Index='
                || p_Ap_Live_Index
                || ' p_Ap_Live_City='
                || p_Ap_Live_City
                || ' p_Ap_Live_Street='
                || p_Ap_Live_Street
                || ' p_Ap_Live_Building='
                || p_Ap_Live_Building
                || ' p_Ap_Reg_Index='
                || p_Ap_Reg_Index
                || ' p_Ap_Reg_City='
                || p_Ap_Reg_City
                || ' p_Ap_Reg_Street='
                || p_Ap_Reg_Street
                || ' p_Ap_Reg_Building='
                || p_Ap_Reg_Building,
            p_lob_param        => p_Ap_Documents);


        l_Sc_Id :=
            Uss_Person.Load$socialcard.Load_Sc (
                p_Fn            => UPPER (Clear_Name (p_Ap_FName)),
                p_Ln            => UPPER (Clear_Name (p_Ap_LName)),
                p_Mn            => UPPER (Clear_Name (p_Ap_MName)),
                p_Gender        => NULL,
                p_Nationality   => NULL,
                p_Src_Dt        => NULL,
                p_Birth_Dt      => NULL,
                p_Inn_Num       => p_Ap_Inn,
                p_Inn_Ndt       => 5,
                p_Doc_Ser       => NULL,
                p_Doc_Num       => NULL,
                p_Doc_Ndt       => NULL,
                p_Src           => '35',
                p_Sc_Unique     => l_Sc_Unique,
                p_Mode          => Uss_Person.Load$socialcard.c_Mode_Search,
                p_Sc            => l_Sc_Id);

        IF l_Sc_Id IS NOT NULL
        THEN
            l_Gender :=
                USS_PERSON.API$SC_TOOLS.GET_GENDER (P_SC_ID => l_Sc_Id);
            l_Birth_Dt :=
                USS_PERSON.API$SC_TOOLS.GET_BIRTHDATE (P_SC_ID => l_Sc_Id);
            USS_PERSON.API$SC_TOOLS.Get_Passport (p_Sc_Id    => l_Sc_Id,
                                                  p_Ndt      => l_Ndt,
                                                  p_Seria    => l_Seria,
                                                  p_Number   => l_Number);
        END IF;

        l_Gender := NVL (p_Gender, l_Gender);

        API$APPEAL.Save_Person (
            p_App_Id        => l_App_Id,
            p_App_Ap        => l_Ap_Id,
            p_App_Tp        => Api$appeal.c_App_Tp_Applicant,
            p_App_Inn       => p_Ap_Inn,
            p_App_Ndt       => l_Ndt,
            p_App_Doc_Num   =>
                CASE
                    WHEN NVL (p_Ap_Inn_Refusal, 'F') = 'T' THEN p_Ap_Inn
                    ELSE l_Seria || l_Number
                END,
            p_App_Fn        => p_Ap_FName,
            p_App_Mn        => p_Ap_MName,
            p_App_Ln        => p_Ap_LName,
            p_App_Esr_Num   => l_Sc_Unique,
            p_App_Gender    => l_Gender,
            p_App_Vf        => NULL,
            p_App_Sc        => l_Sc_Id,
            p_App_Num       => NULL,
            p_New_Id        => l_App_New_Id);

        l_App_Id := NVL (l_App_Id, l_App_New_Id);

        IF l_Sc_Id IS NOT NULL
        THEN
            SELECT MAX (CASE WHEN nda_class = 'BDT' THEN Nda_Id END),
                   MAX (CASE WHEN nda_class = 'DSN' THEN Nda_Id END)
              INTO l_Birth_Nda, l_Dsn_Nda
              FROM uss_ndi.v_ndi_document_attr
             WHERE nda_ndt = l_Ndt AND nda_class IN ('BDT', 'DSN');

            Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                      p_Apd_Ap    => l_Ap_Id,
                                      p_Apd_Ndt   => l_Ndt,
                                      p_Apd_Doc   => NULL,
                                      p_Apd_Vf    => NULL,
                                      p_Apd_App   => l_App_Id,
                                      p_Com_Wu    => l_Com_Wu,
                                      p_Apd_Dh    => NULL,
                                      p_Apd_Aps   => NULL,
                                      p_New_Id    => l_Apd_New_Id);

            API$APPEAL.Save_Not_Empty_Document_Attr_Dt (
                p_Apda_Ap       => l_Ap_Id,
                p_Apda_Apd      => l_Apd_New_Id,
                p_Apda_Nda      => l_Birth_Nda,
                p_Apda_Val_Dt   => l_Birth_Dt,
                p_New_Id        => l_Apda_New_Id);
            API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                p_Apda_Ap           => l_Ap_Id,
                p_Apda_Apd          => l_Apd_New_Id,
                p_Apda_Nda          => l_Dsn_Nda,
                p_Apda_Val_String   => l_Seria || l_Number,
                p_New_Id            => l_Apda_New_Id);
        END IF;

        IF NVL (p_Ap_Inn_Refusal, 'F') = 'T'
        THEN
            Api$appeal.Save_Document (
                p_Apd_Id    => NULL,
                p_Apd_Ap    => l_Ap_Id,
                p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_KEP_Identity,
                p_Apd_Doc   => NULL,
                p_Apd_Vf    => NULL,
                p_Apd_App   => l_App_Id,
                p_Com_Wu    => l_Com_Wu,
                p_Apd_Dh    => NULL,
                p_Apd_Aps   => NULL,
                p_New_Id    => l_Apd_New_Id);

            API$APPEAL.Save_Not_Empty_Document_Attr_Dt (
                p_Apda_Ap       => l_Ap_Id,
                p_Apda_Apd      => l_Apd_New_Id,
                p_Apda_Nda      => 8722,
                p_Apda_Val_Dt   => p_Birth_Dt,
                p_New_Id        => l_Apda_New_Id);
            API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                p_Apda_Ap           => l_Ap_Id,
                p_Apda_Apd          => l_Apd_New_Id,
                p_Apda_Nda          => 8723,
                p_Apda_Val_String   => p_Ap_Inn,
                p_New_Id            => l_Apda_New_Id);
        END IF;

        IF p_Ap_Inn IS NOT NULL AND NVL (p_Ap_Inn_Refusal, 'F') = 'F'
        THEN
            Api$appeal.Save_Document (
                p_Apd_Id    => NULL,
                p_Apd_Ap    => l_Ap_Id,
                p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_RNOKPP,
                p_Apd_Doc   => NULL,
                p_Apd_Vf    => NULL,
                p_Apd_App   => l_App_Id,
                p_Com_Wu    => l_Com_Wu,
                p_Apd_Dh    => NULL,
                p_Apd_Aps   => NULL,
                p_New_Id    => l_Apd_New_Id);
            API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                p_Apda_Ap           => l_Ap_Id,
                p_Apda_Apd          => l_Apd_New_Id,
                p_Apda_Nda          => 1,
                p_Apda_Val_String   => p_Ap_Inn,
                p_New_Id            => l_Apda_New_Id);
        END IF;

        IF NVL (p_Ap_Inn_Refusal, 'F') = 'T'
        THEN
            Api$appeal.Save_Document (
                p_Apd_Id    => NULL,
                p_Apd_Ap    => l_Ap_Id,
                p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_RNOKPP_Refusal,
                p_Apd_Doc   => NULL,
                p_Apd_Vf    => NULL,
                p_Apd_App   => l_App_Id,
                p_Com_Wu    => l_Com_Wu,
                p_Apd_Dh    => NULL,
                p_Apd_Aps   => NULL,
                p_New_Id    => l_Apd_New_Id);
        END IF;

        Api$appeal.Save_Document (
            p_Apd_Id    => NULL,
            p_Apd_Ap    => l_Ap_Id,
            p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_rehab_Tool,
            p_Apd_Doc   => NULL,
            p_Apd_Vf    => NULL,
            p_Apd_App   => l_App_Id,
            p_Com_Wu    => l_Com_Wu,
            p_Apd_Dh    => NULL,
            p_Apd_Aps   => NULL,
            p_New_Id    => l_Apd_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8731,
            p_Apda_Val_String   => p_is_Address_Live_eq_Reg,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 9016,
            p_Apda_Val_String   => p_Is_Vpo_Addr_Eq_Fact_Addr,
            p_New_Id            => l_Apda_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Id (
            p_Apda_Ap       => l_Ap_Id,
            p_Apda_Apd      => l_Apd_New_Id,
            p_Apda_Nda      => 8634,
            p_Apda_Val_Id   => p_Ap_Live_City,
            p_New_Id        => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8682,
            p_Apda_Val_String   => p_Ap_Live_Index,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8635,
            p_Apda_Val_String   => p_Ap_Live_Street,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8636,
            p_Apda_Val_String   => p_Ap_Live_Building,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8637,
            p_Apda_Val_String   => p_Ap_Live_Block,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8638,
            p_Apda_Val_String   => p_Ap_Live_Flat,
            p_New_Id            => l_Apda_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Id (
            p_Apda_Ap       => l_Ap_Id,
            p_Apda_Apd      => l_Apd_New_Id,
            p_Apda_Nda      => 8725,
            p_Apda_Val_Id   => p_Ap_Reg_City,
            p_New_Id        => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8726,
            p_Apda_Val_String   => p_Ap_Reg_Index,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8727,
            p_Apda_Val_String   => p_Ap_Reg_Street,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8728,
            p_Apda_Val_String   => p_Ap_Reg_Building,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8729,
            p_Apda_Val_String   => p_Ap_Reg_Block,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8730,
            p_Apda_Val_String   => p_Ap_Reg_Flat,
            p_New_Id            => l_Apda_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8639,
            p_Apda_Val_String   => p_Ap_Phone,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8640,
            p_Apda_Val_String   => p_Ap_Phone_Add,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8735,
            p_Apda_Val_String   => l_Ap_Tool_List,
            p_New_Id            => l_Apda_New_Id);

        Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                  p_Apd_Ap    => l_Ap_Id,
                                  p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_Ankt,
                                  p_Apd_Doc   => NULL,
                                  p_Apd_Vf    => NULL,
                                  p_Apd_App   => l_App_Id,
                                  p_Com_Wu    => l_Com_Wu,
                                  p_Apd_Dh    => NULL,
                                  p_Apd_Aps   => NULL,
                                  p_New_Id    => l_Apd_New_Id);

        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8617,
            p_Apda_Val_String   => l_Apda_8617_value,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 8786,
            p_Apda_Val_String   => p_Is_Vpo_Exist,
            p_New_Id            => l_Apda_New_Id);
        API$APPEAL.Save_Not_Empty_Document_Attr_Str (
            p_Apda_Ap           => l_Ap_Id,
            p_Apda_Apd          => l_Apd_New_Id,
            p_Apda_Nda          => 9010,
            p_Apda_Val_String   => p_Is_Regf_Addr_Not_Eq_fact_Addr,
            p_New_Id            => l_Apda_New_Id);

        Api$appeal.Save_Document (
            p_Apd_Id    => NULL,
            p_Apd_Ap    => l_Ap_Id,
            p_Apd_Ndt   => Api$appeal.c_Apd_Ndt_rehab_Tool_outcome,
            p_Apd_Doc   => NULL,
            p_Apd_Vf    => NULL,
            p_Apd_App   => l_App_Id,
            p_Com_Wu    => l_Com_Wu,
            p_Apd_Dh    => NULL,
            p_Apd_Aps   => NULL,
            p_New_Id    => l_Apd_New_Id);

        IF p_Ap_Documents IS NOT NULL
        THEN
            --Парсинг документів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Ap_Documents',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_Ap_Documents
                USING p_Ap_Documents;

            Updatexmlsqllog (Package_Name, 't_Ap_Documents', p_Ap_Documents);

            FOR Rec IN (SELECT d.*
                          FROM TABLE (l_Ap_Documents) d)
            LOOP
                --Зберігаємо документ
                Api$appeal.Merge_Document (
                    p_Apd_Id    => Rec.Apd_Id,
                    p_Apd_Ap    => l_Ap_Id,
                    p_Apd_Ndt   => Rec.Apd_Ndt,
                    p_Apd_Doc   => Rec.Apd_Doc,
                    p_Apd_Vf    => NULL,
                    p_Apd_App   => l_App_Id,
                    p_New_Id    => Rec.Apd_Id,
                    p_Com_Wu    => l_Com_Wu,
                    p_Apd_Dh    => Rec.Apd_Dh,
                    p_Apd_Aps   => NULL,
                    p_Apd_Tmp_To_Del_File   =>
                        CASE
                            WHEN Rec.Sign_Info IS NOT NULL
                            THEN
                                Tools.Convertc2b (Rec.Sign_Info)
                        END);

                IF Rec.Apd_Attachments IS NOT NULL
                THEN
                    --Зберігаємо вкладення документа
                    Uss_Doc.Api$documents.Save_Attach_List (
                        p_Doc_Id        => Rec.Apd_Doc,
                        p_Dh_Id         => NULL,
                        p_Attachments   => Rec.Apd_Attachments);
                END IF;
            END LOOP;
        END IF;

        API$APPEAL.Save_Service (
            p_Aps_Id    => NULL,
            p_Aps_Nst   => Api$appeal.c_Aps_Nst_rehab_Tool,
            p_Aps_Ap    => l_Ap_Id,
            p_Aps_St    => 'R',
            p_New_Id    => l_Aps_New_Id);


        --Пишемо повідомлення в журнал
        Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                              p_Apl_Hs        => l_Hs_Id,
                              p_Apl_St        => l_Ap_St,
                              p_Apl_Message   => CHR (38) || '2');



        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (l_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2);
    EXCEPTION
        WHEN Api$appeal.Ex_Opt_Block_Viol
        THEN
            Raise_Application_Error (
                -20000,
                Ikis_Message_Util.GET_MESSAGE (Msg_Opt_Block_Viol));
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ РОЗПИСКИ
    ---------------------------------------------------------------------
    PROCEDURE Save_Note (p_Ap_Id NUMBER, p_Note_Document CLOB)
    IS
        c_Note_Ndt   CONSTANT NUMBER := 127;
        l_Note_Document       r_Ap_Document;
        l_Com_Wu              NUMBER;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Save_Note');

        l_Com_Wu := Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid);

        EXECUTE IMMEDIATE Type2xmltable (Package_Name, 'r_Ap_Document', TRUE)
            INTO l_Note_Document
            USING p_Note_Document;

        Api$appeal.Save_Document (p_Apd_Id    => l_Note_Document.Apd_Id,
                                  p_Apd_Ap    => p_Ap_Id,
                                  p_Apd_Ndt   => c_Note_Ndt,
                                  p_Apd_Doc   => l_Note_Document.Apd_Doc,
                                  p_Apd_Vf    => NULL,
                                  p_Apd_App   => l_Note_Document.Apd_App,
                                  p_New_Id    => l_Note_Document.Apd_Id,
                                  p_Com_Wu    => l_Com_Wu,
                                  p_Apd_Dh    => l_Note_Document.Apd_Dh,
                                  p_Apd_Aps   => NULL);

        IF l_Note_Document.Apd_Attachments IS NOT NULL
        THEN
            --Зберігаємо вкладення документа
            Uss_Doc.Api$documents.Save_Attach_List (
                p_Doc_Id        => l_Note_Document.Apd_Doc,
                p_Dh_Id         => NULL,
                p_Attachments   => l_Note_Document.Apd_Attachments);
        END IF;
    END;

    -- info:   поиск персоны
    -- params: p_inn - ИНН
    --         p_doc_num - номер и серия паспорта
    --         p_esr_num - еср номер
    --         p_ln      - фамилия
    --         p_fn      - имя
    --         p_mn      - отчество
    -- note:
    PROCEDURE Search_Person (p_Inn          IN     VARCHAR2,
                             p_Doc_Num      IN     VARCHAR2,
                             p_Esr_Num      IN     VARCHAR2,
                             p_Ln           IN     VARCHAR2,
                             p_Fn           IN     VARCHAR2,
                             p_Mn           IN     VARCHAR2,
                             p_Ndt_Id       IN     NUMBER,
                             p_Gender       IN     VARCHAR2,
                             p_Show_Modal      OUT NUMBER,
                             p_Rn_Id           OUT NUMBER,
                             Res_Cur           OUT SYS_REFCURSOR)
    IS
        l_Found_Cnt           INTEGER;

        l_Err_Inn_Exception   EXCEPTION;
        l_Err_Dn_Exception    EXCEPTION;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Search_Person');

        -- Контроль на корректность ИНН
        IF NOT REGEXP_LIKE (p_Inn, '^(\d){10}$')
        THEN
            RAISE l_Err_Inn_Exception;
        END IF;

        -- Контроль на корректность Паспорта
        /*  IF NOT ((Regexp_Like(p_Doc_Num, '^(\d){9}$')) OR -- ид кард
            (Regexp_Like(Substr(p_Doc_Num, 1, 2), '^([ЇІЄҐА-Я]){2}$') AND Regexp_Like(Substr(p_Doc_Num, -6, 6), '^(\d){6}$')) -- паспорт
            )
        THEN
         RAISE l_Err_Dn_Exception;
        END IF;*/

        Uss_Person.Api$socialcard.Search_Sc_By_Params (
            p_Inn          => p_Inn,
            p_Ndt_Id       => p_Ndt_Id,
            p_Doc_Num      => p_Doc_Num,
            p_Fn           => p_Fn,
            p_Ln           => p_Ln,
            p_Mn           => p_Mn,
            p_Esr_Num      => p_Esr_Num,
            p_Gender       => p_Gender,
            p_Found_Cnt    => l_Found_Cnt,
            p_Show_Modal   => p_Show_Modal,
            p_Persons      => Res_Cur);

        IF l_Found_Cnt = 0
        THEN
            --Створюємо запит на пошук особи в РЗО
            Uss_Person.Dnet$exch_Uss2ikis.Reg_Search_Person_Req (
                p_Numident   => p_Inn,
                p_Ln         => p_Ln,
                p_Fn         => p_Fn,
                p_Mn         => p_Mn,
                p_Doc_Tp     => p_Ndt_Id,
                p_Doc_Num    => p_Doc_Num,
                p_Gender     => p_Gender,
                p_Wu_Id      =>
                    Uss_Visit_Context.Getcontext (Uss_Visit_Context.Guid),
                p_Src        => Api$appeal.c_Src_Vst,
                p_Rn_Id      => p_Rn_Id);
        END IF;
    EXCEPTION
        WHEN l_Err_Inn_Exception
        THEN
            Raise_Application_Error (
                -20100,
                'Податковий номер повинен містити 10 цифр.');
        WHEN l_Err_Dn_Exception
        THEN
            Raise_Application_Error (
                -20100,
                'Паспорт повинен містити 9 цифр або 2 літери та 6 цифр.');
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   DBMS_UTILITY.Format_Error_Stack
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    ---------------------------------------------------------------------
    --            Отримання результату пошуку особи в РЗО
    ---------------------------------------------------------------------
    PROCEDURE Get_Person_Search_Result (p_Rn_Id   IN     NUMBER,
                                        p_Rn_St      OUT VARCHAR2,
                                        Res_Cur      OUT SYS_REFCURSOR)
    IS
        l_Esr_Num      Ap_Person.App_Esr_Num%TYPE;
        l_Found_Cnt    NUMBER;
        l_Show_Modal   NUMBER;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Person_Search_Result');
        --Отримуємо статус запиту та ПЕОКЗО
        Uss_Person.Dnet$exch_Uss2ikis.Get_Person_Search_Result (
            p_Rn_Id     => p_Rn_Id,
            p_Rn_St     => p_Rn_St,
            p_Esr_Num   => l_Esr_Num);
        --Отримуємо дані особи з ЕСР за ПЕОКЗО
        Uss_Person.Api$socialcard.Search_Sc_By_Params (
            p_Inn          => NULL,
            p_Ndt_Id       => NULL,
            p_Doc_Num      => NULL,
            p_Fn           => NULL,
            p_Ln           => NULL,
            p_Mn           => NULL,
            p_Esr_Num      => l_Esr_Num,
            p_Gender       => NULL,
            p_Found_Cnt    => l_Found_Cnt,
            p_Show_Modal   => l_Show_Modal,
            p_Persons      => Res_Cur);
    END;

    -- #70852: Создание временной социальной карточки особи при регистрации звернення
    PROCEDURE Create_Person (p_Inn        IN     VARCHAR2,
                             p_Ndt_Id     IN     VARCHAR2,
                             p_Doc_Num    IN     VARCHAR2,
                             p_Fn         IN     VARCHAR2,
                             p_Ln         IN     VARCHAR2,
                             p_Mn         IN     VARCHAR2,
                             p_Esr_Num    IN     VARCHAR2,
                             p_Gender     IN     VARCHAR2,
                             p_Birth_Dt   IN     DATE,
                             p_Mode       IN     NUMBER,
                             p_Sc_Id         OUT NUMBER)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Create_Person');
        Uss_Person.Api$socialcard.Register_Temporary_Card (p_Inn,
                                                           p_Ndt_Id,
                                                           p_Doc_Num,
                                                           p_Fn,
                                                           p_Ln,
                                                           p_Mn,
                                                           p_Esr_Num,
                                                           p_Gender,
                                                           p_Birth_Dt,
                                                           p_Mode,
                                                           p_Sc_Id);
        --sho, 29.12.2024
        uss_person.api$socialcard.Init_Sc_Info (p_Sc_Id => p_Sc_Id);
    END;

    PROCEDURE Register_Doc_Hist (p_Doc_Id NUMBER, p_Dh_Id OUT NUMBER)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Register_Doc_Hist');
        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => p_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => NULL,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   =>
                Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => Tools.Getcurrwu,
            p_Dh_Src         => Api$appeal.c_Src_Vst,
            p_New_Id         => p_Dh_Id);
    END;

    PROCEDURE Get_Ap_Log (p_Ap_Id            Appeal.Ap_Id%TYPE,
                          p_Log_Cursor   OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Ap_Log');

        OPEN p_Log_Cursor FOR
              SELECT Apl_Id,
                     Apl_Tp,
                     Hs_Dt,
                     o.Dic_Name                  AS Old_Status_Name,
                     n.Dic_Name                  AS New_Status_Name,
                     CASE
                         WHEN Apl_Tp = Api$appeal.c_Apl_Tp_Terror
                         THEN
                                'Технічна помилка. Інформація для розробника: код події=('
                             || Apl_Id
                             || '). Будь ласка, зверніться до розробника'
                         ELSE
                             Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                 Apl_Message)
                     END                         AS Apl_Message,
                     COALESCE (Tools.Getuserlogin (Hs_Wu),
                               Ikis_Rbm.Tools.Getcupib (Hs_Cu),
                               'Автоматично')    AS Apl_Hs_Author
                FROM v_Appeal,
                     v_Ap_Log,
                     Uss_Ndi.v_Ddn_Ap_St n,
                     Uss_Ndi.v_Ddn_Ap_St o,
                     Uss_Visit.Histsession
               WHERE     Apl_St = n.Dic_Value(+)
                     AND Apl_St_Old = o.Dic_Value(+)
                     AND Apl_Hs = Hs_Id(+)
                     AND Apl_Ap = Ap_Id
                     AND Apl_Ap = p_Ap_Id
            ORDER BY Hs_Dt, Apl_Id;
    END;

    -- #69968: вичитка декларації по зверненню
    PROCEDURE Get_Declaration (p_Ap_Id       IN     NUMBER,
                               Decl_Cur         OUT SYS_REFCURSOR,
                               Person_Cur       OUT SYS_REFCURSOR,
                               Inc_Cur          OUT SYS_REFCURSOR,
                               Land_Cur         OUT SYS_REFCURSOR,
                               Living_Cur       OUT SYS_REFCURSOR,
                               Other_Cur        OUT SYS_REFCURSOR,
                               Spend_Cur        OUT SYS_REFCURSOR,
                               Vehicle_Cur      OUT SYS_REFCURSOR,
                               Alimony_Cur      OUT SYS_REFCURSOR)
    IS
        l_Id   NUMBER;
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Get_Declaration');

        SELECT MAX (Apr_Id)
          INTO l_Id
          FROM Ap_Declaration t
         WHERE t.Apr_Ap = p_Ap_Id;

        OPEN Decl_Cur FOR SELECT *
                            FROM Ap_Declaration t
                           WHERE t.Apr_Ap = p_Ap_Id;

        OPEN Person_Cur FOR
            SELECT *
              FROM Apr_Person t
             WHERE t.Aprp_Apr = l_Id AND t.History_Status = 'A';

        OPEN Inc_Cur FOR SELECT *
                           FROM Apr_Income t
                          WHERE t.Apri_Apr = l_Id AND t.History_Status = 'A';

        OPEN Land_Cur FOR SELECT *
                            FROM Apr_Land_Plot t
                           WHERE t.Aprt_Apr = l_Id AND t.History_Status = 'A';

        OPEN Living_Cur FOR
            SELECT *
              FROM Apr_Living_Quarters t
             WHERE t.Aprl_Apr = l_Id AND t.History_Status = 'A';

        OPEN Other_Cur FOR
            SELECT *
              FROM Apr_Other_Income t
             WHERE t.Apro_Apr = l_Id AND t.History_Status = 'A';

        OPEN Spend_Cur FOR
            SELECT *
              FROM Apr_Spending t
             WHERE t.Aprs_Apr = l_Id AND t.History_Status = 'A';

        OPEN Vehicle_Cur FOR
            SELECT *
              FROM Apr_Vehicle t
             WHERE t.Aprv_Apr = l_Id AND t.History_Status = 'A';

        OPEN Alimony_Cur FOR
            SELECT *
              FROM Apr_Alimony t
             WHERE t.Apra_Apr = l_Id AND t.History_Status = 'A';
    END;

    -- #70521: "Повернути на довведення"
    PROCEDURE Return_Appeals (p_Ap_Id IN NUMBER)
    IS
        l_St            VARCHAR2 (10);
        l_Is_External   VARCHAR2 (10);
        l_Src           VARCHAR2 (10);
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Return_Appeals');

        SELECT Ap_St, Ap_Is_Ext_Process, Ap_Src
          INTO l_St, l_Is_External, l_Src
          FROM Appeal t
         WHERE t.Ap_Id = p_Ap_Id;

        IF l_Src = Api$appeal.c_Src_Diia AND l_is_external = 'T'
        THEN
            Raise_Application_Error (
                -20000,
                'Операція заборонена для звернень з джерелом "Дія"');
        END IF;

        IF (l_St NOT IN ('P', 'B'))
        THEN
            Raise_Application_Error (
                -20000,
                'Звернення не можна повернути в поточному стані!');
        END IF;

        -- #81791 - для зовнішніх звернень повертати на W
        UPDATE Appeal
           SET Ap_St = 'J' --CASE WHEN l_is_external = 1 THEN 'W' ELSE 'J' END
         WHERE Ap_Id = p_Ap_Id AND (Ap_St <> 'J' OR Ap_St IS NULL);

        --#73983 2021,12,09
        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => Tools.Gethistsession,
                              p_Apl_St        => 'J',
                              p_Apl_Message   => CHR (38) || '42',
                              p_Apl_St_Old    => l_St);
    END;

    -- #117308: "Повернути на довведення для ТГ/ЦНАП"
    PROCEDURE Return_Appeals_Tsnap (p_Ap_Id IN NUMBER)
    IS
        l_St            VARCHAR2 (10);
        l_Is_External   VARCHAR2 (10);
        l_Src           VARCHAR2 (10);
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Return_Appeals_Tsnap');

        SELECT Ap_St
          INTO l_St
          FROM Appeal t
         WHERE t.Ap_Id = p_Ap_Id;

        IF (l_St NOT IN ('RR'))
        THEN
            Raise_Application_Error (
                -20000,
                'Звернення не можна повернути в поточному стані!');
        END IF;

        UPDATE Appeal
           SET Ap_St = 'R'
         WHERE Ap_Id = p_Ap_Id AND (Ap_St <> 'R' OR Ap_St IS NULL);

        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => Tools.Gethistsession,
                              p_Apl_St        => 'R',
                              p_Apl_Message   => CHR (38) || '42',
                              p_Apl_St_Old    => l_St);
    END;

    -- #81791: "Повернути на СГ"
    PROCEDURE Return_Appeal_To_Sg (p_Ap_Id IN NUMBER)
    IS
        l_St            VARCHAR2 (10);
        l_Is_External   VARCHAR2 (10);
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Return_Appeal_To_SG');

        SELECT Ap_St,
               CASE
                   WHEN    t.Ap_Is_Ext_Process = 'T'
                        OR t.Ap_Src IN
                               (Api$appeal.c_Src_Community,
                                Api$appeal.c_Src_Diia)
                   THEN
                       'T'
                   ELSE
                       'F'
               END
          INTO l_St, l_Is_External
          FROM Appeal t
         WHERE t.Ap_Id = p_Ap_Id;

        IF (l_St NOT IN ('B'))
        THEN
            Raise_Application_Error (
                -20000,
                'Звернення не можна повернути в поточному стані!');
        END IF;

        IF (l_Is_External != 'T')
        THEN
            Raise_Application_Error (
                -20000,
                'Звернення не можна повернути в СГ! Звернення не приходило з Дії/СГ.');
        END IF;

        UPDATE Appeal
           SET Ap_St = 'W'
         WHERE Ap_Id = p_Ap_Id AND (Ap_St <> 'W' OR Ap_St IS NULL);

        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => Tools.Gethistsession,
                              p_Apl_St        => 'W',
                              p_Apl_Message   => CHR (38) || '42',
                              p_Apl_St_Old    => l_St);
    END;

    -- створення дублікату звернення
    PROCEDURE Duplicate_Appeal (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Duplicate_Appeal');
        Api$appeal.Duplicate_Appeal (p_Ap_Id, p_New_Ap);
    END;

    -- #97069: створення дублікату звернення "Звернення іншого батька"
    PROCEDURE Duplicate_Appeal_ANF (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER)
    IS
    BEGIN
        Tools.Writemsg ('Dnet$appeal.Duplicate_Appeal_ANF');
        Api$appeal.Duplicate_Appeal_ANF (p_Ap_Id, p_New_Ap);
    END;

    -- #82496: Визначення необхідності заповнення вкладки «Декларація»
    FUNCTION Get_Isneed_Income (p_Ap_Id NUMBER, p_Ap_Tp VARCHAR2)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        IF p_Ap_Tp != 'SS'
        THEN
            l_Rez := 1;
        ELSE
            SELECT COUNT (1)
              INTO l_Rez
              FROM Ap_Person
                   JOIN Ap_Document
                       ON     Apd_App = App_Id
                          AND Apd_Ndt IN (801, 802, 803)
                          AND Ap_Document.History_Status = 'A'
                   JOIN Ap_Document_Attr
                       ON     Apda_Apd = Apd_Id
                          AND Apda_Nda IN (1871, 1948, 2528)
                          AND Ap_Document_Attr.History_Status = 'A'
             WHERE     App_Ap = p_Ap_Id
                   AND Ap_Person.History_Status = 'A'
                   AND NVL (Apda_Val_String, 'F') = 'T';
        END IF;

        RETURN SIGN (l_Rez);
    END;

    -- #117306 повернення з ОСЗН до org_to ЦНАП/ТГ
    PROCEDURE return_to_tsnap (p_ap_id IN NUMBER, p_msg IN VARCHAR2)
    IS
        l_wu            NUMBER;
        l_ap_st         VARCHAR2 (10);
        l_org_to        NUMBER;
        l_ap_dest_org   NUMBER;
        l_org           NUMBER := tools.GetCurrOrg;
    BEGIN
        SELECT ap_st, t.ap_dest_org, p.org_to
          INTO l_ap_st, l_ap_dest_org, l_org_to
          FROM appeal t JOIN v_opfu p ON (p.org_id = t.com_org)
         WHERE t.ap_id = p_ap_id;

        IF (l_ap_st != 'J')
        THEN
            raise_application_error (
                -20000,
                'Повернення можливе лише в стані "Реєстрація в роботі"');
        END IF;

        IF (l_ap_dest_org != l_org)
        THEN
            raise_application_error (
                -20000,
                'Не можна перевести звернення з чужого ОСЗН на доопрацювання!');
        END IF;

        IF (l_org_to NOT IN (33, 35))
        THEN
            raise_application_error (
                -20000,
                'Не можна перевести звернення, яке було створене не в ЦНАП/ГТ на доопрацювання!');
        END IF;

        SELECT MAX (hs_wu)
          INTO l_wu
          FROM (SELECT FIRST_VALUE (hs_wu) OVER (ORDER BY h.hs_dt DESC)    AS hs_wu
                  FROM ap_log t JOIN histsession h ON (h.hs_id = t.apl_hs)
                 WHERE     t.apl_ap = p_ap_id
                       AND t.apl_st = 'J'
                       AND t.apl_st_old = 'R');

        IF (l_wu IS NOT NULL)
        THEN
            UPDATE appeal t
               SET com_wu = l_wu, ap_st = 'RR'
             WHERE t.ap_id = p_ap_id;

            --Пишемо повідомлення в журнал
            Api$appeal.Write_Log (
                p_Apl_Ap        => p_Ap_Id,
                p_Apl_Hs        => tools.GetHistSession,
                p_Apl_St        => 'R',
                p_apl_st_old    => l_ap_st,
                p_Apl_Message   => CHR (38) || '333#' || p_msg,
                p_Apl_Tp        => 'SYS');
        ELSE
            raise_application_error (
                -20000,
                'Не знайдено користувача на кого перевести!');
        END IF;
    END;

    -- #117321 взяти в роботу в ОСЗН звернення ЦНАП/ТГ
    PROCEDURE get_to_work (p_ap_id IN NUMBER)
    IS
        l_wu            NUMBER := tools.GetCurrWu;
        l_ap_st         VARCHAR2 (10);
        l_org_to        NUMBER;
        l_ap_dest_org   NUMBER;
        l_org           NUMBER := tools.GetCurrOrg;
    BEGIN
        SELECT ap_st, t.ap_dest_org, p.org_to
          INTO l_ap_st, l_ap_dest_org, l_org_to
          FROM appeal t JOIN v_opfu p ON (p.org_id = t.com_org)
         WHERE t.ap_id = p_ap_id;

        IF (l_ap_st != 'J')
        THEN
            raise_application_error (
                -20000,
                'Взяти в роботу можливо лише в стані "Реєстрація в роботі"');
        END IF;

        IF (l_ap_dest_org != l_org)
        THEN
            raise_application_error (
                -20000,
                'Не можна взяти в роботу звернення з чужого ОСЗН!');
        END IF;

        IF (l_org_to NOT IN (33, 35))
        THEN
            raise_application_error (
                -20000,
                'Не можна взяти в роботу звернення, яке було створене не в ЦНАП/ГТ!');
        END IF;

        UPDATE appeal t
           SET t.com_wu = l_wu
         WHERE t.ap_id = p_ap_id;
    END;
BEGIN
    NULL;
END Dnet$appeal;
/