/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_SEARCH
IS
    -- Author  : SHOSTAK
    -- Created : 27.11.2023 1:02:50 PM
    -- Purpose :

    FUNCTION Get_At_St_Name (p_At_St IN VARCHAR2, p_At_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Get_Acts_Urgent_Pr (p_Cmes_Owner_Id   IN     NUMBER,
                                  p_At_Dt_Start     IN     DATE,
                                  p_At_Dt_Stop      IN     DATE,
                                  p_At_Num          IN     VARCHAR2,
                                  --4) ПІБ відповідальної особи, якою сформовано Договір
                                  p_Creator_Pib     IN     VARCHAR2,
                                  --5) ПІБ отримувача соціальної послуги
                                  p_Receiver_Pib    IN     VARCHAR2,
                                  --6) ПІБ законного представника / уповноваженої особи ОСП
                                  p_Agent_Pib       IN     VARCHAR2,
                                  --8) Наявність документів на підпис
                                  p_At_St           IN     VARCHAR2,
                                  p_Need_Sign       IN     VARCHAR2,
                                  p_Acts               OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Urgent_Rc (p_At_Dt_Start    IN     DATE,
                                  p_At_Dt_Stop     IN     DATE,
                                  p_At_Num         IN     VARCHAR2,
                                  --4) ПІБ відповідальної особи, якою сформовано Договір
                                  p_Creator_Pib    IN     VARCHAR2,
                                  --5) ПІБ отримувача соціальної послуги
                                  p_Receiver_Pib   IN     VARCHAR2,
                                  --6) ПІБ законного представника / уповноваженої особи ОСП
                                  p_Agent_Pib      IN     VARCHAR2,
                                  --8) Наявність документів на підпис
                                  p_At_St          IN     VARCHAR2,
                                  p_Need_Sign      IN     VARCHAR2,
                                  p_Acts              OUT SYS_REFCURSOR);
