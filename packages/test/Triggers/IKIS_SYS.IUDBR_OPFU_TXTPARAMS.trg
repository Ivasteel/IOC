/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IUDBR_OPFU_TXTPARAMS
    BEFORE INSERT OR UPDATE OR DELETE
    ON ikis_sys.opfu_txtparams
    FOR EACH ROW
    DISABLE
BEGIN
    CASE
        WHEN INSERTING
        THEN
            -- +Frolov 20091229 добавил поле org_tel_contact
            EXECUTE IMMEDIATE '
        insert into opfu_txtparams@ikis$opfu
          (org_id, org_adr, org_pib_upr, org_tel_upr, org_pib_dox,
           org_tel_dox, org_pib_pers, org_tel_pers, org_pib_pens,
           org_tel_pens, org_pib_admin, org_tel_admin,
           org_email, org_upd_user, org_accnum, org_mfo,
           org_bank_sname, org_bank_name, org_numident,
           org_post_code, org_post_sname, org_post_name, org_tel_contact)
        values
          (:p_org_id, :p_org_adr, :p_org_pib_upr, :p_org_tel_upr, :p_org_pib_dox,
           :p_org_tel_dox, :p_org_pib_pers, :p_org_tel_pers, :p_org_pib_pens,
           :p_org_tel_pens, :p_org_pib_admin, :p_org_tel_admin, :p_org_email,
           :p_org_upd_user, :p_org_accnum, :p_org_mfo, :p_org_bank_sname,
           :p_org_bank_name, :p_org_numident, :p_org_post_code,
           :p_org_post_sname, :p_org_post_name, :p_org_tel_contact) '
                USING :NEW.org_id,
                      :NEW.org_adr,
                      :NEW.org_pib_upr,
                      :NEW.org_tel_upr,
                      :NEW.org_pib_dox,
                      :NEW.org_tel_dox,
                      :NEW.org_pib_pers,
                      :NEW.org_tel_pers,
                      :NEW.org_pib_pens,
                      :NEW.org_tel_pens,
                      :NEW.org_pib_admin,
                      :NEW.org_tel_admin,
                      :NEW.org_email,
                      :NEW.org_upd_user,
                      :NEW.org_accnum,
                      :NEW.org_mfo,
                      :NEW.org_bank_sname,
                      :NEW.org_bank_name,
                      :NEW.org_numident,
                      :NEW.org_post_code,
                      :NEW.org_post_sname,
                      :NEW.org_post_name,
                      :NEW.org_tel_contact;
        -- -Frolov 20091229
        WHEN UPDATING
        THEN
            EXECUTE IMMEDIATE '
        update opfu_txtparams@ikis$opfu 
           set org_adr       = :p_org_adr,
               org_pib_upr   = :p_org_pib_upr,
               org_tel_upr   = :p_org_tel_upr,
               org_pib_dox   = :p_org_pib_dox,
               org_tel_dox   = :p_org_tel_dox,
               org_pib_pers  = :p_org_pib_pers,
               org_tel_pers  = :p_org_tel_pers,
               org_pib_pens  = :p_org_pib_pens,
               org_tel_pens  = :p_org_tel_pens,
               org_pib_admin = :p_org_pib_admin,
               org_tel_admin = :p_org_tel_admin,
               org_email     = :p_org_email,
               org_upd_user  = :p_org_upd_user,
               org_upd_date  = :p_org_upd_date,
               org_accnum    = :p_org_accnum,
               org_mfo       = :p_org_mfo,
               org_bank_sname= :p_org_bank_sname,
               org_bank_name = :p_org_bank_name,
               org_numident  = :p_org_numident,
               org_post_code = :p_org_post_code,
               org_post_sname= :p_org_post_sname,
               org_post_name = :p_org_post_name,
               org_tel_contact = :p_org_tel_contact  
         where org_id = :p_org_id '
                USING :NEW.org_adr,
                      :NEW.org_pib_upr,
                      :NEW.org_tel_upr,
                      :NEW.org_pib_dox,
                      :NEW.org_tel_dox,
                      :NEW.org_pib_pers,
                      :NEW.org_tel_pers,
                      :NEW.org_pib_pens,
                      :NEW.org_tel_pens,
                      :NEW.org_pib_admin,
                      :NEW.org_tel_admin,
                      :NEW.org_email,
                      :NEW.org_upd_user,
                      :NEW.org_upd_date,
                      :NEW.org_accnum,
                      :NEW.org_mfo,
                      :NEW.org_bank_sname,
                      :NEW.org_bank_name,
                      :NEW.org_numident,
                      :NEW.org_post_code,
                      :NEW.org_post_sname,
                      :NEW.org_post_name,
                      :NEW.org_tel_contact,
                      :NEW.org_id;
        -- -Frolov 20091229
        WHEN DELETING
        THEN
            raise_application_error (-20000, 'Функція не підтримується!');
        ELSE
            raise_application_error (
                -20000,
                'Невизначена дія! Зверніться до розробника.');
    END CASE;
END IUDBR_OPFU_TXTPARAMS;
/
