/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_VISIT
IS
    -- Author  : SHOSTAK
    -- Created : 20.05.2021 16:08:07
    -- Purpose :

    TYPE t_Ndi_Children_Service IS TABLE OF Ndi_Children_Service%ROWTYPE;

    --===============================================
    --                NDI_SERVICE_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Service_Type (
        p_Nst_Id               IN     Ndi_Service_Type.Nst_Id%TYPE,
        p_Nst_Code             IN     Ndi_Service_Type.Nst_Code%TYPE,
        p_Nst_Name             IN     Ndi_Service_Type.Nst_Name%TYPE,
        p_Nst_Ap_Tp            IN     Ndi_Service_Type.Nst_Ap_Tp%TYPE,
        p_Nst_Nbg              IN     Ndi_Service_Type.Nst_Nbg%TYPE,
        p_Nst_Legal_Act        IN     Ndi_Service_Type.Nst_Legal_Act%TYPE,
        p_Nst_Order            IN     Ndi_Service_Type.Nst_Order%TYPE,
        p_Nst_Nst_Main         IN     Ndi_Service_Type.Nst_Nst_Main%TYPE,
        p_Nst_Is_Can_Select    IN     Ndi_Service_Type.Nst_Is_Can_Select%TYPE,
        p_Nst_Is_Or_Generate   IN     v_Ndi_Service_Type.Nst_Is_Or_Generate%TYPE,
        p_New_Id                  OUT Ndi_Service_Type.Nst_Id%TYPE);

    PROCEDURE Delete_Ndi_Service_Type (
        p_Nst_Id   IN Ndi_Service_Type.Nst_Id%TYPE);

    PROCEDURE Query_Ndi_Service_Type (
        p_Nst_Code             IN     VARCHAR2,
        p_Nst_Name             IN     VARCHAR2,
        p_Nst_Ap_Tp            IN     VARCHAR2,
        p_Nst_Nbg              IN     NUMBER,
        p_Nst_Nst_Main         IN     NUMBER,
        p_Nst_Is_Can_Select    IN     VARCHAR2,
        p_Nst_Is_Or_Generate   IN     VARCHAR2,
        p_Res                     OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Service_Type (p_Nst_Id   IN     NUMBER,
                                    p_Res         OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_PAYMENT_CODES
    --===============================================

    PROCEDURE Save_Ndi_Payment_Codes (
        p_Npc_Id                IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Npc_Code              IN     Ndi_Payment_Codes.Npc_Code%TYPE,
        p_Npc_Name              IN     Ndi_Payment_Codes.Npc_Name%TYPE,
        p_Npc_Notes             IN     Ndi_Payment_Codes.Npc_Notes%TYPE,
        p_Npc_Order             IN     Ndi_Payment_Codes.Npc_Order%TYPE,
        p_Npc_Nkv               IN     Ndi_Payment_Codes.Npc_Nkv%TYPE,
        p_Npc_Org_Assembly_Tp   IN     Ndi_Payment_Codes.Npc_Org_Assembly_Tp%TYPE,
        p_New_Id                   OUT Ndi_Payment_Codes.Npc_Id%TYPE);

    PROCEDURE Delete_Ndi_Payment_Codes (
        p_Npc_Id   IN Ndi_Payment_Codes.Npc_Id%TYPE);

    PROCEDURE Query_Ndi_Payment_Codes (p_Npc_Code    IN     VARCHAR2,
                                       p_Npc_Name    IN     VARCHAR2,
                                       p_Npc_Notes   IN     VARCHAR2,
                                       p_Npc_Nkv     IN     NUMBER,
                                       p_Res            OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Payment_Codes (
        p_Id    IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res      OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_PAYMENT_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Payment_Type (
        p_Npt_Id                 IN     Ndi_Payment_Type.Npt_Id%TYPE,
        p_Npt_Code               IN     Ndi_Payment_Type.Npt_Code%TYPE,
        p_Npt_Name               IN     Ndi_Payment_Type.Npt_Name%TYPE,
        p_Npt_Legal_Act          IN     Ndi_Payment_Type.Npt_Legal_Act%TYPE,
        p_Npt_Nbg                IN     Ndi_Payment_Type.Npt_Nbg%TYPE,
        p_Npt_Npc                IN     Ndi_Payment_Type.Npt_Npc%TYPE,
        p_npt_include_pdfo_rpt   IN     Ndi_Payment_Type.npt_include_pdfo_rpt%TYPE,
        p_npt_include_esv_rpt    IN     Ndi_Payment_Type.npt_include_esv_rpt%TYPE,
        p_New_Id                    OUT Ndi_Payment_Type.Npt_Id%TYPE);

    PROCEDURE Delete_Ndi_Payment_Type (
        p_Npt_Id   IN Ndi_Payment_Type.Npt_Id%TYPE);

    PROCEDURE Query_Ndi_Payment_Type (p_Npt_Code        IN     VARCHAR2,
                                      p_Npt_Name        IN     VARCHAR2,
                                      p_Npt_Legal_Act   IN     VARCHAR2,
                                      p_Npt_Nbg         IN     NUMBER,
                                      p_Npt_Npc         IN     NUMBER,
                                      p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Payment_Type (
        p_Id    IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res      OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_BUDGET_PROGRAM
    --===============================================

    PROCEDURE Save_Ndi_Budget_Program (
        p_Nbg_Id         IN     Ndi_Budget_Program.Nbg_Id%TYPE,
        p_Nbg_Kpk_Code   IN     Ndi_Budget_Program.Nbg_Kpk_Code%TYPE,
        p_Nbg_Kfk_Code   IN     Ndi_Budget_Program.Nbg_Kfk_Code%TYPE,
        p_Nbg_Sname      IN     Ndi_Budget_Program.Nbg_Sname%TYPE,
        p_Nbg_Name       IN     Ndi_Budget_Program.Nbg_Name%TYPE,
        p_Nbg_Note       IN     Ndi_Budget_Program.Nbg_Note%TYPE,
        p_New_Id            OUT Ndi_Budget_Program.Nbg_Id%TYPE);

    PROCEDURE Delete_Ndi_Budget_Program (
        p_Nbg_Id   IN Ndi_Budget_Program.Nbg_Id%TYPE);

    PROCEDURE Query_Ndi_Budget_Program (
        p_Nbg_Kpk_Code   IN     VARCHAR2,
        p_Nbg_Kfk_Code   IN     VARCHAR2,
        p_Nbg_Sname      IN     VARCHAR2,
        p_Nbg_Name       IN     VARCHAR2,
        p_Nbg_Note       IN     VARCHAR2,
        p_Res               OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Budget_Program (
        p_Nbg_Id   IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res         OUT SYS_REFCURSOR);

    PROCEDURE Save_Adopt_Dict (p_Request IN CLOB);
END Dnet$dic_Visit;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO II01RC_USS_NDI_SVC
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_VISIT TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_VISIT
IS
    --===============================================
    --                NDI_SERVICE_TYPE
    --===============================================
    PROCEDURE Save_Ndi_Service_Type (
        p_Nst_Id               IN     Ndi_Service_Type.Nst_Id%TYPE,
        p_Nst_Code             IN     Ndi_Service_Type.Nst_Code%TYPE,
        p_Nst_Name             IN     Ndi_Service_Type.Nst_Name%TYPE,
        p_Nst_Ap_Tp            IN     Ndi_Service_Type.Nst_Ap_Tp%TYPE,
        p_Nst_Nbg              IN     Ndi_Service_Type.Nst_Nbg%TYPE,
        p_Nst_Legal_Act        IN     Ndi_Service_Type.Nst_Legal_Act%TYPE,
        p_Nst_Order            IN     Ndi_Service_Type.Nst_Order%TYPE,
        p_Nst_Nst_Main         IN     Ndi_Service_Type.Nst_Nst_Main%TYPE,
        p_Nst_Is_Can_Select    IN     Ndi_Service_Type.Nst_Is_Can_Select%TYPE,
        p_Nst_Is_Or_Generate   IN     v_Ndi_Service_Type.Nst_Is_Or_Generate%TYPE,
        p_New_Id                  OUT Ndi_Service_Type.Nst_Id%TYPE)
    IS
        l_Code_Exists   NUMBER;
    BEGIN
        Tools.Check_User_And_Raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_Code_Exists
          FROM Ndi_Service_Type t
         WHERE     Nst_Code = p_Nst_Code
               AND t.history_status = 'A'
               AND Nst_Id <> NVL (p_Nst_Id, -999);

        IF l_Code_Exists = 1
        THEN
            Raise_Application_Error (
                -20001,
                'Тип послуги з кодом ' || p_Nst_Code || ' вже існує');
        END IF;

        Api$dic_Visit.Save_Ndi_Service_Type (
            p_Nst_Id               => p_Nst_Id,
            p_Nst_Code             => p_Nst_Code,
            p_Nst_Name             => p_Nst_Name,
            p_History_Status       => Api$dic_Visit.c_History_Status_Actual,
            p_Nst_Ap_Tp            => p_Nst_Ap_Tp,
            p_Nst_Nbg              => p_Nst_Nbg,
            p_Nst_Legal_Act        => p_Nst_Legal_Act,
            p_Nst_Order            => p_Nst_Order,
            p_Nst_Nst_Main         => p_Nst_Nst_Main,
            p_Nst_Is_Can_Select    => p_Nst_Is_Can_Select,
            p_Nst_Is_Or_Generate   => p_Nst_Is_Or_Generate,
            p_New_Id               => p_New_Id);
    END;

    PROCEDURE Delete_Ndi_Service_Type (
        p_Nst_Id   IN Ndi_Service_Type.Nst_Id%TYPE)
    IS
    BEGIN
        Tools.Check_User_And_Raise (7);
        Api$dic_Visit.Set_Ndi_Service_Type_Hist_St (
            p_Nst_Id           => p_Nst_Id,
            p_History_Status   => Api$dic_Visit.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Service_Type (
        p_Nst_Code             IN     VARCHAR2,
        p_Nst_Name             IN     VARCHAR2,
        p_Nst_Ap_Tp            IN     VARCHAR2,
        p_Nst_Nbg              IN     NUMBER,
        p_Nst_Nst_Main         IN     NUMBER,
        p_Nst_Is_Can_Select    IN     VARCHAR2,
        p_Nst_Is_Or_Generate   IN     VARCHAR2,
        p_Res                     OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT t.*,
                   s.Dic_Name                              AS History_Status_Name,
                   At.Dic_Name                             AS Nst_Ap_Tp_Name,
                   Nbp.Nbg_Kpk_Code                        AS Nst_Nbg_Name, -- #77903 nbp.Nbg_Sname,
                   Vt.Nst_Name                             AS Nst_Nst_Main_Name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = t.record_src)     AS record_src_name,
                   tools.can_edit_record (t.record_src)    AS can_Edit_Record
              FROM Ndi_Service_Type  t
                   LEFT JOIN v_Ndi_Budget_Program Nbp
                       ON t.Nst_Nbg = Nbp.Nbg_Id
                   LEFT JOIN v_Ndi_Service_Type Vt
                       ON Vt.Nst_Id =
                          (SELECT Vt2.Nst_Id
                             FROM v_Ndi_Service_Type Vt2
                            WHERE     Vt2.Nst_Id = t.Nst_Nst_Main
                                  AND Vt2.History_Status =
                                      Api$dic_Visit.c_History_Status_Actual)
                   JOIN v_Ddn_Hist_Status s ON t.History_Status = s.Dic_Value
                   JOIN v_Ddn_Ap_Tp At ON t.Nst_Ap_Tp = At.Dic_Value
             WHERE     t.History_Status =
                       Api$dic_Visit.c_History_Status_Actual
                   AND (   p_Nst_Code IS NULL
                        OR t.Nst_Code LIKE '%' || p_Nst_Code || '%'
                        OR t.Nst_Code LIKE p_Nst_Code || '%')
                   AND (   p_Nst_Name IS NULL
                        OR UPPER (t.Nst_Name) LIKE
                               '%' || UPPER (p_Nst_Name) || '%')
                   AND t.Nst_Ap_Tp = NVL (p_Nst_Ap_Tp, t.Nst_Ap_Tp)
                   AND (   p_Nst_Is_Can_Select IS NULL
                        OR t.Nst_Is_Can_Select = p_Nst_Is_Can_Select)
                   AND (   p_Nst_Is_Or_Generate IS NULL
                        OR t.Nst_Is_Or_Generate = p_Nst_Is_Or_Generate)
                   AND (p_Nst_Nbg IS NULL OR t.Nst_Nbg = p_Nst_Nbg)
                   AND (   p_Nst_Nst_Main IS NULL
                        OR t.Nst_Nst_Main = p_Nst_Nst_Main);
    END;

    PROCEDURE Get_Ndi_Service_Type (p_Nst_Id   IN     NUMBER,
                                    p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT t.nst_id,
                   t.nst_code,
                   t.nst_name,
                   t.history_status,
                   t.nst_ap_tp,
                   t.nst_nbg,
                   t.nst_legal_act,
                   --t.nst_nst_main,
                   t.nst_order,
                   t.nst_is_can_select,
                   t.nst_is_or_generate,
                   t.nst_is_payed,
                   t.nst_can_urgent,
                   t.nst_is_inroom,
                   t.nst_is_innursing,
                   t.nst_accrual_period,
                   t.record_src,
                   t.nst_hs_ins,
                   t.nst_hs_del,
                   Vt.Nst_Id                               AS Nst_Nst_Main,
                   s.Dic_Name                              AS History_Status_Name,
                   At.Dic_Name                             AS Nst_Ap_Tp_Name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = t.record_src)     AS record_src_name,
                   tools.can_edit_record (t.record_src)    AS can_Edit_Record
              FROM Ndi_Service_Type  t
                   JOIN v_Ddn_Hist_Status s ON t.History_Status = s.Dic_Value
                   JOIN v_Ddn_Ap_Tp At ON t.Nst_Ap_Tp = At.Dic_Value
                   LEFT JOIN v_Ndi_Service_Type Vt
                       ON Vt.Nst_Id =
                          (SELECT Vt2.Nst_Id
                             FROM v_Ndi_Service_Type Vt2
                            WHERE     Vt2.Nst_Id = t.Nst_Nst_Main
                                  AND Vt2.History_Status =
                                      Api$dic_Visit.c_History_Status_Actual)
                   LEFT JOIN v_Ndi_Budget_Program Nbp
                       ON t.Nst_Nbg = Nbp.Nbg_Id
             WHERE t.Nst_Id = p_Nst_Id;
    END;

    --===============================================
    --                NDI_PAYMENT_CODES
    --===============================================

    PROCEDURE Save_Ndi_Payment_Codes (
        p_Npc_Id                IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Npc_Code              IN     Ndi_Payment_Codes.Npc_Code%TYPE,
        p_Npc_Name              IN     Ndi_Payment_Codes.Npc_Name%TYPE,
        p_Npc_Notes             IN     Ndi_Payment_Codes.Npc_Notes%TYPE,
        p_Npc_Order             IN     Ndi_Payment_Codes.Npc_Order%TYPE,
        p_Npc_Nkv               IN     Ndi_Payment_Codes.Npc_Nkv%TYPE,
        p_Npc_Org_Assembly_Tp   IN     Ndi_Payment_Codes.Npc_Org_Assembly_Tp%TYPE,
        p_New_Id                   OUT Ndi_Payment_Codes.Npc_Id%TYPE)
    IS
        l_Code_Exists   NUMBER;
    BEGIN
        Tools.Check_User_And_Raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_Code_Exists
          FROM Ndi_Payment_Codes t
         WHERE     Npc_Code = p_Npc_Code
               AND t.history_status = 'A'
               AND Npc_Id <> NVL (p_Npc_Id, -999);

        IF l_Code_Exists = 1
        THEN
            Raise_Application_Error (
                -20001,
                'Тип послуги з кодом ' || p_Npc_Code || ' вже існує');
        END IF;

        Api$dic_Visit.Save_Ndi_Payment_Codes (
            p_Npc_Id                => p_Npc_Id,
            p_Npc_Code              => p_Npc_Code,
            p_Npc_Name              => p_Npc_Name,
            p_Npc_Notes             => p_Npc_Notes,
            p_Npc_Order             => p_Npc_Order,
            p_History_Status        => Api$dic_Visit.c_History_Status_Actual,
            p_Npc_Nkv               => p_Npc_Nkv,
            p_Npc_Org_Assembly_Tp   => p_Npc_Org_Assembly_Tp,
            p_New_Id                => p_New_Id);
    END;

    PROCEDURE Delete_Ndi_Payment_Codes (
        p_Npc_Id   IN Ndi_Payment_Codes.Npc_Id%TYPE)
    IS
    BEGIN
        Tools.Check_User_And_Raise (7);
        Api$dic_Visit.Delete_Ndi_Payment_Codes (
            p_Npc_Id           => p_Npc_Id,
            p_History_Status   => Api$dic_Visit.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Payment_Codes (p_Npc_Code    IN     VARCHAR2,
                                       p_Npc_Name    IN     VARCHAR2,
                                       p_Npc_Notes   IN     VARCHAR2,
                                       p_Npc_Nkv     IN     NUMBER,
                                       p_Res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (7);

        OPEN p_Res FOR
              SELECT Npc.*,
                     Nk.Nkv_Code || ' ' || Nk.Nkv_Sname    AS Nkv_Sname,
                     tp.DIC_NAME                           AS npc_org_assembly_tp_name
                FROM Ndi_Payment_Codes Npc
                     LEFT JOIN v_Ndi_Kekv Nk ON Nk.Nkv_Id = Npc.Npc_Nkv
                     LEFT JOIN V_DDN_NPC_ORG_ASSEMBLY_TP tp
                         ON (tp.DIC_VALUE = npc.npc_org_assembly_tp)
               WHERE     Npc.History_Status =
                         Api$dic_Visit.c_History_Status_Actual
                     AND (   p_Npc_Code IS NULL
                          OR Npc.Npc_Code LIKE '%' || p_Npc_Code || '%')
                     AND (p_Npc_Nkv IS NULL OR Npc.Npc_Nkv = p_Npc_Nkv)
                     AND (   p_Npc_Name IS NULL
                          OR UPPER (Npc.Npc_Name) LIKE
                                 '%' || UPPER (p_Npc_Name) || '%'
                          OR UPPER (Npc.Npc_Name) LIKE
                                 UPPER (p_Npc_Name) || '%')
                     AND (   p_Npc_Notes IS NULL
                          OR UPPER (Npc.Npc_Notes) LIKE
                                 '%' || UPPER (p_Npc_Notes) || '%'
                          OR UPPER (Npc.Npc_Notes) LIKE
                                 UPPER (p_Npc_Notes) || '%')
            ORDER BY TO_NUMBER (Npc.Npc_Code);
    END;

    PROCEDURE Get_Ndi_Payment_Codes (
        p_Id    IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (7);

        OPEN p_Res FOR
            SELECT Npc.*
              FROM Ndi_Payment_Codes Npc
             WHERE     Npc.Npc_Id = p_Id
                   AND Npc.History_Status =
                       Api$dic_Visit.c_History_Status_Actual;
    END;

    --===============================================
    --                NDI_PAYMENT_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Payment_Type (
        p_Npt_Id                 IN     Ndi_Payment_Type.Npt_Id%TYPE,
        p_Npt_Code               IN     Ndi_Payment_Type.Npt_Code%TYPE,
        p_Npt_Name               IN     Ndi_Payment_Type.Npt_Name%TYPE,
        p_Npt_Legal_Act          IN     Ndi_Payment_Type.Npt_Legal_Act%TYPE,
        p_Npt_Nbg                IN     Ndi_Payment_Type.Npt_Nbg%TYPE,
        p_Npt_Npc                IN     Ndi_Payment_Type.Npt_Npc%TYPE,
        p_npt_include_pdfo_rpt   IN     Ndi_Payment_Type.npt_include_pdfo_rpt%TYPE,
        p_npt_include_esv_rpt    IN     Ndi_Payment_Type.npt_include_esv_rpt%TYPE,
        p_New_Id                    OUT Ndi_Payment_Type.Npt_Id%TYPE)
    IS
        l_Code_Exists   NUMBER;
    BEGIN
        Tools.Check_User_And_Raise (5);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_Code_Exists
          FROM Ndi_Payment_Type t
         WHERE     Npt_Code = p_Npt_Code
               AND t.history_status = 'A'
               AND Npt_Id <> NVL (p_Npt_Id, -999);

        IF l_Code_Exists = 1
        THEN
            Raise_Application_Error (
                -20001,
                'Тип послуги з кодом ' || p_Npt_Code || ' вже існує');
        END IF;

        Api$dic_Visit.Save_Ndi_Payment_Type (
            p_Npt_Id                 => p_Npt_Id,
            p_Npt_Code               => p_Npt_Code,
            p_Npt_Name               => p_Npt_Name,
            p_Npt_Legal_Act          => p_Npt_Legal_Act,
            p_Npt_Nbg                => p_Npt_Nbg,
            p_Npt_Npc                => p_Npt_Npc,
            p_History_Status         => Api$dic_Visit.c_History_Status_Actual,
            p_npt_include_pdfo_rpt   => p_npt_include_pdfo_rpt,
            p_npt_include_esv_rpt    => p_npt_include_esv_rpt,
            p_New_Id                 => p_New_Id);
    END;

    PROCEDURE Delete_Ndi_Payment_Type (
        p_Npt_Id   IN Ndi_Payment_Type.Npt_Id%TYPE)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);
        Api$dic_Visit.Delete_Ndi_Payment_Type (
            p_Npt_Id           => p_Npt_Id,
            p_History_Status   => Api$dic_Visit.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Payment_Type (p_Npt_Code        IN     VARCHAR2,
                                      p_Npt_Name        IN     VARCHAR2,
                                      p_Npt_Legal_Act   IN     VARCHAR2,
                                      p_Npt_Nbg         IN     NUMBER,
                                      p_Npt_Npc         IN     NUMBER,
                                      p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT Npt.Npt_Id,
                   Npt.Npt_Code,
                   Npt.Npt_Name,
                   Npt.Npt_Legal_Act,
                   Npt.Npt_Nbg,
                   Npt.Npt_Npc,
                   npt.npt_include_pdfo_rpt,
                   npt.npt_include_esv_rpt,
                   Nbp.Nbg_Kpk_Code                        AS Nbg_Sname, -- #77903 nbp.NBG_SNAME,
                   Npc.Npc_Code || '-' || Npc.Npc_Name     AS Npc_Name -- #77903
              FROM Ndi_Payment_Type  Npt
                   LEFT JOIN v_Ndi_Budget_Program Nbp
                       ON Npt.Npt_Nbg = Nbp.Nbg_Id
                   LEFT JOIN v_Ndi_Payment_Codes Npc
                       ON Npt.Npt_Npc = Npc.Npc_Id
             WHERE     Npt.History_Status =
                       Api$dic_Visit.c_History_Status_Actual
                   AND (   p_Npt_Code IS NULL
                        OR Npt.Npt_Code LIKE '%' || p_Npt_Code || '%')
                   AND (   p_Npt_Name IS NULL
                        OR UPPER (Npt.Npt_Name) LIKE
                               '%' || UPPER (p_Npt_Name) || '%'
                        OR UPPER (Npt.Npt_Name) LIKE
                               UPPER (p_Npt_Name) || '%')
                   AND (p_Npt_Nbg IS NULL OR Npt.Npt_Nbg = p_Npt_Nbg)
                   AND (p_Npt_Npc IS NULL OR Npt.Npt_Npc = p_Npt_Npc)
                   AND (   p_Npt_Legal_Act IS NULL
                        OR UPPER (Npt.Npt_Legal_Act) LIKE
                               '%' || UPPER (p_Npt_Legal_Act) || '%'
                        OR UPPER (Npt.Npt_Legal_Act) LIKE
                               UPPER (p_Npt_Legal_Act) || '%');
    END;

    PROCEDURE Get_Ndi_Payment_Type (
        p_Id    IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT Npt.*
              FROM Ndi_Payment_Type Npt
             WHERE     Npt.Npt_Id = p_Id
                   AND Npt.History_Status =
                       Api$dic_Visit.c_History_Status_Actual;
    END;

    --===============================================
    --                NDI_BUDGET_PROGRAM
    --===============================================

    PROCEDURE Save_Ndi_Budget_Program (
        p_Nbg_Id         IN     Ndi_Budget_Program.Nbg_Id%TYPE,
        p_Nbg_Kpk_Code   IN     Ndi_Budget_Program.Nbg_Kpk_Code%TYPE,
        p_Nbg_Kfk_Code   IN     Ndi_Budget_Program.Nbg_Kfk_Code%TYPE,
        p_Nbg_Sname      IN     Ndi_Budget_Program.Nbg_Sname%TYPE,
        p_Nbg_Name       IN     Ndi_Budget_Program.Nbg_Name%TYPE,
        p_Nbg_Note       IN     Ndi_Budget_Program.Nbg_Note%TYPE,
        p_New_Id            OUT Ndi_Budget_Program.Nbg_Id%TYPE)
    IS
        l_Code_Exists   NUMBER;
    BEGIN
        Tools.Check_User_And_Raise (5);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_Code_Exists
          FROM Ndi_Budget_Program t
         WHERE     Nbg_Kpk_Code = p_Nbg_Kpk_Code
               AND t.history_status = 'A'
               AND Nbg_Id <> NVL (p_Nbg_Id, -999);

        IF l_Code_Exists = 1
        THEN
            Raise_Application_Error (
                -20001,
                'Тип послуги з кодом ' || p_Nbg_Kpk_Code || ' вже існує');
        END IF;

        Api$dic_Visit.Save_Ndi_Budget_Program (
            p_Nbg_Id           => p_Nbg_Id,
            p_Nbg_Kpk_Code     => p_Nbg_Kpk_Code,
            p_Nbg_Kfk_Code     => p_Nbg_Kfk_Code,
            p_Nbg_Sname        => p_Nbg_Sname,
            p_Nbg_Name         => p_Nbg_Name,
            p_Nbg_Note         => p_Nbg_Note,
            p_History_Status   => Api$dic_Visit.c_History_Status_Actual,
            p_New_Id           => p_New_Id);
    END;

    PROCEDURE Delete_Ndi_Budget_Program (
        p_Nbg_Id   IN Ndi_Budget_Program.Nbg_Id%TYPE)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);
        Api$dic_Visit.Delete_Ndi_Budget_Program (
            p_Nbg_Id           => p_Nbg_Id,
            p_History_Status   => Api$dic_Visit.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Budget_Program (
        p_Nbg_Kpk_Code   IN     VARCHAR2,
        p_Nbg_Kfk_Code   IN     VARCHAR2,
        p_Nbg_Sname      IN     VARCHAR2,
        p_Nbg_Name       IN     VARCHAR2,
        p_Nbg_Note       IN     VARCHAR2,
        p_Res               OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT Nbp.Nbg_Id,
                   Nbp.Nbg_Kpk_Code,
                   Nbp.Nbg_Kfk_Code,
                   Nbp.Nbg_Sname,
                   Nbp.Nbg_Name,
                   Nbp.Nbg_Note
              FROM Ndi_Budget_Program Nbp
             WHERE     Nbp.History_Status =
                       Api$dic_Visit.c_History_Status_Actual
                   AND (   p_Nbg_Kpk_Code IS NULL
                        OR Nbp.Nbg_Kpk_Code LIKE '%' || p_Nbg_Kpk_Code || '%')
                   AND (   p_Nbg_Kfk_Code IS NULL
                        OR Nbp.Nbg_Kfk_Code LIKE '%' || p_Nbg_Kfk_Code || '%')
                   AND (   p_Nbg_Sname IS NULL
                        OR Nbp.Nbg_Sname LIKE '%' || p_Nbg_Sname || '%'
                        OR Nbp.Nbg_Sname LIKE p_Nbg_Sname || '%')
                   AND (   p_Nbg_Name IS NULL
                        OR Nbp.Nbg_Name LIKE '%' || p_Nbg_Name || '%'
                        OR Nbp.Nbg_Name LIKE p_Nbg_Name || '%')
                   AND (   p_Nbg_Note IS NULL
                        OR Nbp.Nbg_Note LIKE '%' || p_Nbg_Note || '%'
                        OR Nbp.Nbg_Note LIKE p_Nbg_Note || '%');
    END;

    PROCEDURE Get_Ndi_Budget_Program (
        p_Nbg_Id   IN     Ndi_Payment_Codes.Npc_Id%TYPE,
        p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Check_User_And_Raise (5);

        OPEN p_Res FOR
            SELECT Nbp.Nbg_Id,
                   Nbp.Nbg_Kpk_Code,
                   Nbp.Nbg_Kfk_Code,
                   Nbp.Nbg_Sname,
                   Nbp.Nbg_Name,
                   Nbp.Nbg_Note
              FROM Ndi_Budget_Program Nbp
             WHERE     Nbp.Nbg_Id = p_Nbg_Id
                   AND Nbp.History_Status =
                       Api$dic_Visit.c_History_Status_Actual;
    END;

    --===============================================
    --          Довідники щодо усиновлення
    --===============================================
    PROCEDURE Save_Adopt_Dict (p_Request IN CLOB)
    IS
        l_Dict_Name   VARCHAR2 (100);
    BEGIN
              SELECT Dict_Name
                INTO l_Dict_Name
                FROM XMLTABLE ('/*/*'
                               PASSING Xmltype (p_Request)
                               COLUMNS Dict_Name    VARCHAR2 (100) PATH 'name()');

        IF LOWER (l_Dict_Name) = 'ssd'
        THEN
            MERGE INTO Ndi_Children_Service Dst
                 USING (SELECT *
                          FROM (             SELECT x.*,
                                                    ROW_NUMBER ()
                                                        OVER (
                                                            PARTITION BY x.ncs_id
                                                            ORDER BY
                                                                CASE
                                                                    WHEN x.History_Status =
                                                                         'A'
                                                                    THEN
                                                                        1
                                                                    ELSE
                                                                        2
                                                                END)    AS rn,
                                                    k.Kaot_Id           AS Ncs_Kaot
                                               FROM XMLTABLE (
                                                        '/*/*/*'
                                                        PASSING Xmltype (p_Request)
                                                        COLUMNS Ncs_Id              NUMBER PATH 'id',
                                                                Ncs_Ncs             NUMBER PATH 'parent_Id',
                                                                Katottg             VARCHAR2 (20) PATH 'KATOTTG',
                                                                Ncs_Code            VARCHAR2 (10) PATH 'code',
                                                                Ncs_Name            VARCHAR2 (250) PATH 'name',
                                                                Ncs_Address         VARCHAR2 (250) PATH 'address',
                                                                Ncs_Contacts        VARCHAR2 (250) PATH 'contacts',
                                                                History_Status      VARCHAR2 (10) PATH 'status',
                                                                Ncs_Adopt           VARCHAR2 (10) PATH 'adopt',
                                                                Ncs_Advice          VARCHAR2 (10) PATH 'advice',
                                                                Ncs_Ps_Dbst         VARCHAR2 (10) PATH 'ps_dbst',
                                                                Ncs_Guardianship    VARCHAR2 (10) PATH 'guardianship')
                                                    x
                                                    LEFT JOIN Uss_Ndi.Ndi_Katottg k
                                                        ON x.Katottg = k.Kaot_Code)
                         WHERE rn = 1) Src
                    ON (Dst.Ncs_Id = Src.Ncs_Id)
            WHEN NOT MATCHED
            THEN
                INSERT     (Ncs_Id,
                            Ncs_Ncs,
                            Ncs_Kaot,
                            Ncs_Code,
                            Ncs_Name,
                            Ncs_Address,
                            Ncs_Contacts,
                            Ncs_Region_Code,
                            History_Status,
                            Ncs_Adopt,
                            Ncs_Advice,
                            Ncs_Ps_Dbst,
                            Ncs_Guardianship)
                    VALUES (Src.Ncs_Id,
                            Src.Ncs_Ncs,
                            Src.Ncs_Kaot,
                            Src.Ncs_Code,
                            Src.Ncs_Name,
                            Src.Ncs_Address,
                            Src.Ncs_Contacts,
                            Src.Ncs_Code,
                            Src.History_Status,
                            Src.Ncs_Adopt,
                            Src.Ncs_Advice,
                            Src.Ncs_Ps_Dbst,
                            Src.Ncs_Guardianship)
            WHEN MATCHED
            THEN
                UPDATE SET Dst.Ncs_Ncs = Src.Ncs_Ncs,
                           Dst.Ncs_Kaot = Src.Ncs_Kaot,
                           Dst.Ncs_Name = Src.Ncs_Name,
                           Dst.Ncs_Address = Src.Ncs_Address,
                           Dst.Ncs_Contacts = Src.Ncs_Contacts,
                           Dst.History_Status = Src.History_Status,
                           Dst.Ncs_Adopt = Src.Ncs_Adopt,
                           Dst.Ncs_Advice = Src.Ncs_Advice,
                           Dst.Ncs_Ps_Dbst = Src.Ncs_Ps_Dbst,
                           Dst.Ncs_Guardianship = Src.Ncs_Guardianship;
        ELSE
            Raise_Application_Error (
                -20000,
                'Невідомий тип довідника ' || l_Dict_Name);
        END IF;
    END;
END Dnet$dic_Visit;
/