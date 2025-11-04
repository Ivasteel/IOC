/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBRC_IKIS_USERS_ATTR_UPD
    AFTER UPDATE
    ON IKIS_SYS.IKIS_USERS_ATTR
    REFERENCING NEW AS new OLD AS old
    FOR EACH ROW
BEGIN
    CHNG_IKIS_USERS_ATTR.UPDATE_ESS (:old.IUSR_ID,
                                     :new.IUSR_ID,
                                     :old.IUSR_NAME,
                                     :new.IUSR_NAME,
                                     :old.IUSR_NUMIDENT,
                                     :new.IUSR_NUMIDENT,
                                     :old.IUSR_IS_ADMIN,
                                     :new.IUSR_IS_ADMIN,
                                     :old.IUSR_ST,
                                     :new.IUSR_ST,
                                     :old.IUSR_LOGIN,
                                     :new.IUSR_LOGIN,
                                     :old.IUSR_INTERNAL,
                                     :new.IUSR_INTERNAL,
                                     :old.IUSR_START_DT,
                                     :new.IUSR_START_DT,
                                     :old.IUSR_STOP_DT,
                                     :new.IUSR_STOP_DT,
                                     :old.IUSR_ORG,
                                     :new.IUSR_ORG,
                                     :old.IUSR_COMP,
                                     :new.IUSR_COMP);
END;
/
