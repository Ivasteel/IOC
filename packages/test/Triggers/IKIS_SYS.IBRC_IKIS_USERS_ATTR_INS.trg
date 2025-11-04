/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBRC_IKIS_USERS_ATTR_INS
    AFTER INSERT
    ON IKIS_SYS.IKIS_USERS_ATTR
    REFERENCING NEW AS new OLD AS old
    FOR EACH ROW
BEGIN
    CHNG_IKIS_USERS_ATTR.INSERT_ESS (:new.IUSR_ID,
                                     :new.IUSR_NAME,
                                     :new.IUSR_NUMIDENT,
                                     :new.IUSR_IS_ADMIN,
                                     :new.IUSR_ST,
                                     :new.IUSR_LOGIN,
                                     :new.IUSR_INTERNAL,
                                     :new.IUSR_START_DT,
                                     :new.IUSR_STOP_DT,
                                     :new.IUSR_ORG,
                                     :new.IUSR_COMP);
END;
/
