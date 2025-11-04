/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.LOAD_FILE_JAVA_UTIL
IS
    -- Формирует на выходе массив объектов (BLOBов) с файлами из ZIP-BLOBа
    PROCEDURE getBlobsFromZip (src     IN     BLOB,
                               dst     IN OUT tbl_file_info,
                               bsize   IN     NUMBER);

    -- Формирует на выходе массив объектов (CLOBов) с файлами из ZIP-BLOBа
    PROCEDURE getClobsFromZip (src     IN     BLOB,
                               dst     IN OUT tbl_file_info,
                               bsize   IN     NUMBER);

    -- Формирует на выходе таблицу (BLOB) с файлами из ZIP-BLOBа
    PROCEDURE getInsFromZip (src IN BLOB);

    -- Формирует на выходе CLOB CSV с динамически формируемыми названиями столбцов из запроса SQL
    PROCEDURE getClobCsvFromSql (l_sql        IN     VARCHAR2,
                                 l_headPref   IN     VARCHAR2,
                                 l_colNum     IN     NUMBER,
                                 p_out           OUT CLOB);
END LOAD_FILE_JAVA_UTIL;
/


/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.LOAD_FILE_JAVA_UTIL
IS
    -- Формирует на выходе массив объектов (CLOBов) с файлами из ZIP-BLOBа
    PROCEDURE getBlobsFromZip (src     IN     BLOB,
                               dst     IN OUT tbl_file_info,
                               bsize   IN     NUMBER)
    AS
        LANGUAGE JAVA
        NAME 'zip_util.unpackInBlob(oracle.sql.BLOB, oracle.sql.ARRAY[], int)' ;

    -- Формирует на выходе массив объектов (CLOBов) с файлами из ZIP-BLOBа
    PROCEDURE getClobsFromZip (src     IN     BLOB,
                               dst     IN OUT tbl_file_info,
                               bsize   IN     NUMBER)
    AS
        LANGUAGE JAVA
        NAME 'zip_util.unpackInClob(oracle.sql.BLOB, oracle.sql.ARRAY[], int)' ;

    -- Формирует на выходе таблицу (BLOB) с файлами из ZIP-BLOBа
    PROCEDURE getInsFromZip (src IN BLOB)
    AS
        LANGUAGE JAVA
        NAME 'zip_util.unpackBlobIns(oracle.sql.BLOB)' ;

    -- Формирует на выходе CLOB CSV с динамически формируемыми названиями столбцов из запроса SQL
    PROCEDURE getClobCsvFromSql (l_sql        IN     VARCHAR2,
                                 l_headPref   IN     VARCHAR2,
                                 l_colNum     IN     NUMBER,
                                 p_out           OUT CLOB)
    AS
        LANGUAGE JAVA
        NAME 'CsvUtil.getCsvFromSql(java.lang.String, java.lang.String, int, oracle.sql.CLOB[])' ;
BEGIN
    -- Initialization
    NULL;
END LOAD_FILE_JAVA_UTIL;
/