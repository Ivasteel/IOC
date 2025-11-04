/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION
IS
    -- Author  : VANO
    -- Created : 09.06.2021 18:37:50
    -- Purpose : Функції роботи з верифікаціями

    g_Vf_Id                         NUMBER;

    ----------------------------------------------------
    --  СТАТУСИ ВЕРИФІКАЦІЙ
    ----------------------------------------------------
    c_Vf_St_Reg            CONSTANT VARCHAR2 (10) := 'R';      --Зареєстровано
    c_Vf_St_Error          CONSTANT VARCHAR2 (10) := 'E';   --Технічна помилка
    c_Vf_St_Ok             CONSTANT VARCHAR2 (10) := 'X'; --Успішна верифікація
    c_Vf_St_Not_Verified   CONSTANT VARCHAR2 (10) := 'N'; --Верифікацію не пройдено

    ----------------------------------------------------
    --  ТИПИ ПОВІДОМЛЕНЬ В ПРОТОКОЛІ ВЕРИФІКАЦІЇ
    ----------------------------------------------------
    c_Vfl_Tp_Info          CONSTANT VARCHAR2 (10) := 'I';
    c_Vfl_Tp_Error         CONSTANT VARCHAR2 (10) := 'E';
    c_Vfl_Tp_Terror        CONSTANT VARCHAR2 (10) := 'T';   --Технічна помилка
    c_Vfl_Tp_Warning       CONSTANT VARCHAR2 (10) := 'W';
    c_Vfl_Tp_Done          CONSTANT VARCHAR2 (10) := 'D';
    c_Vfl_Tp_Process       CONSTANT VARCHAR2 (10) := 'P'; -- Титичасвова помилка процессу веріфікації

    ----------------------------------------------------
    --  ТИПИ ВЕРИФІКАЦІЇ
    ----------------------------------------------------
    --c_Nvt_Docs_Validation   CONSTANT NUMBER := 6; --Валідація(контролі) документів звернення
    --c_Nvt_Appeal_Validation CONSTANT NUMBER := 12; --Валідація(контролі) всього зверення
    c_Nvt_Diia_Sharing     CONSTANT NUMBER := 13; --Шерінг документа через Дію
    c_Nvt_App2sc           CONSTANT NUMBER := 14; --Пошук/створення/оновлення соціальної картки учасника звернення
    c_Nvt_Rzo_Search       CONSTANT NUMBER := 15;          --Пошук особи в РЗО

    ----------------------------------------------------
    --  ТИПИ ДОКУМЕНТІВ
    ----------------------------------------------------
    c_Ndt_Inn                       NUMBER := 5;


    PROCEDURE Check_Vf_St (p_Vf_Id IN NUMBER);

    PROCEDURE Ap_Verification (p_Ap_Id       Appeal.Ap_Id%TYPE,
                               p_Ap_Vf       Appeal.Ap_Vf%TYPE,
                               p_Nvt_Id   IN NUMBER);

    PROCEDURE Set_Vf_Tech_Error (p_Vf_Id IN NUMBER, p_Error IN VARCHAR2);

    PROCEDURE Set_Tech_Error (p_Rn_Id IN NUMBER, p_Error IN VARCHAR2);

    PROCEDURE Set_Ok (p_Vf_Id IN NUMBER);

    PROCEDURE Set_Not_Verified (p_Vf_Id IN NUMBER, p_Error IN VARCHAR2);

    FUNCTION Get_Vf_Obj (p_Vf_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Vf_Obj_Tp (p_Vf_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Vf_St (p_Vf_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Vf_Ap (p_Vf_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Skip_Vf_By_Src (p_Apd_Id NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Vf_Log_Message_Exists (
        p_Vf_Id         Verification.Vf_Id%TYPE,
        p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
        p_Vfl_Message   Vf_Log.Vfl_Message%TYPE)
        RETURN NUMBER;

    FUNCTION Is_main_vf_exists (p_vf_id IN NUMBER)
        RETURN NUMBER;


    PROCEDURE Write_Vf_Log (p_Vf_Id         Verification.Vf_Id%TYPE,
                            p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
                            p_Vfl_Message   Vf_Log.Vfl_Message%TYPE);

    PROCEDURE Merge_Vf_Log (p_Vf_Id         Verification.Vf_Id%TYPE,
                            p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
                            p_Vfl_Message   Vf_Log.Vfl_Message%TYPE);

    FUNCTION Get_Verification (
        p_Vf_Tp        Verification.Vf_Tp%TYPE,
        p_Vf_Nvt       Verification.Vf_Nvt%TYPE,
        p_Vf_Obj_Tp    Verification.Vf_Obj_Tp%TYPE,
        p_Vf_Obj_Id    Verification.Vf_Obj_Id%TYPE,
        p_Vf_Vf_Main   Verification.Vf_Vf_Main%TYPE:= NULL)
        RETURN Verification.Vf_Id%TYPE;

    PROCEDURE Register_Vf_Request (
        p_Vf_Id       IN Verification.Vf_Id%TYPE,
        p_Vf_Obj_Id   IN Verification.Vf_Obj_Id%TYPE,
        p_Nvt_Id      IN Uss_Ndi.Ndi_Verification_Type.Nvt_Id%TYPE DEFAULT NULL,
        p_Nvt_Nrt     IN Uss_Ndi.Ndi_Verification_Type.Nvt_Nrt%TYPE DEFAULT NULL);

    PROCEDURE Save_Verification (
        p_Vf_Id                 IN     Verification.Vf_Id%TYPE,
        p_Vf_Vf_Main            IN     Verification.Vf_Vf_Main%TYPE,
        p_Vf_Tp                 IN     Verification.Vf_Tp%TYPE,
        p_Vf_St                 IN     Verification.Vf_St%TYPE,
        p_Vf_Own_St             IN     Verification.Vf_Own_St%TYPE,
        p_Vf_Start_Dt           IN     Verification.Vf_Start_Dt%TYPE,
        p_Vf_Stop_Dt            IN     Verification.Vf_Stop_Dt%TYPE,
        p_Vf_Expected_Stop_Dt   IN     Verification.Vf_Expected_Stop_Dt%TYPE,
        p_Vf_Nvt                IN     Verification.Vf_Nvt%TYPE,
        p_Vf_Obj_Tp             IN     Verification.Vf_Obj_Tp%TYPE,
        p_Vf_Obj_Id             IN     Verification.Vf_Obj_Id%TYPE,
        p_Vf_Hs_Rewrite         IN     Verification.Vf_Hs_Rewrite%TYPE,
        p_New_Id                   OUT Verification.Vf_Id%TYPE);

    PROCEDURE Link_Request2verification (p_Vfa_Vf   IN Vf_Answer.Vfa_Vf%TYPE,
                                         p_Vfa_Rn   IN Vf_Answer.Vfa_Rn%TYPE);

    PROCEDURE Try_Continue_App_Vf (p_App_Id NUMBER);

    PROCEDURE Collect_Ap_For_Verification;

    PROCEDURE Execute_Auto_Verifications;

    PROCEDURE Finish_Ap_Verifications;

    PROCEDURE Save_Verification_Answer (
        p_Vfa_Rn            IN     Vf_Answer.Vfa_Rn%TYPE,
        p_Vfa_Answer_Data   IN     Vf_Answer.Vfa_Answer_Data%TYPE,
        p_Vfa_Vf               OUT Vf_Answer.Vfa_Vf%TYPE);

    PROCEDURE Set_Verification_Status (p_Vf_Id   IN Verification.Vf_Id%TYPE,
                                       p_Vf_St   IN Verification.Vf_St%TYPE);

    PROCEDURE Set_Verification_Status (
        p_Vf_Id           IN Verification.Vf_Id%TYPE,
        p_Vf_St           IN Verification.Vf_St%TYPE,
        p_Vf_Own_St       IN Verification.Vf_Own_St%TYPE,
        p_Vf_Hs_Rewrite   IN Verification.Vf_Hs_Rewrite%TYPE DEFAULT NULL,
        p_Lock_Main_Vf    IN BOOLEAN DEFAULT TRUE);

    FUNCTION Calc_Parent_Vf_St (p_Parent_Vf_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Calc_Vf_St (p_Nvt_Skip_Cond   IN VARCHAR2,
                         p_Ap_Id           IN NUMBER,
                         p_Vf_St           IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Delay_Auto_Vf (p_Vf_Id           IN NUMBER,
                             p_Delay_Seconds   IN NUMBER,
                             p_Delay_Reason    IN VARCHAR2);

    PROCEDURE Suspend_Auto_Vf (p_Vf_Id IN NUMBER);

    PROCEDURE Resume_Auto_Vf (p_Vf_Id IN NUMBER);

    FUNCTION Get_Vf_Req_Cnt (p_Vf_Id IN NUMBER, p_Rn_Nrt IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Ur_Vf (p_Ur_Id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Restart_Ap_Vf (p_Ap_Id IN NUMBER);

    PROCEDURE Clear_Ap_Vf (p_Ap_Id IN NUMBER);
END Api$verification;
/


/* Formatted on 8/12/2025 5:59:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION
IS
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

    FUNCTION Get_Vf_Main (p_Vf_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_vf   NUMBER;
    BEGIN
        SELECT vf_vf_main
          INTO l_vf
          FROM verification
         WHERE vf_id = p_vf_id;

        IF l_vf IS NULL
        THEN
            RETURN p_Vf_Id;
        ELSE
            RETURN Get_Vf_Main (l_vf);
        END IF;
    END;

    PROCEDURE Check_Vf_St (p_Vf_Id IN NUMBER)
    IS
        l_R         NUMBER;
        l_X         NUMBER;
        l_vf_main   NUMBER;
    BEGIN
        l_vf_main := Get_Vf_Main (p_Vf_Id);

            SELECT COUNT (CASE WHEN vf_st = 'R' THEN 1 END),
                   COUNT (CASE WHEN vf_id = l_vf_main AND vf_st = 'X' THEN 1 END)
              INTO l_R, l_X
              FROM Verification v
        START WITH v.Vf_Id = l_vf_main
        CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main;

        IF l_R > 0 AND l_X > 0
        THEN
            raise_application_error (-20000,
                                     'Ошибка установки статуса верификации');
        END IF;
    END;

    PROCEDURE Set_Vf_Tech_Error (p_Vf_Id IN NUMBER, p_Error IN VARCHAR2)
    IS
    BEGIN
        Api$verification.Set_Verification_Status (
            p_Vf_Id       => p_Vf_Id,
            p_Vf_St       => Api$verification.c_Vf_St_Error,
            p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => p_Vf_Id,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
            p_Vfl_Message   => p_Error);

        IF Is_Vf_Log_Message_Exists (
               p_Vf_Id         => p_Vf_Id,
               p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
               p_Vfl_Message   => CHR (38) || '96') =
           0
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END IF;
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

        IF Is_Vf_Log_Message_Exists (
               p_Vf_Id         => l_Vf_Id,
               p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
               p_Vfl_Message   => CHR (38) || '96') =
           0
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '96');
        END IF;
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
            IF Is_Vf_Log_Message_Exists (
                   p_Vf_Id         => p_Vf_Id,
                   p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                   p_Vfl_Message   => CHR (38) || '96') =
               0
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                    p_Vfl_Message   => CHR (38) || '96');
            END IF;
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
        IF Is_Vf_Log_Message_Exists (
               p_Vf_Id         => p_Vf_Id,
               p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
               p_Vfl_Message   => CHR (38) || '97') =
           0
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => CHR (38) || '97');
        END IF;

        --Змінюємо статус верифікації
        Api$verification.Set_Verification_Status (
            p_Vf_Id       => p_Vf_Id,
            p_Vf_St       => Api$verification.c_Vf_St_Ok,
            p_Vf_Own_St   => Api$verification.c_Vf_St_Ok);
    END;

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

    FUNCTION Get_Vf_Obj_Tp (p_Vf_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Verification.Vf_Obj_Tp%TYPE;
    BEGIN
        SELECT v.Vf_Obj_Tp
          INTO l_Result
          FROM Verification v
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Vf_St (p_Vf_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Verification.Vf_St%TYPE;
    BEGIN
        SELECT v.Vf_St
          INTO l_Result
          FROM Verification v
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Vf_Ap (p_Vf_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        --#110450
        SELECT COALESCE (d.Apd_Ap, p.App_Ap, v.Vf_Obj_Id)
          INTO l_Ap_Id
          FROM Verification  v
               /*JOIN Ap_Document d
                 ON v.Vf_Obj_Id = d.Apd_Id*/
               LEFT JOIN Ap_Document d
                   ON v.Vf_Obj_Id = d.Apd_Id AND v.Vf_Obj_Tp = 'D'
               LEFT JOIN Ap_Person p
                   ON v.Vf_Obj_Id = p.app_id AND v.Vf_Obj_Tp = 'P'
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Ap_Id;
    END;

    -------------------------------------------------------------------------------
    -- Встановлення статусу "Успішна верифікація" у разі отримання документа
    -- з довіренного джерела
    -------------------------------------------------------------------------------
    FUNCTION Skip_Vf_By_Src (p_Apd_Id NUMBER)
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

    FUNCTION Is_Vf_Log_Message_Exists (
        p_Vf_Id         Verification.Vf_Id%TYPE,
        p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
        p_Vfl_Message   Vf_Log.Vfl_Message%TYPE)
        RETURN NUMBER
    IS
        l_Qty   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Qty
          FROM Vf_Log
         WHERE     Vfl_Vf = p_Vf_Id
               AND Vfl_Tp = p_Vfl_Tp
               AND Vfl_Message = p_Vfl_Message;

        RETURN l_Qty;
    END;

    FUNCTION Is_main_vf_exists (p_vf_id IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Res
          FROM (    SELECT vf_id          AS x_vf_id,
                           vf_vf_main     AS x_vf_vf_main,
                           vf_tp          AS x_vf_tp
                      FROM verification
                START WITH vf_id = p_vf_id
                CONNECT BY PRIOR vf_id = vf_vf_main)
         WHERE x_vf_vf_main IS NULL;

        RETURN l_Res;
    END;

    --Пишему протоколу верифікації
    PROCEDURE Write_Vf_Log (p_Vf_Id         Verification.Vf_Id%TYPE,
                            p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
                            p_Vfl_Message   Vf_Log.Vfl_Message%TYPE)
    IS
        l_Vfl_Id   Verification.Vf_Id%TYPE;
        l_Vfl_Tp   Vf_Log.Vfl_Tp%TYPE;
    BEGIN
        --тип повідомлення був в довіднику, бо десь в коді вже є неправильні записи
        BEGIN
            SELECT dic_value
              INTO l_Vfl_Tp
              FROM Uss_Ndi.v_Ddn_Vfl_Tp
             WHERE dic_value = p_Vfl_Tp;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                       'Код типу повідомлення ['
                    || p_Vfl_Tp
                    || '] не знайдено в довіднику Uss_Ndi.v_Ddn_Vfl_Tp');
        END;

        INSERT INTO Vf_Log (Vfl_Id,
                            Vfl_Vf,
                            Vfl_Dt,
                            Vfl_Tp,
                            Vfl_Message)
             VALUES (0,
                     p_Vf_Id,
                     SYSDATE,
                     p_Vfl_Tp,
                     p_Vfl_Message)
          RETURNING Vfl_Id
               INTO l_Vfl_Id;
    /*IF p_Vfl_Tp = c_Vfl_Tp_Terror THEN
      INSERT INTO Vf_Log
        (Vfl_Id,
         Vfl_Vf,
         Vfl_Dt,
         Vfl_Tp,
         Vfl_Message)
      VALUES
        (0,
         p_Vf_Id,
         SYSDATE,
         c_Vfl_Tp_Error,
         Chr(38) || '136#' || l_Vfl_Id);
    END IF;*/
    END;

    --Мержемо протоколу верифікації
    PROCEDURE Merge_Vf_Log (p_Vf_Id         Verification.Vf_Id%TYPE,
                            p_Vfl_Tp        Vf_Log.Vfl_Tp%TYPE,
                            p_Vfl_Message   Vf_Log.Vfl_Message%TYPE)
    IS
        l_Vfl_Tp   Vf_Log.Vfl_Tp%TYPE;
    BEGIN
        --тип повідомлення був в довіднику, бо десь в коді вже є неправильні записи
        BEGIN
            SELECT dic_value
              INTO l_Vfl_Tp
              FROM Uss_Ndi.v_Ddn_Vfl_Tp
             WHERE dic_value = p_Vfl_Tp;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                       'Код типу повідомлення ['
                    || p_Vfl_Tp
                    || '] не знайдено в довіднику Uss_Ndi.v_Ddn_Vfl_Tp');
        END;

        MERGE INTO Vf_Log d
             USING (SELECT p_Vf_Id           AS p_Vf_Id,
                           p_Vfl_Tp          AS p_Vfl_Tp,
                           p_Vfl_Message     AS p_Vfl_Message
                      FROM DUAL) n
                ON (    d.Vfl_Vf = n.p_Vf_Id
                    AND d.Vfl_Tp = n.p_Vfl_Tp
                    AND d.Vfl_Message = p_Vfl_Message)
        WHEN MATCHED
        THEN
            UPDATE SET Vfl_Dt = SYSDATE
        WHEN NOT MATCHED
        THEN
            INSERT     (Vfl_Id,
                        Vfl_Vf,
                        Vfl_Dt,
                        Vfl_Tp,
                        Vfl_Message)
                VALUES (0,
                        n.p_Vf_Id,
                        SYSDATE,
                        n.p_Vfl_Tp,
                        n.p_Vfl_Message);
    END;



    PROCEDURE Save_Verification (
        p_Vf_Id                 IN     Verification.Vf_Id%TYPE,
        p_Vf_Vf_Main            IN     Verification.Vf_Vf_Main%TYPE,
        p_Vf_Tp                 IN     Verification.Vf_Tp%TYPE,
        p_Vf_St                 IN     Verification.Vf_St%TYPE,
        p_Vf_Own_St             IN     Verification.Vf_Own_St%TYPE,
        p_Vf_Start_Dt           IN     Verification.Vf_Start_Dt%TYPE,
        p_Vf_Stop_Dt            IN     Verification.Vf_Stop_Dt%TYPE,
        p_Vf_Expected_Stop_Dt   IN     Verification.Vf_Expected_Stop_Dt%TYPE,
        p_Vf_Nvt                IN     Verification.Vf_Nvt%TYPE,
        p_Vf_Obj_Tp             IN     Verification.Vf_Obj_Tp%TYPE,
        p_Vf_Obj_Id             IN     Verification.Vf_Obj_Id%TYPE,
        p_Vf_Hs_Rewrite         IN     Verification.Vf_Hs_Rewrite%TYPE,
        p_New_Id                   OUT Verification.Vf_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Vf_Id, -1) < 0
        THEN
            INSERT INTO Verification (Vf_Id,
                                      Vf_Vf_Main,
                                      Vf_Tp,
                                      Vf_St,
                                      Vf_Own_St,
                                      Vf_Start_Dt,
                                      Vf_Stop_Dt,
                                      Vf_Expected_Stop_Dt,
                                      Vf_Nvt,
                                      Vf_Obj_Tp,
                                      Vf_Obj_Id,
                                      Vf_Hs_Rewrite,
                                      Vf_Plan_Dt)
                 VALUES (0,
                         p_Vf_Vf_Main,
                         p_Vf_Tp,
                         p_Vf_St,
                         p_Vf_Own_St,
                         p_Vf_Start_Dt,
                         p_Vf_Stop_Dt,
                         p_Vf_Expected_Stop_Dt,
                         p_Vf_Nvt,
                         p_Vf_Obj_Tp,
                         p_Vf_Obj_Id,
                         p_Vf_Hs_Rewrite,
                         SYSDATE)
              RETURNING Vf_Id
                   INTO p_New_Id;
        ELSE
            UPDATE Verification v
               SET v.Vf_St = p_Vf_St,
                   v.Vf_Own_St = p_Vf_Own_St,
                   v.Vf_Stop_Dt = p_Vf_Stop_Dt,
                   v.Vf_Hs_Rewrite = p_Vf_Hs_Rewrite
             WHERE v.Vf_Id = p_Vf_Id;
        END IF;
    END;

    --Отримуємо реєстраційний запис верифікації
    FUNCTION Get_Verification (
        p_Vf_Tp        Verification.Vf_Tp%TYPE,
        p_Vf_Nvt       Verification.Vf_Nvt%TYPE,
        p_Vf_Obj_Tp    Verification.Vf_Obj_Tp%TYPE,
        p_Vf_Obj_Id    Verification.Vf_Obj_Id%TYPE,
        p_Vf_Vf_Main   Verification.Vf_Vf_Main%TYPE:= NULL)
        RETURN Verification.Vf_Id%TYPE
    IS
    BEGIN
        Save_Verification (p_Vf_Id                 => NULL,
                           p_Vf_Vf_Main            => p_Vf_Vf_Main,
                           p_Vf_Tp                 => p_Vf_Tp,
                           p_Vf_St                 => 'R',
                           p_Vf_Own_St             => 'R',
                           p_Vf_Start_Dt           => SYSDATE,
                           p_Vf_Stop_Dt            => NULL,
                           p_Vf_Expected_Stop_Dt   => NULL,
                           p_Vf_Nvt                => p_Vf_Nvt,
                           p_Vf_Obj_Tp             => p_Vf_Obj_Tp,
                           p_Vf_Obj_Id             => p_Vf_Obj_Id,
                           p_Vf_Hs_Rewrite         => NULL,
                           p_New_Id                => g_Vf_Id);

        Write_Vf_Log (p_Vf_Id         => g_Vf_Id,
                      p_Vfl_Tp        => c_Vfl_Tp_Info,
                      p_Vfl_Message   => CHR (38) || '178');

        RETURN g_Vf_Id;
    END;

    -------------------------------------------------------------------------------
    --              Реєстрація запиту для верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Register_Vf_Request (
        p_Vf_Id       IN Verification.Vf_Id%TYPE,
        p_Vf_Obj_Id   IN Verification.Vf_Obj_Id%TYPE,
        p_Nvt_Id      IN Uss_Ndi.Ndi_Verification_Type.Nvt_Id%TYPE DEFAULT NULL,
        p_Nvt_Nrt     IN Uss_Ndi.Ndi_Verification_Type.Nvt_Nrt%TYPE DEFAULT NULL)
    IS
        l_Nvt_Nrt         Uss_Ndi.Ndi_Verification_Type.Nvt_Nrt%TYPE;
        l_Nrt_Make_Func   Uss_Ndi.v_Ndi_Request_Type.Nrt_Make_Func%TYPE;
        l_Nrt_Vf_Name     Uss_Ndi.v_Ndi_Request_Type.Nrt_Vf_Name%TYPE;
        l_Rn_Id           NUMBER;
        l_Error           VARCHAR2 (4000);
    BEGIN
        TOOLS.LOG (
            'API$VERIFICATION.REGISTER_VF_REQUEST',
            'PDVF',
            p_Vf_Id,
               'Start: p_Nvt_Id='
            || p_Nvt_Id
            || ', p_Nvt_Nrt='
            || p_Nvt_Nrt
            || ' ,p_Vf_Obj_Id='
            || p_Vf_Obj_Id);

        IF p_Nvt_Nrt IS NULL
        THEN
            SELECT t.Nvt_Nrt
              INTO l_Nvt_Nrt
              FROM Uss_Ndi.Ndi_Verification_Type t
             WHERE t.Nvt_Id = p_Nvt_Id;
        ELSE
            l_Nvt_Nrt := p_Nvt_Nrt;
        END IF;

        SELECT r.Nrt_Make_Func, r.Nrt_Vf_Name
          INTO l_Nrt_Make_Func, l_Nrt_Vf_Name
          FROM Uss_Ndi.v_Ndi_Request_Type r
         WHERE r.Nrt_Id = l_Nvt_Nrt;

        BEGIN
            EXECUTE IMMEDIATE   'begin :p_rn_id :='
                             || l_Nrt_Make_Func
                             || '(p_rn_nrt=>:p_rn_nrt, p_obj_id=>:p_obj_id, p_error=>:p_error); end;'
                USING OUT l_Rn_Id,
                      IN l_Nvt_Nrt,
                      IN p_Vf_Obj_Id,
                      OUT l_Error;
        EXCEPTION
            WHEN OTHERS
            THEN
                Write_Vf_Log (
                    p_Vf_Id    => p_Vf_Id,
                    p_Vfl_Tp   => c_Vfl_Tp_Terror,
                    p_Vfl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || l_Nvt_Nrt
                        || ', p_Vf_Obj_Id = '
                        || p_Vf_Obj_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
                Set_Verification_Status (
                    p_Vf_Id          => p_Vf_Id,
                    p_Vf_St          => c_Vf_St_Not_Verified,
                    p_Vf_Own_St      => c_Vf_St_Not_Verified,
                    p_Lock_Main_Vf   => FALSE);
                Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                              p_Vfl_Tp        => c_Vfl_Tp_Done,
                              p_Vfl_Message   => CHR (38) || '179');
        END;

        IF l_Error IS NOT NULL
        THEN
            Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                          p_Vfl_Tp        => c_Vfl_Tp_Error,
                          p_Vfl_Message   => l_Error);
            Set_Verification_Status (p_Vf_Id          => p_Vf_Id,
                                     p_Vf_St          => c_Vf_St_Not_Verified,
                                     p_Vf_Own_St      => c_Vf_St_Not_Verified,
                                     p_Lock_Main_Vf   => FALSE);
            Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                          p_Vfl_Tp        => c_Vfl_Tp_Done,
                          p_Vfl_Message   => CHR (38) || '179');
            RETURN;
        END IF;

        IF l_Rn_Id IS NOT NULL
        THEN
            Link_Request2verification (p_Vfa_Vf   => p_Vf_Id,
                                       p_Vfa_Rn   => l_Rn_Id);

            IF l_Nrt_Vf_Name IS NOT NULL
            THEN
                Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || '323#@6502@' || l_Nvt_Nrt);
            ELSE
                Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                              p_Vfl_Tp        => c_Vfl_Tp_Info,
                              p_Vfl_Message   => CHR (38) || '180');
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --              Створення звязку між верифікацією та запитом
    -------------------------------------------------------------------------------
    PROCEDURE Link_Request2verification (p_Vfa_Vf   IN Vf_Answer.Vfa_Vf%TYPE,
                                         p_Vfa_Rn   IN Vf_Answer.Vfa_Rn%TYPE)
    IS
    BEGIN
        INSERT INTO Vf_Answer (Vfa_Vf, Vfa_Rn)
             VALUES (p_Vfa_Vf, p_Vfa_Rn);
    END;

    -------------------------------------------------------------------------------
    --              Визначення умови необхідності запуску верифікації
    -------------------------------------------------------------------------------
    FUNCTION Need_Start_Vf (p_Nvt_Start_Cond   IN VARCHAR2,
                            p_Ap_Id            IN NUMBER,
                            p_App_Id           IN NUMBER DEFAULT NULL,
                            p_Apd_Id           IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Expression      VARCHAR2 (4000);
        l_Need_Start_Vf   BOOLEAN;
    BEGIN
        IF p_Nvt_Start_Cond IS NULL
        THEN
            RETURN TRUE;
        END IF;

        l_Expression :=
            REGEXP_REPLACE (p_Nvt_Start_Cond,
                            ':app',
                            p_App_Id,
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':apd',
                            p_Apd_Id,
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':ap',
                            p_Ap_Id,
                            1,
                            0,
                            'i');
        l_Expression := 'BEGIN :p_need_start := ' || l_Expression || '; END;';

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Need_Start_Vf;

        RETURN l_Need_Start_Vf;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20001,
                   'Помилка перевірки умови для запуску верифікації.'
                || CHR (10)
                || 'Умова: '
                || CHR (10)
                || l_Expression
                || CHR (10)
                || 'Помилка: '
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION Need_Start_Vf (p_Nvt_Id   IN NUMBER,
                            p_Ap_Id    IN NUMBER,
                            p_App_Id   IN NUMBER DEFAULT NULL,
                            p_Apd_Id   IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Nvt_Start_Cond   VARCHAR2 (4000);
    BEGIN
        SELECT t.Nvt_Start_Cond
          INTO l_Nvt_Start_Cond
          FROM Uss_Ndi.v_Ndi_Verification_Type t
         WHERE t.Nvt_Id = p_Nvt_Id;

        RETURN Need_Start_Vf (p_Nvt_Start_Cond   => l_Nvt_Start_Cond,
                              p_Ap_Id            => p_Ap_Id,
                              p_App_Id           => p_App_Id,
                              p_Apd_Id           => p_Apd_Id);
    END;

    -------------------------------------------------------------------------------
    -- Зворотній виклик, що виконується після завершення верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Vf_Callback (p_Nvt_Callback   IN VARCHAR2,
                           p_Vf_Obj_Tp      IN VARCHAR2,
                           p_Vf_Obj_Id      IN NUMBER,
                           p_Vf_St          IN VARCHAR2,
                           p_Vf_Id          IN NUMBER)
    IS
        l_Expression   VARCHAR2 (8000);
    BEGIN
        IF p_Nvt_Callback IS NULL
        THEN
            RETURN;
        END IF;

        l_Expression := p_Nvt_Callback;

        IF p_Vf_Obj_Tp = 'P'
        THEN
            l_Expression :=
                REGEXP_REPLACE (l_Expression,
                                ':App',
                                p_Vf_Obj_Id,
                                1,
                                0,
                                'i');
        END IF;

        IF p_Vf_Obj_Tp = 'D'
        THEN
            l_Expression :=
                REGEXP_REPLACE (l_Expression,
                                ':Apd',
                                p_Vf_Obj_Id,
                                1,
                                0,
                                'i');
        END IF;

        IF p_Vf_Obj_Tp = 'A'
        THEN
            l_Expression :=
                REGEXP_REPLACE (l_Expression,
                                ':Ap',
                                p_Vf_Obj_Id,
                                1,
                                0,
                                'i');
        END IF;

        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Vf_St',
                            q'[']' || p_Vf_St || q'[']',
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Vf_Id',
                            q'[']' || p_Vf_Id || q'[']',
                            1,
                            0,
                            'i');

        EXECUTE IMMEDIATE l_Expression;
    END;

    -------------------------------------------------------------------------------
    -- Зворотній виклик, що виконується після завершення верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Vf_Callback (p_Vf_Nvt      IN NUMBER,
                           p_Vf_Obj_Tp   IN VARCHAR2,
                           p_Vf_Obj_Id   IN NUMBER,
                           p_Vf_St       IN VARCHAR2,
                           p_Vf_Id       IN NUMBER)
    IS
        l_Nvt_Callback   Uss_Ndi.Ndi_Verification_Type.Nvt_Callback%TYPE;
    BEGIN
        SELECT t.Nvt_Callback
          INTO l_Nvt_Callback
          FROM Uss_Ndi.Ndi_Verification_Type t
         WHERE t.Nvt_Id = p_Vf_Nvt;

        Vf_Callback (p_Nvt_Callback   => l_Nvt_Callback,
                     p_Vf_Obj_Tp      => p_Vf_Obj_Tp,
                     p_Vf_Obj_Id      => p_Vf_Obj_Id,
                     p_Vf_St          => p_Vf_St,
                     p_Vf_Id          => p_Vf_Id);
    END;

    -------------------------------------------------------------------------------
    -- Верифікація документів учасника
    -------------------------------------------------------------------------------
    PROCEDURE Ap_Person_Doc_Verification (
        p_App_Id       IN     Ap_Person.App_Id%TYPE,
        p_Parent_Vf    IN     NUMBER,
        p_Parent_Nvt   IN     NUMBER,
        p_Level        IN     NUMBER := 1,
        p_New_Vf_Cnt   IN OUT NUMBER)
    IS
        l_Vf_Id            Verification.Vf_Id%TYPE;
        l_Parallel_Cnt     NUMBER := 0;
        l_Sequential_Cnt   NUMBER := 0;
        l_Skip_Vf          VARCHAR2 (10);
        l_Vf_St            VARCHAR2 (10);
    BEGIN
        --Виконуємо верифікацію документів учасника звернення
        TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                   'PDVF',
                   p_Parent_Vf,
                   'Start: App_Id=' || p_App_Id);

        FOR Rec
            IN (  SELECT *
                    FROM (--Верифікації по учаснику, що не повязані з документами
                          SELECT p.App_Ap     AS Ap_Id,
                                 App_Id       AS Obj_Id,
                                 'P'          AS Obj_Tp,
                                 NULL         AS Vf_Id,
                                 t.Nvt_Id,
                                 t.Nvt_Order,
                                 t.Nvt_Start_Cond,
                                 t.Nvt_Is_Parallel,
                                 t.Nvt_Vf_Tp,
                                 'F'          AS Is_Shared_Doc
                            FROM Uss_Ndi.v_Ndi_Verification_Type t
                                 JOIN Ap_Person p ON p.App_Id = p_App_Id
                           WHERE     t.Nvt_Nvt_Main = p_Parent_Nvt
                                 AND t.Nvt_Ndt IS NULL
                                 AND t.History_Status = 'A'
                                 AND NOT EXISTS
                                         (SELECT NULL
                                            FROM Verification v
                                           WHERE     v.Vf_Vf_Main = p_Parent_Vf
                                                 AND v.Vf_Obj_Id = p_App_Id
                                                 AND v.Vf_Obj_Tp = 'P'
                                                 AND v.Vf_Nvt = t.Nvt_Id)
                          UNION ALL
                          --Верифікації по учаснику, що повязані з документами
                          SELECT Apd_Ap                                      AS Ap_Id,
                                 Apd_Id                                      AS Obj_Id,
                                 'D'                                         AS Obj_Tp,
                                 Apd_Vf                                      AS Vf_Id,
                                 t.Nvt_Id,
                                 t.Nvt_Order,
                                 t.Nvt_Start_Cond,
                                 t.Nvt_Is_Parallel,
                                 t.Nvt_Vf_Tp,
                                 CASE WHEN Shr.Vf_Tp = 'SHR' THEN 'T' END    Is_Shared_Doc
                            FROM Ap_Document d
                                 JOIN Uss_Ndi.Ndi_Verification_Type t
                                     ON     d.Apd_Ndt = t.Nvt_Ndt
                                        AND t.Nvt_Nvt_Main = p_Parent_Nvt
                                        AND t.History_Status = 'A'
                                 LEFT JOIN Verification Shr
                                     ON d.Apd_Vf = Shr.Vf_Id
                           WHERE     Apd_App = p_App_Id
                                 AND d.History_Status = 'A'
                                 --Виключаємо вже створені верифікації на цьому рівні
                                 AND NOT EXISTS
                                         (SELECT NULL
                                            FROM Verification v
                                           WHERE     v.Vf_Vf_Main = p_Parent_Vf
                                                 AND v.Vf_Obj_Id = d.Apd_Id
                                                 AND v.Vf_Obj_Tp = 'D'
                                                 AND v.Vf_Nvt = t.Nvt_Id))
                ORDER BY Nvt_Order)
        LOOP
            TOOLS.LOG (
                'API$VERIFICATION.Ap_Person_Doc_Verification',
                'PDVF',
                p_Parent_Vf,
                   'Start iteration: Obj_Tp='
                || Rec.Obj_Tp
                || ', Obj_Id='
                || Rec.Obj_Id
                || ', Nvt_Id='
                || Rec.Nvt_Id
                || ', Is_Shared_Doc='
                || Rec.Is_Shared_Doc);

            --Якщо документ отримано через шерінг
            IF Rec.Is_Shared_Doc = 'T'
            THEN
                --Привязуюємо варифікацію документа до верифікації учасника
                UPDATE Verification v
                   SET v.Vf_Vf_Main = p_Parent_Vf
                 WHERE v.Vf_Id = Rec.Vf_Id;

                CONTINUE;
            END IF;

            IF NOT Need_Start_Vf (
                       p_Nvt_Start_Cond   => Rec.Nvt_Start_Cond,
                       p_Ap_Id            => Rec.Ap_Id,
                       p_App_Id           => p_App_Id,
                       p_Apd_Id           =>
                           CASE WHEN Rec.Obj_Tp = 'D' THEN Rec.Obj_Id END)
            THEN
                TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                           'PDVF',
                           p_Parent_Vf,
                           'Skip VF by condition');
                CONTINUE;
            END IF;

            IF Rec.Nvt_Is_Parallel = 'F'
            THEN
                --Рахуємо кількість послідовних верифікацій на цьому рівні
                l_Sequential_Cnt := l_Sequential_Cnt + 1;
            ELSE
                --Рахуємо кількість паралельних верифікацій на цьому рівні
                l_Parallel_Cnt := l_Parallel_Cnt + 1;
            END IF;

            IF    l_Sequential_Cnt > 1
               OR (l_Parallel_Cnt > 0 AND l_Sequential_Cnt = 1)
            THEN
                --Не виконуємо більше однієї послідовної верифікації
                --Не виконуємо послідовну верифікацію, перед якою є паралельні
                --Не виконуємо паралельну верфікцію, перед якою є послідовна
                --(повинні завершитись попередні верифікації)
                TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                           'PDVF',
                           p_Parent_Vf,
                           'Skip VF by parallel overhead');
                RETURN;
            END IF;

            l_Vf_Id :=
                Get_Verification (p_Vf_Tp        => Rec.Nvt_Vf_Tp,
                                  p_Vf_Nvt       => Rec.Nvt_Id,
                                  p_Vf_Obj_Tp    => Rec.Obj_Tp,
                                  p_Vf_Obj_Id    => Rec.Obj_Id,
                                  p_Vf_Vf_Main   => p_Parent_Vf);

            IF p_Level = 1 AND Rec.Obj_Tp = 'D'
            THEN
                --Записуємо посилання на верифікацію в документ
                UPDATE Ap_Document
                   SET Apd_Vf = l_Vf_Id
                 WHERE Apd_Id = Rec.Obj_Id;
            END IF;

            --Загулшка для встановлення статусу "Успішна верифікація" без відправки запити.
            --(для середовища розробки)
            SELECT NVL (MAX (v.Prm_Value), 'F')
              INTO l_Skip_Vf
              FROM Paramsvisit v
             WHERE v.Prm_Code = 'SKIP_VF_' || Rec.Nvt_Id;

            IF l_Skip_Vf = 'T'
            THEN
                TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                           'PDVF',
                           p_Parent_Vf,
                           'Skip OK by settings');
                Set_Ok (l_Vf_Id);
            END IF;

            --Якщо верифікація групуюча, то виконуємо верифікації рівнем нижче
            IF Rec.Nvt_Vf_Tp = 'MAIN'
            THEN
                TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                           'PDVF',
                           p_Parent_Vf,
                           'Start VF MAIN');
                Ap_Person_Doc_Verification (p_App_Id       => p_App_Id,
                                            p_Parent_Vf    => l_Vf_Id,
                                            p_Parent_Nvt   => Rec.Nvt_Id,
                                            p_Level        => p_Level + 1,
                                            p_New_Vf_Cnt   => p_New_Vf_Cnt);
            ELSIF Rec.Nvt_Vf_Tp = 'EZV'
            THEN
                IF l_Skip_Vf = 'F'
                THEN
                    --Реєструємо запит для перевірки документа
                    TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                               'PDVF',
                               p_Parent_Vf,
                               'Start VF EZV');
                    Register_Vf_Request (p_Vf_Id       => l_Vf_Id,
                                         p_Vf_Obj_Id   => Rec.Obj_Id,
                                         p_Nvt_Id      => Rec.Nvt_Id);
                ELSE
                    TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                               'PDVF',
                               p_Parent_Vf,
                               'Skip VF EZV');
                END IF;
            END IF;

            SELECT Vf_St
              INTO l_Vf_St
              FROM Verification
             WHERE Vf_Id = l_Vf_Id;

            IF l_Vf_St <> 'R'
            THEN
                --Зупиняємо цикл створення верифікацій, томущо він вже був виконаний в процедурі встановлення статусу
                TOOLS.LOG ('API$VERIFICATION.Ap_Person_Doc_Verification',
                           'PDVF',
                           p_Parent_Vf,
                           'Skip VF process');
                RETURN;
            END IF;

            p_New_Vf_Cnt := NVL (p_New_Vf_Cnt, 0) + 1;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Спроба продовження ланцюжка верифікацій по учаснику
    -- (може викликатись прикладними обробниками після завершення верифікацій,
    -- що могли створити умови для запуску верифікацій по учаснику.
    -- Приклад:
    -- -Для передачі заяви до СГ потрібно спочатку отримати атрибути свідоцтв про народження по всім учасникам(дітям, у яких є такий документ)
    -- -Тобто до моменту поки всі верифікації свідоцтв не завершаться запит до СГ відправляти не можна
    -- -Для верифікації, яка створює запит до СГ недостатньо просто прописати в налаштуваннях NVT_START_COND
    --  умову щодо завершенності верифікації свідоцт, томущо ця верифікації привязана до заявника і на момент звершення верифікації свідоцтв про народження,
    --  веріфікації по заявнику вже буде завершена.
    -- -Відповідно для цього і потрібна ця працедура, яка відкатить статус верифікації по учаснику(в даному прикладі по заявнику)
    --  і продовжить ланцюжок верифікацій(в даному прикладі створить запит до СГ), якщо будуть виконані відповідні умови
    -- )
    -------------------------------------------------------------------------------
    PROCEDURE Try_Continue_App_Vf (p_App_Id NUMBER)
    IS
        l_New_Vf_Cnt    NUMBER;
        l_Nvt_Id        NUMBER;
        l_App_Vf        NUMBER;
        l_Ap_Vf         NUMBER;
        l_Lock_Handle   Ikis_Sys.Ikis_Lock.t_Lockhandler;
    BEGIN
        SELECT v.Vf_Nvt, p.App_Vf, v.Vf_Vf_Main
          INTO l_Nvt_Id, l_App_Vf, l_Ap_Vf
          FROM Ap_Person p JOIN Verification v ON p.App_Vf = v.Vf_Id
         WHERE p.App_Id = p_App_Id;

        BEGIN
            Ikis_Sys.Ikis_Lock.Request_Lock (
                p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                p_Var_Name            => 'VF' || l_App_Vf,
                p_Errmessage          => NULL,
                p_Lockhandler         => l_Lock_Handle,
                p_Timeout             => 3600,
                p_Release_On_Commit   => TRUE);
        EXCEPTION
            WHEN OTHERS
            THEN
                --Виключення буде якщо в цій сесії вже виконано блокування
                NULL;
        END;

        --Запускаємо верифікацію по документам учасника
        Ap_Person_Doc_Verification (p_App_Id       => p_App_Id,
                                    p_Parent_Vf    => l_App_Vf,
                                    p_Parent_Nvt   => l_Nvt_Id,
                                    p_Level        => 1,
                                    p_New_Vf_Cnt   => l_New_Vf_Cnt);


        IF l_New_Vf_Cnt > 0
        THEN
            UPDATE Verification
               SET Vf_St = 'R', Vf_Own_St = 'R', Vf_Stop_Dt = NULL
             WHERE Vf_Id IN (l_Ap_Vf, l_App_Vf) AND Vf_St <> 'R';
        END IF;
    END;

    -------------------------------------------------------------------------------
    -- Ставимо учасників до верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Ap_Person_Verification (
        p_App_Id         Ap_Person.App_Id%TYPE,
        p_Parent_Vf      Verification.Vf_Id%TYPE,
        p_Nvt_Id      IN NUMBER)
    IS
        l_App_Main_Vf      Ap_Person.App_Vf%TYPE;
        l_New_Vf_Cnt       NUMBER;
        l_Vf_Child_Count   NUMBER;
        l_Vf_St            VARCHAR2 (10);
    BEGIN
        --Створюємо головну верифікацію учасника звернення
        l_App_Main_Vf :=
            Get_Verification (p_Vf_Tp        => 'MAIN',
                              p_Vf_Nvt       => p_Nvt_Id,
                              p_Vf_Obj_Tp    => 'P',
                              p_Vf_Obj_Id    => p_App_Id,
                              p_Vf_Vf_Main   => p_Parent_Vf);

        --Зберігаємо посилання на верифікацію
        UPDATE Ap_Person p
           SET p.App_Vf = l_App_Main_Vf
         WHERE p.App_Id = p_App_Id;

        --Запускаємо верифікацію по документам учасника
        Ap_Person_Doc_Verification (p_App_Id       => p_App_Id,
                                    p_Parent_Vf    => l_App_Main_Vf,
                                    p_Parent_Nvt   => p_Nvt_Id,
                                    p_Level        => 1,
                                    p_New_Vf_Cnt   => l_New_Vf_Cnt);

        SELECT COUNT (1)
          INTO l_Vf_Child_Count
          FROM Verification
         WHERE Vf_Vf_Main = l_App_Main_Vf AND Vf_St = 'R';

        IF l_Vf_Child_Count = 0
        THEN
            l_Vf_St := NVL (Calc_Parent_Vf_St (l_App_Main_Vf), c_Vf_St_Ok);
            Set_Verification_Status (p_Vf_Id          => l_App_Main_Vf,
                                     p_Vf_St          => l_Vf_St,
                                     p_Vf_Own_St      => l_Vf_St,
                                     p_Lock_Main_Vf   => FALSE);
        ELSE
            --Змінюємо статус верифікації звернення на "Зареєстровано"
            --на випадок, якщо попередні верифікації учасників були порожні(не мали підлеглих),
            UPDATE Verification
               SET Vf_St = 'R', Vf_Own_St = 'R', Vf_Stop_Dt = NULL
             WHERE Vf_Id = p_Parent_Vf AND Vf_St <> 'R';
        END IF;
    END;

    -------------------------------------------------------------------------------
    -- "Забираємо" звернення на верифікацію -
    -- зміна статусу та прописування "группуючої" верифікації в Звернення
    -------------------------------------------------------------------------------
    FUNCTION Lock_Ap_For_Verification (p_Ap_Id           Appeal.Ap_Id%TYPE,
                                       p_Nvt_Id   IN     NUMBER,
                                       p_Ap_Vf       OUT Appeal.Ap_Vf%TYPE)
        RETURN BOOLEAN
    IS
        l_Hs   Histsession.Hs_Id%TYPE;
    BEGIN
        p_Ap_Vf :=
            Get_Verification (p_Vf_Tp       => 'MAIN',
                              p_Vf_Nvt      => p_Nvt_Id,
                              p_Vf_Obj_Tp   => 'A',
                              p_Vf_Obj_Id   => p_Ap_Id);

        UPDATE Appeal
           SET Ap_St = 'VW', Ap_Vf = p_Ap_Vf
         WHERE Ap_Id = p_Ap_Id AND Ap_St = 'F';

        IF SQL%ROWCOUNT = 0
        THEN
            RETURN FALSE;
        END IF;

        l_Hs := Tools.Gethistsession ();
        --#73983 2021,12,09
        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => l_Hs,
                              p_Apl_St        => 'VW',
                              p_Apl_Message   => CHR (38) || '3',
                              p_Apl_St_Old    => 'F');

        RETURN TRUE;
    END;

    PROCEDURE Save_Validation_Result (p_Vf_Id IN NUMBER)
    IS
    BEGIN
        FOR i IN 1 .. Api$validation.g_Messages.COUNT
        LOOP
            Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$validation.g_Messages (i).Msg_Tp,
                p_Vfl_Message   => Api$validation.g_Messages (i).Msg_Text);
        END LOOP;

        IF Api$validation.Ap_Is_Valid
        THEN
            Set_Verification_Status (p_Vf_Id          => p_Vf_Id,
                                     p_Vf_St          => c_Vf_St_Ok,
                                     p_Vf_Own_St      => c_Vf_St_Ok,
                                     p_Lock_Main_Vf   => FALSE);
            Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                          p_Vfl_Tp        => c_Vfl_Tp_Done,
                          p_Vfl_Message   => CHR (38) || '97');
        ELSE
            Set_Verification_Status (p_Vf_Id          => p_Vf_Id,
                                     p_Vf_St          => c_Vf_St_Not_Verified,
                                     p_Vf_Own_St      => c_Vf_St_Not_Verified,
                                     p_Lock_Main_Vf   => FALSE);
            Write_Vf_Log (p_Vf_Id         => p_Vf_Id,
                          p_Vfl_Tp        => c_Vfl_Tp_Done,
                          p_Vfl_Message   => CHR (38) || '179');
        END IF;
    END;

    -------------------------------------------------------------------------------
    -- Ставимо складові звернення до верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Ap_Verification (p_Ap_Id       Appeal.Ap_Id%TYPE,
                               p_Ap_Vf       Appeal.Ap_Vf%TYPE,
                               p_Nvt_Id   IN NUMBER)
    IS
        l_Validation_List   VARCHAR2 (4000) := '';
    BEGIN
        --Виконуємо автоматичні перевірки звернення(валідації)
        FOR Rec
            IN (SELECT t.Nvt_Start_Cond, t.Nvt_Id, t.Nvt_Callback
                  FROM Uss_Ndi.v_Ndi_Verification_Type t
                 WHERE     t.Nvt_Nvt_Main = p_Nvt_Id
                       AND t.History_Status = 'A'
                       AND t.Nvt_Vf_Tp = 'AUTO')
        LOOP
            IF NOT Need_Start_Vf (p_Nvt_Start_Cond   => Rec.Nvt_Start_Cond,
                                  p_Ap_Id            => p_Ap_Id)
            THEN
                CONTINUE;
            END IF;

            l_Validation_List :=
                   l_Validation_List
                || ','
                || Get_Verification (p_Vf_Tp        => 'AUTO',
                                     p_Vf_Nvt       => Rec.Nvt_Id,
                                     p_Vf_Obj_Tp    => 'A',
                                     p_Vf_Obj_Id    => p_Ap_Id,
                                     p_Vf_Vf_Main   => p_Ap_Vf);
            Vf_Callback (p_Nvt_Callback   => Rec.Nvt_Callback,
                         p_Vf_Obj_Tp      => 'A',
                         p_Vf_Obj_Id      => p_Ap_Id,
                         p_Vf_St          => NULL,
                         p_Vf_Id          => p_Ap_Vf);
        END LOOP;

        --Виконуємо верифікацію даних про учасників--#73723 2021.12.03
        FOR Rec
            IN (  SELECT App_Id, t.Nvt_Start_Cond, t.Nvt_Id
                    FROM Ap_Person p
                         JOIN Uss_Ndi.v_Ndi_Verification_Type t
                             ON     t.Nvt_Nvt_Main = p_Nvt_Id
                                AND t.Nvt_Vf_Tp = 'MAIN'
                   WHERE App_Ap = p_Ap_Id AND p.History_Status = 'A'
                --Створюємо верифікацію заявника в останню чергу.
                --В деяких ситуаціях верифікації по заявнику повинні створюватись
                --після створення верифікацій по всім учасникам, для коректного визначення умов запуску
                ORDER BY CASE WHEN p.App_Tp = 'Z' THEN 2 ELSE 1 END)
        LOOP
            IF NOT Need_Start_Vf (p_Nvt_Start_Cond   => Rec.Nvt_Start_Cond,
                                  p_Ap_Id            => p_Ap_Id,
                                  p_App_Id           => Rec.App_Id)
            THEN
                CONTINUE;
            END IF;

            Ap_Person_Verification (Rec.App_Id,
                                    p_Parent_Vf   => p_Ap_Vf,
                                    p_Nvt_Id      => Rec.Nvt_Id);
        END LOOP;

        FOR Rec IN (SELECT TO_NUMBER (COLUMN_VALUE)     AS Vf_Id
                      FROM XMLTABLE (LTRIM (l_Validation_List, ','))
                     WHERE l_Validation_List <> ',')
        LOOP
            --Збереження статусу валідації звернення виконуються після створення всіх інших верифікацій,
            --щоб статус верифікації звернення не розрахувався передчасно
            Save_Validation_Result (Rec.Vf_Id);
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Очистка попередніх протоколів верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Clear_Ap_Vf (p_Ap_Id IN NUMBER)
    IS
    BEGIN
        UPDATE Ap_Document d
           SET d.Apd_Vf = NULL
         WHERE d.Apd_Ap = p_Ap_Id;

        UPDATE Ap_Person p
           SET p.App_Vf = NULL
         WHERE p.App_Ap = p_Ap_Id;

        UPDATE Appeal
           SET Ap_Vf = NULL
         WHERE Ap_Id = p_Ap_Id;
    END;

    PROCEDURE Restart_Ap_Vf (p_Ap_Id IN NUMBER)
    IS
    BEGIN
        Clear_Ap_Vf (p_Ap_Id);

        UPDATE Appeal
           SET Ap_St = 'F'
         WHERE Ap_Id = p_Ap_Id;
    END;

    -------------------------------------------------------------------------------
    -- Ставимо зверення в стані F (Зареєстровано) до автоматичної верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Collect_Ap_For_Verification
    IS
        l_Ap_Vf   Appeal.Ap_Vf%TYPE;
    BEGIN
        --#78995 2022.08.01
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        FOR Rec
            IN (  SELECT Ap_Id,
                         Ap_Vf,
                         t.Nvt_Id,
                         t.Nvt_Start_Cond,
                         t.Nvt_Callback
                    FROM Appeal
                         JOIN Uss_Ndi.v_Ndi_Verification_Type t
                             ON     t.Nvt_Nvt_Main IS NULL
                                AND t.Nvt_Vf_Tp = 'MAIN'
                                AND t.History_Status = 'A'
                   WHERE Ap_St IN ('F')
                ORDER BY Ap_Reg_Dt
                   FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                RETURN;
            END IF;

            IF NOT Need_Start_Vf (p_Nvt_Start_Cond   => Rec.Nvt_Start_Cond,
                                  p_Ap_Id            => Rec.Ap_Id)
            THEN
                Vf_Callback (p_Nvt_Callback   => Rec.Nvt_Callback,
                             p_Vf_Obj_Tp      => 'A',
                             p_Vf_Obj_Id      => Rec.Ap_Id,
                             p_Vf_St          => c_Vf_St_Ok,
                             p_Vf_Id          => NULL);

                UPDATE Appeal
                   SET Ap_St = 'VO'
                 WHERE Ap_Id = Rec.Ap_Id;

                COMMIT;
                CONTINUE;
            END IF;

            --IF Rec.Ap_Vf IS NOT NULL THEN
            --Виконуємо очистку попередніх протоколів верифікацій
            Clear_Ap_Vf (Rec.Ap_Id);

            --END IF;

            --Блокуємо звернення на період автоматичної верифікації
            IF Lock_Ap_For_Verification (Rec.Ap_Id,
                                         p_Nvt_Id   => Rec.Nvt_Id,
                                         p_Ap_Vf    => l_Ap_Vf)
            THEN
                --Виконуємо верифікацію звернення
                Ap_Verification (Rec.Ap_Id,
                                 p_Ap_Vf    => l_Ap_Vf,
                                 p_Nvt_Id   => Rec.Nvt_Id);
                COMMIT;
            ELSE
                ROLLBACK;
            END IF;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Виканання автоматичних верифікацій в БД
    -------------------------------------------------------------------------------
    PROCEDURE Execute_Auto_Verifications
    IS
    --l_Skip_Vf VARCHAR2(10);
    BEGIN
        FOR Rec
            IN (  SELECT v.Vf_Obj_Tp,
                         v.Vf_Obj_Id,
                         v.Vf_Id,
                         t.Nvt_Callback,
                         t.Nvt_Id
                    FROM Verification v
                         JOIN Uss_Ndi.Ndi_Verification_Type t
                             ON v.Vf_Nvt = t.Nvt_Id
                   WHERE     v.Vf_St = 'R'
                         AND v.Vf_Tp = 'AUTO'
                         AND v.Vf_Plan_Dt < SYSDATE
                ORDER BY v.Vf_Start_Dt
                   FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                RETURN;
            END IF;

            /*
            --Загулшка для встановлення статусу "Успішна верифікація" без відправки запити.
            --(для середовища розробки)
            SELECT Nvl(MAX(v.Prm_Value), 'F')
              INTO l_Skip_Vf
              FROM Paramsvisit v
             WHERE v.Prm_Code = 'SKIP_VF_' || Rec.Nvt_Id;

            IF l_Skip_Vf = 'T' THEN
              TOOLS.log('API$VERIFICATION.Ap_Person_Doc_Verification','PDVF',Rec.Vf_Id,'Skip OK by settings');
              Set_Ok(Rec.Vf_Id);
            END IF;
            */
            Vf_Callback (p_Nvt_Callback   => Rec.Nvt_Callback,
                         p_Vf_Obj_Tp      => Rec.Vf_Obj_Tp,
                         p_Vf_Obj_Id      => Rec.Vf_Obj_Id,
                         p_Vf_St          => NULL,
                         p_Vf_Id          => Rec.Vf_Id);

            COMMIT;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Розблокування звернення після верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Unlock_Ap (p_Ap_Id    Appeal.Ap_Id%TYPE,
                         p_Vf_Nvt   Verification.Vf_Nvt%TYPE,
                         p_Vf_St    Verification.Vf_St%TYPE)
    IS
        l_Hs      Histsession.Hs_Id%TYPE;
        l_Ap_Vf   Appeal.Ap_Vf%TYPE;
        l_Ap_St   Appeal.Ap_St%TYPE;
    BEGIN
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => 'USS_VISIT.API$VERIFICATION.UNLOCK_AP',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'Start Unlock_Ap');

           UPDATE Appeal
              SET Ap_St = CASE p_Vf_St WHEN c_Vf_St_Ok THEN 'VO' ELSE 'VE' END
            WHERE Ap_Id = p_Ap_Id AND Ap_St IN ('VW', 'VE')
        RETURNING Ap_Vf, Ap_St
             INTO l_Ap_Vf, l_Ap_St;


        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src      => 'USS_VISIT.API$VERIFICATION.UNLOCK_AP',
            p_obj_tp   => 'APPEAL',
            p_obj_id   => p_Ap_Id,
            p_regular_params   =>
                'l_Ap_Vf=' || l_Ap_Vf || ' l_Ap_St=' || l_Ap_St);

        IF l_Ap_Vf IS NULL
        THEN
            RETURN;
        END IF;

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => 'USS_VISIT.API$VERIFICATION.UNLOCK_AP',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'Run callback. p_Vf_Nvt=' || p_Vf_Nvt);
        --Виконуємо зворотній виклик, що прописано в таблиці налаштувань для поточної верифікації
        Vf_Callback (p_Vf_Nvt      => p_Vf_Nvt,
                     p_Vf_Obj_Tp   => 'A',
                     p_Vf_Obj_Id   => p_Ap_Id,
                     p_Vf_St       => p_Vf_St,
                     p_Vf_Id       => l_Ap_Vf);

        l_Hs := Tools.Gethistsession ();
        --#73983 2021,12,09
        Api$appeal.Write_Log (p_Apl_Ap        => p_Ap_Id,
                              p_Apl_Hs        => l_Hs,
                              p_Apl_St        => l_Ap_St,
                              p_Apl_Message   => CHR (38) || '4',
                              p_Apl_St_Old    => 'VW');

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => 'USS_VISIT.API$VERIFICATION.UNLOCK_AP',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'Finish Unlock_Ap');
    EXCEPTION
        WHEN OTHERS
        THEN
            Api$appeal.Write_Log (
                p_Apl_Ap        => p_Ap_Id,
                p_Apl_Hs        => Tools.Gethistsession (NULL),
                p_Apl_St        => 'VW',
                p_Apl_Message   =>
                       'Unlock_Ap Exception: '
                    || SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Apl_Tp        => Api$appeal.c_Apl_Tp_Terror);
    END;

    -------------------------------------------------------------------------------
    --              Завершення верифікацій звернень
    -------------------------------------------------------------------------------
    PROCEDURE Finish_Ap_Verifications
    IS
    BEGIN
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => 'USS_VISIT.API$VERIFICATION.FINISH_AP_VERIFICATIONS',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => NULL,
            p_regular_params   => 'Start Finish_Ap_Verifications');

        --#78995 2022.08.01
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            IKIS_SYS.Ikis_Procedure_Log.LOG (
                p_src              =>
                    'USS_VISIT.API$VERIFICATION.FINISH_AP_VERIFICATIONS',
                p_obj_tp           => 'APPEAL',
                p_obj_id           => NULL,
                p_regular_params   => 'Skip in main Finish_Ap_Verifications');
            RETURN;
        END IF;



        FOR Rec IN (  SELECT a.Ap_Id,
                             v.Vf_Obj_Tp,
                             v.Vf_Nvt,
                             v.Vf_St
                        FROM Appeal a JOIN Verification v ON a.Ap_Vf = v.Vf_Id
                       WHERE a.Ap_St = 'VW' AND v.Vf_St <> 'R'
                    ORDER BY Ap_Reg_Dt
                       FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                IKIS_SYS.Ikis_Procedure_Log.LOG (
                    p_src      =>
                        'USS_VISIT.API$VERIFICATION.FINISH_AP_VERIFICATIONS',
                    p_obj_tp   => 'APPEAL',
                    p_obj_id   => NULL,
                    p_regular_params   =>
                        'Skip in loop Finish_Ap_Verifications');
                RETURN;
            END IF;

            IKIS_SYS.Ikis_Procedure_Log.LOG (
                p_src              =>
                    'USS_VISIT.API$VERIFICATION.FINISH_AP_VERIFICATIONS',
                p_obj_tp           => 'APPEAL',
                p_obj_id           => Rec.Ap_Id,
                p_regular_params   => 'Appeal iteration');

            Unlock_Ap (p_Ap_Id    => Rec.Ap_Id,
                       p_Vf_Nvt   => Rec.Vf_Nvt,
                       p_Vf_St    => Rec.Vf_St);
            COMMIT;
        END LOOP;

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              => 'USS_VISIT.API$VERIFICATION.FINISH_AP_VERIFICATIONS',
            p_obj_tp           => 'APPEAL',
            p_obj_id           => NULL,
            p_regular_params   => 'Finish Finish_Ap_Verifications');
    END;

    -------------------------------------------------------------------------------
    --              Збереження відповіді на запит
    -------------------------------------------------------------------------------
    PROCEDURE Save_Verification_Answer (
        p_Vfa_Rn            IN     Vf_Answer.Vfa_Rn%TYPE,
        p_Vfa_Answer_Data   IN     Vf_Answer.Vfa_Answer_Data%TYPE,
        p_Vfa_Vf               OUT Vf_Answer.Vfa_Vf%TYPE)
    IS
    BEGIN
           UPDATE Vf_Answer
              SET Vfa_Answer_Data = p_Vfa_Answer_Data
            WHERE Vfa_Rn = p_Vfa_Rn
        RETURNING Vfa_Vf
             INTO p_Vfa_Vf;
    END;

    -------------------------------------------------------------------------------
    --              Зміна статусу верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Set_Verification_Status (p_Vf_Id   IN Verification.Vf_Id%TYPE,
                                       p_Vf_St   IN Verification.Vf_St%TYPE)
    IS
    BEGIN
        Set_Verification_Status (p_Vf_Id       => p_Vf_Id,
                                 p_Vf_St       => p_Vf_St,
                                 p_Vf_Own_St   => p_Vf_St);
        Api$verification.Check_Vf_St (p_Vf_Id => p_Vf_Id);
    END;

    -------------------------------------------------------------------------------
    --              Зміна статусу верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Set_Verification_Status (
        p_Vf_Id           IN Verification.Vf_Id%TYPE,
        p_Vf_St           IN Verification.Vf_St%TYPE,
        p_Vf_Own_St       IN Verification.Vf_Own_St%TYPE,
        p_Vf_Hs_Rewrite   IN Verification.Vf_Hs_Rewrite%TYPE DEFAULT NULL,
        p_Lock_Main_Vf    IN BOOLEAN DEFAULT TRUE)
    IS
        l_Is_Ended              NUMBER := 0;
        l_Parent_Nvt            Uss_Ndi.Ndi_Verification_Type.Nvt_Nvt_Main%TYPE;
        l_Vf_Vf_Main            Verification.Vf_Vf_Main%TYPE;
        l_Vf_Nvt                Verification.Vf_Nvt%TYPE;
        l_Vf_Tp                 Verification.Vf_Tp%TYPE;
        l_Vf_Obj_Tp             Verification.Vf_Obj_Tp%TYPE;
        l_Vf_Obj_Id             Verification.Vf_Obj_Id%TYPE;
        l_Lock_Handle           Tools.t_Lockhandler;
        l_Vf_Cnt                NUMBER;
        l_Vf_Ok_Cnt             NUMBER;
        l_Vf_Err_Cnt            NUMBER;
        l_Vf_Not_Verified_Cnt   NUMBER;
        l_Level                 NUMBER;
        l_App_Id                NUMBER;
        l_New_Vf_Cnt            NUMBER;
        l_Parent_Vf_St          Verification.Vf_St%TYPE;
        l_Ap_Id                 NUMBER;
        l_Ap_Vf                 NUMBER;
    BEGIN
        l_Is_Ended :=
            CASE
                WHEN p_Vf_St IN
                         (c_Vf_St_Ok, c_Vf_St_Error, c_Vf_St_Not_Verified)
                THEN
                    1
            END;

           UPDATE Verification v
              SET v.Vf_Own_St = NVL (p_Vf_Own_St, v.Vf_Own_St),
                  v.Vf_St =
                      CASE
                          --Змінюємо статус верифікації тільки у випадку, якщо ніхто не змінював його вручну
                          WHEN v.Vf_Hs_Rewrite IS NULL THEN p_Vf_St
                          ELSE c_Vf_St_Ok                            --v.Vf_St
                      END,
                  v.Vf_Stop_Dt =
                      CASE
                          WHEN l_Is_Ended = 1 THEN NVL (v.Vf_Stop_Dt, SYSDATE)
                      END,
                  v.Vf_Hs_Rewrite = NVL (p_Vf_Hs_Rewrite, v.Vf_Hs_Rewrite)
            WHERE v.Vf_Id = p_Vf_Id
        RETURNING v.Vf_Vf_Main,
                  v.Vf_Nvt,
                  v.Vf_Tp,
                  v.Vf_Obj_Tp,
                  v.Vf_Obj_Id
             INTO l_Vf_Vf_Main,
                  l_Vf_Nvt,
                  l_Vf_Tp,
                  l_Vf_Obj_Tp,
                  l_Vf_Obj_Id;

        IF l_Is_Ended <> 1
        THEN
            RETURN;
        END IF;

        --Якщо відбувається ручне підтвердження верифікації звернення
        IF     l_Vf_Tp = 'MAIN'
           AND l_Vf_Vf_Main IS NULL
           AND p_Vf_Hs_Rewrite IS NOT NULL
           AND p_Vf_St = c_Vf_St_Ok
        THEN
            Unlock_Ap (p_Ap_Id    => l_Vf_Obj_Id,
                       p_Vf_Nvt   => l_Vf_Nvt,
                       p_Vf_St    => p_Vf_St);
        END IF;

        IF     l_Vf_Tp <> 'AUTO'
           AND NOT (l_Vf_Tp = 'MAIN' AND l_Vf_Vf_Main IS NULL)
        THEN
            --Виконуємо зворотній виклик, що прописано в таблиці налаштувань для поточної верифікації
            Vf_Callback (p_Vf_Nvt      => l_Vf_Nvt,
                         p_Vf_Obj_Tp   => l_Vf_Obj_Tp,
                         p_Vf_Obj_Id   => l_Vf_Obj_Id,
                         p_Vf_St       => p_Vf_St,
                         p_Vf_Id       => p_Vf_Id);
        END IF;

        IF l_Vf_Vf_Main IS NOT NULL
        THEN
            IF p_Lock_Main_Vf
            THEN
                BEGIN
                    --Блокуємо сутність що верифікується
                    Ikis_Sys.Ikis_Lock.Request_Lock (
                        p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                        p_Var_Name            => 'VF' || l_Vf_Vf_Main,
                        p_Errmessage          => NULL,
                        p_Lockhandler         => l_Lock_Handle,
                        p_Timeout             => 3600,
                        p_Release_On_Commit   => TRUE);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        --Якщо під час блокування виникла помилка - це свідчить про те, що в поточній сессії блокування вже виконано
                        NULL;
                END;
            END IF;

            --Отримуємо кількість верифікацій на цьому ж рівні ієрархії,
            --загальну
            --що завершились успішно
            --що завершелись неуспішно
            SELECT COUNT (*)
                       AS Cnt,
                   SUM (CASE WHEN v.Vf_St = c_Vf_St_Ok THEN 1 ELSE 0 END)
                       Ok_Cnt,
                   SUM (CASE WHEN v.Vf_St = c_Vf_St_Error THEN 1 ELSE 0 END)
                       Err_Cnt,
                   SUM (
                       CASE
                           WHEN v.Vf_St = c_Vf_St_Not_Verified THEN 1
                           ELSE 0
                       END)
                       Not_Verified_Cnt
              INTO l_Vf_Cnt,
                   l_Vf_Ok_Cnt,
                   l_Vf_Err_Cnt,
                   l_Vf_Not_Verified_Cnt
              FROM Verification v
             WHERE v.Vf_Vf_Main = l_Vf_Vf_Main;


                --Визначаємо поточний рівень ієрархії
                --(віднімаємо 2, щоб не враховувати рівень звернення і рівень учасника)
                SELECT MAX (LEVEL) - 2
                  INTO l_Level
                  FROM Uss_Ndi.Ndi_Verification_Type t
                 WHERE t.Nvt_Id = l_Vf_Nvt
            CONNECT BY PRIOR t.Nvt_Id = t.Nvt_Nvt_Main;

            --Запуск наступних в ланцюжку верифікацій відбувається лише за умови,
            --якщо всі існуючі верифікації на цьому рівні ієрархії завершено успішно
            IF /*l_Vf_Ok_Cnt = l_Vf_Cnt
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           AND*/
               l_Level > 0
            THEN
                IF l_Vf_Obj_Tp = 'D'
                THEN
                    --Визначаємо ІД учасника звернення
                    SELECT d.Apd_App
                      INTO l_App_Id
                      FROM Ap_Document d
                     WHERE d.Apd_Id = l_Vf_Obj_Id;
                ELSIF l_Vf_Obj_Tp = 'P'
                THEN
                    l_App_Id := l_Vf_Obj_Id;
                END IF;

                --Визначаємо ІД батьківського типу верифікації
                SELECT t.Nvt_Nvt_Main
                  INTO l_Parent_Nvt
                  FROM Uss_Ndi.Ndi_Verification_Type t
                 WHERE t.Nvt_Id = l_Vf_Nvt;

                --Продовжуємо ланцюжок верифікацій(за умови наявності відповідних налаштувань в Ndi_Verification_Type)
                Ap_Person_Doc_Verification (p_App_Id       => l_App_Id,
                                            p_Parent_Vf    => l_Vf_Vf_Main,
                                            p_Parent_Nvt   => l_Parent_Nvt,
                                            p_Level        => l_Level,
                                            p_New_Vf_Cnt   => l_New_Vf_Cnt);

                --Якщо було запущено нові верифікації
                IF l_New_Vf_Cnt > 0 --Та виконується ручне підтвердження
                                    AND p_Vf_Hs_Rewrite IS NOT NULL
                THEN
                    --Отримуємо ІД звернення
                    SELECT App_Ap
                      INTO l_Ap_Id
                      FROM Ap_Person
                     WHERE App_Id = l_App_Id;

                       --Повертаємо звернення до статусу "Виконується верифікація"
                       UPDATE Appeal
                          SET Ap_St = 'VW'
                        WHERE     Ap_Id = l_Ap_Id
                              AND Ap_St <> 'VW'
                              AND Ap_Vf IS NOT NULL
                    RETURNING Ap_Vf
                         INTO l_Ap_Vf;

                    --Якщо коренева верифікація відсутня, наприклад хтось змінив звернення (при цьому автоматом відвязується верифікація)
                    --То зупиняємо новостворені
                    /*IF l_Ap_Vf IS NULL THEN
                      UPDATE Verification
                         SET Vf_St = 'N'
                       WHERE Vf_St = 'R'
                         AND Vf_Tp = 'AUTO'
                         AND Vf_Vf_Main = l_Vf_Vf_Main;
                    END IF;*/

                    --Та змінюємо статус батьківської верифікації та верифікації звернення на "Зареєстровано"
                    UPDATE Verification
                       SET Vf_St = 'R', Vf_Own_St = 'R'
                     WHERE Vf_Id IN (l_Ap_Vf, l_Vf_Vf_Main);
                END IF;
            END IF;

            --Якщо всі верифікації на цьому рівні завершено успішно,
            --або хочаб одна з верифікацій завершилась помилкою -
            --змінюємо статус верифікації рівнем вищче
            IF     NVL (l_New_Vf_Cnt, 0) = 0
               AND (l_Vf_Cnt =
                    l_Vf_Ok_Cnt + l_Vf_Err_Cnt + l_Vf_Not_Verified_Cnt)
            THEN
                --Розраховуємо статус батьківської верифікації
                --IF l_Vf_Cnt = l_Vf_Ok_Cnt THEN
                --  l_Parent_Vf_St := c_Vf_St_Ok;
                --ELSE
                l_Parent_Vf_St := Calc_Parent_Vf_St (l_Vf_Vf_Main);
                --END IF;

                Set_Verification_Status (p_Vf_Id           => l_Vf_Vf_Main,
                                         p_Vf_St           => l_Parent_Vf_St,
                                         p_Vf_Own_St       => l_Parent_Vf_St,
                                         p_Vf_Hs_Rewrite   => p_Vf_Hs_Rewrite,
                                         p_Lock_Main_Vf    => p_Lock_Main_Vf);
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --       Розрахунок статусу батьківської верифікації верифікації
    -------------------------------------------------------------------------------
    FUNCTION Calc_Parent_Vf_St (p_Parent_Vf_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Ap_Id          NUMBER;
        l_Parent_Vf_St   VARCHAR2 (10);
    BEGIN
            --Визначаємо ІД звернення
            SELECT MAX (v.Vf_Obj_Id)
              INTO l_Ap_Id
              FROM Verification v
                   JOIN Uss_Ndi.Ndi_Verification_Type t ON v.Vf_Nvt = t.Nvt_Id
             WHERE v.Vf_Obj_Tp = 'A'
        START WITH v.Vf_Id = p_Parent_Vf_Id
        CONNECT BY PRIOR v.Vf_Vf_Main = v.Vf_Id;

            --Визначаємо статус
            SELECT MIN (Calc_Vf_St (t.Nvt_Skip_Cond, l_Ap_Id, v.Vf_St))
              INTO l_Parent_Vf_St
              FROM Verification v
                   JOIN Uss_Ndi.Ndi_Verification_Type t ON v.Vf_Nvt = t.Nvt_Id
             WHERE v.Vf_Id <> p_Parent_Vf_Id
        START WITH v.Vf_Id = p_Parent_Vf_Id
        CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main;

        DBMS_OUTPUT.put_line (l_Parent_Vf_St);
        RETURN l_Parent_Vf_St;
    END;

    -------------------------------------------------------------------------------
    -- Розрахунок статусу верифікації
    -- з урахуванням умови, яку вказано в конфігурації
    -------------------------------------------------------------------------------
    FUNCTION Calc_Vf_St (p_Nvt_Skip_Cond   IN VARCHAR2,
                         p_Ap_Id           IN NUMBER,
                         p_Vf_St           IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Expression   VARCHAR2 (4000);
        l_Skip         BOOLEAN;
    BEGIN
        IF p_Nvt_Skip_Cond IS NULL
        THEN
            RETURN p_Vf_St;
        END IF;

        l_Expression :=
            REGEXP_REPLACE (p_Nvt_Skip_Cond,
                            ':Ap',
                            p_Ap_Id,
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Vf_St',
                            q'[']' || p_Vf_St || q'[']',
                            1,
                            0,
                            'i');
        l_Expression := 'BEGIN :p_skip := ' || l_Expression || '; END;';

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Skip;


        RETURN CASE WHEN l_Skip THEN c_Vf_St_Ok ELSE p_Vf_St END;
    END;

    PROCEDURE Confirm_Child_Vf (p_Parent_Vf_Id    IN NUMBER,
                                p_Vf_Hs_Rewrite   IN NUMBER)
    IS
    BEGIN
        FOR Rec IN (    SELECT v.Vf_Id
                          FROM Verification v
                         WHERE v.Vf_Id <> p_Parent_Vf_Id
                    START WITH v.Vf_Id = p_Parent_Vf_Id
                    CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main)
        LOOP
            UPDATE Verification v
               SET v.Vf_St = Api$verification.c_Vf_St_Ok,
                   v.Vf_Stop_Dt =
                       CASE WHEN v.Vf_Stop_Dt IS NULL THEN SYSDATE END,
                   v.Vf_Hs_Rewrite = p_Vf_Hs_Rewrite
             WHERE v.Vf_Id = Rec.Vf_Id;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Відкладання виконання автоматичної верифікації на вказаний час
    -------------------------------------------------------------------------------
    PROCEDURE Delay_Auto_Vf (p_Vf_Id           IN NUMBER,
                             p_Delay_Seconds   IN NUMBER,
                             p_Delay_Reason    IN VARCHAR2)
    IS
    BEGIN
        UPDATE Verification
           SET Vf_Plan_Dt =
                   SYSDATE + NUMTODSINTERVAL (p_Delay_Seconds, 'SECOND')
         WHERE Vf_Id = p_Vf_Id;

        IF p_Delay_Reason IS NOT NULL
        THEN
            Write_Vf_Log (p_Vf_Id, c_Vfl_Tp_Info, p_Delay_Reason);
        END IF;
    END;

    -------------------------------------------------------------------------------
    -- Призупинення виконання автоматичної верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Suspend_Auto_Vf (p_Vf_Id IN NUMBER)
    IS
    BEGIN
        UPDATE Verification
           SET Vf_Plan_Dt = NULL
         WHERE Vf_Id = p_Vf_Id;
    END;

    -------------------------------------------------------------------------------
    -- Відновлення виконання автоматичної верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Resume_Auto_Vf (p_Vf_Id IN NUMBER)
    IS
    BEGIN
        UPDATE Verification
           SET Vf_Plan_Dt = SYSDATE
         WHERE Vf_Id = p_Vf_Id;
    END;

    -------------------------------------------------------------------------------
    -- Отримання кількості верифікаційних запитів по одній верифікації
    -------------------------------------------------------------------------------
    FUNCTION Get_Vf_Req_Cnt (p_Vf_Id IN NUMBER, p_Rn_Nrt IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Result
          FROM Vf_Answer
               JOIN Ikis_Rbm.v_Request_Journal
                   ON Vfa_Rn = Rn_Id AND Rn_Nrt = p_Rn_Nrt
         WHERE Vfa_Vf = p_Vf_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Ur_Vf (p_Ur_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Rn_Id   NUMBER;
        l_Vf_Id   NUMBER;
    BEGIN
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        SELECT MAX (a.Vfa_Vf)
          INTO l_Vf_Id
          FROM Vf_Answer a
         WHERE a.Vfa_Rn = l_Rn_Id;

        RETURN l_Vf_Id;
    END;
BEGIN
    -- Initialization
    NULL;
END Api$verification;
/