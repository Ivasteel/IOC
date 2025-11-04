/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_PT
IS
    -- Author  : YURA_A
    -- Created : 20.04.2006 17:58:30
    -- Purpose : Perfomance control

    PROCEDURE GatherReplBufferStat;
END IKIS_PT;
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_PT
IS
    PROCEDURE GatherReplBufferStat
    IS
    BEGIN
        ikis_file_job_pkg.savejobmessage (
            'I',
            'Початок збору статистики по буферам IKIS_REPL');

        EXECUTE IMMEDIATE 'alter session set NLS_TERRITORY = ''AMERICA''';

        DBMS_STATS.gather_schema_stats (ownname   => 'IKIS_REPL',
                                        cascade   => TRUE);
        ikis_file_job_pkg.savejobmessage (
            'I',
            'Завершення збору статистики по буферам IKIS_REPL');
    END;
END IKIS_PT;
/