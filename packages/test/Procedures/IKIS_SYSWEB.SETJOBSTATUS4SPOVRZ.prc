/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.SETJOBSTATUS4SPOVRZ (
    p_act        IN VARCHAR2,
    p_key_id     IN NUMBER,
    p_mess_add   IN VARCHAR2)
IS
    l_jb_id   w_jobs.jb_id%TYPE;
BEGIN
    -- p_act - код действия DIM - удаление данных по выгруженому страху в пром. хранилище
    -- p_key_id - ид ключа
    -- p_mess_add - текст сообщения добавление в протокол
    -- Процедура проставляет значение джоба по выгрузке этого страха в значение ошибки и допишет протокол,
    BEGIN
        IF p_act = 'DIM'
        THEN
            --находим джоб
            SELECT j.jb_id
              INTO l_jb_id
              FROM w_jobs j, scheduler_job_params sj
             WHERE     j.jb_ss_code = 'IKIS_SPOVRZ'
                   AND j.jb_wjt = 'SPOVRZ_UNLOAD_SPOV_DATA'
                   AND j.jb_status = 'ENDED'
                   AND sj.sjp_job = j.jb_id
                   AND sj.sjp_name = 'p_im_id'
                   AND sj.sjp_value = p_key_id;

            -- Дописываем протокол
            INSERT INTO w_jobs_protocol (jm_id,
                                         jm_jb,
                                         jm_ts,
                                         jm_tp,
                                         jm_message)
                 VALUES (0,
                         l_jb_id,
                         SYSDATE,
                         'I',
                         p_mess_add);

            -- меняем статус
            UPDATE w_jobs j
               SET j.jb_status = 'ERROR'
             WHERE j.jb_id = l_jb_id;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;
END SETJOBSTATUS4SPOVRZ;
/
