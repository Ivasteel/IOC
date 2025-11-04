/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.trg_recipient_mail
    BEFORE UPDATE
    ON ikis_rbm.RECIPIENT_MAIL
    FOR EACH ROW
DECLARE
    l_wu   NUMBER := ikis_rbm.ikis_rbm_context.GetContext ('UID');
    ldt    DATE := SYSDATE;
BEGIN
    INSERT INTO rbm_audit
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_NAME',
               1,
               :old.rm_name,
               :new.rm_name,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (TO_CHAR (:old.rm_name), '-1') <>
               COALESCE (TO_CHAR (:new.rm_name), '-1');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_MFO',
               1,
               :old.rm_mfo,
               :new.rm_mfo,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (TO_CHAR (:old.rm_mfo), '-1') <>
               COALESCE (TO_CHAR (:new.rm_mfo), '-1');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_FILIA',
               1,
               :old.rm_filia,
               :new.rm_filia,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (:old.rm_filia, '-$') <>
               COALESCE (:new.rm_filia, '-$');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_MAIL',
               1,
               :old.rm_mail,
               :new.rm_mail,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (:old.rm_mail, '-$') <> COALESCE (:new.rm_mail, '-$');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_ST',
               1,
               :old.rm_st,
               :new.rm_st,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (:old.rm_st, '-$') <> COALESCE (:new.rm_st, '-$');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'RM_CERT',
               1,
               DBMS_CRYPTO.HASH (:old.RM_CERT, 2),
               DBMS_CRYPTO.HASH (:new.RM_CERT, 2),
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (tools.hash_md5 (:old.RM_CERT), '###') <>
               COALESCE (tools.hash_md5 (:new.RM_CERT), '###');

    INSERT INTO RBM_AUDIT
        SELECT 'RECIPIENT_MAIL',
               :old.rm_id,
               'COM_ORG',
               1,
               :old.com_org,
               :new.com_org,
               ldt,
               l_wu
          FROM DUAL
         WHERE COALESCE (TO_CHAR (:old.com_org), '-1') <>
               COALESCE (TO_CHAR (:new.com_org), '-1');
END;
/
