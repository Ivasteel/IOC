/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.DEVS_PATCH_RESDAT
AS
    CURSOR C IS
        SELECT DISTINCT adr_sys     AS SYS
          FROM APPT_DEL_RES;
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE ADP( ID DECIMAL(10,0) CONSTRAINT XPK_ADP PRIMARY KEY, ARD_ID  DECIMAL(10,0))';

    FOR rec IN c
    LOOP
        EXECUTE IMMEDIATE 'DELETE FROM ADP WHERE 1=1';

        EXECUTE IMMEDIATE 'CREATE SEQUENCE DEVS_TTTT START WITH 1 INCREMENT BY 1';

        EXECUTE IMMEDIATE   'insert into adp select DEVS_TTTT.NEXTVAL ,ard_id '
                         || 'from  appt_res_data, appt_res_elem, appt_del_res '
                         || 'where ard_are = are_id and are_adr = adr_id and adr_sys = :1'
            USING rec.sys;

        EXECUTE IMMEDIATE 'set constraints all deferred';

        EXECUTE IMMEDIATE   'update appt_res_data '
                         || 'set ard_id = (select id+ :1 * 100000 from adp where adp.ard_id = appt_res_data.ard_id) '
                         || 'where ard_id in (select ard_id from adp)'
            USING rec.sys;

        EXECUTE IMMEDIATE 'DROP SEQUENCE DEVS_TTTT';
    END LOOP;

    EXECUTE IMMEDIATE 'drop table adp';
--  EXCEPTION WHEN OTHERS THEN dbms_output.put_line(sqlerrm);
END DEVS_PATCH_RESDAT;
/


GRANT EXECUTE ON IKIS_SYS.DEVS_PATCH_RESDAT TO II01RC_IKIS_DESIGN
/
