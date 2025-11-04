/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_MSP
IS
    -- Author  : SHOSTAK
    -- Created : 08.12.2022 1:38:05 PM
    -- Purpose :

    TYPE r_Doc_Attr IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (1000),
        Val_Dt     DATE,
        Val_Int    NUMBER,
        Val_Id     NUMBER
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attr;

    FUNCTION Reg_Vpo_Info_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Verify_Vpo_By_Sc (p_Apd_Id IN NUMBER, p_Vf_Id IN NUMBER);

    PROCEDURE Handle_Vpo_Info_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Adopt_Req (p_Rn_Nrt   IN     NUMBER,
                            p_Obj_Id   IN     NUMBER,
                            p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Adopt_Resp (p_Ur_Id      IN     NUMBER,
                                 p_Response   IN     CLOB,
                                 p_Error      IN OUT VARCHAR2);

    PROCEDURE Repeat_Vpo_Vf_After_Delta;
END Api$verification_Msp;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MSP TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MSP TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:52 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_MSP
IS
    FUNCTION Get_App_Doc_Num (p_App_Id IN NUMBER, p_Ndt_Id IN OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_App_Doc_Num   VARCHAR2 (10);
    BEGIN
          SELECT a.Apda_Val_String, d.Apd_Ndt
            INTO l_App_Doc_Num, p_Ndt_Id
            FROM Ap_Document d
                 JOIN Ap_Document_Attr a
                     ON d.Apd_Id = a.Apda_Apd AND a.History_Status = 'A'
                 JOIN Uss_Ndi.v_Ndi_Document_Attr n
                     ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
           WHERE     Apd_App = p_App_Id
                 AND (   Apd_Ndt = p_Ndt_Id
                      OR (p_Ndt_Id IS NULL AND Apd_Ndt IN (6, 7, 37)))
                 AND d.History_Status = 'A'
        ORDER BY CASE Apd_Ndt WHEN 7 THEN 1 WHEN 6 THEN 2 WHEN 37 THEN 3 END
           FETCH FIRST ROW ONLY;

        RETURN l_App_Doc_Num;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    PROCEDURE Add_Attr (p_Doc_Attrs   IN OUT t_Doc_Attrs,
                        p_Nda_Id      IN     NUMBER,
                        p_Val_Str     IN     VARCHAR2 DEFAULT NULL,
                        p_Val_Dt      IN     DATE DEFAULT NULL,
                        p_Val_Int     IN     NUMBER DEFAULT NULL,
                        p_Val_Id      IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
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

    PROCEDURE Save_Attrs (p_Apd_Id      IN NUMBER,
                          p_Apd_Ap      IN NUMBER,
                          p_Doc_Attrs   IN t_Doc_Attrs)
    IS
    BEGIN
        FOR Rec
            IN (SELECT a.Apda_Id
                  FROM Ap_Document_Attr a
                 WHERE     a.Apda_Apd = p_Apd_Id
                       AND a.History_Status = 'A'
                       AND a.Apda_Nda NOT IN
                               (SELECT Nda_Id FROM TABLE (p_Doc_Attrs)))
        LOOP
            Api$appeal.Delete_Document_Attr (Rec.Apda_Id);
        END LOOP;

        FOR Rec
            IN (SELECT a.Apda_Id,
                       n.*,
                       CASE
                           WHEN     a.Apda_Id IS NOT NULL
                                AND (   NVL (n.Val_Int, -99999999) <>
                                        NVL (a.Apda_Val_Int, -99999999)
                                     OR NVL (
                                            n.Val_Dt,
                                            TO_DATE ('01.01.1800',
                                                     'dd.mm.yyyy')) <>
                                        NVL (
                                            a.Apda_Val_Dt,
                                            TO_DATE ('01.01.1800',
                                                     'dd.mm.yyyy'))
                                     OR NVL (n.Val_Str, '#') <>
                                        NVL (a.Apda_Val_String, '#')
                                     OR NVL (n.Val_Id, -99999999) <>
                                        NVL (a.Apda_Val_Id, -99999999))
                           THEN
                               1
                           ELSE
                               0
                       END    AS Is_Modified
                  FROM TABLE (p_Doc_Attrs)  n
                       LEFT JOIN Ap_Document_Attr a
                           ON     a.Apda_Apd = p_Apd_Id
                              AND a.Apda_Nda = n.Nda_Id
                              AND a.History_Status = 'A')
        LOOP
            IF Rec.Apda_Id IS NOT NULL
            THEN
                IF Rec.Is_Modified = 1
                THEN
                    Api$appeal.Delete_Document_Attr (Rec.Apda_Id);
                ELSE
                    CONTINUE;
                END IF;
            END IF;

            Api$appeal.Save_Document_Attr (p_Apda_Id           => NULL,
                                           p_Apda_Ap           => p_Apd_Ap,
                                           p_Apda_Apd          => p_Apd_Id,
                                           p_Apda_Nda          => Rec.Nda_Id,
                                           p_Apda_Val_Int      => Rec.Val_Int,
                                           p_Apda_Val_Dt       => Rec.Val_Dt,
                                           p_Apda_Val_String   => Rec.Val_Str,
                                           p_Apda_Val_Id       => Rec.Val_Id,
                                           p_Apda_Val_Sum      => NULL,
                                           p_New_Id            => Rec.Apda_Id);
        END LOOP;
    END;

    FUNCTION Is_Vpo_Pkg (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Aps_Exists (p_Ap_Id, 664) AND Aps_Exists (p_Ap_Id, 781);
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту для отримання довідки ВПО
    -----------------------------------------------------------------
    FUNCTION Reg_Vpo_Info_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ap_Id         NUMBER;
        l_App_Id        NUMBER;
        l_App_Tp        VARCHAR2 (10);
        l_App_Inn       VARCHAR2 (10);
        l_App_Ndt       NUMBER;
        l_App_Doc_Num   VARCHAR2 (50);
        l_Req_Param     VARCHAR2 (100);
        l_Sc_Id         NUMBER;
        l_Rn_Id         NUMBER;
    BEGIN
        Raise_Application_Error (
            -20001,
            'Починаючи з 17.01.2023 верифікація довідок ВПО відбувається виключно шляхом пошуку у реєстрі СРКО');

        SELECT d.Apd_Ap,
               d.Apd_App,
               NULLIF (p.App_Inn, '0000000000'),
               p.App_Ndt,
               p.App_Doc_Num,
               p.App_Sc,
               p.App_Tp
          INTO l_Ap_Id,
               l_App_Id,
               l_App_Inn,
               l_App_Ndt,
               l_App_Doc_Num,
               l_Sc_Id,
               l_App_Tp
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = p_Obj_Id;

        --Відправляємо запит тільки по заявнику
        --(повязані довідки інших учасників повинні бути у відповіді на цей запит)
        IF l_App_Tp NOT IN ('Z', 'O')
        THEN
            RETURN NULL;
        END IF;

        IF l_App_Inn IS NULL
        THEN
            l_App_Inn := Api$appeal.Get_Person_Inn_Doc (p_App_Id => l_App_Id);
        END IF;

        IF l_App_Inn IS NULL
        THEN
            --Отримуємо документ учасника
            IF l_App_Ndt IS NULL OR l_App_Doc_Num IS NULL
            THEN
                l_App_Ndt := NULL;
                l_App_Doc_Num := Get_App_Doc_Num (l_App_Id, l_App_Ndt);
            END IF;
        END IF;

        l_Req_Param :=
            COALESCE (l_App_Inn,
                      CASE WHEN l_App_Ndt IN (6, 7) THEN l_App_Doc_Num END);

        IF l_Req_Param IS NULL
        THEN
            p_Error :=
                'Для пошуку в реєстрі ВПО потрібні РНОКПП або паспорт громадянина або ІД картка';

            FOR Rec
                IN (SELECT d.Apd_Vf
                      FROM Uss_Visit.Ap_Document d
                     WHERE     d.Apd_Ap = l_Ap_Id
                           AND d.Apd_Ndt = 10052
                           AND d.History_Status = 'A'
                           AND d.Apd_Id <> p_Obj_Id)
            LOOP
                IF Rec.Apd_Vf IS NOT NULL
                THEN
                    Api$verification.Set_Not_Verified (Rec.Apd_Vf,
                                                       CHR (38) || '112');
                END IF;
            END LOOP;

            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Msp.Reg_Vpo_Info_Req (
            p_Rnokpp      => l_Req_Param,
            p_Sc_Id       => l_Sc_Id,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id,
            p_Plan_Dt     =>
                CASE
                    WHEN Is_Vpo_Pkg (l_Ap_Id)
                    THEN
                          SYSDATE
                        + NUMTODSINTERVAL (
                              Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL'),
                              'hour')
                    ELSE
                        SYSDATE
                END);

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Vpo_Info_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --  Збереження основних атрибутів довідки ВПО
    -----------------------------------------------------------------
    PROCEDURE Save_Vpo_Attrs (
        p_Apd_Id          IN NUMBER,
        p_Ap_Id           IN NUMBER,
        p_Vpo_Tp          IN VARCHAR2,
        p_Vpo_Cnt         IN NUMBER,
        p_Vpo_Cert        IN Ikis_Rbm.Api$request_Msp.r_Vpo_Cert,
        p_Vpo_Cert_Main   IN Ikis_Rbm.Api$request_Msp.r_Vpo_Cert DEFAULT NULL)
    IS
        c_Nda_Vpo_Num         CONSTANT NUMBER := 1756;
        c_Nda_Vpo_Gv_Dt       CONSTANT NUMBER := 1757;
        c_Nda_Vpo_Org_Name    CONSTANT NUMBER := 1759;
        c_Nda_Vpo_Tp          CONSTANT NUMBER := 1761;
        c_Nda_Vpo_Cnt         CONSTANT NUMBER := 1762;
        c_Nda_Vpo_Doc_St      CONSTANT NUMBER := 1855;
        --Інформація про заявника
        c_Nda_Vpo_Rnokpp      CONSTANT NUMBER := 1763;
        c_Nda_Vpo_Ln          CONSTANT NUMBER := 1764;
        c_Nda_Vpo_Fn          CONSTANT NUMBER := 1765;
        c_Nda_Vpo_Mn          CONSTANT NUMBER := 1766;
        c_Nda_Vpo_Birthday    CONSTANT NUMBER := 1767;

        c_Nda_Vpo_Guid        CONSTANT NUMBER := 2440;

        --Адреси
        c_Nda_Vpo_Addr_Fact   CONSTANT NUMBER := 2457;
        c_Nda_Vpo_Addr_Reg    CONSTANT NUMBER := 2458;

        c_Nda_Vpo_Kaot        CONSTANT NUMBER := 2292;

        l_Kaot_Id                      NUMBER;
        l_Kaot_Name                    Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;

        l_Doc_Attrs                    t_Doc_Attrs;
    BEGIN
        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Num,
                  p_Val_Str   => p_Vpo_Cert.Certificate_Number);
        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Gv_Dt,
                  p_Val_Dt   => p_Vpo_Cert.Certificate_Date);
        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Org_Name,
                  p_Val_Str   => p_Vpo_Cert.Certificate_Issuer);
        Add_Attr (l_Doc_Attrs, c_Nda_Vpo_Tp, p_Val_Str => p_Vpo_Tp);
        Add_Attr (l_Doc_Attrs, c_Nda_Vpo_Cnt, p_Val_Int => p_Vpo_Cnt);
        Add_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_Doc_St,
            p_Val_Str   =>
                CASE REPLACE (UPPER (p_Vpo_Cert.Certificate_State), ' ')
                    WHEN 'ДІЮЧА' THEN 'A'
                    WHEN 'ЗНЯТАЗОБЛІКУ' THEN 'H'
                END);

        SELECT MAX (k.Kaot_Id), MAX (k.Kaot_Name)
          INTO l_Kaot_Id, l_Kaot_Name
          FROM Uss_Ndi.v_Ndi_Katottg k
         WHERE k.Kaot_Code = p_Vpo_Cert.Catottg;

        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Kaot,
                  p_Val_Id    => l_Kaot_Id,
                  p_Val_Str   => l_Kaot_Name);

        IF p_Vpo_Cert_Main.Certificate_Number IS NOT NULL
        THEN
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Rnokpp,
                      p_Val_Str   => p_Vpo_Cert_Main.Rnokpp);
            Add_Attr (
                l_Doc_Attrs,
                c_Nda_Vpo_Ln,
                p_Val_Str   => TRIM (UPPER (p_Vpo_Cert_Main.Idp_Surname)));
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Fn,
                      p_Val_Str   => TRIM (UPPER (p_Vpo_Cert_Main.Idp_Name)));
            Add_Attr (
                l_Doc_Attrs,
                c_Nda_Vpo_Mn,
                p_Val_Str   => TRIM (UPPER (p_Vpo_Cert_Main.Idp_Patronymic)));
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Birthday,
                      p_Val_Dt   => p_Vpo_Cert_Main.Birth_Date);
        END IF;

        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Guid,
                  p_Val_Str   => NVL (p_Vpo_Cert.Guid, p_Vpo_Cert.UID));

        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Addr_Fact,
                  p_Val_Str   => p_Vpo_Cert.Fact_Address);
        Add_Attr (l_Doc_Attrs,
                  c_Nda_Vpo_Addr_Reg,
                  p_Val_Str   => p_Vpo_Cert.Reg_Address);

        Save_Attrs (p_Apd_Id, p_Ap_Id, l_Doc_Attrs);
    END;

    -----------------------------------------------------------------
    --     Спроба верифікувати довідку ВПО за даними соцкартки
    -----------------------------------------------------------------
    FUNCTION Verify_Vpo_By_Sc (p_App_Id   IN NUMBER,
                               p_App_Sc   IN NUMBER,
                               p_Apd_Id   IN NUMBER,
                               p_Ap_Id    IN NUMBER)
        RETURN BOOLEAN
    IS
        l_App_Sc      NUMBER := p_App_Sc;
        l_Doc_Attrs   t_Doc_Attrs;
        l_Is_Actual   NUMBER;
        l_Dh_Id       NUMBER;
    BEGIN
        IF l_App_Sc IS NULL
        THEN
            BEGIN
                --Шукаємо соцкартку учасника
                Api$ap2sc.Search_App_Sc (p_App_Id   => p_App_Id,
                                         p_App_Sc   => l_App_Sc);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END IF;

        IF NVL (l_App_Sc, 0) < 1
        THEN
            RETURN FALSE;
        END IF;

        --Шукаємо довідку ВПО у соцкартці учасника
        SELECT MAX (d.Scd_Dh)
          INTO l_Dh_Id
          FROM Uss_Person.v_Sc_Document d
         WHERE d.Scd_Sc = l_App_Sc AND d.Scd_Ndt = 10052 AND d.Scd_St = '1';

        IF l_Dh_Id IS NULL
        THEN
            RETURN FALSE;
        END IF;

        --вичитуємо атрибути за наявності
        SELECT a.Da_Nda,
               a.Da_Val_String,
               a.Da_Val_Dt,
               a.Da_Val_Int,
               a.Da_Val_Id
          BULK COLLECT INTO l_Doc_Attrs
          FROM Uss_Doc.v_Doc_Attr2hist  h
               JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
         WHERE h.Da2h_Dh = l_Dh_Id;

        --Перевіряємо актуальність довідки
        SELECT SIGN (COUNT (*))
          INTO l_Is_Actual
          FROM TABLE (l_Doc_Attrs)
         WHERE Nda_Id = 1855 AND Val_Str = 'A';

        IF l_Is_Actual = 1
        THEN
            --Зберігаємо атрибути довідки в документ в звернені
            Save_Attrs (p_Apd_Id      => p_Apd_Id,
                        p_Apd_Ap      => p_Ap_Id,
                        p_Doc_Attrs   => l_Doc_Attrs);
            --Успішна верифікація
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    -----------------------------------------------------------------
    --     Спроба верифікувати довідку ВПО за даними соцкартки
    -----------------------------------------------------------------
    PROCEDURE Verify_Vpo_By_Sc (p_Apd_Id IN NUMBER, p_Vf_Id IN NUMBER)
    IS
        l_Ap_Id             NUMBER;
        l_App_Id            NUMBER;
        l_App_Sc            NUMBER;
        l_Apd_Vf            NUMBER;
        l_Hours_Since_Reg   NUMBER;
        l_Delay             NUMBER;
    BEGIN
        SELECT d.Apd_Ap,
               d.Apd_App,
               d.Apd_Vf,
               p.App_Sc
          INTO l_Ap_Id,
               l_App_Id,
               l_Apd_Vf,
               l_App_Sc
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = p_Apd_Id;

        IF l_Apd_Vf <> p_Vf_Id
        THEN
            --Якщо документ посилається на іншу верифікацію - призупиняємо поточну
            --(таке можливо, якщо звернення перевели на повторну верифікацію до завершення верифікації)
            Api$verification.Suspend_Auto_Vf (p_Vf_Id => p_Vf_Id);
            RETURN;
        END IF;

        IF Verify_Vpo_By_Sc (p_App_Id   => l_App_Id,
                             p_App_Sc   => l_App_Sc,
                             p_Apd_Id   => p_Apd_Id,
                             p_Ap_Id    => l_Ap_Id)
        THEN
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Ok (p_Vf_Id);
        ELSE
            IF Is_Vpo_Pkg (l_Ap_Id)
            THEN
                --Отримуємо кількість годин, що минули з моменту запуску верифікації
                SELECT (SYSDATE - v.Vf_Start_Dt) * 24
                  INTO l_Hours_Since_Reg
                  FROM Verification v
                 WHERE v.Vf_Id = p_Vf_Id;

                IF l_Hours_Since_Reg <
                   TO_NUMBER (
                       Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL_MAX'))
                THEN
                    l_Delay :=
                        Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL') * 60 * 60;
                    Api$verification.Delay_Auto_Vf (
                        p_Vf_Id           => p_Vf_Id,
                        p_Delay_Seconds   => l_Delay,
                        p_Delay_Reason    => CHR (38) || '138#' || l_Delay);
                    RETURN;
                END IF;
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, CHR (38) || '137');
        END IF;
    END;

    -----------------------------------------------------------------
    --      Обробка відповіді на запит для отримання довідки ВПО
    -----------------------------------------------------------------
    PROCEDURE Handle_Vpo_Info_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id          NUMBER;
        l_Apd_Id         NUMBER;
        l_Vf_Id          NUMBER;
        l_Vf_Nvt         NUMBER;
        l_Nrt_Id         NUMBER;
        l_Vpo_Info       Ikis_Rbm.Api$request_Msp.r_Vpo_Info_Resp;
        l_App_Id         NUMBER;
        l_Ap_Vf          NUMBER;
        l_Ap_Id          NUMBER;
        l_Vf_Cnt_Total   NUMBER;
        l_Vf_Cnt_Ended   NUMBER;
    BEGIN
        /*Raise_Application_Error(-20001,
        'Починаючи з 17.01.2023 верифікація довідок ВПО відбувається виключно шляхом пошуку у реєстрі СРКО');*/

        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        --Заглушка(з 17.01.2023 верифікація довідок ВПО відбувається виключно шляхом пошуку у реєстрі СРКО)
        UPDATE Verification
           SET Vf_Tp = 'AUTO', Vf_Plan_Dt = SYSDATE
         WHERE Vf_Id = l_Vf_Id;

        RETURN;

        --Парсимо відповідь
        l_Vpo_Info :=
            Ikis_Rbm.Api$request_Msp.Parse_Vpo_Info_Resp (p_Response);

        IF l_Vpo_Info.Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => l_Vpo_Info.Error);
        END IF;

        --Отримуємо ІД учасника
        SELECT v.Vf_Obj_Id,                                       --ІД довідки
               v.Vf_Nvt,                         --Тип верифікації довідки ВПО
               t.Nvt_Nrt,
               Vv.Vf_Obj_Id,    --ІД учасника, по якому було відправлено запит
               Vv.Vf_Vf_Main,                       --ІД верифікації звернення
               Vvv.Vf_Obj_Id
          INTO l_Apd_Id,
               l_Vf_Nvt,
               l_Nrt_Id,
               l_App_Id,
               l_Ap_Vf,
               l_Ap_Id
          FROM Verification  v                           --Верифікація довідки
               JOIN Uss_Ndi.Ndi_Verification_Type t ON v.Vf_Nvt = t.Nvt_Id
               JOIN Verification Vv            --Групуюча верифікація учасника
                                    ON v.Vf_Vf_Main = Vv.Vf_Id
               JOIN Verification Vvv                   --Верифікація звернення
                                     ON Vv.Vf_Vf_Main = Vvv.Vf_Id
         WHERE v.Vf_Id = l_Vf_Id;

        --Блокуємо верифікацію звернення
        SELECT v.Vf_Id
          INTO l_Ap_Vf
          FROM Verification v
         WHERE v.Vf_Id = l_Ap_Vf
        FOR UPDATE;

        -----ВЕРИФІКАЦІЯ ДОВІДКИ УЧАСНИКА, ПО ЯКОМУ БУЛО ВІДПРАВЛЕНО ЗАПИТ-------
        IF l_Vpo_Info.Person.Certificate_Number IS NOT NULL
        THEN
            --Зберігаємо атрибути довідки ВПО
            Save_Vpo_Attrs (l_Apd_Id,
                            l_Ap_Id,
                            'Z',
                            NULLIF (l_Vpo_Info.Accompanied.COUNT, 0),
                            l_Vpo_Info.Person);
            --Успішна верифікація
            Api$verification.Set_Ok (l_Vf_Id);
        END IF;

        -----ВЕРИФІКАЦІЯ ДОВІДОК ПОВЯЗЯНИХ УЧАСНИКІВ------------------------------
        FOR Rec
            IN (SELECT v.Vf_Obj_Id                          AS App_Id,
                       p.App_Tp,
                       Vv.Vf_Obj_Id                         AS Apd_Id,
                       Vv.Vf_Id,
                       NULLIF (p.App_Inn, '0000000000')     AS App_Inn,
                       p.App_Ndt,
                       p.App_Doc_Num,
                       p.App_Sc
                  FROM Verification  v       --Верифікації учасників звернення
                       JOIN Verification Vv --Верифікації документів учасників
                           ON     v.Vf_Id = Vv.Vf_Vf_Main
                              AND Vv.Vf_Nvt = l_Vf_Nvt
                              AND Vv.Vf_St = 'R'
                       JOIN Ap_Person p
                           ON v.Vf_Obj_Id = p.App_Id AND p.App_Id <> l_App_Id
                 WHERE v.Vf_Vf_Main = l_Ap_Vf AND v.Vf_Obj_Tp = 'P')
        LOOP
            DECLARE
                l_Vpo_Cert      Ikis_Rbm.Api$request_Msp.r_Vpo_Cert;
                l_App_Inn       VARCHAR2 (10);
                l_App_Ndt       NUMBER;
                l_App_Doc_Num   VARCHAR2 (50);
                l_Req_Param     VARCHAR2 (100);
                l_Rn_Id         NUMBER;
            BEGIN
                --Отримуємо ІПН учасника
                IF Rec.App_Inn IS NOT NULL
                THEN
                    l_App_Inn := Rec.App_Inn;
                ELSE
                    l_App_Inn :=
                        Api$appeal.Get_Person_Inn_Doc (p_App_Id => Rec.App_Id);
                END IF;

                --Отримуємо документ учасника
                IF Rec.App_Ndt IS NOT NULL AND Rec.App_Doc_Num IS NOT NULL
                THEN
                    l_App_Ndt := Rec.App_Ndt;
                    l_App_Doc_Num := Rec.App_Doc_Num;
                ELSE
                    l_App_Doc_Num := Get_App_Doc_Num (Rec.App_Id, l_App_Ndt);
                END IF;

                IF     l_Vpo_Info.Accompanied IS NOT NULL
                   AND l_Vpo_Info.Accompanied.COUNT > 0
                THEN
                    --Шукаємо довідку ВПО для учасника звернення
                    BEGIN
                        SELECT *
                          INTO l_Vpo_Cert
                          FROM TABLE (l_Vpo_Info.Accompanied) a
                         WHERE    a.Rnokpp = l_App_Inn
                               OR (    a.Document_Type = Uss_Ndi.Tools.Decode_Dict (
                                                             'VPO_DOC_TP',
                                                             'USS',
                                                             'VPO',
                                                             l_App_Ndt)
                                   AND REPLACE (
                                           UPPER (
                                                  a.Document_Serie
                                               || a.Document_Number),
                                           ' ') =
                                       l_App_Doc_Num)
                         FETCH FIRST ROW ONLY;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            NULL;
                    END;
                END IF;

                --Якщо довідку учасника знайдено серед повязаних
                IF l_Vpo_Cert.Certificate_Number IS NOT NULL
                THEN
                    --Зберігаємо основні атрибути довідки ВПО
                    Save_Vpo_Attrs (Rec.Apd_Id,
                                    l_Ap_Id,
                                    'FM',
                                    l_Vpo_Info.Accompanied.COUNT,
                                    l_Vpo_Cert,
                                    l_Vpo_Info.Person);
                    --Успішна верифікація
                    Api$verification.Set_Ok (Rec.Vf_Id);
                ELSE
                    --Перевіряємо чи є вже створений запит по учаснику
                    SELECT MAX (a.Vfa_Rn)
                      INTO l_Rn_Id
                      FROM Vf_Answer a
                     WHERE a.Vfa_Vf = Rec.Vf_Id;

                    IF l_Rn_Id IS NOT NULL
                    THEN
                        CONTINUE;
                    END IF;

                    l_Req_Param :=
                        COALESCE (
                            l_App_Inn,
                            CASE
                                WHEN l_App_Ndt IN (6, 7) THEN l_App_Doc_Num
                            END);

                    IF l_Req_Param IS NOT NULL
                    THEN
                        --Cтворюємо запит по учаснику
                        Ikis_Rbm.Api$request_Msp.Reg_Vpo_Info_Req (
                            p_Rnokpp      => l_Req_Param,
                            p_Sc_Id       => Rec.App_Sc,
                            p_Rn_Nrt      => l_Nrt_Id,
                            p_Rn_Hs_Ins   => NULL,
                            p_Rn_Src      => Api$appeal.c_Src_Vst,
                            p_Rn_Id       => l_Rn_Id);
                        Api$verification.Link_Request2verification (
                            p_Vfa_Vf   => Rec.Vf_Id,
                            p_Vfa_Rn   => l_Rn_Id);
                    END IF;
                END IF;
            END;
        END LOOP;

        --Якщо у відповідь на запит до реєстру ВПО не повернулась довідка
        --(тільки для пакетних заяв)
        IF     l_Vpo_Info.Person.Certificate_Number IS NULL
           AND Is_Vpo_Pkg (l_Ap_Id)
        THEN
            DECLARE
                l_Time_Since_Reg   NUMBER;
            BEGIN
                --Отримуємо кількість годин, що минули з моменту реєстрації запиту
                SELECT (SYSDATE - v.Vf_Start_Dt) * 24
                  INTO l_Time_Since_Reg
                  FROM Verification v
                 WHERE v.Vf_Id = l_Vf_Id;

                IF l_Time_Since_Reg <
                   TO_NUMBER (
                       Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL_MAX'))
                THEN
                    COMMIT;
                    Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                        p_Ur_Id   => p_Ur_Id,
                        p_Delay_Seconds   =>
                            Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL') * 60,
                        p_Delay_Reason   =>
                            'Довідки ще немає у вітрині реєстру ВПО');
                END IF;
            END;
        END IF;

        SELECT COUNT (*)                                                      AS Vf_Cnt_Total,
               NVL (SUM (CASE WHEN j.Rn_St <> 'NEW' THEN 1 ELSE 0 END), 0)    AS Vf_Cnt_Ended
          INTO l_Vf_Cnt_Total, --Загальна кількість верифікацій довідок ВПО у звернені
                               l_Vf_Cnt_Ended --Кількість верифікацій довідок ВПО у звернені, що завершились
          FROM Verification  v               --Верифікації учасників звернення
               JOIN Verification Vv         --Верифікації документів учасників
                   ON v.Vf_Id = Vv.Vf_Vf_Main AND Vv.Vf_Nvt = l_Vf_Nvt --Верифікація довідки ВПО
               JOIN Vf_Answer a ON Vv.Vf_Id = a.Vfa_Vf
               JOIN Ikis_Rbm.v_Request_Journal j ON a.Vfa_Rn = j.Rn_Id
         WHERE v.Vf_Vf_Main = l_Ap_Vf AND v.Vf_Obj_Id <> l_App_Id;

        --Якщо не завершено всі верифікаційні запити по довідкам ВПО у цьому зверненю
        IF l_Vf_Cnt_Total <> l_Vf_Cnt_Ended
        THEN
            RETURN;
        END IF;

        --Знаходимо верифікації довідок ВПО, які залишились у статусі "Зареєстровано"
        FOR Rec
            IN (SELECT Vv.Vf_Id,
                       p.App_Id,
                       p.App_Sc,
                       Vv.Vf_Obj_Id     AS Apd_Id
                  FROM Verification  v       --Верифікації учасників звернення
                       JOIN Verification Vv --Верифікації документів учасників
                           ON     v.Vf_Id = Vv.Vf_Vf_Main
                              AND Vv.Vf_Nvt = l_Vf_Nvt --Верифікація довідки ВПО
                              AND Vv.Vf_St = 'R'
                       JOIN Ap_Person p ON v.Vf_Obj_Id = p.App_Id
                 WHERE v.Vf_Vf_Main = l_Ap_Vf)
        LOOP
            --Спроба верифікувати довідку ВПО за даними в соцкартці
            IF Verify_Vpo_By_Sc (p_App_Id   => Rec.App_Id,
                                 p_App_Sc   => Rec.App_Sc,
                                 p_Apd_Id   => Rec.Apd_Id,
                                 p_Ap_Id    => l_Ap_Id)
            THEN
                Api$verification.Set_Ok (Rec.Vf_Id);
                CONTINUE;
            END IF;

            --Верифікація може бути неуспішною, томущо
            --Довідку учасника не було знайдено в реєстрі ВПО
            --ані серед довідок заявників ані серед повязаних довідок
            --ані в соцкартці учасника
            Api$verification.Set_Not_Verified (Rec.Vf_Id, CHR (38) || '113');
        END LOOP;
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на усиновлення
    -----------------------------------------------------------------
    FUNCTION Reg_Adopt_Req (p_Rn_Nrt   IN     NUMBER,
                            p_Obj_Id   IN     NUMBER,
                            p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ap_Id      NUMBER;
        l_Ssd_Code   VARCHAR2 (10);
        l_Rn_Id      NUMBER;
    BEGIN
        p_Error := NULL;

          SELECT App_Ap,
                 Uss_Doc.Api$documents.Get_Attr_Val_Str (
                     p_Nda_Class   => 'ORG',
                     p_Dh_Id       => h.Dh_Id)
            INTO l_Ap_Id, l_Ssd_Code
            FROM Ap_Person
                 JOIN Appeal a ON App_Ap = a.Ap_Id
                 JOIN Uss_Doc.v_Doc_Hist h ON a.Ap_Doc = h.Dh_Doc
           WHERE App_Id = p_Obj_Id
        ORDER BY h.Dh_Dt DESC
           FETCH FIRST ROW ONLY;

        Ikis_Rbm.Api$request_Msp.Reg_Save_Adopt_Req (
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id,
            p_Ap_Id       => l_Ap_Id,
            p_Ssd_Code    => l_Ssd_Code);

        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запи на усиновлення
    -----------------------------------------------------------------
    PROCEDURE Handle_Adopt_Resp (p_Ur_Id      IN     NUMBER,
                                 p_Response   IN     CLOB,
                                 p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id   NUMBER;
        l_Vf_Id   NUMBER;
        l_Resp    Ikis_Rbm.Api$request_Msp.r_Adopt_Resp;
        l_Ap_Id   NUMBER;
    --l_Ap_St VARCHAR2(10);
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        IF p_Error IS NOT NULL
        THEN
            Api$verification.Write_Vf_Log (
                l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   => p_Error);
            RETURN;
        END IF;

        l_Resp := Ikis_Rbm.Api$request_Msp.Parse_Adopt_Resp (p_Response);

        IF l_Resp.Result_Code = Ikis_Rbm.Api$request_Msp.c_Adopt_Resp_Code_Ok
        THEN
            l_Ap_Id := Api$verification.Get_Vf_Ap (l_Vf_Id);
            /* SELECT a.Ap_St
             INTO l_Ap_St
             FROM Appeal a
            WHERE a.Ap_Id = l_Ap_Id;*/
            Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                                  p_Apl_Hs        => Tools.Gethistsession (NULL),
                                  p_Apl_St        => 'N',
                                  p_Apl_Message   => CHR (38) || 22,
                                  p_Apl_St_Old    => 'N',
                                  p_Apl_Tp        => Api$appeal.c_Apl_Tp_Sys);
        ELSIF l_Resp.Result_Code =
              Ikis_Rbm.Api$request_Msp.c_Adopt_Resp_Code_Bad_Req
        THEN
            p_Error :=
                NVL (l_Resp.Result_Tech_Info, 'Некоректні параметри запиту');
            Api$verification.Write_Vf_Log (
                l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   => p_Error);
        ELSE
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => l_Resp.Result_Tech_Info);
        END IF;
    END;

    -----------------------------------------------------------------
    --  Повторна верифікація довідок ВПО після отримання дельти
    -----------------------------------------------------------------
    PROCEDURE Repeat_Vpo_Vf_After_Delta
    IS
        l_Start_Dt   DATE;
    BEGIN
        SELECT MIN (Ur_Handle_Dt)
          INTO l_Start_Dt
          FROM (  SELECT r.Ur_Handle_Dt
                    FROM Ikis_Rbm.v_Uxp_Request r
                   WHERE r.Ur_Urt = 43 AND r.Ur_St = 'OK'
                ORDER BY r.Ur_Handle_Dt DESC
                   FETCH FIRST 2 ROWS ONLY);

        FOR Rec
            IN (SELECT a.Ap_Id,
                       a.Ap_Vf,
                       p.App_Vf,
                       d.Apd_Vf
                  FROM Uss_Person.v_Scd_Event  e
                       JOIN Uss_Person.v_Sc_Document Dd
                           ON     e.Scde_Scd = Dd.Scd_Id
                              AND Dd.Scd_Ndt = 10052
                              AND Dd.Scd_St = '1'
                       JOIN Ap_Person p
                           ON e.Scde_Sc = p.App_Sc AND p.History_Status = 'A'
                       JOIN Ap_Document d
                           ON     p.App_Id = d.Apd_App
                              AND d.Apd_Ndt = 10052
                              AND d.History_Status = 'A'
                       JOIN Verification v
                           ON d.Apd_Vf = v.Vf_Id AND v.Vf_St = 'N'
                       JOIN Appeal a
                           ON p.App_Ap = a.Ap_Id AND a.Ap_St IN ('VW', 'VE')
                 WHERE e.Scde_Dt > l_Start_Dt AND e.Scde_Event = 'CR')
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                RETURN;
            END IF;

            DECLARE
                l_Lock_Handle   Tools.t_Lockhandler;
            BEGIN
                Ikis_Sys.Ikis_Lock.Request_Lock (
                    p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                    p_Var_Name            => 'VF' || Rec.Ap_Vf,
                    p_Errmessage          => NULL,
                    p_Lockhandler         => l_Lock_Handle,
                    p_Timeout             => 3600,
                    p_Release_On_Commit   => TRUE);

                UPDATE Appeal a
                   SET a.Ap_St = 'VW'
                 WHERE a.Ap_Id = Rec.Ap_Id AND a.Ap_St IN ('VE', 'VW');

                IF SQL%ROWCOUNT = 0
                THEN
                    COMMIT;
                    CONTINUE;
                END IF;

                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => Rec.Apd_Vf,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '148');

                UPDATE Verification v
                   SET v.Vf_St = 'R', v.Vf_Own_St = 'R'
                 WHERE v.Vf_Id IN (Rec.Apd_Vf, Rec.App_Vf, Rec.Ap_Vf);

                COMMIT;
            END;
        END LOOP;
    END;
END Api$verification_Msp;
/