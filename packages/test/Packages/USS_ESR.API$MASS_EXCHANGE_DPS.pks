/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE_DPS
IS
    -- Author  : KELATEV
    -- Created : 12.02.2024 15:52:03
    -- Purpose : Верифікація в ДПС #97928

    --Uss_Ndi.V_DDN_MPSR_RESULT
    --Uss_Ndi.V_DDN_MPSR_N_CLOSE_REASON
    --Uss_Ndi.V_DDN_MPSR_RESULT_INCOME

    Pkg   VARCHAR2 (100) := 'API$MASS_EXCHANGE_DPS';

    FUNCTION Get_Full_Address (p_Sca_Sc IN NUMBER, p_Sca_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Prepare_Me_Rows (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Make_Me_Packet (p_Me_Tp          Mass_Exchanges.Me_Tp%TYPE,
                              p_Me_Month       Mass_Exchanges.Me_Month%TYPE,
                              p_Me_Id      OUT Mass_Exchanges.Me_Id%TYPE,
                              p_Me_Jb      OUT Mass_Exchanges.Me_Jb%TYPE);

    PROCEDURE Make_Exchange_File (p_Me_Id       Mass_Exchanges.Me_Id%TYPE,
                                  p_Jb_Id   OUT Exchangefiles.Ef_Kv_Pkt%TYPE);

    PROCEDURE Create_File_Request_Job (p_Me_Id Mass_Exchanges.Me_Id%TYPE);

    PROCEDURE Parse_File_Response (p_Pkt_Id Ikis_Rbm.v_Packet.Pkt_Id%TYPE);
END Api$mass_Exchange_Dps;
/


/* Formatted on 8/12/2025 5:49:07 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE_DPS
IS
    g_Debug_Pipe   BOOLEAN := FALSE;                                  --  true

    --=====================================================================
    FUNCTION Get_Full_Address (p_Sca_Sc IN NUMBER, p_Sca_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Addr   VARCHAR2 (32767);
    BEGIN
        SELECT MAX (
                   RTRIM (
                          Sca.Sca_Postcode
                       || NVL2 (Sca.Sca_Postcode, ', ', NULL)
                       || CASE
                              WHEN Sca.Sca_Country IS NOT NULL
                              THEN
                                  Sca.Sca_Country || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_Region IS NOT NULL
                              THEN
                                  'область: ' || Sca.Sca_Region || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_District IS NOT NULL
                              THEN
                                  'район: ' || Sca.Sca_District || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_City IS NOT NULL
                              THEN
                                  Sca.Sca_City || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_Street IS NOT NULL
                              THEN
                                  'вулиця: ' || Sca.Sca_Street || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_Building IS NOT NULL
                              THEN
                                     'номер по вулиці: '
                                  || REPLACE (Sca.Sca_Building, CHR (10))
                                  || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_Block IS NOT NULL
                              THEN
                                     'корпус: '
                                  || REPLACE (Sca.Sca_Block, CHR (10))
                                  || ', '
                          END
                       || CASE
                              WHEN Sca.Sca_Apartment IS NOT NULL
                              THEN
                                     'кв.: '
                                  || REPLACE (Sca.Sca_Apartment, CHR (10))
                          END,
                       ', '))
          INTO l_Addr
          FROM Uss_Person.v_Sc_Address Sca
         WHERE     Sca.Sca_Sc = p_Sca_Sc
               AND Sca.Sca_Tp = p_Sca_Tp
               AND Sca.History_Status = 'A';

        RETURN l_Addr;
    END;

    --=====================================================================
    -- процедура підготовки даних
    PROCEDURE Prepare_Me_Rows (p_Me_Id Mass_Exchanges.Me_Id%TYPE)
    IS
        l_Stop_Dt    DATE;
        l_Cnt        NUMBER;

        l_Period_q   NUMBER;
        l_Period_y   NUMBER;
    BEGIN
        IF g_Debug_Pipe
        THEN
            Ikis_Sysweb.Ikis_Debug_Pipe.Writemsg (
                Pkg || '.' || $$PLSQL_UNIT || ', START');
        END IF;

        SELECT m.Me_Month
          INTO l_Stop_Dt
          FROM Mass_Exchanges m
         WHERE Me_Id = p_Me_Id;

        l_Period_q := TO_NUMBER (TO_CHAR (TRUNC (l_Stop_Dt, 'Q') - 1, 'Q'));
        l_Period_y :=
            TO_NUMBER (TO_CHAR (TRUNC (l_Stop_Dt, 'Q') - 1, 'YYYY'));

        INSERT INTO Me_Dps_Request_Rows (Mprr_Id,
                                         Mprr_Me,
                                         Mprr_Pc,
                                         Mprr_Ef,
                                         Mprr_Id_Fam,
                                         Mprr_Surname,
                                         Mprr_Name,
                                         Mprr_Patronymic,
                                         Mprr_Birth_Dt,
                                         Mprr_Birth_Place,
                                         Mprr_n_Id,
                                         Mprr_Gender,
                                         Mprr_Doctype,
                                         Mprr_Series,
                                         Mprr_Numb,
                                         Mprr_Doc_Dt,
                                         Mprr_Doc_Issuer,
                                         Mprr_r_Address,
                                         Mprr_f_Address,
                                         Mprr_Begin_q,
                                         Mprr_Begin_y,
                                         Mprr_End_q,
                                         Mprr_End_y,
                                         Mprr_St)
            SELECT 0,
                   p_Me_Id,
                   Pd.Pd_Pc,
                   NULL,
                      '1'
                   || LPAD ('' || Pd.Pd_Id, 15, '0')
                   || LPAD (REPLACE (NVL (Sc.Sc_Unique, 0), 'T', '9'),
                            14,
                            '0'),
                   Sci.Sci_Ln,
                   Sci.Sci_Fn,
                   Sci.Sci_Mn,
                   Pdf.Pdf_Birth_Dt
                       AS "DATE_BIRTH",
                   Api$mass_Exchange_Dps.Get_Full_Address (
                       p_Sca_Sc   => Sc.Sc_Id,
                       p_Sca_Tp   => 1                    /*Місце народження*/
                                      )
                       AS "BIRTH_PLACE",
                   NVL (Scd_Ipn.Scd_Number,
                        Scd_Pass.Scd_Seria || Scd_Pass.Scd_Number)
                       AS "RNOKPP",
                   DECODE (Sci.Sci_Gender, 'F', 'Жінка', 'Чоловік')
                       AS "GENDER",
                   DECODE (Scd_Ident.Scd_Ndt,  6, 6,  7, 7,  37, 37,  99)
                       "DOCUMENT_TYPE",
                   Scd_Ident.Scd_Seria
                       "SERIES",
                   Scd_Ident.Scd_Number
                       "NUMBER",
                   Scd_Ident.Scd_Issued_Dt
                       AS "DOCUMENT_DATE",
                   Scd_Ident.Scd_Issued_Who
                       AS "DOCUMENT_ISSUER",
                   Api$mass_Exchange_Dps.Get_Full_Address (
                       p_Sca_Sc   => Sc.Sc_Id,
                       p_Sca_Tp   => 3                    /*Місце реєстрації*/
                                      )
                       AS "REG_ADDRESS",
                   Api$mass_Exchange_Dps.Get_Full_Address (
                       p_Sca_Sc   => Sc.Sc_Id,
                       p_Sca_Tp   => 2                    /*Місце проживання*/
                                      )
                       AS "FACT_ADDRESS",
                   l_Period_q,
                   l_Period_y,
                   l_Period_q,
                   l_Period_y,
                   NULL
              FROM Uss_Esr.Pc_Decision  Pd
                   JOIN Uss_Esr.Pd_Family Pdf ON Pdf.Pdf_Pd = Pd.Pd_Id
                   JOIN Uss_Person.v_Socialcard Sc ON Sc.Sc_Id = Pdf.Pdf_Sc
                   JOIN Uss_Person.v_Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                   JOIN Uss_Person.v_Sc_Identity Sci
                       ON Scc.Scc_Sci = Sci.Sci_Id
                   LEFT JOIN Uss_Person.v_Sc_Document Scd_Ipn
                       ON     Scd_Ipn.Scd_Sc = Sc.Sc_Id
                          AND Scd_Ipn.Scd_Ndt = 5
                          AND Scd_Ipn.Scd_St = '1'
                   LEFT JOIN Uss_Person.v_Sc_Document Scd_Pass
                       ON     Scd_Pass.Scd_Sc = Sc.Sc_Id
                          AND Scd_Pass.Scd_Ndt IN (6, 7)
                          AND Scd_Pass.Scd_St = '1'
                   LEFT JOIN
                   (  SELECT Scd_Pass1.Scd_Sc,
                             MIN (Scd_Pass1.Scd_Ndt)     Min_Scd_Ndt
                        FROM Uss_Person.v_Sc_Document Scd_Pass1
                       WHERE     Scd_Pass1.Scd_Ndt IN (6,
                                                       7,
                                                       8,
                                                       9,
                                                       37)
                             AND Scd_Pass1.Scd_St = '1'
                    GROUP BY Scd_Sc) Scd_Ident_Min
                       ON Scd_Ident_Min.Scd_Sc = Sc.Sc_Id
                   LEFT JOIN Uss_Person.v_Sc_Document Scd_Ident
                       ON     Scd_Ident.Scd_Sc = Sc.Sc_Id
                          AND Scd_Ident.Scd_Ndt = Scd_Ident_Min.Min_Scd_Ndt
                          AND Scd_Ident.Scd_St = '1'
             WHERE     Pd.Pd_Nst = 664                                 /*ВПО*/
                   AND (   Pd.Pd_St = 'S'                       /*Нараховано*/
                        OR (    Pd.Pd_St = 'PS'        /*Призупинено виплату*/
                            AND EXISTS
                                    (SELECT 1
                                       FROM Uss_Ndi.v_Ndi_Reason_Not_Pay  r
                                            LEFT JOIN Uss_Esr.Pc_Block Pcb
                                                ON Pd.Pd_Pcb = Pcb.Pcb_Id
                                      WHERE     r.Rnp_Id = Pcb.Pcb_Rnp
                                            AND r.Rnp_Pnp_Tp = 'CPY'
                                            AND r.History_Status = 'A')))
                   AND EXISTS
                           (SELECT 1
                              FROM Uss_Esr.Pd_Accrual_Period Pdap
                             WHERE     Pdap.Pdap_Pd = Pd.Pd_Id
                                   AND Pdap.History_Status = 'A'
                                   AND LAST_DAY (l_Stop_Dt) BETWEEN Pdap.Pdap_Start_Dt
                                                                AND Pdap.Pdap_Stop_Dt);


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
    --Сформувати пакет
    PROCEDURE Make_Me_Packet (p_Me_Tp          Mass_Exchanges.Me_Tp%TYPE,
                              p_Me_Month       Mass_Exchanges.Me_Month%TYPE,
                              p_Me_Id      OUT Mass_Exchanges.Me_Id%TYPE,
                              p_Me_Jb      OUT Mass_Exchanges.Me_Jb%TYPE)
    IS
        l_Hs_Id   INTEGER := Tools.Gethistsession;
        l_Cnt     INTEGER;
    BEGIN
        -- 0. контролі
        -- 0.1 перевіряємо на відсутність нескасованих записів відповідного місяця
        SELECT COUNT (1)
          INTO l_Cnt
          FROM Mass_Exchanges m
         WHERE     m.Me_Tp = p_Me_Tp
               AND m.Me_St IN (Api$mass_Exchange.c_St_Me_Creating,
                               Api$mass_Exchange.c_St_Me_Exists,
                               Api$mass_Exchange.c_St_Me_File,
                               Api$mass_Exchange.c_St_Me_Ready2send);

        IF l_Cnt > 0
        THEN
            Raise_Application_Error (
                -20000,
                'Помилка підготовки даних для обміну: Існує запущений процес обміну!');
        END IF;

        -- 1. реєструємо запис
        INSERT INTO Mass_Exchanges (Me_Id,
                                    Me_Tp,
                                    Me_Month,
                                    Me_Dt,
                                    Me_St,
                                    Me_Hs_Ins)
             VALUES (NULL,
                     p_Me_Tp,
                     p_Me_Month,
                     TRUNC (SYSDATE),
                     Api$mass_Exchange.c_St_Me_Creating,
                     l_Hs_Id)
          RETURNING Me_Id
               INTO p_Me_Id;

        COMMIT;
        -- 2. запускаємо джоб підготовки даних
        Tools.Submitschedule (
            p_Jb       => p_Me_Jb,
            p_Subsys   => 'USS_ESR',
            p_Wjt      => 'ME_ROWS_PREPARE',
            p_What     =>
                   'begin uss_esr.'
                || Pkg
                || '.Prepare_Me_Rows('
                || p_Me_Id
                || '); end;');

        UPDATE Mass_Exchanges
           SET Me_Jb = p_Me_Jb
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
        l_Rec           NUMBER := 22;                   /*ikis_rbm.recipient*/
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
        l_Filter := 'ME#' || p_Me_Id || '#MSP2DPS';

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

        l_Sql := 'SELECT to_char(mprr_id) as "ID_REQ",
                     mprr_id_fam as "ID_REESTR",
                     mprr_surname as "LAST_NAME",
                     mprr_name as "FIRST_NAME",
                     mprr_patronymic as "SECOND_NAME",
                     mprr_birth_dt as "DATE_BIRTH",
                     mprr_birth_place as "BIRTH_PLACE",
                     mprr_n_id as "RNOKPP",
                     mprr_gender as "GENDER",
                     to_number(mprr_doctype) as "DOCUMENT_TYPE",
                     mprr_series as "SERIES",
                     mprr_numb as "NUMBER",
                     mprr_doc_dt as "DOCUMENT_DATE",
                     mprr_doc_issuer as "DOCUMENT_ISSUER",
                     mprr_r_address as "REG_ADDRESS",
                     mprr_f_address as "FACT_ADDRESS",
                     mprr_begin_q as "PERIOD_BEGIN_QUARTER",
                     mprr_begin_y as "PERIOD_BEGIN_YEAR",
                     mprr_end_q as "PERIOD_END_QUARTER",
                     mprr_end_y as "PERIOD_END_YEAR"
                FROM me_dps_request_rows r
               WHERE r.mprr_me = ' || p_Me_Id;

        -- формуємо csv
        Api$mass_Exchange.Build_Csv (p_Sql => l_Sql, p_Csv_Blob => l_Csv_Blob);

        IF l_Csv_Blob IS NULL OR DBMS_LOB.Getlength (l_Csv_Blob) < 100
        THEN
            Raise_Application_Error (
                -20000,
                'Помилка формування файлу обміну - файл порожній!');
        END IF;

        -- Ім’я файлів інформаційного обміну формується за такими масками PERSON.CSV
        l_Filename := 'PERSON.csv';
        l_Zip_Name := 'PERSON.zip';

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
                     'MSP2DPS',
                     l_Zip_Name,
                     l_Zip_Blob,
                     l_Vis_Clob,
                     NULL,
                     'MSP2DPS',
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
        UPDATE Me_Dps_Request_Rows
           SET Mprr_Ef = l_Ef, Mprr_St = Api$mass_Exchange.c_St_Memr_Sent
         WHERE Mprr_Me = p_Me_Id;

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
    -- 4. Результатом завантаженого файлу відповіді є записи в таблиці me_dps_result_rows.
    -- + формуємо html-таблицю і записуємо в pc_visual_data для відображення.
    -- p_pkt_id - ід пакета ПЕОД
    -- Файл Рекомендації повинен завантажуватися через картку пакета відповідного запиту!!!!
    PROCEDURE Parse_File_Response (p_Pkt_Id Ikis_Rbm.v_Packet.Pkt_Id%TYPE)
    IS
        l_Clob        CLOB;
        l_Pc_Name     Ikis_Rbm.v_Packet_Content.Pc_Name%TYPE;
        l_Com_Wu      NUMBER := Tools.Getcurrwu;
        l_Me_Id       NUMBER;
        l_Ef_Id       NUMBER;
        l_Ecs         NUMBER;
        l_Rec_Id      NUMBER := 22;                     /*ikis_rbm.recipient*/
        l_File_Name   VARCHAR2 (250);
        l_File_Blob   BLOB;
        l_Zip_Blob    BLOB;
        l_Lines_Cnt   NUMBER;
    BEGIN
        SELECT Pc_Data, UPPER (Pc_Name)
          INTO l_Zip_Blob, l_Pc_Name
          FROM Ikis_Rbm.v_Packet  p
               JOIN Ikis_Rbm.v_Packet_Content c ON Pc_Pkt = Pkt_Id
         WHERE Pkt_Id = p_Pkt_Id AND Pkt_St = 'N' AND Pkt_Pat IN (109); -- dps_vrf_resp = Файл обліку осіб які шукають роботу з ДПС

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

        INSERT INTO Me_Dps_Result_Rows (Mpsr_Id,
                                        Mpsr_Me,
                                        Mpsr_Pc,
                                        Mpsr_Mprr,
                                        Mpsr_Ef,
                                        Mpsr_Id_Fam,
                                        Mpsr_Id_Resp,
                                        Mpsr_n_Id,
                                        Mpsr_Result,
                                        Mpsr_n_Close_Dt,
                                        Mpsr_n_Close_Reason,
                                        Mpsr_n_Link,
                                        Mpsr_Tax_Agent,
                                        Mpsr_Tax_Name,
                                        Mpsr_Income_Accrued,
                                        Mpsr_Income_Paid,
                                        Mpsr_Tax_Changed,
                                        Mpsr_Tax_Transferred,
                                        Mpsr_Income_Priv_St,
                                        Mpsr_Employment_Dt,
                                        Mpsr_Dismissal_Dt,
                                        Mpsr_Period_Quarter,
                                        Mpsr_Period_Year,
                                        Mpsr_Result_Income,
                                        Mpsr_St)
            SELECT NULL,
                   l_Me_Id,
                   NULL,
                   TO_NUMBER (Col002)
                       AS Id_Req,
                   NULL,
                   NULL,
                   Col001
                       AS Id_Resp,
                   Col003
                       AS Rnokpp,
                   Col004
                       AS RESULT,
                   tools.tdate (Col005)
                       AS Date_Close_Rnokpp,
                   Col006
                       AS Reason_For_Closing,
                   Col007
                       AS Linked_Rnokpp,
                   Col008
                       AS Tax_Agent,
                   Col009
                       AS Name_Tax_Agent,
                   tools.tnumber (Col010, p_decimal_separator => ',')
                       Income_Accrued,
                   tools.tnumber (Col011, p_decimal_separator => ',')
                       AS Income_Paid,
                   tools.tnumber (Col012, p_decimal_separator => ',')
                       AS Tax_Charged,
                   tools.tnumber (Col013, p_decimal_separator => ',')
                       AS Tax_Transferred,
                   Col014
                       AS Sign_Of_Income_Privilege,
                   tools.tdate (Col015)
                       AS Date_Of_Employment,
                   tools.tdate (Col016)
                       AS Date_Of_Dismissal,
                   Col017
                       AS Period_Quarter,
                   TO_NUMBER (Col018)
                       AS Period_Year,
                   Col019
                       AS Result_Income,
                   NULL
              FROM TABLE (Csv_Util_Pkg.Clob_To_Csv (l_Clob)) p
             WHERE     Col001 IS NOT NULL
                   AND Col002 IS NOT NULL
                   AND Line_Number > 1;

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
                     'DPS2MSP',
                     l_Pc_Name,
                     l_Zip_Blob,
                     l_Clob,
                     NULL,
                     'DPS2MSP',
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

        UPDATE Me_Dps_Result_Rows r
           SET r.Mpsr_Ef = l_Ef_Id,
               r.Mpsr_Pc =
                   (SELECT MIN (Mprr_Pc)
                      FROM Uss_Esr.Me_Dps_Request_Rows
                     WHERE Mprr_Id = Mpsr_Mprr),
               r.Mpsr_Id_Fam =
                   (SELECT MIN (Mprr_Id_Fam)
                      FROM Uss_Esr.Me_Dps_Request_Rows
                     WHERE Mprr_Id = Mpsr_Mprr)
         WHERE r.Mpsr_Me = l_Me_Id;

        UPDATE Mass_Exchanges
           SET Me_St = Api$mass_Exchange.c_St_Me_Loaded
         WHERE Me_Id = l_Me_Id;
    END;
--=====================================================================

END Api$mass_Exchange_Dps;
/