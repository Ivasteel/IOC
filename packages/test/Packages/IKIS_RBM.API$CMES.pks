/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$CMES
IS
    -- Author  : SHOST
    -- Created : 06.02.2023 17:38:00
    -- Purpose :

    c_Cmes_Bank           CONSTANT NUMBER := 1;
    c_Cmes_Ss_Provider    CONSTANT NUMBER := 2;
    c_Cmes_Ss_Receiver    CONSTANT NUMBER := 3;

    c_Crr_St_Registered   CONSTANT VARCHAR2 (10) := 'R';
    c_Crr_St_Accepted     CONSTANT VARCHAR2 (10) := 'A';
    c_Crr_St_Rejected     CONSTANT VARCHAR2 (10) := 'D';

    PROCEDURE Save_User (
        p_Cu_Id               IN     Cmes_Users.Cu_Id%TYPE,
        p_Cu_Cmes             IN     Cmes_Users.Cu_Cmes%TYPE DEFAULT NULL,
        p_Cu_Numident         IN     Cmes_Users.Cu_Numident%TYPE DEFAULT NULL,
        p_Cu_Cert_Serial      IN     Cmes_Users.Cu_Cert_Serial%TYPE DEFAULT NULL,
        p_Cu_Cert_Issuer      IN     Cmes_Users.Cu_Cert_Issuer%TYPE DEFAULT NULL,
        p_Cu_Cert_Expire_Dt   IN     Cmes_Users.Cu_Cert_Expire_Dt%TYPE DEFAULT NULL,
        p_Cu_Pib              IN     Cmes_Users.Cu_Pib%TYPE DEFAULT NULL,
        p_Cu_Locked           IN     Cmes_Users.Cu_Locked%TYPE DEFAULT NULL,
        p_Hs_Id               IN     Histsession.Hs_Id%TYPE DEFAULT NULL,
        p_New_Id                 OUT Cmes_Users.Cu_Id%TYPE);

    PROCEDURE Save_User_Hist (
        p_Ch_Hs               IN Cu_Hist.Ch_Hs%TYPE,
        p_Ch_Cu               IN Cu_Hist.Ch_Cu%TYPE,
        p_Cu_Pib              IN Cu_Hist.Cu_Pib%TYPE,
        p_Cu_Cert_Serial      IN Cu_Hist.Cu_Cert_Serial%TYPE,
        p_Cu_Cert_Issuer      IN Cu_Hist.Cu_Cert_Issuer%TYPE,
        p_Cu_Cert_Expire_Dt   IN Cu_Hist.Cu_Cert_Expire_Dt%TYPE,
        p_Cu_Locked           IN Cu_Hist.Cu_Locked%TYPE);

    PROCEDURE Save_Certificate (
        p_Cuc_Id               OUT Cu_Certificates.Cuc_Id%TYPE,
        p_Cuc_Cu                   Cu_Certificates.Cuc_Cu%TYPE,
        p_Cuc_Cert_Serial          Cu_Certificates.Cuc_Cert_Serial%TYPE,
        p_Cuc_Cert_Issuer          Cu_Certificates.Cuc_Cert_Issuer%TYPE,
        p_Cuc_Cert_Expire_Dt       Cu_Certificates.Cuc_Cert_Expire_Dt%TYPE,
        p_Cuc_Pib                  Cu_Certificates.Cuc_Pib%TYPE,
        p_Cuc_Numident             Cu_Certificates.Cuc_Numident%TYPE,
        p_Cuc_Edrpou               Cu_Certificates.Cuc_Edrpou%TYPE,
        p_Cuc_Hs_Ins               Cu_Certificates.Cuc_Hs_Ins%TYPE,
        p_Cuc_Cert                 Cu_Certificates.Cuc_Cert%TYPE);

    PROCEDURE Lock_Certificate (
        p_Cuc_Id            IN Cu_Certificates.Cuc_Id%TYPE,
        p_Cuc_Lock_Reason   IN Cu_Certificates.Cuc_Lock_Reason%TYPE,
        p_Hs_Id             IN NUMBER);

    PROCEDURE Unlock_Certificate (p_Cuc_Id   IN Cu_Certificates.Cuc_Id%TYPE,
                                  p_Hs_Id    IN NUMBER);

    PROCEDURE Save_User_Role (
        p_Cu2r_Cu                 Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Cu2r_Cr                 Cu_Users2roles.Cu2r_Cr%TYPE,
        p_Cu2r_Cmes_Owner_Id      Cu_Users2roles.Cu2r_Cmes_Owner_Id%TYPE,
        p_Hs_Id                IN NUMBER,
        p_Cu2r_Email              Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL);

    PROCEDURE Delete_User_Role (p_Cu2r_Id      Cu_Users2roles.Cu2r_Cu%TYPE,
                                p_Hs_Id     IN NUMBER);

    PROCEDURE Restore_User_Role (
        p_Cu2r_Id         Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Hs_Id        IN NUMBER,
        p_Cu2r_Email   IN Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL);

    PROCEDURE Assign_User_Role (
        p_Cu2r_Cu                 Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Cu2r_Cr                 Cu_Users2roles.Cu2r_Cr%TYPE,
        p_Cu2r_Cmes_Owner_Id      Cu_Users2roles.Cu2r_Cmes_Owner_Id%TYPE,
        p_Hs_Id                IN NUMBER,
        p_Cu2r_Email              Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL);

    PROCEDURE Link_User2cmes (p_Cu_Id IN NUMBER, p_Cmes_Id IN NUMBER);

    PROCEDURE Reg_Role_Request (
        p_Crr_Cu              Cu_Role_Request.Crr_Cu%TYPE,
        p_Crr_Cr              Cu_Role_Request.Crr_Cr%TYPE,
        p_Crr_Hs_Ins          Cu_Role_Request.Crr_Hs_Ins%TYPE,
        p_Crr_Cmes_Owner_Id   Cu_Role_Request.Crr_Cmes_Owner_Id%TYPE,
        p_Crr_Email           Cu_Role_Request.Crr_Email%TYPE DEFAULT NULL);

    PROCEDURE Accept_Role_Request (
        p_Crr_Id          Cu_Role_Request.Crr_Id%TYPE,
        p_Crr_Hs_Accept   Cu_Role_Request.Crr_Hs_Accept%TYPE);

    PROCEDURE Reject_Role_Request (
        p_Crr_Id              Cu_Role_Request.Crr_Id%TYPE,
        p_Crr_Hs_Reject       Cu_Role_Request.Crr_Hs_Reject%TYPE,
        p_Crr_Reject_Reason   Cu_Role_Request.Crr_Reject_Reason%TYPE);

    -- Оновлення ПІБ якщо змінився в сертифікаті
    PROCEDURE update_pib (p_cu_id NUMBER, p_pib VARCHAR2);
