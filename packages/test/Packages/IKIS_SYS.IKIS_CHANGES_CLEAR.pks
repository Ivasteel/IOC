/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_CHANGES_CLEAR
    AUTHID CURRENT_USER
IS
    -- Author  : RYABA
    -- Created : 01.11.2004 9:29:43
    -- Purpose : Очищення схеми від тригерів та пакаджів аудиту

    PROCEDURE ClearSubSys (p_subsys   IN     ikis_subsys.ss_code%TYPE,
                           p_data        OUT CLOB);

    PROCEDURE DropUnExists (p_subsys   IN     ikis_subsys.ss_code%TYPE,
                            p_data        OUT CLOB);
END IKIS_CHANGES_CLEAR;
/


GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_CLEAR TO II01RC_IKIS_DESIGN
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_CHANGES_CLEAR
IS
    PROCEDURE ClearSubSys (p_subsys   IN     ikis_subsys.ss_code%TYPE,
                           p_data        OUT CLOB)
    IS
    BEGIN
        FOR vDel
            IN (SELECT *
                  FROM all_objects
                 WHERE     owner = p_subsys
                       AND (   (    object_name LIKE 'IBRC%'
                                AND object_type = 'TRIGGER')
                            OR (    object_name LIKE 'CHNG%'
                                AND object_type = 'PACKAGE')))
        LOOP
            p_data :=
                   p_data
                || 'drop '
                || vDel.object_type
                || ' '
                || vDel.object_name
                || ';'
                || CHR (10);
        END LOOP;
    END;

    PROCEDURE DropUnExists (p_subsys   IN     ikis_subsys.ss_code%TYPE,
                            p_data        OUT CLOB)
    IS
        v_res   NUMBER;
    BEGIN
        FOR vDel
            IN (  SELECT *
                    FROM all_objects
                   WHERE     owner = p_subsys
                         AND (   (    object_name LIKE 'IBRC%'
                                  AND object_type = 'TRIGGER')
                              OR (    object_name LIKE 'CHNG%'
                                  AND object_type = 'PACKAGE'))
                ORDER BY SUBSTR (object_name, 5, 30))
        LOOP
            SELECT COUNT (*)
              INTO v_res
              FROM ikis_changes_tables
             WHERE vDel.object_name LIKE '%' || ict_table_name || '%';

            IF v_res = 0
            THEN
                p_data :=
                       p_data
                    || 'drop '
                    || vDel.object_type
                    || ' '
                    || vDel.object_name
                    || ';'
                    || CHR (10);
            END IF;
        END LOOP;
    END;
END IKIS_CHANGES_CLEAR;
/