/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$DBF
IS
    -- Author  : VANO
    -- Created : 21.08.2019 17:05:49
    -- Purpose : Функції роботи з DBF-файлами

    TYPE t_column IS RECORD
    (
        ora_name     VARCHAR2 (100),
        dbf_name     VARCHAR2 (100),
        col_order    INTEGER
    );

    TYPE t_tab_columns IS TABLE OF t_column;

    FUNCTION GetColumnsList (p_column_list VARCHAR2)
        RETURN t_tab_columns
        PIPELINED;

    FUNCTION make_d4_all (p_tblname       VARCHAR2,
                          p_column_list   VARCHAR2,
                          p_where         VARCHAR2,
                          p_order         VARCHAR2:= NULL,
                          p_convert       INTEGER:= 0)
        RETURN BLOB;

    FUNCTION make_d4_all (p_tblname           VARCHAR2,
                          p_column_list       VARCHAR2,
                          p_where             VARCHAR2,
                          p_order             VARCHAR2 := NULL,
                          p_convert           INTEGER := 0,
                          p_row_cnt       OUT NUMBER)
        RETURN BLOB;
END API$DBF;
/


/* Formatted on 8/12/2025 5:48:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$DBF
IS
    FUNCTION make_d4_column_script (p_tblname       VARCHAR2,
                                    p_column_list   VARCHAR2,
                                    p_where         VARCHAR2,
                                    p_order         VARCHAR2:= NULL,
                                    p_convert       INTEGER:= 0)
        RETURN VARCHAR2;         --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить

    FUNCTION GetColumnsList (p_column_list VARCHAR2)
        RETURN t_tab_columns
        PIPELINED
    IS
        l_tmp   t_column;
    BEGIN
        FOR cols
            IN (SELECT CASE
                           WHEN INSTR (i_col_name, '=') > 0
                           THEN
                               SUBSTR (i_col_name,
                                       1,
                                       INSTR (i_col_name, '=') - 1)
                           ELSE
                               i_col_name
                       END    AS i_ora_name,
                       CASE
                           WHEN INSTR (i_col_name, '=') > 0
                           THEN
                               SUBSTR (i_col_name,
                                       INSTR (i_col_name, '=') + 1)
                           ELSE
                               i_col_name
                       END    AS i_dbf_name,
                       i_col_order
                  FROM (    SELECT UPPER (TRIM (REGEXP_SUBSTR (p_column_list,
                                                               '[^,]+',
                                                               1,
                                                               LEVEL)))
                                       AS i_col_name,
                                   LEVEL
                                       AS i_col_order
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (p_column_list,
                                                  '[^,]+',
                                                  1,
                                                  LEVEL)
                                       IS NOT NULL))
        LOOP
            l_tmp.ora_name := cols.i_ora_name;
            l_tmp.dbf_name := cols.i_dbf_name;
            l_tmp.col_order := cols.i_col_order;
            PIPE ROW (l_tmp);
        END LOOP;
    END;

    FUNCTION to_ascii (p_number IN NUMBER)
        RETURN VARCHAR2
    IS
        l_number   NUMBER := p_number;
        l_data     VARCHAR2 (8);
        l_bytes    NUMBER;
        l_byte     NUMBER;
    BEGIN
        SELECT VSIZE (l_number) INTO l_bytes FROM DUAL;

        FOR i IN 1 .. l_bytes
        LOOP
            l_byte :=
                TRUNC (
                    MOD (l_number, POWER (2, 8 * i)) / POWER (2, 8 * (i - 1)));
            l_data := l_data || CHR (l_byte);
        END LOOP;

        RETURN l_data;
    END to_ascii;

    FUNCTION make_d4_header (p_tblname           VARCHAR2,
                             p_column_list       VARCHAR2,
                             p_where             VARCHAR2,
                             p_convert           INTEGER := 0,
                             p_row_cnt       OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_header              VARCHAR2 (32767);
        l_fld_header          VARCHAR2 (100);
        l_number_of_columns   BINARY_INTEGER;
        l_line_length         BINARY_INTEGER;
        l_number_of_records   NUMBER;

        CURSOR c_columns IS
              SELECT c.column_name             AS q_ora_name,
                     DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     NVL (c.data_scale, 0)     data_scale,
                     dbf_name                  AS q_dbf_name
                FROM all_tab_columns c,
                     TABLE (API$DBF.GetColumnsList (p_column_list))
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     AND c.column_name = ora_name
            ORDER BY col_order, column_id;

        TYPE cv_typ IS REF CURSOR;

        CV                    cv_typ;
    BEGIN
          SELECT COUNT (*),
                   SUM (
                       DECODE (c.data_type,
                               'DATE', 8,
                               'NUMBER', NVL (c.data_precision, 20),
                               c.data_length))
                 + 1
            INTO l_number_of_columns, l_line_length
            FROM all_tab_columns c,
                 TABLE (API$DBF.GetColumnsList (p_column_list))
           WHERE     c.table_name = p_tblname
                 AND UPPER (c.column_name) <> 'KEYFLD'
                 AND c.column_name = ora_name
        ORDER BY col_order, column_id;

        EXECUTE IMMEDIATE   'select count(*) cnt from '
                         || p_tblname
                         || ' where 1=1 '
                         || CASE
                                WHEN p_where IS NOT NULL
                                THEN
                                    'and ' || p_where
                            END
            INTO l_number_of_records;

        p_row_cnt := l_number_of_records;

        --ЗАГОЛОВОК
        --№ - номер байта
        -- №0 Версия/ 1 байт
        -- 03 - простая таблица
        l_header := CHR (3);
        -- №1,2,3 Дата последнего обновления таблицы в формате YYMMDD/ 3 байта
        l_header :=
               l_header
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'YY')))
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'MM')))
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'DD')));
        --№4,5,6,7 Количество записей в таблице/ 32 бита = 4 байта
        l_header :=
            l_header || RPAD (to_ascii (l_number_of_records), 4, CHR (0));
        --№8,9 Количество байтов, занимаемых заголовком
        --/16 бит = 2 байта = 32 + 32*n + 1, где n - количество столбцов
        -- а 1 - ограничительный байт
        l_header :=
               l_header
            || RPAD (to_ascii (32 + l_number_of_columns * 32 + 1),
                     2,
                     CHR (0));
        --№10,11 Количество байтов, занимаемых записью/16 бит = 2 байта
        l_header := l_header || RPAD (to_ascii (l_line_length), 2, CHR (0));
        --№12,13 Зарезервировано
        l_header := l_header || RPAD (CHR (0), 2, CHR (0));
        --№14 Транзакция, 1-начало, 0-конец(завершена)
        l_header := l_header || CHR (0);
        --№15 Кодировка: 1-закодировано, 0-нормальная видимость
        l_header := l_header || CHR (0);
        --№16-27 Использование многопользовательского окружения
        l_header := l_header || RPAD (CHR (0), 12, CHR (0));
        --№28 Использование индекса 0-не использовать
        l_header := l_header || CHR (0);

        --№29 Номер драйвера языка
        IF p_convert = 0
        THEN
            l_header := l_header || CHR (38);                          --cp866
        ELSIF p_convert = 3
        THEN
            l_header := l_header || CHR (101);                --Russian MS-DOS
        ELSE
            l_header := l_header || CHR (3);                          --cp1251
        END IF;

        --№30,31 Зарезервировано
        l_header := l_header || RPAD (CHR (0), 2, CHR (0));

        --ОПИСАНИЯ ПОЛЕЙ В ЗАГОЛОВКЕ
        FOR i IN c_columns
        LOOP
            --№0-10 Имя поля с 0-завершением/11 байт
            l_fld_header := RPAD (SUBSTR (i.q_dbf_name, 1, 10), 11, CHR (0));
            --№11 Тип поля/1 байт
            l_fld_header := l_fld_header || i.data_type;
            --№12,13,14,15 Игнорируется/4 байта
            l_fld_header := l_fld_header || RPAD (CHR (0), 4, CHR (0));
            --№16 Размер поля/1 байт
            l_fld_header := l_fld_header || CHR (i.data_length);
            --№17 Количество знаков после запятой/1 байт
            l_fld_header := l_fld_header || CHR (i.data_scale);
            --№18,19 Зарезервированная область/2 байта
            l_fld_header := l_fld_header || RPAD (CHR (0), 2, CHR (0));
            --№20 Идентификатор рабочей области/1 байт
            l_fld_header := l_fld_header || CHR (0);
            --№21,22 Многопользовательский dBase/2 байта
            l_fld_header := l_fld_header || RPAD (CHR (0), 2, CHR (0));
            --№23 Установленные поля/1 байт
            l_fld_header := l_fld_header || CHR (0);                 --chr(1);
            --№24 Зарезервировано/7 байт
            l_fld_header := l_fld_header || RPAD (CHR (0), 7, CHR (0));
            --№31 Флаг MDX-поля: 01H если поле имеет метку индекса в MDX-файле, 00H - нет.
            l_fld_header := l_fld_header || CHR (0);
            --dbms_output.put_line(i.q_dbf_name || ';' || i.data_length || ';' || length(l_fld_header)||';'||UTL_RAW.CAST_TO_RAW(l_fld_header));
            --dbms_output.put_line( i.data_length || chr(i.data_length));
            l_header := l_header || l_fld_header;
        END LOOP;

        --Завершающий заголовок символ 0D
        l_header := l_header || CHR (13);
        RETURN l_header;
    END make_d4_header;

    FUNCTION make_d4_all (p_tblname       VARCHAR2,
                          p_column_list   VARCHAR2,
                          p_where         VARCHAR2,
                          p_order         VARCHAR2:= NULL,
                          p_convert       INTEGER:= 0)
        RETURN BLOB
    IS
        l_row_cnt   NUMBER;
    BEGIN
        RETURN make_d4_all (p_tblname       => p_tblname,
                            p_column_list   => p_column_list,
                            p_where         => p_where,
                            p_order         => p_order,
                            p_convert       => p_convert,
                            p_row_cnt       => l_row_cnt);
    END;

    FUNCTION make_d4_all (p_tblname           VARCHAR2,
                          p_column_list       VARCHAR2,
                          p_where             VARCHAR2,
                          p_order             VARCHAR2 := NULL,
                          p_convert           INTEGER := 0,
                          p_row_cnt       OUT NUMBER)
        RETURN BLOB
    IS
        l_blob             BLOB;
        l_header           VARCHAR2 (32767);
        all_columns        SYS_REFCURSOR;
        v_select           VARCHAR2 (32767);
        l_lines            VARCHAR2 (32767);

        TYPE all_columns_pk IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_all_columns_pk   all_columns_pk;
    BEGIN
        --Формируем заголовок и записываем его
        l_header :=
            make_d4_header (p_tblname       => p_tblname,
                            p_where         => p_where,
                            p_row_cnt       => p_row_cnt,
                            p_convert       => p_convert,
                            p_column_list   => p_column_list);
        DBMS_LOB.createtemporary (l_blob, TRUE);

        FOR i IN 1 .. TRUNC (LENGTH (l_header) / 2000) + 1
        LOOP
            DBMS_LOB.append (
                l_blob,
                UTL_RAW.cast_to_raw (SUBSTR (l_header, 1, 2000)));
            l_header := SUBSTR (l_header, 2001);
        END LOOP;

        --формируем данные
        v_select :=
            make_d4_column_script (p_tblname       => p_tblname,
                                   p_where         => p_where,
                                   p_order         => p_order,
                                   p_convert       => p_convert,
                                   p_column_list   => p_column_list);

        --Складываем "упаковками" :)
        OPEN all_columns FOR v_select;

        LOOP
            FETCH all_columns BULK COLLECT INTO l_all_columns_pk LIMIT 1000;

            EXIT WHEN l_all_columns_pk.COUNT = 0;
            l_lines := '';

            --Вставляем записи
            FOR i IN l_all_columns_pk.FIRST .. l_all_columns_pk.LAST
            LOOP
                IF LENGTH (l_lines) + LENGTH (l_all_columns_pk (i)) > 32000
                THEN
                    DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (l_lines));
                    l_lines := '';
                END IF;

                l_lines := l_lines || CHR (32) || l_all_columns_pk (i);
            END LOOP;

            DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (l_lines));
            l_lines := '';
        END LOOP;

        --Символ-метка конца записи и дописіваем все что не попало в предідущем цікле
        DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (CHR (26)));
        RETURN l_blob;
        DBMS_LOB.freetemporary (l_blob);
    END make_d4_all;

    FUNCTION make_d4_column_script (p_tblname       VARCHAR2,
                                    p_column_list   VARCHAR2,
                                    p_where         VARCHAR2,
                                    p_order         VARCHAR2:= NULL,
                                    p_convert       INTEGER:= 0)
        RETURN VARCHAR2          --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить
    IS
        l_result   VARCHAR2 (32000);
        l_column   VARCHAR2 (4000);

        CURSOR c_all_columns IS --Здесь надо привести свои форматы к формата dbf
              SELECT c.column_name             AS q_ora_name,
                     DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     NVL (c.data_scale, 0)     data_scale,
                     dbf_name                  AS q_dbf_name
                FROM all_tab_columns c,
                     TABLE (API$DBF.GetColumnsList (p_column_list))
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     AND c.column_name = ora_name
            ORDER BY col_order, column_id;
    BEGIN
        FOR rec_all_columns IN c_all_columns
        LOOP
            --Для дат формат должен быть YYYYMMDD
            IF rec_all_columns.data_type = 'D'
            THEN
                l_column :=
                       'TO_CHAR'
                    || '('
                    || rec_all_columns.q_ora_name
                    || ', ''YYYYMMDD'')';
            ELSIF rec_all_columns.data_type = 'N'
            THEN
                --Здесь нужно вставить свой формат чисел
                IF NVL (rec_all_columns.data_scale, 0) = 0
                THEN
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.q_ora_name
                        || ',''999999999999999999''))';
                ELSE
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.q_ora_name
                        || ',''9999999999999990.'
                        || TRIM (
                               LPAD (' ',
                                     rec_all_columns.data_scale + 1,
                                     '9'))
                        || '''))';
                END IF;
            ELSE
                l_column := rec_all_columns.q_ora_name;
            END IF;

            --Если вдруг после преобразований получилось,
            --что длина поля больше указанной,
            --обрезаем поле
            l_column :=
                   'nvl(substr('
                || l_column
                || ',1,'
                || rec_all_columns.data_length
                || '),'' '')';

            --Далее для формата dbf необходимо "дописать" значение
            --в колонке до максимальной длины колонки
            IF rec_all_columns.data_type = 'N'
            THEN
                l_column :=
                       'lpad('
                    || l_column
                    || ','
                    || rec_all_columns.data_length
                    || ')';
            ELSE
                l_column :=
                       'rpad('
                    || l_column
                    || ','
                    || rec_all_columns.data_length
                    || ')';
            END IF;

            IF l_result IS NOT NULL
            THEN
                l_result := l_result || ' || ';
            END IF;

            l_result := l_result || l_column;
        END LOOP;

        --Здесь нужно вставить свою кодировку CL8MSWIN1251 или CL8ISO8859P5, например
        l_result :=
               'SELECT '
            || CASE WHEN p_convert IN (0, 1, 3) THEN 'CONVERT(' END
            || l_result
            || CASE
                   WHEN p_convert = 0
                   THEN
                       ',''RU8PC866'') FROM ' || p_tblname
                   WHEN p_convert = 1
                   THEN
                       ',''CL8MSWIN1251'') FROM ' || p_tblname
                   WHEN p_convert = 3
                   THEN
                       ',''CL8MSWIN1251'') FROM ' || p_tblname
                   ELSE
                       ' FROM ' || p_tblname
               END
            || ' where 1=1 '
            || CASE WHEN p_where IS NOT NULL THEN 'and ' || p_where END
            || CASE WHEN p_order IS NOT NULL THEN ' order by ' || p_order END;

        RETURN l_result;
    END make_d4_column_script;
BEGIN
    -- Initialization
    NULL;
END API$DBF;
/