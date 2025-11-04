/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SCDI2SC
IS
    -- Author  : SHOSTAK
    -- Created : 23.12.2024 21:07:44
    -- Purpose : Пошук/створення/оновлення СРКО після верифікації даних отриманих з зовнішніх джерел

    ----------------------------------------------------------------------------------
    --Отримання статі особи
    ----------------------------------------------------------------------------------
    FUNCTION Get_Scdi_Gender (p_Scdi_Id IN NUMBER)
        RETURN VARCHAR2;

    ----------------------------------------------------------------------------------
    --        Пошук соцкартки особи проміжних структур
    ----------------------------------------------------------------------------------
    FUNCTION Search_Scdi_Sc (
        p_Scdi                  IN OUT Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg              IN     Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE,
        p_Ipn_Invalid              OUT BOOLEAN,
        p_Pib_Mismatch_On_Ipn      OUT BOOLEAN)
        RETURN BOOLEAN;

    ----------------------------------------------------------------------------------
    --Оновлення/створення соціальної картки
    ----------------------------------------------------------------------------------
    PROCEDURE Scdi2sc (p_Scdi_Id    IN NUMBER,
                       p_Scv_Id     IN NUMBER,
                       p_Callback   IN VARCHAR2);
END Api$scdi2sc;
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SCDI2SC
IS
    c_Oper_Sc_Search      CONSTANT VARCHAR2 (10) := 'S';
    c_Oper_Sc_Create      CONSTANT VARCHAR2 (10) := 'C';
    c_Oper_Sc_Update_13   CONSTANT VARCHAR2 (10) := 'U13';

    ----------------------------------------------------------------------------------
    --Отримання статі особи
    ----------------------------------------------------------------------------------
    FUNCTION Get_Scdi_Gender (p_Scdi_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Sc_Pfu_Data_Ident.Scdi_Sex%TYPE;
        l_Src      VARCHAR2 (10);
    BEGIN
        SELECT p.Scdi_Sex, c.Nsc_Ap_Src
          INTO l_Result, l_Src
          FROM Sc_Pfu_Data_Ident  p
               JOIN Uss_Ndi.v_Ndi_Scdi_Config c ON p.Scdi_Nrt = c.Nsc_Nrt
         WHERE p.Scdi_Id = p_Scdi_Id;

        l_Result :=
            NVL (Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'GENDER',
                                            p_Nddc_Src        => l_Src,
                                            p_Nddc_Dest       => 'USS',
                                            p_Nddc_Code_Src   => l_Result),
                 l_Result);

        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------------
    --        Створення замітки для нових документів
    ----------------------------------------------------------------------------------
    FUNCTION Make_Scd_Note (p_Scdi_Cfg IN Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE)
        RETURN VARCHAR2
    IS
        l_Ap_Src_Name   VARCHAR2 (250);
        l_Source_Name   VARCHAR2 (250);
    BEGIN
        SELECT MAX (s.Dic_Sname)
          INTO l_Ap_Src_Name
          FROM Uss_Ndi.v_Ddn_Ap_Src s
         WHERE s.Dic_Value = p_Scdi_Cfg.Nsc_Ap_Src;

        SELECT s.Dic_Sname
          INTO l_Source_Name
          FROM Uss_Ndi.v_Ddn_Source s
         WHERE s.Dic_Value = p_Scdi_Cfg.Nsc_Source;

        RETURN    'Створено з обміну з системи '
               || LTRIM (l_Ap_Src_Name || ':', ':')
               || l_Source_Name;
    END;

    ----------------------------------------------------------------------------------
    --        Пошук соцкартки особи проміжних структур
    ----------------------------------------------------------------------------------
    FUNCTION Search_Scdi_Sc (
        p_Scdi                  IN OUT Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg              IN     Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE,
        p_Ipn_Invalid              OUT BOOLEAN,
        p_Pib_Mismatch_On_Ipn      OUT BOOLEAN)
        RETURN BOOLEAN
    IS
        l_Gender      VARCHAR2 (20);
        l_Ipn         VARCHAR2 (20);
        l_Doc_Num     VARCHAR2 (50);
        l_Doc_Ndt     NUMBER;
        l_Doc_Ser     VARCHAR2 (10);
        l_Sc_Unique   Uss_Person.v_Socialcard.Sc_Unique%TYPE;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$scdi2sc.Search_Scdi_Sc',
                       'SCDI',
                       p_Scdi.Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        LOG ('Start');
        p_Ipn_Invalid := FALSE;
        p_Pib_Mismatch_On_Ipn := FALSE;

        SELECT MAX (Sc.Sc_Id)
          INTO p_Scdi.Scdi_Sc
          FROM Socialcard Sc
         WHERE Sc.Sc_Unique = p_Scdi.Scdi_Ip_Unique AND Sc.Sc_St = '1';

        IF p_Scdi.Scdi_Sc > 0
        THEN
            l_Sc_Unique := p_Scdi.Scdi_Ip_Unique;
        END IF;

        LOG (
               'After Sc_Unique. p_Scdi.Scdi_Sc='
            || p_Scdi.Scdi_Sc
            || ' ,l_Sc_Unique='
            || l_Sc_Unique);

        IF NVL (p_Scdi.Scdi_Sc, 0) <= 0
        THEN
            l_Gender := Get_Scdi_Gender (p_Scdi_Id => p_Scdi.Scdi_Id);

            l_Ipn :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 5,
                    p_Nda_Class   => 'DSN');
            l_Ipn := NVL (l_Ipn, p_Scdi.Scdi_Numident);

            IF    l_Ipn IS NOT NULL
               OR (    p_Scdi.Scdi_Doc_Tp IS NOT NULL
                   AND p_Scdi.Scdi_Doc_Sn IS NOT NULL)
            THEN
                IF     p_Scdi.Scdi_Doc_Tp IS NOT NULL
                   AND p_Scdi.Scdi_Doc_Sn IS NOT NULL
                THEN
                    --Розбиваємо номер документа на серію та номер
                    l_Doc_Num := p_Scdi.Scdi_Doc_Sn;

                    IF l_Doc_Num IS NOT NULL
                    THEN
                        l_Doc_Ndt := p_Scdi.Scdi_Doc_Tp;
                    END IF;

                    Split_Doc_Number (p_Ndt_Id       => l_Doc_Ndt,
                                      p_Doc_Number   => l_Doc_Num,
                                      p_Doc_Serial   => l_Doc_Ser);
                END IF;

                LOG ('Before Load_SC');
                --Шукаємо соцкартку по реквізитам учасника
                p_Scdi.Scdi_Sc :=
                    Uss_Person.Load$socialcard.Load_Sc (
                        p_Fn            => p_Scdi.Scdi_Fn,
                        p_Ln            => p_Scdi.Scdi_Ln,
                        p_Mn            => p_Scdi.Scdi_Mn,
                        p_Gender        => l_Gender,
                        p_Nationality   => p_Scdi.Scdi_Nt,
                        p_Src_Dt        => NULL,
                        p_Birth_Dt      => p_Scdi.Scdi_Birthday,
                        p_Inn_Num       => l_Ipn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => l_Doc_Ndt,
                        p_Src           => p_Scdi_Cfg.Nsc_Source,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Mode          =>
                            Uss_Person.Load$socialcard.c_Mode_Search,
                        p_Sc            => p_Scdi.Scdi_Sc);

                LOG (
                       'After Load_SC. p_Scdi.Scdi_Sc='
                    || p_Scdi.Scdi_Sc
                    || ' ,l_Sc_Unique='
                    || l_Sc_Unique);

                IF p_Scdi.Scdi_Sc <= 0
                THEN
                    p_Scdi.Scdi_Sc := NULL;
                END IF;

                p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
                p_Pib_Mismatch_On_Ipn :=
                    Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;
            END IF;

            LOG ('After Load_SC. p_Scdi.Scdi_Sc=' || p_Scdi.Scdi_Sc);
        END IF;

        IF NVL (p_Scdi.Scdi_Sc, 0) <= 0
        THEN
            --Якщо соцкартку не було знайдено за реквізитами учасник,
            --шукаємо по документах, що привязані до учасника
            LOG ('Before document loop');

            FOR Doc
                IN (  SELECT d.Scpo_Id, d.Scpo_Ndt
                        FROM Sc_Pfu_Document d
                             JOIN Uss_Ndi.v_Ndi_Document_Type t
                                 ON d.Scpo_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13 --Для пошуку або актуалізації соцкартки використовуються лише документи з категорії "Верифікація особи"
                       WHERE d.Scpo_Scdi = p_Scdi.Scdi_Id
                    ORDER BY t.Ndt_Sc_Srch_Priority NULLS LAST)
            LOOP
                LOG ('Document loop iteration. Scpo_Id=' || Doc.Scpo_Id);

                --Отримуємо серію та номер документа
                SELECT MAX (a.Scpda_Val_String)
                  INTO l_Doc_Num
                  FROM Sc_Pfu_Document_Attr  a
                       JOIN Uss_Ndi.v_Ndi_Document_Attr n
                           ON a.Scpda_Nda = n.Nda_Id AND n.Nda_Class = 'DSN'
                 WHERE a.Scpda_Scpo = Doc.Scpo_Id;

                IF l_Doc_Num IS NOT NULL
                THEN
                    Split_Doc_Number (p_Ndt_Id       => Doc.Scpo_Ndt,
                                      p_Doc_Number   => l_Doc_Num,
                                      p_Doc_Serial   => l_Doc_Ser);
                END IF;

                IF     (Doc.Scpo_Ndt IS NULL OR l_Doc_Num IS NULL)
                   AND l_Ipn IS NULL
                THEN
                    CONTINUE;
                END IF;

                --Виконуємо пошук соцкартки
                LOG ('Before Load$socialcard.Load_Sc in Doc loop');
                p_Scdi.Scdi_Sc :=
                    Uss_Person.Load$socialcard.Load_Sc (
                        p_Fn            => p_Scdi.Scdi_Fn,
                        p_Ln            => p_Scdi.Scdi_Ln,
                        p_Mn            => p_Scdi.Scdi_Mn,
                        p_Gender        => l_Gender,
                        p_Nationality   => p_Scdi.Scdi_Nt,
                        p_Src_Dt        => NULL,
                        p_Birth_Dt      => p_Scdi.Scdi_Birthday,
                        p_Inn_Num       => l_Ipn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => Doc.Scpo_Ndt,
                        p_Src           => p_Scdi_Cfg.Nsc_Source,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Mode          =>
                            Uss_Person.Load$socialcard.c_Mode_Search,
                        p_Sc            => p_Scdi.Scdi_Sc);
                LOG (
                       'After Load_SC in Doc loop. p_Scdi.Scdi_Sc='
                    || p_Scdi.Scdi_Sc
                    || ', l_Sc_Unique='
                    || l_Sc_Unique);

                IF p_Scdi.Scdi_Sc <= 0
                THEN
                    p_Scdi.Scdi_Sc := NULL;
                END IF;

                p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
                p_Pib_Mismatch_On_Ipn :=
                    Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;

                IF p_Scdi.Scdi_Sc > 0
                THEN
                    EXIT;
                END IF;
            END LOOP;

            LOG ('After document loop');
        END IF;

        LOG (
               'Final Scdi_Sc. p_Scdi.Scdi_Sc='
            || p_Scdi.Scdi_Sc
            || ', l_Sc_Unique='
            || l_Sc_Unique);

        IF NVL (p_Scdi.Scdi_Sc, 0) > 0
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    ----------------------------------------------------------------------------------
    --    Спроба створення соціальної картки
    ----------------------------------------------------------------------------------
    FUNCTION Try_Create_Scdi_Sc (
        p_Scdi                  IN OUT Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg              IN     Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE,
        p_Ipn_Invalid              OUT BOOLEAN,
        p_Pib_Mismatch_On_Ipn      OUT BOOLEAN)
        RETURN BOOLEAN
    IS
        l_Ipn         VARCHAR2 (20);
        l_Doc_Ndt     NUMBER;
        l_Doc_Ser     VARCHAR2 (10);
        l_Doc_Num     VARCHAR2 (50);
        l_Src_Dt      DATE;

        l_Sc_Unique   VARCHAR2 (100);
        l_Sc_Id2      NUMBER;
    BEGIN
        Tools.LOG ('Api$scdi2sc.Try_Create_Scdi_Sc',
                   'SCDI',
                   p_Scdi.Scdi_Id,
                   'Statr: p_Scdi_Id=' || p_Scdi.Scdi_Id);
        p_Ipn_Invalid := FALSE;
        p_Pib_Mismatch_On_Ipn := FALSE;

        l_Sc_Unique := p_Scdi.Scdi_Ip_Unique;

        l_Ipn := p_Scdi.Scdi_Numident;

        IF l_Ipn IS NULL
        THEN
            l_Ipn :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 5,
                    p_Nda_Class   => 'DSN');
        END IF;

        l_Doc_Num := p_Scdi.Scdi_Doc_Sn;

        IF l_Doc_Num IS NOT NULL
        THEN
            l_Doc_Ndt := NVL (p_Scdi.Scdi_Doc_Tp, 7);
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := 6;
            l_Doc_Num :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 6,
                    p_Nda_Class   => 'DSN');
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := 7;
            l_Doc_Num :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 7,
                    p_Nda_Class   => 'DSN');
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := NULL;
        END IF;

        l_Src_Dt :=
            Api$socialcard_Ext.Get_Attr_Val_Dt (p_Scdi_Id     => p_Scdi.Scdi_Id,
                                                p_Ndt_Id      => l_Doc_Ndt,
                                                p_Nda_Class   => 'DGVDT');

        IF p_Scdi_Cfg.Nsc_Nrt = 43
        THEN
            l_Src_Dt :=
                Api$socialcard_Ext.Get_Attr_Val_Dt (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 10052,
                    p_Nda_Class   => 'DGVDT');
        END IF;

        Split_Doc_Number (p_Ndt_Id       => l_Doc_Ndt,
                          p_Doc_Number   => l_Doc_Num,
                          p_Doc_Serial   => l_Doc_Ser);

        p_Scdi.Scdi_Sc :=
            Load$socialcard.Load_Sc (
                p_Fn            => p_Scdi.Scdi_Fn,
                p_Ln            => p_Scdi.Scdi_Ln,
                p_Mn            => p_Scdi.Scdi_Mn,
                p_Gender        => Get_Scdi_Gender (p_Scdi_Id => p_Scdi.Scdi_Id),
                p_Nationality   => p_Scdi.Scdi_Nt,
                p_Src_Dt        => l_Src_Dt,
                p_Birth_Dt      => p_Scdi.Scdi_Birthday,
                p_Inn_Num       => l_Ipn,
                p_Inn_Ndt       => 5,
                p_Doc_Ser       => l_Doc_Ser,
                p_Doc_Num       => l_Doc_Num,
                p_Doc_Ndt       => l_Doc_Ndt,
                p_Src           => p_Scdi_Cfg.Nsc_Source,
                p_Sc_Unique     => l_Sc_Unique,
                p_Sc            => p_Scdi.Scdi_Sc,
                p_Mode          => Load$socialcard.c_Mode_Search_Update_Create);

        Tools.LOG (
            'Api$scdi2sc.Try_Create_Scdi_Sc',
            'SCDI',
            p_Scdi.Scdi_Id,
               'After Load$socialcard.Load_Sc: p_Scdi.Scdi_Sc='
            || p_Scdi.Scdi_Sc
            || ' ,l_Sc_Unique='
            || l_Sc_Unique);
        p_Ipn_Invalid := Uss_Person.Load$socialcard.g_Ipn_Invalid;
        p_Pib_Mismatch_On_Ipn :=
            Uss_Person.Load$socialcard.g_Pib_Mismatch_On_Ipn;

        IF NVL (p_Scdi.Scdi_Sc, -1) <= 0
        THEN
            RETURN FALSE;
        END IF;

        IF p_Scdi.Scdi_Ip_Unique IS NOT NULL
        THEN
            --Зберігаємо ПЕОКЗО до соцкартки(тільки у разі, якщо вона тимчасова)
            UPDATE Socialcard c
               SET c.Sc_Unique = p_Scdi.Scdi_Ip_Unique, c.Sc_St = '1'
             WHERE c.Sc_Id = p_Scdi.Scdi_Sc AND c.Sc_St = '4';

            --тимчасова
            IF SQL%ROWCOUNT > 0
            THEN
                UPDATE Sc_Info i
                   SET i.Sco_Unique = p_Scdi.Scdi_Ip_Unique
                 WHERE i.Sco_Id = p_Scdi.Scdi_Sc;
            END IF;
        END IF;

        RETURN TRUE;
    END;

    PROCEDURE Copy_Scdi_Attach2sc (
        p_Scpo_Id   IN Sc_Pfu_Document.Scpo_Id%TYPE,
        p_Dh_Id     IN NUMBER)
    IS
    BEGIN
        Tools.LOG ('Api$scdi2sc.Copy_Scdi_attach2sc',
                   'SCPO',
                   p_Scpo_Id,
                   'Statr: p_Scpo_Id=' || p_Scpo_Id);

        FOR Rec IN (SELECT f.Scpdf_Id,
                           f.Scpdf_Code,
                           f.Scpdf_Name,
                           f.Scpdf_Content_Type,
                           f.Scpdf_Hash,
                           f.Scpdf_Size
                      FROM Sc_Pfu_Document_File f
                     WHERE f.Scpdf_Scpo = p_Scpo_Id)
        LOOP
            Tools.LOG ('Api$scdi2sc.Copy_Scdi_attach2sc',
                       'SCPO',
                       p_Scpo_Id,
                       'Start iteration: Scpdf_Id=' || Rec.Scpdf_Id);

            DECLARE
                l_File_Id   NUMBER;
                l_Dat_Id    NUMBER;
            BEGIN
                --Перевіряємо файл на наявність по коду+хеш
                SELECT MAX (File_Id)
                  INTO l_File_Id
                  FROM Uss_Doc.v_Files f
                 WHERE     f.File_Code = Rec.Scpdf_Code
                       AND NVL (f.File_Hash, '-1') =
                           NVL (Rec.Scpdf_Hash, '-2');

                IF l_File_Id IS NULL
                THEN
                    Uss_Doc.Api$documents.Save_File (
                        p_File_Id            => NULL,
                        p_File_Thumb         => NULL,
                        p_File_Code          => Rec.Scpdf_Code,
                        p_File_Name          => Rec.Scpdf_Name,
                        p_File_Mime_Type     => Rec.Scpdf_Content_Type,
                        p_File_Description   => NULL,
                        p_File_Create_Dt     => SYSDATE,
                        p_File_Wu            => NULL,
                        p_File_App           => 2,
                        p_File_Hash          => Rec.Scpdf_Hash,
                        p_File_Size          => Rec.Scpdf_Size,
                        p_New_Id             => l_File_Id);
                END IF;

                Uss_Doc.Api$documents.Save_Attachment (
                    p_Dat_Id          => NULL,
                    p_Dat_Num         => NULL,
                    p_Dat_File        => l_File_Id,
                    p_Dat_Dh          => p_Dh_Id,
                    p_Dat_Sign_File   => NULL,
                    p_Dat_Hs          => Uss_Doc.Tools.Gethistsession,
                    p_New_Id          => l_Dat_Id);
            END;
        END LOOP;
    END;

    PROCEDURE Copy_Scdi_Docs2sc (
        p_Scdi          IN Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg      IN Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE,
        p_Ipn_Invalid   IN BOOLEAN,
        p_Operation     IN VARCHAR2)
    IS
    BEGIN
        Tools.LOG ('Api$scdi2sc.Copy_Scdi_Docs2sc',
                   'SCDI',
                   p_Scdi.Scdi_Id,
                   'Statr: p_Scdi_Id=' || p_Scdi.Scdi_Id);

        FOR Rec
            IN (SELECT *
                  FROM (SELECT d.Scpo_Id,
                               d.Scpo_Ndt,
                               t.Ndt_Ndc,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY t.Ndt_Ndc,
                                                    NVL (t.Ndt_Uniq_Group,
                                                         t.Ndt_Id)
                                       ORDER BY
                                           t.Ndt_Sc_Copy_Priority NULLS LAST)    AS Rn
                          FROM Sc_Pfu_Document  d
                               JOIN Uss_Ndi.v_Ndi_Document_Type t
                                   ON d.Scpo_Ndt = t.Ndt_Id
                         WHERE     d.Scpo_Scdi = p_Scdi.Scdi_Id
                               AND Scpo_Scd IS NULL --пропускаємо документи що уже створені (у разі повторної верифікації)
                               AND t.Ndt_Ndc NOT IN (-1) --Виключаємо технічні документи
                               --Якщо документи копіюються в існуючу СРКО, то виключаємо ідентифікуючі документи та ІПН або відмову від ІПН
                               --(тут можна прописувати умови з врахуванням операції після якої копіюються документи або джерела, з якого надійшли документи)
                               AND NOT (    p_Operation = c_Oper_Sc_Search
                                        AND (   t.Ndt_Ndc = 13
                                             OR t.Ndt_Id IN (5, 10117)))
                               AND NOT (    p_Operation = c_Oper_Sc_Update_13
                                        AND t.Ndt_Id IN (5, 10117))--
                                                                   )
                 WHERE Rn = 1)
        LOOP
            Tools.LOG ('Api$scdi2sc.Copy_Scdi_Docs2sc',
                       'SCDI',
                       p_Scdi.Scdi_Id,
                       'Start iteration: Scpo_Id=' || Rec.Scpo_Id);

            DECLARE
                l_Doc_Id      NUMBER;
                l_Dh_Id       NUMBER;
                l_Scd_Id      NUMBER;
                l_Doc_Attrs   Api$socialcard.t_Doc_Attrs;
                l_Log         VARCHAR2 (4000);
            BEGIN
                IF Rec.Scpo_Ndt = 5 AND p_Ipn_Invalid
                THEN
                    CONTINUE;
                END IF;

                SELECT a.Scpda_Nda,
                       TRIM (a.Scpda_Val_String),
                       a.Scpda_Val_Dt,
                       a.Scpda_Val_Int,
                       a.Scpda_Val_Id
                  BULK COLLECT INTO l_Doc_Attrs
                  FROM Sc_Pfu_Document_Attr a
                 WHERE a.Scpda_Scpo = Rec.Scpo_Id AND a.Scpda_Nda IS NOT NULL;

                IF Rec.Scpo_Ndt = 5
                THEN
                    FOR c
                        IN (SELECT 1
                              FROM TABLE (l_Doc_Attrs)          a,
                                   Uss_Ndi.v_Ndi_Document_Attr  Na
                             WHERE     a.Nda_Id = Na.Nda_Id
                                   AND Na.Nda_Class = 'DSN'
                                   AND a.Val_Str = '0000000000')
                    LOOP
                        CONTINUE;
                    END LOOP;
                END IF;

                SELECT SUBSTR (
                           LISTAGG (
                               DISTINCT
                                      a.Scpda_Nda
                                   || '='
                                   || TRIM (a.Scpda_Val_String),
                               ', '),
                           1,
                           1000)
                  INTO l_Log
                  FROM Sc_Pfu_Document_Attr a
                 WHERE a.Scpda_Scpo = Rec.Scpo_Id AND a.Scpda_Nda IS NOT NULL;

                Tools.LOG (
                    'Api$scdi2sc.Copy_Scdi_Docs2sc',
                    'SCDI',
                    p_Scdi.Scdi_Id,
                       'Before Api$socialcard.Save_Document: p_Sc_Id='
                    || p_Scdi.Scdi_Sc
                    || ', p_Ndt_Id='
                    || Rec.Scpo_Ndt
                    || ', l_Log='
                    || l_Log);

                Api$socialcard.Save_Document (
                    p_Sc_Id         => p_Scdi.Scdi_Sc,
                    p_Ndt_Id        => Rec.Scpo_Ndt,
                    p_Doc_Attrs     => l_Doc_Attrs,
                    p_Src_Id        => p_Scdi_Cfg.Nsc_Source,
                    p_Src_Code      => p_Scdi_Cfg.Nsc_Ap_Src,
                    p_Scd_Note      => Make_Scd_Note (p_Scdi_Cfg => p_Scdi_Cfg),
                    p_Scd_Id        => l_Scd_Id,
                    p_Doc_Id        => l_Doc_Id,
                    p_Dh_Id         => l_Dh_Id,
                    p_Set_Feature   => TRUE);

                UPDATE Sc_Pfu_Document
                   SET Scpo_Scd = l_Scd_Id
                 WHERE Scpo_Id = Rec.Scpo_Id;

                UPDATE Sc_Benefit_Docs
                   SET Scbd_Scd = l_Scd_Id
                 WHERE Scbd_Scpo = Rec.Scpo_Id;

                Copy_Scdi_Attach2sc (p_Scpo_Id   => Rec.Scpo_Id,
                                     p_Dh_Id     => l_Dh_Id);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20001,
                           'Помилка копіювання документа(Scpo_Id='
                        || Rec.Scpo_Id
                        || ') до соц. картки: '
                        || SQLERRM);
            END;
        END LOOP;
    END;

    PROCEDURE Copy_Scdi_Addr2sc (
        p_Scdi       IN Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg   IN Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE)
    IS
    BEGIN
        Tools.LOG ('Api$scdi2sc.Copy_Scdi_Addr2sc',
                   'SCDI',
                   p_Scdi.Scdi_Id,
                   'Statr: p_Scdi_Id=' || p_Scdi.Scdi_Id);

        FOR Rec IN (SELECT *
                      FROM Sc_Pfu_Address a
                     WHERE a.Scpa_Scdi = p_Scdi.Scdi_Id)
        LOOP
            Tools.LOG ('Api$scdi2sc.Copy_Scdi_Addr2sc',
                       'SCDI',
                       p_Scdi.Scdi_Id,
                       'Start iteration: Scpa_Id=' || Rec.Scpa_Id);

            DECLARE
                l_Sca_Id    NUMBER;
                l_Kaot_Id   NUMBER;
            BEGIN
                SELECT MAX (k.Kaot_Id)
                  INTO l_Kaot_Id
                  FROM Uss_Ndi.v_Ndi_Katottg k
                 WHERE k.Kaot_Code = Rec.Scpa_Kaot_Code;

                Tools.LOG (
                    'Api$scdi2sc.Copy_Scdi_Addr2sc',
                    'SCDI',
                    p_Scdi.Scdi_Id,
                       'Before Api$socialcard.Save_Sc_Address: p_Sc_Id='
                    || p_Scdi.Scdi_Sc
                    || ', p_Sca_Tp='
                    || Rec.Scpa_Tp);

                Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => p_Scdi.Scdi_Sc,
                    p_Sca_Tp          => Rec.Scpa_Tp,
                    p_Sca_Kaot        => l_Kaot_Id,
                    p_Sca_Nc          => 1,                         -- Україна
                    p_Sca_Country     => NULL,
                    p_Sca_Region      =>
                        Uss_Ndi.Api$dic_Common.Get_Kaot_Region (
                            p_Kaot_Id   => l_Kaot_Id),
                    p_Sca_District    =>
                        Uss_Ndi.Api$dic_Common.Get_Kaot_District (
                            p_Kaot_Id   => l_Kaot_Id),
                    p_Sca_Postcode    => Rec.Scpa_Postcode,
                    p_Sca_City        => Rec.Scpa_City,
                    p_Sca_Street      => Rec.Scpa_Street,
                    p_Sca_Building    => Rec.Scpa_Building,
                    p_Sca_Block       => Rec.Scpa_Block,
                    p_Sca_Apartment   => Rec.Scpa_Apartment,
                    p_Sca_Note        =>
                        Make_Scd_Note (p_Scdi_Cfg => p_Scdi_Cfg),
                    p_Sca_Src         => p_Scdi_Cfg.Nsc_Source,
                    p_Sca_Create_Dt   => Rec.Scpa_Create_Dt,
                    o_Sca_Id          => l_Sca_Id);

                UPDATE Sc_Household h
                   SET Schh_Sca = l_Sca_Id
                 WHERE h.Schh_Scpa = Rec.Scpa_Id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20001,
                           'Помилка копіювання адреси(Scpa_Id='
                        || Rec.Scpa_Id
                        || ') до соц. картки: '
                        || SQLERRM);
            END;
        END LOOP;
    END;

    ----------------------------------------------------------------------------------
    --Актуалізація соціальної картки
    --До існуючого СРКО внесення документа групи 13 та/або дати народження, при відсутності таког ов СРКО
    --#114235
    ----------------------------------------------------------------------------------
    PROCEDURE Actualize_Scdi_Sc (
        p_Scdi               IN OUT Sc_Pfu_Data_Ident%ROWTYPE,
        p_Scdi_Cfg           IN     Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE,
        p_Is_Append_Doc_13      OUT BOOLEAN)
    IS
        l_Has_Doc_13   BOOLEAN;
        l_Has_Birth    BOOLEAN;

        l_Ipn          VARCHAR2 (20);
        l_Doc_Ndt      NUMBER;
        l_Doc_Ser      Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE;
        l_Doc_Num      Sc_Pfu_Data_Ident.Scdi_Doc_Sn%TYPE;
        l_Src_Dt       DATE;
        l_Birth_Dt     DATE;

        l_Sc_Unique    Socialcard.Sc_Unique%TYPE;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$scdi2sc.Actualize_Scdi_Sc',
                       'SCDI',
                       p_Scdi.Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        p_Is_Append_Doc_13 := FALSE;
        LOG ('Start: p_Scdi.Scdi_Id=' || p_Scdi.Scdi_Id);

        IF p_Scdi.Scdi_Ln IS NULL OR p_Scdi.Scdi_Fn IS NULL
        THEN
            p_Scdi.Scdi_Ln := NULL;
            p_Scdi.Scdi_Fn := NULL;
            p_Scdi.Scdi_Mn := NULL;
        END IF;

        IF     p_Scdi.Scdi_Birthday IS NULL
           AND (p_Scdi.Scdi_Ln IS NULL OR p_Scdi.Scdi_Fn IS NULL)
        THEN
            RETURN;
        END IF;

        l_Has_Doc_13 :=
            Api$sc_Tools.Get_Doc_Num (p_Sc_Id => p_Scdi.Scdi_Sc) IS NOT NULL;
        l_Has_Birth :=
            Api$sc_Tools.Get_Birthdate (p_Sc_Id => p_Scdi.Scdi_Sc) IS NOT NULL;

        IF l_Has_Doc_13 AND l_Has_Birth
        THEN
            LOG (
                   'Has doc in group 13 and Birth. No need update. p_Scdi.Scdi_Id='
                || p_Scdi.Scdi_Id);
            RETURN;
        END IF;

        l_Sc_Unique := p_Scdi.Scdi_Ip_Unique;

        l_Ipn := p_Scdi.Scdi_Numident;

        IF l_Ipn IS NULL
        THEN
            l_Ipn :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 5,
                    p_Nda_Class   => 'DSN');
        END IF;

        l_Doc_Num := p_Scdi.Scdi_Doc_Sn;

        IF l_Doc_Num IS NOT NULL
        THEN
            l_Doc_Ndt := NVL (p_Scdi.Scdi_Doc_Tp, 7);
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := 6;
            l_Doc_Num :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 6,
                    p_Nda_Class   => 'DSN');
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := 7;
            l_Doc_Num :=
                Api$socialcard_Ext.Get_Attr_Val_String (
                    p_Scdi_Id     => p_Scdi.Scdi_Id,
                    p_Ndt_Id      => 7,
                    p_Nda_Class   => 'DSN');
        END IF;

        IF l_Doc_Num IS NULL
        THEN
            l_Doc_Ndt := NULL;
        END IF;

        l_Src_Dt :=
            Api$socialcard_Ext.Get_Attr_Val_Dt (p_Scdi_Id     => p_Scdi.Scdi_Id,
                                                p_Ndt_Id      => l_Doc_Ndt,
                                                p_Nda_Class   => 'DGVDT');
        Split_Doc_Number (p_Ndt_Id       => l_Doc_Ndt,
                          p_Doc_Number   => l_Doc_Num,
                          p_Doc_Serial   => l_Doc_Ser);

        LOG (
               'Before Load$socialcard.Load_Sc: p_Scdi.Scdi_Sc='
            || p_Scdi.Scdi_Sc
            || ', Fn='
            || p_Scdi.Scdi_Fn
            || ', Ln='
            || p_Scdi.Scdi_Ln
            || ', Mn='
            || p_Scdi.Scdi_Mn);
        p_Scdi.Scdi_Sc :=
            Uss_Person.Load$socialcard.Load_Sc (
                p_Fn            => p_Scdi.Scdi_Fn,
                p_Ln            => p_Scdi.Scdi_Ln,
                p_Mn            => p_Scdi.Scdi_Mn,
                p_Gender        => Get_Scdi_Gender (p_Scdi_Id => p_Scdi.Scdi_Id),
                p_Nationality   => p_Scdi.Scdi_Nt,
                p_Src_Dt        => l_Src_Dt,
                p_Birth_Dt      => p_Scdi.Scdi_Birthday,
                p_Inn_Num       => l_Ipn,
                p_Inn_Ndt       => 5,
                p_Doc_Ser       => l_Doc_Ser,
                p_Doc_Num       => l_Doc_Num,
                p_Doc_Ndt       => l_Doc_Ndt,
                p_Src           => p_Scdi_Cfg.Nsc_Source,
                p_Sc_Unique     => l_Sc_Unique,
                p_Mode          => Load$socialcard.c_Mode_Search_Update,
                p_Sc            => p_Scdi.Scdi_Sc);
        LOG (
               'After Load$socialcard.Load_Sc: p_Scdi.Scdi_Sc='
            || p_Scdi.Scdi_Sc);

        IF NOT l_Has_Doc_13
        THEN
            p_Is_Append_Doc_13 := TRUE;
        END IF;
    END;

    ----------------------------------------------------------------------------------
    --Оновлення/створення соціальної картки
    ----------------------------------------------------------------------------------
    PROCEDURE Scdi2sc (p_Scdi_Id    IN NUMBER,
                       p_Scv_Id     IN NUMBER,
                       p_Callback   IN VARCHAR2)
    IS
        l_Scdi                  Sc_Pfu_Data_Ident%ROWTYPE;
        l_Scdi_Cfg              Uss_Ndi.v_Ndi_Scdi_Config%ROWTYPE;
        l_Hs                    NUMBER;
        l_Ipn_Invalid           BOOLEAN := FALSE;
        l_Pib_Mismatch_On_Ipn   BOOLEAN := FALSE;
        l_Is_Append_Doc_13      BOOLEAN := FALSE;

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            Tools.LOG ('Api$scdi2sc.Scdi2sc',
                       'SCDI',
                       p_Scdi_Id,
                       p_Action,
                       p_Clob);
        END;
    BEGIN
        l_Hs := Tools.Gethistsession ();

        LOG ('Start: p_Scdi_Id=' || p_Scdi_Id || ', p_Scv_Id=' || p_Scv_Id);

        SELECT *
          INTO l_Scdi
          FROM Sc_Pfu_Data_Ident
         WHERE Scdi_Id = p_Scdi_Id;

        SELECT *
          INTO l_Scdi_Cfg
          FROM Uss_Ndi.v_Ndi_Scdi_Config c
         WHERE c.Nsc_Nrt = l_Scdi.Scdi_Nrt;

        LOG ('After load person data. Scdi_Sc=' || l_Scdi.Scdi_Sc);

        IF    l_Scdi.Scdi_Sc IS NOT NULL
           OR Search_Scdi_Sc (l_Scdi,
                              l_Scdi_Cfg,
                              l_Ipn_Invalid,
                              l_Pib_Mismatch_On_Ipn)
        THEN
            LOG ('SC Found');

            EXECUTE IMMEDIATE   'BEGIN '
                             || p_Callback
                             || '(p_Scdi_Id => :p_Scdi, p_Scdi_Sc => :p_Scdi_Sc); END;'
                USING IN l_Scdi.Scdi_Id, IN l_Scdi.Scdi_Sc;

            --Актуалізація соціальної картки учасника
            LOG (
                'Before Actualize_Scdi_Sc: l_Scdi.Scdi_Sc=' || l_Scdi.Scdi_Sc);
            Actualize_Scdi_Sc (l_Scdi, l_Scdi_Cfg, l_Is_Append_Doc_13);
            LOG (
                   'After Actualize_Scdi_Sc: l_Scdi.Scdi_Sc='
                || l_Scdi.Scdi_Sc
                || ', l_Is_Append_Doc_13='
                || CASE WHEN l_Is_Append_Doc_13 THEN 'T' ELSE 'F' END);
            --Копіювання документів учасників звернення до соціальної картки
            LOG (
                'Before Copy_Scdi_Docs2sc: l_Scdi.Scdi_Sc=' || l_Scdi.Scdi_Sc);
            Copy_Scdi_Docs2sc (
                l_Scdi,
                l_Scdi_Cfg,
                l_Ipn_Invalid,
                CASE
                    WHEN l_Is_Append_Doc_13 THEN c_Oper_Sc_Update_13
                    ELSE c_Oper_Sc_Search
                END);
            --Копіювання адреси учасників звернення до соціальної картки
            LOG (
                'Before Copy_Scdi_Addr2sc: l_Scdi.Scdi_Sc=' || l_Scdi.Scdi_Sc);
            Copy_Scdi_Addr2sc (l_Scdi, l_Scdi_Cfg);

            IF l_Pib_Mismatch_On_Ipn
            THEN
                Api$sc_Verification.Write_Scv_Log (
                    p_Scv_Id         => p_Scv_Id,
                    p_Scvl_Hs        => l_Hs,
                    p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Warning,
                    p_Scvl_Message   => CHR (38) || '264',
                    p_Scvl_St        => NULL,
                    p_Scvl_St_Old    => NULL);
            END IF;

            IF l_Ipn_Invalid
            THEN
                Api$sc_Verification.Write_Scv_Log (
                    p_Scv_Id         => p_Scv_Id,
                    p_Scvl_Hs        => l_Hs,
                    p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Warning,
                    p_Scvl_Message   => CHR (38) || '265',
                    p_Scvl_St        => NULL,
                    p_Scvl_St_Old    => NULL);
            END IF;

            LOG (
                   'Before Set_Ok: p_Scdi_Id='
                || p_Scdi_Id
                || ', p_Scv_Id='
                || p_Scv_Id);
            Api$sc_Verification.Set_Ok (p_Scv_Id, p_Scvl_Hs => l_Hs);
            RETURN;
        END IF;

        LOG (
               'Before Try_Create_Scdi_Sc: p_Scdi_Id='
            || p_Scdi_Id
            || ', p_Scv_Id='
            || p_Scv_Id);

        IF Try_Create_Scdi_Sc (
               p_Scdi                  => l_Scdi,
               p_Scdi_Cfg              => l_Scdi_Cfg,
               p_Ipn_Invalid           => l_Ipn_Invalid,
               p_Pib_Mismatch_On_Ipn   => l_Pib_Mismatch_On_Ipn)
        THEN
            EXECUTE IMMEDIATE   'BEGIN '
                             || p_Callback
                             || '(p_Scdi_Id => :p_Scdi, p_Scdi_Sc => :p_Scdi_Sc); END;'
                USING IN l_Scdi.Scdi_Id, IN l_Scdi.Scdi_Sc;

            --Копіювання документів учасників звернення до соціальної картки
            LOG (
                'Before Copy_Scdi_Docs2sc: l_Scdi.Scdi_Sc=' || l_Scdi.Scdi_Sc);
            Copy_Scdi_Docs2sc (l_Scdi,
                               l_Scdi_Cfg,
                               l_Ipn_Invalid,
                               c_Oper_Sc_Create);
            --Копіювання адреси учасників звернення до соціальної картки
            LOG (
                'Before Copy_Scdi_Addr2sc: l_Scdi.Scdi_Sc=' || l_Scdi.Scdi_Sc);
            Copy_Scdi_Addr2sc (l_Scdi, l_Scdi_Cfg);

            --Заповнення інформації для відображення в соц. картці
            LOG (
                   'Before Api$socialcard.Init_Sc_Info: p_Scdi_Id='
                || p_Scdi_Id
                || ', p_Scv_Id='
                || p_Scv_Id);
            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => l_Scdi.Scdi_Sc);

            IF l_Pib_Mismatch_On_Ipn
            THEN
                Api$sc_Verification.Write_Scv_Log (
                    p_Scv_Id         => p_Scv_Id,
                    p_Scvl_Hs        => l_Hs,
                    p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Warning,
                    p_Scvl_Message   => CHR (38) || '264',
                    p_Scvl_St        => NULL,
                    p_Scvl_St_Old    => NULL);
            END IF;

            IF l_Ipn_Invalid
            THEN
                Api$sc_Verification.Write_Scv_Log (
                    p_Scv_Id         => p_Scv_Id,
                    p_Scvl_Hs        => l_Hs,
                    p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Warning,
                    p_Scvl_Message   => CHR (38) || '265',
                    p_Scvl_St        => NULL,
                    p_Scvl_St_Old    => NULL);
            END IF;

            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => p_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Info,
                p_Scvl_Message   => CHR (38) || '140#' || l_Scdi.Scdi_Sc,
                p_Scvl_St        => NULL,
                p_Scvl_St_Old    => NULL);

            LOG (
                   'Before Set_Ok: p_Scdi_Id='
                || p_Scdi_Id
                || ', p_Scv_Id='
                || p_Scv_Id);
            Api$sc_Verification.Set_Ok (p_Scv_Id, p_Scvl_Hs => l_Hs);
            RETURN;
        END IF;

        LOG (
               'Try_Create_Scdi_Sc return false: p_Scdi_Id='
            || p_Scdi_Id
            || ', p_Scv_Id='
            || p_Scv_Id);
        --НЕУСПІШНА ВЕРИФІКАЦІЯ
        /*Api$sc_Verification_Moz.Send_Feedback(p_Scdi_Id => p_Scdi_Id,
                                              p_Result  => Api$sc_Verification_Moz.c_Feedback_Verify,
                                              p_Message => Uss_Ndi.Rdm$msg_Template.Getmessagetext(Chr(38) ||
                                                                                                   '141'));*/
        Api$sc_Verification.Set_Not_Verified (
            p_Scv_Id    => p_Scv_Id,
            p_Scvl_Hs   => l_Hs,
            p_Error     => CHR (38) || '141');
    EXCEPTION
        WHEN OTHERS
        THEN
            LOG (
                'Exception.',
                   SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Stack
                || DBMS_UTILITY.Format_Error_Backtrace);
            Api$sc_Verification.Write_Scv_Log (
                p_Scv_Id         => p_Scv_Id,
                p_Scvl_Hs        => l_Hs,
                p_Scvl_Tp        => Api$sc_Verification.c_Scvl_Tp_Terror,
                p_Scvl_Message   =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Scvl_St        => 'VE',
                p_Scvl_St_Old    => NULL);
            --ТЕХНІЧНА ПОМИЛКА
            Api$sc_Verification.Set_Scdi_Verification_Status (
                p_Scv_Id          => p_Scv_Id,
                p_Scv_St          => Api$sc_Verification.c_Scv_St_Error,
                p_Scv_Hs          => l_Hs,
                p_Lock_Main_Scv   => TRUE);
    END;
END Api$scdi2sc;
/