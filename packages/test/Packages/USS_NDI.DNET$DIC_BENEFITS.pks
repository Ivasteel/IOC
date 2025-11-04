/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_BENEFITS
IS
    -- Author  : BOGDAN
    -- Created : 01.04.2024 13:22:41
    -- Purpose : Довідники пільг

    -------------------------------------------------------------
    ---------------------- Категорії пільг ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Benefit_Category_List (p_res OUT SYS_REFCURSOR);


    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Benefit_Category (
        p_id    IN     NDI_BENEFIT_CATEGORY.NBC_ID%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Ndi_Benefit_Category (
        p_NBC_ID               IN     NDI_BENEFIT_CATEGORY.NBC_ID%TYPE,
        p_NBC_CODE             IN     NDI_BENEFIT_CATEGORY.NBC_CODE%TYPE,
        p_NBC_NAME             IN     NDI_BENEFIT_CATEGORY.NBC_NAME%TYPE,
        p_NBC_RIGHT_BENEFIT    IN     NDI_BENEFIT_CATEGORY.NBC_RIGHT_BENEFIT%TYPE,
        p_NBC_BENEFIT_AMOUNT   IN     NDI_BENEFIT_CATEGORY.NBC_BENEFIT_AMOUNT%TYPE,
        p_NBC_UNIT             IN     NDI_BENEFIT_CATEGORY.NBC_UNIT%TYPE,
        p_NBC_BENEFIT_COEF     IN     NDI_BENEFIT_CATEGORY.NBC_BENEFIT_COEF%TYPE,
        p_NBC_NORM_ACT         IN     NDI_BENEFIT_CATEGORY.NBC_NORM_ACT%TYPE,
        p_NBC_SOCIAL_NORM      IN     NDI_BENEFIT_CATEGORY.NBC_SOCIAL_NORM%TYPE,
        p_NBC_INCOME_CHECK     IN     NDI_BENEFIT_CATEGORY.NBC_INCOME_CHECK%TYPE,
        p_NBC_NOTES            IN     NDI_BENEFIT_CATEGORY.NBC_NOTES%TYPE,
        p_NBC_FAMILY_EXT       IN     NDI_BENEFIT_CATEGORY.NBC_FAMILY_EXT%TYPE,
        p_NBC_AVAILABLE        IN     NDI_BENEFIT_CATEGORY.NBC_AVAILABLE%TYPE,
        p_NBC_NNA              IN     NDI_BENEFIT_CATEGORY.NBC_NNA%TYPE,
        p_NBC_IS_RESTRICTED    IN     NDI_BENEFIT_CATEGORY.NBC_IS_RESTRICTED%TYPE,
        p_new_id                  OUT NDI_BENEFIT_CATEGORY.NBC_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Ndi_Benefit_Category (
        p_id   NDI_BENEFIT_CATEGORY.NBC_ID%TYPE);


    --------------------------------------------------------
    ---------------------- Типи пільг ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Benefit_Type_List (p_res OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Benefit_Type (
        p_id    IN     NDI_BENEFIT_TYPE.NBT_ID%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Ndi_Benefit_Type (
        p_NBT_ID      IN     NDI_BENEFIT_TYPE.NBT_ID%TYPE,
        p_NBT_CODE    IN     NDI_BENEFIT_TYPE.NBT_CODE%TYPE,
        p_NBT_NAME    IN     NDI_BENEFIT_TYPE.NBT_NAME%TYPE,
        p_NBT_IS_HS   IN     NDI_BENEFIT_TYPE.NBT_IS_HS%TYPE,
        p_new_id         OUT NDI_BENEFIT_TYPE.NBT_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Ndi_Benefit_Type (p_id NDI_BENEFIT_TYPE.NBT_ID%TYPE);


    -----------------------------------------------------------------
    ---------------------- Категорії та пільги ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbc_Setup_List (
        p_NBCS_NBC   IN     NDI_NBC_SETUP.NBCS_NBC%TYPE,
        p_NBCS_NBT   IN     NDI_NBC_SETUP.NBCS_NBT%TYPE,
        p_res           OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbc_Setup (p_id    IN     ndi_nbc_setup.nbcs_id%TYPE,
                                 p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Ndi_Nbc_Setup (
        p_NBCS_ID    IN     NDI_NBC_SETUP.NBCS_ID%TYPE,
        p_NBCS_NBC   IN     NDI_NBC_SETUP.NBCS_NBC%TYPE,
        p_NBCS_NBT   IN     NDI_NBC_SETUP.NBCS_NBT%TYPE,
        p_new_id        OUT NDI_NBC_SETUP.NBCS_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbc_Setup (p_id ndi_nbc_setup.nbcs_id%TYPE);

    ------------------------------------------------------------------------------------------------
    ---------------------- Категорії та Документи, що надають право на пільги ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbc_Ndt_Setup_List (
        p_nbts_nbc   IN     NDI_NBC_NDT_SETUP.NBTS_NBC%TYPE,
        p_nbts_ndt   IN     NDI_NBC_NDT_SETUP.NBTS_NDT%TYPE,
        p_res           OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbc_Ndt_Setup (
        p_id    IN     ndi_nbc_ndt_setup.nbts_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Ndi_Nbc_Ndt_Setup (
        p_NBTS_ID       IN     NDI_NBC_NDT_SETUP.NBTS_ID%TYPE,
        p_NBTS_NBC      IN     NDI_NBC_NDT_SETUP.NBTS_NBC%TYPE,
        p_NBTS_NDT      IN     NDI_NBC_NDT_SETUP.NBTS_NDT%TYPE,
        p_NBTS_IS_DEF   IN     NDI_NBC_NDT_SETUP.NBTS_IS_DEF%TYPE,
        p_new_id           OUT NDI_NBC_NDT_SETUP.NBTS_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbc_Ndt_Setup (p_id ndi_nbc_ndt_setup.nbts_id%TYPE);


    -------------------------------------------------------------
    ---------------------- Види виплат ПФУ ----------------------

    -- Список за фільтром
    PROCEDURE Get_Pfu_Payment_Type_List (p_res OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Pfu_Payment_Type (
        p_id    IN     ndi_pfu_payment_type.nppt_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Pfu_Payment_Type (
        p_NPPT_ID          IN     NDI_PFU_PAYMENT_TYPE.NPPT_ID%TYPE,
        p_NPPT_CODE        IN     NDI_PFU_PAYMENT_TYPE.NPPT_CODE%TYPE,
        p_NPPT_NAME        IN     NDI_PFU_PAYMENT_TYPE.NPPT_NAME%TYPE,
        p_NPPT_LEGAL_ACT   IN     NDI_PFU_PAYMENT_TYPE.NPPT_LEGAL_ACT%TYPE,
        p_new_id              OUT NDI_PFU_PAYMENT_TYPE.NPPT_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Pfu_Payment_Type (
        p_id   ndi_pfu_payment_type.nppt_id%TYPE);


    -----------------------------------------------------------------------
    ---------------------- Пільги та види виплат ПФУ ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbt_Nppt_Setup_List (
        p_NBPT_NBT    IN     NDI_NBT_NPPT_SETUP.NBPT_NBT%TYPE,
        p_NBPT_NPPT   IN     NDI_NBT_NPPT_SETUP.NBPT_NPPT%TYPE,
        p_res            OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbt_Nppt_Setup (
        p_id    IN     Ndi_Nbt_Nppt_Setup.Nbpt_Id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Set_Ndi_Nbt_Nppt_Setup (
        p_NBPT_ID     IN     NDI_NBT_NPPT_SETUP.NBPT_ID%TYPE,
        p_NBPT_NBT    IN     NDI_NBT_NPPT_SETUP.NBPT_NBT%TYPE,
        p_NBPT_NPPT   IN     NDI_NBT_NPPT_SETUP.NBPT_NPPT%TYPE,
        p_new_id         OUT NDI_NBT_NPPT_SETUP.NBPT_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbt_Nppt_Setup (
        p_id   Ndi_Nbt_Nppt_Setup.Nbpt_Id%TYPE);


    -- Налаштування розрахунку допомог
    PROCEDURE Get_Ndi_Nst_Calc_Config (res_cur OUT SYS_REFCURSOR);
END DNET$DIC_BENEFITS;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_BENEFITS TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_BENEFITS
IS
    -------------------------------------------------------------
    ---------------------- Категорії пільг ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Benefit_Category_List (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
              SELECT t.*,
                     CASE
                         WHEN a.nna_id IS NOT NULL
                         THEN
                                '№'
                             || a.nna_num
                             || ' від '
                             || TO_CHAR (a.nna_dt, 'DD.MM.YYYY')
                     END    AS nbc_nna_name
                FROM NDI_BENEFIT_CATEGORY t
                     LEFT JOIN ndi_normative_act a ON (a.nna_id = t.nbc_nna)
               WHERE t.history_status = 'A'
            ORDER BY t.nbc_code, t.nbc_name;
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Benefit_Category (
        p_id    IN     NDI_BENEFIT_CATEGORY.NBC_ID%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_BENEFIT_CATEGORY t
                        WHERE NBC_ID = p_id AND t.history_status = 'A';
    END;

    -- Зберегти
    PROCEDURE Set_Ndi_Benefit_Category (
        p_NBC_ID               IN     NDI_BENEFIT_CATEGORY.NBC_ID%TYPE,
        p_NBC_CODE             IN     NDI_BENEFIT_CATEGORY.NBC_CODE%TYPE,
        p_NBC_NAME             IN     NDI_BENEFIT_CATEGORY.NBC_NAME%TYPE,
        p_NBC_RIGHT_BENEFIT    IN     NDI_BENEFIT_CATEGORY.NBC_RIGHT_BENEFIT%TYPE,
        p_NBC_BENEFIT_AMOUNT   IN     NDI_BENEFIT_CATEGORY.NBC_BENEFIT_AMOUNT%TYPE,
        p_NBC_UNIT             IN     NDI_BENEFIT_CATEGORY.NBC_UNIT%TYPE,
        p_NBC_BENEFIT_COEF     IN     NDI_BENEFIT_CATEGORY.NBC_BENEFIT_COEF%TYPE,
        p_NBC_NORM_ACT         IN     NDI_BENEFIT_CATEGORY.NBC_NORM_ACT%TYPE,
        p_NBC_SOCIAL_NORM      IN     NDI_BENEFIT_CATEGORY.NBC_SOCIAL_NORM%TYPE,
        p_NBC_INCOME_CHECK     IN     NDI_BENEFIT_CATEGORY.NBC_INCOME_CHECK%TYPE,
        p_NBC_NOTES            IN     NDI_BENEFIT_CATEGORY.NBC_NOTES%TYPE,
        p_NBC_FAMILY_EXT       IN     NDI_BENEFIT_CATEGORY.NBC_FAMILY_EXT%TYPE,
        p_NBC_AVAILABLE        IN     NDI_BENEFIT_CATEGORY.NBC_AVAILABLE%TYPE,
        p_NBC_NNA              IN     NDI_BENEFIT_CATEGORY.NBC_NNA%TYPE,
        p_NBC_IS_RESTRICTED    IN     NDI_BENEFIT_CATEGORY.NBC_IS_RESTRICTED%TYPE,
        p_new_id                  OUT NDI_BENEFIT_CATEGORY.NBC_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NBC_ID IS NULL
        THEN
            INSERT INTO NDI_BENEFIT_CATEGORY (NBC_CODE,
                                              NBC_NAME,
                                              NBC_RIGHT_BENEFIT,
                                              NBC_BENEFIT_AMOUNT,
                                              NBC_UNIT,
                                              NBC_BENEFIT_COEF,
                                              NBC_NORM_ACT,
                                              NBC_SOCIAL_NORM,
                                              NBC_INCOME_CHECK,
                                              NBC_NOTES,
                                              NBC_FAMILY_EXT,
                                              NBC_AVAILABLE,
                                              HISTORY_STATUS,
                                              NBC_NNA,
                                              NBC_IS_RESTRICTED)
                 VALUES (p_NBC_CODE,
                         p_NBC_NAME,
                         p_NBC_RIGHT_BENEFIT,
                         p_NBC_BENEFIT_AMOUNT,
                         p_NBC_UNIT,
                         p_NBC_BENEFIT_COEF,
                         p_NBC_NORM_ACT,
                         p_NBC_SOCIAL_NORM,
                         p_NBC_INCOME_CHECK,
                         p_NBC_NOTES,
                         p_NBC_FAMILY_EXT,
                         p_NBC_AVAILABLE,
                         'A',
                         p_NBC_NNA,
                         p_NBC_IS_RESTRICTED)
              RETURNING NBC_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBC_ID;

            UPDATE NDI_BENEFIT_CATEGORY
               SET NBC_CODE = p_NBC_CODE,
                   NBC_NAME = p_NBC_NAME,
                   NBC_RIGHT_BENEFIT = p_NBC_RIGHT_BENEFIT,
                   NBC_BENEFIT_AMOUNT = p_NBC_BENEFIT_AMOUNT,
                   NBC_UNIT = p_NBC_UNIT,
                   NBC_BENEFIT_COEF = p_NBC_BENEFIT_COEF,
                   NBC_NORM_ACT = p_NBC_NORM_ACT,
                   NBC_SOCIAL_NORM = p_NBC_SOCIAL_NORM,
                   NBC_INCOME_CHECK = p_NBC_INCOME_CHECK,
                   NBC_NOTES = p_NBC_NOTES,
                   NBC_FAMILY_EXT = p_NBC_FAMILY_EXT,
                   NBC_AVAILABLE = p_NBC_AVAILABLE,
                   NBC_NNA = p_NBC_NNA,
                   NBC_IS_RESTRICTED = p_NBC_IS_RESTRICTED
             WHERE NBC_ID = p_NBC_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Ndi_Benefit_Category (
        p_id   NDI_BENEFIT_CATEGORY.NBC_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        UPDATE NDI_BENEFIT_CATEGORY t
           SET t.history_status = 'H'
         WHERE NBC_ID = p_id;
    END;

    --------------------------------------------------------
    ---------------------- Типи пільг ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Benefit_Type_List (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR   SELECT t.*
                           FROM NDI_BENEFIT_TYPE t
                          WHERE t.history_status = 'A'
                       ORDER BY t.nbt_code, t.nbt_name;
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Benefit_Type (
        p_id    IN     NDI_BENEFIT_TYPE.NBT_ID%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_BENEFIT_TYPE t
                        WHERE NBT_ID = p_id AND t.history_status = 'A';
    END;

    -- Зберегти
    PROCEDURE Set_Ndi_Benefit_Type (
        p_NBT_ID      IN     NDI_BENEFIT_TYPE.NBT_ID%TYPE,
        p_NBT_CODE    IN     NDI_BENEFIT_TYPE.NBT_CODE%TYPE,
        p_NBT_NAME    IN     NDI_BENEFIT_TYPE.NBT_NAME%TYPE,
        p_NBT_IS_HS   IN     NDI_BENEFIT_TYPE.NBT_IS_HS%TYPE,
        p_new_id         OUT NDI_BENEFIT_TYPE.NBT_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NBT_ID IS NULL
        THEN
            INSERT INTO NDI_BENEFIT_TYPE (NBT_CODE,
                                          NBT_NAME,
                                          HISTORY_STATUS,
                                          NBT_IS_HS)
                 VALUES (p_NBT_CODE,
                         p_NBT_NAME,
                         'A',
                         p_NBT_IS_HS)
              RETURNING NBT_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBT_ID;

            UPDATE NDI_BENEFIT_TYPE
               SET NBT_CODE = p_NBT_CODE,
                   NBT_NAME = p_NBT_NAME,
                   NBT_IS_HS = p_NBT_IS_HS
             WHERE NBT_ID = p_NBT_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Ndi_Benefit_Type (p_id NDI_BENEFIT_TYPE.NBT_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        UPDATE NDI_BENEFIT_TYPE t
           SET t.history_status = 'H'
         WHERE NBT_ID = p_id;
    END;

    -----------------------------------------------------------------
    ---------------------- Категорії та пільги ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbc_Setup_List (
        p_NBCS_NBC   IN     NDI_NBC_SETUP.NBCS_NBC%TYPE,
        p_NBCS_NBT   IN     NDI_NBC_SETUP.NBCS_NBT%TYPE,
        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT t.*,
                   c.nbc_name     AS nbcs_nbc_name,
                   b.nbt_name     AS nbcs_nbt_name
              FROM NDI_NBC_SETUP  t
                   LEFT JOIN ndi_benefit_category c
                       ON (c.nbc_id = t.nbcs_nbc)
                   LEFT JOIN ndi_benefit_type b ON (b.nbt_id = t.nbcs_nbt)
             WHERE     t.nbcs_nbc = NVL (p_NBCS_NBC, t.nbcs_nbc)
                   AND t.nbcs_nbt = NVL (p_NBCS_NBT, t.nbcs_nbt);
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbc_Setup (p_id    IN     ndi_nbc_setup.nbcs_id%TYPE,
                                 p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_NBC_SETUP t
                        WHERE t.nbcs_id = p_id;
    END;

    -- Зберегти
    PROCEDURE Set_Ndi_Nbc_Setup (
        p_NBCS_ID    IN     NDI_NBC_SETUP.NBCS_ID%TYPE,
        p_NBCS_NBC   IN     NDI_NBC_SETUP.NBCS_NBC%TYPE,
        p_NBCS_NBT   IN     NDI_NBC_SETUP.NBCS_NBT%TYPE,
        p_new_id        OUT NDI_NBC_SETUP.NBCS_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NBCS_ID IS NULL
        THEN
            INSERT INTO NDI_NBC_SETUP (NBCS_NBC, NBCS_NBT)
                 VALUES (p_NBCS_NBC, p_NBCS_NBT)
              RETURNING NBCS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBCS_ID;

            UPDATE NDI_NBC_SETUP
               SET NBCS_NBC = p_NBCS_NBC, NBCS_NBT = p_NBCS_NBT
             WHERE NBCS_ID = p_NBCS_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbc_Setup (p_id ndi_nbc_setup.nbcs_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        DELETE FROM NDI_NBC_SETUP t
              WHERE t.nbcs_id = p_id;
    END;

    ------------------------------------------------------------------------------------------------
    ---------------------- Категорії та Документи, що надають право на пільги ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbc_Ndt_Setup_List (
        p_nbts_nbc   IN     NDI_NBC_NDT_SETUP.NBTS_NBC%TYPE,
        p_nbts_ndt   IN     NDI_NBC_NDT_SETUP.NBTS_NDT%TYPE,
        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT t.*,
                   c.nbc_name     AS nbts_nbc_name,
                   d.ndt_name     AS nbts_ndt_name
              FROM NDI_NBC_NDT_SETUP  t
                   LEFT JOIN ndi_benefit_category c
                       ON (c.nbc_id = t.nbts_nbc)
                   LEFT JOIN Ndi_Document_Type d ON (d.ndt_id = t.nbts_ndt)
             WHERE     t.nbts_nbc = NVL (p_nbts_nbc, t.nbts_nbc)
                   AND t.nbts_ndt = NVL (p_nbts_ndt, t.nbts_ndt);
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbc_Ndt_Setup (
        p_id    IN     ndi_nbc_ndt_setup.nbts_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM NDI_NBC_NDT_SETUP t
                        WHERE t.nbts_id = p_id;
    END;

    -- Зберегти
    PROCEDURE Set_Ndi_Nbc_Ndt_Setup (
        p_NBTS_ID       IN     NDI_NBC_NDT_SETUP.NBTS_ID%TYPE,
        p_NBTS_NBC      IN     NDI_NBC_NDT_SETUP.NBTS_NBC%TYPE,
        p_NBTS_NDT      IN     NDI_NBC_NDT_SETUP.NBTS_NDT%TYPE,
        p_NBTS_IS_DEF   IN     NDI_NBC_NDT_SETUP.NBTS_IS_DEF%TYPE,
        p_new_id           OUT NDI_NBC_NDT_SETUP.NBTS_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NBTS_ID IS NULL
        THEN
            INSERT INTO NDI_NBC_NDT_SETUP (NBTS_NBC, NBTS_NDT, NBTS_IS_DEF)
                 VALUES (p_NBTS_NBC, p_NBTS_NDT, p_NBTS_IS_DEF)
              RETURNING NBTS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBTS_ID;

            UPDATE NDI_NBC_NDT_SETUP
               SET NBTS_NBC = p_NBTS_NBC,
                   NBTS_NDT = p_NBTS_NDT,
                   NBTS_IS_DEF = p_NBTS_IS_DEF
             WHERE NBTS_ID = p_NBTS_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbc_Ndt_Setup (p_id ndi_nbc_ndt_setup.nbts_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        DELETE FROM NDI_NBC_NDT_SETUP t
              WHERE t.nbts_id = p_id;
    END;

    -------------------------------------------------------------
    ---------------------- Види виплат ПФУ ----------------------

    -- Список за фільтром
    PROCEDURE Get_Pfu_Payment_Type_List (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR   SELECT t.*
                           FROM ndi_pfu_payment_type t
                          WHERE 1 = 1
                       ORDER BY t.nppt_code, t.nppt_name;
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Pfu_Payment_Type (
        p_id    IN     ndi_pfu_payment_type.nppt_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM ndi_pfu_payment_type t
                        WHERE t.nppt_id = p_id;
    END;

    -- Зберегти
    PROCEDURE Set_Pfu_Payment_Type (
        p_NPPT_ID          IN     NDI_PFU_PAYMENT_TYPE.NPPT_ID%TYPE,
        p_NPPT_CODE        IN     NDI_PFU_PAYMENT_TYPE.NPPT_CODE%TYPE,
        p_NPPT_NAME        IN     NDI_PFU_PAYMENT_TYPE.NPPT_NAME%TYPE,
        p_NPPT_LEGAL_ACT   IN     NDI_PFU_PAYMENT_TYPE.NPPT_LEGAL_ACT%TYPE,
        p_new_id              OUT NDI_PFU_PAYMENT_TYPE.NPPT_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NPPT_ID IS NULL
        THEN
            INSERT INTO NDI_PFU_PAYMENT_TYPE (NPPT_CODE,
                                              NPPT_NAME,
                                              NPPT_LEGAL_ACT)
                 VALUES (p_NPPT_CODE, p_NPPT_NAME, p_NPPT_LEGAL_ACT)
              RETURNING NPPT_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NPPT_ID;

            UPDATE NDI_PFU_PAYMENT_TYPE
               SET NPPT_CODE = p_NPPT_CODE,
                   NPPT_NAME = p_NPPT_NAME,
                   NPPT_LEGAL_ACT = p_NPPT_LEGAL_ACT
             WHERE NPPT_ID = p_NPPT_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Pfu_Payment_Type (
        p_id   ndi_pfu_payment_type.nppt_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        DELETE FROM ndi_pfu_payment_type t
              WHERE t.nppt_id = p_id;
    END;

    -----------------------------------------------------------------------
    ---------------------- Пільги та види виплат ПФУ ----------------------

    -- Список за фільтром
    PROCEDURE Get_Ndi_Nbt_Nppt_Setup_List (
        p_NBPT_NBT    IN     NDI_NBT_NPPT_SETUP.NBPT_NBT%TYPE,
        p_NBPT_NPPT   IN     NDI_NBT_NPPT_SETUP.NBPT_NPPT%TYPE,
        p_res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
              SELECT t.*,
                     b.nbt_name      AS nbpt_nbt_name,
                     p.nppt_name     AS nbpt_nppt_name
                FROM Ndi_Nbt_Nppt_Setup t
                     JOIN ndi_benefit_type b ON (b.nbt_id = t.nbpt_nbt)
                     JOIN ndi_pfu_payment_type p ON (p.nppt_id = t.nbpt_nppt)
               WHERE     1 = 1
                     AND t.nbpt_nppt = NVL (p_NBPT_NPPT, t.nbpt_nppt)
                     AND t.nbpt_nbt = NVL (p_NBPT_NBT, t.nbpt_nbt)
            ORDER BY 1;
    END;

    -- Отримати запис по ідентифікатору
    PROCEDURE Get_Ndi_Nbt_Nppt_Setup (
        p_id    IN     Ndi_Nbt_Nppt_Setup.Nbpt_Id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM Ndi_Nbt_Nppt_Setup t
                        WHERE t.nbpt_id = p_id;
    END;

    -- Зберегти
    PROCEDURE Set_Ndi_Nbt_Nppt_Setup (
        p_NBPT_ID     IN     NDI_NBT_NPPT_SETUP.NBPT_ID%TYPE,
        p_NBPT_NBT    IN     NDI_NBT_NPPT_SETUP.NBPT_NBT%TYPE,
        p_NBPT_NPPT   IN     NDI_NBT_NPPT_SETUP.NBPT_NPPT%TYPE,
        p_new_id         OUT NDI_NBT_NPPT_SETUP.NBPT_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        IF p_NBPT_ID IS NULL
        THEN
            INSERT INTO NDI_NBT_NPPT_SETUP (NBPT_NPPT, NBPT_NBT)
                 VALUES (p_NBPT_NPPT, p_NBPT_NBT)
              RETURNING NBPT_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBPT_ID;

            UPDATE NDI_NBT_NPPT_SETUP
               SET NBPT_NPPT = p_NBPT_NPPT, NBPT_NBT = p_NBPT_NBT
             WHERE NBPT_ID = p_NBPT_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete_Ndi_Nbt_Nppt_Setup (
        p_id   Ndi_Nbt_Nppt_Setup.Nbpt_Id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (10);

        DELETE FROM Ndi_Nbt_Nppt_Setup t
              WHERE t.nbpt_id = p_id;
    END;

    -- Налаштування розрахунку допомог
    PROCEDURE Get_Ndi_Nst_Calc_Config (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR
              SELECT t.*, s.nst_code || ' ' || s.nst_name AS ncc_nst_name
                FROM ndi_nst_calc_config t
                     JOIN ndi_service_type s ON (s.nst_id = t.ncc_nst)
               WHERE 1 = 1
            ORDER BY s.nst_code || ' ' || s.nst_name, t.ncc_id;
    END;
BEGIN
    NULL;
END DNET$DIC_BENEFITS;
/