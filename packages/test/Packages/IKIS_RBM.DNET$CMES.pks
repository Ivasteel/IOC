/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$CMES
IS
    -- Author  : SHOST
    -- Created : 06.02.2023 18:41:32
    -- Purpose :

    Pkg   CONSTANT VARCHAR2 (100) := 'DNET$CMES';

    TYPE r_Certificate IS RECORD
    (
        Numident     VARCHAR2 (10),
        Pib          VARCHAR2 (300),
        Serial       VARCHAR2 (1000),
        Issuer       VARCHAR2 (4000),
        Issuer_Cn    VARCHAR2 (4000),
        Start_Dt     DATE,
        Expire_Dt    DATE,
        Key_Usage    VARCHAR2 (10),
        File         CLOB
    );

    TYPE t_Certificates IS TABLE OF r_Certificate;

    PROCEDURE Lock_User (p_Cu_Id IN NUMBER);

    PROCEDURE Unlock_User (p_Cu_Id IN NUMBER);

    PROCEDURE Lock_Role (p_Role_Id IN NUMBER);

    PROCEDURE Unlock_Role (p_Role_Id IN NUMBER);

    PROCEDURE Save_Certificates_Bank (p_Rm_Id          IN NUMBER,
                                      p_Certificates   IN CLOB);

    PROCEDURE Get_Users_Bank (p_Pib        IN     VARCHAR2,
                              p_Numident   IN     VARCHAR2,
                              p_Rec_Id     IN     NUMBER,
                              p_Rm_Id      IN     NUMBER,
                              p_Res           OUT SYS_REFCURSOR);

    PROCEDURE Get_User_Bank (p_Cu_Id          IN     NUMBER,
                             p_User              OUT SYS_REFCURSOR,
                             p_Certificates      OUT SYS_REFCURSOR);

    PROCEDURE Save_User_Bank (p_Cu_Id       IN NUMBER,
                              p_Cu_Locked   IN VARCHAR2,
                              p_Rm_Id       IN VARCHAR2,
                              p_Certs2del   IN VARCHAR2);

    FUNCTION Parse_Certificates (p_Certificates IN CLOB)
        RETURN t_Certificates;

    PROCEDURE Get_Role_Requests (p_Cmes_Id         IN     NUMBER,
                                 p_Cmes_Owner_Id   IN     NUMBER,
                                 p_Req_St          IN     VARCHAR2,
                                 p_Requests           OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------------
    --  #88492: Отримання інформації щодо запитів на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_Role_Requests_Queue (p_Request_Details OUT SYS_REFCURSOR);

    PROCEDURE Accept_Role_Request (p_Req_Id IN NUMBER);

    PROCEDURE Reject_Role_Request (p_Req_Id          IN NUMBER,
                                   p_Reject_Reason   IN VARCHAR2);

    PROCEDURE Get_Users_Rnsp (p_Numident   IN     VARCHAR2,
                              p_Pib        IN     VARCHAR2,
                              p_Rnspm_Id   IN     NUMBER,
                              p_Res           OUT SYS_REFCURSOR);

    PROCEDURE Get_User_Rnsp (p_Cu_Id   IN     NUMBER,
                             p_User       OUT SYS_REFCURSOR,
                             p_Roles      OUT SYS_REFCURSOR);
END Dnet$cmes;
/


GRANT EXECUTE ON IKIS_RBM.DNET$CMES TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$CMES TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$CMES TO II01RC_RBM_PORTAL
/

GRANT EXECUTE ON IKIS_RBM.DNET$CMES TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$CMES
IS
    c_Role_Bank_User   CONSTANT NUMBER := 3;

    PROCEDURE Check_Role (p_Role IN VARCHAR2, p_Error IN VARCHAR2)
    IS
        l_User_Tp        NUMBER;
        l_User_Tp_Code   VARCHAR2 (10);
    BEGIN
        l_User_Tp := Ikis_Rbm_Context.Getcontext ('UserTP');

        SELECT Ut.Wut_Code
          INTO l_User_Tp_Code
          FROM Ikis_Sysweb.v_Full_User_Types Ut
         WHERE Ut.Wut_Id = l_User_Tp;

        IF NOT Is_Role_Assigned (Tools.Getcurrlogin, p_Role, l_User_Tp_Code)
        THEN
            Raise_Application_Error (-20000, p_Error);
        END IF;
    END;

    ----------------------------------------------------------------------------
    --           Блокування користувача
    ----------------------------------------------------------------------------
    PROCEDURE Lock_User (p_Cu_Id IN NUMBER)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Role ('W_RBM_CMES_ADM',
                    'Недостатньо прав для блокування користувача');
        Api$cmes.Save_User (p_Cu_Id       => p_Cu_Id,
                            p_Cu_Locked   => 'T',
                            p_New_Id      => l_Cu_Id,
                            p_Hs_Id       => Tools.Gethistsession);
    END;

    ----------------------------------------------------------------------------
    --           Розблокування користувача
    ----------------------------------------------------------------------------
    PROCEDURE Unlock_User (p_Cu_Id IN NUMBER)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Role ('W_RBM_CMES_ADM',
                    'Недостатньо прав для розблокування користувача');
        Api$cmes.Save_User (p_Cu_Id       => p_Cu_Id,
                            p_Cu_Locked   => 'F',
                            p_New_Id      => l_Cu_Id,
                            p_Hs_Id       => Tools.Gethistsession);
    END;

    ----------------------------------------------------------------------------
    --           Блокування ролі
    ----------------------------------------------------------------------------
    PROCEDURE Lock_Role (p_Role_Id IN NUMBER)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM', 'Недостатньо прав для блокування ролі');
        Api$cmes.Delete_User_Role (p_Cu2r_Id   => p_Role_Id,
                                   p_Hs_Id     => Tools.Gethistsession);
    END;

    ----------------------------------------------------------------------------
    --           Розблокування ролі
    ----------------------------------------------------------------------------
    PROCEDURE Unlock_Role (p_Role_Id IN NUMBER)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM',
                    'Недостатньо прав для розблокування ролі');
        Api$cmes.Restore_User_Role (p_Cu2r_Id   => p_Role_Id,
                                    p_Hs_Id     => Tools.Gethistsession);
    END;

    ---------------------------------------------------------------------------
    --       Пошук користувача за сертифікатом
    ---------------------------------------------------------------------------
    FUNCTION Get_User_By_Cert (p_Serial IN VARCHAR2, p_Issuer IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        SELECT MAX (c.Cuc_Cu)
          INTO l_Cu_Id
          FROM Cu_Certificates c
         WHERE c.Cuc_Cert_Serial = p_Serial AND c.Cuc_Cert_Issuer = p_Issuer;

        RETURN l_Cu_Id;
    END;

    ---------------------------------------------------------------------------
    --       Пошук користувача за РНОКПП
    ---------------------------------------------------------------------------
    FUNCTION Get_User_By_Numident (p_Numident IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        SELECT MAX (c.Cuc_Cu)
          INTO l_Cu_Id
          FROM Cu_Certificates c
         WHERE c.Cuc_Numident = p_Numident AND c.Cuc_Locked <> 'T';

        RETURN l_Cu_Id;
    END;

    ---------------------------------------------------------------------------
    --       Пошук користувача за ЄДРПОУ
    ---------------------------------------------------------------------------
    FUNCTION Get_User_By_Edrpou (p_Edrpou IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        SELECT MAX (c.Cuc_Cu)
          INTO l_Cu_Id
          FROM Cu_Certificates c
         WHERE     c.Cuc_Edrpou = p_Edrpou
               --враховуємо лише печатки без РНОКПП, томущо можуть бути інщі користувачі,
               --в яких наявний посадовий сертифікат з таким ЄДРПОУ
               AND c.Cuc_Numident IS NULL
               AND c.Cuc_Locked <> 'T';

        RETURN l_Cu_Id;
    END;

    ----------------------------------------------------------------------------
    --           Збереження сертифікатів користувачів КМЕС
    ----------------------------------------------------------------------------
    PROCEDURE Save_Certificates (
        p_Certificates   IN OUT NOCOPY t_Certificates,
        p_Hs_Id          IN            NUMBER)
    IS
    BEGIN
        FOR Rec IN (SELECT Numident,
                           Pib,
                           Serial,
                           Issuer,
                           Issuer_Cn,
                           Start_Dt,
                           Expire_Dt
                      FROM TABLE (p_Certificates) c
                     WHERE c.Key_Usage = 'SIGN')
        LOOP
            DECLARE
                l_Cuc_Id        NUMBER;
                l_Cu_Id         NUMBER;
                l_Cert_Exists   BOOLEAN;
            BEGIN
                IF Rec.Expire_Dt <= TRUNC (SYSDATE)
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Термін дії сертифіката підпису '
                        || Rec.Serial
                        || ' для користувача '
                        || Rec.Pib
                        || ' завершився '
                        || TO_CHAR (Rec.Expire_Dt, 'dd.mm.yyyy')
                        || '.'
                        || CHR (13)
                        || CHR (10)
                        || 'Будь ласка, оберіть інший сертифікат');
                END IF;

                IF Rec.Serial IS NULL
                THEN
                    Raise_Application_Error (-20000,
                                             'Не вазано номер сертифікату');
                END IF;

                IF Rec.Issuer_Cn IS NULL
                THEN
                    Raise_Application_Error (-20000, 'Не вказано АЦСК');
                END IF;

                /*IF Rec.Numident IS NULL THEN
                  Raise_Application_Error(-20000,
                                          'В сертифікаті ' || Rec.Serial || ' для користувача ' || Rec.Pib ||
                                          ' відсутній РНОКПП. Будь ласка, оберіть інший сертифікат');
                END IF;*/

                --Шукаємо сертифікат по номеру та АЦСК
                l_Cu_Id :=
                    Get_User_By_Cert (p_Serial   => Rec.Serial,
                                      p_Issuer   => Rec.Issuer_Cn);
                l_Cert_Exists := l_Cu_Id IS NOT NULL;

                --raise_application_error(-20000, l_Cu_Id);

                IF l_Cu_Id IS NULL
                THEN
                    --Якщо в сертфікаті наявний РНОКПП
                    IF Rec.Numident IS NOT NULL
                    THEN
                        --Шукаємо сертифікат користувача за РНОКПП
                        l_Cu_Id := Get_User_By_Numident (Rec.Numident);
                    END IF;
                END IF;


                --Реєструємо користувача
                Api$cmes.Save_User (p_Cu_Id         => l_Cu_Id,
                                    p_Cu_Pib        => Rec.Pib,
                                    p_Cu_Numident   => Rec.Numident,
                                    p_Cu_Locked     => 'F',
                                    p_Hs_Id         => p_Hs_Id,
                                    p_New_Id        => l_Cu_Id);


                IF NOT l_Cert_Exists
                THEN
                    --raise_application_error(-20000, '123');
                    --Зберігаємо сертифікат користувача
                    Api$cmes.Save_Certificate (
                        p_Cuc_Id               => l_Cuc_Id,
                        p_Cuc_Cu               => l_Cu_Id,
                        p_Cuc_Cert_Serial      => Rec.Serial,
                        p_Cuc_Cert_Issuer      => Rec.Issuer_Cn,
                        p_Cuc_Cert_Expire_Dt   => Rec.Expire_Dt,
                        p_Cuc_Pib              => Rec.Pib,
                        p_Cuc_Numident         => Rec.Numident,
                        p_Cuc_Edrpou           => NULL,
                        p_Cuc_Hs_Ins           => p_Hs_Id,
                        p_Cuc_Cert             => NULL);
                END IF;
            END;
        END LOOP;
    END;

    ----------------------------------------------------------------------------
    --           Парсинг сертифікатів
    ----------------------------------------------------------------------------
    FUNCTION Parse_Certificates (p_Certificates IN CLOB)
        RETURN t_Certificates
    IS
        l_Result   t_Certificates;
    BEGIN
        EXECUTE IMMEDIATE Type2jsontable (
                             p_Pkg_Name    => Pkg,
                             p_Type_Name   => 't_Certificates',
                             p_Date_Fmt    => 'yyyy-mm-dd"T"hh24:mi:ss.ff"Z"')
            USING IN p_Certificates, OUT l_Result;

        RETURN l_Result;
    END;

    --==========================================================================
    --                       КАБІНЕТ БАНКІРА
    --==========================================================================
    ----------------------------------------------------------------------------
    --           Збереження сертифікатів користувачів кабінету банкіра
    ----------------------------------------------------------------------------
    PROCEDURE Save_Certificates_Bank (p_Rm_Id          IN NUMBER,
                                      p_Certificates   IN CLOB)
    IS
        l_Certificates   t_Certificates;
        l_Hs_Id          NUMBER;
    BEGIN
        /*IF p_Rm_Id IS NULL THEN
          Raise_Application_Error(-20000, 'Не вакзано прив`язку до банку');
        END IF;*/

        --Парсимо сертіфікати
        l_Certificates := Parse_Certificates (p_Certificates);

        --Зберігаємо сертифікати підпису користувачів для входу до кабінету
        l_Hs_Id := Tools.Gethistsession;
        Save_Certificates (p_Certificates   => l_Certificates,
                           p_Hs_Id          => l_Hs_Id);

        --Видаляэмо ролі кабінету банку у яких rm_id відрізняється від поточного
        --Пояснення: у одного користувача може бути тільки одна роль кабінета банку,
        --тобто не може бути прив'язки до декількох банків.
        --Це пов'язано з тим, що немає інтерфейсу для администрування ролей кабінту банку,
        --а єдина точка управління цим - інтерфейс в якому можна обрати лише одинк банк для користувача.
        --На поточному етапі задачу на адміністрування ролей користувача банку по аналогії за кабінетом НСП не ставили(пожливо це і не потрібно)
        --Узгоджено з М.Гінтовою та О.Зиновець
        FOR Rec
            IN (SELECT r.Cu2r_Id
                  FROM TABLE (l_Certificates)  c
                       JOIN Cu_Certificates t
                           ON     c.Serial = t.Cuc_Cert_Serial
                              AND c.Issuer_Cn = t.Cuc_Cert_Issuer
                       JOIN Cu_Users2roles r
                           ON     t.Cuc_Cu = r.Cu2r_Cu
                              AND r.Cu2r_Cr = c_Role_Bank_User
                              AND r.History_Status = 'A'
                              AND r.Cu2r_Cmes_Owner_Id <> NVL (p_Rm_Id, -1))
        LOOP
            Api$cmes.Delete_User_Role (p_Cu2r_Id   => Rec.Cu2r_Id,
                                       p_Hs_Id     => l_Hs_Id);
        END LOOP;


        IF p_Rm_Id IS NOT NULL
        THEN
            --Створюємо звязки між користувачами та банками
            --(додаємо роль в рамках кабінету конкретного банку)
            FOR Rec
                IN (SELECT t.Cuc_Cu     AS Cu_Id
                      FROM TABLE (l_Certificates)  c
                           JOIN Cu_Certificates t
                               ON     c.Serial = t.Cuc_Cert_Serial
                                  AND c.Issuer_Cn = t.Cuc_Cert_Issuer
                     WHERE NOT EXISTS
                               (SELECT 1
                                  FROM Cu_Users2roles r
                                 WHERE     r.Cu2r_Cu = t.Cuc_Cu
                                       AND r.Cu2r_Cr = c_Role_Bank_User
                                       AND r.History_Status = 'A'))
            LOOP
                --Raise_Application_Error(-20000, 'test');
                Api$cmes.Assign_User_Role (p_Cu2r_Cu              => Rec.Cu_Id,
                                           p_Cu2r_Cr              => c_Role_Bank_User,
                                           p_Cu2r_Cmes_Owner_Id   => p_Rm_Id,
                                           p_Hs_Id                => l_Hs_Id);
            END LOOP;
        END IF;

        --Зберігаємо сертифікати шифрування користувачів
        FOR Rec
            IN (SELECT u.Cu_Id, c.*, Rmc.Rmc_Id
                  FROM TABLE (l_Certificates)  c
                       JOIN Cmes_Users u ON c.Numident = u.Cu_Numident
                       LEFT JOIN Rm_Certificates Rmc
                           ON     Rmc.Rmc_Cu = u.Cu_Id
                              AND Rmc.Rmc_Cert_Serial = c.Serial
                 WHERE c.Key_Usage = 'ENC')
        LOOP
            IF Rec.Expire_Dt <= TRUNC (SYSDATE)
            THEN
                Raise_Application_Error (
                    -20000,
                       'Термін дії сертифіката шифрування'
                    || Rec.Serial
                    || ' для користувача '
                    || Rec.Pib
                    || ' завершився '
                    || TO_CHAR (Rec.Expire_Dt, 'dd.mm.yyyy')
                    || '.'
                    || CHR (13)
                    || CHR (10)
                    || 'Будь ласка, оберіть інший сертифікат');
            END IF;

            IF Rec.Rmc_Id IS NULL
            THEN
                INSERT INTO Rm_Certificates (Rmc_Id,
                                             Rmc_Rm,
                                             Rmc_Cert,
                                             Rmc_St,
                                             Rmc_Dt,
                                             Com_Wu,
                                             Rmc_Cert_Serial,
                                             Rmc_Cert_Issuer,
                                             Rmc_Start_Dt,
                                             Rmc_Expire_Dt,
                                             Rmc_Cu)
                     VALUES (0,
                             p_Rm_Id,
                             Tools.Decode_Base64 (Rec.File),
                             'A',
                             SYSDATE,
                             Ikis_Rbm_Context.Getcontext ('UID'),
                             Rec.Serial,
                             Rec.Issuer,
                             Rec.Start_Dt,
                             Rec.Expire_Dt,
                             Rec.Cu_Id);
            ELSE
                --Якщо вже існує такий сертифікат привязаний до цього користувача,
                --встановлюємо йому актуальний статус та записуємого до нього
                --посилання на отримувача(банк), на випадок, якщо він має привязку
                --до іншого банку
                UPDATE Rm_Certificates
                   SET Rmc_Rm = p_Rm_Id,
                       Rmc_St = 'A',
                       Rmc_Dt = SYSDATE,
                       Com_Wu = Ikis_Rbm_Context.Getcontext ('UID')
                 WHERE Rmc_Id = Rec.Rmc_Id;
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------
    --          Пошук користувачів кабінету банкіра
    ----------------------------------------------------------------------------
    PROCEDURE Get_Users_Bank (p_Pib        IN     VARCHAR2,
                              p_Numident   IN     VARCHAR2,
                              p_Rec_Id     IN     NUMBER,
                              p_Rm_Id      IN     NUMBER,
                              p_Res           OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        l_Sql :=
            q'[
WITH Usr AS
 (SELECT u.Cu_Id, RM_REC AS Rec_Id, m.Rm_Id, m.Com_Org
    FROM Cmes_Users u
    JOIN Cu_Users2roles r
      ON u.Cu_Id = r.Cu2r_Cu
     AND r.Cu2r_Cr = 3
     AND r.History_Status = 'A'
    LEFT JOIN Recipient_Mail m
      ON r.Cu2r_Cmes_Owner_Id = m.Rm_Id
   WHERE 1=1 #)
SELECT c.Cu_Id, c.Cu_Numident,
      (select CUC_CERT_SERIAL from cu_certificates where cuc_cu=c.cu_id ORDER BY CUC_ID DESC FETCH FIRST ROW ONLY) as Cu_Cert_Serial,
      (select CUC_CERT_ISSUER from cu_certificates where cuc_cu=c.cu_id ORDER BY CUC_ID DESC FETCH FIRST ROW ONLY) AS Cu_Cert_Issuer,
       c.Cu_Cert_Expire_Dt, c.Cu_Pib, c.Cu_Locked, u.Rm_Id, o.Org_Name AS Rm_Name,
       r.Rec_Id, r.Rec_Name
  FROM Cmes_Users c
  JOIN Usr u
    ON c.Cu_Id = u.Cu_Id
  LEFT JOIN Recipient r
    ON u.Rec_Id = r.Rec_Id
   LEFT JOIN v_Opfu o
     ON u.Com_Org = o.Org_Id]';

        Api$search.Init (l_Sql);
        Api$search.And_ ('CU2R_CMES_OWNER_ID', p_Val_Num => p_Rm_Id);
        Api$search.And_ ('RM_REC', p_Val_Num => p_Rec_Id);
        Api$search.And_ ('CU_PIB', 'LIKE', p_Val_Str => p_Pib);
        Api$search.And_ ('CU_NUMIDENT', 'LIKE', p_Val_Str => p_Numident);
        p_Res := Api$search.Exec;
    END;

    ----------------------------------------------------------------------------
    --          Отримання картки користувача кабінету банкіра
    ----------------------------------------------------------------------------
    PROCEDURE Get_User_Bank (p_Cu_Id          IN     NUMBER,
                             p_User              OUT SYS_REFCURSOR,
                             p_Certificates      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_User FOR
            SELECT u.Cu_Id,
                   u.Cu_Locked,
                   r.Cu2r_Cmes_Owner_Id     AS Rm_Id,
                   o.Org_Name               AS Rm_Name,
                   c.Rec_Id,
                   c.Rec_Name
              FROM Cmes_Users  u
                   LEFT JOIN Cu_Users2roles r
                       ON     u.Cu_Id = r.Cu2r_Cu
                          AND r.Cu2r_Cr = c_Role_Bank_User
                          AND r.History_Status = 'A'
                   LEFT JOIN Recipient_Mail m
                       ON r.Cu2r_Cmes_Owner_Id = m.Rm_Id
                   LEFT JOIN v_Opfu o ON m.Com_Org = o.Org_Id
                   LEFT JOIN Recipient c ON m.Rm_Rec = c.Rec_Id
             WHERE u.Cu_Id = p_Cu_Id;

        OPEN p_Certificates FOR SELECT m.Rmc_Id              AS Cert_Id,
                                       m.Rmc_Cert_Serial     AS Serial,
                                       m.Rmc_Cert_Issuer     AS Issuer,
                                       m.Rmc_Start_Dt        AS Start_Dt,
                                       m.Rmc_Expire_Dt       AS Expire_Dt
                                  FROM Rm_Certificates m
                                 WHERE m.Rmc_Cu = p_Cu_Id AND m.Rmc_St = 'A';
    END;

    ----------------------------------------------------------------------------
    --          Збереження картки користувача кабінету банкіра
    ----------------------------------------------------------------------------
    PROCEDURE Save_User_Bank (p_Cu_Id       IN NUMBER,
                              p_Cu_Locked   IN VARCHAR2,
                              p_Rm_Id       IN VARCHAR2,
                              p_Certs2del   IN VARCHAR2)
    IS
        l_Hs_Id   NUMBER;
    BEGIN
        UPDATE Cmes_Users u
           SET u.Cu_Locked = p_Cu_Locked
         WHERE u.Cu_Id = p_Cu_Id AND (u.Cu_Locked <> p_Cu_Locked);

        UPDATE Rm_Certificates c
           SET c.Rmc_Rm = p_Rm_Id
         WHERE c.Rmc_Cu = p_Cu_Id AND c.Rmc_Rm <> NVL (p_Rm_Id, -1);

        FOR Rec
            IN (SELECT r.Cu2r_Id
                  FROM Cu_Users2roles r
                 WHERE     r.Cu2r_Cu = p_Cu_Id
                       AND r.Cu2r_Cr = c_Role_Bank_User
                       AND r.History_Status = 'A'
                       AND r.Cu2r_Cmes_Owner_Id <> NVL (p_Rm_Id, -1))
        LOOP
            l_Hs_Id := COALESCE (l_Hs_Id, Tools.Gethistsession);
            Api$cmes.Delete_User_Role (p_Cu2r_Id   => Rec.Cu2r_Id,
                                       p_Hs_Id     => l_Hs_Id);
        END LOOP;

        --Створюємо звязки між користувачами та банками
        --(додаємо роль в рамках кабінету конкретного банку)
        IF     p_Rm_Id IS NOT NULL
           AND NOT Api$cmes_Auth.Is_Role_Assigned (
                       p_Cu_Id           => p_Cu_Id,
                       p_Cmes_Id         => Api$cmes.c_Cmes_Bank,
                       p_Cmes_Owner_Id   => p_Rm_Id,
                       p_Cr_Code         => 'BNK_USR')
        THEN
            Api$cmes.Assign_User_Role (
                p_Cu2r_Cu              => p_Cu_Id,
                p_Cu2r_Cr              => c_Role_Bank_User,
                p_Cu2r_Cmes_Owner_Id   => p_Rm_Id,
                p_Hs_Id                =>
                    COALESCE (l_Hs_Id, Tools.Gethistsession));
        END IF;

        IF p_Certs2del IS NOT NULL
        THEN
            UPDATE Rm_Certificates m
               SET m.Rmc_St = 'D'
             WHERE m.Rmc_Id IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Certs2del));
        END IF;
    END;

    ---------------------------------------------------------------------------
    --             Отримання переліку запитів на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_Role_Requests (p_Cmes_Id         IN     NUMBER,
                                 p_Cmes_Owner_Id   IN     NUMBER,
                                 p_Req_St          IN     VARCHAR2,
                                 p_Requests           OUT SYS_REFCURSOR)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM', 'Недостатньо прав для перегляду');

        OPEN p_Requests FOR
            SELECT r.Crr_Id          AS Req_Id,
                   r.Crr_St          AS Req_St,
                   s.Dic_Name        AS Req_St_Name,
                   r.Crr_Cr          AS Req_Role_Id,
                   Cr.Cr_Name        AS Req_Role_Name,
                   h.Hs_Dt           AS Req_Reg_Dt,
                   --Дата створення запиту
                   u.Cu_Pib          AS Req_Requester_Name,
                   --ПІБ запитувача ролі
                   u.Cu_Numident     AS Req_Requester_Numident,
                   --РНОКПП запитувача ролі
                   c.Cmes_Name       AS Req_Cmes_Name         --Назва кабінету
              FROM Cu_Role_Request  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ddn_Crr_St s ON r.Crr_St = s.Dic_Value
                   JOIN Histsession h ON r.Crr_Hs_Ins = h.Hs_Id
                   JOIN Cmes_Users u ON h.Hs_Cu = u.Cu_Id
                   JOIN Uss_Ndi.v_Ndi_Cmes c ON Cr.Cr_Cmes = c.Cmes_Id
             WHERE     Cr.Cr_Cmes = NVL (p_Cmes_Id, Cr.Cr_Cmes)
                   AND r.Crr_Cmes_Owner_Id =
                       NVL (p_Cmes_Owner_Id, r.Crr_Cmes_Owner_Id)
                   AND r.Crr_St = NVL (p_Req_St, r.Crr_St)
                   AND Cr.Cr_Code IN ('NSP_ADM');
    END;

    ---------------------------------------------------------------------------
    --         Отримання інформації щодо запиту на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_Role_Request_Details (
        p_Req_Id            IN     NUMBER,
        p_Request_Details      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM', 'Недостатньо прав для перегляду');

        OPEN p_Request_Details FOR
            SELECT r.Crr_Id
                       AS Req_Id,
                   r.Crr_St
                       AS Req_St,
                   s.Dic_Name
                       AS Req_St_Name,
                   r.Crr_Cr
                       AS Req_Role_Id,
                   Cr.Cr_Name
                       AS Req_Role_Name,
                   Cr.Cr_Cmes
                       AS Req_Cmes_Id,
                   c.Cmes_Name
                       AS Req_Cmes_Name,
                   r.Crr_Cmes_Owner_Id
                       AS Req_Cmes_Owner_Id,
                   o.Cmes_Owner_Name
                       AS Req_Cmes_Owner_Name,
                   --Назва організації або ПІБ власника кабінету
                   o.Cmes_Owner_Code
                       AS Req_Cmes_Owner_Code,
                   --ЄДРПОУ/РНОКПП власника кабінету
                   h.Hs_Dt
                       AS Req_Reg_Dt,
                   u.Cu_Pib
                       AS Req_Requester_Name,
                   --ПІБ запитувача ролі
                   u.Cu_Numident
                       AS Req_Requester_Numident,
                   --РНОКПП запитувача ролі
                   Hh.Hs_Dt
                       AS Req_Reject_Dt,
                   r.Crr_Reject_Reason
                       AS Req_Reject_Reason,
                   Tools.Gethsuserpib (r.Crr_Hs_Reject)
                       AS Req_Rejector_Name,
                   Hhh.Hs_Dt
                       AS Req_Accept_Dt,
                   Tools.Gethsuserpib (r.Crr_Hs_Accept)
                       AS Req_Acceptor_Name
              FROM Cu_Role_Request  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ddn_Crr_St s ON r.Crr_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ndi_Cmes c ON Cr.Cr_Cmes = c.Cmes_Id
                   JOIN v_Cmes_Owners o
                       ON     r.Crr_Cmes_Owner_Id = o.Cmes_Owner_Id
                          AND Cr.Cr_Cmes = o.Cmes_Id
                   JOIN Histsession h ON r.Crr_Hs_Ins = h.Hs_Id
                   JOIN Cmes_Users u ON h.Hs_Cu = u.Cu_Id
                   LEFT JOIN Histsession Hh ON r.Crr_Hs_Reject = Hh.Hs_Id
                   LEFT JOIN Histsession Hhh ON r.Crr_Hs_Accept = Hhh.Hs_Id
             WHERE r.Crr_Id = p_Req_Id;
    END;


    ---------------------------------------------------------------------------
    --  #88492: Отримання інформації щодо запитів на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_Role_Requests_Queue (p_Request_Details OUT SYS_REFCURSOR)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM', 'Недостатньо прав для перегляду');

        OPEN p_Request_Details FOR
            SELECT r.Crr_Id                AS Req_Id,
                   r.Crr_St                AS Req_St,
                   s.Dic_Name              AS Req_St_Name,
                   r.Crr_Cr                AS Req_Role_Id,
                   Cr.Cr_Name              AS Req_Role_Name,
                   Cr.Cr_Cmes              AS Req_Cmes_Id,
                   c.Cmes_Name             AS Req_Cmes_Name,
                   r.Crr_Cmes_Owner_Id     AS Req_Cmes_Owner_Id,
                   o.Cmes_Owner_Name       AS Req_Cmes_Owner_Name,
                   --Назва організації або ПІБ власника кабінету
                   o.Cmes_Owner_Code       AS Req_Cmes_Owner_Code,
                   --ЄДРПОУ/РНОКПП власника кабінету
                   h.Hs_Dt                 AS Req_Reg_Dt,
                   u.Cu_Pib                AS Req_Requester_Name,
                   --ПІБ запитувача ролі
                   u.Cu_Numident           AS Req_Requester_Numident --РНОКПП запитувача ролі
              /* Hh.Hs_Dt AS Req_Reject_Dt,
              r.Crr_Reject_Reason AS Req_Reject_Reason,
              Tools.Gethsuserpib(r.Crr_Hs_Reject) AS Req_Rejector_Name,
              Hhh.Hs_Dt AS Req_Accept_Dt,
              Tools.Gethsuserpib(r.Crr_Hs_Accept) AS Req_Acceptor_Name*/
              FROM Cu_Role_Request  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ddn_Crr_St s ON r.Crr_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ndi_Cmes c ON Cr.Cr_Cmes = c.Cmes_Id
                   JOIN v_Cmes_Owners o
                       ON     r.Crr_Cmes_Owner_Id = o.Cmes_Owner_Id
                          AND Cr.Cr_Cmes = o.Cmes_Id
                   JOIN Histsession h ON r.Crr_Hs_Ins = h.Hs_Id
                   JOIN Cmes_Users u ON h.Hs_Cu = u.Cu_Id
             /*        LEFT JOIN Histsession Hh
               ON r.Crr_Hs_Reject = Hh.Hs_Id
             LEFT JOIN Histsession Hhh
               ON r.Crr_Hs_Accept = Hhh.Hs_Id*/
             WHERE     1 = 1
                   AND r.Crr_St NOT IN
                           (Api$cmes.c_Crr_St_Accepted,
                            Api$cmes.c_Crr_St_Rejected)
                   AND Cr.Cr_Code IN ('NSP_ADM');
    END;


    ---------------------------------------------------------------------------
    --             Підтвердження запиту на надання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Accept_Role_Request (p_Req_Id IN NUMBER)
    IS
        l_Wu_Id   NUMBER;
        l_Hs_Id   NUMBER;
    BEGIN
        Check_Role ('W_RBM_CMES_ADM',
                    'Недостатньо прав для підтвердження запиту');

        l_Wu_Id := Ikis_Rbm_Context.Getcontext ('UID');

        FOR Rec
            IN (SELECT *
                  FROM Cu_Role_Request  r
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON r.Crr_Cr = Cr.Cr_Id
                 WHERE r.Crr_Id = p_Req_Id)
        LOOP
            l_Hs_Id := Tools.Gethistsession (l_Wu_Id);
            Api$cmes.Accept_Role_Request (p_Crr_Id          => p_Req_Id,
                                          p_Crr_Hs_Accept   => l_Hs_Id);

            Api$cmes.Assign_User_Role (
                p_Cu2r_Cu              => Rec.Crr_Cu,
                p_Cu2r_Cr              => Rec.Crr_Cr,
                p_Cu2r_Cmes_Owner_Id   => Rec.Crr_Cmes_Owner_Id,
                p_Hs_Id                => l_Hs_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    --             Відхилення запиту на надання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Reject_Role_Request (p_Req_Id          IN NUMBER,
                                   p_Reject_Reason   IN VARCHAR2)
    IS
    BEGIN
        Check_Role ('W_RBM_CMES_ADM',
                    'Недостатньо прав для відхилення запиту');

        FOR Rec
            IN (SELECT *
                  FROM Cu_Role_Request  r
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON r.Crr_Cr = Cr.Cr_Id
                 WHERE r.Crr_Id = p_Req_Id)
        LOOP
            Api$cmes.Reject_Role_Request (
                p_Crr_Id              => p_Req_Id,
                p_Crr_Hs_Reject       =>
                    Tools.Gethistsession (
                        Ikis_Rbm_Context.Getcontext ('UID')),
                p_Crr_Reject_Reason   => p_Reject_Reason);
        END LOOP;
    END;

    ----------------------------------------------------------------------------
    --          Пошук користувачів кабінету надавача
    ----------------------------------------------------------------------------
    PROCEDURE Get_Users_Rnsp (p_Numident   IN     VARCHAR2,
                              p_Pib        IN     VARCHAR2,
                              p_Rnspm_Id   IN     NUMBER,
                              p_Res           OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        Check_Role ('W_RBM_CMES_ADM', 'Недостатньо прав для перегляду');

        l_Sql := q'[
      SELECT DISTINCT u.Cu_Id, u.Cu_Numident, u.Cu_Pib, u.Cu_Locked
        FROM Cmes_Users u
        JOIN Cu_Users2roles r
          ON u.Cu_Id = r.Cu2r_Cu
         AND r.History_Status = 'A'
        JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
          ON r.Cu2r_Cr = Cr.Cr_Id
       WHERE Cr.Cr_Cmes = 2 #
       order by Cu_Pib
       FETCH FIRST 500 ROWS ONLY]';

        Api$search.Init (l_Sql);
        Api$search.And_ ('Cu2r_Cmes_Owner_Id', p_Val_Num => p_Rnspm_Id);
        Api$search.And_ ('upper(Cu_Pib)',
                         'LIKE',
                         p_Var_Name   => 'p_cu_pib',
                         p_Val_Str    => UPPER (p_Pib));
        Api$search.And_ ('Cu_Numident', 'LIKE', p_Val_Str => p_Numident);
        p_Res := Api$search.Exec;
    END;

    ----------------------------------------------------------------------------
    --          Отримання картки користувача кабінету надавача
    ----------------------------------------------------------------------------
    PROCEDURE Get_User_Rnsp (p_Cu_Id   IN     NUMBER,
                             p_User       OUT SYS_REFCURSOR,
                             p_Roles      OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Check_Role('W_RBM_CMES_ADM', 'Недостатньо прав для перегляду');

        OPEN p_User FOR
            SELECT u.Cu_Id,
                   u.Cu_Numident,
                   u.Cu_Pib,
                   u.Cu_Locked,
                   c.Cmes_Name     AS Cmes_Name
              FROM Cmes_Users  u
                   LEFT JOIN Uss_Ndi.v_Ndi_Cmes c ON u.Cu_Cmes = c.Cmes_Id
             WHERE u.Cu_Id = p_Cu_Id;

        OPEN p_Roles FOR
              SELECT r.Cu2r_Id                     AS Role_Id,
                     Cr.Cr_Name                    AS Role_Name,
                     DECODE (r.History_Status,
                             'A', 'F',
                             'H', 'T')             AS Role_Locked,
                     --Дата останнього підтвердження/розблокування ролі
                      (  SELECT s.Hs_Dt
                           FROM Cu_User2roles_Hist h
                                JOIN Histsession s
                                    ON h.Cu2rh_Hs = s.Hs_Id
                          WHERE     h.Cu2rh_Cu2r = r.Cu2r_Id
                                AND h.History_Status = 'A'
                       ORDER BY s.Hs_Dt DESC
                          FETCH FIRST ROW ONLY)    AS Role_Accept_Dt,
                     --Піб користувача, який останнім підтвердив або розблокував роль
                      (  SELECT Tools.Gethsuserpib (s.Hs_Id)
                           FROM Cu_User2roles_Hist h
                                JOIN Histsession s ON h.Cu2rh_Hs = s.Hs_Id
                          WHERE     h.Cu2rh_Cu2r = r.Cu2r_Id
                                AND h.History_Status = 'A'
                       ORDER BY s.Hs_Dt DESC
                          FETCH FIRST ROW ONLY)    AS Role_Acceptor_Name,
                     --Дата блокування ролі
                      (  SELECT s.Hs_Dt
                           FROM Cu_User2roles_Hist h
                                JOIN Histsession s ON h.Cu2rh_Hs = s.Hs_Id
                          WHERE     h.Cu2rh_Cu2r = r.Cu2r_Id
                                AND r.History_Status = 'H'
                                AND h.History_Status = 'H'
                       ORDER BY s.Hs_Dt DESC
                          FETCH FIRST ROW ONLY)    AS Role_Lock_Dt,
                     --Піб користувача, який заблокував роль
                      (  SELECT Tools.Gethsuserpib (s.Hs_Id)
                           FROM Cu_User2roles_Hist h
                                JOIN Histsession s ON h.Cu2rh_Hs = s.Hs_Id
                          WHERE     h.Cu2rh_Cu2r = r.Cu2r_Id
                                AND r.History_Status = 'H'
                                AND h.History_Status = 'H'
                       ORDER BY s.Hs_Dt DESC
                          FETCH FIRST ROW ONLY)    AS Role_Locker_Name,
                     --ЄДРПОУ надавача
                     o.Cmes_Owner_Code             AS Role_Owner_Code,
                     --Назва надавача
                     o.Cmes_Owner_Name             AS Role_Owner_Name
                FROM Cu_Users2roles r
                     JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Cu2r_Cr = Cr.Cr_Id
                     JOIN v_Cmes_Owners o
                         ON     r.Cu2r_Cmes_Owner_Id = o.Cmes_Owner_Id
                            AND o.Cmes_Id = 2
               WHERE r.Cu2r_Cu = p_Cu_Id AND Cr.Cr_Default <> 'T'
            ORDER BY Cr_Name;
    END;
END Dnet$cmes;
/