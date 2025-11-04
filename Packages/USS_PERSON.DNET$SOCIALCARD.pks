/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.DNET$SOCIALCARD
IS
    -- Author  : SHOSTAK
    -- Created : 28.05.2021 11:19:54
    -- Purpose : Соціальна реєстраціїна картка

    PROCEDURE GET_SC_LIST (p_sc_unique   IN     VARCHAR2,
                           p_eos_num     IN     VARCHAR2,
                           p_pib         IN     VARCHAR2,
                           p_edrpou      IN     VARCHAR2,
                           p_passport    IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR,
                           p_birth_dt    IN     DATE DEFAULT NULL);

    PROCEDURE Get_Soc_Card (p_Sc_Id       IN     NUMBER,
                            Pers_Info        OUT SYS_REFCURSOR,
                            Addr_Cur         OUT SYS_REFCURSOR,
                            Contact_Cur      OUT SYS_REFCURSOR,
                            Doc_Cur          OUT SYS_REFCURSOR,
                            Attr_Cur         OUT SYS_REFCURSOR,
                            Files_Cur        OUT SYS_REFCURSOR,
                            PRIV_CUR         OUT SYS_REFCURSOR,
                            INC_CUR          OUT SYS_REFCURSOR,
                            HIST_CUR         OUT SYS_REFCURSOR);


    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR);

    --  #84371
    PROCEDURE get_sc_addr (p_sc_id    IN     NUMBER,
                           p_is_all   IN     VARCHAR2,
                           addr_cur      OUT SYS_REFCURSOR);

    -- #83425: інформація по зрізу картки
    PROCEDURE get_sc_change_info (p_scc_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR);

    -- #81295
    PROCEDURE get_docs_by_Sc (p_sc_id      IN     NUMBER,
                              p_is_all     IN     VARCHAR2,
                              p_doc_src    IN     VARCHAR2,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              doc_cur         OUT SYS_REFCURSOR,
                              attr_cur        OUT SYS_REFCURSOR,
                              files_cur       OUT SYS_REFCURSOR);

    -- #82141: документ по ідентифікатору
    PROCEDURE get_doc_by_Id (p_scd_id    IN     NUMBER,
                             doc_cur        OUT SYS_REFCURSOR,
                             attr_cur       OUT SYS_REFCURSOR,
                             files_cur      OUT SYS_REFCURSOR);

    -- дані по особі
    PROCEDURE Get_Person_Info (p_Sc_Id     IN     NUMBER,
                               Pers_Info      OUT SYS_REFCURSOR);

    PROCEDURE Get_Person_Info_Full (p_Sc_Id     IN     NUMBER,
                                    Pers_Info      OUT SYS_REFCURSOR);

    -- вичитка ознак соц. карточки
    PROCEDURE GET_SC_STATUSES (P_SC_ID     IN     NUMBER,
                               Flags_Cur      OUT SYS_REFCURSOR,
                               Insp_Cur       OUT SYS_REFCURSOR);


    -- #74082: вибірка пільг
    /*PROCEDURE GET_SC_PRIVILEGES(P_SC_ID IN NUMBER,
                                RES_CUR OUT SYS_REFCURSOR,
                                RES_CUR_DET OUT SYS_REFCURSOR);*/

    -- info:   Выбор информации об аттрибутах документа
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR);

    -- info:   Отримання інформації щодо пільг особи
    -- params: #82141
    -- note:
    PROCEDURE get_sc_benefits (p_sc_id      IN     socialcard.sc_id%TYPE,
                               p_start_dt   IN     DATE,
                               p_stop_dt    IN     DATE,
                               p_res_cur       OUT SYS_REFCURSOR);

    -- info:   Отримання інформації щодо документів що підтверджують пільгові категорії особи
    -- params:
    -- note:   #82141
    PROCEDURE get_sc_benefit_docs (
        p_scbc_id   IN     sc_benefit_category.scbc_id%TYPE,
        p_res_cur      OUT SYS_REFCURSOR);

    -- info:   Реєстр пільг
    -- params: p_numident - ІПН пільговика
    --         p_pasp_sn - Серія/номер паспорта пільговика
    --         p_pib - ПІБ пільговика
    --         p_nbc_id - категорія пільговика
    --         p_nbt_list - перелік пільг
    -- note:   #82142
    PROCEDURE get_person_benefits_list (p_numident       VARCHAR2,
                                        p_pasp_sn        VARCHAR2,
                                        p_pib            VARCHAR2,
                                        p_nbc_id         NUMBER,
                                        p_nbt_list       VARCHAR2,
                                        p_res_cur    OUT SYS_REFCURSOR);

    -- info:   Реєстр субсидій і Картка домогосподарства
    -- params: p_numident - ІПН отримувача субсидії
    --         p_pasp_sn - Серія/номер паспорта отримувача субсидії
    --         p_pib - ПІБ отримувача субсидії
    --         p_ho_address - Адреса домогосподарства
    -- note:   #82143
    PROCEDURE get_person_subsidy_list (p_numident         VARCHAR2,
                                       p_pasp_sn          VARCHAR2,
                                       p_pib              VARCHAR2,
                                       p_hh_address       VARCHAR2,
                                       p_res_cur      OUT SYS_REFCURSOR);

    -- info:   отримання картки домогосподарства
    -- params: p_schh_id - Ідентифікатор домогосподарства
    -- note:   #82143
    PROCEDURE get_household_card (p_schh_id        sc_household.schh_id%TYPE,
                                  p_addr_cur   OUT SYS_REFCURSOR,
                                  p_pers_cur   OUT SYS_REFCURSOR);

    -- info:   Перелік осіб що входять до домогосподарства
    -- params: p_scpp_id - Ідентифікатор виплати
    -- note:   #82143
    PROCEDURE get_household_persons (
        p_scpp_id       sc_pfu_pay_summary.scpp_id%TYPE,
        p_res_cur   OUT SYS_REFCURSOR);

    -- info:   Перелік житлово-комунальних послуг
    -- params: p_scpp_id - Ідентифікатор виплати
    -- note:   #82143
    PROCEDURE get_household_services (
        p_scpp_id       sc_pfu_pay_summary.scpp_id%TYPE,
        p_res_cur   OUT SYS_REFCURSOR);
END Dnet$socialcard;
/


GRANT EXECUTE ON USS_PERSON.DNET$SOCIALCARD TO DNET_PROXY
/

GRANT EXECUTE ON USS_PERSON.DNET$SOCIALCARD TO II01RC_USS_PERSON_WEB
/


