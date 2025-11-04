/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_ACTIVATE
IS
    -- Author  : YURA_A
    -- Created : 24.12.2003 17:56:48
    -- Purpose : Активация ПО

    --Процедуры активации для района/области
    PROCEDURE GetNodeInfo (p_opfu       IN     VARCHAR2,
                           p_fio        IN     VARCHAR2,
                           p_numident   IN     VARCHAR2,
                           p_filename      OUT VARCHAR2,
                           p_filebody      OUT VARCHAR2);

    PROCEDURE SetNodeInfo (p_filebody IN VARCHAR2);

    PROCEDURE CheckNodeInfo;

    --Процедуры активации для центра (обработка районных/обласных сертификатов)
    PROCEDURE LoadNodeInfo (p_filebody   IN     VARCHAR2,
                            p_ice_id        OUT ikis_cert.ice_id%TYPE);

    PROCEDURE CheckCenterNodeInfo (p_ice_id ikis_cert.ice_id%TYPE);

    PROCEDURE UnLoadNodeInfo (p_ice_id         ikis_cert.ice_id%TYPE,
                              p_filename   OUT VARCHAR2,
                              p_filebody   OUT VARCHAR2);

    PROCEDURE CorrectOPFU (p_ice_id   ikis_cert.ice_id%TYPE,
                           p_opfu     opfu.org_id%TYPE);
END IKIS_ACTIVATE;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_ACTIVATE FOR IKIS_SYS.IKIS_ACTIVATE
/


