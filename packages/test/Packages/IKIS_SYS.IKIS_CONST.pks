/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_const
IS
    --********************************************************************
    -- Усі довідники
    --********************************************************************
    -- Загальні довідник
    ----------------------------------------------------------------------
    -- Справочник:    Стан довідникових значеннь
    -- Идентификатор: 2001
    -- Представление: V_DDS_DICS_ST
    DIC_V_DDS_DICS_ST                VARCHAR2 (10) := 2001;
    V_DDS_DICS_ST_A                  VARCHAR2 (10) := 'A';
    txt_V_DDS_DICS_ST_A              VARCHAR2 (100) := 'Актив.';
    V_DDS_DICS_ST_D                  VARCHAR2 (10) := 'D';
    txt_V_DDS_DICS_ST_D              VARCHAR2 (100) := 'Вилуч.';
    ----------------------------------------------------------------------
    -- Справочник:    Тип записів у DIC_DD
    -- Идентификатор: 2002
    -- Представление: V_DDS_DIC_DD_TP
    DIC_V_DDS_DIC_DD_TP              VARCHAR2 (10) := 2002;
    V_DDS_DIC_DD_TP_T                VARCHAR2 (10) := 'T';
    txt_V_DDS_DIC_DD_TP_T            VARCHAR2 (100) := 'Група';
    V_DDS_DIC_DD_TP_D                VARCHAR2 (10) := 'D';
    txt_V_DDS_DIC_DD_TP_D            VARCHAR2 (100) := 'Довід.';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник так/ні
    -- Идентификатор: 2003
    -- Представление: V_DDS_YN
    DIC_V_DDS_YN                     VARCHAR2 (10) := 2003;
    V_DDS_YN_Y                       VARCHAR2 (10) := 'Y';
    txt_V_DDS_YN_Y                   VARCHAR2 (100) := 'Так';
    V_DDS_YN_N                       VARCHAR2 (10) := 'N';
    txt_V_DDS_YN_N                   VARCHAR2 (100) := 'Ні';
    ----------------------------------------------------------------------
    -- Справочник:    Довідник так/ні/Невизначено
    -- Идентификатор: 2004
    -- Представление: V_DDS_YNU
    DIC_V_DDS_YNU                    VARCHAR2 (10) := 2004;
    V_DDS_YNU_Y                      VARCHAR2 (10) := 'Y';
    txt_V_DDS_YNU_Y                  VARCHAR2 (100) := 'Так';
    V_DDS_YNU_N                      VARCHAR2 (10) := 'N';
    txt_V_DDS_YNU_N                  VARCHAR2 (100) := 'Ні';
    V_DDS_YNU_U                      VARCHAR2 (10) := 'U';
    txt_V_DDS_YNU_U                  VARCHAR2 (100) := 'Не визначено';
    ----------------------------------------------------------------------
    -- Справочник:    Місяці
    -- Идентификатор: 2005
    -- Представление: V_DDS_MONTH
    DIC_V_DDS_MONTH                  VARCHAR2 (10) := 2005;
    V_DDS_MONTH_01                   VARCHAR2 (10) := '01';
    txt_V_DDS_MONTH_01               VARCHAR2 (100) := 'Січ.';
    V_DDS_MONTH_02                   VARCHAR2 (10) := '02';
    txt_V_DDS_MONTH_02               VARCHAR2 (100) := 'Лют.';
    V_DDS_MONTH_03                   VARCHAR2 (10) := '03';
    txt_V_DDS_MONTH_03               VARCHAR2 (100) := 'Бер.';
    V_DDS_MONTH_04                   VARCHAR2 (10) := '04';
    txt_V_DDS_MONTH_04               VARCHAR2 (100) := 'Квіт.';
    V_DDS_MONTH_05                   VARCHAR2 (10) := '05';
    txt_V_DDS_MONTH_05               VARCHAR2 (100) := 'Трав.';
    V_DDS_MONTH_06                   VARCHAR2 (10) := '06';
    txt_V_DDS_MONTH_06               VARCHAR2 (100) := 'Черв.';
    V_DDS_MONTH_07                   VARCHAR2 (10) := '07';
    txt_V_DDS_MONTH_07               VARCHAR2 (100) := 'Лип.';
    V_DDS_MONTH_08                   VARCHAR2 (10) := '08';
    txt_V_DDS_MONTH_08               VARCHAR2 (100) := 'Серп.';
    V_DDS_MONTH_09                   VARCHAR2 (10) := '09';
    txt_V_DDS_MONTH_09               VARCHAR2 (100) := 'Вер.';
    V_DDS_MONTH_10                   VARCHAR2 (10) := '10';
    txt_V_DDS_MONTH_10               VARCHAR2 (100) := 'Жовт.';
    V_DDS_MONTH_11                   VARCHAR2 (10) := '11';
    txt_V_DDS_MONTH_11               VARCHAR2 (100) := 'Лист.';
    V_DDS_MONTH_12                   VARCHAR2 (10) := '12';
    txt_V_DDS_MONTH_12               VARCHAR2 (100) := 'Груд.';
    ----------------------------------------------------------------------
    -- Справочник:    Типи повідомленнь
    -- Идентификатор: 2006
    -- Представление: V_DDS_MESSAGE_TP
    DIC_V_DDS_MESSAGE_TP             VARCHAR2 (10) := 2006;
    V_DDS_MESSAGE_TP_E               VARCHAR2 (10) := 'E';
    txt_V_DDS_MESSAGE_TP_E           VARCHAR2 (100) := 'Помилка';
    V_DDS_MESSAGE_TP_W               VARCHAR2 (10) := 'W';
    txt_V_DDS_MESSAGE_TP_W           VARCHAR2 (100) := 'Попередження';
    V_DDS_MESSAGE_TP_I               VARCHAR2 (10) := 'I';
    txt_V_DDS_MESSAGE_TP_I           VARCHAR2 (100) := 'Інформація';
    ----------------------------------------------------------------------
    -- Справочник:    Рівень встановлення додатка
    -- Идентификатор: 2007
    -- Представление: V_DDS_APPLEVEL
    DIC_V_DDS_APPLEVEL               VARCHAR2 (10) := 2007;
    V_DDS_APPLEVEL_D                 VARCHAR2 (10) := 'D';
    txt_V_DDS_APPLEVEL_D             VARCHAR2 (100) := 'Районий';
    V_DDS_APPLEVEL_R                 VARCHAR2 (10) := 'R';
    txt_V_DDS_APPLEVEL_R             VARCHAR2 (100) := 'Обласний';
    V_DDS_APPLEVEL_C                 VARCHAR2 (10) := 'C';
    txt_V_DDS_APPLEVEL_C             VARCHAR2 (100) := 'Центральний';
    ----------------------------------------------------------------------
    -- Справочник:    Тип параметру ІКІС
    -- Идентификатор: 2008
    -- Представление: V_DDS_PARAMETER_TP
    DIC_V_DDS_PARAMETER_TP           VARCHAR2 (10) := 2008;
    V_DDS_PARAMETER_TP_D             VARCHAR2 (10) := 'D';
    txt_V_DDS_PARAMETER_TP_D         VARCHAR2 (100) := 'Дизайнерський';
    V_DDS_PARAMETER_TP_R             VARCHAR2 (10) := 'R';
    txt_V_DDS_PARAMETER_TP_R         VARCHAR2 (100) := 'Виконавчий';
    --********************************************************************
    -- Довідники реплікатора
    ----------------------------------------------------------------------
    -- Справочник:    Типи операцій з рядком
    -- Идентификатор: 3001
    -- Представление: V_DDS_RPL_ROWOP
    DIC_V_DDS_RPL_ROWOP              VARCHAR2 (10) := 3001;
    V_DDS_RPL_ROWOP_I                VARCHAR2 (10) := 'I';
    txt_V_DDS_RPL_ROWOP_I            VARCHAR2 (100) := 'Вст.';
    V_DDS_RPL_ROWOP_U                VARCHAR2 (10) := 'U';
    txt_V_DDS_RPL_ROWOP_U            VARCHAR2 (100) := 'Оновл.';
    V_DDS_RPL_ROWOP_D                VARCHAR2 (10) := 'D';
    txt_V_DDS_RPL_ROWOP_D            VARCHAR2 (100) := 'Лог. Вил.';
    ----------------------------------------------------------------------
    -- Справочник:    Напрям руху інформації
    -- Идентификатор: 3002
    -- Представление: V_DDS_RPL_DTDIR
    DIC_V_DDS_RPL_DTDIR              VARCHAR2 (10) := 3002;
    V_DDS_RPL_DTDIR_R                VARCHAR2 (10) := 'R';
    txt_V_DDS_RPL_DTDIR_R            VARCHAR2 (100) := 'Отримання';
    V_DDS_RPL_DTDIR_S                VARCHAR2 (10) := 'S';
    txt_V_DDS_RPL_DTDIR_S            VARCHAR2 (100) := 'Відправка';
    ----------------------------------------------------------------------
    -- Справочник:    Типи потоків даних
    -- Идентификатор: 3003
    -- Представление: V_DDS_RPL_DT
    DIC_V_DDS_RPL_DT                 VARCHAR2 (10) := 3003;
    V_DDS_RPL_DT_SPOV_PZV            VARCHAR2 (10) := 'SPOV_PZV';
    txt_V_DDS_RPL_DT_SPOV_PZV        VARCHAR2 (100) := 'ПЗВ СПОВ до Центру';
    V_DDS_RPL_DT_ERS_DOCREG          VARCHAR2 (10) := 'ERS_DOCREG';
    txt_V_DDS_RPL_DT_ERS_DOCREG      VARCHAR2 (100) := 'ЄРС район-центр';
    V_DDS_RPL_DT_ERS_DOCST           VARCHAR2 (10) := 'ERS_DOCST';
    txt_V_DDS_RPL_DT_ERS_DOCST       VARCHAR2 (100) := 'Статус ЄРС центр-район';
    V_DDS_RPL_DT_ERS_CACH            VARCHAR2 (10) := 'ERS_CACH';
    txt_V_DDS_RPL_DT_ERS_CACH        VARCHAR2 (100) := 'Сплачено район-центр';
    V_DDS_RPL_DT_ERS_DOCW            VARCHAR2 (10) := 'ERS_DOCW';
    txt_V_DDS_RPL_DT_ERS_DOCW        VARCHAR2 (100) := 'ЄРСУ веєрно';
    V_DDS_RPL_DT_ERS_CACHW           VARCHAR2 (10) := 'ERS_CACHW';
    txt_V_DDS_RPL_DT_ERS_CACHW       VARCHAR2 (100) := 'Сплачено веєрно';
    V_DDS_RPL_DT_SYS_SD1             VARCHAR2 (10) := 'SYS_SD1';
    txt_V_DDS_RPL_DT_SYS_SD1         VARCHAR2 (100) := 'Системна інформация #1';
    V_DDS_RPL_DT_ERS_DOCPR           VARCHAR2 (10) := 'ERS_DOCPR';
    txt_V_DDS_RPL_DT_ERS_DOCPR       VARCHAR2 (100) := 'Прот. С-ка в центрі';
    V_DDS_RPL_DT_NDI_DICS            VARCHAR2 (10) := 'NDI_DICS';
    txt_V_DDS_RPL_DT_NDI_DICS        VARCHAR2 (100) := 'Довідники центр-райони';
    V_DDS_RPL_DT_ERS_INSMOV          VARCHAR2 (10) := 'ERS_INSMOV';
    txt_V_DDS_RPL_DT_ERS_INSMOV      VARCHAR2 (100)
                                         := 'Перехід с-ків з району в район';
    ----------------------------------------------------------------------
    -- Справочник:    Параметри сеансів реплікації
    -- Идентификатор: 3004
    -- Представление: V_DDS_RPL_PARAMS
    DIC_V_DDS_RPL_PARAMS             VARCHAR2 (10) := 3004;
    V_DDS_RPL_PARAMS_CNTR_PROT       VARCHAR2 (10) := 'CNTR_PROT';
    txt_V_DDS_RPL_PARAMS_CNTR_PROT   VARCHAR2 (100) := 'Протокол Центру';
    V_DDS_RPL_PARAMS_PACKNAME        VARCHAR2 (10) := 'PACKNAME';
    txt_V_DDS_RPL_PARAMS_PACKNAME    VARCHAR2 (100) := 'Назва пакету';
    --********************************************************************
    -- Довідники менеджера контролів
    ----------------------------------------------------------------------
    -- Справочник:    Тип параметру
    -- Идентификатор: 4001
    -- Представление: V_DDS_PARAM_TYPE
    DIC_V_DDS_PARAM_TYPE             VARCHAR2 (10) := 4001;
    V_DDS_PARAM_TYPE_T               VARCHAR2 (10) := 'T';
    txt_V_DDS_PARAM_TYPE_T           VARCHAR2 (100) := 'Текст';
    V_DDS_PARAM_TYPE_Q               VARCHAR2 (10) := 'Q';
    txt_V_DDS_PARAM_TYPE_Q           VARCHAR2 (100) := 'Результат SQL';
    V_DDS_PARAM_TYPE_V               VARCHAR2 (10) := 'V';
    txt_V_DDS_PARAM_TYPE_V           VARCHAR2 (100) := 'Змінна';
    ----------------------------------------------------------------------
    -- Справочник:    Умови формування повідомлень
    -- Идентификатор: 4002
    -- Представление: V_DDS_MSG_RES_TYPE
    DIC_V_DDS_MSG_RES_TYPE           VARCHAR2 (10) := 4002;
    V_DDS_MSG_RES_TYPE_G             VARCHAR2 (10) := 'G';
    txt_V_DDS_MSG_RES_TYPE_G         VARCHAR2 (100) := 'Контроль пройдено';
    V_DDS_MSG_RES_TYPE_B             VARCHAR2 (10) := 'B';
    txt_V_DDS_MSG_RES_TYPE_B         VARCHAR2 (100) := 'Контроль не пройдено';
    ----------------------------------------------------------------------
    -- Справочник:    Типи повідомлень
    -- Идентификатор: 4003
    -- Представление: V_DDS_MSG_TYPE
    DIC_V_DDS_MSG_TYPE               VARCHAR2 (10) := 4003;
    V_DDS_MSG_TYPE_I                 VARCHAR2 (10) := 'I';
    txt_V_DDS_MSG_TYPE_I             VARCHAR2 (100) := 'Інформація';
    V_DDS_MSG_TYPE_E                 VARCHAR2 (10) := 'E';
    txt_V_DDS_MSG_TYPE_E             VARCHAR2 (100) := 'Помилка';
    V_DDS_MSG_TYPE_W                 VARCHAR2 (10) := 'W';
    txt_V_DDS_MSG_TYPE_W             VARCHAR2 (100) := 'Попередження';
    ----------------------------------------------------------------------
    -- Справочник:    Умови виконання контролю
    -- Идентификатор: 4004
    -- Представление: V_DDS_CNTR_COND_TYPE
    DIC_V_DDS_CNTR_COND_TYPE         VARCHAR2 (10) := 4004;
    V_DDS_CNTR_COND_TYPE_I           VARCHAR2 (10) := 'I';
    txt_V_DDS_CNTR_COND_TYPE_I       VARCHAR2 (100) := 'Умова IF';
    V_DDS_CNTR_COND_TYPE_U           VARCHAR2 (10) := 'U';
    txt_V_DDS_CNTR_COND_TYPE_U       VARCHAR2 (100) := 'UPDATE';
    V_DDS_CNTR_COND_TYPE_E           VARCHAR2 (10) := 'E';
    txt_V_DDS_CNTR_COND_TYPE_E       VARCHAR2 (100) := 'Exception';
    V_DDS_CNTR_COND_TYPE_F           VARCHAR2 (10) := 'F';
    txt_V_DDS_CNTR_COND_TYPE_F       VARCHAR2 (100)
                                         := 'Умова IF та Exception';
    V_DDS_CNTR_COND_TYPE_R           VARCHAR2 (10) := 'R';
    txt_V_DDS_CNTR_COND_TYPE_R       VARCHAR2 (100) := 'User exception';
    ----------------------------------------------------------------------
    -- Справочник:    Рівні протоколювання
    -- Идентификатор: 4005
    -- Представление: V_DDS_PROT_LEVEL
    DIC_V_DDS_PROT_LEVEL             VARCHAR2 (10) := 4005;
    V_DDS_PROT_LEVEL_3               VARCHAR2 (10) := '3';
    txt_V_DDS_PROT_LEVEL_3           VARCHAR2 (100) := 'Повний';
    V_DDS_PROT_LEVEL_2               VARCHAR2 (10) := '2';
    txt_V_DDS_PROT_LEVEL_2           VARCHAR2 (100) := 'Повний помилковий';
    V_DDS_PROT_LEVEL_1               VARCHAR2 (10) := '1';
    txt_V_DDS_PROT_LEVEL_1           VARCHAR2 (100) := 'Неповний помилковий';
    V_DDS_PROT_LEVEL_0               VARCHAR2 (10) := '0';
    txt_V_DDS_PROT_LEVEL_0           VARCHAR2 (100) := 'Скорочений';
    ----------------------------------------------------------------------
    -- Справочник:    Статуси сесій контролю
    -- Идентификатор: 4006
    -- Представление: V_DDS_WORK_STATUS
    DIC_V_DDS_WORK_STATUS            VARCHAR2 (10) := 4006;
    V_DDS_WORK_STATUS_S              VARCHAR2 (10) := 'S';
    txt_V_DDS_WORK_STATUS_S          VARCHAR2 (100) := 'Не розпочалась';
    V_DDS_WORK_STATUS_A              VARCHAR2 (10) := 'A';
    txt_V_DDS_WORK_STATUS_A          VARCHAR2 (100) := 'В роботі';
    V_DDS_WORK_STATUS_C              VARCHAR2 (10) := 'C';
    txt_V_DDS_WORK_STATUS_C          VARCHAR2 (100) := 'Закінчилась';
    ----------------------------------------------------------------------
    -- Справочник:    Типи повідомлень для груп
    -- Идентификатор: 4007
    -- Представление: V_DDS_GROUP_MSG_TYPE
    DIC_V_DDS_GROUP_MSG_TYPE         VARCHAR2 (10) := 4007;
    V_DDS_GROUP_MSG_TYPE_B           VARCHAR2 (10) := 'B';
    txt_V_DDS_GROUP_MSG_TYPE_B       VARCHAR2 (100) := 'На початку';
    V_DDS_GROUP_MSG_TYPE_E           VARCHAR2 (10) := 'E';
    txt_V_DDS_GROUP_MSG_TYPE_E       VARCHAR2 (100) := 'На прикінці';
    ----------------------------------------------------------------------
    -- Справочник:    Умови фіналізації
    -- Идентификатор: 4009
    -- Представление: V_DDS_FINALCOND
    DIC_V_DDS_FINALCOND              VARCHAR2 (10) := 4009;
    V_DDS_FINALCOND_G                VARCHAR2 (10) := 'G';
    txt_V_DDS_FINALCOND_G            VARCHAR2 (100) := 'Успішне завершення';
    V_DDS_FINALCOND_B                VARCHAR2 (10) := 'B';
    txt_V_DDS_FINALCOND_B            VARCHAR2 (100) := 'Неуспішне завершення';
    V_DDS_FINALCOND_U                VARCHAR2 (10) := 'U';
    txt_V_DDS_FINALCOND_U            VARCHAR2 (100)
                                         := 'Безумовне виконання (скрипт)';
    ----------------------------------------------------------------------
    -- Справочник:    Коди фіналізації
    -- Идентификатор: 4010
    -- Представление: V_DDS_FINALCODE
    DIC_V_DDS_FINALCODE              VARCHAR2 (10) := 4010;
    V_DDS_FINALCODE_A                VARCHAR2 (10) := 'A';
    txt_V_DDS_FINALCODE_A            VARCHAR2 (100) := 'Код по замовчанню';
    V_DDS_FINALCODE_S                VARCHAR2 (10) := 'S';
    txt_V_DDS_FINALCODE_S            VARCHAR2 (100) := 'Відправка ПЗВ';
    V_DDS_FINALCODE_I                VARCHAR2 (10) := 'I';
    txt_V_DDS_FINALCODE_I            VARCHAR2 (100) := 'Підтвердження';
    V_DDS_FINALCODE_U                VARCHAR2 (10) := 'U';
    txt_V_DDS_FINALCODE_U            VARCHAR2 (100) := 'Безумовне виконання';
    ----------------------------------------------------------------------
    -- Справочник:    Умови закінчення контролю групи
    -- Идентификатор: 4011
    -- Представление: V_DDS_CNTR_STOP
    DIC_V_DDS_CNTR_STOP              VARCHAR2 (10) := 4011;
    V_DDS_CNTR_STOP_C                VARCHAR2 (10) := 'C';
    txt_V_DDS_CNTR_STOP_C            VARCHAR2 (100) := 'Продовження контролю';
    V_DDS_CNTR_STOP_G                VARCHAR2 (10) := 'G';
    txt_V_DDS_CNTR_STOP_G            VARCHAR2 (100) := 'Припинення у групах';
    V_DDS_CNTR_STOP_S                VARCHAR2 (10) := 'S';
    txt_V_DDS_CNTR_STOP_S            VARCHAR2 (100) := 'Повне припинення';
    --********************************************************************
    -- Довідники підсистеми обробки файлів
    ----------------------------------------------------------------------
    -- Справочник:    Стан виконання завдання
    -- Идентификатор: 5001
    -- Представление: v_dds_job_st
    DIC_v_dds_job_st                 VARCHAR2 (10) := 5001;
    v_dds_job_st_NEW                 VARCHAR2 (10) := 'NEW';
    txt_v_dds_job_st_NEW             VARCHAR2 (100) := 'Нове';
    v_dds_job_st_EXECUTING           VARCHAR2 (10) := 'EXECUTING';
    txt_v_dds_job_st_EXECUTING       VARCHAR2 (100) := 'Виконується';
    v_dds_job_st_COMPLITE            VARCHAR2 (10) := 'COMPLITE';
    txt_v_dds_job_st_COMPLITE        VARCHAR2 (100) := 'Виконано';
    v_dds_job_st_DISABLE             VARCHAR2 (10) := 'DISABLE';
    txt_v_dds_job_st_DISABLE         VARCHAR2 (100) := 'Заборонено';
    v_dds_job_st_INQUEUE             VARCHAR2 (10) := 'INQUEUE';
    txt_v_dds_job_st_INQUEUE         VARCHAR2 (100) := 'В черзі';
    v_dds_job_st_REMOVED             VARCHAR2 (10) := 'REMOVED';
    txt_v_dds_job_st_REMOVED         VARCHAR2 (100) := 'Видалене';
    v_dds_job_st_ERROREXEC           VARCHAR2 (10) := 'ERROREXEC';
    txt_v_dds_job_st_ERROREXEC       VARCHAR2 (100) := 'Помилка';
    v_dds_job_st_WAITNEXT            VARCHAR2 (10) := 'WAITNEXT';
    txt_v_dds_job_st_WAITNEXT        VARCHAR2 (100)
                                         := 'Очікування наступного';
    ----------------------------------------------------------------------
    -- Справочник:    Тип розподілення задачі
    -- Идентификатор: 5002
    -- Представление: v_dds_job_lock
    DIC_v_dds_job_lock               VARCHAR2 (10) := 5002;
    v_dds_job_lock_1                 VARCHAR2 (10) := '1';
    txt_v_dds_job_lock_1             VARCHAR2 (100) := 'Невизначено';
    v_dds_job_lock_4                 VARCHAR2 (10) := '4';
    txt_v_dds_job_lock_4             VARCHAR2 (100) := 'Розподілюваний';
    v_dds_job_lock_6                 VARCHAR2 (10) := '6';
    txt_v_dds_job_lock_6             VARCHAR2 (100) := 'Виключний';
    --********************************************************************
    -- Довідники подсистеми розподілу доступу
    ----------------------------------------------------------------------
    -- Справочник:    Тип ресурсу
    -- Идентификатор: 6001
    -- Представление: v_dds_resource_tp
    DIC_v_dds_resource_tp            VARCHAR2 (10) := 6001;
    v_dds_resource_tp_D              VARCHAR2 (10) := 'D';
    txt_v_dds_resource_tp_D          VARCHAR2 (100) := 'Дизайнерська';
    v_dds_resource_tp_A              VARCHAR2 (10) := 'A';
    txt_v_dds_resource_tp_A          VARCHAR2 (100) := 'Адміністративна';
    v_dds_resource_tp_U              VARCHAR2 (10) := 'U';
    txt_v_dds_resource_tp_U          VARCHAR2 (100) := 'Користувацька';
    v_dds_resource_tp_I              VARCHAR2 (10) := 'I';
    txt_v_dds_resource_tp_I          VARCHAR2 (100) := 'Интерфейсна';
    v_dds_resource_tp_R              VARCHAR2 (10) := 'R';
    txt_v_dds_resource_tp_R          VARCHAR2 (100) := 'Реплікативний';
    v_dds_resource_tp_S              VARCHAR2 (10) := 'S';
    txt_v_dds_resource_tp_S          VARCHAR2 (100) := 'Спеціальний';
    ----------------------------------------------------------------------
    -- Справочник:    Тип операції атрибута
    -- Идентификатор: 6002
    -- Представление: v_dds_attr_tp
    DIC_v_dds_attr_tp                VARCHAR2 (10) := 6002;
    v_dds_attr_tp_SELECT             VARCHAR2 (10) := 'SELECT';
    txt_v_dds_attr_tp_SELECT         VARCHAR2 (100) := 'Виборка';
    v_dds_attr_tp_INSERT             VARCHAR2 (10) := 'INSERT';
    txt_v_dds_attr_tp_INSERT         VARCHAR2 (100) := 'Вставка';
    v_dds_attr_tp_UPDATE             VARCHAR2 (10) := 'UPDATE';
    txt_v_dds_attr_tp_UPDATE         VARCHAR2 (100) := 'Оновлення';
    v_dds_attr_tp_DELETE             VARCHAR2 (10) := 'DELETE';
    txt_v_dds_attr_tp_DELETE         VARCHAR2 (100) := 'Вилучення';
    v_dds_attr_tp_EXECUTE            VARCHAR2 (10) := 'EXECUTE';
    txt_v_dds_attr_tp_EXECUTE        VARCHAR2 (100) := 'Виконання';
    v_dds_attr_tp_REFERENCES         VARCHAR2 (10) := 'REFERENCES';
    txt_v_dds_attr_tp_REFERENCES     VARCHAR2 (100) := 'Посилання';
    ----------------------------------------------------------------------
    -- Справочник:    Тип обєкту атрибута
    -- Идентификатор: 6003
    -- Представление: v_dds_obj_tp
    DIC_v_dds_obj_tp                 VARCHAR2 (10) := 6003;
    v_dds_obj_tp_SCHEMA              VARCHAR2 (10) := 'SCHEMA';
    txt_v_dds_obj_tp_SCHEMA          VARCHAR2 (100) := 'Схема';
    v_dds_obj_tp_ABSTRACT            VARCHAR2 (10) := 'ABSTRACT';
    txt_v_dds_obj_tp_ABSTRACT        VARCHAR2 (100) := 'Абстракт';
    ----------------------------------------------------------------------
    -- Справочник:    Статуси користувача
    -- Идентификатор: 6004
    -- Представление: v_dds_user_st
    DIC_v_dds_user_st                VARCHAR2 (10) := 6004;
    v_dds_user_st_A                  VARCHAR2 (10) := 'A';
    txt_v_dds_user_st_A              VARCHAR2 (100) := 'Активний';
    v_dds_user_st_L                  VARCHAR2 (10) := 'L';
    txt_v_dds_user_st_L              VARCHAR2 (100) := 'Заблокований';
    v_dds_user_st_D                  VARCHAR2 (10) := 'D';
    txt_v_dds_user_st_D              VARCHAR2 (100) := 'Вилучений';
    ----------------------------------------------------------------------
    -- Справочник:    Типи користувачів
    -- Идентификатор: 6005
    -- Представление: v_dds_user_tp
    DIC_v_dds_user_tp                VARCHAR2 (10) := 6005;
    v_dds_user_tp_Y                  VARCHAR2 (10) := 'Y';
    txt_v_dds_user_tp_Y              VARCHAR2 (100) := 'Вбудований';
    v_dds_user_tp_N                  VARCHAR2 (10) := 'N';
    txt_v_dds_user_tp_N              VARCHAR2 (100) := 'Звичайний';
    v_dds_user_tp_R                  VARCHAR2 (10) := 'R';
    txt_v_dds_user_tp_R              VARCHAR2 (100) := 'Репликатор';
    --********************************************************************
    -- Довідники протоколів
    --********************************************************************
    -- Довідник підсистеми активації
    ----------------------------------------------------------------------
    -- Справочник:    Статус активації
    -- Идентификатор: 8001
    -- Представление: V_DDS_ACTIVATE_ST
    DIC_V_DDS_ACTIVATE_ST            VARCHAR2 (10) := 8001;
    V_DDS_ACTIVATE_ST_0              VARCHAR2 (10) := '0';
    txt_V_DDS_ACTIVATE_ST_0          VARCHAR2 (100) := 'Активовано';
    V_DDS_ACTIVATE_ST_1              VARCHAR2 (10) := '1';
    txt_V_DDS_ACTIVATE_ST_1          VARCHAR2 (100) := 'Помилка активації';
    V_DDS_ACTIVATE_ST_2              VARCHAR2 (10) := '2';
    txt_V_DDS_ACTIVATE_ST_2          VARCHAR2 (100)
                                         := 'Скореговано та активовано';
    V_DDS_ACTIVATE_ST_3              VARCHAR2 (10) := '3';
    txt_V_DDS_ACTIVATE_ST_3          VARCHAR2 (100) := 'Сгенеровано запит';
    V_DDS_ACTIVATE_ST_4              VARCHAR2 (10) := '4';
    txt_V_DDS_ACTIVATE_ST_4          VARCHAR2 (100) := 'Дубль ОПФУ';
    --********************************************************************
    -- Довідники реєстрації дій
    ----------------------------------------------------------------------
    -- Справочник:    Зміни користувача
    -- Идентификатор: 9001
    -- Представление: V_DDS_USR_AU
    DIC_V_DDS_USR_AU                 VARCHAR2 (10) := 9001;
    V_DDS_USR_AU_1                   VARCHAR2 (10) := '1';
    txt_V_DDS_USR_AU_1               VARCHAR2 (100) := 'Створення';
    V_DDS_USR_AU_2                   VARCHAR2 (10) := '2';
    txt_V_DDS_USR_AU_2               VARCHAR2 (100) := 'Зміна ПІБ';
    V_DDS_USR_AU_3                   VARCHAR2 (10) := '3';
    txt_V_DDS_USR_AU_3               VARCHAR2 (100) := 'Зміна кода ОКЗО';
    V_DDS_USR_AU_4                   VARCHAR2 (10) := '4';
    txt_V_DDS_USR_AU_4               VARCHAR2 (100) := 'Блокування';
    V_DDS_USR_AU_5                   VARCHAR2 (10) := '5';
    txt_V_DDS_USR_AU_5               VARCHAR2 (100) := 'Розблокування';
    V_DDS_USR_AU_6                   VARCHAR2 (10) := '6';
    txt_V_DDS_USR_AU_6               VARCHAR2 (100) := 'Пароль застарів';
    V_DDS_USR_AU_7                   VARCHAR2 (10) := '7';
    txt_V_DDS_USR_AU_7               VARCHAR2 (100) := 'Додавання ролі';
    V_DDS_USR_AU_8                   VARCHAR2 (10) := '8';
    txt_V_DDS_USR_AU_8               VARCHAR2 (100) := 'Вилучення ролі';
    V_DDS_USR_AU_9                   VARCHAR2 (10) := '9';
    txt_V_DDS_USR_AU_9               VARCHAR2 (100) := 'Вилучення';
    ----------------------------------------------------------------------
    -- Справочник:    Зміни дільниць користувача
    -- Идентификатор: 9002
    -- Представление: V_DDS_AREA_AU
    DIC_V_DDS_AREA_AU                VARCHAR2 (10) := 9002;
    V_DDS_AREA_AU_1                  VARCHAR2 (10) := '1';
    txt_V_DDS_AREA_AU_1              VARCHAR2 (100) := 'Ввод до подсистеми';
    V_DDS_AREA_AU_2                  VARCHAR2 (10) := '2';
    txt_V_DDS_AREA_AU_2              VARCHAR2 (100)
                                         := 'Вилучення з подсистеми';
    V_DDS_AREA_AU_3                  VARCHAR2 (10) := '3';
    txt_V_DDS_AREA_AU_3              VARCHAR2 (100) := 'Призначення дільниці';
    V_DDS_AREA_AU_4                  VARCHAR2 (10) := '4';
    txt_V_DDS_AREA_AU_4              VARCHAR2 (100) := 'Вилучення дільниці';
    V_DDS_AREA_AU_5                  VARCHAR2 (10) := '5';
    txt_V_DDS_AREA_AU_5              VARCHAR2 (100)
                                         := 'Призначення головної дільниці';
    --********************************************************************
    -- Довідники менеджеру аудиту
    ----------------------------------------------------------------------
    -- Справочник:    Час виконання тригеру
    -- Идентификатор: 10001
    -- Представление: V_DDS_TRIG_TIME
    DIC_V_DDS_TRIG_TIME              VARCHAR2 (10) := 10001;
    V_DDS_TRIG_TIME_B                VARCHAR2 (10) := 'B';
    txt_V_DDS_TRIG_TIME_B            VARCHAR2 (100) := 'BEFORE';
    V_DDS_TRIG_TIME_A                VARCHAR2 (10) := 'A';
    txt_V_DDS_TRIG_TIME_A            VARCHAR2 (100) := 'AFTER';
    --********************************************************************
    -- Довідник системи повідомленнь
    ----------------------------------------------------------------------
    -- Справочник:    Приоритет повідомлення
    -- Идентификатор: 11001
    -- Представление: v_dds_msg_priority
    DIC_v_dds_msg_priority           VARCHAR2 (10) := 11001;
    v_dds_msg_priority_0             VARCHAR2 (10) := '0';
    txt_v_dds_msg_priority_0         VARCHAR2 (100) := 'Найвищій';
    v_dds_msg_priority_1             VARCHAR2 (10) := '1';
    txt_v_dds_msg_priority_1         VARCHAR2 (100) := 'Високий';
    v_dds_msg_priority_2             VARCHAR2 (10) := '2';
    txt_v_dds_msg_priority_2         VARCHAR2 (100) := 'Нормальний';
    ----------------------------------------------------------------------
    -- Справочник:    Статус повідомлення
    -- Идентификатор: 11002
    -- Представление: v_dds_msg_st
    DIC_v_dds_msg_st                 VARCHAR2 (10) := 11002;
    v_dds_msg_st_N                   VARCHAR2 (10) := 'N';
    txt_v_dds_msg_st_N               VARCHAR2 (100) := 'Нове';
    v_dds_msg_st_W                   VARCHAR2 (10) := 'W';
    txt_v_dds_msg_st_W               VARCHAR2 (100) := 'В роботі';
    v_dds_msg_st_E                   VARCHAR2 (10) := 'E';
    txt_v_dds_msg_st_E               VARCHAR2 (100) := 'Оброблено';
    v_dds_msg_st_C                   VARCHAR2 (10) := 'C';
    txt_v_dds_msg_st_C               VARCHAR2 (100) := 'Скасоване';
    ----------------------------------------------------------------------
    -- Справочник:    Тип параметра
    -- Идентификатор: 11003
    -- Представление: v_dds_msg_par_tp
    DIC_v_dds_msg_par_tp             VARCHAR2 (10) := 11003;
    v_dds_msg_par_tp_TEXT            VARCHAR2 (10) := 'TEXT';
    txt_v_dds_msg_par_tp_TEXT        VARCHAR2 (100) := 'Текстовий параметр';
    v_dds_msg_par_tp_DEVS            VARCHAR2 (10) := 'DEVS';
    txt_v_dds_msg_par_tp_DEVS        VARCHAR2 (100) := 'Код задачі ДЕВС';
    v_dds_msg_par_tp_SETPN           VARCHAR2 (10) := 'SETPN';
    txt_v_dds_msg_par_tp_SETPN       VARCHAR2 (100) := 'Параметр';
END ikis_const;
/


CREATE OR REPLACE SYNONYM IKIS_SYSWEB.IKIS_SYS_IKIS_CONST FOR IKIS_SYS.IKIS_CONST
/


CREATE OR REPLACE SYNONYM IKIS_WEBPROXY.IKIS_SYS_IKIS_CONST FOR IKIS_SYS.IKIS_CONST
/


GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CONST TO USS_VISIT WITH GRANT OPTION
/
