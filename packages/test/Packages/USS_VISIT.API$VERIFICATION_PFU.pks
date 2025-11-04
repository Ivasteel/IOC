/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_PFU
IS
    -- Author  : SHOSTAK
    -- Created : 08.12.2022 2:05:43 PM
    -- Purpose :

    c_Pt_App_Id   CONSTANT NUMBER := 309;

    FUNCTION Reg_Verify_Incomes_Req (p_Rn_Nrt   IN     NUMBER,
                                     p_Obj_Id   IN     NUMBER,
                                     p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Search_Person_Req (p_Rn_Nrt   IN     NUMBER,
                                    p_Obj_Id   IN     NUMBER,
                                    p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2);
END Api$verification_Pfu;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_PFU TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_PFU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:52 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_PFU
IS
    -----------------------------------------------------------------
    --         Реєстрація запиту до ПФУ
    --    для верифікації доходів
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Incomes_Req (p_Rn_Nrt   IN     NUMBER,
                                     p_Obj_Id   IN     NUMBER,
                                     p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id      NUMBER;
        l_Doc_Ser    VARCHAR2 (7);
        l_Doc_Nom    VARCHAR2 (9);
        l_Start_Dt   DATE;
        l_Stop_Dt    DATE;
    BEGIN
        FOR Rec
            IN (SELECT NVL (
                           p.App_Inn,
                           (SELECT MAX (a.Apda_Val_String)
                              FROM Ap_Document  d
                                   JOIN Ap_Document_Attr a
                                       ON     d.Apd_Id = a.Apda_Apd
                                          AND a.History_Status = 'A'
                                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                       ON     a.Apda_Nda = n.Nda_Id
                                          AND n.Nda_Class = 'DSN'
                             WHERE     d.Apd_App = p.App_Id
                                   AND d.Apd_Ndt = 5
                                   AND d.History_Status = 'A'))
                           AS App_Inn,
                       p.App_Ndt,
                       p.App_Doc_Num,
                       p.App_Fn,
                       p.App_Mn,
                       p.App_Ln,
                       p.App_Sc,
                       s.Sc_Unique,
                       b.Scb_Dt,
                       p.App_Ap,
                       p.App_Tp,
                       Ap.Ap_Reg_Dt
                  FROM Ap_Person  p
                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                       LEFT JOIN Uss_Person.v_Socialcard s
                           ON p.App_Sc = s.Sc_Id
                       LEFT JOIN Uss_Person.v_Sc_Birth b
                           ON s.Sc_Id = b.Scb_Sc
                 WHERE p.App_Id = p_Obj_Id)
        LOOP
            IF Rec.App_Ndt = 6
            THEN
                l_Doc_Ser := SUBSTR (Rec.App_Doc_Num, 1, 2);
                l_Doc_Nom := SUBSTR (Rec.App_Doc_Num, 3, 9);
            ELSE
                l_Doc_Nom := SUBSTR (Rec.App_Doc_Num, 1, 9);
            END IF;

            --#99018
            IF     Api$appeal.Service_Exists (p_Aps_Ap    => Rec.App_Ap,
                                              p_Aps_Nst   => 664)
               AND Rec.Ap_Reg_Dt >= TO_DATE ('01.02.2024', 'DD.MM.YYYY')
            THEN
                WITH
                    Prev
                    AS
                        (SELECT TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1), 'Q')    AS Dt
                           FROM DUAL)
                SELECT ADD_MONTHS (Dt, -3), Dt - 1
                  INTO l_Start_Dt, l_Stop_Dt
                  FROM Prev;
            --#72638
            ELSIF     Rec.App_Tp = 'FP'
                  AND Api$appeal.Service_Exists (p_Aps_Ap    => Rec.App_Ap,
                                                 p_Aps_Nst   => 268)
                  AND Api$appeal.Get_Person_Relation_Tp (p_App_Id => p_Obj_Id) =
                      'CHRG'
            THEN
                l_Stop_Dt :=
                    LAST_DAY (ADD_MONTHS (TRUNC (Rec.Ap_Reg_Dt), -1));
                l_Start_Dt := ADD_MONTHS (l_Stop_Dt, -13) + 1;
            --shost 03.04.2023(за усною постановкою В.Шимановича): період за який ззапитуються доходи для соцпослуг повинен відповідати періоду з декларації
            --(логіка розрахунуку періоду скопійовано з контролю по декларації)
            ELSIF Rec.App_Tp = 'SS'
            THEN
                WITH
                    Prev
                    AS
                        (SELECT TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1), 'MM')    AS Dt
                           FROM DUAL)
                SELECT TO_CHAR (TRUNC (ADD_MONTHS (Dt, -3), 'Q'),
                                'dd.mm.yyyy'),
                       TO_CHAR (
                             TRUNC (
                                 ADD_MONTHS (
                                     TRUNC (ADD_MONTHS (Dt, -3), 'Q'),
                                     3),
                                 'Q')
                           - 1,
                           'dd.mm.yyyy')
                  INTO l_Start_Dt, l_Stop_Dt
                  FROM Prev;
            --
            ELSE
                SELECT MAX (d.Apr_Start_Dt), MAX (d.Apr_Stop_Dt)
                  INTO l_Start_Dt, l_Stop_Dt
                  FROM Ap_Declaration d
                 WHERE d.Apr_Ap = Rec.App_Ap;

                --#73136
                IF l_Start_Dt IS NULL OR l_Stop_Dt IS NULL
                THEN
                    l_Start_Dt :=
                          ADD_MONTHS (
                              ADD_MONTHS (
                                    TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1),
                                           'Q')
                                  - 1,
                                  -5),
                              -1)
                        + 1;
                    l_Stop_Dt :=
                        TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1), 'Q') - 1;
                END IF;
            END IF;

            IF    Rec.App_Ln IS NULL
               OR Rec.App_Fn IS NULL
               OR l_Start_Dt IS NULL
               OR l_Stop_Dt IS NULL
            THEN
                p_Error := 'Не вказано';
            END IF;

            IF Rec.App_Ln IS NULL
            THEN
                p_Error := p_Error || ' прізвище особи';
            END IF;

            IF Rec.App_Fn IS NULL
            THEN
                p_Error := p_Error || ' ім’я особи';
            END IF;

            IF l_Stop_Dt IS NULL
            THEN
                p_Error := p_Error || ' кінець періоду в декларації';
            END IF;

            IF l_Start_Dt IS NULL
            THEN
                p_Error := p_Error || ' початок періоду в декларації';
            END IF;

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                    RTRIM (p_Error, ',') || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;

            Ikis_Rbm.Api$request_Pfu.Reg_Upszn_Person_Data_Req (
                p_Sc_Id          => Rec.App_Sc,
                p_Rn_Nrt         => p_Rn_Nrt,
                p_Cod_Upszn      => NULL,
                p_Case_Number    => NULL,
                p_Num_Kss        => Rec.Sc_Unique,
                p_Pn             => Rec.App_Inn,
                p_Ndt_Id         => Rec.App_Ndt,
                p_Doc_Ser        => l_Doc_Ser,
                p_Doc_Nom        => l_Doc_Nom,
                p_Ln             => Rec.App_Ln,
                p_Nm             => Rec.App_Fn,
                p_Ftn            => Rec.App_Mn,
                p_Birthday       => Rec.Scb_Dt,
                p_Period_Start   => l_Start_Dt,
                p_Period_Stop    => l_Stop_Dt,
                p_Ozn_Sub        => NULL,
                p_Rn_Hs_Ins      => NULL,
                p_Rn_Src         => Api$appeal.c_Src_Vst,
                p_Rn_Id          => l_Rn_Id);
        END LOOP;

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Incomes_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до ПФУ
    --     для верифікації доходів
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Vf_Id              NUMBER;
        l_Response_Body      CLOB;
        l_Response_Payload   CLOB;
        l_Reponse_Exists     NUMBER;
    BEGIN
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

              --Парсимо відповідь
              SELECT Resp_Body
                INTO l_Response_Body
                FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                               '/*'
                               PASSING Xmltype (p_Response)
                               COLUMNS Resp_Body    CLOB PATH 'Body');

        l_Response_Payload := Tools.B64_Decode (l_Response_Body);

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => l_Response_Payload,
            p_Vfa_Vf            => l_Vf_Id);

           SELECT SIGN (COUNT (*))
             INTO l_Reponse_Exists
             FROM XMLTABLE ('/*'
                            PASSING Xmltype (l_Response_Payload)
                            COLUMNS Ext_Id    XMLTYPE PATH 'EXTERNAL_ID')
            WHERE Ext_Id IS NOT NULL;

        --Якщо в прикладній відповіді є хочаб якісь дані - вважаємо верифікацію успішною
        --(по постановці К.Я. 27.07.2021)
        IF l_Reponse_Exists = 1
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '110');
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Ok (l_Vf_Id);
        ELSE
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$verification.Set_Not_Verified (l_Vf_Id, CHR (38) || '111');
        END IF;
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на пошук особи в РЗО
    -----------------------------------------------------------------
    FUNCTION Reg_Search_Person_Req (p_Rn_Nrt   IN     NUMBER,
                                    p_Obj_Id   IN     NUMBER,
                                    p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_App_Inn            VARCHAR2 (50);
        l_App_Inn_Verified   NUMBER;
        l_App_Ndt            NUMBER;
        l_App_Doc_Num        Ap_Person.App_Doc_Num%TYPE;
    BEGIN
        p_Error := NULL;
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              =>
                UPPER (
                    'USS_VISIT.Api$verification_Pfu.Reg_Search_Person_Req'),
            p_obj_tp           => 'APPEAL',
            p_Obj_Id           => p_Obj_Id,
            p_regular_params   => 'Start p_Rn_Nrt=' || p_Rn_Nrt);

        FOR Rec IN (SELECT *
                      FROM Ap_Person p
                     WHERE p.App_Id = p_Obj_Id AND p.History_Status = 'A')
        LOOP
            IKIS_SYS.Ikis_Procedure_Log.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.Api$verification_Pfu.Reg_Search_Person_Req'),
                p_obj_tp           => 'APPEAL',
                p_Obj_Id           => p_Obj_Id,
                p_regular_params   => 'Iteration for  App_id=' || Rec.App_Id);

            IF Rec.App_Inn IS NOT NULL AND Rec.App_Inn <> '0000000000'
            THEN
                l_App_Inn := Rec.App_Inn;

                --Перевіряємо чи верифіковно ІПН, що вказано у реквізитах учасника
                SELECT SIGN (COUNT (*))
                  INTO l_App_Inn_Verified
                  FROM Verification v
                 WHERE     v.Vf_Vf_Main = Rec.App_Vf
                       AND v.Vf_Nvt = 4
                       AND v.Vf_St = Api$verification.c_Vf_St_Ok;
            END IF;

            IF l_App_Inn IS NULL OR NVL (l_App_Inn_Verified, 0) <> 1
            THEN
                BEGIN
                    --Отримуємо ІПН учасника з документів
                    SELECT a.Apda_Val_String
                      INTO l_App_Inn
                      FROM Ap_Document  d
                           JOIN Ap_Document_Attr a
                               ON     d.Apd_Id = a.Apda_Apd
                                  AND a.Apda_Nda = 1
                                  AND a.History_Status = 'A'
                                  AND a.Apda_Val_String IS NOT NULL
                                  AND a.Apda_Val_String <> '0000000000'
                     WHERE     d.Apd_App = Rec.App_Id
                           AND d.History_Status = 'A'
                           AND d.Apd_Ndt = 5
                     FETCH FIRST ROW ONLY;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            END IF;

            BEGIN
                  --Отримуємо документ учасника
                  SELECT a.Apda_Val_String, d.Apd_Ndt
                    INTO l_App_Doc_Num, l_App_Ndt
                    FROM Ap_Document d
                         JOIN Ap_Document_Attr a
                             ON     d.Apd_Id = a.Apda_Apd
                                AND a.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                             ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
                   WHERE     Apd_App = Rec.App_Id
                         AND Apd_Ndt IN (6,
                                         7,
                                         8,
                                         9,
                                         13,
                                         37)
                         AND d.History_Status = 'A'
                ORDER BY CASE Apd_Ndt
                             WHEN 7 THEN 1
                             WHEN 6 THEN 2
                             WHEN 37 THEN 3
                             WHEN 13 THEN 4
                             WHEN 8 THEN 5
                             WHEN 9 THEN 6
                         END
                   FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    p_Error :=
                        'Для учасника звернення не задано обов''язковий документ. Створення запиту неможливе';
                    RETURN NULL;
            END;

            Ikis_Rbm.Api$request_Pfu.Reg_Get_Person_Unique_Req (
                p_Rn_Nrt      => p_Rn_Nrt,
                p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
                p_Rn_Src      => 'VST',
                p_Rn_Id       => l_Rn_Id,
                p_Ur_Ext_Id   => NULL,
                p_Is_Reg      => 'F',
                p_Numident    => l_App_Inn,
                p_Ln          => Clear_Name (Rec.App_Ln),
                p_Fn          => Clear_Name (Rec.App_Fn),
                p_Mn          => Clear_Name (Rec.App_Mn),
                p_Doc_Tp      => l_App_Ndt,
                p_Doc_Num     => l_App_Doc_Num,
                p_Gender      => Rec.App_Gender,
                p_Birthday    => NULL);
            Ikis_Rbm.Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => l_Rn_Id,
                p_Rnc_Pt       => c_Pt_App_Id,
                p_Rnc_Val_Id   => Rec.App_Id);
            RETURN l_Rn_Id;
        END LOOP;
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на пошук особи в РЗО
    -----------------------------------------------------------------
    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id       NUMBER;
        l_Vf_Id       NUMBER;
        l_App_Id      NUMBER;
        l_Ap_Id       NUMBER;
        l_New_Id      NUMBER;
        l_App2sc_Vf   NUMBER;
        l_Sc_Unique   Uss_Person.v_Socialcard.Sc_Unique%TYPE;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        --Обробка відповіді
        BEGIN
            Uss_Person.Dnet$exch_Uss2ikis.Handle_Search_Person_Resp (
                p_Ur_Id      => p_Ur_Id,
                p_Response   => p_Response,
                p_Error      => p_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                p_Error := SQLERRM;
        END;

        --Отримуємо ІД учасника звернення
        l_App_Id :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Id (
                p_Rnc_Rn   => l_Rn_Id,
                p_Rnc_Pt   => c_Pt_App_Id);

        --Визначаємо ІД верифікації в якій виконувався пошук соцкартки
        SELECT Vf_Id, App_Ap
          INTO l_App2sc_Vf, l_Ap_Id
          FROM Ap_Person
               JOIN Verification
                   ON     App_Vf = Vf_Vf_Main
                      AND Vf_Nvt IN (Api$verification.c_Nvt_App2sc, 321)
         WHERE App_Id = l_App_Id;

        IF Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id IS NULL
        THEN
            IF Uss_Person.Dnet$exch_Uss2ikis.g_Is_Temp_Error
            THEN
                --ТИМЧАСОВА ПОМИЛКА НА БОЦІ РЗО
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => 'Технічна помилка на боці РЗО');
            ELSE
                --НЕУСПІШНА ВЕРИФІКАЦІЯ
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    NVL (p_Error, CHR (38) || '116'));
                --Продовжуємо процес верифікації пошука/створення соцкартки
                Api$verification.Resume_Auto_Vf (l_App2sc_Vf);
                RETURN;
            END IF;
        END IF;

        SELECT c.Sc_Unique
          INTO l_Sc_Unique
          FROM Uss_Person.v_Socialcard c
         WHERE c.Sc_Id = Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id;

        --Зберігаємо посилання на соцкартку
        Api$appeal.Save_Person (
            p_App_Id        => l_App_Id,
            p_App_Ap        => l_Ap_Id,
            p_App_Tp        => NULL,
            p_App_Inn       => NULL,
            p_App_Ndt       => NULL,
            p_App_Doc_Num   => NULL,
            p_App_Fn        => NULL,
            p_App_Mn        => NULL,
            p_App_Ln        => NULL,
            p_App_Esr_Num   => l_Sc_Unique,
            p_App_Gender    => NULL,
            p_App_Vf        => NULL,
            p_App_Sc        => Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id,
            p_App_Num       => NULL,
            p_New_Id        => l_New_Id);
        /*
        UPDATE Ap_Person p
           SET p.App_Sc      = Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id,
               p.App_Esr_Num = l_Sc_Unique
         WHERE p.App_Id = l_App_Id;
        */
        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$verification.Set_Ok (l_Vf_Id);
        --Продовжуємо процес верифікації пошука/створення соцкартки
        Api$verification.Resume_Auto_Vf (l_App2sc_Vf);
    END;
END Api$verification_Pfu;
/