END Cmes$act_Search;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_SEARCH TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_SEARCH TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:23 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_SEARCH
IS
    FUNCTION Get_At_St_Name (p_At_St IN VARCHAR2, p_At_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
        TOOLS.validate_param (p_At_Tp);

        EXECUTE IMMEDIATE   'SELECT DIC_NAME FROM USS_NDI.V_DDN_AT_'
                         || p_At_Tp
                         || '_ST WHERE DIC_VALUE=:p_st'
            INTO l_Result
            USING IN p_At_St;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --   Отримання переліку актів екстренно
    -------------------------------------------------------------------
    PROCEDURE Get_Acts_Urgent (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   Tp.Dic_Name
                       AS At_Tp_Name,
                   s.Dic_Name
                       AS At_Src_Name,
                   Cmes$act_Search.Get_At_St_Name (a.At_St, a.At_Tp)
                       AS At_St_Name,
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --ПІБ, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Назва НСП
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --ПІБ ОСП
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --ПІБ КМ
                   Ikis_Rbm.Tools.Getcupib (a.At_Cu)
                       At_Cu_Pib
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Tp Tp ON a.At_Tp = Tp.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value;
    END;

    -------------------------------------------------------------------
    --   Отримання переліку актів екстренно для НСП #94996
    -------------------------------------------------------------------
    PROCEDURE Get_Acts_Urgent_Pr (p_Cmes_Owner_Id   IN     NUMBER,
                                  p_At_Dt_Start     IN     DATE,
                                  p_At_Dt_Stop      IN     DATE,
                                  p_At_Num          IN     VARCHAR2,
                                  --4) ПІБ відповідальної особи, якою сформовано Договір
                                  p_Creator_Pib     IN     VARCHAR2,
                                  --5) ПІБ отримувача соціальної послуги
                                  p_Receiver_Pib    IN     VARCHAR2,
                                  --6) ПІБ законного представника / уповноваженої особи ОСП
                                  p_Agent_Pib       IN     VARCHAR2,
                                  --8) Наявність документів на підпис
                                  p_At_St           IN     VARCHAR2,
                                  p_Need_Sign       IN     VARCHAR2,
                                  p_Acts               OUT SYS_REFCURSOR)
    IS
    BEGIN
        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT At_Id
              FROM (SELECT a.At_Id,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY a.At_Ap, a.At_Tp
                                   ORDER BY
                                       --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                       CASE
                                           WHEN a.At_St IN ('XR', 'GR')
                                           THEN
                                               2
                                           ELSE
                                               1
                                       END)    AS Rn
                      FROM Act a
                     WHERE     a.At_Rnspm = p_Cmes_Owner_Id
                           AND a.At_Tp IN ('ANPK', 'ANPOE') --зі слів Ж.Хоменко OKS не потрібно виводити в цьому переліку
                           AND a.At_St NOT IN ('GN',
                                               'GD',
                                               'XN',
                                               'XD')
                           AND a.At_St = NVL (p_At_St, a.At_St)
                           AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                           AND NVL (p_At_Dt_Stop, a.At_Dt)
                           AND (   p_At_Num IS NULL
                                OR a.At_Num LIKE p_At_Num || '%')
                           AND EXISTS
                                   (SELECT 1
                                      FROM ap_document_attr apda
                                     WHERE     apda.apda_ap = a.at_ap
                                           AND apda.apda_nda IN
                                                   (1870, 8263, 1947)
                                           AND apda.apda_val_string = 'T')
                           --Наявність документів на підпис
                           AND (   NVL (p_Need_Sign, 'F') = 'F'
                                OR a.At_St IN ('DV', 'XV')
                                OR EXISTS
                                       (SELECT 1
                                          FROM Act Aa
                                         WHERE     Aa.At_Ap = a.At_Ap
                                               AND Aa.At_Rnspm = a.At_Rnspm
                                               AND (   (    Aa.At_Tp = 'NDIS'
                                                        AND Aa.At_St = 'NS')
                                                    OR (    Aa.At_Tp = 'AVOP'
                                                        AND Aa.At_St = 'VK')
                                                    OR (    Aa.At_Tp = 'IP'
                                                        AND Aa.At_St = 'IK')
                                                    OR (    Aa.At_Tp = 'TCTR'
                                                        AND Aa.At_St = 'DS'))))
                           --ПІБ відповідальної особи, якою сформовано
                           AND (   p_Creator_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Ikis_Rbm.v_Cmes_Users u
                                         WHERE     u.Cu_Id = a.At_Cu
                                               AND UPPER (u.Cu_Pib) LIKE
                                                          UPPER (
                                                              p_Creator_Pib)
                                                       || '%'))
                           --ПІБ отримувача соціальної послуги
                           AND (   p_Receiver_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Uss_Person.v_Sc_Info i
                                         WHERE     i.Sco_Id = a.At_Sc
                                               AND UPPER (
                                                          i.Sco_Ln
                                                       || ' '
                                                       || i.Sco_Fn
                                                       || ' '
                                                       || i.Sco_Ln) LIKE
                                                          UPPER (
                                                              p_Receiver_Pib)
                                                       || '%'))
                           --ПІБ законного представника / уповноваженої особи ОСП
                           AND (   p_Agent_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Ap_Person  p
                                               JOIN Uss_Person.v_Sc_Info i
                                                   ON p.App_Sc = i.Sco_Id
                                         WHERE     p.App_Ap = a.At_Ap
                                               AND p.App_Tp IN
                                                       ('OR', 'OP', 'AF')
                                               AND UPPER (
                                                          i.Sco_Ln
                                                       || ' '
                                                       || i.Sco_Fn
                                                       || ' '
                                                       || i.Sco_Ln) LIKE
                                                          UPPER (p_Agent_Pib)
                                                       || '%')))
             WHERE Rn = 1;

        Get_Acts_Urgent (p_Acts);
    END;

    -------------------------------------------------------------------
    --   Отримання переліку актів екстренно для ОСП #94996
    -------------------------------------------------------------------
    PROCEDURE Get_Acts_Urgent_Rc (p_At_Dt_Start    IN     DATE,
                                  p_At_Dt_Stop     IN     DATE,
                                  p_At_Num         IN     VARCHAR2,
                                  --4) ПІБ відповідальної особи, якою сформовано Договір
                                  p_Creator_Pib    IN     VARCHAR2,
                                  --5) ПІБ отримувача соціальної послуги
                                  p_Receiver_Pib   IN     VARCHAR2,
                                  --6) ПІБ законного представника / уповноваженої особи ОСП
                                  p_Agent_Pib      IN     VARCHAR2,
                                  --8) Наявність документів на підпис
                                  p_At_St          IN     VARCHAR2,
                                  p_Need_Sign      IN     VARCHAR2,
                                  p_Acts              OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        DELETE FROM Tmp_Work_Ids;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT At_Id
              FROM (SELECT a.At_Id,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY a.At_Ap, a.At_Tp
                                   ORDER BY
                                       --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                       CASE
                                           WHEN a.At_St IN ('XR', 'GR')
                                           THEN
                                               2
                                           ELSE
                                               1
                                       END)    AS Rn
                      FROM Act a
                     WHERE     (   a.At_Sc = l_Cu_Sc
                                OR EXISTS
                                       (SELECT 1
                                          FROM At_Signers s
                                         WHERE     s.Ati_At = a.At_Id
                                               AND s.History_Status = 'A'
                                               AND s.Ati_Sc = l_Cu_Sc))
                           AND a.At_Tp IN ('ANPK', 'ANPOE') --зі слів Ж.Хоменко OKS не потрібно виводити в цьому переліку
                           AND a.At_St NOT IN ('GN',
                                               'GD',
                                               'XN',
                                               'XD')
                           AND a.At_St = NVL (p_At_St, a.At_St)
                           AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                           AND NVL (p_At_Dt_Stop, a.At_Dt)
                           AND (   p_At_Num IS NULL
                                OR a.At_Num LIKE p_At_Num || '%')
                           AND EXISTS
                                   (SELECT 1
                                      FROM ap_document_attr apda
                                     WHERE     apda.apda_ap = a.at_ap
                                           AND apda.apda_nda = 1870
                                           AND apda.apda_val_string = 'T')
                           --Наявність документів на підпис
                           AND (   NVL (p_Need_Sign, 'F') = 'F'
                                OR a.At_St IN ('DV', 'XV')
                                OR EXISTS
                                       (SELECT 1
                                          FROM Act  Aa
                                               JOIN At_Signers Ss
                                                   ON     Aa.At_Id =
                                                          Ss.Ati_At
                                                      AND Ss.Ati_Sc = l_Cu_Sc
                                                      AND Ss.History_Status =
                                                          'A'
                                         WHERE     Aa.At_Ap = a.At_Ap
                                               AND (   (    Aa.At_Tp = 'AVOP'
                                                        AND Aa.At_St = 'VV')
                                                    OR (    Aa.At_Tp = 'IP'
                                                        AND Aa.At_St = 'IV')
                                                    OR (    Aa.At_Tp = 'TCTR'
                                                        AND Aa.At_St = 'DV'))))
                           --ПІБ відповідальної особи, якою сформовано
                           AND (   p_Creator_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Ikis_Rbm.v_Cmes_Users u
                                         WHERE     u.Cu_Id = a.At_Cu
                                               AND UPPER (u.Cu_Pib) LIKE
                                                          UPPER (
                                                              p_Creator_Pib)
                                                       || '%'))
                           --ПІБ отримувача соціальної послуги
                           AND (   p_Receiver_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Uss_Person.v_Sc_Info i
                                         WHERE     i.Sco_Id = a.At_Sc
                                               AND UPPER (
                                                          i.Sco_Ln
                                                       || ' '
                                                       || i.Sco_Fn
                                                       || ' '
                                                       || i.Sco_Ln) LIKE
                                                          UPPER (
                                                              p_Receiver_Pib)
                                                       || '%'))
                           --ПІБ законного представника / уповноваженої особи ОСП
                           AND (   p_Agent_Pib IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM Ap_Person  p
                                               JOIN Uss_Person.v_Sc_Info i
                                                   ON p.App_Sc = i.Sco_Id
                                         WHERE     p.App_Ap = a.At_Ap
                                               AND p.App_Tp IN
                                                       ('OR', 'OP', 'AF')
                                               AND UPPER (
                                                          i.Sco_Ln
                                                       || ' '
                                                       || i.Sco_Fn
                                                       || ' '
                                                       || i.Sco_Ln) LIKE
                                                          UPPER (p_Agent_Pib)
                                                       || '%')))
             WHERE Rn = 1;

        Get_Acts_Urgent (p_Acts);
    END;
END Cmes$act_Search;
/