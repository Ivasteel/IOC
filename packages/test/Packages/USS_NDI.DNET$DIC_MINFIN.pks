/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_MINFIN
IS
    -- Author  : BOGDAN
    -- Created : 02.11.2023 18:31:41
    -- Purpose : Довідники Мінфіну

    ------------------------------------------------------------
    --- Коди опрацювання рекомендацій ти прийнятих рішень
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d14 (res_cur OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE get_card_d14 (p_d14_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- видалити
    PROCEDURE delete_d14 (p_d14_id IN NUMBER);

    -- створення / оновлення
    PROCEDURE set_d14 (
        p_D14_ID             IN     NDI_MINFIN_D14.D14_ID%TYPE,
        p_D14_RIS_CODE       IN     NDI_MINFIN_D14.D14_RIS_CODE%TYPE,
        p_D14_RIS_NAME       IN     NDI_MINFIN_D14.D14_RIS_NAME%TYPE,
        p_D14_KLCOM_CODDEC   IN     NDI_MINFIN_D14.D14_KLCOM_CODDEC%TYPE,
        p_D14_KLCOM_NAME     IN     NDI_MINFIN_D14.D14_KLCOM_NAME%TYPE,
        p_D14_STATUS         IN     NDI_MINFIN_D14.D14_STATUS%TYPE,
        p_new_id                OUT NDI_MINFIN_D14.D14_ID%TYPE);

    ------------------------------------------------------------
    --- Коди виявлених невідповідностей
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d15 (res_cur OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE get_card_d15 (p_d15_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- видалити
    PROCEDURE delete_d15 (p_d15_id IN NUMBER);

    -- створення / оновлення
    PROCEDURE set_d15 (
        p_D15_ID            IN     NDI_MINFIN_D15.D15_ID%TYPE,
        p_D15_TYPE_REC      IN     NDI_MINFIN_D15.D15_TYPE_REC%TYPE,
        p_D15_CONTENT_MAX   IN     NDI_MINFIN_D15.D15_CONTENT_MAX%TYPE,
        p_D15_CONTENT_MIN   IN     NDI_MINFIN_D15.D15_CONTENT_MIN%TYPE,
        p_new_id               OUT NDI_MINFIN_D15.D15_ID%TYPE);

    ------------------------------------------------------------
    --- Джерела надходження інформації
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d16 (res_cur OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE get_card_d16 (p_d16_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- видалити
    PROCEDURE delete_d16 (p_d16_id IN NUMBER);

    -- створення / оновлення
    PROCEDURE set_d16 (
        p_D16_ID         IN     NDI_MINFIN_D16.D16_ID%TYPE,
        p_D16_ORG        IN     NDI_MINFIN_D16.D16_ORG%TYPE,
        p_D16_NAME_ORG   IN     NDI_MINFIN_D16.D16_NAME_ORG%TYPE,
        p_new_id            OUT NDI_MINFIN_D16.D16_ID%TYPE);


    ------------------------------------------------------------
    --- Унікальні коди коментарів до прийнятих рішень
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d11 (res_cur OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE get_card_d11 (p_d11_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- видалити
    PROCEDURE delete_d11 (p_d11_id IN NUMBER);

    -- створення / оновлення
    PROCEDURE set_d11 (
        p_D11_ID         IN     NDI_MINFIN_D11.D11_ID%TYPE,
        p_D11_COM_CODE   IN     NDI_MINFIN_D11.D11_COM_CODE%TYPE,
        p_D11_TYPE_REC   IN     NDI_MINFIN_D11.D11_TYPE_REC%TYPE,
        p_D11_COM_NAME   IN     NDI_MINFIN_D11.D11_COM_NAME%TYPE,
        p_D11_DOC_CODE   IN     NDI_MINFIN_D11.D11_DOC_CODE%TYPE,
        p_new_id            OUT NDI_MINFIN_D11.D11_ID%TYPE);


    ------------------------------------------------------------
    --- Назви документів які підтверджують невідповідність
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d12 (res_cur OUT SYS_REFCURSOR);

    -- картка
    PROCEDURE get_card_d12 (p_d12_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- видалити
    PROCEDURE delete_d12 (p_d12_id IN NUMBER);

    -- створення / оновлення
    PROCEDURE set_d12 (
        p_D12_ID         IN     NDI_MINFIN_D12.D12_ID%TYPE,
        p_D12_DOC_CODE   IN     NDI_MINFIN_D12.D12_DOC_CODE%TYPE,
        p_D12_DOC_NAME   IN     NDI_MINFIN_D12.D12_DOC_NAME%TYPE,
        p_new_id            OUT NDI_MINFIN_D12.D12_ID%TYPE);
END DNET$DIC_MINFIN;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_MINFIN TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_MINFIN
IS
    ------------------------------------------------------------
    --- Коди опрацювання рекомендацій ти прийнятих рішень
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d14 (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d14 t;
    END;

    -- картка
    PROCEDURE get_card_d14 (p_d14_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d14 t
                          WHERE t.d14_id = p_d14_id;
    END;

    -- видалити
    PROCEDURE delete_d14 (p_d14_id IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        DELETE ndi_minfin_d14 t
         WHERE t.d14_id = p_d14_id;
    END;

    -- створення / оновлення
    PROCEDURE set_d14 (
        p_D14_ID             IN     NDI_MINFIN_D14.D14_ID%TYPE,
        p_D14_RIS_CODE       IN     NDI_MINFIN_D14.D14_RIS_CODE%TYPE,
        p_D14_RIS_NAME       IN     NDI_MINFIN_D14.D14_RIS_NAME%TYPE,
        p_D14_KLCOM_CODDEC   IN     NDI_MINFIN_D14.D14_KLCOM_CODDEC%TYPE,
        p_D14_KLCOM_NAME     IN     NDI_MINFIN_D14.D14_KLCOM_NAME%TYPE,
        p_D14_STATUS         IN     NDI_MINFIN_D14.D14_STATUS%TYPE,
        p_new_id                OUT NDI_MINFIN_D14.D14_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_D14_ID IS NULL
        THEN
            INSERT INTO NDI_MINFIN_D14 (D14_RIS_CODE,
                                        D14_RIS_NAME,
                                        D14_KLCOM_CODDEC,
                                        D14_KLCOM_NAME,
                                        D14_STATUS)
                 VALUES (p_D14_RIS_CODE,
                         p_D14_RIS_NAME,
                         p_D14_KLCOM_CODDEC,
                         p_D14_KLCOM_NAME,
                         p_D14_STATUS)
              RETURNING D14_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_D14_ID;

            UPDATE NDI_MINFIN_D14
               SET D14_RIS_CODE = p_D14_RIS_CODE,
                   D14_RIS_NAME = p_D14_RIS_NAME,
                   D14_KLCOM_CODDEC = p_D14_KLCOM_CODDEC,
                   D14_KLCOM_NAME = p_D14_KLCOM_NAME,
                   D14_STATUS = p_D14_STATUS
             WHERE D14_ID = p_D14_ID;
        END IF;
    END;

    ------------------------------------------------------------
    --- Коди виявлених невідповідностей
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d15 (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d15 t;
    END;

    -- картка
    PROCEDURE get_card_d15 (p_d15_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d15 t
                          WHERE t.d15_id = p_d15_id;
    END;

    -- видалити
    PROCEDURE delete_d15 (p_d15_id IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        DELETE ndi_minfin_d15 t
         WHERE t.d15_id = p_d15_id;
    END;

    -- створення / оновлення
    PROCEDURE set_d15 (
        p_D15_ID            IN     NDI_MINFIN_D15.D15_ID%TYPE,
        p_D15_TYPE_REC      IN     NDI_MINFIN_D15.D15_TYPE_REC%TYPE,
        p_D15_CONTENT_MAX   IN     NDI_MINFIN_D15.D15_CONTENT_MAX%TYPE,
        p_D15_CONTENT_MIN   IN     NDI_MINFIN_D15.D15_CONTENT_MIN%TYPE,
        p_new_id               OUT NDI_MINFIN_D15.D15_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_D15_ID IS NULL
        THEN
            INSERT INTO NDI_MINFIN_D15 (D15_TYPE_REC,
                                        D15_CONTENT_MAX,
                                        D15_CONTENT_MIN)
                 VALUES (p_D15_TYPE_REC,
                         p_D15_CONTENT_MAX,
                         p_D15_CONTENT_MIN)
              RETURNING D15_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_D15_ID;

            UPDATE NDI_MINFIN_D15
               SET D15_TYPE_REC = p_D15_TYPE_REC,
                   D15_CONTENT_MAX = p_D15_CONTENT_MAX,
                   D15_CONTENT_MIN = p_D15_CONTENT_MIN
             WHERE D15_ID = p_D15_ID;
        END IF;
    END;

    ------------------------------------------------------------
    --- Джерела надходження інформації
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d16 (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d16 t;
    END;

    -- картка
    PROCEDURE get_card_d16 (p_d16_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d16 t
                          WHERE t.d16_id = p_d16_id;
    END;

    -- видалити
    PROCEDURE delete_d16 (p_d16_id IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        DELETE ndi_minfin_d16 t
         WHERE t.d16_id = p_d16_id;
    END;

    -- створення / оновлення
    PROCEDURE set_d16 (
        p_D16_ID         IN     NDI_MINFIN_D16.D16_ID%TYPE,
        p_D16_ORG        IN     NDI_MINFIN_D16.D16_ORG%TYPE,
        p_D16_NAME_ORG   IN     NDI_MINFIN_D16.D16_NAME_ORG%TYPE,
        p_new_id            OUT NDI_MINFIN_D16.D16_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_D16_ID IS NULL
        THEN
            INSERT INTO NDI_MINFIN_D16 (D16_ORG, D16_NAME_ORG)
                 VALUES (p_D16_ORG, p_D16_NAME_ORG)
              RETURNING D16_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_D16_ID;

            UPDATE NDI_MINFIN_D16
               SET D16_ORG = p_D16_ORG, D16_NAME_ORG = p_D16_NAME_ORG
             WHERE D16_ID = p_D16_ID;
        END IF;
    END;

    ------------------------------------------------------------
    --- Унікальні коди коментарів до прийнятих рішень
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d11 (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d11 t;
    END;

    -- картка
    PROCEDURE get_card_d11 (p_d11_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d11 t
                          WHERE t.d11_id = p_d11_id;
    END;

    -- видалити
    PROCEDURE delete_d11 (p_d11_id IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        DELETE ndi_minfin_d11 t
         WHERE t.d11_id = p_d11_id;
    END;

    -- створення / оновлення
    PROCEDURE set_d11 (
        p_D11_ID         IN     NDI_MINFIN_D11.D11_ID%TYPE,
        p_D11_COM_CODE   IN     NDI_MINFIN_D11.D11_COM_CODE%TYPE,
        p_D11_TYPE_REC   IN     NDI_MINFIN_D11.D11_TYPE_REC%TYPE,
        p_D11_COM_NAME   IN     NDI_MINFIN_D11.D11_COM_NAME%TYPE,
        p_D11_DOC_CODE   IN     NDI_MINFIN_D11.D11_DOC_CODE%TYPE,
        p_new_id            OUT NDI_MINFIN_D11.D11_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_D11_ID IS NULL
        THEN
            INSERT INTO NDI_MINFIN_D11 (D11_COM_CODE,
                                        D11_TYPE_REC,
                                        D11_COM_NAME,
                                        D11_DOC_CODE)
                 VALUES (p_D11_COM_CODE,
                         p_D11_TYPE_REC,
                         p_D11_COM_NAME,
                         p_D11_DOC_CODE)
              RETURNING D11_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_D11_ID;

            UPDATE NDI_MINFIN_D11
               SET D11_COM_CODE = p_D11_COM_CODE,
                   D11_TYPE_REC = p_D11_TYPE_REC,
                   D11_COM_NAME = p_D11_COM_NAME,
                   D11_DOC_CODE = p_D11_DOC_CODE
             WHERE D11_ID = p_D11_ID;
        END IF;
    END;

    ------------------------------------------------------------
    --- Назви документів які підтверджують невідповідність
    ------------------------------------------------------------

    -- журнал
    PROCEDURE query_d12 (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d12 t;
    END;

    -- картка
    PROCEDURE get_card_d12 (p_d12_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN res_cur FOR SELECT t.*
                           FROM ndi_minfin_d12 t
                          WHERE t.d12_id = p_d12_id;
    END;

    -- видалити
    PROCEDURE delete_d12 (p_d12_id IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        DELETE ndi_minfin_d12 t
         WHERE t.d12_id = p_d12_id;
    END;

    -- створення / оновлення
    PROCEDURE set_d12 (
        p_D12_ID         IN     NDI_MINFIN_D12.D12_ID%TYPE,
        p_D12_DOC_CODE   IN     NDI_MINFIN_D12.D12_DOC_CODE%TYPE,
        p_D12_DOC_NAME   IN     NDI_MINFIN_D12.D12_DOC_NAME%TYPE,
        p_new_id            OUT NDI_MINFIN_D12.D12_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_D12_ID IS NULL
        THEN
            INSERT INTO NDI_MINFIN_D12 (D12_DOC_CODE, D12_DOC_NAME)
                 VALUES (p_D12_DOC_CODE, p_D12_DOC_NAME)
              RETURNING D12_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_D12_ID;

            UPDATE NDI_MINFIN_D12
               SET D12_DOC_CODE = p_D12_DOC_CODE,
                   D12_DOC_NAME = p_D12_DOC_NAME
             WHERE D12_ID = p_D12_ID;
        END IF;
    END;
BEGIN
    NULL;
END DNET$DIC_MINFIN;
/