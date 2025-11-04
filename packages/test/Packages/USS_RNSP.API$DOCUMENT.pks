/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$DOCUMENT
IS
    -- Author  : LESHA
    -- Created : 12.04.2022 15:16:20
    -- Purpose :

    -------------------------------------------
    --Джерела надходження даних
    -------------------------------------------
    c_Src_Uss    CONSTANT VARCHAR2 (10) := 'USS';
    c_Src_Vst    CONSTANT VARCHAR2 (10) := 'VST';
    c_Src_Rnsp   CONSTANT VARCHAR2 (10) := 'RNSP';

    --=============================================--
    FUNCTION Get_Apda_Val_String (p_Ap_Id     IN Appeal.Ap_Id%TYPE,
                                  p_apd_ndt   IN ap_Document.apd_Ndt%TYPE,
                                  p_Nda_Id    IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Apd_aps_Str (p_apd_aps   IN Ap_Document.apd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Apd_aps_sum (p_apd_aps   IN Ap_Document.apd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_rnd_aps_Str (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_rnd_aps_sum (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_rnd_aps_Int (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Rnda_Str (p_Rnd_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    --=============================================--
    --  Это для получения атрибутов через apd_id и Nda_id
    --=============================================--
    FUNCTION Get_Apda_Str (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Apda_dt (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                          p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    FUNCTION Get_Apda_sum (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Apda_int (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Apda_id (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                          p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    --=============================================--
    --  Інтерфейси  до Кт_Document ....
    --=============================================--
    PROCEDURE Save_Document (p_rnd_Id      IN     rn_Document.rnd_Id%TYPE,
                             p_rnd_Rnspm   IN     rn_Document.Rnd_Rnspm%TYPE,
                             p_rnd_Ndt     IN     rn_Document.rnd_Ndt%TYPE,
                             p_rnd_Doc     IN     rn_Document.rnd_Doc%TYPE,
                             p_rnd_St      IN     rn_Document.Rnd_St%TYPE,
                             p_New_Id         OUT rn_Document.rnd_Id%TYPE,
                             p_Com_Wu      IN     NUMBER,
                             p_rnd_Dh      IN     rn_Document.rnd_Dh%TYPE);

    PROCEDURE Save_Document (p_rnd_Id    IN     rn_Document.rnd_Id%TYPE,
                             p_rnd_Ap    IN     rn_Document.rnd_Ap%TYPE,
                             p_rnd_Ndt   IN     rn_Document.rnd_Ndt%TYPE,
                             p_rnd_Doc   IN     rn_Document.rnd_Doc%TYPE,
                             p_rnd_App   IN     rn_Document.rnd_App%TYPE,
                             p_New_Id       OUT rn_Document.rnd_Id%TYPE,
                             p_Com_Wu    IN     NUMBER,
                             p_rnd_Dh    IN     rn_Document.rnd_Dh%TYPE,
                             p_rnd_Aps   IN     rn_Document.rnd_Aps%TYPE,
                             p_rnd_Src   IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Delete_Document (p_Id rn_Document.rnd_Id%TYPE);

    --=============================================--
    PROCEDURE Save_Document_Attr (
        p_rnda_Id           IN     Rn_Document_Attr.rnda_Id%TYPE,
        p_rnda_rnd          IN     Rn_Document_Attr.rnda_rnd%TYPE,
        p_rnda_Nda          IN     Rn_Document_Attr.rnda_Nda%TYPE,
        p_rnda_Val_Int      IN     Rn_Document_Attr.rnda_Val_Int%TYPE,
        p_rnda_Val_Dt       IN     Rn_Document_Attr.rnda_Val_Dt%TYPE,
        p_rnda_Val_String   IN     Rn_Document_Attr.rnda_Val_String%TYPE,
        p_rnda_Val_Id       IN     Rn_Document_Attr.rnda_Val_Id%TYPE,
        p_rnda_Val_Sum      IN     Rn_Document_Attr.rnda_Val_Sum%TYPE,
        p_New_Id               OUT Rn_Document_Attr.rnda_Val_Id%TYPE);

    PROCEDURE Delete_Document_Attr (p_Id rn_Document_Attr.rnda_Val_Id%TYPE);

    --=============================================--

    FUNCTION Get_Attr_Val_String (p_Ap_Id     IN Appeal.Ap_Id%TYPE,
                                  p_rnd_ndt   IN Rn_Document.rnd_Ndt%TYPE,
                                  p_Nda_Id    IN NUMBER)
        RETURN VARCHAR2;

    --=============================================--
    PROCEDURE Get_UserPIB (p_p   OUT VARCHAR2,
                           p_i   OUT VARCHAR2,
                           p_b   OUT VARCHAR2);

    PROCEDURE Get_UserOPFU (p_OPFU_cod    OUT VARCHAR2,
                            p_OPFU_name   OUT VARCHAR2);

    --=============================================--
    --PROCEDURE Copy_Document2Rn (p_ap_id NUMBER);

    PROCEDURE Update_UserPIB (p_rnd_id Rn_Document.rnd_id%TYPE);

    PROCEDURE Create_document730 (p_ap_id        appeal.ap_id%TYPE,
                                  p_rnd_id   OUT rn_document.rnd_id%TYPE);

    PROCEDURE Update_document730 (p_rnd_id   rn_document.rnd_id%TYPE,
                                  p_doc_id   rn_document.rnd_doc%TYPE,
                                  p_dh_id    rn_document.rnd_dh%TYPE);

    PROCEDURE Update_document730_pib (p_ap_id Rn_Document.rnd_ap%TYPE);

    PROCEDURE Update_appeal_ap_ext_ident (
        p_ap_id           appeal.ap_id%TYPE,
        p_ext_ident   OUT appeal.ap_ext_ident%TYPE);

    PROCEDURE Copy_appeal_2_rnsp (p_ap_id          appeal.ap_id%TYPE,
                                  p_Ap_St          appeal.Ap_St%TYPE,
                                  p_rnspm_id       rnsp_main.rnspm_id%TYPE,
                                  p_old_rnsps_id   rnsp_state.rnsps_id%TYPE,
                                  IS_RAISE         BOOLEAN);

    -- Перезавантаження атрибутів по послугах
    PROCEDURE MERGE_dict_service (p_ap_id NUMBER);

    PROCEDURE Save_appeal_2_rnsp (p_ap_id appeal.ap_id%TYPE);

    --=============================================--
    FUNCTION appeal_info (p_id NUMBER)
        RETURN CLOB;

    --=============================================--
    PROCEDURE dbms_output_appeal_info (p_id NUMBER);
--=============================================--
END API$Document;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$DOCUMENT
IS
    --=============================================--
    FUNCTION Get_Apda_Val_String (p_Ap_Id     IN Appeal.Ap_Id%TYPE,
                                  p_apd_ndt   IN ap_Document.apd_Ndt%TYPE,
                                  p_Nda_Id    IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.apda_Val_String)
          INTO l_Result
          FROM ap_Document  apd
               JOIN ap_Document_Attr a
                   ON     a.apda_apd = apd.apd_id
                      AND a.apda_nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE     apd.apd_ap = p_Ap_Id
               AND apd.apd_ndt = p_apd_ndt
               AND apd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    --  Это для получения атрибутов через услугу и код типа атрибута
    --=============================================--
    FUNCTION Get_Apd_aps_Str (p_apd_aps   IN Ap_Document.apd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.apda_Val_String)
          INTO l_Result
          FROM ap_Document  apd
               JOIN ap_Document_Attr a
                   ON a.apda_apd = apd.apd_id AND a.History_Status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON nda_id = apda_nda
               JOIN uss_ndi.v_ndi_param_type
                   ON pt_id = nda_pt AND pt_code = UPPER (p_pt_code)
         WHERE apd.apd_aps = p_apd_aps AND apd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Apd_aps_sum (p_apd_aps   IN Ap_Document.apd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Sum)
          INTO l_Result
          FROM ap_Document  apd
               JOIN ap_Document_Attr a
                   ON a.apda_apd = apd.apd_id AND a.History_Status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON nda_id = apda_nda
               JOIN uss_ndi.v_ndi_param_type
                   ON pt_id = nda_pt AND pt_code = UPPER (p_pt_code)
         WHERE apd.apd_aps = p_apd_aps AND apd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    --  Это для получения атрибутов через услугу и код типа атрибута
    --=============================================--
    FUNCTION Get_rnd_aps_Str (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.rnda_Val_String)
          INTO l_Result
          FROM rn_Document  rnd
               JOIN rn_Document_Attr a
                   ON a.rnda_rnd = rnd.rnd_id AND a.History_Status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON nda_id = rnda_nda
               JOIN uss_ndi.v_ndi_param_type
                   ON pt_id = nda_pt AND pt_code = UPPER (p_pt_code)
         WHERE rnd.rnd_aps = p_rnd_aps AND rnd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_rnd_aps_sum (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.rnda_Val_Sum)
          INTO l_Result
          FROM rn_Document  rnd
               JOIN rn_Document_Attr a
                   ON a.rnda_rnd = rnd.rnd_id AND a.History_Status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON nda_id = rnda_nda
               JOIN uss_ndi.v_ndi_param_type
                   ON pt_id = nda_pt AND pt_code = UPPER (p_pt_code)
         WHERE rnd.rnd_aps = p_rnd_aps AND rnd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_rnd_aps_Int (p_rnd_aps   IN rn_Document.rnd_aps%TYPE,
                              p_pt_code   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Rnda_Val_Int)
          INTO l_Result
          FROM rn_Document  rnd
               JOIN rn_Document_Attr a
                   ON a.rnda_rnd = rnd.rnd_id AND a.History_Status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON nda_id = rnda_nda
               JOIN uss_ndi.v_ndi_param_type
                   ON pt_id = nda_pt AND pt_code = UPPER (p_pt_code)
         WHERE rnd.rnd_aps = p_rnd_aps AND rnd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Rnda_Str (p_Rnd_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.Rnda_Val_String)
          INTO l_Result
          FROM Rn_Document_Attr a
         WHERE     a.Rnda_Rnd = p_Rnd_Id
               AND a.History_Status = 'A'
               AND a.Rnda_Nda = p_Nda_Id;

        RETURN l_Result;
    END;

    --=============================================--
    --  Это для получения атрибутов
    --=============================================--
    FUNCTION Get_Apda_Str (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.apda_Val_String)
          INTO l_Result
          FROM ap_Document_Attr a
         WHERE     a.apda_apd = p_apda_apd
               AND a.apda_nda = p_apda_nda
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Apda_dt (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                          p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (a.apda_Val_dt)
          INTO l_Result
          FROM ap_Document_Attr a
         WHERE     a.apda_apd = p_apda_apd
               AND a.apda_nda = p_apda_nda
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Apda_sum (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Sum)
          INTO l_Result
          FROM ap_Document_Attr a
         WHERE     a.apda_apd = p_apda_apd
               AND a.apda_nda = p_apda_nda
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Apda_int (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                           p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Int)
          INTO l_Result
          FROM ap_Document_Attr a
         WHERE     a.apda_apd = p_apda_apd
               AND a.apda_nda = p_apda_nda
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION Get_Apda_id (p_apda_apd   IN Ap_Document_Attr.Apda_Apd%TYPE,
                          p_apda_nda   IN Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM ap_Document_Attr a
         WHERE     a.apda_apd = p_apda_apd
               AND a.apda_nda = p_apda_nda
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    FUNCTION get_ap_doc_str (p_ap        ap_document.apd_ap%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_nda       ap_document_attr.apda_nda%TYPE,
                             p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
         WHERE     apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND ap_document.history_status = 'A';

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --=============================================--
    PROCEDURE Copy_Document2Rn (p_ap_id NUMBER)
    IS
        l_rnspm_id   NUMBER (10);
    BEGIN
        SELECT MAX (appeal.ap_ext_ident)
          INTO l_rnspm_id
          FROM appeal
         WHERE ap_id = p_ap_id;

        IF p_ap_id IS NULL
        THEN
            Raise_Application_Error (-20001,
                                     'lesha >> ещё не установлено обращение');
        END IF;

        IF l_rnspm_id IS NULL
        THEN
            Raise_Application_Error (
                -20002,
                'lesha >> ещё не установлена связь с карточкой');
        END IF;

        MERGE INTO uss_rnsp.rn_document
             USING (SELECT apd_id             AS x_apd_id,
                           apd_ap             AS x_apd_ap,
                           apd_app            AS x_apd_app,
                           apd_ndt            AS x_apd_ndt,
                           apd_doc            AS x_apd_doc,
                           apd_dh             AS x_apd_dh,
                           history_status     AS x_history_status,
                           apd_vf             AS x_apd_vf,
                           apd_aps            AS x_apd_aps
                      FROM ap_document
                     WHERE apd_ap = p_ap_id)
                ON (x_apd_id = rnd_apd)
        WHEN MATCHED
        THEN
            UPDATE SET rnd_app = x_apd_app,
                       rnd_ndt = x_apd_ndt,
                       rnd_doc = x_apd_doc,
                       rnd_dh = x_apd_dh,
                       rnd_aps = x_apd_aps,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (rnd_id,
                        rnd_ap,
                        rnd_app,
                        rnd_ndt,
                        rnd_aps,
                        rnd_doc,
                        rnd_dh,
                        history_status,
                        rnd_apd,
                        rnd_rnspm)
                VALUES (NULL,
                        x_apd_ap,
                        x_apd_app,
                        x_apd_ndt,
                        x_apd_aps,
                        x_apd_doc,
                        x_apd_dh,
                        x_history_status,
                        x_apd_id,
                        l_rnspm_id);

        MERGE INTO uss_rnsp.rn_document_attr
             USING (SELECT apda_id
                               AS x_apda_id,
                           apda_apd
                               AS x_apda_apd,
                           apda_nda
                               AS x_apda_nda,
                           apda_val_int
                               AS x_apda_val_int,
                           apda_val_sum
                               AS x_apda_val_sum,
                           apda_val_id
                               AS x_apda_val_id,
                           apda_val_dt
                               AS x_apda_val_dt,
                           apda_val_string
                               AS x_apda_val_string,
                           ap_document_attr.history_status
                               AS x_history_status,
                           rnd_id
                               AS x_rnd_id
                      FROM ap_document_attr
                           LEFT JOIN uss_rnsp.rn_document
                               ON apda_apd = rnd_apd
                     WHERE apda_ap = p_ap_id)
                ON (rnda_apda = x_apda_id)
        WHEN MATCHED
        THEN
            UPDATE SET rnda_nda = x_apda_nda,
                       rnda_val_int = x_apda_val_int,
                       rnda_val_sum = x_apda_val_sum,
                       rnda_val_id = x_apda_val_id,
                       rnda_val_dt = x_apda_val_dt,
                       rnda_val_string = x_apda_val_string,
                       history_status = x_history_status
        WHEN NOT MATCHED
        THEN
            INSERT     (rnda_id,
                        rnda_rnd,
                        rnda_nda,
                        rnda_val_int,
                        rnda_val_sum,
                        rnda_val_id,
                        rnda_val_dt,
                        rnda_val_string,
                        history_status,
                        rnda_apda)
                VALUES (NULL,
                        x_rnd_id,
                        x_apda_nda,
                        x_apda_val_int,
                        x_apda_val_sum,
                        x_apda_val_id,
                        x_apda_val_dt,
                        x_apda_val_string,
                        x_history_status,
                        x_apda_id);


        UPDATE uss_rnsp.rn_document_attr rnda
           SET rnda.HISTORY_STATUS = 'H'
         WHERE     rnda.HISTORY_STATUS = 'A'
               AND rnda.rnda_apda IS NULL
               AND rnda.rnda_rnd IN
                       (SELECT rnd.rnd_id
                          FROM uss_rnsp.rn_document rnd
                         WHERE     rnd_ndt NOT IN (700, 730, 740)
                               AND rnd_ap = p_ap_id);
    --rnda_id, rnda_rnd, rnda_nda, rnda_val_int, rnda_val_sum, rnda_val_id, rnda_val_dt, rnda_val_string, history_status, rnda_apda
    /*
    INSERT INTO uss_rnsp.rn_document_attr(rnda_id,
                                          rnda_rnd,
                                          rnda_nda,
                                          rnda_val_int,
                                          rnda_val_sum,
                                          rnda_val_id,
                                          rnda_val_dt,
                                          rnda_val_string,
                                          history_status,
                                          rnda_apda)
    */
    END;

    --=============================================--
    PROCEDURE Save_Document (p_rnd_Id      IN     rn_Document.rnd_Id%TYPE,
                             p_rnd_Rnspm   IN     rn_Document.Rnd_Rnspm%TYPE,
                             p_rnd_Ndt     IN     rn_Document.rnd_Ndt%TYPE,
                             p_rnd_Doc     IN     rn_Document.rnd_Doc%TYPE,
                             p_rnd_St      IN     rn_Document.Rnd_St%TYPE,
                             p_New_Id         OUT rn_Document.rnd_Id%TYPE,
                             p_Com_Wu      IN     NUMBER,
                             p_rnd_Dh      IN     rn_Document.rnd_Dh%TYPE)
    IS
        l_New_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        IF p_rnd_Id IS NULL OR p_rnd_Id < 0
        THEN
            INSERT INTO rn_Document (rnd_Ndt,
                                     rnd_Doc,
                                     rnd_Dh,
                                     History_Status,
                                     rnd_Rnspm,
                                     rnd_St)
                 VALUES (p_rnd_Ndt,
                         p_rnd_Doc,
                         p_rnd_Dh,
                         'A',
                         p_rnd_Rnspm,
                         p_rnd_St)
              RETURNING rnd_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_rnd_Id;

            UPDATE rn_Document
               SET rnd_Ndt = p_rnd_Ndt,
                   rnd_Doc = p_rnd_Doc,
                   rnd_Dh = p_rnd_Dh,
                   rnd_St = p_rnd_St
             WHERE rnd_Id = p_rnd_Id;

            IF p_rnd_Doc IS NOT NULL
            THEN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => p_rnd_Doc,
                    p_Doc_Ndt         => p_rnd_Ndt,
                    p_Doc_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_New_Id          => l_New_Id);

                l_Dh_Id :=
                    Uss_Doc.Api$documents.Get_Last_Doc_Hist (
                        p_Dh_Doc   => p_rnd_Doc);
                --raise_application_error(-20013, p_rnd_Src);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => l_Dh_Id,
                    p_Dh_Doc         => p_rnd_Doc,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => p_rnd_Ndt,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => p_Com_Wu,
                    p_Dh_Src         => c_Src_Rnsp,
                    p_New_Id         => l_Dh_Id);
            END IF;
        END IF;
    END;

    --=============================================--
    PROCEDURE Save_Document (p_rnd_Id    IN     rn_Document.rnd_Id%TYPE,
                             p_rnd_Ap    IN     rn_Document.rnd_Ap%TYPE,
                             p_rnd_Ndt   IN     rn_Document.rnd_Ndt%TYPE,
                             p_rnd_Doc   IN     rn_Document.rnd_Doc%TYPE,
                             p_rnd_App   IN     rn_Document.rnd_App%TYPE,
                             p_New_Id       OUT rn_Document.rnd_Id%TYPE,
                             p_Com_Wu    IN     NUMBER,
                             p_rnd_Dh    IN     rn_Document.rnd_Dh%TYPE,
                             p_rnd_Aps   IN     rn_Document.rnd_Aps%TYPE,
                             p_rnd_Src   IN     VARCHAR2 DEFAULT NULL)
    IS
        l_New_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        IF p_rnd_Id IS NULL OR p_rnd_Id < 0
        THEN
            INSERT INTO rn_Document (rnd_Ap,
                                     rnd_Ndt,
                                     rnd_Doc,
                                     rnd_App,
                                     rnd_Dh,
                                     History_Status,
                                     rnd_Aps)
                 VALUES (p_rnd_Ap,
                         p_rnd_Ndt,
                         p_rnd_Doc,
                         p_rnd_App,
                         p_rnd_Dh,
                         'A',
                         p_rnd_Aps)
              RETURNING rnd_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_rnd_Id;

            UPDATE rn_Document
               SET rnd_Ndt = p_rnd_Ndt,
                   rnd_Doc = p_rnd_Doc,
                   rnd_App = p_rnd_App,
                   rnd_Dh = p_rnd_Dh,
                   rnd_Aps = p_rnd_Aps
             WHERE rnd_Id = p_rnd_Id;

            IF p_rnd_Doc IS NOT NULL
            THEN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => p_rnd_Doc,
                    p_Doc_Ndt         => p_rnd_Ndt,
                    p_Doc_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_New_Id          => l_New_Id);

                l_Dh_Id :=
                    Uss_Doc.Api$documents.Get_Last_Doc_Hist (
                        p_Dh_Doc   => p_rnd_Doc);
                --raise_application_error(-20013, p_rnd_Src);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => l_Dh_Id,
                    p_Dh_Doc         => p_rnd_Doc,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => p_rnd_Ndt,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   =>
                        Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => p_Com_Wu,
                    p_Dh_Src         => NVL (p_rnd_Src, c_Src_Vst),
                    p_New_Id         => l_Dh_Id);
            END IF;
        END IF;
    END;

    PROCEDURE Delete_Document (p_Id rn_Document.rnd_Id%TYPE)
    IS
    BEGIN
        UPDATE rn_Document d
           SET d.History_Status = 'H'
         WHERE rnd_Id = p_Id;

        UPDATE rn_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.rnda_rnd = p_Id;
    END;

    --=============================================--
    PROCEDURE Save_Document_Attr (
        p_rnda_Id           IN     Rn_Document_Attr.rnda_Id%TYPE,
        p_rnda_rnd          IN     Rn_Document_Attr.rnda_rnd%TYPE,
        p_rnda_Nda          IN     Rn_Document_Attr.rnda_Nda%TYPE,
        p_rnda_Val_Int      IN     Rn_Document_Attr.rnda_Val_Int%TYPE,
        p_rnda_Val_Dt       IN     Rn_Document_Attr.rnda_Val_Dt%TYPE,
        p_rnda_Val_String   IN     Rn_Document_Attr.rnda_Val_String%TYPE,
        p_rnda_Val_Id       IN     Rn_Document_Attr.rnda_Val_Id%TYPE,
        p_rnda_Val_Sum      IN     Rn_Document_Attr.rnda_Val_Sum%TYPE,
        p_New_Id               OUT Rn_Document_Attr.rnda_Val_Id%TYPE)
    IS
    BEGIN
        IF p_rnda_Id IS NULL OR p_rnda_Id < 0
        THEN
            INSERT INTO Rn_Document_Attr (rnda_Id,
                                          rnda_rnd,
                                          rnda_Nda,
                                          rnda_Val_Id,
                                          rnda_Val_Int,
                                          rnda_Val_Dt,
                                          rnda_Val_String,
                                          rnda_Val_Sum,
                                          History_Status)
                 VALUES (0,
                         p_rnda_rnd,
                         p_rnda_Nda,
                         p_rnda_Val_Id,
                         p_rnda_Val_Int,
                         p_rnda_Val_Dt,
                         p_rnda_Val_String,
                         p_rnda_Val_Sum,
                         'A')
              RETURNING rnda_Val_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_rnda_Val_Id;

            UPDATE Rn_Document_Attr
               SET rnda_rnd = p_rnda_rnd,
                   rnda_Nda = p_rnda_Nda,
                   rnda_Val_Id = p_rnda_Val_Id,
                   rnda_Val_Int = p_rnda_Val_Int,
                   rnda_Val_Dt = p_rnda_Val_Dt,
                   rnda_Val_String = p_rnda_Val_String,
                   rnda_Val_Sum = p_rnda_Val_Sum
             WHERE rnda_Id = p_rnda_Id;
        END IF;
    END;

    --=============================================--
    PROCEDURE Delete_Document_Attr (p_Id rn_Document_Attr.rnda_Val_Id%TYPE)
    IS
    BEGIN
        UPDATE rn_Document_Attr a
           SET a.History_Status = 'H'
         WHERE a.rnda_Id = p_Id;
    END;

    --=============================================--
    FUNCTION Get_Attr_Val_String (p_Ap_Id     IN Appeal.Ap_Id%TYPE,
                                  p_rnd_ndt   IN Rn_Document.rnd_Ndt%TYPE,
                                  p_Nda_Id    IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a.rnda_Val_String)
          INTO l_Result
          FROM Rn_Document  rnd
               JOIN Rn_Document_Attr a
                   ON     a.rnda_rnd = rnd.rnd_id
                      AND a.rnda_nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE     rnd.rnd_ap = p_Ap_Id
               AND rnd.rnd_ndt = p_rnd_ndt
               AND rnd.History_Status = 'A';

        RETURN l_Result;
    END;

    --=============================================--
    PROCEDURE Save_Document_Attr_Str (
        p_rnda_Id           IN Rn_Document_Attr.rnda_Id%TYPE,
        p_rnda_rnd          IN Rn_Document_Attr.rnda_rnd%TYPE,
        p_rnda_Nda          IN Rn_Document_Attr.rnda_Nda%TYPE,
        p_rnda_Val_String   IN Rn_Document_Attr.rnda_Val_String%TYPE)
    AS
        L_New_Id   Rn_Document_Attr.rnda_Val_Id%TYPE;
    BEGIN
        Save_Document_Attr (p_rnda_Id           => p_rnda_Id,
                            p_rnda_rnd          => p_rnda_rnd,
                            p_rnda_Nda          => p_rnda_Nda,
                            p_rnda_Val_Int      => NULL,
                            p_rnda_Val_Dt       => NULL,
                            p_rnda_Val_String   => p_rnda_Val_String,
                            p_rnda_Val_Id       => NULL,
                            p_rnda_Val_Sum      => NULL,
                            p_New_Id            => L_New_Id);
    END;

    --=============================================--
    PROCEDURE Save_Document_Attr_Int (
        p_rnda_Id        IN Rn_Document_Attr.rnda_Id%TYPE,
        p_rnda_rnd       IN Rn_Document_Attr.rnda_rnd%TYPE,
        p_rnda_Nda       IN Rn_Document_Attr.rnda_Nda%TYPE,
        p_rnda_Val_Int   IN Rn_Document_Attr.rnda_Val_Int%TYPE)
    AS
        L_New_Id   Rn_Document_Attr.rnda_Val_Id%TYPE;
    BEGIN
        Save_Document_Attr (p_rnda_Id           => p_rnda_Id,
                            p_rnda_rnd          => p_rnda_rnd,
                            p_rnda_Nda          => p_rnda_Nda,
                            p_rnda_Val_Int      => p_rnda_Val_Int,
                            p_rnda_Val_Dt       => NULL,
                            p_rnda_Val_String   => NULL,
                            p_rnda_Val_Id       => NULL,
                            p_rnda_Val_Sum      => NULL,
                            p_New_Id            => L_New_Id);
    END;

    --=============================================--
    PROCEDURE Save_Document_Attr_DT (
        p_rnda_Id       IN Rn_Document_Attr.rnda_Id%TYPE,
        p_rnda_rnd      IN Rn_Document_Attr.rnda_rnd%TYPE,
        p_rnda_Nda      IN Rn_Document_Attr.rnda_Nda%TYPE,
        p_rnda_Val_dt   IN Rn_Document_Attr.rnda_Val_dt%TYPE)
    AS
        L_New_Id   Rn_Document_Attr.rnda_Val_Id%TYPE;
    BEGIN
        Save_Document_Attr (p_rnda_Id           => p_rnda_Id,
                            p_rnda_rnd          => p_rnda_rnd,
                            p_rnda_Nda          => p_rnda_Nda,
                            p_rnda_Val_Int      => NULL,
                            p_rnda_Val_Dt       => p_rnda_Val_dt,
                            p_rnda_Val_String   => NULL,
                            p_rnda_Val_Id       => NULL,
                            p_rnda_Val_Sum      => NULL,
                            p_New_Id            => L_New_Id);
    END;

    --=============================================--
    PROCEDURE Get_UserEnv (p_p           OUT VARCHAR2,
                           p_i           OUT VARCHAR2,
                           p_b           OUT VARCHAR2,
                           p_OPFU_cod    OUT VARCHAR2,
                           p_OPFU_name   OUT VARCHAR2)
    IS
        l_user_info      SYS_REFCURSOR;
        l_user_roles     SYS_REFCURSOR;
        WU_ID            NUMBER (14);
        WU_WUT           NUMBER (14);
        WU_ORG           NUMBER (5);
        WU_ORG_ORG       NUMBER (5);
        WU_TRC           VARCHAR2 (10);
        WU_LOGIN         VARCHAR2 (30);
        WU_PIB           VARCHAR2 (255);
        WU_NUMID         VARCHAR2 (10);
        WUT_CODE         VARCHAR2 (255);
        WUT_NAME         VARCHAR2 (255);
        WU_ORG_TO        VARCHAR2 (255);
        WU_org_acc_org   VARCHAR2 (255);
    BEGIN
        /*
              select wu_id,
                     wu_wut,
                     wu_org,
                     (select org_org from v$v_opfu_all where org_id = wu_org ) wu_org_org,
                     (select org_acc_org from v_opfu where org_id = wu_org ) wu_org_acc_org,
                     wu_trc,
                     wu_login,
                     wu_pib,
                     wu_numid,
                     wut_code,
                     wut_name,
                     (select org_to from v$v_opfu_all where org_id = wu_org ) wu_org_to
        */
        --uss_rnsp.uss_rnsp_context.SetDnetRnspContext(p_session => '112560-4645647407779588056');
        IKIS_SYSWEB.IKIS_DNET_AUTH.GetUserInfo (
            p_session_id   => uss_rnsp.uss_rnsp_context.Getcontext ('session'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_info
                INTO WU_ID,
                     WU_WUT,
                     WU_ORG,
                     WU_ORG_ORG,
                     WU_ORG_ACC_ORG,
                     WU_TRC,
                     WU_LOGIN,
                     WU_PIB,
                     WU_NUMID,
                     WUT_CODE,
                     WUT_NAME,
                     WU_ORG_TO;

            EXIT WHEN l_user_info%NOTFOUND;
        --      DBMS_OUTPUT.PUT_LINE ( WU_PIB||'      '||WUT_NAME );
        END LOOP;

        CLOSE l_user_info;

        p_p :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           1);
        p_i :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           2);
        p_b :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           3);
        p_OPFU_cod := WU_ORG;

        SELECT MAX (Opfu.Org_Name)
          INTO p_OPFU_name
          FROM v_Opfu Opfu
         WHERE Opfu.Org_Id = WU_ORG;
    END;

    --=============================================--
    PROCEDURE Get_UserPIB (p_p   OUT VARCHAR2,
                           p_i   OUT VARCHAR2,
                           p_b   OUT VARCHAR2)
    IS
        l_OPFU_cod    VARCHAR2 (250);
        l_OPFU_name   VARCHAR2 (250);
    BEGIN
        Get_UserEnv (p_p,
                     p_i,
                     p_b,
                     l_OPFU_cod,
                     l_OPFU_name);
    END;

    --=============================================--
    PROCEDURE Get_UserOPFU (p_OPFU_cod    OUT VARCHAR2,
                            p_OPFU_name   OUT VARCHAR2)
    IS
        l_p   VARCHAR2 (250);
        l_i   VARCHAR2 (250);
        l_b   VARCHAR2 (250);
    BEGIN
        Get_UserEnv (l_p,
                     l_i,
                     l_b,
                     p_OPFU_cod,
                     p_OPFU_name);
    END;

    --=============================================--
    PROCEDURE Set_UserPIB (p_rnd_id Rn_Document.rnd_id%TYPE)
    IS
        l_user_info      SYS_REFCURSOR;
        l_user_roles     SYS_REFCURSOR;

        WU_ID            NUMBER (14);
        WU_WUT           NUMBER (14);
        WU_ORG           NUMBER (5);
        WU_ORG_ORG       NUMBER (5);
        WU_TRC           VARCHAR2 (10);
        WU_LOGIN         VARCHAR2 (30);
        WU_PIB           VARCHAR2 (255);
        WU_NUMID         VARCHAR2 (10);
        WUT_CODE         VARCHAR2 (255);
        WUT_NAME         VARCHAR2 (255);
        WU_ORG_TO        VARCHAR2 (255);
        WU_org_acc_org   VARCHAR2 (255);
        l_p              VARCHAR2 (255);
        l_i              VARCHAR2 (255);
        l_b              VARCHAR2 (255);
    BEGIN
        --uss_rnsp.uss_rnsp_context.SetDnetRnspContext(p_session => '112560-4645647407779588056');
        IKIS_SYSWEB.IKIS_DNET_AUTH.GetUserInfo (
            p_session_id   => uss_rnsp.uss_rnsp_context.Getcontext ('session'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_info
                INTO WU_ID,
                     WU_WUT,
                     WU_ORG,
                     WU_ORG_ORG,
                     WU_ORG_ACC_ORG,
                     WU_TRC,
                     WU_LOGIN,
                     WU_PIB,
                     WU_NUMID,
                     WUT_CODE,
                     WUT_NAME,
                     WU_ORG_TO;

            --      FETCH l_user_info INTO WU_ID,  WU_WUT,  WU_ORG,  WU_ORG_ORG,  WU_TRC,  WU_LOGIN,  WU_PIB,  WU_NUMID,  WUT_CODE,  WUT_NAME,  WU_ORG_TO;
            EXIT WHEN l_user_info%NOTFOUND;
        --      DBMS_OUTPUT.PUT_LINE ( WU_PIB||'      '||WUT_NAME );
        END LOOP;

        CLOSE l_user_info;

        l_p :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           1);
        l_i :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           2);
        l_b :=
            REGEXP_SUBSTR (WU_PIB,
                           '[^ ]+',
                           1,
                           3);
        --38   Уповноважена особа суб’єкта реєс  1116  Посада
        --38   Уповноважена особа суб’єкта реєс  1117  Прізвище
        --38   Уповноважена особа суб’єкта реєс  1118  Ім’я
        --38   Уповноважена особа суб’єкта реєс  1119  По батькові
        Save_Document_Attr_Str (NULL,
                                p_rnd_id,
                                1116,
                                WUT_NAME);
        Save_Document_Attr_Str (NULL,
                                p_rnd_id,
                                1117,
                                l_p);
        Save_Document_Attr_Str (NULL,
                                p_rnd_id,
                                1118,
                                l_i);
        Save_Document_Attr_Str (NULL,
                                p_rnd_id,
                                1119,
                                l_b);
    END;

    --=============================================--
    PROCEDURE Update_UserPIB (p_rnd_id Rn_Document.rnd_id%TYPE)
    IS
        l_p   VARCHAR2 (255);
        l_i   VARCHAR2 (255);
        l_b   VARCHAR2 (255);
    BEGIN
        api$document.Get_UserPIB (l_p, l_i, l_b);

        --38   Уповноважена особа суб’єкта реєс  1116  Посада
        --38   Уповноважена особа суб’єкта реєс  1117  Прізвище
        --38   Уповноважена особа суб’єкта реєс  1118  Ім’я
        --38   Уповноважена особа суб’єкта реєс  1119  По батькові

        FOR atr
            IN (SELECT nda_id, rnda_Id
                  FROM uss_ndi.v_ndi_document_attr
                       LEFT JOIN Rn_Document_Attr
                           ON rnda_rnd = p_rnd_id AND rnda_nda = nda_id
                 WHERE     nda_ndt = 730
                       AND nda_id IN (1117, 1118, 1119)
                       AND uss_ndi.v_ndi_document_attr.history_status = 'A')
        LOOP
            CASE atr.nda_id
                WHEN 1117
                THEN
                    Save_Document_Attr_Str (atr.rnda_Id,
                                            p_rnd_id,
                                            1117,
                                            l_p);
                WHEN 1118
                THEN
                    Save_Document_Attr_Str (atr.rnda_Id,
                                            p_rnd_id,
                                            1118,
                                            l_i);
                WHEN 1119
                THEN
                    Save_Document_Attr_Str (atr.rnda_Id,
                                            p_rnd_id,
                                            1119,
                                            l_b);
                ELSE
                    NULL;
            END CASE;
        END LOOP;
    END;

    --=============================================--
    PROCEDURE Create_document730 (p_ap_id        appeal.ap_id%TYPE,
                                  p_rnd_id   OUT Rn_Document.rnd_id%TYPE)
    IS
        l_rnd_ndt   Rn_Document.rnd_ndt%TYPE := 730;
        NUM         NUMBER;
        YY          NUMBER;
        L_New_Id    Rn_Document_Attr.rnda_Val_Id%TYPE;
    BEGIN
        --DELETE FROM Rn_Document_attr WHERE rnda_rnd IN (SELECT rnd_id FROM Rn_Document WHERE rnd_ap = p_ap_id AND rnd_ndt = 730);
        UPDATE Rn_Document
           SET history_status = 'H'
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';

        SELECT MAX (rnd_id)
          INTO p_rnd_id
          FROM Rn_Document
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';

        -- сформируем диапазон номера
        YY := TO_NUMBER (TO_CHAR (SYSDATE, 'YY')) * 100000;

        -- сформируем номер
        SELECT NVL (MAX (rnda.rnda_val_int), YY) + 1
          INTO NUM
          FROM Rn_Document  rnd
               JOIN Rn_Document_attr rnda
                   ON     rnda.rnda_rnd = rnd_id
                      AND rnda.rnda_nda = 1112
                      AND rnda_val_int BETWEEN YY AND YY + 99999
         WHERE rnd.rnd_ndt = l_rnd_ndt;

        IF p_rnd_id IS NULL
        THEN
            -- запишем документ
            INSERT INTO Rn_Document (rnd_id,
                                     rnd_ap,
                                     rnd_app,
                                     rnd_ndt,
                                     history_status)
                 VALUES (NULL,
                         p_ap_id,
                         NULL,
                         l_rnd_ndt,
                         'A')
              RETURNING rnd_id
                   INTO p_rnd_id;
        END IF;

        --18   Загальна інформація               1112  №
        --18   Загальна інформація               1113  Дата
        --18   Загальна інформація               1114  Рішення  V_DDN_RNSP_DECISION
        --18   Загальна інформація               1115  Підстави прийняття рішення про повернення на доопрацювання
        Save_Document_Attr_Int (NULL,
                                p_rnd_id,
                                1112,
                                NUM);
        Save_Document_Attr_DT (NULL,
                               p_rnd_id,
                               1113,
                               TRUNC (SYSDATE));
        --Save_Document_Attr_Str(NULL, p_ap_id, p_rnd_id, 1114, (CASE ap.ap_st WHEN 'X' THEN 'P' ELSE 'V' END));

        -- Загрузим данніе пользователя
        Set_UserPIB (p_rnd_id);

        FOR atr
            IN (SELECT Rn_Document_attr.*
                  FROM Rn_Document
                       JOIN Rn_Document_attr
                           ON     rnda_rnd = rnd_id
                              AND rnda_nda IN (1094,
                                               1095,
                                               1096,
                                               1097)
                              AND Rn_Document_attr.history_status = 'A'
                 WHERE     rnd_ap = p_ap_id
                       AND rnd_ndt = 700
                       AND Rn_Document.history_status = 'A')
        LOOP
            Save_Document_Attr_Str (
                NULL,
                p_rnd_id,
                CASE atr.rnda_nda
                    WHEN 1094 THEN 1120
                    WHEN 1095 THEN 1121
                    WHEN 1096 THEN 1122
                    WHEN 1097 THEN 1123
                END,
                atr.rnda_val_string);
        END LOOP;

        Save_Document_Attr_dt (NULL,
                               p_rnd_id,
                               1124,
                               SYSDATE);
    --Copy_Document2Rn(p_ap_id);
    /*

       37   Заявник                           1094  Посада керівника юридичної особи/ фізичної особи - підприємця
       37   Заявник                           1095  Прізвище керівника юридичної особи/ фізичної особи - підприємця
       37   Заявник                           1096  Ім’я керівника юридичної особи/ фізичної особи – підприємця
       37   Заявник                           1097  По батькові керівника юридичної особи/ фізичної особи – підприємця

       39   Примірник рішення отримано        1120  посада керівника/ФОП/документ уповноваженої особи
       39   Примірник рішення отримано        1121  Прізвище
       39   Примірник рішення отримано        1122  Ім’я
       39   Примірник рішення отримано        1123  По батькові
       39   Примірник рішення отримано        1124  Дата

    */
    END;

    --=============================================--
    PROCEDURE Update_document730 (p_rnd_id   Rn_Document.rnd_id%TYPE,
                                  p_doc_id   Rn_Document.rnd_doc%TYPE,
                                  p_dh_id    Rn_Document.rnd_dh%TYPE)
    IS
    BEGIN
        UPDATE Rn_Document
           SET rnd_doc = p_doc_id, rnd_dh = p_dh_id
         WHERE rnd_id = p_rnd_id;
    END;

    --=============================================--
    PROCEDURE Update_document730_pib (p_ap_id Rn_Document.rnd_ap%TYPE)
    IS
        l_rnd_id   Rn_Document.rnd_id%TYPE;
    BEGIN
        SELECT MAX (rnd_id)
          INTO l_rnd_id
          FROM Rn_Document
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';

        IF l_rnd_id IS NOT NULL
        THEN
            Update_userpib (l_rnd_id);
        END IF;
    END;

    --=============================================--
    PROCEDURE Delete_rnsp_state (p_rnsps_id rnsp_state.rnsps_id%TYPE)
    IS
    --l_rnspa_id  rnsp_address.rnspa_id%TYPE;
    --l_rnspo_id  rnsp_other.rnspo_id%TYPE;
    BEGIN
        /*
            DELETE FROM rnsp2service
            WHERE rnsp2s_rnsps = p_rnsps_id;

            DELETE FROM rnsp_dict_service
            WHERE NOT EXISTS (SELECT 1 FROM rnsp2service WHERE rnsp2s_rnspds = rnspds_id);


            DELETE FROM rnsp2doc
            WHERE rnsp2d_rnsps = p_rnsps_id;

            SELECT s.rnsps_rnspa, s.rnsps_rnspo
              INTO l_rnspa_id, l_rnspo_id
            FROM rnsp_state s
            WHERE s.rnsps_id = p_rnsps_id;
        */

        UPDATE rnsp_state
           SET history_status = 'H'
         WHERE rnsps_id = p_rnsps_id;
    --DELETE FROM rnsp_state
    --WHERE rnsps_id = p_rnsps_id;

    --DELETE FROM rnsp_address
    --WHERE rnspa_id = l_rnspa_id;

    --DELETE FROM rnsp_other
    --WHERE rnspo_id = l_rnspo_id;

    END;

    --=============================================--
    PROCEDURE Copy_appeal_2_rnsp (p_ap_id          appeal.ap_id%TYPE,
                                  p_Ap_St          appeal.Ap_St%TYPE,
                                  p_rnspm_id       rnsp_main.rnspm_id%TYPE,
                                  p_old_rnsps_id   rnsp_state.rnsps_id%TYPE,
                                  IS_RAISE         BOOLEAN)
    IS
        l_rnspa_id    rnsp_address.rnspa_id%TYPE;
        l_rnspa1_id   rnsp_address.rnspa_id%TYPE;
        l_rnspo_id    rnsp_other.rnspo_id%TYPE;
        l_rnsps_id    rnsp_state.rnsps_id%TYPE;
        l_rnspds_id   rnsp_dict_service.rnspds_id%TYPE;
        l_hs          NUMBER := tools.GetHistSession;
        l_err         VARCHAR2 (4000);
        l_qty         NUMBER;
    BEGIN
        TOOLS.LOG (
            'USS_RNSP.API$DOCUMENT.Copy_appeal_2_rnsp',
            'APPEAL',
            p_ap_id,
               'Start. p_rnspm_id='
            || p_rnspm_id
            || ', p_old_rnsps_id='
            || p_old_rnsps_id
            || ', p_Ap_St='
            || p_Ap_St);


        SELECT sq_id_rnsp_other.NEXTVAL INTO l_rnspo_id FROM DUAL;

        INSERT INTO rnsp_other (rnspo_id,
                                rnspo_phone,
                                rnspo_email,
                                rnspo_web,
                                rnspo_service_location,
                                rnspo_prop_form,
                                rnspo_union_tp)
            SELECT l_rnspo_id,
                   api$document.Get_Apda_Str (apd.apd_id, 968)
                       AS PHONE,
                   api$document.Get_Apda_Str (apd.apd_id, 969)
                       AS EMAIL,
                   api$document.Get_Apda_Str (apd.apd_id, 970)
                       AS WEB,
                   CASE NVL (Get_apda_Str (apd.apd_id, 1093), 'T')
                       WHEN 'T'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 974)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 982)
                       ELSE
                           ''
                   END
                       AS SERVICE_LOCATION,
                   CASE Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 966)
                       WHEN 'O'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 958)
                       ELSE
                           ''
                   END
                       AS PROP_FORM,
                   CASE Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 967)
                       WHEN 'O'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 959)
                       ELSE
                           ''
                   END
                       AS UNION_TP
              FROM ap_Document apd
             WHERE     apd.apd_ap = p_Ap_Id
                   AND apd.apd_ndt = 700
                   AND apd.history_status = 'A';

        l_qty := SQL%ROWCOUNT;
        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Copy_appeal_2_rnsp',
                   'APPEAL',
                   p_ap_id,
                   'rnsp_other >> ' || l_qty);
        DBMS_OUTPUT.put_line ('rnsp_other >> ' || l_qty);


        --    BEGIN
        SELECT sq_id_rnsp_address.NEXTVAL INTO l_rnspa_id FROM DUAL;

        INSERT INTO rnsp_address (rnspa_id,
                                  rnspa_kaot,
                                  rnspa_index,
                                  rnspa_street,
                                  rnspa_building,
                                  rnspa_korp,
                                  rnspa_appartement,
                                  rnspa_notes,
                                  rnspa_tp)
            SELECT l_rnspa_id,
                   api$document.Get_Apda_id (apd.apd_id, 971)
                       AS KATTOTG_ID,
                   api$document.Get_Apda_Str (apd.apd_id, 972)
                       AS INDEX_,
                   NVL (api$document.Get_Apda_Str (apd.apd_id, 975),
                        api$document.Get_Apda_Str (apd.apd_id, 2159))
                       AS STREET,
                   SUBSTR (api$document.Get_Apda_Str (apd.apd_id, 976),
                           1,
                           10)
                       AS BUILDING,
                   api$document.Get_Apda_Str (apd.apd_id, 977)
                       AS KORP,
                   api$document.Get_Apda_Str (apd.apd_id, 978)
                       AS APPARTEMENT,
                   api$document.Get_Apda_Str (apd.apd_id, 1485)
                       AS Notes,
                   'U'
              FROM ap_Document apd
             WHERE     apd.apd_ap = p_Ap_Id
                   AND apd.apd_ndt = 700
                   AND apd.history_status = 'A';

        l_qty := SQL%ROWCOUNT;
        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Copy_appeal_2_rnsp',
                   'APPEAL',
                   p_ap_id,
                   'rnsp_address U>> ' || l_qty);

        --    EXCEPTION WHEN OTHERS THEN
        --      api$find.Write_Log(p_ap_id,
        --                         l_hs,
        --                         p_Ap_St,
        --                         Dbms_Utility.Format_Error_Stack || Dbms_Utility.Format_Error_Backtrace,
        --                         NULL, NULL);
        --    END;
        --      IF api$document.Get_ap_doc_Str( p_Ap_Id, 700, 1093, 'F') = 'F' THEN

        SELECT sq_id_rnsp_address.NEXTVAL INTO l_rnspa1_id FROM DUAL;

        INSERT INTO rnsp_address (rnspa_id,
                                  rnspa_kaot,
                                  rnspa_index,
                                  rnspa_street,
                                  rnspa_building,
                                  rnspa_korp,
                                  rnspa_appartement,
                                  rnspa_notes,
                                  rnspa_tp)
            SELECT l_rnspa1_id,
                   api$document.Get_Apda_id (apd.apd_id, 979)
                       AS KATTOTG_ID,
                   api$document.Get_Apda_Str (apd.apd_id, 980)
                       AS INDEX_,
                   NVL (api$document.Get_Apda_Str (apd.apd_id, 983),
                        api$document.Get_Apda_Str (apd.apd_id, 2160))
                       AS STREET,
                   SUBSTR (api$document.Get_Apda_Str (apd.apd_id, 984),
                           1,
                           10)
                       AS BUILDING,
                   api$document.Get_Apda_Str (apd.apd_id, 985)
                       AS KORP,
                   api$document.Get_Apda_Str (apd.apd_id, 986)
                       AS APPARTEMENT,
                   api$document.Get_Apda_Str (apd.apd_id, 1486)
                       AS Notes,
                   'S'
              FROM ap_Document apd
             WHERE     apd.apd_ap = p_Ap_Id
                   AND apd.apd_ndt = 700
                   AND apd.history_status = 'A';

        l_qty := SQL%ROWCOUNT;
        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Copy_appeal_2_rnsp',
                   'APPEAL',
                   p_ap_id,
                   'rnsp_address S >> ' || l_qty);

        --      ELSE
        --        l_rnspa1_id := NULL;
        --      END IF;

        --dbms_output.put_line('rnsp_address >> '||sql%rowcount);

        SELECT sq_id_rnsp_state.NEXTVAL INTO l_rnsps_id FROM DUAL;

        INSERT INTO rnsp_state (rnsps_id,
                                rnsps_rnspm,
                                rnsps_rnspa,
                                rnsps_rnspo,
                                rnsps_numident,
                                rnsps_is_numident_missing,
                                rnsps_pass_seria,
                                rnsps_pass_num,
                                rnsps_last_name,
                                rnsps_first_name,
                                rnsps_middle_name,
                                rnsps_ownership,
                                --rnsps_gender,
                                --rnsps_date_birth,
                                --rnsps_nc,
                                history_status,
                                rnsps_hs,
                                rnsps_rnspa1_old,
                                rnsps_edr_state)
            SELECT l_rnsps_id,
                   p_rnspm_id,
                   l_rnspa_id,
                   l_rnspo_id,
                   CASE Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 961)
                       WHEN 'O'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 955)
                       ELSE
                           ''
                   END
                       AS NUMIDENT,
                   api$document.Get_Apda_Str (apd.apd_id, 960)
                       AS NUMIDENT_MISSING,
                   --'' AS PASS_SERIA,
                   --api$document.Get_Apda_Str( apd.apd_id, 962) AS PASS_NUM,
                   CASE
                       WHEN NVL (
                                REGEXP_INSTR (
                                    api$document.Get_Apda_Str (apd.apd_id,
                                                               962),
                                    '^[А-Я]{2}[0-9]{6}$',
                                    1),
                                0) >
                            0
                       THEN
                           REGEXP_SUBSTR (
                               api$document.Get_Apda_Str (apd.apd_id, 962),
                               '^[А-Я]{2}',
                               1)
                       ELSE
                           ''
                   END
                       AS PASS_SERIA,
                   CASE
                       WHEN NVL (
                                REGEXP_INSTR (
                                    api$document.Get_Apda_Str (apd.apd_id,
                                                               962),
                                    '^[А-Я]{2}[0-9]{6}$',
                                    1),
                                0) >
                            0
                       THEN
                           REGEXP_SUBSTR (
                               api$document.Get_Apda_Str (apd.apd_id, 962),
                               '[0-9]{6}$',
                               1)
                       ELSE
                           api$document.Get_Apda_Str (apd.apd_id, 962)
                   END
                       AS PASS_NUM,
                   CASE api$document.Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 963)
                       WHEN 'O'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 956)
                       ELSE
                           ''
                   END
                       AS LAST_NAME,
                   CASE api$document.Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 964)
                       WHEN 'O'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 957)
                       ELSE
                           ''
                   END
                       AS FIRST_NAME,
                   CASE api$document.Get_apda_Str (apd.apd_id, 953)
                       WHEN 'F'
                       THEN
                           api$document.Get_Apda_Str (apd.apd_id, 965)
                       WHEN 'O'
                       THEN
                           ''
                       ELSE
                           ''
                   END
                       AS MIDDLE_NAME,
                   api$document.Get_Apda_Str (apd.apd_id, 2540)
                       AS OWNERSHIP,
                   'A',
                   l_hs,
                   l_rnspa1_id,
                   NVL (api$document.Get_Apda_Str (apd.apd_id, 8370),
                        api$document.Get_Apda_Str (apd.apd_id, 3434))
                       AS RNSPS_EDR_STATE
              FROM ap_Document apd
             WHERE     apd.apd_ap = p_Ap_Id
                   AND apd.apd_ndt = 700
                   AND apd.history_status = 'A';

        l_qty := SQL%ROWCOUNT;
        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Copy_appeal_2_rnsp',
                   'APPEAL',
                   p_ap_id,
                   'rnsp_state >> ' || l_qty);

        INSERT INTO uss_rnsp.RNSP2ADDRESS (rnsp2a_id,
                                           rnsp2a_rnsps,
                                           rnsp2a_rnspa)
            SELECT 0, rs.rnsps_id, rs.rnsps_rnspa
              FROM uss_rnsp.Rnsp_State rs
             WHERE rs.rnsps_id = l_rnsps_id AND rs.rnsps_rnspa IS NOT NULL;

        INSERT INTO uss_rnsp.RNSP2ADDRESS (rnsp2a_id,
                                           rnsp2a_rnsps,
                                           rnsp2a_rnspa)
            SELECT 0, rs.rnsps_id, rs.rnsps_rnspa1_old
              FROM uss_rnsp.Rnsp_State rs
             WHERE     rs.rnsps_id = l_rnsps_id
                   AND rs.rnsps_rnspa1_old IS NOT NULL;

        FOR a
            IN (SELECT sq_id_rnsp_address.NEXTVAL
                           AS x_rnspa_id,
                       api$document.Get_Apda_id (apd.apd_id, 1098)
                           AS KATTOTG_ID,
                       api$document.Get_Apda_Str (apd.apd_id, 1133)
                           AS INDEX_,
                       NVL (api$document.Get_Apda_Str (apd.apd_id, 2535),
                            api$document.Get_Apda_Str (apd.apd_id, 2536))
                           AS STREET,
                       api$document.Get_Apda_Str (apd.apd_id, 2537)
                           AS BUILDING,
                       api$document.Get_Apda_Str (apd.apd_id, 2538)
                           AS KORP,
                       api$document.Get_Apda_Str (apd.apd_id, 2539)
                           AS APPARTEMENT,
                       api$document.Get_Apda_Str (apd.apd_id, 1487)
                           AS Notes,
                       'S'
                           AS tp
                  FROM ap_Document apd
                 WHERE     apd.apd_ap = p_Ap_Id
                       AND apd.apd_ndt = 750
                       AND apd.history_status = 'A')
        LOOP
            INSERT INTO rnsp_address (rnspa_id,
                                      rnspa_kaot,
                                      rnspa_index,
                                      rnspa_street,
                                      rnspa_building,
                                      rnspa_korp,
                                      rnspa_appartement,
                                      rnspa_notes,
                                      rnspa_tp)
                 VALUES (a.x_rnspa_id,
                         a.KATTOTG_ID,
                         a.INDEX_,
                         a.STREET,
                         a.BUILDING,
                         a.KORP,
                         a.APPARTEMENT,
                         a.notes,
                         a.tp);

            INSERT INTO uss_rnsp.RNSP2ADDRESS (rnsp2a_id,
                                               rnsp2a_rnsps,
                                               rnsp2a_rnspa)
                 VALUES (0, l_rnsps_id, a.x_rnspa_id);
        /*
               CASE a.tp
               WHEN 'S2' THEN l_rnspa2_id := a.x_rnspa_id;
               WHEN 'S3' THEN l_rnspa3_id := a.x_rnspa_id;
               WHEN 'S4' THEN l_rnspa4_id := a.x_rnspa_id;
               ELSE NULL;
               END CASE;
        */
        END LOOP;

        DBMS_OUTPUT.put_line ('rnsp_state >> ' || SQL%ROWCOUNT);

        FOR s IN (SELECT *
                    FROM ap_service
                   WHERE aps_ap = p_ap_id AND history_status = 'A')
        LOOP
            SELECT sq_id_rnsp_dict_service.NEXTVAL INTO l_rnspds_id FROM DUAL;

            INSERT INTO rnsp_dict_service (rnspds_id,
                                           rnspds_nst,
                                           rnspds_content,
                                           rnspds_condition,
                                           rnspds_sum,
                                           rnspds_sum_fm,
                                           rnspds_izm,
                                           rnspds_cnt,
                                           rnspds_can_urgant,
                                           rnspds_is_inroom,
                                           rnspds_is_innursing,
                                           rnspds_is_standards)
                 VALUES (l_rnspds_id,
                         s.aps_nst,
                         Get_rnd_aps_Str (s.aps_id, 'CONTENT'),
                         Get_rnd_aps_Str (s.aps_id, 'CONDITION'),
                         Get_rnd_aps_sum (s.aps_id, 'SUM'),
                         Get_rnd_aps_sum (s.aps_id, 'SUM_FM'),
                         Get_rnd_aps_Str (s.aps_id, 'IZM'),
                         Get_rnd_aps_Int (s.aps_id, 'CNT'),
                         Get_rnd_aps_Str (s.aps_id, 'CAN_URGANT'),
                         Get_rnd_aps_Str (s.aps_id, 'IS_INROOM'),
                         Get_rnd_aps_Str (s.aps_id, 'IS_INNURSING'),
                         Get_rnd_aps_Str (s.aps_id, 'IS_STANDARDS'));

            DBMS_OUTPUT.put_line ('rnsp_dict_service >> ' || SQL%ROWCOUNT);

            INSERT INTO rnsp2service (rnsp2s_rnsps, rnsp2s_rnspds)
                 VALUES (l_rnsps_id, l_rnspds_id);

            /*
                    INSERT INTO rnsp2service(rnsp2s_rnsps, rnsp2s_rnspds)
                    SELECT rnsp2s_rnsps, rnsp2s_rnspds
                    FROM rnsp2service
                    WHERE rnsp2s_rnsps = p_old_rnsps_id
                          --AND NOT EXISTS ()
                          ;*/



            DBMS_OUTPUT.put_line ('rnsp2service >> ' || SQL%ROWCOUNT);
        END LOOP;

        INSERT INTO rnsp2doc (rnsp2d_rnsps, rnsp2d_dh)
            SELECT l_rnsps_id, apd.apd_dh
              FROM ap_Document  apd
                   JOIN uss_ndi.v_ndi_document_type ON ndt_id = apd_ndt
             WHERE     apd.apd_ap = 13571205
                   AND apd.apd_ndt NOT IN (700, 730, 750)
                   AND apd.apd_aps IS NULL
                   AND ndt_ndc != 14
                   AND apd.history_status = 'A';
    /*
          INSERT INTO rnsp2doc(rnsp2d_rnsps, rnsp2d_dh)
          SELECT l_rnsps_id, apd.apd_dh
          FROM ap_Document apd
          WHERE apd.apd_ap = p_Ap_Id
                AND apd.apd_ndt NOT IN ( 700, 730)
                AND apd.apd_aps IS NULL
                AND apd.history_status = 'A';
    */

    EXCEPTION
        WHEN OTHERS
        THEN
            api$find.Write_Log (
                p_ap_id,
                l_hs,
                p_Ap_St,
                   DBMS_UTILITY.Format_Error_Stack
                || DBMS_UTILITY.Format_Error_Backtrace,
                NULL,
                NULL);

            IF IS_RAISE
            THEN
                RAISE;
            END IF;
    END;

    --=============================================--
    -- Перезавантаження атрибутів по послугах
    PROCEDURE MERGE_dict_service (p_ap_id NUMBER)
    IS
        CURSOR srv IS
            SELECT ds.rnspds_id
                       AS x_rnspds_id,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'CONTENT')
                       AS x_rnspds_content,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'CONDITION')
                       AS x_rnspds_condition,
                   API$Document.Get_rnd_aps_sum (aps.aps_id, 'SUM')
                       AS x_rnspds_sum,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'IZM')
                       AS x_rnspds_izm,
                   API$Document.Get_rnd_aps_Int (aps.aps_id, 'CNT')
                       AS x_rnspds_cnt,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'CAN_URGANT')
                       AS x_rnspds_can_urgant,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'IS_INROOM')
                       AS x_rnspds_is_inroom,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'IS_INNURSING')
                       AS x_rnspds_is_innursing,
                   API$Document.Get_rnd_aps_Str (aps.aps_id, 'IS_STANDARDS')
                       AS x_rnspds_is_standards
              FROM appeal  ap
                   JOIN ap_service aps
                       ON aps_ap = ap_id AND aps.history_status = 'A'
                   JOIN rnsp_state st
                       ON     st.rnsps_rnspm = ap.ap_ext_ident
                          AND st.history_status = 'A'
                   JOIN rnsp2service st2s ON st2s.rnsp2s_rnsps = st.rnsps_id
                   JOIN rnsp_dict_service ds
                       ON     ds.rnspds_id = st2s.rnsp2s_rnspds
                          AND ds.rnspds_nst = aps.aps_nst
             WHERE ap_id = p_ap_id;
    BEGIN
        FOR rec IN srv
        LOOP
            UPDATE rnsp_dict_service
               SET rnspds_content = rec.x_rnspds_content,
                   rnspds_condition = rec.x_rnspds_condition,
                   rnspds_sum = rec.x_rnspds_sum,
                   rnspds_izm = rec.x_rnspds_izm,
                   rnspds_cnt = rec.x_rnspds_cnt,
                   rnspds_can_urgant = rec.x_rnspds_can_urgant,
                   rnspds_is_inroom = rec.x_rnspds_is_inroom,
                   rnspds_is_innursing = rec.x_rnspds_is_innursing,
                   rnspds_is_standards = rec.x_rnspds_is_standards
             WHERE rnspds_id = rec.x_rnspds_id;
        END LOOP;
    /*
        MERGE INTO rnsp_dict_service
        USING (SELECT ds.rnspds_id AS x_rnspds_id,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'CONTENT')      AS x_rnspds_content,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'CONDITION')    AS x_rnspds_condition,
                      API$Document.Get_rnd_aps_sum(aps.aps_id, 'SUM')          AS x_rnspds_sum,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'IZM')          AS x_rnspds_izm,
                      API$Document.Get_rnd_aps_Int(aps.aps_id, 'CNT')          AS x_rnspds_cnt,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'CAN_URGANT')   AS x_rnspds_can_urgant,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'IS_INROOM')    AS x_rnspds_is_inroom,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'IS_INNURSING') AS x_rnspds_is_innursing,
                      API$Document.Get_rnd_aps_Str(aps.aps_id, 'IS_STANDARDS') AS x_rnspds_is_standards
               FROM appeal ap
                    JOIN ap_service aps ON aps_ap = ap_id AND aps.history_status = 'A'
                    JOIN rnsp_state st ON st.rnsps_rnspm = ap.ap_ext_ident AND st.history_status = 'A'
                    JOIN rnsp2service st2s ON st2s.rnsp2s_rnsps = st.rnsps_id
                    JOIN rnsp_dict_service ds ON ds.rnspds_id = st2s.rnsp2s_rnspds AND ds.rnspds_nst = aps.aps_nst
               WHERE ap_id = p_ap_id
               )
        ON (rnspds_id = x_rnspds_id)
           WHEN MATCHED THEN
             UPDATE SET
             rnspds_content     = x_rnspds_content,
             rnspds_condition   = x_rnspds_condition,
             rnspds_sum         = x_rnspds_sum,
             rnspds_izm         = x_rnspds_izm,
             rnspds_cnt         = x_rnspds_cnt,
             rnspds_can_urgant  = x_rnspds_can_urgant,
             rnspds_is_inroom   = x_rnspds_is_inroom,
             rnspds_is_innursing= x_rnspds_is_innursing,
             rnspds_is_standards= x_rnspds_is_standards
        ;
        */
    END;

    --=============================================--
    PROCEDURE Update_appeal_ap_ext_ident (
        p_ap_id           appeal.ap_id%TYPE,
        p_ext_ident   OUT appeal.ap_ext_ident%TYPE)
    IS
        l_RNSP_ST        VARCHAR2 (12);
        l_RNSP_TP        VARCHAR2 (12);
        --A sign of the coincidence of the place of provision of social services with the location of the provider
        --l_sign_location  VARCHAR2(12);
        l_rnspm_id       rnsp_main.rnspm_id%TYPE;
        l_rnsps_id       rnsp_state.rnsps_id%TYPE;
        --    l_ext_ident appeal.ap_ext_ident%TYPE;
        l_ap_num         appeal.ap_num%TYPE;
        l_ap_st          appeal.ap_st%TYPE;
        l_numident       VARCHAR2 (200);
        l_rnspm_st       VARCHAR2 (20);
        l_rnspm_tp       VARCHAR2 (20);
        l_rnspm_org_tp   rnsp_main.rnspm_org_tp%TYPE;
        l_rnspm_rnspm    rnsp_main.rnspm_rnspm%TYPE;
    --l_rnspm_chapter     rnsp_main.rnspm_chapter%TYPE;

    BEGIN
        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                   'APPEAL',
                   p_ap_id,
                   'Start');

        SELECT ap_ext_ident, ap_num, ap_st
          INTO p_ext_ident, l_ap_num, l_ap_st
          FROM appeal
         WHERE ap_id = p_ap_id;

        /*
        1131 700 Головна організація/філіал
        2451 700 Надавач соціальної послуги
        2450 700 Код філіалу
        */

        FOR ank
            IN (SELECT apd_ap,
                       apd_id,
                       api$document.Get_Apda_Str (apd.apd_id, 953)
                           AS RNSP_TP,
                       api$document.Get_Apda_Str (apd.apd_id, 954)
                           AS RNSP_ST,
                       api$document.Get_Apda_Str (apd.apd_id, 955)
                           AS EDRPOU,
                       api$document.Get_Apda_Str (apd.apd_id, 960)
                           AS IsNotIIN,
                       api$document.Get_Apda_Str (apd.apd_id, 961)
                           AS IIN,
                       api$document.Get_Apda_Str (apd.apd_id, 962)
                           AS PASPORT,
                       api$document.Get_Apda_Str (apd.apd_id, 1131)
                           AS rnspm_org_tp,
                       api$document.Get_Apda_Id (Apd.Apd_Id, 2450)
                           AS "RNSPM_ID", --Найменування організації, щодо якої створюється звернення ID V_RNSP_ALL
                       api$document.Get_Apda_Id (Apd.Apd_Id, 2451)
                           AS "RNSPM_RNSPM", --Головна організація/установа (вказати, якщо обрано ознаку "філіал")
                       api$document.Get_Apda_Id (Apd.Apd_Id, 8370)
                           AS "RNSPS_EDR_STATE"
                  FROM ap_document apd
                 WHERE     apd.apd_ap = p_ap_id
                       AND apd.apd_ndt = 700
                       AND history_status = 'A')
        LOOP
            CASE
                WHEN ank.rnsp_tp = 'O'
                THEN
                    l_numident := ank.EDRPOU;
                WHEN ank.rnsp_tp = 'F' AND NVL (ank.IsNotIIN, 'F') = 'F'
                THEN
                    l_numident := ank.iin;
                WHEN ank.rnsp_tp = 'F' AND NVL (ank.isnotiin, 'F') = 'T'
                THEN
                    l_numident := ank.pasport;
                ELSE
                    NULL;
            END CASE;

            /*
                  l_sign_location := nvl(ank.IsNotIIN,'F');
                  uss_rnsp.API$Find.GetRNSPM(l_numident,
                                             l_sign_location,
                                             l_ap_num,
                                             ank.rnspm_org_tp,
                                             ank.rnspm_rnspm,
                                             ank.rnspm_chapter,
                                             l_rnspm_id,
                                             l_rnspm_st,
                                             l_rnspm_tp);
            */

            l_rnspm_org_tp := ank.rnspm_org_tp;
            l_rnspm_rnspm := ank.rnspm_rnspm;
            l_rnspm_id := ank.rnspm_id;
        END LOOP;

        l_RNSP_ST := Get_apda_Val_String (p_ap_id, 700, 954);
        l_RNSP_TP := Get_Apda_Val_String (p_ap_id, 700, 953);

        DBMS_OUTPUT.put_line ('Тип надавача   ' || l_RNSP_TP);
        DBMS_OUTPUT.put_line ('Тип звернення  ' || l_RNSP_ST);
        DBMS_OUTPUT.put_line ('l_numident   ' || l_numident);
        DBMS_OUTPUT.put_line ('l_rnspm_id   ' || l_rnspm_id);
        DBMS_OUTPUT.put_line ('l_rnspm_st   ' || l_rnspm_st);
        DBMS_OUTPUT.put_line ('p_ext_ident  ' || p_ext_ident);

        -- Для случая, когда создание и при возврате отредактировали  EDRPOU, IIN или PASPORT
        IF l_RNSP_ST = 'A' AND p_ext_ident IS NOT NULL
        THEN
            l_rnspm_id := p_ext_ident;
        END IF;

        TOOLS.LOG (
            'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
            'APPEAL',
            p_ap_id,
               'Before case action. l_rnspm_id='
            || l_rnspm_id
            || ', l_numident='
            || l_numident
            || ', l_RNSP_ST='
            || l_RNSP_ST
            || ', l_RNSP_TP='
            || l_RNSP_TP
            || ', l_ap_st='
            || l_ap_st);


        --A  Включено до РНСП
        --U  Зміна відомостей в РНСП
        --D  Виключено з РНСП
        CASE
            WHEN l_RNSP_ST = 'A' AND l_rnspm_id IS NULL
            THEN
                TOOLS.LOG (
                    'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                    'APPEAL',
                    p_ap_id,
                    'Before case action 1.');

                SELECT sq_id_rnsp_main.NEXTVAL INTO l_rnspm_id FROM DUAL;

                INSERT INTO rnsp_main (rnspm_id,
                                       rnspm_num,
                                       rnspm_date_in,
                                       rnspm_st,
                                       rnspm_version,
                                       rnspm_tp,
                                       rnspm_org_tp,
                                       rnspm_rnspm)
                    SELECT l_rnspm_id,
                           appeal.ap_num,
                           appeal.ap_reg_dt,
                           'N',
                           0,
                           l_RNSP_TP,
                           l_rnspm_org_tp,
                           l_rnspm_rnspm
                      FROM appeal
                     WHERE ap_id = p_ap_id;

                Copy_appeal_2_rnsp (p_ap_id,
                                    l_ap_st,
                                    l_rnspm_id,
                                    NULL,
                                    FALSE);

                UPDATE appeal
                   SET appeal.ap_ext_ident = l_rnspm_id
                 WHERE ap_id = p_ap_id;

                p_ext_ident := l_rnspm_id;

                Copy_Document2Rn (p_ap_id);
            WHEN l_RNSP_ST = 'A' AND l_rnspm_id IS NOT NULL
            THEN
                TOOLS.LOG (
                    'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                    'APPEAL',
                    p_ap_id,
                    'Before case action 2.');


                SELECT MAX (s.rnsps_id)
                  INTO l_rnsps_id
                  FROM rnsp_state s
                 WHERE rnsps_rnspm = l_rnspm_id AND s.history_status = 'A';

                IF l_rnsps_id IS NOT NULL
                THEN
                    Delete_rnsp_state (l_rnsps_id);
                END IF;

                Copy_appeal_2_rnsp (p_ap_id,
                                    l_ap_st,
                                    l_rnspm_id,
                                    NULL,
                                    FALSE);

                UPDATE appeal
                   SET appeal.ap_ext_ident = l_rnspm_id
                 WHERE ap_id = p_ap_id;

                Copy_Document2Rn (p_ap_id);
            WHEN l_RNSP_ST = 'U'
            THEN
                TOOLS.LOG (
                    'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                    'APPEAL',
                    p_ap_id,
                    'Before case action 3.');

                UPDATE appeal
                   SET appeal.ap_ext_ident = l_rnspm_id
                 WHERE ap_id = p_ap_id;

                Copy_Document2Rn (p_ap_id);
            WHEN l_RNSP_ST = 'D'
            THEN
                TOOLS.LOG (
                    'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                    'APPEAL',
                    p_ap_id,
                    'Before case action 4.');

                UPDATE appeal
                   SET appeal.ap_ext_ident = l_rnspm_id
                 WHERE ap_id = p_ap_id;

                Copy_Document2Rn (p_ap_id);
            ELSE
                TOOLS.LOG (
                    'USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                    'APPEAL',
                    p_ap_id,
                    'Before case action 5.');
                NULL;
        END CASE;

        TOOLS.LOG ('USS_RNSP.API$DOCUMENT.Update_appeal_ap_ext_ident',
                   'APPEAL',
                   p_ap_id,
                   'After case action.');
        DBMS_OUTPUT.put_line (' ');
    END;

    PROCEDURE Grant_Cmes_Access (p_Ap_Id       IN NUMBER,
                                 p_Rnspm_Id    IN NUMBER,
                                 p_Ap_Sub_Tp   IN VARCHAR2)
    IS
        l_Apd_Id          NUMBER;
        l_App             Ap_Person%ROWTYPE;
        l_Sco             Uss_person.v_Sc_Info%ROWTYPE;
        l_Boss_Numident   VARCHAR2 (4000);
        l_Fop_Numident    VARCHAR2 (4000);
        l_Hs_Id           NUMBER;
        l_Email           VARCHAR2 (4000);
        l_Msg             VARCHAR2 (4000);
        l_Msg_Title       VARCHAR2 (4000);

        PROCEDURE Garnt_Access (p_Numident IN VARCHAR2, p_Pib IN VARCHAR2)
        IS
            l_Cu_Id   NUMBER;
        BEGIN
            SELECT MAX (u.Cu_Id)
              INTO l_Cu_Id
              FROM Ikis_Rbm.v_Cmes_Users u
             WHERE u.Cu_Numident = p_Numident;


            IF l_Cu_Id IS NULL
            THEN
                Ikis_Rbm.Api$cmes.Save_User (p_Cu_Id         => NULL,
                                             p_Cu_Numident   => p_Numident,
                                             p_Cu_Pib        => p_Pib,
                                             p_Cu_Locked     => 'F',
                                             p_Hs_Id         => l_Hs_Id,
                                             p_New_Id        => l_Cu_Id);
            END IF;

            IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cu_Id           => l_Cu_Id,
                       p_Cmes_Id         => 2,
                       p_Cmes_Owner_Id   => p_Rnspm_Id,
                       p_Cr_Code         => 'NSP_SPEC')
            THEN
                --Призначаємо роль уповноваженого спеціаліста НСП
                Ikis_Rbm.Api$cmes.Assign_User_Role (
                    p_Cu2r_Cu              => l_Cu_Id,
                    p_Cu2r_Cr              => 5,
                    p_Cu2r_Cmes_Owner_Id   => p_Rnspm_Id,
                    p_Hs_Id                => l_Hs_Id,
                    p_Cu2r_Email           => NULL);

                l_Msg :=
                       l_Msg
                    || 'Користувачу '
                    || INITCAP (p_Pib)
                    || ' присвоєно роль "Уповноважений спеціаліст НСП"'
                    || CHR (13)
                    || CHR (10);
            END IF;

            IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cu_Id           => l_Cu_Id,
                       p_Cmes_Id         => 2,
                       p_Cmes_Owner_Id   => p_Rnspm_Id,
                       p_Cr_Code         => 'NSP_ADM')
            THEN
                --Призначаємо роль адміністратора НСП
                Ikis_Rbm.Api$cmes.Assign_User_Role (
                    p_Cu2r_Cu              => l_Cu_Id,
                    p_Cu2r_Cr              => 4,
                    p_Cu2r_Cmes_Owner_Id   => p_Rnspm_Id,
                    p_Hs_Id                => l_Hs_Id,
                    p_Cu2r_Email           => NULL);

                l_Msg :=
                       l_Msg
                    || 'Користувачу '
                    || INITCAP (p_Pib)
                    || ' присвоєно роль "Адміністратор спеціаліст НСП"'
                    || CHR (13)
                    || CHR (10);
            END IF;
        END;
    BEGIN
        l_Msg :=
               CASE
                   WHEN p_Ap_Sub_Tp = 'A'
                   THEN
                          'Затверджено рішення про внесення надавача "'
                       || Api$find.Get_Nsp_Name (p_Rnspm_Id)
                       || '" до реєстру надавачів соціальних послуг.'
                   ELSE
                          'Затверджено рішення про зміну даних надавача "'
                       || Api$find.Get_Nsp_Name (p_Rnspm_Id)
                       || '" в реєстрі надавачів соціальних послуг.'
               END
            || CHR (13)
            || CHR (10)
            || CHR (13)
            || CHR (10);

        l_Msg_Title :=
            CASE
                WHEN p_Ap_Sub_Tp = 'A'
                THEN
                    'ЄІССС: реєстрація надавача соціальних послуг'
                ELSE
                    'ЄІССС: зміна реєстраційних даних надавача соціальних послуг'
            END;

        --Отримуємо ІД документа заяви
        SELECT d.Apd_Id
          INTO l_Apd_Id
          FROM Ap_Document d
         WHERE     d.Apd_Ap = p_Ap_Id
               AND d.Apd_Ndt = 700
               AND d.History_Status = 'A';

        --Отримуємо email
        l_Email :=
            Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                       p_Apda_Nda   => 969);
        l_Hs_Id := Ikis_Rbm.Tools.Gethistsession;

        --Зчитуємо дані заявника
        /*SELECT p.*
          INTO l_App
          FROM Ap_Person p
         WHERE p.App_Ap = p_Ap_Id
           AND p.App_Tp = 'Z';*/
        BEGIN
            SELECT f.*
              INTO l_sco
              FROM Ap_Person  p
                   JOIN uss_person.v_sc_info f ON (f.sco_id = p.app_sc)
             WHERE     p.App_Ap = p_Ap_Id
                   AND p.App_Tp = 'Z'
                   AND p.history_status = 'A';
        EXCEPTION
            WHEN OTHERS
            THEN
                SELECT p.app_ln,
                       p.app_fn,
                       p.app_mn,
                       p.app_inn,
                       p.app_doc_num
                  INTO l_sco.sco_ln,
                       l_sco.sco_fn,
                       l_sco.sco_mn,
                       l_sco.sco_numident,
                       l_sco.sco_pasp_number
                  FROM Ap_Person p
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.App_Tp = 'Z'
                       AND p.history_status = 'A';
        END;

        --Надаємо заявнику доступ до кабінету НСП
        /*Garnt_Access(p_Numident => Nvl(l_App.App_Inn, l_App.App_Doc_Num),
                     p_Pib      => l_App.App_Ln || ' ' || l_App.App_Fn || ' ' || l_App.App_Mn);*/

        -- якщо немає РНОКПП по заявнику то немає і іншого.
        IF (NVL (l_sco.sco_numident,
                 l_sco.sco_pasp_seria || l_sco.sco_pasp_number)
                IS NOT NULL)
        THEN
            Garnt_Access (
                p_Numident   =>
                    NVL (l_sco.sco_numident,
                         l_sco.sco_pasp_seria || l_sco.sco_pasp_number),
                p_Pib   =>
                       l_sco.sco_ln
                    || ' '
                    || l_sco.sco_fn
                    || ' '
                    || l_sco.sco_mn);
        END IF;


        --Отримуємо РНОКПП керівника юридичної особи
        l_Boss_Numident :=
            Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                       p_Apda_Nda   => 5575);

        IF     l_Boss_Numident IS NOT NULL
           --Якщо РНОКПП керівника відрізняється від РНОКПП заявник
           AND l_Boss_Numident <>                            /*l_App.App_Inn*/
                                  NVL (l_sco.sco_numident, '-1')
        THEN
            --Надаємо керівнику доступ до кабінету НСП
            Garnt_Access (
                p_Numident   => l_Boss_Numident,
                p_Pib        =>
                       Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 1095)
                    || ' '
                    || Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 1096)
                    || ' '
                    || Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 1097));
        END IF;

        --Отримуємо РОКПП ФОПа
        l_Fop_Numident :=
            Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                       p_Apda_Nda   => 961);

        IF     l_Fop_Numident IS NOT NULL
           AND l_Fop_Numident NOT IN
                   (NVL (l_sco.sco_numident, '-1')           /*l_App.App_Inn*/
                                                  ,
                    NVL (l_Boss_Numident, '-2'))
        THEN
            --Надаємо ФОПу доступ до кабінету НСП
            Garnt_Access (
                p_Numident   => l_Fop_Numident,
                p_Pib        =>
                       Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 963)
                    || ' '
                    || Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 964)
                    || ' '
                    || Api$document.Get_Apda_Str (p_Apda_Apd   => l_Apd_Id,
                                                  p_Apda_Nda   => 965));
        END IF;

        IF l_Email IS NOT NULL
        THEN
            --Відправляємо повідомлення про прийняття рішення та видачу доступів
            Uss_Person.Api$nt_Api.Sendrnspmail (p_Rnspm_Id   => p_Rnspm_Id,
                                                p_Source     => '42',
                                                p_Title      => l_Msg_Title,
                                                p_Text       => l_Msg);
        END IF;
    END;

    --=============================================--
    PROCEDURE Save_appeal_2_rnsp (p_ap_id appeal.ap_id%TYPE)
    IS
        l_RNSP_ST    VARCHAR2 (12);
        l_RNSPS_ID   VARCHAR2 (12);
    BEGIN
        FOR ank
            IN (SELECT ap_ext_ident,
                       ap_reg_dt,
                       ap_st,
                       api$document.Get_Apda_Str (apd.apd_id, 954)    AS RNSP_ST
                  FROM appeal
                       JOIN ap_document apd
                           ON     apd_ap = ap_id
                              AND apd.apd_ndt = 700
                              AND apd.history_status = 'A'
                 WHERE ap_id = p_ap_id)
        LOOP
            CASE ank.RNSP_ST
                WHEN 'A'
                THEN
                    UPDATE rnsp_main
                       SET rnspm_st = 'A'
                     WHERE rnspm_id = ank.ap_ext_ident;

                    grant_Cmes_Access (p_ap_id,
                                       ank.ap_ext_ident,
                                       ank.rnsp_st);
                WHEN 'U'
                THEN
                    SELECT MAX (rnsps_id)
                      INTO l_RNSPS_ID
                      FROM rnsp_state
                     WHERE     history_status = 'A'
                           AND rnsps_rnspm = ank.ap_ext_ident;

                    UPDATE rnsp_state
                       SET history_status = 'H'
                     WHERE     history_status = 'A'
                           AND rnsps_rnspm = ank.ap_ext_ident;

                    Copy_appeal_2_rnsp (p_ap_id,
                                        ank.ap_st,
                                        ank.ap_ext_ident,
                                        l_RNSPS_ID,
                                        TRUE);

                    /**/
                    UPDATE rnsp_main
                       SET rnspm_st = 'A', rnspm_date_out = ''
                     WHERE     rnspm_id = ank.ap_ext_ident
                           AND rnspm_st IN ('D', 'N');

                    /**/
                    grant_Cmes_Access (p_ap_id,
                                       ank.ap_ext_ident,
                                       ank.rnsp_st);
                WHEN 'D'
                THEN
                    UPDATE rnsp_main
                       SET rnspm_st = 'A', rnspm_date_out = ank.ap_reg_dt
                     WHERE rnspm_id = ank.ap_ext_ident;
                ELSE
                    NULL;
            END CASE;
        END LOOP;
    --A  Включено до РНСП
    --U  Зміна відомостей в РНСП
    --D  Виключено з РНСП
    --CASE
    --WHEN l_RNSP_ST = 'A' AND l_rnspm_id IS NULL THEN
    END;

    --=============================================--
    FUNCTION appeal_info (p_id NUMBER)
        RETURN CLOB
    IS
        rezult   CLOB;

        ---------------------------------------------------------
        CURSOR ap IS
            SELECT ap_id,
                      '    <tr>'
                   || '<td>ap_st</td> <td>'
                   || ap_st
                   || '</td>'
                   || '    </tr>'
                   || '    <tr>'
                   || '<td>ap_ext_ident</td>  <td>'
                   || ap_ext_ident
                   || '</td>'
                   || '    </tr>'    AS ap
              FROM appeal
             WHERE ap_id = p_id;

        ---------------------------------------------------------
        CURSOR Doc IS
            SELECT    '    <tr>'
                   || '<td>'
                   || 'ndt_id='
                   || RPAD (ndt_id, 6, ' ')
                   || '</td>'
                   || '<td colspan = 2>'
                   || ndt.ndt_name_short
                   || '</td>'
                   || '<td>'
                   || apd_id
                   || '</td>'
                   || '<td>'
                   || rnd_id
                   || '</td>'
                   || ' </tr>'    AS Doc,
                   ndt_id,
                   apd_id,
                   rnd_id
              FROM uss_ndi.v_ndi_document_type  ndt
                   LEFT JOIN ap_Document
                       ON     apd_ap = p_id
                          AND apd_ndt = ndt_id
                          AND ap_Document.History_Status = 'A'
                   LEFT JOIN rn_document
                       ON     rnd_ap = p_id
                          AND rnd_ndt = ndt_id
                          AND rn_Document.History_Status = 'A'
             WHERE ndt.ndt_id IN
                       (SELECT apd_ndt
                          FROM ap_Document
                         WHERE apd_ap = p_id AND history_status = 'A'
                        UNION
                        SELECT rnd_ndt
                          FROM rn_Document
                         WHERE rnd_ap = p_id AND history_status = 'A');

        ---------------------------------------------------------
        CURSOR atr (p_ndt_id NUMBER, p_apd_id NUMBER, p_rnd_id NUMBER)
        IS
            WITH
                nda
                AS
                    (  SELECT nda.nda_id,
                              nda.nda_order,
                              nda.nda_nng,
                              nng.nng_order,
                              pt_data_type,
                              NVL (nda.nda_name, npt.pt_name)     nda_name,
                              nng.nng_name
                         FROM uss_ndi.v_ndi_document_attr nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                              LEFT JOIN uss_ndi.v_ndi_nda_group nng
                                  ON nng.nng_id = nda.nda_nng
                        WHERE     nda.nda_ndt = p_ndt_id
                              AND nda.history_status = 'A'
                     ORDER BY 4, 2)
            SELECT    '    <tr>'
                   || '<td>'
                   || ''
                   || '</td>'
                   || '<td>'
                   || nng_name
                   || '</td>'
                   || '<td>'
                   || RPAD (TO_CHAR (nda_id), 6, ' ')
                   || ' '
                   || nda_name
                   || '</td>'
                   || '<td>'
                   || apda_val
                   || '</td>'
                   || '<td>'
                   || rnda_val
                   || '</td>'
                   || '</tr>'    AS atr
              FROM (SELECT nda.nda_id,
                           nda.nda_order,
                           nda.nda_nng,
                           nda.nng_order,
                           nda_name,
                           nng_name,
                           CASE pt_data_type
                               WHEN 'STRING'
                               THEN
                                   apda_val_string
                               WHEN 'INTEGER'
                               THEN
                                   TO_CHAR (apda_val_int)
                               WHEN 'SUM'
                               THEN
                                   TO_CHAR (apda_val_sum)
                               WHEN 'ID'
                               THEN
                                   TO_CHAR (apda_val_id)
                               WHEN 'DATE'
                               THEN
                                   TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                               ELSE
                                   '???'
                           END    AS apda_val,
                           CASE pt_data_type
                               WHEN 'STRING'
                               THEN
                                   rnda_val_string
                               WHEN 'INTEGER'
                               THEN
                                   TO_CHAR (rnda_val_int)
                               WHEN 'SUM'
                               THEN
                                   TO_CHAR (rnda_val_sum)
                               WHEN 'ID'
                               THEN
                                   TO_CHAR (rnda_val_id)
                               WHEN 'DATE'
                               THEN
                                   TO_CHAR (rnda_val_dt, 'dd.mm.yyyy')
                               ELSE
                                   '???'
                           END    AS rnda_val
                      FROM nda
                           LEFT JOIN ap_Document_attr apda
                               ON     apda.apda_apd = p_apd_id
                                  AND apda.apda_nda = nda.nda_id
                                  AND apda.history_status = 'A'
                           LEFT JOIN rn_Document_attr rnda
                               ON     rnda.rnda_rnd = p_rnd_id
                                  AND rnda.rnda_nda = nda.nda_id
                                  AND rnda.history_status = 'A')
             WHERE apda_val IS NOT NULL OR rnda_val IS NOT NULL;

        PROCEDURE add (val VARCHAR2)
        IS
        BEGIN
            rezult := rezult || val || CHR (10);
        END;
    BEGIN
        add ('<html>');
        add ('<head/>');
        add ('<Body>');

        FOR p IN ap
        LOOP
            add ('  <Table width=200px  border="1">  ');
            add (p.ap);
            add ('  </Table>');

            add ('  <Table border="1">  ');
            add (
                '    <colgroup>  <col width=10% />  <col width=20% /> <col width=30% />  <col width=20% />  <col width=20% /> </colgroup>');

            FOR d IN doc
            LOOP
                add (d.Doc);

                FOR a IN atr (d.ndt_id, d.apd_id, d.rnd_id)
                LOOP
                    add (a.atr);
                END LOOP;
            END LOOP;

            add ('  </Table>');
        END LOOP;

        add ('</Body>');
        add ('</html>');
        RETURN rezult;
    END;

    --=============================================--
    PROCEDURE dbms_output_appeal_info (p_id NUMBER)
    IS
        CURSOR ap IS
            SELECT *
              FROM appeal
             WHERE ap_id = p_id;

        CURSOR S (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_service
             WHERE aps_ap = p_ap_id AND history_status = 'A';

        CURSOR Z (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('Z', 'O')
                   AND history_status = 'A';

        CURSOR doc (p_ap_id NUMBER)
        IS
            SELECT apd_id,
                   apd_app,
                   apd_ndt,
                   ndt.ndt_name_short,
                      /*'rnd_app='||rpad( rnd.rnd_app, 4,' ')||*/
                      ' rnd_ndt='
                   || RPAD (apd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_Document
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd_ndt
             WHERE     p_ap_id = apd_ap
                   AND apd_aps IS NULL
                   AND ap_Document.history_status = 'A';

        CURSOR doc2 (p_ap_id NUMBER, p_aps_id NUMBER)
        IS
            SELECT rnd.rnd_id,
                   rnd.rnd_app,
                   rnd.rnd_ndt,
                   ndt.ndt_name_short,
                      /*'rnd_app='||rpad( rnd.rnd_app, 4,' ')||*/
                      ' rnd_ndt='
                   || RPAD (rnd.rnd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM Rn_Document  rnd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = rnd.rnd_ndt
             WHERE     p_ap_id = rnd.rnd_ap
                   AND rnd.rnd_aps = p_aps_id
                   AND rnd.history_status = 'A';

        CURSOR rnd (p_ap_id NUMBER)
        IS
            SELECT rnd.rnd_id,
                   rnd.rnd_app,
                   rnd.rnd_ndt,
                   ndt.ndt_name_short,
                      /*'rnd_app='||rpad( rnd.rnd_app, 4,' ')||*/
                      ' rnd_ndt='
                   || RPAD (rnd.rnd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM Rn_Document  rnd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = rnd.rnd_ndt
             WHERE     p_ap_id = rnd.rnd_ap
                   AND rnd.rnd_aps IS NULL
                   AND rnd.history_status = 'A';

        CURSOR rnd2 (p_ap_id NUMBER, p_aps_id NUMBER)
        IS
            SELECT rnd.rnd_id,
                   rnd.rnd_app,
                   rnd.rnd_ndt,
                   ndt.ndt_name_short,
                      /*'rnd_app='||rpad( rnd.rnd_app, 4,' ')||*/
                      ' rnd_ndt='
                   || RPAD (rnd.rnd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM Rn_Document  rnd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = rnd.rnd_ndt
             WHERE     p_ap_id = rnd.rnd_ap
                   AND rnd.rnd_aps = p_aps_id
                   AND rnd.history_status = 'A';

        CURSOR atr (p_apd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT apda_apd,
                              apda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      apda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (apda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (apda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (apda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS apda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM ap_Document_attr apda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = apda.apda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE apda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT apda_apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || apda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY apda_apd)    apda_list
                FROM atr
               WHERE apda_val IS NOT NULL AND atr.apda_apd = p_apd_id
            GROUP BY apda_apd;


        CURSOR rnda (p_rnd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT rnda.rnda_rnd,
                              rnda.rnda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      rnda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (rnda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (rnda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (rnda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (rnda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS rnda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM Rn_Document_attr rnda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = rnda.rnda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE rnda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT rnda_rnd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || rnda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY rnda_rnd)    rnda_list
                FROM atr
               WHERE rnda_val IS NOT NULL AND atr.rnda_rnd = p_rnd_id
            GROUP BY rnda_rnd;
    BEGIN
        FOR d IN ap
        LOOP
            FOR p IN Z (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN S (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    nst=' || p.aps_nst);

                FOR docum IN doc2 (d.ap_id, p.aps_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.rnd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR docum IN doc (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('        ' || docum.doc);

                FOR a IN atr (docum.apd_id)
                LOOP
                    DBMS_OUTPUT.put_line (a.apda_list);
                END LOOP;
            END LOOP;
        END LOOP;
    END;
--=============================================--
END API$Document;
/