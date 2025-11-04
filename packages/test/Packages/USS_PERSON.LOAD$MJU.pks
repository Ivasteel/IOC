/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$MJU
IS
    -- Author  : SHOSTAK
    -- Created : 28.04.2023 3:20:20 PM
    -- Purpose :

    c_Src_Dracs                CONSTANT VARCHAR2 (10) := '20';

    c_Ndt_Death_Cert           CONSTANT NUMBER := 89;

    c_Nda_Death_Crt_Num        CONSTANT NUMBER := 217;
    c_Nda_Death_Crt_Give_Dt    CONSTANT NUMBER := 219;
    c_Nda_Death_Crt_Death_Dt   CONSTANT NUMBER := 222;
    c_Nda_Death_Crt_Ar_Num     CONSTANT NUMBER := 218;
    c_Nda_Death_Crt_Ar_Dt      CONSTANT NUMBER := 221;
    c_Nda_Death_Crt_Birth_Dt   CONSTANT NUMBER := 785;
    c_Nda_Death_Crt_Pib        CONSTANT NUMBER := 786;
    c_Nda_Death_Crt_Org        CONSTANT NUMBER := 807;

    PROCEDURE Handle_Death_Delta_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Death_Delta_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    PROCEDURE Save_Death_Ar (p_Death_Ar Uss_Exch.v_Death_Ar%ROWTYPE);

    PROCEDURE Process_Death_Delta_Requests;
END Load$mju;
/


