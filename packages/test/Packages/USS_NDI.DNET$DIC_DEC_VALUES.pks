/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_DEC_VALUES
IS
    -- Author  : BOGDAN
    -- Created : 29.03.2024 17:05:05
    -- Purpose : Довідник числових довідників

    -- налаштування довідників
    PROCEDURE get_setup (res_Cur OUT SYS_REFCURSOR);

    -- список
    PROCEDURE get_journal (p_nds_id IN NUMBER, res_Cur OUT SYS_REFCURSOR);

    -- встановлення значення
    PROCEDURE set_value (
        p_NDV_NDS        IN     NDI_DEC_VALUES.NDV_NDS%TYPE,
        p_NDV_START_DT   IN     NDI_DEC_VALUES.NDV_START_DT%TYPE,
        p_NDV_STOP_DT    IN     NDI_DEC_VALUES.NDV_STOP_DT%TYPE,
        p_NDV_VALUE1     IN     NDI_DEC_VALUES.NDV_VALUE1%TYPE,
        p_NDV_VALUE2     IN     NDI_DEC_VALUES.NDV_VALUE2%TYPE,
        p_NDV_VALUE3     IN     NDI_DEC_VALUES.NDV_VALUE3%TYPE,
        p_NDV_VALUE4     IN     NDI_DEC_VALUES.NDV_VALUE4%TYPE,
        p_NDV_VALUE5     IN     NDI_DEC_VALUES.NDV_VALUE5%TYPE,
        p_NDV_NNA        IN     NDI_DEC_VALUES.NDV_NNA%TYPE,
        p_new_id            OUT NDI_DEC_VALUES.NDV_ID%TYPE);


    PROCEDURE delete_value (p_ndv_id IN NUMBER);
END DNET$DIC_DEC_VALUES;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_DEC_VALUES TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_DEC_VALUES
IS
    -- налаштування довідників
    PROCEDURE get_setup (res_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_Cur FOR SELECT *
                           FROM ndi_dec_setup t;
    END;

    -- список
    PROCEDURE get_journal (p_nds_id IN NUMBER, res_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        OPEN res_Cur FOR
              SELECT t.*,
                        '№'
                     || n.nna_num
                     || ' від '
                     || TO_CHAR (n.nna_dt, 'DD.MM.YYYY')    AS ndv_nna_name,
                     s.nds_name                             AS ndv_nds_name
                FROM ndi_dec_values t
                     JOIN ndi_normative_act n ON (n.nna_id = t.ndv_nna)
                     JOIN ndi_dec_setup s ON (s.nds_id = t.ndv_nds)
               WHERE t.ndv_nds = p_nds_id AND t.history_status = 'A'
            ORDER BY t.ndv_start_dt DESC;
    END;

    -- встановлення значення
    PROCEDURE set_value (
        p_NDV_NDS        IN     NDI_DEC_VALUES.NDV_NDS%TYPE,
        p_NDV_START_DT   IN     NDI_DEC_VALUES.NDV_START_DT%TYPE,
        p_NDV_STOP_DT    IN     NDI_DEC_VALUES.NDV_STOP_DT%TYPE,
        p_NDV_VALUE1     IN     NDI_DEC_VALUES.NDV_VALUE1%TYPE,
        p_NDV_VALUE2     IN     NDI_DEC_VALUES.NDV_VALUE2%TYPE,
        p_NDV_VALUE3     IN     NDI_DEC_VALUES.NDV_VALUE3%TYPE,
        p_NDV_VALUE4     IN     NDI_DEC_VALUES.NDV_VALUE4%TYPE,
        p_NDV_VALUE5     IN     NDI_DEC_VALUES.NDV_VALUE5%TYPE,
        p_NDV_NNA        IN     NDI_DEC_VALUES.NDV_NNA%TYPE,
        p_new_id            OUT NDI_DEC_VALUES.NDV_ID%TYPE)
    IS
        l_hs   NUMBER := tools.gethistsession;
    BEGIN
        tools.check_user_and_raise (7);

        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   t.ndv_id,
                   t.ndv_start_dt,
                   t.ndv_stop_dt
              FROM ndi_dec_values t
             WHERE t.history_status = 'A' AND t.ndv_nds = p_NDV_NDS;

        -- формування історії
        api$hist.setup_history (0, p_NDV_START_DT, p_NDV_STOP_DT);

        -- закриття недіючих
        UPDATE ndi_dec_values t
           SET t.ndv_hs_del = l_hs, t.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = t.ndv_id);

        -- додавання нових періодів
        INSERT INTO ndi_dec_values (ndv_id,
                                    ndv_nds,
                                    ndv_hs_ins,
                                    ndv_start_dt,
                                    ndv_stop_dt,
                                    ndv_value1,
                                    ndv_value2,
                                    ndv_value3,
                                    ndv_value4,
                                    ndv_value5,
                                    history_status,
                                    ndv_nna)
            SELECT 0,
                   p_NDV_NDS,
                   l_hs,
                   rz.rz_begin,
                   rz.rz_end,
                   t.ndv_value1,
                   t.ndv_value2,
                   t.ndv_value3,
                   t.ndv_value4,
                   t.ndv_value5,
                   'A',
                   t.ndv_nna
              FROM tmp_unh_rz_list rz, ndi_dec_values t
             WHERE     rz.rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND t.ndv_id = rz_hst
            UNION
            SELECT 0,
                   p_NDV_NDS,
                   l_hs,
                   p_NDV_START_DT,
                   p_NDV_STOP_DT,
                   p_NDV_VALUE1,
                   p_NDV_VALUE2,
                   p_NDV_VALUE3,
                   p_NDV_VALUE4,
                   p_NDV_VALUE5,
                   'A',
                   p_NDV_NNA
              FROM tmp_unh_rz_list rl
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);
    END;

    PROCEDURE delete_value (p_ndv_id IN NUMBER)
    IS
        l_hs   NUMBER := tools.gethistsession;
    BEGIN
        UPDATE ndi_dec_values t
           SET t.history_status = 'H', t.ndv_hs_del = l_hs
         WHERE t.ndv_id = p_ndv_id;
    END;
BEGIN
    NULL;
END DNET$DIC_DEC_VALUES;
/