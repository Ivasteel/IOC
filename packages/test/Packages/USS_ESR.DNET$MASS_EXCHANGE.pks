/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MASS_EXCHANGE
IS
    -- Author  : BOGDAN
    -- Created : 12.07.2023 12:47:54
    -- Purpose : Верифікація Мінфін


    FUNCTION get_dynamic_value (p_col_name      IN VARCHAR2,
                                p_col_data_tp   IN VARCHAR2,
                                p_col_scale     IN NUMBER,
                                p_memr_id       IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_dynamic_value_un (p_col_name      IN VARCHAR2,
                                   p_col_data_tp   IN VARCHAR2,
                                   p_col_scale     IN NUMBER,
                                   p_mvrr_id       IN NUMBER)
        RETURN VARCHAR2;

    -- #89638: Сформувати пакет
    PROCEDURE START_MAKE_PACKET (p_me_tp      IN     VARCHAR2,
                                 p_me_month   IN     DATE,
                                 p_me_id         OUT NUMBER,
                                 p_me_jb         OUT NUMBER);

    --Отримання списку місяців, доступних для формування користувачу
    PROCEDURE get_month_list (p_months_list OUT SYS_REFCURSOR);


    -- #89638: Список попередніх сформованих пакетів
    PROCEDURE get_prev_packets (p_me_id      IN     NUMBER,
                                p_me_tp      IN     VARCHAR2,
                                p_me_month   IN     DATE,
                                p_start_dt   IN     DATE,
                                p_stop_dt    IN     DATE,
                                p_me_st      IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);


    -- #89638: Лог формування пакету
    PROCEDURE get_mass_exchange_log (p_me_id   IN     NUMBER,
                                     res_cur      OUT SYS_REFCURSOR);

    -- #89640: Картка пакету
    PROCEDURE get_packet_card (p_me_id             IN     NUMBER,
                               p_pc_num            IN     VARCHAR2,
                               p_memr_n_id         IN     VARCHAR2,
                               p_memr_surname      IN     VARCHAR2,
                               p_memr_name         IN     VARCHAR2,
                               p_memr_patronymic   IN     VARCHAR2,
                               p_memr_st           IN     VARCHAR2,
                               p_org_id            IN     NUMBER,
                               p_merc_type_rec     IN     NUMBER,
                               p_memr_id_fam       IN     VARCHAR2,
                               res_cur                OUT SYS_REFCURSOR);

    -- #98173: Картка пакету "ВПП ООН"
    PROCEDURE get_packet_card_un (p_me_id             IN     NUMBER,
                                  p_pc_num            IN     VARCHAR2,
                                  p_mvrr_n_id         IN     VARCHAR2,
                                  p_mvrr_surname      IN     VARCHAR2,
                                  p_mvrr_name         IN     VARCHAR2,
                                  p_mvrr_patronymic   IN     VARCHAR2,
                                  p_mvrr_st           IN     VARCHAR2,
                                  p_org_id            IN     NUMBER,
                                  p_mvrr_id_fam       IN     VARCHAR2,
                                  res_cur                OUT SYS_REFCURSOR);

    -- #98173: Картка результату "ВПП ООН"
    PROCEDURE get_packet_result_un (p_mvrr_id   IN     NUMBER,
                                    insp_cur       OUT SYS_REFCURSOR,
                                    res_cur        OUT SYS_REFCURSOR);

    -- #89676: Вкладка ЕОС "Верифікація в Мінфіні"
    PROCEDURE get_packet_card_pc (p_pc_id    IN     NUMBER,
                                  p_is_all   IN     VARCHAR2,
                                  res_cur       OUT SYS_REFCURSOR);

    -- #89640: Кнопка "Сформувати файл"
    PROCEDURE generate_file (p_me_id IN NUMBER, p_jb_id OUT NUMBER);

    -- #89640: Кнопка "Скасувати"
    PROCEDURE reject_packet (p_me_id IN NUMBER);


    -- #89673: Форма "Дані верифікації з Мінфіном"
    PROCEDURE get_row_card (p_memr_id   IN     NUMBER,
                            insp_cur       OUT SYS_REFCURSOR,
                            row_cur        OUT SYS_REFCURSOR);

    -- #89673: Форма "Картка рекомендації та рішення"
    PROCEDURE get_recomendation_card (p_merc_id   IN     NUMBER,
                                      rec_cur        OUT SYS_REFCURSOR,
                                      res_cur        OUT SYS_REFCURSOR);

    -- #89673: збереження результату верифікації
    PROCEDURE save_result_data (
        p_MESR_ID            IN OUT ME_MINFIN_RESULT_ROWS.MESR_ID%TYPE,
        p_MESR_ME            IN     ME_MINFIN_RESULT_ROWS.MESR_ME%TYPE,
        p_MESR_MEMR          IN     ME_MINFIN_RESULT_ROWS.MESR_MEMR%TYPE,
        p_MESR_MERC          IN     ME_MINFIN_RESULT_ROWS.MESR_MERC%TYPE,
        --p_MESR_EF in ME_MINFIN_RESULT_ROWS.MESR_EF%type,
        --p_MESR_ID_REC in ME_MINFIN_RESULT_ROWS.MESR_ID_REC%type,
        --p_MESR_ID_FAM in ME_MINFIN_RESULT_ROWS.MESR_ID_FAM%type,
        --p_MESR_RIS_CODE in ME_MINFIN_RESULT_ROWS.MESR_RIS_CODE%type,
        --p_MESR_KLCOM_CODDEC in ME_MINFIN_RESULT_ROWS.MESR_KLCOM_CODDEC%type,
        p_MESR_RES_DATE      IN     ME_MINFIN_RESULT_ROWS.MESR_RES_DATE%TYPE,
        p_MESR_SUMM_P        IN     ME_MINFIN_RESULT_ROWS.MESR_SUMM_P%TYPE,
        p_MESR_RES_START     IN     ME_MINFIN_RESULT_ROWS.MESR_RES_START%TYPE,
        p_MESR_RES_END       IN     ME_MINFIN_RESULT_ROWS.MESR_RES_END%TYPE,
        p_MESR_CONTENT_REC   IN     ME_MINFIN_RESULT_ROWS.MESR_CONTENT_REC%TYPE,
        p_MESR_TYPE_REC      IN     ME_MINFIN_RESULT_ROWS.MESR_TYPE_REC%TYPE,
        p_MESR_REC_CODE      IN     ME_MINFIN_RESULT_ROWS.MESR_REC_CODE%TYPE,
        p_MESR_REC_DATE      IN     ME_MINFIN_RESULT_ROWS.MESR_REC_DATE%TYPE,
        p_MESR_D14           IN     ME_MINFIN_RESULT_ROWS.MESR_D14%TYPE);

    -- #89673: видалення результату верифікації
    PROCEDURE delete_result_data (p_mesr_id IN NUMBER);

    -- #89673: підтвердження результату верифікації
    PROCEDURE approve_result_data (p_mesr_id IN NUMBER);

    -- 20/05/2024 serhii: не використовувати, стан змінюється в set_result_recommend_data
    -- #90966: відпрацювання невідповідності
    -- PROCEDURE set_worked_recommend_data (p_merc_id IN NUMBER);

    -- #90966: редагування невідповідності
    PROCEDURE set_edit_recommend_data (p_merc_id IN NUMBER);

    -- #93863: Рішення по рекомендації
    PROCEDURE set_result_recommend_data (p_memr_id       IN NUMBER,
                                         p_merc_Id_Rec   IN VARCHAR2,
                                         p_d14           IN NUMBER);

    -- #91120: рекомендації відпрацьовано
    PROCEDURE set_worked_packet_data (p_memr_id IN NUMBER);

    -- #93855: повернення Рішення на редагування
    PROCEDURE set_edit_result_data (p_mesr_id IN NUMBER);

    -- #109658
    PROCEDURE set_packet_st (p_me_id IN NUMBER, p_me_st IN VARCHAR2);
END DNET$MASS_EXCHANGE;
/


GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MASS_EXCHANGE
IS
    FUNCTION get_dynamic_value (p_col_name      IN VARCHAR2,
                                p_col_data_tp   IN VARCHAR2,
                                p_col_scale     IN NUMBER,
                                p_memr_id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN p_col_name = 'MEMR_ST'
                                THEN
                                    '(select dic_name from uss_ndi.v_ddn_memr_st z where z.dic_value = d.memr_st)'
                                WHEN p_col_name = 'MEMR_DOCTYPE'
                                THEN
                                    '(select ndt_name from uss_ndi.v_ndi_document_type z where z.ndt_id = d.MEMR_DOCTYPE)'
                                WHEN p_col_name = 'MEMR_CITIZENSHIP'
                                THEN
                                    '(select dic_name from uss_ndi.v_ddn_nationality z where z.dic_value = d.MEMR_CITIZENSHIP)'
                                WHEN p_col_name = 'MEMR_GENDER'
                                THEN
                                    '(CASE MEMR_GENDER WHEN ''1'' THEN ''Чоловіча'' WHEN ''2'' THEN ''Жіноча'' END)'
                                WHEN     p_col_data_tp = 'NUMBER'
                                     AND p_col_scale IS NOT NULL
                                     AND p_col_scale > 0
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_col_data_tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''DD.MM.YYYY'')'
                                ELSE
                                    p_col_name
                            END
                         || '
                         FROM me_minfin_request_rows d
                        WHERE d.memr_id = :id'
            INTO l_res
            USING p_memr_id;

        RETURN l_res;
    END;

    FUNCTION get_dynamic_value_un (p_col_name      IN VARCHAR2,
                                   p_col_data_tp   IN VARCHAR2,
                                   p_col_scale     IN NUMBER,
                                   p_mvrr_id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN p_col_name = 'MVRR_ST'
                                THEN
                                    '(select dic_name from uss_ndi.v_ddn_mvrr_st z where z.dic_value = d.mvrr_st)'
                                WHEN p_col_name = 'MVRR_GENDER'
                                THEN
                                    '(CASE MVRR_GENDER WHEN ''1'' THEN ''Чоловіча'' WHEN ''2'' THEN ''Жіноча'' END)'
                                WHEN     p_col_data_tp = 'NUMBER'
                                     AND p_col_scale IS NOT NULL
                                     AND p_col_scale > 0
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_col_data_tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''DD.MM.YYYY'')'
                                ELSE
                                    p_col_name
                            END
                         || '
                         FROM me_vppun_request_rows d
                        WHERE d.mvrr_id = :id'
            INTO l_res
            USING p_mvrr_id;

        RETURN l_res;
    END;

    -- #89638: Сформувати пакет
    PROCEDURE START_MAKE_PACKET (p_me_tp      IN     VARCHAR2,
                                 p_me_month   IN     DATE,
                                 p_me_id         OUT NUMBER,
                                 p_me_jb         OUT NUMBER)
    IS
    BEGIN
        Api$mass_Exchange.Make_Me_Packet (p_Me_Tp,
                                          p_Me_Month,
                                          p_Me_Id,
                                          p_Me_Jb);
    END;


    -- #89638: Отримання списку місяців, доступних для формування користувачу
    PROCEDURE get_month_list (p_months_list OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_months_list FOR
              SELECT x_month,
                     TO_CHAR (x_month,
                              'Month YYYY',
                              'NLS_DATE_LANGUAGE=UKRAINIAN')    AS x_month_name
                FROM (SELECT TRUNC (SYSDATE, 'MM') AS x_month FROM DUAL)
            ORDER BY 1 DESC;
    END;

    -- #89638: Список попередніх операцій формування пакету
    PROCEDURE get_prev_packets (p_me_id      IN     NUMBER,
                                p_me_tp      IN     VARCHAR2,
                                p_me_month   IN     DATE,
                                p_start_dt   IN     DATE,
                                p_stop_dt    IN     DATE,
                                p_me_st      IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.*,
                     tp.DIC_NAME                      AS me_tp_name,
                     st.DIC_NAME                      AS me_st_name,
                     hsi.hs_dt                        AS me_ins_dt,
                     tools.GetUserPib (hsi.hs_wu)     AS me_ins_pib,
                     hsf.hs_dt                        AS me_fix_dt,
                     tools.GetUserPib (hsf.hs_wu)     AS me_fix_pib
                FROM v_mass_exchanges t
                     JOIN uss_ndi.v_ddn_me_tp tp ON (tp.DIC_VALUE = t.me_tp)
                     JOIN uss_ndi.v_ddn_me_st st ON (st.DIC_VALUE = t.me_st)
                     JOIN histsession hsi ON (hsi.hs_id = t.me_hs_ins)
                     LEFT JOIN histsession hsf ON (hsf.hs_id = t.me_hs_fix)
               WHERE     1 = 1
                     AND (p_me_id IS NULL OR t.me_id = p_me_id)
                     AND (p_me_tp IS NULL OR t.me_tp = p_me_tp)
                     AND (p_me_st IS NULL OR t.me_st = p_me_st)
                     AND (p_me_month IS NULL OR t.me_month = p_me_month)
                     AND (p_start_dt IS NULL OR t.me_dt >= p_start_dt)
                     AND (p_stop_dt IS NULL OR t.me_dt <= p_stop_dt)
            ORDER BY t.me_month DESC;
    END;

    -- #89638: Лог формування пакету
    PROCEDURE get_mass_exchange_log (p_me_id   IN     NUMBER,
                                     res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.mel_id                                                   AS log_id,
                     t.mel_me                                                   AS log_obj,
                     t.mel_tp                                                   AS log_tp,
                     st.dic_name                                                AS log_st_name,
                     sto.dic_name                                               AS log_st_old_name,
                     hs_dt                                                      AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                 AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (t.mel_message)    AS log_message
                FROM me_log t
                     LEFT JOIN uss_ndi.v_ddn_me_st st
                         ON (st.dic_value = t.mel_st)
                     LEFT JOIN uss_ndi.v_ddn_me_st sto
                         ON (sto.dic_value = t.mel_st_old)
                     LEFT JOIN v_histsession ON (hs_id = t.mel_hs)
               WHERE t.mel_me = p_me_id
            ORDER BY hs_dt ASC, mel_id ASC;
    END;


    -- #89640: Картка пакету
    PROCEDURE get_packet_card (p_me_id             IN     NUMBER,
                               p_pc_num            IN     VARCHAR2,
                               p_memr_n_id         IN     VARCHAR2,
                               p_memr_surname      IN     VARCHAR2,
                               p_memr_name         IN     VARCHAR2,
                               p_memr_patronymic   IN     VARCHAR2,
                               p_memr_st           IN     VARCHAR2,
                               p_org_id            IN     NUMBER,
                               p_merc_type_rec     IN     NUMBER,
                               p_memr_id_fam       IN     VARCHAR2,
                               res_cur                OUT SYS_REFCURSOR)
    IS
        l_org_to          NUMBER := tools.getcurrorgto;
        l_org             NUMBER := tools.getcurrorg;
        l_merc_type_rec   NUMBER;
    BEGIN
        SELECT MAX (t.d15_type_rec)
          INTO l_merc_type_rec
          FROM uss_ndi.v_ndi_minfin_d15 t
         WHERE t.d15_id = p_merc_type_rec;

        OPEN res_cur FOR
            SELECT /*+ FIRST_ROWS (100) */
                   t.memr_id,
                   t.memr_pc,
                   t.memr_n_id,
                   t.memr_surname,
                   t.memr_name,
                   t.memr_patronymic,
                   t.memr_id_fam,
                   t.memr_kfn,
                   t.memr_p_summd,
                   t.memr_n_summd,
                   t.memr_v_summd,
                   t.memr_st,
                   pc.pc_num,
                   st.DIC_NAME                                      AS memr_st_name,
                   uss_person.api$sc_tools.get_vpo_num (
                       pc.pc_sc)                                    AS vpo_num,
                   (SELECT LISTAGG (merc_type_rec, ', ')
                               WITHIN GROUP (ORDER BY 1)
                      FROM (SELECT DISTINCT r.merc_type_rec
                              FROM me_minfin_recomm_rows r
                             WHERE     r.merc_me = p_me_id
                                   AND r.merc_memr = t.memr_id))    AS merc_type_rec_list
              FROM v_me_minfin_request_rows  t
                   JOIN uss_ndi.v_ddn_memr_st st
                       ON (st.DIC_VALUE = t.memr_st)
                   JOIN v_personalcase pc ON (pc.pc_id = t.memr_pc)
             WHERE     memr_me = p_me_id
                   AND memr_st != 'U'             -- 16/07/2024 serhii #105323
                   AND (p_pc_num IS NULL OR pc.pc_num = p_pc_num)
                   AND (p_memr_n_id IS NULL OR t.memr_n_id = p_memr_n_id)
                   AND (p_memr_st IS NULL OR t.memr_st = p_memr_st)
                   AND (   p_memr_surname IS NULL
                        OR UPPER (t.memr_surname) LIKE
                               UPPER (p_memr_surname) || '%')
                   AND (   p_memr_name IS NULL
                        OR UPPER (t.memr_name) LIKE
                               UPPER (p_memr_name) || '%')
                   AND (   p_memr_patronymic IS NULL
                        OR UPPER (t.memr_patronymic) LIKE
                               UPPER (p_memr_patronymic) || '%')
                   AND (       l_org_to IN (30, 40, 20)
                           AND (   p_org_id IS NULL
                                OR p_org_id = 0
                                OR pc.com_org = p_org_id)
                        OR     l_org_to IN (31)
                           AND (   p_org_id IS NULL
                                OR     p_org_id = 0
                                   AND pc.com_org IN (SELECT * FROM tmp_org)
                                OR pc.com_org = p_org_id)
                        -- OR l_org_to != 32
                        -- OR l_org_to = 32 AND pc.com_org = l_org
                        OR     l_org_to IN (21)
                           AND pc.com_org IN
                                   (SELECT org_id
                                      FROM opfu, uss_ndi.v_ndi_nsss2dszn
                                     WHERE     org_st = 'A'
                                           AND org_to = 32
                                           AND org_org = n2d_org_dszn
                                           AND n2d_org_nsss = l_org)
                        OR     l_org_to NOT IN (30,
                                                40,
                                                31,
                                                20)
                           AND (pc.com_org = l_org))
                   AND (   p_merc_type_rec IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM me_minfin_recomm_rows z
                                 WHERE     z.merc_memr = t.memr_id
                                       AND z.merc_type_rec = l_merc_type_rec))
                   AND ROWNUM <= 502--ORDER BY memr_Id_Fam

                                    ;
    END;

    -- #98173: Картка пакету "ВПП ООН"
    PROCEDURE get_packet_card_un (p_me_id             IN     NUMBER,
                                  p_pc_num            IN     VARCHAR2,
                                  p_mvrr_n_id         IN     VARCHAR2,
                                  p_mvrr_surname      IN     VARCHAR2,
                                  p_mvrr_name         IN     VARCHAR2,
                                  p_mvrr_patronymic   IN     VARCHAR2,
                                  p_mvrr_st           IN     VARCHAR2,
                                  p_org_id            IN     NUMBER,
                                  p_mvrr_id_fam       IN     VARCHAR2,
                                  res_cur                OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.getcurrorgto;
        l_org      NUMBER := tools.getcurrorg;
    BEGIN
        OPEN res_cur FOR
            SELECT /*+ FIRST_ROWS (100) */
                   t.*, pc.pc_num, st.DIC_NAME AS mvrr_st_name
              --uss_person.api$sc_tools.get_vpo_num(pc.pc_sc) AS vpo_num
              FROM v_me_vppun_request_rows  t
                   JOIN uss_ndi.V_DDN_MVRR_ST st
                       ON (st.DIC_VALUE = t.mvrr_st)
                   JOIN v_personalcase pc ON (pc.pc_id = t.mvrr_pc)
             WHERE     mvrr_me = p_me_id
                   AND (p_pc_num IS NULL OR pc.pc_num = p_pc_num)
                   AND (p_mvrr_n_id IS NULL OR t.mvrr_n_id = p_mvrr_n_id)
                   AND (p_mvrr_st IS NULL OR t.mvrr_st = p_mvrr_st)
                   AND (   p_mvrr_surname IS NULL
                        OR UPPER (t.mvrr_surname) LIKE
                               UPPER (p_mvrr_surname) || '%')
                   AND (   p_mvrr_name IS NULL
                        OR UPPER (t.mvrr_name) LIKE
                               UPPER (p_mvrr_name) || '%')
                   AND (   p_mvrr_patronymic IS NULL
                        OR UPPER (t.mvrr_patronymic) LIKE
                               UPPER (p_mvrr_patronymic) || '%')
                   AND (       l_org_to IN (30, 40, 20)
                           AND (   p_org_id IS NULL
                                OR p_org_id = 0
                                OR pc.com_org = p_org_id)
                        OR     l_org_to IN (31)
                           AND (   p_org_id IS NULL
                                OR     p_org_id = 0
                                   AND pc.com_org IN (SELECT * FROM tmp_org)
                                OR pc.com_org = p_org_id)
                        OR     l_org_to IN (21)
                           AND pc.com_org IN
                                   (SELECT org_id
                                      FROM opfu, uss_ndi.v_ndi_nsss2dszn
                                     WHERE     org_st = 'A'
                                           AND org_to = 32
                                           AND org_org = n2d_org_dszn
                                           AND n2d_org_nsss = l_org)
                        OR     l_org_to NOT IN (30,
                                                40,
                                                31,
                                                20)
                           AND (pc.com_org = l_org))
                   AND ROWNUM <= 502;
    END;

    -- #98173: Картка результату "ВПП ООН"
    PROCEDURE get_packet_result_un (p_mvrr_id   IN     NUMBER,
                                    insp_cur       OUT SYS_REFCURSOR,
                                    res_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Insp_Cur FOR
              SELECT t.Comments                          AS NAME,
                     get_dynamic_value_un (t.Column_Name,
                                           Ct.Data_Type,
                                           Ct.Data_Scale,
                                           p_mvrr_id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE     t.Table_Name = UPPER ('me_vppun_request_rows')
                     AND NOT EXISTS
                             (SELECT *
                                FROM All_Cons_Columns z
                               WHERE     z.Table_Name = t.Table_Name
                                     AND z.Column_Name = t.Column_Name)
            ORDER BY Ct.Column_Id;

        OPEN res_cur FOR
            SELECT t.*, pc.pc_num, st.DIC_NAME AS mvsr_st_name
              FROM v_me_vppun_result_rows  t
                   LEFT JOIN uss_ndi.V_DDN_MVRR_ST st
                       ON (st.DIC_VALUE = t.mvsr_st)
                   JOIN v_personalcase pc ON (pc.pc_id = t.mvsr_pc)
             WHERE mvsr_mvrr = p_mvrr_id;
    END;

    -- #89676: Вкладка ЕОС "Верифікація в Мінфіні"
    PROCEDURE get_packet_card_pc (p_pc_id    IN     NUMBER,
                                  p_is_all   IN     VARCHAR2,
                                  res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.memr_id,
                     t.memr_pc,
                     t.memr_n_id,
                     t.memr_surname,
                     t.memr_name,
                     t.memr_patronymic,
                     t.memr_id_fam,
                     t.memr_kfn,
                     t.memr_p_summd,
                     t.memr_n_summd,
                     t.memr_v_summd,
                     t.memr_st,
                     st.DIC_NAME     AS memr_st_name,
                     e.me_month
                FROM v_me_minfin_request_rows t
                     JOIN mass_exchanges e ON (e.me_id = t.memr_me)
                     JOIN uss_ndi.v_ddn_memr_st st
                         ON (st.DIC_VALUE = t.memr_st)
               WHERE     memr_pc = p_pc_id
                     AND (p_is_all = 'F' AND t.memr_st != 'P' OR p_is_all = 'T')
            ORDER BY me_month DESC;
    END;

    -- #89640: Кнопка "Сформувати файл"
    PROCEDURE generate_file (p_me_id IN NUMBER, p_jb_id OUT NUMBER)
    IS
    BEGIN
        API$MASS_EXCHANGE.make_exchange_file (p_me_id, p_jb_id);
    END;

    -- #89640: Кнопка "Скасувати"
    PROCEDURE reject_packet (p_me_id IN NUMBER)
    IS
    BEGIN
        API$MASS_EXCHANGE.reject_packet (p_me_id);
    END;

    -- #89673: Форма "Дані верифікації з Мінфіном"
    PROCEDURE get_row_card (p_memr_id   IN     NUMBER,
                            insp_cur       OUT SYS_REFCURSOR,
                            row_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN insp_cur FOR
              SELECT t.comments                       AS NAME,
                     get_dynamic_value (t.column_name,
                                        ct.data_type,
                                        ct.data_scale,
                                        p_memr_id)    AS VALUE
                FROM all_col_comments t
                     JOIN all_tab_columns ct
                         ON (    ct.table_name = t.table_name
                             AND ct.column_name = t.column_name)
               WHERE     t.table_name = UPPER ('me_minfin_request_rows')
                     AND NOT EXISTS
                             (SELECT *
                                FROM all_cons_columns z
                               WHERE     z.table_name = t.table_name
                                     AND z.column_name = t.column_name)
            ORDER BY ct.column_id;

        OPEN row_cur FOR
            SELECT t.*,
                   st.DIC_NAME                         AS merc_st_name,
                   d.d15_type_rec              /*|| ' ' || d.d15_content_min*/
                                                       AS merc_type_rec_name,
                   d2.d16_name_org                     AS merc_org_name,
                   q.memr_st,
                   (SELECT MAX (s.mesr_rec_code)
                      FROM me_minfin_result_rows s
                     WHERE s.mesr_merc = t.merc_id)    AS mesr_rec_code,
                   (SELECT MAX (s.mesr_rec_date)
                      FROM me_minfin_result_rows s
                     WHERE s.mesr_merc = t.merc_id)    AS mesr_rec_date,
                   (SELECT MAX (s.mesr_ris_code)
                      FROM me_minfin_result_rows s
                     WHERE s.mesr_merc = t.merc_id)    AS mesr_ris_code
              FROM me_minfin_recomm_rows  t
                   JOIN me_minfin_request_rows q ON (q.memr_id = t.merc_memr)
                   JOIN uss_ndi.v_ddn_merc_st st
                       ON (st.DIC_VALUE = t.merc_st)
                   LEFT JOIN uss_ndi.v_ndi_minfin_d15 d
                       ON (d.d15_type_rec = t.merc_type_rec)
                   LEFT JOIN uss_ndi.v_ndi_minfin_d16 d2
                       ON (d2.d16_org = t.merc_org)
             WHERE t.merc_memr = p_memr_id;
    END;

    -- #89673: Форма "Картка рекомендації та рішення"
    PROCEDURE get_recomendation_card (p_merc_id   IN     NUMBER,
                                      rec_cur        OUT SYS_REFCURSOR,
                                      res_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN rec_cur FOR
            SELECT t.*,
                   st.DIC_NAME
                       AS merc_st_name,
                   d.d15_type_rec || ' ' || d.d15_content_max
                       AS merc_type_rec_name,
                   d.d15_type_rec
                       AS merc_type_rec_code,
                   d2.d16_org || ' ' || d2.d16_name_org
                       AS merc_org_name
              FROM me_minfin_recomm_rows  t
                   JOIN uss_ndi.v_ddn_merc_st st
                       ON (st.DIC_VALUE = t.merc_st)
                   LEFT JOIN uss_ndi.v_ndi_minfin_d15 d
                       ON (d.d15_type_rec = t.merc_type_rec)
                   LEFT JOIN uss_ndi.v_ndi_minfin_d16 d2
                       ON (d2.d16_org = t.merc_org)
             WHERE t.merc_id = p_merc_id;

        OPEN res_cur FOR
            SELECT t.*, st.DIC_NAME AS mesr_st_name
              FROM me_minfin_result_rows  t
                   JOIN uss_ndi.v_ddn_mesr_st st
                       ON (st.DIC_VALUE = t.mesr_st)
             WHERE t.mesr_merc = p_merc_id;
    END;

    -- #89673: збереження результату верифікації
    PROCEDURE save_result_data (
        p_MESR_ID            IN OUT ME_MINFIN_RESULT_ROWS.MESR_ID%TYPE,
        p_MESR_ME            IN     ME_MINFIN_RESULT_ROWS.MESR_ME%TYPE,
        p_MESR_MEMR          IN     ME_MINFIN_RESULT_ROWS.MESR_MEMR%TYPE,
        p_MESR_MERC          IN     ME_MINFIN_RESULT_ROWS.MESR_MERC%TYPE,
        --p_MESR_EF in ME_MINFIN_RESULT_ROWS.MESR_EF%type,
        --p_MESR_ID_REC in ME_MINFIN_RESULT_ROWS.MESR_ID_REC%type,
        --p_MESR_ID_FAM in ME_MINFIN_RESULT_ROWS.MESR_ID_FAM%type,
        --p_MESR_RIS_CODE in ME_MINFIN_RESULT_ROWS.MESR_RIS_CODE%type,
        --p_MESR_KLCOM_CODDEC in ME_MINFIN_RESULT_ROWS.MESR_KLCOM_CODDEC%type,
        p_MESR_RES_DATE      IN     ME_MINFIN_RESULT_ROWS.MESR_RES_DATE%TYPE,
        p_MESR_SUMM_P        IN     ME_MINFIN_RESULT_ROWS.MESR_SUMM_P%TYPE,
        p_MESR_RES_START     IN     ME_MINFIN_RESULT_ROWS.MESR_RES_START%TYPE,
        p_MESR_RES_END       IN     ME_MINFIN_RESULT_ROWS.MESR_RES_END%TYPE,
        p_MESR_CONTENT_REC   IN     ME_MINFIN_RESULT_ROWS.MESR_CONTENT_REC%TYPE,
        p_MESR_TYPE_REC      IN     ME_MINFIN_RESULT_ROWS.MESR_TYPE_REC%TYPE,
        p_MESR_REC_CODE      IN     ME_MINFIN_RESULT_ROWS.MESR_REC_CODE%TYPE,
        p_MESR_REC_DATE      IN     ME_MINFIN_RESULT_ROWS.MESR_REC_DATE%TYPE,
        p_MESR_D14           IN     ME_MINFIN_RESULT_ROWS.MESR_D14%TYPE)
    IS
        l_d14_c1   NUMBER (3);
        l_d14_c2   NUMBER (3);
        l_row      me_minfin_recomm_rows%ROWTYPE;
        l_cnt      PLS_INTEGER;
        l_hs       histsession.hs_id%TYPE := TOOLS.GetHistSession;
    BEGIN
        IF (p_MESR_RES_END < p_MESR_RES_START)
        THEN
            raise_application_error (
                -20000,
                'Дата закінчення періоду повинна бути не менша за початкову!');
        END IF;

        -- 18/05/2024 serhii: #102796-3
        SELECT COUNT (*)
          INTO l_cnt
          FROM me_minfin_result_rows t
         WHERE t.mesr_merc = p_MESR_MERC AND t.mesr_id != NVL (p_MESR_ID, -1);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Не можна створювати більше одного рішення на кожну невідповідність! Оновіть картку та видаліть зайві рішення.');
        --NULL;
        END IF;

        SELECT MAX (TO_NUMBER (t.d14_ris_code)),
               MAX (TO_NUMBER (t.d14_klcom_coddec))
          INTO l_d14_c1, l_d14_c2
          FROM uss_ndi.v_ndi_minfin_d14 t
         WHERE t.d14_id = p_MESR_D14;

        SELECT *
          INTO l_row
          FROM me_minfin_recomm_rows t
         WHERE t.merc_id = p_MESR_MERC;

        IF p_MESR_ID IS NULL
        THEN
            INSERT INTO ME_MINFIN_RESULT_ROWS (MESR_ME,
                                               MESR_MEMR,
                                               MESR_MERC,
                                               MESR_ID_REC,
                                               MESR_ID_FAM,
                                               MESR_RIS_CODE,
                                               MESR_KLCOM_CODDEC,
                                               MESR_RES_DATE,
                                               MESR_SUMM_P,
                                               MESR_RES_START,
                                               MESR_RES_END,
                                               MESR_CONTENT_REC,
                                               MESR_TYPE_REC,
                                               MESR_REC_CODE,
                                               MESR_REC_DATE,
                                               MESR_ST,
                                               MESR_D14,
                                               MESR_HS_INS)
                 VALUES (p_MESR_ME,
                         p_MESR_MEMR,
                         p_MESR_MERC,
                         l_row.merc_id_rec,
                         l_row.merc_id_fam,
                         l_d14_c1,
                         l_d14_c2,
                         p_MESR_RES_DATE,
                         p_MESR_SUMM_P,
                         p_MESR_RES_START,
                         p_MESR_RES_END,
                         p_MESR_CONTENT_REC,
                         p_MESR_TYPE_REC,
                         p_MESR_REC_CODE,
                         p_MESR_REC_DATE,
                         'E',
                         p_MESR_D14,
                         l_hs)
              RETURNING MESR_ID
                   INTO p_MESR_ID;
        ELSE
            UPDATE ME_MINFIN_RESULT_ROWS
               SET MESR_RIS_CODE = l_d14_c1,
                   MESR_KLCOM_CODDEC = l_d14_c2,
                   MESR_RES_DATE = p_MESR_RES_DATE,
                   MESR_SUMM_P = p_MESR_SUMM_P,
                   MESR_RES_START = p_MESR_RES_START,
                   MESR_RES_END = p_MESR_RES_END,
                   MESR_CONTENT_REC = p_MESR_CONTENT_REC,
                   MESR_TYPE_REC = p_MESR_TYPE_REC,
                   MESR_REC_CODE = p_MESR_REC_CODE,
                   MESR_REC_DATE = p_MESR_REC_DATE,
                   MESR_D14 = p_MESR_D14
             WHERE MESR_ID = p_MESR_ID;
        END IF;
    END;

    -- #89673: видалення результату верифікації
    PROCEDURE delete_result_data (p_mesr_id IN NUMBER)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT t.mesr_st
          INTO l_st
          FROM me_minfin_result_rows t
         WHERE t.mesr_id = p_mesr_id;

        IF (l_st IS NULL OR l_st != 'E')
        THEN
            raise_application_error (
                -20000,
                'Статус не позволяє видаляти результат верифікації!');
        END IF;

        DELETE FROM me_minfin_result_rows t
              WHERE t.mesr_id = p_mesr_id;
    END;

    -- #89673: підтвердження результату верифікації (Підтвердження рішення)
    PROCEDURE approve_result_data (p_mesr_id IN NUMBER)
    IS
        l_row         me_minfin_result_rows%ROWTYPE;
        l_err_msg     VARCHAR2 (1000) := '';
        l_merc_date   me_minfin_recomm_rows.merc_date_err%TYPE;
    BEGIN
        SELECT *
          INTO l_row
          FROM me_minfin_result_rows t
         WHERE t.mesr_id = p_mesr_id;

        -- serhii: #93665-4 додав контролі для обов'язкових полів
        IF l_row.mesr_res_date IS NULL
        THEN
            l_err_msg :=
                l_err_msg || '"Дата опрацювання невідповідності"' || CHR (10);
        END IF;

        IF (l_row.mesr_klcom_coddec IS NULL OR l_row.mesr_ris_code IS NULL)
        THEN
            l_err_msg := l_err_msg || '"Прийняте рішення"' || CHR (10);
        END IF;

        IF NOT l_err_msg IS NULL
        THEN
            l_err_msg :=
                   'Необхідно заповнити обов''язкові поля:'
                || CHR (10)
                || l_err_msg;
            raise_application_error (-20000, l_err_msg);
        END IF;

        IF (l_row.mesr_st IS NULL OR l_row.mesr_st != 'E')
        THEN
            raise_application_error (
                -20000,
                   'Не можливо підтвердити рішення у даному статусі! '
                || TO_CHAR (l_row.mesr_st));
        END IF;

        IF (l_row.mesr_d14 IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Підтверджувати рішення не можливо через порожнє прийняте рішення!');
        END IF;

        -- #93855-2
        IF    (    (l_row.mesr_ris_code = 1 AND l_row.mesr_klcom_coddec = 4)
               AND NVL (l_row.mesr_summ_p, 0) = 0)
           OR (    (l_row.mesr_ris_code = 2 AND l_row.mesr_klcom_coddec = 10)
               AND NVL (l_row.mesr_summ_p, 0) = 0)
        --or ((l_row.mesr_ris_code = 4 and l_row.mesr_klcom_coddec = 13) and nvl(l_row.mesr_summ_p, 0) = 0) -- #99681
        THEN
            raise_application_error (
                -20000,
                'Поле "Сума перерахунку для повернення за результатом прийнятого рішення по рекомендації" обов''язкове для заповнення для обраного рішення!');
        -- #94669
        ELSIF    (    (    l_row.mesr_ris_code = 3
                       AND l_row.mesr_klcom_coddec = 12)
                  AND NVL (TRIM (l_row.mesr_content_rec), '[]') = '[]')
              OR (    (    l_row.mesr_ris_code = 4
                       AND l_row.mesr_klcom_coddec = 14)
                  AND NVL (TRIM (l_row.mesr_content_rec), '[]') = '[]')
        THEN
            raise_application_error (
                -20000,
                'Поле "Коментар до прийнятого рішення по невідповідності" обов''язкове для заповнення для обраного рішення!');
        END IF;

        -- #93855 Дата опрацювання невідповідності пізніше "Дата здійснення верифікації" але не пізніше поточної
        SELECT t.merc_date_err
          INTO l_merc_date
          FROM me_minfin_recomm_rows t
         WHERE t.merc_id = l_row.mesr_merc;

        IF l_row.mesr_res_date < l_merc_date
        THEN
            raise_application_error (
                -20000,
                '"Дата опрацювання невідповідності" не може бути раніше ніж "Дата здійснення верифікації"!');
        ELSIF l_row.mesr_res_date > SYSDATE
        THEN
            raise_application_error (
                -20000,
                '"Дата опрацювання невідповідності" не може бути пізніше за поточну дату!');
        END IF;

        -- #93855 "Код рішення" відповідає типу невідповідності 01/02
        IF     SUBSTR (l_row.mesr_id_rec, -2) = '01'
           AND NVL (l_row.mesr_ris_code, -1) NOT IN (1, 2, 3)
        THEN
            raise_application_error (
                -20000,
                'Для рекомендацій типу "01" (останні два символи "Ідентифікатора рекомендації") дозволено лише застосування рішеннь з кодами "1", "2" або "3"!');
        ELSIF     SUBSTR (l_row.mesr_id_rec, -2) = '02'
              AND NVL (l_row.mesr_ris_code, -1) NOT IN (4)
        THEN
            raise_application_error (
                -20000,
                'Для рекомендацій типу "02" (останні два символи "Ідентифікатора рекомендації") дозволено лише застосування рішеннь з кодом "4"!');
        END IF;

        UPDATE me_minfin_result_rows t
           SET t.mesr_st = 'P'
         WHERE t.mesr_id = p_mesr_id;
    END;

    /* 18/05/2024 serhii: цю процедуру не використовуємо, зміна статуса та необхідні контролі теперь в set_result_recommend_data
      -- #90966: відпрацювання невідповідності
      PROCEDURE set_worked_recommend_data (p_merc_id IN NUMBER)
      IS
       -- l_st VARCHAR2(10);
       -- l_cnt_all pls_integer;
       -- l_cnt_P   pls_integer;
      BEGIN
        NULL;
        SELECT t.merc_st
          INTO l_st
          FROM me_minfin_recomm_rows t
         WHERE t.merc_id = p_merc_id;

        IF (l_st IS NULL OR l_st != 'O') THEN
          raise_application_error(-20000, 'Статус не позволяє відпрацювати поточну невідповіднісь!');
        END IF;

        -- serhii: змінено по #92025-17
        SELECT SUM(cnt_all), SUM(cnt_P)
          INTO l_cnt_all, l_cnt_P
          FROM (SELECT COUNT(*) cnt_all,
                      SUM(CASE WHEN mesr_st = 'P' OR mesr_st = 'S' THEN 1 ELSE 0 END) cnt_P
                   FROM me_minfin_result_rows
                  WHERE mesr_merc = p_merc_id
                 UNION ALL
                 SELECT 0 cnt_all, 0 cnt_P FROM dual -- щоб не обробляти no_data_found
                ) t ;

        IF l_cnt_all = 0 THEN
          raise_application_error(-20000, 'Для відпрацювання невідповідності необхідно створити принаймні одне підтверджене рішення!');
        ELSIF l_cnt_all != l_cnt_P THEN
          raise_application_error(-20000, 'Для відпрацювання невідповідності всі пов''язані рішення необхідно підтвердити!');
        END IF;

        UPDATE me_minfin_recomm_rows t
          SET t.merc_st = 'V'
        WHERE t.merc_id = p_merc_id;

      END; */

    -- #90966: редагування невідповідності
    PROCEDURE set_edit_recommend_data (p_merc_id IN NUMBER)
    IS
        l_memr_st       me_minfin_request_rows.memr_st%TYPE;
        l_merc_st       me_minfin_recomm_rows.merc_st%TYPE;
        l_merc_id_rec   me_minfin_recomm_rows.merc_id_rec%TYPE;
        l_merc_memr     me_minfin_recomm_rows.merc_memr%TYPE;
    BEGIN
        SELECT NVL (r.merc_st, 'xxx'),
               NVL (q.memr_st, 'xxx'),
               r.merc_memr,
               r.merc_id_rec
          INTO l_merc_st,
               l_memr_st,
               l_merc_memr,
               l_merc_id_rec
          FROM me_minfin_recomm_rows  r
               JOIN me_minfin_request_rows q ON r.merc_memr = q.memr_id
         WHERE r.merc_id = p_merc_id;

        -- 7/11/2023 serhii: додав відповідно до #93855
        IF l_merc_st = 'O'
        THEN                                                    --вже доступна
            raise_application_error (
                -20000,
                'Відкрийте картку невідповідності для редагування.');
        ELSIF l_merc_st != 'V'
        THEN                               -- можна тільки для V-Відпрацьовано
            raise_application_error (
                -20000,
                'Поточний стан невідповідності не дозволяє редагування!');
        ELSIF l_memr_st != 'K'
        THEN                       -- можна тільки для K-Отримано рекомендації
            raise_application_error (
                -20000,
                'Поточний стан запису "Дані верифікації з Мінфіном" не дозволяє редагування!');
        END IF;

        UPDATE me_minfin_recomm_rows t
           SET t.merc_st = 'O'
         WHERE t.merc_id = p_merc_id;

        -- #93855 7/11/2023 serhii: Видаляє код і дату рішення по рекомендації
        UPDATE me_minfin_result_rows t
           SET t.mesr_rec_code = NULL, t.mesr_rec_date = NULL
         WHERE t.mesr_merc = p_merc_id;
    /* 20/05/2024 serhii: прибрав, бо не потрібно видаляти дату з рішень по іншим невідповідностям
     t.mesr_merc IN (SELECT z.merc_id
            FROM me_minfin_recomm_rows z
           WHERE z.merc_id_rec = l_merc_id_rec
             AND z.merc_memr = l_merc_memr
          )  */
    END;

    -- #93863-3: Рішення по рекомендації
    PROCEDURE set_result_recommend_data (p_memr_id       IN NUMBER,
                                         p_merc_Id_Rec   IN VARCHAR2,
                                         p_d14           IN NUMBER)
    IS
        l_st    VARCHAR2 (10);
        l_d14   VARCHAR2 (10);
        l_cnt   PLS_INTEGER;
    BEGIN
        SELECT t.d14_ris_code
          INTO l_d14
          FROM uss_ndi.v_ndi_minfin_d14 t
         WHERE t.d14_id = p_d14;

        /* serhii: стани мають бути: memr_st=K, merc_st=O, mesr_st=P */
        -- #93855 Стан батьківського рядка = K:Отримано рекомендації
        SELECT NVL (memr_st, 'xxx')
          INTO l_st
          FROM me_minfin_request_rows
         WHERE memr_id = p_memr_id;

        IF l_st != 'K'
        THEN
            raise_application_error (
                -20000,
                'Встановити "Рішення по рекомендації" можливо лише коли "Дані верифікації з Мінфіном" мають "Стан запису = Отримано рекомендації"!');
        END IF;

        -- 23/05/2024 serhii: записи що підлягаєть оновленню:
        -- невідповідності у стані O:Отримано або V:Відпрацьовано (невідправлені) відбрані за  merc_id_rec+merc_memr
        -- та їх рішення, такі що !=S (невідправлені)
        INSERT INTO tmp_work_set4 (x_id1,
                                   x_string1,
                                   x_id2,
                                   x_string2,
                                   x_id3,
                                   x_id4)
            SELECT merc_id,
                   merc_st,
                   mesr_id,
                   mesr_st,
                   mesr_ris_code,
                   merc_type_rec
              FROM me_minfin_recomm_rows
                   LEFT JOIN me_minfin_result_rows
                       ON mesr_merc = merc_id AND mesr_st != 'S'
             WHERE     merc_id_rec = p_merc_Id_Rec
                   AND merc_memr = p_memr_id
                   AND merc_st IN ('O', 'V');

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'За даною рекомендацією не знайдено не відправлених рішеннь!');
        END IF;

        -- #93855 Всі невідповідності повінні мати дочірні рішення
        -- у стані P:Підтверджено ; S:Надіслано - не враховуємо
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set4
         WHERE NVL (x_string2, 'xxx') != 'P';

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Є невідповідності які не мають підтверджених рішеннь!');
        END IF;

        -- #93855 Код рішення по рекомендації відповідає одному з рішень невідповідностей
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set4
         WHERE x_id3 = l_d14;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Обране рішення по рекомендації не співпадає з жодним з рішеннь по невідповіностям!');
        END IF;

        -- 23/05/2024 serhii: додаткова перевірка на дублюючі рішення
        SELECT NVL (MAX (x_id4), 0)
          INTO l_cnt
          FROM (SELECT x_id4,
                       ROW_NUMBER () OVER (PARTITION BY x_id1 ORDER BY 1)    cnt
                  FROM tmp_work_set4)
         WHERE cnt = 2;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'За невідповідністю з кодом '
                || TO_CHAR (l_cnt)
                || ' створено більше одного рішення! Видаліть зайві рішення перед підтвердженням.');
        END IF;

        -- Заповнюємо в рішеннях код та дату загального рішення за рекомендацією
        UPDATE me_minfin_result_rows t
           SET t.mesr_rec_code = l_d14, t.mesr_rec_date = TRUNC (SYSDATE)
         WHERE t.mesr_id IN (SELECT x_id2 FROM tmp_work_set4);

        -- стан невідповідностей за рекомендацією 'V' Відпрацьовано
        UPDATE me_minfin_recomm_rows
           SET merc_st = 'V'
         WHERE merc_id IN (SELECT x_id1 FROM tmp_work_set4);
    END;


    -- #91120: рекомендації відпрацьовано
    PROCEDURE set_worked_packet_data (p_memr_id IN NUMBER)
    IS
        l_cnt   NUMBER;
    BEGIN
        /* 24/05/2024 serhii: деякі контролі виконуються раніше
          , але якщо якісь сценарії дозволять з'явитись некоректним даним, перевіряємо: #102796-12 */

        -- Рядок пакета у стані К "Отримано рекомендації"
        -- #91859
        SELECT COUNT (*)
          INTO l_cnt
          FROM me_minfin_request_rows t
         WHERE t.memr_id = p_memr_id AND t.memr_st = 'K';

        IF (l_cnt = 0)
        THEN
            raise_application_error (
                -20000,
                'Застосувати дію "Відпрацьовано" можливо лише у Стані = "Отримано рекомендації"!');
        END IF;

        -- Існує хоч одна Відпрацьована рекомендація
        SELECT COUNT (*)
          INTO l_cnt
          FROM me_minfin_recomm_rows
         WHERE merc_memr = p_memr_id AND merc_st = 'V';

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'За даним рядком пакету не знайдено жодної відпрацьованної рекомендації!');
        END IF;

        -- serhii: #92025-28 контроль на обробоку всіх невідповідностей
        -- Всі дочірні рекомендації Відпрацьовані або Передані (V,P)
        SELECT COUNT (*)
          INTO l_cnt
          FROM me_minfin_recomm_rows
         WHERE merc_memr = p_memr_id AND NVL (merc_st, 'O') = 'O';

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'За даним рядком є невідпрацьовані рекомендації!');
        END IF;

        -- Всі "Відпрацьовані" дочірні рекомендації мають Підтверджені дочірні рішеня
        SELECT NVL (MAX (r.merc_type_rec), 0)
          INTO l_cnt
          FROM me_minfin_recomm_rows r
         WHERE     r.merc_memr = p_memr_id
               AND r.merc_st = 'V'
               AND NOT EXISTS
                       (SELECT NULL
                          FROM me_minfin_result_rows s
                         WHERE s.mesr_merc = r.merc_id AND s.mesr_st = 'P');

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'За невідповідністю з кодом '
                || TO_CHAR (l_cnt)
                || ' не знайдено підтвердженних рішеннь!');
        END IF;

        -- Всі "Відпрацьовані" дочірні рекомендації не мають непідтверждених дочірніх рішень
        SELECT NVL (MAX (r.merc_type_rec), 0)
          INTO l_cnt
          FROM me_minfin_recomm_rows r
         WHERE     r.merc_memr = p_memr_id
               AND r.merc_st = 'V'
               AND EXISTS
                       (SELECT NULL
                          FROM me_minfin_result_rows s
                         WHERE     s.mesr_merc = r.merc_id
                               AND NVL (s.mesr_st, 'E') = 'E');

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'За невідповідністю з кодом '
                || TO_CHAR (l_cnt)
                || ' знайдено непідтвердженні рішення!');
        END IF;

        -- Немає дублюючих рішень
        SELECT NVL (MAX (t.mesr_type_rec), 0)
          INTO l_cnt
          FROM (SELECT s.mesr_type_rec,
                       ROW_NUMBER ()
                           OVER (PARTITION BY s.mesr_merc ORDER BY 1)    rn
                  FROM me_minfin_result_rows s
                 WHERE     NVL (s.mesr_st, 'P') = 'P'
                       AND s.mesr_merc IN
                               (SELECT r.merc_id
                                  FROM me_minfin_recomm_rows r
                                 WHERE     r.merc_memr = p_memr_id
                                       AND r.merc_st = 'V')) t
         WHERE t.rn = 2;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'За невідповідністю з кодом '
                || TO_CHAR (l_cnt)
                || ' знайдено більше одного рішення!');
        END IF;

        -- В рішеннях заповнені всі обов'язкові поля
        SELECT NVL (MAX (r.merc_type_rec), 0)
          INTO l_cnt
          FROM me_minfin_recomm_rows r
         WHERE     r.merc_memr = p_memr_id
               AND r.merc_st = 'V'
               AND EXISTS
                       (SELECT NULL
                          FROM me_minfin_result_rows
                         WHERE     mesr_merc = r.merc_id
                               AND mesr_st = 'P'
                               AND NOT (    mesr_id_rec IS NOT NULL
                                        AND mesr_id_fam IS NOT NULL
                                        AND mesr_ris_code IS NOT NULL
                                        AND mesr_klcom_coddec IS NOT NULL
                                        AND mesr_res_date IS NOT NULL
                                        AND mesr_type_rec IS NOT NULL
                                        AND mesr_rec_code IS NOT NULL
                                        AND mesr_rec_date IS NOT NULL));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'За невідповідністю з кодом '
                || TO_CHAR (l_cnt)
                || ' знайдено рішення в якому не всі обов''язкові поля заповнені!');
        END IF;

        UPDATE me_minfin_request_rows t
           SET t.memr_st = 'V'
         WHERE t.memr_id = p_memr_id;
    END;

    -- #93855: повернення Рішення на редагування
    PROCEDURE set_edit_result_data (p_mesr_id IN NUMBER)
    IS
        l_merc_st   me_minfin_recomm_rows.merc_st%TYPE;
        l_mesr_st   me_minfin_result_rows.mesr_st%TYPE;
    BEGIN
        SELECT merc_st, mesr_st
          INTO l_merc_st, l_mesr_st
          FROM me_minfin_result_rows
               INNER JOIN me_minfin_recomm_rows ON mesr_merc = merc_id
         WHERE mesr_id = p_mesr_id;

        IF NOT (l_mesr_st = 'P' AND l_merc_st = 'O')
        THEN
            raise_application_error (
                -20000,
                'Повернення підтвердженого рішення на редагування можливо лише для невідповідності у стані "Отримано"!');
        END IF;

        UPDATE me_minfin_result_rows
           SET mesr_st = 'E'                                       -- Створено
         WHERE mesr_id = p_mesr_id;
    END;

    -- #109658
    PROCEDURE set_packet_st (p_me_id IN NUMBER, p_me_st IN VARCHAR2)
    IS
    BEGIN
        API$MASS_EXCHANGE.setPacketSt (p_me_id, p_me_st);
    END;
BEGIN
    NULL;
END DNET$MASS_EXCHANGE;
/