GRANT EXECUTE ON USS_PERSON.LOAD$MJU TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.LOAD$MJU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$MJU
IS
    c_Nrt_Death_Delta_Init   CONSTANT NUMBER := 66;
    c_Urt_Death_Delta_Init   CONSTANT NUMBER := 66;

    c_Nrt_Death_Delta        CONSTANT NUMBER := 67;
    c_Urt_Death_Delta        CONSTANT NUMBER := 67;

    c_Lft_Death_Delta        CONSTANT NUMBER := 25;

    ------------------------------------------------------------------
    -- Обробка відповіді на запит отримання дельти по померлим
    --                    (ініціалізація)
    -----------------------------------------------------------------
    PROCEDURE Handle_Death_Delta_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2)
    IS
        l_Order_Id   NUMBER;
        l_Rn_Id      NUMBER;
    BEGIN
        IF    p_Error IS NOT NULL
           OR p_Response IS NULL
           OR DBMS_LOB.Getlength (p_Response) = 0
        THEN
            --У разі помилки відкладаємо запит до "кращіх часів"
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 3600,
                p_Delay_Reason    => p_Error);
        END IF;

        --Парсимо відповідь
        Ikis_Rbm.Api$request_Mju.Parse_Death_Delta_Init_Resp (
            p_Response   => p_Response,
            p_Order_Id   => l_Order_Id);

        IF l_Order_Id IS NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 3600,
                p_Delay_Reason    => 'OrderId порожній');
        END IF;

        --Реєструємо запит на отримання даних
        Ikis_Rbm.Api$request_Mju.Reg_Death_Delta_Req (
            p_Parent_Ur   => p_Ur_Id,
            p_Order_Id    => l_Order_Id,
            p_Plan_Dt     => SYSDATE + INTERVAL '2' MINUTE,
            p_Rn_Nrt      => c_Nrt_Death_Delta,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => 'PERSON',
            p_Rn_Id       => l_Rn_Id);
    END;

    ------------------------------------------------------------------
    -- Обробка відповіді на запит отримання дельти по померлим
    --                  (отримання відповіді)
    -----------------------------------------------------------------
    PROCEDURE Handle_Death_Delta_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
        l_Result   NUMBER;
    BEGIN
        IF    p_Error IS NOT NULL
           OR p_Response IS NULL
           OR DBMS_LOB.Getlength (p_Response) = 0
        THEN
            --У разі помилки відкладаємо запит до "кращіх часів"
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 3600,
                p_Delay_Reason    => p_Error);
        END IF;

        Ikis_Rbm.Api$request_Mju.Parse_Death_Delta_Resp (
            p_Response   => p_Response,
            p_Result     => l_Result);

        IF l_Result = Ikis_Rbm.Api$request_Mju.c_Death_Delta_Res_In_Progress
        THEN
            --Якщо відповідь ще не сформовано, повторюємо запит на отримання даних
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60000,
                p_Delay_Reason    => 'Запит в оброці');
        END IF;

        IF l_Result = Ikis_Rbm.Api$request_Mju.c_Death_Delta_Res_Err
        THEN
            p_Error :=
                   'Сервіс на боці ДРАЦС повернув помилку(код відповіді='
                || Ikis_Rbm.Api$request_Mju.c_Death_Delta_Res_Err
                || ')';
            RETURN;
        END IF;

        BEGIN
            DBMS_SCHEDULER.Run_Job (Job_Name              => 'DAILY_ROUTINE',
                                    Use_Current_Session   => FALSE);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
    END;

    ------------------------------------------------------------------
    -- Парсинг файлу відповіді, дельти по померлим
    ------------------------------------------------------------------
    PROCEDURE Parse_Died_Persons (p_Ur_Id          IN            NUMBER,
                                  p_Died_Persons   IN OUT NOCOPY CLOB,
                                  p_Lfd_Id         IN OUT        NUMBER)
    IS
        l_Lfd_St   VARCHAR2 (10);
    BEGIN
        Uss_Exch.Load_File_Loader.Insertfile (
            p_Lfd_Id          => p_Lfd_Id,
            p_Lfd_Lfd         => NULL,
            p_Lfd_File_Name   =>
                   'DP_'
                || p_Ur_Id
                || '_'
                || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
                || '.csv',
            p_Lfd_Lft         => c_Lft_Death_Delta,
            p_Lfd_Mime_Type   => 'application/csv',
            p_Lfd_Filesize    => DBMS_LOB.Getlength (p_Died_Persons),
            p_Lfd_Create_Dt   => SYSDATE,
            p_Lfd_User_Id     => NULL,
            p_Lfd_Src         => c_Src_Dracs);

        Uss_Exch.Load_File_Loader.Insertdata (
            p_Lfdc_Lfd       => p_Lfd_Id,
            p_Lfdc_Content   => Ikis_Rbm.Tools.Convertc2b (p_Died_Persons));
        COMMIT;
        Uss_Exch.Load_File_Loader.Startprocess (p_Lfd_Id);
        COMMIT;

        SELECT d.Lfd_St
          INTO l_Lfd_St
          FROM Uss_Exch.v_Load_File_Data d
         WHERE d.Lfd_Id = p_Lfd_Id;

        IF NVL (l_Lfd_St, '-') <> 'C'
        THEN
            Raise_Application_Error (
                -20001,
                'Помилка парсингу файла(LFD_ID=' || p_Lfd_Id || ')');
        END IF;
    END;

    ------------------------------------------------------------------
    -- Збереження АЗ та свідоцтва
    ------------------------------------------------------------------
    PROCEDURE Save_Death_Ar (p_Death_Ar Uss_Exch.v_Death_Ar%ROWTYPE)
    IS
        c_Op_Name_Reg     CONSTANT VARCHAR2 (10) := '1';
        c_Op_Name_Del     CONSTANT VARCHAR2 (10) := '2';
        c_Op_Name_Close   CONSTANT VARCHAR2 (10) := '3';

        l_Inn                      VARCHAR2 (500);
        l_Ndt_Id                   NUMBER;
        l_Doc_Ser                  VARCHAR2 (500);
        l_Doc_Num                  VARCHAR2 (500);
        l_Ln                       VARCHAR2 (500);
        l_Fn                       VARCHAR2 (500);
        l_Mn                       VARCHAR2 (500);
        l_Src_Dt                   DATE;
        l_Birth_Dt                 DATE;
        l_Sc_Id                    NUMBER;
        l_Sc_Unique                Socialcard.Sc_Unique%TYPE;
        l_Error                    VARCHAR2 (4000);
        l_Sc_Birth_Dt              DATE;
        l_Sc_Ln                    Sc_Identity.Sci_Ln%TYPE;
        l_Sc_Fn                    Sc_Identity.Sci_Fn%TYPE;
        l_Sc_Mn                    Sc_Identity.Sci_Mn%TYPE;
        l_Scd_Id                   NUMBER;
        l_Dh_Id                    NUMBER;
        l_Attrs                    Api$socialcard.t_Doc_Attrs;
    BEGIN
        l_Inn := TRIM (REPLACE (p_Death_Ar.Numident, ' '));

        IF NOT REGEXP_LIKE (l_Inn, '^[0-9]{10}$')
        THEN
            l_Inn := NULL;
        END IF;

        l_Doc_Num := UPPER (TRIM (REPLACE (p_Death_Ar.Doc_Number, ' ')));

        IF    p_Death_Ar.Doc_Type = '1'
           OR TRIM (LOWER (p_Death_Ar.Doc_Name)) LIKE '%паспорт%'
        THEN
            IF REGEXP_LIKE (l_Doc_Num, '^[0-9]{9}$')
            THEN
                --ІД карта
                l_Ndt_Id := 7;
            ELSIF REGEXP_LIKE (l_Doc_Num,
                               '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[-]{0,1}[0-9]{6}$')
            THEN
                --паспорт старого зарку
                l_Ndt_Id := 6;
                l_Doc_Ser :=
                    TRANSLATE (SUBSTR (l_Doc_Num, 1, 2),
                               'ABCIETOPHKXM',
                               'АВСІЕТОРНКХМ');
                l_Doc_Num := SUBSTR (l_Doc_Num, LENGTH (l_Doc_Num) - 5, 6);
            ELSE
                l_Doc_Num := NULL;
            END IF;
        ELSIF TRIM (LOWER (p_Death_Ar.Doc_Name)) LIKE
                  'свідоцтво про народження%'
        THEN
            l_Ndt_Id := 37;
        ELSIF TRIM (LOWER (p_Death_Ar.Doc_Name)) LIKE
                  'посвідка на постійне проживання%'
        THEN
            l_Ndt_Id := 8;
        ELSIF TRIM (LOWER (p_Death_Ar.Doc_Name)) LIKE
                  'посвідка на тимчасове проживання%'
        THEN
            l_Ndt_Id := 9;
        ELSE
            --інший документ
            l_Ndt_Id := 10192;
        END IF;

        l_Ln := Clear_Name (p_Death_Ar.Surname);
        l_Fn := Clear_Name (p_Death_Ar.Name);
        l_Mn := Clear_Name (p_Death_Ar.Patronymic);
        l_Src_Dt :=
            Tools.Try_Parse_Dt (p_Death_Ar.Op_Date, 'dd.mm.yyyy hh24:mi:ss');
        l_Birth_Dt :=
            Tools.Try_Parse_Dt (p_Death_Ar.Date_Birth,
                                'dd.mm.yyyy hh24:mi:ss');

        IF    --та ІПН або документ
              l_Inn IS NOT NULL
           OR (l_Ndt_Id IS NOT NULL AND l_Doc_Num IS NOT NULL)
        THEN
            BEGIN
                l_Sc_Id :=
                    Load$socialcard.Load_Sc (
                        p_Fn            => l_Fn,
                        p_Ln            => l_Ln,
                        p_Mn            => l_Mn,
                        p_Gender        =>
                            CASE p_Death_Ar.Sex
                                WHEN 1 THEN 'M'
                                WHEN 2 THEN 'F'
                                ELSE 'V'
                            END,
                        p_Nationality   => NULL,
                        p_Src_Dt        => l_Src_Dt,
                        p_Birth_Dt      => l_Birth_Dt,
                        p_Inn_Num       => l_Inn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => l_Ndt_Id,
                        p_Src           => c_Src_Dracs,
                        p_Sc            => l_Sc_Id,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Mode          => Load$socialcard.c_Mode_Search);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_Error :=
                           CHR (38)
                        || '150#'
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Stack
                        || DBMS_UTILITY.Format_Error_Backtrace;
            END;
        ELSE
            l_Sc_Id := NULL;
            l_Error := CHR (38) || '151'; --Не вказано коректні ІПН та документ для визначення СРКО.
        END IF;

        IF l_Sc_Id = 0
        THEN
            l_Sc_Id := NULL;
            l_Error := CHR (38) || '194'; --Неможливо однозначно визначити особу
        END IF;

        IF l_Sc_Id = -2
        THEN
            l_Sc_Id := NULL;
            l_Error := CHR (38) || '193';  --Недостатньо даних для пошуку СРКО
        END IF;

        --РЕЄСТРАЦІЯ АЗ
        IF     UPPER (p_Death_Ar.Ar_Op_Name) IN
                   (c_Op_Name_Reg, 'РЕЄСТРАЦІЯ АЗ')             --Іноді від ДРАЦС тип операції приходить цифрою, а іноді - текстом...
           AND p_Death_Ar.Cert_Serial_Number IS NOT NULL
        THEN
            IF l_Sc_Id IS NOT NULL
            THEN
                --Отримуємо персонільні дані з СРКО для подальшої звірки з даними АЗ
                SELECT i.Sci_Fn,
                       i.Sci_Ln,
                       i.Sci_Mn,
                       b.Scb_Dt
                  INTO l_Sc_Fn,
                       l_Sc_Ln,
                       l_Sc_Mn,
                       l_Sc_Birth_Dt
                  FROM Socialcard  c
                       JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                       LEFT JOIN Sc_Identity i
                           ON Cc.Scc_Sci = i.Sci_Id AND Cc.Scc_Sci <> -1
                       LEFT JOIN Sc_Birth b
                           ON Cc.Scc_Scb = b.Scb_Id AND Cc.Scc_Scb <> -1
                 WHERE c.Sc_Id = l_Sc_Id;

                --Не зберігаємо документ до СРКО у разі, якщо в АЗ та в СРКО вказано ДР, але вони не співпадають
                IF     l_Sc_Birth_Dt IS NOT NULL
                   AND l_Birth_Dt IS NOT NULL
                   AND l_Sc_Birth_Dt <> l_Birth_Dt
                THEN
                    l_Sc_Id := NULL;
                    l_Error := CHR (38) || '195';
                END IF;

                --Не зберігаємо документ до СРКО у разі, ім'я та побатькові в АЗ не відповідають тим що наявні в СРКО (схоже меньше 80%)
                --IF Nvl(Clear_Name(l_Sc_Fn || l_Sc_Mn), '-') <> Nvl(l_Fn || l_Mn, '-') THEN
                IF UTL_MATCH.edit_distance_similarity (
                       NVL (Clear_Name (l_Sc_Fn || l_Sc_Mn), '-'),
                       NVL (l_Fn || l_Mn, '-')) <
                   80
                THEN                                                 --#109620
                    l_Sc_Id := NULL;
                    l_Error := CHR (38) || '196';
                END IF;
            END IF;

            --Зберігаємо документ тільки у разі, якщо було визначено соцкартку,
            IF l_Sc_Id IS NOT NULL --або виникла помилка під час визначення(щоб залогувати подію з посиланням на документ)
                                   OR l_Error IS NOT NULL
            THEN
                --Заповнюємо атрибути документа
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Num,
                    p_Val_Str   => p_Death_Ar.Cert_Serial_Number);
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Give_Dt,
                    p_Val_Dt   =>
                        Tools.Try_Parse_Dt (p_Death_Ar.Cert_Date,
                                            'dd.mm.yyyy'));
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Death_Dt,
                    p_Val_Dt   =>
                        Tools.Try_Parse_Dt (p_Death_Ar.Date_Death,
                                            'dd.mm.yyyy'));
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Ar_Num,
                    p_Val_Str   => p_Death_Ar.Ar_Reg_Number);
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Ar_Dt,
                    p_Val_Dt   =>
                        Tools.Try_Parse_Dt (p_Death_Ar.Compose_Dt,
                                            'dd.mm.yyyy'));
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Birth_Dt,
                    p_Val_Dt   =>
                        Tools.Try_Parse_Dt (p_Death_Ar.Date_Birth,
                                            'dd.mm.yyyy'));
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Pib,
                    p_Val_Str   =>
                           p_Death_Ar.Surname
                        || ' '
                        || p_Death_Ar.Name
                        || ' '
                        || p_Death_Ar.Patronymic);
                Api$socialcard.Add_Doc_Attr (
                    l_Attrs,
                    c_Nda_Death_Crt_Org,
                    p_Val_Str   => p_Death_Ar.Cert_Org);

                --Зберігаємо документ до соцкартки
                Api$socialcard.Save_Document (p_Sc_Id       => l_Sc_Id,
                                              p_Ndt_Id      => c_Ndt_Death_Cert,
                                              p_Doc_Attrs   => l_Attrs,
                                              p_Src_Id      => c_Src_Dracs,
                                              p_Src_Code    => 'DRACS',
                                              p_Scd_Note    => NULL,
                                              p_Scd_Id      => l_Scd_Id,
                                              p_Scd_Dh      => l_Dh_Id);
            END IF;

            IF l_Sc_Id IS NOT NULL
            THEN
                --Зберігаємо інформацію про смерть
                Api$feature.Set_Sc_Death (
                    p_Sc_Id    => l_Sc_Id,
                    p_Scd_Id   => l_Scd_Id,
                    p_Death_Dt   =>
                        Tools.Try_Parse_Dt (p_Death_Ar.Date_Death,
                                            'dd.mm.yyyy'),
                    p_Note     => NULL,
                    p_Src      => c_Src_Dracs,
                    p_Src_Dt   =>
                        NVL (
                            Tools.Try_Parse_Dt (p_Death_Ar.Op_Date,
                                                'dd.mm.yyyy'),
                            SYSDATE));
            END IF;
        --АНУЛЮВАННЯ АБО ВИДАЛЕННЯ АЗ
        ELSIF     l_Sc_Id IS NOT NULL
              AND UPPER (p_Death_Ar.Ar_Op_Name) IN (c_Op_Name_Del,
                                                    c_Op_Name_Close,
                                                    'АНУЛЮВАННЯ АЗ',
                                                    'ВИДАЛЕННЯ АЗ')                        --Іноді від ДРАЦС тип операції приходить цифрою, а іноді - текстом...
        THEN
            FOR Rec
                IN (SELECT d.Scd_Id
                      FROM Sc_Document  d
                           JOIN Uss_Doc.v_Doc_Attr2hist h
                               ON d.Scd_Dh = h.Da2h_Dh
                           JOIN Uss_Doc.v_Doc_Attributes a
                               ON     h.Da2h_Da = a.Da_Id
                                  AND a.Da_Nda = c_Nda_Death_Crt_Ar_Num
                                  AND a.Da_Val_String =
                                      p_Death_Ar.Ar_Reg_Number
                     WHERE     d.Scd_Sc = l_Sc_Id
                           AND d.Scd_Ndt = c_Ndt_Death_Cert
                           AND d.Scd_St = '1')
            LOOP
                --Знімаємо ознаку про смерть(якщо її раніше було встановлено за свідоцтвом/АЗ, що анулюється)
                Api$feature.Unset_Sc_Death (
                    p_Sc_Id    => l_Sc_Id,
                    p_Scd_Id   => Rec.Scd_Id,
                    p_Src      => c_Src_Dracs,
                    p_Src_Dt   =>
                        NVL (
                            Tools.Try_Parse_Dt (p_Death_Ar.Op_Date,
                                                'dd.mm.yyyy'),
                            SYSDATE));
                --Змінюємо статус документа на "Не актуальний"
                Api$socialcard.Set_Doc_St (
                    p_Scd_Id   => Rec.Scd_Id,
                    p_Scd_St   => Api$socialcard.c_Scd_St_Closed);
            END LOOP;
        END IF;

        IF l_Error IS NOT NULL AND l_Scd_Id IS NOT NULL
        THEN
            --Зберігаємо інформацію про помилку визначення соцкартки
            Api$scd_Event.Save_Doc_Error (p_Scde_Scd       => l_Scd_Id,
                                          p_Scde_Dt        => SYSDATE,
                                          p_Scde_Message   => l_Error);
        END IF;
    END;

    ------------------------------------------------------------------
    -- Фонова обробка відповіді на запит отримання дельти по померлим
    ------------------------------------------------------------------
    PROCEDURE Process_Death_Delta_Requests
    IS
        l_New_Req_Exists   NUMBER;
        l_Ur_Id            NUMBER;
        l_Ur_Root          NUMBER;
        l_Response         CLOB;
        l_Prev_Stop_Dt     DATE;
        l_Rn_Id            NUMBER;
        l_Died_Persons     CLOB;
        l_Lfd_Id           NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_New_Req_Exists
          FROM Ikis_Rbm.v_Uxp_Request r
         WHERE     r.Ur_Urt IN (c_Urt_Death_Delta_Init, c_Urt_Death_Delta)
               AND r.Ur_St = 'NEW';

        IF l_New_Req_Exists = 1
        THEN
            RETURN;
        END IF;

        --Отримуємо останню відповідь від ДРАЦС
        BEGIN
              SELECT r.Ur_Id, r.Ur_Soap_Resp
                INTO l_Ur_Id, l_Response
                FROM Ikis_Rbm.v_Uxp_Request r
               WHERE r.Ur_Urt = c_Urt_Death_Delta AND r.Ur_St = 'OK'
            ORDER BY r.Ur_Create_Dt DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        --Отримуємо ІД кореневого запиту(запиту на ініціалізацію)
        l_Ur_Root := Ikis_Rbm.Api$uxp_Request.Get_Root_Request (l_Ur_Id);

        --Отримуємо дату завершення періоду з кореневого запиту
        SELECT Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                   p_Rnc_Rn   => Ur_Rn,
                   p_Rnc_Pt   => Ikis_Rbm.Api$request_Mju.c_Pt_Stop_Dt)
          INTO l_Prev_Stop_Dt
          FROM Ikis_Rbm.v_Uxp_Request r
         WHERE r.Ur_Id = l_Ur_Root;

        --Парсимо відповідь
        Ikis_Rbm.Api$request_Mju.Parse_Death_Delta_Resp (
            p_Response       => l_Response,
            p_Died_Persons   => l_Died_Persons);

        IF     l_Died_Persons IS NOT NULL
           AND DBMS_LOB.Getlength (l_Died_Persons) > 0
        THEN
            --Парсимо файл відповіді
            Parse_Died_Persons (l_Ur_Id,
                                p_Died_Persons   => l_Died_Persons,
                                p_Lfd_Id         => l_Lfd_Id);

            FOR Rec
                IN (  SELECT *
                        FROM Uss_Exch.v_Death_Ar d
                       WHERE d.Lfdp_Lfd = l_Lfd_Id AND LENGTH (d.Op_Date) = 10
                    ORDER BY TO_DATE (d.Op_Date, 'dd.mm.yyyy hh24:mi:ss'))
            LOOP
                --Зберігаємо дані АЗ та свідоцтв
                Save_Death_Ar (Rec);
            END LOOP;
        END IF;

        --Реєструємо наступний запит
        Ikis_Rbm.Api$request_Mju.Reg_Death_Delta_Init_Req (
            p_Start_Dt    => TRUNC (l_Prev_Stop_Dt),
            --Запитуємо дані лише за один день, на випадок тривалого простою обміну
            --Якщо, наприклад, обмін не працював місяць, то є ймовірність, що сервіс не зможе віддати такий об'єм даних
            p_Stop_Dt     => TRUNC (l_Prev_Stop_Dt) + 1,
            p_Plan_Dt     => TRUNC (l_Prev_Stop_Dt) + 1 + INTERVAL '3' HOUR, --Дата, коли сервіс буде відправляти запит
            p_Rn_Nrt      => c_Nrt_Death_Delta_Init,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => 'PERSON',
            p_Rn_Id       => l_Rn_Id);
        COMMIT;
    END;
END Load$mju;
/