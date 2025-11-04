/* Formatted on 8/12/2025 5:50:18 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE USS_ESR.InitJobContext
IS
--обертка для инициализации контекста задачи, здесь только заглушка
--в прикладных подсистемах соответствующий вызов
--имя процедуры должно быть таким же, поскольку вызываеся из  ikis_sysweb.ScheduleWrap
BEGIN
    --ikis_sysweb.ikis_debug_pipe.WriteMsg('InitJobContext');
    uss_esr_context.SetJobContext (NULL);
    ikis_sysweb.ikis_web_context.setjobcontext (NULL, 'USS_ESR');
END InitJobContext;
/
