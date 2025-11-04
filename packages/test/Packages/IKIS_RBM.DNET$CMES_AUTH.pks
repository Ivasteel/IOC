/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$CMES_AUTH
IS
    -- Author  : SHOSTAK
    -- Created : 23.05.2023 1:17:22 PM
    -- Purpose :

    Pkg                  CONSTANT VARCHAR2 (50) := 'DNET$CMES_AUTH';

    c_Auth_Alg_Default   CONSTANT VARCHAR2 (10) := 'D';

    TYPE r_Cert_Info IS RECORD
    (
        Issuer              VARCHAR2 (4000),
        Issuer_Cn           VARCHAR2 (1000),
        Serial              VARCHAR2 (100),
        Subj_Full_Name      VARCHAR2 (1000),
        Subj_Edrpou_Code    VARCHAR2 (10),
        Subj_Drfo_Code      VARCHAR2 (20),
        Cert_End_Time       DATE
    );

    FUNCTION Authenticate (p_Cert_Info      IN     CLOB,
                           p_Lifetime_Sec   IN     PLS_INTEGER,
                           p_Session_Id        OUT VARCHAR2,
                           p_Params         IN     VARCHAR2 DEFAULT NULL,
                           p_Auth_Alg       IN     VARCHAR2 DEFAULT NULL,
                           p_ip_address     IN     VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             Data              OUT SYS_REFCURSOR);

    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             p_Cu_Id           OUT NUMBER,
                             p_Cus_Id          OUT NUMBER);

    PROCEDURE Check_Session (p_Session_Id IN VARCHAR2, p_Cu_Id OUT NUMBER);

    FUNCTION Get_Oauth_Token (p_Session_Id IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Oauth_Session (p_Token_Id IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Reg_Role_Request (p_Role_Code       IN VARCHAR2,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Email           IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Reg_Role_Request (p_Session_Id      IN VARCHAR2,
                                p_Role_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Email           IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Get_User_Role_Requests (p_Session_Id   IN     VARCHAR2,
                                      p_Requests        OUT SYS_REFCURSOR);

    PROCEDURE Get_Owner_Role_Requests (p_Req_St     IN     VARCHAR2,
                                       p_Requests      OUT SYS_REFCURSOR);

    PROCEDURE Get_Role_Request_Details (
        p_Req_Id            IN     NUMBER,
        p_Request_Details      OUT SYS_REFCURSOR);

    PROCEDURE Accept_Role_Request (p_Req_Id IN NUMBER);

    PROCEDURE Reject_Role_Request (p_Req_Id          IN NUMBER,
                                   p_Reject_Reason   IN VARCHAR2);

    PROCEDURE Get_User_Roles (p_Session_Id   IN     VARCHAR2,
                              p_Roles           OUT SYS_REFCURSOR);

    PROCEDURE Get_User_Roles_For_Adm (p_Cu_Id           IN     NUMBER,
                                      p_Cmes_Id         IN     NUMBER,
                                      p_Cmes_Owner_Id   IN     NUMBER,
                                      p_Roles              OUT SYS_REFCURSOR);

    PROCEDURE Lock_Role (p_Role_Id IN NUMBER);

    PROCEDURE Unlock_Role (p_Role_Id IN NUMBER);

    PROCEDURE Get_User_Cmes_List (p_Session_Id   IN     VARCHAR2,
                                  p_Cmes_List       OUT SYS_REFCURSOR,
                                  p_Roles           OUT SYS_REFCURSOR);

    FUNCTION Is_Role_Assigned (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE Get_User_Profile (p_Session_Id   IN     VARCHAR2,
                                p_Data            OUT SYS_REFCURSOR);

    PROCEDURE Close_Session (p_Session_Id IN VARCHAR2);

    PROCEDURE Get_User_List (p_Cmes_Id         IN     NUMBER,
                             p_Cmes_Owner_Id   IN     NUMBER,
                             p_Role_Code       IN     VARCHAR2 DEFAULT NULL,
                             p_Res                OUT SYS_REFCURSOR,
                             p_Show_Locked     IN     VARCHAR2 DEFAULT 'F',
                             p_Cu_Pib          IN     VARCHAR2 DEFAULT NULL,
                             p_Cu_Numident     IN     VARCHAR2 DEFAULT NULL);

    /*  PROCEDURE Set_Session_Cmes(p_Session_Id    IN VARCHAR2,
    p_Cmes_Id       IN NUMBER,
    p_Cmes_Owner_Id IN NUMBER);*/

    PROCEDURE Assign_User_Roles (p_Cmes_Owner_Id   IN NUMBER,
                                 p_Is_Refusal      IN NUMBER,
                                 p_Cu_Numident     IN VARCHAR2,
                                 p_Cu_Pib          IN VARCHAR2,
                                 p_Role_List       IN VARCHAR2,
                                 p_Email           IN VARCHAR2);
END Dnet$cmes_Auth;
/


GRANT EXECUTE ON IKIS_RBM.DNET$CMES_AUTH TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$CMES_AUTH TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$CMES_AUTH TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$CMES_AUTH
IS
    ---------------------------------------------------------------------------
    --       Парсинг інформації про сетифікат
    ---------------------------------------------------------------------------
    FUNCTION Parse_Cert_Info (p_Cert_Info IN CLOB)
        RETURN r_Cert_Info
    IS
        l_Result   r_Cert_Info;
    BEGIN
        EXECUTE IMMEDIATE Type2jsontable (Pkg,
                                          'r_Cert_Info',
                                          'yyyy-mm-dd"T"hh24:mi:ss.ff"Z"')
            USING IN p_Cert_Info, OUT l_Result;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    --       Отримання ознаки блокування користувача
    ---------------------------------------------------------------------------
    FUNCTION User_Is_Locked (p_Cu_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cu_Locked   VARCHAR2 (10);
    BEGIN
        SELECT u.Cu_Locked
          INTO l_Cu_Locked
          FROM Cmes_Users u
         WHERE u.Cu_Id = p_Cu_Id;

        RETURN l_Cu_Locked = 'T';
    END;

    ---------------------------------------------------------------------------
    --       Пошук користувача за сертифікатом
    ---------------------------------------------------------------------------
    FUNCTION Get_User_By_Cert (p_Serial           IN     VARCHAR2,
                               p_Issuer           IN     VARCHAR2,
                               p_Cert_Is_Locked      OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        SELECT MAX (c.Cuc_Cu), MAX (c.Cuc_Locked)
          INTO l_Cu_Id, p_Cert_Is_Locked
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

    FUNCTION Get_Cu_By_Numident (p_Numident IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        SELECT MAX (c.cu_id)
          INTO l_Cu_Id
          FROM cmes_users c
         WHERE c.Cu_Numident = p_Numident AND c.cu_locked <> 'T';

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

    ---------------------------------------------------------------------------
    --       Прив'язка користувача до соцкартки
    ---------------------------------------------------------------------------
    PROCEDURE Link_Cu2sc (p_Cu_Id         IN NUMBER,
                          p_Cu_Numident   IN VARCHAR2,
                          p_Cu_Pib        IN VARCHAR2)
    IS
        l_Sc_Id       NUMBER;
        l_Sc_Unique   VARCHAR2 (100);
        l_Ln          VARCHAR2 (100);
        l_Fn          VARCHAR2 (100);
        l_Mn          VARCHAR2 (100);
    BEGIN
        l_Sc_Id := Tools.Getcusc (p_Cu_Id);

        IF l_Sc_Id IS NOT NULL
        THEN
            RETURN;
        END IF;

        Tools.Split_Pib (p_Pib   => p_Cu_Pib,
                         p_Ln    => l_Ln,
                         p_Fn    => l_Fn,
                         p_Mn    => l_Mn);
        l_Sc_Id :=
            Uss_Person.Load$socialcard.Load_Sc (
                p_Fn            => l_Fn,
                p_Ln            => l_Ln,
                p_Mn            => l_Mn,
                p_Gender        => NULL,
                p_Nationality   => NULL,
                p_Src_Dt        => SYSDATE,
                p_Birth_Dt      => NULL,
                p_Inn_Num       => p_Cu_Numident,
                p_Inn_Ndt       => 5,
                p_Doc_Ser       => NULL,
                p_Doc_Num       => NULL,
                p_Doc_Ndt       => NULL,
                p_Src           => NULL,
                p_Sc            => l_Sc_Id,
                p_Sc_Unique     => l_Sc_Unique,
                p_Mode          => Uss_Person.Load$socialcard.c_Mode_Search);

        IF l_Sc_Id > 0
        THEN
            UPDATE Cu_Users2roles r
               SET r.Cu2r_Cmes_Owner_Id = l_Sc_Id
             WHERE     r.Cu2r_Cu = p_Cu_Id
                   AND r.History_Status = 'A'
                   AND r.Cu2r_Cr = 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;

    ---------------------------------------------------------------------------
    --       Автентифікація користувача КМЕС по стандартному алгоритму
    ---------------------------------------------------------------------------
    FUNCTION Authenticate_Default (
        p_Cert_Info    IN OUT NOCOPY r_Cert_Info,
        p_Cu_Id           OUT        NUMBER,
        p_ip_address   IN            VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Cert_Is_Locked   VARCHAR2 (10);
        l_Cuc_Id           NUMBER;
        l_Hs_Id            NUMBER;
    BEGIN
        --Шукаємо сертифікат по номеру та АЦСК
        p_Cu_Id :=
            Get_User_By_Cert (p_Serial           => p_Cert_Info.Serial,
                              p_Issuer           => p_Cert_Info.Issuer_Cn,
                              p_Cert_Is_Locked   => l_Cert_Is_Locked);

        IF p_Cu_Id IS NOT NULL
        THEN
            --Якщо знайдено не заблокований сертифікат, та незаблоковано користувача - автентифікацію пройдено
            IF (NOT l_Cert_Is_Locked = 'T' AND NOT User_Is_Locked (p_Cu_Id))
            THEN
                Ikis_Sys.Ikis_Audit.Writemsg (
                    'WEB_CMES_AUTH',
                       'Аутентифіковано користувача '
                    || NVL (p_Cert_Info.Subj_Drfo_Code,
                            p_Cert_Info.Subj_Edrpou_Code)
                    || ' '
                    || p_Cert_Info.Subj_Full_Name
                    || '. IP-address: '
                    || p_ip_address,
                    p_Cu_Id);
            ELSIF (l_Cert_Is_Locked = 'T')
            THEN
                Ikis_Sys.Ikis_Audit.Writemsg ('WEB_CMES_AUTH_ERR_SERT_BLOCK',
                                              p_ip_address,
                                              p_Cu_Id);
            ELSIF (User_Is_Locked (p_Cu_Id))
            THEN
                Ikis_Sys.Ikis_Audit.Writemsg ('WEB_CMES_AUTH_ERR_USER_BLOCK',
                                              p_ip_address,
                                              p_Cu_Id);
            END IF;

            RETURN     NOT l_Cert_Is_Locked = 'T'
                   AND NOT User_Is_Locked (p_Cu_Id);
        END IF;

        --Якщо в сертфікаті наявний РНОКПП
        IF p_Cert_Info.Subj_Drfo_Code IS NOT NULL
        THEN
            --Шукаємо сертифікат користувача за РНОКПП
            p_Cu_Id := Get_User_By_Numident (p_Cert_Info.Subj_Drfo_Code);
        --Якщо в сертфікаті відсутній РНОКПП але є ЄДРПО
        ELSIF p_Cert_Info.Subj_Edrpou_Code IS NOT NULL
        THEN
            --Шукаємо сертифікат користувача за ЄДРПОУ
            p_Cu_Id := Get_User_By_Edrpou (p_Cert_Info.Subj_Edrpou_Code);
        ELSE
            Ikis_Sys.Ikis_Audit.Writemsg (
                'WEB_CMES_AUTH_ERR',
                   'В сертифікаті не знайдено ні РНОКПП ні ЄДРПОУ. IP-address: '
                || p_ip_address,
                p_Cu_Id);
            RETURN FALSE;
        END IF;

        IF p_Cert_Info.Subj_Drfo_Code IS NOT NULL AND p_cu_Id IS NULL
        THEN
            --Шукаємо користувача за РНОКПП
            p_Cu_Id := Get_Cu_By_Numident (p_Cert_Info.Subj_Drfo_Code);
        END IF;

        --Якщо користувача знайдено
        IF p_Cu_Id IS NOT NULL
        THEN
            IF User_Is_Locked (p_Cu_Id)
            THEN
                Ikis_Sys.Ikis_Audit.Writemsg ('WEB_CMES_AUTH_ERR_USER_BLOCK',
                                              p_ip_address,
                                              p_Cu_Id);
                RETURN FALSE;
            END IF;

            --Зберігаємо сертифікат користувача
            Api$cmes.Save_Certificate (
                p_Cuc_Id               => l_Cuc_Id,
                p_Cuc_Cu               => p_Cu_Id,
                p_Cuc_Cert_Serial      => p_Cert_Info.Serial,
                p_Cuc_Cert_Issuer      => p_Cert_Info.Issuer_Cn,
                p_Cuc_Cert_Expire_Dt   => p_Cert_Info.Cert_End_Time,
                p_Cuc_Pib              => p_Cert_Info.Subj_Full_Name,
                p_Cuc_Numident         => p_Cert_Info.Subj_Drfo_Code,
                p_Cuc_Edrpou           => p_Cert_Info.Subj_Edrpou_Code,
                p_Cuc_Hs_Ins           => l_Hs_Id,
                p_Cuc_Cert             => NULL);


            Ikis_Sys.Ikis_Audit.Writemsg (
                'WEB_CMES_AUTH',
                   'Аутентифіковано користувача '
                || NVL (p_Cert_Info.Subj_Drfo_Code,
                        p_Cert_Info.Subj_Edrpou_Code)
                || ' '
                || p_Cert_Info.Subj_Full_Name
                || '. IP-address: '
                || p_ip_address,
                p_Cu_Id);

            api$cmes.update_pib (p_cu_id, p_Cert_Info.Subj_Full_Name);
            RETURN TRUE;
        --Якщо користувача НЕ знайдено
        ELSE
            --Реєструємо користувача
            Api$cmes.Save_User (p_Cu_Id         => NULL,
                                p_Cu_Pib        => p_Cert_Info.Subj_Full_Name,
                                p_Cu_Numident   => p_Cert_Info.Subj_Drfo_Code,
                                p_Cu_Locked     => 'F',
                                p_Hs_Id         => Tools.Gethistsession,
                                p_New_Id        => p_Cu_Id);

            l_Hs_Id := Tools.Gethistsessioncmes (p_Cu_Id);
            --Зберігаємо сертифікат користувача
            Api$cmes.Save_Certificate (
                p_Cuc_Id               => l_Cuc_Id,
                p_Cuc_Cu               => p_Cu_Id,
                p_Cuc_Cert_Serial      => p_Cert_Info.Serial,
                p_Cuc_Cert_Issuer      => p_Cert_Info.Issuer_Cn,
                p_Cuc_Cert_Expire_Dt   => p_Cert_Info.Cert_End_Time,
                p_Cuc_Pib              => p_Cert_Info.Subj_Full_Name,
                p_Cuc_Numident         => p_Cert_Info.Subj_Drfo_Code,
                p_Cuc_Edrpou           => p_Cert_Info.Subj_Edrpou_Code,
                p_Cuc_Hs_Ins           => l_Hs_Id,
                p_Cuc_Cert             => NULL);

            FOR Rec
                IN (SELECT c.Cmes_Id, r.Cr_Id
                      FROM Uss_Ndi.v_Ndi_Cmes  c
                           JOIN Uss_Ndi.v_Ndi_Cmes_Roles r
                               ON     c.Cmes_Id = r.Cr_Cmes
                                  AND r.Cr_Default = 'T'
                                  AND r.Cr_Actual = 'A'
                     WHERE c.Cmes_Default = 'T' AND c.History_Status = 'A')
            LOOP
                --Застосовуємо до користувача дефолтну роль
                Api$cmes.Assign_User_Role (p_Cu2r_Cu              => p_Cu_Id,
                                           p_Cu2r_Cr              => Rec.Cr_Id,
                                           p_Cu2r_Cmes_Owner_Id   => NULL,
                                           p_Hs_Id                => l_Hs_Id);
                --Привязуємо користувача до дефолтного кабінету
                Api$cmes.Link_User2cmes (p_Cu_Id     => p_Cu_Id,
                                         p_Cmes_Id   => Rec.Cmes_Id);
            END LOOP;

            Ikis_Sys.Ikis_Audit.Writemsg (
                'WEB_CMES_AUTH',
                   'Аутентифіковано користувача '
                || NVL (p_Cert_Info.Subj_Drfo_Code,
                        p_Cert_Info.Subj_Edrpou_Code)
                || ' '
                || p_Cert_Info.Subj_Full_Name
                || '. IP-address: '
                || p_ip_address,
                p_Cu_Id);
            RETURN TRUE;
        END IF;
    END;

    ---------------------------------------------------------------------------
    --       Автентифікація користувача КМЕС
    ---------------------------------------------------------------------------
    FUNCTION Authenticate (
        p_Cert_Info    IN OUT NOCOPY r_Cert_Info,
        p_Auth_Alg     IN            VARCHAR2 DEFAULT NULL,
        p_Cu_Id           OUT        VARCHAR2,
        p_ip_address   IN            VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Result   BOOLEAN := FALSE;
    BEGIN
        IF NVL (p_Auth_Alg, c_Auth_Alg_Default) = c_Auth_Alg_Default
        THEN
            l_Result :=
                Authenticate_Default (p_Cert_Info,
                                      p_Cu_Id        => p_Cu_Id,
                                      p_ip_address   => p_ip_address);
        END IF;

        IF l_Result
        THEN
            --Прив'язуємо користувача до СРКО
            Link_Cu2sc (p_Cu_Id         => p_Cu_Id,
                        p_Cu_Numident   => p_Cert_Info.Subj_Drfo_Code,
                        p_Cu_Pib        => p_Cert_Info.Subj_Full_Name);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Generate_Code
        RETURN VARCHAR2
    IS
        l_Res   Portal_User_Session.Pus_Code%TYPE;
    BEGIN
        SELECT      ORA_HASH (SYS_GUID () || 'ss222$')
                  * ORA_HASH (
                           TO_CHAR (SYSTIMESTAMP, 'MMYYYYSSDDHH24MISSxFF')
                        || 'sod2!')
               || ''
          INTO l_Res
          FROM DUAL;

        RETURN l_Res;
    END;

    ---------------------------------------------------------------------------
    --                      Створення сесії
    ---------------------------------------------------------------------------
    PROCEDURE Create_Session (p_Cu_Id          IN            NUMBER,
                              p_Lifetime_Sec   IN            PLS_INTEGER,
                              p_Params         IN            VARCHAR2,
                              p_Cert_Info      IN OUT NOCOPY r_Cert_Info,
                              p_Session_Id        OUT        VARCHAR2)
    IS
        l_Id         NUMBER;
        l_Code       VARCHAR2 (40);
        l_Start_Dt   DATE;
        l_Stop_Dt    DATE;
    BEGIN
        l_Code := Generate_Code ();
        l_Start_Dt := SYSDATE;
        l_Stop_Dt := l_Start_Dt + p_Lifetime_Sec / 24 / 60 / 60;

        INSERT INTO Cu_Session (Cus_Id,
                                Cus_Cu,
                                Cus_Code,
                                Cus_Start_Dt,
                                Cus_Stop_Dt,
                                Cus_Last_Active_Dt,
                                History_Status)
             VALUES (0,
                     p_Cu_Id,
                     l_Code,
                     l_Start_Dt,
                     l_Stop_Dt,
                     SYSDATE,
                     'A')
          RETURNING Cus_Id
               INTO l_Id;

        INSERT INTO Cu_Session_Info (Cusi_Cus,
                                     Cusi_Cert_Serial,
                                     Cusi_Cert_Issuer,
                                     Cusi_Numident,
                                     Cusi_Edrpou,
                                     Cusi_Params)
             VALUES (l_Id,
                     p_Cert_Info.Serial,
                     p_Cert_Info.Issuer_Cn,
                     p_Cert_Info.Subj_Drfo_Code,
                     p_Cert_Info.Subj_Edrpou_Code,
                     p_Params);

        p_Session_Id := l_Id || '-' || l_Code;
    END;

    ---------------------------------------------------------------------------
    --       Автентифікація користувача КМЕС
    ---------------------------------------------------------------------------
    FUNCTION Authenticate (p_Cert_Info      IN     CLOB,
                           p_Lifetime_Sec   IN     PLS_INTEGER,
                           p_Session_Id        OUT VARCHAR2,
                           p_Params         IN     VARCHAR2 DEFAULT NULL,
                           p_Auth_Alg       IN     VARCHAR2 DEFAULT NULL,
                           p_ip_address     IN     VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Cert_Info   r_Cert_Info;
        l_Cu_Id       NUMBER;
    BEGIN
        l_Cert_Info := Parse_Cert_Info (p_Cert_Info);

        IF NOT Authenticate (p_Cert_Info    => l_Cert_Info,
                             p_Auth_Alg     => p_Auth_Alg,
                             p_Cu_Id        => l_Cu_Id,
                             p_ip_address   => p_ip_address)
        THEN
            RETURN 'F';
        END IF;

        Create_Session (p_Cu_Id          => l_Cu_Id,
                        p_Lifetime_Sec   => p_Lifetime_Sec,
                        p_Params         => p_Params,
                        p_Cert_Info      => l_Cert_Info,
                        p_Session_Id     => p_Session_Id);

        RETURN 'T';
    END;

    ---------------------------------------------------------------------------
    --                 Перевірка сесії(для порталу)
    ---------------------------------------------------------------------------
    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             Data              OUT SYS_REFCURSOR)
    IS
        l_Id     NUMBER;
        l_Code   VARCHAR2 (40);
    BEGIN
        Api$cmes_Auth.Parse_Session (p_Session_Id   => p_Session_Id,
                                     p_Id           => l_Id,
                                     p_Code         => l_Code);

        OPEN Data FOR
            SELECT TRUNC ((s.Cus_Stop_Dt - SYSDATE) * 24 * 60 * 60)
                       AS Expiredseconds,
                   s.Cus_Id || '-' || s.Cus_Code
                       AS Session_Id,
                   s.*,
                   Si.Cusi_Cert_Serial,
                   Si.Cusi_Cert_Issuer,
                   Si.Cusi_Numident,
                   Si.Cusi_Edrpou
              FROM Cu_Session  s
                   LEFT JOIN Cu_Session_Info Si ON Si.Cusi_Cus = s.Cus_Id
             WHERE     s.Cus_Id = l_Id
                   AND s.Cus_Code = l_Code
                   AND s.Cus_Stop_Dt >= SYSDATE
                   AND s.History_Status = 'A';
    END;

    ---------------------------------------------------------------------------
    --                 Перевірка сесії(для внутрішніх ресурсів)
    ---------------------------------------------------------------------------
    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             p_Cu_Id           OUT NUMBER,
                             p_Cus_Id          OUT NUMBER)
    IS
    BEGIN
        Api$cmes_Auth.Check_Session (p_Session_Id   => p_Session_Id,
                                     p_Cu_Id        => p_Cu_Id,
                                     p_Cus_Id       => p_Cus_Id);
    END;

    ---------------------------------------------------------------------------
    --                 Перевірка сесії(для внутрішніх ресурсів)
    ---------------------------------------------------------------------------
    PROCEDURE Check_Session (p_Session_Id IN VARCHAR2, p_Cu_Id OUT NUMBER)
    IS
        l_Cus_Id   NUMBER;
    BEGIN
        Api$cmes_Auth.Check_Session (p_Session_Id, p_Cu_Id, l_Cus_Id);
    END;

    ---------------------------------------------------------------------------
    --                        Закриття сесії
    ---------------------------------------------------------------------------
    PROCEDURE Close_Session (p_Session_Id IN VARCHAR2)
    IS
        l_Id     NUMBER;
        l_Code   VARCHAR2 (40);
    BEGIN
        Api$cmes_Auth.Parse_Session (p_Session_Id   => p_Session_Id,
                                     p_Id           => l_Id,
                                     p_Code         => l_Code);

        UPDATE Cu_Session s
           SET s.History_Status = 'H', s.Cus_Stop_Dt = SYSDATE
         WHERE s.Cus_Id = l_Id AND s.Cus_Code = l_Code;
    END;

    ---------------------------------------------------------------------------
    --                     Отримання токену для OAuth
    ---------------------------------------------------------------------------
    FUNCTION Get_Oauth_Token (p_Session_Id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Cu_Id               NUMBER;
        l_Cus_Id              NUMBER;
        l_Id                  NUMBER;
        l_Code                VARCHAR2 (40);
        l_Start_Dt            DATE;
        l_Stop_Dt             DATE;
        c_Lifetime   CONSTANT NUMBER := 120;
    BEGIN
        Check_Session (p_Session_Id, l_Cu_Id, l_Cus_Id);

        l_Code := Generate_Code ();
        l_Start_Dt := SYSDATE;
        l_Stop_Dt := l_Start_Dt + c_Lifetime / 24 / 60 / 60;

        INSERT INTO Cu_Oauth_Token (Cot_Id,
                                    Cot_Cus,
                                    Cot_Token,
                                    Cot_Start_Dt,
                                    Cot_Stop_Dt,
                                    History_Status)
             VALUES (0,
                     l_Cus_Id,
                     l_Code,
                     l_Start_Dt,
                     l_Stop_Dt,
                     'A')
          RETURNING Cot_Id
               INTO l_Id;

        RETURN l_Id || '-' || l_Code;
    END;

    ---------------------------------------------------------------------------
    --                    Парсинг токену
    ---------------------------------------------------------------------------
    PROCEDURE Parse_Token (p_Token_Id       VARCHAR2,
                           p_Id         OUT NUMBER,
                           p_Code       OUT VARCHAR2)
    IS
    BEGIN
        Api$cmes_Auth.Parse_Session (p_Session_Id   => p_Token_Id,
                                     p_Id           => p_Id,
                                     p_Code         => p_Code);
    END;

    ---------------------------------------------------------------------------
    --               Отримання сесії по токену OAuth
    ---------------------------------------------------------------------------
    FUNCTION Get_Oauth_Session (p_Token_Id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Id           NUMBER;
        l_Code         VARCHAR2 (40);
        l_Session_Id   VARCHAR2 (40);
    BEGIN
        Parse_Token (p_Token_Id => p_Token_Id, p_Id => l_Id, p_Code => l_Code);

        SELECT s.Cus_Id || '-' || s.Cus_Code
          INTO l_Session_Id
          FROM Cu_Oauth_Token t JOIN Cu_Session s ON t.Cot_Cus = s.Cus_Id
         WHERE     t.Cot_Id = l_Id
               AND t.Cot_Token = l_Code
               AND t.Cot_Stop_Dt >= SYSDATE
               AND t.History_Status = 'A';

        UPDATE Cu_Oauth_Token t
           SET t.History_Status = 'H', t.Cot_Stop_Dt = SYSDATE
         WHERE t.Cot_Id = l_Id AND t.Cot_Token = l_Code;

        RETURN l_Session_Id;
    END;

    ---------------------------------------------------------------------------
    --                Реєстрація запиту на отримання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Role_Request (p_Role_Code       IN VARCHAR2,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Email           IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        IF p_Cmes_Owner_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано власника кабінету');
        END IF;

        l_Cu_Id := Cmes_Context.Get_Context (Cmes_Context.g_Cuid);
        Api$cmes.Reg_Role_Request (
            p_Crr_Cu              => l_Cu_Id,
            p_Crr_Cr              => Api$cmes_Auth.Get_Role_Id (p_Role_Code),
            p_Crr_Hs_Ins          => Tools.Gethistsessioncmes (l_Cu_Id),
            p_Crr_Cmes_Owner_Id   => p_Cmes_Owner_Id,
            p_Crr_Email           => p_Email);
    END;

    ---------------------------------------------------------------------------
    --                Реєстрація запиту на отримання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Role_Request (p_Session_Id      IN VARCHAR2,
                                p_Role_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Email           IN VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        IF p_Cmes_Owner_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано власника кабінету');
        END IF;

        Check_Session (p_Session_Id, l_Cu_Id);
        Api$cmes.Reg_Role_Request (
            p_Crr_Cu              => l_Cu_Id,
            p_Crr_Cr              => p_Role_Id,
            p_Crr_Hs_Ins          => Tools.Gethistsessioncmes (l_Cu_Id),
            p_Crr_Cmes_Owner_Id   => p_Cmes_Owner_Id,
            p_Crr_Email           => p_Email);
    END;

    ---------------------------------------------------------------------------
    --                Отримання переліку власних запитів на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Role_Requests (p_Session_Id   IN     VARCHAR2,
                                      p_Requests        OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Session (p_Session_Id, l_Cu_Id);

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
                   u.Cu_Numident     AS Req_Requester_Numident --РНОКПП запитувача ролі
              FROM Cu_Role_Request  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ddn_Crr_St s ON r.Crr_St = s.Dic_Value
                   JOIN Histsession h ON r.Crr_Hs_Ins = h.Hs_Id
                   JOIN Cmes_Users u ON h.Hs_Cu = u.Cu_Id
             WHERE r.Crr_Cu = l_Cu_Id --викючаємо вже підтверджені запити
                                      AND r.Crr_St <> 'A';
    END;

    ---------------------------------------------------------------------------
    -- Отримання переліку запитів на видачу ролі направлених власнику кабінета
    ---------------------------------------------------------------------------
    PROCEDURE Get_Owner_Role_Requests (p_Req_St     IN     VARCHAR2,
                                       p_Requests      OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        l_Cu_Id := Cmes_Context.Get_Context (Cmes_Context.g_Cuid);

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
                   u.Cu_Numident     AS Req_Requester_Numident --РНОКПП запитувача ролі
              FROM Cu_Users2roles  u
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Owr
                       ON     u.Cu2r_Cr = Owr.Cr_Id
                          AND Owr.Cr_Actual = 'A'
                          AND Owr.Cr_Tp = 'A'
                   JOIN Cu_Role_Request r
                       ON u.Cu2r_Cmes_Owner_Id = r.Crr_Cmes_Owner_Id
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ddn_Crr_St s ON r.Crr_St = s.Dic_Value
                   JOIN Histsession h ON r.Crr_Hs_Ins = h.Hs_Id
                   JOIN Cmes_Users u ON h.Hs_Cu = u.Cu_Id
             WHERE     u.Cu2r_Cu = l_Cu_Id
                   AND u.History_Status = 'A'
                   AND Owr.Cr_Cmes = Cr.Cr_Cmes
                   AND r.Crr_St = NVL (p_Req_St, r.Crr_St);
    END;

    ---------------------------------------------------------------------------
    --         Отримання інформації щодо запиту на видачу ролі
    ---------------------------------------------------------------------------
    PROCEDURE Get_Role_Request_Details (
        p_Req_Id            IN     NUMBER,
        p_Request_Details      OUT SYS_REFCURSOR)
    IS
        l_Cu_Id        NUMBER;
        l_Has_Access   BOOLEAN := FALSE;
    BEGIN
        l_Cu_Id := Cmes_Context.Get_Context (Cmes_Context.g_Cuid);

        FOR Rec
            IN (SELECT r.Crr_Cr,
                       Cr.Cr_Cmes,
                       r.Crr_Cmes_Owner_Id,
                       r.Crr_Cu
                  FROM Cu_Role_Request  r
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON r.Crr_Cr = Cr.Cr_Id
                 WHERE r.Crr_Id = p_Req_Id)
        LOOP
            --Дозволяємо перегляд запиту лише для
            --користувача що його надіслав
            IF    (Rec.Crr_Cu = l_Cu_Id)
               --або для адміністратора кабінету
               OR Api$cmes_Auth.Is_Adm_Role_Assigned (
                      p_Cu_Id           => l_Cu_Id,
                      p_Cmes_Id         => Rec.Cr_Cmes,
                      p_Cmes_Owner_Id   => Rec.Crr_Cmes_Owner_Id)
            THEN
                l_Has_Access := TRUE;
            END IF;
        END LOOP;

        IF NOT l_Has_Access
        THEN
            Raise_Application_Error (-20000,
                                     'Недостатньо прав для перегляду');
        END IF;

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
                   ----
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
    --             Підтвердження запиту на надання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Accept_Role_Request (p_Req_Id IN NUMBER)
    IS
        l_Cu_Id   NUMBER;
        l_Hs_Id   NUMBER;
    BEGIN
        l_Cu_Id := Cmes_Context.Get_Context (Cmes_Context.g_Cuid);

        FOR Rec
            IN (SELECT *
                  FROM Cu_Role_Request  r
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON r.Crr_Cr = Cr.Cr_Id
                 WHERE r.Crr_Id = p_Req_Id)
        LOOP
            IF NOT Api$cmes_Auth.Is_Adm_Role_Assigned (
                       p_Cu_Id           => l_Cu_Id,
                       p_Cmes_Id         => Rec.Cr_Cmes,
                       p_Cmes_Owner_Id   => Rec.Crr_Cmes_Owner_Id)
            THEN
                Raise_Application_Error (
                    -20000,
                    'Недостатньо прав для підтвердження запиту');
            END IF;

            l_Hs_Id := Tools.Gethistsessioncmes (l_Cu_Id);
            Api$cmes.Accept_Role_Request (p_Crr_Id          => p_Req_Id,
                                          p_Crr_Hs_Accept   => l_Hs_Id);

            Api$cmes.Assign_User_Role (
                p_Cu2r_Cu              => Rec.Crr_Cu,
                p_Cu2r_Cr              => Rec.Crr_Cr,
                p_Cu2r_Cmes_Owner_Id   => Rec.Crr_Cmes_Owner_Id,
                p_Hs_Id                => l_Hs_Id,
                p_Cu2r_Email           => Rec.Crr_Email);
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    --             Відхилення запиту на надання ролі
    ---------------------------------------------------------------------------
    PROCEDURE Reject_Role_Request (p_Req_Id          IN NUMBER,
                                   p_Reject_Reason   IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        l_Cu_Id := Cmes_Context.Get_Context (Cmes_Context.g_Cuid);

        FOR Rec
            IN (SELECT *
                  FROM Cu_Role_Request  r
                       JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                           ON r.Crr_Cr = Cr.Cr_Id
                 WHERE r.Crr_Id = p_Req_Id)
        LOOP
            IF NOT Api$cmes_Auth.Is_Adm_Role_Assigned (
                       p_Cu_Id           => l_Cu_Id,
                       p_Cmes_Id         => Rec.Cr_Cmes,
                       p_Cmes_Owner_Id   => Rec.Crr_Cmes_Owner_Id)
            THEN
                Raise_Application_Error (
                    -20000,
                    'Недостатньо прав для відхилення запиту');
            END IF;

            Api$cmes.Reject_Role_Request (
                p_Crr_Id              => p_Req_Id,
                p_Crr_Hs_Reject       => Tools.Gethistsessioncmes (l_Cu_Id),
                p_Crr_Reject_Reason   => p_Reject_Reason);
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    --                Отримання переліку ролей користувача
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Roles (p_Cu_Id IN NUMBER, p_Roles OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Roles FOR
            SELECT Cr.Cr_Id                 AS Role_Id,
                   Cr.Cr_Cmes               AS Role_Cmes,
                   r.Cu2r_Cmes_Owner_Id     AS Role_Cmes_Owner_Id,
                   Cr.Cr_Code               AS Role_Code,
                   Cr.Cr_Name               AS Role_Name,
                   Cr.Cr_Tp                 AS Role_Tp
              FROM Cu_Users2roles  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                       ON r.Cu2r_Cr = Cr.Cr_Id AND Cr.Cr_Actual = 'A'
             WHERE r.Cu2r_Cu = p_Cu_Id AND r.History_Status = 'A';
    END;

    ---------------------------------------------------------------------------
    --                Отримання переліку ролей користувача
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Roles (p_Session_Id   IN     VARCHAR2,
                              p_Roles           OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Session (p_Session_Id, l_Cu_Id);
        Get_User_Roles (l_Cu_Id, p_Roles);
    END;

    ---------------------------------------------------------------------------
    --                Отримання переліку ролей користувача
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Roles_For_Adm (p_Cu_Id           IN     NUMBER,
                                      p_Cmes_Id         IN     NUMBER,
                                      p_Cmes_Owner_Id   IN     NUMBER,
                                      p_Roles              OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF NOT Api$cmes_Auth.Is_Adm_Role_Assigned (
                   p_Cmes_Id         => p_Cmes_Id,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id)
        THEN
            Raise_Application_Error (-20000,
                                     'Недостатньо прав для перегляду');
        END IF;

        OPEN p_Roles FOR
            SELECT r.Cu2r_Id                                          AS Role_Id,
                   Cr.Cr_Cmes                                         AS Role_Cmes,
                   r.Cu2r_Cmes_Owner_Id                               AS Role_Cmes_Owner_Id,
                   Cr.Cr_Code                                         AS Role_Code,
                   Cr.Cr_Name                                         AS Role_Name,
                   Cr.Cr_Tp                                           AS Role_Tp,
                   DECODE (r.History_Status,  'A', 'F',  'H', 'T')    AS Role_Locked
              FROM Cu_Users2roles  r
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                       ON r.Cu2r_Cr = Cr.Cr_Id AND Cr.Cr_Actual = 'A'
             WHERE     r.Cu2r_Cu = p_Cu_Id
                   AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
                   AND Cr.Cr_Cmes = p_Cmes_Id;
    END;

    ----------------------------------------------------------------------------
    --           Блокування ролі
    ----------------------------------------------------------------------------
    PROCEDURE Lock_Role (p_Role_Id IN NUMBER)
    IS
        l_Cmes_Owner_Id   NUMBER;
        l_Cmes_Id         NUMBER;
        l_Cu_Id           NUMBER := Tools.Getcurrentcu;
    BEGIN
        SELECT r.Cu2r_Cmes_Owner_Id, Rr.Cr_Cmes
          INTO l_Cmes_Owner_Id, l_Cmes_Id
          FROM Cu_Users2roles  r
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Rr ON r.Cu2r_Cr = Rr.Cr_Id
         WHERE r.Cu2r_Id = p_Role_Id;

        --raise_application_error(-20000, 'l_Cmes_Owner_Id='||l_Cmes_Owner_Id||';p_Role_Id='||p_Role_Id||';l_Cmes_Id='||l_Cmes_Id||';l_cu_id='||l_cu_id);

        IF NOT Api$cmes_Auth.Is_Adm_Role_Assigned (
                   p_Cu_Id           => l_Cu_Id,
                   p_Cmes_Id         => l_Cmes_Id,
                   p_Cmes_Owner_Id   => l_Cmes_Owner_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Недостатньо прав для виконання операції');
        END IF;

        Api$cmes.Delete_User_Role (p_Cu2r_Id   => p_Role_Id,
                                   p_Hs_Id     => Tools.Gethistsession);
    END;

    ----------------------------------------------------------------------------
    --           Розблокування ролі
    ----------------------------------------------------------------------------
    PROCEDURE Unlock_Role (p_Role_Id IN NUMBER)
    IS
        l_Cmes_Owner_Id   NUMBER;
        l_Cmes_Id         NUMBER;
        l_Cu_Id           NUMBER := Tools.Getcurrentcu;
    BEGIN
        SELECT r.Cu2r_Cmes_Owner_Id, Rr.Cr_Cmes
          INTO l_Cmes_Owner_Id, l_Cmes_Id
          FROM Cu_Users2roles  r
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Rr ON r.Cu2r_Cr = Rr.Cr_Id
         WHERE r.Cu2r_Id = p_Role_Id;

        IF NOT Api$cmes_Auth.Is_Adm_Role_Assigned (
                   p_Cu_Id           => l_Cu_Id,
                   p_Cmes_Id         => l_Cmes_Id,
                   p_Cmes_Owner_Id   => l_Cmes_Owner_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Недостатньо прав для виконання операції');
        END IF;

        Api$cmes.Restore_User_Role (p_Cu2r_Id   => p_Role_Id,
                                    p_Hs_Id     => Tools.Gethistsession);
    END;

    ---------------------------------------------------------------------------
    --               Отримання переліку кабінетів користувача
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Cmes_List (p_Session_Id   IN     VARCHAR2,
                                  p_Cmes_List       OUT SYS_REFCURSOR,
                                  p_Roles           OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Session (p_Session_Id, l_Cu_Id);

        OPEN p_Cmes_List FOR
            SELECT c.Cmes_Id,
                   c.Cmes_Name,
                   c.Cmes_Owner_Id,
                   o.Cmes_Owner_Code,
                   o.Cmes_Owner_Name
              FROM (SELECT DISTINCT
                           c.Cmes_Id,
                           c.Cmes_Name,
                           r.Cu2r_Cmes_Owner_Id     AS Cmes_Owner_Id
                      FROM Cu_Users2roles  r
                           JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                               ON r.Cu2r_Cr = Cr.Cr_Id AND Cr.Cr_Actual = 'A'
                           JOIN Uss_Ndi.v_Ndi_Cmes c
                               ON Cr.Cr_Cmes = c.Cmes_Id
                     WHERE r.Cu2r_Cu = l_Cu_Id AND r.History_Status = 'A') c
                   LEFT JOIN v_Cmes_Owners o
                       ON     c.Cmes_Owner_Id = o.Cmes_Owner_Id
                          AND c.Cmes_Id = o.Cmes_Id;

        Get_User_Roles (l_Cu_Id, p_Roles);
    END;

    FUNCTION Is_Role_Assigned (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => p_Cmes_Id,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => p_Cr_Code);
    END;

    ---------------------------------------------------------------------------
    --                Профіль користувача
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_Profile (p_Session_Id   IN     VARCHAR2,
                                p_Data            OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Check_Session (p_Session_Id, l_Cu_Id);

        OPEN p_Data FOR SELECT u.Cu_Id, u.Cu_Numident, u.Cu_Pib
                          FROM Cmes_Users u
                         WHERE Cu_Id = l_Cu_Id;
    END;

    ---------------------------------------------------------------------------
    --                Отримання переліку користувачів кабінету
    ---------------------------------------------------------------------------
    PROCEDURE Get_User_List (p_Cmes_Id         IN     NUMBER,
                             p_Cmes_Owner_Id   IN     NUMBER,
                             p_Role_Code       IN     VARCHAR2 DEFAULT NULL,
                             p_Res                OUT SYS_REFCURSOR,
                             p_Show_Locked     IN     VARCHAR2 DEFAULT 'F',
                             p_Cu_Pib          IN     VARCHAR2 DEFAULT NULL,
                             p_Cu_Numident     IN     VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        IF p_Cmes_Id = Api$cmes_Auth.c_Cmes_Ss_Provider
        THEN
            IF NOT Api$cmes_Auth.Is_Roles_Assigned (
                       p_Cmes_Id         => p_Cmes_Id,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Codes        => 'NSP_ADM,NSP_SPEC,NSP_CM')
            THEN
                Raise_Application_Error (-20000,
                                         'Недостатньо прав для перегляду');
            END IF;
        ELSE
            Raise_Application_Error (-20000,
                                     'Недостатньо прав для перегляду');
        END IF;

        OPEN p_Res FOR
              SELECT                                                --DISTINCT
                     u.Cu_Id,
                     u.Cu_Cmes,
                     u.Cu_Numident,
                     u.Cu_Pib,
                     CASE
                         WHEN u.Cu_Locked = 'T' THEN 'T'
                         ELSE DECODE (MIN (r.History_Status), 'A', 'F', 'T')
                     END    AS Cu_Locked
                FROM Cu_Users2roles r
                     JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                         ON     r.Cu2r_Cr = Cr.Cr_Id
                            AND Cr.Cr_Cmes = p_Cmes_Id
                            AND Cr.Cr_Actual = 'A'
                            AND Cr.Cr_Code = NVL (p_Role_Code, Cr.Cr_Code)
                     JOIN Cmes_Users u ON r.Cu2r_Cu = u.Cu_Id
               WHERE     r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
                     AND (   p_Show_Locked = 'T'
                          OR (u.Cu_Locked = 'F' AND r.History_Status = 'A'))
                     AND (   p_Cu_Pib IS NULL
                          OR UPPER (u.Cu_Pib) LIKE UPPER (p_Cu_Pib) || '%')
                     AND (   p_Cu_Numident IS NULL
                          OR u.Cu_Numident LIKE p_Cu_Numident || '%')
            GROUP BY u.Cu_Id,
                     u.Cu_Cmes,
                     u.Cu_Numident,
                     u.Cu_Pib,
                     u.Cu_Locked;
    END;

    ---------------------------------------------------------------------------
    -- Збереження до сесії інформації щодо кабінету в який увійшов користувач
    ---------------------------------------------------------------------------
    /*  PROCEDURE Set_Session_Cmes(p_Session_Id    IN VARCHAR2,
                               p_Cmes_Id       IN NUMBER,
                               p_Cmes_Owner_Id IN NUMBER) IS
      l_Cu_Id          NUMBER;
      l_Cus_Id         NUMBER;
      l_Edrpou         VARCHAR2(10);
      l_Is_Linked2cmes NUMBER;
    BEGIN
      Check_Session(p_Session_Id, l_Cu_Id, l_Cus_Id);

      SELECT Sign(COUNT(*))
        INTO l_Is_Linked2cmes
        FROM Cu_Users2roles r
        JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
          ON r.Cu2r_Cr = Cr.Cr_Id
       WHERE r.Cu2r_Cu = l_Cu_Id
             AND
            --Для кабінета отримувача може не бути посилання на соцкратку
            --(теоретично воно з'явиться вже після опрацювання одного зі звернень)
             (r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id OR (p_Cmes_Id = Api$cmes.c_Cmes_Ss_Receiver AND p_Cmes_Owner_Id IS NULL))
             AND Cr.Cr_Cmes = p_Cmes_Id
             AND r.History_Status = 'A'
             AND Cr.Cr_Actual = 'A';

      --зберігаємо інформацію про кабінет лише у випадку, якщо користувач має роль з привязкою до цього кабінету
      IF l_Is_Linked2cmes = 1 THEN
        UPDATE Cu_Session_Info i
           SET i.Cusi_Cmes_Owner_Id = p_Cmes_Owner_Id,
               i.Cusi_Cmes          = p_Cmes_Id
         WHERE i.Cusi_Cus = l_Cus_Id;
      ELSE
        --Визначаємо чи було виконано вхід за печаткою
        SELECT MAX(i.Cusi_Edrpou)
          INTO l_Edrpou
          FROM Cu_Session_Info i
         WHERE i.Cusi_Cus = l_Cus_Id
               AND i.Cusi_Numident IS NULL;
        --todo: уточнити чи потрібно автоматично призначати адмін роль користувачу
      END IF;
    END;*/

    ---------------------------------------------------------------------------
    -- Присвоєння ролей користувачу
    ---------------------------------------------------------------------------
    PROCEDURE Assign_User_Roles (p_Cmes_Owner_Id   IN NUMBER,
                                 p_Is_Refusal      IN NUMBER,
                                 p_Cu_Numident     IN VARCHAR2,
                                 p_Cu_Pib          IN VARCHAR2,
                                 p_Role_List       IN VARCHAR2,
                                 p_Email           IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_Hs_Id   NUMBER;
    BEGIN
        IF (NVL (p_Is_Refusal, 0) > 0)
        THEN
            IF LENGTH (p_Cu_Numident) <> 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'РНОКПП має містити 10 цифр. Ви ввели '
                    || LENGTH (p_Cu_Numident));
            END IF;

            IF NOT REGEXP_LIKE (p_Cu_Numident, '^([0-9]+)$')
            THEN
                Raise_Application_Error (-20000,
                                         'РНОКПП має містити тільки цифри');
            END IF;
        END IF;

        IF NOT Is_Role_Assigned (p_Cmes_Id         => Api$cmes.c_Cmes_Ss_Provider,
                                 p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                                 p_Cr_Code         => 'NSP_ADM')
        THEN
            Raise_Application_Error (
                -20000,
                'Недостатньо прав для виконання операції');
        END IF;

        SELECT MAX (u.Cu_Id)
          INTO l_Cu_Id
          FROM Cmes_Users u
         WHERE u.Cu_Numident = p_Cu_Numident;

        /*IF (l_cu_id IS NULL) THEN
          raise_application_error(-20000, 'Юзера з РНОКПП ' || p_Cu_Numident || ' не знайдено в системі!');
        END IF;*/

        l_Hs_Id := Tools.Gethistsessioncmes;

        Api$cmes.Save_User (p_Cu_Id         => l_Cu_Id,
                            p_Cu_Numident   => p_Cu_Numident,
                            p_Cu_Pib        => p_Cu_Pib,
                            p_Cu_Locked     => 'F',
                            p_Hs_Id         => l_Hs_Id,
                            p_New_Id        => l_Cu_Id);

        FOR Rec
            IN (SELECT TO_NUMBER (COLUMN_VALUE)     AS Cr_Id
                  FROM XMLTABLE (p_Role_List))
        LOOP
            Api$cmes.Assign_User_Role (
                p_Cu2r_Cu              => l_Cu_Id,
                p_Cu2r_Cr              => Rec.Cr_Id,
                p_Cu2r_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                p_Hs_Id                => l_Hs_Id,
                p_Cu2r_Email           => p_Email);
        END LOOP;
    END;
END Dnet$cmes_Auth;
/