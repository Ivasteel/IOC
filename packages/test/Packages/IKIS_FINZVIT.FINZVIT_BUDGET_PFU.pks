/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_BUDGET_PFU
IS
    -- Author  : MAXYM
    -- Created : 23.11.2018 9:53:07
    -- Purpose :

    PROCEDURE InsertBudget (p_BP_YEAR       budget_pfu.BP_YEAR%TYPE,
                            p_BP_ID     OUT budget_pfu.BP_ID%TYPE);

    PROCEDURE LockBudget (p_BP_ID   budget_pfu.BP_ID%TYPE,
                          p_BP_TS   budget_pfu.BP_TS%TYPE);

    PROCEDURE UpdateBudgetVersion (p_BP_ID budget_pfu.BP_ID%TYPE);

    PROCEDURE SetBudget2Item (p_BP2I_BP    budget_pfu2item.BP2I_BP%TYPE,
                              p_BP2I_BI    budget_pfu2item.BP2I_BI%TYPE,
                              p_BP2I_SUM   budget_pfu2item.BP2I_SUM%TYPE);

    PROCEDURE SetBudget2Item2org (
        p_BP2I_BP       budget_pfu2item.BP2I_BP%TYPE,
        p_BP2I2O_BP2I   budget_pfu2item2org.BP2I2O_BP2I%TYPE,
        p_BP2I2O_ORG    budget_pfu2item2org.BP2I2O_ORG%TYPE,
        p_BP2I2O_SUM    budget_pfu2item2org.BP2I2O_SUM%TYPE);

    PROCEDURE GetBudgetPfu (p_BP_ID                 budget_pfu.BP_ID%TYPE,
                            p_main              OUT SYS_REFCURSOR,
                            p_items             OUT SYS_REFCURSOR,
                            p_items2org         OUT SYS_REFCURSOR,
                            p_org_budget        OUT SYS_REFCURSOR,
                            p_org_budget_item   OUT SYS_REFCURSOR);

    PROCEDURE ClearEmptryBudget2Item (p_BP2I_BP budget_pfu2item.BP2I_BP%TYPE);

    PROCEDURE DeleteBudget (p_BP_ID budget_pfu.BP_ID%TYPE);

    PROCEDURE ChangeBudgetStatus (p_BP_ID       budget_pfu.BP_ID%TYPE,
                                  p_BP_STATUS   budget_pfu.BP_STATUS%TYPE,
                                  P_FILE_CODE   VARCHAR2:= NULL);

    PROCEDURE GetBudgetForSign (p_BP_ID                 budget_pfu.BP_ID%TYPE,
                                p_main              OUT SYS_REFCURSOR,
                                p_items             OUT SYS_REFCURSOR,
                                p_items2org         OUT SYS_REFCURSOR,
                                p_org_budget        OUT SYS_REFCURSOR,
                                p_org_budget_item   OUT SYS_REFCURSOR,
                                p_monthes           OUT SYS_REFCURSOR);

    PROCEDURE GetLastSignedRec (p_bp_id   IN     budget_pfu.bp_id%TYPE,
                                p_res        OUT SYS_REFCURSOR);
