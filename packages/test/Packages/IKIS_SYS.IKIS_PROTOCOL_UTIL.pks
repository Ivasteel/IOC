/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_PROTOCOL_UTIL
IS
    -- Author  : RYABA
    -- Created : 02.09.2003 12:18:58
    -- Purpose : Робота з загальносистемним протоколом
    --Суффикс at - автономная транзакция
    FUNCTION GetNewSeans (
        p_ps_type   IN ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN ikis_prot_seans.ps_ss%TYPE,
        p_ps_desc   IN ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN ikis_prot_seans.ps_type%TYPE := NULL)
        RETURN NUMBER;

    PROCEDURE PGetNewSeans (
        p_ps_type   IN     ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN     ikis_prot_seans.ps_ss%TYPE,
        p_seans        OUT NUMBER,
        p_ps_desc   IN     ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN     ikis_prot_seans.ps_type%TYPE := NULL);

    FUNCTION GetNewSeans_at (
        p_ps_type   IN ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN ikis_prot_seans.ps_ss%TYPE,
        p_ps_desc   IN ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN ikis_prot_seans.ps_type%TYPE := NULL)
        RETURN NUMBER;

    PROCEDURE PGetNewSeans_at (
        p_ps_type   IN     ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN     ikis_prot_seans.ps_ss%TYPE,
        p_seans        OUT NUMBER,
        p_ps_desc   IN     ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN     ikis_prot_seans.ps_type%TYPE := NULL);


    --Встановлює дату та час закінчення сеансу протоколу
    PROCEDURE CloseSeans (p_ps_id IN ikis_prot_seans.ps_id%TYPE);

    PROCEDURE CloseSeans_at (p_ps_id IN ikis_prot_seans.ps_id%TYPE);

    --Повертає поточний № сеансу протоколу
    FUNCTION GetCurProtSeans
        RETURN NUMBER;

    PROCEDURE PGetCurProtSeans (p_seans OUT NUMBER);

    --Встановлює поточний № сенасу протоколу з вже існуючих сеансів
    PROCEDURE SetCurProtSeans (p_seans IN ikis_prot_seans.ps_id%TYPE);


    --додає повідомлення до протоколу без прив'язки до суииєвостей
    PROCEDURE insert_prot_msg (
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    PROCEDURE insert_prot_msg_at (
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );


    --додає повідомлення до протоколу без прив'язки до суииєвостей для вказаного сеансу
    PROCEDURE insert_seans_prot_msg (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    PROCEDURE insert_seans_prot_msg_at (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    --додає повідомлення до протоколу з прив'язкою до суииєвостей
    PROCEDURE insert_es_prot_msg (
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL, -- Умова сортування 3
        p_is_array              BOOLEAN DEFAULT FALSE);

    PROCEDURE insert_es_prot_msg_at (
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    --+YAP 20071019
    --для загрузки сообщений при массовой обработке FORALL
    --сохранение в массиве см параметр p_is_array процедуры insert_es_prot_msg
    --FORALL INSERT
    PROCEDURE insert_es_prot_msg_apply;

    --очистка массива
    PROCEDURE insert_es_prot_msg_reset;

    ---

    --додає повідомлення до протоколу з прив'язкою до суииєвостей для вказсного сеансу
    PROCEDURE insert_seans_es_prot_msg (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    PROCEDURE insert_seans_es_prot_msg_at (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     );

    --Процедура вилучає рядок з таблиці протоколу
    PROCEDURE delete_es_prot_msg (
        p_prot_ss      IN ikis_subsys.ss_code%TYPE,      --код підсистеми ІКІС
        p_prot_es      IN ikis_protocol.prot_es%TYPE,         --Код суттєвості
        p_prot_es_id   IN ikis_protocol.prot_es_id%TYPE,       --ІД суттєвості
        p_prot_type    IN ikis_prot_seans.ps_type%TYPE --тип запису повідомлення (довідник V_DDS_PROT_TYPE)
                                                      );

    ----------------------------------------
    -- YURA_A 22.11.2003 13:16:57
    ----------------------------------------
    -- Назначение : Удаление протокола подсистемы по типу
    -- Параметры  : код подсистемы, тип протокола
    PROCEDURE delete_es_prot (p_prot_ss     IN ikis_subsys.ss_code%TYPE, --код підсистеми ІКІС
                              p_prot_type   IN ikis_prot_seans.ps_type%TYPE --тип запису повідомлення (довідник V_DDS_PROT_TYPE)
                                                                           );

    PROCEDURE delete_es_prot_seans (
        p_prot_seans   IN ikis_protocol.prot_seans%TYPE);


    --Процедура встановлює усім рядкам саенсу протоколу часову мітку зміни
    PROCEDURE SetSeansTS (p_seans   IN ikis_protocol.prot_seans%TYPE,
                          p_ts      IN NUMBER);

    --Процедура встановлює параметр для сеансу протоколу
    PROCEDURE SetSeansParam (
        p_code    IN ikis_prot_seans_param.psp_code%TYPE,      --Код параметру
        p_ps      IN ikis_prot_seans_param.psp_ps%TYPE,            --ИД сеансу
        p_value   IN ikis_prot_seans_param.psp_value%TYPE); --значення параметру

    PROCEDURE SetSeansParam_at (
        p_code    IN ikis_prot_seans_param.psp_code%TYPE,
        p_ps      IN ikis_prot_seans_param.psp_ps%TYPE,
        p_value   IN ikis_prot_seans_param.psp_value%TYPE);

    --Функція для визначення потреби не виводити повідомлення
    --заданих типів для суттєвості
    FUNCTION SuppresESMessages (p_prot_id    IN ikis_protocol.prot_id%TYPE,
                                p_es_id      IN ikis_protocol.prot_es_id%TYPE,
                                p_es         IN ikis_protocol.prot_es%TYPE,
                                p_seans      IN ikis_protocol.prot_seans%TYPE,
                                p_messages   IN VARCHAR2 := '|E|')
        RETURN ikis_protocol.prot_id%TYPE;
END IKIS_PROTOCOL_UTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_PROTOCOL_UTIL FOR IKIS_SYS.IKIS_PROTOCOL_UTIL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO II01RC_IKIS_SYS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO II01RC_SR_CONTROL_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PROTOCOL_UTIL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_PROTOCOL_UTIL
IS
    msgUNIQUE_VIOLATION          NUMBER := 1;
    msgCOMMON_EXCEPTION          NUMBER := 2;
    msgAlreadyLocked             NUMBER := 77;
    msgDataChanged               NUMBER := 78;
    msgEstablish                 NUMBER := 79;
    msgGroupControlError         NUMBER := 97;
    msgProgramError              NUMBER := 117;
    msgFEATURENOTENABLED         NUMBER := 213;
    msgParamNotFound             NUMBER := 298;
    msgProtSeansInitErr          NUMBER := 2935;
    msgProtSeansInvalid          NUMBER := 2936;

    gCurProtSeans                ikis_prot_seans.ps_id%TYPE := 0;
    gCurProtSS                   ikis_prot_seans.ps_ss%TYPE;
    gCurProtType                 ikis_prot_type.type_id%TYPE;
    gCurProtTypeCode             ikis_prot_type.type_code%TYPE;


    unique_constraint_violated   EXCEPTION;
    PRAGMA EXCEPTION_INIT (unique_constraint_violated, -1);


    --массовая загрузка протокола
    TYPE t_prot_es IS TABLE OF ikis_protocol.prot_es%TYPE;

    TYPE t_prot_es_id IS TABLE OF ikis_protocol.prot_es_id%TYPE;

    TYPE t_prot_ipm IS TABLE OF ikis_messages.ipm_id%TYPE;

    TYPE t_prot_msg_type IS TABLE OF ikis_messages.ipm_tp%TYPE;

    TYPE t_prot_paramvalue1 IS TABLE OF ikis_protocol.prot_paramvalue1%TYPE;

    TYPE t_prot_paramvalue2 IS TABLE OF ikis_protocol.prot_paramvalue2%TYPE;

    TYPE t_prot_paramvalue3 IS TABLE OF ikis_protocol.prot_paramvalue3%TYPE;

    TYPE t_prot_paramvalue4 IS TABLE OF ikis_protocol.prot_paramvalue4%TYPE;

    TYPE t_prot_paramvalue5 IS TABLE OF ikis_protocol.prot_paramvalue5%TYPE;

    TYPE t_prot_paramvalue6 IS TABLE OF ikis_protocol.prot_paramvalue6%TYPE;

    TYPE t_prot_paramvalue7 IS TABLE OF ikis_protocol.prot_paramvalue7%TYPE;

    TYPE t_prot_paramvalue8 IS TABLE OF ikis_protocol.prot_paramvalue8%TYPE;

    TYPE t_prot_ord_1 IS TABLE OF ikis_protocol.prot_ord_1%TYPE;

    TYPE t_prot_ord_2 IS TABLE OF ikis_protocol.prot_ord_2%TYPE;

    TYPE t_prot_ord_3 IS TABLE OF ikis_protocol.prot_ord_3%TYPE;

    TYPE t_prot_datetime IS TABLE OF ikis_protocol.prot_datetime%TYPE;

    prot_es                      t_prot_es := t_prot_es ();
    prot_es_id                   t_prot_es_id := t_prot_es_id ();
    prot_ipm                     t_prot_ipm := t_prot_ipm ();
    prot_msg_type                t_prot_msg_type := t_prot_msg_type ();
    prot_paramvalue1             t_prot_paramvalue1 := t_prot_paramvalue1 ();
    prot_paramvalue2             t_prot_paramvalue2 := t_prot_paramvalue2 ();
    prot_paramvalue3             t_prot_paramvalue3 := t_prot_paramvalue3 ();
    prot_paramvalue4             t_prot_paramvalue4 := t_prot_paramvalue4 ();
    prot_paramvalue5             t_prot_paramvalue5 := t_prot_paramvalue5 ();
    prot_paramvalue6             t_prot_paramvalue6 := t_prot_paramvalue6 ();
    prot_paramvalue7             t_prot_paramvalue7 := t_prot_paramvalue7 ();
    prot_paramvalue8             t_prot_paramvalue8 := t_prot_paramvalue8 ();
    prot_ord_1                   t_prot_ord_1 := t_prot_ord_1 ();
    prot_ord_2                   t_prot_ord_2 := t_prot_ord_2 ();
    prot_ord_3                   t_prot_ord_3 := t_prot_ord_3 ();
    prot_datetime                t_prot_datetime := t_prot_datetime ();



    PROCEDURE CheckProtSeans
    IS
    BEGIN
        IF gCurProtSeans = 0
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgProtSeansInitErr));
        END IF;
    END;

    PROCEDURE insert_prot_msg (
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE,
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL,
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL,
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL,
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL,
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL,
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL,
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL,
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL,
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL,
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL,
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL)
    IS
        l_msg_type   ikis_messages.ipm_tp%TYPE;
        l_dser       BOOLEAN;
    BEGIN
        --+yap 20071116
        l_dser := dserials.gd_idiap_enabled;
        dserials.gd_idiap_enabled := TRUE;

        CheckProtSeans;

        l_msg_type := NULL;

        IF     (LENGTH (TRIM (p_prot_msg_type)) > 0)
           AND (p_prot_msg_type IS NOT NULL)
        THEN
            l_msg_type := TRIM (p_prot_msg_type);
        END IF;

        --Додання запису до протоколу
        INSERT INTO ikis_protocol (prot_seans,
                                   prot_ss,
                                   prot_type,
                                   prot_ipm,
                                   prot_msg_type,
                                   prot_paramvalue1,
                                   prot_paramvalue2,
                                   prot_paramvalue3,
                                   prot_paramvalue4,
                                   prot_paramvalue5,
                                   prot_paramvalue6,
                                   prot_paramvalue7,
                                   prot_paramvalue8,
                                   prot_ord_1,
                                   prot_ord_2,
                                   prot_ord_3,
                                   prot_datetime)
             VALUES (gCurProtSeans,
                     gCurProtSS,
                     gCurProtType,
                     p_prot_ipm,
                     l_msg_type,
                     SUBSTR (p_prot_paramvalue1, 1, 1000),
                     SUBSTR (p_prot_paramvalue2, 1, 200),
                     SUBSTR (p_prot_paramvalue3, 1, 200),
                     SUBSTR (p_prot_paramvalue4, 1, 200),
                     SUBSTR (p_prot_paramvalue5, 1, 200),
                     SUBSTR (p_prot_paramvalue6, 1, 200),
                     SUBSTR (p_prot_paramvalue7, 1, 200),
                     SUBSTR (p_prot_paramvalue8, 1, 200),
                     SUBSTR (p_prot_ord_1, 1, 200),
                     SUBSTR (p_prot_ord_2, 1, 200),
                     SUBSTR (p_prot_ord_3, 1, 200),
                     SYSDATE);

        dserials.gd_idiap_enabled := l_dser;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            dserials.gd_idiap_enabled := l_dser;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.Insert_prot_msg',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE insert_prot_msg_at (
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE,
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL,
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL,
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL,
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL,
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL,
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL,
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL,
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL,
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL,
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL,
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        insert_prot_msg (p_prot_ipm,
                         p_prot_msg_type,
                         p_prot_paramvalue1,
                         p_prot_paramvalue2,
                         p_prot_paramvalue3,
                         p_prot_paramvalue4,
                         p_prot_paramvalue5,
                         p_prot_paramvalue6,
                         p_prot_paramvalue7,
                         p_prot_paramvalue8,
                         p_prot_ord_1,
                         p_prot_ord_2,
                         p_prot_ord_3);
        COMMIT;
    END;


    PROCEDURE insert_seans_prot_msg (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     )
    IS
        old_ProtSeans   ikis_prot_seans.ps_id%TYPE;
        old_ProtSS      ikis_prot_seans.ps_ss%TYPE;
        old_ProtType    ikis_prot_seans.ps_type%TYPE;
    BEGIN
        old_ProtSeans := gCurProtSeans;
        old_ProtSS := gCurProtSS;
        old_ProtType := gCurProtType;

        SetCurprotSeans (p_prot_seans);

        insert_prot_msg (p_prot_ipm,
                         p_prot_msg_type,
                         p_prot_paramvalue1,
                         p_prot_paramvalue2,
                         p_prot_paramvalue3,
                         p_prot_paramvalue4,
                         p_prot_paramvalue5,
                         p_prot_paramvalue6,
                         p_prot_paramvalue7,
                         p_prot_paramvalue8,
                         p_prot_ord_1,
                         p_prot_ord_2,
                         p_prot_ord_3);

        gCurProtSeans := old_ProtSeans;
        gCurProtSS := old_ProtSS;
        gCurProtType := old_ProtType;
    END;

    PROCEDURE insert_seans_prot_msg_at (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        insert_seans_prot_msg (p_prot_seans,
                               p_prot_ipm,
                               p_prot_msg_type,
                               p_prot_paramvalue1,
                               p_prot_paramvalue2,
                               p_prot_paramvalue3,
                               p_prot_paramvalue4,
                               p_prot_paramvalue5,
                               p_prot_paramvalue6,
                               p_prot_paramvalue7,
                               p_prot_paramvalue8,
                               p_prot_ord_1,
                               p_prot_ord_2,
                               p_prot_ord_3);
        COMMIT;
    END;

    PROCEDURE insert_es_prot_msg_apply
    IS
        errors       NUMBER;
        dml_errors   EXCEPTION;
        PRAGMA EXCEPTION_INIT (dml_errors, -24381);
    BEGIN
        IF prot_es.COUNT > 0
        THEN
            FORALL i IN prot_es.FIRST .. prot_es.LAST SAVE EXCEPTIONS
                INSERT INTO ikis_protocol (prot_seans,
                                           prot_ss,
                                           prot_type,
                                           prot_es,
                                           prot_es_id,
                                           prot_ipm,
                                           prot_msg_type,
                                           prot_paramvalue1,
                                           prot_paramvalue2,
                                           prot_paramvalue3,
                                           prot_paramvalue4,
                                           prot_paramvalue5,
                                           prot_paramvalue6,
                                           prot_paramvalue7,
                                           prot_paramvalue8,
                                           prot_ord_1,
                                           prot_ord_2,
                                           prot_ord_3,
                                           prot_datetime)
                     VALUES (gCurProtSeans,
                             gCurProtSS,
                             gCurProtType,
                             prot_es (i),
                             prot_es_id (i),
                             prot_ipm (i),
                             prot_msg_type (i),
                             prot_paramvalue1 (i),
                             prot_paramvalue2 (i),
                             prot_paramvalue3 (i),
                             prot_paramvalue4 (i),
                             prot_paramvalue5 (i),
                             prot_paramvalue6 (i),
                             prot_paramvalue7 (i),
                             prot_paramvalue8 (i),
                             prot_ord_1 (i),
                             prot_ord_2 (i),
                             prot_ord_3 (i),
                             prot_datetime (i));
        END IF;
    EXCEPTION
        /*  WHEN dml_errors THEN -- Now we figure out what failed and why.
           errors := SQL%BULK_EXCEPTIONS.COUNT;
           DBMS_OUTPUT.PUT_LINE('Number of statements that failed: ' || errors);
           FOR i IN 1..errors LOOP
              DBMS_OUTPUT.PUT_LINE('Error #' || i || ' occurred during '||
                 'iteration #' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                  DBMS_OUTPUT.PUT_LINE('Error message is ' ||
                  SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
           END LOOP;*/
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.Insert_es_prot_msg',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE insert_es_prot_msg_reset
    IS
    BEGIN
        prot_es.delete;
        prot_es_id.delete;
        prot_ipm.delete;
        prot_msg_type.delete;
        prot_paramvalue1.delete;
        prot_paramvalue2.delete;
        prot_paramvalue3.delete;
        prot_paramvalue4.delete;
        prot_paramvalue5.delete;
        prot_paramvalue6.delete;
        prot_paramvalue7.delete;
        prot_paramvalue8.delete;
        prot_ord_1.delete;
        prot_ord_2.delete;
        prot_ord_3.delete;
        prot_datetime.delete;
    END;


    PROCEDURE insert_es_prot_msg (
        p_prot_es            IN ikis_protocol.prot_es%TYPE,
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL,
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL,
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL,
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL,
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL,
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL,
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL,
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL,
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL,
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL,
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL,
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL,
        p_is_array              BOOLEAN DEFAULT FALSE)
    IS
        l_org        NUMBER;
        l_msg_type   ikis_messages.ipm_tp%TYPE;
    BEGIN
        CheckProtSeans;

        l_msg_type := NULL;

        IF     (LENGTH (TRIM (p_prot_msg_type)) > 0)
           AND (p_prot_msg_type IS NOT NULL)
        THEN
            l_msg_type := TRIM (p_prot_msg_type);
        END IF;

        --Додання запису до протоколу
        IF NOT p_is_array
        THEN                                             --работаем по старому
            INSERT INTO ikis_protocol (prot_seans,
                                       prot_ss,
                                       prot_type,
                                       prot_es,
                                       prot_es_id,
                                       prot_ipm,
                                       prot_msg_type,
                                       prot_paramvalue1,
                                       prot_paramvalue2,
                                       prot_paramvalue3,
                                       prot_paramvalue4,
                                       prot_paramvalue5,
                                       prot_paramvalue6,
                                       prot_paramvalue7,
                                       prot_paramvalue8,
                                       prot_ord_1,
                                       prot_ord_2,
                                       prot_ord_3,
                                       prot_datetime)
                 VALUES (gCurProtSeans,
                         gCurProtSS,
                         gCurProtType,
                         p_prot_es,
                         p_prot_es_id,
                         p_prot_ipm,
                         p_prot_msg_type,
                         SUBSTR (p_prot_paramvalue1, 1, 1000),
                         SUBSTR (p_prot_paramvalue2, 1, 200),
                         SUBSTR (p_prot_paramvalue3, 1, 200),
                         SUBSTR (p_prot_paramvalue4, 1, 200),
                         SUBSTR (p_prot_paramvalue5, 1, 200),
                         SUBSTR (p_prot_paramvalue6, 1, 200),
                         SUBSTR (p_prot_paramvalue7, 1, 200),
                         SUBSTR (p_prot_paramvalue8, 1, 200),
                         SUBSTR (p_prot_ord_1, 1, 200),
                         SUBSTR (p_prot_ord_2, 1, 200),
                         SUBSTR (p_prot_ord_3, 1, 200),
                         SYSDATE);
        ELSE
            --сохраняем в массиве
            prot_es.EXTEND;
            prot_es (prot_es.LAST) := p_prot_es;
            prot_es_id.EXTEND;
            prot_es_id (prot_es_id.LAST) := p_prot_es_id;
            prot_ipm.EXTEND;
            prot_ipm (prot_ipm.LAST) := p_prot_ipm;
            prot_msg_type.EXTEND;
            prot_msg_type (prot_msg_type.LAST) := p_prot_msg_type;
            prot_paramvalue1.EXTEND;
            prot_paramvalue1 (prot_paramvalue1.LAST) :=
                SUBSTR (p_prot_paramvalue1, 1, 1000);
            prot_paramvalue2.EXTEND;
            prot_paramvalue2 (prot_paramvalue2.LAST) :=
                SUBSTR (p_prot_paramvalue2, 1, 200);
            prot_paramvalue3.EXTEND;
            prot_paramvalue3 (prot_paramvalue3.LAST) :=
                SUBSTR (p_prot_paramvalue3, 1, 200);
            prot_paramvalue4.EXTEND;
            prot_paramvalue4 (prot_paramvalue4.LAST) :=
                SUBSTR (p_prot_paramvalue4, 1, 200);
            prot_paramvalue5.EXTEND;
            prot_paramvalue5 (prot_paramvalue5.LAST) :=
                SUBSTR (p_prot_paramvalue5, 1, 200);
            prot_paramvalue6.EXTEND;
            prot_paramvalue6 (prot_paramvalue6.LAST) :=
                SUBSTR (p_prot_paramvalue6, 1, 200);
            prot_paramvalue7.EXTEND;
            prot_paramvalue7 (prot_paramvalue7.LAST) :=
                SUBSTR (p_prot_paramvalue7, 1, 200);
            prot_paramvalue8.EXTEND;
            prot_paramvalue8 (prot_paramvalue8.LAST) :=
                SUBSTR (p_prot_paramvalue8, 1, 200);
            prot_ord_1.EXTEND;
            prot_ord_1 (prot_ord_1.LAST) := SUBSTR (p_prot_ord_1, 1, 200);
            prot_ord_2.EXTEND;
            prot_ord_2 (prot_ord_2.LAST) := SUBSTR (p_prot_ord_2, 1, 200);
            prot_ord_3.EXTEND;
            prot_ord_3 (prot_ord_3.LAST) := SUBSTR (p_prot_ord_3, 1, 200);
            prot_datetime.EXTEND;
            prot_datetime (prot_datetime.LAST) := SYSDATE;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.Insert_es_prot_msg',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE insert_es_prot_msg_at (
        p_prot_es            IN ikis_protocol.prot_es%TYPE,
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE,
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL,
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL,
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL,
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL,
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL,
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL,
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL,
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL,
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL,
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL,
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL,
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        insert_es_prot_msg (p_prot_es,
                            p_prot_es_id,
                            p_prot_ipm,
                            p_prot_msg_type,
                            p_prot_paramvalue1,
                            p_prot_paramvalue2,
                            p_prot_paramvalue3,
                            p_prot_paramvalue4,
                            p_prot_paramvalue5,
                            p_prot_paramvalue6,
                            p_prot_paramvalue7,
                            p_prot_paramvalue8,
                            p_prot_ord_1,
                            p_prot_ord_2,
                            p_prot_ord_3);
        COMMIT;
    END;


    PROCEDURE insert_seans_es_prot_msg (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     )
    IS
        old_ProtSeans   ikis_prot_seans.ps_id%TYPE;
        old_ProtSS      ikis_prot_seans.ps_ss%TYPE;
        old_ProtType    ikis_prot_seans.ps_type%TYPE;
    BEGIN
        old_ProtSeans := gCurProtSeans;
        old_ProtSS := gCurProtSS;
        old_ProtType := gCurProtType;

        SetCurprotSeans (p_prot_seans);
        insert_es_prot_msg (p_prot_es,
                            p_prot_es_id,
                            p_prot_ipm,
                            p_prot_msg_type,
                            p_prot_paramvalue1,
                            p_prot_paramvalue2,
                            p_prot_paramvalue3,
                            p_prot_paramvalue4,
                            p_prot_paramvalue5,
                            p_prot_paramvalue6,
                            p_prot_paramvalue7,
                            p_prot_paramvalue8,
                            p_prot_ord_1,
                            p_prot_ord_2,
                            p_prot_ord_3);

        gCurProtSeans := old_ProtSeans;
        gCurProtSS := old_ProtSS;
        gCurProtType := old_ProtType;
    END;

    PROCEDURE insert_seans_es_prot_msg_at (
        p_prot_seans         IN ikis_protocol.prot_seans%TYPE,
        p_prot_es            IN ikis_protocol.prot_es%TYPE,   --Код суттєвості
        p_prot_es_id         IN ikis_protocol.prot_es_id%TYPE, --ІД суттєвості
        p_prot_ipm           IN ikis_messages.ipm_id%TYPE,   --ІД повідомлення
        p_prot_msg_type      IN ikis_messages.ipm_tp%TYPE := NULL, --Тип повідомлення (якщо передати null, то тип буде той, що вказано в таблиці ikis_messages)
        p_prot_paramvalue1   IN ikis_protocol.prot_paramvalue1%TYPE := NULL, --Значення параметру 1
        p_prot_paramvalue2   IN ikis_protocol.prot_paramvalue2%TYPE := NULL, --Значення параметру 2
        p_prot_paramvalue3   IN ikis_protocol.prot_paramvalue3%TYPE := NULL, --Значення параметру 3
        p_prot_paramvalue4   IN ikis_protocol.prot_paramvalue4%TYPE := NULL, --Значення параметру 4
        p_prot_paramvalue5   IN ikis_protocol.prot_paramvalue5%TYPE := NULL, --Значення параметру 5
        p_prot_paramvalue6   IN ikis_protocol.prot_paramvalue6%TYPE := NULL, --Значення параметру 6
        p_prot_paramvalue7   IN ikis_protocol.prot_paramvalue7%TYPE := NULL, --Значення параметру 7
        p_prot_paramvalue8   IN ikis_protocol.prot_paramvalue8%TYPE := NULL, --Значення параметру 8
        p_prot_ord_1         IN ikis_protocol.prot_ord_1%TYPE := NULL, -- Умова сортування 1
        p_prot_ord_2         IN ikis_protocol.prot_ord_2%TYPE := NULL, -- Умова сортування 2
        p_prot_ord_3         IN ikis_protocol.prot_ord_3%TYPE := NULL -- Умова сортування 3
                                                                     )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        insert_seans_es_prot_msg (p_prot_seans,
                                  p_prot_es,
                                  p_prot_es_id,
                                  p_prot_ipm,
                                  p_prot_msg_type,
                                  p_prot_paramvalue1,
                                  p_prot_paramvalue2,
                                  p_prot_paramvalue3,
                                  p_prot_paramvalue4,
                                  p_prot_paramvalue5,
                                  p_prot_paramvalue6,
                                  p_prot_paramvalue7,
                                  p_prot_paramvalue8,
                                  p_prot_ord_1,
                                  p_prot_ord_2,
                                  p_prot_ord_3);
        COMMIT;
    END;

    PROCEDURE delete_es_prot_msg (
        p_prot_ss      IN ikis_subsys.ss_code%TYPE,
        p_prot_es      IN ikis_protocol.prot_es%TYPE,
        p_prot_es_id   IN ikis_protocol.prot_es_id%TYPE,
        p_prot_type    IN ikis_prot_seans.ps_type%TYPE)
    IS
    BEGIN
        SAVEPOINT one;

        DELETE FROM ikis_protocol
              WHERE     prot_es = UPPER (p_prot_es)
                    AND prot_es_id = p_prot_es_id
                    AND prot_ss = UPPER (p_prot_ss)
                    AND prot_type = --upper(p_prot_type)
                                    p_prot_type;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.delete_es_prot_msg',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE delete_es_prot (p_prot_ss     IN ikis_subsys.ss_code%TYPE, --код підсистеми ІКІС
                              p_prot_type   IN ikis_prot_seans.ps_type%TYPE --тип запису повідомлення (довідник V_DDS_PROT_TYPE)
                                                                           )
    IS
    BEGIN
        SAVEPOINT one;

        DELETE FROM ikis_protocol
              WHERE     prot_ss = UPPER (p_prot_ss)
                    AND prot_type = UPPER (p_prot_type);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.delete_es_prot',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE delete_es_prot_seans (
        p_prot_seans   IN ikis_protocol.prot_seans%TYPE)
    IS
    BEGIN
        SAVEPOINT one;

        DELETE FROM ikis_protocol
              WHERE prot_seans = p_prot_seans;

        DELETE FROM ikis_prot_seans
              WHERE ps_id = p_prot_seans;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.delete_es_prot_seans',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetNewSeans (
        p_ps_type   IN ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN ikis_prot_seans.ps_ss%TYPE,
        p_ps_desc   IN ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN ikis_prot_seans.ps_type%TYPE := NULL)
        RETURN NUMBER
    IS
        l_res   NUMBER;
        l_org   ikis_prot_seans.ps_type%TYPE;
    BEGIN
        IF p_ps_org IS NULL
        THEN
            l_org := IKIS_COMMON.GETAP_IKIS_OPFU;
        ELSE
            l_org := p_ps_org;
        END IF;

        SELECT type_id
          INTO gCurProtType
          FROM ikis_prot_type
         WHERE type_code = p_ps_type;

        INSERT INTO ikis_prot_seans (ps_id,
                                     ps_ss,
                                     ps_org,
                                     ps_type,
                                     ps_date_start,
                                     ps_desc)
             VALUES (0,
                     p_ps_ss,
                     l_org,
                     gCurProtType,
                     SYSDATE,
                     p_ps_desc)
          RETURNING ps_id
               INTO l_res;

        --+ Автор: YURA_A 16.02.2004 12:40:51
        --  Описание: перенес сюда
        --+ Автор: YURA_A 27.10.2003 11:56:11
        --  Описание: номер сеанса генерить в диапазоне узла
        l_res := l_res;
        --- Автор: YURA_A 27.10.2003 11:56:24
        gCurProtSeans := l_res;
        gCurProtSS := UPPER (p_ps_ss);
        gCurProtTypeCode := p_ps_type;
        RETURN l_res;
    END;

    FUNCTION GetNewSeans_at (
        p_ps_type   IN ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN ikis_prot_seans.ps_ss%TYPE,
        p_ps_desc   IN ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN ikis_prot_seans.ps_type%TYPE := NULL)
        RETURN NUMBER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_res   NUMBER;
    BEGIN
        l_res :=
            GetNewSeans (p_ps_type,
                         p_ps_ss,
                         p_ps_desc,
                         p_ps_org);
        COMMIT;
        RETURN l_res;
    END;

    PROCEDURE PGetNewSeans (
        p_ps_type   IN     ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN     ikis_prot_seans.ps_ss%TYPE,
        p_seans        OUT NUMBER,
        p_ps_desc   IN     ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN     ikis_prot_seans.ps_type%TYPE := NULL)
    IS
    BEGIN
        p_seans :=
            GetNewSeans (p_ps_type,
                         p_ps_ss,
                         p_ps_desc,
                         p_ps_org);
    END;

    PROCEDURE PGetNewSeans_at (
        p_ps_type   IN     ikis_prot_type.type_code%TYPE,
        p_ps_ss     IN     ikis_prot_seans.ps_ss%TYPE,
        p_seans        OUT NUMBER,
        p_ps_desc   IN     ikis_prot_seans.ps_desc%TYPE := NULL,
        p_ps_org    IN     ikis_prot_seans.ps_type%TYPE := NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        p_seans :=
            GetNewSeans (p_ps_type,
                         p_ps_ss,
                         p_ps_desc,
                         p_ps_org);
        COMMIT;
    END;

    PROCEDURE CloseSeans (p_ps_id IN ikis_prot_seans.ps_id%TYPE)
    IS
    BEGIN
        UPDATE ikis_prot_seans
           SET ps_date_stop = SYSDATE
         WHERE ps_id = p_ps_id;

        gCurProtSeans := 0;
    END;

    PROCEDURE CloseSeans_at (p_ps_id IN ikis_prot_seans.ps_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        CloseSeans (p_Ps_Id);
        COMMIT;
    END;

    FUNCTION GetCurProtSeans
        RETURN NUMBER
    IS
    BEGIN
        RETURN gCurProtSeans;
    END;

    PROCEDURE PGetCurProtSeans (p_seans OUT NUMBER)
    IS
    BEGIN
        p_seans := gCurProtSeans;
    END;

    PROCEDURE SetCurProtSeans (p_seans IN ikis_prot_seans.ps_id%TYPE)
    IS
    BEGIN
        SELECT ps_ss, ps_type
          INTO gCurProtSS, gCurProtType
          FROM ikis_prot_seans
         WHERE ps_id = p_seans;

        gCurProtSeans := p_seans;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgProtSeansInvalid));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.SetCurProtSeans',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetSeansTS (p_seans   IN ikis_protocol.prot_seans%TYPE,
                          p_ts      IN NUMBER)
    IS
    BEGIN
        UPDATE ikis_protocol
           SET repl_ts = p_ts
         WHERE prot_seans = p_seans;

        UPDATE ikis_prot_seans
           SET repl_ts = p_ts
         WHERE ps_id = p_seans;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.SetSeansTS',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetSeansParam (
        p_code    IN ikis_prot_seans_param.psp_code%TYPE,
        p_ps      IN ikis_prot_seans_param.psp_ps%TYPE,
        p_value   IN ikis_prot_seans_param.psp_value%TYPE)
    IS
    BEGIN
        SAVEPOINT SP_SET_SEANS_PARAMS;

        BEGIN
            INSERT INTO ikis_prot_seans_param (psp_code, psp_ps, psp_value)
                 VALUES (p_code, p_ps, p_value);
        EXCEPTION
            WHEN unique_constraint_violated
            THEN
                UPDATE ikis_prot_seans_param
                   SET psp_value = p_value
                 WHERE psp_code = p_code AND psp_ps = p_ps;
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO SP_SET_SEANS_PARAMS;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_PROTOCOL_UTIL.SetSeansParam',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetSeansParam_at (
        p_code    IN ikis_prot_seans_param.psp_code%TYPE,
        p_ps      IN ikis_prot_seans_param.psp_ps%TYPE,
        p_value   IN ikis_prot_seans_param.psp_value%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SetSeansParam (p_code, p_ps, p_value);
        COMMIT;
    END;

    FUNCTION SuppresESMessages (p_prot_id    IN ikis_protocol.prot_id%TYPE,
                                p_es_id      IN ikis_protocol.prot_es_id%TYPE,
                                p_es         IN ikis_protocol.prot_es%TYPE,
                                p_seans      IN ikis_protocol.prot_seans%TYPE,
                                p_messages   IN VARCHAR2 := '|E|')
        RETURN ikis_protocol.prot_id%TYPE
    IS
        l_res   NUMBER;
    BEGIN
        IF p_es_id IS NULL OR p_es IS NULL
        THEN
            RETURN p_prot_id;
        END IF;

        IF '|E|I|W|' LIKE '%' || p_messages || '%'
        THEN
            SELECT COUNT (ROWID)
              INTO l_res
              FROM v_ikis_protocol
             WHERE     prot_seans = p_seans
                   AND prot_es = p_es
                   AND prot_es_id = p_es_id
                   AND p_messages LIKE
                           '%' || '|' || prot_msg_type || '|' || '%';

            IF l_res = 0
            THEN
                RETURN NULL;
            ELSE
                RETURN p_prot_id;
            END IF;
        ELSE
            RETURN p_prot_id;
        END IF;
    END;
END IKIS_PROTOCOL_UTIL;
/