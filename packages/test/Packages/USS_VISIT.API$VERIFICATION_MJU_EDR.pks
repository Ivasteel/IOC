/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VERIFICATION_MJU_EDR
IS
    c_Test   CONSTANT CLOB
        := '{"id": 1, "state":1, "state_text": "ХЗ", "names":{"name": "повна назва", "short":"коротка назва"}, "name": "ще назва", "code":"12345678",
         "address":{"zip":"04215", "country":"Ukraine","address":"des tam", "parts":{"atu":"Kyiv", "street":"Hreschatyyk", "house_type":"буд."}},
         "founders":[{"last_name":"Petrenko", "role": 1, address:{"zip":"04213", "country":"Ukraine"}},
                     {"last_name":"Vasylenko", "role": 3, address:{"zip":"04215", "country":"Ukraine"}}],
         "heads":[{"name":"RogaCopyta", "role": 2, address:{"zip":"04213", "country":"Ukraine"}, "role_text":"golova", "last_name":"Petrenko"},
                  {"name":"RogaCopyta2", "role": 3, address:{"zip":"04213", "country":"Ukraine"}, "role_text":"hogi", "last_name":"Vasylysa", "first_middle_name":"Vasyl-Dmitro Vasylovich"}]}' ;


    PROCEDURE Handle_EDR_Doc_700_Answer (p_Vf_Id      IN NUMBER,
                                         p_Response   IN CLOB);

    FUNCTION Get_Word_Number (p_Str        IN VARCHAR2,
                              p_Row        IN NUMBER,
                              p_Splitter   IN VARCHAR2 DEFAULT '#')
        RETURN VARCHAR2;
END API$VERIFICATION_MJU_EDR;
/


