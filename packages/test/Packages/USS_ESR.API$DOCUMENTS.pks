/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$DOCUMENTS
IS
    -- Author  : LEV
    -- Created : 13.05.2022 14:40:07
    -- Purpose : Робота з документами ЄРС

    -- info:   Створення документа-рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа звернення
    -- note:
    PROCEDURE create_decision (
        p_pd_id        IN     pd_document.pdo_pd%TYPE,
        p_doc_id       IN     pd_document.pdo_doc%TYPE DEFAULT NULL,
        p_dh_id        IN     pd_document.pdo_dh%TYPE DEFAULT NULL,
        p_ap_id        IN     pd_document.pdo_ap%TYPE DEFAULT NULL,
        p_app_id       IN     pd_document.pdo_app%TYPE DEFAULT NULL,
        p_aps_id       IN     pd_document.pdo_aps%TYPE DEFAULT NULL,
        p_apd_id       IN     pd_document.pdo_apd%TYPE DEFAULT NULL,
        p_new_pdo_id      OUT pd_document.pdo_id%TYPE);

    -- info:   Оновлення інформації по документу Е/А в документі рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    -- note:
    PROCEDURE add_decision_doc (p_pd_id    IN pd_document.pdo_pd%TYPE,
                                p_doc_id   IN pd_document.pdo_doc%TYPE,
                                p_dh_id    IN pd_document.pdo_dh%TYPE);

    -- info:   Оновлення інформації в документі рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа  звернення
    -- note:
    PROCEDURE add_decision_info (
        p_pd_id    IN pd_document.pdo_pd%TYPE,
        p_ap_id    IN pd_document.pdo_ap%TYPE DEFAULT NULL,
        p_app_id   IN pd_document.pdo_app%TYPE DEFAULT NULL,
        p_aps_id   IN pd_document.pdo_aps%TYPE DEFAULT NULL,
        p_apd_id   IN pd_document.pdo_apd%TYPE DEFAULT NULL);

    -- info:   Створення документа
    -- params: p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа звернення
    --         p_ndt_id - ідентифікатор типу документа
    --         p_pd_id - ідентифікатор рішення
    -- note:
    PROCEDURE save_pd_document (p_pdo_Id   IN     pd_document.pdo_id%TYPE,
                                p_doc_id   IN     pd_document.pdo_doc%TYPE,
                                p_dh_id    IN     pd_document.pdo_dh%TYPE,
                                p_ap_id    IN     pd_document.pdo_ap%TYPE,
                                p_app_id   IN     pd_document.pdo_app%TYPE,
                                p_aps_id   IN     pd_document.pdo_aps%TYPE,
                                p_apd_id   IN     pd_document.pdo_apd%TYPE,
                                p_ndt_id   IN     pd_document.pdo_ndt%TYPE,
                                p_pd_id    IN     pd_document.pdo_pd%TYPE,
                                p_new_id      OUT pd_document.pdo_id%TYPE);

    PROCEDURE delete_pd_document (p_pdo_Id IN NUMBER);

    PROCEDURE delete_pd_document_all (p_pd_Id IN NUMBER);

    -- info:   Збереження атрибута
    PROCEDURE Save_pd_Document_Attr (
        p_pdoa_Id           IN     pd_Document_Attr.pdoa_Id%TYPE,
        p_pdoa_pdo          IN     pd_Document_Attr.pdoa_pdo%TYPE,
        p_pdoa_pd           IN     pd_Document_Attr.pdoa_pd%TYPE,
        p_pdoa_Nda          IN     pd_Document_Attr.pdoa_Nda%TYPE,
        p_pdoa_Val_Int      IN     pd_Document_Attr.pdoa_Val_Int%TYPE DEFAULT NULL,
        p_pdoa_Val_Dt       IN     pd_Document_Attr.pdoa_Val_Dt%TYPE DEFAULT NULL,
        p_pdoa_Val_String   IN     pd_Document_Attr.pdoa_Val_String%TYPE DEFAULT NULL,
        p_pdoa_Val_Id       IN     pd_Document_Attr.pdoa_Val_Id%TYPE DEFAULT NULL,
        p_pdoa_Val_Sum      IN     pd_Document_Attr.pdoa_Val_Sum%TYPE DEFAULT NULL,
        p_New_Id               OUT pd_Document_Attr.pdoa_Id%TYPE);

    -- info:   Видалення атрибута
    PROCEDURE Delete_pd_Document_Attr (p_Id pd_Document_Attr.pdoa_Id%TYPE);



    ------------------------------------------------------------
    --------------- Документи по актах -------------------------

    PROCEDURE save_at_document (p_ATD_ID    IN     AT_DOCUMENT.ATD_ID%TYPE,
                                p_ATD_AT    IN     AT_DOCUMENT.ATD_AT%TYPE,
                                p_ATD_NDT   IN     AT_DOCUMENT.ATD_NDT%TYPE,
                                p_ATD_ATS   IN     AT_DOCUMENT.ATD_ATS%TYPE,
                                p_ATD_DOC   IN     AT_DOCUMENT.ATD_DOC%TYPE,
                                p_ATD_DH    IN     AT_DOCUMENT.ATD_DH%TYPE,
                                p_new_id       OUT AT_DOCUMENT.ATD_ID%TYPE);

    PROCEDURE delete_at_document (p_atd_Id IN NUMBER);

    PROCEDURE delete_at_document_all (p_pd_Id IN NUMBER);

    PROCEDURE save_at_document_attr (
        p_ATDA_ID           IN     AT_DOCUMENT_ATTR.ATDA_ID%TYPE,
        p_ATDA_ATD          IN     AT_DOCUMENT_ATTR.ATDA_ATD%TYPE,
        p_ATDA_AT           IN     AT_DOCUMENT_ATTR.ATDA_AT%TYPE,
        p_ATDA_NDA          IN     AT_DOCUMENT_ATTR.ATDA_NDA%TYPE,
        p_ATDA_VAL_INT      IN     AT_DOCUMENT_ATTR.ATDA_VAL_INT%TYPE,
        p_ATDA_VAL_SUM      IN     AT_DOCUMENT_ATTR.ATDA_VAL_SUM%TYPE,
        p_ATDA_VAL_ID       IN     AT_DOCUMENT_ATTR.ATDA_VAL_ID%TYPE,
        p_ATDA_VAL_DT       IN     AT_DOCUMENT_ATTR.ATDA_VAL_DT%TYPE,
        p_ATDA_VAL_STRING   IN     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,
        p_new_id               OUT AT_DOCUMENT_ATTR.ATDA_VAL_ID%TYPE);

    PROCEDURE Delete_at_Document_Attr (p_Id at_Document_Attr.atda_Id%TYPE);
