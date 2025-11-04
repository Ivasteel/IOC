/* Formatted on 8/12/2025 6:00:14 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE USS_VISIT.Split_Pib (p_Pib   IN     VARCHAR2,
                                                 p_Ln       OUT VARCHAR2,
                                                 p_Fn       OUT VARCHAR2,
                                                 p_Mn       OUT VARCHAR2)
IS
    l_Pib   VARCHAR2 (250);
BEGIN
    l_Pib := REPLACE (p_Pib, '  ', '');

        SELECT UPPER (TRIM (MAX (CASE
                                     WHEN ROWNUM = 1
                                     THEN
                                         REGEXP_SUBSTR (l_Pib,
                                                        '[^ ]+',
                                                        1,
                                                        LEVEL)
                                 END))),
               UPPER (TRIM (MAX (CASE
                                     WHEN ROWNUM = 2
                                     THEN
                                         REGEXP_SUBSTR (l_Pib,
                                                        '[^ ]+',
                                                        1,
                                                        LEVEL)
                                 END))),
               UPPER (TRIM (MAX (CASE
                                     WHEN ROWNUM = 3
                                     THEN
                                         REGEXP_SUBSTR (l_Pib,
                                                        '[^ ]+',
                                                        1,
                                                        LEVEL)
                                 END)))
          INTO p_Ln, p_Fn, p_Mn
          FROM DUAL
    CONNECT BY REGEXP_SUBSTR (l_Pib,
                              '[^ ]+',
                              1,
                              LEVEL)
                   IS NOT NULL;
END Split_Pib;
/
