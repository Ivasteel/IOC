/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT
IS
    -- Author  : OLEKSII
    -- Created : 15.05.2023 11:54:05

    Pkg             CONSTANT VARCHAR2 (50) := 'API$ACT';

    g_Ap_Id                  Appeal.Ap_Id%TYPE;
    g_At_Id                  Act.At_Id%TYPE;
    g_At_Src_Id              Act.At_Id%TYPE;
    g_At_Num                 Act.At_Num%TYPE;
    g_At_Sc                  Act.At_Sc%TYPE;
    g_At_St                  Act.At_St%TYPE;
    g_At_St_Old              Act.At_St%TYPE;
    g_Atl_Message            At_Log.Atl_Message%TYPE;
    g_Message                At_Log.Atl_Message%TYPE;
    g_Hs                     NUMBER;

    TYPE r_Act IS RECORD
    (
        At_Pc                 Act.At_Pc%TYPE,
        At_Dt                 TIMESTAMP,
        At_Org                Act.At_Org%TYPE,
        At_Sc                 Act.At_Sc%TYPE,
        At_Rnspm              Act.At_Rnspm%TYPE,
        At_Ap                 Act.At_Ap%TYPE,
        At_Case_Class         Act.At_Case_Class%TYPE,
        Ac_Action_Start_Dt    TIMESTAMP,
        At_Action_Stop_Dt     TIMESTAMP,
        At_Notes              Act.At_Notes%TYPE,
        At_Family_Info        Act.At_Family_Info%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Conclusion_Tp      Act.At_Conclusion_Tp%TYPE,
        At_Form_Tp            Act.At_Form_Tp%TYPE
    );

    TYPE r_At_Person IS RECORD
    (
        Atp_Id                 At_Person.Atp_Id%TYPE,
        Atp_Sc                 At_Person.Atp_Sc%TYPE,
        Atp_Fn                 At_Person.Atp_Fn%TYPE,
        Atp_Mn                 At_Person.Atp_Mn%TYPE,
        Atp_Ln                 At_Person.Atp_Ln%TYPE,
        Atp_Birth_Dt           TIMESTAMP,
        Atp_Relation_Tp        At_Person.Atp_Relation_Tp%TYPE,
        Atp_Is_Disabled        At_Person.Atp_Is_Disabled%TYPE,
        Atp_Is_Capable         At_Person.Atp_Is_Capable%TYPE,
        Atp_Work_Place         At_Person.Atp_Work_Place%TYPE,
        Atp_Is_Adr_Matching    At_Person.Atp_Is_Adr_Matching%TYPE,
        Atp_Phone              At_Person.Atp_Phone%TYPE,
        Atp_Live_Address       At_Person.Atp_Live_Address%TYPE,
        Atp_Tp                 At_Person.Atp_Tp%TYPE,
        Atp_App_Tp             At_Person.Atp_App_Tp%TYPE,
        Atp_Fact_Address       At_Person.Atp_Fact_Address%TYPE,
        Atp_Notes              At_Person.Atp_Notes%TYPE,
        Atp_Is_Disordered      At_Person.Atp_Is_Disordered%TYPE,
        Atp_Disorder_Record    At_Person.Atp_Disorder_Record%TYPE,
        Atp_Disable_Record     At_Person.Atp_Disable_Record%TYPE,
        Atp_Capable_Record     At_Person.Atp_Capable_Record%TYPE,
        Atp_Sex                At_Person.Atp_Sex%TYPE,
        Atp_Citizenship        At_Person.Atp_Citizenship%TYPE,
        Atp_Is_Selfservice     At_Person.Atp_Is_Selfservice%TYPE,
        Atp_Is_Vpo             At_Person.Atp_Is_Vpo%TYPE,
        Atp_Is_Orphan          At_Person.Atp_Is_Orphan%TYPE,
        Atp_Email              At_Person.Atp_Email%TYPE,
        Atp_Num                At_Person.Atp_Num%TYPE,
        New_Id                 NUMBER,
        Deleted                NUMBER
    );

    TYPE t_At_Persons IS TABLE OF r_At_Person;

    TYPE r_At_Section IS RECORD
    (
        Ate_Id                  At_Section.Ate_Id%TYPE,
        Ate_Atp                 At_Section.Ate_Atp%TYPE,
        Ate_Atop                At_Section.Ate_Atop%TYPE,
        Ate_Nng                 At_Section.Ate_Nng%TYPE,
        Ate_Chield_Info         At_Section.Ate_Chield_Info%TYPE,
        Ate_Parent_Info         At_Section.Ate_Parent_Info%TYPE,
        Ate_Notes               At_Section.Ate_Notes%TYPE,
        Ate_Indicator_Value1    At_Section.Ate_Indicator_Value1%TYPE,
        Ate_Indicator_Value2    At_Section.Ate_Indicator_Value2%TYPE,
        Features                XMLTYPE
    );

    TYPE t_At_Sections IS TABLE OF r_At_Section;

    TYPE r_At_Section_Feature IS RECORD
    (
        Atef_Id         At_Section_Feature.Atef_Id%TYPE,
        Atef_Nda        At_Section_Feature.Atef_Nda%TYPE,
        Atef_Feature    At_Section_Feature.Atef_Feature%TYPE,
        Atef_Notes      At_Section_Feature.Atef_Notes%TYPE
    );

    TYPE t_At_Section_Features IS TABLE OF r_At_Section_Feature;

    TYPE r_At_Signer IS RECORD
    (
        Ati_Id       At_Signers.Ati_Id%TYPE,
        Ati_Tp       At_Signers.Ati_Tp%TYPE,
        Ati_Sc       At_Signers.Ati_Sc%TYPE,
        Ati_Atp      At_Signers.Ati_Atp%TYPE,
        Ati_Order    At_Signers.Ati_Order%TYPE,
        Ati_Cu       At_Signers.Ati_Cu%TYPE,
        Ati_Atd      At_Signers.Ati_Atd%TYPE,
        Deleted      NUMBER
    );

    TYPE t_At_Signers IS TABLE OF r_At_Signer;

    TYPE r_At_Service IS RECORD
    (
        Ats_Id               At_Service.Ats_Id%TYPE,
        Ats_Nst              At_Service.Ats_Nst%TYPE,
        Ats_Ss_Method        At_Service.Ats_Ss_Method%TYPE,
        Ats_Ss_Address_Tp    At_Service.Ats_Ss_Address_Tp%TYPE,
        Ats_Ss_Address       At_Service.Ats_Ss_Address%TYPE,
        Ats_Tarif_Sum        At_Service.Ats_Tarif_Sum%TYPE,
        Ats_Act_Sum          At_Service.Ats_Act_Sum%TYPE,
        Ats_Rnspa            At_Service.Ats_Rnspa%TYPE,
        Ats_Ss_Term          At_Service.Ats_Ss_Term%TYPE,
        Deleted              NUMBER
    );

    TYPE t_At_Services IS TABLE OF r_At_Service;

    TYPE t_At_Services_Row IS TABLE OF AT_SERVICE%ROWTYPE;

    TYPE r_At_Document_Attr IS RECORD
    (
        Atda_Nda           At_Document_Attr.Atda_Nda%TYPE,
        Atda_Val_Int       At_Document_Attr.Atda_Val_Int%TYPE,
        Atda_Val_Sum       At_Document_Attr.Atda_Val_Sum%TYPE,
        Atda_Val_Id        At_Document_Attr.Atda_Val_Id%TYPE,
        Atda_Val_Dt        At_Document_Attr.Atda_Val_Dt%TYPE,
        Atda_Val_String    At_Document_Attr.Atda_Val_String%TYPE,
        Field              VARCHAR2 (300),
        Deleted            NUMBER
    );

    TYPE t_At_Document_Attrs IS TABLE OF r_At_Document_Attr;

    TYPE r_At_Document IS RECORD
    (
        Atd_Id        At_Document.Atd_Id%TYPE,
        Atd_Ndt       At_Document.Atd_Ndt%TYPE,
        Atd_Ats       At_Document.Atd_Ats%TYPE,
        Atd_Doc       At_Document.Atd_Doc%TYPE,
        Atd_Dh        At_Document.Atd_Dh%TYPE,
        Attributes    XMLTYPE,
        New_Id        NUMBER,
        Deleted       NUMBER
    );

    TYPE t_At_Documents IS TABLE OF r_At_Document;

    TYPE r_At_Living_Conditions
        IS RECORD
    (
        Atlc_Id                   At_Living_Conditions.Atlc_Id%TYPE,
        Atlc_At                   At_Living_Conditions.Atlc_At%TYPE,
        Atlc_Living_Square        At_Living_Conditions.Atlc_Living_Square%TYPE,
        Atlc_Holding_Square       At_Living_Conditions.Atlc_Holding_Square%TYPE,
        Atlc_Housing_Condition    At_Living_Conditions.Atlc_Housing_Condition%TYPE,
        Atlc_Residents_Cnt        At_Living_Conditions.Atlc_Residents_Cnt%TYPE,
        Atlc_Inv_Cnt              At_Living_Conditions.Atlc_Inv_Cnt%TYPE,
        Atlc_Inv_Child_Cnt        At_Living_Conditions.Atlc_Inv_Child_Cnt%TYPE,
        Deleted                   NUMBER
    );

    TYPE t_At_Living_Conditions IS TABLE OF r_At_Living_Conditions;

    TYPE r_At_Other_Spec IS RECORD
    (
        Atop_Id          At_Other_Spec.Atop_Id%TYPE,
        Atop_Fn          At_Other_Spec.Atop_Fn%TYPE,
        Atop_Mn          At_Other_Spec.Atop_Mn%TYPE,
        Atop_Ln          At_Other_Spec.Atop_Ln%TYPE,
        Atop_Phone       At_Other_Spec.Atop_Phone%TYPE,
        Atop_Atip        At_Other_Spec.Atop_Atip%TYPE,
        Atop_Position    At_Other_Spec.Atop_Position%TYPE,
        Atop_Tp          At_Other_Spec.Atop_Tp%TYPE,
        Atop_Order       At_Other_Spec.Atop_Order%TYPE,
        Atop_Notes       At_Other_Spec.Atop_Notes%TYPE,
        Atop_Atp         At_Other_Spec.Atop_Atp%TYPE,
        New_Id           NUMBER,
        Deleted          NUMBER
    );

    TYPE t_At_Other_Spec IS TABLE OF r_At_Other_Spec;

    TYPE r_At_Result IS RECORD
    (
        Atr_Id                  At_Results.Atr_Id%TYPE,
        Atr_At                  At_Results.Atr_AT%TYPE,
        Atr_Nst                 At_Results.Atr_NST%TYPE,
        Atr_Result              At_Results.Atr_RESULT%TYPE,
        Atr_Is_Redirected       At_Results.Atr_IS_REDIRECTED%TYPE,
        Atr_Redirect_Dt         At_Results.Atr_REDIRECT_DT%TYPE,
        Atr_Redirect_Rnspm      At_Results.Atr_REDIRECT_RNSPM%TYPE,
        Atr_Redirect_Else       At_Results.Atr_REDIRECT_ELSE%TYPE,
        Atr_Atip                At_Results.Atr_ATIP%TYPE,
        Atr_Achievment_Level    At_Results.Atr_ACHIEVMENT_LEVEL%TYPE,
        Deleted                 NUMBER
    );

    TYPE t_At_Results IS TABLE OF r_At_Result;

    TYPE r_At_Individual_Plan IS RECORD
    (
        Atip_Id               At_Individual_Plan.Atip_Id%TYPE,
        Atip_Nsa              At_Individual_Plan.Atip_Nsa%TYPE,
        Atip_Place            At_Individual_Plan.Atip_Place%TYPE,
        Atip_Period           At_Individual_Plan.Atip_Period%TYPE,
        Atip_Qnt              At_Individual_Plan.Atip_Qnt%TYPE,
        Atip_Cu               At_Individual_Plan.Atip_Cu%TYPE,
        Atip_Resources        At_Individual_Plan.Atip_Resources%TYPE,
        Atip_Desc             At_Individual_Plan.Atip_Desc%TYPE,
        Atip_St               At_Individual_Plan.Atip_St%TYPE,
        Atip_Exprections      At_Individual_Plan.Atip_Exprections%TYPE,
        Atip_Nst              At_Individual_Plan.Atip_Nst%TYPE,
        Atip_Nsa_Det          At_Individual_Plan.Atip_Nsa_Det%TYPE,
        Atip_Term_Tp          At_Individual_Plan.Atip_Term_Tp%TYPE,
        Atip_Start_Dt         At_Individual_Plan.Atip_Start_Dt%TYPE,
        Atip_Stop_Dt          At_Individual_Plan.Atip_Stop_Dt%TYPE,
        Atip_Order            At_Individual_Plan.Atip_Order%TYPE,
        Atip_Nsa_Hand_Name    At_Individual_Plan.Atip_Nsa_Hand_Name%TYPE,
        New_Id                NUMBER,
        Deleted               NUMBER
    );

    TYPE t_At_Individual_Plan IS TABLE OF r_At_Individual_Plan;


    -- Рішення про відмову
    TYPE r_At_Reject_Info IS RECORD
    (
        Ari_Id     At_Reject_Info.Ari_Id%TYPE,
        Ari_At     At_Reject_Info.Ari_At%TYPE,
        Ari_Nrr    At_Reject_Info.Ari_Nrr%TYPE,
        Ari_Njr    At_Reject_Info.Ari_Njr%TYPE,
        Ari_Ats    At_Reject_Info.Ari_Ats%TYPE,
        Deleted    NUMBER
    );

    TYPE t_At_Reject_Info IS TABLE OF r_At_Reject_Info;

    TYPE t_Nda_Map IS TABLE OF VARCHAR2 (255)
        INDEX BY PLS_INTEGER;

    TYPE r_At_Right_Log IS RECORD
    (
        Arl_Id        NUMBER,
        Arl_Result    VARCHAR2 (10)
    );

    TYPE t_At_Right_Log IS TABLE OF r_At_Right_Log;

    g_At_Service_Init_List   t_At_Services;

    PROCEDURE Write_At_Log (p_Atl_At        At_Log.Atl_At%TYPE,
                            p_Atl_Hs        At_Log.Atl_Hs%TYPE,
                            p_Atl_St        At_Log.Atl_St%TYPE,
                            p_Atl_Message   At_Log.Atl_Message%TYPE,
                            p_Atl_St_Old    At_Log.Atl_St_Old%TYPE,
                            p_Atl_Tp        At_Log.Atl_Tp%TYPE:= 'SYS');

    PROCEDURE Init_Ppnp (p_Rstopss_Id IN NUMBER, p_At_Id OUT NUMBER);

    FUNCTION Get_At_Tp_By_Ap (p_Ap_Id     IN NUMBER,
                              p_Ap_Tp     IN VARCHAR2,
                              p_Ap_Main   IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_At_St_By_Ap (p_At_Tp IN VARCHAR2, p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    --  Функція формування проектів актів про припинення наданя соцпослуг
    --  p_mode 1=з p_ap_id, 2=з таблиці tmp_work_ids
    PROCEDURE Init_Act_By_Appeals (p_Mode           INTEGER,
                                   p_Ap_Id          Appeal.Ap_Id%TYPE,
                                   p_Messages   OUT SYS_REFCURSOR);

    --====================================================--
    -- #: Автоматичне створення аст з Appeals
    --====================================================--
    PROCEDURE Proces_Act_By_Appeals;

    --====================================================--
    -- #: Перевірка умов для наступного статуса
    --====================================================--
    FUNCTION Check_St_Config (Sqlstr VARCHAR2)
        RETURN NUMBER;

    --====================================================--
    -- #: Видалення документів, що було підписано, при поверненні на доопрацювання
    --====================================================--
    PROCEDURE Delete_At_Document_All (p_At_Id IN NUMBER);

    PROCEDURE Delete_At_Document (p_At_Id IN NUMBER, p_ndt_id IN NUMBER);

    --====================================================--
    -- #: Видалення перевірки прав на соц послуги
    --====================================================--
    PROCEDURE Delete_At_Right_Log (p_At_Id IN NUMBER);

    --====================================================--
    -- #: Видалення параметрів відмови по акту на соц послуги
    --====================================================--
    PROCEDURE Delete_At_Reject_Info (p_At_Id IN NUMBER);

    --====================================================--
    --  Set global for act
    --====================================================--
    PROCEDURE Set_g_Ap_and_g_AT (P_at_id NUMBER);

    --====================================================--
    -- #: фнкція перевіряє чи є наступний шаг по бізнес прцесу
    --====================================================--
    FUNCTION Can_Do_Act_Process_Step (p_At_Id     IN NUMBER,
                                      p_Npsc_Tp   IN VARCHAR2 DEFAULT 'UP')
        RETURN NUMBER;

    --====================================================--
    -- #: процедура перевіряє чи є наступний шаг по бізнес прцесу і повертає помилку, якщо немає
    --====================================================--
    PROCEDURE Check_Do_Act_Process_Step (
        p_At_Id     IN NUMBER,
        p_Npsc_Tp   IN VARCHAR2 DEFAULT 'UP');

    --====================================================--
    -- # затвердити act
    --====================================================--
    PROCEDURE Approve_Act (p_At_Id       IN NUMBER,
                           p_At_Src_Id   IN NUMBER DEFAULT NULL);

    --====================================================--
    -- # Поверенення акту на доопрацювання
    --====================================================--
    PROCEDURE Return_Act (p_At_Id NUMBER, p_Reason VARCHAR2);

    --====================================================--
    -- # збереження форми "Рішення про відмову"
    --====================================================--
    PROCEDURE Rejects_Act (p_At_Id IN NUMBER);

    PROCEDURE Rejects_Act (p_At_Id     IN     NUMBER,
                           --p_Clob    IN CLOB,
                           p_St           OUT VARCHAR2,
                           p_St_Name      OUT VARCHAR2);

    --====================================================--
    -- # Поверенення акту на доопрацювання
    --====================================================--
    PROCEDURE Reject_Act_Reject (p_At_Id     IN     NUMBER,
                                 p_St           OUT VARCHAR2,
                                 p_St_Name      OUT VARCHAR2);

    --====================================================--
    -- # Зліяння послуг в "первинная оцінка" та "рішення"
    --====================================================--
    PROCEDURE Merge_Pdsp_Ats (p_Ap_Id NUMBER, p_At_Id NUMBER);

    PROCEDURE Check_At_Tp (p_At_Id IN NUMBER, p_At_Tp IN VARCHAR2);

    PROCEDURE Check_Atp_Z_Exists_Incorrect (p_At_Id IN NUMBER);

    PROCEDURE Recalc_Pdsp_Ats_St (p_At_Id NUMBER);

    FUNCTION Parse (p_Type_Name      IN VARCHAR2,
                    p_Clob_Input     IN BOOLEAN DEFAULT TRUE,
                    p_Has_Root_Tag   IN BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act;

    FUNCTION Parse_Persons (p_Xml IN CLOB)
        RETURN t_At_Persons;

    FUNCTION Parse_Sections (p_Xml IN CLOB)
        RETURN t_At_Sections;

    FUNCTION Parse_Section_Features (p_Xml IN XMLTYPE)
        RETURN t_At_Section_Features;

    FUNCTION Parse_Signers (p_Xml IN CLOB)
        RETURN t_At_Signers;

    FUNCTION Parse_Services (p_Xml IN CLOB)
        RETURN t_At_Services;

    FUNCTION Parse_Attributes (p_Xml IN CLOB)
        RETURN t_At_Document_Attrs;

    FUNCTION Parse_Living_Conditions (p_Xml IN CLOB)
        RETURN t_At_Living_Conditions;

    FUNCTION Parse_Other_Spec (p_Xml IN CLOB)
        RETURN t_At_Other_Spec;

    FUNCTION Parse_Individual_Plan (p_Xml IN CLOB)
        RETURN t_At_Individual_Plan;

    FUNCTION Parse_At_Results (p_Xml IN CLOB)
        RETURN t_At_Results;

    FUNCTION Parse_Right_Log (p_Xml IN CLOB)
        RETURN t_At_Right_Log;

    FUNCTION Parse_Documents (p_Xml IN CLOB)
        RETURN t_At_Documents;

    FUNCTION Parse_Attributes (p_Xml IN XMLTYPE)
        RETURN Api$act.t_At_Document_Attrs;

    FUNCTION Parse_Reject_Info (p_Xml IN CLOB)
        RETURN t_At_Reject_Info;

    PROCEDURE Save_Act (
        p_At_Id                    Act.At_Id%TYPE,
        p_At_Tp                    Act.At_Tp%TYPE,
        p_At_Pc                    Act.At_Pc%TYPE,
        p_At_Num                   Act.At_Num%TYPE DEFAULT NULL,
        p_At_Dt                    Act.At_Dt%TYPE,
        p_At_Org                   Act.At_Org%TYPE,
        p_At_Sc                    Act.At_Sc%TYPE,
        p_At_Rnspm                 Act.At_Rnspm%TYPE,
        p_At_Rnp                   Act.At_Rnp%TYPE DEFAULT NULL,
        p_At_Ap                    Act.At_Ap%TYPE,
        p_At_St                    Act.At_St%TYPE,
        p_At_Src                   Act.At_Src%TYPE,
        p_At_Case_Class            Act.At_Case_Class%TYPE DEFAULT NULL,
        p_At_Main_Link_Tp          Act.At_Main_Link_Tp%TYPE DEFAULT NULL,
        p_At_Main_Link             Act.At_Main_Link%TYPE DEFAULT NULL,
        p_At_Action_Start_Dt       Act.At_Action_Start_Dt%TYPE DEFAULT NULL,
        p_At_Action_Stop_Dt        Act.At_Action_Stop_Dt%TYPE DEFAULT NULL,
        p_At_Notes                 Act.At_Notes%TYPE DEFAULT NULL,
        p_At_Family_Info           Act.At_Family_Info%TYPE DEFAULT NULL,
        p_At_Live_Address          Act.At_Live_Address%TYPE DEFAULT NULL,
        p_At_Wu                    Act.At_Wu%TYPE DEFAULT NULL,
        p_At_Cu                    Act.At_Cu%TYPE DEFAULT NULL,
        p_At_Conclusion_Tp         Act.At_Conclusion_Tp%TYPE DEFAULT NULL,
        p_At_Form_Tp               Act.At_Form_Tp%TYPE DEFAULT NULL,
        p_At_Ext_Ident             Act.At_Ext_Ident%TYPE DEFAULT NULL,
        p_New_Id               OUT Act.At_Id%TYPE);

    PROCEDURE Copy_At_To_New (p_At_id            IN     Act.At_Id%TYPE,
                              p_New_At_Tp        IN     Act.At_Tp%TYPE,
                              p_New_At_Id           OUT Act.At_Id%TYPE,
                              p_With_Signers     IN     NUMBER DEFAULT 1,
                              p_With_Documents   IN     NUMBER DEFAULT 1,
                              p_With_Logs        IN     NUMBER DEFAULT 0);

    PROCEDURE Copy_At_Documents_Signers_To_New_Act (
        p_At_id       IN Act.At_Id%TYPE,
        p_New_At_Id   IN Act.At_Id%TYPE);

    PROCEDURE Merge_At_To_New (p_At_id            IN Act.At_Id%TYPE,
                               p_New_At_Id        IN Act.At_Id%TYPE,
                               p_With_Signers     IN NUMBER DEFAULT 1,
                               p_With_Documents   IN NUMBER DEFAULT 1,
                               p_With_Logs        IN NUMBER DEFAULT 0);

    PROCEDURE Check_At_Integrity (p_At_Id         IN NUMBER,
                                  p_Table         IN VARCHAR2,
                                  p_Id_Field      IN VARCHAR,
                                  p_At_Field      IN VARCHAR,
                                  p_Id_Val        IN NUMBER,
                                  p_Entity_Name   IN VARCHAR2);

    PROCEDURE Check_At_Services (p_At_Id IN NUMBER);


    PROCEDURE CheckIsActSCInPersons (p_At_Sc   IN Act.At_Sc%TYPE,
                                     p_App     IN t_At_Persons);

    PROCEDURE Save_Persons (p_At_Id     IN            NUMBER,
                            p_Persons   IN OUT NOCOPY Api$act.t_At_Persons,
                            p_Cu_Id     IN            NUMBER);

    FUNCTION Get_Next_Atp_Num (p_At_Id IN ACT.AT_ID%TYPE)
        RETURN NUMBER;

    PROCEDURE Save_Person (
        p_Atp_Id                    At_Person.Atp_Id%TYPE,
        p_Atp_At                    At_Person.Atp_At%TYPE,
        p_Atp_Sc                    At_Person.Atp_Sc%TYPE,
        p_Atp_Fn                    At_Person.Atp_Fn%TYPE,
        p_Atp_Mn                    At_Person.Atp_Mn%TYPE,
        p_Atp_Ln                    At_Person.Atp_Ln%TYPE,
        p_Atp_Birth_Dt              At_Person.Atp_Birth_Dt%TYPE,
        p_Atp_Relation_Tp           At_Person.Atp_Relation_Tp%TYPE,
        p_Atp_Is_Disabled           At_Person.Atp_Is_Disabled%TYPE,
        p_Atp_Is_Capable            At_Person.Atp_Is_Capable%TYPE,
        p_Atp_Work_Place            At_Person.Atp_Work_Place%TYPE,
        p_Atp_Is_Adr_Matching       At_Person.Atp_Is_Adr_Matching%TYPE,
        p_Atp_Phone                 At_Person.Atp_Phone%TYPE,
        p_Atp_Notes                 At_Person.Atp_Notes%TYPE,
        p_Atp_Live_Address          At_Person.Atp_Live_Address%TYPE,
        p_Atp_Tp                    At_Person.Atp_Tp%TYPE,
        p_Atp_Cu                    At_Person.Atp_Cu%TYPE,
        p_Atp_App_Tp                At_Person.Atp_App_Tp%TYPE,
        p_Atp_Fact_Address          At_Person.Atp_Fact_Address%TYPE,
        p_Atp_Is_Disordered         At_Person.Atp_Is_Disordered%TYPE,
        p_Atp_Disorder_Record       At_Person.Atp_Disorder_Record%TYPE,
        p_Atp_Disable_Record        At_Person.Atp_Disable_Record%TYPE,
        p_Atp_Capable_Record        At_Person.Atp_Capable_Record%TYPE,
        p_Atp_Sex                   At_Person.Atp_Sex%TYPE,
        p_Atp_Citizenship           At_Person.Atp_Citizenship%TYPE,
        p_Atp_Is_Selfservice        At_Person.Atp_Is_Selfservice%TYPE,
        p_Atp_Is_Vpo                At_Person.Atp_Is_Vpo%TYPE,
        p_Atp_Is_Orphan             At_Person.Atp_Is_Orphan%TYPE,
        p_Atp_Email                 At_Person.Atp_Email%TYPE,
        p_Atp_Num                   At_Person.Atp_Num%TYPE,
        p_New_Id                OUT At_Person.Atp_Id%TYPE);

    PROCEDURE Get_Persons (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Save_Sections (
        p_At_Id      IN            NUMBER,
        p_Sections   IN OUT NOCOPY Api$act.t_At_Sections,
        p_Persons    IN OUT NOCOPY Api$act.t_At_Persons);

    PROCEDURE Save_Sections (
        p_At_Id           IN            NUMBER,
        p_Sections        IN OUT NOCOPY Api$act.t_At_Sections,
        p_Persons         IN OUT NOCOPY Api$act.t_At_Persons,
        p_At_Other_Spec   IN OUT NOCOPY Api$act.t_At_Other_Spec);

    PROCEDURE Save_Section (
        p_Ate_Id                     At_Section.Ate_Id%TYPE,
        p_Ate_Atp                    At_Section.Ate_Atp%TYPE,
        p_Ate_At                     At_Section.Ate_At%TYPE,
        p_Ate_Nng                    At_Section.Ate_Nng%TYPE,
        p_Ate_Chield_Info            At_Section.Ate_Chield_Info%TYPE,
        p_Ate_Parent_Info            At_Section.Ate_Parent_Info%TYPE,
        p_Ate_Indicator_Value1       At_Section.Ate_Indicator_Value1%TYPE,
        p_Ate_Indicator_Value2       At_Section.Ate_Indicator_Value2%TYPE,
        p_Ate_Notes                  At_Section.Ate_Notes%TYPE,
        p_Ate_Atop                   At_Section.Ate_Atop%TYPE,
        p_New_Id                 OUT At_Section.Ate_Id%TYPE);

    PROCEDURE Get_Sections (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Services_Only (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Other_Spec (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    -- Збереження результатів відпрацювання заходів акту
    -----------------------------------------------------------
    PROCEDURE Save_At_Results (
        p_At_Id     IN            NUMBER,
        p_Results   IN OUT NOCOPY Api$act.t_At_Results);

    --====================================================--
    --   Збереження результату відпрацювання заходів
    --====================================================--
    PROCEDURE Save_At_Result (
        P_Atr_Id                     At_Results.Atr_Id%TYPE,
        P_Atr_At                     At_Results.Atr_AT%TYPE,
        P_Atr_Nst                    At_Results.Atr_NST%TYPE,
        P_Atr_Result                 At_Results.Atr_RESULT%TYPE,
        P_Atr_Is_Redirected          At_Results.Atr_IS_REDIRECTED%TYPE,
        P_Atr_Redirect_Dt            At_Results.Atr_REDIRECT_DT%TYPE,
        P_Atr_Redirect_Rnspm         At_Results.Atr_REDIRECT_RNSPM%TYPE,
        P_Atr_Redirect_Else          At_Results.Atr_REDIRECT_ELSE%TYPE,
        P_Atr_Atip                   At_Results.Atr_ATIP%TYPE,
        P_Atr_Achievment_Level       At_Results.Atr_ACHIEVMENT_LEVEL%TYPE,
        p_New_Id                 OUT At_Results.Atr_Id%TYPE);

    --====================================================--
    --   Збереження Соціально-побутові умови проживання
    --====================================================--
    PROCEDURE Save_Living_Conditions (
        p_At_Id               IN            NUMBER,
        p_Living_Conditions   IN OUT NOCOPY Api$act.t_At_Living_Conditions,
        p_Cu_Id               IN            NUMBER);

    PROCEDURE Save_Living_Condition (
        p_Atlc_Id                      At_Living_Conditions.Atlc_Id%TYPE,
        p_Atlc_At                      At_Living_Conditions.Atlc_At%TYPE,
        p_Atlc_Living_Square           At_Living_Conditions.Atlc_Living_Square%TYPE,
        p_Atlc_Holding_Square          At_Living_Conditions.Atlc_Holding_Square%TYPE,
        p_Atlc_Housing_Condition       At_Living_Conditions.Atlc_Housing_Condition%TYPE,
        p_Atlc_Residents_Cnt           At_Living_Conditions.Atlc_Residents_Cnt%TYPE,
        p_Atlc_Inv_Cnt                 At_Living_Conditions.Atlc_Inv_Cnt%TYPE,
        p_Atlc_Inv_Child_Cnt           At_Living_Conditions.Atlc_Inv_Child_Cnt%TYPE,
        p_New_Id                   OUT At_Living_Conditions.Atlc_Id%TYPE);

    --====================================================--
    --   Отримання Соціально-побутові умови проживання
    --====================================================--
    PROCEDURE Get_Living_Conditions (p_At_Id   IN     NUMBER,
                                     p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Save_Section_Features (
        p_At_Id      IN            NUMBER,
        p_Ate_Id     IN            NUMBER,
        p_Features   IN OUT NOCOPY Api$act.t_At_Section_Features);

    PROCEDURE Save_Section_Feature (
        p_Atef_Id            At_Section_Feature.Atef_Id%TYPE,
        p_Atef_Ate           At_Section_Feature.Atef_Ate%TYPE,
        p_Atef_At            At_Section_Feature.Atef_At%TYPE,
        p_Atef_Nda           At_Section_Feature.Atef_Nda%TYPE,
        p_Atef_Feature       At_Section_Feature.Atef_Feature%TYPE,
        p_Atef_Notes         At_Section_Feature.Atef_Notes%TYPE,
        p_New_Id         OUT At_Section_Feature.Atef_Id%TYPE);

    PROCEDURE Get_Section_Features (p_At_Id   IN     NUMBER,
                                    p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Save_Signers (p_At_Id     IN            NUMBER,
                            p_Signers   IN OUT NOCOPY Api$act.t_At_Signers);

    PROCEDURE Save_Signers (p_At_Id     IN            NUMBER,
                            p_Signers   IN OUT NOCOPY Api$act.t_At_Signers,
                            p_Persons   IN OUT NOCOPY Api$act.t_At_Persons);

    PROCEDURE Save_Signers (
        p_At_Id       IN            NUMBER,
        p_Signers     IN OUT NOCOPY Api$act.t_At_Signers,
        p_Persons     IN OUT NOCOPY Api$act.t_At_Persons,
        p_Documents   IN OUT NOCOPY Api$act.t_At_Documents);

    FUNCTION Get_Signer_Name (p_Ati_Sc    IN NUMBER,
                              p_Ati_Cu    IN NUMBER,
                              p_Ati_Wu    IN NUMBER,
                              p_Ati_atp   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    PROCEDURE Get_Signers (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Save_Services (p_At_Id      IN            NUMBER,
                             p_Services   IN OUT NOCOPY t_At_Services);

    PROCEDURE Save_Service (
        p_Ats_Id                  At_Service.Ats_Id%TYPE,
        p_Ats_At                  At_Service.Ats_At%TYPE,
        p_Ats_Nst                 At_Service.Ats_Nst%TYPE,
        p_History_Status          At_Service.History_Status%TYPE,
        p_Ats_At_Src              At_Service.Ats_At_Src%TYPE,
        p_Ats_St                  At_Service.Ats_St%TYPE,
        p_Ats_Ss_Method           At_Service.Ats_Ss_Method%TYPE,
        p_Ats_Ss_Address_Tp       At_Service.Ats_Ss_Address_Tp%TYPE,
        p_Ats_Ss_Address          At_Service.Ats_Ss_Address%TYPE,
        p_Ats_Tarif_Sum           At_Service.Ats_Tarif_Sum%TYPE,
        p_Ats_Act_Sum             At_Service.Ats_Act_Sum%TYPE,
        p_Ats_Rnspa               At_Service.Ats_Rnspa%TYPE,
        p_Ats_Ss_Term             At_Service.Ats_Ss_Term%TYPE,
        p_New_Id              OUT At_Service.Ats_Id%TYPE);

    PROCEDURE Save_Other_Spec (
        p_Atop_Id             At_Other_Spec.Atop_Id%TYPE,
        p_Atop_At             At_Other_Spec.Atop_At%TYPE,
        p_Atop_Fn             At_Other_Spec.Atop_Fn%TYPE,
        p_Atop_Mn             At_Other_Spec.Atop_Mn%TYPE,
        p_Atop_Ln             At_Other_Spec.Atop_Ln%TYPE,
        p_Atop_Phone          At_Other_Spec.Atop_Phone%TYPE,
        p_Atop_Atip           At_Other_Spec.Atop_Atip%TYPE,
        p_Atop_Position       At_Other_Spec.Atop_Position%TYPE,
        p_Atop_Tp             At_Other_Spec.Atop_Tp%TYPE,
        p_Atop_Order          At_Other_Spec.Atop_Order%TYPE,
        p_Atop_Notes          At_Other_Spec.Atop_Notes%TYPE,
        p_Atop_Atp            At_Other_Spec.Atop_Atp%TYPE,
        p_New_Id          OUT At_Other_Spec.Atop_Id%TYPE);

    PROCEDURE Save_Other_Specs (
        p_At_Id         IN            NUMBER,
        p_Other_Specs   IN OUT NOCOPY t_At_Other_Spec);

    PROCEDURE Map_Atop_Atip (
        p_Other_Specs        IN OUT NOCOPY t_At_Other_Spec,
        p_Individual_Plans   IN OUT NOCOPY t_At_Individual_Plan);

    PROCEDURE Save_Individual_Plan (
        p_Atip_Id                  At_Individual_Plan.Atip_Id%TYPE,
        p_Atip_At                  At_Individual_Plan.Atip_At%TYPE,
        p_Atip_Nsa                 At_Individual_Plan.Atip_Nsa%TYPE,
        p_Atip_Place               At_Individual_Plan.Atip_Place%TYPE,
        p_Atip_Period              At_Individual_Plan.Atip_Period%TYPE,
        p_Atip_Qnt                 At_Individual_Plan.Atip_Qnt%TYPE,
        p_Atip_Cu                  At_Individual_Plan.Atip_Cu%TYPE,
        p_Atip_Resources           At_Individual_Plan.Atip_Resources%TYPE,
        p_Atip_Desc                At_Individual_Plan.Atip_Desc%TYPE,
        p_Atip_St                  At_Individual_Plan.Atip_St%TYPE,
        p_Atip_Exprections         At_Individual_Plan.Atip_Exprections%TYPE,
        p_Atip_Nst                 At_Individual_Plan.Atip_Nst%TYPE,
        p_Atip_Nsa_Det             At_Individual_Plan.Atip_Nsa_Det%TYPE,
        p_Atip_Term_Tp             At_Individual_Plan.Atip_Term_Tp%TYPE,
        p_Atip_Start_Dt            At_Individual_Plan.Atip_Start_Dt%TYPE,
        p_Atip_Stop_Dt             At_Individual_Plan.Atip_Stop_Dt%TYPE,
        p_Atip_Order               At_Individual_Plan.Atip_Order%TYPE,
        p_Atip_Nsa_Hand_Name       At_Individual_Plan.Atip_Nsa_Hand_Name%TYPE,
        p_New_Id               OUT At_Individual_Plan.Atip_Id%TYPE);

    PROCEDURE Save_Individual_Plans (
        p_At_Id              IN            NUMBER,
        p_Individual_Plans   IN OUT NOCOPY t_At_Individual_Plan);

    PROCEDURE Get_Indivilual_Plan (p_At_Id   IN     NUMBER,
                                   p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Save_Right_Log (p_At_Id          IN NUMBER,
                              p_At_Right_Log   IN t_At_Right_Log,
                              p_Hs_Id          IN NUMBER);

    PROCEDURE Save_Reject_Info (
        p_At_Id            IN NUMBER,
        p_At_Reject_Info      Api$act.t_At_Reject_Info);

    PROCEDURE Save_Reject_Infos (p_At_Id IN NUMBER, p_Clob IN CLOB);

    PROCEDURE Save_Link (p_Atk_At        At_Links.Atk_At%TYPE,
                         p_Atk_Link_At   At_Links.Atk_Link_At%TYPE,
                         p_Atk_Tp        At_Links.Atk_Tp%TYPE);

    FUNCTION Get_At_St (p_At_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ats_cnt (p_At_Id         IN NUMBER,
                          p_nst           IN NUMBER,
                          p_Ats_St_List   IN VARCHAR2 := 'R, P, PP')
        RETURN NUMBER;

    FUNCTION Get_Atd_Id (p_At_Id IN NUMBER, p_Atd_Ndt IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Atd_At (p_Atd_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Define_Print_Form_Ndt (
        p_At_Id                IN     NUMBER,
        p_Build_Proc              OUT VARCHAR2,
        p_Raise_If_Undefined   IN     BOOLEAN DEFAULT TRUE)
        RETURN NUMBER;

    FUNCTION Define_Print_Form_Ndt (
        p_At_Id                IN NUMBER,
        p_Raise_If_Undefined   IN BOOLEAN DEFAULT TRUE)
        RETURN NUMBER;

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Form_Ndt    IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Form_Ndt               IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id             IN     NUMBER,
                             p_At_Prj_St         IN     VARCHAR2,
                             p_Form_Ndt          IN     NUMBER,
                             p_Form_Build_Proc   IN     VARCHAR2,
                             p_Doc_Cur              OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id     IN     NUMBER,
                            p_Atd_Ndt   IN     NUMBER,
                            p_Doc          OUT SYS_REFCURSOR);

    FUNCTION Get_Form_Doc (p_At_Id IN NUMBER, p_Atd_Ndt IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Get_Sign_Info_Doc (p_At_Id    IN     NUMBER,
                                 p_Atp_Id   IN     NUMBER,
                                 p_Atd_Id      OUT NUMBER,
                                 p_Doc_Id      OUT NUMBER);

    PROCEDURE Get_Form_Doc_Src (p_At_Id     IN     NUMBER,
                                p_Atd_Ndt   IN     NUMBER,
                                p_Doc_Src      OUT VARCHAR2);

    FUNCTION Get_At_Spec_Name (p_At_Wu IN NUMBER, p_At_Cu IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_At_Spec_Position (p_At_Wu      IN NUMBER,
                                   p_At_Cu      IN NUMBER,
                                   p_At_Rnspm   IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER);

    PROCEDURE Save_Documents (
        p_At_Id          IN            NUMBER,
        p_At_Documents   IN OUT NOCOPY Api$act.t_At_Documents);

    PROCEDURE Save_Documents (p_At_Id IN NUMBER, p_At_Documents IN CLOB);

    PROCEDURE Get_Documents (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Doc_Files (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Signed_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Doc_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Set_Atd_Dh (p_Atd_Id           IN NUMBER,
                          p_Atd_Dh           IN NUMBER,
                          p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO');

    PROCEDURE Set_Atd_Source (p_Atd_Id           IN NUMBER,
                              p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO');

    PROCEDURE Add_Attr (p_Attrs     IN OUT NOCOPY t_At_Document_Attrs,
                        p_Nda_Id    IN            NUMBER,
                        p_Val_Str   IN            VARCHAR2 DEFAULT NULL,
                        p_Val_Dt    IN            DATE DEFAULT NULL,
                        p_Val_Sum   IN            NUMBER DEFAULT NULL,
                        p_Val_Int   IN            NUMBER DEFAULT NULL,
                        p_Val_Id    IN            NUMBER DEFAULT NULL);

    PROCEDURE Save_Attributes (
        p_At_Id     IN            NUMBER,
        p_Atd_Id    IN            NUMBER,
        p_Attrs     IN OUT NOCOPY Api$act.t_At_Document_Attrs,
        p_Nda_Map   IN OUT NOCOPY t_Nda_Map);

    PROCEDURE Save_Attributes (p_At_Id    IN            NUMBER,
                               p_Atd_Id   IN            NUMBER,
                               p_Attrs    IN OUT NOCOPY t_At_Document_Attrs);

    PROCEDURE Modify_Attribute (p_Atda_Id           IN NUMBER,
                                p_Atda_At           IN NUMBER,
                                p_Atda_Atd          IN NUMBER,
                                p_Atda_Nda          IN NUMBER,
                                p_Atda_Val_Int      IN NUMBER,
                                p_Atda_Val_Sum      IN NUMBER,
                                p_Atda_Val_Id       IN NUMBER,
                                p_Atda_Val_Dt       IN DATE,
                                p_Atda_Val_String   IN VARCHAR2);

    PROCEDURE Make_Attr_Collection (
        p_At_Id     IN            NUMBER,
        p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
        p_Attrs     IN OUT NOCOPY Api$act.t_At_Document_Attrs);

    FUNCTION Get_Attr_Field (p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Attributes (p_At_Id     IN            NUMBER,
                              p_Atd_Ndt   IN            NUMBER,
                              p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
                              p_Res          OUT        SYS_REFCURSOR);

    PROCEDURE Get_Attributes (p_Atd_Ndt   IN            NUMBER,
                              p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
                              p_Res          OUT        SYS_REFCURSOR);

    FUNCTION Get_Attr_Val_Str (p_Atd_Id    IN            NUMBER,
                               p_Field     IN            VARCHAR2,
                               p_Nda_Map   IN OUT NOCOPY t_Nda_Map)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_Field (p_At_Id     IN NUMBER,
                                 p_Field     IN VARCHAR2,
                                 p_Nda_Map   IN t_Nda_Map)
        RETURN VARCHAR2;

    FUNCTION Get_By_Ap_Attr_Val_Str (p_Ap_Id     IN NUMBER,
                                     p_Nda_Id    IN NUMBER,
                                     p_At_Tp     IN VARCHAR2 DEFAULT NULL,
                                     p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_By_Ap_Attr_Val_Dt (p_Ap_Id     IN NUMBER,
                                    p_Nda_Id    IN NUMBER,
                                    p_At_Tp     IN VARCHAR2 DEFAULT NULL,
                                    p_Default      VARCHAR2 DEFAULT NULL)
        RETURN DATE;

    FUNCTION Get_Attr_Val_Str (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_Val_Dt (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN DATE;

    FUNCTION Get_Section_Attr_Val_Str (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Attributes (p_Atd_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Raise_Unauthorized;

    PROCEDURE Save_Features (
        p_Atf_Id           IN     At_Features.Atf_Id%TYPE,
        p_Atf_At           IN     At_Features.Atf_At%TYPE,
        p_Atf_Nft          IN     At_Features.Atf_Nft%TYPE,
        p_Atf_Val_Int      IN     At_Features.Atf_Val_Int%TYPE,
        p_Atf_Val_Sum      IN     At_Features.Atf_Val_Sum%TYPE,
        p_Atf_Val_Id       IN     At_Features.Atf_Val_Id%TYPE,
        p_Atf_Val_Dt       IN     At_Features.Atf_Val_Dt%TYPE,
        p_Atf_Val_String   IN     At_Features.Atf_Val_String%TYPE,
        p_Atf_Atp          IN     At_Features.Atf_Atp%TYPE,
        p_New_Id              OUT At_Features.Atf_Id%TYPE);

    PROCEDURE Delete_Features (p_Atf_Id IN At_Features.Atf_Id%TYPE);

    PROCEDURE Can_Add_Doc (p_At_Id    IN NUMBER,
                           p_Ati_Tp   IN VARCHAR2,
                           p_Ndt_Id   IN NUMBER);

    PROCEDURE Can_Sign (p_At_Id    IN NUMBER,
                        p_Atd_Id   IN NUMBER,
                        p_Ati_Tp   IN VARCHAR2);

    FUNCTION Is_All_Signed (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE Set_At_St (p_At_Id               IN NUMBER,
                         p_At_St_Old           IN VARCHAR2,
                         p_At_St_New           IN VARCHAR2,
                         p_Log_Msg             IN VARCHAR2,
                         p_Wrong_St_Msg        IN VARCHAR2,
                         p_At_Action_Stop_Dt   IN DATE DEFAULT NULL);

    FUNCTION Signer_Exists (p_Ati_At   IN NUMBER,
                            p_Ati_Sc   IN NUMBER,
                            p_Ati_Tp   IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Get_Signer_Pib (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Signer_Position (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Signer_Dt (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN DATE;

    FUNCTION Get_At_Rnspm (p_At_Id IN NUMBER)
        RETURN NUMBER;

    -----------------------------------------------------------
    --Отримання текстового параметру документу по act
    -----------------------------------------------------------
    FUNCTION Get_Act_Feature (p_atef_at    NUMBER,
                              p_atef_Nda   NUMBER,
                              p_Default    VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Full_Attr_Val_Str (p_At_Id     IN NUMBER,
                                    p_Nda_Id    IN NUMBER,
                                    p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_At_Ap (p_At_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_At_Decline_Reason_Text (p_at_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Act_Exists (p_At_Main_Link      IN NUMBER,
                         p_At_Main_Link_Tp   IN VARCHAR2,
                         p_At_Tp             IN VARCHAR2,
                         p_At_St             IN VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE Check_Lnk_St (p_at_id     NUMBER,
                            p_at_st     VARCHAR2,
                            p_at_tp     VARCHAR2,
                            p_message   VARCHAR2:= NULL);

    -- Створення лінку між актами
    PROCEDURE add_at_link (p_at_id         IN NUMBER,
                           p_atk_link_at   IN NUMBER,
                           p_atk_tp        IN VARCHAR2);

    FUNCTION Get_PDSP_Feature (p_atef_at    NUMBER,
                               p_atef_Nda   NUMBER,
                               p_Default    VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    -- Для PDST AT_ST = 'SP1'
    FUNCTION Check_PDST_ST_SP1 (p_at_id NUMBER)
        RETURN VARCHAR2;

    --==========================================--
    -- Для PDST AT_ST = 'SW'
    --#96628
    --==========================================--
    FUNCTION Check_PDST_ST_SW (p_at_id NUMBER)
        RETURN VARCHAR2;

    -- Для PDST AT_ST = 'SA'
    FUNCTION Check_PDST_ST_SA (p_at_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION Check_PDST_ST_SNR (p_at_id NUMBER)
        RETURN VARCHAR2;

    --==========================================--
    -- Перевіримо по акту, що документ є та підписаний
    --==========================================--
    FUNCTION Doc_Exists_Sign (p_at_id NUMBER, p_ndt NUMBER)
        RETURN NUMBER;

    PROCEDURE dbms_output_appeal_info (p_id NUMBER);

    PROCEDURE Resume_Suspended_Tctr;

    PROCEDURE set_ats_st (p_at_Id        IN NUMBER,
                          p_ats_st_old   IN VARCHAR2,
                          p_ats_st_new   IN VARCHAR2);

    -- опрацювання варіацій підпису ОСП в КМ
    PROCEDURE Handle_Cm_Sign (p_at_id       IN     NUMBER,
                              p_at_st_old   IN     VARCHAR2,
                              p_at_st_new   IN     VARCHAR2,
                              p_ndt_id      IN     NUMBER,
                              p_res_st         OUT VARCHAR2);

    -- при збереженні акту тип ДФ скидується в AUTO. всі підписи на планшеті стають історичними
    PROCEDURE Handle_Form_Save (p_at_id IN NUMBER, p_ndt_id IN NUMBER);

    PROCEDURE Get_Tablet_Sign (p_At_Id        IN     NUMBER,
                               p_Atp_id       IN     NUMBER,
                               p_Atd_Dh          OUT NUMBER,
                               p_Sign_Code       OUT VARCHAR2,
                               p_Photo_Code      OUT VARCHAR2);

    FUNCTION Get_Atd_Attach_Source (p_At_Id IN NUMBER, p_Ndt_id IN NUMBER)
        RETURN VARCHAR2;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Sign (p_At_Id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    FUNCTION Is_Appeal_Maked_Correct (p_At_Id IN NUMBER)
        RETURN NUMBER;
END Api$act;
/


GRANT EXECUTE ON USS_ESR.API$ACT TO OKOMISAROV
/

GRANT EXECUTE ON USS_ESR.API$ACT TO SHOST
/


/* Formatted on 8/12/2025 5:48:38 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT
IS
    g_Nda_Map   t_Nda_Map;

    PROCEDURE Write_At_Log (p_Atl_At        At_Log.Atl_At%TYPE,
                            p_Atl_Hs        At_Log.Atl_Hs%TYPE,
                            p_Atl_St        At_Log.Atl_St%TYPE,
                            p_Atl_Message   At_Log.Atl_Message%TYPE,
                            p_Atl_St_Old    At_Log.Atl_St_Old%TYPE,
                            p_Atl_Tp        At_Log.Atl_Tp%TYPE:= 'SYS')
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        IF p_Atl_Hs IS NOT NULL
        THEN
            l_Hs := p_Atl_Hs;
        ELSIF Tools.Getcurrwu IS NOT NULL
        THEN
            l_Hs := Tools.Gethistsession;
        ELSIF Ikis_Rbm.Tools.Getcurrentcu IS NOT NULL
        THEN
            l_Hs := Tools.Gethistsessioncmes;
        END IF;

        INSERT INTO At_Log (Atl_Id,
                            Atl_At,
                            Atl_Hs,
                            Atl_St,
                            Atl_Message,
                            Atl_St_Old,
                            Atl_Tp)
             VALUES (0,
                     p_Atl_At,
                     l_Hs,
                     p_Atl_St,
                     p_Atl_Message,
                     p_Atl_St_Old,
                     NVL (p_Atl_Tp, 'SYS'));
    END;

    -----------------------------------------------------------
    --Отримання текстового параметру документу по act
    -----------------------------------------------------------
    FUNCTION Get_Act_Feature (p_atef_at    NUMBER,
                              p_atef_Nda   NUMBER,
                              p_Default    VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Atef.Atef_Feature)
          INTO l_Rez
          FROM At_Section_Feature atef
         WHERE atef.atef_at = p_atef_at AND atef.atef_nda = p_atef_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    FUNCTION Get_PDSP_Feature (p_atef_at    NUMBER,
                               p_atef_Nda   NUMBER,
                               p_Default    VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Atef.Atef_Feature)
          INTO l_Rez
          FROM At_Section_Feature atef
         WHERE atef.atef_at = p_atef_at AND atef.atef_nda = p_atef_Nda;

        IF l_Rez IS NULL
        THEN
            SELECT MAX (Atef.Atef_Feature)
              INTO l_Rez
              FROM At_Section_Feature  atef
                   JOIN act at ON atef.atef_at = at.at_id
             WHERE at.at_main_link = p_atef_at AND atef.atef_nda = p_atef_Nda;
        END IF;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    FUNCTION Get_By_Ap_Attr_Val_Str (p_Ap_Id     IN NUMBER,
                                     p_Nda_Id    IN NUMBER,
                                     p_At_Tp     IN VARCHAR2 DEFAULT NULL,
                                     p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        SELECT MAX (Atda_Val_String)
          INTO l_Result
          FROM (SELECT aa.Atda_Val_String
                  FROM Act a JOIN At_Document_Attr aa ON a.at_id = aa.atda_at
                 WHERE     a.at_ap = p_Ap_Id
                       AND aa.History_Status = 'A'
                       AND (a.at_tp = p_At_Tp OR p_At_Tp IS NULL)
                       AND aa.atda_nda = p_Nda_Id
                UNION ALL
                SELECT Atef.Atef_Feature
                  FROM Act  a
                       JOIN At_Section_Feature atef ON a.at_id = atef.atef_at
                 WHERE     a.at_ap = p_Ap_Id
                       AND (a.at_tp = p_At_Tp OR p_At_Tp IS NULL)
                       AND atef.atef_nda = p_Nda_Id);

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_By_Ap_Attr_Val_Dt (p_Ap_Id     IN NUMBER,
                                    p_Nda_Id    IN NUMBER,
                                    p_At_Tp     IN VARCHAR2 DEFAULT NULL,
                                    p_Default      VARCHAR2 DEFAULT NULL)
        RETURN DATE
    IS
        l_Result   At_Document_Attr.Atda_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (Atda_Val_Dt)
          INTO l_Result
          FROM (SELECT aa.Atda_Val_Dt
                  FROM Act a JOIN At_Document_Attr aa ON a.at_id = aa.atda_at
                 WHERE     a.at_ap = p_Ap_Id
                       AND aa.History_Status = 'A'
                       AND (a.at_tp = p_At_Tp OR p_At_Tp IS NULL)
                       AND aa.atda_nda = p_Nda_Id);

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;


    FUNCTION Get_Full_Attr_Val_Str (p_At_Id     IN NUMBER,
                                    p_Nda_Id    IN NUMBER,
                                    p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        l_Result := Get_Section_Attr_Val_Str (p_At_Id, p_Nda_Id);

        IF l_Result IS NULL
        THEN
            l_Result := Get_Attr_Val_Str (p_At_Id, p_Nda_Id);
        END IF;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;


    FUNCTION Gen_At_Num (p_Pc_Id Personalcase.Pc_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Cnt      INTEGER;
        l_Pc_Num   Personalcase.Pc_Num%TYPE;
    BEGIN
        SELECT COUNT (1)
          INTO l_Cnt
          FROM Act
         WHERE     At_Pc = p_Pc_Id
               AND At_Dt BETWEEN TRUNC (SYSDATE, 'YYYY')
                             AND LAST_DAY (
                                     ADD_MONTHS (TRUNC (SYSDATE, 'YYYY'), 11))
               AND At_Num IS NOT NULL;

        --  dbms_output.put_line(l_cnt);
        SELECT Pc_Num
          INTO l_Pc_Num
          FROM Personalcase
         WHERE Pc_Id = p_Pc_Id;

        --  dbms_output.put_line(l_pc_num);
        --  dbms_output.put_line(l_pc_num||'-'||TO_CHAR(sysdate, 'YYYY')||'-'||(l_cnt + 1));
        RETURN    l_Pc_Num
               || '-'
               || TO_CHAR (SYSDATE, 'YYYY')
               || '-'
               || (l_Cnt + 1);
    END;

    FUNCTION Get_At_Decline_Reason_Text (p_at_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (DISTINCT nst.nst_name || '-' || nrr.njr_name, '; ')
          INTO l_res
          FROM AT_REJECT_INFO  atri
               JOIN AT_SERVICE ats ON atri.ari_ats = ats.ats_id
               JOIN uss_Ndi.v_Ndi_Service_Type nst
                   ON ats.ats_nst = nst.nst_id
               JOIN uss_ndi.v_ndi_reject_reason nrr
                   ON atri.ari_nrr = nrr.njr_id
         WHERE     atri.ari_at = p_at_id
               AND ats.history_status = 'A'
               AND nst.history_status = 'A'
               AND nrr.history_status = 'A';

        RETURN l_res;
    END;

    -----------------------------------------------------------
    --   Стоверення повідомлення про припинення надання СП
    -----------------------------------------------------------
    PROCEDURE Init_Ppnp (p_Rstopss_Id IN NUMBER, p_At_Id OUT NUMBER)
    IS
        l_Act               Act%ROWTYPE;
        l_At_Live_Address   Act.At_Live_Address%TYPE;
    BEGIN
        SELECT *
          INTO l_Act
          FROM Act a
         WHERE a.At_Id = p_Rstopss_Id;

        BEGIN
            SELECT a.At_Live_Address
              INTO l_At_Live_Address
              FROM Act a
             WHERE     a.At_Main_Link = p_Rstopss_Id
                   AND a.At_Tp = 'IPNP'
                   AND a.At_St = 'NP';
        EXCEPTION
            WHEN OTHERS
            THEN
                SELECT MAX (a.At_Live_Address)
                  INTO l_At_Live_Address
                  FROM Act a JOIN at_links l ON (l.atk_link_at = a.at_id)
                 WHERE     l.atk_at = p_Rstopss_Id
                       AND a.At_Tp = 'TCTR'
                       AND a.At_St NOT IN ('DD', 'DR', 'DN');
        END;

        --Зберігаємо шапку акту
        INSERT INTO Act (At_Id,
                         At_Tp,
                         At_Pc,
                         At_Num,
                         At_Dt,
                         At_Org,
                         At_Sc,
                         At_Rnspm,
                         At_Rnp,
                         At_Ap,
                         At_St,
                         At_Src,
                         At_Main_Link_Tp,
                         At_Main_Link,
                         At_Action_Stop_Dt,
                         At_Live_Address,
                         At_Wu,
                         At_Cu)
             VALUES (0,
                     'PPNP',
                     l_Act.At_Pc,
                     NULL,
                     SYSDATE,
                     l_Act.At_Org,
                     l_Act.At_Sc,
                     l_Act.At_Rnspm,
                     l_Act.At_Rnp,
                     l_Act.At_Ap,
                     'MN',
                     l_Act.At_Src,
                     'RSTOPSS',
                     l_Act.At_Id,
                     l_Act.At_Action_Stop_Dt,
                     l_At_Live_Address,
                     l_Act.At_Wu,
                     l_Act.At_Cu)
          RETURNING At_Id
               INTO p_At_Id;

        UPDATE act t
           SET at_num = p_At_Id
         WHERE at_id = p_At_Id;

        --Зберігаємо осіб
        INSERT INTO At_Person (Atp_Id,
                               Atp_At,
                               Atp_Sc,
                               Atp_Fn,
                               Atp_Mn,
                               Atp_Ln,
                               Atp_Birth_Dt,
                               Atp_App_Tp,
                               Atp_Num,
                               History_Status)                      --#APP_NUM
            SELECT 0,
                   p_At_Id,
                   p.Atp_Sc,
                   p.Atp_Fn,
                   p.Atp_Mn,
                   p.Atp_Ln,
                   p.Atp_Birth_Dt,
                   p.Atp_App_Tp,
                   p.atp_num,
                   'A'
              FROM At_Person p
             WHERE p.Atp_At = p_Rstopss_Id AND p.History_Status = 'A';

        --Зберігаємо посилання на договір
        INSERT INTO At_Links (Atk_Id,
                              Atk_At,
                              Atk_Link_At,
                              Atk_Tp)
            SELECT 0,
                   p_At_Id,
                   l.Atk_Link_At,
                   l.Atk_Tp
              FROM At_Links l
             WHERE l.Atk_At = p_Rstopss_Id AND l.Atk_Tp = 'TCTR';
    END;


    -----------------------------------------------------------
    --     Стоверення рішення про припинення надання СП
    --     (по зверненню R.OS або R.GS)
    -----------------------------------------------------------
    PROCEDURE Init_Rstopss (p_At_Id   IN NUMBER,
                            p_Ap_Id   IN NUMBER,
                            p_At_St   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Tctr_Num          Act.At_Num%TYPE;
        l_Tctr_Id           NUMBER;
        l_Pdsp_Id           NUMBER;
        l_Ipnp_Id           NUMBER;
        l_Ipnp_Exists       NUMBER;
        l_At_St             VARCHAR2 (10);
        l_At_Cu             NUMBER;
        l_Primary_Ap        NUMBER;
        l_is_oszn           NUMBER;
        l_apd_864           VARCHAR2 (10);
        l_At_Live_Address   act.at_live_address%TYPE;
        l_Ap                Appeal%ROWTYPE;
        l_At                Act%ROWTYPE;
    BEGIN
        --Шукаємо діючий договір за номером та отримувачем
        l_Tctr_Num := Api$appeal.Get_Ap_Doc_Str (p_Ap_Id, 'TCTRNUM');

        BEGIN
              SELECT a.At_Id,
                     a.At_Main_Link,
                     a.At_Cu,
                     a.At_Ap,
                     a.At_Live_Address
                INTO l_Tctr_Id,
                     l_Pdsp_Id,
                     l_At_Cu,
                     l_Primary_Ap,
                     l_At_Live_Address
                FROM Act a
                     JOIN Ap_Person p
                         ON     p.App_Ap = p_Ap_Id
                            AND p.App_Tp IN ('Z', 'OS')
                            AND p.History_Status = 'A'
               WHERE     a.At_Num = l_Tctr_Num
                     AND a.At_Tp = 'TCTR'
                     AND a.At_Sc = p.App_Sc
                     AND a.At_St IN ('DT')
            ORDER BY a.At_Dt DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                --todo: повернути звернення на доопрацювання ???
                --NULL;
                RETURN;
        END;

        /*
            --#94257 Зміна логіки пошуку актів про надання СП при відмові від надання послуг
            IF l_Pdsp_Id IS NULL THEN
              BEGIN

                SELECT a.At_Id
                  INTO l_Pdsp_Id
                  FROM Act a
                  JOIN Ap_Person p
                    ON p.App_Ap = p_Ap_Id
                   AND p.App_Tp IN ('Z', 'OS')
                   AND p.History_Status = 'A'
                 WHERE a.At_Num = l_Tctr_Num
                   AND a.At_Tp = 'PDSP'
                   AND a.At_Sc = p.App_Sc
                   AND a.At_St IN ('SS')
                 ORDER BY a.At_Dt DESC
                 FETCH FIRST ROW ONLY;

              EXCEPTION
                WHEN No_Data_Found THEN
                  --todo: повернути звернення на доопрацювання ???
                  RETURN;
              END;
            END IF;

         типу R.OS, пошук в ЄСРі виконувати по наявності акту PDSP у статусі SS
        */

        --Зберігаємо до рішення посилання на договір
        Save_Link (p_Atk_At        => p_At_Id,
                   p_Atk_Link_At   => l_Tctr_Id,
                   p_Atk_Tp        => 'TCTR');

        --Визначаємо наявність інформації про припинення від НСП
        SELECT SIGN (COUNT (*)),
               MAX (a.at_id),
               COUNT (CASE WHEN a.at_rnp IN (399, 400) THEN 1 END)
          INTO l_Ipnp_Exists, l_Ipnp_Id, l_is_oszn
          FROM At_Links  l
               JOIN Act a
                   ON     l.Atk_At = a.At_Id
                      AND a.At_Tp = 'IPNP'
                      AND a.At_St = 'NP'
         WHERE l.Atk_Link_At = l_Tctr_Id AND l.Atk_Tp = 'TCTR';

        IF p_At_St IS NULL
        THEN
            SELECT *
              INTO l_Ap
              FROM Appeal
             WHERE Ap_id = p_Ap_Id;

            SELECT *
              INTO l_At
              FROM Act
             WHERE at_id = p_at_id;

            SELECT CASE WHEN COUNT (1) = 0 THEN 'F' ELSE 'T' END
              INTO l_apd_864
              FROM ap_document apd
             WHERE apd_ap = p_Ap_Id AND apd_ndt IN (864);

            IF l_At.At_Tp = 'RSTOPSS' AND l_Ap.Ap_Tp = 'R.OS'
            THEN
                --#111840
                l_At_St := 'RS.C';

                -- Дата припинення надання СП
                UPDATE act a
                   SET a.at_action_stop_dt =
                           Api$appeal.get_doc_dt_max (p_Ap_Id,
                                                      NULL,
                                                      800,
                                                      3065),
                       a.at_live_address = l_At_Live_Address
                 WHERE a.at_id = p_At_Id;
            --якщо було подано інформацію про припинення
            ELSIF l_Ipnp_Exists = 1
            THEN
                IF l_apd_864 = 'T' AND l_Ap.Ap_Tp = 'R.GS'
                THEN
                    --#110881
                    l_At_St := 'RM.N';
                ELSIF    Api$appeal.Get_Ap_Doc_Str (l_Primary_Ap,
                                                    'DIRECTION') =
                         'SB'
                      -- #110815 НСП - ОСЗН
                      OR l_is_oszn > 0
                THEN
                    --стан = "Очікує підписання спеціаліста ОСЗН"
                    l_At_St := 'RS.S';
                ELSE
                    --стан = "Очікує підписання КМа"
                    l_At_St := 'RS.C';
                END IF;

                -- прив'язуємо ІПНП до РСТОПСС
                UPDATE act a
                   SET a.at_main_link = p_At_Id
                 WHERE a.at_id = l_Ipnp_Id;

                UPDATE Act a
                   SET (a.At_Pc,
                        a.At_Sc,
                        a.at_rnp,
                        a.at_action_stop_dt,
                        a.at_live_address) =
                           (SELECT at_pc,
                                   at_sc,
                                   at_rnp,
                                   NVL (a.at_action_stop_dt,
                                        z.at_action_stop_dt),
                                   z.at_live_address
                              FROM act z
                             WHERE z.at_id = l_Ipnp_Id)
                 WHERE a.At_Id = p_At_Id;

                -- Зберігаємо до IPNP посилання на рішення про припинення
                Save_Link (p_Atk_At        => l_Ipnp_Id,
                           p_Atk_Link_At   => p_At_Id,
                           p_Atk_Tp        => 'RSTOPSS');
            ELSIF     l_At.At_Tp = 'RSTOPSS'
                  AND l_Ap.Ap_Tp = 'R.GS'
                  AND l_apd_864 = 'T'
            THEN
                l_At_St := 'RM.N';
            ELSIF l_At.At_Tp = 'RSTOPSS' AND l_Ap.Ap_Tp = 'R.GS'
            THEN
                --#111841
                l_At_St := 'RS.N';
            ELSE
                --якщо інформація про припинення не подавалась
                --стан = "На розгляд НСП"
                l_At_St := 'RR';
            END IF;
        ELSE
            l_At_St := p_At_St;
        END IF;

        UPDATE Act a
           SET a.At_Rnspm = Api$appeal.Get_Ap_Doc_Id (p_Ap_Id, 'RNSP'), --Надавач
               a.At_Rnp =
                   NVL (
                       a.At_Rnp,
                       NVL (Api$appeal.Get_Ap_Doc_Id (p_Ap_Id, 'RNP'),
                            Api$appeal.Get_Ap_Doc_Str (p_Ap_Id, 'RNP'))), --Причина припинення
               a.At_Main_Link = l_Pdsp_Id,            --Рішення про надання СП
               a.At_Main_Link_Tp = 'DECISION',
               a.At_St = l_At_St,
               a.At_Cu = l_At_Cu           --КМ який буде працювати з рішенням
         WHERE a.At_Id = p_At_Id;
    END;

    --====================================================--
    --   Копіювання підписантів в новий акт
    --====================================================--
    PROCEDURE Copy_At_Signers_To_New_Act (
        p_At_id        IN Act.At_Id%TYPE,
        p_New_At_Id    IN Act.At_Id%TYPE,
        p_Atd_Id       IN At_Document.Atd_Id%TYPE,
        p_New_Atd_Id   IN At_Document.Atd_Id%TYPE,
        p_Atp_Id       IN At_Person.Atp_Id%TYPE,
        p_New_Atp_Id   IN At_Person.Atp_Id%TYPE)
    IS
    BEGIN
        INSERT INTO at_signers (ati_id,
                                ati_at,
                                ati_atd,
                                ati_wu,
                                ati_sign_dt,
                                ati_is_signed,
                                history_status,
                                ati_cu,
                                ati_sc,
                                ati_order,
                                ati_atp,
                                ati_tp,
                                ati_sign_code)
            SELECT 0,
                   p_New_At_Id,
                   p_New_Atd_Id,
                   ati_wu,
                   ati_sign_dt,
                   ati_is_signed,
                   history_status,
                   ati_cu,
                   ati_sc,
                   ati_order,
                   ati_atp,
                   ati_tp,
                   ati_sign_code
              FROM at_signers s
             WHERE     Ati_At = p_At_id
                   AND History_Status = 'A'
                   AND (   Ati_Atp = p_Atp_Id
                        OR (Ati_Atp IS NULL AND p_Atp_Id IS NULL))
                   AND (   Ati_Atd = p_Atd_Id
                        OR (Ati_Atd IS NULL AND p_Atd_Id IS NULL));
    END;

    --====================================================--
    --   Копіювання докуменів в новий акт
    --====================================================--
    PROCEDURE Copy_At_Documents_To_New_Act (
        p_At_id        IN Act.At_Id%TYPE,
        p_New_At_Id    IN Act.At_Id%TYPE,
        p_Atp_Id       IN At_Person.Atp_Id%TYPE,
        p_New_Atp_Id   IN At_Person.Atp_Id%TYPE)
    IS
        v_New_Atd_Id   At_Document.Atd_Id%TYPE;
    BEGIN
        FOR v_At_Doc
            IN (SELECT atd_id,
                       atd_at,
                       atd_ndt,
                       atd_ats,
                       atd_doc,
                       atd_dh,
                       history_status,
                       atd_atp,
                       atd_attach_src
                  FROM at_document atd
                 WHERE     Atd_At = p_At_id
                       AND History_Status = 'A'
                       AND (   Atd_Atp = p_Atp_Id
                            OR (Atd_Atp IS NULL AND p_Atp_Id IS NULL)))
        LOOP
            INSERT INTO at_document (atd_id,
                                     atd_at,
                                     atd_ndt,
                                     atd_ats,
                                     atd_doc,
                                     atd_dh,
                                     history_status,
                                     atd_atp,
                                     atd_attach_src)
                 VALUES (0,
                         p_New_At_Id,
                         v_At_Doc.atd_ndt,
                         v_At_Doc.atd_ats,
                         v_At_Doc.atd_doc,
                         v_At_Doc.atd_dh,
                         'A',
                         p_New_Atp_Id,
                         v_At_Doc.Atd_Attach_Src)
              RETURNING Atd_Id
                   INTO v_New_Atd_Id;


            Copy_At_Signers_To_New_Act (p_At_id,
                                        p_New_At_Id,
                                        v_At_Doc.atd_id,
                                        v_New_Atd_Id,
                                        p_Atp_Id,
                                        p_New_Atp_Id);


            FOR v_At_Doc_attr
                IN (SELECT atda_id,
                           atda_atd,
                           atda_at,
                           atda_nda,
                           atda_val_int,
                           atda_val_sum,
                           atda_val_id,
                           atda_val_dt,
                           atda_val_string,
                           history_status
                      FROM at_document_attr
                     WHERE     atda_atd = v_At_Doc.Atd_Id
                           AND History_Status = 'A')
            LOOP
                INSERT INTO at_document_attr (atda_id,
                                              atda_atd,
                                              atda_at,
                                              atda_nda,
                                              atda_val_int,
                                              atda_val_sum,
                                              atda_val_id,
                                              atda_val_dt,
                                              atda_val_string,
                                              history_status)
                     VALUES (0,
                             v_New_Atd_Id,
                             p_New_At_Id,
                             v_At_Doc_attr.atda_nda,
                             v_At_Doc_attr.atda_val_int,
                             v_At_Doc_attr.atda_val_sum,
                             v_At_Doc_attr.atda_val_id,
                             v_At_Doc_attr.atda_val_dt,
                             v_At_Doc_attr.atda_val_string,
                             'A');
            END LOOP;
        END LOOP;
    END;

    PROCEDURE Copy_At_Documents_Signers_To_New_Act (
        p_At_id       IN Act.At_Id%TYPE,
        p_New_At_Id   IN Act.At_Id%TYPE)
    IS
    --v_New_Atd_Id  At_Document.Atd_Id%TYPE;
    BEGIN
        Copy_At_Signers_To_New_Act (p_At_id,
                                    p_New_At_Id,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL);

        FOR v_At_Doc
            IN (SELECT atd.atd_id,
                       atd.atd_atp,
                       atd_new.atd_id      new_at_id,
                       atd_new.atd_atp     new_atd_atp
                  FROM at_document  atd
                       JOIN at_document atd_new
                           ON atd.atd_ndt = atd_new.atd_ndt
                 WHERE     atd.Atd_At = p_At_id
                       AND atd_new.Atd_At = p_New_At_Id
                       AND atd.History_Status = 'A'
                       AND atd_new.History_Status = 'A')
        LOOP
            Copy_At_Signers_To_New_Act (p_At_id,
                                        p_New_At_Id,
                                        v_At_Doc.atd_id,
                                        v_At_Doc.new_at_id,
                                        v_At_Doc.atd_atp,
                                        v_At_Doc.new_atd_atp);
            NULL;
        END LOOP;
    END;


    --====================================================--
    --   Копіювання секцій в новий акт
    --====================================================--
    PROCEDURE Copy_At_Section_To_New_Act (
        p_At_id        IN Act.At_Id%TYPE,
        p_New_At_Id    IN Act.At_Id%TYPE,
        p_Atp_Id       IN At_Person.Atp_Id%TYPE,
        p_New_Atp_Id   IN At_Person.Atp_Id%TYPE)
    IS
        v_New_Ate_Id   At_Document.Atd_Id%TYPE;
    BEGIN
        FOR v_At_Sec
            IN (SELECT ate_id,
                       ate_atp,
                       ate_at,
                       ate_nng,
                       ate_chield_info,
                       ate_parent_info,
                       ate_notes,
                       ate_indicator_value1,
                       ate_indicator_value2
                  FROM at_section
                 WHERE     Ate_At = p_At_id
                       AND (   Ate_Atp = p_Atp_Id
                            OR (Ate_Atp IS NULL AND p_Atp_Id IS NULL)))
        LOOP
            INSERT INTO at_section (ate_id,
                                    ate_atp,
                                    ate_at,
                                    ate_nng,
                                    ate_chield_info,
                                    ate_parent_info,
                                    ate_notes,
                                    ate_indicator_value1,
                                    ate_indicator_value2)
                 VALUES (0,
                         p_New_Atp_Id,
                         p_New_At_Id,
                         v_At_Sec.ate_nng,
                         v_At_Sec.ate_chield_info,
                         v_At_Sec.ate_parent_info,
                         v_At_Sec.ate_notes,
                         v_At_Sec.ate_indicator_value1,
                         v_At_Sec.ate_indicator_value2)
              RETURNING ate_id
                   INTO v_New_Ate_Id;


            INSERT INTO at_section_feature (atef_id,
                                            atef_ate,
                                            atef_at,
                                            atef_nda,
                                            atef_feature,
                                            atef_notes)
                SELECT 0,
                       v_New_Ate_Id,
                       p_New_At_Id,
                       atef_nda,
                       atef_feature,
                       atef_notes
                  FROM at_section_feature
                 WHERE atef_ate = v_At_Sec.ate_id;
        END LOOP;
    END;

    --====================================================--
    --   Копіювання специфікацій в новий акт
    --====================================================--
    PROCEDURE Copy_At_Other_Spec_To_New_Act (
        p_At_id        IN Act.At_Id%TYPE,
        p_New_At_Id    IN Act.At_Id%TYPE,
        p_Atp_Id       IN At_Person.Atp_Id%TYPE,
        p_New_Atp_Id   IN At_Person.Atp_Id%TYPE)
    IS
        v_New_Atop_Id   At_Other_Spec.Atop_Id%TYPE;
    --v_Atp_Num      At_Person.Atp_Num%TYPE;
    BEGIN
        FOR v_At_Spec
            IN (SELECT atop_id,
                       atop_at,
                       atop_fn,
                       atop_mn,
                       atop_ln,
                       atop_phone,
                       atop_atip,
                       atop_position,
                       atop_tp,
                       history_status,
                       atop_atr,
                       atop_notes,
                       atop_order,
                       atop_atp
                  FROM at_other_spec
                 WHERE     atop_at = p_At_id
                       AND (   Atop_Atp = p_Atp_Id
                            OR (Atop_Atp IS NULL AND p_Atp_Id IS NULL)))
        LOOP
            INSERT INTO at_other_spec (atop_id,
                                       atop_at,
                                       atop_fn,
                                       atop_mn,
                                       atop_ln,
                                       atop_phone,
                                       atop_atip,
                                       atop_position,
                                       atop_tp,
                                       history_status,
                                       atop_atr,
                                       atop_notes,
                                       atop_order,
                                       atop_atp)
                 VALUES (0,
                         p_New_At_Id,
                         v_At_Spec.atop_fn,
                         v_At_Spec.atop_mn,
                         v_At_Spec.atop_ln,
                         v_At_Spec.atop_phone,
                         NULL,
                         v_At_Spec.atop_position,
                         v_At_Spec.atop_tp,
                         v_At_Spec.history_status,
                         NULL,
                         v_At_Spec.atop_notes,
                         v_At_Spec.atop_order,
                         p_New_Atp_Id)
              RETURNING atop_id
                   INTO v_New_Atop_Id;
        END LOOP;
    END;


    --====================================================--
    --   Копіювання послуг в новий акт
    --====================================================--
    PROCEDURE Copy_At_Service_To_New_Act (p_At_id       IN Act.At_Id%TYPE,
                                          p_New_At_Id   IN Act.At_Id%TYPE)
    IS
        v_New_Ats_Id   At_Service.Ats_Id%TYPE;
    BEGIN
        FOR v_At_Ser IN (SELECT ats_id,
                                ats_at,
                                ats_nst,
                                history_status,
                                ats_at_src,
                                ats_st,
                                ats_ss_method,
                                ats_ss_address_tp,
                                ats_ss_address,
                                ats_tarif_sum,
                                ats_act_sum,
                                ats_ss_term,
                                ats_hs_decision
                           FROM at_service
                          WHERE Ats_At = p_At_id AND history_status = 'A')
        LOOP
            INSERT INTO at_service (ats_id,
                                    ats_at,
                                    ats_nst,
                                    history_status,
                                    ats_at_src,
                                    ats_st,
                                    ats_ss_method,
                                    ats_ss_address_tp,
                                    ats_ss_address,
                                    ats_tarif_sum,
                                    ats_act_sum,
                                    ats_ss_term,
                                    ats_hs_decision)
                 VALUES (0,
                         p_New_At_Id,
                         v_At_Ser.ats_nst,
                         'A',
                         v_At_Ser.ats_at_src,
                         v_At_Ser.ats_st,
                         v_At_Ser.ats_ss_method,
                         v_At_Ser.ats_ss_address_tp,
                         v_At_Ser.ats_ss_address,
                         v_At_Ser.ats_tarif_sum,
                         v_At_Ser.ats_act_sum,
                         v_At_Ser.ats_ss_term,
                         v_At_Ser.ats_hs_decision)
              RETURNING ats_id
                   INTO v_New_Ats_Id;

            INSERT INTO at_reject_info (ari_id,
                                        ari_at,
                                        ari_nrr,
                                        ari_njr,
                                        ari_ats)
                SELECT 0,
                       p_New_At_Id,
                       ari_nrr,
                       ari_njr,
                       v_New_Ats_Id
                  FROM at_reject_info
                 WHERE ari_at = p_At_id AND ari_ats = v_At_Ser.Ats_Id;
        END LOOP;

        INSERT INTO at_reject_info (ari_id,
                                    ari_at,
                                    ari_nrr,
                                    ari_njr,
                                    ari_ats)
            SELECT 0,
                   p_New_At_Id,
                   ari_nrr,
                   ari_njr,
                   v_New_Ats_Id
              FROM at_reject_info
             WHERE ari_at = p_At_id AND ari_ats IS NULL;
    END;

    --====================================================--
    --   Копіювання логів в новий акт
    --====================================================--
    PROCEDURE Copy_At_Logs_To_New_Act (p_At_id       IN Act.At_Id%TYPE,
                                       p_New_At_Id   IN Act.At_Id%TYPE)
    IS
    BEGIN
        INSERT INTO AT_LOG (ATL_AT,
                            ATL_HS,
                            ATL_ST,
                            ATL_MESSAGE,
                            ATL_ST_OLD,
                            ATL_TP)
            SELECT p_New_At_Id,
                   ATL_HS,
                   ATL_ST,
                   ATL_MESSAGE,
                   ATL_ST_OLD,
                   ATL_TP
              FROM AT_LOG
             WHERE ATL_AT = p_At_id;
    END;

    --====================================================--
    --   Копіювання учасників в новий акт
    --====================================================--
    PROCEDURE Copy_At_Person_To_New_Act (
        p_At_id            IN Act.At_Id%TYPE,
        p_New_At_Id        IN Act.At_Id%TYPE,
        p_With_Signers     IN NUMBER DEFAULT 1,
        p_With_Documents   IN NUMBER DEFAULT 1)
    IS
        l_New_Atp_id   At_Person.Atp_Id%TYPE;
    BEGIN
        FOR v_Act_Persons
            IN (SELECT Atp_Id,
                       Atp_At,
                       Atp_Sc,
                       Atp_Fn,
                       Atp_Mn,
                       Atp_Ln,
                       Atp_Birth_Dt,
                       Atp_Relation_Tp,
                       Atp_Is_Disabled,
                       Atp_Is_Capable,
                       Atp_Work_Place,
                       Atp_Is_Adr_Matching,
                       Atp_Phone,
                       Atp_Notes,
                       Atp_Live_Address,
                       Atp_Tp,
                       Atp_Cu,
                       Atp_App_Tp,
                       Atp_Fact_Address,
                       Atp_Is_Disordered,
                       Atp_Disorder_Record,
                       Atp_Disable_Record,
                       Atp_Capable_Record,
                       Atp_Sex,
                       Atp_Citizenship,
                       Atp_Is_Selfservice,
                       Atp_Is_Vpo,
                       Atp_Is_Orphan,
                       Atp_Email,
                       Atp_Num,
                       Atp_App
                  FROM at_person
                 WHERE Atp_At = p_At_Id AND History_Status = 'A')
        LOOP
            --#APP_NUM
            INSERT INTO At_Person (Atp_Id,
                                   Atp_At,
                                   Atp_Sc,
                                   Atp_Fn,
                                   Atp_Mn,
                                   Atp_Ln,
                                   Atp_Birth_Dt,
                                   Atp_Relation_Tp,
                                   Atp_Is_Disabled,
                                   Atp_Is_Capable,
                                   Atp_Work_Place,
                                   Atp_Is_Adr_Matching,
                                   Atp_Phone,
                                   Atp_Notes,
                                   Atp_Live_Address,
                                   Atp_Tp,
                                   Atp_Cu,
                                   Atp_App_Tp,
                                   Atp_Fact_Address,
                                   Atp_Is_Disordered,
                                   Atp_Disorder_Record,
                                   Atp_Disable_Record,
                                   Atp_Capable_Record,
                                   Atp_Sex,
                                   Atp_Citizenship,
                                   Atp_Is_Selfservice,
                                   Atp_Is_Vpo,
                                   Atp_Is_Orphan,
                                   Atp_Email,
                                   Atp_Num,
                                   Atp_App,
                                   History_Status)
                 VALUES (0,
                         p_New_At_Id,
                         v_Act_Persons.Atp_Sc,
                         v_Act_Persons.Atp_Fn,
                         v_Act_Persons.Atp_Mn,
                         v_Act_Persons.Atp_Ln,
                         v_Act_Persons.Atp_Birth_Dt,
                         v_Act_Persons.Atp_Relation_Tp,
                         v_Act_Persons.Atp_Is_Disabled,
                         v_Act_Persons.Atp_Is_Capable,
                         v_Act_Persons.Atp_Work_Place,
                         v_Act_Persons.Atp_Is_Adr_Matching,
                         v_Act_Persons.Atp_Phone,
                         v_Act_Persons.Atp_Notes,
                         v_Act_Persons.Atp_Live_Address,
                         v_Act_Persons.Atp_Tp,
                         v_Act_Persons.Atp_Cu,
                         v_Act_Persons.Atp_App_Tp,
                         v_Act_Persons.Atp_Fact_Address,
                         v_Act_Persons.Atp_Is_Disordered,
                         v_Act_Persons.Atp_Disorder_Record,
                         v_Act_Persons.Atp_Disable_Record,
                         v_Act_Persons.Atp_Capable_Record,
                         v_Act_Persons.Atp_Sex,
                         v_Act_Persons.Atp_Citizenship,
                         v_Act_Persons.Atp_Is_Selfservice,
                         v_Act_Persons.Atp_Is_Vpo,
                         v_Act_Persons.Atp_Is_Orphan,
                         v_Act_Persons.Atp_Email,
                         v_Act_Persons.Atp_Num,
                         v_Act_Persons.Atp_App,
                         'A')
              RETURNING Atp_Id
                   INTO l_New_Atp_id;

            --копіювання документів по акту особи
            IF NVL (p_With_Documents, 1) = 1
            THEN
                Copy_At_Documents_To_New_Act (p_At_Id,
                                              p_New_At_Id,
                                              v_Act_Persons.Atp_Id,
                                              l_New_Atp_id);
            END IF;

            IF NVL (p_With_Signers, 1) = 1
            THEN
                Copy_At_Signers_To_New_Act (p_At_id,
                                            p_New_At_Id,
                                            NULL,
                                            NULL,
                                            v_Act_Persons.Atp_Id,
                                            l_New_Atp_id);
            END IF;

            Copy_At_Section_To_New_Act (p_At_Id,
                                        p_New_At_Id,
                                        v_Act_Persons.Atp_Id,
                                        l_New_Atp_id);
        END LOOP;
    END;

    --====================================================--
    --   Копіювання даних акту в новий акт
    --====================================================--
    PROCEDURE Copy_At_To_New (p_At_id            IN     Act.At_Id%TYPE,
                              p_New_At_Tp        IN     Act.At_Tp%TYPE,
                              p_New_At_Id           OUT Act.At_Id%TYPE,
                              p_With_Signers     IN     NUMBER DEFAULT 1,
                              p_With_Documents   IN     NUMBER DEFAULT 1,
                              p_With_Logs        IN     NUMBER DEFAULT 0)
    IS
        l_New_At_St   Act.At_St%TYPE;
    --l_New_Atd_id At_Document.Atd_Id%TYPE;
    BEGIN
        --Отримання початковго статусу акту
        --dbms_output.put_line('BEGIN select DIC_VALUE INTO :val from uss_ndi.V_DDN_AT_'||p_New_At_Tp||'_ST where dic_srtordr=1; END;');
        EXECUTE IMMEDIATE   'BEGIN select DIC_VALUE INTO :val from uss_ndi.V_DDN_AT_'
                         || p_New_At_Tp
                         || '_ST where dic_srtordr=1; END;'
            USING OUT l_New_At_St;

        --Створення акту
        p_New_At_Id := Sq_Id_Act.NEXTVAL;

        INSERT INTO act (at_id,
                         at_tp,
                         at_pc,
                         at_num,
                         at_dt,
                         at_org,
                         at_sc,
                         at_rnspm,
                         at_rnp,
                         at_ap,
                         at_st,
                         at_src,
                         at_case_class,
                         at_main_link_tp,
                         at_main_link,
                         at_action_start_dt,
                         at_action_stop_dt,
                         at_notes,
                         at_family_info,
                         at_live_address,
                         at_wu,
                         at_cu,
                         at_conclusion_tp,
                         at_form_tp,
                         at_redirect_rnspm)
            SELECT p_New_At_Id,
                   p_New_At_Tp,
                   at_pc,
                   at_num,
                   SYSDATE,
                   at_org,
                   at_sc,
                   at_rnspm,
                   at_rnp,
                   at_ap,
                   l_New_At_St,
                   at_src,
                   at_case_class,
                   at_main_link_tp,
                   at_main_link,
                   at_action_start_dt,
                   at_action_stop_dt,
                   at_notes,
                   at_family_info,
                   at_live_address,
                   at_wu,
                   at_cu,
                   at_conclusion_tp,
                   at_form_tp,
                   at_redirect_rnspm
              FROM act
             WHERE at_id = p_At_id;

        /*
        Нижче йде копіювання послуг
        INSERT INTO at_service
          (ats_id, ats_at, ats_nst, history_status, ats_at_src, ats_st, ats_ss_method, ats_ss_address_tp, ats_ss_address, ats_tarif_sum, ats_act_sum, ats_hs_decision)
        SELECT
          0, p_New_At_Id, ats_nst, history_status, ats_at_src, ats_st, ats_ss_method, ats_ss_address_tp, ats_ss_address, ats_tarif_sum, ats_act_sum, ats_hs_decision
        FROM at_service s
        WHERE s.ats_at = p_At_id
          AND History_Status = 'A';
        */

        --копіювання осіб по акту
        Copy_At_Person_To_New_Act (p_At_Id,
                                   p_New_At_Id,
                                   p_With_Signers,
                                   p_With_Documents);

        --копіювання документів по акту без особи
        IF NVL (p_With_Documents, 1) = 1
        THEN
            Copy_At_Documents_To_New_Act (p_At_Id,
                                          p_New_At_Id,
                                          NULL,
                                          NULL);
        END IF;

        IF NVL (p_With_Signers, 1) = 1
        THEN
            Copy_At_Signers_To_New_Act (p_At_id,
                                        p_New_At_Id,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL);
        END IF;

        IF NVL (p_With_logs, 0) = 1
        THEN
            Copy_At_Logs_To_New_Act (p_At_Id, p_New_At_Id);
        END IF;

        Copy_At_Section_To_New_Act (p_At_Id,
                                    p_New_At_Id,
                                    NULL,
                                    NULL);
        Copy_At_Other_Spec_To_New_Act (p_At_Id,
                                       p_New_At_Id,
                                       NULL,
                                       NULL);
        Copy_At_Service_To_New_Act (p_At_Id, p_New_At_Id);

        INSERT INTO At_Links (Atk_At, Atk_Link_At, Atk_Tp)
             VALUES (p_New_At_Id, p_At_id, p_New_At_Tp);
    END;

    --====================================================--
    --   Додавання даних акту в інший акт
    --====================================================--
    PROCEDURE Merge_At_To_New (p_At_id            IN Act.At_Id%TYPE,
                               p_New_At_Id        IN Act.At_Id%TYPE,
                               p_With_Signers     IN NUMBER DEFAULT 1,
                               p_With_Documents   IN NUMBER DEFAULT 1,
                               p_With_Logs        IN NUMBER DEFAULT 0)
    IS
        l_New_At   ACT%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_New_At
          FROM act
         WHERE at_id = p_At_id;

        --копіювання осіб по акту
        Copy_At_Person_To_New_Act (p_At_Id,
                                   p_New_At_Id,
                                   p_With_Signers,
                                   p_With_Documents);

        --копіювання документів по акту без особи
        IF NVL (p_With_Documents, 1) = 1
        THEN
            Copy_At_Documents_To_New_Act (p_At_Id,
                                          p_New_At_Id,
                                          NULL,
                                          NULL);
        END IF;

        IF NVL (p_With_Signers, 1) = 1
        THEN
            Copy_At_Signers_To_New_Act (p_At_id,
                                        p_New_At_Id,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL);
        END IF;

        IF NVL (p_With_logs, 0) = 1
        THEN
            Copy_At_Logs_To_New_Act (p_At_Id, p_New_At_Id);
        END IF;

        Copy_At_Section_To_New_Act (p_At_Id,
                                    p_New_At_Id,
                                    NULL,
                                    NULL);
        Copy_At_Other_Spec_To_New_Act (p_At_Id,
                                       p_New_At_Id,
                                       NULL,
                                       NULL);
        Copy_At_Service_To_New_Act (p_At_Id, p_New_At_Id);

        INSERT INTO At_Links (Atk_At, Atk_Link_At, Atk_Tp)
             VALUES (p_New_At_Id, p_At_id, l_New_At.At_Tp);
    END;


    FUNCTION Get_At_Tp_By_Ap (p_Ap_Id     IN NUMBER,
                              p_Ap_Tp     IN VARCHAR2,
                              p_Ap_Main   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (50);
    BEGIN
        l_Res :=
            CASE
                WHEN p_Ap_Tp = 'R.OS'
                THEN
                    'RSTOPSS'
                WHEN p_Ap_Tp = 'R.GS'
                THEN
                    'RSTOPSS'
                WHEN     p_Ap_Tp = 'SS'
                     AND API$Appeal.Is_Appeal_Maked_Correct (p_Ap_Id) = 0
                     AND (   API$Appeal.Get_Ap_Attr_Str (p_Ap_Id     => p_Ap_Id,
                                                         p_Nda_Id    => 1870,
                                                         p_Default   => 'F') =
                             'T'
                          OR API$Appeal.Get_Ap_Attr_Str (p_Ap_Id     => p_Ap_Id,
                                                         p_Nda_Id    => 1947,
                                                         p_Default   => 'F') =
                             'T'
                          OR API$Appeal.Get_Ap_Attr_Str (p_Ap_Id     => p_Ap_Id,
                                                         p_Nda_Id    => 8263,
                                                         p_Default   => 'F') =
                             'T')
                THEN
                    'ANPOE'
                WHEN     p_Ap_Tp = 'SS'
                     AND API$Appeal.Is_Appeal_Maked_Correct (p_Ap_Id) = 0
                     AND API$Appeal.Is_Aps_Exists (p_Ap_Id, 420) > 0
                THEN
                    'OKS'
                WHEN     p_Ap_Tp = 'SS'
                     AND API$Appeal.Is_Appeal_Maked_Correct (p_Ap_Id) = 0
                THEN
                    'APOP'
                WHEN p_Ap_Tp = 'SS'
                THEN
                    'PDSP'
            END;
        RETURN l_Res;
    END;

    FUNCTION Get_At_St_By_Ap (p_At_Tp IN VARCHAR2, p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res              VARCHAR2 (50);
        l_App              Appeal%ROWTYPE;
        l_Is_App_Correct   NUMBER;
        l_ap_init_doc      NUMBER;
        l_ap_attr_3688     VARCHAR2 (500) := '-';
        l_ap_attr_3687     VARCHAR2 (500) := '-';
        l_ap_attr_3261     VARCHAR2 (500) := '-';
        l_ap_attr_1872     VARCHAR2 (500) := '-';
        l_ap_attr_3689     VARCHAR2 (500) := '-';
        l_ap_attr_3263     VARCHAR2 (500) := '-';
        l_ap_attr_1870     VARCHAR2 (500) := '-';
        l_ap_attr_3686     VARCHAR2 (500) := '-';
        l_apd_864          VARCHAR2 (500) := '-';
    BEGIN
        SELECT *
          INTO l_App
          FROM Appeal
         WHERE ap_id = p_ap_id;

        SELECT MAX (apd.apd_ndt)
          INTO l_ap_init_doc
          FROM ap_document apd
         WHERE     apd_ap = p_ap_id
               AND apd_ndt IN (835,
                               802,
                               801,
                               836);

        SELECT CASE WHEN COUNT (1) = 0 THEN 'F' ELSE 'T' END
          INTO l_apd_864
          FROM ap_document apd
         WHERE apd_ap = p_ap_id AND apd_ndt IN (864);

        IF l_ap_init_doc = 801
        THEN
            l_ap_attr_3688 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3688, '-');
            l_ap_attr_1872 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 1872, '-');
            l_ap_attr_1870 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 1870, 'F');
        ELSIF l_ap_init_doc = 802
        THEN
            l_ap_attr_3687 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3687, '-');
            l_ap_attr_3689 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3689, '-');
        ELSIF l_ap_init_doc = 835
        THEN
            l_ap_attr_3261 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3261, '-');
            l_ap_attr_3263 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3263, '-');
        ELSIF l_ap_init_doc = 836
        THEN
            l_ap_attr_3686 := Api$appeal.Get_Ap_Attr_Str (p_Ap_Id, 3686, '-');
        END IF;

        l_Is_App_Correct := API$Appeal.Is_Appeal_Maked_Correct (p_Ap_Id);

        --#90840
        IF     p_At_Tp = 'PDSP'
           AND l_Is_App_Correct = 1
           --Проверка, что Ap_Ap_Main пусто
           AND l_App.Ap_Ap_Main IS NULL
           AND (   (l_ap_init_doc = 801 AND l_ap_attr_3688 != 'G')
                OR (l_ap_init_doc = 802 AND l_ap_attr_3687 != 'G')
                OR (l_ap_init_doc = 835 AND l_ap_attr_3261 != 'G'))
        THEN
            l_Res := 'SC';
        ELSIF     p_At_Tp = 'PDSP'
              AND l_Is_App_Correct = 1
              --Проверка, что Ap_Ap_Main пусто
              AND l_App.Ap_Ap_Main IS NULL
              AND (   (    l_ap_init_doc = 801
                       AND l_ap_attr_3688 = 'G'
                       AND l_ap_attr_1872 = '-')
                   OR (    l_ap_init_doc = 802
                       AND l_ap_attr_3687 = 'G'
                       AND l_ap_attr_3689 = '-')
                   OR (    l_ap_init_doc = 835
                       AND l_ap_attr_3261 = 'G'
                       AND l_ap_attr_3263 = '-'))
        THEN
            l_Res := 'SC';
        ELSIF     p_At_Tp = 'PDSP'
              AND l_Is_App_Correct = 1
              --Проверка, что Ap_Ap_Main не пусто
              AND l_App.Ap_Ap_Main IS NOT NULL
              AND (   (l_ap_init_doc = 801 AND l_ap_attr_3688 != 'G')
                   OR (l_ap_init_doc = 802 AND l_ap_attr_3687 != 'G')
                   OR (l_ap_init_doc = 835 AND l_ap_attr_3261 != 'G'))
        THEN
            l_Res := 'SR';
        ELSIF     p_At_Tp = 'PDSP'
              AND l_Is_App_Correct = 1
              --Проверка, что Ap_Ap_Main не пусто
              AND l_App.Ap_Ap_Main IS NOT NULL
              AND (   (    l_ap_init_doc = 801
                       AND l_ap_attr_3688 = 'G'
                       AND l_ap_attr_1872 != '-')
                   OR (    l_ap_init_doc = 802
                       AND l_ap_attr_3687 = 'G'
                       AND l_ap_attr_3689 != '-')
                   OR (    l_ap_init_doc = 835
                       AND l_ap_attr_3261 = 'G'
                       AND l_ap_attr_3263 != '-'))
        THEN
            l_Res := 'SR';
        ELSIF p_At_Tp = 'OKS'
        THEN
            l_Res := 'TN';
        ELSIF p_At_Tp = 'APOP'
        THEN
            l_Res := 'AN';
        ELSIF p_At_Tp = 'ANPOE'
        THEN
            l_Res := 'XN';
        ELSIF     p_At_Tp = 'PDSP'
              AND l_ap_attr_3688 = 'G'
              AND l_ap_attr_1872 != '-'
              AND l_ap_attr_1870 = 'T'
        THEN
            l_Res := 'SR';
        ELSIF p_At_Tp = 'PDSP' AND l_ap_attr_3688 = 'G'
        THEN
            l_Res := 'SP1';
        ELSIF p_At_Tp = 'PDSP' AND l_ap_attr_3687 = 'G'
        THEN
            l_Res := 'SP1';
        ELSIF p_At_Tp = 'PDSP' AND l_ap_attr_3261 = 'G'
        THEN
            l_Res := 'SP1';
        ELSIF p_At_Tp = 'PDSP' AND l_ap_attr_3686 = 'G'
        THEN
            l_Res := 'SP1';
        ELSIF p_At_Tp = 'PDSP'
        THEN
            l_Res := 'SR';
        END IF;

        RETURN l_Res;
    END;

    --  Функція формування проектів актів про припинення наданя соцпослуг
    --  p_mode 1,3,5=з p_ap_id, 2=з таблиці tmp_work_ids,  5-не повертати повідомлення
    PROCEDURE Init_Act_By_Appeals (p_Mode           INTEGER,
                                   p_Ap_Id          Appeal.Ap_Id%TYPE,
                                   p_Messages   OUT SYS_REFCURSOR)
    IS
        l_Cnt          INTEGER;
        l_Ats_Cnt      INTEGER;
        l_Lock_Init    Tools.t_Lockhandler;
        l_Lock         Tools.t_Lockhandler;
        g_Messages     Tools.t_Messages := Tools.t_Messages ();
        l_Num          Pc_Account.Pa_Num%TYPE;
        l_Hs           Histsession.Hs_Id%TYPE;
        l_Com_Org      Pc_Decision.Com_Org%TYPE;
        --l_Com_Wu    Pc_Decision.Com_Wu%TYPE;
        l_app_sc       NUMBER;
        l_app_scc      NUMBER;
        l_app_pc       NUMBER;
        --l_New_Ate_Id NUMBER;
        l_New_At_Id    NUMBER;
        l_New_Atd_Id   NUMBER;
        --l_New_Atda_Id NUMBER;
        --l_Ats_Id      NUMBER;
        --l_Atp_id      NUMBER;
        l_At_Tp        VARCHAR2 (10);
        l_At_St        VARCHAR2 (10);
        l_At_Data      Act%ROWTYPE;
    --l_At_Case_Class Act.At_Case_Class%TYPE;
    BEGIN
        /*
        IF p_Mode IN (1, 2) THEN
          l_Com_Org := Tools.Getcurrorg;
          l_Com_Wu := Tools.Getcurrwu;
          IF l_Com_Org IS NULL THEN
            Raise_Application_Error(-20000, 'Не можу визначити орган призначення!');
          END IF;
          IF l_Com_Wu IS NULL THEN
            Raise_Application_Error(-20000, 'Не можу визначити користувача!');
          END IF;
        END IF;
        */
        l_Lock_Init :=
            Tools.Request_Lock (
                p_Descr   => 'INIT_ACT_' || p_Ap_Id,
                p_Error_Msg   =>
                       'В даний момент вже виконується створення актів про припинення наданя соцпослуг '
                    || p_Ap_Id
                    || '!');

        --  raise_application_error(-20000, 'p_mode='||p_mode||'    p_ap_id='||p_ap_id);

        IF p_Mode IN (1, 3, 5) AND p_Ap_Id IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Ap_Id
                  FROM Appeal
                 WHERE     Ap_Id = p_Ap_Id
                       AND Ap_St IN ('O')
                       AND Ap_Tp IN ('R.OS', 'R.GS', 'SS');

            l_Cnt := SQL%ROWCOUNT;


            Tools.LOG (
                p_src              => UPPER ('USS_ESR.Api$act.Init_Act_By_Appeals'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_Ap_Id,
                p_regular_params   => 'Alone appeal. p_Mode=' || p_Mode);
        ELSE
            SELECT COUNT (*)
              INTO l_Cnt
              FROM Tmp_Work_Ids, Appeal
             WHERE     x_Id = Ap_Id
                   AND Ap_St IN ('O')
                   AND Ap_Tp IN ('R.OS', 'R.GS', 'SS');


            FOR vAp
                IN (SELECT ap_id
                      FROM Tmp_Work_Ids, Appeal
                     WHERE     x_Id = Ap_Id
                           AND Ap_St IN ('O')
                           AND Ap_Tp IN ('R.OS', 'R.GS', 'SS'))
            LOOP
                Tools.LOG (
                    p_src              => UPPER ('USS_ESR.Api$act.Init_Act_By_Appeals'),
                    p_obj_tp           => 'APPEAL',
                    p_obj_id           => vAp.Ap_Id,
                    p_regular_params   => 'Appeal in list. p_Mode=' || p_Mode);
            END LOOP;
        END IF;

        IF l_Cnt = 0
        THEN
            Raise_Application_Error (
                -20000,
                'В функцію формування проектів актів про припинення наданя соцпослуг!');
        END IF;

        l_Hs := Tools.Gethistsession;

        --Створюємо проекти рішень в стані "Розраховується" для тих послуг, по яким вказано флаг nst_is_or_generate (і якщо ще не створено по зверненню і такій послузі нічого)
        --для зверненнь "Допомога"
        INSERT INTO Act (At_Id,
                         At_Pc,
                         At_Ap,
                         At_St,
                         At_Num,
                         At_Dt,
                         At_Org,
                         At_Rnspm,
                         At_Rnp,
                         At_Sc,
                         At_Src,
                         At_Tp,
                         at_case_class,
                         At_Wu,
                         at_cu)
            SELECT DISTINCT
                   0,
                   Ap_Pc,
                   Ap_Id,
                   CASE Ap_Tp
                       WHEN 'R.OS' THEN 'RS.C'
                       WHEN 'R.GS' THEN 'RS.N'
                       WHEN 'SS' THEN 'SC'
                   END,
                   --             'SC',
                   '',
                   SYSDATE,
                   NVL (l_Com_Org, Ap.Com_Org),
                   NULL,
                   NULL,
                   Pc_Sc,
                   Ap_Src,
                   API$ACT.Get_At_Tp_By_Ap (Ap.Ap_Id,
                                            Ap.Ap_Tp,
                                            Ap.Ap_Ap_Main),
                   CASE
                       WHEN api$appeal.Get_Ap_Attr_Str (ap_id, 1870, 'F') =
                            'T'
                       THEN
                           'EM'
                       --#103625
                       WHEN     API$ACT.Get_At_Tp_By_Ap (Ap.Ap_Id,
                                                         Ap.Ap_Tp,
                                                         Ap.Ap_Ap_Main) IN
                                    ('APOP', 'ANPOE')
                            AND (   API$APPEAL.Get_Ap_Attr_Str (
                                        p_Ap_Id     => Ap.Ap_Id,
                                        p_Nda_Id    => 1870,
                                        p_Default   => 'F') =
                                    'T'
                                 OR API$APPEAL.Get_Ap_Attr_Str (
                                        p_Ap_Id     => Ap.Ap_Id,
                                        p_Nda_Id    => 1947,
                                        p_Default   => 'F') =
                                    'T'
                                 OR API$APPEAL.Get_Ap_Attr_Str (
                                        p_Ap_Id     => Ap.Ap_Id,
                                        p_Nda_Id    => 8263,
                                        p_Default   => 'F') =
                                    'T')
                       THEN
                           'EM'
                       ELSE
                           ''
                   END,
                   ap.com_wu,
                   CASE
                       WHEN     api$appeal.Get_Ap_Attr_Str (ap.ap_id,
                                                            8415,
                                                            'F') =
                                'T'
                            AND ap.ap_ap_main IS NOT NULL
                       THEN
                           (SELECT MAX (at_cu)
                              FROM act at
                             WHERE     at.at_ap = ap.ap_ap_main
                                   AND at.at_tp IN ('OKS', 'APOP', 'ANPOE'))
                       ELSE
                           NULL
                   END
              --Api$personalcase.Get_Scc_By_Appeal(Ap_Id),
              FROM Tmp_Work_Ids
                   JOIN Appeal Ap ON Ap_Id = x_Id
                   LEFT OUTER JOIN Personalcase ON Pc_Id = Ap_Pc
             WHERE     Ap_Tp IN ('R.OS', 'R.GS', 'SS')
                   AND NOT EXISTS
                           (SELECT 1
                              FROM Act z
                             WHERE     z.At_Ap = Ap_Id
                                   AND z.at_tp =
                                       API$ACT.Get_At_Tp_By_Ap (
                                           Ap.Ap_Id,
                                           Ap.Ap_Tp,
                                           Ap.Ap_Ap_Main));

        --l_Cnt := SQL%ROWCOUNT;

        --Трошки спростимо собі життя, зв'яжемо звернення і акт PDSP/RSTOPSS
        DELETE FROM Tmp_Work_Set1
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Set1 (x_Id1, x_Id2)
            SELECT at_ap, at_id
              FROM Tmp_Work_Ids
                   JOIN Act
                       ON     at_Ap = x_Id
                          AND at_tp IN ('PDSP', 'RSTOPSS', 'APOP');

        --l_Cnt := SQL%ROWCOUNT;

        UPDATE At_Service Ats
           SET Ats.History_Status = 'H', Ats.Ats_St = 'R'
         WHERE EXISTS
                   (SELECT 1
                      FROM Tmp_Work_Set1
                           JOIN ap_service aps
                               ON aps_ap = x_id1 AND aps.history_status = 'H'
                     WHERE Ats.Ats_At = x_id2 AND ats_nst = aps_nst);

        --l_Cnt := SQL%ROWCOUNT;

        UPDATE At_Service Ats
           SET Ats.History_Status = 'A', Ats.Ats_St = 'R'
         WHERE EXISTS
                   (SELECT 1
                      FROM Tmp_Work_Set1
                           JOIN ap_service aps
                               ON aps_ap = x_id1 AND aps.history_status = 'A'
                     WHERE Ats.Ats_At = x_id2 AND ats_nst = aps_nst);

        IF (g_At_Service_Init_List IS NOT NULL)
        THEN
            FORALL j
                IN g_At_Service_Init_List.FIRST ..
                   g_At_Service_Init_List.LAST
                INSERT INTO At_Service (Ats_Id,
                                        Ats_At,
                                        Ats_Nst,
                                        Ats_St,
                                        Ats_at_src,
                                        History_Status)
                    SELECT 0,
                           x_Id2,
                           Aps_Nst,
                           'R',
                           x_Id2,
                           History_Status
                      FROM Tmp_Work_Set1
                           JOIN Ap_Service aps
                               ON Aps_Ap = x_Id1 AND aps.history_status = 'A'
                     WHERE     aps.aps_nst =
                               g_At_Service_Init_List (j).Ats_Nst
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM At_Service ats
                                     WHERE     Ats_At = x_id2
                                           AND Ats_Nst = Aps_Nst)
                           AND Aps.History_Status = 'A';

            --Треба обнулити перелік послуг, щоб не використати їх при неступному виклаку
            g_At_Service_Init_List := NULL;
        ELSE
            INSERT INTO At_Service (Ats_Id,
                                    Ats_At,
                                    Ats_Nst,
                                    Ats_St,
                                    Ats_at_src,
                                    History_Status)
                SELECT 0,
                       x_Id2,
                       Aps_Nst,
                       'R',
                       x_Id2,
                       History_Status
                  FROM Tmp_Work_Set1
                       JOIN Ap_Service aps
                           ON Aps_Ap = x_Id1 AND aps.history_status = 'A'
                 WHERE     NOT EXISTS
                               (SELECT 1
                                  FROM At_Service ats
                                 WHERE Ats_At = x_id2 AND Ats_Nst = Aps_Nst)
                       AND Aps.History_Status = 'A';
        --l_Ats_Cnt := SQL%ROWCOUNT;
        END IF;

        --#112009
        UPDATE at_service ats2
           SET ats_ss_term =
                   (SELECT ats1.ats_ss_term
                      FROM Tmp_Work_Set1  t
                           JOIN appeal ap1 ON t.x_id1 = ap1.ap_id
                           JOIN act at1
                               ON     at1.at_ap = ap1.ap_ap_main
                                  AND at1.at_tp = 'APOP'
                                  AND at1.at_st IN ('AS')
                           JOIN at_service ats1
                               ON (    at1.at_id = ats1.ats_at
                                   AND ats1.history_status = 'A')
                     WHERE     ats2.ats_at = t.x_id2
                           AND ats2.ats_nst = ats1.ats_nst)
         WHERE     EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Set1  t
                               JOIN act at2
                                   ON     t.x_id2 = at2.at_id
                                      AND t.x_id2 = ats2.ats_at
                                      AND at2.at_tp IN ('PDSP')
                               JOIN appeal ap2
                                   ON     t.x_id1 = ap2.ap_id
                                      AND ap2.ap_ap_main IS NOT NULL)
               AND ats_ss_term IS NULL;


        -- #115466
        UPDATE at_service ats2
           SET ats_ss_term =
                   (SELECT ats1.ats_ss_term
                      FROM Tmp_Work_Set1  t
                           JOIN appeal ap1 ON t.x_id1 = ap1.ap_id
                           JOIN act at1
                               ON     at1.at_ap = ap1.ap_ap_main
                                  AND at1.at_tp = 'ANPOE'
                                  AND at1.at_st IN ('XP')
                           JOIN at_service ats1
                               ON (    at1.at_id = ats1.ats_at
                                   AND ats1.history_status = 'A')
                     WHERE     ats2.ats_at = t.x_id2
                           AND ats2.ats_nst = ats1.ats_nst)
         WHERE     EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Set1  t
                               JOIN act at2
                                   ON     t.x_id2 = at2.at_id
                                      AND t.x_id2 = ats2.ats_at
                                      AND at2.at_tp IN ('PDSP')
                               JOIN appeal ap2
                                   ON     t.x_id1 = ap2.ap_id
                                      AND ap2.ap_ap_main IS NOT NULL)
               AND ats_ss_term IS NULL;

        UPDATE At_Person Atp
           SET (Atp.Atp_Sc, Atp.History_Status) =
                   (SELECT App.App_Sc, App.History_Status
                      FROM Act JOIN Ap_Person App ON App_Ap = At_Ap
                     WHERE At_Id = Atp_At AND Atp_App = App_Id)
         WHERE EXISTS
                   (SELECT 1
                      FROM Tmp_Work_Ids
                           JOIN Act ON At_Ap = x_Id
                           JOIN Ap_Person ON App_Ap = x_Id
                     WHERE At_Id = Atp_At);

        --#APP_NUM
        INSERT INTO At_Person (Atp_Id,
                               Atp_At,
                               Atp_Sc,
                               Atp_Fn,
                               Atp_Mn,
                               Atp_Ln,
                               Atp_Birth_Dt,
                               Atp_Relation_Tp,
                               Atp_Tp,
                               Atp_App_Tp,
                               History_Status,
                               Atp_App,
                               Atp_Num)
            SELECT 0
                       AS x_Atp_Id,
                   At_Id,
                   App.App_Sc,
                   NVL (
                       Sci.Sci_Fn,
                       uss_visit.api$find.get_app_column (app.app_id,
                                                          'app_fn')),
                   NVL (
                       Sci.Sci_Mn,
                       uss_visit.api$find.get_app_column (app.app_id,
                                                          'app_mn')),
                   NVL (
                       Sci.Sci_Ln,
                       uss_visit.api$find.get_app_column (app.app_id,
                                                          'app_ln')),
                   Uss_Person.Api$sc_Tools.Get_Birthdate (App.App_Sc)
                       AS x_Birthdate,
                   ''
                       AS x_r_Tp,
                   ''
                       x_Tp,
                   App.App_Tp,
                   App.History_Status,
                   App.App_Id,
                   App.App_Num
              FROM Tmp_Work_Ids
                   JOIN Act ON At_Ap = x_Id
                   JOIN Ap_Person App ON App_Ap = x_Id
                   LEFT JOIN Uss_Person.v_Socialcard ON Sc_Id = App_Sc
                   LEFT JOIN Uss_Person.v_Sc_Change Cc ON Sc_Scc = Cc.Scc_Id
                   LEFT JOIN Uss_Person.v_Sc_Identity Sci
                       ON Sci.Sci_Id = Cc.Scc_Sci
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM At_Person
                         WHERE Atp_At = At_Id AND Atp_Sc = App_Sc);

        /*

        SELECT MAX(sc_scc) FROM uss_person.v_socialcard sc WHERE sc.sc_id = rec.app_sc;

              SELECT c.Sc_Id,
                     --Реєстраційний номер соціальної картки
                     c.Sc_Unique,
                     --Джерело
                     c.Sc_Src, s.Dic_Name AS Sc_Src_Name,
                     --Дата створення соціальної картки
                     c.Sc_Create_Dt,
                     --ПІБ
                     i.Sci_Ln AS Sc_Ln, i.Sci_Fn AS Sc_Fn, i.Sci_Mn AS Sc_Mn,
                     --Дата закриття соціальної картки
                     --todo: уточнити
                     CASE
                        WHEN c.Sc_St = '2' THEN
                         CAST(NULL AS DATE)
                      END Sc_Close_Dt,
                     --Дата народження
                     (SELECT b.Scb_Dt
                         FROM Sc_Birth b
                        WHERE b.Scb_Id = Cc.Scc_Scp) AS Sc_Birth_Dt,
                     --Ознака відмови від РНОКПП
                     (SELECT Decode(COUNT(*), 0, 'F', 'T')
                         FROM Sc_Document d
                        WHERE d.Scd_Sc = c.Sc_Id
                          AND d.Scd_Ndt = 10117
                          AND d.Scd_St = '1') AS Sc_Numident_Refuse,
                     --РНОКПП
                     (SELECT d.Scd_Number
                         FROM Sc_Document d
                        WHERE d.Scd_Sc = c.Sc_Id
                          AND d.Scd_Ndt = 5
                          AND d.Scd_St = '1') AS Sc_Numident,
                     --Тип документу, що посвідчує особу
                     (SELECT Scd_Ndt
                         FROM Pasp) AS Sc_Doc_Ndt,
                     --Серія та номер документу, що посвідчує особу
                     (SELECT Scd_Seria || Scd_Number
                         FROM Pasp) AS Sc_Doc_Num,
                     --Ким видано документ, що посвідчує особу
                     (SELECT Scd_Issued_Who
                         FROM Pasp) AS Sc_Doc_Issuer,
                     --Коли виданий, документ, що посвідчує особу
                     (SELECT Scd_Issued_Dt
                         FROM Pasp) AS Sc_Doc_Issued_Dt,
                     --Дата закінчення строку дії документу, документ, що посвідчує особу
                     (SELECT Scd_Stop_Dt
                         FROM Pasp) AS Sc_Doc_Stop_Dt,
                     --Унікальний номер запису в Єдиному державному демографічному реєстрі
                     (SELECT Uss_Doc.Api$documents.Get_Attr_Val_Str(810, Scd_Dh)
                         FROM Pasp
                        WHERE Scd_Ndt = 7) AS Sc_Doc_Eddr_Num,
                     --Стать
                     (SELECT g.Dic_Name
                         FROM Uss_Ndi.v_Ddn_Gender g
                        WHERE g.Dic_Value = i.Sci_Gender) AS Sc_Gender,
                     --Громадянство
                     (SELECT n.Dic_Name
                         FROM Uss_Ndi.v_Ddn_Nationality n
                        WHERE n.Dic_Value = i.Sci_Nationality) AS Sc_Nationality,
                     --Дата смерті
                     (SELECT Dt.Sch_Dt
                         FROM Sc_Death Dt
                        WHERE Dt.Sch_Id = Cc.Scc_Sch
                          AND Dt.Sch_Is_Dead = 'T') AS Sc_Death_Dt,
                     --Телефон мобільний
                     (SELECT Ct.Sct_Phone_Mob
                         FROM Sc_Contact Ct
                        WHERE Ct.Sct_Id = Cc.Scc_Sct) AS Sc_Phone_Mob,
                     --Телефон стаціонарний
                     (SELECT Ct.Sct_Phone_Mob
                         FROM Sc_Contact Ct
                        WHERE Ct.Sct_Id = Cc.Scc_Sct) AS Sc_Phone,
                     --email
                     (SELECT Ct.Sct_Email
                         FROM Sc_Contact Ct
                        WHERE Ct.Sct_Id = Cc.Scc_Sct) AS Sc_Email,
                     --Статус соціальної картки
                     c.Sc_St, St.Dic_Name AS Sc_St_Name
                FROM Socialcard c
                JOIN Sc_Change Cc
                  ON c.Sc_Scc = Cc.Scc_Id
                JOIN Sc_Identity i
                  ON Cc.Scc_Sci = i.Sci_Id
                JOIN Uss_Ndi.v_Ddn_Source s
                  ON c.Sc_Src = s.Dic_Value
                JOIN Uss_Ndi.v_Ddn_Sc_St St
                  ON c.Sc_St = St.Dic_Value
               WHERE c.Sc_Id = p_Sc_Id
                  OR c.Sc_Id IN (SELECT t.x_Id
                                   FROM Tmp_Work_Ids t);

        */

        MERGE INTO At_Features
             USING (SELECT 0 AS x_Atf_Id, At_Id AS x_At_Id, Nft_Id
                      FROM Uss_Ndi.v_Ndi_Pd_Feature_Type,
                           Tmp_Work_Ids
                           JOIN Act ON Act.At_Ap = x_Id
                     WHERE Nft_View = 'SS')
                ON (Atf_At = x_At_Id AND Atf_Nft = Nft_Id)
        WHEN NOT MATCHED
        THEN
            INSERT     (Atf_Id, Atf_At, Atf_Nft)
                VALUES (x_Atf_Id, x_At_Id, Nft_Id);

        --заповнюєму по заявнику
        UPDATE At_Features Atf
           SET (Atf.Atf_Val_Id, Atf.Atf_Val_String) =
                   (SELECT MAX (
                               COALESCE (
                                   Api$appeal.Get_Doc_Id (App_Id, 801, 1872),
                                   Api$appeal.Get_Doc_Id (App_Id, 802, 3689),
                                   Api$appeal.Get_Doc_Id (App_Id, 835, 3263),
                                   Api$appeal.Get_Doc_Id (App_Id, 836, 3690)))
                               AS x_Id,
                           MAX (
                               COALESCE (
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              801,
                                                              1872),
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              802,
                                                              3689),
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              835,
                                                              3263),
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              836,
                                                              3690)))
                               AS x_String
                      FROM Ap_Person  App
                           JOIN Act ON App.App_Ap = At_Ap AND At_Id = Atf_At
                     WHERE App.App_Tp = 'Z' AND App.History_Status = 'A')
         WHERE     Atf_Nft = 9
               AND Atf_At IN (SELECT At_Id
                                FROM Act JOIN Tmp_Work_Ids ON At_Ap = x_Id);

        --#106911
        --якщо заявника не було, то по іншим учасникам
        UPDATE At_Features Atf
           SET (Atf.Atf_Val_Id, Atf.Atf_Val_String) =
                   (SELECT MAX (
                               COALESCE (
                                   Api$appeal.Get_Doc_Id (App_Id, 801, 1872),
                                   Api$appeal.Get_Doc_Id (App_Id, 802, 3689),
                                   Api$appeal.Get_Doc_Id (App_Id, 835, 3263)))
                               AS x_Id,
                           MAX (
                               COALESCE (
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              801,
                                                              1872),
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              802,
                                                              3689),
                                   Api$appeal.Get_Doc_String (App_Id,
                                                              835,
                                                              3263)))
                               AS x_String
                      FROM Ap_Person  App
                           JOIN Act ON App.App_Ap = At_Ap AND At_Id = Atf_At
                     WHERE App.History_Status = 'A')
         WHERE     Atf_Nft = 9
               AND Atf.Atf_Val_Id IS NULL
               AND Atf.Atf_Val_String IS NULL
               AND Atf_At IN (SELECT At_Id
                                FROM Act JOIN Tmp_Work_Ids ON At_Ap = x_Id);

        --#110881
        --Копіюємо в акт усі документи зі звернення
        FOR vAct
            IN (SELECT apd.*,
                       at.*,
                       (SELECT MAX (atp_id)
                          FROM at_person
                         WHERE atp_at = at.At_Id AND atp_app = Apd_App)
                           atp_id,
                       (SELECT MAX (ats_id)
                          FROM at_service
                               JOIN ap_service
                                   ON aps_id = Apd_Aps AND aps_nst = ats_nst
                         WHERE ats_at = At_Id)
                           ats_id
                  FROM Tmp_Work_Ids
                       JOIN Act at
                           ON at.At_Ap = x_Id AND at.At_tp = 'RSTOPSS'
                       JOIN Appeal ap
                           ON at.At_ap = Ap_Id AND ap.ap_tp = 'R.GS'
                       JOIN Ap_Document apd
                           ON     ap.ap_id = apd.apd_ap
                              AND apd.history_status = 'A')
        LOOP
            INSERT INTO At_Document (Atd_Id,
                                     Atd_At,
                                     Atd_Atp,
                                     Atd_Ndt,
                                     Atd_Ats,
                                     Atd_Doc,
                                     Atd_Dh,
                                     History_Status)
                 VALUES (0,
                         vAct.At_Id,
                         vAct.atp_id,
                         vAct.Apd_Ndt,
                         vAct.ats_id,
                         vAct.Apd_Doc,
                         vAct.Apd_Dh,
                         'A')
              RETURNING Atd_Id
                   INTO l_New_Atd_Id;

            INSERT INTO At_Document_Attr (Atda_Id,
                                          Atda_Atd,
                                          Atda_At,
                                          Atda_Nda,
                                          Atda_Val_Int,
                                          Atda_Val_Sum,
                                          Atda_Val_Id,
                                          Atda_Val_Dt,
                                          Atda_Val_String,
                                          History_Status)
                SELECT 0,
                       l_New_Atd_Id,
                       vAct.At_Id,
                       Apda_Nda,
                       Apda_Val_Int,
                       Apda_Val_Sum,
                       Apda_Val_Id,
                       Apda_Val_Dt,
                       Apda_Val_String,
                       'A'
                  FROM Ap_Document_Attr apda
                 WHERE     apda_ap = vAct.At_Ap
                       AND apda_apd = vAct.Apd_Id
                       AND apda.history_status = 'A';
        END LOOP;



        FOR vAct
            IN (SELECT at1.at_id at_dest_id, at2.at_id at_src_id
                  FROM Tmp_Work_Ids
                       JOIN Act at1
                           ON at1.At_Ap = x_Id AND at1.At_tp = 'PDSP'
                       JOIN Appeal ap ON at1.At_ap = Ap_Id
                       JOIN Act at2 ON ap.Ap_Ap_Main = at2.at_ap
                 WHERE At2.At_Tp IN ('OKS', 'APOP', 'ANPOE'))
        LOOP
            Copy_At_Section_To_New_Act (vAct.at_src_id,
                                        vAct.At_Dest_Id,
                                        NULL,
                                        NULL);

            Copy_At_Documents_To_New_Act (vAct.at_src_id,
                                          vAct.At_Dest_Id,
                                          NULL,
                                          NULL);

            Copy_At_Signers_To_New_Act (vAct.at_src_id,
                                        vAct.At_Dest_Id,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL);

            Copy_At_Other_Spec_To_New_Act (vAct.at_src_id,
                                           vAct.At_Dest_Id,
                                           NULL,
                                           NULL);

            --Copy_At_Service_To_New_Act(vAct.at_src_id, vAct.At_Dest_Id);

            FOR vPerson
                IN (SELECT atp1.atp_id atp_dest_id, atp2.atp_id atp_src_id
                      FROM at_person atp1, at_person atp2
                     WHERE     atp1.atp_at = vAct.At_Dest_Id
                           AND atp2.atp_at = vAct.At_Src_Id
                           AND atp1.atp_num = atp2.atp_num)
            LOOP
                Copy_At_Section_To_New_Act (vAct.at_src_id,
                                            vAct.At_Dest_Id,
                                            vPerson.Atp_Src_Id,
                                            vPerson.Atp_Dest_Id);

                Copy_At_Documents_To_New_Act (vAct.at_src_id,
                                              vAct.At_Dest_Id,
                                              vPerson.Atp_Src_Id,
                                              vPerson.Atp_Dest_Id);

                Copy_At_Signers_To_New_Act (vAct.at_src_id,
                                            vAct.At_Dest_Id,
                                            NULL,
                                            NULL,
                                            vPerson.Atp_Src_Id,
                                            vPerson.Atp_Dest_Id);
            END LOOP;
        END LOOP;


        UPDATE Act
           SET At_Rnspm =
                   (SELECT Atf_Val_Id
                      FROM At_Features
                     WHERE Atf_At = At_Id AND Atf_Nft = 9)
         WHERE     EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Ids
                         WHERE At_Ap = x_Id)
               AND At_Tp NOT IN ('APOP', 'IPNP');


        UPDATE Act att
           SET At_Rnspm =
                   NVL (
                       COALESCE (
                           Api$appeal.Get_All_Ap_Doc_Id (at_ap, 801, 1872),
                           Api$appeal.Get_All_Ap_Doc_Id (at_ap, 802, 3689),
                           Api$appeal.Get_All_Ap_Doc_Id (at_ap, 835, 3263),
                           Api$appeal.Get_All_Ap_Doc_Id (at_ap, 836, 3690),
                           (SELECT CAST (MAX (x_id2) AS VARCHAR2 (50))
                              FROM tmp_work_set2
                             WHERE At_Ap = x_id1)),
                       At_Rnspm)
         WHERE     EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Ids
                         WHERE At_Ap = x_Id)
               AND At_Tp IN ('APOP',
                             'OKS',
                             'PDSP',
                             'ANPOE')
               AND At_Rnspm IS NULL;

        UPDATE Act p
           SET p.At_St = API$ACT.Get_At_St_By_Ap (p.at_tp, p.at_ap)
         WHERE     (   p.At_St IN ('W',
                                   'E',
                                   'SC',
                                   'C',
                                   'RS.C',
                                   'RS.N',
                                   'RM.N')
                    OR p.at_st IS NULL)
               AND EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Ids
                         WHERE At_Ap = x_Id);


        --Розрахунку доходу
        --Видаляємо лог попереднього розрахунку доходу
        DELETE FROM At_Income_Log
              WHERE Ail_Aid IN
                        (SELECT Aid_Id
                           FROM At_Income_Detail,
                                At_Income_Calc,
                                Tmp_Work_set1
                          WHERE Aid_Aic = Aic_Id AND Aic_At = x_Id2);

        --Видаляємо детальний розрахунок доходу
        DELETE FROM At_Income_Detail
              WHERE Aid_Aic IN (SELECT Aic_Id
                                  FROM At_Income_Calc, Tmp_Work_set1
                                 WHERE Aic_At = x_Id2);

        --Видаляємо розрахунок доходу
        DELETE FROM At_Income_Calc
              WHERE Aic_At IN (SELECT x_id2 FROM Tmp_Work_set1);

        --Видаляємо перевірку права
        DELETE FROM At_Right_Log arl
              WHERE arl.arl_at IN (SELECT x_id2 FROM Tmp_Work_set1);

        IF SQL%ROWCOUNT > 0
        THEN
            Tools.Add_Message (
                g_Messages,
                'W',
                'Повернуто на розрахунок ' || SQL%ROWCOUNT || ' актів!');
        END IF;

        --  RETURN;

        --Проставляємо номери рішень для актів де створена особова справа
        FOR Rec
            IN (  SELECT At_Id,
                         Pc_Id,
                         Pc_Num,
                         Ap_Tp,
                         At_Tp,
                         At_St,
                         (SELECT LISTAGG (Ats.Ats_Nst,
                                          ', '
                                          ON OVERFLOW TRUNCATE '...')
                                 WITHIN GROUP (ORDER BY Ats_Id)
                            FROM At_Service Ats
                                 JOIN Uss_Ndi.v_Ndi_Service_Type
                                     ON Ats_Nst = Nst_Id
                           WHERE Ats_At = At_Id)      AS Nst_Name,
                         Ap_Id,
                         Ap_Src,
                            rnsp.RNSPS_LAST_NAME
                         || ' '
                         || RNSPS_FIRST_NAME
                         || ' '
                         || rnsp.RNSPS_MIDDLE_NAME    RNSPS_NAME
                    FROM Tmp_Work_Ids
                         JOIN Appeal ON Ap_Id = x_Id
                         JOIN Personalcase ON Pc_Id = Ap_Pc
                         JOIN Act at ON At_Pc = Pc_Id
                         LEFT JOIN USS_RNSP.V_RNSP rnsp
                             ON at.at_rnspm = rnsp.RNSPM_ID
                   WHERE At_Num IS NULL
                ORDER BY LPAD (Pc_Num, 10, '0') ASC, Ap_Id ASC)
        LOOP
            --Вішаємо lock на генерацію номера для ЕОС
            l_Lock :=
                Tools.Request_Lock (
                    p_Descr   => 'CALC_ACT_NUMS_PC_' || Rec.Pc_Id,
                    p_Error_Msg   =>
                           'В даний момент вже виконується генерація номерів для актів ЕОС №'
                        || Rec.Pc_Num
                        || '!');

            IF Rec.At_Tp IN ('APOP',
                             'OKS',
                             'ANPOE',
                             'RSTOPSS')
            THEN
                l_Num := Rec.At_Id;
            ELSE
                l_Num := Gen_At_Num (Rec.Pc_Id);
            END IF;

            API$PERSONALCASE.Get_sc_scc_by_appeal (Rec.Ap_Id,
                                                   Rec.Ap_Tp,
                                                   Rec.Ap_Src,
                                                   l_app_sc,
                                                   l_app_scc);
            l_app_pc := API$PERSONALCASE.Get_pc_by_sc (l_app_sc);

            UPDATE Act at
               SET At_Num = l_Num, at.at_pc = l_app_pc, at.at_sc = l_app_sc
             WHERE At_Id = Rec.At_Id;

            Tools.Release_Lock (l_Lock);

            IF Rec.Ap_Tp IN ('R.OS', 'R.GS') AND rec.at_tp IN ('RSTOPSS')
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Створено акт № '
                    || l_Num
                    || ' для ЕОС № '
                    || Rec.Pc_Num
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'C',
                    CHR (38) || '201#' || l_Num || '#' || Rec.Pc_Num,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                    CHR (38) || '201#' || l_Num || '#' || Rec.Pc_Num,
                    NULL);
                Init_Rstopss (Rec.At_Id, Rec.Ap_Id);
            ELSIF Rec.At_Tp = 'APOP'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту первинної оцінки створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            ELSIF Rec.At_Tp = 'OKS'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту оцінки кризової ситуації створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            ELSIF Rec.At_Tp = 'ANPOE'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту про надання повнолітній особі соціальних послуг екстрено (кризово) створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            ELSE
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Створено проект рішення № '
                    || l_Num
                    || ' для ЕОС № '
                    || Rec.Pc_Num
                    || ' по послугам: '
                    || Rec.Nst_Name
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.Pc_Num
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            END IF;
        END LOOP;

        --Проставляємо номери рішень для актів де НЕ створена особова справа
        FOR Rec
            IN (  SELECT At_Id,
                         Ap_Tp,
                         At_Tp,
                         (SELECT LISTAGG (Ats.Ats_Nst,
                                          ', '
                                          ON OVERFLOW TRUNCATE '...')
                                 WITHIN GROUP (ORDER BY Ats_Id)
                            FROM At_Service Ats
                                 JOIN Uss_Ndi.v_Ndi_Service_Type
                                     ON Ats_Nst = Nst_Id
                           WHERE Ats_At = At_Id)      AS Nst_Name,
                         Ap_Id,
                         Ap_Src,
                            rnsp.RNSPS_LAST_NAME
                         || ' '
                         || RNSPS_FIRST_NAME
                         || ' '
                         || rnsp.RNSPS_MIDDLE_NAME    RNSPS_NAME
                    FROM Tmp_Work_Ids
                         JOIN Appeal ON Ap_Id = x_Id
                         JOIN Act at ON At_ap = Ap_id
                         LEFT JOIN USS_RNSP.V_RNSP rnsp
                             ON at.at_rnspm = rnsp.RNSPM_ID
                   WHERE     At_Num IS NULL
                         AND At.At_Pc IS NULL
                         AND At_Tp IN ('APOP',
                                       'OKS',
                                       'ANPOE',
                                       'RSTOPSS')
                ORDER BY Ap_Id ASC)
        LOOP
            --Вішаємо lock на генерацію номера для ЕОС
            l_Lock :=
                Tools.Request_Lock (
                    p_Descr   => 'CALC_ACT_NUMS_PC_' || Rec.At_Id,
                    p_Error_Msg   =>
                           'В даний момент вже виконується генерація номерів для актів ЕОС №'
                        || Rec.At_Id
                        || '!');

            l_Num := Rec.At_Id;

            UPDATE Act at
               SET At_Num = l_Num
             WHERE At_Id = Rec.At_Id;

            Tools.Release_Lock (l_Lock);

            IF Rec.At_Tp = 'APOP'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту первинної оцінки створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            ELSIF Rec.At_Tp = 'OKS'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту оцінки кризової ситуації створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            ELSIF Rec.At_Tp = 'ANPOE'
            THEN
                Tools.Add_Message (
                    g_Messages,
                    'I',
                       'Проєкт акту про надання повнолітній особі соціальних послуг екстрено (кризово) створено та передано на опрацювання до '
                    || Rec.RNSPS_NAME
                    || '.');
                Write_At_Log (
                    Rec.At_Id,
                    l_Hs,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
                --#73634 2021.12.02
                Api$esr_Action.Preparewrite_Visit_At_Log (
                    Rec.At_Id,
                       CHR (38)
                    || '11#'
                    || l_Num
                    || '#'
                    || Rec.At_Id
                    || '#'
                    || Rec.Nst_Name,
                    NULL);
            END IF;
        END LOOP;

        --Створюємо копії попередніх актів
        FOR Rec
            IN (SELECT Ap_Ap_Main,
                       Ap.Ap_Id,
                       At_Tp,
                       API$Appeal.Is_Aps_Exists (Ap_Id, 420)
                           Is_420_Exists,
                       At.At_Id,
                       At.At_Rnspm,
                       At.At_Cu,
                       At.At_Sc,
                       (SELECT MAX (At_id)
                          FROM Act a
                         WHERE a.at_ap = Ap_Ap_Main AND a.AT_TP IN ('OKS'))
                           Ap_Ap_Main_oks_id,
                       (SELECT MAX (At_id)
                          FROM Act a
                         WHERE a.at_ap = Ap_Ap_Main AND a.AT_TP IN ('APOP'))
                           Ap_Ap_Main_apop_id,
                       (SELECT MAX (At_id)
                          FROM Act a
                         WHERE a.at_ap = Ap_Ap_Main AND a.AT_TP IN ('ANPOE'))
                           Ap_Ap_Main_anpoe_id
                  FROM Tmp_Work_Ids
                       JOIN Appeal Ap ON Ap_Id = x_Id
                       JOIN Act At ON Ap.Ap_Id = At.At_Ap
                 WHERE     Ap_Ap_Main IS NOT NULL
                       AND At.At_Tp = 'PDSP'
                       AND Ap.Ap_tp = 'SS'
                       AND EXISTS
                               (SELECT 1
                                  FROM Act prv
                                 WHERE     prv.AT_AP = Ap_Ap_Main
                                       AND prv.AT_TP IN
                                               ('OKS', 'APOP', 'ANPOE')))
        LOOP
            l_At_Tp := NULL;
            --#115496
            l_At_St := NULL;

            IF Rec.Ap_Ap_Main_anpoe_id IS NOT NULL
            THEN
                l_At_Tp := 'ANPOE';

                SELECT *
                  INTO l_At_Data
                  FROM Act
                 WHERE at_id = Rec.Ap_Ap_Main_anpoe_id;

                --#115496
                l_At_St := 'XP';
            ELSIF Rec.Is_420_Exists > 0 AND Rec.Ap_Ap_Main_Oks_Id IS NOT NULL
            THEN
                l_At_Tp := 'OKS';

                SELECT *
                  INTO l_At_Data
                  FROM Act
                 WHERE at_id = Rec.Ap_Ap_Main_Oks_Id;

                --#115496
                l_At_St := 'TP';
            ELSIF Rec.Ap_Ap_Main_Apop_Id IS NOT NULL
            THEN
                l_At_Tp := 'APOP';

                SELECT *
                  INTO l_At_Data
                  FROM Act
                 WHERE at_id = Rec.Ap_Ap_Main_Apop_Id;

                --#115496
                l_At_St := 'AS';
            END IF;

            IF l_At_Tp IS NOT NULL
            THEN
                Copy_At_To_New (p_At_id       => l_At_Data.At_Id,
                                p_New_At_Tp   => l_At_Tp,
                                p_New_At_Id   => l_New_At_Id,
                                p_With_Logs   => 1);

                --#106661
                --Оновлення даних учасників нової копії акту з даних PDSP
                FOR Atp_PDSP IN (SELECT *
                                   FROM at_person
                                  WHERE atp_at = Rec.At_Id)
                LOOP
                    UPDATE at_person atp
                       SET atp.atp_sc = Atp_pdsp.Atp_Sc,             --#112615
                           atp.atp_app_tp = Atp_pdsp.Atp_App_Tp,
                           atp.atp_app = Atp_pdsp.atp_app
                     WHERE     atp.atp_at = l_New_At_Id
                           AND atp.atp_num = Atp_pdsp.Atp_Num;
                END LOOP;

                UPDATE Act at
                   SET At_Num = l_New_At_Id,
                       At.At_Main_Link = Rec.At_Id,
                       At.At_Main_Link_Tp = 'DECISION',
                       At.At_Sc = Rec.At_Sc,
                       At.At_St = NVL (l_At_St, At.At_St),
                       At.At_Ap = Rec.Ap_Id,
                       At.At_Rnspm = Rec.At_Rnspm,
                       At.At_Cu = Rec.At_Cu
                 WHERE At_Id = l_New_At_Id;

                DELETE FROM At_Links
                      WHERE Atk_At = l_New_At_Id;

                INSERT INTO At_Links (Atk_At, Atk_Link_At, Atk_Tp)
                     VALUES (Rec.At_Id, l_New_At_Id, l_At_Tp);
            END IF;
        END LOOP;

        DELETE FROM At_Income_Src
              WHERE     Ais_Src <> 'HND'
                    AND EXISTS
                            (SELECT 1
                               FROM Tmp_Work_Ids, Act
                              WHERE At_Ap = x_Id AND Ais_At = At_Id);

        --Вставляємо дані по декларації - для Допомог
        INSERT INTO At_Income_Src (Ais_Id,
                                   Ais_Src,
                                   Ais_Tp,
                                   Ais_Edrpou,
                                   Ais_Fact_Sum,
                                   Ais_Final_Sum,
                                   Ais_Sc,
                                   Ais_Esv_Paid,
                                   Ais_Esv_Min,
                                   Ais_Start_Dt,
                                   Ais_Stop_Dt,
                                   Ais_At,
                                   Ais_App,
                                   Ais_Is_Use,
                                   Ais_Exch_Tp)
            SELECT 0,
                   'APR',
                   Apri_Tp,
                   '0',
                   Apri_Sum,
                   Apri_Sum,
                   App_Sc,
                   'F',
                   'F',
                   Apri_Start_Dt,
                   Apri_Stop_Dt,
                   At_Id,
                   App_Id,
                   'T',
                   NULL
              FROM Tmp_Work_Ids,
                   Act,
                   Ap_Declaration,
                   Apr_Person,
                   Apr_Income,
                   Ap_Person,
                   Appeal
             WHERE     x_Id = At_Ap
                   AND Apr_Ap = x_Id
                   AND Apri_Apr = Apr_Id
                   AND Apri_Aprp = Aprp_Id
                   AND Aprp_App = App_Id
                   AND App_Ap = x_Id
                   AND App_Ap = At_Ap
                   AND Apr_Person.History_Status = 'A'
                   AND Apr_Income.History_Status = 'A'
                   AND Ap_Person.History_Status = 'A'
                   AND Ap_Id = x_Id
                   AND Ap_Tp IN ('SS')
            UNION ALL
            SELECT 0,
                   Api_Src,
                   Api_Tp,
                   Api_Edrpou,
                   Api_Sum,
                   Api_Sum,
                   App_Sc,
                   DECODE (Api_Esv_Paid,  '0', 'F',  '1', 'T',  'F'),
                   DECODE (Api_Esv_Min,  '0', 'F',  '1', 'T',  'F'),
                   NVL (Api_Start_Dt, Api_Month),
                   NVL (Api_Stop_Dt, LAST_DAY (Api_Month)),
                   At_Id,
                   App_Id,
                   'F',
                   Api_Exch_Tp
              FROM Tmp_Work_Ids,
                   Act,
                   Ap_Person,
                   Ap_Income,
                   Appeal
             WHERE     x_Id = At_Ap
                   AND App_Ap = At_Ap
                   AND Api_App = App_Id
                   AND Ap_Person.History_Status = 'A'
                   AND Ap_Id = x_Id
                   AND Ap_Tp IN ('SS');

        --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
        Api$appeal.Mark_Appeal_Working (2,
                                        6,
                                        NULL,
                                        l_Cnt);

        IF l_Cnt = 0
        THEN
            Tools.Add_Message (
                g_Messages,
                'W',
                'Проектів рішень за зверненням не знайдено, стан звернення не змінено!');
        END IF;

        Tools.Release_Lock (l_Lock_Init);

        --#109549
        IF p_Mode <> 5
        THEN
            OPEN p_Messages FOR SELECT * FROM TABLE (g_Messages);
        END IF;
    END;

    --====================================================--
    -- #: Перевірка умов для наступного статуса
    --====================================================--
    PROCEDURE Proces_Act_By_Appeals
    IS
        p_Messages   SYS_REFCURSOR;
        l_Cnt        NUMBER;
    BEGIN
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT Ap_Id
              FROM Appeal
                   JOIN Ap_Person p
                       ON     p.App_Ap = Ap_Id
                          AND p.History_Status = 'A'
                          AND p.App_Tp = 'Z'
                   JOIN Ap_Document d
                       ON d.Apd_App = p.App_Id AND d.History_Status = 'A'
                   JOIN Ap_Document_Attr a
                       ON a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A'
             WHERE     Ap_St IN ('O')
                   AND Ap_Tp IN ('SS')
                   AND (   (    d.Apd_Ndt = 801
                            AND a.Apda_Nda = 3688
                            AND NVL (a.Apda_Val_String, '-') = 'G')
                        OR (    d.Apd_Ndt = 802
                            AND a.Apda_Nda = 3687
                            AND NVL (a.Apda_Val_String, '-') = 'G')
                        OR (    d.Apd_Ndt = 835
                            AND a.Apda_Nda = 3261
                            AND NVL (a.Apda_Val_String, '-') = 'G')
                        OR (    d.Apd_Ndt = 836
                            AND a.Apda_Nda = 3686
                            AND NVL (a.Apda_Val_String, '-') = 'G'));

        l_Cnt := SQL%ROWCOUNT;

        IF l_Cnt > 0
        THEN
            Init_Act_By_Appeals (4, NULL, p_Messages);
        END IF;
    END;

    --====================================================--
    -- #: Перевірка умов для наступного статуса
    --====================================================--
    FUNCTION Check_St_Config (Sqlstr VARCHAR2)
        RETURN NUMBER
    IS
        Ret   NUMBER;
    BEGIN
        IF Sqlstr IS NULL
        THEN
            RETURN 1;
        END IF;

        EXECUTE IMMEDIATE Sqlstr
            USING OUT Ret;

        RETURN CASE Ret WHEN 0 THEN 0 WHEN -1 THEN -1 ELSE 1 END;
    END;

    --====================================================--
    -- #: Видалення документів, що було підписано, при поверненні на доопрацювання
    --====================================================--
    PROCEDURE Delete_At_Document_All (p_At_Id IN NUMBER)
    IS
    BEGIN
        UPDATE At_Signers t
           SET t.History_Status = 'H'
         WHERE     t.ati_at = p_At_Id
               AND t.ati_atd IN (SELECT z.atd_id
                                   FROM at_document z
                                  WHERE     z.atd_at = p_At_Id
                                        AND z.atd_ndt IN (850,
                                                          851,
                                                          852,
                                                          853,
                                                          854,
                                                          842,
                                                          843))
               AND t.History_Status = 'A';

        UPDATE At_Document t
           SET t.History_Status = 'H'
         WHERE     t.Atd_At = p_At_Id
               AND t.Atd_Ndt IN (850,
                                 851,
                                 852,
                                 853,
                                 854,
                                 842,
                                 843)
               AND t.History_Status = 'A';

        UPDATE At_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.Atda_Atd IN (SELECT Atd_Id
                                FROM At_Document t
                               WHERE     t.Atd_At = p_At_Id
                                     AND t.Atd_Ndt IN (850,
                                                       851,
                                                       852,
                                                       853,
                                                       854,
                                                       842,
                                                       843)
                                     AND t.History_Status = 'H');
    END;

    PROCEDURE Delete_At_Document (p_At_Id IN NUMBER, p_ndt_id IN NUMBER)
    IS
    BEGIN
        UPDATE At_Signers t
           SET t.History_Status = 'H'
         WHERE     t.ati_at = p_At_Id
               AND t.ati_atd IN
                       (SELECT z.atd_id
                          FROM at_document z
                         WHERE z.atd_at = p_At_Id AND z.atd_ndt IN (p_ndt_id))
               AND t.History_Status = 'A';

        UPDATE At_Document t
           SET t.History_Status = 'H'
         WHERE     t.Atd_At = p_At_Id
               AND t.Atd_Ndt IN (p_ndt_id)
               AND t.History_Status = 'A';

        UPDATE At_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.Atda_Atd IN
                   (SELECT Atd_Id
                      FROM At_Document t
                     WHERE     t.Atd_At = p_At_Id
                           AND t.Atd_Ndt IN (p_ndt_id)
                           AND t.History_Status = 'H');
    END;

    --====================================================--
    -- #: Видалення перевірки прав на соц послуги
    --====================================================--
    PROCEDURE Delete_At_Right_Log (p_At_Id IN NUMBER)
    IS
    BEGIN
        DELETE FROM At_Right_Log
              WHERE Arl_At = p_At_Id;
    END;

    --====================================================--
    -- #: Видалення параметрів відмови по акту на соц послуги
    --====================================================--
    PROCEDURE Delete_At_Reject_Info (p_At_Id IN NUMBER)
    IS
    BEGIN
        DELETE FROM At_Reject_Info t
              WHERE t.ari_at = p_At_Id;
    END;

    --====================================================--
    --  Set global for act
    --====================================================--
    PROCEDURE Set_g_Ap_and_g_AT (P_at_id NUMBER)
    IS
    BEGIN
        g_At_Id := p_At_Id;

        SELECT at_ap, at_num, at_sc
          INTO g_Ap_Id, g_At_num, g_At_sc
          FROM act
         WHERE at_id = p_At_Id;
    END;

    --====================================================--
    -- #: фнкція перевіряє чи є наступний шаг по бізнес прцесу
    --====================================================--
    FUNCTION Can_Do_Act_Process_Step (p_At_Id     IN NUMBER,
                                      p_Npsc_Tp   IN VARCHAR2 DEFAULT 'UP')
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Res
          FROM Act  t
               JOIN Appeal ON t.At_Ap = Ap_Id
               JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                   ON     (Npsc.Npsc_Ap_Tp = Ap_Tp OR Npsc.Npsc_At_Tp = At_Tp)
                      AND Npsc.Npsc_Tp = p_Npsc_Tp
                      AND Npsc.Npsc_From_St = t.At_St
                      AND Npsc.History_Status = 'A'
         WHERE t.At_Id = p_At_Id;

        RETURN l_Res;
    END;

    --====================================================--
    -- #: процедура перевіряє чи є наступний шаг по бізнес прцесу і повертає помилку, якщо немає
    --====================================================--
    PROCEDURE Check_Do_Act_Process_Step (
        p_At_Id     IN NUMBER,
        p_Npsc_Tp   IN VARCHAR2 DEFAULT 'UP')
    IS
    BEGIN
        IF Can_Do_Act_Process_Step (p_At_Id) = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Бізнес процесс обробки документів не передбачає перехід до наступого статусу');
        END IF;
    END;

    --====================================================--
    -- #: затвердити act
    --====================================================--
    PROCEDURE Approve_Act (p_At_Id       IN NUMBER,
                           p_At_Src_Id   IN NUMBER DEFAULT NULL)
    IS
        l_Hs           NUMBER := Tools.Gethistsession;
        l_St           VARCHAR2 (10);
        l_St_New       VARCHAR2 (10);
        l_Ap_Id        Appeal.Ap_Id%TYPE;
        l_Ap_Tp        Appeal.Ap_Tp%TYPE;
        l_Action_Sql   Uss_Ndi.v_Ndi_Pd_St_Config.Npsc_Check_Sql%TYPE;
        l_Check_St     NUMBER;

        -------------------------------
        CURSOR St_Config IS
            SELECT Ap_Id,
                   Ap_Tp,
                   t.At_St,
                   Npsc.Npsc_To_St,
                   Npsc.Npsc_Action_Sql,
                   Npsc.Npsc_Check_Sql
              FROM Act  t
                   JOIN Appeal ON t.At_Ap = Ap_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                       ON     (   Npsc.Npsc_Ap_Tp = Ap_Tp
                               OR Npsc.Npsc_At_Tp = At_Tp)
                          AND Npsc.Npsc_Tp = 'UP'
                          AND Npsc.Npsc_From_St = t.At_St
                          AND Npsc.History_Status = 'A'
             WHERE t.At_Id = p_At_Id;
    -------------------------------
    BEGIN
        Set_g_Ap_and_g_AT (p_At_Id);

        FOR rec IN St_Config
        LOOP
            DBMS_OUTPUT.put_line (rec.npsc_to_st);
            l_Check_St := Api$act.Check_St_Config (rec.Npsc_Check_Sql);
            DBMS_OUTPUT.put_line (rec.npsc_to_st);

            IF l_Check_St                                             /*!= 0*/
                          > 0
            THEN
                l_Ap_Id := rec.Ap_Id;
                l_Ap_Tp := rec.Ap_Tp;
                l_St := rec.At_St;
                l_St_New := rec.Npsc_To_St;
                l_Action_Sql := rec.Npsc_Action_Sql;
                EXIT;
            END IF;
        END LOOP;

        /*

        BEGIN
          SELECT Ap_Id, Ap_Tp, At_St, Npsc_To_St, Npsc_Action_Sql, x_Check_St
            INTO l_Ap_Id, l_Ap_Tp, l_St, l_St_New, l_Action_Sql, l_Check_St
            FROM (SELECT Ap_Id, Ap_Tp, t.At_St, Npsc.Npsc_To_St, Npsc.Npsc_Action_Sql,
                          Api$act.Check_St_Config(Npsc.Npsc_Check_Sql) AS x_Check_St
                     FROM Act t
                     JOIN Appeal
                       ON t.At_Ap = Ap_Id
                     LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                       ON (Npsc.Npsc_Ap_Tp = Ap_Tp OR Npsc.Npsc_At_Tp = At_Tp)
                      AND Npsc.Npsc_Tp = 'UP'
                      AND Npsc.Npsc_From_St = t.At_St
                      AND Npsc.History_Status = 'A'
                    WHERE t.At_Id = p_At_Id)
           WHERE x_Check_St != 0;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      */
        IF l_St_New IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'Акт неможливо підтвердити. Статус рішення не задовільняє умовам!');
        END IF;

        -- Взагалі, Api$act.Check_St_Config може повернути три значення 0, 1, -1
        --   0 - перевірка не пройдена взагалі, по факту, це потрібно для вибору одного варіанта переходу з декількох.
        --       тому це відсікаємо на запиті "WHERE x_Check_st != 0;"
        --   1 - все гаразд, всі умови виконано. Дозволяємо перехід.
        --  -1 - обрано потрібну гілку переходу, але на всі умови для зміни статусу виконано, наприклад - не всі акти вторинної оцінки підписано.
        IF l_Check_St = -1
        THEN
            RETURN;
        END IF;

        g_Ap_Id := l_Ap_Id;
        g_At_Id := p_At_Id;
        g_At_Src_Id := p_At_Src_Id;
        g_At_St_Old := l_St;
        g_At_St := l_St_New;
        g_Hs := l_Hs;

        UPDATE Act t
           SET t.At_St = l_St_New
         WHERE t.At_Id = p_At_Id;

        Write_At_Log (p_At_Id,
                      l_Hs,
                      l_St_New,
                      CHR (38) || '17',
                      l_St);

        IF l_Action_Sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_Action_Sql;
        END IF;
    END;

    --====================================================--
    -- # Поверенення акту на доопрацювання
    --====================================================--
    PROCEDURE Return_Act (p_At_Id NUMBER, p_Reason VARCHAR2)
    IS
        l_Hs             NUMBER := Tools.Gethistsession;
        l_St             VARCHAR2 (10);
        l_St_New         VARCHAR2 (10);
        l_St_Name        VARCHAR2 (250);
        l_Ap             Appeal.Ap_Id%TYPE;
        l_Ap_Tp          Appeal.Ap_Tp%TYPE;
        l_Action_Sql     Uss_Ndi.v_Ndi_Pd_St_Config.Npsc_Action_Sql%TYPE;
        l_Check_Ap_sql   Uss_Ndi.v_Ndi_Pd_St_Config.Npsc_Check_Ap_Sql%TYPE;
        l_Check_ap_St    NUMBER;
    BEGIN
        Set_g_Ap_and_g_AT (p_At_Id);

        BEGIN
            SELECT Ap_Id,
                   Ap_Tp,
                   t.At_St,
                   Dic_Name,
                   Npsc.Npsc_To_St,
                   Npsc.Npsc_Action_Sql,
                   Npsc.npsc_check_ap_sql
              INTO l_Ap,
                   l_Ap_Tp,
                   l_St,
                   l_St_Name,
                   l_St_New,
                   l_Action_Sql,
                   l_Check_ap_sql
              FROM Act  t
                   JOIN Appeal ON At_Ap = Ap_Id
                   -- поки іншого не придумав
                   JOIN (SELECT * FROM Uss_Ndi.v_Ddn_At_Pdsp_St
                         UNION
                         SELECT * FROM Uss_Ndi.v_Ddn_At_rstopss_St)
                       ON At_St = Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                       ON     (   Npsc.Npsc_Ap_Tp = Ap_Tp
                               OR Npsc.Npsc_At_Tp = At_Tp)
                          AND Npsc.Npsc_Tp = 'DOWN'
                          AND Npsc.Npsc_From_St = t.At_St
                          AND Npsc.History_Status = 'A'
                          AND Api$act.Check_St_Config (Npsc.Npsc_Check_Sql) =
                              1
             WHERE t.At_Id = p_At_Id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        IF l_St_New IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Акт не можливо повернути на доопрацювання з статусу '
                || l_St_Name
                || '!');
        END IF;

        g_At_Id := p_At_Id;
        g_At_St_Old := l_St;
        g_At_St := l_St_New;
        g_Hs := l_Hs;

        UPDATE Act t
           SET t.At_St = l_St_New
         WHERE t.At_Id = p_At_Id;

        Write_At_Log (p_At_Id,
                      l_Hs,
                      l_St_New,
                      CHR (38) || '17',
                      l_St,
                      'SYS');

        IF p_Reason IS NOT NULL
        THEN
            Write_At_Log (p_At_Id,
                          l_Hs,
                          l_St_New,
                          p_Reason,
                          l_St,
                          'USR');
        END IF;

        --#107531 Не для всіх статусів треба повертати статуси звернень
        l_Check_ap_St := Api$act.Check_St_Config (l_Check_ap_sql);

        IF l_Check_ap_St > 0
        THEN
            Api$appeal.Return_Appeal_To_Editing (l_Ap, p_Reason);
        END IF;

        IF l_Action_Sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_Action_Sql;
        END IF;
    END;

    PROCEDURE Rejects_Act (p_At_Id IN NUMBER)
    IS
        l_st        VARCHAR2 (10);
        l_st_name   VARCHAR2 (500);
    BEGIN
        Rejects_Act (p_At_Id, l_st, l_st_name);
    END;

    --====================================================--
    -- # збереження форми "Рішення про відмову"
    --====================================================--
    PROCEDURE Rejects_Act (p_At_Id     IN     NUMBER,
                           --p_Clob    IN CLOB,
                           p_St           OUT VARCHAR2,
                           p_St_Name      OUT VARCHAR2)
    IS
        --l_Arr        t_At_Reject_Info;
        l_Hs           NUMBER := Tools.Gethistsession;
        l_St           VARCHAR2 (10);
        l_Action_Sql   Uss_Ndi.v_Ndi_Pd_St_Config.Npsc_Check_Sql%TYPE;
        l_Check_St     NUMBER;

        -------------------------------
        CURSOR St_Config IS
            SELECT Ap_Id,
                   Ap_Tp,
                   t.At_St,
                   Npsc.Npsc_To_St,
                   Npsc.Npsc_Action_Sql,
                   Npsc.Npsc_Check_Sql,
                   (SELECT Dic_Name
                      FROM Uss_Ndi.V_DDN_AT_PDSP_ST
                     WHERE At_St = Dic_Value)    AS Dic_Name
              FROM Act  t
                   JOIN Appeal ON t.At_Ap = Ap_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                       ON     (   Npsc.Npsc_Ap_Tp = Ap_Tp
                               OR Npsc.Npsc_At_Tp = At_Tp)
                          AND Npsc.Npsc_Tp = 'UP_REJECT'
                          AND Npsc.Npsc_From_St = t.At_St
                          AND Npsc.History_Status = 'A'
             WHERE t.At_Id = p_At_Id;
    -------------------------------
    BEGIN
        Set_g_Ap_and_g_AT (p_At_Id);

        /*
          EXECUTE IMMEDIATE Type2xmltable(Pkg, 't_at_reject_info', TRUE, TRUE) BULK COLLECT
            INTO l_Arr
            USING p_Clob;

          IF (l_Arr.Count = 0) THEN
            Raise_Application_Error(-20000, 'Не можна відхиляти без причин!');
          END IF;

          FORALL i IN INDICES OF l_Arr
            UPDATE At_Reject_Info t
               SET t.Ari_Nrr = l_Arr(i).Ari_Nrr,
                   t.Ari_Njr = l_Arr(i).Ari_Njr
             WHERE t.Ari_Id = l_Arr(i).Ari_Id;

          FOR Xx IN (SELECT t.Ari_Id, Tt.Ari_Id AS x_Ari_Id
                       FROM At_Reject_Info t
                       LEFT JOIN TABLE(l_Arr) Tt
                         ON Tt.Ari_Id = t.Ari_Id
                      WHERE t.Ari_At = p_At_Id
                        AND Tt.Ari_Id IS NULL)
          LOOP
            DELETE FROM At_Reject_Info t
             WHERE t.Ari_Id = Xx.Ari_Id;

          END LOOP;

          FOR Xx IN (SELECT *
                       FROM TABLE(l_Arr)
                      WHERE Ari_Id IS NULL)
          LOOP
            INSERT INTO At_Reject_Info t
              (Ari_Nrr, Ari_Njr, Ari_At)
            VALUES
              (Xx.Ari_Nrr, Xx.Ari_Njr, p_At_Id);

          END LOOP;
        */
        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Ids (x_Id)
             VALUES (p_At_Id);

        FOR rec IN St_Config
        LOOP
            l_Check_St := Api$act.Check_St_Config (rec.Npsc_Check_Sql);

            IF l_Check_St > 0
            THEN
                --l_Ap_Id     := rec.Ap_Id;
                --l_Ap_Tp     := rec.Ap_Tp;
                l_St := rec.At_St;
                p_St := rec.Npsc_To_St;
                p_St_Name := rec.dic_name;
                l_Action_Sql := rec.Npsc_Action_Sql;
                EXIT;
            END IF;
        END LOOP;

        /* BEGIN
           SELECT t.At_St, Npsc.Npsc_To_St,
                  (SELECT Dic_Name FROM Uss_Ndi.V_DDN_AT_PDSP_ST WHERE At_St = Dic_Value ) AS Dic_Name,
                  Npsc.Npsc_Action_Sql
             INTO l_St, p_St, p_St_Name, l_Action_Sql
             FROM Act t
             JOIN Appeal
               ON At_Ap = Ap_Id
             LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
               ON (Npsc.Npsc_Ap_Tp = Ap_Tp OR Npsc.Npsc_At_Tp = At_Tp)
              AND Npsc.Npsc_Tp = 'UP_REJECT'
              AND Npsc.Npsc_From_St = t.At_St
              AND Npsc.History_Status = 'A'
              AND Api$act.Check_St_Config(Npsc.Npsc_Check_Sql) = 1
            WHERE t.At_Id = p_At_Id;
         EXCEPTION
           WHEN OTHERS THEN
             raise_application_error(-20000, SQLERRM);
         END;*/

        IF (p_St IS NULL)
        THEN
            Raise_Application_Error (
                -20000,
                'Відхилення при поточному статусі неможливе!');
        END IF;

        UPDATE Act t
           SET t.At_St = p_St, t.At_Wu = COALESCE (t.At_Wu, Tools.Getcurrwu)
         WHERE t.At_Id = p_At_Id;

        g_At_Id := p_At_Id;

        IF g_Message IS NULL
        THEN
            Api$act.Write_At_Log (p_At_Id,
                                  l_Hs,
                                  p_St,
                                  CHR (38) || '16',
                                  l_St);
        ELSE
            Api$act.Write_At_Log (p_At_Id,
                                  l_Hs,
                                  p_St,
                                  CHR (38) || '166#' || g_Message,
                                  l_St);
        END IF;

        IF l_Action_Sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_Action_Sql;
        END IF;
    END;

    --====================================================--
    -- # Поверенення акту на доопрацювання
    --====================================================--
    PROCEDURE Reject_Act_Reject (p_At_Id     IN     NUMBER,
                                 p_St           OUT VARCHAR2,
                                 p_St_Name      OUT VARCHAR2)
    IS
        l_Hs           NUMBER := Tools.Gethistsession;
        l_St           VARCHAR2 (10);
        --l_st_new VARCHAR2(10);
        l_Action_Sql   Uss_Ndi.v_Ndi_Pd_St_Config.Npsc_Check_Sql%TYPE;
    BEGIN
        Set_g_Ap_and_g_AT (p_At_Id);

        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Ids (x_Id)
             VALUES (p_At_Id);

        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        Api$account.Init_Tmp_For_Pd;

        BEGIN
            SELECT t.At_St,
                   Npsc.Npsc_To_St,
                   Dic_Name,
                   Npsc.Npsc_Action_Sql
              INTO l_St,
                   p_St,
                   p_St_Name,
                   l_Action_Sql
              FROM Act  t
                   JOIN Appeal ON At_Ap = Ap_Id
                   JOIN Uss_Ndi.v_Ddn_at_Pdsp_St ON At_St = Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Pd_St_Config Npsc
                       ON     (   Npsc.Npsc_Ap_Tp = Ap_Tp
                               OR Npsc.Npsc_At_Tp = At_Tp)
                          AND Npsc.Npsc_Tp = 'DOWN'
                          AND Npsc.Npsc_From_St = t.At_St
                          AND Npsc.History_Status = 'A'
                          AND Api$act.Check_St_Config (Npsc.Npsc_Check_Sql) =
                              1
             WHERE t.At_Id = p_At_Id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        IF (p_St IS NULL)
        THEN
            Raise_Application_Error (
                -20000,
                'Повернення при поточному статусі неможливе!');
        END IF;

        UPDATE Act t
           SET t.At_St = p_St, t.At_Wu = COALESCE (t.At_Wu, Tools.Getcurrwu)
         WHERE t.At_Id = p_At_Id;

        IF l_Action_Sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_Action_Sql;
        END IF;

        Api$act.Write_At_Log (p_At_Id,
                              l_Hs,
                              p_St,
                              CHR (38) || '16',
                              l_St);
    END;

    --====================================================--
    FUNCTION Get_Approve_Cnt (p_At_Id NUMBER)
        RETURN NUMBER
    IS
        l_Ret   NUMBER;
    BEGIN
        /*
        4.2) вікно «Рішення про призначення», кнопка «Затвердити» – зміна статусів повинна відбуватись наступним чином:
        - для рішення зміна SR => SN («Очікування затвердження відмови») – тільки якщо всім послугам у рішенні встановлено статус PR
        - для рішення зміна SR => SW («Очікування затвердження призначення») – якщо хоча б одній послузі встановлено статус PP
        */
        SELECT COUNT (1)
          INTO l_Ret
          FROM At_Service Ats
         WHERE     Ats.Ats_At = p_At_Id
               AND Ats.Ats_St IN ('PP')
               AND Ats.History_Status = 'A';

        RETURN l_Ret;
    END;

    --====================================================--
    PROCEDURE Merge_Pdsp_Ats (p_Ap_Id NUMBER, p_At_Id NUMBER)
    IS
        l_Apop_At_Id   NUMBER;
    BEGIN
        SELECT Apop.At_Id
          INTO l_Apop_At_Id
          FROM Act Apop
         WHERE     (   (Apop.At_Tp = 'APOP' AND Apop.At_St = 'AS')
                    OR (Apop.At_Tp = 'OKS' AND Apop.At_St = 'TP'))
               AND Apop.At_Ap = p_Ap_Id;

        --потім додати умову , коли APOP дійсно не потрібен
        IF l_Apop_At_Id IS NULL
        THEN
            RETURN;
        END IF;

        INSERT INTO At_Service (Ats_Id,
                                Ats_At,
                                Ats_Nst,
                                History_Status,
                                Ats_At_Src,
                                Ats_St,
                                Ats_Ss_Method,
                                Ats_Ss_Address_Tp,
                                Ats_Ss_Address,
                                Ats_Tarif_Sum,
                                Ats_Act_Sum,
                                Ats_Ss_Term)
            SELECT 0           AS x_Id,
                   p_At_Id     AS x_At,
                   Ats.Ats_Nst,
                   Ats.History_Status,
                   Ats.Ats_At,
                   'R'         AS x_St,
                   Ats.Ats_Ss_Method,
                   Ats.Ats_Ss_Address_Tp,
                   Ats.Ats_Ss_Address,
                   Ats.Ats_Tarif_Sum,
                   Ats.Ats_Act_Sum,
                   Ats.Ats_Ss_Term
              FROM At_Service Ats
             WHERE     Ats.Ats_At = l_Apop_At_Id
                   AND NOT EXISTS
                           (SELECT 1
                              FROM At_Service Ats_
                             WHERE     Ats_.Ats_At = p_At_Id
                                   AND Ats_.Ats_Nst = Ats.Ats_Nst
                                   AND (   Ats_.Ats_At =
                                           NVL (Ats_.Ats_At_Src, Ats_.Ats_At)
                                        OR Ats_.Ats_At_Src = Ats.Ats_At)
                                   AND Ats_.History_Status = 'A');

        UPDATE At_Service Ats_
           SET (Ats_.Ats_St, Ats_.Ats_Ss_Term) =
                   (SELECT CASE COUNT (1)
                               WHEN 0 THEN 'PR'
                               ELSE Ats_.Ats_St
                           END,
                           MAX (Ats.Ats_Ss_Term)
                      FROM At_Service Ats
                     WHERE     Ats.Ats_At = l_Apop_At_Id
                           AND Ats.History_Status = 'A'
                           AND Ats.Ats_Nst = Ats_.Ats_Nst)
         WHERE Ats_.Ats_At = p_At_Id AND Ats_.History_Status = 'A';
    END;

    --====================================================--
    PROCEDURE Recalc_Pdsp_Ats_St (p_At_Id NUMBER)
    IS
        l_Ap_Id           NUMBER;
        l_Apop_At_Id      NUMBER;
        l_Is_Need_Apop    NUMBER;
        l_is_no_service   VARCHAR2 (10);
    BEGIN
        SELECT At_Ap
          INTO l_Ap_Id
          FROM Act
         WHERE At_Id = p_At_Id;

        SELECT MAX (Apop.At_Id),
               CASE
                   WHEN (    Api$act.Get_Section_Attr_Val_Str (
                                 MAX (Apop.At_Id),
                                 843) =
                             'T'
                         AND MAX (AT_CONCLUSION_TP) = 'V2')
                   THEN
                       'T'
                   WHEN (    Api$act.Get_Section_Attr_Val_Str (
                                 MAX (Apop.At_Id),
                                 2062) =
                             'T'
                         AND MAX (AT_CONCLUSION_TP) = 'V1')
                   THEN
                       'T'
                   ELSE
                       'F'
               END
          INTO l_Apop_At_Id, l_is_no_service
          FROM Act Apop
         WHERE     Apop.At_Tp = 'APOP'
               AND Apop.At_St = 'AS'
               AND Apop.At_Ap = l_Ap_Id;

        --потім додати умову , коли APOP дійсно не потрібен
        SELECT SIGN (COUNT (1))
          INTO l_Is_Need_Apop
          FROM Act Apop
         WHERE Apop.At_Tp = 'APOP' AND Apop.At_Ap = l_Ap_Id;

        IF l_Apop_At_Id IS NOT NULL
        THEN
            UPDATE At_Service Ats_
               SET Ats_.Ats_St =
                       (SELECT CASE
                                   WHEN Is_Ari > 0
                                   THEN
                                       'PR'
                                   WHEN Is_Apop = 0 AND l_Is_Need_Apop > 0
                                   THEN
                                       'PR'
                                   WHEN Is_Err > 0
                                   THEN
                                       'PR'
                                   ELSE
                                       'PP'
                               END
                          FROM (SELECT (SELECT COUNT (1)
                                          FROM At_Reject_Info r
                                         WHERE r.Ari_Ats = Ats_.Ats_Id)
                                           AS Is_Ari,
                                       (SELECT COUNT (1)
                                          FROM At_Service Ats
                                         WHERE     Ats.Ats_At = l_Apop_At_Id
                                               AND Ats.History_Status = 'A'
                                               AND Ats.Ats_Nst = Ats_.Ats_Nst)
                                           AS Is_Apop,
                                       (SELECT COUNT (1)
                                          FROM at_right_log  arl
                                               JOIN
                                               uss_ndi.v_ndi_right_rule nrr
                                                   ON     nrr.nrr_id =
                                                          arl_nrr
                                                      AND nrr.nrr_tp = 'E'
                                         WHERE     arl.arl_ats = Ats_.Ats_Id
                                               AND arl.arl_result = 'F')
                                           AS Is_Err
                                  FROM DUAL))
             WHERE Ats_.Ats_At = p_At_Id AND Ats_.History_Status = 'A';

            --#111551
            IF l_is_no_service = 'T'
            THEN
                UPDATE at_service ats
                   SET ats.ats_st = 'PR'
                 WHERE ats.ats_at = p_at_Id -- AND ats.ats_st = 'P'
                                            AND ats.history_status = 'A';
            END IF;
        ELSIF l_Is_Need_Apop = 0
        THEN
            UPDATE At_Service Ats_
               SET Ats_.Ats_St =
                       (SELECT CASE
                                   WHEN Is_Ari > 0 THEN 'PR'
                                   WHEN Is_Err > 0 THEN 'PR'
                                   ELSE 'PP'
                               END
                          FROM (SELECT (SELECT COUNT (1)
                                          FROM At_Reject_Info r
                                         WHERE r.Ari_Ats = Ats_.Ats_Id)
                                           AS Is_Ari,
                                       (SELECT COUNT (1)
                                          FROM at_right_log  arl
                                               JOIN
                                               uss_ndi.v_ndi_right_rule nrr
                                                   ON     nrr.nrr_id =
                                                          arl_nrr
                                                      AND nrr.nrr_tp = 'E'
                                         WHERE     arl.arl_ats = Ats_.Ats_Id
                                               AND arl.arl_result = 'F')
                                           AS Is_Err
                                  FROM DUAL))
             WHERE Ats_.Ats_At = p_At_Id AND Ats_.History_Status = 'A';
        END IF;
    /*
          UPDATE at_service s SET
            s.ats_st = CASE (SELECT count(1)
                             FROM at_right_log arl
                                  JOIN uss_ndi.v_ndi_right_rule nrr on nrr.nrr_id=arl_nrr  AND nrr.nrr_tp = 'E'
                             WHERE arl.arl_ats = s.ats_id
                               AND arl.arl_result = 'F')
                       WHEN 0 THEN 'PP'
                       ELSE 'PR'
                       END
          WHERE s.ats_id = rec.ats_id
            AND s.ats_st IN ('R','PP','PR');
      */
    END;

    --====================================================--
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    --====================================================--
    --   Парсинг акту
    --====================================================--
    FUNCTION Parse (p_Type_Name      IN VARCHAR2,
                    p_Clob_Input     IN BOOLEAN DEFAULT TRUE,
                    p_Has_Root_Tag   IN BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Type2xmltable (Pkg,
                              p_Type_Name,
                              TRUE,
                              p_Clob_Input,
                              p_Has_Root_Tag);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act
    IS
        l_Result   r_Act;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Parse ('r_Act')
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу акту: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Persons (p_Xml IN CLOB)
        RETURN t_At_Persons
    IS
        l_Result   t_At_Persons;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Persons ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Persons')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу інормації про осіб в акті: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Sections (p_Xml IN CLOB)
        RETURN t_At_Sections
    IS
        l_Result   t_At_Sections;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Sections ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Sections')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу розділів акту: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Section_Features (p_Xml IN XMLTYPE)
        RETURN t_At_Section_Features
    IS
        l_Result   t_At_Section_Features;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Section_Features ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Section_Features',
                                 p_Clob_Input     => FALSE,
                                 p_Has_Root_Tag   => TRUE)
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу ознак: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Signers (p_Xml IN CLOB)
        RETURN t_At_Signers
    IS
        l_Result   t_At_Signers;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Signers ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Signers')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу підписантів: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Services (p_Xml IN CLOB)
        RETURN t_At_Services
    IS
        l_Result   t_At_Services;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Services ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_services')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу послуг: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Attributes (p_Xml IN CLOB)
        RETURN t_At_Document_Attrs
    IS
        l_Result   t_At_Document_Attrs;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Document_Attrs ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Document_Attrs')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу атрибутів: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Living_Conditions (p_Xml IN CLOB)
        RETURN t_At_Living_Conditions
    IS
        l_Result   t_At_Living_Conditions;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Living_Conditions ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_living_conditions')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу умов проживання: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Other_Spec (p_Xml IN CLOB)
        RETURN t_At_Other_Spec
    IS
        l_Result   t_At_Other_Spec;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Other_Spec ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_at_other_spec')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу залучених спеціялістів: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Individual_Plan (p_Xml IN CLOB)
        RETURN t_At_Individual_Plan
    IS
        l_Result   t_At_Individual_Plan;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Individual_Plan ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Individual_Plan')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу заходів щодо надання СП: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_At_Results (p_Xml IN CLOB)
        RETURN t_At_Results
    IS
        l_Result   t_At_Results;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Results ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_At_Results')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу розділів акту: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Right_Log (p_Xml IN CLOB)
        RETURN t_At_Right_Log
    IS
        l_Result   t_At_Right_Log;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Right_Log ();
        END IF;

        EXECUTE IMMEDIATE Api$act.Parse ('t_At_Right_Log')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу перевірок права: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Documents (p_Xml IN CLOB)
        RETURN t_At_Documents
    IS
        l_Result   t_At_Documents;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Documents ();
        END IF;

        EXECUTE IMMEDIATE Api$act.Parse ('t_At_Documents')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу документів: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Attributes (p_Xml IN XMLTYPE)
        RETURN Api$act.t_At_Document_Attrs
    IS
        l_Result   Api$act.t_At_Document_Attrs;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW Api$act.t_At_Document_Attrs ();
        END IF;

        EXECUTE IMMEDIATE Api$act.Parse ('t_At_Document_Attrs',
                                         p_Clob_Input   => FALSE)
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу атрибутів: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Reject_Info (p_Xml IN CLOB)
        RETURN t_At_Reject_Info
    IS
        l_Result   t_At_Reject_Info;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_At_Reject_Info ();
        END IF;

        EXECUTE IMMEDIATE Api$act.Parse ('t_At_Reject_Info')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу перевірок права: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;


    --====================================================--
    --   Збереження акту
    --====================================================--
    PROCEDURE Save_Act (
        p_At_Id                    Act.At_Id%TYPE,
        p_At_Tp                    Act.At_Tp%TYPE,
        p_At_Pc                    Act.At_Pc%TYPE,
        p_At_Num                   Act.At_Num%TYPE DEFAULT NULL,
        p_At_Dt                    Act.At_Dt%TYPE,
        p_At_Org                   Act.At_Org%TYPE,
        p_At_Sc                    Act.At_Sc%TYPE,
        p_At_Rnspm                 Act.At_Rnspm%TYPE,
        p_At_Rnp                   Act.At_Rnp%TYPE DEFAULT NULL,
        p_At_Ap                    Act.At_Ap%TYPE,
        p_At_St                    Act.At_St%TYPE,
        p_At_Src                   Act.At_Src%TYPE,
        p_At_Case_Class            Act.At_Case_Class%TYPE DEFAULT NULL,
        p_At_Main_Link_Tp          Act.At_Main_Link_Tp%TYPE DEFAULT NULL,
        p_At_Main_Link             Act.At_Main_Link%TYPE DEFAULT NULL,
        p_At_Action_Start_Dt       Act.At_Action_Start_Dt%TYPE DEFAULT NULL,
        p_At_Action_Stop_Dt        Act.At_Action_Stop_Dt%TYPE DEFAULT NULL,
        p_At_Notes                 Act.At_Notes%TYPE DEFAULT NULL,
        p_At_Family_Info           Act.At_Family_Info%TYPE DEFAULT NULL,
        p_At_Live_Address          Act.At_Live_Address%TYPE DEFAULT NULL,
        p_At_Wu                    Act.At_Wu%TYPE DEFAULT NULL,
        p_At_Cu                    Act.At_Cu%TYPE DEFAULT NULL,
        p_At_Conclusion_Tp         Act.At_Conclusion_Tp%TYPE DEFAULT NULL,
        p_At_Form_Tp               Act.At_Form_Tp%TYPE DEFAULT NULL,
        p_At_Ext_Ident             Act.At_Ext_Ident%TYPE DEFAULT NULL,
        p_New_Id               OUT Act.At_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_At_Id, -1) < 0
        THEN
            p_New_Id := Sq_Id_Act.NEXTVAL;

            INSERT INTO Act (At_Id,
                             At_Tp,
                             At_Pc,
                             At_Num,
                             At_Dt,
                             At_Org,
                             At_Sc,
                             At_Rnspm,
                             At_Rnp,
                             At_Ap,
                             At_St,
                             At_Src,
                             At_Case_Class,
                             At_Main_Link_Tp,
                             At_Main_Link,
                             At_Action_Start_Dt,
                             At_Action_Stop_Dt,
                             At_Notes,
                             At_Family_Info,
                             At_Live_Address,
                             At_Wu,
                             At_Cu,
                             At_Conclusion_Tp,
                             At_Form_Tp,
                             At_Ext_Ident)
                 VALUES (p_New_Id,
                         p_At_Tp,
                         p_At_Pc,
                         NVL (p_At_Num, p_New_Id),
                         p_At_Dt,
                         p_At_Org,
                         p_At_Sc,
                         p_At_Rnspm,
                         p_At_Rnp,
                         p_At_Ap,
                         p_At_St,
                         p_At_Src,
                         p_At_Case_Class,
                         p_At_Main_Link_Tp,
                         p_At_Main_Link,
                         p_At_Action_Start_Dt,
                         p_At_Action_Stop_Dt,
                         p_At_Notes,
                         p_At_Family_Info,
                         p_At_Live_Address,
                         p_At_Wu,
                         p_At_Cu,
                         p_At_Conclusion_Tp,
                         p_At_Form_Tp,
                         p_At_Ext_Ident);
        ELSE
            p_New_Id := p_At_Id;

            UPDATE Act a
               SET a.At_Pc = p_At_Pc,
                   a.At_Dt = p_At_Dt,
                   a.At_Org = p_At_Org,
                   a.At_Sc = p_At_Sc,
                   a.At_Rnspm = p_At_Rnspm,
                   a.At_Rnp = p_At_Rnp,
                   a.At_Ap = p_At_Ap,
                   a.At_St = p_At_St,
                   a.At_Src = p_At_Src,
                   a.At_Case_Class = p_At_Case_Class,
                   a.At_Main_Link_Tp = p_At_Main_Link_Tp,
                   a.At_Main_Link = p_At_Main_Link,
                   a.At_Action_Start_Dt = p_At_Action_Start_Dt,
                   a.At_Action_Stop_Dt = p_At_Action_Stop_Dt,
                   a.At_Notes = p_At_Notes,
                   a.At_Family_Info = p_At_Family_Info,
                   a.At_Live_Address = p_At_Live_Address,
                   a.At_Wu = p_At_Wu,
                   a.At_Cu = p_At_Cu,
                   a.At_Conclusion_Tp = p_At_Conclusion_Tp,
                   a.At_Form_Tp = p_At_Form_Tp
             WHERE a.At_Id = p_At_Id;
        END IF;
    END;


    -----------------------------------------------------------
    -- Перевірка порушення цілісності даних акту
    --якщо було передано ІД сутності > 0, перевіряємо
    --щоб ця сутність належала саме до того акту який зберігається
    -----------------------------------------------------------
    PROCEDURE Check_At_Integrity (p_At_Id         IN NUMBER,
                                  p_Table         IN VARCHAR2,
                                  p_Id_Field      IN VARCHAR,
                                  p_At_Field      IN VARCHAR,
                                  p_Id_Val        IN NUMBER,
                                  p_Entity_Name   IN VARCHAR2)
    IS
        l_At_Id   NUMBER;
    BEGIN
        IF NVL (p_Id_Val, -1) < 0
        THEN
            RETURN;
        END IF;

        EXECUTE IMMEDIATE   'SELECT MAX('
                         || p_At_Field
                         || ') FROM '
                         || p_Table
                         || ' WHERE '
                         || p_Id_Field
                         || '= :p_id'
            INTO l_At_Id
            USING p_Id_Val;

        IF l_At_Id IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                p_Entity_Name || '(ІД=' || p_Id_Val || ') не знайдено');
        END IF;

        IF l_At_Id <> p_At_Id
        THEN
            Raise_Application_Error (
                -20000,
                   p_Entity_Name
                || '(ІД='
                || p_Id_Val
                || ') знайдено в іншому акті');
        END IF;
    END;

    PROCEDURE Check_At_Services (p_At_Id IN NUMBER)
    IS
        l_err   VARCHAR2 (2000);
    BEGIN
        SELECT SUBSTR (LISTAGG ('[' || ats_nst || '] ' || nst.nst_name, ','),
                       1,
                       2000)
          INTO l_err
          FROM (  SELECT ats_nst
                    FROM At_Service
                   WHERE Ats_At = p_At_Id AND HISTORY_STATUS = 'A'
                GROUP BY ats_nst
                  HAVING COUNT (1) > 1)
               JOIN uss_ndi.v_ndi_service_type nst ON ats_nst = nst.nst_id;

        IF l_err IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В документі наявні дублі послуг: ' || l_err);
        END IF;
    END;

    PROCEDURE Check_At_Tp (p_At_Id IN NUMBER, p_At_Tp IN VARCHAR2)
    IS
        l_All   NUMBER;
        l_Tp    NUMBER;
    BEGIN
        SELECT COUNT (1),
               NVL (
                   SUM (
                       CASE WHEN a.at_tp = NVL (p_At_Tp, '#NONE#') THEN 1 END),
                   0)
          INTO l_All, l_Tp
          FROM Act a
         WHERE a.at_id = p_At_Id;

        IF l_All = 0
        THEN
            Raise_Application_Error (
                -20000,
                'Документ с ІД ' || p_At_Id || ' не знайдено');
        ELSIF l_Tp = 0
        THEN
            Raise_Application_Error (
                -20000,
                   'Документ с ІД '
                || p_At_Id
                || ' не є документом с типом '
                || NVL (p_At_Tp, '# ТИП НЕ ВКАЗАНО #'));
        END IF;
    END;

    PROCEDURE Check_Atp_Z_Exists (p_At_Id IN NUMBER)
    IS
        l_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_res
          FROM at_person
         WHERE atp_at = p_at_id AND atp_app_tp = 'Z';

        IF l_res = 0
        THEN
            Raise_Application_Error (
                -20000,
                'В переліку учасників відсутній учасник з типом «Заявник»');
        END IF;
    END;

    PROCEDURE Check_Atp_Z_Exists_Incorrect (p_At_Id IN NUMBER)
    IS
        l_ap_id           NUMBER;
        l_ap_is_correct   NUMBER;
    BEGIN
        SELECT at_ap
          INTO l_ap_id
          FROM act
         WHERE at_id = p_at_id;

        l_ap_is_correct :=
            Api$appeal.Is_Appeal_Maked_Correct (p_Ap_Id => l_ap_id);

        IF l_ap_is_correct = 0
        THEN
            Check_Atp_Z_Exists (p_At_Id);
        END IF;
    END;



    -----------------------------------------------------------
    -- Збереження інформації про осіб в акті
    -----------------------------------------------------------
    PROCEDURE Save_Persons (p_At_Id     IN            NUMBER,
                            p_Persons   IN OUT NOCOPY Api$act.t_At_Persons,
                            p_Cu_Id     IN            NUMBER)
    IS
    BEGIN
        IF p_Persons IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_Persons');

        FOR i IN 1 .. p_Persons.COUNT
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_PERSON',
                                p_Id_Field      => 'ATP_ID',
                                p_At_Field      => 'ATP_AT',
                                p_Id_Val        => p_Persons (i).Atp_Id,
                                p_Entity_Name   => 'Особа');

            IF p_Persons (i).Deleted = 1
            THEN
                UPDATE At_Person p
                   SET p.History_Status = 'H'
                 WHERE p.Atp_Id = p_Persons (i).Atp_Id;
            ELSE
                Api$act.Save_Person (
                    p_Atp_Id               => p_Persons (i).Atp_Id,
                    p_Atp_At               => p_At_Id,
                    p_Atp_Sc               => p_Persons (i).Atp_Sc,
                    p_Atp_Fn               => p_Persons (i).Atp_Fn,
                    p_Atp_Mn               => p_Persons (i).Atp_Mn,
                    p_Atp_Ln               => p_Persons (i).Atp_Ln,
                    p_Atp_Birth_Dt         => p_Persons (i).Atp_Birth_Dt,
                    p_Atp_Relation_Tp      => p_Persons (i).Atp_Relation_Tp,
                    p_Atp_Is_Disabled      => p_Persons (i).Atp_Is_Disabled,
                    p_Atp_Is_Capable       => p_Persons (i).Atp_Is_Capable,
                    p_Atp_Work_Place       => p_Persons (i).Atp_Work_Place,
                    p_Atp_Is_Adr_Matching   =>
                        p_Persons (i).Atp_Is_Adr_Matching,
                    p_Atp_Phone            => p_Persons (i).Atp_Phone,
                    p_Atp_Notes            => p_Persons (i).Atp_Notes,
                    p_Atp_Live_Address     => p_Persons (i).Atp_Live_Address,
                    p_Atp_Tp               => p_Persons (i).Atp_Tp,
                    p_Atp_Cu               => p_Cu_Id,
                    p_Atp_App_Tp           => p_Persons (i).Atp_App_Tp,
                    p_Atp_Fact_Address     => p_Persons (i).Atp_Fact_Address,
                    p_Atp_Is_Disordered    => p_Persons (i).Atp_Is_Disordered,
                    p_Atp_Disorder_Record   =>
                        p_Persons (i).Atp_Disorder_Record,
                    p_Atp_Disable_Record   => p_Persons (i).Atp_Disable_Record,
                    p_Atp_Capable_Record   => p_Persons (i).Atp_Capable_Record,
                    p_Atp_Sex              => p_Persons (i).Atp_Sex,
                    p_Atp_Citizenship      => p_Persons (i).Atp_Citizenship,
                    p_Atp_Is_Selfservice   => p_Persons (i).Atp_Is_Selfservice,
                    p_Atp_Is_Vpo           => p_Persons (i).Atp_Is_Vpo,
                    p_Atp_Is_Orphan        => p_Persons (i).Atp_Is_Orphan,
                    p_Atp_Email            => p_Persons (i).Atp_Email,
                    p_Atp_Num              => p_Persons (i).Atp_Num,
                    p_New_Id               => p_Persons (i).New_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження інформації про особу в акті
    --====================================================--

    FUNCTION IsActSCInPersons (p_At_Sc   IN Act.At_Sc%TYPE,
                               p_App     IN t_At_Persons)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
        l_App   t_At_Persons := p_App;
    BEGIN
        SELECT CASE WHEN COUNT (1) > 0 THEN 1 ELSE 0 END
          INTO l_Res
          FROM TABLE (l_App) t
         WHERE t.Atp_Sc = p_At_Sc;

        RETURN l_Res;
    END;

    PROCEDURE CheckIsActSCInPersons (p_At_Sc   IN Act.At_Sc%TYPE,
                                     p_App     IN t_At_Persons)
    IS
    BEGIN
        IF p_At_Sc IS NOT NULL
        THEN
            IF IsActSCInPersons (p_At_Sc, p_App) = 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'Код соціальної картки, переданий в акті, не знайдено у жодного участника');
            END IF;
        END IF;
    END;

    --#APP_NUM
    FUNCTION Get_Next_Atp_Num (p_At_Id IN ACT.AT_ID%TYPE)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT NVL (MAX (atp_num), 0) + 1
          INTO l_res
          FROM at_person
         WHERE atp_at = p_At_Id;

        RETURN l_Res;
    END;

    PROCEDURE Save_Person (
        p_Atp_Id                    At_Person.Atp_Id%TYPE,
        p_Atp_At                    At_Person.Atp_At%TYPE,
        p_Atp_Sc                    At_Person.Atp_Sc%TYPE,
        p_Atp_Fn                    At_Person.Atp_Fn%TYPE,
        p_Atp_Mn                    At_Person.Atp_Mn%TYPE,
        p_Atp_Ln                    At_Person.Atp_Ln%TYPE,
        p_Atp_Birth_Dt              At_Person.Atp_Birth_Dt%TYPE,
        p_Atp_Relation_Tp           At_Person.Atp_Relation_Tp%TYPE,
        p_Atp_Is_Disabled           At_Person.Atp_Is_Disabled%TYPE,
        p_Atp_Is_Capable            At_Person.Atp_Is_Capable%TYPE,
        p_Atp_Work_Place            At_Person.Atp_Work_Place%TYPE,
        p_Atp_Is_Adr_Matching       At_Person.Atp_Is_Adr_Matching%TYPE,
        p_Atp_Phone                 At_Person.Atp_Phone%TYPE,
        p_Atp_Notes                 At_Person.Atp_Notes%TYPE,
        p_Atp_Live_Address          At_Person.Atp_Live_Address%TYPE,
        p_Atp_Tp                    At_Person.Atp_Tp%TYPE,
        p_Atp_Cu                    At_Person.Atp_Cu%TYPE,
        p_Atp_App_Tp                At_Person.Atp_App_Tp%TYPE,
        p_Atp_Fact_Address          At_Person.Atp_Fact_Address%TYPE,
        p_Atp_Is_Disordered         At_Person.Atp_Is_Disordered%TYPE,
        p_Atp_Disorder_Record       At_Person.Atp_Disorder_Record%TYPE,
        p_Atp_Disable_Record        At_Person.Atp_Disable_Record%TYPE,
        p_Atp_Capable_Record        At_Person.Atp_Capable_Record%TYPE,
        p_Atp_Sex                   At_Person.Atp_Sex%TYPE,
        p_Atp_Citizenship           At_Person.Atp_Citizenship%TYPE,
        p_Atp_Is_Selfservice        At_Person.Atp_Is_Selfservice%TYPE,
        p_Atp_Is_Vpo                At_Person.Atp_Is_Vpo%TYPE,
        p_Atp_Is_Orphan             At_Person.Atp_Is_Orphan%TYPE,
        p_Atp_Email                 At_Person.Atp_Email%TYPE,
        p_Atp_Num                   At_Person.Atp_Num%TYPE,
        p_New_Id                OUT At_Person.Atp_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atp_Id, -1) < 0
        THEN
            INSERT INTO At_Person (Atp_Id,
                                   Atp_At,
                                   Atp_Sc,
                                   Atp_Fn,
                                   Atp_Mn,
                                   Atp_Ln,
                                   Atp_Birth_Dt,
                                   Atp_Relation_Tp,
                                   Atp_Is_Disabled,
                                   Atp_Is_Capable,
                                   Atp_Work_Place,
                                   Atp_Is_Adr_Matching,
                                   Atp_Phone,
                                   Atp_Notes,
                                   Atp_Live_Address,
                                   Atp_Tp,
                                   Atp_Cu,
                                   Atp_App_Tp,
                                   Atp_Fact_Address,
                                   Atp_Is_Disordered,
                                   Atp_Disorder_Record,
                                   Atp_Disable_Record,
                                   Atp_Capable_Record,
                                   Atp_Sex,
                                   Atp_Citizenship,
                                   Atp_Is_Selfservice,
                                   Atp_Is_Vpo,
                                   Atp_Is_Orphan,
                                   Atp_Email,
                                   Atp_Num,
                                   History_Status)
                 VALUES (0,
                         p_Atp_At,
                         p_Atp_Sc,
                         p_Atp_Fn,
                         p_Atp_Mn,
                         p_Atp_Ln,
                         p_Atp_Birth_Dt,
                         p_Atp_Relation_Tp,
                         p_Atp_Is_Disabled,
                         p_Atp_Is_Capable,
                         p_Atp_Work_Place,
                         p_Atp_Is_Adr_Matching,
                         p_Atp_Phone,
                         p_Atp_Notes,
                         p_Atp_Live_Address,
                         p_Atp_Tp,
                         p_Atp_Cu,
                         p_Atp_App_Tp,
                         p_Atp_Fact_Address,
                         p_Atp_Is_Disordered,
                         p_Atp_Disorder_Record,
                         p_Atp_Disable_Record,
                         p_Atp_Capable_Record,
                         p_Atp_Sex,
                         p_Atp_Citizenship,
                         p_Atp_Is_Selfservice,
                         p_Atp_Is_Vpo,
                         p_Atp_Is_Orphan,
                         p_Atp_Email,
                         NVL (p_Atp_Num, Get_Next_Atp_Num (p_Atp_At)),
                         'A')
              RETURNING Atp_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atp_Id;

            UPDATE At_Person p
               SET p.Atp_Sc = p_Atp_Sc,
                   p.Atp_Fn = p_Atp_Fn,
                   p.Atp_Mn = p_Atp_Mn,
                   p.Atp_Ln = p_Atp_Ln,
                   p.Atp_Birth_Dt = p_Atp_Birth_Dt,
                   p.Atp_Relation_Tp = p_Atp_Relation_Tp,
                   p.Atp_Is_Disabled = p_Atp_Is_Disabled,
                   p.Atp_Is_Capable = p_Atp_Is_Capable,
                   p.Atp_Work_Place = p_Atp_Work_Place,
                   p.Atp_Is_Adr_Matching = p_Atp_Is_Adr_Matching,
                   p.Atp_Phone = p_Atp_Phone,
                   p.Atp_Notes = p_Atp_Notes,
                   p.Atp_Live_Address = p_Atp_Live_Address,
                   p.Atp_Tp = p_Atp_Tp,
                   p.Atp_Cu = p_Atp_Cu,
                   p.Atp_App_Tp = p_Atp_App_Tp,
                   p.Atp_Fact_Address = p_Atp_Fact_Address,
                   p.Atp_Is_Disordered = p_Atp_Is_Disordered,
                   p.Atp_Disorder_Record = p_Atp_Disorder_Record,
                   p.Atp_Disable_Record = p_Atp_Disable_Record,
                   p.Atp_Capable_Record = p_Atp_Capable_Record,
                   p.Atp_Sex = p_Atp_Sex,
                   p.Atp_Citizenship = p_Atp_Citizenship,
                   p.Atp_Is_Selfservice = p_Atp_Is_Selfservice,
                   p.Atp_Is_Vpo = p_Atp_Is_Vpo,
                   p.Atp_Is_Orphan = p_Atp_Is_Orphan,
                   p.Atp_Email = p_Atp_Email,
                   p.Atp_num = p_Atp_Num
             WHERE p.Atp_Id = p_Atp_Id;
        END IF;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ПЕРЕЛІКУ ОСІБ В АКТІ
    -----------------------------------------------------------
    PROCEDURE Get_Persons (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT p.*,
                   Rt.Dic_Name      AS Atp_Relation_Tp_Name,
                   Appt.Dic_Name    AS Atp_App_Tp_Name,
                   CASE
                       WHEN (SELECT MAX (r.cu2r_cu)
                               FROM ikis_rbm.v_Cu_Users2roles r
                              WHERE     r.Cu2r_Cmes_Owner_Id =
                                        p.atp_sc
                                    AND r.History_Status = 'A'
                                    AND r.Cu2r_Cr = 1)
                                IS NOT NULL
                       THEN
                           'T'
                       ELSE
                           'F'
                   END              AS has_cabinet
              FROM At_Person  p
                   LEFT JOIN Uss_Ndi.v_Ddn_Relation_Tp Rt
                       ON p.Atp_Relation_Tp = Rt.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_App_Tp Appt
                       ON p.Atp_App_Tp = Appt.Dic_Value
             WHERE p.Atp_At = p_At_Id AND p.History_Status = 'A';
    END;

    -----------------------------------------------------------
    -- Збереження розділів акту
    -----------------------------------------------------------
    PROCEDURE Save_Sections (
        p_At_Id      IN            NUMBER,
        p_Sections   IN OUT NOCOPY Api$act.t_At_Sections,
        p_Persons    IN OUT NOCOPY Api$act.t_At_Persons)
    IS
        l_Features   Api$act.t_At_Section_Features;
    BEGIN
        IF p_Sections IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_Sections');

        FOR Rec
            IN (SELECT NVL (Ss.Ate_Id, s.Ate_Id)                   AS Ate_Id,
                       s.Ate_Atp,
                       s.Ate_Nng,
                       s.Ate_Chield_Info,
                       s.Ate_Parent_Info,
                       s.Ate_Notes,
                       s.Ate_Indicator_Value1,
                       s.Ate_Indicator_Value2,
                       s.ate_atop,
                       s.Features,
                       GREATEST (p.Atp_Id, NVL (p.New_Id, -1))     AS Atp_Id
                  FROM TABLE (p_Sections)  s
                       LEFT JOIN TABLE (p_Persons) p ON s.Ate_Atp = p.Atp_Id
                       --Виключаємо можливість дублювання розділу по особі
                       LEFT JOIN At_Section Ss
                           ON     s.Ate_Atp = Ss.Ate_Atp
                              AND s.Ate_Nng = Ss.Ate_Nng)
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_SECTION',
                                p_Id_Field      => 'ATE_ID',
                                p_At_Field      => 'ATE_AT',
                                p_Id_Val        => Rec.Ate_Id,
                                p_Entity_Name   => 'Розділ');

            --Зберігаємо розділ
            Api$act.Save_Section (
                p_Ate_Id                 => Rec.Ate_Id,
                p_Ate_Atp                => Rec.Atp_Id,
                p_Ate_At                 => p_At_Id,
                p_Ate_Nng                => Rec.Ate_Nng,
                p_Ate_Chield_Info        => Rec.Ate_Chield_Info,
                p_Ate_Parent_Info        => Rec.Ate_Parent_Info,
                p_Ate_Indicator_Value1   => Rec.Ate_Indicator_Value1,
                p_Ate_Indicator_Value2   => Rec.Ate_Indicator_Value2,
                p_Ate_Notes              => Rec.Ate_Notes,
                p_Ate_Atop               => Rec.Ate_Atop,
                p_New_Id                 => Rec.Ate_Id);

            IF Rec.Features IS NOT NULL
            THEN
                l_Features := Api$act.Parse_Section_Features (Rec.Features);
                --Зберігаємо ознаки до розділу
                Save_Section_Features (p_At_Id, Rec.Ate_Id, l_Features);
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Sections (
        p_At_Id           IN            NUMBER,
        p_Sections        IN OUT NOCOPY Api$act.t_At_Sections,
        p_Persons         IN OUT NOCOPY Api$act.t_At_Persons,
        p_At_Other_Spec   IN OUT NOCOPY Api$act.t_At_Other_Spec)
    IS
        l_Features   Api$act.t_At_Section_Features;
    BEGIN
        IF p_Sections IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_Sections');

        FOR Rec
            IN (SELECT NVL (Ss.Ate_Id, s.Ate_Id)
                           AS Ate_Id,
                       s.Ate_Atp,
                       s.Ate_Nng,
                       s.Ate_Chield_Info,
                       s.Ate_Parent_Info,
                       s.Ate_Notes,
                       s.Ate_Indicator_Value1,
                       s.Ate_Indicator_Value2,
                       GREATEST (o.Atop_Id, NVL (o.New_Id, -1))
                           AS Atop_Id,
                       s.Features,
                       GREATEST (p.Atp_Id, NVL (p.New_Id, -1))
                           AS Atp_Id
                  FROM TABLE (p_Sections)  s
                       LEFT JOIN TABLE (p_Persons) p ON s.Ate_Atp = p.Atp_Id
                       LEFT JOIN TABLE (p_At_Other_Spec) o
                           ON s.Ate_Atop = o.Atop_Id
                       --Виключаємо можливість дублювання розділу по особі
                       LEFT JOIN At_Section Ss
                           ON     s.Ate_Atp = Ss.Ate_Atp
                              AND s.Ate_Nng = Ss.Ate_Nng)
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_SECTION',
                                p_Id_Field      => 'ATE_ID',
                                p_At_Field      => 'ATE_AT',
                                p_Id_Val        => Rec.Ate_Id,
                                p_Entity_Name   => 'Розділ');

            --Зберігаємо розділ
            Api$act.Save_Section (
                p_Ate_Id                 => Rec.Ate_Id,
                p_Ate_Atp                => Rec.Atp_Id,
                p_Ate_At                 => p_At_Id,
                p_Ate_Nng                => Rec.Ate_Nng,
                p_Ate_Chield_Info        => Rec.Ate_Chield_Info,
                p_Ate_Parent_Info        => Rec.Ate_Parent_Info,
                p_Ate_Indicator_Value1   => Rec.Ate_Indicator_Value1,
                p_Ate_Indicator_Value2   => Rec.Ate_Indicator_Value2,
                p_Ate_Notes              => Rec.Ate_Notes,
                p_Ate_Atop               => Rec.Atop_Id,
                p_New_Id                 => Rec.Ate_Id);

            IF Rec.Features IS NOT NULL
            THEN
                l_Features := Api$act.Parse_Section_Features (Rec.Features);
                --Зберігаємо ознаки до розділу
                Save_Section_Features (p_At_Id, Rec.Ate_Id, l_Features);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження розділу акту
    --====================================================--
    PROCEDURE Save_Section (
        p_Ate_Id                     At_Section.Ate_Id%TYPE,
        p_Ate_Atp                    At_Section.Ate_Atp%TYPE,
        p_Ate_At                     At_Section.Ate_At%TYPE,
        p_Ate_Nng                    At_Section.Ate_Nng%TYPE,
        p_Ate_Chield_Info            At_Section.Ate_Chield_Info%TYPE,
        p_Ate_Parent_Info            At_Section.Ate_Parent_Info%TYPE,
        p_Ate_Indicator_Value1       At_Section.Ate_Indicator_Value1%TYPE,
        p_Ate_Indicator_Value2       At_Section.Ate_Indicator_Value2%TYPE,
        p_Ate_Notes                  At_Section.Ate_Notes%TYPE,
        p_Ate_Atop                   At_Section.Ate_Atop%TYPE,
        p_New_Id                 OUT At_Section.Ate_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Ate_Id, -1) < 0
        THEN
            INSERT INTO At_Section (Ate_Id,
                                    Ate_Atp,
                                    Ate_At,
                                    Ate_Nng,
                                    Ate_Chield_Info,
                                    Ate_Parent_Info,
                                    Ate_Notes,
                                    Ate_Indicator_Value1,
                                    Ate_Indicator_Value2,
                                    Ate_Atop)
                 VALUES (0,
                         p_Ate_Atp,
                         p_Ate_At,
                         p_Ate_Nng,
                         p_Ate_Chield_Info,
                         p_Ate_Parent_Info,
                         p_Ate_Notes,
                         p_Ate_Indicator_Value1,
                         p_Ate_Indicator_Value2,
                         p_Ate_Atop)
              RETURNING Ate_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Ate_Id;

            UPDATE At_Section s
               SET s.Ate_Nng = p_Ate_Nng,
                   s.Ate_Chield_Info = p_Ate_Chield_Info,
                   s.Ate_Parent_Info = p_Ate_Parent_Info,
                   s.Ate_Notes = p_Ate_Notes,
                   s.Ate_Indicator_Value1 = p_Ate_Indicator_Value1,
                   s.Ate_Indicator_Value2 = p_Ate_Indicator_Value2,
                   s.Ate_Atop = p_Ate_Atop,
                   s.Ate_Atp = p_Ate_Atp
             WHERE s.Ate_Id = p_Ate_Id;
        END IF;
    END;

    -----------------------------------------------------------
    --      ОТРИМАННЯ РОЗДІЛІВ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Sections (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, g.Nng_Name AS Ate_Nng_Name
              FROM At_Section  s
                   JOIN Uss_Ndi.v_Ndi_Nda_Group g ON s.Ate_Nng = g.Nng_Id
                   LEFT JOIN At_Person p ON s.Ate_Atp = p.Atp_Id
             WHERE s.Ate_At = p_At_Id AND NVL (p.History_Status, 'A') = 'A';
    END;

    --         ОТРИМАННЯ ПОСЛУГ
    -----------------------------------------------------------
    PROCEDURE Get_Services_Only (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT t.nst_id, t.Nst_Name AS Ats_Nst_Name
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
             WHERE s.Ats_At = p_At_Id AND s.history_status = 'A';
    END;

    -----------------------------------------------------------
    -- Збереження результатів відпрацювання заходів акту
    -----------------------------------------------------------
    PROCEDURE Save_At_Results (
        p_At_Id     IN            NUMBER,
        p_Results   IN OUT NOCOPY Api$act.t_At_Results)
    IS
    BEGIN
        IF p_Results IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_At_Results');

        FOR Rec IN (SELECT atr_id,
                           atr_nst,
                           atr_result,
                           atr_is_redirected,
                           atr_redirect_dt,
                           atr_redirect_rnspm,
                           atr_redirect_else,
                           atr_atip,
                           atr_achievment_level,
                           deleted
                      FROM TABLE (p_Results) s)
        LOOP
            Check_At_Integrity (
                p_At_Id         => p_At_Id,
                p_Table         => 'AT_RESULTS',
                p_Id_Field      => 'ATR_ID',
                p_At_Field      => 'ATR_AT',
                p_Id_Val        => Rec.Atr_Id,
                p_Entity_Name   => 'Результат відпрацювання заходів');

            IF Rec.deleted = 1 AND Rec.atr_id > 0
            THEN
                UPDATE At_Results
                   SET History_Status = 'H'
                 WHERE Atr_Id = Rec.Atr_Id;
            ELSE
                --Зберігаємо розділ
                Api$act.Save_At_Result (
                    P_Atr_Id                 => Rec.Atr_Id,
                    P_Atr_At                 => p_At_Id,
                    P_Atr_Nst                => Rec.Atr_Nst,
                    P_Atr_Result             => Rec.Atr_Result,
                    P_Atr_Is_Redirected      => Rec.Atr_Is_Redirected,
                    P_Atr_Redirect_Dt        => Rec.Atr_Redirect_Dt,
                    P_Atr_Redirect_Rnspm     => Rec.Atr_Redirect_Rnspm,
                    P_Atr_Redirect_Else      => Rec.Atr_Redirect_Else,
                    P_Atr_Atip               => Rec.Atr_Atip,
                    P_Atr_Achievment_Level   => Rec.Atr_Achievment_Level,
                    p_New_Id                 => Rec.Atr_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Збереження результату відпрацювання заходів
    --====================================================--
    PROCEDURE Save_At_Result (
        P_Atr_Id                     At_Results.Atr_Id%TYPE,
        P_Atr_At                     At_Results.Atr_AT%TYPE,
        P_Atr_Nst                    At_Results.Atr_NST%TYPE,
        P_Atr_Result                 At_Results.Atr_RESULT%TYPE,
        P_Atr_Is_Redirected          At_Results.Atr_IS_REDIRECTED%TYPE,
        P_Atr_Redirect_Dt            At_Results.Atr_REDIRECT_DT%TYPE,
        P_Atr_Redirect_Rnspm         At_Results.Atr_REDIRECT_RNSPM%TYPE,
        P_Atr_Redirect_Else          At_Results.Atr_REDIRECT_ELSE%TYPE,
        P_Atr_Atip                   At_Results.Atr_ATIP%TYPE,
        P_Atr_Achievment_Level       At_Results.Atr_ACHIEVMENT_LEVEL%TYPE,
        p_New_Id                 OUT At_Results.Atr_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atr_Id, -1) < 0
        THEN
            INSERT INTO AT_RESULTS (ATR_AT,
                                    ATR_NST,
                                    ATR_RESULT,
                                    ATR_IS_REDIRECTED,
                                    ATR_REDIRECT_DT,
                                    ATR_REDIRECT_RNSPM,
                                    ATR_REDIRECT_ELSE,
                                    ATR_ATIP,
                                    ATR_ACHIEVMENT_LEVEL,
                                    history_status)
                 VALUES (p_ATR_AT,
                         p_ATR_NST,
                         p_ATR_RESULT,
                         p_ATR_IS_REDIRECTED,
                         p_ATR_REDIRECT_DT,
                         p_ATR_REDIRECT_RNSPM,
                         p_ATR_REDIRECT_ELSE,
                         p_ATR_ATIP,
                         p_ATR_ACHIEVMENT_LEVEL,
                         'A')
              RETURNING ATR_ID
                   INTO p_new_id;
        ELSE
            p_New_Id := p_Atr_Id;

            UPDATE AT_RESULTS s
               SET ATR_RESULT = p_ATR_RESULT,
                   ATR_IS_REDIRECTED = p_ATR_IS_REDIRECTED,
                   ATR_REDIRECT_DT = p_ATR_REDIRECT_DT,
                   ATR_REDIRECT_RNSPM = p_ATR_REDIRECT_RNSPM,
                   ATR_REDIRECT_ELSE = p_ATR_REDIRECT_ELSE,
                   ATR_ATIP = p_ATR_ATIP,
                   ATR_ACHIEVMENT_LEVEL = p_ATR_ACHIEVMENT_LEVEL
             WHERE s.Atr_Id = p_Atr_Id;
        END IF;
    END;

    --====================================================--
    --   Збереження Соціально-побутові умови проживання
    --====================================================--
    PROCEDURE Save_Living_Condition (
        p_Atlc_Id                      At_Living_Conditions.Atlc_Id%TYPE,
        p_Atlc_At                      At_Living_Conditions.Atlc_At%TYPE,
        p_Atlc_Living_Square           At_Living_Conditions.Atlc_Living_Square%TYPE,
        p_Atlc_Holding_Square          At_Living_Conditions.Atlc_Holding_Square%TYPE,
        p_Atlc_Housing_Condition       At_Living_Conditions.Atlc_Housing_Condition%TYPE,
        p_Atlc_Residents_Cnt           At_Living_Conditions.Atlc_Residents_Cnt%TYPE,
        p_Atlc_Inv_Cnt                 At_Living_Conditions.Atlc_Inv_Cnt%TYPE,
        p_Atlc_Inv_Child_Cnt           At_Living_Conditions.Atlc_Inv_Child_Cnt%TYPE,
        p_New_Id                   OUT At_Living_Conditions.Atlc_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atlc_Id, -1) < 0
        THEN
            INSERT INTO At_Living_Conditions (Atlc_Id,
                                              Atlc_At,
                                              Atlc_Living_Square,
                                              Atlc_Holding_Square,
                                              Atlc_Housing_Condition,
                                              Atlc_Residents_Cnt,
                                              Atlc_Inv_Cnt,
                                              Atlc_Inv_Child_Cnt)
                 VALUES (0,
                         p_Atlc_At,
                         p_Atlc_Living_Square,
                         p_Atlc_Holding_Square,
                         p_Atlc_Housing_Condition,
                         p_Atlc_Residents_Cnt,
                         p_Atlc_Inv_Cnt,
                         p_Atlc_Inv_Child_Cnt)
              RETURNING Atlc_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atlc_Id;

            UPDATE At_Living_Conditions l
               SET Atlc_Living_Square = p_Atlc_Living_Square,
                   Atlc_Holding_Square = p_Atlc_Holding_Square,
                   Atlc_Housing_Condition = p_Atlc_Housing_Condition,
                   Atlc_Residents_Cnt = p_Atlc_Residents_Cnt,
                   Atlc_Inv_Cnt = p_Atlc_Inv_Cnt,
                   Atlc_Inv_Child_Cnt = p_Atlc_Inv_Child_Cnt
             WHERE l.Atlc_Id = p_Atlc_Id;
        END IF;
    END;

    PROCEDURE Save_Living_Conditions (
        p_At_Id               IN            NUMBER,
        p_Living_Conditions   IN OUT NOCOPY Api$act.t_At_Living_Conditions,
        p_Cu_Id               IN            NUMBER                    --Ignore
                                                  )
    IS
    BEGIN
        IF p_Living_Conditions IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_living_conditions');

        FOR i IN 1 .. p_Living_Conditions.COUNT
        LOOP
            Check_At_Integrity (
                p_At_Id         => p_At_Id,
                p_Table         => 'AT_LIVING_CONDITIONS',
                p_Id_Field      => 'ATLC_ID',
                p_At_Field      => 'ATLC_AT',
                p_Id_Val        => p_Living_Conditions (i).Atlc_Id,
                p_Entity_Name   => 'Соціально-побутові умови проживання');

            IF p_Living_Conditions (i).Deleted = 1
            THEN
                DELETE FROM At_Living_Conditions l
                      WHERE l.Atlc_Id = p_Living_Conditions (i).Atlc_Id;
            ELSE
                Api$act.Save_Living_Condition (
                    p_Atlc_Id              => p_Living_Conditions (i).Atlc_Id,
                    p_Atlc_At              => p_At_Id,
                    p_Atlc_Living_Square   =>
                        p_Living_Conditions (i).Atlc_Living_Square,
                    p_Atlc_Holding_Square   =>
                        p_Living_Conditions (i).Atlc_Holding_Square,
                    p_Atlc_Housing_Condition   =>
                        p_Living_Conditions (i).Atlc_Housing_Condition,
                    p_Atlc_Residents_Cnt   =>
                        p_Living_Conditions (i).Atlc_Residents_Cnt,
                    p_Atlc_Inv_Cnt         => p_Living_Conditions (i).Atlc_Inv_Cnt,
                    p_Atlc_Inv_Child_Cnt   =>
                        p_Living_Conditions (i).Atlc_Inv_Child_Cnt,
                    p_New_Id               => p_Living_Conditions (i).Atlc_Id);
            END IF;
        END LOOP;
    END;

    --====================================================--
    --   Отримання Соціально-побутові умови проживання
    --====================================================--
    /*
      PROCEDURE Get_living_conditions(p_atlc_id IN NUMBER,
                                      p_Res    OUT SYS_REFCURSOR) IS
      BEGIN
        OPEN p_Res FOR
          SELECT l.*
            FROM At_living_conditions l
           WHERE l.atlc_id = p_atlc_id;
      END;
    */
    PROCEDURE Get_Living_Conditions (p_At_Id   IN     NUMBER,
                                     p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT l.*, c.Dic_Name AS Atlc_Housing_Condition_Name
              FROM At_Living_Conditions  l
                   JOIN Uss_Ndi.v_Ddn_Housing_Condition c
                       ON l.Atlc_Housing_Condition = c.Dic_Value
             WHERE l.Atlc_At = p_At_Id;
    END;

    -----------------------------------------------------------
    -- Збереження ознак до розділу акту
    -----------------------------------------------------------
    PROCEDURE Save_Section_Features (
        p_At_Id      IN            NUMBER,
        p_Ate_Id     IN            NUMBER,
        p_Features   IN OUT NOCOPY Api$act.t_At_Section_Features)
    IS
    BEGIN
        Write_Audit ('Save_Section_Features');

        FOR Rec
            IN (SELECT NVL (Ff.Atef_Id, f.Atef_Id)     AS Atef_Id,
                       f.Atef_Nda,
                       f.Atef_Feature,
                       f.Atef_Notes
                  FROM TABLE (p_Features)  f
                       --Запобігаємо дублювання ознаки з таким типом в рамках розділу
                       LEFT JOIN At_Section_Feature Ff
                           ON     p_Ate_Id = Ff.Atef_Ate
                              AND f.Atef_Nda = Ff.Atef_Nda)
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_SECTION_FEATURE',
                                p_Id_Field      => 'ATEF_ID',
                                p_At_Field      => 'ATEF_AT',
                                p_Id_Val        => Rec.Atef_Id,
                                p_Entity_Name   => 'Ознака');

            Api$act.Save_Section_Feature (
                p_Atef_Id        => Rec.Atef_Id,
                p_Atef_Ate       => p_Ate_Id,
                p_Atef_At        => p_At_Id,
                p_Atef_Nda       => Rec.Atef_Nda,
                p_Atef_Feature   => Rec.Atef_Feature,
                p_Atef_Notes     => Rec.Atef_Notes,
                p_New_Id         => Rec.Atef_Id);
        END LOOP;
    END;

    --====================================================--
    --   Збереження ознаки
    --====================================================--
    PROCEDURE Save_Section_Feature (
        p_Atef_Id            At_Section_Feature.Atef_Id%TYPE,
        p_Atef_Ate           At_Section_Feature.Atef_Ate%TYPE,
        p_Atef_At            At_Section_Feature.Atef_At%TYPE,
        p_Atef_Nda           At_Section_Feature.Atef_Nda%TYPE,
        p_Atef_Feature       At_Section_Feature.Atef_Feature%TYPE,
        p_Atef_Notes         At_Section_Feature.Atef_Notes%TYPE,
        p_New_Id         OUT At_Section_Feature.Atef_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atef_Id, -1) < 0
        THEN
            INSERT INTO At_Section_Feature (Atef_Id,
                                            Atef_Ate,
                                            Atef_At,
                                            Atef_Nda,
                                            Atef_Feature,
                                            Atef_Notes)
                 VALUES (0,
                         p_Atef_Ate,
                         p_Atef_At,
                         p_Atef_Nda,
                         p_Atef_Feature,
                         p_Atef_Notes)
              RETURNING Atef_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atef_Id;

            UPDATE At_Section_Feature f
               SET f.Atef_Nda = p_Atef_Nda,
                   f.Atef_Feature = p_Atef_Feature,
                   f.Atef_Notes = p_Atef_Notes
             WHERE f.Atef_Id = p_Atef_Id;
        END IF;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ОЗНАК В АКТІ
    -----------------------------------------------------------
    PROCEDURE Get_Section_Features (p_At_Id   IN     NUMBER,
                                    p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT f.*, a.Nda_Name AS Atef_Nda_Name
              FROM At_Section_Feature  f
                   JOIN Uss_Ndi.v_Ndi_Document_Attr a
                       ON f.Atef_Nda = a.Nda_Id
                   JOIN At_Section s ON f.Atef_Ate = s.Ate_Id
                   LEFT JOIN At_Person p ON s.Ate_Atp = p.Atp_Id
             WHERE f.Atef_At = p_At_Id AND NVL (p.History_Status, 'A') = 'A';
    END;

    -----------------------------------------------------------
    -- Збереження підписантів
    -----------------------------------------------------------
    PROCEDURE Save_Signers (p_At_Id     IN            NUMBER,
                            p_Signers   IN OUT NOCOPY Api$act.t_At_Signers)
    IS
        l_Documents   t_At_Documents := t_At_Documents ();
        l_Persons     t_At_Persons := t_At_Persons ();
    BEGIN
        Save_Signers (p_At_Id       => p_At_Id,
                      p_Signers     => p_Signers,
                      p_Persons     => l_Persons,
                      p_Documents   => l_Documents);
    END;

    -----------------------------------------------------------
    -- Збереження підписантів
    -----------------------------------------------------------
    PROCEDURE Save_Signers (p_At_Id     IN            NUMBER,
                            p_Signers   IN OUT NOCOPY Api$act.t_At_Signers,
                            p_Persons   IN OUT NOCOPY Api$act.t_At_Persons)
    IS
        l_Documents   t_At_Documents := t_At_Documents ();
    BEGIN
        Save_Signers (p_At_Id       => p_At_Id,
                      p_Signers     => p_Signers,
                      p_Persons     => p_Persons,
                      p_Documents   => l_Documents);
    END;

    -----------------------------------------------------------
    -- Збереження підписантів
    -----------------------------------------------------------
    PROCEDURE Save_Signers (
        p_At_Id       IN            NUMBER,
        p_Signers     IN OUT NOCOPY Api$act.t_At_Signers,
        p_Persons     IN OUT NOCOPY Api$act.t_At_Persons,
        p_Documents   IN OUT NOCOPY Api$act.t_At_Documents)
    IS
    BEGIN
        IF p_Signers IS NULL
        THEN
            RETURN;
        END IF;

        FOR Rec
            IN (SELECT s.*,
                       GREATEST (p.Atp_Id, NVL (p.New_Id, -1))     AS Atp_Id,
                       GREATEST (d.Atd_Id, NVL (d.New_Id, -1))     AS Atd_Id,
                       Ss.Ati_Is_Signed
                  FROM TABLE (p_Signers)  s
                       LEFT JOIN TABLE (p_Persons) p ON s.Ati_Atp = p.Atp_Id
                       LEFT JOIN At_Signers Ss ON s.Ati_Id = Ss.Ati_Id
                       LEFT JOIN TABLE (p_Documents) d
                           ON s.Ati_Atd = d.Atd_Id)
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_SIGNERS',
                                p_Id_Field      => 'ATI_ID',
                                p_At_Field      => 'ATI_AT',
                                p_Id_Val        => Rec.Ati_Id,
                                p_Entity_Name   => 'Підписант');

            IF Rec.Ati_Id > 0
            THEN
                IF Rec.Deleted = 1
                THEN
                    UPDATE At_Signers s
                       SET s.History_Status = 'H'
                     WHERE s.Ati_Id = Rec.Ati_Id;
                ELSE
                    IF Rec.Ati_Is_Signed = 'T'
                    THEN
                        --Не даємо відредагувати підписанта, якйи вже наклав підпис
                        CONTINUE;
                    END IF;

                    UPDATE At_Signers s
                       SET s.Ati_Sc = Rec.Ati_Sc,
                           s.Ati_Order = Rec.Ati_Order,
                           s.Ati_Atp = Rec.Ati_Atp,
                           s.Ati_Tp = Rec.Ati_Tp,
                           s.Ati_Atd = Rec.Atd_Id
                     WHERE s.Ati_Id = Rec.Ati_Id;
                END IF;
            ELSE
                INSERT INTO At_Signers (Ati_Id,
                                        Ati_At,
                                        History_Status,
                                        Ati_Sc,
                                        Ati_Order,
                                        Ati_Atp,
                                        Ati_Tp,
                                        Ati_Is_Signed,
                                        Ati_Cu,
                                        Ati_Atd)
                     VALUES -- гарна спроба хацкер, але ні, не буде проставлятись ознака підписання при створенні.
                             (0,
                              p_At_Id,
                              'A',
                              Rec.Ati_Sc,
                              Rec.Ati_Order,
                              Rec.Atp_Id,
                              Rec.Ati_Tp,
                              'F'              /*Nvl(Rec.Ati_Is_Signed, 'F')*/
                                 ,
                              Rec.Ati_Cu,
                              Rec.Atd_Id);
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ІМЕНІ ПІДПИСАНТ
    -----------------------------------------------------------
    FUNCTION Get_Signer_Name (p_Ati_Sc    IN NUMBER,
                              p_Ati_Cu    IN NUMBER,
                              p_Ati_Wu    IN NUMBER,
                              p_Ati_atp   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
        IF p_Ati_Cu IS NOT NULL
        THEN
            RETURN Ikis_Rbm.Tools.Getcupib (p_Ati_Cu);
        END IF;

        IF p_Ati_Wu IS NOT NULL
        THEN
            SELECT Wu_Pib
              INTO l_Result
              FROM ikis_sysweb.v$all_users   --Ikis_Sysweb.V$w_Users4hierarchy
             WHERE Wu_Id = p_Ati_Wu;

            RETURN l_Result;
        END IF;

        IF p_Ati_Sc IS NOT NULL
        THEN
            RETURN Uss_Person.Api$sc_Tools.Get_Pib (p_Ati_Sc);
        END IF;

        IF p_Ati_atp IS NOT NULL
        THEN
            SELECT p.atp_fn || ' ' || p.atp_fn || ' ' || p.atp_fn
              INTO l_Result
              FROM At_Person p
             WHERE p.atp_id = p_Ati_atp;

            RETURN l_Result;
        END IF;

        RETURN NULL;
    END;



    -----------------------------------------------------------
    --         ОТРИМАННЯ ПЕРЕЛІКУ ПІДПИСАНТІВ В АКТІ
    -----------------------------------------------------------
    PROCEDURE Get_Signers (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT s.*,
                     t.Dic_Name                             AS Ati_Tp_Name,
                     api$act.Get_Signer_Name (Ati_Sc,
                                              Ati_Cu,
                                              Ati_Wu,
                                              s.ati_atp)    AS Ati_Signer_Name
                FROM At_Signers s
                     JOIN Uss_Ndi.v_Ddn_Ati_Tp t ON s.Ati_Tp = t.Dic_Value
               WHERE s.Ati_At = p_At_Id AND s.History_Status = 'A'
            ORDER BY s.Ati_Order;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ЗАЛУЧЕНИХ СПЕЦІАЛІСТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Other_Spec (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Dic_Name AS Atop_Tp_Name
              FROM At_Other_Spec  s
                   JOIN Uss_Ndi.v_Ddn_Atop_Avop_Tp t
                       ON s.Atop_Tp = t.Dic_Value
             WHERE s.Atop_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСЛУГ
    ----------------------------------------------------------
    PROCEDURE Save_Services (p_At_Id      IN            NUMBER,
                             p_Services   IN OUT NOCOPY t_At_Services)
    IS
        l_Hs          NUMBER;
        l_Tarif_Sum   NUMBER;
    BEGIN
        IF p_Services IS NULL
        THEN
            RETURN;
        END IF;

        /*
         ats_tarif_sum
        */

        FOR Rec
            IN (SELECT NVL (Ss.Ats_Id, s.Ats_Id)     AS Ats_Id,
                       s.Ats_Nst,
                       s.Ats_Ss_Method,
                       s.Ats_Ss_Address_Tp,
                       s.Ats_Ss_Address,
                       s.Ats_Tarif_Sum,
                       s.Ats_Act_Sum,
                       s.Ats_Rnspa,
                       s.Deleted,
                       s.Ats_Ss_Term
                  FROM TABLE (p_Services)  s
                       LEFT JOIN At_Service Ss
                           ON     p_At_Id = Ss.Ats_At
                              AND s.Ats_Nst = Ss.Ats_Nst
                              AND Ss.History_Status = 'A')
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_SERVICE',
                                p_Id_Field      => 'ATS_ID',
                                p_At_Field      => 'ATS_AT',
                                p_Id_Val        => Rec.Ats_Id,
                                p_Entity_Name   => 'Послуга');


            IF Rec.Ats_Id > 0 AND Rec.Deleted = 1
            THEN
                UPDATE At_Service s
                   SET s.History_Status = 'H'
                 WHERE s.Ats_Id = Rec.Ats_Id;

                l_Hs := NVL (l_Hs, tools.GetHistSession);
            --         Write_At_Log(p_At_Id, l_Hs, '', 'SET s.History_Status = ''H'' WHERE s.Ats_Id = '||s.Ats_Id = Ats_Id, NULL);


            ELSE
                --шукаємо тариф
                SELECT MAX (t.rnspt_sum)
                  INTO l_Tarif_Sum
                  FROM act  a
                       JOIN uss_rnsp.v_rnsp_tariff t
                           ON t.rnspt_rnspm = a.at_rnspm
                 WHERE     a.at_id = p_At_Id
                       AND t.rnspt_nst = rec.ats_nst
                       AND SYSDATE BETWEEN t.rnspt_start_dt
                                       AND NVL (t.rnspt_stop_dt, SYSDATE);

                /*
                        FROM act a
                          JOIN uss_rnsp.v_rnsp r ON r.RNSPM_ID = a.at_rnspm
                          JOIN uss_rnsp.v_rnsp2service rs ON rs.rnsp2s_rnsps = r.RNSPS_ID
                          JOIN uss_rnsp.v_ rnsp_dict_service s ON s.RNSPDS_ID = rs.rnsp2s_rnspds
                        WHERE a.at_id = p_At_Id;*/


                Save_Service (p_Ats_Id              => Rec.Ats_Id,
                              p_Ats_At              => p_At_Id,
                              p_Ats_Nst             => Rec.Ats_Nst,
                              p_History_Status      => 'A',
                              p_Ats_At_Src          => NULL,
                              p_Ats_St              => 'R',   --todo: уточнити
                              p_Ats_Ss_Method       => Rec.Ats_Ss_Method,
                              p_Ats_Ss_Address_Tp   => Rec.Ats_Ss_Address_Tp,
                              p_Ats_Ss_Address      => Rec.Ats_Ss_Address,
                              p_Ats_Tarif_Sum       => l_Tarif_Sum, --nvl(Rec.Ats_Tarif_Sum, l_Tarif_Sum),
                              p_Ats_Act_Sum         => Rec.Ats_Act_Sum,
                              p_Ats_Rnspa           => rec.Ats_Rnspa,
                              p_Ats_Ss_Term         => rec.Ats_Ss_Term,
                              p_New_Id              => Rec.Ats_Id);
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСЛУГИ
    ----------------------------------------------------------
    PROCEDURE Save_Service (
        p_Ats_Id                  At_Service.Ats_Id%TYPE,
        p_Ats_At                  At_Service.Ats_At%TYPE,
        p_Ats_Nst                 At_Service.Ats_Nst%TYPE,
        p_History_Status          At_Service.History_Status%TYPE,
        p_Ats_At_Src              At_Service.Ats_At_Src%TYPE,
        p_Ats_St                  At_Service.Ats_St%TYPE,
        p_Ats_Ss_Method           At_Service.Ats_Ss_Method%TYPE,
        p_Ats_Ss_Address_Tp       At_Service.Ats_Ss_Address_Tp%TYPE,
        p_Ats_Ss_Address          At_Service.Ats_Ss_Address%TYPE,
        p_Ats_Tarif_Sum           At_Service.Ats_Tarif_Sum%TYPE,
        p_Ats_Act_Sum             At_Service.Ats_Act_Sum%TYPE,
        p_Ats_Rnspa               At_Service.Ats_Rnspa%TYPE,
        p_Ats_Ss_Term             At_Service.Ats_Ss_Term%TYPE,
        p_New_Id              OUT At_Service.Ats_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Ats_Id, -1) < 0
        THEN
            INSERT INTO At_Service (Ats_Id,
                                    Ats_At,
                                    Ats_Nst,
                                    History_Status,
                                    Ats_At_Src,
                                    Ats_St,
                                    Ats_Ss_Method,
                                    Ats_Ss_Address_Tp,
                                    Ats_Ss_Address,
                                    Ats_Tarif_Sum,
                                    Ats_Act_Sum,
                                    Ats_Rnspa,
                                    Ats_Ss_Term)
                 VALUES (0,
                         p_Ats_At,
                         p_Ats_Nst,
                         p_History_Status,
                         p_Ats_At_Src,
                         p_Ats_St,
                         p_Ats_Ss_Method,
                         p_Ats_Ss_Address_Tp,
                         p_Ats_Ss_Address,
                         p_Ats_Tarif_Sum,
                         p_Ats_Act_Sum,
                         p_Ats_Rnspa,
                         p_Ats_Ss_Term)
              RETURNING Ats_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Ats_Id;

            UPDATE At_Service s
               SET s.Ats_Nst = p_Ats_Nst,
                   s.History_Status = p_History_Status,
                   s.Ats_At_Src = p_Ats_At_Src,
                   s.Ats_Ss_Method = p_Ats_Ss_Method,
                   s.Ats_Ss_Address_Tp = p_Ats_Ss_Address_Tp,
                   s.Ats_Ss_Address = p_Ats_Ss_Address,
                   s.Ats_Tarif_Sum = p_Ats_Tarif_Sum,
                   s.Ats_Act_Sum = p_Ats_Act_Sum,
                   s.Ats_Rnspa = p_Ats_Rnspa,
                   s.Ats_Ss_Term = p_Ats_Ss_Term
             WHERE s.Ats_Id = p_Ats_Id;

            IF SQL%ROWCOUNT = 0
            THEN
                INSERT INTO At_Service (Ats_Id,
                                        Ats_At,
                                        Ats_Nst,
                                        History_Status,
                                        Ats_At_Src,
                                        Ats_St,
                                        Ats_Ss_Method,
                                        Ats_Ss_Address_Tp,
                                        Ats_Ss_Address,
                                        Ats_Tarif_Sum,
                                        Ats_Act_Sum,
                                        Ats_Rnspa,
                                        Ats_Ss_Term)
                     VALUES (p_Ats_Id,
                             p_Ats_At,
                             p_Ats_Nst,
                             p_History_Status,
                             p_Ats_At_Src,
                             p_Ats_St,
                             p_Ats_Ss_Method,
                             p_Ats_Ss_Address_Tp,
                             p_Ats_Ss_Address,
                             p_Ats_Tarif_Sum,
                             p_Ats_Act_Sum,
                             p_Ats_Rnspa,
                             p_Ats_Ss_Term);
            END IF;
        END IF;
    END;

    PROCEDURE Save_Other_Spec (
        p_Atop_Id             At_Other_Spec.Atop_Id%TYPE,
        p_Atop_At             At_Other_Spec.Atop_At%TYPE,
        p_Atop_Fn             At_Other_Spec.Atop_Fn%TYPE,
        p_Atop_Mn             At_Other_Spec.Atop_Mn%TYPE,
        p_Atop_Ln             At_Other_Spec.Atop_Ln%TYPE,
        p_Atop_Phone          At_Other_Spec.Atop_Phone%TYPE,
        p_Atop_Atip           At_Other_Spec.Atop_Atip%TYPE,
        p_Atop_Position       At_Other_Spec.Atop_Position%TYPE,
        p_Atop_Tp             At_Other_Spec.Atop_Tp%TYPE,
        p_Atop_Order          At_Other_Spec.Atop_Order%TYPE,
        p_Atop_Notes          At_Other_Spec.Atop_Notes%TYPE,
        p_Atop_Atp            At_Other_Spec.Atop_Atp%TYPE,
        p_New_Id          OUT At_Other_Spec.Atop_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atop_Id, -1) < 0
        THEN
            INSERT INTO At_Other_Spec (Atop_Id,
                                       Atop_At,
                                       Atop_Fn,
                                       Atop_Mn,
                                       Atop_Ln,
                                       Atop_Phone,
                                       Atop_Atip,
                                       Atop_Position,
                                       Atop_Tp,
                                       History_Status,
                                       Atop_Order,
                                       Atop_Notes,
                                       Atop_Atp)
                 VALUES (0,
                         p_Atop_At,
                         p_Atop_Fn,
                         p_Atop_Mn,
                         p_Atop_Ln,
                         p_Atop_Phone,
                         p_Atop_Atip,
                         p_Atop_Position,
                         p_Atop_Tp,
                         'A',
                         p_Atop_Order,
                         p_Atop_Notes,
                         p_Atop_Atp)
              RETURNING Atop_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atop_Id;

            UPDATE At_Other_Spec s
               SET s.Atop_Fn = p_Atop_Fn,
                   s.Atop_Mn = p_Atop_Mn,
                   s.Atop_Ln = p_Atop_Ln,
                   s.Atop_Phone = p_Atop_Phone,
                   s.Atop_Atip = p_Atop_Atip,
                   s.Atop_Position = p_Atop_Position,
                   s.Atop_Tp = p_Atop_Tp,
                   s.Atop_Order = p_Atop_Order,
                   s.Atop_Notes = p_Atop_Notes,
                   s.Atop_Atp = p_Atop_Atp
             WHERE s.Atop_Id = p_Atop_Id;
        END IF;
    END;

    PROCEDURE Save_Other_Specs (
        p_At_Id         IN            NUMBER,
        p_Other_Specs   IN OUT NOCOPY t_At_Other_Spec)
    IS
    BEGIN
        IF p_Other_Specs IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_Other_Specs');

        FOR i IN 1 .. p_Other_Specs.COUNT
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_OTHER_SPEC',
                                p_Id_Field      => 'ATOP_ID',
                                p_At_Field      => 'ATOP_AT',
                                p_Id_Val        => p_Other_Specs (i).Atop_Id,
                                p_Entity_Name   => 'Залучений спеціаліст');

            IF     p_Other_Specs (i).Deleted = 1
               AND p_Other_Specs (i).Atop_Id > 0
            THEN
                UPDATE At_Other_Spec s
                   SET s.History_Status = 'H'
                 WHERE s.Atop_Id = p_Other_Specs (i).Atop_Id;
            ELSE
                Save_Other_Spec (
                    p_Atop_Id         => p_Other_Specs (i).Atop_Id,
                    p_Atop_At         => p_At_Id,
                    p_Atop_Fn         => p_Other_Specs (i).Atop_Fn,
                    p_Atop_Mn         => p_Other_Specs (i).Atop_Mn,
                    p_Atop_Ln         => p_Other_Specs (i).Atop_Ln,
                    p_Atop_Phone      => p_Other_Specs (i).Atop_Phone,
                    p_Atop_Atip       =>
                        CASE
                            WHEN p_Other_Specs (i).Atop_Atip > 0
                            THEN
                                p_Other_Specs (i).Atop_Atip
                        END,
                    p_Atop_Position   => p_Other_Specs (i).Atop_Position,
                    p_Atop_Tp         => p_Other_Specs (i).Atop_Tp,
                    p_Atop_Order      => p_Other_Specs (i).Atop_Order,
                    p_Atop_Notes      => p_Other_Specs (i).Atop_Notes,
                    p_Atop_Atp        => p_Other_Specs (i).Atop_Atp,
                    p_New_Id          => p_Other_Specs (i).New_Id);
            END IF;
        END LOOP;
    END;

    PROCEDURE Map_Atop_Atip (
        p_Other_Specs        IN OUT NOCOPY t_At_Other_Spec,
        p_Individual_Plans   IN OUT NOCOPY t_At_Individual_Plan)
    IS
    BEGIN
        FOR i IN 1 .. p_Other_Specs.COUNT
        LOOP
            IF p_Other_Specs (i).Atop_Atip < 0
            THEN
                SELECT MAX (New_Id)
                  INTO p_Other_Specs (i).Atop_Atip
                  FROM TABLE (p_Individual_Plans)
                 WHERE Atip_Id = p_Other_Specs (i).Atop_Atip;
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Individual_Plan (
        p_Atip_Id                  At_Individual_Plan.Atip_Id%TYPE,
        p_Atip_At                  At_Individual_Plan.Atip_At%TYPE,
        p_Atip_Nsa                 At_Individual_Plan.Atip_Nsa%TYPE,
        p_Atip_Place               At_Individual_Plan.Atip_Place%TYPE,
        p_Atip_Period              At_Individual_Plan.Atip_Period%TYPE,
        p_Atip_Qnt                 At_Individual_Plan.Atip_Qnt%TYPE,
        p_Atip_Cu                  At_Individual_Plan.Atip_Cu%TYPE,
        p_Atip_Resources           At_Individual_Plan.Atip_Resources%TYPE,
        p_Atip_Desc                At_Individual_Plan.Atip_Desc%TYPE,
        p_Atip_St                  At_Individual_Plan.Atip_St%TYPE,
        p_Atip_Exprections         At_Individual_Plan.Atip_Exprections%TYPE,
        p_Atip_Nst                 At_Individual_Plan.Atip_Nst%TYPE,
        p_Atip_Nsa_Det             At_Individual_Plan.Atip_Nsa_Det%TYPE,
        p_Atip_Term_Tp             At_Individual_Plan.Atip_Term_Tp%TYPE,
        p_Atip_Start_Dt            At_Individual_Plan.Atip_Start_Dt%TYPE,
        p_Atip_Stop_Dt             At_Individual_Plan.Atip_Stop_Dt%TYPE,
        p_Atip_Order               At_Individual_Plan.Atip_Order%TYPE,
        p_Atip_Nsa_Hand_Name       At_Individual_Plan.Atip_Nsa_Hand_Name%TYPE,
        p_New_Id               OUT At_Individual_Plan.Atip_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Atip_Id, -1) < 0
        THEN
            INSERT INTO At_Individual_Plan (Atip_Id,
                                            Atip_At,
                                            Atip_Nsa,
                                            Atip_Place,
                                            Atip_Period,
                                            Atip_Qnt,
                                            Atip_Cu,
                                            Atip_Resources,
                                            Atip_Desc,
                                            Atip_St,
                                            Atip_Exprections,
                                            Atip_Nst,
                                            Atip_Nsa_Det,
                                            Atip_Term_Tp,
                                            Atip_Start_Dt,
                                            Atip_Stop_Dt,
                                            History_Status,
                                            Atip_Order,
                                            Atip_Nsa_Hand_Name)
                 VALUES (0,
                         p_Atip_At,
                         p_Atip_Nsa,
                         p_Atip_Place,
                         p_Atip_Period,
                         p_Atip_Qnt,
                         p_Atip_Cu,
                         p_Atip_Resources,
                         p_Atip_Desc,
                         p_Atip_St,
                         p_Atip_Exprections,
                         p_Atip_Nst,
                         p_Atip_Nsa_Det,
                         p_Atip_Term_Tp,
                         p_Atip_Start_Dt,
                         p_Atip_Stop_Dt,
                         'A',
                         p_Atip_Order,
                         p_Atip_Nsa_Hand_Name)
              RETURNING Atip_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atip_Id;

            UPDATE At_Individual_Plan p
               SET p.Atip_Nsa = p_Atip_Nsa,
                   p.Atip_Place = p_Atip_Place,
                   p.Atip_Period = p_Atip_Period,
                   p.Atip_Qnt = p_Atip_Qnt,
                   p.Atip_Cu = p_Atip_Cu,
                   p.Atip_Resources = p_Atip_Resources,
                   p.Atip_Desc = p_Atip_Desc,
                   p.Atip_St = p_Atip_St,
                   p.Atip_Exprections = p_Atip_Exprections,
                   p.Atip_Nst = p_Atip_Nst,
                   p.Atip_Nsa_Det = p_Atip_Nsa_Det,
                   p.Atip_Term_Tp = p_Atip_Term_Tp,
                   p.Atip_Start_Dt = p_Atip_Start_Dt,
                   p.Atip_Stop_Dt = p_Atip_Stop_Dt,
                   p.Atip_Order = p_Atip_Order,
                   p.Atip_Nsa_Hand_Name = p_Atip_Nsa_Hand_Name
             WHERE p.Atip_Id = p_Atip_Id;
        END IF;
    END;

    PROCEDURE Save_Individual_Plans (
        p_At_Id              IN            NUMBER,
        p_Individual_Plans   IN OUT NOCOPY t_At_Individual_Plan)
    IS
    BEGIN
        IF p_Individual_Plans IS NULL
        THEN
            RETURN;
        END IF;

        Write_Audit ('Save_Individual_Plans');

        FOR i IN 1 .. p_Individual_Plans.COUNT
        LOOP
            Check_At_Integrity (
                p_At_Id         => p_At_Id,
                p_Table         => 'AT_INDIVIDUAL_PLAN',
                p_Id_Field      => 'ATIP_ID',
                p_At_Field      => 'ATIP_AT',
                p_Id_Val        => p_Individual_Plans (i).Atip_Id,
                p_Entity_Name   => 'Залучений спеціаліст');
            USS_NDI.TOOLS.Check_Dict_Value (
                p_Value   => p_Individual_Plans (i).Atip_Period,
                p_Dict    => 'v_ddn_atip_period');


            IF     p_Individual_Plans (i).Deleted = 1
               AND p_Individual_Plans (i).Atip_Id > 0
            THEN
                UPDATE At_Individual_Plan i
                   SET i.History_Status = 'H'
                 WHERE i.Atip_Id = p_Individual_Plans (i).Atip_Id;

                UPDATE At_Results
                   SET History_Status = 'H'
                 WHERE Atr_Atip = p_Individual_Plans (i).Atip_Id;
            ELSE
                Save_Individual_Plan (
                    p_Atip_Id              => p_Individual_Plans (i).Atip_Id,
                    p_Atip_At              => p_At_Id,
                    p_Atip_Nsa             => p_Individual_Plans (i).Atip_Nsa,
                    p_Atip_Place           => p_Individual_Plans (i).Atip_Place,
                    p_Atip_Period          => p_Individual_Plans (i).Atip_Period,
                    p_Atip_Qnt             => p_Individual_Plans (i).Atip_Qnt,
                    p_Atip_Cu              => p_Individual_Plans (i).Atip_Cu,
                    p_Atip_Resources       =>
                        p_Individual_Plans (i).Atip_Resources,
                    p_Atip_Desc            => p_Individual_Plans (i).Atip_Desc,
                    p_Atip_St              => p_Individual_Plans (i).Atip_St,
                    p_Atip_Exprections     =>
                        p_Individual_Plans (i).Atip_Exprections,
                    p_Atip_Nst             => p_Individual_Plans (i).Atip_Nst,
                    p_Atip_Nsa_Det         => p_Individual_Plans (i).Atip_Nsa_Det,
                    p_Atip_Term_Tp         => p_Individual_Plans (i).Atip_Term_Tp,
                    p_Atip_Start_Dt        => p_Individual_Plans (i).Atip_Start_Dt,
                    p_Atip_Stop_Dt         => p_Individual_Plans (i).Atip_Stop_Dt,
                    p_Atip_Order           => p_Individual_Plans (i).Atip_Order,
                    p_Atip_Nsa_Hand_Name   =>
                        p_Individual_Plans (i).Atip_Nsa_Hand_Name,
                    p_New_Id               => p_Individual_Plans (i).New_Id);
            END IF;
        END LOOP;
    END;

    PROCEDURE Get_Indivilual_Plan (p_At_Id   IN     NUMBER,
                                   p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT p.*,
                   t.Nst_Name      AS Atip_Nst_Name,
                   a.Nsa_Name      AS Atip_Nsa_Name,
                   d.Nsa_Name      AS Atip_Nsa_Det_Name,
                   Pr.Dic_Name     AS Atip_Period_Name
              FROM At_Individual_Plan  p
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON p.Atip_Nst = t.Nst_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Nst_Activities a
                       ON p.Atip_Nsa = a.Nsa_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Nst_Activities d
                       ON p.Atip_Nsa_Det = d.Nsa_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Atip_Period Pr
                       ON p.Atip_Period = Pr.Dic_Value
             WHERE p.Atip_At = p_At_Id AND p.History_Status = 'A';
    END;

    PROCEDURE Save_Right_Log (p_At_Id          IN NUMBER,
                              p_At_Right_Log   IN t_At_Right_Log,
                              p_Hs_Id          IN NUMBER)
    IS
    BEGIN
        FOR i IN 1 .. p_At_Right_Log.COUNT
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_RIGHT_LOG',
                                p_Id_Field      => 'ARL_ID',
                                p_At_Field      => 'ARL_AT',
                                p_Id_Val        => p_At_Right_Log (i).Arl_Id,
                                p_Entity_Name   => 'Правило перевірки');

            UPDATE At_Right_Log l
               SET l.Arl_Result = p_At_Right_Log (i).Arl_Result,
                   l.Arl_Hs_Rewrite = p_Hs_Id
             WHERE     l.Arl_Id = p_At_Right_Log (i).Arl_Id
                   AND NVL (l.Arl_Result, 'F') <>
                       NVL (p_At_Right_Log (i).Arl_Result, 'F');
        END LOOP;
    END;

    PROCEDURE Save_Reject_Info (
        p_At_Id            IN NUMBER,
        p_At_Reject_Info      Api$act.t_At_Reject_Info)
    IS
    BEGIN
        FOR i IN 1 .. p_At_Reject_Info.COUNT
        LOOP
            Check_At_Integrity (p_At_Id         => p_At_Id,
                                p_Table         => 'AT_REJECT_INFO',
                                p_Id_Field      => 'ARI_ID',
                                p_At_Field      => 'ARI_AT',
                                p_Id_Val        => p_At_Reject_Info (i).Ari_Id,
                                p_Entity_Name   => 'Причина відмови');

            IF     p_At_Reject_Info (i).Deleted = 1
               AND p_At_Reject_Info (i).Ari_Id > 0
            THEN
                DELETE FROM At_Reject_Info
                      WHERE Ari_Id = p_At_Reject_Info (i).Ari_Id;
            ELSE
                IF NVL (p_At_Reject_Info (i).Ari_Id, 0) <= 0
                THEN
                    INSERT INTO At_Reject_Info (Ari_Id,
                                                Ari_At,
                                                Ari_Nrr,
                                                Ari_Njr,
                                                Ari_Ats)
                         VALUES (0,
                                 p_At_Id        /*p_At_Reject_Info(i).Ari_At*/
                                        ,
                                 p_At_Reject_Info (i).Ari_Nrr,
                                 p_At_Reject_Info (i).Ari_Njr,
                                 p_At_Reject_Info (i).Ari_Ats);
                ELSE
                    UPDATE At_Reject_Info
                       SET Ari_Nrr = p_At_Reject_Info (i).Ari_Nrr,
                           Ari_Njr = p_At_Reject_Info (i).Ari_Njr
                     WHERE Ari_Id = p_At_Reject_Info (i).Ari_Id;
                END IF;
            END IF;
        END LOOP;

        Recalc_Pdsp_Ats_St (p_At_Id);
    END;


    --====================================================--
    PROCEDURE Save_Reject_Infos (p_At_Id IN NUMBER, p_Clob IN CLOB)
    IS
        l_Arr   t_At_Reject_Info;
    BEGIN
        TOOLS.validate_param (p_Clob);
        Write_Audit ('Save_Reject_Infos');

        EXECUTE IMMEDIATE Type2xmltable (Pkg,
                                         't_at_reject_info',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_Arr
            USING p_Clob;

        Save_Reject_Info (p_At_Id, l_Arr);
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ
    -----------------------------------------------------------
    PROCEDURE Save_Link (p_Atk_At        At_Links.Atk_At%TYPE,
                         p_Atk_Link_At   At_Links.Atk_Link_At%TYPE,
                         p_Atk_Tp        At_Links.Atk_Tp%TYPE)
    IS
        l_Akt_Id   NUMBER;
    BEGIN
        SELECT MAX (l.Atk_Id)
          INTO l_Akt_Id
          FROM At_Links l
         WHERE l.Atk_At = p_Atk_At AND l.Atk_Tp = p_Atk_Tp;

        IF l_Akt_Id IS NULL
        THEN
            INSERT INTO At_Links (Atk_Id,
                                  Atk_At,
                                  Atk_Link_At,
                                  Atk_Tp)
                 VALUES (0,
                         p_Atk_At,
                         p_Atk_Link_At,
                         p_Atk_Tp);
        ELSE
            UPDATE At_Links l
               SET l.Atk_Link_At = p_Atk_Link_At
             WHERE l.Atk_Id = l_Akt_Id AND l.Atk_Link_At <> p_Atk_Link_At;
        END IF;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ПОТОЧНОГО СТАНУ АКТУ
    -----------------------------------------------------------
    FUNCTION Get_At_St (p_At_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_At_St   VARCHAR2 (10);
    BEGIN
        SELECT a.At_St
          INTO l_At_St
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        RETURN l_At_St;
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРА ДОКУМЕНТА ВКАЗАНОГО ТИПУ В АКТІ
    -----------------------------------------------------------
    FUNCTION Get_Atd_Id (p_At_Id IN NUMBER, p_Atd_Ndt IN NUMBER)
        RETURN NUMBER
    IS
        l_Atd_Id   NUMBER;
    BEGIN
        SELECT MAX (d.Atd_Id)
          INTO l_Atd_Id
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Atd_Ndt
               AND d.History_Status = 'A';

        RETURN l_Atd_Id;
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРА АКТУ ДЛЯ ДОКУМЕНТА
    -----------------------------------------------------------
    FUNCTION Get_Atd_At (p_Atd_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Atd_At   NUMBER;
    BEGIN
        SELECT MAX (d.Atd_At)
          INTO l_Atd_At
          FROM At_Document d
         WHERE d.Atd_Id = p_Atd_Id;

        RETURN l_Atd_At;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ПІБу СПЕЦІАЛІСТА, ЯКИЙ СКЛАВ АКТ
    -----------------------------------------------------------
    FUNCTION Get_At_Spec_Name (p_At_Wu IN NUMBER, p_At_Cu IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR (300);
    BEGIN
        IF p_At_Cu IS NOT NULL
        THEN
            RETURN Ikis_Rbm.Tools.Getcupib (p_At_Cu);
        END IF;

        IF p_At_Wu IS NOT NULL
        THEN
            SELECT Wu_Pib
              INTO l_Result
              FROM Ikis_Sysweb.V$w_Users4hierarchy
             WHERE Wu_Id = p_At_Wu;

            RETURN l_Result;
        END IF;

        RETURN NULL;
    END;

    -----------------------------------------------------------
    --     ВИЗНАЧЕННЯ ПОСАДИ СПЕЦІАЛІСТА, ЯКИЙ СКЛАВ АКТ
    -----------------------------------------------------------
    FUNCTION Get_At_Spec_Position (p_At_Wu      IN NUMBER,
                                   p_At_Cu      IN NUMBER,
                                   p_At_Rnspm   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (1000);
    BEGIN
        IF p_At_Cu IS NOT NULL
        THEN
            --TODO:
            RETURN l_Result;
        END IF;

        IF p_At_Wu IS NOT NULL
        THEN
            --TODO:
            RETURN l_Result;
        END IF;

        RETURN NULL;
    END;

    -----------------------------------------------------------
    --     ВИЗНАЧЕННЯ ТИПУ ДОКУМЕНТА ДЛЯ ДРУК. ФОРМИ АКТУ
    -----------------------------------------------------------
    FUNCTION Define_Print_Form_Ndt (
        p_At_Id                IN     NUMBER,
        p_Build_Proc              OUT VARCHAR2,
        p_Raise_If_Undefined   IN     BOOLEAN DEFAULT TRUE)
        RETURN NUMBER
    IS
        l_Ndt_Id   NUMBER;
        l_Cnt      NUMBER;
    BEGIN
        SELECT MAX (c.Napc_Ndt), MAX (c.Napc_Form_Make_Prc), COUNT (*)
          INTO l_Ndt_Id, p_Build_Proc, l_Cnt
          FROM Act  a
               JOIN Uss_Ndi.v_Ndi_At_Print_Config c ON c.Napc_At_Tp = a.At_Tp
               /* LEFT JOIN At_Service s
                  ON s.Ats_At = p_At_Id
                 AND s.History_Status = 'A'*/
               -- 20240227 bogdan
               LEFT JOIN at_document d
                   ON (d.atd_at = a.at_id AND d.history_status = 'A')
               -- 20240528 bogdan: так як тепер можуть на одну послугу додавати більше одного запису сюди бо треба вказати більше 1 адреси надання послуги
               LEFT JOIN
               (  SELECT s.ats_nst
                    FROM At_Service s
                   WHERE s.Ats_At = p_At_Id AND s.History_Status = 'A'
                GROUP BY s.ats_nst) s
                   ON (s.Ats_Nst = c.Napc_Nst)
         WHERE     a.At_Id = p_At_Id
               AND (c.Napc_Nst IS NULL OR s.Ats_Nst = c.Napc_Nst)
               -- 20240227 bogdan: якщо по послузі визначено > 1 документа то без документу цей контроль завжди видає помилку, навіть якщо "обрав вручну"
               AND (d.atd_ndt IS NULL OR d.atd_ndt = c.Napc_Ndt);

        IF p_Raise_If_Undefined
        THEN
            IF l_Ndt_Id IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не визначено налаштування для друкованої форми');
            END IF;

            IF l_Cnt > 1
            THEN
                Raise_Application_Error (
                    -20000,
                    'Неможливо автоматично визначити тип друкованої форми. Потрібно обрати вручну');
            END IF;
        END IF;

        IF l_Cnt > 1
        THEN
            l_Ndt_Id := 0;
        END IF;

        RETURN l_Ndt_Id;
    END;

    FUNCTION Define_Print_Form_Ndt (
        p_At_Id                IN NUMBER,
        p_Raise_If_Undefined   IN BOOLEAN DEFAULT TRUE)
        RETURN NUMBER
    IS
        l_Build_Proc   VARCHAR2 (1000);
    BEGIN
        RETURN Define_Print_Form_Ndt (p_At_Id,
                                      l_Build_Proc,
                                      p_Raise_If_Undefined);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Form_Ndt    IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        SELECT Atd_Dh, File_Code
          INTO p_Atd_Dh, p_File_Code
          FROM (SELECT d.Atd_Dh,
                       f.File_Code,
                       NVL (a.dat_num, -1)                                       dat_num,
                       NVL (MAX (a.dat_num) OVER (PARTITION BY d.atd_id), -1)    max_dat_num
                  FROM At_Document  d
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON d.Atd_Dh = a.Dat_Dh
                       JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                 WHERE     d.Atd_At = p_At_Id
                       AND d.Atd_Ndt = p_Form_Ndt
                       AND d.History_Status = 'A')
         WHERE dat_num = max_dat_num;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --     (вже побудованої, з кодами підписів через кому)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Form_Ndt               IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2)
    IS
    BEGIN
        SELECT Atd_Dh,
               File_Code,
               (SELECT LISTAGG (Fs.File_Code, ',')
                           WITHIN GROUP (ORDER BY Ss.Dats_Id)
                  FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                       JOIN Uss_Doc.v_Files Fs
                           ON Ss.Dats_Sign_File = Fs.File_Id
                 WHERE Ss.Dats_Dat = Dat_Id)    AS Added_Signs
          INTO p_Atd_Dh, p_File_Code, p_File_Signs_Code_List
          FROM (SELECT d.Atd_Dh,
                       f.File_Code,
                       a.Dat_Id,
                       NVL (a.dat_num, -1)                                       dat_num,
                       NVL (MAX (a.dat_num) OVER (PARTITION BY d.atd_id), -1)    max_dat_num
                  FROM At_Document  d
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON d.Atd_Dh = a.Dat_Dh
                       JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                 WHERE     d.Atd_At = p_At_Id
                       AND d.Atd_Ndt = p_Form_Ndt
                       AND d.History_Status = 'A')
         WHERE dat_num = max_dat_num;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id             IN     NUMBER,
                             p_At_Prj_St         IN     VARCHAR2,
                             p_Form_Ndt          IN     NUMBER,
                             p_Form_Build_Proc   IN     VARCHAR2,
                             p_Doc_Cur              OUT SYS_REFCURSOR)
    IS
        l_Cu_Id            NUMBER;
        l_At_St            VARCHAR2 (10);
        l_Atd_Id           NUMBER;
        l_Doc_Id           NUMBER;
        l_Dh_Id            NUMBER;
        l_File_Code        VARCHAR2 (50);
        l_File_Hash        VARCHAR2 (50);
        l_File_Content     BLOB;
        l_atd_attach_src   VARCHAR2 (50);
    BEGIN
        SELECT a.At_St
          INTO l_At_St
          FROM Act a
         WHERE a.At_Id = p_At_Id
        FOR UPDATE;

        SELECT MAX (d.Atd_Id),
               MAX (d.Atd_Doc),
               MAX (d.Atd_Dh),
               MAX (atd_attach_src)
          INTO l_Atd_Id,
               l_Doc_Id,
               l_Dh_Id,
               l_atd_attach_src
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Form_Ndt
               AND d.History_Status = 'A';

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        IF l_Atd_Id IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => p_Form_Ndt,
                p_Doc_Actuality   => 'U',
                p_New_Id          => l_Doc_Id);

            Uss_Doc.Api$documents.Save_Doc_Hist (
                p_Dh_Id          => NULL,
                p_Dh_Doc         => l_Doc_Id,
                p_Dh_Sign_Alg    => NULL,
                p_Dh_Ndt         => p_Form_Ndt,
                p_Dh_Sign_File   => NULL,
                p_Dh_Actuality   => 'U',
                p_Dh_Dt          => SYSDATE,
                p_Dh_Wu          => NULL,
                p_Dh_Src         => 'CMES',
                p_Dh_Cu          => l_Cu_Id,
                p_New_Id         => l_Dh_Id);



            INSERT INTO At_Document (Atd_Id,
                                     Atd_At,
                                     Atd_Ndt,
                                     Atd_Doc,
                                     Atd_Dh,
                                     History_Status,
                                     atd_attach_src)
                 VALUES (0,
                         p_At_Id,
                         p_Form_Ndt,
                         l_Doc_Id,
                         l_Dh_Id,
                         'A',
                         'AUTO')
              RETURNING Atd_Id
                   INTO l_Atd_Id;

            l_atd_attach_src := 'AUTO';
        ELSE
            BEGIN
                SELECT File_Code, File_Hash
                  INTO l_File_Code, l_File_Hash
                  FROM (SELECT f.File_Code,
                               f.File_Hash,
                               NVL (a.dat_num, -1)                  dat_num,
                               NVL (MAX (a.dat_num) OVER (), -1)    max_dat_num
                          FROM Uss_Doc.v_Doc_Attachments  a
                               JOIN Uss_Doc.v_Files f
                                   ON a.Dat_File = f.File_Id
                         WHERE a.Dat_Dh = l_Dh_Id)
                 WHERE dat_Num = max_dat_num;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        END IF;

        IF     l_At_St = p_At_Prj_St
           AND (   l_atd_attach_src IN ('AUTO', 'TABLET')
                OR l_atd_attach_src IS NULL)
        THEN
            --Виконуємо побудову друк. форми акту тільки якщо він в стані проекту
            --Для всіх інших станів передбачається, що друковану форму вже ствоерно
            EXECUTE IMMEDIATE   'select '
                             || p_Form_Build_Proc
                             || '(:p_At_Id) from dual'
                INTO l_File_Content
                USING IN p_At_Id;
        END IF;

        OPEN p_Doc_Cur FOR
            SELECT l_Atd_Id             AS Atd_Id,
                   p_Form_Ndt           AS Atd_Ndt,
                   l_Doc_Id             AS Atd_Doc,
                   l_Dh_Id              AS Atd_Dh,
                   l_File_Code          AS File_Code,
                   l_File_Hash          AS File_Hash,
                   l_File_Content       AS File_Content,
                   l_atd_attach_src     AS Atd_Attach_Src
              FROM DUAL;
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ІДЕНТИФІКТОРІВ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id     IN     NUMBER,
                            p_Atd_Ndt   IN     NUMBER,
                            p_Doc          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Doc FOR
            SELECT d.Atd_Id,
                   d.Atd_At,
                   d.Atd_Ndt,
                   d.Atd_Ats,
                   d.Atd_Doc,
                   d.Atd_Dh,
                   d.History_Status,
                   f.File_Code,
                   f.File_Hash,
                   f.File_Name
              FROM At_Document  d
                   JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
             WHERE     d.Atd_At = p_At_Id
                   AND d.Atd_Ndt = p_Atd_Ndt
                   AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ДОКУМЕНТУ ВКЛАДЕННЯ ПРИ ПІДПИСІ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Sign_Info_Doc (p_At_Id    IN     NUMBER,
                                 p_Atp_Id   IN     NUMBER,
                                 p_Atd_Id      OUT NUMBER,
                                 p_Doc_Id      OUT NUMBER)
    IS
    BEGIN
        SELECT MAX (d.atd_id), MAX (d.atd_doc)
          INTO p_Atd_Id, p_Doc_Id
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = 1017
               AND d.atd_atp = p_Atp_Id
               AND d.History_Status = 'A';

        IF p_Atd_Id IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => 1017,
                p_Doc_Actuality   => 'U',
                p_New_Id          => p_Doc_Id);

            INSERT INTO At_Document (Atd_Id,
                                     Atd_At,
                                     Atd_Atp,
                                     Atd_Ndt,
                                     Atd_Doc,
                                     History_Status)
                 VALUES (0,
                         p_At_Id,
                         p_Atp_Id,
                         1017,
                         p_Doc_Id,
                         'A')
              RETURNING Atd_Id
                   INTO p_Atd_Id;
        END IF;
    END;

    ------------------------------------------------------------------------
    --         ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    ------------------------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id     IN     NUMBER,
                                p_Atd_Ndt   IN     NUMBER,
                                p_Doc_Src      OUT VARCHAR2)
    IS
    BEGIN
        SELECT MAX (d.atd_attach_src)
          INTO p_Doc_Src
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Atd_Ndt
               AND d.History_Status = 'A';
    END;

    FUNCTION Get_Form_Doc (p_At_Id IN NUMBER, p_Atd_Ndt IN NUMBER)
        RETURN NUMBER
    IS
        l_Atd_Id   NUMBER;
    BEGIN
        SELECT MAX (d.Atd_Id)
          INTO l_Atd_Id
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Atd_Ndt
               AND d.History_Status = 'A';

        RETURN l_Atd_Id;
    END;

    -----------------------------------------------------------
    --         БЛОКУВАННЯ АКТА В РЕЖИМІ NOWAIT
    -----------------------------------------------------------
    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER)
    IS
        l_Atd_Id   NUMBER;
    BEGIN
            SELECT d.Atd_Id
              INTO l_Atd_Id
              FROM At_Document d
             WHERE d.Atd_Id = p_Atd_Id
        FOR UPDATE NOWAIT;
    END;

    --------------------------------------------------------------
    --   Збереження документів
    --------------------------------------------------------------
    PROCEDURE Save_Documents (
        p_At_Id          IN            NUMBER,
        p_At_Documents   IN OUT NOCOPY Api$act.t_At_Documents)
    IS
    BEGIN
        FOR i IN 1 .. p_At_Documents.COUNT
        LOOP
            DECLARE
                l_Attrs    Api$act.t_At_Document_Attrs;
                l_Ndt_Id   NUMBER;
            BEGIN
                Api$act.Check_At_Integrity (
                    p_At_Id         => p_At_Id,
                    p_Table         => 'AT_DOCUMENT',
                    p_Id_Field      => 'ATD_ID',
                    p_At_Field      => 'ATD_AT',
                    p_Id_Val        => p_At_Documents (i).Atd_Id,
                    p_Entity_Name   => 'Документ');

                IF     p_At_Documents (i).Deleted = 1
                   AND p_At_Documents (i).Atd_Id > 0
                THEN
                    UPDATE At_Document d
                       SET d.History_Status = 'H'
                     WHERE d.Atd_Id = p_At_Documents (i).Atd_Id;
                ELSIF p_At_Documents (i).Atd_Id > 0
                THEN
                    UPDATE At_Document d
                       SET d.atd_ndt = p_At_Documents (i).Atd_Ndt,
                           d.atd_dh = p_At_Documents (i).Atd_Dh,
                           d.atd_doc = p_At_Documents (i).Atd_Doc
                     --d.atd_atp = p_At_Documents(i).Atd_Atp
                     WHERE d.Atd_Id = p_At_Documents (i).Atd_Id;

                    p_At_Documents (i).New_Id := p_At_Documents (i).Atd_Id;
                ELSE
                    INSERT INTO At_Document (Atd_Id,
                                             Atd_At,
                                             Atd_Ndt,
                                             Atd_Ats,
                                             Atd_Doc,
                                             Atd_Dh,
                                             History_Status)
                         VALUES (0,
                                 p_At_Id,
                                 p_At_Documents (i).Atd_Ndt,
                                 p_At_Documents (i).Atd_Ats,
                                 p_At_Documents (i).Atd_Doc,
                                 p_At_Documents (i).Atd_Dh,
                                 'A')
                      RETURNING Atd_Id
                           INTO p_At_Documents (i).New_Id;
                END IF;

                IF NVL (p_At_Documents (i).Atd_Id, -1) > 0
                THEN
                    SELECT d.Atd_Ndt
                      INTO l_Ndt_Id
                      FROM At_Document d
                     WHERE d.Atd_Id = p_At_Documents (i).Atd_Id;

                    IF l_Ndt_Id <> p_At_Documents (i).Atd_Ndt
                    THEN
                        UPDATE At_Document_Attr a
                           SET a.History_Status = 'H'
                         WHERE a.Atda_Atd = p_At_Documents (i).Atd_Id;
                    END IF;
                END IF;

                IF p_At_Documents (i).Attributes IS NOT NULL
                THEN
                    l_Attrs :=
                        Api$act.Parse_Attributes (
                            p_At_Documents (i).Attributes);
                    Api$act.Save_Attributes (
                        p_At_Id    => p_At_Id,
                        p_Atd_Id   => p_At_Documents (i).New_Id,
                        p_Attrs    => l_Attrs);
                END IF;
            END;
        END LOOP;
    END;

    PROCEDURE Save_Documents (p_At_Id IN NUMBER, p_At_Documents IN CLOB)
    IS
        l_At_Documents   Api$act.t_At_Documents;
    BEGIN
        IF p_At_Documents IS NULL
        THEN
            RETURN;
        END IF;

        --Парсинг документів
        l_At_Documents := Api$act.Parse_Documents (p_At_Documents);

        IF l_At_Documents.COUNT > 0
        THEN
            --Збереження документів
            Save_Documents (p_At_Id, l_At_Documents);
        END IF;
    END;

    -----------------------------------------------------------
    --        ОТРИМАННЯ ДОКУМЕНТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Documents (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.*,
                   t.Ndt_Name_Short                                 AS Atd_Ndt_Name,
                   api$act.Doc_Exists_Sign (d.atd_at, d.atd_ndt)    AS Doc_Exists_Sign
              FROM At_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Atd_Ndt = t.Ndt_Id
             WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --         ОТРИМАННЯ ВКЛАДЕНЬ ДОКУМЕНТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Doc_Files (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.Atd_Id,
                   d.Atd_Doc                          AS Doc_Id,
                   d.Atd_Dh                           AS Dh_Id,
                   f.File_Code,
                   f.File_Name,
                   f.File_Mime_Type,
                   f.File_Size,
                   f.File_Hash,
                   f.File_Create_Dt,
                   f.File_Description,
                   s.File_Code                        AS File_Sign_Code,
                   s.File_Hash                        AS File_Sign_Hash,
                   (SELECT LISTAGG (Fs.File_Code, ',')
                               WITHIN GROUP (ORDER BY Ss.Dats_Id)
                      FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                           JOIN Uss_Doc.v_Files Fs
                               ON Ss.Dats_Sign_File = Fs.File_Id
                     WHERE Ss.Dats_Dat = a.Dat_Id)    AS File_Signs,
                   a.Dat_Num
              FROM At_Document  d
                   JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                   LEFT JOIN Uss_Doc.v_Files s ON a.Dat_Sign_File = s.File_Id
             WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A';
    END;

    PROCEDURE Get_Signed_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT *
              FROM (SELECT d.Atd_Id,
                           d.Atd_Doc                          AS Doc_Id,
                           d.Atd_Dh                           AS Dh_Id,
                           f.File_Code,
                           f.File_Name,
                           f.File_Mime_Type,
                           f.File_Size,
                           f.File_Hash,
                           f.File_Create_Dt,
                           f.File_Description,
                           s.File_Code                        AS File_Sign_Code,
                           s.File_Hash                        AS File_Sign_Hash,
                           (SELECT LISTAGG (Fs.File_Code, ',')
                                   WITHIN GROUP (ORDER BY
                                                     Ss.Dats_Id)
                              FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                                   JOIN Uss_Doc.v_Files Fs
                                       ON Ss.Dats_Sign_File =
                                          Fs.File_Id
                             WHERE Ss.Dats_Dat = a.Dat_Id)    AS File_Signs,
                           a.Dat_Num
                      FROM At_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Atd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                           LEFT JOIN Uss_Doc.v_Files s
                               ON a.Dat_Sign_File = s.File_Id
                     WHERE     d.Atd_At = p_At_Id
                           AND d.History_Status = 'A'
                           --#92377
                           AND EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND Sg.Ati_Is_Signed = 'T')
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND NVL (Sg.Ati_Is_Signed, 'F') =
                                               'F'))
             --#93366
             WHERE File_Signs IS NOT NULL OR File_Sign_Code IS NOT NULL;
    END;


    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ НА ЗРІЗ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Dh (p_Atd_Id           IN NUMBER,
                          p_Atd_Dh           IN NUMBER,
                          p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO')
    IS
    BEGIN
        UPDATE At_Document d
           SET d.Atd_Dh = p_Atd_Dh, d.atd_attach_src = p_Atd_Attach_Src
         WHERE d.Atd_Id = p_Atd_Id;
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ СОРСУ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Source (p_Atd_Id           IN NUMBER,
                              p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO')
    IS
    BEGIN
        UPDATE At_Document d
           SET d.atd_attach_src = p_Atd_Attach_Src
         WHERE d.Atd_Id = p_Atd_Id;
    END;

    -----------------------------------------------------------
    --         ДОДАВАННЯ АТРИБУТУ ДО КОЛЕКЦІЇ
    -----------------------------------------------------------
    PROCEDURE Add_Attr (p_Attrs     IN OUT NOCOPY t_At_Document_Attrs,
                        p_Nda_Id    IN            NUMBER,
                        p_Val_Str   IN            VARCHAR2 DEFAULT NULL,
                        p_Val_Dt    IN            DATE DEFAULT NULL,
                        p_Val_Sum   IN            NUMBER DEFAULT NULL,
                        p_Val_Int   IN            NUMBER DEFAULT NULL,
                        p_Val_Id    IN            NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF p_Nda_Id IS NULL
        THEN
            RETURN;
        END IF;

        IF p_Attrs IS NULL
        THEN
            p_Attrs := t_At_Document_Attrs ();
        END IF;

        p_Attrs.EXTEND ();
        p_Attrs (p_Attrs.COUNT).Atda_Nda := p_Nda_Id;

        p_Attrs (p_Attrs.COUNT).Atda_Val_String := p_Val_Str;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Dt := p_Val_Dt;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Sum := p_Val_Sum;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Int := p_Val_Int;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Id := p_Val_Id;
    END;

    FUNCTION Get_Field_Datatype (p_Field_Name IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (250);
    BEGIN
        SELECT DATA_TYPE
          INTO l_Res
          FROM User_Tab_Columns tc
         WHERE     tc.table_name = 'ACT'
               AND tc.column_name = UPPER (p_Field_Name);

        RETURN l_Res;
    END;

    FUNCTION Get_Dt_Field_Value (p_At_Id IN NUMBER, p_Field_Name IN VARCHAR2)
        RETURN DATE
    IS
        l_Res   DATE;
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || p_Field_Name
                         || ' FROM act WHERE at_id = :p_At_Id'
            INTO l_Res
            USING p_At_Id;

        RETURN l_Res;
    END;

    FUNCTION Get_Num_Field_Value (p_At_Id        IN NUMBER,
                                  p_Field_Name   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || p_Field_Name
                         || ' FROM act WHERE at_id = :p_At_Id'
            INTO l_Res
            USING p_At_Id;

        RETURN l_Res;
    END;

    FUNCTION Get_Char_Field_Value (p_At_Id        IN NUMBER,
                                   p_Field_Name   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (500);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || p_Field_Name
                         || ' FROM act WHERE at_id = :p_At_Id'
            INTO l_Res
            USING p_At_Id;

        RETURN l_Res;
    END;

    PROCEDURE Make_Attr_Collection (
        p_At_Id     IN            NUMBER,
        p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
        p_Attrs     IN OUT NOCOPY Api$act.t_At_Document_Attrs)
    IS
        l_Val_Dt     DATE;
        l_Val_Num    NUMBER;
        l_Val_Char   VARCHAR2 (500);
        l_DataType   VARCHAR2 (500);
        l_Idx        VARCHAR2 (255);
    BEGIN
        l_Idx := p_Nda_Map.FIRST;

        WHILE l_Idx IS NOT NULL
        LOOP
            l_DataType := Get_Field_Datatype (p_Nda_Map (l_Idx));

            l_Val_Dt := NULL;
            l_Val_Num := NULL;
            l_Val_Char := NULL;

            IF l_DataType = 'DATE'
            THEN
                l_Val_Dt := Get_Dt_Field_Value (p_At_Id, p_Nda_Map (l_Idx));
            ELSIF l_DataType = 'VARCHAR2'
            THEN
                l_Val_Char :=
                    Get_Char_Field_Value (p_At_Id, p_Nda_Map (l_Idx));
            ELSE
                l_Val_Num := Get_Num_Field_Value (p_At_Id, p_Nda_Map (l_Idx));
            END IF;

            Add_Attr (p_Attrs     => p_Attrs,
                      p_Nda_Id    => l_Idx,
                      p_Val_Str   => l_Val_Char,
                      p_Val_Dt    => l_Val_Dt,
                      p_Val_Sum   => l_Val_Num);

            l_Idx := p_Nda_Map.NEXT (l_Idx);
        END LOOP;
    END;

    FUNCTION Get_Attr_Nda (p_Field     IN            VARCHAR2,
                           p_Nda_Map   IN OUT NOCOPY t_Nda_Map)
        RETURN NUMBER
    IS
        l_Idx   VARCHAR2 (255);
    BEGIN
        l_Idx := p_Nda_Map.FIRST;

        WHILE l_Idx IS NOT NULL
        LOOP
            IF UPPER (p_Nda_Map (l_Idx)) = UPPER (p_Field)
            THEN
                RETURN l_Idx;
            END IF;

            l_Idx := p_Nda_Map.NEXT (l_Idx);
        END LOOP;

        RETURN NULL;
    END;

    PROCEDURE Save_Attributes (
        p_At_Id     IN            NUMBER,
        p_Atd_Id    IN            NUMBER,
        p_Attrs     IN OUT NOCOPY Api$act.t_At_Document_Attrs,
        p_Nda_Map   IN OUT NOCOPY t_Nda_Map)
    IS
    BEGIN
        FOR i IN 1 .. p_Attrs.COUNT
        LOOP
            p_Attrs (i).Atda_Nda :=
                Get_Attr_Nda (p_Attrs (i).Field, p_Nda_Map);
        END LOOP;

        Api$act.Save_Attributes (p_At_Id    => p_At_Id,
                                 p_Atd_Id   => p_Atd_Id,
                                 p_Attrs    => p_Attrs);
    END;

    -----------------------------------------------------------
    --         ДОДАВАННЯ АТРИБУТІВ ДОКУМЕНТУ
    -----------------------------------------------------------
    PROCEDURE Save_Attributes (p_At_Id    IN            NUMBER,
                               p_Atd_Id   IN            NUMBER,
                               p_Attrs    IN OUT NOCOPY t_At_Document_Attrs)
    IS
    BEGIN
        FOR Rec
            IN (SELECT a.*, Aa.Atda_Id, n.Nda_Can_Edit
                  FROM TABLE (p_Attrs)  a
                       JOIN Uss_Ndi.v_Ndi_Document_Attr n
                           ON a.Atda_Nda = n.Nda_Id
                       LEFT JOIN At_Document_Attr Aa
                           ON     Aa.Atda_Atd = p_Atd_Id
                              AND a.Atda_Nda = Aa.Atda_Nda
                              AND Aa.History_Status = 'A')
        LOOP
            IF Rec.Atda_Id IS NOT NULL
            THEN
                IF Rec.Nda_Can_Edit = 'F'
                THEN
                    CONTINUE;
                END IF;

                UPDATE At_Document_Attr a
                   SET Atda_Val_Int = Rec.Atda_Val_Int,
                       Atda_Val_Sum = Rec.Atda_Val_Sum,
                       Atda_Val_Id = Rec.Atda_Val_Id,
                       Atda_Val_Dt = Rec.Atda_Val_Dt,
                       Atda_Val_String = Rec.Atda_Val_String
                 WHERE a.Atda_Id = Rec.Atda_Id;
            ELSE
                INSERT INTO At_Document_Attr (Atda_Id,
                                              Atda_Atd,
                                              Atda_At,
                                              Atda_Nda,
                                              Atda_Val_Int,
                                              Atda_Val_Sum,
                                              Atda_Val_Id,
                                              Atda_Val_Dt,
                                              Atda_Val_String,
                                              History_Status)
                     VALUES (0,
                             p_Atd_Id,
                             p_At_Id,
                             Rec.Atda_Nda,
                             Rec.Atda_Val_Int,
                             Rec.Atda_Val_Sum,
                             Rec.Atda_Val_Id,
                             Rec.Atda_Val_Dt,
                             Rec.Atda_Val_String,
                             'A');
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Attribute (p_Atda_Id           IN NUMBER,
                              p_Atda_At           IN NUMBER,
                              p_Atda_Atd          IN NUMBER,
                              p_Atda_Nda          IN NUMBER,
                              p_Atda_Val_Int      IN NUMBER,
                              p_Atda_Val_Sum      IN NUMBER,
                              p_Atda_Val_Id       IN NUMBER,
                              p_Atda_Val_Dt       IN DATE,
                              p_Atda_Val_String   IN VARCHAR2)
    IS
    BEGIN
        IF NVL (p_Atda_Id, 0) != 0
        THEN
            UPDATE At_Document_Attr a
               SET Atda_Val_Int = p_Atda_Val_Int,
                   Atda_Val_Sum = p_Atda_Val_Sum,
                   Atda_Val_Id = p_Atda_Val_Id,
                   Atda_Val_Dt = p_Atda_Val_Dt,
                   Atda_Val_String = p_Atda_Val_String
             WHERE a.Atda_Id = p_Atda_Id;
        ELSE
            INSERT INTO At_Document_Attr (Atda_Id,
                                          Atda_Atd,
                                          Atda_At,
                                          Atda_Nda,
                                          Atda_Val_Int,
                                          Atda_Val_Sum,
                                          Atda_Val_Id,
                                          Atda_Val_Dt,
                                          Atda_Val_String,
                                          History_Status)
                 VALUES (0,
                         p_Atda_Atd,
                         p_Atda_At,
                         p_Atda_Nda,
                         p_Atda_Val_Int,
                         p_Atda_Val_Sum,
                         p_Atda_Val_Id,
                         p_Atda_Val_Dt,
                         p_Atda_Val_String,
                         'A');
        END IF;
    END;

    PROCEDURE Modify_Attribute (p_Atda_Id           IN NUMBER,
                                p_Atda_At           IN NUMBER,
                                p_Atda_Atd          IN NUMBER,
                                p_Atda_Nda          IN NUMBER,
                                p_Atda_Val_Int      IN NUMBER,
                                p_Atda_Val_Sum      IN NUMBER,
                                p_Atda_Val_Id       IN NUMBER,
                                p_Atda_Val_Dt       IN DATE,
                                p_Atda_Val_String   IN VARCHAR2)
    IS
        l_Atda_Id   NUMBER;
    BEGIN
        IF NVL (l_Atda_Id, 0) = 0
        THEN
            SELECT MAX (Atda_Id)
              INTO l_Atda_Id
              FROM At_Document_Attr atda
             WHERE     atda.atda_at = p_Atda_At
                   AND atda.atda_nda = p_Atda_Nda
                   AND (p_Atda_Atd IS NULL OR atda.atda_atd = p_Atda_Atd);
        END IF;

        Save_Attribute (l_Atda_Id,
                        p_Atda_At,
                        p_Atda_Atd,
                        p_Atda_Nda,
                        p_Atda_Val_Int,
                        p_Atda_Val_Sum,
                        p_Atda_Val_Id,
                        p_Atda_Val_Dt,
                        p_Atda_Val_String);
    END;

    FUNCTION Get_Attr_Field (p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        IF g_Nda_Map.EXISTS (p_Nda_Id)
        THEN
            RETURN g_Nda_Map (p_Nda_Id);
        END IF;

        RETURN NULL;
    END;

    PROCEDURE Get_Attributes (p_At_Id     IN            NUMBER,
                              p_Atd_Ndt   IN            NUMBER,
                              p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
                              p_Res          OUT        SYS_REFCURSOR)
    IS
    BEGIN
        g_Nda_Map := p_Nda_Map;

        OPEN p_Res FOR
            SELECT a.Atda_At,
                   a.Atda_Nda,
                   a.Atda_Val_Int,
                   a.Atda_Val_Sum,
                   a.Atda_Val_Id,
                   a.Atda_Val_Dt,
                   a.Atda_Val_String,
                   Get_Attr_Field (a.Atda_Nda)     AS Field
              FROM At_Document  d
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A'
             WHERE     d.Atd_At = p_At_Id
                   AND d.Atd_Ndt = p_Atd_Ndt
                   AND d.History_Status = 'A';
    END;

    PROCEDURE Get_Attributes (p_Atd_Ndt   IN            NUMBER,
                              p_Nda_Map   IN OUT NOCOPY t_Nda_Map,
                              p_Res          OUT        SYS_REFCURSOR)
    IS
    BEGIN
        g_Nda_Map := p_Nda_Map;

        OPEN p_Res FOR
            SELECT a.Atda_At,
                   a.Atda_Nda,
                   a.Atda_Val_Int,
                   a.Atda_Val_Sum,
                   a.Atda_Val_Id,
                   a.Atda_Val_Dt,
                   a.Atda_Val_String,
                   Get_Attr_Field (a.Atda_Nda)     AS Field
              FROM Tmp_Work_Ids  t
                   JOIN At_Document d
                       ON     t.x_Id = d.Atd_At
                          AND d.Atd_Ndt = p_Atd_Ndt
                          AND d.History_Status = 'A'
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A';
    END;

    PROCEDURE Get_Attributes (p_Atd_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document_Attr  a
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE a.Atda_Atd = p_Atd_Id AND a.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --        ОТРИМАННЯ АТРИБУТІВ ДОКУМЕНТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Doc_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document  d
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A'
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A';
    END;

    FUNCTION Get_Attr_Val_Str (p_Atd_Id    IN            NUMBER,
                               p_Field     IN            VARCHAR2,
                               p_Nda_Map   IN OUT NOCOPY t_Nda_Map)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
        l_Nda_Id   NUMBER;
    BEGIN
        l_Nda_Id := Get_Attr_Nda (p_Field, p_Nda_Map);

        SELECT MAX (a.Atda_Val_String)
          INTO l_Result
          FROM At_Document_Attr a
         WHERE     a.Atda_Atd = p_Atd_Id
               AND a.Atda_Nda = l_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_Field (p_At_Id     IN NUMBER,
                                 p_Field     IN VARCHAR2,
                                 p_Nda_Map   IN t_Nda_Map)
        RETURN VARCHAR2
    IS
        l_Nda_Map   t_Nda_Map := p_Nda_Map;
        l_Result    VARCHAR2 (4000);
        l_Nda_Id    NUMBER;
    BEGIN
        l_Nda_Id := Get_Attr_Nda (p_Field, l_Nda_Map);

        SELECT MAX (a.Atda_Val_String)
          INTO l_Result
          FROM At_Document_Attr a
         WHERE     a.Atda_At = p_At_Id
               AND a.Atda_Nda = l_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_Str (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Atda_Val_String)
          INTO l_Result
          FROM At_Document_Attr a
         WHERE     a.Atda_At = p_At_Id
               AND a.Atda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_Dt (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.Atda_Val_dt)
          INTO l_Result
          FROM At_Document_Attr a
         WHERE     a.Atda_At = p_At_Id
               AND a.Atda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Section_Attr_Val_Str (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.atef_feature)
          INTO l_Result
          FROM at_section_feature a
         WHERE a.atef_At = p_At_Id AND a.atef_Nda = p_Nda_Id;

        RETURN l_Result;
    END;

    PROCEDURE Raise_Unauthorized
    IS
    BEGIN
        Raise_Application_Error (-20000, 'unauthorized');
    END;


    PROCEDURE Save_Features (
        p_Atf_Id           IN     At_Features.Atf_Id%TYPE,
        p_Atf_At           IN     At_Features.Atf_At%TYPE,
        p_Atf_Nft          IN     At_Features.Atf_Nft%TYPE,
        p_Atf_Val_Int      IN     At_Features.Atf_Val_Int%TYPE,
        p_Atf_Val_Sum      IN     At_Features.Atf_Val_Sum%TYPE,
        p_Atf_Val_Id       IN     At_Features.Atf_Val_Id%TYPE,
        p_Atf_Val_Dt       IN     At_Features.Atf_Val_Dt%TYPE,
        p_Atf_Val_String   IN     At_Features.Atf_Val_String%TYPE,
        p_Atf_Atp          IN     At_Features.Atf_Atp%TYPE,
        p_New_Id              OUT At_Features.Atf_Id%TYPE)
    IS
        l_Tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.Nft_View)
          INTO l_Tp
          FROM Uss_Ndi.v_Ndi_Pd_Feature_Type t
         WHERE t.Nft_Id = p_Atf_Nft;

        --IF p_atf_nft IS NOT NULL AND p_atf_nft!= 9 THEN
        IF l_Tp IS NULL OR l_Tp != 'SS'
        THEN
            RETURN;
        END IF;

        IF p_Atf_Id IS NULL OR p_Atf_Id < 0
        THEN
            INSERT INTO At_Features (Atf_At,
                                     Atf_Nft,
                                     Atf_Val_Int,
                                     Atf_Val_Sum,
                                     Atf_Val_Id,
                                     Atf_Val_Dt,
                                     Atf_Val_String,
                                     Atf_Atp)
                 VALUES (p_Atf_At,
                         p_Atf_Nft,
                         p_Atf_Val_Int,
                         p_Atf_Val_Sum,
                         p_Atf_Val_Id,
                         p_Atf_Val_Dt,
                         p_Atf_Val_String,
                         p_Atf_Atp)
              RETURNING Atf_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Atf_Id;

            UPDATE At_Features
               SET Atf_At = p_Atf_At,
                   Atf_Nft = p_Atf_Nft,
                   Atf_Val_Int = p_Atf_Val_Int,
                   Atf_Val_Sum = p_Atf_Val_Sum,
                   Atf_Val_Id = p_Atf_Val_Id,
                   Atf_Val_Dt = p_Atf_Val_Dt,
                   Atf_Val_String = p_Atf_Val_String,
                   Atf_Atp = p_Atf_Atp
             WHERE Atf_Id = p_Atf_Id;
        END IF;
    END;

    PROCEDURE Delete_Features (p_Atf_Id IN At_Features.Atf_Id%TYPE)
    IS
    BEGIN
        DELETE FROM At_Features s
              WHERE Atf_Id = p_Atf_Id AND NVL (Atf_Nft, -1) = 9;
    END;

    /* PROCEDURE Can_Sign(p_Atd_Id IN NUMBER) IS
    BEGIN
      SELECT FROM At_Document d
        JOIN Act a
          ON d.Atd_At = a.At_Id

       WHERE d.Atd_Id = p_Atd_Id;
    END;*/

    FUNCTION Is_All_Signed (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Unsigned_Cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Unsigned_Cnt
          FROM At_Signers s
         WHERE     s.Ati_At = p_At_Id
               AND s.History_Status = 'A'
               AND s.Ati_Tp = p_Ati_Tp
               AND s.Ati_Is_Signed = 'F';

        RETURN l_Unsigned_Cnt = 0;
    END;

    PROCEDURE Can_Add_Doc (p_At_Id    IN NUMBER,
                           p_Ati_Tp   IN VARCHAR2,
                           p_Ndt_Id   IN NUMBER)
    IS
        l_Can_Add    NUMBER;
        l_Ndt_Name   VARCHAR2 (500);
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Can_Add
          FROM Act  a
               JOIN Uss_Ndi.v_Ndi_At_Lc_Config c
                   ON     a.At_Tp = c.Nalc_At_Tp
                      AND a.At_St = c.Nalc_At_From_St
                      AND c.Nalc_User_Tp = p_Ati_Tp
                      AND c.Nalc_Ndt = p_Ndt_Id
         WHERE a.At_Id = p_At_Id;

        IF l_Can_Add <> 1
        THEN
            SELECT t.Ndt_Name
              INTO l_Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = p_Ndt_Id;

            Raise_Application_Error (
                -20000,
                   'Додавання документу "'
                || l_Ndt_Name
                || '" на поточному етапі неможливо');
        END IF;
    END;

    PROCEDURE Can_Sign (p_At_Id    IN NUMBER,
                        p_Atd_Id   IN NUMBER,
                        p_Ati_Tp   IN VARCHAR2)
    IS
        l_Can_Sign   VARCHAR2 (4000);
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Can_Sign
          FROM Act  a
               JOIN Uss_Ndi.v_Ndi_At_Lc_Config c
                   ON     a.At_Tp = c.Nalc_At_Tp
                      AND a.At_St = c.Nalc_At_From_St
                      AND c.Nalc_User_Tp = p_Ati_Tp
               JOIN At_Document d
                   ON d.Atd_Id = p_Atd_Id AND c.Nalc_Ndt = d.Atd_Ndt
         WHERE a.At_Id = p_At_Id;

        IF l_Can_Sign <> 1
        THEN
            Raise_Application_Error (-20000, 'Підписання не потребується');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗМІНА СТАНУ АКТУ
    -----------------------------------------------------------
    PROCEDURE Set_At_St (p_At_Id               IN NUMBER,
                         p_At_St_Old           IN VARCHAR2,
                         p_At_St_New           IN VARCHAR2,
                         p_Log_Msg             IN VARCHAR2,
                         p_Wrong_St_Msg        IN VARCHAR2,
                         p_At_Action_Stop_Dt   IN DATE DEFAULT NULL)
    IS
    BEGIN
        UPDATE Act a
           SET a.At_St = p_At_St_New,
               a.At_Action_Stop_Dt =
                   NVL (p_At_Action_Stop_Dt, a.At_Action_Stop_Dt)
         WHERE a.At_Id = p_At_Id AND a.At_St = p_At_St_Old;

        IF SQL%ROWCOUNT = 0
        THEN
            Raise_Application_Error (-20000, p_Wrong_St_Msg);
        END IF;

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes (),
                              p_Atl_St        => p_At_St_New,
                              p_Atl_Message   => p_Log_Msg,
                              p_Atl_St_Old    => NULL);
    END;



    -----------------------------------------------------------
    -- ПЕРЕВІРКА НАЯВНОСТІ ПІДПИСАНТА
    -----------------------------------------------------------
    FUNCTION Signer_Exists (p_Ati_At   IN NUMBER,
                            p_Ati_Sc   IN NUMBER,
                            p_Ati_Tp   IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Exists
          FROM At_Signers s
         WHERE     s.Ati_At = p_Ati_At
               AND s.Ati_Sc = p_Ati_Sc
               AND s.History_Status = 'A'
               AND s.Ati_Tp = p_Ati_Tp;

        RETURN l_Exists = 1;
    END;

    --=========================================================--
    --  CM Кейс-менеджер
    --  RC Отримувач
    --  PR Надавач
    --  SP Спеціаліст ОСЗН
    --=========================================================--
    FUNCTION Get_Signer_Pib (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Ret   VARCHAR2 (2000);
    BEGIN
          SELECT MAX (Api$act.Get_Signer_Name (s.Ati_Sc, s.Ati_Cu, s.Ati_Wu))
            INTO l_Ret
            FROM At_Signers s
           WHERE     s.Ati_At = p_At_Id
                 AND s.History_Status = 'A'
                 AND s.Ati_Tp = p_Ati_Tp
        ORDER BY s.Ati_Order;

        RETURN l_Ret;
    END;

    FUNCTION Get_Signer_Position (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Ret   VARCHAR2 (2000);
    BEGIN
          --todo: додати поле
          SELECT MAX (NULL)
            INTO l_Ret
            FROM At_Signers s
           WHERE     s.Ati_At = p_At_Id
                 AND s.History_Status = 'A'
                 AND s.Ati_Tp = p_Ati_Tp
        ORDER BY s.Ati_Order;

        RETURN l_Ret;
    END;

    FUNCTION Get_Signer_Dt (p_At_Id IN NUMBER, p_Ati_Tp IN VARCHAR2)
        RETURN DATE
    IS
        l_Ret   DATE;
    BEGIN
          SELECT MAX (s.ati_sign_dt)
            INTO l_Ret
            FROM At_Signers s
           WHERE     s.Ati_At = p_At_Id
                 AND s.History_Status = 'A'
                 AND s.Ati_Tp = p_Ati_Tp
        ORDER BY s.Ati_Order;

        RETURN l_Ret;
    END;

    FUNCTION Get_At_Rnspm (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT a.At_Rnspm
          INTO l_Result
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Ats_cnt (p_At_Id         IN NUMBER,
                          p_nst           IN NUMBER,
                          p_Ats_St_List   IN VARCHAR2 := 'R, P, PP')
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Result
          FROM At_Service Ats
         WHERE     Ats.Ats_At = p_At_Id
               AND Ats.History_Status = 'A'
               AND (   INSTR (',' || REPLACE (p_Ats_St_List, ' ', '') || ',',
                              ',' || Ats.Ats_St || ',') >
                       0
                    OR TRIM (p_Ats_St_List) IS NULL)
               AND Ats.Ats_Nst = p_nst;

        RETURN l_Result;
    END;

    FUNCTION Get_At_Ap (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT a.At_Ap
          INTO l_Result
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        RETURN l_Result;
    END;

    FUNCTION Act_Exists (p_At_Main_Link      IN NUMBER,
                         p_At_Main_Link_Tp   IN VARCHAR2,
                         p_At_Tp             IN VARCHAR2,
                         p_At_St             IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Act_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Act_Exists
          FROM Act a
         WHERE     a.At_Main_Link = p_At_Main_Link
               AND a.At_Main_Link_Tp = p_At_Main_Link_Tp
               AND a.At_Tp = p_At_Tp
               AND a.At_St = p_At_St;

        RETURN l_Act_Exists = 1;
    END;

    PROCEDURE add_at_link (p_at_id         IN NUMBER,
                           p_atk_link_at   IN NUMBER,
                           p_atk_tp        IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO at_links (atk_at, atk_link_at, atk_tp)
             VALUES (p_at_id, p_atk_link_at, p_atk_tp);
    END;

    ----------------------------------------------------
    PROCEDURE State_APOP (p_at_id         NUMBER,
                          p_cnt_all   OUT NUMBER,
                          p_cnt_ap    OUT NUMBER,
                          p_apop_id   OUT NUMBER)
    IS
    BEGIN
        /*AN Проект
        AD Скасовано
        AV Очікує підписання
        AK Підписано отримувачем
        AS Підписано надавачем
        AP Затверджено
        AR Відхилено
        */
        SELECT COUNT (1),
               SUM (CASE apop.at_st WHEN 'AP' THEN 1 ELSE 0 END),
               MAX (
                   CASE apop.at_st
                       WHEN 'AP' THEN apop.at_id
                       ELSE TO_NUMBER (NULL)
                   END)
          INTO p_cnt_all, p_cnt_ap, p_apop_id
          FROM act apop
         WHERE     apop.at_main_link = p_at_id
               AND apop.at_tp = 'APOP'
               AND apop.at_st IN ('AN',
                                  'AV',
                                  'AK',
                                  'AS',
                                  'AP');
    END;

    ----------------------------------------------------
    PROCEDURE State_OKS (p_at_id         NUMBER,
                         p_cnt_all   OUT NUMBER,
                         p_cnt_gp    OUT NUMBER)
    IS
    BEGIN
        SELECT COUNT (1), SUM (CASE oks.at_st WHEN 'TP' THEN 1 ELSE 0 END)
          INTO p_cnt_all, p_cnt_gp
          FROM act oks
         WHERE     oks.at_main_link = p_at_id
               AND oks.at_tp = 'OKS'
               AND oks.at_st IN ('TN',
                                 'TV',
                                 'TS',
                                 'TP');
    END;

    ----------------------------------------------------
    PROCEDURE State_ANPK (p_at_id         NUMBER,
                          p_cnt_all   OUT NUMBER,
                          p_cnt_gp    OUT NUMBER)
    IS
    BEGIN
        SELECT COUNT (1), SUM (CASE anpoe.at_st WHEN 'GP' THEN 1 ELSE 0 END)
          INTO p_cnt_all, p_cnt_gp
          FROM act anpoe
         WHERE     anpoe.at_main_link = p_at_id
               AND anpoe.at_tp = 'ANPK'
               AND anpoe.at_st IN ('GN',
                                   'DV',
                                   'GV',
                                   'GS',
                                   'GP');
    END;

    ----------------------------------------------------
    PROCEDURE State_ANPOE (p_at_id         NUMBER,
                           p_cnt_all   OUT NUMBER,
                           p_cnt_xp    OUT NUMBER,
                           p_id_xp     OUT NUMBER)
    IS
    BEGIN
        SELECT COUNT (1), SUM (CASE anpoe.at_st WHEN 'XP' THEN 1 ELSE 0 END)
          INTO p_cnt_all, p_cnt_xp
          FROM act anpoe
         WHERE     anpoe.at_main_link = p_at_id
               AND anpoe.at_tp = 'ANPOE'
               AND anpoe.at_st IN ('XN',
                                   'XV',
                                   'XS',
                                   'XP');

        IF p_cnt_xp > 0
        THEN
            SELECT at_id
              INTO p_id_xp
              FROM act anpoe
             WHERE     anpoe.at_main_link = p_at_id
                   AND anpoe.at_tp = 'ANPOE'
                   AND anpoe.at_st = 'XP';
        END IF;
    END;

    ----------------------------------------------------
    PROCEDURE State_NRNP (p_at_id              NUMBER,
                          p_cnt_xp         OUT NUMBER,
                          p_id_xp          OUT NUMBER,
                          p_cnt_803        OUT NUMBER,
                          p_cnt_ats_all    OUT NUMBER,
                          p_cnt_ats_need   OUT NUMBER)
    IS
    BEGIN
        SELECT SUM (CASE nrnp.at_st WHEN 'FP' THEN 1 ELSE 0 END)
          INTO p_cnt_xp
          FROM act nrnp
         WHERE     nrnp.at_main_link = p_at_id
               AND nrnp.at_tp = 'NRNP'
               AND nrnp.at_st IN ('FP');

        IF p_cnt_xp > 0
        THEN
            SELECT at_id
              INTO p_id_xp
              FROM act nrnp
             WHERE     nrnp.at_main_link = p_at_id
                   AND nrnp.at_tp = 'NRNP'
                   AND nrnp.at_st = 'FP';
        END IF;


        SELECT COUNT (1)
          INTO p_cnt_803
          FROM act  at
               JOIN act all_at ON at.at_ap = all_at.at_ap
               JOIN at_document atd
                   ON     atd.atd_at = all_at.at_id
                      AND atd_ndt = 803
                      AND HISTORY_STATUS = 'A'
         WHERE at.at_id = p_at_id;

        SELECT COUNT (1),
               SUM (
                   CASE WHEN ats.ats_nst IN (401, 403, 420) THEN 1 ELSE 0 END)
          INTO p_cnt_ats_all, p_cnt_ats_need
          FROM at_service ats
         WHERE ats_at = p_at_id AND HISTORY_STATUS = 'A' AND ats.ats_st = 'P';
    END;

    ----------------------------------------------------

    /*
    В глобальний ЖЦ необхідно додати вилку після акту АРОР:
    1) якщо в АРОРі nda_id in (2063) = T або nda_id in (844) = T, то:
    - зміна статусу SP1 => SGA
    - автоматичне створення акту NDIS
    - після підписання NDIS зміна статусу SGA => SR

    2) - якщо в АРОРі nda_id in (2063) = F та nda_id in (844) = F, то:
    - зміна статусу SP1 => SR*/

    -- точка виходу з міні-ЖЦ в загальний ЖЦ – документ отримав статус:
    -- статус акту OKS = GP «Затверджено», після чого рішення PDSP отримує статус SR
    -- Для PDST AT_ST = 'SP1'
    FUNCTION Check_PDST_ST_SP1 (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        l_apop_cnt_all   NUMBER;
        l_apop_cnt_ap    NUMBER;
        l_apop_id        NUMBER;


        l_cnt_all        NUMBER;
        l_cnt_gp         NUMBER;
    BEGIN
        State_APOP (p_at_id,
                    l_apop_cnt_all,
                    l_apop_cnt_ap,
                    l_apop_cnt_ap);

        IF l_apop_cnt_all > 0 AND l_apop_cnt_all = l_apop_cnt_ap
        THEN
            IF    Get_Act_Feature (l_apop_id, 2063, 'F') = 'T'
               OR Get_Act_Feature (l_apop_id, 844, 'F') = 'F'
            THEN
                RETURN 'SGP';
            ELSE
                RETURN 'SR';
            END IF;
        END IF;


        State_OKS (p_at_id, l_cnt_all, l_cnt_gp);

        IF l_cnt_all = 0
        THEN
            RETURN 'SR';
        ELSIF l_cnt_all > 0 AND l_cnt_gp = 0
        THEN
            RETURN '-1';
        ELSIF l_cnt_all > 0 AND l_cnt_gp = l_cnt_all
        THEN
            RETURN 'SR';
        END IF;

        RETURN '__';
    END;

    --==========================================--
    -- Для PDST AT_ST = 'SW'
    --#96628
    --==========================================--
    FUNCTION Check_PDST_ST_SW (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        l_cnt420      NUMBER;
        l_age         NUMBER := 0;
        l_atr_2081    VARCHAR2 (200);
        l_atr_2084    VARCHAR2 (200);
        l_atr_1870    VARCHAR2 (200);
        l_atr_33      VARCHAR2 (200);
        l_atr_2031    VARCHAR2 (200);
        l_atr_2032    VARCHAR2 (200);
        l_atr_2078    VARCHAR2 (200);
        l_atr_2082    VARCHAR2 (200);
        l_anpoe_qty   NUMBER;
        l_ap_id       NUMBER;
    BEGIN
        SELECT at_ap
          INTO l_ap_id
          FROM act
         WHERE at_id = p_at_id;

        --перевірю, чи послуга 420
        SELECT COUNT (*)
          INTO l_cnt420
          FROM Uss_Esr.At_Service s
         WHERE     s.Ats_At = p_at_id
               AND s.Ats_Nst = 420
               AND s.History_Status = 'A'
               AND s.Ats_St IN ('R', 'PP', 'P');

        --Шукаємо ANPOE для PDSP
        SELECT COUNT (1)
          INTO l_anpoe_qty
          FROM Act anpoe JOIN Act pdsp ON anpoe.at_ap = pdsp.at_ap
         WHERE     pdsp.at_id = p_at_id
               AND anpoe.at_tp = 'ANPOE'
               AND anpoe.at_st = 'XP';

        IF l_cnt420 > 0
        THEN
            --визначимо вік отримувача, він повинен бути більше 18 років
            SELECT TRUNC (MONTHS_BETWEEN (act.at_dt, Scb_Dt) / 12, 0)
              INTO l_age
              FROM act
                   JOIN Uss_Person.v_Socialcard c ON c.sc_id = At_Sc
                   JOIN Uss_Person.v_Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Uss_Person.v_Sc_Birth b ON Cc.Scc_Scb = b.Scb_Id
             WHERE at_id = p_at_id;
        ELSE
            --визначимо атрибути «Одноразова послуга»

            SELECT (SELECT MAX (sf.atef_feature)
                      FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2081),
                   (SELECT MAX (sf.atef_feature)
                      FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2084)
              INTO l_atr_2081, l_atr_2084
              FROM (SELECT MAX (at_id)     AS at_id
                      FROM act a
                     WHERE     a.at_tp = 'APOP'
                           AND a.at_st = 'AS'
                           AND a.at_main_link =
                               NVL (Api$act.g_At_Id, p_at_id)) a;

            SELECT MAX (f.atf_val_string)
              INTO l_atr_33
              FROM at_features f
             WHERE     f.atf_nft = 33
                   AND f.atf_at = NVL (Api$act.g_at_Id, p_at_id);
        END IF;

        --#104894
        l_atr_1870 := Api$appeal.Get_Ap_Attr_Str (l_ap_id, 1870);

        --#106471
        l_atr_2031 := Api$appeal.Get_Ap_Attr_Str (l_ap_id, 2031);
        l_atr_2032 := Api$appeal.Get_Ap_Attr_Str (l_ap_id, 2032);
        l_atr_2078 := Api$appeal.Get_Ap_Attr_Str (l_ap_id, 2078);
        l_atr_2082 := Api$appeal.Get_Ap_Attr_Str (l_ap_id, 2082);

        IF l_anpoe_qty = 0
        THEN
            CASE
                WHEN l_atr_1870 = 'T'
                THEN
                    --#104894
                    RETURN 'SA';
                WHEN l_cnt420 > 0 AND l_age < 18
                THEN
                    RETURN 'SJ';
                WHEN l_cnt420 > 0 AND l_age >= 18
                THEN
                    RETURN 'SU';
                WHEN l_atr_2081 = 'T' OR l_atr_2084 = 'T'
                THEN
                    RETURN 'SGO';
                WHEN l_atr_33 = 'T'
                THEN
                    RETURN 'O.SO';
                ELSE
                    RETURN 'SA';
            END CASE;
        ELSE
            --#106471
            CASE
                WHEN     l_atr_2031 = 'T'
                     AND l_atr_2078 = 'F'
                     AND l_atr_2082 = 'T'
                     AND l_atr_2032 = 'F'
                THEN
                    RETURN 'SGO';
                WHEN     l_atr_2031 = 'T'
                     AND l_atr_2078 = 'F'
                     AND l_atr_2082 = 'F'
                     AND l_atr_2032 = 'F'
                THEN
                    RETURN 'SGM';
                WHEN     l_atr_2031 = 'T'
                     AND l_atr_2078 = 'T'
                     AND l_atr_2082 IN ('T', 'F')
                     AND l_atr_2032 = 'F'
                THEN
                    RETURN 'SGA';
                WHEN l_atr_2032 = 'T'
                THEN
                    RETURN 'SV';
                ELSE
                    RETURN 'SA';
            END CASE;
        END IF;

        RETURN '__';
    END;

    PROCEDURE Check_Lnk_St (p_at_id     NUMBER,
                            p_at_st     VARCHAR2,
                            p_at_tp     VARCHAR2,
                            p_message   VARCHAR2:= NULL)
    IS
        l_qty          NUMBER;
        l_at_tp_name   VARCHAR2 (100);
    BEGIN
        SELECT COUNT (1)
          INTO l_qty
          FROM uss_esr.act  lnk
               JOIN uss_esr.act a ON a.at_main_link = lnk.at_id
         WHERE a.at_id = p_at_id AND lnk.at_st = p_at_st;

        IF l_qty = 0
        THEN
            BEGIN
                EXECUTE IMMEDIATE   'select DIC_NAME from uss_ndi.V_DDN_AT_'
                                 || p_at_tp
                                 || '_ST where dic_value = :st'
                    INTO l_at_tp_name
                    USING p_at_st;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_at_tp_name :=
                        'Status not found for act type [' || p_at_tp || ']';
            END;

            raise_application_error (
                -20000,
                NVL (
                    p_message,
                       'Акт повинен бути у статусі '
                    || l_at_tp_name
                    || ' ['
                    || p_at_st
                    || ']'));
        END IF;
    END;

    --==========================================--
    -- Для PDST AT_ST = 'SA'
    --==========================================--
    FUNCTION Check_PDST_ST_SA (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        l_ap_id         NUMBER;
        l_cnt_all       NUMBER;
        l_cnt_avop      NUMBER;
        -------------
        --l_id_anpoe     NUMBER;
        l_cnt_anpoe     NUMBER := 0;
        l_cnt_anpoe_p   NUMBER := 0;
        -------------
        l_id_anpk       NUMBER;
        l_cnt_anpk      NUMBER := 0;
        l_cnt_anpk_p    NUMBER := 0;
        -------------
        l_cnt_nrnp      NUMBER := 0;
        -------------
        l_atr_3621      VARCHAR2 (200);
        l_atr_2081      VARCHAR2 (200);
        l_atr_2084      VARCHAR2 (200);
    BEGIN
        l_ap_id := Get_At_Ap (p_at_id);

        State_ANPOE (p_at_id,
                     l_cnt_anpoe,
                     l_cnt_anpoe_p,
                     l_id_anpk);

        SELECT COUNT (1)
          INTO l_cnt_nrnp
          FROM Act nrnp
         WHERE     nrnp.at_main_link_tp = 'DECISION'
               AND nrnp.at_main_link = p_at_id
               AND nrnp.at_ap = l_ap_id
               AND nrnp.at_st IN ('FP');


        dbms_output_put_lines (
               'p_at_id='
            || p_at_id
            || '  l_cnt_anpoe='
            || l_cnt_anpoe
            || '  l_cnt_anpoe_p='
            || l_cnt_anpoe_p
            || '  l_id_anpk='
            || l_id_anpk);

        IF l_cnt_nrnp > 0
        THEN
            RETURN 'SNR';
        ELSIF l_cnt_anpoe > 0 AND l_cnt_anpoe > l_cnt_anpoe_p
        THEN
            RETURN 'SA';
        ELSIF l_cnt_anpoe > 0 AND l_cnt_anpoe = l_cnt_anpoe_p
        THEN
            IF Get_Act_Feature (l_id_anpk, 2032, 'F') = 'T'
            THEN
                RETURN 'SV';
            ELSIF Get_Act_Feature (l_id_anpk, 2032, 'F') = 'F'
            THEN
                IF     Get_Act_Feature (l_id_anpk, 2031, 'F') = 'T'
                   AND Get_Act_Feature (l_id_anpk, 2078, 'F') = 'F'
                   AND Get_Act_Feature (l_id_anpk, 2082, 'F') = 'T'
                THEN
                    RETURN 'SGO';
                ELSIF     Get_Act_Feature (l_id_anpk, 2031, 'F') = 'T'
                      AND Get_Act_Feature (l_id_anpk, 2078, 'F') = 'F'
                      AND Get_Act_Feature (l_id_anpk, 2082, 'F') = 'F'
                THEN
                    RETURN 'SGM';
                ELSIF     Get_Act_Feature (l_id_anpk, 2031, 'F') = 'T'
                      AND Get_Act_Feature (l_id_anpk, 2078, 'F') = 'T'
                THEN
                    RETURN 'SGA';
                END IF;
            END IF;
        END IF;


        /*
        - точка виходу з міні-ЖЦ в загальний ЖЦ – документ отримав статус:
        -- статус акту ANPK = GP «Затверджено», після чого рішення отримує статус:
        --- або «Виконано» SV - якщо в документі ndt_id=845, який створювався для типу акту OKS,
        атрибут «Перенаправлення до інших НСП» nda_id in (3621)=F
        --- або «Створення перенаправлення» SGA - якщо в документі ndt_id=845, який створювався для типу акту OKS,
        атрибут «Перенаправлення до інших НСП» nda_id in (3621)=T*/

        State_ANPK (p_at_id, l_cnt_anpk, l_cnt_anpk_p);

        IF l_cnt_anpk > 0 AND l_cnt_anpk > l_cnt_anpk_p
        THEN
            RETURN 'SA';
        ELSIF l_cnt_anpk > 0 AND l_cnt_anpk = l_cnt_anpk_p
        THEN
            SELECT NVL (MAX (atda.atda_val_string), 'F')
              INTO l_atr_3621
              FROM act  oks
                   JOIN at_document atd
                       ON atd.atd_at = oks.at_id AND atd.history_status = 'A'
                   JOIN at_document_attr atda
                       ON     atda.atda_atd = atd.atd_id
                          AND atda.history_status = 'A'
             WHERE     oks.at_main_link = p_at_id
                   AND oks.at_tp = 'OKS'
                   AND oks.at_st IN ('TP')
                   AND atd.atd_ndt = 845
                   AND atda.atda_nda = 3621;

            IF l_atr_3621 = 'T'
            THEN
                RETURN 'SGA';
            ELSE
                RETURN 'SV';
            END IF;
        END IF;

        SELECT COUNT (1), SUM (Is_avop) AS cnt_avop
          INTO l_cnt_all, l_cnt_avop
          FROM (SELECT act.at_id,
                       act.at_ap,
                       ats.ats_nst,
                       (SELECT COUNT (1)
                          FROM act  avop
                               JOIN at_service atsa
                                   ON     avop.at_id = atsa.ats_at
                                      AND atsa.history_status = 'A'
                         WHERE     avop.at_main_link = act.at_id
                               AND atsa.ats_nst = ats.ats_nst
                               AND avop.at_tp = 'AVOP'
                               AND avop.at_st = 'VP')    Is_avop
                  FROM act  act
                       JOIN at_service ats
                           ON     act.at_id = ats.ats_at
                              AND ats.history_status = 'A'
                 WHERE     act.at_id = NVL (Api$act.g_At_Id, p_at_id)
                       AND act.at_tp = 'PDSP'
                       AND ats.ats_st IN ('P', 'PP'));

        /*
        Умова формування гілки: гілка має формуватися в залежності від значень атрибутів nda_id in (2081, 2084) документа ndt_id=804,
        який було створено у акті APOP, який має статус AS (при виконанні первинної оцінки)
        Процес: при встановленні акту вторинної оцінки AVOP статусу VP, виконувати переходи:
        1) SA => SV
        - якщо «одноразова послуга» nda_id in (2081) = T або nda_id in (2084) = T
        2) SA => SP2
        - якщо «одноразова послуга» nda_id in (2081) = F або nda_id in (2084) = F
        */
        IF l_cnt_all = l_cnt_avop
        THEN
            SELECT (SELECT MAX (sf.atef_feature)
                      FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2081),
                   (SELECT MAX (sf.atef_feature)
                      FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2084)
              INTO l_atr_2081, l_atr_2084
              FROM act  a
                   JOIN at_document atd
                       ON     atd.atd_at = a.at_id
                          AND atd.atd_ndt = 804
                          AND atd.history_status = 'A'
             WHERE     a.at_tp = 'APOP'
                   AND a.at_st = 'AS'
                   AND a.at_main_link = NVL (Api$act.g_At_Id, p_at_id);

            IF NVL (l_atr_2081, 'F') = 'T' OR NVL (l_atr_2084, 'F') = 'T'
            THEN
                RETURN 'SV';
            END IF;

            RETURN 'SP2';
        END IF;

        RETURN '__';
    /*
    l_ap_id
    1) SA => SGO
    - «є потреба у подальшому наданні соціальних послуг» nda_id in (2031) = T
    - «Перенаправлення до іншого НСП» nda_id in (2078) = F
    - «одноразова послуга» nda_id in (2082) = T
    - «роботу з отримувачем соціальних послуг можна завершити» nda_id in (2032) = F
    2) SA => SGM
    - «є потреба у подальшому наданні соціальних послуг» nda_id in (2031) = T
    - «Перенаправлення до іншого НСП» nda_id in (2078) = F
    - «одноразова послуга» nda_id in (2082) = F
    - «роботу з отримувачем соціальних послуг можна завершити» nda_id in (2032) = F
    3) SA => SGA
    - «є потреба у подальшому наданні соціальних послуг» nda_id in (2031) = T
    - «Перенаправлення до іншого НСП» nda_id in (2078) = T
    - «одноразова послуга» nda_id in (2082) = T/F
    - «роботу з отримувачем соціальних послуг можна завершити» nda_id in (2032) = F
    4) SA => SV
    - «роботу з отримувачем соціальних послуг можна завершити» nda_id in (2032) = T*/

    END;


    --==========================================--
    -- Для PDST AT_ST = 'SGO'
    --==========================================--
    FUNCTION Check_PDST_ST_SGO (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        --l_cnt_all      NUMBER;
        --l_cnt_avop     NUMBER;
        -------------
        l_id_anpk       NUMBER;
        --l_id_anpoe     NUMBER;
        l_cnt_anpoe     NUMBER := 0;
        l_cnt_anpoe_p   NUMBER := 0;
    BEGIN
        State_ANPOE (p_at_id,
                     l_cnt_anpoe,
                     l_cnt_anpoe_p,
                     l_id_anpk);
        dbms_output_put_lines (
               'p_at_id='
            || p_at_id
            || '  l_cnt_anpoe='
            || l_cnt_anpoe
            || '  l_cnt_anpoe_p='
            || l_cnt_anpoe_p
            || '  l_id_anpk='
            || l_id_anpk);

        IF l_cnt_anpoe > 0 AND l_cnt_anpoe > l_cnt_anpoe_p
        THEN
            RETURN 'SGO';
        ELSIF l_cnt_anpoe > 0 AND l_cnt_anpoe = l_cnt_anpoe_p
        THEN
            RETURN '1';
        END IF;

        RETURN 'SGO';
    END;

    --==========================================--
    -- Для PDST AT_ST = 'SNR'
    --==========================================--
    FUNCTION Check_PDST_ST_SNR (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        --l_ap_id NUMBER;
        l_nrnp_id                 NUMBER;
        l_cnt_nrnp                NUMBER;
        l_cnt_803                 NUMBER;
        l_cnt_pdsp_avop_ats_all   NUMBER;
        l_cnt_ats_all             NUMBER;
        l_cnt_ats_need            NUMBER;
        l_cnt_ats_o               NUMBER;
        l_cnt_ats_p               NUMBER;

        l_cnt_all                 NUMBER;
        l_cnt_avop                NUMBER;
        l_cnt_avop_p              NUMBER;
        l_cnt_avop_o              NUMBER;
        l_cnt_signed_avop_p       NUMBER;
        l_cnt_signed_avop_o       NUMBER;
        --l_atr_2081     VARCHAR2(200);
        --l_atr_2084     VARCHAR2(200);
        l_atr_2031                VARCHAR2 (200);
        l_atr_2032                VARCHAR2 (200);
        l_atr_2078                VARCHAR2 (200);
        --l_atr_2082     VARCHAR2(200);
        l_res_st                  VARCHAR2 (10);
    BEGIN
        --https://redmine.med/projects/uss_esr/wiki/PDSP_%E2%80%93_%D0%B7%D0%BC%D1%96%D0%BD%D0%B0_%D1%81%D1%82%D0%B0%D1%82%D1%83%D1%81%D1%83_%D0%B7_%D0%BF%D0%BE%D1%82%D0%BE%D1%87%D0%BD%D0%BE%D0%B3%D0%BE_%D1%81%D1%82%D0%B0%D1%82%D1%83%D1%81%D1%83_%E2%80%98SNR%E2%80%99
        --#110354
        --l_ap_id := Get_At_Ap(p_at_id);

        State_NRNP (NVL (Api$act.g_At_Id, p_at_id),
                    l_cnt_nrnp,
                    l_nrnp_id,
                    l_cnt_803,
                    l_cnt_ats_all,
                    l_cnt_ats_need);

        --#111064 закоментовано, щоб відповідати умові задачі
        --IF  l_cnt_ats_need  = l_cnt_ats_all THEN
        --  RETURN 'SV';
        --END IF;


        IF l_cnt_803 > 0
        THEN
            l_atr_2031 := Get_PDSP_Feature (p_at_id, 2031, '_');
            l_atr_2078 := Get_PDSP_Feature (p_at_id, 2078, '_');
            l_atr_2032 := Get_PDSP_Feature (p_at_id, 2032, '_');

            --l_atr_2082 := Get_PDSP_Feature(p_at_id, 2082, '_');

            IF l_cnt_ats_all > 0 AND l_cnt_ats_all = l_cnt_ats_need
            THEN
                l_res_st := 'SV';
            ELSIF l_atr_2031 = 'T' AND l_atr_2078 = 'F' AND --#110554
                                                            --l_atr_2082 = 'F' AND
                                                            l_atr_2032 = 'F'
            THEN
                l_res_st := 'SGM';
            ELSIF l_atr_2031 = 'T' AND l_atr_2078 = 'F' AND --#110554
                                                            --l_atr_2082 = 'T' AND
                                                            l_atr_2032 = 'F'
            THEN
                l_res_st := 'SGO';
            ELSIF l_atr_2031 = 'T' AND l_atr_2078 = 'T' AND --#110554
                                                            --(p_at_id, 2082, '_') IN ('T','F') AND
                                                            l_atr_2032 = 'F'
            THEN
                l_res_st := 'SGA';
            ELSIF l_atr_2032 = 'T'
            THEN
                --#110554
                l_res_st := 'SV';
            ELSIF l_atr_2031 = 'F'
            THEN
                --#110354
                l_res_st := 'SV';
            END IF;

            RETURN l_res_st;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt_pdsp_avop_ats_all
          FROM (SELECT atsa.ats_id,
                       atsa.ats_nst,
                       (SELECT COUNT (DISTINCT ats.ats_nst)
                          FROM act  avop
                               JOIN at_service ats
                                   ON     avop.at_id = ats.ats_at
                                      AND ats.history_status = 'A'
                         WHERE     avop.at_main_link = pdsp.at_id
                               AND avop.at_main_link_tp = 'DECISION'
                               AND avop.at_st = 'VP'
                               AND ats.ats_nst = atsa.ats_nst)    avop_nst_qty
                  FROM uss_esr.act  pdsp
                       JOIN uss_esr.at_service atsa
                           ON     pdsp.at_id = atsa.ats_at
                              AND atsa.history_status = 'A'
                 WHERE     pdsp.at_id = NVL (Api$act.g_At_Id, p_at_id)
                       AND pdsp.at_tp = 'PDSP'
                       AND atsa.ats_st = 'P')
         WHERE avop_nst_qty = 0;

        IF l_cnt_pdsp_avop_ats_all = 0
        THEN
            --#111064
            SELECT COUNT (1),
                   SUM (CASE WHEN atsa.ats_ss_term = 'O' THEN 1 ELSE 0 END),
                   SUM (CASE WHEN atsa.ats_ss_term = 'P' THEN 1 ELSE 0 END)
              INTO l_cnt_ats_all, l_cnt_ats_o, l_cnt_ats_p
              FROM uss_esr.act  pdsp
                   JOIN uss_esr.at_service atsa
                       ON     pdsp.at_id = atsa.ats_at
                          AND atsa.history_status = 'A'
             WHERE     pdsp.at_id = NVL (Api$act.g_At_Id, p_at_id)
                   AND pdsp.at_tp = 'PDSP'
                   AND atsa.ats_st = 'P';

            SELECT COUNT (DISTINCT at_id),
                   COUNT (DISTINCT CASE WHEN at_st = 'VP' THEN at_id END),
                   COUNT (
                       DISTINCT CASE WHEN ats_ss_term = 'P' THEN at_id END),
                   COUNT (
                       DISTINCT CASE WHEN ats_ss_term = 'O' THEN at_id END),
                   COUNT (
                       DISTINCT
                           CASE
                               WHEN at_st = 'VP' AND ats_ss_term = 'P'
                               THEN
                                   at_id
                           END),
                   COUNT (
                       DISTINCT
                           CASE
                               WHEN at_st = 'VP' AND ats_ss_term = 'O'
                               THEN
                                   at_id
                           END)
              INTO l_cnt_all,
                   l_cnt_avop,
                   l_cnt_avop_p,
                   l_cnt_avop_o,
                   l_cnt_signed_avop_p,
                   l_cnt_signed_avop_o
              FROM (SELECT at_id, at_st, ats.ats_ss_term
                      FROM uss_Esr.act  avop
                           JOIN uss_Esr.at_service ats ON ats_at = at_id
                     WHERE     avop.at_main_link =
                               NVL (Api$act.g_At_Id, p_at_id)
                           AND avop.at_tp = 'AVOP'
                           AND avop.at_st NOT IN ('VD', 'VR', 'VA')
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.act  pdsp
                                           JOIN uss_esr.at_service atsa
                                               ON     pdsp.at_id =
                                                      atsa.ats_at
                                                  AND atsa.history_status =
                                                      'A'
                                     WHERE     pdsp.at_id =
                                               NVL (Api$act.g_At_Id, p_at_id)
                                           AND pdsp.at_tp = 'PDSP'
                                           AND atsa.ats_st = 'P'
                                           AND atsa.ats_nst = ats.ats_nst));



            --1. Если все услуги в PDSP со сроком O и есть столько же AVOP -> статус SV
            --2. Если в PDSP есть услуги со сроком P и все услуги в AVOP сроком P-> статус SP2
            IF     l_cnt_ats_all > 0
               AND l_cnt_ats_all = l_cnt_ats_o
               AND l_cnt_ats_all = l_cnt_avop
            THEN
                RETURN 'SV';
            ELSIF l_cnt_ats_p > 0 AND l_cnt_avop_p = l_cnt_signed_avop_p
            THEN
                RETURN 'SP2';
            END IF;
        END IF;

        /*
        SELECT COUNT(1), SUM(Is_avop) AS  cnt_avop
           INTO l_cnt_all, l_cnt_avop
         FROM (SELECT act.at_id, act.at_ap, ats.ats_nst,
                      ( SELECT COUNT(distinct atsa.ats_nst)
                        FROM act avop
                        JOIN at_service atsa ON avop.at_id = atsa.ats_at AND atsa.history_status = 'A'
                        WHERE avop.at_main_link = act.at_id
                          AND atsa.ats_nst = ats.ats_nst
                          AND avop.at_tp = 'AVOP'
                          AND avop.at_st = 'VP'
                      ) Is_avop
               FROM act act
                 JOIN at_service ats ON act.at_id = ats.ats_at AND ats.history_status = 'A'
               WHERE act.at_id = nvl(Api$act.g_At_Id, p_at_id)
                 AND act.at_tp = 'PDSP'
                 AND ats.ats_st in ('P', 'PP')
              );


        IF l_cnt_all = l_cnt_avop THEN
           BEGIN
             SELECT (SELECT MAX(sf.atef_feature)
                     FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2081 ),
                    (SELECT MAX(sf.atef_feature)
                     FROM at_section_feature sf
                     WHERE sf.atef_at = a.at_id AND sf.atef_nda = 2084 )
                INTO l_atr_2081, l_atr_2084
              FROM act a
               JOIN at_document atd ON atd.atd_at = a.at_id AND atd.atd_ndt = 804 AND atd.history_status = 'A'
              WHERE a.at_tp = 'APOP'
               AND a.at_st = 'AS'
               AND a.at_main_link = nvl(Api$act.g_At_Id, p_at_id);

              IF nvl(l_atr_2081, 'F') = 'T' OR nvl(l_atr_2084, 'F') = 'T' THEN
                RETURN 'SV';
              END IF;
              RETURN 'SP2';
            EXCEPTION
              WHEN no_data_found then RETURN 'SP2';
            END;
           END IF;
         */

        RETURN '__';
    END;


    --==========================================--
    -- Перевіримо по акту, що документ є та підписаний
    --==========================================--
    FUNCTION Doc_Exists_Sign (p_at_id NUMBER, p_ndt NUMBER)
        RETURN NUMBER
    IS
        l_ret   NUMBER;
    BEGIN
        -- функція повинна повертати 0 або 1, так як перевірка виконуєтьсяя як != 1... тому більше  1 працювати не буде
        SELECT CASE WHEN COUNT (1) >= 1 THEN 1 ELSE 0 END
          INTO l_ret
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE     d.History_Status = 'A'
               AND atd_ndt = p_ndt
               AND atd_at = P_at_id
               AND (   a.Dat_Sign_File IS NOT NULL
                    OR EXISTS
                           (SELECT 1
                              FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                                   JOIN Uss_Doc.v_Files Fs
                                       ON Ss.Dats_Sign_File = Fs.File_Id
                             WHERE Ss.Dats_Dat = a.Dat_Id));

        RETURN l_ret;
    END;


    --+++++++++++++++++++++
    --Повний склад звернення
    --+++++++++++++++++++++
    PROCEDURE dbms_output_appeal_info (p_id NUMBER)
    IS
        CURSOR ap IS
            SELECT *
              FROM appeal
             WHERE ap_id = p_id;

        CURSOR S (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_service
             WHERE aps_ap = p_ap_id AND history_status = 'A';

        CURSOR Z (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('Z', 'O')
                   AND history_status = 'A';

        CURSOR FP (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('FP', 'DU', 'OS')
                   AND history_status = 'A';

        CURSOR FM (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'FM'
                   AND history_status = 'A';

        --    Cursor OS(p_ap_id number) is select * from  ap_person where app_ap=p_ap_id and app_tp IN ('FP','DU') AND history_status = 'A';
        CURSOR doc (p_app_id NUMBER)
        IS
            SELECT apd.apd_id,
                   apd.apd_app,
                   apd.apd_ndt,
                   ndt.ndt_name_short,
                      /*'apd_app='||rpad( apd.apd_app, 4,' ')||*/
                      ' apd_ndt='
                   || RPAD (apd.apd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_document  apd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd.apd_ndt
             WHERE p_app_id = apd.apd_app AND apd.history_status = 'A';

        CURSOR atr (p_apd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT apda.apda_apd,
                              apda.apda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      apda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (apda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (apda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (apda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS apda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM ap_document_attr apda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = apda.apda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE apda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT apda_apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || apda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY apda_apd)    apda_list
                FROM atr
               WHERE apda_val IS NOT NULL AND atr.apda_apd = p_apd_id
            GROUP BY apda_apd;
    BEGIN
        FOR d IN ap
        LOOP
            FOR p IN S (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    nst=' || p.aps_nst);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN Z (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    ' || p.app_tp || '  ' || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FP (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FM (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    ' || p.app_tp || '  ' || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;
    END;


    -----------------------------------------------
    --  Продовження призупинених договорів
    -----------------------------------------------
    PROCEDURE Resume_Suspended_Tctr
    IS
        TYPE r_Act_Info IS RECORD
        (
            At_Id           NUMBER,
            At_St           VARCHAR2 (10),
            At_Main_Link    NUMBER
        );

        TYPE t_At_List IS TABLE OF r_Act_Info;

        l_Tctr_List   t_At_List;
        l_Hs_Id       NUMBER;
    BEGIN
        SELECT a.At_Id, a.At_St, a.At_Main_Link
          BULK COLLECT INTO l_Tctr_List
          FROM Act a
         WHERE     a.At_St = 'DPU'
               AND a.At_Tp = 'TCTR'
               AND NOT EXISTS
                       (SELECT 1
                          FROM Act i
                         WHERE     i.At_Main_Link = a.At_Id
                               AND i.At_Tp = 'ISNP'
                               AND TRUNC (SYSDATE) BETWEEN i.At_Action_Start_Dt
                                                       AND i.At_Action_Stop_Dt);

        IF l_Tctr_List IS NULL OR l_Tctr_List.COUNT = 0
        THEN
            RETURN;
        END IF;

        FORALL i IN INDICES OF l_Tctr_List
            UPDATE Act a
               SET a.At_St = 'DT'
             WHERE a.At_Id = l_Tctr_List (i).At_Id;

        l_Hs_Id := Tools.Gethistsessioncmes ();

        FORALL i IN INDICES OF l_Tctr_List
            INSERT INTO At_Log (Atl_Id,
                                Atl_At,
                                Atl_Hs,
                                Atl_St,
                                Atl_Message,
                                Atl_St_Old,
                                Atl_Tp)
                 VALUES (0,
                         l_Tctr_List (i).At_Id,
                         l_Hs_Id,
                         'DT',
                         CHR (38) || '267',
                         'DPU',
                         'SYS');

        FOR i IN 1 .. l_Tctr_List.COUNT
        LOOP
            DECLARE
                l_Ip_List   t_At_List;
            BEGIN
                SELECT a.At_Id, a.At_St, a.At_Main_Link
                  BULK COLLECT INTO l_Ip_List
                  FROM At_Links  l
                       JOIN Act a
                           ON     l.Atk_At = a.At_Id
                              AND a.At_Tp = 'IP'
                              AND a.At_St = 'IT'
                 WHERE     l.Atk_Link_At = l_Tctr_List (i).At_Main_Link
                       AND l.Atk_Tp = 'DECISION';

                IF l_Ip_List IS NULL OR l_Ip_List.COUNT = 0
                THEN
                    CONTINUE;
                END IF;

                FORALL i IN INDICES OF l_Ip_List
                    UPDATE Act a
                       SET a.At_St = 'IT'
                     WHERE a.At_Id = l_Ip_List (i).At_Id;

                l_Hs_Id := Tools.Gethistsessioncmes ();

                FORALL i IN INDICES OF l_Ip_List
                    INSERT INTO At_Log (Atl_Id,
                                        Atl_At,
                                        Atl_Hs,
                                        Atl_St,
                                        Atl_Message,
                                        Atl_St_Old,
                                        Atl_Tp)
                         VALUES (0,
                                 l_Ip_List (i).At_Id,
                                 l_Hs_Id,
                                 'IT',
                                 CHR (38) || '267',
                                 'ITU',
                                 'SYS');
            END;
        END LOOP;

        COMMIT;
    END;

    PROCEDURE set_ats_st (p_at_Id        IN NUMBER,
                          p_ats_st_old   IN VARCHAR2,
                          p_ats_st_new   IN VARCHAR2)
    IS
    BEGIN
        UPDATE at_service t
           SET t.ats_st = p_ats_st_new
         WHERE t.ats_at = p_at_id AND t.ats_st = p_ats_st_old;
    END;

    -- опрацювання варіацій підпису ОСП в КМ
    PROCEDURE Handle_Cm_Sign (p_at_id       IN     NUMBER,
                              p_at_st_old   IN     VARCHAR2,
                              p_at_st_new   IN     VARCHAR2,
                              p_ndt_id      IN     NUMBER,
                              p_res_st         OUT VARCHAR2)
    IS
        l_doc_Attach_Src   VARCHAR2 (10);
        l_is_used          VARCHAR2 (10) := tools.ggp ('HAND_SIGN_OSP');
        l_is_all_signed    BOOLEAN
            := Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC');
        l_atd_id           NUMBER;
    BEGIN
        p_res_st := p_at_st_old;
        Get_Form_Doc_Src (p_at_id, p_ndt_id, l_doc_Attach_Src);

        IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T' /* AND l_is_all_signed*/
                                                         )
        THEN
            p_res_st := p_at_st_new;
        --Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id, p_Ndt_Id => p_ndt_id);
        ELSIF (    l_doc_Attach_Src = 'TABLET'
               AND l_is_used = 'T'
               AND l_is_all_signed)
        THEN
            p_res_st := p_at_st_new;
        /*ELSIF (l_doc_Attach_Src IN ('HAND', 'TABLET')  AND l_is_used = 'T' AND NOT l_is_all_signed) THEN
          l_atd_id := Get_Atd_Id(p_At_Id, p_ndt_id);
          Set_Atd_Source(l_atd_id, 'MIX');*/
        END IF;
    END;

    -- при збереженні акту тип ДФ скидується в AUTO. всі підписи на планшеті стають історичними
    PROCEDURE Handle_Form_Save (p_at_id IN NUMBER, p_ndt_id IN NUMBER)
    IS
    --l_cnt NUMBER;
    BEGIN
        IF (p_ndt_id IS NULL)
        THEN
            RETURN;
        END IF;

        /* SELECT COUNT(*)
           INTO l_cnt
           FROM at_signers t
          WHERE t.ati_at = p_at_id
            AND t.history_status = 'A'
            AND t.ati_tp = 'CM'
            AND t.ati_is_signed = 'T';

         IF (l_cnt > 0) THEN
           raise_application_error(-20000, 'Скинути дані підпису в поточному стані заборонено!');
         END iF;*/

        UPDATE at_document t
           SET t.atd_attach_src = 'AUTO'
         WHERE     t.atd_at = p_at_id
               AND t.atd_ndt = p_ndt_id
               AND t.history_status = 'A';

        UPDATE at_document t
           SET t.history_status = 'H'
         WHERE     t.atd_at = p_at_id
               AND t.atd_ndt = 1017
               AND t.history_status = 'A';

        UPDATE at_signers t
           SET t.ati_is_signed = 'F', t.ati_sign_dt = NULL
         WHERE     t.ati_at = p_at_id
               AND t.ati_tp = 'RC'
               AND t.history_status = 'A';
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Sign (p_At_Id        IN     NUMBER,
                               p_Atp_id       IN     NUMBER,
                               p_Atd_Dh          OUT NUMBER,
                               p_Sign_Code       OUT VARCHAR2,
                               p_Photo_Code      OUT VARCHAR2)
    IS
    BEGIN
        SELECT MAX (Atd_Dh),
               MAX (CASE WHEN dat_num = 1 THEN File_Code END),
               MAX (CASE WHEN dat_num = 2 THEN File_Code END)
          INTO p_Atd_Dh, p_Sign_Code, p_Photo_Code
          FROM (SELECT d.Atd_Dh, f.File_Code, NVL (a.dat_num, -1) dat_num
                  FROM At_Document  d
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON d.Atd_Dh = a.Dat_Dh
                       JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                 WHERE     d.Atd_At = p_At_Id
                       AND d.Atd_Ndt = 1017
                       AND d.atd_atp = p_Atp_id
                       AND d.History_Status = 'A');
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДФ
    -----------------------------------------------------------
    FUNCTION Get_Atd_Attach_Source (p_At_Id IN NUMBER, p_Ndt_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (10);
    BEGIN
        SELECT MAX (d.atd_attach_src)
          INTO l_str
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Ndt_id
               AND d.History_Status = 'A';

        RETURN l_str;
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Sign (p_At_Id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT *
              FROM (SELECT f.file_code,
                           'pts' || d.atd_atp     AS person_code,
                           d.atd_atp
                      FROM At_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Atd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                     WHERE     d.Atd_At = p_At_Id
                           AND d.Atd_Ndt = 1017
                           AND d.History_Status = 'A'
                           AND a.dat_num = 1);
    END;

    --#112076
    FUNCTION Is_Appeal_Maked_Correct (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        SELECT at_ap
          INTO l_Ap_Id
          FROM Act
         WHERE at_id = p_at_id;

        RETURN API$APPEAL.Is_Appeal_Maked_Correct (l_Ap_Id);
    END;
BEGIN
    NULL;
END Api$act;
/