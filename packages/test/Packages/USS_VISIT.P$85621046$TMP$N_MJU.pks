/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.P$85621046$TMP$N_MJU
IS
    -- Author  : SHOSTAK
    -- Created : 08.12.2022 1:37:32 PM
    -- Purpose :

    TYPE t_Char_Arr IS TABLE OF VARCHAR2 (10);

    FUNCTION Clear_Crt_Num (p_Doc_Num IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Reg_Verify_Birth_Certificate_Req (p_Rn_Nrt   IN     NUMBER,
                                               p_Obj_Id   IN     NUMBER,
                                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Certificate_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Death_Cert_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Death_Cert_Resp (p_Ur_Id      IN     NUMBER,
                                             p_Response   IN     CLOB,
                                             p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Cert_By_Birthday_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Birth_Cert_By_Name_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Cert_By_Name_Dt_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Nsp_Code_Link_Req (p_Rn_Nrt   IN     NUMBER,
                                           p_Obj_Id   IN     NUMBER,
                                           p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Nsp_Code_Link_Resp (p_Ur_Id      IN     NUMBER,
                                                p_Response   IN     CLOB,
                                                p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Verify_Nsp_Code_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Ar_By_Name_And_Birth_Date_Req (p_Rn_Nrt   IN     NUMBER,
                                                p_Obj_Id   IN     NUMBER,
                                                p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_App_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Apd_Ar_By_Rnokpp_Role1_Req (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Birth_Ar_Name_And_Birth_Date_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Birth_Ar_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Test_Resp (p_Ur_Id      IN     NUMBER,
                                p_Response   IN     CLOB,
                                p_Error      IN OUT VARCHAR2);
END P$85621046$TMP$N_MJU;
/
