/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$VERIFICATION
IS
    -- Author  : SHOSTAK
    -- Created : 20.07.2021 12:04:30
    -- Purpose :

    FUNCTION Get_Vf_St_Name (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Vf_St_Value (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2;                   --kolio Значення dic_value по Vf_Id

    PROCEDURE Get_Vf_Protocol (p_Vf_Id          Verification.Vf_Id%TYPE,
                               p_Main_Cur   OUT SYS_REFCURSOR,
                               p_Vf_Cur     OUT SYS_REFCURSOR,
                               p_Log_Cur    OUT SYS_REFCURSOR);

    PROCEDURE Confirm_Verification (p_Vf_Id Verification.Vf_Id%TYPE);

    PROCEDURE Get_Vf_Stats (p_Header1_Cur   OUT SYS_REFCURSOR,
                            p_Header2_Cur   OUT SYS_REFCURSOR,
                            p_Data_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Reg_Diia_Sharing_Request (p_Barcode   IN     VARCHAR2,
                                        p_Rn_Id        OUT NUMBER);

    PROCEDURE Reg_Dsa_Sharing_SS (p_Rnokpp IN VARCHAR2, p_Rn_Id OUT NUMBER);

    PROCEDURE Get_Diia_Sharing_Response (p_Rn_Id   IN     NUMBER,
                                         p_Doc        OUT SYS_REFCURSOR,
                                         p_Attrs      OUT SYS_REFCURSOR,
                                         p_Files      OUT SYS_REFCURSOR);

    PROCEDURE Get_Dsa_Sharing_SS_Response (p_Rn_Id   IN     NUMBER,
                                           p_Doc        OUT SYS_REFCURSOR);


    PROCEDURE Reg_Mju_EDR_Sharing_SS (p_Rnokpp   IN     VARCHAR2,
                                      p_Rn_Id       OUT NUMBER);

    PROCEDURE Get_Mju_EDR_Sharing_SS_Response (
        p_Rn_Id           IN     NUMBER,
        p_EDR_Main_Data      OUT SYS_REFCURSOR);

    PROCEDURE Delay_Verification (p_Ur_Id           IN NUMBER,
                                  p_Delay_Seconds   IN NUMBER);
END Dnet$verification;
/


GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO II01RC_USS_VISIT_WEB
/

GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.DNET$VERIFICATION TO USS_RNSP
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$VERIFICATION
IS
    FUNCTION Get_Vf_St_Name (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Vf_St_Name   Uss_Ndi.v_Ddn_Vf_St.Dic_Name%TYPE;
    BEGIN
        SELECT MAX (s.Dic_Name)
          INTO l_Vf_St_Name
          FROM Verification  v
               JOIN Uss_Ndi.v_Ddn_Vf_St s ON v.Vf_St = s.Dic_Value
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Vf_St_Name;
    END;

    --kolio Значення dic_value по Vf_Id
    FUNCTION Get_Vf_St_Value (p_Vf_Id IN Verification.Vf_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Vf_St_Value   Uss_Ndi.v_Ddn_Vf_St.Dic_Value%TYPE;
    BEGIN
        SELECT MAX (s.Dic_Value)
          INTO l_Vf_St_Value
          FROM Verification  v
               JOIN Uss_Ndi.v_Ddn_Vf_St s ON v.Vf_St = s.Dic_Value
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Vf_St_Value;
    END;

    PROCEDURE Get_Vf_Protocol (p_Vf_Id          Verification.Vf_Id%TYPE,
                               p_Main_Cur   OUT SYS_REFCURSOR,
                               p_Vf_Cur     OUT SYS_REFCURSOR,
                               p_Log_Cur    OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Основна інформация про об’єкт верифікації
        OPEN p_Main_Cur FOR
            SELECT    t.Dic_Name
                   || CASE
                          WHEN v.Vf_Obj_Tp = 'A'
                          THEN
                              (SELECT ' №' || a.Ap_Num
                                 FROM Appeal a
                                WHERE a.Ap_Id = v.Vf_Obj_Id)
                          WHEN v.Vf_Obj_Tp = 'P'
                          THEN
                              (SELECT    ' '
                                      || p.App_Ln
                                      || ' '
                                      || p.App_Fn
                                      || ' '
                                      || p.App_Mn
                                 FROM Ap_Person p
                                WHERE p.App_Id = v.Vf_Obj_Id)
                          WHEN v.Vf_Obj_Tp = 'D'
                          THEN
                              (SELECT    ' "'
                                      || t.Ndt_Name
                                      || '"'
                                 FROM Ap_Document  d
                                      JOIN
                                      Uss_Ndi.v_Ndi_Document_Type
                                      t
                                          ON d.Apd_Ndt =
                                             t.Ndt_Id
                                WHERE d.Apd_Id = v.Vf_Obj_Id)
                      END    AS Vf_Object_Descr,
                   CASE
                       WHEN v.Vf_Own_St IN
                                (Api$verification.c_Vf_St_Error,
                                 Api$verification.c_Vf_St_Not_Verified)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END       AS Confirm_Allowed
              FROM Verification  v
                   JOIN Uss_Ndi.v_Ddn_Vf_Obj_Tp t
                       ON v.Vf_Obj_Tp = t.Dic_Value
             WHERE v.Vf_Id = p_Vf_Id;

        --Дерево верифікацій
        OPEN p_Vf_Cur FOR
                       SELECT v.Vf_Id,
                                 CASE
                                     WHEN LEVEL > 1
                                     THEN
                                         LPAD (Tt.Nvt_Name,
                                               LENGTH (Tt.Nvt_Name) + (LEVEL * 3),
                                               CHR (160))
                                     ELSE
                                         Tt.Nvt_Name
                                 END
                              || CASE
                                     WHEN v.Vf_Obj_Tp = 'P' AND v.Vf_Tp = 'MAIN'
                                     THEN
                                            ' '
                                         || p.App_Ln
                                         || ' '
                                         || SUBSTR (p.App_Fn, 1, 1)
                                         || '.'
                                         || SUBSTR (p.App_Mn, 1, 1)
                                         || '.'
                                     ELSE
                                         ''
                                 END           AS Vf_Nvt_Name,
                              t.Dic_Name       AS Vf_Tp_Name,
                              v.Vf_Start_Dt    AS Vf_Star_Tdt,
                              v.Vf_Stop_Dt,
                              v.Vf_Expected_Stop_Dt,
                              St.Dic_Name      AS Vf_St_Name,
                              s.Hs_Dt          AS Vf_Confirm_Dt,
                              u.Wu_Login       AS Vf_Confirm_Wu,
                              Ost.Dic_Name     AS Vf_Own_St_Name,
                              v.Vf_Tp
                         FROM Verification v
                              JOIN Uss_Ndi.v_Ddn_Vf_Tp t ON v.Vf_Tp = t.Dic_Value
                              JOIN Uss_Ndi.Ndi_Verification_Type Tt
                                  ON v.Vf_Nvt = Tt.Nvt_Id
                              JOIN Uss_Ndi.v_Ddn_Vf_St St ON v.Vf_St = St.Dic_Value
                              LEFT JOIN Uss_Ndi.v_Ddn_Vf_St Ost
                                  ON v.Vf_Own_St = Ost.Dic_Value
                              LEFT JOIN Histsession s ON v.Vf_Hs_Rewrite = s.Hs_Id
                              LEFT JOIN Ikis_Sysweb.V$w_Users_4gic u
                                  ON s.Hs_Wu = u.Wu_Id
                              LEFT JOIN Ap_Person p
                                  ON v.Vf_Obj_Id = p.App_Id AND v.Vf_Obj_Tp = 'P'
                   START WITH v.Vf_Id = p_Vf_Id
                   CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main
            ORDER SIBLINGS BY v.Vf_Start_Dt;

        --Протоколи верифікацій
        --20220808 оптимізація по часу виконання
        OPEN p_Log_Cur FOR
              SELECT l.Vfl_Vf,
                     l.Vfl_Dt,
                     CASE
                         WHEN Vfl_Tp = Api$verification.c_Vfl_Tp_Terror
                         THEN
                             REPLACE (
                                    'Технічна помилка: '
                                 || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                        l.Vfl_Message)
                                 || '. Інформація для розробника: код події='
                                 || Vfl_Id
                                 || '. Будь ласка, зверніться до розробника',
                                 '..',
                                 '.')
                         ELSE
                             Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                 l.Vfl_Message)
                     END           AS Vfl_Message,
                     t.Dic_Name    AS Vfl_Tp_Name
                FROM Vf_Log l
                     --OUTER треба, бо вже є неправильні записи, і їх треба відобразити
                     LEFT OUTER JOIN Uss_Ndi.v_Ddn_Vfl_Tp t
                         ON l.Vfl_Tp = t.Dic_Value
                     JOIN Verification tf ON l.Vfl_Vf = tf.vf_id
               WHERE     l.Vfl_Vf IN (    SELECT t.Vf_Id
                                            FROM Verification t
                                      START WITH t.Vf_Id = p_Vf_Id
                                      CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                     --Якщо веріфікація ще в процессі, то треба віводити помилки процесу
                     AND (   (tf.Vf_St = API$VERIFICATION.c_Vf_St_Reg)
                          OR (l.vfl_tp <> API$VERIFICATION.c_Vfl_Tp_Process))
            --Виключаємо технічні помилки
            -- AND l.Vfl_Tp <> Api$verification.c_Vfl_Tp_Terror
            ORDER BY l.Vfl_Vf, l.Vfl_Dt, l.Vfl_Id;
    END;

    PROCEDURE Confirm_Verification (p_Vf_Id Verification.Vf_Id%TYPE)
    IS
        l_Vf_Nvt                 NUMBER;
        l_Vf_Obj_Tp              VARCHAR2 (10);
        l_Vf_Obj_Id              NUMBER;
        l_Vf_St                  VARCHAR2 (10);
        l_Nvt_Can_Confirm        VARCHAR2 (10);
        l_Nvt_Ndt                NUMBER;
        l_Hs                     NUMBER;
        l_Hs_Wu                  NUMBER;
        l_Attrs                  VARCHAR2 (4000);
        l_Is_All_Docs_Verified   NUMBER;
        l_cnt                    NUMBER;
    BEGIN
        Tools.Writemsg ('DNET$VERIFICATION.' || $$PLSQL_UNIT);

        IF p_Vf_Id IS NULL
        THEN
            Raise_Application_Error (-20000,
                                     'Не обрано протокол верифікації');
        END IF;

        SELECT Vf_Nvt,
               Vf_Obj_Tp,
               Vf_Obj_Id,
               Vf_St,
               Nvt_Can_Confirm,
               Nvt_Ndt
          INTO l_Vf_Nvt,
               l_Vf_Obj_Tp,
               l_Vf_Obj_Id,
               l_Vf_St,
               l_Nvt_Can_Confirm,
               l_Nvt_Ndt
          FROM Verification
               JOIN Uss_Ndi.Ndi_Verification_Type ON Vf_Nvt = Nvt_Id
         WHERE Vf_Id = p_Vf_Id;

        IF l_Vf_St NOT IN
               (Api$verification.c_Vf_St_Error,
                Api$verification.c_Vf_St_Not_Verified)
        THEN
            Raise_Application_Error (
                -20000,
                'Підтвердження верифікації в поточному статусі заборонено');
        END IF;

        IF NVL (l_Nvt_Can_Confirm, 'F') <> 'T'
        THEN
            Raise_Application_Error (
                -20000,
                'Підтвердження верифікації вручну заборонено');
        END IF;

        l_Hs := Tools.Gethistsession;

        SELECT h.Hs_Wu
          INTO l_Hs_Wu
          FROM Histsession h
         WHERE Hs_Id = l_Hs;

        IF NVL (l_Hs_Wu, -1) < 1
        THEN
            Raise_Application_Error (
                -20000,
                'Не визначено користувача, що виконує підтвердження верифікації. Будь ласка, повторіть спробу або зверніться до розробника');
        END IF;

        IF l_Vf_Obj_Tp = 'D'
        THEN
            BEGIN
                WITH
                    Ndi
                    AS
                        (SELECT n.Nda_Id, n.Nda_Name, n.Nda_Order
                           FROM Uss_Ndi.v_Ndi_Document_Attr n
                          WHERE     n.Nda_Ndt = l_Nvt_Ndt
                                AND n.History_Status = 'A'
                                AND n.Nda_Is_Req = 'T')
                SELECT LISTAGG (n.Nda_Name, ', ')
                           WITHIN GROUP (ORDER BY Nda_Order)
                  INTO l_Attrs
                  FROM Ndi  n
                       LEFT JOIN Ap_Document_Attr a
                           ON     a.Apda_Apd = l_Vf_Obj_Id
                              AND a.History_Status = 'A'
                              AND n.Nda_Id = a.Apda_Nda
                 WHERE     a.Apda_Val_Int IS NULL
                       AND a.Apda_Val_Dt IS NULL
                       AND a.Apda_Val_String IS NULL
                       AND a.Apda_Val_Id IS NULL
                       AND a.Apda_Val_Sum IS NULL;
            EXCEPTION
                WHEN OTHERS
                THEN
                    --На випадок, якщо перелік назв незаповнених обовязкових атрибутів перевищую 4000 символів
                    Raise_Application_Error (
                        -20000,
                        'Для підтвердження верифікації необхідно заповнити всі обов`язкові атрибути документа');
            END;

            SELECT NVL ( (SELECT COUNT (*)
                            FROM uss_doc.v_doc_attachments z
                           WHERE z.dat_dh = t.apd_dh),
                        0)    AS cnt
              INTO l_cnt
              FROM ap_document t
             WHERE t.apd_vf = p_Vf_Id;

            IF (l_cnt = 0)
            THEN
                raise_application_error (
                    -20000,
                    'Заборонено підтверджувати документ без сканкопії');
            END IF;
        END IF;

        IF l_Attrs IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Для підтвердження верифікації необхідно заповнити обов`язкові атрибути документа: '
                || l_Attrs);
        END IF;

        IF l_Vf_Obj_Tp = 'A'
        THEN
            SELECT DECODE (COUNT (*), 0, 1, 0)
              INTO l_Is_All_Docs_Verified
              FROM Ap_Document d JOIN Verification v ON d.Apd_Vf = v.Vf_Id
             WHERE     d.Apd_Ap = l_Vf_Obj_Id
                   AND d.History_Status = 'A'
                   AND v.Vf_St <> 'X';

            IF l_Is_All_Docs_Verified <> 1
            THEN
                Raise_Application_Error (
                    -20000,
                       'Для підтвердження верифікації звернення необхідно підтвердити всі верифікації документів: '
                    || l_Attrs);
            END IF;
        END IF;

        Api$verification.Set_Verification_Status (
            p_Vf_Id           => p_Vf_Id,
            p_Vf_St           => Api$verification.c_Vf_St_Ok,
            p_Vf_Own_St       => NULL,
            p_Vf_Hs_Rewrite   => l_Hs);
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => p_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
            p_Vfl_Message   => CHR (38) || '139#' || l_Hs_Wu);
    END;

    PROCEDURE Get_Vf_Stats (p_Header1_Cur   OUT SYS_REFCURSOR,
                            p_Header2_Cur   OUT SYS_REFCURSOR,
                            p_Data_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Header1_Cur FOR
            SELECT 'Успішних верифікацій документів' AS Col_Name FROM DUAL
            UNION ALL
            SELECT 'Не успішних верифікацій документів' AS Col_Name FROM DUAL
            UNION ALL
            SELECT 'Ручних підтверджень верифікації звернення'    AS Col_Name
              FROM DUAL;

        OPEN p_Header2_Cur FOR
            SELECT *
              FROM (    SELECT TO_CHAR (TRUNC (SYSDATE) - LEVEL + 1, 'dd.mm')    AS Col_Name
                          FROM DUAL
                    CONNECT BY LEVEL <= 5
                      ORDER BY 1)
            UNION ALL
            SELECT *
              FROM (    SELECT TO_CHAR (TRUNC (SYSDATE) - LEVEL + 1, 'dd.mm')    AS Col_Name
                          FROM DUAL
                    CONNECT BY LEVEL <= 5
                      ORDER BY 1)
            UNION ALL
            SELECT *
              FROM (    SELECT TO_CHAR (TRUNC (SYSDATE) - LEVEL + 1, 'dd.mm')    AS Col_Name
                          FROM DUAL
                    CONNECT BY LEVEL <= 5
                      ORDER BY 1);

        OPEN p_Data_Cur FOR
            WITH
                Doc_Stats
                AS
                    (  SELECT /*+ MATERIALIZE */
                              a.Com_Org,
                              --Успішних верифікацій документів
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St = 'X'
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 4
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col1,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St = 'X'
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 3
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col2,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St = 'X'
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 2
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col3,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St = 'X'
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 1
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col4,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St = 'X'
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE)
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col5,
                              --Не успішних верифікацій документів
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St IN ('E', 'N')
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 4
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col6,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St IN ('E', 'N')
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 3
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col7,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St IN ('E', 'N')
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 2
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col8,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St IN ('E', 'N')
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE) - 1
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col9,
                              SUM (
                                  CASE
                                      WHEN     v.Vf_St IN ('E', 'N')
                                           AND TRUNC (v.Vf_Stop_Dt) =
                                               TRUNC (SYSDATE)
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col10
                         FROM Ap_Document d
                              JOIN Verification v
                                  ON     d.Apd_Vf = v.Vf_Id
                                     AND v.Vf_Stop_Dt > TRUNC (SYSDATE) - 4
                                     AND v.Vf_St IN ('X', 'E', 'N')
                              JOIN Appeal a ON d.Apd_Ap = a.Ap_Id
                     GROUP BY a.Com_Org),
                Ap_Stats
                AS
                    (  SELECT /*+ MATERIALIZE */
                              a.Com_Org,
                              --Ручних підтверджень верифікації звернення
                              SUM (
                                  CASE
                                      WHEN TRUNC (v.Vf_Stop_Dt) =
                                           TRUNC (SYSDATE) - 4
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col11,
                              SUM (
                                  CASE
                                      WHEN TRUNC (v.Vf_Stop_Dt) =
                                           TRUNC (SYSDATE) - 3
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col12,
                              SUM (
                                  CASE
                                      WHEN TRUNC (v.Vf_Stop_Dt) =
                                           TRUNC (SYSDATE) - 2
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col13,
                              SUM (
                                  CASE
                                      WHEN TRUNC (v.Vf_Stop_Dt) =
                                           TRUNC (SYSDATE) - 1
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col14,
                              SUM (
                                  CASE
                                      WHEN TRUNC (v.Vf_Stop_Dt) =
                                           TRUNC (SYSDATE)
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)    AS Col15
                         FROM Appeal a
                              JOIN Verification v
                                  ON     a.Ap_Vf = v.Vf_Id
                                     AND v.Vf_Stop_Dt > TRUNC (SYSDATE) - 4
                                     AND v.Vf_St = 'X'
                                     AND v.Vf_St <> v.Vf_Own_St
                     GROUP BY a.Com_Org)
              SELECT o.Org_Name,
                     NVL (Dst.Col1, 0)      AS Col1,
                     NVL (Dst.Col2, 0)      AS Col2,
                     NVL (Dst.Col3, 0)      AS Col3,
                     NVL (Dst.Col4, 0)      AS Col4,
                     NVL (Dst.Col5, 0)      AS Col5,
                     NVL (Dst.Col6, 0)      AS Col6,
                     NVL (Dst.Col7, 0)      AS Col7,
                     NVL (Dst.Col8, 0)      AS Col8,
                     NVL (Dst.Col9, 0)      AS Col9,
                     NVL (Dst.Col10, 0)     AS Col10,
                     NVL (Ast.Col11, 0)     AS Col11,
                     NVL (Ast.Col12, 0)     AS Col12,
                     NVL (Ast.Col13, 0)     AS Col13,
                     NVL (Ast.Col14, 0)     AS Col14,
                     NVL (Ast.Col15, 0)     AS Col15
                FROM Doc_Stats Dst
                     FULL OUTER JOIN Ap_Stats Ast ON Dst.Com_Org = Ast.Com_Org
                     JOIN Ikis_Sys.v_Opfu o
                         ON NVL (Dst.Com_Org, Ast.Com_Org) = o.Org_Id
            ORDER BY 1;
    END;

    ---------------------------------------------------------------------------------
    --              Реєстрація запиту на шеринг
    ---------------------------------------------------------------------------------
    PROCEDURE Reg_Diia_Sharing_Request (p_Barcode   IN     VARCHAR2,
                                        p_Rn_Id        OUT NUMBER)
    IS
    BEGIN
        Tools.Writemsg ('DNET$VERIFICATION.' || $$PLSQL_UNIT);
        Ikis_Rbm.Api$request_Diia.Reg_Sharing_Request (
            p_Barcode    => p_Barcode,
            p_Skip_Pdf   => 'F',
            p_Wu_Id      => Tools.Getcurrwu,
            p_Src        => Api$appeal.c_Src_Vst,
            p_Com_Org    => Tools.Getcurrorg,
            p_Rn_Id      => p_Rn_Id);
    END;

    PROCEDURE Reg_Dsa_Sharing_SS (p_Rnokpp IN VARCHAR2, p_Rn_Id OUT NUMBER)
    IS
    BEGIN
        Ikis_Rbm.Api$request_Dsa.Reg_Decision_Req (
            p_Rnokpp      => p_Rnokpp,
            p_Rn_Nrt      => 79,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => p_Rn_Id,
            p_Wu_Id       => Tools.Getcurrwu);
    END;


    PROCEDURE Reg_Mju_EDR_Sharing_SS (p_Rnokpp   IN     VARCHAR2,
                                      p_Rn_Id       OUT NUMBER)
    IS
    BEGIN
        Ikis_Rbm.Api$request_Mju.Reg_Nsp_Mju_Sharing_Data_Req (
            p_Rn_Nrt      => 69,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => p_Rn_Id,
            p_Numident    => p_Rnokpp,
            p_Wu_Id       => Tools.Getcurrwu);
    END;

    ---------------------------------------------------------------------------------
    --              Отримання відповіді на шеринг
    ---------------------------------------------------------------------------------
    PROCEDURE Get_Diia_Sharing_Response (p_Rn_Id   IN     NUMBER,
                                         p_Doc        OUT SYS_REFCURSOR,
                                         p_Attrs      OUT SYS_REFCURSOR,
                                         p_Files      OUT SYS_REFCURSOR)
    IS
        l_Resp     Ikis_Rbm.Api$request_Diia.r_Sharing_Response;
        l_Error    VARCHAR2 (4000);
        l_Attrs    Ikis_Rbm.Api$request_Diia.t_Doc_Attrs;
        l_Ndt_Id   NUMBER;
        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
        l_Apd_Id   NUMBER;
        l_Vf_Id    NUMBER;
    BEGIN
        Tools.Writemsg ('DNET$VERIFICATION.' || $$PLSQL_UNIT);

        IF NOT Ikis_Rbm.Api$request_Diia.Get_Sharing_Response (
                   p_Rn_Id      => p_Rn_Id,
                   p_Wu_Id      => Tools.Getcurrwu,
                   p_Response   => l_Resp,
                   p_Error      => l_Error)
        THEN
            IF l_Error IS NOT NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Під час шерінгу документа виникла помилка('
                    || p_Rn_Id
                    || '). Будь ласка, повторіть зчитування штрихкода');
            END IF;

            RETURN;
        END IF;

        --Конвертуємо відповідь від Дії у атрибути документа
        l_Attrs :=
            Ikis_Rbm.Api$request_Diia.Get_Shared_Doc_Attrs (
                p_Shared_Doc   => l_Resp,
                p_Doc_Ndt      => l_Ndt_Id);
        --Зберігаємо документ та зріз в архів
        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => l_Ndt_Id,
                                             p_Doc_Actuality   => 'A',
                                             p_New_Id          => l_Doc_Id);
        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => l_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => l_Ndt_Id,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   => 'A',
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => Tools.Getcurrwu,
            p_Dh_Src         => Api$appeal.c_Src_Vst,
            p_New_Id         => l_Dh_Id);
        --Зберігаємо документ, що потім буде привязано до звернення
        --Робимо це саме на цьому етапі, щоб одразу привязати до нього протокол верифікації,
        --томущо посилання на протоко верифікації, під час збереження звернення з клієнта не передаються(і не повинні).
        Api$appeal.Save_Document (
            p_Apd_Id                => NULL,
            p_Apd_Ap                => NULL,
            p_Apd_Ndt               => l_Ndt_Id,
            p_Apd_Doc               => l_Doc_Id,
            p_Apd_Vf                => NULL,
            p_Apd_App               => NULL,
            p_New_Id                => l_Apd_Id,
            p_Com_Wu                => Tools.Getcurrwu,
            p_Apd_Dh                => l_Dh_Id,
            p_Apd_Aps               => NULL,
            p_Apd_Tmp_To_Del_File   => NULL,
            p_Apd_Src               => Api$appeal.c_Src_Vst);

        --Зберігаємо атрибути документа
        FOR i IN 1 .. l_Attrs.COUNT
        LOOP
            DECLARE
                l_Apda_Id   NUMBER;
            BEGIN
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => NULL,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => l_Attrs (i).Nda_Id,
                    p_Apda_Val_Int      => NULL,
                    p_Apda_Val_Dt       => l_Attrs (i).Val_Dt,
                    p_Apda_Val_String   => l_Attrs (i).Val_Str,
                    p_Apda_Val_Id       => l_Attrs (i).Val_Id,
                    p_Apda_Val_Sum      => NULL,
                    p_New_Id            => l_Apda_Id);
            END;
        END LOOP;

        --Зберігаємо протокол верифікації
        Api$verification.Save_Verification (
            p_Vf_Id                 => NULL,
            p_Vf_Vf_Main            => NULL,
            p_Vf_Tp                 => 'SHR',
            p_Vf_St                 => Api$verification.c_Vf_St_Ok,
            p_Vf_Own_St             => Api$verification.c_Vf_St_Ok,
            p_Vf_Start_Dt           => SYSDATE,
            p_Vf_Stop_Dt            => NULL,
            p_Vf_Expected_Stop_Dt   => NULL,
            p_Vf_Nvt                => Api$verification.c_Nvt_Diia_Sharing,
            p_Vf_Obj_Tp             => 'D',
            p_Vf_Obj_Id             => l_Apd_Id,
            p_Vf_Hs_Rewrite         => NULL,
            p_New_Id                => l_Vf_Id);

        --Зберігаємо посилання на протокол верифікації у документ
        UPDATE Ap_Document d
           SET d.Apd_Vf = l_Vf_Id
         WHERE d.Apd_Id = l_Apd_Id;

        --Привязуємо запит до протоколу верифікації
        Api$verification.Link_Request2verification (p_Vfa_Vf   => l_Vf_Id,
                                                    p_Vfa_Rn   => p_Rn_Id);

        ------ДОКУМЕНТИ------
        OPEN p_Doc FOR SELECT l_Apd_Id                AS Apd_Id,
                              l_Ndt_Id                AS Apd_Ndt,
                              t.Ndt_Name              AS Apd_Ndt_Name,
                              l_Doc_Id                AS Apd_Doc,
                              l_Dh_Id                 AS Apd_Dh,
                              l_Vf_Id                 AS Apd_Vf,
                              t.Ndt_Is_Vt_Visible     AS Is_Shown,
                              'T'                     Is_Read_Only
                         FROM Uss_Ndi.v_Ndi_Document_Type t
                        WHERE t.Ndt_Id = l_Ndt_Id;

        ------АТРИБУТИ------
        OPEN p_Attrs FOR SELECT l_Apd_Id     AS Apda_Apd,
                                l_Doc_Id     AS Doc_Id,
                                a.Apda_Nda,
                                a.Apda_Val_String,
                                a.Apda_Val_Int,
                                a.Apda_Val_Dt,
                                a.Apda_Val_Id,
                                a.Apda_Val_Sum,
                                l_Dh_Id      AS Dh_Id
                           FROM Ap_Document_Attr a
                          WHERE a.Apda_Apd = l_Apd_Id;

        ------ВКЛАДЕННЯ------
        OPEN p_Files FOR
            SELECT l_Resp.File_Name      AS File_Name,
                   'application/pdf'     AS File_Mime_Type,
                   l_Resp.File_Data      AS File_Data,
                   l_Resp.File_Sign      AS File_Sign
              FROM DUAL;
    END;

    PROCEDURE Get_Dsa_Sharing_SS_Response (p_Rn_Id   IN     NUMBER,
                                           p_Doc        OUT SYS_REFCURSOR)
    IS
        l_Resp     Ikis_Rbm.Api$request_Dsa.t_Sharing_Response;
        l_Error    VARCHAR2 (4000);
        l_Ndt_Id   NUMBER;
        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
        l_Apd_Id   NUMBER;
        l_Vf_Id    NUMBER;
    BEGIN
        Tools.Writemsg ('DNET$VERIFICATION.' || $$PLSQL_UNIT);

        IF NOT Ikis_Rbm.Api$request_Dsa.Get_Sharing_Response (
                   p_Rn_Id      => p_Rn_Id,
                   p_Wu_Id      => Tools.Getcurrwu,
                   p_Response   => l_Resp,
                   p_Error      => l_Error)
        THEN
            IF l_Error IS NOT NULL AND INSTR (l_Error, 'Data not found') > 0
            THEN
                Raise_Application_Error (-20000,
                                         'Відомості відсутні в ЄДРСР');
            ELSIF l_Error IS NOT NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Під час пошуку в ДСА виникла помилка('
                    || p_Rn_Id
                    || ') - '
                    || l_Error);
            END IF;

            RETURN;
        END IF;


        ------ДОКУМЕНТИ------
        OPEN p_Doc FOR SELECT * FROM TABLE (l_Resp);
    END;

    PROCEDURE Get_Mju_EDR_Sharing_SS_Response (
        p_Rn_Id           IN     NUMBER,
        p_EDR_Main_Data      OUT SYS_REFCURSOR)
    IS
        l_Main_Data   Ikis_Rbm.Api$request_Mju.t_Nsp_EDR_Main_Data_List;
    BEGIN
        Tools.Writemsg ('DNET$VERIFICATION.' || $$PLSQL_UNIT);
        Ikis_Rbm.Api$request_Mju.Get_Nsp_Mju_Sharing_Response (
            p_Rn_Id                    => p_Rn_Id,
            p_Nsp_EDR_Main_Data_List   => l_Main_Data);

        OPEN p_EDR_Main_Data FOR SELECT * FROM TABLE (l_Main_Data);
    END;

    PROCEDURE Delay_Verification (p_Ur_Id           IN NUMBER,
                                  p_Delay_Seconds   IN NUMBER)
    IS
        l_Vf_Id   Verification.Vf_Id%TYPE;
    BEGIN
        l_Vf_Id := API$VERIFICATION.Get_Ur_Vf (p_Ur_Id);
        API$VERIFICATION.Merge_Vf_Log (
            p_Vf_Id         => l_Vf_Id,
            p_Vfl_Tp        => API$VERIFICATION.c_Vfl_Tp_Process,
            p_Vfl_Message   => CHR (38) || '283');
        API$VERIFICATION.Merge_Vf_Log (
            p_Vf_Id    => l_Vf_Id,
            p_Vfl_Tp   => API$VERIFICATION.c_Vfl_Tp_Process,
            p_Vfl_Message   =>
                   'Запит буде перевідправлено через '
                || p_Delay_Seconds
                || ' секунд');
    END;
END Dnet$verification;
/