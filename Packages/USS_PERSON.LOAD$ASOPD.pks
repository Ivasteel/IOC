/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$ASOPD
IS
    -- Author  : SHOSTAK
    -- Created : 11.08.2022 8:21:06 PM
    -- Purpose : Завантаження даних з АСОПД

    c_src_asopd               CONSTANT VARCHAR2 (10) := '7';
    c_src_edarp               CONSTANT VARCHAR2 (10) := '39';

    c_ndt_asopd               CONSTANT NUMBER := 10041;
    c_nda_asopd_org           CONSTANT NUMBER := 1099;
    c_nda_asopd_acc_num       CONSTANT NUMBER := 1100;
    c_nda_asopd_npt_code      CONSTANT NUMBER := 1101;
    c_nda_asopd_start_dt      CONSTANT NUMBER := 1102;
    c_nda_asopd_stop_dt       CONSTANT NUMBER := 1103;
    c_nda_asopd_scy_group     CONSTANT NUMBER := 1104;
    c_nda_asopd_scy_reason    CONSTANT NUMBER := 2193;
    c_nda_asopd_decision_dt   CONSTANT NUMBER := 1105;
    c_nda_asopd_till_dt       CONSTANT NUMBER := 1106;
    c_nda_asopd_document      CONSTANT NUMBER := 1107;
    c_nda_asopd_rp_ln         CONSTANT NUMBER := 1108;
    c_nda_asopd_rp_fn         CONSTANT NUMBER := 1109;
    c_nda_asopd_rp_mn         CONSTANT NUMBER := 1110;
    c_nda_asopd_rp_bdt        CONSTANT NUMBER := 1111;
    c_nda_asopd_rp_n          CONSTANT NUMBER := 2263;

    PROCEDURE save_asopd_case_info (
        p_district_id             VARCHAR2,
        p_decl_num                VARCHAR2,
        p_ls_kfn                  VARCHAR2,
        p_d_from                  DATE,
        p_d_till                  DATE,
        p_dis_group               VARCHAR2,
        p_dis_reason              VARCHAR2,
        p_dis_begin               DATE,
        p_dis_start               DATE,
        p_dis_end                 DATE,
        p_n_id                    VARCHAR2,
        p_passport                VARCHAR2,
        p_surname                 VARCHAR2,
        p_name                    VARCHAR2,
        p_patronymic              VARCHAR2,
        p_bdate                   DATE,
        p_gender                  VARCHAR2,
        p_citizenship             VARCHAR2,
        p_fam_relat               VARCHAR2,
        --Інформація про отримувача допомоги
        --(заповнбється для справ по інвалідності)
        p_recipient_n_id          VARCHAR2 DEFAULT NULL,
        p_recipient_passport      VARCHAR2 DEFAULT NULL,
        p_recipient_surname       VARCHAR2 DEFAULT NULL,
        p_recipient_name          VARCHAR2 DEFAULT NULL,
        p_recipient_patronymic    VARCHAR2 DEFAULT NULL,
        p_recipient_bdate         DATE DEFAULT NULL,
        p_recipient_gender        VARCHAR2 DEFAULT NULL,
        p_recipient_citizenship   VARCHAR2 DEFAULT NULL,
        p_recipient_fam_relat     VARCHAR2 DEFAULT NULL,
        --Інорфмація про пільги з ЄДАРП
        p_prv_doc                 VARCHAR2 DEFAULT NULL,
        p_prv_begin               DATE DEFAULT NULL,
        p_prv_end                 DATE DEFAULT NULL,
        p_prv_issuer              VARCHAR2 DEFAULT NULL,
        --інформація про файл з якого завантажено дані
        p_file_id                 NUMBER DEFAULT NULL,
        p_file_name               VARCHAR2 DEFAULT NULL);
END load$asopd;
/


GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.LOAD$ASOPD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$ASOPD
IS
    ------------------------------------------------------
    --  Збереження інформації зі справи АСПОД/ЄДАРП
    ------------------------------------------------------
    PROCEDURE save_asopd_case_info (
        p_district_id             VARCHAR2,
        p_decl_num                VARCHAR2,
        p_ls_kfn                  VARCHAR2,
        p_d_from                  DATE,
        p_d_till                  DATE,
        p_dis_group               VARCHAR2,
        p_dis_reason              VARCHAR2,
        p_dis_begin               DATE,
        p_dis_start               DATE,
        p_dis_end                 DATE,
        p_n_id                    VARCHAR2,
        p_passport                VARCHAR2,
        p_surname                 VARCHAR2,
        p_name                    VARCHAR2,
        p_patronymic              VARCHAR2,
        p_bdate                   DATE,
        p_gender                  VARCHAR2,
        p_citizenship             VARCHAR2,
        p_fam_relat               VARCHAR2,
        --Інформація про отримувача допомоги
        --(заповнбється для справ по інвалідності)
        p_recipient_n_id          VARCHAR2 DEFAULT NULL,
        p_recipient_passport      VARCHAR2 DEFAULT NULL,
        p_recipient_surname       VARCHAR2 DEFAULT NULL,
        p_recipient_name          VARCHAR2 DEFAULT NULL,
        p_recipient_patronymic    VARCHAR2 DEFAULT NULL,
        p_recipient_bdate         DATE DEFAULT NULL,
        p_recipient_gender        VARCHAR2 DEFAULT NULL,
        p_recipient_citizenship   VARCHAR2 DEFAULT NULL,
        p_recipient_fam_relat     VARCHAR2 DEFAULT NULL,
        --Інорфмація про пільги з ЄДАРП
        p_prv_doc                 VARCHAR2 DEFAULT NULL,
        p_prv_begin               DATE DEFAULT NULL,
        p_prv_end                 DATE DEFAULT NULL,
        p_prv_issuer              VARCHAR2 DEFAULT NULL,
        --інформація про файл з якого завантажено дані
        p_file_id                 NUMBER DEFAULT NULL,
        p_file_name               VARCHAR2 DEFAULT NULL)
    IS
        l_sc_id        socialcard.sc_id%TYPE;
        l_scd_id       sc_document.scd_id%TYPE;
        l_dh_id        sc_document.scd_dh%TYPE;
        l_attrs        api$socialcard.t_doc_attrs;
        l_ndt_id       NUMBER;
        l_scy_group    VARCHAR2 (10);
        l_scy_reason   VARCHAR2 (4000);

        FUNCTION get_sc (p_numident   IN VARCHAR2,
                         p_doc_num    IN VARCHAR2,
                         p_ln         IN VARCHAR2,
                         p_fn         IN VARCHAR2,
                         p_mn         IN VARCHAR2,
                         p_gender     IN VARCHAR2,
                         p_birthday   IN DATE,
                         p_src_dt     IN DATE)
            RETURN NUMBER
        IS
            l_sc_id       NUMBER;
            l_ndt_id      NUMBER;
            l_inn         VARCHAR2 (10);
            l_doc_ser     VARCHAR2 (4); --серія свідоцтва про народження може мати більше двух символів
            l_doc_num     VARCHAR2 (50);
            l_sc_unique   uss_person.socialcard.sc_unique%TYPE;
            l_age         NUMBER;
        BEGIN
            l_inn :=
                CASE
                    WHEN REGEXP_LIKE (REPLACE (p_numident, ' ', ''),
                                      '^[0-9]{10}$')
                    THEN
                        REPLACE (p_numident, ' ', '')
                END;

            l_doc_num := UPPER (REPLACE (p_doc_num, ' ', ''));

            l_age :=
                FLOOR (
                    MONTHS_BETWEEN (NVL (p_src_dt, SYSDATE), p_birthday) / 12);

            IF REGEXP_LIKE (l_doc_num, '^[0-9]{9}$') AND l_age >= 14
            THEN
                l_ndt_id := 7;
            ELSIF    REGEXP_LIKE (
                         l_doc_num,
                         '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[0-9]{6}[/]{1}[0-9]{2}[-]{1}[0-9]{4,5}$')
                  OR REGEXP_LIKE (
                         l_doc_num,
                         '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[0-9]{8}[-]{1}[0-9]{3}$')
                  OR REGEXP_LIKE (
                         l_doc_num,
                         '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[0-9]{6}[/]{1}[0-9]{6}$')
            THEN
                l_ndt_id := 8;
            ELSIF     REGEXP_LIKE (
                          SUBSTR (l_doc_num, LENGTH (l_doc_num) - 5, 6),
                          '^[0-9]{6}$')
                  AND l_age <= 16
            THEN
                l_ndt_id := 37;
            ELSIF REGEXP_LIKE (l_doc_num,
                               '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[-]{0,1}[0-9]{6}$')
            THEN
                l_ndt_id := 6;
            ELSIF REGEXP_LIKE (l_doc_num, '^[0-9]{9}$')
            THEN
                l_ndt_id := 7;
            END IF;

            IF l_ndt_id = 6
            THEN
                l_doc_ser :=
                    TRANSLATE (SUBSTR (l_doc_num, 1, LENGTH (l_doc_num) - 6),
                               'ABCIETOPHKXM',
                               'АВСІЕТОРНКХМ');
                l_doc_num := SUBSTR (l_doc_num, LENGTH (l_doc_num) - 5, 6);
            ELSIF l_ndt_id = 37
            THEN
                l_doc_ser := SUBSTR (l_doc_num, 1, LENGTH (l_doc_num) - 6);
                l_doc_num := SUBSTR (l_doc_num, LENGTH (l_doc_num) - 5, 6);
            ELSIF l_ndt_id = 8
            THEN
                l_doc_ser := SUBSTR (l_doc_num, 1, 2);
                l_doc_num := SUBSTR (l_doc_num, 3);
            END IF;

            l_doc_ser := TRIM ('-' FROM l_doc_ser);

            IF l_ndt_id IS NULL
            THEN
                l_doc_ser := NULL;
                l_doc_num := NULL;
            END IF;

            IF l_inn IS NULL AND l_ndt_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'РНКОПП не відповідає формату та не вдалось визначити тип документу');
            END IF;

            l_sc_id :=
                uss_person.load$socialcard.load_sc (
                    p_fn            => Clear_Name (p_fn),
                    p_ln            => Clear_Name (p_ln),
                    p_mn            => Clear_Name (p_mn),
                    p_gender        =>
                        CASE p_gender
                            WHEN '1' THEN 'M'
                            WHEN '2' THEN 'F'
                            ELSE 'V'
                        END,
                    p_nationality   => '1',
                    p_src_dt        => p_src_dt,
                    p_birth_dt      => p_birthday,
                    p_inn_num       => l_inn,
                    p_inn_ndt       => 5,
                    p_doc_ser       => l_doc_ser,
                    p_doc_num       => l_doc_num,
                    p_doc_ndt       => l_ndt_id,
                    p_src           => '7',
                    p_sc_unique     => l_sc_unique,
                    p_sc            => l_sc_id);

            IF COALESCE (l_sc_id, -1) <= 0
            THEN
                raise_application_error (
                    -20000,
                    'Не вдалось однозначно визначити особу');
            END IF;

            RETURN l_sc_id;
        END;
    BEGIN
        --отримання соцкартки персони
        l_sc_id :=
            get_sc (
                p_numident   => p_n_id,
                p_doc_num    => p_passport,
                p_ln         => p_surname,
                p_fn         => p_name,
                p_mn         => p_patronymic,
                p_gender     => p_gender,
                p_birthday   => p_bdate,
                p_src_dt     => COALESCE (p_dis_start, p_prv_begin, p_d_from));

        --якщо картка отримана - збереження документів в залежності від КФН
        IF l_sc_id IS NOT NULL
        THEN
            --група інвалідності
            IF     COALESCE (p_ls_kfn, '0') NOT IN ('35', 36)
               AND p_dis_group IS NOT NULL
            THEN
                --Перекодуємо атрибути
                --група інвалідності
                l_scy_group :=
                    uss_ndi.tools.decode_dict (
                        p_nddc_tp         => 'SCY_GROUP',
                        p_nddc_src        => 'ASOPD',
                        p_nddc_dest       => 'USS',
                        p_nddc_code_src   => p_dis_group);

                --причина інвалідності
                SELECT MAX (r.dic_name)
                  INTO l_scy_reason
                  FROM uss_ndi.v_ddn_asopd_scy_reason r
                 WHERE r.dic_value = p_dis_reason;

                --Формуємо атрибути документа
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_org,
                                             p_val_str   => p_district_id);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_acc_num,
                                             p_val_str   => p_decl_num);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_npt_code,
                                             p_val_str   => p_ls_kfn);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_start_dt,
                                             p_val_dt   => p_d_from);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_stop_dt,
                                             p_val_dt   => p_d_till);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_scy_group,
                                             p_val_str   => l_scy_group);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_scy_reason,
                                             p_val_str   => l_scy_reason);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_decision_dt,
                                             p_val_dt   => p_dis_start);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_till_dt,
                                             p_val_dt   => p_dis_end);
                api$socialcard.add_doc_attr (
                    l_attrs,
                    c_nda_asopd_document,
                    p_val_str   => p_recipient_passport);
                api$socialcard.add_doc_attr (
                    l_attrs,
                    c_nda_asopd_rp_ln,
                    p_val_str   => p_recipient_surname);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_rp_fn,
                                             p_val_str   => p_recipient_name);
                api$socialcard.add_doc_attr (
                    l_attrs,
                    c_nda_asopd_rp_mn,
                    p_val_str   => p_recipient_patronymic);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_rp_bdt,
                                             p_val_dt   => p_recipient_bdate);
                api$socialcard.add_doc_attr (l_attrs,
                                             c_nda_asopd_rp_n,
                                             p_val_str   => p_recipient_n_id);

                --Зберігаємо документ
                api$socialcard.save_document (
                    p_sc_id       => l_sc_id,
                    p_ndt_id      => c_ndt_asopd,
                    p_doc_attrs   => l_attrs,
                    p_src_id      => c_src_asopd,
                    p_src_code    => 'ASOPD',
                    p_scd_note    =>
                        p_file_name || '(' || TO_CHAR (p_file_id) || ')',
                    p_scd_id      => l_scd_id,
                    p_scd_dh      => l_dh_id);

                --Зберігаємо інформацію про інвалідність до соцкартки
                api$feature.set_sc_disability (p_scy_sc        => l_sc_id,
                                               p_scy_scd       => l_scd_id,
                                               p_scy_scd_ndt   => c_ndt_asopd,
                                               p_scy_scd_dh    => l_dh_id);
            END IF;

            --збереження соціальної категорії: 35 - багатодітна сім'я; 36 – дитина з багатодітної; 507 - отримувач допомоги малозабезпеченим сім’ям; 537 - багатодітна сім’я; 589 - одинока мати або батько
            IF p_ls_kfn IN ('35',
                            '36',
                            '507',
                            '537',
                            '589')
            THEN
                --на всяк випадок "обнулення" перемінних
                l_scd_id := NULL;
                l_dh_id := NULL;
                l_attrs := NULL;

                --визначення документу в залежності від КФН
                l_ndt_id :=
                    (CASE p_ls_kfn
                         WHEN '35' THEN 10108
                         WHEN '36' THEN 10107
                         WHEN '507' THEN 10106
                         WHEN '537' THEN 10104
                         ELSE 10105
                     END);

                --Формуємо атрибути документа
                api$socialcard.add_doc_attr (
                    l_attrs,
                    (CASE l_ndt_id
                         WHEN 10108 THEN 2273
                         WHEN 10107 THEN 2281
                         WHEN 10106 THEN 2267
                         WHEN 10104 THEN 2270
                         ELSE 2264
                     END),
                    p_val_str   =>
                        (CASE
                             WHEN l_ndt_id IN (10107, 10108)
                             THEN
                                 COALESCE (
                                     p_prv_doc,
                                     (p_district_id || ' - ' || p_decl_num))
                             ELSE
                                 (p_district_id || ' - ' || p_decl_num)
                         END));                              --Номер документа
                api$socialcard.add_doc_attr (
                    l_attrs,
                    (CASE l_ndt_id
                         WHEN 10107 THEN 2287
                         WHEN 10108 THEN 2279
                         WHEN 10106 THEN 2268
                         WHEN 10104 THEN 2271
                         ELSE 2265
                     END),
                    p_val_dt   => p_d_from);          --Допомога з/Пільговик з
                api$socialcard.add_doc_attr (
                    l_attrs,
                    (CASE l_ndt_id
                         WHEN 10107 THEN 2288
                         WHEN 10108 THEN 2280
                         WHEN 10106 THEN 2269
                         WHEN 10104 THEN 2272
                         ELSE 2266
                     END),
                    p_val_dt   => p_d_till);        --Допомога по/Пільговик по

                --додаткові атрибути для документів пільг ЕДАРП
                IF l_ndt_id IN (10107, 10108)
                THEN
                    api$socialcard.add_doc_attr (
                        l_attrs,
                        (CASE l_ndt_id WHEN 10107 THEN 2282 ELSE 2274 END),
                        p_val_dt   => p_prv_begin);    --Дата видачі документа
                    api$socialcard.add_doc_attr (
                        l_attrs,
                        (CASE l_ndt_id WHEN 10107 THEN 2283 ELSE 2275 END),
                        p_val_dt   => p_prv_end);        --Документ дійсний до
                    api$socialcard.add_doc_attr (
                        l_attrs,
                        (CASE l_ndt_id WHEN 10107 THEN 2284 ELSE 2276 END),
                        p_val_str   => p_prv_issuer);             --Ким видано
                    api$socialcard.add_doc_attr (
                        l_attrs,
                        (CASE l_ndt_id WHEN 10107 THEN 2285 ELSE 2277 END),
                        p_val_str   => p_district_id);            --Код району
                    api$socialcard.add_doc_attr (
                        l_attrs,
                        (CASE l_ndt_id WHEN 10107 THEN 2286 ELSE 2278 END),
                        p_val_str   => p_decl_num);  --Номер картки пільговика
                END IF;

                --Зберігаємо документ
                api$socialcard.save_document (
                    p_sc_id       => l_sc_id,
                    p_ndt_id      => l_ndt_id,
                    p_doc_attrs   => l_attrs,
                    p_src_id      =>
                        (CASE
                             WHEN p_ls_kfn IN ('35', '36') THEN c_src_edarp
                             ELSE c_src_asopd
                         END),
                    p_src_code    =>
                        (CASE
                             WHEN p_ls_kfn IN ('35', '36') THEN 'EDARP'
                             ELSE 'ASOPD'
                         END),
                    p_scd_note    =>
                        p_file_name || '(' || TO_CHAR (p_file_id) || ')',
                    p_scd_id      => l_scd_id,
                    p_scd_dh      => l_dh_id);

                --Збереження інформації по соціальній категорії
                api$feature.set_sc_feature (p_scs_sc        => l_sc_id,
                                            p_scs_scd       => l_scd_id,
                                            p_scs_scd_ndt   => l_ndt_id,
                                            p_scs_scd_dh    => l_dh_id);
            END IF;
        END IF;
    END;
END load$asopd;
/