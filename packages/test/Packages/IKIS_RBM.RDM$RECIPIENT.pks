/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$RECIPIENT
IS
    -- Author  : ivashchuk
    -- Created : 08.07.2015

    PROCEDURE insert_recipient (        --   rec_id       NUMBER(14) not null,
        p_rec_name       VARCHAR2,
        p_rec_cert       BLOB,
        p_rec_cert_idn   v_recipient.rec_cert_idn%TYPE,
        p_rec_code       v_recipient.rec_code%TYPE DEFAULT NULL,
        p_rec_tp         recipient.rec_tp%TYPE DEFAULT 'IC');

    -- оновлення коду адресата/запитувача -- ivashchuk 20160216 #14353
    PROCEDURE update_rec_code (p_rec_id     v_recipient.rec_id%TYPE,
                               p_rec_code   v_recipient.rec_code%TYPE);

    -- оновлення даних адресата/запитувача -- ivashchuk 20160223 #14353
    PROCEDURE update_recipient (
        p_rec_id         v_recipient.rec_id%TYPE,
        p_rec_name       VARCHAR2,
        p_rec_cert       BLOB,
        p_rec_cert_idn   v_recipient.rec_cert_idn%TYPE,
        p_rec_code       v_recipient.rec_code%TYPE DEFAULT NULL);

    PROCEDURE mass_update_rec_code;


    PROCEDURE insert_recipient_mail (
        p_rm_rec             recipient_mail.rm_rec%TYPE,
        p_rm_name            recipient_mail.rm_name%TYPE,
        p_rm_mfo             recipient_mail.rm_mfo%TYPE,
        p_rm_filia           recipient_mail.rm_filia%TYPE,
        p_rm_mail            recipient_mail.rm_mail%TYPE,
        p_rm_cert            recipient_mail.rm_cert%TYPE,
        p_rm_cert_name       VARCHAR2,
        --p_rm_st,
        p_rm_psb             recipient_mail.rm_psb%TYPE,
        p_com_org            recipient_mail.com_org%TYPE DEFAULT ikis_rbm_context.getcontext (
                                                                     'OPFU'),
        p_rm_id          OUT recipient_mail.rm_id%TYPE);

    PROCEDURE update_recipient_mail (
        p_rm_id          recipient_mail.rm_id%TYPE,
        p_rm_name        recipient_mail.rm_name%TYPE,
        p_rm_mail        recipient_mail.rm_mail%TYPE,
        p_rm_cert        recipient_mail.rm_cert%TYPE,
        p_rm_cert_name   VARCHAR2,
        p_com_org        recipient_mail.com_org%TYPE);

    -- збереження додаткового  сертифіката
    PROCEDURE insert_rm_certificates (
        p_rmc_rm              rm_certificates.rmc_rm%TYPE,
        p_rmc_cert_name       rm_certificates.rmc_info%TYPE,
        p_rmc_id          OUT rm_certificates.rmc_id%TYPE);

    --отримання ресіпієнта (банк) по користувачу (якщо 1 користувач 1 ресіпієнт)
    FUNCTION Get_User_Rm (p_Cert_Serial VARCHAR2, p_Cert_Issuer_Cn VARCHAR2)
        RETURN NUMBER;
END RDM$RECIPIENT;
/


