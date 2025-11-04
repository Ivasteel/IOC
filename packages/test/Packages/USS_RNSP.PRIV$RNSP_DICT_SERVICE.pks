/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.PRIV$RNSP_DICT_SERVICE
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id    IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
                   p_res      OUT SYS_REFCURSOR);


    -- Зберегти
    PROCEDURE Save (
        p_RNSPDS_ID             IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN     RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN     RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN     RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN     RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN     RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN     RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN     RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN     RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN     RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN     RNSP_DICT_SERVICE.rnspds_is_standards%TYPE,
        p_new_id                   OUT RNSP_DICT_SERVICE.RNSPDS_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_DICT_SERVICE.RNSPDS_ID%TYPE);

    -- Запис не змінився
    FUNCTION IsNoChanges (
        p_RNSPDS_ID             IN RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN RNSP_DICT_SERVICE.rnspds_is_standards%TYPE)
        RETURN BOOLEAN;

    -- Список за фільтром
    PROCEDURE Query (p_RNSPS_id IN NUMBER, p_res OUT SYS_REFCURSOR);
END PRIV$RNSP_DICT_SERVICE;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.PRIV$RNSP_DICT_SERVICE
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id    IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
                   p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM RNSP_DICT_SERVICE t
                        WHERE RNSPDS_ID = p_id;
    END;

    -- Зберегти
    PROCEDURE Save (
        p_RNSPDS_ID             IN     RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN     RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN     RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN     RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN     RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN     RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN     RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN     RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN     RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN     RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN     RNSP_DICT_SERVICE.rnspds_is_standards%TYPE,
        p_new_id                   OUT RNSP_DICT_SERVICE.RNSPDS_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPDS_ID IS NULL
        THEN
            INSERT INTO RNSP_DICT_SERVICE (RNSPDS_NST,
                                           RNSPDS_CONTENT,
                                           RNSPDS_CONDITION,
                                           RNSPDS_SUM,
                                           RNSPDS_IZM,
                                           RNSPDS_CNT,
                                           RNSPDS_CAN_URGANT,
                                           RNSPDS_IS_INROOM,
                                           RNSPDS_IS_INNURSING,
                                           rnspds_is_standards)
                 VALUES (p_RNSPDS_NST,
                         p_RNSPDS_CONTENT,
                         p_RNSPDS_CONDITION,
                         p_RNSPDS_SUM,
                         p_RNSPDS_IZM,
                         p_RNSPDS_CNT,
                         p_RNSPDS_CAN_URGANT,
                         p_RNSPDS_IS_INROOM,
                         p_RNSPDS_IS_INNURSING,
                         p_rnspds_is_standards)
              RETURNING RNSPDS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPDS_ID;

            UPDATE RNSP_DICT_SERVICE
               SET RNSPDS_NST = p_RNSPDS_NST,
                   RNSPDS_CONTENT = p_RNSPDS_CONTENT,
                   RNSPDS_CONDITION = p_RNSPDS_CONDITION,
                   RNSPDS_SUM = p_RNSPDS_SUM,
                   RNSPDS_IZM = p_RNSPDS_IZM,
                   RNSPDS_CNT = p_RNSPDS_CNT,
                   RNSPDS_CAN_URGANT = p_RNSPDS_CAN_URGANT,
                   RNSPDS_IS_INROOM = p_RNSPDS_IS_INROOM,
                   RNSPDS_IS_INNURSING = p_RNSPDS_IS_INNURSING,
                   rnspds_is_standards = p_rnspds_is_standards
             WHERE RNSPDS_ID = p_RNSPDS_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_DICT_SERVICE.RNSPDS_ID%TYPE)
    IS
    BEGIN
        DELETE FROM RNSP_DICT_SERVICE
              WHERE RNSPDS_ID = p_id;
    END;

    -- Запис не змінився
    FUNCTION IsNoChanges (
        p_RNSPDS_ID             IN RNSP_DICT_SERVICE.RNSPDS_ID%TYPE,
        p_RNSPDS_NST            IN RNSP_DICT_SERVICE.RNSPDS_NST%TYPE,
        p_RNSPDS_CONTENT        IN RNSP_DICT_SERVICE.RNSPDS_CONTENT%TYPE,
        p_RNSPDS_CONDITION      IN RNSP_DICT_SERVICE.RNSPDS_CONDITION%TYPE,
        p_RNSPDS_SUM            IN RNSP_DICT_SERVICE.RNSPDS_SUM%TYPE,
        p_RNSPDS_IZM            IN RNSP_DICT_SERVICE.RNSPDS_IZM%TYPE,
        p_RNSPDS_CNT            IN RNSP_DICT_SERVICE.RNSPDS_CNT%TYPE,
        p_RNSPDS_CAN_URGANT     IN RNSP_DICT_SERVICE.RNSPDS_CAN_URGANT%TYPE,
        p_RNSPDS_IS_INROOM      IN RNSP_DICT_SERVICE.RNSPDS_IS_INROOM%TYPE,
        p_RNSPDS_IS_INNURSING   IN RNSP_DICT_SERVICE.RNSPDS_IS_INNURSING%TYPE,
        p_rnspds_is_standards   IN RNSP_DICT_SERVICE.rnspds_is_standards%TYPE)
        RETURN BOOLEAN
    IS
        l_rec   RNSP_DICT_SERVICE%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_rec
          FROM RNSP_DICT_SERVICE
         WHERE RNSPDS_id = p_RNSPDS_id;

        RETURN (    tools.isequalN (p_RNSPDS_NST, l_rec.RNSPDS_NST)
                AND tools.isequalS (p_RNSPDS_CONTENT, l_rec.RNSPDS_CONTENT)
                AND tools.isequalS (p_RNSPDS_CONDITION,
                                    l_rec.RNSPDS_CONDITION)
                AND tools.isequalN (p_rnspds_sum, l_rec.rnspds_sum)
                AND tools.isequalS (p_rnspds_izm, l_rec.rnspds_izm)
                AND tools.isequalN (p_rnspds_cnt, l_rec.rnspds_cnt)
                AND tools.isequalS (p_rnspds_can_urgant,
                                    l_rec.rnspds_can_urgant)
                AND tools.isequalS (p_rnspds_is_inroom,
                                    l_rec.rnspds_is_inroom)
                AND tools.isequalS (p_rnspds_is_innursing,
                                    l_rec.rnspds_is_innursing)
                AND tools.isequalS (p_rnspds_is_standards,
                                    l_rec.rnspds_is_standards));
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN FALSE;
    END;

    -- Список за фільтром
    PROCEDURE Query (p_RNSPS_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT rnspds_id,
                   rnspds_nst,
                   rnspds_content,
                   rnspds_condition,
                   rnspds_sum,
                   rnspds_izm,
                   rnspds_cnt,
                   rnspds_can_urgant,
                   rnspds_is_inroom,
                   rnspds_is_innursing,
                   rnspds_is_standards,
                   rnspds_sum_fm,
                   nst_code,
                   nst_name,
                   rnspt_id,
                   rnspt_rnspm,
                   rnspt_nst,
                   rnspt_start_dt,
                   rnspt_stop_dt,
                   rnspt_sum,
                   rnspt_sum_fm,
                   rnspt_rnd,
                   rnspt_hs,
                   history_status,
                   service_Status,
                   rnspt_Reason
              FROM (SELECT rnspds_id,
                           rnspds_nst,
                           rnspds_content,
                           rnspds_condition,
                           rnspds_sum,
                           rnspds_izm,
                           rnspds_cnt,
                           rnspds_can_urgant,
                           rnspds_is_inroom,
                           rnspds_is_innursing,
                           rnspds_is_standards,
                           rnspds_sum_fm,
                           tp.nst_code,
                           tp.nst_name,
                           rnspt_id,
                           rnspt_rnspm,
                           rnspt_nst,
                           rnspt_start_dt,
                           rnspt_stop_dt,
                           rnspt_sum,
                           rnspt_sum_fm,
                           rnspt_rnd,
                           rnspt_hs,
                           t.history_status,
                           CASE
                               WHEN ass.history_status = 'A' THEN 'надається'
                               ELSE 'не надається'
                           END
                               AS service_Status,
                           COUNT (
                               CASE
                                   WHEN NVL (ass.history_status, 'H') = 'H'
                                   THEN
                                       1
                               END)
                               OVER (PARTITION BY tp.nst_id, l.rnsp2s_rnsps)
                               ass_history_qty,
                           COUNT (
                               CASE WHEN ass.history_status = 'A' THEN 1 END)
                               OVER (PARTITION BY tp.nst_id, l.rnsp2s_rnsps)
                               ass_active_qty,
                           NVL (ass.history_status, 'H')
                               AS ass_history_status,
                           dt.ndt_name
                               AS rnspt_Reason
                      --,g.nsg_code,
                      --g.nsg_name
                      FROM rnsp_state  s
                           JOIN rnsp_main m ON (m.rnspm_id = s.rnsps_rnspm)
                           JOIN rnsp2service l
                               ON (s.rnsps_id = l.rnsp2s_rnsps)
                           JOIN rnsp_dict_service d
                               ON l.rnsp2s_rnspds = d.rnspds_id
                           LEFT JOIN ap_service ass
                               ON (    ASs.Aps_Nst = d.rnspds_nst
                                   AND ass.aps_ap = m.rnspm_ap_edit)
                           --LEFT JOIN ap_service ass ON (ASs.Aps_Nst = d.rnspds_nst)
                           LEFT JOIN rnsp_tariff t
                               ON (    t.rnspt_rnspm = s.rnsps_rnspm
                                   AND t.rnspt_nst = d.rnspds_nst
                                   AND SYSDATE BETWEEN t.rnspt_start_dt
                                                   AND t.rnspt_stop_dt
                                   AND t.history_status = 'A')
                           LEFT JOIN rn_document rd
                               ON (rd.rnd_id = t.rnspt_rnd)
                           LEFT JOIN uss_ndi.v_ndi_document_type dt
                               ON (dt.ndt_id = rd.rnd_ndt)
                           LEFT JOIN uss_ndi.v_Ndi_Service_Type tp
                               ON tp.nst_id = d.rnspds_nst
                     --  left join uss_ndi.v_ndi_service_group g on g.nsg_id = tp.nst_nsg
                     WHERE l.rnsp2s_rnsps = p_rnsps_id)
             WHERE    ass_history_status = 'A'
                   OR (ass_history_status = 'H' AND ass_active_qty = 0);
    END;
END PRIV$RNSP_DICT_SERVICE;
/