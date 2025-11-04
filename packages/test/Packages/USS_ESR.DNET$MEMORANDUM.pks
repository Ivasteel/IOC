/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MEMORANDUM
IS
    -- Author  : DLEV
    -- Created : 04.11.2022 16:42:43
    -- Purpose : Робота з "Реєстр меморандумів 2022"

    -- info:   отримання даних для реєстру
    -- params: p_start_dt - Дата формування з
    --         p_stop_dt - Дата формування по
    --         p_msi_npt - Ідентифікатор меморандуму (v_memorandum_list)
    -- note:
    PROCEDURE get_memorandum_log (p_msi_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR);

    PROCEDURE get_memorandum_list (
        p_start_dt   IN     DATE,
        p_stop_dt    IN     DATE,
        p_msi_npt    IN     v_msp_memorandum_files.mm_npt%TYPE,
        res_cur         OUT SYS_REFCURSOR);


    PROCEDURE get_memorandum (
        p_msi_id   IN     v_msp_memorandum_files.mm_id%TYPE,
        res_cur       OUT SYS_REFCURSOR);

    -- info:   отримання вкладення (файлу) по запису реєстру
    -- params: p_msi_id - ідентифікатор запису
    --         p_file_mime_type - тип файлу
    --         p_file_name - назва файлу
    --         p_file_blob - вміст файлу (блоб)
    -- note:
    PROCEDURE get_linked_file (
        p_msi_id      IN     v_msp_memorandum_files.mm_id%TYPE, /* p_file_mime_type OUT VARCHAR2,*/
        p_file_name      OUT VARCHAR2,
        p_file_blob      OUT BLOB);
END;
/


