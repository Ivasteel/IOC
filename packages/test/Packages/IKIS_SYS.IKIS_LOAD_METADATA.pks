/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_load_metadata
    AUTHID CURRENT_USER
IS
    -- Author  : YURA_A
    -- Created : 06.09.2003 12:19:54
    -- Purpose : Загрузка метаданных ИКИС при инсталляции

    PROCEDURE LoadIKISMetaData;

    PROCEDURE LoadSRControlMetadata;
END ikis_load_metadata;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_LOAD_METADATA FOR IKIS_SYS.IKIS_LOAD_METADATA
/


GRANT EXECUTE ON IKIS_SYS.IKIS_LOAD_METADATA TO II01RC_IKIS_SUPERUSER
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_load_metadata
IS
    PROCEDURE LoadIKISMetaData
    IS
        --l_cnt number;
        l_script   VARCHAR2 (32760);
    BEGIN
        EXECUTE IMMEDIATE 'set constraint all deferred';

        --Загрузка списка подсистем только при первичной инсталляции
        --+ Автор: YURA_A 05.05.2004 10:11:29
        --  Описание: изменение загрузки списка подсистем
        --  select count(1) into l_cnt from ikis_subsys;
        --  if l_cnt=0 then
        --    l_script:='insert into ikis_subsys select * from load_ikis_subsys';
        --    execute immediate l_script;
        --  end if;

        l_script :=
               'merge into ikis_subsys using (select ss_code, ss_owner, ss_root_role, ss_main, ss_comment, ss_instance_pref, ss_msys_begin, ss_msys_end from load_ikis_subsys) src '
            || 'on (ikis_subsys.ss_code=src.ss_code) '
            || 'when matched then update set '
            || 'ikis_subsys.ss_comment=src.ss_comment, '
            || 'ikis_subsys.ss_msys_begin=src.ss_msys_begin, '
            || 'ikis_subsys.ss_msys_end=src.ss_msys_end '
            || 'when not matched then insert   '
            || '(ss_code, ss_owner, ss_root_role, ss_main, ss_comment, ss_instance_pref, ss_msys_begin, ss_msys_end) '
            || 'values '
            || '(src.ss_code, src.ss_owner,  '
            || 'src.ss_root_role, src.ss_main,  '
            || 'src.ss_comment, src.ss_instance_pref,  '
            || 'src.ss_msys_begin, src.ss_msys_end)';

        EXECUTE IMMEDIATE l_script;

        --- Автор: YURA_A 05.05.2004 10:11:32

        --Загрузка скрипточ и запросов отчетов
        l_script :=
               'merge into ikis_scripts using load_ikis_scripts '
            || 'on (ikis_scripts.isc_code=load_ikis_scripts.isc_code) '
            || 'when matched then update set '
            || 'ikis_scripts.isc_ss_code=load_ikis_scripts.isc_ss_code, '
            || 'ikis_scripts.isc_query=load_ikis_scripts.isc_query, '
            || 'ikis_scripts.isc_where=load_ikis_scripts.isc_where '
            || 'when not matched then insert '
            || '(ISC_SS_CODE,ISC_CODE,ISC_QUERY,ISC_WHERE) '
            || 'values '
            || '(load_ikis_scripts.isc_ss_code, '
            || 'load_ikis_scripts.isc_code, '
            || 'load_ikis_scripts.isc_query, '
            || 'load_ikis_scripts.isc_where) ';

        EXECUTE IMMEDIATE l_script;

        --Категории сообщений
        l_script :=
            'insert into ikis_messcat select * from load_ikis_messcat x where x.imc_name not in (select z.imc_name from ikis_messcat z)';

        EXECUTE IMMEDIATE l_script;

        --Сообщения
        l_script :=
               'merge into ikis_messages using load_ikis_messages '
            || 'on (ikis_messages.IPM_ID=load_ikis_messages.IPM_ID) '
            || 'when matched then update set '
            || 'ikis_messages.IPM_ACTION=load_ikis_messages.IPM_ACTION,ikis_messages.IPM_CATEGORY=load_ikis_messages.IPM_CATEGORY,ikis_messages.IPM_CAUSE=load_ikis_messages.IPM_CAUSE,ikis_messages.IPM_CONSTNAME=load_ikis_messages.IPM_CONSTNAME,ikis_messages.IPM_ECODE=load_ikis_messages.IPM_ECODE,ikis_messages.IPM_MESSAGE=load_ikis_messages.IPM_MESSAGE,ikis_messages.IPM_SS_CODE=load_ikis_messages.IPM_SS_CODE,ikis_messages.IPM_TP=load_ikis_messages.IPM_TP '
            || 'when not matched then insert '
            || '(IPM_ECODE,IPM_ID,IPM_SS_CODE,IPM_TP,IPM_MESSAGE,IPM_CATEGORY,IPM_CAUSE,IPM_ACTION,IPM_CONSTNAME) '
            || 'values '
            || '(load_ikis_messages.IPM_ECODE,load_ikis_messages.IPM_ID,load_ikis_messages.IPM_SS_CODE,load_ikis_messages.IPM_TP,load_ikis_messages.IPM_MESSAGE,load_ikis_messages.IPM_CATEGORY,load_ikis_messages.IPM_CAUSE,load_ikis_messages.IPM_ACTION,load_ikis_messages.IPM_CONSTNAME)';

        EXECUTE IMMEDIATE l_script;

        --створюю копію прив'язок ролей до груп
        BEGIN             --yura_ap 2006-05-22 добавим подпорку к кривульке :)
            EXECUTE IMMEDIATE 'drop table old_ikis_role2group';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        l_script :=
               'create table old_ikis_role2group as select * from ikis_role2group x1 '
            || 'where (irg2g_irl in (select irl_name from load_ikis_role) '
            || '   or irg2g_igrp in (select igrp_name from load_ikis_group)) and '
            || '   not exists (select 1 from load_ikis_role2group x2 '
            || '               where x1.irg2g_irl=x2.irg2g_irl '
            || '                 and x1.irg2g_igrp=x2.irg2g_igrp)';

        EXECUTE IMMEDIATE l_script;

        EXECUTE IMMEDIATE 'set constraint all deferred';

        --Вилучення прив'язки ролей до груп
        l_script :=
               'delete from ikis_role2group '
            || 'where irg2g_igrp in (select igrp_name from ikis_group '
            || '                     where igrp_ss_code in (select igrp_ss_code from load_ikis_group)) '
            || '   or irg2g_irl in (select irl_name from ikis_role '
            || '                    where irl_ss_code in (select irl_ss_code from load_ikis_role))';

        EXECUTE IMMEDIATE l_script;

        --Вилучення груп
        l_script :=
            'delete from ikis_group where igrp_ss_code in (select igrp_ss_code from load_ikis_group)';

        EXECUTE IMMEDIATE l_script;

        --Вилучення прив'язки ресурсів до груп
        l_script :=
               'delete from ikis_rsrc2role '
            || 'where rs2r_irl in (select irl_name from ikis_role '
            || '                   where irl_ss_code in (select irl_ss_code from load_ikis_role))';

        EXECUTE IMMEDIATE l_script;

        --Вилучення ролей
        l_script :=
            'delete from ikis_role where irl_ss_code in (select irl_ss_code from load_ikis_role)';

        EXECUTE IMMEDIATE l_script;

        --Ресурсы доступа:
        --Вилучення атрибутів ресурсів
        l_script :=
               'delete from ikis_rsrc_attr '
            || 'where rat_rsrc in (select rsrc_name from ikis_resource '
            || '                   where rsrc_ss_code in (select rsrc_ss_code from load_ikis_resource))';

        EXECUTE IMMEDIATE l_script;

        --Вилучення ресурсів
        l_script :=
               'delete from ikis_resource '
            || 'where rsrc_ss_code in (select rsrc_ss_code from load_ikis_resource)';

        EXECUTE IMMEDIATE l_script;

        --Ресурси
        l_script :=
               'insert into ikis_resource (rsrc_name, rsrc_ss_code, rsrc_msys, rsrc_tp) '
            || 'select rsrc_name, rsrc_ss_code, rsrc_msys, rsrc_tp from load_ikis_resource';

        EXECUTE IMMEDIATE l_script;

        --Аттрибуты ресурсов
        l_script :=
               'insert into ikis_rsrc_attr (RAT_RSRC,RAT_TP,RAT_OBJECT_NAME,RAT_OBJECT_TP) '
            || 'select RAT_RSRC,RAT_TP,RAT_OBJECT_NAME,RAT_OBJECT_TP from load_ikis_rsrc_attr';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'insert into ikis_role(IRL_NAME,IRL_SS_CODE,IRL_COMMENT,IRL_MSYS) '
            || 'select IRL_NAME,IRL_SS_CODE,IRL_COMMENT,IRL_MSYS from load_ikis_role';

        EXECUTE IMMEDIATE l_script;

        -- Ресурсы ролям присваиваются так
        l_script :=
               'insert into ikis_rsrc2role (rs2r_rsrc,rs2r_irl) '
            || '     select x.rs2r_rsrc,x.rs2r_irl from load_ikis_rsrc2role x '
            || '      where (x.rs2r_rsrc,x.rs2r_irl) not in (select rs2r_rsrc,rs2r_irl from ikis_rsrc2role)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'insert into ikis_group(igrp_name, igrp_ss_code, igrp_comment, igrp_msys) '
            || 'select igrp_name, igrp_ss_code, igrp_comment, igrp_msys from load_ikis_group';

        EXECUTE IMMEDIATE l_script;

        -- Ресурсы ролям присваиваются так
        l_script :=
               'insert into ikis_role2group(irg2g_irl, irg2g_igrp) '
            || ' select irg2g_irl, irg2g_igrp from load_ikis_role2group';

        EXECUTE IMMEDIATE l_script;

        --Відновлення прив'язки ролей до груп
        l_script :=
               'insert into ikis_role2group(irg2g_irl, irg2g_igrp) '
            || 'select irg2g_irl, irg2g_igrp from old_ikis_role2group';

        EXECUTE IMMEDIATE l_script;

        --Очередь заданий - задачи
        l_script :=
               'merge into file_type using load_file_type '
            || 'on (file_type.FT_ID=load_file_type.FT_ID) '
            || 'when matched then update set '
            || 'file_type.FT_MODE=load_file_type.FT_MODE,file_type.FT_NOTE=load_file_type.FT_NOTE,file_type.FT_PKG_NAME=load_file_type.FT_PKG_NAME,file_type.FT_PROC_NAME=load_file_type.FT_PROC_NAME,file_type.FT_SS_CODE=load_file_type.FT_SS_CODE,file_type.FT_TP=load_file_type.FT_TP,file_type.FT_TP_USR=load_file_type.FT_TP_USR '
            || 'when not matched then insert '
            || '(FT_SS_CODE,FT_ID,FT_PKG_NAME,FT_PROC_NAME,FT_TP,FT_NOTE,FT_MODE,FT_TP_USR) '
            || 'values '
            || '(load_file_type.FT_SS_CODE,load_file_type.FT_ID,load_file_type.FT_PKG_NAME,load_file_type.FT_PROC_NAME,load_file_type.FT_TP,load_file_type.FT_NOTE,load_file_type.FT_MODE,load_file_type.FT_TP_USR)';

        EXECUTE IMMEDIATE l_script;

        --Очередь заданий - параметры заданий
        l_script :=
               'merge into file_type_parameter using load_file_type_parameter '
            || 'on (file_type_parameter.FTP_ID=load_file_type_parameter.FTP_ID) '
            || 'when matched then update set '
            || 'file_type_parameter.FTP_CALLSPEC=load_file_type_parameter.FTP_CALLSPEC,file_type_parameter.FTP_DATA_FMT=load_file_type_parameter.FTP_DATA_FMT,file_type_parameter.FTP_DATA_FMT_D=load_file_type_parameter.FTP_DATA_FMT_D,file_type_parameter.FTP_DATA_TYPE=load_file_type_parameter.FTP_DATA_TYPE,file_type_parameter.FTP_DEFVALUE=load_file_type_parameter.FTP_DEFVALUE,file_type_parameter.FTP_FT=load_file_type_parameter.FTP_FT,file_type_parameter.FTP_MANDATORY=load_file_type_parameter.FTP_MANDATORY,file_type_parameter.FTP_NAME=load_file_type_parameter.FTP_NAME '
            || 'when not matched then insert '
            || '(FTP_ID,FTP_FT,FTP_NAME,FTP_DATA_TYPE,FTP_CALLSPEC,FTP_DEFVALUE,FTP_DATA_FMT,FTP_DATA_FMT_D,FTP_MANDATORY) '
            || 'values '
            || '(load_file_type_parameter.FTP_ID,load_file_type_parameter.FTP_FT,load_file_type_parameter.FTP_NAME,load_file_type_parameter.FTP_DATA_TYPE,load_file_type_parameter.FTP_CALLSPEC,load_file_type_parameter.FTP_DEFVALUE,load_file_type_parameter.FTP_DATA_FMT,load_file_type_parameter.FTP_DATA_FMT_D,load_file_type_parameter.FTP_MANDATORY)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into ikis_parameters using load_ikis_parameters '
            || 'on (ikis_parameters.PAR_CODE=load_ikis_parameters.PAR_CODE and '
            || 'ikis_parameters.PAR_SS_CODE=load_ikis_parameters.PAR_SS_CODE) '
            || 'when matched then update set '
            || 'ikis_parameters.PAR_COMMENT=load_ikis_parameters.PAR_COMMENT,ikis_parameters.PAR_DT=load_ikis_parameters.PAR_DT,ikis_parameters.PAR_TP=load_ikis_parameters.PAR_TP,ikis_parameters.PAR_VALUE=load_ikis_parameters.PAR_VALUE, '
            || 'ikis_parameters.par_def=load_ikis_parameters.par_def '
            || 'when not matched then insert '
            || '(PAR_CODE,PAR_SS_CODE,PAR_VALUE,PAR_TP,PAR_DT,PAR_COMMENT,par_def) '
            || 'values '
            || '(load_ikis_parameters.PAR_CODE,load_ikis_parameters.PAR_SS_CODE,load_ikis_parameters.par_def,load_ikis_parameters.PAR_TP,sysdate,load_ikis_parameters.PAR_COMMENT,load_ikis_parameters.par_def)';

        --Внимание здесь дефолтное значение инсертится в значение параметра
        EXECUTE IMMEDIATE l_script;

        --Завантаження типів протоколів
        l_script :=
               'merge into ikis_prot_type using load_ikis_prot_type '
            || 'on (ikis_prot_type.type_id=load_ikis_prot_type.type_id) '
            || 'when matched then update '
            || 'set ikis_prot_type.type_ss_code=load_ikis_prot_type.type_ss_code, '
            || '    ikis_prot_type.type_code=load_ikis_prot_type.type_code, '
            || '    ikis_prot_type.type_desc=load_ikis_prot_type.type_desc '
            || 'when not matched then '
            || 'insert (ikis_prot_type.type_id, ikis_prot_type.type_ss_code,  '
            || '        ikis_prot_type.type_code, ikis_prot_type.type_desc)   '
            || 'values(load_ikis_prot_type.type_id, load_ikis_prot_type.type_ss_code,  '
            || '       load_ikis_prot_type.type_code, load_ikis_prot_type.type_desc)';

        EXECUTE IMMEDIATE l_script;


        l_script :=
               'merge into ikis_ess_aud_code using load_ikis_ess_aud_code '
            || 'on (ikis_ess_aud_code.ead_id=load_ikis_ess_aud_code.ead_id) '
            || 'when matched then update '
            || 'set ikis_ess_aud_code.ead_ss_code=load_ikis_ess_aud_code.ead_ss_code, '
            || '    ikis_ess_aud_code.ead_table=load_ikis_ess_aud_code.ead_table, '
            || '    ikis_ess_aud_code.ead_fields=load_ikis_ess_aud_code.ead_fields, '
            || '    ikis_ess_aud_code.ead_chield_sql=load_ikis_ess_aud_code.ead_chield_sql, '
            || '    ikis_ess_aud_code.ead_name=load_ikis_ess_aud_code.ead_name, '
            || '    ikis_ess_aud_code.ead_ead=load_ikis_ess_aud_code.ead_ead '
            || 'when not matched then '
            || 'insert (ikis_ess_aud_code.ead_id, ikis_ess_aud_code.ead_ss_code, ikis_ess_aud_code.ead_table, ikis_ess_aud_code.ead_fields, ikis_ess_aud_code.ead_name, ikis_ess_aud_code.ead_ead, ikis_ess_aud_code.ead_chield_sql) '
            || 'values (load_ikis_ess_aud_code.ead_id, load_ikis_ess_aud_code.ead_ss_code, load_ikis_ess_aud_code.ead_table, load_ikis_ess_aud_code.ead_fields, load_ikis_ess_aud_code.ead_name, load_ikis_ess_aud_code.ead_ead, load_ikis_ess_aud_code.ead_chield_sql)';

        EXECUTE IMMEDIATE l_script;

        l_script := 'drop table old_ikis_role2group';

        EXECUTE IMMEDIATE l_script;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Error in LoadIKISMetaData: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || l_script);
    END;

    PROCEDURE LoadSRControlMetadata
    IS
        l_script   VARCHAR2 (32760);
    BEGIN
        EXECUTE IMMEDIATE 'set constraint all deferred';

        l_script :=
               'merge into sr_essences using load_sr_essences '
            || 'on (sr_essences.ES_CODE=load_sr_essences.ES_CODE) '
            || 'when matched then update set '
            || 'sr_essences.ES_REM=load_sr_essences.ES_REM,sr_essences.ES_SS_CODE=load_sr_essences.ES_SS_CODE,sr_essences.ES_TABLE=load_sr_essences.ES_TABLE '
            || 'when not matched then insert '
            || '(ES_CODE,ES_TABLE,ES_REM,ES_SS_CODE) '
            || 'values '
            || '(load_sr_essences.ES_CODE,load_sr_essences.ES_TABLE,load_sr_essences.ES_REM,load_sr_essences.ES_SS_CODE)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_groups using load_sr_groups '
            || 'on (sr_groups.GRP_ID=load_sr_groups.GRP_ID) '
            || 'when matched then update set '
            || 'sr_groups.GRP_ES=load_sr_groups.GRP_ES,sr_groups.GRP_FIELDSSQL=load_sr_groups.GRP_FIELDSSQL,sr_groups.GRP_INITSQL=load_sr_groups.GRP_INITSQL,sr_groups.GRP_NAME=load_sr_groups.GRP_NAME,sr_groups.GRP_OBJ_NAME=load_sr_groups.GRP_OBJ_NAME '
            || 'when not matched then insert '
            || '(GRP_ID,GRP_NAME,GRP_ES,GRP_OBJ_NAME,GRP_FIELDSSQL,GRP_INITSQL) '
            || 'values '
            || '(load_sr_groups.GRP_ID,load_sr_groups.GRP_NAME,load_sr_groups.GRP_ES,load_sr_groups.GRP_OBJ_NAME,load_sr_groups.GRP_FIELDSSQL,load_sr_groups.GRP_INITSQL)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_group_links using load_sr_group_links '
            || 'on (sr_group_links.GRPL_ID=load_sr_group_links.GRPL_ID) '
            || 'when matched then update set '
            || 'sr_group_links.GRPL_CNTRSQL=load_sr_group_links.GRPL_CNTRSQL,sr_group_links.GRPL_GRP_DEPEND=load_sr_group_links.GRPL_GRP_DEPEND,sr_group_links.GRPL_GRP_MASTER=load_sr_group_links.GRPL_GRP_MASTER,sr_group_links.GRPL_NAME=load_sr_group_links.GRPL_NAME,sr_group_links.GRPL_ORD=load_sr_group_links.GRPL_ORD,sr_group_links.GRPL_USETOFINAL=load_sr_group_links.GRPL_USETOFINAL '
            || 'when not matched then insert '
            || '(GRPL_ID,GRPL_GRP_MASTER,GRPL_NAME,GRPL_GRP_DEPEND,GRPL_ORD,GRPL_CNTRSQL,GRPL_USETOFINAL) '
            || 'values '
            || '(load_sr_group_links.GRPL_ID,load_sr_group_links.GRPL_GRP_MASTER,load_sr_group_links.GRPL_NAME,load_sr_group_links.GRPL_GRP_DEPEND,load_sr_group_links.GRPL_ORD,load_sr_group_links.GRPL_CNTRSQL,load_sr_group_links.GRPL_USETOFINAL)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_groups_msg using load_sr_groups_msg '
            || 'on (sr_groups_msg.GM_IPM=load_sr_groups_msg.GM_IPM) '
            || 'when matched then update set '
            || 'sr_groups_msg.GM_GRP=load_sr_groups_msg.GM_GRP,sr_groups_msg.GM_MSG_TYPE=load_sr_groups_msg.GM_MSG_TYPE,sr_groups_msg.GM_NUMBER=load_sr_groups_msg.GM_NUMBER,sr_groups_msg.GM_ORDER=load_sr_groups_msg.GM_ORDER '
            || 'when not matched then insert '
            || '(GM_IPM,GM_GRP,GM_MSG_TYPE,GM_NUMBER,GM_ORDER) '
            || 'values '
            || '(load_sr_groups_msg.GM_IPM,load_sr_groups_msg.GM_GRP,load_sr_groups_msg.GM_MSG_TYPE,load_sr_groups_msg.GM_NUMBER,load_sr_groups_msg.GM_ORDER)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_controls using load_sr_controls '
            || 'on (sr_controls.CNTR_ID=load_sr_controls.CNTR_ID) '
            || 'when matched then update set '
            || 'sr_controls.CNTR_CNTRCOND=load_sr_controls.CNTR_CNTRCOND,sr_controls.CNTR_CODESQL=load_sr_controls.CNTR_CODESQL,sr_controls.CNTR_CODE_TYPE=load_sr_controls.CNTR_CODE_TYPE,sr_controls.CNTR_GRP=load_sr_controls.CNTR_GRP,sr_controls.CNTR_NAME=load_sr_controls.CNTR_NAME,sr_controls.CNTR_NUMBER=load_sr_controls.CNTR_NUMBER,sr_controls.CNTR_ORDER=load_sr_controls.CNTR_ORDER,sr_controls.CNTR_PRECODE=load_sr_controls.CNTR_PRECODE,sr_controls.CNTR_PRECOND=load_sr_controls.CNTR_PRECOND,sr_controls.CNTR_STATUS=load_sr_controls.CNTR_STATUS,sr_controls.CNTR_STOP_CNTR=load_sr_controls.CNTR_STOP_CNTR '
            || 'when not matched then insert '
            || '(CNTR_ID,CNTR_GRP,CNTR_NAME,CNTR_NUMBER,CNTR_CODE_TYPE,CNTR_ORDER,CNTR_PRECOND,CNTR_CODESQL,CNTR_CNTRCOND,CNTR_STATUS,CNTR_PRECODE,CNTR_STOP_CNTR) '
            || 'values '
            || '(load_sr_controls.CNTR_ID,load_sr_controls.CNTR_GRP,load_sr_controls.CNTR_NAME,load_sr_controls.CNTR_NUMBER,load_sr_controls.CNTR_CODE_TYPE,load_sr_controls.CNTR_ORDER,load_sr_controls.CNTR_PRECOND,load_sr_controls.CNTR_CODESQL,load_sr_controls.CNTR_CNTRCOND,load_sr_controls.CNTR_STATUS,load_sr_controls.CNTR_PRECODE,load_sr_controls.CNTR_STOP_CNTR)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_control_msg using load_sr_control_msg '
            || 'on (sr_control_msg.MSG_IPM=load_sr_control_msg.MSG_IPM) '
            || 'when matched then update set '
            || 'sr_control_msg.MSG_CNTR=load_sr_control_msg.MSG_CNTR,sr_control_msg.MSG_NUMBER=load_sr_control_msg.MSG_NUMBER,sr_control_msg.MSG_ORDER=load_sr_control_msg.MSG_ORDER,sr_control_msg.MSG_RES_TYPE=load_sr_control_msg.MSG_RES_TYPE '
            || 'when not matched then insert '
            || '(MSG_IPM,MSG_CNTR,MSG_RES_TYPE,MSG_NUMBER,MSG_ORDER) '
            || 'values '
            || '(load_sr_control_msg.MSG_IPM,load_sr_control_msg.MSG_CNTR,load_sr_control_msg.MSG_RES_TYPE,load_sr_control_msg.MSG_NUMBER,load_sr_control_msg.MSG_ORDER)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_msg_params using load_sr_msg_params '
            || 'on (sr_msg_params.GMP_NUM=load_sr_msg_params.GMP_NUM and '
            || 'sr_msg_params.GMP_IPM=load_sr_msg_params.GMP_IPM) '
            || 'when matched then update set '
            || 'sr_msg_params.GMP_PTYPE=load_sr_msg_params.GMP_PTYPE,sr_msg_params.GMP_VALUE=load_sr_msg_params.GMP_VALUE '
            || 'when not matched then insert '
            || '(GMP_NUM,GMP_PTYPE,GMP_VALUE,GMP_IPM) '
            || 'values '
            || '(load_sr_msg_params.GMP_NUM,load_sr_msg_params.GMP_PTYPE,load_sr_msg_params.GMP_VALUE,load_sr_msg_params.GMP_IPM)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'merge into sr_group_final using load_sr_group_final '
            || 'on (sr_group_final.GF_ID=load_sr_group_final.GF_ID) '
            || 'when matched then update set '
            || 'sr_group_final.GF_FINALCODE=load_sr_group_final.GF_FINALCODE,sr_group_final.GF_FINALCOND=load_sr_group_final.GF_FINALCOND,sr_group_final.GF_GRP=load_sr_group_final.GF_GRP,sr_group_final.GF_NUMBER=load_sr_group_final.GF_NUMBER,sr_group_final.GF_SQL=load_sr_group_final.GF_SQL,sr_group_final.gf_msgtype=load_sr_group_final.gf_msgtype '
            || 'when not matched then insert '
            || '(GF_ID,GF_GRP,GF_FINALCOND,GF_NUMBER,GF_SQL,GF_FINALCODE,gf_msgtype) '
            || 'values '
            || '(load_sr_group_final.GF_ID,load_sr_group_final.GF_GRP,load_sr_group_final.GF_FINALCOND,load_sr_group_final.GF_NUMBER,load_sr_group_final.GF_SQL,load_sr_group_final.GF_FINALCODE,load_sr_group_final.gf_msgtype)';

        EXECUTE IMMEDIATE l_script;

        --ryaba
        --Глючит merge  - заменид на delete-insert
        -- l_script:=
        --   'merge into sr_groups_order using load_sr_groups_order '||
        --   'on (sr_groups_order.GRPO_GRP=load_sr_groups_order.GRPO_GRP AND sr_groups_order.GRPO_NUM=load_sr_groups_order.GRPO_NUM) '||
        --   'when matched then update set '||
        --   'sr_groups_order.GRPO_TYPE=load_sr_groups_order.GRPO_TYPE, sr_groups_order.GRPO_NUM=load_sr_groups_order.GRPO_NUM  '||
        --   'when not matched then insert '||
        --   '(GRPO_GRP, GRPO_NUM, GRPO_TYPE, GRPO_VALUE) '||
        --   'values '||
        --   '(load_sr_groups_order.GRPO_GRP, load_sr_groups_order.GRPO_NUM, load_sr_groups_order.GRPO_TYPE, load_sr_groups_order.GRPO_VALUE)';
        l_script :=
               'delete from sr_groups_order '
            || 'where exists(select 1 '
            || '         from load_sr_groups_order '
            || '         where sr_groups_order.GRPO_GRP=load_sr_groups_order.GRPO_GRP AND '
            || '              sr_groups_order.GRPO_NUM=load_sr_groups_order.GRPO_NUM)';

        EXECUTE IMMEDIATE l_script;

        l_script :=
               'insert into sr_groups_order '
            || 'select * from load_sr_groups_order';

        EXECUTE IMMEDIATE l_script;
    --l_script:=
    --  'merge into sr_template using load_sr_template '||
    --  'on (sr_template.TM_ID=load_sr_template.TM_ID) '||
    --  'when matched then update set '||
    --  'sr_template.TM_NAME=load_sr_template.TM_NAME,sr_template.TM_TEMPL=load_sr_template.TM_TEMPL '||
    --  'when not matched then insert '||
    --  '(TM_ID,TM_NAME,TM_TEMPL) '||
    --  'values '||
    --  '(load_sr_template.TM_ID,load_sr_template.TM_NAME,load_sr_template.TM_TEMPL)';
    --+ Автор: YURA_A 25.02.2004 11:43:04
    --  Описание: в пром бд не грузим
    --execute immediate l_script;
    --- Автор: YURA_A 25.02.2004 11:43:07
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Error in LoadSRControlMetadata: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || l_script);
    END;
END ikis_load_metadata;
/