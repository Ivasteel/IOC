/* Formatted on 8/12/2025 5:58:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$REPORTS_LOCK
IS
    -- Author  : SBOND
    -- Created : 16.11.2021 12:49:23
    -- Purpose : Пакет для блокування одночасно виконання звіту

    --перевірка можливості паралельно
    FUNCTION AllowParallel (p_rpt_id IN NUMBER)
        RETURN PLS_INTEGER;
END API$REPORTS_LOCK;
/


/* Formatted on 8/12/2025 5:58:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$REPORTS_LOCK
IS
    --перевірка можливості паралельно
    FUNCTION AllowParallel (p_rpt_id IN NUMBER)
        RETURN PLS_INTEGER
    IS
        l_res                        PLS_INTEGER := 0;
        l_rt_id                      uss_ndi.v_ndi_report_type.rt_id%TYPE;
        l_rt_code                    uss_ndi.v_ndi_report_type.rt_code%TYPE;
        l_rpt_org                    reports.com_org%TYPE;
        l_rpt_wu                     reports.com_wu%TYPE;
        l_ndi_report_parallel_lock   uss_ndi.v_ndi_rpt_parallel_lock%ROWTYPE;
        l_lock_string                VARCHAR2 (100);
        l_lock_cont                  ikis_lock.t_lockhandler;
        l_lock_cont1                 ikis_lock.t_lockhandler;
        l_try_cnt                    PLS_INTEGER := 0;
        l_get_lock                   PLS_INTEGER := 0;
        l_try_lock_max               PLS_INTEGER := 0;
    BEGIN
        SELECT rt.rt_id,
               rt.rt_code,
               rpt.com_org,
               rpt.com_wu
          INTO l_rt_id,
               l_rt_code,
               l_rpt_org,
               l_rpt_wu
          FROM reports rpt, uss_ndi.v_ndi_report_type rt
         WHERE rpt.rpt_id = p_rpt_id AND rpt.rpt_rt = rt.rt_id;

        BEGIN
            SELECT *
              INTO l_ndi_report_parallel_lock
              FROM uss_ndi.v_ndi_rpt_parallel_lock ndpl
             WHERE ndpl.ndpl_rt = l_rt_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        IF l_ndi_report_parallel_lock.ndpl_id IS NULL
        THEN
            --Якщо не прописано - дозволяємо
            l_res := 1;
        ELSE
            l_lock_string := l_rt_code;

            IF l_ndi_report_parallel_lock.ndpl_org_lock > 0
            THEN
                l_lock_string := l_lock_string || l_rpt_org;
            END IF;

            IF l_ndi_report_parallel_lock.ndpl_usr_lock > 0
            THEN
                l_lock_string := l_lock_string || l_rpt_wu;
            END IF;

            IF l_ndi_report_parallel_lock.ndpl_max_process > 0
            THEN
                ikis_lock.Request_Lock (
                    p_permanent_name      => 'IKISWEBCHEDULERMEDIRENTRPT',
                    p_var_name            => l_lock_string || '_bl',
                    p_errmessage          =>
                        'Неможливо отримати дозвіл на виконання.',
                    p_lockhandler         => l_lock_cont,
                    p_lockmode            => 6,
                    p_timeout             => 30,
                    p_release_on_commit   => FALSE);
                l_try_cnt := 1;

                LOOP         -- делаем три попытки (копися ка как при скедуле)
                    l_try_lock_max := 1;

                    LOOP               -- попытка получить слот для исполнения
                        BEGIN
                            ikis_lock.Request_Lock (
                                p_permanent_name      =>
                                    'IKISWEBCHEDULERMEDIRENTRPT',
                                p_var_name            =>
                                    l_lock_string || l_try_lock_max,
                                p_errmessage          => 'XXXXX',
                                p_lockhandler         => l_lock_cont1,
                                p_lockmode            => 6,
                                p_timeout             => 0,
                                p_release_on_commit   => FALSE);
                            l_get_lock := 1;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                NULL;
                        END;

                        l_try_lock_max := l_try_lock_max + 1;
                        EXIT WHEN (   l_try_lock_max >
                                      l_ndi_report_parallel_lock.ndpl_max_process
                                   OR l_get_lock > 0);
                    END LOOP;

                    l_try_cnt := l_try_cnt + 1;
                    EXIT WHEN (l_get_lock > 0 OR l_try_cnt > 3);
                END LOOP;

                ikis_lock.Releace_Lock (p_lockhandler => l_lock_cont);

                IF (l_get_lock > 0)
                THEN
                    l_res := 1;
                ELSE
                    l_res := 0;
                END IF;
            END IF;
        END IF;

        RETURN l_res;
    END;
END API$REPORTS_LOCK;
/