/* Formatted on 8/12/2025 5:57:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.DNET$SOCIALCARD
IS
    PROCEDURE GET_SC_LIST (p_sc_unique   IN     VARCHAR2,
                           p_eos_num     IN     VARCHAR2,
                           p_pib         IN     VARCHAR2,
                           p_edrpou      IN     VARCHAR2,
                           p_passport    IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR,
                           p_birth_dt    IN     DATE DEFAULT NULL)
    IS
        --FUNCTION clean
        l_sql   VARCHAR2 (4000)
            := ' WITH flt AS
             (SELECT :1 as p_sc_unique,
                     :2 as p_eos_num,
                     :3 as p_pib,
                     :4 as p_edrpou,
                     :5 as p_passport,
                     :6 as p_birth_dt
              FROM dual
             )
     SELECT t.sc_id,
            t.sc_unique,
            (SELECT MAX(z.pc_num) FROM uss_esr.v_personalcase z WHERE z.pc_sc = t.sc_id) AS eos_num,
            i.sci_ln || '' '' || i.sci_fn ||'' '' || i.sci_mn AS pib,
            --ПАСПОРТ
            (SELECT p.Scd_Seria || p.Scd_Number
               FROM Sc_Document p
              WHERE p.Scd_Sc = t.Sc_Id
                    AND p.Scd_Ndt IN (6, 7)
                    AND p.Scd_St IN (''A'', ''1'')
              ORDER BY (p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS Passport,
            --ІПН
            (SELECT p.Scd_Seria || p.Scd_Number
               FROM Sc_Document p
              WHERE p.Scd_Sc = t.Sc_Id
                    AND p.Scd_Ndt = 5
                    AND p.Scd_St IN (''A'', ''1'')
              ORDER BY (p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS Numident,
            b.scb_dt
       FROM flt f,
            socialcard t
       JOIN sc_change ch ON (ch.scc_id = t.sc_scc)
       JOIN sc_identity i ON (i.sci_id = ch.scc_sci)
       left join sc_birth b on (b.scb_id = ch.scc_scb)
      WHERE 1 = 1';
    BEGIN
        IF (    p_sc_unique IS NULL
            AND p_pib IS NULL
            AND p_edrpou IS NULL
            AND p_passport IS NULL
            AND p_eos_num IS NULL
            AND p_birth_dt IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Необхідно вказати параметр(и) пошуку!@@@');
        END IF;

        IF p_eos_num IS NOT NULL
        THEN
            raise_application_error (
                -20000,
                'Фільтрацію по ЕОС не реалізовано - будь-ласка, шукайте ЕОС в Реєстрі ЕОС!');
        END IF;


        tools.validate_param (p_sc_unique);
        tools.validate_param (p_eos_num);
        tools.validate_param (p_pib);
        tools.validate_param (p_edrpou);
        tools.validate_param (p_passport);


        IF p_sc_unique IS NOT NULL
        THEN
            l_sql := l_sql || ' AND t.sc_unique LIKE f.p_sc_unique||''%''';
        END IF;

        IF p_pib IS NOT NULL
        THEN
            l_sql :=
                   l_sql
                || ' AND upper(i.sci_ln || '' '' || i.sci_fn || '' '' || i.sci_mn) LIKE upper(f.p_pib) || ''%''';
        END IF;

        IF p_edrpou IS NOT NULL
        THEN
            /*l_sql := l_sql||' AND EXISTS (SELECT *
                                          FROM Sc_Document p
                                          WHERE p.Scd_Sc = t.Sc_Id
                                            AND p.Scd_Ndt = 5
                                            AND p.Scd_St IN (''A'', ''1'')
                                            AND p.Scd_Number LIKE ''' || p_edrpou || '%'')';*/
            l_sql := l_sql || ' AND EXISTS (SELECT *
                                   FROM Sc_Document p
                                   WHERE p.Scd_Sc = t.Sc_Id
                                     AND p.Scd_Ndt = 5
                                     AND p.Scd_St IN (''A'', ''1'')
                                     AND p.Scd_Number LIKE f.p_edrpou||''%'')';
        END IF;

        IF p_passport IS NOT NULL
        THEN
            /*l_sql := l_sql||' AND EXISTS (SELECT *
                                          FROM Sc_Document p
                                          WHERE p.Scd_Sc = t.Sc_Id
                                            AND p.Scd_Ndt IN (6, 7)
                                            AND p.Scd_St IN (''A'', ''1'')
                                            AND  p.Scd_Seria || p.Scd_Number LIKE ''%' || p_passport || '%'')';*/
            l_sql :=
                   l_sql
                || ' AND EXISTS (SELECT *
                                   FROM Sc_Document p
                                   WHERE p.Scd_Sc = t.Sc_Id
                                     AND p.Scd_Ndt IN (6, 7)
                                     AND p.Scd_St IN (''A'', ''1'')
                                     AND  p.Scd_Seria || p.Scd_Number LIKE f.p_passport||''%'')';
        END IF;

        IF p_birth_dt IS NOT NULL
        THEN
            /*l_sql := l_sql||' AND EXISTS (SELECT *
                                          FROM Sc_Document p
                                          WHERE p.Scd_Sc = t.Sc_Id
                                            AND p.Scd_Ndt IN (6, 7)
                                            AND p.Scd_St IN (''A'', ''1'')
                                            AND  p.Scd_Seria || p.Scd_Number LIKE ''%' || p_passport || '%'')';*/
            l_sql := l_sql || ' AND b.scb_dt = f.p_birth_dt';
        END IF;

        l_sql := l_sql || ' AND rownum < 502';

        /*OPEN res_cur FOR
          l_sql;*/

        OPEN res_cur FOR l_sql
            USING p_sc_unique,
        p_eos_num,
        p_pib,
        p_edrpou,
        p_passport,
        p_birth_dt;

        RETURN;

        OPEN res_cur FOR
            SELECT t.sc_id,
                   t.sc_unique,
                   'не знаю откуда брать'        AS eos_num,
                      i.sci_ln
                   || ' '
                   || i.sci_fn
                   || ' '
                   || i.sci_mn                   AS pib,
                   --ПАСПОРТ
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM Sc_Document p
                        WHERE     p.Scd_Sc = t.Sc_Id
                              AND p.Scd_Ndt IN (6, 7)
                              AND p.scd_st IN ('A', '1')
                     ORDER BY (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Passport,
                   --ІПН
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM Sc_Document p
                        WHERE     p.Scd_Sc = t.Sc_Id
                              AND p.Scd_Ndt = 5
                              AND p.scd_st IN ('A', '1')
                     ORDER BY (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Numident
              FROM socialcard  t
                   JOIN sc_change ch ON (ch.scc_id = t.sc_scc)
                   JOIN sc_identity i ON (i.sci_id = ch.scc_sci)
             WHERE     1 = 1
                   AND t.sc_unique LIKE p_sc_unique || '%'
                   AND (   p_pib IS NULL
                        OR UPPER (
                               i.sci_ln || ' ' || i.sci_fn || ' ' || i.sci_mn) LIKE
                               UPPER (p_pib) || '%')
                   AND (   p_edrpou IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM Sc_Document p
                                 WHERE     p.Scd_Sc = t.Sc_Id
                                       AND p.Scd_Ndt = 5
                                       AND p.scd_st IN ('A', '1')
                                       AND p.Scd_Number LIKE p_edrpou || '%'))
                   AND (   p_passport IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM Sc_Document p
                                 WHERE     p.Scd_Sc = t.Sc_Id
                                       AND p.Scd_Ndt IN (6, 7)
                                       AND p.scd_st IN ('A', '1')
                                       AND p.Scd_Seria || p.Scd_Number LIKE
                                               p_passport || '%'))
                   AND ROWNUM < 1000;
    END;


    -- info:   Выбор информации об документах (файлы)
    -- params: p_sc_id - ідентифікатор соц. картки
    -- note:
    PROCEDURE Get_Documents_Files (p_Sc_Id           NUMBER,
                                   p_is_all          VARCHAR2,
                                   p_Res         OUT SYS_REFCURSOR,
                                   p_mode     IN     NUMBER DEFAULT 0)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT t.scd_dh
              FROM sc_document t
             WHERE     (   p_mode = 0 AND t.scd_sc = p_sc_id
                        OR p_mode = 1 AND t.scd_id = p_sc_id)
                   --AND t.scd_st IN ('A', '1')
                   AND (   p_is_all = 'T'
                        OR p_is_all = 'F' AND scd_st IN ('A', '1'));

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_sc_id - ідентифікатор соц. картки
    -- note:
    PROCEDURE Get_Documents_Attributes (p_Sc_Id           NUMBER,
                                        p_is_all          VARCHAR2,
                                        p_Res         OUT SYS_REFCURSOR,
                                        p_mode     IN     NUMBER DEFAULT 0)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT t.scd_dh
              FROM sc_document t
             WHERE     (   p_mode = 0 AND t.scd_sc = p_sc_id
                        OR p_mode = 1 AND t.scd_id = p_sc_id)
                   -- AND t.scd_st IN ('A', '1')
                   AND (   p_is_all = 'T'
                        OR p_is_all = 'F' AND scd_st IN ('A', '1'));

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attributes (p_Doc_Id        => NULL,
                                              p_Dh_Id         => NULL,
                                              p_Res           => p_Res,
                                              p_Params_Mode   => 3);
    END;

    PROCEDURE get_photo_info (p_sc_id        IN     NUMBER,
                              p_photo_code      OUT VARCHAR2,
                              p_photo_type      OUT VARCHAR2)
    IS
        l_files_cursor   SYS_REFCURSOR;
        l_doc            NUMBER;
        l_file           uss_doc.Api$documents.r_file;
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT t.scd_dh
              FROM sc_document t
             WHERE     t.scd_sc = p_Sc_Id
                   AND t.scd_st IN ('A', '1')
                   AND t.scd_ndt = 19;                -- фотокартка пенсіонера

        --raise_application_error(-20000, SQL%ROWCOUNT);
        IF (SQL%ROWCOUNT > 0)
        THEN
            --отримуємо дані файлів з електронного архіву
            Uss_Doc.Api$documents.Get_Attachments (
                p_Doc_Id        => NULL,
                p_Dh_Id         => NULL,
                p_Res           => l_files_cursor,
                p_Params_Mode   => 3);

            LOOP
                FETCH l_files_cursor INTO l_file;

                EXIT WHEN l_files_cursor%NOTFOUND;
                p_photo_code := l_file.File_Code;
                p_photo_type := l_file.File_Mime_Type;
                EXIT;
            END LOOP;
        END IF;
    END;

    PROCEDURE Get_Soc_Card (p_Sc_Id       IN     NUMBER,
                            Pers_Info        OUT SYS_REFCURSOR,
                            Addr_Cur         OUT SYS_REFCURSOR,
                            Contact_Cur      OUT SYS_REFCURSOR,
                            Doc_Cur          OUT SYS_REFCURSOR,
                            Attr_Cur         OUT SYS_REFCURSOR,
                            Files_Cur        OUT SYS_REFCURSOR,
                            PRIV_CUR         OUT SYS_REFCURSOR,
                            INC_CUR          OUT SYS_REFCURSOR,
                            HIST_CUR         OUT SYS_REFCURSOR)
    IS
        l_flag          NUMBER
            := CASE WHEN tools.GetCurrOrgTo IN (30, 40) THEN 0 ELSE 1 END;
        l_is_permited   NUMBER;
        l_is_pilgovik   NUMBER;
    BEGIN
        WITH
            dat
            AS
                (SELECT t.RAJ, t.R_NCARDP
                   FROM uss_person.v_x_trg  t
                        JOIN uss_person.v_sc_benefit_category c
                            ON     c.scbc_id = t.trg_id
                               AND t.trg_code =
                                   'USS_PERSON.SC_BENEFIT_CATEGORY'
                  WHERE c.scbc_sc = p_sc_id
                  FETCH FIRST ROW ONLY)
        SELECT COUNT (*),
               COUNT (CASE
                          WHEN l_flag = 0
                          THEN
                              1
                          WHEN     l_flag = 1
                               AND z.katp_cd NOT IN (1,
                                                     2,
                                                     3,
                                                     4,
                                                     11,
                                                     12,
                                                     13,
                                                     22,
                                                     23,
                                                     58,
                                                     80,
                                                     85,
                                                     86,
                                                     87,
                                                     88,
                                                     136,
                                                     137,
                                                     138,
                                                     139)
                          THEN
                              1
                      END)
          INTO l_is_pilgovik, l_is_permited
          FROM dat  t
               JOIN uss_person.v_b_katpp z
                   ON (t.raj = z.raj AND t.r_ncardp = z.r_ncardp)
         WHERE 1 = 1;

        Get_Person_Info (p_sc_id, Pers_Info);

        OPEN Addr_Cur FOR
            SELECT d.Sca_Id,
                   d.Sca_Tp,
                   tp.DIC_SNAME          AS Sca_Tp_Name,
                      sca_postcode
                   || ', '
                   || d.Sca_Country
                   || ', '
                   || d.Sca_Region
                   || ', '
                   || d.sca_district
                   || ', '
                   || d.sca_city
                   || ', '
                   || d.sca_street
                   || CASE
                          WHEN d.sca_building IS NOT NULL THEN ' буд. '
                          ELSE ' '
                      END
                   || d.sca_building
                   || CASE
                          WHEN d.sca_block IS NOT NULL THEN ' корп. '
                          ELSE ' '
                      END
                   || d.sca_block
                   || CASE
                          WHEN d.sca_apartment IS NOT NULL THEN ' кв. '
                          ELSE ' '
                      END
                   || d.sca_apartment    AS Sca_Full_Addr,
                   d.history_status,
                   d.sca_create_dt
              FROM Socialcard  s
                   JOIN Sc_Address d ON (d.Sca_Sc = s.sc_id)
                   JOIN uss_ndi.v_ddn_sca_tp tp ON (tp.DIC_VALUE = d.sca_tp)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND d.history_status = 'A'
                   AND (   l_flag = 0
                        OR l_is_pilgovik > 0 AND l_is_permited > 0
                        OR l_is_pilgovik = 0
                        OR 1 = 2);

        OPEN Contact_Cur FOR
            SELECT 'Номер мобільного'     AS Contact_Name,
                   c.Sct_Phone_Mob        AS Contact_Value
              FROM Socialcard  s
                   JOIN Sc_Change t ON s.Sc_Scc = t.Scc_Id
                   JOIN Sc_Contact c ON (c.Sct_Id = t.Scc_Sct)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND c.Sct_Phone_Mob IS NOT NULL
                   AND (   l_flag = 0
                        OR l_is_pilgovik > 0 AND l_is_permited > 0
                        OR l_is_pilgovik = 0
                        OR 1 = 2)
            UNION
            SELECT 'Номер стаціонарного'     AS Contact_Name,
                   c.Sct_Phone_Num           AS Contact_Value
              FROM Socialcard  s
                   JOIN Sc_Change t ON s.Sc_Scc = t.Scc_Id
                   JOIN Sc_Contact c ON (c.Sct_Id = t.Scc_Sct)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND c.Sct_Phone_Num IS NOT NULL
                   AND (   l_flag = 0
                        OR l_is_pilgovik > 0 AND l_is_permited > 0
                        OR l_is_pilgovik = 0
                        OR 1 = 2)
            UNION
            SELECT 'Факс' AS Contact_Name, c.Sct_Fax_Num AS Contact_Value
              FROM Socialcard  s
                   JOIN Sc_Change t ON s.Sc_Scc = t.Scc_Id
                   JOIN Sc_Contact c ON (c.Sct_Id = t.Scc_Sct)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND c.Sct_Fax_Num IS NOT NULL
                   AND (   l_flag = 0
                        OR l_is_pilgovik > 0 AND l_is_permited > 0
                        OR l_is_pilgovik = 0
                        OR 1 = 2)
            UNION
            SELECT 'Email' AS Contact_Name, c.Sct_Email AS Contact_Value
              FROM Socialcard  s
                   JOIN Sc_Change t ON s.Sc_Scc = t.Scc_Id
                   JOIN Sc_Contact c ON (c.Sct_Id = t.Scc_Sct)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND c.Sct_Email IS NOT NULL
                   AND (   l_flag = 0
                        OR l_is_pilgovik > 0 AND l_is_permited > 0
                        OR l_is_pilgovik = 0
                        OR 1 = 2);

        OPEN Doc_Cur FOR SELECT *
                           FROM DUAL
                          WHERE 1 = 2;

        OPEN Attr_Cur FOR SELECT *
                            FROM DUAL
                           WHERE 1 = 2;

        OPEN Files_Cur FOR SELECT *
                             FROM DUAL
                            WHERE 1 = 2;

        --get_docs_by_Sc(p_Sc_Id, 'F', Doc_Cur, Attr_Cur, Files_Cur);

        /* OPEN Doc_Cur FOR
          SELECT d.*,
             Tp.Ndt_Name_Short  AS Scd_Ndt_Name,
             St.Dic_Sname       AS Scd_St_Name,
             Src.Dic_Sname      AS Scd_Src_Name
           FROM Sc_Document d
           JOIN Uss_Ndi.v_Ndi_Document_Type Tp
            ON (Tp.Ndt_Id = d.Scd_Ndt)
           JOIN Uss_Ndi.v_Ddn_Scd_St St
            ON (St.Dic_Value = d.Scd_St)
           JOIN Uss_Ndi.v_Ddn_Source Src
            ON (Src.Dic_Value = d.Scd_Src)
          WHERE d.Scd_Sc = p_Sc_Id;

          Get_Documents_Attributes(p_Sc_Id, Attr_Cur);
          Get_Documents_Files(p_Sc_Id, Files_Cur);
          */

        OPEN priv_cur FOR SELECT *
                            FROM DUAL
                           WHERE 1 = 2;

        --get_sc_benefits(p_sc_id, priv_cur);
        /*
          OPEN PRIV_CUR FOR
            SELECT *
              FROM v_edarp_b_lgp t
             WHERE t.sc_id = p_sc_id;*/

        ikis_sys.ikis_audit.WriteMsg (
            p_msg_type   => 'OPEN_SOCIAL_CARD',
            p_msg_text   => 'Надано дані соц.картки id=<' || p_Sc_Id || '>');
        Api$socialcard.write_sc_log (p_Sc_Id,
                                     NULL,
                                     NULL,
                                     CHR (38) || '221',
                                     NULL,
                                     NULL);

        /*OPEN Change_Cur FOR
      SELECT c.Scc_Create_Dt,
         s.Dic_Name AS Scc_Src_Name,
         i.Sci_Fn || ' ' || i.Sci_Ln || ' ' || i.Sci_Mn AS Scc_Pib
       FROM Sc_Change c
       JOIN Uss_Ndi.v_Ddn_Source s
        ON c.Scc_Src = s.Dic_Value
       JOIN Sc_Identity i
        ON c.Scc_Sci = i.Sci_Id
      WHERE c.Scc_Sc = p_Sc_Id
      ORDER BY c.Scc_Create_Dt DESC;

     OPEN Ralation_Cur FOR
      SELECT i.Sci_Fn || ' ' || i.Sci_Ln || ' ' || i.Sci_Mn AS Scr_Pib,
         t.Dic_Name AS Scr_Tp_Name,
         b.Scb_Dt AS Birth_Dt,
         --ПАСПОРТ
         (SELECT p.Scd_Seria || p.Scd_Number
           FROM Sc_Document p
          WHERE p.Scd_Sc = r.Scr_Sc_Link
             AND p.Scd_Ndt IN (6, 7)
             AND p.Scd_St = '1'
          ORDER BY To_Number(p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS Scr_Pasport,
         --ІПН
         (SELECT p.Scd_Seria || p.Scd_Number
           FROM Sc_Document p
          WHERE p.Scd_Sc = r.Scr_Sc_Link
             AND p.Scd_Ndt = 5
             AND p.Scd_St = '1'
          ORDER BY To_Number(p.Scd_Start_Dt) DESC FETCH FIRST ROW ONLY) AS Scr_Numident,
         r.Scr_Note,
         Bl.Dic_Name AS Scr_Is_Separate_Name,
         Src.Dic_Name AS Scr_Src_Name,
         To_Char(r.Scr_Start_Dt, 'dd.mm.yyyy') || ' - ' || To_Char(r.Scr_Stop_Dr, 'dd.mm.yyyy') AS Scr_Period,
         s.Dic_Name AS Scr_History_Status_Name
       FROM Sc_Ralation r
       JOIN Sc_Identity i
        ON r.Scr_Sc_Link = i.Sci_Sc
       JOIN Socialcard c
        ON r.Scr_Sc_Link = c.Sc_Id
       JOIN Uss_Ndi.v_Ddn_Source Src
        ON c.Sc_Src = Src.Dic_Value
       LEFT JOIN Uss_Ndi.v_Ddn_Scr_Tp t
        ON r.Scr_Tp = t.Dic_Value
       LEFT JOIN Sc_Birth b
        ON r.Scr_Sc_Link = b.Scb_Sc
       LEFT JOIN Uss_Ndi.v_Ddn_Boolean Bl
        ON r.Scr_Is_Separate = Bl.Dic_Value
       LEFT JOIN Uss_Ndi.v_Ddn_Hist_Status s
        ON r.History_Status = s.Dic_Value
      WHERE r.Scr_Sc = p_Sc_Id;*/
        OPEN INC_CUR FOR
              SELECT t.*, tp.DIC_NAME AS sil_inc_name
                FROM socialcard s
                     JOIN v_sc_income_link t ON (t.sil_sc = s.sc_id)
                     LEFT JOIN uss_ndi.V_DDN_SIL_INC tp
                         ON (tp.DIC_VALUE = t.SIL_INC)
               WHERE s.sc_id = p_Sc_Id AND t.sil_st = 'A'
            ORDER BY SIL_ACCRUAL_DT DESC, t.SIL_INC;

        OPEN HIST_CUR FOR
              SELECT t.scc_id,
                     t.scc_create_dt,
                     i.sci_ln || ' ' || i.sci_fn || ' ' || i.sci_mn
                         AS pib,
                     src.DIC_SNAME
                         AS scc_src_name,
                     CASE WHEN t.scc_id = sc.sc_scc THEN 'T' ELSE 'F' END
                         AS is_curr
                FROM sc_change t
                     JOIN socialcard sc ON (sc.sc_id = t.scc_sc)
                     JOIN uss_ndi.v_ddn_source src
                         ON (src.DIC_VALUE = t.scc_src)
                     JOIN sc_identity i ON (i.sci_id = t.scc_sci)
               WHERE t.scc_sc = p_sc_id
            ORDER BY t.scc_create_dt DESC;
    END;

    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN LOG_CUR FOR
              SELECT t.scl_id
                         AS log_id,
                     t.scl_sc
                         AS log_obj,
                     t.scl_tp
                         AS log_tp,
                     st.DIC_NAME
                         AS log_st_name,
                     sto.DIC_NAME
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     NVL (tools.GetUserLogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.scl_message)
                         AS log_message
                FROM sc_log t
                     LEFT JOIN uss_ndi.v_ddn_pd_st st
                         ON (st.DIC_VALUE = t.scl_st)
                     LEFT JOIN uss_ndi.v_ddn_pd_st sto
                         ON (sto.DIC_VALUE = t.scl_old_st)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.scl_hs)
               WHERE t.scl_sc = p_Sc_Id
            ORDER BY hs.hs_dt;
    END;

    --  #84371
    PROCEDURE get_sc_addr (p_sc_id    IN     NUMBER,
                           p_is_all   IN     VARCHAR2,
                           addr_cur      OUT SYS_REFCURSOR)
    IS
        l_flag          NUMBER
            := CASE WHEN tools.GetCurrOrgTo IN (30, 40) THEN 0 ELSE 1 END;
        l_is_permited   NUMBER;
        l_is_pilgovik   NUMBER;
    BEGIN
        WITH
            dat
            AS
                (SELECT t.RAJ, t.R_NCARDP
                   FROM uss_person.v_x_trg  t
                        JOIN uss_person.v_sc_benefit_category c
                            ON     c.scbc_id = t.trg_id
                               AND t.trg_code =
                                   'USS_PERSON.SC_BENEFIT_CATEGORY'
                  WHERE c.scbc_sc = p_sc_id
                  FETCH FIRST ROW ONLY)
        SELECT COUNT (*),
               COUNT (CASE
                          WHEN l_flag = 0
                          THEN
                              1
                          WHEN     l_flag = 1
                               AND z.katp_cd NOT IN (1,
                                                     2,
                                                     3,
                                                     4,
                                                     11,
                                                     12,
                                                     13,
                                                     22,
                                                     23,
                                                     58,
                                                     80,
                                                     85,
                                                     86,
                                                     87,
                                                     88,
                                                     136,
                                                     137,
                                                     138,
                                                     139)
                          THEN
                              1
                      END)
          INTO l_is_pilgovik, l_is_permited
          FROM dat  t
               JOIN uss_person.v_b_katpp z
                   ON (t.raj = z.raj AND t.r_ncardp = z.r_ncardp)
         WHERE 1 = 1;

        IF (l_flag = 1 AND l_is_pilgovik > 0 AND l_is_permited = 0)
        THEN
            OPEN Addr_Cur FOR SELECT *
                                FROM DUAL
                               WHERE 1 = 2;

            RETURN;
        END IF;

        OPEN Addr_Cur FOR
            SELECT d.Sca_Id,
                   d.Sca_Tp,
                   tp.DIC_SNAME          AS Sca_Tp_Name,
                      sca_postcode
                   || ', '
                   || d.Sca_Country
                   || ', '
                   || d.Sca_Region
                   || ', '
                   || d.sca_district
                   || ', '
                   || d.sca_city
                   || ', '
                   || d.sca_street
                   || CASE
                          WHEN d.sca_building IS NOT NULL THEN ' буд. '
                          ELSE ' '
                      END
                   || d.sca_building
                   || CASE
                          WHEN d.sca_block IS NOT NULL THEN ' корп. '
                          ELSE ' '
                      END
                   || d.sca_block
                   || CASE
                          WHEN d.sca_apartment IS NOT NULL THEN ' кв. '
                          ELSE ' '
                      END
                   || d.sca_apartment    AS Sca_Full_Addr,
                   d.history_status,
                   d.sca_create_dt
              FROM Socialcard  s
                   /* JOIN Sc_Change Sc
                      ON s.Sc_Scc = Sc.Scc_Id*/
                   JOIN Sc_Address d ON (d.Sca_Sc = s.sc_id)
                   JOIN uss_ndi.v_ddn_sca_tp tp ON (tp.DIC_VALUE = d.sca_tp)
             WHERE     s.Sc_Id = p_Sc_Id
                   AND (   p_is_all = 'T'
                        OR p_is_all = 'F' AND d.history_status = 'A');
    END;

    -- #83425: інформація по зрізу картки
    PROCEDURE get_sc_change_info (p_scc_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.scc_id,
                   t.scc_create_dt,
                   i.sci_ln || ' ' || i.sci_fn || ' ' || i.sci_mn
                       AS pib,
                   (SELECT MAX (src.DIC_SNAME)
                      FROM uss_ndi.v_ddn_source src
                     WHERE src.DIC_VALUE = t.scc_src)
                       AS scc_src_name,
                   (SELECT MAX (z.DIC_SNAME)
                      FROM uss_ndi.v_ddn_gender z
                     WHERE z.DIC_VALUE = i.sci_gender)
                       AS sci_gender_name,
                   (SELECT MAX (z.DIC_SNAME)
                      FROM uss_ndi.v_ddn_nationality z
                     WHERE z.DIC_VALUE = i.sci_nationality)
                       AS sci_nationality_name,
                   c.*,
                   scb_dt,
                   scb_scd,
                      a.Sca_Country
                   || ' '
                   || a.Sca_Region
                   || ' '
                   || a.sca_district
                   || ' '
                   || a.sca_city
                   || ' '
                   || a.sca_street
                   || ' '
                   || a.sca_building
                   || ' '
                   || a.sca_apartment
                       AS Sca_Full_Addr,
                   sch_dt,
                   sch_is_dead,
                   scp_is_pension
              FROM sc_change  t
                   JOIN sc_identity i ON (i.sci_id = t.scc_sci)
                   LEFT JOIN sc_contact c ON (c.sct_id = t.scc_sct)
                   LEFT JOIN sc_birth b ON (b.scb_id = t.scc_scb)
                   LEFT JOIN sc_address a ON (a.sca_id = t.scc_sca)
                   LEFT JOIN sc_death h ON (h.sch_id = t.scc_sch)
                   LEFT JOIN sc_pension p ON (p.scp_id = t.scc_scp)
             WHERE t.scc_id = p_scc_Id;
    END;

    -- #81295
    PROCEDURE get_docs_by_Sc (p_sc_id      IN     NUMBER,
                              p_is_all     IN     VARCHAR2,
                              p_doc_src    IN     VARCHAR2,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              doc_cur         OUT SYS_REFCURSOR,
                              attr_cur        OUT SYS_REFCURSOR,
                              files_cur       OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.getcurrorgto;
    BEGIN
        OPEN Doc_Cur FOR
            SELECT d.*,
                   Tp.Ndt_Name_Short     AS Scd_Ndt_Name,
                   St.Dic_Sname          AS Scd_St_Name,
                   Src.Dic_Sname         AS Scd_Src_Name,
                   h.Dh_Dt               AS Scd_Modify_Dt
              FROM Sc_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type Tp
                       ON (Tp.Ndt_Id = d.Scd_Ndt)
                   JOIN Uss_Ndi.v_Ddn_Scd_St St ON (St.Dic_Value = d.Scd_St)
                   JOIN Uss_Ndi.v_Ddn_Source Src
                       ON (Src.Dic_Value = d.Scd_Src)
                   LEFT JOIN Uss_Doc.v_Doc_Hist h ON d.Scd_Dh = h.Dh_Id
             WHERE     d.Scd_Sc = p_Sc_Id
                   AND (   p_Is_All = 'T'
                        OR p_Is_All = 'F' AND d.Scd_St IN ('A', '1'))
                   AND (p_doc_src IS NULL OR src.DIC_VALUE = p_doc_src)
                   AND (   p_start_dt IS NULL
                        OR NVL (d.scd_issued_dt, p_start_dt) >= p_start_dt)
                   AND (   p_stop_dt IS NULL
                        OR NVL (d.scd_issued_dt, p_stop_dt) <= p_stop_dt)
                   AND (   l_org_to IN (30, 40)
                        OR     l_org_to NOT IN (30, 40)
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM SC_BENEFIT_DOCS  z
                                           JOIN sc_benefit_category c
                                               ON (c.scbc_id = z.scbd_scbc)
                                     WHERE     z.scbd_scd = d.scd_id
                                           AND c.scbc_nbc IN (1,
                                                              2,
                                                              3,
                                                              4,
                                                              11,
                                                              12,
                                                              13,
                                                              14,
                                                              1,
                                                              2,
                                                              3,
                                                              4,
                                                              11,
                                                              12,
                                                              13,
                                                              14,
                                                              22,
                                                              23,
                                                              26)));

        Get_Documents_Attributes (p_Sc_Id, p_is_all, Attr_Cur);
        Get_Documents_Files (p_Sc_Id, p_is_all, Files_Cur);
    END;

    -- #82141: документ по ідентифікатору
    PROCEDURE get_doc_by_Id (p_scd_id    IN     NUMBER,
                             doc_cur        OUT SYS_REFCURSOR,
                             attr_cur       OUT SYS_REFCURSOR,
                             files_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        -- raise_application_error(-20000, 'p_is_all='|| p_is_all);
        OPEN Doc_Cur FOR
            SELECT d.*,
                   Tp.Ndt_Name_Short     AS Scd_Ndt_Name,
                   St.Dic_Sname          AS Scd_St_Name,
                   Src.Dic_Sname         AS Scd_Src_Name
              FROM Sc_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type Tp
                       ON (Tp.Ndt_Id = d.Scd_Ndt)
                   JOIN Uss_Ndi.v_Ddn_Scd_St St ON (St.Dic_Value = d.Scd_St)
                   JOIN Uss_Ndi.v_Ddn_Source Src
                       ON (Src.Dic_Value = d.Scd_Src)
             WHERE d.Scd_Id = p_Scd_Id;

        Get_Documents_Attributes (p_Scd_Id,
                                  'T',
                                  Attr_Cur,
                                  1);
        Get_Documents_Files (p_Scd_Id,
                             'T',
                             Files_Cur,
                             1);
    END;

    -- дані по особі
    PROCEDURE Get_Person_Info (p_Sc_Id     IN     NUMBER,
                               Pers_Info      OUT SYS_REFCURSOR)
    IS
        l_photo_code   VARCHAR2 (50);
        l_photo_type   VARCHAR2 (50);
    BEGIN
        get_photo_info (p_Sc_Id, l_photo_code, l_photo_type);

        OPEN Pers_Info FOR
            SELECT t.*,
                      INITCAP (i.Sci_Ln)
                   || ' '
                   || INITCAP (i.Sci_Fn)
                   || ' '
                   || INITCAP (i.Sci_Mn)         AS Pib,
                   g.Dic_Sname                   AS Gender,
                   n.Dic_Sname                   AS Nationality,
                   b.Scb_Dt                      AS Birth_Dt,
                   --ПАСПОРТ
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM Sc_Document p
                        WHERE     p.Scd_Sc = t.Sc_Id
                              AND p.Scd_Ndt IN (6, 7)
                              AND p.scd_st IN ('A', '1')
                     ORDER BY (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Pass_Data,
                   --ІПН
                    (  SELECT p.Scd_Seria || p.Scd_Number
                         FROM Sc_Document p
                        WHERE     p.Scd_Sc = t.Sc_Id
                              AND p.Scd_Ndt = 5
                              AND p.scd_st IN ('A', '1')
                     ORDER BY (p.Scd_Start_Dt) DESC
                        FETCH FIRST ROW ONLY)    AS Doc_Numident,
                   pc.pc_num                     AS Doc_Eos,            -- ЕОС
                   pc.pc_id,
                   CASE
                       WHEN dh.sch_is_dead = 'T'
                       THEN
                              TO_CHAR (dh.sch_dt, 'DD.MM.YYYY')
                           || ' '
                           || dh.sch_note
                   END                           AS Death_Status,
                   st.DIC_SNAME                  AS sc_st_name,
                   l_photo_type                  AS photo_type,
                   l_photo_code                  AS photo_code,
                   lg.r_ncardp                   AS Privilege_Card_Num,
                   lg.R_DTUCHB                   AS Edarp_Start_Dt
              FROM Socialcard  t
                   JOIN Sc_Change Sc ON t.Sc_Scc = Sc.Scc_Id
                   JOIN uss_ndi.v_ddn_sc_st st ON (st.dic_value = t.sc_st)
                   LEFT JOIN Sc_Identity i ON (i.Sci_Id = Sc.Scc_Sci)
                   LEFT JOIN Uss_Ndi.v_Ddn_Gender g
                       ON (g.Dic_Value = i.Sci_Gender)
                   LEFT JOIN Uss_Ndi.v_Ddn_Nationality n
                       ON (n.Dic_Value = i.Sci_Nationality)
                   LEFT JOIN Sc_Birth b ON (b.Scb_Id = Sc.Scc_Scb)
                   LEFT JOIN sc_death dh ON (dh.sch_id = sc.scc_sch)
                   LEFT JOIN uss_esr.v_personalcase pc
                       ON (pc.pc_sc = t.sc_id)
                   LEFT JOIN uss_person.v_edarp_b_reestrlg lg
                       ON (lg.sc_id = t.sc_id)
             WHERE t.Sc_Id = p_Sc_Id;
    END;


    PROCEDURE Get_Person_Info_Full (p_Sc_Id     IN     NUMBER,
                                    Pers_Info      OUT SYS_REFCURSOR)
    IS
        l_photo_code   VARCHAR2 (50);
        l_photo_type   VARCHAR2 (50);
    BEGIN
        get_photo_info (p_Sc_Id, l_photo_code, l_photo_type);

        OPEN Pers_Info FOR
            SELECT t.*,
                   i.Sci_Ln                   LN,
                   i.Sci_Fn                   Fn,
                   i.Sci_Mn                   Mn,
                   i.Sci_Gender               Gender,
                   g.Dic_Sname                AS Gender_name,
                   i.Sci_Nationality          AS Nationality,
                   n.Dic_Sname                AS Nationality_name,
                   b.Scb_Dt                   AS Birth_Dt,
                   --ПАСПОРТ
                   Pass_Data.Scd_Seria        Passport_Seria,
                   Pass_Data.Scd_Number       Passport_Number,
                   --ІПН
                   Doc_Numident.Scd_Number    Numident,
                   pc.pc_num                  AS Doc_Eos,               -- ЕОС
                   pc.pc_id,
                   CASE
                       WHEN dh.sch_is_dead = 'T'
                       THEN
                              TO_CHAR (dh.sch_dt, 'DD.MM.YYYY')
                           || ' '
                           || dh.sch_note
                   END                        AS Death_Status,
                   st.DIC_SNAME               AS sc_st_name,
                   l_photo_type               AS photo_type,
                   l_photo_code               AS photo_code,
                   lg.r_ncardp                AS Privilege_Card_Num,
                   lg.R_DTUCHB                AS Edarp_Start_Dt
              FROM Socialcard  t
                   JOIN Sc_Change Sc ON t.Sc_Scc = Sc.Scc_Id
                   JOIN uss_ndi.v_ddn_sc_st st ON (st.dic_value = t.sc_st)
                   LEFT JOIN Sc_Identity i ON (i.Sci_Id = Sc.Scc_Sci)
                   LEFT JOIN Uss_Ndi.v_Ddn_Gender g
                       ON (g.Dic_Value = i.Sci_Gender)
                   LEFT JOIN Uss_Ndi.v_Ddn_Nationality n
                       ON (n.Dic_Value = i.Sci_Nationality)
                   LEFT JOIN Sc_Birth b ON (b.Scb_Id = Sc.Scc_Scb)
                   LEFT JOIN sc_death dh ON (dh.sch_id = sc.scc_sch)
                   LEFT JOIN uss_esr.v_personalcase pc
                       ON (pc.pc_sc = t.sc_id)
                   LEFT JOIN uss_person.v_edarp_b_reestrlg lg
                       ON (lg.sc_id = t.sc_id)
                   LEFT JOIN
                   (  SELECT p.Scd_Sc, p.Scd_Seria, p.Scd_Number
                        FROM Sc_Document p
                       WHERE     p.Scd_Sc = p_Sc_Id
                             AND p.Scd_Ndt IN (6, 7)
                             AND p.scd_st IN ('A', '1')
                    ORDER BY (p.Scd_Start_Dt) DESC
                       FETCH FIRST ROW ONLY) Pass_Data
                       ON t.sc_id = Pass_Data.Scd_Sc
                   LEFT JOIN
                   (  SELECT p.Scd_Sc, p.Scd_Seria, p.Scd_Number
                        FROM Sc_Document p
                       WHERE     p.Scd_Sc = p_Sc_Id
                             AND p.Scd_Ndt = 5
                             AND p.scd_st IN ('A', '1')
                    ORDER BY (p.Scd_Start_Dt) DESC
                       FETCH FIRST ROW ONLY) Doc_Numident
                       ON t.sc_id = Doc_Numident.Scd_Sc
             WHERE t.Sc_Id = p_Sc_Id;
    END;

    -- вичитка ознак соц. карточки
    PROCEDURE GET_SC_STATUSES (P_SC_ID     IN     NUMBER,
                               Flags_Cur      OUT SYS_REFCURSOR,
                               Insp_Cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        /* OPEN res_cur FOR
           SELECT t.scf_is_pension,
                  'F' AS scf_is_jobless,
                  'T' AS scf_is_accident,
                  'F' AS scf_is_invalid
             FROM sc_feature t
            WHERE t.scf_sc = p_sc_id;*/
        OPEN Flags_Cur FOR
            SELECT t.Scf_Is_Pension     AS Flag,
                   'Пенсіонер'          AS Flag_Name,
                   'pens'               AS Flag_Code,
                   0                    AS rn,
                   'T'                  AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id
            UNION
            SELECT t.scf_is_dasabled          AS Flag,
                   'Особа з інвалідністю'     AS Flag_Name,
                   'invalid'                  AS Flag_Code,
                   3                          AS rn,
                   'T'                        AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id
            -- нові хотєлки. данных пока нету
            /*   Застрахована особа
          2. Отримувач субсидій
          3. Отримувач соціальної допомоги
          4. Отримувач допомоги соціального страхування
          5. Отримувач соціальних пільг
          6. Внутрішньо переміщена особа
          7. Постраждалий внаслідок Чорнобильської катастрофи*/
            UNION
            SELECT t.scf_is_migrant                  AS Flag,
                   'Внутрішньо переміщена особа'     AS Flag_Name,
                   'VPO'                             AS Flag_Code,
                   9                                 AS rn,
                   'F'                               AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id
            /* #78717
            Одинока матір/батько
            Багатодітна сім'я
            Малозабезпечена сім'я

            Прибрати з вкладки відображення наступних статусів:
            Постраждалий внаслідок Чорнобильської катастрофи
            Отримувач соціальних пільг
            Отримувач допомоги соціального страхування
            Отримувач субсидій
            Отримувач соціальної допомоги
            Застрахована особа
            Безробітний
            Особа, з якою стався нещасний випадок на виробництві, проф.захворювання
            */
            UNION
            SELECT t.scf_is_singl_parent      AS Flag,
                   'Одинока матір/батько'     AS Flag_Name,
                   'lonely'                   AS Flag_Code,
                   11                         AS rn,
                   'F'                        AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id
            UNION
            SELECT t.scf_is_large_family     AS Flag,
                   'Багатодітна сім`я'       AS Flag_Name,
                   'multikids'               AS Flag_Code,
                   12                        AS rn,
                   'F'                       AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id
            UNION
            SELECT t.scf_is_low_income         AS Flag,
                   'Малозабезпечена сім`я'     AS Flag_Name,
                   'lowsalary'                 AS Flag_Code,
                   13                          AS rn,
                   'F'                         AS Is_Grid
              FROM Sc_Feature t
             WHERE t.Scf_Sc = p_Sc_Id;


        OPEN Insp_Cur FOR
            WITH
                inv_data
                AS
                    (SELECT t.*
                       FROM v_socialcard  sc
                            LEFT JOIN sc_disability t
                                ON (    t.scy_sc = sc.sc_id
                                    AND t.history_status = 'A')
                      WHERE sc.sc_id = P_SC_ID),
                pens_data
                AS
                    (  SELECT t.*
                         FROM v_socialcard sc
                              JOIN v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                              LEFT JOIN sc_pension t ON (t.scp_id = ch.scc_scp)
                        WHERE sc.sc_id = P_SC_ID
                     ORDER BY t.SCP_BEGIN_DT DESC
                        FETCH FIRST ROW ONLY)
              SELECT *
                FROM (SELECT 'Група'        AS Insp_Name,
                             g.DIC_NAME     AS Insp_Value,
                             'invalid'      AS Insp_Code,
                             0              AS rn
                        FROM inv_data t
                             LEFT JOIN uss_ndi.V_DDN_SCY_GROUP g
                                 ON (g.DIC_VALUE = t.scy_group)
                      /*UNION
                      SELECT 'Дата огляду' AS Insp_Name,
                             to_char(t.scy_inspection_dt, 'DD.MM.YYYY') AS Insp_Value,
                             'invalid' AS Insp_Code
                        FROM inv_data t*/
                      UNION
                      SELECT 'Дата встановлення'
                                 AS Insp_Name,
                             TO_CHAR (t.scy_decision_dt, 'DD.MM.YYYY')
                                 AS Insp_Value,
                             'invalid'
                                 AS Insp_Code,
                             1
                                 AS rn
                        FROM inv_data t
                      UNION
                      SELECT 'Встановлено на період до'
                                 AS Insp_Name,
                             TO_CHAR (t.scy_till_dt, 'DD.MM.YYYY')
                                 AS Insp_Value,
                             'invalid'
                                 AS Insp_Code,
                             2
                                 AS rn
                        FROM inv_data t
                      UNION
                      SELECT 'Причина інвалідності'    AS Insp_Name,
                             NVL ( (SELECT MAX (q.DIC_NAME)
                                      FROM uss_ndi.V_DDN_INV_REASON q
                                     WHERE q.dic_value = t.scy_reason),
                                  t.scy_reason)        AS Insp_Value,
                             'invalid'                 AS Insp_Code,
                             3                         AS rn
                        FROM inv_data t
                      /*UNION
                      SELECT 'Вік' AS Insp_Name,
                             to_char(floor(months_between(trunc(SYSDATE), b.scb_dt) / 12)) AS Insp_Value,
                             'invalid' AS Insp_Code
                        FROM v_socialcard sc
                        JOIN v_sc_change ch ON (ch.scc_id = sc.sc_scc)
                        JOIN v_sc_birth b ON (b.scb_id = ch.scc_scb)
                       WHERE sc.sc_id = P_SC_ID*/


                      UNION
                      SELECT '№ ПС'               AS Insp_Name,
                             t.scp_pnf_number     AS Insp_Value,
                             'pens'               AS Insp_Code,
                             0                    AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Код органу ПФУ'        AS Insp_Name,
                             TO_CHAR (t.scp_org)     AS Insp_Value,
                             'pens'                  AS Insp_Code,
                             1                       AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Вид пенсії'     AS Insp_Name,
                             tp.dic_name      AS Insp_Value,
                             'pens'           AS Insp_Code,
                             2                AS rn
                        FROM pens_data t
                             LEFT JOIN uss_ndi.v_ddn_scp_pens_tp tp
                                 ON (tp.dic_value = t.scp_pens_tp)
                      UNION
                      SELECT 'Основний закон, за яким призначено пенсію'
                                 AS Insp_Name,
                             t.scp_legal_act
                                 AS Insp_Value,
                             'pens'
                                 AS Insp_Code,
                             3
                                 AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Пенсія призначена з'
                                 AS Insp_Name,
                             TO_CHAR (t.scp_begin_dt, 'DD.MM.YYYY')
                                 AS Insp_Value,
                             'pens'
                                 AS Insp_Code,
                             4
                                 AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Пенсія призначена по'
                                 AS Insp_Name,
                             TO_CHAR (t.scp_end_dt, 'DD.MM.YYYY')
                                 AS Insp_Value,
                             'pens'
                                 AS Insp_Code,
                             5
                                 AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Причина зняття з виплати'     AS Insp_Name,
                             tp.DIC_NAME                    AS Insp_Value,
                             'pens'                         AS Insp_Code,
                             6                              AS rn
                        FROM pens_data t
                             LEFT JOIN uss_ndi.v_ddn_scp_psn tp
                                 ON (tp.DIC_VALUE = t.scp_psn)
                      UNION
                      SELECT 'Дата перерахунку'
                                 AS Insp_Name,
                             TO_CHAR (t.scp_recalc_dt, 'DD.MM.YYYY')
                                 AS Insp_Value,
                             'pens'
                                 AS Insp_Code,
                             7
                                 AS rn
                        FROM pens_data t
                      UNION
                      SELECT 'Спосіб виплати'     AS Insp_Name,
                             t.scp_pay_tp         AS Insp_Value,
                             'pens'               AS Insp_Code,
                             8                    AS rn
                        FROM pens_data t)
            ORDER BY rn;
    END;

    -- #74082: вибірка пільг
    PROCEDURE GET_SC_PRIVILEGES (P_SC_ID       IN     NUMBER,
                                 RES_CUR          OUT SYS_REFCURSOR,
                                 RES_CUR_DET      OUT SYS_REFCURSOR)
    IS
    BEGIN
        NULL;
    /*OPEN res_cur FOR
      SELECT DISTINCT t.lg_cd,
             t.lg_cd_name
        FROM v_edarp_b_lgp t
       WHERE t.sc_id = p_sc_id;

    OPEN RES_CUR_DET FOR
      SELECT z.*
       FROM (SELECT t.r_ncardp,
                    t.lg_cd,
                    'Дата початку' AS NAME,
                    to_char(t.lg_dtb, 'DD.MM.YYYY') AS VALUE,
                    1 AS rn
               FROM b_lgp t
              WHERE t.lg_dte > TRUNC(SYSDATE)
             UNION
             SELECT t.r_ncardp,
                    t.lg_cd,
                    'Дата закінчення' AS NAME,
                    to_char(t.lg_dte, 'DD.MM.YYYY') AS VALUE,
                    2 AS rn
               FROM b_lgp t
              WHERE t.lg_dte > TRUNC(SYSDATE)
             UNION
             SELECT t.r_ncardp,
                    t.lg_cd,
                    'Різновид використання' AS NAME,
                    to_char(k.kor_name) AS VALUE,
                    3 AS rn
               FROM b_lgp t
               JOIN b_korys k ON (k.kor_kod = t.lg_stat)
              WHERE t.lg_dte > TRUNC(SYSDATE)
             UNION
             SELECT t.r_ncardp,
                    t.lg_cd,
                    'Вартість пільги (резерв)' AS NAME,
                    to_char(t.lg_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',''''')  AS VALUE,
                    4 AS rn
               FROM b_lgp t
              WHERE t.lg_dte > TRUNC(SYSDATE)
             UNION
             SELECT t.r_ncardp,
                    t.lg_cd,
                    'Послуги' AS NAME,
                    to_char(t.lg_paydservcd) AS VALUE, -- потом через справочник
                    5 AS rn
               FROM b_lgp t
              WHERE t.lg_dte > TRUNC(SYSDATE)
            ) z
       JOIN b_reestrlg t ON (t.r_ncardp = z.r_ncardp)
       JOIN b_reestrlg2sc g ON (g.r_ncardp = t.r_ncardp)
      WHERE g.sc_id = p_sc_id;*/
    END;

    -- info:   Выбор информации об аттрибутах документа
    -- params:
    -- note:
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Nda_Cur FOR
            SELECT Nda.Nda_Id,
                   Nda.Nda_Name,
                   Nda.Nda_Is_Key,
                   Nda.Nda_Ndt,
                   Nda.Nda_Order,
                   Nda.Nda_Pt,
                   NVL (nda.nda_nng, -1)     AS nda_nng,
                   Nda.Nda_Is_Req,
                   Nda.Nda_Def_Value,
                   Nda.Nda_Can_Edit,
                   Nda.Nda_Need_Show,
                   Pt.Pt_Id,
                   Pt.Pt_Code,
                   Pt.Pt_Name,
                   Pt.Pt_Ndc,
                   Pt.Pt_Edit_Type,
                   Pt.Pt_Data_Type,
                   Ndc.Ndc_Code
              FROM Uss_Ndi.v_Ndi_Document_Attr  Nda
                   JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                   LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config Ndc
                       ON Ndc.Ndc_Id = Pt.Pt_Ndc
             WHERE Nda_Ndt = p_Ndt_Id;
    END;

    -- info:   Отримання інформації щодо пільг особи
    -- params:
    -- note:   #82141
    PROCEDURE get_sc_benefits (p_sc_id      IN     socialcard.sc_id%TYPE,
                               p_start_dt   IN     DATE,
                               p_stop_dt    IN     DATE,
                               p_res_cur       OUT SYS_REFCURSOR)
    IS
        l_check_user   VARCHAR2 (1)
                           := tools.CheckUserRoleStr ('W_ESR_BENEFIT_VIEW');
        l_wut          NUMBER := tools.getcurrwut;
    BEGIN
        IF (l_check_user = 'F')
        THEN
            uss_person.Api$socialcard.write_sc_log (p_sc_id,
                                                    NULL,
                                                    NULL,
                                                    CHR (38) || '224',
                                                    NULL,
                                                    NULL);
            COMMIT;
            raise_application_error (-20000, 'Вкладка пільги недуступна!');
        END IF;

        OPEN p_res_cur FOR
              SELECT scbc_id,                   --Ід пільгової категорії особи
                     scbc_nbc,                        --Ід пільгової категорії
                     nbc_name,                          --Категорія пільговика
                     nbt_id,                                       --ІД пільги
                     nbt_name,                                        --Пільга
                     TO_CHAR (nbc_benefit_amount) || nbc_unit
                         AS benefit_amount,                           --Розмір
                     scbc_start_dt,                         --Дата початку дії
                     scbc_stop_dt,                       --Дата завершення дії
                     nbc_norm_act,                       --Норма законодавства
                     bt.scbt_start_dt,
                     bt.scbt_stop_dt
                FROM sc_benefit_category t
                     JOIN uss_ndi.v_ndi_benefit_category ON nbc_id = scbc_nbc
                     LEFT JOIN v_sc_benefit_type bt ON bt.scbt_scbc = t.scbc_id
                     LEFT JOIN uss_ndi.v_ndi_benefit_type ON nbt_id = scbt_nbt
                     LEFT JOIN uss_ndi.v_ndi_nbc_setup
                         ON nbcs_nbt = scbt_nbt AND nbcs_nbc = scbc_nbc
               WHERE     scbc_sc = p_sc_id
                     AND scbc_st = 'A'
                     AND (   l_wut IN (31, 41)
                          OR nbc_id NOT IN (1,
                                            2,
                                            3,
                                            4,
                                            11,
                                            12,
                                            13,
                                            22,
                                            23,
                                            58,
                                            80,
                                            85,
                                            86,
                                            87,
                                            88,
                                            136,
                                            137,
                                            138,
                                            139))
                     AND (p_start_dt IS NULL OR t.scbc_stop_dt >= p_start_dt)
                     AND (p_stop_dt IS NULL OR t.scbc_start_dt <= p_stop_dt)
            ORDER BY nbc_name;
    END;

    -- info:   Отримання інформації щодо документів що підтверджують пільгові категорії особи
    -- params:
    -- note:   #82141
    PROCEDURE get_sc_benefit_docs (
        p_scbc_id   IN     sc_benefit_category.scbc_id%TYPE,
        p_res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT scd_id,                                    --Ід документу
                     ndt_name,                         -- Назва типу документу
                     scd_seria || scd_number     AS doc_sn, --Серія та номер документу
                     scd_doc,
                     scd_dh
                FROM v_sc_benefit_docs b
                     JOIN v_sc_document ON scd_id = scbd_scd
                     JOIN uss_ndi.v_ndi_document_type ON ndt_id = scd_ndt
               WHERE scbd_scbc = p_scbc_id
            ORDER BY ndt_name;
    END;

    -- info:   Реєстр пільг
    -- params: p_numident - ІПН пільговика
    --         p_pasp_sn - Серія/номер паспорта пільговика
    --         p_pib - ПІБ пільговика
    --         p_nbc_id - категорія пільговика
    --         p_nbt_list - перелік пільг
    -- note:   #82142
    PROCEDURE get_person_benefits_list (p_numident       VARCHAR2,
                                        p_pasp_sn        VARCHAR2,
                                        p_pib            VARCHAR2,
                                        p_nbc_id         NUMBER,
                                        p_nbt_list       VARCHAR2,
                                        p_res_cur    OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.GetCurrOrgTo;
    BEGIN
        IF     TRIM (p_numident) IS NULL
           AND TRIM (p_pasp_sn) IS NULL
           AND TRIM (p_pib) IS NULL
           AND p_nbc_id IS NULL
           AND p_nbt_list IS NULL
        THEN
            raise_application_error (
                -20000,
                'Необхідно вказати параметр(-и) пошуку!');
        END IF;

        TOOLS.validate_param (p_numident);
        TOOLS.validate_param (p_pasp_sn);
        TOOLS.validate_param (p_pib);
        TOOLS.validate_param (p_nbt_list);

        OPEN p_res_cur FOR
               q'[SELECT sc_id, --Ід соц картки для переходу
             scbc_id, --Ід пільгової категорії особи для отримання документів
             (sci_ln || ' ' || sci_fn || ' ' || sci_mn) AS pib, --ПІБ пільговика
             (SELECT scd_seria || scd_number
                FROM v_sc_document
               WHERE scd_sc = sc_id
                 AND scd_ndt IN (6, 7)
                 AND scd_st IN ('A', '1')
               ORDER BY scd_start_dt DESC
               FETCH FIRST ROW ONLY) AS passport, --Паспорт пільговика
             (SELECT scd_number
                FROM v_sc_document
               WHERE scd_sc = sc_id
                 AND scd_ndt = 5
                 AND scd_st IN ('A', '1')
               ORDER BY scd_start_dt DESC
               FETCH FIRST ROW ONLY) AS numident, --ІПН пільговика
             nbc_name, --Категорія пільговика
             (SELECT nbt_name FROM uss_ndi.v_ndi_benefit_type WHERE nbt_id = scbt_nbt) AS nbt_name, --Пільга
             to_char(scbt_start_dt, 'DD.MM.YYYY') || '-' || to_char(scbt_stop_dt, 'DD.MM.YYYY') AS benefit_period, --Період дії пільги
             nbc_norm_act --Норма законодавства
        FROM v_socialcard
        JOIN v_sc_change ON scc_id = sc_scc
                        AND scc_sc = sc_id
        JOIN v_sc_identity ON sci_id = scc_sci
                          AND sci_sc = sc_id
        JOIN v_sc_benefit_category ON scbc_sc = sc_id
                                  AND scbc_st = 'A'
        JOIN uss_ndi.v_ndi_benefit_category ON nbc_id = scbc_nbc
        JOIN v_sc_benefit_type ON scbt_sc = sc_id
                              AND scbt_st = 'A' AND scbt_scbc = scbc_id --20230425 Чубаров
        --20230425 JOIN uss_ndi.v_ndi_nbc_setup ON nbcs_nbt = scbt_nbt AND nbcs_nbc = scbc_nbc
       WHERE 1 = 1
         and rownum <= 5000
         ]'
            || (CASE
                    WHEN l_org_to NOT IN (30, 40)
                    THEN
                        'and nbc_id not in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
                END)
            || (CASE
                    WHEN p_numident IS NOT NULL
                    THEN
                        q'[
         AND EXISTS (SELECT 1
                       FROM v_sc_document
                      WHERE scd_sc = sc_id
                        AND scd_ndt = 5
                        AND scd_st IN ('A', '1')
                        AND scd_number LIKE ']' || p_numident || q'[%')]'
                END)
            || (CASE
                    WHEN p_pasp_sn IS NOT NULL
                    THEN
                           q'[
         AND EXISTS (SELECT 1
                       FROM v_sc_document
                      WHERE scd_sc = sc_id
                        AND scd_ndt IN (6, 7)
                        AND scd_st IN ('A', '1')
                        AND scd_seria || scd_number LIKE ']'
                        || p_pasp_sn
                        || q'[%')]'
                END)
            || (CASE
                    WHEN p_pib IS NOT NULL
                    THEN
                           q'[
        AND UPPER(sci_ln || ' ' || sci_fn || ' ' || sci_mn) LIKE ']'
                        || UPPER (p_pib)
                        || q'[%']'
                END)
            || (CASE
                    WHEN p_nbc_id IS NOT NULL THEN '
        AND scbc_nbc = ' || TO_CHAR (p_nbc_id)
                END)
            || (CASE
                    WHEN p_nbt_list IS NOT NULL THEN '
        AND scbt_nbt IN (' || p_nbt_list || ')'
                END);
    END;

    -- info:   Реєстр субсидій і Картка домогосподарства
    -- params: p_numident - ІПН отримувача субсидії
    --         p_pasp_sn - Серія/номер паспорта отримувача субсидії
    --         p_pib - ПІБ отримувача субсидії
    --         p_ho_address - Адреса домогосподарства
    -- note:   #82143
    PROCEDURE get_person_subsidy_list (p_numident         VARCHAR2,
                                       p_pasp_sn          VARCHAR2,
                                       p_pib              VARCHAR2,
                                       p_hh_address       VARCHAR2,
                                       p_res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF     TRIM (p_numident) IS NULL
           AND TRIM (p_pasp_sn) IS NULL
           AND TRIM (p_pib) IS NULL
           AND TRIM (p_hh_address) IS NULL
        THEN
            raise_application_error (
                -20000,
                'Необхідно вказати параметр(-и) пошуку!');
        END IF;

        TOOLS.validate_param (p_numident);
        TOOLS.validate_param (p_pasp_sn);
        TOOLS.validate_param (p_pib);
        TOOLS.validate_param (p_hh_address);

        OPEN p_res_cur FOR
               q'[SELECT sc_id, --Ід соц картки для переходу
               schh_id, --Ід домогосподарства для переходу на картку
               (sci_ln || ' ' || sci_fn || ' ' || sci_mn) AS pib, --ПІБ отримувача субсидії
               (SELECT scd_seria || scd_number
                  FROM v_sc_document
                 WHERE scd_sc = sc_id
                   AND scd_ndt IN (6, 7)
                   AND scd_st IN ('A', '1')
                 ORDER BY scd_start_dt DESC
                 FETCH FIRST ROW ONLY) AS passport, --Паспорт отримувача субсидії
               (SELECT scd_number
                  FROM v_sc_document
                 WHERE scd_sc = sc_id
                   AND scd_ndt = 5
                   AND scd_st IN ('A', '1')
                 ORDER BY scd_start_dt DESC
                 FETCH FIRST ROW ONLY) AS numident, --ІПН отримувача субсидії
               REGEXP_REPLACE((sca_country || ' ' || sca_region || ' ' || sca_district || ' ' || sca_city || ' ' || sca_street ||
                              (CASE WHEN TRIM(sca_building) IS NOT NULL THEN ', ' || TRIM(sca_building) END) ||
                              (CASE WHEN TRIM(sca_block) IS NOT NULL THEN ', ' || TRIM(sca_block) END) ||
                              (CASE WHEN TRIM(sca_apartment) IS NOT NULL THEN ', кв.' || TRIM(sca_apartment) END)), '  ', ' ') AS ho_address, --Адреса домогосподарства
               scpp_sum, --Розмір субсидії
               to_char(scpp_pfu_pd_start_dt, 'DD.MM.YYYY') || '-' || to_char(scpp_pfu_pd_stop_dt, 'DD.MM.YYYY') AS subs_period, --Період дії субсидії
               NULL AS norm_act --Норма законодавства
          FROM v_socialcard
          JOIN v_sc_change ON scc_id = sc_scc
                          AND scc_sc = sc_id
          JOIN v_sc_identity ON sci_id = scc_sci
                            AND sci_sc = sc_id
          JOIN v_sc_address ON sca_sc = sc_id
                           AND sca_tp = '5'
          JOIN v_sc_household ON schh_sc = sc_id
                             AND schh_sca = sca_id
          JOIN v_sc_pfu_pay_summary ON scpp_sc = sc_id
                                   AND scpp_schh = schh_id
         WHERE 1 = 1]'
            || (CASE
                    WHEN p_numident IS NOT NULL
                    THEN
                        q'[
           AND EXISTS (SELECT 1
                         FROM v_sc_document
                        WHERE scd_sc = sc_id
                          AND scd_ndt = 5
                          AND scd_st IN ('A', '1')
                          AND scd_number LIKE ']' || p_numident || q'[%')]'
                END)
            || (CASE
                    WHEN p_pasp_sn IS NOT NULL
                    THEN
                           q'[
           AND EXISTS (SELECT 1
                         FROM v_sc_document
                        WHERE scd_sc = sc_id
                          AND scd_ndt IN (6, 7)
                          AND scd_st IN ('A', '1')
                          AND scd_seria || scd_number LIKE ']'
                        || p_pasp_sn
                        || q'[%')]'
                END)
            || (CASE
                    WHEN p_pib IS NOT NULL
                    THEN
                           q'[
          AND UPPER(sci_ln || ' ' || sci_fn || ' ' || sci_mn) LIKE ']'
                        || UPPER (p_pib)
                        || q'[%']'
                END)
            || (CASE
                    WHEN p_hh_address IS NOT NULL
                    THEN
                           q'[
          AND UPPER(sca_country || ' ' || sca_region || ' ' || sca_district || ' ' || sca_city || ' ' || sca_street || ' ' || sca_building || ' ' || sca_apartment) LIKE ']'
                        || UPPER (p_hh_address)
                        || q'[%']'
                END);
    END;

    -- info:   отримання картки домогосподарства
    -- params: p_schh_id - Ідентифікатор домогосподарства
    -- note:   #82143
    PROCEDURE get_household_card (p_schh_id        sc_household.schh_id%TYPE,
                                  p_addr_cur   OUT SYS_REFCURSOR,
                                  p_pers_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Адреса домогосподарства
        OPEN p_addr_cur FOR
            SELECT REGEXP_REPLACE (
                       (   sca_country
                        || ' '
                        || sca_region
                        || ' '
                        || sca_district
                        || ' '
                        || sca_city
                        || ' '
                        || sca_street
                        || (CASE
                                WHEN TRIM (sca_building) IS NOT NULL
                                THEN
                                    ', ' || TRIM (sca_building)
                            END)
                        || (CASE
                                WHEN TRIM (sca_block) IS NOT NULL
                                THEN
                                    ', ' || TRIM (sca_block)
                            END)
                        || (CASE
                                WHEN TRIM (sca_apartment) IS NOT NULL
                                THEN
                                    ', кв.' || TRIM (sca_apartment)
                            END)),
                       '  ',
                       ' ')    AS hh_address
              FROM v_sc_household
                   JOIN v_sc_address
                       ON sca_id = schh_sca AND sca_tp IN ('4', '5')
             WHERE schh_id = p_schh_id;

        --Особи що отримували житлові субсидії
        OPEN p_pers_cur FOR
              SELECT scpp_id, --Ід виплати для відкриття "Перелік осіб що входять до домогосподарства"/"Перелік житлово-комунальних послуг"
                     (SELECT (   sci_ln
                              || ' '
                              || sci_fn
                              || ' '
                              || sci_mn)
                        FROM v_socialcard
                             JOIN v_sc_change
                                 ON     scc_id = sc_scc
                                    AND scc_sc = scpp_sc
                             JOIN v_sc_identity
                                 ON     sci_id = scc_sci
                                    AND scc_sc = scpp_sc
                       WHERE sc_id = scpp_sc)     AS pib,                --ПІБ
                        TO_CHAR (scpp_pfu_pd_start_dt,
                                 'DD.MM.YYYY')
                     || '-'
                     || TO_CHAR (scpp_pfu_pd_stop_dt,
                                 'DD.MM.YYYY')    AS pay_period, --період виплати
                     scpp_sum                                 --розмір виплати
                FROM v_sc_pfu_pay_summary
               WHERE scpp_schh = p_schh_id
            ORDER BY 2;
    END;

    -- info:   Перелік осіб що входять до домогосподарства
    -- params: p_scpp_id - Ідентифікатор виплати
    -- note:   #82143
    PROCEDURE get_household_persons (
        p_scpp_id       sc_pfu_pay_summary.scpp_id%TYPE,
        p_res_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT (SELECT (   sci_ln
                              || ' '
                              || sci_fn
                              || ' '
                              || sci_mn)
                        FROM v_sc_identity
                       WHERE     sci_sc = scpf_sc
                             AND sci_id = scc_sci)
                         AS pib,                                         --ПІБ
                     (  SELECT scd_number
                          FROM v_sc_document
                         WHERE     scd_sc = scpf_sc
                               AND scd_ndt = 5
                               AND scd_st IN ('A', '1')
                      ORDER BY scd_start_dt DESC
                         FETCH FIRST ROW ONLY)
                         AS numident,                                    --ІПН
                     (  SELECT scd_seria || scd_number
                          FROM v_sc_document
                         WHERE     scd_sc = scpf_sc
                               AND scd_ndt IN (6, 7)
                               AND scd_st IN ('A', '1')
                      ORDER BY scd_start_dt DESC
                         FETCH FIRST ROW ONLY)
                         AS passport,                                --паспорт
                     (SELECT scb_dt
                        FROM v_sc_birth
                       WHERE scb_sc = scpf_sc AND scb_id = scc_scb)
                         AS birth_dt,                        --дата народження
                     (SELECT dic_name
                        FROM uss_ndi.v_ddn_relation_tp
                       WHERE dic_value = scpf_relation_tp)
                         AS family_relation_tp     --ступінь родинного зв’язку
                FROM v_sc_scpp_family
                     JOIN v_socialcard ON sc_id = scpf_sc
                     JOIN v_sc_change ON scc_id = sc_scc AND scc_sc = scpf_sc
               WHERE scpf_scpp = p_scpp_id
            ORDER BY 1;
    END;

    -- info:   Перелік житлово-комунальних послуг
    -- params: p_scpp_id - Ідентифікатор виплати
    -- note:   #82143
    PROCEDURE get_household_services (
        p_scpp_id       sc_pfu_pay_summary.scpp_id%TYPE,
        p_res_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT --(SELECT dic_name FROM uss_ndi.v_ddn_housing_serv_tp WHERE dic_value = d.scpd_service_tp) AS service_name, --назва послуги
                     (SELECT nppt_name
                        FROM uss_ndi.v_ndi_pfu_payment_type
                       WHERE nppt_id = d.scpd_nppt)    AS service_name, --назва послуги
                     d.scpd_sum                               --розмір виплати
                FROM v_sc_scpp_detail d
               WHERE scpd_scpp = p_scpp_id
            ORDER BY 1, d.scpd_start_dt;
    END;
BEGIN
    NULL;
END Dnet$socialcard;
/