/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.TEST$TEST_MASTER
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN TEST_MASTER.TM_ID%TYPE, p_res OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Save (
        p_TM_ID                 IN     TEST_MASTER.TM_ID%TYPE,
        p_TM_VARCHAR_NULL       IN     TEST_MASTER.TM_VARCHAR_NULL%TYPE,
        p_TM_VARCHAR_NOT_NULL   IN     TEST_MASTER.TM_VARCHAR_NOT_NULL%TYPE,
        p_TM_INT_NULL           IN     TEST_MASTER.TM_INT_NULL%TYPE,
        p_TM_INT_NOT_NULL       IN     TEST_MASTER.TM_INT_NOT_NULL%TYPE,
        p_TM_DATE_NULL          IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NOT_NULL      IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DECIMAL_NULL       IN     TEST_MASTER.TM_DECIMAL_NULL%TYPE,
        p_TM_DECIMAL_NOT_NULL   IN     TEST_MASTER.TM_DECIMAL_NOT_NULL%TYPE,
        p_TM_DIC_NULL           IN     TEST_MASTER.TM_DIC_NULL%TYPE,
        p_TM_DIC_NOT_NULL       IN     TEST_MASTER.TM_DIC_NOT_NULL%TYPE,
        p_new_id                   OUT TEST_MASTER.TM_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete (p_id TEST_MASTER.TM_ID%TYPE);

    -- Список за фільтром
    PROCEDURE Query (
        p_TM_VARCHAR_NULL         IN     TEST_MASTER.TM_VARCHAR_NULL%TYPE,
        p_TM_VARCHAR_NOT_NULL     IN     TEST_MASTER.TM_VARCHAR_NOT_NULL%TYPE,
        p_TM_DATE_NULL_From       IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NULL_To         IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NOT_NULL_From   IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DATE_NOT_NULL_To     IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DIC_NOT_NULL         IN     TEST_MASTER.TM_DIC_NOT_NULL%TYPE,
        p_res                        OUT SYS_REFCURSOR);
END TEST$TEST_MASTER;
/


GRANT EXECUTE ON USS_VISIT.TEST$TEST_MASTER TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:00:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.TEST$TEST_MASTER
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN TEST_MASTER.TM_ID%TYPE, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT TM_ID,
                              TM_VARCHAR_NULL,
                              TM_VARCHAR_NOT_NULL,
                              TM_INT_NULL,
                              TM_INT_NOT_NULL,
                              TM_DATE_NULL,
                              TM_DATE_NOT_NULL,
                              TM_DECIMAL_NULL,
                              TM_DECIMAL_NOT_NULL,
                              TM_DIC_NULL,
                              TM_DIC_NOT_NULL
                         FROM TEST_MASTER
                        WHERE TM_ID = p_id;
    END;

    -- Зберегти
    PROCEDURE Save (
        p_TM_ID                 IN     TEST_MASTER.TM_ID%TYPE,
        p_TM_VARCHAR_NULL       IN     TEST_MASTER.TM_VARCHAR_NULL%TYPE,
        p_TM_VARCHAR_NOT_NULL   IN     TEST_MASTER.TM_VARCHAR_NOT_NULL%TYPE,
        p_TM_INT_NULL           IN     TEST_MASTER.TM_INT_NULL%TYPE,
        p_TM_INT_NOT_NULL       IN     TEST_MASTER.TM_INT_NOT_NULL%TYPE,
        p_TM_DATE_NULL          IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NOT_NULL      IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DECIMAL_NULL       IN     TEST_MASTER.TM_DECIMAL_NULL%TYPE,
        p_TM_DECIMAL_NOT_NULL   IN     TEST_MASTER.TM_DECIMAL_NOT_NULL%TYPE,
        p_TM_DIC_NULL           IN     TEST_MASTER.TM_DIC_NULL%TYPE,
        p_TM_DIC_NOT_NULL       IN     TEST_MASTER.TM_DIC_NOT_NULL%TYPE,
        p_new_id                   OUT TEST_MASTER.TM_ID%TYPE)
    IS
    BEGIN
        IF p_TM_ID IS NULL
        THEN
            SELECT NVL (MAX (tm_id), 100000000000) + 1
              INTO p_new_id
              FROM TEST_MASTER;

            INSERT INTO TEST_MASTER (TM_ID,
                                     TM_VARCHAR_NULL,
                                     TM_VARCHAR_NOT_NULL,
                                     TM_INT_NULL,
                                     TM_INT_NOT_NULL,
                                     TM_DATE_NULL,
                                     TM_DATE_NOT_NULL,
                                     TM_DECIMAL_NULL,
                                     TM_DECIMAL_NOT_NULL,
                                     TM_DIC_NULL,
                                     TM_DIC_NOT_NULL)
                 VALUES (p_new_id,
                         p_TM_VARCHAR_NULL,
                         p_TM_VARCHAR_NOT_NULL,
                         p_TM_INT_NULL,
                         p_TM_INT_NOT_NULL,
                         p_TM_DATE_NULL,
                         p_TM_DATE_NOT_NULL,
                         p_TM_DECIMAL_NULL,
                         p_TM_DECIMAL_NOT_NULL,
                         p_TM_DIC_NULL,
                         p_TM_DIC_NOT_NULL)
              RETURNING TM_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_TM_ID;

            UPDATE TEST_MASTER
               SET TM_VARCHAR_NULL = p_TM_VARCHAR_NULL,
                   TM_VARCHAR_NOT_NULL = p_TM_VARCHAR_NOT_NULL,
                   TM_INT_NULL = p_TM_INT_NULL,
                   TM_INT_NOT_NULL = p_TM_INT_NOT_NULL,
                   TM_DATE_NULL = p_TM_DATE_NULL,
                   TM_DATE_NOT_NULL = p_TM_DATE_NOT_NULL,
                   TM_DECIMAL_NULL = p_TM_DECIMAL_NULL,
                   TM_DECIMAL_NOT_NULL = p_TM_DECIMAL_NOT_NULL,
                   TM_DIC_NULL = p_TM_DIC_NULL,
                   TM_DIC_NOT_NULL = p_TM_DIC_NOT_NULL
             WHERE TM_ID = p_TM_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete (p_id TEST_MASTER.TM_ID%TYPE)
    IS
    BEGIN
        DELETE FROM TEST_MASTER
              WHERE TM_ID = p_id;
    END;

    -- Список за фільтром
    PROCEDURE Query (
        p_TM_VARCHAR_NULL         IN     TEST_MASTER.TM_VARCHAR_NULL%TYPE,
        p_TM_VARCHAR_NOT_NULL     IN     TEST_MASTER.TM_VARCHAR_NOT_NULL%TYPE,
        p_TM_DATE_NULL_From       IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NULL_To         IN     TEST_MASTER.TM_DATE_NULL%TYPE,
        p_TM_DATE_NOT_NULL_From   IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DATE_NOT_NULL_To     IN     TEST_MASTER.TM_DATE_NOT_NULL%TYPE,
        p_TM_DIC_NOT_NULL         IN     TEST_MASTER.TM_DIC_NOT_NULL%TYPE,
        p_res                        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT TM_ID,
                   TM_VARCHAR_NULL,
                   TM_VARCHAR_NOT_NULL,
                   TM_INT_NULL,
                   TM_INT_NOT_NULL,
                   TM_DATE_NULL,
                   TM_DATE_NOT_NULL,
                   TM_DECIMAL_NULL,
                   TM_DECIMAL_NOT_NULL,
                   TM_DIC_NULL,
                   TM_DIC_NOT_NULL
              FROM TEST_MASTER
             WHERE     (   p_TM_VARCHAR_NULL IS NULL
                        OR UPPER (TM_VARCHAR_NULL) LIKE
                               '%' || UPPER (p_TM_VARCHAR_NULL) || '%')
                   AND (   p_TM_VARCHAR_NOT_NULL IS NULL
                        OR UPPER (TM_VARCHAR_NOT_NULL) LIKE
                               '%' || UPPER (p_TM_VARCHAR_NOT_NULL) || '%')
                   AND (   p_TM_DATE_NULL_From IS NULL
                        OR TM_DATE_NULL >= p_TM_DATE_NULL_From)
                   AND (   p_TM_DATE_NULL_To IS NULL
                        OR TM_DATE_NULL < p_TM_DATE_NULL_To + 1)
                   AND (   p_TM_DATE_NOT_NULL_From IS NULL
                        OR TM_DATE_NOT_NULL >= p_TM_DATE_NOT_NULL_From)
                   AND (   p_TM_DATE_NOT_NULL_To IS NULL
                        OR TM_DATE_NOT_NULL < p_TM_DATE_NOT_NULL_To + 1)
                   AND (   p_TM_DIC_NOT_NULL IS NULL
                        OR TM_DIC_NOT_NULL = p_TM_DIC_NOT_NULL);
    END;
END TEST$TEST_MASTER;
/