/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.P$66749763$TMP
IS
    -- Author  : VANO
    -- Created : 07.06.2021 13:06:19
    -- Purpose : Функції роботи з даними SocialCard

    --Статуси документів
    c_Scd_St_Actual      CONSTANT VARCHAR2 (10) := '1';
    c_Scd_St_Closed      CONSTANT VARCHAR2 (10) := '2';
    c_Scd_St_Duplicate   CONSTANT VARCHAR2 (10) := '4';
    c_Scd_St_Undefined   CONSTANT VARCHAR2 (10) := '-1';

    --Типи документів
    c_Ndt_Vpo_Cert       CONSTANT NUMBER := 10052;
    c_Ndt_Death_Cert     CONSTANT NUMBER := 89;
    c_Ndt_Msek_Cert      CONSTANT NUMBER := 201;

    -- serhii оновлено 20/03/2024 відповідно до вихідного параметра (курсора) PROCEDURE Search_Sc_By_Params
    TYPE r_Search_Sc IS RECORD
    (
        app_sc             NUMBER (14),
        app_inn            VARCHAR2 (50),
        app_fn             VARCHAR2 (200),
        app_ln             VARCHAR2 (200),
        app_mn             VARCHAR2 (200),
        app_esr_num        VARCHAR2 (100),
        app_gender         VARCHAR2 (10),
        app_gender_name    VARCHAR2 (100),
        doc_eos            VARCHAR2 (100),
        birth_dt           DATE,
        app_doc_num        VARCHAR2 (50),
        app_ndt            NUMBER (14),
        app_ndt_name       VARCHAR2 (255)
    );

    TYPE t_Search_Sc IS TABLE OF r_Search_Sc;

    TYPE r_Doc_Attrs IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (4000),
        Val_Dt     DATE,
        Val_Int    NUMBER,
        Val_Id     NUMBER
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attrs;

    TYPE r_Document IS RECORD
    (
        App_Sc          NUMBER,
        Apd_App_Pib     VARCHAR2 (602),
        Apd_Ndt         NUMBER,
        Apd_Ndt_Name    VARCHAR2 (255),
        Apd_Doc         NUMBER
    );

    PROCEDURE Write_Sc_Log (p_Scl_Sc        Sc_Log.Scl_Sc%TYPE,
                            p_Scl_Hs        Sc_Log.Scl_Hs%TYPE,
                            p_Scl_St        Sc_Log.Scl_St%TYPE,
                            p_Scl_Message   Sc_Log.Scl_Message%TYPE,
                            p_Scl_St_Old    Sc_Log.Scl_Old_St%TYPE,
                            p_Scl_Tp        Sc_Log.Scl_Tp%TYPE:= 'SYS');

    PROCEDURE Search_Sc_By_Params (p_Inn          IN     VARCHAR2,
                                   p_Ndt_Id       IN     NUMBER,
                                   p_Doc_Num      IN     VARCHAR2,
                                   p_Fn           IN     VARCHAR2,
                                   p_Ln           IN     VARCHAR2,
                                   p_Mn           IN     VARCHAR2,
                                   p_Esr_Num      IN     VARCHAR2,
                                   p_Gender       IN     VARCHAR2,
                                   p_Found_Cnt       OUT INTEGER,
                                   p_Show_Modal      OUT NUMBER,
                                   p_Persons         OUT SYS_REFCURSOR);

    PROCEDURE Search_Sc_By_Params (p_Inn          IN     VARCHAR2,
                                   p_Ndt_Id       IN     NUMBER,
                                   p_Doc_Num      IN     VARCHAR2,
                                   p_Fn           IN     VARCHAR2,
                                   p_Ln           IN     VARCHAR2,
                                   p_Mn           IN     VARCHAR2,
                                   p_Esr_Num      IN     VARCHAR2,
                                   p_Gender       IN     VARCHAR2,
                                   p_Show_Modal      OUT NUMBER,
                                   p_Found_Cnt       OUT INTEGER,
                                   p_mode         IN     NUMBER DEFAULT 0);

    -- #86318: пошук ЕОС по соц. картці
    PROCEDURE Search_Pc_By_Params (p_Inn          IN     VARCHAR2,
                                   p_Fn           IN     VARCHAR2,
                                   p_Ln           IN     VARCHAR2,
                                   p_Mn           IN     VARCHAR2,
                                   p_Found_Cnt       OUT INTEGER,
                                   p_Show_Modal      OUT NUMBER,
                                   p_Persons         OUT SYS_REFCURSOR);

    PROCEDURE Example_Serach_Sc;

    PROCEDURE Get_Sc_Documents (p_Sc_Id           DECIMAL,
                                p_Ndc_Id          NUMBER DEFAULT NULL,
                                p_Documents   OUT SYS_REFCURSOR);

    PROCEDURE Init_Sc_Info (p_Sc_Id Socialcard.Sc_Id%TYPE);

    PROCEDURE Update_Sc_Info (
        p_Sco_Id            IN Sc_Info.Sco_Id%TYPE,
        p_Sco_Numident      IN Sc_Info.Sco_Numident%TYPE,
        p_Sco_Pasp_Seria    IN Sc_Info.Sco_Pasp_Seria%TYPE,
        p_Sco_Pasp_Number   IN Sc_Info.Sco_Pasp_Number%TYPE,
        p_Sco_Birth_Dt      IN Sc_Info.Sco_Birth_Dt%TYPE,
        p_Sco_Fn            IN Sc_Info.Sco_Fn%TYPE,
        p_Sco_Mn            IN Sc_Info.Sco_Mn%TYPE,
        p_Sco_Ln            IN Sc_Info.Sco_Ln%TYPE);

    PROCEDURE Register_Temporary_Card (p_Inn        IN     VARCHAR2,
                                       p_Ndt_Id     IN     VARCHAR2,
                                       p_Doc_Num    IN     VARCHAR2,
                                       p_Fn         IN     VARCHAR2,
                                       p_Ln         IN     VARCHAR2,
                                       p_Mn         IN     VARCHAR2,
                                       p_Esr_Num    IN     VARCHAR2,
                                       p_Gender     IN     VARCHAR2,
                                       p_Birth_Dt   IN     DATE,
                                       p_Mode       IN     NUMBER DEFAULT 0, -- 0 - якщо не знайдено жодного, 1 - при виборі вручну
                                       p_Sc_Id         OUT NUMBER);

    PROCEDURE Save_Socialcard (
        p_Sc_Id          IN     Socialcard.Sc_Id%TYPE,
        p_Sc_Unique      IN     Socialcard.Sc_Unique%TYPE,
        p_Sc_Create_Dt   IN     Socialcard.Sc_Create_Dt%TYPE,
        p_Sc_Scc         IN     Socialcard.Sc_Scc%TYPE,
        p_Sc_Src         IN     Socialcard.Sc_Src%TYPE,
        p_Sc_St          IN     Socialcard.Sc_St%TYPE,
        p_New_Id            OUT Socialcard.Sc_Id%TYPE);

    PROCEDURE Save_Sc_Identity (
        p_Sci_Id            IN     Sc_Identity.Sci_Id%TYPE,
        p_Sci_Sc            IN     Sc_Identity.Sci_Sc%TYPE,
        p_Sci_Fn            IN     Sc_Identity.Sci_Fn%TYPE,
        p_Sci_Ln            IN     Sc_Identity.Sci_Ln%TYPE,
        p_Sci_Mn            IN     Sc_Identity.Sci_Mn%TYPE,
        p_Sci_Gender        IN     Sc_Identity.Sci_Gender%TYPE,
        p_Sci_Nationality   IN     Sc_Identity.Sci_Nationality%TYPE,
        p_New_Id               OUT Sc_Identity.Sci_Id%TYPE);

    PROCEDURE Save_Sc_Birh (p_Scb_Id     IN     Sc_Birth.Scb_Id%TYPE,
                            p_Scb_Sc     IN     Sc_Birth.Scb_Sc%TYPE,
                            p_Scb_Sca    IN     Sc_Birth.Scb_Sca%TYPE,
                            p_Scb_Scd    IN     Sc_Birth.Scb_Scd%TYPE,
                            p_Scb_Dt     IN     Sc_Birth.Scb_Dt%TYPE,
                            p_Scb_Note   IN     Sc_Birth.Scb_Note%TYPE,
                            p_Scb_Src    IN     Sc_Birth.Scb_Src%TYPE,
                            p_Scb_Ln     IN     Sc_Birth.Scb_Ln%TYPE,
                            p_New_Id        OUT Sc_Birth.Scb_Id%TYPE);

    PROCEDURE Save_Sc_Change (
        p_Scc_Id          IN     Sc_Change.Scc_Id%TYPE,
        p_Scc_Sc          IN     Sc_Change.Scc_Sc%TYPE,
        p_Scc_Create_Dt   IN     Sc_Change.Scc_Create_Dt%TYPE,
        p_Scc_Src         IN     Sc_Change.Scc_Src%TYPE,
        p_Scc_Sct         IN     Sc_Change.Scc_Sct%TYPE,
        p_Scc_Sci         IN     Sc_Change.Scc_Sci%TYPE,
        p_Scc_Scb         IN     Sc_Change.Scc_Scb%TYPE,
        p_Scc_Sca         IN     Sc_Change.Scc_Sca%TYPE,
        p_Scc_Sch         IN     Sc_Change.Scc_Sch%TYPE,
        p_Scc_Scp         IN     Sc_Change.Scc_Scp%TYPE,
        p_Scc_Src_Dt      IN     Sc_Change.Scc_Src_Dt%TYPE,
        p_New_Id             OUT Sc_Change.Scc_Id%TYPE);

    PROCEDURE Set_Sc_Scc (p_Sc_Id    IN Socialcard.Sc_Id%TYPE,
                          p_Sc_Scc   IN Socialcard.Sc_Scc%TYPE);

    PROCEDURE Add_Doc_Attr (p_Doc_Attrs   IN OUT t_Doc_Attrs,
                            p_Nda_Id      IN     NUMBER,
                            p_Val_Str     IN     VARCHAR2 DEFAULT NULL,
                            p_Val_Dt      IN     DATE DEFAULT NULL,
                            p_Val_Int     IN     NUMBER DEFAULT NULL,
                            p_Val_Id      IN     NUMBER DEFAULT NULL);

    PROCEDURE Save_Document (p_Sc_Id       IN     NUMBER,
                             p_Ndt_Id      IN     NUMBER,
                             p_Doc_Attrs   IN     t_Doc_Attrs,
                             p_Src_Id      IN     NUMBER,
                             p_Src_Code    IN     VARCHAR2,
                             p_Scd_Note    IN     VARCHAR2,
                             p_Scd_Id         OUT NUMBER,
                             p_Scd_Dh         OUT NUMBER);

    PROCEDURE Save_Document (p_Sc_Id         IN     NUMBER,
                             p_Ndt_Id        IN     NUMBER,
                             p_Doc_Attrs     IN     t_Doc_Attrs,
                             p_Src_Id        IN     NUMBER,
                             p_Src_Code      IN     VARCHAR2,
                             p_Scd_Note      IN     VARCHAR2,
                             p_Scd_Id           OUT NUMBER,
                             p_Doc_Id        IN OUT NUMBER,
                             p_Dh_Id         IN OUT NUMBER,
                             p_Set_Feature   IN     BOOLEAN DEFAULT FALSE);

    PROCEDURE Save_Sc_Document (
        p_Scd_Id     IN     Sc_Document.Scd_Id%TYPE,
        p_Scd_Sc     IN     Sc_Document.Scd_Sc%TYPE,
        p_Scd_Name   IN     Sc_Document.Scd_Name%TYPE,
        p_Scd_St     IN     Sc_Document.Scd_St%TYPE,
        p_Scd_Src    IN     Sc_Document.Scd_Src%TYPE,
        p_Scd_Note   IN     Sc_Document.Scd_Note%TYPE,
        p_Scd_Ndt    IN     Sc_Document.Scd_Ndt%TYPE,
        p_Scd_Doc    IN     Sc_Document.Scd_Doc%TYPE,
        p_Scd_Dh     IN     Sc_Document.Scd_Dh%TYPE,
        p_New_Id        OUT Sc_Document.Scd_Id%TYPE);

    PROCEDURE Save_Sc_Document (
        p_Scd_Id           IN     Sc_Document.Scd_Id%TYPE,
        p_Scd_Sc           IN     Sc_Document.Scd_Sc%TYPE,
        p_Scd_Name         IN     Sc_Document.Scd_Name%TYPE,
        p_Scd_Seria        IN     Sc_Document.Scd_Seria%TYPE,
        p_Scd_Number       IN     Sc_Document.Scd_Number%TYPE,
        p_Scd_Issued_Dt    IN     Sc_Document.Scd_Issued_Dt%TYPE,
        p_Scd_Issued_Who   IN     Sc_Document.Scd_Issued_Who%TYPE,
        p_Scd_Start_Dt     IN     Sc_Document.Scd_Start_Dt%TYPE,
        p_Scd_Stop_Dt      IN     Sc_Document.Scd_Stop_Dt%TYPE,
        p_Scd_St           IN     Sc_Document.Scd_St%TYPE,
        p_Scd_Src          IN     Sc_Document.Scd_Src%TYPE,
        p_Scd_Note         IN     Sc_Document.Scd_Note%TYPE,
        p_Scd_Ndt          IN     Sc_Document.Scd_Ndt%TYPE,
        p_Scd_Doc          IN     Sc_Document.Scd_Doc%TYPE,
        p_Scd_Dh           IN     Sc_Document.Scd_Dh%TYPE,
        p_New_Id              OUT Sc_Document.Scd_Id%TYPE);

    PROCEDURE Set_Doc_St (p_Scd_Id IN NUMBER, p_Scd_St IN VARCHAR2);

    PROCEDURE Close_Other_Docs (p_Sc_Id        NUMBER,
                                p_Ndt_Id       NUMBER,
                                p_Actual_Scd   NUMBER);

    PROCEDURE Save_Sc_Address (
        p_Sca_Id           IN     Sc_Address.Sca_Id%TYPE,
        p_Sca_Sc           IN     Sc_Address.Sca_Sc%TYPE,
        p_Sca_Tp           IN     Sc_Address.Sca_Tp%TYPE,
        p_Sca_Kaot         IN     Sc_Address.Sca_Kaot%TYPE,
        p_Sca_Nc           IN     Sc_Address.Sca_Nc%TYPE,
        p_Sca_Country      IN     Sc_Address.Sca_Country%TYPE,
        p_Sca_Region       IN     Sc_Address.Sca_Region%TYPE,
        p_Sca_District     IN     Sc_Address.Sca_District%TYPE,
        p_Sca_Postcode     IN     Sc_Address.Sca_Postcode%TYPE,
        p_Sca_City         IN     Sc_Address.Sca_City%TYPE,
        p_Sca_Street       IN     Sc_Address.Sca_Street%TYPE,
        p_Sca_Building     IN     Sc_Address.Sca_Building%TYPE,
        p_Sca_Block        IN     Sc_Address.Sca_Block%TYPE,
        p_Sca_Apartment    IN     Sc_Address.Sca_Apartment%TYPE,
        p_Sca_Note         IN     Sc_Address.Sca_Note%TYPE,
        p_History_Status   IN     Sc_Address.History_Status%TYPE,
        p_Sca_Src          IN     Sc_Address.Sca_Src%TYPE,
        p_New_Id              OUT Sc_Address.Sca_Id%TYPE);

    PROCEDURE Save_Sc_Address (                                   -- IC #83999
        p_Sca_Sc          IN     Sc_Address.Sca_Sc%TYPE,
        p_Sca_Tp          IN     Sc_Address.Sca_Tp%TYPE,
        p_Sca_Kaot        IN     Sc_Address.Sca_Kaot%TYPE := NULL,
        p_Sca_Nc          IN     Sc_Address.Sca_Nc%TYPE := NULL,
        p_Sca_Country     IN     Sc_Address.Sca_Country%TYPE := 'УКРАЇНА',
        p_Sca_Region      IN     Sc_Address.Sca_Region%TYPE := NULL,
        p_Sca_District    IN     Sc_Address.Sca_District%TYPE := NULL,
        p_Sca_Postcode    IN     Sc_Address.Sca_Postcode%TYPE := NULL,
        p_Sca_City        IN     Sc_Address.Sca_City%TYPE := NULL,
        p_Sca_Street      IN     Sc_Address.Sca_Street%TYPE := NULL,
        p_Sca_Building    IN     Sc_Address.Sca_Building%TYPE := NULL,
        p_Sca_Block       IN     Sc_Address.Sca_Block%TYPE := NULL,
        p_Sca_Apartment   IN     Sc_Address.Sca_Apartment%TYPE := NULL,
        p_Sca_Note        IN     Sc_Address.Sca_Note%TYPE := NULL,
        p_Sca_Src         IN     Sc_Address.Sca_Src%TYPE := NULL,
        p_Sca_Create_Dt   IN     Sc_Address.Sca_Create_Dt%TYPE := SYSDATE,
        o_Sca_Id             OUT Sc_Address.Sca_Id%TYPE);

    PROCEDURE Save_Sc_Contact (
        p_Sct_Id          IN     Sc_Contact.Sct_Id%TYPE,
        p_Sct_Phone_Mob   IN     Sc_Contact.Sct_Phone_Mob%TYPE,
        p_Sct_Phone_Num   IN     Sc_Contact.Sct_Phone_Num%TYPE,
        p_Sct_Fax_Num     IN     Sc_Contact.Sct_Fax_Num%TYPE,
        p_Sct_Email       IN     Sc_Contact.Sct_Email%TYPE,
        p_Sct_Note        IN     Sc_Contact.Sct_Note%TYPE,
        p_New_Id             OUT Sc_Contact.Sct_Id%TYPE);

    --#90065
    PROCEDURE Save_Sc_Contact (
        p_Scc_Sc          IN Sc_Change.Scc_Sc%TYPE,
        p_Sct_Phone_Mob   IN Sc_Contact.Sct_Phone_Mob%TYPE,
        p_Sct_Email       IN Sc_Contact.Sct_Email%TYPE);

    PROCEDURE Save_Sc_Feature (
        p_Scf_Id                IN     Sc_Feature.Scf_Id%TYPE,
        p_Scf_Sc                IN     Sc_Feature.Scf_Sc%TYPE,
        p_Scf_Is_Taxpayer       IN     Sc_Feature.Scf_Is_Taxpayer%TYPE DEFAULT NULL,
        p_Scf_Is_Migrant        IN     Sc_Feature.Scf_Is_Migrant%TYPE DEFAULT NULL,
        p_Scf_Is_Pension        IN     Sc_Feature.Scf_Is_Pension%TYPE DEFAULT NULL,
        p_Scf_Is_Intpension     IN     Sc_Feature.Scf_Is_Intpension%TYPE DEFAULT NULL,
        p_Scf_Is_Dead           IN     Sc_Feature.Scf_Is_Jobless%TYPE DEFAULT NULL,
        p_Scf_Is_Jobless        IN     Sc_Feature.Scf_Is_Jobless%TYPE DEFAULT NULL,
        p_Scf_Is_Accident       IN     Sc_Feature.Scf_Is_Accident%TYPE DEFAULT NULL,
        p_Scf_Is_Dasabled       IN     Sc_Feature.Scf_Is_Dasabled%TYPE DEFAULT NULL,
        p_Scf_Is_Singl_Parent   IN     Sc_Feature.Scf_Is_Singl_Parent%TYPE DEFAULT NULL,
        p_Scf_Is_Large_Family   IN     Sc_Feature.Scf_Is_Large_Family%TYPE DEFAULT NULL,
        p_Scf_Is_Low_Income     IN     Sc_Feature.Scf_Is_Low_Income%TYPE DEFAULT NULL,
        p_New_Id                   OUT Sc_Feature.Scf_Id%TYPE);

    PROCEDURE Save_Sc_Feature_Hist (
        p_Scs_Sc           Sc_Feature_Hist.Scs_Sc%TYPE,
        p_Scs_Tp           Sc_Feature_Hist.Scs_Tp%TYPE,
        p_Scs_Scd          Sc_Feature_Hist.Scs_Scd%TYPE,
        p_Scs_Start_Dt     Sc_Feature_Hist.Scs_Start_Dt%TYPE,
        p_Scs_Stop_Dt      Sc_Feature_Hist.Scs_Stop_Dt%TYPE,
        p_Scs_Assign_Dt    Sc_Feature_Hist.Scs_Assign_Dt%TYPE,
        p_Scs_Till_Dt      Sc_Feature_Hist.Scs_Till_Dt%TYPE,
        p_Scs_Dh           Sc_Feature_Hist.Scs_Dh%TYPE,
        p_History_Status   Sc_Feature_Hist.History_Status%TYPE);

    PROCEDURE Save_Sc_Pension (
        p_Scp_Id              IN     Sc_Pension.Scp_Id%TYPE,
        p_Scp_Scd             IN     Sc_Pension.Scp_Scd%TYPE,
        p_Scp_Is_Pension      IN     Sc_Pension.Scp_Is_Pension%TYPE,
        p_Scp_Is_Intpension   IN     Sc_Pension.Scp_Is_Intpension%TYPE,
        p_Scp_Intpension_Dt   IN     Sc_Pension.Scp_Intpension_Dt%TYPE,
        p_Scp_Note            IN     Sc_Pension.Scp_Note%TYPE,
        p_Scp_Pnf_Number      IN     Sc_Pension.Scp_Pnf_Number%TYPE,
        p_Scp_Org             IN     Sc_Pension.Scp_Org%TYPE,
        p_Scp_Pens_Tp         IN     Sc_Pension.Scp_Pens_Tp%TYPE,
        p_Scp_Begin_Dt        IN     Sc_Pension.Scp_Begin_Dt%TYPE,
        p_Scp_End_Dt          IN     Sc_Pension.Scp_End_Dt%TYPE,
        p_Scp_Psn             IN     Sc_Pension.Scp_Psn%TYPE,
        p_Scp_Recalc_Dt       IN     Sc_Pension.Scp_Recalc_Dt%TYPE,
        p_Scp_Pay_Tp          IN     Sc_Pension.Scp_Pay_Tp%TYPE,
        p_Scp_Legal_Act       IN     Sc_Pension.Scp_Legal_Act%TYPE,
        p_Scp_Sc              IN     Sc_Pension.Scp_Sc%TYPE,
        p_Scp_Sum_Pens        IN     Sc_Pension.Scp_Sum_Pens%TYPE,
        p_Scp_Dh              IN     Sc_Pension.Scp_Dh%TYPE,
        p_New_Id                 OUT Sc_Pension.Scp_Id%TYPE);

    PROCEDURE Save_Sc_Disability (
        p_Scy_Sc              IN Sc_Disability.Scy_Sc%TYPE,
        p_Scy_Group           IN Sc_Disability.Scy_Group%TYPE,
        p_Scy_Scd             IN Sc_Disability.Scy_Scd%TYPE,
        p_Scy_Inspection_Dt   IN Sc_Disability.Scy_Inspection_Dt%TYPE,
        p_Scy_Decision_Dt     IN Sc_Disability.Scy_Decision_Dt%TYPE,
        p_Scy_Till_Dt         IN Sc_Disability.Scy_Till_Dt%TYPE,
        p_Scy_Reason          IN Sc_Disability.Scy_Reason%TYPE,
        p_Scy_Start_Dt        IN Sc_Disability.Scy_Start_Dt%TYPE,
        p_Scy_Stop_Dt         IN Sc_Disability.Scy_Stop_Dt%TYPE,
        p_Scy_Dh              IN Sc_Disability.Scy_Dh%TYPE,
        p_History_Status      IN Sc_Disability.History_Status%TYPE);

    FUNCTION Get_Sc_Scf (p_Scf_Sc IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Sc_Scy (p_Scy_Sc IN NUMBER)
        RETURN NUMBER;

    -- info:   оновлення інформації про пільгові категорії особи
    -- params: p_vstr_id - ідентифікатор учасника звернення
    -- note:
    PROCEDURE Save_Sc_Benefit_Category (
        p_Scbc_Id          IN OUT Sc_Benefit_Category.Scbc_Id%TYPE,
        p_Scbc_Sc                 Sc_Benefit_Category.Scbc_Sc%TYPE,
        p_Scbc_Nbc                Sc_Benefit_Category.Scbc_Nbc%TYPE,
        p_Scbc_Start_Dt           Sc_Benefit_Category.Scbc_Start_Dt%TYPE,
        p_Scbc_Stop_Dt            Sc_Benefit_Category.Scbc_Stop_Dt%TYPE,
        p_Scbc_Src                Sc_Benefit_Category.Scbc_Src%TYPE,
        p_Scbc_Create_Dt          Sc_Benefit_Category.Scbc_Create_Dt%TYPE DEFAULT SYSDATE,
        p_Scbc_St                 Sc_Benefit_Category.Scbc_St%TYPE DEFAULT 'A');

    -- info:   оновлення інформації про пільги особи
    -- params:
    -- note:
    PROCEDURE Save_Sc_Benefit_Type (
        p_Scbt_Id          IN OUT Sc_Benefit_Type.Scbt_Id%TYPE,
        p_Scbt_Sc                 Sc_Benefit_Type.Scbt_Sc%TYPE,
        p_Scbt_Nbt                Sc_Benefit_Type.Scbt_Nbt%TYPE,
        p_Scbt_Start_Dt           Sc_Benefit_Type.Scbt_Start_Dt%TYPE,
        p_Scbt_Stop_Dt            Sc_Benefit_Type.Scbt_Stop_Dt%TYPE,
        p_Scbt_Src                Sc_Benefit_Type.Scbt_Src%TYPE,
        p_Scbt_Create_Dt          Sc_Benefit_Type.Scbt_Create_Dt%TYPE DEFAULT SYSDATE,
        p_Scbt_St                 Sc_Benefit_Type.Scbt_St%TYPE DEFAULT 'A',
        p_Scbt_Scbc               Sc_Benefit_Type.Scbt_Scbc%TYPE);

    -- info:   встановлення пільг особі
    -- params:
    -- note:
    PROCEDURE Set_Sc_Benefits (
        p_Scbc_Sc             Sc_Benefit_Category.Scbc_Sc%TYPE,
        p_Scbc_Nbc            Sc_Benefit_Category.Scbc_Nbc%TYPE,
        p_Scbc_Start_Dt       Sc_Benefit_Category.Scbc_Start_Dt%TYPE,
        p_Scbc_Stop_Dt        Sc_Benefit_Category.Scbc_Stop_Dt%TYPE,
        p_Scbc_Src            Sc_Benefit_Category.Scbc_Src%TYPE,
        p_Scbc_Id         OUT Sc_Benefit_Category.Scbc_Id%TYPE);

    --Домогосподарство
    PROCEDURE Save_Sc_Household (
        p_Schh_Id                OUT Sc_Household.Schh_Id%TYPE,
        p_Schh_Sc             IN     Sc_Household.Schh_Sc%TYPE,
        p_Schh_Sca            IN     Sc_Household.Schh_Sca%TYPE,
        p_Schh_Full_Area      IN     Sc_Household.Schh_Full_Area%TYPE,
        p_Schh_Heating_Area   IN     Sc_Household.Schh_Heating_Area%TYPE);

    --Домогосподарство
    PROCEDURE Save_Sc_Household (
        p_Schh_Id                    OUT Sc_Household.Schh_Id%TYPE,
        p_Schh_Sc                 IN     Sc_Household.Schh_Sc%TYPE,
        p_Schh_Scdi               IN     Sc_Household.Schh_Scdi%TYPE,
        p_Schh_Sca                IN     Sc_Household.Schh_Sca%TYPE,
        p_Schh_Scpa               IN     Sc_Household.Schh_Scpa%TYPE,
        p_Schh_Full_Area          IN     Sc_Household.Schh_Full_Area%TYPE,
        p_Schh_Heating_Area       IN     Sc_Household.Schh_Heating_Area%TYPE,
        p_Schh_Pfu_Id             IN     Sc_Household.Schh_Pfu_Id%TYPE,
        p_Schh_Is_Separate_Bill   IN     Sc_Household.Schh_Is_Separate_Bill%TYPE,
        p_Schh_Floor_Cnt          IN     Sc_Household.Schh_Floor_Cnt%TYPE,
        p_Schh_Build_Tp           IN     Sc_Household.Schh_Build_Tp%TYPE,
        p_Schh_Fam_Tp             IN     Sc_Household.Schh_Fam_Tp%TYPE);

    --Зведена інформація по призначенню виплат в ПФУ
    PROCEDURE Save_Sc_Pfu_Pay_Summary (
        p_Scpp_Id                   OUT Sc_Pfu_Pay_Summary.Scpp_Id%TYPE,
        p_Scpp_Sc                IN     Sc_Pfu_Pay_Summary.Scpp_Sc%TYPE, --Ід соціальної картки
        p_Scpp_Pfu_Pd_Id         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE,
        p_Scpp_Pfu_Payment_Tp    IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Payment_Tp%TYPE,
        p_Scpp_Pfu_Pd_Dt         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Dt%TYPE,
        p_Scpp_Pfu_Pd_Start_Dt   IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Start_Dt%TYPE,
        p_Scpp_Pfu_Pd_Stop_Dt    IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Stop_Dt%TYPE,
        p_Scpp_Pfu_Pd_St         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_St%TYPE,
        p_Scpp_Change_Dt         IN     Sc_Pfu_Pay_Summary.Scpp_Change_Dt%TYPE,
        p_Scpp_Sum               IN     Sc_Pfu_Pay_Summary.Scpp_Sum%TYPE,
        p_Scpp_Schh              IN     Sc_Pfu_Pay_Summary.Scpp_Schh%TYPE, --Ід домогосподарства
        p_Scpp_St                IN     Sc_Pfu_Pay_Summary.Scpp_St%TYPE,
        p_Scpp_Pfu_Com_Org       IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Com_Org%TYPE);

    --Зведена інформація по призначенню виплат в ПФУ
    PROCEDURE Save_Sc_Pfu_Pay_Summary (
        p_Scpp_Id                     OUT Sc_Pfu_Pay_Summary.Scpp_Id%TYPE,
        p_Scpp_Sc                  IN     Sc_Pfu_Pay_Summary.Scpp_Sc%TYPE, --Ід соціальної картки
        p_Scpp_Pfu_Pd_Id           IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE,
        p_Scpp_Pfu_Payment_Tp      IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Payment_Tp%TYPE,
        p_Scpp_Pfu_Pd_Dt           IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Dt%TYPE,
        p_Scpp_Pfu_Pd_Start_Dt     IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Start_Dt%TYPE,
        p_Scpp_Pfu_Pd_Stop_Dt      IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Stop_Dt%TYPE,
        p_Scpp_Pfu_Pd_St           IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_St%TYPE,
        p_Scpp_Change_Dt           IN     Sc_Pfu_Pay_Summary.Scpp_Change_Dt%TYPE,
        p_Scpp_Sum                 IN     Sc_Pfu_Pay_Summary.Scpp_Sum%TYPE,
        p_Scpp_Schh                IN     Sc_Pfu_Pay_Summary.Scpp_Schh%TYPE, --Ід домогосподарства
        p_Scpp_St                  IN     Sc_Pfu_Pay_Summary.Scpp_St%TYPE,
        p_Scpp_Pfu_Com_Org         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Com_Org%TYPE,
        p_Scpp_Scdi                IN     Sc_Pfu_Pay_Summary.Scpp_Scdi%TYPE,
        p_Scpp_Income_Amount       IN     Sc_Pfu_Pay_Summary.Scpp_Income_Amount%TYPE,
        p_Scpp_Avg_Income_Amount   IN     Sc_Pfu_Pay_Summary.Scpp_Avg_Income_Amount%TYPE,
        p_Scpp_Pfu_Pc_Num          IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pc_Num%TYPE,
        p_Scpp_Pfu_Pd_Num          IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Num%TYPE,
        p_Scpp_Pfu_Appeal_Dt       IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Appeal_Dt%TYPE,
        p_Scpp_Pfu_Norm_Act        IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Norm_Act%TYPE,
        p_Scpp_Pfu_Scr             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Scr%TYPE,
        p_Scpp_Pfu_Refuse_Reason   IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Refuse_Reason%TYPE,
        p_Scpp_Start_Dt            IN     Sc_Pfu_Pay_Summary.Scpp_Start_Dt%TYPE,
        p_Scpp_Stop_Dt             IN     Sc_Pfu_Pay_Summary.Scpp_Stop_Dt%TYPE);

    --Дані про родину щодо призначеної виплати ПФУ
    PROCEDURE Save_Sc_Scpp_Family (p_Scpf_Id            IN OUT NUMBER,
                                   p_Scpf_Scpp          IN     NUMBER,
                                   p_Scpf_Sc            IN     NUMBER,
                                   p_Scpf_Sc_Main       IN     NUMBER,
                                   p_Scpf_Relation_Tp   IN     VARCHAR2,
                                   p_Scpf_Marital_St    IN     VARCHAR2);

    PROCEDURE Save_Sc_Death (
        p_Sch_Id        IN     Sc_Death.Sch_Id%TYPE,
        p_Sch_Scd       IN     Sc_Death.Sch_Scd%TYPE,
        p_Sch_Dt        IN     Sc_Death.Sch_Dt%TYPE,
        p_Sch_Note      IN     Sc_Death.Sch_Note%TYPE,
        p_Sch_Src       IN     Sc_Death.Sch_Src%TYPE,
        p_Sch_Sc        IN     Sc_Death.Sch_Sc%TYPE,
        p_Sch_Is_Dead   IN     Sc_Death.Sch_Is_Dead%TYPE,
        p_New_Id           OUT Sc_Death.Sch_Id%TYPE);
END P$66749763$TMP;
/
