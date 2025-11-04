/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_ANPK_ANPOE
IS
    -- Author  : OLEKSII
    -- Created : 11.11.2023 18:37:51
    -- Purpose : перегляд інформації щодо сформованих та внесених актів з надання соціальних послуг екстрено (кризово)

    Pkg   VARCHAR2 (50) := 'CMES$ACT_ANPK_ANPOE';

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    --==============================================================--
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);
END Cmes$Act_Anpk_Anpoe;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPK_ANPOE TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPK_ANPOE TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:19 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_ANPK_ANPOE
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   tp.Dic_Name
                       AS At_tp_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   --ОСЗН
                   o.Org_Name
                       AS At_Org_Name,
                   --Ким сформовано
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Найменування організації
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   a.At_Main_Link
                       AS At_Decision
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN uss_ndi.v_ddn_at_tp tp ON a.At_tp = tp.Dic_Value
                   JOIN (SELECT * FROM Uss_Ndi.v_Ddn_At_Anpoe_St
                         UNION ALL
                         SELECT * FROM Uss_Ndi.v_Ddn_At_Anpk_St) s
                       ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value;
    END;

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    --==============================================================--
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
        l_at_st   VARCHAR2 (10);
    BEGIN
        l_at_st := '_' || SUBSTR (p_At_St, 2);
        Write_Audit ('Get_Acts_Pr');

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Adm_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp IN ('ANPK', 'ANPOE')
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND a.At_Num LIKE p_At_Num || '%'
                   AND (p_At_St IS NULL OR a.At_St LIKE l_At_St);

        Get_Act_List (p_Res);
    END;
END Cmes$Act_Anpk_Anpoe;
/