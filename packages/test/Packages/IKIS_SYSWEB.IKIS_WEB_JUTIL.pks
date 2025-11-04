/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_JUTIL
IS
    -- Author  : Slaviq
    -- Created : 03.05.07
    -- Purpose : Робота з DBF и ZIP через BLOB

    -- Формирует на выходе BLOB с DBF (dBase III, CP866 - DOS)
    -- На входе требеует:
    --   pParamFld - через "|" по строчно описание полей, а именно:
    --     Имя|Тип|Размер|Кол.зн.после зап., например 'DELO|C|12|0'CHR(13)||CHR(10)||'FIO|C|50|0'||CHR(13)||CHR(10);
    --   pDataOfFld - через "|" по строчно перчисление значений полей, например
    --     pnf_number||'| '||prt_name||CHR(13)||CHR(10) - обязательно перед следующим значением должен быть пробел ('| ')!
    --     это нужно для выявления пустых (Null) значений при разборе строчки и пайпочек, если будит '||||...'
    --     строка пропустится до следующего пайпа с данными
    --  pCnt - количество строк будующего ДБФ

    --+Slaviq
    -- Формирует на выходе BLOB с DBF файлом на вход идет CLOB с описанием полей и CLOB с данными
    --пример работы смотреть в ikis_mil.WEB$Report
    FUNCTION getDBF2Strm (pParamFld    IN CLOB,
                          pDataOfFld   IN CLOB,
                          pCnt         IN NUMBER)
        RETURN BLOB;

    -- Формирует на выходе BLOB с ZIP файлом полученный на основании входящего массива объектов
    FUNCTION getZipFromStrms (pFilesArr IN tbl_some_files)
        RETURN BLOB;

    -- Формирует на выходе массив объектов (BLOBов) с файлами из ZIP BLOBа
    PROCEDURE getStrmsFromZip (src IN BLOB, dst IN OUT tbl_some_files);

    -- Sbond
    --Данные функции работают только на ikisdb (на mil и на ceped не установлена)
    FUNCTION getZipFromStrmsCyr (pFilesArr IN tbl_some_files)
        RETURN BLOB;

    PROCEDURE getStrmsFromZipCyr (src IN BLOB, dst IN OUT tbl_some_files);

    --используеться для распаковки формата zip64
    --Данная функция работает только на ikisdb (на mil и на ceped не установлена)
    PROCEDURE getStrmsFromZipZipDvs64 (src   IN     BLOB,
                                       dst   IN OUT tbl_some_files_ext);
END IKIS_WEB_JUTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_WEB_JUTIL FOR IKIS_SYSWEB.IKIS_WEB_JUTIL
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_JUTIL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_JUTIL
IS
    FUNCTION getDBF2Strm (pParamFld    IN CLOB,
                          pDataOfFld   IN CLOB,
                          pCnt         IN NUMBER)
        RETURN BLOB
    AS
        LANGUAGE JAVA
        NAME 'getDBF.getDBF2Strm (oracle.sql.CLOB, oracle.sql.CLOB, int) return oracle.sql.BLOB' ;

    /*
    function getZipFromStrms (pFilesArr in tbl_some_files) return BLOB
    AS
      LANGUAGE JAVA
      NAME 'zip_util.ZipBlobs (oracle.sql.ARRAY) return oracle.sql.BLOB';*/
    FUNCTION getZipFromStrms (pFilesArr IN tbl_some_files)
        RETURN BLOB
    AS
        LANGUAGE JAVA
        NAME 'zip_util.ZipBlobs (oracle.sql.ARRAY) return oracle.sql.BLOB' ;

    PROCEDURE getStrmsFromZip (src IN BLOB, dst IN OUT tbl_some_files)
    AS
        LANGUAGE JAVA
        NAME 'zip_util.unpackBlob(oracle.sql.BLOB, oracle.sql.ARRAY[])' ;

    --Данная функция работает только на ikisdb (на mil и на ceped не установлена)
    FUNCTION getZipFromStrmsCyr (pFilesArr IN tbl_some_files)
        RETURN BLOB
    AS
        LANGUAGE JAVA
        NAME 'zip_util.ZipBlobsCyr (oracle.sql.ARRAY) return oracle.sql.BLOB' ;

    --Данная функция работает только на ikisdb (на mil и на ceped не установлена)
    PROCEDURE getStrmsFromZipCyr (src IN BLOB, dst IN OUT tbl_some_files)
    AS
        LANGUAGE JAVA
        NAME 'zip_util.unpackBlobCyr(oracle.sql.BLOB, oracle.sql.ARRAY[])' ;

    --используеться для распаковки формата zip64
    --Данная функция работает только на ikisdb (на mil и на ceped не установлена)
    PROCEDURE getStrmsFromZipZipDvs64 (src   IN     BLOB,
                                       dst   IN OUT tbl_some_files_ext)
    AS
        LANGUAGE JAVA
        NAME 'zip_util_dvs.unpackBlobCyr(oracle.sql.BLOB, oracle.sql.ARRAY[])' ;
BEGIN
    -- Initialization
    NULL;
END IKIS_WEB_JUTIL;
/