GRANT EXECUTE ON IKIS_RBM.RDM$RECIPIENT TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$RECIPIENT TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$RECIPIENT TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$RECIPIENT TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$RECIPIENT TO USS_ESR
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$RECIPIENT
IS
    -- Author  : OIVASHCHUK

    -- Purpose : generate pkto_id
    FUNCTION get_rec_id
        RETURN NUMBER
    IS
        l_curval   NUMBER;
    BEGIN
        SELECT SQ_ID_RECIPIENT.NEXTVAL INTO l_curval FROM DUAL;

        RETURN (l_curval);
    END get_rec_id;

    PROCEDURE insert_recipient (        --   rec_id       NUMBER(14) not null,
        p_rec_name       VARCHAR2,
        p_rec_cert       BLOB,
        p_rec_cert_idn   v_recipient.rec_cert_idn%TYPE,
        p_rec_code       v_recipient.rec_code%TYPE DEFAULT NULL,
        p_rec_tp         recipient.rec_tp%TYPE DEFAULT 'IC')
    IS
        l_rec_id   NUMBER (14);
    BEGIN
        l_rec_id := get_rec_id;

        INSERT INTO recipient (rec_id,
                               rec_name,
                               rec_cert,
                               rec_cert_idn,
                               rec_code,
                               rec_tp)
             VALUES (l_rec_id,
                     p_rec_name,
                     p_rec_cert,
                     p_rec_cert_idn,
                     p_rec_code,
                     p_rec_tp);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_packet ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- оновлення коду адресата/запитувача -- ivashchuk 20160216 #14353
    PROCEDURE update_rec_code (p_rec_id     v_recipient.rec_id%TYPE,
                               p_rec_code   v_recipient.rec_code%TYPE)
    IS
    BEGIN
        UPDATE v_recipient
           SET rec_code = p_rec_code
         WHERE rec_id = p_rec_id;
    --  if sql%rowcount=0 then raise exOptBlockViol; end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.update_rec_code: ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;


    -- оновлення даних адресата/запитувача -- ivashchuk 20160223 #14353
    PROCEDURE update_recipient (
        p_rec_id         v_recipient.rec_id%TYPE,
        p_rec_name       VARCHAR2,
        p_rec_cert       BLOB,
        p_rec_cert_idn   v_recipient.rec_cert_idn%TYPE,
        p_rec_code       v_recipient.rec_code%TYPE DEFAULT NULL)
    IS
    BEGIN
        UPDATE v_recipient
           SET rec_name = p_rec_name,
               rec_cert = p_rec_cert,
               rec_cert_idn = p_rec_cert_idn,
               rec_code = p_rec_code
         WHERE rec_id = p_rec_id;
    --  if sql%rowcount=0 then raise exOptBlockViol; end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.update_recipient: ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- оновлення коду адресата/запитувача -- ivashchuk 20160216 #14353
    PROCEDURE mass_update_rec_code
    IS
        v_list   VARCHAR2 (2000);
    BEGIN
        FOR i IN 1 .. APEX_APPLICATION.g_f02.COUNT
        LOOP
            --v_list :=  v_list  ||apex_application.g_f01(i)||' - '||apex_application.g_f02(i)||', ';
            IF NVL (APEX_APPLICATION.g_f02 (i), '-') != '-'
            THEN
                UPDATE ikis_rbm.v_recipient
                   SET rec_code =
                           CASE
                               WHEN     APEX_APPLICATION.g_f01 (i) != '-'
                                    AND EXISTS
                                            ( -- якщо запитувач ІС видалений, то запис видаляємо
                                             SELECT 1
                                               FROM ikis_rbm.infocross_requestor
                                              WHERE     irr_st = 'A'
                                                    AND irr_code =
                                                        APEX_APPLICATION.g_f01 (
                                                            i))
                               THEN
                                   APEX_APPLICATION.g_f01 (i)
                               ELSE
                                   NULL
                           END
                 WHERE rec_id = APEX_APPLICATION.g_f02 (i);
            END IF;

            IF NVL (APEX_APPLICATION.g_f02 (i), '-') = '-'
            THEN
                UPDATE ikis_rbm.v_recipient
                   SET rec_code = NULL
                 WHERE rec_code = APEX_APPLICATION.g_f01 (i);
            END IF;
        END LOOP;
    --raise_application_error(-20000, v_list);
    END;


    PROCEDURE insert_recipient_mail (
        p_rm_rec             recipient_mail.rm_rec%TYPE,
        p_rm_name            recipient_mail.rm_name%TYPE,
        p_rm_mfo             recipient_mail.rm_mfo%TYPE,
        p_rm_filia           recipient_mail.rm_filia%TYPE,
        p_rm_mail            recipient_mail.rm_mail%TYPE,
        p_rm_cert            recipient_mail.rm_cert%TYPE,
        p_rm_cert_name       VARCHAR2,
        --p_rm_st,
        p_rm_psb             recipient_mail.rm_psb%TYPE,
        p_com_org            recipient_mail.com_org%TYPE DEFAULT ikis_rbm_context.getcontext (
                                                                     'OPFU'),
        p_rm_id          OUT recipient_mail.rm_id%TYPE)
    IS
        l_rec_id         NUMBER (14);
        exNoRec          EXCEPTION;
        exNoName         EXCEPTION;
        exNoMFO          EXCEPTION;
        exNoFilia        EXCEPTION;
        exNoMail         EXCEPTION;
        exBadMail        EXCEPTION;
        exNoCert         EXCEPTION;
        exRmExists       EXCEPTION;
        exNoCert4Load    EXCEPTION;
        l_Blob_Content   BLOB;
        l_rm_cnt         NUMBER;
        l_rm_id          NUMBER;
        ldt              DATE := SYSDATE;
        l_wu             NUMBER
                             := ikis_rbm.ikis_rbm_context.GetContext ('UID');
    BEGIN
        IF p_rm_rec IS NULL
        THEN
            RAISE exNoRec;
        END IF;

        IF p_rm_name IS NULL
        THEN
            RAISE exNoName;
        END IF;

        IF p_rm_mfo IS NULL
        THEN
            RAISE exNoMFO;
        END IF;

        IF p_rm_filia IS NULL
        THEN
            RAISE exNoFilia;
        END IF;

        IF p_rm_mail IS NULL
        THEN
            RAISE exNoMail;
        END IF;

        IF NOT REGEXP_LIKE (
                   p_rm_mail,
                   '^[A-Za-z]+[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
        THEN
            RAISE exBadMail;
        END IF;

        SELECT COUNT (1)
          INTO l_rm_cnt
          FROM recipient_mail
         WHERE     rm_mfo = p_rm_mfo
               AND rm_filia = p_rm_filia
               AND rm_rec = p_rm_rec
               AND com_org = p_com_org   --ikis_rbm_context.getcontext('OPFU')
               AND rm_st = 'A';

        IF l_rm_cnt > 0
        THEN
            RAISE exRmExists;
        END IF;

        /*  select count(1)  into l_rm_cnt
          from recipient_mail
          where rm_mfo = p_rm_mfo
           and rm_psb = p_rm_psb
           and rm_rec = p_rm_rec
           and com_org =  ikis_rbm_context.getcontext('OPFU')
           and rm_st = 'A';

          if l_rm_cnt > 0 then
            raise exRmExists;
          end if;  */

        IF p_rm_cert IS NULL
        THEN
            BEGIN
                SELECT f.blob_content
                  INTO l_Blob_Content
                  FROM APEX_APPLICATION_TEMP_FILES f
                 WHERE UPPER (name) = UPPER (p_rm_cert_name);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    RAISE exNoCert4Load;
            END;

            IF l_Blob_Content IS NULL
            THEN
                RAISE exNoCert4Load; --Raise_Application_Error(-20000, q'[! Не вдалося завантажити файл:]' || p_rm_cert_name);
            END IF;

            DELETE APEX_APPLICATION_TEMP_FILES
             WHERE NAME = p_rm_cert_name AND p_rm_cert IS NULL;
        ELSE
            l_Blob_Content := p_rm_cert;
        END IF;

        IF l_Blob_Content IS NULL OR DBMS_LOB.getlength (l_Blob_Content) = 0
        THEN
            RAISE exNoCert;
        END IF;

        INSERT INTO recipient_mail (rm_id,
                                    rm_rec,
                                    rm_name,
                                    rm_mfo,
                                    rm_filia,
                                    rm_mail,
                                    rm_cert,
                                    rm_st,
                                    com_org,
                                    rm_psb)
             VALUES (NULL,
                     p_rm_rec,
                     p_rm_name,
                     p_rm_mfo,
                     p_rm_filia,
                     p_rm_mail,
                     l_Blob_Content,
                     'A',
                     NVL (p_com_org, ikis_rbm_context.getcontext ('OPFU')),
                     p_rm_psb)
          RETURNING rm_id
               INTO l_rm_id;

        INSERT INTO rm_certificates (rmc_id,
                                     rmc_rm,
                                     rmc_cert,
                                     rmc_st,
                                     rmc_info,
                                     rmc_dt,
                                     com_wu)
             VALUES (NULL,
                     l_rm_id,
                     l_Blob_Content,
                     'A',
                     p_rm_cert_name,
                     SYSDATE,
                     ikis_rbm_context.getcontext ('UID'));

        INSERT INTO rbm_audit
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'RM_NAME',
                   1,
                   NULL,
                   p_rm_name,
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'RM_MFO',
                   1,
                   NULL,
                   p_rm_mfo,
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'RM_FILIA',
                   1,
                   NULL,
                   p_rm_filia,
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'RM_MAIL',
                   1,
                   NULL,
                   p_rm_mail,
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'RM_CERT',
                   1,
                   NULL,
                   DBMS_CRYPTO.HASH (l_Blob_Content, 2),
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rm_id,
                   'COM_ORG',
                   1,
                   NULL,
                   p_com_org,
                   ldt,
                   l_wu
              FROM DUAL;

        p_rm_id := l_rm_id;
    EXCEPTION
        WHEN exNoCert4Load
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_recipient_mail ',
                   CHR (10)
                || q'[! Не вдалося завантажити файл:]'
                || p_rm_cert_name);
        WHEN exBadMail
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Некоректний формат e-mail');
        WHEN exRmExists
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_recipient_mail ',
                   CHR (10)
                || 'Для ОПФУ '
                || p_com_org                  /*ikis_rbm_context.getcontext('OPFU')*/
                || ' уже існує адресат з МФО<'
                || p_rm_mfo
                || '>, Філія<'
                || p_rm_filia
                || '>, Банк<'
                || p_rm_rec
                || '> ');
        WHEN exNoCert
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано сертифікат адресата');
        WHEN exNoMail
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано e-mail адресата');
        WHEN exNoFilia
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано філію адресата');
        WHEN exNoMFO
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано МФО адресата');
        WHEN exNoName
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано назву адресата');
        WHEN exNoRec
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Не вказано посилання на Банк');
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_recipient_mail ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_recipient_mail (
        p_rm_id          recipient_mail.rm_id%TYPE,
        p_rm_name        recipient_mail.rm_name%TYPE,
        p_rm_mail        recipient_mail.rm_mail%TYPE,
        p_rm_cert        recipient_mail.rm_cert%TYPE,
        p_rm_cert_name   VARCHAR2,
        p_com_org        recipient_mail.com_org%TYPE)
    IS
        l_rec_id         NUMBER (14);
        exNoRm           EXCEPTION;
        exBadMail        EXCEPTION;
        exNoName         EXCEPTION;
        exNoMFO          EXCEPTION;
        exNoFilia        EXCEPTION;
        exNoMail         EXCEPTION;
        exNoCert         EXCEPTION;
        exRmExists       EXCEPTION;
        l_Blob_Content   BLOB;
        l_rm_cnt         NUMBER;
        l_rm_rec         NUMBER;
        l_rm_mfo         NUMBER;
        l_rm_filia       NUMBER;
    BEGIN
        IF     p_rm_mail IS NOT NULL
           AND NOT REGEXP_LIKE (
                       p_rm_mail,
                       '^[A-Za-z]+[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
        THEN
            RAISE exBadMail;
        END IF;

        SELECT rm_mfo, rm_filia, rm_rec
          INTO l_rm_mfo, l_rm_filia, l_rm_rec
          FROM recipient_mail
         WHERE rm_id = p_rm_id;

        SELECT COUNT (1)
          INTO l_rm_cnt
          FROM recipient_mail
         WHERE     rm_mfo = l_rm_mfo                -- nvl(p_rm_mfo, l_rm_mfo)
               AND rm_filia = l_rm_filia         --nvl(p_rm_filia, l_rm_filia)
               AND rm_rec = l_rm_rec
               AND com_org = p_com_org
               AND rm_st = 'A'
               AND rm_id != p_rm_id;

        IF l_rm_cnt > 0
        THEN
            RAISE exRmExists;
        END IF;

        IF p_rm_cert IS NULL AND p_rm_cert_name IS NOT NULL
        THEN
            SELECT f.blob_content
              INTO l_Blob_Content
              FROM APEX_APPLICATION_TEMP_FILES f
             WHERE UPPER (name) = UPPER (p_rm_cert_name);

            IF l_Blob_Content IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                    q'[! Не вдалося завантажити файл:]' || p_rm_cert_name);
            END IF;

            DELETE APEX_APPLICATION_TEMP_FILES
             WHERE NAME = p_rm_cert_name AND p_rm_cert IS NULL;
        ELSE
            l_Blob_Content := p_rm_cert;
        END IF;

        IF     p_rm_mail IS NOT NULL
           AND NOT REGEXP_LIKE (
                       p_rm_mail,
                       '^[A-Za-z]+[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
        THEN
            RAISE exBadMail;
        END IF;

        UPDATE recipient_mail
           SET rm_name = NVL (p_rm_name, rm_name),
               rm_mail = NVL (p_rm_mail, rm_mail),
               rm_cert = NVL (l_Blob_Content, rm_cert),
               com_org = NVL (p_com_org, com_org)
         WHERE rm_id = p_rm_id;

        IF     l_Blob_Content IS NOT NULL
           AND DBMS_LOB.getlength (l_Blob_Content) > 0
        THEN
            INSERT INTO rm_certificates (rmc_id,
                                         rmc_rm,
                                         rmc_cert,
                                         rmc_st,
                                         rmc_info,
                                         rmc_dt,
                                         com_wu)
                 VALUES (NULL,
                         p_rm_id,
                         l_Blob_Content,
                         'A',
                         p_rm_cert_name,
                         SYSDATE,
                         ikis_rbm_context.getcontext ('UID'));
        END IF;
    EXCEPTION
        WHEN exRmExists
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_recipient_mail ',
                   CHR (10)
                || 'Для ОПФУ '
                || p_com_org                  /*ikis_rbm_context.getcontext('OPFU')*/
                || ' уже існує адресат з МФО<'
                || l_rm_mfo
                || '>, Філія<'
                || l_rm_filia
                || '>, Банк<'
                || l_rm_rec
                || '> ');
        WHEN exBadMail
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_recipient_mail ',
                          CHR (10) || 'Некоректний формат e-mail');
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.update_recipient_mail ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- збереження додаткового  сертифіката
    PROCEDURE insert_rm_certificates (
        p_rmc_rm              rm_certificates.rmc_rm%TYPE,
        p_rmc_cert_name       rm_certificates.rmc_info%TYPE,
        p_rmc_id          OUT rm_certificates.rmc_id%TYPE)
    IS
        l_rec_id         NUMBER (14);
        exNoRec          EXCEPTION;
        exNoName         EXCEPTION;
        exNoCert         EXCEPTION;
        exRmExists       EXCEPTION;
        exNoCert4Load    EXCEPTION;
        l_Blob_Content   BLOB;
        l_rm_cnt         NUMBER;
        l_rmc_id         NUMBER;
        ldt              DATE := SYSDATE;
        l_wu             NUMBER
                             := ikis_rbm.ikis_rbm_context.GetContext ('UID');
    BEGIN
        IF p_rmc_rm IS NULL
        THEN
            RAISE exNoRec;
        END IF;

        /*
        select count(1)  into l_rm_cnt
        from recipient_mail
        where rm_mfo = p_rm_mfo
         and rm_filia = p_rm_filia
         and rm_rec = p_rm_rec
         and com_org =  p_com_org --ikis_rbm_context.getcontext('OPFU')
         and rm_st = 'A';

        if l_rm_cnt > 0 then
          raise exRmExists;
        end if;*/

        BEGIN
            SELECT f.blob_content
              INTO l_Blob_Content
              FROM APEX_APPLICATION_TEMP_FILES f
             WHERE UPPER (name) = UPPER (p_rmc_cert_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE exNoCert4Load;
        END;

        IF l_Blob_Content IS NULL
        THEN
            RAISE exNoCert4Load; --Raise_Application_Error(-20000, q'[! Не вдалося завантажити файл:]' || p_rm_cert_name);
        END IF;

        DELETE APEX_APPLICATION_TEMP_FILES
         WHERE NAME = p_rmc_cert_name;

        IF l_Blob_Content IS NULL OR DBMS_LOB.getlength (l_Blob_Content) = 0
        THEN
            RAISE exNoCert;
        END IF;

        INSERT INTO rm_certificates (rmc_id,
                                     rmc_rm,
                                     rmc_cert,
                                     rmc_st,
                                     rmc_info,
                                     rmc_dt,
                                     com_wu)
             VALUES (NULL,
                     p_rmc_rm,
                     l_Blob_Content,
                     'A',
                     p_rmc_cert_name,
                     SYSDATE,
                     ikis_rbm_context.getcontext ('UID'))
          RETURNING rmc_id
               INTO l_rmc_id;

        INSERT INTO rbm_audit
            SELECT 'RM_CERTIFICATES',
                   l_rmc_id,
                   'RMC_INFO',
                   1,
                   NULL,
                   p_rmc_cert_name,
                   ldt,
                   l_wu
              FROM DUAL;

        INSERT INTO RBM_AUDIT
            SELECT 'RECIPIENT_MAIL',
                   l_rmc_id,
                   'RMC_CERT',
                   1,
                   NULL,
                   DBMS_CRYPTO.HASH (l_Blob_Content, 2),
                   ldt,
                   l_wu
              FROM DUAL;

        p_rmc_id := l_rmc_id;
    EXCEPTION
        WHEN exNoCert4Load
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_rm_certificates ',
                   CHR (10)
                || q'[! Не вдалося завантажити файл:]'
                || p_rmc_cert_name);
        WHEN exNoCert
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_rm_certificates ',
                          CHR (10) || 'Не вказано сертифікат адресата');
        WHEN exNoName
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_rm_certificates ',
                          CHR (10) || 'Не вказано назву адресата');
        WHEN exNoRec
        THEN
            ExceptionRBM ('RDM$RECIPIENT.insert_rm_certificates ',
                          CHR (10) || 'Не вказано посилання на Банк');
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$RECIPIENT.insert_rm_certificates ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    --отримання ресіпієнта (банк) по користувачу (якщо 1 користувач 1 ресіпієнт)
    FUNCTION Get_User_Rm (p_Cert_Serial VARCHAR2, p_Cert_Issuer_Cn VARCHAR2)
        RETURN NUMBER
    IS
        l_Rm_Id   NUMBER;
    BEGIN
        SELECT MAX (r.Cu2r_Cmes_Owner_Id)
          INTO l_Rm_Id
          FROM Cu_Certificates  c
               JOIN Cmes_Users u ON c.Cuc_Cu = u.Cu_Id AND u.Cu_Locked = 'F'
               JOIN Cu_Users2roles r
                   ON     u.Cu_Id = r.Cu2r_Cu
                      AND r.History_Status = 'A'
                      AND r.Cu2r_Cr = 3 --Поки зав'язуємось на те, що у користувача кабінету банка може бути лише одна роль в рамках одного банку
         WHERE     c.Cuc_Cert_Serial = p_Cert_Serial
               AND c.Cuc_Cert_Issuer = p_Cert_Issuer_Cn
               AND c.Cuc_Locked = 'F';

        RETURN l_Rm_Id;
    END;
BEGIN
    NULL;
END RDM$RECIPIENT;
/