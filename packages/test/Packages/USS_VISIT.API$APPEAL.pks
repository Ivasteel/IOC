/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$APPEAL
IS
    Package_Name                       CONSTANT VARCHAR2 (100) := 'API$APPEAL';

    Ex_Opt_Block_Viol                           EXCEPTION;

    -------------------------------------------
    --Джерела надходження даних
    -------------------------------------------
    c_Src_Uss                          CONSTANT VARCHAR2 (10) := 'USS';
    c_Src_Vst                          CONSTANT VARCHAR2 (10) := 'VST';
    c_Src_Diia                         CONSTANT VARCHAR2 (10) := 'DIIA';
    c_Src_Community                    CONSTANT VARCHAR2 (10) := 'COM'; --Соцгромада
    c_Src_Portal                       CONSTANT VARCHAR2 (10) := 'PORTAL';
    c_Src_Cmes                         CONSTANT VARCHAR2 (10) := 'CMES';
    c_Src_Ehlp                         CONSTANT VARCHAR2 (10) := 'EHLP';

    -------------------------------------------
    --Статуси звернень
    -------------------------------------------
    c_Ap_St_New                        CONSTANT VARCHAR2 (10) := 'N';   --Нове
    c_Ap_St_Reg_In_Work                CONSTANT VARCHAR2 (10) := 'J';   --Нове
    c_Ap_St_Wait_Docs                  CONSTANT VARCHAR2 (10) := 'W'; --Очікування документів
    c_Ap_St_Attr                       CONSTANT VARCHAR2 (10) := 'A'; --Атрибутування
    c_Ap_St_Reg                        CONSTANT VARCHAR2 (10) := 'F'; --Зареєстровано
    c_Ap_St_Returned                   CONSTANT VARCHAR2 (10) := 'P'; --Повернуто
    c_Ap_St_Not_Verified               CONSTANT VARCHAR2 (10) := 'VE'; --Неуспішна верифікація
    c_Ap_St_Declined                   CONSTANT VARCHAR2 (10) := 'X'; --Відхилено

    -------------------------------------------
    --Типи звернень
    -------------------------------------------
    c_Ap_Tp_Help                       CONSTANT VARCHAR2 (10) := 'V';
    c_Ap_Tp_Subs                       CONSTANT VARCHAR2 (10) := 'S';
    c_Ap_Tp_Vpo                        CONSTANT VARCHAR2 (10) := 'VPO';
    c_Ap_Tp_Adopt                      CONSTANT VARCHAR2 (10) := 'ADOPT';
    c_Ap_Tp_Ehelp                      CONSTANT VARCHAR2 (10) := 'IA';
    c_Ap_Tp_SS                         CONSTANT VARCHAR2 (10) := 'SS';
    c_Ap_Tp_DD                         CONSTANT VARCHAR2 (10) := 'DD';

    -------------------------------------------
    --Підтипи звернень
    -------------------------------------------
    c_Ap_Sub_Tp_SZ                     CONSTANT VARCHAR2 (10) := 'SZ';


    -------------------------------------------
    --Типи повідомлень в журналі обробки
    -------------------------------------------
    c_Apl_Tp_Sys                       CONSTANT VARCHAR2 (10) := 'SYS';
    c_Apl_Tp_Usr                       CONSTANT VARCHAR2 (10) := 'USR';
    c_Apl_Tp_Tinfo                     CONSTANT VARCHAR2 (10) := 'TINFO';
    c_Apl_Tp_Terror                    CONSTANT VARCHAR2 (10) := 'TERROR';

    -------------------------------------------
    --Типи послуг
    -------------------------------------------
    c_Aps_Nst_Help_Alone_Mother        CONSTANT NUMBER := 267;
    c_Aps_Nst_rehab_Tool               CONSTANT NUMBER := 22;

    -------------------------------------------
    --Типи учасників звернення
    -------------------------------------------
    c_App_Tp_Applicant                 CONSTANT VARCHAR2 (10) := 'Z'; --Заявник
    c_App_Tp_Applicant_Rep             CONSTANT VARCHAR2 (10) := 'P'; --Представник заявника
    c_App_Tp_Familly                   CONSTANT VARCHAR2 (10) := 'FM'; --Член сім’ї
    c_App_Tp_Charge                    CONSTANT VARCHAR2 (10) := 'FP'; --Утриманець
    c_App_Tp_Receiver                  CONSTANT VARCHAR2 (10) := 'O'; --Отримувач допомоги

    -------------------------------------------
    --Типи длокументів
    -------------------------------------------
    c_Apd_Ndt_Zayv                     CONSTANT NUMBER := 600;
    c_Apd_Ndt_Zayv_p                   CONSTANT NUMBER := 835; --заява при надходжені з порталу
    c_Apd_Ndt_Ankt                     CONSTANT NUMBER := 605;
    c_Apd_Ndt_Pasp                     CONSTANT NUMBER := 6;
    c_Apd_Ndt_Idcard                   CONSTANT NUMBER := 7;
    c_Apd_Ndt_Vpo_Crt                  CONSTANT NUMBER := 10052;
    c_Apd_Ndt_Ess_Appeal               CONSTANT NUMBER := 1015;
    c_Apd_Ndt_RNOKPP                   CONSTANT NUMBER := 5;
    c_Apd_Ndt_RNOKPP_Refusal           CONSTANT NUMBER := 10117;
    c_Apd_Ndt_Veteran                  CONSTANT NUMBER := 10305;
    c_Apd_Ndt_rehab_Tool               CONSTANT NUMBER := 10344;
    c_Apd_Ndt_rehab_Tool_outcome       CONSTANT NUMBER := 10339;
    c_Apd_Ndt_KEP_Identity             CONSTANT NUMBER := 10366;

    -------------------------------------------
    --Атрибути длокументів
    -------------------------------------------
    c_Apda_Nda_Relation                CONSTANT NUMBER := 649; --З анкети ступінь родинного звязку
    c_Apda_Nda_Is_Alone                CONSTANT NUMBER := 641; --З анкети Одинокий/одинока
    c_Apda_Nda_Fop                     CONSTANT NUMBER := 651;  --З анкети ФОП

    c_Apda_Nda_Care_Child3             CONSTANT NUMBER := 653; --Доглядає за дитиною до 3-х років
    c_Apda_Nda_Care_Old                CONSTANT NUMBER := 655; --Доглядає за особою похилого віку, 80-ти річною особою
    c_Apda_Nda_Care_Child_Dis          CONSTANT NUMBER := 656; --Доглядає за хворою дитиною, якій не встановлено інвалідність
    c_Apda_Nda_Care_Per_Dis1           CONSTANT NUMBER := 657; --Доглядає за особою з інвалідністю І групи
    c_Apda_Nda_Care_Per_Dis2           CONSTANT NUMBER := 658; --Доглядає за особою з інвалідністю ІІ групи внаслідок психічного розладу
    c_Apda_Nda_Care_Child18            CONSTANT NUMBER := 659; --Доглядає за дитиною з інвалідністю до 18-років

    c_Apda_Nda_Divorsed                CONSTANT NUMBER := 669; --З заяви на допомогу
    c_Apda_Nda_Unmarried               CONSTANT NUMBER := 670; --З заяви на допомогу
    c_Apda_Nda_Married                 CONSTANT NUMBER := 671; --З заяви на допомогу

    c_Apda_Nda_Addr_Residence_Ind      CONSTANT NUMBER := 599; --Адреса проживання Індекс
    c_Apda_Nda_Addr_Registration_Ind   CONSTANT NUMBER := 587; --Адреса реєстрації Індекс
    -------------------------------------------
    --Ступінь родинного зв’язку
    -------------------------------------------
    c_Rel_Tp_Applicant                 CONSTANT VARCHAR2 (10) := 'Z';
    c_Rel_Tp_Husband_Or_Wife           CONSTANT VARCHAR2 (10) := 'HW';

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
        Apm_Katottg_Code    Uss_Ndi.v_Ndi_Katottg.Kaot_Code%TYPE,
        Apm_Mfo             Uss_Ndi.v_Ndi_Bank.Nb_Mfo%TYPE,
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
        Attributes         XMLTYPE,
        Apd_Attachments    XMLTYPE,
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
        Apri_Id        Apr_Income.Apri_Id%TYPE,
        Apri_Apr       Apr_Income.Apri_Apr%TYPE,
        Apri_Tp        Apr_Income.Apri_Tp%TYPE,
        Apri_Sum       VARCHAR2 (100),         --потом конвертируется в number
        Apri_Source    Apr_Income.Apri_Source%TYPE,
        Apri_Aprp      Apr_Income.Apri_Aprp%TYPE,
        Deleted        NUMBER
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
        Vehicles          t_Apr_Vehicles
    );

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
        Vehicles          XMLTYPE
    );

    -- типи для копіювання звернення
    --
    TYPE Tc_Ap_Service IS TABLE OF Ap_Service%ROWTYPE;

    TYPE Tc_Ap_Document IS TABLE OF Ap_Document%ROWTYPE;

    TYPE Tc_Ap_Document_Attr IS TABLE OF Ap_Document_Attr%ROWTYPE;

    TYPE Tc_Ap_Person IS TABLE OF Ap_Person%ROWTYPE;

    TYPE Tc_Ap_Payment IS TABLE OF Ap_Payment%ROWTYPE;

    TYPE Tc_Apr_Person IS TABLE OF Apr_Person%ROWTYPE;

    TYPE Tc_Apr_Income IS TABLE OF Apr_Income%ROWTYPE;

    TYPE Tc_Apr_Living_Quarters IS TABLE OF Apr_Living_Quarters%ROWTYPE;

    TYPE Tc_Apr_Land_Plot IS TABLE OF Apr_Land_Plot%ROWTYPE;

    TYPE Tc_Apr_Other_Income IS TABLE OF Apr_Other_Income%ROWTYPE;

    TYPE Tc_Apr_Vehicle IS TABLE OF Apr_Vehicle%ROWTYPE;

    TYPE Tc_Apr_Spending IS TABLE OF Apr_Spending%ROWTYPE;

    TYPE Rc_Map IS RECORD
    (
        Old_Id    NUMBER,
        New_Id    NUMBER
    );

    TYPE Tc_Map IS TABLE OF Rc_Map;

    FUNCTION Check_Appeal_Tp (p_Ap_Tp       IN Appeal.Ap_Tp%TYPE,
                              p_Def_Ap_Ap   IN Appeal.Ap_Tp%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Set_Ap_Sub_Tp (p_Ap_Id IN Appeal.Ap_Id%TYPE);

    FUNCTION Define_Ap_Sub_Tp (p_Ap_Id IN Appeal.Ap_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Is_Appeal_Maked_Correct (p_Ap_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Is_Prepare_Appeal_Copy2ESR (p_Ap_id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Save_Ap_Correct_Status (
        p_Ap_Id               IN Appeal.Ap_Id%TYPE,
        p_Ap_Correct_status   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Save_Appeal (
        p_Ap_Id               IN     Appeal.Ap_Id%TYPE,
        p_Ap_Num              IN     Appeal.Ap_Num%TYPE,
        p_Ap_Reg_Dt           IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Create_Dt        IN     Appeal.Ap_Create_Dt%TYPE,
        p_Ap_Src              IN     Appeal.Ap_Src%TYPE,
        p_Ap_St               IN OUT Appeal.Ap_St%TYPE,
        p_Com_Org             IN     Appeal.Com_Org%TYPE,
        p_Ap_Is_Second        IN     Appeal.Ap_Is_Second%TYPE,
        p_Ap_Vf               IN     Appeal.Ap_Vf%TYPE,
        p_Com_Wu              IN     Appeal.Com_Wu%TYPE,
        p_Ap_Tp               IN     Appeal.Ap_Tp%TYPE,
        p_New_Id                 OUT Appeal.Ap_Id%TYPE,
        p_Ap_Ext_Ident        IN     Appeal.Ap_Ext_Ident%TYPE DEFAULT NULL,
        p_Ap_Doc              IN     Appeal.Ap_Doc%TYPE DEFAULT NULL,
        p_Ap_Is_Ext_Process   IN     Appeal.Ap_Is_Ext_Process%TYPE DEFAULT NULL,
        p_Obi_Ts              IN     Appeal.Obi_Ts%TYPE DEFAULT NULL,
        p_Ap_Ext_Ident2       IN     Appeal.Ap_Ext_Ident2%TYPE DEFAULT NULL,
        p_Ap_Dest_Org         IN     Appeal.Ap_Dest_Org%TYPE DEFAULT NULL,
        p_Ap_Cu               IN     Appeal.Ap_Cu%TYPE DEFAULT NULL,
        p_Ap_Sub_Tp           IN     Appeal.Ap_Sub_Tp%TYPE DEFAULT NULL,
        p_Ap_Ap_Main          IN     Appeal.Ap_Ap_Main%TYPE DEFAULT NULL);

    FUNCTION Gen_Appeal_Num (p_Ap_Id   IN Appeal.Ap_Id%TYPE,
                             p_Ap_Tp   IN Appeal.Ap_Tp%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Tp (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Tp%TYPE;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Src (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Src%TYPE;

    FUNCTION Get_Ap_Sub_Tp (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Sub_Tp%TYPE;

    FUNCTION Get_Ap_Reg_Dt (p_Ap_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Ap_Ap_Main (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Ap_Main%TYPE;

    FUNCTION Get_Ap_Is_Ext_Process (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Set_Ap_Tp (p_Ap_Id IN NUMBER, p_Ap_Tp IN Appeal.Ap_Tp%TYPE);

    FUNCTION Get_Ap_Ext_Ident2 (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Ext_Ident2%TYPE;

    PROCEDURE Set_Ap_Ext_Ident2 (
        p_Ap_Id           IN NUMBER,
        p_Ap_Ext_Ident2   IN Appeal.Ap_Ext_Ident2%TYPE);

    FUNCTION Parse_Services (p_Ap_Services IN CLOB)
        RETURN t_Ap_Services;

    PROCEDURE Save_Service (p_Aps_Id    IN     Ap_Service.Aps_Id%TYPE,
                            p_Aps_Nst   IN     Ap_Service.Aps_Nst%TYPE,
                            p_Aps_Ap    IN     Ap_Service.Aps_Ap%TYPE,
                            p_Aps_St    IN     Ap_Service.Aps_St%TYPE,
                            p_New_Id       OUT Ap_Service.Aps_Id%TYPE);

    PROCEDURE Delete_Service (p_Id Ap_Service.Aps_Id%TYPE);

    PROCEDURE Delete_Service_Payments (p_Aps_Id IN Ap_Service.Aps_Id%TYPE);

    FUNCTION Service_Exists (p_Aps_Ap    IN Ap_Service.Aps_Ap%TYPE,
                             p_Aps_Nst   IN Ap_Service.Aps_Nst%TYPE)
        RETURN BOOLEAN;

    FUNCTION Document_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Parse_Persons (p_Ap_Persons IN CLOB)
        RETURN t_Ap_Persons;

    FUNCTION Get_Next_App_Num (p_Ap_Id IN APPEAL.AP_ID%TYPE)
        RETURN NUMBER;

    PROCEDURE Save_Person (p_App_Id        IN     Ap_Person.App_Id%TYPE,
                           p_App_Ap        IN     Ap_Person.App_Ap%TYPE,
                           p_App_Tp        IN     Ap_Person.App_Tp%TYPE,
                           p_App_Inn       IN     Ap_Person.App_Inn%TYPE,
                           p_App_Ndt       IN     Ap_Person.App_Ndt%TYPE,
                           p_App_Doc_Num   IN     Ap_Person.App_Doc_Num%TYPE,
                           p_App_Fn        IN     Ap_Person.App_Fn%TYPE,
                           p_App_Mn        IN     Ap_Person.App_Mn%TYPE,
                           p_App_Ln        IN     Ap_Person.App_Ln%TYPE,
                           p_App_Esr_Num   IN     Ap_Person.App_Esr_Num%TYPE,
                           p_App_Gender    IN     Ap_Person.App_Gender%TYPE,
                           p_App_Vf        IN     Ap_Person.App_Vf%TYPE,
                           p_App_Sc        IN     Ap_Person.App_Sc%TYPE,
                           p_App_Num       IN     Ap_Person.App_Num%TYPE,
                           p_New_Id           OUT Ap_Person.App_Id%TYPE);

    PROCEDURE Delete_Person (p_Id Ap_Person.App_Id%TYPE);

    PROCEDURE Detach_Person_Docs (p_App_Id IN Ap_Person.App_Id%TYPE);

    PROCEDURE Delete_Person_Payments (p_App_Id IN Ap_Person.App_Id%TYPE);

    FUNCTION Get_Person_Tp (p_App_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Relation_Tp (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Inn (p_App_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Inn_Doc (p_App_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Gender (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Person_Has_Inn (p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Get_Person_Doc (p_App_Id    IN     NUMBER,
                              p_Ndt_Id    IN OUT NUMBER,
                              p_Apd_Id       OUT NUMBER,
                              p_Doc_Num      OUT VARCHAR2);

    FUNCTION Parse_Payments (p_Ap_Payments IN CLOB)
        RETURN t_Ap_Payments;

    PROCEDURE Save_Payment (
        p_Apm_Id             IN     Ap_Payment.Apm_Id%TYPE,
        p_Apm_Ap             IN     Ap_Payment.Apm_Ap%TYPE,
        p_Apm_Aps            IN     Ap_Payment.Apm_Aps%TYPE,
        p_Apm_App            IN     Ap_Payment.Apm_App%TYPE,
        p_Apm_Tp             IN     Ap_Payment.Apm_Tp%TYPE,
        p_Apm_Index          IN     Ap_Payment.Apm_Index%TYPE,
        p_Apm_Kaot           IN     Ap_Payment.Apm_Kaot%TYPE,
        p_Apm_Nb             IN     Ap_Payment.Apm_Nb%TYPE,
        p_Apm_Account        IN     Ap_Payment.Apm_Account%TYPE,
        p_Apm_Need_Account   IN     Ap_Payment.Apm_Need_Account%TYPE,
        p_Apm_Street         IN     Ap_Payment.Apm_Street%TYPE,
        p_Apm_Ns             IN     Ap_Payment.Apm_Ns%TYPE,
        p_Apm_Building       IN     Ap_Payment.Apm_Building%TYPE,
        p_Apm_Block          IN     Ap_Payment.Apm_Block%TYPE,
        p_Apm_Apartment      IN     Ap_Payment.Apm_Apartment%TYPE,
        p_Apm_Dppa           IN     Ap_Payment.Apm_Dppa%TYPE,
        p_New_Id                OUT Ap_Payment.Apm_Id%TYPE);

    PROCEDURE Delete_Payment (p_Id Ap_Payment.Apm_Id%TYPE);

    FUNCTION Parse_Documents (p_Ap_Documents IN CLOB)
        RETURN t_Ap_Documents;

    PROCEDURE Save_Document (
        p_Apd_Id                IN     Ap_Document.Apd_Id%TYPE,
        p_Apd_Ap                IN     Ap_Document.Apd_Ap%TYPE,
        p_Apd_Ndt               IN     Ap_Document.Apd_Ndt%TYPE,
        p_Apd_Doc               IN     Ap_Document.Apd_Doc%TYPE,
        p_Apd_Vf                IN     Ap_Document.Apd_Vf%TYPE,
        p_Apd_App               IN     Ap_Document.Apd_App%TYPE,
        p_New_Id                   OUT Ap_Document.Apd_Id%TYPE,
        p_Com_Wu                IN     NUMBER,
        p_Apd_Dh                IN     Ap_Document.Apd_Dh%TYPE,
        p_Apd_Aps               IN     Ap_Document.Apd_Aps%TYPE,
        p_Apd_Tmp_To_Del_File   IN     Ap_Document.Apd_Tmp_To_Del_File%TYPE DEFAULT NULL,
        p_Apd_Src               IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Merge_Document (
        p_Apd_Id                IN     Ap_Document.Apd_Id%TYPE,
        p_Apd_Ap                IN     Ap_Document.Apd_Ap%TYPE,
        p_Apd_Ndt               IN     Ap_Document.Apd_Ndt%TYPE,
        p_Apd_Doc               IN     Ap_Document.Apd_Doc%TYPE,
        p_Apd_Vf                IN     Ap_Document.Apd_Vf%TYPE,
        p_Apd_App               IN     Ap_Document.Apd_App%TYPE,
        p_New_Id                   OUT Ap_Document.Apd_Id%TYPE,
        p_Com_Wu                IN     NUMBER,
        p_Apd_Dh                IN     Ap_Document.Apd_Dh%TYPE,
        p_Apd_Aps               IN     Ap_Document.Apd_Aps%TYPE,
        p_Apd_Tmp_To_Del_File   IN     Ap_Document.Apd_Tmp_To_Del_File%TYPE DEFAULT NULL,
        p_Apd_Src               IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Delete_Document (p_Id Ap_Document.Apd_Id%TYPE);

    FUNCTION Get_Apd_Ap (p_Apd_Id IN Ap_Document.Apd_Id%TYPE)
        RETURN Ap_Document.Apd_Ap%TYPE;

    FUNCTION Get_Doc_Owner_Sc (p_Apd_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Parse_Document_Attr (
        p_Ap_Document_Attrs   IN XMLTYPE,
        p_Has_Root_Tag           BOOLEAN DEFAULT TRUE)
        RETURN t_Ap_Document_Attrs;

    PROCEDURE Save_Attr (p_Apd_Id            IN NUMBER,
                         p_Ap_Id             IN NUMBER,
                         p_Apda_Nda          IN NUMBER,
                         p_Apda_Val_Int      IN NUMBER DEFAULT NULL,
                         p_Apda_Val_Dt       IN DATE DEFAULT NULL,
                         p_Apda_Val_String   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Save_Document_Attr (
        p_Apda_Id           IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Int      IN     Ap_Document_Attr.Apda_Val_Int%TYPE DEFAULT NULL,
        p_Apda_Val_Dt       IN     Ap_Document_Attr.Apda_Val_Dt%TYPE DEFAULT NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_Apda_Val_Sum      IN     Ap_Document_Attr.Apda_Val_Sum%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE);

    PROCEDURE Save_Not_Empty_Document_Attr_Str (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE);

    PROCEDURE Save_Not_Empty_Document_Attr_Id (
        p_Apda_Ap       IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd      IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda      IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Id   IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_New_Id           OUT Ap_Document_Attr.Apda_Val_Id%TYPE);

    PROCEDURE Save_Not_Empty_Document_Attr_Id_Str (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE);

    PROCEDURE Save_Not_Empty_Document_Attr_Dt (
        p_Apda_Ap       IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd      IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda      IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Dt   IN     Ap_Document_Attr.Apda_Val_Dt%TYPE DEFAULT NULL,
        p_New_Id           OUT Ap_Document_Attr.Apda_Val_Id%TYPE);

    PROCEDURE Save_Exists_Doc_Attr (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE);


    PROCEDURE Copy_Document_Attr (
        p_Apda_Id_From   IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Id_To     IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Nda_To    IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_New_Id            OUT Ap_Document_Attr.Apda_Id%TYPE);

    PROCEDURE Delete_Document_Attr (p_Id Ap_Document_Attr.Apda_Val_Id%TYPE);

    FUNCTION Get_Attr_Val_Dt (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                              p_Nda_Class   IN VARCHAR2)
        RETURN DATE;

    FUNCTION Get_Person_Attr_Val_Dt (p_App_Id      IN NUMBER,
                                     p_Nda_Class   IN VARCHAR2)
        RETURN DATE;

    FUNCTION Get_Attr_Val_String (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_String (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Id      NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_Id (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                              p_Nda_Id      NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Attrp_Val_String (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                                   p_Pt_Id       NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Document_Id (p_Apd_Ap     IN Ap_Document_Attr.Apda_Ap%TYPE,
                              p_Apda_Nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Document_Attr_Id (
        p_Apda_Ap    IN Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Person_Attr_Val_Str (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Attr_Val_Str (p_App_Id      IN NUMBER,
                                      p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Person_Attr_Val_Id (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Person_Attr_Val_Dt (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Person_Doc_Attr_Val_Dt (
        p_App_Id      IN NUMBER,
        p_Nda_Class   IN VARCHAR2,
        p_Ndt_Ndc     IN NUMBER DEFAULT NULL)
        RETURN DATE;

    FUNCTION Get_Ap_Attr_Val_Str (p_Ap_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Val_Id (p_Ap_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Clear_Document_Attrs (p_Apd_Id Ap_Document.Apd_Id%TYPE);

    FUNCTION Parse_Declaration (p_Declaration_Dto IN CLOB)
        RETURN r_Declaration_Dto;

    PROCEDURE Save_Declaration (
        p_Apr_Id          IN     Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Ap          IN     Ap_Declaration.Apr_Ap%TYPE,
        p_Apr_Fn          IN     Ap_Declaration.Apr_Fn%TYPE,
        p_Apr_Mn          IN     Ap_Declaration.Apr_Mn%TYPE,
        p_Apr_Ln          IN     Ap_Declaration.Apr_Ln%TYPE,
        p_Apr_Residence   IN     Ap_Declaration.Apr_Residence%TYPE,
        p_Com_Org         IN     Ap_Declaration.Com_Org%TYPE,
        p_Apr_Vf          IN     Ap_Declaration.Apr_Vf%TYPE,
        p_Apr_Start_Dt    IN     Ap_Declaration.Apr_Start_Dt%TYPE,
        p_Apr_Stop_Dt     IN     Ap_Declaration.Apr_Stop_Dt%TYPE,
        p_New_Id             OUT Ap_Declaration.Apr_Residence%TYPE);

    FUNCTION Declaration_Exists (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Declaration_Period_Exists (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Save_Apr_Person (
        p_Aprp_Id      IN     Apr_Person.Aprp_Id%TYPE,
        p_Aprp_Apr     IN     Apr_Person.Aprp_Apr%TYPE,
        p_Aprp_Fn      IN     Apr_Person.Aprp_Fn%TYPE,
        p_Aprp_Mn      IN     Apr_Person.Aprp_Mn%TYPE,
        p_Aprp_Ln      IN     Apr_Person.Aprp_Ln%TYPE,
        p_Aprp_Tp      IN     Apr_Person.Aprp_Tp%TYPE,
        p_Aprp_Inn     IN     Apr_Person.Aprp_Inn%TYPE,
        p_Aprp_Notes   IN     Apr_Person.Aprp_Notes%TYPE,
        p_Aprp_App     IN     Apr_Person.Aprp_App%TYPE,
        p_New_Id          OUT Apr_Person.Aprp_Id%TYPE);

    PROCEDURE Delete_Apr_Person (p_Aprp_Id IN Apr_Person.Aprp_Id%TYPE);

    PROCEDURE Save_Apr_Income (
        p_Apri_Id            IN     Apr_Income.Apri_Id%TYPE,
        p_Apri_Apr           IN     Apr_Income.Apri_Apr%TYPE,
        p_Apri_Ln_Initials   IN     Apr_Income.Apri_Ln_Initials%TYPE,
        p_Apri_Tp            IN     Apr_Income.Apri_Tp%TYPE,
        p_Apri_Sum           IN     Apr_Income.Apri_Sum%TYPE,
        p_Apri_Source        IN     Apr_Income.Apri_Source%TYPE,
        p_Apri_Aprp          IN     Apr_Income.Apri_Aprp%TYPE,
        p_Apri_Start_Dt      IN     Apr_Income.Apri_Start_Dt%TYPE,
        p_Apri_Stop_Dt       IN     Apr_Income.Apri_Stop_Dt%TYPE,
        p_New_Id                OUT Apr_Income.Apri_Id%TYPE);

    PROCEDURE Delete_Apr_Income (p_Apri_Id IN Apr_Income.Apri_Id%TYPE);

    PROCEDURE Save_Apr_Land_Plot (
        p_Aprt_Id            IN     Apr_Land_Plot.Aprt_Id%TYPE,
        p_Aprt_Apr           IN     Apr_Land_Plot.Aprt_Apr%TYPE,
        p_Aprt_Ln_Initials   IN     Apr_Land_Plot.Aprt_Ln_Initials%TYPE,
        p_Aprt_Area          IN     Apr_Land_Plot.Aprt_Area%TYPE,
        p_Aprt_Ownership     IN     Apr_Land_Plot.Aprt_Ownership%TYPE,
        p_Aprt_Purpose       IN     Apr_Land_Plot.Aprt_Purpose%TYPE,
        p_Aprt_Aprp          IN     Apr_Land_Plot.Aprt_Aprp%TYPE,
        p_New_Id                OUT Apr_Land_Plot.Aprt_Id%TYPE);

    PROCEDURE Delete_Apr_Land_Plot (Aprt_Id IN Apr_Land_Plot.Aprt_Id%TYPE);

    PROCEDURE Save_Apr_Living_Quarters (
        p_Aprl_Id            IN     Apr_Living_Quarters.Aprl_Id%TYPE,
        p_Aprl_Apr           IN     Apr_Living_Quarters.Aprl_Apr%TYPE,
        p_Aprl_Ln_Initials   IN     Apr_Living_Quarters.Aprl_Ln_Initials%TYPE,
        p_Aprl_Area          IN     Apr_Living_Quarters.Aprl_Area%TYPE,
        p_Aprl_Qnt           IN     Apr_Living_Quarters.Aprl_Qnt%TYPE,
        p_Aprl_Address       IN     Apr_Living_Quarters.Aprl_Address%TYPE,
        p_Aprl_Aprp          IN     Apr_Living_Quarters.Aprl_Aprp%TYPE,
        p_Aprl_Tp            IN     Apr_Living_Quarters.Aprl_Tp%TYPE DEFAULT NULL,
        p_Aprl_Ch            IN     Apr_Living_Quarters.Aprl_Ch%TYPE DEFAULT NULL,
        p_New_Id                OUT Apr_Living_Quarters.Aprl_Id%TYPE);

    PROCEDURE Delete_Apr_Living_Quarters (
        p_Aprl_Id   IN Apr_Living_Quarters.Aprl_Id%TYPE);

    PROCEDURE Save_Apr_Other_Income (
        p_Apro_Id             IN     Apr_Other_Income.Apro_Id%TYPE,
        p_Apro_Apr            IN     Apr_Other_Income.Apro_Apr%TYPE,
        p_Apro_Tp             IN     Apr_Other_Income.Apro_Tp%TYPE,
        p_Apro_Income_Info    IN     Apr_Other_Income.Apro_Income_Info%TYPE,
        p_Apro_Income_Usage   IN     Apr_Other_Income.Apro_Income_Usage%TYPE,
        p_Apro_Aprp           IN     Apr_Other_Income.Apro_Aprp%TYPE,
        p_New_Id                 OUT Apr_Other_Income.Apro_Id%TYPE);

    PROCEDURE Delete_Apr_Other_Income (
        p_Apro_Id   IN Apr_Other_Income.Apro_Id%TYPE);

    PROCEDURE Save_Apr_Spending (
        p_Aprs_Id            IN     Apr_Spending.Aprs_Id%TYPE,
        p_Aprs_Apr           IN     Apr_Spending.Aprs_Apr%TYPE,
        p_Aprs_Ln_Initials   IN     Apr_Spending.Aprs_Ln_Initials%TYPE,
        p_Aprs_Tp            IN     Apr_Spending.Aprs_Tp%TYPE,
        p_Aprs_Cost_Type     IN     Apr_Spending.Aprs_Cost_Type%TYPE,
        p_Aprs_Cost          IN     Apr_Spending.Aprs_Cost%TYPE,
        p_Aprs_Dt            IN     Apr_Spending.Aprs_Dt%TYPE,
        p_Aprs_Aprp          IN     Apr_Spending.Aprs_Aprp%TYPE,
        p_New_Id                OUT Apr_Spending.Aprs_Id%TYPE);

    PROCEDURE Delete_Apr_Spending (p_Aprs_Id IN Apr_Spending.Aprs_Id%TYPE);

    PROCEDURE Save_Apr_Vehicle (
        p_Aprv_Id                IN     Apr_Vehicle.Aprv_Id%TYPE,
        p_Aprv_Apr               IN     Apr_Vehicle.Aprv_Apr%TYPE,
        p_Aprv_Ln_Initials       IN     Apr_Vehicle.Aprv_Ln_Initials%TYPE,
        p_Aprv_Car_Brand         IN     Apr_Vehicle.Aprv_Car_Brand%TYPE,
        p_Aprv_License_Plate     IN     Apr_Vehicle.Aprv_License_Plate%TYPE,
        p_Aprv_Production_Year   IN     Apr_Vehicle.Aprv_Production_Year%TYPE,
        p_Aprv_Is_Social_Car     IN     Apr_Vehicle.Aprv_Is_Social_Car%TYPE,
        p_Aprv_Aprp              IN     Apr_Vehicle.Aprv_Aprp%TYPE,
        p_New_Id                    OUT Apr_Vehicle.Aprv_Id%TYPE);

    PROCEDURE Delete_Apr_Vehicle (p_Aprv_Id IN Apr_Vehicle.Aprv_Id%TYPE);

    PROCEDURE Save_Apr_Alimony (
        p_Apra_Id                IN     Apr_Alimony.Apra_Id%TYPE,
        p_Apra_Apr               IN     Apr_Alimony.Apra_Apr%TYPE,
        p_Apra_Payer             IN     Apr_Alimony.Apra_Payer%TYPE,
        p_Apra_Sum               IN     Apr_Alimony.Apra_Sum%TYPE,
        p_Apra_Is_Have_Arrears   IN     Apr_Alimony.Apra_Is_Have_Arrears%TYPE,
        p_Apra_Aprp              IN     Apr_Alimony.Apra_Aprp%TYPE,
        p_New_Id                    OUT Apr_Alimony.Apra_Id%TYPE);

    PROCEDURE Delete_Apr_Alimony (p_Apra_Id IN Apr_Alimony.Apra_Id%TYPE);

    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL);

    -- створення дублікату звернення
    PROCEDURE Duplicate_Appeal (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER);

    -- створення дублікату звернення для ANF з Z + ANF
    PROCEDURE Duplicate_Appeal_ANF (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER);
END Api$appeal;
/


GRANT EXECUTE ON USS_VISIT.API$APPEAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.API$APPEAL TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 5:59:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$APPEAL
IS
    PROCEDURE Check_Appeal_Tp (p_Ap_Tp              IN Appeal.Ap_Tp%TYPE,
                               p_Raise_User_Error   IN NUMBER DEFAULT 1)
    IS
        l_Ap_Tp_Code   VARCHAR2 (10);
    BEGIN
        SELECT t.Dic_Code
          INTO l_Ap_Tp_Code
          FROM Uss_Ndi.v_Ddn_Ap_Tp t
         WHERE t.Dic_Value = p_Ap_Tp;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF p_Raise_User_Error = 1
            THEN
                Raise_Application_Error (
                    -20000,
                       'Розробник! Вказанний код типу звернення ['
                    || p_Ap_Tp
                    || '] не знайдено в довіднику');
            ELSE
                RAISE;
            END IF;
    END;

    FUNCTION Check_Appeal_Tp (p_Ap_Tp       IN Appeal.Ap_Tp%TYPE,
                              p_Def_Ap_Ap   IN Appeal.Ap_Tp%TYPE)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_Ap_Tp IS NULL
        THEN
            RETURN p_Def_Ap_Ap;
        END IF;

        Check_Appeal_Tp (p_Ap_Tp);
        RETURN p_Ap_Tp;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF p_Def_Ap_Ap IS NOT NULL
            THEN
                RETURN p_Def_Ap_Ap;
            ELSE
                RAISE;
            END IF;
    END;


    FUNCTION Gen_Appeal_Num (p_Ap_Id   IN Appeal.Ap_Id%TYPE,
                             p_Ap_Tp   IN Appeal.Ap_Tp%TYPE)
        RETURN VARCHAR2
    IS
        l_Ap_Num       Appeal.Ap_Num%TYPE;
        l_Ap_Tp_Code   VARCHAR2 (10);
        l_Otg_Num      VARCHAR2 (7) := '0000000'; --пока не известно как высчитывать
        l_Distr        VARCHAR2 (2) := '00'; --пока не известно как высчитывать
    BEGIN
        Check_Appeal_Tp (p_Ap_Tp);

        SELECT t.Dic_Code
          INTO l_Ap_Tp_Code
          FROM Uss_Ndi.v_Ddn_Ap_Tp t
         WHERE t.Dic_Value = p_Ap_Tp;

        l_Ap_Num :=
               l_Ap_Tp_Code
            || l_Otg_Num
            || l_Distr
            || TO_CHAR (SYSDATE, 'YY')
            || LPAD (p_Ap_Id, 10, '0');
        RETURN l_Ap_Num;
    END;

    PROCEDURE Set_Ap_Sub_Tp (p_Ap_Id IN Appeal.Ap_Id%TYPE)
    IS
        l_Ap_Sub_Tp   VARCHAR2 (10);
    BEGIN
        l_Ap_Sub_Tp := Define_Ap_Sub_Tp (p_Ap_Id);

        UPDATE Appeal a
           SET a.Ap_Sub_Tp = l_Ap_Sub_Tp
         WHERE a.Ap_Id = p_Ap_Id;
    END;

    FUNCTION Define_Ap_Sub_Tp (p_Ap_Id IN Appeal.Ap_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Ap_Sub_Tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (c.Nasc_Ap_Sub_Tp)
          INTO l_Ap_Sub_Tp
          FROM Appeal  a
               JOIN Uss_Ndi.v_Ndi_Ap_Sub_Config c ON a.Ap_Tp = c.Nasc_Ap_Tp
               JOIN Ap_Document d
                   ON     a.Ap_Id = d.Apd_Ap
                      AND d.Apd_Ndt = c.Nasc_Ndt
                      AND d.History_Status = 'A'
               LEFT JOIN Ap_Document_Attr t
                   ON     d.Apd_Id = t.Apda_Apd
                      AND c.Nasc_Nda = t.Apda_Nda
                      AND t.History_Status = 'A'
         WHERE     a.Ap_Id = p_Ap_Id
               AND (   c.Nasc_Nda IS NULL
                    OR t.Apda_Val_String = c.Nasc_Val_String);

        RETURN l_Ap_Sub_Tp;
    END;

    --
    --Перевірка корректності створення звернення:
    --1 - якщо не має жодного F у вказанних атрибутах
    --0 - в іншому випадку
    FUNCTION Is_Appeal_Maked_Correct (p_Ap_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Res
          FROM appeal ap
         WHERE ap.ap_id = p_Ap_Id AND ap.ap_tp = c_Ap_Tp_SS;

        IF l_Res = 0
        THEN
            RETURN 1;
        END IF;

        SELECT SIGN (COUNT (1))
          INTO l_Res
          FROM Ap_Document  Apd
               JOIN Ap_Document_Attr Apda ON Apd.Apd_Id = Apda.Apda_Apd
         WHERE     Apda.Apda_Nda IN (8415,
                                     8416,
                                     8417,
                                     8418,
                                     8419)
               AND Apd.Apd_Ap = p_Ap_Id
               AND Apda.Apda_Val_String = 'F';

        RETURN CASE WHEN l_Res = 0 THEN 1 ELSE 0 END;
    END;

    --
    -- Підготовка до відправки в ЕСР.
    -- Це потрібно, щоб обійти вимоги по відправки в ЕСР усього
    --
    FUNCTION Is_Prepare_Appeal_Copy2ESR (p_Ap_id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ap_Tp   VARCHAR2 (10);
    --l_Ap_Sub_Tp            VARCHAR2(10);
    --l_Ap_Src               VARCHAR2(10);
    BEGIN
        --l_Ap_Src := Api$appeal.Get_Ap_Src(p_Ap_id);
        l_Ap_Tp := Api$appeal.Get_Ap_Tp (p_Ap_id);

        --l_Ap_Sub_Tp := Api$appeal.Get_Ap_Sub_Tp(p_Ap_id);
        IF     l_Ap_Tp IN ('SS')
           AND API$APPEAL.Is_Appeal_Maked_Correct (p_Ap_id) = 0
        THEN
            Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_id,
                                                    p_St_Old   => 'VW');
            API$Visit_Action.Save_Sc_Contact (p_Ap_id);
            RETURN 1;
        END IF;

        RETURN 0;
    END;


    PROCEDURE Save_Ap_Correct_Status (
        p_Ap_Id               IN Appeal.Ap_Id%TYPE,
        p_Ap_Correct_status   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ap                  Appeal%ROWTYPE;
        l_Vf_St               VARCHAR2 (10);
        l_Apd_Id              NUMBER;
        l_Apda_Nda            NUMBER;
        --l_Apd_App  NUMBER;
        --l_New_Id   NUMBER;
        l_Ap_Correct_status   VARCHAR2 (10);
        l_Docs_List           VARCHAR2 (4000);
    BEGIN
        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE ap_id = p_Ap_Id;

        IF l_Ap.ap_tp NOT IN ('SS')
        THEN
            RETURN;
        END IF;

        BEGIN
            SELECT Vf_St
              INTO l_Vf_St
              FROM Verification
             WHERE vf_id = l_Ap.Ap_Vf;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_Vf_St := API$VERIFICATION.c_Vf_St_Reg;
        END;

        BEGIN
            SELECT Apd_Id, Apda_Nda
              INTO l_Apd_Id, l_Apda_Nda
              FROM (  SELECT Apd_Id, Apda_Nda
                        FROM Ap_Document Apd
                             JOIN Ap_Document_Attr Apda
                                 ON Apd.Apd_Id = Apda.Apda_Apd
                       WHERE     Apd.Apd_Ap = p_Ap_Id
                             AND Apda.Apda_Nda IN (8415,
                                                   8416,
                                                   8417,
                                                   8419)
                             AND Apd.History_Status = 'A'
                             AND Apda.History_Status = 'A'
                    ORDER BY Apd_Id)
             WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                BEGIN
                    SELECT Apd_Id, Nda_Id
                      INTO l_Apd_Id, l_Apda_Nda
                      FROM (  SELECT Apd_Id, Nda_id
                                FROM Ap_Document Apd
                                     JOIN USS_NDI.v_Ndi_Document_Attr Nda
                                         ON Apd.Apd_Ndt = Nda.nda_ndt
                               WHERE     Apd.Apd_Ap = p_Ap_Id
                                     AND Nda.nda_id IN (8415,
                                                        8416,
                                                        8417,
                                                        8419)
                                     AND Apd.History_Status = 'A'
                            ORDER BY Apd_Id)
                     WHERE ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        /*
                        BEGIN
                          SELECT App_Id
                          INTO l_Apd_App
                          FROM(SELECT App_Id
                               FROM Ap_Person
                               WHERE App_Ap = p_Ap_Id
                               AND History_Status='A'
                               ORDER BY CASE WHEN App_Tp = 'Z' THEN 1 ELSE 2 END)
                          WHERE rownum=1;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN NULL;
                        END;

                      Save_Document(p_Apd_Id => -1, p_Apd_Ap => p_Ap_Id, p_Apd_Ndt => 801 ,p_Apd_Doc => null, p_Apd_Vf => null, p_Apd_App => l_Apd_App, p_New_Id =>  l_New_Id, p_Com_Wu => null, p_Apd_Dh => null, p_Apd_Aps => null);
                      l_Apd_Id := l_New_Id;
                      l_Apda_Nda := 8415;
                      */
                        SELECT LISTAGG ('"' || dt.ndt_name || '"', ', ')
                          INTO l_Docs_List
                          FROM uss_ndi.v_ndi_document_type dt
                         WHERE ndt_id IN (801,
                                          802,
                                          835,
                                          1015);

                        Raise_Application_Error (
                            -20000,
                               'До звернення необхідно додати хоча б один з наступних ініціативних документів: '
                            || l_Docs_List);
                END;
        END;


        IF p_Ap_Correct_status IS NOT NULL
        THEN
            l_Ap_Correct_status :=
                Get_Ap_Attr_Val_Str (p_Ap_Id    => p_Ap_Id,
                                     p_Nda_Id   => l_Apda_Nda);

            --Використовеємо правило: некоректний один раз - некоректний завжди
            IF NVL (l_Ap_Correct_status, 'T') != 'F'
            THEN
                Save_Attr (p_Apd_Id            => l_Apd_Id,
                           p_Ap_Id             => p_Ap_Id,
                           p_Apda_Nda          => l_Apda_Nda,
                           p_Apda_Val_String   => p_Ap_Correct_status);
            END IF;
        ELSIF l_Vf_St <> Api$verification.c_Vf_St_Ok
        THEN
            Save_Attr (p_Apd_Id            => l_Apd_Id,
                       p_Ap_Id             => p_Ap_Id,
                       p_Apda_Nda          => l_Apda_Nda,
                       p_Apda_Val_String   => 'F');
        ELSIF NOT API$VERIFICATION_COND.Is_Apd_Exists (p_Ap_Id, 801)
        THEN
            Save_Attr (p_Apd_Id            => l_Apd_Id,
                       p_Ap_Id             => p_Ap_Id,
                       p_Apda_Nda          => l_Apda_Nda,
                       p_Apda_Val_String   => 'F');
        ELSE
            Save_Attr (p_Apd_Id            => l_Apd_Id,
                       p_Ap_Id             => p_Ap_Id,
                       p_Apda_Nda          => l_Apda_Nda,
                       p_Apda_Val_String   => 'T');
        END IF;
    END;

    PROCEDURE Save_Appeal (
        p_Ap_Id               IN     Appeal.Ap_Id%TYPE,
        p_Ap_Num              IN     Appeal.Ap_Num%TYPE,
        p_Ap_Reg_Dt           IN     Appeal.Ap_Reg_Dt%TYPE,
        p_Ap_Create_Dt        IN     Appeal.Ap_Create_Dt%TYPE,
        p_Ap_Src              IN     Appeal.Ap_Src%TYPE,
        p_Ap_St               IN OUT Appeal.Ap_St%TYPE,
        p_Com_Org             IN     Appeal.Com_Org%TYPE,
        p_Ap_Is_Second        IN     Appeal.Ap_Is_Second%TYPE,
        p_Ap_Vf               IN     Appeal.Ap_Vf%TYPE,
        p_Com_Wu              IN     Appeal.Com_Wu%TYPE,
        p_Ap_Tp               IN     Appeal.Ap_Tp%TYPE,
        p_New_Id                 OUT Appeal.Ap_Id%TYPE,
        p_Ap_Ext_Ident        IN     Appeal.Ap_Ext_Ident%TYPE DEFAULT NULL,
        p_Ap_Doc              IN     Appeal.Ap_Doc%TYPE DEFAULT NULL,
        p_Ap_Is_Ext_Process   IN     Appeal.Ap_Is_Ext_Process%TYPE DEFAULT NULL,
        p_Obi_Ts              IN     Appeal.Obi_Ts%TYPE DEFAULT NULL,
        p_Ap_Ext_Ident2       IN     Appeal.Ap_Ext_Ident2%TYPE DEFAULT NULL,
        p_Ap_Dest_Org         IN     Appeal.Ap_Dest_Org%TYPE DEFAULT NULL,
        p_Ap_Cu               IN     Appeal.Ap_Cu%TYPE DEFAULT NULL,
        p_Ap_Sub_Tp           IN     Appeal.Ap_Sub_Tp%TYPE DEFAULT NULL,
        p_Ap_Ap_Main          IN     Appeal.Ap_Ap_Main%TYPE DEFAULT NULL)
    IS
        l_Ap_Num      Appeal.Ap_Num%TYPE;
        l_Cnt         NUMBER;
        l_obi_ts      appeal.obi_ts%TYPE;
        l_Ap_Reg_Dt   Appeal.Ap_Reg_Dt%TYPE;
    BEGIN
        l_Ap_Reg_Dt :=
            TRUNC (NVL (p_Ap_Reg_Dt, NVL (p_Ap_Create_Dt, SYSDATE))); -- 29/10/2024 serhii: #109232-15

        IF NVL (p_Ap_Id, -1) < 0
        THEN
            p_New_Id := Sq_Id_Appeal.NEXTVAL;

            IF p_Ap_Num IS NULL
            THEN
                l_Ap_Num :=
                    Gen_Appeal_Num (p_Ap_Id => p_New_Id, p_Ap_Tp => p_Ap_Tp);
            ELSE
                l_Ap_Num := p_Ap_Num;
            END IF;

            IF     p_Ap_Tp IN ('G')
               AND p_Ap_Dest_Org IS NOT NULL
               AND p_Ap_Dest_Org != p_Com_Org
            THEN
                SELECT COUNT (1)
                  INTO l_Cnt
                  FROM Uss_Ndi.v_Ndi_Allowed_Dest_Org Nado
                 WHERE     Nado.Nado_Src_Org = p_Com_Org
                       AND Nado.Nado_Dest_Org = p_Ap_Dest_Org
                       AND Nado.Nado_Tp = '01';

                IF l_Cnt IS NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Не дозволена організація призначення!');
                END IF;
            END IF;

            INSERT INTO Appeal (Ap_Id,
                                Ap_Num,
                                Ap_Reg_Dt,
                                Ap_Create_Dt,
                                Ap_Src,
                                Ap_St,
                                Com_Org,
                                Ap_Is_Second,
                                Ap_Vf,
                                Com_Wu,
                                Ap_Tp,
                                Ap_Ext_Ident,
                                Ap_Doc,
                                Ap_Is_Ext_Process,
                                Ap_Ext_Ident2,
                                Ap_Dest_Org,
                                Ap_Cu,
                                Ap_Sub_Tp,
                                Ap_Ap_Main)
                 VALUES (p_New_Id,
                         l_Ap_Num,
                         l_Ap_Reg_Dt,
                         NVL (p_Ap_Create_Dt, SYSDATE),
                         p_Ap_Src,
                         NVL (p_Ap_St, c_Ap_St_Reg_In_Work),
                         NVL (p_Com_Org, Tools.Getcurrorg),
                         p_Ap_Is_Second,
                         p_Ap_Vf,
                         p_Com_Wu,
                         p_Ap_Tp,
                         p_Ap_Ext_Ident,
                         p_Ap_Doc,
                         NVL (p_Ap_Is_Ext_Process, 'F'),
                         p_Ap_Ext_Ident2,
                         NVL (p_Ap_Dest_Org, p_Com_Org),
                         p_Ap_Cu,
                         p_Ap_Sub_Tp,
                         p_Ap_Ap_Main)
              RETURNING Ap_St
                   INTO p_Ap_St;
        ELSE
            p_New_Id := p_Ap_Id;

            IF p_Ap_Src = c_Src_Uss
            THEN
                   UPDATE Appeal
                      SET Ap_Reg_Dt = l_Ap_Reg_Dt,
                          Com_Org = p_Com_Org,
                          Ap_Is_Second = p_Ap_Is_Second,
                          Ap_Vf = p_Ap_Vf,
                          Com_Wu = p_Com_Wu,
                          Ap_St = NVL (p_Ap_St, Ap_St),
                          Ap_Is_Ext_Process =
                              NVL (p_Ap_Is_Ext_Process, Ap_Is_Ext_Process),
                          Ap_Dest_Org = NVL (p_Ap_Dest_Org, Ap_Dest_Org),
                          Ap_Ap_Main = NVL (p_Ap_Ap_Main, Ap_Ap_Main)
                    WHERE Ap_Id = p_Ap_Id AND Obi_Ts = p_Obi_Ts --Для джерела ЄІССС пересвідчуємось що не було паралельного редагування
                RETURNING Ap_St
                     INTO p_Ap_St;

                IF SQL%ROWCOUNT = 0
                THEN
                    SELECT obi_ts
                      INTO l_obi_ts
                      FROM appeal
                     WHERE ap_id = p_ap_id;

                    Ikis_sys.Ikis_Procedure_Log.LOG (
                        p_src              => UPPER ('USS_VISIT.API$APPEAL.Save_Appeal'),
                        p_obj_tp           => 'APPEAL',
                        p_obj_id           => p_Ap_Id,
                        p_regular_params   =>
                               'p_Ap_Id='
                            || p_Ap_Id
                            || ', p_from_interdace_Obi_Ts='
                            || p_Obi_Ts
                            || ', p_curr_in_record_obi_ts='
                            || l_obi_ts,
                        p_lob_param        => NULL);
                    RAISE Ex_Opt_Block_Viol;
                END IF;
            ELSE
                   --Для всіх інших джерел не контролюємо паралельне редагування
                   UPDATE Appeal
                      SET Ap_Reg_Dt = l_Ap_Reg_Dt,
                          Com_Org = p_Com_Org,
                          Ap_Is_Second = p_Ap_Is_Second,
                          Ap_Vf = p_Ap_Vf,
                          Com_Wu = p_Com_Wu,
                          Ap_St = NVL (p_Ap_St, Ap_St),
                          Ap_Is_Ext_Process =
                              NVL (p_Ap_Is_Ext_Process, Ap_Is_Ext_Process),
                          Ap_Ap_Main = NVL (p_Ap_Ap_Main, Ap_Ap_Main)
                    WHERE Ap_Id = p_Ap_Id
                RETURNING Ap_St
                     INTO p_Ap_St;
            END IF;
        END IF;
    END;

    FUNCTION Get_Ap_Tp (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Tp%TYPE
    IS
        l_Ap_Tp   Appeal.Ap_Tp%TYPE;
    BEGIN
        SELECT a.Ap_Tp
          INTO l_Ap_Tp
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Ap_Tp;
    END;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Ap = p_Ap_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Sub_Tp (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Sub_Tp%TYPE
    IS
        l_Ap_Sub_Tp   Appeal.Ap_Sub_Tp%TYPE;
    BEGIN
        SELECT a.Ap_Sub_Tp
          INTO l_Ap_Sub_Tp
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Ap_Sub_Tp;
    END;

    FUNCTION Get_Ap_Src (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Src%TYPE
    IS
        l_Ap_Src   Appeal.Ap_Src%TYPE;
    BEGIN
        SELECT a.Ap_Src
          INTO l_Ap_Src
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Ap_Src;
    END;

    FUNCTION Get_Ap_Reg_Dt (p_Ap_Id IN NUMBER)
        RETURN DATE
    IS
        l_Ap_Reg_Dt   DATE;
    BEGIN
        SELECT Ap_Reg_Dt
          INTO l_Ap_Reg_Dt
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        RETURN l_Ap_Reg_Dt;
    END;

    FUNCTION Get_Ap_Ap_Main (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Ap_Main%TYPE
    IS
        l_Ap_Ap_Main   Appeal.Ap_Ap_Main%TYPE;
    BEGIN
        SELECT a.Ap_Ap_Main
          INTO l_Ap_Ap_Main
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Ap_Ap_Main;
    END;

    FUNCTION Get_Ap_Is_Ext_Process (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Ap_Is_Ext_Process   Appeal.Ap_Is_Ext_Process%TYPE;
    BEGIN
        SELECT a.Ap_Is_Ext_Process
          INTO l_Ap_Is_Ext_Process
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN NVL (l_Ap_Is_Ext_Process, 'F') = 'T';
    END;

    PROCEDURE Set_Ap_Tp (p_Ap_Id IN NUMBER, p_Ap_Tp IN Appeal.Ap_Tp%TYPE)
    IS
    BEGIN
        UPDATE Appeal a
           SET a.Ap_Tp = p_Ap_Tp
         WHERE a.Ap_Id = p_Ap_Id;
    END;

    FUNCTION Get_Ap_Ext_Ident2 (p_Ap_Id IN NUMBER)
        RETURN Appeal.Ap_Ext_Ident2%TYPE
    IS
        l_Ap_Ext_Ident2   Appeal.Ap_Ext_Ident2%TYPE;
    BEGIN
        SELECT a.Ap_Ext_Ident2
          INTO l_Ap_Ext_Ident2
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Ap_Ext_Ident2;
    END;

    PROCEDURE Set_Ap_Ext_Ident2 (
        p_Ap_Id           IN NUMBER,
        p_Ap_Ext_Ident2   IN Appeal.Ap_Ext_Ident2%TYPE)
    IS
    BEGIN
        UPDATE Appeal a
           SET a.Ap_Ext_Ident2 = p_Ap_Ext_Ident2
         WHERE a.Ap_Id = p_Ap_Id;
    END;

    FUNCTION Parse_Services (p_Ap_Services IN CLOB)
        RETURN t_Ap_Services
    IS
        l_Ap_Services   t_Ap_Services;
    BEGIN
        IF p_Ap_Services IS NULL OR DBMS_LOB.getlength (p_Ap_Services) = 0
        THEN
            RETURN NULL;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Ap_Services',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_Ap_Services
            USING p_Ap_Services;

        RETURN l_Ap_Services;
    END;

    -- info:  Збереження послуг
    -- params:
    -- note:
    PROCEDURE Save_Service (p_Aps_Id    IN     Ap_Service.Aps_Id%TYPE,
                            p_Aps_Nst   IN     Ap_Service.Aps_Nst%TYPE,
                            p_Aps_Ap    IN     Ap_Service.Aps_Ap%TYPE,
                            p_Aps_St    IN     Ap_Service.Aps_St%TYPE,
                            p_New_Id       OUT Ap_Service.Aps_Id%TYPE)
    IS
    BEGIN
        IF p_Aps_Id IS NULL OR p_Aps_Id < 0
        THEN
            INSERT INTO Ap_Service (Aps_Nst,
                                    Aps_Ap,
                                    Aps_St,
                                    History_Status)
                 VALUES (p_Aps_Nst,
                         p_Aps_Ap,
                         p_Aps_St,
                         'A')
              RETURNING Aps_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aps_Id;

            UPDATE Ap_Service
               SET Aps_Nst = p_Aps_Nst, --Aps_Ap  = p_Aps_Ap,
                                        Aps_St = p_Aps_St
             WHERE Aps_Id = p_Aps_Id;
        END IF;
    END;

    PROCEDURE Delete_Service (p_Id Ap_Service.Aps_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Service s
           SET s.History_Status = 'H'
         WHERE Aps_Id = p_Id;
    END;

    PROCEDURE Delete_Service_Payments (p_Aps_Id IN Ap_Service.Aps_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Payment p
           SET p.History_Status = 'H'
         WHERE p.Apm_Aps = p_Aps_Id;
    END;

    FUNCTION Service_Exists (p_Aps_Ap    IN Ap_Service.Aps_Ap%TYPE,
                             p_Aps_Nst   IN Ap_Service.Aps_Nst%TYPE)
        RETURN BOOLEAN
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM Ap_Service s
         WHERE     s.Aps_Ap = p_Aps_Ap
               AND s.Aps_Nst = p_Aps_Nst
               AND s.History_Status = 'A';

        RETURN l_Result = 1;
    END;

    FUNCTION Document_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM Ap_Document
         WHERE     Apd_Ap = p_Apd_Ap
               AND Apd_Ndt = p_Apd_Ndt
               AND History_Status = 'A';

        RETURN l_Result = 1;
    END;

    FUNCTION Parse_Persons (p_Ap_Persons IN CLOB)
        RETURN t_Ap_Persons
    IS
        l_Ap_Persons   t_Ap_Persons;
    BEGIN
        IF p_Ap_Persons IS NULL OR DBMS_LOB.getlength (p_Ap_Persons) = 0
        THEN
            RETURN NULL;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Ap_Persons',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_Ap_Persons
            USING p_Ap_Persons;

        RETURN l_Ap_Persons;
    END;

    --#APP_NUM
    FUNCTION Get_Next_App_Num (p_Ap_Id IN APPEAL.AP_ID%TYPE)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT NVL (MAX (app_num), 0) + 1
          INTO l_res
          FROM ap_person
         WHERE app_ap = p_Ap_Id;

        RETURN l_Res;
    END;

    PROCEDURE Save_Person (p_App_Id        IN     Ap_Person.App_Id%TYPE,
                           p_App_Ap        IN     Ap_Person.App_Ap%TYPE,
                           p_App_Tp        IN     Ap_Person.App_Tp%TYPE,
                           p_App_Inn       IN     Ap_Person.App_Inn%TYPE,
                           p_App_Ndt       IN     Ap_Person.App_Ndt%TYPE,
                           p_App_Doc_Num   IN     Ap_Person.App_Doc_Num%TYPE,
                           p_App_Fn        IN     Ap_Person.App_Fn%TYPE,
                           p_App_Mn        IN     Ap_Person.App_Mn%TYPE,
                           p_App_Ln        IN     Ap_Person.App_Ln%TYPE,
                           p_App_Esr_Num   IN     Ap_Person.App_Esr_Num%TYPE,
                           p_App_Gender    IN     Ap_Person.App_Gender%TYPE,
                           p_App_Vf        IN     Ap_Person.App_Vf%TYPE,
                           p_App_Sc        IN     Ap_Person.App_Sc%TYPE,
                           p_App_Num       IN     Ap_Person.App_Num%TYPE,
                           p_New_Id           OUT Ap_Person.App_Id%TYPE)
    IS
        l_App_Num   Ap_Person.App_Num%TYPE;
    BEGIN
        Ikis_sys.Ikis_Procedure_Log.LOG (
            p_src      => UPPER ('USS_VISIT.API$APPEAL.Save_Person'),
            p_obj_tp   => 'APPEAL',
            p_obj_id   => p_App_Ap,
            p_regular_params   =>
                   'p_App_Id='
                || p_App_Id
                || ', p_App_Inn='
                || p_App_Inn
                || ', p_App_Ndt='
                || p_App_Ndt
                || ', p_App_Doc_Num='
                || p_App_Doc_Num
                || ', p_App_Fn='
                || p_App_Fn
                || ', p_App_Mn='
                || p_App_Mn
                || ', p_App_Ln='
                || p_App_Ln
                || ', p_App_Esr_Num='
                || p_App_Esr_Num
                || ', p_App_Num='
                || p_App_Num,
            p_lob_param   =>
                Tools.GetAuditStack (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        IF p_App_Id IS NULL OR p_App_Id < 0
        THEN
            --#APP_NUM
            l_App_Num := NVL (p_App_Num, Get_Next_App_Num (p_App_Ap));


            INSERT INTO Ap_Person (App_Ap,
                                   App_Tp,
                                   App_Inn,
                                   App_Ndt,
                                   App_Doc_Num,
                                   App_Fn,
                                   App_Mn,
                                   App_Ln,
                                   App_Esr_Num,
                                   App_Gender,
                                   App_Vf,
                                   App_Sc,
                                   History_Status,
                                   App_Num)
                 VALUES (p_App_Ap,
                         p_App_Tp,
                         p_App_Inn,
                         p_App_Ndt,
                         p_App_Doc_Num,
                         Clear_Name (p_App_Fn),
                         Clear_Name (p_App_Mn),
                         Clear_Name (p_App_Ln),
                         p_App_Esr_Num,
                         p_App_Gender,
                         p_App_Vf,
                         p_App_Sc,
                         'A',
                         l_App_Num)
              RETURNING App_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_App_Id;

            UPDATE Ap_Person
               SET                                   --App_Ap      = p_App_Ap,
                   App_Tp = NVL (p_App_Tp, App_Tp),
                   App_Inn = NVL (p_App_Inn, App_Inn),
                   App_Ndt = NVL (p_App_Ndt, App_Ndt),
                   App_Doc_Num = NVL (p_App_Doc_Num, App_Doc_Num),
                   App_Fn = NVL (p_App_Fn, App_Fn),
                   App_Mn = NVL (p_App_Mn, App_Mn),
                   App_Ln = NVL (p_App_Ln, App_Ln),
                   App_Esr_Num = NVL (p_App_Esr_Num, App_Esr_Num),
                   App_Gender = NVL (p_App_Gender, App_Gender),
                   App_Vf = p_App_Vf, -- NVL(p_App_Vf,App_Vf)  -- changed 17/10/2024 by serhii: #109236-11 очищати протоколи по учасникам
                   App_Sc = NVL (p_App_Sc, App_Sc),
                   App_Num = NVL (p_App_Num, App_Num)
             WHERE App_Id = p_App_Id --Щоб випадково не перенесли учасника з одного звернення до іншого
                                     AND App_Ap = p_App_Ap;
        END IF;
    END;

    PROCEDURE Delete_Person (p_Id Ap_Person.App_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Person p
           SET p.History_Status = 'H'
         WHERE App_Id = p_Id;
    END;

    PROCEDURE Detach_Person_Docs (p_App_Id IN Ap_Person.App_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Document d
           SET d.Apd_App = NULL
         WHERE d.Apd_App = p_App_Id;
    END;

    PROCEDURE Delete_Person_Payments (p_App_Id IN Ap_Person.App_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Payment p
           SET p.History_Status = 'H'
         WHERE p.Apm_App = p_App_Id;
    END;

    FUNCTION Get_Person_Tp (p_App_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_App_Tp   VARCHAR2 (10);
    BEGIN
        SELECT p.App_Tp
          INTO l_App_Tp
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        RETURN l_App_Tp;
    END;

    FUNCTION Get_Person_Relation_Tp (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        --Визначаємо ступінь родинного з’язку
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.History_Status = 'A'
                      AND a.Apda_Nda = 649
         WHERE     d.Apd_App = p_App_Id
               AND d.Apd_Ndt = 605
               AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Inn (p_App_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Inn   Ap_Person.App_Inn%TYPE;
    BEGIN
        SELECT p.App_Inn
          INTO l_Inn
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        RETURN l_Inn;
    END;

    FUNCTION Get_Person_Inn_Doc (p_App_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Inn   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Inn
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = 1
                      AND a.History_Status = 'A'
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND d.Apd_Ndt = 5;

        RETURN l_Inn;
    END;

    FUNCTION Get_Person_Gender (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Person.App_Gender%TYPE;
    BEGIN
        SELECT p.App_Gender
          INTO l_Result
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        RETURN l_Result;
    END;

    FUNCTION Person_Has_Inn (p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Has_Inn   NUMBER;
    BEGIN
        SELECT CASE WHEN p.App_Inn IS NOT NULL THEN 1 ELSE 0 END
          INTO l_Has_Inn
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        IF l_Has_Inn = 0
        THEN
            SELECT SIGN (COUNT (*))
              INTO l_Has_Inn
              FROM Ap_Document d
             WHERE     d.Apd_App = p_App_Id
                   AND d.History_Status = 'A'
                   AND d.Apd_Ndt = 5;
        END IF;

        RETURN l_Has_Inn = 1;
    END;

    PROCEDURE Get_Person_Doc (p_App_Id    IN     NUMBER,
                              p_Ndt_Id    IN OUT NUMBER,
                              p_Apd_Id       OUT NUMBER,
                              p_Doc_Num      OUT VARCHAR2)
    IS
    BEGIN
          SELECT a.Apda_Val_String, d.Apd_Ndt, d.Apd_Id
            INTO p_Doc_Num, p_Ndt_Id, p_Apd_Id
            FROM Ap_Document d
                 JOIN Ap_Document_Attr a
                     ON d.Apd_Id = a.Apda_Apd AND a.History_Status = 'A'
                 JOIN Uss_Ndi.v_Ndi_Document_Attr n
                     ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
           WHERE     Apd_App = p_App_Id
                 AND (   Apd_Ndt = p_Ndt_Id
                      OR (    p_Ndt_Id IS NULL
                          AND Apd_Ndt IN (6,
                                          7,
                                          8,
                                          9,
                                          13,
                                          37)))
                 AND d.History_Status = 'A'
        ORDER BY CASE Apd_Ndt
                     WHEN 7 THEN 1
                     WHEN 6 THEN 2
                     WHEN 37 THEN 3
                     WHEN 13 THEN 4
                     WHEN 8 THEN 5
                     WHEN 9 THEN 6
                 END
           FETCH FIRST ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    FUNCTION Parse_Payments (p_Ap_Payments IN CLOB)
        RETURN t_Ap_Payments
    IS
        l_Ap_Payments   t_Ap_Payments;
    BEGIN
        IF p_Ap_Payments IS NULL OR DBMS_LOB.getlength (p_Ap_Payments) = 0
        THEN
            RETURN NULL;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Ap_Payments',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_Ap_Payments
            USING p_Ap_Payments;

        RETURN l_Ap_Payments;
    END;

    PROCEDURE Save_Payment (
        p_Apm_Id             IN     Ap_Payment.Apm_Id%TYPE,
        p_Apm_Ap             IN     Ap_Payment.Apm_Ap%TYPE,
        p_Apm_Aps            IN     Ap_Payment.Apm_Aps%TYPE,
        p_Apm_App            IN     Ap_Payment.Apm_App%TYPE,
        p_Apm_Tp             IN     Ap_Payment.Apm_Tp%TYPE,
        p_Apm_Index          IN     Ap_Payment.Apm_Index%TYPE,
        p_Apm_Kaot           IN     Ap_Payment.Apm_Kaot%TYPE,
        p_Apm_Nb             IN     Ap_Payment.Apm_Nb%TYPE,
        p_Apm_Account        IN     Ap_Payment.Apm_Account%TYPE,
        p_Apm_Need_Account   IN     Ap_Payment.Apm_Need_Account%TYPE,
        p_Apm_Street         IN     Ap_Payment.Apm_Street%TYPE,
        p_Apm_Ns             IN     Ap_Payment.Apm_Ns%TYPE,
        p_Apm_Building       IN     Ap_Payment.Apm_Building%TYPE,
        p_Apm_Block          IN     Ap_Payment.Apm_Block%TYPE,
        p_Apm_Apartment      IN     Ap_Payment.Apm_Apartment%TYPE,
        p_Apm_Dppa           IN     Ap_Payment.Apm_Dppa%TYPE,
        p_New_Id                OUT Ap_Payment.Apm_Id%TYPE)
    IS
    BEGIN
        IF p_Apm_Id IS NULL OR p_Apm_Id < 0
        THEN
            INSERT INTO Ap_Payment (Apm_Ap,
                                    Apm_Aps,
                                    Apm_App,
                                    Apm_Tp,
                                    Apm_Index,
                                    Apm_Kaot,
                                    Apm_Nb,
                                    Apm_Account,
                                    Apm_Need_Account,
                                    History_Status,
                                    Apm_Street,
                                    Apm_Ns,
                                    Apm_Building,
                                    Apm_Block,
                                    Apm_Apartment,
                                    Apm_Dppa)
                 VALUES (p_Apm_Ap,
                         p_Apm_Aps,
                         p_Apm_App,
                         p_Apm_Tp,
                         p_Apm_Index,
                         p_Apm_Kaot,
                         p_Apm_Nb,
                         p_Apm_Account,
                         p_Apm_Need_Account,
                         'A',
                         p_Apm_Street,
                         p_Apm_Ns,
                         p_Apm_Building,
                         p_Apm_Block,
                         p_Apm_Apartment,
                         p_Apm_Dppa)
              RETURNING Apm_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apm_Id;

            UPDATE Ap_Payment
               SET                              --Apm_Ap           = p_Apm_Ap,
                   Apm_Aps = p_Apm_Aps,
                   Apm_App = p_Apm_App,
                   Apm_Tp = p_Apm_Tp,
                   Apm_Index = p_Apm_Index,
                   Apm_Kaot = p_Apm_Kaot,
                   Apm_Nb = p_Apm_Nb,
                   Apm_Account = p_Apm_Account,
                   Apm_Need_Account = p_Apm_Need_Account,
                   Apm_Street = p_Apm_Street,
                   Apm_Ns = p_Apm_Ns,
                   Apm_Building = p_Apm_Building,
                   Apm_Block = p_Apm_Block,
                   Apm_Apartment = p_Apm_Apartment,
                   Apm_Dppa = p_Apm_Dppa
             WHERE Apm_Id = p_Apm_Id;
        END IF;
    END;

    PROCEDURE Delete_Payment (p_Id Ap_Payment.Apm_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Payment p
           SET p.History_Status = 'H'
         WHERE Apm_Id = p_Id;
    END;

    FUNCTION Parse_Documents (p_Ap_Documents IN CLOB)
        RETURN t_Ap_Documents
    IS
        l_Ap_Documents   t_Ap_Documents;
    BEGIN
        IF p_Ap_Documents IS NULL OR DBMS_LOB.getlength (p_Ap_Documents) = 0
        THEN
            RETURN NULL;
        END IF;

        --Парсинг документів
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Ap_Documents',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_Ap_Documents
            USING p_Ap_Documents;

        RETURN l_Ap_Documents;
    END;

    PROCEDURE Merge_Document (
        p_Apd_Id                IN     Ap_Document.Apd_Id%TYPE,
        p_Apd_Ap                IN     Ap_Document.Apd_Ap%TYPE,
        p_Apd_Ndt               IN     Ap_Document.Apd_Ndt%TYPE,
        p_Apd_Doc               IN     Ap_Document.Apd_Doc%TYPE,
        p_Apd_Vf                IN     Ap_Document.Apd_Vf%TYPE,
        p_Apd_App               IN     Ap_Document.Apd_App%TYPE,
        p_New_Id                   OUT Ap_Document.Apd_Id%TYPE,
        p_Com_Wu                IN     NUMBER,                        --Ignore
        p_Apd_Dh                IN     Ap_Document.Apd_Dh%TYPE,       --Ignore
        p_Apd_Aps               IN     Ap_Document.Apd_Aps%TYPE,
        p_Apd_Tmp_To_Del_File   IN     Ap_Document.Apd_Tmp_To_Del_File%TYPE DEFAULT NULL,
        p_Apd_Src               IN     VARCHAR2 DEFAULT NULL          --Ignore
                                                            )
    IS
        l_Apd   AP_DOCUMENT%ROWTYPE;
    BEGIN
        IF p_Apd_Id IS NULL OR p_Apd_Id < 0
        THEN
            BEGIN
                SELECT *
                  INTO l_apd
                  FROM ap_document
                 WHERE     apd_ap = p_Apd_Ap
                       AND apd_ndt = p_Apd_Ndt
                       AND History_Status = 'A';
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
                WHEN TOO_MANY_ROWS
                THEN
                    NULL;
            END;
        ELSE
            l_Apd.Apd_Id := p_Apd_Id;
        END IF;

        Save_Document (l_Apd.Apd_Id,
                       NVL (p_Apd_Ap, l_apd.apd_ap),
                       NVL (p_Apd_Ndt, l_apd.Apd_Ndt),
                       NVL (p_Apd_Doc, l_apd.Apd_Doc),
                       NVL (p_Apd_Vf, l_apd.Apd_Vf),
                       NVL (p_Apd_App, l_apd.Apd_App),
                       p_New_Id,
                       p_Com_Wu,
                       NVL (p_Apd_Dh, l_apd.Apd_Dh),
                       NVL (p_Apd_Aps, l_apd.Apd_Aps),
                       p_Apd_Tmp_To_Del_File,
                       p_Apd_Src);
    END;

    PROCEDURE Save_Document (
        p_Apd_Id                IN     Ap_Document.Apd_Id%TYPE,
        p_Apd_Ap                IN     Ap_Document.Apd_Ap%TYPE,
        p_Apd_Ndt               IN     Ap_Document.Apd_Ndt%TYPE,
        p_Apd_Doc               IN     Ap_Document.Apd_Doc%TYPE,
        p_Apd_Vf                IN     Ap_Document.Apd_Vf%TYPE,
        p_Apd_App               IN     Ap_Document.Apd_App%TYPE,
        p_New_Id                   OUT Ap_Document.Apd_Id%TYPE,
        p_Com_Wu                IN     NUMBER,                        --Ignore
        p_Apd_Dh                IN     Ap_Document.Apd_Dh%TYPE,       --Ignore
        p_Apd_Aps               IN     Ap_Document.Apd_Aps%TYPE,
        p_Apd_Tmp_To_Del_File   IN     Ap_Document.Apd_Tmp_To_Del_File%TYPE DEFAULT NULL,
        p_Apd_Src               IN     VARCHAR2 DEFAULT NULL          --Ignore
                                                            )
    IS
    BEGIN
        IF p_Apd_Id IS NULL OR p_Apd_Id < 0
        THEN
            INSERT INTO Ap_Document (Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     Apd_Vf,
                                     Apd_App,
                                     Apd_Dh,
                                     History_Status,
                                     Apd_Tmp_To_Del_File,
                                     Apd_Aps)
                 VALUES (p_Apd_Ap,
                         p_Apd_Ndt,
                         p_Apd_Doc,
                         p_Apd_Vf,
                         p_Apd_App,
                         p_Apd_Dh,
                         'A',
                         p_Apd_Tmp_To_Del_File,
                         p_Apd_Aps)
              RETURNING Apd_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apd_Id;

            UPDATE Ap_Document
               SET                           --Apd_Ap              = p_Apd_Ap,
                   Apd_Ndt = p_Apd_Ndt,
                   Apd_Doc = p_Apd_Doc,
                   Apd_Vf = p_Apd_Vf,
                   Apd_App = p_Apd_App,
                   Apd_Dh = p_Apd_Dh,
                   Apd_Aps = p_Apd_Aps,
                   Apd_Tmp_To_Del_File = p_Apd_Tmp_To_Del_File
             WHERE Apd_Id = p_Apd_Id --Щоб випадково не перенесли документ до іншого звернення
                                     AND Apd_Ap = p_Apd_Ap;
        END IF;
    /*    IF p_Apd_Doc IS NOT NULL THEN
      Uss_Doc.Api$documents.Save_Document(p_Doc_Id        => p_Apd_Doc,
                                          p_Doc_Ndt       => p_Apd_Ndt,
                                          p_Doc_Actuality => Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                                          p_New_Id        => l_New_Id);

      Uss_Doc.Api$documents.Save_Doc_Hist(p_Dh_Id        => p_Apd_Dh,
                                          p_Dh_Doc       => p_Apd_Doc,
                                          p_Dh_Sign_Alg  => NULL,
                                          p_Dh_Ndt       => p_Apd_Ndt,
                                          p_Dh_Sign_File => NULL,
                                          p_Dh_Actuality => Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                                          p_Dh_Dt        => SYSDATE,
                                          p_Dh_Wu        => p_Com_Wu,
                                          p_Dh_Src       => Nvl(p_Apd_Src, c_Src_Vst),
                                          p_New_Id       => l_Dh_Id);
    END IF;*/
    --EXCEPTION WHEN OTHERS THEN
    --raise_application_error(-20000, 'p_Apd_Ndt='||p_Apd_Ndt||';p_Apd_App='||p_Apd_App);
    END;

    PROCEDURE Delete_Document (p_Id Ap_Document.Apd_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Document d
           SET d.History_Status = 'H'
         WHERE Apd_Id = p_Id;

        UPDATE Ap_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.Apda_Apd = p_Id;
    END;

    FUNCTION Parse_Document_Attr (
        p_Ap_Document_Attrs   IN XMLTYPE,
        p_Has_Root_Tag           BOOLEAN DEFAULT TRUE)
        RETURN t_Ap_Document_Attrs
    IS
        l_Ap_Document_Attrs   t_Ap_Document_Attrs;
    BEGIN
        IF p_Ap_Document_Attrs IS NULL
        THEN
            RETURN NULL;
        END IF;

        --Парсимо атрибути документа
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Ap_Document_Attrs',
                                         TRUE,
                                         FALSE,
                                         p_Has_Root_Tag)
            BULK COLLECT INTO l_Ap_Document_Attrs
            USING p_Ap_Document_Attrs;

        RETURN l_Ap_Document_Attrs;
    END;

    PROCEDURE Save_Attr (p_Apd_Id            IN NUMBER,
                         p_Ap_Id             IN NUMBER,
                         p_Apda_Nda          IN NUMBER,
                         p_Apda_Val_Int      IN NUMBER DEFAULT NULL,
                         p_Apda_Val_Dt       IN DATE DEFAULT NULL,
                         p_Apda_Val_String   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Apda_Id            NUMBER;
        l_Apda_Is_Modified   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Id),
               MAX (
                   CASE
                       WHEN     (   p_Apda_Val_Int IS NOT NULL
                                 OR p_Apda_Val_Dt IS NOT NULL
                                 OR p_Apda_Val_String IS NOT NULL)
                            AND (   NVL (p_Apda_Val_Int, -99999999) <>
                                    NVL (a.Apda_Val_Int, -99999999)
                                 OR NVL (
                                        p_Apda_Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy')) <>
                                    NVL (
                                        a.Apda_Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                                 OR NVL (p_Apda_Val_String, '#') <>
                                    NVL (a.Apda_Val_String, '#'))
                       THEN
                           1
                       ELSE
                           0
                   END)
          INTO l_Apda_Id, l_Apda_Is_Modified
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = p_Apd_Id
               AND a.Apda_Nda = p_Apda_Nda
               AND a.History_Status = 'A';

        IF l_Apda_Is_Modified = 1
        THEN
            --Якщо значення існуючого атрибута було змінено, переводимо його в статус "історичний"
            Api$appeal.Delete_Document_Attr (l_Apda_Id);
            l_Apda_Id := NULL;
        END IF;

        Api$appeal.Save_Document_Attr (
            p_Apda_Id           => l_Apda_Id,
            p_Apda_Ap           => p_Ap_Id,
            p_Apda_Apd          => p_Apd_Id,
            p_Apda_Nda          => p_Apda_Nda,
            p_Apda_Val_Int      => p_Apda_Val_Int,
            p_Apda_Val_Dt       => p_Apda_Val_Dt,
            p_Apda_Val_String   => p_Apda_Val_String,
            p_Apda_Val_Id       => NULL,
            p_Apda_Val_Sum      => NULL,
            p_New_Id            => l_Apda_Id);
    END;

    FUNCTION Get_Document_Id (p_Apd_Ap     IN Ap_Document_Attr.Apda_Ap%TYPE,
                              p_Apda_Nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT MAX (Apd_Id)
          INTO l_Res
          FROM Ap_Document  apd
               JOIN USS_NDI.v_Ndi_Document_Attr NDA
                   ON Apd.Apd_Ndt = Nda.nda_ndt
         WHERE Apd_Ap = p_Apd_Ap AND Nda.nda_id = p_Apda_Nda;

        RETURN l_Res;
    END;

    FUNCTION Get_Document_Attr_Id (
        p_Apda_Ap    IN Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT MAX (Apda_Id)
          INTO l_Res
          FROM Ap_Document_Attr
         WHERE     Apda_Ap = p_Apda_Ap
               AND (Apda_Apd = p_Apda_Apd OR p_Apda_Apd IS NULL)
               AND Apda_Nda = p_Apda_Nda;

        RETURN l_Res;
    END;

    /*
    function is_can_get_dict_name_by_id(P_NDA_ID IN NUMBER) RETURN NUMBER IS
     l_res NUMBER;
    begin
      select count(1)
      into l_res
      from uss_ndi.v_ndi_document_attr da
      join uss_ndi.v_ndi_param_type pt
        on da.nda_pt = pt.pt_id
      where pt.pt_edit_type='MF'
      and nda_id = P_NDA_ID;

      return l_res;
    end;

    function GET_DICT_NAME_BY_ID(P_NDA_ID IN NUMBER,
                                 P_NDA_VAL_ID IN NUMBER) RETURN VARCHAR2 IS
     l_Query VARCHAR2(32000);
     l_Res VARCHAR2(4000);
    begin
      select dc.ndc_sql
      into l_Query
      from uss_ndi.v_ndi_document_attr da
      join uss_ndi.v_ndi_param_type pt
        on da.nda_pt = pt.pt_id
      join uss_ndi.v_ndi_dict_config dc
        on pt.pt_ndc = dc.ndc_id
      where pt.pt_edit_type='MF'
      and nda_id = P_NDA_ID;

      l_Query := regexp_replace(l_Query, 'AND ROWNUM < \d{1,5}','AND 1=1');


      l_Query := 'SELECT NAME
         FROM (
         '||l_Query||'
         )
         WHERE ID = '||P_NDA_VAL_ID;

      dbms_output.put_line(l_Query);

      EXECUTE IMMEDIATE l_Query INTO l_Res;


      RETURN l_Res;

    exception
      when no_data_found then return null;
    end;
    */

    PROCEDURE Save_Document_Attr (
        p_Apda_Id           IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Int      IN     Ap_Document_Attr.Apda_Val_Int%TYPE DEFAULT NULL,
        p_Apda_Val_Dt       IN     Ap_Document_Attr.Apda_Val_Dt%TYPE DEFAULT NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_Apda_Val_Sum      IN     Ap_Document_Attr.Apda_Val_Sum%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apda_Val_String   Ap_Document_Attr.Apda_Val_String%TYPE
                                := p_Apda_Val_String;
    BEGIN
        --Тут по ИД справочника пітаемся достать наименование
        IF (l_Apda_Val_String IS NULL AND p_Apda_Val_Id IS NOT NULL)
        THEN
            IF USS_NDI.API$FIND.is_can_get_dict_name_by_id (p_Apda_Nda) > 0
            THEN
                IF USS_NDI.API$FIND.get_dict_name_by_id_source (p_Apda_Nda) =
                   'USS_RNSP'
                THEN
                    l_Apda_Val_String :=
                        USS_RNSP.API$FIND.GET_DICT_NAME_BY_ID (
                            P_NDA_ID       => p_Apda_Nda,
                            P_NDA_VAL_ID   => p_Apda_Val_Id);
                ELSE
                    l_Apda_Val_String :=
                        USS_NDI.API$FIND.GET_DICT_NAME_BY_ID (
                            P_NDA_ID       => p_Apda_Nda,
                            P_NDA_VAL_ID   => p_Apda_Val_Id);
                END IF;
            END IF;
        END IF;

        IF p_Apda_Id IS NULL OR p_Apda_Id < 0
        THEN
            INSERT INTO Ap_Document_Attr (Apda_Id,
                                          Apda_Ap,
                                          Apda_Apd,
                                          Apda_Nda,
                                          Apda_Val_Id,
                                          Apda_Val_Int,
                                          Apda_Val_Dt,
                                          Apda_Val_String,
                                          Apda_Val_Sum,
                                          History_Status)
                 VALUES (0,
                         p_Apda_Ap,
                         p_Apda_Apd,
                         p_Apda_Nda,
                         p_Apda_Val_Id,
                         p_Apda_Val_Int,
                         p_Apda_Val_Dt,
                         l_Apda_Val_String,
                         p_Apda_Val_Sum,
                         'A')
              RETURNING Apda_Val_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apda_Val_Id;

            UPDATE Ap_Document_Attr
               SET Apda_Ap = p_Apda_Ap,
                   Apda_Apd = p_Apda_Apd,
                   Apda_Nda = p_Apda_Nda,
                   Apda_Val_Id = p_Apda_Val_Id,
                   Apda_Val_Int = p_Apda_Val_Int,
                   Apda_Val_Dt = p_Apda_Val_Dt,
                   Apda_Val_String = l_Apda_Val_String,
                   Apda_Val_Sum = p_Apda_Val_Sum
             WHERE Apda_Id = p_Apda_Id;
        END IF;
    END;

    PROCEDURE Save_Not_Empty_Document_Attr_Str (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apda_Id   Ap_Document_attr.Apda_Id%TYPE;
        l_Apd_Id    Ap_Document.Apd_Id%TYPE;
    BEGIN
        IF p_Apda_Val_String IS NOT NULL
        THEN
            l_Apd_Id :=
                NVL (
                    p_Apda_Apd,
                    Api$appeal.Get_Document_Id (p_Apd_Ap     => p_Apda_Ap,
                                                p_Apda_Nda   => p_Apda_Nda));
            l_Apda_Id :=
                Api$appeal.Get_Document_Attr_Id (p_Apda_Ap    => p_Apda_Ap,
                                                 p_Apda_Apd   => l_Apd_Id,
                                                 p_Apda_Nda   => p_Apda_Nda);
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => l_Apda_Id,
                p_Apda_Ap           => p_Apda_Ap,
                p_Apda_Apd          => l_Apd_Id,
                p_Apda_Nda          => p_Apda_Nda,
                p_Apda_Val_String   => p_Apda_Val_String,
                p_New_Id            => p_New_Id);
        END IF;
    END;

    PROCEDURE Save_Not_Empty_Document_Attr_Dt (
        p_Apda_Ap       IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd      IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda      IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Dt   IN     Ap_Document_Attr.Apda_Val_Dt%TYPE DEFAULT NULL,
        p_New_Id           OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apda_Id   Ap_Document_attr.Apda_Id%TYPE;
        l_Apd_Id    Ap_Document.Apd_Id%TYPE;
    BEGIN
        IF p_Apda_Val_Dt IS NOT NULL
        THEN
            l_Apd_Id :=
                NVL (
                    p_Apda_Apd,
                    Api$appeal.Get_Document_Id (p_Apd_Ap     => p_Apda_Ap,
                                                p_Apda_Nda   => p_Apda_Nda));
            l_Apda_Id :=
                Api$appeal.Get_Document_Attr_Id (p_Apda_Ap    => p_Apda_Ap,
                                                 p_Apda_Apd   => l_Apd_Id,
                                                 p_Apda_Nda   => p_Apda_Nda);
            Api$appeal.Save_Document_Attr (p_Apda_Id       => l_Apda_Id,
                                           p_Apda_Ap       => p_Apda_Ap,
                                           p_Apda_Apd      => l_Apd_Id,
                                           p_Apda_Nda      => p_Apda_Nda,
                                           p_Apda_Val_Dt   => p_Apda_Val_Dt,
                                           p_New_Id        => p_New_Id);
        END IF;
    END;

    PROCEDURE Save_Not_Empty_Document_Attr_Id (
        p_Apda_Ap       IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd      IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda      IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Id   IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_New_Id           OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apda_Id   Ap_Document_attr.Apda_Id%TYPE;
        l_Apd_Id    Ap_Document.Apd_Id%TYPE;
    BEGIN
        IF p_Apda_Val_Id IS NOT NULL
        THEN
            l_Apda_Id :=
                Api$appeal.Get_Document_Attr_Id (p_Apda_Ap    => p_Apda_Ap,
                                                 p_Apda_Apd   => p_Apda_Apd,
                                                 p_Apda_Nda   => p_Apda_Nda);
            l_Apd_Id :=
                NVL (
                    l_Apd_Id,
                    Api$appeal.Get_Document_Id (p_Apd_Ap     => p_Apda_Ap,
                                                p_Apda_Nda   => p_Apda_Nda));
            Api$appeal.Save_Document_Attr (p_Apda_Id       => l_Apda_Id,
                                           p_Apda_Ap       => p_Apda_Ap,
                                           p_Apda_Apd      => l_Apd_Id,
                                           p_Apda_Nda      => p_Apda_Nda,
                                           p_Apda_Val_Id   => p_Apda_Val_Id,
                                           p_New_Id        => p_New_Id);
        END IF;
    END;

    PROCEDURE Save_Not_Empty_Document_Attr_Id_Str (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apda_Id   Ap_Document_attr.Apda_Id%TYPE;
        l_Apd_Id    Ap_Document.Apd_Id%TYPE;
    BEGIN
        IF p_Apda_Val_Id IS NOT NULL OR p_Apda_Val_String IS NOT NULL
        THEN
            l_Apda_Id :=
                Api$appeal.Get_Document_Attr_Id (p_Apda_Ap    => p_Apda_Ap,
                                                 p_Apda_Apd   => p_Apda_Apd,
                                                 p_Apda_Nda   => p_Apda_Nda);
            l_Apd_Id :=
                NVL (
                    l_Apd_Id,
                    Api$appeal.Get_Document_Id (p_Apd_Ap     => p_Apda_Ap,
                                                p_Apda_Nda   => p_Apda_Nda));
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => l_Apda_Id,
                p_Apda_Ap           => p_Apda_Ap,
                p_Apda_Apd          => l_Apd_Id,
                p_Apda_Nda          => p_Apda_Nda,
                p_Apda_Val_Id       => p_Apda_Val_Id,
                p_Apda_Val_String   => p_Apda_Val_String,
                p_New_Id            => p_New_Id);
        END IF;
    END;

    PROCEDURE Save_Exists_Doc_Attr (
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
        l_Apd_id    NUMBER;
        l_Apda_id   NUMBER;
    BEGIN
        l_Apd_id := Get_Document_Id (p_Apda_Ap, p_Apda_Nda);

        IF l_Apd_id IS NOT NULL
        THEN
            l_Apda_id :=
                Get_Document_Attr_Id (p_Apda_Ap    => p_Apda_Ap,
                                      p_Apda_Apd   => l_Apd_id,
                                      p_Apda_Nda   => p_Apda_Nda);
            Save_Document_Attr (p_Apda_Id           => l_Apda_id,
                                p_Apda_Ap           => p_Apda_Ap,
                                p_Apda_Apd          => l_Apd_id,
                                p_Apda_Nda          => p_Apda_Nda,
                                p_Apda_Val_String   => p_Apda_Val_String,
                                p_New_Id            => p_New_Id);
        END IF;
    END;


    PROCEDURE Copy_Document_Attr (
        p_Apda_Id_From   IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Id_To     IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Nda_To    IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_New_Id            OUT Ap_Document_Attr.Apda_Id%TYPE)
    IS
        l_Row   Ap_Document_Attr%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Row
          FROM Ap_Document_Attr
         WHERE Apda_Id = p_Apda_Id_From;

        IF p_Apda_Id_To IS NULL OR p_Apda_Id_To < 0
        THEN
            INSERT INTO Ap_Document_Attr (Apda_Id,
                                          Apda_Ap,
                                          Apda_Apd,
                                          Apda_Nda,
                                          Apda_Val_Id,
                                          Apda_Val_Int,
                                          Apda_Val_Dt,
                                          Apda_Val_String,
                                          Apda_Val_Sum,
                                          History_Status)
                 VALUES (0,
                         l_Row.Apda_Ap,
                         l_Row.Apda_Apd,
                         NVL (p_Apda_Nda_To, l_Row.Apda_Nda),
                         l_Row.Apda_Val_Id,
                         l_Row.Apda_Val_Int,
                         l_Row.Apda_Val_Dt,
                         l_Row.Apda_Val_String,
                         l_Row.Apda_Val_Sum,
                         'A')
              RETURNING Apda_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apda_Id_To;


            UPDATE Ap_Document_Attr
               SET Apda_Ap = l_Row.Apda_Ap,
                   Apda_Apd = l_Row.Apda_Apd,
                   Apda_Nda = NVL (p_Apda_Nda_To, l_Row.Apda_Nda),
                   Apda_Val_Id = l_Row.Apda_Val_Id,
                   Apda_Val_Int = l_Row.Apda_Val_Int,
                   Apda_Val_Dt = l_Row.Apda_Val_Dt,
                   Apda_Val_String = l_Row.Apda_Val_String,
                   Apda_Val_Sum = l_Row.Apda_Val_Sum
             WHERE Apda_Id = p_New_Id;
        END IF;
    END;

    PROCEDURE Delete_Document_Attr (p_Id Ap_Document_Attr.Apda_Val_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.Apda_Id = p_Id;
    END;

    FUNCTION Get_Apd_Ap (p_Apd_Id IN Ap_Document.Apd_Id%TYPE)
        RETURN Ap_Document.Apd_Ap%TYPE
    IS
        l_Apd_Ap   NUMBER;
    BEGIN
        SELECT d.Apd_Ap
          INTO l_Apd_Ap
          FROM Ap_Document d
         WHERE d.Apd_Id = p_Apd_Id;

        RETURN l_Apd_Ap;
    END;


    FUNCTION Get_Doc_Owner_Sc (p_Apd_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        SELECT p.App_Sc
          INTO l_Sc_Id
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = p_Apd_Id;

        RETURN l_Sc_Id;
    END;

    FUNCTION Get_Attr_Val_Dt (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                              p_Nda_Class   IN VARCHAR2)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.Apda_Val_Dt)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_String (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_String (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Id      NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = p_Apd_Id
               AND a.History_Status = 'A'
               AND a.Apda_Nda = p_Nda_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_Id (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                              p_Nda_Id      NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = p_Apd_Id
               AND a.History_Status = 'A'
               AND a.Apda_Nda = p_Nda_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Attrp_Val_String (p_Apd_Id   IN Ap_Document.Apd_Id%TYPE,
                                   p_Pt_Id       NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Pt = p_Pt_Id
         WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Attr_Val_Str (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE d.Apd_App = p_App_Id AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Attr_Val_Str (p_App_Id      IN NUMBER,
                                      p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Apda_Val_String)
          INTO l_Result
          FROM (  SELECT a.Apda_Val_String
                    FROM Ap_Document d
                         JOIN Ap_Document_Attr a
                             ON     d.Apd_Id = a.Apda_Apd
                                AND a.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                             ON     a.Apda_Nda = n.Nda_Id
                                AND n.nda_class = p_Nda_Class
                   WHERE     d.Apd_App = p_App_Id
                         AND d.History_Status = 'A'
                         AND a.Apda_Val_String IS NOT NULL
                ORDER BY n.nda_order)
         WHERE ROWNUM = 1;

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Attr_Val_Id (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE d.Apd_App = p_App_Id AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Attr_Val_Dt (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.Apda_Val_Dt)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND Apda_Val_Dt IS NOT NULL;

        RETURN l_Result;
    END;

    FUNCTION Get_Person_Attr_Val_Dt (p_App_Id      IN NUMBER,
                                     p_Nda_Class   IN VARCHAR2)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (Apda_Val_Dt)
          INTO l_Result
          FROM (  SELECT a.Apda_Val_Dt
                    FROM Ap_Document d
                         JOIN Ap_Document_Attr a
                             ON     d.Apd_Id = a.Apda_Apd
                                AND a.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                             ON     a.Apda_Nda = n.Nda_Id
                                AND n.nda_class = p_Nda_Class
                   WHERE     d.Apd_App = p_App_Id
                         AND d.History_Status = 'A'
                         AND a.Apda_Val_Dt IS NOT NULL
                ORDER BY n.nda_order)
         WHERE ROWNUM = 1;

        RETURN l_Result;
    END;

    -- 12/08/2024 serhii: для пошуку атрибуту тільки в документах певної категорії #106852
    FUNCTION Get_Person_Doc_Attr_Val_Dt (
        p_App_Id      IN NUMBER,
        p_Nda_Class   IN VARCHAR2,
        p_Ndt_Ndc     IN NUMBER DEFAULT NULL)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (Apda_Val_Dt)
          INTO l_Result
          FROM (  SELECT a.Apda_Val_Dt
                    FROM Ap_Document d
                         JOIN Ap_Document_Attr a
                             ON     d.Apd_Id = a.Apda_Apd
                                AND a.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                             ON     a.Apda_Nda = n.Nda_Id
                                AND n.nda_class = p_Nda_Class
                         JOIN Uss_Ndi.v_Ndi_Document_Type t
                             ON d.apd_ndt = t.ndt_id
                   WHERE     d.Apd_App = p_App_Id
                         AND d.History_Status = 'A'
                         AND a.Apda_Val_Dt IS NOT NULL
                         AND NVL (p_Ndt_Ndc, t.ndt_ndc) = t.ndt_ndc
                ORDER BY t.ndt_order)
         WHERE ROWNUM = 1;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Attr_Val_Str (p_Ap_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Attr_Val_Id (p_Ap_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    PROCEDURE Clear_Document_Attrs (p_Apd_Id Ap_Document.Apd_Id%TYPE)
    IS
    BEGIN
        UPDATE Ap_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.Apda_Apd = p_Apd_Id;
    END;

    FUNCTION Parse_Declaration (p_Declaration_Dto IN CLOB)
        RETURN r_Declaration_Dto
    IS
        l_Declaration_Xml_Dto   r_Declaration_Xml_Dto;
        l_Declaration_Dto       r_Declaration_Dto;
    BEGIN
        IF    p_Declaration_Dto IS NULL
           OR DBMS_LOB.getlength (p_Declaration_Dto) = 0
        THEN
            RETURN NULL;
        END IF;

                    SELECT Declaration,
                           Persons,
                           Incomes,
                           Land_Plots,
                           Living_Quarters,
                           Other_Incomes,
                           Spendings,
                           Vehicles
                      INTO l_Declaration_Xml_Dto
                      FROM XMLTABLE (
                               '/*'
                               PASSING Xmltype (p_Declaration_Dto)
                               COLUMNS --
                                       Declaration        XMLTYPE PATH 'Declaration',
                                       Persons            XMLTYPE PATH 'Persons',
                                       Incomes            XMLTYPE PATH 'Incomes',
                                       Land_Plots         XMLTYPE PATH 'LandPlots',
                                       Living_Quarters    XMLTYPE PATH 'LivingQuarters',
                                       Other_Incomes      XMLTYPE PATH 'OtherIncomes',
                                       Spendings          XMLTYPE PATH 'Spendings',
                                       Vehicles           XMLTYPE PATH 'Vehicles');

        --Парсинг шапки декларації
        IF l_Declaration_Xml_Dto.Declaration IS NOT NULL
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'r_Ap_Declaration',
                                             TRUE,
                                             FALSE)
                INTO l_Declaration_Dto.Declaration
                USING l_Declaration_Xml_Dto.Declaration;
        END IF;

        IF l_Declaration_Xml_Dto.Persons IS NOT NULL
        THEN
            --Парсинг членів родини
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Persons',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Persons
                USING l_Declaration_Xml_Dto.Persons;
        END IF;

        IF l_Declaration_Xml_Dto.Incomes IS NOT NULL
        THEN
            --Парсинг доходів членів родини
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Incomes',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Incomes
                USING l_Declaration_Xml_Dto.Incomes;
        END IF;

        IF l_Declaration_Xml_Dto.Land_Plots IS NOT NULL
        THEN
            --Парсинг земельних ділянок
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Land_Plots',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Land_Plots
                USING l_Declaration_Xml_Dto.Land_Plots;
        END IF;

        IF l_Declaration_Xml_Dto.Living_Qurters IS NOT NULL
        THEN
            --Парсинг житлових приміщень
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Living_Quarters',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Living_Qurters
                USING l_Declaration_Xml_Dto.Living_Qurters;
        END IF;

        IF l_Declaration_Xml_Dto.Other_Incomes IS NOT NULL
        THEN
            --Парсинг додаткових джерел існування
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Other_Incomes',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Other_Incomes
                USING l_Declaration_Xml_Dto.Other_Incomes;
        END IF;

        IF l_Declaration_Xml_Dto.Spendings IS NOT NULL
        THEN
            --Парсинг відомостей про витрати
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Spendings',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Spendings
                USING l_Declaration_Xml_Dto.Spendings;
        END IF;

        IF l_Declaration_Xml_Dto.Vehicles IS NOT NULL
        THEN
            --Парсинг транспортних засобів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_Apr_Vehicles',
                                             TRUE,
                                             FALSE)
                BULK COLLECT INTO l_Declaration_Dto.Vehicles
                USING l_Declaration_Xml_Dto.Vehicles;
        END IF;

        RETURN l_Declaration_Dto;
    END;

    PROCEDURE Save_Declaration (
        p_Apr_Id          IN     Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Ap          IN     Ap_Declaration.Apr_Ap%TYPE,
        p_Apr_Fn          IN     Ap_Declaration.Apr_Fn%TYPE,
        p_Apr_Mn          IN     Ap_Declaration.Apr_Mn%TYPE,
        p_Apr_Ln          IN     Ap_Declaration.Apr_Ln%TYPE,
        p_Apr_Residence   IN     Ap_Declaration.Apr_Residence%TYPE,
        p_Com_Org         IN     Ap_Declaration.Com_Org%TYPE,
        p_Apr_Vf          IN     Ap_Declaration.Apr_Vf%TYPE,
        p_Apr_Start_Dt    IN     Ap_Declaration.Apr_Start_Dt%TYPE,
        p_Apr_Stop_Dt     IN     Ap_Declaration.Apr_Stop_Dt%TYPE,
        p_New_Id             OUT Ap_Declaration.Apr_Residence%TYPE)
    IS
    BEGIN
        IF p_Apr_Id IS NULL OR p_Apr_Id < 0
        THEN
            INSERT INTO Ap_Declaration (Apr_Ap,
                                        Apr_Fn,
                                        Apr_Mn,
                                        Apr_Ln,
                                        Com_Org,
                                        Apr_Vf,
                                        Apr_Start_Dt,
                                        Apr_Stop_Dt,
                                        Apr_Residence)
                 VALUES (p_Apr_Ap,
                         p_Apr_Fn,
                         p_Apr_Mn,
                         p_Apr_Ln,
                         p_Com_Org,
                         p_Apr_Vf,
                         p_Apr_Start_Dt,
                         p_Apr_Stop_Dt,
                         p_Apr_Residence)
              RETURNING Apr_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apr_Id;

            UPDATE Ap_Declaration
               SET Apr_Ap = p_Apr_Ap,
                   Apr_Fn = p_Apr_Fn,
                   Apr_Mn = p_Apr_Mn,
                   Apr_Ln = p_Apr_Ln,
                   Com_Org = p_Com_Org,
                   Apr_Vf = p_Apr_Vf,
                   Apr_Start_Dt = p_Apr_Start_Dt,
                   Apr_Stop_Dt = p_Apr_Stop_Dt,
                   Apr_Residence = p_Apr_Residence
             WHERE Apr_Id = p_Apr_Id;
        END IF;
    END;

    FUNCTION Declaration_Exists (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Declaration_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Declaration_Exists
          FROM Ap_Declaration d
         WHERE d.Apr_Ap = p_Ap_Id;

        RETURN l_Declaration_Exists = 1;
    END;

    FUNCTION Declaration_Period_Exists (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Declaration_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Declaration_Exists
          FROM Ap_Declaration d
         WHERE     d.Apr_Ap = p_Ap_Id
               AND d.Apr_Start_Dt IS NOT NULL
               AND d.Apr_Stop_Dt IS NOT NULL;

        RETURN l_Declaration_Exists = 1;
    END;

    PROCEDURE Save_Apr_Person (
        p_Aprp_Id      IN     Apr_Person.Aprp_Id%TYPE,
        p_Aprp_Apr     IN     Apr_Person.Aprp_Apr%TYPE,
        p_Aprp_Fn      IN     Apr_Person.Aprp_Fn%TYPE,
        p_Aprp_Mn      IN     Apr_Person.Aprp_Mn%TYPE,
        p_Aprp_Ln      IN     Apr_Person.Aprp_Ln%TYPE,
        p_Aprp_Tp      IN     Apr_Person.Aprp_Tp%TYPE,
        p_Aprp_Inn     IN     Apr_Person.Aprp_Inn%TYPE,
        p_Aprp_Notes   IN     Apr_Person.Aprp_Notes%TYPE,
        p_Aprp_App     IN     Apr_Person.Aprp_App%TYPE,
        p_New_Id          OUT Apr_Person.Aprp_Id%TYPE)
    IS
    BEGIN
        IF p_Aprp_Id IS NULL OR p_Aprp_Id < 0
        THEN
            INSERT INTO Apr_Person (Aprp_Apr,
                                    Aprp_Fn,
                                    Aprp_Mn,
                                    Aprp_Ln,
                                    Aprp_Tp,
                                    Aprp_Inn,
                                    Aprp_Notes,
                                    Aprp_App,
                                    History_Status)
                 VALUES (p_Aprp_Apr,
                         p_Aprp_Fn,
                         p_Aprp_Mn,
                         p_Aprp_Ln,
                         p_Aprp_Tp,
                         p_Aprp_Inn,
                         p_Aprp_Notes,
                         p_Aprp_App,
                         'A')
              RETURNING Aprp_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aprp_Id;

            UPDATE Apr_Person
               SET Aprp_Apr = p_Aprp_Apr,
                   Aprp_Fn = p_Aprp_Fn,
                   Aprp_Mn = p_Aprp_Mn,
                   Aprp_Ln = p_Aprp_Ln,
                   Aprp_Tp = p_Aprp_Tp,
                   Aprp_Inn = p_Aprp_Inn,
                   Aprp_Notes = p_Aprp_Notes,
                   Aprp_App = p_Aprp_App
             WHERE Aprp_Id = p_Aprp_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Person (p_Aprp_Id IN Apr_Person.Aprp_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Person p
           SET p.History_Status = 'H'
         WHERE p.Aprp_Id = p_Aprp_Id;
    END;

    PROCEDURE Save_Apr_Income (
        p_Apri_Id            IN     Apr_Income.Apri_Id%TYPE,
        p_Apri_Apr           IN     Apr_Income.Apri_Apr%TYPE,
        p_Apri_Ln_Initials   IN     Apr_Income.Apri_Ln_Initials%TYPE,
        p_Apri_Tp            IN     Apr_Income.Apri_Tp%TYPE,
        p_Apri_Sum           IN     Apr_Income.Apri_Sum%TYPE,
        p_Apri_Source        IN     Apr_Income.Apri_Source%TYPE,
        p_Apri_Aprp          IN     Apr_Income.Apri_Aprp%TYPE,
        p_Apri_Start_Dt      IN     Apr_Income.Apri_Start_Dt%TYPE,
        p_Apri_Stop_Dt       IN     Apr_Income.Apri_Stop_Dt%TYPE,
        p_New_Id                OUT Apr_Income.Apri_Id%TYPE)
    IS
    BEGIN
        IF p_Apri_Id IS NULL OR p_Apri_Id < 0
        THEN
            INSERT INTO Apr_Income (Apri_Apr,
                                    Apri_Ln_Initials,
                                    Apri_Tp,
                                    Apri_Sum,
                                    Apri_Source,
                                    Apri_Aprp,
                                    Apri_Start_Dt,
                                    Apri_Stop_Dt,
                                    History_Status)
                 VALUES (p_Apri_Apr,
                         p_Apri_Ln_Initials,
                         p_Apri_Tp,
                         p_Apri_Sum,
                         p_Apri_Source,
                         p_Apri_Aprp,
                         TRUNC (p_Apri_Start_Dt),
                         TRUNC (p_Apri_Stop_Dt),
                         'A')
              RETURNING Apri_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apri_Id;

            UPDATE Apr_Income
               SET Apri_Apr = p_Apri_Apr,
                   Apri_Ln_Initials = p_Apri_Ln_Initials,
                   Apri_Tp = p_Apri_Tp,
                   Apri_Sum = p_Apri_Sum,
                   Apri_Source = p_Apri_Source,
                   Apri_Aprp = p_Apri_Aprp,
                   Apri_Start_Dt = TRUNC (p_Apri_Start_Dt),
                   Apri_Stop_Dt = TRUNC (p_Apri_Stop_Dt)
             WHERE Apri_Id = p_Apri_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Income (p_Apri_Id IN Apr_Income.Apri_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Income i
           SET i.History_Status = 'H'
         WHERE i.Apri_Id = p_Apri_Id;
    END;

    PROCEDURE Save_Apr_Land_Plot (
        p_Aprt_Id            IN     Apr_Land_Plot.Aprt_Id%TYPE,
        p_Aprt_Apr           IN     Apr_Land_Plot.Aprt_Apr%TYPE,
        p_Aprt_Ln_Initials   IN     Apr_Land_Plot.Aprt_Ln_Initials%TYPE,
        p_Aprt_Area          IN     Apr_Land_Plot.Aprt_Area%TYPE,
        p_Aprt_Ownership     IN     Apr_Land_Plot.Aprt_Ownership%TYPE,
        p_Aprt_Purpose       IN     Apr_Land_Plot.Aprt_Purpose%TYPE,
        p_Aprt_Aprp          IN     Apr_Land_Plot.Aprt_Aprp%TYPE,
        p_New_Id                OUT Apr_Land_Plot.Aprt_Id%TYPE)
    IS
    BEGIN
        IF p_Aprt_Id IS NULL OR p_Aprt_Id < 0
        THEN
            INSERT INTO Apr_Land_Plot (Aprt_Apr,
                                       Aprt_Ln_Initials,
                                       Aprt_Area,
                                       Aprt_Ownership,
                                       Aprt_Purpose,
                                       Aprt_Aprp,
                                       History_Status)
                 VALUES (p_Aprt_Apr,
                         p_Aprt_Ln_Initials,
                         p_Aprt_Area,
                         p_Aprt_Ownership,
                         p_Aprt_Purpose,
                         p_Aprt_Aprp,
                         'A')
              RETURNING Aprt_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aprt_Id;

            UPDATE Apr_Land_Plot
               SET Aprt_Apr = p_Aprt_Apr,
                   Aprt_Ln_Initials = p_Aprt_Ln_Initials,
                   Aprt_Area = p_Aprt_Area,
                   Aprt_Ownership = p_Aprt_Ownership,
                   Aprt_Purpose = p_Aprt_Purpose,
                   Aprt_Aprp = p_Aprt_Aprp
             WHERE Aprt_Id = p_Aprt_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Land_Plot (Aprt_Id IN Apr_Land_Plot.Aprt_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Land_Plot p
           SET p.History_Status = 'H'
         WHERE p.Aprt_Id = Aprt_Id;
    END;

    PROCEDURE Save_Apr_Living_Quarters (
        p_Aprl_Id            IN     Apr_Living_Quarters.Aprl_Id%TYPE,
        p_Aprl_Apr           IN     Apr_Living_Quarters.Aprl_Apr%TYPE,
        p_Aprl_Ln_Initials   IN     Apr_Living_Quarters.Aprl_Ln_Initials%TYPE,
        p_Aprl_Area          IN     Apr_Living_Quarters.Aprl_Area%TYPE,
        p_Aprl_Qnt           IN     Apr_Living_Quarters.Aprl_Qnt%TYPE,
        p_Aprl_Address       IN     Apr_Living_Quarters.Aprl_Address%TYPE,
        p_Aprl_Aprp          IN     Apr_Living_Quarters.Aprl_Aprp%TYPE,
        p_Aprl_Tp            IN     Apr_Living_Quarters.Aprl_Tp%TYPE DEFAULT NULL,
        p_Aprl_Ch            IN     Apr_Living_Quarters.Aprl_Ch%TYPE DEFAULT NULL,
        p_New_Id                OUT Apr_Living_Quarters.Aprl_Id%TYPE)
    IS
    BEGIN
        IF p_Aprl_Id IS NULL OR p_Aprl_Id < 0
        THEN
            INSERT INTO Apr_Living_Quarters (Aprl_Apr,
                                             Aprl_Ln_Initials,
                                             Aprl_Area,
                                             Aprl_Qnt,
                                             Aprl_Address,
                                             Aprl_Aprp,
                                             History_Status,
                                             Aprl_Tp,
                                             Aprl_Ch)
                 VALUES (p_Aprl_Apr,
                         p_Aprl_Ln_Initials,
                         p_Aprl_Area,
                         p_Aprl_Qnt,
                         p_Aprl_Address,
                         p_Aprl_Aprp,
                         'A',
                         p_Aprl_Tp,
                         p_Aprl_Ch)
              RETURNING Aprl_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aprl_Id;

            UPDATE Apr_Living_Quarters
               SET Aprl_Apr = p_Aprl_Apr,
                   Aprl_Ln_Initials = p_Aprl_Ln_Initials,
                   Aprl_Area = p_Aprl_Area,
                   Aprl_Qnt = p_Aprl_Qnt,
                   Aprl_Address = p_Aprl_Address,
                   Aprl_Aprp = p_Aprl_Aprp,
                   Aprl_Tp = NVL (p_Aprl_Tp, Aprl_Tp),
                   Aprl_Ch = NVL (p_Aprl_Ch, Aprl_Ch)
             WHERE Aprl_Id = p_Aprl_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Living_Quarters (
        p_Aprl_Id   IN Apr_Living_Quarters.Aprl_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Living_Quarters q
           SET q.History_Status = 'H'
         WHERE q.Aprl_Id = p_Aprl_Id;
    END;

    PROCEDURE Save_Apr_Other_Income (
        p_Apro_Id             IN     Apr_Other_Income.Apro_Id%TYPE,
        p_Apro_Apr            IN     Apr_Other_Income.Apro_Apr%TYPE,
        p_Apro_Tp             IN     Apr_Other_Income.Apro_Tp%TYPE,
        p_Apro_Income_Info    IN     Apr_Other_Income.Apro_Income_Info%TYPE,
        p_Apro_Income_Usage   IN     Apr_Other_Income.Apro_Income_Usage%TYPE,
        p_Apro_Aprp           IN     Apr_Other_Income.Apro_Aprp%TYPE,
        p_New_Id                 OUT Apr_Other_Income.Apro_Id%TYPE)
    IS
    BEGIN
        IF p_Apro_Id IS NULL OR p_Apro_Id < 0
        THEN
            INSERT INTO Apr_Other_Income (Apro_Apr,
                                          Apro_Tp,
                                          Apro_Income_Info,
                                          Apro_Income_Usage,
                                          Apro_Aprp,
                                          History_Status)
                 VALUES (p_Apro_Apr,
                         p_Apro_Tp,
                         p_Apro_Income_Info,
                         p_Apro_Income_Usage,
                         p_Apro_Aprp,
                         'A')
              RETURNING Apro_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apro_Id;

            UPDATE Apr_Other_Income
               SET Apro_Apr = p_Apro_Apr,
                   Apro_Tp = p_Apro_Tp,
                   Apro_Income_Info = p_Apro_Income_Info,
                   Apro_Income_Usage = p_Apro_Income_Usage,
                   Apro_Aprp = p_Apro_Aprp
             WHERE Apro_Id = p_Apro_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Other_Income (
        p_Apro_Id   IN Apr_Other_Income.Apro_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Other_Income o
           SET o.History_Status = 'H'
         WHERE o.Apro_Id = p_Apro_Id;
    END;

    PROCEDURE Save_Apr_Spending (
        p_Aprs_Id            IN     Apr_Spending.Aprs_Id%TYPE,
        p_Aprs_Apr           IN     Apr_Spending.Aprs_Apr%TYPE,
        p_Aprs_Ln_Initials   IN     Apr_Spending.Aprs_Ln_Initials%TYPE,
        p_Aprs_Tp            IN     Apr_Spending.Aprs_Tp%TYPE,
        p_Aprs_Cost_Type     IN     Apr_Spending.Aprs_Cost_Type%TYPE,
        p_Aprs_Cost          IN     Apr_Spending.Aprs_Cost%TYPE,
        p_Aprs_Dt            IN     Apr_Spending.Aprs_Dt%TYPE,
        p_Aprs_Aprp          IN     Apr_Spending.Aprs_Aprp%TYPE,
        p_New_Id                OUT Apr_Spending.Aprs_Id%TYPE)
    IS
    BEGIN
        IF p_Aprs_Id IS NULL OR p_Aprs_Id < 0
        THEN
            INSERT INTO Apr_Spending (Aprs_Apr,
                                      Aprs_Ln_Initials,
                                      Aprs_Tp,
                                      Aprs_Cost_Type,
                                      Aprs_Cost,
                                      Aprs_Dt,
                                      Aprs_Aprp,
                                      History_Status)
                 VALUES (p_Aprs_Apr,
                         p_Aprs_Ln_Initials,
                         p_Aprs_Tp,
                         p_Aprs_Cost_Type,
                         p_Aprs_Cost,
                         p_Aprs_Dt,
                         p_Aprs_Aprp,
                         'A')
              RETURNING Aprs_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aprs_Id;

            UPDATE Apr_Spending
               SET Aprs_Apr = p_Aprs_Apr,
                   Aprs_Ln_Initials = p_Aprs_Ln_Initials,
                   Aprs_Tp = p_Aprs_Tp,
                   Aprs_Cost_Type = p_Aprs_Cost_Type,
                   Aprs_Cost = p_Aprs_Cost,
                   Aprs_Dt = p_Aprs_Dt,
                   Aprs_Aprp = p_Aprs_Aprp
             WHERE Aprs_Id = p_Aprs_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Spending (p_Aprs_Id IN Apr_Spending.Aprs_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Spending s
           SET s.History_Status = 'H'
         WHERE s.Aprs_Id = p_Aprs_Id;
    END;

    PROCEDURE Save_Apr_Vehicle (
        p_Aprv_Id                IN     Apr_Vehicle.Aprv_Id%TYPE,
        p_Aprv_Apr               IN     Apr_Vehicle.Aprv_Apr%TYPE,
        p_Aprv_Ln_Initials       IN     Apr_Vehicle.Aprv_Ln_Initials%TYPE,
        p_Aprv_Car_Brand         IN     Apr_Vehicle.Aprv_Car_Brand%TYPE,
        p_Aprv_License_Plate     IN     Apr_Vehicle.Aprv_License_Plate%TYPE,
        p_Aprv_Production_Year   IN     Apr_Vehicle.Aprv_Production_Year%TYPE,
        p_Aprv_Is_Social_Car     IN     Apr_Vehicle.Aprv_Is_Social_Car%TYPE,
        p_Aprv_Aprp              IN     Apr_Vehicle.Aprv_Aprp%TYPE,
        p_New_Id                    OUT Apr_Vehicle.Aprv_Id%TYPE)
    IS
    BEGIN
        IF p_Aprv_Id IS NULL OR p_Aprv_Id < 0
        THEN
            INSERT INTO Apr_Vehicle (Aprv_Apr,
                                     Aprv_Ln_Initials,
                                     Aprv_Car_Brand,
                                     Aprv_License_Plate,
                                     Aprv_Production_Year,
                                     Aprv_Is_Social_Car,
                                     Aprv_Aprp,
                                     History_Status)
                 VALUES (p_Aprv_Apr,
                         p_Aprv_Ln_Initials,
                         p_Aprv_Car_Brand,
                         p_Aprv_License_Plate,
                         p_Aprv_Production_Year,
                         p_Aprv_Is_Social_Car,
                         p_Aprv_Aprp,
                         'A')
              RETURNING Aprv_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Aprv_Id;

            UPDATE Apr_Vehicle
               SET Aprv_Apr = p_Aprv_Apr,
                   Aprv_Ln_Initials = p_Aprv_Ln_Initials,
                   Aprv_Car_Brand = p_Aprv_Car_Brand,
                   Aprv_License_Plate = p_Aprv_License_Plate,
                   Aprv_Production_Year = p_Aprv_Production_Year,
                   Aprv_Is_Social_Car = p_Aprv_Is_Social_Car,
                   Aprv_Aprp = p_Aprv_Aprp
             WHERE Aprv_Id = p_Aprv_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Vehicle (p_Aprv_Id IN Apr_Vehicle.Aprv_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Vehicle v
           SET v.History_Status = 'H'
         WHERE v.Aprv_Id = p_Aprv_Id;
    END;

    PROCEDURE Save_Apr_Alimony (
        p_Apra_Id                IN     Apr_Alimony.Apra_Id%TYPE,
        p_Apra_Apr               IN     Apr_Alimony.Apra_Apr%TYPE,
        p_Apra_Payer             IN     Apr_Alimony.Apra_Payer%TYPE,
        p_Apra_Sum               IN     Apr_Alimony.Apra_Sum%TYPE,
        p_Apra_Is_Have_Arrears   IN     Apr_Alimony.Apra_Is_Have_Arrears%TYPE,
        p_Apra_Aprp              IN     Apr_Alimony.Apra_Aprp%TYPE,
        p_New_Id                    OUT Apr_Alimony.Apra_Id%TYPE)
    IS
    BEGIN
        IF p_Apra_Id IS NULL OR p_Apra_Id < 0
        THEN
            INSERT INTO Apr_Alimony (Apra_Apr,
                                     Apra_Payer,
                                     Apra_Sum,
                                     Apra_Is_Have_Arrears,
                                     Apra_Aprp,
                                     History_Status)
                 VALUES (p_Apra_Apr,
                         p_Apra_Payer,
                         p_Apra_Sum,
                         p_Apra_Is_Have_Arrears,
                         p_Apra_Aprp,
                         'A')
              RETURNING Apra_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Apra_Id;

            UPDATE Apr_Alimony a
               SET Apra_Apr = p_Apra_Apr,
                   Apra_Payer = p_Apra_Payer,
                   Apra_Sum = p_Apra_Sum,
                   Apra_Is_Have_Arrears = p_Apra_Is_Have_Arrears,
                   Apra_Aprp = p_Apra_Aprp
             WHERE a.Apra_Id = p_Apra_Id;
        END IF;
    END;

    PROCEDURE Delete_Apr_Alimony (p_Apra_Id IN Apr_Alimony.Apra_Id%TYPE)
    IS
    BEGIN
        UPDATE Apr_Alimony s
           SET s.History_Status = 'H'
         WHERE s.Apra_Id = p_Apra_Id;
    END;

    /*
      PROCEDURE Write_Log(p_Apl_Ap      IN Ap_Log.Apl_Ap%TYPE,
                          p_Apl_Hs      IN Ap_Log.Apl_Hs%TYPE,
                          p_Apl_St      IN Ap_Log.Apl_St%TYPE,
                          p_Apl_Message IN Ap_Log.Apl_Message%TYPE,
                          p_Apl_Tp      IN Ap_Log.Apl_Tp%TYPE := NULL) IS
      BEGIN
        IF p_Apl_Hs IS NULL THEN raise_application_error(-20000, 'vano>>программист прикладной функции забыл сгенерировать сессию историческую! Клемить его позором'); END IF;
        INSERT INTO Ap_Log
          (Apl_Ap,
           Apl_Hs,
           Apl_St,
           Apl_Message,
           Apl_Tp)
        VALUES
          (p_Apl_Ap,
           p_Apl_Hs,
           p_Apl_St,
           p_Apl_Message,
           Nvl(p_Apl_Tp, 'SYS'));
      END;
    */
    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL)
    IS
    BEGIN
        IF p_Apl_Hs IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'vano>>программист прикладной функции забыл сгенерировать сессию историческую! Клемить его позором');
        END IF;

        INSERT INTO Ap_Log (Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_Message,
                            Apl_St_Old,
                            Apl_Tp)
             VALUES (p_Apl_Ap,
                     p_Apl_Hs,
                     p_Apl_St,
                     p_Apl_Message,
                     p_Apl_St_Old,
                     NVL (p_Apl_Tp, 'SYS'));
    END;

    -- створення дублікату звернення
    PROCEDURE Duplicate_Appeal (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER)
    IS
        l_Appeal                Appeal%ROWTYPE;
        l_Aps                   Tc_Ap_Service := Tc_Ap_Service ();
        l_App                   Tc_Ap_Person := Tc_Ap_Person ();
        l_Id                    NUMBER;
        l_Aps_Map               Tc_Map := Tc_Map ();
        l_App_Map               Tc_Map := Tc_Map ();

        l_Apd                   Tc_Ap_Document := Tc_Ap_Document ();
        l_Apda                  Tc_Ap_Document_Attr := Tc_Ap_Document_Attr ();
        l_Apd_Map               Tc_Map := Tc_Map ();
        l_Ap_Payment            Tc_Ap_Payment := Tc_Ap_Payment ();

        l_Ap_Declaration        Ap_Declaration%ROWTYPE;
        l_Apr_Id_Old            NUMBER;
        l_Apr_Id                NUMBER;

        l_Apr_Person            Tc_Apr_Person := Tc_Apr_Person ();
        l_Aprp_Map              Tc_Map := Tc_Map ();

        l_Apr_Income            Tc_Apr_Income := Tc_Apr_Income ();
        l_Apr_Living_Quarters   Tc_Apr_Living_Quarters
                                    := Tc_Apr_Living_Quarters ();
        l_Apr_Land_Plot         Tc_Apr_Land_Plot := Tc_Apr_Land_Plot ();
        l_Apr_Other_Income      Tc_Apr_Other_Income := Tc_Apr_Other_Income ();
        l_Apr_Vehicle           Tc_Apr_Vehicle := Tc_Apr_Vehicle ();
        l_Apr_Spending          Tc_Apr_Spending := Tc_Apr_Spending ();
    BEGIN
        SELECT *
          INTO l_Appeal
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        l_Appeal.Ap_Id := Sq_Id_Appeal.NEXTVAL;
        l_Appeal.Ap_Vf := NULL;
        l_Appeal.Ap_St := 'J';
        l_Appeal.Ap_Reg_Dt := TRUNC (SYSDATE);
        l_Appeal.Ap_Create_Dt := SYSDATE;
        l_Appeal.Ap_Num := Gen_Appeal_Num (l_Appeal.Ap_Id, l_Appeal.Ap_Tp);
        l_Appeal.Com_Wu := Tools.Getcurrwu;
        l_Appeal.Com_Org :=
            Uss_Visit_Context.Getcontext (Uss_Visit_Context.Gorg);
        l_appeal.ap_src := 'USS';
        l_appeal.ap_ext_ident2 := p_ap_id;

        INSERT INTO Appeal
             VALUES l_Appeal
          RETURNING Ap_Id
               INTO p_New_Ap;

        -- копіювання послуг
        SELECT *
          BULK COLLECT INTO l_Aps
          FROM Ap_Service t
         WHERE t.Aps_Ap = p_Ap_Id AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Aps.FIRST, 0) .. NVL (l_Aps.LAST, -1)
        LOOP
            l_Aps_Map.EXTEND;
            l_Aps_Map (Xx).Old_Id := l_Aps (Xx).Aps_Id;
            l_Aps (Xx).Aps_Id := NULL;
            l_Aps (Xx).Aps_Ap := p_New_Ap;
            l_Aps (Xx).Aps_st := 'R';

            INSERT INTO Ap_Service
                 VALUES l_Aps (Xx)
              RETURNING Aps_Id
                   INTO l_Id;

            l_Aps_Map (Xx).New_Id := l_Id;
        END LOOP;

        -- копіювання учасників
        SELECT *
          BULK COLLECT INTO l_App
          FROM Ap_Person t
         WHERE t.App_Ap = p_Ap_Id AND t.History_Status = 'A';

        FOR Xx IN NVL (l_App.FIRST, 0) .. NVL (l_App.LAST, -1)
        LOOP
            l_App_Map.EXTEND;
            l_App_Map (Xx).Old_Id := l_App (Xx).App_Id;
            l_App (Xx).App_Id := NULL;
            l_App (Xx).App_Vf := NULL;
            l_App (Xx).App_Ap := p_New_Ap;

            INSERT INTO Ap_Person
                 VALUES l_App (Xx)
              RETURNING App_Id
                   INTO l_Id;

            l_App_Map (Xx).New_Id := l_Id;
        END LOOP;

        -- копіювання документів
        SELECT *
          BULK COLLECT INTO l_Apd
          FROM Ap_Document t
         WHERE     t.Apd_Ap = p_Ap_Id
               AND t.History_Status = 'A'
               AND t.Apd_Ndt != 730;

        FOR Xx IN NVL (l_Apd.FIRST, 0) .. NVL (l_Apd.LAST, -1)
        LOOP
            l_Apd_Map.EXTEND;
            l_Apd_Map (Xx).Old_Id := l_Apd (Xx).Apd_Id;

            SELECT *
              BULK COLLECT INTO l_Apda
              FROM Ap_Document_Attr t
             WHERE t.Apda_Apd = l_Apd (Xx).Apd_Id;

            l_Apd (Xx).Apd_Id := NULL;
            l_Apd (Xx).Apd_Vf := NULL;
            l_Apd (Xx).Apd_Ap := p_New_Ap;

            SELECT MAX (New_Id)
              INTO l_Id
              FROM TABLE (l_App_Map)
             WHERE Old_Id = l_Apd (Xx).Apd_App;

            l_Apd (Xx).Apd_App := l_Id;

            IF l_Apd (Xx).Apd_Aps IS NOT NULL
            THEN
                SELECT MAX (New_Id)
                  INTO l_Id
                  FROM TABLE (l_Aps_Map)
                 WHERE Old_Id = l_Apd (Xx).Apd_Aps;

                l_Apd (Xx).Apd_Aps := l_Id;
            END IF;

            /*
                  SELECT t.aps_id
                    INTO l_Apd(Xx).Apd_aps
                  FROM Ap_Service t
                  WHERE t.Aps_Ap = p_Ap_Id
                    AND t.History_Status = 'A'
                    AND t.Aps_Nst = ;
            */

            INSERT INTO Ap_Document
                 VALUES l_Apd (Xx)
              RETURNING Apd_Id
                   INTO l_Id;

            l_Apd_Map (Xx).New_Id := l_Id;

            FOR Zz IN NVL (l_Apda.FIRST, 0) .. NVL (l_Apda.LAST, -1)
            LOOP
                l_Apda (Zz).Apda_Id := Sq_Id_Ap_Document_Attr.NEXTVAL;
                l_Apda (Zz).Apda_Ap := p_New_Ap;
                l_Apda (Zz).Apda_Apd := l_Id;

                INSERT INTO Ap_Document_Attr
                     VALUES l_Apda (Zz);
            END LOOP;
        END LOOP;

        -- копіювання способів виплати
        SELECT *
          BULK COLLECT INTO l_Ap_Payment
          FROM Ap_Payment t
         WHERE t.Apm_Ap = p_Ap_Id AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Ap_Payment.FIRST, 0) .. NVL (l_Ap_Payment.LAST, -1)
        LOOP
            l_Ap_Payment (Xx).Apm_Id := NULL;
            l_Ap_Payment (Xx).Apm_Ap := p_New_Ap;

            IF l_Ap_Payment (Xx).Apm_App IS NOT NULL
            THEN
                SELECT MAX (New_Id)
                  INTO l_Id
                  FROM TABLE (l_App_Map)
                 WHERE Old_Id = l_Ap_Payment (Xx).Apm_App;

                l_Ap_Payment (Xx).Apm_App := l_Id;
            END IF;

            IF l_Ap_Payment (Xx).Apm_Aps IS NOT NULL
            THEN
                SELECT MAX (New_Id)
                  INTO l_Id
                  FROM TABLE (l_Aps_Map)
                 WHERE Old_Id = l_Ap_Payment (Xx).Apm_Aps;

                l_Ap_Payment (Xx).Apm_Aps := l_Id;
            END IF;

            INSERT INTO Ap_Payment
                 VALUES l_Ap_Payment (Xx);
        END LOOP;

        -- копіювання декларації --
        ---------------------------
        BEGIN
            SELECT *
              INTO l_Ap_Declaration
              FROM Ap_Declaration t
             WHERE t.Apr_Ap = p_Ap_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF (l_Ap_Declaration.Apr_Id IS NULL)
        THEN
            RETURN;
        END IF;

        l_Apr_Id_Old := l_Ap_Declaration.Apr_Id;
        l_Ap_Declaration.Apr_Id := NULL;
        l_Ap_Declaration.Apr_Vf := NULL;
        l_Ap_Declaration.Apr_Ap := p_New_Ap;

        INSERT INTO Ap_Declaration
             VALUES l_Ap_Declaration
          RETURNING Apr_Id
               INTO l_Apr_Id;

        -- копіювання учасників декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Person
          FROM Apr_Person t
         WHERE t.Aprp_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Apr_Person.FIRST, 0) .. NVL (l_Apr_Person.LAST, -1)
        LOOP
            l_Aprp_Map.EXTEND ();
            l_Aprp_Map (Xx).Old_Id := l_Apr_Person (Xx).Aprp_Id;

            l_Apr_Person (Xx).Aprp_Id := NULL;
            l_Apr_Person (Xx).Aprp_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_App_Map)
             WHERE Old_Id = l_Apr_Person (Xx).Aprp_App;

            l_Apr_Person (Xx).Aprp_App := l_Id;

            INSERT INTO Apr_Person
                 VALUES l_Apr_Person (Xx)
              RETURNING Aprp_Id
                   INTO l_Id;

            l_Aprp_Map (Xx).New_Id := l_Id;
        END LOOP;

        -- копіювання доходу в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Income
          FROM Apr_Income t
         WHERE t.Apri_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Apr_Income.FIRST, 0) .. NVL (l_Apr_Income.LAST, -1)
        LOOP
            l_Apr_Income (Xx).Apri_Id := NULL;
            l_Apr_Income (Xx).Apri_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Income (Xx).Apri_Aprp;

            l_Apr_Income (Xx).Apri_Aprp := l_Id;

            INSERT INTO Apr_Income
                 VALUES l_Apr_Income (Xx);
        END LOOP;

        -- копіювання земельних ділянок в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Land_Plot
          FROM Apr_Land_Plot t
         WHERE t.Aprt_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Land_Plot.FIRST, 0) ..
               NVL (l_Apr_Land_Plot.LAST, -1)
        LOOP
            l_Apr_Land_Plot (Xx).Aprt_Id := NULL;
            l_Apr_Land_Plot (Xx).Aprt_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Land_Plot (Xx).Aprt_Aprp;

            l_Apr_Land_Plot (Xx).Aprt_Aprp := l_Id;

            INSERT INTO Apr_Land_Plot
                 VALUES l_Apr_Land_Plot (Xx);
        END LOOP;

        -- копіювання житла в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Living_Quarters
          FROM Apr_Living_Quarters t
         WHERE t.Aprl_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Living_Quarters.FIRST, 0) ..
               NVL (l_Apr_Living_Quarters.LAST, -1)
        LOOP
            l_Apr_Living_Quarters (Xx).Aprl_Id := NULL;
            l_Apr_Living_Quarters (Xx).Aprl_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Living_Quarters (Xx).Aprl_Aprp;

            l_Apr_Living_Quarters (Xx).Aprl_Aprp := l_Id;

            INSERT INTO Apr_Living_Quarters
                 VALUES l_Apr_Living_Quarters (Xx);
        END LOOP;

        -- копіювання інших доходів в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Other_Income
          FROM Apr_Other_Income t
         WHERE t.Apro_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Other_Income.FIRST, 0) ..
               NVL (l_Apr_Other_Income.LAST, -1)
        LOOP
            l_Apr_Other_Income (Xx).Apro_Id := NULL;
            l_Apr_Other_Income (Xx).Apro_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Other_Income (Xx).Apro_Aprp;

            l_Apr_Other_Income (Xx).Apro_Aprp := l_Id;

            INSERT INTO Apr_Other_Income
                 VALUES l_Apr_Other_Income (Xx);
        END LOOP;

        -- копіювання витрат в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Spending
          FROM Apr_Spending t
         WHERE t.Aprs_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Spending.FIRST, 0) .. NVL (l_Apr_Spending.LAST, -1)
        LOOP
            l_Apr_Spending (Xx).Aprs_Id := NULL;
            l_Apr_Spending (Xx).Aprs_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Spending (Xx).Aprs_Aprp;

            l_Apr_Spending (Xx).Aprs_Aprp := l_Id;

            INSERT INTO Apr_Spending
                 VALUES l_Apr_Spending (Xx);
        END LOOP;

        -- копіювання транспорту в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Vehicle
          FROM Apr_Vehicle t
         WHERE t.Aprv_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Vehicle.FIRST, 0) .. NVL (l_Apr_Vehicle.LAST, -1)
        LOOP
            l_Apr_Vehicle (Xx).Aprv_Id := NULL;
            l_Apr_Vehicle (Xx).Aprv_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Vehicle (Xx).Aprv_Aprp;

            l_Apr_Vehicle (Xx).Aprv_Aprp := l_Id;

            INSERT INTO Apr_Vehicle
                 VALUES l_Apr_Vehicle (Xx);
        END LOOP;
    END;

    -- створення дублікату звернення для ANF з Z + ANF
    PROCEDURE Duplicate_Appeal_ANF (p_Ap_Id IN NUMBER, p_New_Ap OUT NUMBER)
    IS
        l_Appeal                Appeal%ROWTYPE;
        l_Id                    NUMBER;

        l_Ap_Declaration        Ap_Declaration%ROWTYPE;
        l_Apr_Id_Old            NUMBER;
        l_Apr_Id                NUMBER;

        l_Apr_Person            Tc_Apr_Person := Tc_Apr_Person ();
        l_Aprp_Map              Tc_Map := Tc_Map ();

        l_Apr_Income            Tc_Apr_Income := Tc_Apr_Income ();
        l_Apr_Living_Quarters   Tc_Apr_Living_Quarters
                                    := Tc_Apr_Living_Quarters ();
        l_Apr_Land_Plot         Tc_Apr_Land_Plot := Tc_Apr_Land_Plot ();
        l_Apr_Other_Income      Tc_Apr_Other_Income := Tc_Apr_Other_Income ();
        l_Apr_Vehicle           Tc_Apr_Vehicle := Tc_Apr_Vehicle ();
        l_Apr_Spending          Tc_Apr_Spending := Tc_Apr_Spending ();
        l_cnt                   NUMBER;
    BEGIN
        -- Перевіримо, чи то копіюємо
        -- Послуга
        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = p_Ap_Id
               AND s.History_Status = 'A'
               AND s.aps_nst = 275;

        IF l_Cnt = 0
        THEN
            Raise_Application_Error (
                -20000,
                   'Не дозволена створювати звернення на другого батька-вихователя, якщо не вказано послугу '
                || '"Соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування, грошове забезпечення батькам-вихователям і прийомним батькам"!');
        END IF;

        -- Заявитель
        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.History_Status = 'A'
               AND p.app_tp = 'Z';

        IF l_Cnt = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Не дозволена створювати звернення на другого батька-вихователя, якщо не вказано "Заявитель"!');
        END IF;

        -- Другий батько-вихователь
        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.History_Status = 'A'
               AND p.app_tp = 'ANF';

        IF l_Cnt = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Помилка! Створити звернення на іншого батька-вихователя немає можливості, так як у блоці "Учасники звернення" не вказаний учасник з типом "Інший батько-вихователь"');
        END IF;


        SELECT *
          INTO l_Appeal
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        l_Appeal.Ap_Id := Sq_Id_Appeal.NEXTVAL;
        l_Appeal.Ap_Vf := NULL;
        l_Appeal.Ap_St := 'J';
        --l_Appeal.Ap_Reg_Dt := Trunc(SYSDATE);
        l_Appeal.Ap_Create_Dt := SYSDATE;
        l_Appeal.Ap_Num := Gen_Appeal_Num (l_Appeal.Ap_Id, l_Appeal.Ap_Tp);
        l_Appeal.Com_Wu := Tools.Getcurrwu;
        l_Appeal.Com_Org :=
            NVL (Uss_Visit_Context.Getcontext (Uss_Visit_Context.Gorg),
                 l_Appeal.Com_Org);
        l_appeal.ap_src := 'USS';
        l_appeal.ap_ap_main := p_ap_id;

        INSERT INTO Appeal
             VALUES l_Appeal
          RETURNING Ap_Id
               INTO p_New_Ap;

        -- Почистимо буфер
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        -- копіювання послуг
        INSERT INTO tmp_work_set1 (x_id1, x_id2, x_string1)
            SELECT s.aps_id, id_ap_service (0), 'APS'
              FROM Ap_Service s
             WHERE     s.Aps_Ap = p_Ap_Id
                   AND s.History_Status = 'A'
                   AND s.aps_nst = 275;

        INSERT INTO Ap_Service (Aps_Id,
                                Aps_Nst,
                                Aps_Ap,
                                Aps_St,
                                History_Status)
            SELECT 0,
                   Aps_Nst,
                   p_New_Ap,
                   Aps_St,
                   History_Status
              FROM Ap_Service  aps
                   JOIN tmp_work_set1 t ON t.x_id1 = aps.aps_id
             WHERE x_string1 = 'APS';

        -- копіювання учасників
        INSERT INTO tmp_work_set1 (x_id1, x_id2, x_string1)
            SELECT t.app_id, Id_Ap_Person (0), 'APP'
              FROM Ap_Person t
             WHERE     t.App_Ap = p_Ap_Id
                   AND t.History_Status = 'A'
                   AND t.app_tp != 'Z';

        INSERT INTO Ap_Person (App_Id,
                               App_Ap,
                               App_Tp,
                               App_Inn,
                               App_Ndt,
                               App_Doc_Num,
                               App_Fn,
                               App_Mn,
                               App_Ln,
                               App_Esr_Num,
                               App_Gender,
                               History_Status,
                               App_Sc)
            SELECT t.x_id2,
                   p_New_Ap,
                   App_Tp,
                   App_Inn,
                   App_Ndt,
                   App_Doc_Num,
                   App_Fn,
                   App_Mn,
                   App_Ln,
                   App_Esr_Num,
                   App_Gender,
                   History_Status,
                   App_Sc
              FROM Ap_Person app JOIN tmp_work_set1 t ON t.x_id1 = app.app_id
             WHERE x_string1 = 'APP';

        -- копіювання документів
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_string1)
            SELECT apd.apd_id,
                   id_ap_document (0),
                   t.x_id2,
                   'APD'
              FROM Ap_Document  apd
                   LEFT JOIN tmp_work_set1 t ON t.x_id1 = apd.apd_app
             WHERE apd.Apd_Ap = p_Ap_Id AND apd.History_Status = 'A';

        -- це окрема хімія - перекидаємо заявку
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_string1)
            SELECT apd.apd_id,
                   id_ap_document (0),
                   (SELECT MAX (app.app_id)
                      FROM ap_person app
                     WHERE app.app_ap = p_new_Ap AND app.app_tp = 'ANF'),
                   'APD'
              FROM Ap_Document apd
             WHERE     apd.Apd_Ap = p_Ap_Id
                   AND apd.apd_ndt = 600
                   AND apd.History_Status = 'A';

        INSERT INTO Ap_Document (Apd_Id,
                                 Apd_Ap,
                                 Apd_Ndt,
                                 Apd_Doc,
                                 Apd_App,
                                 History_Status,
                                 Apd_Dh)
            SELECT t.x_id2,
                   p_New_Ap,
                   Apd_Ndt,
                   Apd_Doc,
                   t.x_id3,
                   History_Status,
                   Apd_Dh
              FROM Ap_Document  apd
                   JOIN tmp_work_set1 t ON t.x_id1 = apd.apd_id
             WHERE x_string1 = 'APD';

        INSERT INTO Ap_Document_Attr (Apda_Id,
                                      Apda_Ap,
                                      Apda_Apd,
                                      Apda_Nda,
                                      Apda_Val_Int,
                                      Apda_Val_Dt,
                                      Apda_Val_String,
                                      Apda_Val_Id,
                                      Apda_Val_Sum,
                                      History_Status)
            SELECT 0,
                   p_New_Ap,
                   t.x_id2,
                   Apda_Nda,
                   Apda_Val_Int,
                   Apda_Val_Dt,
                   Apda_Val_String,
                   Apda_Val_Id,
                   Apda_Val_Sum,
                   History_Status
              FROM Ap_Document_Attr  apda
                   JOIN tmp_work_set1 t ON t.x_id1 = apda.apda_apd
             WHERE x_string1 = 'APD' AND apda.History_Status = 'A';

        -- копіювання способів виплати
        INSERT INTO Ap_Payment (Apm_Id,
                                Apm_Ap,
                                Apm_Aps,
                                Apm_App,
                                Apm_Kaot,
                                Apm_Nb,
                                Apm_Tp,
                                Apm_Index,
                                Apm_Account,
                                Apm_Need_Account,
                                History_Status,
                                Apm_Street,
                                Apm_Ns,
                                Apm_Building,
                                Apm_Block,
                                Apm_Apartment,
                                Apm_Dppa)
            SELECT 0,
                   p_New_Ap,
                   Apm_Aps,
                   App.x_Id2,
                   Apm_Kaot,
                   Apm_Nb,
                   Apm_Tp,
                   Apm_Index,
                   Apm_Account,
                   Apm_Need_Account,
                   History_Status,
                   Apm_Street,
                   Apm_Ns,
                   Apm_Building,
                   Apm_Block,
                   Apm_Apartment,
                   Apm_Dppa
              FROM Ap_Payment  apm
                   JOIN tmp_work_set1 app
                       ON app.x_id1 = apm.apm_app AND app.x_string1 = 'APP'
                   LEFT JOIN tmp_work_set1 aps
                       ON aps.x_id1 = apm.apm_aps AND aps.x_string1 = 'APS'
             WHERE     apm.apm_ap = p_Ap_Id
                   AND (apm.apm_aps IS NULL OR aps.x_id2 IS NOT NULL);

        /*
            SELECT *
              BULK COLLECT
              INTO l_Ap_Payment
              FROM Ap_Payment t
             WHERE t.Apm_Ap = p_Ap_Id
               AND t.History_Status = 'A';

            FOR Xx IN Nvl(l_Ap_Payment.First, 0) .. Nvl(l_Ap_Payment.Last, -1)
            LOOP
              l_Ap_Payment(Xx).Apm_Id := NULL;
              l_Ap_Payment(Xx).Apm_Ap := p_New_Ap;

              IF l_Ap_Payment(Xx).Apm_App IS NOT NULL THEN
                SELECT MAX(New_Id)
                  INTO l_Id
                  FROM TABLE(l_App_Map)
                 WHERE Old_Id = l_Ap_Payment(Xx).Apm_App;
                l_Ap_Payment(Xx).Apm_App := l_Id;
              END IF;

              IF l_Ap_Payment(Xx).Apm_Aps IS NOT NULL THEN
                SELECT MAX(New_Id)
                  INTO l_Id
                  FROM TABLE(l_Aps_Map)
                 WHERE Old_Id = l_Ap_Payment(Xx).Apm_Aps;
                l_Ap_Payment(Xx).Apm_Aps := l_Id;
              END IF;

              INSERT INTO Ap_Payment
              VALUES l_Ap_Payment
                (Xx);
            END LOOP;
        */
        -- копіювання декларації --
        ---------------------------
        BEGIN
            SELECT *
              INTO l_Ap_Declaration
              FROM Ap_Declaration t
             WHERE t.Apr_Ap = p_Ap_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF (l_Ap_Declaration.Apr_Id IS NULL)
        THEN
            RETURN;
        END IF;

        l_Apr_Id_Old := l_Ap_Declaration.Apr_Id;
        l_Ap_Declaration.Apr_Id := NULL;
        l_Ap_Declaration.Apr_Vf := NULL;
        l_Ap_Declaration.Apr_Ap := p_New_Ap;

        INSERT INTO Ap_Declaration
             VALUES l_Ap_Declaration
          RETURNING Apr_Id
               INTO l_Apr_Id;

        -- копіювання учасників декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Person
          FROM Apr_Person t
         WHERE t.Aprp_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Apr_Person.FIRST, 0) .. NVL (l_Apr_Person.LAST, -1)
        LOOP
            l_Aprp_Map.EXTEND ();
            l_Aprp_Map (Xx).Old_Id := l_Apr_Person (Xx).Aprp_Id;

            l_Apr_Person (Xx).Aprp_Id := NULL;
            l_Apr_Person (Xx).Aprp_Apr := l_Apr_Id;

            SELECT x_id2
              INTO l_Apr_Person (Xx).Aprp_App
              FROM tmp_work_set1 t
             WHERE t.x_id1 = l_Apr_Person (Xx).Aprp_App AND x_string1 = 'APP';

            INSERT INTO Apr_Person
                 VALUES l_Apr_Person (Xx)
              RETURNING Aprp_Id
                   INTO l_Id;

            l_Aprp_Map (Xx).New_Id := l_Id;
        END LOOP;

        -- копіювання доходу в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Income
          FROM Apr_Income t
         WHERE t.Apri_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx IN NVL (l_Apr_Income.FIRST, 0) .. NVL (l_Apr_Income.LAST, -1)
        LOOP
            l_Apr_Income (Xx).Apri_Id := NULL;
            l_Apr_Income (Xx).Apri_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Income (Xx).Apri_Aprp;

            l_Apr_Income (Xx).Apri_Aprp := l_Id;

            INSERT INTO Apr_Income
                 VALUES l_Apr_Income (Xx);
        END LOOP;

        -- копіювання земельних ділянок в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Land_Plot
          FROM Apr_Land_Plot t
         WHERE t.Aprt_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Land_Plot.FIRST, 0) ..
               NVL (l_Apr_Land_Plot.LAST, -1)
        LOOP
            l_Apr_Land_Plot (Xx).Aprt_Id := NULL;
            l_Apr_Land_Plot (Xx).Aprt_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Land_Plot (Xx).Aprt_Aprp;

            l_Apr_Land_Plot (Xx).Aprt_Aprp := l_Id;

            INSERT INTO Apr_Land_Plot
                 VALUES l_Apr_Land_Plot (Xx);
        END LOOP;

        -- копіювання житла в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Living_Quarters
          FROM Apr_Living_Quarters t
         WHERE t.Aprl_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Living_Quarters.FIRST, 0) ..
               NVL (l_Apr_Living_Quarters.LAST, -1)
        LOOP
            l_Apr_Living_Quarters (Xx).Aprl_Id := NULL;
            l_Apr_Living_Quarters (Xx).Aprl_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Living_Quarters (Xx).Aprl_Aprp;

            l_Apr_Living_Quarters (Xx).Aprl_Aprp := l_Id;

            INSERT INTO Apr_Living_Quarters
                 VALUES l_Apr_Living_Quarters (Xx);
        END LOOP;

        -- копіювання інших доходів в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Other_Income
          FROM Apr_Other_Income t
         WHERE t.Apro_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Other_Income.FIRST, 0) ..
               NVL (l_Apr_Other_Income.LAST, -1)
        LOOP
            l_Apr_Other_Income (Xx).Apro_Id := NULL;
            l_Apr_Other_Income (Xx).Apro_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Other_Income (Xx).Apro_Aprp;

            l_Apr_Other_Income (Xx).Apro_Aprp := l_Id;

            INSERT INTO Apr_Other_Income
                 VALUES l_Apr_Other_Income (Xx);
        END LOOP;

        -- копіювання витрат в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Spending
          FROM Apr_Spending t
         WHERE t.Aprs_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Spending.FIRST, 0) .. NVL (l_Apr_Spending.LAST, -1)
        LOOP
            l_Apr_Spending (Xx).Aprs_Id := NULL;
            l_Apr_Spending (Xx).Aprs_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Spending (Xx).Aprs_Aprp;

            l_Apr_Spending (Xx).Aprs_Aprp := l_Id;

            INSERT INTO Apr_Spending
                 VALUES l_Apr_Spending (Xx);
        END LOOP;

        -- копіювання транспорту в декларації
        SELECT *
          BULK COLLECT INTO l_Apr_Vehicle
          FROM Apr_Vehicle t
         WHERE t.Aprv_Apr = l_Apr_Id_Old AND t.History_Status = 'A';

        FOR Xx
            IN NVL (l_Apr_Vehicle.FIRST, 0) .. NVL (l_Apr_Vehicle.LAST, -1)
        LOOP
            l_Apr_Vehicle (Xx).Aprv_Id := NULL;
            l_Apr_Vehicle (Xx).Aprv_Apr := l_Apr_Id;

            SELECT New_Id
              INTO l_Id
              FROM TABLE (l_Aprp_Map)
             WHERE Old_Id = l_Apr_Vehicle (Xx).Aprv_Aprp;

            l_Apr_Vehicle (Xx).Aprv_Aprp := l_Id;

            INSERT INTO Apr_Vehicle
                 VALUES l_Apr_Vehicle (Xx);
        END LOOP;
    END;
END Api$appeal;
/