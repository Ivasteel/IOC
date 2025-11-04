/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.MESSENGER_EXAMPLE
IS
    i   INTEGER;
BEGIN
    --Создание сообщения
    i :=
        ikis_messenger.CreateMessage (p_boundary_dt   => SYSDATE + 5,
                                      p_priority      => 1,
                                      p_caption       => 'TEST2');
    --Добавление подписчика (можно добавлять нескольких)
    ikis_messenger.AddSubscr (p_mes => i, p_iusr_id => 961);
    --Добавление первого параметра: код задачи
    ikis_messenger.AddParam (p_mes     => i,
                             p_tp      => 'DEVS', -- тип параметра (имеет такое значение для ДЕВСовых кодов задач
                             p_value   => 'CRD_JOB',    -- ДЕВСовый код задачи
                             p_name    => 'VIEW'); -- тип открытия (пока что в поддерживаются методы VIEW и BROWSE)
           -- поддержку можно расширить в Tfra_Brw_Messenger.acOpenCardExecute
    ikis_messenger.AddParam (p_mes     => i,
                             p_tp      => 'SETPN', -- тип параметра для передачи в SETPARAM
                             p_value   => '1491',        -- значение параметра
                             p_name    => 'FJ_ID');           -- имя параметра
    ikis_messenger.AddParam (p_mes     => i,
                             p_tp      => 'TEXT', -- тип параметра для отображении значения в превьюве броузера сообщений
                             p_value   => 'Текстовый разъяснительный текст',                              -- значение параметра
                             p_name    => NULL);                            --

    -- процедуры транзакцией не управляют
    COMMIT;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line (SQLERRM);
        ROLLBACK;
END;
/
