/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_FILES
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    PROCEDURE insert_rpt_files (p_rf_rpt    NUMBER,
                                p_rf_data   BLOB,
                                p_rf_name   VARCHAR2);

    PROCEDURE update_rpt_files (p_rf_id     NUMBER,
                                p_rf_data   BLOB DEFAULT NULL,
                                p_rf_name   VARCHAR2 DEFAULT NULL);

    PROCEDURE delete_rpt_files (p_rf_id NUMBER);
END API$RPT_FILES;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_FILES
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    msgCOMMON_EXCEPTION   NUMBER := 2;

    PROCEDURE insert_rpt_files (p_rf_rpt    NUMBER,
                                p_rf_data   BLOB,
                                p_rf_name   VARCHAR2)
    IS
    BEGIN
        INSERT INTO RPT_FILES (rf_id,
                               rf_rpt,
                               rf_data,
                               rf_name)
             VALUES (0,
                     p_rf_rpt,
                     p_rf_data,
                     p_rf_name);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_FILES.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_rpt_files (p_rf_id     NUMBER,
                                p_rf_data   BLOB DEFAULT NULL,
                                p_rf_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        UPDATE RPT_FILES
           SET rf_data = NVL (p_rf_data, rf_data),
               rf_name = NVL (p_rf_name, rf_name)
         WHERE rf_id = p_rf_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_FILES.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE delete_rpt_files (p_rf_id NUMBER)
    IS
    BEGIN
        DELETE FROM RPT_FILES
              WHERE rf_id = p_rf_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$RPT_FILES.delete: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
END API$RPT_FILES;
/