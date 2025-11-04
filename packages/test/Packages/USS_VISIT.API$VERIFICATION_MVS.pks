/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_MVS
IS
    FUNCTION Reg_Verify_Passport_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Id   IN     NUMBER,
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Passport_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);
END Api$verification_Mvs;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MVS TO USS_RNSP
/


/* Formatted on 8/12/2025 5:59:52 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_MVS
IS
    -----------------------------------------------------------------
    --         Реєстрація запиту до МВС для
    --     верифікації даних документів учасника звернення
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Passport_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Id   IN     NUMBER,     --Документ
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id        NUMBER;
        l_Sc_Id        NUMBER;
        l_Apd_Id       NUMBER;
        l_Ndt_Id       NUMBER;
        l_Gender       VARCHAR2 (50);
        l_Inn          VARCHAR2 (100);

        l_Doc_Number   VARCHAR2 (100);
        l_Doc_Ser      VARCHAR2 (100);
        l_Doc_Num      VARCHAR2 (100);
        l_Birth_Dt     DATE;
        l_Ln           VARCHAR2 (250);
        l_Mn           VARCHAR2 (250);
        l_Fn           VARCHAR2 (250);
    BEGIN
        SELECT p.App_Sc,
               d.Apd_Id,
               d.Apd_Ndt,
               p.App_Gender,
               p.App_Inn,
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'DSN'),
                   p.app_doc_num),
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'FN'),
                   p.app_fn),
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'LN'),
                   p.app_ln),
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'MN'),
                   p.app_mn)
          INTO l_Sc_Id,
               l_Apd_Id,
               l_Ndt_Id,
               l_Gender,
               l_Inn,
               l_Doc_Number,
               l_Fn,
               l_Ln,
               l_Mn
          FROM Ap_Document d JOIN Ap_Person p ON p.App_Id = d.apd_app
         WHERE d.Apd_id = p_Obj_Id AND d.History_Status = 'A';

        l_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => l_Apd_Id,
                                        p_Nda_Class   => 'BDT');

        l_Doc_Ser := REGEXP_SUBSTR (l_Doc_Number, '^[^(0-9)]{2}');

        IF l_Doc_Ser IS NOT NULL
        THEN
            l_Doc_Num := LTRIM (l_Doc_Number, l_Doc_Ser);
        ELSE
            l_Doc_Num := TRIM (l_Doc_Number);
        END IF;

        IF    l_Birth_Dt IS NULL
           OR l_Doc_Number IS NULL
           OR l_Fn IS NULL
           OR l_Ln IS NULL
        THEN
            Tools.Add_Err (l_Doc_Number IS NULL,
                           ' серію та номер документа',
                           p_Error);
            Tools.Add_Err (l_Birth_Dt IS NULL, ' дату народження', p_Error);
            Tools.Add_Err (l_Ln IS NULL, ' прізвище', p_Error);
            Tools.Add_Err (l_Fn IS NULL, ' ім’я', p_Error);

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                       'Не вказано'
                    || RTRIM (p_Error, ',')
                    || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;
        END IF;



        Ikis_Rbm.Api$request_Mvs.Reg_Create_Pass_Req (
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
            p_Doc_Tp      => l_Ndt_Id, --Кодування в коди МВС відбувається в ikis_rbm
            p_Doc_Ser     => l_Doc_Ser,
            p_Doc_Num     => l_Doc_Num,
            p_Gender      => l_Gender, --Кодування в коди МВС відбувається в ikis_rbm
            p_Birthday    => l_Birth_Dt);

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Passport_Req: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до МВС для веріфікації документів
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Passport_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id          NUMBER;
        l_Ur_Create_Dt   DATE;
        l_Vf_Id          NUMBER;
        l_Ap_Id          NUMBER;
        l_App_Id         NUMBER;
        l_Apd_Id         NUMBER;
        l_Ndt_Id         NUMBER;
        l_Nda_Id         NUMBER;
        l_Answer         Ikis_Rbm.Api$request_Mvs.r_Mvs_Response;
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
            --Парсимо помилку
            l_Answer :=
                Ikis_Rbm.Api$request_Mvs.Parse_Create_Pass_Resp (
                    p_Response   => p_Response);

            IF    l_Answer.Result_Code =
                  Ikis_Rbm.Api$request_Mvs.c_Result_Person_Not_Found
               OR l_Answer.Error = 404
            THEN                                                    -- #106619
                p_Error := '&' || '371';
                Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
                RETURN;
            END IF;

            l_Ur_Create_Dt :=
                Ikis_Rbm.Api$uxp_Request.Get_Vrequest (p_Ur_Id => p_Ur_Id).Ur_Create_Dt;

            IF l_Ur_Create_Dt > SYSDATE - 3
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 20 * 60,
                    p_Delay_Reason    => p_Error);
            ELSE
                p_Error := 'Перевищено термін повторних спроб';
                Api$verification.Set_Tech_Error (l_Rn_Id, p_Error);
            END IF;

            RETURN;
        ELSIF TRIM (p_Response) IS NULL
        THEN
            p_Error := '&' || '111';
            Api$verification.Set_Tech_Error (l_Rn_Id, p_Error);
            RETURN;
        END IF;

        --Отриуюємо документу
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        SELECT Apd.Apd_Ndt, Apd.Apd_App, Apd.Apd_Ap
          INTO l_Ndt_Id, l_App_Id, l_Ap_Id
          FROM Ap_Document Apd
         WHERE Apd.Apd_Id = l_Apd_Id;

        UPDATE Ap_Document
           SET Apd_Vf = l_Vf_Id
         WHERE Apd_Id = l_Apd_Id;

        BEGIN
            --Парсимо відповідь
            l_Answer :=
                Ikis_Rbm.Api$request_Mvs.Parse_Create_Pass_Resp (
                    p_Response   => p_Response);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
                    'Помилка парсингу відповіді: ' || SQLERRM);
                RETURN;
        END;

        IF l_Answer.Result_Code =
           Ikis_Rbm.Api$request_Mvs.c_Result_Answer_Gived
        THEN
            p_Error :=
                CASE
                    WHEN     l_Answer.Result_Content = 'true'
                         AND l_Answer.Status = 'дійсний'
                    THEN
                        NULL                                              --OK
                    WHEN     l_Answer.Result_Content = 'true'
                         AND l_Answer.Status = 'недійсний'
                    THEN
                        '&' || '375'
                    WHEN     l_Answer.Result_Content = 'false'
                         AND l_Answer.Status = 'дійсний'
                    THEN
                        '&' || '376'
                    WHEN     l_Answer.Result_Content = 'false'
                         AND l_Answer.Status = 'недійсний'
                    THEN
                        '&' || '377'
                    ELSE
                           'Невідома відповідь. Код: '
                        || l_Answer.Result_Code
                        || ', Текст: '
                        || l_Answer.Result_Content
                        || ', Статус: '
                        || l_Answer.Status
                END;
        ELSE
            p_Error :=
                CASE
                    WHEN l_Answer.Result_Code =
                         Ikis_Rbm.Api$request_Mvs.c_Result_Person_Not_Found
                    THEN
                        '&' || '371'
                    WHEN l_Answer.Result_Code =
                         Ikis_Rbm.Api$request_Mvs.c_Result_Data_Not_Matched
                    THEN
                        '&' || '372'
                    WHEN l_Answer.Result_Code =
                         Ikis_Rbm.Api$request_Mvs.c_Result_Fields_Not_Filled
                    THEN
                        '&' || '373'
                    WHEN l_Answer.Result_Code =
                         Ikis_Rbm.Api$request_Mvs.c_Result_Other_Error
                    THEN
                        '&' || '374'
                    ELSE
                           'Невідома помилка. Код: '
                        || l_Answer.Result_Code
                        || ', Текст: '
                        || l_Answer.Error_Message
                END;
        END IF;

        IF p_Error IS NOT NULL
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
            RETURN;
        END IF;

        IF l_Answer.Unzr IS NOT NULL
        THEN
            --У випадку отримання від ДМС коду УНЗР (має приходити для біометрічних документів) записувати/перезаписувати у відпівідні атрибути:
            --для NDT_ID=7 атрибут NDA_ID=810
            --для NDT_ID=11 атрибут NDA_ID=5550
            l_Nda_Id :=
                CASE l_Ndt_Id WHEN 7 THEN 810 WHEN 11 THEN 5550 ELSE NULL END; --pt_id=462???

            IF l_Nda_Id IS NOT NULL
            THEN
                Api$appeal.Save_Attr (p_Apd_Id            => l_Apd_Id,
                                      p_Ap_Id             => l_Ap_Id,
                                      p_Apda_Nda          => l_Nda_Id,
                                      p_Apda_Val_String   => l_Answer.Unzr);
            END IF;
        END IF;

        Api$verification.Set_Ok (l_Vf_Id);
    END;
END Api$verification_Mvs;
/