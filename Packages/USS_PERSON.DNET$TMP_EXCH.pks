/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$TMP_EXCH
IS
    -- Author  : SHOSTAK
    -- Created : 25.03.2022 7:04:48 AM
    -- Purpose :
    c_Src_Cbi                 CONSTANT VARCHAR2 (10) := '34';
    c_Src_Asopd               CONSTANT VARCHAR2 (10) := '7';

    c_Ndt_Msec                CONSTANT NUMBER := 201;
    c_Nda_Msec_Doc_Num        CONSTANT NUMBER := 346;
    c_Nda_Msec_Start_St       CONSTANT NUMBER := 352;
    c_Nda_Msec_Stop_Dt        CONSTANT NUMBER := 347;
    c_Nda_Msec_Inv_Gr         CONSTANT NUMBER := 349;
    c_Nda_Msec_Inv_Rsn        CONSTANT NUMBER := 353;

    c_Ndt_Asopd               CONSTANT NUMBER := 10041;
    c_Nda_Asopd_Org           CONSTANT NUMBER := 1099;
    c_Nda_Asopd_Acc_Num       CONSTANT NUMBER := 1100;
    c_Nda_Asopd_Npt_Code      CONSTANT NUMBER := 1101;
    c_Nda_Asopd_Start_Dt      CONSTANT NUMBER := 1102;
    c_Nda_Asopd_Stop_Dt       CONSTANT NUMBER := 1103;
    c_Nda_Asopd_Scy_Group     CONSTANT NUMBER := 1104;
    c_Nda_Asopd_Scy_Reason    CONSTANT NUMBER := 2193;
    c_Nda_Asopd_Decision_Dt   CONSTANT NUMBER := 1105;
    c_Nda_Asopd_Till_Dt       CONSTANT NUMBER := 1106;
    c_Nda_Asopd_Document      CONSTANT NUMBER := 1107;
    c_Nda_Asopd_Rp_Ln         CONSTANT NUMBER := 1108;
    c_Nda_Asopd_Rp_Fn         CONSTANT NUMBER := 1109;
    c_Nda_Asopd_Rp_Mn         CONSTANT NUMBER := 1110;
    c_Nda_Asopd_Rp_Bdt        CONSTANT NUMBER := 1111;

    TYPE r_Doc_Attrs IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (4000),
        Val_Dt     DATE
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attrs;

    TYPE t_Stats IS TABLE OF NUMBER
        INDEX BY VARCHAR2 (300);

    PROCEDURE Stats_Init;

    FUNCTION Get_Stats_Text
        RETURN VARCHAR2;

    PROCEDURE Stats_Inc (p_Measure IN VARCHAR2);

    PROCEDURE Save_Cbi_Disability_Info (p_Rnokpp                IN VARCHAR2,
                                        p_Ozn_Doc               IN VARCHAR2,
                                        p_Sn_Doc                IN VARCHAR2,
                                        p_Full_Name             IN VARCHAR2,
                                        p_First_Name            IN VARCHAR2,
                                        p_Second_Name           IN VARCHAR2,
                                        p_Disabled_Number       IN VARCHAR2,
                                        p_Disabled_Date_Begin   IN VARCHAR2,
                                        p_Disabled_Date_End     IN VARCHAR2,
                                        p_Disabled_Gr           IN VARCHAR2,
                                        p_Disabled_Cat          IN VARCHAR2,
                                        p_Disabled_Cat_Code     IN VARCHAR2,
                                        p_Filename              IN VARCHAR2);

    PROCEDURE Start_Asopd_Dependant_Iter (p_Lfd_Id NUMBER);

    PROCEDURE Save_Asopd_Dependant_Info (
        p_Asd_Lfd              As_Dependant.Asd_Lfd%TYPE,
        p_Asd_Asopd_Code       As_Dependant.Asd_Asopd_Code%TYPE,
        p_Asd_Acc_Num          As_Dependant.Asd_Acc_Num%TYPE,
        p_Asd_Npt_Code         As_Dependant.Asd_Npt_Code%TYPE,
        p_Asd_Start_Dt         As_Dependant.Asd_Start_Dt%TYPE,
        p_Asd_Stop_Dt          As_Dependant.Asd_Stop_Dt%TYPE,
        p_Asd_Scy_Group        As_Dependant.Asd_Scy_Group%TYPE,
        p_Asd_Scy_Reason       As_Dependant.Asd_Scy_Reason%TYPE,
        p_Asd_Onset_Dt         As_Dependant.Asd_Onset_Dt%TYPE,
        p_Asd_Decision_Dt      As_Dependant.Asd_Decision_Dt%TYPE,
        p_Asd_Till_Dt          As_Dependant.Asd_Till_Dt%TYPE,
        p_Asd_Numident         As_Dependant.Asd_Numident%TYPE,
        p_Asd_Document         As_Dependant.Asd_Document%TYPE,
        p_Asd_Ln               As_Dependant.Asd_Ln%TYPE,
        p_Asd_Fn               As_Dependant.Asd_Fn%TYPE,
        p_Asd_Mn               As_Dependant.Asd_Mn%TYPE,
        p_Asd_Birth_Dt         As_Dependant.Asd_Birth_Dt%TYPE,
        p_Asd_Gender           As_Dependant.Asd_Gender%TYPE,
        p_Asd_Nationality      As_Dependant.Asd_Nationality%TYPE,
        p_Asd_Relation_Tp      As_Dependant.Asd_Relation_Tp%TYPE,
        p_Asd_Rp_Numident      As_Dependant.Asd_Rp_Numident%TYPE,
        p_Asd_Rp_Document      As_Dependant.Asd_Rp_Document%TYPE,
        p_Asd_Rp_Ln            As_Dependant.Asd_Rp_Ln%TYPE,
        p_Asd_Rp_Fn            As_Dependant.Asd_Rp_Fn%TYPE,
        p_Asd_Rp_Mn            As_Dependant.Asd_Rp_Mn%TYPE,
        p_Asd_Rp_Birth_Dt      As_Dependant.Asd_Rp_Birth_Dt%TYPE,
        p_Asd_Rp_Gender        As_Dependant.Asd_Rp_Gender%TYPE,
        p_Asd_Rp_Nationality   As_Dependant.Asd_Rp_Nationality%TYPE,
        p_Asd_Rp_Relation_Tp   As_Dependant.Asd_Rp_Relation_Tp%TYPE);

    PROCEDURE Link_Asopd_Dependants_To_Sc (p_File_Name IN VARCHAR2);
END Dnet$tmp_Exch;
/


GRANT EXECUTE ON USS_PERSON.DNET$TMP_EXCH TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.DNET$TMP_EXCH TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.DNET$TMP_EXCH TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.DNET$TMP_EXCH TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.DNET$TMP_EXCH TO USS_VISIT
/
