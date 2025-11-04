/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_OBMF
IS
    -- Author  : YURA_A
    -- Created : 26.09.2003 10:59:48
    -- Purpose : Функции работи со строками

    PROCEDURE SetStr (p_str VARCHAR2, p_is_commit NUMBER DEFAULT 0);

    PROCEDURE SetStr1 (p_str VARCHAR2);

    FUNCTION GetStr
        RETURN VARCHAR2;

    FUNCTION GetStr1
        RETURN VARCHAR2;

    PROCEDURE Compare;


    PROCEDURE Install;
END IKIS_OBMF;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_OBMF FOR IKIS_SYS.IKIS_OBMF
/


GRANT EXECUTE ON IKIS_SYS.IKIS_OBMF TO II01RC_IKIS_REPL
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_OBMF
IS
    g_filename   CONSTANT VARCHAR2 (30) := 'sqwrt.ctc';
    c_tag1       CONSTANT VARCHAR2 (5) := 'D';
    c_tag2       CONSTANT VARCHAR2 (5) := 'S';

    FUNCTION Encrypt (p_str VARCHAR2)
        RETURN VARCHAR2
    IS
        input_string       VARCHAR2 (255);
        key_string         VARCHAR2 (8);
        encrypted_string   VARCHAR2 (255);
    BEGIN
        debug.f ('Start procedure');
        input_string :=
            RPAD (p_str, (TRUNC (LENGTH (p_str) / 8)) * 8 + 8, ' ');

        SELECT RPAD (aptprm_value, 8, '~')
          INTO key_string
          FROM appt_params
         WHERE aptprm_name = 'IKIS_OPFU';

        DBMS_OBFUSCATION_TOOLKIT.DESEncrypt (
            input_string       => input_string,
            key_string         => key_string,
            encrypted_string   => encrypted_string);
        debug.f ('Stop procedure');
        RETURN RAWTOHEX (UTL_RAW.CAST_TO_RAW (encrypted_string));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка строкових операцій в процедурі E'
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION Decrypt (p_str VARCHAR2)
        RETURN VARCHAR2
    IS
        key_string         VARCHAR2 (8);
        decrypted_string   VARCHAR2 (255);
    BEGIN
        debug.f ('Start procedure');

        SELECT RPAD (aptprm_value, 8, '~')
          INTO key_string
          FROM appt_params
         WHERE aptprm_name = 'IKIS_OPFU';

        DBMS_OBFUSCATION_TOOLKIT.DESDecrypt (
            input_string       => UTL_RAW.cast_to_varchar2 (HEXTORAW (p_str)),
            key_string         => key_string,
            decrypted_string   => decrypted_string);
        debug.f ('Stop procedure');
        RETURN decrypted_string;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Помилка строкових операцій в процедурі D');
    END;

    FUNCTION GetDirName
        RETURN VARCHAR2
    IS
        l_pref   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        SELECT ss_instance_pref
          INTO l_pref
          FROM ikis_subsys
         WHERE ss_code = 'IKIS_SYS';

        debug.f ('Stop procedure');
        RETURN l_pref || 'ctldir';
    END;

    FUNCTION GetFileNamePref
        RETURN VARCHAR2
    IS
        l_pref   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        SELECT ss_instance_pref
          INTO l_pref
          FROM ikis_subsys
         WHERE ss_code = 'IKIS_SYS';

        debug.f ('Stop procedure');
        RETURN l_pref;
    END;

    PROCEDURE SetStr (p_str VARCHAR2, p_is_commit NUMBER DEFAULT 0)
    IS
        l_str   VARCHAR2 (255);
    BEGIN
        IF ikis_common.GetAP_IKIS_APPLEVEL != ikis_common.alCenter
        THEN                                   --YAP 20080531 - for RAC center
            l_str := Encrypt (p_str);

            UPDATE appt_params
               SET appt_params.aptprm_value = l_str
             WHERE appt_params.aptprm_name = 'IKIS_RTS';

            IF p_is_commit = 0
            THEN
                COMMIT; --YAP 20090623 - see ikis_sys.ikis_repl_util.SetParams
            END IF;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            debug.f ('Exception: %s', SQLERRM);
            raise_application_error (
                -20000,
                   'Помилка строкових операцій в процедурі SetStr'
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE SetStr1 (p_str VARCHAR2)
    IS
        l_file   UTL_FILE.FILE_TYPE;                       -- дескриптор файла
    BEGIN
        debug.f ('Start procedure');

        IF ikis_common.GetAP_IKIS_APPLEVEL != ikis_common.alCenter
        THEN                                   --YAP 20080411 - for RAC center
            debug.f ('SetStr1');
            l_file :=
                UTL_FILE.Fopen (UPPER (GetDirName),
                                GetFileNamePref || g_filename,
                                'W',
                                4000);
            UTL_FILE.Put_Line (l_file,
                               Encrypt (c_tag1 || p_str || c_tag2),
                               TRUE);
            UTL_FILE.Fclose (l_file);
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            debug.f ('Exception: %s', SQLERRM);

            IF UTL_FILE.IS_OPEN (l_file)
            THEN
                UTL_FILE.Fclose (l_file);
            END IF;

            raise_application_error (
                -20000,
                   'Помилка строкових операцій в процедурі SetStr1'
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION GetStr
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (255);
    BEGIN
        SELECT aptprm_value
          INTO l_str
          FROM appt_params
         WHERE aptprm_name = 'IKIS_RTS';

        debug.f ('Stop procedure');
        RETURN TRIM (Decrypt (l_str));
    EXCEPTION
        WHEN OTHERS
        THEN
            debug.f ('Exception: %s', SQLERRM);
            RETURN -1;
    --  raise_application_error(-20000,'Помилка строкових операцій в процедурі GetStr');
    END;

    FUNCTION GetStr1
        RETURN VARCHAR2
    IS
        l_file   UTL_FILE.FILE_TYPE;                       -- дескриптор файла
        l_buff   VARCHAR2 (255);
    BEGIN
        debug.f ('Start procedure');

        IF ikis_common.GetAP_IKIS_APPLEVEL != ikis_common.alCenter
        THEN                                   --YAP 20080411 - for RAC center
            debug.f ('GetStr1');
            l_file :=
                UTL_FILE.Fopen (UPPER (GetDirName),
                                GetFileNamePref || g_filename,
                                'R',
                                4000);
            UTL_FILE.Get_Line (l_file, l_buff, 4000);
            UTL_FILE.Fclose (l_file);
            RETURN TRIM (
                       TRAILING c_tag2 FROM
                           TRIM (LEADING c_tag1 FROM TRIM (Decrypt (l_buff))));
        ELSE
            debug.f ('GetStr1 for center RAC');
            RETURN getstr ();
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            debug.f ('Exception: %s', SQLERRM);

            IF UTL_FILE.IS_OPEN (l_file)
            THEN
                UTL_FILE.Fclose (l_file);
            END IF;

            RETURN -1;
    --  raise_application_error(-20000,'Помилка строкових операцій в процедурі GetStr1');
    END;

    PROCEDURE Compare
    IS
        exErr      EXCEPTION;
        exCanDll   EXCEPTION;
        p1         NUMBER;
        p2         NUMBER;
        l_par      VARCHAR2 (2000);
        l_errm     VARCHAR2 (32765);

        PROCEDURE SaveException (p_msg VARCHAR2)
        IS
            PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
            EXECUTE IMMEDIATE   'insert into ikis_exception_log '
                             || '  (iel_id, iel_ipm, iel_paramvalue1, iel_date) '
                             || 'values '
                             || '  (0, 2, :p_msg, sysdate)'
                USING IN SUBSTR (p_msg, 1, 4000);

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                RAISE;
        END;
    BEGIN
        debug.f ('Start procedure');
        p1 := GetStr1;
        p2 := GetStr;

        IF NOT (p1 = p2) OR p1 = -1 OR p2 = -1
        THEN
            debug.f ('Raise %s', 'exErr');
            RAISE exErr;
        END IF;

        BEGIN
            debug.f ('Check par');
            ikis_parameter_util.getparameter ('DDL_PWD', 'IKIS_SYS', l_par);
            ikis_parameter_util.getparameter ('LOAD_STATUS_RAJON',
                                              'IKIS_ERS',
                                              l_par);

            IF     l_par = '99'
               AND ikis_common.getap_ikis_applevel = ikis_common.aldistrict
            THEN
                debug.f ('Raise %s', 'exCanDll');
                RAISE exCanDll;
            END IF;
        EXCEPTION
            WHEN exCanDll
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                NULL;
        END;
    EXCEPTION
        WHEN exCanDll
        THEN
            SaveException ('ikis_obmf.compare; exCanDll');
            SaveException ('Порушення структури системи ІКІС.');
            raise_application_error (
                -20000,
                'Порушення структури системи ІКІС. Необхідно успішно завершити процедуру логічного резервного копіювання.');
        WHEN exErr
        THEN
            SaveException ('ikis_obmf.compare; exErr');
            SaveException (
                'Порушення відповідності даних в розподіленої системі ІКІС.');
            raise_application_error (
                -20000,
                'Порушення відповідності даних в розподіленої системі ІКІС.');
        WHEN OTHERS
        THEN
            l_errm := SQLERRM;
            SaveException ('ikis_obmf.compare; others');
            SaveException (l_errm);
            raise_application_error (
                -20000,
                'Порушення цілісності даних системи ІКІС.');
    END;

    PROCEDURE Install
    IS
        l_path   VARCHAR2 (2000);
        l_dir    VARCHAR2 (2000);
        l_sys    VARCHAR2 (2000);
    BEGIN
        debug.f ('Start procedure');
        l_dir := 'create or replace directory %<NAME>% as ''%<PATH>%''';

        --Ryaba
        --3.11.2004
        --Визначаю місце встановлення контрольного файлу в залежності від операційної системи
        SELECT banner
          INTO l_sys
          FROM V$version
         WHERE banner LIKE 'TNS for%';

        --select substr(name,1,instr(name,'/',-1)) into l_path from v$controlfile where name like '%1.ctl%';
        IF INSTR (UPPER (l_sys), 'WINDOWS') > 0
        THEN
            l_path := 'c:\oracle\';
        ELSE
            l_path := '/home/oracle/';
        END IF;

        l_dir := REPLACE (l_dir, '%<NAME>%', GetDirName);
        l_dir := REPLACE (l_dir, '%<PATH>%', l_path);

        EXECUTE IMMEDIATE l_dir;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Помилка строкових операцій в процедурі I');
    END;
END IKIS_OBMF;
/