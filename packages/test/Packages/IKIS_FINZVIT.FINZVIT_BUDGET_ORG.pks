/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_BUDGET_ORG
IS
    -- Author  : MAXYM
    -- Created : 30.11.2018 10:26:56
    -- Purpose :

    PROCEDURE LockBudget (p_BO_ID   budget_pfu.BP_ID%TYPE,
                          p_BO_TS   budget_pfu.BP_TS%TYPE);

    PROCEDURE LockBudgetCenter (p_BO_ID   budget_pfu.BP_ID%TYPE,
                                p_BO_TS   budget_pfu.BP_TS%TYPE);


    PROCEDURE GetBudget (p_BO_ID             budget_pfu.BP_ID%TYPE,
                         p_main          OUT SYS_REFCURSOR,
                         p_items         OUT SYS_REFCURSOR,
                         p_monthes       OUT SYS_REFCURSOR,
                         p_constraints   OUT SYS_REFCURSOR);

    PROCEDURE UpdateItem (p_BO2I_ID    budget_org2item.BO2I_ID%TYPE,
                          p_BO_ID      budget_org2item.BO2I_BO%TYPE,
                          p_BO2I_SUM   budget_org2item.BO2I_SUM%TYPE);

    PROCEDURE UpdateItemMonth (
        p_BO2I2M_ID    budget_org2item2month.BO2I2M_ID%TYPE,
        p_BO_ID        budget_org2item.BO2I_BO%TYPE,
        p_BO2I2M_SUM   budget_org2item2month.BO2I2M_SUM%TYPE);

    PROCEDURE UpdateBudgetVersion (p_BO_ID budget_org.BO_ID%TYPE);

    PROCEDURE ChangeBudgetStatus (p_BO_ID       budget_org.BO_ID%TYPE,
                                  p_BO_STATUS   budget_org.BO_STATUS%TYPE,
                                  P_FILE_CODE   VARCHAR2:= NULL);

    PROCEDURE SaveJournal (
        p_boj_bo          IN budget_org_journal.boj_bo%TYPE,
        p_boj_status      IN budget_org_journal.boj_status%TYPE,
        p_boj_comment     IN budget_org_journal.boj_comment%TYPE,
        p_boj_file_code   IN budget_org_journal.boj_file_code%TYPE);

    PROCEDURE GetBudgetForSign (p_BO_ID         budget_pfu.BP_ID%TYPE,
                                p_main      OUT SYS_REFCURSOR,
                                p_items     OUT SYS_REFCURSOR,
                                p_monthes   OUT SYS_REFCURSOR);

    PROCEDURE GetLastSignedRec (p_bo_id   IN     budget_org.bo_id%TYPE,
                                p_res        OUT SYS_REFCURSOR);
