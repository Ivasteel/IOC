/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$APPEAL_PORTAL
IS
    -- Author  : SHOST
    -- Created : 02.03.2023 11:59:07
    -- Purpose : Збереження та перегляд заяв порталом МСП

    Package_Name                CONSTANT VARCHAR2 (100) := 'DNET$APPEAL_PORTAL';

    c_Xml_Dt_Fmt                CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    c_Cabinet_Ss_Provider       CONSTANT NUMBER := 2;                 --'PSS';
    c_Cabinet_Ss_Recipient      CONSTANT NUMBER := 3;                 --'RSS';

    c_Ap_Type_Extract           CONSTANT VARCHAR2 (20) := 'D';
    c_Ap_Subtype_Prov_Reg       CONSTANT VARCHAR2 (20) := 'GA';
    c_Ap_Subtype_Prov_Edit      CONSTANT VARCHAR2 (20) := 'GU';
    c_Ap_Subtype_Prov_Exclude   CONSTANT VARCHAR2 (20) := 'GD';
    c_Ap_Subtype_Prov_Extract   CONSTANT VARCHAR2 (20) := 'DE';
    c_Ap_Subtype_Prov_Dlc       CONSTANT VARCHAR2 (20) := 'SC';


    c_Ap_Subtype_Rec_Ss         CONSTANT VARCHAR2 (20) := 'SS';

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
        Deleted            NUMBER
    );

    TYPE t_Ap_Document_Attrs IS TABLE OF r_Ap_Document_Attr;

    --Документи
    TYPE r_Ap_Document IS RECORD
    (
        Apd_Id        Ap_Document.Apd_Id%TYPE,
        Apd_Ndt       Ap_Document.Apd_Ndt%TYPE,
        Apd_Doc       Ap_Document.Apd_Doc%TYPE,
        Apd_App       Ap_Document.Apd_App%TYPE,
        Apd_Dh        Ap_Document.Apd_Dh%TYPE,
        Apd_Aps       Ap_Document.Apd_Aps%TYPE,
        Attributes    XMLTYPE,
        Deleted       NUMBER
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
    TYPE r_Declaration_Xml_Dto IS RECORD
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

    --Контейнер декларації
    TYPE r_Declaration_Dto IS RECORD
    (
        Declaration       r_Ap_Declaration,
        Persons           t_Apr_Persons,
        Incomes           t_Apr_Incomes,
        Land_Plots        t_Apr_Land_Plots,
        Living_Qurters    t_Apr_Living_Quarters,
        Other_Incomes     t_Apr_Other_Incomes,
        Spendings         t_Apr_Spendings,
        Vehicles          t_Apr_Vehicles,
        Alimonies         t_Apr_Alimonies
    );

    TYPE r_Id IS RECORD
    (
        Id    NUMBER
    );

    TYPE t_Ids IS TABLE OF r_Id;

    TYPE r_Sc_Doc IS RECORD
    (
        Ndt_Id     NUMBER,
        Doc_Id     NUMBER (14),
        Dh_Id      NUMBER (14),
        Doc_Num    VARCHAR2 (4000)
    );

    TYPE t_Sc_Docs IS TABLE OF r_Sc_Doc;

    FUNCTION Doc_Is_Read_Only (p_Apd_Vf IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Define_Com_Org (p_Ap_Id       IN NUMBER,
                             p_Ap_Tp       IN VARCHAR2 := NULL,
                             p_Ap_Sub_Tp   IN VARCHAR2 := NULL)
        RETURN NUMBER;

    FUNCTION Get_App_Main_Pib (p_Ap_Id NUMBER)
        RETURN VARCHAR2;


    PROCEDURE Save_Appeal (
        p_Ap_Id            IN OUT Appeal.Ap_Id%TYPE,
        p_Ap_Is_Second     IN     Appeal.Ap_Is_Second%TYPE,
        p_Ap_Tp            IN     Appeal.Ap_Tp%TYPE,
        p_Ap_Reg_Dt        IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Com_Org          IN     Appeal.Com_Org%TYPE,
        p_Ap_Services      IN     CLOB,
        p_Ap_Persons       IN     CLOB,
        p_Ap_Payments      IN     CLOB,
        p_Ap_Documents     IN     CLOB,
        p_Ap_Declaration   IN     CLOB,
        p_Messages            OUT SYS_REFCURSOR,
        p_Ap_Src           IN     VARCHAR2 DEFAULT Api$appeal.c_Src_Portal,
        p_Ap_Sub_Tp        IN     VARCHAR2 DEFAULT NULL,
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
        p_Gender                          IN     VARCHAR2 DEFAULT NULL,
        p_Birth_Dt                        IN     DATE DEFAULT NULL,
        p_Ap_Documents                    IN     CLOB DEFAULT NULL,
        p_is_Address_Live_eq_Reg          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Reg_City                     IN     NUMBER DEFAULT NULL,
        p_Ap_Reg_Index                    IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Reg_Street                   IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Reg_Building                 IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Reg_Block                    IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Reg_Flat                     IN     VARCHAR2 DEFAULT NULL,
        p_Is_Vpo_Exist                    IN     VARCHAR2 DEFAULT NULL,
        p_Is_Regf_Addr_Not_Eq_fact_Addr   IN     VARCHAR2 DEFAULT NULL,
        p_Is_Vpo_Addr_Eq_Fact_Addr        IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Live_Index                   IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Send_Ap_To_Vf (p_Ap_Id IN NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Return_Ap_To_Cm (p_Ap_Id           IN NUMBER,
                               p_Return_Reason   IN VARCHAR2,
                               p_Cmes_Owner_Id   IN NUMBER);

    PROCEDURE Return_Appeals (p_Ap_Id IN NUMBER);

    PROCEDURE Approve_Ap (p_Ap_Id IN NUMBER, p_Cmes_Owner_Id IN NUMBER);

    PROCEDURE Get_Ss_Prov_Ap_Subtypes (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Ss_Rec_Ap_Subtypes (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_My_Appeals (p_Cabinet         IN     NUMBER,
                              p_Edrpou          IN     VARCHAR2,
                              p_Rnokpp          IN     VARCHAR2,
                              p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
                              p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
                              p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_St           IN     VARCHAR2 DEFAULT NULL,
                              p_Com_Org         IN     NUMBER DEFAULT NULL,
                              p_App_Pib         IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Subtype      IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Type         IN     VARCHAR2 DEFAULT NULL,
                              p_Res                OUT SYS_REFCURSOR,
                              p_Res_Doc            OUT SYS_REFCURSOR,
                              p_Cmes_Owner_Id   IN     NUMBER DEFAULT NULL,
                              p_Ap_Ap_Main      IN     NUMBER DEFAULT NULL);

    PROCEDURE Get_My_Appeals (p_Cabinet         IN     NUMBER,
                              p_Edrpou          IN     VARCHAR2,
                              p_Rnokpp          IN     VARCHAR2,
                              p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
                              p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
                              p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_St           IN     VARCHAR2 DEFAULT NULL,
                              p_Com_Org         IN     NUMBER DEFAULT NULL,
                              p_App_Pib         IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Subtype      IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Type         IN     VARCHAR2 DEFAULT NULL,
                              p_Res                OUT SYS_REFCURSOR,
                              p_Cmes_Owner_Id   IN     NUMBER DEFAULT NULL,
                              p_Ap_Ap_Main      IN     NUMBER DEFAULT NULL);

    PROCEDURE Get_My_Extract (p_Cabinet         IN     NUMBER,
                              p_Edrpou          IN     VARCHAR2,
                              p_Rnokpp          IN     VARCHAR2,
                              p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
                              p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
                              p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
                              p_Com_Org         IN     NUMBER DEFAULT NULL,
                              p_App_Pib         IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Subtype      IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Tp           IN     VARCHAR2 DEFAULT NULL,
                              p_Res                OUT SYS_REFCURSOR,
                              p_Res_Doc            OUT SYS_REFCURSOR,
                              p_Cmes_Owner_Id   IN     NUMBER DEFAULT NULL);

    PROCEDURE Filter_My_Extract (p_Cabinet         IN NUMBER,
                                 p_Edrpou          IN VARCHAR2,
                                 p_Rnokpp          IN VARCHAR2,
                                 p_Ap_Reg_Start    IN DATE DEFAULT NULL,
                                 p_Ap_Reg_Stop     IN DATE DEFAULT NULL,
                                 p_Ap_Num          IN VARCHAR2 DEFAULT NULL,
                                 p_Com_Org         IN NUMBER DEFAULT NULL,
                                 p_App_Pib         IN VARCHAR2 DEFAULT NULL,
                                 p_Ap_Subtype      IN VARCHAR2 DEFAULT NULL,
                                 p_Ap_Id           IN NUMBER DEFAULT NULL,
                                 p_Cmes_Owner_Id   IN NUMBER DEFAULT NULL);

    PROCEDURE Get_Appeals_For_Approve (
        p_Cmes_Owner_Id   IN     NUMBER DEFAULT NULL,
        p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
        p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
        p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_St           IN     VARCHAR2 DEFAULT NULL,
        p_Com_Org         IN     NUMBER DEFAULT NULL,
        p_App_Pib         IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Subtype      IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Tp           IN     VARCHAR2 DEFAULT NULL,
        p_Res                OUT SYS_REFCURSOR);

    FUNCTION Get_Ap_Modify_Dt (p_Ap_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Wu_Pib (p_Wu_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Appeal_Card (
        p_Ap_Id            IN     VARCHAR2,
        p_Cabinet          IN     NUMBER,
        p_Edrpou           IN     VARCHAR2,
        p_Rnokpp           IN     VARCHAR2,
        p_Main_Cur            OUT SYS_REFCURSOR,
        p_Ser_Cur             OUT SYS_REFCURSOR,
        p_Pers_Cur            OUT SYS_REFCURSOR,
        p_Docs_Cur            OUT SYS_REFCURSOR,
        p_Docs_Attr_Cur       OUT SYS_REFCURSOR,
        p_Docs_Files_Cur      OUT SYS_REFCURSOR,
        p_Log_Cur             OUT SYS_REFCURSOR,
        p_Cmes_Owner_Id    IN     NUMBER DEFAULT NULL,
        p_Access_Checked   IN     VARCHAR2 DEFAULT NULL,
        p_Pay_Cur             OUT SYS_REFCURSOR);

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

    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR);

    FUNCTION Check_File_Access (p_File_Code   IN VARCHAR2,
                                p_Cabinet     IN VARCHAR2,
                                p_Edrpou      IN VARCHAR2,
                                p_Rnokpp      IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Check_Ap_Access (p_Ap_Id           IN NUMBER,
                              p_Cabinet         IN NUMBER,
                              p_Edrpou          IN VARCHAR2 DEFAULT NULL,
                              p_Rnokpp          IN VARCHAR2 DEFAULT NULL,
                              p_Cmes_Owner_Id   IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN;

    FUNCTION Get_Ap_Rnspm (p_Ap_Id IN NUMBER)
        RETURN NUMBER;

    ---------------------------------------------------------------------
    --    ОТРИМАННЯ ЖУРНАЛУ ОБРОБКИ ТА ВЕРИФІКАЦІЇ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Log (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------
    --    ОТРИМАННЯ ЖУРНАЛУ ОБРОБКИ ТА ВЕРИФІКАЦІЇ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Log_By_SC (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Prefill_Main (p_Ap_Tp           IN     VARCHAR2,
                                p_Ap_Sub_Tp       IN     VARCHAR2,
                                p_App_Tp          IN     VARCHAR2,
                                p_Pers_Cur           OUT SYS_REFCURSOR,
                                p_Pers_Addr_Cur      OUT SYS_REFCURSOR,
                                p_Ap_Attrs           OUT SYS_REFCURSOR,
                                p_Ankt_Attrs         OUT SYS_REFCURSOR,
                                p_Docs_Cur           OUT SYS_REFCURSOR,
                                p_Attrs_Cur          OUT SYS_REFCURSOR,
                                p_Files_Cur          OUT SYS_REFCURSOR);

    PROCEDURE Get_Prefill_Docs (p_Ap_Tp             IN     VARCHAR2,
                                p_App_Tp            IN     VARCHAR2,
                                p_Services          IN     VARCHAR2,
                                p_Ankt_Attributes   IN     CLOB,
                                p_Docs_Cur             OUT SYS_REFCURSOR,
                                p_Attrs_Cur            OUT SYS_REFCURSOR,
                                p_Files_Cur            OUT SYS_REFCURSOR);

    PROCEDURE SendEmailMessage (p_Email    IN VARCHAR2,
                                p_Header   IN VARCHAR2,
                                p_Msg      IN VARCHAR2);

    PROCEDURE get_org_by_kaot (p_kaot_id    IN     NUMBER,
                               p_org_id        OUT NUMBER,
                               p_org_name      OUT VARCHAR2);

    FUNCTION get_org_by_kaot (p_kaot_id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE get_dzr_by_sc (p_sc_id IN NUMBER, p_res OUT SYS_REFCURSOR);

    PROCEDURE Get_Vpo_Sc_Address (p_sc_id IN NUMBER, p_res OUT SYS_REFCURSOR);
END Dnet$appeal_Portal;
/


GRANT EXECUTE ON USS_VISIT.DNET$APPEAL_PORTAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL_PORTAL TO II01RC_USS_VISIT_PORTAL
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL_PORTAL TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:00:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$APPEAL_PORTAL IS

  PROCEDURE Write_Audit(p_Proc_Name IN VARCHAR2) IS
  BEGIN
    Tools.Writemsg(Package_Name || '.' || p_Proc_Name);
  END;

  FUNCTION To_Money(p_Str VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN To_Number(REPLACE(p_Str, ',', '.'), '9999999999D99999', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END;

  PROCEDURE Updatexmlsqllog(p_Lxs_Pkg_Name  VARCHAR2,
                            p_Lxs_Type_Name VARCHAR2,
                            p_Lxs_Xml       CLOB) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE Logxmlsql Ddd
       SET Ddd.Lxs_Xml = p_Lxs_Xml
     WHERE Lxs_Pkg_Name = p_Lxs_Pkg_Name
       AND Lxs_Type_Name = p_Lxs_Type_Name
       AND Ddd.Lxs_Xml IS NULL;
    COMMIT;
  END;

  ---------------------------------------------------------------------
  --              Парсинг послуг
  ---------------------------------------------------------------------
  FUNCTION Parse_Services(p_Ap_Services IN CLOB) RETURN t_Ap_Services IS
    l_Ap_Services t_Ap_Services;
  BEGIN
    IF p_Ap_Services IS NULL THEN
      RETURN NULL;
    END IF;

    EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Services', TRUE, TRUE) BULK COLLECT
      INTO l_Ap_Services
      USING p_Ap_Services;

    RETURN l_Ap_Services;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000,
                              'Помилка парсингу послуг: ' || Chr(13) || SQLERRM || Chr(13) || Dbms_Utility.Format_Error_Backtrace);
  END;

  ---------------------------------------------------------------------
  --              Парсинг учасників звернення
  ---------------------------------------------------------------------
  FUNCTION Parse_Persons(p_Ap_Persons IN CLOB) RETURN t_Ap_Persons IS
    l_Ap_Persons t_Ap_Persons;
  BEGIN
    IF p_Ap_Persons IS NULL THEN
      RETURN NULL;
    END IF;

    EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Persons', TRUE, TRUE) BULK COLLECT
      INTO l_Ap_Persons
      USING p_Ap_Persons;

    RETURN l_Ap_Persons;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000,
                              'Помилка парсингу учасників звернення: ' || Chr(13) || SQLERRM || Chr(13) ||
                              Dbms_Utility.Format_Error_Backtrace);
  END;

  ---------------------------------------------------------------------
  --              Парсинг способів виплат
  ---------------------------------------------------------------------
  FUNCTION Parse_Payments(p_Ap_Payments IN CLOB) RETURN t_Ap_Payments IS
    l_Ap_Payments t_Ap_Payments;
  BEGIN
    IF p_Ap_Payments IS NULL THEN
      RETURN NULL;
    END IF;

    EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Payments', TRUE, TRUE) BULK COLLECT
      INTO l_Ap_Payments
      USING p_Ap_Payments;

    RETURN l_Ap_Payments;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000,
                              'Помилка парсингу способів виплат: ' || Chr(13) || SQLERRM || Chr(13) ||
                              Dbms_Utility.Format_Error_Backtrace);
  END;

  ---------------------------------------------------------------------
  --              Парсинг документів
  ---------------------------------------------------------------------
  FUNCTION Parse_Documents(p_Ap_Documents IN CLOB) RETURN t_Ap_Documents IS
    l_Ap_Documents t_Ap_Documents;
  BEGIN
    IF p_Ap_Documents IS NULL THEN
      RETURN NULL;
    END IF;

    Updatexmlsqllog(Package_Name, 't_Ap_Documents', p_Ap_Documents);
    --Парсинг документів
    EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Documents', TRUE, TRUE) BULK COLLECT
      INTO l_Ap_Documents
      USING p_Ap_Documents;

    RETURN l_Ap_Documents;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000,
                              'Помилка парсингу документів: ' || Chr(13) || SQLERRM || Chr(13) ||
                              Dbms_Utility.Format_Error_Backtrace);
  END;

  ---------------------------------------------------------------------
  --              Парсинг атрибутів документа
  ---------------------------------------------------------------------
  FUNCTION Parse_Document_Attr(p_Ap_Document_Attrs IN Xmltype) RETURN t_Ap_Document_Attrs IS
    l_Ap_Document_Attrs t_Ap_Document_Attrs;
  BEGIN
    IF p_Ap_Document_Attrs IS NULL THEN
      RETURN NULL;
    END IF;

    --Парсимо атрибути документа
    EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Document_Attrs', TRUE, FALSE, FALSE) BULK COLLECT
      INTO l_Ap_Document_Attrs
      USING p_Ap_Document_Attrs;

    RETURN l_Ap_Document_Attrs;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000,
                              'Помилка парсингу атрибутів документа: ' || Chr(13) || SQLERRM || Chr(13) ||
                              Dbms_Utility.Format_Error_Backtrace);
  END;

  ---------------------------------------------------------------------
  --              Парсинг декларації
  ---------------------------------------------------------------------
  FUNCTION Parse_Declaration(p_Declaration_Dto IN CLOB) RETURN r_Declaration_Dto IS
    l_Declaration_Xml_Dto r_Declaration_Xml_Dto;
    l_Declaration_Dto     r_Declaration_Dto;
  BEGIN
    IF p_Declaration_Dto IS NULL THEN
      RETURN NULL;
    END IF;

    SELECT Declaration, Persons, Incomes, Land_Plots, Living_Quarters, Other_Incomes, Spendings, Vehicles, Alimonies
      INTO l_Declaration_Xml_Dto
      FROM Xmltable('/*' Passing Xmltype(p_Declaration_Dto) Columns
                     --
                     Declaration Xmltype Path 'Declaration',
                     Persons Xmltype Path 'Persons',
                     Incomes Xmltype Path 'Incomes',
                     Land_Plots Xmltype Path 'LandPlots',
                     Living_Quarters Xmltype Path 'LivingQuarters',
                     Other_Incomes Xmltype Path 'OtherIncomes',
                     Spendings Xmltype Path 'Spendings',
                     Vehicles Xmltype Path 'Vehicles',
                     Alimonies Xmltype Path 'Alimonies');

    --Парсинг шапки декларації
    IF l_Declaration_Xml_Dto.Declaration IS NOT NULL THEN
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 'r_Ap_Declaration', TRUE, FALSE)
        INTO l_Declaration_Dto.Declaration
        USING l_Declaration_Xml_Dto.Declaration;
    END IF;

    IF l_Declaration_Xml_Dto.Persons IS NOT NULL THEN
      --Парсинг членів родини
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Persons', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Persons
        USING l_Declaration_Xml_Dto.Persons;
    END IF;

    IF l_Declaration_Xml_Dto.Incomes IS NOT NULL THEN
      --Парсинг доходів членів родини
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Incomes', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Incomes
        USING l_Declaration_Xml_Dto.Incomes;
    END IF;

    IF l_Declaration_Xml_Dto.Land_Plots IS NOT NULL THEN
      --Парсинг земельних ділянок
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Land_Plots', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Land_Plots
        USING l_Declaration_Xml_Dto.Land_Plots;
    END IF;

    IF l_Declaration_Xml_Dto.Living_Qurters IS NOT NULL THEN
      --Парсинг житлових приміщень
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Living_Quarters', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Living_Qurters
        USING l_Declaration_Xml_Dto.Living_Qurters;
    END IF;

    IF l_Declaration_Xml_Dto.Other_Incomes IS NOT NULL THEN
      --Парсинг додаткових джерел існування
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Other_Incomes', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Other_Incomes
        USING l_Declaration_Xml_Dto.Other_Incomes;
    END IF;

    IF l_Declaration_Xml_Dto.Spendings IS NOT NULL THEN
      --Парсинг відомостей про витрати
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Spendings', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Spendings
        USING l_Declaration_Xml_Dto.Spendings;
    END IF;

    IF l_Declaration_Xml_Dto.Vehicles IS NOT NULL THEN
      --Парсинг транспортних засобів
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Apr_Vehicles', TRUE, FALSE) BULK COLLECT
        INTO l_Declaration_Dto.Vehicles
        USING l_Declaration_Xml_Dto.Vehicles;
    END IF;

    RETURN l_Declaration_Dto;
  END;

  FUNCTION Error_Exists(p_Messages IN OUT NOCOPY Api$validation.t_Messages) RETURN BOOLEAN IS
    l_Result NUMBER;
  BEGIN
    SELECT Sign(COUNT(*))
      INTO l_Result
      FROM TABLE(p_Messages)
     WHERE Msg_Tp IN ('F', 'E');

    RETURN l_Result = 1;
  END;

  ---------------------------------------------------------------------
  --     ПЕРЕВІРКА НА ПОРУШЕННЯ ЦІЛІСНОСТІ ДАНИХ ЗАЯВИ
  --якщо було передано ІД сутності > 0, перевіряємо
  --щоб ця сутність належала саме до того звернення яке зберігається
  ---------------------------------------------------------------------
  PROCEDURE Check_Ap_Integrity(p_Ap_Id       IN NUMBER,
                               p_Table       IN VARCHAR2,
                               p_Id_Field    IN VARCHAR2,
                               p_Ap_Field    IN VARCHAR2,
                               p_Id_Val      NUMBER,
                               p_Entity_Name IN VARCHAR2) IS
    l_Ap_Id NUMBER;
  BEGIN
    IF Nvl(p_Id_Val, -1) < 0 THEN
      RETURN;
    END IF;

    EXECUTE IMMEDIATE 'SELECT MAX(' || p_Ap_Field || ') FROM ' || p_Table || ' WHERE ' || p_Id_Field || '= :p_id'
      INTO l_Ap_Id
      USING p_Id_Val;

    IF l_Ap_Id IS NULL THEN
      Raise_Application_Error(-20000, p_Entity_Name || '(ІД=' || p_Id_Val || ') не знайдено');
    END IF;

    IF l_Ap_Id <> p_Ap_Id THEN
      Raise_Application_Error(-20000,
                              p_Entity_Name || '(ІД=' || p_Id_Val || ') знайдено в іншому звернені');
    END IF;
  END;

  ---------------------------------------------------------------------
  --     ПЕРЕВІРКА НА ПОРУШЕННЯ ЦІЛІСНОСТІ ДАНИХ ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Check_Apr_Integrity(p_Apr_Id      IN NUMBER,
                                p_Table       IN VARCHAR2,
                                p_Id_Field    IN VARCHAR2,
                                p_Apr_Field   IN VARCHAR2,
                                p_Id_Val      NUMBER,
                                p_Entity_Name IN VARCHAR2) IS
    l_Apr_Id NUMBER;
  BEGIN
    IF Nvl(p_Id_Val, -1) < 0 THEN
      RETURN;
    END IF;

    EXECUTE IMMEDIATE 'SELECT MAX(' || p_Apr_Field || ') FROM ' || p_Table || ' WHERE ' || p_Id_Field || '= :p_id'
      INTO l_Apr_Id
      USING p_Id_Val;

    IF l_Apr_Id IS NULL THEN
      Raise_Application_Error(-20000, p_Entity_Name || '(ІД=' || p_Id_Val || ') не знайдено');
    END IF;

    IF l_Apr_Id <> p_Apr_Id THEN
      Raise_Application_Error(-20000,
                              p_Entity_Name || '(ІД=' || p_Id_Val || ') знайдено в іншій декларації');
    END IF;
  END;

  ---------------------------------------------------------------------
  --                    ЗБЕРЕЖЕННЯ ПОСЛУГ
  ---------------------------------------------------------------------
  PROCEDURE Save_Services(p_Ap_Id       IN NUMBER,
                          p_Ap_Services IN OUT NOCOPY t_Ap_Services) IS
  BEGIN
    FOR i IN 1 .. p_Ap_Services.Count
    LOOP
      Check_Ap_Integrity(p_Ap_Id       => p_Ap_Id,
                         p_Table       => 'Ap_Service',
                         p_Ap_Field    => 'Aps_Ap',
                         p_Id_Field    => 'Aps_Id',
                         p_Id_Val      => p_Ap_Services(i).Aps_Id,
                         p_Entity_Name => 'Послугу');

      IF p_Ap_Services(i).Deleted = 1
          AND p_Ap_Services(i).Aps_Id > 0 THEN
        --Видаляємо повязані с послугою способи виплат
        Api$appeal.Delete_Service_Payments(p_Aps_Id => p_Ap_Services(i).Aps_Id);
        --Видаляємо послугу
        Api$appeal.Delete_Service(p_Id => p_Ap_Services(i).Aps_Id);
      ELSE
        Api$appeal.Save_Service(p_Aps_Id  => p_Ap_Services(i).Aps_Id,
                                p_Aps_Nst => p_Ap_Services(i).Aps_Nst,
                                p_Aps_Ap  => p_Ap_Id,
                                p_Aps_St  => Nvl(p_Ap_Services(i).Aps_St, 'R'),
                                p_New_Id  => p_Ap_Services(i).New_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --                     ЗБЕРЕЖЕННЯ ОСІБ
  ---------------------------------------------------------------------
  PROCEDURE Save_Persons(p_Ap_Id      IN NUMBER,
                         p_Ap_Persons IN OUT NOCOPY t_Ap_Persons) IS
  BEGIN
    FOR i IN 1 .. p_Ap_Persons.Count
    LOOP
      Check_Ap_Integrity(p_Ap_Id       => p_Ap_Id,
                         p_Table       => 'Ap_Person',
                         p_Ap_Field    => 'App_Ap',
                         p_Id_Field    => 'App_Id',
                         p_Id_Val      => p_Ap_Persons(i).App_Id,
                         p_Entity_Name => 'Учасника');

      IF p_Ap_Persons(i).Deleted = 1
          AND p_Ap_Persons(i).App_Id > 0 THEN
        --Видаляємо повязані з особою способи виплат
        Api$appeal.Delete_Person_Payments(p_App_Id => p_Ap_Persons(i).App_Id);
        --Відвязуємо особу від документів
        Api$appeal.Detach_Person_Docs(p_App_Id => p_Ap_Persons(i).App_Id);
        --Видаляемо особу
        Api$appeal.Delete_Person(p_Id => p_Ap_Persons(i).App_Id);
      ELSE
        --Зберігаємо особу
        Api$appeal.Save_Person(p_App_Id      => p_Ap_Persons(i).App_Id,
                               p_App_Ap      => p_Ap_Id,
                               p_App_Tp      => p_Ap_Persons(i).App_Tp,
                               p_App_Inn     => p_Ap_Persons(i).App_Inn,
                               p_App_Ndt     => p_Ap_Persons(i).App_Ndt,
                               p_App_Doc_Num => Upper(p_Ap_Persons(i).App_Doc_Num),
                               p_App_Fn      => p_Ap_Persons(i).App_Fn,
                               p_App_Mn      => p_Ap_Persons(i).App_Mn,
                               p_App_Ln      => p_Ap_Persons(i).App_Ln,
                               p_App_Esr_Num => p_Ap_Persons(i).App_Esr_Num,
                               p_App_Gender  => p_Ap_Persons(i).App_Gender,
                               p_App_Vf      => NULL,
                               p_App_Sc      => p_Ap_Persons(i).App_Sc,
                               p_App_Num     => p_Ap_Persons(i).App_Num,
                               p_New_Id      => p_Ap_Persons(i).New_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --                 ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
  ---------------------------------------------------------------------
  PROCEDURE Save_Payments(p_Ap_Id       IN NUMBER,
                          p_Ap_Payments IN OUT NOCOPY t_Ap_Payments,
                          p_Ap_Services IN OUT NOCOPY t_Ap_Services,
                          p_Ap_Persons  IN OUT NOCOPY t_Ap_Persons) IS
    l_New_Id NUMBER;
  BEGIN
    FOR Rec IN (SELECT p.*, Greatest(s.Aps_Id, Nvl(s.New_Id, -1)) AS Aps_Id, Greatest(Pr.App_Id, Nvl(Pr.New_Id, -1)) AS App_Id
                  FROM TABLE(p_Ap_Payments) p
                  LEFT JOIN TABLE(p_Ap_Services) s
                    ON p.Apm_Aps = s.Aps_Id
                  LEFT JOIN TABLE(p_Ap_Persons) Pr
                    ON p.Apm_App = Pr.App_Id)
    LOOP
      Check_Ap_Integrity(p_Ap_Id       => p_Ap_Id,
                         p_Table       => 'Ap_Payment',
                         p_Ap_Field    => 'Apm_Ap',
                         p_Id_Field    => 'Apm_Id',
                         p_Id_Val      => Rec.Apm_Id,
                         p_Entity_Name => 'Спосіб виплати');

      IF Rec.Deleted = 1
         AND Rec.Apm_Id > 0 THEN
        --Видаляємо спосіб виплати
        Api$appeal.Delete_Payment(p_Id => Rec.Apm_Id);
      ELSE
        --#78157 20220622
        IF Rec.Apm_Nb IS NULL
           AND Rec.Apm_Account IS NOT NULL THEN
          SELECT MAX(b.Nb_Id)
            INTO Rec.Apm_Nb
            FROM Uss_Ndi.v_Ndi_Bank b
           WHERE b.Nb_Mfo = Regexp_Substr('UA' || Rec.Apm_Account, '[0-9]{6}', 5)
             AND b.History_Status = 'A';
        END IF;

        Api$appeal.Save_Payment(p_Apm_Id           => Rec.Apm_Id,
                                p_Apm_Ap           => p_Ap_Id,
                                p_Apm_Aps          => Rec.Aps_Id,
                                p_Apm_App          => Rec.App_Id,
                                p_Apm_Tp           => Rec.Apm_Tp,
                                p_Apm_Index        => Rec.Apm_Index,
                                p_Apm_Kaot         => Rec.Apm_Kaot,
                                p_Apm_Nb           => Rec.Apm_Nb,
                                p_Apm_Account      => CASE
                                                        WHEN Rec.Apm_Account IS NOT NULL THEN
                                                         'UA' || Rec.Apm_Account
                                                        ELSE
                                                         Rec.Apm_Account
                                                      END, -- #74462
                                p_Apm_Need_Account => Rec.Apm_Need_Account,
                                p_Apm_Street       => Rec.Apm_Street,
                                p_Apm_Ns           => Rec.Apm_Ns,
                                p_Apm_Building     => Rec.Apm_Building,
                                p_Apm_Block        => Rec.Apm_Block,
                                p_Apm_Apartment    => Rec.Apm_Apartment,
                                p_Apm_Dppa         => Rec.Apm_Dppa,
                                p_New_Id           => l_New_Id);
      END IF;
    END LOOP;
  END;

  FUNCTION Doc_Is_Read_Only(p_Apd_Vf IN NUMBER) RETURN VARCHAR2 IS
    l_Result VARCHAR2(10);
  BEGIN
    IF p_Apd_Vf IS NULL THEN
      RETURN 'F';
    END IF;

    SELECT Nvl(MAX(CASE
                      WHEN v.Vf_Tp = 'SHR' THEN
                       'T'
                    END),
                'F')
      INTO l_Result
      FROM Verification v
     WHERE v.Vf_Id = p_Apd_Vf;

    RETURN l_Result;
  END;

  ---------------------------------------------------------------------
  --             ЗБЕРЕЖЕННЯ АТРИБУТІВ ДОКУМЕНТА
  ---------------------------------------------------------------------
  PROCEDURE Save_Document_Attrs(p_Ap_Id     IN NUMBER,
                                p_Apd_Id    IN NUMBER,
                                p_Apd_Attrs IN OUT NOCOPY t_Ap_Document_Attrs) IS
    l_New_Id NUMBER;
  BEGIN
    FOR Rec IN (SELECT a.Deleted, Nvl(a.Apda_Id, Da.Apda_Id) AS Apda_Id, a.Apda_Nda, a.Apda_Val_Int AS Val_Int,
                       a.Apda_Val_Dt AS Val_Dt, a.Apda_Val_String AS Val_String, a.Apda_Val_Id AS Val_Id, a.Apda_Val_Sum AS Val_Sum
                  FROM TABLE(p_Apd_Attrs) a
                  LEFT JOIN Ap_Document_Attr Da
                    ON Da.Apda_Apd = p_Apd_Id
                   AND a.Apda_Nda = Da.Apda_Nda
                   AND Da.History_Status = 'A')
    LOOP
      IF Rec.Apda_Id > 0 THEN
        DECLARE
          l_Apda_Apd NUMBER;
        BEGIN
          SELECT MAX(a.Apda_Apd)
            INTO l_Apda_Apd
            FROM Ap_Document_Attr a
           WHERE a.Apda_Id = Rec.Apda_Id;

          IF l_Apda_Apd IS NULL THEN
            Raise_Application_Error(-20000, 'Не знайдено атрибут документа ІД=' || Rec.Apda_Id);
          END IF;

          IF l_Apda_Apd <> p_Apd_Id THEN
            Raise_Application_Error(-20000,
                                    'Атрибут документа з ІД=' || Rec.Apda_Id || ' знайдено в іншому документі');
          END IF;
        END;
      END IF;

      IF Rec.Deleted = 1
         AND Rec.Apda_Id > 0 THEN
        --Видаляємо атрибут
        Api$appeal.Delete_Document_Attr(p_Id => Rec.Apda_Id);
      ELSE
        Api$appeal.Save_Document_Attr(p_Apda_Id         => Rec.Apda_Id,
                                      p_Apda_Ap         => p_Ap_Id,
                                      p_Apda_Apd        => p_Apd_Id,
                                      p_Apda_Nda        => Rec.Apda_Nda,
                                      p_Apda_Val_Int    => Rec.Val_Int,
                                      p_Apda_Val_Dt     => Rec.Val_Dt,
                                      p_Apda_Val_String => Rec.Val_String,
                                      p_Apda_Val_Id     => Rec.Val_Id,
                                      p_Apda_Val_Sum    => Rec.Val_Sum,
                                      p_New_Id          => l_New_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --                   ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
  ---------------------------------------------------------------------
  PROCEDURE Save_Documents(p_Ap_Id        IN NUMBER,
                           p_Ap_Documents IN OUT NOCOPY t_Ap_Documents,
                           p_Ap_Persons   IN OUT NOCOPY t_Ap_Persons,
                           p_Ap_Services  IN OUT NOCOPY t_Ap_Services) IS
    l_Ap_Document_Attrs t_Ap_Document_Attrs;
  BEGIN
    Write_Audit('Save_Documents');
    FOR Rec IN (SELECT d.*, Greatest(p.App_Id, Nvl(p.New_Id, -1)) AS App_Id, Greatest(s.Aps_Id, Nvl(s.New_Id, -1)) AS Aps_Id,
                       CASE
                          WHEN Ad.Apd_Id IS NOT NULL
                               AND d.Apd_Ndt <> Ad.Apd_Ndt THEN
                           1
                          ELSE
                           0
                        END AS Ndt_Changed, p.App_Tp, Doc_Is_Read_Only(p_Apd_Vf => Ad.Apd_Vf) AS Is_Read_Only
                  FROM TABLE(p_Ap_Documents) d
                  LEFT JOIN TABLE(p_Ap_Persons) p
                    ON d.Apd_App = p.App_Id
                  LEFT JOIN TABLE(p_Ap_Services) s
                    ON d.Apd_Aps = s.Aps_Id
                  LEFT JOIN Ap_Document Ad
                    ON d.Apd_Id = Ad.Apd_Id
                 ORDER BY CASE
                          --Обрабатываем заяву в конце, т.к. атрибуты заявы сверяеются с атрибутами других документов
                            WHEN d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Zayv THEN
                             1
                            ELSE
                             0
                          END)
    LOOP
      Check_Ap_Integrity(p_Ap_Id       => p_Ap_Id,
                         p_Table       => 'Ap_Document',
                         p_Ap_Field    => 'Apd_Ap',
                         p_Id_Field    => 'Apd_Id',
                         p_Id_Val      => Rec.Apd_Id,
                         p_Entity_Name => 'Документ');

      IF Rec.Deleted = 1
         AND Rec.Apd_Id > 0 THEN
        --Видаляємо документ
        --raise_application_error(-20000, 'Apd_Id='|| Rec.Apd_Id || ';deleted='||Rec.Deleted);
        Api$appeal.Delete_Document(p_Id => Rec.Apd_Id);
      ELSIF Rec.Apd_Id > 0
            AND Rec.Is_Read_Only = 'T' THEN
        --У документах "тільки для читання" може бути змінено лише посилання на учасника
        UPDATE Ap_Document d
           SET d.Apd_Ap  = p_Ap_Id,
               d.Apd_App = Rec.App_Id
         WHERE d.Apd_Id = Rec.Apd_Id;
        UPDATE Ap_Document_Attr a
           SET a.Apda_Ap = p_Ap_Id
         WHERE a.Apda_Apd = Rec.Apd_Id;
      ELSE
        IF Rec.Attributes IS NOT NULL THEN
          --Парсимо атрибути
          l_Ap_Document_Attrs := Parse_Document_Attr(Rec.Attributes);
        END IF;

        --Зберігаємо документ
        Api$appeal.Save_Document(p_Apd_Id  => Rec.Apd_Id,
                                 p_Apd_Ap  => p_Ap_Id,
                                 p_Apd_Ndt => Rec.Apd_Ndt,
                                 p_Apd_Doc => Rec.Apd_Doc,
                                 p_Apd_Vf  => NULL,
                                 p_Apd_App => Rec.App_Id,
                                 p_New_Id  => Rec.Apd_Id,
                                 p_Com_Wu  => NULL,
                                 p_Apd_Dh  => Rec.Apd_Dh,
                                 p_Apd_Aps => Rec.Aps_Id);

        IF Rec.Ndt_Changed = 1 THEN
          --У разі зміни типу документа, видаляємо усі навявні атрибути
          Api$appeal.Clear_Document_Attrs(p_Apd_Id => Rec.Apd_Id);
        END IF;

        IF Rec.Attributes IS NOT NULL THEN
          --Зберігаємо атрибути документа
          Save_Document_Attrs(p_Ap_Id => p_Ap_Id, p_Apd_Id => Rec.Apd_Id, p_Apd_Attrs => l_Ap_Document_Attrs);
        END IF;

        /*IF Rec.Attachments IS NOT NULL THEN
          --Зберігаємо вкладення документа
          Uss_Doc.Api$documents.Save_Attach_List(p_Doc_Id => Rec.Apd_Doc, p_Dh_Id => NULL, p_Attachments => Rec.Attachments);
        END IF;*/
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --              ЗБЕРЕЖЕННЯ ШАПКИ ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Ap_Declaration(p_Ap_Id          IN Appeal.Ap_Id%TYPE,
                                p_Com_Org        IN NUMBER,
                                p_Ap_Persons     IN OUT NOCOPY t_Ap_Persons,
                                p_Ap_Declaration IN OUT NOCOPY r_Ap_Declaration) IS
  BEGIN
    IF p_Ap_Declaration.Apr_Id < 0 THEN
      SELECT Nvl(MAX(d.Apr_Id), p_Ap_Declaration.Apr_Id)
        INTO p_Ap_Declaration.Apr_Id
        FROM Ap_Declaration d
       WHERE d.Apr_Ap = p_Ap_Id;
    ELSE
      Check_Ap_Integrity(p_Ap_Id       => p_Ap_Id,
                         p_Table       => 'Ap_Declaration',
                         p_Ap_Field    => 'Apr_Ap',
                         p_Id_Field    => 'Apr_Id',
                         p_Id_Val      => p_Ap_Declaration.Apr_Id,
                         p_Entity_Name => 'Декларацію');
    END IF;

    --#70674
    SELECT MAX(App_Ln), MAX(App_Fn), MAX(App_Mn)
      INTO p_Ap_Declaration.Apr_Ln, p_Ap_Declaration.Apr_Fn, p_Ap_Declaration.Apr_Mn
      FROM (SELECT *
               FROM TABLE(p_Ap_Persons)
              WHERE App_Tp = 'Z'
                AND Nvl(Deleted, 0) = 0
              ORDER BY App_Id
              FETCH FIRST ROW ONLY);

    Api$appeal.Save_Declaration(p_Apr_Id        => p_Ap_Declaration.Apr_Id,
                                p_Apr_Ap        => p_Ap_Id,
                                p_Apr_Fn        => p_Ap_Declaration.Apr_Fn,
                                p_Apr_Mn        => p_Ap_Declaration.Apr_Mn,
                                p_Apr_Ln        => p_Ap_Declaration.Apr_Ln,
                                p_Apr_Residence => p_Ap_Declaration.Apr_Residence,
                                p_Com_Org       => p_Com_Org,
                                p_Apr_Vf        => p_Ap_Declaration.Apr_Vf,
                                p_Apr_Start_Dt  => To_Date(p_Ap_Declaration.Apr_Start_Dt, c_Xml_Dt_Fmt),
                                p_Apr_Stop_Dt   => To_Date(p_Ap_Declaration.Apr_Stop_Dt, c_Xml_Dt_Fmt),
                                p_New_Id        => p_Ap_Declaration.Apr_Id);
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ЧЛЕНІВ РОДИНИ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Persons(p_Apr_Id      IN Ap_Declaration.Apr_Id%TYPE,
                             p_Apr_Persons IN OUT NOCOPY t_Apr_Persons,
                             p_Ap_Persons  IN OUT NOCOPY t_Ap_Persons) IS
    l_Apr_App NUMBER;
  BEGIN
    FOR i IN 1 .. p_Apr_Persons.Count
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Person',
                          p_Apr_Field   => 'Aprp_Apr',
                          p_Id_Field    => 'Aprp_Id',
                          p_Id_Val      => p_Apr_Persons(i).Aprp_Id,
                          p_Entity_Name => 'Учасника');

      IF p_Apr_Persons(i).Deleted = 1
          AND p_Apr_Persons(i).Aprp_Id > 0 THEN
        --Видаляємо члена родини
        Api$appeal.Delete_Apr_Person(p_Aprp_Id => p_Apr_Persons(i).Aprp_Id);
      ELSE
        SELECT MAX(Greatest(p.App_Id, Nvl(p.New_Id, -1)))
          INTO l_Apr_App
          FROM TABLE(p_Ap_Persons) p
         WHERE App_Id = p_Apr_Persons(i).Aprp_App;

        --Зберігаємо члена родини
        Api$appeal.Save_Apr_Person(p_Aprp_Id    => p_Apr_Persons(i).Aprp_Id,
                                   p_Aprp_Apr   => p_Apr_Id,
                                   p_Aprp_Fn    => p_Apr_Persons(i).Aprp_Fn,
                                   p_Aprp_Mn    => p_Apr_Persons(i).Aprp_Mn,
                                   p_Aprp_Ln    => p_Apr_Persons(i).Aprp_Ln,
                                   p_Aprp_Tp    => p_Apr_Persons(i).Aprp_Tp,
                                   p_Aprp_Inn   => p_Apr_Persons(i).Aprp_Inn,
                                   p_Aprp_Notes => p_Apr_Persons(i).Aprp_Notes,
                                   p_Aprp_App   => l_Apr_App,
                                   p_New_Id     => p_Apr_Persons(i).New_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ДОХОДІВ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Incomes(p_Apr_Id      IN Ap_Declaration.Apr_Id%TYPE,
                             p_Apr_Persons IN OUT NOCOPY t_Apr_Persons,
                             p_Apr_Incomes IN OUT NOCOPY t_Apr_Incomes) IS
  BEGIN
    FOR Rec IN (SELECT i.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Incomes) i
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON i.Apri_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Income',
                          p_Apr_Field   => 'APRI_APR',
                          p_Id_Field    => 'APRI_ID',
                          p_Id_Val      => Rec.Apri_Id,
                          p_Entity_Name => 'Запис про доходи');

      IF Rec.Deleted = 1
         AND Rec.Apri_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Income(p_Apri_Id => Rec.Apri_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Income(p_Apri_Id          => Rec.Apri_Id,
                                   p_Apri_Apr         => p_Apr_Id,
                                   p_Apri_Ln_Initials => NULL,
                                   p_Apri_Tp          => Rec.Apri_Tp,
                                   p_Apri_Sum         => To_Money(Rec.Apri_Sum),
                                   p_Apri_Source      => Rec.Apri_Source,
                                   p_Apri_Aprp        => Rec.Aprp_Id,
                                   p_Apri_Start_Dt    => To_Date(Rec.Apri_Start_Dt, c_Xml_Dt_Fmt),
                                   p_Apri_Stop_Dt     => To_Date(Rec.Apri_Stop_Dt, c_Xml_Dt_Fmt),
                                   p_New_Id           => Rec.Apri_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ЗЕМЕЛЬНИХ ДІЛЯНОК З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Land_Plots(p_Apr_Id         IN Ap_Declaration.Apr_Id%TYPE,
                                p_Apr_Persons    IN OUT NOCOPY t_Apr_Persons,
                                p_Apr_Land_Plots IN OUT NOCOPY t_Apr_Land_Plots) IS
  BEGIN
    FOR Rec IN (SELECT l.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Land_Plots) l
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON l.Aprt_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Land_Plot',
                          p_Apr_Field   => 'APRT_APR',
                          p_Id_Field    => 'APRT_ID',
                          p_Id_Val      => Rec.Aprt_Id,
                          p_Entity_Name => 'Земельну ділянку');

      IF Rec.Deleted = 1
         AND Rec.Aprt_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Land_Plot(Aprt_Id => Rec.Aprt_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Land_Plot(p_Aprt_Id          => Rec.Aprt_Id,
                                      p_Aprt_Apr         => p_Apr_Id,
                                      p_Aprt_Ln_Initials => NULL,
                                      p_Aprt_Area        => Rec.Aprt_Area,
                                      p_Aprt_Ownership   => Rec.Aprt_Ownership,
                                      p_Aprt_Purpose     => Rec.Aprt_Purpose,
                                      p_Aprt_Aprp        => Rec.Aprp_Id,
                                      p_New_Id           => Rec.Aprt_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ЖИТЛОВИХ ПРИМІЩЕНЬ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Living_Quarters(p_Apr_Id              IN Ap_Declaration.Apr_Id%TYPE,
                                     p_Apr_Persons         IN OUT NOCOPY t_Apr_Persons,
                                     p_Apr_Living_Quarters IN OUT NOCOPY t_Apr_Living_Quarters) IS
  BEGIN
    FOR Rec IN (SELECT q.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Living_Quarters) q
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON q.Aprl_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Living_Quarters',
                          p_Apr_Field   => 'Aprl_Apr',
                          p_Id_Field    => 'Aprl_Id',
                          p_Id_Val      => Rec.Aprl_Id,
                          p_Entity_Name => 'Житлове приміщення');

      IF Rec.Deleted = 1
         AND Rec.Aprl_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Living_Quarters(p_Aprl_Id => Rec.Aprl_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Living_Quarters(p_Aprl_Id          => Rec.Aprl_Id,
                                            p_Aprl_Apr         => p_Apr_Id,
                                            p_Aprl_Ln_Initials => NULL,
                                            p_Aprl_Area        => Rec.Aprl_Area,
                                            p_Aprl_Qnt         => Rec.Aprl_Qnt,
                                            p_Aprl_Address     => Rec.Aprl_Address,
                                            p_Aprl_Aprp        => Rec.Aprp_Id,
                                            p_Aprl_Tp          => Rec.Aprl_Tp,
                                            p_Aprl_Ch          => Rec.Aprl_Ch,
                                            p_New_Id           => Rec.Aprl_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ДОДАТКОВИХ ДЖЕРЕЛ ІСНУВАННЯ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Other_Incomes(p_Apr_Id            IN Ap_Declaration.Apr_Id%TYPE,
                                   p_Apr_Persons       IN OUT NOCOPY t_Apr_Persons,
                                   p_Apr_Other_Incomes IN OUT NOCOPY t_Apr_Other_Incomes) IS
  BEGIN
    FOR Rec IN (SELECT o.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Other_Incomes) o
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON o.Apro_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Other_Income',
                          p_Apr_Field   => 'Apro_Apr',
                          p_Id_Field    => 'Apro_Id',
                          p_Id_Val      => Rec.Apro_Id,
                          p_Entity_Name => 'Додаткове джерело існування');

      IF Rec.Deleted = 1
         AND Rec.Apro_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Other_Income(p_Apro_Id => Rec.Apro_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Other_Income(p_Apro_Id           => Rec.Apro_Id,
                                         p_Apro_Apr          => p_Apr_Id,
                                         p_Apro_Tp           => Rec.Apro_Tp,
                                         p_Apro_Income_Info  => Rec.Apro_Income_Info,
                                         p_Apro_Income_Usage => Rec.Apro_Income_Usage,
                                         p_Apro_Aprp         => Rec.Aprp_Id,
                                         p_New_Id            => Rec.Apro_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ВІДОМОСТЕЙ ПРО ВИТРАТИ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Spendings(p_Apr_Id        IN Ap_Declaration.Apr_Id%TYPE,
                               p_Apr_Persons   IN OUT NOCOPY t_Apr_Persons,
                               p_Apr_Spendings IN OUT NOCOPY t_Apr_Spendings) IS
  BEGIN
    FOR Rec IN (SELECT s.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Spendings) s
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON s.Aprs_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Spending',
                          p_Apr_Field   => 'Aprs_Apr',
                          p_Id_Field    => 'Aprs_Id',
                          p_Id_Val      => Rec.Aprs_Id,
                          p_Entity_Name => 'Відомості про витрати');

      IF Rec.Deleted = 1
         AND Rec.Aprs_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Spending(p_Aprs_Id => Rec.Aprs_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Spending(p_Aprs_Id          => Rec.Aprs_Id,
                                     p_Aprs_Apr         => p_Apr_Id,
                                     p_Aprs_Ln_Initials => NULL,
                                     p_Aprs_Tp          => Rec.Aprs_Tp,
                                     p_Aprs_Cost_Type   => Rec.Aprs_Cost_Type,
                                     p_Aprs_Cost        => To_Money(Rec.Aprs_Cost),
                                     p_Aprs_Dt          => To_Date(Rec.Aprs_Dt, c_Xml_Dt_Fmt),
                                     p_Aprs_Aprp        => Rec.Aprp_Id,
                                     p_New_Id           => Rec.Aprs_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --         ЗБЕРЕЖЕННЯ ТРАНСПОРТНИХ ЗАСОБІВ З ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Apr_Vehicles(p_Apr_Id       IN Ap_Declaration.Apr_Id%TYPE,
                              p_Apr_Persons  IN OUT NOCOPY t_Apr_Persons,
                              p_Apr_Vehicles IN OUT NOCOPY t_Apr_Vehicles) IS
  BEGIN
    FOR Rec IN (SELECT v.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Vehicles) v
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON v.Aprv_Aprp = p.Aprp_Id)
    LOOP
      Check_Apr_Integrity(p_Apr_Id      => p_Apr_Id,
                          p_Table       => 'Apr_Vehicle',
                          p_Apr_Field   => 'Aprv_Apr',
                          p_Id_Field    => 'Aprv_Id',
                          p_Id_Val      => Rec.Aprv_Id,
                          p_Entity_Name => 'Транспортний засіб');

      IF Rec.Deleted = 1
         AND Rec.Aprv_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Vehicle(p_Aprv_Id => Rec.Aprv_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Vehicle(p_Aprv_Id              => Rec.Aprv_Id,
                                    p_Aprv_Apr             => p_Apr_Id,
                                    p_Aprv_Ln_Initials     => NULL,
                                    p_Aprv_Car_Brand       => Rec.Aprv_Car_Brand,
                                    p_Aprv_License_Plate   => Rec.Aprv_License_Plate,
                                    p_Aprv_Production_Year => Rec.Aprv_Production_Year,
                                    p_Aprv_Is_Social_Car   => Rec.Aprv_Is_Social_Car,
                                    p_Aprv_Aprp            => Rec.Aprp_Id,
                                    p_New_Id               => Rec.Aprv_Id);
      END IF;
    END LOOP;
  END;
  ---------------------------------------------------------------------
  --                    ЗБЕРЕЖЕННЯ СУМИ АЛІМЕНТІВ
  ---------------------------------------------------------------------

  PROCEDURE Save_Apr_Alimonies(p_Apr_Id        IN Ap_Declaration.Apr_Id%TYPE,
                               p_Apr_Persons   IN OUT NOCOPY t_Apr_Persons,
                               p_Apr_Alimonies IN OUT NOCOPY t_Apr_Alimonies) IS
  BEGIN
    FOR Rec IN (SELECT v.*, Greatest(p.Aprp_Id, Nvl(p.New_Id, -1)) AS Aprp_Id
                  FROM TABLE(p_Apr_Alimonies) v
                  LEFT JOIN TABLE(p_Apr_Persons) p
                    ON v.Apra_Aprp = p.Aprp_Id)
    LOOP
      IF Rec.Deleted = 1
         AND Rec.Apra_Id > 0 THEN
        --Видаляємо запис
        Api$appeal.Delete_Apr_Alimony(p_Apra_Id => Rec.Apra_Id);
      ELSE
        --Зберігаємо запис
        Api$appeal.Save_Apr_Alimony(p_Apra_Id              => Rec.Apra_Id,
                                    p_Apra_Apr             => p_Apr_Id,
                                    p_Apra_Payer           => Rec.Apra_Payer,
                                    p_Apra_Sum             => To_Money(Rec.Apra_Sum),
                                    p_Apra_Is_Have_Arrears => Rec.Apra_Is_Have_Arrears,
                                    p_Apra_Aprp            => Rec.Aprp_Id,
                                    p_New_Id               => Rec.Apra_Id);
      END IF;
    END LOOP;
  END;

  ---------------------------------------------------------------------
  --                    ЗБЕРЕЖЕННЯ ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Save_Declaration(p_Ap_Id           IN Appeal.Ap_Id%TYPE,
                             p_Com_Org         IN Appeal.Com_Org%TYPE,
                             p_Declaration_Dto IN OUT NOCOPY r_Declaration_Dto,
                             p_Ap_Persons      IN OUT NOCOPY t_Ap_Persons) IS
  BEGIN
    Write_Audit('Save_Declaration');
    Save_Ap_Declaration(p_Ap_Id, p_Com_Org, p_Ap_Persons, p_Declaration_Dto.Declaration);
    IF p_Declaration_Dto.Persons IS NOT NULL THEN
      --Зберігаємо учасників
      Save_Apr_Persons(p_Apr_Id      => p_Declaration_Dto.Declaration.Apr_Id,
                       p_Apr_Persons => p_Declaration_Dto.Persons,
                       p_Ap_Persons  => p_Ap_Persons);
    END IF;

    IF p_Declaration_Dto.Incomes IS NOT NULL THEN
      --Зберігаємо доходи
      Save_Apr_Incomes(p_Apr_Id      => p_Declaration_Dto.Declaration.Apr_Id,
                       p_Apr_Persons => p_Declaration_Dto.Persons,
                       p_Apr_Incomes => p_Declaration_Dto.Incomes);
    END IF;

    IF p_Declaration_Dto.Other_Incomes IS NOT NULL THEN
      --Зберігаємо додаткові джерела доходів
      Save_Apr_Other_Incomes(p_Apr_Id            => p_Declaration_Dto.Declaration.Apr_Id,
                             p_Apr_Persons       => p_Declaration_Dto.Persons,
                             p_Apr_Other_Incomes => p_Declaration_Dto.Other_Incomes);
    END IF;

    IF p_Declaration_Dto.Spendings IS NOT NULL THEN
      --Зберігаємо витрати
      Save_Apr_Spendings(p_Apr_Id        => p_Declaration_Dto.Declaration.Apr_Id,
                         p_Apr_Persons   => p_Declaration_Dto.Persons,
                         p_Apr_Spendings => p_Declaration_Dto.Spendings);
    END IF;

    IF p_Declaration_Dto.Land_Plots IS NOT NULL THEN
      --Зберігаємо земельні ділянки
      Save_Apr_Land_Plots(p_Apr_Id         => p_Declaration_Dto.Declaration.Apr_Id,
                          p_Apr_Persons    => p_Declaration_Dto.Persons,
                          p_Apr_Land_Plots => p_Declaration_Dto.Land_Plots);
    END IF;

    IF p_Declaration_Dto.Living_Qurters IS NOT NULL THEN
      --Зберігаємо житлові приміщення
      Save_Apr_Living_Quarters(p_Apr_Id              => p_Declaration_Dto.Declaration.Apr_Id,
                               p_Apr_Persons         => p_Declaration_Dto.Persons,
                               p_Apr_Living_Quarters => p_Declaration_Dto.Living_Qurters);
    END IF;

    IF p_Declaration_Dto.Vehicles IS NOT NULL THEN
      --Зберігаємо транспортні засоби
      Save_Apr_Vehicles(p_Apr_Id       => p_Declaration_Dto.Declaration.Apr_Id,
                        p_Apr_Persons  => p_Declaration_Dto.Persons,
                        p_Apr_Vehicles => p_Declaration_Dto.Vehicles);
    END IF;
  END;

  ---------------------------------------------------------------------
  --                  Визначення органу
  ---------------------------------------------------------------------
  FUNCTION Define_Com_Org(p_Ap_Id     IN NUMBER,
                          p_Ap_Tp     IN VARCHAR2 := null,
                          p_Ap_Sub_Tp IN VARCHAR2 := null) RETURN NUMBER IS
    l_Com_Org NUMBER;
    l_Com_Org_Name VARCHAR2(500);
    l_Org_St VARCHAR2(10);
    l_Kaot_Id VARCHAR2(50);
    l_Ap      APPEAL%ROWTYPE;
  BEGIN
    SELECT *
    INTO l_Ap
    FROM Appeal
    WHERE Ap_Id = p_Ap_Id;

    IF NVL(p_Ap_Tp,l_Ap.Ap_Tp) = 'G' THEN
      SELECT MAX(Coalesce(Api$appeal.Get_Attr_Val_Id(d.Apd_Id, 971), Api$appeal.Get_Attr_Val_Id(d.Apd_Id, 979)))
        INTO l_Kaot_Id
        FROM Ap_Document d
       WHERE Apd_Ap = p_Ap_Id
         AND Apd_Ndt = 700
         AND d.History_Status = 'A';
      --Отримання витягу з РНСП
    ELSIF NVL(p_Ap_Sub_Tp,l_Ap.Ap_Sub_Tp) = 'DE' THEN
      NULL;
      --Заява про надання соціальної послуги медіації +
      --Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО +
      --Звернення з кабінету ОСП


    ELSIF l_Ap.Ap_Src IN ('PORTAL','CMES','USS') THEN

       --#108756
       FOR vI IN (SELECT 1873 Nda_Id FROM DUAL
                  UNION ALL
                  SELECT 8251 FROM DUAL
                  UNION ALL
                  SELECT 1968  FROM DUAL
                  UNION ALL
                  SELECT 1952  FROM DUAL
                  UNION ALL
                  --SELECT 3262 FROM DUAL
                  SELECT 1618 FROM DUAL)
       LOOP
         IF l_Com_Org IS NULL THEN
           l_Kaot_Id := Tools.Try_Parse_Number(Api$appeal.Get_Ap_Attr_Val_Id(p_Ap_Id, vI.Nda_id));
           IF l_Kaot_Id IS NOT NULL THEN
            get_org_by_kaot(l_Kaot_Id, l_Com_Org, l_Com_Org_Name);
           END IF;
         END IF;
       END LOOP;
    ELSE
      SELECT
           --#108421
           NVL(
            MAX(Api$appeal.Get_Person_Attr_Val_Id(p.App_Id, 1968)),
            MAX(Api$appeal.Get_Person_Attr_Val_Id(p.App_Id, 1952)))
          --MAX(Api$appeal.Get_Person_Attr_Val_Id(p.App_Id, 1618))
        INTO l_Kaot_Id
        FROM Ap_Person p
       WHERE p.App_Ap = p_Ap_Id
         AND p.App_Tp = 'Z'
         AND p.History_Status = 'A';
    END IF;

    l_Kaot_Id := Tools.Try_Parse_Number(l_Kaot_Id);

    IF l_Com_Org IS NULL THEN
      IF l_Kaot_Id IS NOT NULL THEN
        IF NVL(p_Ap_Tp,l_Ap.Ap_Tp) IN ('SS') THEN
          BEGIN
            --#108658
            SELECT k.nok_org, org_st
              INTO l_Com_Org, l_Org_St
             FROM Uss_Ndi.v_ndi_org2Kaot k
             JOIN ikis_sys.v_opfu o
               ON k.nok_org = o.org_id
            WHERE k.nok_kaot = l_Kaot_Id
              AND k.history_status='A'
              AND ROWNUM=1;

            IF l_Org_St = 'H' THEN
              SELECT MAX(c.nddc_code_dest)
              INTO l_Com_Org
              FROM uss_ndi.v_ndi_decoding_config c
              WHERE nddc_tp ='ORG_MIGR'
               AND c.nddc_code_src = l_Com_Org;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN NULL;
          END;

        ELSE
         --#108658
         SELECT MAX(k.nok_org)
            INTO l_Com_Org
           FROM Uss_Ndi.v_ndi_org2Kaot k
          WHERE k.nok_kaot = l_Kaot_Id;
        END IF;
      END IF;
    END IF;

    --#115045
    IF l_Com_Org IS NULL AND
       API$VALIDATION.Get_Ap_Doc_Count(p_Ap_Id,802) > 0 AND
       l_Ap.Ap_Src IN ('CMES')  THEN
      Raise_application_Error(-20000,'Неможливо визначити ОСЗН для передачі на опрацювання. Необхідно ввести та зберегти: або назву ОСЗН, до якого потрібно відправити звернення на опрацювання, або адресу проживання отримувача, або адресу організації, яка направляє повідомлення про СЖО');
    END IF;

    RETURN Nvl(l_Com_Org, 50000);
  END;

  ---------------------------------------------------------------------
  --                    ЗБЕРЕЖЕННЯ ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Save_Appeal(p_Ap_Id          IN OUT Appeal.Ap_Id%TYPE,
                        p_Ap_Is_Second   IN Appeal.Ap_Is_Second%TYPE,
                        p_Ap_Tp          IN Appeal.Ap_Tp%TYPE,
                        p_Ap_Reg_Dt      IN Appeal.Ap_Reg_Dt%TYPE,
                        p_Com_Org        IN Appeal.Com_Org%TYPE,
                        p_Ap_Services    IN CLOB,
                        p_Ap_Persons     IN CLOB,
                        p_Ap_Payments    IN CLOB,
                        p_Ap_Documents   IN CLOB,
                        p_Ap_Declaration IN CLOB,
                        p_Messages       OUT SYS_REFCURSOR,
                        p_Ap_Src         IN VARCHAR2 DEFAULT Api$appeal.c_Src_Portal,
                        p_Ap_Sub_Tp      IN VARCHAR2 DEFAULT NULL,
                        p_Ap_Ap_Main     IN Appeal.Ap_Ap_Main%TYPE DEFAULT NULL) IS
    l_Ap_Cu               NUMBER;
    l_Ap_Services         t_Ap_Services;
    l_Ap_Persons          t_Ap_Persons;
    l_Ap_Payments         t_Ap_Payments;
    l_Ap_Documents        t_Ap_Documents;
    l_Ap_Declaration      r_Declaration_Dto;
    l_Ap_Src              Appeal.Ap_Src%TYPE;
    l_Ap_St_Old           Appeal.Ap_St%TYPE;
    l_Ap_St               Appeal.Ap_St%TYPE;
    l_Ap_Sub_Tp           Appeal.Ap_Sub_Tp%TYPE;
    l_Validation_Messages Api$validation.t_Messages;
    l_Com_Wu              Appeal.Com_Wu%TYPE;
    l_com_org             NUMBER;
    l_P_Ap_Id             NUMBER := p_Ap_Id;
    l_Nst420              NUMBER := 0;
    l_New_Id              NUMBER;
  BEGIN
    Write_Audit('Save_Appeal');

    IF Nvl(p_Ap_Id, -1) > 0  THEN
      SELECT a.Ap_Cu, a.Ap_St, a.Ap_Src
        INTO l_Ap_Cu, l_Ap_St_Old, l_Ap_Src
        FROM Appeal a
       WHERE a.Ap_Id = p_Ap_Id;
      IF l_Ap_Cu IS NULL
         OR l_Ap_Cu <> Nvl(Ikis_Rbm.Tools.Getcurrentcu, -1) THEN
        Raise_Application_Error(-20000, 'Редагування заборононено');
      END IF;

      --#89117
      IF /*l_Ap_Src = 'CMES'
                                                                                                               AND*/
       l_Ap_St_Old NOT IN ('J', 'VE') THEN
        Raise_Application_Error(-20000,
                                'Редагування звернення в поточному статусі заборононено');
      END IF;
    END IF;

    /*INSERT INTO tmp_lob
    (x_id, x_clob )
    VALUES
    (1234567890, p_Ap_Persons);
    */
    --ПАРСИНГ
    l_Ap_Services := Parse_Services(p_Ap_Services);
    l_Ap_Persons := Parse_Persons(p_Ap_Persons);
    l_Ap_Payments := Parse_Payments(p_Ap_Payments);
    l_Ap_Documents := Parse_Documents(p_Ap_Documents);
    l_Ap_Declaration := Parse_Declaration(p_Ap_Declaration);

    --#89117
    IF p_Ap_Tp = 'SS'
       AND p_Ap_Src = 'CMES' THEN
      --Якщо звернення подається з кабінету кейс менеджера, то воно зберігається в статусі "Реєстрація в роботі"
      --після чого КМ повинен перевести його в статус "Зареєстровано"
      --після проходження верифікації надавач повинен його затвердитти
      l_Ap_St := 'J';
      --    ELSIF p_Ap_Tp = 'SS'
      --       AND p_Ap_Src = 'PORTAL' THEN
      --      l_Ap_St := 'J';
      IF p_Ap_Sub_Tp = 'SZ' THEN
         l_Com_Wu := Uss_Visit_Context.Getcontext(Uss_Visit_Context.Guid);
      END IF;
    ELSIF p_Ap_Tp = 'REG' AND p_Ap_Src = 'PORTAL' AND l_Ap_Services IS NOT NULL THEN
      -- #115554
      BEGIN
        FOR i IN 1 .. l_Ap_Services.Count
        LOOP
          CONTINUE WHEN l_Ap_Services(i).Deleted = 1;
          IF l_Ap_Services(i).Aps_Nst = 1141
          THEN
            l_Ap_St := 'J';
            EXIT;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          l_Ap_St := 'F';
      END;
    ELSE
      l_Ap_St := 'F';
    END IF;

    --ЗБЕРЕЖЕННЯ ЗВЕРНЕННЯ
    Api$appeal.Save_Appeal(p_Ap_Id        => p_Ap_Id,
                           p_Ap_Num       => NULL,
                           p_Ap_Reg_Dt    => p_Ap_Reg_Dt,
                           p_Ap_Create_Dt => SYSDATE,
                           p_Ap_Src       => p_Ap_Src,
                           p_Ap_St        => l_Ap_St,
                           p_Com_Org      => p_Com_Org,
                           p_Ap_Is_Second => Nvl(p_Ap_Is_Second, 'F'),
                           p_Ap_Vf        => NULL,
                           p_Com_Wu       => l_Com_Wu,
                           p_Ap_Tp        => p_Ap_Tp,
                           p_Ap_Dest_Org  => p_Com_Org,
                           p_New_Id       => p_Ap_Id,
                           p_Ap_Cu        => Ikis_Rbm.Tools.Getcurrentcu,
                           p_Ap_Sub_Tp    => p_Ap_Sub_Tp,
                           p_Ap_Ap_Main   => p_Ap_Ap_Main);

    IKIS_SYS.Ikis_Procedure_Log.LOG(p_src => UPPER('USS_VISIT.DNET$APPEAL_PORTAL.Save_Appeal'),
                                    p_obj_tp => UPPER('Appeal'),
                                    p_obj_id => p_Ap_Id,
                                    p_regular_params => 'p_Ap_Id='||l_p_Ap_Id||' p_Ap_Is_Second='||p_Ap_Is_Second||' p_Ap_Tp='||p_Ap_Tp||' p_Ap_Sub_Tp='||p_Ap_Sub_Tp||' p_Ap_Src='||p_Ap_Src||' p_Com_Org='||p_Com_Org||' l_Com_Wu='||l_Com_Wu||' Ikis_Rbm.Tools.Getcurrentcu='||Ikis_Rbm.Tools.Getcurrentcu||' p_Ap_Ap_Main='||p_Ap_Ap_Main );

    --ЗБЕРЕЖЕННЯ ПОСЛУГ
    IF l_Ap_Services IS NOT NULL THEN
      Save_Services(p_Ap_Id, l_Ap_Services);
    END IF;

    --ЗБЕРЕЖЕННЯ УЧАСНИКІВ
    IF l_Ap_Persons IS NOT NULL THEN
      Save_Persons(p_Ap_Id, l_Ap_Persons);
    END IF;

    --ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
    IF l_Ap_Payments IS NOT NULL THEN
      Save_Payments(p_Ap_Id, l_Ap_Payments, l_Ap_Services, l_Ap_Persons);
    END IF;

    --ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
    IF l_Ap_Documents IS NOT NULL THEN
      Save_Documents(p_Ap_Id        => p_Ap_Id,
                     p_Ap_Documents => l_Ap_Documents,
                     p_Ap_Persons   => l_Ap_Persons,
                     p_Ap_Services  => l_Ap_Services);
    END IF;

    --ЗБЕРЕЖЕННЯ ДЕКЛАРАЦІЇ
    IF l_Ap_Declaration.Declaration.Apr_Id IS NOT NULL THEN
      Save_Declaration(p_Ap_Id, p_Com_Org, l_Ap_Declaration, l_Ap_Persons);
    END IF;

    IF p_Ap_Sub_Tp IS NULL THEN
      l_Ap_Sub_Tp := Api$appeal.Define_Ap_Sub_Tp(p_Ap_Id);
    ELSE
      l_Ap_Sub_Tp := p_Ap_Sub_Tp;
    END IF;

   --API$APPEAL.Save_Ap_Main(p_Ap_Id, p_Ap_Ap_Main);
   --#110280
   DNET$APPEAL.Create_App_By_Attr(p_Ap_Id =>p_Ap_Id);


   --#106619
   l_Nst420 := Api$verification_Cond.Ap_Aps_Amount(p_Ap_Id => p_Ap_Id,
                                                   p_Aps_Nst_List => '420');

   --#106619
   IF l_Nst420 > 0 THEN
     Api$appeal.Save_Exists_Doc_Attr(p_Apda_Ap => p_Ap_Id,
                                    p_Apda_Nda => 1870,
                                    p_Apda_Val_String => 'T',
                                    p_New_Id => l_New_Id);

     Api$appeal.Save_Exists_Doc_Attr(p_Apda_Ap => p_Ap_Id,
                                    p_Apda_Nda => 1947,
                                    p_Apda_Val_String => 'T',
                                    p_New_Id => l_New_Id);


     Api$appeal.Save_Exists_Doc_Attr(p_Apda_Ap => p_Ap_Id,
                                    p_Apda_Nda => 8263,
                                    p_Apda_Val_String => 'T',
                                    p_New_Id => l_New_Id);

   END IF;


   SELECT Com_Org
   INTO l_com_org
   FROM Appeal ap
   WHERE ap.ap_id = p_Ap_Id;

   IF l_com_org IS NULL THEN
     l_com_org := DNET$APPEAL_PORTAL.Define_Com_Org(p_Ap_Id);
   END IF;

   UPDATE Appeal ap
   SET com_org     =  l_com_org,
       ap_dest_org =  l_com_org,
       Ap_Sub_Tp   = l_Ap_Sub_Tp
   WHERE ap_id = p_Ap_Id;


    --ВАЛІДАЦІЯ ЗВЕРНЕННЯ
    l_Validation_Messages := Api$validation.Validate_Appeal(p_Ap_Id => p_Ap_Id,
                                                            p_Warnings => TRUE,
                                                            p_Raise_Fatal_Err => FALSE,
                                                            --#103476
                                                            p_Error_To_Warning => API$VERIFICATION_COND.Is_Apd_Ap_Tp_Exists(p_Ap_Id, '802','SS'));

    --UPD(29.11.2023 ): Зберігаємо заяву у будь-якому випадку(за постановкою О.Зиновець та Ж.Хоменко)
    --Якщо не пройшов хочаб один контроль - заява не зберігається
    /* IF Error_Exists(l_Validation_Messages)
      --(на порталі редагування звернень не передбачено)
       AND p_Ap_Src = 'PORTAL'
       AND l_Ap_St != 'J' THEN
      NULL;
      ROLLBACK;
      p_Ap_Id := -1;
    END IF;*/

    --#111840
   API$Visit_Action.Prepare_Ap_Copy_Visit2ESR(p_ap => p_Ap_Id);

    --Пишемо в журнал повідомлення про збереження заяви
    Api$appeal.Write_Log(p_Apl_Ap      => p_Ap_Id,
                         p_Apl_Hs      => Tools.Gethistsessioncmes(),
                         p_Apl_St      => l_Ap_St,
                         p_Apl_Message => CASE
                                            WHEN p_Ap_Id IS NULL THEN
                                             Chr(38) || '1'
                                            ELSE
                                             Chr(38) || '2'
                                          END);


    OPEN p_Messages FOR
      SELECT *
        FROM TABLE(l_Validation_Messages) t
       ORDER BY Decode(t.Msg_Tp, 'F', 1, 'E', 2, 3);

    COMMIT;
  END;

  PROCEDURE Save_Appeal_Light(p_Ap_Id             IN Appeal.Ap_Id%TYPE,
                              p_Ap_Tp             IN Appeal.Ap_Tp%TYPE,
                              p_Ap_St             IN Appeal.Ap_St%TYPE,
                              p_Obi_Ts            IN Appeal.Obi_Ts%TYPE,
                              p_Ap_Reg_Dt         IN Appeal.Ap_Reg_Dt%TYPE,
                              p_Ap_Dest_Org       IN Appeal.Ap_Dest_Org%TYPE,
                              p_Ap_Inn            IN VARCHAR2,
                              p_Ap_Inn_Refusal    IN VARCHAR2,
                              p_Ap_FIO            IN VARCHAR2,
                              p_Ap_Is_About_Other IN VARCHAR2,
                              p_Ap_City           IN VARCHAR2,
                              p_Ap_Street         IN VARCHAR2,
                              p_Ap_Building       IN VARCHAR2,
                              p_Ap_Block          IN VARCHAR2,
                              p_Ap_Flat           IN VARCHAR2,
                              p_Ap_Phone          IN VARCHAR2,
                              p_Ap_Email          IN VARCHAR2,
                              p_Ap_Situation      IN VARCHAR2,
                              p_Ap_Child_Treat    IN VARCHAR2,
                              p_New_Id            OUT Appeal.Ap_Id%TYPE,
                              p_Messages          OUT SYS_REFCURSOR,
                              p_Ap_Documents      IN CLOB DEFAULT NULL,
                              p_Ap_City_Name      IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --raise_application_error(-20000, 'p_Ap_Dest_Org='||p_Ap_Dest_Org);
    DNET$APPEAL.Save_Appeal_Light(p_Ap_Id,
                                  p_Ap_Tp,
                                  p_Ap_St,
                                  p_Obi_Ts,
                                  p_Ap_Reg_Dt,
                                  p_Ap_Dest_Org,
                                  p_Ap_Inn,
                                  p_Ap_Inn_Refusal,
                                  p_Ap_FIO,
                                  p_Ap_Is_About_Other,
                                  p_Ap_City,
                                  p_Ap_Street,
                                  p_Ap_Building,
                                  p_Ap_Block,
                                  p_Ap_Flat,
                                  p_Ap_Phone,
                                  p_Ap_Email,
                                  p_Ap_Situation,
                                  p_Ap_Child_Treat,
                                  p_New_Id,
                                  p_Messages,
                                  p_Ap_Documents,
                                  p_Ap_City_Name);
  END;

  PROCEDURE Save_Appeal_Rehab_Tool(p_Ap_Id              IN Appeal.Ap_Id%TYPE,
                                   p_Obi_Ts             IN Appeal.Obi_Ts%TYPE,
                                   p_Ap_Dest_Org        IN Appeal.Ap_Dest_Org%TYPE, -- ТВ ФСЗОІ куди подається заява (за місцем реєстрації особи)
                                   p_Ap_LName           IN VARCHAR2,  --Прізвище особи
                                   p_Ap_FName           IN VARCHAR2,  --Ім’я
                                   p_Ap_MName           IN VARCHAR2,  --По батькові
                                   p_Ap_Inn_Refusal     IN VARCHAR2,  --Ознака відмови від РНОКПП
                                   p_Ap_Inn             IN VARCHAR2,  --РНОКПП заявника
                                   p_Ap_Live_City            IN NUMBER,
                                   p_Ap_Live_Street          IN VARCHAR2,
                                   p_Ap_Live_Building        IN VARCHAR2,
                                   p_Ap_Live_Block           IN VARCHAR2,
                                   p_Ap_Live_Flat            IN VARCHAR2,
                                   p_Ap_Phone           IN VARCHAR2,
                                   p_Ap_Phone_Add       IN VARCHAR2,
                                   p_Ap_Tool_List       IN VARCHAR2,
                                   p_New_Id             OUT Appeal.Ap_Id%TYPE,
                                   p_Messages           OUT SYS_REFCURSOR,
                                   p_Gender             IN VARCHAR2 DEFAULT NULL,
                                   p_Birth_Dt           IN DATE DEFAULT NULL,
                                   p_Ap_Documents       IN CLOB DEFAULT NULL,
                                   p_is_Address_Live_eq_Reg IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Reg_City       IN NUMBER DEFAULT NULL,
                                   p_Ap_Reg_Index      IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Reg_Street     IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Reg_Building   IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Reg_Block      IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Reg_Flat       IN VARCHAR2 DEFAULT NULL,
                                   p_Is_Vpo_Exist       IN VARCHAR2 DEFAULT NULL,
                                   p_Is_Regf_Addr_Not_Eq_fact_Addr  IN VARCHAR2 DEFAULT NULL,
                                   p_Is_Vpo_Addr_Eq_Fact_Addr  IN VARCHAR2 DEFAULT NULL,
                                   p_Ap_Live_Index      IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    DNET$APPEAL.Save_Appeal_Rehab_Tool(p_Ap_Id,
                                       p_Obi_Ts,
                                       p_Ap_Dest_Org,
                                       p_Ap_LName,
                                       p_Ap_FName,
                                       p_Ap_MName,
                                       p_Ap_Inn_Refusal,
                                       p_Ap_Inn,
                                       p_Ap_Live_City,
                                       p_Ap_Live_Street,
                                       p_Ap_Live_Building,
                                       p_Ap_Live_Block,
                                       p_Ap_Live_Flat,
                                       p_Ap_Phone,
                                       p_Ap_Phone_Add,
                                       p_Ap_Tool_List,
                                       p_New_Id,
                                       p_Messages,
                                       p_Gender,
                                       p_Birth_Dt,
                                       p_Ap_Documents,
                                       p_is_Address_Live_eq_Reg,
                                       p_Ap_Reg_City,
                                       p_Ap_Reg_Index,
                                       p_Ap_Reg_Street,
                                       p_Ap_Reg_Building,
                                       p_Ap_Reg_Block,
                                       p_Ap_Reg_Flat,
                                       p_Is_Vpo_Exist,
                                       p_Is_Regf_Addr_Not_Eq_fact_Addr,
                                       p_Is_Vpo_Addr_Eq_Fact_Addr,
                                       p_Ap_Live_Index);
  END;

  FUNCTION Is_Role_Assigned(p_Cmes_Id       IN NUMBER,
                            p_Cmes_Owner_Id IN NUMBER,
                            p_Cr_Code       IN VARCHAR2) RETURN BOOLEAN IS
  l_tmp boolean;
  BEGIN
    l_tmp := Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned(p_Cmes_Id       => p_Cmes_Id,
                                                   p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                                                   p_Cr_Code       => p_Cr_Code);
    --raise_application_error(-20000, 'cu_id='||ikis_rbm.tools.GetCurrentCu||';p_Cmes_Id='||p_Cmes_Id||';p_Cmes_Owner_Id='||p_Cmes_Owner_Id||';l_tmp='||case when l_tmp then 1 else 0 end);
    return l_tmp;
  END;

  FUNCTION Is_Adm_Role_Assigned(p_Cmes_Id       IN NUMBER,
                                p_Cmes_Owner_Id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN Ikis_Rbm.Api$cmes_Auth.Is_Adm_Role_Assigned(p_Cmes_Id => p_Cmes_Id, p_Cmes_Owner_Id => p_Cmes_Owner_Id);
  END;

  ---------------------------------------------------------------------
  -- ПЕРЕВІРКА НАЯВНОСТІ У ПОТОЧНОГО КОРИСТУВАЧА НАДВАЧА
  -- ДОСТУПУ ДО ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Check_Ap_Access_By_Prov(p_Ap_Id         IN NUMBER,
                                    p_Cmes_Owner_Id IN NUMBER) IS
    l_Is_Allowed NUMBER;
  BEGIN
    --Перевіряємо наявність у поточного користувача ролі в кабінеті
    -- вказаного надавача
    IF NOT Is_Role_Assigned(c_Cabinet_Ss_Provider, p_Cmes_Owner_Id, 'NSP_SPEC') THEN
      Raise_Application_Error(-20000, 'Надавача вказано некоректно');
    END IF;

    --Перевіряємо, що звернення було створено одним
    --з користувачів кабінету вказаного надавача
    SELECT Sign(COUNT(*))
      INTO l_Is_Allowed
      FROM Appeal a
      JOIN Ikis_Rbm.v_Cu_Users2roles r
        ON a.Ap_Cu = r.Cu2r_Cu
       AND r.History_Status = 'A'
      JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
        ON r.Cu2r_Cr = Cr.Cr_Id
       AND Cr.Cr_Cmes = c_Cabinet_Ss_Provider
       AND Cr.Cr_Actual = 'A'
     WHERE a.Ap_Id = p_Ap_Id
       AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id;

    IF l_Is_Allowed <> 1 THEN
      Raise_Application_Error(-20000, 'Недостатньо прав для виконання операції');
    END IF;
  END;

  ---------------------------------------------------------------------
  --        ВІДПРАВКА ЗВЕРНЕННЯ НА ВЕРИФІКАЦІЮ
  ---------------------------------------------------------------------
  PROCEDURE Send_Ap_To_Vf(p_Ap_Id    IN NUMBER,
                          p_Messages OUT SYS_REFCURSOR) IS
    l_Ap_St               Appeal.Ap_St%TYPE;
    l_Ap_Cu               NUMBER;
    l_Validation_Messages Api$validation.t_Messages;
  BEGIN
    SELECT Ap_Cu, a.Ap_St
      INTO l_Ap_Cu, l_Ap_St
      FROM Appeal a
     WHERE a.Ap_Id = p_Ap_Id;

    IF l_Ap_Cu IS NULL
       OR l_Ap_Cu <> Nvl(Ikis_Rbm.Tools.Getcurrentcu, -1) THEN
      Raise_Application_Error(-20000, 'unauthorized');
    END IF;

    IF l_Ap_St <> 'J' THEN
      Raise_Application_Error(-20000,
                              'Відправка звернення на верифікацію можлива лише стані "Реєстрація в роботі"');
    END IF;

    --ВАЛІДАЦІЯ ЗВЕРНЕННЯ
    l_Validation_Messages := Api$validation.Validate_Appeal(p_Ap_Id => p_Ap_Id,
                                                            p_Warnings => TRUE,
                                                            p_Raise_Fatal_Err => FALSE,
                                                            --#103476
                                                            p_Error_To_Warning => API$VERIFICATION_COND.Is_Apd_Ap_Tp_Exists(p_Ap_Id, '802','SS'));
    IF NOT Error_Exists(l_Validation_Messages) THEN
      UPDATE Appeal a
         SET a.Ap_St = 'F'
       WHERE a.Ap_Id = p_Ap_Id
         AND a.Ap_St = 'J';

      IF SQL%ROWCOUNT > 0 THEN
        Api$appeal.Write_Log(p_Apl_Ap      => p_Ap_Id,
                             p_Apl_Hs      => Tools.Gethistsessioncmes(),
                             p_Apl_St      => 'F',
                             p_Apl_Message => Chr(38) || 242);
      END IF;
    END IF;

    OPEN p_Messages FOR
      SELECT *
        FROM TABLE(l_Validation_Messages) t
       ORDER BY Decode(t.Msg_Tp, 'F', 1, 'E', 1, 2);
  END;

  ---------------------------------------------------------------------
  --       ПОВЕРНЕННЯ ЗВЕРНЕННЯ ДО КМа
  ---------------------------------------------------------------------
  PROCEDURE Return_Ap_To_Cm(p_Ap_Id         IN NUMBER,
                            p_Return_Reason IN VARCHAR2,
                            p_Cmes_Owner_Id IN NUMBER) IS
  BEGIN
    Check_Ap_Access_By_Prov(p_Ap_Id, p_Cmes_Owner_Id);

    UPDATE Appeal a
       SET a.Ap_St = 'J'
     WHERE a.Ap_Id = p_Ap_Id
       AND a.Ap_St = 'WB';

    IF SQL%ROWCOUNT = 0 THEN
      Raise_Application_Error(-20000,
                              'Повернути звернення до кейс-менеджера можливо лише в стані "Очікує підтвердження керівника"');
    END IF;

    Api$appeal.Write_Log(p_Apl_Ap      => p_Ap_Id,
                         p_Apl_Hs      => Tools.Gethistsessioncmes(),
                         p_Apl_St      => 'J',
                         p_Apl_Message => Chr(38) || '243#' || p_Return_Reason,
                         p_Apl_Tp      => 'USR');
  END;

  --#112664
  PROCEDURE Return_Appeals(p_Ap_Id IN NUMBER) IS
  BEGIN
    Dnet$appeal.Return_Appeals(p_Ap_Id);
  END;

  ---------------------------------------------------------------------
  --       ПІДТВЕРДЖЕННЯ ЗВЕРНЕННЯ НАДАВАЧЕМ
  ---------------------------------------------------------------------
  PROCEDURE Approve_Ap(p_Ap_Id         IN NUMBER,
                       p_Cmes_Owner_Id IN NUMBER) IS
    l_Ap_Ap_Main Appeal.Ap_Ap_Main%TYPE;
  BEGIN
    --Check_Ap_Access_By_Prov(p_Ap_Id, p_Cmes_Owner_Id);

    UPDATE Appeal a
       SET a.Ap_St = 'BA'
     WHERE a.Ap_Id = p_Ap_Id
       AND a.Ap_St = 'WB'
     RETURNING Ap_Ap_Main INTO l_Ap_Ap_Main;

    IF SQL%ROWCOUNT = 0 THEN
      Raise_Application_Error(-20000,
                              'Підтвердження звернення можливо лише в стані "Очікує підтвердження керівника"');
    END IF;

    --3105819
    IF l_Ap_Ap_Main IS NOT NULL THEN
       UPDATE Appeal a
       SET a.Ap_St = 'V'
       WHERE a.Ap_Id = l_Ap_Ap_Main;

    END IF;

    Api$appeal.Write_Log(p_Apl_Ap      => p_Ap_Id,
                         p_Apl_Hs      => Tools.Gethistsessioncmes(),
                         p_Apl_St      => 'BA',
                         p_Apl_Message => Chr(38) || '244');

    Api$visit_Action.Preparecopy_Visit2esr(p_Ap => p_Ap_Id, p_St_Old => 'BA');
  END;

  ---------------------------------------------------------------------
  --       ОТРИМАННЯ ПІБ ЗАЯВНИКА
  ---------------------------------------------------------------------
  FUNCTION Get_App_Main_Pib(p_Ap_Id NUMBER) RETURN VARCHAR2 IS
    l_Pib VARCHAR2(2000);
  BEGIN
    SELECT MAX(p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn)
      INTO l_Pib
      FROM Uss_Visit.Ap_Person p
     WHERE p.App_Ap = p_Ap_Id
       AND p.App_Tp IN ('Z', 'O', /* всі можливі варіанти для SS */ 'Z', 'AG', 'OR', 'AF', 'AP')
       AND p.History_Status = 'A';

    RETURN l_Pib;
  END;

  ---------------------------------------------------------------------
  --                   ЗАГАЛЬНІ ФІЛЬТРИ
  ---------------------------------------------------------------------
  PROCEDURE Filter_Common(p_Ap_Reg_Start IN DATE DEFAULT NULL,
                          p_Ap_Reg_Stop  IN DATE DEFAULT NULL,
                          p_Ap_Num       IN VARCHAR2 DEFAULT NULL,
                          p_Ap_St        IN VARCHAR2 DEFAULT NULL,
                          p_Com_Org      IN NUMBER DEFAULT NULL,
                          p_App_Pib      IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --Номер звернення
    IF p_Ap_Num IS NOT NULL THEN
      DELETE FROM Tmp_Work_Ids t
       WHERE NOT EXISTS (SELECT 1
                FROM Appeal a
               WHERE a.Ap_Id = t.x_Id
                 AND a.Ap_Num LIKE p_Ap_Num || '%');
    END IF;

    --Дата реєстрації
    IF p_Ap_Reg_Start IS NOT NULL
       OR p_Ap_Reg_Stop IS NOT NULL THEN
      DELETE FROM Tmp_Work_Ids t
       WHERE NOT EXISTS (SELECT 1
                FROM Appeal a
               WHERE a.Ap_Id = t.x_Id
                 AND a.Ap_Reg_Dt BETWEEN Nvl(p_Ap_Reg_Start, a.Ap_Reg_Dt) AND Nvl(p_Ap_Reg_Stop, a.Ap_Reg_Dt));
    END IF;

    --Орган реєстрації
    IF p_Com_Org IS NOT NULL THEN
      DELETE FROM Tmp_Work_Ids t
       WHERE NOT EXISTS (SELECT 1
                FROM Appeal a
               WHERE a.Ap_Id = t.x_Id
                 AND a.Com_Org = p_Com_Org);
    END IF;

    --Статус звернення
    IF p_Ap_St IS NOT NULL THEN
      DELETE FROM Tmp_Work_Ids t
       WHERE NOT EXISTS (SELECT 1
                FROM Appeal a
               WHERE a.Ap_Id = t.x_Id
                 AND a.Ap_St = p_Ap_St);
    END IF;

    --ПІБ заявника
    IF p_App_Pib IS NOT NULL THEN
      DELETE FROM Tmp_Work_Ids t
       WHERE NOT EXISTS (SELECT 1
                FROM Ap_Person p
               WHERE p.App_Ap = t.x_Id
                 AND Upper(p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn) LIKE Upper(p_App_Pib) || '%'
                 AND p.App_Tp IN ('Z')
                 AND p.History_Status = 'A');
    END IF;
  END;

  ---------------------------------------------------------------------
  --       ФІЛЬТРАЦІЯ "МОЇХ ЗАЯВ" ДЛЯ ОТРИМУВАЧА СОЦПОСЛУГ
  ---------------------------------------------------------------------
  FUNCTION Filter_My_Appeals_Ss_Rec(p_Ipn          IN VARCHAR2, --ignore
                                    p_Ndt          IN VARCHAR2, --ignore
                                    p_Doc_Num      IN VARCHAR2, --ignore
                                    p_Ap_Reg_Start IN DATE DEFAULT NULL,
                                    p_Ap_Reg_Stop  IN DATE DEFAULT NULL,
                                    p_Ap_Num       IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_St        IN VARCHAR2 DEFAULT NULL,
                                    p_Com_Org      IN NUMBER DEFAULT NULL,
                                    p_App_Pib      IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_Subtype   IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_Id        IN NUMBER DEFAULT NULL,
                                    p_Ap_Type      IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
    l_Cnt   NUMBER;
    l_Cu_Id NUMBER;
    l_Cu_Sc NUMBER;
  BEGIN
    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
    l_Cu_Sc := Ikis_Rbm.Tools.Getcusc(l_Cu_Id);
    --l_Cu_Sc := 125102441;

    Tools.Log(p_Src            => 'USS_VISIT.Dnet$appeal_Portal.Filter_My_Appeals_Ss_Rec',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Cu_Id='||l_Cu_Id||' l_Cu_Sc='|| l_Cu_Sc||' p_Ipn='|| p_Ipn||' p_Ndt='|| p_Ndt||' p_Doc_Num='|| p_Doc_Num||' p_Ap_Subtype='||p_Ap_Subtype||' p_Ap_Type='|| p_Ap_Type);

    IF p_Ap_Subtype = c_Ap_Subtype_Prov_Extract
       OR p_Ap_Type = c_Ap_Type_Extract THEN
      INSERT INTO Tmp_Work_Ids
        (x_Id)
        SELECT DISTINCT a.Ap_Id
          FROM Appeal a
          JOIN Ap_Person p
            ON a.Ap_Id = p.App_Ap
           AND p.App_Tp = 'Z'
         WHERE
        --#93211 якщо заява по користувачу кабінета то беремо тільки ті що подавались з порталу(з кабінету ОСП)
         ((a.Ap_Cu = l_Cu_Id AND a.Ap_Src = 'PORTAL')
         --
         OR p.App_Sc = l_Cu_Sc)
         AND a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
         AND a.Ap_Tp IN ('D')
         AND a.Ap_St NOT IN ('N','J')
         AND (p_Ap_Subtype IS NULL OR p_Ap_Subtype = c_Ap_Subtype_Prov_Extract OR (p_Ap_Subtype IS NOT NULL AND a.ap_sub_tp = p_Ap_Subtype))
         --AND (p.App_Inn = p_Ipn OR (p.App_Ndt = p_Ndt AND p.App_Doc_Num = p_Doc_Num))
         AND p.History_Status = 'A';
    ELSE
      INSERT INTO Tmp_Work_Ids
        (x_Id)
        SELECT DISTINCT a.Ap_Id
          FROM Appeal a
          JOIN Ap_Person p
            ON a.Ap_Id = p.App_Ap
           AND (p.App_Tp IN ('Z', 'AG', 'OR', 'AF', 'AP')
                -- #109573
                or p.app_sc is not null and p.App_Tp IN ('Z', 'OS', 'OR', 'FM', 'AF'))
         WHERE 1=1
         --AND ap_id = 48972
        --#93211 якщо заява по користувачу кабінета то беремо тільки ті що подавались з порталу(з кабінету ОСП)
         AND ((a.Ap_Cu = l_Cu_Id AND a.Ap_Src = 'PORTAL') OR p.App_Sc = l_Cu_Sc)
         -- #109573/#109565
         and (a.ap_src != 'CMES' or a.ap_src = 'CMES' and a.ap_cu != l_Cu_Id)
         AND a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
         AND (a.Ap_Tp IN ('SS', 'R.OS', 'CH_SRKO', 'REG', 'DD') AND a.Ap_St NOT IN ('N')) --,'J' 02/02/2025 serhii: #115554

         --AND (p.App_Inn = p_Ipn OR (p.App_Ndt = p_Ndt AND p.App_Doc_Num = p_Doc_Num))
        --#108888
         AND (p_Ap_Subtype IS NULL OR (p_Ap_Subtype IS NOT NULL AND a.ap_sub_tp = p_Ap_Subtype))
         AND (p_Ap_Type IS NULL OR (p_Ap_Type IS NOT NULL AND a.Ap_Tp = p_Ap_Type))
         AND p.History_Status = 'A';
    END IF;
    --Загальні фільтри
    Filter_Common(p_Ap_Reg_Start => p_Ap_Reg_Start,
                  p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                  p_Ap_Num       => p_Ap_Num,
                  p_Ap_St        => p_Ap_St,
                  p_Com_Org      => p_Com_Org,
                  p_App_Pib      => p_App_Pib);

    SELECT COUNT(*)
      INTO l_Cnt
      FROM Tmp_Work_Ids;

    Tools.Log(p_Src            => 'USS_VISIT.Dnet$appeal_Portal.Filter_My_Appeals_Ss_Rec',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Cnt       = ' || l_Cnt);

    RETURN l_Cnt > 0;
  END;

  ---------------------------------------------------------------------
  --        ФІЛЬТРАЦІЯ "МОЇХ ЗАЯВ" ДЛЯ КЕЙС МЕНЕДЖЕРА
  ---------------------------------------------------------------------
  FUNCTION Filter_My_Appeals_Cm(p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                                p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                                p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                                p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                                p_Com_Org       IN NUMBER DEFAULT NULL,
                                p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                                p_Ap_Id         IN NUMBER DEFAULT NULL,
                                p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                                p_Ap_Type       IN VARCHAR2 DEFAULT NULL,
                                p_Ap_Subtype   IN VARCHAR2 DEFAULT NULL,
                                p_Ap_Ap_Main    IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_Cnt   NUMBER;
    l_Cu_Id NUMBER;
  BEGIN
    IF NOT Is_Role_Assigned(c_Cabinet_Ss_Provider, p_Cmes_Owner_Id, 'NSP_CM') THEN
      Raise_Application_Error(-20000, 'Надавача вказано некоректно');
    END IF;

    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Filter_My_Appeals_Cm',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Cu_Id='|| l_Cu_Id||' p_Cmes_Owner_Id='||p_Cmes_Owner_Id);
    INSERT INTO Tmp_Work_Ids
      (x_Id)
      SELECT a.Ap_Id
        FROM Appeal a
       WHERE a.Ap_Cu = l_Cu_Id
         AND a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
            --#93211 показуємо тільки заяви які подавались з кабінету КМа
         AND a.Ap_Src = 'CMES'
         AND (p_Ap_Type IS NULL OR (p_Ap_Type IS NOT NULL AND a.Ap_Tp = p_Ap_Type))
         AND (p_Ap_Subtype IS NULL OR (p_Ap_Subtype IS NOT NULL AND a.ap_sub_tp = p_Ap_Subtype))
         AND (p_Ap_Ap_Main IS NULL OR (p_Ap_Ap_Main IS NOT NULL AND a.Ap_Ap_Main = p_Ap_Ap_Main));

    --Загальні фільтри
    Filter_Common(p_Ap_Reg_Start => p_Ap_Reg_Start,
                  p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                  p_Ap_Num       => p_Ap_Num,
                  p_Ap_St        => p_Ap_St,
                  p_Com_Org      => p_Com_Org,
                  p_App_Pib      => p_App_Pib);

    SELECT COUNT(*)
      INTO l_Cnt
      FROM Tmp_Work_Ids;

    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Filter_My_Appeals_Cm',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Cnt       = ' || l_Cnt);

    RETURN l_Cnt > 0;
  END;

  ---------------------------------------------------------------------
  --        Отримання ІД надавача СП зі звернення
  ---------------------------------------------------------------------
  FUNCTION Get_Ap_Rnspm(p_Ap_Id IN NUMBER) RETURN NUMBER IS
    l_Ap_Tp     VARCHAR2(10);
    l_Ap_Sub_Tp VARCHAR2(10);
    l_Ap_Rnspm  NUMBER;
    l_Ipn       VARCHAR2(4000);
    l_Edrpou    VARCHAR2(4000);
    l_Doc_Num   VARCHAR2(4000);
  BEGIN
    SELECT a.Ap_Tp, a.Ap_Sub_Tp
      INTO l_Ap_Tp, l_Ap_Sub_Tp
      FROM Appeal a
     WHERE a.Ap_Id = p_Ap_Id;

    --Звернення ОСП
    IF l_Ap_Tp = 'SS' THEN
      SELECT MAX(a.Apda_Val_Id)
        INTO l_Ap_Rnspm
        FROM Ap_Document_Attr a
        JOIN Uss_Ndi.v_Ndi_Document_Attr n
          ON a.Apda_Nda = n.Nda_Id
       WHERE a.Apda_Ap = p_Ap_Id
         AND a.History_Status = 'A'
         AND n.Nda_Class = 'NSP';
      --Звернення надавача щодо реєстру надавачів
    ELSIF l_Ap_Tp = 'G' THEN
      SELECT MAX(CASE
                    WHEN a.Apda_Nda = 955 THEN
                     a.Apda_Val_String
                  END),
             MAX(CASE
                    WHEN a.Apda_Nda = 961 THEN
                     a.Apda_Val_String
                  END),
             MAX(CASE
                    WHEN a.Apda_Nda = 962 THEN
                     a.Apda_Val_String
                  END)
        INTO l_Edrpou, l_Ipn, l_Doc_Num
        FROM Ap_Document_Attr a
       WHERE a.Apda_Ap = p_Ap_Id
         AND a.History_Status = 'A'
         AND a.Apda_Nda IN (955, 961, 962)
         AND a.Apda_Val_String IS NOT NULL;

      l_Ap_Rnspm := Uss_Rnsp.Api$find.Getrnspm(p_Edrpou => l_Edrpou, p_Ipn => l_Ipn, p_Doc_Num => l_Doc_Num);

      --Звернення надавача на формування витягу з реєстру надавачів
    ELSIF l_Ap_Sub_Tp = c_Ap_Subtype_Prov_Extract THEN
      SELECT a.Apda_Val_String
        INTO l_Edrpou
        FROM Ap_Document_Attr a
       WHERE a.Apda_Ap = p_Ap_Id
         AND a.History_Status = 'A'
         AND a.Apda_Nda = 1725
         AND a.Apda_Val_String IS NOT NULL;

      l_Ap_Rnspm := Uss_Rnsp.Api$find.Getrnspm(p_Edrpou => l_Edrpou, p_Ipn => l_Edrpou, p_Doc_Num => l_Edrpou);
    END IF;

    RETURN l_Ap_Rnspm;
  END;

  ---------------------------------------------------------------------
  --        ФІЛЬТРАЦІЯ "МОЇХ ЗАЯВ" ДЛЯ НАДАВАЧА СОЦПОСЛУГ
  ---------------------------------------------------------------------
  FUNCTION Filter_My_Appeals_Ss_Prov(p_Edrpou       IN VARCHAR2,
                                     p_Ipn          IN VARCHAR2,
                                     p_Doc_Num      IN VARCHAR2,
                                     p_Ap_Reg_Start IN DATE DEFAULT NULL,
                                     p_Ap_Reg_Stop  IN DATE DEFAULT NULL,
                                     p_Ap_Num       IN VARCHAR2 DEFAULT NULL,
                                     p_Ap_St        IN VARCHAR2 DEFAULT NULL,
                                     p_Com_Org      IN NUMBER DEFAULT NULL,
                                     p_App_Pib      IN VARCHAR2 DEFAULT NULL,
                                     p_Ap_Subtype   IN VARCHAR2 DEFAULT NULL,
                                     p_Ap_Id        IN NUMBER DEFAULT NULL,
                                     p_Ap_Type      IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
    l_Cnt      NUMBER;
    l_Rnspm_Id NUMBER;
  BEGIN
    Tools.Log(p_Src            => 'USS_VISIT.Dnet$appeal_Portal.Filter_My_Appeals_Ss_Prov',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'p_Edrpou='||p_Edrpou||' p_Ipn='|| p_Ipn||' p_Doc_Num='|| p_Doc_Num||' p_Ap_Subtype='||p_Ap_Subtype||' p_Ap_Type='|| p_Ap_Type);


    IF Coalesce(p_Ipn, p_Doc_Num, p_Edrpou) IS NULL THEN
      RETURN FALSE;
    END IF;

    --Отримуємо ІД надавача
    l_Rnspm_Id := Uss_Rnsp.Api$find.Getrnspm(p_Edrpou => p_Edrpou, p_Ipn => p_Ipn, p_Doc_Num => p_Doc_Num);

    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Filter_My_Appeals_Ss_Prov',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Rnspm_Id       = ' || l_Rnspm_Id);

    --IF NOT Is_Role_Assigned(p_Cmes_Id => c_Cabinet_Ss_Provider, p_Cmes_Owner_Id => l_Rnspm_Id, p_Cr_Code => 'NSP_SPEC') THEN
    --  Raise_Application_Error(-20000, 'Надавача вказано некоректно');
    --END IF;

    --Звернення надавача щодо реєстру надавачів
    IF p_Ap_Subtype IS NULL
       OR p_Ap_Subtype IN (c_Ap_Subtype_Prov_Reg, c_Ap_Subtype_Prov_Edit, c_Ap_Subtype_Prov_Exclude) THEN
      INSERT INTO Tmp_Work_Ids
        (x_Id)
        SELECT DISTINCT a.Ap_Id
          FROM Appeal a
          JOIN Ap_Document_Attr t
            ON a.Ap_Id = t.Apda_Ap
         WHERE a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
           AND a.Ap_Tp = 'G'
           AND t.Apda_Nda IN (961, 962, 955)
           AND t.Apda_Val_String = CASE
                 WHEN t.Apda_Nda = 961 THEN
                  p_Ipn
                 WHEN t.Apda_Nda = 962 THEN
                  p_Doc_Num
                 WHEN t.Apda_Nda = 955 THEN
                  p_Edrpou
               END --Coalesce(p_Ipn, p_Doc_Num, p_Edrpou)
           AND t.History_Status = 'A'
           AND a.Ap_St NOT IN ('N', 'J')
           AND a.Ap_Sub_Tp = Nvl(p_Ap_Subtype, a.Ap_Sub_Tp)
           AND (p_Ap_Type IS NULL OR (p_Ap_Type IS NOT NULL AND a.Ap_Tp = p_Ap_Type));

      IF SQL%ROWCOUNT > 0
         AND p_Ap_Id IS NOT NULL THEN
        RETURN TRUE;
      END IF;
    END IF;

    --Звернення надавача на формування витягу з реєстру надавачів
    IF p_Ap_Subtype IS NULL
       OR p_Ap_Subtype IN (c_Ap_Subtype_Prov_Extract)
       OR p_Ap_Type = c_Ap_Type_Extract THEN
      INSERT INTO Tmp_Work_Ids
        (x_Id)
        SELECT DISTINCT a.Ap_Id
          FROM Appeal a
          JOIN Ap_Document_Attr t
            ON a.Ap_Id = t.Apda_Ap
         WHERE a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
           AND a.Ap_Sub_Tp = Nvl(p_Ap_Subtype, a.Ap_Sub_Tp)
           AND (p_Ap_Type IS NULL OR (p_Ap_Type IS NOT NULL AND a.Ap_Tp = p_Ap_Type))
           AND a.Ap_Tp = 'D'
           AND t.Apda_Nda = 1725
           AND t.Apda_Val_String IN (p_Ipn, p_Doc_Num, p_Edrpou)
           AND t.History_Status = 'A';

      IF SQL%ROWCOUNT > 0
         AND p_Ap_Id IS NOT NULL THEN
        RETURN TRUE;
      END IF;
    END IF;


    --#108888 Інші типи звернень
    IF     p_Ap_Subtype IS NOT NULL
       AND p_Ap_Subtype NOT IN (c_Ap_Subtype_Prov_Reg, c_Ap_Subtype_Prov_Edit, c_Ap_Subtype_Prov_Exclude, c_Ap_Subtype_Prov_Extract) THEN
    INSERT INTO Tmp_Work_Ids
      (x_Id)
      SELECT a.Ap_Id
        FROM Appeal a
       WHERE a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
         AND EXISTS(SELECT 1
                    FROM Ap_Document_Attr a
                    JOIN Ap_Document d
                      ON a.Apda_Apd = d.Apd_Id
                     AND d.History_Status = 'A'
                    JOIN Uss_Ndi.v_Ndi_Document_Attr n
                      ON a.Apda_Nda = n.Nda_Id
                     AND n.Nda_Class = 'NSP'
                   WHERE a.Apda_Ap = a.ap_id
                     AND a.History_Status = 'A'
                     and a.Apda_Val_Id = l_Rnspm_Id)
         AND (p_Ap_Type IS NULL OR (p_Ap_Type IS NOT NULL AND a.Ap_Tp = p_Ap_Type))
         AND (p_Ap_Subtype IS NULL OR (p_Ap_Subtype IS NOT NULL AND a.ap_sub_tp = p_Ap_Subtype));
    END IF;


    --Загальні фільтри
    Filter_Common(p_Ap_Reg_Start => p_Ap_Reg_Start,
                  p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                  p_Ap_Num       => p_Ap_Num,
                  p_Ap_St        => p_Ap_St,
                  p_Com_Org      => p_Com_Org,
                  p_App_Pib      => p_App_Pib);

    SELECT COUNT(*)
      INTO l_Cnt
      FROM Tmp_Work_Ids;

    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Filter_My_Appeals_Ss_Prov',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'l_Cnt       = ' || l_Cnt);

    RETURN l_Cnt > 0;
  END;

  ---------------------------------------------------------------------
  --             ФІЛЬТРАЦІЯ "МОЇХ ЗАЯВ"
  ---------------------------------------------------------------------
  FUNCTION Filter_My_Appeals(p_Cabinet       IN NUMBER,
                             p_Edrpou        IN VARCHAR2 DEFAULT NULL,
                             p_Rnokpp        IN VARCHAR2 DEFAULT NULL,
                             p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                             p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                             p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                             p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                             p_Com_Org       IN NUMBER DEFAULT NULL,
                             p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                             p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                             p_Ap_Id         IN NUMBER DEFAULT NULL,
                             p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                             p_Ap_Type       IN VARCHAR2 DEFAULT NULL,
                             p_Ap_Ap_Main    IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_Doc_Num VARCHAR2(10);
    l_Ipn     VARCHAR2(12);
    l_Ndt     NUMBER;
    l_Edrpou  VARCHAR2(12);
  BEGIN
    DELETE FROM Tmp_Work_Ids;

    l_Edrpou := p_Edrpou;

    IF Regexp_Like(p_Rnokpp, '^[0-9]{10}$') THEN
      l_Ipn := p_Rnokpp;
    ELSIF Regexp_Like(p_Rnokpp, '^[А-ЯҐІЇЄ]{2}[0-9]{6}$') THEN
      l_Doc_Num := p_Rnokpp;
      l_Ndt := 6;
    ELSIF Regexp_Like(p_Rnokpp, '^[0-9]{9}$') THEN
      l_Doc_Num := p_Rnokpp;
      l_Ndt := 7;
    END IF;

    IF p_Cabinet = c_Cabinet_Ss_Provider THEN
      --TODO: придумати кращій критерій для визначання того, що запит надходить саме від КМа
      IF p_Edrpou IS NULL
         AND p_Rnokpp IS NULL
         AND p_Cmes_Owner_Id IS NOT NULL THEN
        --Звернення кейс-менеджера
        RETURN Filter_My_Appeals_Cm(p_Ap_Reg_Start  => p_Ap_Reg_Start,
                                    p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                                    p_Ap_Num        => p_Ap_Num,
                                    p_Ap_St         => p_Ap_St,
                                    p_Com_Org       => p_Com_Org,
                                    p_App_Pib       => p_App_Pib,
                                    p_Ap_Id         => p_Ap_Id,
                                    p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                                    p_Ap_Type       => p_Ap_Type,
                                    p_Ap_Ap_Main    => p_Ap_Ap_Main);
      ELSE
        --Звернення надавача соцпослуг
        RETURN Filter_My_Appeals_Ss_Prov(p_Edrpou       => l_Edrpou,
                                         p_Ipn          => l_Ipn,
                                         p_Doc_Num      => l_Doc_Num,
                                         p_Ap_Reg_Start => p_Ap_Reg_Start,
                                         p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                                         p_Ap_Num       => p_Ap_Num,
                                         p_Ap_St        => p_Ap_St,
                                         p_Com_Org      => p_Com_Org,
                                         p_App_Pib      => p_App_Pib,
                                         p_Ap_Subtype   => p_Ap_Subtype,
                                         p_Ap_Type      => p_Ap_Type,
                                         p_Ap_Id        => p_Ap_Id);
      END IF;
    ELSIF p_Cabinet = c_Cabinet_Ss_Recipient THEN
      --Звернення отримувача соцпослуг
      RETURN Filter_My_Appeals_Ss_Rec(p_Ipn          => l_Ipn,
                                      p_Ndt          => l_Ndt,
                                      p_Doc_Num      => l_Doc_Num,
                                      p_Ap_Reg_Start => p_Ap_Reg_Start,
                                      p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                                      p_Ap_Num       => p_Ap_Num,
                                      p_Ap_St        => p_Ap_St,
                                      p_Com_Org      => p_Com_Org,
                                      p_App_Pib      => p_App_Pib,
                                      p_Ap_Subtype   => p_Ap_Subtype,
                                      p_Ap_Type      => p_Ap_Type,
                                      p_Ap_Id        => p_Ap_Id);
    END IF;

    RETURN FALSE;
  END;

  PROCEDURE Filter_My_Appeals(p_Cabinet       IN NUMBER,
                              p_Edrpou        IN VARCHAR2,
                              p_Rnokpp        IN VARCHAR2,
                              p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                              p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                              p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                              p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                              p_Com_Org       IN NUMBER DEFAULT NULL,
                              p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                              p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                              p_Ap_Id         IN NUMBER DEFAULT NULL,
                              p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                              p_Ap_Ap_Main    IN NUMBER DEFAULT NULL,
                              p_Ap_Type       IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF Filter_My_Appeals(p_Ap_Id         => p_Ap_Id,
                         p_Cabinet       => p_Cabinet,
                         p_Edrpou        => p_Edrpou,
                         p_Rnokpp        => p_Rnokpp,
                         p_Ap_Reg_Start  => p_Ap_Reg_Start,
                         p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                         p_Ap_Num        => p_Ap_Num,
                         p_Ap_St         => p_Ap_St,
                         p_Com_Org       => p_Com_Org,
                         p_App_Pib       => p_App_Pib,
                         p_Ap_Subtype    => p_Ap_Subtype,
                         p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                         p_Ap_Ap_Main    => p_Ap_Ap_Main,
                         p_Ap_Type       => p_Ap_Type) THEN
      NULL;
    END IF;
  END;

  PROCEDURE Filter_My_Extract(p_Cabinet      IN NUMBER,
                              p_Edrpou       IN VARCHAR2,
                              p_Rnokpp       IN VARCHAR2,
                              p_Ap_Reg_Start IN DATE DEFAULT NULL,
                              p_Ap_Reg_Stop  IN DATE DEFAULT NULL,
                              p_Ap_Num       IN VARCHAR2 DEFAULT NULL,
                              --p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                              p_Com_Org       IN NUMBER DEFAULT NULL,
                              p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                              p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                              p_Ap_Id         IN NUMBER DEFAULT NULL,
                              p_Cmes_Owner_Id IN NUMBER DEFAULT NULL) IS
  BEGIN
    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Filter_My_Extract',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'p_Cabinet       = ' || p_Cabinet || Chr(13) || Chr(10) || 'p_Edrpou        = ' || p_Edrpou ||
                                  Chr(13) || Chr(10) || 'p_Rnokpp        = ' || p_Rnokpp || Chr(13) || Chr(10) ||
                                  'p_Ap_Reg_Start  = ' || p_Ap_Reg_Start || Chr(13) || Chr(10) || 'p_Ap_Reg_Stop   = ' ||
                                  p_Ap_Reg_Stop || Chr(13) || Chr(10) || 'p_Ap_Num        = ' || p_Ap_Num || Chr(13) || Chr(10) ||
                                  'p_Com_Org       = ' || p_Com_Org || Chr(13) || Chr(10) || 'p_App_Pib       = ' || p_App_Pib ||
                                  Chr(13) || Chr(10) || 'p_Ap_Subtype    = ' || p_Ap_Subtype || Chr(13) || Chr(10) ||
                                  'p_Ap_Id         = ' || p_Ap_Id || Chr(13) || Chr(10) || 'p_Cmes_Owner_Id = ' || p_Cmes_Owner_Id);
    IF Filter_My_Appeals(p_Ap_Id         => p_Ap_Id,
                         p_Cabinet       => p_Cabinet,
                         p_Edrpou        => p_Edrpou,
                         p_Rnokpp        => p_Rnokpp,
                         p_Ap_Reg_Start  => p_Ap_Reg_Start,
                         p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                         p_Ap_Num        => p_Ap_Num,
                         p_Ap_St         => '', --'V',
                         p_Com_Org       => p_Com_Org,
                         p_App_Pib       => p_App_Pib,
                         p_Ap_Subtype    => p_Ap_Subtype,
                         p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                         p_Ap_Type       => 'D') THEN
      NULL;
    END IF;
  END;

  ---------------------------------------------------------------------
  --       ОТРИМАННЯ ПІДТИПІВ ЗВЕРНЕНЬ НАДАВАЧА СОЦПОСЛУГ
  ---------------------------------------------------------------------
  PROCEDURE Get_Ss_Prov_Ap_Subtypes(p_Res OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT t.Dic_Value AS Ap_Subtype, t.Dic_Name AS Ap_Subtype_Name
        FROM Uss_Ndi.v_Ddn_Ap_Sub_Tp t
        JOIN Uss_Ndi.v_Ndi_Ap_Sub_Config c
          ON t.Dic_Value = c.Nasc_Ap_Sub_Tp
       WHERE c.Nasc_Ap_Tp = 'G'
          OR t.Dic_Value IN ('DE', 'SC');
  END;

  ---------------------------------------------------------------------
  --       ОТРИМАННЯ ПІДТИПІВ ЗВЕРНЕНЬ ОТРИМУВАЧА СОЦПОСЛУГ
  ---------------------------------------------------------------------
  PROCEDURE Get_Ss_Rec_Ap_Subtypes(p_Res OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT t.Dic_Value AS Ap_Subtype, t.Dic_Name AS Ap_Subtype_Name
        FROM Uss_Ndi.v_Ddn_Ap_Sub_Tp t
        JOIN Uss_Ndi.v_Ndi_Ap_Sub_Config c
          ON t.Dic_Value = c.Nasc_Ap_Sub_Tp
       WHERE c.Nasc_Ap_Tp IN ('SS', 'R.OS');
  END;

  PROCEDURE Get_Ap_List(p_Res OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT a.*, St.Dic_Sname AS Ap_St_Name, Tp.Dic_Sname AS Ap_Tp_Name, Src.Dic_Sname AS Ap_Src_Name,
             --o.Org_Code || ' ' || o.Org_Name AS Com_Org_Name,
             -- #97716 п.8
             (SELECT CASE WHEN MAX(za.apda_val_string) = 'G' THEN uss_rnsp.api$find.Get_Nsp_Name(MAX(za2.apda_val_id))
                          ELSE o.Org_Code || ' ' || o.Org_Name
                     END
                FROM ap_document zd
                JOIN ap_document_attr za ON (za.apda_apd = zd.apd_id)
                JOIN ap_document_attr za2 ON (za2.apda_apd = zd.apd_id)
               WHERE zd.apd_ap = a.ap_id
                 AND zd.apd_ndt = 802
                 AND za.apda_nda = 3687
                 AND za2.apda_nda = 3689
                 AND zd.history_status = 'A'
                 AND za.history_status = 'A'
                 AND za2.history_status = 'A'
             ) AS Com_Org_Name,
             Get_App_Main_Pib(a.Ap_Id) AS App_Pib, Sb.Dic_Name AS Ap_Sub_Tp_Name,
             Get_Ap_Modify_Dt(a.Ap_Id) AS Ap_Modify_Dt,
             CASE
                WHEN a.Com_Wu IS NOT NULL THEN
                 Get_Wu_Pib(a.Com_Wu)
                WHEN a.Ap_Cu IS NOT NULL THEN
                 Ikis_Rbm.Tools.Getcupib(a.Ap_Cu)
              END AS Ap_Modify_Wu,
             (SELECT listagg(distinct ndt_name,', ')
                FROM v_ap_document z
                JOIN uss_ndi.v_ndi_document_type zt ON (zt.ndt_id = z.apd_ndt)
               WHERE z.apd_ap = a.ap_id
                 AND z.history_status = 'A'
                 AND z.apd_ndt IN (801, 802, 835, 836, 1015, 10305, 10292, 10344)) AS apd_init_name
        FROM Appeal a
        JOIN Uss_Ndi.v_Ddn_Ap_St St
          ON a.Ap_St = St.Dic_Value
        JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp
          ON a.Ap_Tp = Tp.Dic_Value
        JOIN Uss_Ndi.v_Ddn_Ap_Src Src
          ON a.Ap_Src = Src.Dic_Value
        JOIN Opfu o
          ON a.Com_Org = o.Org_Id
        LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp Sb
          ON a.Ap_Sub_Tp = Sb.Dic_Value
        WHERE EXISTS(SELECT 1
                     FROM Tmp_Work_Ids i
                     WHERE i.x_Id = a.Ap_Id)  ;
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ПЕРЕЛІКУ "МОЇХ ЗАЯВ"
  ---------------------------------------------------------------------
  PROCEDURE Get_My_Appeals(p_Cabinet       IN NUMBER,
                           p_Edrpou        IN VARCHAR2,
                           p_Rnokpp        IN VARCHAR2,
                           p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                           p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                           p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                           p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                           p_Com_Org       IN NUMBER DEFAULT NULL,
                           p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Type       IN VARCHAR2 DEFAULT NULL,
                           p_Res           OUT SYS_REFCURSOR,
                           p_Res_Doc       OUT SYS_REFCURSOR,
                           p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                           p_Ap_Ap_Main    IN NUMBER DEFAULT NULL) IS
    l_Str VARCHAR2(4000);
  BEGIN
    Tools.LOG(p_src => 'USS_VISIT.DNET$APPEALGet_My_Appeals',
                                    p_obj_tp => 'IPN',
                                    p_obj_id => NULL,
                                    p_regular_params => 'p_Cabinet='||p_Cabinet||' p_Edrpou='||p_Edrpou||' p_Rnokpp='||p_Rnokpp||' p_Ap_Num='||p_Ap_Num );


    Filter_My_Appeals(p_Cabinet       => p_Cabinet,
                      p_Edrpou        => p_Edrpou,
                      p_Rnokpp        => p_Rnokpp,
                      p_Ap_Reg_Start  => p_Ap_Reg_Start,
                      p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                      p_Ap_Num        => p_Ap_Num,
                      p_Ap_St         => p_Ap_St,
                      p_Com_Org       => p_Com_Org,
                      p_App_Pib       => p_App_Pib,
                      p_Ap_Subtype    => p_Ap_Subtype,
                      p_Ap_Type       => p_Ap_Type,
                      p_Cmes_Owner_Id => p_Cmes_Owner_Id);

    Get_Ap_List(p_Res);

    SELECT Listagg(x_Id, ', ' ON Overflow Truncate '...') Within GROUP(ORDER BY x_Id)
      INTO l_Str
      FROM Tmp_Work_Ids;

    IF length(l_Str) > 3900 THEN
      l_Str := Substr(l_Str, 1, 3900)||' ...';
    END IF;



    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Get_My_Appeals',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'insert into Tmp_Work_Ids values (' || l_Str || ');');



    OPEN p_Res_Doc FOR
      SELECT d.Apd_Ap, d.Apd_Id, d.Apd_Doc AS Doc_Id, d.Apd_Dh AS Dh_Id, f.File_Code, f.File_Name, f.File_Mime_Type, f.File_Size,
             f.File_Hash, f.File_Create_Dt, f.File_Description, s.File_Code AS File_Sign_Code, s.File_Hash AS File_Sign_Hash,
             (SELECT Listagg(nvl(Fs.File_Code, ''), ',') Within GROUP(ORDER BY Ss.Dats_Id)
                 FROM Uss_Doc.v_Doc_Attach_Signs Ss
                 JOIN Uss_Doc.v_Files Fs
                   ON Ss.Dats_Sign_File = Fs.File_Id
                WHERE Ss.Dats_Dat = a.Dat_Id) AS File_Signs, a.Dat_Num
        FROM Tmp_Work_Ids i
        JOIN Ap_Document d
          ON d.Apd_Ap = i.x_Id
        JOIN Uss_Doc.v_Doc_Attachments a
          ON d.Apd_Dh = a.Dat_Dh
        JOIN Uss_Doc.v_Files f
          ON a.Dat_File = f.File_Id
        LEFT JOIN Uss_Doc.v_Files s
          ON a.Dat_Sign_File = s.File_Id
       WHERE d.History_Status = 'A';
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ПЕРЕЛІКУ "МОЇХ ЗАЯВ"
  ---------------------------------------------------------------------
  PROCEDURE Get_My_Appeals(p_Cabinet       IN NUMBER,
                           p_Edrpou        IN VARCHAR2,
                           p_Rnokpp        IN VARCHAR2,
                           p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                           p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                           p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                           p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                           p_Com_Org       IN NUMBER DEFAULT NULL,
                           p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Type       IN VARCHAR2 DEFAULT NULL,
                           p_Res           OUT SYS_REFCURSOR,
                           p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                           p_Ap_Ap_Main    IN NUMBER DEFAULT NULL) IS
  BEGIN
    Tools.LOG(p_src => 'USS_VISIT.DNET$APPEAL.Get_My_Appeals_with_res_docs',
                                    p_obj_tp => 'IPN',
                                    p_obj_id => NULL,
                                    p_regular_params => 'p_Cabinet='||p_Cabinet||' p_Edrpou='||p_Edrpou||' p_Rnokpp='||p_Rnokpp||' p_Ap_Num='||p_Ap_Num );
    Filter_My_Appeals(p_Cabinet       => p_Cabinet,
                      p_Edrpou        => p_Edrpou,
                      p_Rnokpp        => p_Rnokpp,
                      p_Ap_Reg_Start  => p_Ap_Reg_Start,
                      p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                      p_Ap_Num        => p_Ap_Num,
                      p_Ap_St         => p_Ap_St,
                      p_Com_Org       => p_Com_Org,
                      p_App_Pib       => p_App_Pib,
                      p_Ap_Subtype    => p_Ap_Subtype,
                      p_Ap_Type       => p_Ap_Type,
                      p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                      p_Ap_Ap_Main    => p_Ap_Ap_Main);

    Get_Ap_List(p_Res);
  END;

  PROCEDURE Get_My_Extract(p_Cabinet       IN NUMBER,
                           p_Edrpou        IN VARCHAR2,
                           p_Rnokpp        IN VARCHAR2,
                           p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                           p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                           p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                           p_Com_Org       IN NUMBER DEFAULT NULL,
                           p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                           p_Ap_Tp         IN VARCHAR2 DEFAULT NULL,
                           p_Res           OUT SYS_REFCURSOR,
                           p_Res_Doc       OUT SYS_REFCURSOR,
                           p_Cmes_Owner_Id IN NUMBER DEFAULT NULL) IS
    l_Str VARCHAR2(2000);
  BEGIN
    Filter_My_Extract(p_Cabinet       => p_Cabinet,
                      p_Edrpou        => p_Edrpou,
                      p_Rnokpp        => p_Rnokpp,
                      p_Ap_Reg_Start  => p_Ap_Reg_Start,
                      p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                      p_Ap_Num        => p_Ap_Num,
                      p_Com_Org       => p_Com_Org,
                      p_App_Pib       => p_App_Pib,
                      p_Ap_Subtype    => p_Ap_Subtype,
                      p_Cmes_Owner_Id => p_Cmes_Owner_Id);

    Get_Ap_List(p_Res);


    SELECT Listagg(x_Id, ', ' ON Overflow Truncate '...') Within GROUP(ORDER BY x_Id)
      INTO l_Str
      FROM Tmp_Work_Ids;

    Tools.Log(p_Src            => 'Dnet$appeal_Portal.Get_My_Extract',
              p_Obj_Tp         => '',
              p_Obj_Id         => '',
              p_Regular_Params => 'insert into Tmp_Work_Ids values (' || l_Str || ');');



    OPEN p_Res_Doc FOR
      SELECT d.Apd_Ap, d.Apd_Id, d.Apd_Doc AS Doc_Id, d.Apd_Dh AS Dh_Id, f.File_Code, f.File_Name, f.File_Mime_Type, f.File_Size,
             f.File_Hash, f.File_Create_Dt, f.File_Description, s.File_Code AS File_Sign_Code, s.File_Hash AS File_Sign_Hash,
             (SELECT Listagg(nvl(Fs.File_Code, ''), ',') Within GROUP(ORDER BY Ss.Dats_Id)
                 FROM Uss_Doc.v_Doc_Attach_Signs Ss
                 JOIN Uss_Doc.v_Files Fs
                   ON Ss.Dats_Sign_File = Fs.File_Id
                WHERE Ss.Dats_Dat = a.Dat_Id) AS File_Signs, a.Dat_Num
        FROM Tmp_Work_Ids i
        JOIN Ap_Document d
          ON d.Apd_Ap = i.x_Id
        JOIN Uss_Doc.v_Doc_Attachments a
          ON d.Apd_Dh = a.Dat_Dh
        JOIN Uss_Doc.v_Files f
          ON a.Dat_File = f.File_Id
        LEFT JOIN Uss_Doc.v_Files s
          ON a.Dat_Sign_File = s.File_Id
       WHERE d.History_Status = 'A';

  END;

  FUNCTION Filter_Appeals_For_Approve(p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                                      p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                                      p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                                      p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                                      p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                                      p_Com_Org       IN NUMBER DEFAULT NULL,
                                      p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                                      p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                                      p_Ap_Id         IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_Cnt NUMBER;
  BEGIN
    IF NOT Is_Role_Assigned(p_Cmes_Id => c_Cabinet_Ss_Provider, p_Cmes_Owner_Id => p_Cmes_Owner_Id, p_Cr_Code => 'NSP_SPEC') THEN
      --      Raise_Application_Error(-20000, 'Надавача вказано некоректно');
      Raise_Application_Error(-20000, 'Користувач не має відповідної ролі!');
    END IF;

    DELETE FROM Tmp_Work_Ids;

    INSERT INTO Tmp_Work_Ids
      (x_Id)
      SELECT DISTINCT a.Ap_Id
        FROM Appeal a
        JOIN Ikis_Rbm.v_Cu_Users2roles r
          ON a.Ap_Cu = r.Cu2r_Cu
         AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
         AND r.History_Status = 'A'
        JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
          ON r.Cu2r_Cr = Cr.Cr_Id
         AND Cr.Cr_Code IN ('NSP_SPEC', 'NSP_CM')
        JOIN Ap_Document_Attr t
          ON a.Ap_Id = t.Apda_Ap
        JOIN Uss_Ndi.v_Ndi_Document_Attr n
          ON t.Apda_Nda = n.Nda_Id
       WHERE a.Ap_Id = Nvl(p_Ap_Id, a.Ap_Id)
         AND a.Ap_Tp = 'SS'
         AND a.Ap_St = 'WB'
         AND a.Ap_Sub_Tp = Nvl(p_Ap_Subtype, a.Ap_Sub_Tp)
         AND n.Nda_Class = 'NSP'
         AND t.Apda_Val_Id = p_Cmes_Owner_Id
         AND t.History_Status = 'A';

    IF SQL%ROWCOUNT > 0
       AND p_Ap_Id IS NOT NULL THEN
      RETURN TRUE;
    END IF;

    --Загальні фільтри
    Filter_Common(p_Ap_Reg_Start => p_Ap_Reg_Start,
                  p_Ap_Reg_Stop  => p_Ap_Reg_Stop,
                  p_Ap_Num       => p_Ap_Num,
                  p_Ap_St        => p_Ap_St,
                  p_Com_Org      => p_Com_Org,
                  p_App_Pib      => p_App_Pib);

    SELECT COUNT(*)
      INTO l_Cnt
      FROM Tmp_Work_Ids;

    RETURN l_Cnt > 0;
  END;

  PROCEDURE Filter_Appeals_For_Approve(p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                                       p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                                       p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                                       p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                                       p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                                       p_Com_Org       IN NUMBER DEFAULT NULL,
                                       p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                                       p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                                       p_Ap_Id         IN NUMBER DEFAULT NULL) IS
  BEGIN
    IF Filter_Appeals_For_Approve(p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                                  p_Ap_Reg_Start  => p_Ap_Reg_Start,
                                  p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                                  p_Ap_Num        => p_Ap_Num,
                                  p_Ap_St         => p_Ap_St,
                                  p_Com_Org       => p_Com_Org,
                                  p_App_Pib       => p_App_Pib,
                                  p_Ap_Subtype    => p_Ap_Subtype,
                                  p_Ap_Id         => p_Ap_Id) THEN
      NULL;
    END IF;
  END;



  ---------------------------------------------------------------------
  --       ОТРИМАННЯ ПЕРЕЛІКУ ЗАЯВ НА ЗАТВЕРДЖЕННЯ ДЛЯ НАДАВАЧА
  ---------------------------------------------------------------------
  PROCEDURE Get_Appeals_For_Approve(p_Cmes_Owner_Id IN NUMBER DEFAULT NULL,
                                    p_Ap_Reg_Start  IN DATE DEFAULT NULL,
                                    p_Ap_Reg_Stop   IN DATE DEFAULT NULL,
                                    p_Ap_Num        IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_St         IN VARCHAR2 DEFAULT NULL,
                                    p_Com_Org       IN NUMBER DEFAULT NULL,
                                    p_App_Pib       IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_Subtype    IN VARCHAR2 DEFAULT NULL,
                                    p_Ap_Tp         IN VARCHAR2 DEFAULT NULL,
                                    p_Res           OUT SYS_REFCURSOR) IS
  BEGIN
    Filter_Appeals_For_Approve(p_Cmes_Owner_Id => p_Cmes_Owner_Id,
                               p_Ap_Reg_Start  => p_Ap_Reg_Start,
                               p_Ap_Reg_Stop   => p_Ap_Reg_Stop,
                               p_Ap_Num        => p_Ap_Num,
                               p_Ap_St         => p_Ap_St,
                               p_Com_Org       => p_Com_Org,
                               p_App_Pib       => p_App_Pib,
                               p_Ap_Subtype    => p_Ap_Subtype);

    Get_Ap_List(p_Res);
  END;

  FUNCTION Get_Ap_Modify_Dt(p_Ap_Id IN NUMBER) RETURN DATE IS
    l_Result DATE;
  BEGIN
    SELECT MAX(s.Hs_Dt)
      INTO l_Result
      FROM Ap_Log l
      JOIN Histsession s
        ON l.Apl_Hs = s.Hs_Id
     WHERE l.Apl_Ap = p_Ap_Id;

    RETURN l_Result;
  END;

  FUNCTION Get_Wu_Pib(p_Wu_Id IN NUMBER) RETURN VARCHAR2 IS
    l_Result VARCHAR(300);
  BEGIN
    IF p_Wu_Id IS NULL THEN
      RETURN NULL;
    END IF;

    SELECT Wu_Pib
      INTO l_Result
      FROM Ikis_Sysweb.V$all_Users
     WHERE Wu_Id = p_Wu_Id;

    RETURN l_Result;
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ РЕКВІЗИТІВ ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Get_Appeal(p_Ap_Id IN NUMBER,
                       p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT a.*, St.Dic_Sname AS Ap_St_Name, Tp.Dic_Sname AS Ap_Tp_Name, Src.Dic_Sname AS Ap_Src_Name,
             /*o.Org_Code || ' ' || o.Org_Name AS Com_Org_Name,*/ Get_App_Main_Pib(a.Ap_Id) AS App_Pib,
             -- #97716 п.8
             (SELECT CASE WHEN MAX(za.apda_val_string) = 'G' THEN uss_rnsp.api$find.Get_Nsp_Name(MAX(za2.apda_val_id))
                          ELSE o.Org_Code || ' ' || o.Org_Name
                     END
                FROM ap_document zd
                JOIN ap_document_attr za ON (za.apda_apd = zd.apd_id)
                JOIN ap_document_attr za2 ON (za2.apda_apd = zd.apd_id)
               WHERE zd.apd_ap = a.ap_id
                 AND zd.apd_ndt = 802
                 AND za.apda_nda = 3687
                 AND za2.apda_nda = 3689
                 AND zd.history_status = 'A'
                 AND za.history_status = 'A'
                 AND za2.history_status = 'A'
             ) AS Com_Org_Name,
             Get_Ap_Modify_Dt(a.Ap_Id) AS Ap_Modify_Dt,
             CASE
                WHEN a.Com_Wu IS NOT NULL THEN
                 Get_Wu_Pib(a.Com_Wu)
                WHEN a.Ap_Cu IS NOT NULL THEN
                 Ikis_Rbm.Tools.Getcupib(a.Ap_Cu)
              END AS Ap_Modify_Wu, Sb.Dic_Name AS Ap_Sub_Tp_Name
        FROM Appeal a
        JOIN Uss_Ndi.v_Ddn_Ap_St St
          ON a.Ap_St = St.Dic_Value
        JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp
          ON a.Ap_Tp = Tp.Dic_Value
        JOIN Uss_Ndi.v_Ddn_Ap_Src Src
          ON a.Ap_Src = Src.Dic_Value
        JOIN Opfu o
          ON a.Com_Org = o.Org_Id
        LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp Sb
          ON a.Ap_Sub_Tp = Sb.Dic_Value
       WHERE a.Ap_Id = p_Ap_Id;
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ПОСЛУГ
  ---------------------------------------------------------------------
  PROCEDURE Get_Services(p_Ap_Id IN NUMBER,
                         p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT s.Aps_Id, s.Aps_Nst, t.Nst_Name AS Aps_Nst_Name, t.Nst_Legal_Act, s.Aps_St, St.Dic_Sname AS Aps_St_Name
        FROM Ap_Service s
        JOIN Uss_Ndi.v_Ndi_Service_Type t
          ON s.Aps_Nst = t.Nst_Id
        JOIN Uss_Ndi.v_Ddn_Aps_St St
          ON s.Aps_St = St.Dic_Value
       WHERE s.Aps_Ap = p_Ap_Id
         AND s.History_Status = 'A';
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ УЧАСНИКІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Persons(p_Ap_Id IN NUMBER,
                        p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT p.App_Id, p.App_Tp, t.Dic_Name AS App_Tp_Name, p.App_Inn, p.App_Ndt, Dt.Ndt_Name AS App_Ndt_Name, p.App_Doc_Num,
             p.App_Fn, p.App_Mn, p.App_Ln, p.App_Esr_Num, p.App_Gender, g.Dic_Name AS App_Gender_Name, p.App_Sc, p.App_Num
        FROM Ap_Person p
        LEFT JOIN Uss_Ndi.v_Ddn_App_Tp t
          ON p.App_Tp = t.Dic_Value
        LEFT JOIN Uss_Ndi.v_Ndi_Document_Type Dt
          ON p.App_Ndt = Dt.Ndt_Id
        LEFT JOIN Uss_Ndi.v_Ddn_Gender g
          ON p.App_Gender = g.Dic_Value
       WHERE p.App_Ap = p_Ap_Id
         AND p.History_Status = 'A';
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ДОКУМЕНТІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Documents(p_Ap_Id IN NUMBER,
                          p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT d.Apd_Id, d.Apd_Ap, d.Apd_Ndt, t.Ndt_Name_Short AS Apd_Ndt_Name, d.Apd_App,
             --серія та номер документа
             Api$appeal.Get_Attr_Val_String(d.Apd_Id, 'DSN') AS Apd_Num, d.Apd_Doc, d.Apd_Dh, d.Apd_Aps AS Aps_Id, d.Apd_Aps
        FROM Ap_Document d
        JOIN Uss_Ndi.v_Ndi_Document_Type t
          ON d.Apd_Ndt = t.Ndt_Id
       WHERE d.Apd_Ap = p_Ap_Id
         AND d.History_Status = 'A';
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ АТРИБУТІВ ДОКУМЕНТІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Doc_Attributes(p_Ap_Id IN NUMBER,
                               p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT Ada.Apda_Id, Ada.Apda_Ap, Ada.Apda_Apd, Ada.Apda_Nda, Ada.Apda_Val_Int, Ada.Apda_Val_Dt, Ada.Apda_Val_String,
             Ada.Apda_Val_Id, Ada.Apda_Val_Sum, Nda.Nda_Id, Nda.Nda_Name, Nda.Nda_Is_Key, Nda.Nda_Ndt, Nda.Nda_Order, Nda.Nda_Pt,
             Nda.Nda_Is_Req, Nda.Nda_Def_Value, Nda.Nda_Can_Edit, Nda.Nda_Need_Show, Pt.Pt_Id, Pt.Pt_Code, Pt.Pt_Name, Pt.Pt_Ndc,
             Pt.Pt_Edit_Type, Pt.Pt_Data_Type
        FROM Ap_Document d
        JOIN Ap_Document_Attr Ada
          ON Ada.Apda_Apd = d.Apd_Id
         AND Ada.History_Status = 'A'
        JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
          ON Nda.Nda_Id = Ada.Apda_Nda
        JOIN Uss_Ndi.v_Ndi_Param_Type Pt
          ON Pt.Pt_Id = Nda.Nda_Pt
       WHERE d.Apd_Ap = p_Ap_Id
         AND d.History_Status = 'A'
       ORDER BY Nda.Nda_Order;
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ВКЛАДЕНЬ ДОКУМЕНТІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Doc_Files(p_Ap_Id IN NUMBER,
                          p_Res   OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_Res FOR
      SELECT Apd_Id, Doc_Id, Dh_Id, File_Code, File_Name, File_Mime_Type, File_Size,
             File_Hash, File_Create_Dt, File_Description, File_Sign_Code, File_Sign_Hash,
             (SELECT Listagg(nvl(Fs.File_Code, ''), ',') Within GROUP(ORDER BY Ss.Dats_Id)
                 FROM Uss_Doc.v_Doc_Attach_Signs Ss
                 JOIN Uss_Doc.v_Files Fs
                   ON Ss.Dats_Sign_File = Fs.File_Id
                WHERE Ss.Dats_Dat = Dat_Id) AS File_Signs, Dat_Num
      FROM(
        SELECT  d.Apd_Id, d.Apd_Doc AS Doc_Id, d.Apd_Dh AS Dh_Id, f.File_Code, f.File_Name, f.File_Mime_Type, f.File_Size,
             f.File_Hash, f.File_Create_Dt, f.File_Description, s.File_Code AS File_Sign_Code, s.File_Hash AS File_Sign_Hash,
             nvl(a.dat_num,-1) dat_num, --nvl(max(a.dat_num) over (partition by d.apd_id),-1) max_dat_num,
             dat_id
        FROM Ap_Document d
        JOIN Uss_Doc.v_Doc_Attachments a
          ON d.Apd_Dh = a.Dat_Dh
        JOIN Uss_Doc.v_Files f
          ON a.Dat_File = f.File_Id
        LEFT JOIN Uss_Doc.v_Files s
          ON a.Dat_Sign_File = s.File_Id
       WHERE d.Apd_Ap = p_Ap_Id
         AND d.History_Status = 'A'
         -- #109916
         and upper(f.file_mime_type) != upper('application/json')
         -- #113307
         and (d.apd_ndt in (851, 860, 862) and s.File_Code is not null or d.apd_ndt not in (851, 860, 862))
         )
      -- #109098 bogdan: не зовсім розумію для чого це було введено.
      -- я так розумію це було в коді коли накладається в осзн підпис з qr-кодом і виводився лише він без оригіналу
      --WHERE  dat_num = max_dat_num
      ;
  END;

  ---------------------------------------------------------------------
  --    ОТРИМАННЯ ЖУРНАЛУ ОБРОБКИ ТА ВЕРИФІКАЦІЇ ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Get_Log(p_Ap_Id IN NUMBER,
                    p_Res   OUT SYS_REFCURSOR) IS
    l_Ap_St Appeal.Ap_St%TYPE;
    l_Ap_Vf NUMBER;
  BEGIN
    SELECT Ap_St, Ap_Vf
      INTO l_Ap_St, l_Ap_Vf
      FROM Appeal
     WHERE Ap_Id = p_Ap_Id;

    OPEN p_Res FOR
      SELECT *
        FROM (SELECT s.Hs_Dt AS Log_Dt, Uss_Ndi.Rdm$msg_Template.Getmessagetext(l.Apl_Message) AS Log_Msg
                 FROM Ap_Log l
                 JOIN Histsession s
                   ON l.Apl_Hs = s.Hs_Id
                WHERE l.Apl_Ap = p_Ap_Id
                  AND l_Ap_St IN ('W', 'X', 'D', 'P')
                ORDER BY s.Hs_Dt DESC, l.Apl_Id DESC
                FETCH FIRST ROW ONLY)
      UNION ALL
      SELECT Vfl_Dt AS Log_Dt,
             CASE
                WHEN p.App_Id IS NOT NULL THEN
                 p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn || ': '
              END || Uss_Ndi.Rdm$msg_Template.Getmessagetext(l.Vfl_Message) AS Log_Msg
        FROM Vf_Log l
        JOIN Verification v
          ON l.Vfl_Vf = v.Vf_Id
        JOIN Verification Vv
          ON v.Vf_Vf_Main = Vv.Vf_Id
        LEFT JOIN Ap_Person p
          ON Vv.Vf_Obj_Tp = 'P'
         AND Vv.Vf_Obj_Id = p.App_Id
       WHERE l_Ap_St = 'VE'
         AND l.Vfl_Vf IN (SELECT t.Vf_Id
                            FROM Verification t
                           WHERE t.Vf_Nvt <> Api$verification.c_Nvt_Rzo_Search
                           START WITH t.Vf_Id = l_Ap_Vf
                          CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
         AND l.Vfl_Tp IN ('W', 'E')
       ORDER BY 1;
  END;

  ---------------------------------------------------------------------
  --    ОТРИМАННЯ ЖУРНАЛУ ОБРОБКИ ТА ВЕРИФІКАЦІЇ ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Get_Log_By_SC(p_Res   OUT SYS_REFCURSOR)
  IS
    l_Cu_Id NUMBER;
    l_Cu_Sc NUMBER;
  BEGIN
     l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
     l_Cu_Sc := Ikis_Rbm.Tools.Getcusc(l_Cu_Id);

    OPEN p_Res FOR
     SELECT s.Hs_Dt AS Log_Dt,
            Uss_Ndi.Rdm$msg_Template.Getmessagetext(l.Apl_Message) AS Log_Msg
       FROM Ap_Log l
       JOIN appeal p ON (p.ap_id = l.apl_ap)
       JOIN Histsession s
         ON l.Apl_Hs = s.Hs_Id
      WHERE p.ap_tp IN ('SS')
        AND EXISTS (SELECT * FROM ap_person z WHERE z.app_ap = p.ap_id AND z.history_status = 'A' AND z.app_sc = l_Cu_Sc)
        AND p.Ap_St IN ('W', 'X', 'D', 'P')
      ORDER BY s.Hs_Dt DESC, l.Apl_Id DESC
      FETCH FIRST ROW ONLY;
  END;

  FUNCTION Check_Ap_Access(p_Ap_Id         IN NUMBER,
                           p_Cabinet       IN NUMBER,
                           p_Edrpou        IN VARCHAR2 DEFAULT NULL,
                           p_Rnokpp        IN VARCHAR2 DEFAULT NULL,
                           p_Cmes_Owner_Id IN NUMBER DEFAULT NULL) RETURN BOOLEAN IS
    l_Ap_Tp VARCHAR2(10);
    l_Is_Cm BOOLEAN;
  BEGIN
    --Визначаємо тип звернення
    l_Ap_Tp := Api$appeal.Get_Ap_Tp(p_Ap_Id);
    --Визначаємо чи надійшов запит від КМа
    --todo: придумати кращій критерій для визначення
    l_Is_Cm := p_Cabinet = c_Cabinet_Ss_Provider AND p_Cmes_Owner_Id IS NOT NULL AND p_Edrpou IS NULL AND p_Rnokpp IS NULL;

    --Якщо надійшов запит на перегляд звернення ОСП з кабінету надавача
    IF p_Cabinet = c_Cabinet_Ss_Provider
       AND l_Ap_Tp = 'SS'
      --та якщо запит не від КМа
       AND NOT l_Is_Cm THEN
      --то перевіряюмо право на перегляд для розділу "Звернення на підтвердження"
      RETURN Filter_Appeals_For_Approve(p_Ap_Id => p_Ap_Id, p_Cmes_Owner_Id => Get_Ap_Rnspm(p_Ap_Id));
    ELSE
      --Інакше перевіряємо право на перегляд для розділу "Мої звернення"
      RETURN Filter_My_Appeals(p_Ap_Id         => p_Ap_Id,
                               p_Cabinet       => p_Cabinet,
                               p_Edrpou        => p_Edrpou,
                               p_Rnokpp        => p_Rnokpp,
                               p_Ap_Subtype    => CASE l_Ap_Tp
                                                    WHEN 'D' THEN
                                                     'DE'
                                                    ELSE
                                                     ''
                                                  END, --
                               p_Cmes_Owner_Id => p_Cmes_Owner_Id);
    END IF;

    RETURN FALSE;
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ КАРТКИ ЗВЕРНЕННЯ
  ---------------------------------------------------------------------
  PROCEDURE Get_Appeal_Card(p_Ap_Id          IN VARCHAR2,
                            p_Cabinet        IN NUMBER,
                            p_Edrpou         IN VARCHAR2,
                            p_Rnokpp         IN VARCHAR2,
                            p_Main_Cur       OUT SYS_REFCURSOR,
                            p_Ser_Cur        OUT SYS_REFCURSOR,
                            p_Pers_Cur       OUT SYS_REFCURSOR,
                            p_Docs_Cur       OUT SYS_REFCURSOR,
                            p_Docs_Attr_Cur  OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur OUT SYS_REFCURSOR,
                            p_Log_Cur        OUT SYS_REFCURSOR,
                            p_Cmes_Owner_Id  IN NUMBER DEFAULT NULL,
                            --Перевірка наявності доступу може бути
                            --попередньо виконана сервисом через ЄСР
                            p_Access_Checked IN VARCHAR2 DEFAULT NULL,
                            p_Pay_Cur        OUT SYS_REFCURSOR) IS
  BEGIN
    Write_Audit('Get_Appeal_Card');

    Ikis_Sys.Ikis_Procedure_Log.Log(p_Src            => UPPER('uss_visit.dnet$appeal_portal.Get_Appeal_Card'),
                                    p_Obj_Tp         => 'APPEAL',
                                    p_Obj_Id         => p_Ap_Id,
                                    p_Regular_Params => 'p_Ap_Id   =' || p_Ap_Id || Chr(13) || 'p_Cabinet =' || p_Cabinet ||
                                                        Chr(13) || 'p_Edrpou  =' || p_Edrpou || Chr(13) || 'p_Rnokpp  =' ||
                                                        p_Rnokpp || Chr(13) || 'p_Cmes_Owner_Id=' || p_Cmes_Owner_Id || Chr(13) ||
                                                        'p_Access_Checked=' || p_Access_Checked);


    --Перевірка прав доступу на вичітку даних звернення
    IF NOT Nvl(p_Access_Checked, 'F') = 'T'
       AND NOT Check_Ap_Access(p_Ap_Id         => p_Ap_Id,
                               p_Cabinet       => p_Cabinet,
                               p_Edrpou        => p_Edrpou,
                               p_Rnokpp        => p_Rnokpp,
                               p_Cmes_Owner_Id => p_Cmes_Owner_Id) THEN

      Ikis_Sys.Ikis_Procedure_Log.Log(p_Src            => UPPER('uss_visit.dnet$appeal_portal.Get_Appeal_Card'),
                                      p_Obj_Tp         => 'APPEAL',
                                      p_Obj_Id         => p_Ap_Id,
                                      p_Regular_Params => 'unauthorized');
      --Raise_Application_Error(-20000, 'unauthorized');
    END IF;

    Get_Appeal(p_Ap_Id => p_Ap_Id, p_Res => p_Main_Cur);
    Get_Services(p_Ap_Id => p_Ap_Id, p_Res => p_Ser_Cur);
    Get_Persons(p_Ap_Id => p_Ap_Id, p_Res => p_Pers_Cur);
    Get_Documents(p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Cur);
    Get_Doc_Attributes(p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Attr_Cur);
    Get_Doc_Files(p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Files_Cur);
    Get_Log(p_Ap_Id => p_Ap_Id, p_Res => p_Log_Cur);
    DNET$APPEAL.Get_Payments(p_Ap_Id => p_Ap_Id, p_Res => p_Pay_Cur);
  END;

  ---------------------------------------------------------------------
  --               ОТРИМАННЯ ДЕКЛАРАЦІЇ
  ---------------------------------------------------------------------
  PROCEDURE Get_Declaration(p_Ap_Id     IN NUMBER,
                            Decl_Cur    OUT SYS_REFCURSOR,
                            Person_Cur  OUT SYS_REFCURSOR,
                            Inc_Cur     OUT SYS_REFCURSOR,
                            Land_Cur    OUT SYS_REFCURSOR,
                            Living_Cur  OUT SYS_REFCURSOR,
                            Other_Cur   OUT SYS_REFCURSOR,
                            Spend_Cur   OUT SYS_REFCURSOR,
                            Vehicle_Cur OUT SYS_REFCURSOR,
                            Alimony_Cur OUT SYS_REFCURSOR) IS
    l_Id NUMBER;
  BEGIN
    Write_Audit('Get_Declaration');
    SELECT MAX(Apr_Id)
      INTO l_Id
      FROM Ap_Declaration t
     WHERE t.Apr_Ap = p_Ap_Id;

    OPEN Decl_Cur FOR
      SELECT *
        FROM Ap_Declaration t
       WHERE t.Apr_Ap = p_Ap_Id;

    OPEN Person_Cur FOR
      SELECT *
        FROM Apr_Person t
       WHERE t.Aprp_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Inc_Cur FOR
      SELECT *
        FROM Apr_Income t
       WHERE t.Apri_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Land_Cur FOR
      SELECT *
        FROM Apr_Land_Plot t
       WHERE t.Aprt_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Living_Cur FOR
      SELECT *
        FROM Apr_Living_Quarters t
       WHERE t.Aprl_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Other_Cur FOR
      SELECT *
        FROM Apr_Other_Income t
       WHERE t.Apro_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Spend_Cur FOR
      SELECT *
        FROM Apr_Spending t
       WHERE t.Aprs_Apr = l_Id
         AND t.History_Status = 'A';

    OPEN Vehicle_Cur FOR
      SELECT *
        FROM Apr_Vehicle t
       WHERE t.Aprv_Apr = l_Id
         AND t.History_Status = 'A';
    OPEN Alimony_Cur FOR
      SELECT *
        FROM Apr_Alimony t
       WHERE t.Apra_Apr = l_Id
         AND t.History_Status = 'A';
  END;

  ---------------------------------------------------------------------
  --                   ДОВІДНИК АТРИБУТІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Nda_List(p_Ndt_Id  NUMBER,
                         p_Nda_Cur OUT SYS_REFCURSOR) IS
  BEGIN
    Write_Audit('Get_Nda_List');

    OPEN p_Nda_Cur FOR
      SELECT Nda.Nda_Id, Nvl(Nda.Nda_Name, Pt.Pt_Name) AS Nda_Name, Nda.Nda_Is_Key, Nda.Nda_Ndt, Nda.Nda_Order, Nda.Nda_Pt,
             Nda.Nda_Is_Req, Nda.Nda_Def_Value, Nda.Nda_Can_Edit, Nda.Nda_Need_Show, Nda.Nda_Class, Pt.Pt_Id, Pt.Pt_Code,
             Pt.Pt_Name, Pt.Pt_Ndc, Pt.Pt_Edit_Type, Pt.Pt_Data_Type, Ndc.Ndc_Code, Nvl(Nda.Nda_Nng, -1) AS Nda_Nng,
             (SELECT MAX(z.Nnv_Condition)
                 FROM Uss_Ndi.v_Ndi_Nda_Validation z
                WHERE z.Nnv_Nda = Nda.Nda_Id
                  AND z.Nnv_Tp = 'MASK') AS Mask_Setup,
             (SELECT Coalesce(MAX(z.Nnv_Condition), 'F')
                 FROM Uss_Ndi.v_Ndi_Nda_Validation z
                WHERE z.Nnv_Nda = Nda.Nda_Id
                  AND z.Nnv_Tp = 'RESET') AS Can_Reset
        FROM Uss_Ndi.v_Ndi_Document_Attr Nda
        JOIN Uss_Ndi.v_Ndi_Param_Type Pt
          ON Pt.Pt_Id = Nda.Nda_Pt
        LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config Ndc
          ON Ndc.Ndc_Id = Pt.Pt_Ndc
       WHERE Nda_Ndt = p_Ndt_Id;
  END;

  ---------------------------------------------------------------------
  --                   ДОВІДНИК ГРУП АТРИБУТІВ
  ---------------------------------------------------------------------
  PROCEDURE Get_Nng_List(p_Nng_Cur OUT SYS_REFCURSOR) IS
  BEGIN
    Write_Audit('Get_Nng_List');

    OPEN p_Nng_Cur FOR
      SELECT -1 AS Nng_Id, 'Основні параметри' AS Nng_Name, 'T' AS Nng_Open_By_Def, 0 AS Nng_Order
        FROM Dual
      UNION ALL
      SELECT g.Nng_Id, g.Nng_Name, g.Nng_Open_By_Def, g.Nng_Order
        FROM Uss_Ndi.v_Ndi_Nda_Group g
       ORDER BY Nng_Order;
  END;

  ---------------------------------------------------------------------
  --                Перевірка доступу до файлу
  ---------------------------------------------------------------------
  FUNCTION Check_File_Access(p_File_Code IN VARCHAR2,
                             p_Cabinet   IN VARCHAR2,
                             p_Edrpou    IN VARCHAR2,
                             p_Rnokpp    IN VARCHAR2) RETURN VARCHAR2 IS
    l_bool boolean;
  BEGIN
    FOR Rec IN (SELECT d.Apd_Ap, Ap.Ap_Tp
                  FROM Uss_Doc.v_Files f
                  JOIN Uss_Doc.v_Doc_Attachments a
                    ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                  JOIN Ap_Document d
                    ON a.Dat_Dh = d.Apd_Dh
                   AND d.History_Status = 'A'
                  JOIN Appeal Ap
                    ON d.Apd_Ap = Ap.Ap_Id
                 WHERE f.File_Code = p_File_Code)
    LOOP
      begin
        l_bool := Check_Ap_Access(p_Ap_Id => Rec.Apd_Ap, p_Cabinet => p_Cabinet, p_Edrpou => p_Edrpou, p_Rnokpp => p_Rnokpp);
      exception when others then
        l_bool := false;
      end;

      IF l_bool THEN
        RETURN 'T';
      END IF;
    END LOOP;

    RETURN 'F';
  END;


  ---------------------------------------------------------------------
  --                Перевірка доступу до файлу
  -- (поки ця реалізація використовується лише для КМа )
  ---------------------------------------------------------------------
  FUNCTION Check_File_Access(p_File_Code IN VARCHAR2,
                             p_Cmes_Id   IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    FOR Rec IN (SELECT d.Apd_Ap
                  FROM Uss_Doc.v_Files f
                  JOIN Uss_Doc.v_Doc_Attachments a
                    ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                  JOIN Ap_Document d
                    ON a.Dat_Dh = d.Apd_Dh
                   AND d.History_Status = 'A'
                 WHERE f.File_Code = p_File_Code)
    LOOP
      DECLARE
        l_Cmes_Owner_Id NUMBER;
        l_cu_id number;
        l_cnt number;
      BEGIN
        IF p_Cmes_Id = c_Cabinet_Ss_Provider THEN
          l_Cmes_Owner_Id := Get_Ap_Rnspm(Rec.Apd_Ap);
          l_cu_id := ikis_rbm.tools.GetCurrentCu;

          -- #109529
          if (l_cu_id is not null) then
            SELECT count(*)
              into l_cnt
              FROM appeal t
             where t.ap_id = rec.apd_ap
               and t.ap_cu = l_cu_id;

            if (l_cnt > 0) then
              return 'T';
            end if;
          end if;

        END IF;

        IF Filter_My_Appeals(p_Ap_Id => Rec.Apd_Ap, p_Cabinet => p_Cmes_Id, p_Cmes_Owner_Id => l_Cmes_Owner_Id) THEN
          RETURN 'T';
        END IF;
      END;
    END LOOP;

    RETURN 'F';
  END;

  PROCEDURE Add_Attr(p_Attrs   IN OUT NOCOPY t_Ap_Document_Attrs,
                     p_Nda_Id  IN NUMBER,
                     p_Val_Str IN VARCHAR2 DEFAULT NULL,
                     p_Val_Dt  IN DATE DEFAULT NULL,
                     p_Val_Id  IN NUMBER DEFAULT NULL) IS
  BEGIN
    IF p_Attrs IS NULL THEN
      p_Attrs := t_Ap_Document_Attrs();
    END IF;

    IF p_Val_Str IS NULL
       AND p_Val_Dt IS NULL
       AND p_Val_Id IS NULL THEN
      RETURN;
    END IF;

    p_Attrs.Extend();
    p_Attrs(p_Attrs.Count).Apda_Nda := p_Nda_Id;
    p_Attrs(p_Attrs.Count).Apda_Val_Id := p_Val_Id;
    p_Attrs(p_Attrs.Count).Apda_Val_String := p_Val_Str;
    p_Attrs(p_Attrs.Count).Apda_Val_Dt := p_Val_Dt;
  END;

  FUNCTION Attrs2cur(p_Attrs IN OUT NOCOPY t_Ap_Document_Attrs) RETURN SYS_REFCURSOR IS
    l_Result SYS_REFCURSOR;
  BEGIN
    OPEN l_Result FOR
      SELECT Apda_Nda, Apda_Val_String, Apda_Val_Int, CAST(Apda_Val_Dt AS DATE) AS Apda_Val_Dt, Apda_Val_Id, Apda_Val_Sum
        FROM TABLE(p_Attrs);

    RETURN l_Result;
  END;

  FUNCTION Empty_Cursor RETURN SYS_REFCURSOR IS
    l_Res SYS_REFCURSOR;
  BEGIN
    OPEN l_Res FOR
      SELECT CAST(1 AS NUMBER) AS a
        FROM Dual
       WHERE 1 = 2;

    RETURN l_Res;
  END;

  ----------------------------------------------------------------------------
  -- Отримання даних для предзаповнення заяви про надання СП
  ----------------------------------------------------------------------------
  FUNCTION Get_Prefill_Sz(p_Ln        IN VARCHAR2,
                          p_Fn        IN VARCHAR2,
                          p_Mn        IN VARCHAR2,
                          p_Birth_Dt  IN DATE,
                          p_Phone     IN VARCHAR2,
                          p_Addr_Fact IN Uss_Person.v_Sc_Address%ROWTYPE,
                          p_Addr_Reg  IN Uss_Person.v_Sc_Address%ROWTYPE) RETURN t_Ap_Document_Attrs IS
    l_Attrs    t_Ap_Document_Attrs;
    l_Index_Id NUMBER;
  BEGIN
    Add_Attr(l_Attrs, 1896, p_Val_Str => p_Ln);
    Add_Attr(l_Attrs, 1897, p_Val_Str => p_Fn);
    Add_Attr(l_Attrs, 1898, p_Val_Str => p_Mn);
    Add_Attr(l_Attrs, 1899, p_Val_Dt => p_Birth_Dt);

    --Адреса реєстрації
    IF p_Addr_Reg.Sca_Kaot IS NOT NULL THEN
      --КАТОТТГ
      Add_Attr(l_Attrs,
               1885,
               p_Val_Id  => p_Addr_Reg.Sca_Kaot,
               p_Val_Str => Uss_Ndi.Api$dic_Common.Get_Katottg_Name(p_Addr_Reg.Sca_Kaot));
    END IF;
    --Область
    Add_Attr(l_Attrs, 1887, p_Val_Str => p_Addr_Reg.Sca_Region);
    --Район
    Add_Attr(l_Attrs, 1888, p_Val_Str => p_Addr_Reg.Sca_District);
    --Населений пункт
    Add_Attr(l_Attrs, 1889, p_Val_Str => p_Addr_Reg.Sca_City);
    --Квартира
    Add_Attr(l_Attrs, 1894, p_Val_Str => p_Addr_Reg.Sca_Apartment);
    --Корпус
    Add_Attr(l_Attrs, 1893, p_Val_Str => p_Addr_Reg.Sca_Block);
    --Будинок
    Add_Attr(l_Attrs, 1892, p_Val_Str => p_Addr_Reg.Sca_Building);
    --Вулиця (введення, у випадку відсутності в довіднику)
    Add_Attr(l_Attrs, 1890, p_Val_Str => p_Addr_Reg.Sca_Street);
    --Індекс
    IF p_Addr_Reg.Sca_Postcode IS NOT NULL THEN
      SELECT MAX(o.Npo_Id)
        INTO l_Index_Id
        FROM Uss_Ndi.v_Ndi_Post_Office o
       WHERE o.Npo_Index = p_Addr_Reg.Sca_Postcode;
      Add_Attr(l_Attrs, 1886, p_Val_Id => l_Index_Id);
    END IF;

    --Адреса проживання
    Add_Attr(l_Attrs, 1883, p_Val_Str => p_Phone);
    IF p_Addr_Fact.Sca_Kaot IS NOT NULL THEN
      --КАТОТТГ
      Add_Attr(l_Attrs,
               1873,
               p_Val_Id  => p_Addr_Fact.Sca_Kaot,
               p_Val_Str => Uss_Ndi.Api$dic_Common.Get_Katottg_Name(p_Addr_Fact.Sca_Kaot));
    END IF;
    --Область
    Add_Attr(l_Attrs, 1875, p_Val_Str => p_Addr_Fact.Sca_Region);
    --Район
    Add_Attr(l_Attrs, 1876, p_Val_Str => p_Addr_Fact.Sca_District);
    --Населений пункт
    Add_Attr(l_Attrs, 1877, p_Val_Str => p_Addr_Fact.Sca_City);
    --Квартира
    Add_Attr(l_Attrs, 1882, p_Val_Str => p_Addr_Fact.Sca_Apartment);
    --Корпус
    Add_Attr(l_Attrs, 1881, p_Val_Str => p_Addr_Fact.Sca_Block);
    --Будинок
    Add_Attr(l_Attrs, 1880, p_Val_Str => p_Addr_Fact.Sca_Building);
    --Вулиця (введення, у випадку відсутності в довіднику)
    Add_Attr(l_Attrs, 1878, p_Val_Str => p_Addr_Fact.Sca_Street);
    --Індекс
    IF p_Addr_Fact.Sca_Postcode IS NOT NULL THEN
      SELECT MAX(o.Npo_Id)
        INTO l_Index_Id
        FROM Uss_Ndi.v_Ndi_Post_Office o
       WHERE o.Npo_Index = p_Addr_Fact.Sca_Postcode;
      Add_Attr(l_Attrs, 1874, p_Val_Id => l_Index_Id);
    END IF;

    RETURN l_Attrs;
  END;


  ----------------------------------------------------------------------------
  -- Отримання основних даних для предзаповнення заяви
  ----------------------------------------------------------------------------
  PROCEDURE Get_Prefill_Main(p_Ap_Tp         IN VARCHAR2,
                             p_Ap_Sub_Tp     IN VARCHAR2,
                             p_App_Tp        IN VARCHAR2,
                             p_Pers_Cur      OUT SYS_REFCURSOR,
                             p_Pers_Addr_Cur OUT SYS_REFCURSOR,
                             p_Ap_Attrs      OUT SYS_REFCURSOR,
                             p_Ankt_Attrs    OUT SYS_REFCURSOR,
                             p_Docs_Cur      OUT SYS_REFCURSOR,
                             p_Attrs_Cur     OUT SYS_REFCURSOR,
                             p_Files_Cur     OUT SYS_REFCURSOR) IS
    l_Sc_Id       NUMBER;
    l_Scc_Id      NUMBER;
    l_Doc         Uss_Person.v_Sc_Document%ROWTYPE;
    l_Ln          Ap_Person.App_Ln%TYPE;
    l_Fn          Ap_Person.App_Fn%TYPE;
    l_Mn          Ap_Person.App_Mn%TYPE;
    l_Gender      Ap_Person.App_Gender%TYPE;
    l_Birth_Dt    DATE;
    l_Inv_Group   Uss_Person.v_Sc_Disability.Scy_Group%TYPE;
    l_Inv_Reason  Uss_Person.v_Sc_Disability.Scy_Reason%TYPE;
    l_Inv_Till_Dt DATE;
    l_Sc_Unique   Ap_Person.App_Esr_Num%TYPE;
    l_Addr_Fact   Uss_Person.v_Sc_Address%ROWTYPE;
    l_Addr_Reg    Uss_Person.v_Sc_Address%ROWTYPE;
    l_Index_Id    NUMBER;
    l_Phone       Uss_Person.v_Sc_Contact.Sct_Phone_Mob%TYPE;
    l_Email       Uss_Person.v_Sc_Contact.Sct_Email%TYPE;
    l_Ankt_Attrs  t_Ap_Document_Attrs;
    l_Ap_Attrs    t_Ap_Document_Attrs;
    l_Age         NUMBER;
    l_Ipn_Refuse  NUMBER;

    --Перевірка необхідності додавати атрибут в анкету
    FUNCTION Need_Attr(p_Nda_Id IN NUMBER) RETURN BOOLEAN IS
      l_Need_Attr NUMBER;
    BEGIN
      SELECT Sign(COUNT(*))
        INTO l_Need_Attr
        FROM Uss_Ndi.v_Ndi_Nda_Config c
       WHERE c.Nac_Ap_Tp = p_Ap_Tp
         AND c.History_Status = 'A'
         AND c.Nac_Nda = p_Nda_Id;

      RETURN l_Need_Attr = 1;
    END;

    --Додавання атрибута в анкету
    PROCEDURE Add_Ankt_Attr(p_Nda_Id  IN NUMBER,
                            p_Val_Str IN VARCHAR2 DEFAULT NULL,
                            p_Val_Dt  IN DATE DEFAULT NULL,
                            p_Val_Id  IN NUMBER DEFAULT NULL) IS
    BEGIN
      IF Need_Attr(p_Nda_Id) THEN
        Add_Attr(l_Ankt_Attrs, p_Nda_Id => p_Nda_Id, p_Val_Str => p_Val_Str, p_Val_Dt => p_Val_Dt, p_Val_Id => p_Val_Id);
      END IF;
    END;
  BEGIN
    l_Sc_Id := Ikis_Rbm.Tools.Getcusc(Ikis_Rbm.Tools.Getcurrentcu); --1293704;
    --На поточний момент предзаповнення працює лише для заявника, тому що нормиативно не врегульована видача персональних даних інших учасників зверення
    IF Nvl(p_App_Tp, '-') <> 'Z'
       OR l_Sc_Id IS NULL THEN
      p_Pers_Cur := Empty_Cursor;
      p_Pers_Addr_Cur := Empty_Cursor;
      p_Ap_Attrs := Empty_Cursor;
      p_Ankt_Attrs := Empty_Cursor;
      p_Docs_Cur := Empty_Cursor;
      p_Attrs_Cur := Empty_Cursor;
      p_Files_Cur := Empty_Cursor;
      RETURN;
    END IF;

    SELECT MAX(c.Sc_Scc), MAX(c.Sc_Unique)
      INTO l_Scc_Id, l_Sc_Unique
      FROM Uss_Person.v_Socialcard c
     WHERE c.Sc_Id = l_Sc_Id;

    SELECT i.Sci_Ln, i.Sci_Fn, i.Sci_Mn, i.Sci_Gender, b.Scb_Dt, Nvl(c.Sct_Phone_Mob, c.Sct_Phone_Num), c.Sct_Email
      INTO l_Ln, l_Fn, l_Mn, l_Gender, l_Birth_Dt, l_Phone, l_Email
      FROM Uss_Person.v_Sc_Change Cc
      JOIN Uss_Person.v_Sc_Identity i
        ON Cc.Scc_Sci = i.Sci_Id
      LEFT JOIN Uss_Person.v_Sc_Birth b
        ON Cc.Scc_Scb = b.Scb_Id
      LEFT JOIN Uss_Person.v_Sc_Contact c
        ON Cc.Scc_Sct = c.Sct_Id
     WHERE Cc.Scc_Id = l_Scc_Id;

    l_Age := Floor(Months_Between(SYSDATE, l_Birth_Dt) / 12);

    l_Ankt_Attrs := t_Ap_Document_Attrs();

    --Атрибути анкети по інвалідності
    BEGIN
      SELECT d.Scy_Group, d.Scy_Till_Dt, d.Scy_Reason
        INTO l_Inv_Group, l_Inv_Till_Dt, l_Inv_Reason
        FROM Uss_Person.v_Sc_Disability d
       WHERE d.Scy_Sc = l_Sc_Id
         AND d.History_Status = 'A';

      --Група інвалідності
      Add_Ankt_Attr(1790, p_Val_Str => l_Inv_Group);
      --Строк встановлення групи інвалідності
      Add_Ankt_Attr(1793, p_Val_Dt => l_Inv_Till_Dt);

      --Статус інвалідності
      IF l_Inv_Group IS NOT NULL THEN
        IF l_Inv_Reason = 'ID' THEN
          --Інвалідність з дитинства
          Add_Ankt_Attr(1789, p_Val_Str => 'IZ');
        ELSIF l_Age < 18 THEN
          --Дитина з інвалідністю
          Add_Ankt_Attr(1789, p_Val_Str => 'DI');
        ELSE
          --Особа з інвалідністю
          Add_Ankt_Attr(1789, p_Val_Str => 'I');
        END IF;
      END IF;

      IF l_Inv_Group IS NOT NULL
         AND l_Age < 18 THEN
        --Дитина з інвалідністю
        Add_Ankt_Attr(1797, p_Val_Str => 'T');
      END IF;

      IF l_Inv_Group = '1' THEN
        --Особа з інвалідністю I групи
        Add_Ankt_Attr(1798, p_Val_Str => 'T');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    SELECT Sign(COUNT(*))
      INTO l_Ipn_Refuse
      FROM Uss_Person.v_Sc_Document d
     WHERE d.Scd_Sc = l_Sc_Id
       AND d.Scd_Ndt = 10117
       AND d.Scd_St = 'A';

    IF l_Ipn_Refuse = 1 THEN
      Add_Ankt_Attr(812, p_Val_Str => 'T');
    END IF;

    --Адреса проживання
    BEGIN
      SELECT a.*
        INTO l_Addr_Fact
        FROM Uss_Person.v_Sc_Address a
       WHERE a.Sca_Sc = l_Sc_Id
         AND a.History_Status = 'A'
         AND a.Sca_Tp = '2'
       FETCH FIRST ROW ONLY;

      --#112934
      IF l_Addr_Fact.Sca_Kaot IS NOT NULL THEN
        --КАТОТТГ
        Add_Ankt_Attr(1873,
                      p_Val_Id  => l_Addr_Fact.Sca_Kaot,
                      p_Val_Str => Uss_Ndi.Api$dic_Common.Get_Katottg_Name(l_Addr_Fact.Sca_Kaot));
      END IF;
      --Квартира
      Add_Ankt_Attr(1882, p_Val_Str => l_Addr_Fact.Sca_Apartment);
      --Корпус
      Add_Ankt_Attr(1881, p_Val_Str => l_Addr_Fact.Sca_Block);
      --Будинок
      Add_Ankt_Attr(1880, p_Val_Str => l_Addr_Fact.Sca_Building);
      --Вулиця (введення, у випадку відсутності в довіднику)
      Add_Ankt_Attr(1878, p_Val_Str => l_Addr_Fact.Sca_Street);
      --Індекс
      IF l_Addr_Fact.Sca_Postcode IS NOT NULL THEN
        SELECT MAX(o.Npo_Id)
          INTO l_Index_Id
          FROM Uss_Ndi.v_Ndi_Post_Office o
         WHERE o.Npo_Index = l_Addr_Fact.Sca_Postcode;
        Add_Ankt_Attr(1874, p_Val_Id => l_Index_Id);
      END IF;
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
    END;

    --Адреса реєстрації
    BEGIN
      SELECT a.*
        INTO l_Addr_Reg
        FROM Uss_Person.v_Sc_Address a
       WHERE a.Sca_Sc = l_Sc_Id
         AND a.History_Status = 'A'
         AND a.Sca_Tp = '3'
       FETCH FIRST ROW ONLY;

      IF l_Addr_Reg.Sca_Kaot IS NOT NULL THEN
        --КАТОТТГ
        Add_Ankt_Attr(1885,
                      p_Val_Id  => l_Addr_Reg.Sca_Kaot,
                      p_Val_Str => Uss_Ndi.Api$dic_Common.Get_Katottg_Name(l_Addr_Reg.Sca_Kaot));
      END IF;
      --Квартира
      Add_Ankt_Attr(1894, p_Val_Str => l_Addr_Reg.Sca_Apartment);
      --Корпус
      Add_Ankt_Attr(1893, p_Val_Str => l_Addr_Reg.Sca_Block);
      --Будинок
      Add_Ankt_Attr(1892, p_Val_Str => l_Addr_Reg.Sca_Building);
      --Вулиця (введення, у випадку відсутності в довіднику)
      Add_Ankt_Attr(1890, p_Val_Str => l_Addr_Reg.Sca_Street);
      --Індекс
      IF l_Addr_Reg.Sca_Postcode IS NOT NULL THEN
        SELECT MAX(o.Npo_Id)
          INTO l_Index_Id
          FROM Uss_Ndi.v_Ndi_Post_Office o
         WHERE o.Npo_Index = l_Addr_Reg.Sca_Postcode;
        Add_Ankt_Attr(1886, p_Val_Id => l_Index_Id);
      END IF;
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
    END;

    --адреса електронної пошти
    Add_Ankt_Attr(3060, p_Val_Str => l_Email);
    --Контактний телефон
    Add_Ankt_Attr(1673, p_Val_Str => l_Phone);

    --Документ що посвідчує особу
    BEGIN
      SELECT Scd.Scd_Ndt, Scd.Scd_Doc, Scd.Scd_Dh, Scd.Scd_Seria, Scd.Scd_Number
        INTO l_Doc.Scd_Ndt, l_Doc.Scd_Doc, l_Doc.Scd_Dh, l_Doc.Scd_Seria, l_Doc.Scd_Number
        FROM (SELECT Row_Number() Over(ORDER BY Decode(Ndt.Ndt_Uniq_Group, 'PASP', 1, 'BRCR', 2, 'OVRP', 3, 9), Ndt.Ndt_Sc_Upd_Priority) AS Rn,
                      Scd.*
                 FROM Uss_Person.v_Sc_Document Scd
                 JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                   ON Ndt.Ndt_Id = Scd.Scd_Ndt
                  AND Ndt.Ndt_Ndc = 13
                WHERE Scd.Scd_Sc = l_Sc_Id
                  AND Scd.Scd_St = '1') Scd
       WHERE Scd.Rn = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
    END;

    --Основні данні учасника звернення
    OPEN p_Pers_Cur FOR
      SELECT l_Sc_Unique AS App_Esr_Num,
             --ПІБ
             l_Ln AS App_Ln, l_Fn AS App_Fn, l_Mn AS App_Mn,
             --РНОКПП
             (SELECT d.Scd_Number
                 FROM Uss_Person.v_Sc_Document d
                WHERE d.Scd_Sc = l_Sc_Id
                  AND d.Scd_Ndt = 5
                  AND d.Scd_St = '1') AS App_Inn,
             --Тип документу, що посвідчує особу
             l_Doc.Scd_Ndt AS App_Ndt,
             --Серія та номер документу, що посвідчує особу
             l_Doc.Scd_Seria || l_Doc.Scd_Number AS App_Doc_Num,
             --Стать
             l_Gender AS App_Gender
        FROM Dual;

     --Адреса реєстрації та проживання учасника звернення
     OPEN p_Pers_Addr_Cur FOR
       SELECT a.*, sca.DIC_NAME as Sca_Tp_Name, Uss_Ndi.Api$dic_Common.Get_Katottg_Name(a.sca_kaot) as Sca_Katottg_Name
          FROM Uss_Person.v_Sc_Address a
          JOIN Uss_Ndi.V_Ddn_Sca_Tp sca
            ON a.sca_tp = sca.DIC_VALUE
         WHERE a.Sca_Sc = l_Sc_Id
           AND a.History_Status = 'A'
           AND a.Sca_Tp in ('2','3');

    --Заява про надання соціальних послуг
    IF p_Ap_Sub_Tp = 'SZ' THEN
      l_Ap_Attrs := Get_Prefill_Sz(p_Ln        => l_Ln,
                                   p_Fn        => l_Fn,
                                   p_Mn        => l_Mn,
                                   p_Birth_Dt  => l_Birth_Dt,
                                   p_Phone     => l_Phone,
                                   p_Addr_Fact => l_Addr_Fact,
                                   p_Addr_Reg  => l_Addr_Reg);

    ELSE
      l_Ap_Attrs := t_Ap_Document_Attrs();
    END IF;

    --Атрибути анкети
    p_Ankt_Attrs := Attrs2cur(l_Ankt_Attrs);

    --Атрибути заяви
    p_Ap_Attrs := Attrs2cur(l_Ap_Attrs);

    --Документ що посвідчує особу
    OPEN p_Docs_Cur FOR
      SELECT l_Doc.Scd_Ndt AS Apd_Ndt, t.Ndt_Name_Short AS Apd_Ndt_Name, l_Doc.Scd_Doc AS Apd_Doc, l_Doc.Scd_Dh AS Apd_Dh,
             l_Doc.Scd_Seria || l_Doc.Scd_Number AS Apd_Num
        FROM Uss_Ndi.v_Ndi_Document_Type t
       WHERE t.Ndt_Id = l_Doc.Scd_Ndt;

    --Атрибути документа що посвідчує особу
    OPEN p_Attrs_Cur FOR
      SELECT l_Doc.Scd_Doc AS Doc_Id, l_Doc.Scd_Dh AS Dh_Id, a.Da_Nda AS Apda_Nda, a.Da_Val_String AS Apda_Val_String,
             a.Da_Val_Int AS Apda_Val_Int, a.Da_Val_Dt AS Apda_Val_Dt, a.Da_Val_Id AS Apda_Val_Id, a.Da_Val_Sum AS Apda_Val_Sum,
             n.Nda_Id, n.Nda_Name, n.Nda_Is_Key, n.Nda_Ndt, n.Nda_Order, n.Nda_Pt, n.Nda_Is_Req, n.Nda_Def_Value, n.Nda_Can_Edit,
             n.Nda_Need_Show, Pt.Pt_Id, Pt.Pt_Code, Pt.Pt_Name, Pt.Pt_Ndc, Pt.Pt_Edit_Type, Pt.Pt_Data_Type
        FROM Uss_Doc.v_Doc_Attr2hist h
        JOIN Uss_Doc.v_Doc_Attributes a
          ON h.Da2h_Da = a.Da_Id
        JOIN Uss_Ndi.v_Ndi_Document_Attr n
          ON a.Da_Nda = n.Nda_Id
        JOIN Uss_Ndi.v_Ndi_Param_Type Pt
          ON Pt.Pt_Id = n.Nda_Pt
       WHERE h.Da2h_Dh = l_Doc.Scd_Dh;

    --Вкладення документа що посвідчує особу
    OPEN p_Files_Cur FOR
      SELECT l_Doc.Scd_Doc AS Doc_Id, l_Doc.Scd_Dh AS Dh_Id, f.File_Code, f.File_Name, f.File_Mime_Type, f.File_Size, f.File_Hash,
             f.File_Create_Dt, f.File_Description, s.File_Code AS File_Sign_Code, s.File_Hash AS File_Sign_Hash,
             (SELECT Listagg(nvl(Fs.File_Code, ''), ',') Within GROUP(ORDER BY Ss.Dats_Id)
                 FROM Uss_Doc.v_Doc_Attach_Signs Ss
                 JOIN Uss_Doc.v_Files Fs
                   ON Ss.Dats_Sign_File = Fs.File_Id
                WHERE Ss.Dats_Dat = a.Dat_Id) AS File_Signs, a.Dat_Num
        FROM Uss_Doc.v_Doc_Attachments a
        JOIN Uss_Doc.v_Files f
          ON a.Dat_File = f.File_Id
        LEFT JOIN Uss_Doc.v_Files s
          ON a.Dat_Sign_File = s.File_Id
       WHERE a.Dat_Dh = l_Doc.Scd_Dh;
  END;

  ----------------------------------------------------------------------------
  -- Отримання документів для предзаповнення заяви
  ----------------------------------------------------------------------------
  PROCEDURE Get_Prefill_Docs(p_Ap_Tp           IN VARCHAR2,
                             p_App_Tp          IN VARCHAR2,
                             p_Services        IN VARCHAR2,
                             p_Ankt_Attributes IN CLOB,
                             p_Docs_Cur        OUT SYS_REFCURSOR,
                             p_Attrs_Cur       OUT SYS_REFCURSOR,
                             p_Files_Cur       OUT SYS_REFCURSOR) IS
    l_Sc_Id           NUMBER;
    l_Services        t_Ids;
    l_Ankt_Attributes t_Ap_Document_Attrs := t_Ap_Document_Attrs();
    l_Sc_Docs         t_Sc_Docs;
  BEGIN
    l_Sc_Id := Ikis_Rbm.Tools.Getcusc(Ikis_Rbm.Tools.Getcurrentcu);

    IF Nvl(p_App_Tp, '-') <> 'Z'
       OR l_Sc_Id IS NULL THEN
      p_Docs_Cur := Empty_Cursor;
      p_Attrs_Cur := Empty_Cursor;
      p_Files_Cur := Empty_Cursor;
      RETURN;
    END IF;


    --Парсимо перелік типів послуг учасника
    SELECT To_Number(Column_Value)
      BULK COLLECT
      INTO l_Services
      FROM Xmltable(Rtrim(p_Services, ','));

    --Парсимо атрибути анкети
    IF Dbms_Lob.Getlength(p_Ankt_Attributes) > 0 THEN
      EXECUTE IMMEDIATE Type2xmltable(Package_Name, 't_Ap_Document_Attrs', TRUE) BULK COLLECT
        INTO l_Ankt_Attributes
        USING p_Ankt_Attributes;
    END IF;

    --    OPEN p_Docs_Cur FOR
    SELECT d.Scd_Ndt, d.Scd_Doc, d.Scd_Dh, d.Scd_Seria || d.Scd_Number
      BULK COLLECT
      INTO l_Sc_Docs
      FROM Uss_Person.v_Sc_Document d
      JOIN Uss_Ndi.v_Ndi_Nst_Doc_Config c
        ON d.Scd_Ndt = c.Nndc_Ndt
      JOIN Uss_Ndi.v_Ndi_Document_Type t
        ON d.Scd_Ndt = t.Ndt_Id
       AND t.Ndt_Ndc <> 13
     WHERE d.Scd_Sc = l_Sc_Id
       AND c.Nndc_Ap_Tp = p_Ap_Tp
          --Послуги
       AND (c.Nndc_Nst IN (SELECT s.Id
                             FROM TABLE(l_Services) s) OR c.Nndc_Nst IS NULL)
          --Тип учасника
       AND (c.Nndc_App_Tp = p_App_Tp OR c.Nndc_App_Tp IS NULL)
          --Ознаки та інщі атрибути
       AND (c.Nndc_Nda IS NULL OR EXISTS
            (SELECT NULL
               FROM TABLE(l_Ankt_Attributes) a
              WHERE c.Nndc_Nda = a.Apda_Nda
                AND (a.Apda_Val_String IS NULL AND c.Nndc_Val_String IS NULL OR a.Apda_Val_String = c.Nndc_Val_String)))
       AND c.History_Status = 'A';

    OPEN p_Docs_Cur FOR
      SELECT Ndt_Id AS Apd_Ndt, Doc_Id AS Apd_Doc, Dh_Id AS Apd_Dh, Doc_Num AS Apd_Num
        FROM TABLE(l_Sc_Docs);

    OPEN p_Attrs_Cur FOR
      SELECT d.Doc_Id, d.Dh_Id, a.Da_Nda AS Apda_Nda, a.Da_Val_String AS Apda_Val_String, a.Da_Val_Int AS Apda_Val_Int,
             a.Da_Val_Dt AS Apda_Val_Dt, a.Da_Val_Id AS Apda_Val_Id, a.Da_Val_Sum AS Apda_Val_Sum, n.Nda_Id, n.Nda_Name,
             n.Nda_Is_Key, n.Nda_Ndt, n.Nda_Order, n.Nda_Pt, n.Nda_Is_Req, n.Nda_Def_Value, n.Nda_Can_Edit, n.Nda_Need_Show,
             Pt.Pt_Id, Pt.Pt_Code, Pt.Pt_Name, Pt.Pt_Ndc, Pt.Pt_Edit_Type, Pt.Pt_Data_Type
        FROM TABLE(l_Sc_Docs) d
        JOIN Uss_Doc.v_Doc_Attr2hist h
          ON d.Dh_Id = h.Da2h_Dh
        JOIN Uss_Doc.v_Doc_Attributes a
          ON h.Da2h_Da = a.Da_Id
        JOIN Uss_Ndi.v_Ndi_Document_Attr n
          ON a.Da_Nda = n.Nda_Id
        JOIN Uss_Ndi.v_Ndi_Param_Type Pt
          ON Pt.Pt_Id = n.Nda_Pt;

    OPEN p_Files_Cur FOR
      SELECT d.Doc_Id, d.Dh_Id, f.File_Code, f.File_Name, f.File_Mime_Type, f.File_Size, f.File_Hash, f.File_Create_Dt,
             f.File_Description, s.File_Code AS File_Sign_Code, s.File_Hash AS File_Sign_Hash,
             (SELECT Listagg(nvl(Fs.File_Code, ''), ',') Within GROUP(ORDER BY Ss.Dats_Id)
                 FROM Uss_Doc.v_Doc_Attach_Signs Ss
                 JOIN Uss_Doc.v_Files Fs
                   ON Ss.Dats_Sign_File = Fs.File_Id
                WHERE Ss.Dats_Dat = a.Dat_Id) AS File_Signs, a.Dat_Num
        FROM TABLE(l_Sc_Docs) d
        JOIN Uss_Doc.v_Doc_Attachments a
          ON d.Dh_Id = a.Dat_Dh
        JOIN Uss_Doc.v_Files f
          ON a.Dat_File = f.File_Id
        LEFT JOIN Uss_Doc.v_Files s
          ON a.Dat_Sign_File = s.File_Id;
  END;

  PROCEDURE SendEmailMessage(p_Email  IN VARCHAR2,
                             p_Header IN VARCHAR2,
                             p_Msg    IN VARCHAR2) IS
  BEGIN
    USS_PERSON.Api$nt_Api.SendRcMessage(p_email =>  p_Email,
                                        p_source => 'PORTAL',
                                        p_title =>  Chr(38)||'101#mail_header='||p_Header,
                                        p_text =>   Chr(38)||'101#mail_body='||p_Msg);
  END;

  procedure get_org_by_kaot (p_kaot_id in number,
                             p_org_id out number,
                             p_org_name out varchar2)
  is
    l_org_to number;
    l_kaot_id number;
  begin
    /*SELECT t.nk2o_org, p.org_name
      into p_org_id, p_org_name
      FROM uss_ndi.v_ndi_kaot2org t
      join v_opfu p on (p.org_id = t.nk2o_org)
     where t.nk2o_kaot = p_kaot_id
       and t.history_status = 'A'
       and trunc(sysdate) between nvl(t.nk2o_start_dt, trunc(sysdate)) and nvl(t.nk2o_stop_dt, sysdate);
    */
    SELECT nok_org, org_name, org_to
    into p_org_id, p_org_name, l_org_to
    FROM(
    SELECT t.nok_org, p.org_name, p.org_to, t.nok_id
      FROM uss_ndi.v_ndi_org2kaot t
      join v_opfu p on (p.org_id = t.nok_org)
     where t.nok_kaot = p_kaot_id
       and t.history_status = 'A'
     ORDER BY  t.nok_id
     )
     WHERE rownum=1;

    if (l_org_to = 32) then
      SELECT case when t.kaot_kaot_l4 = t.kaot_id then t.kaot_kaot_l3
                  when t.kaot_kaot_l5 = t.kaot_id then t.kaot_kaot_l4
                  when t.kaot_kaot_l3 = t.kaot_id then t.kaot_kaot_l2
                  when t.kaot_kaot_l2 = t.kaot_id then t.kaot_kaot_l1
             end
        into l_kaot_id
        FROM uss_ndi.v_ndi_katottg t
       where t.kaot_id = p_kaot_id;

      begin
      SELECT nok_org, org_name, org_to
      into p_org_id, p_org_name, l_org_to
      FROM(
      SELECT t.nok_org, p.org_name, p.org_to, t.nok_id
        FROM uss_ndi.v_ndi_org2kaot t
        join v_opfu p on (p.org_id = t.nok_org)
       where t.nok_kaot = l_kaot_id
         and t.history_status = 'A'
      ORDER BY  t.nok_id
      )
       WHERE rownum=1
     ;
     exception when others then
       null;
     end;
    end if;


    exception when others then
      raise_application_error(-20000, 'Увага! Вибір населеного пункту виконано некоректно.' || chr(10) || sqlerrm);
  end;

  function get_org_by_kaot (p_kaot_id in number) return number is
    l_id number;
    l_name varchar2(500);
  begin
    get_org_by_kaot(p_kaot_id, l_id, l_name);
    return l_id;
  exception
    when others then
      return null;
  end;

  --#112827
  PROCEDURE get_dzr_by_sc(p_sc_id IN NUMBER, p_res OUT SYS_REFCURSOR) IS
    l_Sc_Id NUMBER;
  BEGIN
    --USS_PERSON.API$SC_TOOLS.get_dzr_by_sc(P_SC_ID => P_SC_ID,p_res => p_res);
    Tools.LOG(p_src => 'USS_VISIT.DNET$APPEAL.get_dzr_by_sc',
                                    p_obj_tp => 'SC',
                                    p_obj_id => l_Sc_Id,
                                    p_regular_params => 'l_Sc_Id='||l_Sc_Id||' p_sc_id='||p_sc_id);
    --#113474
    l_Sc_Id := Ikis_Rbm.Tools.Getcusc(Ikis_Rbm.Tools.Getcurrentcu);
    USS_ESR.Api$find.Get_avalilable_dzr_by_sc(p_sc_id => l_Sc_Id, p_res => p_res);
  END;

  --#116749
  PROCEDURE Get_Vpo_Sc_Address(p_sc_id IN NUMBER,
                               p_res OUT SYS_REFCURSOR) IS
    l_Sc_Id NUMBER;
    l_sc_doc_id NUMBER;
  BEGIN
    l_Sc_Id := Ikis_Rbm.Tools.Getcusc(Ikis_Rbm.Tools.Getcurrentcu);

    Tools.LOG(p_src => 'USS_VISIT.DNET$APPEAL.Get_Vpo_Sc_Address',
                                    p_obj_tp => 'SC',
                                    p_obj_id => l_Sc_Id,
                                    p_regular_params => 'l_Sc_Id='||l_Sc_Id||' p_sc_id='||p_sc_id);

    --#116959 - 21.02.2025
    l_sc_doc_id := uss_person.Api$sc_Tools.get_sc_doc(l_Sc_Id,10052);

    open p_res for
    SELECT 0 SCA_ID,
       l_Sc_Id SCA_SC,
       2 SCA_TP,
       uss_person.Api$sc_Tools.get_sc_doc_val_id(l_sc_doc_id,4492) SCA_KAOT,
       1 SCA_NC,
       NULL SCA_COUNTRY,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4481) SCA_REGION,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4482) SCA_DISTRICT,
       NULL SCA_POSTCODE,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4483) SCA_CITY,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4485) SCA_STREET,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4487) SCA_BUILDING,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4488) SCA_BLOCK,
       uss_person.Api$sc_Tools.get_sc_doc_val_str(l_sc_doc_id,4489) SCA_APARTMENT,
       NULL SCA_NOTE,
       NULL SCA_SCR
    FROM DUAL;
    /*
    select *
    from uss_person.v_sc_address sca
    where sca.sca_tp=2
    and sca_src='38'
    and sca.history_status='A'
    and sca.sca_sc = l_Sc_Id;
    */
  END;

END Dnet$appeal_Portal;
/