/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$UXP_REQUEST
IS
    c_Ur_St_New   CONSTANT VARCHAR2 (10) := 'NEW';
    c_Ur_St_Err   CONSTANT VARCHAR2 (10) := 'ERR';
    c_Ur_St_Ok    CONSTANT VARCHAR2 (10) := 'OK';

    PROCEDURE Register_Out_Request (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Id          OUT Uxp_Request.Ur_Ext_Id%TYPE);

    PROCEDURE Register_Out_Request (
        p_Ur_Plan_Dt     IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Urt         IN     Uxp_Request.Ur_Urt%TYPE,
        p_Ur_Create_Wu   IN     Uxp_Request.Ur_Create_Wu%TYPE,
        p_Ur_Ext_Id      IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Body        IN     Uxp_Request.Ur_Body%TYPE,
        p_New_Id            OUT Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_New_Rn_Id         OUT Request_Journal.Rn_Id%TYPE);

    -- Зберегти
    PROCEDURE Save_Request (
        p_Ur_Id              IN     Uxp_Request.Ur_Id%TYPE,
        p_Ur_Plan_Dt         IN     Uxp_Request.Ur_Plan_Dt%TYPE DEFAULT NULL,
        p_Ur_Create_Dt       IN     Uxp_Request.Ur_Create_Dt%TYPE DEFAULT NULL,
        p_Ur_Has_Subreq      IN     Uxp_Request.Ur_Has_Subreq%TYPE DEFAULT NULL,
        p_Ur_Response_Time   IN     Uxp_Request.Ur_Response_Time%TYPE DEFAULT NULL,
        p_Ur_Urt             IN     Uxp_Request.Ur_Urt%TYPE DEFAULT NULL,
        p_Ur_Handle_Dt       IN     Uxp_Request.Ur_Handle_Dt%TYPE DEFAULT NULL,
        p_Ur_St              IN     Uxp_Request.Ur_St%TYPE DEFAULT NULL,
        p_Ur_Create_Wu       IN     Uxp_Request.Ur_Create_Wu%TYPE DEFAULT NULL,
        p_Ur_Ext_Id          IN     Uxp_Request.Ur_Ext_Id%TYPE DEFAULT NULL,
        p_Ur_Error           IN     Uxp_Request.Ur_Error%TYPE DEFAULT NULL,
        p_Ur_Body            IN     Uxp_Request.Ur_Body%TYPE DEFAULT NULL,
        p_Ur_Soap_Req        IN     Uxp_Request.Ur_Soap_Req%TYPE DEFAULT NULL,
        p_Ur_Soap_Resp       IN     Uxp_Request.Ur_Soap_Resp%TYPE DEFAULT NULL,
        p_Ur_Rn              IN     Uxp_Request.Ur_Rn%TYPE DEFAULT NULL,
        p_New_Id                OUT Uxp_Request.Ur_Ext_Id%TYPE);

    PROCEDURE Save_Request_Link (
        p_Url_Ur       IN Uxp_Req_Links.Url_Ur%TYPE,
        p_Url_Root     IN Uxp_Req_Links.Url_Root%TYPE,
        p_Url_Parent   IN Uxp_Req_Links.Url_Parent%TYPE);

    PROCEDURE Save_Request_Response (
        p_Ur_Rn          IN Uxp_Request.Ur_Rn%TYPE,
        p_Ur_Soap_Resp   IN Uxp_Request.Ur_Soap_Resp%TYPE);

    PROCEDURE Delay_Request (p_Ur_Id           IN Uxp_Request.Ur_Id%TYPE,
                             p_Delay_Seconds   IN NUMBER);

    PROCEDURE Delay_Request_Exception (p_Ur_Id           NUMBER,
                                       p_Delay_Seconds   NUMBER,
                                       p_Delay_Reason    VARCHAR2);

    PROCEDURE Unauthorized_Exception;

    FUNCTION Get_Ur_Rn (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN Uxp_Request.Ur_Rn%TYPE;

    FUNCTION Get_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN Uxp_Request%ROWTYPE;

    FUNCTION Get_Vrequest (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN v_Uxp_Request%ROWTYPE; --не удалять - в 12й версии строгая типизация.

    FUNCTION Get_Root_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Child_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Request_Ext_Id (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER;

    PROCEDURE Clear_Lob_Data;

    FUNCTION Is_Same_Request_In_Queue (p_Ur_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Repeat_Out_Request (p_Ur_Id IN NUMBER);

    FUNCTION Parse_Common_Soap_Request (p_Request IN CLOB)
        RETURN CLOB;

    FUNCTION Check_User_Exists (p_Wu_Id NUMBER)
        RETURN NUMBER;

    PROCEDURE Save_Request_Error (
        p_Ure_Ur        IN Uxp_Request_Error.Ure_Ur%TYPE,
        p_Ure_Row_Id    IN Uxp_Request_Error.Ure_Row_Id%TYPE,
        p_Ure_Row_Num   IN Uxp_Request_Error.Ure_Row_Num%TYPE,
        p_Ure_Error     IN Uxp_Request_Error.Ure_Error%TYPE);

    FUNCTION Get_Ur_Nrt (p_Ur_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Ur_Src (p_Ur_Id IN NUMBER)
        RETURN VARCHAR2;
END Api$uxp_Request;
/


GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_REQUEST TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$UXP_REQUEST
IS
    ----------------------------------------------------------------------------
    --                Реєстрація вихідного запиту
    ----------------------------------------------------------------------------
    PROCEDURE Register_Out_Request (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Id          OUT Uxp_Request.Ur_Ext_Id%TYPE)
    IS
        l_Rn_Id   NUMBER;
    BEGIN
        Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                              p_Ur_Urt         => NULL,
                              p_Ur_Create_Wu   => NULL,
                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                              p_Ur_Body        => NULL,
                              p_New_Id         => p_Ur_Id,
                              p_Rn_Nrt         => p_Rn_Nrt,
                              p_Rn_Src         => p_Rn_Src,
                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                              p_New_Rn_Id      => l_Rn_Id);
    END;

    ----------------------------------------------------------------------------
    --                Реєстрація вихідного запиту
    ----------------------------------------------------------------------------
    PROCEDURE Register_Out_Request (
        p_Ur_Plan_Dt     IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Urt         IN     Uxp_Request.Ur_Urt%TYPE,
        p_Ur_Create_Wu   IN     Uxp_Request.Ur_Create_Wu%TYPE,
        p_Ur_Ext_Id      IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Ur_Body        IN     Uxp_Request.Ur_Body%TYPE,
        p_New_Id            OUT Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_New_Rn_Id         OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Rn_Nrt     NUMBER;
        l_Ur_Urt     NUMBER;
        l_Urt_Code   Uss_Ndi.v_Ndi_Uxp_Req_Types.Urt_Code%TYPE;
    BEGIN
        IF p_Rn_Nrt IS NULL
        THEN
            SELECT t.Urt_Nrt, t.Urt_Code
              INTO l_Rn_Nrt, l_Urt_Code
              FROM Uss_Ndi.v_Ndi_Uxp_Req_Types t
             WHERE t.Urt_Id = p_Ur_Urt;
        ELSE
            l_Rn_Nrt := p_Rn_Nrt;
        END IF;

        IF p_Ur_Urt IS NULL
        THEN
            SELECT t.Urt_Id, t.Urt_Code
              INTO l_Ur_Urt, l_Urt_Code
              FROM Uss_Ndi.v_Ndi_Uxp_Req_Types t
             WHERE t.Urt_Nrt = p_Rn_Nrt;
        ELSE
            l_Ur_Urt := p_Ur_Urt;
        END IF;

        IF l_Urt_Code IS NULL
        THEN
            SELECT t.Urt_Code
              INTO l_Urt_Code
              FROM Uss_Ndi.v_Ndi_Uxp_Req_Types t
             WHERE t.Urt_Id = l_Ur_Urt;
        END IF;

        --Реєструємо запит в прикладному журналі
        Api$request.Save_Request_Journal (
            p_Rn_Id          => NULL,
            p_Rn_Nrt         => l_Rn_Nrt,
            p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
            p_Rn_Ins_Dt      => SYSDATE,
            p_Rn_Expect_Dt   => SYSDATE,
            p_Rn_Worked_Mc   => NULL,
            p_Rn_St          => Api$request.c_Rn_St_New,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Answer_Dt   => NULL,
            p_Rn_Ask_Dt      => NULL,
            p_New_Id         => p_New_Rn_Id);

        --Реєструємо запит в транспортному журналі
        Save_Request (p_Ur_Id              => NULL,
                      p_Ur_Plan_Dt         => p_Ur_Plan_Dt,
                      p_Ur_Create_Dt       => SYSDATE,
                      p_Ur_Has_Subreq      => 'F',
                      p_Ur_Response_Time   => NULL,
                      p_Ur_Urt             => l_Ur_Urt,
                      p_Ur_Handle_Dt       => NULL,
                      p_Ur_St              => c_Ur_St_New,
                      p_Ur_Create_Wu       => p_Ur_Create_Wu,
                      p_Ur_Ext_Id          => p_Ur_Ext_Id,
                      p_Ur_Error           => NULL,
                      p_Ur_Body            => p_Ur_Body,
                      p_Ur_Soap_Req        => NULL,
                      p_Ur_Soap_Resp       => NULL,
                      p_Ur_Rn              => p_New_Rn_Id,
                      p_New_Id             => p_New_Id);

        --IKIS_SYS.IKIS_PROCEDURE_LOG.LOG(p_src => 'IKIS_RBM.Api$uxp_Request.Register_Out_Request',p_obj_tp => 'UXP_REQUEST', p_obj_id => p_New_Id, p_regular_params => 'l_Urt_Code='||l_Urt_Code);

        --Ставимо запит в чергу на обробку
        INSERT INTO Uxp_Req_Queue (Urq_Id, Urq_Urt_Code)
             VALUES (p_New_Id, l_Urt_Code);
    END;

    -- Зберегти
    PROCEDURE Save_Request (
        p_Ur_Id              IN     Uxp_Request.Ur_Id%TYPE,
        p_Ur_Plan_Dt         IN     Uxp_Request.Ur_Plan_Dt%TYPE DEFAULT NULL,
        p_Ur_Create_Dt       IN     Uxp_Request.Ur_Create_Dt%TYPE DEFAULT NULL,
        p_Ur_Has_Subreq      IN     Uxp_Request.Ur_Has_Subreq%TYPE DEFAULT NULL,
        p_Ur_Response_Time   IN     Uxp_Request.Ur_Response_Time%TYPE DEFAULT NULL,
        p_Ur_Urt             IN     Uxp_Request.Ur_Urt%TYPE DEFAULT NULL,
        p_Ur_Handle_Dt       IN     Uxp_Request.Ur_Handle_Dt%TYPE DEFAULT NULL,
        p_Ur_St              IN     Uxp_Request.Ur_St%TYPE DEFAULT NULL,
        p_Ur_Create_Wu       IN     Uxp_Request.Ur_Create_Wu%TYPE DEFAULT NULL,
        p_Ur_Ext_Id          IN     Uxp_Request.Ur_Ext_Id%TYPE DEFAULT NULL,
        p_Ur_Error           IN     Uxp_Request.Ur_Error%TYPE DEFAULT NULL,
        p_Ur_Body            IN     Uxp_Request.Ur_Body%TYPE DEFAULT NULL,
        p_Ur_Soap_Req        IN     Uxp_Request.Ur_Soap_Req%TYPE DEFAULT NULL,
        p_Ur_Soap_Resp       IN     Uxp_Request.Ur_Soap_Resp%TYPE DEFAULT NULL,
        p_Ur_Rn              IN     Uxp_Request.Ur_Rn%TYPE DEFAULT NULL,
        p_New_Id                OUT Uxp_Request.Ur_Ext_Id%TYPE)
    IS
    BEGIN
        IF p_Ur_Id IS NULL
        THEN
            INSERT INTO Uxp_Request (Ur_Id,
                                     Ur_Plan_Dt,
                                     Ur_Create_Dt,
                                     Ur_Has_Subreq,
                                     Ur_Response_Time,
                                     Ur_Urt,
                                     Ur_Handle_Dt,
                                     Ur_St,
                                     Ur_Create_Wu,
                                     Ur_Ext_Id,
                                     Ur_Error,
                                     Ur_Body,
                                     Ur_Soap_Req,
                                     Ur_Soap_Resp,
                                     Ur_Rn)
                 VALUES (p_Ur_Id,
                         p_Ur_Plan_Dt,
                         p_Ur_Create_Dt,
                         p_Ur_Has_Subreq,
                         p_Ur_Response_Time,
                         p_Ur_Urt,
                         p_Ur_Handle_Dt,
                         p_Ur_St,
                         p_Ur_Create_Wu,
                         p_Ur_Ext_Id,
                         p_Ur_Error,
                         p_Ur_Body,
                         p_Ur_Soap_Req,
                         p_Ur_Soap_Resp,
                         p_Ur_Rn)
              RETURNING Ur_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Ur_Id;

            UPDATE Uxp_Request
               SET Ur_Has_Subreq = NVL (p_Ur_Has_Subreq, Ur_Has_Subreq),
                   Ur_Response_Time = p_Ur_Response_Time,
                   Ur_Handle_Dt = p_Ur_Handle_Dt,
                   Ur_St = p_Ur_St,
                   Ur_Error = p_Ur_Error,
                   Ur_Soap_Req = NVL (p_Ur_Soap_Req, Ur_Soap_Req),
                   Ur_Soap_Resp = p_Ur_Soap_Resp,
                   Ur_Attempts = NVL (Ur_Attempts, 0) + 1
             WHERE Ur_Id = p_Ur_Id;

            IF p_Ur_St IN (c_Ur_St_Err, c_Ur_St_Ok)
            THEN
                DELETE FROM Uxp_Req_Queue q
                      WHERE q.Urq_Id = p_Ur_Id;
            END IF;
        END IF;
    END;

    PROCEDURE Save_Request_Link (
        p_Url_Ur       IN Uxp_Req_Links.Url_Ur%TYPE,
        p_Url_Root     IN Uxp_Req_Links.Url_Root%TYPE,
        p_Url_Parent   IN Uxp_Req_Links.Url_Parent%TYPE)
    IS
    BEGIN
        INSERT INTO Uxp_Req_Links (Url_Ur, Url_Root, Url_Parent)
             VALUES (p_Url_Ur, p_Url_Root, p_Url_Parent);
    END;

    PROCEDURE Save_Request_Response (
        p_Ur_Rn          IN Uxp_Request.Ur_Rn%TYPE,
        p_Ur_Soap_Resp   IN Uxp_Request.Ur_Soap_Resp%TYPE)
    IS
    BEGIN
        UPDATE Uxp_Request Ur
           SET Ur.Ur_Soap_Resp = p_Ur_Soap_Resp
         WHERE Ur.Ur_Rn = p_Ur_Rn;
    END;

    PROCEDURE Delay_Request (p_Ur_Id           IN Uxp_Request.Ur_Id%TYPE,
                             p_Delay_Seconds   IN NUMBER)
    IS
    BEGIN
        UPDATE Uxp_Request
           SET Ur_Plan_Dt =
                   CASE
                       WHEN NVL (Ur_Attempts, 0) < 4
                       THEN
                             SYSDATE
                           + NUMTODSINTERVAL (p_Delay_Seconds, 'second')
                       ELSE
                           --Якщо вже виконано кілька спроб, відкладаємо запит на довший час,
                           --щоб не навантажувати шини та мережу
                           SYSDATE + INTERVAL '3' HOUR
                   END,
               Ur_Attempts = NVL (Ur_Attempts, 0) + 1
         WHERE Ur_Id = p_Ur_Id;

        Uss_Visit.Dnet$verification.Delay_Verification (p_Ur_Id,
                                                        p_Delay_Seconds);
    END;

    PROCEDURE Delay_Request_Exception (p_Ur_Id           NUMBER,
                                       p_Delay_Seconds   NUMBER,
                                       p_Delay_Reason    VARCHAR2)
    IS
    BEGIN
        UPDATE Uxp_Request r
           SET r.Ur_Plan_Dt =
                   CASE
                       WHEN NVL (r.Ur_Attempts, 0) < 4
                       THEN
                             SYSDATE
                           + NUMTODSINTERVAL (p_Delay_Seconds, 'second')
                       ELSE
                           --Якщо вже виконано кілька спроб, відкладаємо запит на довший час,
                           --щоб не навантажувати шини та мережу
                           SYSDATE + INTERVAL '3' HOUR
                   END,
               r.Ur_Error = p_Delay_Reason,
               Ur_Attempts = NVL (Ur_Attempts, 0) + 1
         WHERE r.Ur_Id = p_Ur_Id;

        COMMIT;

        Raise_Application_Error (
            -20999,
               'Запит буде виконано повторно через '
            || p_Delay_Seconds
            || ' секунд. Причина: '
            || p_Delay_Reason);
    END;

    PROCEDURE Unauthorized_Exception
    IS
    BEGIN
        Raise_Application_Error (-20998, 'Unauthorized');
    END;

    FUNCTION Get_Ur_Rn (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN Uxp_Request.Ur_Rn%TYPE
    IS
        l_Ur_Rn   NUMBER;
    BEGIN
        SELECT r.Ur_Rn
          INTO l_Ur_Rn
          FROM Uxp_Request r
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Ur_Rn;
    END;

    FUNCTION Get_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN Uxp_Request%ROWTYPE
    IS
        l_Result   Uxp_Request%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Result
          FROM Uxp_Request r
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Vrequest (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN v_Uxp_Request%ROWTYPE
    IS
        l_Result   v_Uxp_Request%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Result
          FROM v_Uxp_Request r
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Result;
    END;

    FUNCTION Check_User_Exists (p_Wu_Id NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Tools.Check_User_Exists (p_Wu_Id);
    END;

    FUNCTION Get_Root_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (l.Url_Root)
          INTO l_Result
          FROM Uxp_Req_Links l
         WHERE l.Url_Ur = p_Ur_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Child_Request (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (l.Url_Ur)
          INTO l_Result
          FROM Uxp_Req_Links l
         WHERE l.Url_Parent = p_Ur_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Request_Ext_Id (p_Ur_Id IN Uxp_Request.Ur_Id%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT Ur_Ext_Id
          INTO l_Result
          FROM Uxp_Request
         WHERE Ur_Id = p_Ur_Id;

        RETURN l_Result;
    END;

    PROCEDURE Clear_Lob_Data
    IS
    BEGIN
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        UPDATE Uxp_Request r
           SET r.Ur_Body = NULL,
               r.Ur_Soap_Req = NULL,
               r.Ur_Soap_Resp = NULL,
               r.Ur_St = 'ARCH'
         WHERE     r.Ur_Create_Dt < SYSDATE - INTERVAL '1' MONTH
               AND r.Ur_St <> 'ARCH';
    END;

    FUNCTION Is_Same_Request_In_Queue (p_Ur_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Request_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Request_Exists
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON r.Ur_Urt = t.Urt_Id
               JOIN Ikis_Rbm.Uxp_Req_Queue q ON t.Urt_Code = q.Urq_Urt_Code
               JOIN Ikis_Rbm.Uxp_Request Rr
                   ON     q.Urq_Id = Rr.Ur_Id
                      AND r.Ur_Urt = Rr.Ur_Urt
                      AND r.Ur_Ext_Id = Rr.Ur_Ext_Id
                      AND r.Ur_Id <> Rr.Ur_Id
                      AND r.Ur_Create_Dt > Rr.Ur_Create_Dt
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Request_Exists = 1;
    END;

    PROCEDURE Repeat_Out_Request (p_Ur_Id IN NUMBER)
    IS
    BEGIN
        INSERT INTO Ikis_Rbm.Uxp_Req_Queue (Urq_Id, Urq_Urt_Code)
            SELECT r.Ur_Id, t.Urt_Code
              FROM Ikis_Rbm.Uxp_Request  r
                   JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON r.Ur_Urt = t.Urt_Id
             WHERE r.Ur_Id = p_Ur_Id;

        UPDATE Ikis_Rbm.Uxp_Request r
           SET r.Ur_St = 'NEW', r.Ur_Attempts = NVL (r.Ur_Attempts, 0) + 1
         WHERE r.Ur_Id = p_Ur_Id;
    END;

    FUNCTION Parse_Common_Soap_Request (p_Request IN CLOB)
        RETURN CLOB
    IS
        l_Req_Body   CLOB;
    BEGIN
             SELECT Ikis_Rbm.Tools.B64_Decode (Req_Body, 'UTF8')
               INTO l_Req_Body
               FROM XMLTABLE (
                        Xmlnamespaces (
                            'http://schemas.xmlsoap.org/soap/envelope/' AS "s",
                            'http://tempuri.org/' AS "tem"),
                        '/*'
                        PASSING Xmltype (p_Request)
                        COLUMNS Req_Body    CLOB PATH 's:Body/tem:CommonRequest/tem:Body');

        RETURN l_Req_Body;
    END;

    PROCEDURE Save_Request_Error (
        p_Ure_Ur        IN Uxp_Request_Error.Ure_Ur%TYPE,
        p_Ure_Row_Id    IN Uxp_Request_Error.Ure_Row_Id%TYPE,
        p_Ure_Row_Num   IN Uxp_Request_Error.Ure_Row_Num%TYPE,
        p_Ure_Error     IN Uxp_Request_Error.Ure_Error%TYPE)
    IS
    BEGIN
        INSERT INTO Uxp_Request_Error (Ure_Id,
                                       Ure_Ur,
                                       Ure_Row_Id,
                                       Ure_Row_Num,
                                       Ure_Error,
                                       Ure_Dt,
                                       Ure_Fix_Dt,
                                       Ure_Comment)
             VALUES (0,
                     p_Ure_Ur,
                     p_Ure_Row_Id,
                     p_Ure_Row_Num,
                     p_Ure_Error,
                     SYSDATE,
                     NULL,
                     NULL);
    END;

    FUNCTION Get_Ur_Nrt (p_Ur_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Nrt_Id   NUMBER;
    BEGIN
        SELECT t.Urt_Nrt
          INTO l_Nrt_Id
          FROM Uxp_Request  r
               JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON r.Ur_Urt = t.Urt_Id
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Nrt_Id;
    END;

    FUNCTION Get_Ur_Src (p_Ur_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Rn_Src   Request_Journal.Rn_Src%TYPE;
    BEGIN
        SELECT r.Rn_Src
          INTO l_Rn_Src
          FROM Uxp_Request u JOIN Request_Journal r ON u.Ur_Rn = r.Rn_Id
         WHERE u.Ur_Id = p_Ur_Id;

        RETURN l_Rn_Src;
    END;
END Api$uxp_Request;
/