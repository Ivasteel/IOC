/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.get_user_attr (
    p_wu_id          w_users.wu_id%TYPE,
    p_username   OUT w_users.wu_login%TYPE,
    p_pib        OUT w_users.wu_pib%TYPE,
    p_wut        OUT w_users.wu_wut%TYPE,
    p_org        OUT w_users.wu_org%TYPE,
    p_org_org    OUT w_users.wu_org_org%TYPE,
    p_trc        OUT w_users.wu_trc%TYPE,
    p_numid      OUT w_users.wu_numid%TYPE)
IS
BEGIN
    SELECT wu.wu_login,
           wu.wu_pib,
           wu.wu_wut,
           wu.wu_org,
           wu.wu_org_org,
           wu.wu_trc,
           wu.wu_numid
      INTO p_username,
           p_pib,
           p_wut,
           p_org,
           p_org_org,
           p_trc,
           p_numid
      FROM w_users wu
     WHERE wu.wu_id = p_wu_id;
END;
/


GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO IKIS_FINZVIT
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.GET_USER_ATTR TO USS_VISIT
/
