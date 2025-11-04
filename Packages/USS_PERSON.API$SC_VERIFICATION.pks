/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_VERIFICATION
IS
    -- Author  : KELATEV
    -- Created : 29.07.2024 17:01:59
    -- Purpose : Функції роботи з верифікаціями даних осіб

    g_Scv_Id                         NUMBER;

    c_St_Scv_Required       CONSTANT VARCHAR2 (10) := 'VR'; -- Потребує верифікації
    c_St_Scv_Work           CONSTANT VARCHAR2 (10) := 'VW'; -- Виконується верифікація
    c_St_Scv_Ok             CONSTANT VARCHAR2 (10) := 'VO'; -- Успішна верифікація
    c_St_Scv_Error          CONSTANT VARCHAR2 (10) := 'VE'; -- Неуспішна верифікація

    --статуси верифікацій
    c_Scv_St_Reg            CONSTANT VARCHAR2 (10) := 'R';     --Зареєстровано
    c_Scv_St_Error          CONSTANT VARCHAR2 (10) := 'E';  --Технічна помилка
    c_Scv_St_Ok             CONSTANT VARCHAR2 (10) := 'X'; --Успішна верифікація
    c_Scv_St_Not_Verified   CONSTANT VARCHAR2 (10) := 'N'; --Верифікацію не пройдено

    --типи повідомлень в протоколі верифікації
    c_Scvl_Tp_Info          CONSTANT VARCHAR2 (10) := 'I';
    c_Scvl_Tp_Error         CONSTANT VARCHAR2 (10) := 'E';
    c_Scvl_Tp_Terror        CONSTANT VARCHAR2 (10) := 'T';  --Технічна помилка
    c_Scvl_Tp_Warning       CONSTANT VARCHAR2 (10) := 'W';
    c_Scvl_Tp_Done          CONSTANT VARCHAR2 (10) := 'D';
    c_Scvl_Tp_Process       CONSTANT VARCHAR2 (10) := 'P'; -- Титичасвова помилка процессу веріфікації

    c_Scv_Obj_Tp_Pi         CONSTANT VARCHAR2 (10) := 'PI'; --sc_Pfu_data_Ident
    c_Scv_Obj_Tp_Pd         CONSTANT VARCHAR2 (10) := 'PD';  --sc_Pfu_Document
    c_Scv_Obj_Tp_Pa         CONSTANT VARCHAR2 (10) := 'PA';   --sc_Pfu_Address

    --METHODS
    FUNCTION Get_Scv_Obj (p_Scv_Id IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Write_Scv_Log (p_Scv_Id         IN Sc_Verification.Scv_Id%TYPE,
                             p_Scvl_Hs        IN Scv_Log.Scvl_Hs%TYPE,
                             p_Scvl_Message   IN Scv_Log.Scvl_Message%TYPE,
                             p_Scvl_Tp        IN Scv_Log.Scvl_Tp%TYPE,
                             p_Scvl_St        IN Scv_Log.Scvl_St%TYPE,
                             p_Scvl_St_Old    IN Scv_Log.Scvl_St_Old%TYPE);

    PROCEDURE Set_Not_Verified (p_Scv_Id    IN NUMBER,
                                p_Scvl_Hs   IN Scv_Log.Scvl_Hs%TYPE,
                                p_Error     IN VARCHAR2);

    PROCEDURE Set_Ok (p_Scv_Id IN NUMBER, p_Scvl_Hs IN Scv_Log.Scvl_Hs%TYPE);

    PROCEDURE Set_Tech_Error (p_Rn_Id     IN NUMBER,
                              p_Scvl_Hs   IN Scv_Log.Scvl_Hs%TYPE,
                              p_Error     IN VARCHAR2);

    FUNCTION Get_Verification (
        p_Scv_Tp            Sc_Verification.Scv_Tp%TYPE,
        p_Scv_Nvt           Sc_Verification.Scv_Nvt%TYPE,
        p_Scv_Obj_Tp        Sc_Verification.Scv_Obj_Tp%TYPE,
        p_Scv_Obj_Id        Sc_Verification.Scv_Obj_Id%TYPE,
        p_Scv_Hs         IN Sc_Verification.Scv_Hs%TYPE,
        p_Scv_Scv_Main      Sc_Verification.Scv_Scv_Main%TYPE := NULL)
        RETURN Sc_Verification.Scv_Id%TYPE;

    PROCEDURE Register_Scv_Request (
        p_Scv_Id       IN Sc_Verification.Scv_Id%TYPE,
        p_Scv_Obj_Id   IN Sc_Verification.Scv_Obj_Id%TYPE,
        p_Hs           IN NUMBER,
        p_Nvt_Id       IN Uss_Ndi.v_Ndi_Verification_Type.Nvt_Id%TYPE DEFAULT NULL,
        p_Nvt_Nrt      IN Uss_Ndi.v_Ndi_Verification_Type.Nvt_Nrt%TYPE DEFAULT NULL);

    PROCEDURE Link_Request2verification (
        p_Scva_Scv   IN Scv_Answer.Scva_Scv%TYPE,
        p_Scva_Rn    IN Scv_Answer.Scva_Rn%TYPE);

    PROCEDURE Save_Verification_Answer (
        p_Scva_Rn            IN     Scv_Answer.Scva_Rn%TYPE,
        p_Scva_Answer_Data   IN     Scv_Answer.Scva_Answer_Data%TYPE,
        p_Scva_Scv              OUT Scv_Answer.Scva_Scv%TYPE);

    PROCEDURE Collect_Scdi_For_Verification;

    PROCEDURE Execute_Scdi_Auto_Verifications;

    PROCEDURE Finish_Scdi_Verifications;

    /*PROCEDURE Set_Scdi_Verification_Status(p_Scv_Id IN Sc_Verification.Scv_Id%TYPE,
    p_Scv_St IN Sc_Verification.Scv_St%TYPE,
    p_Scv_Hs IN Sc_Verification.Scv_Hs%TYPE);*/

    PROCEDURE Set_Scdi_Verification_Status (
        p_Scv_Id          IN Sc_Verification.Scv_Id%TYPE,
        p_Scv_St          IN Sc_Verification.Scv_St%TYPE,
        p_Scv_Hs          IN Sc_Verification.Scv_Hs%TYPE,
        p_Lock_Main_Scv   IN BOOLEAN DEFAULT TRUE);

    FUNCTION Calc_Parent_Scv_St (p_Parent_Scv_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Calc_Scv_St (p_Nvt_Skip_Cond   IN VARCHAR2,
                          p_Scdi_Id         IN NUMBER,
                          p_Scv_St          IN VARCHAR2)
        RETURN VARCHAR2;
END Api$sc_Verification;
/


GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SC_VERIFICATION TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_VERIFICATION
IS
    FUNCTION Get_Scv_Main (p_Scv_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Scv   NUMBER;
    BEGIN
        SELECT Scv_Scv_Main
          INTO l_Scv
          FROM Sc_Verification
         WHERE Scv_Id = p_Scv_Id;

        IF l_Scv IS NULL
        THEN
            RETURN p_Scv_Id;
        ELSE
            RETURN Get_Scv_Main (l_Scv);
        END IF;
    END;

    FUNCTION Get_Scv_Obj (p_Scv_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT v.Scv_Obj_Id
          INTO l_Result
          FROM Sc_Verification v
         WHERE v.Scv_Id = p_Scv_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Scv_By_Rn (p_Scv_Rn IN Scv_Answer.Scva_Rn%TYPE)
        RETURN Scv_Answer.Scva_Scv%TYPE
    IS
        l_Result   Scv_Answer.Scva_Scv%TYPE;
    BEGIN
        SELECT MAX (a.Scva_Scv)
          INTO l_Result
          FROM Scv_Answer a
         WHERE a.Scva_Rn = p_Scv_Rn;

        RETURN l_Result;
    END;

    PROCEDURE Check_Scv_St (p_Scv_Id IN NUMBER)
    IS
        l_r          NUMBER;
        l_x          NUMBER;
        l_Scv_Main   NUMBER;
    BEGIN
        l_Scv_Main := Get_Scv_Main (p_Scv_Id);

            SELECT COUNT (CASE WHEN Scv_St = 'R' THEN 1 END),
                   COUNT (
                       CASE WHEN Scv_Id = l_Scv_Main AND Scv_St = 'X' THEN 1 END)
              INTO l_r, l_x
              FROM Sc_Verification v
        START WITH v.Scv_Id = l_Scv_Main
        CONNECT BY PRIOR v.Scv_Id = v.Scv_Scv_Main;

        IF l_r > 0 AND l_x > 0
        THEN
            Raise_Application_Error (-20000,
                                     'Ошибка установки статуса верификации');
        END IF;
    END;

    FUNCTION Is_Scv_Log_Message_Exists (
        p_Scv_Id         IN Sc_Verification.Scv_Id%TYPE,
        p_Scvl_Tp        IN Scv_Log.Scvl_Tp%TYPE,
        p_Scvl_Message   IN Scv_Log.Scvl_Message%TYPE)
        RETURN NUMBER
    IS
        l_Qty   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Qty
          FROM Scv_Log
         WHERE     Scvl_Scv = p_Scv_Id
               AND Scvl_Tp = p_Scvl_Tp
               AND Scvl_Message = p_Scvl_Message;

        RETURN l_Qty;
    END;

    --Пишему протоколу верифікації
    PROCEDURE Write_Scv_Log (p_Scv_Id         IN Sc_Verification.Scv_Id%TYPE,
                             p_Scvl_Hs        IN Scv_Log.Scvl_Hs%TYPE,
                             p_Scvl_Message   IN Scv_Log.Scvl_Message%TYPE,
                             p_Scvl_Tp        IN Scv_Log.Scvl_Tp%TYPE,
                             p_Scvl_St        IN Scv_Log.Scvl_St%TYPE,
                             p_Scvl_St_Old    IN Scv_Log.Scvl_St_Old%TYPE)
    IS
    BEGIN
        INSERT INTO Scv_Log (Scvl_Id,
                             Scvl_Scv,
                             Scvl_Hs,
                             Scvl_St,
                             Scvl_Message,
                             Scvl_Tp,
                             Scvl_St_Old)
             VALUES (0,
                     p_Scv_Id,
                     p_Scvl_Hs,
                     p_Scvl_St,
                     p_Scvl_Message,
                     p_Scvl_Tp,
                     p_Scvl_St_Old);
    END;

    PROCEDURE Set_Not_Verified (p_Scv_Id    IN NUMBER,
                                p_Scvl_Hs   IN Scv_Log.Scvl_Hs%TYPE,
                                p_Error     IN VARCHAR2)
    IS
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                           p_Scvl_Hs        => p_Scvl_Hs,
                           p_Scvl_Tp        => c_Scvl_Tp_Error,
                           p_Scvl_Message   => p_Error,
                           p_Scvl_St        => c_St_Scv_Error,
                           p_Scvl_St_Old    => NULL);
        ELSE
            IF Is_Scv_Log_Message_Exists (
                   p_Scv_Id         => p_Scv_Id,
                   p_Scvl_Tp        => c_Scvl_Tp_Done,
                   p_Scvl_Message   => CHR (38) || '96') =
               0
            THEN
                Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                               p_Scvl_Hs        => p_Scvl_Hs,
                               p_Scvl_Tp        => c_Scvl_Tp_Done,
                               p_Scvl_Message   => CHR (38) || '96',
                               p_Scvl_St        => c_St_Scv_Error,
                               p_Scvl_St_Old    => NULL);
            END IF;
        END IF;

        --Змінюємо статус верифікації
        Set_Scdi_Verification_Status (p_Scv_Id   => p_Scv_Id,
                                      p_Scv_St   => c_Scv_St_Not_Verified,
                                      p_Scv_Hs   => p_Scvl_Hs);
    END;

    PROCEDURE Set_Ok (p_Scv_Id IN NUMBER, p_Scvl_Hs IN Scv_Log.Scvl_Hs%TYPE)
    IS
    BEGIN
        IF Is_Scv_Log_Message_Exists (p_Scv_Id         => p_Scv_Id,
                                      p_Scvl_Tp        => c_Scvl_Tp_Done,
                                      p_Scvl_Message   => CHR (38) || '97') =
           0
        THEN
            Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                           p_Scvl_Hs        => p_Scvl_Hs,
                           p_Scvl_Message   => CHR (38) || '97',
                           p_Scvl_Tp        => c_Scvl_Tp_Done,
                           p_Scvl_St        => c_Scv_St_Ok,
                           p_Scvl_St_Old    => NULL);
        END IF;

        --Змінюємо статус верифікації
        Set_Scdi_Verification_Status (p_Scv_Id   => p_Scv_Id,
                                      p_Scv_St   => c_Scv_St_Ok,
                                      p_Scv_Hs   => p_Scvl_Hs);
    END;

    PROCEDURE Set_Tech_Error (p_Rn_Id     IN NUMBER,
                              p_Scvl_Hs   IN Scv_Log.Scvl_Hs%TYPE,
                              p_Error     IN VARCHAR2)
    IS
        l_Scv_Id   NUMBER;
    BEGIN
        l_Scv_Id := Get_Scv_By_Rn (p_Rn_Id);
        Set_Scdi_Verification_Status (p_Scv_Id   => l_Scv_Id,
                                      p_Scv_Hs   => p_Scvl_Hs,
                                      p_Scv_St   => c_Scv_St_Error);
        Write_Scv_Log (p_Scv_Id         => l_Scv_Id,
                       p_Scvl_Hs        => p_Scvl_Hs,
                       p_Scvl_Tp        => c_Scvl_Tp_Terror,
                       p_Scvl_Message   => p_Error,
                       p_Scvl_St        => c_Scv_St_Error,
                       p_Scvl_St_Old    => NULL);

        IF Is_Scv_Log_Message_Exists (p_Scv_Id         => l_Scv_Id,
                                      p_Scvl_Tp        => c_Scvl_Tp_Done,
                                      p_Scvl_Message   => CHR (38) || '96') =
           0
        THEN
            Write_Scv_Log (p_Scv_Id         => l_Scv_Id,
                           p_Scvl_Hs        => p_Scvl_Hs,
                           p_Scvl_Tp        => c_Scvl_Tp_Done,
                           p_Scvl_Message   => CHR (38) || '96',
                           p_Scvl_St        => c_Scv_St_Ok,
                           p_Scvl_St_Old    => NULL);
        END IF;
    END;

    PROCEDURE Save_Verification (
        p_Scv_Id         IN     Sc_Verification.Scv_Id%TYPE,
        p_Scv_Scv_Main   IN     Sc_Verification.Scv_Scv_Main%TYPE,
        p_Scv_Tp         IN     Sc_Verification.Scv_Tp%TYPE,
        p_Scv_St         IN     Sc_Verification.Scv_St%TYPE,
        p_Scv_Start_Dt   IN     Sc_Verification.Scv_Start_Dt%TYPE,
        p_Scv_Stop_Dt    IN     Sc_Verification.Scv_Stop_Dt%TYPE,
        p_Scv_Nvt        IN     Sc_Verification.Scv_Nvt%TYPE,
        p_Scv_Obj_Tp     IN     Sc_Verification.Scv_Obj_Tp%TYPE,
        p_Scv_Obj_Id     IN     Sc_Verification.Scv_Obj_Id%TYPE,
        p_Scv_Hs         IN     Sc_Verification.Scv_Hs%TYPE,
        p_New_Id            OUT Sc_Verification.Scv_Id%TYPE)
    IS
    BEGIN
        IF NVL (p_Scv_Id, -1) < 0
        THEN
            INSERT INTO Sc_Verification (Scv_Id,
                                         Scv_Scv_Main,
                                         Scv_Tp,
                                         Scv_St,
                                         Scv_Start_Dt,
                                         Scv_Stop_Dt,
                                         Scv_Nvt,
                                         Scv_Obj_Id,
                                         Scv_Obj_Tp,
                                         Scv_Hs)
                 VALUES (0,
                         p_Scv_Scv_Main,
                         p_Scv_Tp,
                         p_Scv_St,
                         p_Scv_Start_Dt,
                         p_Scv_Stop_Dt,
                         p_Scv_Nvt,
                         p_Scv_Obj_Id,
                         p_Scv_Obj_Tp,
                         p_Scv_Hs)
              RETURNING Scv_Id
                   INTO p_New_Id;
        ELSE
            UPDATE Sc_Verification v
               SET v.Scv_St = p_Scv_St, v.Scv_Stop_Dt = p_Scv_Stop_Dt
             WHERE v.Scv_Id = p_Scv_Id;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --Отримуємо реєстраційний запис верифікації
    -------------------------------------------------------------------------------
    FUNCTION Get_Verification (
        p_Scv_Tp            Sc_Verification.Scv_Tp%TYPE,
        p_Scv_Nvt           Sc_Verification.Scv_Nvt%TYPE,
        p_Scv_Obj_Tp        Sc_Verification.Scv_Obj_Tp%TYPE,
        p_Scv_Obj_Id        Sc_Verification.Scv_Obj_Id%TYPE,
        p_Scv_Hs         IN Sc_Verification.Scv_Hs%TYPE,
        p_Scv_Scv_Main      Sc_Verification.Scv_Scv_Main%TYPE := NULL)
        RETURN Sc_Verification.Scv_Id%TYPE
    IS
    BEGIN
        Save_Verification (p_Scv_Id         => NULL,
                           p_Scv_Scv_Main   => p_Scv_Scv_Main,
                           p_Scv_Tp         => p_Scv_Tp,
                           p_Scv_St         => 'R',
                           p_Scv_Start_Dt   => SYSDATE,
                           p_Scv_Stop_Dt    => NULL,
                           p_Scv_Nvt        => p_Scv_Nvt,
                           p_Scv_Obj_Tp     => p_Scv_Obj_Tp,
                           p_Scv_Obj_Id     => p_Scv_Obj_Id,
                           p_Scv_Hs         => p_Scv_Hs,
                           p_New_Id         => g_Scv_Id);

        Write_Scv_Log (p_Scv_Id         => g_Scv_Id,
                       p_Scvl_Hs        => p_Scv_Hs,
                       p_Scvl_St        => 'R',
                       p_Scvl_St_Old    => NULL,
                       p_Scvl_Message   => CHR (38) || '178',
                       p_Scvl_Tp        => c_Scvl_Tp_Info);

        RETURN g_Scv_Id;
    END;

    -------------------------------------------------------------------------------
    --              Реєстрація запиту для верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Register_Scv_Request (
        p_Scv_Id       IN Sc_Verification.Scv_Id%TYPE,
        p_Scv_Obj_Id   IN Sc_Verification.Scv_Obj_Id%TYPE,
        p_Hs           IN NUMBER,
        p_Nvt_Id       IN Uss_Ndi.v_Ndi_Verification_Type.Nvt_Id%TYPE DEFAULT NULL,
        p_Nvt_Nrt      IN Uss_Ndi.v_Ndi_Verification_Type.Nvt_Nrt%TYPE DEFAULT NULL)
    IS
        l_Nvt_Nrt         Uss_Ndi.v_Ndi_Verification_Type.Nvt_Nrt%TYPE;
        l_Nrt_Make_Func   Uss_Ndi.v_Ndi_Request_Type.Nrt_Make_Func%TYPE;
        l_Rn_Id           NUMBER;
        l_Error           VARCHAR2 (4000);
    BEGIN
        Tools.LOG (
            'Api$sc_Verification.Register_Scv_Request',
            'SCV',
            p_Scv_Id,
               'Start: p_Nvt_Id='
            || p_Nvt_Id
            || ', p_Nvt_Nrt='
            || p_Nvt_Nrt
            || ', p_Scv_Obj_Id='
            || p_Scv_Obj_Id);

        IF p_Nvt_Nrt IS NULL
        THEN
            SELECT t.Nvt_Nrt
              INTO l_Nvt_Nrt
              FROM Uss_Ndi.v_Ndi_Verification_Type t
             WHERE t.Nvt_Id = p_Nvt_Id;
        ELSE
            l_Nvt_Nrt := p_Nvt_Nrt;
        END IF;

        SELECT r.Nrt_Make_Func
          INTO l_Nrt_Make_Func
          FROM Uss_Ndi.v_Ndi_Request_Type r
         WHERE r.Nrt_Id = l_Nvt_Nrt;

        BEGIN
            EXECUTE IMMEDIATE   'begin :p_rn_id :='
                             || l_Nrt_Make_Func
                             || '(p_rn_nrt => :p_rn_nrt, p_obj_id => :p_obj_id, p_error => :p_error); end;'
                USING OUT l_Rn_Id,
                      IN l_Nvt_Nrt,
                      IN p_Scv_Obj_Id,
                      OUT l_Error;
        EXCEPTION
            WHEN OTHERS
            THEN
                Write_Scv_Log (
                    p_Scv_Id        => p_Scv_Id,
                    p_Scvl_Hs       => p_Hs,
                    p_Scvl_Tp       => c_Scvl_Tp_Terror,
                    p_Scvl_St       => c_St_Scv_Error,
                    p_Scvl_St_Old   => NULL,
                    p_Scvl_Message   =>
                           SQLERRM
                        || CHR (13)
                        || 'l_Nvt_Nrt = '
                        || l_Nvt_Nrt
                        || ', p_Scv_Obj_Id = '
                        || p_Scv_Obj_Id
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Backtrace);
                Set_Scdi_Verification_Status (
                    p_Scv_Id          => p_Scv_Id,
                    p_Scv_St          => c_Scv_St_Not_Verified,
                    p_Scv_Hs          => p_Hs,
                    p_Lock_Main_Scv   => FALSE);
                Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                               p_Scvl_Hs        => p_Hs,
                               p_Scvl_Tp        => c_Scvl_Tp_Done,
                               p_Scvl_St        => NULL,
                               p_Scvl_St_Old    => NULL,
                               p_Scvl_Message   => CHR (38) || '179');
        END;

        IF l_Error IS NOT NULL
        THEN
            Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                           p_Scvl_Hs        => p_Hs,
                           p_Scvl_Tp        => c_Scvl_Tp_Error,
                           p_Scvl_Message   => l_Error,
                           p_Scvl_St        => c_St_Scv_Error,
                           p_Scvl_St_Old    => NULL);
            Set_Scdi_Verification_Status (p_Scv_Id          => p_Scv_Id,
                                          p_Scv_St          => c_Scv_St_Not_Verified,
                                          p_Scv_Hs          => p_Hs,
                                          p_Lock_Main_Scv   => FALSE);
            Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                           p_Scvl_Hs        => p_Hs,
                           p_Scvl_Tp        => c_Scvl_Tp_Done,
                           p_Scvl_Message   => CHR (38) || '179',
                           p_Scvl_St        => NULL,
                           p_Scvl_St_Old    => NULL);
            RETURN;
        END IF;

        IF l_Rn_Id IS NOT NULL
        THEN
            Link_Request2verification (p_Scva_Scv   => p_Scv_Id,
                                       p_Scva_Rn    => l_Rn_Id);
            Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                           p_Scvl_Hs        => p_Hs,
                           p_Scvl_Tp        => c_Scvl_Tp_Info,
                           p_Scvl_Message   => CHR (38) || '180',
                           p_Scvl_St        => NULL,
                           p_Scvl_St_Old    => NULL);
        END IF;
    END;

    -------------------------------------------------------------------------------
    --              Створення звязку між верифікацією та запитом
    -------------------------------------------------------------------------------
    PROCEDURE Link_Request2verification (
        p_Scva_Scv   IN Scv_Answer.Scva_Scv%TYPE,
        p_Scva_Rn    IN Scv_Answer.Scva_Rn%TYPE)
    IS
    BEGIN
        INSERT INTO Scv_Answer (Scva_Scv, Scva_Rn)
             VALUES (p_Scva_Scv, p_Scva_Rn);
    END;

    -------------------------------------------------------------------------------
    --              Збереження відповіді на запит
    -------------------------------------------------------------------------------
    PROCEDURE Save_Verification_Answer (
        p_Scva_Rn            IN     Scv_Answer.Scva_Rn%TYPE,
        p_Scva_Answer_Data   IN     Scv_Answer.Scva_Answer_Data%TYPE,
        p_Scva_Scv              OUT Scv_Answer.Scva_Scv%TYPE)
    IS
    BEGIN
           UPDATE Scv_Answer
              SET Scva_Answer_Data = p_Scva_Answer_Data
            WHERE Scva_Rn = p_Scva_Rn
        RETURNING Scva_Scv
             INTO p_Scva_Scv;
    END;

    -------------------------------------------------------------------------------
    -- Визначення умови необхідності запуску верифікації
    -------------------------------------------------------------------------------
    FUNCTION Need_Start_Scv (p_Nvt_Start_Cond   IN VARCHAR2,
                             p_Scdi_Id          IN NUMBER,
                             p_Scpo_Id          IN NUMBER DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Expression       VARCHAR2 (4000);
        l_Need_Start_Scv   BOOLEAN;
    BEGIN
        IF p_Nvt_Start_Cond IS NULL
        THEN
            RETURN TRUE;
        END IF;

        l_Expression :=
            REGEXP_REPLACE (p_Nvt_Start_Cond,
                            ':scpo',
                            p_Scpo_Id,
                            1,
                            0,
                            'i');                            --sc_pfu_document
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':scdi',
                            p_Scdi_Id,
                            1,
                            0,
                            'i');                          --sc_pfu_data_ident
        l_Expression := 'BEGIN :p_need_start := ' || l_Expression || '; END;';

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Need_Start_Scv;

        RETURN l_Need_Start_Scv;
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

    -------------------------------------------------------------------------------
    -- Зворотній виклик, що виконується після завершення верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scv_Callback (p_Nvt_Callback   IN VARCHAR2,
                            p_Scv_Obj_Tp     IN VARCHAR2,
                            p_Scv_Obj_Id     IN NUMBER,
                            p_Scv_St         IN VARCHAR2,
                            p_Scv_Id         IN NUMBER)
    IS
        l_Expression   VARCHAR2 (8000);
    BEGIN
        IF p_Nvt_Callback IS NULL
        THEN
            RETURN;
        END IF;

        l_Expression := p_Nvt_Callback;

        IF p_Scv_Obj_Tp = c_Scv_Obj_Tp_Pi
        THEN
            --sc_Pfu_data_Ident
            l_Expression :=
                REGEXP_REPLACE (l_Expression,
                                ':Scdi',
                                p_Scv_Obj_Id,
                                1,
                                0,
                                'i');
        END IF;

        IF p_Scv_Obj_Tp = c_Scv_Obj_Tp_Pd
        THEN
            --sc_Pfu_Document
            l_Expression :=
                REGEXP_REPLACE (l_Expression,
                                ':Scpo',
                                p_Scv_Obj_Id,
                                1,
                                0,
                                'i');
        END IF;

        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Scv_St',
                            q'[']' || p_Scv_St || q'[']',
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Scv_Id',
                            q'[']' || p_Scv_Id || q'[']',
                            1,
                            0,
                            'i');

        EXECUTE IMMEDIATE l_Expression;
    END;

    -------------------------------------------------------------------------------
    -- Зворотній виклик, що виконується після завершення верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scv_Callback (p_Scv_Nvt      IN NUMBER,
                            p_Scv_Obj_Tp   IN VARCHAR2,
                            p_Scv_Obj_Id   IN NUMBER,
                            p_Scv_St       IN VARCHAR2,
                            p_Scv_Id       IN NUMBER)
    IS
        l_Nvt_Callback   Uss_Ndi.v_Ndi_Verification_Type.Nvt_Callback%TYPE;
    BEGIN
        SELECT t.Nvt_Callback
          INTO l_Nvt_Callback
          FROM Uss_Ndi.v_Ndi_Verification_Type t
         WHERE t.Nvt_Id = p_Scv_Nvt;

        Scv_Callback (p_Nvt_Callback   => l_Nvt_Callback,
                      p_Scv_Obj_Tp     => p_Scv_Obj_Tp,
                      p_Scv_Obj_Id     => p_Scv_Obj_Id,
                      p_Scv_St         => p_Scv_St,
                      p_Scv_Id         => p_Scv_Id);
    END;

    -------------------------------------------------------------------------------
    -- "Забираємо" проміжні дані на верифікацію -
    -- зміна статусу та прописування "группуючої" верифікації в проміжні дані
    -------------------------------------------------------------------------------
    FUNCTION Lock_Scdi_For_Verification (
        p_Scdi_Id          Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Nvt_Id    IN     NUMBER,
        p_Hs        IN     Sc_Verification.Scv_Hs%TYPE,
        p_Scv_Id       OUT Sc_Verification.Scv_Id%TYPE)
        RETURN BOOLEAN
    IS
        l_Data_Ident_Begin_Work   BOOLEAN := FALSE;
    BEGIN
        p_Scv_Id :=
            Get_Verification (p_Scv_Tp       => 'MAIN_PFU',
                              p_Scv_Nvt      => p_Nvt_Id,
                              p_Scv_Obj_Tp   => c_Scv_Obj_Tp_Pi,
                              p_Scv_Obj_Id   => p_Scdi_Id,
                              p_Scv_Hs       => p_Hs);

        UPDATE Sc_Pfu_Data_Ident
           SET Scdi_St = 'VW'
         WHERE Scdi_Id = p_Scdi_Id AND Scdi_St = 'VR';

        l_Data_Ident_Begin_Work := SQL%ROWCOUNT > 0;

        IF l_Data_Ident_Begin_Work
        THEN
            Api$sc_Verification_Pfu.Set_Scdi_Child_St (
                p_Scdi_Id    => p_Scdi_Id,
                p_Scdi_St    => 'VW',
                p_Is_Force   => TRUE);
        END IF;

        RETURN l_Data_Ident_Begin_Work;
    END;

    -------------------------------------------------------------------------------
    -- Ставимо складові звернення до верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Scdi_Verification (
        p_Scdi_Id       IN     Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Parent_Scv    IN     Sc_Verification.Scv_Id%TYPE,
        p_Parent_Nvt    IN     NUMBER,
        p_Hs            IN     NUMBER,
        p_New_Scv_Cnt   IN OUT NUMBER)
    IS
        l_Scv_Id           Sc_Verification.Scv_Id%TYPE;
        l_Parallel_Cnt     NUMBER := 0;
        l_Sequential_Cnt   NUMBER := 0;
        l_Skip_Scv         VARCHAR2 (10);
        l_Scv_St           VARCHAR2 (10);
    BEGIN
        Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                   'SCV',
                   p_Parent_Scv,
                   'Start: Scdi_Id=' || p_Scdi_Id);

        FOR Rec
            IN (  SELECT *
                    FROM ( --Верифікації по учаснику, що не повязані з документами
                          SELECT p.Scdi_Id     AS Obj_Id,
                                 'PI'          AS Obj_Tp,
                                 NULL          AS Vf_Id,
                                 t.Nvt_Id,
                                 t.Nvt_Order,
                                 t.Nvt_Start_Cond,
                                 t.Nvt_Callback,
                                 t.Nvt_Is_Parallel,
                                 t.Nvt_Vf_Tp
                            FROM Uss_Ndi.v_Ndi_Verification_Type t
                                 JOIN Sc_Pfu_Data_Ident p
                                     ON p.Scdi_Id = p_Scdi_Id
                           WHERE     t.Nvt_Nvt_Main = p_Parent_Nvt
                                 AND t.Nvt_Ndt IS NULL
                                 AND t.History_Status = 'A'
                                 AND NOT EXISTS
                                         (SELECT NULL
                                            FROM Sc_Verification v
                                           WHERE     v.Scv_Scv_Main =
                                                     p_Parent_Scv
                                                 AND v.Scv_Obj_Id = p_Scdi_Id
                                                 AND v.Scv_Obj_Tp = 'PI'
                                                 AND v.Scv_Nvt = t.Nvt_Id)
                          UNION ALL
                          --Верифікації по учаснику, що повязані з документами
                          SELECT d.Scpo_Id     AS Obj_Id,
                                 'PD'          AS Obj_Tp,
                                 NULL          AS Vf_Id,
                                 t.Nvt_Id,
                                 t.Nvt_Order,
                                 t.Nvt_Start_Cond,
                                 t.Nvt_Callback,
                                 t.Nvt_Is_Parallel,
                                 t.Nvt_Vf_Tp
                            FROM Sc_Pfu_Document d
                                 JOIN Uss_Ndi.v_Ndi_Verification_Type t
                                     ON     d.Scpo_Ndt = t.Nvt_Ndt
                                        AND t.Nvt_Nvt_Main = p_Parent_Nvt
                                        AND t.History_Status = 'A'
                           WHERE     d.Scpo_Scdi = p_Scdi_Id
                                 --Виключаємо вже створені верифікації на цьому рівні
                                 AND NOT EXISTS
                                         (SELECT NULL
                                            FROM Sc_Verification v
                                           WHERE     v.Scv_Scv_Main =
                                                     p_Parent_Scv
                                                 AND v.Scv_Obj_Id = d.Scpo_Id
                                                 AND v.Scv_Obj_Tp = 'PD'
                                                 AND v.Scv_Nvt = t.Nvt_Id))
                ORDER BY Nvt_Order)
        LOOP
            IF NOT Need_Start_Scv (
                       p_Nvt_Start_Cond   => Rec.Nvt_Start_Cond,
                       p_Scdi_Id          => p_Scdi_Id,
                       p_Scpo_Id          =>
                           CASE WHEN Rec.Obj_Tp = 'PD' THEN Rec.Obj_Id END)
            THEN
                Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                           'SCV',
                           p_Parent_Scv,
                           'Skip SCV by condition');
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
                Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                           'SCV',
                           p_Parent_Scv,
                           'Skip SCV by parallel overhead');
                RETURN;
            END IF;

            l_Scv_Id :=
                Get_Verification (p_Scv_Tp         => Rec.Nvt_Vf_Tp,
                                  p_Scv_Nvt        => Rec.Nvt_Id,
                                  p_Scv_Obj_Tp     => Rec.Obj_Tp,
                                  p_Scv_Obj_Id     => Rec.Obj_Id,
                                  p_Scv_Hs         => p_Hs,
                                  p_Scv_Scv_Main   => p_Parent_Scv);

            --Загулшка для встановлення статусу "Успішна верифікація" без відправки запити.
            --(для середовища розробки)
            SELECT NVL (MAX (v.Prm_Value), 'F')
              INTO l_Skip_Scv
              FROM Paramsperson v
             WHERE v.Prm_Code = 'SKIP_SCV_' || Rec.Nvt_Id;

            IF l_Skip_Scv = 'T'
            THEN
                Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                           'SCV',
                           p_Parent_Scv,
                           'Skip OK by settings');
                Set_Ok (l_Scv_Id, p_Scvl_Hs => p_Hs);
            END IF;

            --MAIN_PFU - підгрупи недоступні для верифікації проміжних даних ПФУ
            --AUTO_PFU - автоматична лише реєструється, виконуватися буде в іншій таймерній задачі
            IF Rec.Nvt_Vf_Tp = 'EZV_PFU'
            THEN
                IF l_Skip_Scv = 'F'
                THEN
                    --Реєструємо запит для перевірки документа
                    Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                               'SCV',
                               p_Parent_Scv,
                               'Start SCV EZV');
                    Register_Scv_Request (p_Scv_Id       => l_Scv_Id,
                                          p_Scv_Obj_Id   => Rec.Obj_Id,
                                          p_Hs           => p_Hs,
                                          p_Nvt_Id       => Rec.Nvt_Id);
                ELSE
                    Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                               'SCV',
                               p_Parent_Scv,
                               'Skip SCV EZV');
                END IF;
            END IF;

            SELECT Scv_St
              INTO l_Scv_St
              FROM Sc_Verification
             WHERE Scv_Id = l_Scv_Id;

            IF l_Scv_St <> 'R'
            THEN
                --Зупиняємо цикл створення верифікацій, томущо він вже був виконаний в процедурі встановлення статусу
                Tools.LOG ('Api$sc_Verification.Scdi_Verification',
                           'SCV',
                           p_Parent_Scv,
                           'Skip SCV process');
                RETURN;
            END IF;

            p_New_Scv_Cnt := NVL (p_New_Scv_Cnt, 0) + 1;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Шукаємо данні осіб із ПФУ які підлягають верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Collect_Scdi_For_Verification
    IS
        l_Hs   NUMBER;
    BEGIN
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        l_Hs := Tools.Gethistsession;

        FOR c
            IN (  SELECT Scdi_Id,
                         t.Nvt_Id,
                         t.Nvt_Start_Cond,
                         t.Nvt_Callback
                    FROM Sc_Pfu_Data_Ident Pi
                         JOIN Uss_Ndi.v_Ndi_Verification_Type t
                             ON     Nvt_Nvt_Main IS NULL
                                AND t.Nvt_Vf_Tp = 'MAIN_PFU'
                                AND t.History_Status = 'A'
                   WHERE Scdi_St = 'VR'
                ORDER BY Scdi_Id
                   FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                RETURN;
            END IF;

            --Пошук та прив'язка наших типів документів та типів атрибутів документів
            Api$sc_Verification_Pfu.Find_Scdi_Scpo (p_Scdi_Id => c.Scdi_Id);

            --Можливо верифікація не повинна запускатися (якщо про це вказано в правилах)
            IF NOT Need_Start_Scv (p_Nvt_Start_Cond   => c.Nvt_Start_Cond,
                                   p_Scdi_Id          => c.Scdi_Id)
            THEN
                Scv_Callback (p_Nvt_Callback   => c.Nvt_Callback,
                              p_Scv_Obj_Tp     => c_Scv_Obj_Tp_Pi,
                              p_Scv_Obj_Id     => c.Scdi_Id,
                              p_Scv_St         => c_Scv_St_Ok,
                              p_Scv_Id         => NULL);

                UPDATE Sc_Pfu_Data_Ident
                   SET Scdi_St = 'VO'
                 WHERE Scdi_Id = c.Scdi_Id;

                Api$sc_Verification_Pfu.Set_Scdi_Child_St (
                    p_Scdi_Id    => c.Scdi_Id,
                    p_Scdi_St    => 'VO',
                    p_Is_Force   => TRUE);
                COMMIT;
                CONTINUE;
            END IF;

            DECLARE
                l_Scv_Id            Sc_Verification.Scv_Id%TYPE;
                l_New_Scv_Cnt       NUMBER;
                l_Scv_Child_Count   NUMBER;
                l_Scv_St            VARCHAR2 (10);
            BEGIN
                --Блокуємо звернення на період автоматичної верифікації
                IF Lock_Scdi_For_Verification (p_Scdi_Id   => c.Scdi_Id,
                                               p_Nvt_Id    => c.Nvt_Id,
                                               p_Hs        => l_Hs,
                                               p_Scv_Id    => l_Scv_Id)
                THEN
                    --Виконуємо верифікацію даних особи із ПФУ
                    Scdi_Verification (p_Scdi_Id       => c.Scdi_Id,
                                       p_Parent_Scv    => l_Scv_Id,
                                       p_Parent_Nvt    => c.Nvt_Id,
                                       p_Hs            => l_Hs,
                                       p_New_Scv_Cnt   => l_New_Scv_Cnt);

                    SELECT COUNT (1)
                      INTO l_Scv_Child_Count
                      FROM Sc_Verification
                     WHERE Scv_Scv_Main = l_Scv_Id AND Scv_St = 'R';

                    IF l_Scv_Child_Count = 0
                    THEN
                        l_Scv_St :=
                            NVL (Calc_Parent_Scv_St (l_Scv_Id), c_Scv_St_Ok);
                        Tools.LOG (
                            'Api$sc_Verification.Collect_Scdi_For_Verification',
                            'SCV',
                            l_Scv_Id,
                            'No reg child:l_Scv_St=' || l_Scv_St);
                        Set_Scdi_Verification_Status (
                            p_Scv_Id          => l_Scv_Id,
                            p_Scv_St          => l_Scv_St,
                            p_Scv_Hs          => l_Hs,
                            p_Lock_Main_Scv   => FALSE);
                    END IF;

                    COMMIT;
                ELSE
                    ROLLBACK;
                END IF;
            END;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Виканання автоматичних верифікацій в БД
    -------------------------------------------------------------------------------
    PROCEDURE Execute_Scdi_Auto_Verifications
    IS
    BEGIN
        FOR Rec
            IN (  SELECT v.Scv_Obj_Tp,
                         v.Scv_Obj_Id,
                         v.Scv_Id,
                         t.Nvt_Callback
                    FROM Sc_Verification v
                         JOIN Uss_Ndi.v_Ndi_Verification_Type t
                             ON v.Scv_Nvt = t.Nvt_Id
                   WHERE v.Scv_St = 'R' AND v.Scv_Tp = 'AUTO_PFU'
                ORDER BY v.Scv_Start_Dt
                   FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                RETURN;
            END IF;

            Scv_Callback (p_Nvt_Callback   => Rec.Nvt_Callback,
                          p_Scv_Obj_Tp     => Rec.Scv_Obj_Tp,
                          p_Scv_Obj_Id     => Rec.Scv_Obj_Id,
                          p_Scv_St         => NULL,
                          p_Scv_Id         => Rec.Scv_Id);

            COMMIT;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    -- Розблокування звернення після верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Unlock_Scdi (p_Scdi_Id   IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
                           p_Scv_Id    IN Sc_Verification.Scv_Id%TYPE,
                           p_Scv_Nvt   IN Sc_Verification.Scv_Nvt%TYPE,
                           p_Scv_St    IN Sc_Verification.Scv_St%TYPE,
                           p_Scv_Hs    IN Sc_Verification.Scv_Hs%TYPE)
    IS
        l_Scdi_St   Sc_Pfu_Data_Ident.Scdi_St%TYPE;
    BEGIN
        Tools.LOG ('Api$sc_Verification.Unlock_Scdi',
                   'SCDI',
                   p_Scdi_Id,
                   'Start Unlock_Scdi');

           UPDATE Sc_Pfu_Data_Ident
              SET Scdi_St =
                      CASE p_Scv_St WHEN c_Scv_St_Ok THEN 'VO' ELSE 'VE' END
            WHERE Scdi_Id = p_Scdi_Id AND Scdi_St IN ('VW', 'VE')
        RETURNING Scdi_St
             INTO l_Scdi_St;

        Api$sc_Verification_Pfu.Set_Scdi_Child_St (p_Scdi_Id   => p_Scdi_Id,
                                                   p_Scdi_St   => l_Scdi_St);

        Tools.LOG ('Api$sc_Verification.Unlock_Scdi',
                   'SCDI',
                   p_Scdi_Id,
                   'p_Scv_Id=' || p_Scv_Id || '&l_Scdi_St=' || l_Scdi_St);

        IF p_Scv_Id IS NULL
        THEN
            RETURN;
        END IF;

        Tools.LOG ('Api$sc_Verification.Unlock_Scdi',
                   'SCDI',
                   p_Scdi_Id,
                   'Run callback. p_Scv_Nvt=' || p_Scv_Nvt);
        --Виконуємо зворотній виклик, що прописано в таблиці налаштувань для поточної верифікації
        Scv_Callback (p_Scv_Nvt      => p_Scv_Nvt,
                      p_Scv_Obj_Tp   => 'PI',
                      p_Scv_Obj_Id   => p_Scdi_Id,
                      p_Scv_St       => p_Scv_St,
                      p_Scv_Id       => p_Scv_Id);

        Write_Scv_Log (p_Scv_Id         => p_Scv_Id,
                       p_Scvl_Hs        => p_Scv_Hs,
                       p_Scvl_Tp        => c_Scvl_Tp_Done,
                       p_Scvl_Message   => CHR (38) || '4',
                       p_Scvl_St        => l_Scdi_St,
                       p_Scvl_St_Old    => NULL);

        Tools.LOG ('Api$sc_Verification.Unlock_Scdi',
                   'SCDI',
                   p_Scdi_Id,
                   'Finish Unlock_Scdi');
    EXCEPTION
        WHEN OTHERS
        THEN
            Write_Scv_Log (
                p_Scv_Id         => p_Scv_Id,
                p_Scvl_Hs        => p_Scv_Hs,
                p_Scvl_Tp        => c_Scvl_Tp_Terror,
                p_Scvl_Message   =>
                       'Unlock_Scdi Exception: '
                    || SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Scvl_St        => 'VW',
                p_Scvl_St_Old    => NULL);
    END;

    -------------------------------------------------------------------------------
    -- Завершення верифікацій звернень
    -------------------------------------------------------------------------------
    PROCEDURE Finish_Scdi_Verifications
    IS
        l_Hs   NUMBER;
    BEGIN
        Tools.LOG ('Api$sc_Verification.Finish_Scdi_Verifications',
                   'SCDI',
                   NULL,
                   'Start Finish_Scdi_Verifications');

        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            Tools.LOG ('Api$sc_Verification.Finish_Scdi_Verifications',
                       'SCDI',
                       NULL,
                       'Skip in main Finish_Scdi_Verifications');
            RETURN;
        END IF;

        l_Hs := Tools.Gethistsession ();

        FOR Rec IN (  SELECT a.Scdi_Id,
                             v.Scv_Obj_Tp,
                             v.Scv_Id,
                             v.Scv_Nvt,
                             v.Scv_St
                        FROM Sc_Pfu_Data_Ident a
                             JOIN Sc_Verification v
                                 ON     v.Scv_Obj_Tp = 'PI'
                                    AND v.Scv_Obj_Id = a.Scdi_Id
                                    AND v.Scv_Scv_Main IS NULL
                                    AND v.Scv_St <> 'R'
                                    AND v.Scv_Id =
                                        (SELECT MAX (V2.Scv_Id)
                                           FROM Sc_Verification V2
                                          WHERE     V2.Scv_Scv_Main IS NULL
                                                AND V2.Scv_Obj_Tp = 'PI'
                                                AND V2.Scv_Obj_Id = a.Scdi_Id)
                       WHERE a.Scdi_St = 'VW'
                    ORDER BY a.Scdi_Id
                       FETCH FIRST 300 ROWS ONLY)
        LOOP
            IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                           'IKIS_SYS') !=
               'FALSE'
            THEN
                Tools.LOG ('Api$sc_Verification.Finish_Scdi_Verifications',
                           'SCDI',
                           Rec.Scdi_Id,
                           'Skip in loop Finish_Scdi_Verifications');
                RETURN;
            END IF;

            Tools.LOG ('Api$sc_Verification.Finish_Scdi_Verifications',
                       'SCDI',
                       Rec.Scdi_Id,
                       'Scdi iteration');
            Unlock_Scdi (p_Scdi_Id   => Rec.Scdi_Id,
                         p_Scv_Id    => Rec.Scv_Id,
                         p_Scv_Nvt   => Rec.Scv_Nvt,
                         p_Scv_St    => Rec.Scv_St,
                         p_Scv_Hs    => l_Hs);
            COMMIT;
        END LOOP;

        Tools.LOG ('Api$sc_Verification.Finish_Scdi_Verifications',
                   'SCDI',
                   NULL,
                   'Finish Finish_Scdi_Verifications');
        COMMIT;
    END;

    -------------------------------------------------------------------------------
    -- Зміна статусу верифікації
    -------------------------------------------------------------------------------
    /*PROCEDURE Set_Scdi_Verification_Status(p_Scv_Id IN Sc_Verification.Scv_Id%TYPE,
                                           p_Scv_St IN Sc_Verification.Scv_St%TYPE,
                                           p_Scv_Hs IN Sc_Verification.Scv_Hs%TYPE) IS
    BEGIN
      Set_Verification_Status(p_Scv_Id => p_Scv_Id, p_Scv_St => p_Scv_St, p_Scv_Hs => p_Scv_Hs);
      Check_Scv_St(p_Scv_Id => p_Scv_Id);
    END;*/
    -------------------------------------------------------------------------------
    -- Зміна статусу верифікації
    -------------------------------------------------------------------------------
    PROCEDURE Set_Scdi_Verification_Status (
        p_Scv_Id          IN Sc_Verification.Scv_Id%TYPE,
        p_Scv_St          IN Sc_Verification.Scv_St%TYPE,
        p_Scv_Hs          IN Sc_Verification.Scv_Hs%TYPE,
        p_Lock_Main_Scv   IN BOOLEAN DEFAULT TRUE)
    IS
        l_Is_Ended               NUMBER := 0;
        l_Parent_Nvt             Uss_Ndi.v_Ndi_Verification_Type.Nvt_Nvt_Main%TYPE;
        l_Scv_Scv_Main           Sc_Verification.Scv_Scv_Main%TYPE;
        l_Scv_Nvt                Sc_Verification.Scv_Nvt%TYPE;
        l_Scv_Tp                 Sc_Verification.Scv_Tp%TYPE;
        l_Scv_Obj_Tp             Sc_Verification.Scv_Obj_Tp%TYPE;
        l_Scv_Obj_Id             Sc_Verification.Scv_Obj_Id%TYPE;
        l_Lock_Handle            Tools.t_Lockhandler;
        l_Scv_Cnt                NUMBER;
        l_Scv_Ok_Cnt             NUMBER;
        l_Scv_Err_Cnt            NUMBER;
        l_Scv_Not_Verified_Cnt   NUMBER;
        l_Level                  NUMBER;
        l_Scdi_Id                NUMBER;
        l_New_Scv_Cnt            NUMBER;
        l_Parent_Scv_St          Sc_Verification.Scv_St%TYPE;
    BEGIN
        Tools.LOG ('Api$sc_Verification.Set_Scdi_Verification_Status',
                   'SCV',
                   p_Scv_Id,
                   'p_Scv_Id=' || p_Scv_Id || '&p_Scv_St=' || p_Scv_St);

        l_Is_Ended :=
            CASE
                WHEN p_Scv_St IN
                         (c_Scv_St_Ok, c_Scv_St_Error, c_Scv_St_Not_Verified)
                THEN
                    1
            END;

           UPDATE Sc_Verification v
              SET v.Scv_St = p_Scv_St,
                  v.Scv_Stop_Dt =
                      CASE
                          WHEN l_Is_Ended = 1 THEN NVL (v.Scv_Stop_Dt, SYSDATE)
                      END,
                  v.Scv_Hs = NVL (p_Scv_Hs, v.Scv_Hs)
            WHERE v.Scv_Id = p_Scv_Id
        RETURNING v.Scv_Scv_Main,
                  v.Scv_Nvt,
                  v.Scv_Tp,
                  v.Scv_Obj_Tp,
                  v.Scv_Obj_Id
             INTO l_Scv_Scv_Main,
                  l_Scv_Nvt,
                  l_Scv_Tp,
                  l_Scv_Obj_Tp,
                  l_Scv_Obj_Id;

        IF l_Is_Ended <> 1
        THEN
            RETURN;
        END IF;

        --P.S. Кореневий(MAIN_PFU) зворотній виклик запускається в Unlock_Scdi
        IF     l_Scv_Tp <> 'AUTO_PFU'
           AND NOT (l_Scv_Tp = 'MAIN_PFU' AND l_Scv_Scv_Main IS NULL)
        THEN
            --Виконуємо зворотній виклик, що прописано в таблиці налаштувань для поточної верифікації
            Scv_Callback (p_Scv_Nvt      => l_Scv_Nvt,
                          p_Scv_Obj_Tp   => l_Scv_Obj_Tp,
                          p_Scv_Obj_Id   => l_Scv_Obj_Id,
                          p_Scv_St       => p_Scv_St,
                          p_Scv_Id       => p_Scv_Id);
        END IF;

        IF l_Scv_Scv_Main IS NOT NULL
        THEN
            IF p_Lock_Main_Scv
            THEN
                BEGIN
                    --Блокуємо сутність що верифікується
                    Ikis_Sys.Ikis_Lock.Request_Lock (
                        p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                        p_Var_Name            => 'SCV' || l_Scv_Scv_Main,
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
            SELECT COUNT (*)    AS Cnt,
                   NVL (
                       SUM (
                           CASE WHEN v.Scv_St = c_Scv_St_Ok THEN 1 ELSE 0 END),
                       0)       Ok_Cnt,
                   NVL (
                       SUM (
                           CASE
                               WHEN v.Scv_St = c_Scv_St_Error THEN 1
                               ELSE 0
                           END),
                       0)       Err_Cnt,
                   NVL (
                       SUM (
                           CASE
                               WHEN v.Scv_St = c_Scv_St_Not_Verified THEN 1
                               ELSE 0
                           END),
                       0)       Not_Verified_Cnt
              INTO l_Scv_Cnt,
                   l_Scv_Ok_Cnt,
                   l_Scv_Err_Cnt,
                   l_Scv_Not_Verified_Cnt
              FROM Sc_Verification v
             WHERE v.Scv_Scv_Main = l_Scv_Scv_Main;


                --Визначаємо поточний рівень ієрархії
                --(віднімаємо 1, щоб не враховувати кореневий рівень)
                SELECT MAX (LEVEL) - 1
                  INTO l_Level
                  FROM Uss_Ndi.v_Ndi_Verification_Type t
                 WHERE t.Nvt_Id = l_Scv_Nvt
            CONNECT BY PRIOR t.Nvt_Id = t.Nvt_Nvt_Main;

            --Запуск наступних в ланцюжку верифікацій відбувається лише за умови,
            --якщо всі існуючі верифікації на цьому рівні ієрархії завершено успішно
            IF                                 /*l_Scv_Ok_Cnt = l_Vf_Cnt AND*/
               l_Level > 0
            THEN
                IF l_Scv_Obj_Tp = 'PD'
                THEN
                    --Визначаємо ІД учасника звернення
                    SELECT d.Scpo_Scdi
                      INTO l_Scdi_Id
                      FROM Sc_Pfu_Document d
                     WHERE d.Scpo_Id = l_Scv_Obj_Id;
                ELSIF l_Scv_Obj_Tp = 'PI'
                THEN
                    l_Scdi_Id := l_Scv_Obj_Id;
                END IF;

                --Визначаємо ІД батьківського типу верифікації
                SELECT t.Nvt_Nvt_Main
                  INTO l_Parent_Nvt
                  FROM Uss_Ndi.v_Ndi_Verification_Type t
                 WHERE t.Nvt_Id = l_Scv_Nvt;

                --Продовжуємо ланцюжок верифікацій(за умови наявності відповідних налаштувань в Ndi_Verification_Type)
                Scdi_Verification (p_Scdi_Id       => l_Scdi_Id,
                                   p_Parent_Scv    => l_Scv_Scv_Main,
                                   p_Parent_Nvt    => l_Parent_Nvt,
                                   p_Hs            => p_Scv_Hs,
                                   p_New_Scv_Cnt   => l_New_Scv_Cnt);
            END IF;

            --Якщо всі верифікації на цьому рівні завершено успішно,
            --або хочаб одна з верифікацій завершилась помилкою -
            --змінюємо статус верифікації рівнем вищче
            IF     NVL (l_New_Scv_Cnt, 0) = 0
               AND (l_Scv_Cnt =
                    l_Scv_Ok_Cnt + l_Scv_Err_Cnt + l_Scv_Not_Verified_Cnt)
            THEN
                --Розраховуємо статус батьківської верифікації
                l_Parent_Scv_St := Calc_Parent_Scv_St (l_Scv_Scv_Main);

                Set_Scdi_Verification_Status (
                    p_Scv_Id          => l_Scv_Scv_Main,
                    p_Scv_St          => l_Parent_Scv_St,
                    p_Scv_Hs          => p_Scv_Hs,
                    p_Lock_Main_Scv   => p_Lock_Main_Scv);
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --       Розрахунок статусу батьківської верифікації верифікації
    -------------------------------------------------------------------------------
    FUNCTION Calc_Parent_Scv_St (p_Parent_Scv_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Scdi_Id         NUMBER;
        l_Parent_Scv_St   VARCHAR2 (10);
    BEGIN
            --Визначаємо ІД даних особи
            SELECT MAX (v.Scv_Obj_Id)
              INTO l_Scdi_Id
              FROM Uss_Person.Sc_Verification v
                   JOIN Uss_Ndi.v_Ndi_Verification_Type t ON v.Scv_Nvt = t.Nvt_Id
             WHERE v.Scv_Obj_Tp = 'PI'
        START WITH v.Scv_Id = p_Parent_Scv_Id
        CONNECT BY PRIOR v.Scv_Scv_Main = v.Scv_Id;

            --Визначаємо статус
            SELECT MIN (
                       Api$sc_Verification.Calc_Scv_St (t.Nvt_Skip_Cond,
                                                        l_Scdi_Id,
                                                        v.Scv_St))
              INTO l_Parent_Scv_St
              FROM Uss_Person.Sc_Verification v
                   JOIN Uss_Ndi.v_Ndi_Verification_Type t ON v.Scv_Nvt = t.Nvt_Id
             WHERE v.Scv_Id <> p_Parent_Scv_Id
        START WITH v.Scv_Id = p_Parent_Scv_Id
        CONNECT BY PRIOR v.Scv_Id = v.Scv_Scv_Main;

        RETURN l_Parent_Scv_St;
    END;

    -------------------------------------------------------------------------------
    -- Розрахунок статусу верифікації
    -- з урахуванням умови, яку вказано в конфігурації
    -------------------------------------------------------------------------------
    FUNCTION Calc_Scv_St (p_Nvt_Skip_Cond   IN VARCHAR2,
                          p_Scdi_Id         IN NUMBER,
                          p_Scv_St          IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Expression   VARCHAR2 (4000);
        l_Skip         BOOLEAN;
    BEGIN
        IF p_Nvt_Skip_Cond IS NULL
        THEN
            RETURN p_Scv_St;
        END IF;

        l_Expression :=
            REGEXP_REPLACE (p_Nvt_Skip_Cond,
                            ':Scdi',
                            p_Scdi_Id,
                            1,
                            0,
                            'i');
        l_Expression :=
            REGEXP_REPLACE (l_Expression,
                            ':Scv_St',
                            q'[']' || p_Scv_St || q'[']',
                            1,
                            0,
                            'i');
        l_Expression := 'BEGIN :p_skip := ' || l_Expression || '; END;';

        EXECUTE IMMEDIATE l_Expression
            USING OUT l_Skip;


        RETURN CASE WHEN l_Skip THEN c_Scv_St_Ok ELSE p_Scv_St END;
    END;
END Api$sc_Verification;
/