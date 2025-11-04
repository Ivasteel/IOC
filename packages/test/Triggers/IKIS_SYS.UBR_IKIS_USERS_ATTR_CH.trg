/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.UBR_ikis_users_attr_CH
    BEFORE UPDATE OF iusr_name, iusr_numident
    ON IKIS_SYS.IKIS_USERS_ATTR
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
BEGIN
    IF :OLD.iusr_name = :NEW.iusr_name
    THEN
        NULL;
    ELSE
        ikis_changes_utl.savedata (
            p_actid   => ikis_const.V_DDS_USR_AU_2,
            p_ibj     => ikis_const.dic_v_dds_usr_au,
            p_ibjid   => :NEW.iusr_id,
            p_par1    =>
                'OLD=' || :OLD.iusr_name || '; NEW=' || :NEW.iusr_name);
    END IF;

    IF :OLD.iusr_numident = :NEW.iusr_numident
    THEN
        NULL;
    ELSE
        ikis_changes_utl.savedata (
            p_actid   => ikis_const.V_DDS_USR_AU_3,
            p_ibj     => ikis_const.dic_v_dds_usr_au,
            p_ibjid   => :NEW.iusr_id,
            p_par1    =>
                   'OLD='
                || :OLD.iusr_numident
                || '; NEW='
                || :NEW.iusr_numident);
    END IF;
END;
/
