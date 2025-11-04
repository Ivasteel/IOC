/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.CheckEDRPOU (p_numident   VARCHAR2,
                                                    p_type       VARCHAR2)
    RETURN VARCHAR2
IS
    Result      VARCHAR2 (255);
    l_buff      VARCHAR2 (32760);

    TYPE t_regexps IS TABLE OF VARCHAR2 (255)
        INDEX BY BINARY_INTEGER;

    regexps     t_regexps;
    resultstr   VARCHAR2 (255);
BEGIN
    Result := NULL;
    --  l_buff := upper(p_numident);
    l_buff := p_numident;
    resultstr :=
        REGEXP_SUBSTR (l_buff,
                       '^0+$',
                       1,
                       1,
                       'c');

    IF l_buff IS NULL
    THEN
        Result := 'Поле ЕДРПОУ/ДРФО має містити значення';
    ELSIF resultstr IS NOT NULL
    THEN
        Result := 'Поле не може містити тілки нулі';
    ELSE
        resultstr := NULL;

        IF p_type IS NULL
        THEN                                                          -- пусто
            Result := 'Ви не можете перевіряти пусте значення типу';
        ELSIF p_type IN ('U')
        THEN                                                 -- юридична особа
            regexps (1) := '^\d{8,9}$';

            IF regexps.COUNT > 0
            THEN
                FOR i IN regexps.FIRST .. regexps.LAST
                LOOP
                    resultstr :=
                        REGEXP_SUBSTR (l_buff,
                                       regexps (i),
                                       1,
                                       1,
                                       'c');

                    IF resultstr IS NOT NULL
                    THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF resultstr IS NULL
            THEN
                Result := 'Поле має містити 8 або 9 цифр';
            END IF;
        ELSE                                  -- фізична особа  или доброволец
            regexps (1) := '^\d{10}$';
            regexps (2) :=
                '^[ҐІЇЄАВ-ЕЖ-ЩЬЮЯ][ҐІЇЄА-ЕЖ-ЙЛ-ЩЬЮЯ][ҐІЇЄА-ЕЖ-ЩЬЮЯ] \d{6}$';
            regexps (3) := '^БК[ҐІЇЄА-ЕЖ-ЩЬЮЯ]{2}\d{6}$';

            --      regexps(4) := '^[А-Я]{2}\d{8}$';
            IF regexps.COUNT > 0
            THEN
                FOR i IN regexps.FIRST .. regexps.LAST
                LOOP
                    resultstr :=
                        REGEXP_SUBSTR (l_buff,
                                       regexps (i),
                                       1,
                                       1,
                                       'c');

                    IF resultstr IS NOT NULL
                    THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            IF resultstr IS NULL
            THEN
                Result :=
                       'Поле має містити тільки цифри "0123456789",<br>'
                    || --                  'або символи за шаблонами: '||'БКАА123456; АА12345678'||'<br>'||
                       'або символи за шаблонами: '
                    || 'БКАА123456'
                    || '<br>'
                    || 'АБВ 012345 (не може починатись з БК);';                       -- FZZZZZZZZZ';
            END IF;
        END IF;
    END IF;

    RETURN (Result);
END CheckEDRPOU;
/
