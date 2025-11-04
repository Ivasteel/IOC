/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_REPORT
IS
    -- Author  : MAXYM
    -- Created : 18.10.2017 15:08:49

    -- Проверка что можно изменять отчеты в пакете и блокирование его записи
    PROCEDURE CheckCanChangePacketAndLock (
        p_rp_id       IN Rpt_Pack.Rp_Id%TYPE,
        p_change_ts   IN Rpt_Pack.change_ts%TYPE);

    -- Получить данные отчета
    PROCEDURE GetReport (p_rpt_id        IN     report.rpt_id%TYPE,
                         p_packet           OUT SYS_REFCURSOR,
                         p_report           OUT SYS_REFCURSOR,
                         p_frames           OUT SYS_REFCURSOR,
                         p_data             OUT SYS_REFCURSOR,
                         p_inlinedata       OUT SYS_REFCURSOR,
                         p_agg_reports      OUT SYS_REFCURSOR);

    -- Возвращает данные по всему пакету
    PROCEDURE GetPacketData (p_rp_id      IN     rpt_pack.rp_id%TYPE,
                             p_packet        OUT SYS_REFCURSOR,
                             p_reports       OUT SYS_REFCURSOR,
                             p_data          OUT SYS_REFCURSOR,
                             p_agg_data      OUT SYS_REFCURSOR);



    -- Создать отчет
    PROCEDURE CreateReport (p_RPT_RP       IN     report.RPT_RP%TYPE,
                            p_RPT_RT       IN     report.RPT_RT%TYPE,
                            p_change_ts    IN     Rpt_Pack.change_ts%TYPE,
                            P_RPT_ID_new      OUT report.rpt_id%TYPE);

    -- Обновление шапки фрейма
    PROCEDURE StartUpdateFrame (p_RP_ID   IN RPT_PACK.RP_ID%TYPE,
                                --  P_RP_CHANGE_TS in RPT_PACK.CHANGE_TS%type,
                                p_RF_ID   IN RPT_FRAME.RF_ID%TYPE-- P_RF_CHANGE_TS in RPT_FRAME.CHANGE_TS%type
                                                                 );

    -- Обновление данных строки автофрейма
    PROCEDURE UpdateRptFrameData (p_rd_id    IN rpt_frame_data.rd_id%TYPE,
                                  p_rd_rf    IN rpt_frame_data.rd_rf%TYPE,
                                  p_rd_f01   IN rpt_frame_data.rd_f01%TYPE,
                                  p_rd_f02   IN rpt_frame_data.rd_f02%TYPE,
                                  p_rd_f03   IN rpt_frame_data.rd_f03%TYPE,
                                  p_rd_f04   IN rpt_frame_data.rd_f04%TYPE,
                                  p_rd_f05   IN rpt_frame_data.rd_f05%TYPE,
                                  p_rd_f06   IN rpt_frame_data.rd_f06%TYPE,
                                  p_rd_f07   IN rpt_frame_data.rd_f07%TYPE,
                                  p_rd_f08   IN rpt_frame_data.rd_f08%TYPE,
                                  p_rd_f09   IN rpt_frame_data.rd_f09%TYPE,
                                  p_rd_f10   IN rpt_frame_data.rd_f10%TYPE,
                                  p_rd_f11   IN rpt_frame_data.rd_f11%TYPE,
                                  p_rd_f12   IN rpt_frame_data.rd_f12%TYPE,
                                  p_rd_f13   IN rpt_frame_data.rd_f13%TYPE,
                                  p_rd_f14   IN rpt_frame_data.rd_f14%TYPE,
                                  p_rd_f15   IN rpt_frame_data.rd_f15%TYPE,
                                  p_rd_f16   IN rpt_frame_data.rd_f16%TYPE,
                                  p_rd_f17   IN rpt_frame_data.rd_f17%TYPE,
                                  p_rd_f18   IN rpt_frame_data.rd_f18%TYPE,
                                  p_rd_f19   IN rpt_frame_data.rd_f19%TYPE,
                                  p_rd_f20   IN rpt_frame_data.rd_f20%TYPE,
                                  p_rd_f21   IN rpt_frame_data.rd_f21%TYPE,
                                  p_rd_f22   IN rpt_frame_data.rd_f22%TYPE,
                                  p_rd_f23   IN rpt_frame_data.rd_f23%TYPE,
                                  p_rd_f24   IN rpt_frame_data.rd_f24%TYPE,
                                  p_rd_f25   IN rpt_frame_data.rd_f25%TYPE,
                                  p_rd_f26   IN rpt_frame_data.rd_f26%TYPE,
                                  p_rd_f27   IN rpt_frame_data.rd_f27%TYPE,
                                  p_rd_f28   IN rpt_frame_data.rd_f28%TYPE,
                                  p_rd_f29   IN rpt_frame_data.rd_f29%TYPE,
                                  p_rd_f30   IN rpt_frame_data.rd_f30%TYPE,
                                  p_rd_f31   IN rpt_frame_data.rd_f31%TYPE,
                                  p_rd_f32   IN rpt_frame_data.rd_f32%TYPE,
                                  p_rd_f33   IN rpt_frame_data.rd_f33%TYPE,
                                  p_rd_f34   IN rpt_frame_data.rd_f34%TYPE,
                                  p_rd_f35   IN rpt_frame_data.rd_f35%TYPE,
                                  p_rd_f36   IN rpt_frame_data.rd_f36%TYPE,
                                  p_rd_f37   IN rpt_frame_data.rd_f37%TYPE,
                                  p_rd_f38   IN rpt_frame_data.rd_f38%TYPE,
                                  p_rd_f39   IN rpt_frame_data.rd_f39%TYPE,
                                  p_rd_f40   IN rpt_frame_data.rd_f40%TYPE,
                                  p_rd_f41   IN rpt_frame_data.rd_f41%TYPE,
                                  p_rd_f42   IN rpt_frame_data.rd_f42%TYPE,
                                  p_rd_f43   IN rpt_frame_data.rd_f43%TYPE,
                                  p_rd_f44   IN rpt_frame_data.rd_f44%TYPE,
                                  p_rd_f45   IN rpt_frame_data.rd_f45%TYPE);

    -- Обновление или встанвка размножаемой строки автофрейма
    PROCEDURE SetRptInlineData (
        p_ird_id        IN OUT rpt_inline_data.ird_id%TYPE,
        p_ird_rf        IN     rpt_inline_data.ird_rf%TYPE,
        p_ird_rrt       IN     rpt_inline_data.ird_rrt%TYPE,
        p_ird_name      IN     rpt_inline_data.ird_name%TYPE,
        p_ird_row_num   IN     rpt_inline_data.ird_row_num%TYPE,
        p_ird_f01       IN     rpt_inline_data.ird_f01%TYPE,
        p_ird_f02       IN     rpt_inline_data.ird_f02%TYPE,
        p_ird_f03       IN     rpt_inline_data.ird_f03%TYPE,
        p_ird_f04       IN     rpt_inline_data.ird_f04%TYPE,
        p_ird_f05       IN     rpt_inline_data.ird_f05%TYPE,
        p_ird_f06       IN     rpt_inline_data.ird_f06%TYPE,
        p_ird_f07       IN     rpt_inline_data.ird_f07%TYPE,
        p_ird_f08       IN     rpt_inline_data.ird_f08%TYPE,
        p_ird_f09       IN     rpt_inline_data.ird_f09%TYPE,
        p_ird_f10       IN     rpt_inline_data.ird_f10%TYPE,
        p_ird_f11       IN     rpt_inline_data.ird_f11%TYPE,
        p_ird_f12       IN     rpt_inline_data.ird_f12%TYPE,
        p_ird_f13       IN     rpt_inline_data.ird_f13%TYPE,
        p_ird_f14       IN     rpt_inline_data.ird_f14%TYPE,
        p_ird_f15       IN     rpt_inline_data.ird_f15%TYPE,
        p_ird_f16       IN     rpt_inline_data.ird_f16%TYPE,
        p_ird_f17       IN     rpt_inline_data.ird_f17%TYPE,
        p_ird_f18       IN     rpt_inline_data.ird_f18%TYPE,
        p_ird_f19       IN     rpt_inline_data.ird_f19%TYPE,
        p_ird_f20       IN     rpt_inline_data.ird_f20%TYPE,
        p_ird_f21       IN     rpt_inline_data.ird_f21%TYPE,
        p_ird_f22       IN     rpt_inline_data.ird_f22%TYPE,
        p_ird_f23       IN     rpt_inline_data.ird_f23%TYPE,
        p_ird_f24       IN     rpt_inline_data.ird_f24%TYPE,
        p_ird_f25       IN     rpt_inline_data.ird_f25%TYPE,
        p_ird_f26       IN     rpt_inline_data.ird_f26%TYPE,
        p_ird_f27       IN     rpt_inline_data.ird_f27%TYPE,
        p_ird_f28       IN     rpt_inline_data.ird_f28%TYPE,
        p_ird_f29       IN     rpt_inline_data.ird_f29%TYPE,
        p_ird_f30       IN     rpt_inline_data.ird_f30%TYPE,
        p_ird_f31       IN     rpt_inline_data.ird_f31%TYPE,
        p_ird_f32       IN     rpt_inline_data.ird_f32%TYPE,
        p_ird_f33       IN     rpt_inline_data.ird_f33%TYPE,
        p_ird_f34       IN     rpt_inline_data.ird_f34%TYPE,
        p_ird_f35       IN     rpt_inline_data.ird_f35%TYPE,
        p_ird_f36       IN     rpt_inline_data.ird_f36%TYPE,
        p_ird_f37       IN     rpt_inline_data.ird_f37%TYPE,
        p_ird_f38       IN     rpt_inline_data.ird_f38%TYPE,
        p_ird_f39       IN     rpt_inline_data.ird_f39%TYPE,
        p_ird_f40       IN     rpt_inline_data.ird_f40%TYPE,
        p_ird_f41       IN     rpt_inline_data.ird_f41%TYPE,
        p_ird_f42       IN     rpt_inline_data.ird_f42%TYPE,
        p_ird_f43       IN     rpt_inline_data.ird_f43%TYPE,
        p_ird_f44       IN     rpt_inline_data.ird_f44%TYPE,
        p_ird_f45       IN     rpt_inline_data.ird_f45%TYPE);

    -- Удаление размножаемой строки автофрейма
    PROCEDURE DeleteRptInlineData (p_ird_id   IN rpt_inline_data.ird_id%TYPE,
                                   p_ird_rf   IN rpt_inline_data.ird_rf%TYPE);

    -- Обновление версии пакета
    PROCEDURE ChangePacketTS (p_rp_id IN Rpt_Pack.Rp_Id%TYPE);

    -- Удаление отчета из пакета
    PROCEDURE DeleteReport (p_rpt_id      IN report.rpt_id%TYPE,
                            p_RPT_RP      IN report.RPT_RP%TYPE,
                            p_change_ts   IN Rpt_Pack.change_ts%TYPE);

    -- Возвращает строку с данными для поледнего завиксированного пакета
    PROCEDURE GetPackCellValue (
        p_com_org                rpt_pack.com_org%TYPE,
        p_rp_end_period_dt       rpt_pack.rp_end_period_dt%TYPE,
        p_rp_gr                  rpt_pack.rp_gr%TYPE,
        p_rt_code                rpt_template.rt_code%TYPE,
        p_rrt_id                 rpt_row_tp.rrt_id%TYPE,
        p_res                OUT SYS_REFCURSOR);
