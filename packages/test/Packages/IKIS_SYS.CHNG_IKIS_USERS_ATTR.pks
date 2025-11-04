/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.CHNG_IKIS_USERS_ATTR
IS
    PROCEDURE INSERT_ESS (
        p_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE);

    PROCEDURE UPDATE_ESS (
        p_old_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_new_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_old_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_new_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_old_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_new_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_old_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_new_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_old_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_new_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_old_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_new_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_old_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_new_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_old_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_new_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_old_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_new_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_old_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_new_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_old_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE,
        p_new_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE);

    PROCEDURE DELETE_ESS (
        p_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE);
END CHNG_IKIS_USERS_ATTR;
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.CHNG_IKIS_USERS_ATTR
IS
    msgDeleteClose   NUMBER := 3139;

    c_ESS_CODE       NUMBER := 74;

    FUNCTION GetFieldChng (p_field_name      VARCHAR2,
                           p_old          IN VARCHAR2,
                           p_new          IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF    (NOT TRIM (p_new) = TRIM (p_old))
           OR (TRIM (p_new) IS NULL AND TRIM (p_old) IS NOT NULL)
           OR (TRIM (p_new) IS NOT NULL AND TRIM (p_old) IS NULL)
        THEN
            RETURN    p_field_name
                   || '='
                   || NVL (p_new, IKIS_CHANGES_UTL.g_EMPTY_FIELD)
                   || '#@#';
        ELSE
            RETURN '';
        END IF;
    END;

    PROCEDURE INSERT_ESS (
        p_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE)
    IS
        l_value       VARCHAR2 (500);
        l_ess_id      DECIMAL (14, 0);
        l_operation   CHAR (1);
    BEGIN
        l_ess_id := p_IUSR_ID;
        l_value :=
               'IUSR_ID='
            || NVL (TO_CHAR (p_IUSR_ID), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_NAME='
            || NVL (TO_CHAR (p_IUSR_NAME), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_NUMIDENT='
            || NVL (TO_CHAR (p_IUSR_NUMIDENT),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_IS_ADMIN='
            || NVL (TO_CHAR (p_IUSR_IS_ADMIN),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_ST='
            || NVL (TO_CHAR (p_IUSR_ST), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_LOGIN='
            || NVL (TO_CHAR (p_IUSR_LOGIN), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_INTERNAL='
            || NVL (TO_CHAR (p_IUSR_INTERNAL),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_START_DT='
            || NVL (TO_CHAR (p_IUSR_START_DT),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_STOP_DT='
            || NVL (TO_CHAR (p_IUSR_STOP_DT), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_ORG='
            || NVL (TO_CHAR (p_IUSR_ORG), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_COMP='
            || NVL (TO_CHAR (p_IUSR_COMP), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#';
        l_operation := 1;
        IKIS_CHANGES_UTL.Change (c_ESS_CODE,
                                 l_ess_id,
                                 l_operation,
                                 l_value);
    END;

    PROCEDURE UPDATE_ESS (
        p_old_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_new_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_old_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_new_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_old_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_new_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_old_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_new_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_old_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_new_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_old_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_new_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_old_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_new_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_old_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_new_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_old_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_new_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_old_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_new_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_old_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE,
        p_new_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE)
    IS
        l_value       VARCHAR2 (500);
        l_ess_id      DECIMAL (14, 0);
        l_operation   CHAR (1);
    BEGIN
        l_ess_id := p_new_IUSR_ID;
        l_value :=
               GetFieldChng ('IUSR_ID', p_old_IUSR_ID, p_new_IUSR_ID)
            || GetFieldChng ('IUSR_NAME', p_old_IUSR_NAME, p_new_IUSR_NAME)
            || GetFieldChng ('IUSR_NUMIDENT',
                             p_old_IUSR_NUMIDENT,
                             p_new_IUSR_NUMIDENT)
            || GetFieldChng ('IUSR_IS_ADMIN',
                             p_old_IUSR_IS_ADMIN,
                             p_new_IUSR_IS_ADMIN)
            || GetFieldChng ('IUSR_ST', p_old_IUSR_ST, p_new_IUSR_ST)
            || GetFieldChng ('IUSR_LOGIN',
                             p_old_IUSR_LOGIN,
                             p_new_IUSR_LOGIN)
            || GetFieldChng ('IUSR_INTERNAL',
                             p_old_IUSR_INTERNAL,
                             p_new_IUSR_INTERNAL)
            || GetFieldChng ('IUSR_START_DT',
                             p_old_IUSR_START_DT,
                             p_new_IUSR_START_DT)
            || GetFieldChng ('IUSR_STOP_DT',
                             p_old_IUSR_STOP_DT,
                             p_new_IUSR_STOP_DT)
            || GetFieldChng ('IUSR_ORG', p_old_IUSR_ORG, p_new_IUSR_ORG)
            || GetFieldChng ('IUSR_COMP', p_old_IUSR_COMP, p_new_IUSR_COMP);
        l_operation := 2;

        IF TRIM (l_value) IS NOT NULL
        THEN
            IKIS_CHANGES_UTL.Change (c_ESS_CODE,
                                     l_ess_id,
                                     l_operation,
                                     l_value);
        END IF;
    END;

    PROCEDURE DELETE_ESS (
        p_IUSR_ID         IN IKIS_USERS_ATTR.IUSR_ID%TYPE,
        p_IUSR_NAME       IN IKIS_USERS_ATTR.IUSR_NAME%TYPE,
        p_IUSR_NUMIDENT   IN IKIS_USERS_ATTR.IUSR_NUMIDENT%TYPE,
        p_IUSR_IS_ADMIN   IN IKIS_USERS_ATTR.IUSR_IS_ADMIN%TYPE,
        p_IUSR_ST         IN IKIS_USERS_ATTR.IUSR_ST%TYPE,
        p_IUSR_LOGIN      IN IKIS_USERS_ATTR.IUSR_LOGIN%TYPE,
        p_IUSR_INTERNAL   IN IKIS_USERS_ATTR.IUSR_INTERNAL%TYPE,
        p_IUSR_START_DT   IN IKIS_USERS_ATTR.IUSR_START_DT%TYPE,
        p_IUSR_STOP_DT    IN IKIS_USERS_ATTR.IUSR_STOP_DT%TYPE,
        p_IUSR_ORG        IN IKIS_USERS_ATTR.IUSR_ORG%TYPE,
        p_IUSR_COMP       IN IKIS_USERS_ATTR.IUSR_COMP%TYPE)
    IS
        l_value       VARCHAR2 (500);
        l_ess_id      DECIMAL (14, 0);
        l_operation   CHAR (1);
    BEGIN
        l_ess_id := p_IUSR_ID;
        l_value :=
               'IUSR_ID='
            || NVL (TO_CHAR (p_IUSR_ID), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_NAME='
            || NVL (TO_CHAR (p_IUSR_NAME), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_NUMIDENT='
            || NVL (TO_CHAR (p_IUSR_NUMIDENT),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_IS_ADMIN='
            || NVL (TO_CHAR (p_IUSR_IS_ADMIN),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_ST='
            || NVL (TO_CHAR (p_IUSR_ST), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_LOGIN='
            || NVL (TO_CHAR (p_IUSR_LOGIN), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_INTERNAL='
            || NVL (TO_CHAR (p_IUSR_INTERNAL),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_START_DT='
            || NVL (TO_CHAR (p_IUSR_START_DT),
                    IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_STOP_DT='
            || NVL (TO_CHAR (p_IUSR_STOP_DT), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_ORG='
            || NVL (TO_CHAR (p_IUSR_ORG), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#'
            || 'IUSR_COMP='
            || NVL (TO_CHAR (p_IUSR_COMP), IKIS_CHANGES_UTL.g_EMPTY_FIELD)
            || '#@#';
        l_operation := 3;
        IKIS_CHANGES_UTL.Change (c_ESS_CODE,
                                 l_ess_id,
                                 l_operation,
                                 l_value);
    END;
END CHNG_IKIS_USERS_ATTR;
/