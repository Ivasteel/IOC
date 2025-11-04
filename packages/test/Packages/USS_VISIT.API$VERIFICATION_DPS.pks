/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_DPS
IS
    -- Author  : SHOSTAK
    -- Created : 08.12.2022 12:12:05 PM
    -- Purpose :

    FUNCTION Reg_Get_Incomes_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Get_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Get_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Ipn_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Id   IN     NUMBER,
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Ipn_Init_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Verify_Ipn_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Dfs_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Dfs_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);
END Api$verification_Dps;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_DPS TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_DPS TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_DPS
IS
    -----------------------------------------------------------------
    --         Реєстрація запиту до ДФС для отримання доходів
    --           (ініціалізація розрахунку)
    -----------------------------------------------------------------
    FUNCTION Reg_Get_Incomes_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Executor_Wu    NUMBER;
        l_Hs             NUMBER;
        l_Rn_Id          NUMBER;
        l_Ap_Id          NUMBER;
        l_Ap_Reg_Dt      DATE;
        l_Ap_Tp          Appeal.Ap_Tp%TYPE;
        l_Apd_Ndt        Ap_Document.Apd_Ndt%TYPE;
        l_App_Inn        Ap_Person.App_Inn%TYPE;
        l_App_Fn         Ap_Person.App_Fn%TYPE;
        l_App_Mn         Ap_Person.App_Mn%TYPE;
        l_App_Ln         Ap_Person.App_Ln%TYPE;
        l_App_Sc         Ap_Person.App_Sc%TYPE;
        l_Wu_Pib         VARCHAR2 (300);
        l_Wu_Numid       VARCHAR2 (10);
        l_Ln             VARCHAR2 (100);
        l_Fn             VARCHAR2 (100);
        l_Mn             VARCHAR2 (100);
        l_App_Birth_Dt   DATE;
        l_Period_Begin   DATE;
        l_Period_End     DATE;
    BEGIN
        BEGIN
            --Отримуємо ІПН та інщі реквізити учасника
            SELECT a.Ap_Reg_Dt,
                   p.App_Ap,
                   COALESCE (
                       Api$appeal.Get_Person_Inn_Doc (p_App_Id => p.App_Id),
                       p.App_Inn),
                   p.App_Fn,
                   p.App_Mn,
                   p.App_Ln,
                   p.App_Sc,
                   a.Com_Wu,
                   a.Ap_Tp
              INTO l_Ap_Reg_Dt,
                   l_Ap_Id,
                   l_App_Inn,
                   l_App_Fn,
                   l_App_Mn,
                   l_App_Ln,
                   l_App_Sc,
                   l_Executor_Wu,
                   l_Ap_Tp
              FROM Ap_Person p JOIN Appeal a ON p.App_Ap = a.Ap_Id
             WHERE p.App_Id = p_Obj_Id;

            IF l_App_Inn IS NULL
            THEN
                SELECT Apd_Ndt,
                       Api$appeal.Get_Attr_Val_String (Apd_Id, 'DSN'),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'FN'),
                            l_App_Fn),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'MN'),
                            l_App_Mn),
                       NVL (Api$appeal.Get_Attr_Val_String (Apd_Id, 'LN'),
                            l_App_Ln),
                       Api$appeal.Get_Attr_Val_Dt (Apd_Id, 'BDT')
                  INTO l_Apd_Ndt,
                       l_App_Inn,
                       l_App_Fn,
                       l_App_Mn,
                       l_App_Ln,
                       l_App_Birth_Dt
                  FROM (SELECT d.Apd_Id, d.Apd_Ndt
                          FROM Ap_Document d
                         WHERE     d.Apd_App = p_Obj_Id
                               AND d.History_Status = 'A'
                               AND d.Apd_Ndt IN (6, 7)
                         FETCH FIRST ROW ONLY);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --#99018
        IF     Api$appeal.Service_Exists (p_Aps_Ap    => l_Ap_Id,
                                          p_Aps_Nst   => 664)
           AND l_Ap_Reg_Dt >= TO_DATE ('01.02.2024', 'DD.MM.YYYY')
        THEN
            WITH
                Prev
                AS
                    (SELECT TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'Q')    AS Dt
                       FROM DUAL)
            SELECT ADD_MONTHS (Dt, -3), Dt - 1
              INTO l_Period_Begin, l_Period_End
              FROM Prev;
        ELSIF l_Ap_Tp = 'SS'
        THEN
            --shost 03.04.2023(за усною постановкою В.Шимановича): період за який ззапитуються доходи для соцпослуг повинен відповідати періоду з декларації
            --(логіка розрахунуку періоду скопійовано з контролю по декларації)
            WITH
                Prev
                AS
                    (SELECT TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'MM')    AS Dt
                       FROM DUAL)
            SELECT TO_CHAR (TRUNC (ADD_MONTHS (Dt, -3), 'Q'), 'dd.mm.yyyy'),
                   TO_CHAR (
                         TRUNC (
                             ADD_MONTHS (TRUNC (ADD_MONTHS (Dt, -3), 'Q'), 3),
                             'Q')
                       - 1,
                       'dd.mm.yyyy')
              INTO l_Period_Begin, l_Period_End
              FROM Prev;
        --
        ELSE
            SELECT MAX (d.Apr_Start_Dt), MAX (d.Apr_Stop_Dt)
              INTO l_Period_Begin, l_Period_End
              FROM Ap_Declaration d
             WHERE d.Apr_Ap = l_Ap_Id;

            --#73136
            IF l_Period_Begin IS NULL OR l_Period_End IS NULL
            THEN
                l_Period_Begin :=
                      ADD_MONTHS (
                          ADD_MONTHS (
                              TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'Q') - 1,
                              -5),
                          -1)
                    + 1;
                l_Period_End := TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'Q') - 1;
            END IF;
        END IF;

        IF    l_App_Inn IS NULL
           OR l_App_Fn IS NULL
           --OR l_App_Mn IS NULL
           OR l_App_Ln IS NULL
           OR (l_Apd_Ndt IN (6, 7) AND l_App_Birth_Dt IS NULL)
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_App_Inn IS NULL
        THEN
            p_Error :=
                   p_Error
                || CASE
                       WHEN l_Apd_Ndt IN (6, 7)
                       THEN
                           ' серію та номер паспорту'
                       ELSE
                           ' РНОКПП'
                   END
                || ' особи,';
        END IF;

        IF l_App_Fn IS NULL
        THEN
            p_Error := p_Error || ' ім’я особи,';
        END IF;

        --#92240 контроль знято
        /*IF l_App_Mn IS NULL THEN
          p_Error := p_Error || ' по батькові особи,';
        END IF;*/

        IF l_App_Ln IS NULL
        THEN
            p_Error := p_Error || ' прізвище особи,';
        END IF;

        IF l_Apd_Ndt IN (6, 7) --#72466: Дата народження є обов’язковою тільки для безкодників
                               AND l_App_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження особи';
        END IF;

        IF l_Executor_Wu IS NOT NULL
        THEN
            SELECT MAX (u.Wu_Pib), MAX (u.WU_NUMID)
              INTO l_Wu_Pib, l_Wu_Numid
              FROM Ikis_Sysweb.V$all_Users u
             WHERE u.Wu_Id = l_Executor_Wu;

            Ikis_rbm.Tools.Split_Pib (l_Wu_Pib,
                                      l_Ln,
                                      l_Fn,
                                      l_Mn);

            Tools.Add_Err (
                TRIM (l_Ln) IS NULL OR TRIM (l_Fn) IS NULL,
                   'Для користівача з ІД ['
                || l_Executor_Wu
                || '], що відправляє запит, повинно бути заповнен Прізвище та І''мя [{'
                || l_Ln
                || '} {'
                || l_Fn
                || '}]',
                p_Error);
            Tools.Add_Err (
                TRIM (l_Wu_Numid) IS NULL,
                   'Для користівача з ІД ['
                || l_Executor_Wu
                || '], що відправляє запит, повинен бути заповнен РНОКПП',
                p_Error);
        END IF;

        --#109232 за цими значеннями розраховуються обов'язкові period_begin_quarter, period_ begin_year, period_end_ quarter, period_end_year
        IF l_Period_Begin IS NULL OR l_Period_End IS NULL
        THEN
            p_Error :=
                'Не вдалося визначити початок та кінець періоду для запиту';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Dfs.Reg_Income_Sources_Query_Req (
            p_Basis_Request   =>                                        --CASE
                                           --  WHEN l_Ap_Tp in ('V','SS') THEN
            '2'--END
               ,
            p_Executor_Wu    => l_Executor_Wu,
            p_Sc_Id          => l_App_Sc,
            p_Rnokpp         => l_App_Inn,
            p_Last_Name      => l_App_Ln,
            p_First_Name     => l_App_Fn,
            p_Middle_Name    => l_App_Mn,
            p_Date_Birth     => l_App_Birth_Dt,
            p_Period_Begin   => l_Period_Begin,
            p_Period_End     => l_Period_End,
            p_Rn_Nrt         => p_Rn_Nrt,
            p_Rn_Hs_Ins      => l_Hs,
            p_Rn_Src         => Api$appeal.c_Src_Vst,
            p_Rn_Id          => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Dps.Reg_Get_Incomes_Init_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для отримання доходів
    --                 (ініціалізація розрахунку)
    -----------------------------------------------------------------
    PROCEDURE Handle_Get_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2)
    IS
        c_Subreq_Nrt   CONSTANT NUMBER := 3; --тип підзапиту на отримання даних
        l_Rn_Id                 NUMBER;
        l_Vf_Id                 NUMBER;
        l_Repeat                VARCHAR2 (10);
        l_Subreq_Created        VARCHAR2 (10);
    BEGIN
        IF p_Error IS NULL
        THEN
            Ikis_Rbm.Api$request_Dfs.Handle_Income_Sources_Query_Resp (
                p_Ur_Id            => p_Ur_Id,
                p_Response         => p_Response,
                p_Error            => p_Error,
                p_Repeat           => l_Repeat,
                p_Subreq_Created   => l_Subreq_Created,
                p_Subreq_Nrt       => c_Subreq_Nrt,
                p_Rn_Src           => Api$appeal.c_Src_Vst);

            IF l_Repeat = 'T'
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => p_Error);
            END IF;
        ELSE
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --в разі помилки змінюємо статус верифікації
        IF p_Error IS NOT NULL
        THEN
            l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
            Api$verification.Save_Verification_Answer (
                p_Vfa_Rn            => l_Rn_Id,
                p_Vfa_Answer_Data   => p_Response,
                p_Vfa_Vf            => l_Vf_Id);
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                p_Vfl_Message   => p_Error);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END IF;
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для отримання доходів
    --                 (отримання відповіді)
    -----------------------------------------------------------------
    PROCEDURE Handle_Get_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
        l_Ur_Root         NUMBER;
        l_Rn_Id           NUMBER;
        l_Vf_Id           NUMBER;
        l_Error_Message   VARCHAR2 (4000);
    BEGIN
        --Отримуємо ІД кореневого запиту
        l_Ur_Root :=
            Ikis_Rbm.Api$uxp_Request.Get_Root_Request (p_Ur_Id => p_Ur_Id);
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => l_Ur_Root);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь від ДПС
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Res          NUMBER PATH 'Info/result',
                                         Rnokpp       VARCHAR2 (20) PATH 'Info/RNOKPP',
                                         Error        VARCHAR2 (10) PATH 'error',
                                         Error_Msg    VARCHAR2 (4000) PATH 'errorMsg'))
        LOOP
            IF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_Not_Found
            THEN
                --ТЕХНІЧНА ПОМИЛКА(НА БОЦІ ДФС)
                p_Error := Rec.Error_Msg;
                Api$verification.Set_Tech_Error (l_Rn_Id, Rec.Error_Msg);
                RETURN;
            ELSIF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_In_Process
            THEN
                --ЗАПИТ В ОБРОБЦІ
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => Rec.Error_Msg);

                --Встановлюємо ознаку для сервіса, що запит необхідно надіслати повторно
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 30,
                    p_Delay_Reason    => Rec.Error_Msg);
            ELSIF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_Answer_Gived
            THEN
                --НА ЗАПИТ ВЖЕ НАДАНО ВІДПОВІДЬ
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => Rec.Error_Msg);

                --Встановлюємо ознаку для сервіса, що батківський запит необхідно надіслати повторно
                Ikis_Rbm.Api$uxp_Request.Repeat_Out_Request (
                    p_Ur_Id   => l_Ur_Root);
                RETURN;
            END IF;

            IF NVL (Rec.Res, 4) = 4        --Код відповіді 4 означає наступне:
                                    --"інформація щодо сум нарахованого доходу та сум утриманого з них податку за вказаний в запиті період в ДРФО відсутня".
                                    --Тому якщо припустити, що він повертається тільки у разі, якщо реквізити коректні, але доходи за період не знайдено,
                                    --вважаємо верифікацію реквізитів успішною.
                                    --Відсутність коду відповіді також є підставою для позитивного результату верифікації.
                                    --Всі інщі коди відповідей повідомляють про некоректність реквізитів.
                                    AND Rec.Rnokpp IS NOT NULL
            THEN
                --УСПІШНА ВЕРИФІКАЦІЯ
                Api$verification.Set_Ok (l_Vf_Id);
            ELSE
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                l_Error_Message :=
                       CHR (38)
                    || CASE Rec.Res
                           WHEN 5 THEN '98'
                           WHEN 6 THEN '99'
                           WHEN 7 THEN '100'
                           WHEN 8 THEN '101'
                           WHEN 9 THEN '102'
                           WHEN 10 THEN '103'
                           WHEN 11 THEN '104'
                           WHEN 12 THEN '105'
                           WHEN 13 THEN '106'
                           ELSE '107'
                       END;
                Api$verification.Set_Not_Verified (l_Vf_Id, l_Error_Message);
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до ДФС для перевірки ІПН
    --           (ініціалізація розрахунку)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Ipn_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Id   IN     NUMBER,
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Vf_Obj_Tp   Verification.Vf_Obj_Tp%TYPE;
        l_Ap_Id       NUMBER;
        l_App_Id      NUMBER;
        l_Apd_Ndt     NUMBER;
        l_Ipn         VARCHAR2 (50);
        l_Mask        VARCHAR2 (100);
    BEGIN
        l_Vf_Obj_Tp :=
            Api$verification.Get_Vf_Obj_Tp (Api$verification.g_Vf_Id);

        --Якщо верифікується документ
        IF l_Vf_Obj_Tp = 'D'
        THEN
            SELECT d.Apd_App, d.Apd_Ndt, d.Apd_Ap
              INTO l_App_Id, l_Apd_Ndt, l_Ap_Id
              FROM Ap_Document d
             WHERE d.Apd_Id = p_Obj_Id;

            l_Ipn :=
                REPLACE (Api$appeal.Get_Attr_Val_String (p_Obj_Id, 'DSN'),
                         ' ');
            l_Mask :=
                CASE l_Apd_Ndt
                    WHEN 5 THEN '^[0-9]{10}$'
                    WHEN 6 THEN '^[А-ЯҐІЇЄ]{2}[-]{0,1}[0-9]{6}$'
                    WHEN 7 THEN '^[0-9]{9}$'
                END;
        ELSE
            --Якщо верифікується реквізит учасника
            l_App_Id := p_Obj_Id;

            SELECT p.App_Ap
              INTO l_Ap_Id
              FROM Ap_Person p
             WHERE p.App_Id = l_App_Id;

            l_Ipn := REPLACE (Api$appeal.Get_Person_Inn (l_App_Id), ' ');
            l_Mask := '^[0-9]{10}$';
        END IF;

        IF l_Ipn IS NULL
        THEN
            p_Error := 'не вказано РНОКПП';
            RETURN NULL;
        END IF;

        IF NOT REGEXP_LIKE (l_Ipn, l_Mask)
        THEN
            p_Error := 'РНОКПП ' || l_Ipn || ' має некоректний формат';
        END IF;

        --Заявник в Дії авторизується за допомогою КЕП, тому його РНОКПП
        --вважаеється верифікованим
        --08.12.2022: за постановкоє КЕВ
        IF     Api$appeal.Get_Ap_Src (l_Ap_Id) = 'DIIA'
           AND Api$appeal.Get_Person_Tp (l_App_Id) = 'Z'
        THEN
            Api$verification.Set_Ok (p_Vf_Id => Api$verification.g_Vf_Id);
            RETURN NULL;
        END IF;

        --#94235
        --Заявник на порталі авторизується за допомогою КЕП, тому його РНОКПП
        --вважаеється верифікованим
        IF     Api$appeal.Get_Ap_Src (l_Ap_Id) = 'PORTAL'
           AND Api$appeal.Get_Person_Tp (l_App_Id) = 'Z'
        THEN
            Api$verification.Set_Ok (p_Vf_Id => Api$verification.g_Vf_Id);
            RETURN NULL;
        END IF;

        RETURN NULL;
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для перевірки ІПН
    --                 (ініціалізація розрахунку)
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Ipn_Init_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        NULL;
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для перевірки ІПН
    --                 (отримання відповіді)
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Ipn_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        NULL;
    END;


    -----------------------------------------------------------------
    --         Реєстрація запиту до ДПС (верифікація РНОКПП)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Dfs_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id      NUMBER;
        l_Sc_Id      NUMBER;
        l_Apd_Id     NUMBER;
        l_App_Id     NUMBER;
        l_Ndt_Id     NUMBER;

        l_Inn        VARCHAR2 (100);
        l_Birth_Dt   DATE;
        l_Ln         VARCHAR2 (250);
        l_Mn         VARCHAR2 (250);
        l_Fn         VARCHAR2 (250);
        l_Wu         NUMBER;
    BEGIN
          SELECT p.App_Sc,
                 d.Apd_Id,
                 d.Apd_Ndt,
                 p.App_Inn,
                 p.app_fn,
                 p.app_ln,
                 p.app_mn,
                 p.app_id,
                 ap.com_wu
            INTO l_Sc_Id,
                 l_Apd_Id,
                 l_Ndt_Id,
                 l_Inn,
                 l_Fn,
                 l_Ln,
                 l_Mn,
                 l_App_Id,
                 l_Wu
            FROM Ap_Document d
                 JOIN Ap_Person p ON d.Apd_App = p.App_Id
                 JOIN Appeal ap ON p.app_ap = ap.ap_id
           WHERE     d.apd_id = p_Obj_Id
                 AND d.History_Status = 'A'
                 --При зміні, оновити в Handle_Verify_Passport_Resp
                 AND d.Apd_Ndt IN (5         /*Довідка про присвоєння РНОКПП*/
                                    )
        ORDER BY Apd_Ndt
           FETCH FIRST 1 ROW ONLY;

        l_Inn :=
            NVL (
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'DSN'),
                l_Inn);
        l_Birth_Dt :=
            Api$appeal.Get_Person_Doc_Attr_Val_Dt (p_App_Id      => l_App_Id,
                                                   p_Nda_Class   => 'BDT',
                                                   p_Ndt_Ndc     => 13); --#106852
        l_Fn :=
            NVL (
                l_Fn,
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'FN'));
        l_Ln :=
            NVL (
                l_Ln,
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'LN'));
        l_Mn :=
            NVL (
                l_Mn,
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'MN'));


        IF    l_Birth_Dt IS NULL
           OR l_Fn IS NULL
           OR l_Ln IS NULL
           OR l_Inn IS NULL
        THEN
            Tools.Add_Err (l_Birth_Dt IS NULL, ' дату народження', p_Error);
            Tools.Add_Err (l_Ln IS NULL, ' прізвище', p_Error);
            Tools.Add_Err (l_Fn IS NULL, ' ім’я', p_Error);
            Tools.Add_Err (l_Inn IS NULL, ' ІНН', p_Error);

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                       'Не вказано'
                    || RTRIM (p_Error, ',')
                    || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;
        END IF;


        Ikis_Rbm.Api$request_Dfs.Reg_Create_Dfs_Rnokpp_Req (
            p_Sc_Id       => l_Sc_Id,
            p_Plan_Dt     => SYSDATE,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => NULL,
            p_Rn_Id       => l_Rn_Id,
            p_Numident    => l_Inn,
            p_Ln          => l_Ln,
            p_Fn          => l_Fn,
            p_Mn          => l_Mn,
            p_Doc_Ser     => NULL,
            p_Doc_Num     => NULL,
            p_Birthday    => l_Birth_Dt,
            p_Wu          => l_Wu);

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_DFS_RNOKPP_Req: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;


    PROCEDURE Handle_Dfs_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
        --l_Ur_Root       NUMBER;
        l_Rn_Id           NUMBER;
        l_Vf_Id           NUMBER;
        l_Apd_Id          NUMBER;
        l_Error_Message   VARCHAR2 (4000);
    BEGIN
        --Отримуємо ІД кореневого запиту
        --l_Ur_Root := Ikis_Rbm.Api$uxp_Request.Get_Root_Request(p_Ur_Id => p_Ur_Id);
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь від ДПС
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документу
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        UPDATE Ap_Document
           SET Apd_Vf = l_Vf_Id
         WHERE Apd_Id = l_Apd_Id;

        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Res          NUMBER PATH 'Result',
                                         Error_Msg    VARCHAR2 (4000) PATH 'Errormsg'))
        LOOP
            IF NVL (Rec.Res, 0) = 0
            THEN
                --УСПІШНА ВЕРИФІКАЦІЯ
                Api$verification.Set_Ok (l_Vf_Id);
            ELSE
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                l_Error_Message :=
                       CHR (38)
                    || CASE Rec.Res
                           WHEN 1 THEN '275'
                           WHEN 2 THEN '276'
                           WHEN 3 THEN '277'
                           WHEN 4 THEN '278'
                           WHEN 42 THEN '279'
                           ELSE '107'
                       END;
                Api$verification.Set_Not_Verified (l_Vf_Id, l_Error_Message);
            --Api$verification.Set_Vf_Tech_Error(l_Vf_Id, l_Error_Message);
            END IF;
        END LOOP;
    END;
END Api$verification_Dps;
/