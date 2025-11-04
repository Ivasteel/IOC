/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.LOAD_FILE_WEB
IS
    PROCEDURE configNls;

    PROCEDURE UploadFile (p_lfd_id             OUT NUMBER,
                          p_lfd_lfd         IN     NUMBER,
                          p_lfd_file_name   IN     VARCHAR2,
                          p_lfd_lft         IN     NUMBER,
                          p_lfd_mime_type   IN     VARCHAR2,
                          p_lfd_filesize    IN     NUMBER,
                          p_lfd_create_dt   IN     DATE,
                          p_lfd_st          IN     CHAR,
                          p_content         IN     BLOB);

    PROCEDURE GetFiltredFiles (p_user        IN     VARCHAR2,
                               p_file_type   IN     NUMBER,
                               p_start_dt    IN     DATE,
                               p_finish_dt   IN     DATE,
                               res_cur          OUT SYS_REFCURSOR);

    -- info:   Выборка для детального реестра
    -- params: res_cur
    -- note:   -
    PROCEDURE GetFilteredFilesDetails (
        p_lfd_id           IN     NUMBER,
        res_cur_files         OUT SYS_REFCURSOR,
        res_cur_logs          OUT SYS_REFCURSOR,
        res_cur_protocol      OUT SYS_REFCURSOR);

    PROCEDURE GetFileById (p_lfd_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    PROCEDURE GetFileTypesByRole (res_cur OUT SYS_REFCURSOR);

    PROCEDURE GetProtocolContent (
        p_lfp_id     IN     load_file_protocol.lfp_id%TYPE,
        p_lfp_name      OUT load_file_protocol.lfp_name%TYPE,
        p_content       OUT load_file_protocol.content%TYPE);

    PROCEDURE RegisterProcessControl (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER);

    PROCEDURE RegisterProcessLoad (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER);
END LOAD_FILE_WEB;
/


GRANT EXECUTE ON USS_EXCH.LOAD_FILE_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_EXCH.LOAD_FILE_WEB TO II01RC_USS_EXCH_WEB
/


/* Formatted on 8/12/2025 5:54:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.LOAD_FILE_WEB
IS
    -- Kovalenko A 04.09.2018
    -- Application constants
    package_name   CONSTANT VARCHAR2 (32) := 'LOAD_FILE_WEB';

    -- info:   Установка рпараметров сесии
    -- params: -
    -- note:   -
    PROCEDURE configNls
    IS
    BEGIN
        DBMS_SESSION.set_nls ('NLS_DATE_FORMAT', '''dd.mm.yyyy hh24:mi:ss''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');
    END;

    -- info:   процедура загрузки файлов с реестра РЗО
    -- params: p_lfd_id  идентификатор файла,
    --         p_lfd_lfd идентификатор родителя(как правило архив),
    --         p_lfd_file_name название файла,
    --         p_lfd_lft тип файла (load_file_type),
    --         p_lfd_mime_type тип расширения файла,
    --         p_lfd_filesize размер файла,
    --         p_lfd_create_dt дата создания,
    --         p_lfd_st статус файла,
    --         p_content бинарное содержимое файла
    -- note:   ShY 26 05 2020 - добавил для аз про смерть вызов обработчика на загрузку
    --         ShY 16 05 2021 - добавил для типов файлов автоматический загрузчик по факту загрузки
    --         ShY 20 05 2021 - запрет на повторное мнесение файла с одним и тем же названием если файл не является ошибочным
    PROCEDURE UploadFile (p_lfd_id             OUT NUMBER,
                          p_lfd_lfd         IN     NUMBER,
                          p_lfd_file_name   IN     VARCHAR2,
                          p_lfd_lft         IN     NUMBER,
                          p_lfd_mime_type   IN     VARCHAR2,
                          p_lfd_filesize    IN     NUMBER,
                          p_lfd_create_dt   IN     DATE,
                          p_lfd_st          IN     CHAR,
                          p_content         IN     BLOB)
    IS
        l_lft_src               v_load_file_type.lft_src%TYPE;
        l_lft_is_auto_start     v_load_file_type.lft_is_auto_start%TYPE;
        l_lft_is_unique         v_load_file_type.lft_is_unique%TYPE;

        l_exception_is_unique   EXCEPTION;
        l_exception_message     VARCHAR2 (255);
    BEGIN
        -- +++++++++++++++++++++++++++++++++++++++ Инициализация +++++++++++++++++++++++++++++++++++++++++++= --
        -- определяем источник загружаемого файла по типу файла
        SELECT v.lft_src, v.lft_is_auto_start, v.lft_is_unique
          INTO l_lft_src, l_lft_is_auto_start, l_lft_is_unique
          FROM v_load_file_type v
         WHERE p_lfd_lft = v.lft_id;

        -- +++++++++++++++++++++++++++++++++++++++++++++ Контроли +++++++++++++++++++++++++++++++++++++++++++++++++++ --
        -- Shy 200520021
        IF l_lft_is_unique = 'T'
        THEN
            l_exception_message := NULL;

            FOR rec
                IN (SELECT lfd.lfd_id, lfd.lfd_create_dt
                      FROM load_file_data lfd
                     WHERE     lfd.lfd_file_name = p_lfd_file_name
                           AND lfd.lfd_lft = p_lfd_lft
                           AND lfd.lfd_st <> 'R')
            LOOP
                l_exception_message :=
                       'Файл '
                    || p_lfd_file_name
                    || ', даного типу, вже завантажено до "Реєстра завантаження файлів" '
                    || TO_CHAR (rec.lfd_create_dt, 'dd.mm.yyyy hh24:mi:ss');
                RAISE l_exception_is_unique;
            END LOOP;
        END IF;

        -- +++++++++++++++++++++++++++++++++++++++++++++ Вставка +++++++++++++++++++++++++++++++++++++++++++++++++++ --
        -- вставка информационных данных про файл
        INSERT INTO load_file_data (lfd_id,
                                    lfd_lfd,
                                    lfd_file_name,
                                    lfd_lft,
                                    lfd_mime_type,
                                    lfd_filesize,
                                    lfd_create_dt,
                                    lfd_user_id,
                                    lfd_src,
                                    lfd_st)
             VALUES (p_lfd_id,
                     p_lfd_lfd,
                     p_lfd_file_name,
                     p_lfd_lft,
                     p_lfd_mime_type,
                     p_lfd_filesize,
                     SYSDATE,
                     uss_exch_context.getcontext ('uid'),
                     l_lft_src,
                     p_lfd_st)
          RETURNING lfd_id
               INTO p_lfd_id;

        -- вставка вложения
        INSERT INTO load_file_data_content (content, lfdc_lfd)
             VALUES (p_content, p_lfd_id);

        -- вставка лог записи про загрузку файла
        INSERT INTO load_file_data_log (lfdl_lfd,
                                        lfdl_text,
                                        lfdl_create,
                                        lfdl_user_id,
                                        lfdl_tp,
                                        lfdl_file_st)
             VALUES (p_lfd_id,
                     'Завантажено файл ' || p_lfd_file_name,
                     SYSDATE,
                     uss_exch_context.getcontext ('uid'),
                     'P',
                     'A');

        -- Shy переписать load_file_type добавить атрибут на автоматическую загрузку после загрузки файла
        -- 200520021 ShY, дописал
        IF l_lft_is_auto_start = 'T'
        THEN
            load_file_loader.DnetStart (p_lfd_id);
        END IF;
    EXCEPTION
        WHEN l_exception_is_unique
        THEN
            raise_application_error (-20000, l_exception_message);
    END;

    -- info:   Получение информаци о файле
    -- params: p_lfd_id - Идентификатор файла
    --         res_cur - возвращаемый курсор
    -- note:   -
    PROCEDURE GetFileById (p_lfd_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR SELECT vl.*
                           FROM v_load_file_data_full vl
                          WHERE vl.file_id = p_lfd_id;
    END;

    -- info:   Выборка для реестра
    -- params: p_user_code,
    --         p_file_type_name,
    --         p_requestformationdatestart,
    --         p_requestformationdatefinish,
    --         res_cur
    -- note:   -
    PROCEDURE GetFiltredFiles (p_user        IN     VARCHAR2,
                               p_file_type   IN     NUMBER,
                               p_start_dt    IN     DATE,
                               p_finish_dt   IN     DATE,
                               res_cur          OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (32767);
    BEGIN
        confignls;
        v_sql :=
            'SELECT
    vf.file_id,
    vf.file_name,
    vf.file_type_code,
    vf.file_type_sname,
    vf.file_type_name,
    vf.file_size,
    vf.file_create,
    vf.user_code,
    vf.user_fio,
    vf.src_sname,
    vf.src_name,
    vf.file_st_code,
    vf.file_st_name,
    vf.file_st_dt,
    vf.cnt_toload,
    case when vf.file_st_code = ''C''  then 1 else 0 end as is_can_control,
    case when (vf.file_st_code = ''V'') or (vf.file_st_code = ''F'' and vf.file_type_id = 10 and vf.cnt_toload > 0) then 1 else 0 end as is_can_load
  FROM v_load_file_data_full vf
  WHERE rownum <= 500
    and vf.file_parent_id is null
    and (vf.user_org = uss_exch_context.getcontext(''org'') or uss_exch_context.getcontext(''login'') in (''U50000-U1'',''U50001-U1'',''U50000-DEV'',''U50001-DEV''))
  ';

        IF p_user IS NOT NULL
        THEN
            v_sql :=
                   v_sql
                || 'AND upper(vf.USER_FIO) like upper(''%'
                || p_user
                || '%'') ';
        END IF;

        IF p_file_type IS NOT NULL
        THEN
            v_sql := v_sql || 'AND vf.FILE_TYPE_ID = ' || p_file_type || ' ';
        END IF;

        IF p_start_dt IS NOT NULL
        THEN
            v_sql :=
                   v_sql
                || q'[AND trunc(vf.FILE_CREATE) >= trunc(to_date(']'
                || p_start_dt
                || q'[', 'dd.mm.yyyy hh24:mi:ss'))]';
        END IF;

        IF p_finish_dt IS NOT NULL
        THEN
            v_sql :=
                   v_sql
                || q'[AND trunc(vf.FILE_CREATE) <= trunc(to_date(']'
                || p_finish_dt
                || q'[', 'dd.mm.yyyy hh24:mi:ss'))]';
        END IF;

        v_sql := v_sql || 'order by vf.FILE_CREATE desc, vf.USER_CODE';

        --raise_application_error(-20000, v_sql);
        OPEN res_cur FOR v_sql;
    END;

    -- info:   Выборка для детального реестра
    -- params: res_cur
    -- note:   -
    PROCEDURE GetFilteredFilesDetails (
        p_lfd_id           IN     NUMBER,
        res_cur_files         OUT SYS_REFCURSOR,
        res_cur_logs          OUT SYS_REFCURSOR,
        res_cur_protocol      OUT SYS_REFCURSOR)
    IS
    BEGIN
        confignls;

        OPEN res_cur_files FOR
              SELECT vf.file_id,
                     vf.file_name,
                     vf.file_type_code,
                     vf.file_type_sname,
                     vf.file_type_name,
                     vf.file_size     AS File_Size,
                     vf.file_create,
                     vf.file_records_cnt,
                     vf.user_code,
                     vf.user_fio,
                     vf.src_sname,
                     vf.src_name,
                     vf.file_st_code,
                     vf.file_st_name,
                     vf.file_st_dt
                FROM v_load_file_data_full vf
               WHERE (vf.file_id = p_lfd_id OR vf.file_parent_id = p_lfd_id)
            ORDER BY vf.file_id;

        OPEN res_cur_logs FOR
            SELECT l.lfdl_id,
                   l.lfdl_lfd,
                   l.lfdl_text      AS lfdl_text,
                   l.lfdl_create,
                   l.lfdl_file_st,
                   st.dic_sname     AS lfdl_file_st_sname
              FROM v_load_file_data_full  vf
                   JOIN load_file_data_log l
                       ON l.lfdl_lfd = vf.file_id AND l.lfdl_tp IN ('P')
                   JOIN uss_ndi.v_ddn_load_file_st st
                       ON st.dic_value = l.lfdl_file_st
             WHERE vf.file_id = p_lfd_id
            UNION ALL
            SELECT l.lfdl_id,
                   l.lfdl_lfd,
                   '-- ' || l.lfdl_text     AS lfdl_text,
                   l.lfdl_create,
                   l.lfdl_file_st,
                   st.dic_sname             AS lfdl_file_st_sname
              FROM v_load_file_data_full  vf
                   JOIN load_file_data_log l
                       ON l.lfdl_lfd = vf.file_id AND l.lfdl_tp IN ('P')
                   JOIN uss_ndi.v_ddn_load_file_st st
                       ON st.dic_value = l.lfdl_file_st
             WHERE vf.file_parent_id = p_lfd_id
            ORDER BY lfdl_id;

        OPEN res_cur_protocol FOR
              SELECT p.lfp_id,
                     p.lfp_lfp,
                     p.lfp_lfd,
                     p.lfp_tp,
                     NULL     AS lfp_tp_name,
                     p.lfp_name,
                     p.lfp_comment,
                     p.lfp_create_dt
                FROM v_load_file_data_full vf
                     JOIN load_file_protocol p ON p.lfp_lfd = vf.file_id
               WHERE (vf.file_id = p_lfd_id OR vf.file_parent_id = p_lfd_id)
            ORDER BY p.lfp_create_dt;
    END;

    -- Призначення: Вивантаження протоколу через web-додаток;
    -- Параметри:   ІД протоколу;
    /*procedure DownloadContent(
      p_lp_id           in ls_protocol.lp_id%type
    )
    is
      l_filename  ls_asopd_data.lad_filename%type;
      l_mime_type ls_asopd_data.lad_mime_type%type;
  --    l_content   ls_asopd_data.content%type;
      l_content   ls_protocol.content%type;
    begin
      if (p_lp_id is not null) then
        begin
  --        select substr(lad.lad_filename, 1, instr(lad.lad_filename, '.', -1)-1)||'_protocol_'||pt.pt_name||'.zip', lad.lad_mime_type, lp.content
          select replace(pt.pt_name, ' ', '_')||'.zip', lad.lad_mime_type, lp.content
            into l_filename, l_mime_type, l_content
            from ls_asopd_data lad,
                 ls_protocol lp,
                 nsi_protocol_type pt
           where lad.lad_id = lp.lp_lad
             and lp.lp_pt = pt.pt_id
             and lp.lp_id = p_lp_id;
        exception
          when NO_DATA_FOUND then
            l_filename  := null;
            l_mime_type := 'application/zip';
            l_content   := null;
        end;

        if (dbms_lob.getlength(l_content) > 0) then
          htp.p('Content-Type: ' || l_mime_type || '; name="' || l_filename || '"');
          htp.p('Content-Disposition: attachment; filename="' || l_filename || '"');
          htp.p('Content-Length: ' || dbms_lob.getlength(l_content));
          htp.p('');

          wpg_docload.download_file(l_content);
          begin apex_application.stop_apex_engine; exception when others then null; end;
        end if;
      end if;
    end;*/

    -- info:   Выборка для лукапа (выпадалка) какие типы загрузок доступны по ролям пользователя
    -- params: res_cur - курсор
    -- note:   -
    PROCEDURE GetFileTypesByRole (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT v.lft_name name, v.lft_id id
                FROM v_load_file_type v
                     JOIN ikis_sysweb.v$user_roles vu
                         ON v.lft_role = vu.wr_name
               WHERE v.lft_st = 'A'
            ORDER BY v.lft_name;
    END;

    -- info:   Получение информаци о загрузке/обработке (лог) файлпа
    -- params: p_lfd_id - Идентификатор файла
    --         res_cur - возвращаемый курсор
    -- note:   -
    PROCEDURE GetLogById (p_lfd_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT lfd.lfd_file_name, l.*
                FROM v_load_file_data_log l
                     JOIN v_load_file_data lfd ON lfd.lfd_id = l.lfdl_lfd
               WHERE lfd.lfd_id = p_lfd_id AND l.lfdl_tp IN ('U', 'P')
            ORDER BY l.lfdl_create, l.lfdl_id;
    END;

    -- вивантаження пртоколу завантаження
    PROCEDURE GetProtocolContent (
        p_lfp_id     IN     load_file_protocol.lfp_id%TYPE,
        p_lfp_name      OUT load_file_protocol.lfp_name%TYPE,
        p_content       OUT load_file_protocol.content%TYPE)
    IS
    BEGIN
        SELECT lfp.lfp_name, lfp.content
          INTO p_lfp_name, p_content
          FROM load_file_protocol lfp
         WHERE lfp.lfp_id = p_lfp_id;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Файл не знайдено, або у вас недостатньо прав доступу');
    END;

    PROCEDURE RegisterProcessControl (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER)
    IS
    BEGIN
        Load_file_loader.RegisterProcessControl (p_jb       => p_jb,
                                                 p_lfd_id   => p_lfd_id,
                                                 p_isweb    => p_isweb);
    END;

    PROCEDURE RegisterProcessLoad (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER)
    IS
    BEGIN
        Load_file_loader.RegisterProcessLoad (p_jb       => p_jb,
                                              p_lfd_id   => p_lfd_id,
                                              p_isweb    => p_isweb);
    END;
END;
/