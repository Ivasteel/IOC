/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.GET_USERINFO4OK (
    p_login      IN     VARCHAR2,
    p_wu_id      IN     VARCHAR2,
    p_numident      OUT VARCHAR2,
    p_fio           OUT VARCHAR2)
IS
    l_wu_id   NUMBER (14);
BEGIN
    IF p_wu_id IS NULL
    THEN
        SELECT wu.wu_id
          INTO l_wu_id
          FROM w_users wu
         WHERE wu.wu_login = UPPER (p_login);
    ELSE
        l_wu_id := p_wu_id;
    END IF;

    SELECT wu.wu_numid, wu.wu_pib
      INTO p_numident, p_fio
      FROM w_users wu
     WHERE wu.wu_id = l_wu_id;
EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END GET_USERINFO4OK;
/
