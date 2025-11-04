/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_MJU
IS
    -- Author  : KELATEV
    -- Created : 28.02.2025 16:34:21
    -- Purpose : Верифікація ДРАЦС яка виконується у проміжних структурах

    FUNCTION Reg_By_Name_And_Birth_Date_Req (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                p_Obj_Id   IN     NUMBER,
                                p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Change_Name_By_Rnokpp_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Merriage_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Birth_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Death_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2);
END Api$sc_Verification_Mju;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION_MJU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_MJU
IS
    -----------------------------------------------------------------
    -- Реєстрація запиту до ДРАЦС за ПІБ та датою народження
    -----------------------------------------------------------------
    FUNCTION Reg_By_Name_And_Birth_Date_Req (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id        NUMBER;
        l_Name         VARCHAR2 (250);
        l_Surname      VARCHAR2 (250);
        l_Patronymic   VARCHAR2 (250);
        l_Birth_Dt     DATE;
    BEGIN
        SELECT d.Scdi_Fn,
               d.Scdi_Ln,
               d.Scdi_Mn,
               d.Scdi_Birthday
          INTO l_Name,
               l_Surname,
               l_Patronymic,
               l_Birth_Dt
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = p_Obj_Id;

        l_Birth_Dt :=
            NVL (
                l_Birth_Dt,
                Api$socialcard_Ext.Get_Attr_Val_Dt (p_Scdi_Id     => p_Obj_Id,
                                                    p_Nda_Class   => 'BDT',
                                                    p_Ndc_Id      => 13));
        l_Name :=
            NVL (
                l_Name,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'FN',
                    p_Ndc_Id      => 13));
        l_Surname :=
            NVL (
                l_Surname,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'LN',
                    p_Ndc_Id      => 13));
        l_Patronymic :=
            NVL (
                l_Patronymic,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Nda_Class   => 'MN',
                    p_Ndc_Id      => 13));

        IF    l_Birth_Dt IS NULL
           OR l_Surname IS NULL
           OR l_Name IS NULL
           OR l_Patronymic IS NULL
        THEN
            IF l_Birth_Dt IS NULL
            THEN
                p_Error := p_Error || ' дату народження,';
            END IF;

            IF l_Surname IS NULL
            THEN
                p_Error := p_Error || ' прізвище,';
            END IF;

            IF l_Name IS NULL
            THEN
                p_Error := p_Error || ' ім’я,';
            END IF;

            IF l_Patronymic IS NULL
            THEN
                p_Error := p_Error || ' по батькові,';
            END IF;

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                       'Не вказано'
                    || RTRIM (p_Error, ',')
                    || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Ar_By_Name_And_Birth_Date_Req (
            p_Sc_Id        => NULL,
            p_Birth_Dt     => l_Birth_Dt,
            p_Surname      => l_Surname,
            p_Name         => l_Name,
            p_Patronymic   => l_Patronymic,
            p_Rn_Nrt       => p_Rn_Nrt,
            p_Rn_Hs_Ins    => NULL,
            p_Rn_Src       => 'VST',
            p_Rn_Id        => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$sc_Verification_Mju.Reg_By_Name_And_Birth_Date_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Реєстрація запиту до ДРАЦС за РНОКПП
    -----------------------------------------------------------------
    FUNCTION Reg_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                p_Obj_Id   IN     NUMBER,
                                p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
        l_Inn     VARCHAR2 (100);
    BEGIN
        SELECT d.Scdi_Numident
          INTO l_Inn
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = p_Obj_Id;

        l_Inn :=
            NVL (
                l_Inn,
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Obj_Id,
                    p_Ndt_Id      => 5,
                    p_Nda_Class   => 'DSN'));

        IF l_Inn IS NULL
        THEN
            IF l_Inn IS NULL
            THEN
                p_Error := p_Error || ' РНОКПП,';
            END IF;

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                       'Не вказано'
                    || RTRIM (p_Error, ',')
                    || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Ar_By_Rnokpp_Req (
            p_Sc_Id       => NULL,
            p_Inn         => l_Inn,
            p_Role        => NULL,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => 'VST',
            p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$sc_Verification_Mju.Reg_By_Rnokpp_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про зміну імені
    -----------------------------------------------------------------
    PROCEDURE Handle_Change_Name_By_Rnokpp_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id           NUMBER;
        l_Scv_Id          NUMBER;
        l_Scdi_Id         NUMBER;
        l_Scdi_Fn         VARCHAR2 (250);
        l_Scdi_Mn         VARCHAR2 (250);
        l_Scdi_Ln         VARCHAR2 (250);
        l_Scdi_Birth_Dt   DATE;
        l_Error_Info      VARCHAR2 (4000);
        l_Result_Code     NUMBER;
        l_Hs              NUMBER;
        l_Ar_List         Ikis_Rbm.Api$request_Mju.t_Change_Name_Act_Record_List;
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);
        --Отриуюємо ід особи
        l_Scdi_Id := Api$sc_Verification.Get_Scv_Obj (l_Scv_Id);

        --Отримуємо ПІБ особи
        SELECT d.Scdi_Fn,
               d.Scdi_Ln,
               d.Scdi_Mn,
               d.Scdi_Birthday
          INTO l_Scdi_Fn,
               l_Scdi_Ln,
               l_Scdi_Mn,
               l_Scdi_Birth_Dt
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = l_Scdi_Id;

        BEGIN
            --Парсимо відповідь
            l_Ar_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Change_Name_Ar_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$sc_Verification.Set_Tech_Error (
                    l_Rn_Id,
                    l_Hs,
                    'Помилка парсингу відповіді: ' || SQLERRM);
                RETURN;
        END;

        IF l_Result_Code =
           Ikis_Rbm.Api$request_Mju.c_Result_Code_Internal_Err
        THEN
            --Технічна помилка на боці ДРАЦС
            --(повторюємо запит)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    =>
                    NVL (l_Error_Info, 'Технічна помилка на боці ДРАЦС'));
            RETURN;
        END IF;

        IF l_Result_Code <> Ikis_Rbm.Api$request_Mju.c_Result_Code_Ok
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;

            l_Error_Info :=
                NVL (
                    l_Error_Info,
                    CASE
                        WHEN l_Result_Code IN
                                 (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
                        THEN
                               --
                               'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                            || l_Result_Code
                        --
                        WHEN l_Result_Code =
                             Ikis_Rbm.Api$request_Mju.c_Result_Code_Bad_Req
                        THEN
                               'Некоректні параметри запиту.  Код відповіді'
                            || l_Result_Code
                    END);
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => l_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   => 'ДРАЦС. ' || l_Error_Info);
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  l_Error_Info);
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => l_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                p_Scvl_Message   => CHR (38) || '165',
                p_Scvl_St        => NULL,
                p_Scvl_St_Old    => NULL);
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
            RETURN;
        END IF;

        --Шукаємо зміну імені в отриманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            --Найменування останньої операції з АЗ
            IF l_Ar_List (i).Ar_Op_Name NOT IN ('1'             /*Реєстрація*/
                                                   , '4'                       /*Зміни*/
                                                        )
            THEN
                CONTINUE;
            END IF;

            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => l_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                p_Scvl_Message   => CHR (38) || '163',
                p_Scvl_St        => NULL,
                p_Scvl_St_Old    => NULL);

            IF    l_Ar_List (i).Name != l_Scdi_Fn
               OR l_Ar_List (i).Surname != l_Scdi_Ln
               OR NVL (l_Ar_List (i).Patronymic, '0') != NVL (l_Scdi_Mn, '0')
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                l_Error_Info :=
                       CHR (38)
                    || '329#'
                    || TRIM (
                              l_Ar_List (i).Surname
                           || ' '
                           || l_Ar_List (i).Name
                           || ' '
                           || l_Ar_List (i).Patronymic);
                Api$sc_Verification_Moz.Send_Feedback (
                    p_Scdi_Id   => l_Scdi_Id,
                    p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                    p_Message   =>
                           'ДРАЦС. '
                        || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                               l_Error_Info));
                Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                      l_Hs,
                                                      l_Error_Info);
                RETURN;
            END IF;

            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => l_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                p_Scvl_Message   => CHR (38) || '328',
                p_Scvl_St        => NULL,
                p_Scvl_St_Old    => NULL);
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
            RETURN;
        END LOOP;

        Api$sc_Verification.Write_Scv_Log (
            p_Scv_Id         => l_Scv_Id,
            p_Scvl_Hs        => l_Hs,
            p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
            p_Scvl_Message   => CHR (38) || '161',
            p_Scvl_St        => NULL,
            p_Scvl_St_Old    => NULL);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про шлюб
    -----------------------------------------------------------------
    PROCEDURE Handle_Merriage_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Scv_Id        NUMBER;
        l_Scdi_Id       NUMBER;
        l_Numident      Sc_Pfu_Data_Ident.Scdi_Numident%TYPE;
        l_App_Gender    Sc_Pfu_Data_Ident.Scdi_Sex%TYPE;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Hs            NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Merriage_Act_Record_List;
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);

        --Отриуюємо ід особи
        l_Scdi_Id := Api$sc_Verification.Get_Scv_Obj (l_Scv_Id);

        --Отримуємо дані особи
        SELECT d.Scdi_Numident, d.Scdi_Sex
          INTO l_Numident, l_App_Gender
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = l_Scdi_Id;

        BEGIN
            --Парсимо відповідь
            l_Ar_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Merriage_Ar_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$sc_Verification.Set_Tech_Error (
                    l_Rn_Id,
                    l_Hs,
                    'Помилка парсингу відповіді: ' || SQLERRM);
                RETURN;
        END;

        IF l_Result_Code =
           Ikis_Rbm.Api$request_Mju.c_Result_Code_Internal_Err
        THEN
            --Технічна помилка на боці ДРАЦС
            --(повторюємо запит)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    =>
                    NVL (l_Error_Info, 'Технічна помилка на боці ДРАЦС'));
            RETURN;
        END IF;

        IF l_Result_Code <> Ikis_Rbm.Api$request_Mju.c_Result_Code_Ok
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            l_Error_Info :=
                NVL (
                    l_Error_Info,
                    CASE
                        WHEN l_Result_Code IN
                                 (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
                        THEN
                               --
                               'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                            || l_Result_Code
                        --
                        WHEN l_Result_Code =
                             Ikis_Rbm.Api$request_Mju.c_Result_Code_Bad_Req
                        THEN
                               'Некоректні параметри запиту.  Код відповіді'
                            || l_Result_Code
                    END);
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => l_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   => 'ДРАЦС. ' || l_Error_Info);
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  l_Error_Info);
            RETURN;
        END IF;

        --Особа із ПФУ може бути не одружена
        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
            RETURN;
        END IF;

        --Шукаємо свідоцтво про шлюб в отриманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            IF l_Ar_List (i).Certificates IS NULL
            THEN
                CONTINUE;
            END IF;

            --Найменування останньої операції з АЗ
            IF l_Ar_List (i).Ar_Op_Name NOT IN ('1'             /*Реєстрація*/
                                                   , '4'                       /*Зміни*/
                                                        )
            THEN
                CONTINUE;
            END IF;

            DECLARE
                l_Certs         Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert_List;
                l_As_Female     BOOLEAN;
                l_Ar_Numident   VARCHAR2 (10);
            BEGIN
                SELECT *
                  BULK COLLECT INTO l_Certs
                  FROM TABLE (l_Ar_List (i).Certificates)
                 WHERE Cert_Status = '1'                            /*дійсне*/
                                        ;

                IF l_Certs.COUNT > 0
                THEN
                    Api$sc_Verification.Write_Scv_Log (
                        p_Scv_Id         => l_Scv_Id,
                        p_Scvl_Hs        => l_Hs,
                        p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                        p_Scvl_Message   => CHR (38) || '163',
                        p_Scvl_St        => NULL,
                        p_Scvl_St_Old    => NULL);

                    l_As_Female := NVL (l_App_Gender, 'M') = 'F';
                    l_Ar_Numident :=
                        CASE
                            WHEN l_As_Female THEN l_Ar_List (i).Wife_Numident
                            ELSE l_Ar_List (i).Husband_Numident
                        END;

                    IF l_Numident IS NOT NULL AND l_Ar_Numident IS NOT NULL
                    THEN
                        IF LTRIM (l_Ar_Numident, '0') <>
                           LTRIM (l_Numident, '0')
                        THEN
                            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                            Api$sc_Verification_Moz.Send_Feedback (
                                p_Scdi_Id   => l_Scdi_Id,
                                p_Result    =>
                                    Api$sc_Verification_Moz.c_Feedback_Verify,
                                p_Message   =>
                                       'ДРАЦС. '
                                    || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                           CHR (38) || '162'));
                            Api$sc_Verification.Set_Not_Verified (
                                l_Scv_Id,
                                l_Hs,
                                CHR (38) || '162');
                            RETURN;
                        END IF;
                    END IF;

                    --ПІБ та ДН як мінімум належать реальній людині
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
                    RETURN;
                END IF;
            END;
        END LOOP;

        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про народження
    -----------------------------------------------------------------
    PROCEDURE Handle_Birth_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Scv_Id        NUMBER;
        l_Scdi_Id       NUMBER;
        l_Numident      Sc_Pfu_Data_Ident.Scdi_Numident%TYPE;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Hs            NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Birth_Act_Record_List;
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);

        --Отриуюємо ід особи
        l_Scdi_Id := Api$sc_Verification.Get_Scv_Obj (l_Scv_Id);

        --Отримуємо дані особи
        SELECT d.Scdi_Numident
          INTO l_Numident
          FROM Sc_Pfu_Data_Ident d
         WHERE Scdi_Id = l_Scdi_Id;

        BEGIN
            --Парсимо відповідь
            l_Ar_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Birth_Ar_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$sc_Verification.Set_Tech_Error (
                    l_Rn_Id,
                    l_Hs,
                    'Помилка парсингу відповіді: ' || SQLERRM);
                RETURN;
        END;

        IF l_Result_Code =
           Ikis_Rbm.Api$request_Mju.c_Result_Code_Internal_Err
        THEN
            --Технічна помилка на боці ДРАЦС
            --(повторюємо запит)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    =>
                    NVL (l_Error_Info, 'Технічна помилка на боці ДРАЦС'));
            RETURN;
        END IF;

        IF l_Result_Code <> Ikis_Rbm.Api$request_Mju.c_Result_Code_Ok
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            l_Error_Info :=
                NVL (
                    l_Error_Info,
                    CASE
                        WHEN l_Result_Code IN
                                 (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
                        THEN
                               --
                               'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                            || l_Result_Code
                        --
                        WHEN l_Result_Code =
                             Ikis_Rbm.Api$request_Mju.c_Result_Code_Bad_Req
                        THEN
                               'Некоректні параметри запиту.  Код відповіді'
                            || l_Result_Code
                    END);
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => l_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   => 'ДРАЦС. ' || l_Error_Info);
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  l_Error_Info);
            RETURN;
        END IF;

        --Особа із ПФУ може бути не одружена
        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  CHR (38) || '108');
            RETURN;
        END IF;

        --Шукаємо свідоцтво про шлюб в отриманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            IF l_Ar_List (i).Certificates IS NULL
            THEN
                CONTINUE;
            END IF;

            --Найменування останньої операції з АЗ
            IF l_Ar_List (i).Ar_Op_Name NOT IN ('1'             /*Реєстрація*/
                                                   , '4'                       /*Зміни*/
                                                        )
            THEN
                CONTINUE;
            END IF;

            DECLARE
                l_Certs   Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert_List;
            BEGIN
                SELECT *
                  BULK COLLECT INTO l_Certs
                  FROM TABLE (l_Ar_List (i).Certificates)
                 WHERE Cert_Status = '1'                            /*дійсне*/
                                        ;

                IF l_Certs.COUNT > 0
                THEN
                    Api$sc_Verification.Write_Scv_Log (
                        p_Scv_Id         => l_Scv_Id,
                        p_Scvl_Hs        => l_Hs,
                        p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                        p_Scvl_Message   => CHR (38) || '163',
                        p_Scvl_St        => NULL,
                        p_Scvl_St_Old    => NULL);

                    IF     l_Numident IS NOT NULL
                       AND l_Ar_List (i).Child_Numident IS NOT NULL
                    THEN
                        IF LTRIM (l_Ar_List (i).Child_Numident, '0') <>
                           LTRIM (l_Numident, '0')
                        THEN
                            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                            Api$sc_Verification_Moz.Send_Feedback (
                                p_Scdi_Id   => l_Scdi_Id,
                                p_Result    =>
                                    Api$sc_Verification_Moz.c_Feedback_Verify,
                                p_Message   =>
                                       'ДРАЦС. '
                                    || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                           CHR (38) || '162'));
                            Api$sc_Verification.Set_Not_Verified (
                                l_Scv_Id,
                                l_Hs,
                                CHR (38) || '162');
                            RETURN;
                        END IF;
                    END IF;

                    --ПІБ та ДН як мінімум належать реальній людині
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
                    RETURN;
                END IF;
            END;
        END LOOP;

        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        Api$sc_Verification_Moz.Send_Feedback (
            p_Scdi_Id   => l_Scdi_Id,
            p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
            p_Message   =>
                   'ДРАЦС. '
                || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                       CHR (38) || '161'));
        Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                              l_Hs,
                                              CHR (38) || '161');
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про смерть
    -----------------------------------------------------------------
    PROCEDURE Handle_Death_By_Name_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Scv_Id        NUMBER;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Hs            NUMBER;
        l_Scdi_Id       NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Death_Act_Record_List;
    BEGIN
        l_Hs := Tools.Gethistsession;
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$sc_Verification.Save_Verification_Answer (
            p_Scva_Rn            => l_Rn_Id,
            p_Scva_Answer_Data   => p_Response,
            p_Scva_Scv           => l_Scv_Id);

        --Отриуюємо ід особи
        l_Scdi_Id := Api$sc_Verification.Get_Scv_Obj (l_Scv_Id);

        BEGIN
            --Парсимо відповідь
            l_Ar_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Death_Ar_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$sc_Verification.Set_Tech_Error (
                    l_Rn_Id,
                    l_Hs,
                    'Помилка парсингу відповіді: ' || SQLERRM);
                RETURN;
        END;

        IF l_Result_Code =
           Ikis_Rbm.Api$request_Mju.c_Result_Code_Internal_Err
        THEN
            --Технічна помилка на боці ДРАЦС
            --(повторюємо запит)
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    =>
                    NVL (l_Error_Info, 'Технічна помилка на боці ДРАЦС'));
            RETURN;
        END IF;

        IF l_Result_Code <> Ikis_Rbm.Api$request_Mju.c_Result_Code_Ok
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            l_Error_Info :=
                NVL (
                    l_Error_Info,
                    CASE
                        WHEN l_Result_Code IN
                                 (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3,
                                  Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
                        THEN
                               --
                               'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                            || l_Result_Code
                        --
                        WHEN l_Result_Code =
                             Ikis_Rbm.Api$request_Mju.c_Result_Code_Bad_Req
                        THEN
                               'Некоректні параметри запиту.  Код відповіді'
                            || l_Result_Code
                    END);
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => l_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   => 'ДРАЦС. ' || l_Error_Info);
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  l_Error_Info);
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => l_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                p_Scvl_Message   => CHR (38) || '109',
                p_Scvl_St        => NULL,
                p_Scvl_St_Old    => NULL);
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
            RETURN;
        END IF;

        --Шукаємо зміну імені в отриманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$sc_Verification_Moz.Send_Feedback (
                p_Scdi_Id   => l_Scdi_Id,
                p_Result    => Api$sc_Verification_Moz.c_Feedback_Verify,
                p_Message   =>
                       'ДРАЦС. '
                    || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                           CHR (38) || '163'));
            Api$sc_Verification.Set_Not_Verified (l_Scv_Id,
                                                  l_Hs,
                                                  CHR (38) || '163');
            RETURN;
        END LOOP;

        Api$sc_Verification.Write_Scv_Log (
            p_Scv_Id         => l_Scv_Id,
            p_Scvl_Hs        => l_Hs,
            p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
            p_Scvl_Message   => CHR (38) || '161',
            p_Scvl_St        => NULL,
            p_Scvl_St_Old    => NULL);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$sc_Verification.Set_Ok (l_Scv_Id, l_Hs);
    END;
END Api$sc_Verification_Mju;
/