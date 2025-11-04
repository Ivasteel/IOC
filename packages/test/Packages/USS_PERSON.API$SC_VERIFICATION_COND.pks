/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION_COND
IS
    -- Author  : KELATEV
    -- Created : 07.02.2025 17:29:03
    -- Purpose :

    c_Manual_Verification   VARCHAR2 (100) := 'Sc_Document_Verification';

    FUNCTION Is_Scpo_Exists (p_Scdi_Id IN NUMBER, p_Scpo_Ndt IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Scdi_Verified (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_All_Scpo_Verified (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Manual_Verification (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Verified (p_Scdi_Id IN NUMBER, p_Scv_Nvt IN NUMBER)
        RETURN BOOLEAN;
END Api$sc_Verification_Cond;
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION_COND
IS
    ----------------------------------------------------------------------------------
    FUNCTION Is_Scpo_Exists (p_Scdi_Id IN NUMBER, p_Scpo_Ndt IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Scpo_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Scpo_Exists
          FROM Sc_Pfu_Data_Ident p
         WHERE p.Scdi_Id = p_Scdi_Id AND p.Scdi_Doc_Tp = p_Scpo_Ndt;

        IF l_Scpo_Exists > 0
        THEN
            RETURN TRUE;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Scpo_Exists
          FROM Sc_Pfu_Document d
         WHERE d.Scpo_Scdi = p_Scdi_Id AND d.Scpo_Ndt = p_Scpo_Ndt;

        RETURN l_Scpo_Exists = 1;
    END;

    ----------------------------------------------------------------------------------
    --  Чи верифіковано дані особи успішні
    ----------------------------------------------------------------------------------
    FUNCTION Is_Scdi_Verified (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Last_Main_Scv      NUMBER;
        l_Not_Verified_Cnt   NUMBER;
    BEGIN
        SELECT MAX (Scv_Id)
          INTO l_Last_Main_Scv
          FROM Sc_Verification v
         WHERE     v.Scv_Obj_Tp = 'PI'
               AND v.Scv_Obj_Id = p_Scdi_Id
               AND v.Scv_Tp = 'MAIN_PFU';

        SELECT COUNT (*)
          INTO l_Not_Verified_Cnt
          FROM Sc_Verification v
         WHERE     v.Scv_St <> 'X'
               AND v.Scv_Obj_Tp = 'PI'
               AND v.Scv_Obj_Id = p_Scdi_Id
               AND v.Scv_Scv_Main = l_Last_Main_Scv;

        RETURN l_Not_Verified_Cnt = 0;
    END;

    ----------------------------------------------------------------------------------
    --  Чи всі верифікації документів учасника успішні
    ----------------------------------------------------------------------------------
    FUNCTION Is_All_Scpo_Verified (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Last_Main_Scv      NUMBER;
        l_Not_Verified_Cnt   NUMBER;
    BEGIN
        SELECT MAX (Scv_Id)
          INTO l_Last_Main_Scv
          FROM Sc_Verification v
         WHERE     v.Scv_Obj_Tp = 'PI'
               AND v.Scv_Obj_Id = p_Scdi_Id
               AND v.Scv_Tp = 'MAIN_PFU';

        SELECT COUNT (*)
          INTO l_Not_Verified_Cnt
          FROM Sc_Pfu_Document  d
               JOIN Sc_Verification v
                   ON     v.Scv_Obj_Tp = 'PD'
                      AND v.Scv_Obj_Id = d.Scpo_Id
                      AND v.Scv_Scv_Main = l_Last_Main_Scv
               JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Scpo_Ndt = t.Ndt_Id
         WHERE     d.Scpo_Scdi = p_Scdi_Id
               AND v.Scv_St <> 'X'
               AND (t.Ndt_Ndc = 13 OR d.Scpo_Ndt = 5);

        RETURN l_Not_Verified_Cnt = 0;
    END;

    ----------------------------------------------------------------------------------
    FUNCTION Is_Manual_Verification (p_Scdi_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Api$socialcard_Ext.Get_Scdi_Nrt_Code (p_Scdi_Id) IN
                   (c_Manual_Verification);
    END;

    ----------------------------------------------------------------------------------
    FUNCTION Is_Verified (p_Scdi_Id IN NUMBER, p_Scv_Nvt IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Last_Main_Scv   NUMBER;
        l_Verified_Cnt    NUMBER;
    BEGIN
        SELECT MAX (Scv_Id)
          INTO l_Last_Main_Scv
          FROM Sc_Verification v
         WHERE     v.Scv_Obj_Tp = 'PI'
               AND v.Scv_Obj_Id = p_Scdi_Id
               AND v.Scv_Tp = 'MAIN_PFU';

        SELECT COUNT (*)
          INTO l_Verified_Cnt
          FROM Sc_Verification v
         WHERE     v.Scv_St = 'X'
               AND v.Scv_Nvt = p_Scv_Nvt
               AND v.Scv_Scv_Main = l_Last_Main_Scv;

        RETURN l_Verified_Cnt > 0;
    END;
----------------------------------------------------------------------------------
END Api$sc_Verification_Cond;
/