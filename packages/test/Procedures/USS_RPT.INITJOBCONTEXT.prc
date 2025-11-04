/* Formatted on 8/12/2025 5:59:02 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE USS_RPT.InitJobContext
IS
--обертка для инициализации контекста задачи, здесь только заглушка
--в прикладных подсистемах соответствующий вызов
--имя процедуры должно быть таким же, поскольку вызываеся из  ikis_sysweb.ScheduleWrap
BEGIN
    --ikis_sysweb.ikis_debug_pipe.WriteMsg('InitJobContext');

    --  uss_esr_context.SetUSerContext(p_user => ikis_sysweb_schedule.getuser);
    --uss_esr_context.SetUSerContext(p_user => uss_esr_context.GetContext('LOGIN'));
    --uss_esr_context.SetUSerContext(p_user => nvl(ikis_sysweb.ikis_sysweb_jobs.GetUser,IKIS_SYSWEB_SCHEDULE.GetUser));
    uss_rpt_context.SetJobContext (NULL);
    ikis_sysweb.ikis_web_context.setjobcontext (NULL, 'USS_RPT');
END InitJobContext;
/
