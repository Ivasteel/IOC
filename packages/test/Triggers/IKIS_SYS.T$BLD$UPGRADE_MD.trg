/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.T$BLD$UPGRADE_MD
    BEFORE UPDATE
    ON IKIS_SYS.BLD$UPGRADE
    FOR EACH ROW
BEGIN
    :NEW.bldu_md_dt := SYSDATE;
    :NEW.bldu_author :=
           'USERENV: '
        || 'SESSION_USER='
        || SYS_CONTEXT ('USERENV', 'SESSION_USER')
        || '; '
        || 'HOST='
        || SYS_CONTEXT ('USERENV', 'HOST')
        || '; '
        || 'IP_ADDRESS='
        || SYS_CONTEXT ('USERENV', 'IP_ADDRESS')
        || '; '
        || 'OS_USER='
        || SYS_CONTEXT ('USERENV', 'OS_USER');
END;
/