GRANT EXECUTE ON IKIS_SYS.IKIS_ACTIVATE TO II01RC_IKIS_SUPERUSER
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_ACTIVATE
IS
    -- Messages for category: IKIS_ACTIVATE
    msgCOMMON_EXCEPTION      NUMBER := 2;
    msgCertAlreadyUnload     NUMBER := 1807;
    msgActivateAlreadySet    NUMBER := 1808;
    msgFileCertExist         NUMBER := 1809;
    msgInvalPwd              NUMBER := 1810;
    msgChangeOPFU            NUMBER := 1811;
    msgNotActivate           NUMBER := 1812;
    msgInvIFile              NUMBER := 1813;
    msgInvOFile              NUMBER := 1814;
    msgInvDataI              NUMBER := 1815;
    msgInvDataO              NUMBER := 1816;
    msgInvAppLevel           NUMBER := 1817;
    msgAlreadyLoadedCert     NUMBER := 1818;
    msgCertAbsent            NUMBER := 1819;
    msgNotExistCert          NUMBER := 1820;
    msgAlreadyActivated      NUMBER := 1821;
    msgOPFURNULL             NUMBER := 1822;
    msgInvFileCert           NUMBER := 1823;
    msgAlreadySetOPFU        NUMBER := 1826;
    msgInvCert               NUMBER := 1829;
    msgNotAllowCheck         NUMBER := 1853;
    msgInvLoadCert           NUMBER := 1866;
    msgCodAlrUse             NUMBER := 1867;
    msgInvCertID             NUMBER := 1868;

    --Типы проверяемых файлов
    acFileI                  NUMBER := 1;
    acFileIO                 NUMBER := 2;
    acFileO                  NUMBER := 3;

    fCertDir                 VARCHAR2 (10)
        := ikis_subsys_util.getinstancepref || 'CTLDIR';
    fCertFileI               VARCHAR2 (14)
        := ikis_subsys_util.getinstancepref || 'certi.ctc';
    fCertFileO               VARCHAR2 (14)
        := ikis_subsys_util.getinstancepref || 'certo.ctc';

    --Исключения
    exCertAlreadyUnload      EXCEPTION;
    exActivateAlreadySet     EXCEPTION;
    exFileCertExist          EXCEPTION;
    exAlreadyLoadedCert      EXCEPTION;
    exOPFURNULL              EXCEPTION;
    exAlreadySetOPFU         EXCEPTION;
    exInvCert                EXCEPTION;
    exInvLoadCert            EXCEPTION;
    exCodAlrUse              EXCEPTION;

    exInvalidFileOperation   EXCEPTION;
    PRAGMA EXCEPTION_INIT (exInvalidFileOperation, -29283);


    g_pwd                    VARCHAR2 (16) := 'A56F8C55';
    g_delm                   VARCHAR2 (1) := '|';

    ts_fmt                   VARCHAR2 (50) := 'DD/MM/YYYYHH24:MI:SS.FF6';

    g_certifname             VARCHAR2 (50)
        := 'certi' || LPAD (ikis_common.getap_ikis_opfu, 5, '0') || '.crt';
    g_certofname             VARCHAR2 (50) := 'certo<OPFU>.crt';

    errSuccess               NUMBER := 0;

    g_certid                 NUMBER;

    PROCEDURE CheckGetNodeInfoSession
    IS
        l_cnt   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        --проверить не было ли уже этого вызова, если был, то райзить экзепшн
        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_cert
         WHERE ice_tsg IS NOT NULL AND ice_id = g_certid;

        debug.f ('l_cnt %s', l_cnt);

        IF l_cnt > 0
        THEN
            debug.f ('Raise exCertAlreadyUnload');
            RAISE exCertAlreadyUnload;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exCertAlreadyUnload
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCertAlreadyUnload));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.CheckGetNodeInfoSession',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckSetNodeInfoSession
    IS
        l_cnt   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        --проверить не было ли уже этого вызова, если был, то райзить экзепшн
        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_cert
         WHERE ice_tsa IS NOT NULL AND ice_id = g_certid;

        debug.f ('l_cnt %s', l_cnt);

        IF l_cnt > 0
        THEN
            debug.f ('Raise exActivateAlreadySet');
            RAISE exActivateAlreadySet;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exActivateAlreadySet
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgActivateAlreadySet));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.CheckSetNodeInfoSession',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckFileCert (p_filetp NUMBER)
    IS
        l_fh1   UTL_FILE.file_type;
    BEGIN
        debug.f ('Start procedure');

        --проверить, может уже есть файлы сертификатов, если есть то райзить экзепшн.
        CASE p_filetp
            WHEN acFileI
            THEN
                BEGIN
                    debug.f ('Case acFileI');
                    l_fh1 := UTL_FILE.fopen (fCertDir, fCertFileI, 'r');
                    debug.f ('File opened');
                    UTL_FILE.fclose (l_fh1);
                    debug.f ('File closed and then raise exFileCertExist');
                    RAISE exFileCertExist;
                EXCEPTION
                    WHEN exInvalidFileOperation
                    THEN
                        debug.f ('Handled exInvalidFileOperation');
                    WHEN OTHERS
                    THEN
                        RAISE;
                END;
            WHEN acFileO
            THEN
                BEGIN
                    debug.f ('Case acFileO');
                    l_fh1 := UTL_FILE.fopen (fCertDir, fCertFileO, 'r');
                    debug.f ('File opened');
                    UTL_FILE.fclose (l_fh1);
                    debug.f ('File closed and then raise exFileCertExist');
                    RAISE exFileCertExist;
                EXCEPTION
                    WHEN exInvalidFileOperation
                    THEN
                        debug.f ('Handled exInvalidFileOperation');
                    WHEN OTHERS
                    THEN
                        RAISE;
                END;
            WHEN acFileIO
            THEN
                BEGIN
                    BEGIN
                        debug.f ('Case acFileIO');
                        l_fh1 := UTL_FILE.fopen (fCertDir, fCertFileI, 'r');
                        debug.f ('File opened');
                        UTL_FILE.fclose (l_fh1);
                        debug.f (
                            'File closed and then raise exFileCertExist');
                        RAISE exFileCertExist;
                    EXCEPTION
                        WHEN exInvalidFileOperation
                        THEN
                            NULL;
                        WHEN OTHERS
                        THEN
                            RAISE;
                    END;

                    BEGIN
                        l_fh1 := UTL_FILE.fopen (fCertDir, fCertFileO, 'r');
                        UTL_FILE.fclose (l_fh1);
                        RAISE exFileCertExist;
                    EXCEPTION
                        WHEN exInvalidFileOperation
                        THEN
                            debug.f ('Handled exInvalidFileOperation');
                        WHEN OTHERS
                        THEN
                            RAISE;
                    END;
                END;
            ELSE
                NULL;
        END CASE;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exFileCertExist
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgFileCertExist));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.CheckFileCert',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE GetCertData (p_opfu       IN VARCHAR2,
                           p_fio        IN VARCHAR2,
                           p_numident   IN VARCHAR2)
    IS
    BEGIN
        debug.f ('Start procedure');

        --Заполнить поля таблицы сертификатов
        INSERT INTO ikis_cert (ice_id,
                               ice_opfu,
                               ice_ts1,
                               ice_ts2,
                               ice_aopfu,
                               ice_apib,
                               ice_anum,
                               ice_tsg,
                               ice_reg_st)
             VALUES (g_certid,
                     ikis_common.getap_ikis_opfu,
                     0,
                     0,
                     SUBSTR (p_opfu, 1, 255),
                     SUBSTR (p_fio, 1, 255),
                     SUBSTR (p_numident, 1, 255),
                     SYSTIMESTAMP,
                     ikis_const.v_dds_activate_st_3);

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.GetCertData',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetCertData (p_filebody VARCHAR2)
    IS
    BEGIN
        debug.f ('Start procedure');

        --Заполнить таблицу сертификатов
        UPDATE ikis_cert
           SET ice_file2 = p_filebody
         WHERE ice_id = g_certid;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.SetCertData',
                                               CHR (10) || SQLERRM));
    END;

    FUNCTION GetData1
        RETURN VARCHAR2
    IS
        l_rec   ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        debug.f ('Stop procedure');
        RETURN    l_rec.ice_id
               || g_delm
               || l_rec.ice_opfu
               || g_delm
               || l_rec.ice_ts1
               || g_delm
               || l_rec.ice_ts2
               || g_delm
               || l_rec.ice_aopfu
               || g_delm
               || l_rec.ice_apib
               || g_delm
               || l_rec.ice_anum
               || g_delm
               || TO_CHAR (l_rec.ice_tsg, ts_fmt);
    END;

    FUNCTION GetData2 (p_ice_id ikis_cert.ice_id%TYPE)
        RETURN VARCHAR2
    IS
        l_rec   ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = p_ice_id;

        debug.f ('Stop procedure');
        RETURN    ROUND (l_rec.ice_id, -5)
               || g_delm
               || l_rec.ice_ec
               || g_delm
               || l_rec.ice_reg_st
               || g_delm
               || l_rec.ice_opfur
               || g_delm
               || TO_CHAR (l_rec.ice_tsa, ts_fmt)
               || g_delm
               || TO_CHAR (l_rec.ice_tsg, ts_fmt)
               || g_delm
               || l_rec.ice_file1;
    END;

    PROCEDURE EncryptCertData
    IS
        l_data   LONG RAW;
    BEGIN
        debug.f ('Start procedure');
        l_data :=
            ikis_crypt.encryptraw (UTL_RAW.cast_to_raw (GetData1),
                                   UTL_RAW.cast_to_raw (g_pwd));

        UPDATE ikis_cert
           SET ice_file1 = l_data
         WHERE ice_id = g_certid;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.EncryptCertData',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE DecryptCertData
    IS
        l_data       LONG RAW;
        l_rec        ikis_cert%ROWTYPE;

        l_occurr     INTEGER := 1;
        l_pos        INTEGER := 1;
        l_pos_prev   INTEGER := 1;
        l_lst        VARCHAR2 (32760);
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        debug.f ('Read data from table');
        --Расшифровать
        l_data :=
            ikis_crypt.decryptraw (TO_CHAR (l_rec.ice_file2),
                                   UTL_RAW.cast_to_raw (g_pwd));
        debug.f ('Decrypted');
        l_lst := UTL_RAW.cast_to_varchar2 (l_data) || g_delm;
        debug.f ('Start parse');

        LOOP
            l_pos :=
                INSTR (l_lst,
                       g_delm,
                       1,
                       l_occurr);
            EXIT WHEN l_pos = 0;

            --парсинг с конца
            CASE l_occurr
                WHEN 7
                THEN
                    BEGIN
                        IF NOT (l_rec.ice_file1 =
                                SUBSTR (l_lst,
                                        l_pos_prev,
                                        l_pos - l_pos_prev))
                        THEN
                            RAISE exInvLoadCert;
                        END IF;
                    END;
                WHEN 6
                THEN
                    BEGIN
                        --          if not(l_rec.ice_tsg=to_timestamp(substr(l_lst,l_pos_prev,l_pos-l_pos_prev),ts_fmt)) then
                        --            raise exInvCert;
                        --          end if;
                        NULL;
                    END;
                WHEN 5
                THEN
                    l_rec.ice_tsa :=
                        TO_TIMESTAMP (
                            SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev),
                            ts_fmt);
                WHEN 4
                THEN
                    l_rec.ice_opfur :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 3
                THEN
                    l_rec.ice_reg_st :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 2
                THEN
                    l_rec.ice_ec :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 1
                THEN
                    BEGIN
                        IF NOT (l_rec.ice_id =
                                SUBSTR (l_lst,
                                        l_pos_prev,
                                        l_pos - l_pos_prev))
                        THEN
                            raise_application_error (
                                -20000,
                                'DEBUG: Некорректний ИД записи сертификата.');
                        END IF;
                    END;
                ELSE
                    NULL;
            END CASE;

            l_occurr := l_occurr + 1;
            l_pos_prev := l_pos + 1;
        END LOOP;

        debug.f ('End parse');

        UPDATE ikis_cert
           SET ice_reg_st = l_rec.ice_reg_st,
               ice_opfur = l_rec.ice_opfur,
               ice_tsa = l_rec.ice_tsa,
               ice_ec = l_rec.ice_ec
         WHERE ice_id = g_certid;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exInvLoadCert
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvLoadCert));
        WHEN exInvCert
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvCert));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.DecryptCertData',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetFileCertI (p_filebody OUT VARCHAR2)
    IS
        l_file   UTL_FILE.file_type;
        l_rec    ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        debug.f ('Prepare to unload to file');
        --Записать в файло /home/oracle/ikiscerti.ctc
        l_file := UTL_FILE.fopen (fCertDir, fCertFileI, 'w');
        debug.f ('File opened');
        UTL_FILE.put_line (l_file, TO_CHAR (l_rec.ice_file1));
        debug.f ('File unload');
        UTL_FILE.fclose (l_file);
        debug.f ('File close');
        p_filebody := l_rec.ice_file1;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.SetFileCertI',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetFileCertO
    IS
        l_file   UTL_FILE.file_type;
        l_rec    ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        --Если активировано, то записать сертификат в /home/oracle/ikiscerto.ctc
        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        debug.f ('Prepare to unload to file');
        --Записать в файло /home/oracle/ikiscerti.ctc
        l_file := UTL_FILE.fopen (fCertDir, fCertFileO, 'w');
        debug.f ('File opened');
        UTL_FILE.put_line (l_file, TO_CHAR (l_rec.ice_file2));
        debug.f ('File unload');
        UTL_FILE.fclose (l_file);
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.SetFileCertO',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckActivateStatus
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_rec             ikis_cert%ROWTYPE;
        exNotActivate     EXCEPTION;
        exActivateError   EXCEPTION;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        --Проверить статус активации
        --Если нет вернуть экзепшн с сообщением о причине отказа
        IF l_rec.ice_reg_st IS NULL
        THEN
            debug.f ('Raise exception %s', 'exNotActivate');
            RAISE exNotActivate;
        END IF;

        IF l_rec.ice_reg_st = ikis_const.v_dds_activate_st_1
        THEN
            debug.f ('Raise exception %s', 'exActivateError');
            RAISE exActivateError;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActivate));
        WHEN exNotActivate
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActivate));
        WHEN exActivateError
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (l_rec.ice_ec));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.CheckActivateStatus',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckCertTF
    IS
        l_rec        ikis_cert%ROWTYPE;
        l_file       UTL_FILE.file_type;
        l_buff       LONG RAW;
        exInvIFile   EXCEPTION;
        exInvOFile   EXCEPTION;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        debug.f ('Check certificate I');
        --Проверить совпадение сертификатов в таблице и файловой системе
        l_file := UTL_FILE.fopen (fCertDir, fCertFileI, 'r');
        UTL_FILE.get_line (l_file, l_buff);
        UTL_FILE.fclose (l_file);

        IF NOT (l_buff = l_rec.ice_file1)
        THEN
            debug.f ('Raise exception %s', 'exInvIFile');
            RAISE exInvIFile;
        END IF;

        debug.f ('Checked certificate I');

        debug.f ('Check certificate O');
        l_file := UTL_FILE.fopen (fCertDir, fCertFileO, 'r');
        UTL_FILE.get_line (l_file, l_buff);
        UTL_FILE.fclose (l_file);

        IF NOT (l_buff = l_rec.ice_file2)
        THEN
            debug.f ('Raise exception %s', 'exInvOFile');
            RAISE exInvOFile;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActivate));
        WHEN exInvIFile
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvIFile));
        WHEN exInvOFile
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvOFile));
        WHEN exInvalidFileOperation
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvFileCert));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.CheckCertTF',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckDataCert
    IS
        l_data       LONG RAW;
        l_rec        ikis_cert%ROWTYPE;
        exInvDataI   EXCEPTION;
        exInvDataO   EXCEPTION;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        --проверить совпадение шифрованых данных сертификатов с самим сертификатом
        IF NOT (   l_rec.ice_opfu = ikis_common.getap_ikis_opfu
                OR l_rec.ice_opfur = ikis_common.getap_ikis_opfu)
        THEN
            debug.f ('Raise exception %s (%s)', 'exInvDataI', 'OPFU1');
            RAISE exInvDataI;
        END IF;

        IF NOT (l_rec.ice_file1 =
                ikis_crypt.encryptraw (UTL_RAW.cast_to_raw (GetData1),
                                       UTL_RAW.cast_to_raw (g_pwd)))
        THEN
            debug.f ('Raise exception %s (%s)', 'exInvDataI', 'FILE1');
            RAISE exInvDataI;
        END IF;

        IF NOT (l_rec.ice_opfur = ikis_common.getap_ikis_opfu)
        THEN
            debug.f ('Raise exception %s (%s)', 'exInvDataO', 'OPFU2');
            RAISE exInvDataO;
        END IF;

        IF NOT (l_rec.ice_file2 =
                ikis_crypt.encryptraw (
                    UTL_RAW.cast_to_raw (GetData2 (g_certid)),
                    UTL_RAW.cast_to_raw (g_pwd)))
        THEN
            debug.f ('Raise exception %s (%s)', 'exInvDataO', 'FILE2');
            RAISE exInvDataO;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotActivate));
        WHEN exInvDataI
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvDataI));
        WHEN exInvDataO
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvDataO));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.CheckDataCert',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE RepairOPFU
    IS
        l_rec   ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = g_certid;

        IF     l_rec.ice_reg_st = ikis_const.v_dds_activate_st_2
           AND l_rec.ice_ec = msgChangeOPFU
        THEN
            debug.f ('Repair OPFU %s', l_rec.ice_opfur);
            ikis_params.setopfu (l_rec.ice_opfur);
            DBMS_OUTPUT.put_line (
                ikis_message_util.GET_MESSAGE (l_rec.ice_ec, l_rec.ice_opfur));
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.RepairOPFU',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE GetNodeInfo (p_opfu       IN     VARCHAR2,
                           p_fio        IN     VARCHAR2,
                           p_numident   IN     VARCHAR2,
                           p_filename      OUT VARCHAR2,
                           p_filebody      OUT VARCHAR2)
    IS
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel IN
                    (ikis_const.v_dds_applevel_d, ikis_const.v_dds_applevel_r))
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel, 'GetNodeInfo'));
        END IF;

        --проверить не было ли уже этого вызова, если был, то райзить экзепшн
        CheckGetNodeInfoSession;
        --проверить, может уже есть файлы сертификатов, если есть то райзить экзепшн.
        CheckFileCert (acFileI);
        --Заполнить поля таблицы сертификатов
        GetCertData (p_opfu, p_fio, p_numident);
        --Защифровать данные таблицы
        EncryptCertData;
        --Записать в файло /home/oracle/ikiscerti.ctc
        SetFileCertI (p_filebody);
        p_filename := g_certifname;
        --Выдать файло в шестнадцатиричном представлении (зашифрованый представлен шестнадцатирично)
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.GetNodeInfo',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetNodeInfo (p_filebody VARCHAR2)
    IS
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel IN
                    (ikis_const.v_dds_applevel_d, ikis_const.v_dds_applevel_r))
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel, 'SetNodeInfo'));
        END IF;

        --проверить не было ли уже этого вызова, если был, то райзить экзепшн
        CheckSetNodeInfoSession;
        --проверить, может уже есть файлы сертификатов, если есть то райзить экзепшн.
        CheckFileCert (acFileO);

        --Заполнить таблицу сертификатов
        SetCertData (p_filebody);

        --Расшифровать
        DecryptCertData;

        RepairOPFU;
        SetFileCertO;
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.SetNodeInfo',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckNodeInfo
    IS
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel = ikis_const.v_dds_applevel_c)
        THEN
            --проверить статус активации
            CheckActivateStatus;
            --Проверить совпадение сертификатов в таблице и файловой системе
            CheckCertTF;
            --проверить совпадение шифрованых данных сертификатов с самим сертификатом
            CheckDataCert;
        END IF;

        debug.f ('Stop procedure');
    --exception
    --  when others then raise_application_error(-20000,ikis_message_util.Get_Message(msgCOMMON_EXCEPTION,'IKIS_ACTIVATE.CheckNodeInfo',chr(10)||sqlerrm));
    END;

    PROCEDURE LoadNodeInfo (p_filebody   IN     VARCHAR2,
                            p_ice_id        OUT ikis_cert.ice_id%TYPE)
    IS
        --  pragma autonomous_transaction;
        l_data       LONG RAW;
        l_rec        ikis_cert%ROWTYPE;

        l_occurr     INTEGER := 1;
        l_pos        INTEGER := 1;
        l_pos_prev   INTEGER := 1;
        l_lst        VARCHAR2 (32760);

        l_cnt        NUMBER;
        l_iter       NUMBER := 0;
        l_ice_id     ikis_cert.ice_id%TYPE;
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel = ikis_const.v_dds_applevel_c)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel,
                                               'LoadNodeInfo'));
        END IF;

        l_data :=
            ikis_crypt.decryptraw (p_filebody, UTL_RAW.cast_to_raw (g_pwd));
        debug.f ('Data decrypted');

        l_lst := UTL_RAW.cast_to_varchar2 (l_data) || g_delm;
        debug.f ('Start parse');

        LOOP
            l_pos :=
                INSTR (l_lst,
                       g_delm,
                       1,
                       l_occurr);
            EXIT WHEN l_pos = 0;

            --парсинг с конца
            --    dbms_output.put_line(l_occurr);
            --    dbms_output.put_line(substr(l_lst,l_pos_prev,l_pos-l_pos_prev));
            CASE l_occurr
                WHEN 8
                THEN
                    l_rec.ice_tsg :=
                        TO_TIMESTAMP (
                            SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev),
                            ts_fmt);
                WHEN 7
                THEN
                    l_rec.ice_anum :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 6
                THEN
                    l_rec.ice_apib :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 5
                THEN
                    l_rec.ice_aopfu :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 4
                THEN
                    l_rec.ice_ts2 :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 3
                THEN
                    l_rec.ice_ts1 :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 2
                THEN
                    l_rec.ice_opfu :=
                        SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
                WHEN 1
                THEN
                    l_rec.ice_id :=
                        TO_CHAR (
                            SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev));
                ELSE
                    NULL;
            END CASE;

            l_occurr := l_occurr + 1;
            l_pos_prev := l_pos + 1;
        END LOOP;

        debug.f ('Stop parse');
        l_ice_id := l_rec.ice_id;

        LOOP
            l_iter := l_iter + 1;
            debug.f ('Attempt load cert into table (%s)', l_iter);
            EXIT WHEN l_iter > 1000;

            debug.f ('Search cert with ID', l_rec.ice_id);

            SELECT COUNT (*)
              INTO l_cnt
              FROM ikis_cert
             WHERE ice_id = l_rec.ice_id;

            IF l_cnt = 0
            THEN
                debug.f ('Inserting cert');

                INSERT INTO ikis_cert (ice_id,
                                       ice_opfu,
                                       ice_ts1,
                                       ice_ts2,
                                       ice_aopfu,
                                       ice_apib,
                                       ice_anum,
                                       ice_tsg,
                                       ice_file1)
                     VALUES (l_rec.ice_id,
                             l_rec.ice_opfu,
                             l_rec.ice_ts1,
                             l_rec.ice_ts2,
                             l_rec.ice_aopfu,
                             l_rec.ice_apib,
                             l_rec.ice_anum,
                             l_rec.ice_tsg,
                             p_filebody);

                p_ice_id := l_rec.ice_id;
            END IF;

            EXIT WHEN l_cnt = 0;

            l_rec.ice_id := l_rec.ice_id + 1;
        END LOOP;

        COMMIT;
        debug.f ('Commited');

        IF l_iter > 1
        THEN
            debug.f ('Limit of iteration is exhausted');
            RAISE exAlreadyLoadedCert;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exAlreadyLoadedCert
        THEN
            DBMS_OUTPUT.put_line (ikis_message_util.GET_MESSAGE (
                                      msgAlreadyLoadedCert,
                                      l_ice_id,
                                      l_iter - 1,
                                      l_rec.ice_id));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.LoadNodeInfo',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckCenterNodeInfo (p_ice_id ikis_cert.ice_id%TYPE)
    IS
        l_chk   ikis_cert%ROWTYPE;
        l_cnt   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel = ikis_const.v_dds_applevel_c)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel,
                                               'CheckCenterNodeInfo'));
        END IF;

        SELECT *
          INTO l_chk
          FROM ikis_cert
         WHERE ice_id = p_ice_id;

        debug.f ('Check status of cert');

        IF l_chk.ice_reg_st NOT IN (ikis_const.V_DDS_ACTIVATE_ST_3)
        THEN
            debug.f ('Status not rule');
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotAllowCheck));
        END IF;

        debug.f ('Check double on OPFU');

        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_cert
         WHERE ice_opfur = l_chk.ice_opfu AND NOT (ice_id = l_chk.ice_id);

        IF l_cnt = 0
        THEN
            debug.f ('Double not found');

            UPDATE ikis_cert
               SET ice_reg_st = ikis_const.V_DDS_ACTIVATE_ST_0,
                   ice_tsa = SYSTIMESTAMP,
                   ice_opfur = l_chk.ice_opfu,
                   ice_ec = errSuccess
             WHERE ice_id = l_chk.ice_id;
        ELSE
            debug.f ('Double is found');

            UPDATE ikis_cert
               SET ice_reg_st = ikis_const.v_dds_activate_st_4,
                   ice_tsa = SYSTIMESTAMP,
                   ice_ec = msgAlreadyActivated
             WHERE ice_id = l_chk.ice_id;
        END IF;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCertAbsent, p_ice_id));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.CheckNodeInfo',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE UnLoadNodeInfo (p_ice_id         ikis_cert.ice_id%TYPE,
                              p_filename   OUT VARCHAR2,
                              p_filebody   OUT VARCHAR2)
    IS
        l_data   LONG RAW;
        l_rec    ikis_cert%ROWTYPE;
        l_cnt    NUMBER;
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel = ikis_const.v_dds_applevel_c)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel,
                                               'UnLoadNodeInfo'));
        END IF;

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = p_ice_id;

        debug.f ('Check OPFU in cert (%s)', l_rec.ice_opfur);

        SELECT COUNT (*)
          INTO l_cnt
          FROM opfu
         WHERE org_id = l_rec.ice_opfur;

        IF l_cnt = 0
        THEN
            debug.f ('Invalid OPFU in cert (%s)', l_rec.ice_opfur);
            RAISE exOPFURNULL;
        END IF;

        debug.f ('Calc status of cert (%s)', l_rec.ice_reg_st);

        CASE l_rec.ice_reg_st
            WHEN ikis_const.v_dds_activate_st_0
            THEN
                NULL;
            WHEN ikis_const.v_dds_activate_st_4
            THEN
                l_rec.ice_reg_st := ikis_const.v_dds_activate_st_1;
            WHEN ikis_const.v_dds_activate_st_2
            THEN
                NULL;
            ELSE
                NULL;
        END CASE;

        debug.f ('Status of cert is (%s)', l_rec.ice_reg_st);

        UPDATE ikis_cert
           SET ice_reg_st = l_rec.ice_reg_st
         WHERE ice_id = l_rec.ice_id;

        l_data :=
            ikis_crypt.encryptraw (UTL_RAW.cast_to_raw (GetData2 (p_ice_id)),
                                   UTL_RAW.cast_to_raw (g_pwd));
        debug.f ('Data is encryped');

        UPDATE ikis_cert
           SET ice_file2 = l_data
         WHERE ice_id = p_ice_id;

        p_filebody := l_data;
        p_filename :=
            REPLACE (g_certofname, '<OPFU>', LPAD (l_rec.ice_opfur, 5, '0'));
        debug.f ('File name: %s', p_filename);
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotExistCert));
        WHEN exOPFURNULL
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOPFURNULL));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_ACTIVATE.UnLoadNodeInfo',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CorrectOPFU (p_ice_id   ikis_cert.ice_id%TYPE,
                           p_opfu     opfu.org_id%TYPE)
    IS
        l_cnt   NUMBER;
        l_rec   ikis_cert%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        IF NOT (ikis_common.getap_ikis_applevel = ikis_const.v_dds_applevel_c)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvAppLevel, 'CorrectOPFU'));
        END IF;

        SELECT *
          INTO l_rec
          FROM ikis_cert
         WHERE ice_id = p_ice_id;

        debug.f ('Check status of cert (%s).', l_rec.ice_reg_st);

        IF NOT (l_rec.ice_reg_st IN
                    (ikis_const.v_dds_activate_st_4,
                     ikis_const.v_dds_activate_st_0))
        THEN
            debug.f ('Raise exception %s', 'exAlreadySetOPFU');
            RAISE exAlreadySetOPFU;
        END IF;

        debug.f ('Check OPFU on dict (%s)', p_opfu);

        SELECT COUNT (*)
          INTO l_cnt
          FROM opfu
         WHERE org_id = p_opfu;

        IF l_cnt = 0
        THEN
            debug.f ('Raise exception %s', 'exOPFURNULL');
            RAISE exOPFURNULL;
        END IF;

        debug.f ('Check OPFU on double (%s)', p_opfu);

        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_cert
         WHERE ice_opfur = p_opfu;

        IF l_cnt > 0
        THEN
            debug.f ('Raise exception %s', 'exCodAlrUse');
            RAISE exCodAlrUse;
        END IF;

        debug.f ('Set OPFU');

        UPDATE ikis_cert
           SET ikis_cert.ice_opfur = p_opfu,
               ikis_cert.ice_reg_st = ikis_const.v_dds_activate_st_2,
               ikis_cert.ice_ec = msgChangeOPFU
         WHERE ikis_cert.ice_id = p_ice_id;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exCodAlrUse
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCodAlrUse));
        WHEN exOPFURNULL
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOPFURNULL));
        WHEN exAlreadySetOPFU
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgAlreadySetOPFU));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_ACTIVATE.CorrectOPFU',
                                               CHR (10) || SQLERRM));
    END;
BEGIN
    debug.init;
    debug.f ('Start procedure (initialize)');

    IF NOT (ikis_common.getap_ikis_applevel = ikis_common.alcenter)
    THEN
        BEGIN
            debug.f ('Calc ID of cert');

            SELECT ice_id INTO g_certid FROM ikis_cert;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                debug.f ('No data found');
                g_certid := dserials.gd_serial_diapason;
            WHEN TOO_MANY_ROWS
            THEN
                debug.f ('Too many rows');
                raise_application_error (
                    -20000,
                       ikis_message_util.GET_MESSAGE (msgInvCertID)
                    || CHR (10)
                    || SQLERRM);
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       ikis_message_util.GET_MESSAGE (msgInvCertID)
                    || CHR (10)
                    || SQLERRM);
        END;
    ELSE
        g_certid := -1;
    END IF;

    debug.f ('ID of cert: %s', g_certid);
    debug.f ('Stop procedure (initialize)');
END IKIS_ACTIVATE;
/