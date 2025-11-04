/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.PORTAL$SESSION
IS
    PROCEDURE CreateSession (p_userid         IN     NUMBER,
                             p_auth_tp        IN     VARCHAR2,
                             p_lifetime_sec   IN     PLS_INTEGER,
                             p_params         IN     VARCHAR2,
                             p_sess_id           OUT VARCHAR2);

    PROCEDURE CheckSession (p_sess_id IN VARCHAR2, data OUT SYS_REFCURSOR);

    PROCEDURE CheckSessionRetro (p_sess_id   IN     VARCHAR2,
                                 p_time             DATE,
                                 data           OUT SYS_REFCURSOR);

    PROCEDURE CloseSession (p_sess_id IN VARCHAR2);

    PROCEDURE CmesAuth (p_Cert_Serial          VARCHAR2,
                        p_Cert_Issuer_Cn       VARCHAR2,
                        p_Cmes_Id              NUMBER,
                        p_Cu_Id            OUT NUMBER);


    PROCEDURE AutoAuth (p_numident       VARCHAR2,
                        p_name           VARCHAR2,
                        p_type           VARCHAR2,
                        p_user_id    OUT NUMBER);
END portal$session;
/


GRANT EXECUTE ON IKIS_RBM.PORTAL$SESSION TO II01RC_RBM_PORTAL
/

GRANT EXECUTE ON IKIS_RBM.PORTAL$SESSION TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.PORTAL$SESSION
IS
    FUNCTION GenerateCode
        RETURN VARCHAR2
    IS
        l_res   portal_user_session.pus_code%TYPE;
    BEGIN
        SELECT      ORA_HASH (SYS_GUID () || 'ss222$')
                  * ORA_HASH (
                           TO_CHAR (SYSTIMESTAMP, 'MMYYYYSSDDHH24MISSxFF')
                        || 'sod2!')
               || ''
          INTO l_res
          FROM DUAL;

        RETURN l_res;
    END;

    PROCEDURE parseSessId (p_sess_id       VARCHAR2,
                           p_id        OUT NUMBER,
                           p_code      OUT VARCHAR2)
    IS
        l_pos   PLS_INTEGER;
    BEGIN
        l_pos := INSTR (p_sess_id, '-');

        IF (l_pos <= 0)
        THEN
            raise_application_error (-20000, 'Невірний код сесії');
        END IF;

        p_id := TO_NUMBER (SUBSTR (p_sess_id, 1, l_pos - 1));
        p_code := SUBSTR (p_sess_id, l_pos + 1);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000, 'Невірний код сесії');
    END;

    PROCEDURE CreateSession (p_userid         IN     NUMBER,
                             p_auth_tp        IN     VARCHAR2,
                             p_lifetime_sec   IN     PLS_INTEGER,
                             p_params         IN     VARCHAR2,
                             p_sess_id           OUT VARCHAR2)
    IS
        l_id         portal_user_session.pus_id%TYPE;
        l_code       VARCHAR2 (40);
        l_start_dt   DATE;
        l_end_dt     DATE;
    BEGIN
        l_code := GenerateCode () || p_auth_tp;
        l_start_dt := SYSDATE;
        l_end_dt := l_start_dt + p_lifetime_sec / 24 / 60 / 60;

        INSERT INTO portal_user_session (pus_code,
                                         pus_pu,
                                         pus_start_dt,
                                         pus_end_dt,
                                         history_status,
                                         pus_auth_tp,
                                         pus_params)
             VALUES (l_code,
                     p_userid,
                     l_start_dt,
                     l_end_dt,
                     'A',
                     p_auth_tp,
                     p_params)
             RETURN pus_id
               INTO l_id;

        p_sess_id := l_id || '-' || l_code;
    END;

    PROCEDURE CheckSession (p_sess_id IN VARCHAR2, data OUT SYS_REFCURSOR)
    IS
        l_id     NUMBER;
        l_code   VARCHAR2 (40);
    BEGIN
        parseSessId (p_sess_id, l_id, l_code);

        OPEN data FOR
            SELECT TRUNC ((pus_end_dt - SYSDATE) * 24 * 60 * 60)
                       AS ExpiredSeconds,
                   pus_id || '-' || pus_code
                       AS sess_id,
                   s.*
              FROM portal_user_session s
             WHERE     pus_id = l_id
                   AND pus_code = l_code
                   AND pus_end_dt >= SYSDATE
                   AND history_status = 'A';
    END;

    PROCEDURE CheckSessionRetro (p_sess_id   IN     VARCHAR2,
                                 p_time             DATE,
                                 data           OUT SYS_REFCURSOR)
    IS
        l_id     NUMBER;
        l_code   VARCHAR2 (40);
    BEGIN
        parseSessId (p_sess_id, l_id, l_code);

        OPEN data FOR
            SELECT TRUNC ((pus_end_dt - SYSDATE) * 24 * 60 * 60)
                       AS ExpiredSeconds,
                   pus_id || '-' || pus_code
                       AS sess_id,
                   s.*
              FROM portal_user_session s
             WHERE     pus_id = l_id
                   AND pus_code = l_code
                   AND pus_end_dt >= p_time;
    END;

    PROCEDURE CloseSession (p_sess_id IN VARCHAR2)
    IS
        l_id     NUMBER;
        l_code   VARCHAR2 (40);
    BEGIN
        parseSessId (p_sess_id, l_id, l_code);

        UPDATE portal_user_session
           SET HISTORY_STATUS = 'D', pus_end_dt = SYSDATE
         WHERE pus_id = l_id AND pus_code = l_code;
    END;

    PROCEDURE CmesAuth (p_Cert_Serial          VARCHAR2,
                        p_Cert_Issuer_Cn       VARCHAR2,
                        p_Cmes_Id              NUMBER,
                        p_Cu_Id            OUT NUMBER)
    IS
    BEGIN
        IF (NOT api$cmes_auth.Authenticate (
                    p_Cert_Serial      => p_Cert_Serial,
                    p_Cert_Issuer_Cn   => p_Cert_Issuer_Cn,
                    p_Cmes_Id          => p_Cmes_Id,
                    p_Cu_Id            => p_Cu_Id))
        THEN
            raise_application_error (
                -20000,
                'Вас не зареєстровано користувачем КМЕС.');
        END IF;
    END;

    PROCEDURE AutoAuth (p_numident       VARCHAR2,
                        p_name           VARCHAR2,
                        p_type           VARCHAR2,
                        p_user_id    OUT NUMBER)
    IS
    BEGIN
        SELECT au_id
          INTO p_user_id
          FROM AUTO_USER
         WHERE au_numident = p_numident AND au_tp = p_type;

        -- If a row exists, update the corresponding name
        UPDATE AUTO_USER
           SET au_name = p_name
         WHERE au_id = p_user_id;
    -- If a row does not exist, insert a new row with the given values
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            INSERT INTO AUTO_USER (au_numident,
                                   au_tp,
                                   au_reg_dt,
                                   au_name)
                 VALUES (p_numident,
                         p_type,
                         SYSDATE,
                         p_name)
              RETURNING au_id
                   INTO p_user_id;
    END;
END portal$session;
/