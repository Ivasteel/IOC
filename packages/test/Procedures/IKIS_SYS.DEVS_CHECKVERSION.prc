/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.devs_checkversion (
    p_syscode      IN VARCHAR2,
    p_subsystems   IN VARCHAR2,
    p_version      IN VARCHAR2)
IS
    l_subsystems    VARCHAR2 (250);
    l_res           NUMBER;
    l_param_value   VARCHAR2 (250);
    l_param_name    VARCHAR2 (250);
BEGIN
    --  execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
    l_subsystems := REPLACE (p_subsystems, ' ', '');

    --Проверка версии основной системы
    SELECT COUNT (*)
      INTO l_res
      FROM appt_systems
     WHERE     UPPER (TRIM (s_code)) = UPPER (TRIM (p_syscode))
           AND ',' || l_subsystems || ',' LIKE '%,' || s_sys_main || ',%'
           AND UPPER (TRIM (s_version)) = UPPER (TRIM (p_version));

    IF l_res = 0
    THEN
        raise_application_error (
            -20000,
               'Version '
            || p_version
            || ' of '
            || p_syscode
            || ' not registered.');
    END IF;

    FOR vSS
        IN (SELECT s_code,
                   ss_code,
                   CASE
                       WHEN    ss_version IS NULL
                            OR LENGTH (TRIM (ss_version)) = 0
                       THEN
                           s_version
                       ELSE
                           ss_version
                   END    version,
                   CASE
                       WHEN    ss_ver_method IS NULL
                            OR LENGTH (TRIM (ss_ver_method)) = 0
                       THEN
                           s_ver_method
                       ELSE
                           ss_ver_method
                   END    ver_method
              FROM appt_systems, appt_subsyss
             WHERE     s_code = ss_s
                   AND (   ',' || l_subsystems || ',' LIKE
                               '%,' || ss_sys || ',%'
                        OR ss_sys IS NULL))
    LOOP
        --Проверка правильности заполнения информации о № версии
        IF LENGTH (TRIM (NVL (vSS.version, ''))) = 0
        THEN
            raise_application_error (
                -20000,
                   'Version information for SUBSYS '
                || vSS.ss_code
                || ' is empty.');
        END IF;

        l_param_value := '';

        --Определяю имя параметра для вычисления версии установленной подсистемы
        IF SUBSTR (UPPER (vSS.ver_method), 1, 7) = '_' || CHR (35) || 'PARAM'
        THEN
            l_param_name :=
                SUBSTR (vSS.ver_method, 9, LENGTH (vSS.ver_method));

            SELECT COUNT (*)
              INTO l_res
              FROM appt_params
             WHERE UPPER (aptprm_name) = UPPER (l_param_name);

            IF l_res > 0
            THEN
                SELECT aptprm_value
                  INTO l_param_value
                  FROM appt_params
                 WHERE UPPER (aptprm_name) = UPPER (l_param_name);
            END IF;
        ELSIF SUBSTR (UPPER (vSS.ver_method), 1, 5) = '_#SQL'
        THEN
            l_param_name :=
                SUBSTR (vSS.ver_method, 9, LENGTH (vSS.ver_method));
        ELSIF LENGTH (TRIM (NVL (vSS.ver_method, ''))) > 0
        THEN
            raise_application_error (
                -20000,
                'Unknown method information: ' || vSS.ver_method);
        END IF;

        --Проверяю, а надо ли проверять установленность подсистемы в БД
        IF LENGTH (TRIM (NVL (l_param_value, ''))) > 0
        THEN
            IF vSS.version <> l_param_value
            THEN
                raise_application_error (
                    -20000,
                       'Versions for subsystem '
                    || vSS.ss_code
                    || ' not equeals.');
            END IF;
        END IF;
    END LOOP;

    FOR vVer
        IN (SELECT ssl_master_ver,
                   ssl_depend_s,
                   ssl_depend_ss,
                   ssl_depend_ver
              FROM appt_subsyss_link
             WHERE ssl_master_s = p_syscode AND ssl_master_ver = p_version)
    LOOP
        IF LENGTH (TRIM (NVL (vVer.ssl_depend_ss, ''))) > 0
        THEN
            --Проверка установленной версии подсистемы
            SELECT COUNT (*)
              INTO l_res
              FROM appt_subsyss
             WHERE     ss_s = vVer.ssl_depend_s
                   AND ss_code = vVer.ssl_depend_ss
                   AND ss_version = vVer.ssl_depend_ver;

            IF l_res = 0
            THEN
                raise_application_error (
                    -20000,
                       'Version '
                    || NVL (vVer.ssl_depend_ver, '')
                    || ' of subsystem '
                    || NVL (vVer.ssl_depend_ss, '')
                    || ' not installed.');
            END IF;
        ELSE
            --Проверка установленной версии системы
            SELECT COUNT (*)
              INTO l_res
              FROM appt_systems
             WHERE     s_code = vVer.ssl_depend_s
                   AND s_version = vVer.ssl_depend_ver;

            IF l_res = 0
            THEN
                raise_application_error (
                    -20000,
                       'Version '
                    || NVL (vVer.ssl_depend_ver, '')
                    || ' of system '
                    || NVL (vVer.ssl_depend_s, '')
                    || ' not installed.');
            END IF;
        END IF;
    END LOOP;
END devs_checkversion;
/


CREATE OR REPLACE PUBLIC SYNONYM DEVS_CHECKVERSION FOR IKIS_SYS.DEVS_CHECKVERSION
/


GRANT EXECUTE ON IKIS_SYS.DEVS_CHECKVERSION TO II01RC_IKIS_COMMON
/
