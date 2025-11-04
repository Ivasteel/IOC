/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE_UNI
IS
    -- Author  : KELATEV
    -- Created : 04.03.2024 09:00:03
    -- Purpose : Верифікація в ЮНІСЕФ #99087

    Pkg   VARCHAR2 (100) := 'API$MASS_EXCHANGE_UNI';

    PROCEDURE Prepare_Me_Rows (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Make_Exchange_File (p_Me_Id       Mass_Exchanges.Me_Id%TYPE,
                                  p_Jb_Id   OUT Exchangefiles.Ef_Kv_Pkt%TYPE);

    PROCEDURE Create_File_Request_Job (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Parse_File_Response (p_Pkt_Id Ikis_Rbm.v_Packet.Pkt_Id%TYPE);
END Api$mass_Exchange_Uni;
/


/* Formatted on 8/12/2025 5:49:07 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE_UNI
IS
    g_Debug_Pipe   BOOLEAN := FALSE;                                  --  true

    --=====================================================================
    FUNCTION phone_clear (p_text IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (32767) := p_text;
    BEGIN
        l_result := REGEXP_REPLACE (l_result, '\,.*$', ''); --remove second number
        l_result := REGEXP_REPLACE (l_result, '[\(\)\+- ]', ''); --remove addition symbol
        l_result := LTRIM (l_result, '38');

        IF LENGTH (l_result) != 10
        THEN
            RETURN NULL;
        END IF;

        RETURN l_result;
    END;

    --=====================================================================
    -- процедура підготовки даних
    PROCEDURE Prepare_Me_Rows (p_Me_Id Mass_Exchanges.Me_Id%TYPE)
    IS
        l_Start_Dt   DATE;
        l_Cnt        NUMBER;

        FUNCTION phone_clear (p_text IN VARCHAR2)
            RETURN VARCHAR2
        IS
            l_result   VARCHAR2 (32767) := p_text;
        BEGIN
            l_result := REGEXP_REPLACE (l_result, '\,.*$', ''); --remove second number
            l_result := REGEXP_REPLACE (l_result, '[\(\)\+- ]', ''); --remove addition symbol
            RETURN l_result;
        END;
    BEGIN
        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', START');
        END IF;

        SELECT m.Me_Month
          INTO l_Start_Dt
          FROM Mass_Exchanges m
         WHERE Me_Id = p_Me_Id;

        --Obl
        --o_Kaot_Id,o_Kaot_Code,o_Name_l1,o_Name_l2
        INSERT INTO tmp_work_set4 (x_id1,
                                   x_string1,
                                   x_string2,
                                   x_string3,
                                   x_dt1)
            SELECT t.Kaot_Id
                       o_Kaot_Id,
                   l2.kaot_code
                       o_Kaot_Code,
                   UPPER (l1.kaot_name) || '%'
                       o_Name_l1,
                   REGEXP_REPLACE (UPPER (l2.kaot_name), 'ИЙ$', '%')
                       o_Name_l2,
                   TO_DATE ('01.11.2023', 'dd.mm.yyyy')
              FROM Uss_Ndi.v_Ndi_Katottg  t,
                   Uss_Ndi.v_Ndi_Katottg  l1,
                   Uss_Ndi.v_Ndi_Katottg  l2
             WHERE     l1.kaot_id = t.kaot_kaot_l1
                   AND l2.kaot_id = t.kaot_kaot_l2
                   AND t.kaot_kaot_l2 IN (4088 /*Дніпропетровська-Дніпровський*/
                                              ,
                                          4638 /*Дніпропетровська-Криворізький*/
                                              ,
                                          5083 /*Дніпропетровська-Новомосковський*/
                                              ,
                                          5202 /*Дніпропетровська-Павлоградський*/
                                              ,
                                          9755      /*Запорізька-Запорізький*/
                                              ,
                                          24675  /*Харківська-Богодухівський*/
                                               ,
                                          26029     /*Харківська-Харківський*/
                                               ,
                                          26262     /*Харківська-Чугуївський*/
                                               );

        --1927--0.01s
        INSERT INTO tmp_work_set4 (x_id1,
                                   x_string1,
                                   x_string2,
                                   x_string3,
                                   x_dt1)
            SELECT t.Kaot_Id
                       o_Kaot_Id,
                   l2.kaot_code
                       o_Kaot_Code,
                   UPPER (l1.kaot_name) || '%'
                       o_Name_l1,
                   REGEXP_REPLACE (UPPER (l2.kaot_name), 'ИЙ$', '%')
                       o_Name_l2,
                   TO_DATE ('01.02.2024', 'dd.mm.yyyy')
              FROM Uss_Ndi.v_Ndi_Katottg  t,
                   Uss_Ndi.v_Ndi_Katottg  l1,
                   Uss_Ndi.v_Ndi_Katottg  l2
             WHERE     l1.kaot_id = t.kaot_kaot_l1
                   AND l2.kaot_id = t.kaot_kaot_l2
                   AND t.kaot_kaot_l2 IN (5701        /*Донецька-Бахмутський*/
                                              ,
                                          5821       /*Донецька-Волноваський*/
                                              ,
                                          6468      /*Донецька-Краматорський*/
                                              ,
                                          6815        /*Донецька-Покровський*/
                                              );

        --814--0.01s
        --Pd
        --pd_id, pc_sc, Sca2, Obl_Kaot, x_dt1
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_dt1)
              SELECT MAX (pd.pd_id)       pd_id,
                     Pc.pc_sc             pc_sc,
                     MAX (Sca.sca_id)     Sca2,
                     MAX (Obl.x_id1)      Obl_Kaot,
                     MAX (Obl.x_dt1)      x_dt1
                FROM Uss_Esr.Pc_Decision Pd
                     JOIN Uss_Esr.v_Personalcase Pc ON Pc.Pc_Id = Pd.Pd_Pc
                     JOIN Uss_Person.v_Sc_Address Sca
                         ON Sca.Sca_Sc = Pc.pc_sc AND Sca.Sca_Tp = 2
                     --and sca.history_status = 'A'
                     JOIN tmp_work_set4 Obl
                         ON     (   Sca.Sca_Kaot = Obl.x_id1
                                 OR (    UPPER (Sca.sca_region) LIKE
                                             Obl.x_string2
                                     AND UPPER (Sca.sca_district) LIKE
                                             Obl.x_string3))
                            AND Sca.sca_id IN
                                    (SELECT MAX (sca_id)
                                       FROM Uss_Person.v_Sc_Address
                                      WHERE     Sca_Sc = Pc.pc_sc
                                            AND Sca_Tp = 2
                                            AND (   sca_create_dt IS NULL
                                                 OR sca_create_dt <=
                                                    LAST_DAY (Obl.x_dt1) + 1)
                                            AND (   sca_kaot IS NOT NULL
                                                 OR sca_region IS NOT NULL))
               WHERE     Pd.Pd_Nst = 249
                     AND EXISTS
                             (SELECT 1
                                FROM Uss_Esr.Pd_Accrual_Period Pdap
                               WHERE     Pdap.Pdap_Pd = Pd.Pd_Id
                                     AND Pdap.History_Status = 'A'
                                     AND Obl.x_dt1 BETWEEN TRUNC (
                                                               Pdap.Pdap_Start_Dt,
                                                               'MM')
                                                       AND Pdap.Pdap_Stop_Dt)
            GROUP BY Pc.pc_sc;

        /*INSERT INTO Me_Unicef_Request_Rows
            (Murr_Id, Murr_Me, Murr_Pc, Murr_Sc, Murr_Ef, Murr_Id_Fam, Murr_Surname, Murr_Name, Murr_Patronymic,
             Murr_Bdate, Murr_n_Id, Murr_Passport, Murr_Fam_Cnt, Murr_Fam_Ch, Murr_Fam_Inv, Murr_Phone,
             Murr_Is_Vpo, Murr_Region, Murr_District, Murr_Pindex, Murr_Address, Murr_Iban, Murr_St)
      WITH src AS
         (SELECT pd.com_org r_Org,
               Pd.pd_id r_Pd,
               pd.pd_pc r_Pc,
               x_id4 r_Kaot_Id,
               (SELECT osz.kaot_code
                  FROM uss_ndi.v_ndi_katottg osz
                 WHERE osz.kaot_id = x_id4\*Kaot_Id*\) r_Kaot_Code,
               x_id4 r_Sc_App,
               (SELECT min(Pdf1.Pdf_Birth_Dt)
                  FROM Uss_Esr.Pd_Family Pdf1
                 WHERE Pdf1.Pdf_Sc = x_id2 \*pc_sc*\
                ) r_Bdate_App,
               Pdf.Pdf_Sc r_Sc_Child,
               pdf.pdf_birth_dt r_Bdate_Child,
               (SELECT Dense_Rank(Pdf.Pdf_Id) Within GROUP(ORDER BY t.Pdf_Id)
                  FROM Uss_Esr.Pd_Family t
                 WHERE Pdf_Pd = Pd.pd_id) r_Order_Child,
               (SELECT COUNT(DISTINCT Pdf1.Pdf_Id)
                  FROM Uss_Esr.Pd_Family Pdf1
                 WHERE Pdf1.Pdf_Pd = Pd.pd_id) r_Member_Full,
               (SELECT COUNT(DISTINCT Pdf1.Pdf_Id)
                  FROM Uss_Esr.Pd_Family Pdf1
                 WHERE Pdf1.Pdf_Pd = Pd.pd_id
                   AND Pdf1.Pdf_Birth_Dt >= Add_Months(p.x_dt1, -18 * 12)) r_Member_Child,
               (SELECT COUNT(DISTINCT Pdf1.Pdf_Id)
                  FROM Uss_Esr.Pd_Family Pdf1
                 WHERE Pdf1.Pdf_Pd = Pd.pd_id
                   AND Pdf1.Pdf_Birth_Dt >= Add_Months(p.x_dt1, -18 * 12)
                   and EXISTS (SELECT 1
                          FROM Uss_Person.v_Sc_Disability Scy
                          join Uss_Person.v_Socialcard Sc_Child
                            on Sc_Child.Sc_Id = Pdf.Pdf_Sc
                         WHERE Scy.History_Status = 'A'
                           AND Scy_Sc = Pdf1.Pdf_Sc
                           AND Scy_Till_Dt > p.x_dt1)) r_Member_Inv,
               phone_clear(get_doc_string(null, pd_ap, 600, 605)) as phone,
               NVL((select sca_postcode
                     from uss_person.v_sc_address
                    where sca_id = x_id3 \*sca_id*\
                   ),
                   get_doc_string(null, pd_ap, 600, 599)) as pindex,
               (select nvl((SELECT COALESCE(t.l4_kaot_full_name,
                                           t.l3_kaot_full_name,
                                           t.l2_kaot_full_name)
                             FROM uss_ndi.MV_NDI_KATOTTG t
                            WHERE kaot_id = sca_kaot),
                           sca_city) || ';' || sca_street || ';' || sca_building || ';' || CASE
                         WHEN sca_block IS NOT NULL THEN
                          ' корп. ' || sca_block
                       END || ';' ||
                       nvl2(sca_apartment, 'кв.' || sca_apartment, '')
                  from uss_person.v_sc_address
                 where sca_id = x_id3 \*sca_id*\
                ) AS address,
               (select pdm_account
                  from uss_esr.pd_pay_method pdm
                 where pdm_pd = pd_id
                   AND pdm.history_status = 'A'
                   AND pdm_is_actual = 'T'
                   and pdm_pay_tp = 'BANK'
                   and LENGTH(pdm_account) = 29 -- для Банк: якщо в параметрах виплати довжина рахунку меньше 29 символів, то не вивантажувати (їм буде зміна виплати на пошту)
                ) as iban
          FROM Uss_Esr.Pc_Decision Pd
          JOIN tmp_work_set2 p -- x_id1\*pd_id*\, x_id2\*pc_sc*\, x_id3\*sca_id*\, x_id4\*Kaot_Id*\
            ON p.x_id1 = Pd.pd_id
          JOIN Uss_Esr.Pd_Family Pdf
            ON Pdf.Pdf_Pd = x_id1 \*pd_id*\
           AND Pdf.Pdf_Birth_Dt >= Add_Months(p.x_dt1, -18 * 12)

         WHERE ( --інвалідність
                EXISTS
                (SELECT 1
                   FROM Uss_Person.v_Sc_Disability Scy
                  WHERE Scy.History_Status = 'A'
                    AND Scy_Sc = Pdf.Pdf_Sc
                    AND Scy_Till_Dt > p.x_dt1) OR
               --багатодітних сімей
                (SELECT COUNT(DISTINCT Pdf1.Pdf_Id)
                   FROM Uss_Esr.Pd_Family Pdf1
                  WHERE Pdf1.Pdf_Pd = Pd.pd_id
                    AND Pdf1.Pdf_Birth_Dt >= Add_Months(p.x_dt1, -18 * 12)) > 2)),
      src_join as
       (select r_Pd,
               Lpad(r_Order_Child, 2, '0') r_Order,
               r_Sc_Child r_Sc,
               r_Bdate_Child r_Bdate,
               r_Org,
               r_Pc,
               r_Kaot_Id,
               r_Kaot_Code,
               r_Member_Full,
               r_Member_Child,
               r_Member_Inv,
               phone,
               pindex,
               address,
               iban
          from src
        union all
        select r_Pd,
               '00' r_Order,
               r_Sc_App r_Sc,
               r_Bdate_App r_Bdate,
               r_Org,
               r_Pc,
               r_Kaot_Id,
               r_Kaot_Code,
               r_Member_Full,
               r_Member_Child,
               r_Member_Inv,
               phone,
               pindex,
               address,
               iban
          from src),
      src_distinct as
       (select r_Pd,
               min(r_Order) r_Order,
               r_Sc,
               r_Bdate,
               r_Org,
               r_Pc,
               r_Kaot_Id,
               r_Kaot_Code,
               r_Member_Full,
               r_Member_Child,
               r_Member_Inv,
               phone,
               pindex,
               address,
               iban
          from src_join
         group by r_Pd,
                  r_Sc,
                  r_Bdate,
                  r_Org,
                  r_Pc,
                  r_Kaot_Id,
                  r_Kaot_Code,
                  r_Member_Full,
                  r_Member_Child,
                  r_Member_Inv,
                  phone,
                  pindex,
                  address,
                  iban)
      select rownum,
             null,
             r_pc,
             r_Sc,
             null,
             '1' || Substr(r_Kaot_Code, 3, 4) || Substr(r_Org, 3, 3) ||
             Lpad(r_Pd, 12, '0') || r_Order "ID_FAM",
             Sci.Sci_Ln "SURNAME",
             Sci.Sci_Fn "NAME",
             Sci.Sci_Mn "PATRONYMIC",
             r_Bdate "BDATE",
             (SELECT replace(replace(Nvl(MAX(Scd_Number), '0000000000'),
                                     'НЕМАЄ',
                                     '0000000000'),
                             'НІ',
                             '0000000000')
                FROM Uss_Person.v_Sc_Document
               WHERE Scd_Sc = r_Sc
                 AND Scd_Ndt = 5
                 AND Scd_St = '1') "N_ID",
             (SELECT MAX(Scd_Seria || Scd_Number)
                FROM Uss_Person.v_Sc_Document
               WHERE Scd_Sc = r_Sc
                 AND Scd_Ndt IN (6, 7, 37, 673)
                 AND Scd_St = '1') "PASSPORT",
             r_Member_Full "FAM_CNT",
             r_Member_Child "FAM_CH",
             r_Member_Inv "FAM_INV",
             phone "PHONЕ",
             (select count(*)
                from uss_person.v_sc_document d
               where d.scd_sc = r_Sc
                 and d.scd_ndt = 10052
                 AND d.scd_st = '1') "VPO",
             (SELECT MAX(obl.kaot_name)
                FROM uss_ndi.v_ndi_katottg osz, uss_ndi.v_ndi_katottg obl
               WHERE osz.kaot_kaot_l1 = obl.kaot_id
                 and osz.kaot_id = r_Kaot_Id) AS "REGION",
             (SELECT MAX(rn.kaot_name)
                FROM uss_ndi.v_ndi_katottg osz, uss_ndi.v_ndi_katottg rn
               WHERE osz.kaot_kaot_l2 = rn.kaot_id
                 and osz.kaot_id = r_Kaot_Id) AS "DISTRICT",
             pindex "PINDEX",
             address "ADDRESS",
             iban "IBAN",
             'A'
        from src_distinct
        JOIN Uss_Person.v_Socialcard Sc
          ON Sc.Sc_Id = r_Sc
        JOIN Uss_Person.v_Sc_Change Scc
          ON Scc.Scc_Id = Sc.Sc_Scc
        JOIN Uss_Person.v_Sc_Identity Sci
          ON Scc.Scc_Sci = Sci.Sci_Id;
        */


        l_Cnt := SQL%ROWCOUNT;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', INSERTED: ' || l_Cnt);
        END IF;

        UPDATE Mass_Exchanges m
           SET m.Me_Count = l_Cnt, m.Me_St = Api$mass_Exchange.c_St_Me_Exists
         WHERE Me_Id = p_Me_Id;
    END;

    --=====================================================================
    --Кнопка "Сформувати файл"
    PROCEDURE Make_Exchange_File (p_Me_Id       Mass_Exchanges.Me_Id%TYPE,
                                  p_Jb_Id   OUT Exchangefiles.Ef_Kv_Pkt%TYPE)
    IS
        l_Prev_St        Mass_Exchanges.Me_St%TYPE;
        l_Prev_St_Name   VARCHAR2 (250);
    BEGIN
        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', p_me_id=' || p_Me_Id);
        END IF;

        SELECT Me_St, Dic_Name
          INTO l_Prev_St, l_Prev_St_Name
          FROM Mass_Exchanges
               JOIN Uss_Ndi.v_Ddn_Me_St St ON (St.Dic_Value = Me_St)
         WHERE Me_Id = p_Me_Id;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', l_prev_st=' || l_Prev_St);
        END IF;

        IF l_Prev_St = Api$mass_Exchange.c_St_Me_Exists
        THEN
            UPDATE Mass_Exchanges
               SET Me_St = Api$mass_Exchange.c_St_Me_File
             WHERE Me_Id = p_Me_Id;

            COMMIT;
            Tools.Submitschedule (
                p_Jb       => p_Jb_Id,
                p_Subsys   => 'USS_ESR',
                p_Wjt      => 'ME_FILE_CREATION',
                p_What     =>
                       'begin uss_esr.'
                    || Pkg
                    || '.Create_File_Request_Job(p_me_id => '
                    || p_Me_Id
                    || '); end;');
        ELSIF l_Prev_St = Api$mass_Exchange.c_St_Me_File
        THEN
            Raise_Application_Error (
                -20000,
                'Пакет у статусі "Формується файл обміну". Якщо пакет перебуває у цьому стані тривалий час - зверніться до адміністратора системи.');
        ELSE
            Raise_Application_Error (
                -20000,
                   'Неможливо формувати файл з пакета у статусі обміну "'
                || l_Prev_St_Name
                || '"!');
        END IF;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', p_jb_id=' || p_Jb_Id);
        END IF;

        UPDATE Mass_Exchanges
           SET Me_Jb = p_Jb_Id
         WHERE Me_Id = p_Me_Id;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', END');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_Debug_Pipe
            THEN
                Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                    Pkg || '.' || $$PLSQL_UNIT || ', EXCEPTION');
            END IF;

            UPDATE Mass_Exchanges
               SET Me_St = l_Prev_St
             WHERE Me_Id = p_Me_Id;

            COMMIT;
            RAISE;
    END;

    --=====================================================================
    PROCEDURE Create_File_Request_Job (p_Me_Id Mass_Exchanges.Me_Id%TYPE)
    IS
        l_Filter        VARCHAR2 (250);
        l_Filename      VARCHAR2 (250);
        l_Zip_Name      VARCHAR2 (250);
        l_Ecs           Exchcreatesession.Ecs_Id%TYPE;
        l_Ef            Exchangefiles.Ef_Id%TYPE;
        l_Pkt           Exchangefiles.Ef_Pkt%TYPE;
        l_Cnt           PLS_INTEGER;
        l_Com_Wu        NUMBER := Tools.Getcurrwu;
        l_Me_Count      PLS_INTEGER;
        l_Rec           NUMBER := 23;                   /*ikis_rbm.recipient*/
        l_Sql           VARCHAR2 (32000);
        l_Csv_Blob      BLOB;
        l_Zip_Blob      BLOB;
        l_Vis_Clob      CLOB;
        l_Date_Format   VARCHAR2 (20) := 'DD.MM.YYYY';
    BEGIN
        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', p_me_id=' || p_Me_Id);
        END IF;

        SELECT m.Me_Count
          INTO l_Me_Count
          FROM Mass_Exchanges m
         WHERE m.Me_Id = p_Me_Id;

        -- захист від дублювання файлів
        l_Filter := 'ME#' || p_Me_Id || '#MSP2UNI';

        SELECT COUNT (1)
          INTO l_Cnt
          FROM Exchcreatesession
         WHERE Ecs_Filter = l_Filter;

        IF l_Cnt > 0
        THEN
            Raise_Application_Error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        -- реєструємо сесію формування файлів обміну
        INSERT INTO Exchcreatesession (Ecs_Id, Ecs_Start_Dt, Ecs_Filter)
             VALUES (0, SYSDATE, l_Filter)
          RETURNING Ecs_Id
               INTO l_Ecs;

        /*l_Sql := 'SELECT murr_id_fam as "ID_FAM",
              murr_surname as "SURNAME",
              murr_name as "NAME",
              murr_patronymic as "PATRONYMIC",
              murr_bdate as "BDATE",
              murr_n_id as "N_ID",
              murr_passport as "PASSPORT",
              murr_fam_cnt as "FAM_CNT",
              murr_fam_ch as "FAM_CH",
              murr_fam_inv as "FAM_INV",
              murr_phone as "PHONЕ",
              murr_is_vpo as "VPO",
              murr_region as "REGION",
              murr_district as "DISTRICT",
              murr_pindex as "PINDEX",
              murr_address as "ADDRESS",
              murr_iban as "IBAN"
         FROM me_unicef_request_rows r
        WHERE r.murr_me = ' || p_Me_Id;*/

        -- формуємо csv
        Api$mass_Exchange.Build_Csv (p_Sql => l_Sql, p_Csv_Blob => l_Csv_Blob);

        IF l_Csv_Blob IS NULL OR DBMS_LOB.Getlength (l_Csv_Blob) < 100
        THEN
            Raise_Application_Error (
                -20000,
                'Помилка формування файлу обміну - файл порожній!');
        END IF;

        -- Ім’я файлів інформаційного обміну формується за такими масками VVV2OOO_DSD507_YYYYMMDD.CSV
        l_Filename :=
            'MSP2UNI_DSD507_' || TO_CHAR (SYSDATE, 'yyyymmdd') || '.csv';
        l_Zip_Name :=
            'MSP2UNI_DSD507_' || TO_CHAR (SYSDATE, 'yyyymmdd') || '.zip';

        l_Zip_Blob :=
            Tools.Tozip2 (p_File_Blob => l_Csv_Blob, p_File_Name => l_Filename);

        l_Vis_Clob :=
               'Файл '
            || l_Filename
            || '<br>'
            || 'за даними державних допомог Єдиної інформаційної системи соціальної сфери Міністерства соціальної політики України'
            || '<br>'
            || 'Кількість рядків: '
            || l_Me_Count;

        INSERT INTO Exchangefiles (Ef_Id,
                                   Ef_Po,
                                   Com_Org,
                                   Com_Wu,
                                   Ef_Tp,
                                   Ef_Name,
                                   Ef_Data,
                                   Ef_Visual_Data,
                                   Ef_Header,
                                   Ef_Main_Tag_Name,
                                   Ef_Data_Name,
                                   Ef_Ecp_List_Name,
                                   Ef_Ecp_Name,
                                   Ef_Ecp_Alg,
                                   Ef_St,
                                   Ef_Dt,
                                   Ef_Ident_Data,
                                   Ef_Ecs,
                                   Ef_Rec,
                                   Ef_File_Idn,
                                   Ef_Pkt,
                                   Ef_File_Name)
             VALUES (NULL,
                     NULL,
                     50000,
                     l_Com_Wu,
                     'MSP2UNI',
                     l_Zip_Name,
                     l_Zip_Blob,
                     l_Vis_Clob,
                     NULL,
                     'MSP2UNI',
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     'Z',
                     SYSDATE,
                     NULL,
                     l_Ecs,
                     l_Rec,
                     NULL,
                     NULL,
                     l_Filename)
          RETURNING Ef_Id
               INTO l_Ef;

        -- заливаємо дані в ПЕОД
        INSERT INTO Ikis_Rbm.Tmp_Exchangefiles_M1 (Ef_Id,
                                                   Ef_Pr,
                                                   Com_Wu,
                                                   Com_Org,
                                                   Ef_Tp,
                                                   Ef_Name,
                                                   Ef_Data,
                                                   Ef_Visual_Data,
                                                   Ef_Header,
                                                   Ef_Main_Tag_Name,
                                                   Ef_Data_Name,
                                                   Ef_Ecp_List_Name,
                                                   Ef_Ecp_Name,
                                                   Ef_Ecp_Alg,
                                                   Ef_St,
                                                   Ef_Dt,
                                                   Ef_Ident_Data,
                                                   Ef_Ecs,
                                                   Ef_Rec)
            SELECT Ef_Id,
                   Ef_Pr,
                   Com_Wu,
                   Com_Org,
                   Ef_Tp,
                   Ef_Name,
                   Ef_Data,
                   Ef_Visual_Data,
                   Ef_Header,
                   Ef_Main_Tag_Name,
                   Ef_Data_Name,
                   Ef_Ecp_List_Name,
                   Ef_Ecp_Name,
                   Ef_Ecp_Alg,
                   Ef_St,
                   Ef_Dt,
                   Ef_Ident_Data,
                   Ef_Ecs,
                   Ef_Rec
              FROM Exchangefiles
             WHERE Ef_Ecs = l_Ecs;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', ef_ecs=' || l_Ecs);
        END IF;

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        Ikis_Rbm.Rdm$app_Exchange.Genpaketsfromtmptable;

        SELECT Ef_Pkt
          INTO l_Pkt
          FROM Ikis_Rbm.Tmp_Exchangefiles_M1
         WHERE Ef_Id = l_Ef;

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', ef_pkt=' || l_Pkt);
        END IF;

        UPDATE Exchangefiles f
           SET Ef_Pkt = l_Pkt
         WHERE Ef_Id = l_Ef;

        UPDATE Exchcreatesession
           SET Ecs_Stop_Dt = SYSDATE
         WHERE Ecs_Id = l_Ecs;

        -- зміна статусів на етапі А0.1 "Формування файлу для поточної верифікації"
        -- прописуємо ід пакета в таблицю обміну
        UPDATE Mass_Exchanges m
           SET Me_Pkt = l_Pkt, Me_St = Api$mass_Exchange.c_St_Me_Sent
         WHERE Me_Id = p_Me_Id AND Me_Pkt IS NULL;

        -- serhii: ^ me_pkt ^ повинен містити Ід файла з данними допомг, що відправлений в ПЕОД. Не можна його перезаписувати

        -- прописуємо ід файла обміну в таблицю рядків
        /*UPDATE Me_Unicef_Request_Rows
          SET Murr_Ef = l_Ef, Murr_St = Api$mass_Exchange.c_St_Memr_Sent
        WHERE Murr_Me = p_Me_Id;*/

        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ' END, p_me_id=' || p_Me_Id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_Debug_Pipe
            THEN
                Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                       Pkg
                    || '.'
                    || $$PLSQL_UNIT
                    || ', EXCEPTION:'
                    || CHR (10)
                    || SQLERRM);
            END IF;

            ROLLBACK;

            UPDATE Mass_Exchanges
               SET Me_St = Api$mass_Exchange.c_St_Me_Exists
             WHERE Me_Id = p_Me_Id;

            COMMIT;
            RAISE;
    END;

    --=====================================================================
    -- 4. Результатом завантаженого файлу відповіді є записи в таблиці me_unicef_result_rows.
    -- + формуємо html-таблицю і записуємо в pc_visual_data для відображення.
    -- p_pkt_id - ід пакета ПЕОД
    -- Файл Рекомендації повинен завантажуватися через картку пакета відповідного запиту!!!!
    PROCEDURE Parse_File_Response (p_Pkt_Id Ikis_Rbm.v_Packet.Pkt_Id%TYPE)
    IS
        l_Clob          CLOB;
        l_Pc_Name       Ikis_Rbm.v_Packet_Content.Pc_Name%TYPE;
        l_Com_Wu        NUMBER := Tools.Getcurrwu;
        l_Me_Id         NUMBER;
        l_Ef_Id         NUMBER;
        l_Ecs           NUMBER;
        l_Rec_Id        NUMBER := 23;                   /*ikis_rbm.recipient*/
        l_File_Name     VARCHAR2 (250);
        l_File_Blob     BLOB;
        l_Zip_Blob      BLOB;
        l_Lines_Cnt     NUMBER;
        l_Date_Format   VARCHAR2 (20) := 'dd.mm.yyyy';
    BEGIN
        SELECT Pc_Data, UPPER (Pc_Name)
          INTO l_Zip_Blob, l_Pc_Name
          FROM Ikis_Rbm.v_Packet  p
               JOIN Ikis_Rbm.v_Packet_Content c ON Pc_Pkt = Pkt_Id
         WHERE Pkt_Id = p_Pkt_Id AND Pkt_St = 'N' AND Pkt_Pat IN (123); -- uni_report = Файл – звіт. Надається ЮНІСЕФ

        BEGIN
            Tools.Unzip2 (p_Zip_Blob    => l_Zip_Blob,
                          p_File_Blob   => l_File_Blob,
                          p_File_Name   => l_File_Name);
            l_Clob := Tools.Convertb2c (l_File_Blob);
            l_Pc_Name := l_File_Name;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                       'Помилка обробки архіву.'
                    || CHR (10)
                    || 'Перевірте відповідність файлу "'
                    || l_Pc_Name
                    || '" вимогам протоколу обміну.'
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Backtrace
                    || CHR (10)
                    || SQLERRM);
        END;

        IF UPPER (SUBSTR (l_Pc_Name, -4)) != '.CSV'
        THEN
            l_Pc_Name := l_Pc_Name || '.CSV';
        END IF;

        SELECT m.Me_Id
          INTO l_Me_Id
          FROM Ikis_Rbm.v_Packet_Links  x
               JOIN Mass_Exchanges m ON m.Me_Pkt = x.Pl_Pkt_Out
         WHERE x.Pl_Pkt_In = p_Pkt_Id;

        /*INSERT INTO Me_Unicef_Result_Rows
        (Musr_Id, Musr_Me, Musr_Pc, Musr_Murr, Musr_Ef, Musr_Id_Fam, Musr_Payment, Musr_Pdate, Musr_St)
        SELECT NULL, l_Me_Id, NULL, NULL, NULL, NULL, Col001 AS ID_FAM,
               decode(Col002, 0, 'F', 1, 'T', Col002) AS PAYMENT, Tools.tdate(Col003) AS PDATE, NULL
          FROM TABLE(Csv_Util_Pkg.Clob_To_Csv(l_Clob)) p
         WHERE Col001 IS NOT NULL
           AND Line_Number > 1;*/
        l_Lines_Cnt := SQL%ROWCOUNT;

        IF l_Lines_Cnt = 0
        THEN
            Raise_Application_Error (
                -20000,
                   'З файлу "'
                || l_Pc_Name
                || '" не вдалося завантажити жодного рядка.');
        END IF;

        Ikis_Rbm.Rdm$app_Exchange.Set_Visual_Data (
            p_Pkt_Id        => p_Pkt_Id,
            p_Visual_Data   => l_Pc_Name);       -- #94133 l_clob -> l_pc_name

        Ikis_Rbm.Rdm$packet.Set_Packet_State (p_Pkt_Id          => p_Pkt_Id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_Com_Wu,
                                              p_Pkt_Change_Dt   => SYSDATE);

        -- записуємо файл в exchangefiles
        -- варто залишити, щоб зберегти зв'язок з джерелом через me_dps_result_rows.mpsr_ef + exchangefiles.ef_pkt
        INSERT INTO Exchangefiles (Ef_Id,
                                   Com_Org,
                                   Com_Wu,
                                   Ef_Tp,
                                   Ef_Name,
                                   Ef_Data,
                                   Ef_Visual_Data,
                                   Ef_Header,
                                   Ef_Main_Tag_Name,
                                   Ef_Data_Name,
                                   Ef_Ecp_List_Name,
                                   Ef_Ecp_Name,
                                   Ef_Ecp_Alg,
                                   Ef_St,
                                   Ef_Dt,
                                   Ef_Ident_Data,
                                   Ef_Ecs,
                                   Ef_Rec,
                                   Ef_File_Idn,
                                   Ef_Pkt,
                                   Ef_File_Name)
             VALUES (NULL,
                     50000,
                     l_Com_Wu,
                     'UNI2MSP',
                     l_Pc_Name,
                     l_Zip_Blob,
                     l_Clob,
                     NULL,
                     'UNI2MSP',
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     'Z',
                     SYSDATE,
                     NULL,
                     l_Ecs,
                     l_Rec_Id,
                     NULL,
                     p_Pkt_Id,
                     l_Pc_Name)
          RETURNING Ef_Id
               INTO l_Ef_Id;

        /*UPDATE Me_Unicef_Result_Rows r
          SET r.Musr_Ef = l_Ef_Id,
              r.Musr_Pc =
               (SELECT MIN(Murr_Pc)
                  FROM Uss_Esr.Me_Unicef_Request_Rows
                 WHERE Murr_Id_Fam = Musr_Id_Fam),
              r.Musr_Murr =
               (SELECT MIN(Murr_Id)
                  FROM Uss_Esr.Me_Unicef_Request_Rows
                 WHERE Murr_Id_Fam = Musr_Id_Fam)
        WHERE r.Musr_Me = l_Me_Id;*/

        UPDATE Mass_Exchanges
           SET Me_St = Api$mass_Exchange.c_St_Me_Loaded
         WHERE Me_Id = l_Me_Id;
    END;
--=====================================================================

END Api$mass_Exchange_Uni;
/