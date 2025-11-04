/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT
IS
    -- Author  : SHOSTAK
    -- Created : 15.09.2023 10:10:06 AM
    -- Purpose :

    Pkg   VARCHAR2 (50) := 'CMES$ACT';

    TYPE r_Act_Info IS RECORD
    (
        At_Id    NUMBER,
        At_St    VARCHAR2 (10)
    );

    TYPE t_At_List IS TABLE OF r_Act_Info;

    FUNCTION Check_Act_Access_Pr (p_At_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Check_Act_Access_Cm (p_At_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Check_Act_Access_Cm (p_At_Id IN NUMBER);

    FUNCTION Check_Act_Access (p_At_Id IN NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Set_Signed_Cm (p_At_Id          NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Cm (p_At_Id          NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Tablet_Sign (p_At_Id    IN NUMBER,
                               p_Atd_Id   IN NUMBER,
                               p_Atp_Id   IN NUMBER);

    PROCEDURE Set_All_Signed_Rc (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Atd_Dh (p_Atd_Id           IN NUMBER,
                          p_Atd_Dh           IN NUMBER,
                          p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO');

    PROCEDURE Set_Atd_Source (p_Atd_Id           IN NUMBER,
                              p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO');

    PROCEDURE Set_Cm (p_At_Id IN NUMBER, p_At_Cu IN NUMBER);

    PROCEDURE Get_Act_Documents (p_At_Id            IN     NUMBER,
                                 p_Docs_Cur            OUT SYS_REFCURSOR,
                                 p_Docs_Files_Cur      OUT SYS_REFCURSOR);

    -- лог по рішенню
    PROCEDURE GET_ACT_LOG (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    PROCEDURE Get_Sign_Info_Doc (p_At_Id    IN     NUMBER,
                                 p_Atp_Id   IN     NUMBER,
                                 p_Atd_Id      OUT NUMBER,
                                 p_Doc_Id      OUT NUMBER);

    PROCEDURE Get_Tablet_Sign (p_At_Id        IN     NUMBER,
                               p_Atp_id       IN     NUMBER,
                               -- p_Atd_Dh    OUT NUMBER,
                               p_Sign_Code       OUT VARCHAR2,
                               p_Photo_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    FUNCTION Get_Form_Ndt (p_at_tp IN ACT.AT_TP%TYPE)
        RETURN NUMBER;

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

    FUNCTION Get_Decline_Reason (p_at_id IN NUMBER)
        RETURN VARCHAR2;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Signs (p_At_Id IN NUMBER, res_cur OUT SYS_REFCURSOR);


    PROCEDURE Set_Cm_Execute (p_At_Id IN NUMBER, p_At_Cu IN NUMBER);

    PROCEDURE Log_Tmp_work_Ids_Amnt (p_src              IN VARCHAR2,
                                     p_obj_tp           IN VARCHAR2,
                                     p_obj_id           IN NUMBER,
                                     p_regular_params   IN VARCHAR2);

    FUNCTION Compare_Atp_App_Tp_On_Save (
        p_At_Id     IN            NUMBER,
        p_Persons   IN OUT NOCOPY Api$act.t_At_Persons)
        RETURN NUMBER;

    FUNCTION Compare_Atp_App_Tp (p_At_Id_1 IN NUMBER, p_At_Id_2 IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Set_Sign_Code (p_at_id IN NUMBER, p_sign_code IN VARCHAR2);
END Cmes$act;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:18 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    -----------------------------------------------------------
    -- ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО АКТУ У КОРИСТУВАЧА НСП
    -----------------------------------------------------------
    FUNCTION Check_Act_Access_Pr (p_At_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_At_Rnspm   NUMBER;
    BEGIN
        --Отримуємо ід надавача вказаного в акті
        SELECT a.At_Rnspm
          INTO l_At_Rnspm
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        RETURN Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => l_At_Rnspm,
                   p_Cr_Code         => 'NSP_SPEC');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО АКТУ У КОРИСТУВАЧА КМа
    -----------------------------------------------------------
    FUNCTION Check_Act_Access_Cm (p_At_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Id   NUMBER;
        l_At_Cu   NUMBER;
    BEGIN
        SELECT a.At_Cu
          INTO l_At_Cu
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        Tools.LOG (
            p_src      => UPPER ('USS_ESR.CMES$ACT.Check_Act_Access_Cm'),
            p_obj_tp   => 'ACT',
            p_obj_id   => p_At_Id,
            p_regular_params   =>
                'l_At_Cu=' || l_Cu_Id || ' l_Cu_Id=' || l_Cu_Id,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        RETURN NVL (l_Cu_Id = l_At_Cu, FALSE);
    END;

    PROCEDURE Check_Act_Access_Cm (p_At_Id IN NUMBER)
    IS
    BEGIN
        IF NOT Cmes$act.Check_Act_Access_Cm (p_At_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Скасування може виконувати лише кейс-менеджер, який веде випадок');
        END IF;
    END;



    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    FUNCTION Check_Act_Access (p_At_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Id        NUMBER;
        l_Cu_Sc        NUMBER;
        l_At_Cu        NUMBER;
        l_At_Rnspm     NUMBER;
        l_At_Sc        NUMBER;
        l_At_Ap        NUMBER;
        l_Is_Allowed   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Cu,
               a.At_Rnspm,
               a.At_Sc,
               a.At_Ap
          INTO l_At_Cu,
               l_At_Rnspm,
               l_At_Sc,
               l_At_Ap
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Дозволено доступ до акту, якщо його закріплено за поточним користувачем
        IF l_At_Cu = l_Cu_Id
        THEN
            RETURN TRUE;
        END IF;

        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        --Дозволено доступ до акту, якщо поточний користувач є отримувачем СП
        IF l_At_Sc = l_Cu_Sc
        THEN
            RETURN TRUE;
        END IF;

        --Дозволено доступ до акту, якщо поточний користувач має роль "Уповноважений спеціаліст" в кабінеті надавача за яким закріплено акт
        IF    Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                  p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                  p_Cu_Id           => l_Cu_Id,
                  p_Cmes_Owner_Id   => l_At_Rnspm,
                  p_Cr_Code         => 'NSP_SPEC')
           OR Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                  p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                  p_Cu_Id           => l_Cu_Id,
                  p_Cmes_Owner_Id   => l_At_Rnspm,
                  p_Cr_Code         => 'NSP_ADM')
        THEN
            RETURN TRUE;
        END IF;

        --Дозволено доступ до акту, якщо поточний користувач присутній серед підписантів акту
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM At_Signers s
         WHERE     s.Ati_At = p_At_Id
               AND s.Ati_Sc = l_Cu_Sc
               AND s.History_Status = 'A';

        IF l_Is_Allowed = 1
        THEN
            RETURN TRUE;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM Ap_Person p JOIN Appeal a ON p.App_Ap = a.Ap_Id
         WHERE     p.App_Ap = l_At_Ap
               AND p.App_Sc = l_Cu_Sc
               AND p.App_Tp = 'Z'
               AND p.History_Status = 'A'
               AND NVL (a.Ap_Sub_Tp, '-') <> 'SC';

        IF l_Is_Allowed = 1
        THEN
            RETURN TRUE;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM At_Person p
         WHERE     p.Atp_At = p_At_Id
               AND p.History_Status = 'A'
               AND p.Atp_Sc = l_Cu_Sc
               AND p.Atp_App_Tp IN ('Z', 'OS');

        IF l_Is_Allowed = 1
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        IF NOT Check_Act_Access (p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;
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
            IN (SELECT                                                /*At.**/
                       At.At_Id
                  FROM Uss_Doc.v_Files  f
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON f.File_Id IN (a.Dat_File, a.Dat_Sign_File)
                       JOIN At_Document d ON a.Dat_Dh = d.Atd_Dh
                       JOIN Act At ON d.Atd_At = At.At_Id
                 WHERE f.File_Code = p_File_Code)
        LOOP
            IF Check_Act_Access (Rec.At_Id)
            THEN
                RETURN 'T';
            END IF;
        END LOOP;

        RETURN 'F';
    END;

    PROCEDURE Merge_Signer (p_At_Id       IN NUMBER,
                            p_Ati_Tp      IN VARCHAR2,
                            p_Cu_Id       IN NUMBER,
                            p_Ndt_Id      IN NUMBER,
                            p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Atd_Id   NUMBER;
        l_Ndt_Id   NUMBER;
        l_Ati_Id   NUMBER;
    BEGIN
        l_Ndt_Id :=
            COALESCE (p_Ndt_Id, Api$act.Define_Print_Form_Ndt (p_At_Id));
        l_Atd_Id :=
            Api$act.Get_Atd_Id (p_At_Id => p_At_Id, p_Atd_Ndt => l_Ndt_Id);

        IF l_Atd_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не сформовано друковану форму');
            NULL;
        END IF;

        Api$act.Can_Sign (p_At_Id    => p_At_Id,
                          p_Atd_Id   => l_Atd_Id,
                          p_Ati_Tp   => p_Ati_Tp);

        SELECT MAX (Ati_Id)
          INTO l_Ati_Id
          FROM (  SELECT s.Ati_Id
                    FROM At_Signers s
                   WHERE     s.Ati_At = p_At_Id
                         AND s.Ati_Tp = p_Ati_Tp
                         AND s.History_Status = 'A'
                         AND s.Ati_Is_Signed = 'F'
                         AND (s.Ati_Cu = p_Cu_Id OR s.Ati_Cu IS NULL)
                ORDER BY CASE --Якщо КМ явно вказаний в якості підписанта
                              WHEN s.Ati_Cu = p_Cu_Id THEN 1 ELSE 2 END
                   FETCH FIRST ROW ONLY);

        --Для КМа виконуємо MERGE, томущо КМ не вказує сам себе у якості підписанта
        IF l_Ati_Id IS NULL
        THEN
            INSERT INTO At_Signers (Ati_Id,
                                    Ati_At,
                                    Ati_Atd,
                                    Ati_Sign_Dt,
                                    Ati_Is_Signed,
                                    History_Status,
                                    Ati_Cu,
                                    Ati_Tp,
                                    ati_sign_code)
                 VALUES (0,
                         p_At_Id,
                         l_Atd_Id,
                         SYSDATE,
                         'T',
                         'A',
                         p_Cu_Id,
                         p_Ati_Tp,
                         p_file_code)
              RETURNING Ati_Id
                   INTO l_Ati_Id;
        ELSE
            UPDATE At_Signers s
               SET s.Ati_Sign_Dt = SYSDATE,
                   s.Ati_Is_Signed = 'T',
                   s.Ati_Cu = p_Cu_Id,
                   s.Ati_Atd = l_Atd_Id,
                   s.ati_sign_code = p_file_code
             WHERE s.Ati_Id = l_Ati_Id;
        END IF;

        UPDATE At_Signers s
           SET s.History_Status = 'H'
         WHERE     s.Ati_Atd = l_Atd_Id
               AND s.Ati_Cu = p_Cu_Id
               AND s.ati_tp = p_Ati_Tp
               AND s.History_Status = 'A'
               AND s.Ati_Id <> l_Ati_Id;
    END;

    PROCEDURE Merge_Signer (p_At_Id       IN NUMBER,
                            p_Atd_Id      IN NUMBER,
                            p_Ati_Tp      IN VARCHAR2,
                            p_Cu_Id       IN NUMBER,
                            p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ati_Id   NUMBER;
    BEGIN
        Api$act.Can_Sign (p_At_Id    => p_At_Id,
                          p_Atd_Id   => p_Atd_Id,
                          p_Ati_Tp   => p_Ati_Tp);

        SELECT MAX (Ati_Id)
          INTO l_Ati_Id
          FROM (  SELECT s.Ati_Id
                    FROM At_Signers s
                   WHERE     s.Ati_Atd = p_Atd_Id
                         AND s.Ati_Tp = p_Ati_Tp
                         AND s.History_Status = 'A'
                         AND s.Ati_Is_Signed = 'F'
                         AND (s.Ati_Cu = p_Cu_Id OR s.Ati_Cu IS NULL)
                ORDER BY CASE --Якщо КМ явно вказаний в якості підписанта
                              WHEN s.Ati_Cu = p_Cu_Id THEN 1 ELSE 2 END
                   FETCH FIRST ROW ONLY);

        --Для КМа виконуємо MERGE, томущо КМ не вказує сам себе у якості підписанта
        IF l_Ati_Id IS NULL
        THEN
            INSERT INTO At_Signers (Ati_Id,
                                    Ati_At,
                                    Ati_Atd,
                                    Ati_Sign_Dt,
                                    Ati_Is_Signed,
                                    History_Status,
                                    Ati_Cu,
                                    Ati_Tp,
                                    ati_sign_code)
                 VALUES (0,
                         p_At_Id,
                         p_Atd_Id,
                         SYSDATE,
                         'T',
                         'A',
                         p_Cu_Id,
                         p_Ati_Tp,
                         p_file_code)
              RETURNING Ati_Id
                   INTO l_Ati_Id;
        ELSE
            UPDATE At_Signers s
               SET s.Ati_Sign_Dt = SYSDATE,
                   s.Ati_Is_Signed = 'T',
                   s.Ati_Cu = p_Cu_Id,
                   s.ati_sign_code = p_file_code
             WHERE s.Ati_Id = l_Ati_Id;
        END IF;

        --Видаляємо інформацію про попередні підписи документа цим же користувачем
        UPDATE At_Signers s
           SET s.History_Status = 'H'
         WHERE     s.Ati_Atd = p_Atd_Id
               AND s.Ati_Cu = p_Cu_Id
               AND s.ati_tp = p_Ati_Tp
               AND s.History_Status = 'A'
               AND s.Ati_Id <> l_Ati_Id;
    END;

    PROCEDURE Update_Signer (p_At_Id       IN NUMBER,
                             p_Ati_Tp      IN VARCHAR2,
                             p_Ati_Sc      IN NUMBER,
                             p_Cu_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ati_Id        NUMBER;
        l_Ati_Order     NUMBER;
        l_Ndt_Id        NUMBER;
        l_Atd_Id        NUMBER;
        l_Next_Ati_Sc   NUMBER;
    BEGIN
        --Шукаємо підписанта по Ід соцкратки поточного користувача
        SELECT MAX (s.Ati_Id), MAX (s.Ati_Order)
          INTO l_Ati_Id, l_Ati_Order
          FROM At_Signers s
         WHERE     s.Ati_At = p_At_Id
               AND s.Ati_Tp = p_Ati_Tp
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Sc = p_Ati_Sc;

        IF l_Ati_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Підписання не потребується');
        END IF;

        l_Ndt_Id :=
            COALESCE (p_Ndt_Id, Api$act.Define_Print_Form_Ndt (p_At_Id));
        l_Atd_Id :=
            Api$act.Get_Atd_Id (p_At_Id => p_At_Id, p_Atd_Ndt => l_Ndt_Id);

        Api$act.Can_Sign (p_At_Id    => p_At_Id,
                          p_Atd_Id   => l_Atd_Id,
                          p_Ati_Tp   => p_Ati_Tp);

          --Визначаємо
          --чи є підписанти-отримувачі які мають менший порядковий номер, але поки не підписали
          SELECT MAX (s.Ati_Sc)
            INTO l_Next_Ati_Sc
            FROM At_Signers s
           WHERE     s.Ati_At = p_At_Id
                 AND s.Ati_Tp = p_Ati_Tp
                 AND s.Ati_Is_Signed = 'F'
                 AND s.History_Status = 'A'
                 AND s.Ati_Order < l_Ati_Order
        ORDER BY s.Ati_Order;

        IF l_Next_Ati_Sc IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Порушено порядок підписання. Очікується підпис '
                || Uss_Person.Api$sc_Tools.Get_Pib (l_Next_Ati_Sc));
        END IF;

        UPDATE At_Signers s
           SET s.Ati_Sign_Dt = SYSDATE,
               s.Ati_Is_Signed = 'T',
               s.Ati_Cu = p_Cu_Id,
               s.Ati_Atd = l_Atd_Id,
               s.ati_sign_code = p_file_code
         WHERE s.Ati_Id = l_Ati_Id;
    END;

    PROCEDURE Update_Signer (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_Ati_Tp      IN VARCHAR2,
                             p_Ati_Sc      IN NUMBER,
                             p_Cu_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ati_Id        NUMBER;
        l_Ati_Order     NUMBER;
        l_Next_Ati_Sc   NUMBER;
    BEGIN
        --Шукаємо підписанта по Ід соцкратки поточного користувача
        SELECT MAX (s.Ati_Id), MAX (s.Ati_Order)
          INTO l_Ati_Id, l_Ati_Order
          FROM At_Signers s
         WHERE     s.Ati_Atd = p_Atd_Id
               AND s.Ati_Tp = p_Ati_Tp
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Sc = p_Ati_Sc;

        IF l_Ati_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Підписання не потребується');
        END IF;

        Api$act.Can_Sign (p_At_Id    => p_At_Id,
                          p_Atd_Id   => p_Atd_Id,
                          p_Ati_Tp   => p_Ati_Tp);

          --Визначаємо
          --чи є підписанти-отримувачі які мають менший порядковий номер, але поки не підписали
          SELECT MAX (s.Ati_Sc)
            INTO l_Next_Ati_Sc
            FROM At_Signers s
           WHERE     s.Ati_Atd = p_Atd_Id
                 AND s.Ati_Tp = p_Ati_Tp
                 AND s.Ati_Is_Signed = 'F'
                 AND s.History_Status = 'A'
                 AND s.Ati_Order < l_Ati_Order
        ORDER BY s.Ati_Order;

        IF l_Next_Ati_Sc IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Порушено порядок підписання. Очікується підпис '
                || Uss_Person.Api$sc_Tools.Get_Pib (l_Next_Ati_Sc));
        END IF;

        UPDATE At_Signers s
           SET s.Ati_Sign_Dt = SYSDATE,
               s.Ati_Is_Signed = 'T',
               s.Ati_Cu = p_Cu_Id,
               s.ati_sign_code = p_file_code
         WHERE s.Ati_Id = l_Ati_Id;
    END;

    PROCEDURE Update_Signer (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_Ati_Tp      IN VARCHAR2,
                             p_Atp_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ati_Id        NUMBER;
        l_Ati_Order     NUMBER;
        l_Next_Ati_Sc   NUMBER;
    BEGIN
        --Шукаємо підписанта по Ід соцкратки поточного користувача
        SELECT MAX (s.Ati_Id), MAX (s.Ati_Order)
          INTO l_Ati_Id, l_Ati_Order
          FROM At_Signers s
         WHERE     1 = 1
               --and s.Ati_Atd = p_Atd_Id
               AND s.Ati_Tp = p_Ati_Tp
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Atp = p_Atp_Id
               AND s.ati_at = p_At_Id;

        IF l_Ati_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Підписання не потребується');
        END IF;

        --Api$act.Can_Sign(p_At_Id => p_At_Id, p_Atd_Id => p_Atd_Id, p_Ati_Tp => p_Ati_Tp);

        /*--Визначаємо
        --чи є підписанти-отримувачі які мають менший порядковий номер, але поки не підписали
        SELECT MAX(s.Ati_Sc)
          INTO l_Next_Ati_Sc
          FROM At_Signers s
         WHERE s.Ati_Atd = p_Atd_Id
           AND s.Ati_Tp = p_Ati_Tp
           AND s.Ati_Is_Signed = 'F'
           AND s.History_Status = 'A'
           AND s.Ati_Order < l_Ati_Order
         ORDER BY s.Ati_Order;

        IF l_Next_Ati_Sc IS NOT NULL THEN
          Raise_Application_Error(-20000,
                                  'Порушено порядок підписання. Очікується підпис ' || Uss_Person.Api$sc_Tools.Get_Pib(l_Next_Ati_Sc));
        END IF;*/

        UPDATE At_Signers s
           SET s.Ati_Sign_Dt = SYSDATE,
               s.Ati_Is_Signed = 'T',
               s.ati_sign_code = p_file_code,
               s.ati_atd = p_Atd_Id
         WHERE s.Ati_Id = l_Ati_Id;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМа
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність лише однієї друк. форми.
    -- Якщо не вказати p_Ndt_Id, тип документу буде
    -- визначатись по налаштуванням Ndi_At_Print_Config
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id          NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
        l_At_Cu   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Cu
          INTO l_At_Cu
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
        THEN
            Raise_Application_Error (
                -20000,
                'Підписання може здійснювати лише кейс-менеджер, який веде випадок');
            NULL;
        END IF;

        --Для КМа виконуємо MERGE, томущо КМ МОЖЕ не вказувати сам себе у якості підписанта
        Merge_Signer (p_At_Id       => p_At_Id,
                      p_Ati_Tp      => 'CM',
                      p_Cu_Id       => l_At_Cu,
                      p_Ndt_Id      => p_Ndt_Id,
                      p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМа
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність декількох друк. форм одночасно
    -- В такому випадку потрібно створювати документи на
    -- етапі збереження проекту акту(до побудови друк. форми).
    -- (поки не використовується)
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id          NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
        l_At_Cu   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Cu
          INTO l_At_Cu
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
        THEN
            Raise_Application_Error (
                -20000,
                'Підписання може здійснювати лише кейс-менеджер, який веде випадок');
        END IF;

        --Для КМа виконуємо MERGE, томущо КМ МОЖЕ не вказувати сам себе у якості підписанта
        Merge_Signer (p_At_Id       => p_At_Id,
                      p_Atd_Id      => p_Atd_Id,
                      p_Ati_Tp      => 'CM',
                      p_Cu_Id       => l_At_Cu,
                      p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність лише однієї друк. форми.
    -- Якщо не вказати p_Ndt_Id, тип документу буде
    -- визначатись по налаштуванням Ndi_At_Print_Config
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        Update_Signer (p_At_Id       => p_At_Id,
                       p_Ndt_Id      => p_Ndt_Id,
                       p_Ati_Tp      => 'RC',
                       p_Ati_Sc      => l_Cu_Sc,
                       p_Cu_Id       => l_Cu_Id,
                       p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність декількох друк. форм одночасно
    -- В такому випадку потрібно створювати документи на
    -- етапі збереження проекту акту(до побудови друк. форми).
    -- (поки не використовується)
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
        l_Cu_Sc   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (l_Cu_Id);

        Update_Signer (p_At_Id       => p_At_Id,
                       p_Atd_Id      => p_Atd_Id,
                       p_Ati_Tp      => 'RC',
                       p_Ati_Sc      => l_Cu_Sc,
                       p_Cu_Id       => l_Cu_Id,
                       p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП з допомогою планшету
    -----------------------------------------------------------
    PROCEDURE Set_Tablet_Sign (p_At_Id    IN NUMBER,
                               p_Atd_Id   IN NUMBER,
                               p_Atp_Id   IN NUMBER)
    IS
    BEGIN
        Update_Signer (p_At_Id    => p_At_Id,
                       p_Atd_Id   => p_Atd_Id,
                       p_Ati_Tp   => 'RC',
                       p_Atp_Id   => p_Atp_Id);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ всіх ОСП письмово
    -----------------------------------------------------------
    PROCEDURE Set_All_Signed_Rc (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
    IS
        l_Atd_Id   NUMBER;
    BEGIN
        l_Atd_Id :=
            Api$act.Get_Atd_Id (p_At_Id => p_At_Id, p_Atd_Ndt => p_Ndt_Id);

        FOR xx
            IN (SELECT *
                  FROM At_Signers t
                 WHERE     t.ati_at = p_At_Id
                       AND t.ati_atd = l_atd_id
                       AND t.history_status = 'A'
                       AND t.ati_tp = 'RC')
        LOOP
            Update_Signer (p_At_Id    => p_At_Id,
                           p_Atd_Id   => l_Atd_Id,
                           p_Ati_Tp   => 'RC',
                           p_Atp_Id   => xx.ati_atp);
        END LOOP;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність лише однієї друк. форми.
    -- Якщо не вказати p_Ndt_Id, тип документу буде
    -- визначатись по налаштуванням Ndi_At_Print_Config
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_Ndt_Id      IN NUMBER DEFAULT NULL,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id      NUMBER;
        l_At_Rnspm   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Rnspm
          INTO l_At_Rnspm
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cu_Id           => l_Cu_Id,
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => l_At_Rnspm,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Raise_Application_Error (
                -20000,
                'Підписання може здійснювати лише уповноважений спеціаліст надавача соціальних послуг');
        --null;
        END IF;

        --Для НСП виконуємо MERGE, томущо КМ МОЖЕ не вказати його у якості підписанта
        --на етапі збереження проекту(залежить від типу акту)
        Merge_Signer (p_At_Id       => p_At_Id,
                      p_Ati_Tp      => 'PR',
                      p_Cu_Id       => l_Cu_Id,
                      p_Ndt_Id      => p_Ndt_Id,
                      p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -- Використовувати у разі, якщо в акті передбачено
    -- наявність декількох друк. форм одночасно
    -- В такому випадку потрібно створювати документи на
    -- етапі збереження проекту акту(до побудови друк. форми).
    -- (поки не використовується)
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_Atd_Id      IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id      NUMBER;
        l_At_Rnspm   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Rnspm
          INTO l_At_Rnspm
          FROM Act a
         WHERE a.At_Id = p_At_Id;


        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cu_Id           => l_Cu_Id,
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => l_At_Rnspm,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            Raise_Application_Error (
                -20000,
                'Підписання може здійснювати лише уповноважений спеціаліст надавача соціальних послуг');
        --null;
        END IF;

        --Для НСП виконуємо MERGE, томущо КМ МОЖЕ не вказати його у якості підписанта
        --на етапі збереження проекту(залежить від типу акту)
        Merge_Signer (p_At_Id       => p_At_Id,
                      p_Atd_Id      => p_Atd_Id,
                      p_Ati_Tp      => 'PR',
                      p_Cu_Id       => l_Cu_Id,
                      p_file_code   => p_file_code);
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ НА ЗРІЗ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Dh (p_Atd_Id           IN NUMBER,
                          p_Atd_Dh           IN NUMBER,
                          p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO')
    IS
    BEGIN
        Write_Audit ('Set_Atd_Dh');
        Api$act.Set_Atd_Dh (p_Atd_Id, p_Atd_Dh, p_Atd_Attach_Src);
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ СОРСУ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Source (p_Atd_Id           IN NUMBER,
                              p_Atd_Attach_Src   IN VARCHAR2 DEFAULT 'AUTO')
    IS
    BEGIN
        Write_Audit ('Set_Atd_Dh');
        Api$act.Set_Atd_Source (p_Atd_Id, p_Atd_Attach_Src);
    END;

    PROCEDURE Get_Act_Documents (p_At_Id            IN     NUMBER,
                                 p_Docs_Cur            OUT SYS_REFCURSOR,
                                 p_Docs_Files_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Docs_Files_Cur);
    END;

    -- лог по рішенню
    PROCEDURE Get_Act_Log (p_At_Id IN NUMBER, Res_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
              SELECT /*T.ATL_ID AS LOG_ID,
                                                               T.ATL_AT AS LOG_OBJ,
                                                               T.ATL_TP AS LOG_TP,
                                                               ST.DIC_NAME AS LOG_ST_NAME,
                                                               STO.DIC_NAME AS LOG_ST_OLD_NAME,
                                                               HS.HS_DT AS LOG_HS_DT,
                                                               NVL(TOOLS.GETUSERLOGIN(HS.HS_WU), 'Автоматично') AS LOG_HS_AUTHOR,
                                                               USS_NDI.RDM$MSG_TEMPLATE.GETMESSAGETEXT(T.ATL_MESSAGE) AS LOG_MESSAGE*/
                     Hs.Hs_Dt                                                   AS Log_Dt,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.Atl_Message)    AS Log_Msg
                FROM At_Log t
                     LEFT JOIN Uss_Ndi.v_Ddn_At_Pdsp_St St
                         ON (St.Dic_Value = t.Atl_St)
                     LEFT JOIN Uss_Ndi.v_Ddn_At_Pdsp_St Sto
                         ON (Sto.Dic_Value = t.Atl_St_Old)
                     LEFT JOIN v_Histsession Hs ON (Hs.Hs_Id = t.Atl_Hs)
               WHERE t.Atl_At = p_At_Id
            ORDER BY Hs.Hs_Dt;
    END;

    FUNCTION Get_Form_Ndt (p_at_tp IN ACT.AT_TP%TYPE)
        RETURN NUMBER
    IS
    BEGIN
        IF p_at_tp = 'APOP'
        THEN
            RETURN CMES$ACT_APOP.с_Form_Ndt;
        ELSIF p_at_tp = 'ANPOE'
        THEN
            RETURN CMES$ACT_ANPOE.с_Form_Ndt;
        END IF;

        RETURN NULL;
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   CASE
                       WHEN a.at_tp = 'APOP' THEN s.Dic_Name
                       WHEN a.at_tp = 'ANPOE' THEN s1.Dic_Name
                       ELSE 'Невідомий статус'
                   END
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   api$act.Get_Atd_Attach_Source (
                       a.at_id,
                       CMES$ACT.Get_Form_Ndt (a.at_tp))
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Apop_St s
                       ON a.At_St = s.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Anpoe_St s1
                       ON a.At_St = s1.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value;
    END;

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'ANPOE'
                       AND a.At_Rnspm = p_Cmes_Owner_Id
                UNION ALL
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'AR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'APOP'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'AD')
                 WHERE Rn = 1;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'ANPOE'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM At_Signers s
                                     WHERE     s.Ati_At = a.At_Id
                                           AND s.History_Status = 'A'
                                           AND s.Ati_Sc = l_Sc_Id))
                       AND EXISTS
                               (SELECT 1
                                  FROM At_Log l
                                 WHERE     l.Atl_At = a.At_Id
                                       AND l.Atl_St IN ('XV', 'XS'))
                UNION ALL
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'AR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'APOP'
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'AD'
                               AND (   a.At_Sc = l_Sc_Id
                                    OR EXISTS
                                           (SELECT 1
                                              FROM At_Signers s
                                             WHERE     s.Ati_At = a.At_Id
                                                   AND s.History_Status = 'A'
                                                   AND s.Ati_Sc = l_Sc_Id))
                               AND EXISTS
                                       (SELECT 1
                                          FROM At_Log l
                                         WHERE     l.Atl_At = a.At_Id
                                               AND l.Atl_St IN ('AV', 'AK')))
                 WHERE Rn = 1;
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        Get_Act_List (p_Acts);
    END;

    FUNCTION Get_Decline_Reason (p_at_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (SUBSTR (t.atl_message, 6))
          INTO l_res
          FROM at_log t
         WHERE     1 = 1
               AND t.atl_at = p_at_id
               AND SUBSTR (t.atl_st, 2, 1) IN ('R', 'D')
               AND (   t.atl_message LIKE CHR (38) || '231#%'
                    OR t.atl_message LIKE CHR (38) || '230#%');

        RETURN l_Res;
    END;

    --------------------------------------------------------------
    --   Встановлення кейс менеджера який буде вести випадок
    --------------------------------------------------------------
    PROCEDURE Set_Cm (p_At_Id IN NUMBER,                          --Ід ріщення
                                         p_At_Cu IN NUMBER --Ід користувача КМа, який буде вести випадок
                                                          )
    IS
        l_At_Tp   VARCHAR2 (10);
    BEGIN
        SELECT a.At_Tp
          INTO l_At_Tp
          FROM Act a
         WHERE a.At_Id = p_At_Id;


        IF l_At_Tp = 'PDSP'
        THEN
            CMES$ACT_PDSP.Set_Cm (p_At_Id, p_At_Cu);
        ELSIF l_At_Tp = 'ANPOE'
        THEN
            CMES$ACT_ANPOE.Set_Cm (p_At_Id, p_At_Cu);
        ELSIF l_At_Tp = 'APOP'
        THEN
            CMES$ACT_APOP.Set_Cm (p_At_Id, p_At_Cu);
        ELSIF l_At_Tp = 'OKS'
        THEN
            CMES$ACT_OKS.Set_Cm (p_At_Id, p_At_Cu);
        ELSE
            Raise_Application_Error (
                -20000,
                   'Для актів з типом '
                || l_At_Tp
                || ' не визначено алгоритм зміни КМ');
        END IF;
    END;

    PROCEDURE Set_Cm_Execute (p_At_Id IN NUMBER, p_At_Cu IN NUMBER)
    IS
        l_At_List   CMES$ACT.t_At_List;
        l_At_Cu     NUMBER;
        l_At_St     VARCHAR2 (10);
        l_At_Ap     NUMBER;
        l_Hs_Id     NUMBER;
    BEGIN
        Write_Audit ('Set_Cm_Execute');

        SELECT a.At_Cu, a.at_st, a.at_ap
          INTO l_At_Cu, l_At_St, l_At_Ap
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Отримуємо всі пов'язані з рішенням акти
        SELECT At_Id, At_St
          BULK COLLECT INTO l_At_List
          FROM (SELECT p_At_Id AS At_Id, l_At_St AS At_St FROM DUAL
                UNION ALL
                SELECT a.At_Id, a.At_St
                  FROM Act a
                 WHERE     a.At_Main_Link = p_At_Id
                       AND a.At_Main_Link_Tp = 'DECISION'
                UNION ALL
                SELECT l.Atk_At, a.At_St
                  FROM At_Links l JOIN Act a ON l.Atk_At = a.At_Id
                 WHERE l.Atk_Link_At = p_At_Id AND l.Atk_Tp = 'DECISION'
                UNION ALL
                --На випадок, якщо акт перв. оцінки не привязаний до конкретного рішення
                --таке можливо, якщо по випадку є декілька рішень, а акт перв. оцінки лише один
                SELECT a.At_Id, a.At_St
                  FROM Act a
                 WHERE     a.At_Ap = l_At_Ap
                       AND a.At_Tp IN ('APOP',
                                       'OKS',
                                       'ANPOE',
                                       'IP'));

        FORALL i IN INDICES OF l_At_List
            UPDATE Act a
               SET a.At_Cu = p_At_Cu
             WHERE a.At_Id = l_At_List (i).At_Id;

        --#113948
        FORALL i IN INDICES OF l_At_List
            UPDATE At_Calendar a
               SET a.Atc_Cu = p_At_Cu
             WHERE a.Atc_At = l_At_List (i).At_Id AND a.atc_is_km_ok IS NULL;

        --#113948
        FORALL i IN INDICES OF l_At_List
            UPDATE At_Individual_Plan a
               SET a.Atip_Cu = p_At_Cu
             WHERE a.atip_at = l_At_List (i).At_Id;

        l_Hs_Id := Tools.Gethistsessioncmes ();

        FORALL i IN INDICES OF l_At_List
            INSERT INTO At_Log (Atl_Id,
                                Atl_At,
                                Atl_Hs,
                                Atl_St,
                                Atl_Message,
                                Atl_St_Old,
                                Atl_Tp)
                     VALUES (
                                0,
                                l_At_List (i).At_Id,
                                l_Hs_Id,
                                l_At_List (i).At_St,
                                   CHR (38)
                                || '233#'
                                || Ikis_Rbm.Tools.Getcupib (l_At_Cu)
                                || '#'
                                || Ikis_Rbm.Tools.Getcupib (p_At_Cu),
                                l_At_List (i).At_St,
                                'SYS');
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ДОКУМЕНТУ ВКЛАДЕННЯ ПРИ ПІДПИСІ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Sign_Info_Doc (p_At_Id    IN     NUMBER,
                                 p_Atp_Id   IN     NUMBER,
                                 p_Atd_Id      OUT NUMBER,
                                 p_Doc_Id      OUT NUMBER)
    IS
    BEGIN
        Api$act.Get_Sign_Info_Doc (p_At_Id    => p_At_Id,
                                   p_Atp_Id   => p_Atp_Id,
                                   p_Atd_Id   => p_Atd_Id,
                                   p_Doc_Id   => p_Doc_Id);
    END;


    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Sign (p_At_Id        IN     NUMBER,
                               p_Atp_id       IN     NUMBER,
                               --p_Atd_Dh    OUT NUMBER,
                               p_Sign_Code       OUT VARCHAR2,
                               p_Photo_Code      OUT VARCHAR2)
    IS
        p_Atd_Dh   NUMBER;
    BEGIN
        api$act.Get_Tablet_Sign (p_At_Id,
                                 p_Atp_id,
                                 p_Atd_Dh,
                                 p_Sign_Code,
                                 p_Photo_Code);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id       => p_At_Id,
            p_Form_Ndt    => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Atd_Dh      => p_Atd_Dh,
            p_File_Code   => p_File_Code);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ФАЙЛІВ ПІДПИСУ НА ПЛАНШЕТІ
    -----------------------------------------------------------
    PROCEDURE Get_Tablet_Signs (p_At_Id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
        p_Atd_Dh   NUMBER;
    BEGIN
        api$act.Get_Tablet_Sign (p_At_Id, res_cur);
    END;


    PROCEDURE Log_Tmp_work_Ids_Amnt (p_src              IN VARCHAR2,
                                     p_obj_tp           IN VARCHAR2,
                                     p_obj_id           IN NUMBER,
                                     p_regular_params   IN VARCHAR2)
    IS
        l_Amnt   NUMBER;
    BEGIN
        SELECT COUNT (1) INTO l_Amnt FROM Tmp_Work_Ids;

        Tools.LOG (
            p_src      => p_src,
            p_obj_tp   => p_obj_tp,
            p_obj_id   => p_obj_id,
            p_regular_params   =>
                p_regular_params || ', Tmp_Work_Ids_Amnt=' || l_Amnt);
    END;

    FUNCTION Compare_Atp_App_Tp_On_Save (
        p_At_Id     IN            NUMBER,
        p_Persons   IN OUT NOCOPY Api$act.t_At_Persons)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT CASE WHEN COUNT (1) > 0 THEN 1 ELSE 0 END
          INTO l_Res
          FROM TABLE (p_Persons)  t1
               JOIN at_person t2
                   ON t2.Atp_At = p_At_Id AND t1.atp_id = t2.atp_id
         WHERE t2.atp_app_tp <> t1.atp_app_tp;

        RETURN l_Res;
    END;

    --Перевірка змін типу учасника в акті
    -- 0 - без змін
    -- 1 - є зміни
    FUNCTION Compare_Atp_App_Tp (p_At_Id_1 IN NUMBER, p_At_Id_2 IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT CASE WHEN COUNT (1) > 0 THEN 1 ELSE 0 END
          INTO l_Res
          FROM at_person t1, at_person t2
         WHERE     t1.atp_at = p_At_Id_1
               AND t2.atp_at = p_At_Id_2
               AND t1.atp_sc = t2.atp_sc
               AND t1.atp_app_tp <> t2.atp_app_tp
               AND t1.history_status = 'A'
               AND t2.history_status = 'A';

        IF l_Res = 0
        THEN
            SELECT CASE WHEN COUNT (1) > 0 THEN 1 ELSE 0 END
              INTO l_Res
              FROM at_person t1, at_person t2
             WHERE     t1.atp_at = p_At_Id_1
                   AND t2.atp_at = p_At_Id_2
                   AND t1.atp_num = t2.atp_num
                   AND t1.atp_app_tp <> t2.atp_app_tp
                   AND t1.history_status = 'A'
                   AND t2.history_status = 'A';
        END IF;

        RETURN l_Res;
    END;

    PROCEDURE Set_Sign_Code (p_at_id IN NUMBER, p_sign_code IN VARCHAR2)
    IS
        l_cu   NUMBER := ikis_rbm.tools.GetCurrentCu;
    BEGIN
        UPDATE at_signers t
           SET t.ati_sign_code = p_sign_code
         WHERE     t.ati_at = p_at_id
               AND t.history_status = 'T'
               AND t.ati_is_signed = 'T'
               AND t.ati_cu = l_cu;
    END;
END Cmes$act;
/