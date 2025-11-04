/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBRC_IKIS_USERS_ATTR_DEL
    BEFORE DELETE
    ON IKIS_SYS.IKIS_USERS_ATTR
    REFERENCING NEW AS new OLD AS old
    FOR EACH ROW
BEGIN
    CHNG_IKIS_USERS_ATTR.DELETE_ESS (:old.IUSR_ID,
                                     :old.IUSR_NAME,
                                     :old.IUSR_NUMIDENT,
                                     :old.IUSR_IS_ADMIN,
                                     :old.IUSR_ST,
                                     :old.IUSR_LOGIN,
                                     :old.IUSR_INTERNAL,
                                     :old.IUSR_START_DT,
                                     :old.IUSR_STOP_DT,
                                     :old.IUSR_ORG,
                                     :old.IUSR_COMP);
END;
/
