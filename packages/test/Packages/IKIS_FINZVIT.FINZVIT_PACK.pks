/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_PACK
IS
    -- Дістати пакет
    PROCEDURE GetPack (p_rp_id      IN     NUMBER,
                       p_rpt_card      OUT SYS_REFCURSOR,
                       p_report        OUT SYS_REFCURSOR);

    -- Збереження пакету звітності
    PROCEDURE SavePack (p_rp_year              IN     NUMBER,
                        p_rp_month             IN     NUMBER,
                        p_rp_tp                IN     VARCHAR2,
                        p_rp_period            IN     VARCHAR2,
                        p_rp_gr                IN     VARCHAR2,
                        p_rp_start_period_dt   IN     DATE,
                        p_rp_end_period_dt     IN     DATE,
                        p_rp_quarter           IN     NUMBER,
                        p_rp_id                   OUT NUMBER);

    -- Видалення пакету
    PROCEDURE DeletePack (p_rp_id IN NUMBER);


    -- Возвращает данные по всему пакету для подписания (не включает информацию по переменным полям, типа статуса)
    PROCEDURE GetPacketDataForSign (p_rp_id        IN     rpt_pack.rp_id%TYPE,
                                    p_packet          OUT SYS_REFCURSOR,
                                    p_reports         OUT SYS_REFCURSOR,
                                    p_frames          OUT SYS_REFCURSOR,
                                    p_data            OUT SYS_REFCURSOR,
                                    p_inlinedata      OUT SYS_REFCURSOR);