END FINZVIT_REPORT;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_REPORT TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_REPORT
IS
    PROCEDURE CheckCanChangePacketAndLock (
        p_rp_id       IN Rpt_Pack.Rp_Id%TYPE,
        p_change_ts   IN Rpt_Pack.change_ts%TYPE)
    IS
        resource_busy   EXCEPTION;
        PRAGMA EXCEPTION_INIT (resource_busy, -54);
        l_row           v_rpt_pack%ROWTYPE;
    BEGIN
            SELECT *
              INTO l_row
              FROM v_rpt_pack
             WHERE rp_id = p_rp_id
        FOR UPDATE WAIT 30;

        IF (l_row.change_ts != NVL (p_change_ts, 0))
        THEN
            raise_application_error (
                -20000,
                'Пакет змінено іншим шляхом, повторіть процедуру редагування наново.');
        END IF;

        IF (l_row.com_org !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в пакети іншого ОПФУ.');
        END IF;

        IF (l_row.rp_status != 'E')
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в пакет, який не знаходиться в статусі "Редагується".');
        END IF;
    EXCEPTION
        WHEN resource_busy
        THEN
            raise_application_error (
                -20000,
                'Пакет звітності оновлюється іншим користувачем.');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000, 'Пакет звітності не знайдено.');
    END;

    PROCEDURE GetReport (p_rpt_id        IN     report.rpt_id%TYPE,
                         p_packet           OUT SYS_REFCURSOR,
                         p_report           OUT SYS_REFCURSOR,
                         p_frames           OUT SYS_REFCURSOR,
                         p_data             OUT SYS_REFCURSOR,
                         p_inlinedata       OUT SYS_REFCURSOR,
                         p_agg_reports      OUT SYS_REFCURSOR)
    IS
        l_rp_id   Rpt_Pack.Rp_Id%TYPE;
        l_rp_st   Rpt_Pack.Rp_Status%TYPE;
    BEGIN
        BEGIN
            SELECT rp_id, rp_status
              INTO l_rp_id, l_rp_st
              FROM v_report r INNER JOIN v_rpt_pack p ON p.rp_id = r.rpt_rp
             WHERE r.rpt_id = p_rpt_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (-20000,
                                         'Пакет звітності не знайдено.');
        END;

        OPEN p_packet FOR
            SELECT p.*,
                   EXTRACT (YEAR FROM p.RP_START_PERIOD_DT)
                       RP_YEAR,
                   EXTRACT (MONTH FROM p.RP_START_PERIOD_DT)
                       RP_MONTH,
                   TRUNC (
                       (EXTRACT (MONTH FROM p.RP_START_PERIOD_DT) + 2) / 3)
                       RP_QUARTER,
                   org_name
              FROM v_rpt_pack p JOIN v_opfu ON com_org = org_id
             WHERE p.rp_id = l_rp_id;

        OPEN p_report FOR SELECT r.*
                            FROM v_report r
                           WHERE r.rpt_id = p_rpt_id;

        OPEN p_frames FOR   SELECT *
                              FROM v_rpt_frame f
                             WHERE f.RF_RPT = p_rpt_id
                          ORDER BY f.RF_ID;

        OPEN p_data FOR
              SELECT fd.*
                FROM V_RPT_FRAME_DATA fd
                     INNER JOIN V_RPT_FRAME f ON f.RF_ID = fd.RD_RF
               WHERE f.RF_RPT = p_rpt_id
            ORDER BY fd.RD_ID;

        OPEN p_inlinedata FOR
              SELECT fd.*
                FROM V_RPT_INLINE_DATA fd
                     INNER JOIN V_RPT_FRAME f ON f.RF_ID = fd.IRD_RF
               WHERE f.RF_RPT = p_rpt_id
            ORDER BY fd.IRD_ID;


        IF (l_rp_st = 'A')
        THEN            -- Для актуальных только где есть пакеты для агрегации
            OPEN p_agg_reports FOR
                  SELECT *
                    FROM v_aggr_reports ar
                   WHERE ar.RPT_ID_DEST = p_rpt_id AND ar.RP_ID_SRC IS NOT NULL
                ORDER BY ar.org_code;
        ELSE
            OPEN p_agg_reports FOR -- Для остальных - либо есть пакет либо опфу у нас не в миграции
                  SELECT *
                    FROM v_aggr_reports ar
                   WHERE     ar.RPT_ID_DEST = p_rpt_id
                         AND (   ar.RP_ID_SRC IS NOT NULL
                              OR ar.org_id IN
                                     (SELECT org_id FROM v_active_opfu))
                ORDER BY ar.org_code;
        END IF;
    END;

    PROCEDURE CreateReport (p_RPT_RP       IN     report.RPT_RP%TYPE,
                            p_RPT_RT       IN     report.RPT_RT%TYPE,
                            p_change_ts    IN     Rpt_Pack.change_ts%TYPE,
                            P_RPT_ID_new      OUT report.rpt_id%TYPE)
    IS
        l_cnt     PLS_INTEGER;
        l_rf_id   rpt_frame.rf_id%TYPE;
    BEGIN
        CheckCanChangePacketAndLock (p_RPT_RP, p_change_ts);

        SELECT COUNT (*)
          INTO l_cnt
          FROM rpt_in_pack_template  rip
               JOIN rpt_pack p ON p.rp_pt = rip.r2pt_pt
         WHERE rip.r2pt_rt = p_RPT_RT AND p.rp_id = p_RPT_RP;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Обраний тип звіту не може бути створено в даному пакеті');
        END IF;

        INSERT INTO report (rpt_rp, rpt_rt)
             VALUES (p_rpt_rp, p_rpt_rt)
          RETURNING rpt_id
               INTO P_RPT_ID_new;

        FOR c IN (SELECT *
                    FROM rpt_frame_template f, frames_in_rpt_template fit
                   WHERE fit.f2rt_rft = f.rft_id AND fit.f2rt_rt = p_RPT_RT)
        LOOP
            INSERT INTO rpt_frame (rf_rft, rf_change_dt, rf_rpt)
                 VALUES (c.f2rt_rft, SYSDATE, P_RPT_ID_new)
              RETURNING rf_id
                   INTO l_rf_id;

            IF (c.rft_tp = 'A')
            THEN
                -- auto frame
                INSERT INTO rpt_frame_data (rd_rrt, rd_rf)
                    SELECT rrt_id, l_rf_id
                      FROM rpt_row_tp r
                     WHERE r.rrt_rft = c.f2rt_rft AND r.rrt_cat != 'V'; -- except virtual
            END IF;
        END LOOP;
    END;

    PROCEDURE StartUpdateFrame (p_RP_ID   IN RPT_PACK.RP_ID%TYPE--,P_RP_CHANGE_TS in RPT_PACK.CHANGE_TS%type
                                                                ,
                                p_RF_ID   IN RPT_FRAME.RF_ID%TYPE--,P_RF_CHANGE_TS in RPT_FRAME.CHANGE_TS%type
                                                                 )
    IS
        l_row   V_RPT_FRAME%ROWTYPE;
    BEGIN
        SELECT f.*
          INTO l_row
          FROM V_RPT_FRAME  f
               JOIN v_report r ON r.RPT_ID = f.RF_RPT
               JOIN V_RPT_PACK p ON p.RP_ID = r.RPT_RP
         WHERE f.RF_ID = p_RF_ID AND RP_ID = p_RP_ID; -- Проверяем по 2 идам, чтобы юзер не смог нас на..ть и сохранить данные чужого фрейма под видом своего пакета

        UPDATE RPT_FRAME f
           SET f.rf_change_dt = SYSDATE
         WHERE f.rf_id = p_RF_ID--and f.change_ts = P_RF_CHANGE_TS
                                ;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                'Фрейм змінено іншим шляхом, повторіть процедуру редагування наново.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000, 'Не знайдено фрейм у пакеті.');
    END;

    PROCEDURE UpdateRptFrameData (p_rd_id    IN rpt_frame_data.rd_id%TYPE,
                                  p_rd_rf    IN rpt_frame_data.rd_rf%TYPE,
                                  p_rd_f01   IN rpt_frame_data.rd_f01%TYPE,
                                  p_rd_f02   IN rpt_frame_data.rd_f02%TYPE,
                                  p_rd_f03   IN rpt_frame_data.rd_f03%TYPE,
                                  p_rd_f04   IN rpt_frame_data.rd_f04%TYPE,
                                  p_rd_f05   IN rpt_frame_data.rd_f05%TYPE,
                                  p_rd_f06   IN rpt_frame_data.rd_f06%TYPE,
                                  p_rd_f07   IN rpt_frame_data.rd_f07%TYPE,
                                  p_rd_f08   IN rpt_frame_data.rd_f08%TYPE,
                                  p_rd_f09   IN rpt_frame_data.rd_f09%TYPE,
                                  p_rd_f10   IN rpt_frame_data.rd_f10%TYPE,
                                  p_rd_f11   IN rpt_frame_data.rd_f11%TYPE,
                                  p_rd_f12   IN rpt_frame_data.rd_f12%TYPE,
                                  p_rd_f13   IN rpt_frame_data.rd_f13%TYPE,
                                  p_rd_f14   IN rpt_frame_data.rd_f14%TYPE,
                                  p_rd_f15   IN rpt_frame_data.rd_f15%TYPE,
                                  p_rd_f16   IN rpt_frame_data.rd_f16%TYPE,
                                  p_rd_f17   IN rpt_frame_data.rd_f17%TYPE,
                                  p_rd_f18   IN rpt_frame_data.rd_f18%TYPE,
                                  p_rd_f19   IN rpt_frame_data.rd_f19%TYPE,
                                  p_rd_f20   IN rpt_frame_data.rd_f20%TYPE,
                                  p_rd_f21   IN rpt_frame_data.rd_f21%TYPE,
                                  p_rd_f22   IN rpt_frame_data.rd_f22%TYPE,
                                  p_rd_f23   IN rpt_frame_data.rd_f23%TYPE,
                                  p_rd_f24   IN rpt_frame_data.rd_f24%TYPE,
                                  p_rd_f25   IN rpt_frame_data.rd_f25%TYPE,
                                  p_rd_f26   IN rpt_frame_data.rd_f26%TYPE,
                                  p_rd_f27   IN rpt_frame_data.rd_f27%TYPE,
                                  p_rd_f28   IN rpt_frame_data.rd_f28%TYPE,
                                  p_rd_f29   IN rpt_frame_data.rd_f29%TYPE,
                                  p_rd_f30   IN rpt_frame_data.rd_f30%TYPE,
                                  p_rd_f31   IN rpt_frame_data.rd_f31%TYPE,
                                  p_rd_f32   IN rpt_frame_data.rd_f32%TYPE,
                                  p_rd_f33   IN rpt_frame_data.rd_f33%TYPE,
                                  p_rd_f34   IN rpt_frame_data.rd_f34%TYPE,
                                  p_rd_f35   IN rpt_frame_data.rd_f35%TYPE,
                                  p_rd_f36   IN rpt_frame_data.rd_f36%TYPE,
                                  p_rd_f37   IN rpt_frame_data.rd_f37%TYPE,
                                  p_rd_f38   IN rpt_frame_data.rd_f38%TYPE,
                                  p_rd_f39   IN rpt_frame_data.rd_f39%TYPE,
                                  p_rd_f40   IN rpt_frame_data.rd_f40%TYPE,
                                  p_rd_f41   IN rpt_frame_data.rd_f41%TYPE,
                                  p_rd_f42   IN rpt_frame_data.rd_f42%TYPE,
                                  p_rd_f43   IN rpt_frame_data.rd_f43%TYPE,
                                  p_rd_f44   IN rpt_frame_data.rd_f44%TYPE,
                                  p_rd_f45   IN rpt_frame_data.rd_f45%TYPE)
    IS
    BEGIN
        UPDATE rpt_frame_data
           SET rd_f01 = p_rd_f01,
               rd_f02 = p_rd_f02,
               rd_f03 = p_rd_f03,
               rd_f04 = p_rd_f04,
               rd_f05 = p_rd_f05,
               rd_f06 = p_rd_f06,
               rd_f07 = p_rd_f07,
               rd_f08 = p_rd_f08,
               rd_f09 = p_rd_f09,
               rd_f10 = p_rd_f10,
               rd_f11 = p_rd_f11,
               rd_f12 = p_rd_f12,
               rd_f13 = p_rd_f13,
               rd_f14 = p_rd_f14,
               rd_f15 = p_rd_f15,
               rd_f16 = p_rd_f16,
               rd_f17 = p_rd_f17,
               rd_f18 = p_rd_f18,
               rd_f19 = p_rd_f19,
               rd_f20 = p_rd_f20,
               rd_f21 = p_rd_f21,
               rd_f22 = p_rd_f22,
               rd_f23 = p_rd_f23,
               rd_f24 = p_rd_f24,
               rd_f25 = p_rd_f25,
               rd_f26 = p_rd_f26,
               rd_f27 = p_rd_f27,
               rd_f28 = p_rd_f28,
               rd_f29 = p_rd_f29,
               rd_f30 = p_rd_f30,
               rd_f31 = p_rd_f31,
               rd_f32 = p_rd_f32,
               rd_f33 = p_rd_f33,
               rd_f34 = p_rd_f34,
               rd_f35 = p_rd_f35,
               rd_f36 = p_rd_f36,
               rd_f37 = p_rd_f37,
               rd_f38 = p_rd_f38,
               rd_f39 = p_rd_f39,
               rd_f40 = p_rd_f40,
               rd_f41 = p_rd_f41,
               rd_f42 = p_rd_f42,
               rd_f43 = p_rd_f43,
               rd_f44 = p_rd_f44,
               rd_f45 = p_rd_f45
         WHERE rd_id = p_rd_id AND rd_rf = p_rd_rf;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                   'Internal error: no record updated (rd_id:'
                || p_rd_id
                || ', rd_rf:'
                || p_rd_rf
                || ')');
        END IF;
    END;

    PROCEDURE SetRptInlineData (
        p_ird_id        IN OUT rpt_inline_data.ird_id%TYPE,
        p_ird_rf        IN     rpt_inline_data.ird_rf%TYPE,
        p_ird_rrt       IN     rpt_inline_data.ird_rrt%TYPE,
        p_ird_name      IN     rpt_inline_data.ird_name%TYPE,
        p_ird_row_num   IN     rpt_inline_data.ird_row_num%TYPE,
        p_ird_f01       IN     rpt_inline_data.ird_f01%TYPE,
        p_ird_f02       IN     rpt_inline_data.ird_f02%TYPE,
        p_ird_f03       IN     rpt_inline_data.ird_f03%TYPE,
        p_ird_f04       IN     rpt_inline_data.ird_f04%TYPE,
        p_ird_f05       IN     rpt_inline_data.ird_f05%TYPE,
        p_ird_f06       IN     rpt_inline_data.ird_f06%TYPE,
        p_ird_f07       IN     rpt_inline_data.ird_f07%TYPE,
        p_ird_f08       IN     rpt_inline_data.ird_f08%TYPE,
        p_ird_f09       IN     rpt_inline_data.ird_f09%TYPE,
        p_ird_f10       IN     rpt_inline_data.ird_f10%TYPE,
        p_ird_f11       IN     rpt_inline_data.ird_f11%TYPE,
        p_ird_f12       IN     rpt_inline_data.ird_f12%TYPE,
        p_ird_f13       IN     rpt_inline_data.ird_f13%TYPE,
        p_ird_f14       IN     rpt_inline_data.ird_f14%TYPE,
        p_ird_f15       IN     rpt_inline_data.ird_f15%TYPE,
        p_ird_f16       IN     rpt_inline_data.ird_f16%TYPE,
        p_ird_f17       IN     rpt_inline_data.ird_f17%TYPE,
        p_ird_f18       IN     rpt_inline_data.ird_f18%TYPE,
        p_ird_f19       IN     rpt_inline_data.ird_f19%TYPE,
        p_ird_f20       IN     rpt_inline_data.ird_f20%TYPE,
        p_ird_f21       IN     rpt_inline_data.ird_f21%TYPE,
        p_ird_f22       IN     rpt_inline_data.ird_f22%TYPE,
        p_ird_f23       IN     rpt_inline_data.ird_f23%TYPE,
        p_ird_f24       IN     rpt_inline_data.ird_f24%TYPE,
        p_ird_f25       IN     rpt_inline_data.ird_f25%TYPE,
        p_ird_f26       IN     rpt_inline_data.ird_f26%TYPE,
        p_ird_f27       IN     rpt_inline_data.ird_f27%TYPE,
        p_ird_f28       IN     rpt_inline_data.ird_f28%TYPE,
        p_ird_f29       IN     rpt_inline_data.ird_f29%TYPE,
        p_ird_f30       IN     rpt_inline_data.ird_f30%TYPE,
        p_ird_f31       IN     rpt_inline_data.ird_f31%TYPE,
        p_ird_f32       IN     rpt_inline_data.ird_f32%TYPE,
        p_ird_f33       IN     rpt_inline_data.ird_f33%TYPE,
        p_ird_f34       IN     rpt_inline_data.ird_f34%TYPE,
        p_ird_f35       IN     rpt_inline_data.ird_f35%TYPE,
        p_ird_f36       IN     rpt_inline_data.ird_f36%TYPE,
        p_ird_f37       IN     rpt_inline_data.ird_f37%TYPE,
        p_ird_f38       IN     rpt_inline_data.ird_f38%TYPE,
        p_ird_f39       IN     rpt_inline_data.ird_f39%TYPE,
        p_ird_f40       IN     rpt_inline_data.ird_f40%TYPE,
        p_ird_f41       IN     rpt_inline_data.ird_f41%TYPE,
        p_ird_f42       IN     rpt_inline_data.ird_f42%TYPE,
        p_ird_f43       IN     rpt_inline_data.ird_f43%TYPE,
        p_ird_f44       IN     rpt_inline_data.ird_f44%TYPE,
        p_ird_f45       IN     rpt_inline_data.ird_f45%TYPE)
    IS
    BEGIN
        IF p_ird_id = 0
        THEN
            p_ird_id := NULL;
        END IF;

        UPDATE rpt_inline_data
           SET ird_name = p_ird_name,
               ird_row_num = p_ird_row_num,
               ird_f01 = p_ird_f01,
               ird_f02 = p_ird_f02,
               ird_f03 = p_ird_f03,
               ird_f04 = p_ird_f04,
               ird_f05 = p_ird_f05,
               ird_f06 = p_ird_f06,
               ird_f07 = p_ird_f07,
               ird_f08 = p_ird_f08,
               ird_f09 = p_ird_f09,
               ird_f10 = p_ird_f10,
               ird_f11 = p_ird_f11,
               ird_f12 = p_ird_f12,
               ird_f13 = p_ird_f13,
               ird_f14 = p_ird_f14,
               ird_f15 = p_ird_f15,
               ird_f16 = p_ird_f16,
               ird_f17 = p_ird_f17,
               ird_f18 = p_ird_f18,
               ird_f19 = p_ird_f19,
               ird_f20 = p_ird_f20,
               ird_f21 = p_ird_f21,
               ird_f22 = p_ird_f22,
               ird_f23 = p_ird_f23,
               ird_f24 = p_ird_f24,
               ird_f25 = p_ird_f25,
               ird_f26 = p_ird_f26,
               ird_f27 = p_ird_f27,
               ird_f28 = p_ird_f28,
               ird_f29 = p_ird_f29,
               ird_f30 = p_ird_f30,
               ird_f31 = p_ird_f31,
               ird_f32 = p_ird_f32,
               ird_f33 = p_ird_f33,
               ird_f34 = p_ird_f34,
               ird_f35 = p_ird_f35,
               ird_f36 = p_ird_f36,
               ird_f37 = p_ird_f37,
               ird_f38 = p_ird_f38,
               ird_f39 = p_ird_f39,
               ird_f40 = p_ird_f40,
               ird_f41 = p_ird_f41,
               ird_f42 = p_ird_f42,
               ird_f43 = p_ird_f43,
               ird_f44 = p_ird_f44,
               ird_f45 = p_ird_f45
         WHERE ird_id = p_ird_id AND ird_rf = p_ird_rf;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO rpt_inline_data (ird_rf,
                                         ird_rrt,
                                         ird_name,
                                         ird_row_num,
                                         ird_f01,
                                         ird_f02,
                                         ird_f03,
                                         ird_f04,
                                         ird_f05,
                                         ird_f06,
                                         ird_f07,
                                         ird_f08,
                                         ird_f09,
                                         ird_f10,
                                         ird_f11,
                                         ird_f12,
                                         ird_f13,
                                         ird_f14,
                                         ird_f15,
                                         ird_f16,
                                         ird_f17,
                                         ird_f18,
                                         ird_f19,
                                         ird_f20,
                                         ird_f21,
                                         ird_f22,
                                         ird_f23,
                                         ird_f24,
                                         ird_f25,
                                         ird_f26,
                                         ird_f27,
                                         ird_f28,
                                         ird_f29,
                                         ird_f30,
                                         ird_f31,
                                         ird_f32,
                                         ird_f33,
                                         ird_f34,
                                         ird_f35,
                                         ird_f36,
                                         ird_f37,
                                         ird_f38,
                                         ird_f39,
                                         ird_f40,
                                         ird_f41,
                                         ird_f42,
                                         ird_f43,
                                         ird_f44,
                                         ird_f45)
                 VALUES (p_ird_rf,
                         p_ird_rrt,
                         p_ird_name,
                         p_ird_row_num,
                         p_ird_f01,
                         p_ird_f02,
                         p_ird_f03,
                         p_ird_f04,
                         p_ird_f05,
                         p_ird_f06,
                         p_ird_f07,
                         p_ird_f08,
                         p_ird_f09,
                         p_ird_f10,
                         p_ird_f11,
                         p_ird_f12,
                         p_ird_f13,
                         p_ird_f14,
                         p_ird_f15,
                         p_ird_f16,
                         p_ird_f17,
                         p_ird_f18,
                         p_ird_f19,
                         p_ird_f20,
                         p_ird_f21,
                         p_ird_f22,
                         p_ird_f23,
                         p_ird_f24,
                         p_ird_f25,
                         p_ird_f26,
                         p_ird_f27,
                         p_ird_f28,
                         p_ird_f29,
                         p_ird_f30,
                         p_ird_f31,
                         p_ird_f32,
                         p_ird_f33,
                         p_ird_f34,
                         p_ird_f35,
                         p_ird_f36,
                         p_ird_f37,
                         p_ird_f38,
                         p_ird_f39,
                         p_ird_f40,
                         p_ird_f41,
                         p_ird_f42,
                         p_ird_f43,
                         p_ird_f44,
                         p_ird_f45)
              RETURNING ird_id
                   INTO p_ird_id;
        END IF;
    END;

    PROCEDURE DeleteRptInlineData (p_ird_id   IN rpt_inline_data.ird_id%TYPE,
                                   p_ird_rf   IN rpt_inline_data.ird_rf%TYPE)
    IS
    BEGIN
        DELETE FROM rpt_inline_data
              WHERE ird_id = p_ird_id AND ird_rf = p_ird_rf;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                   'Internal error: no record deleted (ird_id:'
                || p_ird_id
                || ', ird_rf:'
                || p_ird_rf
                || ')');
        END IF;
    END;


    PROCEDURE GetPacketData (p_rp_id      IN     rpt_pack.rp_id%TYPE,
                             p_packet        OUT SYS_REFCURSOR,
                             p_reports       OUT SYS_REFCURSOR,
                             p_data          OUT SYS_REFCURSOR,
                             p_agg_data      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_packet FOR
            SELECT p.*,
                   EXTRACT (YEAR FROM p.RP_START_PERIOD_DT)
                       RP_YEAR,
                   EXTRACT (MONTH FROM p.RP_START_PERIOD_DT)
                       RP_MONTH,
                   TRUNC (
                       (EXTRACT (MONTH FROM p.RP_START_PERIOD_DT) + 2) / 3)
                       RP_QUARTER,
                   org_name
              FROM v_rpt_pack p JOIN v_opfu ON com_org = org_id
             WHERE p.rp_id = p_rp_id;

        OPEN p_reports FOR SELECT *
                             FROM v_report r
                            WHERE r.rpt_rp = p_rp_id;

        OPEN p_data FOR   SELECT fd.*
                            FROM rpt_frame_data fd
                                 INNER JOIN rpt_frame f ON f.rf_id = fd.rd_rf
                                 INNER JOIN v_report r ON r.rpt_id = f.rf_rpt
                           --       inner join v_rpt_pack p on p.RP_ID = r.rpt_rp -- rls on v_rpt_pack
                           WHERE r.rpt_rp = p_rp_id
                        ORDER BY fd.rd_id;

        OPEN p_agg_data FOR
              SELECT RD_rrt,
                     r.rpt_rt                  rt_id,
                     SUM (NVL (RD_F01, 0))     RD_F01,
                     SUM (NVL (RD_F02, 0))     RD_F02,
                     SUM (NVL (RD_F03, 0))     RD_F03,
                     SUM (NVL (RD_F04, 0))     RD_F04,
                     SUM (NVL (RD_F05, 0))     RD_F05,
                     SUM (NVL (RD_F06, 0))     RD_F06,
                     SUM (NVL (RD_F07, 0))     RD_F07,
                     SUM (NVL (RD_F08, 0))     RD_F08,
                     SUM (NVL (RD_F09, 0))     RD_F09,
                     SUM (NVL (RD_F10, 0))     RD_F10,
                     SUM (NVL (RD_F11, 0))     RD_F11,
                     SUM (NVL (RD_F12, 0))     RD_F12,
                     SUM (NVL (RD_F13, 0))     RD_F13,
                     SUM (NVL (RD_F14, 0))     RD_F14,
                     SUM (NVL (RD_F15, 0))     RD_F15,
                     SUM (NVL (RD_F16, 0))     RD_F16,
                     SUM (NVL (RD_F17, 0))     RD_F17,
                     SUM (NVL (RD_F18, 0))     RD_F18,
                     SUM (NVL (RD_F19, 0))     RD_F19,
                     SUM (NVL (RD_F20, 0))     RD_F20,
                     SUM (NVL (RD_F21, 0))     RD_F21,
                     SUM (NVL (RD_F22, 0))     RD_F22,
                     SUM (NVL (RD_F23, 0))     RD_F23,
                     SUM (NVL (RD_F24, 0))     RD_F24,
                     SUM (NVL (RD_F25, 0))     RD_F25,
                     SUM (NVL (RD_F26, 0))     RD_F26,
                     SUM (NVL (RD_F27, 0))     RD_F27,
                     SUM (NVL (RD_F28, 0))     RD_F28,
                     SUM (NVL (RD_F29, 0))     RD_F29,
                     SUM (NVL (RD_F30, 0))     RD_F30,
                     SUM (NVL (RD_F31, 0))     RD_F31,
                     SUM (NVL (RD_F32, 0))     RD_F32,
                     SUM (NVL (RD_F33, 0))     RD_F33,
                     SUM (NVL (RD_F34, 0))     RD_F34,
                     SUM (NVL (RD_F35, 0))     RD_F35,
                     SUM (NVL (RD_F36, 0))     RD_F36,
                     SUM (NVL (RD_F37, 0))     RD_F37,
                     SUM (NVL (RD_F38, 0))     RD_F38,
                     SUM (NVL (RD_F39, 0))     RD_F39,
                     SUM (NVL (RD_F40, 0))     RD_F40,
                     SUM (NVL (RD_F41, 0))     RD_F41,
                     SUM (NVL (RD_F42, 0))     RD_F42,
                     SUM (NVL (RD_F43, 0))     RD_F43,
                     SUM (NVL (RD_F44, 0))     RD_F44,
                     SUM (NVL (RD_F45, 0))     RD_F45
                FROM RPT_FRAME_DATA fd
                     INNER JOIN RPT_FRAME f ON f.rf_id = fd.rd_rf
                     INNER JOIN REPORT r ON r.rpt_id = f.rf_rpt
                     INNER JOIN AGGR_PACK a ON a.ap_rp_src = r.rpt_rp
                     INNER JOIN V_RPT_PACK p ON p.RP_ID = a.ap_rp_dest
               WHERE p.RP_ID = p_rp_id
            GROUP BY RD_rrt, rpt_rt
            ORDER BY RD_rrt, rt_id;
    END;


    PROCEDURE ChangePacketTS (p_rp_id IN Rpt_Pack.Rp_Id%TYPE)
    IS
    BEGIN
        UPDATE rpt_pack
           SET change_ts = FINZVIT_COMMON.GetNextChangeTs
         WHERE rp_id = p_rp_id;
    END;

    PROCEDURE DeleteReport (p_rpt_id      IN report.rpt_id%TYPE,
                            p_RPT_RP      IN report.RPT_RP%TYPE,
                            p_change_ts   IN Rpt_Pack.change_ts%TYPE)
    IS
    BEGIN
        --   CheckCanChangePacketAndLock(p_rp_id     => p_RPT_RP,                                p_change_ts => p_change_ts);
        DELETE FROM rpt_inline_data id
              WHERE id.ird_rf IN (SELECT rf_id
                                    FROM rpt_frame f
                                   WHERE f.rf_rpt = p_rpt_id);

        DELETE FROM rpt_frame_data fd
              WHERE fd.rd_rf IN (SELECT rf_id
                                   FROM rpt_frame f
                                  WHERE f.rf_rpt = p_rpt_id);

        DELETE FROM rpt_frame f
              WHERE f.rf_rpt = p_rpt_id;


        DELETE FROM report
              WHERE rpt_id = p_rpt_id AND rpt_rp = p_rpt_rp;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (-20000, 'Не знайдено звіт у пакеті');
        END IF;
    END;

    PROCEDURE GetPackCellValue (
        p_com_org                rpt_pack.com_org%TYPE,
        p_rp_end_period_dt       rpt_pack.rp_end_period_dt%TYPE,
        p_rp_gr                  rpt_pack.rp_gr%TYPE,
        p_rt_code                rpt_template.rt_code%TYPE,
        p_rrt_id                 rpt_row_tp.rrt_id%TYPE,
        p_res                OUT SYS_REFCURSOR)
    IS
        l_rp_id   rpt_pack.rp_id%TYPE;
    BEGIN
        --  raise_application_error(-20000, p_com_org||'='||p_rp_end_period_dt||'='||p_rp_gr||'='|| p_rt_code||'='|| p_rrt_id);

        SELECT MAX (rp_id)
          INTO l_rp_id
          FROM v_rpt_pack p
         WHERE     p.COM_ORG = p_com_org
               AND p.RP_END_PERIOD_DT = p_rp_end_period_dt
               AND p.RP_STATUS = 'A'
               AND p.RP_GR = p_rp_gr;

        OPEN p_res FOR
            SELECT *
              FROM rpt_frame_data  fd
                   JOIN rpt_frame f ON f.rf_id = fd.rd_rf
                   JOIN report r ON r.rpt_id = f.rf_rpt
                   JOIN rpt_template t ON t.rt_id = r.rpt_rt
             WHERE     r.rpt_rp = l_rp_id
                   AND t.rt_code = p_rt_code
                   AND fd.rd_rrt = p_rrt_id;
    END;
END FINZVIT_REPORT;
/