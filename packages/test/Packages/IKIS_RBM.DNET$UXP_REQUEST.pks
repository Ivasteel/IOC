/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$UXP_REQUEST
IS
    -- Author  : SHOSTAK
    -- Created : 22.06.2021 19:10:59
    -- Purpose :

    g_Client_Member_Code   Uss_Ndi.v_Ndi_Uxp_Members.Um_Code%TYPE;
    g_Client_Subsys        Uss_Ndi.v_Ndi_Uxp_Members.Um_Subsys%TYPE;

    PROCEDURE Register_Out_Request (
        p_Ur_Plan_Dt     IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Urt         IN     Uxp_Request.Ur_Urt%TYPE,
        p_Ur_Create_Wu   IN     Uxp_Request.Ur_Create_Wu%TYPE,
        p_Ur_Ext_Id      IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Body        IN     Uxp_Request.Ur_Body%TYPE,
        p_New_Id            OUT Uxp_Request.Ur_Ext_Id%TYPE);

    PROCEDURE Save_Request_Result (
        p_Ur_Id              IN Uxp_Request.Ur_Id%TYPE,
        p_Ur_Has_Subreq      IN Uxp_Request.Ur_Has_Subreq%TYPE,
        p_Ur_Response_Time   IN Uxp_Request.Ur_Response_Time%TYPE,
        p_Ur_Error           IN Uxp_Request.Ur_Error%TYPE,
        p_Ur_Soap_Req        IN Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Soap_Resp       IN Uxp_Request.Ur_Soap_Resp%TYPE);

    PROCEDURE Register_In_Out_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE,
        p_Uxp_Client       OUT SYS_REFCURSOR,
        p_Uxp_Service      OUT SYS_REFCURSOR);

    PROCEDURE Register_In_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE);

    PROCEDURE Register_In_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE,
        p_Work_Func        OUT VARCHAR2);

    PROCEDURE Register_In_Request (
        p_Urt_Code        IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Client_Code     IN     Uss_Ndi.v_Ndi_Uxp_Members.Um_Code%TYPE,
        p_Client_Subsys   IN     Uss_Ndi.v_Ndi_Uxp_Members.Um_Subsys%TYPE,
        p_Ask_Dt          IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id       IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req     IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id              OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn              OUT Uxp_Request.Ur_Rn%TYPE,
        p_Rn_Src          IN OUT Request_Journal.Rn_Src%TYPE,
        p_Work_Func          OUT VARCHAR2);

    PROCEDURE Save_Request_Result (
        p_Ur_Rn              IN Uxp_Request.Ur_Rn%TYPE,
        p_Ur_Response_Time   IN Uxp_Request.Ur_Response_Time%TYPE,
        p_Ur_Handle_Dt       IN Uxp_Request.Ur_Handle_Dt%TYPE,
        p_Ur_Error           IN Uxp_Request.Ur_Error%TYPE,
        p_Ur_Soap_Resp       IN Uxp_Request.Ur_Soap_Resp%TYPE,
        p_Rn_Answer_Dt       IN Request_Journal.Rn_Answer_Dt%TYPE);

    PROCEDURE Delay_Request (p_Ur_Id           IN Uxp_Request.Ur_Id%TYPE,
                             p_Delay_Seconds   IN NUMBER);

    FUNCTION Get_Parent_Req_Status (p_Ur_Id IN NUMBER)
        RETURN VARCHAR2;

    /*
    info:    Отримання похіддного запиту
    author:  sho
    note:    Використовється, якщо вихідний запит є квитанцією на інший вхідний запит
    */
    FUNCTION Get_Src_Request_Id (p_Ur_Id IN Uxp_Ack.Ua_Ur_Out%TYPE)
        RETURN Uxp_Ack.Ua_Ur_Out%TYPE;
END Dnet$uxp_Request;
/