END;
/


/* Formatted on 8/12/2025 5:48:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$DOCUMENTS
IS
    -- info:   Створення документа-рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа звернення
    -- note:
    PROCEDURE create_decision (
        p_pd_id        IN     pd_document.pdo_pd%TYPE,
        p_doc_id       IN     pd_document.pdo_doc%TYPE DEFAULT NULL,
        p_dh_id        IN     pd_document.pdo_dh%TYPE DEFAULT NULL,
        p_ap_id        IN     pd_document.pdo_ap%TYPE DEFAULT NULL,
        p_app_id       IN     pd_document.pdo_app%TYPE DEFAULT NULL,
        p_aps_id       IN     pd_document.pdo_aps%TYPE DEFAULT NULL,
        p_apd_id       IN     pd_document.pdo_apd%TYPE DEFAULT NULL,
        p_new_pdo_id      OUT pd_document.pdo_id%TYPE)
    IS
    BEGIN
        IF p_pd_id IS NOT NULL
        THEN
            --видалення існуючого документа з рішенням яке втратило свою актуальність
            UPDATE pd_document
               SET history_status = 'H'
             WHERE     pdo_pd = p_pd_id
                   AND pdo_ndt = 10051
                   AND history_status = 'A';

            INSERT INTO pd_document (pdo_id,
                                     pdo_doc,
                                     pdo_dh,
                                     pdo_ap,
                                     pdo_app,
                                     pdo_aps,
                                     pdo_apd,
                                     pdo_ndt,
                                     pdo_pd,
                                     history_status)
                 VALUES (NULL,
                         p_doc_id,
                         p_dh_id,
                         p_ap_id,
                         p_app_id,
                         p_aps_id,
                         p_apd_id,
                         10051,
                         p_pd_id,
                         'A')
              RETURNING pdo_id
                   INTO p_new_pdo_id;
        END IF;
    END;

    -- info:   Оновлення інформації по документу Е/А в документі рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    -- note:
    PROCEDURE add_decision_doc (p_pd_id    IN pd_document.pdo_pd%TYPE,
                                p_doc_id   IN pd_document.pdo_doc%TYPE,
                                p_dh_id    IN pd_document.pdo_dh%TYPE)
    IS
    BEGIN
        UPDATE pd_document
           SET pdo_doc = p_doc_id, pdo_dh = p_dh_id
         WHERE pdo_pd = p_pd_id AND pdo_ndt = 10051 AND history_status = 'A';
    END;

    -- info:   Оновлення інформації в документі рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа  звернення
    -- note:
    PROCEDURE add_decision_info (
        p_pd_id    IN pd_document.pdo_pd%TYPE,
        p_ap_id    IN pd_document.pdo_ap%TYPE DEFAULT NULL,
        p_app_id   IN pd_document.pdo_app%TYPE DEFAULT NULL,
        p_aps_id   IN pd_document.pdo_aps%TYPE DEFAULT NULL,
        p_apd_id   IN pd_document.pdo_apd%TYPE DEFAULT NULL)
    IS
    BEGIN
        UPDATE pd_document
           SET pdo_ap = COALESCE (p_ap_id, pdo_ap),
               pdo_app = COALESCE (p_app_id, pdo_app),
               pdo_aps = COALESCE (p_aps_id, pdo_aps),
               pdo_apd = COALESCE (p_apd_id, pdo_apd)
         WHERE pdo_pd = p_pd_id AND pdo_ndt = 10051 AND history_status = 'A';
    END;

    -- info:   Створення документа
    -- params: p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    --         p_ap_id - ідентифікатор звернення
    --         p_app_id - ідентифікатор учасника звернення
    --         p_aps_id - ідентифікатор послуги звернення
    --         p_apd_id - ідентифікатор документа звернення
    --         p_ndt_id - ідентифікатор типу документа
    --         p_pd_id - ідентифікатор рішення
    -- note:
    PROCEDURE save_pd_document (p_pdo_Id   IN     pd_document.pdo_id%TYPE,
                                p_doc_id   IN     pd_document.pdo_doc%TYPE,
                                p_dh_id    IN     pd_document.pdo_dh%TYPE,
                                p_ap_id    IN     pd_document.pdo_ap%TYPE,
                                p_app_id   IN     pd_document.pdo_app%TYPE,
                                p_aps_id   IN     pd_document.pdo_aps%TYPE,
                                p_apd_id   IN     pd_document.pdo_apd%TYPE,
                                p_ndt_id   IN     pd_document.pdo_ndt%TYPE,
                                p_pd_id    IN     pd_document.pdo_pd%TYPE,
                                p_new_id      OUT pd_document.pdo_id%TYPE)
    IS
    BEGIN
        IF (p_pdo_id IS NULL OR p_pdo_id < 0)
        THEN
            INSERT INTO pd_document (pdo_id,
                                     pdo_doc,
                                     pdo_dh,
                                     pdo_ap,
                                     pdo_app,
                                     pdo_aps,
                                     pdo_apd,
                                     pdo_ndt,
                                     pdo_pd,
                                     history_status)
                 VALUES (NULL,
                         p_doc_id,
                         p_dh_id,
                         p_ap_id,
                         p_app_id,
                         p_aps_id,
                         p_apd_id,
                         p_ndt_id,
                         p_pd_id,
                         'A')
              RETURNING pdo_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_pdo_id;

            UPDATE pd_document t
               SET                                      --t.pdo_pd = p_pdo_pd,
                                                      --t.pdo_doc = p_pdo_doc,
               t.pdo_apd = p_apd_id,
               --t.pdo_ap = p_pdo_ap,
               t.pdo_dh = p_dh_id,
               t.pdo_app = p_app_id,
               t.pdo_aps = p_aps_id,
               t.pdo_ndt = p_ndt_id
             --t.pdo_sc = p_pdo_sc
             WHERE t.pdo_id = p_pdo_id;
        END IF;
    END;

    PROCEDURE delete_pd_document (p_pdo_Id IN NUMBER)
    IS
    BEGIN
        UPDATE pd_document t
           SET t.history_status = 'H'
         WHERE t.pdo_id = p_pdo_id;

        UPDATE pd_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.pdoa_pdo = p_pdo_id;
    END;

    PROCEDURE delete_pd_document_all (p_pd_Id IN NUMBER)
    IS
    BEGIN
        UPDATE pd_document t
           SET t.history_status = 'H'
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (850,
                                 851,
                                 852,
                                 853,
                                 854);

        UPDATE pd_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.pdoa_pdo IN (SELECT pdo_id
                                FROM pd_document t
                               WHERE     t.pdo_pd = p_pd_id
                                     AND t.pdo_ndt IN (850,
                                                       851,
                                                       852,
                                                       853,
                                                       854));
    END;

    PROCEDURE Save_pd_Document_Attr (
        p_pdoa_Id           IN     pd_Document_Attr.pdoa_Id%TYPE,
        p_pdoa_pdo          IN     pd_Document_Attr.pdoa_pdo%TYPE,
        p_pdoa_pd           IN     pd_Document_Attr.pdoa_pd%TYPE,
        p_pdoa_Nda          IN     pd_Document_Attr.pdoa_Nda%TYPE,
        p_pdoa_Val_Int      IN     pd_Document_Attr.pdoa_Val_Int%TYPE DEFAULT NULL,
        p_pdoa_Val_Dt       IN     pd_Document_Attr.pdoa_Val_Dt%TYPE DEFAULT NULL,
        p_pdoa_Val_String   IN     pd_Document_Attr.pdoa_Val_String%TYPE DEFAULT NULL,
        p_pdoa_Val_Id       IN     pd_Document_Attr.pdoa_Val_Id%TYPE DEFAULT NULL,
        p_pdoa_Val_Sum      IN     pd_Document_Attr.pdoa_Val_Sum%TYPE DEFAULT NULL,
        p_New_Id               OUT pd_Document_Attr.pdoa_Id%TYPE)
    IS
    BEGIN
        IF p_pdoa_Id IS NULL OR p_pdoa_Id < 0
        THEN
            INSERT INTO pd_Document_Attr (Pdoa_Id,
                                          Pdoa_Pdo,
                                          Pdoa_Pd,
                                          Pdoa_Nda,
                                          Pdoa_Val_Int,
                                          Pdoa_Val_Sum,
                                          Pdoa_Val_Id,
                                          Pdoa_Val_Dt,
                                          Pdoa_Val_String,
                                          History_Status)
                 VALUES (0,
                         p_pdoa_pdo,
                         p_pdoa_pd,
                         p_pdoa_Nda,
                         p_pdoa_Val_Int,
                         p_pdoa_Val_Sum,
                         p_pdoa_Val_id,
                         p_pdoa_Val_dt,
                         p_pdoa_Val_String,
                         'A')
              RETURNING pdoa_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_pdoa_Id;

            UPDATE pd_Document_Attr
               SET pdoa_pd = p_pdoa_pd,
                   pdoa_pdo = p_pdoa_pdo,
                   pdoa_Nda = p_pdoa_Nda,
                   pdoa_Val_Id = p_pdoa_Val_Id,
                   pdoa_Val_Int = p_pdoa_Val_Int,
                   pdoa_Val_Dt = p_pdoa_Val_Dt,
                   pdoa_Val_String = p_pdoa_Val_String,
                   pdoa_Val_Sum = p_pdoa_Val_Sum
             WHERE pdoa_Id = p_pdoa_Id;
        END IF;
    END;

    PROCEDURE Delete_pd_Document_Attr (p_Id pd_Document_Attr.pdoa_Id%TYPE)
    IS
    BEGIN
        UPDATE pd_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.pdoa_Id = p_Id;
    END;


    ------------------------------------------------------------
    --------------- Документи по актах -------------------------

    PROCEDURE save_at_document (p_ATD_ID    IN     AT_DOCUMENT.ATD_ID%TYPE,
                                p_ATD_AT    IN     AT_DOCUMENT.ATD_AT%TYPE,
                                p_ATD_NDT   IN     AT_DOCUMENT.ATD_NDT%TYPE,
                                p_ATD_ATS   IN     AT_DOCUMENT.ATD_ATS%TYPE,
                                p_ATD_DOC   IN     AT_DOCUMENT.ATD_DOC%TYPE,
                                p_ATD_DH    IN     AT_DOCUMENT.ATD_DH%TYPE,
                                p_new_id       OUT AT_DOCUMENT.ATD_ID%TYPE)
    IS
    BEGIN
        IF p_ATD_ID IS NULL
        THEN
            INSERT INTO AT_DOCUMENT (ATD_AT,
                                     ATD_NDT,
                                     ATD_ATS,
                                     ATD_DOC,
                                     ATD_DH,
                                     HISTORY_STATUS)
                 VALUES (p_ATD_AT,
                         p_ATD_NDT,
                         p_ATD_ATS,
                         p_ATD_DOC,
                         p_ATD_DH,
                         'A')
              RETURNING ATD_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_ATD_ID;

            UPDATE AT_DOCUMENT
               SET ATD_AT = p_ATD_AT,
                   ATD_NDT = p_ATD_NDT,
                   ATD_ATS = p_ATD_ATS,
                   ATD_DOC = p_ATD_DOC,
                   ATD_DH = p_ATD_DH
             WHERE ATD_ID = p_ATD_ID;
        END IF;
    END;


    PROCEDURE delete_at_document (p_atd_Id IN NUMBER)
    IS
    BEGIN
        UPDATE at_document t
           SET t.history_status = 'H'
         WHERE t.atd_id = p_atd_id;

        UPDATE at_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.atda_atd = p_atd_Id;
    END;

    PROCEDURE delete_at_document_all (p_pd_Id IN NUMBER)
    IS
    BEGIN
        UPDATE pd_document t
           SET t.history_status = 'H'
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (850,
                                 851,
                                 852,
                                 853,
                                 854);

        UPDATE pd_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.pdoa_pdo IN (SELECT pdo_id
                                FROM pd_document t
                               WHERE     t.pdo_pd = p_pd_id
                                     AND t.pdo_ndt IN (850,
                                                       851,
                                                       852,
                                                       853,
                                                       854));
    END;

    PROCEDURE save_at_document_attr (
        p_ATDA_ID           IN     AT_DOCUMENT_ATTR.ATDA_ID%TYPE,
        p_ATDA_ATD          IN     AT_DOCUMENT_ATTR.ATDA_ATD%TYPE,
        p_ATDA_AT           IN     AT_DOCUMENT_ATTR.ATDA_AT%TYPE,
        p_ATDA_NDA          IN     AT_DOCUMENT_ATTR.ATDA_NDA%TYPE,
        p_ATDA_VAL_INT      IN     AT_DOCUMENT_ATTR.ATDA_VAL_INT%TYPE,
        p_ATDA_VAL_SUM      IN     AT_DOCUMENT_ATTR.ATDA_VAL_SUM%TYPE,
        p_ATDA_VAL_ID       IN     AT_DOCUMENT_ATTR.ATDA_VAL_ID%TYPE,
        p_ATDA_VAL_DT       IN     AT_DOCUMENT_ATTR.ATDA_VAL_DT%TYPE,
        p_ATDA_VAL_STRING   IN     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,
        p_new_id               OUT AT_DOCUMENT_ATTR.ATDA_VAL_ID%TYPE)
    IS
    BEGIN
        IF p_ATDA_ID IS NULL
        THEN
            INSERT INTO AT_DOCUMENT_ATTR (ATDA_ID,
                                          ATDA_ATD,
                                          ATDA_AT,
                                          ATDA_NDA,
                                          ATDA_VAL_INT,
                                          ATDA_VAL_ID,
                                          ATDA_VAL_SUM,
                                          ATDA_VAL_DT,
                                          ATDA_VAL_STRING,
                                          HISTORY_STATUS)
                 VALUES (p_ATDA_ID,
                         p_ATDA_ATD,
                         p_ATDA_AT,
                         p_ATDA_NDA,
                         p_ATDA_VAL_INT,
                         p_ATDA_VAL_ID,
                         p_ATDA_VAL_SUM,
                         p_ATDA_VAL_DT,
                         p_ATDA_VAL_STRING,
                         'A')
              RETURNING ATDA_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_ATDA_ID;

            UPDATE AT_DOCUMENT_ATTR
               SET ATDA_ID = p_ATDA_ID,
                   ATDA_ATD = p_ATDA_ATD,
                   ATDA_AT = p_ATDA_AT,
                   ATDA_NDA = p_ATDA_NDA,
                   ATDA_VAL_INT = p_ATDA_VAL_INT,
                   ATDA_VAL_ID = p_ATDA_VAL_ID,
                   ATDA_VAL_SUM = p_ATDA_VAL_SUM,
                   ATDA_VAL_DT = p_ATDA_VAL_DT,
                   ATDA_VAL_STRING = p_ATDA_VAL_STRING
             WHERE ATDA_ID = p_ATDA_ID;
        END IF;
    END;


    PROCEDURE Delete_at_Document_Attr (p_Id at_Document_Attr.atda_Id%TYPE)
    IS
    BEGIN
        UPDATE at_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.atda_Id = p_Id;
    END;
END;
/