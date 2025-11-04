/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_DSA
IS
    -- Author  : SHOSTAK
    -- Created : 13.07.2023 11:31:51 PM
    -- Purpose :

    FUNCTION Reg_Decision_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Decision_Req_SS (p_Rn_Nrt   IN     NUMBER,
                                  p_Obj_Id   IN     NUMBER,
                                  p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Need_Save_Decision (p_Ur_Id               IN     NUMBER,
                                 p_Case_Num            IN     VARCHAR2,
                                 p_Doc_Type_Id         IN     VARCHAR2,
                                 p_Doc_Date            IN     VARCHAR2,
                                 p_Reg_Num             IN     VARCHAR2,
                                 p_Cause_Category_Id   IN     VARCHAR2,
                                 p_Dh_Id                  OUT NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Set_Verified (p_Ur_Id        IN NUMBER,
                            p_Law_Dt       IN VARCHAR2,
                            p_Court_Name   IN VARCHAR2);

    PROCEDURE Set_Not_Verified (p_Ur_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Tech_Error (p_Ur_Id IN NUMBER, p_Error IN VARCHAR2);
END Api$verification_Dsa;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_DSA TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_DSA
IS
    -------------------------------------------------------------------
    --    Реєстрація запиту на отримання судового рішення
    -------------------------------------------------------------------
    FUNCTION Reg_Decision_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_App      Ap_Person%ROWTYPE;
        l_Rnokpp   VARCHAR2 (10);
        l_Rn_Id    NUMBER;
    BEGIN
        SELECT p.*
          INTO l_App
          FROM Ap_Document  d
               JOIN Ap_Person p
                   ON     d.Apd_Ap = p.App_Ap
                      AND p.App_Tp = 'Z'
                      AND p.History_Status = 'A'
         WHERE d.Apd_Id = p_Obj_Id;

        IF l_App.App_Inn IS NOT NULL AND l_App.App_Inn <> '0000000000'
        THEN
            IF REGEXP_LIKE (l_App.App_Inn, '^[0-9]{10}$')
            THEN
                l_Rnokpp := l_App.App_Inn;
            ELSE
                p_Error := 'ІПН має некорекний формат';
            END IF;
        ELSIF l_App.App_Doc_Num IS NOT NULL
        THEN
            IF l_App.App_Ndt = 6
            THEN
                IF REGEXP_LIKE (l_App.App_Doc_Num, '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                THEN
                    l_Rnokpp := l_App.App_Doc_Num;
                ELSE
                    p_Error := 'Паспорт має некоректний формат';
                END IF;
            ELSIF l_App.App_Ndt = 7
            THEN
                IF REGEXP_LIKE (l_App.App_Doc_Num, '^[0-9]{9}$')
                THEN
                    l_Rnokpp := l_App.App_Doc_Num;
                ELSE
                    p_Error := 'ІД карта має некоректний формат';
                END IF;
            ELSE
                p_Error := 'Не вказано ІПН або серію та номер паспорта';
            END IF;
        ELSE
            p_Error := 'Не вказано ІПН або серію та номер паспорта';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error :=
                   RTRIM (p_Error, ',')
                || '. Неможливо отримати судове рішення від ДСА';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Dsa.Reg_Decision_Req (
            p_Rnokpp      => l_Rnokpp,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id);

        RETURN l_Rn_Id;
    END;

    FUNCTION Reg_Decision_Req_SS (p_Rn_Nrt   IN     NUMBER,
                                  p_Obj_Id   IN     NUMBER,
                                  p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_App      Ap_Person%ROWTYPE;
        l_Rnokpp   VARCHAR2 (10);
        l_Rn_Id    NUMBER;
    BEGIN
        SELECT p.*
          INTO l_App
          FROM Ap_Document  d
               JOIN Ap_Person p
                   ON d.Apd_App = p.App_Id AND p.History_Status = 'A'
         WHERE d.Apd_Id = p_Obj_Id;

        IF l_App.App_Inn IS NOT NULL AND l_App.App_Inn <> '0000000000'
        THEN
            IF REGEXP_LIKE (l_App.App_Inn, '^[0-9]{10}$')
            THEN
                l_Rnokpp := l_App.App_Inn;
            ELSE
                p_Error := 'ІПН має некорекний формат';
            END IF;
        ELSIF l_App.App_Doc_Num IS NOT NULL
        THEN
            IF l_App.App_Ndt = 6
            THEN
                IF REGEXP_LIKE (l_App.App_Doc_Num, '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                THEN
                    l_Rnokpp := l_App.App_Doc_Num;
                ELSE
                    p_Error := 'Паспорт має некоректний формат';
                END IF;
            ELSIF l_App.App_Ndt = 7
            THEN
                IF REGEXP_LIKE (l_App.App_Doc_Num, '^[0-9]{9}$')
                THEN
                    l_Rnokpp := l_App.App_Doc_Num;
                ELSE
                    p_Error := 'ІД карта має некоректний формат';
                END IF;
            ELSE
                p_Error := 'Не вказано ІПН або серію та номер паспорта';
            END IF;
        ELSE
            p_Error := 'Не вказано ІПН або серію та номер паспорта';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error :=
                   RTRIM (p_Error, ',')
                || '. Неможливо отримати судове рішення від ДСА';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Dsa.Reg_Decision_Req (
            p_Rnokpp      => l_Rnokpp,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id);

        RETURN l_Rn_Id;
    END;

    -------------------------------------------------------------------
    --    Визначення необхідності збереження судового рішення
    -------------------------------------------------------------------
    FUNCTION Need_Save_Decision (p_Ur_Id               IN     NUMBER,
                                 p_Case_Num            IN     VARCHAR2,
                                 p_Doc_Type_Id         IN     VARCHAR2, --Ignore
                                 p_Doc_Date            IN     VARCHAR2,
                                 p_Reg_Num             IN     VARCHAR2, --Ignore
                                 p_Cause_Category_Id   IN     VARCHAR2, --Ignore
                                 p_Dh_Id                  OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_Vf_Id           NUMBER;
        l_Apd_Id          NUMBER;
        l_Ap_Id           NUMBER;
        l_Doc_Id          NUMBER;
        l_Ndt_Id          NUMBER;
        l_Attach_Exists   NUMBER;
    BEGIN
        l_Vf_Id := Api$verification.Get_Ur_Vf (p_Ur_Id);
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        SELECT d.Apd_Ap,
               d.Apd_Dh,
               d.Apd_Doc,
               d.Apd_Ndt
          INTO l_Ap_Id,
               p_Dh_Id,
               l_Doc_Id,
               l_Ndt_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = l_Apd_Id;

        /*IF Api$verification_Cond.Is_Attach_Exists(l_Apd_Id) THEN
          RETURN 'F';
        END IF;*/

        /*FOR Rec IN (SELECT s.Aps_Nst
                      FROM Ap_Service s
                     WHERE s.Aps_Ap = l_Ap_Id
                       AND s.History_Status = 'A')
        LOOP
          IF Rec.Aps_Nst IN (269)
             AND p_Cause_Category_Id IN ('40408' \*,'40407',  '40409', '1036'*\) THEN
            RETURN 'T';
          END IF;

          IF Rec.Aps_Nst IN (248, 265, 267)
             AND p_Cause_Category_Id IN ('40408', '40458' \*, '40407', '40409', '1036'*\)
             AND Api$appeal.Get_Attr_Val_String(l_Apd_Id, 'DSN') = p_Case_Num
             AND Api$appeal.Get_Attr_Val_Dt(l_Apd_Id, 'DGVDT') = To_Date(p_Doc_Date, 'YYYY-MM-DD') THEN
            RETURN 'T';
          END IF;
        END LOOP;*/

        IF     Api$appeal.Get_Attr_Val_String (l_Apd_Id, 'DSN') = p_Case_Num
           AND Api$appeal.Get_Attr_Val_Dt (l_Apd_Id, 'DGVDT') =
               TO_DATE (p_Doc_Date, 'YYYY-MM-DD')
        THEN
            --Перевіряємо наявність скану у поточному зрізі документа
            SELECT SIGN (COUNT (*))
              INTO l_Attach_Exists
              FROM Uss_Doc.v_Doc_Attachments a
             WHERE a.Dat_Dh = p_Dh_Id;

            --За постановкою О.Синиці від 20102023: якщо наявний скан, то замінюємо його новим
            IF l_Attach_Exists = 1
            THEN
                --для цього створюємо новий зріз документа
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => l_Ndt_Id,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'A',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => 'VST',
                    p_Dh_Cu          => NULL,
                    p_New_Id         => p_Dh_Id);

                --Прописуємо посилання на зріз
                UPDATE Ap_Document d
                   SET d.Apd_Dh = p_Dh_Id
                 WHERE d.Apd_Id = l_Apd_Id;
            END IF;

            RETURN 'T';
        END IF;

        RETURN 'F';
    END;

    -------------------------------------------------------------------
    --    Встановлення статусу "Успішна верифікація"
    -------------------------------------------------------------------
    PROCEDURE Set_Verified (p_Ur_Id        IN NUMBER,
                            p_Law_Dt       IN VARCHAR2,
                            p_Court_Name   IN VARCHAR2)
    IS
        l_Vf_Id     NUMBER;
        l_Apd_Id    NUMBER;
        l_Ap_Id     NUMBER;
        l_Ndt_Id    NUMBER;
        l_App_Pib   VARCHAR2 (4000);

        FUNCTION Get_Nda (p_Nda_Class IN VARCHAR2)
            RETURN NUMBER
        IS
            l_Nda_Id   NUMBER;
        BEGIN
            SELECT MAX (a.Nda_Id)
              INTO l_Nda_Id
              FROM Uss_Ndi.v_Ndi_Document_Attr a
             WHERE a.Nda_Ndt = l_Ndt_Id AND a.Nda_Class = p_Nda_Class;

            RETURN l_Nda_Id;
        END;
    BEGIN
        l_Vf_Id := Api$verification.Get_Ur_Vf (p_Ur_Id);
        l_Apd_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);

        SELECT d.Apd_Ap,
               d.Apd_Ndt,
               UPPER (
                      TRIM (p.App_Ln)
                   || ' '
                   || TRIM (p.App_Fn)
                   || ' '
                   || TRIM (p.App_Mn))
          INTO l_Ap_Id, l_Ndt_Id, l_App_Pib
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = l_Apd_Id;

        Api$appeal.Save_Attr (
            p_Apd_Id        => l_Apd_Id,
            p_Ap_Id         => l_Ap_Id,
            p_Apda_Nda      => Get_Nda ('DSTDT'),
            p_Apda_Val_Dt   => TO_DATE (p_Law_Dt, 'YYYY-MM-DD'));
        Api$appeal.Save_Attr (p_Apd_Id            => l_Apd_Id,
                              p_Ap_Id             => l_Ap_Id,
                              p_Apda_Nda          => Get_Nda ('DORG'),
                              p_Apda_Val_String   => p_Court_Name);
        Api$appeal.Save_Attr (p_Apd_Id            => l_Apd_Id,
                              p_Ap_Id             => l_Ap_Id,
                              p_Apda_Nda          => Get_Nda ('PIB'),
                              p_Apda_Val_String   => l_App_Pib);
        Api$verification.Set_Ok (
            p_Vf_Id   => Api$verification.Get_Ur_Vf (p_Ur_Id));
    END;

    -------------------------------------------------------------------
    --    Встановлення статусу "Верифікацію не пройдено"
    -------------------------------------------------------------------
    PROCEDURE Set_Not_Verified (p_Ur_Id IN NUMBER, p_Reason IN VARCHAR2 --Ignore
                                                                       )
    IS
        l_Vf_Id      NUMBER;
        l_Ap_Id      NUMBER;
        l_Obj_Id     NUMBER;
        l_Ap_Src     VARCHAR2 (10);
        l_Ap_Tp      VARCHAR2 (10);
        l_Ndt_Name   VARCHAR2 (500);
    BEGIN
        l_Vf_Id := Api$verification.Get_Ur_Vf (p_Ur_Id);
        l_Obj_Id := Api$verification.Get_Vf_Obj (l_Vf_Id);
        l_Ap_Id := Api$verification.Get_Vf_Ap (l_Vf_Id);
        l_Ap_Src := Api$appeal.Get_Ap_Src (l_Ap_Id);
        l_Ap_Tp := Api$appeal.Get_Ap_Tp (l_Ap_Id);


        IF (l_ap_tp = 'SS')
        THEN
            SELECT MAX (t.ndt_name)
              INTO l_Ndt_Name
              FROM Ap_Document  d
                   JOIN uss_ndi.v_ndi_document_type t
                       ON (t.ndt_id = d.apd_ndt)
             WHERE d.Apd_Id = l_Obj_Id;

            Api$verification.Set_Not_Verified (
                p_Vf_Id   => l_Vf_Id,
                p_Error   => CHR (38) || '159' || '#' || l_Ndt_Name);
        ELSE
            Api$verification.Set_Not_Verified (
                p_Vf_Id   => l_Vf_Id,
                p_Error   =>
                       CHR (38)
                    || CASE WHEN l_Ap_Src = 'DIIA' THEN '245' ELSE '262' END);
        END IF;


        IF l_Ap_Src IN ('DIIA', 'DRACS')
        THEN
            UPDATE Appeal
               SET Ap_St = 'X'
             WHERE Ap_Id = l_Ap_Id AND Ap_St = 'VW';

            IF SQL%ROWCOUNT > 0
            THEN
                Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                                      p_Apl_Hs        => Tools.Gethistsession,
                                      p_Apl_St        => 'X',
                                      p_Apl_Message   => CHR (38) || '245',
                                      p_Apl_St_Old    => 'VW');

                --Формуємо рішення про відмову
                Dnet$appeal_Ext.Create_Decision_Doc (
                    p_Ap_Id   => l_Ap_Id,
                    p_Refuse_Reason   =>
                        Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                            CHR (38) || '245'));
                --Реєструємо запит на передачу статуса до Дії
                Dnet$appeal_Ext.Reg_Diia_Status_Send_Req (
                    p_Ap_Id         => l_Ap_Id,
                    p_Ap_St         => 'X',
                    p_Message       => CHR (38) || '245',
                    p_Decision_Dt   => SYSDATE);
                --Реєструємо запит на передачу статуса до ДРАЦС
                Dnet$exch_Mju.Reg_Dracs_Application_Result_Req (
                    p_Ap_Id     => l_Ap_Id,
                    p_Ap_St     => 'X',
                    p_Message   => CHR (38) || '245');
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------
    --    Встановлення статусу "Технічна помилка"
    -------------------------------------------------------------------
    PROCEDURE Set_Tech_Error (p_Ur_Id IN NUMBER, p_Error IN VARCHAR2)
    IS
    BEGIN
        Api$verification.Set_Tech_Error (
            p_Rn_Id   =>
                Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id),
            p_Error   => p_Error);
    END;
END Api$verification_Dsa;
/