/* Formatted on 8/12/2025 5:59:52 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VERIFICATION_MJU_EDR
IS
    ---
    --- Визначення атрибута з полем
    ---
    FUNCTION Get_Nda_By_Field_Name (
        p_Level          IN NUMBER,
        p_Field_Name_1   IN VARCHAR2,
        p_Field_Name_2   IN VARCHAR2 DEFAULT NULL)
        RETURN NUMBER
    IS
    BEGIN
        IF p_Level = 1 AND LOWER (TRIM (p_Field_Name_1)) = 'code'
        THEN
            RETURN 955;
        ELSIF p_Level = 1 AND LOWER (TRIM (p_Field_Name_1)) = 'olf_name'
        THEN
            RETURN 958;
        ELSIF p_Level = 2 AND LOWER (TRIM (p_Field_Name_1)) = 'name'
        THEN
            RETURN 956;
        ELSIF p_Level = 2 AND LOWER (TRIM (p_Field_Name_1)) = 'short'
        THEN
            RETURN 957;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'role_text'
              AND LOWER (TRIM (p_Field_Name_2)) = 'heads'
        THEN
            RETURN 1094;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'last_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'heads'
        THEN
            RETURN 1095;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'first_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'heads'
        THEN
            RETURN 1096;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'middle_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'heads'
        THEN
            RETURN 1097;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'last_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'founders'
        THEN
            RETURN 963;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'first_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'founders'
        THEN
            RETURN 964;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'middle_name'
              AND LOWER (TRIM (p_Field_Name_2)) = 'founders'
        THEN
            RETURN 965;
        ELSIF     p_Level = 2
              AND LOWER (TRIM (p_Field_Name_1)) = 'zip'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 972;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'atu'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 974;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'street'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 2159;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'house'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 976;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'building'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 977;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'num'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 978;
        ELSIF     p_Level = 3
              AND LOWER (TRIM (p_Field_Name_1)) = 'num_type'
              AND LOWER (TRIM (p_Field_Name_2)) = 'address'
        THEN
            RETURN 1485;
        END IF;

        RAISE_APPLICATION_ERROR (
            -20000,
               'NDI Document Attribeute for Fields ['
            || p_Field_Name_1
            || ', '
            || p_Field_Name_2
            || '] not found');
    END;

    ---
    --- Отримання слова з рядка за номером
    ---
    FUNCTION Get_Word_Number (p_Str        IN VARCHAR2,
                              p_Row        IN NUMBER,
                              p_Splitter   IN VARCHAR2 DEFAULT '#')
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (250);
    BEGIN
        SELECT string_parts
          INTO l_Res
          FROM (SELECT ROWNUM rn, string_parts
                  FROM (    SELECT REGEXP_SUBSTR (p_Str,
                                                  '[^' || p_Splitter || ']+',
                                                  1,
                                                  LEVEL)    AS string_parts
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (p_Str,
                                                  '[^' || p_Splitter || ']+',
                                                  1,
                                                  LEVEL)
                                       IS NOT NULL))
         WHERE rn = p_Row;

        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;


    ---
    --- Встановлення атрибуту документа
    ---
    PROCEDURE Set_Doc_Attr_value (p_Apd_Id         IN NUMBER,
                                  p_Level          IN NUMBER,
                                  p_Field_Name_1   IN VARCHAR2,
                                  p_Field_Name_2   IN VARCHAR2 DEFAULT NULL,
                                  p_Value          IN VARCHAR2)
    IS
        l_Nda_Id   NUMBER;
        l_Ap_id    NUMBER;
    BEGIN
        l_Nda_ID :=
            Get_Nda_By_Field_Name (p_Level, p_Field_Name_1, p_Field_Name_2);

        SELECT apd.apd_ap
          INTO l_Ap_id
          FROM ap_document apd
         WHERE apd.apd_id = p_Apd_Id;

        API$APPEAL.Save_Attr (p_Apd_Id            => p_Apd_Id,
                              p_Ap_Id             => l_Ap_id,
                              p_Apda_Nda          => l_Nda_ID,
                              p_Apda_Val_String   => p_Value);
    END;

    ---
    --- Обробка відповіді від ЄДР та заповнення полів документу
    ---
    PROCEDURE Handle_EDR_Doc_700_Answer (p_Vf_Id      IN NUMBER,
                                         p_Response   IN CLOB)
    IS
        l_Apd_Id   NUMBER;
    BEGIN
        l_Apd_Id := API$VERIFICATION.Get_Vf_Obj (p_Vf_Id);

        FOR cMain
            IN (SELECT *
                  FROM JSON_TABLE (
                           p_Response,
                           '$'
                           COLUMNS (
                               id NUMBER PATH '$.id',
                               state NUMBER PATH '$.state',
                               state_text VARCHAR2 (250) PATH '$.state_text',
                               olf_name VARCHAR2 (250) PATH '$.olf_name',
                               NESTED PATH '$.names[*]'
                                   COLUMNS (
                                       names_name
                                           VARCHAR (4000)
                                           PATH '$.name',
                                       names_short
                                           VARCHAR (4000)
                                           PATH '$.short'),
                               address_zip
                                   VARCHAR2 (250)
                                   PATH '$.address.zip',
                               address_parts_atu
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.atu',
                               address_parts_street
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.street',
                               address_parts_house
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.house',
                               address_parts_building
                                   VARCHAR2 (250)
                                   PATH '$.address.parts. building',
                               address_parts_num
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.num',
                               address_parts_num_type
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.num_type',
                               code VARCHAR2 (250) PATH '$.code',
                               founders
                                   VARCHAR2 (4000)
                                   FORMAT JSON
                                   PATH '$.founders',
                               heads
                                   VARCHAR2 (4000)
                                   FORMAT JSON
                                   PATH '$.heads')))
        LOOP
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 1,
                                p_Field_Name_1   => 'code',
                                p_Field_Name_2   => NULL,
                                p_Value          => cMain.Code);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 1,
                                p_Field_Name_1   => 'olf_name',
                                p_Field_Name_2   => NULL,
                                p_Value          => cMain.olf_name);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 2,
                                p_Field_Name_1   => 'name',
                                p_Field_Name_2   => NULL,
                                p_Value          => cMain.names_name);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 2,
                                p_Field_Name_1   => 'short',
                                p_Field_Name_2   => NULL,
                                p_Value          => cMain.names_short);

            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 2,
                                p_Field_Name_1   => 'zip',
                                p_Field_Name_2   => 'address',
                                p_Value          => cMain.address_zip);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 3,
                                p_Field_Name_1   => 'atu',
                                p_Field_Name_2   => 'address',
                                p_Value          => cMain.address_parts_atu);
            Set_Doc_Attr_value (
                p_Apd_Id         => l_Apd_id,
                p_Level          => 3,
                p_Field_Name_1   => 'street',
                p_Field_Name_2   => 'address',
                p_Value          => cMain.address_parts_street);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 3,
                                p_Field_Name_1   => 'house',
                                p_Field_Name_2   => 'address',
                                p_Value          => cMain.address_parts_house);
            Set_Doc_Attr_value (
                p_Apd_Id         => l_Apd_id,
                p_Level          => 3,
                p_Field_Name_1   => 'building',
                p_Field_Name_2   => 'address',
                p_Value          => cMain.address_parts_building);
            Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                p_Level          => 3,
                                p_Field_Name_1   => 'num',
                                p_Field_Name_2   => 'address',
                                p_Value          => cMain.address_parts_num);
            Set_Doc_Attr_value (
                p_Apd_Id         => l_Apd_id,
                p_Level          => 3,
                p_Field_Name_1   => 'num_type',
                p_Field_Name_2   => 'address',
                p_Value          => cMain.address_parts_num_type);

            FOR cSecond
                IN (SELECT role,
                           role_text,
                           last_name,
                           API$VERIFICATION_MJU_EDR.Get_Word_Number (
                               REGEXP_REPLACE (first_middle_name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               1)    first_name,
                           API$VERIFICATION_MJU_EDR.Get_Word_Number (
                               REGEXP_REPLACE (first_middle_name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               2)    middle_name
                      FROM JSON_TABLE (
                               cMain.Heads,
                               '$[*]'
                               COLUMNS (
                                   role NUMBER PATH '$.role',
                                   role_text
                                       VARCHAR2 (250)
                                       PATH '$.role_text',
                                   last_name
                                       VARCHAR2 (250)
                                       PATH '$.last_name',
                                   first_middle_name
                                       VARCHAR2 (250)
                                       PATH '$.first_middle_name'))
                     WHERE role = 3)
            LOOP
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'role_text',
                                    p_Field_Name_2   => 'heads',
                                    p_Value          => cSecond.role_text);
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'last_name',
                                    p_Field_Name_2   => 'heads',
                                    p_Value          => cSecond.last_name);
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'first_name',
                                    p_Field_Name_2   => 'heads',
                                    p_Value          => cSecond.first_name);
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'middle_name',
                                    p_Field_Name_2   => 'heads',
                                    p_Value          => cSecond.middle_name);
            END LOOP;

            FOR cSecond
                IN (SELECT role,
                           last_name,
                           API$VERIFICATION_MJU_EDR.Get_Word_Number (
                               REGEXP_REPLACE (first_middle_name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               1)    first_name,
                           API$VERIFICATION_MJU_EDR.Get_Word_Number (
                               REGEXP_REPLACE (first_middle_name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               2)    middle_name
                      FROM JSON_TABLE (
                               cMain.Heads,
                               '$[*]'
                               COLUMNS (
                                   role NUMBER PATH '$.role',
                                   last_name
                                       VARCHAR2 (250)
                                       PATH '$.last_name',
                                   first_middle_name
                                       VARCHAR2 (250)
                                       PATH '$.first_middle_name'))
                     WHERE role = 1)
            LOOP
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'last_name',
                                    p_Field_Name_2   => 'founders',
                                    p_Value          => cSecond.last_name);
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'first_name',
                                    p_Field_Name_2   => 'founders',
                                    p_Value          => cSecond.first_name);
                Set_Doc_Attr_value (p_Apd_Id         => l_Apd_id,
                                    p_Level          => 2,
                                    p_Field_Name_1   => 'middle_name',
                                    p_Field_Name_2   => 'founders',
                                    p_Value          => cSecond.middle_name);
            END LOOP;
        END LOOP;
    END;
END API$VERIFICATION_MJU_EDR;
/