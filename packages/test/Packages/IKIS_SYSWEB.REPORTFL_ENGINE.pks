/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.REPORTFL_ENGINE
    AUTHID CURRENT_USER
IS
    -- AUTHOR  : VANO
    -- CREATED : 11.01.2007 19:14:52
    -- PURPOSE : ФОРМУВАННЯ ЗВІТІВ НА ОСНОВІ ШАБЛОНІВ (RTF...)

    vTempBlob   BLOB;


    PROCEDURE InitReport (p_ss_code   rpt_templates.rt_ss_code%TYPE,
                          p_code      rpt_templates.rt_code%TYPE);

    PROCEDURE AddParam (p_param_name VARCHAR2, p_param_value VARCHAR2);

    -- додаємо DataSet.
    PROCEDURE AddDataSet (p_dataset VARCHAR2, p_sql VARCHAR2);

    -- пошук на існування DataSet
    FUNCTION ExistsDataSet (p_DataSet VARCHAR2)
        RETURN BOOLEAN;

    -- додаємо зв`язок між DataSet
    PROCEDURE AddRelation (pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2);

    -- пошук на існування зв`язоку між DataSet
    FUNCTION ExistsRelation (pMaster   VARCHAR2,
                             pDetail   VARCHAR2,
                             pType     INTEGER:= 1)
        RETURN BOOLEAN;

    -- додаємо Summary
    PROCEDURE AddSummary (pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2);

    -- пошук на існування Summary
    FUNCTION ExistsSummary (pDataSet      VARCHAR2,
                            pField        VARCHAR2,
                            pType         VARCHAR2,
                            pTypeExists   INTEGER:= 1)
        RETURN BOOLEAN;

    FUNCTION GetParamValue (p_param_name VARCHAR2)
        RETURN VARCHAR2;

    -- +Kalev 18.02.2008
    -- Вставка DataSet
    PROCEDURE DataSetIntoReport (pReport OUT BLOB);

    PROCEDURE PublishReport;

    FUNCTION PublishReportBlob
        RETURN BLOB;

    PROCEDURE Print1;

    PROCEDURE SetParamTag (pParamTag VARCHAR2);
END REPORTFL_ENGINE;
/


CREATE OR REPLACE PUBLIC SYNONYM REPORTFL_ENGINE FOR IKIS_SYSWEB.REPORTFL_ENGINE
/


GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.REPORTFL_ENGINE
IS
    g_f_format2    VARCHAR2 (20) := '9999999999990.00';
    bl             VARCHAR2 (4) := '0.00';

    exSection      EXCEPTION;
    exNoEndTag     EXCEPTION;

    TYPE r_param IS RECORD
    (
        param_name     VARCHAR2 (250),
        param_value    VARCHAR2 (32767)
    );

    TYPE t_params IS TABLE OF r_param;

    vTemplate      rpt_templates.rt_text%TYPE;
    vParams        t_params := t_params ();
    vParamTag      VARCHAR2 (1) := '#';
    vCode          rpt_templates.rt_code%TYPE;
    vName          rpt_templates.rt_name%TYPE;
    vType          rpt_templates.rt_file_tp%TYPE;

    vReport        BLOB;

    -- массив DataSet
    -- масив значень
    TYPE TArrField IS TABLE OF VARCHAR2 (2000)
        INDEX BY VARCHAR2 (20);

    -- один запис
    TYPE TOneRecord IS RECORD
    (
        Field    TArrField
    );

    -- масив записів
    TYPE TArrRecord IS TABLE OF TOneRecord
        INDEX BY BINARY_INTEGER;

    -- датасет
    TYPE TOneDataSet IS RECORD
    (
        Record    TArrRecord
    );

    -- масив датасетів
    TYPE TArrDataSet IS TABLE OF TOneDataSet
        INDEX BY VARCHAR2 (20);

    -- ДатаСети
    DataSet        TArrDataSet;

    -- масив пустих датасетів
    TYPE TArrDataSetEmpty IS TABLE OF VARCHAR2 (20)
        INDEX BY VARCHAR2 (20);

    -- ДатаСети
    DataSetEmpty   TArrDataSetEmpty;

    -- тип запису для зв`язку
    TYPE RRelation IS RECORD
    (
        Master         VARCHAR2 (20),
        MasterField    VARCHAR2 (20),
        Detail         VARCHAR2 (20),
        DetailField    VARCHAR2 (20)
    );

    -- тип зв`язку
    TYPE TRelation IS TABLE OF RRelation
        INDEX BY BINARY_INTEGER;

    -- масив зв`язків
    ArrRelation    TRelation;

    -- тип запису для Summary
    TYPE RSummary IS RECORD
    (
        DataSet    VARCHAR2 (20),
        Field      VARCHAR2 (20),
        TYPE       VARCHAR2 (20),
        Format     VARCHAR2 (20)
    );

    -- тип Summary
    TYPE TSummary IS TABLE OF RSummary
        INDEX BY BINARY_INTEGER;

    -- масив Summary
    ArrSummary     TSummary;

    -- масив данных для Summary
    DataSetSum     TArrDataSet;

    FUNCTION SUM_TO_TEXT (v_sum NUMBER)
        RETURN VARCHAR2
    IS
        -- Сумма прописью
        -- +27.01.2003
        -- Garder
        TYPE mass IS TABLE OF VARCHAR2 (20)
            INDEX BY BINARY_INTEGER;

        TYPE rec IS RECORD
        (
            a    VARCHAR2 (12),
            b    VARCHAR2 (12),
            c    VARCHAR2 (12),
            d    VARCHAR2 (12),
            e    VARCHAR2 (12)
        );

        TYPE razr IS TABLE OF rec
            INDEX BY BINARY_INTEGER;

        m1      mass;
        m1a     mass;
        m11     mass;
        m10     mass;
        m100    mass;
        r       razr;
        c       VARCHAR2 (255);
        n       NUMBER;
        i       NUMBER;
        again   BOOLEAN;
    BEGIN
        --**********************************  Заполняем массивы данными
        -- массив 1 разряда (разряды с конца)
        m1 (0) := '';
        m1 (1) := 'одна ';
        m1 (2) := 'дві ';
        m1 (3) := 'три ';
        m1 (4) := 'чотири ';
        m1 (5) := 'п''ять ';
        m1 (6) := 'шість ';
        m1 (7) := 'сім ';
        m1 (8) := 'вісім ';
        m1 (9) := 'дев''ять ';
        -- массив 1 разряда для тысяч
        m1a (0) := '';
        m1a (1) := 'один ';
        m1a (2) := 'два ';
        m1a (3) := 'три ';
        m1a (4) := 'чотири ';
        m1a (5) := 'п''ять ';
        m1a (6) := 'шість ';
        m1a (7) := 'сім ';
        m1a (8) := 'вісім ';
        m1a (9) := 'дев''ять ';
        -- массив 1 и 2 разрядов для чисел от 11 до 19
        m11 (0) := '';
        m11 (1) := 'одинадцять ';
        m11 (2) := 'дванадцять ';
        m11 (3) := 'тринадцять ';
        m11 (4) := 'чотирнадцять ';
        m11 (5) := 'п''ятнадцять ';
        m11 (6) := 'шістнадцять ';
        m11 (7) := 'сімнадцять ';
        m11 (8) := 'вісімнадцять ';
        m11 (9) := 'дев''ятнадцять ';
        -- массив 2 разряда
        m10 (0) := '';
        m10 (1) := 'десять ';
        m10 (2) := 'двадцять ';
        m10 (3) := 'тридцять ';
        m10 (4) := 'сорок ';
        m10 (5) := 'п''ятдесят ';
        m10 (6) := 'шістдесят ';
        m10 (7) := 'сімдесят ';
        m10 (8) := 'вісімдесят ';
        m10 (9) := 'дев''яносто ';
        -- массив 3 разряда
        m100 (0) := '';
        m100 (1) := 'сто ';
        m100 (2) := 'двісті ';
        m100 (3) := 'триста ';
        m100 (4) := 'чотириста ';
        m100 (5) := 'п''ятсот ';
        m100 (6) := 'шістсот ';
        m100 (7) := 'сімсот ';
        m100 (8) := 'вісімсот ';
        m100 (9) := 'дев''ятсот ';
        -- массив перед 1 разрядом
        r (0).a := 'грн. ';
        r (1).a := 'грн. ';
        r (2).a := 'грн. ';
        r (3).a := 'грн. ';
        r (4).a := 'грн. ';
        r (5).a := 'грн. ';
        r (6).a := 'грн. ';
        r (7).a := 'грн. ';
        r (8).a := 'грн. ';
        r (9).a := 'грн. ';
        -- массив перед 4 разрядом
        r (0).b := 'тисяч ';
        r (1).b := 'тисяча ';
        r (2).b := 'тисячі ';
        r (3).b := 'тисячі ';
        r (4).b := 'тисячі ';
        r (5).b := 'тисяч ';
        r (6).b := 'тисяч ';
        r (7).b := 'тисяч ';
        r (8).b := 'тисяч ';
        r (9).b := 'тисяч ';
        -- массив перед 7 разрядом
        r (0).c := 'мільйонів ';
        r (1).c := 'мільйон ';
        r (2).c := 'мільйони ';
        r (3).c := 'мільйони ';
        r (4).c := 'мільйони ';
        r (5).c := 'мільйонів ';
        r (6).c := 'мільйонів ';
        r (7).c := 'мільйонів ';
        r (8).c := 'мільйонів ';
        r (9).c := 'мільйонів ';
        -- массив перед 10 разрядом
        r (0).d := 'мільярдів ';
        r (1).d := 'мільярд ';
        r (2).d := 'мільярди ';
        r (3).d := 'мільярди ';
        r (4).d := 'мільярди ';
        r (5).d := 'мільярдів ';
        r (6).d := 'мільярдів ';
        r (7).d := 'мільярдів ';
        r (8).d := 'мільярдів ';
        r (9).d := 'мільярдів ';
        -- массив перед любым разрядом если он пустой
        r (0).e := '';
        r (1).e := '';
        r (2).e := '';
        r (3).e := '';
        r (4).e := '';
        r (5).e := '';
        r (6).e := '';
        r (7).e := '';
        r (8).e := '';
        r (9).e := '';
        -- *************************************  Печатаем копейки
        n := ABS (ROUND (v_sum, 2));
        c :=
               SUBSTR (TO_CHAR (n, '999999999999999999.99'),
                       LENGTH (TO_CHAR (n, '999999999999999999.99')) - 1,
                       2)
            || ' коп.';
        -- *************************************  Печатаем сумму
        i := 1;
        again := TRUE;

        WHILE again
        LOOP
            IF FLOOR (MOD (n, 100)) > 10 AND FLOOR (MOD (n, 100)) < 20
            THEN
                c := r (0).a || c;
                c := m11 (FLOOR (MOD (n, 10))) || c;
            ELSE
                c := r (FLOOR (MOD (n, 10))).a || c;

                IF i = 3 OR i = 4
                THEN
                    c := m1a (FLOOR (MOD (n, 10))) || c;
                ELSE
                    c := m1 (FLOOR (MOD (n, 10))) || c;
                END IF;

                c := m10 (FLOOR (MOD (TRUNC (n / 10, 0), 10))) || c;
            END IF;

            c := m100 (FLOOR (MOD (TRUNC (n / 100, 0), 10))) || c;
            n := TRUNC (n / 1000, 0);

            IF n = 0
            THEN
                again := FALSE;
            END IF;

            FOR j IN 0 .. 9
            LOOP
                IF i = 1
                THEN
                    r (j).a := r (j).b;
                END IF;

                IF i = 2
                THEN
                    r (j).a := r (j).c;
                END IF;

                IF i = 3
                THEN
                    r (j).a := r (j).d;
                END IF;

                IF MOD (n, 1000) = 0
                THEN
                    r (j).a := r (j).e;
                END IF;
            END LOOP;

            i := i + 1;
        END LOOP;

        IF FLOOR (ABS (v_sum)) = 0
        THEN
            c := 'нуль ' || c;
        END IF;

        IF v_sum < 0
        THEN
            c := 'мінус ' || c;
        END IF;

        RETURN (UPPER (SUBSTR (c, 1, 1)) || SUBSTR (c, 2, LENGTH (c) - 1));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'SUM_TO_TEXT Error: ' || SQLERRM,
                                     FALSE);
    END;

    FUNCTION ReplaceServSymb (pVar VARCHAR2)
        RETURN VARCHAR2
    AS
        Result   VARCHAR2 (2000);
    BEGIN
        result := pVar;
        result := REPLACE (result, '\', '/');                          --5C');
        --result := Replace(result, '/','/');--5C');
        result := REPLACE (result, '{', '\{');                         --7B');
        result := REPLACE (result, '}', '\}');                         --7D');
        result := REPLACE (result, '#', '№');
        result := REPLACE (result, '|EOL:', '{\par}');
        result := REPLACE (result, '|EOP:', '{\page}');
        RETURN result;
    END;

    -- склеивание
    PROCEDURE PasteReport2Part (pPart1    IN     BLOB,
                                pPart2    IN     BLOB,
                                pReport      OUT BLOB);

    -- построение DataSet
    PROCEDURE BuildDataSet (pReport        IN OUT BLOB,
                            pName          IN     VARCHAR2,
                            pFilterField   IN     VARCHAR2 := NULL,
                            pFilterValue   IN     VARCHAR2 := NULL,
                            pFlSummary            BOOLEAN := FALSE);

    PROCEDURE ClearParams
    IS
    BEGIN
        -- параметри
        IF vParams.COUNT > 0
        THEN
            vParams := NULL;
            vParams := t_params ();
        END IF;

        -- DataSet
        IF DataSet.COUNT > 0
        THEN
            DataSet.Delete;
        END IF;

        -- DataSetEmpty
        IF DataSetEmpty.COUNT > 0
        THEN
            DataSetEmpty.Delete;
        END IF;

        -- Relation
        IF ArrRelation.COUNT > 0
        THEN
            ArrRelation.Delete;
        END IF;

        -- Summary
        IF ArrSummary.COUNT > 0
        THEN
            ArrSummary.Delete;
        END IF;

        -- DataSetSum
        IF DataSetSum.COUNT > 0
        THEN
            DataSetSum.Delete;
        END IF;
    END;

    PROCEDURE InitReport (p_ss_code   rpt_templates.rt_ss_code%TYPE,
                          p_code      rpt_templates.rt_code%TYPE)
    IS
    BEGIN
        ClearParams;

        --dbms_lob.CreateTemporary(vTemplate, True, 10);
        SELECT rt_name, rt_text, rt_file_tp
          INTO vName, vTemplate, vType
          FROM rpt_templates
         WHERE rt_ss_code = p_ss_code AND rt_code = p_code;

        vCode := p_code;
    --dbms_lob.open(vTemplate, dbms_lob.lob_readonly);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.InitReport. Помилка ініціалізації звіту: '
                || SQLERRM);
    END;

    -- Додаємо параметр. Якщо вже існує з таким ім'ям - змінюємо значення.
    PROCEDURE AddParam (p_param_name VARCHAR2, p_param_value VARCHAR2)
    IS
        vInserted   BOOLEAN;
    BEGIN
        vInserted := FALSE;

        IF vParams.COUNT > 0
        THEN
            FOR i IN vParams.FIRST .. vParams.LAST
            LOOP
                IF vParams (i).param_name = p_param_name
                THEN
                    vParams (i).param_value := p_param_value;
                    vInserted := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF NOT vInserted
        THEN
            vParams.EXTEND;
            vParams (vParams.LAST).param_name := p_param_name;
            vParams (vParams.LAST).param_value := p_param_value;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'REPORTFL_ENGINE.AddParam. ' || SQLERRM);
    END;

    -- Кількість записів в DataSet
    FUNCTION RecordCount (p_DataSet       VARCHAR2,
                          p_FilterField   VARCHAR2,
                          p_FilterValue   VARCHAR2)
        RETURN INTEGER
    IS
        Result   INTEGER;
    BEGIN
        -- количество записей всего по таблице
        Result := DataSet (p_DataSet).Record.COUNT;

        -- количество записей по таблице Master-Detail
        IF p_FilterField IS NOT NULL
        THEN
            Result := 0;

            FOR rcd IN 1 .. DataSet (p_DataSet).Record.COUNT
            LOOP
                --dbms_output.put_line('RecordCount--' || p_DataSet || ' Field=' || p_FilterField || ' Value=' || p_FilterValue || ' ValueDS=' || DataSet(p_DataSet).Record(rcd).Field(p_FilterField));
                IF (DataSet (p_DataSet).Record (rcd).Field (p_FilterField) =
                    p_FilterValue)
                THEN
                    Result := Result + 1;
                --dbms_output.put_line('Result=' || Result);
                END IF;
            END LOOP;
        END IF;

        -- выдача
        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Result := 0;
            RETURN Result;
    END;

    -- Додаємо DataSet.
    PROCEDURE AddDataSet (p_DataSet VARCHAR2, p_Sql VARCHAR2)
    IS
        v_Cursor      INTEGER;
        v_NumColumn   INTEGER;
        v_DescInfo    DBMS_SQL.desc_tab;
        v_DescRec     DBMS_SQL.desc_rec;
        v_NumRec      INTEGER;
        v_Value       VARCHAR2 (2000);
    BEGIN
        -- проверка на существование
        IF ExistsDataSet (p_DataSet)
        THEN
            raise_application_error (
                -20000,
                   'Таблиця з ім`ям: '
                || p_DataSet
                || ' вже існує!'
                || CHR (10)
                || SQLERRM);
        END IF;

        -- открытие курсора
        v_cursor := DBMS_SQL.open_cursor;
        -- подготовка
        DBMS_SQL.parse (v_cursor, p_sql, DBMS_SQL.native);
        -- инфо по столбцам
        DBMS_SQL.describe_columns (v_cursor, v_NumColumn, v_DescInfo);

        -- пробежка по столбцам
        FOR idx IN 1 .. v_NumColumn
        LOOP
            -- определение выхода для столбцов
            DBMS_SQL.define_column (v_cursor,
                                    idx,
                                    v_Value,
                                    2000);
            -- инфо о записи
            v_DescRec := v_DescInfo (idx);
        END LOOP;

        -- ЗНАЧЕНИЯ
        -- выполнение запроса
        IF DBMS_SQL.execute (v_cursor) <> 0
        THEN
            raise_application_error (
                -20000,
                'Помилка при ініціалізації курсору: ' || CHR (10) || SQLERRM);
        END IF;

        -- № записи
        v_NumRec := 0;

        LOOP
            -- получение одной записи
            IF DBMS_SQL.fetch_rows (v_cursor) = 0
            THEN
                -- занесення в масив пустих DataSet
                DataSetEmpty (p_DataSet) := p_DataSet;
                EXIT;
            END IF;

            v_NumRec := v_NumRec + 1;

            -- пробежка по столбцам
            FOR idx IN 1 .. v_NumColumn
            LOOP
                -- получение значения
                DBMS_SQL.COLUMN_VALUE (v_cursor, idx, v_Value);

                IF vType = 'XML'
                THEN
                    v_Value := CONVERT (v_Value, 'UTF8');
                END IF;

                DataSet (p_DataSet).Record (v_NumRec).Field (
                    LOWER (v_DescInfo (idx).col_name)) :=
                    v_Value;
            END LOOP;
        END LOOP;

        -- закрытие курсора
        DBMS_SQL.close_cursor (v_Cursor);
    --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'AddDataSet ' || p_DataSet || ' count=' || RecordCount(p_DataSet, null, null));
    EXCEPTION
        WHEN OTHERS
        THEN
            IF DBMS_SQL.is_open (v_cursor)
            THEN
                DBMS_SQL.close_cursor (v_Cursor);
            END IF;

            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.AddDataSet. ' || SQLERRM);
    END;

    -- Пошук на існування DataSet
    FUNCTION ExistsDataSet (p_DataSet VARCHAR2)
        RETURN BOOLEAN
    IS
        Result   BOOLEAN;
        sName    VARCHAR2 (20);
    BEGIN
        Result := FALSE;
        -- перелік
        sName := DataSet.FIRST;

        FOR ds IN 1 .. DataSet.COUNT
        LOOP
            IF sName IS NOT NULL
            THEN
                IF sName = p_DataSet
                THEN
                    Result := TRUE;
                END IF;
            END IF;

            sName := DataSet.NEXT (sName);
        END LOOP;

        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ExistsDataSet. ' || SQLERRM);
    END;

    -- Пошук на існування DataSet
    FUNCTION ExistsDataSetEmpty (p_DataSet VARCHAR2)
        RETURN BOOLEAN
    IS
        Result   BOOLEAN;
        sName    VARCHAR2 (20);
    BEGIN
        Result := FALSE;
        -- перелік
        sName := DataSetEmpty.FIRST;

        FOR ds IN 1 .. DataSetEmpty.COUNT
        LOOP
            IF sName IS NOT NULL
            THEN
                IF sName = p_DataSet
                THEN
                    Result := TRUE;
                END IF;
            END IF;

            sName := DataSetEmpty.NEXT (sName);
        END LOOP;

        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ExistsDataSetEmpty. ' || SQLERRM);
    END;

    -- додаємо зв`язок між DataSet
    PROCEDURE AddRelation (pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2)
    IS
        flInserted   BOOLEAN;
        vIdx         INTEGER;
    BEGIN
        flInserted := ExistsRelation (pMaster, pDetail, 1);

        IF flInserted
        THEN
            raise_application_error (
                -20000,
                   'Зв`язок між таблицями: '
                || pMaster
                || ' та '
                || pDetail
                || ' вже існує!'
                || CHR (10)
                || SQLERRM);
        ELSE
            vIdx := ArrRelation.COUNT + 1;
            ArrRelation (vIdx).Master := pMaster;
            ArrRelation (vIdx).MasterField := pMasterField;
            ArrRelation (vIdx).Detail := pDetail;
            ArrRelation (vIdx).DetailField := pDetailField;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.AddRelation. ' || SQLERRM);
    END;

    -- пошук на існування зв`язоку між DataSet
    -- параметр pType 1-связь  2-мастер 3-детайл
    FUNCTION ExistsRelation (pMaster   VARCHAR2,
                             pDetail   VARCHAR2,
                             pType     INTEGER:= 1)
        RETURN BOOLEAN
    IS
        Result   BOOLEAN;
    BEGIN
        Result := FALSE;

        -- перелік
        IF ArrRelation.COUNT > 0
        THEN
            FOR i IN ArrRelation.FIRST .. ArrRelation.LAST
            LOOP
                IF    (    pType = 1
                       AND ArrRelation (i).Master = pMaster
                       AND ArrRelation (i).Detail = pDetail)
                   OR (pType = 2 AND ArrRelation (i).Master = pMaster)
                   OR (pType = 3 AND ArrRelation (i).Detail = pDetail)
                THEN
                    Result := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        -- выдача
        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ExistsRelation. ' || SQLERRM);
    END;

    -- додаємо Summary
    PROCEDURE AddSummary (pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2)
    IS
        flInserted   BOOLEAN;
        vIdx         INTEGER;
    BEGIN
        flInserted :=
            ExistsSummary (pDataSet,
                           pField,
                           pType,
                           1);

        IF flInserted
        THEN
            raise_application_error (
                -20000,
                   'Формування результатів по таблиці: '
                || pDataSet
                || ' по полю '
                || pField
                || ' з типом '
                || pType
                || ' вже існує!'
                || CHR (10)
                || SQLERRM);
        ELSE
            vIdx := ArrSummary.COUNT + 1;
            ArrSummary (vIdx).DataSet := pDataSet;
            ArrSummary (vIdx).Field := pField;
            ArrSummary (vIdx).TYPE := pType;
            ArrSummary (vIdx).Format := pFormat;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.AddSummary. ' || SQLERRM);
    END;

    -- пошук на існування Summary
    -- параметр pTypeExists 1-суммировка вцелом 2-поиск только для DataSet
    FUNCTION ExistsSummary (pDataSet      VARCHAR2,
                            pField        VARCHAR2,
                            pType         VARCHAR2,
                            pTypeExists   INTEGER:= 1)
        RETURN BOOLEAN
    IS
        Result   BOOLEAN;
    BEGIN
        Result := FALSE;

        -- перелік
        IF ArrSummary.COUNT > 0
        THEN
            FOR i IN ArrSummary.FIRST .. ArrSummary.LAST
            LOOP
                IF    (    pTypeExists = 1
                       AND ArrSummary (i).DataSet = pDataSet
                       AND ArrSummary (i).Field = pField
                       AND ArrSummary (i).TYPE = pType)
                   OR (pTypeExists = 2 AND ArrSummary (i).DataSet = pDataSet)
                THEN
                    Result := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        -- выдача
        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ExistsSummary. ' || SQLERRM);
    END;

    -- Значення параметрів можуть містити спецвирази форматування відображення або символи опсу формату RTF
    PROCEDURE ParseParams
    IS
    BEGIN
        IF vParams.COUNT > 0
        THEN
            FOR i IN vParams.FIRST .. vParams.LAST
            LOOP
                IF vType = 'RTF'
                THEN
                    vParams (i).param_value :=
                        ReplaceServSymb (vParams (i).param_value);
                --vParams(i).param_value := Replace(vParams(i).param_value, '\','\5C');
                --vParams(i).param_value := Replace(vParams(i).param_value, '{','\7B');
                --vParams(i).param_value := Replace(vParams(i).param_value, '}','\7D');
                --vParams(i).param_value := Replace(vParams(i).param_value, '|EOL:','{\par}');
                --vParams(i).param_value := Replace(vParams(i).param_value, '|EOP:','{\page}');
                ELSIF vType = 'XML'
                THEN
                    vParams (i).param_value :=
                        CONVERT (vParams (i).param_value, 'UTF8');
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ParseParams. ' || SQLERRM);
    END;

    -- Отримуємо значення параметрів. DATE, TIME та EOP - особливі
    -- Потрібно ще реалиізувати обробку можливості задання всіляких хитрощів - для цього треба ДУЖЕ уважно прочитати код RepoRTFM.pas
    FUNCTION GetParamValue (p_param_name VARCHAR2)
        RETURN VARCHAR2
    IS
        vTemp   VARCHAR2 (32767);
    BEGIN
        vTemp := '';

        IF TRIM (UPPER (p_param_name)) = 'DATE'
        THEN
            vTemp := TO_CHAR (SYSDATE, 'DD.MM.YYYY');
        ELSIF TRIM (UPPER (p_param_name)) = 'TIME'
        THEN
            vTemp := TO_CHAR (SYSDATE, 'HH24:MI');
        ELSIF TRIM (UPPER (p_param_name)) = 'EOP'
        THEN
            IF vType = 'RTF'
            THEN
                vTemp := '{\page}';
            ELSE
                vTemp := '{\014}';
            END IF;
        ELSIF p_param_name IS NOT NULL
        THEN
            IF vParams.COUNT > 0
            THEN
                FOR i IN vParams.FIRST .. vParams.LAST
                LOOP
                    IF TRIM (UPPER (p_param_name)) =
                       TRIM (UPPER (vParams (i).param_name))
                    THEN
                        vTemp := vParams (i).param_value;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END IF;

        RETURN vTemp;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.GetParamValue. ' || SQLERRM);
    END;

    PROCEDURE ParIntoReport
    IS
        vCurPos        INTEGER;
        vLength        INTEGER;
        vBuff          RAW (32767);
        vParPozStart   INTEGER;
        vParPozStop    INTEGER;
        vBuffEndPos    INTEGER;
        vParamName     VARCHAR2 (250);
        vParamValue    VARCHAR2 (32767);
    BEGIN
        vLength := DBMS_LOB.GetLength (vTemplate);
        vCurPos := 1;
        DBMS_LOB.CreateTemporary (vReport, TRUE, 10);
        DBMS_LOB.Open (vReport, DBMS_LOB.lob_readwrite);

        WHILE vCurPos < vLength
        LOOP
            -- Шукаємо початок та кінець чергового параметру в шаблоні
            vParPozStart :=
                DBMS_LOB.INSTR (vTemplate,
                                UTL_RAW.cast_to_raw (vParamTag),
                                vCurPos,
                                1);
            vParPozStop :=
                DBMS_LOB.INSTR (vTemplate,
                                UTL_RAW.cast_to_raw (vParamTag),
                                vCurPos,
                                2);

            IF vParPozStart = 0
            THEN -- Якщо параметрів більше немає: все до кінця шаблону - в звіт
                vBuffEndPos := vLength;
            ELSE -- Якщо початок параметру є, то в звіт все до початку параметру
                vBuffEndPos := vParPozStart - 1;
            END IF;

            -- Записуємо в звіт незмінну частину шаблону
            WHILE vBuffEndPos - vCurPos + 1 > 32517
            LOOP
                vBuff := DBMS_LOB.SUBSTR (vTemplate, 32517, vCurPos);
                DBMS_LOB.WriteAppend (vReport, LENGTH (vBuff) / 2, vBuff);
                vCurPos := vCurPos + 32517;
            END LOOP;

            vBuff :=
                DBMS_LOB.SUBSTR (vTemplate,
                                 vBuffEndPos - vCurPos + 1,
                                 vCurPos);

            --dbms_output.put_line(vCurPos);
            IF vParPozStop > 0 AND (vParPozStop - vParPozStart - 1) <= 250
            THEN
                vParamName :=
                    UTL_RAW.cast_to_varchar2 (
                        DBMS_LOB.SUBSTR (vTemplate,
                                         vParPozStop - vParPozStart - 1,
                                         vParPozStart + 1));
                --if vParamName = 'dpn_full_sum' then
                --dbms_output.put_line(vParamName);
                --end if;
                --dbms_output.put_line(vParamName);
                vParamValue := GetParamValue (vParamName);

                IF vParamValue IS NOT NULL
                THEN
                    --dbms_output.put_line('b_buff_length='||Length(vBuff));
                    vBuff :=
                        UTL_RAW.CONCAT (vBuff,
                                        UTL_RAW.cast_to_raw (vParamValue));
                --dbms_output.put_line('u_buff_length='||Length(vBuff));
                END IF;
            END IF;

            DBMS_LOB.WriteAppend (vReport, LENGTH (vBuff) / 2, vBuff);

            IF vParPozStop > 0
            THEN
                vCurPos := vParPozStop + 1;
            ELSE
                vCurPos := vLength;
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.ParIntoReport. ' || SQLERRM);
    END;

    -- +Kalev 18.02.2008
    -- Получение позиции последнего вхождения
    FUNCTION InStrUnDirect (pBlob     BLOB,
                            pSubStr   VARCHAR2,
                            pMaxPos   INTEGER:= NULL)
        RETURN INTEGER
    IS
        Result    INTEGER;
        flPos     BOOLEAN;
        vPos      INTEGER;
        vMaxPos   INTEGER;
    BEGIN
        Result := 0;
        flPos := TRUE;
        vPos := 1;

        IF (pMaxPos IS NULL OR pMaxPos = 0)
        THEN
            vMaxPos := DBMS_LOB.GetLength (pBlob);
        ELSE
            vMaxPos := pMaxPos;
        END IF;

        WHILE (flPos) AND (vPos > 0) AND (vPos <= vMaxPos)
        LOOP
            vPos :=
                DBMS_LOB.INSTR (pBlob,
                                UTL_RAW.cast_to_raw (pSubStr),
                                vPos,
                                1);

            IF vPos = 0
            THEN
                flPos := FALSE;
            ELSE
                IF vPos < vMaxPos
                THEN
                    Result := vPos;
                END IF;

                vPos := vPos + 1;
            END IF;
        END LOOP;

        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.InStrUnDirect. ' || SQLERRM);
    END;

    -- +Kalev 18.02.2008
    -- Вырезка из отчета одной части
    PROCEDURE CutReport1Part (pReport   IN     BLOB,
                              pStart    IN     INTEGER,
                              pStop     IN     INTEGER,
                              pPart        OUT BLOB)
    IS
        vCurPos   INTEGER;
        vBuff     RAW (32767);
    BEGIN
        -- сотворение
        DBMS_LOB.CreateTemporary (pPart, TRUE, 10);
        DBMS_LOB.Open (pPart, DBMS_LOB.lob_readwrite);

        -- перекидка
        IF pStart <= DBMS_LOB.GetLength (pReport)
        THEN
            vCurPos := pStart;

            IF vCurPos = 0
            THEN
                vCurPos := 1;
            END IF;

            WHILE pStop - vCurPos + 1 > 32517
            LOOP
                vBuff := DBMS_LOB.SUBSTR (pReport, 32517, vCurPos);
                DBMS_LOB.WriteAppend (pPart, LENGTH (vBuff) / 2, vBuff);
                vCurPos := vCurPos + 32517;
            END LOOP;

            vBuff := DBMS_LOB.SUBSTR (pReport, pStop - vCurPos + 1, vCurPos);
            DBMS_LOB.WriteAppend (pPart, LENGTH (vBuff) / 2, vBuff);
        ELSE
            pPart := NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CutReport1Part. ' || SQLERRM);
    END;

    -- +Kalev 18.02.2008
    -- Разрезка отчета на две части по позициям
    PROCEDURE CutReport2Part (pReport   IN     BLOB,
                              pStart    IN     INTEGER,
                              pStop     IN     INTEGER,
                              pPart1       OUT BLOB,
                              pPart2       OUT BLOB)
    IS
    BEGIN
        -- сотворение
        DBMS_LOB.CreateTemporary (pPart1, TRUE, 10);
        DBMS_LOB.Open (pPart1, DBMS_LOB.lob_readwrite);
        DBMS_LOB.CreateTemporary (pPart2, TRUE, 10);
        DBMS_LOB.Open (pPart2, DBMS_LOB.lob_readwrite);

        -- вырезка первой части
        IF pStart > 1
        THEN
            CutReport1Part (pReport,
                            1,
                            pStart - 1,
                            pPart1);
        END IF;

        -- вырезка второй части
        CutReport1Part (pReport,
                        pStop + 1,
                        DBMS_LOB.GetLength (pReport),
                        pPart2);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CutReport2Part. ' || SQLERRM);
    END;

    -- +Kalev 20.02.2008
    -- Вырезка из BLOB подстроки
    PROCEDURE CutReportStrok (pReport   IN OUT BLOB,
                              pStart    IN     INTEGER,
                              pStop     IN     INTEGER)
    IS
        vPart1   BLOB;
        vPart2   BLOB;
    BEGIN
        --dbms_output.put_line('pStop=' || pStop || ' length=' || dbms_lob.GetLength(pReport));
        -- вырезка пред и пост
        CutReport2Part (pReport,
                        pStart,
                        pStop,
                        vPart1,
                        vPart2);
        -- склеивание
        --dbms_output.put_line('Paste=' || utl_raw.cast_to_varchar2(dbms_lob.Substr(vPart2, dbms_lob.getlength(vPart2), 1)));
        PasteReport2Part (vPart1, vPart2, pReport);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CutReportStrok. ' || SQLERRM);
    END;

    -- +Kalev 28.02.2008
    -- Вырезка из BLOB имени DataSet с переводом на новую строку
    PROCEDURE CutDataSetTag (pReport IN OUT BLOB, pNameDS IN VARCHAR2)
    IS
        vNameDS       VARCHAR2 (30);
        vStartClear   INTEGER;
        vPosCR        INTEGER;
        vPosTag       INTEGER;
        vPosGroup     INTEGER;
        vPosGroup2    INTEGER;
        sTemp         VARCHAR2 (32000);
    BEGIN
        vNameDS := pNameDS;
        -- позиция начала
        vStartClear :=
            DBMS_LOB.INSTR (pReport,
                            UTL_RAW.cast_to_raw (vNameDS),
                            1,
                            1);

        -- для html вырезаем с переводом на новую строку
        IF vType IN ('HTML', 'XML')
        THEN
            IF DBMS_LOB.INSTR (
                   pReport,
                   UTL_RAW.cast_to_raw (vNameDS || CHR (13) || CHR (10)),
                   1,
                   1) = vStartClear
            THEN
                vNameDS := vNameDS || CHR (13) || CHR (10);
            ELSE
                IF   DBMS_LOB.INSTR (
                         pReport,
                         UTL_RAW.cast_to_raw (
                             CHR (13) || CHR (10) || vNameDS),
                         1,
                         1)
                   + 2 = vStartClear
                THEN
                    vStartClear := vStartClear - 2;
                    vNameDS := CHR (13) || CHR (10) || vNameDS;
                END IF;
            END IF;
        ELSE
            -- поиск закрытия группы
            vPosGroup :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw ('}'),
                                vStartClear,
                                1);
            vPosGroup2 :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw ('}'),
                                vStartClear,
                                2);
            -- поиск перевода на новую строку
            vPosCR :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw ('\par '),
                                vStartClear,
                                1);
            -- поиск следующего тега
            vPosTag :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw (vParamTag),
                                vStartClear + LENGTH (vNameDS),
                                1);

            --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'vNameDS=' || vNameDS ||' vStartClear=' || vStartClear || ' vPosCR=' || vPosCR || ' vPosGroup=' || vPosGroup || ' vPosGroup2=' || vPosGroup2 || ' vPosTag=' || vPosTag);
            -- вырезка перевода строки в данной группе
            IF     (vPosCR > 0)
               AND (vPosCR < vPosGroup)
               AND (vPosTag = 0 OR (vPosTag > 0 AND vPosCR < vPosTag))
            THEN
                --dbms_output.put_line('cut CR');
                CutReportStrok (pReport,
                                vPosCR,
                                vPosCR + LENGTH ('\par ') - 1);
            -- вырезка перевода строки в следующей группе
            ELSIF     (vPosCR > 0)
                  AND (vPosCR < vPosGroup2)
                  AND (vPosTag = 0 OR (vPosTag > 0 AND vPosCR < vPosTag))
            THEN
                --dbms_output.put_line('cut2 CR');
                CutReportStrok (pReport,
                                vPosCR,
                                vPosCR + LENGTH ('\par ') - 1);
            END IF;
        END IF;

        -- вырезка имени DataSet
        CutReportStrok (pReport,
                        vStartClear,
                        vStartClear + LENGTH (vNameDS) - 1);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CutDataSetTag. ' || SQLERRM);
    END;

    -- +Kalev 28.02.2008
    -- Проверка группы на перевод на новую строку
    FUNCTION IsParGroup (pReport IN OUT BLOB)
        RETURN BOOLEAN
    IS
        Result     BOOLEAN;
        vPosCR     INTEGER;
        vPosTag    INTEGER;
        vPosPage   INTEGER;
    BEGIN
        Result := FALSE;
        -- поиск перевода на новую строку
        vPosCR :=
            DBMS_LOB.INSTR (pReport,
                            UTL_RAW.cast_to_raw ('\par '),
                            1,
                            1);
        -- поиск следующего тега
        vPosTag :=
            DBMS_LOB.INSTR (pReport,
                            UTL_RAW.cast_to_raw (vParamTag),
                            1,
                            1);
        -- поиск нового листа
        vPosPage :=
            DBMS_LOB.INSTR (pReport,
                            UTL_RAW.cast_to_raw ('\page '),
                            1,
                            1);

        IF (vPosCR > 0) AND (vPosTag = 0) AND (vPosPage = 0)
        THEN
            Result := TRUE;
        END IF;

        -- выдача
        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.IsParGroup. ' || SQLERRM);
    END;

    -- +Kalev 07.03.2009
    -- Подсчет количества символов в blob`е
    FUNCTION CountSymbol (pReport IN BLOB, pSymbol IN VARCHAR2)
        RETURN INTEGER
    IS
        Result       INTEGER;
        vCurPos      INTEGER;
        vPosSymbol   INTEGER;
    BEGIN
        Result := 0;
        -- начальная позиция
        vCurPos := 1;

        -- подсчет
        LOOP
            vPosSymbol :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw (pSymbol),
                                vCurPos,
                                1);

            IF vPosSymbol > 0
            THEN
                Result := Result + 1;
                vCurPos := vPosSymbol + LENGTH (pSymbol);
            ELSE
                EXIT;
            END IF;
        END LOOP;

        -- выдача
        RETURN Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CountSymbol. ' || SQLERRM);
    END;

    -- +Kalev 19.02.2008
    -- Определение начала-конца@ и чистого DataSet
    PROCEDURE CutReportDataSet (pReport       IN     BLOB,
                                pName         IN     VARCHAR2,
                                pStart        IN OUT INTEGER,
                                pStop         IN OUT INTEGER,
                                pRepDataSet      OUT BLOB)
    IS
        sNameDS     VARCHAR2 (30);
        vCurPos     INTEGER;
        vTmpBlob    BLOB;
        vStopAdd    INTEGER;
        --vStartClear integer;
        --vStopClear integer;
        vPosCR      INTEGER;
        vPosTag     INTEGER;
        vPosGroup   INTEGER;
    BEGIN
        -- сотворение
        DBMS_LOB.CreateTemporary (pRepDataSet, TRUE, 10);
        DBMS_LOB.Open (pRepDataSet, DBMS_LOB.lob_readwrite);
        -- имя
        sNameDS := vParamTag || pName || vParamTag;
        -- ищем DataSet
        vCurPos := pStart;

        -- ищем начало DataSet
        IF vType IN ('HTML', 'XML')
        THEN
            pStart :=
                  DBMS_LOB.INSTR (pReport,
                                  UTL_RAW.cast_to_raw (sNameDS),
                                  vCurPos,
                                  1)
                - 1;
        ELSE
            pStart :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw (sNameDS),
                                vCurPos,
                                1);

            IF pStart > 0
            THEN
                CutReport1Part (pReport,
                                vCurPos,
                                pStart - 1,
                                vTmpBlob);
                pStart := InStrUnDirect (vTmpBlob, '{');
            END IF;
        END IF;

        --dbms_output.put_line(sNameDS || '-' || pStart);
        --dbms_output.put_line('{-' || pStart);
        -- ищем конец@ DataSet
        IF vType IN ('HTML', 'XML')
        THEN
            pStop :=
                  DBMS_LOB.INSTR (pReport,
                                  UTL_RAW.cast_to_raw (sNameDS),
                                  vCurPos,
                                  2)
                + LENGTH (sNameDS);

            IF   DBMS_LOB.INSTR (
                     pReport,
                     UTL_RAW.cast_to_raw (sNameDS || CHR (13) || CHR (10)),
                     vCurPos,
                     2)
               + LENGTH (sNameDS) = pStop
            THEN
                pStop := pStop + LENGTH (CHR (13) || CHR (10));
            END IF;
        ELSE
            pStop :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw (sNameDS),
                                vCurPos,
                                2);

            IF pStop > 0
            THEN
                pStop :=
                    DBMS_LOB.INSTR (pReport,
                                    UTL_RAW.cast_to_raw ('}'),
                                    pStop,
                                    1);
            END IF;
        END IF;

        --dbms_output.put_line(sNameDS || '-' || pStop);
        --dbms_output.put_line('}-' || pStop);
        IF (pStart >= 0) AND (pStop > 0)
        THEN
            -- поиск на перевод строки
            /*vStopAdd := dbms_lob.InStr(pReport, utl_raw.cast_to_raw('}'), pStop, 2);
            if (vStopAdd > pStop) then
              CutReport1Part(pReport, pStop, vStopAdd, vTmpBlob);
              if (dbms_lob.InStr(vTmpBlob, utl_raw.cast_to_raw('\par '), 1, 1) > 0) then
                pStop := vStopAdd;
              end if;
            end if;*/
            --dbms_output.put_line('}-' || pStop);
            -- вырезка DataSet полного
            -- CutReport1Part(pReport, pStart, pStop, vTmpBlob);
            -- переделано на вырезку
            /*
            -- чистое начало
            vStartClear := dbms_lob.InStr(vTmpBlob, utl_raw.cast_to_raw('}'), 1, 1) + 1;
            -- чистый конец@
            vCurPos := dbms_lob.InStr(vTmpBlob, utl_raw.cast_to_raw(sNameDS), 1, 2);
            vStopClear := InStrUnDirect(vTmpBlob, '{', vCurPos) - 1;
            -- вырезка DataSet
            CutReport1Part(vTmpBlob, vStartClear, vStopClear, pRepDataSet);
            -- прибитие перевода на новую строку
            vPosCR := dbms_lob.InStr(pRepDataSet, utl_raw.cast_to_raw('\par '), 1, 1);
            vCurPos := dbms_lob.InStr(pRepDataSet, utl_raw.cast_to_raw('}'), 1, 1);
            --dbms_output.put_line(sNameDS || '-' || ' vPosCR-' || vPosCR || ' vCurPos-' || vCurPos);
            if (vPosCR > 0) and (vPosCR < vCurPos) then
              CutReportStrok(pRepDataSet, vPosCR, vPosCR + Length('\par ') - 1);
            end if;
            */
            -- проверка на новую строку в конечной группе для DataSet
            vPosTag :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw (sNameDS),
                                pStart,
                                2);
            vPosCR :=
                DBMS_LOB.INSTR (pReport,
                                UTL_RAW.cast_to_raw ('\par '),
                                vPosTag,
                                1);

            -- проверка на новую строку в следующей, после конечной, группе
            IF (vPosCR > pStop)
            THEN
                vStopAdd :=
                    DBMS_LOB.INSTR (pReport,
                                    UTL_RAW.cast_to_raw ('}'),
                                    pStop,
                                    2);
                CutReport1Part (pReport,
                                pStop,
                                vStopAdd,
                                vTmpBlob);

                IF IsParGroup (vTmpBlob)
                THEN
                    pStop := vStopAdd;
                END IF;
            END IF;

            -- вырезка DataSet
            CutReport1Part (pReport,
                            pStart,
                            pStop,
                            vTmpBlob);
            -- парсинг и вырезка ненужного имени DataSet и перевода каретки
            -- начало
            CutDataSetTag (vTmpBlob, sNameDS);
            -- конец
            CutDataSetTag (vTmpBlob, sNameDS);
            --dbms_output.put_line('---');
            --dbms_output.put_line(utl_raw.cast_to_varchar2(vTmpBlob));
            --dbms_output.put_line('---');
            -- выдача
            pRepDataSet := vTmpBlob;

            --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||sNameDS || ' count symbol <{>=' || CountSymbol(pRepDataSet, '{') || ' <}>=' || CountSymbol(pRepDataSet, '}'));
            -- +Kalev 07.03.2009
            IF CountSymbol (pRepDataSet, '{') <>
               CountSymbol (pRepDataSet, '}')
            THEN
                RAISE exSection;
            END IF;
        END IF;
    EXCEPTION
        WHEN exSection
        THEN
            raise_application_error (
                -20000,
                   'DataSet '
                || pName
                || ' неможливо коректно визначити кількість секцій!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.CutReportDataSet. ' || SQLERRM);
    END;

    -- +Kalev 18.02.2008
    -- Склеивание отчета из двух частей
    PROCEDURE PasteReport2Part (pPart1    IN     BLOB,
                                pPart2    IN     BLOB,
                                pReport      OUT BLOB)
    IS
        vCurPos   INTEGER;
        vBuff     RAW (32767);
        vLength   INTEGER;
    BEGIN
        -- сотворение
        ---dbms_lob.CreateTemporary(pReport, True, 10);
        ---dbms_lob.Open(pReport, dbms_lob.lob_readwrite);
        -- перекидка
        pReport := pPart1;

        -- склейка
        IF pPart2 IS NOT NULL
        THEN
            vCurPos := 1;
            vLength := DBMS_LOB.GetLength (pPart2);

            WHILE vLength - vCurPos + 1 > 32517
            LOOP
                vBuff := DBMS_LOB.SUBSTR (pPart2, 32517, vCurPos);
                DBMS_LOB.WriteAppend (pReport, LENGTH (vBuff) / 2, vBuff);
                vCurPos := vCurPos + 32517;
            END LOOP;

            vBuff := DBMS_LOB.SUBSTR (pPart2, vLength - vCurPos + 1, vCurPos);
            /*if dbms_lob.getlength(pPart2) < 10 then
              dbms_output.put_line('Part2=' || utl_raw.cast_to_varchar2(dbms_lob.Substr(pPart2, dbms_lob.getlength(pPart2), 1)));
            end if;*/
            DBMS_LOB.WriteAppend (pReport, LENGTH (vBuff) / 2, vBuff);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.PasteReport2Part. ' || SQLERRM);
    END;

    -- +Kalev 22.02.2008
    -- заполнение Summary
    PROCEDURE BuildSummary (pName IN VARCHAR2, pRecDS IN INTEGER:= 0)
    IS
        vField   VARCHAR2 (30);
        vValue   NUMBER;
    --vValue varchar2(100);
    BEGIN
        --+Slaviq 03042009 добавил
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''. ''';

        ---SLaviq
        IF ArrSummary.COUNT > 0
        THEN
            FOR i IN ArrSummary.FIRST .. ArrSummary.LAST
            LOOP
                IF ArrSummary (i).DataSet = pName
                THEN
                    -- поле
                    vField :=
                        ArrSummary (i).Field || '_' || ArrSummary (i).TYPE;

                    -- обнуление
                    IF pRecDs = 0
                    THEN
                        -- для количества
                        DataSetSum (pName).Record (1).Field (vField) := 0;
                        -- для суммы
                        DataSetSum (pName).Record (2).Field (vField) := 0;
                    ELSE
                        -- для количества
                        DataSetSum (pName).Record (1).Field (vField) :=
                            DataSetSum (pName).Record (1).Field (vField) + 1;
                        -- для суммы
                        -- +Kalev 03.03.2009 сделал через number в связи с периодом (1.45666666666666666)
                        -- +Frolov 20080529 добавил nvl в to_namber т.к. если в списке хоть одна запись с нулом - в итоге получался нул
                        vValue :=
                            TO_NUMBER (
                                REPLACE (
                                    NVL (
                                        TRIM (
                                            NVL (
                                                DataSet (pName).Record (
                                                    pRecDS).Field (
                                                    ArrSummary (i).Field),
                                                '0')),
                                        bl),
                                    ',',
                                    '.'));
                        --+Slaviq 03042009 бло такое
                        --'.', ','));
                        ---Slaviq
                        DataSetSum (pName).Record (2).Field (vField) :=
                              --DataSetSum(pName).Record(2).Field(vField) + to_number(nvl(trim(Replace(DataSet(pName).Record(pRecDS).Field(ArrSummary(i).Field),  '.', ',')), bl), g_f_format2);
                              DataSetSum (pName).Record (2).Field (vField)
                            + vValue;
                    -- -Frolov
                    -- -Kalev 03.03.2009
                    END IF;
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                REPLACE (
                       DBMS_UTILITY.FORMAT_ERROR_STACK
                    || ' => '
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                    'ORA-20000:'));
    --raise_application_error(-20000, 'REPORTFL_ENGINE.BuildSummary. DataSet-' || pName || ' record-' || pRecDS || ' field-' || vField || ' value=<' || vValue || '>. ' || sqlerrm);
    END;

    -- +Kalev 19.02.2008
    -- Заполнение DataSet
    PROCEDURE FillDataSet (pReport        IN OUT BLOB,
                           pName          IN     VARCHAR2,
                           pFilterField   IN     VARCHAR2 := NULL,
                           pFilterValue   IN     VARCHAR2 := NULL)
    IS
        flInsert     BOOLEAN;
        vReport      BLOB;
        vRepOne      BLOB;
        sFieldName   VARCHAR2 (30);
        vPosVar      INTEGER;
        vRepPre      BLOB;
        vRepPost     BLOB;
        vVar         VARCHAR2 (2000);
    BEGIN
        -- сотворение
        DBMS_LOB.CreateTemporary (vReport, TRUE, 10);
        DBMS_LOB.Open (vReport, DBMS_LOB.lob_readwrite);

        -- подготовка суммировки
        IF ExistsSummary (pName,
                          NULL,
                          NULL,
                          2)
        THEN
            BuildSummary (pName, 0);
        END IF;

        -- пробежка по записям
        FOR rcd IN 1 .. DataSet (pName).Record.COUNT
        LOOP
            flInsert :=
                   (pFilterField IS NULL)
                OR (    pFilterField IS NOT NULL
                    AND DataSet (pName).Record (rcd).Field (pFilterField) =
                        pFilterValue);

            -- добавление строки
            IF flInsert
            THEN
                --dbms_output.put_line('DataSet=' || pName || ' record=' || rcd || ' FilterField=' || pFilterField || ' FilterValue=' || pFilterValue);
                vRepOne := pReport;
                -- замена переменных #XXX#
                -- пробежка по DataSet
                sFieldName := DataSet (pName).Record (rcd).Field.FIRST;

                FOR fld IN 1 .. DataSet (pName).Record (rcd).Field.COUNT
                LOOP
                    IF sFieldName IS NOT NULL
                    THEN
                        -- поиск переменной в шаблоне
                        vVar :=
                            ReplaceServSymb (
                                DataSet (pName).Record (rcd).Field (
                                    sFieldName));
                        vPosVar :=
                            DBMS_LOB.INSTR (
                                vRepOne,
                                UTL_RAW.cast_to_raw (
                                    vParamTag || sFieldName || vParamTag),
                                1,
                                1);

                        -- замена по циклу
                        WHILE     (vPosVar > 0)
                              AND (   (vVar <>
                                       vParamTag || sFieldName || vParamTag)
                                   OR (vVar IS NULL))
                        LOOP
                            --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'DataSet=' || pName || ' sFieldName=' || sFieldName || ' vVar=' || vVar || ' vPosVar=' || vPosVar);
                            -- вырезка пред и пост
                            CutReport2Part (
                                vRepOne,
                                vPosVar,
                                  vPosVar
                                + LENGTH (
                                      vParamTag || sFieldName || vParamTag)
                                - 1,
                                vRepPre,
                                vRepPost);
                            PasteReport2Part (vRepPre,
                                              UTL_RAW.cast_to_raw (vVar),
                                              vRepOne);
                            PasteReport2Part (vRepOne, vRepPost, vRepOne);
                            vPosVar :=
                                DBMS_LOB.INSTR (
                                    vRepOne,
                                    UTL_RAW.cast_to_raw (
                                        vParamTag || sFieldName || vParamTag),
                                    1,
                                    1);
                        END LOOP;
                    END IF;

                    sFieldName :=
                        DataSet (pName).Record (rcd).Field.NEXT (sFieldName);
                END LOOP;

                -- проверка на мастера и построение
                IF ArrRelation.COUNT > 0
                THEN
                    FOR rlt IN ArrRelation.FIRST .. ArrRelation.LAST
                    LOOP
                        IF ArrRelation (rlt).Master = pName
                        THEN
                            --dbms_output.put_line('Master=' || pName || ' record=' || rcd || ' value=' || DataSet(pName).Record(rcd).Field(ArrRelation(rlt).MasterField) || ' Detail=' || ArrRelation(rlt).Detail || ' DetailField=' || ArrRelation(rlt).DetailField);
                            BuildDataSet (
                                vRepOne,
                                ArrRelation (rlt).Detail,
                                ArrRelation (rlt).DetailField,
                                DataSet (pName).Record (rcd).Field (
                                    ArrRelation (rlt).MasterField));
                        END IF;
                    END LOOP;
                END IF;

                -- склеивание
                PasteReport2Part (vReport, vRepOne, vReport);

                -- формирование суммировки
                IF ExistsSummary (pName,
                                  NULL,
                                  NULL,
                                  2)
                THEN
                    BuildSummary (pName, rcd);
                END IF;
            END IF;
        END LOOP;

        -- вставка суммировки
        --if ExistsSummary(pName, null, null, 2) then
        --dbms_output.put_line('Summary=' || pName || '_sum');
        ---BuildDataSet(vReport, pName || '_sum', null, null, True);
        --BuildDataSet(vReport, 'DetailDS_sum', null, null, True);
        --end if;
        -- выталкивание
        pReport := vReport;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.FillDataSet. ' || SQLERRM);
    END;

    -- +Kalev 22.02.2008
    -- Заполнение Summary
    PROCEDURE FillSummary (pReport IN OUT BLOB, pName IN VARCHAR2)
    IS
        vReport    BLOB;
        sName      VARCHAR2 (30);
        vField     VARCHAR2 (30);
        vVar       VARCHAR2 (2000);
        vPosVar    INTEGER;
        vRepPre    BLOB;
        vRepPost   BLOB;
        vFormat    VARCHAR2 (100);
    BEGIN
        -- сотворение
        DBMS_LOB.CreateTemporary (vReport, TRUE, 10);
        DBMS_LOB.Open (vReport, DBMS_LOB.lob_readwrite);
        -- вырезка чистой таблицы
        sName := SUBSTR (pName, 1, LENGTH (pName) - 4);

        -- простановка сумм
        -- +Kalev 04.03.2009 проверка на кол-во записей
        IF (ArrSummary.COUNT > 0) AND (RecordCount (sName, NULL, NULL) > 0)
        THEN
            -- -Kalev 04.03.2009
            FOR i IN ArrSummary.FIRST .. ArrSummary.LAST
            LOOP
                IF ArrSummary (i).DataSet = sName
                THEN
                    -- поле
                    vField :=
                        ArrSummary (i).Field || '_' || ArrSummary (i).TYPE;

                    -- формат
                    IF    (NVL (ArrSummary (i).Format, '~') = '~')
                       OR (ArrSummary (i).Format = '')
                    THEN
                        vFormat := g_f_format2;
                    ELSE
                        vFormat := ArrSummary (i).Format;
                    END IF;

                    -- поиск и замена
                    IF ArrSummary (i).TYPE = 'count'
                    THEN
                        vVar := DataSetSum (sName).Record (1).Field (vField);
                    ELSIF ArrSummary (i).TYPE = 'sum'
                    THEN
                        BEGIN
                            vVar :=
                                NVL (
                                    TO_CHAR (
                                        DataSetSum (sName).Record (2).Field (
                                            vField),
                                        vFormat),
                                    bl);
                        EXCEPTION
                            -- Sbond 20120417 Добавил обработчик так как падал отчет
                            WHEN NO_DATA_FOUND
                            THEN
                                vVar := NULL;
                        END;
                    ELSIF ArrSummary (i).TYPE = 'avg'
                    THEN
                        vVar :=
                            NVL (
                                TO_CHAR (
                                      DataSetSum (sName).Record (2).Field (
                                          vField)
                                    / DataSetSum (sName).Record (2).Field (
                                          vField),
                                    vFormat),
                                bl);
                    ELSIF ArrSummary (i).TYPE = 'sum_nm'
                    THEN
                        vVar :=
                            NVL (
                                SUM_TO_TEXT (
                                    v_sum   =>
                                        DataSetSum (sName).Record (2).Field (
                                            vField)),
                                bl);
                    END IF;

                    vPosVar :=
                        DBMS_LOB.INSTR (
                            pReport,
                            UTL_RAW.cast_to_raw (
                                vParamTag || vField || vParamTag),
                            1,
                            1);

                    --if vPosVar > 0 then
                    --+Slaviq 6032008 добавил цикл
                    WHILE     (vPosVar > 0)
                          AND (   (vVar <> vParamTag || vField || vParamTag)
                               OR (vVar IS NULL))
                    LOOP
                        ---Slaviq
                        -- вырезка пред и пост
                        CutReport2Part (
                            pReport,
                            vPosVar,
                              vPosVar
                            + LENGTH (vParamTag || vField || vParamTag)
                            - 1,
                            vRepPre,
                            vRepPost);
                        PasteReport2Part (vRepPre,
                                          UTL_RAW.cast_to_raw (TRIM (vVar)),
                                          vRepPre);
                        PasteReport2Part (vRepPre, vRepPost, pReport);
                        vPosVar :=
                            DBMS_LOB.INSTR (
                                pReport,
                                UTL_RAW.cast_to_raw (
                                    vParamTag || vField || vParamTag),
                                1,
                                1);
                    --end if;
                    END LOOP;
                END IF;
            END LOOP;
        END IF;
    -- выталкивание
    ---pReport := vReport;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.FillSummary. DataSet-'
                || sName
                || ' RecordCount='
                || RecordCount (sName, NULL, NULL)
                || ' field-'
                || vField
                || ' value=<'
                || vVar
                || '>. '
                || SQLERRM);
    END;

    -- +Kalev 21.02.2008
    -- Построение DataSet
    PROCEDURE BuildDataSet (pReport        IN OUT BLOB,
                            pName          IN     VARCHAR2,
                            pFilterField   IN     VARCHAR2 := NULL,
                            pFilterValue   IN     VARCHAR2 := NULL,
                            pFlSummary            BOOLEAN := FALSE)
    IS
        vCurPos     INTEGER;
        vPosStart   INTEGER;
        vPosStop    INTEGER;
        vPart1      BLOB;
        vPart2      BLOB;
        vPartDS     BLOB;
    BEGIN
        -- с позиции
        --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'start built data set ' || pName || ' ' || vCurPos);
        vCurPos := 1;
        -- поиск по отчету с символа
        vPosStart := vCurPos;

        WHILE (vPosStart > 0)
        LOOP
            -- получение начала-конца@ и чистого DataSet
            vPosStart := vCurPos;
            --dbms_output.put_line('CutReportDataSet' || vCurPos);
            CutReportDataSet (pReport,
                              pName,
                              vPosStart,
                              vPosStop,
                              vPartDS);

            --dbms_output.put_line('After cut: vCurPos=' || vCurPos );
            --dbms_output.put_line('sName=' || pName || ' vPosStart-' || vPosStart || ' vPosStop-' || vPosStop);
            -- +Kalev 07.03.09 проверка
            IF (vPosStart > 0) AND (vPosStop = 0)
            THEN
                RAISE exNoEndTag;
            END IF;

            -- -Kalev 07.03.09
            -- работааем с DataSet
            IF (vPosStart >= 0) AND (vPosStop > 0)
            THEN
                -- вырезка пред и пост
                --dbms_output.put_line('sName=' || pName || ' vPosStart-' || vPosStart || ' vPosStop-' || vPosStop || ' pFilterField-' || pFilterField || ' pFilterValue-' || pFilterValue || ' count-' || RecordCount(pName, pFilterField, pFilterValue));
                ---CutReport2Part(pReport, vPosStart - 1, vPosStop, vPart1, vPart2);
                CutReport2Part (pReport,
                                vPosStart,
                                vPosStop,
                                vPart1,
                                vPart2);

                ---- вырезка
                /*if pName = 'YearDS' and vTempBlob is null then
                  vTempBlob := vPart2;
                  update rpt_templates t set t.rt_text = vTempBlob where t.rt_id = 1003;
                end if;*/
                ----
                -- добавление DataSet
                IF NOT pFlSummary
                THEN
                    IF RecordCount (pName, pFilterField, pFilterValue) > 0
                    THEN
                        --dbms_output.put_line('+++Fill');
                        FillDataSet (vPartDS,
                                     pName,
                                     pFilterField,
                                     pFilterValue);
                    --dbms_output.put_line('---Fill');
                    ELSE
                        vPartDS := NULL;
                    END IF;
                ELSE
                    --dbms_output.put_line('Start FillSummary ' || pName);
                    FillSummary (vPartDS, pName);
                --dbms_output.put_line('Stop FillSummary ' || pName);
                END IF;

                -- склеивание с пред
                --dbms_output.put_line('склеивание с пред');
                PasteReport2Part (vPart1, vPartDS, vPart1);
                -- склеивание с пост
                --dbms_output.put_line('склеивание с пост');
                PasteReport2Part (vPart1, vPart2, pReport);
                -- суммировка
                --dbms_output.put_line('Start BuildDataSet Summary ' || pName);
                BuildDataSet (pReport,
                              pName || '_sum',
                              NULL,
                              NULL,
                              TRUE);
            --dbms_output.put_line('Stop BuildDataSet Summary ' || pName);
            END IF;
        END LOOP;
    --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'stop built data set ' || pName || ' ' || vCurPos);
    EXCEPTION
        WHEN exNoEndTag
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.BuildDataSet. Для DataSet '
                || pName
                || ' не знайдено закриваючий тег (можливо невірно сформовано шаблон)!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.BuildDataSet. ' || SQLERRM);
    END;

    -- +Kalev 11.01.2010
    -- Построение DataSetEmpty
    PROCEDURE BuildDataSetEmpty (pReport IN OUT BLOB, pName IN VARCHAR2)
    IS
        vCurPos     INTEGER;
        vPosStart   INTEGER;
        vPosStop    INTEGER;
        vPart1      BLOB;
        vPart2      BLOB;
        vPartDS     BLOB;
    BEGIN
        -- с позиции
        vCurPos := 1;
        -- поиск по отчету с символа
        vPosStart := vCurPos;

        WHILE (vPosStart > 0)
        LOOP
            -- получение начала-конц@
            vPosStart := vCurPos;
            CutReportDataSet (pReport,
                              pName,
                              vPosStart,
                              vPosStop,
                              vPartDS);

            IF (vPosStart > 0) AND (vPosStop = 0)
            THEN
                RAISE exNoEndTag;
            END IF;

            -- -Kalev 07.03.09
            -- работааем с DataSet
            IF (vPosStart >= 0) AND (vPosStop > 0)
            THEN
                -- вырезка пред и пост
                CutReport2Part (pReport,
                                vPosStart,
                                vPosStop,
                                vPart1,
                                vPart2);
                -- склеивание пред с пост
                PasteReport2Part (vPart1, vPart2, pReport);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN exNoEndTag
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.BuildDataSetEmpty. Для DataSet '
                || pName
                || ' не знайдено закриваючий тег (можливо невірно сформовано шаблон)!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.BuildDataSetEmpty. ' || SQLERRM);
    END;

    -- +Kalev 18.02.2008
    -- Вставка DataSet
    PROCEDURE DataSetIntoReport (pReport OUT BLOB)
    IS
        sName   VARCHAR2 (20);
    BEGIN
        vTempBlob := NULL;
        -- пробежка по DataSet
        sName := DataSet.FIRST;

        FOR ds IN 1 .. DataSet.COUNT
        LOOP
            --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'BuildDataSet ' || sName);
            IF (sName IS NOT NULL) AND (NOT ExistsRelation (NULL, sName, 3))
            THEN
                BuildDataSet (vTemplate, sName);
            END IF;

            sName := DataSet.NEXT (sName);
        END LOOP;

        -- пробежка по DataSetEmpty
        sName := DataSetEmpty.FIRST;

        FOR ds IN 1 .. DataSetEmpty.COUNT
        LOOP
            IF (sName IS NOT NULL) AND (RecordCount (sName, NULL, NULL) = 0)
            THEN
                --dbms_output.put_line(to_char(CURRENT_TIMESTAMP, 'DD-MM-YYYY HH24:MI:SSxFF')||': '||'BuildDataSetEmpty ' || sName);
                BuildDataSetEmpty (vTemplate, sName);
            END IF;

            sName := DataSetEmpty.NEXT (sName);
        END LOOP;

        -- выдача
        --pReport := vTemp;
        pReport := vTemplate;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'REPORTFL_ENGINE.DataSetIntoReport. ' || SQLERRM);
    END;

    FUNCTION PublishReportBlob
        RETURN BLOB
    IS
        vRepDataSet   BLOB;
    BEGIN
        -- подмена DataSet
        DataSetIntoReport (vRepDataSet);
        -- парс параметров
        ParseParams;
        -- замена констант
        ParIntoReport;
        RETURN vReport;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.PublishReportBlob. Помилка публікації звіту: '
                || SQLERRM);
    END;

    PROCEDURE PublishReport
    IS
        vRepDataSet   BLOB;
    BEGIN
        DataSetIntoReport (vRepDataSet);
        ParseParams;
        ParIntoReport;
        -- Цей код приушує браузер показати спеціальне вікно, в якому файл можна відкрити відповідною програмою перегляду.
        HTP.p (
               'Content-Type: application/rtf; name="'
            || vName
            || '.'
            || vType
            || '"');
        HTP.p (
               'Content-Disposition: attachment; filename="'
            || vName
            || '.'
            || vType
            || '"');
        HTP.p ('Content-Length: ' || DBMS_LOB.getlength (vReport));
        HTP.p ('');
        WPG_DOCLOAD.download_file (vReport);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'REPORTFL_ENGINE.PublishReport. Помилка публікації звіту: '
                || SQLERRM);
    END;

    PROCEDURE Print1
    IS
    BEGIN
        InitReport ('IKIS_MIL', 'PL1');
        AddParam ('Number', '33/111');
        AddParam ('OrgTo', 'Руководителям предприятия');
        AddParam ('NameTo', 'Уважаемые господа!');
        AddParam (
            'Ouverture',
            'Представляем Вам наш завод - один из основных поставщиков деталей трубопроводов в нашей стране, известный и за рубежом. Началу экспортных поставок предшествовало получение нашим заводом сертификата соответствия международной системе качества ИСО-9002 номер 041008716, выданного международной аудиторской фирмой  RWTUV. ОАО "Тоскинский завод монтажных заготовок и металлоконструкций"  предлагает Вам приобретать следующую сертифицированную продукцию:|EOL:1. Отводы цельнотянутые из стали 20, 09Г2С, 12Х18Н10Т, St37, WPB по ГОСТ 17375-83, ТУ 39-0147016-64-96, ТУ 1468-120-1411419-93, ТУ 1468-126-01411411-95, DIN 2605, ANSI B.16.9 диаметром 21,3-630мм.|EOL:2. Отводы, тройники сварные диаметром 720-1020мм по ТУ 102-488-95.|EOL:3. Фланцы плоские и воротниковые из стали 20, Ст3, 12Х18Н10Т, St37, по ГОСТ 12820-83, ГОСТ 12821-83, PN-87/H-7431, DIN 2576, DIN 2633 Ду 15-600мм.|EOL:4. Переходы из стали 20, 09Г2С, St37, по ГОСТ 17378-83, DIN 2616, Ду 45-325мм.|EOL:5. Заглушки из стали 20, 09Г2С, St37, по ГОСТ 17379-83, DIN 28011, Ду 45-20мм.|EOL:6. Тройники штампованные, сварные  из стали 20, 09Г2С , St37, по ГОСТ 17376-83, ТУ 102-488-95, ТУ 51-29-81 диаметром 325-530мм.');
        AddParam (
            'Conclusion',
            'Надежность работы нашего предприятия подтверждается постоянным  сотрудничеством с такими  известными  отечественными компаниями нефтегазового комплекса как ОАО "Нижневартовскснабнефть" , ОАО "Сургутнефтегаз", ОАО "Тюменская нефтяная компания" и других, а также с зарубежными компаниями, как из ближнего зарубежья (стран СНГ, Балтии), так и Европы - Польши, Испании, Германии. Мы всегда готовы рассмотреть любые заказы, в том числе на новые типоразмеры  продукции.');
        AddParam ('Position', 'Генеральный директор');
        AddParam ('Who', 'Челноков С.В.');
        AddParam (
            'Doer',
            'Клейносов А.А. тел. /04491/ 3-26-47 , факс 3-32-34 , 3-21-47');
        ParseParams;
        ParIntoReport;
        HTP.p ('Content-Type: application/rtf; name="test.' || vType || '"'); --'||vName||'.'||vType||'"');
        HTP.p (
               'Content-Disposition: attachment; filename="test.'
            || vType
            || '"');
        HTP.p ('Content-Length: ' || DBMS_LOB.getlength (vReport));
        HTP.p ('');
        WPG_DOCLOAD.download_file (vReport);
    END;

    --Проставить тег для параметров, по умолчанию '#'
    PROCEDURE SetParamTag (pParamTag VARCHAR2)
    IS
    BEGIN
        vParamTag := pParamTag;
    END;
END REPORTFL_ENGINE;
/