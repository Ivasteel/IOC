/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_MFU
IS
    -- Author  : SHOSTAK
    -- Created : 21.04.2023 12:41:55 PM
    -- Purpose :

    FUNCTION Reg_Verification_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verification_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2);
END Api$verification_Mfu;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MFU TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MFU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_MFU
IS
    -------------------------------------------------------------------
    --    Реєстрація запиту на превентивну верифікацію
    -------------------------------------------------------------------
    FUNCTION Reg_Verification_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id          NUMBER;
        l_App            Ap_Person%ROWTYPE;
        l_Com_Org        NUMBER;
        l_Com_Wu         NUMBER;
        l_Wu_Pib         VARCHAR2 (300);
        l_Ln             VARCHAR2 (100);
        l_Fn             VARCHAR2 (100);
        l_Mn             VARCHAR2 (100);
        l_Pay_Id         VARCHAR2 (20);
        l_Passport_Ser   VARCHAR2 (10);
        l_Passport_Num   VARCHAR2 (50);
    BEGIN
        --Отримуємо дані учасника звернення
        SELECT *
          INTO l_App
          FROM Ap_Person p
         WHERE p.App_Id = p_Obj_Id;

        --Отримуємо ІД органу та короситувача, від імені якого буде відправлятись запит
        SELECT NVL (a.Ap_Dest_Org, a.Com_Org), a.Com_Wu
          INTO l_Com_Org, l_Com_Wu
          FROM Appeal a
         WHERE a.Ap_Id = l_App.App_Ap;

        IF l_App.App_Ndt = 6
        THEN
            l_Passport_Num := l_App.App_Doc_Num;
            Split_Doc_Number (p_Ndt_Id       => l_App.App_Ndt,
                              p_Doc_Number   => l_Passport_Num,
                              p_Doc_Serial   => l_Passport_Ser);
        ELSIF l_App.App_Ndt = 7
        THEN
            l_Passport_Num := l_App.App_Doc_Num;
        END IF;

        --Отримуємо код виплати для мінфіну
        FOR Rec
            IN (SELECT *
                  FROM Ap_Service s
                 WHERE s.Aps_Ap = l_App.App_Ap AND s.History_Status = 'A')
        LOOP
            l_Pay_Id :=
                Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'NST_ID',
                                           p_Nddc_Src        => 'USS',
                                           p_Nddc_Dest       => 'MFU',
                                           p_Nddc_Code_Src   => Rec.Aps_Nst);

            IF l_Pay_Id IS NOT NULL
            THEN
                EXIT;
            END IF;
        END LOOP;

        IF l_Com_Wu IS NOT NULL
        THEN
            SELECT MAX (u.Wu_Pib)
              INTO l_Wu_Pib
              FROM Ikis_Sysweb.V$all_Users u
             WHERE u.Wu_Id = l_Com_Wu;

            Ikis_rbm.Tools.Split_Pib (l_Wu_Pib,
                                      l_Ln,
                                      l_Fn,
                                      l_Mn);

            Tools.Add_Err (
                TRIM (l_Ln) IS NULL OR TRIM (l_Fn) IS NULL,
                   'Для користівача з ІД ['
                || l_Com_Wu
                || '], що відправляє запит, повинно будти заповнен Прізвище та І''мя [{'
                || l_Ln
                || '} {'
                || l_Fn
                || '}]',
                p_Error);
        END IF;

        --Перевіряємо чи коректно заповнено дані для відправки запиту
        Tools.Add_Err (l_Pay_Id IS NULL,
                       'не знайдено код виплати для послуги',
                       p_Error);
        Tools.Add_Err (
                (l_App.App_Inn IS NULL OR l_App.App_Inn = '0000000000')
            AND l_Passport_Num IS NULL,
            'не вказано ІПН або серію та номер паспорта',
            p_Error);
        Tools.Add_Err (
                l_App.App_Inn IS NOT NULL
            AND NOT REGEXP_LIKE (l_App.App_Inn, '^[0-9]{10}$'),
            'ІПН має некоректний формат',
            p_Error);
        Tools.Add_Err (
                l_Passport_Num IS NOT NULL
            AND l_App.App_Ndt = 7
            AND NOT REGEXP_LIKE (l_Passport_Num, '^[0-9]{9}$'),
            'ІД картка має некоректний формат',
            p_Error);
        Tools.Add_Err (
                l_Passport_Num IS NOT NULL
            AND l_App.App_Ndt = 6
            AND NOT REGEXP_LIKE (l_Passport_Ser || l_Passport_Num,
                                 '^[А-ЯҐІЇЄ]{2}[0-9]{6}$'),
            'Паспорт має некоректний формат',
            p_Error);


        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        --Реєструємо запит
        Ikis_Rbm.Api$request_Mfu.Reg_Verification_Req (
            p_Inn            => NVL (l_App.App_Inn, l_Passport_Ser || l_Passport_Num),
            p_Passport_Ser   => l_Passport_Ser,
            p_Passport_Num   => l_Passport_Num,
            p_Param_Id       => 'ALL',
            p_Pay_Id         => 'MSP1' || l_Pay_Id, -- 08/08/2024 serhii #106676-4
            p_Wu_Id          => l_Com_Wu,
            p_Com_Org        => l_Com_Org,
            p_Sc_Id          => l_App.App_Sc,
            p_Rn_Nrt         => p_Rn_Nrt,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src         => Api$appeal.c_Src_Vst,
            p_Rn_Id          => l_Rn_Id);

        RETURN l_Rn_Id;
    END;

    -------------------------------------------------------------------
    --  Обробка відповіді на запит превентивної верифікації
    -------------------------------------------------------------------
    PROCEDURE Handle_Verification_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id            NUMBER;
        l_Vf_Id            NUMBER;
        l_Resp             Ikis_Rbm.Api$request_Mfu.r_Vf_Response;
        l_Resp_Err         Ikis_Rbm.Api$request_Mfu.r_Vf_Response_Err;
        l_Recomend_Exist   BOOLEAN := FALSE;
    BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
        IF p_Error IS NOT NULL
        THEN
            BEGIN
                Api$verification.Save_Verification_Answer (
                    p_Vfa_Rn            => l_Rn_Id,
                    p_Vfa_Answer_Data   => p_Response,
                    p_Vfa_Vf            => l_Vf_Id);
                l_Resp_Err :=
                    Ikis_Rbm.Api$request_Mfu.Parse_Verification_Err_Resp (
                        p_Response);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            IF    l_Resp_Err.MESSAGE IS NULL
               OR l_Resp_Err.MESSAGE IN
                      ('Bad Request',
                       'Gateway Timeout',
                       'Перевірка заборонена. Проводяться технічні роботи.',
                       'Access denied')
            THEN
                --В такому випадку відправляємо запит повторно
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => p_Error);
            ELSIF l_Resp_Err.MESSAGE = 'Unauthorized'
            THEN
                Ikis_Rbm.Api$uxp_Request.Unauthorized_Exception;
            ELSIF l_Resp_Err.MESSAGE <> 'Recipient not found'
            THEN
                --Інакше переводимо верифікацію в статус "Технічна помилка"
                Api$verification.Set_Tech_Error (l_Rn_Id, l_Resp_Err.MESSAGE);
                RETURN;
            END IF;
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        IF NVL (l_Resp_Err.MESSAGE, '-') <> 'Recipient not found'
        THEN
            BEGIN
                --Парсимо відповідь
                l_Resp :=
                    Ikis_Rbm.Api$request_Mfu.Parse_Verification_Resp (
                        p_Response);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Api$verification.Set_Tech_Error (
                        l_Rn_Id,
                        'Помилка парсингу відповіді: ' || SQLERRM);
                    RETURN;
            END;

            FOR i IN 1 .. l_Resp.Facts_Recomend.COUNT
            LOOP
                IF l_Resp.Facts_Recomend (i).Is_Recomend <> 1
                THEN
                    CONTINUE;
                END IF;

                l_Recomend_Exist := TRUE;
                --Пишемо в журнал верифікації рекомендації отримані від мінфіну
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                    p_Vfl_Message   => l_Resp.Facts_Recomend (i).Recomend);
            END LOOP;
        ELSE
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                p_Vfl_Message   => 'Особу не знайдено в ІАПЕВМ');
        END IF;

        IF l_Recomend_Exist
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$verification.Set_Not_Verified (p_Vf_Id   => l_Vf_Id,
                                               p_Error   => CHR (38) || '192');
        ELSE
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Ok (l_Vf_Id);
        END IF;
    END;
END Api$verification_Mfu;
/