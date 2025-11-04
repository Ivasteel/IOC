/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.GetUserAttr4Id (
    p_wu_id          w_users.wu_id%TYPE,
    p_username   OUT w_users.wu_login%TYPE,
    p_pib        OUT w_users.wu_pib%TYPE,
    p_wut        OUT w_users.wu_wut%TYPE,
    p_org        OUT w_users.wu_org%TYPE,
    p_org_org    OUT w_users.wu_org_org%TYPE,
    p_trc        OUT w_users.wu_trc%TYPE)
IS
BEGIN
    BEGIN
        SELECT wu.wu_login,
               wu.wu_pib,
               wu.wu_wut,
               wu.wu_org,
               wu.wu_org_org,
               wu.wu_trc
          INTO p_username,
               p_pib,
               p_wut,
               p_org,
               p_org_org,
               p_trc
          FROM w_users wu
         WHERE wu.wu_id = p_wu_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                p_username := '';
                p_pib := '';
                p_wut := 0;
                p_org := -1;
                p_org_org := -1;
                p_trc := 0;
            END;
    END;
END;
/


GRANT EXECUTE ON IKIS_SYSWEB.GETUSERATTR4ID TO IKIS_PERSON
/
