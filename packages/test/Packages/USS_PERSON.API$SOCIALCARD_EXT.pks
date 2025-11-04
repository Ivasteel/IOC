/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SOCIALCARD_EXT
IS
    -- Author  : SHOSTAK
    -- Created : 24.12.2024 14:34:49
    -- Purpose : Прцедури для роботи з проміжними структурами, що заповнюються в процесі обмінів з зовнішніми системами

    ------------------------------------------------------------------------
    --                           БАЗОВІ РЕКВІЗИТИ
    ------------------------------------------------------------------------
    /*
    info:    Збереження інформація про особу
    author:  sho
    */
    PROCEDURE Save_Data_Ident (
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

    /*
    info:    Збереження адреси
    author:  sho
    */
    PROCEDURE Save_Address (
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
        p_Scpa_Create_Dt   IN     Sc_Pfu_Address.Scpa_Create_Dt%TYPE DEFAULT NULL,
        p_Scpa_St          IN     Sc_Pfu_Address.Scpa_St%TYPE DEFAULT 'VR');

    /*
    info:    Збереження документа
    author:  sho
    */
    PROCEDURE Save_Document (
        p_Scpo_Id        OUT Sc_Pfu_Document.Scpo_Id%TYPE,
        p_Scpo_Sc            Sc_Pfu_Document.Scpo_Sc%TYPE DEFAULT NULL,
        p_Scpo_Scdi          Sc_Pfu_Document.Scpo_Scdi%TYPE,
        p_Scpo_Ndt           Sc_Pfu_Document.Scpo_Ndt%TYPE DEFAULT NULL,
        p_Scpo_Pfu_Ndt       Sc_Pfu_Document.Scpo_Pfu_Ndt%TYPE DEFAULT NULL,
        p_Scpo_St            Sc_Pfu_Document.Scpo_St%TYPE DEFAULT 'VR',
        p_Scpo_Scd           Sc_Pfu_Document.Scpo_Scd%TYPE DEFAULT NULL);

    /*
    info:    Збереження атрибута документа
    author:  sho
    */
    PROCEDURE Save_Doc_Attr (
        p_Scpda_Scpo         Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda          Sc_Pfu_Document_Attr.Scpda_Nda%TYPE DEFAULT NULL,
        p_Scpda_Val_Int      Sc_Pfu_Document_Attr.Scpda_Val_Int%TYPE DEFAULT NULL,
        p_Scpda_Val_Dt       Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE DEFAULT NULL,
        p_Scpda_Val_String   Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE DEFAULT NULL,
        p_Scpda_St           Sc_Pfu_Document_Attr.Scpda_St%TYPE DEFAULT 'VR',
        p_Scpda_Pfu_Nda      Sc_Pfu_Document_Attr.Scpda_Pfu_Nda%TYPE DEFAULT NULL,
        p_Scpda_Val_Id       Sc_Pfu_Document_Attr.Scpda_Val_Id%TYPE DEFAULT NULL);

    /*
    info:    Отримання значення атрибута рядка
    author:  sho
    */
    FUNCTION Get_Attr_Val_Str (
        p_Scpda_Scpo   IN Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda    IN Sc_Pfu_Document_Attr.Scpda_Nda%TYPE)
        RETURN Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE;

    /*
    info:    Отримання значення атрибута рядка
    author:  sho
    */
    FUNCTION Get_Attr_Val_String (p_Scdi_Id     IN NUMBER,
                                  p_Ndt_Id      IN NUMBER,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    /*
    info:    Отримання значення атрибута рядка
    author:  kelatev
    */
    FUNCTION Get_Attr_Val_String (p_Scdi_Id     IN NUMBER,
                                  p_Nda_Class   IN VARCHAR2,
                                  p_Ndc_Id      IN NUMBER)
        RETURN VARCHAR2;

    /*
    info:    Отримання значення атрибута дати
    author:  sho
    */
    FUNCTION Get_Attr_Val_Dt (
        p_Scpda_Scpo   IN Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda    IN Sc_Pfu_Document_Attr.Scpda_Nda%TYPE)
        RETURN Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE;

    /*
    info:    Отримання значення атрибута дати
    author:  sho
    */
    FUNCTION Get_Attr_Val_Dt (p_Scdi_Id     IN NUMBER,
                              p_Ndt_Id      IN NUMBER,
                              p_Nda_Class   IN VARCHAR2)
        RETURN DATE;

    /*
    info:    Отримання значення атрибута дати
    author:  kelatev
    */
    FUNCTION Get_Attr_Val_Dt (p_Scdi_Id     IN NUMBER,
                              p_Nda_Class   IN VARCHAR2,
                              p_Ndc_Id      IN NUMBER)
        RETURN DATE;

    /*
    info:    Отримання коду запиту, яким було збережено дані
    author:  sho
    */
    FUNCTION Get_Scdi_Nrt_Code (p_Scdi_Id IN NUMBER)
        RETURN VARCHAR2;

    ------------------------------------------------------------------------
    --                           ЦБІ
    ------------------------------------------------------------------------
    /*
    info:    Запис в тимчасовий лог зміни статусів ДЗР від ЦБІ
    author:  sho
    */
    PROCEDURE Write_Cbi_Ware_Log (
        p_Sccwl_Rn       Sccw_Log.Sccwl_Rn%TYPE,
        p_Sccwl_Sccw     Sccw_Log.Sccwl_Sccw%TYPE,
        p_Sccwl_Cbi_Dt   Sccw_Log.Sccwl_Cbi_Dt%TYPE,
        p_Sccwl_St_Old   Sccw_Log.Sccwl_St_Old%TYPE,
        p_Sccwl_St       Sccw_Log.Sccwl_St%TYPE);

    /*
    info:    Збреження інформації про ДЗР в заяві від ЦБІ
    author:  sho
    */
    PROCEDURE Save_Cbi_Wares (
        p_Sccw_Id              IN OUT Sc_Cbi_Wares.Sccw_Id%TYPE,
        p_Sccw_Scdi                   Sc_Cbi_Wares.Sccw_Scdi%TYPE DEFAULT NULL,
        p_Sccw_Iso                    Sc_Cbi_Wares.Sccw_Iso%TYPE DEFAULT NULL,
        p_Sccw_Name                   Sc_Cbi_Wares.Sccw_Name%TYPE DEFAULT NULL,
        p_Sccw_Ext_Id                 Sc_Cbi_Wares.Sccw_Ext_Id%TYPE DEFAULT NULL,
        p_Sccw_St                     Sc_Cbi_Wares.Sccw_St%TYPE DEFAULT NULL,
        p_Sccw_Wrn                    Sc_Cbi_Wares.Sccw_Wrn%TYPE DEFAULT NULL,
        p_Sccw_Ref_Num                Sc_Cbi_Wares.Sccw_Ref_Num%TYPE DEFAULT NULL,
        p_Sccw_Ref_Dt                 Sc_Cbi_Wares.Sccw_Ref_Dt%TYPE DEFAULT NULL,
        p_Sccw_Ref_Exp_Dt             Sc_Cbi_Wares.Sccw_Ref_Exp_Dt%TYPE DEFAULT NULL,
        p_Sccw_Issue_Dt               Sc_Cbi_Wares.Sccw_Issue_Dt%TYPE DEFAULT NULL,
        p_Sccw_End_Exp_Dt             Sc_Cbi_Wares.Sccw_End_Exp_Dt%TYPE DEFAULT NULL,
        p_Sccw_Reject_Reason          Sc_Cbi_Wares.Sccw_Reject_Reason%TYPE DEFAULT NULL,
        p_Sccw_Cbi_St                 Sc_Cbi_Wares.Sccw_Cbi_St%TYPE DEFAULT NULL);

    ------------------------------------------------------------------------
    --                           МОЗ
    ------------------------------------------------------------------------

    /*
    info:    Збреження інформації про оцінювання в ЗОЗ від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Assessment (
        p_Scma_Id                        OUT Sc_Moz_Assessment.Scma_Id%TYPE,
        p_Scma_Scdi                          Sc_Moz_Assessment.Scma_Scdi%TYPE DEFAULT NULL,
        p_Scma_Sc                            Sc_Moz_Assessment.Scma_Sc%TYPE DEFAULT NULL,
        p_Scma_Eval_Dt                       Sc_Moz_Assessment.Scma_Eval_Dt%TYPE DEFAULT NULL,
        p_Scma_Decision_Num                  Sc_Moz_Assessment.Scma_Decision_Num%TYPE DEFAULT NULL,
        p_Scma_Decision_Dt                   Sc_Moz_Assessment.Scma_Decision_Dt%TYPE DEFAULT NULL,
        p_Scma_Is_Group                      Sc_Moz_Assessment.Scma_Is_Group%TYPE DEFAULT NULL,
        p_Scma_Start_Dt                      Sc_Moz_Assessment.Scma_Start_Dt%TYPE DEFAULT NULL,
        p_Scma_Group                         Sc_Moz_Assessment.Scma_Group%TYPE DEFAULT NULL,
        p_Scma_Main_Diagnosis                Sc_Moz_Assessment.Scma_Main_Diagnosis%TYPE DEFAULT NULL,
        p_Scma_Add_Diagnoses                 Sc_Moz_Assessment.Scma_Add_Diagnoses%TYPE DEFAULT NULL,
        p_Scma_Is_Endless                    Sc_Moz_Assessment.Scma_Is_Endless%TYPE DEFAULT NULL,
        p_Scma_End_Dt                        Sc_Moz_Assessment.Scma_End_Dt%TYPE DEFAULT NULL,
        p_Scma_Reasons                       Sc_Moz_Assessment.Scma_Reasons%TYPE DEFAULT NULL,
        p_Scma_Is_Prev                       Sc_Moz_Assessment.Scma_Is_Prev%TYPE DEFAULT NULL,
        p_Scma_Is_Loss_Prof_Ability          Sc_Moz_Assessment.Scma_Is_Loss_Prof_Ability%TYPE DEFAULT NULL,
        p_Scma_Disease_Dt                    Sc_Moz_Assessment.Scma_Disease_Dt%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Dt          Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Dt%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Perc        Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Perc%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Cause       Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Cause%TYPE DEFAULT NULL,
        p_Scma_Reexam_Dt                     Sc_Moz_Assessment.Scma_Reexam_Dt%TYPE DEFAULT NULL,
        p_Scma_Is_Ext_Temp_Dis               Sc_Moz_Assessment.Scma_Is_Ext_Temp_Dis%TYPE DEFAULT NULL,
        p_Scma_Ext_Temp_Dis_Dt               Sc_Moz_Assessment.Scma_Ext_Temp_Dis_Dt%TYPE DEFAULT NULL,
        p_Scma_Ext_Temp_Dis_Note             Sc_Moz_Assessment.Scma_Ext_Temp_Dis_Note%TYPE DEFAULT NULL,
        p_Scma_Is_Car_Needed                 Sc_Moz_Assessment.Scma_Is_Car_Needed%TYPE DEFAULT NULL,
        p_Scma_Is_Car_Provision              Sc_Moz_Assessment.Scma_Is_Car_Provision%TYPE DEFAULT NULL,
        p_Scma_Is_Med_Ind                    Sc_Moz_Assessment.Scma_Is_Med_Ind%TYPE DEFAULT NULL,
        p_Scma_Is_Med_Contr_Ind              Sc_Moz_Assessment.Scma_Is_Med_Contr_Ind%TYPE DEFAULT NULL,
        p_Scma_Is_Death_Dis_Conn             Sc_Moz_Assessment.Scma_Is_Death_Dis_Conn%TYPE DEFAULT NULL,
        p_Scma_Is_San_Trtmnt                 Sc_Moz_Assessment.Scma_Is_San_Trtmnt%TYPE DEFAULT NULL,
        p_Scma_Is_Pfu_Rec                    Sc_Moz_Assessment.Scma_Is_Pfu_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Oszn_Rec                   Sc_Moz_Assessment.Scma_Is_Oszn_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Soc_Rehab                  Sc_Moz_Assessment.Scma_Is_Soc_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Psycholog_Rec              Sc_Moz_Assessment.Scma_Is_Psycholog_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Psycholog_Rehab            Sc_Moz_Assessment.Scma_Is_Psycholog_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Workplace_Arrgmnt          Sc_Moz_Assessment.Scma_Is_Workplace_Arrgmnt%TYPE DEFAULT NULL,
        p_Scma_Is_Job_Center_Rec             Sc_Moz_Assessment.Scma_Is_Job_Center_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Prof_Limits                Sc_Moz_Assessment.Scma_Is_Prof_Limits%TYPE DEFAULT NULL,
        p_Scma_Is_Prof_Rehab                 Sc_Moz_Assessment.Scma_Is_Prof_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Skills              Sc_Moz_Assessment.Scma_Is_Sports_Skills%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Trainings           Sc_Moz_Assessment.Scma_Is_Sports_Trainings%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Needed              Sc_Moz_Assessment.Scma_Is_Sports_Needed%TYPE DEFAULT NULL,
        p_Scma_Add_Needs                     Sc_Moz_Assessment.Scma_Add_Needs%TYPE DEFAULT NULL,
        p_Scma_St                            Sc_Moz_Assessment.Scma_St%TYPE DEFAULT NULL,
        p_Scma_Is_Permanent_Care             Sc_Moz_Assessment.Scma_Is_Permanent_Care%TYPE DEFAULT NULL,
        p_Scma_Is_Vlk_Decisions              Sc_Moz_Assessment.Scma_Is_Vlk_Decisions%TYPE DEFAULT NULL,
        p_Scma_Vlk_Decisions                 Sc_Moz_Assessment.Scma_Vlk_Decisions%TYPE DEFAULT NULL);

    /*
    info:    Збреження відомостей про ЗОЗ від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Zoz (
        p_Scmz_Id               OUT Sc_Moz_Zoz.Scmz_Id%TYPE,
        p_Scmz_Scdi                 Sc_Moz_Zoz.Scmz_Scdi%TYPE DEFAULT NULL,
        p_Scmz_Sc                   Sc_Moz_Zoz.Scmz_Sc%TYPE DEFAULT NULL,
        p_Scmz_Org_Name             Sc_Moz_Zoz.Scmz_Org_Name%TYPE DEFAULT NULL,
        p_Scmz_Org_Id               Sc_Moz_Zoz.Scmz_Org_Id%TYPE DEFAULT NULL,
        p_Scmz_Region_Id            Sc_Moz_Zoz.Scmz_Region_Id%TYPE DEFAULT NULL,
        p_Scmz_Region_Name          Sc_Moz_Zoz.Scmz_Region_Name%TYPE DEFAULT NULL,
        p_Scmz_District_Id          Sc_Moz_Zoz.Scmz_District_Id%TYPE DEFAULT NULL,
        p_Scmz_District_Name        Sc_Moz_Zoz.Scmz_District_Name%TYPE DEFAULT NULL,
        p_Scmz_Community_Id         Sc_Moz_Zoz.Scmz_Community_Id%TYPE DEFAULT NULL,
        p_Scmz_Community_Name       Sc_Moz_Zoz.Scmz_Community_Name%TYPE DEFAULT NULL,
        p_Scmz_City_Id              Sc_Moz_Zoz.Scmz_City_Id%TYPE DEFAULT NULL,
        p_Scmz_City_Name            Sc_Moz_Zoz.Scmz_City_Name%TYPE DEFAULT NULL,
        p_Scmz_Street_Name          Sc_Moz_Zoz.Scmz_Street_Name%TYPE DEFAULT NULL,
        p_Scmz_Building             Sc_Moz_Zoz.Scmz_Building%TYPE DEFAULT NULL,
        p_Scmz_Room                 Sc_Moz_Zoz.Scmz_Room%TYPE DEFAULT NULL,
        p_Scmz_Post_Code            Sc_Moz_Zoz.Scmz_Post_Code%TYPE DEFAULT NULL,
        p_Scmz_St                   Sc_Moz_Zoz.Scmz_St%TYPE DEFAULT NULL);

    /*
    info:    Збреження відомостей рекомендацій щодо ДЗР від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Dzr_Recomm (
        p_Scmd_Id              OUT Sc_Moz_Dzr_Recomm.Scmd_Id%TYPE,
        p_Scmd_Scdi                Sc_Moz_Dzr_Recomm.Scmd_Scdi%TYPE DEFAULT NULL,
        p_Scmd_Sc                  Sc_Moz_Dzr_Recomm.Scmd_Sc%TYPE DEFAULT NULL,
        p_Scmd_Is_Dzr_Needed       Sc_Moz_Dzr_Recomm.Scmd_Is_Dzr_Needed%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Code            Sc_Moz_Dzr_Recomm.Scmd_Dzr_Code%TYPE DEFAULT NULL,
        p_Scmd_Iso_Code            Sc_Moz_Dzr_Recomm.Scmd_Iso_Code%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Name            Sc_Moz_Dzr_Recomm.Scmd_Dzr_Name%TYPE DEFAULT NULL,
        p_Scmd_Iso_Code1           Sc_Moz_Dzr_Recomm.Scmd_Iso_Code1%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Name1           Sc_Moz_Dzr_Recomm.Scmd_Dzr_Name1%TYPE DEFAULT NULL,
        p_Scmd_Wrn                 Sc_Moz_Dzr_Recomm.Scmd_Wrn%TYPE DEFAULT NULL,
        p_Scmd_St                  Sc_Moz_Dzr_Recomm.Scmd_St%TYPE DEFAULT NULL);

    /*
    info:    Збреження відомостей рекомендацій щодо забезпечення особи медичними виробами від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Med_Data_Recomm (
        p_Scmm_Id              OUT Sc_Moz_Med_Data_Recomm.Scmm_Id%TYPE,
        p_Scmm_Scdi                Sc_Moz_Med_Data_Recomm.Scmm_Scdi%TYPE DEFAULT NULL,
        p_Scmm_Sc                  Sc_Moz_Med_Data_Recomm.Scmm_Sc%TYPE DEFAULT NULL,
        p_Scmm_Is_Med_Needed       Sc_Moz_Med_Data_Recomm.Scmm_Is_Med_Needed%TYPE DEFAULT NULL,
        p_Scmm_Med_Name            Sc_Moz_Med_Data_Recomm.Scmm_Med_Name%TYPE DEFAULT NULL,
        p_Scmm_Med_Needed_Dt       Sc_Moz_Med_Data_Recomm.Scmm_Med_Needed_Dt%TYPE DEFAULT NULL,
        p_Scmm_Med_Qty             Sc_Moz_Med_Data_Recomm.Scmm_Med_Qty%TYPE DEFAULT NULL,
        p_Scmm_St                  Sc_Moz_Med_Data_Recomm.Scmm_St%TYPE DEFAULT NULL);

    /*
    info:    Збреження даних про втрату професіної працездатності від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Loss_Prof_Ability (
        p_Scml_Id                        OUT Sc_Moz_Loss_Prof_Ability.Scml_Id%TYPE,
        p_Scml_Scdi                          Sc_Moz_Loss_Prof_Ability.Scml_Scdi%TYPE DEFAULT NULL,
        p_Scml_Sc                            Sc_Moz_Loss_Prof_Ability.Scml_Sc%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Dt          Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Dt%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Perc        Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Perc%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Cause       Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Cause%TYPE DEFAULT NULL,
        p_Scml_St                            Sc_Moz_Loss_Prof_Ability.Scml_St%TYPE DEFAULT NULL);
END Api$socialcard_Ext;
/


GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD_EXT TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD_EXT TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD_EXT TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SOCIALCARD_EXT TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SOCIALCARD_EXT
IS
    ------------------------------------------------------------------------
    --                           БАЗОВІ РЕКВІЗИТИ
    ------------------------------------------------------------------------
    /*
    info:    Збереження інформація про особу
    author:  sho
    */
    PROCEDURE Save_Data_Ident (
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
                     p_Ext_Ident)
          RETURNING Scdi_Id
               INTO p_Scdi_Id;
    END;

    /*
    info:    Збереження адреси
    author:  sho
    */
    PROCEDURE Save_Address (
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
        p_Scpa_Create_Dt   IN     Sc_Pfu_Address.Scpa_Create_Dt%TYPE DEFAULT NULL,
        p_Scpa_St          IN     Sc_Pfu_Address.Scpa_St%TYPE DEFAULT 'VR')
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
                     NVL (p_Scpa_Create_Dt, SYSDATE),
                     p_Scpa_St)
          RETURNING Scpa_Id
               INTO p_Scpa_Id;
    END;

    /*
    info:    Збереження документа
    author:  sho
    */
    PROCEDURE Save_Document (
        p_Scpo_Id        OUT Sc_Pfu_Document.Scpo_Id%TYPE,
        p_Scpo_Sc            Sc_Pfu_Document.Scpo_Sc%TYPE DEFAULT NULL,
        p_Scpo_Scdi          Sc_Pfu_Document.Scpo_Scdi%TYPE,
        p_Scpo_Ndt           Sc_Pfu_Document.Scpo_Ndt%TYPE DEFAULT NULL,
        p_Scpo_Pfu_Ndt       Sc_Pfu_Document.Scpo_Pfu_Ndt%TYPE DEFAULT NULL,
        p_Scpo_St            Sc_Pfu_Document.Scpo_St%TYPE DEFAULT 'VR',
        p_Scpo_Scd           Sc_Pfu_Document.Scpo_Scd%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Pfu_Document (Scpo_Id,
                                     Scpo_Sc,
                                     Scpo_Scdi,
                                     Scpo_Ndt,
                                     Scpo_Pfu_Ndt,
                                     Scpo_St,
                                     Scpo_Scd)
             VALUES (0,
                     p_Scpo_Sc,
                     p_Scpo_Scdi,
                     p_Scpo_Ndt,
                     p_Scpo_Pfu_Ndt,
                     p_Scpo_St,
                     p_Scpo_Scd)
          RETURNING Scpo_Id
               INTO p_Scpo_Id;
    END;

    /*
    info:    Збереження атрибута документа
    author:  sho
    */
    PROCEDURE Save_Doc_Attr (
        p_Scpda_Scpo         Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda          Sc_Pfu_Document_Attr.Scpda_Nda%TYPE DEFAULT NULL,
        p_Scpda_Val_Int      Sc_Pfu_Document_Attr.Scpda_Val_Int%TYPE DEFAULT NULL,
        p_Scpda_Val_Dt       Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE DEFAULT NULL,
        p_Scpda_Val_String   Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE DEFAULT NULL,
        p_Scpda_St           Sc_Pfu_Document_Attr.Scpda_St%TYPE DEFAULT 'VR',
        p_Scpda_Pfu_Nda      Sc_Pfu_Document_Attr.Scpda_Pfu_Nda%TYPE DEFAULT NULL,
        p_Scpda_Val_Id       Sc_Pfu_Document_Attr.Scpda_Val_Id%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Pfu_Document_Attr (Scpda_Id,
                                          Scpda_Scpo,
                                          Scpda_Nda,
                                          Scpda_Val_Int,
                                          Scpda_Val_Dt,
                                          Scpda_Val_String,
                                          Scpda_St,
                                          Scpda_Pfu_Nda,
                                          Scpda_Val_Id)
             VALUES (0,
                     p_Scpda_Scpo,
                     p_Scpda_Nda,
                     p_Scpda_Val_Int,
                     p_Scpda_Val_Dt,
                     p_Scpda_Val_String,
                     p_Scpda_St,
                     p_Scpda_Pfu_Nda,
                     p_Scpda_Val_Id);
    END;

    /*
    info:    Отримання значення атрибута рядка
    author:  sho
    */
    FUNCTION Get_Attr_Val_Str (
        p_Scpda_Scpo   IN Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda    IN Sc_Pfu_Document_Attr.Scpda_Nda%TYPE)
        RETURN Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE
    IS
        l_Result   Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Scpda_Val_String)
          INTO l_Result
          FROM Uss_Person.v_Sc_Pfu_Document_Attr a
         WHERE a.Scpda_Scpo = p_Scpda_Scpo AND a.Scpda_Nda = p_Scpda_Nda;

        RETURN l_Result;
    END;

    /*
    info:    Отримання значення атрибута рядка
    author:  sho
    */
    FUNCTION Get_Attr_Val_String (p_Scdi_Id     IN NUMBER,
                                  p_Ndt_Id      IN NUMBER,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Scpda_Val_String)
          INTO l_Result
          FROM Sc_Pfu_Document  d
               JOIN Sc_Pfu_Document_Attr a ON a.Scpda_Scpo = d.Scpo_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Scpda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE d.Scpo_Scdi = p_Scdi_Id AND d.Scpo_Ndt = p_Ndt_Id;

        RETURN l_Result;
    END;

    /*
    info:    Отримання значення атрибута рядка
    author:  kelatev
    */
    FUNCTION Get_Attr_Val_String (p_Scdi_Id     IN NUMBER,
                                  p_Nda_Class   IN VARCHAR2,
                                  p_Ndc_Id      IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Scpda_Val_String)
          INTO l_Result
          FROM Sc_Pfu_Document  d
               JOIN Sc_Pfu_Document_Attr a ON a.Scpda_Scpo = d.Scpo_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Scpda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
               JOIN Uss_Ndi.v_Ndi_Document_Type t
                   ON d.Scpo_Ndt = t.Ndt_Id AND t.Ndt_Ndc = p_Ndc_Id
         WHERE d.Scpo_Scdi = p_Scdi_Id;

        RETURN l_Result;
    END;

    /*
    info:    Отримання значення атрибута дати
    author:  sho
    */
    FUNCTION Get_Attr_Val_Dt (
        p_Scpda_Scpo   IN Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
        p_Scpda_Nda    IN Sc_Pfu_Document_Attr.Scpda_Nda%TYPE)
        RETURN Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE
    IS
        l_Result   Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (a.Scpda_Val_Dt)
          INTO l_Result
          FROM Uss_Person.v_Sc_Pfu_Document_Attr a
         WHERE a.Scpda_Scpo = p_Scpda_Scpo AND a.Scpda_Nda = p_Scpda_Nda;

        RETURN l_Result;
    END;

    /*
    info:    Отримання значення атрибута дати
    author:  sho
    */
    FUNCTION Get_Attr_Val_Dt (p_Scdi_Id     IN NUMBER,
                              p_Ndt_Id      IN NUMBER,
                              p_Nda_Class   IN VARCHAR2)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.Scpda_Val_Dt)
          INTO l_Result
          FROM Sc_Pfu_Document  d
               JOIN Sc_Pfu_Document_Attr a ON a.Scpda_Scpo = d.Scpo_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Scpda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE d.Scpo_Scdi = p_Scdi_Id AND d.Scpo_Ndt = p_Ndt_Id;

        RETURN l_Result;
    END;

    /*
    info:    Отримання значення атрибута дати
    author:  kelatev
    */
    FUNCTION Get_Attr_Val_Dt (p_Scdi_Id     IN NUMBER,
                              p_Nda_Class   IN VARCHAR2,
                              p_Ndc_Id      IN NUMBER)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.Scpda_Val_Dt)
          INTO l_Result
          FROM Sc_Pfu_Document  d
               JOIN Sc_Pfu_Document_Attr a ON a.Scpda_Scpo = d.Scpo_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Scpda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
               JOIN Uss_Ndi.v_Ndi_Document_Type t
                   ON d.Scpo_Ndt = t.Ndt_Id AND t.Ndt_Ndc = p_Ndc_Id
         WHERE d.Scpo_Scdi = p_Scdi_Id;

        RETURN l_Result;
    END;

    /*
    info:    Отримання коду запиту, яким було збережено дані
    author:  sho
    */
    FUNCTION Get_Scdi_Nrt_Code (p_Scdi_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        SELECT NVL (MAX (t.Nrt_Code), '-')
          INTO l_Result
          FROM Sc_Pfu_Data_Ident  i
               JOIN Uss_Ndi.v_Ndi_Request_Type t ON i.Scdi_Nrt = t.Nrt_Id
         WHERE i.Scdi_Id = p_Scdi_Id;

        RETURN l_Result;
    END;

    ------------------------------------------------------------------------
    --                           ЦБІ
    ------------------------------------------------------------------------
    /*
    info:    Запис в тимчасовий лог зміни статусів ДЗР від ЦБІ
    author:  sho
    */
    PROCEDURE Write_Cbi_Ware_Log (
        p_Sccwl_Rn       Sccw_Log.Sccwl_Rn%TYPE,
        p_Sccwl_Sccw     Sccw_Log.Sccwl_Sccw%TYPE,
        p_Sccwl_Cbi_Dt   Sccw_Log.Sccwl_Cbi_Dt%TYPE,
        p_Sccwl_St_Old   Sccw_Log.Sccwl_St_Old%TYPE,
        p_Sccwl_St       Sccw_Log.Sccwl_St%TYPE)
    IS
    BEGIN
        INSERT INTO Sccw_Log (Sccwl_Id,
                              Sccwl_Rn,
                              Sccwl_Sccw,
                              Sccwl_Cbi_Dt,
                              Sccwl_St_Old,
                              Sccwl_St)
             VALUES (0,
                     p_Sccwl_Rn,
                     p_Sccwl_Sccw,
                     p_Sccwl_Cbi_Dt,
                     p_Sccwl_St_Old,
                     p_Sccwl_St);
    END;

    /*
    info:    Збреження інформації про ДЗР в заяві від ЦБІ
    author:  sho
    */
    PROCEDURE Save_Cbi_Wares (
        p_Sccw_Id              IN OUT Sc_Cbi_Wares.Sccw_Id%TYPE,
        p_Sccw_Scdi                   Sc_Cbi_Wares.Sccw_Scdi%TYPE DEFAULT NULL,
        p_Sccw_Iso                    Sc_Cbi_Wares.Sccw_Iso%TYPE DEFAULT NULL,
        p_Sccw_Name                   Sc_Cbi_Wares.Sccw_Name%TYPE DEFAULT NULL,
        p_Sccw_Ext_Id                 Sc_Cbi_Wares.Sccw_Ext_Id%TYPE DEFAULT NULL,
        p_Sccw_St                     Sc_Cbi_Wares.Sccw_St%TYPE DEFAULT NULL,
        p_Sccw_Wrn                    Sc_Cbi_Wares.Sccw_Wrn%TYPE DEFAULT NULL,
        p_Sccw_Ref_Num                Sc_Cbi_Wares.Sccw_Ref_Num%TYPE DEFAULT NULL,
        p_Sccw_Ref_Dt                 Sc_Cbi_Wares.Sccw_Ref_Dt%TYPE DEFAULT NULL,
        p_Sccw_Ref_Exp_Dt             Sc_Cbi_Wares.Sccw_Ref_Exp_Dt%TYPE DEFAULT NULL,
        p_Sccw_Issue_Dt               Sc_Cbi_Wares.Sccw_Issue_Dt%TYPE DEFAULT NULL,
        p_Sccw_End_Exp_Dt             Sc_Cbi_Wares.Sccw_End_Exp_Dt%TYPE DEFAULT NULL,
        p_Sccw_Reject_Reason          Sc_Cbi_Wares.Sccw_Reject_Reason%TYPE DEFAULT NULL,
        p_Sccw_Cbi_St                 Sc_Cbi_Wares.Sccw_Cbi_St%TYPE DEFAULT NULL)
    IS
    BEGIN
        IF NVL (p_Sccw_Id, 0) = 0
        THEN
            INSERT INTO Sc_Cbi_Wares (Sccw_Id,
                                      Sccw_Scdi,
                                      Sccw_Iso,
                                      Sccw_Name,
                                      Sccw_Ext_Id,
                                      Sccw_St,
                                      Sccw_Wrn,
                                      Sccw_Ref_Num,
                                      Sccw_Ref_Dt,
                                      Sccw_Ref_Exp_Dt,
                                      Sccw_Issue_Dt,
                                      Sccw_End_Exp_Dt,
                                      Sccw_Reject_Reason,
                                      Sccw_Cbi_St)
                 VALUES (0,
                         p_Sccw_Scdi,
                         p_Sccw_Iso,
                         p_Sccw_Name,
                         p_Sccw_Ext_Id,
                         NVL (p_Sccw_St, 'VR'),
                         p_Sccw_Wrn,
                         p_Sccw_Ref_Num,
                         p_Sccw_Ref_Dt,
                         p_Sccw_Ref_Exp_Dt,
                         p_Sccw_Issue_Dt,
                         p_Sccw_End_Exp_Dt,
                         p_Sccw_Reject_Reason,
                         p_Sccw_Cbi_St)
              RETURNING Sccw_Id
                   INTO p_Sccw_Id;
        ELSE
            UPDATE Sc_Cbi_Wares w
               SET Sccw_St = COALESCE (p_Sccw_St, Sccw_St),
                   Sccw_Wrn = COALESCE (p_Sccw_Wrn, Sccw_Wrn),
                   Sccw_Ref_Num = COALESCE (p_Sccw_Ref_Num, Sccw_Ref_Num),
                   Sccw_Ref_Dt = COALESCE (p_Sccw_Ref_Dt, Sccw_Ref_Dt),
                   Sccw_Ref_Exp_Dt =
                       COALESCE (p_Sccw_Ref_Exp_Dt, Sccw_Ref_Exp_Dt),
                   Sccw_Issue_Dt = COALESCE (p_Sccw_Issue_Dt, Sccw_Issue_Dt),
                   Sccw_End_Exp_Dt =
                       COALESCE (p_Sccw_End_Exp_Dt, Sccw_End_Exp_Dt),
                   Sccw_Reject_Reason =
                       COALESCE (p_Sccw_Reject_Reason, Sccw_Reject_Reason),
                   Sccw_Cbi_St = COALESCE (p_Sccw_Cbi_St, Sccw_Cbi_St)
             WHERE w.Sccw_Id = p_Sccw_Id;
        END IF;
    END;

    ------------------------------------------------------------------------
    --                           МОЗ
    ------------------------------------------------------------------------

    /*
    info:    Збреження інформації про оцінювання в ЗОЗ від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Assessment (
        p_Scma_Id                        OUT Sc_Moz_Assessment.Scma_Id%TYPE,
        p_Scma_Scdi                          Sc_Moz_Assessment.Scma_Scdi%TYPE DEFAULT NULL,
        p_Scma_Sc                            Sc_Moz_Assessment.Scma_Sc%TYPE DEFAULT NULL,
        p_Scma_Eval_Dt                       Sc_Moz_Assessment.Scma_Eval_Dt%TYPE DEFAULT NULL,
        p_Scma_Decision_Num                  Sc_Moz_Assessment.Scma_Decision_Num%TYPE DEFAULT NULL,
        p_Scma_Decision_Dt                   Sc_Moz_Assessment.Scma_Decision_Dt%TYPE DEFAULT NULL,
        p_Scma_Is_Group                      Sc_Moz_Assessment.Scma_Is_Group%TYPE DEFAULT NULL,
        p_Scma_Start_Dt                      Sc_Moz_Assessment.Scma_Start_Dt%TYPE DEFAULT NULL,
        p_Scma_Group                         Sc_Moz_Assessment.Scma_Group%TYPE DEFAULT NULL,
        p_Scma_Main_Diagnosis                Sc_Moz_Assessment.Scma_Main_Diagnosis%TYPE DEFAULT NULL,
        p_Scma_Add_Diagnoses                 Sc_Moz_Assessment.Scma_Add_Diagnoses%TYPE DEFAULT NULL,
        p_Scma_Is_Endless                    Sc_Moz_Assessment.Scma_Is_Endless%TYPE DEFAULT NULL,
        p_Scma_End_Dt                        Sc_Moz_Assessment.Scma_End_Dt%TYPE DEFAULT NULL,
        p_Scma_Reasons                       Sc_Moz_Assessment.Scma_Reasons%TYPE DEFAULT NULL,
        p_Scma_Is_Prev                       Sc_Moz_Assessment.Scma_Is_Prev%TYPE DEFAULT NULL,
        p_Scma_Is_Loss_Prof_Ability          Sc_Moz_Assessment.Scma_Is_Loss_Prof_Ability%TYPE DEFAULT NULL,
        p_Scma_Disease_Dt                    Sc_Moz_Assessment.Scma_Disease_Dt%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Dt          Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Dt%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Perc        Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Perc%TYPE DEFAULT NULL,
        p_Scma_Loss_Prof_Ability_Cause       Sc_Moz_Assessment.Scma_Loss_Prof_Ability_Cause%TYPE DEFAULT NULL,
        p_Scma_Reexam_Dt                     Sc_Moz_Assessment.Scma_Reexam_Dt%TYPE DEFAULT NULL,
        p_Scma_Is_Ext_Temp_Dis               Sc_Moz_Assessment.Scma_Is_Ext_Temp_Dis%TYPE DEFAULT NULL,
        p_Scma_Ext_Temp_Dis_Dt               Sc_Moz_Assessment.Scma_Ext_Temp_Dis_Dt%TYPE DEFAULT NULL,
        p_Scma_Ext_Temp_Dis_Note             Sc_Moz_Assessment.Scma_Ext_Temp_Dis_Note%TYPE DEFAULT NULL,
        p_Scma_Is_Car_Needed                 Sc_Moz_Assessment.Scma_Is_Car_Needed%TYPE DEFAULT NULL,
        p_Scma_Is_Car_Provision              Sc_Moz_Assessment.Scma_Is_Car_Provision%TYPE DEFAULT NULL,
        p_Scma_Is_Med_Ind                    Sc_Moz_Assessment.Scma_Is_Med_Ind%TYPE DEFAULT NULL,
        p_Scma_Is_Med_Contr_Ind              Sc_Moz_Assessment.Scma_Is_Med_Contr_Ind%TYPE DEFAULT NULL,
        p_Scma_Is_Death_Dis_Conn             Sc_Moz_Assessment.Scma_Is_Death_Dis_Conn%TYPE DEFAULT NULL,
        p_Scma_Is_San_Trtmnt                 Sc_Moz_Assessment.Scma_Is_San_Trtmnt%TYPE DEFAULT NULL,
        p_Scma_Is_Pfu_Rec                    Sc_Moz_Assessment.Scma_Is_Pfu_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Oszn_Rec                   Sc_Moz_Assessment.Scma_Is_Oszn_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Soc_Rehab                  Sc_Moz_Assessment.Scma_Is_Soc_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Psycholog_Rec              Sc_Moz_Assessment.Scma_Is_Psycholog_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Psycholog_Rehab            Sc_Moz_Assessment.Scma_Is_Psycholog_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Workplace_Arrgmnt          Sc_Moz_Assessment.Scma_Is_Workplace_Arrgmnt%TYPE DEFAULT NULL,
        p_Scma_Is_Job_Center_Rec             Sc_Moz_Assessment.Scma_Is_Job_Center_Rec%TYPE DEFAULT NULL,
        p_Scma_Is_Prof_Limits                Sc_Moz_Assessment.Scma_Is_Prof_Limits%TYPE DEFAULT NULL,
        p_Scma_Is_Prof_Rehab                 Sc_Moz_Assessment.Scma_Is_Prof_Rehab%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Skills              Sc_Moz_Assessment.Scma_Is_Sports_Skills%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Trainings           Sc_Moz_Assessment.Scma_Is_Sports_Trainings%TYPE DEFAULT NULL,
        p_Scma_Is_Sports_Needed              Sc_Moz_Assessment.Scma_Is_Sports_Needed%TYPE DEFAULT NULL,
        p_Scma_Add_Needs                     Sc_Moz_Assessment.Scma_Add_Needs%TYPE DEFAULT NULL,
        p_Scma_St                            Sc_Moz_Assessment.Scma_St%TYPE DEFAULT NULL,
        p_Scma_Is_Permanent_Care             Sc_Moz_Assessment.Scma_Is_Permanent_Care%TYPE DEFAULT NULL,
        p_Scma_Is_Vlk_Decisions              Sc_Moz_Assessment.Scma_Is_Vlk_Decisions%TYPE DEFAULT NULL,
        p_Scma_Vlk_Decisions                 Sc_Moz_Assessment.Scma_Vlk_Decisions%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Moz_Assessment (Scma_Id,
                                       Scma_Scdi,
                                       Scma_Sc,
                                       Scma_Eval_Dt,
                                       Scma_Decision_Num,
                                       Scma_Decision_Dt,
                                       Scma_Is_Group,
                                       Scma_Start_Dt,
                                       Scma_Group,
                                       Scma_Main_Diagnosis,
                                       Scma_Add_Diagnoses,
                                       Scma_Is_Endless,
                                       Scma_End_Dt,
                                       Scma_Reasons,
                                       Scma_Is_Prev,
                                       Scma_Is_Loss_Prof_Ability,
                                       Scma_Disease_Dt,
                                       Scma_Loss_Prof_Ability_Dt,
                                       Scma_Loss_Prof_Ability_Perc,
                                       Scma_Loss_Prof_Ability_Cause,
                                       Scma_Reexam_Dt,
                                       Scma_Is_Ext_Temp_Dis,
                                       Scma_Ext_Temp_Dis_Dt,
                                       Scma_Ext_Temp_Dis_Note,
                                       Scma_Is_Car_Needed,
                                       Scma_Is_Car_Provision,
                                       Scma_Is_Med_Ind,
                                       Scma_Is_Med_Contr_Ind,
                                       Scma_Is_Death_Dis_Conn,
                                       Scma_Is_San_Trtmnt,
                                       Scma_Is_Pfu_Rec,
                                       Scma_Is_Oszn_Rec,
                                       Scma_Is_Soc_Rehab,
                                       Scma_Is_Psycholog_Rec,
                                       Scma_Is_Psycholog_Rehab,
                                       Scma_Is_Workplace_Arrgmnt,
                                       Scma_Is_Job_Center_Rec,
                                       Scma_Is_Prof_Limits,
                                       Scma_Is_Prof_Rehab,
                                       Scma_Is_Sports_Skills,
                                       Scma_Is_Sports_Trainings,
                                       Scma_Is_Sports_Needed,
                                       Scma_Add_Needs,
                                       Scma_St,
                                       Scma_Is_Permanent_Care,
                                       Scma_Is_Vlk_Decisions,
                                       Scma_Vlk_Decisions)
             VALUES (0,
                     p_Scma_Scdi,
                     p_Scma_Sc,
                     p_Scma_Eval_Dt,
                     p_Scma_Decision_Num,
                     p_Scma_Decision_Dt,
                     p_Scma_Is_Group,
                     p_Scma_Start_Dt,
                     p_Scma_Group,
                     p_Scma_Main_Diagnosis,
                     p_Scma_Add_Diagnoses,
                     p_Scma_Is_Endless,
                     p_Scma_End_Dt,
                     p_Scma_Reasons,
                     p_Scma_Is_Prev,
                     p_Scma_Is_Loss_Prof_Ability,
                     p_Scma_Disease_Dt,
                     p_Scma_Loss_Prof_Ability_Dt,
                     p_Scma_Loss_Prof_Ability_Perc,
                     p_Scma_Loss_Prof_Ability_Cause,
                     p_Scma_Reexam_Dt,
                     p_Scma_Is_Ext_Temp_Dis,
                     p_Scma_Ext_Temp_Dis_Dt,
                     p_Scma_Ext_Temp_Dis_Note,
                     p_Scma_Is_Car_Needed,
                     p_Scma_Is_Car_Provision,
                     p_Scma_Is_Med_Ind,
                     p_Scma_Is_Med_Contr_Ind,
                     p_Scma_Is_Death_Dis_Conn,
                     p_Scma_Is_San_Trtmnt,
                     p_Scma_Is_Pfu_Rec,
                     p_Scma_Is_Oszn_Rec,
                     p_Scma_Is_Soc_Rehab,
                     p_Scma_Is_Psycholog_Rec,
                     p_Scma_Is_Psycholog_Rehab,
                     p_Scma_Is_Workplace_Arrgmnt,
                     p_Scma_Is_Job_Center_Rec,
                     p_Scma_Is_Prof_Limits,
                     p_Scma_Is_Prof_Rehab,
                     p_Scma_Is_Sports_Skills,
                     p_Scma_Is_Sports_Trainings,
                     p_Scma_Is_Sports_Needed,
                     p_Scma_Add_Needs,
                     NVL (p_Scma_St, 'VR'),
                     p_Scma_Is_Permanent_Care,
                     p_Scma_Is_Vlk_Decisions,
                     p_Scma_Vlk_Decisions)
          RETURNING Scma_Id
               INTO p_Scma_Id;
    END;

    /*
    info:    Збреження відомостей про ЗОЗ від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Zoz (
        p_Scmz_Id               OUT Sc_Moz_Zoz.Scmz_Id%TYPE,
        p_Scmz_Scdi                 Sc_Moz_Zoz.Scmz_Scdi%TYPE DEFAULT NULL,
        p_Scmz_Sc                   Sc_Moz_Zoz.Scmz_Sc%TYPE DEFAULT NULL,
        p_Scmz_Org_Name             Sc_Moz_Zoz.Scmz_Org_Name%TYPE DEFAULT NULL,
        p_Scmz_Org_Id               Sc_Moz_Zoz.Scmz_Org_Id%TYPE DEFAULT NULL,
        p_Scmz_Region_Id            Sc_Moz_Zoz.Scmz_Region_Id%TYPE DEFAULT NULL,
        p_Scmz_Region_Name          Sc_Moz_Zoz.Scmz_Region_Name%TYPE DEFAULT NULL,
        p_Scmz_District_Id          Sc_Moz_Zoz.Scmz_District_Id%TYPE DEFAULT NULL,
        p_Scmz_District_Name        Sc_Moz_Zoz.Scmz_District_Name%TYPE DEFAULT NULL,
        p_Scmz_Community_Id         Sc_Moz_Zoz.Scmz_Community_Id%TYPE DEFAULT NULL,
        p_Scmz_Community_Name       Sc_Moz_Zoz.Scmz_Community_Name%TYPE DEFAULT NULL,
        p_Scmz_City_Id              Sc_Moz_Zoz.Scmz_City_Id%TYPE DEFAULT NULL,
        p_Scmz_City_Name            Sc_Moz_Zoz.Scmz_City_Name%TYPE DEFAULT NULL,
        p_Scmz_Street_Name          Sc_Moz_Zoz.Scmz_Street_Name%TYPE DEFAULT NULL,
        p_Scmz_Building             Sc_Moz_Zoz.Scmz_Building%TYPE DEFAULT NULL,
        p_Scmz_Room                 Sc_Moz_Zoz.Scmz_Room%TYPE DEFAULT NULL,
        p_Scmz_Post_Code            Sc_Moz_Zoz.Scmz_Post_Code%TYPE DEFAULT NULL,
        p_Scmz_St                   Sc_Moz_Zoz.Scmz_St%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Moz_Zoz (Scmz_Id,
                                Scmz_Scdi,
                                Scmz_Sc,
                                Scmz_Org_Name,
                                Scmz_Org_Id,
                                Scmz_Region_Id,
                                Scmz_Region_Name,
                                Scmz_District_Id,
                                Scmz_District_Name,
                                Scmz_Community_Id,
                                Scmz_Community_Name,
                                Scmz_City_Id,
                                Scmz_City_Name,
                                Scmz_Street_Name,
                                Scmz_Building,
                                Scmz_Room,
                                Scmz_Post_Code,
                                Scmz_St)
             VALUES (0,
                     p_Scmz_Scdi,
                     p_Scmz_Sc,
                     p_Scmz_Org_Name,
                     p_Scmz_Org_Id,
                     p_Scmz_Region_Id,
                     p_Scmz_Region_Name,
                     p_Scmz_District_Id,
                     p_Scmz_District_Name,
                     p_Scmz_Community_Id,
                     p_Scmz_Community_Name,
                     p_Scmz_City_Id,
                     p_Scmz_City_Name,
                     p_Scmz_Street_Name,
                     p_Scmz_Building,
                     p_Scmz_Room,
                     p_Scmz_Post_Code,
                     NVL (p_Scmz_St, 'VR'))
          RETURNING Scmz_Id
               INTO p_Scmz_Id;
    END;

    /*
    info:    Збреження відомостей рекомендацій щодо ДЗР від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Dzr_Recomm (
        p_Scmd_Id              OUT Sc_Moz_Dzr_Recomm.Scmd_Id%TYPE,
        p_Scmd_Scdi                Sc_Moz_Dzr_Recomm.Scmd_Scdi%TYPE DEFAULT NULL,
        p_Scmd_Sc                  Sc_Moz_Dzr_Recomm.Scmd_Sc%TYPE DEFAULT NULL,
        p_Scmd_Is_Dzr_Needed       Sc_Moz_Dzr_Recomm.Scmd_Is_Dzr_Needed%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Code            Sc_Moz_Dzr_Recomm.Scmd_Dzr_Code%TYPE DEFAULT NULL,
        p_Scmd_Iso_Code            Sc_Moz_Dzr_Recomm.Scmd_Iso_Code%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Name            Sc_Moz_Dzr_Recomm.Scmd_Dzr_Name%TYPE DEFAULT NULL,
        p_Scmd_Iso_Code1           Sc_Moz_Dzr_Recomm.Scmd_Iso_Code1%TYPE DEFAULT NULL,
        p_Scmd_Dzr_Name1           Sc_Moz_Dzr_Recomm.Scmd_Dzr_Name1%TYPE DEFAULT NULL,
        p_Scmd_Wrn                 Sc_Moz_Dzr_Recomm.Scmd_Wrn%TYPE DEFAULT NULL,
        p_Scmd_St                  Sc_Moz_Dzr_Recomm.Scmd_St%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Moz_Dzr_Recomm (Scmd_Id,
                                       Scmd_Scdi,
                                       Scmd_Sc,
                                       Scmd_Is_Dzr_Needed,
                                       Scmd_Dzr_Code,
                                       Scmd_Iso_Code,
                                       Scmd_Dzr_Name,
                                       Scmd_Iso_Code1,
                                       Scmd_Dzr_Name1,
                                       Scmd_Wrn,
                                       Scmd_St)
             VALUES (0,
                     p_Scmd_Scdi,
                     p_Scmd_Sc,
                     p_Scmd_Is_Dzr_Needed,
                     p_Scmd_Dzr_Code,
                     p_Scmd_Iso_Code,
                     p_Scmd_Dzr_Name,
                     p_Scmd_Iso_Code1,
                     p_Scmd_Dzr_Name1,
                     p_Scmd_Wrn,
                     'VR')
          RETURNING Scmd_Id
               INTO p_Scmd_Id;
    END;

    /*
    info:    Збреження відомостей рекомендацій щодо забезпечення особи медичними виробами від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Med_Data_Recomm (
        p_Scmm_Id              OUT Sc_Moz_Med_Data_Recomm.Scmm_Id%TYPE,
        p_Scmm_Scdi                Sc_Moz_Med_Data_Recomm.Scmm_Scdi%TYPE DEFAULT NULL,
        p_Scmm_Sc                  Sc_Moz_Med_Data_Recomm.Scmm_Sc%TYPE DEFAULT NULL,
        p_Scmm_Is_Med_Needed       Sc_Moz_Med_Data_Recomm.Scmm_Is_Med_Needed%TYPE DEFAULT NULL,
        p_Scmm_Med_Name            Sc_Moz_Med_Data_Recomm.Scmm_Med_Name%TYPE DEFAULT NULL,
        p_Scmm_Med_Needed_Dt       Sc_Moz_Med_Data_Recomm.Scmm_Med_Needed_Dt%TYPE DEFAULT NULL,
        p_Scmm_Med_Qty             Sc_Moz_Med_Data_Recomm.Scmm_Med_Qty%TYPE DEFAULT NULL,
        p_Scmm_St                  Sc_Moz_Med_Data_Recomm.Scmm_St%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Moz_Med_Data_Recomm (Scmm_Id,
                                            Scmm_Scdi,
                                            Scmm_Sc,
                                            Scmm_Is_Med_Needed,
                                            Scmm_Med_Name,
                                            Scmm_Med_Needed_Dt,
                                            Scmm_Med_Qty,
                                            Scmm_St)
             VALUES (0,
                     p_Scmm_Scdi,
                     p_Scmm_Sc,
                     p_Scmm_Is_Med_Needed,
                     p_Scmm_Med_Name,
                     p_Scmm_Med_Needed_Dt,
                     p_Scmm_Med_Qty,
                     NVL (p_Scmm_St, 'VR'))
          RETURNING Scmm_Id
               INTO p_Scmm_Id;
    END;

    /*
    info:    Збреження даних про втрату професіної працездатності від МОЗ
    author:  kelatev
    */
    PROCEDURE Save_Moz_Loss_Prof_Ability (
        p_Scml_Id                        OUT Sc_Moz_Loss_Prof_Ability.Scml_Id%TYPE,
        p_Scml_Scdi                          Sc_Moz_Loss_Prof_Ability.Scml_Scdi%TYPE DEFAULT NULL,
        p_Scml_Sc                            Sc_Moz_Loss_Prof_Ability.Scml_Sc%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Dt          Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Dt%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Perc        Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Perc%TYPE DEFAULT NULL,
        p_Scml_Loss_Prof_Ability_Cause       Sc_Moz_Loss_Prof_Ability.Scml_Loss_Prof_Ability_Cause%TYPE DEFAULT NULL,
        p_Scml_St                            Sc_Moz_Loss_Prof_Ability.Scml_St%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Sc_Moz_Loss_Prof_Ability (Scml_Id,
                                              Scml_Scdi,
                                              Scml_Sc,
                                              Scml_Loss_Prof_Ability_Dt,
                                              Scml_Loss_Prof_Ability_Perc,
                                              Scml_Loss_Prof_Ability_Cause,
                                              Scml_St)
             VALUES (0,
                     p_Scml_Scdi,
                     p_Scml_Sc,
                     p_Scml_Loss_Prof_Ability_Dt,
                     p_Scml_Loss_Prof_Ability_Perc,
                     p_Scml_Loss_Prof_Ability_Cause,
                     NVL (p_Scml_St, 'VR'))
          RETURNING Scml_Id
               INTO p_Scml_Id;
    END;
END Api$socialcard_Ext;
/