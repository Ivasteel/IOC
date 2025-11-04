/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_VERREP
IS
    -- Author  : YURA_A
    -- Created : 28.04.2009
    -- Purpose : Version Repository

    PROCEDURE CreateVersion (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE,
        p_iver_prev_ver      ikis_versions.iver_prev_ver%TYPE);

    PROCEDURE StartInstall (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE);

    PROCEDURE EndInstall (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE);

    FUNCTION GetNewSeans
        RETURN NUMBER;
END IKIS_VERREP;
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_VERREP
IS
    PROCEDURE CreateVersion (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE,
        p_iver_prev_ver      ikis_versions.iver_prev_ver%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO ikis_versions (iver_seans,
                                   iver_ss_code,
                                   iver_current_ver,
                                   iver_prev_ver)
             VALUES (p_iver_seans,
                     p_iver_ss_code,
                     p_iver_current_ver,
                     p_iver_prev_ver);

        COMMIT;
    END;

    PROCEDURE StartInstall (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE ikis_sys.ikis_versions
           SET iver_start_install = SYSDATE
         WHERE     iver_seans = p_iver_seans
               AND iver_ss_code = p_iver_ss_code
               AND iver_current_ver = p_iver_current_ver;

        COMMIT;
    END;

    PROCEDURE EndInstall (
        p_iver_seans         ikis_versions.iver_seans%TYPE,
        p_iver_ss_code       ikis_versions.iver_ss_code%TYPE,
        p_iver_current_ver   ikis_versions.iver_current_ver%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE ikis_sys.ikis_versions
           SET iver_end_install = SYSDATE
         WHERE     iver_seans = p_iver_seans
               AND iver_ss_code = p_iver_ss_code
               AND iver_current_ver = p_iver_current_ver;

        COMMIT;
    END;


    FUNCTION GetNewSeans
        RETURN NUMBER
    IS
        l_var   NUMBER;
    BEGIN
        SELECT seq_default_id.NEXTVAL INTO l_var FROM DUAL;

        RETURN l_var;
    END;
END IKIS_VERREP;
/