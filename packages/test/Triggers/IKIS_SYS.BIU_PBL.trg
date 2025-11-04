/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.BIU_PBL
    BEFORE INSERT OR UPDATE OR DELETE
    ON IKIS_SYS.IKIS_PATCH_REP
    FOR EACH ROW
DECLARE
    l_cnt   NUMBER;
BEGIN
    IF INSERTING
    THEN
        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_patch_bl
         WHERE pbl_num = :NEW.ip_number;
    ELSIF UPDATING
    THEN
        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_patch_bl
         WHERE pbl_num = :NEW.ip_number OR pbl_num = :OLD.ip_number;
    ELSIF DELETING
    THEN
        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_patch_bl
         WHERE pbl_num = :OLD.ip_number;
    END IF;

    IF l_cnt > 0
    THEN
        raise_application_error (-20000, 'Patch blocked.');
    END IF;
END BIU_PBL;
/
