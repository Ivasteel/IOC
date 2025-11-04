/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.DIC_DV_MON
    BEFORE INSERT OR UPDATE
    ON IKIS_SYS.DIC_DV
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF INSERTING OR (UPDATING AND :OLD.dic_value <> :NEW.dic_value)
    THEN
        MERGE INTO dic_monitor trg
             USING (SELECT ikis_dd.GetChangeVersion ver, :NEW.dic_didi dic
                      FROM DUAL) src
                ON (src.ver = trg.dm_ver AND src.dic = trg.dm_dic)
        WHEN NOT MATCHED
        THEN
            INSERT     (trg.dm_ver, trg.dm_dic)
                VALUES (src.ver, src.dic);
    END IF;
END DIC_DD_MON;
/
