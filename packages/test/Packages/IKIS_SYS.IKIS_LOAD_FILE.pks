/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_LOAD_FILE
IS
-- Author  : SLAVIQ
-- Created : 06.08.2007 12:51:06
-- Purpose : Загрузка и обработка файл архивов на сервере
--Закоментировано до лучших времен!

/*function ExtractArh(p_file blob, p_file_name varchar2, p_ss_code ikis_subsys.ss_code%type, p_taskcode varchar2) return ikis_lock.t_lockhandler;
function ExtractBlobArh(p_file_name varchar2, p_ss_code ikis_subsys.ss_code%type, p_taskcode varchar2) return ikis_lock.t_lockhandler;
*/
END IKIS_LOAD_FILE;
/


GRANT EXECUTE ON IKIS_SYS.IKIS_LOAD_FILE TO II01RC_IKIS_COMMON
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_LOAD_FILE
IS
/*
  msgCOMMON_EXCEPTION   number :=2;

procedure UnzipFile2Dir(p_blobfile in blob,p_filename varchar2, p_location varchar2)
is
  v_read_amount     integer := 32765;
  v_read_offset     integer := 1;
  v_buffer          raw(32767);
  l_file            UTL_FILE.file_type;
  l_outzipdir       varchar2(1000);
  l_inzipdir        varchar2(1000);
  l_workdirpath     varchar2(1000);

begin
  select directory_path
         into l_workdirpath
    from all_directories
    where directory_name = UPPER(p_location);

  l_outzipdir := l_workdirpath;
  l_inzipdir := l_workdirpath||'/'||p_filename;

  l_file := UTL_FILE.fopen(location => UPPER(p_location), filename => p_filename, open_mode => 'w', max_linesize => 32767);

  loop
    dbms_lob.read(p_blobfile,v_read_amount,v_read_offset,v_buffer);
    UTL_FILE.put_raw(file => l_file,buffer => v_buffer,autoflush => true);
    v_read_offset := v_read_offset + v_read_amount;
    exit when v_read_amount<32765;
    v_read_amount := 32765;
  end loop;
  UTL_FILE.fclose(file => l_file);
  viewzip$unzipall(p_zip => l_inzipdir, p_outdir => l_outzipdir);
exception
  when others then
    raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_LOAD_FILE.UnzipFile2Dir',chr(10)||sqlerrm));
end;

function ExtractArh(p_file blob, p_file_name varchar2, p_ss_code ikis_subsys.ss_code%type, p_taskcode varchar2) return ikis_lock.t_lockhandler
is
  l_workdirname       varchar2(1000);
  l_lock              ikis_lock.t_lockhandler;
begin

  if p_file is null or p_file_name is null then
    raise_application_error(-20000, 'Помилка тіла файлу що завантажується: '||upper(p_file_name));
  end if;

  l_workdirname := ikis_parameter_util.GetParameter1(p_par_code => 'DIRNAME_'||UPPER(TRIM(p_taskcode)), p_par_ss_code => p_ss_code);

  ikis_lock.request_lock(p_permanent_name => p_ss_code,
                         p_var_name => p_taskcode,
                         p_errmessage => 'Зараз вже виконується обробка файлів, спробуйте пізніше.',
                         p_lockhandler => l_lock,
                         p_lockmode => 6,
                         p_timeout => 10,
                         p_release_on_commit => true);

  UnzipFile2Dir(p_file, p_file_name, l_workdirname);

  return l_lock;
exception
  when others then
    raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_LOAD_FILE.ExtractArh',chr(10)||sqlerrm));
end;

function ExtractBlobArh(p_file_name varchar2, p_ss_code ikis_subsys.ss_code%type, p_taskcode varchar2) return ikis_lock.t_lockhandler
is
  l_file blob;
begin
  begin
    select t.file_content
    into l_file
    from tt$blob_dbf_load t
    where upper(t.file_name) = upper(p_file_name);
  exception
    when others then raise_application_error(-20000, 'Не знайдено в базі даних тіла файлу: '||upper(p_file_name));
  end;
  return ExtractArh(p_file => l_file, p_file_name => upper(p_file_name), p_ss_code => p_ss_code, p_taskcode => p_taskcode);
exception
  when others then
    raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_LOAD_FILE.ExtractBlobArh',chr(10)||sqlerrm));
end;
*/
END IKIS_LOAD_FILE;
/