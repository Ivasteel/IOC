/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VISIT_ACTION
IS
    -- Author  : OLEKSII
    -- Created : 19.10.2021 10:24:39
    -- Purpose : Обработка очереди на копирование из Visit в ESR

    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --  Автономная транзакция
    --==========================================
    PROCEDURE Start_Queue;

    PROCEDURE Stop_Queue;

    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE Prepare_Ap_Copy_Visit2ESR (p_ap appeal.ap_id%TYPE);

    PROCEDURE Prepare_Correct_Appeal_Copy_Visit2ESR (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE);

    PROCEDURE PrepareCopy_Visit2ESR (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE);

    PROCEDURE PrepareCopy_Visit2RNSP (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE);

    --==========================================
    --  Обработка очереди
    --  Commit;
    --==========================================
    PROCEDURE Copy_Visit2ESR;

    PROCEDURE Copy_Visit2RNSP;

    --==========================================
    --  Копирование контактів в СРКО
    --==========================================
    PROCEDURE Save_Sc_Contact (p_ap_id NUMBER);
--==========================================

END API$Visit_Action;
/


/* Formatted on 8/12/2025 5:59:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VISIT_ACTION
IS
    g_hs   histsession.hs_id%TYPE;

    --==========================================
    --  Запуск и остановка очереди через изменение параметра CE2V
    --==========================================
    PROCEDURE Start_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsvisit
           SET prm_value = '1'
         WHERE prm_code = 'CV2E';

        COMMIT;
    END;

    --==========================================
    PROCEDURE Stop_Queue
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE paramsvisit
           SET prm_value = '0'
         WHERE prm_code = 'CV2E';

        COMMIT;
    END;

    --==========================================
    --  Логирование
    --==========================================
    PROCEDURE LOG (p_VEA       VISIT2ESR_ACTIONS.VEA_ID%TYPE,
                   p_message   vea_log.veal_mesage%TYPE)
    IS
    BEGIN
        IF g_hs IS NULL
        THEN
            g_hs := TOOLS.GetHistSessionA ();
        END IF;

        INSERT INTO vea_log (veal_id,
                             veal_vea,
                             veal_hs,
                             veal_mesage)
             VALUES (0,
                     p_vea,
                     g_hs,
                     p_message);
    END;

    --==========================================
    PROCEDURE LogA (p_message vea_log.veal_mesage%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        LOG (NULL, p_message);
        COMMIT;
    END;

    --==========================================
    PROCEDURE Log_vra (p_VRA       VISIT2RNSP_ACTION.VRA_ID%TYPE,
                       p_message   vra_log.vral_message%TYPE)
    IS
    BEGIN
        IF g_hs IS NULL
        THEN
            g_hs := TOOLS.GetHistSessionA ();
        END IF;

        INSERT INTO vra_log (vral_id,
                             vral_vra,
                             vral_hs,
                             vral_message)
             VALUES (0,
                     p_vra,
                     g_hs,
                     p_message);
    END;

    --==========================================

    PROCEDURE LogA_vra (p_message vra_log.vral_message%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        Log_vra (NULL, p_message);
        COMMIT;
    END;

    --==========================================
    --#98993
    --Період призначення для звернень по послузі з Ід=664, у яких Звернення надано для подовження допомоги ВПО з 01.03.2024=так
    --==========================================
    PROCEDURE Correct_Reg_Dt_664 (p_ap appeal.ap_id%TYPE)
    IS
        l_reg_dt        DATE;
        Is_01_03_2024   VARCHAR2 (200);
        l_apd_id        NUMBER;
    BEGIN
        --7902  Реальна дата реестрації звернення
        --7412  Звернення надано для подовження допомоги ВПО з 01.03.2024

        SELECT ap_reg_dt,
               NVL (api$validation.Get_Ap_Doc_String (p_Ap, 10045, 7412),
                    'F')
          INTO l_reg_dt, Is_01_03_2024
          FROM appeal
         WHERE ap_id = p_ap;

        IF     Is_01_03_2024 = 'T'
           AND (   l_reg_dt < TO_DATE ('01.03.2024', 'dd.mm.yyyy')
                OR TRUNC (l_reg_dt, 'MM') =
                   TO_DATE ('01.04.2024', 'dd.mm.yyyy')             -- #100520
                                                       )
        THEN
            SELECT apd_id                                        --MAX(apd_id)
              INTO l_apd_id
              FROM ap_document d
             WHERE     d.apd_ap = p_ap
                   AND d.apd_ndt = 10045
                   AND d.history_status = 'A';

            UPDATE ap_document_attr a
               SET a.apda_val_dt = l_reg_dt
             WHERE     a.apda_apd = l_apd_id
                   AND a.apda_nda = 7902
                   AND a.history_status = 'A';

            IF SQL%ROWCOUNT = 0
            THEN
                INSERT INTO ap_document_attr (apda_id,
                                              apda_ap,
                                              apda_apd,
                                              apda_nda,
                                              apda_val_dt,
                                              history_status)
                     VALUES (0,
                             p_ap,
                             l_apd_id,
                             7902,
                             l_reg_dt,
                             'H');
            END IF;

            UPDATE appeal
               SET ap_reg_dt = TO_DATE ('01.03.2024', 'dd.mm.yyyy')
             WHERE ap_id = p_ap;
        END IF;
    END;

    PROCEDURE Prepare_Correct_Appeal_Copy_Visit2ESR (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE)
    IS
    BEGIN
        IF API$APPEAL.Is_Appeal_Maked_Correct (p_ap) = 0
        THEN
            PrepareCopy_Visit2ESR (p_ap, p_ST_OLD);
        END IF;
    END;

    PROCEDURE Prepare_Ap_Copy_Visit2ESR (p_ap appeal.ap_id%TYPE)
    IS
        l_Ap           Appeal%ROWTYPE;
        l_Act_Data     USS_ESR.API$FIND.cAct;
        l_At_Id        NUMBER;
        l_At_Cnt       NUMBER;
        l_Apd_Exists   BOOLEAN;
        l_Apda_Val     VARCHAR2 (500);
    BEGIN
        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE Ap_Id = p_ap;

        --#111840
        l_Apd_Exists := API$VERIFICATION_COND.Is_Apd_Exists (p_ap, '800');
        l_Apda_Val := API$APPEAL.Get_Ap_Attr_Val_Str (p_ap, 3066);

        IF     l_Ap.Ap_Src IN ('USS', 'PORTAL', 'CMES')
           AND l_Ap.Ap_Tp IN ('R.OS')
           AND l_Apd_Exists
           AND l_Apda_Val IN ('401', '409')
        THEN
            l_At_id := API$APPEAL.Get_Ap_Attr_Val_Str (p_ap, 3062);

            IF l_At_Id IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                    'Необхідно вказати Договір про надання соціальних послуг');
            END IF;

            USS_ESR.API$FIND.Get_Act_By_Id (l_At_Id, l_Act_Data);

            SELECT COUNT (1) INTO l_At_Cnt FROM TABLE (l_Act_Data);

            IF l_At_Cnt = 0
            THEN
                Raise_Application_Error (
                    -20000,
                       'Вказаний Договір про надання соціальних послуг ['
                    || l_At_Id
                    || '] не знайдено');
            END IF;

            PrepareCopy_Visit2ESR (p_ap, l_ap.ap_st);
        END IF;

        --110881
        l_Apd_Exists := API$VERIFICATION_COND.Is_Apd_Exists (p_ap, '864');
        l_Apda_Val := API$APPEAL.Get_Ap_Attr_Val_Str (p_ap, 4291);

        IF     l_Ap.Ap_Src IN ('CMES')
           AND l_Ap.Ap_Tp IN ('R.GS')
           AND l_Apd_Exists
           AND l_Apda_Val IN ('395',
                              '396',
                              '397',
                              '398',
                              '402')
        THEN
            l_At_id := API$APPEAL.Get_Ap_Attr_Val_Str (p_ap, 3062);

            IF l_At_Id IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                    'Необхідно вказати Договір про надання соціальних послуг');
            END IF;

            USS_ESR.API$FIND.Get_Act_By_Id (l_At_Id, l_Act_Data);

            SELECT COUNT (1) INTO l_At_Cnt FROM TABLE (l_Act_Data);

            IF l_At_Cnt = 0
            THEN
                Raise_Application_Error (
                    -20000,
                       'Вказаний Договір про надання соціальних послуг ['
                    || l_At_Id
                    || '] не знайдено');
            END IF;

            PrepareCopy_Visit2ESR (p_ap, l_ap.ap_st);
        END IF;
    END;

    --==========================================
    --  Постановка в очередь на копирование
    --==========================================
    PROCEDURE PrepareCopy_Visit2ESR (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE)
    IS
        l_VEA          NUMBER;
        l_log_params   VARCHAR2 (1000);
    BEGIN
        g_hs := TOOLS.GetHistSessionA ();
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            p_src              =>
                UPPER ('USS_VISIT.API$VISIT_ACTION.PrepareCopy_Visit2ESR'),
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_ap,
            p_regular_params   => NULL);

        SELECT sq_id_VISIT2ESR_ACTIONS.NEXTVAL INTO l_VEA FROM DUAL;

        INSERT INTO VISIT2ESR_ACTIONS (VEA_ID,
                                       VEA_TP,
                                       VEA_AP,
                                       VEA_ST_NEW,
                                       VEA_ST_OLD,
                                       VEA_MESSAGE,
                                       VEA_HS_INS,
                                       VEA_HS_EXEC)
            SELECT l_VEA,
                   Ap_TP,
                   Ap_Id,
                   Ap_St,
                   p_ST_OLD,
                   '',
                   g_hs,
                   -1
              FROM Appeal
             WHERE     Ap_Id = p_Ap
                   AND com_org IS NOT NULL
                   AND (   (    ap_tp IN ('U',
                                          'V',
                                          'VV',
                                          'CH_SRKO',
                                          'REG')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        OR (    ap_tp IN ('SS')
                            AND (   (    EXISTS
                                             (SELECT 1
                                                FROM ap_person sl
                                               WHERE     app_ap = ap_id
                                                     AND app_sc IS NOT NULL
                                                     AND sl.history_status =
                                                         'A')
                                     AND NOT EXISTS
                                             (SELECT 1
                                                FROM ap_person sl
                                               WHERE     app_ap = ap_id
                                                     AND app_sc IS NULL
                                                     AND sl.history_status =
                                                         'A'))
                                 OR API$APPEAL.Is_Appeal_Maked_Correct (
                                        ap_id) =
                                    0))
                        OR (    ap_tp IN ('A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND app_tp = 'O'
                                            AND sl.history_status = 'A'))
                        OR (    ap_tp IN ('IA')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        OR (    ap_tp IN ('O')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     aps_ap = ap_id
                                            AND s.aps_nst IN (23,
                                                              641,
                                                              642,
                                                              643,
                                                              645,
                                                              801,
                                                              923,
                                                              924,
                                                              1161,
                                                              1162,
                                                              1181,
                                                              1201,
                                                              1241)
                                            AND s.history_status = 'A'))
                        OR --#78825 копіювання звернення для формування друкованої форми витягу
                           (    ap_tp = 'D'
                            --             AND EXISTS (SELECT 1 FROM ap_person sl WHERE sl.app_ap = ap_id AND app_sc IS NOT NULL AND sl.history_status = 'A')
                            --             AND NOT EXISTS (SELECT 1 FROM ap_person sl WHERE sl.app_ap = ap_id AND app_sc IS NULL AND sl.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     s.aps_ap = ap_id
                                            AND s.aps_nst IN (        /*701,*/
                                                              761)
                                            AND s.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document d
                                      WHERE     d.apd_ap = ap_id
                                            AND d.apd_ndt IN (740, 741)
                                            AND d.history_status = 'A'))
                        OR --#78825 копіювання звернення для формування друкованої форми витягу
                           (    ap_tp = 'D'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     s.aps_ap = ap_id
                                            AND s.aps_nst = 981
                                            AND s.history_status = 'A'))
                        OR --#114023 копіювання звернення для формування друкованої форми витягу
                           (    ap_tp = 'D'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     s.aps_ap = ap_id
                                            AND s.aps_nst IN (61, 101)
                                            AND s.history_status = 'A'))
                        OR                                                 --#
                           (    ap_tp = 'DD'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     s.aps_ap = ap_id
                                            AND s.aps_nst = 22
                                            AND s.history_status = 'A'))
                        OR (    ap_tp = 'PP'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        --OR
                        --(ap_tp IN ('R.OS', 'R.GS')
                        -- AND ap_src not in ('USS')
                        --  AND EXISTS (SELECT 1 FROM ap_person sl WHERE sl.app_ap = ap_id AND app_sc IS NOT NULL AND sl.history_status = 'A')
                        --  AND NOT EXISTS (SELECT 1 FROM ap_person sl WHERE sl.app_ap = ap_id AND app_sc IS NULL AND sl.history_status = 'A')
                        --)
                        OR (    ap_tp IN ('R.OS')
                            AND ap_src IN ('USS')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        OR --#111840
                           (    ap_tp IN ('R.OS')
                            AND ap_src NOT IN ('USS')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document  apd
                                            JOIN ap_document_attr apda
                                                ON apd_id = apda_apd
                                      WHERE     apd_ap = ap_id
                                            AND apd_ndt = 800
                                            AND apd.history_status = 'A'
                                            AND apda_ap = ap_id
                                            AND apda_nda IN (3062, 3066)
                                            AND apda_val_string IS NOT NULL
                                            AND apda.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        OR --#111841
                           (    ap_tp IN ('R.GS')
                            AND ap_src NOT IN ('USS')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document  apd
                                            JOIN ap_document_attr apda
                                                ON apd_id = apda_apd
                                      WHERE     apd_ap = ap_id
                                            AND apd_ndt = 864
                                            AND apd.history_status = 'A'
                                            AND apda_ap = ap_id
                                            AND apda_nda IN (395,
                                                             396,
                                                             397,
                                                             398,
                                                             402)
                                            AND apda_val_string IS NOT NULL
                                            AND apda.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NOT NULL
                                            AND sl.history_status = 'A')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person sl
                                      WHERE     sl.app_ap = ap_id
                                            AND app_sc IS NULL
                                            AND sl.history_status = 'A'))
                        OR ap_sub_tp = 'SL');

        IF SQL%ROWCOUNT > 0
        THEN
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.API$VISIT_ACTION.PrepareCopy_Visit2ESR'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_ap,
                p_regular_params   => 'Registered to copy');
            Correct_Reg_Dt_664 (p_ap);
            LOG (l_vea, CHR (38) || '24#' || p_ap);
        ELSE
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.API$VISIT_ACTION.PrepareCopy_Visit2ESR'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_ap,
                p_regular_params   => 'Not registered to copy');

            SELECT    'AP_ST='
                   || ap_st
                   || ', AT_TP='
                   || ap_tp
                   || ', AP_SUB_TP='
                   || ap_sub_tp
                   || ', MARKED_CORRECT='
                   || API$APPEAL.Is_Appeal_Maked_Correct (ap_id)
                   || (SELECT    ', PERSONS='
                              || COUNT (1)
                              || ', WITH_SC='
                              || COUNT (
                                     CASE WHEN app_sc IS NOT NULL THEN 1 END)
                              || ', WITHOUT_SC='
                              || COUNT (CASE WHEN app_sc IS NULL THEN 1 END)
                         FROM ap_person
                        WHERE app_ap = ap_id)
              INTO l_log_params
              FROM appeal ap
             WHERE ap_id = p_Ap;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.API$VISIT_ACTION.PrepareCopy_Visit2ESR'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_ap,
                p_regular_params   => l_log_params);

            LOG (NULL, CHR (38) || '25#' || p_ap);
        END IF;
    --  Exception when others then
    --        log(null, sqlcode||' : '||sqlerrm);
    END;

    --==========================================
    PROCEDURE PrepareCopy_Visit2RNSP (
        p_ap       appeal.ap_id%TYPE,
        p_ST_OLD   VISIT2ESR_ACTIONS.VEA_ST_OLD%TYPE)
    IS
        l_VRA   NUMBER;
    BEGIN
        g_hs := TOOLS.GetHistSessionA ();

        SELECT sq_id_VISIT2ESR_ACTIONS.NEXTVAL INTO l_VRA FROM DUAL;

        INSERT INTO VISIT2RNSP_ACTION (VRA_id,
                                       VRA_TP,
                                       VRA_AP,
                                       VRA_ST_NEW,
                                       VRA_ST_OLD,
                                       VRA_MESSAGE,
                                       VRA_HS_INS,
                                       VRA_HS_EXEC)
            SELECT l_VRA,
                   Ap_TP,
                   Ap_Id,
                   Ap_St,
                   p_ST_OLD,
                   '',
                   g_hs,
                   -1
              FROM Appeal
             WHERE     Ap_Id = p_Ap
                   AND ap_tp = 'G'
                   AND EXISTS
                           (SELECT 1
                              FROM ap_person sl
                             WHERE app_ap = ap_id AND sl.history_status = 'A')
            UNION ALL
            --28.04.20222 LEV копіювання Витягу
            SELECT l_VRA,
                   Ap_TP,
                   Ap_Id,
                   Ap_St,
                   p_ST_OLD,
                   '',
                   g_hs,
                   -1
              FROM Appeal
             WHERE     Ap_Id = p_Ap
                   AND ap_tp = 'D'
                   AND EXISTS
                           (SELECT 1
                              FROM ap_person sl
                             WHERE app_ap = p_ap AND sl.history_status = 'A')
                   AND EXISTS
                           (SELECT 1
                              FROM ap_service s
                             WHERE s.aps_ap = p_ap AND s.aps_nst = 701);

        IF SQL%ROWCOUNT > 0
        THEN
            Log_vra (l_vra, CHR (38) || '24#' || p_ap);
        ELSE
            Log_vra (NULL, CHR (38) || '25#' || p_ap);
        END IF;
    --  Exception when others then
    --        log(null, sqlcode||' : '||sqlerrm);
    END;

    --==========================================
    PROCEDURE Save_Paramsvisit (p_cnt NUMBER, p_step NUMBER, p_err VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        MERGE INTO Paramsvisit p
             USING (SELECT 21 AS x_id, TO_CHAR (p_cnt              /*, '999'*/
                                                     ) AS x_value FROM DUAL
                    UNION ALL
                    SELECT 22 AS x_id, TO_CHAR (p_step              /*,'999'*/
                                                      ) AS x_value FROM DUAL
                    UNION ALL
                    SELECT 23 AS x_id, p_err AS x_value FROM DUAL) x
                ON (p.prm_id = x.x_id)
        WHEN MATCHED
        THEN
            UPDATE SET p.prm_value = x.x_value;

        COMMIT;
    END;

    --==========================================
    PROCEDURE Save_minus_13 (p_ap_id NUMBER)
    AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE VISIT2ESR_ACTIONS vea
           SET vea.vea_hs_exec = -13
         WHERE p_ap_id = vea.vea_ap AND vea_hs_exec = -1;

        COMMIT;
    END;

    --==========================================
    --  Копирование в ESR
    --==========================================
    PROCEDURE Copy_Visit2ESR
    IS
        CopyingAllowed   VARCHAR2 (20);
        l_Lock_Handle    Tools.t_Lockhandler;
        sqlrowcount      NUMBER;
        str              VARCHAR2 (2000);
        l_cnt            NUMBER;
        l_step           NUMBER;
        l_err            VARCHAR2 (200);
        l_ap_id          NUMBER;
    BEGIN
        l_cnt :=
            TO_NUMBER (
                tools.Get_Param_Val ('CV2E_CNT')
                    DEFAULT 100 ON CONVERSION ERROR);
        l_step :=
            TO_NUMBER (
                tools.Get_Param_Val ('CV2E_STEP')
                    DEFAULT 0 ON CONVERSION ERROR);
        l_err := tools.Get_Param_Val ('CV2E_ERR');

        IF l_err NOT IN ('T', 'F')
        THEN
            l_err := 'F';
        END IF;

        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        --Блокуэмо сутність що верифікується
        l_Lock_Handle := Tools.Request_Lock (p_Descr => 'Copy_Visit2ESR');

        SELECT NVL (MAX (prm_value), '0')
          INTO CopyingAllowed
          FROM paramsvisit
         WHERE prm_code = 'CV2E';

        IF CopyingAllowed != '1'
        THEN
            RETURN;
        END IF;

        --Збираємо звернення з черги
        INSERT INTO tmp_work_ids (x_id)
            SELECT vea_ap
              FROM (  SELECT DISTINCT vea.vea_ap
                        FROM VISIT2ESR_ACTIONS vea
                       WHERE     vea.vea_hs_exec = -1
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM ap_payment
                                       WHERE     apm_ap = vea_ap
                                             AND apm_app IS NOT NULL
                                             AND NOT EXISTS
                                                     (SELECT 1
                                                        FROM ap_person app
                                                       WHERE     app.app_ap =
                                                                 vea_ap
                                                             AND app.app_id =
                                                                 apm_app))
                    ORDER BY vea.vea_ap ASC)
             WHERE ROWNUM <= l_cnt;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount = 0
        THEN
            RETURN;
        ELSIF sqlrowcount > 0
        THEN
            --       select listagg(x_id, ',') Within GROUP(ORDER BY 1)
            --         into str
            --       from tmp_work_ids;
            IF l_cnt = 1
            THEN
                SELECT MIN (x_id) INTO l_ap_id FROM tmp_work_ids;
            END IF;

            g_hs := TOOLS.GetHistSessionA ();
            LOG (NULL, CHR (38) || '26#' || sqlrowcount);
            --запит на копіювання
            API$AP_PROCESSING.copy_appeals_to_esr_schedule (g_hs);

            --запит на копіювання
            UPDATE VISIT2ESR_ACTIONS vea
               SET vea.vea_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = vea.vea_ap)
                   AND vea_hs_exec = -1;

            LOG (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);

            IF l_err = 'F'
            THEN
                Save_Paramsvisit (100, 0, 'F');
            ELSIF l_err = 'T'
            THEN
                l_step := NVL (l_step, 0) + 1;

                IF l_step > 10
                THEN
                    Save_Paramsvisit (l_cnt, l_step, l_err);
                ELSE
                    Save_Paramsvisit (100, 0, 'F');
                END IF;
            END IF;
        END IF;

        Tools.release_lock (p_lock_handler => l_Lock_Handle);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20000
            THEN
                logA (
                       CHR (38)
                    || '28#'
                    || 'Чергу заблоковано'
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            ELSIF SQLCODE IN (-02091, -02291, -00001)
            THEN
                IF l_err = 'F'
                THEN
                    Save_Paramsvisit (10, 1, 'T');
                ELSIF l_err = 'T' AND l_cnt = 10
                THEN
                    Save_Paramsvisit (1, 0, 'T');
                ELSIF l_err = 'T' AND l_cnt = 1
                THEN
                    Save_minus_13 (l_ap_id);
                    Save_Paramsvisit (100, 0, 'F');
                END IF;

                logA (
                       CHR (38)
                    || '28#'
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace
                    || CHR (13)
                    || CHR (10)
                    || str);

                IF l_Lock_Handle IS NOT NULL
                THEN
                    Tools.release_lock (p_lock_handler => l_Lock_Handle);
                END IF;
            ELSE
                logA (
                       CHR (38)
                    || '28#'
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace
                    || CHR (13)
                    || CHR (10)
                    || str);

                IF l_Lock_Handle IS NOT NULL
                THEN
                    Tools.release_lock (p_lock_handler => l_Lock_Handle);
                END IF;
            END IF;
    END;

    --==========================================
    PROCEDURE Test_Visit2ESR
    IS
        CopyingAllowed   VARCHAR2 (20);
        l_Lock_Handle    Tools.t_Lockhandler;
        sqlrowcount      NUMBER;
        str              VARCHAR2 (2000);
        l_cnt            NUMBER;
        l_step           NUMBER;
        l_err            VARCHAR2 (200);
        -----------------------------------
        invalid          EXCEPTION;
        PRAGMA EXCEPTION_INIT (invalid, -02091);
    -----------------------------------
    BEGIN
        l_cnt :=
            TO_NUMBER (
                tools.Get_Param_Val ('CV2E_CNT')
                    DEFAULT 100 ON CONVERSION ERROR);
        l_step :=
            TO_NUMBER (
                tools.Get_Param_Val ('CV2E_STEP')
                    DEFAULT 0 ON CONVERSION ERROR);
        l_err := tools.Get_Param_Val ('CV2E_ERR');

        IF l_err NOT IN ('T', 'F')
        THEN
            l_err := 'F';
        END IF;

        --Збираємо звернення з черги
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT vea_ap
              FROM (  SELECT t.x_id1     AS vea_ap
                        FROM tmp_work_set1 t
                       WHERE t.x_id2 IS NULL
                    ORDER BY t.x_id1 ASC)
             WHERE ROWNUM <= l_cnt;

        sqlrowcount := SQL%ROWCOUNT;

        dbms_output_put_lines (
               'sqlrowcount = '
            || sqlrowcount
            || '   l_cnt = '
            || l_cnt
            || '   l_step = '
            || l_step);

        IF sqlrowcount = 0
        THEN
            RETURN;
        ELSIF sqlrowcount > 0
        THEN
            FOR e IN (SELECT x_id FROM tmp_work_ids)
            LOOP
                IF e.x_id IN (113, 500, 777)
                THEN
                    --raise_application_error(-02091, 'Test!');
                    RAISE invalid;
                END IF;
            END LOOP;

            UPDATE tmp_work_set1 t
               SET t.x_id2 = t.x_id1
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE x_id = t.x_id1);

            IF l_err = 'F'
            THEN
                Save_Paramsvisit (100, 0, 'F');
            ELSIF l_err = 'T'
            THEN
                l_step := NVL (l_step, 0) + 1;

                IF l_step > 10
                THEN
                    Save_Paramsvisit (l_cnt, l_step, l_err);
                ELSE
                    Save_Paramsvisit (100, 0, 'F');
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20000
            THEN
                logA (
                       CHR (38)
                    || '28#'
                    || 'Чергу заблоковано'
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            ELSIF SQLCODE = -02091 OR SQLCODE = -02291
            THEN
                IF l_err = 'F'
                THEN
                    Save_Paramsvisit (10, 1, 'T');
                ELSIF l_err = 'T' AND l_cnt = 10
                THEN
                    Save_Paramsvisit (1, 0, 'T');
                ELSIF l_err = 'T' AND l_cnt = 1
                THEN
                    UPDATE tmp_work_set1 t
                       SET t.x_id2 = -13, t.x_string1 = 'ERROR'
                     WHERE EXISTS
                               (SELECT 1
                                  FROM tmp_work_ids
                                 WHERE x_id = t.x_id1);

                    --                Save_Paramsvisit(100, 0, 'F');
                    Save_Paramsvisit (100, l_step, 'F');
                END IF;
            --            else
            --                   logA(chr(38)||'28#'||Dbms_Utility.Format_Error_Stack || Dbms_Utility.Format_Error_Backtrace||chr(13)||chr(10)||str);
            --                   if l_Lock_Handle is not null Then
            --                      Tools.release_lock(p_lock_handler => l_Lock_Handle);
            ELSE
                RAISE;
            END IF;
    END;

    /*
    &28#ORA-02091: transaction rolled back
    ORA-02291: integrity constraint (USS_ESR.FK_VF_VF_MAIN) violated - parent key not found
    ORA-06512: at "USS_VISIT.API$VISIT_ACTION", line 302

    39131589,39136005,39138211,39144606,39149346,39150573,39152923,39153602,39156049,39163761
    */
    --==========================================
    --  Копирование в RNSP
    --==========================================
    PROCEDURE Copy_Visit2RNSP
    IS
        CopyingAllowed   VARCHAR2 (20);
        l_Lock_Handle    Tools.t_Lockhandler;
        sqlrowcount      NUMBER;
        str              VARCHAR2 (2000);
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        --Блокуэмо сутність що верифікується
        l_Lock_Handle := Tools.Request_Lock (p_Descr => 'Copy_Visit2RNSP');

        SELECT NVL (MAX (prm_value), '0')
          INTO CopyingAllowed
          FROM paramsvisit
         WHERE prm_code = 'CV2R';

        --Log_vra(null, 'CopyingAllowed='||CopyingAllowed);
        IF CopyingAllowed != '1'
        THEN
            RETURN;
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        --Збираємо звернення з черги
        INSERT INTO tmp_work_ids (x_id)
            SELECT vra_ap
              FROM (  SELECT DISTINCT vra.vra_ap
                        FROM VISIT2RNSP_ACTION vra
                       WHERE vra.vra_tp IN ('G', 'D') AND vra.vra_hs_exec = -1
                    ORDER BY vra.vra_ap ASC)
             WHERE ROWNUM <= 1;

        sqlrowcount := SQL%ROWCOUNT;

        --    Log_vra(null, 'sqlrowcount='||sqlrowcount);

        IF sqlrowcount = 0
        THEN
            --        log(p_Ap, 'Звернення передано на обробку');
            RETURN;
        ELSIF sqlrowcount > 0
        THEN
            SELECT LISTAGG (x_id, ',') WITHIN GROUP (ORDER BY 1)
              INTO str
              FROM tmp_work_ids;

            g_hs := TOOLS.GetHistSessionA ();
            Log_vra (NULL, CHR (38) || '26#' || sqlrowcount);
            --запит на копіювання
            API$AP_PROCESSING.copy_appeals_to_rnsp_schedule (g_hs);

            --запит на копіювання
            UPDATE VISIT2RNSP_ACTION vra
               SET vra.vra_hs_exec = g_hs
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = vra.vra_ap)
                   AND vra_hs_exec = -1;

            Log_vra (NULL, CHR (38) || '27#' || SQL%ROWCOUNT);
        END IF;

        Tools.release_lock (p_lock_handler => l_Lock_Handle);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20000
            THEN
                LogA_vra (
                       CHR (38)
                    || '28#'
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
                LogA_vra (CHR (38) || '28#' || 'Чергу заблоковано');
            ELSE
                LogA_vra (
                       CHR (38)
                    || '28#'
                    || DBMS_UTILITY.Format_Error_Stack
                    || CHR (13)
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Backtrace
                    || CHR (13)
                    || CHR (10)
                    || str);

                IF l_Lock_Handle IS NOT NULL
                THEN
                    Tools.release_lock (p_lock_handler => l_Lock_Handle);
                END IF;
            END IF;
    END;

    --==========================================
    --  Копирование контактів в СРКО
    --==========================================
    PROCEDURE Save_Sc_Contact (p_ap_id NUMBER)
    IS
    BEGIN
        g_hs := TOOLS.GetHistSessionA ();

        FOR rec
            IN (SELECT app.*,
                       Api$validation.Get_Doc_String (app_id, 10232, 3684)
                           AS x_phone,
                       Api$validation.Get_Doc_String (app_id, 10232, 3683)
                           AS x_email
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_TP = 'Z'
                       AND app.history_status = 'A'
                       AND Api$validation.Get_Doc_Count (app_id, 10232) > 0
                       AND EXISTS
                               (SELECT 1
                                  FROM ap_service
                                 WHERE     aps_ap = app_ap
                                       AND aps_nst = 1001
                                       AND ap_service.history_status = 'A'))
        LOOP
            IF rec.app_sc IS NULL
            THEN
                api$appeal.Write_Log (p_ap_id,
                                      g_hs,
                                      '',
                                      'Не визначено зв''язок з СРКО');
            ELSE
                uss_person.Api$socialcard.Save_Sc_Contact (rec.app_sc,
                                                           rec.x_phone,
                                                           rec.x_email);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            api$appeal.Write_Log (
                p_ap_id,
                g_hs,
                '',
                'Помилка в Save_Sc_Contact (' || SQLERRM || ')');
    END;
END API$Visit_Action;
/