GRANT EXECUTE ON IKIS_RBM.DNET$UXP_REQUEST TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.DNET$UXP_REQUEST TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$UXP_REQUEST
IS
    ----------------------------------------------------------------------------------
    --               Реєстрація вихідного запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Register_Out_Request (
        p_Ur_Plan_Dt     IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Urt         IN     Uxp_Request.Ur_Urt%TYPE,
        p_Ur_Create_Wu   IN     Uxp_Request.Ur_Create_Wu%TYPE,
        p_Ur_Ext_Id      IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Body        IN     Uxp_Request.Ur_Body%TYPE,
        p_New_Id            OUT Uxp_Request.Ur_Ext_Id%TYPE)
    IS
        l_Rn_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => NVL (p_Ur_Plan_Dt, SYSDATE),
            p_Ur_Urt         => p_Ur_Urt,
            p_Ur_Create_Wu   => p_Ur_Create_Wu,
            p_Ur_Ext_Id      => p_Ur_Ext_Id,
            p_Ur_Body        => p_Ur_Body,
            p_New_Id         => p_New_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => NULL,
            p_Rn_Hs_Ins      => NULL,
            p_New_Rn_Id      => l_Rn_Id);
    END;

    PROCEDURE Save_Request_Result (
        p_Ur_Id              IN Uxp_Request.Ur_Id%TYPE,
        p_Ur_Has_Subreq      IN Uxp_Request.Ur_Has_Subreq%TYPE,
        p_Ur_Response_Time   IN Uxp_Request.Ur_Response_Time%TYPE,
        p_Ur_Error           IN Uxp_Request.Ur_Error%TYPE,
        p_Ur_Soap_Req        IN Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Soap_Resp       IN Uxp_Request.Ur_Soap_Resp%TYPE)
    IS
        l_New_Id   NUMBER;
        l_Ur_St    VARCHAR2 (10);
        l_Rn_St    VARCHAR2 (10);
        l_Rn_Id    NUMBER;
    BEGIN
        CASE
            WHEN p_Ur_Error IS NULL
            THEN
                l_Ur_St := Api$uxp_Request.c_Ur_St_Ok;
                l_Rn_St := Api$request.c_Rn_St_Ok;
            ELSE
                l_Ur_St := Api$uxp_Request.c_Ur_St_Err;
                l_Rn_St := Api$request.c_Rn_St_Err;
        END CASE;

        Api$uxp_Request.Save_Request (
            p_Ur_Id              => p_Ur_Id,
            p_Ur_Has_Subreq      => p_Ur_Has_Subreq,
            p_Ur_Response_Time   => p_Ur_Response_Time,
            p_Ur_Handle_Dt       => SYSDATE,
            p_Ur_St              => l_Ur_St,
            p_Ur_Error           => p_Ur_Error,
            p_Ur_Soap_Req        => p_Ur_Soap_Req,
            p_Ur_Soap_Resp       => p_Ur_Soap_Resp,
            p_New_Id             => l_New_Id);

        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        Api$request.Save_Request_Journal (
            p_Rn_Id          => l_Rn_Id,
            p_Rn_Worked_Mc   => p_Ur_Response_Time,
            p_Rn_St          => l_Rn_St,
            p_Rn_Answer_Dt   => SYSDATE,
            p_New_Id         => l_New_Id);
    END;

    ----------------------------------------------------------------------------------
    --               Реєстрація "редірект" запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Register_In_Out_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE,
        p_Uxp_Client       OUT SYS_REFCURSOR,
        p_Uxp_Service      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Register_In_Request (p_Urt_Code      => p_Urt_Code,
                             p_Rn_Src        => p_Rn_Src,
                             p_Ask_Dt        => p_Ask_Dt,
                             p_Ur_Ext_Id     => p_Ur_Ext_Id,
                             p_Ur_Soap_Req   => p_Ur_Soap_Req,
                             p_Ur_Id         => p_Ur_Id,
                             p_Ur_Rn         => p_Ur_Rn);

        OPEN p_Uxp_Client FOR
            SELECT m.Um_Class      AS Member_Class,
                   m.Um_Code       AS Member_Code,
                   m.Um_Subsys     AS Subsystem_Code
              FROM Uxp_Request  r
                   JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON r.Ur_Urt = t.Urt_Id
                   JOIN Uss_Ndi.v_Ndi_Uxp_Members m
                       ON t.Urt_Client_Member = m.Um_Id
             WHERE r.Ur_Id = p_Ur_Id;

        OPEN p_Uxp_Service FOR
            SELECT m.Um_Class             AS Member_Class,
                   m.Um_Code              AS Member_Code,
                   m.Um_Subsys            AS Subsystem_Code,
                   t.Urt_Service_Code     AS Service_Code
              FROM Uxp_Request  r
                   JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON r.Ur_Urt = t.Urt_Id
                   JOIN Uss_Ndi.v_Ndi_Uxp_Members m
                       ON t.Urt_Server_Member = m.Um_Id
             WHERE r.Ur_Id = p_Ur_Id;
    END;

    ----------------------------------------------------------------------------------
    --               Реєстрація вхідного запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Register_In_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE)
    IS
        l_Work_Func   VARCHAR (200);
    BEGIN
        Register_In_Request (p_Urt_Code      => p_Urt_Code,
                             p_Rn_Src        => p_Rn_Src,
                             p_Ask_Dt        => p_Ask_Dt,
                             p_Ur_Ext_Id     => p_Ur_Ext_Id,
                             p_Ur_Soap_Req   => p_Ur_Soap_Req,
                             p_Ur_Id         => p_Ur_Id,
                             p_Ur_Rn         => p_Ur_Rn,
                             p_Work_Func     => l_Work_Func);
    END;

    ----------------------------------------------------------------------------------
    --               Реєстрація вхідного запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Register_In_Request (
        p_Urt_Code      IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Ask_Dt        IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id     IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req   IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id            OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn            OUT Uxp_Request.Ur_Rn%TYPE,
        p_Work_Func        OUT VARCHAR2)
    IS
        l_Ur_Urt   Uxp_Request.Ur_Urt%TYPE;
        l_Rn_Nrt   Request_Journal.Rn_Nrt%TYPE;
    BEGIN
        --Визначаємо тип запиту за кодом
        SELECT MAX (t.Urt_Id), MAX (t.Urt_Nrt), MAX (Tt.Nrt_Work_Func)
          INTO l_Ur_Urt, l_Rn_Nrt, p_Work_Func
          FROM Uss_Ndi.v_Ndi_Uxp_Req_Types  t
               JOIN Uss_Ndi.v_Ndi_Request_Type Tt ON t.Urt_Nrt = Tt.Nrt_Id
         WHERE t.Urt_Code = p_Urt_Code;

        IF l_Ur_Urt IS NULL
        THEN
            Raise_Application_Error (-20000,
                                     'Невідомий тип запиту: ' || p_Urt_Code);
        END IF;

        Api$request.Save_Request_Journal (
            p_Rn_Id          => NULL,
            p_Rn_Nrt         => l_Rn_Nrt,
            p_Rn_Hs_Ins      => NULL,
            p_Rn_Ins_Dt      => SYSDATE,
            p_Rn_Expect_Dt   => NULL,
            p_Rn_Worked_Mc   => NULL,
            p_Rn_St          => Api$request.c_Rn_St_New,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Answer_Dt   => NULL,
            p_Rn_Ask_Dt      => p_Ask_Dt,
            p_New_Id         => p_Ur_Rn);

        Api$uxp_Request.Save_Request (
            p_Ur_Id              => NULL,
            p_Ur_Plan_Dt         => SYSDATE,
            p_Ur_Create_Dt       => SYSDATE,
            p_Ur_Has_Subreq      => 'F',
            p_Ur_Response_Time   => NULL,
            p_Ur_Urt             => l_Ur_Urt,
            p_Ur_Handle_Dt       => NULL,
            p_Ur_St              => Api$uxp_Request.c_Ur_St_New,
            p_Ur_Create_Wu       => NULL,
            p_Ur_Ext_Id          => p_Ur_Ext_Id,
            p_Ur_Error           => NULL,
            p_Ur_Body            => NULL,
            p_Ur_Soap_Req        => p_Ur_Soap_Req,
            p_Ur_Soap_Resp       => NULL,
            p_Ur_Rn              => p_Ur_Rn,
            p_New_Id             => p_Ur_Id);
    END;

    ----------------------------------------------------------------------------------
    --               Реєстрація вхідного запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Register_In_Request (
        p_Urt_Code        IN     Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE,
        p_Client_Code     IN     Uss_Ndi.v_Ndi_Uxp_Members.Um_Code%TYPE,
        p_Client_Subsys   IN     Uss_Ndi.v_Ndi_Uxp_Members.Um_Subsys%TYPE,
        p_Ask_Dt          IN     Request_Journal.Rn_Ask_Dt%TYPE,
        p_Ur_Ext_Id       IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Soap_Req     IN     Uxp_Request.Ur_Soap_Req%TYPE,
        p_Ur_Id              OUT Uxp_Request.Ur_Id%TYPE,
        p_Ur_Rn              OUT Uxp_Request.Ur_Rn%TYPE,
        p_Rn_Src          IN OUT Request_Journal.Rn_Src%TYPE,
        p_Work_Func          OUT VARCHAR2)
    IS
        l_Ur_Urt       Uxp_Request.Ur_Urt%TYPE;
        l_Rn_Nrt       Request_Journal.Rn_Nrt%TYPE;
        l_Um_Id        NUMBER;
        l_Is_Allowed   NUMBER;
    BEGIN
        g_Client_Member_Code := p_Client_Code;
        g_Client_Subsys := p_Client_Subsys;

        --Визначаємо тип запиту за кодом
        SELECT MAX (t.Urt_Id), MAX (t.Urt_Nrt), MAX (Tt.Nrt_Work_Func)
          INTO l_Ur_Urt, l_Rn_Nrt, p_Work_Func
          FROM Uss_Ndi.v_Ndi_Uxp_Req_Types  t
               JOIN Uss_Ndi.v_Ndi_Request_Type Tt ON t.Urt_Nrt = Tt.Nrt_Id
         WHERE t.Urt_Code = p_Urt_Code;

        IF l_Ur_Urt IS NULL
        THEN
            Raise_Application_Error (-20000,
                                     'Невідомий тип запиту: ' || p_Urt_Code);
        END IF;

        --Визначаємо джерело запиту за реквізитами клієнта(за заголовку Трембіти)
        SELECT MAX (m.Um_Src), MAX (m.Um_Id)
          INTO p_Rn_Src, l_Um_Id
          FROM Uss_Ndi.v_Ndi_Uxp_Members m
         WHERE    (    m.Um_Code = p_Client_Code
                   AND m.Um_Subsys = p_Client_Subsys)
               OR (m.Um_Src = p_Rn_Src);

        /*  IF p_Rn_Src IS NULL THEN
          Raise_Application_Error(-20000, 'Невідоме джерело запиту');
        END IF;*/

        IF p_Urt_Code LIKE 'USS.Common.%'
        THEN
            SELECT SIGN (COUNT (*))
              INTO l_Is_Allowed
              FROM Uss_Ndi.v_Ndi_Uxp_Access a
             WHERE a.Nua_Um = l_Um_Id AND a.Nua_Urt = l_Ur_Urt;

            IF l_Is_Allowed <> 1
            THEN
                Raise_Application_Error (-20000, 'Доступ заборонено');
            END IF;
        END IF;

        Api$request.Save_Request_Journal (
            p_Rn_Id          => NULL,
            p_Rn_Nrt         => l_Rn_Nrt,
            p_Rn_Hs_Ins      => NULL,
            p_Rn_Ins_Dt      => SYSDATE,
            p_Rn_Expect_Dt   => NULL,
            p_Rn_Worked_Mc   => NULL,
            p_Rn_St          => Api$request.c_Rn_St_New,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Answer_Dt   => NULL,
            p_Rn_Ask_Dt      => p_Ask_Dt,
            p_New_Id         => p_Ur_Rn);

        Api$uxp_Request.Save_Request (
            p_Ur_Id              => NULL,
            p_Ur_Plan_Dt         => SYSDATE,
            p_Ur_Create_Dt       => SYSDATE,
            p_Ur_Has_Subreq      => 'F',
            p_Ur_Response_Time   => NULL,
            p_Ur_Urt             => l_Ur_Urt,
            p_Ur_Handle_Dt       => NULL,
            p_Ur_St              => Api$uxp_Request.c_Ur_St_New,
            p_Ur_Create_Wu       => NULL,
            p_Ur_Ext_Id          => p_Ur_Ext_Id,
            p_Ur_Error           => NULL,
            p_Ur_Body            => NULL,
            p_Ur_Soap_Req        => p_Ur_Soap_Req,
            p_Ur_Soap_Resp       => NULL,
            p_Ur_Rn              => p_Ur_Rn,
            p_New_Id             => p_Ur_Id);
    END;

    ----------------------------------------------------------------------------------
    --               Збереження результату обробки вхідного запиту
    ----------------------------------------------------------------------------------
    PROCEDURE Save_Request_Result (
        p_Ur_Rn              IN Uxp_Request.Ur_Rn%TYPE,
        p_Ur_Response_Time   IN Uxp_Request.Ur_Response_Time%TYPE,
        p_Ur_Handle_Dt       IN Uxp_Request.Ur_Handle_Dt%TYPE,
        p_Ur_Error           IN Uxp_Request.Ur_Error%TYPE,
        p_Ur_Soap_Resp       IN Uxp_Request.Ur_Soap_Resp%TYPE,
        p_Rn_Answer_Dt       IN Request_Journal.Rn_Answer_Dt%TYPE)
    IS
        l_New_Id   NUMBER;
        l_Ur_Id    NUMBER;
        l_Ur_St    VARCHAR2 (10);
        l_Rn_St    VARCHAR2 (10);
    BEGIN
        CASE
            WHEN p_Ur_Error IS NULL
            THEN
                l_Ur_St := Api$uxp_Request.c_Ur_St_Ok;
                l_Rn_St := Api$request.c_Rn_St_Ok;
            ELSE
                l_Ur_St := Api$uxp_Request.c_Ur_St_Err;
                l_Rn_St := Api$request.c_Rn_St_Err;
        END CASE;

        SELECT r.Ur_Id
          INTO l_Ur_Id
          FROM Uxp_Request r
         WHERE r.Ur_Rn = p_Ur_Rn;

        Api$uxp_Request.Save_Request (
            p_Ur_Id              => l_Ur_Id,
            p_Ur_Response_Time   => p_Ur_Response_Time,
            p_Ur_Handle_Dt       => p_Ur_Handle_Dt,
            p_Ur_St              => l_Ur_St,
            p_Ur_Error           => p_Ur_Error,
            p_Ur_Soap_Resp       => p_Ur_Soap_Resp,
            p_New_Id             => l_New_Id);

        Api$request.Save_Request_Journal (
            p_Rn_Id          => p_Ur_Rn,
            p_Rn_Worked_Mc   => p_Ur_Response_Time,
            p_Rn_St          => l_Rn_St,
            p_Rn_Answer_Dt   => p_Rn_Answer_Dt,
            p_New_Id         => l_New_Id);
    END;

    PROCEDURE Delay_Request (p_Ur_Id           IN Uxp_Request.Ur_Id%TYPE,
                             p_Delay_Seconds   IN NUMBER)
    IS
    BEGIN
        Api$uxp_Request.Delay_Request (p_Ur_Id           => p_Ur_Id,
                                       p_Delay_Seconds   => p_Delay_Seconds);
    END;

    FUNCTION Get_Parent_Req_Status (p_Ur_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Url_Parent   NUMBER;
        l_Result       Uxp_Request.Ur_St%TYPE;
    BEGIN
        SELECT MAX (l.Url_Parent)
          INTO l_Url_Parent
          FROM Uxp_Req_Links l
         WHERE l.Url_Ur = p_Ur_Id;

        IF l_Url_Parent IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT r.Ur_St
          INTO l_Result
          FROM Uxp_Request r
         WHERE r.Ur_Id = l_Url_Parent;

        RETURN l_Result;
    END;

    /*
    info:    Отримання похіддного запиту
    author:  sho
    note:    Використовється, якщо вихідний запит є квитанцією на інший вхідний запит
    */
    FUNCTION Get_Src_Request_Id (p_Ur_Id IN Uxp_Ack.Ua_Ur_Out%TYPE)
        RETURN Uxp_Ack.Ua_Ur_Out%TYPE
    IS
        l_Result   Uxp_Ack.Ua_Ur_Out%TYPE;
    BEGIN
        SELECT TO_NUMBER (MAX (r.Ur_Ext_Id))
          INTO l_Result
          FROM Uxp_Ack a JOIN Uxp_Request r ON a.Ua_Ur_In = r.Ur_Id
         WHERE a.Ua_Ur_Out = p_Ur_Id;

        RETURN l_Result;
    END;
END Dnet$uxp_Request;
/