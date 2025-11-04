/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.ikis_const
IS
    --********************************************************************
    -- Усі довідники
    --********************************************************************
    -- Загальні довідник
    ----------------------------------------------------------------------
    -- Справочник:    Довідник так/ні
    -- Идентификатор: 2003
    -- Представление: V_DDW_YN
    DIC_V_DDW_YN               VARCHAR2 (10) := 2003;
    V_DDW_YN_Y                 VARCHAR2 (10) := 'Y';
    txt_V_DDW_YN_Y             VARCHAR2 (100) := 'Так';
    V_DDW_YN_N                 VARCHAR2 (10) := 'N';
    txt_V_DDW_YN_N             VARCHAR2 (100) := 'Ні';
    ----------------------------------------------------------------------
    -- Справочник:    Cтатус завантаженого файлу
    -- Идентификатор: 2004
    -- Представление: V_DDW_W_FILE_ST
    DIC_V_DDW_W_FILE_ST        VARCHAR2 (10) := 2004;
    V_DDW_W_FILE_ST_L          VARCHAR2 (10) := 'L';
    txt_V_DDW_W_FILE_ST_L      VARCHAR2 (100) := 'Завантажений';
    V_DDW_W_FILE_ST_P          VARCHAR2 (10) := 'P';
    txt_V_DDW_W_FILE_ST_P      VARCHAR2 (100) := 'Оброблений';
    V_DDW_W_FILE_ST_E          VARCHAR2 (10) := 'E';
    txt_V_DDW_W_FILE_ST_E      VARCHAR2 (100) := 'Помилковий';
    ----------------------------------------------------------------------
    -- Справочник:    Тип шаблону
    -- Идентификатор: 2005
    -- Представление: V_DDN_RT_TP
    DIC_V_DDN_RT_TP            VARCHAR2 (10) := 2005;
    V_DDN_RT_TP_R              VARCHAR2 (10) := 'R';
    txt_V_DDN_RT_TP_R          VARCHAR2 (100) := 'Вивантажувати в версії';
    V_DDN_RT_TP_D              VARCHAR2 (10) := 'D';
    txt_V_DDN_RT_TP_D          VARCHAR2 (100) := 'Не вивантажувати в версії';
    ----------------------------------------------------------------------
    -- Справочник:    Тип файлу шаблону
    -- Идентификатор: 2006
    -- Представление: V_DDN_RT_FILE_TP
    DIC_V_DDN_RT_FILE_TP       VARCHAR2 (10) := 2006;
    V_DDN_RT_FILE_TP_RTF       VARCHAR2 (10) := 'RTF';
    txt_V_DDN_RT_FILE_TP_RTF   VARCHAR2 (100) := 'Rich Text Format';
    V_DDN_RT_FILE_TP_TXT       VARCHAR2 (10) := 'TXT';
    txt_V_DDN_RT_FILE_TP_TXT   VARCHAR2 (100) := 'Text Format';
    V_DDN_RT_FILE_TP_HTM       VARCHAR2 (10) := 'HTM';
    txt_V_DDN_RT_FILE_TP_HTM   VARCHAR2 (100) := 'HTML Format';
    ----------------------------------------------------------------------
    -- Справочник:    Статус фонового завдання
    -- Идентификатор: 2007
    -- Представление: V_DDN_WJB_ST
    DIC_V_DDN_WJB_ST           VARCHAR2 (10) := 2007;
    V_DDN_WJB_ST_NEW           VARCHAR2 (10) := 'NEW';
    txt_V_DDN_WJB_ST_NEW       VARCHAR2 (100) := 'Нове';
    V_DDN_WJB_ST_RUNING        VARCHAR2 (10) := 'RUNING';
    txt_V_DDN_WJB_ST_RUNING    VARCHAR2 (100) := 'Працює';
    V_DDN_WJB_ST_ENQUEUE       VARCHAR2 (10) := 'ENQUEUE';
    txt_V_DDN_WJB_ST_ENQUEUE   VARCHAR2 (100) := 'В черзі';
    V_DDN_WJB_ST_ERROR         VARCHAR2 (10) := 'ERROR';
    txt_V_DDN_WJB_ST_ERROR     VARCHAR2 (100) := 'Завершено помилкою';
    V_DDN_WJB_ST_ENDED         VARCHAR2 (10) := 'ENDED';
    txt_V_DDN_WJB_ST_ENDED     VARCHAR2 (100) := 'Завершено';

    DIC_V_DDN_ROLE_ACT         VARCHAR2 (10) := 2008;
    V_DDN_ROLE_ACT_A           VARCHAR2 (10) := 'A';
    txt_V_DDN_ROLE_ACT_A       VARCHAR2 (100) := 'Актуальна';
    V_DDN_ROLE_ACT_D           VARCHAR2 (10) := 'D';
    txt_V_DDN_ROLE_ACT_D       VARCHAR2 (100) := 'Не актульна';
END ikis_const;
/


CREATE OR REPLACE SYNONYM IKIS_SYSWEB.IKIS_SYS_IKIS_CONST FOR IKIS_SYS.IKIS_CONST
/


CREATE OR REPLACE SYNONYM IKIS_WEBPROXY.IKIS_SYSWEB_IKIS_CONST FOR IKIS_SYSWEB.IKIS_CONST
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_CONST TO USS_VISIT
/
