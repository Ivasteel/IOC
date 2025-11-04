/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_MJU
IS
    -- Author  : SHOSTAK
    -- Created : 08.12.2022 1:37:32 PM
    -- Purpose :

    TYPE t_Char_Arr IS TABLE OF VARCHAR2 (10);

    FUNCTION Clear_Crt_Num (p_Doc_Num IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Reg_Verify_Birth_Certificate_Req (p_Rn_Nrt   IN     NUMBER,
                                               p_Obj_Id   IN     NUMBER,
                                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Certificate_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Death_Cert_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Death_Cert_Resp (p_Ur_Id      IN     NUMBER,
                                             p_Response   IN     CLOB,
                                             p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Cert_By_Birthday_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Birth_Cert_By_Name_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Cert_By_Name_Dt_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Nsp_Code_Link_Req (p_Rn_Nrt   IN     NUMBER,
                                           p_Obj_Id   IN     NUMBER,
                                           p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Nsp_Code_Link_Resp (p_Ur_Id      IN     NUMBER,
                                                p_Response   IN     CLOB,
                                                p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Verify_Nsp_Code_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Ar_By_Name_And_Birth_Date_Req (p_Rn_Nrt   IN     NUMBER,
                                                p_Obj_Id   IN     NUMBER,
                                                p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_App_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Apd_Ar_By_Rnokpp_Role1_Req (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Birth_Ar_Name_And_Birth_Date_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Birth_Ar_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Merriage_Ar_Name_And_Birth_Date_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Merriage_Ar_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                              p_Response   IN     CLOB,
                                              p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Divorce_Ar_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Change_Name_Ar_Rnokpp_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);
END Api$verification_Mju;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MJU TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_MJU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_MJU
IS
    FUNCTION Clear_Crt_Num (p_Doc_Num IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Doc_Num   VARCHAR2 (100);
    BEGIN
        l_Doc_Num := UPPER (TRIM (REPLACE (REPLACE (p_Doc_Num, '-'), ' ')));
        l_Doc_Num :=
               TRANSLATE (SUBSTR (l_Doc_Num, 1, 1), '1Il', 'ІІІ')
            || SUBSTR (l_Doc_Num, 2, LENGTH (l_Doc_Num));
        l_Doc_Num := TRANSLATE (l_Doc_Num, 'ABCIETOPHKXM', 'АВСІЕТОРНКХМ');
        RETURN l_Doc_Num;
    END;

    -----------------------------------------------------------------
    -- Збереження атрибутів свідоцтва про народження
    -----------------------------------------------------------------
    PROCEDURE Save_Birth_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Birth_Certificate)
    IS
        c_Nda_Birth_Child_Bith_Dt   CONSTANT NUMBER := 91;
        c_Nda_Birth_Child_Pib       CONSTANT NUMBER := 92;
        c_Nda_Birth_Mother_Pib      CONSTANT NUMBER := 679;
        c_Nda_Birth_Father_Pib      CONSTANT NUMBER := 680;
        c_Nda_Birth_Cert_Org        CONSTANT NUMBER := 93;
        c_Nda_Birth_Cert_Dt         CONSTANT NUMBER := 94;
        c_Nda_Az_Reg_Num            CONSTANT NUMBER := 3620;
        c_Nda_Az_Reg_Dt             CONSTANT NUMBER := 3619;

        l_Ap_Id                              NUMBER;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Birth_Child_Bith_Dt,
                              p_Apda_Val_Dt   => p_Cert.Child_Birthdate);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Child_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Child_Surname,
                     p_Cert.Child_Name,
                     p_Cert.Child_Patronymic));
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Mother_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Mother_Surname,
                     p_Cert.Mother_Name,
                     p_Cert.Mother_Patronymic));
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Father_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Father_Surname,
                     p_Cert.Father_Name,
                     p_Cert.Father_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Birth_Cert_Org,
                              p_Apda_Val_String   => p_Cert.Cert_Org);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Birth_Cert_Dt,
                              p_Apda_Val_Dt   => p_Cert.Cert_Date);

        --#91244
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Az_Reg_Num,
                              p_Apda_Val_String   => p_Cert.Ar_Numb);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Az_Reg_Dt,
            p_Apda_Val_Dt   =>
                Uss_Visit.Tools.Try_Parse_Dt (p_Cert.Ar_Composedate,
                                              'dd.mm.yyyy'));
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до НАІС для
    --     верифікації свідоцтва про народження
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Birth_Certificate_Req (p_Rn_Nrt   IN     NUMBER,
                                               p_Obj_Id   IN     NUMBER,
                                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_Doc_Number         VARCHAR2 (100);
        l_Child_Birth_Dt     DATE;
        l_Child_Pib          VARCHAR2 (250);
        l_Child_Surname      VARCHAR2 (250);
        l_Child_Name         VARCHAR2 (250);
        l_Child_Patronymic   VARCHAR2 (250);
    BEGIN
        l_Sc_Id := Api$appeal.Get_Doc_Owner_Sc (p_Obj_Id);

        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'DSN');
        l_Child_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');
        l_Child_Pib :=
            Api$appeal.Get_Attrp_Val_String (p_Apd_Id   => p_Obj_Id,
                                             p_Pt_Id    => 115);
        Split_Pib (l_Child_Pib,
                   l_Child_Surname,
                   l_Child_Name,
                   l_Child_Patronymic);

        IF    l_Child_Birth_Dt IS NULL
           OR l_Child_Surname IS NULL
           OR l_Child_Name IS NULL
           OR l_Child_Patronymic IS NULL
           OR l_Doc_Number IS NULL
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_Doc_Number IS NULL
        THEN
            p_Error := p_Error || ' серію та номер документа,';
        END IF;

        IF l_Child_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження дитини,';
        END IF;

        IF l_Child_Surname IS NULL
        THEN
            p_Error := p_Error || ' прізвище дитини,';
        END IF;

        IF l_Child_Name IS NULL
        THEN
            p_Error := p_Error || ' ім’я дитини,';
        END IF;

        IF l_Child_Patronymic IS NULL
        THEN
            p_Error := p_Error || ' по батькові дитини,';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Birth_Ar_By_Child_Name_And_Birth_Date_Req (
            p_Sc_Id              => l_Sc_Id,
            p_Child_Birth_Dt     => l_Child_Birth_Dt,
            p_Child_Surname      => l_Child_Surname,
            p_Child_Name         => l_Child_Name,
            p_Child_Patronymic   => l_Child_Patronymic,
            p_Rn_Nrt             => p_Rn_Nrt,
            p_Rn_Hs_Ins          => NULL,
            p_Rn_Src             => Api$appeal.c_Src_Vst,
            p_Rn_Id              => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Birth_Certificate_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Реєстрація первинного запиту до МЮУ для
    --     верифікації коду НСП
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Nsp_Code_Link_Req (p_Rn_Nrt   IN     NUMBER,
                                           p_Obj_Id   IN     NUMBER,
                                           p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id        NUMBER;
        l_Rn_Src       Appeal.Ap_Src%TYPE;
        l_Apd_Id       Ap_Document.Apd_Id%TYPE := p_Obj_Id;
        l_Inn          VARCHAR2 (12);
        l_Name         VARCHAR2 (500);
        l_Doc_Number   VARCHAR2 (100);
        l_Doc_Ser      VARCHAR2 (100);
        l_Doc_Num      VARCHAR2 (100);
    BEGIN
        --p_Obj_Id - це ІД документу
        SELECT Ap_Src
          INTO l_Rn_Src
          FROM Appeal Ap JOIN Ap_Document Apd ON Ap.Ap_Id = Apd.Apd_Ap
         WHERE Apd.Apd_Id = p_Obj_Id;

        SELECT Apda.Apda_Val_String
          INTO l_Inn
          FROM Ap_Document_Attr Apda
         WHERE Apda.Apda_Apd = l_Apd_Id AND Apda.Apda_Nda = 955;

        SELECT Apda.Apda_Val_String
          INTO l_Name
          FROM Ap_Document_Attr Apda
         WHERE Apda.Apda_Apd = l_Apd_Id AND Apda.Apda_Nda = 956;

        SELECT Apda.Apda_Val_String
          INTO l_Doc_Number
          FROM Ap_Document_Attr Apda
         WHERE Apda.Apda_Apd = l_Apd_Id AND Apda.Apda_Nda = 961;

        l_Doc_Ser := REGEXP_SUBSTR (l_Doc_Number, '^[^(0-9)]{2}');
        l_Doc_Num := LTRIM (l_Doc_Number, l_Doc_Ser);

        Ikis_Rbm.Api$request_Mju.Reg_Nsp_Mju_Data_Link_Req (
            p_Plan_Dt     => SYSDATE,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => l_Rn_Src,
            p_Rn_Id       => l_Rn_Id,
            p_Numident    => l_Inn,
            p_Fn          => l_Name,
            p_Doc_Ser     => l_Doc_Ser,
            p_Doc_Num     => l_Doc_Num);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Nsp_Code_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;


    -----------------------------------------------------------------
    --         Обробка відповіді на запит до НАІС для
    --     верифікації свідоцтва про народження
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Birth_Certificate_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Vf_Id              NUMBER;
        l_Apd_Id             NUMBER;
        l_Doc_Number         VARCHAR2 (100);
        l_Ar_Cnt             NUMBER := 0;
        l_Cert_Cnt           NUMBER := 0;
        l_Result_Code        VARCHAR2 (10);
        l_Result_Data        CLOB;
        l_Response_Payload   CLOB;
        l_Error_Info         CLOB;
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

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);
        --Отримуємо серію та номер документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                            p_Nda_Class   => 'DSN');

                --Парсимо основну інформацію з відповіді
                SELECT Result_Code, Result_Data, Error_Info
                  INTO l_Result_Code, l_Result_Data, l_Error_Info
                  FROM XMLTABLE (
                           '/*'
                           PASSING Xmltype (p_Response)
                           COLUMNS Result_Code    VARCHAR2 (10) PATH 'ResultCode',
                                   Result_Data    CLOB PATH 'ResultData',
                                   Error_Info     CLOB PATH 'ErrorInfo');

        IF l_Result_Code = '0'
        THEN
            --Декодуємо перелік актових записів
            l_Response_Payload :=
                CONVERT (Tools.B64_Decode (l_Result_Data),
                         'CL8MSWIN1251',
                         'UTF8');

            --Парсимо актові записи
            FOR Act_Rec
                IN (        SELECT Cerificates
                              FROM XMLTABLE (
                                       '/*/*'
                                       PASSING Xmltype (l_Response_Payload)
                                       COLUMNS Cerificates    XMLTYPE PATH 'CERTIFICATES'))
            LOOP
                l_Ar_Cnt := l_Ar_Cnt + 1;

                               --Шукаємо свідоцтво за серією та номером
                               SELECT COUNT (*)
                                 INTO l_Cert_Cnt
                                 FROM XMLTABLE (
                                          '/*/*'
                                          PASSING Act_Rec.Cerificates
                                          COLUMNS Cert_Serial           VARCHAR2 (10) PATH 'CertSerial',
                                                  Cert_Number           VARCHAR2 (11) PATH 'CertNumber',
                                                  Cert_Serial_Number    VARCHAR2 (21) PATH 'CertSerialNumber')
                                WHERE NVL (Cert_Serial || Cert_Number,
                                           Cert_Serial_Number) =
                                      l_Doc_Number;

                IF l_Cert_Cnt > 0
                THEN
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id    => l_Vf_Id,
                        p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   =>
                            'Підтверджено наявність документа в реєстрі АЗ');
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$verification.Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END LOOP;

            IF l_Ar_Cnt = 0
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (l_Vf_Id,
                                                   CHR (38) || '108');
                RETURN;
            END IF;

            IF l_Cert_Cnt = 0
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    'Свідоцтво про народження в актових записах не знайдено');
            END IF;
        ELSE
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            Api$verification.Set_Not_Verified (l_Vf_Id, l_Error_Info);
        END IF;
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до МЮУ для
    --     верифікації кода НСП
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Nsp_Code_Link_Resp (p_Ur_Id      IN     NUMBER,
                                                p_Response   IN     CLOB,
                                                p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Vf_Id              NUMBER;
        l_Result_Code        VARCHAR2 (10);
        l_Result_Data        CLOB;
        l_Response_Payload   CLOB;
        l_Error_Info         CLOB;
        l_Id                 VARCHAR2 (250);
        l_Code               VARCHAR2 (250);
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            l_Code :=
                Ikis_Rbm.Api$request.Get_Rn_Common_Info_String (
                    l_Rn_Id,
                    Ikis_Rbm.Api$request_Mju.c_Pt_Rnokpp);

            IF l_Code IS NULL
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => p_Error);
            END IF;
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        IF (l_Vf_Id IS NULL)
        THEN
            Ikis_Rbm.Api$uxp_Request.Save_Request_Response (
                p_Ur_Rn          => l_Rn_Id,
                p_Ur_Soap_Resp   => p_Response);
            COMMIT;
        END IF;

        --Парсимо основну інформацію з відповіді
        BEGIN
            SELECT Id, Code
              INTO l_Id, l_Code
              FROM (SELECT Id,
                           Code,
                           COUNT (1) OVER ()     Qty,
                           ROWNUM                Rn
                      FROM JSON_TABLE (
                               p_Response,
                               '$[*]'
                               COLUMNS (Id VARCHAR2 (250) PATH '$.id',
                                        Code VARCHAR2 (250) PATH '$.code',
                                        State VARCHAR2 (250) PATH '$.state')))
             WHERE Qty = Rn;


            Ikis_Rbm.Api$request_Mju.Reg_Nsp_Mju_Data_Req (
                p_Url_Parent   => p_Ur_Id,
                p_Rn_Nrt       => 80,
                p_Rn_Hs_Ins    => Ikis_Rbm.Tools.Gethistsession,
                p_Rn_Src       => Api$appeal.c_Src_Vst,
                p_Rn_Id        => l_Rn_Id,
                p_Edr_Id       => l_Id);
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Api$verification.Set_Not_Verified (l_Vf_Id,
                                                   'Дані в ЄДР не знайдено');
        END;
    END;

    PROCEDURE Handle_Verify_Nsp_Code_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id   NUMBER;
        l_Vf_Id   NUMBER;
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

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        IF (l_Vf_Id IS NULL)
        THEN
            Ikis_Rbm.Api$uxp_Request.Save_Request_Response (
                p_Ur_Rn          => l_Rn_Id,
                p_Ur_Soap_Resp   => p_Response);
            COMMIT;
        END IF;
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до НАІС для
    --     верифікації АЗ про смерть
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Death_Cert_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        --PRAGMA AUTONOMOUS_TRANSACTION;
        l_Rn_Id        NUMBER;
        l_Sc_Id        NUMBER;
        l_Doc_Number   VARCHAR2 (100);
        l_Birth_Dt     DATE;
        l_Pib          VARCHAR2 (250);
        l_Surname      VARCHAR2 (250);
        l_Name         VARCHAR2 (250);
        l_Patronymic   VARCHAR2 (250);
    BEGIN
        l_Sc_Id := Api$appeal.Get_Doc_Owner_Sc (p_Obj_Id);

        --Зчитуємо атрибути документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'DSN');
        l_Pib :=
            Api$appeal.Get_Attrp_Val_String (p_Apd_Id   => p_Obj_Id,
                                             p_Pt_Id    => 176);
        l_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');
        Split_Pib (l_Pib,
                   l_Surname,
                   l_Name,
                   l_Patronymic);

        IF    l_Birth_Dt IS NULL
           OR l_Surname IS NULL
           OR l_Name IS NULL
           OR l_Patronymic IS NULL
           OR l_Doc_Number IS NULL
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_Doc_Number IS NULL
        THEN
            p_Error := p_Error || ' серію та номер документа,';
        END IF;

        IF l_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження померлого,';
        END IF;

        IF l_Surname IS NULL
        THEN
            p_Error := p_Error || ' прізвище померлого,';
        END IF;

        IF l_Name IS NULL
        THEN
            p_Error := p_Error || ' ім’я померлого,';
        END IF;

        IF l_Patronymic IS NULL
        THEN
            p_Error := p_Error || ' по батькові померлого,';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Death_Ar_By_Full_Name_And_Birth_Date_Req (
            p_Sc_Id        => l_Sc_Id,
            p_Birth_Dt     => l_Birth_Dt,
            p_Surname      => Clear_Name (l_Surname),
            p_Name         => Clear_Name (l_Name),
            p_Patronymic   => Clear_Name (l_Patronymic),
            p_Rn_Nrt       => p_Rn_Nrt,
            p_Rn_Hs_Ins    => NULL,
            p_Rn_Src       => Api$appeal.c_Src_Vst,
            p_Rn_Id        => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Death_Cert_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Збереження атрибутів свідоцтва про смерть
    -----------------------------------------------------------------
    PROCEDURE Save_Death_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Ar       IN Ikis_Rbm.Api$request_Mju.r_Death_Act_Record,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Death_Cert)
    IS
        c_Nda_Ar_Reg_Num   CONSTANT NUMBER := 218;
        c_Nda_Ar_Reg_Dt    CONSTANT NUMBER := 221;
        c_Nda_Cert_Dt      CONSTANT NUMBER := 219;
        c_Nda_Cert_Org     CONSTANT NUMBER := 807;
        c_Nda_Death_Dt     CONSTANT NUMBER := 222;

        l_Ap_Id                     NUMBER;
        l_Dt                        DATE;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);

        IF     p_Ar.Ar_Reg_Date IS NOT NULL
           AND p_Ar.Ar_Reg_Date < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Ar_Reg_Date ' || p_Ar.Ar_Reg_Date);
        END IF;

        l_Dt := Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy');

        IF l_Dt IS NOT NULL AND l_Dt < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Cert_Date ' || p_Cert.Cert_Date);
        END IF;

        l_Dt := Tools.Try_Parse_Dt (p_Ar.Date_Death, 'dd.mm.yyyy');

        IF l_Dt IS NOT NULL AND l_Dt < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Date_Death ' || p_Ar.Date_Death);
        END IF;

        --#Джерело для c_Nda_Ar_Reg_Num змінено по задачі #100488
        --Api$appeal.Save_Attr(p_Apd_Id, l_Ap_Id, c_Nda_Ar_Reg_Num, p_Apda_Val_String => p_Ar.Ar_Reg_Number);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Num,
                              p_Apda_Val_String   => p_Ar.Reg_Numb);
        --Api$appeal.Save_Attr(p_Apd_Id, l_Ap_Id, c_Nda_Ar_Reg_Dt, p_Apda_Val_Dt => Tools.Try_Parse_Dt(p_Ar.Ar_Reg_Date, 'dd.mm.yyyy'));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Dt,
                              p_Apda_Val_Dt   => p_Ar.Ar_Reg_Date); -- #100611
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Dt,
            p_Apda_Val_Dt   =>
                Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy'));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Cert_Org,
                              p_Apda_Val_String   => p_Cert.Cert_Org);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Death_Dt,
            p_Apda_Val_Dt   =>
                Tools.Try_Parse_Dt (p_Ar.Date_Death, 'dd.mm.yyyy'));
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до НАІС для
    --     верифікації АЗ про смерть
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Death_Cert_Resp (p_Ur_Id      IN     NUMBER,
                                             p_Response   IN     CLOB,
                                             p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_Doc_Number    VARCHAR2 (100);
        l_Result_Code   NUMBER;
        l_Error_Info    CLOB;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Death_Act_Record_List;
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            IF p_Error LIKE '%Could not connect to any target host%'
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
                    'Сервіс тимчасово недоступний');
                RETURN;
            END IF;

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
        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);
        --Отримуємо серію та номер документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                            p_Nda_Class   => 'DSN');

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
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
                    END));
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Api$verification.Set_Not_Verified (l_Vf_Id, CHR (38) || '108');
            RETURN;
        END IF;

        --Шукаємо свідоцтво про смерть в ортиманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            IF l_Ar_List (i).Certificates IS NULL
            THEN
                CONTINUE;
            END IF;

            DECLARE
                l_Certs   Ikis_Rbm.Api$request_Mju.t_Death_Cert_List;
            BEGIN
                SELECT *
                  BULK COLLECT INTO l_Certs
                  FROM TABLE (l_Ar_List (i).Certificates)
                 WHERE Clear_Crt_Num (Cert_Serial || Cert_Number) =
                       Clear_Crt_Num (l_Doc_Number);

                IF l_Certs.COUNT > 1
                THEN
                    --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                    Api$verification.Set_Not_Verified (
                        l_Vf_Id,
                           'Знайдено декілька свідоцтв з номером '
                        || l_Doc_Number);
                    RETURN;
                ELSIF l_Certs.COUNT = 1
                THEN
                    --Зберігаємо атрибути свідоцтва
                    Save_Death_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                           p_Ar       => l_Ar_List (i),
                                           p_Cert     => l_Certs (1));
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$verification.Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END;
        END LOOP;

        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        Api$verification.Set_Not_Verified (l_Vf_Id, CHR (38) || '109');
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на верифікацію свідоцтва про народження
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_Cert_Serial        VARCHAR2 (10);
        l_Cert_Number        VARCHAR2 (50);
        l_Child_Birth_Dt     DATE;
        l_Child_Pib          VARCHAR2 (250);
        l_Child_Surname      VARCHAR2 (250);
        l_Child_Name         VARCHAR2 (250);
        l_Child_Patronymic   VARCHAR2 (250);
    BEGIN
        IF Api$verification.Skip_Vf_By_Src (p_Apd_Id => p_Obj_Id)
        THEN
            RETURN NULL;
        END IF;

        l_Cert_Number :=
            NVL (
                p_Cert_Number,
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                                p_Nda_Class   => 'DSN'));

        IF l_Cert_Number IS NOT NULL
        THEN
            l_Cert_Serial :=
                SUBSTR (l_Cert_Number, 1, LENGTH (l_Cert_Number) - 6);
            l_Cert_Number :=
                SUBSTR (l_Cert_Number, LENGTH (l_Cert_Number) - 5, 6);
        END IF;

        l_Child_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');
        l_Child_Pib :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'PIB');
        Split_Pib (l_Child_Pib,
                   l_Child_Surname,
                   l_Child_Name,
                   l_Child_Patronymic);

        IF    l_Cert_Serial IS NULL
           OR l_Cert_Number IS NULL
           OR (    l_Child_Birth_Dt IS NULL
               AND (l_Child_Name IS NULL OR l_Child_Surname IS NULL))
        THEN
            p_Error := 'Не вказано';
            Tools.Add_Err (l_Cert_Serial IS NULL, 'серію документа', p_Error);
            Tools.Add_Err (l_Cert_Number IS NULL, 'номер документа', p_Error);
            Tools.Add_Err (l_Child_Birth_Dt IS NULL,
                           'дату народження дитини',
                           p_Error);
            Tools.Add_Err (l_Child_Surname IS NULL,
                           'прізвище дитини',
                           p_Error);
            Tools.Add_Err (l_Child_Name IS NULL, 'ім’я дитини', p_Error);
            Tools.Add_Err (l_Cert_Number IS NULL, 'номер документа', p_Error);
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        l_Sc_Id := Api$appeal.Get_Doc_Owner_Sc (p_Obj_Id);

        IF l_Child_Birth_Dt IS NOT NULL
        THEN
            Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Birth_Date_Req (
                p_Cert_Tp       => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                p_Cert_Role     => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                p_Cert_Serial   => l_Cert_Serial,
                p_Cert_Number   => l_Cert_Number,
                p_Date_Birth    => l_Child_Birth_Dt,
                p_Sc_Id         => l_Sc_Id,
                p_Rn_Nrt        => p_Rn_Nrt,
                p_Rn_Hs_Ins     => NULL,
                p_Rn_Src        => Api$appeal.c_Src_Vst,
                p_Rn_Id         => l_Rn_Id);
        ELSE
            Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Names_Req (
                p_Cert_Tp       => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                p_Cert_Role     => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                p_Cert_Serial   => l_Cert_Serial,
                p_Cert_Number   => l_Cert_Number,
                p_Surname       => l_Child_Surname,
                p_Name          => l_Child_Name,
                p_Patronymic    => l_Child_Patronymic,
                p_Sc_Id         => l_Sc_Id,
                p_Rn_Nrt        => 27,        --todo: додати поле nvt_nrt_alt?
                p_Rn_Hs_Ins     => NULL,
                p_Rn_Src        => Api$appeal.c_Src_Vst,
                p_Rn_Id         => l_Rn_Id);
        END IF;

        RETURN l_Rn_Id;
    END;

    FUNCTION Get_Cert_Seria_Variants (p_Except IN VARCHAR2 DEFAULT NULL)
        RETURN t_Char_Arr
    IS
        l_Cert_Seria_Variants   VARCHAR2 (20) := '"I","І","1","l",';
        l_Result                t_Char_Arr;
    BEGIN
        IF p_Except IS NOT NULL
        THEN
            l_Cert_Seria_Variants :=
                REPLACE (l_Cert_Seria_Variants, '"' || p_Except || '",');
        END IF;

        l_Cert_Seria_Variants := RTRIM (l_Cert_Seria_Variants, ',');

        SELECT (COLUMN_VALUE).Getstringval ()     AS Letter
          BULK COLLECT INTO l_Result
          FROM XMLTABLE (l_Cert_Seria_Variants);

        RETURN l_Result;
    END;

    PROCEDURE Decline_For_Diia (p_Vf_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        l_Ap_Id := Api$verification.Get_Vf_Ap (p_Vf_Id);

        IF Api$appeal.Get_Ap_Src (l_Ap_Id) IN ('DIIA', 'DRACS')
        THEN
            UPDATE Appeal
               SET Ap_St = 'X'
             WHERE Ap_Id = l_Ap_Id AND Ap_St = 'VW';

            IF SQL%ROWCOUNT > 0
            THEN
                Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                                      p_Apl_Hs        => Tools.Gethistsession,
                                      p_Apl_St        => 'X',
                                      p_Apl_Message   => p_Reason,
                                      p_Apl_St_Old    => 'VW');

                --Формуємо рішення про відмову
                Dnet$appeal_Ext.Create_Decision_Doc (
                    p_Ap_Id   => l_Ap_Id,
                    p_Refuse_Reason   =>
                        Uss_Ndi.Rdm$msg_Template.Getmessagetext (p_Reason));
                --Реєструємо запит на передачу статуса до Дії
                Dnet$appeal_Ext.Reg_Diia_Status_Send_Req (
                    p_Ap_Id         => l_Ap_Id,
                    p_Ap_St         => 'X',
                    p_Message       => p_Reason,
                    p_Decision_Dt   => SYSDATE);
                --Реєструємо запит на передачу статуса до ДРАЦС
                Dnet$exch_Mju.Reg_Dracs_Application_Result_Req (
                    p_Ap_Id     => l_Ap_Id,
                    p_Ap_St     => 'X',
                    p_Message   => p_Reason);
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит
    -- щодо верифікації свідоцтва про народження(за датою народження)
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Birth_Cert_By_Birthday_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id                 NUMBER;
        l_Vf_Id                 NUMBER;
        l_Apd_Id                NUMBER;
        l_Cert_Number           VARCHAR2 (4000);
        l_Cert_Seria_Variants   t_Char_Arr;
        l_Req_Cnt               NUMBER;
        l_First_Letter          VARCHAR2 (1);
        l_Cert_List             Ikis_Rbm.Api$request_Mju.t_Birth_Cert_List;
        l_Cert                  Ikis_Rbm.Api$request_Mju.r_Birth_Certificate;
        l_Error_Info            VARCHAR2 (4000);
        l_Result_Code           NUMBER;
        l_Child_Pib             VARCHAR2 (250);
    BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            IF p_Error LIKE '%Could not connect to any target host%'
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
                    'Сервіс тимчасово недоступний');
                RETURN;
            END IF;

            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
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

        BEGIN
            --Парсимо відповідь
            l_Cert_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Birth_Cert_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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

        IF NVL (l_Result_Code, -1) <>
           Ikis_Rbm.Api$request_Mju.c_Result_Code_Ok
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
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
                               'Некоректні параметри запиту. Код відповіді'
                            || l_Result_Code
                    END));

            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            RETURN;
        END IF;

        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        IF l_Cert_List.COUNT = 0
        THEN
            --Отримуємо номер документа
            l_Cert_Number :=
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'DSN');
            --Отримуємо можливі варіанти першої літери в серії свідоцтва
            l_Cert_Seria_Variants := Get_Cert_Seria_Variants;

            --Якщо серія свідоцтва починається з літери, яка має різні варіації
            IF SUBSTR (l_Cert_Number, 1, 1) MEMBER OF l_Cert_Seria_Variants
            THEN
                --Отримуємо кількість запитів здійснених в рамках цієї верифікації
                l_Req_Cnt :=
                    Api$verification.Get_Vf_Req_Cnt (p_Vf_Id    => l_Vf_Id,
                                                     p_Rn_Nrt   => 26);

                --Якщо кількість запитів менша кількості варіантів першої літери св-ва
                IF l_Req_Cnt < l_Cert_Seria_Variants.COUNT
                THEN
                    --Видаляємо з переліку варіантів фактичну першу літеру вказану у серії св-ва
                    l_Cert_Seria_Variants :=
                        Get_Cert_Seria_Variants (
                            p_Except   => SUBSTR (l_Cert_Number, 1, 1));
                    --Визначаємо літеру, яка буде використана у якості підміни фактичної, для відправки наступного запиту
                    l_First_Letter := l_Cert_Seria_Variants (l_Req_Cnt);
                    --Підміняємо першу літеру у серії св-ва
                    l_Cert_Number :=
                           l_First_Letter
                        || SUBSTR (l_Cert_Number, 2, LENGTH (l_Cert_Number));
                    --Реєструємо запит за параметрами: серія та номер св-ва + ДР, з підміною першої літери в серії св-ва
                    l_Rn_Id :=
                        Reg_Verify_Birth_Cert_By_Bitrhday_Req (
                            p_Rn_Nrt        => 26,
                            p_Obj_Id        => l_Apd_Id,
                            p_Error         => p_Error,
                            p_Cert_Number   => l_Cert_Number);

                    --Якщо з якихось причин не вийшло зареєструвати запит
                    IF l_Rn_Id IS NULL
                    THEN
                        --НЕУСПІШНА ВЕРИФІКАЦІЯ
                        Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
                        Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
                    ELSE
                        --Привязуємо запит до верифікації
                        Api$verification.Link_Request2verification (
                            p_Vfa_Vf   => l_Vf_Id,
                            p_Vfa_Rn   => l_Rn_Id);
                        Api$verification.Write_Vf_Log (
                            p_Vf_Id    => l_Vf_Id,
                            p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                            p_Vfl_Message   =>
                                CHR (38) || '142#' || l_Cert_Number);
                    END IF;

                    RETURN;
                END IF;
            END IF;

            /* 11/07/2024 serhii: #105123 Відключення верифікації свідоцтва про народження за ПІБ та серію номером свідоцтва
            --Реєструємо запит за параметрами: серія та номер св-ва + ПІБ
            l_Rn_Id := Reg_Verify_Birth_Cert_By_Name_Req(p_Rn_Nrt => 27, --todo: додати поле nvt_nrt_alt?
                                                         p_Obj_Id => l_Apd_Id,
                                                         p_Error  => p_Error);
             #105123   */

            l_Rn_Id := NULL;              --  added 11/07/2024 serhii: #105123

            IF l_Rn_Id IS NULL
            THEN
                Api$verification.Set_Not_Verified (l_Vf_Id,
                                                   CHR (38) || '114');
                Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            ELSE
                Api$verification.Link_Request2verification (
                    p_Vfa_Vf   => l_Vf_Id,
                    p_Vfa_Rn   => l_Rn_Id);
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '143#' || l_Cert_Number);
            END IF;

            RETURN;
        END IF;

        --Отримуємо ПІБ дитини
        l_Child_Pib :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                            p_Nda_Class   => 'PIB');

        IF l_Child_Pib IS NULL AND l_Cert_List.COUNT > 1
        THEN
            Api$verification.Set_Not_Verified (l_Vf_Id, CHR (38) || '115');
            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            RETURN;
        END IF;

          SELECT c.*
            INTO l_Cert
            FROM TABLE (l_Cert_List) c
        ORDER BY UTL_MATCH.Edit_Distance_Similarity (
                     UPPER (Child_Surname || Child_Name || Child_Patronymic),
                     UPPER (REPLACE (l_Child_Pib, ' '))) DESC
           FETCH FIRST ROW ONLY;

        IF     l_Child_Pib IS NOT NULL
           AND REPLACE (
                   UPPER (
                          l_Cert.Child_Surname
                       || l_Cert.Child_Name
                       || l_Cert.Child_Patronymic),
                   ' ') <>
               UPPER (REPLACE (l_Child_Pib, ' '))
        THEN
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
                   'ПІБ дитини у свідоцтві('
                || UPPER (l_Child_Pib)
                || ') не відповідає ПІБ дитини в ДРАЦС('
                || Pib (l_Cert.Child_Surname,
                        l_Cert.Child_Name,
                        l_Cert.Child_Patronymic)
                || ')');
            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            RETURN;
        END IF;

        --Зберігаємо атрибути свідоцтва
        Save_Birth_Cert_Attrs (p_Apd_Id => l_Apd_Id, p_Cert => l_Cert);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$verification.Set_Ok (l_Vf_Id);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на верифікацію свідоцтва про народження
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Birth_Cert_By_Name_Req (
        p_Rn_Nrt        IN     NUMBER,
        p_Obj_Id        IN     NUMBER,
        p_Error            OUT VARCHAR2,
        p_Cert_Number   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_Cert_Serial        VARCHAR2 (10);
        l_Cert_Number        VARCHAR2 (50);
        l_Child_Pib          VARCHAR2 (250);
        l_Child_Surname      VARCHAR2 (250);
        l_Child_Name         VARCHAR2 (250);
        l_Child_Patronymic   VARCHAR2 (250);
    BEGIN
        l_Cert_Number :=
            NVL (
                p_Cert_Number,
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                                p_Nda_Class   => 'DSN'));

        IF l_Cert_Number IS NOT NULL
        THEN
            l_Cert_Serial :=
                SUBSTR (l_Cert_Number, 1, LENGTH (l_Cert_Number) - 6);
            l_Cert_Number :=
                SUBSTR (l_Cert_Number, LENGTH (l_Cert_Number) - 5, 6);
        END IF;

        l_Child_Pib :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'PIB');
        Split_Pib (l_Child_Pib,
                   l_Child_Surname,
                   l_Child_Name,
                   l_Child_Patronymic);

        IF    l_Cert_Serial IS NULL
           OR l_Cert_Number IS NULL
           OR l_Child_Name IS NULL
           OR l_Child_Surname IS NULL
        THEN
            p_Error := 'Не вказано';
            Tools.Add_Err (l_Cert_Serial IS NULL, 'серію документа', p_Error);
            Tools.Add_Err (l_Cert_Number IS NULL, 'номер документа', p_Error);
            Tools.Add_Err (l_Child_Surname IS NULL,
                           'прізвище дитини',
                           p_Error);
            Tools.Add_Err (l_Child_Name IS NULL, 'ім’я дитини', p_Error);
            Tools.Add_Err (l_Cert_Number IS NULL, 'номер документа', p_Error);
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        l_Sc_Id := Api$appeal.Get_Doc_Owner_Sc (p_Obj_Id);

        Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Names_Req (
            p_Cert_Tp       => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
            p_Cert_Role     => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
            p_Cert_Serial   => l_Cert_Serial,
            p_Cert_Number   => l_Cert_Number,
            p_Surname       => l_Child_Surname,
            p_Name          => l_Child_Name,
            p_Patronymic    => l_Child_Patronymic,
            p_Sc_Id         => l_Sc_Id,
            p_Rn_Nrt        => p_Rn_Nrt,
            p_Rn_Hs_Ins     => NULL,
            p_Rn_Src        => Api$appeal.c_Src_Vst,
            p_Rn_Id         => l_Rn_Id);
        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит
    -- щодо верифікації свідоцтва про народження(за ПІБ)
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Birth_Cert_By_Name_Dt_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id                 NUMBER;
        l_Vf_Id                 NUMBER;
        l_Apd_Id                NUMBER;
        l_Cert_Number           VARCHAR2 (4000);
        l_Cert_Seria_Variants   t_Char_Arr;
        l_Req_Cnt               NUMBER;
        l_First_Letter          VARCHAR2 (1);
        l_Cert_List             Ikis_Rbm.Api$request_Mju.t_Birth_Cert_List;
        l_Cert                  Ikis_Rbm.Api$request_Mju.r_Birth_Certificate;
        l_Error_Info            VARCHAR2 (4000);
        l_Result_Code           NUMBER;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        BEGIN
            --Парсимо відповідь
            l_Cert_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Birth_Cert_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
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
                               'Некоректні параметри запиту. Код відповіді'
                            || l_Result_Code
                    END));
            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            RETURN;
        END IF;

        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        IF l_Cert_List.COUNT = 0
        THEN
            --Отримуємо номер документа
            l_Cert_Number :=
                Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                                p_Nda_Class   => 'DSN');
            --Отримуємо можливі варіанти першої літери в серії свідоцтва
            l_Cert_Seria_Variants := Get_Cert_Seria_Variants;

            --Якщо серія свідоцтва починається з літери, яка має різні варіації
            IF SUBSTR (l_Cert_Number, 1, 1) MEMBER OF l_Cert_Seria_Variants
            THEN
                --Отримуємо кількість запитів здійснених в рамках цієї верифікації
                l_Req_Cnt :=
                    Api$verification.Get_Vf_Req_Cnt (p_Vf_Id    => l_Vf_Id,
                                                     p_Rn_Nrt   => 27);

                --Якщо кількість запитів менша кількості варіантів першої літери св-ва
                IF l_Req_Cnt < l_Cert_Seria_Variants.COUNT
                THEN
                    --Видаляємо з переліку варіантів фактичну першу літеру вказану у серії св-ва
                    l_Cert_Seria_Variants :=
                        Get_Cert_Seria_Variants (
                            p_Except   => SUBSTR (l_Cert_Number, 1, 1));
                    --Визначаємо літеру, яка буде використана у якості підміни фактичної, для відправки наступного запиту
                    l_First_Letter := l_Cert_Seria_Variants (l_Req_Cnt);
                    --Підміняємо першу літеру у серії св-ва
                    l_Cert_Number :=
                           l_First_Letter
                        || SUBSTR (l_Cert_Number, 2, LENGTH (l_Cert_Number));
                    --Реєструємо запит з підміною першої літери в серії св-ва
                    l_Rn_Id :=
                        Reg_Verify_Birth_Cert_By_Name_Req (
                            p_Rn_Nrt        => 27,
                            p_Obj_Id        => l_Apd_Id,
                            p_Error         => p_Error,
                            p_Cert_Number   => l_Cert_Number);

                    --Якщо з якихось причин не вийшло зареєструвати запит
                    IF l_Rn_Id IS NULL
                    THEN
                        --НЕУСПІШНА ВЕРИФІКАЦІЯ
                        Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
                        Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
                    ELSE
                        --Привязуємо запит до верифікації
                        Api$verification.Link_Request2verification (
                            p_Vfa_Vf   => l_Vf_Id,
                            p_Vfa_Rn   => l_Rn_Id);
                        Api$verification.Write_Vf_Log (
                            p_Vf_Id    => l_Vf_Id,
                            p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                            p_Vfl_Message   =>
                                CHR (38) || '143#' || l_Cert_Number);
                    END IF;

                    RETURN;
                END IF;
            END IF;

            Api$verification.Set_Not_Verified (l_Vf_Id, CHR (38) || '114');
            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            RETURN;
        END IF;

        SELECT c.*
          INTO l_Cert
          FROM TABLE (l_Cert_List) c
         FETCH FIRST ROW ONLY;

        /*
        --Закоментовано 26.01.2023, узгоджено з О.Зиновець
        --Отримуємо дату народження дитини
        l_Child_Birth_Dt := Api$appeal.Get_Attr_Val_Dt(p_Apd_Id => l_Apd_Id, p_Nda_Class => 'BDT');
        IF l_Child_Birth_Dt IS NOT NULL
           AND Trunc(l_Cert.Child_Birthdate) <> Trunc(l_Child_Birth_Dt) THEN
          Api$verification.Set_Not_Verified(l_Vf_Id,
                                            'Дата народження дитини у свідоцтві(' || To_Char(l_Child_Birth_Dt, 'dd.mm.yyyy') ||
                                            ') не відповідає даті народження в ДРАЦС(' ||
                                            To_Char(l_Cert.Child_Birthdate, 'dd.mm.yyyy') || ')');
          RETURN;
        END IF;*/

        --Зберігаємо атрибути свідоцтва
        Save_Birth_Cert_Attrs (p_Apd_Id => l_Apd_Id, p_Cert => l_Cert);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$verification.Set_Ok (l_Vf_Id);
    END;

    -----------------------------------------------------------------
    -- Реєстрація запиту для верифікації та отримання інформації
    -- АЗ(актового запису) за ПІБ та датою народження
    -----------------------------------------------------------------
    FUNCTION Reg_Ar_By_Name_And_Birth_Date_Req (p_Rn_Nrt   IN     NUMBER,
                                                p_Obj_Id   IN     NUMBER,
                                                p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id        NUMBER;
        l_App_Id       NUMBER;
        l_Sc_Id        NUMBER;
        l_Name         VARCHAR2 (250);
        l_Surname      VARCHAR2 (250);
        l_Patronymic   VARCHAR2 (250);
        l_Birth_Dt     DATE;
    BEGIN
        SELECT p.App_Id,
               p.App_Sc,
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'FN'),
                   p.App_Fn),
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'LN'),
                   p.App_Ln),
               NVL (
                   Api$appeal.Get_Attr_Val_String (p_Apd_Id      => d.Apd_Id,
                                                   p_Nda_Class   => 'MN'),
                   p.App_Mn)
          INTO l_App_Id,
               l_Sc_Id,
               l_Name,
               l_Surname,
               l_Patronymic
          FROM Ap_Document d JOIN Ap_Person p ON p.App_Id = d.Apd_App
         WHERE d.Apd_Id = p_Obj_Id AND d.History_Status = 'A';

        l_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');

        IF l_Birth_Dt IS NULL
        THEN
            l_Birth_Dt :=
                Api$appeal.Get_Person_Doc_Attr_Val_Dt (p_App_Id      => l_App_Id,
                                                       p_Nda_Class   => 'BDT',
                                                       p_Ndt_Ndc     => 13);
        END IF;

        IF    l_Birth_Dt IS NULL
           OR l_Surname IS NULL
           OR l_Name IS NULL
           OR l_Patronymic IS NULL
        THEN
            Tools.Add_Err (l_Birth_Dt IS NULL, ' дату народження', p_Error);
            Tools.Add_Err (l_Surname IS NULL, ' прізвище', p_Error);
            Tools.Add_Err (l_Name IS NULL, ' ім’я', p_Error);
            Tools.Add_Err (l_Patronymic IS NULL, ' по батькові', p_Error);

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
            p_Sc_Id        => l_Sc_Id,
            p_Birth_Dt     => l_Birth_Dt,
            p_Surname      => l_Surname,
            p_Name         => l_Name,
            p_Patronymic   => l_Patronymic,
            p_Rn_Nrt       => p_Rn_Nrt,
            p_Rn_Hs_Ins    => NULL,
            p_Rn_Src       => Api$appeal.c_Src_Vst,
            p_Rn_Id        => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Ar_By_Name_And_Birth_Date_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Реєстрація запиту для верифікації та отримання інформації
    -- АЗ(актового запису) за РНОКПП
    -----------------------------------------------------------------
    FUNCTION Reg_App_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
        l_Sc_Id   NUMBER;
        l_Inn     VARCHAR2 (100);
    BEGIN
        SELECT p.App_Sc, p.App_Inn
          INTO l_Sc_Id, l_Inn
          FROM Ap_Person p
         WHERE p.App_Id = p_Obj_Id AND p.History_Status = 'A';

        IF l_Inn IS NULL
        THEN
            Tools.Add_Err (l_Inn IS NULL, ' РНОКПП', p_Error);

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
            p_Sc_Id       => l_Sc_Id,
            p_Inn         => l_Inn,
            p_Role        => NULL,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Ar_By_Rnokpp_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Реєстрація запиту для верифікації та отримання інформації
    -- АЗ(актового запису) за РНОКПП
    -----------------------------------------------------------------
    FUNCTION Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   IN     NUMBER,
                                       p_Obj_Id   IN     NUMBER,
                                       p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
        l_Sc_Id   NUMBER;
        l_Inn     VARCHAR2 (100);
    BEGIN
        SELECT p.App_Sc, p.App_Inn
          INTO l_Sc_Id, l_Inn
          FROM Ap_Document d JOIN Ap_Person p ON p.App_Id = d.Apd_App
         WHERE d.Apd_Id = p_Obj_Id AND d.History_Status = 'A';

        IF l_Inn IS NULL
        THEN
            Tools.Add_Err (l_Inn IS NULL, ' РНОКПП', p_Error);

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
            p_Sc_Id       => l_Sc_Id,
            p_Inn         => l_Inn,
            p_Role        => NULL,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Ar_By_Rnokpp_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Реєстрація запиту для верифікації та отримання інформації
    -- АЗ(актового запису) за РНОКПП
    -----------------------------------------------------------------
    FUNCTION Reg_Apd_Ar_By_Rnokpp_Role1_Req (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
        l_Sc_Id   NUMBER;
        l_Inn     VARCHAR2 (100);
    BEGIN
        SELECT p.App_Sc, p.App_Inn
          INTO l_Sc_Id, l_Inn
          FROM Ap_Document d JOIN Ap_Person p ON p.App_Id = d.Apd_App
         WHERE d.Apd_Id = p_Obj_Id AND d.History_Status = 'A';

        IF l_Inn IS NULL
        THEN
            Tools.Add_Err (l_Inn IS NULL, ' РНОКПП', p_Error);

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
            p_Sc_Id       => l_Sc_Id,
            p_Inn         => l_Inn,
            p_Role        => '1',
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Ar_By_Rnokpp_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    -- Заповнення "Свідоцтво про народження дитини" NDT_ID=37
    -- на основі АЗ(актового запису) із ДРАЦС
    -----------------------------------------------------------------
    PROCEDURE Save_Birth_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Ar       IN Ikis_Rbm.Api$request_Mju.r_Birth_Act_Record,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert)
    IS
        c_Nda_Ar_Reg_Num        CONSTANT NUMBER := 3620;
        c_Nda_Ar_Reg_Dt         CONSTANT NUMBER := 3619;
        c_Nda_Cert_Num          CONSTANT NUMBER := 90;
        c_Nda_Cert_Dt           CONSTANT NUMBER := 94;
        c_Nda_Cert_Org          CONSTANT NUMBER := 93;
        c_Nda_Child_Dt          CONSTANT NUMBER := 91;
        c_Nda_Child_Name        CONSTANT NUMBER := 92;
        c_Nda_Child_Numident    CONSTANT NUMBER := 8529;
        c_Nda_Father_Name       CONSTANT NUMBER := 680;
        c_Nda_Father_Numident   CONSTANT NUMBER := 8531;
        c_Nda_Mother_Name       CONSTANT NUMBER := 679;
        c_Nda_Mother_Numident   CONSTANT NUMBER := 8530;
        c_Nda_Src_Name          CONSTANT NUMBER := 2293;
        c_Nda_Src_Dt            CONSTANT NUMBER := 2294;

        l_Ap_Id                          NUMBER;
        l_Dt                             DATE;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);

        IF     p_Ar.Ar_Reg_Date IS NOT NULL
           AND p_Ar.Ar_Reg_Date < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Ar_Reg_Date ' || p_Ar.Ar_Reg_Date);
        END IF;

        l_Dt := Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy');

        IF l_Dt IS NOT NULL AND l_Dt < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Cert_Date ' || p_Cert.Cert_Date);
        END IF;

        l_Dt := Tools.Try_Parse_Dt (p_Ar.Child_Date_Birth, 'dd.mm.yyyy');

        IF l_Dt IS NOT NULL AND l_Dt < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилкове параметру Child_Date_Birth '
                || p_Ar.Child_Date_Birth);
        END IF;

        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Num,
                              p_Apda_Val_String   => p_Ar.Reg_Numb);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Dt,
                              p_Apda_Val_Dt   => p_Ar.Ar_Reg_Date);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Num,
            p_Apda_Val_String   =>
                NVL (p_Cert.Cert_Serial || p_Cert.Cert_Number,
                     p_Cert.Cert_Serial_Number));
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Dt,
            p_Apda_Val_Dt   =>
                Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy'));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Cert_Org,
                              p_Apda_Val_String   => p_Cert.Cert_Org);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Child_Dt,
            p_Apda_Val_Dt   =>
                Tools.Try_Parse_Dt (p_Ar.Child_Date_Birth, 'dd.mm.yyyy'));
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Child_Name,
            p_Apda_Val_String   =>
                TRIM (
                       p_Ar.Child_Surname
                    || ' '
                    || p_Ar.Child_Name
                    || ' '
                    || p_Ar.Child_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Child_Numident,
                              p_Apda_Val_String   => p_Ar.Child_Numident);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Father_Name,
            p_Apda_Val_String   =>
                TRIM (
                       p_Ar.Father_Surname
                    || ' '
                    || p_Ar.Father_Name
                    || ' '
                    || p_Ar.Father_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Father_Numident,
                              p_Apda_Val_String   => p_Ar.Father_Numident);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Mother_Name,
            p_Apda_Val_String   =>
                TRIM (
                       p_Ar.Mother_Surname
                    || ' '
                    || p_Ar.Mother_Name
                    || ' '
                    || p_Ar.Mother_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Mother_Numident,
                              p_Apda_Val_String   => p_Ar.Mother_Numident);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Src_Name,
                              p_Apda_Val_String   => 'ДРАЦС',
                              p_Apda_Val_Int      => 1);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Src_Dt,
                              p_Apda_Val_Dt   => SYSDATE);
    END;

    -----------------------------------------------------------------
    -- Заповнення "Свідоцтво про шлюб" NDT_ID=100
    -- на основі АЗ(актового запису) із ДРАЦС
    -----------------------------------------------------------------
    PROCEDURE Save_Merriage_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Ar       IN Ikis_Rbm.Api$request_Mju.r_Merriage_Act_Record,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert)
    IS
        c_Nda_Ar_Reg_Num         CONSTANT NUMBER := 8527;
        c_Nda_Ar_Reg_Dt          CONSTANT NUMBER := 8528;
        c_Nda_Cert_Num           CONSTANT NUMBER := 219;
        c_Nda_Cert_Dt            CONSTANT NUMBER := 255;
        c_Nda_Cert_Org           CONSTANT NUMBER := 254;
        c_Nda_Husband_Name       CONSTANT NUMBER := 2433;
        c_Nda_Husband_Numident   CONSTANT NUMBER := 8526;
        c_Nda_Wife_Name          CONSTANT NUMBER := 2434;
        c_Nda_Wife_Numident      CONSTANT NUMBER := 8532;

        l_Ap_Id                           NUMBER;
        l_Dt                              DATE;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);

        IF     p_Ar.Ar_Reg_Date IS NOT NULL
           AND p_Ar.Ar_Reg_Date < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Ar_Reg_Date ' || p_Ar.Ar_Reg_Date);
        END IF;

        l_Dt := Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy');

        IF l_Dt IS NOT NULL AND l_Dt < TO_DATE ('01.01.1900', 'DD.MM.YYYY')
        THEN
            Raise_Application_Error (
                -20000,
                'Помилкове параметру Cert_Date ' || p_Cert.Cert_Date);
        END IF;

        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Num,
                              p_Apda_Val_String   => p_Ar.Reg_Numb);
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Ar_Reg_Dt,
                              p_Apda_Val_Dt   => p_Ar.Ar_Reg_Date);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Num,
            p_Apda_Val_String   =>
                NVL (p_Cert.Cert_Serial || p_Cert.Cert_Number,
                     p_Cert.Cert_Serial_Number));
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Dt,
            p_Apda_Val_Dt   =>
                Tools.Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy'));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Cert_Org,
                              p_Apda_Val_String   => p_Cert.Cert_Org);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Husband_Name,
            p_Apda_Val_String   =>
                TRIM (
                       p_Ar.Husband_Surname
                    || ' '
                    || p_Ar.Husband_Name
                    || ' '
                    || p_Ar.Husband_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Husband_Numident,
                              p_Apda_Val_String   => p_Ar.Husband_Numident);
        Api$appeal.Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Wife_Name,
            p_Apda_Val_String   =>
                TRIM (
                       p_Ar.Wife_Surname
                    || ' '
                    || p_Ar.Wife_Name
                    || ' '
                    || p_Ar.Wife_Patronymic));
        Api$appeal.Save_Attr (p_Apd_Id,
                              l_Ap_Id,
                              c_Nda_Wife_Numident,
                              p_Apda_Val_String   => p_Ar.Wife_Numident);
    END;

    -----------------------------------------------------------------
    -- Програмний запуск верифікації "Вивантаження даних АЗ про народження за РНОКПП"
    -----------------------------------------------------------------
    FUNCTION Search_Birth_Ar_By_Rnokpp (p_Apd_Id   IN NUMBER,
                                        p_Vf_Id    IN NUMBER)
        RETURN BOOLEAN
    IS
        c_Nrt   CONSTANT NUMBER := 104;             /*MJU.GetBirthArByRnokpp*/
        l_Rn_Id          NUMBER;
        l_Error          VARCHAR2 (4000);
        l_Terror         BOOLEAN := FALSE;
    BEGIN
        --Створюємо верифікацію для відправки запиту
        Tools.LOG ('Api$verification_Mju.Search_Birth_Ar_By_Rnokpp',
                   'BirthArApd',
                   p_Apd_Id,
                   'Start');

        BEGIN
            l_Rn_Id :=
                Reg_Apd_Ar_By_Rnokpp_Role1_Req (p_Rn_Nrt   => c_Nrt,
                                                p_Obj_Id   => p_Apd_Id,
                                                p_Error    => l_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
                l_Terror := TRUE;
                Api$verification.Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || c_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Apd_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF l_Rn_Id IS NULL
        THEN
            IF NOT l_Terror
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, l_Error);
            RETURN FALSE;
        ELSE
            --Привязуємо запит до верифікації
            Api$verification.Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                                        p_Vfa_Rn   => l_Rn_Id);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '323#@6502@' || c_Nrt);
            RETURN TRUE;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Програмний запуск верифікації
    -- "Вивантаження даних АЗ про народження за РНОКПП"
    -----------------------------------------------------------------
    PROCEDURE Search_Change_Name_By_Rnokpp (p_Apd_Id   IN NUMBER,
                                            p_Vf_Id    IN NUMBER)
    IS
        c_Nrt   CONSTANT NUMBER := 102;        /*MJU.GetChangeNameArByRnokpp*/
        l_Rn_Id          NUMBER;
        l_Error          VARCHAR2 (4000);
        l_Terror         BOOLEAN := FALSE;
    BEGIN
        --Створюємо верифікацію для відправки запиту
        Tools.LOG ('Api$verification_Mju.Search_Change_Name_By_Rnokpp',
                   'ChangeNameArApd',
                   p_Apd_Id,
                   'Start');

        BEGIN
            l_Rn_Id :=
                Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   => c_Nrt,
                                          p_Obj_Id   => p_Apd_Id,
                                          p_Error    => l_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
                l_Terror := TRUE;
                Api$verification.Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || c_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Apd_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF l_Rn_Id IS NULL
        THEN
            IF NOT l_Terror
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, l_Error);
        ELSE
            --Привязуємо запит до верифікації
            Api$verification.Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                                        p_Vfa_Rn   => l_Rn_Id);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '323#@6502@' || c_Nrt);
        END IF;
    END;

    -----------------------------------------------------------------
    -- Програмний запуск верифікації
    -- "Вивантаження даних АЗ про шлюб за РНОКПП"
    -----------------------------------------------------------------
    FUNCTION Search_Merriage_Ar_By_Rnokpp (p_Apd_Id   IN NUMBER,
                                           p_Vf_Id    IN NUMBER)
        RETURN BOOLEAN
    IS
        c_Nrt   CONSTANT NUMBER := 98;           /*MJU.GetMarriageArByRnokpp*/
        l_Rn_Id          NUMBER;
        l_Error          VARCHAR2 (4000);
        l_Terror         BOOLEAN := FALSE;
    BEGIN
        --Створюємо верифікацію для відправки запиту
        Tools.LOG ('Api$verification_Mju.Search_Merriage_Ar_By_Rnokpp',
                   'MerriageArApd',
                   p_Apd_Id,
                   'Start');

        BEGIN
            l_Rn_Id :=
                Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   => c_Nrt,
                                          p_Obj_Id   => p_Apd_Id,
                                          p_Error    => l_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
                l_Terror := TRUE;
                Api$verification.Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || c_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Apd_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF l_Rn_Id IS NULL
        THEN
            IF NOT l_Terror
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, l_Error);
            RETURN FALSE;
        ELSE
            --Привязуємо запит до верифікації
            Api$verification.Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                                        p_Vfa_Rn   => l_Rn_Id);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '323#@6502@' || c_Nrt);
            RETURN TRUE;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Програмний запуск верифікації
    -- "Вивантаження даних АЗ про розірвання шлюбу за ПІБ та датою народження"
    -----------------------------------------------------------------
    PROCEDURE Search_Divorce_Ar_By_Name_And_Birth_Date (
        p_Apd_Id      IN NUMBER,
        p_Vf_Id       IN NUMBER,
        p_As_Female   IN BOOLEAN)
    IS
        l_Nrt      NUMBER;
        l_Rn_Id    NUMBER;
        l_Error    VARCHAR2 (4000);
        l_Terror   BOOLEAN := FALSE;
    BEGIN
        IF p_As_Female
        THEN
            l_Nrt := 100;           /*MJU.GetDivorceArByWifeNameAndBirthDate*/
        ELSE
            l_Nrt := 99;         /*MJU.GetDivorceArByHusbandNameAndBirthDate*/
        END IF;

        --Створюємо верифікацію для відправки запиту
        Tools.LOG (
            'Api$verification_Mju.Search_Divorce_Ar_By_Name_And_Birth_Date',
            'DivorceArApd',
            p_Apd_Id,
            'Start');

        BEGIN
            l_Rn_Id :=
                Reg_Ar_By_Name_And_Birth_Date_Req (p_Rn_Nrt   => l_Nrt,
                                                   p_Obj_Id   => p_Apd_Id,
                                                   p_Error    => l_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || l_Nrt);
                l_Terror := TRUE;
                Api$verification.Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || l_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Apd_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF l_Rn_Id IS NULL
        THEN
            IF NOT l_Terror
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || l_Nrt);
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, l_Error);
        ELSE
            --Привязуємо запит до верифікації
            Api$verification.Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                                        p_Vfa_Rn   => l_Rn_Id);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '323#@6502@' || l_Nrt);
        END IF;
    END;

    -----------------------------------------------------------------
    -- Програмний запуск верифікації
    -- "Вивантаження даних АЗ про розірвання шлюбу за РНОКПП"
    -----------------------------------------------------------------
    PROCEDURE Search_Divorce_Ar_By_Rnokpp (p_Apd_Id   IN NUMBER,
                                           p_Vf_Id    IN NUMBER)
    IS
        c_Nrt   CONSTANT NUMBER := 101;           /*MJU.GetDivorceArByRnokpp*/
        l_Rn_Id          NUMBER;
        l_Error          VARCHAR2 (4000);
        l_Terror         BOOLEAN := FALSE;
    BEGIN
        --Створюємо верифікацію для відправки запиту
        Tools.LOG ('Api$verification_Mju.Search_Divorce_Ar_By_Rnokpp',
                   'DivorceArApd',
                   p_Apd_Id,
                   'Start');

        BEGIN
            l_Rn_Id :=
                Reg_Apd_Ar_By_Rnokpp_Req (p_Rn_Nrt   => c_Nrt,
                                          p_Obj_Id   => p_Apd_Id,
                                          p_Error    => l_Error);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
                l_Terror := TRUE;
                Api$verification.Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || c_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Apd_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF l_Rn_Id IS NULL
        THEN
            IF NOT l_Terror
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '324#@6502@' || c_Nrt);
            END IF;

            --НЕУСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Not_Verified (p_Vf_Id, l_Error);
        ELSE
            --Привязуємо запит до верифікації
            Api$verification.Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                                        p_Vfa_Rn   => l_Rn_Id);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '323#@6502@' || c_Nrt);
        END IF;
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про народження
    -- При відсутності АЗ, запуститься пошук про народження за РНОКПП, а дана верифікація відмітиться успішною
    -----------------------------------------------------------------
    PROCEDURE Handle_Birth_Ar_Name_And_Birth_Date_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_App_Id        NUMBER;
        l_Numident      Ap_Person.App_Inn%TYPE;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Birth_Act_Record_List;

        FUNCTION Try_Search_By_Rnokpp (p_Error IN VARCHAR2)
            RETURN BOOLEAN
        IS
        BEGIN
            IF l_Numident IS NULL
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '304');
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
                Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
                RETURN FALSE;
            END IF;

            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                p_Vfl_Message   => p_Error);

            --Реєструємо запит на пошук по РНОКПП
            RETURN Search_Birth_Ar_By_Rnokpp (p_Apd_Id   => l_Apd_Id,
                                              p_Vf_Id    => l_Vf_Id);
        END;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Отримуємо Ід особи
        SELECT Apd_App
          INTO l_App_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

        --Отримуємо серію та номер документа
        l_Numident := Api$appeal.Get_Person_Inn (p_App_Id => l_App_Id);

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            IF l_Result_Code IN
                   (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                    Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
            THEN
                p_Error := l_Error_Info; --Повідомлення для ikis_rbm.uxp_request.ur_error
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                      Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
                            THEN
                                   --
                                   'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                                || l_Result_Code
                        END));
                Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            ELSE
                l_Error_Info :=
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
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

                IF NOT Try_Search_By_Rnokpp (p_Error => l_Error_Info)
                THEN
                    p_Error := l_Error_Info; --Повідомлення для ikis_rbm.uxp_request.ur_error
                END IF;
            END IF;

            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            IF NOT Try_Search_By_Rnokpp (p_Error => CHR (38) || '108')
            THEN
                NULL;
            END IF;

            RETURN;
        END IF;

        --Шукаємо свідоцтво про народження в отриманих актових записах
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
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id         => l_Vf_Id,
                        p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   => CHR (38) || '163');

                    IF     l_Ar_List (i).Child_Numident IS NOT NULL
                       AND l_Numident IS NOT NULL
                    THEN
                        IF LTRIM (l_Ar_List (i).Child_Numident, '0') <>
                           LTRIM (l_Numident, '0')
                        THEN
                            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                            Api$verification.Set_Not_Verified (
                                l_Vf_Id,
                                CHR (38) || '162');
                            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
                            RETURN;
                        END IF;
                    END IF;

                    --Зберігаємо атрибути свідоцтва
                    Save_Birth_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                           p_Ar       => l_Ar_List (i),
                                           p_Cert     => l_Certs (1));

                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$verification.Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END;
        END LOOP;

        IF NOT Try_Search_By_Rnokpp (p_Error => CHR (38) || '161')
        THEN
            NULL;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про народження
    -- При відсутності АЗ, запуститься пошук про зміну імені за РНОКПП, а дана верифікація відмітиться неуспішна
    -----------------------------------------------------------------
    PROCEDURE Handle_Birth_Ar_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_App_Id        NUMBER;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Birth_Act_Record_List;

        PROCEDURE Try_Search_Change_Name (p_Error IN VARCHAR2)
        IS
        BEGIN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                p_Vfl_Message   => p_Error);
            Search_Change_Name_By_Rnokpp (p_Apd_Id   => l_Apd_Id,
                                          p_Vf_Id    => l_Vf_Id);
            Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
        END;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Отримуємо Ід особи
        SELECT Apd_App
          INTO l_App_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            IF l_Result_Code IN
                   (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                    Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                p_Error := l_Error_Info;
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                      Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
                            THEN
                                   --
                                   'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                                || l_Result_Code
                        END));
                Decline_For_Diia (l_Vf_Id, CHR (38) || '250');
            ELSE
                l_Error_Info :=
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
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
                p_Error := l_Error_Info;
                Try_Search_Change_Name (p_Error => l_Error_Info);
            END IF;

            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            Try_Search_Change_Name (p_Error => CHR (38) || '108');
            RETURN;
        END IF;

        --Шукаємо свідоцтво про народження в отриманих актових записах
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
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id         => l_Vf_Id,
                        p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   => CHR (38) || '163');

                    --Зберігаємо атрибути свідоцтва
                    Save_Birth_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                           p_Ar       => l_Ar_List (i),
                                           p_Cert     => l_Certs (1));

                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Api$verification.Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END;
        END LOOP;

        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        Try_Search_Change_Name (p_Error => CHR (38) || '161');
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про шлюб
    -- При відсутності АЗ, запуститься пошук про шлюб за РНОКПП, а дана верифікація відмітиться успішною
    -----------------------------------------------------------------
    PROCEDURE Handle_Merriage_Ar_Name_And_Birth_Date_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_App_Id        NUMBER;
        l_Numident      Ap_Person.App_Inn%TYPE;
        l_App_Name      Ap_Person.App_Fn%TYPE;
        l_App_Gender    Ap_Person.App_Gender%TYPE;
        l_Parent_Vf     NUMBER;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Merriage_Act_Record_List;

        FUNCTION Try_Search_By_Rnokpp (p_Error IN VARCHAR2)
            RETURN BOOLEAN
        IS
            l_Rnokpp_Vf   NUMBER;
        BEGIN
            IF l_Numident IS NULL
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '304');
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (l_Vf_Id, p_Error);
                Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                RETURN FALSE;
            END IF;

            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                p_Vfl_Message   => p_Error);

            --Реєструємо запит на пошук по РНОКПП
            RETURN Search_Merriage_Ar_By_Rnokpp (p_Apd_Id   => l_Apd_Id,
                                                 p_Vf_Id    => l_Vf_Id);
        END;

        PROCEDURE Try_Search_Divorce_By_Name_And_Birth_Date (
            p_As_Female   IN BOOLEAN)
        IS
        BEGIN
            Search_Divorce_Ar_By_Name_And_Birth_Date (
                p_Apd_Id      => l_Apd_Id,
                p_Vf_Id       => l_Vf_Id,
                p_As_Female   => p_As_Female);
        END;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        --Дізнаємося Ід верифікації на особу
        SELECT v.Vf_Vf_Main
          INTO l_Parent_Vf
          FROM Verification v
         WHERE v.Vf_Id = l_Vf_Id;

        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Отримуємо Ід особи
        SELECT Apd_App
          INTO l_App_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

        --Отримуємо серію та номер документа
        l_Numident := Api$appeal.Get_Person_Inn (p_App_Id => l_App_Id);

        --Отримуємо ПІБ особи
        SELECT p.App_Fn
          INTO l_App_Name
          FROM Ap_Person p
         WHERE p.App_Id = l_App_Id;

        l_App_Gender := Api$appeal.Get_Person_Gender (p_App_Id => l_App_Id);

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            IF l_Result_Code IN
                   (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                    Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                p_Error := l_Error_Info;
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                      Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
                            THEN
                                   --
                                   'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                                || l_Result_Code
                        END));
                Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
            ELSE
                l_Error_Info :=
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
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

                IF NOT Try_Search_By_Rnokpp (p_Error => l_Error_Info)
                THEN
                    p_Error := l_Error_Info;
                END IF;
            END IF;

            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            IF NOT Try_Search_By_Rnokpp (p_Error => CHR (38) || '108')
            THEN
                NULL;
            END IF;

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
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id         => l_Vf_Id,
                        p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   => CHR (38) || '163');

                    l_As_Female := NVL (l_App_Gender, 'F') = 'F';
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
                            Api$verification.Set_Not_Verified (
                                l_Vf_Id,
                                CHR (38) || '162');
                            Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                            RETURN;
                        END IF;
                    END IF;

                    IF l_Ar_List (i).Reg_Numb_Link IS NOT NULL
                    THEN
                        Api$verification.Write_Vf_Log (
                            p_Vf_Id    => l_Vf_Id,
                            p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                            p_Vfl_Message   =>
                                   CHR (38)
                                || '327#'
                                || l_Ar_List (i).Reg_Numb_Link);
                        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                        Api$verification.Set_Not_Verified (l_Vf_Id,
                                                           CHR (38) || '330');
                        Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                        RETURN;
                    END IF;

                    --Зберігаємо атрибути свідоцтва
                    --В АЗ два свідоцтва на чоловіка та дружину, в яких заповнено відомості про особу свідоцтва
                    DECLARE
                        l_Certs_By_Name   Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert_List;
                        l_Cert            Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert
                            := l_Certs (1);
                    BEGIN
                        SELECT *
                          BULK COLLECT INTO l_Certs_By_Name
                          FROM TABLE (l_Ar_List (i).Certificates)
                         WHERE Cert_Status = '1'                    /*дійсне*/
                                                 AND NAME = l_App_Name;

                        IF l_Certs_By_Name.COUNT > 0
                        THEN
                            l_Cert := l_Certs_By_Name (1);
                        END IF;

                        Save_Merriage_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                                  p_Ar       => l_Ar_List (i),
                                                  p_Cert     => l_Cert);
                    END;

                    --Запускаємо пошук свідоцтва про розірвання шлюбу
                    Try_Search_Divorce_By_Name_And_Birth_Date (
                        p_As_Female   => l_As_Female);
                    RETURN;
                END IF;
            END;
        END LOOP;

        IF NOT Try_Search_By_Rnokpp (p_Error => CHR (38) || '161')
        THEN
            NULL;
        END IF;
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про шлюб
    -- При відсутності АЗ, запуститься пошук про зміну імені за РНОКПП, а дана верифікація відмітиться неуспішна
    -----------------------------------------------------------------
    PROCEDURE Handle_Merriage_Ar_Rnokpp_Resp (p_Ur_Id      IN     NUMBER,
                                              p_Response   IN     CLOB,
                                              p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_App_Id        NUMBER;
        l_App_Name      Ap_Person.App_Fn%TYPE;
        l_Parent_Vf     NUMBER;
        l_Rnokpp_Vf     NUMBER;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Merriage_Act_Record_List;

        PROCEDURE Try_Search_Change_Name (p_Error IN VARCHAR2)
        IS
        BEGIN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                p_Vfl_Message   => p_Error);

            --Робимо наступний крок поточної верифікації
            --Реєструємо запит на пошук зміни імені по РНОКПП
            Search_Change_Name_By_Rnokpp (p_Apd_Id   => l_Apd_Id,
                                          p_Vf_Id    => l_Vf_Id);
            Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
        END;

        PROCEDURE Try_Search_Divorce_By_Rnokpp
        IS
        BEGIN
            Search_Divorce_Ar_By_Rnokpp (p_Apd_Id   => l_Apd_Id,
                                         p_Vf_Id    => l_Vf_Id);
        END;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        --Дізнаємося Ід верифікації на особу
        SELECT v.Vf_Vf_Main
          INTO l_Parent_Vf
          FROM Verification v
         WHERE v.Vf_Id = l_Vf_Id;

        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Отримуємо Ід особи
        SELECT Apd_App
          INTO l_App_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

        --Отримуємо ПІБ особи
        SELECT p.App_Fn
          INTO l_App_Name
          FROM Ap_Person p
         WHERE p.App_Id = l_App_Id;

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            IF l_Result_Code IN
                   (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                    Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                p_Error := l_Error_Info;
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed2,
                                      Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed3)
                            THEN
                                   --
                                   'Виконання запиту заборонено налаштуваннями на боці ДРАЦС. Код відповіді '
                                || l_Result_Code
                        END));
                Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
            ELSE
                l_Error_Info :=
                    NVL (
                        l_Error_Info,
                        CASE
                            WHEN l_Result_Code IN
                                     (Ikis_Rbm.Api$request_Mju.c_Result_Code_Not_Allowed4)
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
                p_Error := l_Error_Info;
                Try_Search_Change_Name (p_Error => l_Error_Info);
            END IF;

            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Try_Search_Change_Name (p_Error => CHR (38) || '108');
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
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id         => l_Vf_Id,
                        p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   => CHR (38) || '163');

                    IF l_Ar_List (i).Reg_Numb_Link IS NOT NULL
                    THEN
                        Api$verification.Write_Vf_Log (
                            p_Vf_Id    => l_Vf_Id,
                            p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                            p_Vfl_Message   =>
                                   CHR (38)
                                || '327#'
                                || l_Ar_List (i).Reg_Numb_Link);
                        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                        Api$verification.Set_Not_Verified (l_Vf_Id,
                                                           CHR (38) || '330');
                        Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                        RETURN;
                    END IF;

                    --Зберігаємо атрибути свідоцтва
                    --В АЗ два свідоцтва на чоловіка та дружину, в яких заповнено відомості про особу свідоцтва
                    DECLARE
                        l_Certs_By_Name   Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert_List;
                        l_Cert            Ikis_Rbm.Api$request_Mju.r_Act_Record_Cert
                            := l_Certs (1);
                    BEGIN
                        SELECT *
                          BULK COLLECT INTO l_Certs_By_Name
                          FROM TABLE (l_Ar_List (i).Certificates)
                         WHERE Cert_Status = '1'                    /*дійсне*/
                                                 AND NAME = l_App_Name;

                        IF l_Certs_By_Name.COUNT > 0
                        THEN
                            l_Cert := l_Certs_By_Name (1);
                        END IF;

                        Save_Merriage_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                                  p_Ar       => l_Ar_List (i),
                                                  p_Cert     => l_Cert);
                    END;

                    --Запускаємо пошук свідоцтва про розірвання шлюбу
                    Try_Search_Divorce_By_Rnokpp;
                    RETURN;
                END IF;
            END;
        END LOOP;

        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        Try_Search_Change_Name (p_Error => CHR (38) || '161');
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про розірвання шлюбу
    -----------------------------------------------------------------
    PROCEDURE Handle_Divorce_Ar_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id          NUMBER;
        l_Vf_Id          NUMBER;
        l_Apd_Id         NUMBER;
        l_Attr_Act_Num   VARCHAR2 (4000);
        l_Error_Info     VARCHAR2 (4000);
        l_Result_Code    NUMBER;
        l_Ar_List        Ikis_Rbm.Api$request_Mju.t_Divorce_Act_Record_List;
        l_Ar_Has         BOOLEAN := FALSE;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        --Отримуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Номер актового запису
        SELECT a.Apda_Val_String
          INTO l_Attr_Act_Num
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = l_Apd_Id
               AND a.Apda_Nda = 8527
               AND a.History_Status = 'A';

        BEGIN
            --Парсимо відповідь
            l_Ar_List :=
                Ikis_Rbm.Api$request_Mju.Parse_Divorce_Ar_Resp (
                    p_Response      => p_Response,
                    p_Resutl_Code   => l_Result_Code,
                    p_Error_Info    => l_Error_Info);
        EXCEPTION
            WHEN OTHERS
            THEN
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
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
                    END));
            Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '302');
            --УСПІШНА ВЕРИФІКАЦІЯ
            Api$verification.Set_Ok (l_Vf_Id);
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
                    /*Api$verification.Write_Vf_Log(p_Vf_Id       => l_Vf_Id,
                    p_Vfl_Tp      => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message => Chr(38) || '163');*/
                    IF l_Attr_Act_Num = l_Ar_List (i).Ar_Reg_Number
                    THEN
                        Api$verification.Write_Vf_Log (
                            p_Vf_Id    => l_Vf_Id,
                            p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                            p_Vfl_Message   =>
                                   CHR (38)
                                || '327#'
                                || l_Ar_List (i).Ar_Reg_Number);

                        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                        Api$verification.Set_Not_Verified (l_Vf_Id,
                                                           CHR (38) || '325');
                        Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                        RETURN;
                    END IF;

                    Api$verification.Write_Vf_Log (
                        p_Vf_Id         => l_Vf_Id,
                        p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   => CHR (38) || '326');
                    l_Ar_Has := TRUE;
                END IF;
            END;
        END LOOP;

        IF NOT l_Ar_Has
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '161');
        END IF;

        --УСПІШНА ВЕРИФІКАЦІЯ
        Api$verification.Set_Ok (l_Vf_Id);
    END;

    -----------------------------------------------------------------
    -- Обробка відповіді на запит до ДРАЦС для верифікації та отримання інформації
    -- АЗ(актового запису) про зміну імені
    -----------------------------------------------------------------
    PROCEDURE Handle_Change_Name_Ar_Rnokpp_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_App_Id        NUMBER;
        l_App_Fn        Ap_Person.App_Fn%TYPE;
        l_App_Mn        Ap_Person.App_Mn%TYPE;
        l_App_Ln        Ap_Person.App_Ln%TYPE;
        l_Error_Info    VARCHAR2 (4000);
        l_Result_Code   NUMBER;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Change_Name_Act_Record_List;

        PROCEDURE Finish_Vf
        IS
        BEGIN
            --УСПІШНА ВЕРИФІКАЦІЯ
            --Api$verification.Set_Ok(l_Vf_Id);
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Not_Verified,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Not_Verified);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END;
    BEGIN
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
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        --Отримуємо Ід особи
        SELECT Apd_App
          INTO l_App_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

        --Отримуємо ПІБ особи
        SELECT p.App_Fn, p.App_Mn, p.App_Ln
          INTO l_App_Fn, l_App_Mn, l_App_Ln
          FROM Ap_Person p
         WHERE p.App_Id = l_App_Id;

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
                Api$verification.Set_Tech_Error (
                    l_Rn_Id,
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
            Api$verification.Set_Not_Verified (
                l_Vf_Id,
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
                    END));
            Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '165');
            Finish_Vf ();
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

            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '163');

            IF    l_Ar_List (i).Name != l_App_Fn
               OR l_Ar_List (i).Surname != l_App_Ln
               OR NVL (l_Ar_List (i).Patronymic, '0') != NVL (l_App_Mn, '0')
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Api$verification.Set_Not_Verified (
                    l_Vf_Id,
                       CHR (38)
                    || '329#'
                    || TRIM (
                              l_Ar_List (i).Surname
                           || ' '
                           || l_Ar_List (i).Name
                           || ' '
                           || l_Ar_List (i).Patronymic));
                Decline_For_Diia (l_Vf_Id, CHR (38) || '365');
                RETURN;
            END IF;

            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '328');
            Finish_Vf ();
            RETURN;
        END LOOP;

        Api$verification.Write_Vf_Log (
            p_Vf_Id         => l_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
            p_Vfl_Message   => CHR (38) || '161');
        Finish_Vf ();
    END;
END Api$verification_Mju;
/