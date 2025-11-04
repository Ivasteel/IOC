/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_DISTRIB
IS
    -- Author  : MAXYM
    -- Created : 09.11.2017 17:26:07
    -- Purpose : Розподіл

    PROCEDURE CheckCanChangeDistribAndLock (p_dm_id       IN NUMBER,
                                            p_change_ts      NUMBER);

    PROCEDURE GetDistribId (p_dm_id       IN     distrib_main.dm_id%TYPE,
                            p_option      IN     PLS_INTEGER,
                            p_finded_dm      OUT distrib_main.dm_id%TYPE);

    PROCEDURE GetDistrib (p_dm_id          IN     distrib_main.dm_id%TYPE,
                          p_main              OUT SYS_REFCURSOR,
                          p_lines             OUT SYS_REFCURSOR,
                          p_articles          OUT SYS_REFCURSOR,
                          p_article_days      OUT SYS_REFCURSOR);

    PROCEDURE SetDistribMain (
        p_DM_ID                    distrib_main.dm_id%TYPE,
        p_DM_DM                    distrib_main.dm_dm%TYPE,
        p_DM_MONEY_GOV             distrib_main.DM_MONEY_GOV%TYPE,
        p_DM_MONEY_OWN             distrib_main.DM_MONEY_OWN%TYPE,
        p_DM_HAS_ADDITIONAL        distrib_main.DM_HAS_ADDITIONAL%TYPE,
        p_DM_PAY_DT                distrib_main.DM_PAY_DT%TYPE,
        p_DM_ST                    distrib_main.DM_ST%TYPE,
        p_DM_TP                    distrib_main.DM_TP%TYPE,
        p_DM_START_PERIOD_DT       distrib_main.DM_START_PERIOD_DT%TYPE,
        p_DM_DISTRIB_DT            distrib_main.DM_DISTRIB_DT%TYPE,
        p_change_ts                NUMBER,
        p_new_DM_ID            OUT distrib_main.dm_id%TYPE);

    PROCEDURE SetDistribLine (
        p_DL_ID           distrib_line.Dl_Id%TYPE,
        p_DL_DM           distrib_line.Dl_DM%TYPE,
        p_DL_DFA          distrib_line.Dl_DFA%TYPE,
        p_DL_MONEY_NEED   distrib_line.DL_MONEY_NEED%TYPE,
        p_DL_MONEY_GOV    distrib_line.DL_MONEY_GOV%TYPE,
        p_DL_MONEY_OWN    distrib_line.DL_MONEY_OWN%TYPE,
        p_DL_OPFU         distrib_line.DL_OPFU%TYPE);

    PROCEDURE SetDistribArticle (
        p_DA_ID              distrib_article.DA_ID%TYPE,
        p_DA_DM              distrib_article.DA_DM%TYPE,
        p_DA_DFA             distrib_article.DA_DFA%TYPE,
        p_DA_MONEY_GOV       distrib_article.DA_MONEY_GOV%TYPE,
        p_DA_MONEY_OWN       distrib_article.DA_MONEY_OWN%TYPE,
        p_NEW_DA_ID      OUT distrib_article.DA_ID%TYPE);

    PROCEDURE ClearArticleDays (p_DA_ID distrib_article.DA_ID%TYPE);

    PROCEDURE SetArticleDay (p_DAD_DA    distrib_article_day.dad_da%TYPE,
                             p_DAD_DAY   distrib_article_day.dad_day%TYPE);

    PROCEDURE DeleteDistrib (p_dm_id IN NUMBER, p_change_ts NUMBER);

    PROCEDURE GetOpfuForDistrib (p_res OUT SYS_REFCURSOR);

    PROCEDURE GetArticleMaxDay (
        p_dm_id     IN     distrib_main.dm_id%TYPE,
        p_dfa_id    IN     dic_fin_article.dfa_id%TYPE,
        p_max_day      OUT PLS_INTEGER);

    PROCEDURE GetArticleParams (p_dm_id   IN     distrib_main.dm_id%TYPE,
                                p_data       OUT SYS_REFCURSOR);

    PROCEDURE GetNeedSum (
        p_data_field            rpt_col_tp.rct_data_field%TYPE,
        p_com_org               rpt_pack.com_org%TYPE,
        p_start_period_dt       rpt_pack.rp_start_period_dt%TYPE,
        p_pt_id                 rpt_pack.rp_pt%TYPE,
        p_rft_id                rpt_frame.rf_rft%TYPE,
        p_max_day_code          VARCHAR2,
        p_all                   PLS_INTEGER,
        p_res               OUT rpt_frame_data.rd_f01%TYPE);

    PROCEDURE GetFacts (
        p_com_org               rpt_pack.com_org%TYPE,
        p_start_period_dt       rpt_pack.rp_start_period_dt%TYPE,
        p_dfa                   distrib_line.dl_dfa%TYPE,
        p_data              OUT SYS_REFCURSOR);

    -- Используется для заполнения полей при создании розподилов областного и районного уровней
    PROCEDURE GetDataForCreate (p_main           OUT SYS_REFCURSOR,
                                p_articles       OUT SYS_REFCURSOR,
                                p_article_days   OUT SYS_REFCURSOR);

    PROCEDURE FixDistribMain (p_DM_ID       distrib_main.dm_id%TYPE,
                              p_change_ts   NUMBER);

    PROCEDURE GetPayOrderParams (p_res OUT SYS_REFCURSOR);

    PROCEDURE GetDistribPayOrders (p_DM_ID       distrib_main.dm_id%TYPE,
                                   p_res     OUT SYS_REFCURSOR);

    PROCEDURE SetDistribLinePO (p_DL_ID       distrib_line.Dl_Id%TYPE,
                                p_DL_PO_GOV   distrib_line.dl_po_gov%TYPE,
                                p_DL_PO_OWN   distrib_line.dl_po_gov%TYPE);

    PROCEDURE CheckPackExist (
        p_DM_START_PERIOD_DT   IN     distrib_main.DM_START_PERIOD_DT%TYPE,
        p_is_exist                OUT NUMBER);
