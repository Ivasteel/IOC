/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$ACT_APOP
IS
    -- Author  : SHOSTAK
    -- Created : 19.06.2023 8:06:55 PM
    -- Purpose :

    Pkg                         VARCHAR2 (50) := 'DNET$ACT_APOP';

    Ò_Apop_Form_Ndt   CONSTANT NUMBER := 804;

    PROCEDURE Get_Act_List (p_At_Dt_Start     IN     DATE,
                            p_At_Dt_Stop      IN     DATE,
                            p_At_Num          IN     VARCHAR2,
                            p_At_St           IN     VARCHAR2,
                            p_At_Case_Class   IN     VARCHAR2,
                            p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_File_Code OUT VARCHAR2);

    PROCEDURE Set_Signed (p_At_Id IN NUMBER);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_At_Notes IN VARCHAR2);
END Dnet$act_Apop;
/


GRANT EXECUTE ON USS_ESR.DNET$ACT_APOP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$ACT_APOP TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$ACT_APOP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
        l_Is_Allowed   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          --todo: ‰Ó‰‡ÚË RLS
          FROM v_Act a
         WHERE a.At_Id = p_At_Id;

        IF l_Is_Allowed <> 1
        THEN
            Raise_Application_Error (
                -20000,
                'ÕÂ‰ÓÒÚ‡ÚÌ¸Ó Ô‡‚ ‰Îˇ ‚ËÍÓÌ‡ÌÌˇ ÓÔÂ‡ˆ≥ø');
        END IF;
    END;

    -----------------------------------------------------------
    --             Œ“–»Ã¿ÕÕﬂ œ≈–≈À≤ ” ¿ “≤¬
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_At_Dt_Start     IN     DATE,
                            p_At_Dt_Stop      IN     DATE,
                            p_At_Num          IN     VARCHAR2,
                            p_At_St           IN     VARCHAR2,
                            p_At_Case_Class   IN     VARCHAR2,
                            p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_List');

        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                      r.Rnsps_Last_Name
                   || ' '
                   || r.Rnsps_First_Name
                   || ' '
                   || r.Rnsps_Middle_Name
                       AS At_Rnspm_Name
              FROM v_Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Apop_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
                   LEFT JOIN Uss_Rnsp.v_Rnsp r ON a.At_Rnspm = r.Rnspm_Id
             WHERE     a.At_Tp = 'APOP'
                   --ƒÓ‰‡ÚÍÓ‚≥ Ù≥Î¸ÚË
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND a.At_Num LIKE p_At_Num || '%'
                   AND a.At_St = NVL (p_At_St, a.At_St)
                   AND a.At_Case_Class =
                       NVL (p_At_Case_Class, a.At_Case_Class);
    END;

    -----------------------------------------------------------
    --            Œ“–»Ã¿ÕÕﬂ Œ—ÕŒ¬Õ»’ ƒ¿Õ»’ ¿ “”
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                      r.Rnsps_Last_Name
                   || ' '
                   || r.Rnsps_First_Name
                   || ' '
                   || r.Rnsps_Middle_Name
                       AS At_Rnspm_Name
              FROM v_Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Apop_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
                   LEFT JOIN Uss_Rnsp.v_Rnsp r ON a.At_Rnspm = r.Rnspm_Id
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     Œ“–»Ã¿ÕÕﬂ ƒ¿Õ»’ ¿ “” œ≈–¬»ÕÕŒØ Œ÷≤Õ » œŒ“–≈¡
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
    END;

    -----------------------------------------------------------
    --            Œ“–»Ã¿ÕÕﬂ ƒ–” Œ¬¿ÕŒØ ‘Œ–Ã» ¿ “”
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_File_Code OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');

        Check_Act_Access (p_At_Id);

        SELECT f.File_Code
          INTO p_File_Code
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = Ò_Apop_Form_Ndt
               AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    -- «¡≈–≈∆≈ÕÕﬂ ≤Õ‘Œ–Ã¿÷≤Ø ŸŒƒŒ œ≤ƒœ»—¿ÕÕﬂ ¿ “” œ≈–»¬ŒÕÕŒØ
    -- Œ÷≤Õ » œŒ“–≈¡ —œ≈÷≤¿À≤—“ŒÃ ”—«Õ
    -----------------------------------------------------------
    PROCEDURE Set_Signed (p_At_Id IN NUMBER)
    IS
        l_Wu_Id    NUMBER;
        l_Atd_Id   NUMBER;
    BEGIN
        Write_Audit ('Set_Signed');

        Check_Act_Access (p_At_Id);

        UPDATE Act a
           SET a.At_St = 'AP'
         WHERE a.At_Id = p_At_Id AND a.At_St = 'AS';

        IF SQL%ROWCOUNT = 0
        THEN
            Raise_Application_Error (
                -20000,
                'œ≥‰ÔËÒ‡ÌÌˇ ÒÔÂˆ≥‡Î≥ÒÚÓÏ ÏÓÊÎË‚Ó ÎË¯Â ‰Îˇ ‡ÍÚ≥‚ ‚ ÒÚ‡Ì≥ "œ≥‰ÔËÒ‡ÌÓ Ì‡‰‡‚‡˜ÂÏ"');
        END IF;

        l_Atd_Id := Api$act.Get_Atd_Id (p_At_Id, Ò_Apop_Form_Ndt);
        l_Wu_Id := Tools.Getcurrwu;

        MERGE INTO At_Signers Dst
             USING (SELECT s.Ati_Id
                      FROM At_Signers s
                     WHERE     s.Ati_At = p_At_Id
                           AND s.Ati_Tp = 'SP'
                           AND s.History_Status = 'A'
                           AND s.Ati_Is_Signed = 'F') Src
                ON (Src.Ati_Id = Dst.Ati_Id)
        WHEN NOT MATCHED
        THEN
            INSERT     (Ati_Id,
                        Ati_At,
                        Ati_Atd,
                        Ati_Sign_Dt,
                        Ati_Is_Signed,
                        History_Status,
                        Ati_Cu,
                        Ati_Tp)
                VALUES (0,
                        p_At_Id,
                        l_Atd_Id,
                        SYSDATE,
                        'T',
                        'A',
                        l_Wu_Id,
                        'CM')
        WHEN MATCHED
        THEN
            UPDATE SET Dst.Ati_Sign_Dt = SYSDATE,
                       Dst.Ati_Is_Signed = 'T',
                       Dst.Ati_Atd = l_Atd_Id,
                       Dst.Ati_Wu = l_Wu_Id
                 WHERE Dst.Ati_Id = Src.Ati_Id;

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsession (),
                              p_Atl_St        => 'AR',
                              p_Atl_Message   => CHR (38) || '232',
                              p_Atl_St_Old    => NULL);
    END;

    -----------------------------------------------------------
    -- œ≈–≈¬Œƒ ¿ “” œ≈–¬»ÕÕŒØ Œ÷≤Õ » œŒ“–≈¡ ¬ —“¿Õ
    -- "¬≤ƒ’»À≈ÕŒ"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_At_Notes IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Declined');

        IF p_At_Notes IS NULL
        THEN
            Raise_Application_Error (-20000, 'ÕÂ ‚Í‡Á‡ÌÓ ÔË˜ËÌÛ ‚≥‰ıËÎÂÌÌˇ');
        END IF;

        Check_Act_Access (p_At_Id);

        UPDATE Act a
           SET a.At_St = 'AR', a.At_Notes = p_At_Notes
         WHERE a.At_Id = p_At_Id AND a.At_St IN ('AS', 'AP');

        IF SQL%ROWCOUNT = 0
        THEN
            Raise_Application_Error (
                -20000,
                '¬≥‰ıËÎÂÌÌˇ ‡ÍÚÛ ‚ ÔÓÚÓ˜ÌÓÏÛ ÒÚ‡Ì≥ ÌÂÏÓÊÎË‚Ó');
        END IF;

        Api$act.Write_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Hs        => Tools.Gethistsession (),
            p_Atl_St        => 'AR',
            p_Atl_Message   => CHR (38) || '231#' || p_At_Notes,
            p_Atl_St_Old    => NULL);
    END;
END Dnet$act_Apop;
/