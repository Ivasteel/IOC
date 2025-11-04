/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$EXCH_MVE
IS
    -- Author  : SHOSTAK
    -- Created : 25.03.2023 2:58:00 PM
    -- Purpose : Обмін з міністерством ветеранів

    PROCEDURE Reg_Create_Vet_Req (p_Sc_Id IN NUMBER);

    FUNCTION Get_Create_Vet_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Handle_Create_Vet_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);
END Dnet$exch_Mve;
/


GRANT EXECUTE ON USS_PERSON.DNET$EXCH_MVE TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_MVE TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$EXCH_MVE
IS
    --------------------------------------------------------------------
    -- Реєстрація запиту на передачу даних про ветерана то Мінвету
    --------------------------------------------------------------------
    PROCEDURE Reg_Create_Vet_Req (p_Sc_Id IN NUMBER)
    IS
        l_Rn_Id        NUMBER;
        l_Has_Bf_Cat   NUMBER;
    BEGIN
        RETURN;

        --Перевіряємо наявність певної пільгової категорії
        SELECT SIGN (COUNT (*))
          INTO l_Has_Bf_Cat
          FROM Sc_Benefit_Category c
         WHERE     c.Scbc_Sc = p_Sc_Id
               AND c.Scbc_Nbc IN (1,
                                  11,
                                  12,
                                  13,
                                  14,
                                  2,
                                  20,
                                  22,
                                  23,
                                  3,
                                  4)
               AND c.Scbc_St = 'A';

        IF l_Has_Bf_Cat <> 1
        THEN
            RETURN;
        END IF;

        --todo: check tzr?

        --Реєструємо запит
        Ikis_Rbm.Api$request_Mve.Reg_Create_Vet_Req (
            p_Sc_Id       => p_Sc_Id,
            p_Plan_Dt     => SYSDATE,
            p_Rn_Nrt      => 63,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession,
            p_Rn_Src      => 'PERSON',
            p_Rn_Id       => l_Rn_Id);
    END;

    --------------------------------------------------------------------
    -- Отримання даних запиту на передачу даних про ветерана то Мінвету
    --------------------------------------------------------------------
    FUNCTION Get_Create_Vet_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Sc_Id        NUMBER;
        l_Msec_Dh      NUMBER;
        l_Req          Ikis_Rbm.Api$request_Mve.r_Create_Vet_Request;
        l_Disability   Ikis_Rbm.Api$request_Mve.r_Disability_Data;
        l_Inv_Rsn      VARCHAR2 (4000);
    BEGIN
        IF Ikis_Rbm.Api$uxp_Request.Is_Same_Request_In_Queue (
               p_Ur_Id   => p_Ur_Id)
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 120,
                p_Delay_Reason    =>
                    'В черзі є раніше створені необроблені ззапити по цій соцкартці');
        END IF;

        l_Sc_Id := Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id);

        --l_Sc_Id := 125015382; --1426970;--1258420; --125092187;

        --Отримуємо основну інформацію про особу
        SELECT i.Sci_Fn,
               i.Sci_Mn,
               i.Sci_Ln,
               b.Scb_Dt,
               DECODE (i.Sci_Gender,  'F', 'жіноча',  'M', 'чоловіча')
          INTO l_Req."firstName",
               l_Req."middleName",
               l_Req."lastName",
               l_Req."dateBirth",
               l_req."personGender"
          FROM Socialcard  c
               JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
               JOIN Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
               LEFT JOIN Sc_Birth b
                   ON Cc.Scc_Scb <> -1 AND Cc.Scc_Scb = b.Scb_Id
         WHERE c.Sc_Id = l_Sc_Id;

        --ІПН
        SELECT MAX (d.Scd_Number)
          INTO l_Req."rnokpp"
          FROM Sc_Document d
         WHERE d.Scd_Sc = l_Sc_Id AND d.Scd_Ndt = 5 AND d.Scd_St = '1';

        BEGIN
              --Отримуємо документ що посвідчує особу
              SELECT d.Scd_Ndt, --todo: уточнити щодо перекодування
                                d.Scd_Seria || d.Scd_Number
                INTO l_req."mainPersonDocType", l_req."docSeriesNumber"
                FROM Sc_Document d
                     JOIN Uss_Ndi.v_Ndi_Document_Type t
                         ON d.Scd_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13
               WHERE d.Scd_Sc = l_Sc_Id AND d.Scd_St = '1'
            ORDER BY d.Scd_Id DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        BEGIN
            --Отримуємо номер телефона
            SELECT NVL (c.Sct_Phone_Mob, c.Sct_Phone_Num)
              INTO l_req."primaryPhone"
              FROM Socialcard  s
                   JOIN Sc_Change Cc ON s.Sc_Scc = Cc.Scc_Id
                   JOIN Sc_Contact c
                       ON Cc.Scc_Sct = c.Sct_Id AND Cc.Scc_Sct <> -1
             WHERE s.Sc_Id = l_Sc_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        BEGIN
              --Отримуємо інформацію про інвалідність
              --За постановкою КЕВ: віддаємо тільки інформацію про інвалідність по даним ЦБІ
              --Отримуємо зріз документу довідки МСЕК
              SELECT d.Scd_Dh
                INTO l_Msec_Dh
                FROM Sc_Document d
               WHERE d.Scd_Sc = l_Sc_Id AND d.Scd_Ndt = 201 AND d.Scd_St = '1'
            ORDER BY 1 DESC
               FETCH FIRST ROW ONLY;

            --Отримуємо атрибути з довідки МСЕК
            l_req."reasonTo" :=
                Uss_Doc.Api$documents.Get_Attr_Val_Str (2920, l_Msec_Dh);
            l_req."endDate" :=
                Uss_Doc.Api$documents.Get_Attr_Val_Dt (2921, l_Msec_Dh);
            l_Disability."isDisabilityPerpetual" :=
                CASE
                    --todo: уточнити
                    --Якщо не вказано дату завершення строку інвалідності, вважаємо, що довічно
                    WHEN Uss_Doc.Api$documents.Get_Attr_Val_Dt (347,
                                                                l_Msec_Dh)
                             IS NULL
                    THEN
                        TRUE
                    ELSE
                        --Інакше отримуємо ознаку довічносі з атрибута
                        CASE Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                 2925,
                                 l_Msec_Dh)
                            WHEN 'T'
                            THEN
                                TRUE
                            ELSE
                                FALSE
                        END
                END;
            l_Disability."diagnosisNosology" :=
                Uss_Doc.Api$documents.Get_Attr_Val_Str (2923, l_Msec_Dh);
            l_Disability."isAmputationMoreOne" :=
                CASE Uss_Doc.Api$documents.Get_Attr_Val_Str (2924, l_Msec_Dh)
                    WHEN 'T' THEN TRUE
                    ELSE FALSE
                END;
            l_Disability."disabilityGroup" :=
                Uss_Doc.Api$documents.Get_Attr_Val_Str (349, l_Msec_Dh);
            l_Disability."disabilityDateFrom" :=
                Uss_Doc.Api$documents.Get_Attr_Val_Dt (352, l_Msec_Dh);

            l_Inv_Rsn :=
                Uss_Doc.Api$documents.Get_Attr_Val_Str (353, l_Msec_Dh);

            SELECT MAX (r.Dic_Name)
              INTO l_Disability."diasabilityReason"
              FROM Uss_Ndi.v_Ddn_Inv_Reason r
             WHERE r.Dic_Value = l_Inv_Rsn;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                --Raise_Application_Error(-20000, 'Не знайдено діючої довідки МСЕК');
                NULL;
        END;

        l_req."disabilityListData" :=
            Ikis_Rbm.Api$request_Mve.t_Disability_Data ();
        l_req."disabilityListData".EXTEND ();
        l_req."disabilityListData" (1) := l_Disability;

        BEGIN
              --Отримуємо адресу
              SELECT DECODE (a.Sca_Tp,
                             '2', 'адреса проживання',
                             '3', 'адреса реєстрації'),
                     k.Kaot_Code,
                     a.Sca_Postcode,
                     a.Sca_Street,
                     a.Sca_Building,
                     a.Sca_Block,
                     a.Sca_Apartment
                INTO l_req."primaryAddress"."addressType",
                     l_req."primaryAddress"."addressCode",
                     l_req."primaryAddress"."postcode",
                     l_req."primaryAddress"."addressStreet",
                     l_req."primaryAddress"."buildingNumber",
                     l_req."primaryAddress"."corpNumber",
                     l_req."primaryAddress"."flatNumber"
                FROM Sc_Address a
                     LEFT JOIN Uss_Ndi.v_Ndi_Katottg k
                         ON a.Sca_Kaot = k.Kaot_Id
               WHERE     a.Sca_Sc = l_Sc_Id
                     AND a.History_Status = 'A'
                     AND a.Sca_Tp IN ('2', '3')
            ORDER BY DECODE (a.Sca_Tp,  '2', 1,  '3', 2)
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                IF l_Msec_Dh IS NOT NULL
                THEN
                    l_req."primaryAddress"."addressCode" :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (2918,
                                                                l_Msec_Dh);
                    l_req."primaryAddress"."addressStreet" :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (2919,
                                                                l_Msec_Dh);

                    IF    l_req."primaryAddress"."addressStreet" IS NOT NULL
                       OR l_req."primaryAddress"."addressCode" IS NOT NULL
                    THEN
                        l_req."primaryAddress"."addressType" := 2;
                    END IF;
                END IF;
        END;

        l_req."primaryAddress"."isHomeless" :=
            NVL (Uss_Doc.Api$documents.Get_Attr_Val_Str (2922, l_Msec_Dh),
                 'F') =
            'T';

        BEGIN
            --Отримуємо пільгові категорії особи
            SELECT Uss_Ndi.Tools.Decode_Dict ('NBC_ID',
                                              'PERSON',
                                              'MVE',
                                              Scbc_Nbc),
                   --
                   Nbc_Norm_Act,
                   Scd_Seria,
                   Scd_Number,
                   Scd_Issued_Dt,
                   Scd_Issued_Who,
                   NVL (Scd_Stop_Dt, TO_DATE ('31.12.2054', 'dd.mm.yyyy'))
              BULK COLLECT INTO l_Req."personCategoryListData"
              FROM (SELECT c.Scbc_Nbc,
                           n.Nbc_Norm_Act,
                           d.Scd_Seria,
                           d.Scd_Number,
                           d.Scd_Issued_Dt,
                           d.Scd_Stop_Dt,
                           d.Scd_Issued_Who,
                           --Теоретично на одну категорію може бути декілька документів
                           --з вразуванням відсутності постановки який саме потрібно брати - беремо рандомно перший
                           ROW_NUMBER ()
                               OVER (PARTITION BY c.Scbc_Id
                                     ORDER BY d.Scd_Id)    AS Rn
                      FROM Sc_Benefit_Category  c
                           JOIN Uss_Ndi.v_Ndi_Benefit_Category n
                               ON c.Scbc_Nbc = n.Nbc_Id
                           JOIN Sc_Benefit_Docs Bd
                               ON c.Scbc_Id = Bd.Scbd_Scbc
                           JOIN Sc_Document d ON Bd.Scbd_Scd = d.Scd_Id
                     WHERE c.Scbc_Sc = l_Sc_Id AND c.Scbc_St = 'A')
             WHERE Rn = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        BEGIN
            --Отримуємо пільги особи
            SELECT --Тип пільги(код)
                   Uss_Ndi.Tools.Decode_Dict ('NBT_ID',
                                              'PERSON',
                                              'MVE',
                                              Nbt.Nbt_Id),
                   --Тип пільги(назва)
                   Nbt.Nbt_Name,
                   --Категорія пільги(код)
                   Uss_Ndi.Tools.Decode_Dict ('NBC_ID',
                                              'PERSON',
                                              'MVE',
                                              Nbc.Nbc_Id),
                   --Категорія пільги(назва)
                   Nbc.Nbc_Name,
                      --
                      REPLACE (
                          TO_CHAR (NVL (Nbc.Nbc_Benefit_Amount, 0),
                                   'FM999999999999990D90'),
                          ',',
                          '.')
                   || Nbc.Nbc_Unit,
                   Bt.Scbt_Start_Dt,
                   Bt.Scbt_Stop_Dt,
                   0,
                   NULL
              BULK COLLECT INTO l_Req."benefitUsageListData"
              FROM Uss_Person.Sc_Benefit_Type  Bt
                   JOIN Uss_Ndi.v_Ndi_Benefit_Type Nbt
                       ON Bt.Scbt_Nbt = Nbt.Nbt_Id
                   JOIN Uss_Person.Sc_Benefit_Category Bc
                       ON Bt.Scbt_Scbc = Bc.Scbc_Id AND Bc.Scbc_St = 'A'
                   JOIN Uss_Ndi.v_Ndi_Benefit_Category Nbc
                       ON Bc.Scbc_Nbc = Nbc.Nbc_Id
             WHERE Bt.Scbt_Sc = l_Sc_Id AND Bt.Scbt_St = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Вичитуємо інформацію про ТЗР
        SELECT p.Scar_Wr,
               p.Scar_Dt,
               p.Scar_Issue_Dt,
               p.Scar_End_Expl_Dt
          BULK COLLECT INTO l_req."disabilityRehab"
          FROM Sc_Prosthetics p
         WHERE p.Scar_Sc = l_Sc_Id AND p.Scar_St = 'A';

        --Вичитуємо інформацію про заяви на автомобілі
        SELECT c.Scap_Start_Dt,
               c.Scap_Qt,
               c.Scap_Number,
               c.Scap_Issue_Dt,
               c.Scap_Cancel_Dt
          BULK COLLECT INTO l_req."carProvision"
          FROM Sc_Cars c
         WHERE c.Scap_Sc = l_Sc_Id AND c.Scap_St = 'A';


        -- 07/08/2024 serhii: #105642 Дані по рішеннях про ЖКП
        SELECT scpp_pfu_payment_tp      pdPayTp,
               scpp_pfu_pd_start_dt     pdStartDt,
               scpp_pfu_pd_stop_dt      pdStopDt
          BULK COLLECT INTO l_req."decisionsInfo"
          FROM sc_pfu_pay_summary
         WHERE scpp_sc = l_Sc_Id AND scpp_st = 'A';

        --Вичитуємо інформацію про заяви на санаторно-курортне лікування
        SELECT v.Scas_Dt,
               v.Scas_Number,
               v.Scas_Place,
               v.Scas_Season,
               v.Scas_Pfl_Id,
               v.Scas_Ag_Id_Code,
               v.Scas_Ag_Id_Sanatorium,
               v.Scas_Arrival_Dt,
               v.Scas_Departure_Dt,
               v.Scas_Price,
               v.Scas_Renounce_Dt,
               v.Scas_Renounce_Reason,
               v.Scas_Rejection_Dt
          BULK COLLECT INTO l_req."sanTreatmentData"
          FROM Sc_Voucheres v
         WHERE v.Scas_Sc = l_Sc_Id AND v.Scas_St = 'A';

        -- Dbms_Output.Put_Line(Ikis_Rbm.Api$request_Mve.Build_Create_Vet_Req(l_Req));
        RETURN Ikis_Rbm.Api$request_Mve.Build_Create_Vet_Req (l_Req);
    END;

    ------------------------------------------------------------------------
    --Обробка відповіді на запит на передачу даних про ветерана то Мінвету
    ------------------------------------------------------------------------
    PROCEDURE Handle_Create_Vet_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
        l_Resp   Ikis_Rbm.Api$request_Mve.r_Mve_Response;
    BEGIN
        BEGIN
            l_Resp :=
                Ikis_Rbm.Api$request_Mve.Parse_Create_Vet_Resp (p_Response);
        EXCEPTION
            WHEN OTHERS
            THEN
                IF p_Error IS NOT NULL
                THEN
                    Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                        p_Ur_Id           => p_Ur_Id,
                        p_Delay_Seconds   => 60,
                        p_Delay_Reason    => p_Error);
                ELSE
                    p_Error := 'Помилка парсингу: ' || SQLERRM;
                    RETURN;
                END IF;
        END;

        IF l_Resp.Status_Code IN ('400', '404')
        THEN
            p_Error := NVL (p_Error, 'Код відповіді ' || l_Resp.Status_Code);
            RETURN;
        END IF;

        IF NVL (l_Resp.Status_Code, '-') <>
           Ikis_Rbm.Api$request_Mve.c_Status_Code_Ok
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    =>
                    NVL (p_Error, 'Код відповіді ' || l_Resp.Status_Code));
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_Error := 'Помилка обробки відповіді: ' || SQLERRM;
    END;
END Dnet$exch_Mve;
/