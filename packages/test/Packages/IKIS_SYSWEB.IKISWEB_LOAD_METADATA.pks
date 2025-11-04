/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.ikisweb_load_metadata
    AUTHID CURRENT_USER
IS
    -- Author  : YURA_A
    -- Created : 31.05.2007 15:42:04
    -- Purpose :

    -- Public type declarations
    PROCEDURE loadmetadata;
END ikisweb_load_metadata;
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.ikisweb_load_metadata
IS
    PROCEDURE loadmetadata
    IS
    BEGIN
        EXECUTE IMMEDIATE   'merge into ikis_sysweb.w_job_type trg using load_w_job_type src '
                         || 'on (src.wjt_id=trg.wjt_id) '
                         || 'when matched then update set '
                         || '       trg.wjt_apex_app = src.wjt_apex_app, '
                         || '       trg.wjt_apex_page = src.wjt_apex_page, '
                         || '       trg.wjt_is_reg_lock = src.wjt_is_reg_lock, '
                         || '       trg.wjt_is_user_lock = src.wjt_is_user_lock, '
                         || '       trg.wjt_content_type = src.wjt_content_type, '
                         || '       trg.wjt_file_name = src.wjt_file_name, '
                         || '       trg.wjt_concur_cnt_lock = src.wjt_concur_cnt_lock, '
                         || '       trg.wjt_descr = src.wjt_descr '
                         || 'when not matched then insert  '
                         || '  (trg.wjt_id, trg.wjt_apex_app, trg.wjt_apex_page, trg.wjt_is_reg_lock, trg.wjt_is_user_lock, trg.wjt_content_type, trg.wjt_file_name, trg.wjt_concur_cnt_lock, trg.wjt_descr) '
                         || 'values '
                         || '  (src.wjt_id, src.wjt_apex_app, src.wjt_apex_page, src.wjt_is_reg_lock, src.wjt_is_user_lock, src.wjt_content_type, src.wjt_file_name, src.wjt_concur_cnt_lock, src.wjt_descr)';
    END;
END ikisweb_load_metadata;
/