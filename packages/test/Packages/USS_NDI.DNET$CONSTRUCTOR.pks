/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$CONSTRUCTOR
IS
    -- Author  : BOGDAN
    -- Created : 25.10.2024 12:52:46
    -- Purpose :


    PROCEDURE get_doc_verify_setup (p_doc   OUT SYS_REFCURSOR,
                                    p_ver   OUT SYS_REFCURSOR);

    PROCEDURE get_service_doc_setup (p_nst_id   IN     NUMBER,
                                     res_cur       OUT SYS_REFCURSOR);


    -- #111378: картка налаштування документів по послузі
    PROCEDURE get_service_doc_setup_card (p_nndc_id   IN     NUMBER,
                                          res_cur        OUT SYS_REFCURSOR,
                                          alt_cur        OUT SYS_REFCURSOR);

    -- #111378: збереження налаштування документів по послузі
    PROCEDURE save_service_doc_setup (
        p_NNDC_ID           IN     NDI_NST_DOC_CONFIG.NNDC_ID%TYPE,
        p_NNDC_NST          IN     NDI_NST_DOC_CONFIG.NNDC_NST%TYPE,
        p_NNDC_NDT          IN     NDI_NST_DOC_CONFIG.NNDC_NDT%TYPE,
        p_NNDC_IS_REQ       IN     NDI_NST_DOC_CONFIG.NNDC_IS_REQ%TYPE,
        p_NNDC_NOTE         IN     NDI_NST_DOC_CONFIG.NNDC_NOTE%TYPE,
        p_NNDC_APP_TP       IN     NDI_NST_DOC_CONFIG.NNDC_APP_TP%TYPE,
        --p_NNDC_NDT_ALT1 in NDI_NST_DOC_CONFIG.NNDC_NDT_ALT1%type,
        p_NNDC_NDC          IN     NDI_NST_DOC_CONFIG.NNDC_NDC%TYPE,
        p_NNDC_NDA          IN     NDI_NST_DOC_CONFIG.NNDC_NDA%TYPE,
        p_NNDC_VAL_STRING   IN     NDI_NST_DOC_CONFIG.NNDC_VAL_STRING%TYPE,
        p_NNDC_AP_TP        IN     NDI_NST_DOC_CONFIG.NNDC_AP_TP%TYPE,
        p_new_id               OUT NDI_NST_DOC_CONFIG.NNDC_ID%TYPE);

    -- #111378: видалення налаштування документів по послузі
    PROCEDURE delete_service_doc_setup (p_nndc_id IN NUMBER);

    -- #111378: додавання налаштування документів по послузі (альтернативних)
    PROCEDURE add_nndc_setup (p_nndc_id   IN     NUMBER,
                              p_ndt_id    IN     NUMBER,
                              p_new_id       OUT NUMBER);

    -- #111378: видалення налаштування документів по послузі (альтернативних)
    PROCEDURE delete_nndc_setup (p_nns_id IN NUMBER);

    -----------------------------------------
    ------------ NDI RIGHT SETUP ------------

    PROCEDURE get_nst_list (p_show_all   IN     VARCHAR2,
                            res_cur         OUT SYS_REFCURSOR);

    -- #110291
    PROCEDURE get_right_setup (p_nst_id           IN     NUMBER,
                               p_show_All         IN     VARCHAR2,
                               p_right_rules         OUT SYS_REFCURSOR,
                               p_reject_reasons      OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Nrr_Config (
        p_Nruc_Id   IN     ndi_nrr_config.nruc_id%TYPE,
        P_RES          OUT SYS_REFCURSOR);

    PROCEDURE GET_REJECT_REASON (
        p_njr_id   IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        P_RES         OUT SYS_REFCURSOR);

    PROCEDURE Set_Ndi_Nrr_Config (
        p_NRUC_ID           IN NDI_NRR_CONFIG.NRUC_ID%TYPE,
        p_NRUC_NRR          IN NDI_NRR_CONFIG.NRUC_NRR%TYPE,
        p_NRUC_NST          IN NDI_NRR_CONFIG.NRUC_NST%TYPE,
        p_NRUC_SQL          IN NDI_NRR_CONFIG.NRUC_SQL%TYPE,
        p_NRUC_SQL_INFO     IN NDI_NRR_CONFIG.NRUC_SQL_INFO%TYPE,
        p_NRUC_IS_VISIBLE   IN NDI_NRR_CONFIG.NRUC_IS_VISIBLE%TYPE,
        p_NRUC_START_DT     IN NDI_NRR_CONFIG.NRUC_START_DT%TYPE,
        p_NRUC_STOP_DT      IN NDI_NRR_CONFIG.NRUC_STOP_DT%TYPE--,p_new_id out NDI_NRR_CONFIG.NRUC_ID%type
                                                               );

    PROCEDURE set_reject_reason (
        p_njr_id      IN     ndi_reject_reason.njr_id%TYPE,
        p_njr_code    IN     ndi_reject_reason.njr_code%TYPE,
        p_njr_name    IN     ndi_reject_reason.njr_name%TYPE,
        p_njr_order   IN     ndi_reject_reason.njr_order%TYPE,
        p_njr_nst     IN     ndi_reject_reason.njr_nst%TYPE,
        p_new_id         OUT ndi_reject_reason.njr_id%TYPE);

    -- #112746
    PROCEDURE Delete_Ndi_Nrr_Config (
        p_Nruc_Id   IN ndi_nrr_config.nruc_id%TYPE);

    -- #112746
    PROCEDURE DELETE_REJECT_REASON (
        p_Nrj_Id   IN ndi_reject_reason.njr_id%TYPE);



    PROCEDURE get_income_setup (p_Res_cur OUT SYS_REFCURSOR);

    -- #110303, #111380
    PROCEDURE get_ap_nst_setup (p_ap_tp      IN     VARCHAR2,
                                p_show_All   IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);

    -- #111380
    PROCEDURE add_ap_nst_setup (p_at_tp IN VARCHAR2, p_nst_id IN NUMBER);

    -- #111380
    PROCEDURE delete_ap_nst_setup (p_nanc_id IN NUMBER);

    -- #110411
    PROCEDURE get_nda_validation (res_cur OUT SYS_REFCURSOR);

    -- #110938
    PROCEDURE get_dics_change_log (p_obj_type    IN     VARCHAR2,
                                   p_record_id   IN     NUMBER,
                                   info_cur         OUT SYS_REFCURSOR,
                                   res_cur          OUT SYS_REFCURSOR);

    -----------------------------------------
    ------------ NDI_RIGHT_RULES ------------

    -- #110297, #112728
    PROCEDURE get_right_rules (p_nrr_code      IN     VARCHAR2,
                               p_nrr_name      IN     VARCHAR2,
                               p_nrr_tp        IN     VARCHAR2,
                               p_nrr_ap_tp     IN     VARCHAR2,
                               p_is_critical   IN     VARCHAR2,
                               res_cur            OUT SYS_REFCURSOR);

    -- #112728
    PROCEDURE get_right_rules_card (p_nrr_id   IN     NUMBER,
                                    res_cur       OUT SYS_REFCURSOR);

    -- #112728
    PROCEDURE set_right_rules (
        p_NRR_ID                  IN     NDI_RIGHT_RULE.NRR_ID%TYPE,
        p_NRR_CODE                IN     NDI_RIGHT_RULE.NRR_CODE%TYPE,
        p_NRR_NAME                IN     NDI_RIGHT_RULE.NRR_NAME%TYPE,
        p_NRR_ALG                 IN     NDI_RIGHT_RULE.NRR_ALG%TYPE,
        p_NRR_ORDER               IN     NDI_RIGHT_RULE.NRR_ORDER%TYPE,
        p_NRR_TP                  IN     NDI_RIGHT_RULE.NRR_TP%TYPE,
        p_NRR_IS_CRITICAL_ERROR   IN     NDI_RIGHT_RULE.NRR_IS_CRITICAL_ERROR%TYPE,
        p_NRR_AP_TP               IN     NDI_RIGHT_RULE.NRR_AP_TP%TYPE,
        p_new_id                     OUT NDI_RIGHT_RULE.NRR_ID%TYPE);

    -- #112728
    PROCEDURE Delete_Ndi_Right_Rules (p_Nrr_Id IN ndi_right_rule.Nrr_Id%TYPE);
END DNET$CONSTRUCTOR;
/


GRANT EXECUTE ON USS_NDI.DNET$CONSTRUCTOR TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$CONSTRUCTOR IS

  -- #110305
  procedure get_doc_verify_setup (p_doc out sys_refcursor,
                                  p_ver out sys_refcursor)
  is
  begin
    open p_doc for
      SELECT t.*
        FROM ndi_document_type t
       where t.history_status = 'A'
         and exists (SELECT * FROM ndi_verification_type z where z.nvt_ndt = t.ndt_id and z.history_status = 'A')
       ;

    open p_ver for
      SELECT t.*,
             m.nvt_name as nvt_nvt_main_main,
             tp.DIC_NAME as nvt_tp_name,
             r.nrt_code as nvt_nrt_name
        FROM ndi_verification_type t
        join v_ddn_vf_tp tp on (tp.DIC_VALUE = t.nvt_vf_tp)
        left join ndi_verification_type m on (m.nvt_id = t.nvt_nvt_main)
        left join NDI_REQUEST_TYPE r on (r.nrt_id = t.nvt_nrt)
       where t.history_status = 'A';
  end;

  -- #110304, #111378: налаштування документів по послузі
  procedure get_service_doc_setup (p_nst_id in number,
                                   res_cur out sys_refcursor)
  is
  begin
    open res_cur for
      SELECT t.*,
             tm.ndt_name as nndc_ndt_name,
             a.nda_name as nndc_nda_name,
             tp.DIC_NAME as nndc_ap_tp_name,
             tpp.DIC_NAME as nndc_app_tp_name,
             s.nst_name as nndc_nst_name,
             (SELECT listagg(dz.ndt_name_short, '; ' on overflow truncate '...') within group (order by 1)
                FROM Ndi_Nndc_Setup z
                join ndi_document_type dz on (dz.ndt_id = z.nns_ndt)
               where z.nns_nndc = t.nndc_id
                 and z.history_status = 'A'
                 and z.nns_tp = 'AD'
             ) as alt_doc_types,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
             tools.can_edit_record(t.record_src) as can_Edit_Record
        FROM ndi_nst_doc_config t
        join ndi_service_type s on (s.nst_id = t.nndc_nst)
        join ndi_document_type tm on (tm.ndt_id = t.nndc_ndt)
        left join ndi_document_attr a on (a.nda_id = t.nndc_nda)
        left join v_ddn_ap_tp tp on (tp.DIC_VALUE = t.nndc_ap_tp)
        left join v_ddn_app_tp tpp on (tpp.DIC_VALUE = t.nndc_app_tp)
       where t.history_status = 'A'
         and t.nndc_nst = p_nst_id
      ;
  end;

  -- #111378: картка налаштування документів по послузі
  procedure get_service_doc_setup_card (p_nndc_id in number,
                                        res_cur out sys_refcursor,
                                        alt_cur out sys_refcursor)
  is
  begin
    open res_cur for
      SELECT t.*,
             tm.ndt_name as nndc_ndt_name,
             a.nda_name as nndc_nda_name,
             tp.DIC_NAME as nndc_ap_tp_name,
             tpp.DIC_NAME as nndc_app_tp_name,
             s.nst_name as nndc_nst_name,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
             tools.can_edit_record(t.record_src) as can_Edit_Record
        FROM ndi_nst_doc_config t
        join ndi_service_type s on (s.nst_id = t.nndc_nst)
        join ndi_document_type tm on (tm.ndt_id = t.nndc_ndt)
        left join ndi_document_attr a on (a.nda_id = t.nndc_nda)
        left join v_ddn_ap_tp tp on (tp.DIC_VALUE = t.nndc_ap_tp)
        left join v_ddn_app_tp tpp on (tpp.DIC_VALUE = t.nndc_app_tp)
       where t.history_status = 'A'
         and t.nndc_id = p_nndc_id
      ;

    open alt_cur for
      SELECT z.*,
             dz.ndt_name as Nns_Ndt_Name
        FROM Ndi_Nndc_Setup z
        join ndi_document_type dz on (dz.ndt_id = z.nns_ndt)
       where z.nns_nndc = p_nndc_id
         and z.history_status = 'A'
         and z.nns_tp = 'AD';
  end;

  -- #111378: збереження налаштування документів по послузі
  procedure save_service_doc_setup (p_NNDC_ID in NDI_NST_DOC_CONFIG.NNDC_ID%type,
                                    p_NNDC_NST in NDI_NST_DOC_CONFIG.NNDC_NST%type,
                                    p_NNDC_NDT in NDI_NST_DOC_CONFIG.NNDC_NDT%type,
                                    p_NNDC_IS_REQ in NDI_NST_DOC_CONFIG.NNDC_IS_REQ%type,
                                    p_NNDC_NOTE in NDI_NST_DOC_CONFIG.NNDC_NOTE%type,
                                    p_NNDC_APP_TP in NDI_NST_DOC_CONFIG.NNDC_APP_TP%type,
                                    --p_NNDC_NDT_ALT1 in NDI_NST_DOC_CONFIG.NNDC_NDT_ALT1%type,
                                    p_NNDC_NDC in NDI_NST_DOC_CONFIG.NNDC_NDC%type,
                                    p_NNDC_NDA in NDI_NST_DOC_CONFIG.NNDC_NDA%type,
                                    p_NNDC_VAL_STRING in NDI_NST_DOC_CONFIG.NNDC_VAL_STRING%type,
                                    p_NNDC_AP_TP in NDI_NST_DOC_CONFIG.NNDC_AP_TP%type,
                                    p_new_id out NDI_NST_DOC_CONFIG.NNDC_ID%type)
  is
    l_rec_src NDI_NST_DOC_CONFIG.Record_Src%type;
    l_hs number := tools.GetHistSession;
  begin
    if p_NNDC_ID is null then
      insert into NDI_NST_DOC_CONFIG
        (
           NNDC_NST,
           NNDC_NDT,
           NNDC_IS_REQ,
           NNDC_NOTE,
           HISTORY_STATUS,
           NNDC_APP_TP,
           --NNDC_NDT_ALT1,
           NNDC_NDC,
           NNDC_NDA,
           NNDC_VAL_STRING,
           NNDC_AP_TP,
           RECORD_SRC,
           NNDC_HS_INS
        )
      values
        (
           p_NNDC_NST,
           p_NNDC_NDT,
           p_NNDC_IS_REQ,
           p_NNDC_NOTE,
           'A',
           p_NNDC_APP_TP,
           --p_NNDC_NDT_ALT1,
           p_NNDC_NDC,
           p_NNDC_NDA,
           p_NNDC_VAL_STRING,
           p_NNDC_AP_TP,
           TOOLS.get_record_src,
           l_hs
        )
      returning NNDC_ID into p_new_id;

      API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NST_DOC_CONFIG',
                                      p_ncl_action => 'C',
                                      p_ncl_hs => l_hs,
                                      p_ncl_record_id => p_new_id
                                     );
    else
      p_new_id := p_NNDC_ID;

      SELECT t.record_src
        into l_rec_src
        FROM NDI_NST_DOC_CONFIG t
       where t.nndc_id = p_new_id;
      TOOLS.check_record_src(l_rec_src);

      update NDI_NST_DOC_CONFIG
         set --NNDC_NST = p_NNDC_NST,
             NNDC_NDT = p_NNDC_NDT,
             NNDC_IS_REQ = p_NNDC_IS_REQ,
             NNDC_NOTE = p_NNDC_NOTE,
             NNDC_APP_TP = p_NNDC_APP_TP,
             NNDC_NDC = p_NNDC_NDC,
             NNDC_NDA = p_NNDC_NDA,
             NNDC_VAL_STRING = p_NNDC_VAL_STRING,
             NNDC_AP_TP = p_NNDC_AP_TP
       where NNDC_ID = p_NNDC_ID;

      API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NST_DOC_CONFIG',
                                      p_ncl_action => 'U',
                                      p_ncl_hs => l_hs,
                                      p_ncl_record_id => p_new_id
                                     );
    end if;
  end;

  -- #111378: видалення налаштування документів по послузі
  procedure delete_service_doc_setup (p_nndc_id in number)
  is
    l_hs number := tools.GetHistSession;
    l_rec_src NDI_NST_DOC_CONFIG.record_src%type;
  begin
    SELECT t.record_src
      into l_rec_src
      FROM NDI_NST_DOC_CONFIG t
     where t.nndc_id = p_nndc_id;
    TOOLS.check_record_src(l_rec_src);

    UPDATE NDI_NST_DOC_CONFIG t
       SET HISTORY_STATUS = 'H',
           t.nndc_hs_del = l_hs
     WHERE NNDC_ID = p_nndc_id;

     API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NST_DOC_CONFIG',
                                     p_ncl_action => 'D',
                                     p_ncl_hs => l_hs,
                                     p_ncl_decription => '&322',
                                     p_ncl_record_id => p_nndc_id
                                    );
  end;

  -- #111378: додавання налаштування документів по послузі (альтернативних)
  procedure add_nndc_setup (p_nndc_id in number,
                            p_ndt_id in number,
                            p_new_id out number)
  is
  begin
    insert into ndi_nndc_setup
      (nns_nndc, nns_tp, nns_ndt, history_status )
    values
      (p_nndc_id, 'AD', p_ndt_id, 'A')
    returning nns_id into p_new_id;
  end;

  -- #111378: видалення налаштування документів по послузі (альтернативних)
  procedure delete_nndc_setup (p_nns_id in number)
  is
  begin
    update ndi_nndc_setup t
       set t.history_status = 'H'
     where t.nns_id = p_nns_id;
  end;

  -----------------------------------------
  ------------ NDI RIGHT SETUP ------------

  -- #112746
  procedure get_nst_list (p_show_all in varchar2,
                          res_cur out sys_refcursor)
  is
  begin
    Tools.Check_User_And_Raise(99);

    open res_cur for
      SELECT t.*
        FROM ndi_service_type t
       where 1 = 1
         and (p_show_All = 'T' or nvl(p_show_All, 'F') = 'F' and t.history_status = 'A')
         ;
  end;

  -- #110291, #112746
  procedure get_right_setup (p_nst_id in number,
                             p_show_All in varchar2,
                             p_right_rules out sys_refcursor,
                             p_reject_reasons out sys_refcursor)
  is
  begin
    Tools.Check_User_And_Raise(99);

    open p_right_rules for
      SELECT t.nrr_name,
             /*tp.DIC_NAME as nrr_tp_name,
             tpa.DIC_NAME as nrr_ap_tp_name,
             hsi.hs_dt as nrr_hs_ins_dt,
             tools.getuserpib(hsi.hs_wu) as nrr_hs_ins_pib,
             hsd.hs_dt as nrr_hs_del_dt,
             tools.getuserpib(hsd.hs_wu) as nrr_hs_del_pib,*/
             c.*,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = c.record_src) as record_src_name,
             tools.can_edit_record(c.record_src) as can_Edit_Record
        FROM ndi_right_rule t
        join ndi_nrr_config c on (c.nruc_nrr = t.nrr_id)
        --left join v_ddn_nrr_tp tp on (tp.DIC_VALUE = t.nrr_tp)
        --left join v_ddn_ap_tp tpa on (tpa.DIC_VALUE = t.nrr_ap_tp)
        --left join histsession hsi on (hsi.hs_id = t.nrr_hs_ins)
        --left join histsession hsd on (hsd.hs_id = t.nrr_hs_del)
       where c.nruc_nst = p_nst_id
         and (p_show_All = 'T' or nvl(p_show_All, 'F') = 'F' and c.history_status = 'A')
         and t.history_status = 'A'
       order by t.nrr_name, c.nruc_start_dt
         ;

    open p_reject_reasons for
      SELECT t.*,
             hsd.hs_dt as njr_hs_del_dt,
             tools.getuserpib(hsd.hs_wu) as njr_hs_del_pib,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
             tools.can_edit_record(t.record_src) as can_Edit_Record
        FROM ndi_reject_reason t
        left join histsession hsd on (hsd.hs_id = t.njr_hs_del)
       where t.njr_nst = p_nst_id
         and (p_show_All = 'T' or nvl(p_show_All, 'F') = 'F' and t.history_status = 'A')
       order by t.njr_name;
  end;

  PROCEDURE Get_Ndi_Nrr_Config (p_Nruc_Id IN ndi_nrr_config.nruc_id%TYPE,
                                P_RES OUT SYS_REFCURSOR)
  IS
  BEGIN
    Tools.Check_User_And_Raise(99);

    OPEN P_RES FOR
    SELECT t.*,
           r.nrr_name,
           st.nst_name,
           (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
           tools.can_edit_record(t.record_src) as can_Edit_Record
      FROM ndi_nrr_config t
      join ndi_right_rule r on (r.nrr_id = t.nruc_nrr)
      join ndi_service_type st on (st.nst_id = t.nruc_nst)
     WHERE t.nruc_id = p_Nruc_Id;
  END;

  PROCEDURE GET_REJECT_REASON (p_njr_id IN NDI_REJECT_REASON.NJR_ID%type,
                               P_RES OUT SYS_REFCURSOR) IS
  BEGIN
    Tools.Check_User_And_Raise(99);

    OPEN P_RES FOR
    SELECT t.*,
           (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
           tools.can_edit_record(t.record_src) as can_Edit_Record
      FROM NDI_REJECT_REASON t
     WHERE NJR_ID = p_njr_id;
  END;

  procedure Set_Ndi_Nrr_Config(p_NRUC_ID in NDI_NRR_CONFIG.NRUC_ID%type,
                               p_NRUC_NRR in NDI_NRR_CONFIG.NRUC_NRR%type,
                               p_NRUC_NST in NDI_NRR_CONFIG.NRUC_NST%type,
                               p_NRUC_SQL in NDI_NRR_CONFIG.NRUC_SQL%type,
                               p_NRUC_SQL_INFO in NDI_NRR_CONFIG.NRUC_SQL_INFO%type,
                               p_NRUC_IS_VISIBLE in NDI_NRR_CONFIG.NRUC_IS_VISIBLE%type,
                               p_NRUC_START_DT in NDI_NRR_CONFIG.NRUC_START_DT%type,
                               p_NRUC_STOP_DT in NDI_NRR_CONFIG.NRUC_STOP_DT%type
                               --,p_new_id out NDI_NRR_CONFIG.NRUC_ID%type
                               )
  is
   l_rec_src NDI_NRR_CONFIG.record_src%type;
   l_hs number := tools.GetHistSession;
  begin
    if (p_NRUC_ID is not null) then
      SELECT t.record_src
        into l_rec_src
        FROM NDI_NRR_CONFIG t
       where t.nruc_id = p_NRUC_ID;
      TOOLS.check_record_src(l_rec_src);
    end if;

    INSERT INTO tmp_unh_old_list
     (ol_obj, ol_hst, ol_begin, ol_end)
     SELECT 0, h.nruc_id, h.nruc_start_dt, h.nruc_stop_dt
       FROM v_NDI_NRR_CONFIG h
      WHERE h.history_status = 'A'
        AND h.nruc_nst = p_NRUC_NST
        AND h.nruc_nrr = p_NRUC_NRR
        AND (p_NRUC_ID IS NULL OR h.nruc_id != p_NRUC_ID)
        ;

   -- формування історії
   api$hist.setup_history(0, p_NRUC_START_DT, p_NRUC_STOP_DT);

   -- закриття недіючих
   UPDATE v_ndi_nrr_config h
      SET h.nruc_hs_del = l_hs,
          h.history_status = 'H'
    WHERE (EXISTS (SELECT 1 FROM tmp_unh_to_prp WHERE tprp_hst = h.nruc_id))
    OR h.nruc_id = p_NRUC_ID
    ;

   -- додавання нових періодів
   INSERT INTO v_ndi_nrr_config
     (
       NRUC_ID,
       NRUC_NRR,
       NRUC_NST,
       NRUC_SQL,
       NRUC_SQL_INFO,
       NRUC_IS_VISIBLE,
       HISTORY_STATUS,
       NRUC_START_DT,
       NRUC_STOP_DT,
       NRUC_HS_INS,
       RECORD_SRC
      )
     SELECT 0,
            ho.nruc_nrr,
            ho.nruc_nst,
            ho.nruc_sql,
            ho.nruc_sql_info,
            ho.nruc_is_visible,
            'A',
            rz.rz_begin,
            rz.rz_end,
            l_hs,
            TOOLS.get_record_src
       FROM tmp_unh_rz_list rz, v_ndi_nrr_config ho
      WHERE rz_hst <> 0
        AND (rz_begin <= rz_end OR rz_end IS NULL)
        AND ho.nruc_id = rz_hst
     UNION
     SELECT 0,
            p_NRUC_NRR,
            p_NRUC_NST,
            p_NRUC_SQL,
            p_NRUC_SQL_INFO,
            p_NRUC_IS_VISIBLE,
            'A',
            vh_lgwh.rz_begin,
            vh_lgwh.rz_end,
            l_hs,
            TOOLS.get_record_src
       FROM tmp_unh_rz_list vh_lgwh
      WHERE rz_hst = 0
        AND (rz_begin <= rz_end OR rz_end IS NULL);

    for xx in (SELECT t.nruc_id FROM v_ndi_nrr_config t where t.nruc_hs_ins = l_hs)
    loop
      API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NRR_CONFIG',
                                      p_ncl_action => 'C',
                                      p_ncl_hs => l_hs,
                                      p_ncl_record_id => xx.nruc_id
                                     );
    end loop;


    /*if p_NRUC_ID is null then
      insert into NDI_NRR_CONFIG
        (
           NRUC_NRR,
           NRUC_NST,
           NRUC_SQL,
           NRUC_SQL_INFO,
           NRUC_IS_VISIBLE,
           HISTORY_STATUS,
           NRUC_START_DT,
           NRUC_STOP_DT,
           NRUC_HS_INS,
           RECORD_SRC
        )
      values
        (
           p_NRUC_NRR,
           p_NRUC_NST,
           p_NRUC_SQL,
           p_NRUC_SQL_INFO,
           p_NRUC_IS_VISIBLE,
           'A',
           p_NRUC_START_DT,
           p_NRUC_STOP_DT,
           l_hs,
           TOOLS.get_record_src
        )
      returning NRUC_ID into p_new_id;

      API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NRR_CONFIG',
                                      p_ncl_action => 'C',
                                      p_ncl_hs => l_hs,
                                      p_ncl_record_id => p_New_Id
                                     );
    else
      p_new_id := p_NRUC_ID;

      SELECT t.record_src
        into l_rec_src
        FROM NDI_NRR_CONFIG t
       where t.nruc_id = p_new_id;
      TOOLS.check_record_src(l_rec_src);

      update NDI_NRR_CONFIG
         set NRUC_NRR = p_NRUC_NRR,
             NRUC_NST = p_NRUC_NST,
             NRUC_SQL = p_NRUC_SQL,
             NRUC_SQL_INFO = p_NRUC_SQL_INFO,
             NRUC_IS_VISIBLE = p_NRUC_IS_VISIBLE,
             NRUC_START_DT = p_NRUC_START_DT,
             NRUC_STOP_DT = p_NRUC_STOP_DT
       where NRUC_ID = p_NRUC_ID;

       API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NRR_CONFIG',
                                       p_ncl_action => 'U',
                                       p_ncl_hs => l_hs,
                                       p_ncl_record_id => p_New_Id
                                      );
    end if;
  */
  end;

  PROCEDURE set_reject_reason(p_njr_id    IN ndi_reject_reason.njr_id%TYPE,
                              p_njr_code  IN ndi_reject_reason.njr_code%TYPE,
                              p_njr_name  IN ndi_reject_reason.njr_name%TYPE,
                              p_njr_order IN ndi_reject_reason.njr_order%TYPE,
                              p_njr_nst   IN ndi_reject_reason.njr_nst%TYPE,
                              p_new_id    OUT ndi_reject_reason.njr_id%TYPE) IS
   l_cnt NUMBER(10);
  BEGIN
    Tools.Check_User_And_Raise(99);

    --#77115  20220512
    IF p_njr_code IS NULL THEN
      raise_application_error(-20002, 'Код причини відмови повинен бути заповнений');
    END IF;

    IF  p_njr_id IS NULL THEN
      SELECT COUNT(1) INTO l_cnt
      FROM NDI_REJECT_REASON
      WHERE njr_code = p_njr_code
            AND HISTORY_STATUS = 'A';
    ELSIF  p_njr_id IS NOT NULL THEN
      SELECT COUNT(1) INTO l_cnt
      FROM NDI_REJECT_REASON
      WHERE njr_code = p_njr_code
            AND njr_id != p_njr_id
            AND HISTORY_STATUS = 'A';
    END IF;

    IF l_cnt > 0 THEN
      raise_application_error(-20002, 'Код причини відмови "'||p_njr_code||'" вже присутній в довіднику');
    END IF;

    api$dic_Common.save_reject_reason(p_njr_id         => p_njr_id,
                                      p_njr_code       => p_njr_code,
                                      p_njr_name       => p_njr_name,
                                      p_njr_order      => p_njr_order,
                                      p_njr_nst        => p_njr_nst,
                                      p_new_id         => p_new_id);
  END;

  -- #112746
  PROCEDURE Delete_Ndi_Nrr_Config(p_Nruc_Id IN ndi_nrr_config.nruc_id%TYPE)
  IS
    l_rec_src NDI_NRR_CONFIG.record_src%type;
    l_hs number := tools.GetHistSession;
  BEGIN
    Tools.Check_User_And_Raise(99);

    SELECT t.record_src
      into l_rec_src
      FROM NDI_NRR_CONFIG t
     where t.nruc_id = p_Nruc_Id;
    TOOLS.check_record_src(l_rec_src);

    API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_NRR_CONFIG',
                                    p_ncl_action => 'D',
                                    p_ncl_hs => l_hs,
                                    p_ncl_record_id => p_Nruc_Id,
                                    p_ncl_decription => '&322'
                                   );
    UPDATE ndi_nrr_config t
       SET History_Status = 'H',
           t.nruc_hs_del = l_hs
     WHERE t.nruc_id = p_Nruc_Id;
  END;

  -- #112746
  PROCEDURE DELETE_REJECT_REASON(p_Nrj_Id IN ndi_reject_reason.njr_id%TYPE)
  IS
    l_rec_src Ndi_Reject_Reason.record_src%type;
  BEGIN
    Tools.Check_User_And_Raise(99);

    SELECT t.record_src
      into l_rec_src
      FROM Ndi_Reject_Reason t
     where t.njr_id = p_Nrj_Id;
    TOOLS.check_record_src(l_rec_src);

    api$dic_common.DELETE_REJECT_REASON(p_Nrj_Id);
  END;



  -- #110296
  procedure get_income_setup (p_Res_cur out sys_refcursor)
  is
  begin
    open p_res_cur for
      SELECT *
        FROM ndi_nst_income_config t;
  end;

  -- #110303, #111380
  procedure get_ap_nst_setup (p_ap_tp in varchar2,
                              p_show_All in varchar2,
                              res_cur out sys_refcursor)
  is
  begin
    open res_cur for
      SELECT t.nst_id,
             t.nst_code,
             t.nst_name,
             /*case when (SELECT count(*)
                FROM ndi_ap_nst_config z
               where z.nanc_nst = t.nst_id
                 and z.nanc_ap_tp = p_ap_tp
                 and z.history_status = 'A') > 0 then 'T' else 'F'
             end as nst_Is_Include*/
             c.nanc_id,
             c.history_status as nanc_hist_status,
             c.record_src,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = c.record_src) as record_src_name,
             tools.can_edit_record(c.record_src) as can_Edit_Record
        FROM ndi_service_type t
        join ndi_ap_nst_config c on (c.nanc_nst = t.nst_id)
       where t.history_status = 'A'
         and c.nanc_ap_tp = p_ap_tp
         and (p_show_All = 'T' or nvl(p_show_All, 'F') = 'F' and c.history_status = 'A')
       ;
  end;

  -- #111380
  procedure add_ap_nst_setup (p_at_tp in varchar2,
                              p_nst_id in number)
  is
    l_cnt number;
    l_hs number := tools.GetHistSession;
    l_id number;
  begin
    SELECT count(*)
      into l_cnt
      FROM ndi_ap_nst_config t
     where t.nanc_ap_tp = p_at_tp
       and t.nanc_nst = p_nst_id
       and t.history_status = 'A'
      ;

    if (l_cnt > 0) then
      raise_application_error(-20000, 'Вибрана послуга вже доступна для цього типу звернення!');
    end if;

    insert into ndi_ap_nst_config
      (nanc_ap_tp, nanc_nst, history_status, record_src, nanc_hs_ins )
    values
      (p_at_tp, p_nst_id, 'A', TOOLS.get_record_src, l_hs)
    returning nanc_id into l_id;

    API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_AP_NST_CONFIG',
                                    p_ncl_action => 'C',
                                    p_ncl_hs => l_hs,
                                    p_ncl_record_id => l_id
                                   );
  end;

  -- #111380
  procedure delete_ap_nst_setup (p_nanc_id in number)
  is
    l_hs number := tools.GetHistSession;
    l_rec_src ndi_ap_nst_config.record_src%type;
  begin
    SELECT t.record_src
      into l_rec_src
      FROM ndi_ap_nst_config t
     where t.nanc_id = p_nanc_id
      ;
    tools.check_record_src(l_rec_src);

    update ndi_ap_nst_config t
       set t.history_status = 'H',
           t.nanc_hs_del = l_hs
     where t.nanc_id = p_nanc_id
       and t.history_status = 'A';

    API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_AP_NST_CONFIG',
                                    p_ncl_action => 'D',
                                    p_ncl_hs => l_hs,
                                    p_ncl_record_id => p_nanc_id,
                                    p_ncl_decription => '&322'
                                   );
  end;

  -- #110411
  procedure get_nda_validation (res_cur out sys_refcursor)
  is
  begin
    open res_cur for
      SELECT t.*,
             a.nda_name || ' (' || a.nda_id || ')' as nnv_nda_name
        FROM ndi_nda_validation t
        join ndi_document_attr a on (a.nda_id = t.nnv_nda)
       where 1 = 1;
  end;

  -- #110938
  procedure get_dics_change_log (p_obj_type in varchar2,
                                 p_record_id in number,
                                 info_cur out sys_refcursor,
                                 res_cur out Sys_Refcursor
                                 )
  is
  begin
    open info_cur for
      SELECT (SELECT max(t.comments)
                FROM user_tab_comments t
               where t.table_name = upper(p_obj_type)
             ) as obj_name,
             p_record_id as ncl_record_id
        FROM dual;

    open res_cur for
      SELECT t.ncl_id,
             t.ncl_hs,
             t.ncl_object,
             t.ncl_action,
             t.ncl_record_id,
            rdm$msg_template.Getmessagetext(t.ncl_change_description) as ncl_change_description,
             t.ncl_part,
             (SELECT max(z.DIC_NAME) FROM v_ddn_ncl_action z where z.DIC_VALUE = t.ncl_action) as ncl_action_name,
             hs.hs_dt as ncl_hs_dt,
             tools.GetUserPib(hs.hs_wu) as ncl_hs_pib
        FROM ndi_change_log t
        join histsession hs on (hs.hs_id = t.ncl_hs)
       where t.ncl_object = p_obj_type
         and t.ncl_record_id = p_record_id;
  end;

  ---------------------------------------------
  ------------ NDI_RIGHT_RULES ----------------

  -- #110297, #112728
  procedure get_right_rules (p_nrr_code in varchar2,
                             p_nrr_name in varchar2,
                             p_nrr_tp   in varchar2,
                             p_nrr_ap_tp in varchar2,
                             p_is_critical in varchar2,
                             res_cur out sys_refcursor)
  is
  begin
    Tools.Check_User_And_Raise(99);

    open res_cur for
      SELECT t.*,
             tp.DIC_NAME as nrr_tp_name,
             tpa.DIC_NAME as nrr_ap_tp_name,
             hsi.hs_dt as nrr_hs_ins_dt,
             tools.getuserpib(hsi.hs_wu) as nrr_hs_ins_pib,
             hsd.hs_dt as nrr_hs_del_dt,
             tools.getuserpib(hsd.hs_wu) as nrr_hs_del_pib,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
             tools.can_edit_record(t.record_src) as can_Edit_Record
        FROM ndi_right_rule t
        left join v_ddn_nrr_tp tp on (tp.DIC_VALUE = t.nrr_tp)
        left join v_ddn_ap_tp tpa on (tpa.DIC_VALUE = t.nrr_ap_tp)
        left join histsession hsi on (hsi.hs_id = t.nrr_hs_ins)
        left join histsession hsd on (hsd.hs_id = t.nrr_hs_del)
       where t.history_status = 'A'
         and (p_nrr_code is null or t.nrr_code like p_nrr_code || '%' )
         and (p_nrr_name is null or t.nrr_name like p_nrr_name || '%' )
         and (p_nrr_tp is null or t.nrr_tp = p_nrr_tp)
         and (p_nrr_ap_tp is null or t.nrr_ap_tp = p_nrr_ap_tp)
         and (p_is_critical is null or t.nrr_is_critical_error = p_is_critical)
       ;
  end;

  -- #112728
  procedure get_right_rules_card (p_nrr_id in number,
                                  res_cur out sys_refcursor)
  is
  begin
    Tools.Check_User_And_Raise(99);

    open res_cur for
      SELECT t.*,
             tp.DIC_NAME as nrr_tp_name,
             tpa.DIC_NAME as nrr_ap_tp_name,
             hsi.hs_dt as nrr_hs_ins_dt,
             tools.getuserpib(hsi.hs_wu) as nrr_hs_ins_pib,
             hsd.hs_dt as nrr_hs_del_dt,
             tools.getuserpib(hsd.hs_wu) as nrr_hs_del_pib,
             (SELECT max(z.DIC_NAME) FROM v_ddn_record_src z where z.DIC_VALUE = t.record_src) as record_src_name,
             tools.can_edit_record(t.record_src) as can_Edit_Record
        FROM ndi_right_rule t
        left join v_ddn_nrr_tp tp on (tp.DIC_VALUE = t.nrr_tp)
        left join v_ddn_ap_tp tpa on (tpa.DIC_VALUE = t.nrr_ap_tp)
        left join histsession hsi on (hsi.hs_id = t.nrr_hs_ins)
        left join histsession hsd on (hsd.hs_id = t.nrr_hs_del)
       where t.nrr_id = p_nrr_id;
  end;

  -- #112728
  procedure set_right_rules(p_NRR_ID in NDI_RIGHT_RULE.NRR_ID%type,
                            p_NRR_CODE in NDI_RIGHT_RULE.NRR_CODE%type,
                            p_NRR_NAME in NDI_RIGHT_RULE.NRR_NAME%type,
                            p_NRR_ALG in NDI_RIGHT_RULE.NRR_ALG%type,
                            p_NRR_ORDER in NDI_RIGHT_RULE.NRR_ORDER%type,
                            p_NRR_TP in NDI_RIGHT_RULE.NRR_TP%type,
                            p_NRR_IS_CRITICAL_ERROR in NDI_RIGHT_RULE.NRR_IS_CRITICAL_ERROR%type,
                            p_NRR_AP_TP in NDI_RIGHT_RULE.NRR_AP_TP%type,
                            p_new_id out NDI_RIGHT_RULE.NRR_ID%type)
  is
   l_rec_src ndi_right_rule.record_src%type;
   l_hs number := tools.GetHistSession;
  begin
    Tools.Check_User_And_Raise(99);

    if p_NRR_ID is null then
      insert into NDI_RIGHT_RULE
        (  NRR_CODE,
           NRR_NAME,
           NRR_ALG,
           NRR_ORDER,
           NRR_TP,
           NRR_IS_CRITICAL_ERROR,
           NRR_AP_TP,
           NRR_HS_INS,
           HISTORY_STATUS,
           RECORD_SRC
        )
      values
        (  p_NRR_CODE,
           p_NRR_NAME,
           p_NRR_ALG,
           p_NRR_ORDER,
           p_NRR_TP,
           p_NRR_IS_CRITICAL_ERROR,
           p_NRR_AP_TP,
           l_hs,
           'A',
           TOOLS.get_record_src
        )
      returning NRR_ID into p_new_id;

      API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_RIGHT_RULE',
                                      p_ncl_action => 'C',
                                      p_ncl_hs => l_hs,
                                      p_ncl_record_id => p_New_Id
                                     );
    else
      p_new_id := p_NRR_ID;

      SELECT t.record_src
        into l_rec_src
        FROM ndi_right_rule t
       where t.nrr_id = p_Nrr_Id;
      TOOLS.check_record_src(l_rec_src);

      update NDI_RIGHT_RULE
         set NRR_CODE = p_NRR_CODE,
             NRR_NAME = p_NRR_NAME,
             NRR_ALG = p_NRR_ALG,
             NRR_ORDER = p_NRR_ORDER,
             NRR_TP = p_NRR_TP,
             NRR_IS_CRITICAL_ERROR = p_NRR_IS_CRITICAL_ERROR,
             NRR_AP_TP = p_NRR_AP_TP
       where NRR_ID = p_NRR_ID;

       API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_RIGHT_RULE',
                                       p_ncl_action => 'U',
                                       p_ncl_hs => l_hs,
                                       p_ncl_record_id => p_New_Id
                                      );

    end if;
  end;

  -- #112728
  PROCEDURE Delete_Ndi_Right_Rules(p_Nrr_Id IN ndi_right_rule.Nrr_Id%TYPE)
  IS
    l_hs number := tools.GetHistSession;
    l_rec_src ndi_right_rule.record_src%type;
  BEGIN
    Tools.Check_User_And_Raise(99);

    SELECT t.record_src
      into l_rec_src
      FROM ndi_right_rule t
     where t.nrr_id = p_Nrr_Id;
    TOOLS.check_record_src(l_rec_src);

    API$CHANGE_LOG.write_change_log(p_ncl_object => 'NDI_RIGHT_RULE',
                                    p_ncl_action => 'D',
                                    p_ncl_hs => l_hs,
                                    p_ncl_record_id => p_Nrr_Id,
                                    p_ncl_decription => '&322'
                                   );
    UPDATE ndi_right_rule t
       SET History_Status = 'H',
           t.nrr_hs_del = l_hs
     WHERE Nrr_Id = p_Nrr_Id;
   END;

begin
  null;
end DNET$CONSTRUCTOR;
/