END Api$cmes;
/


GRANT EXECUTE ON IKIS_RBM.API$CMES TO II01RC_RBM_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$CMES TO USS_RNSP
/


/* Formatted on 8/12/2025 6:10:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$CMES
IS
    PROCEDURE Save_User (
        p_Cu_Id               IN     Cmes_Users.Cu_Id%TYPE,
        p_Cu_Cmes             IN     Cmes_Users.Cu_Cmes%TYPE DEFAULT NULL,
        p_Cu_Numident         IN     Cmes_Users.Cu_Numident%TYPE DEFAULT NULL,
        p_Cu_Cert_Serial      IN     Cmes_Users.Cu_Cert_Serial%TYPE DEFAULT NULL,
        p_Cu_Cert_Issuer      IN     Cmes_Users.Cu_Cert_Issuer%TYPE DEFAULT NULL,
        p_Cu_Cert_Expire_Dt   IN     Cmes_Users.Cu_Cert_Expire_Dt%TYPE DEFAULT NULL,
        p_Cu_Pib              IN     Cmes_Users.Cu_Pib%TYPE DEFAULT NULL,
        p_Cu_Locked           IN     Cmes_Users.Cu_Locked%TYPE DEFAULT NULL,
        p_Hs_Id               IN     Histsession.Hs_Id%TYPE DEFAULT NULL,
        p_New_Id                 OUT Cmes_Users.Cu_Id%TYPE)
    IS
        l_Cu   Cmes_Users%ROWTYPE;
    BEGIN
        IF p_Cu_Id IS NULL
        THEN
            INSERT INTO Cmes_Users (Cu_Id,
                                    Cu_Cmes,
                                    Cu_Numident,
                                    Cu_Cert_Serial,
                                    Cu_Cert_Issuer,
                                    Cu_Cert_Expire_Dt,
                                    Cu_Pib,
                                    Cu_Locked)
                 VALUES (0,
                         p_Cu_Cmes,
                         p_Cu_Numident,
                         p_Cu_Cert_Serial,
                         p_Cu_Cert_Issuer,
                         p_Cu_Cert_Expire_Dt,
                         p_Cu_Pib,
                         p_Cu_Locked)
              RETURNING Cu_Id,
                        Cu_Cmes,
                        Cu_Numident,
                        Cu_Cert_Serial,
                        Cu_Cert_Issuer,
                        Cu_Cert_Expire_Dt,
                        Cu_Pib,
                        Cu_Locked
                   INTO l_Cu.Cu_Id,
                        l_Cu.Cu_Cmes,
                        l_Cu.Cu_Numident,
                        l_Cu.Cu_Cert_Serial,
                        l_Cu.Cu_Cert_Issuer,
                        l_Cu.Cu_Cert_Expire_Dt,
                        l_Cu.Cu_Pib,
                        l_Cu.Cu_Locked;

            p_New_Id := l_Cu.Cu_Id;
        ELSE
            p_New_Id := p_Cu_Id;

               UPDATE Cmes_Users
                  SET Cu_Cert_Serial = NVL (p_Cu_Cert_Serial, Cu_Cert_Serial),
                      Cu_Cert_Issuer = NVL (p_Cu_Cert_Issuer, Cu_Cert_Issuer),
                      Cu_Cert_Expire_Dt =
                          NVL (p_Cu_Cert_Expire_Dt, Cu_Cert_Expire_Dt),
                      Cu_Pib = NVL (p_Cu_Pib, Cu_Pib),
                      Cu_Locked = NVL (p_Cu_Locked, Cu_Locked)
                WHERE Cu_Id = p_Cu_Id
            RETURNING Cu_Id,
                      Cu_Cmes,
                      Cu_Numident,
                      Cu_Cert_Serial,
                      Cu_Cert_Issuer,
                      Cu_Cert_Expire_Dt,
                      Cu_Pib,
                      Cu_Locked
                 INTO l_Cu.Cu_Id,
                      l_Cu.Cu_Cmes,
                      l_Cu.Cu_Numident,
                      l_Cu.Cu_Cert_Serial,
                      l_Cu.Cu_Cert_Issuer,
                      l_Cu.Cu_Cert_Expire_Dt,
                      l_Cu.Cu_Pib,
                      l_Cu.Cu_Locked;
        END IF;

        Save_User_Hist (p_Ch_Hs               => p_Hs_Id,
                        p_Ch_Cu               => l_Cu.Cu_Id,
                        p_Cu_Pib              => l_Cu.Cu_Pib,
                        p_Cu_Cert_Serial      => l_Cu.Cu_Cert_Serial,
                        p_Cu_Cert_Issuer      => l_Cu.Cu_Cert_Issuer,
                        p_Cu_Cert_Expire_Dt   => l_Cu.Cu_Cert_Expire_Dt,
                        p_Cu_Locked           => l_Cu.Cu_Locked);
    END;

    PROCEDURE Save_User_Hist (
        p_Ch_Hs               IN Cu_Hist.Ch_Hs%TYPE,
        p_Ch_Cu               IN Cu_Hist.Ch_Cu%TYPE,
        p_Cu_Pib              IN Cu_Hist.Cu_Pib%TYPE,
        p_Cu_Cert_Serial      IN Cu_Hist.Cu_Cert_Serial%TYPE,
        p_Cu_Cert_Issuer      IN Cu_Hist.Cu_Cert_Issuer%TYPE,
        p_Cu_Cert_Expire_Dt   IN Cu_Hist.Cu_Cert_Expire_Dt%TYPE,
        p_Cu_Locked           IN Cu_Hist.Cu_Locked%TYPE)
    IS
    BEGIN
        INSERT INTO Cu_Hist (Ch_Id,
                             Ch_Hs,
                             Ch_Cu,
                             Cu_Pib,
                             Cu_Cert_Serial,
                             Cu_Cert_Issuer,
                             Cu_Cert_Expire_Dt,
                             Cu_Locked)
             VALUES (0,
                     p_Ch_Hs,
                     p_Ch_Cu,
                     p_Cu_Pib,
                     p_Cu_Cert_Serial,
                     p_Cu_Cert_Issuer,
                     p_Cu_Cert_Expire_Dt,
                     p_Cu_Locked);
    END;

    PROCEDURE Save_Cert_Hist (
        p_Cuch_Cuc           Cu_Certificates_Hist.Cuch_Cuc%TYPE,
        p_Cuch_Locked        Cu_Certificates_Hist.Cuch_Locked%TYPE,
        p_Cuch_Hs            Cu_Certificates_Hist.Cuch_Hs%TYPE,
        p_Cuch_Lock_Reason   Cu_Certificates_Hist.Cuch_Lock_Reason%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Cu_Certificates_Hist (Cuch_Id,
                                          Cuch_Cuc,
                                          Cuch_Locked,
                                          Cuch_Hs,
                                          Cuch_Lock_Reason)
             VALUES (0,
                     p_Cuch_Cuc,
                     p_Cuch_Locked,
                     p_Cuch_Hs,
                     p_Cuch_Lock_Reason);
    END;

    PROCEDURE Save_Certificate (
        p_Cuc_Id               OUT Cu_Certificates.Cuc_Id%TYPE,
        p_Cuc_Cu                   Cu_Certificates.Cuc_Cu%TYPE,
        p_Cuc_Cert_Serial          Cu_Certificates.Cuc_Cert_Serial%TYPE,
        p_Cuc_Cert_Issuer          Cu_Certificates.Cuc_Cert_Issuer%TYPE,
        p_Cuc_Cert_Expire_Dt       Cu_Certificates.Cuc_Cert_Expire_Dt%TYPE,
        p_Cuc_Pib                  Cu_Certificates.Cuc_Pib%TYPE,
        p_Cuc_Numident             Cu_Certificates.Cuc_Numident%TYPE,
        p_Cuc_Edrpou               Cu_Certificates.Cuc_Edrpou%TYPE,
        p_Cuc_Hs_Ins               Cu_Certificates.Cuc_Hs_Ins%TYPE,
        p_Cuc_Cert                 Cu_Certificates.Cuc_Cert%TYPE)
    IS
    BEGIN
        INSERT INTO Cu_Certificates (Cuc_Id,
                                     Cuc_Cu,
                                     Cuc_Cert_Serial,
                                     Cuc_Cert_Issuer,
                                     Cuc_Cert_Expire_Dt,
                                     Cuc_Pib,
                                     Cuc_Locked,
                                     Cuc_Numident,
                                     Cuc_Edrpou,
                                     Cuc_Hs_Ins,
                                     Cuc_Cert)
             VALUES (0,
                     p_Cuc_Cu,
                     p_Cuc_Cert_Serial,
                     p_Cuc_Cert_Issuer,
                     p_Cuc_Cert_Expire_Dt,
                     p_Cuc_Pib,
                     'F',
                     p_Cuc_Numident,
                     p_Cuc_Edrpou,
                     p_Cuc_Hs_Ins,
                     p_Cuc_Cert)
          RETURNING Cuc_Id
               INTO p_Cuc_Id;

        Save_Cert_Hist (p_Cuch_Cuc      => p_Cuc_Id,
                        p_Cuch_Locked   => 'F',
                        p_Cuch_Hs       => p_Cuc_Hs_Ins);
    END;

    PROCEDURE Lock_Certificate (
        p_Cuc_Id            IN Cu_Certificates.Cuc_Id%TYPE,
        p_Cuc_Lock_Reason   IN Cu_Certificates.Cuc_Lock_Reason%TYPE,
        p_Hs_Id             IN NUMBER)
    IS
    BEGIN
        UPDATE Cu_Certificates c
           SET c.Cuc_Locked = 'T',
               c.Cuc_Hs_Locked = p_Hs_Id,
               c.Cuc_Lock_Reason = p_Cuc_Lock_Reason
         WHERE c.Cuc_Id = p_Cuc_Id;

        Save_Cert_Hist (p_Cuch_Cuc           => p_Cuc_Id,
                        p_Cuch_Locked        => 'T',
                        p_Cuch_Hs            => p_Hs_Id,
                        p_Cuch_Lock_Reason   => p_Cuc_Lock_Reason);
    END;

    PROCEDURE Unlock_Certificate (p_Cuc_Id   IN Cu_Certificates.Cuc_Id%TYPE,
                                  p_Hs_Id    IN NUMBER)
    IS
    BEGIN
        UPDATE Cu_Certificates c
           SET c.Cuc_Locked = 'F'
         WHERE c.Cuc_Id = p_Cuc_Id;

        Save_Cert_Hist (p_Cuch_Cuc      => p_Cuc_Id,
                        p_Cuch_Locked   => 'F',
                        p_Cuch_Hs       => p_Hs_Id);
    END;

    PROCEDURE Save_User_Role_Hist (
        p_Cu2rh_Cu2r       Cu_User2roles_Hist.Cu2rh_Cu2r%TYPE,
        p_Cu2rh_Hs         Cu_User2roles_Hist.Cu2rh_Hs%TYPE,
        p_History_Status   Cu_User2roles_Hist.History_Status%TYPE,
        p_Cu2rh_Email      Cu_User2roles_Hist.Cu2rh_Email%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Cu_User2roles_Hist (Cu2rh_Id,
                                        Cu2rh_Cu2r,
                                        Cu2rh_Hs,
                                        History_Status,
                                        Cu2rh_Email)
             VALUES (0,
                     p_Cu2rh_Cu2r,
                     p_Cu2rh_Hs,
                     p_History_Status,
                     p_Cu2rh_Email);
    END;

    PROCEDURE Send_Assign_Role_Message (
        p_Cu2r_Id   Cu_Users2roles.Cu2r_Id%TYPE)
    IS
        l_Text   VARCHAR2 (4000);
    BEGIN
        SELECT    INITCAP (u.Cu_Pib)
               || ', Вам надано доступ до '
               || REPLACE (LOWER (c.Cmes_Name), 'кабінет', 'кабінету')
               || ' "'
               || o.Cmes_Owner_Name
               || '" у якості "'
               || LOWER (Cr.Cr_Name)
               || '"'
          INTO l_Text
          FROM Cu_Users2roles  r
               JOIN Cmes_Users u ON r.Cu2r_Cu = u.Cu_Id
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Cu2r_Cr = Cr.Cr_Id
               JOIN Uss_Ndi.v_Ndi_Cmes c ON Cr.Cr_Cmes = c.Cmes_Id
               JOIN v_Cmes_Owners o
                   ON     r.Cu2r_Cmes_Owner_Id = o.Cmes_Owner_Id
                      AND o.Cmes_Id = c.cmes_id
         WHERE r.Cu2r_Id = p_Cu2r_Id AND r.Cu2r_Email IS NOT NULL;

        Uss_Person.Api$nt_Api.Sendcmesmessage (
            p_Cu2r_Id   => p_Cu2r_Id,
            p_Source    => '28',
            p_Title     => 'ЄІССС: надано доступ',
            p_Text      => l_Text);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    PROCEDURE Save_User_Role (
        p_Cu2r_Cu                 Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Cu2r_Cr                 Cu_Users2roles.Cu2r_Cr%TYPE,
        p_Cu2r_Cmes_Owner_Id      Cu_Users2roles.Cu2r_Cmes_Owner_Id%TYPE,
        p_Hs_Id                IN NUMBER,
        p_Cu2r_Email              Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL)
    IS
        l_New_Id   NUMBER;
    BEGIN
        INSERT INTO Cu_Users2roles (Cu2r_Id,
                                    Cu2r_Cu,
                                    Cu2r_Cr,
                                    Cu2r_Cmes_Owner_Id,
                                    History_Status,
                                    Cu2r_Email)
             VALUES (0,
                     p_Cu2r_Cu,
                     p_Cu2r_Cr,
                     p_Cu2r_Cmes_Owner_Id,
                     'A',
                     p_Cu2r_Email)
          RETURNING Cu2r_Id
               INTO l_New_Id;

        Save_User_Role_Hist (p_Cu2rh_Cu2r       => l_New_Id,
                             p_Cu2rh_Hs         => p_Hs_Id,
                             p_History_Status   => 'A',
                             p_Cu2rh_Email      => p_Cu2r_Email);

        Send_Assign_Role_Message (l_New_Id);
    END;

    PROCEDURE Delete_User_Role (p_Cu2r_Id      Cu_Users2roles.Cu2r_Cu%TYPE,
                                p_Hs_Id     IN NUMBER)
    IS
    BEGIN
        UPDATE Cu_Users2roles r
           SET r.History_Status = 'H'
         WHERE r.Cu2r_Id = p_Cu2r_Id AND r.History_Status = 'A';

        IF SQL%ROWCOUNT > 0
        THEN
            Save_User_Role_Hist (p_Cu2rh_Cu2r       => p_Cu2r_Id,
                                 p_Cu2rh_Hs         => p_Hs_Id,
                                 p_History_Status   => 'H');
        END IF;
    END;

    PROCEDURE Restore_User_Role (
        p_Cu2r_Id         Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Hs_Id        IN NUMBER,
        p_Cu2r_Email   IN Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL)
    IS
        l_Email   VARCHAR2 (100);
    BEGIN
           UPDATE Cu_Users2roles r
              SET r.History_Status = 'A',
                  r.Cu2r_Email = NVL (p_Cu2r_Email, r.Cu2r_Email)
            WHERE r.Cu2r_Id = p_Cu2r_Id AND r.History_Status = 'H'
        RETURNING r.Cu2r_Email
             INTO l_Email;

        IF SQL%ROWCOUNT > 0
        THEN
            Save_User_Role_Hist (p_Cu2rh_Cu2r       => p_Cu2r_Id,
                                 p_Cu2rh_Hs         => p_Hs_Id,
                                 p_History_Status   => 'A',
                                 p_Cu2rh_Email      => l_Email);
            Send_Assign_Role_Message (p_Cu2r_Id);
        END IF;
    END;

    PROCEDURE Assign_User_Role (
        p_Cu2r_Cu                 Cu_Users2roles.Cu2r_Cu%TYPE,
        p_Cu2r_Cr                 Cu_Users2roles.Cu2r_Cr%TYPE,
        p_Cu2r_Cmes_Owner_Id      Cu_Users2roles.Cu2r_Cmes_Owner_Id%TYPE,
        p_Hs_Id                IN NUMBER,
        p_Cu2r_Email              Cu_Users2roles.Cu2r_Email%TYPE DEFAULT NULL)
    IS
        l_Cu2r_Id   NUMBER;
    BEGIN
        --raise_application_error(-20000, 'p_Cu2r_Cu='||p_Cu2r_Cu||';p_Cu2r_Cr='||p_Cu2r_Cr||';p_Cu2r_Cmes_Owner_Id='||p_Cu2r_Cmes_Owner_Id||';p_Cu2r_Email='||p_Cu2r_Email);
        SELECT MAX (r.Cu2r_Id)
          INTO l_Cu2r_Id
          FROM Cu_Users2roles r
         WHERE     r.Cu2r_Cu = p_Cu2r_Cu
               AND r.Cu2r_Cr = p_Cu2r_Cr
               AND r.Cu2r_Cmes_Owner_Id = p_Cu2r_Cmes_Owner_Id;

        IF l_Cu2r_Id IS NULL
        THEN
            Save_User_Role (p_Cu2r_Cu              => p_Cu2r_Cu,
                            p_Cu2r_Cr              => p_Cu2r_Cr,
                            p_Cu2r_Cmes_Owner_Id   => p_Cu2r_Cmes_Owner_Id,
                            p_Hs_Id                => p_Hs_Id,
                            p_Cu2r_Email           => p_Cu2r_Email);
        ELSE
            Restore_User_Role (p_Cu2r_Id      => l_Cu2r_Id,
                               p_Hs_Id        => p_Hs_Id,
                               p_Cu2r_Email   => p_Cu2r_Email);
        END IF;
    END;

    PROCEDURE Link_User2cmes (p_Cu_Id IN NUMBER, p_Cmes_Id IN NUMBER)
    IS
    BEGIN
        MERGE INTO Cu_Users2cmes Dst
             USING (SELECT MAX (c.Cu2cmes_Id)     AS Cu2cmes_Id
                      FROM Cu_Users2cmes c
                     WHERE     c.Cu2cmes_Cu = p_Cu_Id
                           AND c.Cu2cmes_Cmes = p_Cmes_Id) Src
                ON (Src.Cu2cmes_Id = Dst.Cu2cmes_Id)
        WHEN NOT MATCHED
        THEN
            INSERT     (Cu2cmes_Id, Cu2cmes_Cu, Cu2cmes_Cmes)
                VALUES (0, p_Cu_Id, p_Cmes_Id);
    END;

    PROCEDURE Reg_Role_Request (
        p_Crr_Cu              Cu_Role_Request.Crr_Cu%TYPE,
        p_Crr_Cr              Cu_Role_Request.Crr_Cr%TYPE,
        p_Crr_Hs_Ins          Cu_Role_Request.Crr_Hs_Ins%TYPE,
        p_Crr_Cmes_Owner_Id   Cu_Role_Request.Crr_Cmes_Owner_Id%TYPE,
        p_Crr_Email           Cu_Role_Request.Crr_Email%TYPE DEFAULT NULL)
    IS
    BEGIN
        --Виключаємо повторну вставку, якщо вже є такий самий запит в статусі "Зареєстровано"
        MERGE INTO Cu_Role_Request Dst
             USING (SELECT MAX (r.Crr_Id)     AS Crr_Id
                      FROM Cu_Role_Request r
                     WHERE     r.Crr_Cu = p_Crr_Cu
                           AND r.Crr_Cr = p_Crr_Cr
                           AND r.Crr_Cmes_Owner_Id = p_Crr_Cmes_Owner_Id
                           AND r.Crr_St = 'R') Src
                ON (Src.Crr_Id = Dst.Crr_Id)
        WHEN NOT MATCHED
        THEN
            INSERT     (Crr_Id,
                        Crr_Cu,
                        Crr_Cr,
                        Crr_St,
                        Crr_Hs_Ins,
                        Crr_Cmes_Owner_Id,
                        Crr_Email)
                VALUES (0,
                        p_Crr_Cu,
                        p_Crr_Cr,
                        c_Crr_St_Registered,
                        p_Crr_Hs_Ins,
                        p_Crr_Cmes_Owner_Id,
                        p_Crr_Email);
    END;

    PROCEDURE Accept_Role_Request (
        p_Crr_Id          Cu_Role_Request.Crr_Id%TYPE,
        p_Crr_Hs_Accept   Cu_Role_Request.Crr_Hs_Accept%TYPE)
    IS
    BEGIN
        UPDATE Cu_Role_Request r
           SET r.Crr_St = c_Crr_St_Accepted,
               r.Crr_Hs_Accept = p_Crr_Hs_Accept
         WHERE r.Crr_Id = p_Crr_Id;
    END;

    PROCEDURE Reject_Role_Request (
        p_Crr_Id              Cu_Role_Request.Crr_Id%TYPE,
        p_Crr_Hs_Reject       Cu_Role_Request.Crr_Hs_Reject%TYPE,
        p_Crr_Reject_Reason   Cu_Role_Request.Crr_Reject_Reason%TYPE)
    IS
        l_Text   VARCHAR2 (4000);
    BEGIN
        UPDATE Cu_Role_Request r
           SET r.Crr_St = c_Crr_St_Rejected,
               r.Crr_Hs_Reject = p_Crr_Hs_Reject,
               r.Crr_Reject_Reason = p_Crr_Reject_Reason
         WHERE r.Crr_Id = p_Crr_Id;

        BEGIN
            SELECT    INITCAP (u.Cu_Pib)
                   || ', запит на доступ до '
                   || REPLACE (LOWER (c.Cmes_Name), 'кабінет', 'кабінету')
                   || ' "'
                   || o.Cmes_Owner_Name
                   || '" у якості "'
                   || LOWER (Cr.Cr_Name)
                   || '" відхилено. Причина: '
                   || p_Crr_Reject_Reason
              INTO l_Text
              FROM Cu_Role_Request  r
                   JOIN Cmes_Users u ON r.Crr_Cu = u.Cu_Id
                   JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Crr_Cr = Cr.Cr_Id
                   JOIN Uss_Ndi.v_Ndi_Cmes c ON Cr.Cr_Cmes = c.Cmes_Id
                   JOIN v_Cmes_Owners o
                       ON     r.Crr_Cmes_Owner_Id = o.Cmes_Owner_Id
                          AND o.Cmes_Id = c.cmes_id
             WHERE r.Crr_Id = p_Crr_Id AND r.Crr_Email IS NOT NULL;

            Uss_Person.Api$nt_Api.Sendcmesreqmessage (
                p_Crr_Id   => p_Crr_Id,
                p_Source   => '28',
                p_Title    => 'ЄІССС: запит відхилено',
                p_Text     => l_Text);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;
    END;

    -- Оновлення ПІБ якщо змінився в сертифікаті
    PROCEDURE update_pib (p_cu_id NUMBER, p_pib VARCHAR2)
    IS
        l_pib      VARCHAR2 (4000);
        l_new_id   NUMBER;
    BEGIN
        SELECT t.cu_pib
          INTO l_pib
          FROM cmes_users t
         WHERE t.cu_id = p_cu_id;

        IF (    l_pib IS NOT NULL
            AND p_pib IS NOT NULL
            AND UPPER (TRIM (p_pib)) != UPPER (TRIM (l_pib)))
        THEN
            Save_User (p_cu_id    => p_cu_id,
                       p_Cu_Pib   => p_pib,
                       p_New_Id   => l_new_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;
END Api$cmes;
/