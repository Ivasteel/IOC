/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.DIC_TBL_MON
    BEFORE INSERT OR UPDATE
    ON IKIS_SYS.DIC_TBL
    FOR EACH ROW
DECLARE
-- local variables here
BEGIN
    IF    INSERTING
       OR (    UPDATING
           AND (   :OLD.tbl_fld_name <> :NEW.tbl_fld_name
                OR :OLD.tbl_tbl_name <> :NEW.tbl_tbl_name))
    THEN
        MERGE INTO dic_monitor trg
             USING (SELECT ikis_dd.GetChangeVersion ver, :NEW.tbl_didi dic
                      FROM DUAL) src
                ON (src.ver = trg.dm_ver AND src.dic = trg.dm_dic)
        WHEN NOT MATCHED
        THEN
            INSERT     (trg.dm_ver, trg.dm_dic, trg.dm_table)
                VALUES (src.ver, src.dic, UPPER (:NEW.tbl_tbl_name));
    END IF;

    IF UPDATING AND :OLD.tbl_didi <> :NEW.tbl_didi
    THEN
        MERGE INTO dic_monitor trg
             USING (SELECT ikis_dd.GetChangeVersion ver, :NEW.tbl_didi dic
                      FROM DUAL) src
                ON (src.ver = trg.dm_ver AND src.dic = trg.dm_dic)
        WHEN NOT MATCHED
        THEN
            INSERT     (trg.dm_ver, trg.dm_dic, trg.dm_table)
                VALUES (src.ver, src.dic, UPPER (:NEW.tbl_tbl_name));

        MERGE INTO dic_monitor trg
             USING (SELECT ikis_dd.GetChangeVersion ver, :OLD.tbl_didi dic
                      FROM DUAL) src
                ON (src.ver = trg.dm_ver AND src.dic = trg.dm_dic)
        WHEN NOT MATCHED
        THEN
            INSERT     (trg.dm_ver, trg.dm_dic, trg.dm_table)
                VALUES (src.ver, src.dic, UPPER (:NEW.tbl_tbl_name));
    END IF;
END DIC_DD_MON;
/