END FINZVIT_BUDGET_ORG;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_BUDGET_ORG TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_BUDGET_ORG
IS
    resource_busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54);

    PROCEDURE SaveJournal (
        p_boj_bo          IN budget_org_journal.boj_bo%TYPE,
        p_boj_status      IN budget_org_journal.boj_status%TYPE,
        p_boj_comment     IN budget_org_journal.boj_comment%TYPE,
        p_boj_file_code   IN budget_org_journal.boj_file_code%TYPE)
    IS
        l_com_wu    NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'IKISUID'); -- Ід користувача
        l_com_org   NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'OPFU'); -- ІД організації
    BEGIN
        INSERT INTO budget_org_journal (boj_bo,
                                        boj_status,
                                        boj_date,
                                        com_org,
                                        com_wu,
                                        boj_file_code,
                                        boj_comment)
             VALUES (p_boj_bo,
                     p_boj_status,
                     SYSDATE,
                     l_com_org,
                     l_com_wu,
                     p_boj_file_code,
                     p_boj_comment);
    END;

    PROCEDURE LockBudget (p_BO_ID   budget_pfu.BP_ID%TYPE,
                          p_BO_TS   budget_pfu.BP_TS%TYPE)
    IS
        l_BO_TS    budget_org.BO_TS%TYPE;
        l_BO_ORG   budget_org.BO_ORG%TYPE;
    BEGIN
            SELECT BO_TS, BO_ORG
              INTO l_BO_TS, l_BO_ORG
              FROM v_budget_org
             WHERE bo_id = p_BO_ID
        FOR UPDATE WAIT 20;

        IF (l_BO_ORG !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в бюджет користувачем іншого ОПФУ.');
        END IF;

        IF (l_BO_TS <> p_BO_TS)
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

    PROCEDURE LockBudgetCenter (p_BO_ID   budget_pfu.BP_ID%TYPE,
                                p_BO_TS   budget_pfu.BP_TS%TYPE)
    IS
        l_BO_TS    budget_org.BO_TS%TYPE;
        l_BO_ORG   budget_org.BO_ORG%TYPE;
    BEGIN
            SELECT BO_TS, BO_ORG
              INTO l_BO_TS, l_BO_ORG
              FROM v_budget_org
             WHERE bo_id = p_BO_ID
        FOR UPDATE WAIT 20;

        IF (28000 !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (-20000,
                                     'Користувач повинен належати ГУ ПФУ.');
        END IF;

        IF (l_BO_TS <> p_BO_TS)
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



    PROCEDURE GetBudget (p_BO_ID             budget_pfu.BP_ID%TYPE,
                         p_main          OUT SYS_REFCURSOR,
                         p_items         OUT SYS_REFCURSOR,
                         p_monthes       OUT SYS_REFCURSOR,
                         p_constraints   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_main FOR SELECT *
                          FROM V_BUDGET_ORG JOIN budget_pfu ON bo_bp = bp_id
                         WHERE bo_id = p_bo_id;

        OPEN p_items FOR
              SELECT *
                FROM budget_org2item JOIN budget_item ON bo2i_bi = bi_id
               WHERE bo2i_bo = p_bo_id
            ORDER BY bi_sort;

        OPEN p_monthes FOR
              SELECT bo2i2m_id,
                     bo2i2m_bo2i,
                     bo2i2m_month,
                     bo2i2m_sum
                FROM budget_org2item2month
                     JOIN budget_org2item ON bo2i2m_bo2i = bo2i_id
               WHERE bo2i_bo = p_bo_id
            ORDER BY bo2i2m_bo2i, bo2i2m_month;

        OPEN p_constraints FOR
            SELECT bp2i_bi, bp2i2o_sum
              FROM budget_pfu2item2org
                   JOIN budget_pfu2item ON bp2i2o_bp2i = bp2i_id
                   JOIN V_BUDGET_ORG ON bp2i_bp = bo_bp
             WHERE     bo_id = p_bo_id
                   AND bp2i2o_org = bo_org
                   AND bp2i2o_sum IS NOT NULL;
    END;

    PROCEDURE UpdateItem (p_BO2I_ID    budget_org2item.BO2I_ID%TYPE,
                          p_BO_ID      budget_org2item.BO2I_BO%TYPE,
                          p_BO2I_SUM   budget_org2item.BO2I_SUM%TYPE)
    IS
    BEGIN
        UPDATE budget_org2item
           SET bo2i_sum = p_bo2i_sum
         WHERE bo2i_id = p_bo2i_id AND bo2i_bo = p_bo_id;
    END;

    PROCEDURE UpdateItemMonth (
        p_BO2I2M_ID    budget_org2item2month.BO2I2M_ID%TYPE,
        p_BO_ID        budget_org2item.BO2I_BO%TYPE,
        p_BO2I2M_SUM   budget_org2item2month.BO2I2M_SUM%TYPE)
    IS
    BEGIN
        UPDATE budget_org2item2month
           SET bo2i2m_sum = p_bo2i2m_sum
         WHERE     bo2i2m_id = p_bo2i2m_id
               AND bo2i2m_bo2i IN (SELECT bo2i_id
                                     FROM budget_org2item
                                    WHERE bo2i_bo = p_bo_id);
    END;

    PROCEDURE UpdateBudgetVersion (p_BO_ID budget_org.BO_ID%TYPE)
    IS
    BEGIN
        UPDATE budget_org
           SET bo_ts = did_budget_org (NULL)
         WHERE bo_id = p_BO_ID;
    END;

    PROCEDURE canChangeStatus (p_NEW_STATUS   budget_org.BO_STATUS%TYPE,
                               p_OLD_STATUS   budget_org.BO_STATUS%TYPE)
    IS
    BEGIN
        IF (p_OLD_STATUS = 'E' AND p_NEW_STATUS = 'C')
        THEN
            RETURN;
        END IF;

        IF (    p_OLD_STATUS IN ('C',
                                 'P',
                                 'W',
                                 'B')
            AND p_NEW_STATUS = 'E')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'C' AND p_NEW_STATUS = 'W')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'W' AND p_NEW_STATUS = 'P')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'P' AND p_NEW_STATUS = 'S')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'S' AND p_NEW_STATUS = 'B')
        THEN
            RETURN;
        END IF;

        IF (p_OLD_STATUS = 'S' AND p_NEW_STATUS = 'A')
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

    FUNCTION getBiName (p_bi_id budget_item.bi_id%TYPE)
        RETURN VARCHAR2
    IS
        l_res   budget_item.bi_name%TYPE;
    BEGIN
        SELECT bi_name
          INTO l_res
          FROM budget_item
         WHERE bi_id = p_bi_id;

        RETURN l_res;
    END;

    PROCEDURE CheckBudget (p_BO_ID budget_org.BO_ID%TYPE)
    IS
        l_bp_id    budget_pfu.bp_id%TYPE;
        l_org_id   budget_org.bo_org%TYPE;
        l_bad_id   NUMBER;
        l_sum      budget_org2item.bo2i_sum%TYPE;
        l_count    PLS_INTEGER;
    BEGIN
        SELECT bo_bp, bo_org
          INTO l_bp_id, l_org_id
          FROM v_budget_org
         WHERE bo_id = p_bo_id;

        -----------
        SELECT MIN (o.bo2i_bi)
          INTO l_bad_id
          FROM budget_org2item o
         WHERE bo2i_bo = p_bo_id AND o.bo2i_sum IS NULL;

        IF (l_bad_id IS NOT NULL)
        THEN
            raise_application_error (
                -20000,
                'Для статі "' || getBiName (l_bad_id) || '" не введено суму.');
        END IF;

        ---------
        SELECT MIN (o.bo2i_bi)
          INTO l_bad_id
          FROM budget_org2item o, budget_org2item2month m
         WHERE     bo2i_bo = p_bo_id
               AND m.bo2i2m_bo2i = o.bo2i_id
               AND m.bo2i2m_sum IS NULL;

        IF (l_bad_id IS NOT NULL)
        THEN
            raise_application_error (
                -20000,
                   'Для статі "'
                || getBiName (l_bad_id)
                || '" не введено суму по всіх місяцях.');
        END IF;

        ---------
        SELECT MIN (o.bo2i_bi)
          INTO l_bad_id
          FROM budget_org2item o
         WHERE     bo2i_bo = p_bo_id
               AND EXISTS
                       (SELECT 1
                          FROM budget_pfu2item2org  z
                               JOIN budget_pfu2item k
                                   ON z.bp2i2o_bp2i = k.bp2i_id
                         WHERE     k.bp2i_bp = l_bp_id
                               AND k.bp2i_bi = o.bo2i_bi
                               AND z.bp2i2o_org = l_org_id
                               AND z.bp2i2o_sum IS NOT NULL
                               AND z.bp2i2o_sum <> o.bo2i_sum);

        IF (l_bad_id IS NOT NULL)
        THEN
            raise_application_error (
                -20000,
                   'Сума в статі "'
                || getBiName (l_bad_id)
                || '" не збігається з сумою в граничних умовах');
        END IF;

        --------------
        FOR c IN (SELECT *
                    FROM budget_org2item
                   WHERE bo2i_bo = p_bo_id)
        LOOP
            SELECT SUM (bo2i_sum), COUNT (*)
              INTO l_sum, l_count
              FROM budget_org2item  oi
                   JOIN budget_item i ON oi.bo2i_bi = i.bi_id
             WHERE bo2i_bo = p_bo_id AND i.bi_group = c.bo2i_bi;

            IF (l_count > 0 AND l_sum <> c.bo2i_sum)
            THEN
                raise_application_error (
                    -20000,
                       'Для статті "'
                    || getBiName (c.bo2i_bi)
                    || '" сума в статтях нижнього рівня '
                    || l_sum
                    || ' не дорівнює сумі в статті '
                    || c.bo2i_sum);
            END IF;

            IF (l_count > 0)
            THEN
                FOR m IN (SELECT *
                            FROM budget_org2item2month
                           WHERE bo2i2m_bo2i = c.bo2i_id)
                LOOP
                    SELECT SUM (bo2i2m_sum)
                      INTO l_sum
                      FROM budget_org2item2month  bm
                           JOIN budget_org2item oi
                               ON oi.bo2i_id = bm.bo2i2m_month
                           JOIN budget_item i ON oi.bo2i_bi = i.bi_id
                     WHERE     bo2i_bo = p_bo_id
                           AND i.bi_group = c.bo2i_bi
                           AND bm.bo2i2m_month = m.bo2i2m_month;

                    IF (l_sum <> m.bo2i2m_sum)
                    THEN
                        raise_application_error (
                            -20000,
                               'Для статті "'
                            || getBiName (c.bo2i_bi)
                            || '" сума граничних умов в статтях нижнього рівня '
                            || l_sum
                            || ' перевищує суму в статті '
                            || m.bo2i2m_sum
                            || ' за '
                            || INITCAP (
                                   TO_CHAR (m.bo2i2m_month,
                                            'MONTH',
                                            'nls_date_language=ukrainian')));
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END;

    PROCEDURE ChangeBudgetStatus (p_BO_ID       budget_org.BO_ID%TYPE,
                                  p_BO_STATUS   budget_org.BO_STATUS%TYPE,
                                  P_FILE_CODE   VARCHAR2:= NULL)
    IS
        l_bo_old_status   budget_org.BO_STATUS%TYPE;
    BEGIN
        SELECT bo_status
          INTO l_bo_old_status
          FROM budget_org
         WHERE bo_id = p_BO_ID;

        canChangeStatus (p_BO_STATUS, l_bo_old_status);

        IF (p_BO_STATUS = 'C')
        THEN
            CheckBudget (p_BO_ID);
        END IF;

        UPDATE budget_org
           SET bo_status = p_bo_status
         WHERE bo_id = p_bo_id;

        SaveJournal (p_bo_id,
                     p_bo_status,
                     NULL,
                     P_FILE_CODE);
    END;

    PROCEDURE GetBudgetForSign (p_BO_ID         budget_pfu.BP_ID%TYPE,
                                p_main      OUT SYS_REFCURSOR,
                                p_items     OUT SYS_REFCURSOR,
                                p_monthes   OUT SYS_REFCURSOR)
    IS
        l_id   NUMBER;
    BEGIN
        -- check for access
        SELECT bo_id
          INTO l_id
          FROM v_BUDGET_ORG
         WHERE bo_id = p_bo_id;

        OPEN p_main FOR SELECT bo_id, bo_org, bo_bp
                          FROM BUDGET_ORG JOIN budget_pfu ON bo_bp = bp_id
                         WHERE bo_id = p_bo_id;

        OPEN p_items FOR   SELECT bo2i_id,
                                  bo2i_bo,
                                  bo2i_bi,
                                  bo2i_sum
                             FROM budget_org2item
                            WHERE bo2i_bo = p_bo_id
                         ORDER BY bo2i_id;

        OPEN p_monthes FOR
              SELECT bo2i2m_id,
                     bo2i2m_bo2i,
                     bo2i2m_month,
                     bo2i2m_sum
                FROM budget_org2item2month
                     JOIN budget_org2item ON bo2i2m_bo2i = bo2i_id
               WHERE bo2i_bo = p_bo_id
            ORDER BY bo2i2m_bo2i, bo2i2m_month, bo2i2m_id;
    END;

    PROCEDURE GetLastSignedRec (p_bo_id   IN     budget_org.bo_id%TYPE,
                                p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT *
              FROM (  SELECT z.*
                        FROM budget_org_journal z
                             JOIN V_budget_org ON boj_bo = bo_id
                       WHERE bo_id = p_bo_id AND boj_file_code IS NOT NULL
                    ORDER BY boj_date DESC, boj_id DESC);
    END;
END FINZVIT_BUDGET_ORG;
/