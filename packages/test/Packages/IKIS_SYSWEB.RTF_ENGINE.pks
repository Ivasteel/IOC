/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.RTF_ENGINE
IS
    -- Author  : CASUFI
    -- Created : 14.06.2010 11:40:36
    -- Purpose :

    -- Public type declarations
    -- type <TypeName> is <Datatype>;

    -- Public constant declarations
    -- <ConstantName> constant <Datatype> := <Value>;

    -- Public variable declarations
    -- <VariableName> <Datatype>;

    -- Public function and procedure declarations
    -- function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
    PROCEDURE InitializeRTF (p_paperw      NUMERIC:= 21, -- ширина листа в сантиметрах
                             p_paperh      NUMERIC:= 29.7, -- высота листа в сантиметрах
                             p_landscape   INTEGER:= 0, -- Ориентация 1 - Ландшафт 0 - портрет
                             -- размер бумаги однозначно определяется параметрами p_paperw и p_paperh,
                             -- параметр p_landscape определяет ориентацию при выводе на печать
                             -- таким образом для печати таблицы на а4 ландшафт нужно указать p_paperw 21, p_paperh 19.7, p_landscape 1
                             p_margl       NUMERIC:= 1.5,      -- отступ слева
                             p_margr       NUMERIC:= 1.5,     -- отступ справа
                             p_margt       NUMERIC:= 1.5,     -- отступ сверху
                             p_margb       NUMERIC:= 1.5       -- отступ снизу
                                                        );

    PROCEDURE AddSection;

    PROCEDURE AddText;

    FUNCTION GetRTF
        RETURN BLOB;
END RTF_ENGINE;
/


/* Formatted on 8/12/2025 6:11:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.RTF_ENGINE
IS
    -- Private type declarations
    -- type <TypeName> is <Datatype>;

    -- Private constant declarations
    -- <ConstantName> constant <Datatype> := <Value>;

    -- Private variable declarations
    gp_report   CLOB;

    -- Function and procedure implementations
    -- function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    --   <LocalVariable> <Datatype>;
    -- begin
    --   <Statement>;
    --   return(<Result>);
    -- end;

    -- Initialization
    PROCEDURE InitializeRTF (p_paperw      NUMERIC:= 21, -- ширина листа в сантиметрах
                             p_paperh      NUMERIC:= 29.7, -- высота листа в сантиметрах
                             p_landscape   INTEGER:= 0, -- Ориентация 1 - Ландшафт 0 - портрет
                             -- размер бумаги однозначно определяется параметрами p_paperw и p_paperh,
                             -- параметр p_landscape определяет ориентацию при выводе на печать
                             -- таким образом для печати таблицы на а4 ландшафт нужно указать p_paperw 21, p_paperh 19.7, p_landscape 1
                             p_margl       NUMERIC:= 1.5,      -- отступ слева
                             p_margr       NUMERIC:= 1.5,     -- отступ справа
                             p_margt       NUMERIC:= 1.5,     -- отступ сверху
                             p_margb       NUMERIC:= 1.5       -- отступ снизу
                                                        )
    IS
        l_paperw      INTEGER;
        l_paperh      INTEGER;
        l_landscape   VARCHAR2 (12);
        l_margl       INTEGER;
        l_margr       INTEGER;
        l_margt       INTEGER;
        l_margb       INTEGER;
    BEGIN
        IF p_landscape IS NOT NULL AND p_landscape = 1
        THEN
            l_landscape := '\landscape';
        ELSE
            l_landscape := '';
        END IF;

        l_paperw := NVL (p_paperw, 21) * 566;
        l_paperh := NVL (p_paperh, 29.7) * 566;
        l_margl := NVL (p_margl, 1.5) * 566;
        l_margr := NVL (p_margr, 1.5) * 566;
        l_margt := NVL (p_margt, 1.5) * 566;
        l_margb := NVL (p_margb, 1.5) * 566;

        IF gp_report IS NULL
        THEN
            gp_report :=
                   ''
                || '{\rtf1 \ansi \ansicpg1251'
                || ' \paperw'
                || l_paperw
                || ' \paperh'
                || l_paperh
                || ' '
                || l_landscape
                || ' \margl'
                || l_margl
                || ' \margr'
                || l_margr
                || ' \margt'
                || l_margt
                || ' \margb'
                || l_margb
                || ' %%CONTENT%%'
                || ' }';
        END IF;
    END;

    PROCEDURE AddSection
    IS
    BEGIN
        IF gp_report IS NOT NULL
        THEN
            gp_report := REPLACE (gp_report, '%%CONTENTEXT%%', '');
            gp_report :=
                REPLACE (gp_report,
                         '%%CONTENT%%',
                         '{\pard %%CONTENTEXT%%\par}%%CONTENT%%');
        ELSE
            raise_application_error (
                -20000,
                'Помилка у функції RTF_ENGINE.AddSection, спочатку потрібно ініціалізувати RTF');
        END IF;
    END;

    PROCEDURE AddText
    IS
    BEGIN
        IF gp_report IS NOT NULL
        THEN
            gp_report :=
                REPLACE (gp_report, '%%CONTENTEXT%%', 'Какой то текст');
        ELSE
            raise_application_error (
                -20000,
                'Помилка у функції RTF_ENGINE.AddText, спочатку потрібно ініціалізувати RTF');
        END IF;
    END;

    PROCEDURE DefineRow
    IS
    BEGIN
        IF gp_report IS NOT NULL
        THEN
            --gp_report := REPLACE(gp_report, '%%CONTENTEXT%%', 'Какой то текст');
            gp_report := gp_report;
        ELSE
            raise_application_error (
                -20000,
                'Помилка у функції RTF_ENGINE.AddRow, спочатку потрібно ініціалізувати RTF');
        END IF;
    END;

    FUNCTION GetRTF
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;
        l_rtf_blob       BLOB;
    BEGIN
        IF gp_report IS NOT NULL
        THEN
            l_clob_offset := 1;
            l_blob_offset := 1;
            l_lang_context := DBMS_LOB.default_lang_ctx;
            DBMS_LOB.createtemporary (l_rtf_blob, TRUE);
            DBMS_LOB.converttoblob (l_rtf_blob,
                                    gp_report,
                                    DBMS_LOB.lobmaxsize,
                                    l_blob_offset,
                                    l_clob_offset,
                                    DBMS_LOB.default_csid,
                                    l_lang_context,
                                    l_convert_warn);
        ELSE
            raise_application_error (
                -20000,
                'Помилка у функції RTF_ENGINE.GetRTF, спочатку потрібно ініціалізувати RTF');
        END IF;

        RETURN l_rtf_blob;
    END;
END RTF_ENGINE;
/