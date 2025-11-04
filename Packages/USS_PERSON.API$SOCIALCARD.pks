/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SOCIALCARD
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
                             p_Scd_Dh         OUT NUMBER,
                             p_Scd_St      IN     VARCHAR2 DEFAULT '1');

    PROCEDURE Save_Document (p_Sc_Id         IN     NUMBER,
                             p_Ndt_Id        IN     NUMBER,
                             p_Doc_Attrs     IN     t_Doc_Attrs,
                             p_Src_Id        IN     NUMBER,
                             p_Src_Code      IN     VARCHAR2,
                             p_Scd_Note      IN     VARCHAR2,
                             p_Scd_Id           OUT NUMBER,
                             p_Doc_Id        IN OUT NUMBER,
                             p_Dh_Id         IN OUT NUMBER,
                             p_Set_Feature   IN     BOOLEAN DEFAULT FALSE,
                             p_Scd_St        IN     VARCHAR2 DEFAULT '1');

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

    --Дані особи в ПФУ
    PROCEDURE Save_Sc_Pfu_Data_Ident (
        p_Scdi_Id             OUT Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Scdi_Sc          IN     Sc_Pfu_Data_Ident.Scdi_Sc%TYPE DEFAULT NULL,
        p_Scdi_Ip_Unique   IN     Sc_Pfu_Data_Ident.Scdi_Ip_Unique%TYPE DEFAULT NULL,
        p_Scdi_Ip_Pt       IN     Sc_Pfu_Data_Ident.Scdi_Ip_Pt%TYPE DEFAULT NULL,
        p_Scdi_Ln          IN     Sc_Pfu_Data_Ident.Scdi_Ln%TYPE DEFAULT NULL,
        p_Scdi_Fn          IN     Sc_Pfu_Data_Ident.Scdi_Fn%TYPE DEFAULT NULL,
        p_Scdi_Mn          IN     Sc_Pfu_Data_Ident.Scdi_Mn%TYPE DEFAULT NULL,
        p_Scdi_Unzr        IN     Sc_Pfu_Data_Ident.Scdi_Unzr%TYPE DEFAULT NULL,
        p_Scdi_Numident    IN     Sc_Pfu_Data_Ident.Scdi_Numident%TYPE DEFAULT NULL,
        p_Scdi_Doc_Tp      IN     Sc_Pfu_Data_Ident.Scdi_Doc_Tp%TYPE DEFAULT NULL,
        p_Scdi_Doc_Sn      IN     Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE DEFAULT NULL,
        p_Scdi_Nt          IN     Sc_Pfu_Data_Ident.Scdi_Nt%TYPE DEFAULT NULL,
        p_Scdi_Sex         IN     Sc_Pfu_Data_Ident.Scdi_Sex%TYPE DEFAULT NULL,
        p_Scdi_Birthday    IN     Sc_Pfu_Data_Ident.Scdi_Birthday%TYPE DEFAULT NULL,
        p_Scdi_Dd_Dt       IN     Sc_Pfu_Data_Ident.Scdi_Dd_Dt%TYPE DEFAULT NULL,
        p_Rn_Id            IN     Sc_Pfu_Data_Ident.Scdi_Rn%TYPE DEFAULT NULL,
        p_Phone_Mob        IN     Sc_Pfu_Data_Ident.Scdi_Phone_Mob%TYPE DEFAULT NULL,
        p_Phone_Num        IN     Sc_Pfu_Data_Ident.Scdi_Phone_Num%TYPE DEFAULT NULL,
        p_Email            IN     Sc_Pfu_Data_Ident.Scdi_Email%TYPE DEFAULT NULL,
        p_Nrt_Id           IN     Sc_Pfu_Data_Ident.Scdi_Nrt%TYPE DEFAULT NULL,
        p_Ext_Ident        IN     Sc_Pfu_Data_Ident.Scdi_Ext_Ident%TYPE DEFAULT NULL);

    PROCEDURE Save_Sc_Pfu_Address (
        p_Scpa_Id             OUT Sc_Pfu_Address.Scpa_Id%TYPE,
        p_Scpa_Sc          IN     Sc_Pfu_Address.Scpa_Sc%TYPE DEFAULT NULL,
        p_Scpa_Scdi        IN     Sc_Pfu_Address.Scpa_Scdi%TYPE,
        p_Scpa_Tp          IN     Sc_Pfu_Address.Scpa_Tp%TYPE,
        p_Scpa_Kaot_Code   IN     Sc_Pfu_Address.Scpa_Kaot_Code%TYPE,
        p_Scpa_Postcode    IN     Sc_Pfu_Address.Scpa_Postcode%TYPE,
        p_Scpa_City        IN     Sc_Pfu_Address.Scpa_City%TYPE DEFAULT NULL,
        p_Scpa_Street      IN     Sc_Pfu_Address.Scpa_Street%TYPE,
        p_Scpa_Building    IN     Sc_Pfu_Address.Scpa_Building%TYPE,
        p_Scpa_Block       IN     Sc_Pfu_Address.Scpa_Block%TYPE,
        p_Scpa_Apartment   IN     Sc_Pfu_Address.Scpa_Apartment%TYPE,
        p_Scpa_St          IN     Sc_Pfu_Address.Scpa_St%TYPE DEFAULT 'A');

    --Домогосподарство
    PROCEDURE Save_Sc_Household (
        p_Schh_Id                OUT Sc_Household.Schh_Id%TYPE,
        p_Schh_Sc             IN     Sc_Household.Schh_Sc%TYPE,
        p_Schh_Sca            IN     Sc_Household.Schh_Sca%TYPE,
        p_Schh_Full_Area      IN     Sc_Household.Schh_Full_Area%TYPE,
        p_Schh_Heating_Area   IN     Sc_Household.Schh_Heating_Area%TYPE);

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
        p_Schh_Build_Tp           IN     Sc_Household.Schh_Build_Tp%TYPE, /*V_DDN_SCHH_BUILD_TP*/
        p_Schh_Fam_Tp             IN     Sc_Household.Schh_Fam_Tp%TYPE /*V_DDN_SCHH_FAM_TP*/
                                                                      );

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

    PROCEDURE Save_Sc_Pfu_Pay_Summary (
        p_Scpp_Id                       OUT Sc_Pfu_Pay_Summary.Scpp_Id%TYPE,
        p_Scpp_Sc                    IN     Sc_Pfu_Pay_Summary.Scpp_Sc%TYPE, --Ід соціальної картки
        p_Scpp_Pfu_Pd_Id             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE,
        p_Scpp_Pfu_Payment_Tp        IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Payment_Tp%TYPE,
        p_Scpp_Pfu_Pd_Dt             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Dt%TYPE,
        p_Scpp_Pfu_Pd_Start_Dt       IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Start_Dt%TYPE,
        p_Scpp_Pfu_Pd_Stop_Dt        IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Stop_Dt%TYPE,
        p_Scpp_Pfu_Pd_St             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_St%TYPE,
        p_Scpp_Change_Dt             IN     Sc_Pfu_Pay_Summary.Scpp_Change_Dt%TYPE,
        p_Scpp_Sum                   IN     Sc_Pfu_Pay_Summary.Scpp_Sum%TYPE,
        p_Scpp_Schh                  IN     Sc_Pfu_Pay_Summary.Scpp_Schh%TYPE, --Ід домогосподарства
        p_Scpp_St                    IN     Sc_Pfu_Pay_Summary.Scpp_St%TYPE,
        p_Scpp_Pfu_Com_Org           IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Com_Org%TYPE,
        p_Scpp_Scdi                  IN     Sc_Pfu_Pay_Summary.Scpp_Scdi%TYPE,
        p_Scpp_Income_Amount         IN     Sc_Pfu_Pay_Summary.Scpp_Income_Amount%TYPE,
        p_Scpp_Avg_Income_Amount     IN     Sc_Pfu_Pay_Summary.Scpp_Avg_Income_Amount%TYPE,
        p_Scpp_Pfu_Pc_Num            IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pc_Num%TYPE,
        p_Scpp_Pfu_Pd_Num            IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Num%TYPE,
        p_Scpp_Pfu_Appeal_Dt         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Appeal_Dt%TYPE,
        p_Scpp_Pfu_Norm_Act          IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Norm_Act%TYPE, /*V_DDN_SCPP_PFU_NORM_ACT*/
        p_Scpp_Pfu_Scr               IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Scr%TYPE, /*V_DDN_SCPP_PFU_SCR*/
        p_Scpp_Pfu_Refuse_Reason     IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Refuse_Reason%TYPE,
        p_Scpp_Start_Dt              IN     Sc_Pfu_Pay_Summary.Scpp_Start_Dt%TYPE,
        p_Scpp_Stop_Dt               IN     Sc_Pfu_Pay_Summary.Scpp_Stop_Dt%TYPE,
        p_Scpp_Pd_Features           IN     Sc_Pfu_Pay_Summary.Scpp_Pd_Features%TYPE, /*V_DDN_SCPF_PD_FEATURES*/
        p_Scpp_Income_Include_Mark   IN     Sc_Pfu_Pay_Summary.Scpp_Income_Include_Mark%TYPE /*V_DDN_SCPF_INCOME_INCLUDE_MARK*/
                                                                                            );

    --Дані про родину щодо призначеної виплати ПФУ
    PROCEDURE Save_Sc_Scpp_Family (p_Scpf_Id               OUT NUMBER,
                                   p_Scpf_Scpp          IN     NUMBER,
                                   p_Scpf_Sc            IN     NUMBER,
                                   p_Scpf_Sc_Main       IN     NUMBER,
                                   p_Scpf_Relation_Tp   IN     VARCHAR2,
                                   p_Scpf_Marital_St    IN     VARCHAR2);

    PROCEDURE Save_Sc_Scpp_Family (
        p_Scpf_Id                       OUT NUMBER,
        p_Scpf_Scpp                  IN     Sc_Scpp_Family.Scpf_Scpp%TYPE,
        p_Scpf_Sc                    IN     Sc_Scpp_Family.Scpf_Sc%TYPE,
        p_Scpf_Sc_Main               IN     Sc_Scpp_Family.Scpf_Sc_Main%TYPE,
        p_Scpf_Scdi                  IN     Sc_Scpp_Family.Scpf_Scdi%TYPE,
        p_Scpf_Scdi_Main             IN     Sc_Scpp_Family.Scpf_Scdi_Main%TYPE,
        p_Scpf_Relation_Tp           IN     Sc_Scpp_Family.Scpf_Relation_Tp%TYPE, /*V_DDN_SCPF_RELATION_TP*/
        p_Scpf_Marital_St            IN     Sc_Scpp_Family.Scpf_Marital_St%TYPE,
        p_Scpf_Incapacity_Category   IN     Sc_Scpp_Family.Scpf_Incapacity_Category%TYPE, /*V_DDN_SCPF_INCAPACITY_CATEGORY*/
        p_Scpf_Is_Vpo                IN     Sc_Scpp_Family.Scpf_Is_Vpo%TYPE, /*V_DDN_SCPF_IS_VPO*/
        p_Scpf_St                    IN     Sc_Scpp_Family.Scpf_St%TYPE DEFAULT 'A');

    PROCEDURE Save_Sc_Death (
        p_Sch_Id        IN     Sc_Death.Sch_Id%TYPE,
        p_Sch_Scd       IN     Sc_Death.Sch_Scd%TYPE,
        p_Sch_Dt        IN     Sc_Death.Sch_Dt%TYPE,
        p_Sch_Note      IN     Sc_Death.Sch_Note%TYPE,
        p_Sch_Src       IN     Sc_Death.Sch_Src%TYPE,
        p_Sch_Sc        IN     Sc_Death.Sch_Sc%TYPE,
        p_Sch_Is_Dead   IN     Sc_Death.Sch_Is_Dead%TYPE,
        p_New_Id           OUT Sc_Death.Sch_Id%TYPE);

    PROCEDURE Save_Sc_Benefit_Docs (
        p_scbd_scbc   IN     Sc_Benefit_Docs.scbd_scbc%TYPE,
        p_scbd_scd    IN     Sc_Benefit_Docs.scbd_scd%TYPE,
        p_scbd_st     IN     Sc_Benefit_Docs.scbd_st%TYPE,
        p_New_Id         OUT Sc_Benefit_Docs.SCBD_ID%TYPE);
END Api$socialcard;
/


GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SOCIALCARD
IS
    PROCEDURE Write_Sc_Log (p_Scl_Sc        Sc_Log.Scl_Sc%TYPE,
                            p_Scl_Hs        Sc_Log.Scl_Hs%TYPE,
                            p_Scl_St        Sc_Log.Scl_St%TYPE,
                            p_Scl_Message   Sc_Log.Scl_Message%TYPE,
                            p_Scl_St_Old    Sc_Log.Scl_Old_St%TYPE,
                            p_Scl_Tp        Sc_Log.Scl_Tp%TYPE:= 'SYS')
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        l_Hs := NVL (p_Scl_Hs, Tools.Gethistsession);

        INSERT INTO Sc_Log (Scl_Id,
                            Scl_Sc,
                            Scl_Hs,
                            Scl_St,
                            Scl_Message,
                            Scl_Old_St,
                            Scl_Tp)
             VALUES (0,
                     p_Scl_Sc,
                     l_Hs,
                     p_Scl_St,
                     p_Scl_Message,
                     p_Scl_St_Old,
                     NVL (p_Scl_Tp, 'SYS'));
    END;


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
                                   p_Persons         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Search_Sc_By_Params (p_Inn          => p_Inn,
                             p_Ndt_Id       => p_Ndt_Id,
                             p_Doc_Num      => p_Doc_Num,
                             p_Fn           => p_Fn,
                             p_Ln           => p_Ln,
                             p_Mn           => p_Mn,
                             p_Esr_Num      => p_Esr_Num,
                             p_Gender       => p_Gender,
                             p_Show_Modal   => p_Show_Modal,
                             p_Found_Cnt    => p_Found_Cnt);

        -- тип r_Search_Sc має відповідати p_Persons
        OPEN p_Persons FOR
            SELECT t.*,
                   Scd_Seria || Scd_Number     AS App_Doc_Num,
                   Ndt_Id                      AS App_Ndt,
                   Ndt_Name_Short              AS App_Ndt_Name
              FROM (SELECT Sc_Id
                               AS App_Sc,
                           --РНОКПП
                            (SELECT Scd_Number
                               FROM Sc_Document
                              WHERE     Scd_Sc = Sc_Id
                                    AND Scd_Ndt = 5
                                    AND (   SYSDATE >=
                                            Scd_Start_Dt
                                         OR Scd_Start_Dt
                                                IS NULL)
                                    AND (   SYSDATE <=
                                            Scd_Stop_Dt
                                         OR Scd_Stop_Dt
                                                IS NULL)
                                    AND Scd_St IN ('1', 'A')
                              FETCH FIRST ROW ONLY)
                               AS App_Inn,
                           --Документ
                           --#87755
                           /*Coalesce((SELECT Scd_Id
                                                                                              FROM Sc_Document
                                                                                             WHERE Scd_Sc = Sc_Id
                                                                                                   AND Scd_Ndt = p_Ndt_Id
                                                                                                   AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
                                                                                                   AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                                                                                                   AND Scd_St IN ('1', 'A')
                                                                                             FETCH FIRST ROW ONLY),
                                                                                            (SELECT Scd_Id
                                                                                               FROM Sc_Document
                                                                                              WHERE Scd_Sc = Sc_Id
                                                                                                    AND Scd_Ndt = 6
                                                                                                    AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
                                                                                                    AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                                                                                                    AND Scd_St IN ('1', 'A')
                                                                                              FETCH FIRST ROW ONLY),
                                                                                            (SELECT Scd_Id
                                                                                               FROM Sc_Document
                                                                                              WHERE Scd_Sc = Sc_Id
                                                                                                    AND Scd_Ndt = 7
                                                                                                    AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
                                                                                                    AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                                                                                                    AND Scd_St IN ('1', 'A')
                                                                                              FETCH FIRST ROW ONLY),
                                                                                            -2) AS App_Scd,*/
                           Sci_Fn
                               AS App_Fn,
                           Sci_Ln
                               AS App_Ln,
                           Sci_Mn
                               AS App_Mn,
                           Sc_Unique
                               AS App_Esr_Num,
                           Sci_Gender
                               AS App_Gender,
                           g.Dic_Sname
                               AS App_Gender_Name,
                           --Pc_Num AS Doc_Eos,
                           Uss_Esr.Api$person2esr.Get_Eos_By_Sc (Sc_Id, 1)
                               AS Doc_Eos,
                           Scb_Dt
                               AS Birth_Dt
                      FROM Socialcard            s,
                           Sc_Change,
                           Sc_Identity,
                           Sc_Birth,
                           Tmp_Work_Ids,
                           --Uss_Esr.v_Personalcase,
                           Uss_Ndi.v_Ddn_Gender  g
                     WHERE     Scc_Sc = Sc_Id
                           AND Sc_Scc = Scc_Id
                           AND Scc_Sci = Sci_Id
                           AND Sc_Id = x_Id
                           AND Scc_Scb = Scb_Id(+)
                           --AND s.Sc_Id = Pc_Sc(+)
                           AND Sci_Gender = g.Dic_Value(+)) t
                   --#87755
                   -- Необхідно, у випадку, якщо в знайденої по пошуку особи в СРКО наявні документи з категорією 13,
                   -- то в таблицю з результатами пошуку заповнювати поля "Тип документа" і "Серія та номер" щодо всіх документів,
                   -- які у статусі "Актуальний".
                   LEFT JOIN Sc_Document
                   JOIN Uss_Ndi.v_Ndi_Document_Type
                       ON (Scd_Ndt = Ndt_Id AND Ndt_Ndc = 13)
                       ON (    App_Sc = Scd_Sc
                           AND (   SYSDATE >= Scd_Start_Dt
                                OR Scd_Start_Dt IS NULL)
                           AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                           AND Scd_St IN ('1', 'A'))-- bogdan 20230526 переписав на джоїни бо не розумію ваших плюсиків
                                                    /*,
                                                          Sc_Document,
                                                          Uss_Ndi.v_Ndi_Document_Type
                                                    WHERE App_Sc = Scd_Sc(+)
                                                      AND Scd_Ndt = Ndt_Id(+)
                                                      --#87755
                                                      -- Необхідно, у випадку, якщо в знайденої по пошуку особи в СРКО наявні документи з категорією 13,
                                                      -- то в таблицю з результатами пошуку заповнювати поля "Тип документа" і "Серія та номер" щодо всіх документів,
                                                      -- які у статусі "Актуальний".
                                                      AND (SYSDATE >= Scd_Start_Dt(+) OR Scd_Start_Dt(+) IS NULL)
                                                      AND (SYSDATE <= Scd_Stop_Dt(+) OR Scd_Stop_Dt(+) IS NULL)
                                                      AND ndt_ndc(+) = 13*/
                                                    ;
    END;

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
                                   p_mode         IN     NUMBER DEFAULT 0) -- 0 - весь пошук, 1 - пошук без піб
    IS
        l_Cnt   INTEGER := 0;
    BEGIN
        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        p_Show_Modal := 0;

        IF p_Esr_Num IS NOT NULL
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Sc_Id
                  FROM Socialcard
                 WHERE Sc_Unique = p_Esr_Num;

            l_Cnt := SQL%ROWCOUNT;
        END IF;

        IF l_Cnt < 1 AND p_Inn IS NOT NULL
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Sc_Id
                  FROM Socialcard, Sc_Document
                 WHERE     Scd_Sc = Sc_Id
                       AND Scd_Ndt IN (5)
                       AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
                       AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                       AND Scd_St IN ('1', 'A')
                       AND Scd_Number = p_Inn;

            l_Cnt := SQL%ROWCOUNT;
        END IF;

        IF l_Cnt < 1 AND p_Doc_Num IS NOT NULL
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Sc_Id
                  FROM Socialcard, Sc_Document
                 WHERE     Scd_Sc = Sc_Id
                       AND (SYSDATE >= Scd_Start_Dt OR Scd_Start_Dt IS NULL)
                       AND (SYSDATE <= Scd_Stop_Dt OR Scd_Stop_Dt IS NULL)
                       AND Scd_St IN ('1', 'A')
                       --AND Scd_Seria || Scd_Number = REPLACE(p_Doc_Num, ' ', '')
                       AND UPPER (
                               REPLACE (
                                   REPLACE (Scd_Seria || Scd_Number, '-', ''),
                                   ' ',
                                   '')) =
                           UPPER (
                               REPLACE (REPLACE (p_Doc_Num, '-', ''),
                                        ' ',
                                        ''))               --#79033 2022.08.03
                       AND Scd_Ndt = NVL (p_Ndt_Id, Scd_Ndt);

            l_Cnt := SQL%ROWCOUNT;
        END IF;

        IF     l_Cnt < 1
           AND p_Fn IS NOT NULL
           AND p_Ln IS NOT NULL
           -- AND p_Mn IS NOT NULL -- #80747
           --AND p_Gender IS NOT NULL
           AND p_mode IN (0)
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Sc_Id
                  FROM Socialcard, Sc_Change, Sc_Identity
                 WHERE     Scc_Sc = Sc_Id
                       AND Sc_Scc = Scc_Id
                       AND Scc_Sci = Sci_Id
                       AND Sci_Fn = UPPER (p_Fn)
                       AND Sci_Ln = UPPER (p_Ln)
                       AND Sci_Mn = UPPER (p_Mn)/*AND Sci_Gender = p_Gender*/
                                                ;

            l_Cnt := SQL%ROWCOUNT;
            p_Show_Modal := CASE WHEN l_Cnt > 0 THEN 1 ELSE 0 END;
        END IF;

        p_Found_Cnt := l_Cnt;

        IF (l_Cnt > 1)
        THEN
            p_Show_Modal := 1;
        END IF;
    END;

    -- #86318: пошук ЕОС по соц. картці
    PROCEDURE Search_Pc_By_Params (p_Inn          IN     VARCHAR2,
                                   p_Fn           IN     VARCHAR2,
                                   p_Ln           IN     VARCHAR2,
                                   p_Mn           IN     VARCHAR2,
                                   p_Found_Cnt       OUT INTEGER,
                                   p_Show_Modal      OUT NUMBER,
                                   p_Persons         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Search_Sc_By_Params (p_Inn          => p_Inn,
                             p_Ndt_Id       => NULL,
                             p_Doc_Num      => NULL,
                             p_Fn           => p_Fn,
                             p_Ln           => p_Ln,
                             p_Mn           => p_Mn,
                             p_Esr_Num      => NULL,
                             p_Gender       => NULL,
                             p_Show_Modal   => p_Show_Modal,
                             p_Found_Cnt    => p_Found_Cnt);

        OPEN p_Persons FOR
            SELECT Pc_Id,
                   --РНОКПП
                    (SELECT Scd_Number
                       FROM Sc_Document
                      WHERE     Scd_Sc = Sc_Id
                            AND Scd_Ndt = 5
                            AND (   SYSDATE >= Scd_Start_Dt
                                 OR Scd_Start_Dt IS NULL)
                            AND (   SYSDATE <= Scd_Stop_Dt
                                 OR Scd_Stop_Dt IS NULL)
                            AND Scd_St IN ('1', 'A')
                      FETCH FIRST ROW ONLY)    AS Pc_Numident,
                   Sci_Fn                      AS Pc_Fn,
                   Sci_Ln                      AS Pc_Ln,
                   Sci_Mn                      AS Pc_Mn,
                   Sc_Unique                   AS Pc_Esr_Num,
                   Sci_Gender                  AS Pc_Gender,
                   g.Dic_Sname                 AS Pc_Gender_Name,
                   Pc_Num
              FROM Socialcard            s,
                   Sc_Change,
                   Sc_Identity,
                   Tmp_Work_Ids,
                   Uss_Esr.v_Personalcase,
                   Uss_Ndi.v_Ddn_Gender  g
             WHERE     Scc_Sc = Sc_Id
                   AND Sc_Scc = Scc_Id
                   AND Scc_Sci = Sci_Id
                   AND Sc_Id = x_Id
                   AND s.Sc_Id = Pc_Sc(+)
                   AND Sci_Gender = g.Dic_Value(+);
    END;

    PROCEDURE Get_Sc_Documents (p_Sc_Id           DECIMAL,
                                p_Ndc_Id          NUMBER DEFAULT NULL,
                                p_Documents   OUT SYS_REFCURSOR)
    IS
    BEGIN
        DELETE FROM Tmp_Work_Ids
              WHERE 1 = 1;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Scd_Dh
              FROM Socialcard  s
                   JOIN Sc_Identity Si ON s.Sc_Id = Si.Sci_Sc
                   JOIN Sc_Document Sc ON Si.Sci_Sc = Sc.Scd_Sc
                   JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                       ON     Ndt.Ndt_Id = Sc.Scd_Ndt
                          AND Ndt.Ndt_Ndc = NVL (p_Ndc_Id, Ndt.Ndt_Ndc)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND Scd_St IN ('1', 'A')
                   AND (Scd_Start_Dt <= SYSDATE OR Scd_Start_Dt IS NULL)
                   AND (Scd_Stop_Dt >= SYSDATE OR Scd_Stop_Dt IS NULL)
                   AND Scd_Doc IS NOT NULL;

        OPEN p_Documents FOR
            SELECT DISTINCT
                   Scd_Sc
                       AS App_Sc,
                   Si.Sci_Ln || ' ' || Si.Sci_Fn || ' ' || Si.Sci_Mn
                       AS Apd_App_Pib,
                   Scd_Ndt
                       AS Apd_Ndt,
                   Ndt.Ndt_Name_Short
                       AS Apd_Ndt_Name,
                   Scd_Doc
                       AS Apd_Doc,
                   --серія та номер документа
                   -- #83402
                   NVL (
                       (SELECT MAX (a.Da_Val_String)
                          FROM Uss_Doc.v_Doc_Attributes  a
                               JOIN Uss_Doc.v_Doc_Attr2hist h
                                   ON (h.Da2h_Da = a.Da_Id)
                               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                   ON     a.Da_Nda = n.Nda_Id
                                      AND n.Nda_Class = 'DSN'
                         WHERE h.Da2h_Dh = Sc.Scd_Dh),
                       (SELECT (a.Da_Val_Int)
                          FROM Uss_Doc.v_Doc_Attributes  a
                               JOIN Uss_Doc.v_Doc_Attr2hist h
                                   ON (h.Da2h_Da = a.Da_Id)
                               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                   ON     a.Da_Nda = n.Nda_Id
                                      AND n.Nda_Id = 1112
                         WHERE     h.Da2h_Dh = Sc.Scd_Dh
                               AND Sc.Scd_Ndt = 730))
                       AS Apd_Serial,
                   NVL (Scd_Dh,
                        Uss_Doc.Api$documents.Get_Last_Doc_Hist (Scd_Doc))
                       AS Apd_Dh,
                   Ndt.Ndt_Is_Vt_Visible
                       AS Is_Shown
              FROM Socialcard  s
                   JOIN Sc_Change c ON s.Sc_Scc = c.Scc_Id
                   JOIN Sc_Identity Si ON c.Scc_Sci = Si.Sci_Id
                   JOIN Sc_Document Sc ON s.Sc_Id = Sc.Scd_Sc
                   JOIN Tmp_Work_Ids ON Scd_Dh = x_Id
                   JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                       ON Ndt.Ndt_Id = Sc.Scd_Ndt
             WHERE     s.Sc_Id = p_Sc_Id
                   AND Scd_St IN ('1', 'A')
                   AND (Scd_Start_Dt <= SYSDATE OR Scd_Start_Dt IS NULL)
                   AND (Scd_Stop_Dt >= SYSDATE OR Scd_Stop_Dt IS NULL)
                   AND Scd_Doc IS NOT NULL;
    END;

    PROCEDURE Example_Serach_Sc
    IS
        l_Found_Cnt    INTEGER;
        l_Show_Modal   INTEGER;
        l_Row          r_Search_Sc;
        l_Persons      SYS_REFCURSOR;
    BEGIN
        Search_Sc_By_Params (p_Inn          => '1934700973',
                             p_Ndt_Id       => NULL,
                             p_Doc_Num      => '',
                             p_Fn           => '',
                             p_Ln           => '',
                             p_Mn           => '',
                             p_Esr_Num      => '',
                             p_Gender       => '',
                             p_Found_Cnt    => l_Found_Cnt,
                             p_Show_Modal   => l_Show_Modal,
                             p_Persons      => l_Persons);

        DBMS_OUTPUT.Put_Line ('found = ' || l_Found_Cnt);

        LOOP
            FETCH l_Persons INTO l_Row;

            EXIT WHEN l_Persons%NOTFOUND;

            DBMS_OUTPUT.Put_Line (
                   'i_sc='
                || l_Row.app_Sc
                || '; i_inn='
                || l_Row.app_Inn
                || '; i_doc_num='
                || l_Row.app_Doc_Num
                || '; i_fn='
                || l_Row.app_Fn
                || '; i_ln='
                || l_Row.app_Ln
                || '; i_mn='
                || l_Row.app_Mn
                || '; i_esr_num='
                || l_Row.app_Esr_Num
                || '; i_gender='
                || l_Row.app_Gender);
        END LOOP;
    END;

    PROCEDURE Init_Sc_Info (p_Sc_Id Socialcard.Sc_Id%TYPE)
    IS
    BEGIN
        DELETE FROM Uss_Person.Sc_Info
              WHERE Sco_Id = p_Sc_Id;

        INSERT INTO Uss_Person.Sc_Info (Sco_Id,
                                        Sco_Fn,
                                        Sco_Mn,
                                        Sco_Ln,
                                        Sco_Nationality,
                                        Sco_Gender,
                                        Sco_Birth_Dt,
                                        Sco_Pasp_Seria,
                                        Sco_Pasp_Number,
                                        Sco_Status,
                                        Sco_Numident,
                                        Sco_Mondify_Dt,
                                        Sco_Unique)
            WITH
                Pasp
                AS
                    (SELECT /*+ materialize*/
                            Scd.*
                       FROM (SELECT ROW_NUMBER ()
                                        OVER (
                                            ORDER BY
                                                DECODE (Ndt.Ndt_Uniq_Group,
                                                        'PASP', 1,
                                                        'BRCR', 2,
                                                        'OVRP', 3,
                                                        9),
                                                Ndt.Ndt_Sc_Upd_Priority)
                                        AS Rn,
                                    Scd.*
                               FROM Sc_Document  Scd
                                    JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                                        ON     Ndt.Ndt_Id = Scd.Scd_Ndt
                                           AND Ndt.Ndt_Ndc = 13
                              WHERE Scd.Scd_St = '1' AND Scd.Scd_Sc = p_Sc_Id)
                            Scd
                      WHERE Scd.Rn = 1)
            SELECT c.Sc_Id,
                   --ПІБ
                   Sci_Fn
                       AS Fn_Name,
                   Sci_Mn
                       AS Mn_Name,
                   Sci_Ln
                       AS Ln_Name,
                   --Національність
                    (SELECT n.Dic_Name
                       FROM Uss_Ndi.v_Ddn_Nationality n
                      WHERE n.Dic_Value = i.Sci_Nationality)
                       AS Nationality,
                   --Стать
                    (SELECT g.Dic_Name
                       FROM Uss_Ndi.v_Ddn_Gender g
                      WHERE g.Dic_Value = i.Sci_Gender)
                       AS Gender,
                   --Дата народження
                    (SELECT b.Scb_Dt
                       FROM Uss_Person.Sc_Birth b
                      WHERE b.Scb_Id = Cc.Scc_Scb)
                       AS Birth_Dt,
                   --Серія паспорта
                   (SELECT Scd_Seria FROM Pasp)
                       AS Pasp_Seria,
                   --Номер паспорта
                   (SELECT Scd_Number FROM Pasp)
                       AS Pasp_Number,
                   --Статус картки
                   s.Dic_Name
                       AS St,
                   --ІПН
                    (  SELECT d.Scd_Number
                         FROM Uss_Person.Sc_Document d
                        WHERE     d.Scd_Sc = c.Sc_Id
                              AND d.Scd_St = '1'
                              AND d.Scd_Ndt = 5
                     ORDER BY d.Scd_Id DESC
                        FETCH FIRST ROW ONLY)
                       AS Numident,
                   SYSDATE,
                   c.Sc_Unique
              FROM Uss_Person.Socialcard  c
                   JOIN Uss_Person.Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Uss_Person.Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
                   JOIN Uss_Ndi.v_Ddn_Sc_St s ON c.Sc_St = s.Dic_Value
             WHERE c.Sc_Id = p_Sc_Id;
    END;

    PROCEDURE Update_Sc_Info (
        p_Sco_Id            IN Sc_Info.Sco_Id%TYPE,
        p_Sco_Numident      IN Sc_Info.Sco_Numident%TYPE,
        p_Sco_Pasp_Seria    IN Sc_Info.Sco_Pasp_Seria%TYPE,
        p_Sco_Pasp_Number   IN Sc_Info.Sco_Pasp_Number%TYPE,
        p_Sco_Birth_Dt      IN Sc_Info.Sco_Birth_Dt%TYPE,
        p_Sco_Fn            IN Sc_Info.Sco_Fn%TYPE,
        p_Sco_Mn            IN Sc_Info.Sco_Mn%TYPE,
        p_Sco_Ln            IN Sc_Info.Sco_Ln%TYPE)
    IS
    BEGIN
        UPDATE Uss_Person.Sc_Info i
           SET i.Sco_Numident = NVL (p_Sco_Numident, i.Sco_Numident),
               i.Sco_Pasp_Seria =
                   NVL (
                       p_Sco_Pasp_Seria,
                       --Оставляем старую серию только в случае, если новые номер паспорта пустой
                       CASE
                           WHEN p_Sco_Pasp_Number IS NULL
                           THEN
                               i.Sco_Pasp_Seria
                       END),
               i.Sco_Pasp_Number = NVL (p_Sco_Pasp_Number, i.Sco_Pasp_Number),
               i.Sco_Birth_Dt = NVL (p_Sco_Birth_Dt, i.Sco_Birth_Dt),
               i.Sco_Fn = NVL (p_Sco_Fn, i.Sco_Fn),
               i.Sco_Mn = NVL (p_Sco_Mn, i.Sco_Mn),
               i.Sco_Ln = NVL (p_Sco_Ln, i.Sco_Ln)
         WHERE i.Sco_Id = p_Sco_Id;
    END;

    PROCEDURE Register_Temporary_Card (p_Inn        IN     VARCHAR2,
                                       p_Ndt_Id     IN     VARCHAR2,
                                       p_Doc_Num    IN     VARCHAR2,
                                       p_Fn         IN     VARCHAR2,
                                       p_Ln         IN     VARCHAR2,
                                       p_Mn         IN     VARCHAR2,
                                       p_Esr_Num    IN     VARCHAR2,
                                       p_Gender     IN     VARCHAR2,
                                       p_Birth_Dt   IN     DATE,
                                       p_Mode       IN     NUMBER DEFAULT 0, -- 0 - якщо не знайдено жодного, 1 - при виборі вручну, 2 - без дати нарождення
                                       p_Sc_Id         OUT NUMBER)
    IS
        l_Found_Cnt    INTEGER;
        l_Show_Modal   INTEGER;
        l_Persons      SYS_REFCURSOR;
        l_Sc_Id        Socialcard.Sc_Id%TYPE;
        l_Scc_Id       Sc_Change.Scc_Id%TYPE;
        l_Sci_Id       Sc_Identity.Sci_Id%TYPE;
        l_Scb_Id       Sc_Birth.Scb_Id%TYPE;
        l_Doc_Ser      Sc_Document.Scd_Seria%TYPE;
        l_Doc_Num      Sc_Document.Scd_Number%TYPE;
    BEGIN
        Api$socialcard.Search_Sc_By_Params (
            p_Inn          => p_Inn,
            p_Ndt_Id       => p_Ndt_Id,
            p_Doc_Num      => p_Doc_Num,
            p_Fn           => UPPER (p_Fn),
            p_Ln           => UPPER (p_Ln),
            p_Mn           => UPPER (p_Mn),
            p_Esr_Num      => p_Esr_Num,
            p_Gender       => p_Gender,
            p_Found_Cnt    => l_Found_Cnt,
            p_Show_Modal   => l_Show_Modal,
            --p_Persons    => l_Persons
            p_mode         => CASE WHEN p_mode = 1 THEN 1 ELSE 0 END);

        IF l_Found_Cnt > 0
        --AND p_Mode != 1 -- #103571
        THEN
            Raise_Application_Error (
                -20000,
                   'По ідентифікаційним даним занайдено '
                || l_Found_Cnt
                || ' осіб - оберіть необхідну через функцію пошуку особи!');
        END IF;

        IF p_Ln IS NULL OR p_Fn IS NULL
        /*OR p_Mn IS NULL*/
        THEN
            -- #80747
            Raise_Application_Error (
                -20000,
                'Для створення тимчасової картки в ЄСР потрібно вказати повний ПІБ особи!');
        END IF;

        IF p_Ndt_Id IS NULL OR p_Doc_Num IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'Для створення тимчасової картки в ЄСР потрібно вказати тип ідентифікаційного документу та заповнити поле Серія та Номер!');
        END IF;

        IF p_Gender IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'Для створення тимчасової картки в ЄСР потрібно вказати стать особи!');
        END IF;

        IF p_Birth_Dt IS NULL AND p_Mode != 2
        THEN
            Raise_Application_Error (
                -20000,
                'Для створення тимчасової картки в ЄСР потрібно завести для особи документ типу "Свідоцтво про народження" та вказати параметр Дата народження!');
        END IF;

        INSERT INTO Socialcard (Sc_Id,
                                Sc_Unique,
                                Sc_Create_Dt,
                                Sc_Scc,
                                Sc_Src,
                                Sc_St)
             VALUES (0,
                     NULL,
                     SYSDATE,
                     NULL,
                     '35',
                     '4')
          RETURNING Sc_Id
               INTO l_Sc_Id;

        INSERT INTO Sc_Identity (Sci_Id,
                                 Sci_Sc,
                                 Sci_Fn,
                                 Sci_Ln,
                                 Sci_Mn,
                                 Sci_Gender,
                                 Sci_Nationality)
             VALUES (0,
                     l_Sc_Id,
                     UPPER (p_Fn),
                     UPPER (p_Ln),
                     UPPER (p_Mn),
                     p_Gender,
                     '1')
             RETURN Sci_Id
               INTO l_Sci_Id;

        INSERT INTO Uss_Person.Sc_Birth (Scb_Id,
                                         Scb_Sc,
                                         Scb_Sca,
                                         Scb_Scd,
                                         Scb_Dt,
                                         Scb_Note,
                                         Scb_Src,
                                         Scb_Ln)
             VALUES (0,
                     l_Sc_Id,
                     -1,
                     -1,
                     p_Birth_Dt,
                     NULL,
                     '35',
                     p_Ln)
             RETURN Scb_Id
               INTO l_Scb_Id;

        INSERT INTO Uss_Person.Sc_Change (Scc_Id,
                                          Scc_Sc,
                                          Scc_Create_Dt,
                                          Scc_Src,
                                          Scc_Sct,
                                          Scc_Sci,
                                          Scc_Scb,
                                          Scc_Sca,
                                          Scc_Sch,
                                          Scc_Scp,
                                          Scc_Src_Dt)
             VALUES (0,
                     l_Sc_Id,
                     SYSDATE,
                     '35',
                     -1,
                     l_Sci_Id,
                     l_Scb_Id,
                     -1,
                     -1,
                     -1,
                     SYSDATE)
             RETURN Scc_Id
               INTO l_Scc_Id;

        l_Doc_Num := p_Doc_Num;
        Split_Doc_Number (p_Ndt_Id       => p_Ndt_Id,
                          p_Doc_Number   => l_Doc_Num,
                          p_Doc_Serial   => l_Doc_Ser);

        INSERT INTO Uss_Person.Sc_Document (Scd_Id,
                                            Scd_Sc,
                                            Scd_Name,
                                            Scd_Seria,
                                            Scd_Number,
                                            Scd_Issued_Dt,
                                            Scd_Issued_Who,
                                            Scd_Start_Dt,
                                            Scd_Stop_Dt,
                                            Scd_St,
                                            Scd_Src,
                                            Scd_Note,
                                            Scd_Ndt,
                                            Scd_Doc,
                                            Scd_Dh)
                 VALUES (
                            0,
                            l_Sc_Id,
                            NULL,
                            l_Doc_Ser,
                            l_Doc_Num,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            '1',
                            '35',
                            'Створено із звернення громадянина з системи ЄІССС: ЄСП',
                            p_Ndt_Id,
                            NULL,
                            NULL);

        INSERT INTO Uss_Person.Sc_Feature (Scf_Id, Scf_Sc)
             VALUES (0, l_Sc_Id);

        UPDATE Socialcard
           SET Sc_Scc = l_Scc_Id, Sc_Unique = 'T' || l_Sc_Id
         WHERE Sc_Id = l_Sc_Id;

        p_Sc_Id := l_Sc_Id;
    END;

    PROCEDURE Save_Socialcard (
        p_Sc_Id          IN     Socialcard.Sc_Id%TYPE,
        p_Sc_Unique      IN     Socialcard.Sc_Unique%TYPE,
        p_Sc_Create_Dt   IN     Socialcard.Sc_Create_Dt%TYPE,
        p_Sc_Scc         IN     Socialcard.Sc_Scc%TYPE,
        p_Sc_Src         IN     Socialcard.Sc_Src%TYPE,
        p_Sc_St          IN     Socialcard.Sc_St%TYPE,
        p_New_Id            OUT Socialcard.Sc_Id%TYPE)
    IS
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            INSERT INTO Socialcard (Sc_Id,
                                    Sc_Unique,
                                    Sc_Create_Dt,
                                    Sc_Scc,
                                    Sc_Src,
                                    Sc_St)
                 VALUES (0,
                         p_Sc_Unique,
                         p_Sc_Create_Dt,
                         p_Sc_Scc,
                         p_Sc_Src,
                         p_Sc_St)
              RETURNING Sc_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Sc_Id;

            UPDATE Socialcard c
               SET c.Sc_Unique = NVL (p_Sc_Unique, c.Sc_Unique),
                   c.Sc_Scc = NVL (p_Sc_Scc, c.Sc_Scc),
                   c.Sc_Src = NVL (p_Sc_Src, c.Sc_Src),
                   c.Sc_St = NVL (p_Sc_St, c.Sc_St)
             WHERE c.Sc_Id = p_Sc_Id;
        END IF;
    END;

    PROCEDURE Save_Sc_Identity (
        p_Sci_Id            IN     Sc_Identity.Sci_Id%TYPE,
        p_Sci_Sc            IN     Sc_Identity.Sci_Sc%TYPE,
        p_Sci_Fn            IN     Sc_Identity.Sci_Fn%TYPE,
        p_Sci_Ln            IN     Sc_Identity.Sci_Ln%TYPE,
        p_Sci_Mn            IN     Sc_Identity.Sci_Mn%TYPE,
        p_Sci_Gender        IN     Sc_Identity.Sci_Gender%TYPE,
        p_Sci_Nationality   IN     Sc_Identity.Sci_Nationality%TYPE,
        p_New_Id               OUT Sc_Identity.Sci_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Identity (Sci_Id,
                                 Sci_Sc,
                                 Sci_Fn,
                                 Sci_Ln,
                                 Sci_Mn,
                                 Sci_Gender,
                                 Sci_Nationality)
             VALUES (0,
                     p_Sci_Sc,
                     p_Sci_Fn,
                     p_Sci_Ln,
                     p_Sci_Mn,
                     p_Sci_Gender,
                     p_Sci_Nationality)
          RETURNING Sci_Id
               INTO p_New_Id;
    END;

    PROCEDURE Save_Sc_Birh (p_Scb_Id     IN     Sc_Birth.Scb_Id%TYPE,
                            p_Scb_Sc     IN     Sc_Birth.Scb_Sc%TYPE,
                            p_Scb_Sca    IN     Sc_Birth.Scb_Sca%TYPE,
                            p_Scb_Scd    IN     Sc_Birth.Scb_Scd%TYPE,
                            p_Scb_Dt     IN     Sc_Birth.Scb_Dt%TYPE,
                            p_Scb_Note   IN     Sc_Birth.Scb_Note%TYPE,
                            p_Scb_Src    IN     Sc_Birth.Scb_Src%TYPE,
                            p_Scb_Ln     IN     Sc_Birth.Scb_Ln%TYPE,
                            p_New_Id        OUT Sc_Birth.Scb_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Birth (Scb_Id,
                              Scb_Sc,
                              Scb_Sca,
                              Scb_Scd,
                              Scb_Dt,
                              Scb_Note,
                              Scb_Src,
                              Scb_Ln)
             VALUES (0,
                     p_Scb_Sc,
                     p_Scb_Sca,
                     p_Scb_Scd,
                     p_Scb_Dt,
                     p_Scb_Note,
                     p_Scb_Src,
                     p_Scb_Ln)
          RETURNING Scb_Id
               INTO p_New_Id;
    END;

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
        p_New_Id             OUT Sc_Change.Scc_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Change (Scc_Id,
                               Scc_Sc,
                               Scc_Create_Dt,
                               Scc_Src,
                               Scc_Sct,
                               Scc_Sci,
                               Scc_Scb,
                               Scc_Sca,
                               Scc_Sch,
                               Scc_Scp,
                               Scc_Src_Dt)
             VALUES (0,
                     p_Scc_Sc,
                     p_Scc_Create_Dt,
                     p_Scc_Src,
                     NVL (p_Scc_Sct, -1),
                     p_Scc_Sci,
                     NVL (p_Scc_Scb, -1),
                     NVL (p_Scc_Sca, -1),
                     NVL (p_Scc_Sch, -1),
                     NVL (p_Scc_Scp, -1),
                     p_Scc_Src_Dt)
          RETURNING Scc_Id
               INTO p_New_Id;
    END;

    PROCEDURE Set_Sc_Scc (p_Sc_Id    Socialcard.Sc_Id%TYPE,
                          p_Sc_Scc   Socialcard.Sc_Scc%TYPE)
    IS
    BEGIN
        UPDATE Socialcard c
           SET c.Sc_Scc = p_Sc_Scc
         WHERE c.Sc_Id = p_Sc_Id;
    END;

    PROCEDURE Add_Doc_Attr (p_Doc_Attrs   IN OUT t_Doc_Attrs,
                            p_Nda_Id      IN     NUMBER,
                            p_Val_Str     IN     VARCHAR2 DEFAULT NULL,
                            p_Val_Dt      IN     DATE DEFAULT NULL,
                            p_Val_Int     IN     NUMBER DEFAULT NULL,
                            p_Val_Id      IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF     p_Val_Str IS NULL
           AND p_Val_Dt IS NULL
           AND p_Val_Int IS NULL
           AND p_Val_Id IS NULL
        THEN
            RETURN;
        END IF;

        IF p_Doc_Attrs IS NULL
        THEN
            p_Doc_Attrs := t_Doc_Attrs ();
        END IF;

        p_Doc_Attrs.EXTEND ();
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Nda_Id := p_Nda_Id;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Str := p_Val_Str;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Dt := p_Val_Dt;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Int := p_Val_Int;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Id := p_Val_Id;
    END;

    ------------------------------------------------------------------
    --  Збереження документа з атрибутами у соціальну картку
    ------------------------------------------------------------------
    PROCEDURE Save_Document (p_Sc_Id       IN     NUMBER,
                             p_Ndt_Id      IN     NUMBER,
                             p_Doc_Attrs   IN     t_Doc_Attrs,
                             p_Src_Id      IN     NUMBER,
                             p_Src_Code    IN     VARCHAR2,
                             p_Scd_Note    IN     VARCHAR2,
                             p_Scd_Id         OUT NUMBER,
                             p_Scd_Dh         OUT NUMBER,
                             p_Scd_St      IN     VARCHAR2 DEFAULT '1')
    IS
        l_Scd_Doc   NUMBER;
    BEGIN
        Save_Document (p_Sc_Id       => p_Sc_Id,
                       p_Ndt_Id      => p_Ndt_Id,
                       p_Doc_Attrs   => p_Doc_Attrs,
                       p_Src_Id      => p_Src_Id,
                       p_Src_Code    => p_Src_Code,
                       p_Scd_Note    => p_Scd_Note,
                       p_Scd_Id      => p_Scd_Id,
                       p_Doc_Id      => l_Scd_Doc,
                       p_Dh_Id       => p_Scd_Dh,
                       p_Scd_St      => p_Scd_St);
    END;

    ------------------------------------------------------------------
    --  Збереження документа з атрибутами у соціальну картку
    ------------------------------------------------------------------
    PROCEDURE Save_Document (p_Sc_Id         IN     NUMBER,
                             p_Ndt_Id        IN     NUMBER,
                             p_Doc_Attrs     IN     t_Doc_Attrs,
                             p_Src_Id        IN     NUMBER,
                             p_Src_Code      IN     VARCHAR2,
                             p_Scd_Note      IN     VARCHAR2,
                             p_Scd_Id           OUT NUMBER,
                             p_Doc_Id        IN OUT NUMBER,
                             p_Dh_Id         IN OUT NUMBER,
                             p_Set_Feature   IN     BOOLEAN DEFAULT FALSE,
                             p_Scd_St        IN     VARCHAR2 DEFAULT '1')
    IS
        l_Doc_Num           VARCHAR2 (100);
        l_Scd               Uss_Person.v_Sc_Document%ROWTYPE;

        l_Attrs_Modified    NUMBER;
        l_Attrs_Exist       NUMBER;
        l_Attach_Modified   NUMBER;

        l_Need_Create_Dh    BOOLEAN := FALSE;
        l_Doc_Hs            NUMBER;
    BEGIN
        --Отримуємо номер документа
        SELECT SUBSTR (MAX (a.Val_Str), 1, 50)
          INTO l_Doc_Num
          FROM TABLE (p_Doc_Attrs)  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Nda_Id = n.Nda_Id AND n.Nda_Class = 'DSN';

        --Шукаємо документ з таким типом у соц.картці
        BEGIN
              SELECT d.Scd_Id, d.Scd_Doc, d.Scd_Dh
                INTO p_Scd_Id, l_Scd.Scd_Doc, l_Scd.Scd_Dh
                FROM Uss_Person.v_Sc_Document d
               WHERE     d.Scd_Sc = p_Sc_Id
                     AND d.Scd_Ndt = p_Ndt_Id
                     --який має такий самий номер
                     AND NVL (
                             UPPER (
                                 REPLACE (
                                     REPLACE (d.Scd_Seria || d.Scd_Number,
                                              '-',
                                              ''),
                                     ' ',
                                     '')),
                             '#') =
                         NVL (
                             UPPER (
                                 REPLACE (REPLACE (l_Doc_Num, '-', ''),
                                          ' ',
                                          '')),
                             '#')
            ORDER BY DECODE (d.Scd_St, '1', 1, 2) ASC, d.Scd_Id DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --ЯКЩО НЕ ПЕРЕДАНО ПОСИЛАННЯ НА ДОКУМЕНТ В АРХІВІ ТА НЕ ЗНАЙДЕНО ДОКУМЕНТ У СОЦКАРТЦІ
        IF p_Doc_Id IS NULL AND l_Scd.Scd_Doc IS NULL
        THEN
            --Створюємо документ в архіві
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => p_Ndt_Id,
                p_Doc_Actuality   => 'A',
                p_New_Id          => l_Scd.Scd_Doc);
            l_Need_Create_Dh := TRUE;
            l_Attrs_Modified := 1;
        --ЯКЩО ПЕРЕДАНО ПОСИЛАННЯ НА ДОКУМЕНТ В АРХІВІ АБО ЗНАЙДЕНО ДОКУМЕНТ В СОЦКАРТЦІ
        ELSE
            --Визначаємо ІД документа та зрізу в архіві, в який будемо записувати атрибути та вкладення:
            -- якщо не знайдено документ у соцкартці
            IF l_Scd.Scd_Doc IS NULL --або знайдено такий самий документ, який було передано в параметрі
                                     OR l_Scd.Scd_Doc = p_Doc_Id
            THEN
                --Тоді будемо записувати атрибути і вкладення у той документ, що було передано
                --(чи записувати у той самий зріз, визначимо далі, в залежності від наявності змін у атрибутах)
                l_Scd.Scd_Doc := p_Doc_Id;
                l_Scd.Scd_Dh := p_Dh_Id;
            END IF;

            --Для визначення того, чи записувати атрибути у зріз що було визначено раніше,
            --виконуємо порівняння атрибутів документа що передали з атрибутами документа в архіві:

            --атрибути документа в архіві
            WITH
                Old_Attrs
                AS
                    (SELECT a.Da_Nda,
                            a.Da_Val_String,
                            a.Da_Val_Dt,
                            a.Da_Val_Int,
                            a.Da_Val_Id
                       FROM Uss_Doc.v_Doc_Attr2hist  h
                            JOIN Uss_Doc.v_Doc_Attributes a
                                ON h.Da2h_Da = a.Da_Id
                      WHERE h.Da2h_Dh = l_Scd.Scd_Dh),
                --атрибути що передали
                New_Attrs AS (SELECT * FROM TABLE (p_Doc_Attrs))
            SELECT MAX (
                       CASE
                           WHEN    o.Da_Nda IS NULL
                                OR n.Nda_Id IS NULL
                                OR NVL (o.Da_Val_String, '-') <>
                                   NVL (n.Val_Str, '-')
                                OR NVL (o.Da_Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy')) <>
                                   NVL (n.Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                                OR NVL (o.Da_Val_Int, -999999999) <>
                                   NVL (n.Val_Int, -999999999)
                                OR NVL (o.Da_Val_Id, -999999999) <>
                                   NVL (n.Val_Id, -999999999)
                           THEN
                               1
                           ELSE
                               0
                       END),
                   SIGN (COUNT (DISTINCT o.Da_Nda))
              INTO l_Attrs_Modified, l_Attrs_Exist
              FROM New_Attrs  n
                   FULL OUTER JOIN Old_Attrs o ON n.Nda_Id = o.Da_Nda;

            --Відмічаємо необхідність створення нового зрізу документа, якщо є зміни в атрибутах
            l_Need_Create_Dh := l_Attrs_Modified = 1 AND l_Attrs_Exist = 1;

            --Порівнбємо вкладення у зрірі, що передали з вкладеннями документа в архіві
            IF NOT l_Need_Create_Dh AND p_Dh_Id <> l_Scd.Scd_Dh
            THEN
                WITH
                    New_Attach
                    AS
                        (SELECT a.*, f.File_Hash
                           FROM Uss_Doc.v_Doc_Attachments  a
                                JOIN Uss_Doc.v_Files f
                                    ON a.Dat_File = f.File_Id
                          WHERE a.Dat_Dh = p_Dh_Id),
                    Old_Attach
                    AS
                        (SELECT a.*, f.File_Hash
                           FROM Uss_Doc.v_Doc_Attachments  a
                                JOIN Uss_Doc.v_Files f
                                    ON a.Dat_File = f.File_Id
                          WHERE a.Dat_Dh = l_Scd.Scd_Dh)
                SELECT MAX (
                           CASE
                               WHEN    o.Dat_Id IS NULL
                                    OR n.Dat_Id IS NULL
                                    OR o.Dat_Sign_File <> n.Dat_Sign_File
                               THEN
                                   1
                               ELSE
                                   0
                           END)
                  INTO l_Attach_Modified
                  FROM New_Attach  n
                       FULL OUTER JOIN Old_Attach o
                           ON n.File_Hash = o.File_Hash;

                l_Need_Create_Dh := l_Attach_Modified = 1;
            END IF;
        END IF;

        IF l_Need_Create_Dh
        THEN
            l_Doc_Hs := Uss_Doc.Tools.Gethistsession;
            --створюємо новий зріз документу
            Uss_Doc.Api$documents.Save_Doc_Hist (
                p_Dh_Id          => NULL,
                p_Dh_Doc         => l_Scd.Scd_Doc,
                p_Dh_Sign_Alg    => NULL,
                p_Dh_Ndt         => p_Ndt_Id,
                p_Dh_Sign_File   => NULL,
                p_Dh_Actuality   => 'A',
                p_Dh_Dt          => SYSDATE,
                p_Dh_Wu          => NULL,
                p_Dh_Src         => p_Src_Code,
                p_New_Id         => l_Scd.Scd_Dh);

            --переносимо вкладення з попереднього зрізу
            FOR Rec IN (SELECT *
                          FROM Uss_Doc.v_Doc_Attachments a
                         WHERE a.Dat_Dh = p_Dh_Id)
            LOOP
                DECLARE
                    l_Dat_Id   NUMBER;
                BEGIN
                    Uss_Doc.Api$documents.Save_Attachment (
                        p_Dat_Id          => NULL,
                        p_Dat_Num         => Rec.Dat_Num,
                        p_Dat_File        => Rec.Dat_File,
                        p_Dat_Dh          => l_Scd.Scd_Dh,
                        p_Dat_Sign_File   => Rec.Dat_Sign_File,
                        p_Dat_Hs          => l_Doc_Hs,
                        p_New_Id          => l_Dat_Id);

                    --Переносимо додаткові підписи
                    FOR Sgn IN (SELECT *
                                  FROM Uss_Doc.v_Doc_Attach_Signs s
                                 WHERE s.Dats_Dat = Rec.Dat_Id)
                    LOOP
                        Uss_Doc.Api$documents.Save_Attachment_Sign (
                            p_Dats_Dat         => l_Dat_Id,
                            p_Dats_Sign_File   => Sgn.Dats_Sign_File,
                            p_Dats_Hs          => l_Doc_Hs);
                    END LOOP;
                END;
            END LOOP;
        ELSIF l_Attrs_Modified = 1 AND l_Attrs_Exist = 0
        THEN
            --#112943
            --У разі якщо Dh був ініціалізований в іншому місці, вказуємо актуальність та тип документу
            DECLARE
                l_Dh_Init     NUMBER;
                l_Dh_Origin   Uss_Doc.v_Doc_Hist%ROWTYPE;
            BEGIN
                SELECT SIGN (COUNT (*))
                  INTO l_Dh_Init
                  FROM Uss_Doc.v_Doc_Hist Dh
                 WHERE     Dh.Dh_Id = l_Scd.Scd_Dh
                       AND Dh.Dh_Ndt IS NULL
                       AND Dh.Dh_Actuality =
                           Uss_Doc.Api$documents.c_Doc_Actuality_Undefined;

                IF l_Dh_Init = 1
                THEN
                    SELECT *
                      INTO l_Dh_Origin
                      FROM Uss_Doc.v_Doc_Hist Dh
                     WHERE Dh.Dh_Id = l_Scd.Scd_Dh;

                    --Оновлюємо існуючий зріз, змінюючи лише тип документу а актуальність
                    Uss_Doc.Api$documents.Save_Doc_Hist (
                        p_Dh_Id          => l_Scd.Scd_Dh,
                        p_Dh_Doc         => l_Dh_Origin.Dh_Doc,
                        p_Dh_Sign_Alg    => l_Dh_Origin.Dh_Sign_Alg,
                        p_Dh_Ndt         => p_Ndt_Id,
                        p_Dh_Sign_File   => l_Dh_Origin.Dh_Sign_File,
                        p_Dh_Actuality   => 'A',
                        p_Dh_Dt          => l_Dh_Origin.Dh_Dt,
                        p_Dh_Wu          => l_Dh_Origin.Dh_Wu,
                        p_Dh_Src         => l_Dh_Origin.Dh_Src,
                        p_Dh_Cu          => l_Dh_Origin.Dh_Cu,
                        p_New_Id         => l_Scd.Scd_Dh);
                END IF;
            END;
        END IF;

        IF l_Attrs_Modified = 1 OR l_Need_Create_Dh
        THEN
            --Зберігаємо атрибути документа
            FOR i IN 1 .. p_Doc_Attrs.COUNT
            LOOP
                Uss_Doc.Api$documents.Save_Doc_Attr (
                    p_Dh_Id     => l_Scd.Scd_Dh,
                    p_Nda_Id    => p_Doc_Attrs (i).Nda_Id,
                    p_Val_Str   => p_Doc_Attrs (i).Val_Str,
                    p_Val_Dt    => p_Doc_Attrs (i).Val_Dt,
                    p_Val_Int   => p_Doc_Attrs (i).Val_Int,
                    p_Val_Id    => p_Doc_Attrs (i).Val_Id);
            END LOOP;
        END IF;

        --Зберігаємо документ у соцкартку
        Uss_Person.Api$socialcard.Save_Sc_Document (
            p_Scd_Id     => p_Scd_Id,
            p_Scd_Sc     => p_Sc_Id,
            p_Scd_Name   => NULL,
            p_Scd_St     => NVL (p_Scd_St, '1'),
            p_Scd_Src    => p_Src_Id,
            p_Scd_Note   => p_Scd_Note,
            p_Scd_Ndt    => p_Ndt_Id,
            p_Scd_Doc    => l_Scd.Scd_Doc,
            p_Scd_Dh     => l_Scd.Scd_Dh,
            p_New_Id     => p_Scd_Id);

        p_Doc_Id := l_Scd.Scd_Doc;
        p_Dh_Id := l_Scd.Scd_Dh;

        --Переводимо інщі документи цього типу у соцкартці у статус "Неактуальний"
        Close_Other_Docs (p_Sc_Id        => p_Sc_Id,
                          p_Ndt_Id       => p_Ndt_Id,
                          p_Actual_Scd   => p_Scd_Id);

        --Якщо передано документ "Відмова від РНОКПП"
        IF p_Ndt_Id = 10117
        THEN
            --Робимо поточний РНОКПП в картці неактульним
            UPDATE Sc_Document d
               SET d.Scd_St = '2'
             WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_Ndt = 5 AND d.Scd_St = '1';
        ELSIF p_Ndt_Id = 5
        THEN
            --Робимо документ "Відмова від РНОКПП" в картці неактульним
            UPDATE Sc_Document d
               SET d.Scd_St = '2'
             WHERE     d.Scd_Sc = p_Sc_Id
                   AND d.Scd_Ndt = 10117
                   AND d.Scd_St = '1';
        END IF;

        IF SQL%ROWCOUNT > 0
        THEN
            Init_Sc_Info (p_Sc_Id => p_Sc_Id);
        END IF;

        --СОЦІАЛЬНІ ОЗНАКИ
        IF p_Set_Feature
        THEN
            --Довідка ВПО
            IF p_Ndt_Id = 10052
            THEN
                DECLARE
                    c_Nda_Vpo_St   CONSTANT NUMBER := 1855;
                    l_Vpo_St                VARCHAR2 (10);
                BEGIN
                    --Отримуємо статус довідки ВПО
                    l_Vpo_St :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => c_Nda_Vpo_St,
                            p_Dh_Id    => p_Dh_Id);

                    IF l_Vpo_St = 'A'
                    THEN
                        --Встановлюємо статус ВПО у особи
                        Uss_Person.Api$feature.Set_Sc_Feature (
                            p_Scs_Sc        => p_Sc_Id,
                            p_Scs_Scd       => p_Scd_Id,
                            p_Scs_Scd_Ndt   => p_Ndt_Id,
                            p_Scs_Scd_Dh    => p_Dh_Id);
                    ELSIF l_Vpo_St = 'H'
                    THEN
                        --Знімаємо статус ВПО у особи
                        Uss_Person.Api$feature.Unset_Sc_Feature (
                            p_Scs_Sc        => p_Sc_Id,
                            p_Scs_Scd       => p_Scd_Id,
                            p_Scs_Scd_Ndt   => p_Ndt_Id,
                            p_Scs_Scd_Dh    => p_Dh_Id);
                    END IF;
                END;
            --Довідка МСЕК/PPP/EPP
            ELSIF p_Ndt_Id IN (201, 601, 602)
            THEN
                Uss_Person.Api$feature.Set_Sc_Disability (
                    p_Scy_Sc        => p_Sc_Id,
                    p_Scy_Scd       => p_Scd_Id,
                    p_Scy_Scd_Ndt   => p_Ndt_Id,
                    p_Scy_Scd_Dh    => p_Dh_Id);
            END IF;
        END IF;
    END;

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
        p_New_Id        OUT Sc_Document.Scd_Id%TYPE)
    IS
        l_Scd_Seria        Sc_Document.Scd_Seria%TYPE;
        l_Scd_Number       Sc_Document.Scd_Number%TYPE;
        l_Scd_Issued_Dt    Sc_Document.Scd_Issued_Dt%TYPE;
        l_Scd_Issued_Who   Sc_Document.Scd_Issued_Who%TYPE;
        l_Scd_Start_Dt     Sc_Document.Scd_Start_Dt%TYPE;
        l_Scd_Stop_Dt      Sc_Document.Scd_Stop_Dt%TYPE;
    BEGIN
        IF p_Scd_Dh IS NOT NULL
        THEN
            SELECT                                  --Серія та номер документа
                   MAX (
                       CASE
                           WHEN Nda_Class = 'DSN'
                           THEN
                               SUBSTR (TRIM (Da_Val_String), 1, 50)
                       END),
                   --Дата видачі документа
                   MAX (CASE WHEN Nda_Class = 'DGVDT' THEN Da_Val_Dt END),
                   --Орган видачі документа
                   MAX (
                       CASE
                           WHEN Nda_Class = 'DORG'
                           THEN
                               SUBSTR (Da_Val_String, 1, 100)
                       END),
                   --Дата початку дії документа
                   MAX (CASE WHEN Nda_Class = 'DSTDT' THEN Da_Val_Dt END),
                   --Дата закінчення дії документа
                   NVL (
                       MAX (CASE WHEN Nda_Class = 'DSPDT' THEN Da_Val_Dt END),
                       MAX (
                           CASE WHEN Nda_Class = 'TILLDT' THEN Da_Val_Dt END))
              INTO l_Scd_Number,
                   l_Scd_Issued_Dt,
                   l_Scd_Issued_Who,
                   l_Scd_Start_Dt,
                   l_Scd_Stop_Dt
              FROM Uss_Doc.v_Doc_Attr2hist  h
                   JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n ON a.Da_Nda = n.Nda_Id
             WHERE h.Da2h_Dh = p_Scd_Dh;

            IF l_Scd_Number IS NOT NULL
            THEN
                Split_Doc_Number (p_Ndt_Id       => p_Scd_Ndt,
                                  p_Doc_Number   => l_Scd_Number,
                                  p_Doc_Serial   => l_Scd_Seria);
            END IF;
        END IF;

        Save_Sc_Document (p_Scd_Id           => p_Scd_Id,
                          p_Scd_Sc           => p_Scd_Sc,
                          p_Scd_Name         => p_Scd_Name,
                          p_Scd_Seria        => l_Scd_Seria,
                          p_Scd_Number       => l_Scd_Number,
                          p_Scd_Issued_Dt    => l_Scd_Issued_Dt,
                          p_Scd_Issued_Who   => l_Scd_Issued_Who,
                          p_Scd_Start_Dt     => l_Scd_Start_Dt,
                          p_Scd_Stop_Dt      => l_Scd_Stop_Dt,
                          p_Scd_St           => p_Scd_St,
                          p_Scd_Src          => p_Scd_Src,
                          p_Scd_Note         => p_Scd_Note,
                          p_Scd_Ndt          => p_Scd_Ndt,
                          p_Scd_Doc          => p_Scd_Doc,
                          p_Scd_Dh           => p_Scd_Dh,
                          p_New_Id           => p_New_Id);
    END;

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
        p_New_Id              OUT Sc_Document.Scd_Id%TYPE)
    IS
        l_Scd_Doc   NUMBER;
    BEGIN
        IF NVL (p_Scd_Id, -1) <= 0
        THEN
            INSERT INTO Sc_Document (Scd_Id,
                                     Scd_Sc,
                                     Scd_Name,
                                     Scd_Seria,
                                     Scd_Number,
                                     Scd_Issued_Dt,
                                     Scd_Issued_Who,
                                     Scd_Start_Dt,
                                     Scd_Stop_Dt,
                                     Scd_St,
                                     Scd_Src,
                                     Scd_Note,
                                     Scd_Ndt,
                                     Scd_Doc,
                                     Scd_Dh)
                 VALUES (0,
                         p_Scd_Sc,
                         p_Scd_Name,
                         p_Scd_Seria,
                         p_Scd_Number,
                         p_Scd_Issued_Dt,
                         p_Scd_Issued_Who,
                         p_Scd_Start_Dt,
                         p_Scd_Stop_Dt,
                         p_Scd_St,
                         p_Scd_Src,
                         p_Scd_Note,
                         p_Scd_Ndt,
                         p_Scd_Doc,
                         p_Scd_Dh)
              RETURNING Scd_Id
                   INTO p_New_Id;

            IF p_Scd_Ndt = c_Ndt_Vpo_Cert
            THEN
                --Фіксуємо подію створення нової довідки ВПО
                Api$scd_Event.Make_New_Document (
                    p_Scde_Scd       => p_New_Id,
                    p_Scde_Dt        => SYSDATE,
                    p_Scde_Message   => CHR (38) || '168');
            ELSIF p_Scd_Ndt = c_Ndt_Death_Cert
            THEN
                --Фіксуємо подію створення нового свідоцтва про смерть
                Api$scd_Event.Make_New_Document (
                    p_Scde_Scd       => p_New_Id,
                    p_Scde_Dt        => SYSDATE,
                    p_Scde_Message   => CHR (38) || '197');
            ELSIF p_Scd_Ndt = c_Ndt_Msek_Cert
            THEN
                --Фіксуємо подію створення нового свідоцтва МСЕК
                Api$scd_Event.Make_New_Document (
                    p_Scde_Scd       => p_New_Id,
                    p_Scde_Dt        => SYSDATE,
                    p_Scde_Message   => CHR (38) || '291');
            END IF;
        ELSE
            p_New_Id := p_Scd_Id;

            IF p_Scd_Doc IS NOT NULL
            THEN
                SELECT d.Scd_Doc
                  INTO l_Scd_Doc
                  FROM Uss_Person.Sc_Document d
                 WHERE d.Scd_Id = p_Scd_Id;

                --З метою запобігання втрати звязку документа в соцкартці з документом в архіві,
                --якщо виконується спроба замінити посилання на документ в архіві,
                IF l_Scd_Doc IS NOT NULL AND l_Scd_Doc <> p_Scd_Doc
                THEN
                    --переводимо поточний документ в соцкартці в історичний статус
                    Set_Doc_St (p_Scd_Id   => p_Scd_Id,
                                p_Scd_St   => c_Scd_St_Closed);

                    --та свторюємо новий запис про документ в соцкартці
                    Save_Sc_Document (p_Scd_Id           => NULL,
                                      p_Scd_Sc           => p_Scd_Sc,
                                      p_Scd_Name         => p_Scd_Name,
                                      p_Scd_Seria        => p_Scd_Seria,
                                      p_Scd_Number       => p_Scd_Number,
                                      p_Scd_Issued_Dt    => p_Scd_Issued_Dt,
                                      p_Scd_Issued_Who   => p_Scd_Issued_Who,
                                      p_Scd_Start_Dt     => p_Scd_Start_Dt,
                                      p_Scd_Stop_Dt      => p_Scd_Stop_Dt,
                                      p_Scd_St           => p_Scd_St,
                                      p_Scd_Src          => p_Scd_Src,
                                      p_Scd_Note         => p_Scd_Note,
                                      p_Scd_Ndt          => p_Scd_Ndt,
                                      p_Scd_Doc          => p_Scd_Doc,
                                      p_Scd_Dh           => p_Scd_Dh,
                                      p_New_Id           => p_New_Id);

                    RETURN;
                END IF;
            END IF;

            UPDATE Uss_Person.Sc_Document d
               SET d.Scd_Seria = p_Scd_Seria,
                   d.Scd_Number = p_Scd_Number,
                   d.Scd_Issued_Dt = p_Scd_Issued_Dt,
                   d.Scd_Issued_Who = p_Scd_Issued_Who,
                   d.Scd_Start_Dt = p_Scd_Start_Dt,
                   d.Scd_Stop_Dt = p_Scd_Stop_Dt,
                   d.Scd_Doc = p_Scd_Doc,
                   d.Scd_Dh = p_Scd_Dh,
                   d.Scd_Src = p_Scd_Src,
                   d.Scd_St = NVL (p_Scd_St, d.Scd_St),
                   d.Scd_Note = p_Scd_Note
             WHERE d.Scd_Id = p_Scd_Id;

            IF p_Scd_Ndt = c_Ndt_Vpo_Cert
            THEN
                --Фіксуємо подію оновлення документа
                Api$scd_Event.Update_Document (p_Scde_Scd       => p_New_Id,
                                               p_Scde_Dt        => SYSDATE,
                                               p_Scde_Message   => NULL);
            ELSIF p_Scd_Ndt = c_Ndt_Msek_Cert
            THEN
                --Фіксуємо подію оновлення документа
                IF NVL (p_Scd_St, '1') = '1'
                THEN
                    Api$scd_Event.Update_Document (p_Scde_Scd       => p_New_Id,
                                                   p_Scde_Dt        => SYSDATE,
                                                   p_Scde_Message   => NULL);
                ELSE
                    Api$scd_Event.Close_Document (
                        p_Scde_Scd       => p_New_Id,
                        p_Scde_Dt        => SYSDATE,
                        p_Scde_Message   => CHR (38) || '292');
                END IF;
            END IF;
        END IF;
    END;

    PROCEDURE Set_Doc_St (p_Scd_Id IN NUMBER, p_Scd_St IN VARCHAR2)
    IS
        l_Scd_Ndt   NUMBER;
    BEGIN
           UPDATE Sc_Document d
              SET d.Scd_St = p_Scd_St
            WHERE d.Scd_Id = p_Scd_Id AND d.Scd_St <> p_Scd_St
        RETURNING Scd_Ndt
             INTO l_Scd_Ndt;

        IF SQL%ROWCOUNT = 0
        THEN
            RETURN;
        END IF;

        IF p_Scd_St = c_Scd_St_Closed AND l_Scd_Ndt = c_Ndt_Vpo_Cert
        THEN
            --Фіксуємо подію закриття довідки ВПО
            Api$scd_Event.Close_Document (
                p_Scde_Scd       => p_Scd_Id,
                p_Scde_Dt        => SYSDATE,
                p_Scde_Message   => CHR (38) || '169');
        ELSIF p_Scd_St = c_Scd_St_Closed AND l_Scd_Ndt = c_Ndt_Death_Cert
        THEN
            --Фіксуємо подію анулювання сівоцтва про смерть
            Api$scd_Event.Close_Document (
                p_Scde_Scd       => p_Scd_Id,
                p_Scde_Dt        => SYSDATE,
                p_Scde_Message   => CHR (38) || '198');
        ELSIF p_Scd_St = c_Scd_St_Closed AND l_Scd_Ndt = c_Ndt_Msek_Cert
        THEN
            --Фіксуємо подію анулювання довідки МСЕК
            Api$scd_Event.Close_Document (
                p_Scde_Scd       => p_Scd_Id,
                p_Scde_Dt        => SYSDATE,
                p_Scde_Message   => CHR (38) || '292');
        END IF;
    END;

    ------------------------------------------------------
    --  Закриття документів вказанного типу в у соцкартці
    --  окрім актуального
    ------------------------------------------------------
    PROCEDURE Close_Other_Docs (p_Sc_Id        NUMBER,
                                p_Ndt_Id       NUMBER,
                                p_Actual_Scd   NUMBER)
    IS
        l_Actual_Doc_Num   Sc_Document.Scd_Number%TYPE;
    BEGIN
        SELECT d.Scd_Seria || d.Scd_Number
          INTO l_Actual_Doc_Num
          FROM Sc_Document d
         WHERE d.Scd_Id = p_Actual_Scd;

        FOR Rec
            IN (SELECT *
                  FROM Sc_Document Ddd
                 WHERE     Ddd.Scd_Id <> p_Actual_Scd
                       AND Ddd.Scd_Sc = p_Sc_Id
                       AND Ddd.Scd_St IN (c_Scd_St_Actual, c_Scd_St_Closed)
                       AND Ddd.Scd_Ndt IN
                               (SELECT Tc.Ndt_Id
                                  FROM Uss_Ndi.v_Ndi_Document_Type  Tt
                                       JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                                           ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                              AND COALESCE (
                                                      Tc.Ndt_Uniq_Group,
                                                      TO_CHAR (Tc.Ndt_Id)) =
                                                  COALESCE (
                                                      Tt.Ndt_Uniq_Group,
                                                      TO_CHAR (Tt.Ndt_Id))
                                 WHERE Tt.Ndt_Id = p_Ndt_Id)
                FOR UPDATE)
        LOOP
            Set_Doc_St (
                p_Scd_Id   => Rec.Scd_Id,
                p_Scd_St   =>
                    CASE
                        WHEN UPPER (
                                 REPLACE (
                                     REPLACE (
                                         Rec.Scd_Seria || Rec.Scd_Number,
                                         '-',
                                         ''),
                                     ' ',
                                     '')) <>
                             UPPER (
                                 REPLACE (
                                     REPLACE (l_Actual_Doc_Num, '-', ''),
                                     ' ',
                                     ''))
                        THEN
                            c_Scd_St_Closed
                        ELSE
                            c_Scd_St_Duplicate
                    END);
        END LOOP;
    END;

    PROCEDURE Save_Sc_Contact (
        p_Sct_Id          IN     Sc_Contact.Sct_Id%TYPE,
        p_Sct_Phone_Mob   IN     Sc_Contact.Sct_Phone_Mob%TYPE,
        p_Sct_Phone_Num   IN     Sc_Contact.Sct_Phone_Num%TYPE,
        p_Sct_Fax_Num     IN     Sc_Contact.Sct_Fax_Num%TYPE,
        p_Sct_Email       IN     Sc_Contact.Sct_Email%TYPE,
        p_Sct_Note        IN     Sc_Contact.Sct_Note%TYPE,
        p_New_Id             OUT Sc_Contact.Sct_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Contact (Sct_Id,
                                Sct_Phone_Mob,
                                Sct_Phone_Num,
                                Sct_Fax_Num,
                                Sct_Email,
                                Sct_Note)
             VALUES (0,
                     p_Sct_Phone_Mob,
                     p_Sct_Phone_Num,
                     p_Sct_Fax_Num,
                     p_Sct_Email,
                     p_Sct_Note)
          RETURNING Sct_Id
               INTO p_New_Id;
    END;

    /* -- Поки вирішили працювати по двох полях
      PROCEDURE Save_Sc_Contact(p_Scc_Sc        IN SC_CHANGE.SCC_SC%TYPE,
                                p_Sct_Phone_Mob IN Sc_Contact.Sct_Phone_Mob%TYPE,
                                p_Sct_Phone_Num IN Sc_Contact.Sct_Phone_Num%TYPE,
                                p_Sct_Fax_Num   IN Sc_Contact.Sct_Fax_Num%TYPE,
                                p_Sct_Email     IN Sc_Contact.Sct_Email%TYPE,
                                p_Sct_Note      IN Sc_Contact.Sct_Note%TYPE) IS
    */
    --#90065
    PROCEDURE Save_Sc_Contact (
        p_Scc_Sc          IN Sc_Change.Scc_Sc%TYPE,
        p_Sct_Phone_Mob   IN Sc_Contact.Sct_Phone_Mob%TYPE,
        p_Sct_Email       IN Sc_Contact.Sct_Email%TYPE)
    IS
        l_New_Id   Sc_Contact.Sct_Id%TYPE;
        l_Sct      Sc_Contact%ROWTYPE;
        l_Scc      Sc_Change%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Scc
          FROM Sc_Change Scc
         WHERE     Scc_Sc = p_Scc_Sc
               AND Scc.Scc_Create_Dt = (SELECT MAX (Scc_m.Scc_Create_Dt)
                                          FROM Sc_Change Scc_m
                                         WHERE Scc_m.Scc_Sc = p_Scc_Sc)
               AND ROWNUM < 2;

        IF l_Scc.Scc_Sct = -1
        THEN
            INSERT INTO Sc_Contact (Sct_Id,
                                    Sct_Phone_Mob,
                                    Sct_Email,
                                    Sct_Is_Mob_Inform,
                                    Sct_Is_Email_Inform)
                 VALUES (
                            0,
                            p_Sct_Phone_Mob,
                            p_Sct_Email,
                            CASE
                                WHEN p_Sct_Phone_Mob IS NULL THEN 'F'
                                ELSE 'T'
                            END,
                            CASE
                                WHEN p_Sct_Email IS NULL THEN 'F'
                                ELSE 'T'
                            END)
              RETURNING Sct_Id
                   INTO l_New_Id;
        ELSE
            SELECT *
              INTO l_Sct
              FROM Sc_Contact Sct
             WHERE Sct.Sct_Id = l_Scc.Scc_Sct;

            IF     NVL (l_Sct.Sct_Phone_Mob, '-') =
                   NVL (p_Sct_Phone_Mob, '-')
               AND NVL (l_Sct.Sct_Email, '-') = NVL (p_Sct_Email, '-')
            THEN
                NULL;
            ELSE
                INSERT INTO Sc_Contact (Sct_Id,
                                        Sct_Phone_Mob,
                                        Sct_Phone_Num,
                                        Sct_Fax_Num,
                                        Sct_Email,
                                        Sct_Note,
                                        Sct_Is_Mob_Inform,
                                        Sct_Is_Email_Inform)
                     VALUES (
                                0,
                                p_Sct_Phone_Mob,
                                l_Sct.Sct_Phone_Num,
                                l_Sct.Sct_Fax_Num,
                                p_Sct_Email,
                                l_Sct.Sct_Note,
                                CASE
                                    WHEN p_Sct_Phone_Mob IS NULL THEN 'F'
                                    ELSE 'T'
                                END,
                                CASE
                                    WHEN p_Sct_Email IS NULL THEN 'F'
                                    ELSE 'T'
                                END)
                  RETURNING Sct_Id
                       INTO l_New_Id;
            END IF;
        END IF;

        IF l_New_Id IS NOT NULL
        THEN
            l_Scc.Scc_Id := 0;
            l_Scc.Scc_Create_Dt := SYSDATE;
            l_Scc.Scc_Sct := l_New_Id;
            l_Scc.Scc_Src_Dt := SYSDATE;

            INSERT INTO Sc_Change
                 VALUES l_Scc
              RETURNING Scc_Id
                   INTO l_Scc.Scc_Id;

            UPDATE Socialcard
               SET Sc_Scc = l_Scc.Scc_Id
             WHERE Sc_Id = p_Scc_Sc;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка збереження контактів (Save_Sc_Contact: '
                || SQLERRM
                || ')');
    END;

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
        p_New_Id              OUT Sc_Address.Sca_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Address (Sca_Id,
                                Sca_Sc,
                                Sca_Tp,
                                Sca_Kaot,
                                Sca_Nc,
                                Sca_Country,
                                Sca_Region,
                                Sca_District,
                                Sca_Postcode,
                                Sca_City,
                                Sca_Street,
                                Sca_Building,
                                Sca_Block,
                                Sca_Apartment,
                                Sca_Note,
                                History_Status,
                                Sca_Src)
             VALUES (0,
                     p_Sca_Sc,
                     p_Sca_Tp,
                     p_Sca_Kaot,
                     p_Sca_Nc,
                     p_Sca_Country,
                     p_Sca_Region,
                     p_Sca_District,
                     p_Sca_Postcode,
                     p_Sca_City,
                     p_Sca_Street,
                     p_Sca_Building,
                     p_Sca_Block,
                     p_Sca_Apartment,
                     p_Sca_Note,
                     p_History_Status,
                     p_Sca_Src)
          RETURNING Sca_Id
               INTO p_New_Id;
    END;

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
        o_Sca_Id             OUT Sc_Address.Sca_Id%TYPE)
    IS
        l_Hs   Sc_Address.History_Status%TYPE := 'A';
    BEGIN
        FOR c
            IN (SELECT *
                  FROM Sc_Address a
                 WHERE     a.Sca_Sc = p_Sca_Sc
                       AND a.Sca_Tp = p_Sca_Tp
                       AND a.History_Status = 'A')
        LOOP
            IF NVL (c.Sca_Create_Dt, TO_DATE ('01011990', 'ddmmyyyy')) <
               NVL (p_Sca_Create_Dt, SYSDATE)
            THEN
                UPDATE Sc_Address
                   SET History_Status = 'H'
                 WHERE Sca_Id = c.Sca_Id;
            END IF;

            IF c.Sca_Create_Dt > NVL (p_Sca_Create_Dt, SYSDATE)
            THEN
                l_Hs := 'H';
            END IF;

            IF c.Sca_Create_Dt = p_Sca_Create_Dt
            THEN
                IF     NVL (c.Sca_Kaot, 0) = NVL (p_Sca_Kaot, 0)
                   AND NVL (c.Sca_Nc, 0) = NVL (p_Sca_Nc, 0)
                   AND NVL (c.Sca_Country, '0') = NVL (p_Sca_Country, '0')
                   AND NVL (c.Sca_Region, '0') = NVL (p_Sca_Region, '0')
                   AND NVL (c.Sca_District, '0') = NVL (p_Sca_District, '0')
                   AND NVL (c.Sca_Postcode, '0') = NVL (p_Sca_Postcode, '0')
                   AND NVL (c.Sca_City, '0') = NVL (p_Sca_City, '0')
                   AND NVL (c.Sca_Street, '0') = NVL (p_Sca_Street, '0')
                   AND NVL (c.Sca_Building, '0') = NVL (p_Sca_Building, '0')
                   AND NVL (c.Sca_Block, '0') = NVL (p_Sca_Block, '0')
                   AND NVL (c.Sca_Apartment, '0') =
                       NVL (p_Sca_Apartment, '0')
                   AND NVL (c.Sca_Note, '0') = NVL (p_Sca_Note, '0')
                   AND NVL (c.Sca_Src, '0') = NVL (p_Sca_Src, '0')
                THEN
                    l_Hs := 'D';                                      -- Дубль
                    o_Sca_Id := c.Sca_Id;
                ELSE
                    UPDATE Sc_Address
                       SET History_Status = 'H'
                     WHERE Sca_Id = c.Sca_Id;
                END IF;
            END IF;
        END LOOP;

        IF l_Hs != 'D'
        THEN
            INSERT INTO Sc_Address (Sca_Id,
                                    Sca_Sc,
                                    Sca_Tp,
                                    Sca_Kaot,
                                    Sca_Nc,
                                    Sca_Country,
                                    Sca_Region,
                                    Sca_District,
                                    Sca_Postcode,
                                    Sca_City,
                                    Sca_Street,
                                    Sca_Building,
                                    Sca_Block,
                                    Sca_Apartment,
                                    Sca_Note,
                                    History_Status,
                                    Sca_Src,
                                    Sca_Create_Dt)
                 VALUES (0,
                         p_Sca_Sc,
                         p_Sca_Tp,
                         p_Sca_Kaot,
                         p_Sca_Nc,
                         p_Sca_Country,
                         p_Sca_Region,
                         p_Sca_District,
                         p_Sca_Postcode,
                         p_Sca_City,
                         p_Sca_Street,
                         p_Sca_Building,
                         p_Sca_Block,
                         p_Sca_Apartment,
                         p_Sca_Note,
                         l_Hs,
                         p_Sca_Src,
                         p_Sca_Create_Dt)
              RETURNING Sca_Id
                   INTO o_Sca_Id;

            -- IC #115381
            FOR c
                IN (SELECT l1.kaot_id            kaot_id_l1,
                           l1.kaot_code          kaot_code_l1,
                           l1.kaot_name          kaot_name_l1,
                           l1.kaot_full_name     kaot_full_name_l1,
                           l2.kaot_id            kaot_id_l2,
                           l2.kaot_code          kaot_code_l2,
                           l2.kaot_name          kaot_name_l2,
                           l2.kaot_full_name     kaot_full_name_l2,
                           l3.kaot_id            kaot_id_l3,
                           l3.kaot_code          kaot_code_l3,
                           l3.kaot_name          kaot_name_l3,
                           l3.kaot_full_name     kaot_full_name_l3,
                           l4.kaot_id            kaot_id_l4,
                           l4.kaot_code          kaot_code_l4,
                           l4.kaot_name          kaot_name_l4,
                           l4.kaot_full_name     kaot_full_name_l4
                      FROM uss_ndi.v_ndi_katottg  l
                           INNER JOIN uss_ndi.v_ndi_katottg l1
                               ON l1.kaot_id = l.kaot_kaot_l1
                           INNER JOIN uss_ndi.v_ndi_katottg l2
                               ON l2.kaot_id = l.kaot_kaot_l2
                           INNER JOIN uss_ndi.v_ndi_katottg l3
                               ON l3.kaot_id = l.kaot_kaot_l3
                           INNER JOIN uss_ndi.v_ndi_katottg l4
                               ON l4.kaot_id = l.kaot_kaot_l4
                     WHERE l.kaot_id = p_Sca_Kaot)
            LOOP
                UPDATE Sc_Address
                   SET Sca_Region = NVL (Sca_Region, c.kaot_full_name_l1),
                       Sca_District = NVL (Sca_District, c.kaot_full_name_l2),
                       Sca_City = NVL (Sca_City, c.kaot_full_name_l4)
                 WHERE Sca_Id = o_Sca_Id;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка збереження адреси (Save_Sc_Address: '
                || SQLERRM
                || ')');
    END Save_Sc_Address;

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
        p_New_Id                   OUT Sc_Feature.Scf_Id%TYPE)
    IS
    BEGIN
        IF p_Scf_Id IS NULL
        THEN
            INSERT INTO Sc_Feature (Scf_Id,
                                    Scf_Sc,
                                    Scf_Is_Taxpayer,
                                    Scf_Is_Migrant,
                                    Scf_Is_Pension,
                                    Scf_Is_Intpension,
                                    Scf_Is_Dead,
                                    Scf_Is_Jobless,
                                    Scf_Is_Accident,
                                    Scf_Is_Dasabled)
                 VALUES (0,
                         p_Scf_Sc,
                         p_Scf_Is_Taxpayer,
                         p_Scf_Is_Migrant,
                         p_Scf_Is_Pension,
                         p_Scf_Is_Intpension,
                         p_Scf_Is_Dead,
                         p_Scf_Is_Jobless,
                         p_Scf_Is_Accident,
                         p_Scf_Is_Dasabled)
              RETURNING Scf_Id
                   INTO p_New_Id;
        ELSE
            UPDATE Sc_Feature f
               SET Scf_Sc = NVL (p_Scf_Sc, Scf_Sc),
                   Scf_Is_Taxpayer = NVL (p_Scf_Is_Taxpayer, Scf_Is_Taxpayer),
                   Scf_Is_Migrant = NVL (p_Scf_Is_Migrant, Scf_Is_Migrant),
                   Scf_Is_Pension = NVL (p_Scf_Is_Pension, Scf_Is_Pension),
                   Scf_Is_Intpension =
                       NVL (p_Scf_Is_Intpension, Scf_Is_Intpension),
                   Scf_Is_Dead = NVL (p_Scf_Is_Dead, Scf_Is_Dead),
                   Scf_Is_Jobless = NVL (p_Scf_Is_Jobless, Scf_Is_Jobless),
                   Scf_Is_Accident = NVL (p_Scf_Is_Accident, Scf_Is_Accident),
                   Scf_Is_Dasabled = NVL (p_Scf_Is_Dasabled, Scf_Is_Dasabled),
                   Scf_Is_Singl_Parent =
                       NVL (p_Scf_Is_Singl_Parent, Scf_Is_Singl_Parent),
                   Scf_Is_Large_Family =
                       NVL (p_Scf_Is_Large_Family, Scf_Is_Large_Family),
                   Scf_Is_Low_Income =
                       NVL (p_Scf_Is_Low_Income, Scf_Is_Low_Income)
             WHERE f.Scf_Id = p_Scf_Id;
        END IF;
    END;

    PROCEDURE Save_Sc_Feature_Hist (
        p_Scs_Sc           Sc_Feature_Hist.Scs_Sc%TYPE,
        p_Scs_Tp           Sc_Feature_Hist.Scs_Tp%TYPE,
        p_Scs_Scd          Sc_Feature_Hist.Scs_Scd%TYPE,
        p_Scs_Start_Dt     Sc_Feature_Hist.Scs_Start_Dt%TYPE,
        p_Scs_Stop_Dt      Sc_Feature_Hist.Scs_Stop_Dt%TYPE,
        p_Scs_Assign_Dt    Sc_Feature_Hist.Scs_Assign_Dt%TYPE,
        p_Scs_Till_Dt      Sc_Feature_Hist.Scs_Till_Dt%TYPE,
        p_Scs_Dh           Sc_Feature_Hist.Scs_Dh%TYPE,
        p_History_Status   Sc_Feature_Hist.History_Status%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Feature_Hist (Scs_Id,
                                     Scs_Sc,
                                     Scs_Tp,
                                     Scs_Scd,
                                     Scs_Start_Dt,
                                     Scs_Stop_Dt,
                                     Scs_Assign_Dt,
                                     Scs_Till_Dt,
                                     Scs_Dh,
                                     History_Status)
             VALUES (0,
                     p_Scs_Sc,
                     p_Scs_Tp,
                     p_Scs_Scd,
                     p_Scs_Start_Dt,
                     p_Scs_Stop_Dt,
                     p_Scs_Assign_Dt,
                     p_Scs_Till_Dt,
                     p_Scs_Dh,
                     p_History_Status);
    END;

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
        p_New_Id                 OUT Sc_Pension.Scp_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Pension (Scp_Id,
                                Scp_Scd,
                                Scp_Is_Pension,
                                Scp_Is_Intpension,
                                Scp_Intpension_Dt,
                                Scp_Note,
                                Scp_Pnf_Number,
                                Scp_Org,
                                Scp_Pens_Tp,
                                Scp_Begin_Dt,
                                Scp_End_Dt,
                                Scp_Psn,
                                Scp_Recalc_Dt,
                                Scp_Pay_Tp,
                                Scp_Legal_Act,
                                Scp_Sc,
                                Scp_Sum_Pens,
                                Scp_Dh)
             VALUES (0,
                     p_Scp_Scd,
                     p_Scp_Is_Pension,
                     p_Scp_Is_Intpension,
                     p_Scp_Intpension_Dt,
                     p_Scp_Note,
                     p_Scp_Pnf_Number,
                     p_Scp_Org,
                     p_Scp_Pens_Tp,
                     p_Scp_Begin_Dt,
                     p_Scp_End_Dt,
                     p_Scp_Psn,
                     p_Scp_Recalc_Dt,
                     p_Scp_Pay_Tp,
                     p_Scp_Legal_Act,
                     p_Scp_Sc,
                     p_Scp_Sum_Pens,
                     p_Scp_Dh)
          RETURNING Scp_Id
               INTO p_New_Id;
    END;

    ---------------------------------------------------------------
    --Збережеггя інформації про інвалідність
    ---------------------------------------------------------------
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
        p_History_Status      IN Sc_Disability.History_Status%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Disability (Scy_Id,
                                   Scy_Sc,
                                   Scy_Group,
                                   Scy_Scd,
                                   Scy_Inspection_Dt,
                                   Scy_Decision_Dt,
                                   Scy_Till_Dt,
                                   Scy_Reason,
                                   Scy_Start_Dt,
                                   Scy_Stop_Dt,
                                   Scy_Dh,
                                   History_Status)
             VALUES (0,
                     p_Scy_Sc,
                     p_Scy_Group,
                     p_Scy_Scd,
                     p_Scy_Inspection_Dt,
                     p_Scy_Decision_Dt,
                     p_Scy_Till_Dt,
                     p_Scy_Reason,
                     p_Scy_Start_Dt,
                     p_Scy_Stop_Dt,
                     p_Scy_Dh,
                     p_History_Status);
    END;

    FUNCTION Get_Sc_Scy (p_Scy_Sc IN NUMBER)
        RETURN NUMBER
    IS
        l_Scy_Id   NUMBER;
    BEGIN
        SELECT MAX (Scy_Id)
          INTO l_Scy_Id
          FROM Sc_Disability
         WHERE Scy_Sc = p_Scy_Sc;

        RETURN l_Scy_Id;
    END;

    /*PROCEDURE Set_Sc_Data(p_Sc          IN OUT Socialcard.Sc_Id%TYPE,
                          p_Inn_Num     IN VARCHAR2,
                          p_Inn_Ndt     IN NUMBER DEFAULT 5,
                          p_Doc_Ser     IN VARCHAR2,
                          p_Doc_Num     IN VARCHAR2,
                          p_Doc_Ndt     IN NUMBER,
                          p_Doc_Is      IN VARCHAR2 DEFAULT NULL,
                          p_Doc_Bdt     IN DATE DEFAULT NULL,
                          p_Doc_Edt     IN DATE DEFAULT NULL,
                          p_Fn          IN VARCHAR2,
                          p_Ln          IN VARCHAR2,
                          p_Mn          IN VARCHAR2,
                          p_Gender      IN VARCHAR,
                          p_Nationality IN VARCHAR2,
                          p_Src_Dt      IN DATE,
                          p_Birth_Dt    IN DATE,
                          p_Src         IN VARCHAR2,
                          p_Note        IN VARCHAR2 DEFAULT NULL,
                          p_Sc_Scc      OUT Socialcard.Sc_Scc%TYPE) IS
      l_Last    NUMBER(1) := 1;
      l_Sysdate DATE := SYSDATE;
      l_Sc      NUMBER := p_Sc;

      r_Scc v_Sc_Change%ROWTYPE;
      r_Sci v_Sc_Identity%ROWTYPE;
      r_Scb v_Sc_Birth%ROWTYPE;
      r_Scd v_Sc_Document%ROWTYPE;

      l_Nationality v_Sc_Identity.Sci_Nationality%TYPE := p_Nationality;
      l_Gender      v_Sc_Identity.Sci_Gender%TYPE := p_Gender;
    BEGIN
      -- вичитка анкети по персоні
      SELECT Scc.*
        INTO r_Scc
        FROM Socialcard Sc
        JOIN v_Sc_Change Scc
          ON Scc.Scc_Id = Sc.Sc_Scc
       WHERE Scc.Scc_Sc = l_Sc;

      IF Coalesce(r_Scc.Scc_Src_Dt, r_Scc.Scc_Create_Dt) <= Coalesce(p_Src_Dt, l_Sysdate) THEN
        l_Last := 1; -- последнее изменение по человеку
      ELSE
        l_Last := 0; -- ранее заведенное изменение
        -- доработано что за базу для заполнения анкеты по персоны мы берем анкету не последнюю в общем жизненном цикле
        -- а последнюю до даты сорца при пустом то до систейта.
        SELECT Scc.*
          INTO r_Scc
          FROM Sc_Change Scc
         WHERE Scc.Scc_Id = (SELECT Coalesce(MAX(Scc_Id), -1)
                               FROM Sc_Change c
                              WHERE c.Scc_Sc = l_Sc
                                    AND Coalesce(c.Scc_Src_Dt, c.Scc_Create_Dt) <= Coalesce(p_Src_Dt, l_Sysdate));

      END IF;

      -- если дата рождения пришла
      IF p_Birth_Dt IS NOT NULL THEN
        <<sc_Birth>>
        BEGIN
          -- по анкете выбираем информацию по дате рождения
          SELECT Scb.*
            INTO r_Scb
            FROM v_Sc_Birth Scb
           WHERE Scb.Scb_Id = Coalesce(r_Scc.Scc_Scb, -1);
          -- если текущая дата рождения отличается от новой даты рождения из параметра
          IF Coalesce(r_Scb.Scb_Dt, To_Date('01.01.1777', 'dd.mm.yyyy')) <> p_Birth_Dt THEN
            -- выбираем была ли у этого пользователя эта дата рождения ранее
            BEGIN
              SELECT Scb.Scb_Id
                INTO r_Scb.Scb_Id
                FROM v_Sc_Birth Scb
               WHERE Scb.Scb_Sc = r_Scc.Scc_Sc
                     AND Scb.Scb_Dt = p_Birth_Dt
                     AND Rownum = 1;
            EXCEPTION
              WHEN No_Data_Found THEN
                r_Scb.Scb_Id := NULL;
            END;
            -- если ранее не использовалась то инсертим
            IF r_Scb.Scb_Id IS NULL THEN
              INSERT INTO Sc_Birth
                (Scb_Id,
                 Scb_Sc,
                 Scb_Sca,
                 Scb_Scd,
                 Scb_Dt,
                 Scb_Note,
                 Scb_Src,
                 Scb_Ln)
              VALUES
                (NULL,
                 l_Sc,
                 -1,
                 -1,
                 p_Birth_Dt,
                 '',
                 p_Src,
                 -1) RETURN Scb_Id INTO r_Scb.Scb_Id;
            END IF;
            -- отмечаем что меняем анкету
            r_Scc.Scc_Id := NULL;
            r_Scc.Scc_Scb := r_Scb.Scb_Id;
          END IF;
        END Sc_Birth;
      END IF;

      -- если есть информация о фио (хоть что-то)
      IF p_Ln IS NOT NULL
         OR p_Fn IS NOT NULL
         OR p_Mn IS NOT NULL THEN
        <<sc_Identity>>
        BEGIN
          -- по анкете выбираем информацию по атрибутике персоны
          SELECT Sci.*
            INTO r_Sci
            FROM v_Sc_Identity Sci
           WHERE Sci.Sci_Id = Coalesce(r_Scc.Scc_Sci, -1);

          -- проверяем национальность/пол если пришло неизвестное значение
          IF (Coalesce(l_Nationality, '-1') = '-1') THEN
            l_Nationality := r_Sci.Sci_Nationality;
          END IF;

          IF (Coalesce(l_Gender, 'V') = 'V') THEN
            l_Gender := r_Sci.Sci_Gender;
          END IF;

          -- если старая инфа отличается от новой
          IF Coalesce(r_Sci.Sci_Ln, '-1') <> Coalesce(p_Ln, '-1')
             OR Coalesce(r_Sci.Sci_Fn, '-1') <> Coalesce(p_Fn, '-1')
             OR Coalesce(r_Sci.Sci_Mn, '-1') <> Coalesce(p_Mn, '-1')
             OR Coalesce(r_Sci.Sci_Gender, 'V') <> Coalesce(l_Gender, 'V')
             OR Coalesce(r_Sci.Sci_Nationality, '-1') <> Coalesce(l_Nationality, '-1') THEN

            -- выбираем была ли у этого пользователя эта инфа по фио ранее
            BEGIN
              SELECT Sci.Sci_Id
                INTO r_Sci.Sci_Id
                FROM v_Sc_Identity Sci
               WHERE Sci.Sci_Sc = r_Scc.Scc_Sc
                     AND Coalesce(Sci.Sci_Ln, '-1') = Coalesce(p_Ln, '-1')
                     AND Coalesce(Sci.Sci_Fn, '-1') = Coalesce(p_Fn, '-1')
                     AND Coalesce(Sci.Sci_Mn, '-1') = Coalesce(p_Mn, '-1')
                     AND Coalesce(Sci.Sci_Gender, 'V') = Coalesce(l_Gender, 'V')
                     AND Coalesce(Sci.Sci_Nationality, '-1') = Coalesce(l_Nationality, '-1')
                     AND Rownum = 1;
            EXCEPTION
              WHEN No_Data_Found THEN
                r_Sci.Sci_Id := NULL;
            END;

            -- если ранее не использовалась то инсертим
            IF r_Sci.Sci_Id IS NULL THEN
              INSERT INTO Sc_Identity
                (Sci_Id,
                 Sci_Sc,
                 Sci_Fn,
                 Sci_Ln,
                 Sci_Mn,
                 Sci_Gender,
                 Sci_Nationality)
              VALUES
                (r_Sci.Sci_Id,
                 l_Sc,
                 p_Fn,
                 p_Ln,
                 p_Mn,
                 l_Gender,
                 l_Nationality) RETURN Sci_Id INTO r_Sci.Sci_Id;
            END IF;
            -- отмечаем что меняем анкету
            r_Scc.Scc_Id := NULL;
            r_Scc.Scc_Sci := r_Sci.Sci_Id;
          END IF;
        END Sc_Identity;
      END IF;

      -------------------------------------------------------------------------
      IF Nullif(p_Inn_Num, '0000000000') IS NOT NULL
         AND p_Inn_Ndt IS NOT NULL THEN
        <<sc_Inn>>
        BEGIN
          BEGIN
            -- находим инн с таким значением
            SELECT d.Scd_Id
              INTO r_Scd.Scd_Id
              FROM v_Sc_Document d
             WHERE d.Scd_Sc = l_Sc
                   AND d.Scd_St IN ('1', '2')
                   AND d.Scd_Ndt = p_Inn_Ndt
                   AND d.Scd_Number = p_Inn_Num;

            -- предыдущий отличный актуальный перводим в неактуальный для последнего среза
            UPDATE v_Sc_Document Ddd
               SET Ddd.Scd_St = CASE
                                  WHEN Ddd.Scd_Id <> r_Scd.Scd_Id THEN
                                   '2'
                                  ELSE
                                   '1'
                                END
             WHERE Ddd.Scd_Sc = l_Sc
                   AND Ddd.Scd_Ndt = p_Inn_Ndt
                   AND Ddd.Scd_St IN ('1', '2')
                   AND l_Last = 1
                   AND Ddd.Scd_St <> CASE
                     WHEN Ddd.Scd_Id <> r_Scd.Scd_Id THEN
                      '2'
                     ELSE
                      '1'
                   END;

            -- не нашли инн, упали в ошибку
          EXCEPTION
            WHEN No_Data_Found THEN
              -- сбрасываем инфу по анкете для образования среза (пересчет ИНФО)
              r_Scd.Scd_Id := NULL;
          END;

          -- если нет инн, создаем
          IF r_Scd.Scd_Id IS NULL THEN
            UPDATE v_Sc_Document Ddd
               SET Ddd.Scd_St = '2'
             WHERE Ddd.Scd_Sc = l_Sc
                   AND Ddd.Scd_Ndt = p_Inn_Ndt
                   AND Ddd.Scd_St = '1'
                   AND l_Last = 1;
            -- вставка документов (ИНН)
            INSERT INTO Sc_Document
              (Scd_Id,
               Scd_Sc,
               Scd_Name,
               Scd_Seria,
               Scd_Number,
               Scd_Issued_Dt,
               Scd_Issued_Who,
               Scd_Start_Dt,
               Scd_Stop_Dt,
               Scd_St,
               Scd_Src,
               Scd_Note,
               Scd_Ndt,
               Scd_Doc,
               Scd_Dh)
            VALUES
              (r_Scd.Scd_Id,
               l_Sc,
               NULL,
               NULL,
               p_Inn_Num,
               NULL,
               NULL,
               NULL,
               NULL,
               Decode(l_Last, 1, '1', '2'),
               p_Src,
               NULL,
               p_Inn_Ndt,
               NULL,
               NULL);

          END IF;
        END Sc_Inn;
      END IF;

      --------------------------------------------------------------------------------------------
      IF REPLACE(REPLACE(p_Doc_Ser || p_Doc_Num, '-', ''), ' ', '') IS NOT NULL
         AND p_Doc_Ndt IS NOT NULL THEN
        <<sc_Doc>>
        BEGIN
          -- если актуального паспорта нет то ищем просто паспорт у этого документва с таким же значением для перевода его в статус актуальный
          -- если анкета не актуальная, но документ актуальный то статус не меняем, если анкета актуальная а инн не актуальный повышаем статус документа до актуального
          BEGIN
            -- поиск документа по ндт среди (13 clas)
            SELECT d.Scd_Id
              INTO r_Scd.Scd_Id
              FROM (SELECT d.Scd_Id,
                           Row_Number() Over(ORDER BY Decode(d.Scd_Ndt, p_Doc_Ndt, 0, 1), Tt.Ndt_Sc_Upd_Priority) AS Rn
                      FROM v_Sc_Document d
                      JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                        ON Tt.Ndt_Id = d.Scd_Ndt -- выбор по классу
                      JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                        ON Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                           AND Coalesce(Tc.Ndt_Uniq_Group, To_Char(Tc.Ndt_Id)) = Coalesce(Tt.Ndt_Uniq_Group, To_Char(Tt.Ndt_Id))

                     WHERE d.Scd_Sc = l_Sc
                           AND d.Scd_St IN ('1', '2')
                           AND Tc.Ndt_Id = p_Doc_Ndt
                           AND Upper(REPLACE(REPLACE(d.Scd_Seria || d.Scd_Number, '-', ''), ' ', '')) =
                           Upper(REPLACE(REPLACE(p_Doc_Ser || p_Doc_Num, '-', ''), ' ', ''))) d
             WHERE Rn = 1;

            -- для последнего обновления, повышаем уровень документа до 1 - актуальный
            -- обнавляем параметры документа если изменения последние
            UPDATE Sc_Document Ddd
               SET Ddd.Scd_St         = '1',
                   Ddd.Scd_Ndt        = p_Doc_Ndt,
                   Ddd.Scd_Issued_Dt  = Coalesce(p_Doc_Bdt, Ddd.Scd_Issued_Dt),
                   Ddd.Scd_Issued_Who = Coalesce(p_Doc_Is, Ddd.Scd_Issued_Who),
                   Ddd.Scd_Start_Dt   = Coalesce(p_Doc_Bdt, Ddd.Scd_Issued_Dt),
                   Ddd.Scd_Stop_Dt    = Coalesce(p_Doc_Edt, Ddd.Scd_Stop_Dt)
             WHERE Ddd.Scd_Id = r_Scd.Scd_Id
                   AND Ddd.Scd_Sc = l_Sc
                   AND l_Last = 1;

            -- не нашли document, упали в ошибку
          EXCEPTION
            WHEN No_Data_Found THEN
              -- вставка документa
              INSERT INTO Sc_Document
                (Scd_Id,
                 Scd_Sc,
                 Scd_Name,
                 Scd_Seria,
                 Scd_Number,
                 Scd_Issued_Dt,
                 Scd_Issued_Who,
                 Scd_Start_Dt,
                 Scd_Stop_Dt,
                 Scd_St,
                 Scd_Src,
                 Scd_Note,
                 Scd_Ndt,
                 Scd_Doc,
                 Scd_Dh)
              VALUES
                (NULL,
                 l_Sc,
                 NULL,
                 p_Doc_Ser,
                 p_Doc_Num,
                 p_Doc_Bdt,
                 p_Doc_Is,
                 p_Doc_Bdt,
                 p_Doc_Edt,
                 Decode(l_Last, 1, '1', '2'),
                 p_Src,
                 p_Note,
                 p_Doc_Ndt,
                 NULL,
                 NULL)
              RETURNING Scd_Id INTO r_Scd.Scd_Id;
          END;

          -- все остальные документы данной группы переводим в неактуальные
          -- а с похожими номерами в рамках группы в дубли
          UPDATE Sc_Document Ddd
             SET Ddd.Scd_St = CASE
                                WHEN Upper(REPLACE(REPLACE(Ddd.Scd_Seria || Ddd.Scd_Number, '-', ''), ' ', '')) <>
                                     Upper(REPLACE(REPLACE(p_Doc_Ser || p_Doc_Num, '-', ''), ' ', '')) THEN
                                 '2'
                                ELSE
                                 '4'
                              END
           WHERE Ddd.Scd_Id <> r_Scd.Scd_Id
                 AND Ddd.Scd_Sc = l_Sc
                 AND Ddd.Scd_St IN ('1', '2')
                 AND l_Last = 1
                 AND Ddd.Scd_Ndt IN
                 (SELECT Tc.Ndt_Id
                        FROM Uss_Ndi.v_Ndi_Document_Type Tt
                        JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                          ON Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                             AND Coalesce(Tc.Ndt_Uniq_Group, To_Char(Tc.Ndt_Id)) = Coalesce(Tt.Ndt_Uniq_Group, To_Char(Tt.Ndt_Id))
                       WHERE Tt.Ndt_Id = p_Doc_Ndt);
        END Sc_Doc;
      END IF;

      -------
      IF r_Scc.Scc_Id IS NULL THEN
        -- вставка анкеты (срез информации о персоне)
        INSERT INTO Sc_Change
          (Scc_Id,
           Scc_Sc,
           Scc_Create_Dt,
           Scc_Src,
           Scc_Sct,
           Scc_Sci,
           Scc_Scb,
           Scc_Sca,
           Scc_Sch,
           Scc_Scp,
           Scc_Src_Dt)
        VALUES
          (r_Scc.Scc_Id,
           l_Sc,
           l_Sysdate,
           p_Src,
           r_Scc.Scc_Sct,
           r_Scc.Scc_Sci,
           r_Scc.Scc_Scb,
           r_Scc.Scc_Sca,
           r_Scc.Scc_Sch,
           r_Scc.Scc_Scp,
           Coalesce(p_Src_Dt, l_Sysdate)) RETURN Scc_Id INTO r_Scc.Scc_Id;

        -- если анкета последняя то на нее ссылаемя у карточки
        IF l_Last = 1 THEN
          -- сылка на новую анкету
          UPDATE Socialcard Ddd
             SET Ddd.Sc_Scc = r_Scc.Scc_Id
           WHERE Ddd.Sc_Id = l_Sc
                 AND Ddd.Sc_Scc <> Coalesce(r_Scc.Scc_Id, -1);
        END IF;
      END IF;
      -- если изменения последние то на всяк случай передергиваем инфо
      IF l_Last = 1 THEN
        Init_Sc_Info(p_Sc_Id => l_Sc);
      END IF;
      -- ОПРЕДЕЛЯЕМ ЗНАЧЕНИЕ АНКЕТЫ ПЕРСОНЫ КОТОРАЯ БЫЛА СОЗДАНА ИЛИ НА ОСНОВАНИИ КОТОРОЙ БЫЛО НАЙДЕНО ПЕРСОНУ
      p_Sc_Scc := r_Scc.Scc_Id;
    END;*/

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
        p_Scbc_St                 Sc_Benefit_Category.Scbc_St%TYPE DEFAULT 'A')
    IS
    BEGIN
        --оновлення інформації
        IF p_Scbc_Id IS NOT NULL
        THEN
            UPDATE Sc_Benefit_Category
               SET Scbc_Sc = p_Scbc_Sc,
                   Scbc_Nbc = p_Scbc_Nbc,
                   Scbc_Start_Dt = p_Scbc_Start_Dt,
                   Scbc_Stop_Dt = p_Scbc_Stop_Dt,
                   Scbc_Src = p_Scbc_Src,
                   Scbc_Create_Dt = p_Scbc_Create_Dt,
                   Scbc_St = p_Scbc_St,
                   Scbc_Modify_Dt = SYSDATE
             WHERE Scbc_Id = p_Scbc_Id;
        ELSE
            --створення нового запису по пільговій категорії
            --закриття існуючого запису про наявність категорії
            UPDATE Sc_Benefit_Category
               SET Scbc_Modify_Dt = SYSDATE, Scbc_St = 'H'
             WHERE     Scbc_Sc = p_Scbc_Sc
                   AND Scbc_Nbc = p_Scbc_Nbc
                   AND Scbc_St = 'A';

            INSERT INTO Sc_Benefit_Category (Scbc_Id,
                                             Scbc_Sc,
                                             Scbc_Nbc,
                                             Scbc_Start_Dt,
                                             Scbc_Stop_Dt,
                                             Scbc_Src,
                                             Scbc_Create_Dt,
                                             Scbc_Modify_Dt,
                                             Scbc_St)
                 VALUES (0,
                         p_Scbc_Sc,
                         p_Scbc_Nbc,
                         p_Scbc_Start_Dt,
                         p_Scbc_Stop_Dt,
                         p_Scbc_Src,
                         p_Scbc_Create_Dt,
                         NULL,
                         COALESCE (p_Scbc_St, 'A'))
              RETURNING Scbc_Id
                   INTO p_Scbc_Id;

            --оновлення інформації по пільзі
            UPDATE Sc_Benefit_Type b
               SET b.Scbt_Modify_Dt = SYSDATE, b.Scbt_St = 'H'
             WHERE     b.Scbt_Sc = p_Scbc_Sc
                   AND b.Scbt_Nbt IN (SELECT s.Nbcs_Nbt
                                        FROM Uss_Ndi.v_Ndi_Nbc_Setup s
                                       WHERE s.Nbcs_Nbc = p_Scbc_Nbc)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM Sc_Benefit_Category c
                             WHERE     c.Scbc_Id = b.Scbt_Scbc
                                   AND c.Scbc_St = 'A');

            INSERT INTO Sc_Benefit_Type (Scbt_Id,
                                         Scbt_Sc,
                                         Scbt_Nbt,
                                         Scbt_Start_Dt,
                                         Scbt_Stop_Dt,
                                         Scbt_Src,
                                         Scbt_Create_Dt,
                                         Scbt_Modify_Dt,
                                         Scbt_St,
                                         Scbt_Scbc)
                SELECT 0,
                       p_Scbc_Sc,
                       s.Nbcs_Nbt,
                       NULL,
                       NULL,
                       p_Scbc_Src,
                       SYSDATE,
                       NULL,
                       'A',
                       p_Scbc_Id
                  FROM Uss_Ndi.v_Ndi_Nbc_Setup s
                 WHERE s.Nbcs_Nbc = p_Scbc_Nbc;
        END IF;
    END;

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
        p_Scbt_Scbc               Sc_Benefit_Type.Scbt_Scbc%TYPE)
    IS
    BEGIN
        --оновлення інформації
        IF p_Scbt_Id IS NOT NULL
        THEN
            UPDATE Sc_Benefit_Type
               SET Scbt_Sc = p_Scbt_Sc,
                   Scbt_Nbt = p_Scbt_Nbt,
                   Scbt_Start_Dt = p_Scbt_Start_Dt,
                   Scbt_Stop_Dt = p_Scbt_Stop_Dt,
                   Scbt_Src = p_Scbt_Src,
                   Scbt_Create_Dt = p_Scbt_Create_Dt,
                   Scbt_St = p_Scbt_St,
                   Scbt_Scbc = p_Scbt_Scbc,
                   Scbt_Modify_Dt = SYSDATE
             WHERE Scbt_Id = p_Scbt_Id;
        ELSE
            --додавання інформації
            INSERT INTO Sc_Benefit_Type (Scbt_Id,
                                         Scbt_Sc,
                                         Scbt_Nbt,
                                         Scbt_Start_Dt,
                                         Scbt_Stop_Dt,
                                         Scbt_Src,
                                         Scbt_Create_Dt,
                                         Scbt_Modify_Dt,
                                         Scbt_St,
                                         Scbt_Scbc)
                 VALUES (0,
                         p_Scbt_Sc,
                         p_Scbt_Nbt,
                         p_Scbt_Start_Dt,
                         p_Scbt_Stop_Dt,
                         p_Scbt_Src,
                         p_Scbt_Create_Dt,
                         NULL,
                         p_Scbt_St,
                         p_Scbt_Scbc)
              RETURNING Scbt_Id
                   INTO p_Scbt_Id;
        END IF;
    END;

    -- info:   встановлення пільг особі
    -- params:
    -- note:
    PROCEDURE Set_Sc_Benefits (
        p_Scbc_Sc             Sc_Benefit_Category.Scbc_Sc%TYPE,
        p_Scbc_Nbc            Sc_Benefit_Category.Scbc_Nbc%TYPE,
        p_Scbc_Start_Dt       Sc_Benefit_Category.Scbc_Start_Dt%TYPE,
        p_Scbc_Stop_Dt        Sc_Benefit_Category.Scbc_Stop_Dt%TYPE,
        p_Scbc_Src            Sc_Benefit_Category.Scbc_Src%TYPE,
        p_Scbc_Id         OUT Sc_Benefit_Category.Scbc_Id%TYPE)
    IS
        v_Scbc_Id         Sc_Benefit_Category.Scbc_Id%TYPE;
        v_Scbc_Start_Dt   Sc_Benefit_Category.Scbc_Start_Dt%TYPE;
        v_Scbc_Stop_Dt    Sc_Benefit_Category.Scbc_Stop_Dt%TYPE;
    BEGIN
        SELECT MAX (c.Scbc_Id), MAX (c.Scbc_Start_Dt), MAX (c.Scbc_Stop_Dt)
          INTO v_Scbc_Id, v_Scbc_Start_Dt, v_Scbc_Stop_Dt
          FROM Sc_Benefit_Category c
         WHERE     c.Scbc_Sc = p_Scbc_Sc
               AND c.Scbc_Nbc = p_Scbc_Nbc
               AND c.Scbc_St = 'A';

        --закриття існуючих записів
        IF v_Scbc_Id IS NOT NULL
        THEN
            UPDATE Sc_Benefit_Category
               SET Scbc_Modify_Dt = SYSDATE, Scbc_St = 'H'
             WHERE Scbc_Id = v_Scbc_Id;

            UPDATE Sc_Benefit_Type b
               SET b.Scbt_Modify_Dt = SYSDATE, b.Scbt_St = 'H'
             WHERE     b.Scbt_Sc = p_Scbc_Sc
                   AND b.Scbt_Nbt IN (SELECT s.Nbcs_Nbt
                                        FROM Uss_Ndi.v_Ndi_Nbc_Setup s
                                       WHERE s.Nbcs_Nbc = p_Scbc_Nbc)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM Sc_Benefit_Category c
                             WHERE     c.Scbc_Id = b.Scbt_Scbc
                                   AND c.Scbc_St = 'A');
        END IF;

        --збереження інформації про категорії пільг
        INSERT INTO Sc_Benefit_Category (Scbc_Id,
                                         Scbc_Sc,
                                         Scbc_Nbc,
                                         Scbc_Start_Dt,
                                         Scbc_Stop_Dt,
                                         Scbc_Src,
                                         Scbc_Create_Dt,
                                         Scbc_Modify_Dt,
                                         Scbc_St)
             VALUES (0,
                     p_Scbc_Sc,
                     p_Scbc_Nbc,
                     p_Scbc_Start_Dt,
                     p_Scbc_Stop_Dt,
                     p_Scbc_Src,
                     SYSDATE,
                     NULL,
                     'A')
          RETURNING Scbc_Id
               INTO p_Scbc_Id;

        --збереження інформації про пільги
        INSERT INTO Sc_Benefit_Type (Scbt_Id,
                                     Scbt_Sc,
                                     Scbt_Nbt,
                                     Scbt_Start_Dt,
                                     Scbt_Stop_Dt,
                                     Scbt_Src,
                                     Scbt_Create_Dt,
                                     Scbt_Modify_Dt,
                                     Scbt_St,
                                     Scbt_Scbc)
            SELECT 0,
                   p_Scbc_Sc,
                   s.Nbcs_Nbt,
                   p_Scbc_Start_Dt,
                   p_Scbc_Stop_Dt,
                   p_Scbc_Src,
                   SYSDATE,
                   NULL,
                   'A',
                   p_Scbc_Id
              FROM Uss_Ndi.v_Ndi_Nbc_Setup s
             WHERE s.Nbcs_Nbc = p_Scbc_Nbc;
    END;

    FUNCTION Get_Sc_Scf (p_Scf_Sc IN NUMBER)
        RETURN NUMBER
    IS
        l_Scf_Id   NUMBER;
    BEGIN
        SELECT MAX (Scf_Id)
          INTO l_Scf_Id
          FROM Sc_Feature
         WHERE Scf_Sc = p_Scf_Sc;

        RETURN l_Scf_Id;
    END;

    --Дані особи в ПФУ
    PROCEDURE Save_Sc_Pfu_Data_Ident (
        p_Scdi_Id             OUT Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Scdi_Sc          IN     Sc_Pfu_Data_Ident.Scdi_Sc%TYPE DEFAULT NULL,
        p_Scdi_Ip_Unique   IN     Sc_Pfu_Data_Ident.Scdi_Ip_Unique%TYPE DEFAULT NULL,
        p_Scdi_Ip_Pt       IN     Sc_Pfu_Data_Ident.Scdi_Ip_Pt%TYPE DEFAULT NULL,
        p_Scdi_Ln          IN     Sc_Pfu_Data_Ident.Scdi_Ln%TYPE DEFAULT NULL,
        p_Scdi_Fn          IN     Sc_Pfu_Data_Ident.Scdi_Fn%TYPE DEFAULT NULL,
        p_Scdi_Mn          IN     Sc_Pfu_Data_Ident.Scdi_Mn%TYPE DEFAULT NULL,
        p_Scdi_Unzr        IN     Sc_Pfu_Data_Ident.Scdi_Unzr%TYPE DEFAULT NULL,
        p_Scdi_Numident    IN     Sc_Pfu_Data_Ident.Scdi_Numident%TYPE DEFAULT NULL,
        p_Scdi_Doc_Tp      IN     Sc_Pfu_Data_Ident.Scdi_Doc_Tp%TYPE DEFAULT NULL,
        p_Scdi_Doc_Sn      IN     Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE DEFAULT NULL,
        p_Scdi_Nt          IN     Sc_Pfu_Data_Ident.Scdi_Nt%TYPE DEFAULT NULL,
        p_Scdi_Sex         IN     Sc_Pfu_Data_Ident.Scdi_Sex%TYPE DEFAULT NULL,
        p_Scdi_Birthday    IN     Sc_Pfu_Data_Ident.Scdi_Birthday%TYPE DEFAULT NULL,
        p_Scdi_Dd_Dt       IN     Sc_Pfu_Data_Ident.Scdi_Dd_Dt%TYPE DEFAULT NULL,
        p_Rn_Id            IN     Sc_Pfu_Data_Ident.Scdi_Rn%TYPE DEFAULT NULL,
        p_Phone_Mob        IN     Sc_Pfu_Data_Ident.Scdi_Phone_Mob%TYPE DEFAULT NULL,
        p_Phone_Num        IN     Sc_Pfu_Data_Ident.Scdi_Phone_Num%TYPE DEFAULT NULL,
        p_Email            IN     Sc_Pfu_Data_Ident.Scdi_Email%TYPE DEFAULT NULL,
        p_Nrt_Id           IN     Sc_Pfu_Data_Ident.Scdi_Nrt%TYPE DEFAULT NULL,
        p_Ext_Ident        IN     Sc_Pfu_Data_Ident.Scdi_Ext_Ident%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Pfu_Data_Ident (Scdi_Sc,
                                       Scdi_Ip_Unique,
                                       Scdi_Ip_Pt,
                                       Scdi_Ln,
                                       Scdi_Fn,
                                       Scdi_Mn,
                                       Scdi_Unzr,
                                       Scdi_Numident,
                                       Scdi_Doc_Tp,
                                       Scdi_Doc_Sn,
                                       Scdi_Nt,
                                       Scdi_Sex,
                                       Scdi_Birthday,
                                       Scdi_Dd_Dt,
                                       Scdi_Rn,
                                       Scdi_Phone_Mob,
                                       Scdi_Phone_Num,
                                       Scdi_Email,
                                       Scdi_St,
                                       Scdi_Nrt,
                                       Scdi_Ext_Ident)
             VALUES (p_Scdi_Sc,
                     p_Scdi_Ip_Unique,
                     p_Scdi_Ip_Pt,
                     p_Scdi_Ln,
                     p_Scdi_Fn,
                     p_Scdi_Mn,
                     p_Scdi_Unzr,
                     p_Scdi_Numident,
                     p_Scdi_Doc_Tp,
                     p_Scdi_Doc_Sn,
                     p_Scdi_Nt,
                     p_Scdi_Sex,
                     p_Scdi_Birthday,
                     p_Scdi_Dd_Dt,
                     p_Rn_Id,
                     p_Phone_Mob,
                     p_Phone_Num,
                     p_Email,
                     'VR',
                     p_Nrt_Id,
                     p_Ext_Ident/*Потребує верифікації*/
                                )
          RETURNING Scdi_Id
               INTO p_Scdi_Id;
    END;

    PROCEDURE Save_Sc_Pfu_Address (
        p_Scpa_Id             OUT Sc_Pfu_Address.Scpa_Id%TYPE,
        p_Scpa_Sc          IN     Sc_Pfu_Address.Scpa_Sc%TYPE DEFAULT NULL,
        p_Scpa_Scdi        IN     Sc_Pfu_Address.Scpa_Scdi%TYPE,
        p_Scpa_Tp          IN     Sc_Pfu_Address.Scpa_Tp%TYPE,
        p_Scpa_Kaot_Code   IN     Sc_Pfu_Address.Scpa_Kaot_Code%TYPE,
        p_Scpa_Postcode    IN     Sc_Pfu_Address.Scpa_Postcode%TYPE,
        p_Scpa_City        IN     Sc_Pfu_Address.Scpa_City%TYPE DEFAULT NULL,
        p_Scpa_Street      IN     Sc_Pfu_Address.Scpa_Street%TYPE,
        p_Scpa_Building    IN     Sc_Pfu_Address.Scpa_Building%TYPE,
        p_Scpa_Block       IN     Sc_Pfu_Address.Scpa_Block%TYPE,
        p_Scpa_Apartment   IN     Sc_Pfu_Address.Scpa_Apartment%TYPE,
        p_Scpa_St          IN     Sc_Pfu_Address.Scpa_St%TYPE DEFAULT 'A')
    IS
    BEGIN
        INSERT INTO Sc_Pfu_Address (Scpa_Sc,
                                    Scpa_Scdi,
                                    Scpa_Tp,
                                    Scpa_Kaot_Code,
                                    Scpa_Postcode,
                                    Scpa_City,
                                    Scpa_Street,
                                    Scpa_Building,
                                    Scpa_Block,
                                    Scpa_Apartment,
                                    Scpa_Create_Dt,
                                    Scpa_St)
             VALUES (p_Scpa_Sc,
                     p_Scpa_Scdi,
                     p_Scpa_Tp,
                     p_Scpa_Kaot_Code,
                     p_Scpa_Postcode,
                     p_Scpa_City,
                     p_Scpa_Street,
                     p_Scpa_Building,
                     p_Scpa_Block,
                     p_Scpa_Apartment,
                     SYSDATE,
                     p_Scpa_St)
          RETURNING Scpa_Id
               INTO p_Scpa_Id;
    END;

    --Домогосподарство
    PROCEDURE Save_Sc_Household (
        p_Schh_Id                OUT Sc_Household.Schh_Id%TYPE,
        p_Schh_Sc             IN     Sc_Household.Schh_Sc%TYPE,
        p_Schh_Sca            IN     Sc_Household.Schh_Sca%TYPE,
        p_Schh_Full_Area      IN     Sc_Household.Schh_Full_Area%TYPE,
        p_Schh_Heating_Area   IN     Sc_Household.Schh_Heating_Area%TYPE)
    IS
    BEGIN
        Save_Sc_Household (p_Schh_Id                 => p_Schh_Id,
                           p_Schh_Sc                 => p_Schh_Sc,
                           p_Schh_Scdi               => NULL,
                           p_Schh_Sca                => p_Schh_Sca,
                           p_Schh_Scpa               => NULL,
                           p_Schh_Full_Area          => p_Schh_Full_Area,
                           p_Schh_Heating_Area       => p_Schh_Heating_Area,
                           p_Schh_Pfu_Id             => NULL,
                           p_Schh_Is_Separate_Bill   => NULL,
                           p_Schh_Floor_Cnt          => NULL,
                           p_Schh_Build_Tp           => NULL,
                           p_Schh_Fam_Tp             => NULL);
    END;

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
        p_Schh_Build_Tp           IN     Sc_Household.Schh_Build_Tp%TYPE, /*V_DDN_SCHH_BUILD_TP*/
        p_Schh_Fam_Tp             IN     Sc_Household.Schh_Fam_Tp%TYPE /*V_DDN_SCHH_FAM_TP*/
                                                                      )
    IS
    BEGIN
        INSERT INTO Sc_Household (Schh_Sc,
                                  Schh_Scdi,
                                  Schh_Sca,
                                  Schh_Scpa,
                                  Schh_Full_Area,
                                  Schh_Heating_Area,
                                  Schh_Pfu_Id,
                                  Schh_Is_Separate_Bill,
                                  Schh_Floor_Cnt,
                                  Schh_Build_Tp,
                                  Schh_Fam_Tp,
                                  Schh_St)
             VALUES (p_Schh_Sc,
                     p_Schh_Scdi,
                     p_Schh_Sca,
                     p_Schh_Scpa,
                     p_Schh_Full_Area,
                     p_Schh_Heating_Area,
                     p_Schh_Pfu_Id,
                     p_Schh_Is_Separate_Bill,
                     p_Schh_Floor_Cnt,
                     p_Schh_Build_Tp,
                     p_Schh_Fam_Tp,
                     'VR'                             /*Потребує верифікації*/
                         )
          RETURNING Schh_Id
               INTO p_Schh_Id;
    END;

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
        p_Scpp_Pfu_Com_Org       IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Com_Org%TYPE)
    IS
    BEGIN
        Save_Sc_Pfu_Pay_Summary (
            p_Scpp_Id                    => p_Scpp_Id,
            p_Scpp_Sc                    => p_Scpp_Sc,
            p_Scpp_Pfu_Pd_Id             => p_Scpp_Pfu_Pd_Id,
            p_Scpp_Pfu_Payment_Tp        => p_Scpp_Pfu_Payment_Tp,
            p_Scpp_Pfu_Pd_Dt             => p_Scpp_Pfu_Pd_Dt,
            p_Scpp_Pfu_Pd_Start_Dt       => p_Scpp_Pfu_Pd_Start_Dt,
            p_Scpp_Pfu_Pd_Stop_Dt        => p_Scpp_Pfu_Pd_Stop_Dt,
            p_Scpp_Pfu_Pd_St             => p_Scpp_Pfu_Pd_St,
            p_Scpp_Change_Dt             => p_Scpp_Change_Dt,
            p_Scpp_Sum                   => p_Scpp_Sum,
            p_Scpp_Schh                  => p_Scpp_Schh,
            p_Scpp_St                    => p_Scpp_St,
            p_Scpp_Pfu_Com_Org           => p_Scpp_Pfu_Com_Org,
            p_Scpp_Scdi                  => NULL,
            p_Scpp_Income_Amount         => NULL,
            p_Scpp_Avg_Income_Amount     => NULL,
            p_Scpp_Pfu_Pc_Num            => NULL,
            p_Scpp_Pfu_Pd_Num            => NULL,
            p_Scpp_Pfu_Appeal_Dt         => NULL,
            p_Scpp_Pfu_Norm_Act          => NULL,
            p_Scpp_Pfu_Scr               => NULL,
            p_Scpp_Pfu_Refuse_Reason     => NULL,
            p_Scpp_Start_Dt              => NULL,
            p_Scpp_Stop_Dt               => NULL,
            p_Scpp_Pd_Features           => NULL,
            p_Scpp_Income_Include_Mark   => NULL);
    END;

    --Зведена інформація по призначенню виплат в ПФУ
    PROCEDURE Save_Sc_Pfu_Pay_Summary (
        p_Scpp_Id                       OUT Sc_Pfu_Pay_Summary.Scpp_Id%TYPE,
        p_Scpp_Sc                    IN     Sc_Pfu_Pay_Summary.Scpp_Sc%TYPE, --Ід соціальної картки
        p_Scpp_Pfu_Pd_Id             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE,
        p_Scpp_Pfu_Payment_Tp        IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Payment_Tp%TYPE,
        p_Scpp_Pfu_Pd_Dt             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Dt%TYPE,
        p_Scpp_Pfu_Pd_Start_Dt       IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Start_Dt%TYPE,
        p_Scpp_Pfu_Pd_Stop_Dt        IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Stop_Dt%TYPE,
        p_Scpp_Pfu_Pd_St             IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_St%TYPE,
        p_Scpp_Change_Dt             IN     Sc_Pfu_Pay_Summary.Scpp_Change_Dt%TYPE,
        p_Scpp_Sum                   IN     Sc_Pfu_Pay_Summary.Scpp_Sum%TYPE,
        p_Scpp_Schh                  IN     Sc_Pfu_Pay_Summary.Scpp_Schh%TYPE, --Ід домогосподарства
        p_Scpp_St                    IN     Sc_Pfu_Pay_Summary.Scpp_St%TYPE,
        p_Scpp_Pfu_Com_Org           IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Com_Org%TYPE,
        p_Scpp_Scdi                  IN     Sc_Pfu_Pay_Summary.Scpp_Scdi%TYPE,
        p_Scpp_Income_Amount         IN     Sc_Pfu_Pay_Summary.Scpp_Income_Amount%TYPE,
        p_Scpp_Avg_Income_Amount     IN     Sc_Pfu_Pay_Summary.Scpp_Avg_Income_Amount%TYPE,
        p_Scpp_Pfu_Pc_Num            IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pc_Num%TYPE,
        p_Scpp_Pfu_Pd_Num            IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Num%TYPE,
        p_Scpp_Pfu_Appeal_Dt         IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Appeal_Dt%TYPE,
        p_Scpp_Pfu_Norm_Act          IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Norm_Act%TYPE, /*V_DDN_SCPP_PFU_NORM_ACT*/
        p_Scpp_Pfu_Scr               IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Scr%TYPE, /*V_DDN_SCPP_PFU_SCR*/
        p_Scpp_Pfu_Refuse_Reason     IN     Sc_Pfu_Pay_Summary.Scpp_Pfu_Refuse_Reason%TYPE,
        p_Scpp_Start_Dt              IN     Sc_Pfu_Pay_Summary.Scpp_Start_Dt%TYPE,
        p_Scpp_Stop_Dt               IN     Sc_Pfu_Pay_Summary.Scpp_Stop_Dt%TYPE,
        p_Scpp_Pd_Features           IN     Sc_Pfu_Pay_Summary.Scpp_Pd_Features%TYPE, /*V_DDN_SCPF_PD_FEATURES*/
        p_Scpp_Income_Include_Mark   IN     Sc_Pfu_Pay_Summary.Scpp_Income_Include_Mark%TYPE /*V_DDN_SCPF_INCOME_INCLUDE_MARK*/
                                                                                            )
    IS
    BEGIN
        INSERT INTO Sc_Pfu_Pay_Summary (Scpp_Sc,
                                        Scpp_Pfu_Pd_Id,
                                        Scpp_Pfu_Payment_Tp,
                                        Scpp_Pfu_Pd_Dt,
                                        Scpp_Pfu_Pd_Start_Dt,
                                        Scpp_Pfu_Pd_Stop_Dt,
                                        Scpp_Pfu_Pd_St,
                                        Scpp_Change_Dt,
                                        Scpp_Sum,
                                        Scpp_Schh,
                                        Scpp_St,
                                        Scpp_Pfu_Com_Org,
                                        Scpp_Scdi,
                                        Scpp_Income_Amount,
                                        Scpp_Avg_Income_Amount,
                                        Scpp_Pfu_Pc_Num,
                                        Scpp_Pfu_Pd_Num,
                                        Scpp_Pfu_Appeal_Dt,
                                        Scpp_Pfu_Norm_Act,
                                        Scpp_Pfu_Scr,
                                        Scpp_Pfu_Refuse_Reason,
                                        Scpp_Start_Dt,
                                        Scpp_Stop_Dt,
                                        Scpp_Pd_Features,
                                        Scpp_Income_Include_Mark,
                                        history_status)
             VALUES (p_Scpp_Sc,
                     p_Scpp_Pfu_Pd_Id,
                     p_Scpp_Pfu_Payment_Tp,
                     p_Scpp_Pfu_Pd_Dt,
                     p_Scpp_Pfu_Pd_Start_Dt,
                     p_Scpp_Pfu_Pd_Stop_Dt,
                     p_Scpp_Pfu_Pd_St,
                     p_Scpp_Change_Dt,
                     p_Scpp_Sum,
                     p_Scpp_Schh,
                     p_Scpp_St,
                     p_Scpp_Pfu_Com_Org,
                     p_Scpp_Scdi,
                     p_Scpp_Income_Amount,
                     p_Scpp_Avg_Income_Amount,
                     p_Scpp_Pfu_Pc_Num,
                     p_Scpp_Pfu_Pd_Num,
                     p_Scpp_Pfu_Appeal_Dt,
                     p_Scpp_Pfu_Norm_Act,
                     p_Scpp_Pfu_Scr,
                     p_Scpp_Pfu_Refuse_Reason,
                     p_Scpp_Start_Dt,
                     p_Scpp_Stop_Dt,
                     p_Scpp_Pd_Features,
                     p_Scpp_Income_Include_Mark,
                     'A')
          RETURNING Scpp_Id
               INTO p_Scpp_Id;
    END;

    --Дані про родину щодо призначеної виплати ПФУ
    PROCEDURE Save_Sc_Scpp_Family (p_Scpf_Id               OUT NUMBER,
                                   p_Scpf_Scpp          IN     NUMBER,
                                   p_Scpf_Sc            IN     NUMBER,
                                   p_Scpf_Sc_Main       IN     NUMBER,
                                   p_Scpf_Relation_Tp   IN     VARCHAR2,
                                   p_Scpf_Marital_St    IN     VARCHAR2)
    IS
    BEGIN
        Save_Sc_Scpp_Family (p_Scpf_Id                    => p_Scpf_Id,
                             p_Scpf_Scpp                  => p_Scpf_Scpp,
                             p_Scpf_Sc                    => p_Scpf_Sc,
                             p_Scpf_Sc_Main               => p_Scpf_Sc_Main,
                             p_Scpf_Scdi                  => NULL,
                             p_Scpf_Scdi_Main             => NULL,
                             p_Scpf_Relation_Tp           => p_Scpf_Relation_Tp,
                             p_Scpf_Marital_St            => p_Scpf_Marital_St,
                             p_Scpf_Incapacity_Category   => NULL,
                             p_Scpf_Is_Vpo                => NULL);
    END;

    --Дані про родину щодо призначеної виплати ПФУ
    PROCEDURE Save_Sc_Scpp_Family (
        p_Scpf_Id                       OUT NUMBER,
        p_Scpf_Scpp                  IN     Sc_Scpp_Family.Scpf_Scpp%TYPE,
        p_Scpf_Sc                    IN     Sc_Scpp_Family.Scpf_Sc%TYPE,
        p_Scpf_Sc_Main               IN     Sc_Scpp_Family.Scpf_Sc_Main%TYPE,
        p_Scpf_Scdi                  IN     Sc_Scpp_Family.Scpf_Scdi%TYPE,
        p_Scpf_Scdi_Main             IN     Sc_Scpp_Family.Scpf_Scdi_Main%TYPE,
        p_Scpf_Relation_Tp           IN     Sc_Scpp_Family.Scpf_Relation_Tp%TYPE, /*V_DDN_SCPF_RELATION_TP*/
        p_Scpf_Marital_St            IN     Sc_Scpp_Family.Scpf_Marital_St%TYPE,
        p_Scpf_Incapacity_Category   IN     Sc_Scpp_Family.Scpf_Incapacity_Category%TYPE, /*V_DDN_SCPF_INCAPACITY_CATEGORY*/
        p_Scpf_Is_Vpo                IN     Sc_Scpp_Family.Scpf_Is_Vpo%TYPE, /*V_DDN_SCPF_IS_VPO*/
        p_Scpf_St                    IN     Sc_Scpp_Family.Scpf_St%TYPE DEFAULT 'A')
    IS
    BEGIN
        INSERT INTO Sc_Scpp_Family (Scpf_Scpp,
                                    Scpf_Sc,
                                    Scpf_Sc_Main,
                                    Scpf_Scdi,
                                    Scpf_Scdi_Main,
                                    Scpf_Relation_Tp,
                                    Scpf_Marital_St,
                                    Scpf_Incapacity_Category,
                                    Scpf_Is_Vpo,
                                    Scpf_St,
                                    history_status)
             VALUES (p_Scpf_Scpp,
                     p_Scpf_Sc,
                     p_Scpf_Sc_Main,
                     p_Scpf_Scdi,
                     p_Scpf_Scdi_Main,
                     p_Scpf_Relation_Tp,
                     p_Scpf_Marital_St,
                     p_Scpf_Incapacity_Category,
                     p_Scpf_Is_Vpo,
                     p_Scpf_St,
                     'A')
          RETURNING Scpf_Id
               INTO p_Scpf_Id;
    END;

    PROCEDURE Save_Sc_Death (
        p_Sch_Id        IN     Sc_Death.Sch_Id%TYPE,
        p_Sch_Scd       IN     Sc_Death.Sch_Scd%TYPE,
        p_Sch_Dt        IN     Sc_Death.Sch_Dt%TYPE,
        p_Sch_Note      IN     Sc_Death.Sch_Note%TYPE,
        p_Sch_Src       IN     Sc_Death.Sch_Src%TYPE,
        p_Sch_Sc        IN     Sc_Death.Sch_Sc%TYPE,
        p_Sch_Is_Dead   IN     Sc_Death.Sch_Is_Dead%TYPE,
        p_New_Id           OUT Sc_Death.Sch_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Death (Sch_Id,
                              Sch_Scd,
                              Sch_Dt,
                              Sch_Note,
                              Sch_Src,
                              Sch_Sc,
                              Sch_Is_Dead)
             VALUES (0,
                     p_Sch_Scd,
                     p_Sch_Dt,
                     p_Sch_Note,
                     p_Sch_Src,
                     p_Sch_Sc,
                     p_Sch_Is_Dead)
          RETURNING Sch_Id
               INTO p_New_Id;
    END;

    PROCEDURE Save_Sc_Benefit_Docs (
        p_scbd_scbc   IN     Sc_Benefit_Docs.scbd_scbc%TYPE,
        p_scbd_scd    IN     Sc_Benefit_Docs.scbd_scd%TYPE,
        p_scbd_st     IN     Sc_Benefit_Docs.scbd_st%TYPE,
        p_New_Id         OUT Sc_Benefit_Docs.SCBD_ID%TYPE)
    IS
    BEGIN
        INSERT INTO Sc_Benefit_Docs (scbd_scbc,
                                     scbd_scd,
                                     scbd_scpo,
                                     scbd_st)
             VALUES (p_scbd_scbc,
                     p_scbd_scd,
                     NULL,
                     p_scbd_st)
          RETURNING SCBD_ID
               INTO p_New_Id;
    END;
BEGIN
    -- Initialization
    NULL;
END Api$socialcard;
/