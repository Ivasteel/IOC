/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_CONST
IS
    --********************************************************************
    -- Усі довідники
    --********************************************************************
    -- Загальні довідники
    ----------------------------------------------------------------------
    -- Справочник:    Довідник Так/Ні
    -- Идентификатор: 2001
    -- Представление: V_DDN_BOOLEAN
    DIC_V_DDN_BOOLEAN            VARCHAR2 (10) := 2001;
    V_DDN_BOOLEAN_T              VARCHAR2 (10) := 'T';
    txt_V_DDN_BOOLEAN_T          VARCHAR2 (100) := 'так';
    V_DDN_BOOLEAN_F              VARCHAR2 (10) := 'F';
    txt_V_DDN_BOOLEAN_F          VARCHAR2 (100) := 'ні';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник типів вмісту Пакета
    -- Идентификатор: 2002
    -- Представление: V_DDN_PKT_CONTENT_TP
    DIC_V_DDN_PKT_CONTENT_TP     VARCHAR2 (10) := 2002;
    V_DDN_PKT_CONTENT_TP_F       VARCHAR2 (10) := 'F';
    txt_V_DDN_PKT_CONTENT_TP_F   VARCHAR2 (100) := 'файл';
    V_DDN_PKT_CONTENT_TP_R       VARCHAR2 (10) := 'R';
    txt_V_DDN_PKT_CONTENT_TP_R   VARCHAR2 (100) := 'запит';
    V_DDN_PKT_CONTENT_TP_T       VARCHAR2 (10) := 'T';
    txt_V_DDN_PKT_CONTENT_TP_T   VARCHAR2 (100) := 'текст';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник дії над Пакетами
    -- Идентификатор: 2003
    -- Представление: V_DDN_ACTION_TP
    DIC_V_DDN_ACTION_TP          VARCHAR2 (10) := 2003;
    V_DDN_ACTION_TP_CRT          VARCHAR2 (10) := 'CRT';
    txt_V_DDN_ACTION_TP_CRT      VARCHAR2 (100) := 'створено';
    V_DDN_ACTION_TP_SGN          VARCHAR2 (10) := 'SGN';
    txt_V_DDN_ACTION_TP_SGN      VARCHAR2 (100) := 'підписано';
    V_DDN_ACTION_TP_WDR          VARCHAR2 (10) := 'WDR';
    txt_V_DDN_ACTION_TP_WDR      VARCHAR2 (100) := 'відкликано ЕЦП';
    V_DDN_ACTION_TP_MOD          VARCHAR2 (10) := 'MOD';
    txt_V_DDN_ACTION_TP_MOD      VARCHAR2 (100) := 'скориговано';
    V_DDN_ACTION_TP_UNL          VARCHAR2 (10) := 'UNL';
    txt_V_DDN_ACTION_TP_UNL      VARCHAR2 (100) := 'вивантажено вміст';
    V_DDN_ACTION_TP_PRCS         VARCHAR2 (10) := 'PRCS';
    txt_V_DDN_ACTION_TP_PRCS     VARCHAR2 (100) := 'оброблено підсистемою';
    V_DDN_ACTION_TP_NVP          VARCHAR2 (10) := 'NVP';
    txt_V_DDN_ACTION_TP_NVP      VARCHAR2 (100) := 'на відправку';
    --********************************************************************
    -- Статуси суттєвостей
    ----------------------------------------------------------------------
    -- Справочник:    Загальний перелік статусів
    -- Идентификатор: 3001
    -- Представление: V_DDN_STATUS_ST
    DIC_V_DDN_STATUS_ST          VARCHAR2 (10) := 3001;
    V_DDN_STATUS_ST_A            VARCHAR2 (10) := 'A';
    txt_V_DDN_STATUS_ST_A        VARCHAR2 (100) := 'актуальний';
    V_DDN_STATUS_ST_D            VARCHAR2 (10) := 'D';
    txt_V_DDN_STATUS_ST_D        VARCHAR2 (100) := 'логічно видалений';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник статусів пакетів
    -- Идентификатор: 3002
    -- Представление: V_DDN_PACKET_ST
    DIC_V_DDN_PACKET_ST          VARCHAR2 (10) := 3002;
    V_DDN_PACKET_ST_N            VARCHAR2 (10) := 'N';
    txt_V_DDN_PACKET_ST_N        VARCHAR2 (100) := 'новий';
    V_DDN_PACKET_ST_M            VARCHAR2 (10) := 'M';
    txt_V_DDN_PACKET_ST_M        VARCHAR2 (100) := 'скориговано';
    V_DDN_PACKET_ST_SGN          VARCHAR2 (10) := 'SGN';
    txt_V_DDN_PACKET_ST_SGN      VARCHAR2 (100) := 'вміст підписано';
    V_DDN_PACKET_ST_SND          VARCHAR2 (10) := 'SND';
    txt_V_DDN_PACKET_ST_SND      VARCHAR2 (100) := 'відправлено';
    V_DDN_PACKET_ST_S            VARCHAR2 (10) := 'S';
    txt_V_DDN_PACKET_ST_S        VARCHAR2 (100) := 'вміст збережено';
    V_DDN_PACKET_ST_PRC          VARCHAR2 (10) := 'PRC';
    txt_V_DDN_PACKET_ST_PRC      VARCHAR2 (100) := 'оброблено';
    V_DDN_PACKET_ST_ANS          VARCHAR2 (10) := 'ANS';
    txt_V_DDN_PACKET_ST_ANS      VARCHAR2 (100) := 'отримано відповідь';
    V_DDN_PACKET_ST_NVP          VARCHAR2 (10) := 'NVP';
    txt_V_DDN_PACKET_ST_NVP      VARCHAR2 (100) := 'на відправку';
    V_DDN_PACKET_ST_D            VARCHAR2 (10) := 'D';
    txt_V_DDN_PACKET_ST_D        VARCHAR2 (100) := 'видалено';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник напрямків пакетів
    -- Идентификатор: 3003
    -- Представление: V_DDN_PKT_DIRECTION
    DIC_V_DDN_PKT_DIRECTION      VARCHAR2 (10) := 3003;
    V_DDN_PKT_DIRECTION_O        VARCHAR2 (10) := 'O';
    txt_V_DDN_PKT_DIRECTION_O    VARCHAR2 (100) := 'вихідний';
    V_DDN_PKT_DIRECTION_I        VARCHAR2 (10) := 'I';
    txt_V_DDN_PKT_DIRECTION_I    VARCHAR2 (100) := 'вхідний';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник типів підпису
    -- Идентификатор: 2004
    -- Представление: V_DDN_SIGN_TP
    DIC_V_DDN_SIGN_TP            VARCHAR2 (10) := 2004;
    V_DDN_SIGN_TP_S              VARCHAR2 (10) := 'S';
    txt_V_DDN_SIGN_TP_S          VARCHAR2 (100) := 'Cистема';
    V_DDN_SIGN_TP_U              VARCHAR2 (10) := 'U';
    txt_V_DDN_SIGN_TP_U          VARCHAR2 (100) := 'Користувач ';
    V_DDN_SIGN_TP_N              VARCHAR2 (10) := 'N';
    txt_V_DDN_SIGN_TP_N          VARCHAR2 (100) := 'Не накладається ';
END ikis_const;
/
