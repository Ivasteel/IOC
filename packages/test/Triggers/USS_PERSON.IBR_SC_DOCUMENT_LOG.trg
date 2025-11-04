/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_SC_DOCUMENT_LOG
    BEFORE UPDATE
    ON USS_PERSON.SC_DOCUMENT
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
        UPPER ('Load$socialcard.sc_document_trg'),
        'SC',
        :new.scd_sc,
           'Update. SCD_ID='
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
END IBR_SC_DOCUMENT_LOG;
/
