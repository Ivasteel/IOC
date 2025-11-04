/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MFU
IS
    -- Author  : SHOSTAK
    -- Created : 20.04.2023 5:07:55 PM
    -- Purpose : запити до мінастерства фінансів

    Pkg             CONSTANT VARCHAR2 (50) := 'API$REQUEST_MFU';

    c_Pt_Param_Id   CONSTANT NUMBER := 346;
    c_Pt_Pay_Id     CONSTANT NUMBER := 345;
    c_Pt_Com_Org    CONSTANT NUMBER := 344;

    TYPE r_Fact_Recomend IS RECORD
    (
        Id_Rec         NUMBER,
        Id_Param       VARCHAR2 (10),
        Recomend       VARCHAR2 (4000),
        Is_Recomend    NUMBER,
        RESULT         VARCHAR2 (4000)
    );

    TYPE t_Facts_Recomend IS TABLE OF r_Fact_Recomend;

    TYPE r_Vf_Response IS RECORD
    (
        Facts_Recomend    t_Facts_Recomend
    );

    TYPE r_Vf_Response_Err IS RECORD
    (
        MESSAGE    VARCHAR2 (4000)
    );

    PROCEDURE Reg_Verification_Req (
        p_Inn            IN     VARCHAR2,
        p_Passport_Ser   IN     VARCHAR2,
        p_Passport_Num   IN     VARCHAR2,
        p_Param_Id       IN     VARCHAR2,
        p_Pay_Id         IN     VARCHAR2,
        p_Wu_Id          IN     NUMBER,
        p_Com_Org        IN     NUMBER,
        p_Sc_Id          IN     NUMBER,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id             OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Verification_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Verification_Resp (p_Response CLOB)
        RETURN r_Vf_Response;

    FUNCTION Parse_Verification_Err_Resp (p_Response CLOB)
        RETURN r_Vf_Response_Err;
END Api$request_Mfu;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MFU TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MFU
IS
    -------------------------------------------------------------------
    --    Реєстрація запиту на превентивну верифікацію
    -------------------------------------------------------------------
    PROCEDURE Reg_Verification_Req (
        p_Inn            IN     VARCHAR2,
        p_Passport_Ser   IN     VARCHAR2,
        p_Passport_Num   IN     VARCHAR2,
        p_Param_Id       IN     VARCHAR2,
        p_Pay_Id         IN     VARCHAR2,
        p_Wu_Id          IN     NUMBER,
        p_Com_Org        IN     NUMBER,
        p_Sc_Id          IN     NUMBER,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id             OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Rnp_Id   NUMBER;
        l_Ur_Id    NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => p_Wu_Id,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        --Зберігаємо інформацію про особу
        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Inn,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => p_Passport_Ser,
                                    p_Rnp_Doc_Number   => p_Passport_Num,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        --Зберігаємо тип перевірки
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Param_Id,
                                         p_Rnc_Val_String   => p_Param_Id);
        --Зберігаємо код виплати
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Pay_Id,
                                         p_Rnc_Val_String   => p_Pay_Id);
        --Зберігаємо ІД органу
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Com_Org,
                                         p_Rnc_Val_Id   => p_Com_Org);
    END;

    FUNCTION Get_Prm_Comment (p_Param IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Param_Rbm.Prm_Comment%TYPE;
    BEGIN
        SELECT p.Prm_Comment
          INTO l_Result
          FROM Param_Rbm p
         WHERE p.Prm_Code = p_Param;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --  Отримання даних для запиту превентивної верифікації
    -------------------------------------------------------------------
    FUNCTION Get_Verification_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_Uxp_Request   Uxp_Request%ROWTYPE;
        l_Req           Json_Obj;
        --l_Attributes  Json_Obj;
        l_Com_Org       NUMBER;
        l_Wu_Pib        VARCHAR2 (300);
        l_Ln            VARCHAR2 (100);
        l_Fn            VARCHAR2 (100);
        l_Mn            VARCHAR2 (100);
        l_Authority     VARCHAR2 (250);
        l_Position      VARCHAR2 (250);
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        --Отримуємо ПІБ користувача від імені якого надсилається запит
        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            SELECT u.Wu_Pib
              INTO l_Wu_Pib
              FROM Ikis_Sysweb.V$all_Users u
             WHERE u.Wu_Id = l_Uxp_Request.Ur_Create_Wu;

            Tools.Split_Pib (l_Wu_Pib,
                             l_Ln,
                             l_Fn,
                             l_Mn);

            l_Com_Org :=
                Api$request.Get_Rn_Common_Info_Id (l_Rn_Id, c_Pt_Com_Org);

            --Отримуємо назву органу
            SELECT o.Org_Name
              INTO l_Authority
              FROM Ikis_Sys.v_Opfu o
             WHERE o.Org_Id = l_Com_Org;

            l_Position := 'Спеціаліст УПСЗН';
        ELSE
            l_Ln := Get_Prm_Comment ('MFU_REQ_LN');
            l_Fn := Get_Prm_Comment ('MFU_REQ_FN');
            l_Mn := Get_Prm_Comment ('MFU_REQ_MN');
            l_Authority := Get_Prm_Comment ('MFU_REQ_DEP');
            l_Position := Get_Prm_Comment ('MFU_REQ_POS');
        END IF;

        --Формуємо JSON об'єкт запиту
        l_Req := NEW Json_Obj ();

        FOR Rec IN (SELECT *
                      FROM Rn_Person p
                     WHERE p.Rnp_Rn = l_Rn_Id)
        LOOP
            l_Req.Push ('inn', Rec.Rnp_Inn);
        /*IF Rec.Rnp_Doc_Number IS NOT NULL THEN
          l_Attributes := NEW Json_Obj();
          l_Attributes.Push('PassportSer', Rec.Rnp_Doc_Seria);
          l_Attributes.Push('PassportNum', Rec.Rnp_Doc_Number);
          l_Req.Push('attributes', l_Attributes);
        END IF;*/
        END LOOP;

        l_Req.Push (
            'paramId',
            Api$request.Get_Rn_Common_Info_String (l_Rn_Id, c_Pt_Param_Id));
        l_Req.Push (
            'payId',
            Api$request.Get_Rn_Common_Info_String (l_Rn_Id, c_Pt_Pay_Id));
        l_Req.Push ('sourceId', 'MSP');
        l_Req.Push ('authorityshortname', l_Authority);
        l_Req.Push ('posada', l_Position);
        l_Req.Push ('lastname', l_Ln);
        l_Req.Push ('firstname', l_Fn);
        l_Req.Push ('middlename', l_Mn);
        RETURN l_Req.TO_CLOB ();
    END;

    -------------------------------------------------------------------
    --  Парсинг відповіді на запит превентивної верифікації
    -------------------------------------------------------------------
    FUNCTION Parse_Verification_Resp (p_Response CLOB)
        RETURN r_Vf_Response
    IS
        l_Response   r_Vf_Response;
    BEGIN
        EXECUTE IMMEDIATE Type2jsontable (Pkg, 'R_VF_RESPONSE')
            USING IN p_Response, OUT l_Response;

        RETURN l_Response;
    END;

    -------------------------------------------------------------------
    --  Парсинг відповіді на запит превентивної верифікації
    --  (у разі помилки)
    -------------------------------------------------------------------
    FUNCTION Parse_Verification_Err_Resp (p_Response CLOB)
        RETURN r_Vf_Response_Err
    IS
        l_Response   r_Vf_Response_Err;
    BEGIN
        EXECUTE IMMEDIATE Type2jsontable (Pkg, 'R_VF_RESPONSE_ERR')
            USING IN p_Response, OUT l_Response;

        RETURN l_Response;
    END;
END Api$request_Mfu;
/