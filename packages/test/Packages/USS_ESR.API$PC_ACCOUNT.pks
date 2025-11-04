/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_ACCOUNT
IS
    -- Author  : VANO
    -- Created : 15.09.2022 8:48:21
    -- Purpose : Функції роботи з особовими рахунками

    --Перевести ОР в режим "заборони реміграції"
    PROCEDURE make_pa_non_remigratable (p_mode INTEGER, --1=за ідом з параметів,2=за ідами з таблиці tmp_workidpa
                                                        p_pa_id INTEGER);
END API$PC_ACCOUNT;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_ACCOUNT
IS
    --Перевести ОР в режим "заборони реміграції"
    PROCEDURE make_pa_non_remigratable (p_mode INTEGER, --1=за ідом з параметів,2=за ідами з таблиці tmp_workidpa
                                                        p_pa_id INTEGER)
    IS
        l_cnt   INTEGER;
    BEGIN
        IF p_mode = 1 AND p_pa_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_idpa
                  WHERE 1 = 1;

            INSERT INTO tmp_work_idpa (x_id)
                SELECT pa_id
                  FROM v_pc_account, v_personalcase
                 WHERE     pa_id = p_pa_id
                       AND pa_pc = pc_id
                       AND (pa_stage IS NULL OR pa_stage = '1');

            l_cnt := SQL%ROWCOUNT;
        ELSE
            --Видаляємо ті ОР, яких ми "не бачимо";
            DELETE FROM tmp_work_idpa
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM v_pc_account, v_personalcase
                              WHERE x_id = pa_id AND pa_pc = pc_id);

            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_idpa, v_pc_account, v_personalcase
             WHERE     x_id = pa_id
                   AND pa_pc = pc_id
                   AND (pa_stage IS NULL OR pa_stage = '1');
        END IF;

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        --Виставляємо режим заборони міграції
        UPDATE pc_account
           SET pa_stage = '2'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_idpa
                     WHERE pa_id = x_id);
    END;
BEGIN
    -- Initialization
    NULL;
END API$PC_ACCOUNT;
/