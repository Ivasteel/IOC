/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.LOAD$ASOPD
IS
    -- Author  : JSHPAK
    -- Created : 16.12.2021 15:16:28
    -- Purpose :
    TYPE cache_op_info_type IS TABLE OF VARCHAR2 (10)
        INDEX BY VARCHAR2 (40);

    g_op_info   cache_op_info_type;

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER;

    PROCEDURE SetKoat2StreetbyLS (p_lfd_lfd NUMBER);

    PROCEDURE Load_LS (p_lfd_lfd NUMBER, p_migration_force NUMBER DEFAULT 0);

    PROCEDURE Load_Decision (p_lfd_lfd       NUMBER,
                             p_ls_lfdp       NUMBER,
                             p_pc            NUMBER,
                             p_sc            NUMBER,
                             p_pa            NUMBER,
                             p_ls_nls        VARCHAR2,
                             p_ls_org        VARCHAR2,
                             p_ls_spos       VARCHAR2,
                             p_ls_indots     VARCHAR2,
                             p_ls_adrul      VARCHAR2,
                             p_ls_adrdom     VARCHAR2,
                             p_ls_adrkorp    VARCHAR2,
                             p_ls_adrkv      VARCHAR2,
                             p_nptc_nst      NUMBER,
                             p_ls_base_org   VARCHAR2,
                             p_sc_scc        NUMBER,
                             p_wu            NUMBER,
                             p_wu_txt        VARCHAR2,
                             p_ls_npt_id     NUMBER);

    PROCEDURE Load_Deduction (p_lfd_lfd       NUMBER,
                              p_sc            NUMBER,
                              p_pc            NUMBER,
                              p_ap            NUMBER,
                              p_pa            NUMBER,
                              p_pd            NUMBER,
                              p_ls_nls        VARCHAR2,
                              p_ls_org        VARCHAR2,
                              p_ls_base_org   VARCHAR2,
                              p_ls_npt_id     NUMBER);

    PROCEDURE Load_Accrual (p_lfd_lfd     NUMBER,
                            p_pc          NUMBER,
                            p_pd          NUMBER,
                            p_ls_nls      VARCHAR2,
                            p_ls_org      VARCHAR2,
                            p_ls_npt_id   NUMBER);

    PROCEDURE Load_Payroll_Bank_Imp (p_lfd_id NUMBER);

    PROCEDURE setImpPrNumByNonpay (                               -- IC #84362
        i_lfd_lfd   IN USS_EXCH.V_LS_NAC_DATA.lfd_lfd%TYPE,
        i_ls_nls    IN USS_EXCH.V_LS_NAC_DATA.ls_nls%TYPE);

    FUNCTION getAccessByKFN (                                     -- IC #84821
                             i_kfn IN VARCHAR2, i_org IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION getExcByKFN (                                       -- IC #102940
                          i_kfn   IN VARCHAR2,
                          i_exc   IN VARCHAR2,
                          i_org   IN VARCHAR2 := NULL)
        RETURN NUMBER;

    PROCEDURE Load_INCOME (p_lfd_lfd           NUMBER,
                           p_migration_force   NUMBER DEFAULT 0);

    FUNCTION getOrgbyLFD (p_lfd_lfd NUMBER)
        RETURN NUMBER;

    PROCEDURE Load_LsPos (p_lfd_lfd           NUMBER,
                          p_migration_force   NUMBER DEFAULT 0);

    PROCEDURE Load_KlDUch (p_lfd_lfd           NUMBER,
                           p_migration_force   NUMBER DEFAULT 0);

    PROCEDURE Load_Street (p_lfd_lfd NUMBER);

    -- IC #103369
    -- Зробити процедуру для аналізу наявності діючих рішень по допомогам по особі при міграції
    FUNCTION getLastDatePayment (p_sc_id NUMBER)
        RETURN DATE;
END Load$ASOPD;
/


GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO USS_EXCH
/

GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.LOAD$ASOPD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.LOAD$ASOPD
IS
    -- Application variables
    -- Версия на 03.11.2022 15:30
    lBuffer                     BINARY_INTEGER := 16383;
    cEndOfLine                  CHAR (2) := CHR (13) || CHR (10);
    vCharBuffer                 VARCHAR2 (32767);

    ex_error_Clear_LS           EXCEPTION;
    ex_error_acd_period         EXCEPTION;
    ex_error_stage_not1         EXCEPTION;
    ex_error_sc_2               EXCEPTION;
    ex_error_sc_1               EXCEPTION;
    ex_error_sc_else            EXCEPTION;
    ex_error_igd_doc_decision   EXCEPTION;
    ex_error_igd_2sc_decision   EXCEPTION;
    ex_error_igd_decision       EXCEPTION;
    ex_error_op_accrual         EXCEPTION;
    ex_error_npt_accrual        EXCEPTION;
    ex_error_klovud_deduction   EXCEPTION;
    ex_error_kud_deduction      EXCEPTION;
    ex_error_nf_bank            EXCEPTION;
    ex_error_nf_npo             EXCEPTION;
    ex_error_nf_ns              EXCEPTION;
    ex_error_create_pd          EXCEPTION;

    ex_error_84235_part_1       EXCEPTION;
    ex_error_84235_part_2       EXCEPTION;
    ex_error_85513              EXCEPTION;
    ex_error_ap_isnotexist      EXCEPTION;
    ex_error_no_gender          EXCEPTION;                           -- #86382
    ex_error_no_npo_index       EXCEPTION;
    ex_error_no_str_code        EXCEPTION;
    ex_error_no_org_code        EXCEPTION;
    ex_error_90903              EXCEPTION;
    ex_error_91221              EXCEPTION;
    ex_error_102940             EXCEPTION; -- IC #102940 Якщо в масиві ПЕР є такі коди КФН (у вкладенні), то видавати помилку по цьому ОР - це помилка

    l_error_prm                 VARCHAR2 (2000);
    l_load_enable               CHAR (1) := TOOLS.GGP ('ASOPD_LOAD_ENABLED');

    tt_date                     datearray := datearray ();

    PROCEDURE SetAction (p_message VARCHAR2)
    IS
    BEGIN
        DBMS_APPLICATION_INFO.set_action (action_name => p_message);
    END;

    -- Призначення: ;
    -- Параметри:   ;
    PROCEDURE WriteLineToBlob (p_line   IN            VARCHAR2,
                               p_blob   IN OUT NOCOPY BLOB,
                               p_buff   IN            BOOLEAN := FALSE)
    IS
        vCharData     VARCHAR2 (32767);
        vRawData      RAW (32767);
        vDataLength   BINARY_INTEGER := 32767;
    BEGIN
        vCharData := TRIM (p_line) || cEndOfLine;

        -- Buffer --
        IF (NOT p_buff) OR (LENGTH (vCharData) > lBuffer)
        THEN
            vRawData := UTL_RAW.cast_to_raw (vCharData);
            vDataLength := LENGTH (vRawData) / 2;
            DBMS_LOB.writeappend (p_blob, vDataLength, vRawData);
        ELSE
            IF LENGTH (vCharBuffer || vCharData) > lBuffer
            THEN
                vRawData := UTL_RAW.cast_to_raw (vCharBuffer);
                vDataLength := LENGTH (vRawData) / 2;
                DBMS_LOB.writeappend (p_blob, vDataLength, vRawData);
                vCharBuffer := vCharData;
            ELSE
                vCharBuffer := vCharBuffer || vCharData;
            END IF;
        END IF;
    END;

    -- установка улиц
    PROCEDURE SetKoat2StreetbyLS (p_lfd_lfd NUMBER)
    IS
        l_ls_raj   NUMBER;
    BEGIN
        -- расписание улиц по городам
        BEGIN
            FOR rec
                IN (SELECT *
                      FROM (SELECT DISTINCT
                                   ls.lfd_lfd,
                                   ls.ls_adrul,
                                   ls.ls_raj,
                                   ls.ls_indots,
                                   u.klul_name,
                                   s.ns_id,
                                   s.ns_kaot,
                                   h.kaot_id,
                                   h.kaot_name,
                                   COUNT (DISTINCT npo.npo_kaot)
                                       OVER (PARTITION BY ls_adrul, ls_raj)    AS cnt_by_ind
                              FROM uss_exch.v_ls_data  ls
                                   JOIN uss_exch.v_b_klul u
                                       ON     ls.ls_adrul = u.klul_codeul
                                          AND ls.ls_raj = u.klul_codern
                                   JOIN uss_ndi.v_ndi_post_office npo
                                       ON npo.npo_index = ls.ls_indots
                                   JOIN uss_ndi.v_ndi_katottg h
                                       ON h.kaot_id = npo.npo_kaot
                                   JOIN uss_ndi.v_ndi_street s
                                       ON     s.ns_code = u.klul_codeul
                                          AND s.ns_org =
                                              LPAD (
                                                  LPAD (u.klul_codern,
                                                        4,
                                                        '0'),
                                                  5,
                                                  '5')
                             WHERE 1 = 1 AND ls.lfd_lfd = p_lfd_lfd) t
                     WHERE     t.ns_kaot IS NULL
                           AND t.cnt_by_ind = 1
                           AND klul_name NOT LIKE '% С.%')
            LOOP
                BEGIN
                    UPDATE uss_ndi.ndi_street ddd
                       SET ddd.ns_kaot = rec.kaot_id
                     WHERE ddd.ns_id = rec.ns_id;

                    IF SQL%ROWCOUNT <> 1
                    THEN
                        raise_application_error (-20000, 'Error1');
                    END IF;
                END;
            END LOOP;
        END;

        -- расписание улиц по селам
        BEGIN
            FOR rec
                IN (SELECT DISTINCT ls.lfd_lfd,
                                    ls.ls_adrul,
                                    ls.ls_raj,
                                    ls.ls_indots,
                                    u.klul_name,
                                    h.kaot_id,
                                    h.kaot_name,
                                    s.ns_id,
                                    s.ns_kaot
                      FROM uss_exch.v_ls_data  ls
                           JOIN uss_exch.v_b_klul u
                               ON     ls.ls_adrul = u.klul_codeul
                                  AND ls.ls_raj = u.klul_codern
                           JOIN uss_ndi.v_ndi_post_office npo
                               ON npo.npo_index = ls.ls_indots
                           JOIN uss_ndi.v_ndi_katottg h
                               ON h.kaot_id = npo.npo_kaot
                           LEFT JOIN uss_ndi.v_ndi_street s
                               ON     s.ns_code = u.klul_codeul
                                  AND s.ns_org =
                                      LPAD (LPAD (u.klul_codern, 4, '0'),
                                            5,
                                            '5')
                     WHERE     1 = 1
                           AND u.klul_name LIKE
                                   UPPER ('%' || '.' || h.kaot_name)
                           AND ls.lfd_lfd = p_lfd_lfd
                           --and ls_adrul = '13879'
                           AND COALESCE (s.ns_kaot, -1) <>
                               COALESCE (h.kaot_id, -1))
            LOOP
                BEGIN
                    IF rec.ns_kaot IS NULL
                    THEN
                        UPDATE uss_ndi.ndi_street ddd
                           SET ddd.ns_kaot = rec.kaot_id
                         WHERE ddd.ns_id = rec.ns_id;

                        IF SQL%ROWCOUNT <> 1
                        THEN
                            raise_application_error (-20000, 'Error1');
                        END IF;
                    ELSIF     rec.ns_kaot IS NOT NULL
                          AND rec.ns_kaot <> rec.kaot_id
                    THEN
                        INSERT INTO uss_ndi.ndi_street (ns_id,
                                                        ns_code,
                                                        ns_name,
                                                        ns_kaot,
                                                        ns_nsrt,
                                                        history_status,
                                                        ns_org)
                            SELECT NULL,
                                   rec.ls_adrul,
                                   rec.klul_name,
                                   rec.kaot_id,
                                   NULL,
                                   'A',
                                   LPAD (LPAD (rec.ls_raj, 4, '0'), 5, '5')
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT 1
                                          FROM uss_ndi.v_ndi_street str
                                         WHERE     str.ns_code = rec.ls_adrul
                                               AND str.ns_org =
                                                   LPAD (
                                                       LPAD (rec.ls_raj,
                                                             4,
                                                             '0'),
                                                       5,
                                                       '5')
                                               AND str.ns_kaot = rec.kaot_id);
                    END IF;
                END;
            END LOOP;
        END;

        -- расписание улиц по соседним селам в рамках района
        BEGIN
            FOR rec
                IN (SELECT DISTINCT ls.lfd_lfd,
                                    ls.ls_adrul,
                                    ls.ls_raj,
                                    ls.ls_indots,
                                    u.klul_name,
                                    hh.kaot_id,
                                    hh.kaot_name,
                                    s.ns_id,
                                    s.ns_kaot
                      FROM uss_exch.v_ls_data  ls
                           JOIN uss_exch.v_b_klul u
                               ON     ls.ls_adrul = u.klul_codeul
                                  AND ls.ls_raj = u.klul_codern
                           JOIN uss_ndi.v_ndi_post_office npo
                               ON npo.npo_index = ls.ls_indots
                           JOIN uss_ndi.v_ndi_katottg h
                               ON h.kaot_id = npo.npo_kaot
                           JOIN uss_ndi.v_ndi_katottg hh
                               ON hh.kaot_kaot_l3 = h.kaot_kaot_l3
                           LEFT JOIN uss_ndi.v_ndi_street s
                               ON     s.ns_code = u.klul_codeul
                                  AND s.ns_org =
                                      LPAD (LPAD (u.klul_codern, 4, '0'),
                                            5,
                                            '5')
                     WHERE     1 = 1
                           AND u.klul_name LIKE
                                   UPPER ('%' || '.' || hh.kaot_name)
                           AND ls.lfd_lfd = p_lfd_lfd
                           --and ls_adrul = '13879'
                           --and ls_indots = '11590'
                           AND COALESCE (s.ns_kaot, -1) <>
                               COALESCE (hh.kaot_id, -1))
            LOOP
                BEGIN
                    IF rec.ns_kaot IS NULL
                    THEN
                        UPDATE uss_ndi.ndi_street ddd
                           SET ddd.ns_kaot = rec.kaot_id
                         WHERE ddd.ns_id = rec.ns_id;

                        IF SQL%ROWCOUNT <> 1
                        THEN
                            raise_application_error (-20000, 'Error1');
                        END IF;
                    ELSIF     rec.ns_kaot IS NOT NULL
                          AND rec.ns_kaot <> rec.kaot_id
                    THEN
                        INSERT INTO uss_ndi.ndi_street (ns_id,
                                                        ns_code,
                                                        ns_name,
                                                        ns_kaot,
                                                        ns_nsrt,
                                                        history_status,
                                                        ns_org)
                            SELECT NULL,
                                   rec.ls_adrul,
                                   rec.klul_name,
                                   rec.kaot_id,
                                   NULL,
                                   'A',
                                   LPAD (LPAD (rec.ls_raj, 4, '0'), 5, '5')
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT 1
                                          FROM uss_ndi.v_ndi_street str
                                         WHERE     str.ns_code = rec.ls_adrul
                                               AND str.ns_org =
                                                   LPAD (
                                                       LPAD (rec.ls_raj,
                                                             4,
                                                             '0'),
                                                       5,
                                                       '5')
                                               AND str.ns_kaot = rec.kaot_id);
                    END IF;
                END;
            END LOOP;
        END;

        -- расписание улиц по соседним селам в рамках района ver 2declare
        BEGIN
            SELECT DISTINCT ls.ls_raj
              INTO l_ls_raj
              FROM uss_exch.v_ls_data ls
             WHERE ls.lfd_lfd = p_lfd_lfd;

            FOR rec3
                IN (SELECT DISTINCT h.kaot_kaot_l3
                      FROM uss_ndi.v_ndi_street  s
                           JOIN uss_ndi.v_ndi_katottg h
                               ON h.kaot_id = s.ns_kaot
                     WHERE s.ns_org = LPAD (LPAD (l_ls_raj, 4, '0'), 5, '5'))
            LOOP
                FOR rec
                    IN (SELECT DISTINCT u.klul_name,
                                        hh.kaot_id,
                                        hh.kaot_name,
                                        s.ns_id,
                                        s.ns_kaot
                          FROM uss_exch.v_b_klul  u
                               JOIN uss_ndi.v_ndi_katottg hh
                                   ON     hh.kaot_kaot_l3 = rec3.kaot_kaot_l3
                                      AND u.klul_name LIKE
                                              UPPER (
                                                  '%' || '.' || hh.kaot_name)
                               JOIN uss_ndi.v_ndi_street s
                                   ON     s.ns_code = u.klul_codeul
                                      AND s.ns_org =
                                          LPAD (LPAD (u.klul_codern, 4, '0'),
                                                5,
                                                '5')
                         WHERE     1 = 1
                               AND u.klul_codern = l_ls_raj
                               AND s.ns_kaot IS NULL
                               AND klul_name LIKE '% С.%'
                               AND COALESCE (s.ns_kaot, -1) <>
                                   COALESCE (hh.kaot_id, -1))
                LOOP
                    BEGIN
                        UPDATE uss_ndi.ndi_street ddd
                           SET ddd.ns_kaot = rec.kaot_id
                         WHERE ddd.ns_id = rec.ns_id;

                        IF SQL%ROWCOUNT <> 1
                        THEN
                            raise_application_error (-20000, 'Error1');
                        END IF;
                    END;
                END LOOP;
            END LOOP;
        END;
    END;

    PROCEDURE SetNlsLog (p_lfdp NUMBER, p_trg NUMBER, p_code VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM uss_exch.v_ls2uss u
              WHERE u.ldr_lfdp = p_lfdp AND u.ldr_trg = -1;

        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
             VALUES (p_lfdp, p_trg, SUBSTR (p_code, 1, 500));

        COMMIT;
    END;


    -- переудаление записей исходя из обращений
    PROCEDURE Clear_LS (p_pa NUMBER, p_ls_nls VARCHAR2, p_base_org VARCHAR2)
    IS
        CHILD_RECORD_FOUND   EXCEPTION;
        PRAGMA EXCEPTION_INIT (CHILD_RECORD_FOUND, -2292);
    BEGIN
        l_error_prm := NULL;

        FOR rec
            IN (SELECT --+ ordered
                       ap.ap_id AS del_ap, a.ldr_lfdp AS del_src
                  FROM pc_account  pa
                       JOIN appeal ap
                       JOIN ap_service aps
                           ON aps.aps_ap = ap.ap_id
                           ON     ap.ap_num = p_base_org || '_' || p_ls_nls
                              AND aps.aps_nst = pa.pa_nst
                       JOIN uss_exch.v_ls2uss a
                           ON     ap.ap_id = a.ldr_trg
                              AND a.ldr_code = 'USS_ESR.APPEAL'
                 WHERE pa.pa_id = p_pa)
        LOOP
            IF rec.del_ap IS NOT NULL
            THEN
                -- это для ручной очистки всего района, для нулевой перемиграции используется.
                -- update pc_account pa set pa.pa_stage = '1'
                -- where pa_pc in (select pd_pc from uss_esr.pc_decision where pd_ap  = rec.del_ap)
                --   and pa.pa_nst in (select aps_nst from uss_esr.ap_service where aps_ap  = rec.del_ap);
                l_error_prm :=
                    'Clear ap_log для apl_ap  = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ap_log
                      WHERE apl_ap = rec.del_ap;

                l_error_prm :=
                       'Clear apr_income для apri_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_income
                      WHERE apri_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_land_plot для aprt_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_land_plot
                      WHERE aprt_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_living_quarters для aprl_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_living_quarters
                      WHERE aprl_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_other_income для apro_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_other_income
                      WHERE apro_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_spending для aprs_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_spending
                      WHERE aprs_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_vehicle для aprv_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_vehicle
                      WHERE aprv_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear apr_person для aprp_apr in (select apr_id from uss_esr.ap_declaration where apr_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.apr_person
                      WHERE aprp_apr IN (SELECT apr_id
                                           FROM uss_esr.ap_declaration
                                          WHERE apr_ap = rec.del_ap);

                l_error_prm :=
                       'Clear ap_declaration для apr_ap  = '
                    || rec.del_ap
                    || ';';

                DELETE FROM uss_esr.ap_declaration
                      WHERE apr_ap = rec.del_ap;

                l_error_prm :=
                    'Clear ap_payment для apm_ap  = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ap_payment
                      WHERE apm_ap = rec.del_ap;

                l_error_prm :=
                       'Clear ap_document_attr для apda_ap  = '
                    || rec.del_ap
                    || ';';

                DELETE FROM uss_esr.ap_document_attr
                      WHERE apda_ap = rec.del_ap;

                l_error_prm :=
                    'Clear ap_document для apd_ap  = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ap_document
                      WHERE apd_ap = rec.del_ap;

                l_error_prm :=
                    'Clear ap_service для aps_ap  = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ap_service
                      WHERE aps_ap = rec.del_ap;

                l_error_prm :=
                       'Clear eva_log для eval_eva in (select eva_id from uss_esr.esr2visit_actions where eva_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.eva_log
                      WHERE eval_eva IN (SELECT eva_id
                                           FROM uss_esr.esr2visit_actions
                                          WHERE eva_ap = rec.del_ap);

                l_error_prm :=
                       'Clear esr2visit_actions для eva_ap  = '
                    || rec.del_ap
                    || ';';

                DELETE FROM uss_esr.esr2visit_actions
                      WHERE eva_ap = rec.del_ap;

                l_error_prm :=
                       'Clear pd_log для pdl_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_log
                      WHERE pdl_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_right_log для prl_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_right_log
                      WHERE prl_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_detail для pdd_pdp in (select pdp_id from uss_esr.pd_payment where pdp_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || '));';

                DELETE FROM uss_esr.pd_detail
                      WHERE pdd_pdp IN
                                (SELECT pdp_id
                                   FROM uss_esr.pd_payment
                                  WHERE pdp_pd IN (SELECT pd_id
                                                     FROM uss_esr.pc_decision
                                                    WHERE pd_ap = rec.del_ap));

                l_error_prm :=
                       'Clear pd_payment для pdp_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_payment
                      WHERE pdp_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_features для pde_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_features
                      WHERE pde_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_family для pdf_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_family
                      WHERE pdf_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_income_src для pis_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_income_src
                      WHERE pis_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_income_log для pil_pid in (select pid_id from uss_esr.pd_income_detail where pid_pic in (select pic_id from uss_esr.pd_income_calc where pic_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ')));';

                DELETE FROM uss_esr.pd_income_log
                      WHERE pil_pid IN
                                (SELECT pid_id
                                   FROM uss_esr.pd_income_detail
                                  WHERE pid_pic IN
                                            (SELECT pic_id
                                               FROM uss_esr.pd_income_calc
                                              WHERE pic_pd IN
                                                        (SELECT pd_id
                                                           FROM uss_esr.pc_decision
                                                          WHERE pd_ap =
                                                                rec.del_ap)));

                l_error_prm :=
                       'Clear pd_income_detail для pid_pic in (select pic_id from uss_esr.pd_income_calc where pic_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || '));';

                DELETE FROM uss_esr.pd_income_detail
                      WHERE pid_pic IN
                                (SELECT pic_id
                                   FROM uss_esr.pd_income_calc
                                  WHERE pic_pd IN (SELECT pd_id
                                                     FROM uss_esr.pc_decision
                                                    WHERE pd_ap = rec.del_ap));

                l_error_prm :=
                       'Clear pd_income_calc для pic_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_income_calc
                      WHERE pic_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_income_src для pis_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_income_src
                      WHERE pis_pd IN (SELECT pd_id
                                         FROM uss_esr.pc_decision
                                        WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_accrual_period для pdap_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_accrual_period
                      WHERE pdap_pd IN (SELECT pd_id
                                          FROM uss_esr.pc_decision
                                         WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_accrual_period для pdap_change_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_accrual_period p
                      WHERE p.pdap_change_pd IN (SELECT pd_id
                                                   FROM uss_esr.pc_decision
                                                  WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pd_pay_method для pdm_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.pd_pay_method m
                      WHERE m.pdm_pd IN (SELECT pd_id
                                           FROM uss_esr.pc_decision
                                          WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear ac_detail для acd_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ') and d.acd_prsd is null;';

                DELETE FROM uss_esr.ac_detail d
                      WHERE     d.acd_pd IN (SELECT pd_id
                                               FROM uss_esr.pc_decision
                                              WHERE pd_ap = rec.del_ap)
                            AND d.acd_prsd IS NULL; -- 26102022 додано захист, якщо поле заповнено значить додано до ведомосты ы видалення вже неможливе

                -- попередня реалізація, видалення accrual, не чипаємо, то на НР
                --for rec_ac in (select d.acd_ac from uss_esr.ac_detail d where d.acd_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = rec.del_ap))
                --loop
                --delete from uss_esr.ac_log acl where acl.acl_ac = rec_ac.acd_ac;
                --delete from uss_esr.ac_detail d where d.acd_ac = rec_ac.acd_ac;
                --delete from uss_esr.accrual aa where aa.ac_id  = rec_ac.acd_ac;
                --end loop;

                l_error_prm :=
                       'update uss_esr.pc_decision set pd_pcb = Null where pd_ap  = '
                    || rec.del_ap
                    || ';';

                UPDATE uss_esr.pc_decision
                   SET pd_pcb = NULL
                 WHERE pd_ap = rec.del_ap;

                l_error_prm :=
                       'Clear pc_block для pcb_pd in (select pd_id from uss_esr.pc_decision where pd_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM pc_block pcb
                      WHERE pcb.pcb_pd IN (SELECT pd_id
                                             FROM uss_esr.pc_decision
                                            WHERE pd_ap = rec.del_ap);

                l_error_prm :=
                       'Clear pc_decision для pd_ap = '
                    || rec.del_ap
                    || ' and pd_ap_reason = pd_ap and pd_ap_reason < 0;';

                DELETE FROM uss_esr.pc_decision pd
                      WHERE     pd_ap = rec.del_ap
                            AND pd.pd_ap_reason = pd.pd_ap
                            AND pd.pd_ap_reason < 0; -- 03112022 pd.pd_ap_reason = pd.pd_ap так как удаляются только то что замигрировалось

                l_error_prm :=
                       'Clear dn_month_usage для dnu_dn in (select dn_id from uss_esr.deduction where dn_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.dn_month_usage u
                      WHERE u.dnu_dn IN (SELECT dn_id
                                           FROM uss_esr.deduction
                                          WHERE dn_ap = rec.del_ap);

                l_error_prm :=
                       'Clear ac_detail для acd_dn in (select dn_id from uss_esr.deduction where dn_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.ac_detail d
                      WHERE d.acd_dn IN (SELECT dn_id
                                           FROM uss_esr.deduction
                                          WHERE dn_ap = rec.del_ap);

                l_error_prm :=
                       'Clear dn_person для dnp_dn in (select dn_id from uss_esr.deduction where dn_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.dn_person
                      WHERE dnp_dn IN (SELECT dn_id
                                         FROM uss_esr.deduction
                                        WHERE dn_ap = rec.del_ap);

                l_error_prm :=
                       'Clear dn_detail для dnd_dn in (select dn_id from uss_esr.deduction where dn_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.dn_detail
                      WHERE dnd_dn IN (SELECT dn_id
                                         FROM uss_esr.deduction
                                        WHERE dn_ap = rec.del_ap);

                l_error_prm :=
                       'Clear dn_log для dnl_dn in (select dn_id from uss_esr.deduction where dn_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.dn_log
                      WHERE dnl_dn IN (SELECT dn_id
                                         FROM uss_esr.deduction
                                        WHERE dn_ap = rec.del_ap);

                l_error_prm :=
                    'Clear deduction для dn_ap  = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.deduction
                      WHERE dn_ap = rec.del_ap;

                l_error_prm :=
                       'Clear ps_log для psl_ps in (select ps_id from uss_esr.pc_state_alimony where ps_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.ps_log
                      WHERE psl_ps IN (SELECT ps_id
                                         FROM uss_esr.pc_state_alimony
                                        WHERE ps_ap = rec.del_ap);

                -- l_error_prm := 'Clear ps_changes для psc_ps in (select ps_id from uss_esr.pc_state_alimony where ps_ap  = ' || rec.del_ap || ');';
                -- delete from uss_esr.ps_changes where psc_ps in (select ps_id from uss_esr.pc_state_alimony where ps_ap  = rec.del_ap);
                l_error_prm :=
                    'Clear ps_changes для psc_ap = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ps_changes
                      WHERE psc_ap = rec.del_ap;

                l_error_prm :=
                       'Clear pc_state_alimony для ps_ap  = '
                    || rec.del_ap
                    || ';';

                DELETE FROM uss_esr.pc_state_alimony
                      WHERE ps_ap = rec.del_ap;

                l_error_prm :=
                       'Clear ap_income для api_app in (select app_id from uss_esr.ap_person where app_ap  = '
                    || rec.del_ap
                    || ');';

                DELETE FROM uss_esr.ap_income
                      WHERE api_app IN (SELECT app_id
                                          FROM uss_esr.ap_person
                                         WHERE app_ap = rec.del_ap);

                l_error_prm :=
                    'Clear ap_person для app_ap = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.ap_person
                      WHERE app_ap = rec.del_ap;

                l_error_prm :=
                    'Clear appeal для ap_id = ' || rec.del_ap || ';';

                DELETE FROM uss_esr.appeal
                      WHERE ap_id = rec.del_ap;
            END IF;

            l_error_prm :=
                   'Clear uss_exch.v_ls2uss для ldr_lfdp in (select f.family_lfdp from uss_exch.v_ls2family f where f.main_lfdp = '
                || rec.del_src
                || ');';

            DELETE FROM uss_exch.v_ls2uss uu
                  WHERE uu.ldr_lfdp IN (SELECT f.family_lfdp
                                          FROM uss_exch.v_ls2family f
                                         WHERE f.main_lfdp = rec.del_src);
        END LOOP;

        l_error_prm := NULL;
    EXCEPTION
        WHEN CHILD_RECORD_FOUND
        THEN
            l_error_prm :=
                   l_error_prm
                || ' ERR-CONSTRAINT: '
                || REGEXP_SUBSTR (DBMS_UTILITY.format_error_stack,
                                  '[^()]+',
                                  1,
                                  2);
        WHEN OTHERS
        THEN
            l_error_prm :=
                   l_error_prm
                || ' Err: '
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace;
    END;

    FUNCTION get_op_tp1 (p_op_id NUMBER)
        RETURN VARCHAR2
    IS
        l_op_tp1   VARCHAR2 (10);
    BEGIN
        RETURN g_op_info (p_op_id);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            BEGIN
                SELECT op_tp1
                  INTO l_op_tp1
                  FROM uss_ndi.v_ndi_op
                 WHERE op_id = p_op_id;

                g_op_info (p_op_id) := l_op_tp1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_op_info (p_op_id) := NULL;
            END;

            RETURN g_op_info (p_op_id);
    END get_op_tp1;

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE
                   WHEN p_op_id IS NULL
                   THEN
                       0
                   WHEN p_op_id IN (1, 2)
                   THEN
                       1
                   WHEN p_op_id IN (3,
                                    123,
                                    124,
                                    6)
                   THEN
                       -1
                   WHEN p_op_id IN (278, 280)
                   THEN
                       -1                 -- ASOPD 08.2022 OPERVIEIEV (?? 279)
                   WHEN get_op_tp1 (p_op_id) = 'NR'
                   THEN
                       1
                   WHEN get_op_tp1 (p_op_id) = 'DN'
                   THEN
                       -1
                   ELSE
                       1
               END;
    END xsign;

    --Оновлення реєстраційних записів нарахувань в частині "виплачено"
    --Вхідна множина нарахувань - в таблиці tmp_work_ids1
    PROCEDURE actuilize_payed_sum (p_mode INTEGER)
    IS
    BEGIN
        --Очищаємо вхідну множину від дублікатів
        DELETE FROM tmp_work_ids3
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids3 (x_id)
            SELECT DISTINCT x_id
              FROM tmp_work_ids1;

        UPDATE accrual
           SET ac_assign_sum = 0,
               ac_else_dn_sum = 0,
               ac_delta_recalc = 0,
               ac_payed_sum = 0
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE ac_id = x_id)
               AND NOT EXISTS
                       (SELECT 1
                          FROM ac_detail d
                         WHERE acd_ac = ac_id AND d.history_status = 'A');

        MERGE INTO accrual
             USING ( -- запит може бути використаний для оновлення за будь якими критеріями
                     -- а також для порівняння поточного стану даних з бажаним
                     SELECT acd_ac      c_id,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        DECODE (API$ACCTOOLS.xsign (acd_op),
                                                1, acd_sum,
                                                0)
                                    ELSE
                                        0
                                END)    c_plus,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        DECODE (API$ACCTOOLS.xsign (acd_op),
                                                -1, acd_sum,
                                                0)
                                    ELSE
                                        0
                                END)    c_minus,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        CASE
                                            WHEN (   acd_imp_pr_num IS NOT NULL
                                                  OR prs_st = 'KV2')
                                            THEN
                                                  API$ACCTOOLS.xsign (acd_op)
                                                * acd_sum
                                            ELSE
                                                0
                                        END
                                    ELSE
                                        0
                                END)    c_payed,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        CASE
                                            WHEN     acd_imp_pr_num IS NULL
                                                 AND NVL (prs_st, 'XX') IN
                                                         ('NA', 'KV1', 'XX')
                                            THEN
                                                  API$ACCTOOLS.xsign (acd_op)
                                                * acd_sum
                                            ELSE
                                                0
                                        END
                                    ELSE
                                        0
                                END)    c_rolled
                       FROM tmp_work_ids3
                            LEFT JOIN ac_detail acd ON acd_ac = x_id -- filter HERE
                            LEFT JOIN pr_sheet_detail prsd
                                ON acd_prsd = prsd_id
                            LEFT JOIN pr_sheet prs ON prsd_prs = prs_id
                      WHERE acd.history_status = 'A' AND acd_st != 'U' /*exclude acd_op=125*/
                   GROUP BY acd_ac)
                ON (ac_id = c_id)
        WHEN MATCHED
        THEN                                                         -- always
            UPDATE SET ac_assign_sum = c_plus, -- усіляких нарахувань та інших "плюсів"
                       ac_else_dn_sum = c_minus, -- усіляких відрахувань та "мінусів"
                       ac_delta_recalc = c_rolled, -- у відомостях : не виплачено, не заблоковано (назва поля не відповідає змісту)
                       ac_payed_sum = c_payed; -- у відомостях : виплачено або закрито АСОПД

        -- в цій частині в рамках задачі #81114 нічого не змінено !
        UPDATE ac_detail
           SET acd_payed_sum = acd_sum, acd_delta_recalc = NULL
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_ac)
               AND (   EXISTS
                           (SELECT 1
                              FROM pr_sheet_detail, pr_sheet
                             WHERE     acd_prsd = prsd_id
                                   AND prsd_prs = prs_id
                                   AND prs_st = 'KV2')
                    OR acd_imp_pr_num IS NOT NULL)
               AND acd_payed_sum IS NULL
               AND acd_delta_recalc IS NOT NULL;

        UPDATE ac_detail
           SET acd_payed_sum = NULL, acd_delta_recalc = acd_sum
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_ac)
               AND NOT EXISTS
                       (SELECT 1
                          FROM pr_sheet_detail, pr_sheet
                         WHERE     acd_prsd = prsd_id
                               AND prsd_prs = prs_id
                               AND prs_st = 'KV2')
               AND acd_imp_pr_num IS NULL
               AND acd_payed_sum IS NOT NULL
               AND acd_delta_recalc IS NULL;
    END actuilize_payed_sum;

    PROCEDURE Load_LS (p_lfd_lfd NUMBER, p_migration_force NUMBER DEFAULT 0)
    IS
        l_sc_id         NUMBER;
        l_sc_scc        NUMBER;
        l_sc_unique     VARCHAR2 (100);
        l_pc_id         NUMBER;
        l_pa_id         pc_account.pa_id%TYPE;
        l_pa_stage      pc_account.pa_stage%TYPE;
        l_pa_org        pc_account.pa_org%TYPE;

        l_flag          NUMBER := 0; -- флаг для проверки что есть что поданному файлу отрабатівать или нет
        l_blob          BLOB;

        l_error_msg     VARCHAR2 (4000);
        l_lock          TOOLS.t_lockhandler;
        l_cnt           NUMBER := 0;

        l_fn            VARCHAR2 (128);
        l_ln            VARCHAR2 (128);
        l_mn            VARCHAR2 (128);
        l_gender        VARCHAR2 (3);
        l_nationality   VARCHAR2 (3);
        l_src_dt        DATE;
        l_birth_dt      DATE;
        l_inn_num       VARCHAR2 (32);
        l_inn_ndt       NUMBER;
        l_doc_ser       VARCHAR2 (8);
        l_doc_num       VARCHAR2 (32);
        l_doc_ndt       NUMBER;
        l_doc_unzr      VARCHAR2 (32);
        l_doc_is        VARCHAR2 (128);
        l_doc_bdt       DATE;
        l_doc_edt       DATE;
        l_src           VARCHAR2 (3) := '710';
        l_Mode          NUMBER := 1;                          -- c_Mode_Search
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Інформація: ',
                         p_blob   => l_blob);

        IF l_load_enable = 'F'
        THEN
            WriteLineToBlob (
                p_line   =>
                    ' Завантаження заблоковоно. Зверніться до розробника, або дочекайтесь оновлення!',
                p_blob   => l_blob);
            uss_exch.load_file_prtcl.checkloadussdata (
                p_lfd_id     => p_lfd_lfd,
                p_nls_list   => l_blob);
            RETURN;
        END IF;

        WriteLineToBlob (
            p_line   =>
                   ' Початок завантаження: '
                || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'),
            p_blob   => l_blob);

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_ls
            IN (SELECT TRIM (SUBSTR (ls.ls_fio || '   ',
                                     1,
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1)))      AS fio_ln,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              1)))    AS fio_fn,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))            AS fio_sn,
                       ls.*
                  FROM (SELECT DISTINCT
                               COUNT (DISTINCT ls.lfdp_id) OVER ()
                                   AS cnt,
                               LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')
                                   AS ls_base_org,
                               COALESCE (
                                   TO_CHAR (o.nddc_code_dest),
                                   LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5'))
                                   AS ls_org,
                               ls.lfd_id,
                               ls.lfd_lfd,
                               ls.lfd_records,
                               ls.lfd_create_dt,
                               ls.lfd_user_id,
                               ls.lfdp_id,
                               ls.rn,
                               ls.ls_nls,
                               ls.ls_spos,
                               TRANSLATE (
                                   UPPER (
                                       REGEXP_REPLACE (TRIM (ls.ls_fio),
                                                       '\s+',
                                                       ' ')),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ')
                                   AS ls_fio,
                               ls.ls_indots,
                               ls.ls_shifr,
                               ls.ls_vid,
                               ls.ls_kfn,
                               ls.ls_pol,
                               ls.ls_drog,
                               CASE
                                   WHEN REGEXP_LIKE (
                                            ls.ls_pasp,
                                            '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                   THEN
                                       REGEXP_REPLACE (
                                           ls.ls_pasp,
                                           '^(.)',
                                           SUBSTR (ls.ls_pasp, 1, 1) || '-')
                                   ELSE
                                       ls.ls_pasp
                               END
                                   ls_pasp,
                               ls.ls_ntel,
                               ls.mobtel,
                               ls.ls_adrul,
                               ls.ls_adrdom,
                               ls.ls_adrkorp,
                               ls.ls_adrkv,
                               ls.ls_grjd,
                               ls.ls_rab,
                               ls.ls_raj,
                               ls.ls_dnac,
                               ls.ls_idcode,
                               ls.p_doct,
                               ls.p_docsn,
                               ls.p_docunzr,
                               ls.p_docis,
                               ls.p_docdt,
                               ls.p_docend,
                               ls.p_docact,
                               ls.p_docactdt,
                               nnc.nptc_nst,
                               nnc.nptc_npt,
                               CASE
                                   WHEN sc.ls_nls IS NOT NULL THEN 1
                                   ELSE 0
                               END
                                   AS is_migr,
                               u.wu_login,
                               u.wu_pib,
                               u.wu_pib || '(' || u.wu_login || ')'
                                   AS wu_txt,
                               npt.npt_id
                                   AS ls_npt_id
                          FROM uss_exch.v_ls_data  ls
                               LEFT JOIN uss_exch.v_ls2sc sc
                                   ON     sc.ls_nls = ls.ls_nls
                                      AND sc.ls_raj = ls.ls_raj
                                      AND sc.lfd_lfd = ls.lfd_lfd
                               --                       join v_ndi_payment_type_mg npt on npt.npt_code = ls.ls_kfn and npt.history_status = 'A'
                               JOIN uss_ndi.v_ndi_payment_type npt
                                   ON     npt.npt_code = ls.ls_kfn
                                      AND npt.history_status = 'A'
                                      -- IC #92346
                                      AND NVL (npt.npt_npc, -1) =
                                          CASE
                                              WHEN npt.npt_code = '256'
                                              THEN
                                                  42
                                              ELSE
                                                  NVL (npt.npt_npc, -1)
                                          END
                               JOIN uss_ndi.v_ndi_npt_config nnc
                                   ON     nnc.nptc_npt = npt.npt_id
                                      AND nnc.nptc_nst <> 664 -- все окрім ВПО
                               JOIN v_ndi_service_type_mg nst
                                   ON nst.nst_id = nnc.nptc_nst
                               LEFT JOIN uss_ndi.v_ndi_decoding_config o
                                   ON     o.nddc_code_src =
                                          LPAD (LPAD (ls.ls_raj, 4, '0'),
                                                5,
                                                '5')
                                      AND o.nddc_tp = 'ORG_MIGR'
                               LEFT JOIN ikis_sysweb.v$all_users u
                                   ON u.wu_id = ls.lfd_user_id
                         WHERE     ls.lfd_lfd = p_lfd_lfd
                               AND nst.org =
                                   SUBSTR (
                                       LPAD (LPAD (ls.ls_raj, 4, '0'),
                                             5,
                                             '5'),
                                       1,
                                       3)
                               AND getAccessByKFN (
                                       ls.ls_kfn,
                                       SUBSTR (
                                           LPAD (LPAD (ls.ls_raj, 4, '0'),
                                                 5,
                                                 '5'),
                                           1,
                                           3)) =
                                   1
                               -- and ls.ls_nls in ('663569')
                               AND (   sc.ls_nls IS NULL
                                    OR p_migration_force = 1)) ls)
        LOOP
            BEGIN
                l_sc_unique :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_idcode, '^(\d){10}$')
                        THEN
                            rec_ls.ls_idcode
                        WHEN LENGTH (TRIM (rec_ls.ls_pasp)) >= 6
                        THEN
                            rec_ls.ls_pasp
                        ELSE
                            NULL
                    END;

                IF l_sc_unique IS NOT NULL
                THEN
                    l_lock :=
                        tools.request_lock_with_timeout (
                            p_descr               => 'MIGR_SC_' || l_sc_unique,
                            p_error_msg           =>
                                'В данний час вже виконуються завантаження для СРК, спробуйте дозавантажити пізніше.',
                            p_timeout             => 13,
                            p_release_on_commit   => TRUE);
                END IF;

                l_cnt := l_cnt + 1;
                SetAction (
                       'ОР №'
                    || rec_ls.ls_base_org
                    || '_'
                    || rec_ls.ls_nls
                    || '. Запис '
                    || l_cnt
                    || ' з '
                    || rec_ls.cnt);

                l_flag := 1;
                l_error_prm := '';
                l_error_msg := '';
                l_sc_id := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;

                l_fn := TOOLS.Clear_Name (rec_ls.fio_fn);
                l_ln := TOOLS.Clear_Name (rec_ls.fio_ln);
                l_mn := TOOLS.Clear_Name (rec_ls.fio_sn);
                l_gender :=
                    CASE
                        WHEN rec_ls.ls_pol = '1' THEN 'M'
                        WHEN rec_ls.ls_pol = '2' THEN 'F'
                        ELSE 'V'
                    END;
                l_nationality :=
                    CASE WHEN rec_ls.ls_grjd = '1' THEN 1 ELSE -1 END;
                l_src_dt := rec_ls.lfd_create_dt;
                l_birth_dt :=
                    TO_DATE (rec_ls.ls_drog DEFAULT NULL ON CONVERSION ERROR,
                             'dd.mm.yyyy');
                l_inn_num :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_idcode, '^(\d){10}$')
                        THEN
                            rec_ls.ls_idcode
                        ELSE
                            NULL
                    END;
                l_inn_ndt :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_idcode, '^(\d){10}$')
                        THEN
                            5
                        ELSE
                            NULL
                    END;                                      -- тип из архива
                l_doc_ser :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp, '^(\d){9}$')
                        THEN
                            NULL
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, 1, 2)
                        WHEN REGEXP_LIKE (
                                 rec_ls.ls_pasp,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, 1, 4)
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, 1, 3)
                        ELSE
                            NULL
                    END;
                l_doc_num :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp, '^(\d){9}$')
                        THEN
                            rec_ls.ls_pasp
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, -6, 6)
                        WHEN REGEXP_LIKE (
                                 rec_ls.ls_pasp,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, -6, 6)
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (rec_ls.ls_pasp, -6, 6)
                        ELSE
                            rec_ls.ls_pasp
                    END;
                l_doc_ndt :=
                    CASE
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp, '^(\d){9}$')
                        THEN
                            7                                 -- новій паспорт
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            6                            -- старій паспорт из архива
                        WHEN REGEXP_LIKE (
                                 rec_ls.ls_pasp,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            37                            -- свидетельство о рождении
                        WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                          '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            37                            -- свидетельство о рождении
                        -- если у персоны нет инн и тип второго документа не определили
                        -- то любой документ который пришел в качестве паспорта
                        -- (документа идентифицирующего особу)
                        -- делаем как документ пришедший с АСОПД
                        -- и  на основании его создаем карточку
                        -- при другом раскладе создаем как инший документ
                        ELSE
                            CASE
                                WHEN NOT REGEXP_LIKE (
                                             NVL (
                                                 NULLIF (rec_ls.ls_idcode,
                                                         '0000000000'),
                                                 '!'),
                                             '^(\d){10}$')
                                THEN
                                    10192
                                ELSE
                                    684
                            END
                    END;
                l_doc_unzr :=
                    CASE
                        WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                        THEN
                            rec_ls.p_docunzr
                    END;
                l_doc_is :=
                    TRIM (
                        CASE
                            WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                            THEN
                                rec_ls.p_docis
                        END);
                l_doc_bdt :=
                    CASE
                        WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                        THEN
                            TO_DATE (
                                rec_ls.p_docdt
                                    DEFAULT NULL ON CONVERSION ERROR,
                                'dd.mm.yyyy')
                    END;
                l_doc_edt :=
                    CASE
                        WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                        THEN
                            TO_DATE (
                                rec_ls.p_docend
                                    DEFAULT NULL ON CONVERSION ERROR,
                                'dd.mm.yyyy')
                    END;

                -- IC #86382
                /*
                if rec_ls.ls_pol not in ('1','2')
                    then
                    l_error_prm := 'LS_DATA';
                    raise ex_error_no_gender;
                end if;
                */

                l_sc_id :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn            => l_fn,
                        p_ln            => l_ln,
                        p_mn            => l_mn,
                        p_gender        => l_gender,
                        p_nationality   => l_nationality,
                        p_src_dt        => l_src_dt,
                        p_birth_dt      => l_birth_dt,
                        p_inn_num       => l_inn_num,
                        p_inn_ndt       => l_inn_ndt,
                        p_doc_ser       => l_doc_ser,
                        p_doc_num       => l_doc_num,
                        p_doc_ndt       => l_doc_ndt,
                        p_doc_unzr      => l_doc_unzr,
                        p_doc_is        => l_doc_is,
                        p_doc_bdt       => l_doc_bdt,
                        p_doc_edt       => l_doc_edt,
                        p_src           => l_src,
                        p_sc            => l_sc_id,
                        p_sc_unique     => l_sc_unique,
                        p_sc_scc        => l_sc_scc,
                        p_Mode          => l_Mode);

                -- IC #104464 перевіряти по всім учасникам, яких завантажуємо, наявність рішень за останні 3 місяці
                IF     l_sc_id > 0
                   AND getLastDatePayment (l_sc_id) >
                       ADD_MONTHS (SYSDATE, -3)
                -- Якщо є рішення в ЄІССС, у яких в PD_payment кінцева дата дії закінчується не раніше, ніж 3 місяці до міграції, тоді не змінюємо ПІБ.
                THEN
                    NULL;
                ELSE
                    l_Mode := 0;                -- c_Mode_Search_Update_Create
                    l_sc_unique := NULL;
                    l_sc_scc := NULL;
                    l_sc_id :=
                        uss_person.load$socialcard.Load_SC_Intrnl (
                            p_fn            => l_fn,
                            p_ln            => l_ln,
                            p_mn            => l_mn,
                            p_gender        => l_gender,
                            p_nationality   => l_nationality,
                            p_src_dt        => l_src_dt,
                            p_birth_dt      => l_birth_dt,
                            p_inn_num       => l_inn_num,
                            p_inn_ndt       => l_inn_ndt,
                            p_doc_ser       => l_doc_ser,
                            p_doc_num       => l_doc_num,
                            p_doc_ndt       => l_doc_ndt,
                            p_doc_unzr      => l_doc_unzr,
                            p_doc_is        => l_doc_is,
                            p_doc_bdt       => l_doc_bdt,
                            p_doc_edt       => l_doc_edt,
                            p_src           => l_src,
                            p_sc            => l_sc_id,
                            p_sc_unique     => l_sc_unique,
                            p_sc_scc        => l_sc_scc,
                            p_Mode          => l_Mode);
                END IF;

                ---------------------------------------------------
                -- для корректно найдених персон створюємо рішення
                IF l_sc_id > 0
                THEN
                    BEGIN
                        SELECT pc_id
                          INTO l_pc_id
                          FROM personalcase pc
                         WHERE pc.pc_sc = l_sc_id;

                        -- перемиграция по районам
                        UPDATE personalcase pc
                           SET pc.com_org = rec_ls.ls_org
                         WHERE     pc.pc_id = l_pc_id
                               AND COALESCE (pc.com_org, -1) = 50000
                               AND COALESCE (pc.com_org, -1) <> rec_ls.ls_org;

                        UPDATE personalcase pc
                           SET pc.pc_num = l_sc_unique
                         WHERE     pc.pc_id = l_pc_id
                               AND pc.pc_num <> l_sc_unique
                               AND NVL (pc.pc_num, 'N/A') = 'N/A'; -- IC #109317
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            INSERT INTO personalcase (pc_id,
                                                      pc_num,
                                                      pc_create_dt,
                                                      pc_sc,
                                                      pc_st,
                                                      com_org)
                                 VALUES (NULL,
                                         l_sc_unique,
                                         rec_ls.lfd_create_dt,
                                         l_sc_id,
                                         'R',
                                         rec_ls.ls_org)
                              RETURNING pc_id
                                   INTO l_pc_id;

                            INSERT INTO uss_esr.pc_location (pl_id,
                                                             pl_pc,
                                                             pl_org,
                                                             pl_start_dt,
                                                             pl_stop_dt,
                                                             history_status)
                                     VALUES (
                                                0,
                                                l_pc_id,
                                                rec_ls.ls_org,
                                                TO_DATE ('01.01.2000',
                                                         'DD.MM.YYYY'),
                                                TO_DATE ('31.12.2999',
                                                         'DD.MM.YYYY'),
                                                'A');
                    END;

                    --------- особовий рахкнок
                    BEGIN
                        SELECT pa.pa_id, pa.pa_stage, pa_org
                          INTO l_pa_id, l_pa_stage, l_pa_org
                          FROM pc_account pa
                         WHERE     pa.pa_pc = l_pc_id
                               AND pa.pa_nst = rec_ls.nptc_nst
                               AND pa.pa_num = rec_ls.ls_nls;

                           -- маркируем услугу за текущим оргом
                           UPDATE pc_account ddd
                              -- IC #95039
                              -- Шукати потрібний район з урахуванням таблиці USS_NDI.NDI_DECODING_CONFIG. і записувати в поле лише значення вже об'єднаного району
                              -- set ddd.pa_org = rec_ls.ls_base_org,
                              SET ddd.pa_org = rec_ls.ls_org, ddd.pa_stage = '1'
                            WHERE     ddd.pa_id = l_pa_id
                                  AND COALESCE (ddd.pa_org, -1) <> rec_ls.ls_org
                        RETURNING ddd.pa_stage
                             INTO l_pa_stage;

                        -- записіваем информацию по услуге, откуда грузили и на какую дату последнего нарахування у нас виплата в вігрузке
                        INSERT INTO pa_log (pal_id,
                                            pal_pa,
                                            pal_hs,
                                            pal_st,
                                            pal_message,
                                            pal_st_old,
                                            pal_tp)
                                 VALUES (
                                            NULL,
                                            l_pa_id,
                                            NULL,
                                            NULL,
                                               CHR (38)
                                            || '92#'
                                            || rec_ls.lfd_lfd
                                            || '#'
                                            || rec_ls.ls_nls
                                            || '#'
                                            || rec_ls.ls_kfn
                                            || '#'
                                            || rec_ls.ls_dnac
                                            || '#'
                                            || rec_ls.ls_org
                                            || '#'
                                            || rec_ls.ls_org
                                            || '#'
                                            || rec_ls.wu_txt
                                            || '#'
                                            || TO_CHAR (
                                                   SYSDATE,
                                                   'dd.mm.yyyy hh24:mi:ss'),
                                            NULL,
                                            'SYS');
                    -- не нашли услугу (особовій рахунок)
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            INSERT INTO pc_account (pa_id,
                                                    pa_pc,
                                                    pa_num,
                                                    pa_nst,
                                                    pa_stage,
                                                    pa_org)
                                 VALUES (NULL,
                                         l_pc_id,
                                         rec_ls.ls_nls,
                                         rec_ls.nptc_nst,
                                         '1',
                                         rec_ls.ls_org)
                              RETURNING pa_id, pa_stage, pa_org
                                   INTO l_pa_id, l_pa_stage, l_pa_org;

                            -- записіваем информацию по услуге, откуда грузили и на какую дату последнего нарахування у нас виплата в вігрузке
                            INSERT INTO pa_log (pal_id,
                                                pal_pa,
                                                pal_hs,
                                                pal_st,
                                                pal_message,
                                                pal_st_old,
                                                pal_tp)
                                     VALUES (
                                                NULL,
                                                l_pa_id,
                                                NULL,
                                                NULL,
                                                   CHR (38)
                                                || '92#'
                                                || rec_ls.lfd_lfd
                                                || '#'
                                                || rec_ls.ls_nls
                                                || '#'
                                                || rec_ls.ls_kfn
                                                || '#'
                                                || rec_ls.ls_dnac
                                                || '#'
                                                || rec_ls.ls_org
                                                || '#'
                                                || rec_ls.ls_org
                                                || '#'
                                                || rec_ls.wu_txt
                                                || '#'
                                                || TO_CHAR (
                                                       SYSDATE,
                                                       'dd.mm.yyyy hh24:mi:ss'),
                                                NULL,
                                                'SYS');
                    END;

                    l_lock :=
                        tools.request_lock_with_timeout (
                            p_descr               => 'MIGR_PA_' || l_pa_id,
                            p_error_msg           =>
                                'В данний час вже виконуються завантаження для особового рахунку, спробуйте дозавантажити пізніше.',
                            p_timeout             => 13,
                            p_release_on_commit   => TRUE);

                    -- IC #92516
                    -- При наявності вже записів в AC_Detail по утриманням з ACD_OP = 5 з відрахувань - дозволяти переміграцію
                    IF COALESCE (l_pa_stage, '0') = '0'
                    THEN
                        SELECT CASE
                                   WHEN EXISTS
                                            (SELECT 1
                                               FROM uss_esr.ac_detail  acd,
                                                    uss_esr.deduction  dn
                                              WHERE     acd.acd_dn = dn.dn_id
                                                    AND acd.acd_op = 5
                                                    AND dn.dn_pa = l_pa_id)
                                   THEN
                                       '1'
                                   ELSE
                                       '0'
                               END
                          INTO l_pa_stage
                          FROM DUAL;
                    END IF;

                    -- якщо рішення по послузібуло завантажено (l_pa_stage = '1') и при этом не менялась после миграции.
                    IF l_pa_stage = '1'
                    THEN
                        -- по итогу мы всегда вызываем попытку удаления, все зависит от того бралось ли в работу, пока не бралось данное действие доступно
                        BEGIN
                            Clear_LS (l_pa_id,
                                      rec_ls.ls_nls,
                                      rec_ls.ls_base_org);

                            IF l_error_prm IS NOT NULL
                            THEN
                                RAISE ex_error_Clear_LS;
                            END IF;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                RAISE ex_error_Clear_LS;
                        END;

                        -- ADDDDD
                        -- Отмечаем вновь созданную или ранее созданную запись в socialcard|PERSONALCASE|PC_ACCOUNT
                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_ls.lfdp_id,
                                         l_sc_id,
                                         'USS_PERSON.SOCIALCARD');

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_ls.lfdp_id,
                                         l_pc_id,
                                         'USS_ESR.PERSONALCASE');

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_ls.lfdp_id,
                                         l_pa_id,
                                         'USS_ESR.PC_ACCOUNT');

                        -- понеслась ....
                        -- первая часть марлезонского балета - РЕШЕНИЯ
                        IF l_sc_scc IS NULL
                        THEN
                            SELECT Sc_Scc
                              INTO l_sc_scc
                              FROM uss_person.v_Socialcard Sc
                             WHERE Sc.Sc_Id = l_sc_id;
                        END IF;

                        Load_Decision (p_lfd_lfd       => p_lfd_lfd,
                                       p_ls_lfdp       => rec_ls.lfdp_id,
                                       p_pc            => l_pc_id,
                                       p_sc            => l_sc_id,
                                       p_pa            => l_pa_id,
                                       p_ls_nls        => rec_ls.ls_nls,
                                       p_ls_org        => rec_ls.ls_org,
                                       p_ls_spos       => rec_ls.ls_spos,
                                       p_ls_indots     => rec_ls.ls_indots,
                                       p_ls_adrul      => rec_ls.ls_adrul,
                                       p_ls_adrdom     => rec_ls.ls_adrdom,
                                       p_ls_adrkorp    => rec_ls.ls_adrkorp,
                                       p_ls_adrkv      => rec_ls.ls_adrkv,
                                       p_nptc_nst      => rec_ls.nptc_nst,
                                       p_ls_base_org   => rec_ls.ls_base_org,
                                       p_sc_scc        => l_sc_scc,
                                       p_wu            => rec_ls.lfd_user_id,
                                       p_wu_txt        => rec_ls.wu_txt,
                                       p_ls_npt_id     => rec_ls.ls_npt_id);
                    ELSE
                        RAISE ex_error_stage_not1;
                    END IF;
                ----------------
                ELSIF l_sc_id = -2
                THEN
                    RAISE ex_error_sc_2;
                ELSIF l_sc_id = -1
                THEN
                    RAISE ex_error_sc_1;
                ELSE
                    RAISE ex_error_sc_else;
                END IF;

                -- явный комит по каждому НЛС (короткие транзакции)
                COMMIT;
            EXCEPTION
                WHEN ex_error_Clear_LS
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Інформація. Переміграцію особового рахунку заблоковано, ОР взято в роботу!; ('
                        || l_error_prm
                        || ')';
                WHEN ex_error_stage_not1
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок взято в роботу, завантаження/перезавантаження неможливе;';
                WHEN ex_error_sc_2
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Документи заявника не вказано чи неможливо визначити тип документа;';
                WHEN ex_error_sc_1
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; За документами заявника знайдено більше однієї персони в ЄСР;';
                WHEN ex_error_sc_else
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Недостатньо інформації для визначення персони заявника;';
                WHEN ex_error_igd_doc_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Документи утриманця не вказано чи неможливо визначити тип документа;';
                WHEN ex_error_igd_2sc_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; За документами утриманця знайдено більше однієї персони в ЄСР;';
                WHEN ex_error_igd_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Недостатньо інформації для визначення персони утриманця;';
                WHEN ex_error_op_accrual
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Невідомий код операції для нарахувань;'
                        || l_error_prm;
                WHEN ex_error_npt_accrual
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Невідомий код нарахувань (неоплата за місяць.рік);'
                        || l_error_prm;
                WHEN ex_error_klovud_deduction
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутне інформація щодо стягувача;'
                        || l_error_prm;
                WHEN ex_error_kud_deduction
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутня інформація за вказаним кодом утримання;'
                        || l_error_prm;
                WHEN ex_error_nf_bank
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити банк, код банку/відділення;'
                        || l_error_prm;
                WHEN ex_error_nf_npo
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити індекс в довіднику;'
                        || l_error_prm;
                WHEN ex_error_nf_ns
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити вулицю в довіднику;'
                        || l_error_prm;
                WHEN ex_error_create_pd
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутня інформація для створення рішення;'
                        || l_error_prm;
                WHEN ex_error_acd_period
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок містить періоди дії послуги, які перетинаються с іншими періодами цієї послуги.;'
                        || l_error_prm;
                WHEN ex_error_no_gender
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Не вказано стать особи. Створення картки СРКО неможлива.;'
                        || l_error_prm;
                WHEN ex_error_84235_part_1
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок містить індекс довжиною більше 6 символів;'
                        || l_error_prm;
                WHEN ex_error_84235_part_2
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; У особовому рахунку відсутня інформація за виплатними реквізитами. Масив: ;'
                        || l_error_prm;
                WHEN ex_error_85513
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутня інформація для визначення періоду по боргу утримання. Масив: ;'
                        || l_error_prm;
                WHEN ex_error_90903
                THEN
                    l_error_msg := rec_ls.ls_nls || '; ' || l_error_prm;
                WHEN ex_error_91221
                THEN
                    l_error_msg := rec_ls.ls_nls || '; ' || l_error_prm;
                WHEN ex_error_102940
                THEN
                    l_error_msg := rec_ls.ls_nls || '; ' || l_error_prm;
                WHEN OTHERS
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Некоректні вхідні данні;'
                        || DBMS_UTILITY.format_error_stack
                        || DBMS_UTILITY.format_error_backtrace;
            END;

            -- запись ошибки
            IF l_error_msg IS NOT NULL
            THEN
                BEGIN                                 -- если потеряли хендлер
                    tools.release_lock (p_lock_handler => l_lock);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                ROLLBACK;
                WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                SetNlsLog (rec_ls.lfdp_id, -1, l_error_msg);
            END IF;
        END LOOP;

        IF l_flag = 0
        THEN
            WriteLineToBlob (
                p_line   => ' Відсутні особові рахунки для завантаження',
                p_blob   => l_blob);
        END IF;

        WriteLineToBlob (
            p_line   =>
                   ' Закінчення завантаження: '
                || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'),
            p_blob   => l_blob);

        uss_exch.load_file_prtcl.checkloadussdata (p_lfd_id     => p_lfd_lfd,
                                                   p_nls_list   => l_blob);
    END;

    PROCEDURE AddPdFamily (p_lfd_lfd     NUMBER,
                           p_ls_nls      VARCHAR2,
                           p_ap_id       NUMBER,
                           p_aps_id      NUMBER,
                           p_pd_id       NUMBER,
                           p_nptc_nst    NUMBER,
                           p_np_dnprav   DATE)
    IS
        l_igd_sc_id       NUMBER;
        l_igd_sc_unique   VARCHAR2 (100);
        l_igd_sc_scc      NUMBER;
        l_pdf_id          NUMBER;

        l_ns_id           NUMBER;
        l_ns_kaot         NUMBER;
        l_ns_name         VARCHAR2 (250);
        l_nsrt_name       VARCHAR2 (250);

        l_scd_id          NUMBER;
        l_scd_dh          NUMBER;
        l_ls_kfn          uss_exch.v_ls_data.ls_kfn%TYPE;

        l_attrs           uss_person.api$socialcard.t_doc_attrs;

        l_is_child        VARCHAR2 (2); -- B_osob 28 - це основна справа , 29 - це виділена справа
        l_nls_child       VARCHAR2 (6);
        l_ap_main         NUMBER;

        l_pdp_start_dt    DATE;
        l_pdp_stop_dt     DATE;

        l_fn              VARCHAR2 (128);
        l_ln              VARCHAR2 (128);
        l_mn              VARCHAR2 (128);
        l_gender          VARCHAR2 (3);
        l_nationality     VARCHAR2 (3);
        l_src_dt          DATE;
        l_birth_dt        DATE;
        l_inn_num         VARCHAR2 (32);
        l_inn_ndt         NUMBER;
        l_doc_ser         VARCHAR2 (8);
        l_doc_num         VARCHAR2 (32);
        l_doc_ndt         NUMBER;
        l_doc_unzr        VARCHAR2 (32);
        l_doc_is          VARCHAR2 (128);
        l_doc_bdt         DATE;
        l_doc_edt         DATE;
        l_src             VARCHAR2 (3) := '710';
        l_Mode            NUMBER := 1;                        -- c_Mode_Search
    BEGIN
        SELECT MAX (ls_kfn)
          INTO l_ls_kfn
          FROM uss_exch.v_ls_data ls
         WHERE ls.lfd_lfd = p_lfd_lfd AND ls.ls_nls = p_ls_nls;

        FOR rec_igd
            IN (SELECT TRIM (SUBSTR (igd.igd_fio || '   ',
                                     1,
                                     INSTR (igd.igd_fio || '   ',
                                            ' ',
                                            1,
                                            1)))      AS fio_ln,
                       TRIM (SUBSTR (igd.igd_fio || '   ',
                                     INSTR (igd.igd_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (igd.igd_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (igd.igd_fio || '   ',
                                              ' ',
                                              1,
                                              1)))    AS fio_fn,
                       TRIM (SUBSTR (igd.igd_fio || '   ',
                                     INSTR (igd.igd_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))            AS fio_sn,
                       igd.*
                  FROM (SELECT CASE
                                   WHEN igd_nomig = '0' THEN 'Z'
                                   ELSE 'FP'
                               END                           AS igd_app_tp,
                               CASE
                                   WHEN     p_nptc_nst = 901 -- IC #107405 по допомозі 901 (КФН 523, 524) по всім учасникам з масиву bigd, якщо стоїть 0, то прописувати CHRG
                                        AND igd_nomig != '0'
                                        AND igd_katrod = '0'
                                   THEN
                                       'CHRG'
                                   WHEN igd_katrod = '5'
                                   THEN
                                       'GC'
                                   WHEN igd_katrod = '6'
                                   THEN
                                       'GP'
                                   WHEN igd_katrod = '7'
                                   THEN
                                       'SP'
                                   WHEN igd_katrod = '8'
                                   THEN
                                       'SC'
                                   WHEN igd_katrod = '65'
                                   THEN
                                       'PILM'
                                   WHEN igd_katrod = '66'
                                   THEN
                                       'PILF'
                                   WHEN igd_katrod = '52'
                                   THEN
                                       'CHRG'
                                   WHEN igd_katrod = '61'
                                   THEN
                                       'GGC'
                                   WHEN igd_katrod = '62'
                                   THEN
                                       'CIL'
                                   WHEN igd_katrod = '63'
                                   THEN
                                       'NC'
                                   WHEN igd_katrod = '64'
                                   THEN
                                       'UN'
                                   WHEN igd_katrod = '68'
                                   THEN
                                       'OTHER'
                                   WHEN igd_katrod = '2'
                                   THEN
                                       'HW'
                                   WHEN igd_katrod = '4'
                                   THEN
                                       'BS'
                                   WHEN igd_katrod = '3'
                                   THEN
                                       'B'
                                   WHEN igd_katrod = '51'
                                   THEN
                                       'GUARD'
                                   WHEN igd_katrod = '1'
                                   THEN
                                       'P'
                                   WHEN igd_katrod = '0'
                                   THEN
                                       'Z'
                                   WHEN igd_katrod = '67'
                                   THEN
                                       NULL
                               END                           AS igd_apd_katrod,
                               i.lfd_lfd,
                               i.lfd_create_dt,
                               i.lfdp_id,
                               i.ls_nls,
                               i.igd_nomig,
                               i.igd_katrod,
                               i.igd_katnetr,
                               i.igd_dusn,
                               TRANSLATE (
                                   UPPER (
                                       REGEXP_REPLACE (
                                           TRIM (i.igd_fio),
                                           '\s+',
                                           ' ')),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ')          AS igd_fio,
                               i.igd_drog,
                               i.igd_pol,
                               i.p_doct,
                               CASE
                                   WHEN REGEXP_LIKE (
                                            i.p_docsn,
                                            '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                   THEN
                                       REGEXP_REPLACE (
                                           i.p_docsn,
                                           '^(.)',
                                              SUBSTR (i.p_docsn,
                                                      1,
                                                      1)
                                           || '-')
                                   ELSE
                                       i.p_docsn
                               END                           p_docsn,
                               i.p_docunzr,
                               i.p_docis,
                               i.p_docdt,
                               i.p_docend,
                               i.p_ipn,
                               i.igd_psn,
                               i.igd_dso,
                               ls.ls_adrul,
                               ls.ls_adrdom,
                               ls.ls_adrkorp,
                               ls.ls_adrkv,
                               ls.ls_indots,
                               ls.mobtel,
                               LPAD (LPAD (ls.ls_raj, 4, '0'),
                                     5,
                                     '5')                    AS ls_org,
                               (  SELECT --+ first_rows(1)
                                         -- max(a.klat_name) keep(dense_rank first order by a.lfd_id desc) klat_name
                                         a.klat_name
                                    FROM uss_exch.v_b_klat a
                                   WHERE a.klat_code = ls.ls_raj
                                ORDER BY a.lfd_lfd DESC
                                   FETCH FIRST ROWS ONLY)    raj_name, -- ic #85426
                               (  SELECT --+ first_rows(1)
                                         --max(a.klat_name) keep(dense_rank first order by a.lfd_id desc) klat_name
                                         a.klat_name
                                    FROM uss_exch.v_b_klat a
                                   WHERE a.klat_code =
                                            SUBSTR (LPAD (ls.ls_raj, 4, '0'),
                                                    1,
                                                    2)
                                         || '00'
                                ORDER BY a.lfd_lfd DESC
                                   FETCH FIRST ROWS ONLY)    reg_name, -- IC #85426
                               ls.ls_rab,
                               ls.ls_kfn
                          FROM uss_exch.v_ls_igd_data  i
                               LEFT JOIN uss_exch.v_ls_data ls
                                   ON     ls.lfd_lfd = i.lfd_lfd
                                      AND ls.ls_nls = i.ls_nls
                                      AND i.igd_nomig = 0
                         WHERE     i.lfd_lfd = p_lfd_lfd
                               AND i.ls_nls = p_ls_nls
                               -- IC #93156 Взагалі по цим допомогам до 2023 року не перевіряти по масиву НП наявність утриманців
                               -- Tania, 04.04.2024 10:36 ой, а можна не робити для цього КФН?? (516)
                               AND CASE
                                       WHEN     NVL (ls.ls_kfn, l_ls_kfn) IN
                                                    ('515',        /*'516', */
                                                     '517',
                                                     '523',
                                                     '524')
                                            AND i.igd_nomig != '0'
                                       THEN
                                           CASE
                                               WHEN TO_DATE (
                                                        i.igd_dso
                                                            DEFAULT NULL ON CONVERSION ERROR,
                                                        'dd.mm.yyyy') <
                                                    TO_DATE ('01.01.2023',
                                                             'dd.mm.yyyy')
                                               THEN
                                                   0
                                               WHEN EXISTS
                                                        (SELECT 1 -- якщо є нарахування з масиву NP
                                                           FROM uss_esr.pd_payment
                                                                p,
                                                                uss_esr.pd_detail
                                                                pd
                                                          WHERE     p.pdp_id =
                                                                    pd.pdd_pdp
                                                                AND p.pdp_pd =
                                                                    p_pd_id
                                                                AND pd.pdd_key =
                                                                    i.lfdp_id)
                                               THEN
                                                   1
                                               ELSE
                                                   0
                                           END
                                       ELSE
                                           1
                                   END =
                                   1
                        UNION
                        SELECT 'Z'
                                   AS igd_app_tp,
                               'Z'
                                   AS igd_apd_katrod,
                               ls.lfd_lfd,
                               ls.lfd_create_dt,
                               ls.lfdp_id,
                               ls.ls_nls,
                               '0'
                                   AS igd_nomig,
                               '0'
                                   AS igd_katrod,
                               '0'
                                   AS igd_katnetr,
                               NULL
                                   AS Igd_Dusn,
                               TRANSLATE (
                                   UPPER (
                                       REGEXP_REPLACE (TRIM (ls.ls_fio),
                                                       '\s+',
                                                       ' ')),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ')
                                   AS igd_fio,
                               ls.ls_drog
                                   AS igd_drog,
                               ls.ls_pol
                                   AS igd_pol,
                               ls.p_doct,
                               CASE
                                   WHEN REGEXP_LIKE (
                                            ls.p_docsn,
                                            '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                   THEN
                                       REGEXP_REPLACE (
                                           ls.p_docsn,
                                           '^(.)',
                                           SUBSTR (ls.p_docsn, 1, 1) || '-')
                                   ELSE
                                       ls.p_docsn
                               END
                                   p_docsn,
                               ls.p_docunzr,
                               ls.p_docis,
                               ls.p_docdt,
                               ls.p_docend,
                               ls.ls_idcode
                                   AS p_ipn,
                               '0'
                                   AS igd_psn,
                               NULL
                                   AS igd_dso,
                               ls.ls_adrul,
                               ls.ls_adrdom,
                               ls.ls_adrkorp,
                               ls.ls_adrkv,
                               ls.ls_indots,
                               ls.mobtel,
                               LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')
                                   AS ls_org,
                               (  SELECT --+ first_rows(1)
                                         --max(a.klat_name) keep(dense_rank  first order by a.lfd_id desc) klat_name
                                         a.klat_name
                                    FROM uss_exch.v_b_klat a
                                   WHERE a.klat_code = ls.ls_raj
                                ORDER BY a.lfd_lfd DESC
                                   FETCH FIRST ROWS ONLY)
                                   raj_name,
                               (  SELECT --+ first_rows(1)
                                         --max(a.klat_name) keep(dense_rank first order by a.lfd_id desc) klat_name
                                         a.klat_name
                                    FROM uss_exch.v_b_klat a
                                   WHERE a.klat_code =
                                            SUBSTR (LPAD (ls.ls_raj, 4, '0'),
                                                    1,
                                                    2)
                                         || '00'
                                ORDER BY a.lfd_lfd DESC
                                   FETCH FIRST ROWS ONLY)
                                   reg_name,                      -- IC #85426
                               ls.ls_rab,
                               ls.ls_kfn
                          FROM uss_exch.v_ls_data ls
                         WHERE     ls.lfd_lfd = p_lfd_lfd
                               AND ls.ls_nls = p_ls_nls
                               AND NOT EXISTS
                                       (SELECT igd.lfdp_id
                                          FROM uss_exch.v_ls_igd_data igd
                                         WHERE     ls.lfd_lfd = igd.lfd_lfd
                                               AND ls.ls_nls = igd.ls_nls
                                               AND igd.igd_nomig = '0')) igd)
        LOOP
            ------------------------------------------------------------------------------------------------------
            l_igd_sc_id := NULL;
            l_igd_sc_scc := NULL;
            l_igd_sc_unique := NULL;

            IF    rec_igd.fio_ln IS NULL                          -- IC #85791
               OR rec_igd.fio_fn IS NULL
               OR (rec_igd.p_docsn IS NULL AND rec_igd.p_ipn IS NULL)
            THEN
                IF rec_igd.igd_nomig = '0'                          -- заявник
                THEN
                    RAISE ex_error_sc_else;
                ELSE
                    RAISE ex_error_igd_decision;                  -- утриманці
                END IF;
            END IF;

            -- IC #86382
            /*
            if rec_igd.igd_pol not in ('1','2')
                then
                l_error_prm := 'IGD_DATA';
                raise ex_error_no_gender;
            end if;
            */
            l_fn := TOOLS.Clear_Name (rec_igd.fio_fn);
            l_ln := TOOLS.Clear_Name (rec_igd.fio_ln);
            l_mn := TOOLS.Clear_Name (rec_igd.fio_sn);
            l_gender :=
                CASE
                    WHEN rec_igd.igd_pol = '1' THEN 'M'
                    WHEN rec_igd.igd_pol = '2' THEN 'F'
                    ELSE 'V'
                END;
            l_nationality := -1;
            l_src_dt := rec_igd.lfd_create_dt;
            l_birth_dt :=
                TO_DATE (rec_igd.igd_drog DEFAULT NULL ON CONVERSION ERROR,
                         'dd.mm.yyyy');
            l_inn_num :=
                CASE
                    WHEN REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                    THEN
                        rec_igd.p_ipn
                    ELSE
                        NULL
                END;
            l_inn_ndt :=
                CASE
                    WHEN REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$') THEN 5
                    ELSE NULL
                END;                                          -- тип из архива
            l_doc_ser :=
                CASE
                    WHEN     rec_igd.p_doct = '1'
                         AND REGEXP_LIKE (rec_igd.p_docsn,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, 1, 2)
                    WHEN     rec_igd.p_doct = '3'
                         AND REGEXP_LIKE (
                                 rec_igd.p_docsn,
                                 '^[І|I|1]{1}{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, 1, 3)
                    WHEN     rec_igd.p_doct IN ('3', '5', '6')
                         AND REGEXP_LIKE (
                                 rec_igd.p_docsn,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, 1, 4)
                    ELSE
                        NULL
                END;
            l_doc_num :=
                CASE
                    WHEN     rec_igd.p_doct = '1'
                         AND REGEXP_LIKE (rec_igd.p_docsn,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, -6, 6)
                    WHEN     rec_igd.p_doct = '2'
                         AND REGEXP_LIKE (rec_igd.p_docsn, '^(\d){9}$')
                    THEN
                        rec_igd.p_docsn
                    WHEN     rec_igd.p_doct = '3'
                         AND REGEXP_LIKE (
                                 rec_igd.p_docsn,
                                 '^[І|I|1]{1}{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, -6, 6)
                    WHEN     rec_igd.p_doct IN ('3', '5', '6')
                         AND REGEXP_LIKE (
                                 rec_igd.p_docsn,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                    THEN
                        SUBSTR (rec_igd.p_docsn, -6, 6)
                    ELSE
                        rec_igd.p_docsn
                END;
            l_doc_ndt :=
                CASE
                    WHEN rec_igd.p_doct = '1'
                    THEN
                        6
                    WHEN rec_igd.p_doct = '2'
                    THEN
                        7
                    WHEN rec_igd.p_doct IN ('3', '5', '6')
                    THEN
                        37
                    ELSE
                        CASE
                            WHEN NOT REGEXP_LIKE (
                                         NVL (
                                             NULLIF (rec_igd.p_ipn,
                                                     '0000000000'),
                                             '!'),
                                         '^(\d){10}$')
                            THEN
                                10192
                            ELSE
                                684
                        END
                END;
            l_doc_unzr := rec_igd.p_docunzr;
            l_doc_is := TRIM (rec_igd.p_docis);
            l_doc_bdt :=
                TO_DATE (rec_igd.p_docdt DEFAULT NULL ON CONVERSION ERROR,
                         'dd.mm.yyyy');
            l_doc_edt :=
                TO_DATE (rec_igd.p_docend DEFAULT NULL ON CONVERSION ERROR,
                         'dd.mm.yyyy');

            l_igd_sc_id :=
                uss_person.load$socialcard.Load_SC_Intrnl (
                    p_fn            => l_fn,
                    p_ln            => l_ln,
                    p_mn            => l_mn,
                    p_gender        => l_gender,
                    p_nationality   => l_nationality,
                    p_src_dt        => l_src_dt,
                    p_birth_dt      => l_birth_dt,
                    p_inn_num       => l_inn_num,
                    p_inn_ndt       => l_inn_ndt,
                    p_doc_ser       => l_doc_ser,
                    p_doc_num       => l_doc_num,
                    p_doc_ndt       => l_doc_ndt,
                    p_doc_unzr      => l_doc_unzr,
                    p_doc_is        => l_doc_is,
                    p_doc_bdt       => l_doc_bdt,
                    p_doc_edt       => l_doc_edt,
                    p_src           => l_src,
                    p_sc            => l_igd_sc_id,
                    p_sc_unique     => l_igd_sc_unique,
                    p_sc_scc        => l_igd_sc_scc,
                    p_Mode          => l_Mode);

            -- IC #104464 перевіряти по всім учасникам, яких завантажуємо, наявність рішень за останні 3 місяці
            IF     l_igd_sc_id > 0
               AND getLastDatePayment (l_igd_sc_id) >
                   ADD_MONTHS (SYSDATE, -3)
            -- Якщо є рішення в ЄІССС, у яких в PD_payment кінцева дата дії закінчується не раніше, ніж 3 місяці до міграції, тоді не змінюємо ПІБ.
            THEN
                NULL;
            ELSE
                l_Mode := 0;                    -- c_Mode_Search_Update_Create
                l_igd_sc_unique := NULL;
                l_igd_sc_scc := NULL;

                l_igd_sc_id :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn            => l_fn,
                        p_ln            => l_ln,
                        p_mn            => l_mn,
                        p_gender        => l_gender,
                        p_nationality   => l_nationality,
                        p_src_dt        => l_src_dt,
                        p_birth_dt      => l_birth_dt,
                        p_inn_num       => l_inn_num,
                        p_inn_ndt       => l_inn_ndt,
                        p_doc_ser       => l_doc_ser,
                        p_doc_num       => l_doc_num,
                        p_doc_ndt       => l_doc_ndt,
                        p_doc_unzr      => l_doc_unzr,
                        p_doc_is        => l_doc_is,
                        p_doc_bdt       => l_doc_bdt,
                        p_doc_edt       => l_doc_edt,
                        p_src           => l_src,
                        p_sc            => l_igd_sc_id,
                        p_sc_unique     => l_igd_sc_unique,
                        p_sc_scc        => l_igd_sc_scc,
                        p_Mode          => l_Mode);
            END IF;

            ---------------------------------------------------------------------------------------------------
            IF l_igd_sc_id > 0 OR l_igd_sc_id = -2
            THEN
                IF l_igd_sc_id = -2
                THEN
                    l_igd_sc_id := NULL;
                ELSE
                    -- заполнение идентификатора иждивенца
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_igd.lfdp_id,
                                     l_igd_sc_id,
                                     'USS_PERSON.SOCIALCARD');
                END IF;

                -- інформація по вулицям
                BEGIN
                      SELECT ns_id,
                             s.ns_kaot,
                             ns_name,
                             st.nsrt_name
                        INTO l_ns_id,
                             l_ns_kaot,
                             l_ns_name,
                             l_nsrt_name
                        FROM uss_ndi.v_ndi_street s
                             LEFT JOIN uss_ndi.v_ndi_street_type st
                                 ON s.ns_nsrt = st.nsrt_id
                       WHERE     s.ns_code = rec_igd.ls_adrul
                             AND TO_CHAR (s.ns_org) = rec_igd.ls_org
                             AND s.history_status = 'A'
                    ORDER BY ns_id
                       FETCH FIRST ROWS ONLY;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_ns_id := NULL;
                        l_ns_kaot := NULL;
                        l_ns_name := rec_igd.ls_adrul;
                        l_nsrt_name := NULL;
                END;

                /*https://redmine.med/issues/84285
                  по адресам, які ми отримуємо від АСОПД, передаємо дані по 2 та 3 типу адреси (V_DDN_SCA_TP) лише для заявника
                */
                IF rec_igd.igd_app_tp = 'Z' AND l_igd_sc_id > 0
                THEN
                    DECLARE
                        l_out_id   NUMBER;
                    BEGIN
                        l_out_id := NULL;
                        uss_person.Api$socialcard.Save_Sc_Address (
                            p_sca_sc          => l_igd_sc_id,
                            p_sca_tp          => 2,
                            p_sca_kaot        => l_ns_kaot,
                            p_sca_postcode    => rec_igd.ls_indots,
                            p_Sca_Region      => rec_igd.reg_name,
                            p_Sca_District    => rec_igd.raj_name,
                            p_sca_street      =>
                                l_nsrt_name || ' ' || l_ns_name,
                            p_sca_building    => rec_igd.ls_adrdom,
                            p_sca_block       => rec_igd.ls_adrkorp,
                            p_sca_apartment   => rec_igd.ls_adrkv,
                            p_sca_src         => '710',
                            p_sca_create_dt   => rec_igd.lfd_create_dt,
                            o_sca_id          => l_out_id);
                        l_out_id := NULL;
                        uss_person.Api$socialcard.Save_Sc_Address (
                            p_sca_sc          => l_igd_sc_id,
                            p_sca_tp          => 3,
                            p_sca_kaot        => l_ns_kaot,
                            p_sca_postcode    => rec_igd.ls_indots,
                            p_Sca_Region      => rec_igd.reg_name,
                            p_Sca_District    => rec_igd.raj_name,
                            p_sca_street      =>
                                l_nsrt_name || ' ' || l_ns_name,
                            p_sca_building    => rec_igd.ls_adrdom,
                            p_sca_block       => rec_igd.ls_adrkorp,
                            p_sca_apartment   => rec_igd.ls_adrkv,
                            p_sca_src         => '710',
                            p_sca_create_dt   => rec_igd.lfd_create_dt,
                            o_sca_id          => l_out_id);
                    END;
                END IF;

                -- IC #101375
                SELECT MIN (p.pdp_start_dt), MAX (p.pdp_stop_dt)
                  INTO l_pdp_start_dt, l_pdp_stop_dt
                  FROM pd_payment p
                 WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                INSERT INTO pd_family (pdf_id,
                                       pdf_sc,
                                       pdf_pd,
                                       pdf_birth_dt,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       history_status,
                                       pdf_src,
                                       pdf_tp)
                     VALUES (
                                NULL,
                                l_igd_sc_id,
                                p_pd_id,
                                TO_DATE (
                                    rec_igd.igd_drog
                                        DEFAULT NULL ON CONVERSION ERROR,
                                    'dd.mm.yyyy'),
                                l_pdp_start_dt,
                                l_pdp_stop_dt,
                                'A',
                                'MG',
                                'CALC')                -- uss_ndi.v_ddn_pdf_tp
                  RETURNING pdf_id
                       INTO l_pdf_id;

                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_igd.lfdp_id, l_pdf_id, 'USS_ESR.PD_FAMILY');

                l_pdp_start_dt := NULL;
                l_pdp_stop_dt := NULL;

                -- IC #87332
                -- PDD_KEY - должен попадать соотвествующий ид pdf_id. (учасник звернення)
                UPDATE pd_detail
                   SET pdd_key = l_pdf_id
                 WHERE     pdd_pdp IN (SELECT p.pdp_id
                                         FROM pd_payment p
                                        WHERE p.pdp_pd = p_pd_id)
                       AND pdd_key = rec_igd.lfdp_id;

                IF SQL%ROWCOUNT > 0
                THEN
                    -- IC #107312 При міграції справ по 901 послузі (КФН 523, 524) потрібно заповнювати по кожному терміну PD_Detail по учаснику заповнювати записи в PD_Family з періодом дії, який співпадає з PD_Detail
                    FOR c
                        IN (SELECT pd.pdd_id,
                                   pd.pdd_start_dt,
                                   pd.pdd_stop_dt,
                                   pt.npt_code,
                                   ROW_NUMBER () OVER (ORDER BY pd.pdd_id)    rn
                              FROM uss_esr.pd_payment  p
                                   INNER JOIN uss_esr.pd_detail pd
                                       ON     pd.pdd_pdp = p.pdp_id
                                          AND pd.pdd_key = l_pdf_id
                                   INNER JOIN uss_ndi.v_ndi_payment_type pt
                                       ON pt.npt_id = pd.pdd_npt
                             WHERE     p.pdp_pd = p_pd_id
                                   AND pt.npt_code IN ('523', '524'))
                    LOOP
                        IF c.rn = 1
                        THEN
                            UPDATE pd_family
                               SET pdf_start_dt = c.pdd_start_dt,
                                   pdf_stop_dt = c.pdd_stop_dt
                             WHERE pdf_id = l_pdf_id;
                        ELSE
                            INSERT INTO pd_family (pdf_id,
                                                   pdf_sc,
                                                   pdf_pd,
                                                   pdf_birth_dt,
                                                   pdf_start_dt,
                                                   pdf_stop_dt,
                                                   history_status,
                                                   pdf_src,
                                                   pdf_tp)
                                 VALUES (
                                            NULL,
                                            l_igd_sc_id,
                                            p_pd_id,
                                            TO_DATE (
                                                rec_igd.igd_drog
                                                    DEFAULT NULL ON CONVERSION ERROR,
                                                'dd.mm.yyyy'),
                                            c.pdd_start_dt,
                                            c.pdd_stop_dt,
                                            'A',
                                            'MG',
                                            'CALC')    -- uss_ndi.v_ddn_pdf_tp
                              RETURNING pdf_id
                                   INTO l_pdf_id;

                            UPDATE uss_esr.pd_detail
                               SET pdd_key = l_pdf_id
                             WHERE pdd_id = c.pdd_id;
                        END IF;

                        -- IC #108633 При міграції допомоги з КФН = 523 додавати документ
                        IF     rec_igd.igd_app_tp != 'Z'
                           AND l_ls_kfn = '523'
                           AND c.npt_code = '524'
                           AND l_pdp_start_dt IS NOT NULL
                        THEN
                            l_pdp_start_dt :=
                                LEAST (c.pdd_start_dt, l_pdp_start_dt);
                            l_pdp_stop_dt :=
                                GREATEST (c.pdd_stop_dt, l_pdp_stop_dt);
                        END IF;
                    END LOOP;
                END IF;


                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             21,
                             rec_igd.igd_nomig,
                             l_pdf_id);

                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             34,
                             rec_igd.igd_katnetr,
                             l_pdf_id);

                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             36,
                             rec_igd.igd_fio,
                             l_pdf_id);

                IF rec_igd.igd_psn <> '0'
                THEN
                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_val_dt,
                                             pde_pdf)
                             VALUES (
                                        NULL,
                                        p_pd_id,
                                        35,
                                        'T',
                                        TO_DATE (
                                            rec_igd.igd_dso
                                                DEFAULT NULL ON CONVERSION ERROR,
                                            'dd.mm.yyyy'),
                                        l_pdf_id);
                END IF;

                --+++++++++++++++++++++++++++++++++++++++++ ДОПОЛНЕНИЕ К ЗВЕРНЕННЮ
                DECLARE
                    l_app_id         NUMBER;
                    l_apd_600_id     NUMBER;
                    l_apd_605_id     NUMBER;
                    l_apd_661_id     NUMBER;
                    l_apd_662_id     NUMBER;
                    l_inv_cnt        NUMBER;

                    l_apd_5_id       NUMBER;
                    l_apd_6_id       NUMBER;
                    l_apd_7_id       NUMBER;
                    l_apd_37_id      NUMBER;

                    l_apd_200_id     NUMBER;
                    l_apd_201_id     NUMBER;
                    l_apd_114_id     NUMBER;
                    l_apd_10192_id   NUMBER;
                    l_apd_92_id      NUMBER;
                    l_apd_10205_id   NUMBER;

                    l_apda_790       NUMBER := 0;
                BEGIN
                    IF l_igd_sc_scc IS NULL
                    THEN
                        SELECT Sc_Scc
                          INTO l_igd_sc_scc
                          FROM uss_person.v_Socialcard Sc
                         WHERE Sc.Sc_Id = l_igd_sc_id;
                    END IF;

                    INSERT INTO ap_person (app_id,
                                           app_ap,
                                           app_sc,
                                           app_tp,
                                           history_status,
                                           app_scc)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_igd_sc_id,
                                 rec_igd.igd_app_tp,
                                 'A',
                                 l_igd_sc_scc)
                      RETURNING app_id
                           INTO l_app_id;

                    -- IC #108633
                    -- документ 10205 (Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя) для кожної дитини, по якій прописано КФН 524.
                    -- Заповнювати дату першої появи дитини (саме мінімальну), як 2688 (Дата влаштування дитини у сім’ю патронатного вихователя)
                    -- саму максимальну дату відповідно записувати, як 2689 (Дата вибуття дитини зі сім'ї патронатного вихователя)
                    IF l_pdp_start_dt IS NOT NULL
                    THEN
                        SELECT MAX (apd_id)
                          INTO l_apd_10205_id
                          FROM ap_document
                         WHERE     apd_ap = p_ap_id
                               AND apd_app = l_app_id
                               AND apd_ndt = 10205
                               AND history_status = 'A';

                        IF l_apd_10205_id IS NULL
                        THEN
                            INSERT INTO ap_document (apd_id,
                                                     apd_ap,
                                                     apd_app,
                                                     apd_ndt,
                                                     history_status,
                                                     apd_aps)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_app_id,
                                         10205,
                                         'A',
                                         p_aps_id)
                              RETURNING apd_id
                                   INTO l_apd_10205_id;

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_dt,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_10205_id,
                                         2688,
                                         l_pdp_start_dt,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_dt,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_10205_id,
                                         2689,
                                         l_pdp_stop_dt,
                                         'A');
                        ELSE
                            UPDATE ap_document_attr
                               SET apda_val_dt = l_pdp_start_dt
                             WHERE     apda_ap = p_ap_id
                                   AND apda_apd = l_apd_10205_id
                                   AND apda_nda = 2688
                                   AND history_status = 'A';

                            IF SQL%ROWCOUNT = 0
                            THEN
                                INSERT INTO ap_document_attr (apda_id,
                                                              apda_ap,
                                                              apda_apd,
                                                              apda_nda,
                                                              apda_val_dt,
                                                              history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_10205_id,
                                             2688,
                                             l_pdp_start_dt,
                                             'A');
                            END IF;

                            UPDATE ap_document_attr
                               SET apda_val_dt = l_pdp_start_dt
                             WHERE     apda_ap = p_ap_id
                                   AND apda_apd = l_apd_10205_id
                                   AND apda_nda = 2689
                                   AND history_status = 'A';

                            IF SQL%ROWCOUNT = 0
                            THEN
                                INSERT INTO ap_document_attr (apda_id,
                                                              apda_ap,
                                                              apda_apd,
                                                              apda_nda,
                                                              apda_val_dt,
                                                              history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_10205_id,
                                             2689,
                                             l_pdp_stop_dt,
                                             'A');
                            END IF;
                        END IF;
                    END IF;

                    -- IC #108866
                    -- по послузі 275
                    IF p_nptc_nst = 275
                    THEN
                        FOR c
                            IN (SELECT MIN (
                                           CASE
                                               WHEN pd.pdd_npt = 835
                                               THEN
                                                   pd.pdd_start_dt
                                           END)    pdd_start_dt_662,
                                       MIN (
                                           CASE
                                               WHEN pd.pdd_npt = 836
                                               THEN
                                                   pd.pdd_start_dt
                                           END)    pdd_start_dt_661
                                  FROM uss_esr.pd_payment  p
                                       INNER JOIN uss_esr.pd_detail pd
                                           ON     pd.pdd_pdp = p.pdp_id
                                              AND pd.pdd_npt IN (835, 836)
                                       INNER JOIN uss_esr.pd_family f
                                           ON     f.pdf_id = pd.pdd_key
                                              AND f.pdf_pd = p_pd_id
                                              AND f.pdf_sc = l_igd_sc_id
                                 WHERE     p.pdp_pd = p_pd_id
                                       AND p.history_status = 'A'
                                       AND EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.pd_payment  p1,
                                                       uss_esr.pd_detail pd1
                                                 WHERE     p1.pdp_pd =
                                                           p_pd_id
                                                       AND p1.pdp_id =
                                                           pd1.pdd_pdp
                                                       AND pd1.pdd_npt = 837)
                                       AND NOT EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.ap_document ad
                                                 WHERE     ad.apd_ap =
                                                           p_ap_id
                                                       AND ad.apd_app =
                                                           l_app_id
                                                       AND ad.history_status =
                                                           'A'
                                                       AND ad.apd_ndt =
                                                           CASE
                                                               WHEN pd.pdd_npt =
                                                                    835
                                                               THEN
                                                                   662
                                                               ELSE
                                                                   661
                                                           END))
                        LOOP
                            -- якщо є pdd_npt = 835, тоді документ ІД = 662, де вказати обов'язково атрибут 2667 (дата першої появи дитини в детейле);
                            IF c.pdd_start_dt_662 IS NOT NULL
                            THEN
                                INSERT INTO uss_esr.ap_document (
                                                apd_id,
                                                apd_ap,
                                                apd_app,
                                                apd_ndt,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_app_id,
                                             662,
                                             'A')
                                  RETURNING apd_id
                                       INTO l_apd_662_id;

                                INSERT INTO uss_esr.ap_document_attr (
                                                apda_id,
                                                apda_ap,
                                                apda_apd,
                                                apda_nda,
                                                apda_val_dt,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_662_id,
                                             2667,
                                             c.pdd_start_dt_662,
                                             'A');
                            END IF;

                            -- якщо є pdd_npt = 836, тоді документ ІД = 661, де вказати обов'язково атрибут 2666 (дата першої появи дитини в детейле).
                            IF c.pdd_start_dt_661 IS NOT NULL
                            THEN
                                INSERT INTO uss_esr.ap_document (
                                                apd_id,
                                                apd_ap,
                                                apd_app,
                                                apd_ndt,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_app_id,
                                             661,
                                             'A')
                                  RETURNING apd_id
                                       INTO l_apd_661_id;

                                INSERT INTO uss_esr.ap_document_attr (
                                                apda_id,
                                                apda_ap,
                                                apda_apd,
                                                apda_nda,
                                                apda_val_dt,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_661_id,
                                             2667,
                                             c.pdd_start_dt_661,
                                             'A');
                            END IF;
                        END LOOP;
                    END IF;

                    -----------------  600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600 600
                    --https://redmine.med/redmine/issues/82856
                    IF rec_igd.igd_nomig = 0 AND p_nptc_nst <> 664
                    THEN
                        BEGIN
                            INSERT INTO ap_document (apd_id,
                                                     apd_ap,
                                                     apd_app,
                                                     apd_ndt,
                                                     history_status,
                                                     apd_aps)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_app_id,
                                         600,
                                         'A',
                                         p_aps_id)
                              RETURNING apd_id
                                   INTO l_apd_600_id;

                            -- https://redmine.medirent.com.ua/issues/83618
                            --insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                            --values (Null,p_ap_id,l_apd_600_id,788,rec_igd.ns_name,'A');--788 - назва вулиці, якщо не знайдена в довіднику ЄІССС, у поле APDA_VAL_String (з поля Ls_Adrul масиву Ls)

                            -- https://redmine.medirent.com.ua/issues/83618
                            -- 585  Вулиця адреси реєстрації (довідник)
                            -- 597  Вулиця адреси проживання (довідник)
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_id,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         585,
                                         l_ns_id,
                                         l_nsrt_name || ' ' || l_ns_name,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_id,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         597,
                                         l_ns_id,
                                         l_nsrt_name || ' ' || l_ns_name,
                                         'A');

                            -- https://redmine.medirent.com.ua/issues/83618
                            -- 584  Будинок адреси реєстрації
                            -- 596  Будинок адреси проживання
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         596,
                                         rec_igd.ls_adrdom,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         584,
                                         rec_igd.ls_adrdom,
                                         'A');

                            -- https://redmine.medirent.com.ua/issues/83618
                            -- 583  Корпус адреси реєстрації
                            -- 595  Корпус адреси проживання
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         583,
                                         rec_igd.ls_adrkorp,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         595,
                                         rec_igd.ls_adrkorp,
                                         'A');

                            -- https://redmine.medirent.com.ua/issues/83618
                            --582  Квартира адреси реєстрації
                            --594  Квартира адреси проживання
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         582,
                                         rec_igd.ls_adrkv,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         594,
                                         rec_igd.ls_adrkv,
                                         'A');

                            -- https://redmine.medirent.com.ua/issues/83618
                            -- 587  Індекс адреси реєстрації
                            -- 599  Індекс адреси проживання
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_600_id,
                                                587,
                                                TO_NUMBER (
                                                    rec_igd.ls_indots
                                                        DEFAULT NULL ON CONVERSION ERROR),
                                                'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_id,
                                                          apda_val_string,
                                                          history_status)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_600_id,
                                                599,
                                                TO_NUMBER (
                                                    rec_igd.ls_indots
                                                        DEFAULT NULL ON CONVERSION ERROR),
                                                rec_igd.ls_indots,
                                                'A');

                            -- --605 - № телефону з поля MobTel масиву Ls
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         605,
                                         rec_igd.mobtel,
                                         'A');

                            --667 - дата народження з поля Ls_Drog масиву Ls
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_dt,
                                                          history_status)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_600_id,
                                                667,
                                                TO_DATE (
                                                    rec_igd.igd_drog
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy'),
                                                'A');

                            -- IC #85426
                            -- y документ 600 записуємо атрибути:
                            -- 588 Район адреси реєстрації
                            -- 600 Район адреси проживання
                            -- 589 Область адреси реєстрації
                            -- 601 Область адреси проживання
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         588,
                                         rec_igd.raj_name,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         600,
                                         rec_igd.raj_name,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         589,
                                         rec_igd.reg_name,
                                         'A');

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_600_id,
                                         601,
                                         rec_igd.reg_name,
                                         'A');
                        END;
                    END IF;

                    ------------------------------ 605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605
                    INSERT INTO ap_document (apd_id,
                                             apd_ap,
                                             apd_app,
                                             apd_ndt,
                                             history_status,
                                             apd_aps)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_app_id,
                                 605,
                                 'A',
                                 p_aps_id)
                      RETURNING apd_id
                           INTO l_apd_605_id;

                    -- адреса
                    IF rec_igd.igd_nomig = 0
                    THEN
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1780,
                                     rec_igd.ls_adrkv,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1781,
                                     l_ns_kaot,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_id,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1783,
                                     l_ns_id,
                                     l_ns_name,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1784,
                                     rec_igd.ls_adrdom,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1787,
                                     rec_igd.ls_adrkorp,
                                     'A');
                    END IF;

                    -- 1772 605 Заявник - особа з інвалідністю
                    SELECT COUNT (*)
                      INTO l_inv_cnt
                      FROM uss_exch.v_ls_inv_data i
                     WHERE     i.lfd_lfd = rec_igd.lfd_lfd
                           AND i.ls_nls = rec_igd.ls_nls
                           AND i.Inv_Nomig = rec_igd.igd_nomig;

                    IF l_inv_cnt > 0
                    THEN
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1772,
                                     'T',
                                     'A');
                    END IF;

                    -- 649  605 Ступінь родинного зв’язку
                    INSERT INTO ap_document_attr (apda_id,
                                                  apda_ap,
                                                  apda_apd,
                                                  apda_nda,
                                                  apda_val_string,
                                                  history_status)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_apd_605_id,
                                 649,
                                 rec_igd.igd_apd_katrod,
                                 'A');

                    -- ONLY VPO
                    IF     rec_igd.igd_nomig = 0
                       AND TO_DATE (
                               rec_igd.igd_drog
                                   DEFAULT NULL ON CONVERSION ERROR,
                               'dd.mm.yyyy')
                               IS NOT NULL
                       AND p_nptc_nst = 664
                    THEN
                        -- 1768 605 Внутрішньо переміщена особа (повнолітня)
                        -- 1770 605 Внутрішньо переміщена особа (неповнолітня)
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_605_id,
                                            CASE
                                                WHEN ADD_MONTHS (
                                                         TO_DATE (
                                                             rec_igd.igd_drog,
                                                             'dd.mm.yyyy'),
                                                         18 * 12) >
                                                     p_np_dnprav
                                                THEN
                                                    1770
                                                WHEN ADD_MONTHS (
                                                         TO_DATE (
                                                             rec_igd.igd_drog,
                                                             'dd.mm.yyyy'),
                                                         18 * 12) <=
                                                     p_np_dnprav
                                                THEN
                                                    1768
                                            END,
                                            'T',
                                            'A');
                    END IF;

                    IF NOT REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                    THEN
                        -- 640  605 Відмова від використання РНОКПП
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     640,
                                     'T',
                                     'A');

                        -- 812  605 Відмова від використання РНОКПП
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     812,
                                     'T',
                                     'A');
                    ELSIF REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                    THEN
                        -- INN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     5,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_5_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_5_id,
                                     1,
                                     rec_igd.p_ipn,
                                     'A');
                    END IF;

                    -- https://redmine.medirent.com.ua/issues/82475
                    IF     rec_igd.ls_rab = 6
                       AND rec_igd.igd_nomig = 0
                       AND p_nptc_nst IN (248, 249, 267)
                    THEN
                        -- для 248 : 663 Не працює - якщо в масиві BLS LS_rab = 6, то ставимо "T"
                        -- для 249 : 663 Не працює - якщо в масиві BLS LS_rab = 6, то ставимо "T"
                        IF p_nptc_nst IN (248, 249)
                        THEN
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         663,
                                         'T',
                                         'A');
                        END IF;

                        IF p_nptc_nst IN (267)
                        THEN
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         650,
                                         'T',
                                         'A');
                        END IF;
                    END IF;

                    -- НА ОСНОВАНИИ ВИДОС
                    -- https://redmine.medirent.com.ua/issues/82475
                    --https://redmine.medirent.com.ua/issues/83763
                    -- IC #92698
                    IF p_nptc_nst = 248 AND rec_igd.igd_nomig = 0
                    THEN
                        FOR rec_vidos
                            IN (SELECT v.*,
                                       CASE v.vidos_priz
                                           WHEN '3' THEN 653 -- Доглядає за дитиною до 3-х років
                                           WHEN '4' THEN 865 -- Перебуває у відпустці у зв’язку з вагітністю та пологами
                                           WHEN '5' THEN 866 -- Перебуває у відпустці без збереження заробітної плати
                                       END                            apda_nda,
                                       CASE v.vidos_priz
                                           WHEN '3' THEN 84
                                           WHEN '4' THEN 86
                                           WHEN '5' THEN 88
                                       END                            pde_nft_b,
                                       CASE v.vidos_priz
                                           WHEN '3' THEN 85
                                           WHEN '4' THEN 87
                                           WHEN '5' THEN 89
                                       END                            pde_nft_e,
                                       TO_DATE (
                                           v.vidos_dateb
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy')              vidos_date_b,
                                       TO_DATE (
                                           v.vidos_datee
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy')              vidos_date_e,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY v.vidos_code,
                                                            v.vidos_priz
                                               ORDER BY
                                                   TO_DATE (
                                                       v.vidos_dateb
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy') DESC NULLS LAST,
                                                   TO_DATE (
                                                       v.vidos_datee
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy') DESC,
                                                   v.lfdp_id DESC)    rnn
                                  FROM uss_exch.v_ls_vidos_data v
                                 WHERE     lfd_lfd = rec_igd.lfd_lfd
                                       AND ls_nls = rec_igd.ls_nls)
                        LOOP
                            /* -- IC #84501
                                if (  -- https://redmine.medirent.com.ua/issues/83763
                                      -- 641 Одинока/одинокий - перевірити, щоб лише для заявника
                                    (rec_vidos.vidos_code in ('4') and rec_vidos.vidos_priz = '1' and rec_igd.igd_nomig = 0)
                                    or
                                    (rec_vidos.vidos_code in ('222','223','224','225') and rec_igd.igd_nomig = 0)
                                    ) then
                                  -- 641 Одинока/одинокий - проставляємо "T"
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status) values (Null,p_ap_id,l_apd_605_id,641,'T','A');
                                end if;

                                --https://redmine.medirent.com.ua/issues/83763
                                -- 642 Опікун - проставляємо "T",якщо в базі BVIDOS VidOs_Code = 226 (лише для заявника)
                                if rec_vidos.VidOs_Code = 226 and rec_igd.igd_nomig = 0 then
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                                  values (Null,p_ap_id,l_apd_605_id,642,'T','A');
                                end if;

                                --https://redmine.medirent.com.ua/issues/83763
                                --Для інших учасників проставляти в такому випадку в атрибут 649 значення CHRG (підопічний)
                                if rec_vidos.VidOs_Code = 226 and rec_igd.igd_nomig <> 0 then
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                                  values (Null,p_ap_id,l_apd_605_id,649,'CHRG','A');
                                end if;

                                --https://redmine.medirent.com.ua/issues/83763
                                -- 645 Особа з інвалідністю з дитинства - проставляємо "T",якщо в базі BVIDOS VidOs_Code = 221 (лише для заявника)
                                if rec_vidos.VidOs_Code = 221 and rec_igd.igd_nomig = 0 then
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                                  values (Null,p_ap_id,l_apd_605_id,645,'T','A');
                                end if;

                                --https://redmine.medirent.com.ua/issues/83763
                                -- 645 Особа з інвалідністю з дитинства - проставляємо "T",якщо в базі BVIDOS VidOs_Code = 221 (лише для заявника)
                                if rec_vidos.VidOs_Code = 222 and rec_igd.igd_nomig = 0 then
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                                  values (Null,p_ap_id,l_apd_605_id,646,'T','A');
                                end if;

                                -- 653 Доглядає за дитиною до 3-х років - якщо в базі BVIDOS VidOs_Code = 147, VidOs_Priz = 3 та дата в ПЕР передостаннього рядка між датами (VidOs_DateB; VidOs_DateE), то ставимо "T"
                                if rec_vidos.vidos_code in ('147')
                                   and rec_igd.igd_nomig = 0
                                   and rec_vidos.vidos_priz in ('3')
                                   and trunc(sysdate) between to_date(rec_vidos.VidOs_DateB, 'dd.mm.yyyy')
                                   and to_date(rec_vidos.VidOs_DateE, 'dd.mm.yyyy') then
                                  -- 653 Доглядає за дитиною до 3-х років
                                  -- 865 Перебуває у відпустці у зв’язку з вагітністю та пологами
                                  -- 866 Перебуває у відпустці без збереження заробітної плати
                                  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status)
                                  values (Null,p_ap_id,l_apd_605_id, 653,'T','A');
                                end if;
                                  */

                            -- IC #93864
                            IF     rec_vidos.vidos_code IN ('147')
                               AND rec_vidos.vidos_priz IN ('3', '4', '5')
                               AND rec_vidos.rnn = 1
                            THEN
                                INSERT INTO ap_document_attr (
                                                apda_id,
                                                apda_ap,
                                                apda_apd,
                                                apda_nda,
                                                apda_val_string,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_605_id,
                                             rec_vidos.apda_nda,
                                             'T',
                                             'A');

                                INSERT INTO uss_esr.pd_features (pde_id,
                                                                 pde_pd,
                                                                 pde_nft,
                                                                 pde_val_dt,
                                                                 pde_pdf)
                                     VALUES (NULL,
                                             p_pd_id,
                                             rec_vidos.pde_nft_b,
                                             rec_vidos.vidos_date_b,
                                             l_pdf_id);

                                INSERT INTO uss_esr.pd_features (pde_id,
                                                                 pde_pd,
                                                                 pde_nft,
                                                                 pde_val_dt,
                                                                 pde_pdf)
                                     VALUES (NULL,
                                             p_pd_id,
                                             rec_vidos.pde_nft_e,
                                             rec_vidos.vidos_date_e,
                                             l_pdf_id);
                            END IF;
                        END LOOP;
                    END IF;

                    -- IC #84501
                    -- НА ОСНОВАНИИ BOSOB
                    l_is_child := '';
                    l_nls_child := '';

                    IF p_nptc_nst IN (248,
                                      249,
                                      265,
                                      267,
                                      268,
                                      275)
                    THEN
                        FOR rec_osob
                            IN (SELECT *
                                  FROM uss_exch.v_ls_osob_data v
                                 WHERE     lfd_lfd = rec_igd.lfd_lfd
                                       AND ls_nls = rec_igd.ls_nls)
                        LOOP
                            -- IC #100542
                            IF p_nptc_nst = 275
                            THEN
                                IF rec_osob.osob_code IN ('28', '29')
                                THEN
                                    -- Код особливості B_osob 28 - це основна справа , 29 - це виділена справа
                                    l_is_child := rec_osob.osob_code;
                                END IF;

                                -- Код особливості B_osob 252 це перші три цифри номеру особового рахунку основної або виділеної справи,
                                IF rec_osob.osob_code = '252'
                                THEN
                                    l_nls_child :=
                                        rec_osob.osob_priz || l_nls_child;
                                END IF;

                                -- Код особливості B_osob 253 - це останні три цифри номеру особового рахунку основної або виділеної справи.
                                IF rec_osob.osob_code = '253'
                                THEN
                                    l_nls_child :=
                                        l_nls_child || rec_osob.osob_priz;
                                END IF;
                            END IF;

                            IF p_nptc_nst = 248
                            THEN
                                IF ( -- 641 Одинока/одинокий (лише для заявника) - проставляємо "T",якщо в базі BOSOB
                                       (    rec_osob.osob_code IN ('4') /*and rec_osob.osob_priz = '1'*/
                                        AND rec_igd.igd_nomig = 0)
                                    OR (    rec_osob.osob_code IN ('222',
                                                                   '223',
                                                                   '224',
                                                                   '225')
                                        AND rec_igd.igd_nomig = 0))
                                THEN
                                    -- 641 Одинока/одинокий - проставляємо "T"
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 641,
                                                 'T',
                                                 'A');
                                END IF;

                                -- #92698
                                -- 642 Опікун - проставляємо "T",якщо в базі BOSOB Osob_Code in (226) (лише для заявника)
                                IF     rec_osob.osob_Code IN ('226')
                                   AND rec_igd.igd_nomig = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 642,
                                                 'T',
                                                 'A');
                                END IF;

                                -- Для інших учасників проставляти в такому випадку в атрибут 649 значення CHRG (підопічний)
                                IF     rec_osob.osob_Code IN ('226')
                                   AND rec_igd.igd_nomig <> 0
                                THEN
                                    UPDATE ap_document_attr       -- IC #84625
                                       SET apda_val_string = 'CHRG'
                                     WHERE     history_status = 'A'
                                           AND apda_ap = p_ap_id
                                           AND apda_apd = l_apd_605_id
                                           AND apda_nda = 649;

                                    IF SQL%ROWCOUNT = 0
                                    THEN
                                        INSERT INTO ap_document_attr (
                                                        apda_id,
                                                        apda_ap,
                                                        apda_apd,
                                                        apda_nda,
                                                        apda_val_string,
                                                        history_status)
                                             VALUES (NULL,
                                                     p_ap_id,
                                                     l_apd_605_id,
                                                     649,
                                                     'CHRG',
                                                     'A');
                                    END IF;
                                END IF;

                                -- 645 Особа з інвалідністю з дитинства - проставляємо "T",якщо в базі BOSOB Osob_Code = 221 (лише для заявника)
                                IF     rec_osob.osob_Code = '221'
                                   AND rec_igd.igd_nomig = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 645,
                                                 'T',
                                                 'A');
                                END IF;

                                -- 646 Мати/батько - проставляємо "T",якщо в базі BOSOB Osob_Code = 222 (лише для заявника)
                                IF     rec_osob.osob_Code = '222'
                                   AND rec_igd.igd_nomig = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 646,
                                                 'T',
                                                 'A');
                                END IF;

                                -- 790 потребує постійного стороннього догляду - проставляємо "T",якщо в базі BOSOB Osob_Code = 4 с Osob_Priz = 1
                                -- але для 201 документу
                                -- IC #85110 неважливо, що проставлено в Osob_Priz
                                IF rec_osob.osob_code IN ('4') /*and rec_osob.osob_priz = '1'*/
                                THEN
                                    l_apda_790 := 790;
                                END IF;

                                -- если Osob_Code = 70 та Osob_Priz = 0, тоді треба робити документ 10117, та обнуляти РНОКПП по СРКО

                                IF     rec_osob.osob_code IN ('70')
                                   AND rec_osob.osob_priz = '0'
                                THEN
                                    --Зберігаємо документ
                                    l_attrs :=
                                        uss_person.api$socialcard.t_doc_attrs ();
                                    uss_person.api$socialcard.save_document (
                                        p_sc_id       => l_igd_sc_id,
                                        p_ndt_id      => 10117,
                                        p_doc_attrs   => l_attrs,
                                        p_src_id      => 710,
                                        p_src_code    => 'ASOPD',
                                        p_scd_note    =>
                                               'lfd_lfd = '
                                            || p_lfd_lfd
                                            || '; ls_nls = '
                                            || p_ls_nls,
                                        p_scd_id      => l_scd_id,
                                        p_scd_dh      => l_scd_dh);
                                END IF;
                            END IF;                        -- p_nptc_nst = 248

                            -- IC #96561
                            -- Якщо по ОР встановлено в масиві BOSOB особливість 303 або 451 в полі OSOB_CODE, тоді потрібно в мігрованих зверненнях в ЄСР прописати:
                            -- добавляй по усім учасникам, не тільки по заявнику
                            IF rec_osob.osob_Code IN ('303', '451')
                            THEN
                                -- 2658 - Особа, яка проживає і працює (навчається) на території гірського населеного пункту в значення "T".
                                UPDATE ap_document_attr
                                   SET apda_val_string = 'T'
                                 WHERE     apda_ap = p_ap_id
                                       AND apda_apd = l_apd_605_id
                                       AND apda_nda = 2658
                                       AND history_status = 'A';

                                IF SQL%ROWCOUNT = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 2658,
                                                 'T',
                                                 'A');
                                END IF;

                                -- 92 Документи про надання статусу особи, яка проживає, працює на території населеного пункту, якому надано статус гірського (атрибути неважливі, можна не створювати)
                                SELECT MAX (apd_id)
                                  INTO l_apd_92_id
                                  FROM uss_esr.ap_document d
                                 WHERE     d.apd_ndt = 92
                                       AND d.apd_ap = p_ap_id
                                       AND d.apd_app = l_app_id
                                       AND d.history_status = 'A';

                                IF NVL (l_apd_92_id, 0) = 0
                                THEN
                                    INSERT INTO uss_esr.ap_document (
                                                    apd_id,
                                                    apd_ap,
                                                    apd_app,
                                                    apd_ndt,
                                                    history_status,
                                                    apd_aps)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_app_id,
                                                 92,
                                                 'A',
                                                 p_aps_id)
                                      RETURNING apd_id
                                           INTO l_apd_92_id;
                                END IF;
                            END IF;     -- rec_osob.osob_Code in ('303','451')
                        END LOOP;                   -- uss_exch.v_ls_osob_data
                    END IF;    -- p_nptc_nst in (248, 249, 265, 267, 268, 275)

                    IF l_is_child = '28'
                    THEN
                        UPDATE appeal
                           SET ap_ap_main = p_ap_id
                         WHERE     ap_num =
                                   rec_igd.ls_org || '_' || l_nls_child
                               AND ap_src = 'ASOPD';
                    END IF;

                    IF l_is_child = '29'
                    THEN
                           UPDATE appeal
                              SET ap_ap_main =
                                      (SELECT MAX (a.ap_id)
                                         FROM appeal a
                                        WHERE     a.ap_num =
                                                     rec_igd.ls_org
                                                  || '_'
                                                  || l_nls_child
                                              AND a.ap_src = 'ASOPD')
                            WHERE ap_id = p_ap_id
                        RETURNING ap_ap_main
                             INTO l_ap_main;

                        -- IC #111168 Змінити міграцію по допомозі 275, якщо ми заповнюємо поле AP_AP_MAIN
                        UPDATE ap_person
                           SET app_tp = 'ANF'
                         WHERE     app_ap = p_ap_id
                               AND app_tp = 'Z'
                               AND p_nptc_nst = 275;

                        IF SQL%ROWCOUNT > 0
                        THEN
                            INSERT INTO uss_esr.ap_person (app_id,
                                                           app_ap,
                                                           app_sc,
                                                           app_tp,
                                                           history_status,
                                                           app_vf,
                                                           app_scc,
                                                           app_num)
                                SELECT NULL          app_id,
                                       l_ap_main     app_ap,
                                       app_sc,
                                       app_tp,
                                       history_status,
                                       app_vf,
                                       app_scc,
                                       app_num
                                  FROM uss_esr.ap_person pp
                                 WHERE     app_ap = p_ap_id
                                       AND app_tp = 'ANF'
                                       AND NOT EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.ap_person p
                                                 WHERE     p.app_ap =
                                                           l_ap_main
                                                       AND p.app_sc =
                                                           pp.app_sc
                                                       AND p.app_tp = 'ANF');
                        END IF;
                    END IF;

                    ------------------------------ 605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605  605

                    IF rec_igd.p_doct = '1'
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     6,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_6_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     3,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     5,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     7,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_6_id,
                                            606,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2373,
                                     rec_igd.fio_sn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2374,
                                     rec_igd.fio_fn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2375,
                                     rec_igd.fio_ln,
                                     'A');
                    ELSIF rec_igd.p_doct = '2'
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     7,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_7_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     9,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_7_id,
                                            10,
                                            TO_DATE (rec_igd.p_docend,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     13,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     14,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_7_id,
                                            607,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     810,
                                     rec_igd.p_docunzr,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2378,
                                     rec_igd.fio_sn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2377,
                                     rec_igd.fio_fn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2376,
                                     rec_igd.fio_ln,
                                     'A');
                    ELSIF rec_igd.p_doct IN ('3', '5', '6')
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     37,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_37_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     90,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_37_id,
                                            91,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     92,
                                     rec_igd.igd_fio,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     93,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     94,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     2293,
                                     'АСОПД',
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     2294,
                                     SYSDATE,
                                     'A');
                    ELSIF rec_igd.p_doct = '4'
                    THEN
                        -- IC #84973 Для типу документу 4 створюємо документ 10192 "Документ з АСОПД
                        -- 2566 Серія та номер документу - в масиві LS та IGD поле P_DocSN
                        -- 2567 Дата видачі - в масиві LS та IGD поле P_DocDt
                        -- 2568 Ким видано - в масиві LS та IGD поле P_DocIs
                        -- 2569 дата закінчення дії - в масиві LS та IGD поле P_DocEnd
                        -- 2570 Дата народження - в масиві LS поле Ls_Drog та IGD поле Igd_Drog
                        --            insert into ap_document (apd_id,apd_ap,apd_app,apd_ndt,history_status,apd_aps) values(Null,p_ap_id,l_app_id,601,'A',p_aps_id) returning apd_id into l_apd_601_id;
                        --            insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,apda_val_string,history_status) values (Null,p_ap_id,l_apd_601_id,90,rec_igd.p_docsn,'A');
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     10192,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_10192_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_10192_id,
                                     2566,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_10192_id,
                                     2567,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_10192_id,
                                     2568,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_10192_id,
                                            2569,
                                            TO_DATE (rec_igd.p_docend,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_10192_id,
                                            2570,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');
                    END IF;

                    ------------------- СПЕЦИФИКА 6 УСЛУГ
                    --- ПО МАССИВУ ИНВЛИДНОСТЬ
                    FOR rec_inv
                        IN (  SELECT inv.*
                                FROM uss_exch.v_ls_inv_data inv
                               WHERE     inv.ls_nls = rec_igd.ls_nls
                                     AND inv.lfd_lfd = rec_igd.lfd_lfd
                                     AND inv.Inv_Nomig = rec_igd.igd_nomig
                            ORDER BY TO_DATE (
                                         inv.Inv_Dnpi
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy') DESC,
                                     inv.rn DESC
                               FETCH FIRST ROWS ONLY)
                    LOOP
                        IF rec_inv.inv_grinv IN ('5', '11')
                        THEN
                            --++++++++++++++ 605 605 605 605 605 605 605 605 605
                            -- https://redmine.medirent.com.ua/issues/83763
                            -- DI - Дитина з інвалідністю - Якщо є запис по учаснику звернення в таблиці BINV Inv_Grinv = (5, 11)
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         796,
                                         'DI',
                                         'A');

                            --++++++++++++++ 200 200 200 200 200 200 200 200 200
                            INSERT INTO ap_document (apd_id,
                                                     apd_ap,
                                                     apd_app,
                                                     apd_ndt,
                                                     history_status,
                                                     apd_aps)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_app_id,
                                         200,
                                         'A',
                                         p_aps_id)
                              RETURNING apd_id
                                   INTO l_apd_200_id;

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_200_id,
                                                792,
                                                'A',
                                                TO_DATE (rec_inv.inv_dni,
                                                         'dd.mm.yyyy')); -- 792 Дата встановлення інвалідності

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_200_id,
                                                793,
                                                'A',
                                                COALESCE (
                                                    TO_DATE (
                                                        rec_inv.inv_dkpi
                                                            DEFAULT NULL ON CONVERSION ERROR,
                                                        'dd.mm.yyyy'),
                                                    TO_DATE ('31.12.2099',
                                                             'dd.mm.yyyy'))); -- 793 Встановлено на період до

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_string)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_200_id,
                                                797,
                                                'A',
                                                CASE
                                                    WHEN rec_inv.inv_grinv =
                                                         '5'
                                                    THEN
                                                        'DI'
                                                    WHEN rec_inv.inv_grinv =
                                                         '11'
                                                    THEN
                                                        'DIA'
                                                END);         -- 797 категорія

                            -- https://redmine.medirent.com.ua/issues/83763
                            -- 344 дата огляду - з поля Inv_Dnpi
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_200_id,
                                                344,
                                                'A',
                                                TO_DATE (
                                                    rec_inv.inv_dnpi
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy'));
                        ---------------- 200 200 200 200 200 200 200 200 200
                        ELSE
                            --++++++++++++++ 605 605 605 605 605 605 605 605 605
                            -- https://redmine.medirent.com.ua/issues/83763
                            -- I - Особа з інвалідністю - Якщо є запис по учаснику звернення в таблиці BINV  Inv_Grinv != (5, 11)
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         796,
                                         'I',
                                         'A');

                            --++++++++++++++ 201 201 201 201 201 201 201 201 201
                            INSERT INTO ap_document (apd_id,
                                                     apd_ap,
                                                     apd_app,
                                                     apd_ndt,
                                                     history_status,
                                                     apd_aps)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_app_id,
                                         201,
                                         'A',
                                         p_aps_id)
                              RETURNING apd_id
                                   INTO l_apd_201_id;

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                347,
                                                'A',
                                                COALESCE (
                                                    TO_DATE (
                                                        rec_inv.inv_dkpi
                                                            DEFAULT NULL ON CONVERSION ERROR,
                                                        'dd.mm.yyyy'),
                                                    TO_DATE ('31.12.2099',
                                                             'dd.mm.yyyy'))); -- 347 встановлено на період по

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_string)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                349,
                                                'A',
                                                CASE
                                                    WHEN rec_inv.inv_grinv IN
                                                             ('1',
                                                              '4',
                                                              '6',
                                                              '8',
                                                              '9')
                                                    THEN
                                                        '1'
                                                    WHEN rec_inv.inv_grinv IN
                                                             ('2', '7', '10')
                                                    THEN
                                                        '2'
                                                    WHEN rec_inv.inv_grinv IN
                                                             ('3')
                                                    THEN
                                                        '3'
                                                END); -- 349 група інвалідності

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                352,
                                                'A',
                                                TO_DATE (rec_inv.inv_dni,
                                                         'dd.mm.yyyy')); -- 352 дата встановлення інвалідності

                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_string)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                791,
                                                'A',
                                                CASE
                                                    WHEN rec_inv.inv_grinv IN
                                                             ('8')
                                                    THEN
                                                        'A'
                                                    WHEN rec_inv.inv_grinv IN
                                                             ('9')
                                                    THEN
                                                        'B'
                                                END); -- 791 підгрупа інвалідності

                            -- IC #89448
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_string)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_201_id,
                                         353,
                                         'A',
                                         'ID'); -- 2053 Інвалідність з дитинства


                            -- https://redmine.medirent.com.ua/issues/83763
                            -- 350 дата огляду - з поля Inv_Dnpi
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                350,
                                                'A',
                                                TO_DATE (
                                                    rec_inv.inv_dnpi
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy'));

                            -- IC #84625
                            -- 1910 Дата чергового переогляду
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          history_status,
                                                          apda_val_dt)
                                     VALUES (
                                                NULL,
                                                p_ap_id,
                                                l_apd_201_id,
                                                1910,
                                                'A',
                                                COALESCE (
                                                      TO_DATE (
                                                          rec_inv.inv_dkpi
                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                          'dd.mm.yyyy')
                                                    - 1,
                                                    TO_DATE ('31.12.2099',
                                                             'dd.mm.yyyy')));

                            -- 790 потребує постійного стороннього догляду - проставляємо "T",якщо в базі BOSOB Osob_Code = 4 с Osob_Priz = 1
                            IF l_apda_790 = 790
                            THEN
                                INSERT INTO ap_document_attr (
                                                apda_id,
                                                apda_ap,
                                                apda_apd,
                                                apda_nda,
                                                apda_val_string,
                                                history_status)
                                     VALUES (NULL,
                                             p_ap_id,
                                             l_apd_201_id,
                                             790,
                                             'T',
                                             'A');
                            END IF;
                        ---------------- 201 201 201 201 201 201 201 201 201
                        END IF;

                        -- https://redmine.medirent.com.ua/issues/83763
                        -- N - Без інвалідності - по замовчанню
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                            SELECT NULL,
                                   p_ap_id,
                                   l_apd_605_id,
                                   796,
                                   'N',
                                   'A'
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT 1
                                          FROM ap_document_attr aaa
                                         WHERE     aaa.apda_apd =
                                                   l_apd_605_id
                                               AND aaa.apda_nda = 796
                                               AND aaa.apda_ap = p_ap_id);

                        --++++++++++++++ 605 605 605 605 605 605 605 605 605
                        -- https://redmine.medirent.com.ua/issues/83763
                        -- 666 Група інвалідності (V_DDN_SCY_GROUP)
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_605_id,
                                            666,
                                            CASE
                                                WHEN rec_inv.inv_grinv IN
                                                         ('1',
                                                          '4',
                                                          '6',
                                                          '8',
                                                          '9')
                                                THEN
                                                    '1'
                                                WHEN rec_inv.inv_grinv IN
                                                         ('2', '7', '10')
                                                THEN
                                                    '2'
                                                WHEN rec_inv.inv_grinv IN
                                                         ('3')
                                                THEN
                                                    '3'
                                                WHEN rec_inv.inv_grinv IN
                                                         ('5', '11')
                                                THEN
                                                    '4'
                                            END,
                                            'A');

                        -- redmine.medirent.com.ua/issues/82386
                        -- Також для 248 послуги потрібно додати в 605 документ (анкету) наступні атрибути:
                        --  660 Особа з інвалідністю - якщо по віку вже більше 18 років та є запис в таблиці BINV
                        IF     p_nptc_nst = 248
                           AND ADD_MONTHS (
                                   TO_DATE (rec_igd.igd_drog, 'dd.mm.yyyy'),
                                   18 * 12) <=
                               p_np_dnprav
                        THEN
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         660,
                                         'T',
                                         'A');
                        END IF;

                        -- IC #94632
                        -- 942 (Дитина з інвалідністю внаслідок аварії на ЧАЕС) в документі 605 при значенні в полі Inv_Kod = 11
                        IF rec_inv.inv_kod = '11'
                        THEN
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         942,
                                         'T',
                                         'A');
                        END IF;
                    END LOOP;

                    -- redmine.medirent.com.ua/issues/82386
                    -- По таблиці BIGD обробляємо поля: якщо послуга 269 (опіка), тоді потрібно додати документ 114 (AP_Document) з атрибутом 708 Дата початку дії - з поля Igd_Dusn
                    IF p_nptc_nst = 269
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     114,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_114_id;

                        --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,704,'A');  -- 704 Дата ухвалення судового рішення
                        --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,705,'A');  -- 705 Номер рішення / Єдиний унікальний номер справи
                        --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,706,'A');  -- 706 дата видачі
                        --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,707,'A');  -- 707 ким видано
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      history_status,
                                                      apda_val_dt)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_114_id,
                                            708,
                                            'A',
                                            TO_DATE (rec_igd.igd_dusn,
                                                     'dd.mm.yyyy')); -- 708 Дата початку дії
                    --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,709,'A');  -- 709 ПІБ усиновленої дитини
                    --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,710,'A');  -- 710 ПІБ усиновлювача -матір
                    --  insert into ap_document_attr(apda_id,apda_ap,apda_apd,apda_nda,history_status) values (Null,p_ap_id,l_apd_114_id,809,'A');  -- 809 ПІБ усиновлювача - батько
                    END IF;

                    -- redmine.medirent.com.ua/issues/82386
                    /*Також для 248 послуги потрібно додати в 605 документ (анкету) наступні атрибути:
                      677 Знаходиться на держутриманні - якщо є незакриті записи в таблиці ISPL (немає по запису інформації в таблиці UD)*/
                    IF p_nptc_nst = 248
                    THEN
                        FOR rec_ispl
                            IN (SELECT *
                                  FROM uss_exch.v_ls_ispl_data  i
                                       LEFT JOIN uss_exch.v_ls_ud_data u
                                           ON     u.lfd_lfd = i.lfd_lfd
                                              AND u.ls_nls = i.ls_nls
                                              AND u.ispl_kud = i.ispl_kud
                                              AND u.ispl_num = i.ispl_num
                                 WHERE     i.lfd_lfd = rec_igd.lfd_lfd
                                       AND i.Ls_Nls = rec_igd.ls_nls
                                       AND u.Ls_Nls IS NULL)
                        LOOP
                            INSERT INTO ap_document_attr (apda_id,
                                                          apda_ap,
                                                          apda_apd,
                                                          apda_nda,
                                                          apda_val_string,
                                                          history_status)
                                 VALUES (NULL,
                                         p_ap_id,
                                         l_apd_605_id,
                                         677,
                                         'T',
                                         'A');
                        END LOOP;
                    END IF;

                    -- IC #102939
                    -- при міграції 275 послуги (КФН = 515, 516, 517)
                    -- if p_nptc_nst = 275 then
                    -- Tania, 16:27 23.05.2024 по гірській - створення документу треба по всім взагалі робити, бо по інвалідам ми тоді додавали вручну
                    IF 1 = 1
                    THEN
                        FOR c
                            IN (SELECT DISTINCT pt.npt_code     npt_code
                                  FROM pc_decision  d
                                       INNER JOIN pd_payment p
                                           ON p.pdp_pd = d.pd_id
                                       INNER JOIN pd_detail pd
                                           ON pd.pdd_pdp = p.pdp_id
                                       INNER JOIN
                                       uss_ndi.v_ndi_payment_type pt
                                           ON pt.npt_id = pd.pdd_npt
                                 WHERE     d.pd_id = p_pd_id
                                       AND pd.pdd_key = l_pdf_id)
                        LOOP
                            -- Додати для учасника, у кого є гірська надбавка, документ 92 Документи про надання статусу особи (гірський нас. пункт)
                            IF c.npt_code = '256'
                            THEN
                                SELECT MAX (apd_id)
                                  INTO l_apd_92_id
                                  FROM uss_esr.ap_document d
                                 WHERE     d.apd_ndt = 92
                                       AND d.apd_ap = p_ap_id
                                       AND d.apd_app = l_app_id
                                       AND d.history_status = 'A';

                                IF NVL (l_apd_92_id, 0) = 0
                                THEN
                                    INSERT INTO uss_esr.ap_document (
                                                    apd_id,
                                                    apd_ap,
                                                    apd_app,
                                                    apd_ndt,
                                                    history_status,
                                                    apd_aps)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_app_id,
                                                 92,
                                                 'A',
                                                 p_aps_id)
                                      RETURNING apd_id
                                           INTO l_apd_92_id;
                                END IF;
                            END IF;

                            -- 515 КФН в документі 605 (анкета) для заявника проставляємо в nda_id =2654 (Прийомні батьки (батько/мати)= так)
                            IF c.npt_code IN ('515')
                            THEN
                                UPDATE ap_document_attr
                                   SET apda_val_string = 'T'
                                 WHERE     apda_ap = p_ap_id
                                       AND apda_apd = l_apd_605_id
                                       AND apda_nda = 2654;

                                IF SQL%ROWCOUNT = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 2654,
                                                 'T',
                                                 'A');
                                END IF;
                            END IF;

                            -- 516 КФН в документі 605 (анкета) для заявника проставляємо в nda_id =1858 (Батько/мати-вихователь дитячого будинку
                            IF c.npt_code IN ('516')
                            THEN
                                UPDATE ap_document_attr
                                   SET apda_val_string = 'T'
                                 WHERE     apda_ap = p_ap_id
                                       AND apda_apd = l_apd_605_id
                                       AND apda_nda = 1858;

                                IF SQL%ROWCOUNT = 0
                                THEN
                                    INSERT INTO ap_document_attr (
                                                    apda_id,
                                                    apda_ap,
                                                    apda_apd,
                                                    apda_nda,
                                                    apda_val_string,
                                                    history_status)
                                         VALUES (NULL,
                                                 p_ap_id,
                                                 l_apd_605_id,
                                                 1858,
                                                 'T',
                                                 'A');
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;                                -- p_nptc_nst = 275
                END;
            ELSIF l_igd_sc_id = -2
            THEN
                RAISE ex_error_igd_doc_decision;
            ELSIF l_igd_sc_id = -1
            THEN
                RAISE ex_error_igd_2sc_decision;
            ELSE
                IF rec_igd.igd_nomig = '0'                          -- заявник
                THEN
                    RAISE ex_error_sc_else;
                ELSE
                    RAISE ex_error_igd_decision;                  -- утриманці
                END IF;
            END IF;
        END LOOP;
    END;

    PROCEDURE Load_Decision (p_lfd_lfd       NUMBER,   -- группа файлов(архив)
                             p_ls_lfdp       NUMBER, -- идентификатор строки инициатора элемеента миграции
                             p_pc            NUMBER,           -- personalcase
                             p_sc            NUMBER, -- персона (отримувач допомоги)
                             p_pa            NUMBER,             -- pc_account
                             p_ls_nls        VARCHAR2,
                             p_ls_org        VARCHAR2,
                             p_ls_spos       VARCHAR2,
                             p_ls_indots     VARCHAR2,
                             p_ls_adrul      VARCHAR2,
                             p_ls_adrdom     VARCHAR2,
                             p_ls_adrkorp    VARCHAR2,
                             p_ls_adrkv      VARCHAR2,
                             p_nptc_nst      NUMBER,
                             p_ls_base_org   VARCHAR2,
                             p_sc_scc        NUMBER,
                             p_wu            NUMBER,
                             p_wu_txt        VARCHAR2,
                             p_ls_npt_id     NUMBER)
    IS
        l_ap_id             NUMBER;
        l_aps_id            NUMBER;
        l_pd_id             NUMBER;
        l_pdp_id            NUMBER;
        l_pdd_id            NUMBER;
        l_pcb_id            NUMBER;
        l_np_dnprav         DATE;

        rec_v_ls_sv1_data   uss_exch.v_ls_sv1_data%ROWTYPE;
        rec_v_ls_sv2_data   uss_exch.v_ls_sv2_data%ROWTYPE;

        l_npo4sv1           NUMBER;
        l_ncn4sv1           NUMBER;
        l_dlv4sv1           NUMBER;
        l_ns4sv1            NUMBER;
        l_bank_id           NUMBER;
    BEGIN
        FOR rec_np
            IN (  SELECT vt.lfdp_id,
                         vt.ls_nls,
                         np_kfn
                             AS np_base_kfn,
                         np_kfn,
                         np_dnprav,
                         np_dkprav,
                         NVL (
                             TO_DATE (
                                 rod_d1 DEFAULT NULL ON CONVERSION ERROR,
                                 'dd.mm.yyyy'),
                             np_dnprav)
                             rod_dnprav,
                         NVL (
                             TO_DATE (
                                 rod_d2 DEFAULT NULL ON CONVERSION ERROR,
                                 'dd.mm.yyyy'),
                             np_dkprav)
                             rod_dkprav,
                         np_snadp,
                         ROW_NUMBER ()
                             OVER (PARTITION BY vt.ls_nls
                                   ORDER BY
                                       np_dnprav,
                                       np_dkprav,
                                       npt_id,
                                       vt.lfdp_id)
                             AS is_first,
                         ROW_NUMBER ()
                             OVER (PARTITION BY vt.ls_nls
                                   ORDER BY
                                       np_dnprav DESC,
                                       np_dkprav DESC,
                                       npt_id DESC,
                                       vt.lfdp_id DESC)
                             AS is_last,
                         MIN (np_dnprav) OVER (PARTITION BY vt.ls_nls)
                             AS min_dt,
                         MAX (np_dkprav) OVER (PARTITION BY vt.ls_nls)
                             AS max_dt,
                         TO_NUMBER (np_snadp)
                             AS sum_grp,
                         ROW_NUMBER ()
                             OVER (PARTITION BY vt.ls_nls,
                                                np_kfn,
                                                np_dnprav,
                                                np_dkprav
                                   ORDER BY npt_id, vt.lfdp_id)
                             AS npp,
                         npt.npt_id,
                         np_block_psn,
                         ls_kfn,
                         ls_fio,
                         ls_drog
                    FROM (WITH
                              tper
                              AS
                                  (  SELECT /*+ materialize index(p) index(ls) use_nl(p ls) */
                                            p.lfd_id,
                                            p.lfd_lfd,
                                            p.lfdp_id,
                                            p.per_kfn,
                                            p.per_rnaz,
                                            p.ls_nls,
                                            p.per_dnpen,
                                            p.per_psn,
                                            ls.ls_kfn,
                                            ls.ls_fio,
                                            ls.ls_drog,
                                            ROW_NUMBER ()
                                                OVER (
                                                    PARTITION BY p.per_kfn,
                                                                 p.per_dnpen,
                                                                 p.per_psn
                                                    ORDER BY
                                                        p.per_op DESC, p.rn DESC)    AS flag
                                       FROM uss_exch.v_ls_per_data p
                                            JOIN uss_exch.v_ls_data ls
                                                ON     ls.lfd_lfd = p.lfd_lfd
                                                   AND ls.ls_nls = p.ls_nls
                                      WHERE     p.ls_nls = p_ls_nls
                                            AND p.lfd_lfd = p_lfd_lfd --and per_psn in ('0','3','6','9','7','17','25','26')
                                   -- and ls.ls_kfn != '169'
                                   ORDER BY TO_DATE (
                                                p.per_dnpen
                                                    DEFAULT NULL ON CONVERSION ERROR,
                                                'dd.mm.yyyy'))
                              SELECT DISTINCT
                                     p.lfdp_id,
                                     p.lfd_lfd,
                                     p.ls_nls,
                                     p.per_kfn
                                         AS np_kfn,
                                     p.ls_kfn,
                                     p.ls_fio,
                                     p.ls_drog,
                                     TO_DATE (
                                         p.per_dnpen
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy')
                                         AS np_dnprav,
                                     LEAST (
                                         COALESCE (
                                             FIRST_VALUE (
                                                   TO_DATE (
                                                       po.per_dnpen
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 - 1)
                                                 OVER (
                                                     PARTITION BY p.lfdp_id,
                                                                  p.ls_nls,
                                                                  p.per_kfn,
                                                                  p.per_dnpen,
                                                                  p.per_rnaz
                                                     ORDER BY
                                                         TO_DATE (
                                                             po.per_dnpen
                                                                 DEFAULT NULL ON CONVERSION ERROR,
                                                             'dd.mm.yyyy')),
                                             FIRST_VALUE (
                                                   TO_DATE (
                                                       pp.per_dnpen
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 - 1)
                                                 OVER (
                                                     PARTITION BY p.lfdp_id,
                                                                  p.ls_nls,
                                                                  p.per_kfn,
                                                                  p.per_dnpen,
                                                                  p.per_rnaz
                                                     ORDER BY
                                                         TO_DATE (
                                                             pp.per_dnpen
                                                                 DEFAULT NULL ON CONVERSION ERROR,
                                                             'dd.mm.yyyy')),
                                             TO_DATE ('31.12.2099',
                                                      'dd.mm.yyyy')),
                                         COALESCE (
                                             FIRST_VALUE (
                                                   TO_DATE (
                                                       pp.per_dnpen
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 - 1)
                                                 OVER (
                                                     PARTITION BY p.lfdp_id,
                                                                  p.ls_nls,
                                                                  p.per_kfn,
                                                                  p.per_dnpen,
                                                                  p.per_rnaz
                                                     ORDER BY
                                                         TO_DATE (
                                                             pp.per_dnpen
                                                                 DEFAULT NULL ON CONVERSION ERROR,
                                                             'dd.mm.yyyy')),
                                             FIRST_VALUE (
                                                   TO_DATE (
                                                       po.per_dnpen
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 - 1)
                                                 OVER (
                                                     PARTITION BY p.lfdp_id,
                                                                  p.ls_nls,
                                                                  p.per_kfn,
                                                                  p.per_dnpen,
                                                                  p.per_rnaz
                                                     ORDER BY
                                                         TO_DATE (
                                                             po.per_dnpen
                                                                 DEFAULT NULL ON CONVERSION ERROR,
                                                             'dd.mm.yyyy')),
                                             TO_DATE ('31.12.2099',
                                                      'dd.mm.yyyy')))
                                         AS np_dkprav,
                                     FIRST_VALUE (pp.per_psn)
                                         OVER (
                                             PARTITION BY p.lfdp_id,
                                                          p.ls_nls,
                                                          p.per_kfn,
                                                          p.per_dnpen,
                                                          p.per_rnaz
                                             ORDER BY
                                                 TO_DATE (
                                                     pp.per_dnpen
                                                         DEFAULT NULL ON CONVERSION ERROR,
                                                     'dd.mm.yyyy'))
                                         np_block_psn,
                                     p.per_rnaz
                                         AS np_snadp
                                FROM tper p
                                     LEFT JOIN tper pp
                                         ON     p.lfd_lfd = pp.lfd_lfd
                                            AND p.ls_nls = pp.ls_nls
                                            AND p.per_kfn = pp.per_kfn
                                            AND pp.per_psn NOT IN ('0')
                                            AND pp.flag = 1
                                            AND TO_DATE (
                                                    pp.per_dnpen
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy') >
                                                TO_DATE (
                                                    p.per_dnpen
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy')
                                     LEFT JOIN tper po
                                         ON     p.lfd_lfd = po.lfd_lfd
                                            AND p.ls_nls = po.ls_nls
                                            AND p.per_kfn = po.per_kfn
                                            AND po.per_psn IN ('0')
                                            AND po.flag = 1
                                            AND TO_DATE (
                                                    po.per_dnpen
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy') >
                                                TO_DATE (
                                                    p.per_dnpen
                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                    'dd.mm.yyyy')
                               WHERE p.per_psn = '0' AND p.flag = 1
                              -- IC #90068
                              UNION ALL
                              SELECT DISTINCT
                                     p.lfdp_id,
                                     p.lfd_lfd,
                                     p.ls_nls,
                                     p.np_kfn,
                                     ls.ls_kfn,
                                     ls.ls_fio,
                                     ls.ls_drog,
                                     TO_DATE (
                                         p.np_dnprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy')    AS np_dnprav,
                                     TO_DATE (
                                         p.np_dkprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy')    AS np_dkprav,
                                     NULL                 np_block_psn,
                                     p.np_snadp
                                FROM uss_exch.v_ls_np_data p
                                     JOIN uss_exch.v_ls_data ls
                                         ON     ls.lfd_lfd = p.lfd_lfd
                                            AND ls.ls_nls = p.ls_nls
                               WHERE     p.ls_nls = p_ls_nls
                                     AND p.lfd_lfd = p_lfd_lfd
                                     AND ls.ls_kfn = '169'
                                     AND TO_DATE (
                                             p.np_dkprav
                                                 DEFAULT NULL ON CONVERSION ERROR,
                                             'dd.mm.yyyy') >=
                                         TO_DATE (
                                             p.np_dnprav
                                                 DEFAULT NULL ON CONVERSION ERROR,
                                             'dd.mm.yyyy')
                                     AND TO_NUMBER (
                                             p.np_snadp
                                                 DEFAULT 0 ON CONVERSION ERROR) >
                                         0
                                     AND 1 = 0 -- IC #90063 поки прибираємо з обробки 169
                                              ) vt
                         --                    join v_ndi_payment_type_mg npt on npt.npt_code = np_kfn and npt.history_status = 'A'
                         JOIN uss_ndi.v_ndi_payment_type npt
                             ON     npt.npt_code = np_kfn
                                AND npt.history_status = 'A'
                                -- IC #92346
                                AND NVL (npt.npt_npc, -1) =
                                    CASE
                                        WHEN npt.npt_code = '256' THEN 42
                                        ELSE NVL (npt.npt_npc, -1)
                                    END
                         -- IC #93118
                         -- 580 (вагітність та пологи) - є особливість по заповненню PD_Detail. період заповнюємо з таблиці BROD (поля Rod_D1 та Rod_D2) nst_id = 251
                         LEFT JOIN uss_exch.v_ls_b_rod_data rod
                             ON     rod.lfd_lfd = p_lfd_lfd
                                AND rod.ls_nls = p_ls_nls
                                AND np_kfn IN ('578',
                                               '579',
                                               '581',
                                               '580',
                                               '577')               -- #111935
                   WHERE getAccessByKFN (np_kfn,
                                         SUBSTR (TO_CHAR (p_ls_org), 1, 3)) =
                         1
                -- Вже сортується аналітичними функціями
                ORDER BY 10            -- np_dnprav, np_dkprav nulls last, npp
                           )
        LOOP
            IF getExcByKFN (rec_np.np_kfn, 'ex_error_102940') = 1
            THEN
                l_error_prm :=
                       'Помилковий код КФН '
                    || rec_np.np_kfn
                    || ' в масиві даних ПЕР!';

                RAISE ex_error_102940;
            END IF;

            -- для первой записи создаем обращение
            IF rec_np.is_first = 1
            THEN
                --------------------------------------------------------  СОЗДАНИЕ APPEAL -------------------------------------------------------------------------
                -- создание обращения (ПРОСТО СОЗДАЕМ НОВОЕ ОБРАЩЕНИЕ, ЕСЛИ СЮДА ПОПАЛИ ТО ЄТО ПЕРЕМИГРАЦИЯ ПОСЛЕ ОЧИСТКИ ИЛИ ПЕРЕМИГРАЦИЯ ДРУГИМ ФАЙЛОМ)
                INSERT INTO appeal (ap_id,
                                    ap_pc,
                                    ap_tp,
                                    ap_reg_dt,
                                    ap_src,
                                    com_org,
                                    ap_num,
                                    ap_st)
                     VALUES (NULL,
                             p_pc,
                             'V',
                             rec_np.np_dnprav,
                             'ASOPD',
                             p_ls_org,
                             p_ls_base_org || '_' || p_ls_nls,
                             'N')
                  RETURNING ap_id
                       INTO l_ap_id;

                INSERT INTO ap_service (aps_id,
                                        aps_ap,
                                        aps_st,
                                        history_status,
                                        aps_nst)
                     VALUES (NULL,
                             l_ap_id,
                             'R',
                             'A',
                             p_nptc_nst)
                  RETURNING aps_id
                       INTO l_aps_id;

                -- ADDDDD
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (p_ls_lfdp, l_ap_id, 'USS_ESR.APPEAL');

                -------------------------------------------------------------------------------------------------------------------------------------------------
                IF p_ls_spos = 1
                THEN
                    -----------------------------------------------------  ДЛЯ ДОСТАВОЧНОГО УЧАСТКА ------------------------------------------------------------------
                    BEGIN
                        SELECT sv1.*
                          INTO rec_v_ls_sv1_data
                          FROM uss_exch.v_ls_sv1_data sv1
                         WHERE     sv1.lfd_lfd = p_lfd_lfd
                               AND sv1.ls_nls = p_ls_nls;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_error_prm := 'B_SV1';
                            RAISE ex_error_84235_part_2;
                    END;

                    IF NULLIF (rec_v_ls_sv1_data.sv1_os, '0') IS NOT NULL
                    THEN
                        BEGIN -- определяем индкекс для связи с оргом, если нет то ищем для базового орга, если нет то ищем для индекса без привязки к оргу
                            --индекс по статусу без привязки к оргу
                            SELECT o.npo_id, o.npo_ncn
                              INTO l_npo4sv1, l_ncn4sv1
                              FROM uss_ndi.v_ndi_post_office o
                             WHERE     o.npo_index =
                                       LPAD (rec_v_ls_sv1_data.sv1_os,
                                             5,
                                             '0')
                                   AND o.npo_org IS NULL
                                   AND o.history_status = 'A'
                             FETCH FIRST ROWS ONLY;

                            -- привязываем первый попавшийся узел связи к этому индеексу
                            IF     l_ncn4sv1 IS NULL
                               AND rec_v_ls_sv1_data.sv1_kus <> '0'
                            THEN
                                BEGIN
                                    SELECT nnn.ncn_id
                                      INTO l_ncn4sv1
                                      FROM uss_ndi.v_ndi_comm_node nnn
                                     WHERE     nnn.ncn_code =
                                               rec_v_ls_sv1_data.sv1_kus
                                           AND SUBSTR (TO_CHAR (nnn.ncn_org),
                                                       1,
                                                       3) =
                                               SUBSTR (TO_CHAR (p_ls_org),
                                                       1,
                                                       3)
                                     FETCH FIRST ROWS ONLY;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                        /*grant execute on API$DIC_DOCUMENT to uss_esr*/
                                        uss_ndi.api$dic_document.save_comm_node (
                                            p_ncn_id           => l_ncn4sv1,
                                            p_ncn_org          =>
                                                   SUBSTR (
                                                       TO_CHAR (p_ls_org),
                                                       1,
                                                       3)
                                                || '00',
                                            p_ncn_code         =>
                                                rec_v_ls_sv1_data.sv1_kus,
                                            p_ncn_sname        => NULL,
                                            p_ncn_name         => NULL,
                                            p_history_status   => 'A',
                                            p_new_id           => l_ncn4sv1);

                                        uss_ndi.API$DIC_DOCUMENT.save_post_office_ncn (
                                            l_npo4sv1,
                                            l_ncn4sv1);
                                /*update uss_ndi.v_ndi_post_office ddd
                                set ddd.npo_ncn = l_ncn4sv1
                                where ddd.npo_id = l_npo4sv1;*/
                                END;
                            END IF;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                l_error_prm := rec_v_ls_sv1_data.sv1_os;
                                RAISE ex_error_nf_npo;
                        END;

                        BEGIN -- определяем улицу по тем же правилам с привязкой к оргу, с привязкой к базовому оргу
                              SELECT s.ns_id
                                INTO l_ns4sv1
                                FROM uss_ndi.v_ndi_street s
                               WHERE     s.ns_code = p_ls_adrul
                                     AND s.ns_org = p_ls_base_org
                                     AND s.history_status = 'A'
                            ORDER BY ns_id
                               FETCH FIRST ROWS ONLY;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                BEGIN
                                      SELECT s.ns_id
                                        INTO l_ns4sv1
                                        FROM uss_ndi.v_ndi_street s
                                       WHERE     s.ns_code = p_ls_adrul
                                             AND s.ns_org = p_ls_org
                                             AND s.history_status = 'A'
                                    ORDER BY ns_id
                                       FETCH FIRST ROWS ONLY;
                                EXCEPTION
                                    WHEN OTHERS
                                    THEN
                                        l_error_prm := p_ls_adrul;
                                        RAISE ex_error_nf_ns;
                                END;
                        END;

                        -- заполняем развязку индекса и улиці, если небіло
                        INSERT INTO uss_ndi.ndi_npo_config (nnc_ns, nnc_npo)
                            SELECT l_ns4sv1, l_npo4sv1
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT *
                                          FROM uss_ndi.ndi_npo_config g
                                         WHERE     g.nnc_ns = l_ns4sv1
                                               AND g.nnc_npo = l_npo4sv1);

                        -- определяем доставочній участок или создаем
                        BEGIN
                            SELECT du.nd_id
                              INTO l_dlv4sv1
                              FROM uss_ndi.v_ndi_delivery du
                             WHERE     du.nd_npo = l_npo4sv1
                                   AND du.nd_code = rec_v_ls_sv1_data.sv1_du
                                   AND du.history_status = 'A'
                             FETCH FIRST ROWS ONLY;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                /*grant execute on api$dic_delivery to uss_esr*/
                                uss_ndi.api$dic_delivery.set_delivery (
                                    p_nd_id        => l_dlv4sv1,
                                    p_nd_code      => rec_v_ls_sv1_data.sv1_du,
                                    p_nd_tp        => 'M',
                                    p_nd_comment   => NULL,
                                    p_nd_npo       => l_npo4sv1);
                        END;
                    END IF;

                    -- находим решение (при отсутствии создаем новое)  -- (ЕСЛИ СЮДА ЗАШЛИ СОЗДАЕМ НОВОЕ)
                    INSERT INTO pc_decision (pd_pc,
                                             pd_ap,
                                             pd_id,
                                             pd_pa,
                                             pd_dt,
                                             pd_st,
                                             pd_has_right,
                                             pd_hs_right,
                                             pd_hs_reject,
                                             pd_hs_app,
                                             pd_hs_mapp,
                                             pd_hs_head,
                                             pd_start_dt,
                                             pd_stop_dt,
                                             pd_num,
                                             pd_nst,
                                             com_org,
                                             com_wu,
                                             pd_hs_return,
                                             pd_src,
                                             pd_ps,
                                             pd_src_id,
                                             pd_ap_reason,
                                             pd_scc)
                         VALUES (p_pc,
                                 l_ap_id,
                                 NULL,
                                 p_pa,
                                 rec_np.min_dt,
                                 'P',
                                 'T',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 rec_np.min_dt,
                                 rec_np.max_dt,
                                 p_ls_base_org || '_' || rec_np.ls_nls,
                                 p_nptc_nst,
                                 p_ls_org,
                                 p_wu,
                                 NULL,
                                 'MG',
                                 NULL,
                                 NULL,
                                 l_ap_id,
                                 p_sc_scc)
                      RETURNING pd_id, pd_start_dt
                           INTO l_pd_id, l_np_dnprav;

                    IF LENGTH (p_ls_indots) > 6
                    THEN
                        l_error_prm := p_ls_indots;
                        RAISE ex_error_84235_part_1;
                    END IF;

                    -- информация по віплатнім реквизитам
                    INSERT INTO pd_pay_method (pdm_id,
                                               pdm_pd,
                                               pdm_start_dt,
                                               pdm_stop_dt,
                                               history_status,
                                               pdm_ap_src,
                                               pdm_pay_tp,
                                               pdm_index,
                                               pdm_kaot,
                                               pdm_nb,
                                               pdm_account,
                                               pdm_street,
                                               pdm_ns,
                                               pdm_building,
                                               pdm_block,
                                               pdm_apartment,
                                               pdm_nd,
                                               pdm_pay_dt,
                                               pdm_scc,
                                               pdm_is_actual,
                                               pdm_nd_num)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        rec_np.min_dt,
                                        rec_np.max_dt,
                                        'A',
                                        l_ap_id,
                                        'POST',
                                        p_ls_indots,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        l_ns4sv1,
                                        p_ls_adrdom,
                                        p_ls_adrkorp,
                                        p_ls_adrkv,
                                        l_dlv4sv1,
                                        --
                                        CASE
                                            WHEN TO_NUMBER (
                                                     rec_v_ls_sv1_data.sv1_dvipl) BETWEEN 1
                                                                                      AND 31
                                            THEN
                                                TO_NUMBER (
                                                    rec_v_ls_sv1_data.sv1_dvipl)
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) <
                                                 4
                                            THEN
                                                4
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) >
                                                 25
                                            THEN
                                                25
                                            ELSE
                                                TO_NUMBER (
                                                    TO_CHAR (rec_np.min_dt,
                                                             'dd'))
                                        END,
                                        p_sc_scc,
                                        'T',
                                        rec_v_ls_sv1_data.sv1_du);

                    INSERT INTO pd_log (pdl_id,
                                        pdl_pd,
                                        pdl_hs,
                                        pdl_st,
                                        pdl_message,
                                        pdl_st_old,
                                        pdl_tp)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        NULL,
                                        NULL,
                                           CHR (38)
                                        || '94#'
                                        || p_wu_txt
                                        || '#'
                                        || TO_CHAR (SYSDATE,
                                                    'dd.mm.yyyy hh24:mi:ss'),
                                        NULL,
                                        'SYS');

                    -- дата міграції для шапки документа
                    INSERT INTO pd_log (pdl_id,
                                        pdl_pd,
                                        pdl_hs,
                                        pdl_st,
                                        pdl_message,
                                        pdl_st_old,
                                        pdl_tp)
                         VALUES (NULL,
                                 l_pd_id,
                                 NULL,
                                 NULL,
                                 TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'),
                                 NULL,
                                 'MIGR');

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_np.lfdp_id,
                                     l_pd_id,
                                     'USS_ESR.PC_DECISION');
                ELSIF p_ls_spos = 2
                THEN
                    ------------------------------------------------------------  ДЛЯ БАНКА -----------------------------------------------------------------------
                    BEGIN
                        -- значения из віплат банка (SV2)
                        BEGIN
                            SELECT sv2.*
                              INTO rec_v_ls_sv2_data
                              FROM uss_exch.v_ls_sv2_data sv2
                             WHERE     sv2.lfd_lfd = p_lfd_lfd
                                   AND sv2.ls_nls = p_ls_nls;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                l_error_prm := 'B_SV2';
                                RAISE ex_error_84235_part_2;
                        END;

                        IF     NULLIF (rec_v_ls_sv2_data.sv2_ncsbb, '0')
                                   IS NOT NULL
                           AND NULLIF (rec_v_ls_sv2_data.sv2_npsbb, '0')
                                   IS NOT NULL
                        THEN
                            -- вібор банка в подсистеме усс по коду баенка и отделению банка с привязкой к оргу,потом с привязкой к базовому оргу, потом без привязки к оргу просто по отделению и коду банка.
                            BEGIN
                                SELECT bb.nbb_nb
                                  INTO l_bank_id
                                  FROM uss_exch.v_ls_nb_branch_ref  bb
                                       JOIN uss_ndi.v_ndi_bank b
                                           ON     b.nb_id = bb.NBB_NB
                                              AND b.history_status = 'A'
                                 WHERE     rec_v_ls_sv2_data.sv2_ncsbb =
                                           bb.nbb_ncsbb
                                       AND rec_v_ls_sv2_data.sv2_npsbb =
                                           bb.nbb_code
                                       AND bb.nbb_org = p_ls_base_org;
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    BEGIN
                                        SELECT bb.nbb_nb
                                          INTO l_bank_id
                                          FROM uss_exch.v_ls_nb_branch_ref bb
                                               JOIN uss_ndi.v_ndi_bank b
                                                   ON     b.nb_id = bb.NBB_NB
                                                      AND b.history_status =
                                                          'A'
                                         WHERE     rec_v_ls_sv2_data.sv2_ncsbb =
                                                   bb.nbb_ncsbb
                                               AND rec_v_ls_sv2_data.sv2_npsbb =
                                                   bb.nbb_code
                                               AND bb.nbb_org = p_ls_org;
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            IF     rec_v_ls_sv2_data.sv2_ncsbb =
                                                   '10026'
                                               AND rec_v_ls_sv2_data.sv2_npsbb =
                                                   '10026'
                                            THEN
                                                l_bank_id := 26;
                                            ELSE
                                                l_error_prm :=
                                                       rec_v_ls_sv2_data.sv2_ncsbb
                                                    || '/'
                                                    || rec_v_ls_sv2_data.sv2_npsbb;
                                                RAISE ex_error_nf_bank;
                                            END IF;
                                    END;
                            END;
                        END IF;
                    END;

                    -- создаем новое решение
                    INSERT INTO pc_decision (pd_pc,
                                             pd_ap,
                                             pd_id,
                                             pd_pa,
                                             pd_dt,
                                             pd_st,
                                             pd_has_right,
                                             pd_hs_right,
                                             pd_hs_reject,
                                             pd_hs_app,
                                             pd_hs_mapp,
                                             pd_hs_head,
                                             pd_start_dt,
                                             pd_stop_dt,
                                             pd_num,
                                             pd_nst,
                                             com_org,
                                             com_wu,
                                             pd_hs_return,
                                             pd_src,
                                             pd_ps,
                                             pd_src_id,
                                             pd_ap_reason,
                                             pd_scc)
                         VALUES (p_pc,
                                 l_ap_id,
                                 NULL,
                                 p_pa,
                                 rec_np.min_dt,
                                 'P',
                                 'T',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 rec_np.min_dt,
                                 rec_np.max_dt,
                                 p_ls_base_org || '_' || rec_np.ls_nls,
                                 p_nptc_nst,
                                 p_ls_org,
                                 p_wu,
                                 NULL,
                                 'MG',
                                 NULL,
                                 NULL,
                                 l_ap_id,
                                 p_sc_scc)
                      RETURNING pd_id, pd_start_dt
                           INTO l_pd_id, l_np_dnprav;

                    IF LENGTH (p_ls_indots) > 6
                    THEN
                        l_error_prm := p_ls_indots;
                        RAISE ex_error_84235_part_1;
                    END IF;

                    -- информация по віплатнім реквизитам
                    INSERT INTO pd_pay_method (pdm_id,
                                               pdm_pd,
                                               pdm_start_dt,
                                               pdm_stop_dt,
                                               history_status,
                                               pdm_ap_src,
                                               pdm_pay_tp,
                                               pdm_index,
                                               pdm_kaot,
                                               pdm_nb,
                                               pdm_account,
                                               pdm_street,
                                               pdm_ns,
                                               pdm_building,
                                               pdm_block,
                                               pdm_apartment,
                                               pdm_nd,
                                               pdm_pay_dt,
                                               pdm_scc,
                                               pdm_is_actual)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        rec_np.min_dt,
                                        rec_np.max_dt,
                                        'A',
                                        l_ap_id,
                                        'BANK',
                                        p_ls_indots,
                                        NULL,
                                        l_bank_id,
                                        rec_v_ls_sv2_data.sv2_vklad,
                                        NULL,
                                        l_ns4sv1,
                                        p_ls_adrdom,
                                        p_ls_adrkorp,
                                        p_ls_adrkv,
                                        NULL,
                                        CASE
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) <
                                                 4
                                            THEN
                                                4
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) >
                                                 25
                                            THEN
                                                25
                                            ELSE
                                                TO_NUMBER (
                                                    TO_CHAR (rec_np.min_dt,
                                                             'dd'))
                                        END,
                                        p_sc_scc,
                                        'T');

                    INSERT INTO pd_log (pdl_id,
                                        pdl_pd,
                                        pdl_hs,
                                        pdl_st,
                                        pdl_message,
                                        pdl_st_old,
                                        pdl_tp)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        NULL,
                                        NULL,
                                           CHR (38)
                                        || '94#'
                                        || p_wu_txt
                                        || '#'
                                        || TO_CHAR (SYSDATE,
                                                    'dd.mm.yyyy hh24:mi:ss'),
                                        NULL,
                                        'SYS');

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_np.lfdp_id,
                                     l_pd_id,
                                     'USS_ESR.PC_DECISION');
                END IF;                          -- if rec_ls.ls_spos = 1 then

                ------------------------------------------------------------ОКОНЧАНИЕ БЛОКА ДЛЯ БАНКА -----------------------------------------------------------------------
                -- если решение не создалось
                IF l_pd_id IS NULL
                THEN
                    RAISE ex_error_create_pd;
                END IF;
            END IF;                             -- if rec_np.is_first = 1 then


            -- https://redmine.med/issues/82196 - дата закрытия всегда '31.12.2099'
            -- создаем віплату
            IF rec_np.npp = 1
            THEN
                -- акруал период создаем только для основного КФН по первому включению
                IF rec_np.np_kfn = rec_np.ls_kfn
                -- акруал створюємо по 129 коду з масиву НП
                -- IC #90063 or rec_np.np_kfn = '129'
                THEN
                    -- IC #102764 При завантаженні всіх послуг, крім 248 (інвалідність) прописувати період дії рішення в PD_ACCRUAL_PERIOD з самого мінімальної дати по саму максимальну (по всім дозволеним кодам)
                    IF p_nptc_nst = 248
                    THEN
                        INSERT INTO pd_accrual_period (pdap_id,
                                                       pdap_pd,
                                                       pdap_start_dt,
                                                       pdap_stop_dt,
                                                       history_status,
                                                       pdap_reason_stop)
                                 VALUES (
                                            NULL,
                                            l_pd_id,
                                            rec_np.np_dnprav,
                                            COALESCE (
                                                rec_np.np_dkprav,
                                                TO_DATE ('31.12.2099',
                                                         'dd.mm.yyyy')),
                                            'A',
                                            CASE
                                                WHEN     COALESCE (
                                                             rec_np.np_dkprav,
                                                             TO_DATE (
                                                                 '31.12.2099',
                                                                 'dd.mm.yyyy')) <
                                                         LAST_DAY (
                                                             TRUNC (SYSDATE))
                                                     AND rec_np.np_block_psn <>
                                                         '0'
                                                THEN
                                                       'RMR'
                                                    || rec_np.np_block_psn
                                                ELSE
                                                    NULL
                                            END);
                    ELSE
                        INSERT INTO pd_accrual_period (pdap_id,
                                                       pdap_pd,
                                                       pdap_start_dt,
                                                       pdap_stop_dt,
                                                       history_status,
                                                       pdap_reason_stop)
                            SELECT NULL             pdap_id,
                                   l_pd_id          pdap_pd,
                                   rec_np.min_dt    pdap_start_dt,
                                   rec_np.max_dt    pdap_stop_dt,
                                   'A'              history_status,
                                   CASE
                                       WHEN     rec_np.max_dt <
                                                LAST_DAY (TRUNC (SYSDATE))
                                            AND rec_np.np_block_psn <> '0'
                                       THEN
                                           'RMR' || rec_np.np_block_psn
                                       ELSE
                                           NULL
                                   END              pdap_reason_stop
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT 1
                                          FROM pd_accrual_period
                                         WHERE     pdap_pd = l_pd_id
                                               AND pdap_start_dt =
                                                   rec_np.min_dt
                                               AND pdap_stop_dt =
                                                   rec_np.max_dt
                                               AND history_status = 'A');
                    END IF;
                END IF;

                INSERT INTO pd_payment (pdp_id,
                                        pdp_pd,
                                        pdp_npt,
                                        pdp_start_dt,
                                        pdp_stop_dt,
                                        pdp_sum,
                                        history_status,
                                        pdp_src)
                     VALUES (
                                NULL,
                                l_pd_id,
                                rec_np.npt_id,
                                rec_np.np_dnprav,
                                COALESCE (
                                    rec_np.np_dkprav,
                                    TO_DATE ('31.12.2099', 'dd.mm.yyyy')),
                                rec_np.sum_grp,
                                'A',
                                'MG')
                  RETURNING pdp_id
                       INTO l_pdp_id;
            END IF;                                  -- if rec_np.npp = 1 then

            --------------------------------------------------------------------------------------------
            --https://redmine.medirent.com.ua/issues/82229
            IF p_nptc_nst = 248
            THEN                                     -- ДЛЯ 248 СВОЯ ТЕКСТОВКА
                -- Tania, 19:27 давай уберем кусок Юры по nptc_nst = 248
                IF rec_np.np_base_kfn NOT IN ('169',
                                              '530',
                                              '576',
                                              '995',
                                              '998',
                                              '986',
                                              '537',
                                              '515',
                                              '516',
                                              '517',
                                              '523',
                                              '524') /*and rec_np.ls_kfn != '169'*/
                THEN
                    FOR rec_82229
                        IN (SELECT ROWNUM
                                       AS rn,
                                   np.lfdp_id,
                                   np.lfd_lfd,
                                   np.ls_nls,
                                   np.np_dnprav,
                                   np.np_dkprav,
                                   np.np_snadp,
                                   SUM (np.np_snadp) OVER ()
                                       AS all_np_snadp,
                                   npt.npt_id
                              FROM uss_exch.v_ls_np_data  np
                                   JOIN v_ndi_payment_type_248_np npt
                                       ON     npt.npt_code = np.np_kfn
                                          -- IC #90063
                                          -- and npt.npt_code = rec_np.np_kfn
                                          AND npt.new_npt_code =
                                              rec_np.np_kfn
                             WHERE     np.lfd_lfd = p_lfd_lfd
                                   AND np.ls_nls = p_ls_nls
                                   AND rec_np.np_dnprav BETWEEN TO_DATE (
                                                                    np.np_dnprav
                                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                                    'dd.mm.yyyy')
                                                            AND COALESCE (
                                                                    NULLIF (
                                                                        TO_DATE (
                                                                            np.np_dkprav
                                                                                DEFAULT NULL ON CONVERSION ERROR,
                                                                            'dd.mm.yyyy'),
                                                                        TO_DATE (
                                                                            '31.12.2054',
                                                                            'dd.mm.yyyy')),
                                                                    TO_DATE (
                                                                        '31.12.2099',
                                                                        'dd.mm.yyyy'))
                                   AND rec_np.np_dkprav BETWEEN TO_DATE (
                                                                    np.np_dnprav
                                                                        DEFAULT NULL ON CONVERSION ERROR,
                                                                    'dd.mm.yyyy')
                                                            AND COALESCE (
                                                                    NULLIF (
                                                                        TO_DATE (
                                                                            np.np_dkprav
                                                                                DEFAULT NULL ON CONVERSION ERROR,
                                                                            'dd.mm.yyyy'),
                                                                        TO_DATE (
                                                                            '31.12.2054',
                                                                            'dd.mm.yyyy')),
                                                                    TO_DATE (
                                                                        '31.12.2099',
                                                                        'dd.mm.yyyy'))
                                   AND TO_NUMBER (
                                           np.np_snadp
                                               DEFAULT 0 ON CONVERSION ERROR) >
                                       0)
                    LOOP
                        IF rec_82229.rn = 1
                        THEN
                            UPDATE pd_payment ppp
                               SET ppp.pdp_sum = rec_82229.all_np_snadp
                             WHERE ppp.pdp_id = l_pdp_id;
                        END IF;

                        INSERT INTO pd_detail (pdd_id,
                                               pdd_pdp,
                                               pdd_value,
                                               pdd_ndp,
                                               pdd_start_dt,
                                               pdd_stop_dt,
                                               pdd_npt,
                                               pdd_row_name)
                             VALUES (
                                        NULL,
                                        l_pdp_id,
                                        rec_82229.np_snadp,
                                        290,
                                        NVL (rec_np.rod_dnprav,
                                             rec_np.np_dnprav),
                                        NVL (
                                            rec_np.rod_dkprav,
                                            COALESCE (
                                                rec_np.np_dkprav,
                                                TO_DATE ('31.12.2099',
                                                         'dd.mm.yyyy'))),
                                        rec_82229.npt_id,
                                           CHR (38)
                                        || '167#@204@'
                                        || rec_82229.npt_id)
                          RETURNING pdd_id
                               INTO l_pdd_id;

                        -- ADDDDD
                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_82229.lfdp_id,
                                         l_pdd_id,
                                         'USS_ESR.PD_DETAIL');
                    END LOOP;
                END IF;
            ELSIF p_nptc_nst = 664
            THEN                                     -- ДЛЯ ВПО СВОЯ ТЕКСТОВКА
                -- создаем детали віплат
                INSERT INTO pd_detail (pdd_id,
                                       pdd_pdp,
                                       pdd_value,
                                       pdd_ndp,
                                       pdd_start_dt,
                                       pdd_stop_dt,
                                       pdd_npt,
                                       pdd_row_name)
                     VALUES (
                                NULL,
                                l_pdp_id,
                                rec_np.np_snadp,
                                290,
                                NVL (rec_np.rod_dnprav, rec_np.np_dnprav),
                                NVL (
                                    rec_np.rod_dkprav,
                                    COALESCE (
                                        rec_np.np_dkprav,
                                        TO_DATE ('31.12.2099', 'dd.mm.yyyy'))),
                                rec_np.npt_id,
                                   CHR (38)
                                || '63#'
                                || rec_np.ls_fio
                                || '#'
                                || rec_np.ls_drog)
                  RETURNING pdd_id
                       INTO l_pdd_id;

                -- ADDDDD
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_np.lfdp_id, l_pdd_id, 'USS_ESR.PD_DETAIL');
            ELSE
                -- Tania, 05.07.2023 15:58 прибери ЮРИН!!!
                IF rec_np.np_base_kfn NOT IN ('169',
                                              '530',
                                              '576',
                                              '995',
                                              '998',
                                              '986',
                                              '537',
                                              '515',
                                              '516',
                                              '517',
                                              '523',
                                              '524') /*and rec_np.ls_kfn != '169'*/
                THEN
                    -- создаем детали віплат
                    INSERT INTO pd_detail (pdd_id,
                                           pdd_pdp,
                                           pdd_value,
                                           pdd_ndp,
                                           pdd_start_dt,
                                           pdd_stop_dt,
                                           pdd_npt,
                                           pdd_row_name)
                         VALUES (
                                    NULL,
                                    l_pdp_id,
                                    rec_np.np_snadp,
                                    290,
                                    NVL (rec_np.rod_dnprav, rec_np.np_dnprav),
                                    NVL (
                                        rec_np.rod_dkprav,
                                        COALESCE (
                                            rec_np.np_dkprav,
                                            TO_DATE ('31.12.2099',
                                                     'dd.mm.yyyy'))),
                                    rec_np.npt_id,
                                    CHR (38) || '167#@204@' || rec_np.npt_id)
                      RETURNING pdd_id
                           INTO l_pdd_id;

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_np.lfdp_id,
                                     l_pdd_id,
                                     'USS_ESR.PD_DETAIL');
                END IF;
            END IF;

            -- IC #87332
            -- Для KFN=576, 530 та 169 додати обробку масиву NP
            -- IC #89114
            -- Додати формування таблиці PD_detail по КФН in (995, 998, 986)
            -- IC #93118 Зміни по міграції по новим допомогам
            -- '537', '580', '515', '516', '517', '523', '524'
            IF rec_np.np_base_kfn IN ('169',
                                      '530',
                                      '576',
                                      '995',
                                      '998',
                                      '986', -- IC #90063 or rec_np.ls_kfn = '169'
                                      '537',
                                      '515',
                                      '516',
                                      '517',
                                      '523',
                                      '524')
            THEN
                l_pdd_id := 0;

                FOR c
                    IN (SELECT SUBSTR (
                                      '&200#'
                                   || REGEXP_REPLACE (
                                          TRIM (NVL (p.igd_fio, ls.ls_fio)),
                                          '\s+',
                                          ' ')
                                   || '#'
                                   || NVL (p.igd_drog, ls.ls_drog)
                                   || '#@204@'
                                   || npt.npt_id,
                                   1,
                                   250)
                                   pdd_row_name,
                               np.lfdp_id,
                               np.lfd_lfd,
                               np.ls_nls,
                               TO_DATE (
                                   np.np_dnprav
                                       DEFAULT NULL ON CONVERSION ERROR,
                                   'dd.mm.yyyy')
                                   np_dnprav,
                               TO_DATE (
                                   np.np_dkprav
                                       DEFAULT NULL ON CONVERSION ERROR,
                                   'dd.mm.yyyy')
                                   np_dkprav,
                               TO_NUMBER (
                                   np.np_snadp
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   np_snadp,
                               -- rec_np.sum_grp
                               -- rec_np.np_dnprav
                               -- rec_np.np_dkprav
                               npt.npt_id,
                               NVL (p.lfdp_id, ls.lfdp_id)
                                   key_lfdp_id,
                               SUM (
                                   TO_NUMBER (
                                       np.np_snadp
                                           DEFAULT NULL ON CONVERSION ERROR))
                                   OVER ()
                                   all_np_snadp,
                               ROWNUM
                                   rn
                          FROM uss_exch.v_ls_np_data  np
                               INNER JOIN v_ndi_payment_type_248_np npt
                                   ON     npt.npt_code = np.np_kfn
                                      -- IC #90063
                                      -- and npt.npt_code = rec_np.np_kfn
                                      AND npt.new_npt_code = rec_np.np_kfn
                               LEFT JOIN uss_exch.v_ls_igd_data p
                                   ON     p.lfd_lfd = np.lfd_lfd
                                      AND p.ls_nls = np.ls_nls
                                      AND p.igd_nomig = np.np_nomig
                                      AND np.np_nomig != '0'
                                      -- IC #93156 Взагалі по цим допомогам до 2023 року не перевіряти по масиву НП наявність утриманців
                                      AND CASE
                                              WHEN np.np_kfn IN ('515', /*'516', */
                                                                 '517',
                                                                 '523',
                                                                 '524')
                                              THEN
                                                  CASE
                                                      WHEN TO_DATE (
                                                               p.igd_dso
                                                                   DEFAULT NULL ON CONVERSION ERROR,
                                                               'dd.mm.yyyy') <
                                                           TO_DATE (
                                                               '01.01.2023',
                                                               'dd.mm.yyyy')
                                                      THEN
                                                          0
                                                      ELSE
                                                          1
                                                  END
                                              ELSE
                                                  1
                                          END =
                                          1
                               LEFT JOIN uss_exch.v_ls_data ls
                                   ON     ls.lfd_lfd = np.lfd_lfd
                                      AND ls.ls_nls = np.ls_nls
                                      AND np.np_nomig = '0'
                         WHERE     np.lfd_lfd = p_lfd_lfd
                               AND np.ls_nls = p_ls_nls
                               AND TO_NUMBER (
                                       np.np_snadp
                                           DEFAULT 0 ON CONVERSION ERROR) >
                                   0
                               AND rec_np.np_dnprav BETWEEN TO_DATE (
                                                                np.np_dnprav
                                                                    DEFAULT NULL ON CONVERSION ERROR,
                                                                'dd.mm.yyyy')
                                                        AND COALESCE (
                                                                NULLIF (
                                                                    TO_DATE (
                                                                        np.np_dkprav
                                                                            DEFAULT NULL ON CONVERSION ERROR,
                                                                        'dd.mm.yyyy'),
                                                                    TO_DATE (
                                                                        '31.12.2054',
                                                                        'dd.mm.yyyy')),
                                                                TO_DATE (
                                                                    '31.12.2099',
                                                                    'dd.mm.yyyy'))
                               AND rec_np.np_dkprav BETWEEN TO_DATE (
                                                                np.np_dnprav
                                                                    DEFAULT NULL ON CONVERSION ERROR,
                                                                'dd.mm.yyyy')
                                                        AND COALESCE (
                                                                NULLIF (
                                                                    TO_DATE (
                                                                        np.np_dkprav
                                                                            DEFAULT NULL ON CONVERSION ERROR,
                                                                        'dd.mm.yyyy'),
                                                                    TO_DATE (
                                                                        '31.12.2054',
                                                                        'dd.mm.yyyy')),
                                                                TO_DATE (
                                                                    '31.12.2099',
                                                                    'dd.mm.yyyy'))
                               AND rec_np.np_kfn NOT IN ('169',
                                                         '530',
                                                         '576',   -- IC #91221
                                                         '537',
                                                         '515',
                                                         '516',
                                                         '517',
                                                         '523',
                                                         '524')
                        UNION ALL
                          SELECT SUBSTR (
                                        '&200#'
                                     || REGEXP_REPLACE (
                                            TRIM (NVL (p.igd_fio, ls.ls_fio)),
                                            '\s+',
                                            ' ')
                                     || '#'
                                     || NVL (p.igd_drog, ls.ls_drog)
                                     || '#@204@'
                                     || npt.npt_id,
                                     1,
                                     250)
                                     pdd_row_name,
                                 MIN (np.lfdp_id)
                                     lfdp_id,
                                 np.lfd_lfd,
                                 np.ls_nls,
                                 MIN (
                                     TO_DATE (
                                         np.np_dnprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy'))
                                     np_dnprav,
                                 MAX (
                                     TO_DATE (
                                         np.np_dkprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy'))
                                     np_dkprav,
                                 MIN (
                                     TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT NULL ON CONVERSION ERROR))
                                     np_snadp,
                                 npt.npt_id,
                                 NVL (p.lfdp_id, ls.lfdp_id)
                                     key_lfdp_id,
                                 MAX (
                                     TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT NULL ON CONVERSION ERROR))
                                     all_np_snadp,
                                 ROW_NUMBER () OVER (ORDER BY npt.npt_id)
                                     rn
                            FROM uss_exch.v_ls_np_data np
                                 INNER JOIN v_ndi_payment_type_248_np npt
                                     ON     npt.npt_code = np.np_kfn
                                        AND npt.new_npt_code = rec_np.np_kfn
                                 LEFT JOIN uss_exch.v_ls_igd_data p
                                     ON     p.lfd_lfd = np.lfd_lfd
                                        AND p.ls_nls = np.ls_nls
                                        AND p.igd_nomig = np.np_nomig
                                        AND np.np_nomig != '0'
                                        -- IC #93156 Взагалі по цим допомогам до 2023 року не перевіряти по масиву НП наявність утриманців
                                        AND CASE
                                                WHEN np.np_kfn IN ('515', /*'516', */
                                                                   '517',
                                                                   '523',
                                                                   '524')
                                                THEN
                                                    CASE
                                                        WHEN TO_DATE (
                                                                 p.igd_dso
                                                                     DEFAULT NULL ON CONVERSION ERROR,
                                                                 'dd.mm.yyyy') <
                                                             TO_DATE (
                                                                 '01.01.2023',
                                                                 'dd.mm.yyyy')
                                                        THEN
                                                            0
                                                        ELSE
                                                            1
                                                    END
                                                ELSE
                                                    1
                                            END =
                                            1
                                 LEFT JOIN uss_exch.v_ls_data ls
                                     ON     ls.lfd_lfd = np.lfd_lfd
                                        AND ls.ls_nls = np.ls_nls
                                        AND np.np_nomig = '0'
                           WHERE     np.lfd_lfd = p_lfd_lfd
                                 AND np.ls_nls = p_ls_nls
                                 AND TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT 0 ON CONVERSION ERROR) >
                                     0
                                 --                    and to_date(np.np_dnprav default null on conversion error, 'dd.mm.yyyy') between rec_np.np_dnprav and coalesce(rec_np.np_dkprav, to_date('31.12.2099', 'dd.mm.yyyy'))
                                 --                    and to_date(np.np_dkprav default null on conversion error, 'dd.mm.yyyy') between rec_np.np_dnprav and coalesce(rec_np.np_dkprav, to_date('31.12.2099', 'dd.mm.yyyy'))
                                 AND rec_np.np_dnprav BETWEEN TO_DATE (
                                                                  np.np_dnprav
                                                                      DEFAULT NULL ON CONVERSION ERROR,
                                                                  'dd.mm.yyyy')
                                                          AND COALESCE (
                                                                  NULLIF (
                                                                      TO_DATE (
                                                                          np.np_dkprav
                                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                                          'dd.mm.yyyy'),
                                                                      TO_DATE (
                                                                          '31.12.2054',
                                                                          'dd.mm.yyyy')),
                                                                  TO_DATE (
                                                                      '31.12.2099',
                                                                      'dd.mm.yyyy'))
                                 AND rec_np.np_dkprav BETWEEN TO_DATE (
                                                                  np.np_dnprav
                                                                      DEFAULT NULL ON CONVERSION ERROR,
                                                                  'dd.mm.yyyy')
                                                          AND COALESCE (
                                                                  NULLIF (
                                                                      TO_DATE (
                                                                          np.np_dkprav
                                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                                          'dd.mm.yyyy'),
                                                                      TO_DATE (
                                                                          '31.12.2054',
                                                                          'dd.mm.yyyy')),
                                                                  TO_DATE (
                                                                      '31.12.2099',
                                                                      'dd.mm.yyyy'))
                                 AND rec_np.np_kfn IN ('169',
                                                       '530',
                                                       '576',     -- IC #91221
                                                       '537',
                                                       '515',
                                                       '516',
                                                       '517',
                                                       '523',
                                                       '524')
                        GROUP BY NVL (p.igd_fio, ls.ls_fio),
                                 NVL (p.igd_drog, ls.ls_drog),
                                 npt.npt_id,
                                 np.lfd_lfd,
                                 np.ls_nls,
                                 NVL (p.lfdp_id, ls.lfdp_id)
                        -- IC #102939 при міграції 275 послуги (КФН = 515, 516, 517) потрібно перевіряти в масиві НП надбавку 256
                        UNION ALL
                          SELECT SUBSTR (
                                        '&200#'
                                     || REGEXP_REPLACE (
                                            TRIM (NVL (p.igd_fio, ls.ls_fio)),
                                            '\s+',
                                            ' ')
                                     || '#'
                                     || NVL (p.igd_drog, ls.ls_drog)
                                     || '#@204@'
                                     || npt.npt_id,
                                     1,
                                     250)
                                     pdd_row_name,
                                 MIN (np.lfdp_id)
                                     lfdp_id,
                                 np.lfd_lfd,
                                 np.ls_nls,
                                 MIN (
                                     TO_DATE (
                                         np.np_dnprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy'))
                                     np_dnprav,
                                 MAX (
                                     TO_DATE (
                                         np.np_dkprav
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy'))
                                     np_dkprav,
                                 MIN (
                                     TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT NULL ON CONVERSION ERROR))
                                     np_snadp,
                                 npt.npt_id,
                                 NVL (p.lfdp_id, ls.lfdp_id)
                                     key_lfdp_id,
                                 MAX (
                                     TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT NULL ON CONVERSION ERROR))
                                     all_np_snadp,
                                 2
                                     rn
                            FROM uss_exch.v_ls_np_data np
                                 INNER JOIN uss_exch.v_ls_np_data npb
                                     ON     npb.lfd_lfd = p_lfd_lfd
                                        AND npb.ls_nls = p_ls_nls
                                        AND npb.np_nomig = np.np_nomig
                                        AND npb.np_dnprav = np.np_dnprav
                                        AND npb.np_dkprav = np.np_dkprav
                                        AND npb.np_kfn = rec_np.np_kfn
                                 INNER JOIN uss_ndi.v_ndi_payment_type npt
                                     ON     npt.npt_code = np.np_kfn
                                        AND npt.history_status = 'A'
                                        AND npt.npt_npc = 31
                                 LEFT JOIN uss_exch.v_ls_igd_data p
                                     ON     p.lfd_lfd = p_lfd_lfd
                                        AND p.ls_nls = p_ls_nls
                                        AND p.igd_nomig = np.np_nomig
                                        AND np.np_nomig != '0'
                                 LEFT JOIN uss_exch.v_ls_data ls
                                     ON     ls.lfd_lfd = p_lfd_lfd
                                        AND ls.ls_nls = p_ls_nls
                                        AND np.np_nomig = '0'
                           WHERE     np.lfd_lfd = p_lfd_lfd
                                 AND np.ls_nls = p_ls_nls
                                 AND np.np_kfn = '256'
                                 AND TO_NUMBER (
                                         np.np_snadp
                                             DEFAULT 0 ON CONVERSION ERROR) >
                                     0
                                 AND rec_np.np_dnprav BETWEEN TO_DATE (
                                                                  np.np_dnprav
                                                                      DEFAULT NULL ON CONVERSION ERROR,
                                                                  'dd.mm.yyyy')
                                                          AND COALESCE (
                                                                  NULLIF (
                                                                      TO_DATE (
                                                                          np.np_dkprav
                                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                                          'dd.mm.yyyy'),
                                                                      TO_DATE (
                                                                          '31.12.2054',
                                                                          'dd.mm.yyyy')),
                                                                  TO_DATE (
                                                                      '31.12.2099',
                                                                      'dd.mm.yyyy'))
                                 AND rec_np.np_dkprav BETWEEN TO_DATE (
                                                                  np.np_dnprav
                                                                      DEFAULT NULL ON CONVERSION ERROR,
                                                                  'dd.mm.yyyy')
                                                          AND COALESCE (
                                                                  NULLIF (
                                                                      TO_DATE (
                                                                          np.np_dkprav
                                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                                          'dd.mm.yyyy'),
                                                                      TO_DATE (
                                                                          '31.12.2054',
                                                                          'dd.mm.yyyy')),
                                                                  TO_DATE (
                                                                      '31.12.2099',
                                                                      'dd.mm.yyyy'))
                                 AND rec_np.np_kfn IN ('515', '516', '517')
                        GROUP BY NVL (p.igd_fio, ls.ls_fio),
                                 NVL (p.igd_drog, ls.ls_drog),
                                 npt.npt_id,
                                 np.lfd_lfd,
                                 np.ls_nls,
                                 NVL (p.lfdp_id, ls.lfdp_id))
                LOOP
                    -- IC #91221
                    IF rec_np.np_kfn IN ('169', '530', '576')
                    THEN
                        -- Якщо сума за період не співпадає хоча б по одному рядку - помилка
                        IF c.np_snadp != c.all_np_snadp
                        THEN
                            l_error_prm :=
                                   'Для обранного коду '
                                || rec_np.np_kfn
                                || ' сума масиву надбавок за період з '
                                || TO_CHAR (rec_np.np_dnprav, 'dd.mm.yyyy')
                                || ' по '
                                || TO_CHAR (rec_np.np_dkprav, 'dd.mm.yyyy')
                                || ' має рядки з різними сумами! Завантаження неможливо!';

                            RAISE ex_error_91221;
                        END IF;
                    -- Якщо немає рядка, де дата початку співпадає або дата закінчення співпадає - видаємо помилку
                    /*
                    if c.np_dnprav != rec_np.np_dnprav or c.np_dkprav != nvl(rec_np.np_dkprav,c.np_dkprav)
                        then
                        l_pdd_id := 0;
                        exit;
                    end if;
                    */
                    END IF;

                    -- перераховувати загальну суму по PD_Payment при заповненні PD_detail
                    -- IC #90903
                    UPDATE pd_payment ppp
                       SET ppp.pdp_sum =
                               CASE
                                   WHEN c.rn = 1 THEN c.np_snadp
                                   ELSE ppp.pdp_sum + c.np_snadp
                               END
                     WHERE ppp.pdp_id = l_pdp_id;

                    INSERT INTO pd_detail (pdd_id,
                                           pdd_pdp,
                                           pdd_row_order,
                                           pdd_row_name,
                                           pdd_value,
                                           pdd_key,
                                           pdd_ndp,
                                           pdd_start_dt,
                                           pdd_stop_dt,
                                           pdd_npt)
                         VALUES (
                                    NULL,
                                    l_pdp_id,
                                    300,
                                    c.pdd_row_name,
                                    c.np_snadp,
                                    -- rec_np.np_snadp,
                                    c.key_lfdp_id,
                                    290,
                                    NVL (rec_np.rod_dnprav, rec_np.np_dnprav),
                                    NVL (
                                        rec_np.rod_dkprav,
                                        COALESCE (
                                            rec_np.np_dkprav,
                                            TO_DATE ('31.12.2099',
                                                     'dd.mm.yyyy'))),
                                    c.npt_id)
                      RETURNING pdd_id
                           INTO l_pdd_id;

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                         VALUES (c.lfdp_id, l_pdd_id, 'USS_ESR.PD_DETAIL');
                END LOOP;

                -- IC #90903 видавати помилку, якщо по періоду, визначеному в ПЕР, по коду КФН не знайдено відповідного запису в НП
                IF l_pdd_id = 0
                THEN
                    l_error_prm :=
                           'Для обранного коду '
                        || rec_np.np_kfn
                        || ' не знайдено записів за період з '
                        || TO_CHAR (rec_np.np_dnprav, 'dd.mm.yyyy')
                        || ' по '
                        || TO_CHAR (rec_np.np_dkprav, 'dd.mm.yyyy')
                        || ' в масиві NP! Приведіть записи по NP та PER у відповідність';

                    -- просють обмежити контрольку хоча б 2022 роком )
                    IF COALESCE (rec_np.np_dkprav,
                                 TO_DATE ('31.12.2099', 'dd.mm.yyyy')) >=
                       TO_DATE ('01.01.2022', 'mm.dd.yyyy')
                    THEN
                        RAISE ex_error_90903;
                    END IF;
                END IF;
            END IF;

            IF     CASE
                       WHEN p_nptc_nst = 248
                       THEN
                           COALESCE (rec_np.np_dkprav,
                                     TO_DATE ('31.12.2099', 'dd.mm.yyyy'))
                       ELSE
                           rec_np.max_dt
                   END <
                   LAST_DAY (TRUNC (SYSDATE))
               AND rec_np.np_block_psn <> '0'
               AND rec_np.is_last = 1
            THEN
                DECLARE
                    l_rnp   NUMBER;
                BEGIN
                    BEGIN
                        SELECT rnp_id
                          INTO l_rnp
                          FROM uss_ndi.v_ndi_reason_not_pay rnp
                         WHERE     rnp.rnp_code =
                                   'ASOPD' || rec_np.np_block_psn
                               AND rnp.rnp_pay_tp =
                                   CASE
                                       WHEN p_ls_spos = 1 THEN 'POST'
                                       WHEN p_ls_spos = 2 THEN 'BANK'
                                       ELSE NULL
                                   END;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_rnp := 20;
                    END;

                    INSERT INTO pc_block (pcb_id,
                                          pcb_pc,
                                          pcb_pd,
                                          pcb_tp,
                                          pcb_rnp,
                                          pcb_lock_pnp_tp,
                                          pcb_ap_src)
                         VALUES (NULL,
                                 p_pc,
                                 l_pd_id,
                                 'MG',
                                 l_rnp,
                                 'CPX',
                                 l_ap_id)
                      RETURNING pcb_id
                           INTO l_pcb_id;
                END;

                -- select * from uss_ndi.V_DDN_PD_ST;
                UPDATE pc_decision ddd
                   SET ddd.pd_pcb = l_pcb_id, ddd.pd_st = 'PS'
                 WHERE ddd.pd_id = l_pd_id;
            END IF;
        END LOOP;                                    -- конец массива НП (ПЕР)

        -- если решение не создалось
        IF l_pd_id IS NULL
        THEN
            RAISE ex_error_create_pd;
        END IF;

        -- IC #107364 Зробити скрипт по заповненню даних по перевірці права по послузі 901 по мігрованим рішенням, якщо таблиця порожня
        INSERT INTO uss_esr.pd_right_log (prl_id,
                                          prl_pd,
                                          prl_nrr,
                                          prl_result,
                                          prl_calc_result)
              SELECT 0         AS x_prl,
                     pd_id     AS x_pd,
                     nrr_id,
                     'T',
                     'T'
                FROM uss_esr.pc_decision d
                     JOIN uss_ndi.v_ndi_nrr_config nnc
                         ON nnc.nruc_nst = d.pd_nst
                     JOIN uss_ndi.v_ndi_right_rule nrr
                         ON     nrr.nrr_id = nnc.nruc_nrr
                            AND nrr.nrr_alg NOT LIKE 'G.%'
               WHERE     nnc.history_status = 'A'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM uss_esr.pd_right_log l
                               WHERE     l.prl_pd = d.pd_id
                                     AND l.prl_nrr = nrr.nrr_id)
                     AND d.pd_nst = p_nptc_nst                   -- IC #108866
                     AND d.pd_id = l_pd_id
            ORDER BY nrr.nrr_order;

        -- для всех иждивенцев с ИНН создаем карточки
        AddPdFamily (p_lfd_lfd     => p_lfd_lfd,
                     p_ls_nls      => p_ls_nls,
                     p_nptc_nst    => p_nptc_nst,
                     p_pd_id       => l_pd_id,
                     p_ap_id       => l_ap_id,
                     p_aps_id      => l_aps_id,
                     p_np_dnprav   => l_np_dnprav);

        -- Начисления
        Load_Accrual (p_lfd_lfd     => p_lfd_lfd,
                      p_pc          => p_pc,
                      p_pd          => l_pd_id,
                      p_ls_nls      => p_ls_nls,
                      p_ls_org      => p_ls_org,
                      p_ls_npt_id   => p_ls_npt_id);

        -- Отчисления
        Load_Deduction (p_lfd_lfd       => p_lfd_lfd,
                        p_sc            => p_sc,
                        p_pc            => p_pc,
                        p_ap            => l_ap_id,
                        p_pa            => p_pa,
                        p_pd            => l_pd_id,
                        p_ls_nls        => p_ls_nls,
                        p_ls_org        => p_ls_org,
                        p_ls_base_org   => p_ls_base_org,
                        p_ls_npt_id     => p_ls_npt_id);

        -- IC #91515
        DELETE FROM pd_accrual_period
              WHERE pdap_pd = (SELECT pd_id
                                 FROM pc_decision
                                WHERE pd_id = l_pd_id AND pd_st = 'P');

        -- IC #84362
        setImpPrNumByNonpay (p_lfd_lfd, p_ls_nls);
    END;

    -- заполнение начислений
    PROCEDURE Load_Accrual (p_lfd_lfd     NUMBER,
                            p_pc          NUMBER,
                            p_pd          NUMBER,
                            p_ls_nls      VARCHAR2,
                            p_ls_org      VARCHAR2,
                            p_ls_npt_id   NUMBER)
    IS
        l_ac    NUMBER;
        l_acd   NUMBER;
    BEGIN
        -- init block
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        DELETE FROM tmp_work_ids1;

        -- верхний цикл по НАКам
        FOR rec_nac
            IN (  SELECT ROW_NUMBER ()
                             OVER (PARTITION BY nac.nac_mec, nac.nac_god
                                   ORDER BY TO_NUMBER (nac.nac_npp), lfdp_id)
                             AS m_rn,
                         --min(to_date(lpad(nac.nac_mec,2,'0')||'.'||nac.nac_god DEFAULT Null ON CONVERSION ERROR, 'mm.yyyy')) over () as start_nac,  -- пока ненужно
                         --max(to_date(lpad(nac.nac_mec,2,'0')||'.'||nac.nac_god DEFAULT Null ON CONVERSION ERROR, 'mm.yyyy')) over () as end_nac,    -- пока ненужно
                         TO_DATE (
                             LPAD (nac.nac_mec, 2, '0') || '.' || nac.nac_god
                                 DEFAULT NULL ON CONVERSION ERROR,
                             'mm.yyyy')
                             AS nac_dt,
                         nac.*
                    FROM ( -- блок данных на основании НАККФН (за отсутствия НАК)
                            SELECT nac.lfd_id,
                                   nac.lfd_lfd,
                                   nac.lfd_create_dt,
                                   MIN (nac.lfdp_id)
                                       AS lfdp_id,
                                   MIN (nac.rn)
                                       AS rn,
                                   nac.ls_nls,
                                   TO_CHAR (
                                       EXTRACT (
                                           YEAR FROM TO_DATE (
                                                         nac.nac_datop
                                                             DEFAULT NULL ON CONVERSION ERROR,
                                                         'dd.mm.yyyy')))
                                       AS nac_god,
                                   TO_CHAR (
                                       EXTRACT (
                                           MONTH FROM TO_DATE (
                                                          nac.nac_datop
                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                          'dd.mm.yyyy')))
                                       AS nac_mec,
                                   NULL
                                       AS nac_npp,
                                   NULL
                                       AS nac_sved,
                                   NULL
                                       AS nac_nved,
                                   NULL
                                       AS nac_datspis,
                                   NULL
                                       AS bj_neop,
                                   NULL
                                       AS bj_tved,
                                   NULL
                                       AS bj_spos,
                                   NULL
                                       AS nac_indots,
                                   NULL
                                       AS nac_mecn,
                                   NULL
                                       AS nac_godn,
                                   NULL
                                       AS nac_nppn,
                                   NULL
                                       AS nac_tip,
                                   NULL
                                       AS nac_tved
                              FROM uss_exch.v_ls_nackfn_data nac
                             WHERE     nac.lfd_lfd = p_lfd_lfd
                                   AND nac.ls_nls = p_ls_nls
                                   AND nac.nac_god = '0'
                                   AND nac.nac_mec = '0'
                                   AND TO_DATE (
                                           nac.nac_datop
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy')
                                           IS NOT NULL
                                   AND NOT EXISTS
                                           (SELECT 1
                                              FROM uss_exch.v_ls_nac_data n
                                             WHERE     n.lfd_lfd = nac.lfd_lfd
                                                   AND n.ls_nls = nac.ls_nls
                                                   AND TO_DATE (
                                                              LPAD (n.nac_mec,
                                                                    2,
                                                                    '0')
                                                           || '.'
                                                           || n.nac_god
                                                               DEFAULT NULL ON CONVERSION ERROR,
                                                           'mm.yyyy') =
                                                       TRUNC (
                                                           TO_DATE (
                                                               nac.nac_datop
                                                                   DEFAULT NULL ON CONVERSION ERROR,
                                                               'dd.mm.yyyy'),
                                                           'month'))
                                   AND TO_NUMBER (
                                           nac.nac_kfn
                                               DEFAULT NULL ON CONVERSION ERROR) NOT BETWEEN 1001
                                                                                         AND 1100 -- IC #84706 не заповняти відрахування з масиву KFN (якщо значення NAC_KFN in (1001..1100)
                          GROUP BY nac.lfd_id,
                                   nac.lfd_lfd,
                                   nac.lfd_create_dt,
                                   nac.ls_nls,
                                   nac.nac_datop
                          UNION    -- БЛОК нормальнных данных на основании НАК
                          SELECT nac.lfd_id,
                                 nac.lfd_lfd,
                                 nac.lfd_create_dt,
                                 nac.lfdp_id,
                                 nac.rn,
                                 nac.ls_nls,
                                 nac.nac_god,
                                 nac.nac_mec,
                                 nac.nac_npp,
                                 nac.nac_sved,
                                 nac.nac_nved,
                                 nac.nac_datspis,
                                 nac.bj_neop,
                                 nac.bj_tved,
                                 nac.bj_spos,
                                 nac.nac_indots,
                                 nac.nac_mecn,
                                 nac.nac_godn,
                                 nac.nac_nppn,
                                 nac.nac_tip,
                                 nac.nac_tved
                            FROM uss_exch.v_ls_nac_data nac
                           WHERE     nac.lfd_lfd = p_lfd_lfd
                                 AND nac.ls_nls = p_ls_nls
                                 AND TO_DATE (
                                            LPAD (nac.nac_mec, 2, '0')
                                         || '.'
                                         || nac.nac_god
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'mm.yyyy')
                                         IS NOT NULL) nac
                ORDER BY nac_dt, m_rn)
        LOOP
            -- https://redmine.medirent.com.ua/redmine/issues/79599 (2)
            IF rec_nac.m_rn = 1
            THEN
                BEGIN
                    -- вибираем ранее внесенній контейнер по акруалам
                    SELECT ac_id
                      INTO l_ac
                      FROM accrual ac
                     WHERE ac.ac_pc = p_pc AND ac_month = rec_nac.nac_dt;

                    -- заменяем орг на актуальній
                    UPDATE accrual aaa
                       SET aaa.com_org = p_ls_org
                     WHERE aaa.ac_id = l_ac AND aaa.com_org <> p_ls_org;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        -- если не найденно инсертив акруал
                        INSERT INTO accrual (ac_id,
                                             ac_pc,
                                             ac_month,
                                             ac_st,
                                             history_status,
                                             com_org)
                             VALUES (NULL,
                                     p_pc,
                                     rec_nac.nac_dt,
                                     'R',
                                     'A',
                                     p_ls_org)
                          RETURNING ac_id
                               INTO l_ac;
                END;

                INSERT INTO tmp_work_ids1
                     VALUES (l_ac);

                -- АДДДДДДДД
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_nac.lfdp_id, l_ac, 'USS_ESR.ACCRUAL');
            END IF;

            -- детальна інформація щодо нарахувань.
            FOR rec_nackfn
                IN (WITH
                        npt
                        AS
                            (SELECT /*+ materialize*/
                                    --  npt.npt_id,
                                    -- https://redmine.med/issues/84327
                                    CASE
                                        WHEN TO_NUMBER (
                                                 npt.npt_code
                                                     DEFAULT NULL ON CONVERSION ERROR) BETWEEN 1001
                                                                                           AND 1100
                                        THEN
                                            p_ls_npt_id
                                        ELSE
                                            npt.npt_id
                                    END    AS npt_id,
                                    npt.npt_code,
                                    npt.npt_name,
                                    npt.npt_legal_act,
                                    npt.npt_nbg,
                                    npt.history_status,
                                    npt.npt_npc
                               --                                      from uss_esr.v_ndi_payment_type_mg npt
                               FROM uss_ndi.v_ndi_payment_type npt
                              WHERE     npt.history_status = 'A'
                                    -- IC #92346
                                    AND NVL (npt.npt_npc, -1) =
                                        CASE
                                            WHEN npt.npt_code = '256' THEN 42
                                            ELSE NVL (npt.npt_npc, -1)
                                        END
                                    AND getAccessByKFN (
                                            npt.npt_code,
                                            SUBSTR (TO_CHAR (p_ls_org), 1, 3)) =
                                        1)
                      SELECT nk.*,
                             o.op_id,
                             o.op_tp1,
                             npt.npt_id,
                             TO_DATE (
                                 LPAD (nk.nac_mec, 2, '0') || '.' || nk.nac_god
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'mm.yyyy')    AS nackfn_dt,
                             TO_DATE (
                                    LPAD (nk.nac_mecf, 2, '0')
                                 || '.'
                                 || nk.nac_godf
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'mm.yyyy')    AS nackfn_f_dt
                        FROM uss_exch.v_ls_nackfn_data nk
                             JOIN npt
                                 ON     npt.npt_code = nk.nac_kfn
                                    AND npt.history_status = 'A'
                             LEFT JOIN uss_ndi.v_ndi_op o
                                 ON o.op_code = nk.nac_op
                       WHERE     nk.lfd_lfd = rec_nac.lfd_lfd
                             AND nk.ls_nls = rec_nac.ls_nls
                             --and nk.nac_god = rec_nac.nac_god
                             --and nk.nac_mec = rec_nac.nac_mec
                             --and nk.nac_npp = rec_nac.nac_npp
                             -- 11_10_2022 убрал данные три строки как привязку к дате операции, так как большинство записей
                             -- ссылаются на ошибочные записи из массива НАК
                             -- 18.10.2022 вернул но для верхнего цикла создаю записи на основании даты операции из масива v_ls_nackfn_data
                             AND COALESCE (NULLIF (nk.nac_god, '0'),
                                           SUBSTR (nk.nac_datop, 7, 4)) =
                                 rec_nac.nac_god
                             AND COALESCE (
                                     NULLIF (nk.nac_mec, '0'),
                                     TO_CHAR (
                                         TO_NUMBER (
                                             SUBSTR (nk.nac_datop, 4, 2)))) =
                                 rec_nac.nac_mec
                             -- 21102022 - хомут для долгов, вызвано тем что неодназначно определен за номером по попорядку контейнер к которому можно присоединить долг
                             -- присоединяем к тому который по номеру по порядку определен как первый
                             -- and coalesce(nullif(nk.nac_npp,'0'),'1') = rec_nac.nac_npp
                             AND (   (nk.nac_npp = rec_nac.nac_npp)
                                  OR (    nk.nac_god = '0'
                                      AND nk.nac_mec = '0'
                                      AND rec_nac.m_rn = 1))
                             AND TO_NUMBER (
                                     nk.nac_kfn
                                         DEFAULT NULL ON CONVERSION ERROR) NOT BETWEEN 1001
                                                                                   AND 1100 -- IC #84706 не заповняти відрахування з масиву KFN (якщо значення NAC_KFN in (1001..1100)
                    ORDER BY nackfn_dt, nackfn_f_dt)
            LOOP
                -- https://redmine.medirent.com.ua/redmine/issues/79966  (3)
                IF rec_nackfn.nac_op = '5010' AND rec_nackfn.nac_kfn = '0'
                THEN
                    NULL;
                ELSE
                    IF rec_nackfn.op_id IS NULL
                    THEN
                        l_error_prm := rec_nackfn.nac_op;
                        RAISE ex_error_op_accrual;
                    END IF;

                    IF rec_nackfn.npt_id IS NULL
                    THEN
                        l_error_prm :=
                            rec_nackfn.nac_mecf || '.' || rec_nackfn.nac_godf;
                        RAISE ex_error_npt_accrual;
                    END IF;

                    INSERT INTO ac_detail (acd_id,
                                           acd_ac,
                                           acd_op,
                                           acd_npt,
                                           acd_start_dt,
                                           acd_stop_dt,
                                           acd_sum,
                                           acd_month_sum,
                                           acd_delta_recalc,
                                           acd_delta_pay,
                                           acd_dn,
                                           acd_pd,
                                           acd_ac_start_dt,
                                           acd_ac_stop_dt,
                                           acd_is_indexed,
                                           acd_st,
                                           history_status,
                                           acd_payed_sum,
                                           acd_imp_pr_num)
                         VALUES (
                                    NULL,
                                    l_ac,
                                    rec_nackfn.op_id,
                                    rec_nackfn.npt_id,
                                    rec_nackfn.nackfn_f_dt,
                                      ADD_MONTHS (rec_nackfn.nackfn_f_dt, 1)
                                    - 1,
                                    rec_nackfn.nac_snac,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    p_pd,
                                    rec_nac.nac_dt,
                                    ADD_MONTHS (rec_nac.nac_dt, 1) - 1,
                                    'F',
                                    'R',
                                    'A',
                                    CASE
                                        WHEN     rec_nac.Bj_Neop = 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nackfn.nac_snac
                                        WHEN     rec_nac.Bj_Neop = 1
                                             AND rec_nac.nac_godn <> 0
                                             AND rec_nac.nac_mecn <> 0
                                             AND rec_nac.nac_nppn <> 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nackfn.nac_snac
                                        ELSE
                                            NULL
                                    END,
                                    CASE
                                        WHEN     rec_nac.Bj_Neop = 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nac.nac_nved
                                        WHEN     rec_nac.Bj_Neop = 1
                                             AND rec_nac.nac_nppn <> 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nac.nac_nppn
                                        ELSE
                                            NULL
                                    END)
                      RETURNING acd_id
                           INTO l_acd;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_nackfn.lfdp_id,
                                     l_acd,
                                     'USS_ESR.AC_DETAIL');

                    -- за даним рішенням є наразування, тобто переводемо рішення в статус Нараховано = S
                    -- убрал по команде КЕВ также как и поставил по команде КЕВ
                    -- поставил по команде КЕВ
                    UPDATE pc_decision ddd
                       SET ddd.pd_st = 'S'
                     WHERE     ddd.pd_id = p_pd
                           AND rec_nackfn.op_tp1 = 'NR'
                           AND ddd.pd_st = 'P';

                    -- IC #92564
                    -- Якщо мігруємо рядок з масиву KFN, де є неоплата, потрібно перевіряти AC_ST по тому місяцю, куди ми прив'язуємо нарахування.
                    -- Якщо AC_ST = 'RP', то змінювати статус на 'R'
                    UPDATE accrual aaa
                       SET aaa.ac_st = 'R'
                     WHERE     aaa.ac_id = l_ac
                           AND aaa.ac_st = 'RP'
                           AND rec_nac.Bj_Neop = 1;
                END IF;
            END LOOP;
        END LOOP;
    -- от Павлюкова и Никоновой какое то апи через tmp_work_ids1
    -- actuilize_payed_sum(2);
    END;

    PROCEDURE Load_Deduction (p_lfd_lfd       NUMBER,  -- группа файлов(архив)
                              p_sc            NUMBER,            -- socialcard
                              p_pc            NUMBER,          -- personalcase
                              p_ap            NUMBER,                -- appeal
                              p_pa            NUMBER,
                              p_pd            NUMBER,
                              p_ls_nls        VARCHAR2,
                              p_ls_org        VARCHAR2,
                              p_ls_base_org   VARCHAR2,
                              p_ls_npt_id     NUMBER)
    IS
        --l_ap          number;
        l_ps             NUMBER;
        l_dn             NUMBER;
        l_dnd            NUMBER;
        l_ndn            NUMBER;
        l_dpp            NUMBER;
        l_dppa           NUMBER;
        l_nb             NUMBER;
        l_psc            NUMBER;

        l_ac             NUMBER;
        l_acd            NUMBER;

        l_dn_stop_dt     DATE;
        l_nudr_dt        DATE;
        l_imp_pr_num     VARCHAR2 (128);
        l_ls_kfn         uss_exch.v_ls_data.ls_kfn%TYPE;

        l_dnd_nl_tp      dn_detail.dnd_nl_tp%TYPE;
        l_dnd_nl_value   dn_detail.dnd_nl_value%TYPE;
        l_ps_sc          pd_family.pdf_sc%TYPE;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_ispl
            IN (SELECT --+ index(i) index(u) index(v) use_nl(i u) use_nl(i v) index(np use_nl(i np))
                       TO_DATE (u.ud_dso, 'dd.mm.yyyy')
                           AS ud_dso,
                       i.lfd_id,
                       i.lfd_lfd,
                       i.lfd_records,
                       i.lfd_create_dt,
                       i.lfdp_id,
                       i.rn,
                       i.ls_nls,
                       i.ispl_kud,
                       i.ispl_num,
                       TO_DATE (i.ispl_dpd, 'dd.mm.yyyy')
                           AS ispl_dpd,
                       i.ispl_vhn,
                       i.ispl_kd,
                       i.ispl_nd,
                       TO_DATE (i.ispl_dv DEFAULT NULL ON CONVERSION ERROR,
                                'dd.mm.yyyy')
                           ispl_dv,
                       i.ispl_kvz,                              -- 0-фіз.особа
                       i.ispl_kold,
                       i.ispl_postdolg,
                       CASE
                           WHEN TO_NUMBER (
                                    i.ispl_ost DEFAULT 0 ON CONVERSION ERROR) > -- IC #84706
                                TO_NUMBER (
                                    i.ispl_dolg DEFAULT 0 ON CONVERSION ERROR)
                           THEN
                               i.ispl_ost
                           ELSE
                               i.ispl_dolg
                       END
                           ispl_dolg,
                       i.ispl_sp,
                       i.ispl_sumud,
                       i.ispl_srud,
                       i.ispl_persud,
                       i.ispl_persud1,
                       TO_DATE (i.ispl_displ, 'dd.mm.yyyy')
                           AS ispl_displ,
                       i.ispl_spos,
                       i.ispl_kdp,
                       i.ispl_ost,
                       i.ispl_gor,
                       i.ispl_kin,
                       u.ud_psn,
                       v.klovud_code,
                       v.klovud_name,
                       v.klovud_nrsb,
                       v.klovud_nrso,
                       v.klovud_dopnr,
                       v.klovud_privo,
                       v.klovud_nameb,
                       v.klovud_mfo,
                       v.klovud_indpo,
                       v.klovud_adr,
                       v.klovud_prim,
                       i.ispl_rudp,
                       (SELECT ppl_prizn
                          FROM uss_exch.v_ls_ppl_data ppl
                         WHERE     ppl.lfd_lfd = i.lfd_lfd
                               AND ppl.ls_nls = i.Ls_Nls
                               AND ppl_sum = ispl_dolg
                         FETCH FIRST ROW ONLY)
                           AS ppl_prizn,
                       -- IC #92589
                       CASE
                           WHEN i.ispl_sp = '1' THEN 'PD'
                           WHEN i.ispl_sp = '2' THEN 'AS'
                           WHEN i.ispl_sp = '3' THEN 'SD'
                           WHEN i.ispl_sp = '4' THEN 'AS'
                           WHEN i.ispl_sp = '5' THEN 'PD'
                           WHEN i.ispl_sp = '6' THEN 'AS'
                           WHEN i.ispl_sp = '0' THEN '0' -- ігноруємо (не створюємо відрахування)
                           ELSE ''
                       END
                           AS unit,
                       ROW_NUMBER ()
                           OVER (
                               PARTITION BY i.lfdp_id
                               ORDER BY
                                   NVL2 (
                                       np.ls_nls,
                                       TO_DATE (
                                           np.np_dnprav
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy'),
                                       TO_DATE (i.ispl_displ, 'dd.mm.yyyy')))
                           AS npp,
                       NVL2 (np.ls_nls, np.lfdp_id, i.lfdp_id)
                           AS dn_lfdp_id,
                       NVL2 (np.ls_nls, 1, 0)
                           AS is_np_199,
                       NVL2 (np.ls_nls,
                             100 - TO_NUMBER (np.np_pr),
                             TO_NUMBER (i.ispl_persud))
                           AS np_pr,
                       GREATEST (
                           NVL2 (
                               np.ls_nls,
                               TO_DATE (
                                   np.np_dnprav
                                       DEFAULT NULL ON CONVERSION ERROR,
                                   'dd.mm.yyyy'),
                               TO_DATE (i.ispl_displ, 'dd.mm.yyyy')),
                           TO_DATE (i.ispl_displ, 'dd.mm.yyyy'))
                           AS dn_start,
                       NVL2 (
                           np.ls_nls,
                           TO_DATE (
                               np.np_dkprav DEFAULT NULL ON CONVERSION ERROR,
                               'dd.mm.yyyy'),
                           TO_DATE (u.ud_dso, 'dd.mm.yyyy'))
                           AS dn_stop,
                       CASE
                           WHEN u.ud_dso IS NULL OR NVL (u.Ud_Psn, '0') = '7' -- IC #89930
                           THEN
                               'R'
                           ELSE
                               'Z'
                       END
                           dn_st,
                       /*
                       case when i.ispl_kud in ('1','2','3') then 'D'                            -- аліменти
                         when i.ispl_kud in ('17','20','21','22','25','30') then 'D'             -- держутримання
                         else 'R' end dn_tp                                                      -- переплата і ішне
                         */
                       NVL (ndn.ndn_dn_tp, 'D')
                           dn_tp,
                       CASE
                           WHEN     ndn.ndn_calc_step = 'F'
                                AND NVL (ndn.ndn_dn_tp, 'D') = 'D'
                           THEN
                               1
                           ELSE
                               0
                       END
                           is_nrh, -- IC #91416 Це все обмежити лише по типам утримання
                       --case  when i.ispl_kdp in ('2','3','6','7','10','18','66','67','71','75','79') then 30 -- IC #91304
                       --      when i.ispl_kdp in ('16','17','20','21','24','80','81','85','87','89','93') then 50
                       --  else null end dnd_value, -- persud
                       CASE
                           WHEN i.ispl_kud IN ('17',
                                               '20',
                                               '21',
                                               '22',
                                               '25',
                                               '30') -- IC #95417 (якщо держутримання)
                           THEN
                               NVL2 (np.ls_nls,
                                     100 - TO_NUMBER (np.np_pr),
                                     TO_NUMBER (i.ispl_persud))
                           ELSE
                               TO_NUMBER (i.ispl_persud)
                       END
                           dnd_value,
                       -- i.ispl_persud dnd_value,
                       CASE
                           WHEN i.Ispl_Sp IN ('3') THEN i.ispl_persud1
                           ELSE NULL
                       END
                           dnd_value_prefix
                  FROM uss_exch.v_ls_ispl_data  i
                       LEFT JOIN uss_exch.v_ls_ud_data u
                           ON     u.lfd_lfd = i.lfd_lfd
                              AND u.ls_nls = i.ls_nls
                              AND u.ispl_kud = i.ispl_kud
                              AND u.ispl_num = i.ispl_num
                       JOIN uss_exch.v_b_klovud v
                           ON     v.klovud_code = i.ispl_kvz
                              AND v.lfd_lfd = i.lfd_lfd
                       LEFT JOIN uss_exch.v_ls_np_data np
                           ON     np.lfd_lfd = i.lfd_lfd
                              AND np.ls_nls = i.Ls_Nls
                              AND np.np_kfn = '199'
                              AND np.Np_Pr <> '100'
                              AND (   TO_DATE (
                                          np.np_dnprav
                                              DEFAULT NULL ON CONVERSION ERROR,
                                          'dd.mm.yyyy') BETWEEN TO_DATE (
                                                                    i.ispl_displ,
                                                                    'dd.mm.yyyy')
                                                            AND COALESCE (
                                                                    TO_DATE (
                                                                        u.ud_dso,
                                                                        'dd.mm.yyyy'),
                                                                    TO_DATE (
                                                                        '31.12.2099',
                                                                        'dd.mm.yyyy'))
                                   OR                            -- IC #102629
                                      TO_DATE (
                                          np.np_dkprav
                                              DEFAULT NULL ON CONVERSION ERROR,
                                          'dd.mm.yyyy') BETWEEN TO_DATE (
                                                                    i.ispl_displ,
                                                                    'dd.mm.yyyy')
                                                            AND COALESCE (
                                                                    TO_DATE (
                                                                        u.ud_dso,
                                                                        'dd.mm.yyyy'),
                                                                    TO_DATE (
                                                                        '31.12.2099',
                                                                        'dd.mm.yyyy')))
                              AND TO_NUMBER (
                                      np.np_snadp
                                          DEFAULT 0 ON CONVERSION ERROR) >
                                  0
                       LEFT JOIN uss_ndi.v_ndi_deduction ndn
                           ON     ndn.ndn_code = i.ispl_kud
                              AND ndn.history_status = 'A'
                 WHERE i.lfd_lfd = p_lfd_lfd AND i.ls_nls = p_ls_nls
                UNION ALL
                SELECT --+ index(i) index(u) index(v) use_nl(i u) use_nl(i v) index(np use_nl(i np))
                       TO_DATE (u.ud_dso, 'dd.mm.yyyy')
                           AS ud_dso,
                       i.lfd_id,
                       i.lfd_lfd,
                       i.lfd_records,
                       i.lfd_create_dt,
                       i.lfdp_id,
                       i.rn,
                       i.ls_nls,
                       i.ispl_kud,
                       i.ispl_num,
                       TO_DATE (i.ispl_dpd, 'dd.mm.yyyy')
                           AS ispl_dpd,
                       i.ispl_vhn,
                       i.ispl_kd,
                       i.ispl_nd,
                       TO_DATE (i.ispl_dv DEFAULT NULL ON CONVERSION ERROR,
                                'dd.mm.yyyy')
                           ispl_dv,
                       i.ispl_kvz,
                       i.ispl_kold,
                       i.ispl_postdolg,
                       CASE
                           WHEN TO_NUMBER (
                                    i.ispl_ost DEFAULT 0 ON CONVERSION ERROR) > -- IC #84706
                                TO_NUMBER (
                                    i.ispl_dolg DEFAULT 0 ON CONVERSION ERROR)
                           THEN
                               i.ispl_ost
                           ELSE
                               i.ispl_dolg
                       END
                           ispl_dolg,
                       i.ispl_sp,
                       i.ispl_sumud,
                       i.ispl_srud,
                       i.ispl_persud,
                       i.ispl_persud1,
                       TO_DATE (i.ispl_displ, 'dd.mm.yyyy')
                           AS ispl_displ,
                       i.ispl_spos,
                       i.ispl_kdp,
                       i.ispl_ost,
                       i.ispl_gor,
                       i.ispl_kin,
                       u.ud_psn,
                       v.klovud_code,
                       v.klovud_name,
                       v.klovud_nrsb,
                       v.klovud_nrso,
                       v.klovud_dopnr,
                       v.klovud_privo,
                       v.klovud_nameb,
                       v.klovud_mfo,
                       v.klovud_indpo,
                       v.klovud_adr,
                       v.klovud_prim,
                       i.ispl_rudp,
                       (SELECT ppl_prizn
                          FROM uss_exch.v_ls_ppl_data ppl
                         WHERE     ppl.lfd_lfd = i.lfd_lfd
                               AND ppl.ls_nls = i.Ls_Nls
                               AND ppl_sum = ispl_dolg
                         FETCH FIRST ROW ONLY)
                           AS ppl_prizn,
                       -- IC #92589
                       CASE
                           WHEN i.ispl_sp = '1' THEN 'PD'
                           WHEN i.ispl_sp = '2' THEN 'AS'
                           WHEN i.ispl_sp = '3' THEN 'SD'
                           WHEN i.ispl_sp = '4' THEN 'AS'
                           WHEN i.ispl_sp = '5' THEN 'PD'
                           WHEN i.ispl_sp = '6' THEN 'AS'
                           WHEN i.ispl_sp = '0' THEN '0' -- ігноруємо (не створюємо відрахування)
                           ELSE ''
                       END
                           AS unit,
                       ROW_NUMBER ()
                           OVER (
                               PARTITION BY i.lfdp_id
                               ORDER BY TO_DATE (i.ispl_displ, 'dd.mm.yyyy'))
                           AS npp,
                       i.lfdp_id
                           AS dn_lfdp_id,
                       0
                           AS is_np_199,
                       TO_NUMBER (i.ispl_persud)
                           AS np_pr,
                       TO_DATE (i.ispl_displ, 'dd.mm.yyyy')
                           AS dn_start,
                       TO_DATE (u.ud_dso, 'dd.mm.yyyy')
                           AS dn_stop,
                       CASE
                           WHEN u.ud_dso IS NULL OR NVL (u.Ud_Psn, '0') = '7' -- IC #89930
                           THEN
                               'R'
                           ELSE
                               'Z'
                       END
                           dn_st,
                       /*
                       case when i.ispl_kud in ('1','2','3') then 'D'                            -- аліменти
                         when i.ispl_kud in ('17','20','21','22','25','30') then 'D'             -- держутримання
                         else 'R' end dn_tp                                                      -- переплата і ішне
                         */
                       NVL (ndn.ndn_dn_tp, 'D')
                           dn_tp,
                       CASE
                           WHEN     ndn.ndn_calc_step = 'F'
                                AND NVL (ndn.ndn_dn_tp, 'D') = 'D'
                           THEN
                               1
                           ELSE
                               0
                       END
                           is_nrh, -- IC #91416 Це все обмежити лише по типам утримання
                       -- case  when i.ispl_kdp in ('2','3','6','7','10','18','66','67','71','75','79') then 30 -- IC #91304
                       --      when i.ispl_kdp in ('16','17','20','21','24','80','81','85','87','89','93') then 50
                       --  else null end dnd_value,
                       TO_NUMBER (i.ispl_persud)
                           dnd_value,
                       CASE
                           WHEN i.Ispl_Sp IN ('3') THEN i.ispl_persud1
                           ELSE NULL
                       END
                           dnd_value_prefix
                  FROM uss_exch.v_ls_ispl_data  i
                       LEFT JOIN uss_exch.v_ls_ud_data u
                           ON     u.lfd_lfd = i.lfd_lfd
                              AND u.ls_nls = i.ls_nls
                              AND u.ispl_kud = i.ispl_kud
                              AND u.ispl_num = i.ispl_num
                       LEFT JOIN uss_exch.v_b_klovud v
                           ON     v.klovud_code = i.ispl_kvz
                              AND v.lfd_lfd = i.lfd_lfd
                       LEFT JOIN uss_ndi.v_ndi_deduction ndn
                           ON     ndn.ndn_code = i.ispl_kud
                              AND ndn.history_status = 'A'
                 WHERE     i.lfd_lfd = p_lfd_lfd
                       AND i.ls_nls = p_ls_nls
                       AND v.lfdp_id IS NULL
                ORDER BY lfdp_id, npp)
        LOOP
            l_dpp := NULL;
            l_dppa := NULL;
            l_nb := NULL;
            l_ndn := NULL;
            l_psc := NULL;

            -- СОЗДАНИЕ КОНТЕЙНЕРА
            IF rec_ispl.npp = 1
            THEN
                -- PC_STATE_ALIMONY
                IF rec_ispl.ispl_kvz > 0
                THEN
                    IF rec_ispl.klovud_code IS NOT NULL
                    THEN
                        -- отримувачі та платники (справочник отримувачыв та платникыв) - если нет записи добавляем
                        BEGIN
                            SELECT npp.dpp_id
                              INTO l_dpp
                              FROM uss_ndi.v_ndi_pay_person npp
                             WHERE     npp.dpp_tax_code =
                                       rec_ispl.klovud_nrsb /*and npp.dpp_org = p_ls_base_org*/
                                   AND npp.history_status = 'A'
                             FETCH FIRST ROWS ONLY;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                BEGIN
                                    SELECT npp.dpp_id
                                      INTO l_dpp
                                      FROM uss_ndi.v_ndi_pay_person npp
                                     WHERE npp.dpp_tax_code =
                                           rec_ispl.klovud_nrsb /*and npp.dpp_org = p_ls_org*/
                                     FETCH FIRST ROWS ONLY;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                        INSERT INTO uss_ndi.ndi_pay_person (
                                                        dpp_id,
                                                        dpp_tax_code,
                                                        dpp_name,
                                                        dpp_org,
                                                        history_status,
                                                        dpp_sname,
                                                        dpp_address,
                                                        dpp_tp,
                                                        dpp_is_ur,
                                                        dpp_hs_upd,
                                                        dpp_hs_del)
                                             VALUES (
                                                        NULL,
                                                        rec_ispl.klovud_nrsb,
                                                        rec_ispl.klovud_name,
                                                        p_ls_org,
                                                        'A',
                                                        rec_ispl.klovud_name,
                                                           rec_ispl.klovud_indpo
                                                        || ', '
                                                        || rec_ispl.klovud_adr,
                                                        'STAL',
                                                        'TRUE',
                                                        NULL,
                                                        NULL)
                                          RETURNING dpp_id
                                               INTO l_dpp;
                                END;
                        END;

                        -- рассчетніе счета для отримувача та платника
                        BEGIN
                            SELECT nppa.dppa_id
                              INTO l_dppa
                              FROM uss_ndi.ndi_pay_person_acc nppa
                             WHERE     nppa.dppa_dpp = l_dpp
                                   AND nppa.dppa_account =
                                       rec_ispl.klovud_nrso
                                   AND nppa.history_status = 'A'
                                   AND ROWNUM = 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN -- не найдені рассчетніе счета для отримувача та платника - необходимо дозаполнить
                                -- Чи є повний рахунок (29 символів) - якщо не 29 символів, тоді не додаємо
                                IF LENGTH (rec_ispl.klovud_nrso) = 29 -- IC #89942
                                THEN
                                    BEGIN
                                        -- находим банк по мфо
                                        SELECT b.nb_id
                                          INTO l_nb
                                          FROM uss_ndi.v_ndi_bank b
                                         WHERE     b.nb_mfo =
                                                   COALESCE (
                                                       NULLIF (
                                                           rec_ispl.klovud_mfo,
                                                           '0'),
                                                       SUBSTR (
                                                           rec_ispl.klovud_nrso,
                                                           5,
                                                           6))
                                               AND b.history_status = 'A';
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            l_nb := NULL;
                                    END;

                                    -- если ненайдено то вствавляем инфу про банки
                                    INSERT INTO uss_ndi.ndi_pay_person_acc (
                                                    dppa_id,
                                                    dppa_dpp,
                                                    dppa_nb,
                                                    dppa_is_main,
                                                    dppa_ab_id,
                                                    history_status,
                                                    dppa_account,
                                                    dppa_nbg,
                                                    dppa_is_social,
                                                    dppa_last_payment_order,
                                                    dppa_hs_upd,
                                                    dppa_hs_del,
                                                    dppa_description)
                                         VALUES (
                                                    NULL,
                                                    l_dpp,
                                                    l_nb,
                                                    CASE
                                                        WHEN EXISTS
                                                                 (SELECT 1
                                                                    FROM uss_ndi.ndi_pay_person_acc
                                                                         nppa
                                                                   WHERE     nppa.dppa_dpp =
                                                                             l_dpp
                                                                         AND nppa.dppa_is_main =
                                                                             1
                                                                         AND nppa.history_status =
                                                                             'A')
                                                        THEN
                                                            0
                                                        ELSE
                                                            1
                                                    END, -- dppa_is_main якщо є основний, проставляємо 0
                                                    NULL,
                                                    'A',
                                                    rec_ispl.klovud_nrso,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    rec_ispl.klovud_prim)
                                      RETURNING dppa_id
                                           INTO l_dppa;
                                END IF;
                        END;

                        -- держутримання  -- issues/82196
                        -- https://redmine.medirent.com.ua/issues/83826
                        -- Держутримання (ispl_kud in ('17','20','21','22','25','30')) - зараз є, але уточнення по типам створюємо записи в таблиці PC_STATE_ALIMONY
                        IF rec_ispl.ispl_kud IN ('17',
                                                 '20',
                                                 '21',
                                                 '22',
                                                 '25',
                                                 '30')
                        THEN
                            BEGIN
                                  -- IC #101700
                                  -- при заповненні PC_STATE_ALIMONY в полі PS_SC треба писати особу, на яку йдуть нарахування по коду npt_id = 219 в таблиці pd_detail
                                  SELECT f.pdf_sc
                                    INTO l_ps_sc
                                    FROM uss_esr.pc_decision d
                                         INNER JOIN uss_esr.pd_payment p
                                             ON p.pdp_pd = d.pd_id
                                         INNER JOIN uss_esr.pd_detail pd
                                             ON     pd.pdd_pdp = p.pdp_id
                                                AND pd.pdd_npt = 219
                                         INNER JOIN uss_esr.pd_family f
                                             ON     f.pdf_pd = d.pd_id
                                                AND f.pdf_id = pd.pdd_key
                                   WHERE     p.history_status = 'A'
                                         AND d.pd_ap = p_ap
                                ORDER BY p.pdp_start_dt DESC,
                                         p.pdp_id DESC,
                                         pd.pdd_id DESC
                                   FETCH FIRST ROWS ONLY;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    l_ps_sc := p_sc;
                            END;

                            INSERT INTO pc_state_alimony (ps_id,
                                                          ps_pc,
                                                          ps_dpp,
                                                          ps_start_dt,
                                                          ps_stop_dt,
                                                          ps_ap,
                                                          ps_hs_ins,
                                                          ps_st,
                                                          ps_sc)
                                 VALUES (NULL,
                                         p_pc,
                                         l_dpp,
                                         rec_ispl.ispl_displ,
                                         rec_ispl.Ud_Dso,
                                         p_ap,
                                         NULL,
                                         rec_ispl.dn_st,
                                         l_ps_sc)
                              RETURNING ps_id
                                   INTO l_ps;
                        ELSE
                            l_ps := NULL;
                        END IF;
                    ELSE
                        l_error_prm := rec_ispl.ispl_kvz;
                        RAISE ex_error_klovud_deduction;
                    END IF;
                END IF;

                -- инициализация дополнительніх справочников
                BEGIN
                    SELECT dic.ndn_id
                      INTO l_ndn
                      FROM uss_ndi.v_ndi_deduction dic
                     WHERE dic.ndn_code = rec_ispl.ispl_kud;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_error_prm := rec_ispl.ispl_kud;
                        RAISE ex_error_kud_deduction;
                END;

                ----------------------------------------------------------------------------------------------
                IF rec_ispl.ispl_kud IN ('1', '2', '3')
                THEN
                    BEGIN
                          SELECT TO_DATE (
                                     det.Ispl_Datae
                                         DEFAULT NULL ON CONVERSION ERROR,
                                     'dd.mm.yyyy')    dt
                            INTO l_dn_stop_dt
                            FROM uss_exch.v_ls_det_data det
                           WHERE     det.Ls_Nls = rec_ispl.ls_nls
                                 AND det.lfd_lfd = rec_ispl.lfd_lfd
                                 AND det.Ispl_Kud = rec_ispl.ispl_kud
                                 AND det.Ispl_num = rec_ispl.ispl_num
                        ORDER BY dt DESC NULLS LAST
                           FETCH FIRST ROWS ONLY;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_dn_stop_dt := rec_ispl.Ud_Dso;
                    END;
                END IF;

                -- вставка утримань
                IF rec_ispl.unit != '0'
                THEN                                                        --
                    INSERT INTO deduction (dn_id,
                                           dn_pc,
                                           dn_ndn,
                                           dn_in_doc_tp,
                                           dn_in_doc_num,
                                           dn_in_doc_dt,
                                           dn_out_doc_num,
                                           dn_out_doc_dt,
                                           dn_unit,
                                           dn_st,
                                           history_status,
                                           dn_debt_total,
                                           dn_debt_current,
                                           dn_is_min_pay,
                                           dn_debt_post,
                                           dn_prc_above,
                                           dn_block_dt,
                                           dn_block_reason,
                                           dn_start_dt,
                                           dn_stop_dt,
                                           dn_unlock_dt,
                                           com_org,
                                           dn_ps,
                                           dn_ap,
                                           dn_dpp,
                                           dn_pa,
                                           dn_reason,
                                           dn_debt_limit_prc,
                                           dn_tp,
                                           dn_params_src)
                         VALUES (
                                    NULL,
                                    p_pc,
                                    l_ndn,
                                    rec_ispl.ispl_kd,
                                    rec_ispl.Ispl_Vhn,
                                    rec_ispl.Ispl_Dpd,
                                    rec_ispl.Ispl_Nd,
                                    rec_ispl.ispl_dv,
                                    rec_ispl.unit,
                                    rec_ispl.dn_st,
                                    'A',
                                    rec_ispl.Ispl_Dolg,
                                    rec_ispl.Ispl_Ost,
                                    'F',
                                    rec_ispl.Ispl_PostDolg,
                                    NULL,
                                    rec_ispl.Ud_Dso,
                                    rec_ispl.Ud_Psn,
                                    rec_ispl.ispl_displ,
                                    COALESCE (l_dn_stop_dt, rec_ispl.Ud_Dso),
                                    NULL,
                                    p_ls_org,
                                    l_ps,
                                    p_ap,
                                    NVL (
                                        l_dpp,
                                        (SELECT MAX (dpp_id)
                                           FROM uss_ndi.v_ndi_pay_person
                                          WHERE     history_status = 'A'
                                                AND dpp_tp = 'OSZN'
                                                AND dpp_org = 50000)),
                                    p_pa,
                                    rec_ispl.ppl_prizn,
                                    -- ТН сказала ppl_prizn использовать для всех - (надо для всех - єто причина возникновения переплат)
                                    --case when rec_ispl.Ud_Dso is not null then rec_ispl.ppl_prizn else null end,
                                    CASE
                                        WHEN TO_NUMBER (
                                                 rec_ispl.ispl_rudp
                                                     DEFAULT 0 ON CONVERSION ERROR) >
                                             0
                                        THEN
                                            TO_NUMBER (rec_ispl.ispl_rudp) -- IC #91163
                                        -- when rec_ispl.ispl_kdp in ('2','3','6','7','10','18','66','67','71','75','79') then 30 -- IC #91079
                                        -- when rec_ispl.ispl_kdp in ('16','17','20','21','24','80','81','85','87','89','93') then 50
                                        WHEN    rec_ispl.Ud_Dso IS NOT NULL
                                             OR rec_ispl.unit = 'AS' --  IC #88070
                                        THEN
                                            NULL
                                        ELSE
                                            TO_NUMBER (rec_ispl.ispl_persud)
                                    END,
                                    rec_ispl.dn_tp,
                                    'DND')                        -- IC #94042
                      RETURNING dn_id
                           INTO l_dn;

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                         VALUES (rec_ispl.lfdp_id, l_dn, 'USS_ESR.DEDUCTION');
                END IF;                                -- rec_ispl.unit != '0'

                DECLARE
                    l_dnp_id   NUMBER;
                BEGIN
                    FOR rec_det
                        IN (SELECT det.lfd_id,
                                   det.lfdp_id,
                                   det.ls_nls,
                                   det.ispl_kud,
                                   det.ispl_num,
                                   TO_DATE (det.ispl_datar, 'dd.mm.yyyy')
                                       AS ispl_datar,
                                   TO_DATE (det.ispl_datae, 'dd.mm.yyyy')
                                       AS ispl_datae
                              FROM uss_exch.v_ls_det_data det
                             WHERE     det.Ls_Nls = rec_ispl.ls_nls
                                   AND det.lfd_lfd = rec_ispl.lfd_lfd
                                   AND det.Ispl_Kud = rec_ispl.ispl_kud
                                   AND det.Ispl_num = rec_ispl.ispl_num)
                    LOOP
                        INSERT INTO dn_person (dnp_id,
                                               dnp_dn,
                                               dnp_start_dt,
                                               dnp_stop_dt,
                                               dnp_birth_dt,
                                               history_status,
                                               -- IC #92589
                                               dnp_tp,
                                               dnp_value,
                                               dnp_value_prefix)
                             VALUES (
                                        NULL,
                                        l_dn,
                                        rec_det.ispl_datar,
                                        rec_det.ispl_datae,
                                        rec_det.ispl_datar,
                                        'A',
                                        rec_ispl.unit,
                                        NVL (rec_ispl.dnd_value,
                                             rec_ispl.np_pr),
                                        rec_ispl.dnd_value_prefix)
                          RETURNING dnp_id
                               INTO l_dnp_id;

                        -- ADDDDD
                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_det.lfdp_id,
                                         l_dnp_id,
                                         'USS_ESR.DN_PERSON');
                    END LOOP;
                END;

                BEGIN
                    -- IC #86423 (Переплати)
                    -- По діючим записам масиву PPL створювати запис з ACD_OP = 6
                    FOR rec_ppl
                        IN (SELECT ppl.lfdp_id,
                                   npt.npt_id,                      -- ACD_NPT
                                   TRUNC (
                                       TO_DATE (
                                           ppl.ppl_dateobn
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy'),
                                       'mm')                                 ac_month,
                                   TO_DATE (
                                       ppl.ppl_dateps
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy')                         acd_start_dt,
                                   TO_DATE (
                                       ppl.ppl_datepk
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy')                         acd_stop_dt,
                                   TO_NUMBER (
                                       ppl.ppl_sum
                                           DEFAULT 0 ON CONVERSION ERROR)    acd_sum
                              FROM uss_exch.v_ls_ppl_data  ppl
                                   INNER JOIN uss_ndi.v_ndi_payment_type npt
                                       ON     npt.npt_code = ppl.ppl_kfn
                                          AND npt.history_status = 'A'
                                          -- IC #92346
                                          AND NVL (npt.npt_npc, -1) =
                                              CASE
                                                  WHEN npt.npt_code = '256'
                                                  THEN
                                                      42
                                                  ELSE
                                                      NVL (npt.npt_npc, -1)
                                              END
                                          AND getAccessByKFN (
                                                  npt.npt_code,
                                                  SUBSTR (TO_CHAR (p_ls_org),
                                                          1,
                                                          3)) =
                                              1
                             WHERE     ppl.lfd_lfd = rec_ispl.lfd_lfd
                                   AND ppl.ls_nls = rec_ispl.ls_nls
                                   AND TO_DATE (
                                           ppl.ppl_dateobn
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy')
                                           IS NOT NULL
                                   AND TO_NUMBER (
                                           ppl.ppl_sum
                                               DEFAULT 0 ON CONVERSION ERROR) !=
                                       0)
                    LOOP
                        BEGIN
                            -- вибираем ранее внесенній контейнер по акруалам
                            SELECT ac_id
                              INTO l_ac
                              FROM accrual ac
                             WHERE     ac.ac_pc = p_pc
                                   AND ac_month = rec_ppl.ac_month;

                            -- заменяем орг на актуальній
                            UPDATE accrual aaa
                               SET aaa.com_org = p_ls_org
                             WHERE     aaa.ac_id = l_ac
                                   AND aaa.com_org <> p_ls_org;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                -- если не найденно инсертив акруал
                                INSERT INTO accrual (ac_id,
                                                     ac_pc,
                                                     ac_month,
                                                     ac_st,
                                                     history_status,
                                                     com_org)
                                     VALUES (NULL,
                                             p_pc,
                                             rec_ppl.ac_month,
                                             'R',
                                             'A',
                                             p_ls_org)
                                  RETURNING ac_id
                                       INTO l_ac;

                                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                               ldr_trg,
                                                               ldr_code)
                                         VALUES (rec_ppl.lfdp_id,
                                                 l_ac,
                                                 'USS_ESR.ACCRUAL');
                        END;

                        INSERT INTO tmp_work_ids1
                             VALUES (l_ac);

                        INSERT INTO ac_detail (acd_id,
                                               acd_ac,
                                               acd_op,
                                               acd_npt,
                                               acd_start_dt,
                                               acd_stop_dt,
                                               acd_sum,
                                               acd_dn,
                                               acd_pd,
                                               acd_ac_start_dt,
                                               acd_ac_stop_dt,
                                               acd_is_indexed,
                                               acd_st,
                                               history_status,
                                               acd_payed_sum,
                                               acd_prsd,
                                               acd_imp_pr_num)
                             VALUES (NULL,
                                     l_ac,
                                     6,                          -- ACD_OP = 6
                                     rec_ppl.npt_id,
                                     rec_ppl.acd_start_dt,
                                     rec_ppl.acd_stop_dt,
                                     rec_ppl.acd_sum, -- PPL_SUM (Сума переплати)
                                     l_dn,
                                     p_pd,
                                     rec_ppl.ac_month,
                                     LAST_DAY (rec_ppl.ac_month),
                                     NULL,
                                     'H',
                                     'A',
                                     NULL,
                                     NULL,
                                     NULL)
                          RETURNING acd_id
                               INTO l_acd;

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_ppl.lfdp_id,
                                         l_acd,
                                         'USS_ESR.AC_DETAIL');
                    END LOOP;
                END;

                --        tt_date := datearray();
                DELETE tmp_work_set1
                 WHERE 1 = 1;

                l_ls_kfn := NULL;

                FOR rec_nudr
                    IN (SELECT nudr.lfd_id,
                               nudr.lfd_lfd,
                               nudr.lfdp_id,
                               udmec.NUdr_God,
                               udmec.NUdr_Mec,
                               CASE
                                   WHEN    udmec.NUdr_God = '0'
                                        OR udmec.NUdr_Mec = '0'
                                   THEN
                                       (SELECT TRUNC (
                                                   MAX (
                                                       TO_DATE (
                                                           nac.nac_datop
                                                               DEFAULT NULL ON CONVERSION ERROR,
                                                           'dd.mm.yyyy')),
                                                   'mm')    nac_datop
                                          FROM uss_exch.v_ls_nackfn_data
                                               nac
                                         WHERE     nac.lfd_lfd =
                                                   udmec.lfd_lfd
                                               AND nac.ls_nls =
                                                   udmec.ls_nls
                                               AND nac.nac_god =
                                                   udmec.nudr_god
                                               AND nac.nac_mec =
                                                   udmec.nudr_mec
                                               AND nac.nac_godf =
                                                   udmec.nudr_godf
                                               AND nac.nac_mecf =
                                                   udmec.nudr_mecf
                                               -- прибираэмо з умови КФН - він завжди буде не той
                                               -- and nac.nac_kfn = ls.ls_kfn
                                               AND nac.nac_snac =
                                                   udmec.nudr_snac)
                                   ELSE
                                       NULL
                               END               nac_datop,
                               TO_DATE (
                                      LPAD (nudr.nudr_mec, 2, '0')
                                   || nudr.nudr_god
                                       DEFAULT NULL ON CONVERSION ERROR,
                                   'mmyyyy')     nudr_dt,
                               TO_DATE (
                                      LPAD (udmec.nudr_mecf, 2, '0')
                                   || '.'
                                   || udmec.nudr_godf
                                       DEFAULT NULL ON CONVERSION ERROR,
                                   'mm.yyyy')    AS nudr_f_dt,
                               udmec.nudr_snac,
                               nudr.nudr_sved,
                               nudr_nkvit,
                               -- IC #85786 проставляэмо ознаку оплати тільки у випадку, коли NUDR_GOD !=0 и NUDR_NKVIT !=0 (не актуально)
                               -- по массиву NUDR поле NKVIT не обращаем внимания, какое значение. Если это борги (по которым ищем записи в KFN), то не заполняем поле с № ведомости АСОПД, по всем остальным - заполняем значением поля NKVIT
                               CASE
                                   WHEN    nudr.NUdr_God = '0'
                                        OR nudr.NUdr_Mec = '0' --nudr.nudr_nkvit = '0'
                                   THEN
                                       ''
                                   -- IC #86151
                                   -- для юридичних осіб
                                   WHEN     (   nudr.NUdr_Godn = '0'
                                             OR nudr.NUdr_Mecn = '0')
                                        AND nudr.nudr_bj IN
                                                ('5', '517')
                                        AND rec_ispl.ispl_kvz > '0'
                                   THEN
                                       ''
                                   WHEN     nudr.nudr_bj IN ('7')
                                        AND rec_ispl.ispl_kvz > '0'
                                   THEN
                                       ''
                                   WHEN     nudr.nudr_bj IN
                                                ('5', '517')
                                        AND rec_ispl.ispl_kvz > '0'
                                   THEN
                                          nudr_nkvit
                                       || ' '
                                       || nudr.NUdr_Mecn
                                       || '.'
                                       || nudr.NUdr_Godn
                                   -- для фізичних осіб
                                   WHEN     (   nudr.NUdr_Godn = '0'
                                             OR nudr.NUdr_Mecn = '0')
                                        AND nudr.nudr_bj IN
                                                ('69', '516')
                                        AND rec_ispl.ispl_kvz = '0'
                                   THEN
                                       ''
                                   WHEN     nudr.nudr_bj IN ('71')
                                        AND rec_ispl.ispl_kvz = '0'
                                   THEN
                                       ''
                                   WHEN     nudr.nudr_bj IN
                                                ('69', '516')
                                        AND rec_ispl.ispl_kvz = '0'
                                   THEN
                                          nudr_nkvit
                                       || ' '
                                       || nudr.NUdr_Mecn
                                       || '.'
                                       || nudr.NUdr_Godn
                                   ELSE
                                       nudr_nkvit
                               END               imp_pr_num,
                               npt.npt_id,
                               ls.ls_kfn
                          FROM uss_exch.v_ls_nudr_data  nudr
                               JOIN uss_exch.v_ls_udmec_data udmec
                                   ON     udmec.lfd_lfd = nudr.lfd_lfd
                                      AND udmec.Ls_Nls = nudr.Ls_Nls
                                      AND udmec.Ispl_Kud = nudr.Ispl_Kud
                                      AND udmec.Ispl_Num = nudr.Ispl_Num
                                      AND udmec.NUdr_Mec = nudr.NUdr_Mec
                                      AND udmec.NUdr_God = nudr.NUdr_God
                               JOIN uss_exch.v_ls_data ls
                                   ON     ls.lfd_lfd = nudr.lfd_lfd
                                      AND ls.ls_nls = nudr.ls_nls
                               --                           join v_ndi_payment_type_mg npt on npt.npt_code = ls.ls_kfn and npt.history_status = 'A'
                               JOIN uss_ndi.v_ndi_payment_type npt
                                   ON     npt.npt_code = ls.ls_kfn
                                      AND npt.history_status = 'A'
                                      -- IC #92346
                                      AND NVL (npt.npt_npc, -1) =
                                          CASE
                                              WHEN npt.npt_code = '256'
                                              THEN
                                                  42
                                              ELSE
                                                  NVL (npt.npt_npc, -1)
                                          END
                                      AND getAccessByKFN (
                                              npt.npt_code,
                                              SUBSTR (TO_CHAR (p_ls_org),
                                                      1,
                                                      3)) =
                                          1
                         WHERE     nudr.lfd_lfd = rec_ispl.lfd_lfd
                               AND nudr.ls_nls = rec_ispl.ls_nls
                               AND nudr.ispl_kud = rec_ispl.ispl_kud
                               AND nudr.ispl_num = rec_ispl.ispl_num
                               -- https://redmine.medirent.com.ua/issues/83826
                               -- заповняти в таблицю AC_Detail записи з масиву BUDMEC
                               -- Держутримання (ispl_kud in ('17','20','21','22','25','30'))
                               -- IC #84706 Аліменти (ispl_kud in ('1','2','3')) та Переплати (всі інші значення поля ispl_kud)
                               --and to_date(lpad(nudr.nudr_mec,2,'0')||nudr.nudr_god default null on conversion error, 'mmyyyy') is not null
                               -- IC #84706 Не заповнювати значення з таблиці BUDMEC, де NUdr_MecF більше 12
                               AND TO_NUMBER (
                                       udmec.nudr_mecf
                                           DEFAULT NULL ON CONVERSION ERROR) BETWEEN 0
                                                                                 AND 12)
                LOOP
                    l_ls_kfn := rec_nudr.ls_kfn;
                    -- IC #89200
                    l_nudr_dt := rec_nudr.nac_datop;

                    IF l_nudr_dt IS NULL AND rec_nudr.NUdr_God = '0'
                    THEN
                        SELECT MAX (TRUNC (bp.bp_month, 'mm'))
                          INTO l_nudr_dt
                          FROM uss_esr.BILLING_PERIOD bp
                         WHERE     bp.BP_TP = 'PR'
                               AND bp.BP_CLASS = 'V'
                               AND bp.BP_ST = 'R'
                               AND COM_ORG = p_ls_org;

                        -- Після того, як знайден активний період - робимо попередній місяць та пишемо ці записи в попередній закритий період
                        l_nudr_dt := ADD_MONTHS (l_nudr_dt, -1);
                    END IF;

                    -- IC #85513
                    IF rec_nudr.NUdr_God = '0' AND l_nudr_dt IS NULL
                    THEN
                        l_error_prm := UPPER ('BUDMEC');
                        RAISE ex_error_85513;
                    ELSE
                        l_nudr_dt :=
                            CASE
                                WHEN rec_nudr.NUdr_God = '0' THEN l_nudr_dt
                                ELSE rec_nudr.nudr_dt
                            END;
                    END IF;

                    -- IC #91416 якщо місяць в місяць відрахування - залишаємо пропорцію
                    IF l_nudr_dt = rec_nudr.nudr_f_dt OR rec_ispl.is_nrh = 0
                    THEN
                        INSERT INTO tmp_work_set1 (x_dt1)
                             VALUES (l_nudr_dt);
                    END IF;

                    BEGIN
                        -- вибираем ранее внесенній контейнер по акруалам
                        SELECT ac_id
                          INTO l_ac
                          FROM accrual ac
                         WHERE ac.ac_pc = p_pc AND ac_month = l_nudr_dt;

                        -- заменяем орг на актуальній
                        UPDATE accrual aaa
                           SET aaa.com_org = p_ls_org
                         WHERE aaa.ac_id = l_ac AND aaa.com_org <> p_ls_org;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            -- если не найденно инсертив акруал
                            INSERT INTO accrual (ac_id,
                                                 ac_pc,
                                                 ac_month,
                                                 ac_st,
                                                 history_status,
                                                 com_org)
                                 VALUES (NULL,
                                         p_pc,
                                         l_nudr_dt,
                                         'R',
                                         'A',
                                         p_ls_org)
                              RETURNING ac_id
                                   INTO l_ac;

                            INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                           ldr_trg,
                                                           ldr_code)
                                     VALUES (rec_nudr.lfdp_id,
                                             l_ac,
                                             'USS_ESR.ACCRUAL');
                    END;

                    INSERT INTO tmp_work_ids1
                         VALUES (l_ac);

                    INSERT INTO ac_detail (acd_id,
                                           acd_ac,
                                           acd_op,
                                           acd_npt,
                                           acd_start_dt,
                                           acd_stop_dt,
                                           acd_sum,
                                           acd_dn,
                                           acd_pd,
                                           acd_ac_start_dt,
                                           acd_ac_stop_dt,
                                           acd_is_indexed,
                                           acd_st,
                                           history_status,
                                           acd_payed_sum,
                                           acd_prsd,
                                           acd_imp_pr_num)
                         VALUES (
                                    NULL,
                                    l_ac,
                                    123,
                                    -- p_ls_npt_id,
                                    rec_nudr.npt_id,
                                    TRUNC (rec_nudr.nudr_f_dt, 'month'),
                                    LAST_DAY (rec_nudr.nudr_f_dt),
                                    rec_nudr.nudr_snac,
                                    l_dn,
                                    p_pd,
                                    TRUNC (l_nudr_dt, 'month'),
                                    LAST_DAY (l_nudr_dt),
                                    'F',
                                    'R',
                                    'A',
                                    CASE
                                        WHEN rec_nudr.nudr_nkvit <> '0'
                                        THEN
                                            rec_nudr.nudr_snac
                                        ELSE
                                            NULL
                                    END,
                                    NULL,
                                    rec_nudr.imp_pr_num)
                      RETURNING acd_id
                           INTO l_acd;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_nudr.lfdp_id,
                                     l_acd,
                                     'USS_ESR.AC_DETAIL');

                    -- IC #91416
                    -- якщо місяць нарахування та місяць, за який нараховано, не співпадають, то робити за цей місяць рядок з нарахуванням,
                    -- який повністю співпадає з сумою відрахування по тому самому коду оплати
                    IF     l_nudr_dt != rec_nudr.nudr_f_dt
                       AND rec_ispl.is_nrh = 1
                    THEN
                        INSERT INTO ac_detail (acd_id,
                                               acd_ac, --  в місяць, по якому є запис
                                               acd_op,      -- 1 (нарахування)
                                               acd_npt, -- =LS_KFN (переведений в наш код)
                                               acd_start_dt, -- начало месяца из періода ACD_AC
                                               acd_stop_dt, -- конец месяца из періода ACD_AC
                                               acd_sum, -- сума з рядка, помножена на суму з поля Np_Pr/100. Якщо період в полях ACD_START_DT, ACD_STOP_DT дорівнює повному місяцю, то суму залишаємо. Якщо меньше - потрібно отриману суму поділити на кількість днів у місяці та помножити на кількість днів між ACD_AC_START_DT, ACD_AC_STOP_DT
                                               acd_dn,             -- порожній
                                               acd_pd, -- посилання на решение
                                               acd_ac_start_dt, -- начало и конец месяца из периода, який визначаємо з полів періоду (якщо початок періоду раніше ніж початок місяця,
                                               acd_ac_stop_dt, -- то пишемо початок місяця, інакше початок періоду. Кінець аналогічно - якщо дата закінчення періоду більше ніж кінець місяця, то пишемо кінець місяця, інакше кінець періоду).
                                               acd_is_indexed,            -- F
                                               acd_st,                    -- R
                                               history_status,            -- A
                                               acd_payed_sum,     -- = ACD_SUM
                                               acd_imp_pr_num)            -- 1
                             VALUES (NULL,
                                     l_ac,
                                     1,
                                     rec_nudr.npt_id,
                                     TRUNC (rec_nudr.nudr_f_dt, 'month'),
                                     LAST_DAY (rec_nudr.nudr_f_dt),
                                     rec_nudr.nudr_snac,
                                     NULL,
                                     p_pd,
                                     TRUNC (l_nudr_dt, 'month'),
                                     LAST_DAY (l_nudr_dt),
                                     'F',
                                     'R',
                                     'A',
                                     rec_nudr.nudr_snac,
                                     1)
                          RETURNING acd_id
                               INTO l_acd;

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_nudr.lfdp_id,
                                         l_acd,
                                         'USS_ESR.AC_DETAIL');
                    END IF;
                END LOOP;

                -- IC #84769 Потрібно перевіряти масив NP додатково та створювати записи по нарахуванню з них:
                -- з кодом Np_Kfn = 199
                -- з кодом Np_Kfn = 995
                -- з кодом Np_Kfn = 998
                -- Якщо у місяці є запис, де відсоток Np_Pr не дорівнює 100, тоді треба створювати запис по нарахуванню пропорційно календарним дням:
                FOR np
                    IN (SELECT np.np_dnprav,
                               np.np_dkprav,
                               np.np_snadp,
                               100 - np.np_pr     np_pr,
                               np.lfdp_id,
                               npt.npt_id
                          --                    case when np.np_kfn in ('199') then p_ls_npt_id
                          --                        else npt.npt_id end     npt_id
                          FROM uss_exch.v_ls_np_data  np
                               --    inner join uss_exch.v_ls_data ls            on ls.lfd_lfd = np.lfd_lfd
                               --                                                    and ls.ls_nls = np.ls_nls
                               INNER JOIN uss_ndi.v_ndi_payment_type npt
                                   ON              -- npt.npt_code = np.np_kfn
                                                                  -- IC #90063
                                        npt.npt_code =
                                        CASE
                                            WHEN     l_ls_kfn = '169'
                                                 AND np.np_kfn = '199'
                                            THEN
                                                l_ls_kfn
                                            ELSE
                                                np.np_kfn
                                        END
                                    -- IC #92346
                                    AND NVL (npt.npt_npc, -1) =
                                        CASE
                                            WHEN npt.npt_code = '256' THEN 42
                                            ELSE NVL (npt.npt_npc, -1)
                                        END
                                    AND npt.history_status = 'A'
                                    AND getAccessByKFN (
                                            npt.npt_code,
                                            SUBSTR (TO_CHAR (p_ls_org), 1, 3)) =
                                        1
                         WHERE     np.lfd_lfd = rec_ispl.lfd_lfd
                               AND np.ls_nls = rec_ispl.ls_nls
                               --and to_date(np.np_dnprav, 'dd.mm.yyyy') between rec_ispl.ispl_displ
                               --                                            and coalesce(rec_ispl.ud_dso,to_date('31.12.2099', 'dd.mm.yyyy'))
                               AND TO_NUMBER (
                                       np.np_snadp
                                           DEFAULT 0 ON CONVERSION ERROR) >
                                   0
                               AND np.np_kfn IN ('199',
                                                 '995',
                                                 '998',
                                                 '986')
                               -- Tania, 10.10.2023 16:03 схоже, що треба додати контрольку - не дорівнює 0 або 100
                               AND np.np_pr NOT IN ('0', '100'))
                LOOP
                    FOR cur_np
                        IN (  SELECT t.ac_month,
                                     t.ac_month
                                         ACD_START_DT,
                                     LAST_DAY (t.ac_month)
                                         ACD_STOP_DT--,ROUND(sum(t.sum_debt_day)*0.01,2)  ACD_SUM
                                                    ,
                                     CASE
                                         WHEN COUNT (*) =
                                              TO_NUMBER (
                                                  TO_CHAR (
                                                      LAST_DAY (t.ac_month),
                                                      'dd'))
                                         THEN
                                             t.sum_debt
                                         -- дилимо на кількість днів в місяці і множим на кількість днів в періоді місяця
                                         ELSE
                                             ROUND (
                                                   t.sum_debt
                                                 / TO_NUMBER (
                                                       TO_CHAR (
                                                           LAST_DAY (
                                                               t.ac_month),
                                                           'dd'))
                                                 * COUNT (*),
                                                 2)
                                     END
                                         ACD_SUM,
                                     GREATEST (t.ac_month, t.np_dnprav)
                                         ACD_AC_START_DT,
                                     LEAST (LAST_DAY (t.ac_month), t.np_dkprav)
                                         ACD_AC_STOP_DT,
                                     t.sum_debt
                                FROM (    SELECT TRUNC (
                                                       TO_DATE (
                                                           np.np_dnprav
                                                               DEFAULT NULL ON CONVERSION ERROR,
                                                           'dd.mm.yyyy')
                                                     + LEVEL
                                                     - 1,
                                                     'mm')
                                                     ac_month,
                                                   TO_DATE (
                                                       np.np_dnprav
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 + LEVEL
                                                 - 1
                                                     day_dat,
                                                 CASE
                                                     WHEN np.np_pr = 0
                                                     THEN
                                                         np.np_snadp * 1
                                                     ELSE
                                                           REGEXP_REPLACE (
                                                               np.np_snadp,
                                                               '[^[:digit:]]',
                                                               '')
                                                         * np.np_pr
                                                         * 0.0001
                                                 END
                                                     sum_debt,
                                                 COUNT (*) OVER ()
                                                     cnt_day,
                                                   CASE
                                                       WHEN np.np_pr = 0
                                                       THEN
                                                           np.np_snadp * 100
                                                       ELSE
                                                           REGEXP_REPLACE (np.np_snadp, '[^[:digit:]]', '') * np.np_pr * 0.01
                                                   END
                                                 / COUNT (*) OVER ()
                                                     sum_debt_day,
                                                 TO_DATE (np.np_dnprav,
                                                          'dd.mm.yyyy')
                                                     np_dnprav,
                                                 TO_DATE (np.np_dkprav,
                                                          'dd.mm.yyyy')
                                                     np_dkprav,
                                                 np.np_snadp,
                                                 np.np_pr
                                            --,np.npt_id
                                            FROM DUAL
                                      CONNECT BY   TO_DATE (
                                                       np.np_dnprav
                                                           DEFAULT NULL ON CONVERSION ERROR,
                                                       'dd.mm.yyyy')
                                                 + LEVEL
                                                 - 1 <=
                                                 TO_DATE (
                                                     np.np_dkprav
                                                         DEFAULT NULL ON CONVERSION ERROR,
                                                     'dd.mm.yyyy')) t
                               --where TO_CHAR(t.ac_month,'yyyymmdd') in (select TO_CHAR(VALUE(tt),'yyyymmdd') ac_month  from table(tt_date) tt)
                               WHERE t.ac_month IN (SELECT tt.x_dt1
                                                      FROM tmp_work_set1 tt)
                            GROUP BY t.ac_month,
                                     t.np_dnprav,
                                     t.sum_debt,
                                     t.np_dkprav
                            ORDER BY 2, 1)
                    LOOP
                        BEGIN
                            -- вибираем ранее внесенній контейнер по акруалам
                            SELECT ac_id
                              INTO l_ac
                              FROM accrual ac
                             WHERE     ac.ac_pc = p_pc
                                   AND ac_month = cur_np.ac_month;

                            -- заменяем орг на актуальній
                            UPDATE accrual aaa
                               SET aaa.com_org = p_ls_org
                             WHERE     aaa.ac_id = l_ac
                                   AND aaa.com_org <> p_ls_org;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                -- если не найденно инсертив акруал
                                INSERT INTO accrual (ac_id,
                                                     ac_pc,
                                                     ac_month,
                                                     ac_st,
                                                     history_status,
                                                     com_org)
                                     VALUES (NULL,
                                             p_pc,
                                             cur_np.ac_month,
                                             'R',
                                             'A',
                                             p_ls_org)
                                  RETURNING ac_id
                                       INTO l_ac;

                                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                               ldr_trg,
                                                               ldr_code)
                                         VALUES (np.lfdp_id,
                                                 l_ac,
                                                 'USS_ESR.ACCRUAL');
                        END;

                        INSERT INTO tmp_work_ids1
                             VALUES (l_ac);

                        INSERT INTO ac_detail (acd_id,
                                               acd_ac, --  в місяць, по якому є запис
                                               acd_op,      -- 1 (нарахування)
                                               acd_npt, -- =LS_KFN (переведений в наш код)
                                               acd_start_dt, -- начало месяца из періода ACD_AC
                                               acd_stop_dt, -- конец месяца из періода ACD_AC
                                               acd_sum, -- сума з рядка, помножена на суму з поля Np_Pr/100. Якщо період в полях ACD_START_DT, ACD_STOP_DT дорівнює повному місяцю, то суму залишаємо. Якщо меньше - потрібно отриману суму поділити на кількість днів у місяці та помножити на кількість днів між ACD_AC_START_DT, ACD_AC_STOP_DT
                                               acd_dn,             -- порожній
                                               acd_pd, -- посилання на решение
                                               acd_ac_start_dt, -- начало и конец месяца из периода, який визначаємо з полів періоду (якщо початок періоду раніше ніж початок місяця,
                                               acd_ac_stop_dt, -- то пишемо початок місяця, інакше початок періоду. Кінець аналогічно - якщо дата закінчення періоду більше ніж кінець місяця, то пишемо кінець місяця, інакше кінець періоду).
                                               acd_is_indexed,            -- F
                                               acd_st,                    -- R
                                               history_status,            -- A
                                               acd_payed_sum,     -- = ACD_SUM
                                               acd_imp_pr_num)            -- 1
                             VALUES (NULL,
                                     l_ac,
                                     1,
                                     np.npt_id,
                                     cur_np.ACD_START_DT,
                                     cur_np.ACD_STOP_DT,
                                     cur_np.ACD_SUM,
                                     NULL,
                                     p_pd,
                                     cur_np.ACD_AC_START_DT,
                                     cur_np.ACD_AC_STOP_DT,
                                     'F',
                                     'R',
                                     'A',
                                     cur_np.ACD_SUM,
                                     1)
                          RETURNING acd_id
                               INTO l_acd;

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                             VALUES (np.lfdp_id, l_acd, 'USS_ESR.AC_DETAIL');
                    END LOOP;
                END LOOP;
            END IF;

            IF rec_ispl.is_np_199 = 1
            THEN
                INSERT INTO ps_changes (psc_id,
                                        psc_ps,
                                        psc_ap,
                                        psc_start_dt,
                                        psc_stop_dt,
                                        history_status,
                                        psc_st,
                                        psc_tp)
                     VALUES (NULL,
                             l_ps,
                             p_ap,
                             rec_ispl.dn_start,
                             rec_ispl.dn_stop,
                             'A',
                             'IN',
                             NULL)
                  RETURNING psc_id
                       INTO l_psc;
            ELSE
                l_psc := NULL;
            END IF;

            -- вставка деталей
            IF rec_ispl.unit != '0'
            THEN
                INSERT INTO dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_nl_tp,
                                       dnd_nl_value)
                     VALUES (
                                NULL,
                                l_dn,
                                rec_ispl.dn_start,
                                CASE
                                    WHEN rec_ispl.ispl_kud IN ('1', '2', '3')
                                    THEN
                                        l_dn_stop_dt
                                    ELSE
                                        rec_ispl.dn_stop
                                END,
                                rec_ispl.unit,                    -- IC #91079
                                NVL (rec_ispl.dnd_value, rec_ispl.np_pr),
                                'A',
                                l_psc,
                                rec_ispl.dnd_value_prefix,
                                -- IC #92589
                                CASE
                                    WHEN rec_ispl.ispl_kdp IN ('7',
                                                               '11',
                                                               '71',
                                                               '67',
                                                               '75',
                                                               '2',
                                                               '3',
                                                               '6',
                                                               '66',
                                                               '10',
                                                               '79',
                                                               '18')
                                    THEN
                                        'PL'
                                    WHEN rec_ispl.ispl_kdp IN ('21',
                                                               '85',
                                                               '81',
                                                               '89',
                                                               '16',
                                                               '17',
                                                               '20',
                                                               '80',
                                                               '24',
                                                               '93',
                                                               '87')
                                    THEN
                                        'PL'
                                    ELSE
                                        NULL
                                END,
                                CASE
                                    WHEN rec_ispl.ispl_kdp IN ('7',
                                                               '11',
                                                               '71',
                                                               '67',
                                                               '75',
                                                               '2',
                                                               '3',
                                                               '6',
                                                               '66',
                                                               '10',
                                                               '79',
                                                               '18')
                                    THEN
                                        30
                                    WHEN rec_ispl.ispl_kdp IN ('21',
                                                               '85',
                                                               '81',
                                                               '89',
                                                               '16',
                                                               '17',
                                                               '20',
                                                               '80',
                                                               '24',
                                                               '93',
                                                               '87')
                                    THEN
                                        50
                                    ELSE
                                        NULL
                                END)
                  RETURNING dnd_id, dnd_nl_tp, dnd_nl_value
                       INTO l_dnd, l_dnd_nl_tp, l_dnd_nl_value;

                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_ispl.dn_lfdp_id, l_dnd, 'USS_ESR.DN_DETAIL');

                -- IC #94632
                IF l_dnd_nl_tp = 'PL'
                THEN
                    UPDATE uss_esr.deduction
                       SET dn_params_src = 'DNP'
                     WHERE dn_id = l_dn;

                    UPDATE uss_esr.dn_person
                       SET dnp_nl_tp = l_dnd_nl_tp,
                           dnp_nl_value = l_dnd_nl_value
                     WHERE dnp_dn = l_dn;
                END IF;
            END IF;
        -------------------------------------------------------------------------------------------------------------
        -- по косвеннім методам развязіваем відрахування сотрицительніми нарахуваннями  o.op_code like '6___')
        --update ac_detail ddd
        --set ddd.acd_dn = l_dn
        --where ddd.acd_pd in (select pd_id from pc_decision pd where pd.pd_ap = p_ap)
        --  and ddd.acd_start_dt between rec_ispl.ispl_displ and coalesce(rec_ispl.Ud_Dso, to_date('31.12.2099', 'dd.mm.yyyy'))
        --  and
        --  and ddd.acd_op in (select o.op_id from uss_ndi.v_ndi_op o where o.op_tp1 = 'DN');
        END LOOP;

        -- Але є зауваження:
        -- якщо DND_TP = SD, тоді треба DNP_VALUE_PREFIX = DND_VALUE_PREFIX * кількість дітей
        -- якщо DND_TP = PD, тоді треба DNP_value = DND_value / кількість дітей
        -- IC #92589
        FOR c
            IN (SELECT d.dn_id,
                       dp.dnp_id,
                       d.dn_unit,
                       COUNT (*) OVER (PARTITION BY d.dn_id)     cnt_chn
                  FROM uss_esr.deduction d, uss_esr.dn_person dp
                 WHERE     d.dn_id = dp.dnp_dn
                       AND d.history_status = 'A'
                       AND dp.history_status = 'A'
                       AND d.dn_pc = p_pc)
        LOOP
            IF c.dn_unit = 'SD'
            THEN
                UPDATE uss_esr.dn_person
                   SET dnp_value_prefix =
                           ROUND (dnp_value_prefix * c.cnt_chn, 2)
                 WHERE dnp_id = c.dnp_id;
            END IF;

            IF c.dn_unit = 'PD'
            THEN
                UPDATE uss_esr.dn_person
                   SET dnp_value = ROUND (dnp_value / c.cnt_chn, 2)
                 WHERE dnp_id = c.dnp_id;
            END IF;
        END LOOP;

        -- от Павлюкова и Никоновой какое то апи через tmp_work_ids1
        actuilize_payed_sum (2);
    END;

    PROCEDURE Load_Payroll_Bank_Imp (p_lfd_id NUMBER)
    IS
        l_pc_id             personalcase.pc_id%TYPE;
        l_pa_id             pc_account.pa_id%TYPE;
        l_sc_id             NUMBER;
        l_sc_unique         VARCHAR2 (100);
        l_ipr_id            NUMBER;
        l_iprs_id           NUMBER;
        l_error_msg         VARCHAR2 (4000);

        l_blob              BLOB;
        l_is_prtcl          NUMBER := 0;
        l_prtcl             NUMBER;
        l_prtcl_file_name   VARCHAR2 (250);
    BEGIN
        --шапка файла
        FOR rec_bank_heading
            IN (SELECT h.lfd_file_name,
                       h.lfd_lfd_file_name,
                       SUBSTR (lfd_file_name, 1, 3)
                           req,
                       SUBSTR (lfd_file_name, 5, 4)
                           AS raj,
                       SUBSTR (lfd_file_name, 10, 8)
                           AS bank_edrpou,
                       SUBSTR (lfd_file_name, 19, 2)
                           AS year,
                       SUBSTR (lfd_file_name, 21, 2)
                           AS month,
                       SUBSTR (lfd_file_name, 24, 2)
                           AS payroll_tp,
                       SUBSTR (lfd_file_name, 27, 2)
                           AS period,
                       LPAD (LPAD (SUBSTR (lfd_file_name, 5, 4), 4, '0'),
                             5,
                             '5')
                           AS base_org,
                       COALESCE (
                           TO_CHAR (o.nddc_code_dest),
                           LPAD (LPAD (SUBSTR (lfd_file_name, 5, 4), 4, '0'),
                                 5,
                                 '5'))
                           AS org,
                       h.lfd_create_dt,
                       h.lfdp_id,
                       h.lfd_id,
                       h.lfd_lfd,
                       h.lfd_lft,
                       u.wu_login,
                       u.wu_pib,
                       u.wu_pib || '(' || u.wu_login || ')'
                           AS wu_txt,
                       h.central_branch_bank,
                       h.bank_branch_number,
                       h.payment_day,
                       h.symbol_separator,
                       h.raj_code,
                       h.header_length,
                       TO_DATE (h.file_creation_dt, 'dd/mm/yy')
                           AS file_creation_dt,
                       h.number_information_rows,
                       h.mfo_payer,
                       h.payer_account,
                       h.mfo_recipient,
                       h.recipient_account,
                       h.debit_credit,
                       h.amount_payment,
                       h.payment_tp,
                       h.payment_number,
                       h.is_presence_payment_supplement,
                       h.payer_name,
                       h.recipient_name,
                       h.purpose_payment,
                       h.branch_number,
                       h.deposit_code,
                       h.processing_modes,
                       h.cop_ep,
                       b.nb_id,
                       DECODE (SUBSTR (lfd_file_name, 24, 2),
                               '95', 642,
                               NULL)
                           AS pr_nst,
                       DECODE (SUBSTR (lfd_file_name, 24, 2), '95', 24, NULL)
                           AS pr_npc,
                       DECODE (SUBSTR (lfd_file_name, 24, 2),
                               '95', 167,
                               NULL)
                           AS prs_npt,
                       CASE
                           WHEN SUBSTR (lfd_file_name, 24, 2) = '95'
                           THEN
                               TO_DATE (
                                      '02'
                                   || SUBSTR (lfd_file_name, 21, 2)
                                   || SUBSTR (lfd_file_name, 19, 2),
                                   'ddmmyy')
                           ELSE
                               TO_DATE (
                                      '04'
                                   || SUBSTR (lfd_file_name, 21, 2)
                                   || SUBSTR (lfd_file_name, 19, 2),
                                   'ddmmyy')
                       END
                           AS start_pay_dt,
                       CASE
                           WHEN SUBSTR (lfd_file_name, 24, 2) = '95'
                           THEN
                               TO_DATE (
                                      '22'
                                   || SUBSTR (lfd_file_name, 21, 2)
                                   || SUBSTR (lfd_file_name, 19, 2),
                                   'ddmmyy')
                           ELSE
                               TO_DATE (
                                      '24'
                                   || SUBSTR (lfd_file_name, 21, 2)
                                   || SUBSTR (lfd_file_name, 19, 2),
                                   'ddmmyy')
                       END
                           AS stop_pay_dt,
                       CASE
                           WHEN     TO_DATE (h.file_creation_dt, 'dd/mm/yy') BETWEEN TO_DATE (
                                                                                            '02'
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                21,
                                                                                                2)
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                19,
                                                                                                2),
                                                                                         'ddmmyy')
                                                                                 AND TO_DATE (
                                                                                            '22'
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                21,
                                                                                                2)
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                19,
                                                                                                2),
                                                                                         'ddmmyy')
                                AND SUBSTR (lfd_file_name, 24, 2) = '95'
                           THEN
                               TO_DATE (h.file_creation_dt, 'dd/mm/yy')
                           WHEN     TO_DATE (h.file_creation_dt, 'dd/mm/yy') BETWEEN TO_DATE (
                                                                                            '04'
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                21,
                                                                                                2)
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                19,
                                                                                                2),
                                                                                         'ddmmyy')
                                                                                 AND TO_DATE (
                                                                                            '25'
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                21,
                                                                                                2)
                                                                                         || SUBSTR (
                                                                                                lfd_file_name,
                                                                                                19,
                                                                                                2),
                                                                                         'ddmmyy')
                                AND SUBSTR (lfd_file_name, 24, 2) <> '95'
                           THEN
                               TO_DATE (h.file_creation_dt, 'dd/mm/yy')
                           ELSE
                               NULL
                       END
                           AS calc_payment_day
                  FROM uss_exch.v_payroll_bank_heading  h
                       LEFT JOIN uss_ndi.v_ndi_bank b
                           ON     LPAD (b.nb_mfo, 9, '0') = h.mfo_recipient
                              --and lpad(b.nb_edrpou,8,'0') = substr(lfd_file_name,10,8)
                              AND b.history_status = 'A'
                       LEFT JOIN uss_ndi.v_ndi_decoding_config o
                           ON     o.nddc_code_src =
                                  LPAD (
                                      LPAD (SUBSTR (lfd_file_name, 5, 4),
                                            4,
                                            '0'),
                                      5,
                                      '5')
                              AND o.nddc_tp = 'ORG_MIGR'
                       LEFT JOIN ikis_sysweb.v$all_users u
                           ON u.wu_id = h.lfd_user_id
                 WHERE h.lfd_id = p_lfd_id)
        LOOP
            INSERT INTO imp_payroll (ipr_id,
                                     ipr_ipr,
                                     com_org,
                                     ipr_npc,
                                     ipr_tp,
                                     ipr_create_dt,
                                     ipr_sum,
                                     ipr_send_dt,
                                     ipr_fix_dt,
                                     ipr_st,
                                     ipr_start_dt,
                                     ipr_stop_dt,
                                     ipr_pc_cnt,
                                     ipr_pib_head,
                                     ipr_pib_bookkeeper,
                                     ipr_is_blocked,
                                     ipr_month,
                                     ipr_start_day,
                                     ipr_stop_day,
                                     ipr_pay_tp,
                                     ipr_src,
                                     ipr_lfd,
                                     ipr_lfd_lfd)
                 VALUES (
                            NULL,
                            NULL,
                            rec_bank_heading.org,
                            rec_bank_heading.pr_npc,
                            'M',
                            rec_bank_heading.file_creation_dt,
                            rec_bank_heading.amount_payment / 100,
                            NULL,
                            NULL,
                            'C',
                            rec_bank_heading.start_pay_dt,
                            rec_bank_heading.stop_pay_dt,
                            rec_bank_heading.number_information_rows,
                            NULL,
                            NULL,
                            NULL,
                            TO_DATE (
                                   rec_bank_heading.month
                                || '.'
                                || rec_bank_heading.year,
                                'mm.yy'),
                            TO_CHAR (rec_bank_heading.start_pay_dt, 'dd'),
                            TO_CHAR (rec_bank_heading.stop_pay_dt, 'dd'),
                            'BANK',
                            rec_bank_heading.lfd_lft,
                            rec_bank_heading.lfd_id,
                            rec_bank_heading.lfd_lfd)
              RETURNING ipr_id
                   INTO l_ipr_id;

            --- ADDDDD
            INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_bank_heading.lfdp_id,
                             l_ipr_id,
                             'USS_ESR.IMP_PAYROLL');

            -- тело файла
            FOR rec_bank
                IN (SELECT REPLACE (
                               TRIM (SUBSTR (b.fio || '   ',
                                             1,
                                             INSTR (b.fio || '   ',
                                                    ' ',
                                                    1,
                                                    1))),
                               '?',
                               'І')                             AS fio_ln,
                           REPLACE (
                               TRIM (
                                   SUBSTR (b.fio || '   ',
                                           INSTR (b.fio || '   ',
                                                  ' ',
                                                  1,
                                                  1),
                                             INSTR (b.fio || '   ',
                                                    ' ',
                                                    1,
                                                    2)
                                           - INSTR (b.fio || '   ',
                                                    ' ',
                                                    1,
                                                    1))),
                               '?',
                               'І')                             AS fio_fn,
                           REPLACE (
                               TRIM (
                                   SUBSTR (b.fio || '   ',
                                           INSTR (b.fio || '   ',
                                                  ' ',
                                                  1,
                                                  2),
                                             INSTR (b.fio || '   ',
                                                    ' ',
                                                    1,
                                                    3)
                                           - INSTR (b.fio || '   ',
                                                    ' ',
                                                    1,
                                                    2))),
                               '?',
                               'І')                             AS fio_sn,
                           b.lfdp_id,
                           b.rn,
                           b.deposit_account_number,
                           b.branch_number,
                           b.deposit_code,
                           b.amount,
                           NULLIF (b.numident, '0000000000')    AS numident,
                           CASE
                               WHEN b.numident = '0000000000'
                               THEN
                                   deposit_account_number
                               ELSE
                                   NULL
                           END                                  AS doc_num,
                           CASE
                               WHEN b.numident = '0000000000' THEN 10095
                               ELSE NULL
                           END                                  AS doc_ndt,
                           b.ls_nls
                      FROM uss_exch.v_payroll_bank_data b
                     WHERE lfd_id = rec_bank_heading.lfd_id /*and b.numident = '2109622382'*/
                                                           )
            LOOP
                -- определяем персону/создаем персону
                l_error_msg := NULL;
                l_sc_id := NULL;
                l_sc_unique := NULL;

                l_pa_id := NULL;
                l_pc_id := NULL;

                l_sc_id :=
                    uss_person.load$socialcard.load_sc (
                        p_fn            => rec_bank.fio_fn,
                        p_ln            => rec_bank.fio_ln,
                        p_mn            => rec_bank.fio_sn,
                        p_gender        => 'V',
                        p_nationality   => '-1',
                        p_src_dt        => rec_bank_heading.lfd_create_dt,
                        p_birth_dt      => NULL,
                        p_inn_num       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_bank.numident,
                                                  '^(\d){10}$')
                                THEN
                                    rec_bank.numident
                                ELSE
                                    NULL
                            END,
                        p_inn_ndt       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_bank.numident,
                                                  '^(\d){10}$')
                                THEN
                                    5
                                ELSE
                                    NULL
                            END,                              -- тип из архива
                        p_doc_ser       => NULL,
                        p_doc_num       => rec_bank.doc_num,
                        p_doc_ndt       => rec_bank.doc_ndt,
                        p_src           => '720',
                        p_sc            => l_sc_id,
                        p_sc_unique     => l_sc_unique);

                IF l_sc_id > 0 OR l_sc_id = -2
                THEN
                    IF l_sc_id > 0
                    THEN
                        -- personalcase --
                        BEGIN
                            SELECT pc.pc_id
                              INTO l_pc_id
                              FROM personalcase pc
                             WHERE pc.pc_sc = l_sc_id;

                            -- перемиграция по районам
                            UPDATE personalcase pc
                               SET pc.com_org = rec_bank_heading.org
                             WHERE     pc.pc_id = l_pc_id
                                   AND COALESCE (pc.com_org, -1) <>
                                       rec_bank_heading.org;

                            UPDATE personalcase pc
                               SET pc.pc_num = l_sc_unique
                             WHERE     pc.pc_id = l_pc_id
                                   AND pc.pc_num <> l_sc_unique;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                INSERT INTO personalcase (pc_id,
                                                          pc_num,
                                                          pc_create_dt,
                                                          pc_sc,
                                                          pc_st,
                                                          com_org)
                                     VALUES (NULL,
                                             l_sc_unique,
                                             rec_bank_heading.lfd_create_dt,
                                             l_sc_id,
                                             'R',
                                             rec_bank_heading.org)
                                  RETURNING pc_id
                                       INTO l_pc_id;

                                --- ADDDDD
                                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                               ldr_trg,
                                                               ldr_code)
                                         VALUES (rec_bank_heading.lfdp_id,
                                                 l_pc_id,
                                                 'USS_ESR.PERSONALCASE');
                        END;

                        -- pc_account ------------------------------------------------------------------------------
                        BEGIN
                            SELECT pa_id
                              INTO l_pa_id
                              FROM pc_account pa
                             WHERE     pa.pa_pc = l_pc_id
                                   AND pa.pa_nst = rec_bank_heading.pr_nst;

                            -- маркируем услугу за текущим оргом
                            UPDATE pc_account ddd
                               SET ddd.pa_org = rec_bank_heading.base_org
                             WHERE     ddd.pa_id = l_pa_id
                                   AND COALESCE (ddd.pa_org, -1) <>
                                       rec_bank_heading.org;

                            -- записіваем информацию по услуге, откуда грузили и на какую дату последнего нарахування у нас виплата в вігрузке
                            INSERT INTO pa_log (pal_id,
                                                pal_pa,
                                                pal_hs,
                                                pal_st,
                                                pal_message,
                                                pal_st_old,
                                                pal_tp)
                                     VALUES (
                                                NULL,
                                                l_pa_id,
                                                NULL,
                                                NULL,
                                                   CHR (38)
                                                || '92#'
                                                || rec_bank_heading.lfd_lfd
                                                || '#'
                                                || rec_bank.ls_nls
                                                || '#'
                                                || rec_bank_heading.prs_npt
                                                || '#'
                                                || rec_bank_heading.start_pay_dt
                                                || '#'
                                                || rec_bank_heading.org
                                                || '#'
                                                || rec_bank_heading.base_org
                                                || '#'
                                                || rec_bank_heading.wu_txt
                                                || '#'
                                                || TO_CHAR (
                                                       SYSDATE,
                                                       'dd.mm.yyyy hh24:mi:ss'),
                                                NULL,
                                                'SYS');
                        -- не нашли услугу (особовій рахунок)
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                INSERT INTO pc_account (pa_id,
                                                        pa_pc,
                                                        pa_num,
                                                        pa_nst,
                                                        pa_stage,
                                                        pa_org)
                                     VALUES (NULL,
                                             l_pc_id,
                                             rec_bank.ls_nls,
                                             rec_bank_heading.pr_nst,
                                             '1',
                                             rec_bank_heading.base_org)
                                  RETURNING pa_id
                                       INTO l_pa_id;

                                INSERT INTO pa_log (pal_id,
                                                    pal_pa,
                                                    pal_hs,
                                                    pal_st,
                                                    pal_message,
                                                    pal_st_old,
                                                    pal_tp)
                                         VALUES (
                                                    NULL,
                                                    l_pa_id,
                                                    NULL,
                                                    NULL,
                                                       CHR (38)
                                                    || '92#'
                                                    || rec_bank_heading.lfd_lfd
                                                    || '#'
                                                    || rec_bank.ls_nls
                                                    || '#'
                                                    || rec_bank_heading.prs_npt
                                                    || '#'
                                                    || rec_bank_heading.start_pay_dt
                                                    || '#'
                                                    || rec_bank_heading.org
                                                    || '#'
                                                    || rec_bank_heading.base_org
                                                    || '#'
                                                    || rec_bank_heading.wu_txt
                                                    || '#'
                                                    || TO_CHAR (
                                                           SYSDATE,
                                                           'dd.mm.yyyy hh24:mi:ss'),
                                                    NULL,
                                                    'SYS');

                                --- ADDDDD
                                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                               ldr_trg,
                                                               ldr_code)
                                         VALUES (rec_bank.lfdp_id,
                                                 l_pa_id,
                                                 'USS_ESR.PC_ACCOUNT');
                        END;
                    END IF;

                    INSERT INTO uss_esr.ipr_sheet (iprs_id,
                                                   iprs_ipr,
                                                   iprs_pc,
                                                   iprs_pa,
                                                   iprs_num,
                                                   iprs_nb,
                                                   iprs_pc_num,
                                                   iprs_account,
                                                   iprs_fn,
                                                   iprs_ln,
                                                   iprs_mn,
                                                   iprs_index,
                                                   iprs_address,
                                                   iprs_tp,
                                                   iprs_sum,
                                                   iprs_post_sum,
                                                   iprs_post_by_org,
                                                   iprs_max_pro_sum,
                                                   iprs_post_perc,
                                                   iprs_remit_dt,
                                                   iprs_remit_num,
                                                   iprs_inn,
                                                   iprs_transfer_dt,
                                                   iprs_kaot,
                                                   iprs_street,
                                                   iprs_ns,
                                                   iprs_building,
                                                   iprs_block,
                                                   iprs_apartment,
                                                   iprs_pay_dt,
                                                   iprs_npt,
                                                   iprs_doc_num,
                                                   iprs_st,
                                                   iprs_dpp)
                         VALUES (
                                    NULL,
                                    l_ipr_id,
                                    l_pc_id,
                                    l_pa_id,
                                    rec_bank.rn - 1,
                                    rec_bank_heading.nb_id,
                                    rec_bank.ls_nls,
                                    rec_bank.deposit_account_number,
                                    rec_bank.fio_fn,
                                    rec_bank.fio_ln,
                                    rec_bank.fio_sn,
                                    NULL,
                                    rec_bank_heading.raj,
                                    'PB',
                                    rec_bank.amount / 100,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    rec_bank.numident,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    COALESCE (
                                        rec_bank_heading.calc_payment_day,
                                        TO_DATE (
                                               DECODE (
                                                   rec_bank_heading.payment_tp,
                                                   '95', '02.',
                                                   '04.')
                                            || rec_bank_heading.month
                                            || '.'
                                            || rec_bank_heading.year,
                                            'dd.mm.yy')),
                                    rec_bank_heading.prs_npt,
                                    NULL,
                                    NULL,
                                    NULL)
                      RETURNING iprs_id
                           INTO l_iprs_id;

                    --- addddd
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_bank.lfdp_id,
                                     l_iprs_id,
                                     'USS_ESR.IPR_SHEET');

                    INSERT INTO uss_esr.ipr_sheet_detail (iprsd_id,
                                                          iprsd_iprsd,
                                                          iprsd_iprs,
                                                          iprsd_pc,
                                                          iprsd_pa,
                                                          iprsd_tp,
                                                          iprsd_ipr,
                                                          iprsd_month,
                                                          iprsd_sum,
                                                          iprsd_is_payed,
                                                          iprsd_full_sum,
                                                          iprsd_iprs_dn)
                             VALUES (
                                        NULL,
                                        NULL,
                                        l_iprs_id,
                                        l_pc_id,
                                        l_pa_id,
                                        'PWI',
                                        l_ipr_id,
                                        TO_DATE (
                                               rec_bank_heading.month
                                            || '.'
                                            || rec_bank_heading.year,
                                            'mm.yy'),
                                        rec_bank.amount / 100,
                                        'F',
                                        rec_bank.amount / 100,
                                        NULL);
                --elsif l_sc_id = -2 then
                --  l_error_msg:= rec_bank_heading.lfd_file_name||';'||rec_bank.deposit_account_number||';'||rec_bank.numident||';Документи в відомості не вказано чи неможливо визначити тип документа;';
                ELSIF l_sc_id = -1
                THEN
                    l_error_msg :=
                           rec_bank_heading.lfd_file_name
                        || ';'
                        || rec_bank.deposit_account_number
                        || ';'
                        || rec_bank.numident
                        || ';За документами відомості знайдено більше однієї персони в ЄСР;';
                ELSE
                    l_error_msg :=
                           rec_bank_heading.lfd_file_name
                        || ';'
                        || rec_bank.deposit_account_number
                        || ';'
                        || rec_bank.numident
                        || ';Помилка визначення персони відомості;';
                END IF;

                IF l_error_msg IS NOT NULL
                THEN
                    IF l_is_prtcl = 0
                    THEN
                        DBMS_LOB.createtemporary (l_blob, TRUE);
                        WriteLineToBlob (
                            p_line   => cEndOfLine || 'Помилкові записи: ',
                            p_blob   => l_blob);
                        l_is_prtcl := 1;
                        l_prtcl_file_name :=
                               rec_bank_heading.lfd_lfd_file_name
                            || '_'
                            || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
                            || '_(помилкові рядки)';
                    END IF;

                    WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                    SetNlsLog (rec_bank_heading.lfdp_id, -1, l_error_msg);
                END IF;
            END LOOP;
        END LOOP;

        IF l_is_prtcl = 1
        THEN
            uss_exch.load_file_prtcl.InsertProtocol (
                p_lfp_id        => l_prtcl,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => p_lfd_id,
                p_lfp_tp        => NULL,
                p_lfp_name      => l_prtcl_file_name,
                p_lfp_comment   => NULL,
                p_content       => l_blob);
        END IF;
    END;

    PROCEDURE setImpPrNumByNonpay (                               -- IC #84362
        i_lfd_lfd   IN USS_EXCH.V_LS_NAC_DATA.lfd_lfd%TYPE,
        i_ls_nls    IN USS_EXCH.V_LS_NAC_DATA.ls_nls%TYPE)
    IS
    BEGIN
    FOR cur IN (
    WITH dacc AS (
    SELECT t.*, a.ac_id
        FROM USS_EXCH.V_LS_NAC_DATA t
            INNER JOIN uss_exch.v_ls2uss l   ON l.ldr_lfdp = t.lfdp_id
                                                AND l.ldr_code = UPPER('USS_ESR.ACCRUAL')
            INNER JOIN accrual a             ON a.ac_id = l.ldr_trg
--            inner join ac_detail d           on d.acd_ac = a.ac_id
        WHERE t.ls_nls = i_ls_nls
            AND t.lfd_lfd = i_lfd_lfd
        )

    SELECT a.ac_id, '№' || a.nac_npp
                        || ' '
                        || LPAD(a.nac_mec,2,'0')
                        || '.'
                        || SUBSTR(a.nac_god,-2) imp_pr --, a.*
        FROM dacc a
        WHERE a.bj_neop = 0
            AND EXISTS (SELECT 1
                            FROM dacc d
                            WHERE d.nac_godn = a.nac_god
                                AND d.nac_mecn = a.nac_mec
                                AND d.nac_nppn = a.nac_npp
                                AND d.bj_neop = 1)
        UNION ALL
    SELECT a.ac_id, '' imp_pr --, a.*
        FROM dacc a
        WHERE a.bj_neop = 1
            AND NVL(a.nac_godn,0) = 0
            AND NVL(a.nac_mecn,0) = 0
            AND NVL(a.nac_nppn,0) = 0
            AND EXISTS (SELECT 1
                            FROM dacc d
                            WHERE d.nac_godn = a.nac_god
                                AND d.nac_mecn = a.nac_mec
                                AND d.nac_nppn = a.nac_npp)) LOOP
        FOR curd IN (
            WITH dacc AS (
            SELECT  a.ac_id,
                    LPAD(t.nac_god,4,'0')||LPAD(t.nac_mec,2,'0')||t.nac_npp nac,
                    LPAD(t.nac_godn,4,'0')||LPAD(t.nac_mecn,2,'0')||t.nac_nppn nacn
                FROM USS_EXCH.V_LS_NAC_DATA t
                    INNER JOIN uss_exch.v_ls2uss l   ON l.ldr_lfdp = t.lfdp_id
                                                        AND l.ldr_code = UPPER('USS_ESR.ACCRUAL')
                    INNER JOIN accrual a             ON a.ac_id = l.ldr_trg
                WHERE t.ls_nls = i_ls_nls
                    AND t.lfd_lfd = i_lfd_lfd
                )

            SELECT a.ac_id
                FROM dacc a
                START WITH a.ac_id = cur.ac_id
                CONNECT BY PRIOR a.nac = a.nacn) LOOP

                UPDATE ac_detail
                    SET acd_imp_pr_num = cur.imp_pr
                WHERE acd_ac = curd.ac_id;
        END LOOP;

    END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                'Помилка обробки setImpPrNumByNonpay: ' || SQLERRM);
    END setImpPrNumByNonpay;

    FUNCTION getAccessByKFN (                                     -- IC #84821
                             i_kfn IN VARCHAR2, i_org IN VARCHAR2)
        RETURN NUMBER
    IS
        p_acc   NUMBER (1) := 1;
    BEGIN
        -- Харкодишь прямо в хранимках. Никакой завязки "кфн-ы по коморгам" или "услуги по коморгам" в системе не будет.
        IF i_kfn IN ('309',
                     '327',
                     '507',
                     '519',
                     '520',
                     '530',
                     '576',
                     '588',
                     '589',
                     '169',
                     '995',
                     '998',
                     '986',
                     '1001',
                     '1002',
                     '1003',
                     '1004',
                     '1005',
                     '1006',
                     '1007',
                     '1008',
                     '1010',
                     '1011',
                     '1012',
                     '1013',
                     '1014',
                     '1015',
                     '1016',
                     '1017',
                     '1018',
                     '1019',
                     '1022',
                     '1023',
                     '1025',
                     '1026',
                     '1027',
                     '1028',
                     '1029',
                     '1030',
                     '1090',
                     '1099',
                     '1100',
                     -- Tania, 17:25 08.04.2024 о, додати треба туди 592
                     '582',
                     '592')
        THEN
            RETURN 1;
        END IF;

        -- IC #90068
        IF i_kfn IN ('129',
                     '290',
                     '291',
                     '223',
                     '216',
                     '217',
                     '218',
                     '219',
                     '220',
                     '221',
                     '222',
                     '228',
                     '229',
                     '230',
                     '231',
                     '238',
                     '239',
                     '240',
                     '241',
                     '242',
                     '243',
                     '244',
                     '245',
                     '246',
                     '247',
                     '248',
                     '249',
                     '250',
                     '251',
                     '252',
                     '253',
                     '254',
                     '260',
                     '2217',
                     '2218',
                     '2229',
                     '256')
        THEN
            RETURN 1;
        END IF;

        -- IC #84821
        IF i_kfn IN ('578',
                     '579',
                     '581',
                     '580',
                     '577',
                     '515',
                     '516',
                     '517',
                     '523',
                     '524',
                     '537') /*
         and i_org in (  '530','531','532','533','534','535','536','537','538',
                         '539','518','556')*/
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END getAccessByKFN;

    FUNCTION getExcByKFN (                                       -- IC #102940
                          i_kfn   IN VARCHAR2,
                          i_exc   IN VARCHAR2,
                          i_org   IN VARCHAR2 := NULL)
        RETURN NUMBER
    IS
    BEGIN
        IF     i_exc = 'ex_error_102940'
           AND i_kfn IN ('216',
                         '217',
                         '218',
                         '219',
                         '220',
                         '221',
                         '222',
                         '228',
                         '229',
                         '230',
                         '231',
                         '238',
                         '239',
                         '240',
                         '241',
                         '242',
                         '243',
                         '244',
                         '245',
                         '246',
                         '247',
                         '248',
                         '249',
                         '250',
                         '251',
                         '252',
                         '253',
                         '254',
                         '260',
                         '2217',
                         '2218',
                         '2229')
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END getExcByKFN;

    PROCEDURE Clear_Income (p_ap_id   NUMBER,
                            p_pd_id   NUMBER,
                            p_ltype   VARCHAR2:= 'ASOPD')
    IS
    BEGIN
        --delete tmp_work_set1 where 1=1;
        --insert into tmp_work_set1(x_id1, x_id2)

        FOR c
            IN (SELECT i.api_id, u.ldr_lfdp
                  FROM uss_esr.ap_income  i,
                       uss_esr.ap_person  p,
                       uss_exch.v_ls2uss  u
                 WHERE     i.api_id = u.ldr_trg
                       AND i.api_app = p.app_id
                       AND u.ldr_code = 'USS_ESR.AP_INCOME'
                       AND i.api_src = p_ltype
                       AND p.app_ap = p_ap_id)
        LOOP
            DELETE FROM ap_income i
                  WHERE i.api_id = c.api_id;
        END LOOP;

        --delete tmp_work_set1 where 1=1;
        --insert into tmp_work_set1(x_id1, x_id2)
        /*
        for c in (
            select pis.pis_id, u.ldr_lfdp
                from pd_income_src pis
                    ,uss_exch.v_ls2uss u
                where pis.pis_id = u.ldr_trg
                    and u.ldr_code = 'USS_ESR.PD_INCOME_SRC'
                    and pis.pis_src = p_ltype
                    and pis.pis_pd = p_pd_id) loop

            delete from pd_income_src p where p.pis_id = c.pis_id;
            --delete from uss_exch.v_ls2uss u where u.ldr_lfdp = c.ldr_lfdp;
            end loop;
        */
        DELETE FROM uss_esr.pd_income_src
              WHERE pis_pd IN (SELECT pd_id
                                 FROM uss_esr.pc_decision
                                WHERE pd_ap = p_ap_id);

        DELETE FROM uss_esr.pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM uss_esr.pd_income_detail
                          WHERE pid_pic IN
                                    (SELECT pic_id
                                       FROM uss_esr.pd_income_calc
                                      WHERE pic_pd IN
                                                (SELECT pd_id
                                                   FROM uss_esr.pc_decision
                                                  WHERE pd_ap = p_ap_id)));

        DELETE FROM uss_esr.pd_income_detail
              WHERE pid_pic IN (SELECT pic_id
                                  FROM uss_esr.pd_income_calc
                                 WHERE pic_pd IN (SELECT pd_id
                                                    FROM uss_esr.pc_decision
                                                   WHERE pd_ap = p_ap_id));

        DELETE FROM uss_esr.pd_income_calc
              WHERE pic_pd IN (SELECT pd_id
                                 FROM uss_esr.pc_decision
                                WHERE pd_ap = p_ap_id);

        DELETE FROM uss_esr.pd_income_src
              WHERE pis_pd IN (SELECT pd_id
                                 FROM uss_esr.pc_decision
                                WHERE pd_ap = p_ap_id);

        FOR c
            IN (SELECT d.apr_id, u.ldr_lfdp
                  FROM uss_esr.ap_declaration d, uss_exch.v_ls2uss u
                 WHERE     d.apr_id = u.ldr_trg
                       AND u.ldr_code = 'USS_ESR.AP_DECLARATION'
                       AND d.apr_ap = p_ap_id)
        LOOP
            DELETE FROM uss_esr.apr_living_quarters
                  WHERE aprl_apr = c.apr_id;

            DELETE FROM uss_esr.apr_vehicle
                  WHERE aprv_apr = c.apr_id;

            DELETE FROM uss_esr.apr_person
                  WHERE aprp_apr = c.apr_id;

            DELETE FROM uss_esr.ap_declaration
                  WHERE apr_id = c.apr_id;

            DELETE FROM uss_exch.v_ls2uss u
                  WHERE u.ldr_lfdp = c.ldr_lfdp;
        END LOOP;

        -- IC #95875
        DELETE FROM uss_esr.pd_detail
              WHERE     pdd_row_order = 110
                    AND pdd_pdp IN (SELECT p.pdp_id
                                      FROM uss_esr.pd_payment p
                                     WHERE p.pdp_pd = p_pd_id);
    END Clear_Income;

    PROCEDURE Load_INCOME (p_lfd_lfd           NUMBER,
                           p_migration_force   NUMBER DEFAULT 0)
    IS
        l_sc_id        NUMBER;
        l_sc_scc       NUMBER;
        l_sc_unique    VARCHAR2 (100);
        l_pc_id        NUMBER;
        l_ap_id        appeal.ap_id%TYPE;
        l_app_id       ap_person.app_id%TYPE;
        l_pd_id        pc_decision.pd_id%TYPE;
        l_pd_dt        pc_decision.pd_dt%TYPE;
        l_api_id       ap_income.api_id%TYPE;
        l_pis_id       pd_income_src.pis_id%TYPE;
        l_pic_id       pd_income_calc.pic_id%TYPE;
        l_hs_rewrite   pd_right_log.prl_hs_rewrite%TYPE;

        l_lfp_id       NUMBER;
        l_load_type    VARCHAR2 (8) := 'ASOPD';
        l_error_msg    VARCHAR2 (4000);
        l_log_msg      VARCHAR2 (4000);
        l_filename     VARCHAR2 (128);
        l_lock         TOOLS.t_lockhandler;
        l_flag         NUMBER := 0; -- флаг для проверки что есть что поданному файлу отрабатівать или нет
        l_blob         BLOB;
        l_cnt          NUMBER := 0;
        l_cnt_ld       NUMBER := 0;
        l_log_det      NUMBER := 0;
        l_api_sum      NUMBER := 0;
        l_fam_nom      VARCHAR2 (3);
        l_apr_id       uss_esr.ap_declaration.apr_id%TYPE;
        l_aprp_id      uss_esr.apr_person.aprp_id%TYPE;
        l_com_org      NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Інформація: ',
                         p_blob   => l_blob);

        SELECT    SUBSTR (lfd.lfd_file_name,
                          1,
                          LENGTH (lfd.lfd_file_name) - 4)
               || '_'
               || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
          INTO l_filename
          FROM uss_exch.load_file_data lfd
         WHERE lfd.lfd_id = p_lfd_lfd;

        IF l_load_enable = 'F'
        THEN
            WriteLineToBlob (
                p_line   =>
                    ' Завантаження заблоковоно. Зверніться до розробника, або дочекайтесь оновлення!',
                p_blob   => l_blob);

            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                uss_exch.load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_lfd,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол завантаження)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;

            RETURN;
        END IF;

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        BEGIN
            SELECT COUNT (*)
              INTO l_log_det
              FROM paramsesr
             WHERE prm_code = 'ASOPD_LOG_DET' AND prm_value = 'T';
        EXCEPTION
            WHEN OTHERS
            THEN
                l_log_det := 0;
        END;

        l_error_prm := UPPER ('b_dsd');

        FOR rec_dsd
            IN (  SELECT MAX (a.Dsd_Nzv)
                         KEEP (DENSE_RANK FIRST
                               ORDER BY
                                   TO_DATE (
                                       a.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') DESC)
                             Dsd_Nzv,
                         MAX (
                             TO_DATE (
                                 a.Dsd_DtObr
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'dd.mm.yyyy'))
                             Dsd_DtObr,
                         MAX (
                             TO_DATE (
                                 a.dsd_datedoxbeg
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'dd.mm.yyyy'))
                         KEEP (DENSE_RANK FIRST
                               ORDER BY
                                   TO_DATE (
                                       a.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') DESC)
                             dsd_datedoxbeg,
                         MAX (
                             TO_DATE (
                                 a.dsd_datedoxend
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'dd.mm.yyyy'))
                         KEEP (DENSE_RANK FIRST
                               ORDER BY
                                   TO_DATE (
                                       a.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') DESC)
                             dsd_datedoxend,
                         a.dsd_nls,
                         a.dsd_raj,
                         a.dsd_pasp,
                         a.dsd_idcode,
                         MAX (TRIM (SUBSTR (a.dsd_fio || '   ',
                                            1,
                                            INSTR (a.dsd_fio || '   ',
                                                   ' ',
                                                   1,
                                                   1))))
                             fio_ln,
                         MAX (TRIM (SUBSTR (a.dsd_fio || '   ',
                                            INSTR (a.dsd_fio || '   ',
                                                   ' ',
                                                   1,
                                                   1),
                                              INSTR (a.dsd_fio || '   ',
                                                     ' ',
                                                     1,
                                                     2)
                                            - INSTR (a.dsd_fio || '   ',
                                                     ' ',
                                                     1,
                                                     1))))
                             fio_fn,
                         MAX (TRIM (SUBSTR (a.dsd_fio || '   ',
                                            INSTR (a.dsd_fio || '   ',
                                                   ' ',
                                                   1,
                                                   2),
                                            500)))
                             fio_sn,
                         LPAD (LPAD (a.dsd_raj, 4, '0'), 5, '5')
                             dsd_base_org,
                         COUNT (*) OVER ()
                             cnt,
                         MAX (a.lfdp_id)
                             lfdp_id
                    FROM uss_exch.v_ls_b_dsd_data a
                   WHERE a.lfd_lfd = p_lfd_lfd
                GROUP BY a.dsd_nls,
                         a.dsd_raj,
                         a.dsd_pasp,
                         a.dsd_idcode)
        LOOP
            BEGIN
                l_cnt := l_cnt + 1;
                l_log_msg :=
                       'ОР №'
                    || rec_dsd.dsd_base_org
                    || '_'
                    || rec_dsd.dsd_nls
                    || '. Запис '
                    || l_cnt
                    || ' з '
                    || rec_dsd.cnt;
                SetAction (l_log_msg);

                l_flag := 1;
                l_error_msg := '';
                l_sc_id := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;
                l_apr_id := NULL;
                l_com_org := NULL;

                DELETE tmp_work_set1
                 WHERE 1 = 1;

                FOR rec_fml
                    IN (  SELECT TRIM (
                                     SUBSTR (f.fam_fio || '   ',
                                             1,
                                             INSTR (f.fam_fio || '   ',
                                                    ' ',
                                                    1,
                                                    1)))    fio_ln,
                                 TRIM (
                                     SUBSTR (
                                         f.fam_fio || '   ',
                                         INSTR (f.fam_fio || '   ',
                                                ' ',
                                                1,
                                                1),
                                           INSTR (f.fam_fio || '   ',
                                                  ' ',
                                                  1,
                                                  2)
                                         - INSTR (f.fam_fio || '   ',
                                                  ' ',
                                                  1,
                                                  1)))      fio_fn,
                                 TRIM (
                                     SUBSTR (f.fam_fio || '   ',
                                             INSTR (f.fam_fio || '   ',
                                                    ' ',
                                                    1,
                                                    2),
                                             500))          fio_sn,
                                 TO_DATE (
                                     f.fam_dtr
                                         DEFAULT NULL ON CONVERSION ERROR,
                                     'dd.mm.yyyy')          fam_dtr,
                                 f.fam_nom,
                                 CASE
                                     WHEN f.fam_nom = '0'
                                     THEN
                                         rec_dsd.dsd_idcode
                                     ELSE
                                         f.fam_idcode
                                 END                        fam_idcode,
                                 CASE
                                     WHEN f.fam_nom = '0'
                                     THEN
                                         rec_dsd.dsd_pasp
                                     ELSE
                                         NULL
                                 END                        dsd_pasp,
                                 f.lfd_id,
                                 f.lfd_lfd,
                                 f.lfdp_id
                            FROM uss_exch.v_ls_a_fam2_data f
                           WHERE     f.lfd_lfd = p_lfd_lfd
                                 AND f.dsd_nzv = rec_dsd.Dsd_Nzv
                                 AND TO_DATE (
                                         f.Dsd_DtObr
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy') =
                                     rec_dsd.Dsd_DtObr
                        ORDER BY TO_NUMBER (f.fam_nom))
                LOOP
                    l_fam_nom := rec_fml.fam_nom;
                    l_sc_id := NULL;
                    l_sc_id :=
                        uss_person.load$socialcard.Load_SC_Intrnl (
                            p_fn            => TOOLS.Clear_Name (rec_fml.fio_fn),
                            p_ln            => TOOLS.Clear_Name (rec_fml.fio_ln),
                            p_mn            => TOOLS.Clear_Name (rec_fml.fio_sn),
                            p_gender        => NULL,
                            p_nationality   => NULL,
                            p_src_dt        => NULL,
                            p_birth_dt      => rec_fml.fam_dtr,
                            p_inn_num       =>
                                CASE
                                    WHEN REGEXP_LIKE (rec_fml.fam_idcode,
                                                      '^(\d){10}$')
                                    THEN
                                        rec_fml.fam_idcode
                                    ELSE
                                        NULL
                                END,
                            p_inn_ndt       =>
                                CASE
                                    WHEN REGEXP_LIKE (rec_fml.fam_idcode,
                                                      '^(\d){10}$')
                                    THEN
                                        5
                                    ELSE
                                        NULL
                                END,                          -- тип из архива
                            p_doc_ser       =>
                                CASE
                                    WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                      '^(\d){9}$')
                                    THEN
                                        NULL
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        SUBSTR (rec_fml.dsd_pasp, 1, 2)
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        SUBSTR (rec_fml.dsd_pasp, 1, 4)
                                    ELSE
                                        NULL
                                END,
                            p_doc_num       =>
                                CASE
                                    WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                      '^(\d){9}$')
                                    THEN
                                        rec_fml.dsd_pasp
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        SUBSTR (rec_fml.dsd_pasp, -6, 6)
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        SUBSTR (rec_fml.dsd_pasp, -6, 6)
                                    ELSE
                                        NULL
                                END,
                            p_doc_ndt       =>
                                CASE
                                    WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                      '^(\d){9}$')
                                    THEN
                                        7                     -- новій паспорт
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        6                -- старій паспорт из архива
                                    WHEN REGEXP_LIKE (
                                             rec_fml.dsd_pasp,
                                             '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                    THEN
                                        37                -- свидетельство о рождении
                                    ELSE
                                        NULL
                                END,
                            p_src           => '710',
                            p_sc            => l_sc_id,
                            p_sc_unique     => l_sc_unique,
                            p_sc_scc        => l_sc_scc,
                            p_mode          => 1              -- тільки звірка
                                                );

                    -- Якщо знайшли карту добавляємо в обробку
                    /*
                    if l_sc_id > 0 then
                        update tmp_work_set1
                            set x_id1 = l_sc_id
                            where x_string1 = rec_fml.fam_nom;
                        if sql%rowcount = 0 then
                            insert into tmp_work_set1(x_id1, x_string1)
                                values(l_sc_id, rec_fml.fam_nom);
                        end if;
                    elsif l_sc_id = -2 then
                      raise ex_error_sc_2;
                    elsif l_sc_id = -1 then
                      raise ex_error_sc_1;
                    else
                      raise ex_error_sc_else;
                    end if;
                    */
                    -- IC #96235
                    UPDATE tmp_work_set1
                       SET x_id1 = l_sc_id, x_dt1 = rec_fml.fam_dtr
                     WHERE x_string1 = rec_fml.fam_nom;

                    IF SQL%ROWCOUNT = 0
                    THEN
                        INSERT INTO tmp_work_set1 (x_id1, x_dt1, x_string1)
                                 VALUES (l_sc_id,
                                         rec_fml.fam_dtr,
                                         rec_fml.fam_nom);
                    END IF;
                END LOOP;


                BEGIN
                    -- Звіряємо наявність СК з існуючим рішенням
                    SELECT pc.pc_id,
                           ap.ap_id,
                           pd.pd_id,
                           pd.pd_dt,
                           prl.prl_hs_rewrite,
                           ap.com_org
                      INTO l_pc_id,
                           l_ap_id,
                           l_pd_id,
                           l_pd_dt,
                           l_hs_rewrite,
                           l_com_org
                      FROM appeal  ap
                           INNER JOIN personalcase pc ON pc.pc_id = ap.ap_pc
                           INNER JOIN pc_decision pd
                               ON pd.pd_ap = ap.ap_id AND pd.pd_pc = pc.pc_id
                           LEFT JOIN pd_right_log prl
                               ON prl.prl_pd = pd.pd_id
                     WHERE     ap.ap_num =
                               rec_dsd.dsd_base_org || '_' || rec_dsd.dsd_nls
                           AND ROWNUM = 1;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        RAISE ex_error_ap_isnotexist;
                END;

                -- IC #96235 спочатку шукаємо по РНОКПП, якщо не знайдено, тоді шукаємо по полю Fam_DateR (B_Fam) або Fam_DtR (A_Fam_) порівнюємо з учасниками по полю "дата народження"
                FOR c IN (  SELECT x_id1, x_dt1, x_string1
                              FROM tmp_work_set1
                             WHERE NVL (x_id1, 0) <= 0
                          ORDER BY x_string1)
                LOOP
                    SELECT MAX (f.pdf_sc)
                      INTO l_sc_id
                      FROM uss_esr.pd_family f
                     WHERE f.pdf_pd = l_pd_id AND f.pdf_birth_dt = c.x_dt1;

                    IF l_sc_id > 0
                    THEN
                        UPDATE tmp_work_set1
                           SET x_id1 = l_sc_id
                         WHERE x_string1 = c.x_string1;
                    ELSIF c.x_id1 = -2
                    THEN
                        RAISE ex_error_sc_2;
                    ELSIF c.x_id1 = -1
                    THEN
                        RAISE ex_error_sc_1;
                    ELSE
                        RAISE ex_error_sc_else;
                    END IF;
                END LOOP;

                l_lock :=
                    tools.request_lock_with_timeout (
                        p_descr               => 'MIGR_API_' || l_ap_id,
                        p_error_msg           =>
                            'В данний час вже виконуються завантаження для Зверення ЕОС, спробуйте дозавантажити пізніше.',
                        p_timeout             => 13,
                        p_release_on_commit   => TRUE);
                -- IC #85870 При міграції доходів по завантаженим рішенням очищати вже наявні доходи
                Clear_Income (l_ap_id, l_pd_id, l_load_type);

                FOR rec_rddm2
                    IN (  SELECT a.lfdp_id,
                                 TO_DATE (
                                        '01'
                                     || LPAD (a.rddm_month, 2, '0')
                                     || a.rddm_year
                                         DEFAULT NULL ON CONVERSION ERROR,
                                     'ddmmyyyy')
                                     API_MONTH,
                                   --                        TO_DATE(a.dsd_dtobr DEFAULT Null ON CONVERSION ERROR,
                                   --                            'dd.mm.yyyy')                                       API_MONTH,
                                   TO_NUMBER (
                                       a.rddm_sum
                                           DEFAULT NULL ON CONVERSION ERROR)
                                 * CASE WHEN a.rddo_pr = '0' THEN -1 ELSE 1 END
                                     API_SUM,
                                   CEIL (
                                         TO_NUMBER (
                                             a.rddm_sum
                                                 DEFAULT NULL ON CONVERSION ERROR)
                                       * CASE
                                             WHEN a.rddo_pr = '0' THEN -1
                                             ELSE 1
                                         END
                                       * 100)
                                 * 0.01
                                     API_SUM_B,
                                 ROW_NUMBER ()
                                     OVER (
                                         PARTITION BY a.rdd_numbf,
                                                      a.rdd_npp,
                                                      a.rddm_sum
                                         ORDER BY
                                             a.rddm_year || a.rddm_month DESC)
                                     rn,
                                 NULL
                                     API_EXCH_TP,
                                 NVL (ndc.nddc_code_dest, '6')
                                     API_TP,
                                 CASE
                                     WHEN ndc.nddc_code_src = '3' THEN 'T'
                                     ELSE 'F'
                                 END
                                     API_ESV_PAI,
                                 CASE
                                     WHEN ndc.nddc_code_src = '3' THEN 'T'
                                     ELSE 'F'
                                 END
                                     API_ESV_MIN,
                                 a.rdd_numbf,
                                 sc.x_id1
                                     sc_id,
                                 p.app_id
                            FROM uss_exch.v_ls_b_rddm2_data a
                                 INNER JOIN tmp_work_set1 sc
                                     ON sc.x_string1 = a.rdd_numbf
                                 INNER JOIN uss_esr.ap_person p
                                     ON     p.app_ap = l_ap_id
                                        AND p.app_sc = sc.x_id1
                                 LEFT JOIN uss_ndi.v_NDI_DECODING_CONFIG ndc
                                     ON     ndc.nddc_code_src = a.rdd_aspectcd
                                        AND ndc.nddc_tp = 'API_GROUP'
                           WHERE     a.lfd_lfd = p_lfd_lfd
                                 AND TO_NUMBER (
                                         a.rddm_sum
                                             DEFAULT NULL ON CONVERSION ERROR) >
                                     0
                                 --and LPAD(a.rddm_month,2,'0') = TO_CHAR(rec_dsd.Dsd_DtObr,'mm')
                                 --and a.rddm_year = TO_CHAR(rec_dsd.Dsd_DtObr,'yyyy')
                                 AND TO_DATE (
                                         a.dsd_dtobr
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy') =
                                     rec_dsd.Dsd_DtObr
                                 AND a.dsd_nzv = rec_dsd.Dsd_Nzv
                        ORDER BY 1)
                LOOP
                    l_api_sum :=
                        CASE
                            WHEN rec_rddm2.rn = 1 THEN rec_rddm2.API_SUM_B
                            ELSE rec_rddm2.API_SUM
                        END;

                    INSERT INTO ap_income (api_id,
                                           api_app,
                                           api_month,
                                           api_src,
                                           api_sum,
                                           api_exch_tp,
                                           api_tp,
                                           api_esv_paid,
                                           api_esv_min,
                                           api_edrpou,
                                           api_start_dt,
                                           api_stop_dt,
                                           api_use_tp)
                         VALUES (0,
                                 rec_rddm2.app_id,                -- l_app_id,
                                 rec_rddm2.API_MONTH,
                                 l_load_type,
                                 l_api_sum,
                                 NULL,
                                 rec_rddm2.API_TP,
                                 rec_rddm2.API_ESV_PAI,
                                 rec_rddm2.API_ESV_MIN,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL)
                      RETURNING api_id
                           INTO l_api_id;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_rddm2.lfdp_id,
                                     l_api_id,
                                     'USS_ESR.AP_INCOME');

                    INSERT INTO pd_income_src (pis_id,
                                               pis_src,
                                               pis_tp,
                                               pis_edrpou,
                                               pis_fact_sum,
                                               pis_final_sum,
                                               pis_hs_rewrite,
                                               pis_sc,
                                               pis_esv_paid,
                                               pis_esv_min,
                                               pis_start_dt,
                                               pis_stop_dt,
                                               pis_pd,
                                               pis_app,
                                               pis_is_use,
                                               pis_exch_tp)
                         VALUES (0,
                                 l_load_type,
                                 rec_rddm2.API_TP,
                                 NULL,                            --pis_edrpou
                                 l_api_sum,
                                 l_api_sum,
                                 l_hs_rewrite,
                                 rec_rddm2.sc_id,
                                 rec_rddm2.API_ESV_PAI,
                                 rec_rddm2.API_ESV_MIN,
                                 rec_rddm2.API_MONTH,
                                 LAST_DAY (rec_rddm2.API_MONTH),
                                 l_pd_id,
                                 rec_rddm2.app_id,                 --l_app_id,
                                 'T',                             --pis_is_use
                                 NULL                            --pis_exch_tp
                                     )
                      RETURNING pis_id
                           INTO l_pis_id;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_rddm2.lfdp_id,
                                     l_pis_id,
                                     'USS_ESR.PD_INCOME_SRC');
                END LOOP;

                -- IC #88202
                -- Декларація про доходи ----------
                FOR c
                    IN (SELECT t.lfdp_id
                          FROM uss_exch.v_ls_b_trans2_data t
                         WHERE     t.lfd_lfd = p_lfd_lfd
                               AND t.dsd_nzv = rec_dsd.Dsd_Nzv
                               AND TO_DATE (
                                       t.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') =
                                   rec_dsd.Dsd_DtObr
                        UNION ALL
                        SELECT t.lfdp_id
                          FROM uss_exch.v_ls_s_mnact2_data t
                         WHERE     t.lfd_lfd = p_lfd_lfd
                               AND t.dsd_nzv = rec_dsd.Dsd_Nzv
                               AND TO_DATE (
                                       t.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') =
                                   rec_dsd.Dsd_DtObr)
                LOOP
                    INSERT INTO uss_esr.ap_declaration (apr_id,
                                                        apr_fn,
                                                        apr_mn,
                                                        apr_ln,
                                                        apr_residence,
                                                        com_org,
                                                        apr_start_dt,
                                                        apr_stop_dt,
                                                        apr_ap)
                         VALUES (NULL,
                                 rec_dsd.fio_fn,
                                 rec_dsd.fio_sn,
                                 rec_dsd.fio_ln,
                                 NULL,                         --apr_residence
                                 l_com_org,
                                 rec_dsd.dsd_datedoxbeg,
                                 rec_dsd.dsd_datedoxend,
                                 l_ap_id)
                      RETURNING apr_id
                           INTO l_apr_id;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (c.lfdp_id,
                                     l_apr_id,
                                     'USS_ESR.AP_DECLARATION');

                    EXIT;
                END LOOP;

                IF NVL (l_apr_id, 0) > 0
                THEN
                    INSERT INTO uss_esr.apr_person (aprp_id,
                                                    aprp_apr,
                                                    aprp_tp,
                                                    aprp_inn,
                                                    history_status,
                                                    aprp_app)
                          SELECT 0
                                     aprp_id,
                                 l_apr_id
                                     aprp_apr,
                                 a.app_tp,
                                 (SELECT MAX (scd_number)
                                    FROM uss_person.v_sc_document
                                   WHERE     scd_sc = a.app_sc
                                         AND scd_ndt = 5
                                         AND scd_st IN ('1', 'A'))
                                     aprp_inn,
                                 'A'
                                     history_status,
                                 a.app_id
                            FROM uss_esr.ap_person a
                           WHERE a.history_status = 'A' AND a.app_ap = l_ap_id
                        ORDER BY a.app_id;

                    SELECT MIN (p.aprp_id)
                      INTO l_aprp_id
                      FROM uss_esr.apr_person p
                     WHERE p.aprp_apr = l_apr_id AND p.aprp_tp = 'Z';

                    INSERT INTO uss_esr.apr_vehicle (aprv_apr,
                                                     aprv_ln_initials,
                                                     aprv_car_brand,
                                                     aprv_license_plate,
                                                     aprv_production_year,
                                                     aprv_is_social_car,
                                                     aprv_aprp,
                                                     history_status)
                        SELECT l_apr_id
                                   aprv_apr,
                               NULL
                                   aprv_ln_initials,
                               t.trans_name
                                   aprv_car_brand,
                               NULL
                                   aprv_license_plate,
                               TO_NUMBER (
                                   t.trans_godv
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   aprv_production_year,
                               CASE
                                   WHEN t.trans_pilga = '0' THEN 'F'
                                   ELSE 'T'
                               END
                                   aprv_is_social_car,
                               l_aprp_id
                                   aprv_aprp,
                               'A'
                                   history_status
                          FROM uss_exch.v_ls_b_trans2_data t
                         WHERE     t.lfd_lfd = p_lfd_lfd
                               AND t.dsd_nzv = rec_dsd.Dsd_Nzv
                               AND TO_DATE (
                                       t.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') =
                                   rec_dsd.Dsd_DtObr;

                    INSERT INTO uss_esr.apr_living_quarters (
                                    aprl_apr,
                                    aprl_ln_initials,
                                    aprl_area,
                                    aprl_qnt,
                                    aprl_address,
                                    aprl_aprp,
                                    history_status,
                                    aprl_tp,
                                    aprl_ch)
                        -- Будинок
                        SELECT l_apr_id
                                   aprl_apr,
                               NULL
                                   aprl_ln_initials,
                               TO_NUMBER (
                                   t.mna_dompl
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   aprl_area,
                               TO_NUMBER (
                                   t.mna_kolprdom
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   aprl_qnt,
                               NULL
                                   aprl_address,
                               l_aprp_id
                                   aprl_aprp,
                               'A'
                                   history_status,
                               2
                                   aprl_tp, -- uss_ndi.V_DDN_APRL_TP 1/2 квартира/будинок
                               NULL
                                   aprl_ch
                          FROM uss_exch.v_ls_s_mnact2_data t
                         WHERE     t.mna_dom != '0'
                               AND t.lfd_lfd = p_lfd_lfd
                               AND t.dsd_nzv = rec_dsd.Dsd_Nzv
                               AND TO_DATE (
                                       t.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') =
                                   rec_dsd.Dsd_DtObr
                        UNION ALL
                        -- Квартира
                        SELECT l_apr_id
                                   aprl_apr,
                               NULL
                                   aprl_ln_initials,
                               TO_NUMBER (
                                   t.mna_kvrtpl
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   aprl_area,
                               TO_NUMBER (
                                   t.mna_kolprkvrt
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   aprl_qnt,
                               NULL
                                   aprl_address,
                               l_aprp_id
                                   aprl_aprp,
                               'A'
                                   history_status,
                               1
                                   aprl_tp, -- uss_ndi.V_DDN_APRL_TP 1/2 квартира/будинок
                               NULL
                                   aprl_ch
                          FROM uss_exch.v_ls_s_mnact2_data t
                         WHERE     t.mna_kvrt != '0'
                               AND t.lfd_lfd = p_lfd_lfd
                               AND t.dsd_nzv = rec_dsd.Dsd_Nzv
                               AND TO_DATE (
                                       t.Dsd_DtObr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'dd.mm.yyyy') =
                                   rec_dsd.Dsd_DtObr;
                END IF;

                l_cnt_ld := l_cnt_ld + 1;

                IF l_log_det > 0
                THEN
                    SELECT MAX (x_id1)
                      INTO l_sc_id
                      FROM tmp_work_set1
                     WHERE x_string1 = '0';

                    WriteLineToBlob (
                        p_line   =>
                               'Завантажено: '
                            || l_log_msg
                            || '; SC: '
                            || TO_CHAR (l_sc_id),
                        p_blob   => l_blob);
                END IF;

                -- IC #95958
                -- По основній міграції доходів по допомогам теж додаємо новий масив S_ItogSum_
                FOR itogsum
                    IN (  SELECT TO_NUMBER (
                                     s.perp_sumdohs
                                         DEFAULT NULL ON CONVERSION ERROR)
                                     pic_total_income_6m, -- (Сукупний дохід сім`ї за 6 місяців)
                                 TO_NUMBER (
                                     s.perp_sumdearth
                                         DEFAULT NULL ON CONVERSION ERROR)
                                     pic_plot_income_6m, -- (Сукупний дохід за 6 місяців від землі)
                                 TO_NUMBER (
                                     s.perp_sumdohf
                                         DEFAULT NULL ON CONVERSION ERROR)
                                     pic_month_income, -- (Сукупний середньомісячний дохід сім`ї)
                                 TO_NUMBER (
                                     s.perp_countfam
                                         DEFAULT NULL ON CONVERSION ERROR)
                                     pic_members_number, -- (Кількість членів сім`ї)
                                 ROUND (
                                     CASE
                                         WHEN TO_NUMBER (
                                                  s.perp_countfam
                                                      DEFAULT 0 ON CONVERSION ERROR) =
                                              0
                                         THEN
                                             0
                                         ELSE
                                               TO_NUMBER (
                                                   s.perp_sumdohf
                                                       DEFAULT NULL ON CONVERSION ERROR)
                                             / TO_NUMBER (s.perp_countfam)
                                     END,
                                     2)
                                     pic_member_month_income, -- (Середньомісячний дохід члена сім`ї)
                                 TO_NUMBER (
                                     s.perp_summax
                                         DEFAULT NULL ON CONVERSION ERROR)
                                     pic_limit          -- (Гранична величина)
                            FROM uss_exch.v_ls_s_itogsum2_data s
                           WHERE     s.lfd_lfd = p_lfd_lfd
                                 AND TO_NUMBER (
                                         s.perp_sumdohs
                                             DEFAULT 0 ON CONVERSION ERROR) >
                                     0
                                 AND s.dsd_nzv = rec_dsd.Dsd_Nzv
                                 AND TO_DATE (
                                         s.dsd_dtobr
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy') =
                                     rec_dsd.Dsd_DtObr
                        ORDER BY s.rn)
                LOOP
                    -- IC #96496 при переміграції по рішенню можливе лише одне PD_INCOME_CALC
                    DELETE FROM uss_esr.pd_income_detail
                          WHERE pid_pic IN (SELECT pic_id
                                              FROM uss_esr.pd_income_calc
                                             WHERE pic_pd = l_pd_id);

                    DELETE FROM uss_esr.pd_income_calc
                          WHERE pic_pd = l_pd_id;

                    INSERT INTO uss_esr.pd_income_calc (
                                    pic_id,
                                    pic_dt,
                                    pic_pc,
                                    pic_pd,
                                    pic_total_income_6m,
                                    pic_plot_income_6m,
                                    pic_month_income,
                                    pic_members_number,
                                    pic_member_month_income,
                                    pic_limit)
                         VALUES (0,
                                 l_pd_dt,
                                 l_pc_id,
                                 l_pd_id,
                                 itogsum.pic_total_income_6m,
                                 itogsum.pic_plot_income_6m,
                                 itogsum.pic_month_income,
                                 itogsum.pic_members_number,
                                 itogsum.pic_member_month_income,
                                 itogsum.pic_limit)
                      RETURNING pic_id
                           INTO l_pic_id;

                    -- IC #96496 Додати в міграцію заповнення PD_INCOME_DETAIL
                    -- Заповнюється так само, як і PD_INCOME_SRC
                    INSERT INTO uss_esr.pd_income_detail (
                                    pid_id,
                                    pid_pic,
                                    pid_sc,
                                    pid_fact_sum,
                                    pid_app,
                                    pid_calc_sum,
                                    pid_month,
                                    pid_min_zp,
                                    pid_koef,
                                    pid_is_family_member)
                        SELECT 0                 pid_id,
                               l_pic_id          pid_pic,
                               pis_sc            pid_sc,
                               pis_fact_sum      pid_fact_sum,
                               pis_app           pid_app,
                               pis_final_sum     pid_calc_sum,
                               pis_start_dt      pid_month,
                               NULL              pid_min_zp,
                               NULL              pid_koef,
                               'T'               pid_is_family_member
                          FROM uss_esr.pd_income_src
                         WHERE pis_pd = l_pd_id AND pis_src = l_load_type;

                    EXIT;
                END LOOP;

                -- фіксація по кожному НЛС
                COMMIT;
            EXCEPTION
                WHEN ex_error_sc_2
                THEN
                    l_error_msg :=
                           rec_dsd.dsd_nls
                        || '; Документи особи не вказано чи неможливо визначити тип документа;'
                        || 'Особа: '
                        || l_fam_nom
                        || ';';
                WHEN ex_error_sc_1
                THEN
                    l_error_msg :=
                           rec_dsd.dsd_nls
                        || '; За вхідними документами знайдено більше однієї особи в ЄСР;'
                        || 'Особа: '
                        || l_fam_nom
                        || ';';
                WHEN ex_error_sc_else
                THEN
                    l_error_msg :=
                           rec_dsd.dsd_nls
                        || '; Особа з вказаним ІПН паспортом або датою народження не знайдена;'
                        || 'Особа: '
                        || l_fam_nom
                        || ';';
                WHEN ex_error_ap_isnotexist
                THEN
                    l_error_msg :=
                           rec_dsd.dsd_nls
                        || '; Рішення з номером '
                        || rec_dsd.dsd_base_org
                        || '_'
                        || rec_dsd.Dsd_Nzv
                        || ' не завантажувалося;';
                WHEN OTHERS
                THEN
                    l_error_msg :=
                           rec_dsd.dsd_nls
                        || '; Некоректні вхідні данні;'
                        || DBMS_UTILITY.format_error_stack
                        || DBMS_UTILITY.format_error_backtrace;
            END;

            -- запись ошибки
            IF l_error_msg IS NOT NULL
            THEN
                BEGIN                                 -- если потеряли хендлер
                    tools.release_lock (p_lock_handler => l_lock);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                ROLLBACK;
                WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                SetNlsLog (rec_dsd.lfdp_id, -1, l_error_msg);
            END IF;
        END LOOP;

        IF l_flag = 1
        THEN
            NULL;
            --dbms_output.put_line(l_error_msg);
            WriteLineToBlob (p_line   => ' Завантаження завершено.',
                             p_blob   => l_blob);
            WriteLineToBlob (
                p_line   => ' Загальна кількість ОР: ' || TO_CHAR (l_cnt),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість ОР завантажено: ' || TO_CHAR (l_cnt_ld),
                p_blob   => l_blob);
        END IF;

        IF l_flag = 0
        THEN
            WriteLineToBlob (
                p_line   => ' Відсутні особові рахунки для завантаження',
                p_blob   => l_blob);
        END IF;

        IF (DBMS_LOB.getlength (l_blob) > 0)
        THEN
            uss_exch.load_file_prtcl.insertprotocol (
                p_lfp_id        => l_lfp_id,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => p_lfd_lfd,
                p_lfp_tp        => NULL,
                p_lfp_name      =>
                       l_filename
                    || '(загальний протокол завантаження)'
                    || '.csv',
                p_lfp_comment   => NULL,
                p_content       => l_blob);
        END IF;
    /*
  uss_exch.load_file_prtcl.checkloadussdata(
    p_lfd_id => p_lfd_lfd,
    p_nls_list => l_blob
    );
    */
    END Load_INCOME;

    FUNCTION getOrgbyLFD (p_lfd_lfd IN NUMBER)
        RETURN NUMBER
    IS
        l_org_id   NUMBER;
    BEGIN
        -- IC #90093
        -- я буду вимагати від них, щоб назва архіву починалася з № району, наприклад "50502_". І шукати тоді лише по цьому району
        SELECT o.org_id
          INTO l_org_id
          FROM uss_exch.v_load_file_data  d
               --left join uss_ndi.v_ndi_decoding_config c   on c.nddc_code_src = TO_NUMBER(substr(d.lfd_file_name,1,5) default null on conversion error)
               --                                                and c.nddc_tp = 'ORG_MIGR'
               INNER JOIN ikis_sys.v_opfu o
                   ON o.org_code = SUBSTR (d.lfd_file_name, 1, 5)
         --and o.org_st = 'A'
         WHERE d.lfd_id = p_lfd_lfd AND ROWNUM = 1;

        RETURN l_org_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END getOrgbyLFD;

    PROCEDURE Load_LsPos (p_lfd_lfd           NUMBER,
                          p_migration_force   NUMBER DEFAULT 0)
    IS
        l_sc_id        NUMBER;
        l_sc_scc       NUMBER;
        l_sc_unique    VARCHAR2 (100);
        l_pc_id        NUMBER;
        l_ap_id        appeal.ap_id%TYPE;
        l_app_id       ap_person.app_id%TYPE;
        l_pd_id        pc_decision.pd_id%TYPE;
        l_pd_dt        pc_decision.pd_dt%TYPE;
        l_api_id       ap_income.api_id%TYPE;
        l_pis_id       pd_income_src.pis_id%TYPE;
        l_pic_id       pd_income_calc.pic_id%TYPE;
        l_hs_rewrite   pd_right_log.prl_hs_rewrite%TYPE;

        l_lfp_id       NUMBER;
        l_load_type    VARCHAR2 (8) := 'ASOPD';
        l_error_msg    VARCHAR2 (4000);
        l_log_msg      VARCHAR2 (4000);
        l_filename     VARCHAR2 (128);
        l_lock         TOOLS.t_lockhandler;
        l_flag         NUMBER := 0; -- флаг для проверки что есть что поданному файлу отрабатівать или нет
        l_blob         BLOB;
        l_cnt          NUMBER := 0;
        l_cnt_ld       NUMBER := 0;
        l_log_det      NUMBER := 0;
        l_api_sum      NUMBER := 0;
        l_fam_nom      VARCHAR2 (3);
        l_apr_id       uss_esr.ap_declaration.apr_id%TYPE;
        l_aprp_id      uss_esr.apr_person.aprp_id%TYPE;
        l_com_org      NUMBER;
        l_load_org     NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Інформація: ',
                         p_blob   => l_blob);

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        BEGIN
            SELECT COUNT (*)
              INTO l_log_det
              FROM paramsesr
             WHERE prm_code = 'ASOPD_LOG_DET' AND prm_value = 'T';
        EXCEPTION
            WHEN OTHERS
            THEN
                l_log_det := 0;
        END;

        l_load_org := getOrgbyLFD (p_lfd_lfd);

        IF l_load_org IS NULL
        THEN
            l_error_msg := 'Помилка визначення актуального району';
        END IF;

        IF l_error_msg IS NULL
        THEN
            l_error_prm := UPPER ('b_naz');

            FOR rec_naz IN (  SELECT a.lfdp_id,
                                     a.lspos_nls,
                                     a.naz_op,
                                     a.naz_dobr,
                                     COUNT (*) OVER ()     cnt
                                FROM uss_exch.v_ls_b_naz_data a
                               WHERE a.lfd_lfd = p_lfd_lfd
                            ORDER BY 1)
            LOOP
                BEGIN
                    l_cnt := l_cnt + 1;
                    l_log_msg :=
                           'ОР №'
                        || TO_CHAR (l_load_org)
                        || '_'
                        || rec_naz.lspos_nls
                        || '. Запис '
                        || l_cnt
                        || ' з '
                        || rec_naz.cnt;
                    SetAction (l_log_msg);

                    l_flag := 1;
                    l_error_msg := '';
                    l_sc_id := NULL;
                    l_sc_scc := NULL;
                    l_sc_unique := NULL;
                    l_apr_id := NULL;
                    l_com_org := NULL;

                    DELETE tmp_work_set1
                     WHERE 1 = 1;

                    FOR rec_fml
                        IN (  SELECT TRIM (
                                         SUBSTR (
                                             f.fam_fio || '   ',
                                             1,
                                             INSTR (f.fam_fio || '   ',
                                                    ' ',
                                                    1,
                                                    1)))    fio_ln,
                                     TRIM (
                                         SUBSTR (
                                             f.fam_fio || '   ',
                                             INSTR (f.fam_fio || '   ',
                                                    ' ',
                                                    1,
                                                    1),
                                               INSTR (
                                                   f.fam_fio || '   ',
                                                   ' ',
                                                   1,
                                                   2)
                                             - INSTR (
                                                   f.fam_fio || '   ',
                                                   ' ',
                                                   1,
                                                   1)))     fio_fn,
                                     TRIM (
                                         SUBSTR (
                                             f.fam_fio || '   ',
                                             INSTR (f.fam_fio || '   ',
                                                    ' ',
                                                    1,
                                                    2),
                                             500))          fio_sn,
                                     TO_DATE (
                                         f.fam_dater
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'dd.mm.yyyy')      fam_dtr,
                                     f.fam_nom,
                                     f.fam_idcode,
                                     NULL                   dsd_pasp,
                                     f.fam_fio
                                FROM uss_exch.v_ls_b_fam_data f
                               WHERE     f.lfd_lfd = p_lfd_lfd
                                     AND f.lspos_nls = rec_naz.lspos_nls
                                     AND f.naz_op = rec_naz.naz_op
                                     AND f.naz_dobr = rec_naz.naz_dobr
                            ORDER BY TO_NUMBER (f.fam_nom), f.lfd_id)
                    LOOP
                        l_fam_nom := rec_fml.fam_nom;
                        l_sc_id := NULL;
                        l_sc_id :=
                            uss_person.load$socialcard.Load_SC_Intrnl (
                                p_fn            => TOOLS.Clear_Name (rec_fml.fio_fn),
                                p_ln            => TOOLS.Clear_Name (rec_fml.fio_ln),
                                p_mn            => TOOLS.Clear_Name (rec_fml.fio_sn),
                                p_gender        => NULL,
                                p_nationality   => NULL,
                                p_src_dt        => NULL,
                                p_birth_dt      => rec_fml.fam_dtr,
                                p_inn_num       =>
                                    CASE
                                        WHEN REGEXP_LIKE (rec_fml.fam_idcode,
                                                          '^(\d){10}$')
                                        THEN
                                            rec_fml.fam_idcode
                                        ELSE
                                            NULL
                                    END,
                                p_inn_ndt       =>
                                    CASE
                                        WHEN REGEXP_LIKE (rec_fml.fam_idcode,
                                                          '^(\d){10}$')
                                        THEN
                                            5
                                        ELSE
                                            NULL
                                    END,                      -- тип из архива
                                p_doc_ser       =>
                                    CASE
                                        WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                          '^(\d){9}$')
                                        THEN
                                            NULL
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            SUBSTR (rec_fml.dsd_pasp, 1, 2)
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            SUBSTR (rec_fml.dsd_pasp, 1, 4)
                                        ELSE
                                            NULL
                                    END,
                                p_doc_num       =>
                                    CASE
                                        WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                          '^(\d){9}$')
                                        THEN
                                            rec_fml.dsd_pasp
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            SUBSTR (rec_fml.dsd_pasp, -6, 6)
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            SUBSTR (rec_fml.dsd_pasp, -6, 6)
                                        ELSE
                                            NULL
                                    END,
                                p_doc_ndt       =>
                                    CASE
                                        WHEN REGEXP_LIKE (rec_fml.dsd_pasp,
                                                          '^(\d){9}$')
                                        THEN
                                            7                 -- новій паспорт
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            6            -- старій паспорт из архива
                                        WHEN REGEXP_LIKE (
                                                 rec_fml.dsd_pasp,
                                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                        THEN
                                            37            -- свидетельство о рождении
                                        ELSE
                                            NULL
                                    END,
                                p_src           => '710',
                                p_sc            => l_sc_id,
                                p_sc_unique     => l_sc_unique,
                                p_sc_scc        => l_sc_scc,
                                p_mode          => 1          -- тільки звірка
                                                    );

                        -- Якщо знайшли карту добавляємо в обробку
                        /*
                        if l_sc_id > 0 then
                            update tmp_work_set1
                                set x_id1 = l_sc_id,
                                    x_string2 = rec_fml.fam_fio
                                where x_string1 = rec_fml.fam_nom;
                            if sql%rowcount = 0 then
                                insert into tmp_work_set1(x_id1, x_string1, x_string2)
                                    values(l_sc_id, rec_fml.fam_nom, rec_fml.fam_fio);
                            end if;
                        elsif l_sc_id = -2 then
                          raise ex_error_sc_2;
                        elsif l_sc_id = -1 then
                          raise ex_error_sc_1;
                        else
                          raise ex_error_sc_else;
                        end if;
                        */
                        -- IC #96235
                        UPDATE tmp_work_set1
                           SET x_id1 = l_sc_id,
                               x_dt1 = rec_fml.fam_dtr,
                               x_string2 = rec_fml.fam_fio
                         WHERE x_string1 = rec_fml.fam_nom;

                        IF SQL%ROWCOUNT = 0
                        THEN
                            INSERT INTO tmp_work_set1 (x_id1,
                                                       x_dt1,
                                                       x_string1,
                                                       x_string2)
                                 VALUES (l_sc_id,
                                         rec_fml.fam_dtr,
                                         rec_fml.fam_nom,
                                         rec_fml.fam_fio);
                        END IF;
                    END LOOP;                                       -- rec_fml

                    BEGIN
                        -- Звіряємо наявність СК з існуючим рішенням
                        SELECT ap.ap_id,
                               pc.pc_id,
                               pd.pd_id,
                               pd.pd_dt,
                               prl.prl_hs_rewrite,
                               ap.com_org
                          INTO l_ap_id,
                               l_pc_id,
                               l_pd_id,
                               l_pd_dt,
                               l_hs_rewrite,
                               l_com_org
                          FROM appeal  ap
                               INNER JOIN personalcase pc
                                   ON pc.pc_id = ap.ap_pc
                               INNER JOIN pc_decision pd
                                   ON     pd.pd_ap = ap.ap_id
                                      AND pd.pd_pc = pc.pc_id
                               LEFT JOIN pd_right_log prl
                                   ON prl.prl_pd = pd.pd_id
                         WHERE     ap.ap_num =
                                      TO_CHAR (l_load_org)
                                   || '_'
                                   || rec_naz.lspos_nls
                               AND ROWNUM = 1;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            RAISE ex_error_ap_isnotexist;
                    END;

                    -- IC #96235 спочатку шукаємо по РНОКПП, якщо не знайдено, тоді шукаємо по полю Fam_DateR (B_Fam) або Fam_DtR (A_Fam_) порівнюємо з учасниками по полю "дата народження"
                    FOR c IN (  SELECT x_id1, x_dt1, x_string1
                                  FROM tmp_work_set1
                                 WHERE NVL (x_id1, 0) <= 0
                              ORDER BY x_string1)
                    LOOP
                        SELECT MAX (f.pdf_sc)
                          INTO l_sc_id
                          FROM uss_esr.pd_family f
                         WHERE     f.pdf_pd = l_pd_id
                               AND f.pdf_birth_dt = c.x_dt1;

                        IF l_sc_id > 0
                        THEN
                            UPDATE tmp_work_set1
                               SET x_id1 = l_sc_id
                             WHERE x_string1 = c.x_string1;
                        ELSIF c.x_id1 = -2
                        THEN
                            RAISE ex_error_sc_2;
                        ELSIF c.x_id1 = -1
                        THEN
                            RAISE ex_error_sc_1;
                        ELSE
                            RAISE ex_error_sc_else;
                        END IF;
                    END LOOP;

                    -- x_id1 - ap_person.app_sc
                    -- x_id2 - pd_family.pdf_id
                    -- x_string1 - v_ls_a_fam2_data.fam_nom
                    -- x_string2 - v_ls_a_fam2_data.fam_fio

                    UPDATE tmp_work_set1
                       SET x_id2 =
                               (SELECT MAX (pdf_id)
                                  FROM pd_family
                                 WHERE pdf_pd = l_pd_id AND pdf_sc = x_id1)
                     WHERE 1 = 1;

                    l_lock :=
                        tools.request_lock_with_timeout (
                            p_descr               => 'MIGR_API_' || l_ap_id,
                            p_error_msg           =>
                                'В данний час вже виконуються завантаження для Зверення ЕОС, спробуйте дозавантажити пізніше.',
                            p_timeout             => 13,
                            p_release_on_commit   => TRUE);
                    -- IC #85870 При міграції доходів по завантаженим рішенням очищати вже наявні доходи
                    Clear_Income (l_ap_id, l_pd_id, l_load_type);

                    FOR rec_rddm
                        IN (  SELECT dm.lfdp_id,
                                     TO_DATE (
                                            '01'
                                         || LPAD (dm.rddm_month, 2, '0')
                                         || dm.rddm_year
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'ddmmyyyy')
                                         API_MONTH,
                                       TO_NUMBER (
                                           dm.rddm_sum
                                               DEFAULT NULL ON CONVERSION ERROR)
                                     * CASE
                                           WHEN dm.rddo_pr = '0' THEN -1
                                           ELSE 1
                                       END
                                         API_SUM,
                                       CEIL (
                                             TO_NUMBER (
                                                 dm.rddm_sum
                                                     DEFAULT NULL ON CONVERSION ERROR)
                                           * CASE
                                                 WHEN dm.rddo_pr = '0' THEN -1
                                                 ELSE 1
                                             END
                                           * 100)
                                     * 0.01
                                         API_SUM_B,
                                     ROW_NUMBER ()
                                         OVER (
                                             PARTITION BY dm.rdd_numbf,
                                                          dm.rdd_npp,
                                                          dm.rddm_sum
                                             ORDER BY
                                                 dm.rddm_year || dm.rddm_month DESC)
                                         rn,
                                     NULL
                                         API_EXCH_TP,
                                     NVL (ndc.nddc_code_dest, '6')
                                         API_TP,
                                     CASE
                                         WHEN ndc.nddc_code_src = '3' THEN 'T'
                                         ELSE 'F'
                                     END
                                         API_ESV_PAI,
                                     CASE
                                         WHEN ndc.nddc_code_src = '3' THEN 'T'
                                         ELSE 'F'
                                     END
                                         API_ESV_MIN,
                                     dm.rdd_numbf,
                                     sc.x_id1
                                         sc_id,
                                     p.app_id
                                FROM uss_exch.v_ls_b_rddm_data dm
                                     INNER JOIN uss_exch.v_ls_b_rdd_data d
                                         ON     d.lspos_nls = dm.lspos_nls
                                            AND d.Naz_Op = dm.Naz_Op
                                            AND d.Naz_Dobr = dm.Naz_Dobr
                                            AND d.Rdd_NumbF = dm.Rdd_NumbF
                                            AND d.Rdd_Npp = dm.Rdd_Npp
                                     INNER JOIN tmp_work_set1 sc
                                         ON sc.x_string1 = d.rdd_numbf
                                     INNER JOIN uss_esr.ap_person p
                                         ON     p.app_ap = l_ap_id
                                            AND p.app_sc = sc.x_id1
                                     LEFT JOIN
                                     uss_ndi.v_NDI_DECODING_CONFIG ndc
                                         ON     ndc.nddc_code_src =
                                                d.rdd_aspectcd
                                            AND ndc.nddc_tp = 'API_GROUP'
                               WHERE     dm.lfd_lfd = p_lfd_lfd
                                     AND TO_NUMBER (
                                             dm.rddm_sum
                                                 DEFAULT NULL ON CONVERSION ERROR) >
                                         0
                                     AND dm.naz_op = rec_naz.naz_op
                                     AND dm.naz_dobr = rec_naz.naz_dobr
                                     AND dm.lspos_nls = rec_naz.lspos_nls
                            ORDER BY TO_NUMBER (dm.rdd_numbf), dm.lfdp_id)
                    LOOP
                        l_api_sum :=
                            CASE
                                WHEN rec_rddm.rn = 1 THEN rec_rddm.API_SUM_B
                                ELSE rec_rddm.API_SUM
                            END;

                        INSERT INTO ap_income (api_id,
                                               api_app,
                                               api_month,
                                               api_src,
                                               api_sum,
                                               api_exch_tp,
                                               api_tp,
                                               api_esv_paid,
                                               api_esv_min,
                                               api_edrpou,
                                               api_start_dt,
                                               api_stop_dt,
                                               api_use_tp)
                             VALUES (0,
                                     rec_rddm.app_id,             -- l_app_id,
                                     rec_rddm.API_MONTH,
                                     l_load_type,
                                     l_api_sum,
                                     NULL,
                                     rec_rddm.API_TP,
                                     rec_rddm.API_ESV_PAI,
                                     rec_rddm.API_ESV_MIN,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL)
                          RETURNING api_id
                               INTO l_api_id;

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_rddm.lfdp_id,
                                         l_api_id,
                                         'USS_ESR.AP_INCOME');

                        INSERT INTO pd_income_src (pis_id,
                                                   pis_src,
                                                   pis_tp,
                                                   pis_edrpou,
                                                   pis_fact_sum,
                                                   pis_final_sum,
                                                   pis_hs_rewrite,
                                                   pis_sc,
                                                   pis_esv_paid,
                                                   pis_esv_min,
                                                   pis_start_dt,
                                                   pis_stop_dt,
                                                   pis_pd,
                                                   pis_app,
                                                   pis_is_use,
                                                   pis_exch_tp)
                             VALUES (0,
                                     l_load_type,
                                     rec_rddm.API_TP,
                                     NULL,                        --pis_edrpou
                                     l_api_sum,
                                     l_api_sum,
                                     l_hs_rewrite,
                                     rec_rddm.sc_id,
                                     rec_rddm.API_ESV_PAI,
                                     rec_rddm.API_ESV_MIN,
                                     rec_rddm.API_MONTH,
                                     LAST_DAY (rec_rddm.API_MONTH),
                                     l_pd_id,
                                     rec_rddm.app_id,              --l_app_id,
                                     'T',                         --pis_is_use
                                     NULL                        --pis_exch_tp
                                         )
                          RETURNING pis_id
                               INTO l_pis_id;

                        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                       ldr_trg,
                                                       ldr_code)
                                 VALUES (rec_rddm.lfdp_id,
                                         l_pis_id,
                                         'USS_ESR.PD_INCOME_SRC');

                        -- IC #95875 Tania, 17:07 самий мінімальний та самий максимальний можемо взяти з таблиці RDDM?
                        UPDATE tmp_work_set1
                           SET x_dt1 =
                                   LEAST (NVL (x_dt1, rec_rddm.API_MONTH),
                                          rec_rddm.API_MONTH),
                               x_dt2 =
                                   GREATEST (NVL (x_dt2, rec_rddm.API_MONTH),
                                             rec_rddm.API_MONTH)
                         WHERE x_string1 = rec_rddm.rdd_numbf;
                    END LOOP;                                      -- rec_rddm

                    l_cnt_ld := l_cnt_ld + 1;

                    IF l_log_det > 0
                    THEN
                        SELECT MAX (x_id1)
                          INTO l_sc_id
                          FROM tmp_work_set1
                         WHERE x_string1 = '0';

                        WriteLineToBlob (
                            p_line   =>
                                   'Завантажено: '
                                || l_log_msg
                                || '; SC: '
                                || TO_CHAR (l_sc_id),
                            p_blob   => l_blob);
                    END IF;

                    -- IC #95875
                    -- Додати при міграції доходів (одинока мама та опіка (другої)) дозавантаження масивів
                    -- B_RddA (База середньомісячного доходу) та B_RddR (База результатів розрахунку сукупного доходу)
                    INSERT INTO uss_esr.pd_detail (pdd_pdp,
                                                   pdd_row_order,
                                                   pdd_row_name,
                                                   pdd_value,
                                                   pdd_key,
                                                   pdd_ndp,
                                                   pdd_start_dt,
                                                   pdd_stop_dt)
                          SELECT p.pdp_id,
                                 110                       row_order,
                                    'Середньомісячна сума доходів (аліменти, пенсія, допомога, стипендія) '
                                 || sc.x_string2           row_name,
                                 TO_NUMBER (a.rdda_sum)    rdda_sum,
                                 x_id2                     pdf_id,
                                 110                       pdd_ndp,
                                 sc.x_dt1                  dt_start,
                                 LAST_DAY (sc.x_dt2)       dt_stop
                            FROM uss_exch.v_ls_b_rdda_data a
                                 INNER JOIN uss_esr.pd_payment p
                                     ON p.pdp_pd = l_pd_id -- добавляємо для всіх платежів
                                 INNER JOIN uss_esr.tmp_work_set1 sc
                                     ON sc.x_string1 = a.rdda_numbf
                           WHERE     a.lfd_lfd = p_lfd_lfd
                                 AND TO_NUMBER (
                                         a.rdda_sum
                                             DEFAULT 0 ON CONVERSION ERROR) >
                                     0
                                 AND a.naz_op = rec_naz.naz_op
                                 AND a.naz_dobr = rec_naz.naz_dobr
                                 AND a.lspos_nls = rec_naz.lspos_nls
                        ORDER BY TO_NUMBER (a.rdda_numbf), a.lfdp_id;


                    FOR rddr
                        IN (  SELECT l_pd_dt,
                                     l_pc_id,
                                     l_pd_id,
                                     TO_NUMBER (
                                         r.rddr_sum
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_total_income_6m, -- (Сукупний дохід сім`ї за 6 місяців)
                                     TO_NUMBER (
                                         r.rddr_sumearth
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_plot_income_6m, -- (Сукупний дохід за 6 місяців від землі)
                                     TO_NUMBER (
                                         r.rddr_summ
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_month_income, -- (Сукупний середньомісячний дохід сім`ї)
                                     TO_NUMBER (
                                         r.rddr_fammc
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_members_number, -- (Кількість членів сім`ї)
                                     TO_NUMBER (
                                         r.rddr_sumfamm
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_member_month_income, -- (Середньомісячний дохід члена сім`ї)
                                     TO_NUMBER (
                                         r.rddr_mindox
                                             DEFAULT NULL ON CONVERSION ERROR)
                                         pic_limit      -- (Гранична величина)
                                FROM uss_exch.v_ls_b_rddr_data r
                               WHERE     r.lfd_lfd = p_lfd_lfd
                                     AND TO_NUMBER (
                                             r.rddr_sum
                                                 DEFAULT 0 ON CONVERSION ERROR) >
                                         0
                                     AND r.naz_op = rec_naz.naz_op
                                     AND r.naz_dobr = rec_naz.naz_dobr
                                     AND r.lspos_nls = rec_naz.lspos_nls
                            ORDER BY r.rn)
                    LOOP
                        -- IC #96496 при переміграції по рішенню можливе лише одне PD_INCOME_CALC
                        DELETE FROM uss_esr.pd_income_detail
                              WHERE pid_pic IN (SELECT pic_id
                                                  FROM uss_esr.pd_income_calc
                                                 WHERE pic_pd = l_pd_id);

                        DELETE FROM uss_esr.pd_income_calc
                              WHERE pic_pd = l_pd_id;

                        INSERT INTO uss_esr.pd_income_calc (
                                        pic_id,
                                        pic_dt,
                                        pic_pc,
                                        pic_pd,
                                        pic_total_income_6m,
                                        pic_plot_income_6m,
                                        pic_month_income,
                                        pic_members_number,
                                        pic_member_month_income,
                                        pic_limit)
                             VALUES (0,
                                     l_pd_dt,
                                     l_pc_id,
                                     l_pd_id,
                                     rddr.pic_total_income_6m,
                                     rddr.pic_plot_income_6m,
                                     rddr.pic_month_income,
                                     rddr.pic_members_number,
                                     rddr.pic_member_month_income,
                                     rddr.pic_limit)
                          RETURNING pic_id
                               INTO l_pic_id;

                        -- IC #96496 Додати в міграцію заповнення PD_INCOME_DETAIL
                        -- Заповнюється так само, як і PD_INCOME_SRC
                        INSERT INTO uss_esr.pd_income_detail (
                                        pid_id,
                                        pid_pic,
                                        pid_sc,
                                        pid_fact_sum,
                                        pid_app,
                                        pid_calc_sum,
                                        pid_month,
                                        pid_min_zp,
                                        pid_koef,
                                        pid_is_family_member)
                            SELECT 0                 pid_id,
                                   l_pic_id          pid_pic,
                                   pis_sc            pid_sc,
                                   pis_fact_sum      pid_fact_sum,
                                   pis_app           pid_app,
                                   pis_final_sum     pid_calc_sum,
                                   pis_start_dt      pid_month,
                                   NULL              pid_min_zp,
                                   NULL              pid_koef,
                                   'T'               pid_is_family_member
                              FROM uss_esr.pd_income_src
                             WHERE pis_pd = l_pd_id AND pis_src = l_load_type;

                        EXIT;
                    END LOOP;

                    -- фіксація по кожному НЛС
                    COMMIT;
                EXCEPTION
                    WHEN ex_error_sc_2
                    THEN
                        l_error_msg :=
                               rec_naz.lspos_nls
                            || '; Документи особи не вказано чи неможливо визначити тип документа;'
                            || 'Особа: '
                            || l_fam_nom
                            || ';';
                    WHEN ex_error_sc_1
                    THEN
                        l_error_msg :=
                               rec_naz.lspos_nls
                            || '; За вхідними документами знайдено більше однієї особи в ЄСР;'
                            || 'Особа: '
                            || l_fam_nom
                            || ';';
                    WHEN ex_error_sc_else
                    THEN
                        l_error_msg :=
                               rec_naz.lspos_nls
                            || '; Особа з вказаним ІПН паспортом або датою народження не знайдена;'
                            || 'Особа: '
                            || l_fam_nom
                            || ';';
                    WHEN ex_error_ap_isnotexist
                    THEN
                        l_error_msg :=
                               rec_naz.lspos_nls
                            || '; Рішення з номером '
                            || TO_CHAR (l_load_org)
                            || '_'
                            || rec_naz.lspos_nls
                            || ' не завантажувалося;';
                    WHEN OTHERS
                    THEN
                        l_error_msg :=
                               rec_naz.lspos_nls
                            || '; Некоректні вхідні данні;'
                            || DBMS_UTILITY.format_error_stack
                            || DBMS_UTILITY.format_error_backtrace;
                END;

                -- запись ошибки
                IF l_error_msg IS NOT NULL
                THEN
                    BEGIN                             -- если потеряли хендлер
                        tools.release_lock (p_lock_handler => l_lock);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;

                    ROLLBACK;
                    WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                    SetNlsLog (rec_naz.lfdp_id, -1, l_error_msg);
                END IF;
            END LOOP;                                               -- rec_naz
        END IF;

        IF l_flag = 1
        THEN
            NULL;
            --dbms_output.put_line(l_error_msg);
            WriteLineToBlob (p_line   => ' Завантаження завершено.',
                             p_blob   => l_blob);
            WriteLineToBlob (
                p_line   => ' Загальна кількість ОР: ' || TO_CHAR (l_cnt),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість ОР завантажено: ' || TO_CHAR (l_cnt_ld),
                p_blob   => l_blob);
        END IF;

        IF l_flag = 0
        THEN
            WriteLineToBlob (
                p_line   =>
                    NVL (l_error_msg,
                         ' Відсутні особові рахунки для завантаження'),
                p_blob   => l_blob);
        END IF;

        SELECT    SUBSTR (lfd.lfd_file_name,
                          1,
                          LENGTH (lfd.lfd_file_name) - 4)
               || '_'
               || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
          INTO l_filename
          FROM uss_exch.load_file_data lfd
         WHERE lfd.lfd_id = p_lfd_lfd;

        IF (DBMS_LOB.getlength (l_blob) > 0)
        THEN
            uss_exch.load_file_prtcl.insertprotocol (
                p_lfp_id        => l_lfp_id,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => p_lfd_lfd,
                p_lfp_tp        => NULL,
                p_lfp_name      =>
                       l_filename
                    || '(загальний протокол завантаження)'
                    || '.csv',
                p_lfp_comment   => NULL,
                p_content       => l_blob);
        END IF;
    /*
  uss_exch.load_file_prtcl.checkloadussdata(
    p_lfd_id => p_lfd_lfd,
    p_nls_list => l_blob
    );
    */
    END Load_LsPos;

    PROCEDURE Load_KlDUch (                          -- IC #88708 (06.07.2023)
                           p_lfd_lfd           NUMBER,
                           p_migration_force   NUMBER DEFAULT 0)
    IS
        l_blob          BLOB;
        --    l_load_type       varchar2(8) := 'ASOPD';
        l_error_msg     VARCHAR2 (4000);
        l_log_det       NUMBER := 0;
        l_flag          NUMBER := 0; -- флаг для проверки что есть что поданному файлу отрабатівать или нет
        l_cnt           NUMBER := 0;
        l_cnt_ld        NUMBER := 0;
        l_log_msg       VARCHAR2 (4000);
        l_filename      VARCHAR2 (128);
        l_lfp_id        NUMBER;

        l_nd_id         NUMBER;
        l_ndd_id        NUMBER;
        l_ns_id         uss_ndi.v_ndi_street.ns_id%TYPE;
        l_ndr_id        NUMBER;
        l_load_org      uss_ndi.v_ndi_decoding_config.nddc_code_dest%TYPE;

        l_list          VARCHAR2 (2048);
        l_ps            CHAR (1) := '0';

        i_ndr_tp        VARCHAR2 (10);                     -- Тип налаштування
        i_ndr_is_even   VARCHAR2 (10);     -- Ознака парності номерів будинків
        l_ndr_bld       VARCHAR2 (1024); -- Перелік або діапазон номерів будинків
        l_ndr_aprt      VARCHAR2 (1024); -- Перелік або діапазони номерів квартир
        l_bld_kv        NUMBER := 0;
        l_kld_err       NUMBER := 1;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Інформація: ',
                         p_blob   => l_blob);

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        BEGIN
            SELECT COUNT (*)
              INTO l_log_det
              FROM paramsesr
             WHERE prm_code = 'ASOPD_LOG_DET' AND prm_value = 'T';
        EXCEPTION
            WHEN OTHERS
            THEN
                l_log_det := 0;
        END;

        l_load_org := getOrgbyLFD (p_lfd_lfd);

        IF l_load_org IS NULL
        THEN
            l_error_msg := 'Помилка визначення актуального району';
        END IF;

        IF l_error_msg IS NULL
        THEN
            FOR rec_m
                IN (SELECT a.lfdp_id,
                           a.lfd_id,
                           a.lfd_lfd,
                           LPAD (a.klduch_indos, 5, '0')
                               klduch_indos,
                           a.klduch_code,
                           TO_NUMBER (a.klduch_data)
                               klduch_data,
                           a.klduch_codeul,
                           a.klduch_about,
                           o.npo_id,
                           d.nd_id,
                           dd.ndd_id,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY LPAD (a.klduch_indos, 5, '0'),
                                                a.klduch_code
                                   ORDER BY a.lfdp_id, d.nd_id)
                               rn_kld,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY LPAD (a.klduch_indos, 5, '0'),
                                                a.klduch_code,
                                                a.klduch_data
                                   ORDER BY
                                       a.lfdp_id,
                                       d.nd_id,
                                       TO_NUMBER (a.klduch_data))
                               rn_kld_dt,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY LPAD (a.klduch_indos, 5, '0'),
                                                a.klduch_code,
                                                a.klduch_data,
                                                a.klduch_codeul
                                   ORDER BY
                                       a.lfdp_id,
                                       d.nd_id,
                                       TO_NUMBER (a.klduch_data),
                                       a.klduch_codeul)
                               rn_kld_dt_ul,
                           COUNT (*) OVER ()
                               cnt
                      FROM uss_exch.v_b_klduch_a  a
                           LEFT JOIN uss_ndi.v_NDI_POST_OFFICE o
                               ON     o.npo_index =
                                      LPAD (a.klduch_indos, 5, '0')
                                  AND o.history_status = 'A'
                           LEFT JOIN uss_ndi.v_ndi_delivery d
                               ON     d.nd_npo = o.npo_id
                                  AND d.nd_code = a.klduch_code
                                  AND d.history_status = 'A'
                           LEFT JOIN uss_ndi.v_ndi_delivery_day dd
                               ON     dd.ndd_nd = d.nd_id
                                  AND dd.ndd_day = TO_NUMBER (a.klduch_data)
                                  AND dd.history_status = 'A'
                     WHERE     a.lfd_lfd = p_lfd_lfd
                           AND TO_NUMBER (
                                   a.klduch_data
                                       DEFAULT NULL ON CONVERSION ERROR)
                                   IS NOT NULL)
            LOOP
                BEGIN
                    l_cnt := l_cnt + 1;
                    l_log_msg :=
                           'IndOS №'
                        || rec_m.klduch_indos
                        || '. Запис '
                        || l_cnt
                        || ' з '
                        || rec_m.cnt;
                    SetAction (l_log_msg);

                    l_flag := 1;
                    l_error_msg := '';

                    IF rec_m.npo_id IS NULL
                    THEN
                        RAISE ex_error_no_npo_index;
                    END IF;

                    IF rec_m.rn_kld = 1
                    THEN
                        IF l_kld_err = 0
                        -- Фіксуємо попередню дільницю при успішній обробці
                        THEN
                            COMMIT;
                        END IF;

                        l_kld_err := 0; -- Обнуляємо помилки для нової дільниці
                        l_nd_id := rec_m.nd_id;

                        -- При завантаженні всі наявні налаштування по даній доставній дільниці переводимо в "H"
                        FOR rec_ndr
                            IN (SELECT ndr.ndr_id
                                  FROM uss_ndi.v_ndi_delivery      dn,
                                       uss_ndi.v_ndi_delivery_day  ndd,
                                       uss_ndi.v_ndi_delivery_ref  ndr
                                 WHERE     dn.nd_id = ndd.ndd_nd
                                       AND ndd.ndd_id = ndr.ndr_ndd
                                       AND dn.nd_id = l_nd_id)
                        LOOP
                            uss_ndi.API$DIC_DELIVERY.DELETE_DELIVERY_REF (
                                rec_ndr.ndr_id);
                        END LOOP;

                        IF l_nd_id IS NULL
                        THEN
                            uss_ndi.API$DIC_DELIVERY.SET_DELIVERY (
                                P_ND_ID        => l_nd_id,
                                P_ND_CODE      => rec_m.klduch_code,
                                P_ND_TP        => 'P',
                                P_ND_COMMENT   =>
                                       'Дільниця '
                                    || rec_m.klduch_code
                                    || ' по індексу '
                                    || rec_m.klduch_indos,
                                P_ND_NPO       => rec_m.npo_id);
                        END IF;
                    END IF;

                    IF rec_m.rn_kld_dt = 1 AND l_kld_err = 0
                    THEN
                        l_ndd_id := rec_m.ndd_id;

                        IF l_ndd_id IS NULL
                        THEN
                            uss_ndi.API$DIC_DELIVERY.SET_DELIVERY_DAY (
                                P_NDD_ID    => l_ndd_id,
                                P_NDD_ND    => l_nd_id,
                                P_NDD_DAY   => rec_m.klduch_data,
                                P_NDD_NPT   => NULL);
                        END IF;
                    END IF;

                    IF rec_m.rn_kld_dt_ul = 1 AND l_kld_err = 0
                    THEN
                        -- Шукаємо вулицю
                        SELECT MAX (a.ns_id)
                          INTO l_ns_id
                          FROM uss_ndi.v_ndi_street a
                         WHERE     ns_code = rec_m.klduch_codeul
                               AND a.ns_org = l_load_org
                               AND history_status = 'A';

                        IF l_ns_id IS NULL
                        THEN
                            RAISE ex_error_no_str_code;
                        END IF;
                    END IF;

                    -- Спроба розпарсити цю трахамудію і записати в NDI_DELIVERY_REF
                    BEGIN
                        l_error_msg := NULL;

                        DELETE FROM tmp_work_set1
                              WHERE 1 = 1;

                        FOR c
                            IN (    SELECT REGEXP_SUBSTR (a.bld,
                                                          '[^*]+',
                                                          1,
                                                          LEVEL)    str
                                      FROM (SELECT REGEXP_REPLACE (
                                                       rec_m.klduch_about,
                                                       '[ ]{1}+',
                                                       ' ')    bld
                                              FROM DUAL) a
                                     WHERE l_kld_err = 0
                                CONNECT BY LEVEL <=
                                           REGEXP_COUNT (a.bld, '\*'))
                        LOOP
                            l_list := c.str;
                            -- dbms_output.put_line(l_list);
                            l_ps := SUBSTR (l_list, 1, 1);

                            IF l_ps = '1'
                            THEN
                                i_ndr_tp := 'ALL';
                                i_ndr_is_even := NULL;
                                l_ndr_bld := NULL;
                                l_ndr_aprt := NULL;
                            ELSIF l_ps = '2'
                            THEN
                                i_ndr_tp := 'ALL';
                                i_ndr_is_even :=
                                    CASE
                                        WHEN l_list LIKE '%2Н%' THEN 'F'
                                        WHEN l_list LIKE '%2Ч%' THEN 'T'
                                        ELSE ''
                                    END;
                                l_ndr_bld := NULL;
                                l_ndr_aprt := NULL;
                            ELSIF l_ps = '3'
                            THEN
                                i_ndr_tp := 'LST';
                                i_ndr_is_even := NULL;
                                l_ndr_bld := TRIM (SUBSTR (l_list, 2));
                                l_ndr_aprt := NULL;
                            ELSIF l_ps IN ('4', '5')
                            THEN
                                i_ndr_tp := 'RNG';
                                i_ndr_is_even :=
                                    CASE
                                        WHEN l_list LIKE '%Н%' THEN 'F'
                                        WHEN l_list LIKE '%Ч%' THEN 'T'
                                        ELSE ''
                                    END;
                                l_ndr_bld :=
                                    TRIM (
                                        REGEXP_REPLACE (l_list,
                                                        '[[:alpha:]]',
                                                        ''));
                                l_ndr_bld :=
                                    REPLACE (SUBSTR (l_ndr_bld, 2), ' ', '-');
                                l_ndr_aprt := NULL;
                            ELSIF l_ps = '6'
                            THEN
                                l_list :=
                                    TRIM (
                                        SUBSTR (REPLACE (l_list, ' -', '-'),
                                                2));
                                --dbms_output.put_line('6: ' || l_list);
                                i_ndr_tp := 'LST';
                                i_ndr_is_even := NULL;
                                l_ndr_bld :=
                                    REGEXP_SUBSTR (l_list,
                                                   '[^ ]+',
                                                   1,
                                                   1);
                                l_ndr_aprt :=
                                    REGEXP_SUBSTR (l_list,
                                                   '[^ ]+',
                                                   1,
                                                   2);
                                l_bld_kv := 4;
                            ELSIF l_ps = '7'
                            THEN
                                i_ndr_tp := 'LST';
                                i_ndr_is_even := NULL;
                                l_ndr_bld :=
                                    REPLACE (TRIM (SUBSTR (l_list, 2)),
                                             ' ',
                                             'К');
                                l_ndr_aprt := NULL;
                            ELSIF l_ps = '8'
                            THEN
                                l_list :=
                                    TRIM (
                                        SUBSTR (REPLACE (l_list, ' -', '-'),
                                                2));
                                i_ndr_tp := 'LST';
                                i_ndr_is_even := NULL;
                                l_ndr_bld :=
                                       REGEXP_SUBSTR (l_list,
                                                      '[^ ]+',
                                                      1,
                                                      1)
                                    || 'К'
                                    || REGEXP_SUBSTR (l_list,
                                                      '[^ ]+',
                                                      1,
                                                      2);
                                l_ndr_aprt :=
                                    REGEXP_SUBSTR (l_list,
                                                   '[^ ]+',
                                                   1,
                                                   3);
                                l_bld_kv := 5;
                            ELSE
                                i_ndr_tp := NULL;
                                i_ndr_is_even := NULL;
                                l_ndr_bld := NULL;
                                l_ndr_aprt := NULL;
                            END IF;

                            IF l_bld_kv = 0
                            THEN
                                UPDATE tmp_work_set1
                                   SET x_string1 =
                                              x_string1
                                           || NVL2 (l_ndr_bld,
                                                    ',' || l_ndr_bld,
                                                    ''),
                                       x_string2 =
                                              x_string2
                                           || NVL2 (l_ndr_aprt,
                                                    ',' || l_ndr_aprt,
                                                    '')
                                 WHERE     x_id1 =
                                           CASE i_ndr_tp
                                               WHEN 'LST' THEN 1
                                               WHEN 'RNG' THEN 2
                                               WHEN 'ALL' THEN 3
                                               ELSE 0
                                           END
                                       AND x_id2 =
                                           CASE i_ndr_is_even
                                               WHEN 'T' THEN 1
                                               WHEN 'F' THEN 2
                                               ELSE 0
                                           END;

                                IF SQL%ROWCOUNT = 0
                                THEN
                                    INSERT INTO tmp_work_set1 (x_id1,
                                                               x_id2,
                                                               x_string1,
                                                               x_string2)
                                             VALUES (
                                                        CASE i_ndr_tp
                                                            WHEN 'LST' THEN 1
                                                            WHEN 'RNG' THEN 2
                                                            WHEN 'ALL' THEN 3
                                                            ELSE 0
                                                        END,
                                                        CASE i_ndr_is_even
                                                            WHEN 'T' THEN 1
                                                            WHEN 'F' THEN 2
                                                            ELSE 0
                                                        END,
                                                        l_ndr_bld,
                                                        l_ndr_aprt);
                                END IF;
                            ELSE
                                UPDATE tmp_work_set1
                                   SET x_string2 =
                                              x_string2
                                           || NVL2 (l_ndr_aprt,
                                                    ',' || l_ndr_aprt,
                                                    '')
                                 WHERE     x_id1 = l_bld_kv
                                       AND x_id2 = 0
                                       AND x_string1 = l_ndr_bld;

                                IF SQL%ROWCOUNT = 0
                                THEN
                                    INSERT INTO tmp_work_set1 (x_id1,
                                                               x_id2,
                                                               x_string1,
                                                               x_string2)
                                         VALUES (l_bld_kv,
                                                 0,
                                                 l_ndr_bld,
                                                 l_ndr_aprt);
                                END IF;

                                l_bld_kv := 0;
                            END IF;
                        --dbms_output.put_line('i_ndr_tp: '||i_ndr_tp);
                        --dbms_output.put_line('i_ndr_is_even: ' || i_ndr_is_even);
                        --dbms_output.put_line('l_ndr_bld: ' || l_ndr_bld);
                        --dbms_output.put_line('l_ndr_aprt: ' || l_ndr_aprt);
                        END LOOP;

                        FOR rec_ref
                            IN (SELECT CASE x_id1
                                           WHEN 1 THEN 'LST'
                                           WHEN 2 THEN 'RNG'
                                           WHEN 3 THEN 'ALL'
                                           WHEN 4 THEN 'LST'
                                           WHEN 5 THEN 'LST'
                                           ELSE NULL
                                       END          ndr_tp,
                                       CASE x_id2
                                           WHEN 1 THEN 'T'
                                           WHEN 2 THEN 'F'
                                           ELSE NULL
                                       END          ndr_is_even,
                                       x_string1    ndr_bld,
                                       x_string2    ndr_aprt
                                  FROM tmp_work_set1)
                        LOOP
                            uss_ndi.API$DIC_DELIVERY.SET_DELIVERY_REF (
                                P_NDR_ID          => l_ndr_id,
                                P_NDR_NDD         => l_ndd_id,
                                P_NDR_KAOT        => NULL,
                                P_NDR_NS          => l_ns_id,
                                P_NDR_TP          => rec_ref.ndr_tp,
                                P_NDR_IS_EVEN     => rec_ref.ndr_is_even,
                                P_NDR_BLD_LIST    => rec_ref.ndr_bld,
                                P_NDR_APRT_LIST   => rec_ref.ndr_aprt);
                        --insert into uss_exch.v_ls2uss(ldr_lfdp,ldr_trg,ldr_code) values(rec_m.lfdp_id,l_ndr_id,'USS_NDI.NDI_DELIVERY_REF');
                        END LOOP;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            l_error_msg :=
                                   rec_m.klduch_indos
                                || '; Невдала спроба розпарсити: '
                                || SUBSTR (rec_m.klduch_about, 1, 250);
                    END;

                    IF l_error_msg IS NULL
                    THEN
                        l_cnt_ld := l_cnt_ld + 1;
                    -- фіксація по кожному запису
                    END IF;
                EXCEPTION
                    WHEN ex_error_no_npo_index
                    THEN
                        l_error_msg :=
                               rec_m.klduch_indos
                            || '; Відсутній відповідний індекс в довіднику; Код: '
                            || rec_m.klduch_code;
                    WHEN ex_error_no_str_code
                    THEN
                        l_error_msg :=
                               rec_m.klduch_indos
                            || '; Відсутній відповідний код вулиці в довіднику; Код: '
                            || rec_m.klduch_codeul;
                    WHEN OTHERS
                    THEN
                        l_error_msg :=
                               rec_m.klduch_indos
                            || '; Некоректні вхідні данні;'
                            || DBMS_UTILITY.format_error_stack
                            || DBMS_UTILITY.format_error_backtrace;
                END;

                -- запись ошибки
                IF l_error_msg IS NOT NULL
                THEN
                    l_kld_err := 1;
                    ROLLBACK;
                    WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                    SetNlsLog (rec_m.lfdp_id, -1, l_error_msg);
                END IF;
            END LOOP;
        END IF;

        IF l_kld_err = 0
        THEN
            COMMIT;
        END IF;

        IF l_flag = 1
        THEN
            --dbms_output.put_line(l_error_msg);
            WriteLineToBlob (p_line   => ' Завантаження завершено.',
                             p_blob   => l_blob);
            WriteLineToBlob (
                p_line   => ' Загальна кількість записів: ' || TO_CHAR (l_cnt),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість записів завантажено: ' || TO_CHAR (l_cnt_ld),
                p_blob   => l_blob);
        END IF;

        IF l_flag = 0
        THEN
            WriteLineToBlob (
                p_line   =>
                    NVL (l_error_msg, ' Відсутні записи для завантаження'),
                p_blob   => l_blob);
        END IF;

        SELECT    SUBSTR (lfd.lfd_file_name,
                          1,
                          LENGTH (lfd.lfd_file_name) - 4)
               || '_'
               || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
          INTO l_filename
          FROM uss_exch.load_file_data lfd
         WHERE lfd.lfd_id = p_lfd_lfd;

        IF (DBMS_LOB.getlength (l_blob) > 0)
        THEN
            uss_exch.load_file_prtcl.insertprotocol (
                p_lfp_id        => l_lfp_id,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => p_lfd_lfd,
                p_lfp_tp        => NULL,
                p_lfp_name      =>
                       l_filename
                    || '(загальний протокол завантаження)'
                    || '.csv',
                p_lfp_comment   => NULL,
                p_content       => l_blob);
        END IF;
    END Load_KlDUch;

    PROCEDURE Load_Street (                          -- IC #90439 (02.08.2023)
                           p_lfd_lfd NUMBER)
    IS
        l_blob       BLOB;
        --    l_load_type       varchar2(8) := 'ASOPD';
        --    l_error_msg       varchar2(4000);
        l_cnt        NUMBER := 0;
        l_cnt_ins    NUMBER := 0;
        l_cnt_upd    NUMBER := 0;
        l_cnt_err    NUMBER := 0;
        l_log_msg    VARCHAR2 (4000);
        l_filename   VARCHAR2 (128);
        l_lfp_id     NUMBER;
        l_new_id     NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Інформація: ',
                         p_blob   => l_blob);

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR c
            IN (SELECT u.lfd_lfd,
                       u.lfdp_id,
                       LPAD (LPAD (u.klul_codern, 4, '0'), 5, '5')
                           klul_codern,
                       u.klul_codeul,
                       u.klul_name,
                       u.klul_codekul,
                       s.ns_id,
                       st.nsrt_id,
                       CASE
                           WHEN st.nsrt_code IS NULL
                           THEN
                               -1 -- Err Відсутє значення в довіднику типів вулиць
                           WHEN     NVL (u.klul_name, '-1') =
                                    NVL (s.ns_name, '-1')
                                AND NVL (u.klul_codekul, '-1') =
                                    NVL (stt.nsrt_code, -1)
                           THEN
                               0
                           WHEN s.ns_id IS NULL -- Добавляємо, інакше оновляємо
                           THEN
                               1
                           ELSE
                               2
                       END
                           is_dml,
                       ROW_NUMBER ()
                           OVER (PARTITION BY u.lfdp_id
                                 ORDER BY u.rn, s.ns_id DESC)
                           rn,
                       COUNT (DISTINCT u.lfdp_id) OVER ()
                           cnt
                  FROM uss_exch.v_b_klul  u
                       --                    left join uss_ndi.v_ndi_decoding_config c   on c.nddc_code_src = lpad(lpad(u.klul_codern,4,'0'),5,'5')
                       --                                                                    and c.nddc_tp = 'ORG_MIGR'
                       LEFT JOIN uss_ndi.v_ndi_street s
                           ON     s.ns_code = u.klul_codeul
                              AND s.ns_org =
                                  LPAD (LPAD (u.klul_codern, 4, '0'), 5, '5')
                              AND s.history_status = 'A'
                       LEFT JOIN uss_ndi.v_ndi_street_type st
                           ON st.nsrt_code = u.klul_codekul
                       LEFT JOIN uss_ndi.v_ndi_street_type stt
                           ON stt.nsrt_id = s.ns_nsrt
                 WHERE u.lfd_lfd = p_lfd_lfd)
        LOOP
            IF c.rn = 1
            THEN
                l_cnt := l_cnt + 1;

                BEGIN
                    IF c.is_dml = -1
                    THEN
                        l_cnt_err := l_cnt_err + 1;
                        WriteLineToBlob (
                            p_line   =>
                                   ' Помилка Klul_codeul: '
                                || c.klul_codeul
                                || '. Відсутнє значення в довіднику типів вулиць! Klul_codekul: '
                                || NVL (c.klul_codekul, 'null'),
                            p_blob   => l_blob);
                    END IF;

                    IF c.is_dml > 0
                    THEN
                        uss_ndi.API$DIC_DOCUMENT.set_street (
                            p_ns_id            => c.ns_id,
                            p_ns_code          => c.klul_codeul,
                            p_ns_name          => c.klul_name,
                            p_ns_kaot          => NULL,
                            p_ns_nsrt          => c.nsrt_id,
                            p_ns_org           => c.klul_codern,
                            p_history_status   => 'A',
                            p_new_id           => l_new_id);

                        IF c.is_dml = 1
                        THEN
                            l_cnt_ins := l_cnt_ins + 1;
                            DBMS_OUTPUT.put_line ('ins: ' || l_new_id);
                        ELSE
                            l_cnt_upd := l_cnt_upd + 1;
                            DBMS_OUTPUT.put_line ('upd: ' || l_new_id);
                        END IF;
                    END IF;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        ROLLBACK;
                        l_cnt_err := l_cnt_err + 1;
                        WriteLineToBlob (
                            p_line   =>
                                   ' Помилка Klul_codeul: '
                                || c.klul_codeul
                                || ' Некоректні вхідні данні; '
                                || DBMS_UTILITY.format_error_stack
                                || DBMS_UTILITY.format_error_backtrace,
                            p_blob   => l_blob);
                END;
            END IF;
        END LOOP;

        COMMIT;

        IF l_cnt > 0
        THEN
            NULL;
            --dbms_output.put_line(l_error_msg);
            WriteLineToBlob (p_line   => ' Завантаження завершено.',
                             p_blob   => l_blob);
            WriteLineToBlob (
                p_line   => ' Загальна кількість записів: ' || TO_CHAR (l_cnt),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість записів добавлено: ' || TO_CHAR (l_cnt_ins),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість записів оновлено: ' || TO_CHAR (l_cnt_upd),
                p_blob   => l_blob);
            WriteLineToBlob (
                p_line   =>
                    ' Кількість помилкових записів: ' || TO_CHAR (l_cnt_err),
                p_blob   => l_blob);
        END IF;

        IF l_cnt = 0
        THEN
            WriteLineToBlob (p_line   => ' Відсутні записи для завантаження',
                             p_blob   => l_blob);
        END IF;

        SELECT    SUBSTR (lfd.lfd_file_name,
                          1,
                          LENGTH (lfd.lfd_file_name) - 4)
               || '_'
               || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
          INTO l_filename
          FROM uss_exch.load_file_data lfd
         WHERE lfd.lfd_id = p_lfd_lfd;

        IF (DBMS_LOB.getlength (l_blob) > 0)
        THEN
            uss_exch.load_file_prtcl.insertprotocol (
                p_lfp_id        => l_lfp_id,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => p_lfd_lfd,
                p_lfp_tp        => NULL,
                p_lfp_name      =>
                       l_filename
                    || '(загальний протокол завантаження)'
                    || '.csv',
                p_lfp_comment   => NULL,
                p_content       => l_blob);
        END IF;
    END Load_Street;

    -- IC #103369
    -- Зробити процедуру для аналізу наявності діючих рішень по допомогам по особі при міграції
    FUNCTION getLastDatePayment (p_sc_id NUMBER)
        RETURN DATE
    IS
        l_last_stop_date   DATE;
    BEGIN
        SELECT MAX (pp.pdp_stop_dt)
          INTO l_last_stop_date
          FROM uss_esr.pd_family  f
               INNER JOIN uss_esr.pc_decision d ON d.pd_id = f.pdf_pd
               INNER JOIN uss_esr.pd_payment pp ON pp.pdp_pd = d.pd_id
         WHERE pp.history_status = 'A' AND f.pdf_sc = p_sc_id;

        RETURN l_last_stop_date;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END getLastDatePayment;
BEGIN
    -- Initialization
    NULL;
END LOAD$ASOPD;
/