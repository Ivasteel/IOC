/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$AP2SC
IS
    -- Author  : SHOSTAK
    -- Created : 04.10.2022 6:35:52 PM
    -- Purpose :

    /*PROCEDURE Exec(p_Ap_Id              IN NUMBER,
    p_Create_Sc_Forced   IN BOOLEAN,
    p_Rzo_Search_Started OUT BOOLEAN);*/

    FUNCTION Is_All_App_Has_Sc (p_Ap_Id                  IN     NUMBER,
                                p_Unlinked_Persons          OUT VARCHAR2,
                                p_Unlinked_Persons_Cnt      OUT NUMBER)
        RETURN BOOLEAN;

    PROCEDURE Search_App_Sc (p_App_Id IN NUMBER, p_App_Sc OUT NUMBER);


    PROCEDURE Copy_App_Docs2sc (p_App           IN Ap_Person%ROWTYPE,
                                p_Ipn_Invalid   IN BOOLEAN);

    PROCEDURE Actualize_App_Sc (p_App             IN OUT Ap_Person%ROWTYPE,
                                p_Ap_Reg_Dt       IN     DATE DEFAULT NULL, --ignore
                                p_Is_Actualized      OUT BOOLEAN);

    PROCEDURE App2sc (p_App_Id             IN NUMBER,
                      p_Vf_Id              IN NUMBER,
                      p_Create_Sc_Forced   IN BOOLEAN);

    --=============================================================
    --Копирование документов из ЕСР в соцкарточку ##111897
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_ap appeal.ap_id%TYPE);

    PROCEDURE Update_Benefits_Data (p_Ap_Id    IN     Appeal.Ap_Id%TYPE,
                                    p_Vf_Res      OUT VARCHAR2);

    PROCEDURE Verify_Person_Benefits (p_App_Id   IN Ap_Person.App_Id%TYPE,
                                      p_Vf_id    IN Appeal.Ap_Vf%TYPE);

    --=============================================================
    -- Оновлення даних СРКО для Взятта на облік ветерана NVT_ID=321
    --=============================================================
    PROCEDURE App2sc_Vtrn (p_App_Id IN NUMBER, p_Vf_Id IN NUMBER);
END Api$ap2sc;
/


