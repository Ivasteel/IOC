/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_PACK_STATUS
IS
    -- Запис в журнал при зміні статусу
    PROCEDURE SavePackJournal (p_rpj_rp          IN NUMBER,
                               p_prj_status      IN VARCHAR2,
                               p_rpj_comment     IN VARCHAR2,
                               p_rpj_file_code   IN VARCHAR2);

    -- Зміна статусу пакету
    PROCEDURE ChangeStatus (p_rp_id           IN NUMBER,
                            p_rp_status       IN VARCHAR2,
                            p_rpj_comment     IN VARCHAR2 := NULL,
                            p_rpj_file_code   IN VARCHAR2 := NULL);

    -- Фіксування пакетів
    PROCEDURE FixPackStatus (p_rp_id         IN NUMBER,
                             p_rp_status     IN VARCHAR2,
                             p_rpj_comment   IN VARCHAR2 := NULL);

    -- Последние подписанные данные и строка журнала которая им соответствует
    PROCEDURE GetLastSignedRec (p_rp_id   IN     rpt_pack.rp_id%TYPE,
                                p_res        OUT SYS_REFCURSOR);
END FINZVIT_PACK_STATUS;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_PACK_STATUS TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_PACK_STATUS
IS
    PROCEDURE SavePackJournal (p_rpj_rp          IN NUMBER,
                               p_prj_status      IN VARCHAR2,
                               p_rpj_comment     IN VARCHAR2,
                               p_rpj_file_code   IN VARCHAR2)
    IS
        l_com_wu         NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'IKISUID'); -- Ід користувача
        l_com_org        NUMBER := SYS_CONTEXT ('IKISFINZVIT', 'OPFU'); -- ІД організації
        l_com_wu_pib     VARCHAR2 (100 BYTE);
        l_com_wu_login   VARCHAR2 (1000 BYTE);
        l_wut            NUMBER;
        l_org            NUMBER;
        l_org_org        NUMBER;
        l_trc            VARCHAR2 (1000 BYTE);
        l_numid          VARCHAR2 (1000 BYTE);
    BEGIN
        DNET$FINZVIT_CONTEXT.GetCurrUserInfo (P_USERNAME   => l_com_wu_login,
                                              P_PIB        => l_com_wu_pib,
                                              P_WUT        => l_wut,
                                              P_ORG        => l_org,
                                              P_ORG_ORG    => l_org_org,
                                              P_TRC        => l_trc,
                                              P_NUMID      => l_numid);

        INSERT INTO RPT_PACK_JOURNAL (RPJ_RP,
                                      RPJ_DATE,
                                      RPJ_STATUS,
                                      COM_WU,
                                      COM_ORG,
                                      rpj_comment,
                                      rpj_file_code,
                                      COM_WU_LOGIN,
                                      COM_WU_PIB)
             VALUES (p_rpj_rp,
                     SYSDATE,
                     p_prj_status,
                     l_com_wu,
                     l_com_org,
                     p_rpj_comment,
                     p_rpj_file_code,
                     l_com_wu_login,
                     l_com_wu_pib);
    END;

    PROCEDURE ChangeStatus (p_rp_id           IN NUMBER,
                            p_rp_status       IN VARCHAR2,
                            p_rpj_comment     IN VARCHAR2 := NULL,
                            p_rpj_file_code   IN VARCHAR2 := NULL)
    IS
        l_status       RPT_PACK.RP_STATUS%TYPE;

        l_org          NUMBER
            := NVL (
                   SYS_CONTEXT (ikis_finzvit_context.gContext,
                                ikis_finzvit_context.gOPFU),
                   0);
        l_pack_org     NUMBER;

        l_parent_org   NUMBER;
    BEGIN
        SELECT RP_STATUS, com_org, org_org
          INTO l_status, l_pack_org, l_parent_org
          FROM RPT_PACK JOIN v_opfu ON com_org = org_id
         WHERE RP_ID = p_rp_id;



        IF (p_rp_status NOT IN ('F', 'I') AND l_org != l_pack_org)
        THEN
            raise_application_error (-20001, 'Пакет належить іншому ОПФУ.');
        END IF;

        IF (p_rp_status IN ('I') AND l_org != l_parent_org)
        THEN
            raise_application_error (
                -20001,
                'Операція дозволена лише головному ОПФУ');
        END IF;


        IF NOT (l_org = l_parent_org OR l_org = l_pack_org)
        THEN
            raise_application_error (
                -20001,
                'Пакет належить або підпорядковано іншому ОПФУ.');
        END IF;


        -- Контроль пакету звітності
        IF p_rp_status = 'C'
        THEN
            IF l_status != 'E'
            THEN
                raise_application_error (
                    -20001,
                    'Статус пакету повинен бути «Редагується»!');
            END IF;
        END IF;

        -- Якщо хочемо повернути на редагування
        IF p_rp_status = 'E'
        THEN
            IF l_status IN ('E', 'I', 'A')
            THEN
                raise_application_error (
                    -20001,
                    'В статусі «Зафіксований» та «Включений до звіту» повернути на доопрацювання немождиво!');
            END IF;
        END IF;

        -- Підпис пакету ЕЦП
        IF p_rp_status IN ('W', 'V')
        THEN
            IF l_status NOT IN ('W', 'C')
            THEN
                raise_application_error (
                    -20001,
                    'Підпис пакету ЕЦП можливий тільки в статусі «Коректний» та «Частково підписаний»!');
            END IF;
        END IF;

        -- Включений до  звіту
        IF p_rp_status = 'I'
        THEN
            IF (l_status != 'V')
            THEN
                raise_application_error (
                    -20001,
                    'Статус пакета для консолідації повинен бути «Поданий»!');
            END IF;
        END IF;

        -- Помилковий
        IF p_rp_status = 'F'
        THEN
            IF (l_status != 'I')
            THEN
                raise_application_error (
                    -20001,
                    'Статус пакета повинен бути «Включений до  звіту»!');
            END IF;
        END IF;



        UPDATE RPT_PACK
           SET RP_STATUS = p_rp_status,
               change_ts = FINZVIT_COMMON.GetNextChangeTs
         WHERE RP_ID = p_rp_id;

        SavePackJournal (p_rp_id,
                         p_rp_status,
                         p_rpj_comment,
                         p_rpj_file_code);
    END;

    PROCEDURE FixPackStatus (p_rp_id         IN NUMBER,
                             p_rp_status     IN VARCHAR2,
                             p_rpj_comment   IN VARCHAR2 := NULL)
    IS
        l_status             RPT_PACK.RP_STATUS%TYPE;
        l_start_period_dt    RPT_PACK.RP_START_PERIOD_DT%TYPE;
        l_rp_end_period_dt   RPT_PACK.RP_END_PERIOD_DT%TYPE;
        l_rp_gr              RPT_PACK.RP_GR%TYPE;

        l_org                NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_pack_org           NUMBER;
    BEGIN
        IF (NVL (l_org, 0) != 28000)
        THEN
            raise_application_error (
                -20000,
                'Зафіксувати пакет можна лище на центральному рівні');
        END IF;

        SELECT rp.RP_STATUS, com_org
          INTO l_status, l_pack_org
          FROM RPT_PACK rp
         WHERE RP_ID = p_rp_id;

        IF p_rp_status = 'A'
        THEN
            IF l_status != 'C'
            THEN
                raise_application_error (
                    -20001,
                    'Зафіксувати пакет можна тільки в статусі «Коректний»!');
            END IF;
        ELSE
            raise_application_error (-20001, 'Зафіксувати пакет не можливо!');
        END IF;

        IF (NVL (l_pack_org, 0) != 28000)
        THEN
            raise_application_error (
                -20000,
                'Можна зафіксувати пакет лище центрального рівня.');
        END IF;


        UPDATE RPT_PACK
           SET RP_STATUS = p_rp_status,
               change_ts = FINZVIT_COMMON.GetNextChangeTs
         WHERE RP_ID = p_rp_id;

        SavePackJournal (p_rp_id,
                         p_rp_status,
                         p_rpj_comment,
                         NULL);

        FOR pac IN (    SELECT ap.ap_rp_src
                          FROM AGGR_PACK ap
                    START WITH ap.ap_rp_dest = p_rp_id
                    CONNECT BY PRIOR ap.ap_rp_src = ap.ap_rp_dest)
        LOOP
            NULL;

            UPDATE RPT_PACK
               SET RP_STATUS = p_rp_status,
                   change_ts = FINZVIT_COMMON.GetNextChangeTs
             WHERE RP_ID = pac.ap_rp_src;

            SavePackJournal (pac.ap_rp_src,
                             p_rp_status,
                             p_rpj_comment,
                             NULL);
        END LOOP;
    END;

    PROCEDURE GetLastSignedRec (p_rp_id   IN     rpt_pack.rp_id%TYPE,
                                p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT *
              FROM (  SELECT v_rpt_journal.*
                        FROM v_rpt_journal JOIN V_RPT_PACK ON rpj_rp = rp_id
                       WHERE rp_id = p_rp_id AND rpj_file_code IS NOT NULL
                    ORDER BY rpj_date DESC, rpj_id DESC);
    END;
END FINZVIT_PACK_STATUS;
/