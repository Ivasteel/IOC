/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_PATCH
IS
    -- Author  : YURA_A
    -- Created : 10.03.2009 11:41:06
    -- Purpose : API for web patch repository

    PROCEDURE AddPatch (p_wp_number       w_patch_rep.wp_number%TYPE,
                        p_wp_subsys       w_patch_rep.wp_subsys%TYPE,
                        p_wp_ver_subsys   w_patch_rep.wp_ver_subsys%TYPE,
                        p_force           VARCHAR2 DEFAULT 'N');

    PROCEDURE AddDependencies (
        p_wpd_number_d   w_patch_dep.wpd_number_d%TYPE,
        p_wpd_subsys_d   w_patch_dep.wpd_subsys_d%TYPE);

    PROCEDURE CheckPrereq;

    PROCEDURE StartInstall;

    PROCEDURE PatchInstalled;

    PROCEDURE SetCurrentPatch (p_wp_number   w_patch_rep.wp_number%TYPE,
                               p_wp_subsys   w_patch_rep.wp_subsys%TYPE);

    PROCEDURE IsPatchInstalled (p_wp_number   w_patch_rep.wp_number%TYPE,
                                p_wp_subsys   w_patch_rep.wp_subsys%TYPE);
END IKIS_WEB_PATCH;
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_PATCH
IS
    g_wp_number       w_patch_rep.wp_number%TYPE;
    g_wp_subsys       w_patch_rep.wp_subsys%TYPE;
    g_wp_ver_subsys   w_patch_rep.wp_ver_subsys%TYPE;

    g_column          NUMBER := 50;
    g_ver             VARCHAR2 (10) := '1.1.1.0';
    g_release_date    DATE := TO_DATE ('20090310', 'YYYYMMDD');

    PROCEDURE SetMessageLog (p_msg VARCHAR2)
    IS
        l_msg   VARCHAR2 (32760);
    BEGIN
        IF p_msg IS NOT NULL
        THEN
            l_msg :=
                TO_CHAR (SYSDATE, 'DD-MM-YYYY HH24:MI:SS') || ' > ' || p_msg;

            FOR i IN 1 .. TRUNC (LENGTH (l_msg) / 248) + 1
            LOOP
                DBMS_OUTPUT.put_line (SUBSTR (l_msg, (i - 1) * 248 + 1, 248));
            END LOOP;
        ELSE
            DBMS_OUTPUT.put_line ('');
        END IF;
    END;

    PROCEDURE Banner
    IS
    BEGIN
        SetMessageLog (RPAD ('*', g_column, '*'));
        SetMessageLog (
               RPAD ('** IKIS WEB patch repository ver.', g_column - 2, ' ')
            || '**');
        SetMessageLog (
            RPAD ('** Version: ' || g_ver, g_column - 2, ' ') || '**');
        SetMessageLog (
               RPAD (
                      '** Release Date: '
                   || TO_CHAR (g_release_date, 'YYYY-MONTH-DD'),
                   g_column - 2,
                   ' ')
            || '**');
        SetMessageLog (RPAD ('*', g_column, '*'));
    END;

    PROCEDURE CheckInitialized
    IS
    BEGIN
        IF g_wp_number IS NULL OR g_wp_subsys IS NULL
        THEN
            raise_application_error (-20000, 'Patch not initialized.');
        END IF;
    END;

    PROCEDURE IsPatchInstalled (p_wp_number   w_patch_rep.wp_number%TYPE,
                                p_wp_subsys   w_patch_rep.wp_subsys%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        Banner;

        SELECT COUNT (1)
          INTO l_cnt
          FROM w_patch_rep
         WHERE     wp_number = p_wp_number
               AND wp_subsys = p_wp_subsys
               AND wp_status IN ('S');

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'Patch: '
                || NVL (p_wp_number, 'N/A')
                || ':'
                || NVL (p_wp_subsys, 'N/A')
                || ' was not installed.');
        ELSE
            SetMessageLog (
                   'Patch: '
                || p_wp_number
                || ':'
                || p_wp_subsys
                || ' installed.');
        END IF;
    END;

    --”станавливает глобальные переменные на текущий патч, который устанавливаетс€ (если окончание установки патча просиходит с релогином
    PROCEDURE SetCurrentPatch (p_wp_number   IN w_patch_rep.wp_number%TYPE,
                               p_wp_subsys   IN w_patch_rep.wp_subsys%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM w_patch_rep
         WHERE     wp_number = p_wp_number
               AND wp_subsys = p_wp_subsys
               AND wp_status IN ('I');

        IF l_cnt = 0
        THEN
            g_wp_number := NULL;
            g_wp_subsys := NULL;
            raise_application_error (
                -20000,
                'Can"t find patch: ' || p_wp_number || ':' || p_wp_subsys);
        END IF;

        g_wp_number := UPPER (p_wp_number);
        g_wp_subsys := UPPER (p_wp_subsys);
    END;

    PROCEDURE AddPatch (p_wp_number       w_patch_rep.wp_number%TYPE,
                        p_wp_subsys       w_patch_rep.wp_subsys%TYPE,
                        p_wp_ver_subsys   w_patch_rep.wp_ver_subsys%TYPE,
                        p_force           VARCHAR2 DEFAULT 'N')
    IS
        l_cnt1   NUMBER;
        l_cnt2   NUMBER;
    BEGIN
        banner;

        g_wp_number := UPPER (p_wp_number);
        g_wp_subsys := UPPER (p_wp_subsys);
        g_wp_ver_subsys := p_wp_ver_subsys;

        SELECT SUM (DECODE (wp_status, 'I', 1, 0)),
               SUM (DECODE (wp_status, 'S', 1, 0))
          INTO l_cnt1, l_cnt2
          FROM w_patch_rep
         WHERE     wp_number = p_wp_number
               AND wp_subsys = p_wp_subsys
               AND wp_status IN ('I', 'S');

        IF l_cnt1 > 0
        THEN
            IF p_force = 'Y'
            THEN
                SetMessageLog (
                       'WARNING: force install specified for '
                    || g_wp_number
                    || ':'
                    || g_wp_subsys);
            ELSE
                raise_application_error (
                    -20000,
                       'ERROR: installing patch '
                    || p_wp_number
                    || ':'
                    || p_wp_subsys
                    || ' in progress...');
            END IF;
        END IF;

        IF l_cnt2 > 0
        THEN
            raise_application_error (
                -20000,
                   'ERROR: patch '
                || p_wp_number
                || ':'
                || p_wp_subsys
                || ' already installed.');
        END IF;


        MERGE INTO w_patch_rep trg
             USING (SELECT p_wp_number         wp_number,
                           p_wp_subsys         wp_subsys,
                           SYSDATE             wp_start_dt,
                           NULL                wp_stop_dt,
                           'N'                 wp_status,
                           g_wp_ver_subsys     wp_ver_subsys
                      FROM DUAL) src
                ON (    trg.wp_number = src.wp_number
                    AND trg.wp_subsys = src.wp_subsys)
        WHEN MATCHED
        THEN
            UPDATE SET
                trg.wp_start_dt = src.wp_start_dt,
                trg.wp_status = src.wp_status,
                trg.wp_ver_subsys = src.wp_ver_subsys
        WHEN NOT MATCHED
        THEN
            INSERT     (trg.wp_number,
                        trg.wp_subsys,
                        trg.wp_start_dt,
                        trg.wp_stop_dt,
                        trg.wp_status,
                        trg.wp_ver_subsys)
                VALUES (src.wp_number,
                        src.wp_subsys,
                        src.wp_start_dt,
                        src.wp_stop_dt,
                        src.wp_status,
                        src.wp_ver_subsys);
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                g_wp_number := NULL;
                g_wp_subsys := NULL;
                g_wp_ver_subsys := NULL;
                RAISE;
            END;
    END;

    PROCEDURE AddDependencies (
        p_wpd_number_d   w_patch_dep.wpd_number_d%TYPE,
        p_wpd_subsys_d   w_patch_dep.wpd_subsys_d%TYPE)
    IS
    BEGIN
        CheckInitialized;

        DELETE ikis_sysweb.w_patch_dep
         WHERE     wpd_number_m = g_wp_number
               AND wpd_subsys_m = g_wp_subsys
               AND wpd_number_d = p_wpd_number_d
               AND wpd_subsys_d = p_wpd_subsys_d;

        INSERT INTO w_patch_dep (wpd_number_m,
                                 wpd_subsys_m,
                                 wpd_number_d,
                                 wpd_subsys_d)
             VALUES (g_wp_number,
                     g_wp_subsys,
                     p_wpd_number_d,
                     p_wpd_subsys_d);
    END;

    PROCEDURE CheckPrereq
    IS
        l_ver     w_patch_rep.wp_ver_subsys%TYPE;
        l_cnt     NUMBER;
        l_error   BOOLEAN := FALSE;
    BEGIN
        CheckInitialized;

        --Check Version
        IF g_wp_ver_subsys IS NOT NULL
        THEN
            IF g_wp_subsys = 'IKIS_DWH_CS_PFU'
            THEN
                EXECUTE IMMEDIATE 'begin :a1:=cs_pfu.webok_common.getver; end;'
                    USING OUT l_ver;
            ELSE
                l_ver :=
                    ikis_sys.ikis_common.getapptparam (
                        p_name   => g_wp_subsys || '_VER');
            END IF;

            IF TRIM (g_wp_ver_subsys) <> TRIM (l_ver)
            THEN
                SetMessageLog (
                       'ERROR: check version for subsys '
                    || g_wp_subsys
                    || '. Need: '
                    || g_wp_ver_subsys
                    || ' Installed: '
                    || l_ver);
                l_error := TRUE;
            ELSE
                SetMessageLog (
                       'Check version for subsys '
                    || g_wp_subsys
                    || ' is OK: need: '
                    || g_wp_ver_subsys
                    || ' Installed: '
                    || l_ver);
            END IF;
        ELSE
            SetMessageLog (
                'Check version for subsys ' || g_wp_subsys || ' disabled.');
        END IF;

        --Check Dependecies
        FOR i
            IN (SELECT wpd_number_d, wpd_subsys_d
                  FROM w_patch_dep
                 WHERE     wpd_number_m = g_wp_number
                       AND wpd_subsys_m = g_wp_subsys)
        LOOP
            SELECT COUNT (1)
              INTO l_cnt
              FROM ikis_sysweb.w_patch_rep
             WHERE     wp_number = i.wpd_number_d
                   AND wp_subsys = i.wpd_subsys_d
                   AND wp_status = 'S';

            IF l_cnt = 0
            THEN
                SetMessageLog (
                       'ERROR: Dependency violation. Patch: '
                    || i.wpd_number_d
                    || ':'
                    || i.wpd_subsys_d
                    || ' absent.');
                l_error := TRUE;
            ELSE
                SetMessageLog (
                       'Dependency check: patch: '
                    || i.wpd_number_d
                    || ':'
                    || i.wpd_subsys_d
                    || ' OK.');
            END IF;
        END LOOP;

        IF l_error
        THEN
            raise_application_error (
                -20000,
                'Check error: see dbms_output messages.');
        END IF;
    END;

    PROCEDURE StartInstall
    IS
    BEGIN
        CheckInitialized;

        UPDATE w_patch_rep
           SET wp_status = 'I'
         WHERE     wp_number = g_wp_number
               AND wp_subsys = g_wp_subsys
               AND wp_status = 'N';

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (-20000, 'Can"t set "StartInstall"');
        END IF;

        SetMessageLog (
            'Start install patch: ' || g_wp_number || ':' || g_wp_subsys);
    END;

    PROCEDURE PatchInstalled
    IS
    BEGIN
        CheckInitialized;

        UPDATE w_patch_rep
           SET wp_stop_dt = SYSDATE, wp_status = 'S'
         WHERE     wp_number = g_wp_number
               AND wp_subsys = g_wp_subsys
               AND wp_status = 'I';

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (-20000, 'Can"t set "PatchInstalled"');
        END IF;

        SetMessageLog (
               'Patch: '
            || g_wp_number
            || ':'
            || g_wp_subsys
            || ' successfully installed.');
    END;
END IKIS_WEB_PATCH;
/