/* Formatted on 8/12/2025 5:59:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$AP2SC
IS
    TYPE r_Benefit_Data IS RECORD
    (
        Cat_Num        NUMBER (14),
        Cat_Id         NUMBER (14),
        Doc_Ndt        NUMBER (14),
        Doc_Id         NUMBER (14),
        Doc_Doc        NUMBER (14),
        Scd_Id         NUMBER (14),
        Scbd_Id        NUMBER (14),
        Doc_Attrs      uss_person.api$socialcard.t_Doc_Attrs,
        Doc_From_Dt    DATE,
        Doc_Till_Dt    DATE,
        Doc_Num        VARCHAR2 (100),
        Doc_Who        VARCHAR2 (4000),
        Doc_Dis        VARCHAR2 (10),
        Msg            VARCHAR2 (4000)
    );

    TYPE t_Benefit_Data IS TABLE OF r_Benefit_Data;

    ----------------------------------------------------------------------------------
    --        Отримання ІПН учасника звернення
    ----------------------------------------------------------------------------------
    FUNCTION Get_App_Inn (p_App                IN     Ap_Person%ROWTYPE,
                          p_App_Inn_Verified      OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_App_Inn   VARCHAR2 (10);
    BEGIN
        IF NVL (p_App.App_Inn, '0000000000') NOT IN ('0000000000')
        THEN
            l_App_Inn := p_App.App_Inn;

            --Перевіряємо чи верифіковно ІПН, що вказано у реквізитах учасника
            SELECT SIGN (COUNT (*))
              INTO p_App_Inn_Verified
              FROM Verification v
             WHERE     v.Vf_Vf_Main = p_App.App_Vf
                   AND v.Vf_Nvt IN (4, 32, 29)
                   AND v.Vf_St = Api$verification.c_Vf_St_Ok;
        END IF;

        IF l_App_Inn IS NULL OR NVL (p_App_Inn_Verified, 0) <> 1
        THEN
            BEGIN
                --Отримуємо ІПН учасника з документів
                SELECT a.Apda_Val_String,
                       DECODE (v.Vf_St, Api$verification.c_Vf_St_Ok, 1, 0)
                  INTO l_App_Inn, p_App_Inn_Verified
                  FROM Ap_Document  d
                       JOIN Ap_Document_Attr a
                           ON     d.Apd_Id = a.Apda_Apd
                              AND a.Apda_Nda = 1
                              AND a.History_Status = 'A'
                              AND NVL (a.Apda_Val_String, '0000000000') NOT IN
                                      ('0000000000')
                       LEFT JOIN Verification v ON d.Apd_Vf = v.Vf_Id
                 WHERE     d.Apd_App = p_App.App_Id
                       AND d.History_Status = 'A'
                       AND d.Apd_Ndt = 5
                 FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        END IF;

        --Якщо ІПН не верифіковано
        IF NVL (p_App_Inn_Verified, 0) <> 1
        THEN
            l_App_Inn := REPLACE (l_App_Inn, ' ');

            --та номер некоректний
            IF NOT REGEXP_LIKE (l_App_Inn, '^[0-9]{10}$')
            THEN
                --не використовуємо ІПН для створення соцкартки
                l_App_Inn := NULL;
            END IF;
        END IF;

        RETURN l_App_Inn;
    END;

    FUNCTION Get_App_Inn (p_App IN Ap_Person%ROWTYPE)
        RETURN VARCHAR2
    IS
        l_App_Inn_Verified   NUMBER;
    BEGIN
        RETURN Get_App_Inn (p_App                => p_App,
                            p_App_Inn_Verified   => l_App_Inn_Verified);
    END;

    PROCEDURE Get_Apd_Pib (p_Apd_Id    IN     NUMBER,
                           p_Apd_Ndt   IN     NUMBER,
                           p_Ln           OUT VARCHAR2,
                           p_Fn           OUT VARCHAR2,
                           p_Mn           OUT VARCHAR2)
    IS
        l_Is_Pib_In_One_Attr   NUMBER;
        l_Pib                  VARCHAR2 (600);
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Pib_In_One_Attr
          FROM Uss_Ndi.v_Ndi_Document_Attr a
         WHERE a.Nda_Ndt = p_Apd_Ndt AND a.Nda_Class = 'PIB';

        IF l_Is_Pib_In_One_Attr <> 1
        THEN
            p_Ln := Api$appeal.Get_Attr_Val_String (p_Apd_Id, 'LN');
            p_Fn := Api$appeal.Get_Attr_Val_String (p_Apd_Id, 'FN');
            p_Mn := Api$appeal.Get_Attr_Val_String (p_Apd_Id, 'MN');
        ELSE
            l_Pib := Api$appeal.Get_Attr_Val_String (p_Apd_Id, 'PIB');
            Split_Pib (l_Pib,
                       p_Ln,
                       p_Fn,
                       p_Mn);
        END IF;
    END;

    FUNCTION Get_Apd_Birth_Dt (p_Apd_Id IN NUMBER)
        RETURN DATE
    IS
    BEGIN
        RETURN Api$appeal.Get_Attr_Val_Dt (p_Apd_Id, 'BDT');
    END;

    PROCEDURE Get_Apd_Number (p_Apd_Id    IN     NUMBER,
                              p_Apd_Ndt   IN     NUMBER,
                              p_Doc_Ser      OUT VARCHAR2,
                              p_Doc_Num      OUT VARCHAR2)
    IS
    BEGIN
        p_Doc_Num := Api$appeal.Get_Attr_Val_String (p_Apd_Id, 'DSN');

        IF p_Doc_Num IS NOT NULL
        THEN
            Split_Doc_Number (p_Ndt_Id       => p_Apd_Ndt,
                              p_Doc_Number   => p_Doc_Num,
                              p_Doc_Serial   => p_Doc_Ser);
        END IF;
    END;

    FUNCTION Is_Valid_Doc_Number (p_Doc_Ndt IN NUMBER, p_Doc_Num IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        IF    p_Doc_Num IS NULL
           OR --Паспорт
              (    p_Doc_Ndt = 6
               AND NOT REGEXP_LIKE (
                           p_Doc_Num,
                           '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[-]{0,1}[0-9]{6}$'))
           --ІД картка
           OR (p_Doc_Ndt = 7 AND NOT REGEXP_LIKE (p_Doc_Num, '^[0-9]{9}$'))
           --Свідоцтво про народження
           OR (    p_Doc_Ndt = 37
               AND NOT REGEXP_LIKE (
                           SUBSTR (p_Doc_Num, LENGTH (p_Doc_Num) - 5, 6),
                           '^[0-9]{6}$'))
        THEN
            RETURN FALSE;
        END IF;

        RETURN TRUE;
    END;

    PROCEDURE Add_DZR_Data_By_SC (p_app_id IN NUMBER)
    IS
        l_dzr_list           VARCHAR2 (4000);
        l_is_aps_22_exists   NUMBER;
        l_Apd_Id             NUMBER;
        l_Apda_Id            NUMBER;
        l_App                AP_PERSON%ROWTYPE;
        l_Ap                 APPEAL%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE app_id = p_app_id;

        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE ap_id = l_App.App_Ap;

        TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                   'APP2SC',
                   p_app_id,
                   'Test AP_TP = ' || l_AP.Ap_Tp);

        IF l_AP.Ap_Tp = 'DD'
        THEN
            --#113305
            SELECT COUNT (1)
              INTO l_is_aps_22_exists
              FROM ap_service
             WHERE aps_ap = l_App.app_ap AND HISTORY_STATUS = 'A';

            TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                       'APP2SC',
                       p_app_id,
                       'Test APS 22 = ' || l_is_aps_22_exists);

            IF l_is_aps_22_exists > 0
            THEN
                --#113305
                --l_dzr_list := USS_PERSON.API$SC_TOOLS.get_dzr_attr_value_by_sc(l_App.App_Sc);
                l_dzr_list :=
                    USS_ESR.API$FIND.Get_avalilable_dzr_by_sc_list (
                        l_App.App_Sc);
                TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                           'APP2SC',
                           p_app_id,
                           'l_dzr_list = ' || l_dzr_list);

                IF LENGTH (TRIM (l_dzr_list)) > 0
                THEN
                    Api$appeal.Merge_Document (
                        p_Apd_Id                => NULL,
                        p_Apd_Ap                => l_App.App_Ap,
                        p_Apd_Ndt               => Api$appeal.c_Apd_Ndt_rehab_Tool_outcome,
                        p_Apd_Doc               => NULL,
                        p_Apd_Vf                => NULL,
                        p_Apd_App               => l_App.App_Id,
                        p_New_Id                => l_Apd_Id,
                        p_Com_Wu                => NULL,
                        p_Apd_Dh                => NULL,
                        p_Apd_Aps               => NULL,
                        p_Apd_Tmp_To_Del_File   => NULL,
                        p_Apd_Src               => NULL);
                    API$APPEAL.Save_Not_Empty_Document_Attr_Str (
                        p_Apda_Ap           => l_App.App_Ap,
                        p_Apda_Apd          => l_Apd_Id,
                        p_Apda_Nda          => 8720,
                        p_Apda_Val_String   => l_dzr_list,
                        p_New_Id            => l_Apda_Id);
                END IF;
            END IF;
        END IF;
    END;

    ----------------------------------------------------------------------------------
    --        Пошук соцкартки учасника звернення
    ----------------------------------------------------------------------------------
    FUNCTION Search_App_Sc (p_App                   IN OUT Ap_Person%ROWTYPE,
                            p_Ipn_Invalid              OUT BOOLEAN,
                            p_Pib_Mismatch_On_Ipn      OUT BOOLEAN)
        RETURN BOOLEAN
    IS
        l_App_Inn        VARCHAR2 (10);
        l_Doc_Ser        VARCHAR2 (7);
        l_App_Birth_Dt   DATE;
        l_Sc_Unique      Uss_Person.v_Socialcard.Sc_Unique%TYPE;
        l_Ses_ID         NUMBER;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                   'APP2SC',
                   p_App.App_Id,
                   'Start');
        p_Ipn_Invalid := FALSE;
        p_Pib_Mismatch_On_Ipn := FALSE;

        --Визначаємо ІПН учасника
        l_App_Inn := Get_App_Inn (p_App => p_App);

        TOOLS.LOG (
            'API$AP2SC.Search_App_Sc',
            'APP2SC',
            p_App.App_Id,
               'INN='
            || l_App_Inn
            || ', p_App.App_Ndt='
            || p_App.App_Ndt
            || ', p_App.App_Doc_Num='
            || p_App.App_Doc_Num);

        IF    l_App_Inn IS NOT NULL
           OR (p_App.App_Ndt IS NOT NULL AND p_App.App_Doc_Num IS NOT NULL)
        THEN
            IF p_App.App_Ndt IS NOT NULL AND p_App.App_Doc_Num IS NOT NULL
            THEN
                --Розбиваємо номер документа на серію та номер
                Split_Doc_Number (p_Ndt_Id       => p_App.App_Ndt,
                                  p_Doc_Number   => p_App.App_Doc_Num,
                                  p_Doc_Serial   => l_Doc_Ser);
            END IF;

            l_Ses_ID :=
                Uss_Person.Load$socialcard.Get_Load_Sc_Ses (
                    p_Fn         => Clear_Name (p_App.App_Fn),
                    p_Ln         => Clear_Name (p_App.App_Ln),
                    p_Mn         => Clear_Name (p_App.App_Mn),
                    p_Birth_Dt   => NULL,
                    p_Inn_Num    => l_App_Inn,
                    p_Inn_Ndt    => 5,
                    p_Doc_Ser    => l_Doc_Ser,
                    p_Doc_Num    => p_App.App_Doc_Num,
                    p_Doc_Ndt    => p_App.App_Ndt,
                    p_Sc         => p_App.App_Sc);
            TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Before Load_SC. l_Ses_ID=' || l_Ses_ID);
            --Шукаємо соцкартку по реквізитам учасника
            p_App.App_Sc :=
                Uss_Person.Load$socialcard.Load_Sc (
                    p_Fn            => Clear_Name (p_App.App_Fn),
                    p_Ln            => Clear_Name (p_App.App_Ln),
                    p_Mn            => Clear_Name (p_App.App_Mn),
                    p_Gender        => NULL,
                    p_Nationality   => NULL,
                    p_Src_Dt        => NULL,
                    p_Birth_Dt      => NULL,
                    p_Inn_Num       => l_App_Inn,
                    p_Inn_Ndt       => 5,
                    p_Doc_Ser       => l_Doc_Ser,
                    p_Doc_Num       => p_App.App_Doc_Num,
                    p_Doc_Ndt       => p_App.App_Ndt,
                    p_Src           => '35',
                    p_Sc_Unique     => l_Sc_Unique,
                    p_Mode          =>
                        Uss_Person.Load$socialcard.c_Mode_Search,
                    p_Sc            => p_App.App_Sc);

            TOOLS.LOG (
                'API$AP2SC.Search_App_Sc',
                'APP2SC',
                p_App.App_Id,
                   'After Load_SC. p_App.App_Sc='
                || p_App.App_Sc
                || ' ,l_Sc_Unique='
                || l_Sc_Unique);

            IF p_App.App_Sc <= 0
            THEN
                p_App.App_Sc := NULL;
            END IF;

            p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
            p_Pib_Mismatch_On_Ipn :=
                Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;
        END IF;

        TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                   'APP2SC',
                   p_App.App_Id,
                   'After Load_SC. p_App.App_Sc=' || p_App.App_Sc);

        IF NVL (p_App.App_Sc, 0) <= 0
        THEN
            --Якщо соцкартку не було знайдено за реквізитами учасник,
            --шукаємо по документах, що привязані до учасника
            TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Before document loop');

            FOR Doc
                IN (  SELECT d.Apd_Id, d.Apd_Ndt
                        FROM Ap_Document d
                             JOIN Uss_Ndi.v_Ndi_Document_Type t
                                 ON d.Apd_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13 --Для пошуку або актуалізації соцкартки використовуються лише документи з категорії "Верифікація особи"
                       WHERE Apd_App = p_App.App_Id AND d.History_Status = 'A'
                    ORDER BY t.Ndt_Sc_Srch_Priority NULLS LAST)
            LOOP
                DECLARE
                    l_Doc_Num        Ap_Person.App_Doc_Num%TYPE;
                    l_Doc_Ser        VARCHAR2 (7);
                    l_App_Ln         VARCHAR2 (200);
                    l_App_Fn         VARCHAR2 (200);
                    l_App_Mn         VARCHAR2 (200);
                    l_App_Birth_Dt   DATE;
                BEGIN
                    TOOLS.LOG (
                        'API$AP2SC.Search_App_Sc',
                        'APP2SC',
                        p_App.App_Id,
                        'Document loop iteration. Apd_id=' || Doc.Apd_Id);
                    --Отримуємо серію та номер документа
                    Get_Apd_Number (Doc.Apd_Id,
                                    Doc.Apd_Ndt,
                                    l_Doc_Ser,
                                    l_Doc_Num);

                    IF     (Doc.Apd_Ndt IS NULL OR l_Doc_Num IS NULL)
                       AND l_App_Inn IS NULL
                    THEN
                        CONTINUE;
                    END IF;

                    --Отримуємо ПІБ з документа
                    Get_Apd_Pib (Doc.Apd_Id,
                                 Doc.Apd_Ndt,
                                 l_App_Ln,
                                 l_App_Fn,
                                 l_App_Mn);

                    --Якщо ПІБ не знайдено в атрибутах документів
                    IF l_App_Ln IS NULL OR l_App_Fn IS NULL
                    THEN
                        --використовємо для пошуку соцкартки ПІБ учасника
                        l_App_Ln := p_App.App_Ln;
                        l_App_Fn := p_App.App_Fn;
                        l_App_Mn := p_App.App_Mn;
                    END IF;

                    --Отримуємо дату народження з докумнета
                    l_App_Birth_Dt := Get_Apd_Birth_Dt (Doc.Apd_Id);

                    --Виконуємо пошук соцкартки
                    TOOLS.LOG (
                        'API$AP2SC.Try_Create_App_Sc',
                        'APP2SC',
                        p_App.App_Id,
                           'Before Load$socialcard.Load_Sc in Doc loop: Fn='
                        || Clear_Name (l_App_Fn)
                        || ', Ln='
                        || Clear_Name (l_App_Ln)
                        || ', Mn='
                        || Clear_Name (l_App_Mn)
                        || ', l_App_Inn='
                        || l_App_Inn);
                    p_App.App_Sc :=
                        Uss_Person.Load$socialcard.Load_Sc (
                            p_Fn            => Clear_Name (l_App_Fn),
                            p_Ln            => Clear_Name (l_App_Ln),
                            p_Mn            => Clear_Name (l_App_Mn),
                            p_Gender        => NULL,
                            p_Nationality   => NULL,
                            p_Src_Dt        => NULL,
                            p_Birth_Dt      => l_App_Birth_Dt,
                            p_Inn_Num       => l_App_Inn,
                            p_Inn_Ndt       => 5,
                            p_Doc_Ser       => l_Doc_Ser,
                            p_Doc_Num       => l_Doc_Num,
                            p_Doc_Ndt       => Doc.Apd_Ndt,
                            p_Src           => '35',
                            p_Sc_Unique     => l_Sc_Unique,
                            p_Mode          =>
                                Uss_Person.Load$socialcard.c_Mode_Search,
                            p_Sc            => p_App.App_Sc);
                    TOOLS.LOG (
                        'API$AP2SC.Search_App_Sc',
                        'APP2SC',
                        p_App.App_Id,
                           'After Load_SC in Doc loop. p_App.App_Sc='
                        || p_App.App_Sc
                        || ' ,l_Sc_Unique='
                        || l_Sc_Unique);

                    IF p_App.App_Sc <= 0
                    THEN
                        p_App.App_Sc := NULL;
                    END IF;

                    p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
                    p_Pib_Mismatch_On_Ipn :=
                        Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;

                    IF p_App.App_Sc > 0
                    THEN
                        EXIT;
                    END IF;
                END;
            END LOOP;

            TOOLS.LOG ('API$AP2SC.Search_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'After document loop');
        END IF;

        TOOLS.LOG (
            'API$AP2SC.Search_App_Sc',
            'APP2SC',
            p_App.App_Id,
               'Final App_Sc. p_App.App_Sc='
            || p_App.App_Sc
            || ', l_Sc_Unique='
            || l_Sc_Unique);

        IF NVL (p_App.App_Sc, 0) > 0
        THEN
            UPDATE Ap_Person p
               SET p.App_Sc = p_App.App_Sc, p.App_Esr_Num = l_Sc_Unique
             WHERE p.App_Id = p_App.App_Id;

            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    PROCEDURE Search_App_Sc (p_App_Id IN NUMBER, p_App_Sc OUT NUMBER)
    IS
        l_App                   Ap_Person%ROWTYPE;
        l_Ipn_Invalid           BOOLEAN;
        l_Pib_Mismatch_On_Ipn   BOOLEAN;
    BEGIN
        SELECT *
          INTO l_App
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        IF Search_App_Sc (l_App, l_Ipn_Invalid, l_Pib_Mismatch_On_Ipn)
        THEN
            p_App_Sc := l_App.App_Sc;
        END IF;
    END;

    ----------------------------------------------------------------------------------
    --        Пошук учасника звернення в РЗО
    ----------------------------------------------------------------------------------
    PROCEDURE Search_App_Rzo (p_App       IN     Ap_Person%ROWTYPE,
                              p_Vf_Id        OUT Verification.Vf_Id%TYPE,
                              p_Skip_Vf      OUT VARCHAR2)
    IS
        l_Vf_Id              NUMBER;
        l_Vf_St              VARCHAR2 (50);
        l_Ap_Vf_Id           NUMBER;
        c_Nvt_Nrt   CONSTANT NUMBER := 40;
    BEGIN
        p_Vf_ID := NULL;
        --Створюємо верифікацію для відправки запиту на пошук особи в РЗО
        TOOLS.LOG ('API$AP2SC.Search_App_Rzo',
                   'APP2SC',
                   p_App.App_Id,
                   'Start');

        l_Vf_Id :=
            Api$verification.Get_Verification (
                p_Vf_Tp        => 'EZV',
                p_Vf_Nvt       => Api$verification.c_Nvt_Rzo_Search,
                p_Vf_Obj_Tp    => 'P',
                p_Vf_Obj_Id    => p_App.App_Id,
                p_Vf_Vf_Main   => p_App.App_Vf);
        p_Vf_Id := l_Vf_Id;

        TOOLS.LOG ('API$AP2SC.Search_App_Rzo',
                   'APP2SC',
                   p_App.App_Id,
                   'l_Vf_Id=' || l_Vf_Id);

        --Загулшка для встановлення статусу "Успішна верифікація" без відправки запити.
        --(для середовища розробки)
        --SELECT Nvl(MAX(v.Prm_Value), 'F')
        --INTO p_Skip_Vf
        --FROM Paramsvisit v
        --WHERE v.Prm_Code = 'SKIP_VF_' || Api$verification.c_Nvt_Rzo_Search;

        --IF p_Skip_Vf = 'T' THEN
        --Api$verification.Set_Ok(l_Vf_Id);
        --RETURN;
        --END IF;


        Api$verification.Register_Vf_Request (
            p_Vf_Id       => l_Vf_Id,
            p_Vf_Obj_Id   => p_App.App_Id,
            p_Nvt_Id      => Api$verification.c_Nvt_Rzo_Search,
            p_Nvt_Nrt     => c_Nvt_Nrt);


        SELECT vf_st
          INTO l_Vf_St
          FROM Verification
         WHERE vf_id = l_Vf_Id;

        TOOLS.LOG ('API$AP2SC.Search_App_Rzo',
                   'APP2SC',
                   p_App.App_Id,
                   'l_Vf_St=' || l_Vf_St);

        IF l_Vf_St = API$VERIFICATION.c_Vf_St_Not_Verified
        THEN
            p_Vf_Id := NULL;
        END IF;

        SELECT a.Ap_Vf
          INTO l_Ap_Vf_Id
          FROM Appeal a
         WHERE a.Ap_Id = p_App.App_Ap;

        --Повертаємо статус верифікації учасника та статус верифікації звернення у "Зареєстровано"
        UPDATE Verification v
           SET v.Vf_St = 'R'
         WHERE v.Vf_Id IN (l_Ap_Vf_Id, p_App.App_Vf);

        --Повертаємо статус звернення у "Виконується верифікація"
        UPDATE Appeal a
           SET a.Ap_St = 'VW'
         WHERE a.Ap_Id = p_App.App_Ap AND a.Ap_St = 'VO';
    END;

    ----------------------------------------------------------------------------------
    --    Перевірка чи має учасник верифіковану довідку ВПО
    ----------------------------------------------------------------------------------
    FUNCTION Is_Vpo_Cert_Verified (p_App_Id NUMBER)
        RETURN BOOLEAN
    IS
        l_Is_Verified   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Verified
          FROM Ap_Document  d
               JOIN Verification v
                   ON     d.Apd_Vf = v.Vf_Id
                      AND v.Vf_St = Api$verification.c_Vf_St_Ok
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND d.Apd_Ndt = 10052;

        RETURN l_Is_Verified = 1;
    END;

    FUNCTION Get_App_Email (p_App_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Email   VARCHAR2 (100);
    BEGIN
        SELECT TRIM (MAX (a.Apda_Val_String))
          INTO l_Email
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a
                   ON d.Apd_Id = a.Apda_Apd AND a.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'EMAIL'
         WHERE d.Apd_App = p_App_Id AND d.History_Status = 'A';

        RETURN l_Email;
    END;

    ----------------------------------------------------------------------------------
    --    Спроба створення соціальної картки за даними учасника звернення
    ----------------------------------------------------------------------------------
    FUNCTION Try_Create_App_Sc (p_App                   IN OUT Ap_Person%ROWTYPE,
                                p_Ap_Reg_Dt             IN     DATE DEFAULT NULL, --ignore
                                p_Create_Sc_Forced      IN     BOOLEAN,
                                p_Ipn_Invalid              OUT BOOLEAN,
                                p_Pib_Mismatch_On_Ipn      OUT BOOLEAN)
        RETURN BOOLEAN
    IS
        l_App_Inn            VARCHAR2 (10);
        l_App_Inn_Verified   NUMBER;
        l_Doc_Num            Ap_Person.App_Doc_Num%TYPE;
        l_Doc_Ser            VARCHAR2 (7);
        l_App_Ln             VARCHAR2 (200);
        l_App_Fn             VARCHAR2 (200);
        l_App_Mn             VARCHAR2 (200);
        l_App_Birth_Dt       DATE;
        l_Apd_Ndt            NUMBER;
        l_Apd_Verified       NUMBER;
        l_Sc_Unique          Uss_Person.v_Socialcard.Sc_Unique%TYPE;
        l_Email              VARCHAR2 (100);
        l_Is_Iteration       BOOLEAN := FALSE;
        l_Ses_ID             NUMBER;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Try_Create_App_Sc',
                   'APP2SC',
                   p_App.App_Id,
                   'Statr: p_App_id=' || p_App.App_Id);
        p_Ipn_Invalid := FALSE;
        p_Pib_Mismatch_On_Ipn := FALSE;

        --Визначаємо ІПН учасника
        l_App_Inn :=
            Get_App_Inn (p_App                => p_App,
                         p_App_Inn_Verified   => l_App_Inn_Verified);

        FOR Doc
            IN (  SELECT d.Apd_Ndt,
                         d.Apd_Id,
                         DECODE (v.Vf_St, Api$verification.c_Vf_St_Ok, 1, 0)    AS Apd_Verified
                    FROM Ap_Document d
                         JOIN Uss_Ndi.v_Ndi_Document_Type t
                             ON d.Apd_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13 --Для пошуку або створення соцкартки використовуються лише документи з категорії "Верифікація особи"
                         JOIN Verification v
                             ON     d.Apd_Vf = v.Vf_Id
                                --#97476: використовуємо дані лише з верифікованих документів
                                AND v.Vf_St = Api$verification.c_Vf_St_Ok
                   WHERE d.Apd_App = p_App.App_Id AND d.History_Status = 'A'
                ORDER BY t.Ndt_Sc_Upd_Priority NULLS LAST)
        LOOP
            TOOLS.LOG ('API$AP2SC.Try_Create_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Start iteration: Apd_Id=' || Doc.Apd_Id);
            l_Is_Iteration := TRUE;
            l_Apd_Ndt := Doc.Apd_Ndt;
            l_Apd_Verified := Doc.Apd_Verified;

            --Отримуємо серію та номер документа
            Get_Apd_Number (Doc.Apd_Id,
                            l_Apd_Ndt,
                            l_Doc_Ser,
                            l_Doc_Num);

            IF     Doc.Apd_Verified <> 1
               AND (   l_Doc_Num IS NULL
                    OR NOT Is_Valid_Doc_Number (l_Apd_Ndt,
                                                l_Doc_Ser || l_Doc_Num))
            THEN
                l_Apd_Ndt := NULL;
                l_Doc_Ser := NULL;
                l_Doc_Num := NULL;
                CONTINUE;
            END IF;

            --Отримуємо ПІБ з документа
            Get_Apd_Pib (Doc.Apd_Id,
                         l_Apd_Ndt,
                         l_App_Ln,
                         l_App_Fn,
                         l_App_Mn);
            --Отримуємо дату народження з докумнета
            l_App_Birth_Dt := Get_Apd_Birth_Dt (Doc.Apd_Id);

            EXIT;
        END LOOP;

        --Якщо ПІБ не знайдено в атрибутах документів
        IF l_App_Ln IS NULL OR l_App_Fn IS NULL
        THEN
            --використовємо для створення соцкартки ПІБ учасника
            l_App_Ln := p_App.App_Ln;
            l_App_Fn := p_App.App_Fn;
            l_App_Mn := p_App.App_Mn;
        END IF;

        IF l_App_Ln IS NULL OR l_App_Fn IS NULL
        THEN
            l_App_Ln := NULL;
            l_App_Fn := NULL;
            l_App_Mn := NULL;
        END IF;

        --Якщо не вказано ІПН та номер документа(в атрибутах),
        --та вказано ознаку "примусового створення", то
        --беремо номер документа з реквізитів учасника
        IF     l_Doc_Num IS NULL
           AND l_App_Inn IS NULL
           AND p_Create_Sc_Forced
           AND p_App.App_Ndt IS NOT NULL
           AND p_App.App_Doc_Num IS NOT NULL
        THEN
            --Перевіряємо, що у якості документа учасника вказано документ з категорії "Верифікація особи"
            SELECT t.Ndt_Id
              INTO p_App.App_Ndt
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = p_App.App_Ndt AND t.Ndt_Ndc = 13;

            IF p_App.App_Ndt IS NOT NULL
            THEN
                l_Apd_Ndt := p_App.App_Ndt;
                l_Doc_Num := p_App.App_Doc_Num;
                Split_Doc_Number (p_Ndt_Id       => l_Apd_Ndt,
                                  p_Doc_Number   => l_Doc_Num,
                                  p_Doc_Serial   => l_Doc_Ser);
            END IF;
        END IF;

        IF     l_Apd_Verified <> 1
           AND l_Doc_Num IS NOT NULL
           --Перевіряємо валідність серії та номеру документа
           AND NOT Is_Valid_Doc_Number (l_Apd_Ndt, l_Doc_Ser || l_Doc_Num)
        THEN
            --Невалідні серія та номер документа не використовуються для створення соц.картки
            l_Doc_Ser := NULL;
            l_Apd_Ndt := NULL;
            l_Doc_Num := NULL;
        END IF;

        --Створюємо соціальну картку лише за умови,
        -- якщо верифіковано документ учасника, що посвідчує особу або ІПН
        TOOLS.LOG (
            'API$AP2SC.Try_Create_App_Sc',
            'APP2SC',
            p_App.App_Id,
               'Check is all vefify are good: l_App_Inn_Verified='
            || l_App_Inn_Verified
            || ', l_Apd_Verified='
            || l_Apd_Verified);

        IF     (   GREATEST (NVL (l_App_Inn_Verified, 0),
                             NVL (l_Apd_Verified, 0)) =
                   1
                --або вказано ознаку "примусового створення" або учасник має верифіковану довідку ВПО
                --та заповнено ІПН або документ, що посвідчує особу
                OR (    (   p_Create_Sc_Forced
                         OR Is_Vpo_Cert_Verified (p_App.App_Id))
                    AND (   l_App_Inn IS NOT NULL
                         OR (l_Apd_Ndt IS NOT NULL AND l_Doc_Num IS NOT NULL))))
           --та вказано прізвище і ім`я учасника
           AND l_App_Ln IS NOT NULL
           AND l_App_Fn IS NOT NULL
        THEN
            l_Email := Get_App_Email (p_App.App_Id);
            l_Ses_ID :=
                Uss_Person.Load$socialcard.Get_Load_Sc_Ses (
                    p_Fn         => Clear_Name (l_App_Fn),
                    p_Ln         => Clear_Name (l_App_Ln),
                    p_Mn         => Clear_Name (l_App_Mn),
                    p_Birth_Dt   => l_App_Birth_Dt,
                    p_Inn_Num    => l_App_Inn,
                    p_Inn_Ndt    => 5,
                    p_Doc_Ser    => l_Doc_Ser,
                    p_Doc_Num    => l_Doc_Num,
                    p_Doc_Ndt    => l_Apd_Ndt,
                    p_Sc         => p_App.App_Sc);
            TOOLS.LOG (
                'API$AP2SC.Try_Create_App_Sc',
                'APP2SC',
                p_App.App_Id,
                   'Before Load$socialcard.Load_Sc: l_Ses_ID='
                || l_Ses_ID
                || ', Fn='
                || Clear_Name (l_App_Fn)
                || ', Ln='
                || Clear_Name (l_App_Ln)
                || ', Mn='
                || Clear_Name (l_App_Mn)
                || ', l_App_Inn='
                || l_App_Inn);
            p_App.App_Sc :=
                Uss_Person.Load$socialcard.Load_Sc (
                    p_Fn            => Clear_Name (l_App_Fn),
                    p_Ln            => Clear_Name (l_App_Ln),
                    p_Mn            => Clear_Name (l_App_Mn),
                    p_Gender        => p_App.App_Gender,
                    p_Nationality   => NULL,
                    p_Src_Dt        => SYSDATE,
                    --За постановкою КЕВ 24.01.2023, вважаємо дані учасника звернення актуальними на дату верифікаціх звернення, тобто на поточну --Nvl(p_Ap_Reg_Dt, Api$appeal.Get_Ap_Reg_Dt(p_App.App_Ap)),
                    p_Birth_Dt      => l_App_Birth_Dt,
                    p_Inn_Num       => l_App_Inn,
                    p_Inn_Ndt       => 5,
                    p_Doc_Ser       => l_Doc_Ser,
                    p_Doc_Num       => l_Doc_Num,
                    p_Doc_Ndt       => l_Apd_Ndt,
                    p_Src           => '35',
                    p_Sc_Unique     => l_Sc_Unique,
                    p_Mode          =>
                        Uss_Person.Load$socialcard.c_Mode_Search_Update_Create,
                    p_Sc            => p_App.App_Sc,
                    p_Email         => l_Email,
                    p_Is_Email_Inform   =>
                        CASE WHEN l_Email IS NOT NULL THEN 'T' END);

            TOOLS.LOG (
                'API$AP2SC.Try_Create_App_Sc',
                'APP2SC',
                p_App.App_Id,
                   'After Load$socialcard.Load_Sc: p_App.App_Sc='
                || p_App.App_Sc
                || ' ,l_Sc_Unique='
                || l_Sc_Unique);
            p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
            p_Pib_Mismatch_On_Ipn :=
                Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;

            IF NVL (p_App.App_Sc, -1) <= 0
            THEN
                /*Raise_Application_Error(-20000,
                'Помилка визначення соцкартки для учасника ' || p_App.App_Id);*/
                RETURN FALSE;
            END IF;

            UPDATE Ap_Person p
               SET p.App_Sc = p_App.App_Sc, p.App_Esr_Num = l_Sc_Unique
             WHERE p.App_Id = p_App.App_Id;

            p_App.App_Esr_Num := l_Sc_Unique;

            RETURN TRUE;
        END IF;

        IF NOT l_Is_Iteration
        THEN
            TOOLS.LOG ('API$AP2SC.Try_Create_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Not found verified documents to create SC');
        END IF;

        RETURN FALSE;
    END;

    ----------------------------------------------------------------------------------
    --     Копіювання документів учасника звернення до соціальної картки
    ----------------------------------------------------------------------------------
    PROCEDURE Copy_App_Docs2sc (p_App           IN Ap_Person%ROWTYPE,
                                p_Ipn_Invalid   IN BOOLEAN)
    IS
        FUNCTION Can_Copy (p_Ndt_Id IN NUMBER)
            RETURN BOOLEAN
        IS
            l_Can_Copy   VARCHAR2 (10);
        BEGIN
            SELECT NVL (MAX (Prm_Value), 'T')
              INTO l_Can_Copy
              FROM Paramsvisit
             WHERE Prm_Code = 'CAN_COPY_NDT_' || TO_CHAR (p_Ndt_Id);

            RETURN l_Can_Copy = 'T';
        END;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Copy_App_Docs2sc',
                   'APP2SC',
                   p_App.App_Id,
                   'Statr: p_App_Id=' || p_App.App_Id);

        FOR Rec
            IN (SELECT *
                  FROM (SELECT d.Apd_Id,
                               d.Apd_Ndt,
                               t.Ndt_Ndc,
                               DECODE (v.Vf_St,
                                       Api$verification.c_Vf_St_Ok, 1,
                                       0)                                        AS Apd_Verified,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY t.Ndt_Ndc,
                                                    NVL (t.Ndt_Uniq_Group,
                                                         t.Ndt_Id)
                                       ORDER BY
                                           t.Ndt_Sc_Copy_Priority NULLS LAST)    AS Rn
                          FROM Ap_Document  d
                               JOIN Uss_Ndi.v_Ndi_Document_Type t
                                   ON d.Apd_Ndt = t.Ndt_Id
                               LEFT JOIN Verification v ON d.Apd_Vf = v.Vf_Id
                         WHERE     d.Apd_App = p_App.App_Id
                               AND d.History_Status = 'A'
                               AND (   --Копіюємо в соц. картку верифіковані певних категорій
                                       (   (    t.Ndt_Ndc IN (2,
                                                              5,
                                                              11,
                                                              13)
                                            AND v.Vf_St =
                                                Api$verification.c_Vf_St_Ok
                                            --#83196: виключаємо довідку ВПО
                                            --AND t.Ndt_Id <> 10052
                                            --02.05.2023: За усною постановкою Т.Ніконової, виключаємо свідоцтво про смерть
                                            --(томущо, воно приходить лише за обміном ДРАЦС)
                                            AND t.Ndt_Id <> 89)
                                        OR (    --#102411
                                                d.Apd_Ndt IN (5,
                                                              6,
                                                              7,
                                                              8,
                                                              9,
                                                              13)
                                            AND --#101896
                                                EXISTS
                                                    (SELECT 1
                                                       FROM Ap_Service Aps
                                                      WHERE     Aps.Aps_Ap =
                                                                d.apd_ap
                                                            AND Aps.Aps_Nst =
                                                                641
                                                            AND Aps.History_Status =
                                                                'A')))
                                    --або документ "Відмова від РНОКПП"
                                    OR d.Apd_Ndt = 10117))
                 WHERE Rn = 1)
        LOOP
            TOOLS.LOG ('API$AP2SC.Copy_App_Docs2sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Start iteration: Apd_Id=' || Rec.Apd_Id);

            DECLARE
                l_Apd               Ap_Document%ROWTYPE;
                l_Scd               Uss_Person.v_Sc_Document%ROWTYPE;
                l_Doc_Attrs         Uss_Person.Api$socialcard.t_Doc_Attrs;
                c_Sc_Src   CONSTANT VARCHAR2 (10) := '35';
                l_log               VARCHAR2 (4000);
            BEGIN
                IF NOT Can_Copy (Rec.Apd_Ndt)
                THEN
                    CONTINUE;
                END IF;

                --#94509
                IF Rec.Apd_Ndt = 5 AND p_Ipn_Invalid
                THEN
                    CONTINUE;
                END IF;

                IF     Rec.Apd_Verified <> 1
                   AND Rec.Ndt_Ndc = 13
                   AND NOT Is_Valid_Doc_Number (
                               p_Doc_Ndt   => Rec.Apd_Ndt,
                               p_Doc_Num   =>
                                   Api$appeal.Get_Attr_Val_String (
                                       Rec.Apd_Id,
                                       'DSN'))
                THEN
                    CONTINUE;
                END IF;

                --Отримуємо інформацію про документ
                SELECT *
                  INTO l_Apd
                  FROM Ap_Document d
                 WHERE d.Apd_Id = Rec.Apd_Id
                FOR UPDATE;

                --Вичитуємо атрибути документа
                SELECT a.Apda_Nda,
                       TRIM (a.Apda_Val_String),
                       a.Apda_Val_Dt,
                       a.Apda_Val_Int,
                       a.Apda_Val_Id
                  BULK COLLECT INTO l_Doc_Attrs
                  FROM Ap_Document_Attr a
                 WHERE a.Apda_Apd = Rec.Apd_Id AND a.History_Status = 'A';

                SELECT SUBSTR (
                           LISTAGG (
                               DISTINCT
                                      a.Apda_Nda
                                   || '='
                                   || TRIM (a.Apda_Val_String),
                               ', '),
                           1,
                           1000)
                  INTO l_log
                  FROM Ap_Document_Attr a
                 WHERE a.Apda_Apd = Rec.Apd_Id AND a.History_Status = 'A';

                l_Scd.Scd_Doc := l_Apd.Apd_Doc;
                l_Scd.Scd_Dh := l_Apd.Apd_Dh;

                --Зберігаємо документ з атрибутами до соціальної картки та архіву документів
                TOOLS.LOG (
                    'API$AP2SC.Copy_App_Docs2sc',
                    'APP2SC',
                    p_App.App_Id,
                       'Before Api$socialcard.Save_Document: p_Sc_Id='
                    || p_App.App_Sc
                    || ', p_Ndt_Id='
                    || l_Apd.Apd_Ndt
                    || ', l_log='
                    || l_log);
                Uss_Person.Api$socialcard.Save_Document (
                    p_Sc_Id         => p_App.App_Sc,
                    p_Ndt_Id        => l_Apd.Apd_Ndt,
                    p_Doc_Attrs     => l_Doc_Attrs,
                    p_Src_Id        => c_Sc_Src,
                    p_Src_Code      => 'VST',
                    p_Scd_Note      =>
                        'Створено із звернення громадянина з системи ЄІССС: ЄСП',
                    p_Scd_Id        => l_Scd.Scd_Id,
                    p_Doc_Id        => l_Scd.Scd_Doc,
                    p_Dh_Id         => l_Scd.Scd_Dh,
                    p_Set_Feature   => TRUE);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20001,
                           'Помилка копіювання документа(APD_ID='
                        || Rec.Apd_Id
                        || ') до соц. картки: '
                        || SQLERRM);
            END;
        END LOOP;
    END;

    ----------------------------------------------------------------------------------
    --     Актуалізація соціальної картки даними учасника звернення
    --!!!Тимчасовий костиль. Логіку потірбно перенести до USS_PERSON
    --ти виконувати оновлення картки за атрибутами документів,
    --що було додано до соцкартки!!!
    ----------------------------------------------------------------------------------
    PROCEDURE Actualize_App_Sc (p_App             IN OUT Ap_Person%ROWTYPE,
                                p_Ap_Reg_Dt       IN     DATE DEFAULT NULL, --ignore
                                p_Is_Actualized      OUT BOOLEAN)
    IS
        l_App_Ln         VARCHAR2 (200);
        l_App_Fn         VARCHAR2 (200);
        l_App_Mn         VARCHAR2 (200);
        l_App_Birth_Dt   DATE;
        l_Sc_Unique      Uss_Person.v_Socialcard.Sc_Unique%TYPE;
        l_Email          VARCHAR2 (100);
        l_mode           NUMBER
            := Uss_Person.Load$socialcard.c_Mode_Search_Update;
        l_ipn            VARCHAR2 (20);
        l_ipn_ndt        NUMBER;
    BEGIN
        p_Is_Actualized := FALSE;
        TOOLS.LOG ('API$AP2SC.Actualize_App_Sc',
                   'APP2SC',
                   p_App.App_Id,
                   'Start: p_App_id=' || p_App.App_Id);

        FOR Doc
            IN (  SELECT *
                    FROM (SELECT d.Apd_Ndt,
                                 d.Apd_Id,
                                 t.Ndt_Sc_Upd_Priority,
                                 ROW_NUMBER ()
                                     OVER (
                                         PARTITION BY t.Ndt_Ndc,
                                                      NVL (t.Ndt_Uniq_Group,
                                                           t.Ndt_Id)
                                         ORDER BY
                                             t.Ndt_Sc_Copy_Priority NULLS LAST)    AS Rn
                            FROM Ap_Document d
                                 JOIN Uss_Ndi.v_Ndi_Document_Type t
                                     ON d.Apd_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13 --Для актуалізації соцкартки використовуються лише документи з категорії "Верифікація особи"
                           WHERE     d.Apd_App = p_App.App_Id
                                 AND d.History_Status = 'A'
                                 AND (   EXISTS
                                             (SELECT 1
                                                FROM Verification v
                                               WHERE     d.Apd_Vf = v.Vf_Id
                                                     --#97476: використовуємо для актуалізації соцкартки лише верифіковані документи
                                                     AND v.Vf_St =
                                                         Api$verification.c_Vf_St_Ok)
                                      OR --#101896
                                         EXISTS
                                             (SELECT 1
                                                FROM Ap_Service Aps
                                               WHERE     Aps.Aps_Ap = d.apd_ap
                                                     AND Aps.Aps_Nst = 641
                                                     AND Aps.History_Status =
                                                         'A')))
                   WHERE Rn = 1 --Використовуємо для актуалізації соцкартки лише документи що будуть скопійовані до соцкартки
                ORDER BY Ndt_Sc_Upd_Priority NULLS LAST)
        LOOP
            TOOLS.LOG ('API$AP2SC.Actualize_App_Sc',
                       'APP2SC',
                       p_App.App_Id,
                       'Start iteration: Apd_Id=' || Doc.Apd_Id);

            --Не використовуємо атрибути з документа, що має некоректний номер
            IF NOT Is_Valid_Doc_Number (
                       Doc.Apd_Ndt,
                       Api$appeal.Get_Attr_Val_String (Doc.Apd_Id, 'DSN'))
            THEN
                CONTINUE;
            END IF;

            --Отримуємо ПІБ з документа
            IF l_App_Ln IS NULL OR l_App_Fn IS NULL
            THEN
                Get_Apd_Pib (Doc.Apd_Id,
                             Doc.Apd_Ndt,
                             l_App_Ln,
                             l_App_Fn,
                             l_App_Mn);
            END IF;

            --Отримуємо дату народження з докумнета
            l_App_Birth_Dt :=
                NVL (l_App_Birth_Dt, Get_Apd_Birth_Dt (Doc.Apd_Id));

            IF     l_App_Birth_Dt IS NOT NULL
               AND l_App_Ln IS NOT NULL
               AND l_App_Fn IS NOT NULL
            THEN
                EXIT;
            END IF;
        END LOOP;


        --#113333
        BEGIN
            SELECT a.apda_val_string, d.apd_ndt
              INTO l_ipn, l_ipn_ndt
              FROM ap_document  d
                   JOIN ap_document_attr a ON d.apd_id = a.apda_apd
             WHERE     a.apda_nda = 8723
                   AND d.apd_ndt = 10366
                   AND a.history_status = 'A'
                   AND d.history_status = 'A'
                   AND d.apd_app = p_App.App_Id;

            l_mode := Uss_Person.Load$socialcard.c_Mode_Search_Update_Create;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF l_App_Ln IS NULL OR l_App_Fn IS NULL
        THEN
            l_App_Ln := NULL;
            l_App_Fn := NULL;
            l_App_Mn := NULL;
        END IF;

        IF     l_App_Birth_Dt IS NULL
           AND (l_App_Ln IS NULL OR l_App_Fn IS NULL)
           AND l_ipn_ndt IS NULL
        THEN
            RETURN;
        END IF;

        l_Email := Get_App_Email (p_App.App_Id);
        TOOLS.LOG (
            'API$AP2SC.Actualize_App_Sc',
            'APP2SC',
            p_App.App_Id,
               'Before Load$socialcard.Load_Sc: Fn='
            || Clear_Name (l_App_Fn)
            || ', Ln='
            || Clear_Name (l_App_Ln)
            || ', Mn='
            || Clear_Name (l_App_Mn));
        p_App.App_Sc :=
            Uss_Person.Load$socialcard.Load_Sc (
                p_Fn            => Clear_Name (l_App_Fn),
                p_Ln            => Clear_Name (l_App_Ln),
                p_Mn            => Clear_Name (l_App_Mn),
                p_Gender        => p_App.App_Gender,
                p_Nationality   => NULL,
                p_Src_Dt        => SYSDATE,
                --За постановкою КЕВ 24.01.2023, вважаємо дані учасника звернення актуальними на дату верифікаціх звернення, тобто на поточну --Nvl(p_Ap_Reg_Dt, Api$appeal.Get_Ap_Reg_Dt(p_App.App_Ap)),
                p_Birth_Dt      => l_App_Birth_Dt,
                p_Inn_Num       => l_ipn,
                p_Inn_Ndt       => l_ipn_ndt,
                p_Doc_Ser       => NULL,
                p_Doc_Num       => NULL,
                p_Doc_Ndt       => NULL,
                p_Src           => '35',
                p_Sc_Unique     => l_Sc_Unique,
                p_Mode          => l_mode,
                p_Sc            => p_App.App_Sc,
                p_Email         => l_Email,
                p_Is_Email_Inform   =>
                    CASE WHEN l_Email IS NOT NULL THEN 'T' END);
        TOOLS.LOG (
            'API$AP2SC.Actualize_App_Sc',
            'APP2SC',
            p_App.App_Id,
            'After Load$socialcard.Load_Sc: p_App.App_Sc=' || p_App.App_Sc);
        p_Is_Actualized := TRUE;
    END;

    ----------------------------------------------------------------------------------
    --        Перенесення даних звернення до соцкартки
    ----------------------------------------------------------------------------------
    /* PROCEDURE Exec(p_Ap_Id              IN NUMBER,
                   p_Create_Sc_Forced   IN BOOLEAN,
                   p_Rzo_Search_Started OUT BOOLEAN) IS
      l_Rzo_Search_Done NUMBER;
      l_Ap_Reg_Dt       DATE;
    BEGIN
      p_Rzo_Search_Started := FALSE;
      --Пошук соц. карток учасників
      FOR Rec IN (SELECT p.*
                    FROM Ap_Person p
                   WHERE p.App_Ap = p_Ap_Id
                         AND p.History_Status = 'A'
                         AND p.App_Sc IS NULL)
      LOOP
        --Виконуємо пошук соц. картки
        IF Search_App_Sc(Rec) THEN
          CONTINUE;
        END IF;

        --Визначаємо чи було виконано спробу пошуку особи в РЗО
        SELECT Sign(COUNT(*))
          INTO l_Rzo_Search_Done
          FROM Verification v
         WHERE v.Vf_Vf_Main = Rec.App_Vf
               AND v.Vf_Nvt = Api$verification.c_Nvt_Rzo_Search;

        --Якщо не було спроби пошуку особи в РЗО
        IF l_Rzo_Search_Done <> 1 THEN
          --Реєструємо запит на пошук в РЗО
          Search_App_Rzo(Rec);
          p_Rzo_Search_Started := TRUE;
        END IF;
      END LOOP;

      --Припиняємо обробку, томущо запит до РЗО - асинхроний.
      --Повторний виклик цієї процедури відбудеться коли пошук буде завершено для всіх учасників звернення
      IF p_Rzo_Search_Started THEN
        RETURN;
      END IF;

      --Отримуємо дату реєстрації звернення
      SELECT a.Ap_Reg_Dt
        INTO l_Ap_Reg_Dt
        FROM Appeal a
       WHERE a.Ap_Id = p_Ap_Id;

      --Актуалізація соціальних карток учасників
      FOR Rec IN (SELECT p.*
                    FROM Ap_Person p
                   WHERE p.App_Ap = p_Ap_Id
                         AND p.History_Status = 'A'
                         AND p.App_Sc IS NOT NULL)
      LOOP
        --Копіювання документів учасників звернення до соціальної картки
        Copy_App_Docs2sc(Rec);
        --Актуалізація соціальної картки учасника
        Actualize_App_Sc(p_App => Rec, p_Ap_Reg_Dt => l_Ap_Reg_Dt);
      END LOOP;

      --Створення соціальних карточ учасників
      FOR Rec IN (SELECT p.*
                    FROM Ap_Person p
                   WHERE p.App_Ap = p_Ap_Id
                         AND p.History_Status = 'A'
                         AND p.App_Sc IS NULL)
      LOOP
        --Спрода створення соціальної картки учасника
        IF Try_Create_App_Sc(p_App => Rec, p_Ap_Reg_Dt => l_Ap_Reg_Dt, p_Create_Sc_Forced => p_Create_Sc_Forced) THEN
          --Копіювання документів учасників звернення до соціальної картки
          Copy_App_Docs2sc(Rec);
          --Заповнення інформації для відображення в соц. картці
          Uss_Person.Api$socialcard.Init_Sc_Info(p_Sc_Id => Rec.App_Sc);
        END IF;
      END LOOP;
    END;*/

    ----------------------------------------------------------------------------------
    --     Визначення чи всі учасники звернення мають посилання на соц. картку
    ----------------------------------------------------------------------------------
    FUNCTION Is_All_App_Has_Sc (p_Ap_Id                  IN     NUMBER,
                                p_Unlinked_Persons          OUT VARCHAR2,
                                p_Unlinked_Persons_Cnt      OUT NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        SELECT COUNT (*)
          INTO p_Unlinked_Persons_Cnt
          FROM Appeal
         WHERE Ap_id = p_Ap_Id AND Ap_Tp IN ('SS') AND Ap_Ap_Main IS NULL;

        IF p_Unlinked_Persons_Cnt = 1
        THEN
            RETURN TRUE;
        END IF;

        SELECT LISTAGG (Pib (p.App_Ln, p.App_Fn, p.App_Mn), ', ')
                   WITHIN GROUP (ORDER BY p.App_Id),
               COUNT (*)
          INTO p_Unlinked_Persons, p_Unlinked_Persons_Cnt
          FROM Ap_Person p JOIN Appeal ON Ap_Id = p.App_Ap
         WHERE     p.App_Ap = p_Ap_Id
               AND p.History_Status = 'A'
               AND p.App_Sc IS NULL
               AND NOT (Ap_Tp IN ('A') AND App_Tp = 'FA')             --#91645
                                                         ;

        RETURN p_Unlinked_Persons_Cnt = 0;
    END;

    ----------------------------------------------------------------------------------
    --      Пошук/створення/оновлення соціальної картки учасника звернення
    ----------------------------------------------------------------------------------
    PROCEDURE App2sc (p_App_Id             IN NUMBER,
                      p_Vf_Id              IN NUMBER,
                      p_Create_Sc_Forced   IN BOOLEAN)
    IS
        l_App                   Ap_Person%ROWTYPE;
        l_Ap                    Appeal%ROWTYPE;
        l_Vf_id                 Verification.Vf_Id%TYPE;
        l_Rzo_Search_Done       NUMBER;
        l_Ipn_Invalid           BOOLEAN := FALSE;
        l_Pib_Mismatch_On_Ipn   BOOLEAN := FALSE;
        l_Is_Actualized         BOOLEAN := FALSE;
        l_Create_Sc_Forced      BOOLEAN := p_Create_Sc_Forced;
        l_Skip_Vf               VARCHAR2 (10);
        l_Pib_Mismatch          NUMBER;
    BEGIN
        TOOLS.LOG ('API$AP2SC.App2sc',
                   'APP2SC',
                   p_App_Id,
                   'Start: p_App_id=' || p_App_Id || ', p_Vf_id=' || p_Vf_Id);

        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE App_Id = p_App_Id;

        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE Ap_Id = l_App.App_Ap;

        TOOLS.LOG (
            'API$AP2SC.App2sc',
            'APP2SC',
            p_App_Id,
               'After load person data. App_sc='
            || l_App.App_Sc
            || ', App_Esr_Num='
            || l_App.App_Esr_Num);

        IF l_App.App_Sc IS NOT NULL AND l_App.App_Esr_Num IS NULL
        THEN
            l_App.App_Esr_Num :=
                Uss_Person.Load$socialcard.Search_Unique_By_Sc (
                    p_Sc             => l_App.App_Sc,
                    p_Is_Pib_Match   => l_Pib_Mismatch);

            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                   'After get person data by SC. App_sc='
                || l_App.App_Sc
                || ', App_Esr_Num='
                || l_App.App_Esr_Num);

            UPDATE Ap_Person p
               SET p.App_Sc = l_App.App_Sc, p.App_Esr_Num = l_App.App_Esr_Num
             WHERE p.App_Id = l_App.App_Id;
        END IF;


        IF    l_App.App_Sc IS NOT NULL
           OR Search_App_Sc (l_App, l_Ipn_Invalid, l_Pib_Mismatch_On_Ipn)
        THEN
            Add_DZR_Data_By_SC (l_App.App_Id);
            /* 24/01/2025 serhii: changed by #115246
           IF l_Ap.Ap_Src = 'PORTAL' THEN
             -- 26/11/2024 serhii: #103626-56 якщо заявка з Соц. порталу - СКРКО не оновлюємо. Тільки пошук
             -- Api$verification.Write_Vf_Log(p_Vf_Id => p_Vf_Id, p_Vfl_Tp => Api$verification.c_Vfl_Tp_Info, p_Vfl_Message => 'СРКО учасника визначено: ' || l_App.App_Sc);
             Api$verification.Set_Ok(p_Vf_Id);
             TOOLS.log('API$AP2SC.App2sc','APP2SC',p_App_Id,'Set_Ok. Sc_Id found: l_App.App_Sc='||l_App.App_Sc ||', p_Vf_id='||p_Vf_Id);
             RETURN;
           END IF; */
            --Копіювання документів учасників звернення до соціальної картки
            TOOLS.LOG ('API$AP2SC.App2sc',
                       'APP2SC',
                       p_App_Id,
                       'SC Found');
            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                'Before Copy_App_Docs2sc: l_App.App_Sc=' || l_App.App_Sc);
            Copy_App_Docs2sc (l_App, l_Ipn_Invalid);
            --Актуалізація соціальної картки учасника
            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                'Before Actualize_App_Sc: l_App.App_Sc=' || l_App.App_Sc);
            Actualize_App_Sc (p_App             => l_App,
                              p_Is_Actualized   => l_Is_Actualized);
            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                'After Actualize_App_Sc: l_App.App_Sc=' || l_App.App_Sc);

            --#94509
            IF l_Pib_Mismatch_On_Ipn
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '264');
            END IF;

            --#94509
            IF l_Ipn_Invalid
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '265');
            END IF;

            --#101896
            IF NOT l_Is_Actualized
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '289');
            END IF;


            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                   'Before Set_Ok: p_App_id='
                || p_App_Id
                || ', p_Vf_id='
                || p_Vf_Id);
            Api$verification.Set_Ok (p_Vf_Id);
            RETURN;
        --ELSIF l_Ap.ap_tp in ('SS') and l_Ap.ap_sub_tp in ('SL') THEN
        --  TOOLS.log('API$AP2SC.App2sc','APP2SC',p_App_Id,'SC NOT Found. Try to force create');
        --  l_Create_Sc_Forced := TRUE;
        ELSE
            /* 24/01/2025 serhii: changed by #115246
            IF l_Ap.Ap_Src = 'PORTAL' THEN
              -- 26/11/2024 serhii: #103626-56 якщо заявка з Соц. порталу - СКРКО не оновлюємо. Тільки пошук
              Api$verification.Set_Not_Verified(p_Vf_Id => p_Vf_Id, p_Error => Chr(38) || '353'); -- Інформація відсутня в Реєстрі. Зверніться до ПФУ або ЦНАП.
              --Api$appeal.Save_Ap_Correct_Status(p_Ap_Id => l_Ap.Ap_Id, p_Ap_Correct_status => 'F');
              TOOLS.log('API$AP2SC.App2sc','APP2SC',p_App_Id,'Set_Not_Verified: p_App_id='||p_App_Id||', p_Vf_id='||p_Vf_Id);
              RETURN;
            END IF; */
            --Визначаємо чи було виконано спробу пошуку особи в РЗО
            SELECT SIGN (COUNT (*))
              INTO l_Rzo_Search_Done
              FROM Verification v
             WHERE     v.Vf_Vf_Main = l_App.App_Vf
                   AND v.Vf_Nvt = Api$verification.c_Nvt_Rzo_Search;

            --Якщо не було спроби пошуку особи в РЗО
            IF l_Rzo_Search_Done <> 1
            THEN
                --Реєструємо запит на пошук в РЗО
                TOOLS.LOG (
                    'API$AP2SC.App2sc',
                    'APP2SC',
                    p_App_Id,
                       'Before Search_App_Rzo: p_App_id='
                    || p_App_Id
                    || ', p_Vf_id='
                    || p_Vf_Id);
                Search_App_Rzo (l_App, l_Vf_id, l_Skip_Vf);
                TOOLS.LOG ('API$AP2SC.App2sc',
                           'APP2SC',
                           p_App_Id,
                           'After Search_App_Rzo:  l_Skip_Vf=' || l_Skip_Vf);

                IF l_Skip_Vf = 'T'
                THEN
                    l_Create_Sc_Forced := TRUE;
                ELSIF l_Vf_id IS NOT NULL
                THEN
                    TOOLS.LOG (
                        'API$AP2SC.App2sc',
                        'APP2SC',
                        p_App_Id,
                           'Suspend/Continue auto verification:  l_Vf_id='
                        || l_Vf_id);
                    --Призупинення виконання верифікації, до отримання відповіді від РЗО
                    Api$verification.Suspend_Auto_Vf (p_Vf_Id);
                    RETURN;
                END IF;
            END IF;
        END IF;

        TOOLS.LOG ('API$AP2SC.App2sc',
                   'APP2SC',
                   p_App_Id,
                   'SC not Found');

        TOOLS.LOG (
            'API$AP2SC.App2sc',
            'APP2SC',
            p_App_Id,
               'Before Try_Create_App_Sc: p_App_id='
            || p_App_Id
            || ', p_Vf_id='
            || p_Vf_Id);

        --Спрода створення соціальної картки учасника
        IF Try_Create_App_Sc (
               p_App                   => l_App,
               p_Create_Sc_Forced      => l_Create_Sc_Forced,
               p_Ipn_Invalid           => l_Ipn_Invalid,
               p_Pib_Mismatch_On_Ipn   => l_Pib_Mismatch_On_Ipn)
        THEN
            --Копіювання документів учасників звернення до соціальної картки
            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                   'Before Docs2sc: p_App_id='
                || p_App_Id
                || ', p_Vf_id='
                || p_Vf_Id);
            Copy_App_Docs2sc (l_App, l_Ipn_Invalid);
            --Заповнення інформації для відображення в соц. картці
            TOOLS.LOG (
                'API$AP2SC.App2sc',
                'APP2SC',
                p_App_Id,
                   'Before Api$socialcard.Init_Sc_Info: p_App_id='
                || p_App_Id
                || ', p_Vf_id='
                || p_Vf_Id);
            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => l_App.App_Sc);

            --#94509
            IF l_Pib_Mismatch_On_Ipn
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '264');
            END IF;

            --#94509
            IF l_Ipn_Invalid
            THEN
                Api$verification.Write_Vf_Log (
                    p_Vf_Id         => p_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Warning,
                    p_Vfl_Message   => CHR (38) || '265');
            END IF;

            Api$verification.Write_Vf_Log (
                p_Vf_Id         => p_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => CHR (38) || '140#' || l_App.App_Esr_Num);

            Api$verification.Set_Ok (p_Vf_Id);
            RETURN;
        END IF;

        TOOLS.LOG (
            'API$AP2SC.App2sc',
            'APP2SC',
            p_App_Id,
               'Try_Create_App_Sc return false: p_App_id='
            || p_App_Id
            || ', p_Vf_id='
            || p_Vf_Id);

        --НЕУСПІШНА ВЕРИФІКАЦІЯ
        Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_Id,
                                           p_Error   => CHR (38) || '141');
        Api$appeal.Save_Ap_Correct_Status (p_Ap_Id               => l_Ap.Ap_Id,
                                           p_Ap_Correct_status   => 'F');
    EXCEPTION
        WHEN OTHERS
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id    => p_Vf_Id,
                p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            --ТЕХНІЧНА ПОМИЛКА
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => p_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
    END;

    FUNCTION Get_Attr_Str (p_App_id      NUMBER,
                           p_Apd_Id      NUMBER,
                           p_Nda_Class   VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Res   Ap_Document_Attr.apda_val_string%TYPE;
    BEGIN
        SELECT a.apda_val_string
          INTO l_Res
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d ON apda_apd = apd_id
               JOIN uss_ndi.v_Ndi_Document_attr t ON t.nda_id = a.apda_nda
         WHERE     d.apd_id = p_Apd_Id
               AND d.apd_app = p_App_Id
               AND t.nda_class = p_Nda_Class
               AND a.history_status = 'A'
               AND d.history_status = 'A';

        RETURN l_Res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION Get_Attr_Dt (p_App_id      NUMBER,
                          p_Apd_Id      NUMBER,
                          p_Nda_Class   VARCHAR2)
        RETURN DATE
    IS
        l_Res   Ap_Document_Attr.apda_val_dt%TYPE;
    BEGIN
        SELECT a.apda_val_dt
          INTO l_Res
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d ON apda_apd = apd_id
               JOIN uss_ndi.v_Ndi_Document_attr t ON t.nda_id = a.apda_nda
         WHERE     d.apd_id = p_Apd_Id
               AND d.apd_app = p_App_Id
               AND t.nda_class = p_Nda_Class
               AND a.history_status = 'A'
               AND d.history_status = 'A';

        RETURN l_Res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- ознаки за якими визанчається категорія пільги та її документ (зі звернення)
    FUNCTION Get_App_Benefit_Params (p_App_Id Ap_Person.App_Id%TYPE)
        RETURN t_Benefit_Data
    IS
        l_Bnft   t_Benefit_Data;
        --l_Vet_Tp        Ap_Document_Attr.apda_val_string%TYPE;
        l_App    Ap_Person%ROWTYPE;
        l_Str    VARCHAR2 (4000);
    BEGIN
        TOOLS.LOG ('API$AP2SC.Get_App_Benefit_Params',
                   'Ap_Person',
                   p_App_Id,
                   'Start.');

        --l_Bnft.Msg := 'OK';
        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE App_Id = p_App_Id;

        BEGIN
            SELECT a.apda_val_string
              INTO l_Str
              FROM Ap_Document_Attr a JOIN Ap_Document d ON apda_apd = apd_id
             WHERE     d.apd_app = p_App_Id
                   AND a.history_status = 'A'
                   AND apda_nda = 8333 -- Статус пільговика - Категорії через кому: "1,2,11,12,13,90,80,35"
                   AND apd_ndt = 605                                 -- Анкета
                   AND d.history_status = 'A';
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Str := NULL;
        END;

        TOOLS.LOG ('API$AP2SC.Get_App_Benefit_Params',
                   'Ap_Person',
                   p_App_Id,
                   'l_Str=' || l_Str);

        IF l_Str IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Не вдалося визначити "Статус пільговика" в анкеті учасника!');
        END IF;

        DECLARE
            l_pos       PLS_INTEGER;
            l_Cat_Num   VARCHAR2 (10);
        BEGIN
            l_Bnft := t_Benefit_Data ();

            LOOP
                l_pos := INSTR (l_Str, ',');

                IF l_pos > 0
                THEN
                    l_Cat_Num := SUBSTR (l_Str, 1, l_pos - 1);
                    l_Str := SUBSTR (l_Str, l_pos + 1);
                ELSE
                    l_Cat_Num := l_Str;
                    l_Str := NULL;
                END IF;

                l_Bnft.EXTEND;
                l_Bnft (l_Bnft.COUNT).Cat_Num := TO_NUMBER (l_Cat_Num);
                l_Bnft (l_Bnft.COUNT).Msg := 'OK';
                TOOLS.LOG ('API$AP2SC.Get_App_Benefit_Params',
                           'Ap_Person',
                           p_App_Id,
                           'l_Cat_Num=' || l_Cat_Num);
                EXIT WHEN l_Str IS NULL;
            END LOOP;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_application_error (
                    -20000,
                    'Не вдалося визначити окремі категорії у полі "Статус пільговика" в анкеті учасника!');
        END;

        FOR i IN 1 .. l_Bnft.COUNT
        LOOP
            -- l_Bnft(i).Cat_Num
            BEGIN
                SELECT s.nbts_ndt
                  INTO l_Bnft (i).Doc_Ndt
                  FROM uss_ndi.v_ndi_nbc_ndt_setup s
                 WHERE     s.nbts_nbc = l_Bnft (i).Cat_Num
                       AND s.nbts_is_def = 'T'; -- 12/02/2025 serhii: added by #116065-9
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
                        -20000,
                           'Не вдалося визначити тип документа, що підтверджує право на пільгу для категорії №'
                        || TO_CHAR (l_Bnft (i).Cat_Num)
                        || '. Перевірте налаштуваня системи за довідником "Категорії та Документи, що надають право на пільги"');
            END;

            TOOLS.LOG ('API$AP2SC.Get_App_Benefit_Params',
                       'Ap_Person',
                       p_App_Id,
                       'Doc_Ndt=' || l_Bnft (i).Doc_Ndt);

            BEGIN
                SELECT d.apd_id, d.apd_doc
                  INTO l_Bnft (i).Doc_Id, l_Bnft (i).Doc_Doc
                  FROM Ap_Document d
                 WHERE     d.Apd_App = l_App.App_Id
                       AND d.apd_ndt = l_Bnft (i).Doc_Ndt
                       AND d.History_Status = 'A';
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_Bnft (i).Doc_Id := NULL;
            END;

            TOOLS.LOG (
                'API$AP2SC.Get_App_Benefit_Params',
                'Ap_Person',
                p_App_Id,
                   'Doc_Id='
                || l_Bnft (i).Doc_Id
                || ', Doc_Doc='
                || l_Bnft (i).Doc_Doc);

            IF l_Bnft (i).Doc_Id IS NULL
            THEN
                Raise_application_error (
                    -20000,
                       'Не вдалося визначити документ учасника звернення, що надає право на пільгу '
                    || TO_CHAR (l_Bnft (i).Cat_Num));
            --l_Bnft.Msg := Chr(38) || '361'; --
            --RETURN l_Bnft;
            END IF;

            -- Атрибути документа пільговика зі звернення:
            l_Bnft (i).Doc_From_Dt :=
                Get_Attr_Dt (l_App.App_Id, l_Bnft (i).Doc_Id, 'DGVDT'); -- дата видачі nda_pt=79,80
            l_Bnft (i).Doc_Till_Dt :=
                Get_Attr_Dt (l_App.App_Id, l_Bnft (i).Doc_Id, 'DSPDT'); -- Дата закінчення дії
            l_Bnft (i).Doc_Num :=
                Get_Attr_Str (l_App.App_Id, l_Bnft (i).Doc_Id, 'DSN'); -- серія та номер документа nda_pt=123
            l_Bnft (i).Doc_Who :=
                Get_Attr_Str (l_App.App_Id, l_Bnft (i).Doc_Id, 'DORG'); -- ким видано nda_pt=101,102
            l_Bnft (i).Doc_Dis :=
                Get_Attr_Str (l_App.App_Id, l_Bnft (i).Doc_Id, 'INVGR'); -- група інвалідності nda_pt=76
            TOOLS.LOG (
                'API$AP2SC.Get_App_Benefit_Params',
                'Ap_Person',
                p_App_Id,
                   'Benefit document attributes: Doc_From_Dt='
                || TO_CHAR (l_Bnft (i).Doc_From_Dt, 'DD.MM.YYYY')
                || ', Doc_Till_Dt='
                || TO_CHAR (l_Bnft (i).Doc_Till_Dt, 'DD.MM.YYYY')
                || ', Doc_Num='
                || l_Bnft (i).Doc_Num
                || ', Doc_Dis='
                || l_Bnft (i).Doc_Dis);

            BEGIN
                SELECT ct.scbc_id
                  INTO l_Bnft (i).Cat_Id
                  FROM uss_person.v_sc_benefit_category ct
                 WHERE     ct.scbc_sc = l_App.App_Sc -- заповнюється ще в App2sc через Search_App_Sc - (для Соцпортал) або Try_Create_App_Sc - (для ЄІССС)
                       --Чи співпадає категорія визначаємо як за її типом, так і за періодом ді
                       AND ct.scbc_nbc = l_Bnft (i).Cat_Num
                       AND ct.scbc_start_dt = l_Bnft (i).Doc_From_Dt -- AND ct.scbc_stop_dt = l_Bnft(i).Doc_Till_Dt
                       AND ct.scbc_st = 'A';
            EXCEPTION
                WHEN OTHERS
                THEN
                    TOOLS.LOG (
                        'API$AP2SC.Get_App_Benefit_Params',
                        'Ap_Person',
                        p_App_Id,
                           'Benefit category is not defined by params: App_Sc='
                        || l_App.App_Sc
                        || ', Cat_Num='
                        || l_Bnft (i).Cat_Num);
            END;
        END LOOP;

        RETURN l_Bnft;
    END;

    -- #103626 serhii: шукає в СРКО учасника вже наявну категорію пільги та документ що її підтверджує
    -- викликається тільки для учасників - пільговиків, звернення з порталу
    PROCEDURE Search_Person_Benefits (
        p_App_Id   IN     Ap_Person.App_Id%TYPE,
        p_Bnft        OUT t_Benefit_Data)
    IS
        l_App   Ap_Person%ROWTYPE;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Search_Person_Benefits',
                   'Ap_Person',
                   p_App_Id,
                   'Start.');

        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE App_Id = p_App_Id;

        p_Bnft := Get_App_Benefit_Params (p_App_Id);

        FOR i IN 1 .. p_Bnft.COUNT
        LOOP
            -- пошук робимо в категоріях та документах категорій
            SELECT MAX (d.scd_id)
              INTO p_Bnft (i).Scd_Id
              FROM uss_person.v_sc_benefit_docs  b
                   JOIN uss_person.v_sc_document d ON scd_id = scbd_scd
             WHERE     scbd_scbc = p_Bnft (i).Cat_Id
                   AND d.scd_ndt = p_Bnft (i).Doc_Ndt
                   AND d.scd_number = UPPER (p_Bnft (i).Doc_Num);

            IF p_Bnft (i).Scd_Id IS NULL
            THEN
                TOOLS.LOG (
                    'API$AP2SC.Search_Person_Benefits',
                    'Ap_Person',
                    p_App_Id,
                       'Benefit document is not defined by params: Cat_Id='
                    || p_Bnft (i).Cat_Id
                    || ', Doc_Ndt='
                    || p_Bnft (i).Doc_Ndt
                    || ', Doc_Num='
                    || p_Bnft (i).Doc_Num);
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------------
    --  Верифікація даних про пільгову категорію учасника #103626
    --  виклик з nvt_id=261 за умов:
    --  Api$appeal.Get_Ap_Tp(:ap) = 'REG' AND aps_exists(:ap, 1141)
    --  AND Api$appeal.Get_Ap_Src(:ap) = 'PORTAL' AND Api$verification_Cond.Is_Veteran(:app)
    ----------------------------------------------------------------------------------
    PROCEDURE Verify_Person_Benefits (p_App_Id   IN Ap_Person.App_Id%TYPE,
                                      p_Vf_id    IN Appeal.Ap_Vf%TYPE)
    IS
        l_App    Ap_Person%ROWTYPE;
        l_Bnft   t_Benefit_Data;
        l_Msg    Vf_Log.Vfl_Message%TYPE;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Verify_Person_Benefits',
                   'Ap_Person',
                   p_App_Id,
                   'Start, p_Vf_id=' || p_Vf_Id);

        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE App_Id = p_App_Id;

        Search_Person_Benefits (p_App_Id => p_App_Id, p_Bnft => l_Bnft);

        /*   IF l_Bnft.Msg != 'OK' THEN
             Api$verification.Set_Not_Verified(p_Vf_Id => p_Vf_id, p_Error => l_Bnft.Msg);
           END IF;
       */

        --TOOLS.log('API$AP2SC.Verify_Person_Benefits','Ap_Person',p_App_Id,'l_App.App_Sc = '||l_App.App_Sc||', l_Bnft.Cat_Id = '|| l_Bnft.Cat_Id||', l_Bnft.Scd_Id = '|| l_Bnft.Scd_Id);
        --"ПОСТАНОВКА НА ВЕРИФІКАЦІ В РЕЄСТРІ.docx" (для Соц.порталу)
        --Умови верифікації в Реєстрі пільговиків:
        IF l_App.App_Sc IS NULL
        THEN
            --4. Картку СРКО по заявнику НЕ ЗНАЙШЛИ = НЕУСПІШНА ВЕРИФІКАЦІЯ
            --(нічого нікуди не добавляємо = відмова= Зверніться до ПФУ або ЦНАП)
            l_Msg := CHR (38) || '353'; --Інформація відсутня в Реєстрі. Зверніться до ПФУ або ЦНАП.
            Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_id,
                                               p_Error   => l_Msg);
        ELSE
            FOR i IN 1 .. l_Bnft.COUNT
            LOOP
                TOOLS.LOG (
                    'API$AP2SC.Verify_Person_Benefits',
                    'Ap_Person',
                    p_App_Id,
                       'l_App.App_Sc = '
                    || l_App.App_Sc
                    || ', Cat_Id = '
                    || l_Bnft (i).Cat_Id
                    || ', Scd_Id = '
                    || l_Bnft (i).Scd_Id);

                IF     l_Bnft (i).Cat_Id IS NOT NULL
                   AND l_Bnft (i).Scd_Id IS NULL
                THEN
                    --3. Знайшли картку СРКО заявника = звірили документи і статус=Документи = не співпали, статус =  співпав =
                    --Результат верифікації – НЕУСПІШНА ВЕРИФІКАЦІЯ (нічого нікуди не добавляємо = відмова)
                    l_Msg := CHR (38) || '354'; --В Реєстрі не знайдено документа з такими атрибутами
                    Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_id,
                                                       p_Error   => l_Msg);
                    EXIT;
                ELSIF l_Bnft (i).Cat_Id IS NULL
                THEN
                    --2. Знайшли картку СРКО заявника = звірили документи і статус=Документи = не співпали, статус = не співпав =
                    -- Результат верифікації – НЕУСПІШНА ВЕРИФІКАЦІЯ (нічого нікуди не добавляємо = відмова)
                    l_Msg := CHR (38) || '355'; -- не знайдено даних в реєстрі за даною категорією
                    Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_id,
                                                       p_Error   => l_Msg);
                    EXIT;
                ELSIF     l_Bnft (i).Cat_Id IS NOT NULL
                      AND l_Bnft (i).Scd_Id IS NOT NULL
                THEN
                    --1 . Знайшли картку СРКО заявника = звірили документи і статус=Документи = співпали, статус = співпав =
                    --Результат верифікації – ВЕРИФІКАЦІЯ УСПІШНА (нічого нікуди не добавляємо)
                    l_Msg := 'OK'; -- 'Дані по учаснику в реєстрі пільговиків успішно верифіковано.'
                END IF;
            END LOOP;
        END IF;

        IF l_Msg = 'OK'
        THEN
            l_Msg := CHR (38) || '356'; -- 'Дані по учаснику в реєстрі пільговиків успішно верифіковано.'
            Api$verification.Write_Vf_Log (p_Vf_id,
                                           Api$verification.c_Vfl_Tp_Info,
                                           l_Msg);
            Api$verification.Set_Ok (p_Vf_id);
        ELSE
            Raise_application_error (
                -20000,
                'Не вдалося верифікувати дані пільговика.');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id    => p_Vf_Id,
                p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            --ТЕХНІЧНА ПОМИЛКА
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => p_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
    END;

    --=============================================================
    --Копирование документов из ЕСР в соцкарточку ##111897
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_ap appeal.ap_id%TYPE)
    IS
        l_Doc_Attrs   Uss_Person.Api$socialcard.t_Doc_Attrs;
        l_Scd_Id      NUMBER;
        l_new_Id      NUMBER;
        l_Rg_L1       VARCHAR2 (500);
        l_Rg_L2       VARCHAR2 (500);
        l_Rg_Nm       VARCHAR2 (500);
        l_Lv_L1       VARCHAR2 (500);
        l_Lv_L2       VARCHAR2 (500);
        l_Lv_Nm       VARCHAR2 (500);

        ------------------------------
        CURSOR adr IS
            SELECT App.App_Ap,
                   App.App_Id,
                   App.App_Sc,
                   App.App_Tp,
                   Apd.apd_id
                       AS apd_id,
                   --Apd_alt.apd_id AS alt_apd_id,
                   --1 Адреса реєстрації
                   api$appeal.Get_Attr_val_Id (apd.Apd_Id, 8388)
                       AS r_katottg, -- КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8390)
                       AS r_apartment,    -- Квартира адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8391)
                       AS r_corps,          -- Корпус адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8392)
                       AS r_House,         -- Будинок адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8393)
                       AS r_Strit_id, -- Вулиця адреси реєстрації (довідник) ID V_NDI_STRGet_Attr_Val_Id
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8394)
                       AS r_city,            -- Місто адреси реєстрації STRING
                   api$appeal.get_attr_val_id (apd.Apd_Id, 8395)
                       AS r_Index,   -- Індекс адреси реєстрації ID v_mf_index
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8396)
                       AS r_District,        -- Район адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8397)
                       AS r_region,        -- Область адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8398)
                       AS r_country,        -- Країна адреси реєстрації STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8410)
                       AS r_Strit, -- Вулиця адреси реєстрації STRING V_NDI_STRGet_Attr_Val_Id
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8412)
                       AS r_Strit_tp,          -- Тип вулиці адреси реєстрації
                   --2 Адреса проживання
                   api$appeal.get_attr_val_id (apd.Apd_Id, 8409)
                       AS l_katottg, -- КАТОТТГ адреси проживання ID V_MF_KOATUU_TEST
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8400)
                       AS l_apartment,    -- Квартира адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8401)
                       AS l_corps,          -- Корпус адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8402)
                       AS l_House,         -- Будинок адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8403)
                       AS l_Strit_id, -- Вулиця адреси проживання (довідник) ID V_NDI_STRGet_Attr_Val_Id
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8404)
                       AS l_city,            -- Місто адреси проживання STRING
                   api$appeal.get_attr_val_id (apd.Apd_Id, 8405)
                       AS l_Index,   -- Індекс адреси проживання ID v_mf_index
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8406)
                       AS l_District,        -- Район адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8407)
                       AS l_region,        -- Область адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8408)
                       AS l_country,        -- Країна адреси проживання STRING
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8411)
                       AS l_Strit, -- Вулиця адреси проживання STRING V_NDI_STRGet_Attr_Val_Id
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 2304)
                       AS l_Strit_tp,          -- Тип вулиці адреси проживання
                   --3 Додаткові параметри
                   api$appeal.get_attr_Val_String (apd.Apd_Id, 8520)
                       AS Is_equality -- Ознака співпадіння адреси реєстрації та проживання STRING
              /*
                --4 Адреса реєстрації алтернативна
                api$appeal.get_attr_Val_id    (Apd_alt.Apd_Id, 3477) AS alt_katottg,-- КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                api$appeal.get_attr_Val_String(Apd_alt.Apd_Id, 3485) AS alt_apartment,-- Квартира адреси реєстрації STRING
                api$appeal.get_attr_Val_String(Apd_alt.Apd_Id, 3484) AS alt_corps,-- Корпус адреси реєстрації STRING
                api$appeal.get_attr_Val_String(Apd_alt.Apd_Id, 3483) AS alt_House,-- Будинок адреси реєстрації STRING
                api$appeal.get_attr_Val_String(Apd_alt.Apd_Id, 3480) AS alt_Strit_id,-- Вулиця адреси реєстрації (довідник) ID V_NDI_STRGet_Attr_Val_Id
                api$appeal.get_attr_Val_id    (Apd_alt.Apd_Id, 3478) AS alt_Index,-- Індекс адреси реєстрації ID v_mf_index
                api$appeal.get_attr_Val_String(Apd_alt.Apd_Id, 3481) AS alt_Strit,-- Вулиця адреси реєстрації STRING V_NDI_STR Get_Attr_Val_Id
                api$appeal.Get_Attr_Val_String(Apd_alt.Apd_Id, 3479) AS alt_Strit_tp-- Вулиця адреси реєстрації STRING V_NDI_STR Get_Attr_Val_Id
              */
              FROM Ap_Person  App
                   LEFT JOIN Ap_Document Apd
                       ON     Apd.Apd_Ap = App.App_Ap
                          AND Apd.Apd_Ndt = 10305
                          AND Apd.History_Status = 'A'
             --LEFT JOIN Ap_Document Apd_alt ON Apd_alt.Apd_App = App.App_Id  AND Apd_alt.Apd_Ndt = 10305 AND Apd_alt.History_Status = 'A'
             WHERE     App.App_Ap = p_Ap
                   AND App.App_Tp IN ('Z', 'FM')
                   AND App.History_Status = 'A'
                   AND App_Sc IS NOT NULL;

        ------------------------------
        CURSOR document IS
            SELECT *
              FROM (SELECT d.Apd_Id,
                           d.Apd_Doc,
                           d.Apd_Dh,
                           d.Apd_Ndt,
                           p.App_Sc,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY d.Apd_App,
                                                t.Ndt_Ndc,
                                                NVL (t.Ndt_Uniq_Group,
                                                     t.Ndt_Id)
                                   ORDER BY t.Ndt_Order)    AS Rn
                      FROM Ap_Document  d
                           JOIN Ap_Person p
                               ON     d.Apd_App = p.App_Id
                                  AND p.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Type t
                               ON     d.Apd_Ndt = t.Ndt_Id
                                  AND t.Ndt_Copy_Esr_Signed = 'T'
                     WHERE     d.Apd_Ap = p_Ap
                           AND EXISTS
                                   (SELECT 1
                                      FROM Ap_Document_Attr  apda
                                           JOIN
                                           Uss_Ndi.v_ndi_document_attr nda
                                               ON     nda.nda_id =
                                                      apda.apda_nda
                                                  AND nda.nda_class IN
                                                          ('DSN')
                                     WHERE     apda.apda_apd = d.apd_id
                                           AND apda.apda_val_string
                                                   IS NOT NULL
                                           AND apda.history_status = 'A')
                           AND d.History_Status = 'A')
             WHERE Rn = 1;
    ------------------------------
    BEGIN
        --#84282 2023.02.21
        FOR rec IN adr
        LOOP
            -- 17/01/2025 serhii #113838:
            BEGIN
                SELECT l1_name, l2_name, kaot_name
                  INTO l_Rg_L1, l_Rg_L2, l_Rg_Nm
                  FROM (SELECT                                          --m.*,
                               (CASE
                                    WHEN kaot_kaot_l1 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l1
                                                AND kaot_tp = dic_value)
                                END)                              AS l1_name,
                               (CASE
                                    WHEN kaot_kaot_l2 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l2
                                                AND kaot_tp = dic_value)
                                END)                              AS l2_name,
                               (CASE
                                    WHEN kaot_kaot_l3 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l3
                                                AND kaot_tp = dic_value)
                                END)                              AS l3_name,
                               (CASE
                                    WHEN kaot_kaot_l4 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l4
                                                AND kaot_tp = dic_value)
                                END)                              AS l4_name,
                               (CASE
                                    WHEN kaot_kaot_l5 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l5
                                                AND kaot_tp = dic_value)
                                END)                              AS l5_name,
                               t.dic_sname || ' ' || kaot_name    AS kaot_name
                          FROM uss_ndi.v_ndi_katottg  m
                               JOIN uss_ndi.v_ddn_kaot_tp t
                                   ON t.dic_code = m.kaot_tp
                         WHERE m.kaot_id = rec.r_katottg);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            l_Rg_L1 := NVL (rec.r_region, l_Rg_L1);
            l_Rg_L2 := NVL (rec.r_district, l_Rg_L2);
            l_Rg_Nm := NVL (rec.r_city, l_Rg_Nm);

            BEGIN
                SELECT l1_name, l2_name, kaot_name
                  INTO l_Lv_L1, l_Lv_L2, l_Lv_Nm
                  FROM (SELECT                                          --m.*,
                               (CASE
                                    WHEN kaot_kaot_l1 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l1
                                                AND kaot_tp = dic_value)
                                END)                              AS l1_name,
                               (CASE
                                    WHEN kaot_kaot_l2 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l2
                                                AND kaot_tp = dic_value)
                                END)                              AS l2_name,
                               (CASE
                                    WHEN kaot_kaot_l3 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l3
                                                AND kaot_tp = dic_value)
                                END)                              AS l3_name,
                               (CASE
                                    WHEN kaot_kaot_l4 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l4
                                                AND kaot_tp = dic_value)
                                END)                              AS l4_name,
                               (CASE
                                    WHEN kaot_kaot_l5 = kaot_id
                                    THEN
                                        NULL
                                    ELSE
                                        (SELECT    dic_sname
                                                || ' '
                                                || x1.kaot_name
                                           FROM uss_ndi.v_ndi_katottg  x1,
                                                uss_ndi.v_ddn_kaot_tp
                                          WHERE     x1.kaot_id =
                                                    m.kaot_kaot_l5
                                                AND kaot_tp = dic_value)
                                END)                              AS l5_name,
                               t.dic_sname || ' ' || kaot_name    AS kaot_name
                          FROM uss_ndi.v_ndi_katottg  m
                               JOIN uss_ndi.v_ddn_kaot_tp t
                                   ON t.dic_code = m.kaot_tp
                         WHERE m.kaot_id = rec.l_katottg);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            l_Lv_L1 := NVL (rec.r_region, l_Lv_L1);
            l_Lv_L2 := NVL (rec.r_district, l_Lv_L2);
            l_Lv_Nm := NVL (rec.r_city, l_Lv_Nm);

            -- #113838

            --3 2011  3 3 Місце реєстрації  Місце реєстрації  A 3
            --4 2011  2 2 Місце проживання  Місце проживання  A 2
            --106 1 UA Україна Україна A
            IF rec.apd_id IS NOT NULL
            THEN
                Uss_Person.Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => rec.app_sc,
                    p_Sca_Tp          => 3,
                    p_Sca_Kaot        => rec.r_katottg,
                    p_Sca_Nc          => 1,
                    p_Sca_Country     => NVL (rec.r_country, 'Україна'),
                    p_Sca_Region      => l_Rg_L1,
                    p_Sca_District    => l_Rg_L2,
                    p_Sca_Postcode    => rec.r_index,
                    p_Sca_City        => l_Rg_Nm,
                    p_Sca_Street      => NVL (rec.r_strit_id, rec.r_strit),
                    p_Sca_Building    => rec.r_house,
                    p_Sca_Block       => rec.r_corps,
                    p_Sca_Apartment   => rec.r_apartment,
                    p_Sca_Note        => '',
                    p_Sca_Src         => '35',
                    p_Sca_Create_Dt   => SYSDATE,
                    o_Sca_Id          => l_new_Id);

                IF rec.is_equality = 'T'
                THEN
                    Uss_Person.Api$socialcard.Save_Sc_Address (
                        p_Sca_Sc          => rec.app_sc,
                        p_Sca_Tp          => 2,
                        p_Sca_Kaot        => rec.r_katottg,
                        p_Sca_Nc          => 1,
                        p_Sca_Country     => NVL (rec.r_country, 'Україна'),
                        p_Sca_Region      => l_Rg_L1,
                        p_Sca_District    => l_Rg_L2,
                        p_Sca_Postcode    => rec.r_index,
                        p_Sca_City        => l_Rg_Nm,
                        p_Sca_Street      => NVL (rec.r_strit_id, rec.r_strit),
                        p_Sca_Building    => rec.r_house,
                        p_Sca_Block       => rec.r_corps,
                        p_Sca_Apartment   => rec.r_apartment,
                        p_Sca_Note        => '',
                        p_Sca_Src         => '35',
                        p_Sca_Create_Dt   => SYSDATE,
                        o_Sca_Id          => l_new_Id);
                ELSE
                    Uss_Person.Api$socialcard.Save_Sc_Address (
                        p_Sca_Sc          => rec.app_sc,
                        p_Sca_Tp          => 2,
                        p_Sca_Kaot        => rec.l_katottg,
                        p_Sca_Nc          => 1,
                        p_Sca_Country     => NVL (rec.l_country, 'Україна'),
                        p_Sca_Region      => l_Lv_L1,
                        p_Sca_District    => l_Lv_L2,
                        p_Sca_Postcode    => rec.l_index,
                        p_Sca_City        => l_Lv_Nm,
                        p_Sca_Street      => NVL (rec.l_strit_id, rec.l_strit),
                        p_Sca_Building    => rec.l_house,
                        p_Sca_Block       => rec.l_corps,
                        p_Sca_Apartment   => rec.l_apartment,
                        p_Sca_Note        => '',
                        p_Sca_Src         => '35',
                        p_Sca_Create_Dt   => SYSDATE,
                        o_Sca_Id          => l_new_Id);
                END IF;
            /* ELSIF rec.alt_apd_id IS NOT NULL THEN
                Uss_Person.Api$socialcard.Save_Sc_Address(p_Sca_Sc         => rec.app_sc,
                                                          p_Sca_Tp         => 3,
                                                          p_Sca_Kaot       => rec.alt_katottg,
                                                          p_Sca_Nc         => 1,
                                                          p_Sca_Country    => 'Україна',
                                                          p_Sca_Region     => NULL,--rec.alt_region,
                                                          p_Sca_District   => NULL,--rec.alt_district,
                                                          p_Sca_Postcode   => rec.alt_index,
                                                          p_Sca_City       => NULL,--rec.alt_city,
                                                          p_Sca_Street     => nvl(rec.alt_strit_id, rec.alt_strit),
                                                          p_Sca_Building   => rec.alt_house,
                                                          p_Sca_Block      => rec.alt_corps,
                                                          p_Sca_Apartment  => rec.alt_apartment,
                                                          p_Sca_Note       => '',
                                                          p_Sca_Src        => '35',
                                                          p_Sca_Create_Dt  => SYSDATE,
                                                          o_Sca_Id         => l_new_Id);
              */
            END IF;
        END LOOP;

        FOR Rec IN document
        LOOP
            SELECT a.Apda_Nda,
                   a.Apda_Val_String,
                   a.Apda_Val_Dt,
                   a.Apda_Val_Int,
                   a.Apda_Val_Id
              BULK COLLECT INTO l_Doc_Attrs
              FROM Ap_Document_Attr a
             WHERE a.Apda_Apd = rec.apd_id AND a.History_Status = 'A';

            Uss_Person.Api$socialcard.Save_Document (
                p_Sc_Id         => Rec.App_Sc,
                p_Ndt_Id        => Rec.Apd_Ndt,
                p_Doc_Attrs     => l_Doc_Attrs,
                p_Src_Id        => '35',
                p_Src_Code      => 'ESR',
                p_Scd_Note      =>
                    'Створено із звернення громадянина з системи ЄІССС: ЄСР',
                p_Scd_Id        => l_Scd_Id,
                p_Doc_Id        => Rec.Apd_Doc,
                p_Dh_Id         => Rec.Apd_Dh,
                p_Set_Feature   => TRUE                       --TODO: уточнить
                                       );

            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => Rec.App_Sc);
        END LOOP;
    END;

    --=============================================================

    PROCEDURE Save_Person_Benefits (p_App_Id Ap_Person.App_Id%TYPE)
    IS
        l_Bnft   t_Benefit_Data;
        l_App    Ap_Person%ROWTYPE;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Save_App_Benefits',
                   'Ap_Person',
                   p_App_Id,
                   'Started.');

        SELECT *
          INTO l_App
          FROM Ap_Person
         WHERE App_Id = p_App_Id;

        l_Bnft := Get_App_Benefit_Params (p_App_Id);

        /*    IF l_Bnft.Msg != 'OK' THEN
              Raise_application_error(-20000, l_Bnft.Msg);
            END IF;
        */
        FOR i IN 1 .. l_Bnft.COUNT
        LOOP
            IF l_Bnft (i).Cat_Id IS NULL
            THEN
                TOOLS.LOG (
                    'API$AP2SC.Save_App_Benefits',
                    'Ap_Person',
                    p_App_Id,
                       'Benefit category is not found by params: App_Sc='
                    || l_App.App_Sc
                    || ', Cat_Num='
                    || l_Bnft (i).Cat_Num
                    || ', Doc_From_Dt='
                    || TO_CHAR (l_Bnft (i).Doc_From_Dt, 'DD.MM.YYYY')
                    || ', Doc_Till_Dt='
                    || TO_CHAR (l_Bnft (i).Doc_Till_Dt, 'DD.MM.YYYY'));
                uss_person.Api$socialcard.Save_Sc_Benefit_Category (
                    p_Scbc_Id         => l_Bnft (i).Cat_Id,
                    p_Scbc_Sc         => l_App.App_Sc,
                    p_Scbc_Nbc        => l_Bnft (i).Cat_Num,
                    p_Scbc_Start_Dt   => l_Bnft (i).Doc_From_Dt,
                    p_Scbc_Stop_Dt    => l_Bnft (i).Doc_Till_Dt,
                    p_Scbc_Src        => '35'); -- 35 - ЄІССС: Єдиний соціальний процессінг
            END IF;

            TOOLS.LOG ('API$AP2SC.Save_App_Benefits',
                       'Ap_Person',
                       p_App_Id,
                       'Sc_Benefit_Category.Scbc_Id=' || l_Bnft (i).Cat_Id);

            -- пошук робимо в документах СРКО (копіюваня вібувається в Copy_Document2Socialcard)
            SELECT MAX (d.Scd_Id)
              INTO l_Bnft (i).Scd_Id
              FROM uss_person.v_sc_document d
             WHERE     d.scd_sc = l_App.App_Sc
                   AND d.scd_doc = l_Bnft (i).Doc_Doc
                   AND d.scd_st = '1'
                   AND d.scd_ndt = l_Bnft (i).Doc_Ndt
                   AND TRIM (d.scd_number) =
                       UPPER (TRIM (l_Bnft (i).Doc_Num))
                   AND d.scd_issued_dt = l_Bnft (i).Doc_From_Dt--AND d.scd_issued_who = l_Bnft(i).Doc_Who
                                                               --AND (d.scd_stop_dt = l_Bnft(i).Doc_Till_Dt OR (d.scd_stop_dt IS NULL AND l_Bnft(i).Doc_Till_Dt IS NULL))
                                                               ;

            -- якщо знайдено - робимо прив'язку до категорії
            IF l_Bnft (i).Scd_Id IS NULL
            THEN
                TOOLS.LOG (
                    'API$AP2SC.Save_App_Benefits',
                    'Ap_Person',
                    p_App_Id,
                       'v_sc_document is not defined by params: scd_sc='
                    || l_App.App_Sc
                    || ' AND scd_doc='
                    || l_Bnft (i).Doc_Doc
                    || ' AND scd_st=''1'' AND scd_ndt='
                    || l_Bnft (i).Doc_Ndt
                    || ' AND scd_number='
                    || l_Bnft (i).Doc_Num
                    || ' AND scd_issued_dt='
                    || TO_CHAR (l_Bnft (i).Doc_From_Dt, 'DD.MM.YYYY')); --||' AND scd_stop_dt='||to_char(l_Bnft(i).Doc_Till_Dt,'DD.MM.YYYY') ||' AND scd_issued_who='||l_Bnft(i).Doc_Who
                Raise_application_error (
                    -20000,
                       'В картці СРКО ('
                    || l_App.App_Sc
                    || ') не вдалося визначити документ ('
                    || l_Bnft (i).Doc_Ndt
                    || ') що підтверджує право на пільгу ('
                    || l_Bnft (i).Cat_Num
                    || ').');
            ELSE
                uss_person.Api$socialcard.Save_Sc_Benefit_Docs (
                    p_scbd_scbc   => l_Bnft (i).Cat_Id,
                    p_scbd_scd    => l_Bnft (i).Scd_Id,
                    p_scbd_st     => NULL,
                    p_New_Id      => l_Bnft (i).Scbd_Id);
                TOOLS.LOG (
                    'API$AP2SC.Save_App_Benefits',
                    'Ap_Person',
                    p_App_Id,
                    'Save_Sc_Benefit_Docs: scbd_Id=' || l_Bnft (i).Scbd_Id);
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------------
    --  Оновлення даних пільговика #103626
    --  Виклик з Api$verification_Cond.Appeal_Main_Vf_Callback (NVT_CALLBACK на рівні Звернення)
    ----------------------------------------------------------------------------------
    PROCEDURE Update_Benefits_Data (p_Ap_Id    IN     Appeal.Ap_Id%TYPE,
                                    p_Vf_Res      OUT VARCHAR2)
    IS
        l_Ap       Appeal%ROWTYPE;
        l_App_Id   Ap_Person.App_Id%TYPE;
        l_Msg      Vf_Log.Vfl_Message%TYPE;
    BEGIN
        TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                   'APPEAL',
                   p_Ap_Id,
                   'Started');

        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                   'APPEAL',
                   p_Ap_Id,
                   'l_Ap.Ap_Src=' || l_Ap.Ap_Src);
        /* 24/01/2025 serhii: changed by #115246
       IF l_Ap.Ap_Src = 'PORTAL' THEN
         l_Msg := 'Оновлення даних по пільгам не виконується для зверненнь з Соціального веб-порталу Мінсоцполітики.';
         --Api$verification.Write_Vf_Log(p_Vf_Id => l_Ap.Ap_Vf, p_Vfl_Tp => Api$verification.c_Vfl_Tp_Info, p_Vfl_Message => l_Msg);
       ELSIF l_Ap.Ap_Src = 'USS' THEN */
        --l_Vf_St := Api$verification_Cond.Get_Veteran_Vf_St(p_Ap_Id); -- we get 'R' here - not useful
        l_App_Id :=
            Api$verification_Cond.Get_Veteran_App_Id (p_Ap_Id => p_Ap_Id);
        TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                   'APPEAL',
                   p_Ap_Id,
                   'Get l_App_Id=' || l_App_Id);

        IF NOT Api$verification_Cond.Is_All_App_Docs_Verified (
                   p_App_Id   => l_App_Id)
        THEN
            TOOLS.LOG (
                'API$AP2SC.Update_Benefits_Data',
                'APPEAL',
                p_Ap_Id,
                   'Process is skipped. Is_All_App_Docs_Verified return FALSE for l_App_Id='
                || l_App_Id);
            l_Msg := CHR (38) || '357'; --  не успішна - оновлення не виконується
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Ap.Ap_Vf,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => l_Msg);
        ELSE
            l_Msg := CHR (38) || '351';         -- Оновлення даних по пільгам.
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Ap.Ap_Vf,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                p_Vfl_Message   => l_Msg);
            TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                       'APPEAL',
                       p_Ap_Id,
                       'Copy_Document2Socialcard started.');
            Copy_Document2Socialcard (p_Ap_Id);
            TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                       'APPEAL',
                       p_Ap_Id,
                       'Copy_Document2Socialcard completed.');

            BEGIN
                FOR App IN (SELECT *
                              FROM Ap_Person
                             WHERE App_Ap = p_Ap_Id)
                LOOP
                    IF Api$verification_Cond.Is_Veteran (
                           p_App_Id   => App.App_Id)
                    THEN
                        Save_Person_Benefits (p_App_Id => App.App_Id);
                    ELSE
                        -- колись буде оновлення даних про членів родини
                        TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                                   'Ap_Person',
                                   App.App_Id,
                                   'Update skipped');
                    END IF;
                END LOOP;
            END;
        END IF;

        /* 24/01/2025 serhii: changed by #115246
       ELSE
         Raise_application_error(-20000, 'Не визначений алгоритм обробки для зверненнь з даним типом Джерела: ' || l_Ap.Ap_Src);
       END IF; */
        l_Msg := CHR (38) || '358'; -- 'Оновлення даних по пільгам завершено.'
        Api$verification.Write_Vf_Log (
            p_Vf_Id         => l_Ap.Ap_Vf,
            p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
            p_Vfl_Message   => l_Msg);
        TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                   'APPEAL',
                   p_Ap_Id,
                   'Completed');
        p_Vf_Res := 'OK';                     -- 19/02/2025 serhii for #116593
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.LOG ('API$AP2SC.Update_Benefits_Data',
                       'APPEAL',
                       p_Ap_Id,
                       'EXCEPTION');
            p_Vf_Res := 'ERR';                -- 19/02/2025 serhii for #116593
            Api$verification.Write_Vf_Log (
                p_Vf_Id    => l_Ap.Ap_Vf,
                p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            --ТЕХНІЧНА ПОМИЛКА
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Ap.Ap_Vf,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
    END;

    PROCEDURE App2sc_Vtrn (p_App_Id IN NUMBER, p_Vf_Id IN NUMBER)
    IS
        l_Ap_Id       NUMBER (14);
        l_Vtr_Id      NUMBER (14);
        l_Znk_Id      NUMBER (14);
        l_Vtr_St      VARCHAR2 (10);
        l_Znk_St      VARCHAR2 (10);
        l_Vtr_Is_Ok   BOOLEAN;
        l_Znk_Is_Ok   BOOLEAN;
    BEGIN
        -- Api$ap2sc.App2sc(p_App_Id => p_App_Id, p_Vf_Id => p_Vf_Id, p_Create_Sc_Forced => FALSE);  /*
        TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                   'Person',
                   p_App_Id,
                   'Begin. App_Id=' || p_App_Id || ', p_Vf_Id=' || p_Vf_Id);

        l_Ap_Id := Api$verification_Cond.Get_App_Ap (p_App_Id);
        l_Vtr_Id := Api$verification_Cond.Get_Veteran_App_Id (l_Ap_Id);

        IF l_Vtr_Id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Не вдалось визначити пільговика у зверненні!');
        END IF;

        l_Znk_Id := Api$verification_Cond.Get_Z_App_Id (l_Ap_Id);

        IF l_Znk_Id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Не вдалось визначити заявника у зверненні!');
        END IF;

        l_Vtr_St := Api$verification_Cond.Get_Person_Vf_St (l_Vtr_Id);
        l_Znk_St := Api$verification_Cond.Get_Person_Vf_St (l_Znk_Id);
        TOOLS.LOG (
            'Api$ap2sc.App2sc_Vtrn',
            'Appeal',
            l_Ap_Id,
               'mark 0 l_Vtr_Id='
            || l_Vtr_Id
            || ', l_Vtr_St='
            || l_Vtr_St
            || ', l_Znk_Id='
            || l_Znk_Id
            || ', l_Znk_St='
            || l_Znk_St);

        /*
        IF l_Vtr_St IN ('N', 'E')
        THEN
          l_Vtr_Is_Ok := FALSE;
        ELSIF l_Vtr_St = 'X'
        THEN
          l_Vtr_Is_Ok := TRUE;
        ELSE
          l_Vtr_Is_Ok := NULL; -- верифікація не завершена
        END IF;
        IF l_Znk_St IN ('N', 'E')
        THEN
          l_Znk_Is_Ok := FALSE;
        ELSIF l_Znk_St = 'X'
        THEN
          l_Znk_Is_Ok := TRUE;
        ELSE
          l_Znk_Is_Ok := NULL; -- верифікація не завершена
        END IF;
        */

        IF NOT Api$verification_Cond.Is_All_App_Doc_Vf_Finished (l_Vtr_Id)
        THEN
            l_Vtr_Is_Ok := NULL;                   -- верифікація не завершена
        ELSIF Api$verification_Cond.Is_All_App_Docs_Verified (l_Vtr_Id)
        THEN
            l_Vtr_Is_Ok := TRUE;
        ELSE
            l_Vtr_Is_Ok := FALSE;
        END IF;

        IF NOT Api$verification_Cond.Is_All_App_Doc_Vf_Finished (l_Znk_Id)
        THEN
            l_Znk_Is_Ok := NULL;                   -- верифікація не завершена
        ELSIF Api$verification_Cond.Is_All_App_Docs_Verified (l_Znk_Id)
        THEN
            l_Znk_Is_Ok := TRUE;
        ELSE
            l_Znk_Is_Ok := FALSE;
        END IF;

        TOOLS.LOG (
            'Api$ap2sc.App2sc_Vtrn',
            'Appeal',
            l_Ap_Id,
               'mark 0 l_Vtr_Id='
            || l_Vtr_Id
            || ', l_Vtr_Is_Ok='
            || TO_CHAR (sys.DIUTIL.bool_to_int (l_Vtr_Is_Ok))
            || ', l_Znk_Id='
            || l_Znk_Id
            || ', l_Znk_Is_Ok='
            || TO_CHAR (sys.DIUTIL.bool_to_int (l_Znk_Is_Ok)));

        IF NOT l_Vtr_Is_Ok
        THEN
            TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                       'Appeal',
                       l_Ap_Id,
                       'mark 1 App_Id=' || p_App_Id);
            Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_Id,
                                               p_Error   => CHR (38) || '359'); --Верифікацію припинено через неуспішну верифікацію пільговика
        ELSIF NOT l_Znk_Is_Ok
        THEN
            TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                       'Appeal',
                       l_Ap_Id,
                       'mark  2 App_Id=' || p_App_Id);
            Api$verification.Set_Not_Verified (p_Vf_Id   => p_Vf_Id,
                                               p_Error   => CHR (38) || '360'); --Верифікацію припинено через неуспішну верифікацію заявника
        ELSE
            -- №4 Учасник звернення + член родини пільговика (НЕ Заявник + Не Пільговик)
            IF p_App_Id != l_Vtr_Id AND p_App_Id != l_Znk_Id
            THEN
                TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                           'Appeal',
                           l_Ap_Id,
                           'mark  3 App_Id=' || p_App_Id);

                IF l_Vtr_Is_Ok IS NULL OR l_Znk_Is_Ok IS NULL
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  4 App_Id=' || p_App_Id);
                    -- перезапуск верифікації учасника роблю за умовою,
                    -- щоб не було зациклювання за ішних (непередбачених варіантиів)
                    Api$verification.Try_Continue_App_Vf (p_App_Id);
                ELSIF l_Vtr_Is_Ok AND l_Znk_Is_Ok
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  5 App_Id=' || p_App_Id);
                    -- очікуємо що тут все успішно
                    Api$ap2sc.App2sc (p_App_Id             => p_App_Id,
                                      p_Vf_Id              => p_Vf_Id,
                                      p_Create_Sc_Forced   => FALSE);
                ELSE
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  6 App_Id=' || p_App_Id);
                    Raise_application_error (
                        -20000,
                        'Не визначено алгоритм обробки!');
                END IF;
            -- №3 Учасник звернення + Пільговик
            ELSIF p_App_Id = l_Vtr_Id AND p_App_Id != l_Znk_Id
            THEN
                IF l_Znk_Is_Ok IS NULL
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  7 App_Id=' || p_App_Id);
                    Api$verification.Try_Continue_App_Vf (p_App_Id);
                ELSIF l_Znk_Is_Ok
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  8 App_Id=' || p_App_Id);
                    Api$ap2sc.App2sc (p_App_Id             => p_App_Id,
                                      p_Vf_Id              => p_Vf_Id,
                                      p_Create_Sc_Forced   => FALSE);
                ELSIF NOT l_Znk_Is_Ok
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  9 App_Id=' || p_App_Id);
                    Api$verification.Set_Not_Verified (
                        p_Vf_Id   => p_Vf_Id,
                        p_Error   => CHR (38) || '360'); --Верифікацію припинено через неуспішну верифікацію заявника
                ELSE
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  10 App_Id=' || p_App_Id);
                    Raise_application_error (
                        -20000,
                        'Не визначено алгоритм обробки!');
                END IF;
            -- №2 Заявник + член родини пільговика
            ELSIF p_App_Id = l_Znk_Id AND p_App_Id != l_Vtr_Id
            THEN
                IF l_Vtr_Is_Ok IS NULL
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  11 App_Id=' || p_App_Id);
                    Api$verification.Try_Continue_App_Vf (p_App_Id);
                ELSIF l_Vtr_Is_Ok
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  12 App_Id=' || p_App_Id);
                    Api$ap2sc.App2sc (p_App_Id             => p_App_Id,
                                      p_Vf_Id              => p_Vf_Id,
                                      p_Create_Sc_Forced   => FALSE);
                ELSIF NOT l_Vtr_Is_Ok
                THEN
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  13 App_Id=' || p_App_Id);
                    Api$verification.Set_Not_Verified (
                        p_Vf_Id   => p_Vf_Id,
                        p_Error   => CHR (38) || '359'); --Верифікацію припинено через неуспішну верифікацію пільговика
                ELSE
                    TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                               'Appeal',
                               l_Ap_Id,
                               'mark  14 App_Id=' || p_App_Id);
                    Raise_application_error (
                        -20000,
                        'Не визначено алгоритм обробки!');
                END IF;
            -- №1 Заявник + Пільговик
            ELSIF p_App_Id = l_Znk_Id AND p_App_Id = l_Vtr_Id
            THEN
                TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                           'Appeal',
                           l_Ap_Id,
                           'mark  15 App_Id=' || p_App_Id);
                Api$ap2sc.App2sc (p_App_Id             => p_App_Id,
                                  p_Vf_Id              => p_Vf_Id,
                                  p_Create_Sc_Forced   => FALSE);
            ELSE
                TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                           'Appeal',
                           l_Ap_Id,
                           'mark  16 App_Id=' || p_App_Id);
                Raise_application_error (-20000,
                                         'Не визначено алгоритм обробки!');
            END IF;
        END IF;

        TOOLS.LOG ('Api$ap2sc.App2sc_Vtrn',
                   'Appeal',
                   l_Ap_Id,
                   'End. App_Id=' || p_App_Id || ', p_Vf_Id=' || p_Vf_Id);
    EXCEPTION
        WHEN OTHERS
        THEN
            Api$verification.Write_Vf_Log (
                p_Vf_Id    => p_Vf_Id,
                p_Vfl_Tp   => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            --ТЕХНІЧНА ПОМИЛКА
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => p_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Error,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Error);
    END;
END Api$ap2sc;
/