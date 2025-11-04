/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$SUBSYSTEM2USER
IS
    -- Author  : JSHPAK
    -- Public function and procedure declarations

    PROCEDURE Delete_SubSystem2User (pwu_id NUMBER);

    PROCEDURE Insert_SubSystem2User (pwu_id NUMBER, pes_id NUMBER);
END RDM$SUBSYSTEM2USER;
/


GRANT EXECUTE ON IKIS_RBM.RDM$SUBSYSTEM2USER TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$SUBSYSTEM2USER TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$SUBSYSTEM2USER TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$SUBSYSTEM2USER
IS
    /* insert subsystem for user */
    PROCEDURE Insert_SubSystem2User (pwu_id NUMBER, pes_id NUMBER)
    IS
    BEGIN
        INSERT INTO subsystem2user (su_es, su_wu)
             VALUES (pes_id, pwu_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'IKIS_RBM_SUBSYSTEM2USER.Delete_SubSystem2User ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /* delete subsystem from user*/
    PROCEDURE Delete_SubSystem2User (pwu_id NUMBER)
    IS
    BEGIN
        DELETE FROM subsystem2user su
              WHERE su.su_wu = pwu_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'IKIS_RBM_SUBSYSTEM2USER.Delete_SubSystem2User ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    NULL;
END RDM$SUBSYSTEM2USER;
/