GRANT EXECUTE ON USS_ESR.DNET$MEMORANDUM TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MEMORANDUM TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MEMORANDUM
IS
    PROCEDURE write_mm_log (p_mml_mm        mm_log.mml_mm%TYPE,
                            p_mml_hs        mm_log.mml_hs%TYPE,
                            p_mml_st        mm_log.mml_st%TYPE,
                            p_mml_message   mm_log.mml_message%TYPE,
                            p_mml_st_old    mm_log.mml_st_old%TYPE,
                            p_mml_tp        mm_log.mml_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_mml_hs, TOOLS.GetHistSession);

        INSERT INTO mm_log (mml_id,
                            mml_mm,
                            mml_hs,
                            mml_st,
                            mml_message,
                            mml_st_old,
                            mml_tp)
             VALUES (0,
                     p_mml_mm,
                     l_hs,
                     p_mml_st,
                     p_mml_message,
                     p_mml_st_old,
                     NVL (p_mml_tp, 'SYS'));
    END;


    PROCEDURE get_memorandum_log (p_msi_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.mml_id
                         AS log_id,
                     t.mml_mm
                         AS log_obj,
                     t.mml_tp
                         AS log_tp,
                     st.dic_name
                         AS log_st_name,
                     sto.dic_name
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     NVL (tools.getuserlogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     uss_ndi.rdm$msg_template.getmessagetext (t.mml_message)
                         AS log_message
                FROM mm_log t
                     LEFT JOIN uss_ndi.v_ddn_pd_st st
                         ON (st.dic_value = t.mml_st)
                     LEFT JOIN uss_ndi.v_ddn_pd_st sto
                         ON (sto.dic_value = t.mml_st_old)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.mml_hs)
               WHERE t.mml_mm = p_msi_id
            ORDER BY hs.hs_dt;
    END;

    -- info:   отримання даних для реєстру
    -- params: p_start_dt - Дата формування з
    --         p_stop_dt - Дата формування по
    --         p_msi_npt - Ідентифікатор меморандуму (v_memorandum_list)
    -- note:
    PROCEDURE get_memorandum_list (
        p_start_dt   IN     DATE,
        p_stop_dt    IN     DATE,
        p_msi_npt    IN     v_msp_memorandum_files.mm_npt%TYPE,
        res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT mm_id
                         msi_id,                        --Ідентифікатор запису
                     mm_create_dt
                         msi_decision_dt,           --Дата формування переліку
                     TO_CHAR (mm_create_dt, 'dd.mm.yyyy HH24:MI')
                         AS Msi_Decision_Dt_Text,
                     npt_code
                         AS msi_code,                        --Код меморандуму
                     npt_name
                         AS msi_name,                      --Назва меморандуму
                     mm_appeal_cnt
                         msi_ap_num,                       --Кількість записів
                     mm_person_cnt
                         msi_app_num,                         --Кількість осіб
                     mm_not_paid_appeal_cnt
                         msi_not_paid_ap_num,    --Виплата не проведена (заяв)
                     mm_not_paid_person_cnt
                         msi_not_paid_app_num,   --Виплата не проведена (осіб)
                     mm_criteria_desc
                         msi_criteria_desc      --Опис критеріїв відбору даних
                FROM v_msp_memorandum_files
                     JOIN uss_ndi.v_ndi_payment_type ON npt_id = mm_npt
               WHERE     COALESCE (p_start_dt, TRUNC (mm_create_dt)) <=
                         TRUNC (mm_create_dt)
                     AND COALESCE (p_stop_dt, TRUNC (mm_create_dt)) >=
                         TRUNC (mm_create_dt)
                     AND COALESCE (p_msi_npt, mm_npt) = mm_npt
            ORDER BY mm_create_dt, npt_id DESC;
    END;

    -- info:   отримання вкладення (файлу) по запису реєстру
    -- params: p_msi_id - ідентифікатор запису по меморандуму
    --         p_file_mime_type - тип файлу
    --         p_file_name - назва файлу
    --         p_file_blob - вміст файлу (блоб)
    -- note:

    PROCEDURE get_memorandum (
        p_msi_id   IN     v_msp_memorandum_files.mm_id%TYPE,
        res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT mm_id
                         msi_id,                        --Ідентифікатор запису
                     mm_create_dt
                         msi_decision_dt,           --Дата формування переліку
                     TO_CHAR (mm_create_dt, 'dd.mm.yyyy HH24:MI')
                         AS Msi_Decision_Dt_Text,
                     npt.npt_code
                         AS msi_code,                        --Код меморандуму
                     npt.npt_name
                         AS msi_name,                      --Назва меморандуму
                     mm_appeal_cnt
                         msi_ap_num,                       --Кількість записів
                     mm_person_cnt
                         msi_app_num,                         --Кількість осіб
                     mm_not_paid_appeal_cnt
                         msi_not_paid_ap_num,    --Виплата не проведена (заяв)
                     mm_not_paid_person_cnt
                         msi_not_paid_app_num,   --Виплата не проведена (осіб)
                     mm_criteria_desc
                         msi_criteria_desc      --Опис критеріїв відбору даних
                FROM v_msp_memorandum_files mf
                     JOIN uss_ndi.v_ndi_payment_type npt
                         ON npt.npt_id = mf.mm_npt
               WHERE mf.mm_id = p_msi_id
            ORDER BY mm_create_dt, npt_id DESC;
    END;


    PROCEDURE get_linked_file (
        p_msi_id      IN     v_msp_memorandum_files.mm_id%TYPE, /* p_file_mime_type OUT VARCHAR2,*/
        p_file_name      OUT VARCHAR2,
        p_file_blob      OUT BLOB)
    IS
        l_usr_pib   VARCHAR2 (250);
    BEGIN
        l_usr_pib := TOOLS.GetCurrUserPIB;

        /*p_file_mime_type := 'text/csv';*/

        SELECT (   'Меморандум '
                || (SELECT npt_name
                      FROM uss_ndi.v_ndi_payment_type
                     WHERE npt_id = mm_npt)
                || TO_CHAR (mm_create_dt, 'DDMMYYYYHH24MISS')
                || '.csv'),
               mm_list_file
          INTO p_file_name, p_file_blob
          FROM v_msp_memorandum_files
         WHERE mm_id = p_msi_id;

        write_mm_log (p_msi_id,
                      TOOLS.GetHistSession,
                      NULL,
                      CHR (38) || '127#' || l_usr_pib,
                      NULL);
    END;
END;
/