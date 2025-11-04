/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.GetUserAttr_ex (
    p_username       w_users.wu_login%TYPE,
    p_uid        OUT w_users.wu_id%TYPE,
    p_wut        OUT w_users.wu_wut%TYPE,
    p_org        OUT w_users.wu_org%TYPE,
    p_org_org    OUT w_users.wu_org_org%TYPE,
    p_trc        OUT w_users.wu_trc%TYPE)
IS
BEGIN
    BEGIN
        SELECT wu_id,
               wu_wut,
               wu_org,
               wu_trc,
               wu_org_org
          INTO p_uid,
               p_wut,
               p_org,
               p_trc,
               p_org_org
          FROM w_users
         WHERE wu_login = p_username;                             --v('USER');
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                p_wut := 0;
                p_uid := -1;
                p_org := -1;
                p_trc := 0;
                p_org_org := -1;
            END;
    END;
END;
/


CREATE OR REPLACE PUBLIC SYNONYM GETUSERATTR_EX FOR IKIS_SYSWEB.GETUSERATTR_EX
/


GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR_EX TO USS_VISIT WITH GRANT OPTION
/
