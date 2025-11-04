/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_REQ
IS
    -- Author  : SHOSTAK
    -- Created : 17.07.2021 20:29:17
    -- Purpose : обробка відповідей на запити по верифікації
    TYPE r_Doc_Attr IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (1000),
        Val_Dt     DATE,
        Val_Int    NUMBER
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attr;

    c_Pt_App_Id   CONSTANT NUMBER := 309;

    PROCEDURE Set_Tech_Error (p_Rn_Id IN NUMBER, p_Error IN VARCHAR2);

    PROCEDURE Set_Not_Verified (p_Vf_Id IN NUMBER, p_Error IN VARCHAR2);

    PROCEDURE Set_Ok (p_Vf_Id IN NUMBER);

    FUNCTION Reg_Verify_Inn_Init_Req_Person (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Verify_Inn_Init_Req_Doc (p_Rn_Nrt   IN     NUMBER,
                                          p_Obj_Id   IN     NUMBER,
                                          p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Reg_Verify_Inn_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Tp   IN     VARCHAR2,
                                      p_Obj_Id   IN     NUMBER,
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Inn_Init_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Verify_Inn_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Birth_Certificate_Req (p_Rn_Nrt   IN     NUMBER,
                                               p_Obj_Id   IN     NUMBER,
                                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Birth_Certificate_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Death_Cert_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Death_Cert_Resp (p_Ur_Id      IN     NUMBER,
                                             p_Response   IN     CLOB,
                                             p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Verify_Incomes_Req (p_Rn_Nrt   IN     NUMBER,
                                     p_Obj_Id   IN     NUMBER,
                                     p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Verify_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Vpo_Info_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Vpo_Info_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2);

    /* 05/09/2024 serhii: переїхали в Api$verification_Mju
      FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req(p_Rn_Nrt IN NUMBER,
                                                     p_Obj_Id IN NUMBER,
                                                     p_Error  OUT VARCHAR2) RETURN NUMBER;

      PROCEDURE Handle_Verify_Birth_Cert_By_Birthday_Resp(p_Ur_Id    IN NUMBER,
                                                          p_Response IN CLOB,
                                                          p_Error    IN OUT VARCHAR2);

      FUNCTION Reg_Verify_Birth_Cert_By_Name_Req(p_Rn_Nrt IN NUMBER,
                                                 p_Obj_Id IN NUMBER,
                                                 p_Error  OUT VARCHAR2) RETURN NUMBER;

      PROCEDURE Handle_Verify_Birth_Cert_By_Name_Dt_Resp(p_Ur_Id    IN NUMBER,
                                                         p_Response IN CLOB,
                                                         p_Error    IN OUT VARCHAR2);
    */
    FUNCTION Reg_Search_Person_Req (p_Rn_Nrt   IN     NUMBER,
                                    p_Obj_Id   IN     NUMBER,
                                    p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Adopt_Req (p_Rn_Nrt   IN     NUMBER,
                            p_Obj_Id   IN     NUMBER,
                            p_Error       OUT VARCHAR2)
        RETURN NUMBER;
END Api$verification_Req;
/


GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_REQ TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$VERIFICATION_REQ TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_REQ
IS
    FUNCTION Get_Vf_Obj (p_Vf_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT v.Vf_Obj_Id
          INTO l_Result
          FROM Verification v
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Vf_By_Rn (p_Vf_Rn IN Vf_Answer.Vfa_Rn%TYPE)
        RETURN Vf_Answer.Vfa_Vf%TYPE
    IS
        l_Result   Vf_Answer.Vfa_Vf%TYPE;
    BEGIN
        SELECT MAX (a.Vfa_Vf)
          INTO l_Result
          FROM Vf_Answer a
         WHERE a.Vfa_Rn = p_Vf_Rn;

        RETURN l_Result;
    END;

    PROCEDURE Split_Pib (p_Pib   IN     VARCHAR2,
                         p_Ln       OUT VARCHAR2,
                         p_Fn       OUT VARCHAR2,
                         p_Mn       OUT VARCHAR2)
    IS
        l_Pib   VARCHAR2 (250);
    BEGIN
        l_Pib := REPLACE (p_Pib, '  ', '');

            SELECT MAX (CASE
                            WHEN ROWNUM = 1
                            THEN
                                REGEXP_SUBSTR (l_Pib,
                                               '[^ ]+',
                                               1,
                                               LEVEL)
                        END),
                   MAX (CASE
                            WHEN ROWNUM = 2
                            THEN
                                REGEXP_SUBSTR (l_Pib,
                                               '[^ ]+',
                                               1,
                                               LEVEL)
                        END),
                   MAX (CASE
                            WHEN ROWNUM = 3
                            THEN
                                REGEXP_SUBSTR (l_Pib,
                                               '[^ ]+',
                                               1,
                                               LEVEL)
                        END)
              INTO p_Ln, p_Fn, p_Mn
              FROM DUAL
        CONNECT BY REGEXP_SUBSTR (l_Pib,
                                  '[^ ]+',
                                  1,
                                  LEVEL)
                       IS NOT NULL;
    END;

    FUNCTION Get_Doc_Owner_Sc (p_Apd_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        SELECT p.App_Sc
          INTO l_Sc_Id
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = p_Apd_Id;

        RETURN l_Sc_Id;
    END;

    FUNCTION Get_App_Inn (p_App_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_App_Inn   VARCHAR2 (10);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_App_Inn
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON     d.Apd_Id = a.Apda_Apd
                      AND a.Apda_Nda = 1
                      AND a.History_Status = 'A'
         WHERE Apd_App = p_App_Id AND d.History_Status = 'A' AND Apd_Ndt = 5;

        RETURN l_App_Inn;
    END;

    FUNCTION Get_App_Doc_Num (p_App_Id IN NUMBER, p_Ndt_Id IN OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_App_Doc_Num   VARCHAR2 (10);
    BEGIN
          SELECT a.Apda_Val_String, d.Apd_Ndt
            INTO l_App_Doc_Num, p_Ndt_Id
            FROM Ap_Document d
                 JOIN Ap_Document_Attr a
                     ON d.Apd_Id = a.Apda_Apd AND a.History_Status = 'A'
                 JOIN Uss_Ndi.v_Ndi_Document_Attr n
                     ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
           WHERE     Apd_App = p_App_Id
                 AND (   Apd_Ndt = p_Ndt_Id
                      OR (p_Ndt_Id IS NULL AND Apd_Ndt IN (6, 7, 37)))
                 AND d.History_Status = 'A'
        ORDER BY CASE Apd_Ndt WHEN 7 THEN 1 WHEN 6 THEN 2 WHEN 37 THEN 3 END
           FETCH FIRST ROW ONLY;

        RETURN l_App_Doc_Num;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    PROCEDURE Set_Tech_Error (p_Rn_Id IN NUMBER, p_Error IN VARCHAR2)
    IS
        l_Vf_Id   NUMBER;
    BEGIN
        l_Vf_Id := Get_Vf_By_Rn (p_Rn_Id);
        Api$verification.Set_Verification_Status (
            p_Vf_Id       => l_Vf_Id,
            p_Vf_St       => Api$verification.c_Vf_St_Error,
            p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => l_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
            p_Vfl_Message   => p_Error);
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => l_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
            p_Vfl_Message   => CHR (38) || '96');
    END;

    PROCEDURE Set_Not_Verified (p_Vf_Id IN NUMBER, p_Error IN VARCHAR2)
    IS
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                p_Vfl_Message   => p_Error);
        ELSE
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END IF;

        --Змінюємо статус верифікації
        Api$verification.Set_Verification_Status (
            p_Vf_Id       => p_Vf_Id,
            p_Vf_St       => Api$verification.c_Vf_St_Not_Verified,
            p_Vf_Own_St   => Api$verification.c_Vf_St_Not_Verified);
    END;

    PROCEDURE Set_Ok (p_Vf_Id IN NUMBER)
    IS
    BEGIN
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => p_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
            p_Vfl_Message   => CHR (38) || '97');
        --Змінюємо статус верифікації
        Api$verification.Set_Verification_Status (
            p_Vf_Id       => p_Vf_Id,
            p_Vf_St       => Api$verification.c_Vf_St_Ok,
            p_Vf_Own_St   => Api$verification.c_Vf_St_Ok);
    END;

    PROCEDURE Add_Attr (p_Doc_Attrs   IN OUT t_Doc_Attrs,
                        p_Nda_Id      IN     NUMBER,
                        p_Val_Str     IN     VARCHAR2 DEFAULT NULL,
                        p_Val_Dt      IN     DATE DEFAULT NULL,
                        p_Val_Int     IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF p_Doc_Attrs IS NULL
        THEN
            p_Doc_Attrs := t_Doc_Attrs ();
        END IF;

        p_Doc_Attrs.EXTEND ();
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Nda_Id := p_Nda_Id;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Str := p_Val_Str;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Dt := p_Val_Dt;
        p_Doc_Attrs (p_Doc_Attrs.COUNT).Val_Int := p_Val_Int;
    END;

    PROCEDURE Save_Attrs (p_Apd_Id      IN NUMBER,
                          p_Apd_Ap      IN NUMBER,
                          p_Doc_Attrs   IN t_Doc_Attrs)
    IS
    BEGIN
        FOR Rec
            IN (SELECT a.Apda_Id
                  FROM Ap_Document_Attr a
                 WHERE     a.Apda_Apd = p_Apd_Id
                       AND a.History_Status = 'A'
                       AND NOT a.Apda_Nda NOT IN
                                   (SELECT Nda_Id FROM TABLE (p_Doc_Attrs)))
        LOOP
            Api$appeal.Delete_Document_Attr (Rec.Apda_Id);
        END LOOP;

        FOR Rec
            IN (SELECT a.Apda_Id,
                       n.*,
                       CASE
                           WHEN     a.Apda_Id IS NOT NULL
                                AND (   NVL (n.Val_Int, -99999999) <>
                                        NVL (a.Apda_Val_Int, -99999999)
                                     OR NVL (
                                            n.Val_Dt,
                                            TO_DATE ('01.01.1800',
                                                     'dd.mm.yyyy')) <>
                                        NVL (
                                            a.Apda_Val_Dt,
                                            TO_DATE ('01.01.1800',
                                                     'dd.mm.yyyy'))
                                     OR NVL (n.Val_Str, '#') <>
                                        NVL (a.Apda_Val_String, '#'))
                           THEN
                               1
                           ELSE
                               0
                       END    AS Is_Modified
                  FROM TABLE (p_Doc_Attrs)  n
                       LEFT JOIN Ap_Document_Attr a
                           ON     a.Apda_Apd = p_Apd_Id
                              AND a.Apda_Nda = n.Nda_Id
                              AND a.History_Status = 'A')
        LOOP
            IF Rec.Apda_Id IS NOT NULL
            THEN
                IF Rec.Is_Modified = 1
                THEN
                    Api$appeal.Delete_Document_Attr (Rec.Apda_Id);
                ELSE
                    CONTINUE;
                END IF;
            END IF;

            Api$appeal.Save_Document_Attr (p_Apda_Id           => NULL,
                                           p_Apda_Ap           => p_Apd_Ap,
                                           p_Apda_Apd          => p_Apd_Id,
                                           p_Apda_Nda          => Rec.Nda_Id,
                                           p_Apda_Val_Int      => Rec.Val_Int,
                                           p_Apda_Val_Dt       => Rec.Val_Dt,
                                           p_Apda_Val_String   => Rec.Val_Str,
                                           p_Apda_Val_Id       => NULL,
                                           p_Apda_Val_Sum      => NULL,
                                           p_New_Id            => Rec.Apda_Id);
        END LOOP;
    END;

    PROCEDURE Save_Attr (p_Apd_Id            IN NUMBER,
                         p_Ap_Id             IN NUMBER,
                         p_Apda_Nda          IN NUMBER,
                         p_Apda_Val_Int      IN NUMBER DEFAULT NULL,
                         p_Apda_Val_Dt       IN DATE DEFAULT NULL,
                         p_Apda_Val_String   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Apda_Id            NUMBER;
        l_Apda_Is_Modified   NUMBER;
    BEGIN
        SELECT MAX (a.Apda_Id),
               MAX (
                   CASE
                       WHEN     (   p_Apda_Val_Int IS NOT NULL
                                 OR p_Apda_Val_Dt IS NOT NULL
                                 OR p_Apda_Val_String IS NOT NULL)
                            AND (   NVL (p_Apda_Val_Int, -99999999) <>
                                    NVL (a.Apda_Val_Int, -99999999)
                                 OR NVL (
                                        p_Apda_Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy')) <>
                                    NVL (
                                        a.Apda_Val_Dt,
                                        TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
                                 OR NVL (p_Apda_Val_String, '#') <>
                                    NVL (a.Apda_Val_String, '#'))
                       THEN
                           1
                       ELSE
                           0
                   END)
          INTO l_Apda_Id, l_Apda_Is_Modified
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = p_Apd_Id
               AND a.Apda_Nda = p_Apda_Nda
               AND a.History_Status = 'A';

        IF l_Apda_Is_Modified = 1
        THEN
            --Якщо значення існуючого атрибута було змінено, переводимо його в статус "історичний"
            Api$appeal.Delete_Document_Attr (l_Apda_Id);
            l_Apda_Id := NULL;
        END IF;

        Api$appeal.Save_Document_Attr (
            p_Apda_Id           => l_Apda_Id,
            p_Apda_Ap           => p_Ap_Id,
            p_Apda_Apd          => p_Apd_Id,
            p_Apda_Nda          => p_Apda_Nda,
            p_Apda_Val_Int      => p_Apda_Val_Int,
            p_Apda_Val_Dt       => p_Apda_Val_Dt,
            p_Apda_Val_String   => p_Apda_Val_String,
            p_Apda_Val_Id       => NULL,
            p_Apda_Val_Sum      => NULL,
            p_New_Id            => l_Apda_Id);
    END;

    PROCEDURE Add_Err (p_Condition    IN     BOOLEAN,
                       p_Msg          IN     VARCHAR2,
                       p_Error_List   IN OUT VARCHAR2)
    IS
    BEGIN
        IF p_Condition
        THEN
            p_Error_List := p_Error_List || ' ' || p_Msg || ',';
        END IF;
    END;

    FUNCTION Get_Vf_Ap (p_Vf_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        SELECT d.Apd_Ap
          INTO l_Ap_Id
          FROM Verification v JOIN Ap_Document d ON v.Vf_Obj_Id = d.Apd_Id
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Ap_Id;
    END;

    FUNCTION Skip_Verification (p_Apd_Id NUMBER)
        RETURN BOOLEAN
    IS
        l_Src                   VARCHAR2 (10);
        l_Vf_Id                 NUMBER;
        c_Src_Manual   CONSTANT VARCHAR2 (10) := '0';      --Внесено заявником
    BEGIN
        l_Src :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Apd_Id,
                                            p_Nda_Class   => 'SRC');

        IF NVL (l_Src, c_Src_Manual) = c_Src_Manual
        THEN
            RETURN FALSE;
        END IF;

        SELECT d.Apd_Vf
          INTO l_Vf_Id
          FROM Ap_Document d
         WHERE d.Apd_Id = p_Apd_Id;

        Api$verification.Write_Vf_Log (
            p_Vf_Id         => l_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
            p_Vfl_Message   => CHR (38) || '91#@1681@' || l_Src);
        Set_Ok (l_Vf_Id);
        RETURN TRUE;
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до ДФС для верифікації ІПН
    --           (ініціалізація розрахунку)(для участника)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Inn_Init_Req_Person (p_Rn_Nrt   IN     NUMBER,
                                             p_Obj_Id   IN     NUMBER,
                                             p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Reg_Verify_Inn_Init_Req (p_Rn_Nrt   => p_Rn_Nrt,
                                        p_Obj_Tp   => 'P',
                                        p_Obj_Id   => p_Obj_Id,
                                        p_Error    => p_Error);
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до ДФС для верифікації ІПН
    --           (ініціалізація розрахунку)(для документа)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Inn_Init_Req_Doc (p_Rn_Nrt   IN     NUMBER,
                                          p_Obj_Id   IN     NUMBER,
                                          p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Reg_Verify_Inn_Init_Req (p_Rn_Nrt   => p_Rn_Nrt,
                                        p_Obj_Tp   => 'D',
                                        p_Obj_Id   => p_Obj_Id,
                                        p_Error    => p_Error);
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до ДФС для верифікації ІПН
    --                 (ініціалізація розрахунку)
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Inn_Init_Req (p_Rn_Nrt   IN     NUMBER,
                                      p_Obj_Tp   IN     VARCHAR2,
                                      p_Obj_Id   IN     NUMBER,
                                      p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Executor_Wu    NUMBER;
        l_Hs             NUMBER;
        l_Rn_Id          NUMBER;
        l_Ap_Id          NUMBER;
        l_Ap_Reg_Dt      DATE;
        l_Apd_Ndt        Ap_Document.Apd_Ndt%TYPE;
        l_App_Inn        Ap_Person.App_Inn%TYPE;
        l_App_Fn         Ap_Person.App_Fn%TYPE;
        l_App_Mn         Ap_Person.App_Mn%TYPE;
        l_App_Ln         Ap_Person.App_Ln%TYPE;
        l_App_Sc         Ap_Person.App_Sc%TYPE;
        l_App_Birth_Dt   DATE;
        l_Period_Begin   DATE;
        l_Period_End     DATE;
    BEGIN
        BEGIN
            CASE p_Obj_Tp
                --Якщо перевіяряємо ІПН як реквізит учасника
                WHEN 'P'
                THEN
                    --Отримуємо ІПН та інщі реквізити учасника
                    SELECT a.Ap_Reg_Dt,
                           p.App_Ap,
                           p.App_Inn,
                           p.App_Fn,
                           p.App_Mn,
                           p.App_Ln,
                           p.App_Sc,
                           a.Com_Wu
                      INTO l_Ap_Reg_Dt,
                           l_Ap_Id,
                           l_App_Inn,
                           l_App_Fn,
                           l_App_Mn,
                           l_App_Ln,
                           l_App_Sc,
                           l_Executor_Wu
                      FROM Ap_Person p JOIN Appeal a ON p.App_Ap = a.Ap_Id
                     WHERE p.App_Id = p_Obj_Id;
                --Якщо перевіяряємо ІПН як документ
                WHEN 'D'
                THEN
                    --Отримуємо ІПН та інщі реквізити учасника
                    SELECT a.Ap_Reg_Dt,
                           p.App_Ap,
                           a.Apda_Val_String,
                           NVL (
                               Api$appeal.Get_Attr_Val_String (d.Apd_Id,
                                                               'FN'),
                               p.App_Fn),
                           NVL (
                               Api$appeal.Get_Attr_Val_String (d.Apd_Id,
                                                               'MN'),
                               p.App_Mn),
                           NVL (
                               Api$appeal.Get_Attr_Val_String (d.Apd_Id,
                                                               'LN'),
                               p.App_Ln),
                           --#72462: для паспорту та ІД картки дату народження необхідно брати з самих документів
                           CASE
                               WHEN d.Apd_Ndt IN (6, 7)
                               THEN
                                   Api$appeal.Get_Attr_Val_Dt (d.Apd_Id,
                                                               'BDT')
                           END,
                           p.App_Sc,
                           a.Com_Wu,
                           d.Apd_Ndt
                      INTO l_Ap_Reg_Dt,
                           l_Ap_Id,
                           l_App_Inn,
                           l_App_Fn,
                           l_App_Mn,
                           l_App_Ln,
                           l_App_Birth_Dt,
                           l_App_Sc,
                           l_Executor_Wu,
                           l_Apd_Ndt
                      FROM Ap_Document  d
                           JOIN Appeal a ON d.Apd_Ap = a.Ap_Id
                           JOIN Ap_Person p ON d.Apd_App = p.App_Id
                           JOIN Ap_Document_Attr a
                               ON     d.Apd_Id = a.Apda_Apd
                                  AND a.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE d.Apd_Id = p_Obj_Id;
            END CASE;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        SELECT MAX (d.Apr_Start_Dt), MAX (d.Apr_Stop_Dt)
          INTO l_Period_Begin, l_Period_End
          FROM Ap_Declaration d
         WHERE d.Apr_Ap = l_Ap_Id;

        --#73136
        IF l_Period_Begin IS NULL OR l_Period_End IS NULL
        THEN
            l_Period_Begin :=
                  ADD_MONTHS (
                      ADD_MONTHS (
                          TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'Q') - 1,
                          -5),
                      -1)
                + 1;
            l_Period_End := TRUNC (ADD_MONTHS (l_Ap_Reg_Dt, -1), 'Q') - 1;
        END IF;

        IF    l_App_Inn IS NULL
           OR l_App_Fn IS NULL
           OR l_App_Mn IS NULL
           OR l_App_Ln IS NULL
           OR (l_Apd_Ndt IN (6, 7) AND l_App_Birth_Dt IS NULL)
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_App_Inn IS NULL
        THEN
            p_Error :=
                   p_Error
                || CASE
                       WHEN l_Apd_Ndt IN (6, 7)
                       THEN
                           ' серію та номер паспорту'
                       ELSE
                           ' РНОКПП'
                   END
                || ' особи,';
        END IF;

        IF l_App_Fn IS NULL
        THEN
            p_Error := p_Error || ' ім’я особи,';
        END IF;

        IF l_App_Mn IS NULL
        THEN
            p_Error := p_Error || ' по батькові особи,';
        END IF;

        IF l_App_Ln IS NULL
        THEN
            p_Error := p_Error || ' прізвище особи,';
        END IF;

        IF l_Apd_Ndt IN (6, 7) --#72466: Дата народження є обов’язковою тільки для безкодників
                               AND l_App_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження особи';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Dfs.Reg_Income_Sources_Query_Req (
            p_Basis_Request   => '2',                  --'Верифікація РНОКПП',
            p_Executor_Wu     => l_Executor_Wu,
            p_Sc_Id           => l_App_Sc,
            p_Rnokpp          => l_App_Inn,
            p_Last_Name       => l_App_Ln,
            p_First_Name      => l_App_Fn,
            p_Middle_Name     => l_App_Mn,
            p_Date_Birth      => l_App_Birth_Dt,
            p_Period_Begin    => l_Period_Begin,
            p_Period_End      => l_Period_End,
            p_Rn_Nrt          => p_Rn_Nrt,
            p_Rn_Hs_Ins       => l_Hs,
            p_Rn_Src          => Api$appeal.c_Src_Vst,
            p_Rn_Id           => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Inn_Init_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --     Обробка відповіді на запит до ДФС для верифікації ІПН
    --                 (ініціалізація розрахунку)
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Inn_Init_Resp (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
        c_Subreq_Nrt   CONSTANT NUMBER := 3; --тип підзапиту на отримання даних
        l_Rn_Id                 NUMBER;
        l_Vf_Id                 NUMBER;
        l_Repeat                VARCHAR2 (10);
        l_Subreq_Created        VARCHAR2 (10);
    BEGIN
        IF p_Error IS NULL
        THEN
            Ikis_Rbm.Api$request_Dfs.Handle_Income_Sources_Query_Resp (
                p_Ur_Id            => p_Ur_Id,
                p_Response         => p_Response,
                p_Error            => p_Error,
                p_Repeat           => l_Repeat,
                p_Subreq_Created   => l_Subreq_Created,
                p_Subreq_Nrt       => c_Subreq_Nrt,
                p_Rn_Src           => Api$appeal.c_Src_Vst);

            IF l_Repeat = 'T'
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => p_Error);
            END IF;
        ELSE
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --в разі помилки змінюємо статус верифікації
        IF p_Error IS NOT NULL
        THEN
            l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
            Api$verification.Save_Verification_Answer (
                p_Vfa_Rn            => l_Rn_Id,
                p_Vfa_Answer_Data   => p_Response,
                p_Vfa_Vf            => l_Vf_Id);
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                p_Vfl_Message   => p_Error);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END IF;
    END;

    PROCEDURE Handle_Verify_Inn_Resp (p_Ur_Id      IN     NUMBER,
                                      p_Response   IN     CLOB,
                                      p_Error      IN OUT VARCHAR2)
    IS
        l_Ur_Root         NUMBER;
        l_Rn_Id           NUMBER;
        l_Vf_Id           NUMBER;
        l_Error_Message   VARCHAR2 (4000);
    BEGIN
        --Отримуємо ІД кореневого запиту
        l_Ur_Root :=
            Ikis_Rbm.Api$uxp_Request.Get_Root_Request (p_Ur_Id => p_Ur_Id);
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => l_Ur_Root);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь від ДПС
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Res          NUMBER PATH 'Info/result',
                                         Rnokpp       VARCHAR2 (20) PATH 'Info/RNOKPP',
                                         Error        VARCHAR2 (10) PATH 'error',
                                         Error_Msg    VARCHAR2 (4000) PATH 'errorMsg'))
        LOOP
            IF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_Not_Found
            THEN
                --ТЕХНІЧНА ПОМИЛКА(НА БОЦІ ДФС)
                p_Error := Rec.Error_Msg;
                Set_Tech_Error (l_Rn_Id, Rec.Error_Msg);
                RETURN;
            ELSIF Rec.Error = Ikis_Rbm.Api$request_Dfs.c_Err_In_Process
            THEN
                --ЗАПИТ В ОБРОБЦІ
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => Rec.Error_Msg);

                --Встановлюємо ознаку для сервіса, що запит необхідно надіслати повторно
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 30,
                    p_Delay_Reason    => Rec.Error_Msg);
            END IF;

            IF NVL (Rec.Res, 4) = 4        --Код відповіді 4 означає наступне:
                                    --"інформація щодо сум нарахованого доходу та сум утриманого з них податку за вказаний в запиті період в ДРФО відсутня".
                                    --Тому якщо припустити, що він повертається тільки у разі, якщо реквізити коректні, але доходи за період не знайдено,
                                    --вважаємо верифікацію реквізитів успішною.
                                    --Відсутність коду відповіді також є підставою для позитивного результату верифікації.
                                    --Всі інщі коди відповідей повідомляють про некоректність реквізитів.
                                    AND Rec.Rnokpp IS NOT NULL
            THEN
                --УСПІШНА ВЕРИФІКАЦІЯ
                Set_Ok (l_Vf_Id);
            ELSE
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                l_Error_Message :=
                       CHR (38)
                    || CASE Rec.Res
                           WHEN 5 THEN '98'
                           WHEN 6 THEN '99'
                           WHEN 7 THEN '100'
                           WHEN 8 THEN '101'
                           WHEN 9 THEN '102'
                           WHEN 10 THEN '103'
                           WHEN 11 THEN '104'
                           WHEN 12 THEN '105'
                           WHEN 13 THEN '106'
                           ELSE '107'
                       END;
                Set_Not_Verified (l_Vf_Id, l_Error_Message);
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до НАІС для
    --     верифікації свідоцтва про народження
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Birth_Certificate_Req (p_Rn_Nrt   IN     NUMBER,
                                               p_Obj_Id   IN     NUMBER,
                                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_Sc_Id              NUMBER;
        l_Doc_Number         VARCHAR2 (100);
        l_Child_Birth_Dt     DATE;
        l_Child_Pib          VARCHAR2 (250);
        l_Child_Surname      VARCHAR2 (250);
        l_Child_Name         VARCHAR2 (250);
        l_Child_Patronymic   VARCHAR2 (250);
    BEGIN
        l_Sc_Id := Get_Doc_Owner_Sc (p_Obj_Id);

        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'DSN');
        l_Child_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');
        l_Child_Pib :=
            Api$appeal.Get_Attrp_Val_String (p_Apd_Id   => p_Obj_Id,
                                             p_Pt_Id    => 115);
        Split_Pib (l_Child_Pib,
                   l_Child_Surname,
                   l_Child_Name,
                   l_Child_Patronymic);

        IF    l_Child_Birth_Dt IS NULL
           OR l_Child_Surname IS NULL
           OR l_Child_Name IS NULL
           OR l_Child_Patronymic IS NULL
           OR l_Doc_Number IS NULL
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_Doc_Number IS NULL
        THEN
            p_Error := p_Error || ' серію та номер документа,';
        END IF;

        IF l_Child_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження дитини,';
        END IF;

        IF l_Child_Surname IS NULL
        THEN
            p_Error := p_Error || ' прізвище дитини,';
        END IF;

        IF l_Child_Name IS NULL
        THEN
            p_Error := p_Error || ' ім’я дитини,';
        END IF;

        IF l_Child_Patronymic IS NULL
        THEN
            p_Error := p_Error || ' по батькові дитини,';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Birth_Ar_By_Child_Name_And_Birth_Date_Req (
            p_Sc_Id              => l_Sc_Id,
            p_Child_Birth_Dt     => l_Child_Birth_Dt,
            p_Child_Surname      => l_Child_Surname,
            p_Child_Name         => l_Child_Name,
            p_Child_Patronymic   => l_Child_Patronymic,
            p_Rn_Nrt             => p_Rn_Nrt,
            p_Rn_Hs_Ins          => NULL,
            p_Rn_Src             => Api$appeal.c_Src_Vst,
            p_Rn_Id              => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Birth_Certificate_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до НАІС для
    --     верифікації свідоцтва про народження
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Birth_Certificate_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Vf_Id              NUMBER;
        l_Apd_Id             NUMBER;
        l_Doc_Number         VARCHAR2 (100);
        l_Ar_Cnt             NUMBER := 0;
        l_Cert_Cnt           NUMBER := 0;
        l_Result_Code        VARCHAR2 (10);
        l_Result_Data        CLOB;
        l_Response_Payload   CLOB;
        l_Error_Info         CLOB;
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Get_Vf_Obj (l_Vf_Id);
        --Отримуємо серію та номер документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                            p_Nda_Class   => 'DSN');

                --Парсимо основну інформацію з відповіді
                SELECT Result_Code, Result_Data, Error_Info
                  INTO l_Result_Code, l_Result_Data, l_Error_Info
                  FROM XMLTABLE (
                           '/*'
                           PASSING Xmltype (p_Response)
                           COLUMNS Result_Code    VARCHAR2 (10) PATH 'ResultCode',
                                   Result_Data    CLOB PATH 'ResultData',
                                   Error_Info     CLOB PATH 'ErrorInfo');

        IF l_Result_Code = '0'
        THEN
            --Декодуємо перелік актових записів
            l_Response_Payload :=
                CONVERT (Tools.B64_Decode (l_Result_Data),
                         'CL8MSWIN1251',
                         'UTF8');

            --Парсимо актові записи
            FOR Act_Rec
                IN (        SELECT Cerificates
                              FROM XMLTABLE (
                                       '/*/*'
                                       PASSING Xmltype (l_Response_Payload)
                                       COLUMNS Cerificates    XMLTYPE PATH 'CERTIFICATES'))
            LOOP
                l_Ar_Cnt := l_Ar_Cnt + 1;

                               --Шукаємо свідоцтво за серією та номером
                               SELECT COUNT (*)
                                 INTO l_Cert_Cnt
                                 FROM XMLTABLE (
                                          '/*/*'
                                          PASSING Act_Rec.Cerificates
                                          COLUMNS Cert_Serial           VARCHAR2 (10) PATH 'CertSerial',
                                                  Cert_Number           VARCHAR2 (11) PATH 'CertNumber',
                                                  Cert_Serial_Number    VARCHAR2 (21) PATH 'CertSerialNumber')
                                WHERE NVL (Cert_Serial || Cert_Number,
                                           Cert_Serial_Number) =
                                      l_Doc_Number;

                IF l_Cert_Cnt > 0
                THEN
                    Api$verification.Write_Vf_Log (
                        p_Vf_Id    => l_Vf_Id,
                        p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Info,
                        p_Vfl_Message   =>
                            'Підтверджено наявність документа в реєстрі АЗ');
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END LOOP;

            IF l_Ar_Cnt = 0
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Set_Not_Verified (l_Vf_Id, CHR (38) || '108');
                RETURN;
            END IF;

            IF l_Cert_Cnt = 0
            THEN
                --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                Set_Not_Verified (
                    l_Vf_Id,
                    'Свідоцтво про народження в актових записах не знайдено');
            END IF;
        ELSE
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            Set_Not_Verified (l_Vf_Id, l_Error_Info);
        END IF;
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до НАІС для
    --     верифікації АЗ про смерть
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Death_Cert_Req (p_Rn_Nrt   IN     NUMBER,
                                        p_Obj_Id   IN     NUMBER,
                                        p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        --PRAGMA AUTONOMOUS_TRANSACTION;
        l_Rn_Id        NUMBER;
        l_Sc_Id        NUMBER;
        l_Doc_Number   VARCHAR2 (100);
        l_Birth_Dt     DATE;
        l_Pib          VARCHAR2 (250);
        l_Surname      VARCHAR2 (250);
        l_Name         VARCHAR2 (250);
        l_Patronymic   VARCHAR2 (250);
    BEGIN
        l_Sc_Id := Get_Doc_Owner_Sc (p_Obj_Id);

        --Зчитуємо атрибути документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => p_Obj_Id,
                                            p_Nda_Class   => 'DSN');
        l_Pib :=
            Api$appeal.Get_Attrp_Val_String (p_Apd_Id   => p_Obj_Id,
                                             p_Pt_Id    => 176);
        l_Birth_Dt :=
            Api$appeal.Get_Attr_Val_Dt (p_Apd_Id      => p_Obj_Id,
                                        p_Nda_Class   => 'BDT');
        Split_Pib (l_Pib,
                   l_Surname,
                   l_Name,
                   l_Patronymic);

        IF    l_Birth_Dt IS NULL
           OR l_Surname IS NULL
           OR l_Name IS NULL
           OR l_Patronymic IS NULL
           OR l_Doc_Number IS NULL
        THEN
            p_Error := 'Не вказано';
        END IF;

        IF l_Doc_Number IS NULL
        THEN
            p_Error := p_Error || ' серію та номер документа,';
        END IF;

        IF l_Birth_Dt IS NULL
        THEN
            p_Error := p_Error || ' дату народження померлого,';
        END IF;

        IF l_Surname IS NULL
        THEN
            p_Error := p_Error || ' прізвище померлого,';
        END IF;

        IF l_Name IS NULL
        THEN
            p_Error := p_Error || ' ім’я померлого,';
        END IF;

        IF l_Patronymic IS NULL
        THEN
            p_Error := p_Error || ' по батькові померлого,';
        END IF;

        IF p_Error IS NOT NULL
        THEN
            p_Error := RTRIM (p_Error, ',') || '. Створення запиту неможливе';
            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Mju.Reg_Death_Ar_By_Full_Name_And_Birth_Date_Req (
            p_Sc_Id        => l_Sc_Id,
            p_Birth_Dt     => l_Birth_Dt,
            p_Surname      => Clear_Name (l_Surname),
            p_Name         => Clear_Name (l_Name),
            p_Patronymic   => Clear_Name (l_Patronymic),
            p_Rn_Nrt       => p_Rn_Nrt,
            p_Rn_Hs_Ins    => NULL,
            p_Rn_Src       => Api$appeal.c_Src_Vst,
            p_Rn_Id        => l_Rn_Id);
        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Death_Cert_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Try_Parse_Dt (p_Val IN VARCHAR2, p_Fmt IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (p_Val, p_Fmt);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -----------------------------------------------------------------
    --         Збереження атрибутів свідоцтва про смерть
    -----------------------------------------------------------------
    PROCEDURE Save_Deatch_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Ar       IN Ikis_Rbm.Api$request_Mju.r_Death_Act_Record,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Death_Cert)
    IS
        c_Nda_Ar_Reg_Num   CONSTANT NUMBER := 218;
        c_Nda_Ar_Reg_Dt    CONSTANT NUMBER := 221;
        c_Nda_Cert_Dt      CONSTANT NUMBER := 219;
        c_Nda_Cert_Org     CONSTANT NUMBER := 807;
        c_Nda_Death_Dt     CONSTANT NUMBER := 222;

        l_Ap_Id                     NUMBER;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);
        Save_Attr (p_Apd_Id,
                   l_Ap_Id,
                   c_Nda_Ar_Reg_Num,
                   p_Apda_Val_String   => p_Ar.Ar_Reg_Number);
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Ar_Reg_Dt,
            p_Apda_Val_Dt   => Try_Parse_Dt (p_Ar.Ar_Reg_Date, 'dd.mm.yyyy'));
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Cert_Dt,
            p_Apda_Val_Dt   => Try_Parse_Dt (p_Cert.Cert_Date, 'dd.mm.yyyy'));
        Save_Attr (p_Apd_Id,
                   l_Ap_Id,
                   c_Nda_Cert_Org,
                   p_Apda_Val_String   => p_Cert.Cert_Org);
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Death_Dt,
            p_Apda_Val_Dt   => Try_Parse_Dt (p_Ar.Date_Death, 'dd.mm.yyyy'));
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до НАІС для
    --     верифікації АЗ про смерть
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Death_Cert_Resp (p_Ur_Id      IN     NUMBER,
                                             p_Response   IN     CLOB,
                                             p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id         NUMBER;
        l_Vf_Id         NUMBER;
        l_Apd_Id        NUMBER;
        l_Doc_Number    VARCHAR2 (100);
        l_Result_Code   NUMBER;
        l_Error_Info    CLOB;
        l_Ar_List       Ikis_Rbm.Api$request_Mju.t_Death_Act_Record_List;
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Отриуюємо ід документа
        l_Apd_Id := Get_Vf_Obj (l_Vf_Id);
        --Отримуємо серію та номер документа
        l_Doc_Number :=
            Api$appeal.Get_Attr_Val_String (p_Apd_Id      => l_Apd_Id,
                                            p_Nda_Class   => 'DSN');

        --Парсимо відповідь
        l_Ar_List :=
            Ikis_Rbm.Api$request_Mju.Parse_Death_Ar_Resp (
                p_Response      => p_Response,
                p_Resutl_Code   => l_Result_Code,
                p_Error_Info    => l_Error_Info);

        IF NVL (l_Result_Code, 0) <> 0
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            p_Error := l_Error_Info;
            Set_Not_Verified (l_Vf_Id, l_Error_Info);
            RETURN;
        END IF;

        IF l_Ar_List IS NULL OR l_Ar_List.COUNT = 0
        THEN
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Set_Not_Verified (l_Vf_Id, CHR (38) || '108');
            RETURN;
        END IF;

        --Шукаємо свідоцтво про смерть в ортиманих актових записах
        FOR i IN 1 .. l_Ar_List.COUNT
        LOOP
            IF l_Ar_List (i).Certificates IS NULL
            THEN
                CONTINUE;
            END IF;

            DECLARE
                l_Certs   Ikis_Rbm.Api$request_Mju.t_Death_Cert_List;
            BEGIN
                SELECT *
                  BULK COLLECT INTO l_Certs
                  FROM TABLE (l_Ar_List (i).Certificates)
                 WHERE REGEXP_REPLACE (
                           TRIM (
                               TRANSLATE (UPPER (Cert_Serial || Cert_Number),
                                          'ETIOPAHKXCBM’',
                                          'ЕТІОРАНКХСВМ''')),
                           '[^ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЇІЄҐ''1234567890]') =
                       REGEXP_REPLACE (
                           TRIM (
                               TRANSLATE (UPPER (l_Doc_Number),
                                          'ETIOPAHKXCBM’',
                                          'ЕТІОРАНКХСВМ''')),
                           '[^ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЇІЄҐ''1234567890]');

                IF l_Certs.COUNT > 1
                THEN
                    --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
                    Set_Not_Verified (
                        l_Vf_Id,
                           'Знайдено декілька свідоцтв з номером '
                        || l_Doc_Number);
                    RETURN;
                ELSIF l_Certs.COUNT = 1
                THEN
                    --Зберігаємо атрибути свідоцтва
                    Save_Deatch_Cert_Attrs (p_Apd_Id   => l_Apd_Id,
                                            p_Ar       => l_Ar_List (i),
                                            p_Cert     => l_Certs (1));
                    --УСПІШНА ВЕРИФІКАЦІЯ
                    Set_Ok (l_Vf_Id);
                    RETURN;
                END IF;
            END;
        END LOOP;

        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        Set_Not_Verified (l_Vf_Id, CHR (38) || '109');
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту до ПФУ
    --    для верифікації доходів
    -----------------------------------------------------------------
    FUNCTION Reg_Verify_Incomes_Req (p_Rn_Nrt   IN     NUMBER,
                                     p_Obj_Id   IN     NUMBER,
                                     p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id      NUMBER;
        l_Doc_Ser    VARCHAR2 (7);
        l_Doc_Nom    VARCHAR2 (9);
        l_Start_Dt   DATE;
        l_Stop_Dt    DATE;
    BEGIN
        FOR Rec
            IN (SELECT NVL (
                           p.App_Inn,
                           (SELECT MAX (a.Apda_Val_String)
                              FROM Ap_Document  d
                                   JOIN Ap_Document_Attr a
                                       ON     d.Apd_Id = a.Apda_Apd
                                          AND a.History_Status = 'A'
                                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                       ON     a.Apda_Nda = n.Nda_Id
                                          AND n.Nda_Class = 'DSN'
                             WHERE     d.Apd_App = p.App_Id
                                   AND d.Apd_Ndt = 5
                                   AND d.History_Status = 'A'))
                           AS App_Inn,
                       p.App_Ndt,
                       p.App_Doc_Num,
                       p.App_Fn,
                       p.App_Mn,
                       p.App_Ln,
                       p.App_Sc,
                       s.Sc_Unique,
                       b.Scb_Dt,
                       p.App_Ap,
                       p.App_Tp,
                       Ap.Ap_Reg_Dt
                  FROM Ap_Person  p
                       JOIN Appeal Ap ON p.App_Ap = Ap.Ap_Id
                       LEFT JOIN Uss_Person.v_Socialcard s
                           ON p.App_Sc = s.Sc_Id
                       LEFT JOIN Uss_Person.v_Sc_Birth b
                           ON s.Sc_Id = b.Scb_Sc
                 WHERE p.App_Id = p_Obj_Id)
        LOOP
            IF Rec.App_Ndt = 6
            THEN
                l_Doc_Ser := SUBSTR (Rec.App_Doc_Num, 1, 2);
                l_Doc_Nom := SUBSTR (Rec.App_Doc_Num, 3, 9);
            ELSE
                l_Doc_Nom := SUBSTR (Rec.App_Doc_Num, 1, 9);
            END IF;

            --#72638
            IF     Rec.App_Tp = 'FP'
               AND Api$appeal.Service_Exists (p_Aps_Ap    => Rec.App_Ap,
                                              p_Aps_Nst   => 268)
               AND Api$appeal.Get_Person_Relation_Tp (p_App_Id => p_Obj_Id) =
                   'CHRG'
            THEN
                l_Stop_Dt :=
                    LAST_DAY (ADD_MONTHS (TRUNC (Rec.Ap_Reg_Dt), -1));
                l_Start_Dt := ADD_MONTHS (l_Stop_Dt, -13) + 1;
            ELSE
                SELECT MAX (d.Apr_Start_Dt), MAX (d.Apr_Stop_Dt)
                  INTO l_Start_Dt, l_Stop_Dt
                  FROM Ap_Declaration d
                 WHERE d.Apr_Ap = Rec.App_Ap;

                --#73136
                IF l_Start_Dt IS NULL OR l_Stop_Dt IS NULL
                THEN
                    l_Start_Dt :=
                          ADD_MONTHS (
                              ADD_MONTHS (
                                    TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1),
                                           'Q')
                                  - 1,
                                  -5),
                              -1)
                        + 1;
                    l_Stop_Dt :=
                        TRUNC (ADD_MONTHS (Rec.Ap_Reg_Dt, -1), 'Q') - 1;
                END IF;
            END IF;

            IF    Rec.App_Ln IS NULL
               OR Rec.App_Fn IS NULL
               OR l_Start_Dt IS NULL
               OR l_Stop_Dt IS NULL
            THEN
                p_Error := 'Не вказано';
            END IF;

            IF Rec.App_Ln IS NULL
            THEN
                p_Error := p_Error || ' прізвище особи';
            END IF;

            IF Rec.App_Fn IS NULL
            THEN
                p_Error := p_Error || ' ім’я особи';
            END IF;

            IF l_Stop_Dt IS NULL
            THEN
                p_Error := p_Error || ' кінець періоду в декларації';
            END IF;

            IF l_Start_Dt IS NULL
            THEN
                p_Error := p_Error || ' початок періоду в декларації';
            END IF;

            IF p_Error IS NOT NULL
            THEN
                p_Error :=
                    RTRIM (p_Error, ',') || '. Створення запиту неможливе';
                RETURN NULL;
            END IF;

            Ikis_Rbm.Api$request_Pfu.Reg_Upszn_Person_Data_Req (
                p_Sc_Id          => Rec.App_Sc,
                p_Rn_Nrt         => p_Rn_Nrt,
                p_Cod_Upszn      => NULL,
                p_Case_Number    => NULL,
                p_Num_Kss        => Rec.Sc_Unique,
                p_Pn             => Rec.App_Inn,
                p_Ndt_Id         => Rec.App_Ndt,
                p_Doc_Ser        => l_Doc_Ser,
                p_Doc_Nom        => l_Doc_Nom,
                p_Ln             => Rec.App_Ln,
                p_Nm             => Rec.App_Fn,
                p_Ftn            => Rec.App_Mn,
                p_Birthday       => Rec.Scb_Dt,
                p_Period_Start   => l_Start_Dt,
                p_Period_Stop    => l_Stop_Dt,
                p_Ozn_Sub        => NULL,
                p_Rn_Hs_Ins      => NULL,
                p_Rn_Src         => Api$appeal.c_Src_Vst,
                p_Rn_Id          => l_Rn_Id);
        END LOOP;

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Verify_Incomes_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --         Обробка відповіді на запит до ПФУ
    --     для верифікації доходів
    -----------------------------------------------------------------
    PROCEDURE Handle_Verify_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id              NUMBER;
        l_Vf_Id              NUMBER;
        l_Response_Body      CLOB;
        l_Response_Payload   CLOB;
        l_Reponse_Exists     NUMBER;
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

              --Парсимо відповідь
              SELECT Resp_Body
                INTO l_Response_Body
                FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                               '/*'
                               PASSING Xmltype (p_Response)
                               COLUMNS Resp_Body    CLOB PATH 'Body');

        l_Response_Payload := Tools.B64_Decode (l_Response_Body);

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => l_Response_Payload,
            p_Vfa_Vf            => l_Vf_Id);

           SELECT SIGN (COUNT (*))
             INTO l_Reponse_Exists
             FROM XMLTABLE ('/*'
                            PASSING Xmltype (l_Response_Payload)
                            COLUMNS Ext_Id    XMLTYPE PATH 'EXTERNAL_ID')
            WHERE Ext_Id IS NOT NULL;

        --Якщо в прикладній відповіді є хочаб якісь дані - вважаємо верифікацію успішною
        --(по постановці К.Я. 27.07.2021)
        IF l_Reponse_Exists = 1
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '110');
            --УСПІШНА ВЕРИФІКАЦІЯ
            Set_Ok (l_Vf_Id);
        ELSE
            --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
            Set_Not_Verified (l_Vf_Id, CHR (38) || '111');
        END IF;
    END;

    FUNCTION Is_Vpo_Pkg (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Aps_Exists (p_Ap_Id, 664) AND Aps_Exists (p_Ap_Id, 781);
    END;

    -----------------------------------------------------------------
    --         Реєстрація запиту для отримання довідки ВПО
    -----------------------------------------------------------------
    FUNCTION Reg_Vpo_Info_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ap_Id         NUMBER;
        l_App_Id        NUMBER;
        l_App_Tp        VARCHAR2 (10);
        l_App_Inn       VARCHAR2 (10);
        l_App_Ndt       NUMBER;
        l_App_Doc_Num   VARCHAR2 (50);
        l_Req_Param     VARCHAR2 (100);
        l_Sc_Id         NUMBER;
        l_Rn_Id         NUMBER;
    BEGIN
        SELECT d.Apd_Ap,
               d.Apd_App,
               NULLIF (p.App_Inn, '0000000000'),
               p.App_Ndt,
               p.App_Doc_Num,
               p.App_Sc,
               p.App_Tp
          INTO l_Ap_Id,
               l_App_Id,
               l_App_Inn,
               l_App_Ndt,
               l_App_Doc_Num,
               l_Sc_Id,
               l_App_Tp
          FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE d.Apd_Id = p_Obj_Id;

        --Відправляємо запит тільки по заявнику
        --(повязані довідки інших учасників повинні бути у відповіді на цей запит)
        IF l_App_Tp NOT IN ('Z', 'O')
        THEN
            RETURN NULL;
        END IF;

        IF l_App_Inn IS NULL
        THEN
            l_App_Inn := Get_App_Inn (p_App_Id => l_App_Id);
        END IF;

        IF l_App_Inn IS NULL
        THEN
            --Отримуємо документ учасника
            IF l_App_Ndt IS NULL OR l_App_Doc_Num IS NULL
            THEN
                l_App_Ndt := NULL;
                l_App_Doc_Num := Get_App_Doc_Num (l_App_Id, l_App_Ndt);
            END IF;
        END IF;

        l_Req_Param :=
            COALESCE (l_App_Inn,
                      CASE WHEN l_App_Ndt IN (6, 7) THEN l_App_Doc_Num END);

        IF l_Req_Param IS NULL
        THEN
            p_Error :=
                'Для пошуку в реєстрі ВПО потрібні РНОКПП або паспорт громадянина або ІД картка';

            FOR Rec
                IN (SELECT d.Apd_Vf
                      FROM Uss_Visit.Ap_Document d
                     WHERE     d.Apd_Ap = l_Ap_Id
                           AND d.Apd_Ndt = 10052
                           AND d.History_Status = 'A'
                           AND d.Apd_Id <> p_Obj_Id)
            LOOP
                IF Rec.Apd_Vf IS NOT NULL
                THEN
                    Set_Not_Verified (Rec.Apd_Vf, CHR (38) || '112');
                END IF;
            END LOOP;

            RETURN NULL;
        END IF;

        Ikis_Rbm.Api$request_Msp.Reg_Vpo_Info_Req (
            p_Rnokpp      => l_Req_Param,
            p_Sc_Id       => l_Sc_Id,
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => NULL,
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id,
            p_Plan_Dt     =>
                CASE
                    WHEN Is_Vpo_Pkg (l_Ap_Id)
                    THEN
                          SYSDATE
                        + NUMTODSINTERVAL (
                              Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL'),
                              'hour')
                    ELSE
                        SYSDATE
                END);

        RETURN l_Rn_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'Api$verification_Req.Reg_Vpo_Info_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------------
    --      Обробка відповіді на запит для отримання довідки ВПО
    -----------------------------------------------------------------
    PROCEDURE Handle_Vpo_Info_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id      NUMBER;
        l_Apd_Id     NUMBER;
        l_Vf_Id      NUMBER;
        l_Vf_Nvt     NUMBER;
        l_Nrt_Id     NUMBER;
        l_Vpo_Info   Ikis_Rbm.Api$request_Msp.r_Vpo_Info_Resp;
        l_App_Id     NUMBER;
        l_Ap_Vf      NUMBER;
        l_Ap_Id      NUMBER;

        --Збереження основних атрибутів довідки ВПО
        PROCEDURE Save_Vpo_Attrs (
            p_Apd_Id          IN NUMBER,
            p_Vpo_Tp          IN VARCHAR2,
            p_Vpo_Cnt         IN NUMBER,
            p_Vpo_Cert        IN Ikis_Rbm.Api$request_Msp.r_Vpo_Cert,
            p_Vpo_Cert_Main   IN Ikis_Rbm.Api$request_Msp.r_Vpo_Cert DEFAULT NULL)
        IS
            c_Nda_Vpo_Num         CONSTANT NUMBER := 1756;
            c_Nda_Vpo_Gv_Dt       CONSTANT NUMBER := 1757;
            c_Nda_Vpo_Org_Name    CONSTANT NUMBER := 1759;
            c_Nda_Vpo_Tp          CONSTANT NUMBER := 1761;
            c_Nda_Vpo_Cnt         CONSTANT NUMBER := 1762;
            c_Nda_Vpo_Doc_St      CONSTANT NUMBER := 1855;
            --Інформація про заявника
            c_Nda_Vpo_Rnokpp      CONSTANT NUMBER := 1763;
            c_Nda_Vpo_Ln          CONSTANT NUMBER := 1764;
            c_Nda_Vpo_Fn          CONSTANT NUMBER := 1765;
            c_Nda_Vpo_Mn          CONSTANT NUMBER := 1766;
            c_Nda_Vpo_Birthday    CONSTANT NUMBER := 1767;

            c_Nda_Vpo_Guid        CONSTANT NUMBER := 2440;

            --Адреси
            c_Nda_Vpo_Addr_Fact   CONSTANT NUMBER := 2457;
            c_Nda_Vpo_Addr_Reg    CONSTANT NUMBER := 2458;

            l_Doc_Attrs                    t_Doc_Attrs;
        BEGIN
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Num,
                      p_Val_Str   => p_Vpo_Cert.Certificate_Number);
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Gv_Dt,
                      p_Val_Dt   => p_Vpo_Cert.Certificate_Date);
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Org_Name,
                      p_Val_Str   => p_Vpo_Cert.Certificate_Issuer);
            Add_Attr (l_Doc_Attrs, c_Nda_Vpo_Tp, p_Val_Str => p_Vpo_Tp);
            Add_Attr (l_Doc_Attrs, c_Nda_Vpo_Cnt, p_Val_Int => p_Vpo_Cnt);
            Add_Attr (
                l_Doc_Attrs,
                c_Nda_Vpo_Doc_St,
                p_Val_Str   =>
                    CASE REPLACE (UPPER (p_Vpo_Cert.Certificate_State), ' ')
                        WHEN 'ДІЮЧА' THEN 'A'
                        WHEN 'ЗНЯТАЗОБЛІКУ' THEN 'H'
                    END);

            IF p_Vpo_Cert_Main.Certificate_Number IS NOT NULL
            THEN
                Add_Attr (l_Doc_Attrs,
                          c_Nda_Vpo_Rnokpp,
                          p_Val_Str   => p_Vpo_Cert_Main.Rnokpp);
                Add_Attr (
                    l_Doc_Attrs,
                    c_Nda_Vpo_Ln,
                    p_Val_Str   => TRIM (UPPER (p_Vpo_Cert_Main.Idp_Surname)));
                Add_Attr (
                    l_Doc_Attrs,
                    c_Nda_Vpo_Fn,
                    p_Val_Str   => TRIM (UPPER (p_Vpo_Cert_Main.Idp_Name)));
                Add_Attr (
                    l_Doc_Attrs,
                    c_Nda_Vpo_Mn,
                    p_Val_Str   =>
                        TRIM (UPPER (p_Vpo_Cert_Main.Idp_Patronymic)));
                Add_Attr (l_Doc_Attrs,
                          c_Nda_Vpo_Birthday,
                          p_Val_Dt   => p_Vpo_Cert_Main.Birth_Date);
            END IF;

            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Guid,
                      p_Val_Str   => NVL (p_Vpo_Cert.Guid, p_Vpo_Cert.UID));

            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Addr_Fact,
                      p_Val_Str   => p_Vpo_Cert.Fact_Address);
            Add_Attr (l_Doc_Attrs,
                      c_Nda_Vpo_Addr_Reg,
                      p_Val_Str   => p_Vpo_Cert.Reg_Address);

            Save_Attrs (p_Apd_Id, l_Ap_Id, l_Doc_Attrs);
        END;
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL
        THEN
            --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
            --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Парсимо відповідь
        l_Vpo_Info :=
            Ikis_Rbm.Api$request_Msp.Parse_Vpo_Info_Resp (p_Response);

        IF l_Vpo_Info.Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => l_Vpo_Info.Error);
        END IF;

        --Отримуємо ІД учасника
        SELECT v.Vf_Obj_Id,                                       --ІД довідки
               v.Vf_Nvt,                         --Тип верифікації довідки ВПО
               t.Nvt_Nrt,
               Vv.Vf_Obj_Id,    --ІД учасника, по якому було відправлено запит
               Vv.Vf_Vf_Main,                       --ІД верифікації звернення
               Vvv.Vf_Obj_Id
          INTO l_Apd_Id,
               l_Vf_Nvt,
               l_Nrt_Id,
               l_App_Id,
               l_Ap_Vf,
               l_Ap_Id
          FROM Verification  v                           --Верифікація довідки
               JOIN Uss_Ndi.Ndi_Verification_Type t ON v.Vf_Nvt = t.Nvt_Id
               JOIN Verification Vv            --Групуюча верифікація учасника
                                    ON v.Vf_Vf_Main = Vv.Vf_Id
               JOIN Verification Vvv                   --Верифікація звернення
                                     ON Vv.Vf_Vf_Main = Vvv.Vf_Id
         WHERE v.Vf_Id = l_Vf_Id;

        --Блокуємо верифікацію звернення
        SELECT v.Vf_Id
          INTO l_Ap_Vf
          FROM Verification v
         WHERE v.Vf_Id = l_Ap_Vf
        FOR UPDATE;

        -----ВЕРИФІКАЦІЯ ДОВІДКИ УЧАСНИКА, ПО ЯКОМУ БУЛО ВІДПРАВЛЕНО ЗАПИТ-------
        IF l_Vpo_Info.Person.Certificate_Number IS NOT NULL
        THEN
            --Зберігаємо атрибути довідки ВПО
            Save_Vpo_Attrs (l_Apd_Id,
                            'Z',
                            NULLIF (l_Vpo_Info.Accompanied.COUNT, 0),
                            l_Vpo_Info.Person);
            --Успішна верифікація
            Set_Ok (l_Vf_Id);
        END IF;

        -----ВЕРИФІКАЦІЯ ДОВІДОК ПОВЯЗЯНИХ УЧАСНИКІВ------------------------------
        FOR Rec
            IN (SELECT v.Vf_Obj_Id                          AS App_Id,
                       p.App_Tp,
                       Vv.Vf_Obj_Id                         AS Apd_Id,
                       Vv.Vf_Id,
                       NULLIF (p.App_Inn, '0000000000')     AS App_Inn,
                       p.App_Ndt,
                       p.App_Doc_Num,
                       p.App_Sc
                  FROM Verification  v       --Верифікації учасників звернення
                       JOIN Verification Vv --Верифікації документів учасників
                           ON     v.Vf_Id = Vv.Vf_Vf_Main
                              AND Vv.Vf_Nvt = l_Vf_Nvt
                              AND Vv.Vf_St = 'R'
                       JOIN Ap_Person p
                           ON v.Vf_Obj_Id = p.App_Id AND p.App_Id <> l_App_Id
                 WHERE v.Vf_Vf_Main = l_Ap_Vf AND v.Vf_Obj_Tp = 'P')
        LOOP
            DECLARE
                l_Vpo_Cert      Ikis_Rbm.Api$request_Msp.r_Vpo_Cert;
                l_App_Inn       VARCHAR2 (10);
                l_App_Ndt       NUMBER;
                l_App_Doc_Num   VARCHAR2 (50);
                l_Req_Param     VARCHAR2 (100);
                l_Rn_Id         NUMBER;
            BEGIN
                --Отримуємо ІПН учасника
                IF Rec.App_Inn IS NOT NULL
                THEN
                    l_App_Inn := Rec.App_Inn;
                ELSE
                    l_App_Inn := Get_App_Inn (p_App_Id => Rec.App_Id);
                END IF;

                --Отримуємо документ учасника
                IF Rec.App_Ndt IS NOT NULL AND Rec.App_Doc_Num IS NOT NULL
                THEN
                    l_App_Ndt := Rec.App_Ndt;
                    l_App_Doc_Num := Rec.App_Doc_Num;
                ELSE
                    l_App_Doc_Num := Get_App_Doc_Num (Rec.App_Id, l_App_Ndt);
                END IF;

                IF     l_Vpo_Info.Accompanied IS NOT NULL
                   AND l_Vpo_Info.Accompanied.COUNT > 0
                THEN
                    --Шукаємо довідку ВПО для учасника звернення
                    BEGIN
                        SELECT *
                          INTO l_Vpo_Cert
                          FROM TABLE (l_Vpo_Info.Accompanied) a
                         WHERE    a.Rnokpp = l_App_Inn
                               OR (    a.Document_Type = Uss_Ndi.Tools.Decode_Dict (
                                                             'VPO_DOC_TP',
                                                             'USS',
                                                             'VPO',
                                                             l_App_Ndt)
                                   AND REPLACE (
                                           UPPER (
                                                  a.Document_Serie
                                               || a.Document_Number),
                                           ' ') =
                                       l_App_Doc_Num)
                         FETCH FIRST ROW ONLY;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            NULL;
                    END;
                END IF;

                --Якщо довідку учасника знайдено серед повязаних
                IF l_Vpo_Cert.Certificate_Number IS NOT NULL
                THEN
                    --Зберігаємо основні атрибути довідки ВПО
                    Save_Vpo_Attrs (Rec.Apd_Id,
                                    'FM',
                                    l_Vpo_Info.Accompanied.COUNT,
                                    l_Vpo_Cert,
                                    l_Vpo_Info.Person);
                    --Успішна верифікація
                    Set_Ok (Rec.Vf_Id);
                ELSE
                    --Перевіряємо чи є вже створений запит по учаснику
                    SELECT MAX (a.Vfa_Rn)
                      INTO l_Rn_Id
                      FROM Vf_Answer a
                     WHERE a.Vfa_Vf = Rec.Vf_Id;

                    IF l_Rn_Id IS NOT NULL
                    THEN
                        CONTINUE;
                    END IF;

                    l_Req_Param :=
                        COALESCE (
                            l_App_Inn,
                            CASE
                                WHEN l_App_Ndt IN (6, 7) THEN l_App_Doc_Num
                            END);

                    IF l_Req_Param IS NOT NULL
                    THEN
                        --Cтворюємо запит по учаснику
                        Ikis_Rbm.Api$request_Msp.Reg_Vpo_Info_Req (
                            p_Rnokpp      => l_Req_Param,
                            p_Sc_Id       => Rec.App_Sc,
                            p_Rn_Nrt      => l_Nrt_Id,
                            p_Rn_Hs_Ins   => NULL,
                            p_Rn_Src      => Api$appeal.c_Src_Vst,
                            p_Rn_Id       => l_Rn_Id);
                        Api$verification.Link_Request2verification (
                            p_Vfa_Vf   => Rec.Vf_Id,
                            p_Vfa_Rn   => l_Rn_Id);
                    END IF;
                END IF;
            END;
        END LOOP;

        --Якщо у відповідь на запит до реєстру ВПО не повернулась довідка
        --(тільки для пакетних заяв)
        IF     l_Vpo_Info.Person.Certificate_Number IS NULL
           AND Is_Vpo_Pkg (l_Ap_Id)
        THEN
            DECLARE
                l_Time_Since_Reg   NUMBER;
            BEGIN
                --Отримуємо кількість годин, що минули з моменту реєстрації запиту
                SELECT (SYSDATE - v.Vf_Start_Dt) * 24
                  INTO l_Time_Since_Reg
                  FROM Verification v
                 WHERE v.Vf_Id = l_Vf_Id;

                IF l_Time_Since_Reg <
                   TO_NUMBER (
                       Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL_MAX'))
                THEN
                    COMMIT;
                    Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                        p_Ur_Id   => p_Ur_Id,
                        p_Delay_Seconds   =>
                            Tools.Get_Param_Val ('VPO_PKG_VF_INTERVAL') * 60,
                        p_Delay_Reason   =>
                            'Довідки ще немає у вітрині реєстру ВПО');
                END IF;
            END;
        END IF;

        DECLARE
            l_Vf_Cnt_Total   NUMBER;
            l_Vf_Cnt_Ended   NUMBER;
        BEGIN
            SELECT COUNT (*)    AS Vf_Cnt_Total,
                   NVL (SUM (CASE WHEN j.Rn_St <> 'NEW' THEN 1 ELSE 0 END),
                        0)      AS Vf_Cnt_Ended
              INTO l_Vf_Cnt_Total, --Загальна кількість верифікацій довідок ВПО у звернені
                                   l_Vf_Cnt_Ended --Кількість верифікацій довідок ВПО у звернені, що завершились
              FROM Verification  v           --Верифікації учасників звернення
                   JOIN Verification Vv     --Верифікації документів учасників
                       ON v.Vf_Id = Vv.Vf_Vf_Main AND Vv.Vf_Nvt = l_Vf_Nvt --Верифікація довідки ВПО
                   JOIN Vf_Answer a ON Vv.Vf_Id = a.Vfa_Vf
                   JOIN Ikis_Rbm.v_Request_Journal j ON a.Vfa_Rn = j.Rn_Id
             WHERE v.Vf_Vf_Main = l_Ap_Vf AND v.Vf_Obj_Id <> l_App_Id;

            --Якщо завершено всі верифікаційні запити по довідкам ВПО у цьому звернені
            IF l_Vf_Cnt_Total = l_Vf_Cnt_Ended
            THEN
                --Знаходимо верифікації довідок ВПО, які залишились у статусі "Зареєстровано"
                FOR Rec
                    IN (SELECT Vv.Vf_Id,
                               p.App_Id,
                               p.App_Sc,
                               Vv.Vf_Obj_Id     AS Apd_Id
                          FROM Verification  v --Верифікації учасників звернення
                               JOIN Verification Vv --Верифікації документів учасників
                                   ON     v.Vf_Id = Vv.Vf_Vf_Main
                                      AND Vv.Vf_Nvt = l_Vf_Nvt --Верифікація довідки ВПО
                                      AND Vv.Vf_St = 'R'
                               JOIN Ap_Person p ON v.Vf_Obj_Id = p.App_Id
                         WHERE v.Vf_Vf_Main = l_Ap_Vf)
                LOOP
                    IF Rec.App_Sc IS NULL
                    THEN
                        --Шукаємо соцкартку учасника
                        Api$ap2sc.Search_App_Sc (p_App_Id   => Rec.App_Id,
                                                 p_App_Sc   => Rec.App_Sc);
                    END IF;

                    IF Rec.App_Sc > 0
                    THEN
                        DECLARE
                            l_Doc_Attrs   t_Doc_Attrs;
                            l_Is_Actual   NUMBER;
                        BEGIN
                            --Шукаємо довідку ВПО у соцкартці учасника
                            --та вичитуємо атрибути за наявності
                            SELECT a.Da_Nda,
                                   a.Da_Val_String,
                                   a.Da_Val_Dt,
                                   a.Da_Val_Int
                              BULK COLLECT INTO l_Doc_Attrs
                              FROM Uss_Person.v_Sc_Document  d
                                   JOIN Uss_Doc.v_Doc_Attr2hist h
                                       ON d.Scd_Dh = h.Da2h_Dh
                                   JOIN Uss_Doc.v_Doc_Attributes a
                                       ON h.Da2h_Da = a.Da_Id
                             WHERE     d.Scd_Sc = Rec.App_Sc
                                   AND d.Scd_Ndt = 10052
                                   AND d.Scd_St = '1';

                            IF l_Doc_Attrs.COUNT > 0
                            THEN
                                --Перевіряємо актуальність довідки
                                SELECT SIGN (COUNT (*))
                                  INTO l_Is_Actual
                                  FROM TABLE (l_Doc_Attrs)
                                 WHERE Nda_Id = 1855 AND Val_Str = 'A';

                                IF l_Is_Actual = 1
                                THEN
                                    --Зберігаємо атрибути довідки в документ в звернені
                                    Save_Attrs (p_Apd_Id      => Rec.Apd_Id,
                                                p_Apd_Ap      => l_Ap_Id,
                                                p_Doc_Attrs   => l_Doc_Attrs);
                                    --Успішна верифікація
                                    Set_Ok (Rec.Vf_Id);
                                    CONTINUE;
                                END IF;
                            END IF;
                        END;
                    END IF;

                    --Верифікація може бути неуспішною, томущо
                    --Довідку учасника не було знайдено в реєстрі ВПО
                    --ані серед довідок заявників ані серед повязаних довідок
                    --ані в соцкартці учасника
                    Set_Not_Verified (Rec.Vf_Id, CHR (38) || '113');
                END LOOP;
            END IF;
        END;
    END;

    -----------------------------------------------------------------
    -- Збереження атрибутів свідоцтва про народження
    -----------------------------------------------------------------
    PROCEDURE Save_Birth_Cert_Attrs (
        p_Apd_Id   IN NUMBER,
        p_Cert     IN Ikis_Rbm.Api$request_Mju.r_Birth_Certificate)
    IS
        c_Nda_Birth_Child_Bith_Dt   CONSTANT NUMBER := 91;
        c_Nda_Birth_Child_Pib       CONSTANT NUMBER := 92;
        c_Nda_Birth_Mother_Pib      CONSTANT NUMBER := 679;
        c_Nda_Birth_Father_Pib      CONSTANT NUMBER := 680;
        c_Nda_Birth_Cert_Org        CONSTANT NUMBER := 93;
        c_Nda_Birth_Cert_Dt         CONSTANT NUMBER := 94;

        l_Ap_Id                              NUMBER;
    BEGIN
        l_Ap_Id := Api$appeal.Get_Apd_Ap (p_Apd_Id);
        Save_Attr (p_Apd_Id,
                   l_Ap_Id,
                   c_Nda_Birth_Child_Bith_Dt,
                   p_Apda_Val_Dt   => p_Cert.Child_Birthdate);
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Child_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Child_Surname,
                     p_Cert.Child_Name,
                     p_Cert.Child_Patronymic));
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Mother_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Mother_Surname,
                     p_Cert.Mother_Name,
                     p_Cert.Mother_Patronymic));
        Save_Attr (
            p_Apd_Id,
            l_Ap_Id,
            c_Nda_Birth_Father_Pib,
            p_Apda_Val_String   =>
                Pib (p_Cert.Father_Surname,
                     p_Cert.Father_Name,
                     p_Cert.Father_Patronymic));
        Save_Attr (p_Apd_Id,
                   l_Ap_Id,
                   c_Nda_Birth_Cert_Org,
                   p_Apda_Val_String   => p_Cert.Cert_Org);
        Save_Attr (p_Apd_Id,
                   l_Ap_Id,
                   c_Nda_Birth_Cert_Dt,
                   p_Apda_Val_Dt   => p_Cert.Cert_Date);
    END;

    /* 05/09/2024 serhii: переїхали в Api$verification_Mju
      -----------------------------------------------------------------
      --  Реєстрація запиту на верифікацію свідоцтва про народження
      -----------------------------------------------------------------
      FUNCTION Reg_Verify_Birth_Cert_By_Bitrhday_Req(p_Rn_Nrt IN NUMBER,
                                                     p_Obj_Id IN NUMBER,
                                                     p_Error  OUT VARCHAR2) RETURN NUMBER IS
        l_Rn_Id            NUMBER;
        l_Sc_Id            NUMBER;
        l_Cert_Serial      VARCHAR2(10);
        l_Cert_Number      VARCHAR2(50);
        l_Child_Birth_Dt   DATE;
        l_Child_Pib        VARCHAR2(250);
        l_Child_Surname    VARCHAR2(250);
        l_Child_Name       VARCHAR2(250);
        l_Child_Patronymic VARCHAR2(250);
      BEGIN
        IF Skip_Verification(p_Apd_Id => p_Obj_Id) THEN
          RETURN NULL;
        END IF;

        l_Cert_Number := Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'DSN');
        IF l_Cert_Number IS NOT NULL THEN
          l_Cert_Serial := Substr(l_Cert_Number, 1, Length(l_Cert_Number) - 6);
          l_Cert_Number := Substr(l_Cert_Number, Length(l_Cert_Number) - 5, 6);
        END IF;
        l_Child_Birth_Dt := Api$appeal.Get_Attr_Val_Dt(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'BDT');
        l_Child_Pib := Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'PIB');
        Split_Pib(l_Child_Pib, l_Child_Surname, l_Child_Name, l_Child_Patronymic);

        IF l_Cert_Serial IS NULL
           OR l_Cert_Number IS NULL
           OR (l_Child_Birth_Dt IS NULL AND (l_Child_Name IS NULL OR l_Child_Surname IS NULL)) THEN
          p_Error := 'Не вказано';
          Add_Err(l_Cert_Serial IS NULL, 'серію документа', p_Error);
          Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
          Add_Err(l_Child_Birth_Dt IS NULL, 'дату народження дитини', p_Error);
          Add_Err(l_Child_Surname IS NULL, 'прізвище дитини', p_Error);
          Add_Err(l_Child_Name IS NULL, 'ім’я дитини', p_Error);
          Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
          p_Error := Rtrim(p_Error, ',') || '. Створення запиту неможливе';
          RETURN NULL;
        END IF;

        l_Sc_Id := Get_Doc_Owner_Sc(p_Obj_Id);

        IF l_Child_Birth_Dt IS NOT NULL THEN
          Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Birth_Date_Req(p_Cert_Tp     => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                                                                           p_Cert_Role   => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                                                                           p_Cert_Serial => l_Cert_Serial,
                                                                           p_Cert_Number => l_Cert_Number,
                                                                           p_Date_Birth  => l_Child_Birth_Dt,
                                                                           p_Sc_Id       => l_Sc_Id,
                                                                           p_Rn_Nrt      => p_Rn_Nrt,
                                                                           p_Rn_Hs_Ins   => NULL,
                                                                           p_Rn_Src      => Api$appeal.c_Src_Vst,
                                                                           p_Rn_Id       => l_Rn_Id);
        ELSE
          Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Names_Req(p_Cert_Tp     => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                                                                      p_Cert_Role   => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                                                                      p_Cert_Serial => l_Cert_Serial,
                                                                      p_Cert_Number => l_Cert_Number,
                                                                      p_Surname     => l_Child_Surname,
                                                                      p_Name        => l_Child_Name,
                                                                      p_Patronymic  => l_Child_Patronymic,
                                                                      p_Sc_Id       => l_Sc_Id,
                                                                      p_Rn_Nrt      => 27, --todo: додати поле nvt_nrt_alt?
                                                                      p_Rn_Hs_Ins   => NULL,
                                                                      p_Rn_Src      => Api$appeal.c_Src_Vst,
                                                                      p_Rn_Id       => l_Rn_Id);
        END IF;
        RETURN l_Rn_Id;
      END;

      -----------------------------------------------------------------
      -- Обробка відповіді на запит
      -- щодо верифікації свідоцтва про народження(за датою народження)
      -----------------------------------------------------------------
      PROCEDURE Handle_Verify_Birth_Cert_By_Birthday_Resp(p_Ur_Id    IN NUMBER,
                                                          p_Response IN CLOB,
                                                          p_Error    IN OUT VARCHAR2) IS
        l_Rn_Id       NUMBER;
        l_Vf_Id       NUMBER;
        l_Apd_Id      NUMBER;
        l_Cert_List   Ikis_Rbm.Api$request_Mju.t_Birth_Cert_List;
        l_Cert        Ikis_Rbm.Api$request_Mju.r_Birth_Certificate;
        l_Error_Info  VARCHAR2(4000);
        l_Result_Code NUMBER;
        l_Child_Pib   VARCHAR2(250);
      BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn(p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL THEN
          --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
          --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
          --RETURN;
          Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception(p_Ur_Id => p_Ur_Id, p_Delay_Seconds => 300, p_Delay_Reason => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer(p_Vfa_Rn => l_Rn_Id, p_Vfa_Answer_Data => p_Response, p_Vfa_Vf => l_Vf_Id);
        --Парсимо відповідь
        l_Cert_List := Ikis_Rbm.Api$request_Mju.Parse_Birth_Cert_Resp(p_Response    => p_Response,
                                                                      p_Resutl_Code => l_Result_Code,
                                                                      p_Error_Info  => l_Error_Info);

        IF l_Result_Code <> 0 THEN
          --Технічна помилка на боці НАІС
          Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => l_Error_Info);
          RETURN;
        END IF;

        --Отриуюємо ід документа
        l_Apd_Id := Get_Vf_Obj(l_Vf_Id);

        IF l_Cert_List.Count = 0 THEN
          l_Rn_Id := Reg_Verify_Birth_Cert_By_Name_Req(p_Rn_Nrt => 27, --todo: додати поле nvt_nrt_alt?
                                                       p_Obj_Id => l_Apd_Id,
                                                       p_Error  => p_Error);
          IF l_Rn_Id IS NULL THEN
            Set_Not_Verified(l_Vf_Id, Chr(38) || '114');
          ELSE
            Api$verification.Link_Request2verification(p_Vfa_Vf => l_Vf_Id, p_Vfa_Rn => l_Rn_Id);
          END IF;

          RETURN;
        END IF;

        --Отримуємо ПІБ дитини
        l_Child_Pib := Api$appeal.Get_Attr_Val_String(p_Apd_Id => l_Apd_Id, p_Nda_Class => 'PIB');

        IF l_Child_Pib IS NULL
           AND l_Cert_List.Count > 1 THEN
          Set_Not_Verified(l_Vf_Id, Chr(38) || '115');
          RETURN;
        END IF;

        SELECT c.*
          INTO l_Cert
          FROM TABLE(l_Cert_List) c
         ORDER BY Utl_Match.Edit_Distance_Similarity(Upper(Child_Surname || Child_Name || Child_Patronymic),
                                                     Upper(REPLACE(l_Child_Pib, ' '))) DESC
         FETCH FIRST ROW ONLY;

        IF l_Child_Pib IS NOT NULL
           AND REPLACE(Upper(l_Cert.Child_Surname || l_Cert.Child_Name || l_Cert.Child_Patronymic), ' ') <>
           Upper(REPLACE(l_Child_Pib, ' ')) THEN
          Set_Not_Verified(l_Vf_Id,
                           'ПІБ дитини у свідоцтві(' || Upper(l_Child_Pib) || ') не відповідає ПІБ дитини в ДРАЦС(' ||
                           Pib(l_Cert.Child_Surname, l_Cert.Child_Name, l_Cert.Child_Patronymic) || ')');
          RETURN;
        END IF;

        --Зберігаємо атрибути свідоцтва
        Save_Birth_Cert_Attrs(p_Apd_Id => l_Apd_Id, p_Cert => l_Cert);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Set_Ok(l_Vf_Id);
      END;

      -----------------------------------------------------------------
      --  Реєстрація запиту на верифікацію свідоцтва про народження
      -----------------------------------------------------------------
      FUNCTION Reg_Verify_Birth_Cert_By_Name_Req(p_Rn_Nrt IN NUMBER,
                                                 p_Obj_Id IN NUMBER,
                                                 p_Error  OUT VARCHAR2) RETURN NUMBER IS
        l_Rn_Id            NUMBER;
        l_Sc_Id            NUMBER;
        l_Cert_Serial      VARCHAR2(10);
        l_Cert_Number      VARCHAR2(50);
        l_Child_Pib        VARCHAR2(250);
        l_Child_Surname    VARCHAR2(250);
        l_Child_Name       VARCHAR2(250);
        l_Child_Patronymic VARCHAR2(250);
      BEGIN
        l_Cert_Number := Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'DSN');
        IF l_Cert_Number IS NOT NULL THEN
          l_Cert_Serial := Substr(l_Cert_Number, 1, Length(l_Cert_Number) - 6);
          l_Cert_Number := Substr(l_Cert_Number, Length(l_Cert_Number) - 5, 6);
        END IF;

        l_Child_Pib := Api$appeal.Get_Attr_Val_String(p_Apd_Id => p_Obj_Id, p_Nda_Class => 'PIB');
        Split_Pib(l_Child_Pib, l_Child_Surname, l_Child_Name, l_Child_Patronymic);

        IF l_Cert_Serial IS NULL
           OR l_Cert_Number IS NULL
           OR l_Child_Name IS NULL
           OR l_Child_Surname IS NULL THEN
          p_Error := 'Не вказано';
          Add_Err(l_Cert_Serial IS NULL, 'серію документа', p_Error);
          Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
          Add_Err(l_Child_Surname IS NULL, 'прізвище дитини', p_Error);
          Add_Err(l_Child_Name IS NULL, 'ім’я дитини', p_Error);
          Add_Err(l_Cert_Number IS NULL, 'номер документа', p_Error);
          p_Error := Rtrim(p_Error, ',') || '. Створення запиту неможливе';
          RETURN NULL;
        END IF;

        l_Sc_Id := Get_Doc_Owner_Sc(p_Obj_Id);

        Ikis_Rbm.Api$request_Mju.Reg_Get_Cert_By_Num_Role_Names_Req(p_Cert_Tp     => Ikis_Rbm.Api$request_Mju.c_Cert_Tp_Birth,
                                                                    p_Cert_Role   => Ikis_Rbm.Api$request_Mju.c_Cert_Role_Child,
                                                                    p_Cert_Serial => l_Cert_Serial,
                                                                    p_Cert_Number => l_Cert_Number,
                                                                    p_Surname     => l_Child_Surname,
                                                                    p_Name        => l_Child_Name,
                                                                    p_Patronymic  => l_Child_Patronymic,
                                                                    p_Sc_Id       => l_Sc_Id,
                                                                    p_Rn_Nrt      => p_Rn_Nrt,
                                                                    p_Rn_Hs_Ins   => NULL,
                                                                    p_Rn_Src      => Api$appeal.c_Src_Vst,
                                                                    p_Rn_Id       => l_Rn_Id);
        RETURN l_Rn_Id;
      END;

      -----------------------------------------------------------------
      -- Обробка відповіді на запит
      -- щодо верифікації свідоцтва про народження(за ПІБ)
      -----------------------------------------------------------------
      PROCEDURE Handle_Verify_Birth_Cert_By_Name_Dt_Resp(p_Ur_Id    IN NUMBER,
                                                         p_Response IN CLOB,
                                                         p_Error    IN OUT VARCHAR2) IS
        l_Rn_Id          NUMBER;
        l_Vf_Id          NUMBER;
        l_Apd_Id         NUMBER;
        l_Cert_List      Ikis_Rbm.Api$request_Mju.t_Birth_Cert_List;
        l_Cert           Ikis_Rbm.Api$request_Mju.r_Birth_Certificate;
        l_Error_Info     VARCHAR2(4000);
        l_Result_Code    NUMBER;
        l_Child_Birth_Dt DATE;
      BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn(p_Ur_Id => p_Ur_Id);

        IF p_Error IS NOT NULL THEN
          --ТЕХНІЧНА ПОМИЛКА(ПІД ЧАС ВІДПРАВКИ ЗАПИТУ)
          --Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => p_Error);
          --RETURN;
          Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception(p_Ur_Id => p_Ur_Id, p_Delay_Seconds => 300, p_Delay_Reason => p_Error);
        END IF;

        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer(p_Vfa_Rn => l_Rn_Id, p_Vfa_Answer_Data => p_Response, p_Vfa_Vf => l_Vf_Id);
        --Парсимо відповідь
        l_Cert_List := Ikis_Rbm.Api$request_Mju.Parse_Birth_Cert_Resp(p_Response    => p_Response,
                                                                      p_Resutl_Code => l_Result_Code,
                                                                      p_Error_Info  => l_Error_Info);

        IF l_Result_Code <> 0 THEN
          --ТЕХНІЧНА ПОМИЛКА на боці НАІС
          Set_Tech_Error(p_Rn_Id => l_Rn_Id, p_Error => l_Error_Info);
          RETURN;
        END IF;

        --Отриуюємо ід документа
        l_Apd_Id := Get_Vf_Obj(l_Vf_Id);

        IF l_Cert_List.Count = 0 THEN
          Set_Not_Verified(l_Vf_Id, Chr(38) || '114');
          RETURN;
        END IF;

        --Отримуємо дату народження дитини
        l_Child_Birth_Dt := Api$appeal.Get_Attr_Val_Dt(p_Apd_Id => l_Apd_Id, p_Nda_Class => 'BDT');

        SELECT c.*
          INTO l_Cert
          FROM TABLE(l_Cert_List) c
         FETCH FIRST ROW ONLY;

        IF l_Child_Birth_Dt IS NOT NULL
           AND Trunc(l_Cert.Child_Birthdate) <> Trunc(l_Child_Birth_Dt) THEN
          Set_Not_Verified(l_Vf_Id,
                           'Дата народження дитини у свідоцтві(' || To_Char(l_Child_Birth_Dt, 'dd.mm.yyyy') ||
                           ') не відповідає даті народження в ДРАЦС(' || To_Char(l_Cert.Child_Birthdate, 'dd.mm.yyyy') || ')');
          RETURN;
        END IF;

        --Зберігаємо атрибути свідоцтва
        Save_Birth_Cert_Attrs(p_Apd_Id => l_Apd_Id, p_Cert => l_Cert);
        --УСПІШНА ВЕРИФІКАЦІЯ
        Set_Ok(l_Vf_Id);
      END;
    */
    -----------------------------------------------------------------
    --  Реєстрація запиту на пошук особи в РЗО
    -----------------------------------------------------------------
    FUNCTION Reg_Search_Person_Req (p_Rn_Nrt   IN     NUMBER,
                                    p_Obj_Id   IN     NUMBER,
                                    p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Rn_Id              NUMBER;
        l_App_Inn            VARCHAR2 (50);
        l_App_Inn_Verified   NUMBER;
        l_App_Ndt            NUMBER;
        l_App_Doc_Num        Ap_Person.App_Doc_Num%TYPE;
    BEGIN
        p_Error := NULL;

        FOR Rec IN (SELECT *
                      FROM Ap_Person p
                     WHERE p.App_Id = p_Obj_Id AND p.History_Status = 'A')
        LOOP
            IF Rec.App_Inn IS NOT NULL AND Rec.App_Inn <> '0000000000'
            THEN
                l_App_Inn := Rec.App_Inn;

                --Перевіряємо чи верифіковно ІПН, що вказано у реквізитах учасника
                SELECT SIGN (COUNT (*))
                  INTO l_App_Inn_Verified
                  FROM Verification v
                 WHERE     v.Vf_Vf_Main = Rec.App_Vf
                       AND v.Vf_Nvt = 4
                       AND v.Vf_St = Api$verification.c_Vf_St_Ok;
            END IF;

            IF l_App_Inn IS NULL OR NVL (l_App_Inn_Verified, 0) <> 1
            THEN
                BEGIN
                    --Отримуємо ІПН учасника з документів
                    SELECT a.Apda_Val_String
                      INTO l_App_Inn
                      FROM Ap_Document  d
                           JOIN Ap_Document_Attr a
                               ON     d.Apd_Id = a.Apda_Apd
                                  AND a.Apda_Nda = 1
                                  AND a.History_Status = 'A'
                                  AND a.Apda_Val_String IS NOT NULL
                                  AND a.Apda_Val_String <> '0000000000'
                     WHERE     d.Apd_App = Rec.App_Id
                           AND d.History_Status = 'A'
                           AND d.Apd_Ndt = 5
                     FETCH FIRST ROW ONLY;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            END IF;

            BEGIN
                  --Отримуємо документ учасника
                  SELECT a.Apda_Val_String, d.Apd_Ndt
                    INTO l_App_Doc_Num, l_App_Ndt
                    FROM Ap_Document d
                         JOIN Ap_Document_Attr a
                             ON     d.Apd_Id = a.Apda_Apd
                                AND a.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                             ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
                   WHERE     Apd_App = Rec.App_Id
                         AND Apd_Ndt IN (6,
                                         7,
                                         8,
                                         9,
                                         13,
                                         37)
                         AND d.History_Status = 'A'
                ORDER BY CASE Apd_Ndt
                             WHEN 7 THEN 1
                             WHEN 6 THEN 2
                             WHEN 37 THEN 3
                             WHEN 13 THEN 4
                             WHEN 8 THEN 5
                             WHEN 9 THEN 6
                         END
                   FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;

            Ikis_Rbm.Api$request_Pfu.Reg_Get_Person_Unique_Req (
                p_Rn_Nrt      => p_Rn_Nrt,
                p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
                p_Rn_Src      => 'VST',
                p_Rn_Id       => l_Rn_Id,
                p_Ur_Ext_Id   => NULL,
                p_Is_Reg      => 'F',
                p_Numident    => l_App_Inn,
                p_Ln          => Clear_Name (Rec.App_Ln),
                p_Fn          => Clear_Name (Rec.App_Fn),
                p_Mn          => Clear_Name (Rec.App_Mn),
                p_Doc_Tp      => l_App_Ndt,
                p_Doc_Num     => l_App_Doc_Num,
                p_Gender      => Rec.App_Gender,
                p_Birthday    => NULL);
            Ikis_Rbm.Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => l_Rn_Id,
                p_Rnc_Pt       => c_Pt_App_Id,
                p_Rnc_Val_Id   => Rec.App_Id);
            RETURN l_Rn_Id;
        END LOOP;
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на пошук особи в РЗО
    -----------------------------------------------------------------
    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id       NUMBER;
        l_Vf_Id       NUMBER;
        l_App_Id      NUMBER;
        l_Sc_Unique   Uss_Person.v_Socialcard.Sc_Unique%TYPE;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);
        --Обробка відповіді
        Uss_Person.Dnet$exch_Uss2ikis.Handle_Search_Person_Resp (
            p_Ur_Id      => p_Ur_Id,
            p_Response   => p_Response,
            p_Error      => p_Error);

        IF Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id IS NULL
        THEN
            IF Uss_Person.Dnet$exch_Uss2ikis.g_Is_Temp_Error
            THEN
                --ТИМЧАСОВА ПОМИЛКА НА БОЦІ РЗО
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => 'Технічна помилка на боці РЗО');
            ELSE
                --НЕУСПІШНА ВЕРИФІКАЦІЯ
                Set_Not_Verified (l_Vf_Id, NVL (p_Error, CHR (38) || '116'));
                RETURN;
            END IF;
        END IF;

        --Отримуємо ІД учасника звернення
        l_App_Id :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Id (
                p_Rnc_Rn   => l_Rn_Id,
                p_Rnc_Pt   => c_Pt_App_Id);

        SELECT c.Sc_Unique
          INTO l_Sc_Unique
          FROM Uss_Person.v_Socialcard c
         WHERE c.Sc_Id = Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id;

        --Зберігаємо посилання на соцкартку
        UPDATE Ap_Person p
           SET p.App_Sc = Uss_Person.Dnet$exch_Uss2ikis.g_Sc_Id,
               p.App_Esr_Num = l_Sc_Unique
         WHERE p.App_Id = l_App_Id;

        --УСПІШНА ВЕРИФІКАЦІЯ
        Set_Ok (l_Vf_Id);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на усиновлення
    -----------------------------------------------------------------
    FUNCTION Reg_Adopt_Req (p_Rn_Nrt   IN     NUMBER,
                            p_Obj_Id   IN     NUMBER,
                            p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ap_Id      NUMBER;
        l_Ssd_Code   VARCHAR2 (10);
        l_Rn_Id      NUMBER;
    BEGIN
        p_Error := NULL;

          SELECT App_Ap,
                 Uss_Doc.Api$documents.Get_Attr_Val_Str (
                     p_Nda_Class   => 'ORG',
                     p_Dh_Id       => h.Dh_Id)
            INTO l_Ap_Id, l_Ssd_Code
            FROM Ap_Person
                 JOIN Appeal a ON App_Ap = a.Ap_Id
                 JOIN Uss_Doc.v_Doc_Hist h ON a.Ap_Doc = h.Dh_Doc
           WHERE App_Id = p_Obj_Id
        ORDER BY h.Dh_Dt DESC
           FETCH FIRST ROW ONLY;

        Ikis_Rbm.Api$request_Msp.Reg_Save_Adopt_Req (
            p_Rn_Nrt      => p_Rn_Nrt,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src      => Api$appeal.c_Src_Vst,
            p_Rn_Id       => l_Rn_Id,
            p_Ap_Id       => l_Ap_Id,
            p_Ssd_Code    => l_Ssd_Code);

        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запи на усиновлення
    -----------------------------------------------------------------
    PROCEDURE Handle_Adopt_Resp (p_Ur_Id      IN     NUMBER,
                                 p_Response   IN     CLOB,
                                 p_Error      IN OUT VARCHAR2)
    IS
        l_Rn_Id   NUMBER;
        l_Vf_Id   NUMBER;
        l_Resp    Ikis_Rbm.Api$request_Msp.r_Adopt_Resp;
        l_Ap_Id   NUMBER;
    --l_Ap_St VARCHAR2(10);
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        IF p_Error IS NOT NULL
        THEN
            Api$verification.Write_Vf_Log (
                l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   => p_Error);
            RETURN;
        END IF;

        l_Resp := Ikis_Rbm.Api$request_Msp.Parse_Adopt_Resp (p_Response);

        IF l_Resp.Result_Code = Ikis_Rbm.Api$request_Msp.c_Adopt_Resp_Code_Ok
        THEN
            l_Ap_Id := Get_Vf_Ap (l_Vf_Id);
            /* SELECT a.Ap_St
             INTO l_Ap_St
             FROM Appeal a
            WHERE a.Ap_Id = l_Ap_Id;*/
            Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                                  p_Apl_Hs        => Tools.Gethistsession (NULL),
                                  p_Apl_St        => 'N',
                                  p_Apl_Message   => CHR (38) || 22,
                                  p_Apl_St_Old    => 'N',
                                  p_Apl_Tp        => Api$appeal.c_Apl_Tp_Sys);
        ELSIF l_Resp.Result_Code =
              Ikis_Rbm.Api$request_Msp.c_Adopt_Resp_Code_Bad_Req
        THEN
            p_Error :=
                NVL (l_Resp.Result_Tech_Info, 'Некоректні параметри запиту');
            Api$verification.Write_Vf_Log (
                l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   => p_Error);
        ELSE
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => l_Resp.Result_Tech_Info);
        END IF;
    END;
END Api$verification_Req;
/