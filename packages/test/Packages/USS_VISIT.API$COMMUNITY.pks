/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$COMMUNITY
IS
    -- Author  : SHOSTAK
    -- Created : 01.11.2021 15:06:42
    -- Purpose : Взаємодія з системою "Соцгромада"

    c_Dt_Fmt   CONSTANT VARCHAR2 (30) := 'yyyy-mm-dd';

    FUNCTION Is_Ext_Pass (p_Ap_Id NUMBER)
        RETURN BOOLEAN;

    FUNCTION Get_Statement (p_Ap_Id IN NUMBER, p_Com_Org IN NUMBER)
        RETURN CLOB;

    FUNCTION Decode_Org (p_Com_Org IN NUMBER)
        RETURN NUMBER;

    FUNCTION Reg_Vpo_Req (p_Rn_Nrt   IN     NUMBER,
                          p_Obj_Id   IN     NUMBER,
                          p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Vpo_Resp (p_Ur_Id      IN     NUMBER,
                               p_Response   IN     CLOB,
                               p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Vpo_Register_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Vpo_Register_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Vpo_Help_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Vpo_Help_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Subs_Req (p_Rn_Nrt   IN     NUMBER,
                           p_Obj_Id   IN     NUMBER,
                           p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Subs_Resp (p_Ur_Id      IN     NUMBER,
                                p_Response   IN     CLOB,
                                p_Error      IN OUT VARCHAR2);

    FUNCTION Reg_Aid_Req (p_Rn_Nrt   IN     NUMBER,
                          p_Obj_Id   IN     NUMBER,
                          p_Error       OUT VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Handle_Aid_Resp (p_Ur_Id      IN     NUMBER,
                               p_Response   IN     CLOB,
                               p_Error      IN OUT VARCHAR2);

    PROCEDURE App_Vf_Callback (p_App_Id IN NUMBER);
END Api$community;
/


GRANT EXECUTE ON USS_VISIT.API$COMMUNITY TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.API$COMMUNITY TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:59:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$COMMUNITY
IS
    -----------------------------------------------------------------
    --  Отримання ознаки чи потрібно передавати звернення до СГ
    -----------------------------------------------------------------
    FUNCTION Is_Ext_Pass (p_Ap_Id NUMBER)
        RETURN BOOLEAN
    IS
        l_Is_Ext_Pass   VARCHAR2 (10);
    BEGIN
        SELECT COALESCE (--Найвищій приорітет має налаштування по району
                         MAX (c.Nnec_Is_Ext_Pass),
                         --Потім по області
                         MAX (Cc.Nnec_Is_Ext_Pass),
                         --Якщо не вказано налаштування, за замовчуванням - T
                         'T')
          INTO l_Is_Ext_Pass
          FROM Appeal  a
               JOIN Ikis_Sys.v_Opfu o ON a.Com_Org = o.Org_Id
               LEFT JOIN Ap_Service s
                   ON a.Ap_Id = s.Aps_Ap AND s.History_Status = 'A'
               --Налаштування по району
               LEFT JOIN Uss_Ndi.v_Ndi_Nst_Ext_Config c
                   ON a.Com_Org = c.Nnec_Org AND s.Aps_Nst = c.Nnec_Nst
               --Налаштування по області
               LEFT JOIN Uss_Ndi.v_Ndi_Nst_Ext_Config Cc
                   ON o.Org_Org = Cc.Nnec_Org AND s.Aps_Nst = Cc.Nnec_Nst
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Is_Ext_Pass = 'T';
    END;

    FUNCTION Create_Id_Obj (p_Id NUMBER)
        RETURN Json_Obj
    IS
        l_Obj   Json_Obj;
    BEGIN
        l_Obj := NEW Json_Obj ();
        l_Obj.Push ('id', p_Id);
        RETURN l_Obj;
    END;

    FUNCTION Sum2char (p_Sum NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (TO_CHAR (p_Sum, 'FM999999999999990D90'), ',', '.');
    END;

    FUNCTION Create_Zip_Code_Obj (p_Index              VARCHAR2,
                                  p_Com_Org            NUMBER,
                                  p_Com_Org_Orig       NUMBER,
                                  p_Kaot_Id        OUT NUMBER)
        RETURN Json_Obj
    IS
        l_Zip_Code      Json_Obj;
        l_Zip_Code_Id   NUMBER;
    BEGIN
        l_Zip_Code := NEW Json_Obj ();

        --#21.08.22: по постановці А.Гуменюк, якщо немає співпадіння по Npo_Org, то брати будьякий запис з таким індексом
        SELECT MAX (Npo_Mirg_Code), MAX (Npo_Kaot)
          INTO l_Zip_Code_Id, p_Kaot_Id
          FROM (  SELECT o.Npo_Mirg_Code, o.Npo_Kaot
                    FROM Uss_Ndi.v_Ndi_Post_Office o
                   WHERE o.Npo_Index = p_Index
                ORDER BY CASE
                             WHEN o.Npo_Org = p_Com_Org THEN 1
                             WHEN o.Npo_Org IS NULL THEN 3
                             ELSE 2
                         END NULLS LAST
                   FETCH FIRST ROW ONLY);

        l_Zip_Code.Push ('id', l_Zip_Code_Id);
        l_Zip_Code.Push ('upsznKATOTTG', p_Com_Org_Orig);
        l_Zip_Code.Push ('zipCode', p_Index);

        RETURN l_Zip_Code;
    END;

    FUNCTION Create_Address_Obj (p_Com_Org               NUMBER,
                                 p_Com_Org_Orig          NUMBER,
                                 p_Num_Build             VARCHAR2,
                                 p_Block_Build           VARCHAR2,
                                 p_Appartment            VARCHAR2,
                                 p_Street_Type           VARCHAR2,
                                 p_Street_Name           VARCHAR2,
                                 p_Kaot_Id        IN OUT NUMBER,
                                 p_Index                 VARCHAR2,
                                 p_Address_Cat           NUMBER)
        RETURN Json_Obj
    IS
        l_Addr          Json_Obj;
        l_Address_Cat   Json_Obj;
        l_Zip_Code      Json_Obj;
        l_Kaot_Id       NUMBER;
        l_Kaot_Code     VARCHAR2 (20);
    BEGIN
        l_Addr := NEW Json_Obj ();
        l_Addr.Push ('id', '');
        l_Addr.Push ('numBuild', p_Num_Build);
        l_Addr.Push ('blockBuild', p_Block_Build);
        l_Addr.Push ('appartment', p_Appartment);

        l_Addr.Push ('refStreet', '');
        l_Addr.Push ('refStreetType', Create_Id_Obj (p_Street_Type));
        l_Addr.Push ('streetName', p_Street_Name);

        l_Zip_Code :=
            Create_Zip_Code_Obj (p_Index          => p_Index,
                                 p_Com_Org        => p_Com_Org,
                                 p_Com_Org_Orig   => p_Com_Org_Orig,
                                 p_Kaot_Id        => l_Kaot_Id);
        l_Addr.Push ('refZipCode', l_Zip_Code);
        p_Kaot_Id := NVL (p_Kaot_Id, l_Kaot_Id);

        IF p_Kaot_Id IS NOT NULL
        THEN
            SELECT Kk.Kaot_Code
              INTO l_Kaot_Code
              FROM Uss_Ndi.v_Ndi_Katottg  k
                   JOIN Uss_Ndi.v_Ndi_Katottg Kk
                       --Постановка А.Гуменюк:
                       ON COALESCE (k.Kaot_Kaot_L5,
                                    k.Kaot_Kaot_L4,
                                    k.Kaot_Kaot_L3,
                                    k.Kaot_Kaot_L2,
                                    k.Kaot_Kaot_L1) = Kk.Kaot_Id
             WHERE k.Kaot_Id = p_Kaot_Id;
        END IF;

        l_Addr.Push ('katottgCode', l_Kaot_Code);
        l_Addr.Push ('refKOATUU', '');                     --#70242 l_Koatuu);

        l_Addr.Push ('start', '');
        l_Addr.Push ('expired', '');

        l_Address_Cat := NEW Json_Obj ();
        l_Address_Cat.Push ('id', p_Address_Cat);
        l_Addr.Push ('refAddressCategory', l_Address_Cat);
        RETURN l_Addr;
    END;

    ---------------------------------------------------------------------
    --   Отримання інформації про адресу учасника звернення
    ---------------------------------------------------------------------
    FUNCTION Get_Address_Data (p_App_Id         IN     NUMBER,
                               p_Com_Org        IN     NUMBER,
                               p_Com_Org_Orig   IN     NUMBER,
                               p_Kaot_Code         OUT VARCHAR2)
        RETURN Json_Arr
    IS
        l_Address_Data   Json_Arr;
        l_Address_Reg    Json_Obj;
        l_Address_Fact   Json_Obj;
        l_Kaot_Id        NUMBER;
    BEGIN
        l_Kaot_Id := Api$appeal.Get_Person_Attr_Val_Id (p_App_Id, 580);
        --АДРЕСА РЕЄСТРАЦІЇ
        l_Address_Reg :=
            Create_Address_Obj (
                p_Com_Org        => p_Com_Org,
                p_Com_Org_Orig   => p_Com_Org_Orig,
                p_Num_Build      =>
                    Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 584),
                p_Block_Build    =>
                    Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 583),
                p_Appartment     =>
                    Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 582),
                p_Street_Type    =>
                    Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 2303),
                p_Street_Name    =>
                    COALESCE (
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 787),
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 585)),
                p_Kaot_Id        => l_Kaot_Id,
                p_Index          =>
                    Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 587),
                p_Address_Cat    => 1);

        --Якщо адреса реєстрації співпадає з адресою проживання
        IF Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 592) = 'T'
        THEN
            l_Address_Fact :=
                Create_Address_Obj (
                    p_Com_Org        => p_Com_Org,
                    p_Com_Org_Orig   => p_Com_Org_Orig,
                    p_Num_Build      =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 584),
                    p_Block_Build    =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 583),
                    p_Appartment     =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 582),
                    p_Street_Type    =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 2303),
                    p_Street_Name    =>
                        COALESCE (
                            Api$appeal.Get_Person_Attr_Val_Str (p_App_Id,
                                                                787),
                            Api$appeal.Get_Person_Attr_Val_Str (p_App_Id,
                                                                585)),
                    p_Kaot_Id        => l_Kaot_Id,
                    p_Index          =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 587),
                    p_Address_Cat    => 2);
        ELSE
            l_Kaot_Id := Api$appeal.Get_Person_Attr_Val_Id (p_App_Id, 604);
            --АДРЕСА ПРОЖИВАННЯ
            l_Address_Fact :=
                Create_Address_Obj (
                    p_Com_Org        => p_Com_Org,
                    p_Com_Org_Orig   => p_Com_Org_Orig,
                    p_Num_Build      =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 596),
                    p_Block_Build    =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 595),
                    p_Appartment     =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 594),
                    p_Street_Type    =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 2304),
                    p_Street_Name    =>
                        COALESCE (
                            Api$appeal.Get_Person_Attr_Val_Str (p_App_Id,
                                                                788),
                            Api$appeal.Get_Person_Attr_Val_Str (p_App_Id,
                                                                597)),
                    p_Kaot_Id        => l_Kaot_Id,
                    p_Index          =>
                        Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 599),
                    p_Address_Cat    => 2);
        END IF;

        --Визначаємо код КАТОТТ тер. громади
        IF l_Kaot_Id IS NOT NULL
        THEN
            --#92481
            --Для Кієва та Севастополя виключення, тому що вони самі собі тер. громади і немають запиту L3
            IF l_Kaot_Id IN (31743, 31754)
            THEN
                SELECT MAX (k.Kaot_Code)
                  INTO p_Kaot_Code
                  FROM Uss_Ndi.v_Ndi_Katottg k
                 WHERE k.Kaot_Id = l_Kaot_Id;
            ELSE
                SELECT MAX (K3.Kaot_Code)
                  INTO p_Kaot_Code
                  FROM Uss_Ndi.v_Ndi_Katottg  k
                       JOIN Uss_Ndi.v_Ndi_Katottg K3
                           ON k.Kaot_Kaot_L3 = K3.Kaot_Id
                 WHERE k.Kaot_Id = l_Kaot_Id;

                IF p_Kaot_Code IS NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Не визначено КАТОТТГ для територіяльної громади');
                END IF;
            END IF;
        END IF;

        l_Address_Data := NEW Json_Arr ();
        l_Address_Data.Push (l_Address_Reg);
        l_Address_Data.Push (l_Address_Fact);

        RETURN l_Address_Data;
    END;

    FUNCTION Create_Doc_Obj (p_Doc_Number      VARCHAR2,
                             p_Ndt_Id          NUMBER,
                             p_Authority       VARCHAR2 DEFAULT NULL,
                             p_Start_Dt        DATE DEFAULT NULL,
                             p_Stop_Dt         DATE DEFAULT NULL,
                             p_Act_Num      IN VARCHAR2 DEFAULT NULL,
                             p_Act_Dt       IN DATE DEFAULT NULL,
                             p_Doc_Seria       VARCHAR2 DEFAULT NULL)
        RETURN Json_Obj
    IS
        l_Doc            Json_Obj;
        l_Ref_Doc_Type   Json_Obj;
        l_Doc_Seria      VARCHAR2 (10);
        l_Doc_Number     VARCHAR2 (20);
    BEGIN
        l_Doc := NEW Json_Obj ();
        l_Doc.Push ('id', '');

        l_Doc_Number := p_Doc_Number;
        Split_Doc_Number (p_Ndt_Id       => p_Ndt_Id,
                          p_Doc_Number   => l_Doc_Number,
                          p_Doc_Serial   => l_Doc_Seria);
        l_Doc.Push ('docSeria', NVL (p_Doc_Seria, l_Doc_Seria));
        l_Doc.Push ('docNumber', l_Doc_Number);
        l_Doc.Push ('authority', p_Authority);
        l_Doc.Push ('start', TO_CHAR (p_Start_Dt, c_Dt_Fmt));
        l_Doc.Push ('expired', TO_CHAR (p_Stop_Dt, c_Dt_Fmt));
        l_Doc.Push ('actNum', p_Act_Num);
        l_Doc.Push ('actDate', TO_CHAR (p_Act_Dt, c_Dt_Fmt));

        l_Ref_Doc_Type := NEW Json_Obj ();
        l_Ref_Doc_Type.Push (
            'id',
            NVL (TO_NUMBER (Uss_Ndi.Tools.Decode_Dict (
                                p_Nddc_Tp         => 'NDT_ID',
                                p_Nddc_Src        =>
                                    Api$appeal.c_Src_Vst,
                                p_Nddc_Dest       =>
                                    Api$appeal.c_Src_Community,
                                p_Nddc_Code_Src   => p_Ndt_Id)),
                 1151));                                 --1151=Інший документ
        --l_Ref_Doc_Type.Push('name', '');
        --l_Ref_Doc_Type.Push('template', '');
        --l_Ref_Doc_Type.Push('oldCode', '');
        --l_Ref_Doc_Type.Push('refProject', '');
        l_Doc.Push ('refDocType', l_Ref_Doc_Type);

        l_Doc.Push ('active', TRUE);
        l_Doc.Push ('unzr', '');

        RETURN l_Doc;
    END;

    ---------------------------------------------------------------------
    --   Отримання інформації про учасника звернення
    ---------------------------------------------------------------------
    FUNCTION Get_Person_Registry (p_App_Id IN NUMBER, p_Address_Data IN CLOB)
        RETURN Json_Obj
    IS
        l_Person_Registry   Json_Obj;
        l_Ref_Gender        Json_Obj;
        l_Ref_Nationality   Json_Obj;
        l_Person_Docs       Json_Arr;
    BEGIN
        l_Person_Registry := NEW Json_Obj ();
        l_Person_Registry.Push ('id', p_App_Id);
        l_Person_Registry.Push (
            'refusalItn',
            Str2bool (Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 640)));

        l_Person_Docs := NEW Json_Arr ();

        --ДОКУМЕНТИ ЩО ПОСВІДЧУЮТЬ ОСОБУ
        FOR Doc IN (SELECT d.Apd_Id,
                           d.Apd_Ndt,
                           --СЕРІЯ ТА НОМЕР ДОКУМЕНТ
                           CASE
                               WHEN Apd_Ndt IN (6,
                                                7,
                                                8,
                                                9,
                                                37)
                               THEN
                                   Api$appeal.Get_Attr_Val_String (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'DSN')
                           END    AS Doc_Number,
                           --ОРГАН ЩО ВИДАВ ДОКУМЕНТ
                           CASE
                               WHEN Apd_Ndt IN (6,
                                                7,
                                                8,
                                                9,
                                                37)
                               THEN
                                   Api$appeal.Get_Attr_Val_String (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'DORG')
                           END    AS Authority,
                           --ДАТА ВИДАЧІ ДОКУМЕНТА
                           CASE
                               WHEN Apd_Ndt IN (6,
                                                7,
                                                8,
                                                9,
                                                37)
                               THEN
                                   Api$appeal.Get_Attr_Val_Dt (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'DGVDT')
                           END    AS Start_Dt,
                           --ДОКУМЕНТ ДІЙСНИЙ ДО
                           CASE
                               WHEN Apd_Ndt IN (7, 8, 9)
                               THEN
                                   Api$appeal.Get_Attr_Val_Dt (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'DSPDT')
                           END    AS Stop_Dt,
                           --НОМЕР АКТОВОГО ЗАПИСУ
                           CASE
                               WHEN Apd_Ndt IN (37)
                               THEN
                                   Api$appeal.Get_Attr_Val_String (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'ARNUM')
                           END    AS Act_Num,
                           --ДАТА АКТОВОГО ЗАПИСУ
                           CASE
                               WHEN Apd_Ndt IN (37)
                               THEN
                                   Api$appeal.Get_Attr_Val_Dt (
                                       p_Apd_Id      => Apd_Id,
                                       p_Nda_Class   => 'ARDT')
                           END    AS Act_Dt,
                           --УНЗР
                           CASE
                               WHEN Apd_Ndt = 7
                               THEN
                                   Api$appeal.Get_Attr_Val_String (
                                       p_Apd_Id   => Apd_Id,
                                       p_Nda_Id   => 810)
                           END    AS Unzr
                      FROM Ap_Document d
                     WHERE     d.Apd_App = p_App_Id
                           AND d.History_Status = 'A'
                           AND d.Apd_Ndt IN (6,
                                             7,
                                             8,
                                             9,
                                             37))
        LOOP
            l_Person_Docs.Push (
                Create_Doc_Obj (
                    p_Doc_Number   => Doc.Doc_Number,
                    p_Ndt_Id       => Doc.Apd_Ndt,
                    p_Authority    => Doc.Authority,
                    p_Start_Dt     => Doc.Start_Dt,
                    p_Stop_Dt      => Doc.Stop_Dt,
                    p_Act_Num      => Doc.Act_Num,
                    p_Act_Dt       => Doc.Act_Dt,
                    p_Doc_Seria    =>
                        CASE
                            WHEN Doc.Apd_Ndt = 7 THEN REPLACE (Doc.Unzr, '-')
                        END));
        END LOOP;

        FOR Rec IN (SELECT p.App_Inn,
                           p.App_Fn,
                           p.App_Mn,
                           p.App_Ln,
                           p.App_Gender,
                           p.App_Doc_Num,
                           p.App_Ndt
                      FROM Ap_Person p
                     WHERE p.App_Id = p_App_Id)
        LOOP
            l_Person_Registry.Push ('name', Rec.App_Fn);
            l_Person_Registry.Push ('surname', Rec.App_Ln);
            l_Person_Registry.Push ('patronymic', Rec.App_Mn);
            l_Person_Registry.Push ('itn', Rec.App_Inn);

            l_Ref_Gender := NEW Json_Obj ();
            l_Ref_Gender.Push (
                'id',
                CASE
                    WHEN Rec.App_Gender = 'M' THEN 1
                    WHEN Rec.App_Gender = 'F' THEN 2
                    ELSE 1
                END);
            --l_Ref_Gender.Push('name', Rec.App_Gender_Name);
            l_Person_Registry.Push ('refGender', l_Ref_Gender);

            IF l_Person_Docs.COUNT = 0
            THEN
                l_Person_Docs.Push (
                    Create_Doc_Obj (p_Doc_Number   => Rec.App_Doc_Num,
                                    p_Ndt_Id       => Rec.App_Ndt));
            END IF;

            --#89070
            IF Rec.App_Ndt IN (6, 7) AND Rec.App_Doc_Num IS NOT NULL
            THEN
                l_Ref_Nationality := NEW Json_Obj ();
                l_Ref_Nationality.Push ('id', 0);
                l_Ref_Nationality.Push ('name', 'громадянин України');

                l_Person_Registry.Push ('refNationality', l_Ref_Nationality);
            ELSE
                l_Person_Registry.Push ('refNationality', '');
            END IF;
        END LOOP;

        l_Person_Registry.Push (
            'birth',
            --#73812
            COALESCE (
                TO_CHAR (Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id, 667),
                         c_Dt_Fmt),
                TO_CHAR (Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id, 606),
                         c_Dt_Fmt),
                TO_CHAR (Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id, 607),
                         c_Dt_Fmt),
                TO_CHAR (Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id, 91),
                         c_Dt_Fmt)));
        l_Person_Registry.Push ('death', '');
        l_Person_Registry.Push (
            'addrSame',
            Str2bool (Api$appeal.Get_Person_Attr_Val_Str (p_App_Id, 592)));
        l_Person_Registry.Push ('dscentrSerial', '');
        l_Person_Registry.Push ('dspersonSerial', '');

        l_Person_Registry.Push_Arr ('personDocs', l_Person_Docs.TO_CLOB);

        l_Person_Registry.Push_Arr ('addressData', p_Address_Data);

        RETURN l_Person_Registry;
    END;

    FUNCTION Get_Fam_Relation (p_App_Id NUMBER)
        RETURN Json_Obj
    IS
        l_Ref_Fam_Relation   Json_Obj;
    BEGIN
        l_Ref_Fam_Relation := NEW Json_Obj ();
        l_Ref_Fam_Relation.Push ('id',
                                 TO_NUMBER (Uss_Ndi.Tools.Decode_Dict (
                                                p_Nddc_Tp   => 'REL_TP',
                                                p_Nddc_Src   =>
                                                    Api$appeal.c_Src_Vst,
                                                p_Nddc_Dest   =>
                                                    Api$appeal.c_Src_Community,
                                                p_Nddc_Code_Src   =>
                                                    Api$appeal.Get_Person_Attr_Val_Str (
                                                        p_App_Id,
                                                        649))));

        RETURN l_Ref_Fam_Relation;
    END;

    ---------------------------------------------------------------------
    --   Отримання інформації про допомоги у зверненні
    ---------------------------------------------------------------------
    FUNCTION Get_Aids (p_Ap_Id          IN NUMBER,
                       p_Ap_Is_Second   IN VARCHAR2,
                       p_Applicant_Id   IN NUMBER)
        RETURN Json_Arr
    IS
        l_Aids            Json_Arr;
        l_Aid             Json_Obj;
        l_Ref_Aid         Json_Obj;
        l_Ref_Aid_Id      NUMBER;
        l_Aid_Documents   Json_Arr;
        l_Aid_Persons     Json_Arr;
    BEGIN
        l_Aids := NEW Json_Arr ();
        l_Aid := NEW Json_Obj ();
        l_Aid.Push ('id', p_Ap_Id);
        l_Aid.Push ('accountNumber', '');
        l_Aid.Push ('appealType', Str2bool (p_Ap_Is_Second));
        l_Aid.Push (
            'appealTypeText',
            CASE
                WHEN p_Ap_Is_Second = 'T' THEN 'повторне'
                ELSE 'первинне'
            END);
        l_Aid.Push ('addAttrPerson', '');

        l_Aid.Push (
            'addAttrMarried',
            CASE
                WHEN Api$appeal.Get_Person_Attr_Val_Str (p_Applicant_Id,
                                                         '669') =
                     'T'
                THEN
                    1
                WHEN Api$appeal.Get_Person_Attr_Val_Str (p_Applicant_Id,
                                                         '670') =
                     'T'
                THEN
                    2
                WHEN Api$appeal.Get_Person_Attr_Val_Str (p_Applicant_Id,
                                                         '671') =
                     'T'
                THEN
                    3
            END);
        l_Aid.Push (
            'addAttrTogether',
            CASE
                WHEN Api$appeal.Get_Person_Attr_Val_Str (p_Applicant_Id,
                                                         '672') =
                     'T'
                THEN
                    1
                ELSE
                    2
            END);
        l_Aid.Push (
            'addAttrPension',
            CASE
                WHEN Api$appeal.Get_Person_Attr_Val_Str (p_Applicant_Id,
                                                         '673') =
                     'T'
                THEN
                    1
                ELSE
                    2
            END);
        l_Aid.Push ('recipientAddr', '');
        l_Aid.Push ('pensionDeptName', '');
        l_Aid.Push ('pensionNum', '');
        l_Aid.Push ('catReciever', '');
        l_Aid.Push ('matHospital', '');
        l_Aid.Push ('dateDecision', '');
        l_Aid.Push ('decision', '');
        l_Aid.Push ('dateStart', '');
        l_Aid.Push ('dateEnd', '');
        l_Aid.Push ('sum', '');
        l_Aid.Push ('datResponse', '');
        l_Aid.Push ('refRefusingReason', '');
        l_Aid.Push ('decisionText', '');

        l_Ref_Aid := NEW Json_Obj ();

        --ПОСЛУГА
        SELECT Uss_Ndi.Tools.Decode_Dict (
                   p_Nddc_Tp         => 'NST_ID',
                   p_Nddc_Src        => Api$appeal.c_Src_Vst,
                   p_Nddc_Dest       => Api$appeal.c_Src_Community,
                   p_Nddc_Code_Src   => s.Aps_Nst)
          INTO l_Ref_Aid_Id
          FROM Ap_Service s
         WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A';

        l_Ref_Aid.Push ('id', l_Ref_Aid_Id);
        l_Aid.Push ('refAid', l_Ref_Aid);

        --ДОКУМЕНТИ
        l_Aid_Documents := NEW Json_Arr ();

        FOR Rec
            IN (SELECT d.Apd_Id,
                       d.Apd_Ndt,
                       d.Apd_App,
                       d.Apd_Dh
                  FROM Ap_Document d
                 WHERE     d.Apd_Ap = p_Ap_Id
                       AND d.History_Status = 'A'
                       AND EXISTS
                               (SELECT 1
                                  FROM Uss_Doc.v_Doc_Attachments  a
                                       JOIN Uss_Doc.v_Files f
                                           ON a.Dat_File = f.File_Id
                                 WHERE a.Dat_Dh = d.Apd_Dh))
        LOOP
            DECLARE
                l_Aid_Doc           Json_Obj;
                l_Person_Registry   Json_Obj;
                l_Ref_Doc_Type      Json_Obj;
                l_Aid_Doc_Scans     Json_Arr;
            BEGIN
                l_Aid_Doc := NEW Json_Obj ();
                l_Aid_Doc.Push ('id', Rec.Apd_Id);            --todo: уточнити

                l_Ref_Doc_Type := NEW Json_Obj ();
                l_Ref_Doc_Type.Push ('id',
                                     NVL (TO_NUMBER (Uss_Ndi.Tools.Decode_Dict (
                                                         p_Nddc_Tp   =>
                                                             'NDT4AID',
                                                         p_Nddc_Src   =>
                                                             Api$appeal.c_Src_Vst,
                                                         p_Nddc_Dest   =>
                                                             Api$appeal.c_Src_Community,
                                                         p_Nddc_Code_Src   =>
                                                             Rec.Apd_Ndt)),
                                          1151));
                l_Aid_Doc.Push ('refDocType', l_Ref_Doc_Type);

                l_Person_Registry := NEW Json_Obj ();
                l_Person_Registry.Push ('id', Rec.Apd_App);
                l_Aid_Doc.Push ('personRegistry', l_Person_Registry);

                --ВКЛАДЕННЯ ДОКУМЕНТУ
                l_Aid_Doc_Scans := NEW Json_Arr ();

                FOR Scan
                    IN (SELECT f.File_Code,
                               f.File_Name,
                               Fs.File_Code     AS File_Sign_Code
                          FROM Uss_Doc.v_Doc_Attachments  a
                               JOIN Uss_Doc.v_Files f
                                   ON a.Dat_File = f.File_Id
                               LEFT JOIN Uss_Doc.v_Files Fs
                                   ON a.Dat_Sign_File = Fs.File_Id
                         WHERE a.Dat_Dh = Rec.Apd_Dh)
                LOOP
                    DECLARE
                        l_Scan   Json_Obj;
                    BEGIN
                        l_Scan := NEW Json_Obj ();
                        l_Scan.Push ('id', '');
                        l_Scan.Push ('aidDocument', '');
                        l_Scan.Push ('scanFile', Scan.File_Name);

                        l_Scan.Push ('docPicEncoded', '');
                        l_Scan.Push ('docCode', Scan.File_Code);

                        l_Scan.Push ('docSignEncoded', '');
                        l_Scan.Push ('docSignCode', Scan.File_Sign_Code);

                        l_Aid_Doc_Scans.Push (l_Scan);
                    END;
                END LOOP;

                l_Aid_Doc.Push_Arr ('aidDocScans', l_Aid_Doc_Scans.TO_CLOB);

                l_Aid_Documents.Push (l_Aid_Doc);
            END;
        END LOOP;

        l_Aid.Push_Arr ('aidDocuments', l_Aid_Documents.TO_CLOB);

        --УЧАСНИКИ ЗВЕРНЕННЯ
        l_Aid_Persons := NEW Json_Arr ();

        FOR Rec IN (SELECT p.App_Id
                      FROM Ap_Person p
                     WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A')
        LOOP
            DECLARE
                l_Aid_Person        Json_Obj;
                l_Person_Registry   Json_Obj;
            BEGIN
                l_Aid_Person := NEW Json_Obj ();
                --TODO: з’ясувати в якому полі передавати ІД та чи потрібно передавати усі інщі поля
                l_Aid_Person.Push ('id', '');

                l_Person_Registry := NEW Json_Obj ();
                l_Person_Registry.Push ('id', Rec.App_Id);
                l_Aid_Person.Push ('personRegistry', l_Person_Registry);

                l_Aid_Person.Push ('refFamRelation',
                                   Get_Fam_Relation (p_App_Id => Rec.App_Id));

                l_Aid_Person.Push ('fullDocPackage', TRUE);
                l_Aid_Person.Push ('lastDoc', '');
                l_Aid_Person.Push ('onlyForDeclaration', FALSE);
                l_Aid_Persons.Push (l_Aid_Person);
            END;
        END LOOP;

        l_Aid.Push_Arr ('aidPersons', l_Aid_Persons.TO_CLOB);
        l_Aids.Push (l_Aid);
        RETURN l_Aids;
    END;

    ---------------------------------------------------------------------
    --   Отримання дати усиновлення/встановлення опіки
    ---------------------------------------------------------------------
    /*FUNCTION Get_Addoption_Dt(p_App_Id_z IN NUMBER,
                              p_App_Pib  IN VARCHAR2) RETURN DATE IS
      l_Adoption_Dt DATE;
    BEGIN
      --ДАТА ВСИНОВЛЕННЯ
      SELECT MAX(a.Apda_Val_Dt)
        INTO l_Adoption_Dt
        FROM Ap_Document d
      --Атрибут "Дата усиновлення"
        JOIN Ap_Document_Attr a
          ON d.Apd_Id = a.Apda_Apd
         AND a.History_Status = 'A'
         AND a.Apda_Nda IN (708, 715)
      --Атрибут "ПІБ дитини"
        LEFT JOIN Ap_Document_Attr p
          ON d.Apd_Id = p.Apda_Apd
         AND p.History_Status = 'A'
         AND p.Apda_Nda IN (709, 716)
      --Дата усиновлення вичитується з одного з документів що прикріплені до заявника, а не до дитини
       WHERE d.Apd_App = p_App_Id_z
         AND d.Apd_Ndt IN (660, 114)
         AND d.History_Status = 'A'
         AND (Upper(p.Apda_Val_String) = Upper(p_App_Pib) OR p.Apda_Val_String IS NULL);

      RETURN Coalesce(l_Adoption_Dt,
                      Api$appeal.Get_Person_Attr_Val_Dt(p_App_Id_z, 774),
                      Api$appeal.Get_Person_Attr_Val_Dt(p_App_Id_z, 722),
                      Api$appeal.Get_Person_Attr_Val_Dt(p_App_Id_z, 729));
    END;*/


    ---------------------------------------------------------------------
    --   Отримання інформації про учасників звернення
    ---------------------------------------------------------------------
    FUNCTION Get_Related_Persons (p_Ap_Id IN NUMBER--p_App_Id_z IN NUMBER
                                                   )
        RETURN Json_Arr
    IS
        l_Related_Persons   Json_Arr;
    BEGIN
        l_Related_Persons := NEW Json_Arr ();

        FOR Rec
            IN (SELECT p.App_Id,
                       p.App_Ln,
                       p.App_Fn,
                       p.App_Mn
                  FROM Ap_Person p
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.App_Tp <> 'Z'
                       AND p.History_Status = 'A')
        LOOP
            DECLARE
                l_Person         Json_Obj;
                l_Birth_Dt       DATE;
                l_Age            NUMBER;
                l_Work_Ability   NUMBER;
                l_Curator        BOOLEAN;
            /*l_Ref_Disability_Gr Json_Obj;
            l_Disability_Gr     VARCHAR2(10);
            l_Disability_Sub_Gr VARCHAR2(10);
            l_Disability_Reason VARCHAR2(10);
            l_Disability_St     VARCHAR2(10);
            l_Disability_Gr_Id  NUMBER;*/
            BEGIN
                l_Person := NEW Json_Obj ();
                l_Person.Push ('id', Rec.App_Id);
                l_Person.Push ('personMain', '');
                l_Person.Push (
                    'personRelated',
                    Get_Person_Registry (Rec.App_Id, p_Address_Data => '[]'));

                --#89225
                IF Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id, 684) = 'T'
                THEN
                    l_Person.Push ('addAttribute', 1);
                END IF;

                --СТУПІНЬ РОДИННОГО ЗВЯЗКУ
                l_Person.Push ('refFamRelation',
                               Get_Fam_Relation (p_App_Id => Rec.App_Id));

                l_Person.Push ('persNumber', '');
                l_Person.Push ('householdMember', '');
                l_Person.Push (
                    'marriedStatus',
                    CASE
                        WHEN Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id,
                                                                 827) =
                             'T'
                        THEN
                            0
                        WHEN Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id,
                                                                 828) =
                             'T'
                        THEN
                            1
                        WHEN Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id,
                                                                 674) =
                             'T'
                        THEN
                            2
                        WHEN Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id,
                                                                 829) =
                             'T'
                        THEN
                            3
                    END);
                l_Person.Push ('paymentOff', '');

                --ВИЗНАЧАЄМО ВІК АБО ПРАЗДАТНІСТЬ
                l_Birth_Dt :=
                    COALESCE (
                        Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id, 91),
                        Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id, 606),
                        Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id, 607));

                IF l_Birth_Dt IS NOT NULL
                THEN
                    l_Age :=
                        FLOOR (
                            MONTHS_BETWEEN (TRUNC (SYSDATE), l_Birth_Dt) / 12);

                    IF l_Age < 18
                    THEN
                        l_Work_Ability := 0;
                    ELSE
                        l_Work_Ability :=
                            CASE
                                WHEN Api$appeal.Get_Person_Attr_Val_Str (
                                         Rec.App_Id,
                                         665) =
                                     'T'
                                THEN
                                    1
                                WHEN Api$appeal.Get_Person_Attr_Val_Str (
                                         Rec.App_Id,
                                         664) =
                                     'T'
                                THEN
                                    2
                            END;
                    END IF;
                END IF;

                l_Person.Push ('workAbility', l_Work_Ability);

                l_Curator :=
                    Str2bool (
                        NVL (
                            Api$appeal.Get_Person_Attr_Val_Str (Rec.App_Id,
                                                                642),
                            'F'));
                l_Person.Push ('curator', l_Curator);

                l_Person.Push (
                    'adoptionDate',
                    TO_CHAR (
                        COALESCE (
                            Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id,
                                                               708),
                            Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id,
                                                               715),
                            Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id,
                                                               774),
                            Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id,
                                                               722),
                            Api$appeal.Get_Person_Attr_Val_Dt (Rec.App_Id,
                                                               729)),
                        'yyyy-mm-dd'));
                --To_Char(Get_Addoption_Dt(p_App_Id_z, Rec.App_Ln || ' ' || Rec.App_Fn || ' ' || Rec.App_Mn), 'yyyy-mm-dd'));

                --30.11.2023: за узгодженням з О.Феофановою інформації про інвалідність в СГ не потрібна
                --ГРУПА ІНВАЛІДНОСТІ
                /*l_Ref_Disability_Gr := NEW Json_Obj();
                l_Disability_Gr := Api$appeal.Get_Person_Attr_Val_Str(Rec.App_Id, 666);
                IF l_Disability_Gr IS NOT NULL THEN
                  l_Disability_Sub_Gr := Api$appeal.Get_Person_Attr_Val_Str(Rec.App_Id, 869);
                  l_Disability_St := Api$appeal.Get_Person_Attr_Val_Str(Rec.App_Id, 796);
                  l_Disability_Reason := Api$appeal.Get_Person_Attr_Val_Str(Rec.App_Id, 795);
                  l_Disability_Gr_Id := CASE
                                          WHEN l_Disability_Gr = '1'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Reason IN ('V1', 'V2', 'V3') THEN
                                           4
                                          WHEN l_Disability_Gr = '1'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Reason = 'MD' THEN
                                           6
                                          WHEN l_Disability_Gr = '1'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Sub_Gr = 'B' THEN
                                           9
                                          WHEN l_Disability_Gr = '1'
                                               AND l_Disability_St = 'I' THEN
                                           1
                                        --
                                          WHEN l_Disability_Gr = '2'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Reason IN ('R0', 'R1') THEN
                                           10
                                          WHEN l_Disability_Gr = '2'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Reason = 'MD' THEN
                                           7
                                          WHEN l_Disability_Gr = '2'
                                               AND l_Disability_St = 'I'
                                               AND l_Disability_Sub_Gr = 'A' THEN
                                           8
                                          WHEN l_Disability_Gr = '2'
                                               AND l_Disability_St = 'I' THEN
                                           2
                                        --
                                          WHEN l_Disability_Gr = '3'
                                               AND l_Disability_St = 'I' THEN
                                           3
                                        --
                                          WHEN l_Disability_St = 'DI' THEN
                                           5
                                        END;
                  l_Ref_Disability_Gr.Push('id', l_Disability_Gr_Id);
                  l_Person.Push('refDisabilityGroup', l_Ref_Disability_Gr);
                END IF;*/

                l_Person.Push ('noteSubs', '');
                l_Related_Persons.Push (l_Person);
            END;
        END LOOP;

        RETURN l_Related_Persons;
    END;

    ---------------------------------------------------------------------
    --   Отримання інформації про способи виплат
    ---------------------------------------------------------------------
    FUNCTION Get_Payment_Detail (p_Ap_Id          IN NUMBER,
                                 p_Com_Org        IN NUMBER,
                                 p_Com_Org_Orig   IN NUMBER)
        RETURN Json_Obj
    IS
        l_Payment_Detail   Json_Obj;
    BEGIN
        l_Payment_Detail := NEW Json_Obj ();
        l_Payment_Detail.Push ('id', '');
        l_Payment_Detail.Push ('bankName', '');

        FOR Rec
            IN (SELECT DECODE (p.Apm_Tp,  'POST', 1,  'BANK', 2)
                           AS Pay_Method_Id,
                       p.Apm_Index,
                       p.Apm_Account,
                       b.Nb_Mfo,
                       b.Nb_Edrpou
                  FROM Ap_Payment  p
                       LEFT JOIN Uss_Ndi.v_Ndi_Bank b ON p.Apm_Nb = b.Nb_Id
                 WHERE p.Apm_Ap = p_Ap_Id AND p.History_Status = 'A')
        LOOP
            DECLARE
                l_Ref_Pay_Method   Json_Obj;
                l_Ref_Zip_Code     Json_Obj;
                l_Ref_Bank         Json_Obj;
                l_Kaot_Id          NUMBER;
            BEGIN
                l_Ref_Pay_Method := NEW Json_Obj ();
                l_Ref_Pay_Method.Push ('id', Rec.Pay_Method_Id);
                l_Payment_Detail.Push ('refPayMethod', l_Ref_Pay_Method);

                IF Rec.Pay_Method_Id = 1
                THEN
                    l_Ref_Zip_Code :=
                        Create_Zip_Code_Obj (
                            p_Index          => Rec.Apm_Index,
                            p_Com_Org        => p_Com_Org,
                            p_Com_Org_Orig   => p_Com_Org_Orig,
                            p_Kaot_Id        => l_Kaot_Id);
                    l_Payment_Detail.Push ('refZipCode', l_Ref_Zip_Code);
                ELSE
                    l_Payment_Detail.Push ('refZipCode', '');
                END IF;

                l_Payment_Detail.Push ('currentAccount', Rec.Apm_Account);

                IF Rec.Pay_Method_Id IS NOT NULL
                THEN
                    l_Ref_Bank := NEW Json_Obj ();
                    l_Ref_Bank.Push ('mfo', Rec.Nb_Mfo);
                    --l_Ref_Bank.Push('ikod', Rec.Nb_Edrpou);
                    l_Payment_Detail.Push ('refBank', l_Ref_Bank);
                ELSE
                    l_Payment_Detail.Push ('refBank', '');
                END IF;
            END;
        END LOOP;

        RETURN l_Payment_Detail;
    END;

    ---------------------------------------------------------------------
    --   Отримання інформації з деларації
    ---------------------------------------------------------------------
    FUNCTION Get_Declaration (p_Ap_Id IN NUMBER)
        RETURN Json_Obj
    IS
        l_Declaration        Json_Obj;
        l_Incomes            Json_Arr;
        l_Apartments         Json_Arr;
        l_Autos              Json_Arr;
        l_Properties         Json_Arr;
        l_Poslugas           Json_Arr;
        l_Sub_Add_Info_Set   Json_Arr;
    BEGIN
        l_Declaration := NEW Json_Obj ();

        FOR Rec IN (SELECT d.Apr_Id, d.Apr_Start_Dt, d.Apr_Stop_Dt
                      FROM Ap_Declaration d
                     WHERE d.Apr_Ap = p_Ap_Id)
        LOOP
            l_Declaration.Push ('id', Rec.Apr_Id);
            l_Declaration.Push ('dateStart',
                                TO_CHAR (Rec.Apr_Start_Dt, c_Dt_Fmt));
            l_Declaration.Push ('dateEnd',
                                TO_CHAR (Rec.Apr_Stop_Dt, c_Dt_Fmt));

            l_Incomes := NEW Json_Arr ();

            --ДОХОДИ
            FOR Inc
                IN (SELECT i.Apri_Id,
                           p.Aprp_App,
                           i.Apri_Tp,
                           i.Apri_Sum,
                           i.Apri_Source
                      FROM Apr_Income  i
                           JOIN Apr_Person p ON i.Apri_Aprp = p.Aprp_Id
                     WHERE i.Apri_Apr = Rec.Apr_Id AND i.History_Status = 'A')
            LOOP
                DECLARE
                    l_Income   Json_Obj;
                BEGIN
                    l_Income := NEW Json_Obj ();
                    l_Income.Push ('id', Inc.Apri_Id);
                    l_Income.Push ('personRegistry',
                                   Create_Id_Obj (Inc.Aprp_App));
                    l_Income.Push ('dateStart', '');
                    l_Income.Push ('dateEnd', '');
                    l_Income.Push ('refIncome',
                                   Create_Id_Obj (Uss_Ndi.Tools.Decode_Dict (
                                                      p_Nddc_Tp   => 'APRI_TP',
                                                      p_Nddc_Src   =>
                                                          Api$appeal.c_Src_Vst,
                                                      p_Nddc_Dest   =>
                                                          Api$appeal.c_Src_Community,
                                                      p_Nddc_Code_Src   =>
                                                          Inc.Apri_Tp)));

                    l_Income.Push ('sum', Sum2char (Inc.Apri_Sum));
                    l_Income.Push ('enterpriseCode', '');
                    l_Income.Push ('enterpriseName', Inc.Apri_Source);
                    l_Income.Push ('refUnemploymentReason', '');
                    l_Incomes.Push (l_Income);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('incomes', l_Incomes.TO_CLOB);

            --ЖИТЛОВІ ПРИМІЩЕННЯ
            l_Apartments := NEW Json_Arr ();

            FOR Apr
                IN (SELECT q.Aprl_Id,
                           p.Aprp_App,
                           q.Aprl_Area,
                           q.Aprl_Qnt,
                           q.Aprl_Address
                      FROM Apr_Living_Quarters  q
                           JOIN Apr_Person p ON q.Aprl_Aprp = p.Aprp_Id
                     WHERE q.Aprl_Apr = Rec.Apr_Id AND q.History_Status = 'A')
            LOOP
                DECLARE
                    l_Apartment   Json_Obj;
                BEGIN
                    l_Apartment := NEW Json_Obj ();
                    l_Apartment.Push ('id', Apr.Aprl_Id);
                    l_Apartment.Push ('personRegistry',
                                      Create_Id_Obj (Apr.Aprp_App));
                    l_Apartment.Push ('square', Apr.Aprl_Area);
                    l_Apartment.Push ('personCount', Apr.Aprl_Qnt);
                    l_Apartment.Push ('address', Apr.Aprl_Address);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('apartments', l_Apartments.TO_CLOB);

            --ТРАНСПОРТНІ ЗАСОБИ
            l_Autos := NEW Json_Arr ();

            FOR Auto
                IN (SELECT v.Aprv_Id,
                           p.Aprp_App,
                           v.Aprv_Car_Brand,
                           v.Aprv_License_Plate,
                           v.Aprv_Production_Year,
                           v.Aprv_Is_Social_Car,
                           b.Dic_Name     AS Aprv_Is_Social_Car_Text
                      FROM Apr_Vehicle  v
                           JOIN Apr_Person p ON v.Aprv_Aprp = p.Aprp_Id
                           JOIN Uss_Ndi.v_Ddn_Boolean b
                               ON v.Aprv_Is_Social_Car = b.Dic_Value
                     WHERE v.Aprv_Apr = Rec.Apr_Id AND v.History_Status = 'A')
            LOOP
                DECLARE
                    l_Auto   Json_Obj;
                BEGIN
                    l_Auto := NEW Json_Obj ();
                    l_Auto.Push ('id', Auto.Aprv_Id);
                    l_Auto.Push ('personRegistry',
                                 Create_Id_Obj (Auto.Aprp_App));
                    l_Auto.Push ('brand',
                                 SUBSTR (Auto.Aprv_Car_Brand, 1, 20));
                    l_Auto.Push ('plate',
                                 SUBSTR (Auto.Aprv_License_Plate, 1, 8));
                    l_Auto.Push ('yearManufactured',
                                 Auto.Aprv_Production_Year);
                    l_Auto.Push ('granted',
                                 Str2bool (Auto.Aprv_Is_Social_Car));
                    l_Auto.Push ('fosterParentBuy',
                                 Str2bool (Auto.Aprv_Is_Social_Car));
                    l_Auto.Push ('grantedText', Auto.Aprv_Is_Social_Car_Text);
                    l_Autos.Push (l_Auto);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('autos', l_Autos.TO_CLOB);

            --ЗЕМЕЛЬНІ ДІЛЯНКИ(Дія не передає)
            l_Declaration.Push_Arr ('lands', '[]');

            --ДОДАТКОВІ ДЖЕРЕЛА ІСНУВАННЯ(Дія не передає)
            l_Declaration.Push_Arr ('addExistenceSrcs', '[]');

            --ВИТРАТИ
            l_Properties := NEW Json_Arr ();

            FOR Prop
                IN (SELECT s.Aprs_Id,
                           p.Aprp_App,
                           s.Aprs_Tp,
                           s.Aprs_Cost,
                           s.Aprs_Dt
                      FROM Apr_Spending  s
                           JOIN Apr_Person p ON s.Aprs_Aprp = p.Aprp_Id
                     WHERE     s.Aprs_Apr = Rec.Apr_Id
                           AND s.History_Status = 'A'
                           AND s.Aprs_Tp IN ('ML',
                                             'MF',
                                             'MA',
                                             'MB',
                                             'MT',
                                             'MM'))
            LOOP
                DECLARE
                    l_Prop   Json_Obj;
                BEGIN
                    l_Prop := NEW Json_Obj ();
                    l_Prop.Push ('id', Prop.Aprs_Id);
                    l_Prop.Push ('personRegistry',
                                 Create_Id_Obj (Prop.Aprp_App));
                    l_Prop.Push ('refPropertyType',
                                 Create_Id_Obj (Uss_Ndi.Tools.Decode_Dict (
                                                    p_Nddc_Tp   => 'APRS_TP',
                                                    p_Nddc_Src   =>
                                                        Api$appeal.c_Src_Vst,
                                                    p_Nddc_Dest   =>
                                                        Api$appeal.c_Src_Community,
                                                    p_Nddc_Code_Src   =>
                                                        Prop.Aprs_Tp)));
                    l_Prop.Push ('sum', Sum2char (Prop.Aprs_Cost));
                    l_Prop.Push ('date', TO_CHAR (Prop.Aprs_Dt, c_Dt_Fmt));
                    l_Properties.Push (l_Prop);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('properties', l_Properties.TO_CLOB);

            --ВИТРАТИ(ПОСЛУГИ)
            l_Poslugas := NEW Json_Arr ();

            FOR Posl
                IN (SELECT s.Aprs_Id,
                           p.Aprp_App,
                           s.Aprs_Tp,
                           s.Aprs_Cost,
                           s.Aprs_Dt
                      FROM Apr_Spending  s
                           JOIN Apr_Person p ON s.Aprs_Aprp = p.Aprp_Id
                     WHERE     s.Aprs_Apr = Rec.Apr_Id
                           AND s.History_Status = 'A'
                           AND s.Aprs_Tp IN ('PR',
                                             'PA',
                                             'PS',
                                             'PE',
                                             'PP'))
            LOOP
                DECLARE
                    l_Posl   Json_Obj;
                BEGIN
                    l_Posl := NEW Json_Obj ();
                    l_Posl.Push ('id', Posl.Aprs_Id);
                    l_Posl.Push ('personRegistry',
                                 Create_Id_Obj (Posl.Aprp_App));
                    l_Posl.Push ('refPosluga',
                                 Create_Id_Obj (Uss_Ndi.Tools.Decode_Dict (
                                                    p_Nddc_Tp   => 'APRS_TP',
                                                    p_Nddc_Src   =>
                                                        Api$appeal.c_Src_Vst,
                                                    p_Nddc_Dest   =>
                                                        Api$appeal.c_Src_Community,
                                                    p_Nddc_Code_Src   =>
                                                        Posl.Aprs_Tp)));
                    l_Posl.Push ('sum', Sum2char (Posl.Aprs_Cost));
                    l_Posl.Push ('date', TO_CHAR (Posl.Aprs_Dt, c_Dt_Fmt));
                    l_Poslugas.Push (l_Posl);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('poslugas', l_Poslugas.TO_CLOB);

            l_Declaration.Push_Arr ('abroad', '[]');
            l_Declaration.Push_Arr ('purchases', '[]');
            l_Declaration.Push_Arr ('currencies', '[]');
            l_Declaration.Push_Arr ('deposits', '[]');
            l_Declaration.Push_Arr ('alimonies', '[]');

            l_Sub_Add_Info_Set := NEW Json_Arr ();

            FOR Per
                IN (SELECT p.Aprp_App, d.Apd_Id
                      FROM Apr_Person  p
                           JOIN Ap_Document d
                               ON     p.Aprp_App = d.Apd_App
                                  AND d.Apd_Ndt = 605
                                  AND d.History_Status = 'A'
                     WHERE     p.Aprp_Apr = Rec.Apr_Id
                           AND p.History_Status = 'A'
                           AND p.Aprp_Notes IS NOT NULL)
            LOOP
                DECLARE
                    l_Person_Ankt_Flags   Json_Obj;
                    l_Flags               Json_Arr;
                BEGIN
                    l_Person_Ankt_Flags :=
                        Create_Id_Obj (TO_NUMBER (Per.Aprp_App));
                    l_Person_Ankt_Flags.Push (
                        'personRegistry',
                        Create_Id_Obj (TO_NUMBER (Per.Aprp_App)));
                    l_Flags := Json_Arr ();

                    FOR Attr IN (SELECT a.Apda_Nda
                                   FROM Ap_Document_Attr a
                                  WHERE a.Apda_Apd = Per.Apd_Id)
                    LOOP
                        DECLARE
                            l_Flag      Json_Obj;
                            l_Flag_Id   NUMBER;
                        BEGIN
                            l_Flag := Create_Id_Obj (NULL);
                            l_Flag_Id :=
                                TO_NUMBER (Uss_Ndi.Tools.Decode_Dict_Reverse (
                                               p_Nddc_Tp     => 'NDA_ID',
                                               p_Nddc_Src    => 'DIIA',
                                               p_Nddc_Dest   => 'VST',
                                               p_Nddc_Code_Dest   =>
                                                   Attr.Apda_Nda));

                            IF l_Flag_Id IS NULL
                            THEN
                                CONTINUE;
                            END IF;

                            l_Flag.Push ('refRefItem',
                                         Create_Id_Obj (l_Flag_Id));
                            l_Flags.Push (l_Flag);
                        END;
                    END LOOP;

                    l_Person_Ankt_Flags.Push_Arr ('itemSet', l_Flags.TO_CLOB);
                    l_Sub_Add_Info_Set.Push (l_Person_Ankt_Flags);
                END;
            END LOOP;

            l_Declaration.Push_Arr ('subAddInfoSet',
                                    l_Sub_Add_Info_Set.TO_CLOB);

            l_Declaration.Push_Arr ('houses', '[]');
        END LOOP;

        RETURN l_Declaration;
    END;

    FUNCTION Get_Aps_Nst (p_Ap_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Aps_Nst   NUMBER;
    BEGIN
        SELECT s.Aps_Nst
          INTO l_Aps_Nst
          FROM Ap_Service s
         WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A';

        RETURN l_Aps_Nst;
    END;

    ---------------------------------------------------------------------
    --   Отримання метаданих звернення для передачі до соцгромади
    ---------------------------------------------------------------------
    FUNCTION Get_Statement (p_Ap_Id IN NUMBER, p_Com_Org IN NUMBER)
        RETURN CLOB
    IS
        l_Aps_Nst         NUMBER;
        l_Result          Json_Obj;
        l_Applicant_Id    NUMBER;
        l_Ap_Is_Second    Appeal.Ap_Is_Second%TYPE;
        l_Com_Org         NUMBER;
        l_Kaot_Code       VARCHAR2 (20);
        l_Ref_Community   Json_Obj;
    BEGIN
        l_Aps_Nst := Get_Aps_Nst (p_Ap_Id);

        l_Result := NEW Json_Obj ();
        l_Result.Push ('id', p_Ap_Id);
        l_Result.Push ('number', '');
        l_Result.Push ('savingDB', '');
        l_Result.Push ('assignOverSquare', '');
        l_Result.Push ('subsType', '');
        l_Result.Push ('declNumb', '');
        l_Result.Push ('floorCount', '');
        l_Result.Push ('squareTotal', '');
        l_Result.Push ('squareHeated', '');
        l_Result.Push ('rented', '');
        l_Result.Push ('ownership', '');
        l_Result.Push ('rentStart', '');
        l_Result.Push ('rentEnd', '');
        l_Result.Push ('subsDecisionDate', '');
        l_Result.Push ('subsDecision', '');
        l_Result.Push ('subsStart', '');
        l_Result.Push ('subsEnd', '');
        l_Result.Push ('subsSumGKP', '');
        l_Result.Push ('subsSumSGTP', '');
        l_Result.Push ('subsAppNum', '');
        l_Result.Push ('subsPaymentType', '');
        l_Result.Push ('fullDocPackage', 1);
        l_Result.Push ('pension', FALSE);
        l_Result.Push ('pensionDocSer', '');
        l_Result.Push ('pensionDocNum', '');
        l_Result.Push ('pensionDocDate', '');
        l_Result.Push ('pilgaCardNum', '');
        l_Result.Push ('pilgaDecisionDate', '');
        l_Result.Push ('pilgaDecision', '');
        l_Result.Push ('pilgaCatSet', '');
        l_Result.Push ('controlStart', '');
        l_Result.Push ('date1stUnload', '');
        l_Result.Push ('date1stCheck', '');
        l_Result.Push ('refHouseholdFeature', '');
        l_Result.Push ('separateBill', '');
        l_Result.Push ('refReturnReason', '');
        l_Result.Push ('returnDescription', '');
        l_Result.Push ('datResponse', '');
        l_Result.Push ('subs', '');
        l_Result.Push ('refCanton', '');
        l_Result.Push ('applicantRefCanton', '');

        --ІНФОРМАЦІЯ ПРО ЗВЕРНЕННЯ
        FOR Rec
            IN (SELECT TO_CHAR (a.Ap_Reg_Dt, c_Dt_Fmt)
                           AS Ap_Reg_Dt,
                       DECODE (a.Ap_Tp,  'V', 1,  'P', 2,  'S', 3)
                           AS Ap_Tp,
                       a.Ap_St,
                       a.Ap_Is_Second,
                       a.Com_Org
                  FROM Appeal a
                 WHERE a.Ap_Id = p_Ap_Id)
        LOOP
            DECLARE
                l_Ref_Status_Id   NUMBER;
                --l_Ref_Status_Name VARCHAR2(250);
                l_Ref_Status      Json_Obj;
                l_Ref_Unit        Json_Obj;
            BEGIN
                l_Ap_Is_Second := Rec.Ap_Is_Second;
                l_Result.Push (
                    'appealType',
                    CASE WHEN Rec.Ap_Is_Second = 'F' THEN 1 ELSE 2 END);
                l_Result.Push ('lastDoc', ''); --#70242 /*CASE WHEN Rec.Ap_St = Api$appeal.c_Ap_St_Wait_Docs THEN To_Char(SYSDATE, c_Dt_Fmt) END*/);
                l_Result.Push ('registryDate', Rec.Ap_Reg_Dt);
                l_Result.Push ('type', Rec.Ap_Tp);

                l_Ref_Status_Id :=
                    Uss_Ndi.Tools.Decode_Dict_Reverse (
                        p_Nddc_Tp          => 'AP_ST',
                        p_Nddc_Src         => Api$appeal.c_Src_Community,
                        p_Nddc_Dest        => Api$appeal.c_Src_Vst,
                        p_Nddc_Code_Dest   => Rec.Ap_St);
                --СТАТУС ЗВЕРНЕННЯ
                l_Ref_Status := NEW Json_Obj ();
                l_Ref_Status.Push ('id', l_Ref_Status_Id);
                l_Result.Push ('refStatus', l_Ref_Status);

                --ОСЗН
                l_Ref_Unit := NEW Json_Obj ();
                l_Ref_Unit.Push ('id', p_Com_Org);
                l_Result.Push ('refUnit', '');
                l_Result.Push ('refUnitDelivery', l_Ref_Unit);
                l_Com_Org := Rec.Com_Org;
            END;
        END LOOP;

        --ІНФОРМАЦІЯ ПРО ЗАЯВНИКА
        SELECT MIN (p.App_Id)
          INTO l_Applicant_Id
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.App_Tp = 'Z'
               AND p.History_Status = 'A';

        l_Result.Push (
            'phone',
            Api$appeal.Get_Person_Attr_Val_Str (l_Applicant_Id, 605));
        l_Result.Push (
            'email',
            Api$appeal.Get_Person_Attr_Val_Str (l_Applicant_Id, 811));
        l_Result.Push (
            'needDecision',
            Str2bool (
                Api$appeal.Get_Person_Attr_Val_Str (l_Applicant_Id, 868)));
        l_Result.Push (
            'personRegistry',
            Get_Person_Registry (
                l_Applicant_Id,
                Get_Address_Data (p_App_Id         => l_Applicant_Id,
                                  p_Com_Org        => l_Com_Org,
                                  p_Com_Org_Orig   => p_Com_Org,
                                  p_Kaot_Code      => l_Kaot_Code).TO_CLOB));

        --ГРОМАДА
        l_Ref_Community := Json_Obj ();
        l_Ref_Community.Push ('code', l_Kaot_Code);
        l_Result.Push ('refCommunity', l_Ref_Community);

        --ІНФОРМАЦІЯ ПРО УЧАСНИКІВ ЗВЕРНЕННЯ
        l_Result.Push_Arr ('relatedPersons',
                           Get_Related_Persons (p_Ap_Id /*, p_App_Id_z => l_Applicant_Id*/
                                                       ).TO_CLOB);

        --ІНФОРМАЦІЯ ПРО ДОПОМОГИ
        l_Result.Push_Arr (
            'aids',
            Get_Aids (p_Ap_Id, l_Ap_Is_Second, l_Applicant_Id).TO_CLOB);

        --ІНФОРМАЦІЯ ПРО СПОСОБИ ВИПЛАТ
        l_Result.Push ('paymentDetail',
                       Get_Payment_Detail (p_Ap_Id, l_Com_Org, p_Com_Org));

        IF l_Aps_Nst IN (267)
        THEN
            --ІНФОРМАЦІЯ З ДЕКЛАРАЦІЇ
            l_Result.Push ('declaration', Get_Declaration (p_Ap_Id));
        END IF;

        RETURN l_Result.TO_CLOB;
    END;

    ---------------------------------------------------------------------
    --   Перекодування ІД управління соцгромади в ІД ЄІССС
    ---------------------------------------------------------------------
    FUNCTION Decode_Org (p_Com_Org IN NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Uss_Ndi.Api$dic_Decoding.District2comorgv01 (p_Com_Org);
    END;

    --===================================================================
    --                     ЗАПИТИ ДО СГ
    --===================================================================
    FUNCTION Get_Statement_Docs (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Statement_Docs   VARCHAR2 (4000);
    BEGIN
        --Отримуємо перелік "не технічних" документів
        SELECT LISTAGG (d.Apd_Dh, ',') WITHIN GROUP (ORDER BY d.Apd_Dh)
          INTO l_Statement_Docs
          FROM Ap_Document  d
               JOIN Uss_Ndi.v_Ndi_Document_Type t
                   ON d.Apd_Ndt = t.Ndt_Id AND t.Ndt_Ndc <> -1
         WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';

        RETURN l_Statement_Docs;
    END;

    FUNCTION Get_Vf_Ap (p_Vf_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        SELECT d.Apd_Ap
          INTO l_Ap_Id
          FROM Verification v JOIN Ap_Document d ON v.Vf_Obj_Id = d.Apd_Id
         WHERE v.Vf_Id = p_Vf_Id;

        RETURN l_Ap_Id;
    END;

    -----------------------------------------------------------------------
    --  Реєстрація запиту на збереження заяви в СГ
    -----------------------------------------------------------------------
    FUNCTION Reg_Statement_Req (p_Rn_Nrt      IN     NUMBER,
                                p_Apd_Id      IN     NUMBER,
                                p_Nst_Id      IN     NUMBER DEFAULT NULL,
                                p_Is_Pkg      IN     BOOLEAN DEFAULT FALSE,
                                p_Send_Docs   IN     BOOLEAN,
                                p_Error          OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ap_Id            NUMBER;
        l_Aps_Id           NUMBER;
        l_Ap_Reg_Dt        DATE;
        l_Statement_File   Uss_Doc.v_Files.File_Code%TYPE;
        l_Statement_Sign   Uss_Doc.v_Files.File_Code%TYPE;
        l_Rn_Id            NUMBER;
    BEGIN
        BEGIN
            --Отрмуємо інфолрмацію про документ
            SELECT d.Apd_Ap,
                   d.Apd_Aps,
                   a.Ap_Reg_Dt,
                   f.File_Code,
                   s.File_Code
              INTO l_Ap_Id,
                   l_Aps_Id,
                   l_Ap_Reg_Dt,
                   l_Statement_File,
                   l_Statement_Sign
              FROM Ap_Document  d
                   JOIN Appeal a ON d.Apd_Ap = a.Ap_Id
                   JOIN Uss_Doc.v_Doc_Attachments t ON d.Apd_Dh = t.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON t.Dat_File = f.File_Id
                   LEFT JOIN Uss_Doc.v_Files s ON t.Dat_Sign_File = s.File_Id
             WHERE d.Apd_Id = p_Apd_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_Error := 'Не заповнено заяву';
                RETURN NULL;
        END;

        IF p_Nst_Id IS NOT NULL AND l_Aps_Id IS NULL
        THEN
            --Намагаємось знайти посилання на послугу в історичних даних
            --(для випадків, якщо виконується редагування звернення)
            SELECT MAX (Dd.Apd_Aps)
              INTO l_Aps_Id
              FROM Ap_Document  d
                   JOIN Ap_Document Dd
                       ON     d.Apd_App = Dd.Apd_App
                          AND d.Apd_Ndt = Dd.Apd_Ndt
                          AND Dd.Apd_Aps IS NOT NULL
             WHERE d.Apd_Id = p_Apd_Id;

            IF l_Aps_Id IS NULL
            THEN
                --Створюємо послугу, якщо її немає
                Api$appeal.Save_Service (p_Aps_Id    => l_Aps_Id,
                                         p_Aps_Nst   => p_Nst_Id,
                                         p_Aps_Ap    => l_Ap_Id,
                                         p_Aps_St    => 'R',
                                         p_New_Id    => l_Aps_Id);
            END IF;

            UPDATE Ap_Document d
               SET d.Apd_Aps = l_Aps_Id
             WHERE d.Apd_Id = p_Apd_Id;
        END IF;

        --Реєеструємо запит для передачі заяви до СГ
        Ikis_Rbm.Api$request_Msp.Reg_Save_Statement_Req (
            p_Rn_Nrt             => p_Rn_Nrt,
            p_Rn_Hs_Ins          => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src             => Api$appeal.c_Src_Vst,
            p_Rn_Id              => l_Rn_Id,
            p_Statement_Id       => l_Aps_Id,
            p_Statement_Pkg_Id   => CASE WHEN p_Is_Pkg THEN l_Ap_Id END,
            p_Statement_St       => NULL,
            p_Statement_Dt       => l_Ap_Reg_Dt,
            p_Statement_File     => l_Statement_File,
            p_Statement_Sign     => l_Statement_Sign,
            p_Statement_Docs     =>
                CASE WHEN p_Send_Docs THEN Get_Statement_Docs (l_Ap_Id) END);

        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------------
    --  Обробка відповіді на запит на збереження заяви в СГ
    -----------------------------------------------------------------------
    PROCEDURE Handle_Statement_Resp (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2,
        p_Is_Pkg     IN     BOOLEAN DEFAULT FALSE)
    IS
        l_Rn_Id            NUMBER;
        l_Vf_Id            NUMBER;
        l_Resp             Ikis_Rbm.Api$request_Msp.r_Statement_Response;
        l_Ap_Id            NUMBER;
        l_Ap_Tp            VARCHAR2 (10);
        l_Ap_St            VARCHAR2 (10);
        l_Com_Org          NUMBER;
        l_Aps_Nst          NUMBER;
        l_Is_Ext_Process   VARCHAR2 (10);
    BEGIN
        --Отримуємо ід запиту з основного журналу
        l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        --Зберігаємо відповідь
        Api$verification.Save_Verification_Answer (
            p_Vfa_Rn            => l_Rn_Id,
            p_Vfa_Answer_Data   => p_Response,
            p_Vfa_Vf            => l_Vf_Id);

        l_Ap_Id := Get_Vf_Ap (l_Vf_Id);

        SELECT MAX (a.Ap_St)
          INTO l_Ap_St
          FROM Appeal a
         WHERE a.Ap_Id = l_Ap_Id;

        --Якщо стан звернення вже було змінено іншим вхідним запитом, то вважаємо поточний запит успішним
        IF l_Ap_St <> 'VW'
        THEN
            RETURN;
        END IF;

        IF p_Error IS NOT NULL
        THEN
            --Api$verification.Write_Vf_Log(l_Vf_Id, p_Vfl_Tp => Api$verification.c_Vfl_Tp_Terror, p_Vfl_Message => p_Error);
            --RETURN;
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;

        l_Resp :=
            Ikis_Rbm.Api$request_Msp.Parse_Save_Statement_Resp (p_Response);

        IF p_Response IS NULL
        THEN
            p_Error := 'Відповідь сервісу "Соц. громади" порожня';

            IF NOT p_Is_Pkg
            THEN
                Api$verification.Set_Tech_Error (p_Rn_Id   => l_Rn_Id,
                                                 p_Error   => p_Error);
            ELSE
                Api$verification.Write_Vf_Log (
                    l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   => p_Error);
            END IF;
        ELSIF l_Resp.Code_ NOT IN
                  (Ikis_Rbm.Api$request_Msp.c_Statement_Resp_Code_Ok,
                   '403',
                   '100')
        --Код 403 повертається при спробі надіслати повторно вже збережену в СГ заяву
        -- 17/07/2024 serhii: #105717 Код "100" - не помилка
        THEN
            IF l_Resp.MESSAGE = 'Response timeout'
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 60,
                    p_Delay_Reason    => l_Resp.MESSAGE);
            END IF;

            p_Error := 'Соцгромада: ' || l_Resp.MESSAGE;

            IF NOT p_Is_Pkg
            THEN
                Api$verification.Set_Tech_Error (p_Rn_Id   => l_Rn_Id,
                                                 p_Error   => p_Error);
            ELSE
                Api$verification.Write_Vf_Log (
                    l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                    p_Vfl_Message   => p_Error);
            END IF;
        ELSIF l_Resp.Code_ IS NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => 'Порожній код відповіді');
        ELSE
            IF NOT p_Is_Pkg
            THEN
                l_Ap_Id := Get_Vf_Ap (l_Vf_Id);

                SELECT MAX (a.Ap_Tp), MAX (a.Com_Org), MAX (s.Aps_Nst)
                  INTO l_Ap_Tp, l_Com_Org, l_Aps_Nst
                  FROM Appeal  a
                       JOIN Ap_Service s
                           ON a.Ap_Id = s.Aps_Ap AND s.History_Status = 'A'
                 WHERE a.Ap_Id = l_Ap_Id;

                SELECT a.Ap_Is_Ext_Process
                  INTO l_Is_Ext_Process
                  FROM Appeal a
                 WHERE a.Ap_Id = l_Ap_Id;

                IF l_Is_Ext_Process = 'T'
                THEN
                    --Якщо звернення повинно відпрацьовуватись на боці СГ,
                    --То після успішної передачі запту змінюємо статус на "Передано на призначення"
                    UPDATE Appeal a
                       SET a.Ap_St = 'S'
                     WHERE a.Ap_Id = l_Ap_Id AND a.Ap_St = 'VW';

                    Api$appeal.Write_Log (
                        p_Apl_Ap        => l_Ap_Id,
                        p_Apl_Hs        => Tools.Gethistsession (NULL),
                        p_Apl_St        => 'S',
                        p_Apl_Message   => CHR (38) || 22,
                        p_Apl_St_Old    => 'VW',
                        p_Apl_Tp        => Api$appeal.c_Apl_Tp_Sys);
                ELSE
                    --Якщо звернення повинно відпрацьовуватись на боці ЄІССС, то переводимо верифікацію в статус "успішна",
                    --для подальшого просування звернення в ЄСР
                    Api$verification.Set_Ok (l_Vf_Id);
                END IF;
            ELSE
                Api$verification.Write_Vf_Log (
                    l_Vf_Id,
                    p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Info,
                    p_Vfl_Message   => CHR (38) || 22);
            END IF;
        END IF;
    END;

    -----------------------------------------------------------------------
    --  Реєстрація запиту на взяття особи на облік ВПО або на допомогу ВПО
    -----------------------------------------------------------------------
    FUNCTION Reg_Vpo_Req (p_Rn_Nrt   IN     NUMBER,
                          p_Obj_Id   IN     NUMBER,
                          p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Aps_Nst   NUMBER;
    BEGIN
        SELECT DECODE (LENGTH (a.Ap_Ext_Ident), 10, 781, 664) --Це костиль, але простішого способу визначення послуги поки немає
          INTO l_Aps_Nst
          FROM Ap_Document d JOIN Appeal a ON d.Apd_Ap = a.Ap_Id
         WHERE d.Apd_Id = p_Obj_Id;

        RETURN Reg_Statement_Req (p_Rn_Nrt      => p_Rn_Nrt,
                                  p_Apd_Id      => p_Obj_Id,
                                  p_Nst_Id      => l_Aps_Nst,
                                  p_Is_Pkg      => TRUE,
                                  p_Send_Docs   => FALSE,
                                  p_Error       => p_Error);
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на взяття особи на облік ВПО
    --   або на допомогу ВПО
    -----------------------------------------------------------------
    PROCEDURE Handle_Vpo_Resp (p_Ur_Id      IN     NUMBER,
                               p_Response   IN     CLOB,
                               p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Handle_Statement_Resp (p_Ur_Id      => p_Ur_Id,
                               p_Response   => p_Response,
                               p_Error      => p_Error);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на взяття особи на облік ВПО
    -----------------------------------------------------------------
    FUNCTION Reg_Vpo_Register_Req (p_Rn_Nrt   IN     NUMBER,
                                   p_Obj_Id   IN     NUMBER,
                                   p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Reg_Statement_Req (p_Rn_Nrt      => p_Rn_Nrt,
                                  p_Apd_Id      => p_Obj_Id,
                                  p_Nst_Id      => 781,
                                  p_Is_Pkg      => TRUE,
                                  p_Send_Docs   => FALSE,
                                  p_Error       => p_Error);
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на взяття на облік ВПО
    -----------------------------------------------------------------
    PROCEDURE Handle_Vpo_Register_Resp (p_Ur_Id      IN     NUMBER,
                                        p_Response   IN     CLOB,
                                        p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Handle_Statement_Resp (p_Ur_Id      => p_Ur_Id,
                               p_Response   => p_Response,
                               p_Error      => p_Error,
                               p_Is_Pkg     => TRUE);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на допомогу на проживання ВПО
    -----------------------------------------------------------------
    FUNCTION Reg_Vpo_Help_Req (p_Rn_Nrt   IN     NUMBER,
                               p_Obj_Id   IN     NUMBER,
                               p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Reg_Statement_Req (p_Rn_Nrt      => p_Rn_Nrt,
                                  p_Apd_Id      => p_Obj_Id,
                                  p_Nst_Id      => 664,
                                  p_Is_Pkg      => TRUE,
                                  p_Send_Docs   => TRUE,
                                  p_Error       => p_Error);
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на допомогу на проживання ВПО
    -----------------------------------------------------------------
    PROCEDURE Handle_Vpo_Help_Resp (p_Ur_Id      IN     NUMBER,
                                    p_Response   IN     CLOB,
                                    p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Handle_Statement_Resp (p_Ur_Id      => p_Ur_Id,
                               p_Response   => p_Response,
                               p_Error      => p_Error,
                               p_Is_Pkg     => TRUE);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на субсидії
    -----------------------------------------------------------------
    FUNCTION Reg_Subs_Req (p_Rn_Nrt   IN     NUMBER,
                           p_Obj_Id   IN     NUMBER,
                           p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Reg_Statement_Req (p_Rn_Nrt      => p_Rn_Nrt,
                                  p_Apd_Id      => p_Obj_Id,
                                  p_Nst_Id      => 8,
                                  p_Is_Pkg      => TRUE,
                                  p_Send_Docs   => TRUE,
                                  p_Error       => p_Error);
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на субсидію
    -----------------------------------------------------------------
    PROCEDURE Handle_Subs_Resp (p_Ur_Id      IN     NUMBER,
                                p_Response   IN     CLOB,
                                p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Handle_Statement_Resp (p_Ur_Id      => p_Ur_Id,
                               p_Response   => p_Response,
                               p_Error      => p_Error);
    END;

    -----------------------------------------------------------------
    --  Реєстрація запиту на соціальну допомогу
    -----------------------------------------------------------------
    FUNCTION Reg_Aid_Req (p_Rn_Nrt   IN     NUMBER,
                          p_Obj_Id   IN     NUMBER,
                          p_Error       OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Aps_Id                NUMBER;
        l_Ap_Id                 NUMBER;
        l_Ap_Reg_Dt             DATE;
        l_Rn_Id                 NUMBER;
        l_Com_Org               NUMBER;
        l_Community_Statement   CLOB;
    BEGIN
        p_Error := NULL;

          --Отрмуємо інформацію про документ
          SELECT d.Apd_Ap,
                 a.Ap_Reg_Dt,
                 Uss_Doc.Api$documents.Get_Attr_Val_Str (
                     p_Nda_Class   => 'ORG',
                     p_Dh_Id       => h.Dh_Id),
                 s.Aps_Id
            INTO l_Ap_Id,
                 l_Ap_Reg_Dt,
                 l_Com_Org,
                 l_Aps_Id
            FROM Ap_Document d
                 JOIN Appeal a ON d.Apd_Ap = a.Ap_Id
                 JOIN Uss_Doc.v_Doc_Hist h ON a.Ap_Doc = h.Dh_Doc
                 JOIN Ap_Service s
                     ON d.Apd_Ap = s.Aps_Ap AND s.History_Status = 'A'
           WHERE d.Apd_Id = p_Obj_Id
        ORDER BY h.Dh_Dt DESC
           FETCH FIRST ROW ONLY;

        --Отримуємо метадані звернення
        l_Community_Statement :=
            Api$community.Get_Statement (p_Ap_Id     => l_Ap_Id,
                                         p_Com_Org   => l_Com_Org);

        --Реєструємо вихідний запит
        Ikis_Rbm.Api$request_Msp.Reg_Save_Statement_Req (
            p_Rn_Nrt           => p_Rn_Nrt,
            p_Rn_Hs_Ins        => Ikis_Rbm.Tools.Gethistsession (NULL),
            p_Rn_Src           => Api$appeal.c_Src_Vst,
            p_Rn_Id            => l_Rn_Id,
            p_Statement_Id     => l_Aps_Id,
            p_Statement_St     => NULL,
            p_Statement_Dt     => l_Ap_Reg_Dt,
            p_Statement_File   => NULL,
            p_Statement_Sign   => NULL,
            p_Statement        => l_Community_Statement,
            p_Statement_Docs   => Get_Statement_Docs (l_Ap_Id));

        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------
    --  Обробка відповіді на запит на соціальну допомогу
    -----------------------------------------------------------------
    PROCEDURE Handle_Aid_Resp (p_Ur_Id      IN     NUMBER,
                               p_Response   IN     CLOB,
                               p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Handle_Statement_Resp (p_Ur_Id      => p_Ur_Id,
                               p_Response   => p_Response,
                               p_Error      => p_Error);
    END;

    -----------------------------------------------------------------
    -- Зворотній виклик, що виконується після завершення
    -- верифікації учасника
    -----------------------------------------------------------------
    PROCEDURE App_Vf_Callback (p_App_Id IN NUMBER)
    IS
        l_Ap            Appeal%ROWTYPE;
        l_App_z         NUMBER;
        l_Lock_Handle   Ikis_Sys.Ikis_Lock.t_Lockhandler;
    BEGIN
        SELECT a.*
          INTO l_Ap
          FROM Ap_Person p JOIN Appeal a ON p.App_Ap = a.Ap_Id
         WHERE p.App_Id = p_App_Id;

        IF NOT (    --Якщо верифікується звернення від ДІЇ
                    l_Ap.Ap_Src IN ('DIIA')
                --по допомозі
                AND l_Ap.Ap_Tp IN ('V')
                --
                AND l_Ap.Ap_St = 'VW'
                --та передається до СГ
                AND Api$community.Is_Ext_Pass (l_Ap.Ap_Id)
                --та не по заявнику
                AND Api$appeal.Get_Person_Tp (p_App_Id) <> 'Z')
        THEN
            RETURN;
        END IF;

        BEGIN
            Ikis_Sys.Ikis_Lock.Request_Lock (
                p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                p_Var_Name            => 'VF_СOM_CALLBACK_' || l_Ap.Ap_Id,
                p_Errmessage          => NULL,
                p_Lockhandler         => l_Lock_Handle,
                p_Timeout             => 3600,
                p_Release_On_Commit   => TRUE);
        EXCEPTION
            WHEN OTHERS
            THEN
                --Виключення буде якщо в цій сесії вже виконано блокування
                NULL;
        END;

        SELECT MAX (p.App_Id)
          INTO l_App_z
          FROM Ap_Person p
         WHERE     p.App_Ap = l_Ap.Ap_Id
               AND p.App_Tp = 'Z'
               AND p.History_Status = 'A'
               AND p.App_Vf IS NOT NULL;

        IF l_App_z IS NOT NULL
        THEN
            Api$verification.Try_Continue_App_Vf (l_App_z);
        END IF;
    END;
END Api$community;
/