END FINZVIT_DISTRIB;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_DISTRIB TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_DISTRIB
IS
    PROCEDURE CheckCanChangeDistribAndLock (p_dm_id       IN NUMBER,
                                            p_change_ts      NUMBER)
    IS
        resource_busy   EXCEPTION;
        PRAGMA EXCEPTION_INIT (resource_busy, -54);
        l_row           v_distrib_main%ROWTYPE;
    BEGIN
            SELECT *
              INTO l_row
              FROM v_distrib_main
             WHERE dm_id = p_dm_id
        FOR UPDATE WAIT 30;

        IF (l_row.change_ts != NVL (p_change_ts, 0))
        THEN
            raise_application_error (
                -20000,
                'Розподіл змінено іншим шляхом, повторіть процедуру редагування наново.');
        END IF;

        IF (l_row.com_org !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в розподіл іншого ОПФУ.');
        END IF;

        IF (l_row.DM_ST != 'E')
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в розподіл, який не знаходиться в статусі "Редагується".');
        END IF;
    EXCEPTION
        WHEN resource_busy
        THEN
            raise_application_error (
                -20000,
                'Розподіл оновлюється іншим користувачем.');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000, 'Розподіл не знайдено.');
    END;

    PROCEDURE GetDistribId (p_dm_id       IN     distrib_main.dm_id%TYPE,
                            p_option      IN     PLS_INTEGER,
                            p_finded_dm      OUT distrib_main.dm_id%TYPE)
    IS
    BEGIN
        CASE p_option
            WHEN 0
            THEN
                p_finded_dm := p_dm_id;                                -- curr
            WHEN 1
            THEN
                -- last edit
                SELECT MAX (dm_id)
                  INTO p_finded_dm
                  FROM V_DISTRIB_MAIN
                 WHERE     com_org =
                           SYS_CONTEXT (ikis_finzvit_context.gContext,
                                        ikis_finzvit_context.gOPFU)
                       AND dm_st = 'E';
            WHEN 2
            THEN
                -- next
                SELECT MIN (dm_id)
                  INTO p_finded_dm
                  FROM V_DISTRIB_MAIN
                 WHERE     com_org = (SELECT com_org
                                        FROM V_DISTRIB_MAIN
                                       WHERE dm_id = p_dm_id)
                       AND dm_id > p_dm_id;
            WHEN 3
            THEN
                -- prev
                SELECT MAX (dm_id)
                  INTO p_finded_dm
                  FROM V_DISTRIB_MAIN
                 WHERE     com_org = (SELECT com_org
                                        FROM V_DISTRIB_MAIN
                                       WHERE dm_id = p_dm_id)
                       AND dm_id < p_dm_id;
        END CASE;
    END;

    PROCEDURE GetDistrib (p_dm_id          IN     distrib_main.dm_id%TYPE,
                          p_main              OUT SYS_REFCURSOR,
                          p_lines             OUT SYS_REFCURSOR,
                          p_articles          OUT SYS_REFCURSOR,
                          p_article_days      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_main FOR
            SELECT m.*,
                   --      (select count(*) from dual) HAS_PAYMENT_MANDAT,
                   EXTRACT (YEAR FROM m.DM_START_PERIOD_DT)      DM_YEAR,
                   EXTRACT (MONTH FROM m.DM_START_PERIOD_DT)     DM_MONTH,
                   EXTRACT (YEAR FROM m.DM_DISTRIB_DT)           DM_YEAR_RP,
                   EXTRACT (MONTH FROM m.DM_DISTRIB_DT)          DM_MONTH_RP
              FROM v_distrib_main m
             WHERE dm_id = p_dm_id;

        OPEN p_lines FOR
              SELECT v_distrib_line.*,
                     org_name,
                     govPo.Po_Status     po_status_gov,
                     ownPo.Po_Status     po_status_own
                FROM v_distrib_line
                     JOIN v_opfu ON dl_opfu = org_id
                     LEFT JOIN pay_order govPO ON govPo.Po_Id = dl_po_gov
                     LEFT JOIN pay_order ownPO ON ownPo.Po_Id = dl_po_own
               WHERE dl_dm = p_dm_id
            ORDER BY org_name;

        OPEN p_articles FOR SELECT *
                              FROM v_distrib_article
                             WHERE da_dm = p_dm_id;

        OPEN p_article_days FOR
            SELECT dad_da, dad_day
              FROM distrib_article_day
                   JOIN v_distrib_article ON dad_da = da_id
             WHERE da_dm = p_dm_id;
    END;

    PROCEDURE GetDataForCreate (p_main           OUT SYS_REFCURSOR,
                                p_articles       OUT SYS_REFCURSOR,
                                p_article_days   OUT SYS_REFCURSOR)
    IS
        p_org     distrib_main.com_org%TYPE
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_dm_id   NUMBER;
    BEGIN
        SELECT MIN (m.dm_id)
          INTO l_dm_id
          FROM distrib_main m
         WHERE     m.DM_ST = 'A'
               AND                                                    -- Fixed
                   m.COM_ORG = (SELECT org_org
                                  FROM v_opfu
                                 WHERE org_id = p_org)
               AND                                  -- Parent for current opfu
                   NOT EXISTS
                       (SELECT 1
                          FROM distrib_main s
                         WHERE s.COM_ORG = p_org AND s.DM_DM = m.DM_ID)
               AND                               -- Not linked to current opfu
                   EXISTS
                       (SELECT 1
                          FROM distrib_line l
                         WHERE l.dl_opfu = p_org AND l.dl_dm = m.dm_id); -- Has current opfu lines

        IF (l_dm_id IS NULL)
        THEN
            RETURN;
        END IF;

        OPEN p_main FOR
            SELECT dm_id                                         AS dm_dm,
                   s_gov                                         AS dm_money_gov,
                   s_own                                         AS dm_money_own,
                   dm_has_additional,
                   dm_pay_dt,
                   p_org                                         com_org,
                   --      null dm_st,
                   dm_tp,
                   dm_start_period_dt--     , 0 change_ts
                                     ,
                   EXTRACT (YEAR FROM m.DM_START_PERIOD_DT)      DM_YEAR,
                   EXTRACT (MONTH FROM m.DM_START_PERIOD_DT)     DM_MONTH,
                   EXTRACT (YEAR FROM m.DM_DISTRIB_DT)           DM_YEAR_RP,
                   EXTRACT (MONTH FROM m.DM_DISTRIB_DT)          DM_MONTH_RP
              FROM distrib_main  m,
                   (SELECT SUM (dl_money_gov) s_gov, SUM (dl_money_own) s_own
                      FROM distrib_line
                     WHERE dl_opfu = p_org AND dl_dm = l_dm_id) LN
             WHERE dm_id = l_dm_id;

        OPEN p_articles FOR
            SELECT da_id,
                   da_dfa,
                   LN.da_money_gov,
                   LN.da_money_own
              FROM distrib_article  a,
                   (  SELECT SUM (dl_money_gov)     da_money_gov,
                             SUM (dl_money_own)     da_money_own,
                             dl_dfa
                        FROM distrib_line
                       WHERE dl_dm = l_dm_id AND dl_opfu = p_org
                    GROUP BY dl_dfa) LN
             WHERE da_dm = l_dm_id AND LN.dl_dfa = da_dfa;

        OPEN p_article_days FOR
            SELECT dad_da, dad_day
              FROM distrib_article_day
                   JOIN v_distrib_article ON dad_da = da_id
             WHERE da_dm = l_dm_id;
    END;

    PROCEDURE FixDistribMain (p_DM_ID       distrib_main.dm_id%TYPE,
                              p_change_ts   NUMBER)
    IS
        l_gov      distrib_main.dm_money_gov%TYPE;
        l_own      distrib_main.dm_money_own%TYPE;
        l_dm_rec   distrib_main%ROWTYPE;
    BEGIN
        CheckCanChangeDistribAndLock (p_dm_id, p_change_ts);

        --- constraints

        SELECT *
          INTO l_dm_rec
          FROM distrib_main
         WHERE dm_id = p_DM_ID;

        SELECT SUM (l.dl_money_gov), SUM (l.dl_money_own)
          INTO l_gov, l_own
          FROM distrib_line l
         WHERE dl_dm = p_DM_ID;

        IF (l_dm_rec.dm_money_gov != l_gov)
        THEN
            raise_application_error (
                -20000,
                   'Сума державних коштів в строках розподілу '
                || l_gov
                || ' відрізняється від суми до розподілу '
                || l_dm_rec.dm_money_gov);
        END IF;

        IF (l_dm_rec.dm_money_own != l_own)
        THEN
            raise_application_error (
                -20000,
                   'Сума власних коштів в строках розподілу '
                || l_own
                || ' відрізняється від суми до розподілу '
                || l_dm_rec.dm_money_own);
        END IF;

        ---------------------

        UPDATE distrib_main
           SET dm_st = 'A'
         WHERE dm_id = dm_id;
    END;

    PROCEDURE SetDistribMain (
        p_DM_ID                    distrib_main.dm_id%TYPE,
        p_DM_DM                    distrib_main.dm_dm%TYPE,
        p_DM_MONEY_GOV             distrib_main.DM_MONEY_GOV%TYPE,
        p_DM_MONEY_OWN             distrib_main.DM_MONEY_OWN%TYPE,
        p_DM_HAS_ADDITIONAL        distrib_main.DM_HAS_ADDITIONAL%TYPE,
        p_DM_PAY_DT                distrib_main.DM_PAY_DT%TYPE,
        p_DM_ST                    distrib_main.DM_ST%TYPE,
        p_DM_TP                    distrib_main.DM_TP%TYPE,
        p_DM_START_PERIOD_DT       distrib_main.DM_START_PERIOD_DT%TYPE,
        p_DM_DISTRIB_DT            distrib_main.DM_DISTRIB_DT%TYPE,
        p_change_ts                NUMBER,
        p_new_DM_ID            OUT distrib_main.dm_id%TYPE)
    IS
        l_cnt   PLS_INTEGER;
        l_org   NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
    BEGIN
        IF (p_DM_ID IS NULL)
        THEN
            --- constraints

            IF (l_org != 28000)
            THEN
                IF (p_dm_dm IS NULL)
                THEN
                    raise_application_error (
                        -20000,
                        'Розподіл повинен будуватись на базі розподілу верхнього рівня.');
                END IF;

                SELECT COUNT (m.dm_id)
                  INTO l_cnt
                  FROM distrib_main m
                 WHERE     m.DM_ST = 'A'
                       AND                                            -- Fixed
                           m.COM_ORG = (SELECT org_org
                                          FROM v_opfu
                                         WHERE org_id = l_org)
                       AND                          -- Parent for current opfu
                           NOT EXISTS
                               (SELECT 1
                                  FROM distrib_main s
                                 WHERE     s.COM_ORG = l_org
                                       AND s.DM_DM = m.DM_ID)
                       AND                       -- Not linked to current opfu
                           EXISTS
                               (SELECT 1
                                  FROM distrib_line l
                                 WHERE     l.dl_opfu = l_org
                                       AND l.dl_dm = m.dm_id) -- Has current opfu lines
                       AND m.dm_id = p_dm_dm;

                IF (l_cnt = 0)
                THEN
                    raise_application_error (
                        -20000,
                        'Для базового розподілу вже створено розподіл, або базовий розподіл не відповідає поточному ОПФУ.');
                END IF;
            END IF;

            --------------------
            BEGIN
                INSERT INTO distrib_main (dm_dm,
                                          dm_money_gov,
                                          dm_money_own,
                                          dm_has_additional,
                                          dm_pay_dt,
                                          com_org,
                                          dm_st,
                                          dm_tp,
                                          dm_start_period_dt,
                                          dm_distrib_dt,
                                          change_ts)
                     VALUES (
                                p_dm_dm,
                                p_dm_money_gov,
                                p_dm_money_own,
                                p_dm_has_additional,
                                p_dm_pay_dt,
                                SYS_CONTEXT (ikis_finzvit_context.gContext,
                                             ikis_finzvit_context.gOPFU),
                                'E',
                                p_dm_tp,
                                p_dm_start_period_dt,
                                p_dm_distrib_dt,
                                FINZVIT_COMMON.GetNextChangeTs)
                  RETURNING dm_id
                       INTO p_new_DM_ID;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX
                THEN
                    IF (INSTR (SQLERRM, 'XAK_DM_UNQ') > 0)
                    THEN
                        raise_application_error (
                            -20000,
                            'Спорчатку потрібно вилучити або зафіксувати попередній розподіл.');
                    ELSE
                        RAISE;
                    END IF;
            END;
        ELSE
            CheckCanChangeDistribAndLock (p_dm_id, p_change_ts);
            p_new_DM_ID := p_dm_id;

            UPDATE distrib_main
               SET                            --dm_money_gov = p_dm_money_gov,
                                              --dm_money_own = p_dm_money_own,
                                    --dm_has_additional = v_dm_has_additional,
                                                    --dm_pay_dt = p_dm_pay_dt,
                                                       -- com_org = v_com_org,
                                                           -- dm_st = v_dm_st,
                                                           -- dm_tp = v_dm_tp,
                                 -- dm_start_period_dt = v_dm_start_period_dt,
               change_ts = FINZVIT_COMMON.GetNextChangeTs
             WHERE dm_id = p_dm_id;
        END IF;
    END;

    PROCEDURE SetDistribLine (
        p_DL_ID           distrib_line.Dl_Id%TYPE,
        p_DL_DM           distrib_line.Dl_DM%TYPE,
        p_DL_DFA          distrib_line.Dl_DFA%TYPE,
        p_DL_MONEY_NEED   distrib_line.DL_MONEY_NEED%TYPE,
        p_DL_MONEY_GOV    distrib_line.DL_MONEY_GOV%TYPE,
        p_DL_MONEY_OWN    distrib_line.DL_MONEY_OWN%TYPE,
        p_DL_OPFU         distrib_line.DL_OPFU%TYPE)
    IS
        l_po_status_gov   VARCHAR2 (10);
        l_po_status_own   VARCHAR2 (10);
        l_DL_MONEY_GOV    distrib_line.DL_MONEY_GOV%TYPE;
        l_DL_MONEY_OWN    distrib_line.DL_MONEY_OWN%TYPE;
    BEGIN
        IF (p_DL_ID IS NULL)
        THEN
            INSERT INTO distrib_line (dl_dm,
                                      dl_dfa,
                                      dl_money_need,
                                      dl_money_gov,
                                      dl_money_own,
                                      dl_opfu)
                 VALUES (p_dl_dm,
                         p_dl_dfa,
                         p_dl_money_need,
                         p_dl_money_gov,
                         p_dl_money_own,
                         p_dl_opfu);
        ELSE
            -- проверка на сохранение в строку, по которой зафиксирована платежка

            SELECT govPo.Po_Status     po_status_gov,
                   ownPo.Po_Status     po_status_own,
                   DL_MONEY_GOV,
                   DL_MONEY_OWN
              INTO l_po_status_gov,
                   l_po_status_own,
                   l_DL_MONEY_GOV,
                   l_DL_MONEY_OWN
              FROM v_distrib_line
                   LEFT JOIN pay_order govPO ON govPo.Po_Id = dl_po_gov
                   LEFT JOIN pay_order ownPO ON ownPo.Po_Id = dl_po_own
             WHERE dl_id = p_dl_id AND dl_dm = p_dl_dm;

            IF (   (    NVL (l_dl_money_gov, 0) != NVL (p_dl_money_gov, 0)
                    AND NVL (l_po_status_gov, '~') = 'A')
                OR (    NVL (l_dl_money_own, 0) != NVL (p_dl_money_own, 0)
                    AND NVL (l_po_status_own, '~') = 'A'))
            THEN
                raise_application_error (
                    -20000,
                    'Сброба зміни строки, по який є зафіксоване платіжне доручення');
            END IF;

            IF (   NVL (l_dl_money_gov, 0) != NVL (p_dl_money_gov, 0)
                OR NVL (l_dl_money_own, 0) != NVL (p_dl_money_own, 0))
            THEN
                UPDATE distrib_line
                   SET                     -- dl_money_need = p_dl_money_need,
                       dl_money_gov = p_dl_money_gov,
                       dl_money_own = p_dl_money_own
                 WHERE dl_id = p_dl_id AND dl_dm = p_dl_dm;
            END IF;
        END IF;
    END;

    PROCEDURE SetDistribArticle (
        p_DA_ID              distrib_article.DA_ID%TYPE,
        p_DA_DM              distrib_article.DA_DM%TYPE,
        p_DA_DFA             distrib_article.DA_DFA%TYPE,
        p_DA_MONEY_GOV       distrib_article.DA_MONEY_GOV%TYPE,
        p_DA_MONEY_OWN       distrib_article.DA_MONEY_OWN%TYPE,
        p_NEW_DA_ID      OUT distrib_article.DA_ID%TYPE)
    IS
    BEGIN
        IF (p_DA_ID IS NULL)
        THEN
            INSERT INTO distrib_article (da_dm,
                                         da_dfa,
                                         da_money_gov,
                                         da_money_own)
                 VALUES (p_da_dm,
                         p_da_dfa,
                         p_da_money_gov,
                         p_da_money_own)
              RETURNING da_id
                   INTO p_NEW_DA_ID;
        ELSE
            UPDATE distrib_article
               SET da_money_gov = p_da_money_gov,
                   da_money_own = p_da_money_own
             WHERE da_id = p_da_id;

            p_NEW_DA_ID := p_da_id;
        END IF;
    END;

    PROCEDURE ClearArticleDays (p_DA_ID distrib_article.DA_ID%TYPE)
    IS
    BEGIN
        DELETE distrib_article_day
         WHERE dad_da = p_da_id;
    END;

    PROCEDURE SetArticleDay (p_DAD_DA    distrib_article_day.dad_da%TYPE,
                             p_DAD_DAY   distrib_article_day.dad_day%TYPE)
    IS
    BEGIN
        INSERT INTO distrib_article_day (dad_da, dad_day)
             VALUES (p_dad_da, p_dad_day);
    END;

    PROCEDURE DeleteDistrib (p_dm_id IN NUMBER, p_change_ts NUMBER)
    IS
    BEGIN
        CheckCanChangeDistribAndLock (p_dm_id, p_change_ts);

        DELETE distrib_article_day
         WHERE dad_da IN (SELECT da_id
                            FROM distrib_article
                           WHERE da_dm = p_dm_id);

        DELETE FROM distrib_article
              WHERE da_dm = p_dm_id;

        DELETE FROM distrib_line
              WHERE dl_dm = p_dm_id;

        DELETE FROM distrib_main m
              WHERE dm_id = p_dm_id;
    END;

    PROCEDURE GetOpfuForDistrib (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT *
              FROM v_Active_opfu v
             WHERE SYS_CONTEXT (ikis_finzvit_context.gContext,
                                ikis_finzvit_context.gOPFU) IN
                       (org_id, org_org);
    END;

    PROCEDURE GetArticleMaxDay (
        p_dm_id     IN     distrib_main.dm_id%TYPE,
        p_dfa_id    IN     dic_fin_article.dfa_id%TYPE,
        p_max_day      OUT PLS_INTEGER)
    IS
        l_start_dt   distrib_main.dm_start_period_dt%TYPE;
        l_opfu       distrib_main.com_org%TYPE;
    BEGIN
        SELECT dm_start_period_dt, com_org
          INTO l_start_dt, l_opfu
          FROM distrib_main
               JOIN distrib_article da ON dm_id = da_dm AND p_dfa_id = da_dfa
         WHERE dm_id = p_dm_id;

        SELECT MAX (DAD_DAY)
          INTO p_max_day
          FROM distrib_main  dm
               JOIN distrib_article da ON dm_id = da_dm
               JOIN distrib_article_day ON dad_da = da_id
         WHERE     dm.dm_start_period_dt = l_start_dt
               AND dm.com_org = l_opfu
               AND da.da_dfa = p_dfa_id;
    --raise_application_error(-20000, 'start_dt='||l_start_dt||' opfu='||l_opfu||' res='||p_max_day );
    END;

    PROCEDURE GetArticleParams (p_dm_id   IN     distrib_main.dm_id%TYPE,
                                p_data       OUT SYS_REFCURSOR)
    IS
        l_distrib_row   v_distrib_main%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_distrib_row
          FROM v_distrib_main
         WHERE dm_id = p_dm_id;

        OPEN p_data FOR
            WITH
                colInfo
                AS
                    (SELECT c.rct_RFT       rft_id,
                            rop.r2pt_rt     RT_ID,
                            p.pt_id,
                            p.pt_ol,
                            c.rct_id,
                            c.rct_data_field
                       FROM rpt_col_tp  c
                            JOIN frames_in_rpt_template fin
                                ON fin.f2rt_rft = c.rct_rft
                            JOIN rpt_in_pack_template rop
                                ON rop.r2pt_rt = fin.f2rt_rt
                            JOIN rpt_pack_template p ON p.pt_id = rop.r2pt_pt
                      WHERE     -- p.pt_start_dt <= l_distrib_row.DM_START_PERIOD_DT  and (p.pt_end_dt >= l_distrib_row.DM_START_PERIOD_DT  or  p.pt_end_dt is null))
                                p.pt_start_dt <= l_distrib_row.DM_DISTRIB_DT
                            AND (   p.pt_end_dt >=
                                    l_distrib_row.DM_DISTRIB_DT
                                 OR p.pt_end_dt IS NULL))
            SELECT p.*,
                   c_r.rft_id               rft_id_r,
                   c_r.RT_ID                RT_ID_r,
                   c_r.pt_id                pt_id_r,
                   c_r.rct_data_field       rct_data_field_r,
                   c_c.rft_id               rft_id_c,
                   c_c.RT_ID                RT_ID_c,
                   c_c.pt_id                pt_id_c,
                   c_c.rct_data_field       rct_data_field_c,
                   c_o.rft_id               rft_id_o,
                   c_o.RT_ID                RT_ID_o,
                   c_o.pt_id                pt_id_o,
                   c_o.rct_data_field       rct_data_field_o,
                   c_o_a.rft_id             rft_id_o_a,
                   c_o_a.RT_ID              RT_ID_o_a,
                   c_o_a.pt_id              pt_id_o_a,
                   c_o_a.rct_data_field     rct_data_field_o_a,
                   f.dfa_name
              FROM DIC_FIN_ARTICLE_PARAM  p
                   JOIN DIC_FIN_ARTICLE f ON f.dfa_id = p.DFAP_DFA
                   LEFT JOIN colInfo c_r
                       ON c_r.rct_id = p.dfap_rct_r AND c_r.pt_ol = 6
                   LEFT JOIN colInfo c_c
                       ON c_c.rct_id = p.dfap_rct_c AND c_c.pt_ol = 4
                   LEFT JOIN colInfo c_o
                       ON c_o.rct_id = p.dfap_rct_o AND c_o.pt_ol = 5
                   LEFT JOIN colInfo c_o_a
                       ON c_o_a.rct_id = p.dfap_rct_o_a AND c_o_a.pt_ol = 5;
    END;

    PROCEDURE GetNeedSum (
        p_data_field            rpt_col_tp.rct_data_field%TYPE,
        p_com_org               rpt_pack.com_org%TYPE,
        p_start_period_dt       rpt_pack.rp_start_period_dt%TYPE,
        p_pt_id                 rpt_pack.rp_pt%TYPE,
        p_rft_id                rpt_frame.rf_rft%TYPE,
        p_max_day_code          VARCHAR2,
        p_all                   PLS_INTEGER,
        p_res               OUT rpt_frame_data.rd_f01%TYPE)
    IS
    BEGIN
        EXECUTE IMMEDIATE '
  declare
    l_com_org number := :p_com_org;
    l_start_period_dt date := :p_start_period_dt;
    l_pt_id  number := :p_pt_id;
    l_rft number := :p_rft;
    l_max_day_code varchar2(20) := :p_max_day_code;
    l_all pls_integer := :p_all;
    l_res rpt_frame_data.rd_f01%type;
  begin  
  select sum(' || p_data_field || ') 
   into l_res
  from
   rpt_frame_data d
   join rpt_row_tp rt on rt.rrt_id = d.rd_rrt
   join rpt_frame f on f.rf_id = d.rd_rf
   join report r on r.rpt_id = f.rf_rpt
   join Rpt_Pack p on p.rp_id = r.rpt_rp
   where p.com_org = l_com_org 
   and p.rp_start_period_dt = l_start_period_dt
   and p.rp_pt = l_pt_id
   and f.rf_rft = l_rft
   and rt.rrt_code<=l_max_day_code
   and p.rp_status = ''A''
   and (l_all=1 or p.rp_tp=''P'');
    :res := l_res;
   end;
   '
            USING p_com_org,
                  p_start_period_dt,
                  p_pt_id,
                  p_rft_id,
                  p_max_day_code,
                  p_all,
                  OUT p_res;
    END;

    PROCEDURE GetFacts (
        p_com_org               rpt_pack.com_org%TYPE,
        p_start_period_dt       rpt_pack.rp_start_period_dt%TYPE,
        p_dfa                   distrib_line.dl_dfa%TYPE,
        p_data              OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_data FOR
              SELECT l.DL_OPFU,
                     NVL (
                         SUM (
                             NVL (l.DL_MONEY_GOV, 0) + NVL (l.DL_MONEY_OWN, 0)),
                         0)    s
                FROM v_Distrib_Line l JOIN v_distrib_main m ON dl_dm = dm_id
               WHERE     m.COM_ORG = p_com_org
                     AND m.DM_START_PERIOD_DT = p_start_period_dt
                     AND l.DL_DFA = p_dfa
            GROUP BY dl_opfu;
    END;

    PROCEDURE GetPayOrderParams (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT *
              FROM v_distrib_po_setup
             WHERE src_org =
                   SYS_CONTEXT (ikis_finzvit_context.gContext,
                                ikis_finzvit_context.gOPFU);
    END;

    PROCEDURE GetDistribPayOrders (p_DM_ID       distrib_main.dm_id%TYPE,
                                   p_res     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT o.*
              FROM V_PAY_ORDER o
             WHERE o.PO_ID IN
                       (SELECT DL_PO_GOV
                          FROM V_DISTRIB_LINE
                         WHERE dl_dm = p_dm_id AND DL_PO_GOV IS NOT NULL
                        UNION ALL
                        SELECT DL_PO_OWN
                          FROM V_DISTRIB_LINE
                         WHERE dl_dm = p_dm_id AND DL_PO_OWN IS NOT NULL);
    END;

    PROCEDURE SetDistribLinePO (p_DL_ID       distrib_line.Dl_Id%TYPE,
                                p_DL_PO_GOV   distrib_line.dl_po_gov%TYPE,
                                p_DL_PO_OWN   distrib_line.dl_po_gov%TYPE)
    IS
    BEGIN
        UPDATE distrib_line
           SET dl_po_gov = p_dl_po_gov, dl_po_own = p_dl_po_own
         WHERE dl_id = p_dl_id;
    END;

    PROCEDURE CheckPackExist (
        p_DM_START_PERIOD_DT   IN     distrib_main.DM_START_PERIOD_DT%TYPE,
        p_is_exist                OUT NUMBER)
    IS
        l_org            NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        cnt_pack_exist   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO cnt_pack_exist
          FROM V_RPT_PACK rp
         WHERE     rp.RP_GR = 'N'
               AND rp.RP_START_PERIOD_DT = p_DM_START_PERIOD_DT
               AND rp.COM_ORG = l_org
               AND rp.RP_STATUS = 'A';

        IF cnt_pack_exist = 0
        THEN
            p_is_exist := 0;
        ELSE
            p_is_exist := 1;
        END IF;
    END;
END FINZVIT_DISTRIB;
/