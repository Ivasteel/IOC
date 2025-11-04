/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$CBI
IS
    -- Author  : SHOSTAK
    -- Created : 11.08.2022 8:20:45 PM
    -- Purpose : Завантаження даних з ЦБІ

    c_Src_Cbi              CONSTANT VARCHAR2 (10) := '34';

    c_Ndt_Msec             CONSTANT NUMBER := 201;
    c_Nda_Msec_Doc_Num     CONSTANT NUMBER := 346;
    c_Nda_Msec_Start_St    CONSTANT NUMBER := 352;
    c_Nda_Msec_Stop_Dt     CONSTANT NUMBER := 347;
    c_Nda_Msec_Inv_Gr      CONSTANT NUMBER := 349;
    c_Nda_Msec_Inv_Rsn     CONSTANT NUMBER := 353;

    c_Nda_Msec_Kaot_Code   CONSTANT NUMBER := 2918;
    c_Nda_Msec_Addr        CONSTANT NUMBER := 2919;
    c_Nda_Msec_Rsun_Name   CONSTANT NUMBER := 2920;
    c_Nda_Msec_Rsun_Dt     CONSTANT NUMBER := 2921;
    c_Nda_Msec_Homless     CONSTANT NUMBER := 2922;
    c_Nda_Msec_Nosoligy    CONSTANT NUMBER := 2923;
    c_Nda_Msec_Amt         CONSTANT NUMBER := 2924;
    c_Nda_Msec_Unlimited   CONSTANT NUMBER := 2925;
    c_Nda_Msec_Capacity    CONSTANT NUMBER := 3703;

    PROCEDURE Handle_Delta_Resp (p_Ur_Id      IN     NUMBER,
                                 p_Response   IN     CLOB,
                                 p_Error      IN OUT VARCHAR2);

    PROCEDURE Process_Requests;

    FUNCTION Char2sum (p_Val IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Save_Disability_Info (
        p_Cbi_Info   IN Ikis_Rbm.Api$request_Cbi.r_Cbi_Info);
END Load$cbi;
/


GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.LOAD$CBI TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$CBI
IS
    -----------------------------------------------------------------------
    --  Обробка відповіді на запит отримання дельти ЦБІ
    -----------------------------------------------------------------------
    PROCEDURE Handle_Delta_Resp (p_Ur_Id      IN     NUMBER,
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
                p_Delay_Seconds   => 10,
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
    --         Фонова обробка відповіді на запит отримання дельти ЦБІ
    ------------------------------------------------------------------
    PROCEDURE Process_Requests
    IS
        l_New_Req_Exists   NUMBER;
        l_Response         CLOB;
        l_Prev_Stop_Dt     DATE;
        l_Delta_Resp       Ikis_Rbm.Api$request_Cbi.t_Cbi_Info;
        c_Nrt     CONSTANT NUMBER := 62;
        c_Urt     CONSTANT NUMBER := 62;
        l_Rn_Id            NUMBER;
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

        --Отримуємо останню відповідь від ЦБІ
        BEGIN
              SELECT r.Ur_Soap_Resp, r.Ur_Id
                INTO l_Response, l_Ur_Id
                FROM Ikis_Rbm.v_Uxp_Request r
               WHERE r.Ur_Urt = c_Urt AND r.Ur_St = 'OK'
            ORDER BY r.Ur_Create_Dt DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        --Отримуємо дату завершення періоду з поточного запиту
        SELECT NVL (
                   Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                       p_Rnc_Rn   => Ur_Rn,
                       p_Rnc_Pt   => Ikis_Rbm.Api$request_Cbi.c_Pt_Stop_Dt),
                   SYSDATE)
          INTO l_Prev_Stop_Dt
          FROM Ikis_Rbm.v_Uxp_Request r
         WHERE r.Ur_Id = l_Ur_Id;

        l_Delta_Resp :=
            Ikis_Rbm.Api$request_Cbi.Parse_Delta_Resp (l_Response);

        FOR i IN 1 .. l_Delta_Resp.COUNT
        LOOP
            Save_Disability_Info (l_Delta_Resp (i));
        END LOOP;

        --Реєструємо наступний запит
        Ikis_Rbm.Api$request_Cbi.Reg_Delta_Request (
            p_Start_Dt    => TRUNC (l_Prev_Stop_Dt),
            --Запитуємо дані лише за один день, на випадок тривалого простою обміну
            --Якщо, наприклад, обмін не працював місяць, то є ймовірність, що сервіс не зможе віддати такий об'єм даних
            p_Stop_Dt     => TRUNC (l_Prev_Stop_Dt) + 1,
            p_Plan_Dt     => TRUNC (l_Prev_Stop_Dt) + 1 + INTERVAL '4' HOUR, --Дата, коли сервіс буде відправляти запит
            p_Rn_Nrt      => c_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => 'PERSON',
            p_Rn_Id       => l_Rn_Id);
        COMMIT;
    END;

    FUNCTION Char2sum (p_Val IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (p_Val,
                          'FM999999999999990D90',
                          'NLS_NUMERIC_CHARACTERS=''.,''');
    END;

    -----------------------------------------------------------------------
    --   Завантаження даних про інвалідність
    -----------------------------------------------------------------------
    PROCEDURE Save_Disability_Info (
        p_Cbi_Info   IN Ikis_Rbm.Api$request_Cbi.r_Cbi_Info)
    IS
        l_Inn          VARCHAR2 (10);
        l_Ndt_Id       NUMBER;
        l_Doc_Ser      VARCHAR2 (100);
        l_Doc_Num      VARCHAR2 (100);
        l_Sc_Unique    Uss_Person.Socialcard.Sc_Unique%TYPE;
        l_Sc_Id        NUMBER;
        l_Scd_Id       NUMBER;
        l_Dh_Id        NUMBER;
        l_Inv_Reason   VARCHAR2 (10);
        l_Attrs        Api$socialcard.t_Doc_Attrs;
        l_Error        VARCHAR2 (4000);
        l_Scd_St       VARCHAR2 (10) := '1';
    BEGIN
        --Перевіряємо валідність РНОКПП
        l_Inn :=
            CASE
                WHEN REGEXP_LIKE (REPLACE (p_Cbi_Info.Rnokpp, ' ', ''),
                                  '^[0-9]{10}$')
                THEN
                    REPLACE (p_Cbi_Info.Rnokpp, ' ', '')
            END;

        l_Doc_Ser :=
            UPPER (TRIM ('-' FROM REPLACE (p_Cbi_Info.Sn_Doc, ' ', '')));
        l_Doc_Num :=
            UPPER (TRIM ('-' FROM REPLACE (p_Cbi_Info.Num_Doc, ' ', '')));

        --Отримуємо тип документа
        CASE
            WHEN     UPPER (p_Cbi_Info.Ozn_Doc) = '1'
                 AND REGEXP_LIKE (l_Doc_Ser || l_Doc_Num,
                                  '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[0-9]{6}$')
            THEN
                --Паспорт
                l_Ndt_Id := 6;
                l_Doc_Ser :=
                    TRANSLATE (l_Doc_Ser, 'ABCIETOPHKXM', 'АВСІЕТОРНКХМ');
            WHEN     UPPER (p_Cbi_Info.Ozn_Doc) = '2'
                 AND REGEXP_LIKE (l_Doc_Num, '^[0-9]{9}$')
            THEN
                --Ід карта
                l_Ndt_Id := 7;
                l_Doc_Ser := NULL;
            WHEN     UPPER (p_Cbi_Info.Ozn_Doc) = '3'
                 AND l_Doc_Ser IS NOT NULL
                 AND REGEXP_LIKE (l_Doc_Num, '^[0-9]{6}$')
            THEN
                --Св-во про народження
                l_Ndt_Id := 37;
            WHEN p_Cbi_Info.Ozn_Doc = '4'
            THEN
                --Інший документ
                l_Ndt_Id := 10192;
            ELSE
                l_Doc_Ser := NULL;
                l_Doc_Num := NULL;
        END CASE;

        IF l_Inn IS NULL AND l_Ndt_Id IS NULL
        THEN
            l_Error := CHR (38) || '151';
        END IF;

        IF l_Error IS NULL
        THEN
            BEGIN
                l_Sc_Id :=
                    Uss_Person.Load$socialcard.Load_Sc (
                        p_Fn            => Clear_Name (p_Cbi_Info.First_Name),
                        p_Ln            => Clear_Name (p_Cbi_Info.Full_Name),
                        p_Mn            => Clear_Name (p_Cbi_Info.Second_Name),
                        p_Gender        =>
                            CASE p_Cbi_Info.Sex
                                WHEN '0' THEN 'F'
                                WHEN '1' THEN 'M'
                                ELSE 'V'
                            END,
                        p_Nationality   => '1',
                        p_Src_Dt        => p_Cbi_Info.Disabled_Date_Begin,
                        p_Birth_Dt      => p_Cbi_Info.Birth_Date,
                        p_Inn_Num       => l_Inn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => l_Ndt_Id,
                        p_Src           => c_Src_Cbi,
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
        END IF;

        IF p_Cbi_Info.Cod_Disabled_Cat IS NOT NULL
        THEN
            --todo:
            -- Уточнити щодо перекодувань причин інвалідності
            l_Inv_Reason :=
                Uss_Ndi.Tools.Decode_Dict (
                    p_Nddc_Tp         => 'INV_REASON',
                    p_Nddc_Src        => 'CBI',
                    p_Nddc_Dest       => 'USS',
                    p_Nddc_Code_Src   => p_Cbi_Info.Cod_Disabled_Cat);
        END IF;

        --Формуємо атрибути документа
        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Doc_Num,
            p_Val_Str   => p_Cbi_Info.Disabled_Number);
        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Start_St,
            p_Val_Dt   => p_Cbi_Info.Disabled_Date_Begin);
        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Stop_Dt,
            p_Val_Dt   => p_Cbi_Info.Disabled_Date_End);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Inv_Gr,
                                     p_Val_Str   => p_Cbi_Info.Disabled_Gr);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Inv_Rsn,
                                     p_Val_Str   => l_Inv_Reason);

        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Kaot_Code,
                                     p_Val_Str   => p_Cbi_Info.Adr_Kt);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Addr,
                                     p_Val_Str   => p_Cbi_Info.Adr_Full);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Rsun_Name,
                                     p_Val_Str   => p_Cbi_Info.Rsun_Name);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Rsun_Dt,
                                     p_Val_Dt   => p_Cbi_Info.Rsun_Date);
        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Homless,
            p_Val_Str   =>
                CASE p_Cbi_Info.Nm_Is_Homeless
                    WHEN '1' THEN 'T'
                    WHEN '0' THEN 'F'
                END);
        Api$socialcard.Add_Doc_Attr (l_Attrs,
                                     c_Nda_Msec_Nosoligy,
                                     p_Val_Id    => p_Cbi_Info.Ain_Pit_Cod,
                                     p_Val_Str   => p_Cbi_Info.Ain_Pit_Name);

        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Amt,
            p_Val_Str   =>
                CASE p_Cbi_Info.Amt_At
                    WHEN '1' THEN 'T'
                    WHEN '0' THEN 'F'
                END);
        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Unlimited,
            p_Val_Str   =>
                CASE p_Cbi_Info.Disabled_Type
                    WHEN '1' THEN 'T'
                    WHEN '2' THEN 'F'
                END);

        Api$socialcard.Add_Doc_Attr (
            l_Attrs,
            c_Nda_Msec_Capacity,
            p_Val_Str   => p_Cbi_Info.Status_Capacity);

        IF     p_Cbi_Info.Disabled_Date_End IS NOT NULL
           AND p_Cbi_Info.Disabled_Date_End < SYSDATE
        THEN
            l_Scd_St := 2;
        END IF;

        --Зберігаємо документ
        Api$socialcard.Save_Document (p_Sc_Id       => l_Sc_Id,
                                      p_Ndt_Id      => c_Ndt_Msec,
                                      p_Doc_Attrs   => l_Attrs,
                                      p_Src_Id      => c_Src_Cbi,
                                      p_Src_Code    => 'CBI',
                                      p_Scd_Note    => NULL,
                                      p_Scd_Id      => l_Scd_Id,
                                      p_Scd_Dh      => l_Dh_Id,
                                      p_Scd_St      => l_Scd_St);

        IF l_Error IS NOT NULL
        THEN
            --Зберігаємо інформацію про помилку визначення соцкартки
            Api$scd_Event.Save_Doc_Error (p_Scde_Scd       => l_Scd_Id,
                                          p_Scde_Dt        => SYSDATE,
                                          p_Scde_Message   => l_Error);
            RETURN;
        END IF;

        --Зберігаємо інформацію про інвалідність до соцкартки
        Uss_Person.Api$feature.Set_Sc_Disability (
            p_Scy_Sc        => l_Sc_Id,
            p_Scy_Scd       => l_Scd_Id,
            p_Scy_Scd_Ndt   => c_Ndt_Msec,
            p_Scy_Scd_Dh    => l_Dh_Id);

        --Зберігаємо інформацію про технічні засоби реабілітації
        FOR Rec
            IN (SELECT *
                  FROM TABLE (p_Cbi_Info.Prosthetics)  p
                       LEFT JOIN Sc_Prosthetics Pp
                           ON     Pp.Scar_Sc = l_Sc_Id
                              AND p.Ar_Id = Pp.Scar_Ext_Id
                              AND Pp.Scar_St = 'A')
        LOOP
            --Якщо в соцкартці вже існує запис з таким ІД
            IF Rec.Scar_Id IS NOT NULL
            THEN
                --Якщо атрибути не змінено, то пропускаємо цей запис
                IF     NVL (Rec.Scar_Wr, '#') = NVL (Rec.Ar_Wr, '#')
                   AND NVL (Rec.Scar_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ar_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scar_Issue_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ar_Issue_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scar_End_Expl_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ar_End_Expl_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                THEN
                    CONTINUE;
                ELSE
                    --Якщо атрибути змінено, переводимо запис в історичний статус
                    UPDATE Sc_Prosthetics p
                       SET p.Scar_St = 'H'
                     WHERE p.Scar_Id = Rec.Scar_Id;
                END IF;
            END IF;

            INSERT INTO Sc_Prosthetics (Scar_Id,
                                        Scar_Sc,
                                        Scar_St,
                                        Scar_Ext_Id,
                                        Scar_Wr,
                                        Scar_Dt,
                                        Scar_Issue_Dt,
                                        Scar_End_Expl_Dt,
                                        Scar_Src,
                                        Scar_Modify_Dt)
                 VALUES (0,
                         l_Sc_Id,
                         'A',
                         Rec.Ar_Id,
                         Rec.Ar_Wr,
                         Rec.Ar_Date,
                         Rec.Ar_Issue_Date,
                         Rec.Ar_End_Expl_Dt,
                         c_Src_Cbi,
                         SYSDATE);
        END LOOP;

        --Зберігаємо інформацію про заяви на видачу автомобілів
        FOR Rec
            IN (SELECT *
                  FROM TABLE (p_Cbi_Info.Cars)  c
                       LEFT JOIN Sc_Cars Cc
                           ON c.Ap_Id = Cc.Scap_Ext_Id AND Cc.Scap_St = 'A')
        LOOP
            --Якщо в соцкартці вже існує запис з таким ІД
            IF Rec.Scap_Id IS NOT NULL
            THEN
                --Якщо атрибути не змінено, то пропускаємо цей запис
                IF     NVL (Rec.Scap_Start_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ap_Start_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scap_Qt, '#') = NVL (Rec.Ap_Qt, '#')
                   AND NVL (Rec.Scap_Number, '#') = NVL (Rec.Ap_Number, '#')
                   AND NVL (Rec.Scap_Issue_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ap_Iss_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scap_Cancel_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Ap_Cancel_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                THEN
                    CONTINUE;
                ELSE
                    --Якщо атрибути змінено, переводимо запис в історичний статус
                    UPDATE Sc_Cars c
                       SET c.Scap_St = 'H'
                     WHERE c.Scap_Id = Rec.Scap_Id;
                END IF;
            END IF;

            INSERT INTO Sc_Cars (Scap_Id,
                                 Scap_Sc,
                                 Scap_St,
                                 Scap_Ext_Id,
                                 Scap_Start_Dt,
                                 Scap_Qt,
                                 Scap_Number,
                                 Scap_Issue_Dt,
                                 Scap_Cancel_Dt,
                                 Scap_Src,
                                 Scap_Modify_Dt)
                 VALUES (0,
                         l_Sc_Id,
                         'A',
                         Rec.Ap_Id,
                         Rec.Ap_Start_Dt,
                         Rec.Ap_Qt,
                         Rec.Ap_Number,
                         Rec.Ap_Iss_Date,
                         Rec.Ap_Cancel_Dt,
                         c_Src_Cbi,
                         SYSDATE);
        END LOOP;

        --Зберігаємо інформацію про заяви на видачу санаторно-курортних путівок
        FOR Rec
            IN (SELECT *
                  FROM TABLE (p_Cbi_Info.Voucheres)  v
                       LEFT JOIN Sc_Voucheres Vv
                           ON     Vv.Scas_Sc = l_Sc_Id
                              AND v.Asr_Id = Vv.Scas_Ext_Id
                              AND Vv.Scas_St = 'A')
        LOOP
            --Якщо в соцкартці вже існує запис з таким ІД
            IF Rec.Scas_Id IS NOT NULL
            THEN
                --Якщо атрибути не змінено, то пропускаємо цей запис
                IF     NVL (Rec.Scas_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Number, '#') = NVL (Rec.Asr_Number, '#')
                   AND NVL (Rec.Scas_Place, '#') = NVL (Rec.Asr_Place, '#')
                   AND NVL (Rec.Scas_Season, '#') = NVL (Rec.Asr_Season, '#')
                   AND NVL (Rec.Scas_Pfl_Id, '#') = NVL (Rec.Asr_Pfl_Id, '#')
                   AND NVL (Rec.Scas_Ag_Id_Code, '#') =
                       NVL (Rec.Asr_Ag_Id_Code, '#')
                   AND NVL (Rec.Scas_Ag_Id_Sanatorium, '#') =
                       NVL (Rec.Asr_Ag_Id_Sanatorium, '#')
                   AND NVL (Rec.Scas_Arrival_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Arrival_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Departure_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Departure_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Price, -999999) =
                       NVL (Char2sum (Rec.Asr_Price), -999999)
                   AND NVL (Rec.Scas_Fact_Arrival_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Arrival_Fact_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Fact_Departure_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Departure_Fact_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Fact_Price, -999999) =
                       NVL (Char2sum (Rec.Asr_Fact_Price), -999999)
                   AND NVL (Rec.Scas_Renounce_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Renounce_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                   AND NVL (Rec.Scas_Renounce_Reason, '#') =
                       NVL (Rec.Asr_Renounce_Reason, '#')
                   AND NVL (Rec.Scas_Rejection_Dt,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy')) =
                       NVL (Rec.Asr_Rejection_Date,
                            TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                THEN
                    CONTINUE;
                ELSE
                    --Якщо атрибути змінено, переводимо запис в історичний статус
                    UPDATE Sc_Voucheres v
                       SET v.Scas_St = 'H'
                     WHERE v.Scas_Id = Rec.Scas_Id;
                END IF;
            END IF;

            INSERT INTO Sc_Voucheres (Scas_Id,
                                      Scas_Sc,
                                      Scas_St,
                                      Scas_Ext_Id,
                                      Scas_Dt,
                                      Scas_Number,
                                      Scas_Place,
                                      Scas_Season,
                                      Scas_Pfl_Id,
                                      Scas_Ag_Id_Code,
                                      Scas_Ag_Id_Sanatorium,
                                      Scas_Arrival_Dt,
                                      Scas_Departure_Dt,
                                      Scas_Price,
                                      Scas_Renounce_Dt,
                                      Scas_Renounce_Reason,
                                      Scas_Rejection_Dt,
                                      Scas_Fact_Arrival_Dt,
                                      Scas_Fact_Departure_Dt,
                                      Scas_Fact_Price,
                                      Scas_Modify_Dt)
                 VALUES (0,
                         l_Sc_Id,
                         'A',
                         Rec.Asr_Id,
                         Rec.Asr_Date,
                         Rec.Asr_Number,
                         Rec.Asr_Place,
                         Rec.Asr_Season,
                         Rec.Asr_Pfl_Id,
                         Rec.Asr_Ag_Id_Code,
                         Rec.Asr_Ag_Id_Sanatorium,
                         Rec.Asr_Arrival_Date,
                         Rec.Asr_Departure_Date,
                         Char2sum (Rec.Asr_Price),
                         Rec.Asr_Renounce_Date,
                         Rec.Asr_Renounce_Reason,
                         Rec.Asr_Rejection_Date,
                         Rec.Asr_Arrival_Fact_Date,
                         Rec.Asr_Departure_Fact_Date,
                         Char2sum (Rec.Asr_Fact_Price),
                         SYSDATE);
        END LOOP;

        --Реєструємо запит до Мінвету
        Dnet$exch_Mve.Reg_Create_Vet_Req (p_Sc_Id => l_Sc_Id);
    END;
END Load$cbi;
/