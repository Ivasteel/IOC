/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$APPEAL_PORTAL
IS
-- Author  : SHOSTAK
-- Created : 03.07.2023 4:01:55 PM
-- Purpose :



END Dnet$appeal_Portal;
/


/* Formatted on 8/12/2025 5:49:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$APPEAL_PORTAL
IS
    ---------------------------------------------------------------------
    --             Отримання переліку потенційних отримувачів
    ---------------------------------------------------------------------
    PROCEDURE Get_Potential_Ss_Rec (p_Cmes_Owner_Id   IN     NUMBER,
                                    p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cu_Id           => Ikis_Rbm.Tools.Getcurrentcu,
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Raise_Application_Error (-20000, 'Недостаньо прав для переглягу');
        END IF;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   p.Ap_Num,
                   p.Ap_Reg_Dt,
                   a.At_Src,
                   s.Dic_Name                                         AS Ap_Src_Name,
                   a.At_St,
                   St.Dic_Name                                        AS Ap_St_Name,
                   Uss_Person.Api$sc_Tools.Get_Pib_Scc (r.App_Scc)    AS App_Pib
              FROM Act  a
                   JOIN Appeal p ON a.At_Ap = p.Ap_Id
                   JOIN Ap_Document d
                       ON     p.Ap_Id = d.Apd_Ap
                          AND d.Apd_Ndt IN (801,
                                            836,
                                            802,
                                            835)
                          AND d.History_Status = 'A'
                   JOIN Uss_Ndi.v_Ddn_Source s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON a.At_St = St.Dic_Value
                   JOIN Ap_Person r ON p.Ap_Id = r.App_Ap AND r.App_Tp = 'Z'
             WHERE     a.At_Tp = 'RSTOPSS'
                   AND a.At_St IN ('SP1',
                                   'SA',
                                   'SP2',
                                   'SI',
                                   'O.SA')
                   AND a.At_Rnspm = p_Cmes_Owner_Id;
    END;
END Dnet$appeal_Portal;
/