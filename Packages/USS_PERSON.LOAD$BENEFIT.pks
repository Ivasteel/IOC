/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$BENEFIT
IS
    -- Author  : JSHPAK
    -- Created : 19.12.2022 12:40:40
    -- Purpose :

    PROCEDURE Load_Benefit (p_part VARCHAR DEFAULT 'ALL');
END;
/


/* Formatted on 8/12/2025 5:57:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$BENEFIT
IS
    cEndOfLine   CHAR (2) := CHR (13) || CHR (10);
    ExError      EXCEPTION;

    PROCEDURE SetAction (p_message VARCHAR2)
    IS
    BEGIN
        DBMS_APPLICATION_INFO.set_action (action_name => p_message);
    END;

    PROCEDURE SetEdarpTrg (p_raj         edarp.x_trg.raj%TYPE,
                           p_r_ncardp    edarp.x_trg.r_ncardp%TYPE,
                           p_src_code    edarp.x_trg.src_code%TYPE,
                           p_src_value   edarp.x_trg.src_value%TYPE,
                           p_trg_code    edarp.x_trg.trg_code%TYPE,
                           p_trg_id      edarp.x_trg.trg_id%TYPE)
    IS
    BEGIN
        INSERT INTO edarp.x_trg (raj,
                                 r_ncardp,
                                 src_code,
                                 src_value,
                                 trg_code,
                                 trg_id,
                                 trg_create_dt)
             VALUES (p_raj,
                     p_r_ncardp,
                     p_src_code,
                     p_src_value,
                     p_trg_code,
                     p_trg_id,
                     SYSDATE);
    END;

    PROCEDURE SetEdarpTrgMsg (p_raj        edarp.x_trg.raj%TYPE,
                              p_r_ncardp   edarp.x_trg.r_ncardp%TYPE,
                              p_trg_msg    edarp.x_trg.trg_msg%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO edarp.x_trg (raj,
                                 r_ncardp,
                                 trg_create_dt,
                                 trg_msg)
             VALUES (p_raj,
                     p_r_ncardp,
                     SYSDATE,
                     p_trg_msg);

        COMMIT;
    END;

    PROCEDURE Load_Benefit (p_part VARCHAR DEFAULT 'ALL')
    IS
        l_sc          NUMBER (14);
        l_sc_scc      NUMBER (14);
        l_sc_unique   VARCHAR2 (100);

        l_scbc        NUMBER (14);
        l_scbc_dt     DATE;
        l_scbc_dte    DATE;
        l_scd         NUMBER;

        l_scbt        NUMBER (14);
        l_scbt_dt     DATE;
        l_scbt_dte    DATE;

        l_create_dt   DATE := SYSDATE;
        l_cnt         NUMBER := 0;
    BEGIN
        IF p_part <> '*'
        THEN
            DBMS_APPLICATION_INFO.set_module (
                module_name   => $$PLSQL_UNIT || '.Part=' || p_part,
                action_name   => 'Load_Benefit');
        END IF;

        FOR rec
            IN (SELECT COUNT (*) OVER ()               AS cnt,
                       vt.raj || '_' || vt.r_ncardp    AS num_ap_pd,
                       vt.raj,
                       vt.r_ncardp,
                       fam_fio,
                       TRIM (SUBSTR (fam_fio || '   ',
                                     1,
                                     INSTR (fam_fio || '   ',
                                            ' ',
                                            1,
                                            1)))       AS fio_ln,
                       TRIM (SUBSTR (fam_fio || '   ',
                                     INSTR (fam_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (fam_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (fam_fio || '   ',
                                              ' ',
                                              1,
                                              1)))     AS fio_fn,
                       TRIM (SUBSTR (fam_fio || '   ',
                                     INSTR (fam_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))             AS fio_sn,
                       fam_numtaxp,
                       fam_pasp,
                       CASE
                           WHEN     REGEXP_LIKE (fam_numtaxp,
                                                 '^(\d){10}$')
                                AND fam_numtaxp <> '0000000000'
                           THEN
                               fam_numtaxp
                           ELSE
                               NULL
                       END                             AS fam_numident,
                       CASE
                           WHEN     REGEXP_LIKE (fam_numtaxp,
                                                 '^(\d){10}$')
                                AND fam_numtaxp <> '0000000000'
                           THEN
                               5
                           ELSE
                               NULL
                       END                             fam_numident_ndt,
                       CASE
                           WHEN REGEXP_LIKE (fam_pasp, '^(\d){9}$')
                           THEN
                               NULL                           -- новій паспорт
                           WHEN REGEXP_LIKE (fam_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, 1, 2)       -- старій паспорт из архива
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, 1, 4)        -- свидетельство о рождении
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, 1, 3)        -- свидетельство о рождении
                           ELSE
                               NULL
                       END                             AS fam_pasp_ser,
                       CASE
                           WHEN REGEXP_LIKE (fam_pasp, '^(\d){9}$')
                           THEN
                               fam_pasp                       -- новій паспорт
                           WHEN REGEXP_LIKE (fam_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, -6, 6)       -- старій паспорт из архива
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, -6, 6)        -- свидетельство о рождении
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               SUBSTR (fam_pasp, -6, 6)        -- свидетельство о рождении
                           ELSE
                               fam_pasp
                       END                             AS fam_pasp_num,
                       CASE
                           WHEN REGEXP_LIKE (fam_pasp, '^(\d){9}$')
                           THEN
                               7                              -- новій паспорт
                           WHEN REGEXP_LIKE (fam_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               6                         -- старій паспорт из архива
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               37                         -- свидетельство о рождении
                           WHEN REGEXP_LIKE (
                                    fam_pasp,
                                    '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                           THEN
                               37                         -- свидетельство о рождении
                           ELSE
                               162
                       END                             AS fam_pasp_ndt,
                       fam_dtpasp,
                       fam_deppasp,
                       fam_pol,
                       fam_dtbirth,
                       --fam_osob,
                       fam_dtbeg,
                       fam_dtexit,
                       --r_cdobl,
                       --r_cdraj,
                       --r_cdul,
                       --r_index,
                       --r_house,
                       --r_apt,
                       --r_build,
                       SYSDATE                         AS src_dt
                  FROM (SELECT --+ full(t) full(fam)
                               t.raj,
                               t.r_ncardp,
                               REPLACE (
                                   REPLACE (
                                       TRANSLATE (UPPER (fam.fam_fio),
                                                  'ETIOPAHKXCBM',
                                                  'ЕТІОРАНКХСВМ'),
                                       '   ',
                                       ' '),
                                   '  ',
                                   ' ')                      AS fam_fio,
                               CASE
                                   WHEN     REGEXP_LIKE (fam.fam_numtaxp,
                                                         '^(\d){10}$')
                                        AND fam.fam_numtaxp <> '0000000000'
                                   THEN
                                       fam.fam_numtaxp
                                   ELSE
                                       NULL
                               END                           AS fam_numtaxp,
                               REPLACE (
                                   REPLACE (
                                       TRANSLATE (UPPER (fam.fam_pasp),
                                                  'ETIOPAHKXCBM',
                                                  'ЕТІОРАНКХСВМ'),
                                       '-',
                                       ''),
                                   ' ',
                                   '')                       AS fam_pasp,
                               fam_dtpasp,
                               TRANSLATE (UPPER (fam.fam_deppasp),
                                          'ETIOPAHKXCBM',
                                          'ЕТІОРАНКХСВМ')    AS fam_deppasp,
                               fam.fam_pol,
                               fam.fam_dtbirth,
                               fam.fam_osob,
                               fam.fam_dtbeg,
                               fam.fam_dtexit,
                               t.r_cdobl,
                               t.r_cdraj,
                               t.r_cdul,
                               t.r_index,
                               t.r_house,
                               t.r_apt,
                               t.r_build
                          FROM edarp.b_reestrlg  t
                               JOIN edarp.b_famp fam
                                   ON     fam.raj = t.raj
                                      AND fam.r_ncardp = t.r_ncardp
                                      AND fam.fam_cdrelat = 1
                                      AND fam.fam_nomf = 0
                                      AND fam.fam_cdexit = 0
                         WHERE     717 = 717
                               AND (   (NVL (
                                            SUBSTR (
                                                CASE
                                                    WHEN     REGEXP_LIKE (
                                                                 t.r_numtax,
                                                                 '^(\d){10}$')
                                                         AND t.r_numtax <>
                                                             '0000000000'
                                                    THEN
                                                        t.r_numtax
                                                    ELSE
                                                        NULL
                                                END,
                                                -1,
                                                1),
                                            'NULL') =
                                        p_part)
                                    OR (p_part = 'ALL'))--and fam.r_ncardp = 693
                                                        ) vt
                       LEFT JOIN edarp.x_trg trg
                           ON     trg.raj = vt.raj
                              AND trg.r_ncardp = vt.r_ncardp
                              AND (   trg.trg_code =
                                      'USS_PERSON.SC_BENEFIT_CATEGORY'
                                   OR trg.trg_msg IS NOT NULL)
                 WHERE trg.raj || trg.r_ncardp IS NULL)
        LOOP
            DECLARE
                l_cnt_katpp   NUMBER;
            BEGIN
                l_cnt := l_cnt + 1;
                SetAction (
                       'ОР №'
                    || rec.raj
                    || '_'
                    || rec.r_ncardp
                    || '. Запис '
                    || l_cnt
                    || ' з '
                    || rec.cnt);

                l_sc := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;

                l_sc :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn            => rec.fio_fn,
                        p_ln            => rec.fio_ln,
                        p_mn            => rec.fio_sn,
                        p_gender        =>
                            CASE
                                WHEN rec.fam_pol = 1 THEN 'M'
                                WHEN rec.fam_pol = 2 THEN 'F'
                                ELSE 'V'
                            END,
                        p_nationality   => -1,
                        p_src_dt        => rec.src_dt,
                        p_birth_dt      => rec.fam_dtbirth,
                        p_inn_num       => rec.fam_numident,
                        p_inn_ndt       => rec.fam_numident_ndt,
                        p_doc_ser       => rec.fam_pasp_ser,
                        p_doc_num       => rec.fam_pasp_num,
                        p_doc_ndt       => rec.fam_pasp_ndt,
                        p_doc_unzr      => NULL,
                        p_doc_is        => rec.fam_deppasp,
                        p_doc_bdt       => rec.fam_dtpasp,
                        p_doc_edt       => NULL,
                        p_src           => '717',
                        p_sc            => l_sc,
                        p_sc_unique     => l_sc_unique,
                        p_sc_scc        => l_sc_scc);

                IF l_sc > 0
                THEN
                    --------------------------
                    SELECT COUNT (*)
                      INTO l_cnt_katpp
                      FROM edarp.b_katpp p
                     WHERE     p.raj = rec.raj
                           AND p.r_ncardp = rec.r_ncardp
                           AND COALESCE (p.katp_cd, 0) <> 0;

                    IF l_cnt_katpp > 0
                    THEN
                        FOR rec_cat
                            IN (SELECT p.raj,
                                       p.r_ncardp,
                                       p.katp_cd,
                                       p.katp_dt,
                                       p.katp_dte,
                                       p.katp_doc,
                                       p.katp_dep,
                                       c.nbc_id,
                                       n.nbts_ndt
                                  FROM edarp.b_katpp  p
                                       LEFT JOIN
                                       uss_ndi.v_ndi_benefit_category c
                                           ON c.nbc_code = p.katp_cd
                                       LEFT JOIN
                                       uss_ndi.v_ndi_nbc_ndt_setup n
                                           ON     n.nbts_nbc = c.nbc_id
                                              AND n.nbts_is_def = 'T'
                                 WHERE     717 = 717
                                       AND COALESCE (p.katp_cd, 0) <> 0
                                       AND p.raj = rec.raj
                                       AND p.r_ncardp = rec.r_ncardp)
                        LOOP
                            BEGIN
                                -- init
                                l_scbc := NULL;
                                l_scd := NULL;

                                IF rec_cat.nbc_id IS NULL
                                THEN
                                    SetEdarpTrgMsg (
                                        rec.raj,
                                        rec.r_ncardp,
                                           'Для кода категорії пільговика "'
                                        || rec_cat.katp_cd
                                        || '" - відсутне значення у довіднику "Пільгові категорії особи".');
                                    RAISE ExError;
                                END IF;

                                IF rec_cat.nbts_ndt IS NULL
                                THEN
                                    SetEdarpTrgMsg (
                                        rec.raj,
                                        rec.r_ncardp,
                                           'Для кода категорії пільговика "'
                                        || rec_cat.katp_cd
                                        || '" - не вказано тип документу який підтверджує пільгу.');
                                    RAISE ExError;
                                END IF;

                                -- поиск категрии льготы для человека
                                SELECT ddd.scbc_id,
                                       ddd.scbc_start_dt,
                                       ddd.scbc_stop_dt
                                  INTO l_scbc, l_scbc_dt, l_scbc_dte
                                  FROM sc_benefit_category ddd
                                 WHERE     ddd.scbc_sc = l_sc
                                       AND ddd.scbc_nbc = rec_cat.nbc_id;

                                -- если дата начала категории более ранняя чем было раньше то меняем на более ранююю
                                IF COALESCE (
                                       l_scbc_dt,
                                       TO_DATE ('31.12.2099', 'dd.mm.yyyy')) >
                                   rec_cat.katp_dt
                                THEN
                                    UPDATE sc_benefit_category ddd
                                       SET ddd.scbc_start_dt =
                                               rec_cat.katp_dt
                                     WHERE ddd.scbc_id = l_scbc;
                                END IF;

                                -- если дата категории льготы более поздняя то меняем дату на более позднюю
                                IF COALESCE (
                                       l_scbc_dte,
                                       TO_DATE ('01.01.1900', 'dd.mm.yyyy')) <
                                   rec_cat.katp_dte
                                THEN
                                    UPDATE sc_benefit_category ddd
                                       SET ddd.scbc_stop_dt =
                                               rec_cat.katp_dte
                                     WHERE ddd.scbc_id = l_scbc;
                                END IF;
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN -- если категории льготы у человека небыло то создаем новую категорию
                                    -- вставка новой категории по льготе
                                    INSERT INTO sc_benefit_category (
                                                    scbc_id,
                                                    scbc_sc,
                                                    scbc_nbc,
                                                    scbc_start_dt,
                                                    scbc_stop_dt,
                                                    scbc_src,
                                                    scbc_create_dt,
                                                    scbc_modify_dt,
                                                    scbc_st)
                                         VALUES (0,
                                                 l_sc,
                                                 rec_cat.nbc_id,
                                                 rec_cat.katp_dt,
                                                 rec_cat.katp_dte,
                                                 '717',
                                                 l_create_dt,
                                                 NULL,
                                                 'A')
                                      RETURNING scbc_id
                                           INTO l_scbc;
                            END;

                            -- Adddddddd
                            SetEdarpTrg (rec.raj,
                                         rec.r_ncardp,
                                         'EDARP.B_KATPP',
                                         rec_cat.katp_cd,
                                         'USS_PERSON.SC_BENEFIT_CATEGORY',
                                         l_scbc);

                            ----------------------------------------------------------------------------------------------------------------------------------------------

                            BEGIN
                                  -- поиск документа определяющего льготу у персоны (поиск по всем атрибутам)
                                  SELECT d.scd_id
                                    INTO l_scd
                                    FROM sc_document d
                                   WHERE     d.scd_sc = l_sc
                                         AND d.scd_ndt = rec_cat.nbts_ndt
                                         AND UPPER (
                                                 d.scd_seria || d.scd_number) =
                                             UPPER (TRIM (rec_cat.katp_doc))
                                         AND UPPER (TRIM (d.scd_issued_who)) =
                                             UPPER (TRIM (rec_cat.katp_dep))
                                         AND d.scd_issued_dt = rec_cat.katp_dt
                                         AND d.scd_stop_dt = rec_cat.katp_dte
                                ORDER BY d.scd_id
                                   FETCH FIRST ROWS ONLY;

                                -- развязка между категориями льготы и документами которые определяют эту льготу (если данной развязки небыло)
                                INSERT INTO sc_benefit_docs (scbd_id,
                                                             scbd_scbc,
                                                             scbd_scd)
                                    SELECT 0, l_scbc, l_scd
                                      FROM DUAL
                                     WHERE NOT EXISTS
                                               (SELECT 1
                                                  FROM sc_benefit_docs bbb
                                                 WHERE     bbb.scbd_scbc =
                                                           l_scbc
                                                       AND bbb.scbd_scd =
                                                           l_scd);
                            ------------------------------------------------------------ -
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN                -- если документ не найден
                                    -- создание нового документа определяющего льготу у человека
                                    INSERT INTO sc_document (scd_id,
                                                             scd_sc,
                                                             scd_number,
                                                             scd_issued_dt,
                                                             scd_issued_who,
                                                             scd_stop_dt,
                                                             scd_st,
                                                             scd_src,
                                                             scd_ndt)
                                         VALUES (
                                                    0,
                                                    l_sc,
                                                    UPPER (
                                                        TRIM (
                                                            rec_cat.katp_doc)),
                                                    rec_cat.katp_dt,
                                                    UPPER (
                                                        TRIM (
                                                            rec_cat.katp_dep)),
                                                    rec_cat.katp_dte,
                                                    '1',
                                                    '717',
                                                    rec_cat.nbts_ndt)
                                      RETURNING scd_id
                                           INTO l_scd;

                                    -- создание развязки между категорией льготы и документом определяющим эту категорию
                                    INSERT INTO sc_benefit_docs (scbd_id,
                                                                 scbd_scbc,
                                                                 scbd_scd)
                                         VALUES (0, l_scbc, l_scd);
                            END;

                            -- Adddddddd
                            SetEdarpTrg (rec.raj,
                                         rec.r_ncardp,
                                         'EDARP.B_KATPP',
                                         rec_cat.katp_cd,
                                         'USS_PERSON.SC_DOCUMENT',
                                         l_scd);

                            ---------------------------------------------------------------------------------------------------------------------------------------------

                            -- для каждой категории добавляем типы льгот
                            FOR rec_tp
                                IN (SELECT l.raj,
                                           l.r_ncardp,
                                           l.lg_cdkat,
                                           l.lg_cd,
                                           l.lg_dtb,
                                           l.lg_dte,
                                           t.nbt_id
                                      FROM edarp.b_lgp  l
                                           LEFT JOIN
                                           uss_ndi.v_ndi_benefit_type t
                                               ON t.nbt_code = l.lg_cd
                                     WHERE     717 = 717
                                           AND l.lg_cdkat = rec_cat.katp_cd
                                           AND l.raj = rec.raj
                                           AND l.r_ncardp = rec.r_ncardp)
                            LOOP
                                BEGIN
                                    --init
                                    l_scbt := NULL;

                                    --
                                    IF rec_cat.nbts_ndt IS NULL
                                    THEN
                                        SetEdarpTrgMsg (
                                            rec.raj,
                                            rec.r_ncardp,
                                               'Для кода пільги "'
                                            || rec_tp.lg_cd
                                            || '" - відсутне значення у довіднику "Пільги особи".');
                                        RAISE ExError;
                                    END IF;

                                    -- пошук типу льготи
                                    SELECT v.scbt_id,
                                           v.scbt_start_dt,
                                           v.scbt_stop_dt
                                      INTO l_scbt, l_scbt_dt, l_scbt_dte
                                      FROM sc_benefit_type v
                                     WHERE     v.scbt_sc = l_sc
                                           AND v.scbt_scbc = l_scbc
                                           AND v.scbt_nbt = rec_tp.nbt_id;

                                    -- если дата начала типа более ранняя чем было раньше то меняем на более ранююю
                                    IF COALESCE (
                                           l_scbt_dt,
                                           TO_DATE ('31.12.2099',
                                                    'dd.mm.yyyy')) >
                                       rec_tp.lg_dtb
                                    THEN
                                        UPDATE sc_benefit_type ttt
                                           SET ttt.scbt_start_dt =
                                                   rec_tp.lg_dtb
                                         WHERE ttt.scbt_id = l_scbt;
                                    END IF;

                                    -- если дата типа льготы более поздняя то меняем дату на более позднюю
                                    IF COALESCE (
                                           l_scbt_dte,
                                           TO_DATE ('01.01.1900',
                                                    'dd.mm.yyyy')) <
                                       rec_tp.lg_dte
                                    THEN
                                        UPDATE sc_benefit_type ttt
                                           SET ttt.scbt_start_dt =
                                                   rec_tp.lg_dte
                                         WHERE ttt.scbt_id = l_scbt;
                                    END IF;
                                --------------------------------------------------
                                EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN                      -- если не нашли
                                        -- зоздание нового типа льгот в рамках категории
                                        INSERT INTO sc_benefit_type (
                                                        scbt_id,
                                                        scbt_sc,
                                                        scbt_nbt,
                                                        scbt_start_dt,
                                                        scbt_stop_dt,
                                                        scbt_src,
                                                        scbt_create_dt,
                                                        scbt_modify_dt,
                                                        scbt_st,
                                                        scbt_scbc)
                                             VALUES (0,
                                                     l_sc,
                                                     rec_tp.nbt_id,
                                                     rec_tp.lg_dtb,
                                                     rec_tp.lg_dte,
                                                     '717',
                                                     l_create_dt,
                                                     NULL,
                                                     'A',
                                                     l_scbc)
                                          RETURNING scbt_id
                                               INTO l_scbt;
                                END;
                            END LOOP;
                        END LOOP;
                    ELSE
                        SetEdarpTrgMsg (
                            rec.raj,
                            rec.r_ncardp,
                               'Для '
                            || rec.fam_fio
                            || ' не вказано детальну інформацію про категорію пільговика.');
                    END IF;
                ELSIF l_sc = -2
                THEN
                    SetEdarpTrgMsg (
                        rec.raj,
                        rec.r_ncardp,
                           'Документи '
                        || rec.fam_fio
                        || ' не вказано чи неможливо визначити тип документа.');
                ELSIF l_sc = -1
                THEN
                    SetEdarpTrgMsg (
                        rec.raj,
                        rec.r_ncardp,
                           'За документами '
                        || rec.fam_fio
                        || ' знайдено більше однієї персони в ЄСР.');
                ELSE
                    SetEdarpTrgMsg (
                        rec.raj,
                        rec.r_ncardp,
                        'Помилка визначення персони ' || rec.fam_fio || '.');
                END IF;

                -- COMMIT )
                COMMIT;
            EXCEPTION
                WHEN ExError
                THEN
                    ROLLBACK;
                WHEN OTHERS
                THEN
                    SetEdarpTrgMsg (
                        rec.raj,
                        rec.r_ncardp,
                           'Невизначена помилка:'
                        || cEndOfLine
                        || DBMS_UTILITY.format_error_stack
                        || DBMS_UTILITY.format_error_backtrace);
                    ROLLBACK;
            END;
        END LOOP;
    END;
BEGIN
    NULL;
END;
/