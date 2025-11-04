/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.InitJobContext
IS
--обертка для инициализации контекста задачи, здесь только заглушка
--в прикладных подсистемах соответствующий вызов
--имя процедуры должно быть таким же, поскольку вызываеся из  ikis_sysweb.ScheduleWrap
BEGIN
    NULL;
--raise_application_error(-20000,'ikis_sysweb.InitJobContext');
END InitJobContext;
/