END FINZVIT_PACK;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_PACK TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_PACK
IS
    PROCEDURE getDateFromQrt (p_quart      IN     NUMBER,
                              p_year       IN     NUMBER,
                              p_start_dt      OUT DATE,
                              p_end_dt        OUT DATE)
    IS
    BEGIN
        SELECT ADD_MONTHS (dt, (p_quart - 1) * 3),
               LAST_DAY (ADD_MONTHS (dt, (p_quart - 1) * 3 + 2))
          INTO p_start_dt, p_end_dt
          FROM (SELECT TO_DATE (p_year || '0101', 'yyyymmdd') dt FROM DUAL);
    END;

    -- Отримуємо ІД шаблону пакету
    FUNCTION GetPackTemlate (p_pt_gr       IN VARCHAR2,
                             p_pt_period   IN VARCHAR2,
                             p_pt_ol       IN NUMBER,
                             p_start_dt    IN DATE)
        RETURN NUMBER
    IS
        l_pt_id   NUMBER;
    BEGIN
        BEGIN
            SELECT pt.pt_id
              INTO l_pt_id
              FROM RPT_PACK_TEMPLATE pt
             WHERE     (   (    pt.pt_start_dt <= p_start_dt
                            AND pt.pt_end_dt >= p_start_dt)
                        OR (    pt.pt_start_dt <= p_start_dt
                            AND pt.pt_end_dt IS NULL))
                   AND pt.pt_period = p_pt_period
                   AND pt.pt_gr = p_pt_gr
                   AND pt.pt_ol = p_pt_ol;

            RETURN l_pt_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (-20001, 'Відсутній шаблон пакету!');
        END;
    END;

    PROCEDURE GetPack (p_rp_id      IN     NUMBER,
                       p_rpt_card      OUT SYS_REFCURSOR,
                       p_report        OUT SYS_REFCURSOR)
    IS
        l_rp_pt   NUMBER;
    BEGIN
        SELECT rp.rp_pt
          INTO l_rp_pt
          FROM V_RPT_PACK rp
         WHERE rp.rp_id = p_rp_id;

        OPEN p_rpt_card FOR
            SELECT rp.rp_id,
                   rp.rp_pt,
                   rp.rp_status,
                   rp.rp_period,
                   rp.rp_tp,
                   rp.rp_create_dt,
                   EXTRACT (YEAR FROM rp.rp_start_period_dt)
                       rp_year,
                   EXTRACT (MONTH FROM rp.rp_start_period_dt)
                       rp_month,
                   TRUNC ((EXTRACT (MONTH FROM RP_START_PERIOD_DT) + 2) / 3)
                       RP_QUARTER,
                   rp.com_org,
                   rp.Change_Ts,
                   rp.rp_start_period_dt,
                   rp.rp_end_period_dt
              FROM RPT_PACK rp
             WHERE rp.rp_id = p_rp_id;

        OPEN p_report FOR
              SELECT rt.*, r.*
                FROM RPT_IN_PACK_TEMPLATE r2pt
                     JOIN RPT_TEMPLATE rt ON rt.rt_id = r2pt.r2pt_rt
                     LEFT JOIN report r
                         ON r.rpt_rt = r2pt.r2pt_rt AND r.rpt_rp = p_rp_id
               WHERE R2PT_PT = l_rp_pt
            ORDER BY r2pt.r2pt_ord;
    END;

    PROCEDURE SavePack (p_rp_year              IN     NUMBER,
                        p_rp_month             IN     NUMBER,
                        p_rp_tp                IN     VARCHAR2,
                        p_rp_period            IN     VARCHAR2,
                        p_rp_gr                IN     VARCHAR2,
                        p_rp_start_period_dt   IN     DATE,
                        p_rp_end_period_dt     IN     DATE,
                        p_rp_quarter           IN     NUMBER,
                        p_rp_id                   OUT NUMBER)
    IS
        l_cnt_p      NUMBER;
        l_cnt_prev   NUMBER;
        l_cnt_p_A    NUMBER;
        l_pt         NUMBER;
        l_start_dt   DATE;
        l_stop_dt    DATE;
        l_com_wu     NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'IKISUID'); -- Ід користувача
        l_com_org    NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'OPFU'); -- ІД організації
        l_user_tp    NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'IUTP'); -- Права користувача
    BEGIN
        IF p_rp_period = 'M'
        THEN
            l_start_dt :=
                TO_DATE ('01.' || p_rp_month || '.' || p_rp_year,
                         'dd.mm.yyyy');
            l_stop_dt :=
                LAST_DAY (
                    TO_DATE ('01.' || p_rp_month || '.' || p_rp_year,
                             'dd.mm.yyyy'));
        ELSIF p_rp_period = 'D'
        THEN
            l_start_dt := p_rp_start_period_dt;
            l_stop_dt := p_rp_start_period_dt;
        ELSIF p_rp_period = 'Y'
        THEN
            l_start_dt := TO_DATE ('01.01.' || p_rp_year, 'dd.mm.yyyy');
            l_stop_dt := TO_DATE ('31.12.' || p_rp_year, 'dd.mm.yyyy');
        ELSIF p_rp_period = 'Q'
        THEN
            getDateFromQrt (p_quart      => p_rp_quarter,
                            p_year       => p_rp_year,
                            p_start_dt   => l_start_dt,
                            p_end_dt     => l_stop_dt);
        ELSE
            l_start_dt := p_rp_start_period_dt;
            l_stop_dt := p_rp_end_period_dt;
        END IF;



        -- Шукаємо пакет за період з типом основний і організації користувача
        SELECT COUNT (1)
          INTO l_cnt_p
          FROM RPT_PACK rp
         WHERE     rp.rp_tp = 'P'
               AND rp.rp_start_period_dt >= l_start_dt
               AND rp.rp_end_period_dt <= l_stop_dt
               AND rp.com_org = l_com_org
               AND rp.rp_gr = p_rp_gr;

        IF p_rp_tp = 'P'
        THEN                                    -- 'P' - Тип пакету "Основний"
            -- Якщо пакету з типом основний за цей період ще не має
            IF l_cnt_p = 0
            THEN
                SELECT COUNT (1)
                  INTO l_cnt_prev
                  FROM RPT_PACK rp
                 WHERE     rp.rp_status NOT IN ('A')
                       AND rp.com_org = l_com_org
                       AND rp.rp_gr = p_rp_gr;

                /*           AND rp.rp_start_period_dt >= add_months(l_start_dt, -1) and
                                  rp.rp_end_period_dt <= add_months(l_stop_dt, -1);*/
                IF l_cnt_prev > 0
                THEN
                    raise_application_error (
                        -20001,
                        'Створення нового пакету звітності з типом «основний» за новий звітний період неможливе, того що існує пакет звітності в статусі не «Зафіксований»!');
                ELSE
                    l_pt :=
                        GetPackTemlate (p_pt_gr       => p_rp_gr,
                                        p_pt_period   => p_rp_period,
                                        p_pt_ol       => l_user_tp,
                                        p_start_dt    => l_start_dt);

                    INSERT INTO RPT_PACK rp (RP_STATUS,
                                             RP_PERIOD,
                                             RP_TP,
                                             RP_GR,
                                             RP_START_PERIOD_DT,
                                             RP_END_PERIOD_DT,
                                             COM_WU,
                                             COM_ORG,
                                             RP_CREATE_DT,
                                             RP_PT)
                         VALUES ('E',
                                 p_rp_period,
                                 p_rp_tp,
                                 p_rp_gr,
                                 l_start_dt,
                                 l_stop_dt,
                                 l_com_wu,
                                 l_com_org,
                                 SYSDATE,
                                 l_pt)
                      RETURNING RP_ID
                           INTO p_rp_id;

                    FINZVIT_PACK_STATUS.SavePackJournal (p_rp_id,
                                                         'E',
                                                         NULL,
                                                         NULL);
                END IF;
            ELSE
                raise_application_error (
                    -20001,
                    'Пакет з таким тимпом за цей період вже існує!');
            END IF;
        ELSIF p_rp_tp = 'C'
        THEN                                               -- 'С' - Доповнення
            IF l_cnt_p = 1
            THEN
                SELECT COUNT (1)
                  INTO l_cnt_p_A
                  FROM RPT_PACK rp
                 WHERE     rp.rp_tp = 'P'
                       AND rp.rp_start_period_dt >= l_start_dt
                       AND rp.rp_end_period_dt <= l_stop_dt
                       AND rp.rp_status = 'A';

                IF l_cnt_p_A = 0
                THEN
                    raise_application_error (
                        -20001,
                        'Створення пакету з типом «доповнення» без наявності пакету звітності з типом «основний» за звітний період в статусі «Зафіксований» неможливо!');
                END IF;

                l_pt :=
                    GetPackTemlate (p_pt_gr       => p_rp_gr,
                                    p_pt_period   => p_rp_period,
                                    p_pt_ol       => l_user_tp,
                                    p_start_dt    => l_start_dt);

                INSERT INTO RPT_PACK rp (RP_STATUS,
                                         RP_PERIOD,
                                         RP_TP,
                                         RP_GR,
                                         RP_START_PERIOD_DT,
                                         RP_END_PERIOD_DT,
                                         COM_WU,
                                         COM_ORG,
                                         RP_CREATE_DT,
                                         RP_PT)
                     VALUES ('E',
                             p_rp_period,
                             p_rp_tp,
                             p_rp_gr,
                             l_start_dt,
                             l_stop_dt,
                             l_com_wu,
                             l_com_org,
                             SYSDATE,
                             l_pt)
                  RETURNING RP_ID
                       INTO p_rp_id;

                FINZVIT_PACK_STATUS.SavePackJournal (p_rp_id,
                                                     'E',
                                                     NULL,
                                                     NULL);
            ELSE
                raise_application_error (
                    -20001,
                    'Пакет з типом «Доповнення» без наявності пакету звітності з типом «Основний» за звітний період в статусі «Зафіксований» відсутній!');
            END IF;
        END IF;
    END;

    PROCEDURE DeletePack (p_rp_id IN NUMBER)
    IS
        l_cnt       NUMBER;
        l_cnt_rep   NUMBER;
        l_cnt_agg   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM RPT_PACK rp
         WHERE rp.rp_id = p_rp_id AND rp.rp_status NOT IN ('E');

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20001,
                'Пакет можна видалити тільки в статусі «Редагується»!');
        END IF;

        SELECT COUNT (1)
          INTO l_cnt_agg
          FROM AGGR_PACK
         WHERE AP_RP_DEST = p_rp_id;

        IF l_cnt_agg > 0
        THEN
            raise_application_error (
                -20001,
                'Видалення неможливе, так як консолідований звіт пакету містить звіти нижчого рівня. Спочатку відкріпіть звіти нижчого рівня від пакету!');
        END IF;



        SELECT COUNT (1)
          INTO l_cnt_rep
          FROM report
         WHERE rpt_rp = p_rp_id;

        IF l_cnt_rep > 0
        THEN
            raise_application_error (
                -20001,
                'Видалення неможливе. Спочатку видаліть звіти!');
        END IF;

        DELETE FROM RPT_PACK_JOURNAL
              WHERE RPJ_RP = p_rp_id;

        DELETE FROM RPT_PACK
              WHERE RP_ID = p_rp_id;
    END;


    PROCEDURE GetPacketDataForSign (p_rp_id        IN     rpt_pack.rp_id%TYPE,
                                    p_packet          OUT SYS_REFCURSOR,
                                    p_reports         OUT SYS_REFCURSOR,
                                    p_frames          OUT SYS_REFCURSOR,
                                    p_data            OUT SYS_REFCURSOR,
                                    p_inlinedata      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_packet FOR SELECT rp_id,
                                 rp_pt,
                                 --rp_status,
                                 rp_period,
                                 rp_tp,
                                 rp_gr,
                                 rp_start_period_dt,
                                 rp_end_period_dt
                            --com_wu,
                            --com_org,
                            --change_ts,
                            --rp_create_dt
                            FROM v_rpt_pack p
                           WHERE p.rp_id = p_rp_id;

        OPEN p_reports FOR   SELECT rpt_id, rpt_rp, rpt_rt
                               FROM v_report r
                              WHERE r.rpt_rp = p_rp_id
                           ORDER BY rpt_rt, rpt_id;

        OPEN p_frames FOR
              SELECT rf_id, rf_rft, rf_rpt
                FROM v_report r JOIN v_rpt_frame f ON f.RF_RPT = r.RPT_ID
               WHERE r.rpt_rp = p_rp_id
            ORDER BY rpt_rt, f.RF_RFT, f.RF_ID;


        OPEN p_data FOR   SELECT fd.*
                            FROM rpt_frame_data fd
                                 INNER JOIN rpt_frame f ON f.rf_id = fd.rd_rf
                                 INNER JOIN v_report r ON r.rpt_id = f.rf_rpt
                           WHERE r.rpt_rp = p_rp_id
                        ORDER BY fd.rd_rf, fd.rd_id;

        OPEN p_inlinedata FOR
              SELECT fdi.*
                FROM rpt_inline_data fdi
                     INNER JOIN rpt_frame f ON f.rf_id = fdi.ird_rf
                     INNER JOIN v_report r ON r.rpt_id = f.rf_rpt
               WHERE r.rpt_rp = p_rp_id
            ORDER BY fdi.ird_rf, fdi.ird_id;
    END;
END FINZVIT_PACK;
/