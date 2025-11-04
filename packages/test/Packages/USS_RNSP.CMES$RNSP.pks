/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.CMES$RNSP
IS
    -- Author  : SHOSTAK
    -- Created : 06.07.2023 9:13:31 PM
    -- Purpose :

    Pkg   CONSTANT VARCHAR2 (50) := 'CMES$RNSP';

    TYPE r_Tariff_Basis IS RECORD
    (
        Doc_Dh      NUMBER,                      --Ід зрізу документа в архіві
        Doc_Id      NUMBER,                            --Ід документа в архіві
        Doc_Num     VARCHAR2 (100),             --номер розпорядчого документа
        Doc_Name    VARCHAR2 (1000),            --назва розпорядчого документа
        Doc_Dt      TIMESTAMP                    --дата розпорядчого документа
    );

    TYPE r_Rnsp_Tariff IS RECORD
    (
        Rnspt_Id          Rnsp_Tariff.Rnspt_Id%TYPE,
        Rnspt_Nst         Rnsp_Tariff.Rnspt_Nst%TYPE, --Тип послуги(ndi_service_type)
        Rnspt_Start_Dt    TIMESTAMP,                 --Дата початку дії тарифу
        Rnspt_Stop_Dt     TIMESTAMP,              --Дата завершення дії тарифу
        Rnspt_Sum         Rnsp_Tariff.Rnspt_Sum%TYPE,     --Вартість для особи
        Rnspt_Sum_Fm      Rnsp_Tariff.Rnspt_Sum_Fm%TYPE   --Вартість для сім'ї
    );

    /*
    TYPE r_Rnsp_Analytic_View IS RECORD(
      Rnspm_Id             RNSP_MAIN.RNSPM_ID%TYPE,
      Rnsps_id             RNSP_STATE.RNSPS_ID%TYPE,
      Rnsps_Numident       RNSP_STATE.RNSPS_NUMIDENT%TYPE,
      Rnsps_Last_Name      RNSP_STATE.Rnsps_Last_Name%TYPE,
      Rnsps_Ownership      RNSP_STATE.Rnsps_Ownership%TYPE,
      Rnsps_Ownership_Name USS_NDI.V_DDN_RNSP_OWNERSHIP_N.DIC_NAME%TYPE,
      Rnsps_Address_U      VARCHAR2(4000),
      Rnsps_Address_S      VARCHAR2(4000),
      Rnsps_Phone          RNSP_OTHER.Rnspo_Phone%TYPE,
      Rnsps_Email          RNSP_OTHER.Rnspo_Email%TYPE,
      Rnsps_Web            RNSP_OTHER.Rnspo_Web%TYPE,
      Rnsps_Serv_Name      VARCHAR2(4000),
      Rnsps_Serv_Context   VARCHAR2(4000),
      Rnspt_Sum            RNSP_TARIFF.RNSPT_SUM%TYPE,
      Rnspt_Sum_Fm         RNSP_TARIFF.RNSPT_SUM_FM%TYPE,
      Rsnsp_Head_Fio       VARCHAR2(500)
    );  */

    TYPE t_Rnsp_Tariffs IS TABLE OF r_Rnsp_Tariff;

    --TYPE t_Rnsp_Analytic_View IS TABLE OF r_Rnsp_Analytic_View;

    FUNCTION Authenticate (p_Edrpou IN VARCHAR2, p_Rnokpp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Val_Str (p_Ap_Id    IN NUMBER,
                                  p_Nda_Id   IN NUMBER,
                                  p_Ndt_Id   IN NUMBER DEFAULT 700)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Val_Dt (p_Ap_Id    IN NUMBER,
                                 p_Nda_Id   IN NUMBER,
                                 p_Ndt_Id   IN NUMBER DEFAULT 700)
        RETURN DATE;

    FUNCTION Get_Rnd_Attr_Val_Str (p_Rnd_Id      IN NUMBER,
                                   p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_City_Tp (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Journal (p_Pib        IN     VARCHAR2,
                                p_Org_Name   IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR,
                                p_Numident   IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE Get_Rnsp_Services (p_Rnspm_Id   IN     NUMBER,
                                 p_Services      OUT SYS_REFCURSOR);

    PROCEDURE Get_Rnsp_Info (p_Edrpou     IN     VARCHAR2,
                             p_Rnokpp     IN     VARCHAR2,
                             p_Main_Cur      OUT SYS_REFCURSOR,
                             p_Svc_Cur       OUT SYS_REFCURSOR,
                             p_Addr_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Get_Rnsp_Info (p_Rnspm_Id   IN     NUMBER,
                             Rnsp_Info       OUT SYS_REFCURSOR);

    FUNCTION Get_Addr_Text (p_Rnspa_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Card (p_Rnspm_Id     IN     NUMBER,
                             Rnsp_Info         OUT SYS_REFCURSOR,
                             Addr_Reg          OUT SYS_REFCURSOR,
                             Addr_Service      OUT SYS_REFCURSOR);

    PROCEDURE Get_Tariffs (p_Rnspm_Id   IN     NUMBER,
                           p_Start_Dt   IN     DATE,
                           p_Stop_Dt    IN     DATE,
                           p_Nst_Id     IN     NUMBER,
                           p_Services      OUT SYS_REFCURSOR,
                           p_Tariffs       OUT SYS_REFCURSOR);

    PROCEDURE Save_Tariffs (p_Rnspm_Id       IN NUMBER,
                            p_Tarriffs       IN CLOB,
                            p_Tariff_Basis   IN CLOB);

    -- лог по картці РНСП
    PROCEDURE Get_Rnsp_Log (p_Rnspm_Id          IN     NUMBER,
                            p_Ap_Log_Cursor        OUT SYS_REFCURSOR,
                            p_Rnsp_Log_Cursor      OUT SYS_REFCURSOR);

    -- лог по картці РНСП (уніфікований як лог по зверненню і акту)
    PROCEDURE Get_Rnsp_Log (p_Rnspm_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Cm_List (p_Cmes_Owner_Id   IN     NUMBER,
                           p_Pib             IN     VARCHAR2,
                           p_Numident        IN     VARCHAR2,
                           p_Show_Locked     IN     VARCHAR2 DEFAULT 'F',
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Rec_Cm_List (p_Rnspm_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);


    FUNCTION Get_Rnsp_Head_Fio (p_Rnspm_id IN uss_rnsp.v_rnsp.RNSPM_ID%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Providers_List (
        p_Res          OUT SYS_REFCURSOR,
        p_Koat_L1   IN     NUMBER DEFAULT NULL,
        p_Koat_L2   IN     NUMBER DEFAULT NULL,
        p_Koat_L3   IN     NUMBER DEFAULT NULL,
        p_Koat_L4   IN     NUMBER DEFAULT NULL,
        p_Koat_L5   IN     NUMBER DEFAULT NULL);
END Cmes$rnsp;
/


GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO II01RC_USS_RNSP_PORTAL
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO II01RC_USS_RNSP_WEB
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO IKIS_RBM
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO OKOMISAROV
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO SHOST
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO USS_ESR
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO USS_PERSON
/

GRANT EXECUTE ON USS_RNSP.CMES$RNSP TO USS_RPT
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.CMES$RNSP
IS
    FUNCTION Is_Ipn (p_Rnokpp IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN REGEXP_LIKE (p_Rnokpp, '^[0-9]{10}$');
    END;

    FUNCTION Is_Pasp (p_Rnokpp IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN REGEXP_LIKE (p_Rnokpp, '^[А-ЯҐІЇЄ]{2}[0-9]{6}$');
    END;

    FUNCTION Is_Id_Card (p_Rnokpp IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN REGEXP_LIKE (p_Rnokpp, '^[0-9]{9}$');
    END;

    -------------------------------------------------------------------
    -- Отримання ідентифікатору картки надавача по ЄДРПОУ або РНОКПП
    -------------------------------------------------------------------
    PROCEDURE Get_Rnsp_Id (p_Edrpou     IN     VARCHAR2,
                           p_Rnokpp     IN     VARCHAR2,
                           p_Rnspm_Id      OUT NUMBER,
                           p_Rnsps_Id      OUT NUMBER)
    IS
        l_Numident   VARCHAR2 (10);
        l_Pass_Num   VARCHAR2 (20);
    BEGIN
        IF Is_Ipn (p_Rnokpp)
        THEN
            l_Numident := p_Rnokpp;
        ELSIF Is_Pasp (p_Rnokpp) OR Is_Id_Card (p_Rnokpp)
        THEN
            l_Pass_Num := p_Rnokpp;
        END IF;

        SELECT MAX (s.Rnsps_Id), MAX (s.Rnsps_Rnspm)
          INTO p_Rnsps_Id, p_Rnspm_Id
          FROM Rnsp_State s JOIN Rnsp_Main m ON s.Rnsps_Rnspm = m.Rnspm_Id
         WHERE     (   s.Rnsps_Numident IN (l_Numident, p_Edrpou)
                    OR s.Rnsps_Pass_Seria || s.Rnsps_Pass_Num = l_Pass_Num)
               AND s.History_Status = 'A'
               AND m.Rnspm_St IN ('A', 'D')
               AND m.Rnspm_Org_Tp = 'PR';
    END;

    -------------------------------------------------------------------
    --          Автентифікація надавача соцпослуг
    -------------------------------------------------------------------
    FUNCTION Authenticate (p_Edrpou IN VARCHAR2, p_Rnokpp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Rnspm_Id   NUMBER;
        l_Rnsps_Id   NUMBER;
    BEGIN
        Get_Rnsp_Id (p_Edrpou     => p_Edrpou,
                     p_Rnokpp     => p_Rnokpp,
                     p_Rnspm_Id   => l_Rnspm_Id,
                     p_Rnsps_Id   => l_Rnsps_Id);
        RETURN CASE WHEN l_Rnsps_Id IS NOT NULL THEN 'T' ELSE 'F' END;
    END;

    -------------------------------------------------------------------
    --       Отримання значення атрибута з заяви з типом "Рядок"
    -------------------------------------------------------------------
    FUNCTION Get_Ap_Attr_Val_Str (p_Ap_Id    IN NUMBER,
                                  p_Nda_Id   IN NUMBER,
                                  p_Ndt_Id   IN NUMBER DEFAULT 700)
        RETURN VARCHAR2
    IS
        l_Result   Rn_Document_Attr.Rnda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Rnda_Val_String)
          INTO l_Result
          FROM Rn_Document  d
               JOIN Rn_Document_Attr a
                   ON     d.Rnd_Id = a.Rnda_Rnd
                      AND a.Rnda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE     d.Rnd_Ap = p_Ap_Id
               AND d.Rnd_Ndt = p_ndt_id
               AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Attr_Val_Dt (p_Ap_Id    IN NUMBER,
                                 p_Nda_Id   IN NUMBER,
                                 p_Ndt_Id   IN NUMBER DEFAULT 700)
        RETURN DATE
    IS
        l_Result   Rn_Document_Attr.Rnda_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (a.Rnda_Val_Dt)
          INTO l_Result
          FROM Rn_Document  d
               JOIN Rn_Document_Attr a
                   ON     d.Rnd_Id = a.Rnda_Rnd
                      AND a.Rnda_Nda = p_Nda_Id
                      AND a.History_Status = 'A'
         WHERE     d.Rnd_Ap = p_Ap_Id
               AND d.Rnd_Ndt = p_ndt_id
               AND d.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Rnd_Attr_Val_Str (p_Rnd_Id      IN NUMBER,
                                   p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Rn_Document_Attr.Rnda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Rnda_Val_String)
          INTO l_Result
          FROM Rn_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Rnda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Rnda_Rnd = p_Rnd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви області по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L1 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви району по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L2 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви населеного пункта по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L4 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання типу населеного пункта по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_City_Tp (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.Dic_Sname)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L4 = Kk.Kaot_Id
               JOIN Uss_Ndi.v_Ddn_Kaot_Tp t ON Kk.Kaot_Tp = t.Dic_Value
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;


    PROCEDURE Get_Rnsp_Journal (p_Pib        IN     VARCHAR2,
                                p_Org_Name   IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR,
                                p_Numident   IN     VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        OPEN Res_Cur FOR
            SELECT s.Rnsps_Rnspm
                       AS Rnsp_Id,
                   t.Dic_Name
                       AS Rnsp_Tp,
                   CASE
                       WHEN m.Rnspm_Tp = 'F'
                       THEN
                              s.Rnsps_Last_Name
                           || ' '
                           || s.Rnsps_First_Name
                           || ' '
                           || s.Rnsps_Middle_Name
                   END
                       AS Pib,
                   CASE WHEN m.Rnspm_Tp = 'O' THEN s.Rnsps_Last_Name END
                       AS Org_Name,
                   CASE WHEN m.Rnspm_Tp = 'O' THEN s.Rnsps_First_Name END
                       AS Org_Name_Short,
                   s.Rnsps_Numident
                       AS Numident,
                   s.Rnsps_Pass_Seria || s.Rnsps_Pass_Num
                       AS Passport
              FROM Rnsp_State  s
                   JOIN Rnsp_Main m ON s.Rnsps_Rnspm = m.Rnspm_Id
                   JOIN Uss_Ndi.v_Ddn_Rnsp_Tp t ON m.Rnspm_Tp = t.Dic_Value
             WHERE     (   (p_Pib IS NULL AND p_Org_Name IS NULL)
                        OR --Юр. особи
                           (    p_Org_Name IS NOT NULL
                            AND UPPER (s.Rnsps_Last_Name) LIKE
                                    '%' || UPPER (p_Org_Name) || '%'
                            AND m.Rnspm_Tp = 'O')
                        --ФОП
                        OR (    p_Pib IS NOT NULL
                            AND UPPER (
                                       s.Rnsps_Last_Name
                                    || ' '
                                    || s.Rnsps_First_Name
                                    || ' '
                                    || s.Rnsps_Middle_Name) LIKE
                                    '%' || UPPER (p_Pib) || '%'
                            AND m.Rnspm_Tp = 'F'))
                   AND s.Rnsps_Numident = NVL (p_Numident, s.Rnsps_Numident)
                   AND s.History_Status = 'A';
    END;

    -------------------------------------------------------------------
    --          Отримання переліку послуг надавача
    -------------------------------------------------------------------
    PROCEDURE Get_Rnsp_Services (p_Rnspm_Id   IN     NUMBER,
                                 p_Rnsps_Id   IN     NUMBER,
                                 p_Services      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Services FOR
            SELECT Ds.Rnspds_Nst               AS Nst_Id,
                   --Назва соціальної послуги
                   St.Nst_Name,
                   --Короткий зміст та обсяг соціальної послуги
                   Ds.Rnspds_Content,
                   --Умови і порядок отримання соціальної послуги
                   Ds.Rnspds_Condition,
                   --Надається екстренно (кризово)
                   Ds.Rnspds_Can_Urgant,
                   --Надається в приміщенні надавача
                   Ds.Rnspds_Is_Inroom,
                   --Наявна кількість
                   Ds.Rnspds_Cnt,
                   --Відповідає державним стандартам
                   Ds.Rnspds_Is_Standards,
                   --Діючий тариф для особи
                    (SELECT t.Rnspt_Sum
                       FROM Rnsp_Tariff t
                      WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                            AND t.History_Status = 'A'
                            AND t.Rnspt_Nst = Ds.Rnspds_Nst
                            AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                            AND NVL (
                                                    t.Rnspt_Stop_Dt,
                                                    SYSDATE)
                            --Рябченко. Костыль  -надо разбитраться, почему дубли
                            AND ROWNUM = 1)    AS Rnspds_Sum,
                   --Діючий тариф для сім'ї
                    (SELECT t.Rnspt_Sum_Fm
                       FROM Rnsp_Tariff t
                      WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                            AND t.History_Status = 'A'
                            AND t.Rnspt_Nst = Ds.Rnspds_Nst
                            AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                            AND NVL (
                                                    t.Rnspt_Stop_Dt,
                                                    SYSDATE)
                            AND ROWNUM = 1)    AS Rnspds_Sum_Fm
              FROM Rnsp2service  Ns
                   JOIN Rnsp_Dict_Service Ds
                       ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                   JOIN Uss_Ndi.v_Ndi_Service_Type St
                       ON Ds.Rnspds_Nst = St.Nst_Id
             WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id;
    END;

    -------------------------------------------------------------------
    --          Отримання переліку послуг надавача
    -------------------------------------------------------------------
    PROCEDURE Get_Rnsp_Services (p_Rnspm_Id   IN     NUMBER,
                                 p_Services      OUT SYS_REFCURSOR)
    IS
        l_Rnsps_Id   NUMBER;
    BEGIN
        SELECT MAX (s.Rnsps_Id)
          INTO l_Rnsps_Id
          FROM Rnsp_State s
         WHERE s.Rnsps_Rnspm = l_Rnsps_Id AND s.History_Status = 'A';

        Get_Rnsp_Services (p_Rnspm_Id   => p_Rnspm_Id,
                           p_Rnsps_Id   => l_Rnsps_Id,
                           p_Services   => p_Services);
    END;

    PROCEDURE Get_Rnsp_Address (p_Rnspm_Id   IN     NUMBER,
                                p_Addr_Tp    IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
            SELECT a.rnspa_id,
                   a.Rnspa_Kaot                         AS Kaot,
                   a.Rnspa_Index                        AS "Index",
                   Get_Kaot_Region (a.Rnspa_Kaot)       AS Region,
                   Get_Kaot_District (a.Rnspa_Kaot)     AS District,
                   Get_Kaot_City (a.Rnspa_Kaot)         AS City,
                   a.Rnspa_Street                       AS Street,
                   a.Rnspa_Building                     AS Building,
                   a.Rnspa_Korp                         AS Korp,
                   a.Rnspa_Appartement                  AS Appartement
              FROM Rnsp_State  s
                   JOIN Rnsp2address t ON s.Rnsps_Id = t.Rnsp2a_Rnsps
                   JOIN Rnsp_Address a
                       ON     t.Rnsp2a_Rnspa = a.Rnspa_Id
                          AND a.Rnspa_Tp = p_Addr_Tp
             WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';
    END;

    -------------------------------------------------------------------
    --          Отримання інформації про надавача соц. послуг
    -------------------------------------------------------------------
    PROCEDURE Get_Rnsp_Info (p_Edrpou     IN     VARCHAR2,
                             p_Rnokpp     IN     VARCHAR2,
                             p_Main_Cur      OUT SYS_REFCURSOR,
                             p_Svc_Cur       OUT SYS_REFCURSOR,
                             p_Addr_Cur      OUT SYS_REFCURSOR)
    IS
        l_Rnsps_Id      NUMBER;
        l_Rnspm_Id      NUMBER;
        l_Last_Ap       NUMBER;
        l_Last_App      NUMBER;
        l_Last_App_Sc   NUMBER;
        l_Last_Rnd      NUMBER;
    BEGIN
        --Отримуємо ІД поточного зрізу картки надавача
        Get_Rnsp_Id (p_Edrpou     => p_Edrpou,
                     p_Rnokpp     => p_Rnokpp,
                     p_Rnspm_Id   => l_Rnspm_Id,
                     p_Rnsps_Id   => l_Rnsps_Id);

        --Отримуємо ІД останнього звернення надавача в статусі "Виконано"
        --та посилання на соцкартку заявника в цьому звернені
        SELECT MAX (Ap_Id), MAX (App_Id), MAX (App_Sc)
          INTO l_Last_Ap, l_Last_App, l_Last_App_Sc
          FROM (  SELECT a.Ap_Id, p.App_Id, p.App_Sc
                    FROM Rnsp_State s
                         JOIN Appeal a
                             ON     s.Rnsps_Rnspm = a.Ap_Ext_Ident
                                AND a.Ap_St = 'V'
                         JOIN Ap_Person p
                             ON     a.Ap_Id = p.App_Ap
                                AND p.History_Status = 'A'
                                AND p.App_Tp = 'Z'
                   WHERE s.Rnsps_Id = l_Rnsps_Id
                ORDER BY a.Ap_Reg_Dt DESC
                   FETCH FIRST ROW ONLY);

        --Отримуємо ІД документа що посвідчує особу з останього звернення
        SELECT MAX (d.Rnd_Id)
          INTO l_Last_Rnd
          FROM Rn_Document d
         WHERE     d.Rnd_App = l_Last_App
               AND d.Rnd_Ndt IN (6, 7)
               AND d.History_Status = 'A';

        OPEN p_Main_Cur FOR
            SELECT ------------------------------
                   --Загальні дані
                   ------------------------------
                   --Ідентифікатор НСП
                   m.Rnspm_Id,
                   --Тип НСП
                   m.Rnspm_Tp,
                   t.Dic_Name
                       AS Rnspm_Tp_Name,
                   --Організаційно-правова форма
                   o.Rnspo_Prop_Form,
                   f.Dic_Name
                       AS Rnspo_Prop_Form_Name,
                   --Вид громадського об’єднання, благодійної чи релігійної організації
                   o.Rnspo_Union_Tp,
                   --Заходи з інформування населення
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1132)
                       AS People_Inform,
                   --Форма власності
                   s.Rnsps_Ownership,
                   Os.Dic_Name
                       AS Rnsps_Ownership_Name,
                   ------------------------------
                   --Юридична особа/ФОП
                   ------------------------------
                   s.Rnsps_Numident,
                   --Код ЄДРПОУ/РНОКПП
                   s.Rnsps_Is_Numident_Missing,
                   --Ознака відмови особи від РНОКПП
                   s.Rnsps_Pass_Seria || s.Rnsps_Pass_Num
                       AS Rnsps_Pass_Num,
                   --Серія та номер паспорта  / номер ID картки
                   s.Rnsps_Last_Name,
                   --Повне найменування юридичної особи (згідно ЄДР)/Прізвище ФОПа
                   s.Rnsps_First_Name,
                   --Скорочене найменування юридичної особи (згідно ЄДР)/Ім’я ФОПа
                   s.Rnsps_Middle_Name,
                   --По батькові ФОПа

                   --Атрибути документа ФОПа
                   Get_Rnd_Attr_Val_Str (l_Last_Rnd, 'DORG')
                       AS Doc_Org,
                   --Орган, що видав
                   Get_Rnd_Attr_Val_Str (l_Last_Rnd, 'DGVDT')
                       AS Doc_Dt,
                   --Дата видачі
                   Get_Rnd_Attr_Val_Str (l_Last_Rnd, 'DSPDT')
                       AS Doc_Stop_Dt,
                   --Дійсний до

                   ------------------------------
                   --Керівник юридичної особи
                   ------------------------------
                   --Посада керівника юридичної особи
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1094)
                       AS Boss_Position,
                   --Прізвище керівника юридичної особи
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1095)
                       AS Boss_Last_Name,
                   --Ім’я керівника юридичної особи
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1096)
                       AS Boss_First_Name,
                   --По- батькові  керівника юридичної особи
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1097)
                       AS Boss_Middle_Name,
                   ------------------------------
                   --Уповноважена особа НСП 
                   ------------------------------
                   --РНОКПП уповноваженої особи
                   Sco.Sco_Numident
                       AS Auth_Person_Numident,
                   -- прізвище уповноваженої особи
                   Sco.Sco_Ln
                       AS Auth_Person_Ln,
                   --ім’я уповноваженої особи
                   Sco.Sco_Fn
                       AS Auth_Person_Fn,
                   --по батькові уповноваженої особи
                   Sco.Sco_Mn
                       AS Auth_Person_Mn,
                   ------------------------------
                   --Адреса реєстрації (Місце знаходження надавача)
                   ------------------------------
                   Au.Rnspa_Kaot
                       AS Addr_Fact_Kaot,
                   Au.Rnspa_Index
                       AS Addr_Fact_Index,
                   Get_Kaot_Region (Au.Rnspa_Kaot)
                       AS Addr_Fact_Region,
                   Get_Kaot_District (Au.Rnspa_Kaot)
                       AS Addr_Fact_District,
                   Get_Kaot_City (Au.Rnspa_Kaot)
                       AS Addr_Fact_City,
                   Au.Rnspa_Street
                       AS Addr_Fact_Street,
                   Au.Rnspa_Building
                       AS Addr_Fact_Building,
                   Au.Rnspa_Korp
                       AS Addr_Fact_Korp,
                   Au.Rnspa_Appartement
                       AS Addr_Fact_Appartement,
                   --Ознака свівпадіння адреси надання соціальних послуг з адресою реєстрації юридичної особи
                   Get_Ap_Attr_Val_Str (l_Last_Ap, 1093)
                       AS Same_Addr,
                   /*------------------------------
                   --Адреса надання соціальних послуг  (Місце надання соціальних послуг)
                   ------------------------------
                   a.Rnspa_Kaot AS Addr_Svc_Kaot, a.Rnspa_Index AS Addr_Svc_Index, Get_Kaot_Region(a.Rnspa_Kaot) AS Addr_Svc_Region,
                   Get_Kaot_District(a.Rnspa_Kaot) AS Addr_Svc_District, Get_Kaot_City(a.Rnspa_Kaot) AS Addr_Svc_City,
                   a.Rnspa_Street AS Addr_Svc_Street, a.Rnspa_Building AS Addr_Svc_Building, a.Rnspa_Korp AS Addr_Svc_Korp,
                   a.Rnspa_Appartement AS Addr_Svc_Appartement,

                   ------------------------------
                   --Адреса надання соціальних послуг (друга)  (Місце надання соціальних послуг)
                   ------------------------------
                   A2.Rnspa_Kaot AS Addr_Svc2_Kaot, A2.Rnspa_Index AS Addr_Svc2_Index, Get_Kaot_Region(A2.Rnspa_Kaot) AS Addr_Svc2_Region,
                   Get_Kaot_District(A2.Rnspa_Kaot) AS Addr_Svc2_District, Get_Kaot_City(A2.Rnspa_Kaot) AS Addr_Svc2_City,
                   A2.Rnspa_Street AS Addr_Svc2_Street, A2.Rnspa_Building AS Addr_Svc2_Building, A2.Rnspa_Korp AS Addr_Svc2_Korp,
                   A2.Rnspa_Appartement AS Addr_Svc2_Appartement,

                   ------------------------------
                   --Адреса надання соціальних послуг (третя)  (Місце надання соціальних послуг)
                   ------------------------------
                   A3.Rnspa_Kaot AS Addr_Svc3_Kaot, A3.Rnspa_Index AS Addr_Svc3_Index, Get_Kaot_Region(A3.Rnspa_Kaot) AS Addr_Svc3_Region,
                   Get_Kaot_District(A3.Rnspa_Kaot) AS Addr_Svc3_District, Get_Kaot_City(A3.Rnspa_Kaot) AS Addr_Svc3_City,
                   A3.Rnspa_Street AS Addr_Svc3_Street, A3.Rnspa_Building AS Addr_Svc3_Building, A3.Rnspa_Korp AS Addr_Svc3_Korp,
                   A3.Rnspa_Appartement AS Addr_Svc3_Appartement,

                   ------------------------------
                   --Адреса надання соціальних послуг (четверта)  (Місце надання соціальних послуг)
                   ------------------------------
                   A4.Rnspa_Kaot AS Addr_Svc4_Kaot, A4.Rnspa_Index AS Addr_Svc4_Index, Get_Kaot_Region(A4.Rnspa_Kaot) AS Addr_Svc4_Region,
                   Get_Kaot_District(A4.Rnspa_Kaot) AS Addr_Svc4_District, Get_Kaot_City(A4.Rnspa_Kaot) AS Addr_Svc4_City,
                   A4.Rnspa_Street AS Addr_Svc4_Street, A4.Rnspa_Building AS Addr_Svc4_Building, A4.Rnspa_Korp AS Addr_Svc4_Korp,
                   A4.Rnspa_Appartement AS Addr_Svc4_Appartement,
                   */
                   ------------------------------
                   --Контактні дані
                   ------------------------------
                   o.Rnspo_Phone,
                   o.Rnspo_Email,
                   o.Rnspo_Web,
                   s.rnsps_is_stuff_publish,
                   bl.DIC_NAME
                       rnsps_is_staff_publish_name
              FROM Rnsp_State  s
                   JOIN Rnsp_Main m ON s.Rnsps_Rnspm = m.Rnspm_Id
                   JOIN Uss_Ndi.v_Ddn_Rnsp_Tp t ON m.Rnspm_Tp = t.Dic_Value
                   JOIN Rnsp_Other o ON s.Rnsps_Rnspo = o.Rnspo_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Rnsp_Ownership_n Os
                       ON s.Rnsps_Ownership = Os.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Forms_Mngm f
                       ON o.Rnspo_Prop_Form = f.Dic_Value
                   LEFT JOIN Rnsp_Address Au
                   JOIN rnsp2address a
                       ON (a.rnsp2a_rnspa = au.rnspa_id)
                       ON     (    au.rnspa_tp = 'U'
                               AND a.rnsp2a_rnsps = s.rnsps_id)
                          --ON Coalesce(s.Rnsps_Rnspa, s.Rnsps_Rnspa2_Old, s.Rnsps_Rnspa3_Old, s.Rnsps_Rnspa4_Old) = Au.Rnspa_Id
                          AND Au.Rnspa_Tp = 'U'
                   /*LEFT JOIN Uss_Ndi.v_Ndi_Katottg Ku
                     ON Au.Rnspa_Kaot = Ku.Kaot_Id
                   LEFT JOIN Rnsp_Address a
                     ON s.Rnsps_Rnspa1_Old = a.Rnspa_Id
                    AND a.Rnspa_Tp = 'S'
                   LEFT JOIN Rnsp_Address A2
                     ON s.Rnsps_Rnspa2_Old = A2.Rnspa_Id
                    AND A2.Rnspa_Tp IN ('S', 'S2')
                   LEFT JOIN Rnsp_Address A3
                     ON s.Rnsps_Rnspa3_Old = A3.Rnspa_Id
                    AND A3.Rnspa_Tp IN ('S', 'S3')
                   LEFT JOIN Rnsp_Address A4
                     ON s.Rnsps_Rnspa4_Old = A4.Rnspa_Id
                    AND A4.Rnspa_Tp IN ('S', 'S4')
                   LEFT JOIN Uss_Ndi.v_Ndi_Katottg Ka
                     ON a.Rnspa_Kaot = Ka.Kaot_Id*/
                   LEFT JOIN Uss_Person.v_Sc_Info Sco
                       ON l_Last_App_Sc = Sco_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Boolean bl
                       ON s.rnsps_is_stuff_publish = bl.DIC_VALUE
             WHERE s.Rnsps_Id = l_Rnsps_Id;


        --Перелік соціальних послуг, які має право надавати надавач соціальних послуг
        Get_Rnsp_Services (p_Rnspm_Id   => l_Rnspm_Id,
                           p_Rnsps_Id   => l_Rnsps_Id,
                           p_Services   => p_Svc_Cur);
        --Перелік адрес надання послуг
        Get_Rnsp_Address (p_Rnspm_Id   => l_Rnspm_Id,
                          p_Addr_Tp    => 'S',
                          Res_Cur      => p_Addr_Cur);
    END;

    PROCEDURE Get_Rnsp_Info (p_Rnspm_Id   IN     NUMBER,
                             Rnsp_Info       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Rnsp_Info FOR
            SELECT s.Rnsps_Rnspm
                       AS Rnsp_Id,
                   t.Dic_Name
                       AS Rnsp_Tp,
                   CASE
                       WHEN m.Rnspm_Tp = 'F'
                       THEN
                              s.Rnsps_Last_Name
                           || ' '
                           || s.Rnsps_First_Name
                           || ' '
                           || s.Rnsps_Middle_Name
                   END
                       AS Pib,
                   CASE WHEN m.Rnspm_Tp = 'O' THEN s.Rnsps_Last_Name END
                       AS Org_Name,
                   CASE WHEN m.Rnspm_Tp = 'O' THEN s.Rnsps_First_Name END
                       AS Org_Name_Short,
                   s.Rnsps_Numident
                       AS Numident,
                   s.Rnsps_Pass_Seria || s.Rnsps_Pass_Num
                       AS Passport,
                   o.Rnspo_Phone
                       AS Phone,
                   o.Rnspo_Email
                       AS Email,
                   o.Rnspo_Web
                       AS Web_Site,
                   o.Rnspo_Union_Tp
                       AS Union_Tp,
                   o.Rnspo_Prop_Form
                       AS Prop_Form,
                   /*,
                   --Не використовується
                   Get_Addr_Text(s.Rnsps_Rnspa) AS Addr_Fact,
                   Get_Addr_Text(s.Rnsps_Rnspa1_Old) AS Addr_Svc1,
                   Get_Addr_Text(s.Rnsps_Rnspa2_Old) AS Addr_Svc2,
                   Get_Addr_Text(s.Rnsps_Rnspa3_Old) AS Addr_Svc3,
                   Get_Addr_Text(s.Rnsps_Rnspa4_Old) AS Addr_Svc4*/

                   ------------------------------
                   --Керівник юридичної особи
                   ------------------------------
                   --Посада керівника юридичної особи
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 1094)
                       AS Boss_Position,
                   --Прізвище керівника юридичної особи
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 1095)
                       AS Boss_Last_Name,
                   --Ім’я керівника юридичної особи
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 1096)
                       AS Boss_First_Name,
                   --По- батькові  керівника юридичної особи
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 1097)
                       AS Boss_Middle_Name,
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 4228, 711)
                       AS Doc_Name,
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 4229, 711)
                       AS Doc_Num,
                   Get_Ap_Attr_Val_Str (m.rnspm_ap_edit, 4230, 711)
                       AS Doc_Dt,
                   s.rnsps_is_stuff_publish,
                   bl.DIC_NAME
                       rnsps_is_staff_publish_name
              FROM Rnsp_State  s
                   JOIN Rnsp_Main m ON s.Rnsps_Rnspm = m.Rnspm_Id
                   JOIN Uss_Ndi.v_Ddn_Rnsp_Tp t ON m.Rnspm_Tp = t.Dic_Value
                   JOIN Rnsp_Other o ON s.Rnsps_Rnspo = o.Rnspo_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Boolean bl
                       ON s.rnsps_is_stuff_publish = bl.DIC_VALUE
             WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';
    END;

    FUNCTION Get_Addr_Text (p_Rnspa_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        IF p_Rnspa_Id IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT    Get_Kaot_Region (a.Rnspa_Kaot)
               || ' обл., '
               || CASE
                      WHEN Get_Kaot_District (a.Rnspa_Kaot) IS NOT NULL
                      THEN
                          Get_Kaot_District (a.Rnspa_Kaot) || ' район, '
                  END
               || CASE
                      WHEN Get_Kaot_City (a.Rnspa_Kaot) IS NOT NULL
                      THEN
                             Get_Kaot_City_Tp (a.Rnspa_Kaot)
                          || ' '
                          || Get_Kaot_City (a.Rnspa_Kaot)
                          || ','
                  END
               || a.Rnspa_Street
               || ' '
               || a.Rnspa_Building
               || CASE
                      WHEN a.Rnspa_Korp IS NOT NULL
                      THEN
                          ', корп. ' || a.Rnspa_Korp
                  END
               || CASE
                      WHEN a.Rnspa_Appartement IS NOT NULL
                      THEN
                          ', кв. ' || a.Rnspa_Appartement
                  END
          INTO l_Result
          FROM Rnsp_Address a
         WHERE a.Rnspa_Id = p_Rnspa_Id;

        RETURN l_Result;
    END;


    PROCEDURE Get_Rnsp_Card (p_Rnspm_Id     IN     NUMBER,
                             Rnsp_Info         OUT SYS_REFCURSOR,
                             Addr_Reg          OUT SYS_REFCURSOR,
                             Addr_Service      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Get_Rnsp_Info (p_Rnspm_Id, Rnsp_Info);
        Get_Rnsp_Address (p_Rnspm_Id, 'U', Addr_Reg);
        Get_Rnsp_Address (p_Rnspm_Id, 'S', Addr_Service);
    END;

    -------------------------------------------------------------------
    --         Отримання тарифів надавача
    -------------------------------------------------------------------
    PROCEDURE Get_Tariffs (p_Rnspm_Id   IN     NUMBER,               --Надавач
                           p_Start_Dt   IN     DATE,            --Дія тарифу з
                           p_Stop_Dt    IN     DATE,           --Дія тарифу по
                           p_Nst_Id     IN     NUMBER,           --Тип послуги
                           p_Services      OUT SYS_REFCURSOR,
                           p_Tariffs       OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Перелік послук по яким надаються тарифи
        OPEN p_Services FOR
            SELECT Rnspds_Nst,
                   Nt.Nst_Name     AS Rnspds_Nst_Name,
                   Rnspds_Content,
                   Rnspds_Condition,
                   Rnspds_Cnt,
                   Rnspds_Can_Urgant,
                   Rnspds_Is_Inroom,
                   Rnspds_Is_Innursing,
                   Rnspds_Is_Standards
              FROM (SELECT Ds.Rnspds_Nst,
                           Ds.Rnspds_Content,
                           Ds.Rnspds_Condition,
                           Ds.Rnspds_Cnt,
                           Ds.Rnspds_Can_Urgant,
                           Ds.Rnspds_Is_Inroom,
                           Ds.Rnspds_Is_Innursing,
                           Ds.Rnspds_Is_Standards,
                           ROW_NUMBER ()
                               OVER (PARTITION BY Ds.Rnspds_Nst
                                     ORDER BY s.Rnsps_Id DESC)    AS Rn
                      FROM Rnsp_Tariff  t
                           JOIN Rnsp_State s ON t.Rnspt_Rnspm = s.Rnsps_Rnspm
                           JOIN Rnsp2service Sv
                               ON s.Rnsps_Id = Sv.Rnsp2s_Rnsps
                           JOIN Rnsp_Dict_Service Ds
                               ON Sv.Rnsp2s_Rnspds = Ds.Rnspds_Id
                     WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                           AND t.History_Status = 'A'
                           AND t.Rnspt_Nst = NVL (p_Nst_Id, t.Rnspt_Nst)
                           AND t.Rnspt_Start_Dt >=
                               NVL (p_Start_Dt, t.Rnspt_Start_Dt)
                           AND t.Rnspt_Stop_Dt <=
                               NVL (p_Stop_Dt, t.Rnspt_Stop_Dt))
                   JOIN Uss_Ndi.v_Ndi_Service_Type Nt
                       ON Rnspds_Nst = Nt.Nst_Id
             WHERE Rn = 1;

        --Перелік тарифів
        OPEN p_Tariffs FOR
              SELECT t.Rnspt_Id,
                     t.Rnspt_Nst,
                     t.Rnspt_Start_Dt,
                     t.Rnspt_Stop_Dt,
                     t.Rnspt_Sum,
                     t.Rnspt_Sum_Fm,
                     Ikis_Rbm.Tools.Getcupib (s.Hs_Cu)
                         AS Cu_Pib,
                     s.Hs_Dt
                         AS Save_Dt,
                        --Підстава на внесення тарифів
                        Api$document.Get_Rnda_Str (t.Rnspt_Rnd, 3536)
                     || ': '
                     || Api$document.Get_Rnda_Str (t.Rnspt_Rnd, 3537)
                         AS Rnspt_Basis,
                     d.Rnd_Doc,
                     d.Rnd_Dh,
                     (  SELECT f.File_Code
                          FROM Uss_Doc.v_Doc_Attachments a
                               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                         WHERE a.Dat_Dh = d.Rnd_Dh
                      ORDER BY f.File_Id DESC
                         FETCH FIRST ROW ONLY)
                         AS File_Code
                FROM Rnsp_Tariff t
                     JOIN Histsession s ON t.Rnspt_Hs = s.Hs_Id
                     JOIN Rn_Document d ON t.Rnspt_Rnd = d.Rnd_Id
               WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                     AND t.History_Status = 'A'
                     AND t.Rnspt_Nst = NVL (p_Nst_Id, t.Rnspt_Nst)
                     AND t.Rnspt_Start_Dt >= NVL (p_Start_Dt, t.Rnspt_Start_Dt)
                     AND t.Rnspt_Stop_Dt <= NVL (p_Stop_Dt, t.Rnspt_Stop_Dt)
            ORDER BY t.Rnspt_Start_Dt;
    END;

    /*FUNCTION To_Money(p_Str VARCHAR2) RETURN NUMBER IS
    BEGIN
      RETURN To_Number(REPLACE(p_Str, ',', '.'), '9999999999D99999', 'NLS_NUMERIC_CHARACTERS=''.,''');
    END;*/

    -------------------------------------------------------------------
    --         Збереження тарифів надавача
    -------------------------------------------------------------------
    PROCEDURE Save_Tariffs (p_Rnspm_Id       IN NUMBER,
                            p_Tarriffs       IN CLOB,
                            p_Tariff_Basis   IN CLOB)
    IS
        l_Tariffs         t_Rnsp_Tariffs;
        l_Basis           r_Tariff_Basis;
        l_Hs              NUMBER;
        l_Rnd             NUMBER;
        l_Cross_Periods   VARCHAR2 (4000);
        l_Nst_Name        VARCHAR2 (4000);
        l_Lock            Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_Svc_Exists      NUMBER;
        l_Rnspt_id        NUMBER;

        PROCEDURE Save_Attr (p_Nda_Id    NUMBER,
                             p_Val_Str   VARCHAR2 DEFAULT NULL,
                             p_Val_Dt    DATE DEFAULT NULL)
        IS
        BEGIN
            INSERT INTO Rn_Document_Attr (Rnda_Id,
                                          Rnda_Rnd,
                                          Rnda_Nda,
                                          Rnda_Val_String,
                                          Rnda_Val_Dt,
                                          History_Status)
                 VALUES (0,
                         l_Rnd,
                         p_Nda_Id,
                         p_Val_Str,
                         p_Val_Dt,
                         'A');
        END;
    BEGIN
        IF p_Rnspm_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано надавача СП');
        END IF;

        --Перевірка наявності ролі надавача
        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Rnspm_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Raise_Application_Error (
                -20000,
                'Недостатньо прав на виконання операції');
        END IF;

        EXECUTE IMMEDIATE q'[ALTER Session SET Nls_Numeric_Characters = '.,']';

        --Парсинг
        EXECUTE IMMEDIATE Type2xmltable (Pkg, 't_Rnsp_Tariffs', TRUE)
            BULK COLLECT INTO l_Tariffs
            USING IN p_Tarriffs;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Tariff_Basis', TRUE)
            INTO l_Basis
            USING IN p_Tariff_Basis;

        l_Hs := Tools.Gethistsessioncmes;
        l_Lock := Tools.Request_Lock (p_Descr => 'SAVE_TARIFF_' || p_Rnspm_Id); --Ignore

        IF l_Basis.Doc_Dh IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'Не вказано документ на підставі якого вносяться тарифи');
        END IF;

        --Збереження підстави на внесення тарифів
        INSERT INTO Rn_Document (Rnd_Id,
                                 Rnd_Ndt,
                                 Rnd_Doc,
                                 Rnd_Dh,
                                 History_Status,
                                 Rnd_Rnspm)
             VALUES (0,
                     727,
                     l_Basis.Doc_Id,
                     l_Basis.Doc_Dh,
                     'A',
                     p_Rnspm_Id)
          RETURNING Rnd_Id
               INTO l_Rnd;

        Save_Attr (3536, p_Val_Str => l_Basis.Doc_Name);
        Save_Attr (3537, p_Val_Str => l_Basis.Doc_Num);
        Save_Attr (3538, p_Val_Dt => l_Basis.Doc_Dt);


        FOR i IN 1 .. l_Tariffs.COUNT
        LOOP
            DECLARE
                l_Tariff       r_Rnsp_Tariff;
                l_Tariff_Old   Rnsp_Tariff%ROWTYPE;
            BEGIN
                l_Tariff := l_Tariffs (i);

                -------------ЗАГАЛЬНІ КОНТРОЛІ------------------
                IF l_Tariff.Rnspt_Start_Dt IS NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Дата початку дії тарифу не може бути порожньою');
                END IF;

                -- #97407
                /*IF l_Tariff.Rnspt_Stop_Dt IS NULL THEN
                  Raise_Application_Error(-20000,
                                          'Дата завершення дії тарифу не може бути порожньою');
                END IF;*/

                -- #101042
                /* IF l_Tariff.Rnspt_Start_Dt < Trunc(SYSDATE) THEN
                   Raise_Application_Error(-20000,
                                           'Дата початку дії тарифу не може бути менше поточної');
                 END IF;*/

                -- #97407
                IF     l_Tariff.Rnspt_Stop_Dt IS NOT NULL
                   AND l_Tariff.Rnspt_Stop_Dt < TRUNC (SYSDATE)
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Дата завершення дії тарифу не може бути менше поточної');
                END IF;

                IF l_Tariff.Rnspt_Start_Dt > l_Tariff.Rnspt_Stop_Dt
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Дата початку дії тарифу не може бути більше дати завершення тарифу');
                END IF;

                IF l_Tariff.Rnspt_Nst IS NULL
                THEN
                    Raise_Application_Error (-20000,
                                             'Не вказано послугу для тарифу');
                END IF;

                IF    l_Tariff.Rnspt_Sum IS NULL
                   OR l_Tariff.Rnspt_Sum_Fm IS NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Не вказано вартість надання послуги для особи та сім`ї');
                END IF;

                --Перевірка наявності полсуги в переліку послуг поточного надавача
                SELECT SIGN (COUNT (*))
                  INTO l_Svc_Exists
                  FROM Rnsp_State  s
                       JOIN Rnsp2service t ON s.Rnsps_Id = t.Rnsp2s_Rnsps
                       JOIN Rnsp_Dict_Service d
                           ON     t.Rnsp2s_Rnspds = d.Rnspds_Id
                              AND d.Rnspds_Nst = l_Tariff.Rnspt_Nst
                 WHERE s.Rnsps_Rnspm = p_Rnspm_Id AND s.History_Status = 'A';

                IF l_Svc_Exists <> 1
                THEN
                    SELECT MAX (t.Nst_Name)
                      INTO l_Nst_Name
                      FROM Uss_Ndi.v_Ndi_Service_Type t
                     WHERE t.Nst_Id = l_Tariff.Rnspt_Nst;

                    Raise_Application_Error (
                        -20000,
                           'Послуга "'
                        || l_Nst_Name
                        || '" не зазначена в переліку послуг надавача');
                END IF;

                --Перевірка наявності перетинів періоду тарифу що зберігається
                --з періодами наявних тарифів
                SELECT MAX (n.Nst_Name),
                       LISTAGG (
                              'з'
                           || TO_CHAR (t.Rnspt_Start_Dt, 'dd.mm.yyyy')
                           || ' по '
                           || TO_CHAR (t.Rnspt_Stop_Dt, 'dd.mm.yyyy'),
                           ';')
                       WITHIN GROUP (ORDER BY t.Rnspt_Start_Dt)
                  INTO l_Nst_Name, l_Cross_Periods
                  FROM Rnsp_Tariff  t
                       JOIN Uss_Ndi.v_Ndi_Service_Type n
                           ON t.Rnspt_Nst = n.Nst_Id
                 WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                       AND t.History_Status = 'A'
                       AND t.Rnspt_Nst = l_Tariff.Rnspt_Nst
                       AND t.Rnspt_Id <> NVL (l_Tariff.Rnspt_Id, -1)
                       AND (   (l_Tariff.Rnspt_Start_Dt BETWEEN t.Rnspt_Start_Dt
                                                            AND t.Rnspt_Stop_Dt)
                            OR (l_Tariff.Rnspt_Stop_Dt BETWEEN t.Rnspt_Start_Dt
                                                           AND t.Rnspt_Stop_Dt)
                            OR (t.Rnspt_Start_Dt BETWEEN l_Tariff.Rnspt_Start_Dt
                                                     AND l_Tariff.Rnspt_Stop_Dt)
                            OR (t.Rnspt_Stop_Dt BETWEEN l_Tariff.Rnspt_Start_Dt
                                                    AND l_Tariff.Rnspt_Stop_Dt));

                IF l_Cross_Periods IS NOT NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                           'По послузі "'
                        || l_Nst_Name
                        || '" вказано період, що перетинається з іншими тарифами: '
                        || l_Cross_Periods);
                END IF;


                -------------РЕДАГУВАННЯ ІНСУЮЧОГО ТАРИФУ------------------
                IF NVL (l_Tariff.Rnspt_Id, -1) > 0
                THEN
                    SELECT *
                      INTO l_Tariff_Old
                      FROM Rnsp_Tariff t
                     WHERE t.Rnspt_Id = l_Tariff.Rnspt_Id;

                    -------------КОНТРОЛІ ПРИ РЕДАГУВАНІ ІНСУЮЧОГО ТАРИФУ------------------
                    IF l_Tariff_Old.Rnspt_Rnspm <> p_Rnspm_Id
                    THEN
                        Raise_Application_Error (
                            -20000,
                            'Недостатньо прав на виконання операції');
                    END IF;

                    IF l_Tariff_Old.Rnspt_Stop_Dt < SYSDATE
                    THEN
                        Raise_Application_Error (
                            -20000,
                            'Заборонено змінювати тариф, дата завершення якого менше поточної');
                    END IF;

                    IF     l_Tariff_Old.Rnspt_Start_Dt < SYSDATE
                       AND l_Tariff_Old.Rnspt_Start_Dt <>
                           l_Tariff.Rnspt_Start_Dt
                    THEN
                        Raise_Application_Error (
                            -20000,
                            'Заборонено змінювати дату початку дії тарифу, яка менше поточної');
                    END IF;

                    IF     l_Tariff_Old.Rnspt_Start_Dt < SYSDATE
                       AND (   NVL (l_Tariff_Old.Rnspt_Sum, 0) <>
                               NVL (l_Tariff.Rnspt_Sum, 0)
                            OR NVL (l_Tariff_Old.Rnspt_Sum_Fm, 0) <>
                               NVL (l_Tariff.Rnspt_Sum_Fm, 0))
                    THEN
                        Raise_Application_Error (
                            -20000,
                            'Заборонено змінювати cуму тарифу, дата початку дії якого менше поточної');
                    END IF;

                    IF     l_Tariff_Old.Rnspt_Start_Dt < SYSDATE
                       AND l_Tariff_Old.Rnspt_Nst <> l_Tariff.Rnspt_Nst
                    THEN
                        Raise_Application_Error (
                            -20000,
                            'Заборонено змінювати послугу в тарифі, дата початку дії якого менше поточної');
                    END IF;

                    --При редагуванні тарифу поточний запис переводиться в історичний стан
                    --та створюється новий запис, в якому вказується нова підстава на внесення тарифів(Rnspt_Rnd).
                    --Таким чином маємо історію збережень з різними підставами
                    UPDATE Rnsp_Tariff t
                       SET t.History_Status = 'H'
                     WHERE t.Rnspt_Id = l_Tariff.Rnspt_Id;
                ELSE
                    -------------Перевіряю, чи є діючий тариф на цію ж послугу, бо не повинно бути дублів------------------
                    SELECT MAX (Rnspt_id)
                      INTO l_Rnspt_id
                      FROM Rnsp_Tariff t
                     WHERE     Rnspt_Rnspm = p_Rnspm_Id
                           AND Rnspt_Nst = l_Tariff.Rnspt_Nst
                           AND History_Status = 'A'
                           -- #101042: діючим тариф може бути лише в якийсь період
                           AND t.rnspt_stop_dt >= l_Tariff.Rnspt_Start_Dt
                           AND t.rnspt_start_dt <= l_Tariff.Rnspt_Stop_Dt;

                    IF l_Rnspt_id IS NOT NULL
                    THEN
                        Raise_Application_Error (
                            -20000,
                               'Для НСП з ІД ['
                            || p_Rnspm_Id
                            || '] для послуги з ІД ['
                            || l_Tariff.Rnspt_Nst
                            || '] вже є рядок з активним тарифом ['
                            || l_Rnspt_id
                            || ']');
                    END IF;
                END IF;

                --Збереження тарифу
                INSERT INTO Rnsp_Tariff (Rnspt_Id,
                                         Rnspt_Rnspm,
                                         Rnspt_Nst,
                                         Rnspt_Start_Dt,
                                         Rnspt_Stop_Dt,
                                         Rnspt_Sum,
                                         Rnspt_Sum_Fm,
                                         Rnspt_Rnd,
                                         Rnspt_Hs,
                                         History_Status)
                     VALUES (0,
                             p_Rnspm_Id,
                             l_Tariff.Rnspt_Nst,
                             l_Tariff.Rnspt_Start_Dt,
                             l_Tariff.Rnspt_Stop_Dt,
                             l_Tariff.Rnspt_Sum,
                             l_Tariff.Rnspt_Sum_Fm,
                             l_Rnd,
                             l_Hs,
                             'A');
            END;
        END LOOP;
    END;

    -- лог по картці РНСП
    PROCEDURE Get_Rnsp_Log (p_Rnspm_Id          IN     NUMBER,
                            p_Ap_Log_Cursor        OUT SYS_REFCURSOR,
                            p_Rnsp_Log_Cursor      OUT SYS_REFCURSOR)
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        Tools.Writemsg ('Cmes$rnsp.Get_Rnsp_Log');

        BEGIN
            SELECT t.Ap_Id
              INTO l_Ap_Id
              FROM v_Appeal t JOIN Rnsp_Main m ON (m.Rnspm_Ap_Edit = t.Ap_Id)
             WHERE m.Rnspm_Id = p_Rnspm_Id
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Не знайдено актуального звернення по рнсп.');
        END;

        OPEN p_Ap_Log_Cursor FOR
              SELECT Apl_Id,
                     Apl_Tp,
                     Hs_Dt,
                     o.Dic_Name                                         AS Old_Status_Name,
                     n.Dic_Name                                         AS New_Status_Name,
                     CASE
                         WHEN INSTR (Apl_Message, '#', 1) > 0
                         THEN
                             SUBSTR (Apl_Message,
                                     INSTR (Apl_Message, '#', 1) + 1)
                         ELSE
                             Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                 Apl_Message)
                     END                                                AS Apl_Message,
                     NVL (Tools.Getuserlogin (Hs_Wu), 'Автоматично')    AS Apl_Hs_Author
                FROM v_Appeal,
                     v_Ap_Log,
                     Uss_Ndi.v_Ddn_Ap_St n,
                     Uss_Ndi.v_Ddn_Ap_St o,
                     Histsession
               WHERE     Apl_St = n.Dic_Value(+)
                     AND Apl_St_Old = o.Dic_Value(+)
                     AND Apl_Hs = Hs_Id(+)
                     AND Apl_Ap = Ap_Id
                     AND Apl_Ap = l_Ap_Id
            ORDER BY Hs_Dt, Apl_Id;

        OPEN p_Rnsp_Log_Cursor FOR
            SELECT Rnspsr_Id,
                   -- RNSP_MAIN
                   Rnspsr_Rnspm,
                   Rnspsr_Date,
                   Rnspsr_Reason,
                   Rnspsr_St,
                   -- HISTSESSION
                   Rnspsr_Hs,
                   h.Hs_Dt,
                   u.Wu_Id,
                   u.Wu_Login,
                   u.Wu_Pib,
                   s.Dic_Name     AS Rnspsr_St_Name
              FROM Rnsp_Status_Register
                   JOIN Histsession h ON h.Hs_Id = Rnspsr_Hs
                   JOIN Uss_Ndi.v_Ddn_Rnsp_St s ON Rnspsr_St = s.Dic_Value
                   LEFT JOIN Ikis_Sysweb.V$all_Users u ON u.Wu_Id = h.Hs_Wu
             WHERE Rnspsr_Rnspm = p_Rnspm_Id;
    END;


    -- лог по картці РНСП (уніфікований як лог по зверненню і акту)
    PROCEDURE Get_Rnsp_Log (p_Rnspm_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR)
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        Tools.Writemsg ('Cmes$rnsp.Get_Rnsp_Log');

        BEGIN
            SELECT t.Ap_Id
              INTO l_Ap_Id
              FROM v_Appeal t JOIN Rnsp_Main m ON (m.Rnspm_Ap_Edit = t.Ap_Id)
             WHERE m.Rnspm_Id = p_Rnspm_Id
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Ap_Id := -1;
        END;

        OPEN Res_Cur FOR
            SELECT Hs_Dt    AS Log_Dt,
                   CASE
                       WHEN INSTR (Apl_Message, '#', 1) > 0
                       THEN
                           SUBSTR (Apl_Message,
                                   INSTR (Apl_Message, '#', 1) + 1)
                       ELSE
                           Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                               Apl_Message)
                   END      AS Log_Msg
              FROM v_Appeal,
                   v_Ap_Log,
                   Uss_Ndi.v_Ddn_Ap_St  n,
                   Uss_Ndi.v_Ddn_Ap_St  o,
                   Histsession
             WHERE     Apl_St = n.Dic_Value(+)
                   AND Apl_St_Old = o.Dic_Value(+)
                   AND Apl_Hs = Hs_Id(+)
                   AND Apl_Ap = Ap_Id
                   AND Apl_Ap = l_Ap_Id
            UNION ALL
            SELECT h.Hs_Dt                                            AS Log_Dt,
                   s.Dic_Name || ', причина - ' || t.Rnspsr_Reason    AS Log_Msg
              FROM Rnsp_Status_Register  t
                   JOIN Histsession h ON h.Hs_Id = Rnspsr_Hs
                   JOIN Uss_Ndi.v_Ddn_Rnsp_St s ON Rnspsr_St = s.Dic_Value
                   LEFT JOIN Ikis_Sysweb.V$all_Users u ON u.Wu_Id = h.Hs_Wu
             WHERE Rnspsr_Rnspm = p_Rnspm_Id
            ORDER BY Log_Dt;
    END;

    -------------------------------------------------------------------
    --         Отримання переліку кейс менеджерів надавача #92403
    -------------------------------------------------------------------
    PROCEDURE Get_Cm_List (p_Cmes_Owner_Id   IN     NUMBER,
                           p_Pib             IN     VARCHAR2,
                           p_Numident        IN     VARCHAR2,
                           p_Show_Locked     IN     VARCHAR2 DEFAULT 'F',
                           p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Raise_Application_Error (-20000, 'unauthorized');
        END IF;

        OPEN p_Res FOR
            SELECT u.Cu_Id,
                   --ПІБ
                   u.Cu_Pib,
                   --ІПН
                   u.Cu_Numident,
                   --ДН
                   e.Em_Birthday_Dt                        AS Cu_Birth_Dt,
                   --Посади
                    (SELECT LISTAGG (p.Osp_Name, ', ')
                                WITHIN GROUP (ORDER BY 1)
                       FROM Uss_Rnsp.Em_Staff  s
                            JOIN Uss_Rnsp.Os_Staff Os
                                ON     s.Emf_Ost = Os.Ost_Id
                                   AND Os.History_Status = 'A'
                            JOIN Uss_Ndi.v_Ndi_Os_Position p
                                ON Os.Ost_Osp = p.Osp_Id
                      WHERE     s.Emf_Em = c.Cu2cmes_Em
                            AND s.History_Status = 'A')    AS Cu_Positions,
                   --Статус
                   r.History_Status                        AS Cu_Is_Locked
              FROM Ikis_Rbm.v_Cu_Users2roles  r
                   JOIN Ikis_Rbm.v_Cmes_Users u ON r.Cu2r_Cu = u.Cu_Id
                   LEFT JOIN Ikis_Rbm.v_Cu_Users2cmes c
                       ON     u.Cu_Id = c.Cu2cmes_Cu
                          AND c.Cu2cmes_Owner_Id = p_Cmes_Owner_Id
                   LEFT JOIN Uss_Rnsp.Emploee e ON c.Cu2cmes_Em = e.Em_Id
             WHERE     r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
                   AND r.Cu2r_Cr = 6
                   AND (   p_Show_Locked = 'T'
                        OR (u.Cu_Locked = 'F' AND r.History_Status = 'A'))
                   AND (   p_Pib IS NULL
                        OR UPPER (u.Cu_Pib) LIKE UPPER (p_Pib) || '%')
                   AND (   p_Numident IS NULL
                        OR u.Cu_Numident LIKE p_Numident || '%');
    END;

    PROCEDURE Get_Rec_Cm_List (p_Rnspm_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT Cu_Id, u.Cu_Pib
              FROM Ikis_Rbm.v_Cu_Users2roles  r
                   JOIN Ikis_Rbm.v_Cmes_Users u ON r.Cu2r_Cu = u.Cu_Id
                   LEFT JOIN Ikis_Rbm.v_Cu_Users2cmes c
                       ON u.Cu_Id = c.Cu2cmes_Cu
                   LEFT JOIN Uss_Rnsp.v_Emploee e ON c.Cu2cmes_Em = e.Em_Id
             WHERE r.Cu2r_Cr = 6 AND r.cu2r_cmes_owner_id = p_Rnspm_Id;
    END;

    FUNCTION Get_Rnsp_Head_Fio (p_Rnspm_id IN uss_rnsp.v_rnsp.RNSPM_ID%TYPE)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (500);
    BEGIN
        FOR cData
            IN (  SELECT rnda_val_string
                    FROM (SELECT rnda_rnd,
                                 MAX (rnda_rnd) OVER ()     max_rnda_rnd,
                                 rnda_nda,
                                 rnda_val_string
                            FROM uss_rnsp.v_rn_document d
                                 JOIN uss_rnsp.v_rn_document_attr da
                                     ON d.rnd_id = da.rnda_rnd
                           WHERE     d.rnd_RNSPM = p_Rnspm_id
                                 AND d.history_status = 'A'
                                 AND da.rnda_nda IN (1095, 1096, 1097))
                   WHERE rnda_rnd = max_rnda_rnd
                ORDER BY rnda_nda)
        LOOP
            l_Res := l_Res || cData.Rnda_Val_String || ' ';
        END LOOP;

        RETURN TRIM (l_Res);
    END;

    PROCEDURE Get_Rnsp_Providers_List (
        p_Res          OUT SYS_REFCURSOR,
        p_Koat_L1   IN     NUMBER DEFAULT NULL,
        p_Koat_L2   IN     NUMBER DEFAULT NULL,
        p_Koat_L3   IN     NUMBER DEFAULT NULL,
        p_Koat_L4   IN     NUMBER DEFAULT NULL,
        p_Koat_L5   IN     NUMBER DEFAULT NULL)
    IS
        l_Query    VARCHAR2 (32000);
        l_Filter   VARCHAR2 (32000);
    BEGIN
        l_Query := 'SELECT distinct
                        r.RNSPS_NUMIDENT,
                        r.RNSPS_LAST_NAME
                   FROM v_rnsp r
                   WHERE 1=1
                   #<FILTER>#
                   ORDER BY r.RNSPS_LAST_NAME
                   ';

        IF (p_Koat_L5 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RNSPS_ID IN (SELECT r2a.RNSP2A_RNSPS
                         FROM rnsp_address ra
                         JOIN rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l5 = '
                || p_Koat_L5
                || '
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l5))';
        ELSIF (p_Koat_L4 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RNSPS_ID IN (SELECT r2a.RNSP2A_RNSPS
                         FROM rnsp_address ra
                         JOIN rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l4 = '
                || p_Koat_L4
                || ' and k.kaot_kaot_l5 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l4))';
        ELSIF (p_Koat_L3 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RNSPS_ID IN (SELECT r2a.RNSP2A_RNSPS
                         FROM rnsp_address ra
                         JOIN rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l3 = '
                || p_Koat_L3
                || ' and k.kaot_kaot_l4 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l3))';
        ELSIF (p_Koat_L2 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RNSPS_ID IN (SELECT r2a.RNSP2A_RNSPS
                         FROM rnsp_address ra
                         JOIN rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l2 = '
                || p_Koat_L2
                || ' and k.kaot_kaot_l3 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l2))';
        ELSIF (p_Koat_L1 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RNSPS_ID IN (SELECT r2a.RNSP2A_RNSPS
                         FROM rnsp_address ra
                         JOIN rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l1 = '
                || p_Koat_L1
                || ' and k.kaot_kaot_l2 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l1))';
        END IF;



        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);

        OPEN p_Res FOR l_Query;
    END;
BEGIN
    NULL;
END Cmes$rnsp;
/