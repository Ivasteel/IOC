/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$DEMO
IS
    -- Author  : KELATEV
    -- Created : 21.02.2025 16:06:40
    -- Purpose :

    c_Rdj_St_New       CONSTANT VARCHAR2 (10) := 'N';
    c_Rdj_St_Done      CONSTANT VARCHAR2 (10) := 'D';
    c_Rdj_St_Fail      CONSTANT VARCHAR2 (10) := 'F';
    c_Rdj_St_History   CONSTANT VARCHAR2 (10) := 'H';

    PROCEDURE Save_Request (p_Rdj_Nrd   IN     NUMBER,
                            p_Rdj_Rn    IN     NUMBER,
                            p_Rdj_St    IN     VARCHAR2 DEFAULT NULL,
                            p_Rdj_Id       OUT NUMBER);

    PROCEDURE Delete_Request (p_Rdj_Id IN NUMBER);

    FUNCTION Generate_Req_Uid
        RETURN VARCHAR2;

    PROCEDURE Handle_Request (p_Ur_Id      IN     NUMBER,
                              p_Response   IN     CLOB,
                              p_Error      IN OUT VARCHAR2);

    PROCEDURE Rebuild_Result (p_Ur_Id IN NUMBER);
END Api$demo;
/


GRANT EXECUTE ON IKIS_RBM.API$DEMO TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$DEMO
IS
    --------------------------------------------------------------------------
    --Створення демо запиту
    --------------------------------------------------------------------------
    PROCEDURE Save_Request (p_Rdj_Nrd   IN     NUMBER,
                            p_Rdj_Rn    IN     NUMBER,
                            p_Rdj_St    IN     VARCHAR2 DEFAULT NULL,
                            p_Rdj_Id       OUT NUMBER)
    IS
    BEGIN
        INSERT INTO Request_Demo_Journal (Rdj_Id,
                                          Rdj_Nrd,
                                          Rdj_Rn,
                                          Rdj_Result,
                                          Rdj_St)
             VALUES (0,
                     p_Rdj_Nrd,
                     p_Rdj_Rn,
                     NULL,
                     NVL (p_Rdj_St, c_Rdj_St_New))
          RETURNING Rdj_Id
               INTO p_Rdj_Id;
    END;

    --------------------------------------------------------------------------
    --Збереження результату до демо запиту
    --------------------------------------------------------------------------
    PROCEDURE Save_Request_Result (p_Rdj_Rn       IN NUMBER,
                                   p_Rdj_Result   IN CLOB,
                                   p_Rdj_St       IN VARCHAR2)
    IS
    BEGIN
        UPDATE Request_Demo_Journal
           SET Rdj_Result = p_Rdj_Result, Rdj_St = p_Rdj_St
         WHERE Rdj_Rn = p_Rdj_Rn;
    END;

    --------------------------------------------------------------------------
    --Видалення демо запиту
    --------------------------------------------------------------------------
    PROCEDURE Delete_Request (p_Rdj_Id IN NUMBER)
    IS
    BEGIN
        UPDATE Request_Demo_Journal
           SET Rdj_St = c_Rdj_St_History
         WHERE Rdj_Id = p_Rdj_Id;
    END;

    --------------------------------------------------------------------------
    --Генерація UUID4
    --------------------------------------------------------------------------
    FUNCTION Generate_Req_Uid
        RETURN VARCHAR2
    IS
        l_Uuid     RAW (16);
        l_Result   VARCHAR2 (40);
    BEGIN
        l_Uuid := Sys.DBMS_CRYPTO.Randombytes (16);
        l_Result :=
            (UTL_RAW.Overlay (
                 UTL_RAW.Bit_Or (
                     UTL_RAW.Bit_And (UTL_RAW.SUBSTR (l_Uuid, 7, 1), '0F'),
                     '40'),
                 l_Uuid,
                 7));
        l_Result :=
            LOWER (
                   SUBSTR (l_Result, 1, 8)
                || '-'
                || SUBSTR (l_Result, 9, 4)
                || '-'
                || SUBSTR (l_Result, 13, 4)
                || '-'
                || SUBSTR (l_Result, 17, 4)
                || '-'
                || SUBSTR (l_Result, 21));

        RETURN l_Result;
    END;

    PROCEDURE Response2text_144 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data              Api$request_Dpsu.r_Last_Crossing;

        l_Gender            VARCHAR2 (250);
        l_Doc_Name          VARCHAR2 (250);
        l_Country_Name      VARCHAR2 (1000);
        l_Border_Crossing   VARCHAR2 (250);
        l_Codeusel_Name     VARCHAR2 (250);
    BEGIN
        l_Data :=
            Api$request_Dpsu.Parse_Find_Last_Crossing_Resp (
                p_Response   => p_Response);

        IF l_Data.Id = -1
        THEN
            p_Html := 'Особу не знайдено в БД «Аркан»';
            RETURN;
        END IF;

        SELECT MAX (Dic_Name)
          INTO l_Gender
          FROM Uss_Ndi.v_Ddn_Gender
         WHERE Dic_Code = l_Data.Sex;

        SELECT MAX (Ndt_Name)
          INTO l_Doc_Name
          FROM Uss_Ndi.v_Ndi_Document_Type t
         WHERE Ndt_Id = Uss_Ndi.Tools.Decode_Dict (
                            p_Nddc_Tp         => 'NDT_ID',
                            p_Nddc_Src        => 'DPSU',
                            p_Nddc_Dest       => 'USS',
                            p_Nddc_Code_Src   => l_Data.Docnameid);

        SELECT MAX (t.Nc_Name)
          INTO l_Country_Name
          FROM Uss_Ndi.v_Ndi_Country t
         WHERE t.Nc_Id = Uss_Ndi.Tools.Decode_Dict (
                             p_Nddc_Tp         => 'NC_ID',
                             p_Nddc_Src        => 'DPSU',
                             p_Nddc_Dest       => 'USS',
                             p_Nddc_Code_Src   => l_Data.Stateid);

        IF l_Country_Name IS NULL AND l_Data.Stateid IS NOT NULL
        THEN
            l_Country_Name := l_Data.Stateid || ' (необхідне перекодування)';
        END IF;

        SELECT MAX (t.Dic_Name)
          INTO l_Codeusel_Name
          FROM Uss_Ndi.v_Ddn_Cross_Point t
         WHERE t.Dic_Value = l_Data.Codeusel;

        IF l_Codeusel_Name IS NULL AND l_Data.Codeusel IS NOT NULL
        THEN
            l_Codeusel_Name :=
                l_Data.Codeusel || ' (необхідне перекодування)';
        END IF;

        SELECT MAX (Dic_Name)
          INTO l_Border_Crossing
          FROM Uss_Ndi.v_Ddn_Border_Crossing_Tp
         WHERE Dic_Code = l_Data.Naprid;

        p_Html :=
               'Ідентифікатор запису особи в БД «Аркан»: '
            || l_Data.Id
            || UTL_TCP.Crlf
            || --
               'Дата, час перетину кордону: '
            || TO_CHAR (l_Data.Datecross, 'dd.mm.yyyy hh24:mi:ss')
            || UTL_TCP.Crlf
            || --
               'ПІБ особи (українською): '
            || l_Data.Fioukr
            || UTL_TCP.Crlf
            || --
               'ПІБ особи (латиницею): '
            || l_Data.Fiolat
            || UTL_TCP.Crlf
            || --
               'ПІБ особи (російською): '
            || l_Data.Fiorus
            || UTL_TCP.Crlf
            || --
               'Дата народження: '
            || TO_CHAR (l_Data.Dateborn, 'dd.mm.yyyy')
            || UTL_TCP.Crlf
            || --
               'Стать: '
            || l_Gender
            || UTL_TCP.Crlf
            || --
               'Вид документа: '
            || NVL (l_Doc_Name, l_Data.Docnameid)
            || UTL_TCP.Crlf
            || --
               'Громадянство (держава): '
            || l_Country_Name
            || UTL_TCP.Crlf
            || --
               'Напрям перетину: '
            || l_Border_Crossing
            || UTL_TCP.Crlf
            || --
               'Серія, № паспорта: '
            || l_Data.Paspnom
            || UTL_TCP.Crlf
            || --
               'Пункт пропуску перетину: '
            || l_Codeusel_Name
            || UTL_TCP.Crlf
            || --
               'Державний реєстраційний номер (№ рейсу): '
            || l_Data.Transport
            || UTL_TCP.Crlf;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_141 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data               Api$request_Mod.r_Evod_Response;
        l_Reservation_Name   VARCHAR2 (250);
        l_Mildoc_Name        VARCHAR2 (250);
        l_Conscript_Name     VARCHAR2 (250);
    BEGIN
        l_Data := Api$request_Mod.Parse_Evod_Resp (p_Response => p_Response);

        p_Html :=
            CASE
                WHEN l_Data.Result_Code = 200
                THEN
                    'Особу знайдено'
                WHEN l_Data.Result_Code > 200 AND l_Data.Result_Code <= 300
                THEN
                    'Особу знайдено'
                WHEN l_Data.Result_Code = 400
                THEN
                    'Обов’язкові поля не заповнено або заповнено неправильно'
                WHEN l_Data.Result_Code = 3
                THEN
                    'Особу не знайдено'
            END;

        SELECT MAX (Dic_Name)
          INTO l_Reservation_Name
          FROM Uss_Ndi.v_Ddn_Mo_Reservation_St
         WHERE Dic_Code = l_Data.Reservation_Status;

        SELECT MAX (Dic_Name)
          INTO l_Mildoc_Name
          FROM Uss_Ndi.v_Ddn_Mo_Mildoc_Tp
         WHERE Dic_Code = l_Data.Mildoc_Type;

        SELECT MAX (Dic_Name)
          INTO l_Conscript_Name
          FROM Uss_Ndi.v_Ddn_Mo_Conscript_St
         WHERE Dic_Code = l_Data.Conscript_Status;

        IF l_Data.Result_Code = 200
        THEN
            p_Html :=
                   p_Html
                || UTL_TCP.Crlf
                || --
                   'Унікальний номер особи: '
                || l_Data.Guid
                || UTL_TCP.Crlf
                || --
                   'Прізвище: '
                || l_Data.Surname
                || UTL_TCP.Crlf
                || --
                   'Власне ім’я: '
                || l_Data.Name_
                || UTL_TCP.Crlf
                || --
                   'По батькові: '
                || l_Data.Patronymic
                || UTL_TCP.Crlf
                || --
                   'РНОКПП (паспорт у разі відсутності): '
                || l_Data.Rnokpp
                || UTL_TCP.Crlf
                || --
                   'Дата народження: '
                || TO_CHAR (l_Data.Date_Birth, 'dd.mm.yyyy')
                || UTL_TCP.Crlf
                || --
                   'Унікальний номер особи (ВІН): '
                || l_Data.Win
                || UTL_TCP.Crlf
                || --
                   'Звання: '
                || l_Data.RANK
                || UTL_TCP.Crlf
                || --
                   'Найменування ВОС: '
                || l_Data.Vos_Name
                || UTL_TCP.Crlf
                || --
                   'Код ВОС: '
                || l_Data.Vos_Cod
                || UTL_TCP.Crlf
                || --
                   'Вид обліку: '
                || l_Data.Account_Type
                || UTL_TCP.Crlf
                || --
                   'Статус обліку: '
                || l_Data.Account_Status
                || UTL_TCP.Crlf
                || --
                   'Причина зняття/виключення: '
                || l_Data.Reason
                || UTL_TCP.Crlf
                || --
                   'Бронювання: '
                || l_Reservation_Name
                || UTL_TCP.Crlf
                || --
                   'Дата кінця бронювання: '
                || TO_CHAR (l_Data.Reservation_End_Date, 'dd.mm.yyyy')
                || UTL_TCP.Crlf
                || --
                   'ТЦК та СП, де стоїть на обліку: '
                || l_Data.Tcc_Name
                || UTL_TCP.Crlf
                || --
                   'Придатність: '
                || l_Data.Vlk_Type
                || UTL_TCP.Crlf
                || --
                   'Дата проходження ВЛК: '
                || TO_CHAR (l_Data.Vlk_Date, 'dd.mm.yyyy')
                || UTL_TCP.Crlf
                || --
                   'Відстрочка: '
                || CASE
                       WHEN l_Data.Deferral = '0' THEN 'немає відстрочки'
                       WHEN l_Data.Deferral != '0' THEN 'є відстрочка'
                   END
                || UTL_TCP.Crlf
                || --
                   'Кінцева дата відстрочки: '
                || TO_CHAR (l_Data.Deferral_End_Date, 'dd.mm.yyyy')
                || UTL_TCP.Crlf
                || --
                   'Розшук: '
                || CASE
                       WHEN l_Data.Wanted = '0' THEN 'не в розшуку'
                       WHEN l_Data.Wanted != '0' THEN 'в розшуку'
                   END
                || UTL_TCP.Crlf
                || --
                   'Тип документу: '
                || l_Mildoc_Name
                || UTL_TCP.Crlf
                || --
                   'Серія документу: '
                || l_Data.Mildoc_Se
                || UTL_TCP.Crlf
                || --
                   'Номер документу: '
                || l_Data.Mildoc_Num
                || UTL_TCP.Crlf
                || --
                   'Статус документу військовозобов’я-заного: '
                || l_Conscript_Name
                || UTL_TCP.Crlf;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_142_143 (p_Response   IN            CLOB,
                                     p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data                       Api$request_Mod.r_Doc_Cause_Response;
        l_Personal_Identifier_Name   VARCHAR2 (250);

        FUNCTION Bool_Encode (p_Text IN VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN CASE
                       WHEN p_Text = 'T' THEN 'Так'
                       WHEN p_Text = 'F' THEN 'Ні'
                       ELSE p_Text
                   END;
        END;
    BEGIN
        l_Data :=
            Api$request_Mod.Parse_Doc_Cause_Resp (p_Response => p_Response);

        SELECT MAX (Ndt_Name)
          INTO l_Personal_Identifier_Name
          FROM Uss_Ndi.v_Ndi_Document_Type d
         WHERE d.Ndt_Id =
               Api$request_Mod.Encode_Identifier_Type (
                   l_Data.Personal_Identifier_Type);

        p_Html :=
               'Прізвище: '
            || l_Data.Person_Name1
            || UTL_TCP.Crlf
            || --
               'Ім’я: '
            || l_Data.Person_Name2
            || UTL_TCP.Crlf
            || --
               'По батькові: '
            || l_Data.Person_Name3
            || UTL_TCP.Crlf
            || --
               'Дата народження: '
            || TO_CHAR (l_Data.Person_Birth_Date, 'dd.mm.yyyy')
            || UTL_TCP.Crlf
            || --
               'Тип ідентифікатора: '
            || l_Personal_Identifier_Name
            || UTL_TCP.Crlf
            || --
               'Значення ідентифікатора: '
            || l_Data.Personal_Identifier_Value
            || UTL_TCP.Crlf
            || --
               'Масив довідок про обставини отримання травми (поранення, контузії, каліцтва): '
            || UTL_TCP.Crlf;

        IF l_Data.Doc_Cause_List IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Doc_Cause_List.COUNT
            LOOP
                IF i > 1
                THEN
                    p_Html := p_Html || '-----' || UTL_TCP.Crlf;
                END IF;

                DECLARE
                    l_Item                       Api$request_Mod.r_Doc_Cause
                                                     := l_Data.Doc_Cause_List (i);
                    l_Personal_Identifier_Name   VARCHAR2 (250);
                    l_Sign_Count                 NUMBER := 0;
                BEGIN
                    IF l_Item.Doc_Cause_Signature_List IS NOT NULL
                    THEN
                        l_Sign_Count := l_Item.Doc_Cause_Signature_List.COUNT;
                    END IF;

                    p_Html :=
                           p_Html
                        || --
                           '   Ідентифікатор (GUID) довідки про обставини травми: '
                        || l_Item.Doc_Cause_Guid
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор типу документа: '
                        || l_Item.Doc_Type_Guid
                        || UTL_TCP.Crlf
                        || --
                           '   Назва типу документа: '
                        || l_Item.Doc_Type_Name
                        || UTL_TCP.Crlf
                        || --
                           '   Реєстраційний номер документу, що вказує на підставу постанови про причинний  зв?язок: '
                        || l_Item.Doc_Cause_Number
                        || UTL_TCP.Crlf
                        || --
                           '   Дата створення документу, що вказує на підставу постанови про причинний зв?язок: '
                        || TO_CHAR (l_Item.Doc_Cause_Date, 'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор установи, що видала документ: '
                        || l_Item.Doc_Cause_Institution_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Назва установи, що видала документ, що вказує на підставу постанови про причинний зв’язок: '
                        || l_Item.Doc_Cause_Institution_Name
                        || UTL_TCP.Crlf
                        || --
                           '   Дата події травмування: '
                        || TO_CHAR (l_Item.Doc_Cause_Event_Date,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Описове поле документу (вид, характер, локалізація травми тощо): '
                        || l_Item.Doc_Cause_Event_Desc
                        || UTL_TCP.Crlf
                        || --
                           '   Формулювання за яких обставин отримана травма: '
                        || l_Item.Doc_Cause_Circumstance
                        || UTL_TCP.Crlf
                        || --
                           '   Внаслідок чого була отримана травма: '
                        || l_Item.Doc_Cause_Consequence
                        || UTL_TCP.Crlf
                        || --
                           '   Присутність засобів індивідуального захисту: '
                        || Bool_Encode (l_Item.Doc_Cause_Safety_Equipment)
                        || UTL_TCP.Crlf
                        || --
                           '   Присутність обставин  пов’язаних з вчиненням особою кримінального чи адміністративного правопорушення: '
                        || Bool_Encode (l_Item.Infringement)
                        || UTL_TCP.Crlf
                        || --
                           '   Присутність обставин пов’язаних з вчиненням дій особою у стані алкогольного, наркотичного чи токсичного сп’яніння: '
                        || Bool_Encode (l_Item.Intoxication)
                        || UTL_TCP.Crlf
                        || --
                           '   Присутність обставин  пов’язаних з вчиненням особою самокаліцтва, іншої шкоди своєму здоров’ю чи спробою самогубства: '
                        || Bool_Encode (l_Item.Self_Harm)
                        || UTL_TCP.Crlf
                        || --
                           '   Кількість накладених на документ електронних підписів: '
                        || l_Sign_Count
                        || UTL_TCP.Crlf;
                END;
            END LOOP;
        END IF;

        p_Html :=
            p_Html || 'Код помилки: ' || l_Data.Err_Code || UTL_TCP.Crlf;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_13x (
        p_Data   IN OUT NOCOPY Api$request_Diia.t_Edra_Xlinks,
        p_Html   IN OUT NOCOPY CLOB)
    IS
    BEGIN
        IF p_Data IS NULL
        THEN
            p_Html := 'Результат пустий';
            RETURN;
        ELSIF p_Data.COUNT = 0
        THEN
            p_Html := 'Результат відсутній';
            RETURN;
        END IF;

        p_Html := 'Результат:' || UTL_TCP.Crlf;

        FOR i IN 1 .. p_Data.COUNT
        LOOP
            p_Html :=
                   p_Html
                || '   '
                || p_Data (i).Atu_Id
                || ' - '
                || p_Data (i).Title
                || UTL_TCP.Crlf;
        END LOOP;
    END;

    FUNCTION Decode_13x_Namespace (p_Namespace IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Namespace
                WHEN 'UA.ATU.U' THEN 'Україна'
                WHEN 'UA.ATU.O' THEN 'Область'
                WHEN 'UA.ATU.P' THEN 'Район'
                WHEN 'UA.ATU.H' THEN 'Громада'
                WHEN 'UA.ATU.M' THEN 'Населений пункт'
                WHEN 'UA.ATU.B' THEN 'Район нас. пункту'
                WHEN 'UA.ADR.B' THEN 'Адреси будинків'
                WHEN 'UA.ADR.S' THEN 'Адреси вулиці'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Status_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN '1'
                THEN
                    'Адреса, яка очікує затвердження зберігачем набору даних або офіційним органом, відповідальним за розподіл адрес'
                WHEN '2'
                THEN
                    'Адреса, затверджена офіційним органом, відповідальним за розподіл адрес, або зберігачем набору даних, але ще не впроваджена'
                WHEN '3'
                THEN
                    'Поточна та діюча адреса відповідно до офіційного органу, відповідального за розподіл адрес, або визнана зберігачем набору даних найбільш прийнятною, загальновживаною адресою'
                WHEN '4'
                THEN
                    'Адреса більше не використовується щодня або скасовується офіційним органом, відповідальним за розподіл адрес, або зберігачем набору даних'
                WHEN '5'
                THEN
                    'Загальновідома адреса, яка відрізняється від основної адреси, визначеної офіційною організацією, відповідальною за призначення адрес або постачальником даних'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Named_Place_Type_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'administrativeUnit'
                THEN
                    'Адміністративно-територіальні одиниці, що розділяють райони, де держави-члени мають та/або здійснюють юрисдикційні права, для місцевого, регіонального та національного управління, розділені адміністративними межами'
                WHEN 'hydrography'
                THEN
                    'Гідрографічні елементи, включаючи морські райони та всі інші водні об’єкти та об’єкти, пов’язані з ними, включаючи річкові басейни'
                WHEN 'landcover'
                THEN
                    'Фізичний та біологічний покрив земної поверхні, включаючи штучні поверхні, сільськогосподарські площі, ліси, заболочені ділянки, водні об’єкти'
                WHEN 'landform'
                THEN
                    'Геоморфологічна особливість рельєфу'
                WHEN 'populatedPlace'
                THEN
                    'Місце, де мешкають люди'
                WHEN 'protectedSite'
                THEN
                    'Територія, призначена або керована в рамках міжнародного законодавства, законодавства Співтовариства та держав-членів для досягнення конкретних цілей запобігання або захисту'
                WHEN 'transportNetwork'
                THEN
                    'Автомобільні, залізничні, повітряні та водні транспортні мережі та супутня інфраструктура. Включає зв’язки між різними мережами'
                WHEN 'building'
                THEN
                    'Географічне розташування будівель'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Administrative_Hierarchy_Level (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN '1'
                THEN
                    'Перший рівень - Держава'
                WHEN '2'
                THEN
                    'Другий рівень - Область'
                WHEN '3'
                THEN
                    'Третій рівень - Район'
                WHEN '4'
                THEN
                    'Четвертий рівень - Територіальна громада (місцева рада)'
                WHEN '5'
                THEN
                    'П''ятий рівень - населені пункти'
                WHEN '6'
                THEN
                    'Шостий рівень - райони у містах'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Geometry_Method_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'fromFeature'
                THEN
                    'Успадковується автоматично з іншого просторового об’єкту, пов’язаного з поточним. Наприклад, координати квартири можуть успадковуватися  від координат відповідної будівлі'
                WHEN 'byAdministrator'
                THEN
                    'Вирішує та реєструє вручну офіційний орган, відповідальний за розподіл адрес, або зберігач набору даних'
                WHEN 'byOtherParty'
                THEN
                    'Вирішила та записала вручну третя сторона'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Locator_Name_Type_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'siteName' THEN 'Назва нерухомості'
                WHEN 'buildingName' THEN 'Назва будівлі'
                WHEN 'roomName' THEN 'Ідентифікатор житла'
                WHEN 'descriptiveLocator' THEN 'Опис місця розташування'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Locator_Designator_Type_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'addressIdentifierGeneral'
                THEN
                    'Ідентифікатор адреси'
                WHEN 'addressNumber'
                THEN
                    'Номер адреси'
                WHEN 'addressNumberExtension'
                THEN
                    'Розширення на номер адреси'
                WHEN 'addressNumber2ndExtension'
                THEN
                    'Розширення2 на номер адреси'
                WHEN 'buildingIdentifier'
                THEN
                    'Будівля (корпус)'
                WHEN 'buildingIdentifierPrefix'
                THEN
                    'Префікс до номера будівлі'
                WHEN 'entranceDoorIdentifier'
                THEN
                    'Вхідні двері (підїзд)'
                WHEN 'staircaseIdentifier'
                THEN
                    'Сходи'
                WHEN 'floorIdentifier'
                THEN
                    'Поверх'
                WHEN 'unitIdentifier'
                THEN
                    'Квартира'
                WHEN 'postalDeliveryIdentifier'
                THEN
                    'Поштова доставка'
                WHEN 'kilometrePoint'
                THEN
                    'Позначка на дорозі'
                WHEN 'cornerAddress1stIdentifier'
                THEN
                    'Магістраль в кутовій адресі'
                WHEN 'cornerAddress2ndIdentifier'
                THEN
                    'Вторинна магістраль в кутовій адресі'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Nativeness_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'endonym'
                THEN
                    'Назва географічного об’єкта офіційною або усталеною мовою, що зустрічається в тій місцевості, де знаходиться об’єкт.'
                WHEN 'exonym'
                THEN
                    'Назва, що використовується конкретною мовою для географічного об’єкта, розташованого за межами району, де цією мовою широко розмовляють, і відрізняється за формою від відповідного ендоніму (ів) у районі, де знаходиться географічна об’єкт.'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Name_Status_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'official'
                THEN
                    'Найменування, що використовується в даний час та офіційно затверджено або встановлено законодавством'
                WHEN 'standardised'
                THEN
                    'Ім’я, що використовується в даний час та прийняте або рекомендоване органом, якому призначена консультативна функція та / або повноваження щодо прийняття рішень у питаннях топоніміки'
                WHEN 'historical'
                THEN
                    'Історична назва не використовується в даний час'
                WHEN 'other'
                THEN
                    'Поточна, але неофіційна та не затверджена назва'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Grammatical_Number_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'singular' THEN 'Однина географічної назви'
                WHEN 'plural' THEN 'Множина географічної назви'
                WHEN 'dual' THEN 'Географічна назва в однині та множині'
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_13x_Grammatical_Gender_Value (p_Value IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            CASE p_Value
                WHEN 'masculine' THEN 'Чоловічій граматичний рід'
                WHEN 'feminine' THEN 'Жіночій граматичний рід'
                WHEN 'neuter' THEN 'Середній граматичний рід'
                WHEN 'common' THEN 'Загальний граматичний рід'
            END;
        RETURN l_Result;
    END;

    PROCEDURE Response2text_133 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.r_Administrative_Unit;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Edrato_Resp (p_Response => p_Response);

        IF l_Data.Inspire_Id.Local_Id IS NULL
        THEN
            p_Html := 'Результат відсутній';
            RETURN;
        END IF;

        p_Html :=
               'Ідентифікатор: '
            || l_Data.Inspire_Id.Local_Id
            || UTL_TCP.Crlf
            || --
               'Тип обєкта: '
            || l_Data.Inspire_Id.Namespace
            || ' - '
            || Decode_13x_Namespace (l_Data.Inspire_Id.Namespace)
            || UTL_TCP.Crlf
            || --
               'Версія: '
            || l_Data.Inspire_Id.Version_Id
            || UTL_TCP.Crlf
            || --
               'Рівень (тип): '
            || l_Data.National_Level_Name
            || ' - '
            || Decode_13x_Administrative_Hierarchy_Level (
                   l_Data.National_Level)
            || UTL_TCP.Crlf
            || --
               'Назва (текст): '
            || l_Data.Name_.Spelling.Text
            || UTL_TCP.Crlf
            || --
               'Назва (властивості): '
            || l_Data.Name_.Language_
            || ' - '
            || Decode_13x_Nativeness_Value (l_Data.Name_.Nativeness)
            || ' - '
            || Decode_13x_Name_Status_Value (l_Data.Name_.Name_Status)
            || ' - '
            || Decode_13x_Grammatical_Gender_Value (
                   l_Data.Name_.Grammatical_Gender)
            || ' - '
            || Decode_13x_Grammatical_Number_Value (
                   l_Data.Name_.Grammatical_Number)
            || UTL_TCP.Crlf
            || --
               'Дійсний: '
            || TO_CHAR (l_Data.Valid_From, 'dd.mm.yyyy')
            || ' - '
            || NVL (TO_CHAR (l_Data.Valid_To, 'dd.mm.yyyy'), '-')
            || UTL_TCP.Crlf
            || --
               'Було змінено: '
            || TO_CHAR (l_Data.Begin_Lifespan_Version, 'dd.mm.yyyy')
            || UTL_TCP.Crlf
            || --
               'Було закрито: '
            || TO_CHAR (l_Data.End_Lifespan_Version, 'dd.mm.yyyy')
            || UTL_TCP.Crlf;

        IF l_Data.Lower_Level_Unit IS NOT NULL
        THEN
            IF l_Data.Lower_Level_Unit.COUNT > 0
            THEN
                p_Html := p_Html || 'Дочірні елементи:' || UTL_TCP.Crlf;

                FOR i IN 1 .. l_Data.Lower_Level_Unit.COUNT
                LOOP
                    p_Html :=
                           p_Html
                        || '   '
                        || l_Data.Lower_Level_Unit (i).Atu_Id
                        || ' - '
                        || l_Data.Lower_Level_Unit (i).Title
                        || UTL_TCP.Crlf;
                END LOOP;
            END IF;
        END IF;

        IF l_Data.Upper_Level_Unit IS NOT NULL
        THEN
            IF l_Data.Upper_Level_Unit.COUNT > 0
            THEN
                p_Html := p_Html || 'Батьківські елементи:' || UTL_TCP.Crlf;

                FOR i IN 1 .. l_Data.Upper_Level_Unit.COUNT
                LOOP
                    p_Html :=
                           p_Html
                        || '   '
                        || l_Data.Upper_Level_Unit (i).Atu_Id
                        || ' - '
                        || l_Data.Upper_Level_Unit (i).Title
                        || UTL_TCP.Crlf;
                END LOOP;
            END IF;
        END IF;

        IF l_Data.Administered_By.Href IS NOT NULL
        THEN
            p_Html :=
                   p_Html
                || '   Підпорядковано:'
                || l_Data.Administered_By.Atu_Id
                || ' - '
                || l_Data.Administered_By.Title
                || UTL_TCP.Crlf;
        END IF;

        IF l_Data.Boundary IS NOT NULL
        THEN
            IF l_Data.Boundary.COUNT > 0
            THEN
                p_Html := p_Html || 'Межі:' || UTL_TCP.Crlf;

                FOR i IN 1 .. l_Data.Boundary.COUNT
                LOOP
                    p_Html :=
                           p_Html
                        || '   '
                        || l_Data.Boundary (i).Atu_Id
                        || ' - '
                        || l_Data.Boundary (i).Title
                        || UTL_TCP.Crlf;
                END LOOP;
            END IF;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_134 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.t_Edra_Xlinks;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Edrato_List_Resp (p_Response => p_Response);
        Response2text_13x (p_Data => l_Data, p_Html => p_Html);
    END;

    PROCEDURE Response2text_135 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.t_Edra_Xlinks;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Street_List_Resp (p_Response => p_Response);
        Response2text_13x (p_Data => l_Data, p_Html => p_Html);
    END;

    PROCEDURE Response2text_136 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.r_Edra_Member;
    BEGIN
        l_Data := Api$request_Diia.Parse_Edra_Resp (p_Response => p_Response);

        p_Html := '';

        IF l_Data.Address IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Address.COUNT
            LOOP
                DECLARE
                    l_Item   Api$request_Diia.r_Address := l_Data.Address (i);
                BEGIN
                    p_Html :=
                           p_Html
                        || 'Адреса:'
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор: '
                        || l_Item.Inspire_Id.Local_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Тип обєкта: '
                        || l_Item.Inspire_Id.Namespace
                        || ' - '
                        || Decode_13x_Namespace (l_Item.Inspire_Id.Namespace)
                        || UTL_TCP.Crlf
                        || --
                           '   Версія: '
                        || l_Item.Inspire_Id.Version_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Статус: '
                        || Decode_13x_Status_Value (l_Item.Status.Title)
                        || UTL_TCP.Crlf
                        || --
                           '   Дійсний: '
                        || TO_CHAR (l_Item.Valid_From, 'dd.mm.yyyy')
                        || ' - '
                        || NVL (TO_CHAR (l_Item.Valid_To, 'dd.mm.yyyy'), '-')
                        || UTL_TCP.Crlf
                        || --
                           '   Було змінено: '
                        || TO_CHAR (l_Item.Begin_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Було закрито: '
                        || TO_CHAR (l_Item.End_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf;

                    IF l_Item.Locator IS NOT NULL
                    THEN
                        FOR j IN 1 .. l_Item.Locator.COUNT
                        LOOP
                            IF l_Item.Locator (j).Designator IS NOT NULL
                            THEN
                                p_Html :=
                                       p_Html
                                    || '   Ідентифікація об''єкта: '
                                    || UTL_TCP.Crlf;

                                FOR k
                                    IN 1 ..
                                       l_Item.Locator (j).Designator.COUNT
                                LOOP
                                    p_Html :=
                                           p_Html
                                        || '      '
                                        || Decode_13x_Locator_Designator_Type_Value (
                                               l_Item.Locator (j).Designator (
                                                   k).Type_.Title)
                                        || ': '
                                        || l_Item.Locator (j).Designator (k).Designator
                                        || UTL_TCP.Crlf;
                                END LOOP;
                            END IF;

                            IF l_Item.Locator (j).Name_ IS NOT NULL
                            THEN
                                p_Html :=
                                       p_Html
                                    || '   Назва об''єкта: '
                                    || UTL_TCP.Crlf;

                                FOR k IN 1 .. l_Item.Locator (j).Name_.COUNT
                                LOOP
                                    p_Html :=
                                           p_Html
                                        || '      '
                                        || Decode_13x_Locator_Designator_Type_Value (
                                               l_Item.Locator (j).Name_ (k).Type_.Title)
                                        || ': '
                                        || l_Item.Locator (j).Name_ (k).Name_.Spelling.Text
                                        || UTL_TCP.Crlf;
                                END LOOP;
                            END IF;
                        END LOOP;
                    END IF;

                    IF l_Item.Parcel IS NOT NULL
                    THEN
                        IF l_Item.Parcel.COUNT > 0
                        THEN
                            p_Html :=
                                   p_Html
                                || '   Земельна ділянка:'
                                || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Parcel.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Parcel (j).Atu_Id
                                    || ' - '
                                    || l_Item.Parcel (j).Title
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    IF l_Item.Parent_Address.Href IS NOT NULL
                    THEN
                        p_Html :=
                               p_Html
                            || '   Основна адреса:'
                            || l_Item.Parent_Address.Atu_Id
                            || ' - '
                            || l_Item.Parent_Address.Title
                            || UTL_TCP.Crlf;
                    END IF;

                    IF l_Item.Building IS NOT NULL
                    THEN
                        IF l_Item.Building.COUNT > 0
                        THEN
                            p_Html := p_Html || '   Споруда:' || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Building.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Building (j).Atu_Id
                                    || ' - '
                                    || l_Item.Building (j).Title
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    IF l_Item.Component IS NOT NULL
                    THEN
                        IF l_Item.Component.COUNT > 0
                        THEN
                            p_Html :=
                                p_Html || '   Компонент:' || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Component.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Component (j).Atu_Id
                                    || ' - '
                                    || l_Item.Component (j).Title
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    p_Html := p_Html || UTL_TCP.Crlf;
                END;
            END LOOP;
        END IF;

        IF l_Data.Thoroughfare_Name IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Thoroughfare_Name.COUNT
            LOOP
                DECLARE
                    l_Item   Api$request_Diia.r_Thoroughfare_Name
                                 := l_Data.Thoroughfare_Name (i);
                BEGIN
                    p_Html :=
                           p_Html
                        || 'Вулиця:'
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор: '
                        || l_Item.Inspire_Id.Local_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Тип обєкта: '
                        || l_Item.Inspire_Id.Namespace
                        || ' - '
                        || Decode_13x_Namespace (l_Item.Inspire_Id.Namespace)
                        || UTL_TCP.Crlf
                        || --
                           '   Версія: '
                        || l_Item.Inspire_Id.Version_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Статус: '
                        || Decode_13x_Status_Value (l_Item.Status.Title)
                        || UTL_TCP.Crlf
                        || --
                           '   Дійсний: '
                        || TO_CHAR (l_Item.Valid_From, 'dd.mm.yyyy')
                        || ' - '
                        || NVL (TO_CHAR (l_Item.Valid_To, 'dd.mm.yyyy'), '-')
                        || UTL_TCP.Crlf
                        || --
                           '   Було змінено: '
                        || TO_CHAR (l_Item.Begin_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Було закрито: '
                        || TO_CHAR (l_Item.End_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf;

                    IF l_Item.Situated_Within IS NOT NULL
                    THEN
                        IF l_Item.Situated_Within.COUNT > 0
                        THEN
                            p_Html :=
                                p_Html || '   Зв''язок:' || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Situated_Within.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Situated_Within (j).Atu_Id
                                    || ' - '
                                    || l_Item.Situated_Within (j).Title
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    IF l_Item.Name_ IS NOT NULL
                    THEN
                        IF l_Item.Name_.COUNT > 0
                        THEN
                            p_Html := p_Html || '   Назва:' || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Name_.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Name_ (j).Name_.Spelling.Text
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    IF l_Item.Transport_Link IS NOT NULL
                    THEN
                        IF l_Item.Transport_Link.COUNT > 0
                        THEN
                            p_Html :=
                                   p_Html
                                || '   Транспортні мережі:'
                                || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Transport_Link.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Transport_Link (j).Atu_Id
                                    || ' - '
                                    || l_Item.Transport_Link (j).Title
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;
                    END IF;

                    p_Html := p_Html || UTL_TCP.Crlf;
                END;
            END LOOP;
        END IF;

        IF l_Data.Address_Area_Name IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Address_Area_Name.COUNT
            LOOP
                DECLARE
                    l_Item   Api$request_Diia.r_Address_Area_Name
                                 := l_Data.Address_Area_Name (i);
                BEGIN
                    p_Html :=
                           p_Html
                        || 'Поіменований об''єкт:'
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор: '
                        || l_Item.Inspire_Id.Local_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Тип обєкта: '
                        || l_Item.Inspire_Id.Namespace
                        || ' - '
                        || Decode_13x_Namespace (l_Item.Inspire_Id.Namespace)
                        || UTL_TCP.Crlf
                        || --
                           '   Версія: '
                        || l_Item.Inspire_Id.Version_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Статус: '
                        || Decode_13x_Status_Value (l_Item.Status.Title)
                        || UTL_TCP.Crlf
                        || --
                           '   Дійсний: '
                        || TO_CHAR (l_Item.Valid_From, 'dd.mm.yyyy')
                        || ' - '
                        || NVL (TO_CHAR (l_Item.Valid_To, 'dd.mm.yyyy'), '-')
                        || UTL_TCP.Crlf
                        || --
                           '   Було змінено: '
                        || TO_CHAR (l_Item.Begin_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Було закрито: '
                        || TO_CHAR (l_Item.End_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Назва: '
                        || l_Item.Name_.Spelling.Text
                        || UTL_TCP.Crlf;

                    p_Html := p_Html || UTL_TCP.Crlf;
                END;
            END LOOP;
        END IF;

        IF l_Data.Admin_Unit_Name IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Admin_Unit_Name.COUNT
            LOOP
                DECLARE
                    l_Item   Api$request_Diia.r_Admin_Unit_Name
                                 := l_Data.Admin_Unit_Name (i);
                BEGIN
                    p_Html :=
                           p_Html
                        || 'Адмін одиниця:'
                        || UTL_TCP.Crlf
                        || --
                           '   Ідентифікатор: '
                        || l_Item.Inspire_Id.Local_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Тип обєкта: '
                        || l_Item.Inspire_Id.Namespace
                        || ' - '
                        || Decode_13x_Namespace (l_Item.Inspire_Id.Namespace)
                        || UTL_TCP.Crlf
                        || --
                           '   Версія: '
                        || l_Item.Inspire_Id.Version_Id
                        || UTL_TCP.Crlf
                        || --
                           '   Статус: '
                        || Decode_13x_Status_Value (l_Item.Status.Title)
                        || UTL_TCP.Crlf
                        || --
                           '   Дійсний: '
                        || TO_CHAR (l_Item.Valid_From, 'dd.mm.yyyy')
                        || ' - '
                        || NVL (TO_CHAR (l_Item.Valid_To, 'dd.mm.yyyy'), '-')
                        || UTL_TCP.Crlf
                        || --
                           '   Було змінено: '
                        || TO_CHAR (l_Item.Begin_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Було закрито: '
                        || TO_CHAR (l_Item.End_Lifespan_Version,
                                    'dd.mm.yyyy')
                        || UTL_TCP.Crlf
                        || --
                           '   Назва: '
                        || l_Item.Name_.Spelling.Text
                        || UTL_TCP.Crlf
                        || --
                           '   Рівень: '
                        || l_Item.Level_.Title
                        || UTL_TCP.Crlf;

                    p_Html := p_Html || UTL_TCP.Crlf;
                END;
            END LOOP;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_137 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.t_Edra_Xlinks;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Address_Resp (p_Response => p_Response);
        Response2text_13x (p_Data => l_Data, p_Html => p_Html);
    END;

    PROCEDURE Response2text_138 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.t_Edra_Xlinks;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Geocoding_Resp (p_Response => p_Response);
        Response2text_13x (p_Data => l_Data, p_Html => p_Html);
    END;

    PROCEDURE Response2text_139 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Diia.t_Edra_Xlinks;
    BEGIN
        l_Data :=
            Api$request_Diia.Parse_Geocoding_Edrato_Resp (
                p_Response   => p_Response);
        Response2text_13x (p_Data => l_Data, p_Html => p_Html);
    END;

    PROCEDURE Response2text_146 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Data   Api$request_Mon.r_Full_Time_Study_List_Response;
    BEGIN
        l_Data :=
            Api$request_Mon.Parse_Full_Time_Study_List_Resp (
                p_Response   => p_Response);

        p_Html :=
               'Індикатор обробки запиту: '
            || CASE l_Data.Full_Time_Study_Result.Status
                   WHEN Api$request_Mon.c_Study_Status_Empty
                   THEN
                       'особу не знайдено'
                   WHEN Api$request_Mon.c_Study_Status_Ok
                   THEN
                       'знайдено особу, яка здобуває освіту на денній формі навчання'
                   WHEN Api$request_Mon.c_Study_Status_End
                   THEN
                       'знайдено особу, яка припинила навчання на денній формі навчання'
                   WHEN Api$request_Mon.c_Study_Status_Notvalid
                   THEN
                       'обов’язкові поля не заповнено або заповнено неправильно'
                   WHEN Api$request_Mon.c_Study_Status_Many
                   THEN
                       'знайдено більше однієї особи'
               END
            || UTL_TCP.Crlf;

        IF l_Data.Full_Time_Study_Result.Status =
           Api$request_Mon.c_Study_Status_Ok
        THEN
            p_Html := p_Html || 'Масив даних щодо особи:' || UTL_TCP.Crlf;

            IF l_Data.Full_Time_Study_Result.Study_List IS NOT NULL
            THEN
                FOR i IN 1 .. l_Data.Full_Time_Study_Result.Study_List.COUNT
                LOOP
                    IF i > 1
                    THEN
                        p_Html := p_Html || '   -----' || UTL_TCP.Crlf;
                    END IF;

                    DECLARE
                        l_Item   Api$request_Mon.r_Study_Entity
                            := l_Data.Full_Time_Study_Result.Study_List (i);
                    BEGIN
                        p_Html :=
                               p_Html
                            || '   Освітній ступінь: '
                            || l_Item.Ed_Degree
                            || UTL_TCP.Crlf
                            ||                                                             --
                               '   Назва закладу освіти: '
                            || l_Item.Ed_Name
                            || UTL_TCP.Crlf
                            ||                                                                --
                               '   Код ЄДРПОУ закладу освіти: '
                            || l_Item.Edrpou
                            || UTL_TCP.Crlf
                            ||                                                                    --
                               '   Код спеціальності: '
                            || l_Item.Sp_Code
                            || UTL_TCP.Crlf
                            ||                                                              --
                               '   Назва спеціальності: '
                            || l_Item.Sp_Name
                            || UTL_TCP.Crlf
                            ||                                                                --
                               '   Код спеціалізації: '
                            || l_Item.Spz_Code
                            || UTL_TCP.Crlf
                            ||                                                              --
                               '   Назва спеціалізації: '
                            || l_Item.Spz_Name
                            || UTL_TCP.Crlf;

                        IF l_Item.Professions IS NOT NULL
                        THEN
                            p_Html :=
                                   p_Html
                                || '   Масив даних по професіях:'
                                || UTL_TCP.Crlf;

                            FOR j IN 1 .. l_Item.Professions.COUNT
                            LOOP
                                p_Html :=
                                       p_Html
                                    || '      '
                                    || l_Item.Professions (j).Prof_Code
                                    || ' - '
                                    || l_Item.Professions (j).Prof_Name
                                    || UTL_TCP.Crlf;
                            END LOOP;
                        END IF;

                        p_Html :=
                               p_Html
                            || '   Дата початку навчання: '
                            || TO_CHAR (l_Item.Date_Begin, 'dd.mm.yyyy')
                            || UTL_TCP.Crlf
                            ||                                              --
                               '   Дата завершення навчання: '
                            || TO_CHAR (l_Item.Date_End, 'dd.mm.yyyy')
                            || UTL_TCP.Crlf;
                    END;
                END LOOP;
            END IF;
        ELSIF l_Data.Full_Time_Study_Result.Status =
              Api$request_Mon.c_Study_Status_End
        THEN
            p_Html :=
                   p_Html
                || 'Дата, з якої припинено навчання на денній формі: '
                || TO_CHAR (l_Data.Full_Time_Study_Result.Date_Stop,
                            'dd.mm.yyyy')
                || UTL_TCP.Crlf;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_147 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Resp_Data            CLOB;
        l_Resp_Error_Code      VARCHAR2 (100);
        l_Resp_Error_Message   VARCHAR2 (1000);
        l_Data                 Api$request_Mon.r_Info_By_Pupil_Response;

        l_Gender               VARCHAR2 (250);
    BEGIN
        Api$request_Mon.Get_Respapi_Resp (
            p_Response        => p_Response,
            p_Data            => l_Resp_Data,
            p_Error_Code      => l_Resp_Error_Code,
            p_Error_Message   => l_Resp_Error_Message);
        l_Data :=
            Api$request_Mon.Parse_Info_By_Pupil_Resp (
                p_Response_Data   => l_Resp_Data);

        IF l_Resp_Error_Code IS NOT NULL
        THEN
            p_Html :=
                   'Трапилась помилка:'
                || UTL_TCP.Crlf                                                             --
                || '   Код: '
                || l_Resp_Error_Code
                || UTL_TCP.Crlf                                                --
                || '   Текст:'
                || l_Resp_Error_Message
                || UTL_TCP.Crlf                                                  --
                || '   Опис:'
                || CASE l_Resp_Error_Code
                       WHEN Api$request_Mon.c_Error_Not_Found
                       THEN
                           'Не знайдено жодного учня із заданими параметрами'
                       WHEN Api$request_Mon.c_Error_Expelled_Death
                       THEN
                           'Відрахований у зв''язку зі смертю дитини'
                       WHEN Api$request_Mon.c_Error_Expelled_Depart
                       THEN
                           'Відраховано за заявою у зв''язку з виїздом дитини за кордон (ПМЖ)'
                       WHEN Api$request_Mon.c_Error_Completed
                       THEN
                           'Учень закінчив навчання'
                       WHEN Api$request_Mon.c_Error_Not_Attending_School
                       THEN
                           'Не відвідує жодної школи'
                   END
                || UTL_TCP.Crlf;
            RETURN;
        END IF;

        SELECT MAX (Dic_Name)
          INTO l_Gender
          FROM Uss_Ndi.v_Ddn_Gender
         WHERE Dic_Code = l_Data.Gender;

        p_Html :=
               'Прізвище: '
            || l_Data.Last_Name
            || UTL_TCP.Crlf                                                         --
            || 'Ім’я: '
            || l_Data.First_Name
            || UTL_TCP.Crlf                                                      --
            || 'По батькові: '
            || l_Data.Second_Name
            || UTL_TCP.Crlf                                                           --
            || 'Дата народження дитини: '
            || TO_CHAR (l_Data.Birthday, 'dd.mm.yyyy')
            || UTL_TCP.Crlf                                                                     --
            || 'Стать: '
            || l_Gender
            || UTL_TCP.Crlf                                                      --
            || 'Адреса проживання (фактична): '
            || l_Data.Address_Fact
            || UTL_TCP.Crlf                                                                         --
            || 'Адреса в розгорнутому вигляді: '
            || UTL_TCP.Crlf                                                                           --
            || '   Назва області: '
            || l_Data.Address.Region
            || UTL_TCP.Crlf                                                             --
            || '   Назва району: '
            || l_Data.Address.District
            || UTL_TCP.Crlf                                                            --
            || '   Тип населеного пункту: '
            || l_Data.Address.Locality_Type
            || UTL_TCP.Crlf                                                                    --
            || '   Назва населеного пункту: '
            || l_Data.Address.Locality
            || UTL_TCP.Crlf                                                                      --
            || '   Назва вулиці: '
            || l_Data.Address.Street
            || UTL_TCP.Crlf                                                            --
            || '   Будинок: '
            || l_Data.Address.House
            || UTL_TCP.Crlf                                                        --
            || '   Номер корпусу чи секції: '
            || l_Data.Address.Building_Part
            || UTL_TCP.Crlf                                                                     --
            || '   Тип: '
            || CASE l_Data.Address.Building_Part_Type
                   WHEN '1' THEN 'корпус'
                   WHEN '2' THEN 'секція'
                   ELSE l_Data.Address.Building_Part_Type
               END
            || UTL_TCP.Crlf                                                 --
            || '   Квартира: '
            || l_Data.Address.Apartment
            || UTL_TCP.Crlf                                                         --
            || 'Навчальний заклад: '
            || UTL_TCP.Crlf                                                                 --
            || '   Код згідно з ЄДРПОУ: '
            || l_Data.University.Edrpo
            || UTL_TCP.Crlf                                                                 --
            || '   Скорочена назва закладу освіти: '
            || l_Data.University.Short_Name
            || UTL_TCP.Crlf                                                                            --
            || '   Тип закладу: '
            || l_Data.University.Educationl_Type
            || UTL_TCP.Crlf                                                           --
            || '   Тип закладу: '
            || l_Data.University.Educationl_Type_Code
            || UTL_TCP.Crlf                                                           --
            || '   Профіль навчання: '
            || UTL_TCP.Crlf;

        IF l_Data.University.Educational_Profiles IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.University.Educational_Profiles.COUNT
            LOOP
                p_Html :=
                       p_Html
                    || '      '
                    || l_Data.University.Educational_Profiles (i)
                    || UTL_TCP.Crlf;
            END LOOP;
        END IF;

        p_Html :=
               p_Html
            || '   Ознака евакуації закладу: '
            || CASE l_Data.University.Is_Evacuated
                   WHEN 'T' THEN 'так'
                   WHEN 'F' THEN 'ні'
                   ELSE l_Data.University.Is_Evacuated
               END
            || UTL_TCP.Crlf                                                 --
            || '   Адреса евакуації закладу: '
            || l_Data.University.Address_Evacuated
            || UTL_TCP.Crlf                                                                       --
            || '   Перебування учня у закладі: '
            || l_Data.Night_Stay
            || UTL_TCP.Crlf                                                                        --
            || '   Спеціалізації закладу освіти: '
            || UTL_TCP.Crlf;

        IF l_Data.Specialties IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Specialties.COUNT
            LOOP
                p_Html :=
                       p_Html
                    || '      '
                    || l_Data.Specialties (i).Specialty
                    || UTL_TCP.Crlf;
            END LOOP;
        END IF;

        p_Html :=
               p_Html
            || '   Форма навчання: '
            || l_Data.Education_Form.Form_Type
            || UTL_TCP.Crlf                                                              --
            || '   Форма здобуття освіти: '
            || l_Data.Education_Form.Form_Subtype
            || UTL_TCP.Crlf                                                                    --
            || '   Навчальний рік: '
            || l_Data.Academic_Year
            || UTL_TCP.Crlf                                                              --
            || '   Перебуває на повному державному утриманні: '
            || CASE l_Data.Is_Full_State_Support
                   WHEN 'T' THEN 'так'
                   WHEN 'F' THEN 'ні'
                   ELSE l_Data.Is_Full_State_Support
               END
            || UTL_TCP.Crlf                                                 --
            || '   Дата початку перебування на повному державному утриманні: '
            || TO_CHAR (l_Data.Full_State_Support.Date_From, 'dd.mm.yyyy')
            || UTL_TCP.Crlf                                                 --
            || '   Дата кінця  перебування на повному державному утриманні: '
            || TO_CHAR (l_Data.Full_State_Support.Date_By, 'dd.mm.yyyy')
            || UTL_TCP.Crlf                                                 --
            || '   Розмір стипендії: '
            || l_Data.Full_State_Support.Stipend
            || UTL_TCP.Crlf                                                                --
            || '   Законні представники учня: '
            || UTL_TCP.Crlf;

        IF l_Data.Parents IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Parents.COUNT
            LOOP
                IF i > 1
                THEN
                    p_Html := p_Html || '      -----' || UTL_TCP.Crlf;
                END IF;

                p_Html :=
                       p_Html
                    || '      Тип законного представника: '
                    || l_Data.Parents (i).Type_Parent
                    || UTL_TCP.Crlf;
                p_Html :=
                       p_Html
                    || '      Прізвище: '
                    || l_Data.Parents (i).Last_Name
                    || UTL_TCP.Crlf;
                p_Html :=
                       p_Html
                    || '      Ім’я: '
                    || l_Data.Parents (i).First_Name
                    || UTL_TCP.Crlf;
                p_Html :=
                       p_Html
                    || '      По батькові: '
                    || l_Data.Parents (i).Second_Name
                    || UTL_TCP.Crlf;
            END LOOP;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    PROCEDURE Response2text_148 (p_Response   IN            CLOB,
                                 p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Resp_Data            CLOB;
        l_Resp_Error_Code      VARCHAR2 (100);
        l_Resp_Error_Message   VARCHAR2 (1000);
        l_Data                 Api$request_Mon.r_Dictionary_Response;
    BEGIN
        Api$request_Mon.Get_Respapi_Resp (
            p_Response        => p_Response,
            p_Data            => l_Resp_Data,
            p_Error_Code      => l_Resp_Error_Code,
            p_Error_Message   => l_Resp_Error_Message);
        l_Data :=
            Api$request_Mon.Parse_Dictionary_Resp (
                p_Response_Data   => l_Resp_Data);

        IF l_Resp_Error_Code IS NOT NULL
        THEN
            p_Html :=
                   'Трапилась помилка:'
                || UTL_TCP.Crlf
                || --
                   '   Код: '
                || l_Resp_Error_Code
                || UTL_TCP.Crlf
                || --
                   '   Текст:'
                || l_Resp_Error_Message
                || UTL_TCP.Crlf;
            RETURN;
        END IF;

        p_Html :=
               'Тип довідника: '
            || l_Data.Type_Dictionary
            || UTL_TCP.Crlf
            || --
               'Назва довідника: '
            || l_Data.Name_Dictionary
            || UTL_TCP.Crlf
            || --
               'Дані довідника:'
            || UTL_TCP.Crlf;

        IF l_Data.Data_Dictionary IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Data_Dictionary.COUNT
            LOOP
                p_Html :=
                       p_Html
                    || '   '
                    || l_Data.Data_Dictionary (i).Code
                    || ' - '
                    || l_Data.Data_Dictionary (i).Name_
                    || UTL_TCP.Crlf;
            END LOOP;
        END IF;

        p_Html :=
               p_Html
            || UTL_TCP.Crlf
            || 'Оригінальна відповідь:'
            || UTL_TCP.Crlf
            || p_Response;
    END;

    --------------------------------------------------------------------------
    -- Конвертація відповіді в читаємий вигляд
    --------------------------------------------------------------------------
    PROCEDURE Response2text (p_Ur_Id      IN            NUMBER,
                             p_Response   IN            CLOB,
                             p_Html       IN OUT NOCOPY CLOB)
    IS
        l_Nrt_Id   NUMBER;
    BEGIN
        l_Nrt_Id := Api$uxp_Request.Get_Ur_Nrt (p_Ur_Id => p_Ur_Id);

        CASE l_Nrt_Id
            --dpsu
            WHEN 144
            THEN
                Response2text_144 (p_Response => p_Response, p_Html => p_Html);
            --mo
            WHEN 141
            THEN
                Response2text_141 (p_Response => p_Response, p_Html => p_Html);
            WHEN 142
            THEN
                Response2text_142_143 (p_Response   => p_Response,
                                       p_Html       => p_Html);
            WHEN 143
            THEN
                Response2text_142_143 (p_Response   => p_Response,
                                       p_Html       => p_Html);
            --diia-edra
            WHEN 133
            THEN
                Response2text_133 (p_Response => p_Response, p_Html => p_Html);
            WHEN 134
            THEN
                Response2text_134 (p_Response => p_Response, p_Html => p_Html);
            WHEN 135
            THEN
                Response2text_135 (p_Response => p_Response, p_Html => p_Html);
            WHEN 136
            THEN
                Response2text_136 (p_Response => p_Response, p_Html => p_Html);
            WHEN 137
            THEN
                Response2text_137 (p_Response => p_Response, p_Html => p_Html);
            WHEN 138
            THEN
                Response2text_138 (p_Response => p_Response, p_Html => p_Html);
            WHEN 139
            THEN
                Response2text_139 (p_Response => p_Response, p_Html => p_Html);
            --mon
            WHEN 146
            THEN
                Response2text_146 (p_Response => p_Response, p_Html => p_Html);
            WHEN 147
            THEN
                Response2text_147 (p_Response => p_Response, p_Html => p_Html);
            WHEN 148
            THEN
                Response2text_148 (p_Response => p_Response, p_Html => p_Html);
            ELSE
                p_Html := p_Response;
        END CASE;
    END;

    --------------------------------------------------------------------------
    -- Обробка відповіді на запит
    --------------------------------------------------------------------------
    PROCEDURE Handle_Request (p_Ur_Id      IN     NUMBER,
                              p_Response   IN     CLOB,
                              p_Error      IN OUT VARCHAR2)
    IS
        l_Html   CLOB;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Save_Request_Result (
                p_Rdj_Rn       => Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
                p_Rdj_Result   => NVL (p_Response, TO_CLOB (p_Error)),
                p_Rdj_St       => c_Rdj_St_Fail);

            IF p_Response IS NOT NULL
            THEN
                RETURN;
            END IF;

            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            Response2text (p_Ur_Id      => p_Ur_Id,
                           p_Response   => p_Response,
                           p_Html       => l_Html);
            Save_Request_Result (
                p_Rdj_Rn       => Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
                p_Rdj_Result   => l_Html,
                p_Rdj_St       => c_Rdj_St_Done);
        END IF;
    END;

    PROCEDURE Rebuild_Result (p_Ur_Id IN NUMBER)
    IS
        l_Response   CLOB;
        l_Html       CLOB;
    BEGIN
        l_Response := Api$uxp_Request.Get_Request (p_Ur_Id).Ur_Soap_Resp;
        Response2text (p_Ur_Id      => p_Ur_Id,
                       p_Response   => l_Response,
                       p_Html       => l_Html);
        Save_Request_Result (
            p_Rdj_Rn       => Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
            p_Rdj_Result   => l_Html,
            p_Rdj_St       => c_Rdj_St_Done);
    END;
END Api$demo;
/