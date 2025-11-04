/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.Load$vpo
IS
    -- Author  : SHOSTAK
    -- Created : 11.08.2022 8:21:39 PM
    -- Purpose : Завантаження даних з реєстру ВПО

    c_Src_Vpo                CONSTANT VARCHAR2 (10) := '38';

    c_Crt_State_Actual       CONSTANT VARCHAR2 (10) := '50';
    c_Crt_State_Closed       CONSTANT VARCHAR2 (10) := '90';

    c_Ndt_Vpo                CONSTANT NUMBER := 10052;
    c_Ndt_Death_Cert         CONSTANT NUMBER := 89;

    c_Nda_Vpo_Num            CONSTANT NUMBER := 1756;
    c_Nda_Vpo_Gv_Dt          CONSTANT NUMBER := 1757;
    c_Nda_Vpo_Org_Name       CONSTANT NUMBER := 1759;
    c_Nda_Vpo_Tp             CONSTANT NUMBER := 1761;
    c_Nda_Vpo_Cnt            CONSTANT NUMBER := 1762;
    c_Nda_Vpo_Doc_St         CONSTANT NUMBER := 1855;
    c_Nda_Vpo_Till_Dt        CONSTANT NUMBER := 1760;
    c_Nda_Vpo_Kaot           CONSTANT NUMBER := 2292;
    c_Nda_Vpo_CanclRsn       CONSTANT NUMBER := 4480;              --#93848-29
    --Інформація про особу(власника довідки)
    c_Nda_Vpo_Owner_Ln       CONSTANT NUMBER := 2571;
    c_Nda_Vpo_Owner_Fn       CONSTANT NUMBER := 2575;
    c_Nda_Vpo_Owner_Mn       CONSTANT NUMBER := 2576;
    c_Nda_Vpo_Owner_Rnokpp   CONSTANT NUMBER := 2572;
    c_Nda_Vpo_Owner_Docnum   CONSTANT NUMBER := 2573;
    c_Nda_Vpo_Owner_Ndt      CONSTANT NUMBER := 2574;
    --Інформація про заявника
    c_Nda_Vpo_Rnokpp         CONSTANT NUMBER := 1763;
    c_Nda_Vpo_Ln             CONSTANT NUMBER := 1764;
    c_Nda_Vpo_Fn             CONSTANT NUMBER := 1765;
    c_Nda_Vpo_Mn             CONSTANT NUMBER := 1766;
    c_Nda_Vpo_Birthday       CONSTANT NUMBER := 1767;
    c_Nda_Vpo_Guid           CONSTANT NUMBER := 2440;
    c_Nda_Vpo_Addr_Fact      CONSTANT NUMBER := 2457;
    c_Nda_Vpo_Addr_Reg       CONSTANT NUMBER := 2458;
    c_Nda_Vpo_Addr_Change    CONSTANT NUMBER := 2833;
    --Адреса фактичного місця проживання/перебування #93848
    c_Nda_Vpo_StreetId       CONSTANT NUMBER := 5551;
    c_Nda_Vpo_StreetType     CONSTANT NUMBER := 4484;
    c_Nda_Vpo_StreetName     CONSTANT NUMBER := 4485;
    c_Nda_Vpo_HouseNum       CONSTANT NUMBER := 4487;
    c_Nda_Vpo_BuildNum       CONSTANT NUMBER := 4488;
    c_Nda_Vpo_FlatNum        CONSTANT NUMBER := 4489;
    c_Nda_Vpo_Atu            CONSTANT NUMBER := 4492;

    PROCEDURE Handle_Vpo_Sync_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2);

    FUNCTION Get_Katottg_Name (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Save_Vpo_Info (
        p_Crt        IN OUT Ikis_Rbm.Api$request_Msp.r_Vpo_Cert,
        p_Vpo_Tp     IN     VARCHAR2,
        p_Vpo_Cnt    IN     NUMBER,
        p_Crt_Main   IN     Ikis_Rbm.Api$request_Msp.r_Vpo_Cert DEFAULT NULL,
        p_Rn_Id      IN     NUMBER DEFAULT NULL,
        p_Nrt_Id     IN     NUMBER DEFAULT NULL);

    PROCEDURE Process_Requests;
END Load$vpo;
/


GRANT EXECUTE ON USS_PERSON.LOAD$VPO TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.LOAD$VPO TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.LOAD$VPO TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_PERSON.LOAD$VPO TO SHOST
/

GRANT EXECUTE ON USS_PERSON.LOAD$VPO TO TNIKONOVA
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.Load$vpo
IS
    ------------------------------------------------------------------
    --         Обробка відповіді на запит до реєстру ВПО
    ------------------------------------------------------------------
    PROCEDURE Handle_Vpo_Sync_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2)
    IS
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
    --           Отримання повної назви КАТОТТГ
    ------------------------------------------------------------------
    FUNCTION Get_Katottg_Name (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (
                   RTRIM (
                          CASE
                              WHEN L1_Name IS NOT NULL AND L1_Name != L2_Name
                              THEN
                                  L1_Name || ', '
                          END
                       || CASE
                              WHEN L2_Name IS NOT NULL AND L2_Name != L3_Name
                              THEN
                                  L2_Name || ', '
                          END
                       || CASE
                              WHEN L3_Name IS NOT NULL AND L3_Name != L4_Name
                              THEN
                                  L3_Name || ', '
                          END
                       || CASE
                              WHEN L4_Name IS NOT NULL AND L4_Name != L5_Name
                              THEN
                                  L4_Name || ', '
                          END
                       || CASE
                              WHEN     L5_Name IS NOT NULL
                                   AND L5_Name != Kaot_Name
                              THEN
                                  L5_Name || ', '
                          END
                       || Name_Temp,
                       ','))
          INTO l_Result
          FROM (SELECT Kaot_Id,
                       CASE
                           WHEN Kaot_Kaot_L1 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM Uss_Ndi.v_Ndi_Katottg  X1,
                                       Uss_Ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L1
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L1_Name,
                       CASE
                           WHEN Kaot_Kaot_L2 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM Uss_Ndi.v_Ndi_Katottg  X1,
                                       Uss_Ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L2
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L2_Name,
                       CASE
                           WHEN Kaot_Kaot_L3 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM Uss_Ndi.v_Ndi_Katottg  X1,
                                       Uss_Ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L3
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L3_Name,
                       CASE
                           WHEN Kaot_Kaot_L4 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM Uss_Ndi.v_Ndi_Katottg  X1,
                                       Uss_Ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L4
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L4_Name,
                       CASE
                           WHEN Kaot_Kaot_L5 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM Uss_Ndi.v_Ndi_Katottg  X1,
                                       Uss_Ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L5
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L5_Name,
                       Kaot_Code,
                       Kaot_Tp,
                       t.Dic_Sname                        AS Kaot_Tp_Name,
                       Kaot_Name,
                       Kaot_Start_Dt,
                       Kaot_Stop_Dt,
                       Kaot_St,
                       Kaot_Koatuu,
                       Kaot_Id                            AS Id,
                       t.Dic_Sname || ' ' || Kaot_Name    AS Name_Temp
                  FROM Uss_Ndi.v_Ndi_Katottg  m
                       JOIN Uss_Ndi.v_Ddn_Kaot_Tp t ON m.Kaot_Tp = t.Dic_Code
                 WHERE Kaot_Id = p_Kaot_Id) t;

        RETURN l_Result;
    END;

    ------------------------------------------------------------------
    --           Збереження довідки і ознаки ВПО
    ------------------------------------------------------------------
    PROCEDURE Save_Vpo_Info (
        p_Crt        IN OUT Ikis_Rbm.Api$request_Msp.r_Vpo_Cert,
        p_Vpo_Tp     IN     VARCHAR2,
        p_Vpo_Cnt    IN     NUMBER,
        p_Crt_Main   IN     Ikis_Rbm.Api$request_Msp.r_Vpo_Cert DEFAULT NULL,
        p_Rn_Id      IN     NUMBER DEFAULT NULL,
        p_Nrt_Id     IN     NUMBER DEFAULT NULL)
    IS
        l_Scdi_Id        NUMBER;
        l_Sc_Id          NUMBER;
        l_Sc_Unique      Socialcard.Sc_Unique%TYPE;
        l_Inn            VARCHAR2 (50);
        l_Ndt_Id         NUMBER;
        l_Doc_Ser        VARCHAR2 (100);
        l_Doc_Num        VARCHAR2 (100);
        l_Gender         VARCHAR2 (10);
        l_Doc_Attrs      Api$socialcard.t_Doc_Attrs;
        l_Scd_Id         NUMBER;
        l_Dh_Id          NUMBER;
        l_Kaot_Id        NUMBER;
        l_Fact_Kaot_Id   NUMBER;
        l_Error          VARCHAR2 (4000);
        l_Sca_Id         Sc_Address.Sca_Id%TYPE;
    BEGIN
        --Перевірка ІПН
        l_Inn := REPLACE (p_Crt.Rnokpp, ' ');

        IF NOT REGEXP_LIKE (l_Inn, '^[0-9]{10}$')
        THEN
            l_Inn := NULL;
        END IF;

        --Перекодування типу документа
        l_Ndt_Id :=
            Uss_Ndi.Tools.Decode_Dict (
                p_Nddc_Tp         => 'NDT_ID',
                p_Nddc_Src        => 'VPO',
                p_Nddc_Dest       => 'USS',
                p_Nddc_Code_Src   => p_Crt.Document_Type);

        --Перевірка документу на відповідність масці, та очищення зайвих символів
        IF l_Ndt_Id IS NOT NULL
        THEN
            l_Doc_Ser := TRIM ('-' FROM REPLACE (p_Crt.Document_Serie, ' '));
            l_Doc_Num := REPLACE (p_Crt.Document_Number, ' ');
        END IF;

        IF l_Ndt_Id = 6
        THEN
            l_Doc_Ser :=
                TRANSLATE (l_Doc_Ser, 'ABCIETOPHKXM', 'АВСІЕТОРНКХМ');

            IF NOT REGEXP_LIKE (l_Doc_Ser || l_Doc_Num,
                                '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
            THEN
                l_Ndt_Id := NULL;
                l_Doc_Ser := NULL;
                l_Doc_Num := NULL;
            END IF;
        ELSIF l_Ndt_Id = 7 AND NOT REGEXP_LIKE (l_Doc_Num, '^[0-9]{9}$')
        THEN
            l_Ndt_Id := NULL;
            l_Doc_Ser := NULL;
            l_Doc_Num := NULL;
        ELSIF l_Ndt_Id = 37 AND NOT REGEXP_LIKE (l_Doc_Num, '^[0-9]{6}$')
        THEN
            l_Ndt_Id := NULL;
            l_Doc_Ser := NULL;
            l_Doc_Num := NULL;
        END IF;

        --Перекодування статі
        SELECT DECODE (UPPER (SUBSTR (p_Crt.Gender, 1, 1)),
                       'Ж', 'F',
                       'Ч', 'M',
                       'V')
          INTO l_Gender
          FROM DUAL;

        --Отримуємо ІД КАТОТТГ
        SELECT MAX (k.Kaot_Id)
          INTO l_Kaot_Id
          FROM Uss_Ndi.v_Ndi_Katottg k
         WHERE k.Kaot_Code = p_Crt.Catottg;

        --Отримуємо ІД КАТОТТГ фактичного місця проживання/перебування
        SELECT MAX (k.Kaot_Id)
          INTO l_Fact_Kaot_Id
          FROM Uss_Ndi.v_Ndi_Katottg k
         WHERE k.Kaot_Code = p_Crt.Fact_Address_Atu;

        /*api$socialcard_ext.Save_Data_Ident(p_Scdi_Id        => l_Scdi_Id,
                                           p_Scdi_Sc        => NULL,
                                           p_Scdi_Ln        => Clear_Name(p_Crt.Idp_Surname),
                                           p_Scdi_Fn        => Clear_Name(p_Crt.Idp_Name),
                                           p_Scdi_Mn        => Clear_Name(p_Crt.Idp_Patronymic),
                                           p_Scdi_Numident  => l_Inn,
                                           p_Scdi_Doc_Tp    => l_Ndt_Id,
                                           p_Scdi_Doc_Sn    => l_Doc_Ser || l_Doc_Num,
                                           p_Scdi_Nt        => 1,
                                           p_Scdi_Sex       => l_Gender,
                                           p_Scdi_Birthday  => p_Crt.Birth_Date,
                                           p_Rn_Id          => p_Rn_Id,
                                           p_Nrt_Id         => p_Nrt_Id,
                                           p_Ext_Ident      => p_Crt.Guid);

        DECLARE
          l_Scpo_Id NUMBER;
        BEGIN
          api$socialcard_ext.Save_Document(p_Scpo_Id      => l_Scpo_Id,
                                           p_Scpo_Sc      => NULL,
                                           p_Scpo_Scdi    => l_Scdi_Id,
                                           p_Scpo_Ndt     => c_Ndt_Vpo);

          --Заповнюємо атрибути документа
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Num, p_Scpda_Val_String => p_Crt.Certificate_Number);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Gv_Dt, p_Scpda_Val_Dt => p_Crt.Certificate_Date);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Org_Name, p_Scpda_Val_String => p_Crt.Certificate_Issuer);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Tp, p_Scpda_Val_String => p_Vpo_Tp);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Cnt, p_Scpda_Val_Int => p_Vpo_Cnt);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Kaot, p_Scpda_Val_Id => l_Kaot_Id, p_Scpda_Val_String => Get_Katottg_Name(l_Kaot_Id));
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id,
                                      c_Nda_Vpo_Doc_St,
                                      p_Scpda_Val_String => CASE
                                                               WHEN p_Crt.Certificate_State = c_Crt_State_Actual THEN
                                                                'A'
                                                               WHEN p_Crt.Certificate_State = c_Crt_State_Closed THEN
                                                                'H'
                                                             END);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Till_Dt, p_Scpda_Val_Dt => p_Crt.Date_End);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_CanclRsn, p_Scpda_Val_Id => p_Crt.CertificateCancelReasonId); --#93848-29

          --Інформація про особу(власника довідки)
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Ln, p_Scpda_Val_String => p_Crt.Idp_Surname);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Fn, p_Scpda_Val_String => p_Crt.Idp_Name);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Mn, p_Scpda_Val_String => p_Crt.Idp_Patronymic);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Rnokpp, p_Scpda_Val_String => p_Crt.Rnokpp);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Docnum, p_Scpda_Val_String => p_Crt.Document_Serie || p_Crt.Document_Number);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Owner_Ndt, p_Scpda_Val_Id => l_Ndt_Id);

          --Інформація про заявника
          IF p_Crt_Main.Certificate_Number IS NOT NULL THEN
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Rnokpp, p_Scpda_Val_String => p_Crt_Main.Rnokpp);
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Ln, p_Scpda_Val_String => p_Crt_Main.Idp_Surname);
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Fn, p_Scpda_Val_String => p_Crt_Main.Idp_Name);
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Mn, p_Scpda_Val_String => p_Crt_Main.Idp_Patronymic);
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Birthday, p_Scpda_Val_Dt => p_Crt_Main.Birth_Date);
          END IF;

          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Guid, p_Scpda_Val_String => p_Crt.Guid);
          --Адреси
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Addr_Fact, p_Scpda_Val_String => p_Crt.Fact_Address);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Addr_Reg, p_Scpda_Val_String => p_Crt.Reg_Address);
          IF p_Crt.Address_Change = '11' THEN
            api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Addr_Change, p_Scpda_Val_String => 'T');
          END IF;

        --Адреса фактичного місця проживання/перебування #93848
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_StreetId, p_Scpda_Val_String => p_Crt.Fact_Address_StreetId);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_StreetName, p_Scpda_Val_String => p_Crt.Fact_Address_StreetName);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_HouseNum, p_Scpda_Val_String => p_Crt.Fact_Address_HouseNum);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_BuildNum, p_Scpda_Val_String => p_Crt.Fact_Address_BuildNum);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_FlatNum, p_Scpda_Val_String => p_Crt.Fact_Address_FlatNum);
          api$socialcard_ext.Save_Doc_Attr(l_Scpo_Id, c_Nda_Vpo_Atu, p_Scpda_Val_Id => l_Fact_Kaot_Id, p_Scpda_Val_String => Get_Katottg_Name(l_Fact_Kaot_Id));

        END;

        IF l_Fact_Kaot_Id is not null THEN
          DECLARE
            l_Scpa_Id NUMBER;
          BEGIN
            api$socialcard_ext.Save_Address(p_Scpa_Id        => l_Scpa_Id,
                                            p_Scpa_Sc        => NULL,
                                            p_Scpa_Scdi      => l_Scdi_Id,
                                            p_Scpa_Tp        => 2,-- Місце проживання
                                            p_Scpa_Kaot_Code => p_Crt.Fact_Address_Atu,
                                            p_Scpa_Postcode  => NULL,
                                            p_Scpa_City      => uss_ndi.Api$dic_Common.Get_Kaot_City(p_Kaot_Id => l_Fact_Kaot_Id),
                                            p_Scpa_Street    => p_Crt.Fact_Address_StreetName,
                                            p_Scpa_Building  => p_Crt.Fact_Address_HouseNum,
                                            p_Scpa_Block     => p_Crt.Fact_Address_BuildNum,
                                            p_Scpa_Apartment => p_Crt.Fact_Address_FlatNum);
          END;
        END IF;

        RETURN;*/
        --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        IF    --Якщо вказзано документ
              (l_Ndt_Id IS NOT NULL AND l_Doc_Num IS NOT NULL)
           --або вказано ІПН
           OR l_Inn IS NOT NULL
        THEN
            BEGIN
                --Викноуємо пошук соцкартки
                --або спробу створення соцкартки, у разі якщо не знайдено
                l_Sc_Id :=
                    Load$socialcard.Load_Sc (
                        p_Fn            => Clear_Name (p_Crt.Idp_Name),
                        p_Ln            => Clear_Name (p_Crt.Idp_Surname),
                        p_Mn            => Clear_Name (p_Crt.Idp_Patronymic),
                        p_Gender        => l_Gender,
                        p_Nationality   => 1,
                        p_Src_Dt        => p_Crt.Certificate_Date,
                        p_Birth_Dt      => p_Crt.Birth_Date,
                        p_Inn_Num       => l_Inn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       =>
                            CASE
                                WHEN p_Crt.Document_Type <> 99 THEN l_Doc_Ser
                            END,
                        p_Doc_Num       =>
                            CASE
                                WHEN p_Crt.Document_Type = 99
                                THEN
                                    l_Doc_Ser || l_Doc_Num
                                ELSE
                                    l_Doc_Num
                            END,
                        p_Doc_Ndt       => l_Ndt_Id,
                        p_Src           => c_Src_Vpo,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Sc            => l_Sc_Id);

                IF NVL (l_Sc_Id, -1) <= 0
                THEN
                    l_Sc_Id := NULL;
                    l_Error := CHR (38) || '149';
                END IF;
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
            l_Error := CHR (38) || '151';
        END IF;

        --Заповнюємо атрибути документа
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Num,
                                     p_Val_Str   => p_Crt.Certificate_Number);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Gv_Dt,
                                     p_Val_Dt   => p_Crt.Certificate_Date);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Org_Name,
                                     p_Val_Str   => p_Crt.Certificate_Issuer);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Tp,
                                     p_Val_Str   => p_Vpo_Tp);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Cnt,
                                     p_Val_Int   => p_Vpo_Cnt);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_Kaot,
            p_Val_Id    => l_Kaot_Id,
            p_Val_Str   => Get_Katottg_Name (l_Kaot_Id));
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_Doc_St,
            p_Val_Str   =>
                CASE
                    WHEN p_Crt.Certificate_State = c_Crt_State_Actual
                    THEN
                        'A'
                    WHEN p_Crt.Certificate_State = c_Crt_State_Closed
                    THEN
                        'H'
                END);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Till_Dt,
                                     p_Val_Dt   => p_Crt.Date_End);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_CanclRsn,
            p_Val_Id   => p_Crt.CertificateCancelReasonId);        --#93848-29

        --Інформація про особу(власника довідки)
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Owner_Ln,
                                     p_Val_Str   => p_Crt.Idp_Surname);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Owner_Fn,
                                     p_Val_Str   => p_Crt.Idp_Name);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Owner_Mn,
                                     p_Val_Str   => p_Crt.Idp_Patronymic);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Owner_Rnokpp,
                                     p_Val_Str   => p_Crt.Rnokpp);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_Owner_Docnum,
            p_Val_Str   => p_Crt.Document_Serie || p_Crt.Document_Number);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Owner_Ndt,
                                     p_Val_Id   => l_Ndt_Id);

        --Інформація про заявника
        IF p_Crt_Main.Certificate_Number IS NOT NULL
        THEN
            Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                         c_Nda_Vpo_Rnokpp,
                                         p_Val_Str   => p_Crt_Main.Rnokpp);
            Api$socialcard.Add_Doc_Attr (
                l_Doc_Attrs,
                c_Nda_Vpo_Ln,
                p_Val_Str   => p_Crt_Main.Idp_Surname);
            Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                         c_Nda_Vpo_Fn,
                                         p_Val_Str   => p_Crt_Main.Idp_Name);
            Api$socialcard.Add_Doc_Attr (
                l_Doc_Attrs,
                c_Nda_Vpo_Mn,
                p_Val_Str   => p_Crt_Main.Idp_Patronymic);
            Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                         c_Nda_Vpo_Birthday,
                                         p_Val_Dt   => p_Crt_Main.Birth_Date);
        END IF;

        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Guid,
                                     p_Val_Str   => p_Crt.Guid);
        --Адреси
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Addr_Fact,
                                     p_Val_Str   => p_Crt.Fact_Address);
        Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                     c_Nda_Vpo_Addr_Reg,
                                     p_Val_Str   => p_Crt.Reg_Address);

        IF p_Crt.Address_Change = '11'
        THEN
            Api$socialcard.Add_Doc_Attr (l_Doc_Attrs,
                                         c_Nda_Vpo_Addr_Change,
                                         p_Val_Str   => 'T');
        END IF;

        --Адреса фактичного місця проживання/перебування #93848
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_StreetId,
            p_Val_Str   => p_Crt.Fact_Address_StreetId);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_StreetName,
            p_Val_Str   => p_Crt.Fact_Address_StreetName);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_HouseNum,
            p_Val_Str   => p_Crt.Fact_Address_HouseNum);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_BuildNum,
            p_Val_Str   => p_Crt.Fact_Address_BuildNum);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_FlatNum,
            p_Val_Str   => p_Crt.Fact_Address_FlatNum);
        Api$socialcard.Add_Doc_Attr (
            l_Doc_Attrs,
            c_Nda_Vpo_Atu,
            p_Val_Id    => l_Fact_Kaot_Id,
            p_Val_Str   => Get_Katottg_Name (l_Fact_Kaot_Id));

        --13/02/2024 serhii: #98341 оновлення даних адрес при отриманні довідки ВПО у новому форматі зі структурованою адресою
        IF l_Fact_Kaot_Id IS NOT NULL
        THEN
            --IF trim(p_Crt.Fact_Address_StreetName) is not null THEN
            Api$socialcard.Save_Sc_Address (
                p_Sca_Sc          => l_Sc_Id,
                p_Sca_Tp          => 2,                    -- Місце проживання
                p_Sca_Kaot        => l_Fact_Kaot_Id,
                p_Sca_Nc          => 1,                             -- Україна
                --p_Sca_Country => 'Україна',
                p_Sca_Region      =>
                    uss_ndi.Api$dic_Common.Get_Kaot_Region (
                        p_Kaot_Id   => l_Fact_Kaot_Id),
                p_Sca_District    =>
                    uss_ndi.Api$dic_Common.Get_Kaot_District (
                        p_Kaot_Id   => l_Fact_Kaot_Id),
                p_Sca_Postcode    => NULL,
                p_Sca_City        =>
                    uss_ndi.Api$dic_Common.Get_Kaot_City (
                        p_Kaot_Id   => l_Fact_Kaot_Id),
                p_Sca_Street      => p_Crt.Fact_Address_StreetName,
                p_Sca_Building    => p_Crt.Fact_Address_HouseNum,
                p_Sca_Block       => p_Crt.Fact_Address_BuildNum,
                p_Sca_Apartment   => p_Crt.Fact_Address_FlatNum,
                p_Sca_Note        => 'обмін з ЄІБД ВПО',
                p_Sca_Src         => c_Src_Vpo,
                --p_Sca_Create_Dt => SYSDATE,
                o_Sca_Id          => l_Sca_Id);
        --END IF;
        END IF;

        --Зберігаємо документ до архіву і соцкартки
        Api$socialcard.Save_Document (p_Sc_Id       => l_Sc_Id,
                                      p_Ndt_Id      => c_Ndt_Vpo,
                                      p_Doc_Attrs   => l_Doc_Attrs,
                                      p_Src_Id      => c_Src_Vpo,
                                      p_Src_Code    => 'VPO',
                                      p_Scd_Note    => NULL,
                                      p_Scd_Id      => l_Scd_Id,
                                      p_Scd_Dh      => l_Dh_Id);

        IF l_Error IS NOT NULL
        THEN
            --Зберігаємо інформацію про помилку визначення соцкартки
            Api$scd_Event.Save_Doc_Error (p_Scde_Scd       => l_Scd_Id,
                                          p_Scde_Dt        => SYSDATE,
                                          p_Scde_Message   => l_Error);
        END IF;

        --Якщо довідка діюча
        IF     p_Crt.Certificate_State = c_Crt_State_Actual
           AND l_Sc_Id IS NOT NULL
        THEN
            --Зберігаємо соціальний статус ВПО
            Api$feature.Set_Sc_Feature (p_Scs_Sc        => l_Sc_Id,
                                        p_Scs_Scd       => l_Scd_Id,
                                        p_Scs_Scd_Ndt   => c_Ndt_Vpo,
                                        p_Scs_Scd_Dh    => l_Dh_Id);
        --Якщо довідка знята з обліку
        ELSIF p_Crt.Certificate_State = c_Crt_State_Closed
        THEN
            --Змінюємо статус документа
            Api$socialcard.Set_Doc_St (
                p_Scd_Id   => l_Scd_Id,
                p_Scd_St   => Api$socialcard.c_Scd_St_Closed);

            IF l_Sc_Id IS NOT NULL
            THEN
                --Знімаємо соціальний статус ВПО
                Api$feature.Unset_Sc_Feature (p_Scs_Sc        => l_Sc_Id,
                                              p_Scs_Scd       => l_Scd_Id,
                                              p_Scs_Scd_Ndt   => c_Ndt_Vpo,
                                              p_Scs_Scd_Dh    => l_Dh_Id);
            END IF;
        END IF;
    END;

    ------------------------------------------------------------------
    --          Обробка відповідей від реєстру ВПО
    ------------------------------------------------------------------
    PROCEDURE Process_Requests
    IS
        l_New_Req_Exists   NUMBER;
        l_Response         CLOB;
        l_Handle_Dt        DATE;
        l_Vpo_Info_Resp    Ikis_Rbm.Api$request_Msp.t_Vpo_Delta_Resp;
        c_Nrt     CONSTANT NUMBER := 43;
        c_Urt     CONSTANT NUMBER := 43;
        l_Rn_Id            NUMBER;
        l_Prev_Delta_Dt    DATE;
        l_Ur_Id            NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_New_Req_Exists
          FROM Ikis_Rbm.v_Uxp_Request r
         WHERE r.Ur_Urt = c_Urt AND r.Ur_St = 'NEW';

        IF l_New_Req_Exists = 1
        THEN
            RETURN;
        END IF;

        BEGIN
              --Отримуємо останню відповідь від реєстру ВПО
              SELECT r.Ur_Soap_Resp,
                     r.Ur_Handle_Dt,
                     r.Ur_Id,
                     Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                         p_Rnc_Rn   => Ur_Rn,
                         p_Rnc_Pt   => Ikis_Rbm.Api$request_Msp.c_Pt_Start_Dt)
                INTO l_Response,
                     l_Handle_Dt,
                     l_Ur_Id,
                     l_Prev_Delta_Dt
                FROM Ikis_Rbm.v_Uxp_Request r
               WHERE r.Ur_Urt = c_Urt AND r.Ur_St = 'OK'
            ORDER BY r.Ur_Create_Dt DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (l_Ur_Id);
        --Парсимо відповідь
        l_Vpo_Info_Resp :=
            Ikis_Rbm.Api$request_Msp.Parse_Vpo_Delta_Resp (l_Response);

        FOR d IN 1 .. l_Vpo_Info_Resp.COUNT
        LOOP
            --Збереження інформації
            FOR i IN 1 .. l_Vpo_Info_Resp (d).Delta_Body.COUNT
            LOOP
                DECLARE
                    l_Crt           Ikis_Rbm.Api$request_Msp.r_Vpo_Cert;
                    l_Accompanied   Ikis_Rbm.Api$request_Msp.t_Vpo_Certs;
                BEGIN
                    l_Crt := l_Vpo_Info_Resp (d).Delta_Body (i).Person;
                    l_Accompanied :=
                        l_Vpo_Info_Resp (d).Delta_Body (i).Accompanied;
                    --Зберігаємо інформацію(довідку+ознаку) для заявника
                    Save_Vpo_Info (
                        p_Crt       => l_Crt,
                        p_Vpo_Tp    => 'Z',
                        p_Vpo_Cnt   =>
                            CASE
                                WHEN l_Accompanied IS NOT NULL
                                THEN
                                    NULLIF (l_Accompanied.COUNT, 0)
                            END,
                        p_Rn_Id     => l_Rn_Id,
                        p_Nrt_Id    => c_Nrt);
                END;
            END LOOP;
        END LOOP;

        --Реєструємо наступний запит
        Ikis_Rbm.Api$request_Msp.Reg_Vpo_Info_Batch_Req (
            p_Start_Dt    =>
                LEAST (TRUNC (l_Prev_Delta_Dt) + 1, TRUNC (SYSDATE)), --Дата за яку запитувати дані
            p_Plan_Dt     =>
                  LEAST (TRUNC (l_Prev_Delta_Dt) + 2, TRUNC (SYSDATE) + 1)
                + INTERVAL '4' HOUR, --Дата, коли сервіс буде відправляти запит
            p_Rn_Nrt      => c_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => 'PERSON',
            p_Rn_Id       => l_Rn_Id);
        COMMIT;
    END;
END Load$vpo;
/