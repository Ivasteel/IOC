/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_sc_document
    BEFORE INSERT
    ON uss_person.sc_document
    FOR EACH ROW
BEGIN
    IF (:NEW.scd_id = 0) OR (:NEW.scd_id IS NULL)
    THEN
        :NEW.scd_id := ID_sc_document (:NEW.scd_id);
    END IF;

    IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
        UPPER ('Load$socialcard.sc_document_trg'),
        'SC',
        :new.scd_sc,
           'Insert. SCD_ID='
        || :new.scd_id
        || ', SCD_SERIA='
        || :new.scd_seria
        || ', SCD_NUMBER='
        || :new.scd_number
        || ', SCD_NDT='
        || :new.scd_ndt
        || ', SCD_ST='
        || :new.scd_st,
        DBMS_UTILITY.format_call_stack ());
END;
/
