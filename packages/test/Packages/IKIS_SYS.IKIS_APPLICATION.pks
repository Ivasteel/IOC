/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_APPLICATION
IS
    -- Author  : RYABA
    -- Created : 10.12.2004 10:59:30
    -- Purpose : Для ініціалізації даних для клієнтської частини

    PROCEDURE Init (p_app_code IN VARCHAR2, p_app_subsys IN VARCHAR2);

    PROCEDURE SetAction (p_action IN VARCHAR2);
END IKIS_APPLICATION;
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_APPLICATION
IS
    PROCEDURE Init (p_app_code IN VARCHAR2, p_app_subsys IN VARCHAR2)
    IS
    BEGIN
        DBMS_APPLICATION_INFO.set_module (p_app_code, NULL);
    END;

    PROCEDURE SetAction (p_action IN VARCHAR2)
    IS
    BEGIN
        DBMS_APPLICATION_INFO.set_action (p_action);
    END;
END IKIS_APPLICATION;
/