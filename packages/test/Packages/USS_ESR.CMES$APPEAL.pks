/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$APPEAL
IS
    -- Author  : SHOSTAK
    -- Created : 03.07.2023 4:01:55 PM
    -- Purpose :

    Package_Name   CONSTANT VARCHAR2 (100) := 'CMES$APPEAL';

    FUNCTION Get_Wu_Pib (p_Wu_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Modify_Dt (p_Ap_Id IN NUMBER)
        RETURN DATE;

    PROCEDURE Get_Potential_Ss_Rec (
        p_Cmes_Owner_Id   IN     NUMBER,                         --ІД надавача
        p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
        p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
        p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Src          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Sub_Tp       IN     VARCHAR2 DEFAULT NULL,
        p_App_Pib         IN     VARCHAR2 DEFAULT NULL,         --ПІБ заявника
        p_At_St           IN     VARCHAR2 DEFAULT NULL,         --Стан рішення
        p_At_Cu_Pib       IN     VARCHAR2 DEFAULT NULL,              --Піб КМа
        p_Need_Sign       IN     VARCHAR2, --Наявність документів на підпис затвердження(T/F)
        p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Current_Ss_Rec (
        p_Cmes_Owner_Id   IN     NUMBER,                         --ІД надавача
        p_At_Reg_Start    IN     DATE DEFAULT NULL,
        p_At_Reg_Stop     IN     DATE DEFAULT NULL,
        p_At_Num          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Src          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Sub_Tp       IN     VARCHAR2 DEFAULT NULL,
        p_App_Pib         IN     VARCHAR2 DEFAULT NULL,         --ПІБ заявника
        p_App_Sc_Pib      IN     VARCHAR2 DEFAULT NULL,       --ПІБ отримувача
        p_At_St           IN     VARCHAR2 DEFAULT NULL,         --Стан рішення
        p_At_Cu_Pib       IN     VARCHAR2 DEFAULT NULL,              --Піб КМа
        p_Need_Sign       IN     VARCHAR2 DEFAULT NULL, --Наявність документів на підпис затвердження(T/F)
        p_Res                OUT SYS_REFCURSOR);


    PROCEDURE Get_Appeals_Cm (p_Ap_Reg_Start   IN     DATE DEFAULT NULL,
                              p_Ap_Reg_Stop    IN     DATE DEFAULT NULL,
                              p_Ap_Num         IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_St          IN     VARCHAR2 DEFAULT NULL,
                              p_Com_Org        IN     NUMBER DEFAULT NULL,
                              p_App_Pib        IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Sub_Tp      IN     VARCHAR2 DEFAULT NULL,
                              p_Res               OUT SYS_REFCURSOR,
                              p_Ap_Ap_Main     IN     NUMBER DEFAULT NULL);

    FUNCTION Check_Ap_Access (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;


    PROCEDURE Get_Appeal_Card (p_Ap_Id            IN     VARCHAR2,
                               p_Main_Cur            OUT SYS_REFCURSOR,
                               p_Ser_Cur             OUT SYS_REFCURSOR,
                               p_Pers_Cur            OUT SYS_REFCURSOR,
                               p_Docs_Cur            OUT SYS_REFCURSOR,
                               p_Docs_Attr_Cur       OUT SYS_REFCURSOR,
                               p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                               p_Log_Cur             OUT SYS_REFCURSOR);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Get_moz_dzp_by_ap (p_Ap_id          IN     NUMBER,
                                 p_Moz_Dzr_Data      OUT SYS_REFCURSOR);
END Cmes$appeal;
/


GRANT EXECUTE ON USS_ESR.CMES$APPEAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$APPEAL TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$APPEAL TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$APPEAL TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$APPEAL
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Package_Name || '.' || p_Proc_Name);
    END;

    FUNCTION Check_Act_Access (p_At_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_At_Rnspm   NUMBER;
        l_At_Cu      NUMBER;
    BEGIN
        SELECT a.At_Rnspm, a.At_Cu
          INTO l_At_Rnspm, l_At_Cu
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$APPEAL.Check_Act_Access',
            p_obj_tp   => 'ACT',
            p_obj_id   => p_At_Id,
            p_regular_params   =>
                   'p_Cu_Id='
                || Ikis_Rbm.Tools.Getcurrentcu
                || ' p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider
                || ', l_At_Cu='
                || l_At_Cu
                || ', l_At_Rnspm='
                || l_At_Rnspm,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        IF l_At_Cu = Ikis_Rbm.Tools.Getcurrentcu
        THEN
            RETURN TRUE;
        END IF;

        IF Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
               p_Cu_Id           => Ikis_Rbm.Tools.Getcurrentcu,
               p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
               p_Cmes_Owner_Id   => l_At_Rnspm,
               p_Cr_Code         => 'NSP_SPEC')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        IF NOT Check_Act_Access (p_At_Id)
        THEN
            Raise_Application_Error (-20000, 'Недостатньо прав');
        END IF;
    END;

    PROCEDURE Get_Ap_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   St.Dic_Sname
                       AS Ap_St_Name,
                   Tp.Dic_Sname
                       AS Ap_Tp_Name,
                   Src.Dic_Sname
                       AS Ap_Src_Name,
                   o.Org_Code || ' ' || o.Org_Name
                       AS Com_Org_Name,
                   NVL (Uss_Person.Api$sc_Tools.Get_Pib_Scc (z.App_Scc),
                        uss_visit.dnet$appeal.Get_Ap_Person_Pib (z.app_id))
                       AS App_Pib,
                   Sb.Dic_Name
                       AS Ap_Sub_Tp_Name,
                   Get_Ap_Modify_Dt (a.Ap_Id)
                       AS Ap_Modify_Dt,
                   CASE
                       WHEN a.Com_Wu IS NOT NULL
                       THEN
                           Get_Wu_Pib (a.Com_Wu)
                       WHEN a.Ap_Cu IS NOT NULL
                       THEN
                           Ikis_Rbm.Tools.Getcupib (a.Ap_Cu)
                   END
                       AS Ap_Modify_Wu,
                   (SELECT MAX (ndt_name)
                      FROM v_ap_document  z
                           JOIN uss_ndi.v_ndi_document_type zt
                               ON (zt.ndt_id = z.apd_ndt)
                     WHERE     z.apd_ap = a.ap_id
                           AND z.history_status = 'A'
                           AND z.apd_ndt IN (801,
                                             802,
                                             835,
                                             836,
                                             1015))
                       AS apd_init_name
              FROM Tmp_Work_Ids  i
                   JOIN Appeal a ON i.x_Id = a.Ap_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON a.Ap_St = St.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp ON a.Ap_Tp = Tp.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.Ap_Src = Src.Dic_Value
                   JOIN Opfu o ON a.Com_Org = o.Org_Id
                   JOIN Ap_Person z
                       ON     a.Ap_Id = z.App_Ap
                          AND z.App_Tp = 'Z'
                          AND z.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp Sb
                       ON a.Ap_Sub_Tp = Sb.Dic_Value;
    END;

    ---------------------------------------------------------------------
    --             Отримання переліку звернень по договору
    ---------------------------------------------------------------------
    PROCEDURE Get_Appeals_By_Tctr (p_Tctr_Id   IN     NUMBER,
                                   p_Res          OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Appeals_By_Tctr');

        Cmes$act_Tctr.Check_Act_Access (p_Tctr_Id);

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Ap
              FROM Act a
             WHERE a.At_Id = p_Tctr_Id AND a.At_Tp = 'TCTR'
            UNION ALL
            SELECT Ap.Ap_Id
              FROM At_Links  l
                   JOIN Act a ON l.Atk_At = a.At_Id AND a.At_Tp = 'RSTOPSS'
                   JOIN Appeal Ap
                       ON a.At_Ap = Ap.Ap_Id AND Ap.Ap_Tp IN ('R.OS')
             WHERE l.Atk_Link_At = p_Tctr_Id AND l.Atk_Tp = 'TCTR';

        Get_Ap_List (p_Res);
    END;

    ---------------------------------------------------------------------
    --             Отримання переліку потенційних отримувачів
    ---------------------------------------------------------------------
    PROCEDURE Get_Potential_Ss_Rec (
        p_Cmes_Owner_Id   IN     NUMBER,                         --ІД надавача
        p_Ap_Reg_Start    IN     DATE DEFAULT NULL,
        p_Ap_Reg_Stop     IN     DATE DEFAULT NULL,
        p_Ap_Num          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Src          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Sub_Tp       IN     VARCHAR2 DEFAULT NULL,
        p_App_Pib         IN     VARCHAR2 DEFAULT NULL,         --ПІБ заявника
        p_At_St           IN     VARCHAR2 DEFAULT NULL,         --Стан рішення
        p_At_Cu_Pib       IN     VARCHAR2 DEFAULT NULL,              --Піб КМа
        p_Need_Sign       IN     VARCHAR2, --Наявність документів на підпис затвердження(T/F)
        p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Potential_Ss_Rec');
        --raise_application_error(-20000, 'p_Cmes_Owner_Id='||p_Cmes_Owner_Id);
        Tools.LOG (
            p_src      => 'USS_ESR.CMES$APPEAL.Get_Potential_Ss_Rec',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Cmes_Owner_Id='
                || p_Cmes_Owner_Id
                || ' p_Ap_Reg_Start='
                || p_Ap_Reg_Start
                || ' p_Ap_Reg_Stop='
                || p_Ap_Reg_Stop
                || ' p_Ap_Num='
                || p_Ap_Num
                || ' p_Ap_Src='
                || p_Ap_Src
                || ' p_Ap_Sub_Tp='
                || p_Ap_Sub_Tp
                || ' p_App_Pib='
                || p_App_Pib
                || ' p_At_Cu_Pib='
                || p_At_Cu_Pib
                || ' p_Need_Sign='
                || p_Need_Sign,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cu_Id           => Ikis_Rbm.Tools.Getcurrentcu,
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Tools.LOG (
                p_src      => 'USS_ESR.CMES$APPEAL.Get_Potential_Ss_Rec',
                p_obj_tp   => 'CMES_OWNER_ID',
                p_obj_id   => p_Cmes_Owner_Id,
                p_regular_params   =>
                       'Insufficient privileges. p_Cu_Id='
                    || Ikis_Rbm.Tools.Getcurrentcu
                    || ' p_Cmes_Id='
                    || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                p_lob_param   =>
                    tools.GetStartPackageName (
                        DBMS_UTILITY.FORMAT_CALL_STACK ()));

            Raise_Application_Error (-20000, 'Недостаньо прав для переглягу');
            NULL;
        END IF;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   p.Ap_Id,
                   p.Ap_Num,
                   p.Ap_Reg_Dt,
                   p.Ap_Create_Dt,
                   p.Ap_Src,
                   s.Dic_Name
                       AS Ap_Src_Name,
                   a.At_St,
                   COALESCE (St.Dic_Name,
                             stp.Dic_Name,
                             sta.DIC_NAME,
                             sto.DIC_NAME,
                             Strst.DIC_NAME)
                       AS At_St_Name,
                   --Заявник
                   NVL (
                       Uss_Person.Api$sc_Tools.Get_Pib_Scc (
                           z.App_Scc),
                       uss_visit.dnet$appeal.Get_Ap_Person_Pib (
                           z.app_id))
                       AS App_Pib,
                   --Отримувач
                   COALESCE (
                       Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc),
                       --#115152
                       uss_visit.dnet$appeal.Get_Ap_Pib (a.at_ap))
                       AS Rec_Pib,
                   a.At_Sc
                       AS Rec_Sc,
                   --todo: уточнити щодо окремого поля "КМ для рішення"
                   a.At_Cu,
                   Ikis_Rbm.Tools.Getcupib (a.At_Cu)
                       AS At_Cu_Pib,
                   --Наявність документів на підпис затвердження
                    (SELECT DECODE (COUNT (*), 0, 'F', 'T')
                       FROM Act Ns
                      WHERE     Ns.At_Ap = a.At_Ap
                            AND Ns.At_St IN ('AK',
                                             'VK',
                                             'DS',
                                             'IK',
                                             'SN'))
                       AS Need_Sign,
                   p.Ap_Sub_Tp,
                   t.Dic_Name
                       AS Ap_Sub_Tp_Name,
                   COUNT (DISTINCT a.at_sc) OVER ()
                       At_Sc_Total
              FROM Act  a
                   JOIN Appeal p ON a.At_Ap = p.Ap_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp t
                       ON p.Ap_Sub_Tp = t.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St
                       ON a.At_St = St.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Apop_St Stp
                       ON a.At_St = Stp.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Anpoe_St Sta
                       ON a.At_St = Sta.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Oks_St Sto
                       ON a.At_St = Sto.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Rstopss_St Strst
                       ON a.At_St = Strst.Dic_Value
                   LEFT JOIN
                   (SELECT z.app_id,
                           z.app_ap,
                           z.app_scc,
                           z.app_tp,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY z.app_ap
                                   ORDER BY
                                       CASE
                                           WHEN z.app_tp = 'Z' THEN 1
                                           WHEN z.app_tp = 'OR' THEN 2
                                           WHEN z.app_tp = 'AP' THEN 3
                                           WHEN z.app_tp = 'AF' THEN 4
                                           ELSE tp.DIC_SRTORDR
                                       END)    rn
                      FROM Ap_Person  z
                           JOIN uss_Ndi.v_Ddn_App_Tp tp
                               ON z.app_tp = tp.DIC_VALUE
                     WHERE     z.History_Status = 'A'
                           AND z.App_Tp IN ('Z',
                                            'OR',
                                            'AP',
                                            'AF')) z
                       ON p.Ap_Id = z.App_Ap AND rn = 1
                   --LEFT JOIN Uss_Person.v_Sc_Change c
                   --  ON z.App_Scc = c.Scc_Id
                   --LEFT JOIN Uss_Person.v_Sc_Identity i
                   --  ON c.Scc_Sci = i.Sci_Id
                   LEFT JOIN Ikis_Rbm.v_Cmes_Users u ON a.At_Cu = u.Cu_Id
             WHERE     (   (    a.At_Tp = 'PDSP'
                            --Зміни відповідно до задачі https://redmine.med/issues/95964
                            AND a.At_St IN ('SP1',
                                            'SR',
                                            'SW',
                                            'SN',
                                            'SGP',
                                            'O.SR',
                                            'O.SR',
                                            'O.SW',
                                            'O.SN')
                            AND p.Ap_Sub_Tp IN ('SZ',
                                                'SM',
                                                'SC',
                                                'SO'))
                        OR (    a.at_tp = 'APOP'
                            AND a.At_St IN ('AN',
                                            'AV',
                                            'AK',
                                            'AS')
                            AND AP_ST = 'WD'
                            AND Api$appeal.Is_Appeal_Maked_Correct (p.ap_id) =
                                0
                            --region #111777 111516
                            AND CASE
                                    WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                                 a.at_ap) =
                                             0
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM at_log
                                                   WHERE     atl_at = a.at_id
                                                         AND atl_st = 'AS')
                                         AND (   (    EXISTS
                                                          (SELECT 1
                                                             FROM at_section_feature
                                                                  atf
                                                            WHERE     atf.atef_at =
                                                                      a.at_id
                                                                  AND atf.atef_nda IN
                                                                          (843)
                                                                  AND atf.atef_feature =
                                                                      'T')
                                                  AND a.at_conclusion_tp =
                                                      'V2')
                                              OR (    EXISTS
                                                          (SELECT 1
                                                             FROM at_section_feature
                                                                  atf
                                                            WHERE     atf.atef_at =
                                                                      a.at_id
                                                                  AND atf.atef_nda IN
                                                                          (2062)
                                                                  AND atf.atef_feature =
                                                                      'T')
                                                  AND a.at_conclusion_tp =
                                                      'V1'))
                                    THEN
                                        0
                                    WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                                 a.at_ap) =
                                             1
                                         AND NOT EXISTS
                                                 (SELECT 1
                                                    FROM at_log
                                                   WHERE     atl_at =
                                                             a.at_main_link
                                                         AND atl_st = 'SD')
                                    THEN
                                        1
                                    ELSE
                                        1
                                END =
                                1--end region #111777
                                 --AND (a.at_main_link_tp is null or a.at_main_link_tp!='DECISION')
                                 )
                        OR (    a.at_tp = 'OKS'
                            AND a.At_St IN ('TN', 'TV', 'TS')
                            AND AP_ST = 'WD'
                            AND Api$appeal.Is_Appeal_Maked_Correct (p.ap_id) =
                                0--AND (a.at_main_link_tp is null or a.at_main_link_tp!='DECISION')
                                 )
                        OR (    a.at_tp = 'ANPOE'
                            AND a.At_St IN ('XN',
                                            'XD',
                                            'XV',
                                            'XS',
                                            'XP')
                            AND AP_ST = 'WD'
                            AND Api$appeal.Is_Appeal_Maked_Correct (p.ap_id) =
                                0--AND (a.at_main_link_tp is null or a.at_main_link_tp!='DECISION')
                                 )
                        --#111840
                        OR (a.at_tp = 'RSTOPSS' AND a.At_St IN ('RS.C')))
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Виключаємо початкові статуси рішення(коли ще не призначено надавача)
                   --NOT IN ('W', 'O', 'SC', 'SS') -- IN ('SP1', 'SA', 'SP2', 'SI', 'O.SA')
                   AND a.At_St = NVL (p_At_St, a.At_St)
                   AND p.Ap_Sub_Tp = NVL (p_Ap_Sub_Tp, p.Ap_Sub_Tp)
                   AND (p_Ap_Num IS NULL OR p.Ap_Num LIKE p_Ap_Num || '%')
                   AND p.Ap_Reg_Dt BETWEEN NVL (p_Ap_Reg_Start, p.Ap_Reg_Dt)
                                       AND NVL (p_Ap_Reg_Stop, p.Ap_Reg_Dt)
                   AND p.Ap_Src = NVL (p_Ap_Src, p.Ap_Src)
                   AND (   p_App_Pib IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM Uss_Person.v_Sc_Change  c
                                       JOIN Uss_Person.v_Sc_Identity i
                                           ON c.Scc_Sci = i.Sci_Id
                                 WHERE     z.App_Scc = c.Scc_Id
                                       AND i.Sci_Ln || i.Sci_Fn || i.Sci_Mn LIKE
                                                  UPPER (
                                                      REPLACE (p_App_Pib,
                                                               ' '))
                                               || '%'))
                   AND (   p_At_Cu_Pib IS NULL
                        OR UPPER (u.Cu_Pib) LIKE UPPER (p_At_Cu_Pib) || '%')
                   AND (   NVL (p_Need_Sign, 'F') = 'F'
                        OR EXISTS
                               (SELECT 1
                                  FROM Act Ns
                                 WHERE     Ns.At_Ap = a.At_Ap
                                       AND Ns.At_St IN ('AK',
                                                        'VK',
                                                        'DS',
                                                        'IK',
                                                        'SN') --todo: уточнити щодо статусів
                                                             ));
    END;

    ---------------------------------------------------------------------
    --             Отримання переліку поточних отримувачів
    ---------------------------------------------------------------------
    PROCEDURE Get_Current_Ss_Rec (
        p_Cmes_Owner_Id   IN     NUMBER,                         --ІД надавача
        p_At_Reg_Start    IN     DATE DEFAULT NULL,
        p_At_Reg_Stop     IN     DATE DEFAULT NULL,
        p_At_Num          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Src          IN     VARCHAR2 DEFAULT NULL,
        p_Ap_Sub_Tp       IN     VARCHAR2 DEFAULT NULL,
        p_App_Pib         IN     VARCHAR2 DEFAULT NULL,         --ПІБ заявника
        p_App_Sc_Pib      IN     VARCHAR2 DEFAULT NULL,       --ПІБ отримувача
        p_At_St           IN     VARCHAR2 DEFAULT NULL,         --Стан рішення
        p_At_Cu_Pib       IN     VARCHAR2 DEFAULT NULL,              --Піб КМа
        p_Need_Sign       IN     VARCHAR2 DEFAULT NULL, --Наявність документів на підпис затвердження(T/F)
        p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Potential_Ss_Rec');
        Tools.LOG (
            p_src      => 'USS_ESR.CMES$APPEAL.Get_Current_Ss_Rec',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Cmes_Owner_Id='
                || p_Cmes_Owner_Id
                || ' p_At_Reg_Start='
                || p_At_Reg_Start
                || ' p_At_Reg_Stop='
                || p_At_Reg_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_Ap_Src='
                || p_Ap_Src
                || ' p_Ap_Sub_Tp='
                || p_Ap_Sub_Tp
                || ' p_App_Pib='
                || p_App_Pib
                || ' p_At_Cu_Pib='
                || p_At_Cu_Pib
                || ' p_Need_Sign='
                || p_Need_Sign,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));


        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cu_Id           => Ikis_Rbm.Tools.Getcurrentcu,
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Tools.LOG (
                p_src      => 'USS_ESR.CMES$APPEAL.Get_Current_Ss_Rec',
                p_obj_tp   => 'CMES_OWNER_ID',
                p_obj_id   => p_Cmes_Owner_Id,
                p_regular_params   =>
                       'Insufficient privileges. p_Cu_Id='
                    || Ikis_Rbm.Tools.Getcurrentcu
                    || ' p_Cmes_Id='
                    || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                p_lob_param   =>
                    tools.GetStartPackageName (
                        DBMS_UTILITY.FORMAT_CALL_STACK ()));

            Raise_Application_Error (-20000, 'Недостаньо прав для переглягу');
            NULL;
        END IF;


        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.at_num,
                   p.Ap_Id,
                   p.Ap_Num,
                   p.Ap_Reg_Dt,
                   p.Ap_Create_Dt,
                   p.Ap_Src,
                   s.Dic_Name
                       AS Ap_Src_Name,
                   a.at_dt,
                   a.At_St,
                   COALESCE (St.Dic_Name,
                             Sto.Dic_Name,
                             Stp.Dic_Name,
                             Sta.Dic_Name)
                       AS At_St_Name,
                   a.at_org,
                   opfu.org_code,
                   opfu.org_name,
                   --Заявник
                   Uss_Person.Api$sc_Tools.Get_Pib_Scc (z.App_Scc)
                       AS App_Pib,
                   --Отримувач
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS Rec_Pib,
                   a.At_Sc
                       AS Rec_Sc,
                   --todo: уточнити щодо окремого поля "КМ для рішення"
                   a.At_Cu,
                   Ikis_Rbm.Tools.Getcupib (a.At_Cu)
                       AS At_Cu_Pib,
                   --Кому буде направлено рішення на затверження
                   At_Direction,
                   (SELECT r.Dic_Name
                      FROM Uss_Ndi.v_Ddn_Ss_Rcp_Ap r
                     WHERE r.Dic_Value = At_Direction)
                       AS At_Direction_Name,
                   --Наявність документів на підпис затвердження
                    (SELECT DECODE (COUNT (*), 0, 'F', 'T')
                       FROM Act Ns
                      WHERE     Ns.At_Ap = a.At_Ap
                            AND Ns.At_St IN ('AK',
                                             'VK',
                                             'DS',
                                             'IK',
                                             'SN',
                                             'FN',
                                             'FV'))
                       AS Need_Sign,
                   p.Ap_Sub_Tp,
                   t.Dic_Name
                       AS Ap_Sub_Tp_Name,
                   COUNT (DISTINCT a.at_sc) OVER ()
                       At_Sc_Total,
                   tctr.at_id
                       tctr_at_id,
                   tctr.at_num
                       tctr_at_num
              FROM (SELECT a.*,
                           Api$appeal.Get_Ap_Doc_Str (
                               p_Ap_Id       => a.At_Ap,
                               p_Nda_Class   => 'DIRECTION')   At_Direction
                      FROM Act a) a
                   JOIN Appeal p ON a.At_Ap = p.Ap_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp t
                       ON p.Ap_Sub_Tp = t.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St
                       ON a.At_St = St.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Oks_St Sto
                       ON a.At_St = Sto.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Apop_St Stp
                       ON a.At_St = Stp.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Anpoe_St Sta
                       ON a.At_St = Sta.Dic_Value
                   LEFT JOIN
                   (SELECT z.app_id,
                           z.app_ap,
                           z.app_scc,
                           z.app_tp,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY z.app_ap
                                   ORDER BY
                                       CASE
                                           WHEN z.app_tp = 'Z' THEN 1
                                           WHEN z.app_tp = 'OR' THEN 2
                                           WHEN z.app_tp = 'AP' THEN 3
                                           WHEN z.app_tp = 'AF' THEN 4
                                           ELSE tp.DIC_SRTORDR
                                       END)    rn
                      FROM Ap_Person  z
                           JOIN uss_Ndi.v_Ddn_App_Tp tp
                               ON z.app_tp = tp.DIC_VALUE
                     WHERE     z.History_Status = 'A'
                           AND z.App_Tp IN ('Z',
                                            'OR',
                                            'AP',
                                            'AF')) z
                       ON p.Ap_Id = z.App_Ap AND rn = 1
                   LEFT JOIN opfu ON a.at_org = opfu.org_id
                   LEFT JOIN Uss_Person.v_Sc_Change c ON z.App_Scc = c.Scc_Id
                   LEFT JOIN Uss_Person.v_Sc_Identity i
                       ON c.Scc_Sci = i.Sci_Id
                   LEFT JOIN Ikis_Rbm.v_Cmes_Users u ON a.At_Cu = u.Cu_Id
                   LEFT JOIN act tctr
                       ON     tctr.at_main_link = a.at_id
                          AND tctr.at_main_link_tp = 'DECISION'
                          AND tctr.at_tp = 'TCTR'
             WHERE     1 = 1
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   AND (   (    a.At_Tp = 'PDSP' --Зміни відповідно до задачі https://redmine.med/issues/95964
                            AND a.At_St IN ('SA',
                                            'O.SA',
                                            'SU',
                                            'SJ',
                                            'SP2',
                                            'SI',
                                            'SGO',
                                            'SGM',
                                            'SGA',
                                            'SS',
                                            'SV',
                                            'SNR'))
                        OR (    a.At_Tp = 'APOP'
                            AND a.At_St IN ('AP', 'AR')
                            AND AP_ST != 'WD'
                            AND (   a.at_main_link_tp IS NULL
                                 OR a.at_main_link_tp != 'DECISION')
                            --region #111777 111516
                            AND CASE
                                    WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                                 a.at_ap) =
                                             0
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM at_log
                                                   WHERE     atl_at = a.at_id
                                                         AND atl_st = 'AS')
                                         AND (   (    EXISTS
                                                          (SELECT 1
                                                             FROM at_section_feature
                                                                  atf
                                                            WHERE     atf.atef_at =
                                                                      a.at_id
                                                                  AND atf.atef_nda IN
                                                                          (843)
                                                                  AND atf.atef_feature =
                                                                      'T')
                                                  AND a.at_conclusion_tp =
                                                      'V2')
                                              OR (    EXISTS
                                                          (SELECT 1
                                                             FROM at_section_feature
                                                                  atf
                                                            WHERE     atf.atef_at =
                                                                      a.at_id
                                                                  AND atf.atef_nda IN
                                                                          (2062)
                                                                  AND atf.atef_feature =
                                                                      'T')
                                                  AND a.at_conclusion_tp =
                                                      'V1'))
                                    THEN
                                        0
                                    WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                                 a.at_ap) =
                                             1
                                         AND NOT EXISTS
                                                 (SELECT 1
                                                    FROM at_log
                                                   WHERE     atl_at =
                                                             a.at_main_link
                                                         AND atl_st = 'SD')
                                    THEN
                                        1
                                    ELSE
                                        1
                                END =
                                1--end region #111777
                                 --AND Api$appeal.Is_Appeal_Maked_Correct(p.ap_id) = 1
                                 )
                        OR (    a.At_Tp = 'OKS'
                            AND a.At_St IN ('TP', 'TR')
                            AND AP_ST != 'WD'
                            AND (   a.at_main_link_tp IS NULL
                                 OR a.at_main_link_tp != 'DECISION')--AND Api$appeal.Is_Appeal_Maked_Correct(p.ap_id) = 1
                                                                    )
                        OR (    a.At_Tp = 'ANPOE'
                            AND a.At_St IN ('XP', 'XR')
                            AND AP_ST != 'WD'
                            AND (   a.at_main_link_tp IS NULL
                                 OR a.at_main_link_tp != 'DECISION')--AND Api$appeal.Is_Appeal_Maked_Correct(p.ap_id) = 0
                                                                    )
                        --#111840
                        OR (    a.at_tp = 'RSTOPSS'
                            AND a.At_St IN ('RR',
                                            'RS.N',
                                            'RM.N',
                                            'RM.O',
                                            'RS.B',
                                            'RS.S')))
                   AND a.At_St = NVL (p_At_St, a.At_St)
                   AND p.Ap_Sub_Tp IN ('SZ',
                                       'SM',
                                       'SC',
                                       'SO',
                                       'SL')
                   AND p.Ap_Sub_Tp = NVL (p_Ap_Sub_Tp, p.Ap_Sub_Tp)
                   AND (   p_At_Num IS NULL
                        OR a.At_Num LIKE p_At_Num || '%'
                        OR p.Ap_Num LIKE p_At_Num || '%'
                        OR EXISTS
                               (SELECT 1
                                  FROM act a1
                                 WHERE     a1.at_ap = a.at_ap
                                       AND a1.At_Num LIKE p_At_Num || '%'))
                   AND a.At_Dt BETWEEN NVL (p_At_Reg_Start, a.At_Dt)
                                   AND NVL (p_At_Reg_Stop, a.At_Dt)
                   AND p.Ap_Src = NVL (p_Ap_Src, p.Ap_Src)
                   AND (   p_App_Pib IS NULL
                        OR i.Sci_Ln || i.Sci_Fn || i.Sci_Mn LIKE
                               UPPER (REPLACE (p_App_Pib, ' ')) || '%')
                   AND (   p_App_Sc_Pib IS NULL
                        OR UPPER (
                               REPLACE (
                                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc),
                                   ' ',
                                   '')) LIKE
                               UPPER (REPLACE (p_App_Sc_Pib, ' ')) || '%')
                   AND (   p_At_Cu_Pib IS NULL
                        OR UPPER (u.Cu_Pib) LIKE UPPER (p_At_Cu_Pib) || '%')
                   AND (   NVL (p_Need_Sign, 'F') = 'F'
                        OR EXISTS
                               (SELECT 1
                                  FROM Act Ns
                                 WHERE     Ns.At_Ap = a.At_Ap
                                       AND Ns.At_St IN ('AK',
                                                        'VK',
                                                        'DS',
                                                        'IK',
                                                        'SN',
                                                        'FN',
                                                        'FV') --todo: уточнити щодо статусів
                                                             ));
    END;

    ---------------------------------------------------------------------
    --       Отримання переліку звернень для кейс-менеджера
    --       (по призначенним на нього випадкам)
    ---------------------------------------------------------------------
    PROCEDURE Get_Appeals_Cm (p_Ap_Reg_Start   IN     DATE DEFAULT NULL,
                              p_Ap_Reg_Stop    IN     DATE DEFAULT NULL,
                              p_Ap_Num         IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_St          IN     VARCHAR2 DEFAULT NULL,
                              p_Com_Org        IN     NUMBER DEFAULT NULL,
                              p_App_Pib        IN     VARCHAR2 DEFAULT NULL,
                              p_Ap_Sub_Tp      IN     VARCHAR2 DEFAULT NULL,
                              p_Res               OUT SYS_REFCURSOR,
                              p_Ap_Ap_Main     IN     NUMBER DEFAULT NULL)
    IS
        l_Cu_Id     NUMBER;
        l_App_Pib   VARCHAR2 (300);
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_App_Pib := UPPER (REPLACE (p_App_Pib, ' '));


        Tools.LOG (
            p_src      => 'USS_ESR.CMES$APPEAL.Get_Appeals_Cm',
            p_obj_tp   => NULL,
            p_obj_id   => NULL,
            p_regular_params   =>
                   ' p_Ap_Reg_Start='
                || p_Ap_Reg_Start
                || ' p_Ap_Reg_Stop='
                || p_Ap_Reg_Stop
                || ' p_Ap_Num='
                || p_Ap_Num
                || ' p_Ap_Sub_Tp='
                || p_Ap_Sub_Tp
                || ' p_App_Pib='
                || p_App_Pib
                || ' p_Ap_Ap_Main='
                || p_Ap_Ap_Main);


        OPEN p_Res FOR
            SELECT a.*,
                   St.Dic_Sname
                       AS Ap_St_Name,
                   Tp.Dic_Sname
                       AS Ap_Tp_Name,
                   Src.Dic_Sname
                       AS Ap_Src_Name,
                   o.Org_Code || ' ' || o.Org_Name
                       AS Com_Org_Name,
                   --Заявник
                   Uss_Person.Api$sc_Tools.Get_Pib_Scc (z.App_Scc)
                       AS App_Pib,
                   Get_Ap_Modify_Dt (a.Ap_Id)
                       AS Ap_Modify_Dt,
                   CASE
                       WHEN a.Com_Wu IS NOT NULL
                       THEN
                           Get_Wu_Pib (a.Com_Wu)
                       WHEN a.Ap_Cu IS NOT NULL
                       THEN
                           Ikis_Rbm.Tools.Getcupib (a.Ap_Cu)
                   END
                       AS Ap_Modify_Wu,
                   Stp.Dic_Name
                       AS Ap_Sub_Tp_Name
              FROM Act  t
                   JOIN Appeal a ON t.At_Ap = a.Ap_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON a.Ap_St = St.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp ON a.Ap_Tp = Tp.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.Ap_Src = Src.Dic_Value
                   JOIN Opfu o ON a.Com_Org = o.Org_Id
                   JOIN Ap_Person z
                       ON     a.Ap_Id = z.App_Ap
                          AND z.App_Tp = 'Z'
                          AND z.History_Status = 'A'
                   JOIN Uss_Person.v_Sc_Change c ON z.App_Scc = c.Scc_Id
                   JOIN Uss_Person.v_Sc_Identity i ON c.Scc_Sci = i.Sci_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp Stp
                       ON a.Ap_Sub_Tp = Stp.Dic_Value
             WHERE     t.At_Cu = l_Cu_Id
                   AND (   t.At_Tp IN ('PDSP', 'RSTOPSS')
                        OR t.At_Tp IN ('APOP') AND t.at_main_link IS NULL)
                   --region #111777 111516
                   AND CASE
                           WHEN     t.At_Tp IN ('APOP')
                                AND API$APPEAL.Is_Appeal_Maked_Correct (
                                        t.at_ap) =
                                    0
                                AND EXISTS
                                        (SELECT 1
                                           FROM at_log
                                          WHERE     atl_at = t.at_id
                                                AND atl_st = 'AS')
                                AND (   (    EXISTS
                                                 (SELECT 1
                                                    FROM at_section_feature
                                                         atf
                                                   WHERE     atf.atef_at =
                                                             t.at_id
                                                         AND atf.atef_nda IN
                                                                 (843)
                                                         AND atf.atef_feature =
                                                             'T')
                                         AND t.at_conclusion_tp = 'V2')
                                     OR (    EXISTS
                                                 (SELECT 1
                                                    FROM at_section_feature
                                                         atf
                                                   WHERE     atf.atef_at =
                                                             t.at_id
                                                         AND atf.atef_nda IN
                                                                 (2062)
                                                         AND atf.atef_feature =
                                                             'T')
                                         AND t.at_conclusion_tp = 'V1'))
                           THEN
                               0
                           WHEN     t.At_Tp IN ('APOP')
                                AND API$APPEAL.Is_Appeal_Maked_Correct (
                                        t.at_ap) =
                                    1
                                AND NOT EXISTS
                                        (SELECT 1
                                           FROM at_log
                                          WHERE     atl_at = t.at_main_link
                                                AND atl_st = 'SD')
                           THEN
                               1
                           ELSE
                               1
                       END =
                       1
                   --end region #111777
                   AND a.Ap_Reg_Dt BETWEEN NVL (p_Ap_Reg_Start, a.Ap_Reg_Dt)
                                       AND NVL (p_Ap_Reg_Stop, a.Ap_Reg_Dt)
                   AND a.Ap_St = NVL (p_Ap_St, a.Ap_St)
                   AND a.Ap_Sub_Tp = NVL (p_Ap_Sub_Tp, a.Ap_Sub_Tp)
                   AND a.Com_Org = NVL (p_Com_Org, a.Com_Org)
                   AND a.ap_ap_main = NVL (p_Ap_Ap_Main, a.ap_ap_main)
                   AND (p_Ap_Num IS NULL OR a.Ap_Num LIKE p_Ap_Num || '%')
                   AND (   l_App_Pib IS NULL
                        OR i.Sci_Ln || i.Sci_Fn || i.Sci_Mn LIKE
                               l_App_Pib || '%');
    END;

    FUNCTION Get_Wu_Pib (p_Wu_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR (300);
    BEGIN
        IF p_Wu_Id IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT Wu_Pib
          INTO l_Result
          FROM Ikis_Sysweb.V$w_Users4hierarchy
         WHERE Wu_Id = p_Wu_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Modify_Dt (p_Ap_Id IN NUMBER)
        RETURN DATE
    IS
        l_Result   DATE;
    BEGIN
        SELECT MAX (s.Hs_Dt)
          INTO l_Result
          FROM Ap_Log l JOIN Histsession s ON l.Apl_Hs = s.Hs_Id
         WHERE l.Apl_Ap = p_Ap_Id;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------
    --               ОТРИМАННЯ РЕКВІЗИТІВ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Appeal (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   St.Dic_Sname
                       AS Ap_St_Name,
                   Tp.Dic_Sname
                       AS Ap_Tp_Name,
                   Src.Dic_Sname
                       AS Ap_Src_Name,
                   --o.Org_Code || ' ' || o.Org_Name AS Com_Org_Name,
                   -- #97716 п.8
                    (SELECT CASE
                                WHEN MAX (za.apda_val_string) =
                                     'G'
                                THEN
                                    uss_rnsp.api$find.Get_Nsp_Name (
                                        MAX (za2.apda_val_id))
                                ELSE
                                       o.Org_Code
                                    || ' '
                                    || o.Org_Name
                            END
                       FROM ap_document  zd
                            JOIN ap_document_attr za
                                ON (za.apda_apd = zd.apd_id)
                            JOIN ap_document_attr za2
                                ON (za2.apda_apd = zd.apd_id)
                      WHERE     zd.apd_ap = a.ap_id
                            AND zd.apd_ndt = 802
                            AND za.apda_nda = 3687
                            AND za2.apda_nda = 3689
                            AND zd.history_status = 'A'
                            AND za.history_status = 'A'
                            AND za2.history_status = 'A')
                       AS Com_Org_Name,
                   --Заявник
                   NVL (Uss_Person.Api$sc_Tools.Get_Pib_Scc (z.App_Scc),
                        uss_visit.dnet$appeal.Get_Ap_Person_Pib (z.app_id))
                       AS App_Pib,
                   Get_Ap_Modify_Dt (a.Ap_Id)
                       AS Ap_Modify_Dt,
                   CASE
                       WHEN a.Com_Wu IS NOT NULL
                       THEN
                           Get_Wu_Pib (a.Com_Wu)
                       WHEN a.Ap_Cu IS NOT NULL
                       THEN
                           Ikis_Rbm.Tools.Getcupib (a.Ap_Cu)
                   END
                       AS Ap_Modify_Wu,
                   Stp.Dic_Name
                       AS Ap_Sub_Tp_Name,
                   (SELECT MAX (kaot_full_name)
                      FROM uss_ndi.v_ndi_katottg k
                     WHERE k.kaot_id IN
                               ( /*Api$appeal.Get_Ap_Attr_Str(a.ap_id,8251),*/
                                Api$appeal.Get_Ap_Attr_Id (a.ap_id, 8251)))
                       apda_val_str_katottg_name
              FROM Appeal  a
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON a.Ap_St = St.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Tp Tp ON a.Ap_Tp = Tp.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.Ap_Src = Src.Dic_Value
                   JOIN Opfu o ON a.Com_Org = o.Org_Id
                   LEFT JOIN
                   (SELECT z.app_id,
                           z.app_ap,
                           z.app_scc,
                           z.app_tp,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY z.app_ap
                                   ORDER BY
                                       CASE
                                           WHEN z.app_tp = 'Z' THEN 1
                                           WHEN z.app_tp = 'OR' THEN 2
                                           WHEN z.app_tp = 'AP' THEN 3
                                           WHEN z.app_tp = 'AF' THEN 3
                                           ELSE tp.DIC_SRTORDR
                                       END)    rn
                      FROM Ap_Person  z
                           JOIN uss_Ndi.v_Ddn_App_Tp tp
                               ON z.app_tp = tp.DIC_VALUE
                     WHERE     z.History_Status = 'A'
                           AND z.App_Tp IN ('Z',
                                            'OR',
                                            'AP',
                                            'AF')
                           AND z.History_Status = 'A') z
                       ON a.Ap_Id = z.App_Ap AND rn = 1
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Sub_Tp Stp
                       ON a.Ap_Sub_Tp = Stp.Dic_Value
             WHERE a.Ap_Id = p_Ap_Id;
    END;

    ---------------------------------------------------------------------
    --               ОТРИМАННЯ ПОСЛУГ
    ---------------------------------------------------------------------
    PROCEDURE Get_Services (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.Aps_Id,
                   s.Aps_Nst,
                   t.Nst_Name       AS Aps_Nst_Name,
                   t.Nst_Legal_Act,
                   s.Aps_St,
                   St.Dic_Sname     AS Aps_St_Name
              FROM Ap_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Aps_Nst = t.Nst_Id
                   JOIN Uss_Ndi.v_Ddn_Aps_St St ON s.Aps_St = St.Dic_Value
             WHERE s.Aps_Id = p_Ap_Id AND s.History_Status = 'A';
    END;



    ---------------------------------------------------------------------
    --               ОТРИМАННЯ УЧАСНИКІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Persons (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Ap_Persons   USS_VISIT.DNET$APPEAL.t_Ap_Persons;
    BEGIN
        l_Ap_Persons := USS_VISIT.DNET$APPEAL.Get_Ap_Persons (p_Ap_Id);

        OPEN p_Res FOR
            SELECT p.App_Id,
                   p.App_Tp,
                   t.Dic_Name                            AS App_Tp_Name,
                   NVL (Uss_Person.Api$sc_Tools.Get_Numident (p.App_Sc),
                        App.App_Inn)                     AS App_Inn,
                   --p.App_Ndt, Dt.Ndt_Name AS App_Ndt_Name, p.App_Doc_Num,
                   --
                   NVL (i.Sci_Fn, App.App_Fn)            AS App_Fn,
                   NVL (i.Sci_Mn, App.App_Mn)            AS App_Mn,
                   NVL (i.Sci_Ln, App.App_Ln)            AS App_Ln,
                   --
                   s.Sc_Unique                           AS App_Esr_Num,
                   NVL (i.Sci_Gender, App.App_Gender)    AS App_Gender,
                   g.Dic_Name                            AS App_Gender_Name,
                   p.App_Sc,
                   --#APP_NUM
                   p.App_Num
              FROM Ap_Person  p
                   JOIN Uss_Ndi.v_Ddn_App_Tp t ON p.App_Tp = t.Dic_Value
                   LEFT JOIN Uss_Person.v_Socialcard s ON p.App_Sc = s.Sc_Id
                   LEFT JOIN Uss_Person.v_Sc_Change c ON p.App_Scc = c.Scc_Id
                   LEFT JOIN Uss_Person.v_Sc_Identity i
                       ON c.Scc_Sci = i.Sci_Id
                   LEFT JOIN TABLE (l_Ap_Persons) App
                       ON p.app_id = App.App_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Gender g
                       ON NVL (i.Sci_Gender, App.App_Gender) = g.Dic_Value
             WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A';
    END;


    ---------------------------------------------------------------------
    --               ОТРИМАННЯ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Documents (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.Apd_Id,
                   d.Apd_Ndt,
                   t.Ndt_Name_Short
                       AS Apd_Ndt_Name,
                   d.Apd_App,
                   --серія та номер документа
                   Api$appeal.Get_Attr_Val_String (d.Apd_Id, 'DSN')
                       AS Apd_Num,
                   d.Apd_Doc,
                   d.Apd_Dh,
                   d.Apd_Aps
                       AS Aps_Id
              FROM Ap_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Apd_Ndt = t.Ndt_Id
             WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';
    END;

    ---------------------------------------------------------------------
    --               ОТРИМАННЯ АТРИБУТІВ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Doc_Attributes (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT Ada.Apda_Id,
                     Ada.Apda_Ap,
                     Ada.Apda_Apd,
                     Ada.Apda_Nda,
                     Ada.Apda_Val_Int,
                     Ada.Apda_Val_Dt,
                     Ada.Apda_Val_String,
                     Ada.Apda_Val_Id,
                     Ada.Apda_Val_Sum,
                     Nda.Nda_Id,
                     Nda.Nda_Name,
                     Nda.Nda_Is_Key,
                     Nda.Nda_Ndt,
                     Nda.Nda_Order,
                     Nda.Nda_Pt,
                     Nda.Nda_Is_Req,
                     Nda.Nda_Def_Value,
                     Nda.Nda_Can_Edit,
                     Nda.Nda_Need_Show,
                     Pt.Pt_Id,
                     Pt.Pt_Code,
                     Pt.Pt_Name,
                     Pt.Pt_Ndc,
                     Pt.Pt_Edit_Type,
                     Pt.Pt_Data_Type
                FROM Ap_Document d
                     JOIN Ap_Document_Attr Ada
                         ON     Ada.Apda_Apd = d.Apd_Id
                            AND Ada.History_Status = 'A'
                     JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                         ON Nda.Nda_Id = Ada.Apda_Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
               WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A'
            ORDER BY Nda.Nda_Order;
    END;

    ---------------------------------------------------------------------
    --               ОТРИМАННЯ ВКЛАДЕНЬ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Doc_Files (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT Apd_Id,
                   Doc_Id,
                   Dh_Id,
                   File_Code,
                   File_Name,
                   File_Mime_Type,
                   File_Size,
                   File_Hash,
                   File_Create_Dt,
                   File_Description,
                   File_Sign_Code,
                   File_Sign_Hash,
                   (SELECT LISTAGG (Fs.File_Code, ',')
                               WITHIN GROUP (ORDER BY Ss.Dats_Id)
                      FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                           JOIN Uss_Doc.v_Files Fs
                               ON Ss.Dats_Sign_File = Fs.File_Id
                     WHERE Ss.Dats_Dat = d.Dat_Id)    AS File_Signs,
                   d.Dat_Num
              FROM (SELECT d.Apd_Id,
                           d.Apd_Doc               AS Doc_Id,
                           d.Apd_Dh                AS Dh_Id,
                           NVL (a.Dat_Num, -1)     Dat_Num,
                           a.Dat_Id,
                           f.File_Code,
                           f.File_Name,
                           f.File_Mime_Type,
                           f.File_Size,
                           f.File_Hash,
                           f.File_Create_Dt,
                           f.File_Description,
                           s.File_Code             AS File_Sign_Code,
                           s.File_Hash             AS File_Sign_Hash
                      --,nvl(max(a.dat_num) over (partition by a.Dat_Dh), -1) Max_Dat_Num
                      FROM Ap_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Apd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                           LEFT JOIN Uss_Doc.v_Files s
                               ON a.Dat_Sign_File = s.File_Id
                     WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A') d--WHERE Dat_Num = Max_Dat_Num
                                                                           ;
    END;

    ---------------------------------------------------------------------
    --    ОТРИМАННЯ ЖУРНАЛУ ОБРОБКИ ТА ВЕРИФІКАЦІЇ ЗВЕРНЕННЯ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Log (p_Ap_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_Ap_St   Appeal.Ap_St%TYPE;
        l_Ap_Vf   NUMBER;
    BEGIN
        SELECT Ap_St, Ap_Vf
          INTO l_Ap_St, l_Ap_Vf
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        OPEN p_Res FOR
            SELECT *
              FROM (  SELECT s.Hs_Dt               AS Log_Dt,
                             Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                 l.Apl_Message)    AS Log_Msg
                        FROM Ap_Log l JOIN Histsession s ON l.Apl_Hs = s.Hs_Id
                       WHERE     l.Apl_Id = p_Ap_Id
                             AND l_Ap_St IN ('W',
                                             'X',
                                             'D',
                                             'P')
                    ORDER BY s.Hs_Dt DESC, l.Apl_Id DESC
                       FETCH FIRST ROW ONLY)
            UNION ALL
            SELECT Vfl_Dt                                                        AS Log_Dt,
                      CASE
                          WHEN p.App_Id IS NOT NULL
                          THEN
                                 Uss_Person.Api$sc_Tools.Get_Pib_Scc (
                                     p.App_Scc)
                              || ': '
                      END
                   || Uss_Ndi.Rdm$msg_Template.Getmessagetext (l.Vfl_Message)    AS Log_Msg
              FROM Vf_Log  l
                   JOIN Verification v ON l.Vfl_Vf = v.Vf_Id
                   JOIN Verification Vv ON v.Vf_Vf_Main = Vv.Vf_Id
                   LEFT JOIN Ap_Person p
                       ON Vv.Vf_Obj_Tp = 'P' AND Vv.Vf_Obj_Id = p.App_Id
             WHERE     l_Ap_St = 'VE'
                   AND l.Vfl_Vf IN (    SELECT t.Vf_Id
                                          FROM Verification t
                                         WHERE t.Vf_Nvt <> 15
                                    START WITH t.Vf_Id = l_Ap_Vf
                                    CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                   AND l.Vfl_Tp IN ('W', 'E')
            ORDER BY 1;
    END;

    FUNCTION Check_Ap_Access (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        FOR Rec IN (SELECT a.At_Id
                      FROM Act a JOIN appeal t ON (t.ap_id = a.at_ap)
                     WHERE     a.At_Ap = p_Ap_Id
                           --todo: уточнити
                           AND (   t.ap_tp = 'R.OS' AND a.At_Tp = 'RSTOPSS'
                                OR t.ap_tp != 'R.OS' AND a.At_Tp = 'PDSP'
                                OR     t.ap_tp = 'SS'
                                   AND a.At_Tp IN ('APOP',
                                                   'OKS',
                                                   'PDSP',
                                                   'ANPOE')))
        LOOP
            IF Check_Act_Access (Rec.At_Id)
            THEN
                RETURN 'T';
            END IF;
        END LOOP;

        RETURN 'F';
    END;

    ---------------------------------------------------------------------
    --               ОТРИМАННЯ КАРТКИ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Get_Appeal_Card (p_Ap_Id            IN     VARCHAR2,
                               p_Main_Cur            OUT SYS_REFCURSOR,
                               p_Ser_Cur             OUT SYS_REFCURSOR,
                               p_Pers_Cur            OUT SYS_REFCURSOR,
                               p_Docs_Cur            OUT SYS_REFCURSOR,
                               p_Docs_Attr_Cur       OUT SYS_REFCURSOR,
                               p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                               p_Log_Cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Appeal_Card');

        Tools.LOG (
            p_src              => 'USS_ESR.CMES$APPEAL.Get_Appeal_Card',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => NULL,
            p_lob_param        =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        IF NOT Check_Ap_Access (p_Ap_Id) = 'T'
        THEN
            Tools.LOG (
                p_src              => 'USS_ESR.CMES$APPEAL.Get_Appeal_Card',
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_Ap_Id,
                p_regular_params   => 'Insufficient privileges.',
                p_lob_param        =>
                    tools.GetStartPackageName (
                        DBMS_UTILITY.FORMAT_CALL_STACK ()));
            Raise_Application_Error (-20000,
                                     'Недостатньо прав для перегляду');
        END IF;



        Get_Appeal (p_Ap_Id => p_Ap_Id, p_Res => p_Main_Cur);
        Get_Services (p_Ap_Id => p_Ap_Id, p_Res => p_Ser_Cur);
        Get_Persons (p_Ap_Id => p_Ap_Id, p_Res => p_Pers_Cur);
        Get_Documents (p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Cur);
        Get_Doc_Attributes (p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Attr_Cur);
        Get_Doc_Files (p_Ap_Id => p_Ap_Id, p_Res => p_Docs_Files_Cur);
        Get_Log (p_Ap_Id => p_Ap_Id, p_Res => p_Log_Cur);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');

        FOR Rec
            IN (SELECT At.At_Id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN Ap_Document d
                           ON a.Dat_Dh = d.Apd_Dh AND d.History_Status = 'A'
                       JOIN Act At
                           ON d.Apd_Ap = At.At_Ap AND At.At_Tp = 'PDSP'
                 WHERE f.File_Code = p_File_Code
                UNION
                SELECT at.at_id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN At_Document d
                           ON a.Dat_Dh = d.Atd_Dh AND d.History_Status = 'A'
                       JOIN Act At
                           ON d.atd_at = At.At_id AND At.At_Tp = 'PDSP'
                 WHERE f.File_Code = p_File_Code
                UNION
                SELECT At.At_Id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN Ap_Document d
                           ON a.Dat_Dh = d.Apd_Dh AND d.History_Status = 'A'
                       JOIN Act At
                           ON     d.Apd_Ap = At.At_Ap
                              AND At.At_Tp IN ('APOP', 'OKS')
                              AND at.at_main_link IS NULL
                 WHERE f.File_Code = p_File_Code
                UNION
                SELECT at.at_id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN At_Document d
                           ON a.Dat_Dh = d.Atd_Dh AND d.History_Status = 'A'
                       JOIN Act At
                           ON     d.atd_at = At.At_id
                              AND At.At_Tp IN ('APOP', 'OKS')
                              AND at.at_main_link IS NULL
                 WHERE f.File_Code = p_File_Code)
        LOOP
            IF Check_Act_Access (Rec.At_Id)
            THEN
                RETURN 'T';
            END IF;
        END LOOP;

        RETURN 'F';
    END;

    PROCEDURE Get_moz_dzp_by_ap (p_Ap_id          IN     NUMBER,
                                 p_Moz_Dzr_Data      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Moz_Dzr_Data FOR
            SELECT scmd_id,
                   scmd_scdi,
                   scmd_is_dzr_needed,
                   scmd_iso_code,
                   scmd_dzr_code,
                   scmd_dzr_name,
                   wrn_shifr,
                   at_num,
                   at_dt,
                   at_ap,
                   atw_st_name,
                   atw_reject_reason,
                   atw_issue_dt,
                   atw_end_exp_dt,
                   atw_ref_num,
                   atw_ref_dt,
                   atw_ref_exp_dt,
                   wrn_issue_max,
                   wrn_mult_qnt
              FROM (SELECT scdr_id          scmd_id,
                           NULL             scmd_scdi,
                           'T'              scmd_is_dzr_needed,
                           cb.wrn_shifr     scmd_iso_code,
                           cb.wrn_code      scmd_dzr_code,
                           cb.wrn_name      scmd_dzr_name,
                           cb.wrn_shifr,
                           ac.at_num,
                           ac.at_dt,
                           ac.at_ap,
                           d.DIC_NAME       atw_st_name,
                           atw.atw_reject_reason,
                           atw.atw_issue_dt,
                           atw.atw_end_exp_dt,
                           atw.atw_ref_num,
                           atw.atw_ref_dt,
                           atw.atw_ref_exp_dt,
                           cb.wrn_issue_max,
                           cb.wrn_mult_qnt
                      FROM uss_person.v_sc_dzr_recomm  a
                           JOIN uss_ndi.v_ndi_cbi_wares cb
                               ON a.scdr_wrn = cb.wrn_id
                           JOIN act ac
                               ON ac.at_sc = a.scdr_sc AND ac.at_tp = 'NDZR'
                           JOIN at_wares atw
                               ON     ac.at_id = atw.atw_at
                                  AND atw.history_status = 'A'
                                  AND atw_wrn = cb.wrn_id
                                  AND a.scdr_id = atw.atw_scdr
                           JOIN uss_ndi.V_DDN_ATW_ST d
                               ON atw.atw_st = d.DIC_VALUE
                     WHERE ac.at_ap = p_Ap_id);
    END;
END Cmes$appeal;
/