END FINZVIT_BUDGET_PFU;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_BUDGET_PFU TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_BUDGET_PFU
IS
    resource_busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54);

    PROCEDURE CheckCentre
    IS
    BEGIN
        IF (28000 !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в бюджет ПФУ користувачем іншого ОПФУ.');
        END IF;
    END;

    PROCEDURE SaveJournal (
        p_bpj_bp          IN budget_pfu_journal.bpj_bp%TYPE,
        p_bpj_status      IN budget_pfu_journal.bpj_status%TYPE,
        p_bpj_comment     IN budget_pfu_journal.bpj_comment%TYPE,
        p_bpj_file_code   IN budget_pfu_journal.bpj_file_code%TYPE)
    IS
        l_com_wu    NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'IKISUID'); -- Ід користувача
        l_com_org   NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'OPFU'); -- ІД організації
    BEGIN
        INSERT INTO budget_pfu_journal (bpj_bp,
                                        bpj_status,
                                        bpj_date,
                                        com_org,
                                        com_wu,
                                        bpj_file_code,
                                        bpj_comment)
             VALUES (p_bpj_bp,
                     p_bpj_status,
                     SYSDATE,
                     l_com_org,
                     l_com_wu,
                     p_bpj_file_code,
                     p_bpj_comment);
    END;

    PROCEDURE InsertBudget (p_BP_YEAR       budget_pfu.BP_YEAR%TYPE,
                            p_BP_ID     OUT budget_pfu.BP_ID%TYPE)
    IS
    BEGIN
        CheckCentre;

        INSERT INTO budget_pfu (bp_year, bp_status, bp_ts)
             VALUES (p_bp_year, 'E', 0)
          RETURNING bp_id
               INTO p_BP_ID;

        SaveJournal (p_BP_ID,
                     'E',
                     NULL,
                     NULL);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
            raise_application_error (
                -20000,
                'Бюджет за ' || p_BP_YEAR || ' вже створено');
    END;

    PROCEDURE LockBudget (p_BP_ID   budget_pfu.BP_ID%TYPE,
                          p_BP_TS   budget_pfu.BP_TS%TYPE)
    IS
        l_BP_TS   budget_pfu.BP_TS%TYPE;
    BEGIN
            SELECT BP_TS
              INTO l_BP_TS
              FROM v_budget_pfu
             WHERE bp_id = p_BP_ID
        FOR UPDATE WAIT 20;

        CheckCentre;

        IF (l_BP_TS <> p_BP_TS)
        THEN
            raise_application_error (
                -20000,
                'Об''єкт змінено. Повторіть процедуру редагування.');
        END IF;
    EXCEPTION
        WHEN resource_busy
        THEN
            raise_application_error (
                -20000,
                'Об''єкт редагується іншим користувачем.');
    END;

    PROCEDURE UpdateBudgetVersion (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
    BEGIN
        UPDATE budget_pfu
           SET bp_ts = did_budget_pfu (NULL)
         WHERE bp_id = p_BP_ID;
    END;

    PROCEDURE SetBudget2Item (p_BP2I_BP    budget_pfu2item.BP2I_BP%TYPE,
                              p_BP2I_BI    budget_pfu2item.BP2I_BI%TYPE,
                              p_BP2I_SUM   budget_pfu2item.BP2I_SUM%TYPE)
    IS
    BEGIN
        UPDATE budget_pfu2item
           SET bp2i_sum = p_bp2i_sum
         WHERE bp2i_bp = p_bp2i_bp AND bp2i_bi = p_bp2i_bi;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO budget_pfu2item (bp2i_bp, bp2i_bi, bp2i_sum)
                 VALUES (p_bp2i_bp, p_bp2i_bi, p_bp2i_sum);
        END IF;
    END;

    PROCEDURE SetBudget2Item2org (
        p_BP2I_BP       budget_pfu2item.BP2I_BP%TYPE,
        p_BP2I2O_BP2I   budget_pfu2item2org.BP2I2O_BP2I%TYPE,
        p_BP2I2O_ORG    budget_pfu2item2org.BP2I2O_ORG%TYPE,
        p_BP2I2O_SUM    budget_pfu2item2org.BP2I2O_SUM%TYPE)
    IS
        l_BP2I2O_BP2I   budget_pfu2item2org.BP2I2O_BP2I%TYPE;
    BEGIN
        -- Проверим что айтем таки принадлежит нужному бюджету а не втюхивают фигню
        SELECT BP2I_id
          INTO l_BP2I2O_BP2I
          FROM budget_pfu2item
         WHERE bp2i_bp = p_bp2i_bp AND bp2i_id = p_BP2I2O_BP2I;

        UPDATE budget_pfu2item2org
           SET bp2i2o_sum = p_bp2i2o_sum
         WHERE bp2i2o_bp2i = p_bp2i2o_bp2i AND bp2i2o_org = p_bp2i2o_org;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO budget_pfu2item2org (bp2i2o_bp2i,
                                             bp2i2o_org,
                                             bp2i2o_sum)
                 VALUES (p_bp2i2o_bp2i, p_bp2i2o_org, p_bp2i2o_sum);
        END IF;
    END;

    PROCEDURE GetBudgetPfu (p_BP_ID                 budget_pfu.BP_ID%TYPE,
                            p_main              OUT SYS_REFCURSOR,
                            p_items             OUT SYS_REFCURSOR,
                            p_items2org         OUT SYS_REFCURSOR,
                            p_org_budget        OUT SYS_REFCURSOR,
                            p_org_budget_item   OUT SYS_REFCURSOR)
    IS
        l_item_date   DATE;
    BEGIN
        SELECT TO_DATE ('01.01.' || bp_year, 'DD.MM.YYYY')
          INTO l_item_date
          FROM v_budget_pfu
         WHERE bp_id = p_BP_ID;

        OPEN p_main FOR SELECT *
                          FROM v_budget_pfu
                         WHERE bp_id = p_BP_ID;

        OPEN p_items FOR
              SELECT bi_id     AS bp2i_bi,
                     bi_name,
                     bi_group,
                     bi_type,
                     bp2i_id,
                     bp2i_bp,
                     bp2i_sum
                FROM budget_item
                     LEFT JOIN budget_pfu2item
                         ON bp2i_bp = p_BP_ID AND bp2i_bi = bi_id
               WHERE    (    (   bi_period_from <= l_item_date
                              OR bi_period_from IS NULL)
                         AND (   bi_period_to > l_item_date
                              OR bi_period_to IS NULL))
                     OR EXISTS
                            (SELECT 1
                               FROM budget_pfu2item
                              WHERE bp2i_bp = p_BP_ID AND bp2i_bi = bi_id)
            ORDER BY bi_sort;

        OPEN p_items2org FOR   SELECT *
                                 FROM budget_pfu2item2org
                                WHERE bp2i2o_bp2i IN (SELECT bp2i_id
                                                        FROM budget_pfu2item
                                                       WHERE bp2i_bp = p_BP_ID)
                             ORDER BY bp2i2o_bp2i, bp2i2o_org;

        OPEN p_org_budget FOR SELECT *
                                FROM budget_org
                               WHERE bo_bp = p_bp_id;

        OPEN p_org_budget_item FOR
            SELECT budget_org2item.*
              FROM budget_org2item JOIN budget_org ON bo2i_bo = bo_id
             WHERE bo_bp = p_bp_id;
    END;

    PROCEDURE ClearEmptryBudget2Item (p_BP2I_BP budget_pfu2item.BP2I_BP%TYPE)
    IS
    BEGIN
        DELETE FROM budget_pfu2item
              WHERE bp2i_bp = p_bp2i_bp AND bp2i_sum IS NULL;
    END;

    PROCEDURE DeleteBudget (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
    BEGIN
        CheckCentre;

        DELETE FROM budget_pfu_journal
              WHERE bpj_bp = p_bp_id;

        DELETE FROM budget_pfu2item
              WHERE bp2i_bp = p_BP_ID;

        DELETE FROM budget_pfu
              WHERE bp_id = p_BP_ID;
    END;

    PROCEDURE canChangeStatus (p_NEW_STATUS   budget_pfu.BP_STATUS%TYPE,
                               p_OLD_STATUS   budget_pfu.BP_STATUS%TYPE)
    IS
    BEGIN
        IF (p_OLD_STATUS = 'E' AND p_NEW_STATUS = 'R')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'R' AND p_NEW_STATUS = 'O')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'O' AND p_NEW_STATUS = 'F')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'F' AND p_NEW_STATUS = 'P')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'P' AND p_NEW_STATUS = 'A')
        THEN
            RETURN;
        END IF;


        raise_application_error (
            -20000,
               'Заборонено змінювати статус з '
            || p_OLD_STATUS
            || ' на '
            || p_NEW_STATUS);
    END;

    PROCEDURE GetSumByOrgs (p_bp2i_id          IN     budget_pfu2item.bp2i_id%TYPE,
                            p_sum                 OUT budget_pfu2item.bp2i_sum%TYPE,
                            p_not_null_count      OUT PLS_INTEGER)
    IS
    BEGIN
        SELECT SUM (bp2i2o_sum), COUNT (*)
          INTO p_sum, p_not_null_count
          FROM budget_pfu2item2org
         WHERE bp2i2o_bp2i = p_bp2i_id AND bp2i2o_sum IS NOT NULL;
    END;

    PROCEDURE GetChildItemsInfo (
        p_BP_ID                budget_pfu.BP_ID%TYPE,
        p_BP_DATE              DATE,
        p_parent_bi            budget_item.bi_id%TYPE,
        p_sum              OUT budget_pfu2item.bp2i_sum%TYPE,
        p_not_null_count   OUT PLS_INTEGER,
        p_null_count       OUT PLS_INTEGER)
    IS
    BEGIN
        WITH
            child_items
            AS
                (SELECT bp2i_sum,
                        DECODE (bp2i_sum, NULL, 1, 0)     null_sum,
                        DECODE (bp2i_sum, NULL, 0, 1)     not_null_sum
                   FROM budget_item
                        LEFT JOIN budget_pfu2item
                            ON bp2i_bp = p_BP_ID AND bp2i_bi = bi_id
                  WHERE     (   (    (   bi_period_from <= p_BP_DATE
                                      OR bi_period_from IS NULL)
                                 AND (   bi_period_to > p_BP_DATE
                                      OR bi_period_to IS NULL))
                             OR EXISTS
                                    (SELECT 1
                                       FROM budget_pfu2item
                                      WHERE     bp2i_bp = p_BP_ID
                                            AND bp2i_bi = bi_id))
                        AND bi_group = p_parent_bi)
        SELECT NVL (SUM (bp2i_sum), 0),
               NVL (SUM (null_sum), 0),
               NVL (SUM (not_null_sum), 0)
          INTO p_sum, p_null_count, p_not_null_count
          FROM child_items;
    END;

    PROCEDURE GetChildItemsOrgSum (
        p_BP_ID           budget_pfu.BP_ID%TYPE,
        p_parent_bi       budget_item.bi_id%TYPE,
        p_org_id          budget_pfu2item2org.bp2i2o_org%TYPE,
        p_sum         OUT budget_pfu2item.bp2i_sum%TYPE)
    IS
    BEGIN
        SELECT NVL (SUM (bp2i2o_sum), 0)
          INTO p_sum
          FROM budget_pfu2item2org
               JOIN budget_pfu2item ON bp2i2o_bp2i = bp2i_id
               JOIN budget_item ON bp2i_bi = bi_id
         WHERE     bi_group = p_parent_bi
               AND bp2i_bp = p_BP_ID
               AND bp2i2o_org = p_org_id;
    END;

    PROCEDURE CheckBudgetPhase1 (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
        l_sum              budget_pfu2item.bp2i_sum%TYPE;
        l_not_null_count   PLS_INTEGER;
        l_null_count       PLS_INTEGER;
        l_org_count        PLS_INTEGER;
        l_item_date        DATE;
    BEGIN
        SELECT TO_DATE ('01.01.' || bp_year, 'DD.MM.YYYY')
          INTO l_item_date
          FROM v_budget_pfu
         WHERE bp_id = p_BP_ID;

        SELECT COUNT (*)
          INTO l_org_count
          FROM ikis_sysweb.v$v_opfu_all
         WHERE org_org = 28000 OR org_id = 28000;

        FOR c IN (SELECT *
                    FROM budget_pfu2item JOIN BUDGET_ITEM ON bi_id = bp2i_bi
                   WHERE bp2i_bp = p_BP_ID)
        LOOP
            GetChildItemsInfo (p_BP_ID,
                               l_item_date,
                               c.bi_id,
                               l_sum,
                               l_not_null_count,
                               l_null_count);

            IF (l_sum > c.bp2i_sum)
            THEN
                /*   raise_application_error(-20000,
                p_BP_ID||'='||l_item_date||'='||c.bi_id
                                );*/

                raise_application_error (
                    -20000,
                       'Для статті "'
                    || c.bi_name
                    || '" сума граничних умов в статтях нижнього рівня '
                    || l_sum
                    || ' перевищує суму в статті '
                    || c.bp2i_sum);
            END IF;

            IF (    l_sum < c.bp2i_sum
                AND l_null_count = 0
                AND l_not_null_count > 0)
            THEN
                raise_application_error (
                    -20000,
                       'Для статті "'
                    || c.bi_name
                    || '" сума граничних умов в статтях нижнього рівня '
                    || l_sum
                    || ' не співпадає з сумою в статті '
                    || c.bp2i_sum);
            END IF;
        END LOOP;
    END;


    PROCEDURE CheckBudgetComplete (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
        l_count_A        PLS_INTEGER;
        l_common_count   PLS_INTEGER;
        l_org_count      PLS_INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_org_count
          FROM ikis_sysweb.v$v_opfu_all
         WHERE org_org = 28000 OR org_id = 28000;

        SELECT COUNT (*), SUM (a)
          INTO l_common_count, l_count_A
          FROM (SELECT DECODE (bo_status, 'A', 1, 0)     a
                  FROM budget_org
                 WHERE bo_bp = p_bp_id);

        IF (l_common_count <> l_org_count)
        THEN
            raise_application_error (
                -20000,
                   'Кількість регіональних ОПФУ '
                || l_org_count
                || ' не співпадає з кількістю регіональних бюджетів '
                || l_common_count);
        END IF;

        IF (l_common_count <> l_count_A)
        THEN
            raise_application_error (
                -20000,
                'Затверджено не всі регіональні бюджети.');
        END IF;
    END;


    PROCEDURE CheckBudget (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
        l_sum              budget_pfu2item.bp2i_sum%TYPE;
        l_org_sum          budget_pfu2item.bp2i_sum%TYPE;
        l_not_null_count   PLS_INTEGER;
        l_null_count       PLS_INTEGER;
        l_org_count        PLS_INTEGER;
        l_item_date        DATE;
    BEGIN
        SELECT TO_DATE ('01.01.' || bp_year, 'DD.MM.YYYY')
          INTO l_item_date
          FROM v_budget_pfu
         WHERE bp_id = p_BP_ID;

        SELECT COUNT (*)
          INTO l_org_count
          FROM ikis_sysweb.v$v_opfu_all
         WHERE org_org = 28000 OR org_id = 28000;

        FOR c IN (SELECT *
                    FROM budget_pfu2item JOIN BUDGET_ITEM ON bi_id = bp2i_bi
                   WHERE bp2i_bp = p_BP_ID)
        LOOP
            GetSumByOrgs (c.bp2i_id, l_sum, l_not_null_count);

            IF (c.bp2i_sum IS NULL)
            THEN
                IF (l_not_null_count > 0)
                THEN
                    raise_application_error (
                        -20000,
                           'Для статті "'
                        || c.bi_name
                        || '" не має затверджених граничних умови, але введено умови по ОПФУ.');
                END IF;
            ELSE
                IF (l_org_count <> l_not_null_count)
                THEN
                    raise_application_error (
                        -20000,
                           'Для статті "'
                        || c.bi_name
                        || '" не введено граничні умови по всіх  ОПФУ.');
                END IF;

                IF (l_sum <> c.bp2i_sum)
                THEN
                    raise_application_error (
                        -20000,
                           'Для статті "'
                        || c.bi_name
                        || '" сума затверджених граничних умов '
                        || c.bp2i_sum
                        || ' відрізняється від суми умов по ОПФУ '
                        || l_sum);
                END IF;

                GetChildItemsInfo (p_BP_ID,
                                   l_item_date,
                                   c.bi_id,
                                   l_sum,
                                   l_not_null_count,
                                   l_null_count);

                IF (l_sum > c.bp2i_sum)
                THEN
                    /*   raise_application_error(-20000,
                    p_BP_ID||'='||l_item_date||'='||c.bi_id
                                    );*/

                    raise_application_error (
                        -20000,
                           'Для статті "'
                        || c.bi_name
                        || '" сума граничних умов в статтях нижнього рівня '
                        || l_sum
                        || ' перевищує суму в статті '
                        || c.bp2i_sum);
                END IF;

                IF (    l_sum < c.bp2i_sum
                    AND l_null_count = 0
                    AND l_not_null_count > 0)
                THEN
                    raise_application_error (
                        -20000,
                           'Для статті "'
                        || c.bi_name
                        || '" сума граничних умов в статтях нижнього рівня '
                        || l_sum
                        || ' не співпадає з сумою в статті '
                        || c.bp2i_sum);
                END IF;

                FOR o
                    IN (SELECT *
                          FROM budget_pfu2item2org
                               JOIN ikis_sysweb.v$v_opfu_all
                                   ON org_id = bp2i2o_org
                         WHERE bp2i2o_bp2i = c.bp2i_id)
                LOOP
                    GetChildItemsOrgSum (p_BP_ID,
                                         c.bi_id,
                                         o.bp2i2o_org,
                                         l_org_sum);

                    IF (l_org_sum > o.bp2i2o_sum)
                    THEN
                        raise_application_error (
                            -20000,
                               'Для статті "'
                            || c.bi_name
                            || '" в ОПФУ '
                            || o.org_code
                            || ' сума граничних умов в статтях нижнього рівня '
                            || l_org_sum
                            || ' перевищує суму в статті '
                            || o.bp2i2o_sum);
                    END IF;

                    IF (    l_org_sum < o.bp2i2o_sum
                        AND l_null_count = 0
                        AND l_not_null_count > 0)
                    THEN
                        raise_application_error (
                            -20000,
                               'Для статті "'
                            || c.bi_name
                            || '" в ОПФУ '
                            || o.org_code
                            || ' сума граничних умов в статтях нижнього рівня '
                            || l_org_sum
                            || ' не співпадає з сумою в статті '
                            || o.bp2i2o_sum);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END;

    PROCEDURE CreateRegionalBudgets (p_BP_ID budget_pfu.BP_ID%TYPE)
    IS
        l_item_date   DATE;
    BEGIN
        SELECT TO_DATE ('01.01.' || bp_year, 'DD.MM.YYYY')
          INTO l_item_date
          FROM v_budget_pfu
         WHERE bp_id = p_BP_ID;

        INSERT INTO budget_org (bo_status,
                                bo_org,
                                bo_bp,
                                bo_ts)
            SELECT 'E',
                   org_id,
                   p_BP_ID,
                   0
              FROM ikis_sysweb.v$v_opfu_all
             WHERE org_org = 28000 OR org_id = 28000;

        FOR c IN (SELECT *
                    FROM budget_org
                   WHERE bo_bp = p_BP_ID)
        LOOP
            finzvit_budget_org.SaveJournal (c.bo_id,
                                            'E',
                                            NULL,
                                            NULL);

            INSERT INTO budget_org2item (bo2i_bo, bo2i_bi, bo2i_sum)
                SELECT c.bo_id, bi_id, NVL (bp2i2o_sum, 0)
                  FROM budget_item
                       LEFT JOIN budget_pfu2item
                           ON bp2i_bp = p_BP_ID AND bp2i_bi = bi_id
                       LEFT JOIN budget_pfu2item2org
                           ON bp2i2o_bp2i = bp2i_id AND bp2i2o_org = c.bo_org
                 WHERE    (    (   bi_period_from <= l_item_date
                                OR bi_period_from IS NULL)
                           AND (   bi_period_to > l_item_date
                                OR bi_period_to IS NULL))
                       OR EXISTS
                              (SELECT 1
                                 FROM budget_pfu2item
                                WHERE bp2i_bp = p_BP_ID AND bp2i_bi = bi_id);
        END LOOP;

        INSERT INTO budget_org2item2month (bo2i2m_bo2i,
                                           bo2i2m_month,
                                           bo2i2m_sum)
            SELECT bo2i_id, d, 0
              FROM budget_org2item
                   JOIN budget_org ON bo2i_bo = bo_id,
                   (SELECT ROWNUM     d
                      FROM (    SELECT ADD_MONTHS (TRUNC (SYSDATE, 'Y'),
                                                   ROWNUM - 1)    rn
                                  FROM DUAL
                            CONNECT BY LEVEL <= 12))
             WHERE bo_bp = p_bp_id;
    END;

    PROCEDURE ChangeBudgetStatus (p_BP_ID       budget_pfu.BP_ID%TYPE,
                                  p_BP_STATUS   budget_pfu.BP_STATUS%TYPE,
                                  P_FILE_CODE   VARCHAR2:= NULL)
    IS
        l_bp_old_status   budget_pfu.BP_STATUS%TYPE;
    BEGIN
        CheckCentre;

        SELECT bp_status
          INTO l_bp_old_status
          FROM budget_pfu
         WHERE bp_id = p_BP_ID;

        canChangeStatus (p_BP_STATUS, l_bp_old_status);

        IF (p_BP_STATUS = 'R')
        THEN
            CheckBudgetPhase1 (p_BP_ID);
        END IF;

        IF (p_BP_STATUS = 'O')
        THEN
            CheckBudget (p_BP_ID);
            CreateRegionalBudgets (p_BP_ID);
        END IF;

        IF (p_BP_STATUS = 'F')
        THEN
            CheckBudgetComplete (p_BP_ID);
        END IF;

        UPDATE budget_pfu
           SET bp_status = p_bp_status
         WHERE bp_id = p_BP_ID;

        SaveJournal (p_BP_ID,
                     p_BP_STATUS,
                     NULL,
                     P_FILE_CODE);
    END;

    PROCEDURE GetBudgetForSign (p_BP_ID                 budget_pfu.BP_ID%TYPE,
                                p_main              OUT SYS_REFCURSOR,
                                p_items             OUT SYS_REFCURSOR,
                                p_items2org         OUT SYS_REFCURSOR,
                                p_org_budget        OUT SYS_REFCURSOR,
                                p_org_budget_item   OUT SYS_REFCURSOR,
                                p_monthes           OUT SYS_REFCURSOR)
    IS
        l_item_date   DATE;
    BEGIN
        SELECT TO_DATE ('01.01.' || bp_year, 'DD.MM.YYYY')
          INTO l_item_date
          FROM v_budget_pfu
         WHERE bp_id = p_BP_ID;

        OPEN p_main FOR SELECT bp_id, bp_year
                          FROM v_budget_pfu
                         WHERE bp_id = p_BP_ID;

        OPEN p_items FOR   SELECT *
                             FROM budget_pfu2item
                            WHERE bp2i_bp = p_bp_id
                         ORDER BY bp2i_id;

        OPEN p_items2org FOR
              SELECT budget_pfu2item2org.*
                FROM budget_pfu2item2org
                     JOIN budget_pfu2item ON bp2i2o_bp2i = bp2i_id
               WHERE bp2i_bp = p_BP_ID
            ORDER BY bp2i2o_id;

        OPEN p_org_budget FOR   SELECT bo_id, bo_org, bo_bp
                                  FROM budget_org
                                 WHERE bo_bp = p_bp_id
                              ORDER BY bo_id;

        OPEN p_org_budget_item FOR
              SELECT budget_org2item.*
                FROM budget_org2item JOIN budget_org ON bo2i_bo = bo_id
               WHERE bo_bp = p_bp_id
            ORDER BY bo2i_id;

        OPEN p_monthes FOR
              SELECT bo2i2m_id,
                     bo2i2m_bo2i,
                     bo2i2m_month,
                     bo2i2m_sum
                FROM budget_org2item2month
                     JOIN budget_org2item ON bo2i2m_bo2i = bo2i_id
                     JOIN budget_org ON bo2i_bo = bo_id
               WHERE bo_bp = p_bp_id
            ORDER BY bo2i2m_id;
    END;

    PROCEDURE GetLastSignedRec (p_bp_id   IN     budget_pfu.bp_id%TYPE,
                                p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT *
              FROM (  SELECT z.*
                        FROM budget_pfu_journal z
                             JOIN V_budget_pfu ON bpj_bp = bp_id
                       WHERE bp_id = p_bp_id AND bpj_file_code IS NOT NULL
                    ORDER BY bpj_date DESC, bpj_id DESC);
    END;
END FINZVIT_BUDGET_PFU;
/