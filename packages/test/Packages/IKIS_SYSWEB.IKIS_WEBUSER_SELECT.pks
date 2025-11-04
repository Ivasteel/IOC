/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEBUSER_SELECT
IS
    -- Author  : MAXYM
    -- Created : 21.09.2012 11:23:29
    -- Purpose : Выдает список WEB пользователей

    -- Возвращает список незаблокированных пользователей ОПФУ обладающих определенной ролью
    PROCEDURE GetUsersXML (p_org_id      IN     w_users.wu_org%TYPE,
                           p_role_name   IN     w_roles.wr_name%TYPE,
                           p_res            OUT CLOB);
END IKIS_WEBUSER_SELECT;
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEBUSER_SELECT
IS
    PROCEDURE GetUsersXML (p_org_id      IN     w_users.wu_org%TYPE,
                           p_role_name   IN     w_roles.wr_name%TYPE,
                           p_res            OUT CLOB)
    IS
    BEGIN
        SELECT XMLELEMENT (
                   USERS,
                   XMLAGG (
                       XMLELEMENT (REC,
                                   XMLELEMENT (WU_ID, WU_ID),
                                   XMLELEMENT (WU_PIB, WU_PIB)))).GetClobVal ()
          INTO p_res
          FROM (  SELECT DISTINCT u.wu_id, u.wu_pib
                    FROM w_users u, w_usr2roles l, w_roles r
                   WHERE     u.wu_id = l.wu_id
                         AND l.wr_id = r.wr_id
                         AND u.wu_org = p_org_id
                         AND r.wr_name = p_role_name
                         AND u.wu_locked = 'N'
                ORDER BY u.wu_pib);
    END;
END IKIS_WEBUSER_SELECT;
/