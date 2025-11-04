/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_VISIT
IS
    -- Author  : SHOSTAK
    -- Created : 20.05.2021 16:06:06
    -- Purpose :

    c_History_Status_Actual       VARCHAR2 (10) := 'A';
    c_History_Status_Historical   VARCHAR2 (10) := 'H';

    --===============================================
    --                NDI_SERVICE_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Service_Type (
        p_Nst_Id               IN     Ndi_Service_Type.Nst_Id%TYPE,
        p_Nst_Code             IN     Ndi_Service_Type.Nst_Code%TYPE,
        p_Nst_Name             IN     Ndi_Service_Type.Nst_Name%TYPE,
        p_History_Status       IN     Ndi_Service_Type.History_Status%TYPE,
        p_Nst_Ap_Tp            IN     Ndi_Service_Type.Nst_Ap_Tp%TYPE,
        p_NST_NBG              IN     Ndi_Service_Type.NST_NBG%TYPE,
        p_NST_LEGAL_ACT        IN     NDI_SERVICE_TYPE.NST_LEGAL_ACT%TYPE,
        p_NST_ORDER            IN     NDI_SERVICE_TYPE.NST_ORDER%TYPE,
        p_NST_NST_MAIN         IN     NDI_SERVICE_TYPE.NST_NST_MAIN%TYPE,
        p_NST_IS_CAN_SELECT    IN     NDI_SERVICE_TYPE.NST_IS_CAN_SELECT%TYPE,
        p_NST_IS_OR_GENERATE   IN     V_NDI_SERVICE_TYPE.NST_IS_OR_GENERATE%TYPE,
        p_New_Id                  OUT Ndi_Service_Type.Nst_Id%TYPE);

    PROCEDURE Set_Ndi_Service_Type_Hist_St (
        p_Nst_Id           IN Ndi_Service_Type.Nst_Id%TYPE,
        p_History_Status      Ndi_Service_Type.History_Status%TYPE);

    --===============================================
    --                NDI_PAYMENT_CODES
    --===============================================

    PROCEDURE Save_Ndi_Payment_Codes (
        p_NPC_ID                IN     NDI_PAYMENT_CODES.NPC_ID%TYPE,
        p_NPC_CODE              IN     NDI_PAYMENT_CODES.NPC_CODE%TYPE,
        p_NPC_NAME              IN     NDI_PAYMENT_CODES.NPC_NAME%TYPE,
        p_NPC_NOTES             IN     NDI_PAYMENT_CODES.NPC_NOTES%TYPE,
        p_NPC_ORDER             IN     NDI_PAYMENT_CODES.NPC_ORDER%TYPE,
        p_HISTORY_STATUS        IN     NDI_PAYMENT_CODES.HISTORY_STATUS%TYPE,
        p_NPC_NKV               IN     NDI_PAYMENT_CODES.NPC_NKV%TYPE,
        p_Npc_Org_Assembly_Tp   IN     Ndi_Payment_Codes.Npc_Org_Assembly_Tp%TYPE,
        p_new_id                   OUT NDI_PAYMENT_CODES.NPC_ID%TYPE);

    PROCEDURE Delete_Ndi_Payment_Codes (
        p_NPC_ID           IN NDI_PAYMENT_CODES.NPC_ID%TYPE,
        p_History_Status      NDI_PAYMENT_CODES.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_PAYMENT_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Payment_Type (
        p_NPT_ID                 IN     NDI_PAYMENT_TYPE.NPT_ID%TYPE,
        p_NPT_CODE               IN     NDI_PAYMENT_TYPE.NPT_CODE%TYPE,
        p_NPT_NAME               IN     NDI_PAYMENT_TYPE.NPT_NAME%TYPE,
        p_NPT_LEGAL_ACT          IN     NDI_PAYMENT_TYPE.NPT_LEGAL_ACT%TYPE,
        p_NPT_NBG                IN     NDI_PAYMENT_TYPE.NPT_NBG%TYPE,
        p_HISTORY_STATUS         IN     NDI_PAYMENT_TYPE.HISTORY_STATUS%TYPE,
        p_NPT_NPC                IN     NDI_PAYMENT_TYPE.NPT_NPC%TYPE,
        p_npt_include_pdfo_rpt   IN     Ndi_Payment_Type.npt_include_pdfo_rpt%TYPE,
        p_npt_include_esv_rpt    IN     Ndi_Payment_Type.npt_include_esv_rpt%TYPE,
        p_new_id                    OUT NDI_PAYMENT_TYPE.NPT_ID%TYPE);

    PROCEDURE Delete_Ndi_Payment_Type (
        p_NPT_ID           IN NDI_PAYMENT_TYPE.NPT_ID%TYPE,
        p_History_Status      NDI_PAYMENT_TYPE.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_BUDGET_PROGRAM
    --===============================================

    PROCEDURE Save_Ndi_Budget_Program (
        p_NBG_ID           IN     NDI_BUDGET_PROGRAM.NBG_ID%TYPE,
        p_NBG_KPK_CODE     IN     NDI_BUDGET_PROGRAM.NBG_KPK_CODE%TYPE,
        p_NBG_KFK_CODE     IN     NDI_BUDGET_PROGRAM.NBG_KFK_CODE%TYPE,
        p_NBG_SNAME        IN     NDI_BUDGET_PROGRAM.NBG_SNAME%TYPE,
        p_NBG_NAME         IN     NDI_BUDGET_PROGRAM.NBG_NAME%TYPE,
        p_NBG_NOTE         IN     NDI_BUDGET_PROGRAM.NBG_NOTE%TYPE,
        p_HISTORY_STATUS   IN     NDI_BUDGET_PROGRAM.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_BUDGET_PROGRAM.NBG_ID%TYPE);

    PROCEDURE Delete_Ndi_Budget_Program (
        p_NBG_ID           IN NDI_BUDGET_PROGRAM.NBG_ID%TYPE,
        p_History_Status      NDI_BUDGET_PROGRAM.HISTORY_STATUS%TYPE);

    --додати/проапдейтити рядок довідника ndi_pfu_payment_type
    PROCEDURE set_ndi_pfu_payment_type (
        p_nppt_id          IN OUT ndi_pfu_payment_type.nppt_id%TYPE,
        p_nppt_code        IN     ndi_pfu_payment_type.nppt_code%TYPE,
        p_nppt_name        IN     ndi_pfu_payment_type.nppt_name%TYPE,
        p_nppt_legal_act   IN     ndi_pfu_payment_type.nppt_legal_act%TYPE);
END Api$dic_Visit;
/


GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_VISIT TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_VISIT
IS
    --===============================================
    --                NDI_SERVICE_TYPE
    --===============================================
    PROCEDURE Save_Ndi_Service_Type (
        p_Nst_Id               IN     Ndi_Service_Type.Nst_Id%TYPE,
        p_Nst_Code             IN     Ndi_Service_Type.Nst_Code%TYPE,
        p_Nst_Name             IN     Ndi_Service_Type.Nst_Name%TYPE,
        p_History_Status       IN     Ndi_Service_Type.History_Status%TYPE,
        p_Nst_Ap_Tp            IN     Ndi_Service_Type.Nst_Ap_Tp%TYPE,
        p_NST_NBG              IN     Ndi_Service_Type.NST_NBG%TYPE,
        p_NST_LEGAL_ACT        IN     NDI_SERVICE_TYPE.NST_LEGAL_ACT%TYPE,
        p_NST_ORDER            IN     NDI_SERVICE_TYPE.NST_ORDER%TYPE,
        p_NST_NST_MAIN         IN     NDI_SERVICE_TYPE.NST_NST_MAIN%TYPE,
        p_NST_IS_CAN_SELECT    IN     NDI_SERVICE_TYPE.NST_IS_CAN_SELECT%TYPE,
        p_NST_IS_OR_GENERATE   IN     V_NDI_SERVICE_TYPE.NST_IS_OR_GENERATE%TYPE,
        p_New_Id                  OUT Ndi_Service_Type.Nst_Id%TYPE)
    IS
        l_rec_src   ndi_service_type.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_Nst_Id IS NULL
        THEN
            INSERT INTO Ndi_Service_Type (Nst_Code,
                                          Nst_Name,
                                          History_Status,
                                          Nst_Ap_Tp,
                                          Nst_Nbg,
                                          NST_LEGAL_ACT,
                                          NST_ORDER,
                                          NST_NST_MAIN,
                                          NST_IS_CAN_SELECT,
                                          NST_IS_OR_GENERATE,
                                          record_src,
                                          nst_hs_ins)
                 VALUES (p_Nst_Code,
                         p_Nst_Name,
                         p_History_Status,
                         p_Nst_Ap_Tp,
                         p_NST_NBG,
                         p_NST_LEGAL_ACT,
                         p_NST_ORDER,
                         p_NST_NST_MAIN,
                         p_NST_IS_CAN_SELECT,
                         p_NST_IS_OR_GENERATE,
                         TOOLS.get_record_src,
                         l_hs)
              RETURNING Nst_Id
                   INTO p_New_Id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_SERVICE_TYPE',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_New_Id := p_Nst_Id;

            SELECT t.record_src
              INTO l_rec_src
              FROM ndi_service_type t
             WHERE t.nst_id = p_Nst_Id;

            TOOLS.check_record_src (l_rec_src);

            UPDATE Ndi_Service_Type
               SET Nst_Code = p_Nst_Code,
                   Nst_Name = p_Nst_Name,
                   History_Status = p_History_Status,
                   Nst_Ap_Tp = p_Nst_Ap_Tp,
                   Nst_Nbg = p_NST_NBG,
                   NST_LEGAL_ACT = p_NST_LEGAL_ACT,
                   NST_ORDER = p_NST_ORDER,
                   NST_NST_MAIN = p_NST_NST_MAIN,
                   NST_IS_CAN_SELECT = p_NST_IS_CAN_SELECT,
                   NST_IS_OR_GENERATE = p_NST_IS_OR_GENERATE
             WHERE Nst_Id = p_Nst_Id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_SERVICE_TYPE',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE Set_Ndi_Service_Type_Hist_St (
        p_Nst_Id           IN Ndi_Service_Type.Nst_Id%TYPE,
        p_History_Status      Ndi_Service_Type.History_Status%TYPE)
    IS
        l_hs   NUMBER;
    BEGIN
        IF (p_History_Status = 'H')
        THEN
            l_hs := tools.GetHistSession;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object       => 'NDI_SERVICE_TYPE',
                p_ncl_action       => 'D',
                p_ncl_hs           => l_hs,
                p_ncl_record_id    => p_Nst_Id,
                p_ncl_decription   => '&322');
        END IF;

        UPDATE Ndi_Service_Type t
           SET History_Status = p_History_Status,
               t.nst_hs_del = NVL (l_hs, t.nst_hs_del)
         WHERE Nst_Id = p_Nst_Id;
    END;

    --===============================================
    --                NDI_PAYMENT_CODES
    --===============================================

    PROCEDURE Save_Ndi_Payment_Codes (
        p_NPC_ID                IN     NDI_PAYMENT_CODES.NPC_ID%TYPE,
        p_NPC_CODE              IN     NDI_PAYMENT_CODES.NPC_CODE%TYPE,
        p_NPC_NAME              IN     NDI_PAYMENT_CODES.NPC_NAME%TYPE,
        p_NPC_NOTES             IN     NDI_PAYMENT_CODES.NPC_NOTES%TYPE,
        p_NPC_ORDER             IN     NDI_PAYMENT_CODES.NPC_ORDER%TYPE,
        p_HISTORY_STATUS        IN     NDI_PAYMENT_CODES.HISTORY_STATUS%TYPE,
        p_NPC_NKV               IN     NDI_PAYMENT_CODES.NPC_NKV%TYPE,
        p_Npc_Org_Assembly_Tp   IN     Ndi_Payment_Codes.Npc_Org_Assembly_Tp%TYPE,
        p_new_id                   OUT NDI_PAYMENT_CODES.NPC_ID%TYPE)
    IS
    BEGIN
        IF p_NPC_ID IS NULL
        THEN
            INSERT INTO NDI_PAYMENT_CODES (NPC_CODE,
                                           NPC_NAME,
                                           NPC_NOTES,
                                           NPC_ORDER,
                                           HISTORY_STATUS,
                                           NPC_NKV,
                                           Npc_Org_Assembly_Tp)
                 VALUES (p_NPC_CODE,
                         p_NPC_NAME,
                         p_NPC_NOTES,
                         p_NPC_ORDER,
                         p_HISTORY_STATUS,
                         p_NPC_NKV,
                         p_Npc_Org_Assembly_Tp)
              RETURNING NPC_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NPC_ID;

            UPDATE NDI_PAYMENT_CODES
               SET NPC_CODE = p_NPC_CODE,
                   NPC_NAME = p_NPC_NAME,
                   NPC_NOTES = p_NPC_NOTES,
                   NPC_ORDER = p_NPC_ORDER,
                   HISTORY_STATUS = p_HISTORY_STATUS,
                   NPC_NKV = p_NPC_NKV,
                   Npc_Org_Assembly_Tp = p_Npc_Org_Assembly_Tp
             WHERE NPC_ID = p_NPC_ID;
        END IF;
    END;

    PROCEDURE Delete_Ndi_Payment_Codes (
        p_NPC_ID           IN NDI_PAYMENT_CODES.NPC_ID%TYPE,
        p_History_Status      NDI_PAYMENT_CODES.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_PAYMENT_CODES
           SET History_Status = p_History_Status
         WHERE NPC_ID = p_NPC_ID;
    END;

    --===============================================
    --                NDI_PAYMENT_TYPE
    --===============================================

    PROCEDURE Save_Ndi_Payment_Type (
        p_NPT_ID                 IN     NDI_PAYMENT_TYPE.NPT_ID%TYPE,
        p_NPT_CODE               IN     NDI_PAYMENT_TYPE.NPT_CODE%TYPE,
        p_NPT_NAME               IN     NDI_PAYMENT_TYPE.NPT_NAME%TYPE,
        p_NPT_LEGAL_ACT          IN     NDI_PAYMENT_TYPE.NPT_LEGAL_ACT%TYPE,
        p_NPT_NBG                IN     NDI_PAYMENT_TYPE.NPT_NBG%TYPE,
        p_HISTORY_STATUS         IN     NDI_PAYMENT_TYPE.HISTORY_STATUS%TYPE,
        p_NPT_NPC                IN     NDI_PAYMENT_TYPE.NPT_NPC%TYPE,
        p_npt_include_pdfo_rpt   IN     Ndi_Payment_Type.npt_include_pdfo_rpt%TYPE,
        p_npt_include_esv_rpt    IN     Ndi_Payment_Type.npt_include_esv_rpt%TYPE,
        p_new_id                    OUT NDI_PAYMENT_TYPE.NPT_ID%TYPE)
    IS
    BEGIN
        IF p_NPT_ID IS NULL
        THEN
            INSERT INTO NDI_PAYMENT_TYPE (NPT_CODE,
                                          NPT_NAME,
                                          NPT_LEGAL_ACT,
                                          NPT_NBG,
                                          NPT_NPC,
                                          npt_include_pdfo_rpt,
                                          npt_include_esv_rpt,
                                          HISTORY_STATUS)
                 VALUES (p_NPT_CODE,
                         p_NPT_NAME,
                         p_NPT_LEGAL_ACT,
                         p_NPT_NBG,
                         p_NPT_NPC,
                         p_npt_include_pdfo_rpt,
                         p_npt_include_esv_rpt,
                         p_HISTORY_STATUS)
              RETURNING NPT_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NPT_ID;

            UPDATE NDI_PAYMENT_TYPE
               SET NPT_CODE = p_NPT_CODE,
                   NPT_NAME = p_NPT_NAME,
                   NPT_LEGAL_ACT = p_NPT_LEGAL_ACT,
                   NPT_NBG = p_NPT_NBG,
                   NPT_NPC = p_NPT_NPC,
                   npt_include_pdfo_rpt = p_npt_include_pdfo_rpt,
                   npt_include_esv_rpt = p_npt_include_esv_rpt,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NPT_ID = p_NPT_ID;
        END IF;
    END;

    PROCEDURE Delete_Ndi_Payment_Type (
        p_NPT_ID           IN NDI_PAYMENT_TYPE.NPT_ID%TYPE,
        p_History_Status      NDI_PAYMENT_TYPE.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_PAYMENT_TYPE
           SET History_Status = p_History_Status
         WHERE NPT_ID = p_NPT_ID;
    END;

    --===============================================
    --                NDI_BUDGET_PROGRAM
    --===============================================

    PROCEDURE Save_Ndi_Budget_Program (
        p_NBG_ID           IN     NDI_BUDGET_PROGRAM.NBG_ID%TYPE,
        p_NBG_KPK_CODE     IN     NDI_BUDGET_PROGRAM.NBG_KPK_CODE%TYPE,
        p_NBG_KFK_CODE     IN     NDI_BUDGET_PROGRAM.NBG_KFK_CODE%TYPE,
        p_NBG_SNAME        IN     NDI_BUDGET_PROGRAM.NBG_SNAME%TYPE,
        p_NBG_NAME         IN     NDI_BUDGET_PROGRAM.NBG_NAME%TYPE,
        p_NBG_NOTE         IN     NDI_BUDGET_PROGRAM.NBG_NOTE%TYPE,
        p_HISTORY_STATUS   IN     NDI_BUDGET_PROGRAM.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_BUDGET_PROGRAM.NBG_ID%TYPE)
    IS
    BEGIN
        IF p_NBG_ID IS NULL
        THEN
            INSERT INTO NDI_BUDGET_PROGRAM (NBG_KPK_CODE,
                                            NBG_KFK_CODE,
                                            NBG_SNAME,
                                            NBG_NAME,
                                            NBG_NOTE,
                                            HISTORY_STATUS)
                 VALUES (p_NBG_KPK_CODE,
                         p_NBG_KFK_CODE,
                         p_NBG_SNAME,
                         p_NBG_NAME,
                         p_NBG_NOTE,
                         p_HISTORY_STATUS)
              RETURNING NBG_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBG_ID;

            UPDATE NDI_BUDGET_PROGRAM
               SET NBG_KPK_CODE = p_NBG_KPK_CODE,
                   NBG_KFK_CODE = p_NBG_KFK_CODE,
                   NBG_SNAME = p_NBG_SNAME,
                   NBG_NAME = p_NBG_NAME,
                   NBG_NOTE = p_NBG_NOTE,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NBG_ID = p_NBG_ID;
        END IF;
    END;

    PROCEDURE Delete_Ndi_Budget_Program (
        p_NBG_ID           IN NDI_BUDGET_PROGRAM.NBG_ID%TYPE,
        p_HISTORY_STATUS      NDI_BUDGET_PROGRAM.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_BUDGET_PROGRAM
           SET History_Status = p_HISTORY_STATUS
         WHERE NBG_ID = p_NBG_ID;
    END;

    --додати/проапдейтити рядок довідника ndi_pfu_payment_type
    PROCEDURE set_ndi_pfu_payment_type (
        p_nppt_id          IN OUT ndi_pfu_payment_type.nppt_id%TYPE,
        p_nppt_code        IN     ndi_pfu_payment_type.nppt_code%TYPE,
        p_nppt_name        IN     ndi_pfu_payment_type.nppt_name%TYPE,
        p_nppt_legal_act   IN     ndi_pfu_payment_type.nppt_legal_act%TYPE)
    IS
    BEGIN
        UPDATE ndi_pfu_payment_type t
           SET nppt_code = p_nppt_code,
               nppt_name = SUBSTR (p_nppt_name, 1, 1000),
               nppt_legal_act = SUBSTR (p_nppt_legal_act, 1, 4000)
         WHERE t.nppt_id = p_nppt_id;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO ndi_pfu_payment_type (nppt_id,
                                              nppt_code,
                                              nppt_name,
                                              nppt_legal_act)
                 VALUES (p_nppt_id,
                         p_nppt_code,
                         p_nppt_name,
                         p_nppt_legal_act)
              RETURNING nppt_id
                   INTO p_nppt_id;
        END IF;
    END;
END Api$dic_Visit;
/