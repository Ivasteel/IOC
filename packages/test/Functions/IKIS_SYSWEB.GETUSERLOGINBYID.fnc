/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.GetUserLoginById (
    p_user_id   IN ikis_sysweb.w_users.wu_id%TYPE)
    RETURN ikis_sysweb.w_users.wu_login%TYPE
IS
    l_wu_login   w_users.wu_login%TYPE;
BEGIN
    SELECT u.wu_login
      INTO l_wu_login
      FROM ikis_sysweb.w_users u
     WHERE 1 = 1 AND u.wu_id = p_user_id;

    RETURN l_wu_login;
END GetUserLoginById;
/


GRANT EXECUTE ON IKIS_SYSWEB.GETUSERLOGINBYID TO IKIS_PERSON
/
