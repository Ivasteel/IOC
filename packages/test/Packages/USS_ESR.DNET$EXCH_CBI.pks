/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$EXCH_CBI
IS
    -- Author  : SHOSTAK
    -- Created : 20.12.2024 13:05:58
    -- Purpose : Обмін з ЦБІ

    /*
    info:    Отримання інформації про наявні ДЗР у особи
    author:  sho
    request: #112502
    note:
    */
    FUNCTION Put_Person_Wares (p_Request_Id     IN NUMBER,
                               p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    Перенос даних про наявні ДЗР у особи з тимчасових структур до структур актів
    author:  sho
    request: #112502
    note:    Повинно викликатись в колбеку верифікації
    */
    PROCEDURE Save_Person_Wares2act (p_Scdi_Id   IN NUMBER,
                                     p_Scv_St    IN VARCHAR2);

    /*
    info:    Отримання статусу ДЗР для особи
    author:  sho
    request: #112502
    note:
    */
    FUNCTION Put_Person_Wares_Status (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    реєстрація запиту для передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    PROCEDURE Reg_Get_Wares_Need_Request (p_At_Id IN NUMBER, p_Rbm_Hs NUMBER);

    /*
    info:    Отримання даних запиту для передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Get_Wares_Need_Request (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    /*
    info:   Обробка відповіді на запит передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    PROCEDURE Handle_Wares_Need_Response (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2);
END Dnet$exch_Cbi;
/


GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO II01RC_USS_ESR_SVC
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.DNET$EXCH_CBI TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$EXCH_CBI
IS
    c_Req_Ndt              CONSTANT NUMBER := 10353;
    с_Req_Nda_Fond_Code   CONSTANT NUMBER := 8684;
    c_Req_Nda_At_Num       CONSTANT NUMBER := 8685;
    c_Req_Nda_At_Dt        CONSTANT NUMBER := 8686;

    /*
    info:    Отримання інформації про наявні ДЗР у особи
    author:  sho
    request: #112502
    note:    Виконує збереження в "тимчасові" структури для подальшої верифікації
    */
    FUNCTION Put_Person_Wares (p_Request_Id     IN NUMBER,
                               p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Req              Ikis_Rbm.Api$request_Cbi.r_Need_Req;
        l_Scdi_Id          NUMBER;
        l_Scpa_Id          NUMBER;
        l_Passp_Ndt        NUMBER;
        l_Scpo_Passp       NUMBER;
        l_Scpo_Req         NUMBER;
        l_Nrt_Id           NUMBER;
        l_Already_Exists   NUMBER;

        --Збереження атрибуту документа в "тимчасову" структуру
        PROCEDURE Save_Attr (p_Scpo_Id     NUMBER,
                             p_Ndt_Id      NUMBER,
                             p_Nda_Class   VARCHAR2,
                             p_Val_Str     VARCHAR2 DEFAULT NULL,
                             p_Val_Dt      DATE DEFAULT NULL)
        IS
        BEGIN
            Uss_Person.Api$socialcard_Ext.Save_Doc_Attr (
                p_Scpda_Scpo         => p_Scpo_Id,
                p_Scpda_Nda          =>
                    Uss_Ndi.Api$dic_Document.Get_Nda_Id (p_Ndt_Id,
                                                         p_Nda_Class),
                p_Scpda_Val_String   => p_Val_Str,
                p_Scpda_Val_Dt       => p_Val_Dt);
        END Save_Attr;

        --Збереження атрибуту документа в "тимчасову" структуру
        PROCEDURE Save_Attr (p_Scpo_Id   NUMBER,
                             p_Nda_Id    VARCHAR2,
                             p_Val_Str   VARCHAR2 DEFAULT NULL,
                             p_Val_Dt    DATE DEFAULT NULL)
        IS
        BEGIN
            Uss_Person.Api$socialcard_Ext.Save_Doc_Attr (
                p_Scpda_Scpo         => p_Scpo_Id,
                p_Scpda_Nda          => p_Nda_Id,
                p_Scpda_Val_String   => p_Val_Str,
                p_Scpda_Val_Dt       => p_Val_Dt);
        END Save_Attr;
    BEGIN
        --Парсимо запит
        BEGIN
            l_Req :=
                Ikis_Rbm.Api$request_Cbi.Parse_Wares_Req (p_Request_Body);
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                       'Помилка парсингу запиту: '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM);
        END;

        l_Nrt_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Nrt (p_Request_Id);

        --Перевірка наявності раніше збереженої заяви з таким ідентифікатором
        SELECT SIGN (COUNT (*))
          INTO l_Already_Exists
          FROM Uss_Person.v_Sc_Pfu_Data_Ident i
         WHERE i.Scdi_Nrt = l_Nrt_Id AND i.Scdi_Ext_Ident = l_Req.Req_Id;

        IF l_Already_Exists = 1
        THEN
            RETURN NULL;
        END IF;

        --Визначаємо тип документа
        l_Passp_Ndt :=
            CASE
                WHEN REGEXP_LIKE (
                         TRIM (
                             l_Req.Passport.Seria || l_Req.Passport.Number_),
                         '^[0-9]{9}$')
                THEN
                    7
                WHEN REGEXP_LIKE (
                         TRIM (
                             l_Req.Passport.Seria || l_Req.Passport.Number_),
                         '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[0-9]{6}$')
                THEN
                    6
            END;

        --Зберігаюмо основні реквізити особи
        Uss_Person.Api$socialcard_Ext.Save_Data_Ident (
            p_Scdi_Ln         => Tools.Clear_Name (l_Req.Last_Name),
            p_Scdi_Fn         => Tools.Clear_Name (l_Req.First_Name),
            p_Scdi_Mn         => Tools.Clear_Name (l_Req.Second_Name),
            p_Scdi_Numident   => l_Req.Numident,
            p_Scdi_Doc_Tp     => l_Passp_Ndt,
            p_Scdi_Doc_Sn     =>
                l_Req.Passport.Seria || l_Req.Passport.Number_,
            p_Scdi_Sex        => l_Req.Sex,
            p_Scdi_Birthday   => l_Req.Birth_Date,
            p_Rn_Id           =>
                Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Request_Id),
            p_Phone_Num       => l_Req.Phone,
            p_Email           => l_Req.Email,
            p_Ext_Ident       => l_Req.Pers_Id,
            p_Scdi_Id         => l_Scdi_Id,
            p_Nrt_Id          => l_Nrt_Id);

        --Зберігаємо атрибути паспорта(для подальшого копіювання в СРКО)
        IF l_Passp_Ndt IS NOT NULL
        THEN
            Uss_Person.Api$socialcard_Ext.Save_Document (
                p_Scpo_Id     => l_Scpo_Passp,
                p_Scpo_Scdi   => l_Scdi_Id,
                p_Scpo_Ndt    => l_Passp_Ndt);

            Save_Attr (
                l_Scpo_Passp,
                l_Passp_Ndt,
                'DSN',
                p_Val_Str   => l_Req.Passport.Seria || l_Req.Passport.Number_);
            Save_Attr (l_Scpo_Passp,
                       l_Passp_Ndt,
                       'DORG',
                       p_Val_Str   => l_Req.Passport.Issue_Org);
            Save_Attr (l_Scpo_Passp,
                       l_Passp_Ndt,
                       'DGVDT',
                       p_Val_Dt   => l_Req.Passport.Issue_Date);
        END IF;

        --Зберігаємо в атрибути технічного документа поля із запиту, для яких немає полів у "тимчасових" структурах
        Uss_Person.Api$socialcard_Ext.Save_Document (
            p_Scpo_Id     => l_Scpo_Req,
            p_Scpo_Scdi   => l_Scdi_Id,
            p_Scpo_Ndt    => c_Req_Ndt);
        Save_Attr (l_Scpo_Req,
                   с_Req_Nda_Fond_Code,
                   p_Val_Str   => l_Req.Fond_Code);
        Save_Attr (l_Scpo_Req, 8685, p_Val_Str => l_Req.Req_Number);
        Save_Attr (l_Scpo_Req, 8686, p_Val_Dt => l_Req.Req_Date);
        Save_Attr (l_Scpo_Req, 8687, p_Val_Str => l_Req.Pers_State);

        --Зберігаємо адресу
        Uss_Person.Api$socialcard_Ext.Save_Address (
            p_Scpa_Id          => l_Scpa_Id,
            p_Scpa_Scdi        => l_Scdi_Id,
            p_Scpa_Tp          => '2',                     --Адреса проживання
            p_Scpa_Kaot_Code   => l_Req.Actual_Address.Katottg,
            p_Scpa_Postcode    => l_Req.Actual_Address.Post_Index,
            p_Scpa_Street      => l_Req.Actual_Address.Street,
            p_Scpa_Building    => l_Req.Actual_Address.House,
            p_Scpa_Block       => l_Req.Actual_Address.Block,
            p_Scpa_Apartment   => l_Req.Actual_Address.Appartment,
            p_Scpa_Create_Dt   => l_Req.Req_Date);

        --Зберігаємо ДЗР
        FOR i IN 1 .. l_Req.Wares.COUNT
        LOOP
            DECLARE
                l_Sccw_Id   NUMBER;
            BEGIN
                Uss_Person.Api$socialcard_Ext.Save_Cbi_Wares (
                    p_Sccw_Id       => l_Sccw_Id,
                    p_Sccw_Scdi     => l_Scdi_Id,
                    p_Sccw_Iso      => l_Req.Wares (i).Ware_Iso,
                    p_Sccw_Name     => l_Req.Wares (i).Ware_Name,
                    p_Sccw_Ext_Id   => l_Req.Wares (i).Ware_Id_Cbi);
            END;
        END LOOP;

        RETURN NULL;
    END Put_Person_Wares;

    FUNCTION Lock_Cbi_Ware (p_Ware_Id_Cbi IN NUMBER)
        RETURN Ikis_Sys.Ikis_Lock.t_Lockhandler
    IS
        l_Lock   Ikis_Sys.Ikis_Lock.t_Lockhandler;
    BEGIN
        l_Lock :=
            Tools.Request_Lock_With_Timeout (
                p_Descr               => 'SAVE_CBI_WARES_' || p_Ware_Id_Cbi,
                p_Error_Msg           => 'Сервіс тимчасово недоступний',
                p_Timeout             => 60,
                p_Release_On_Commit   => TRUE);

        RETURN l_Lock;
    END Lock_Cbi_Ware;

    /*
    info:    Перенос даних про наявні ДЗР у особи з тимчасових структур до структур актів
    author:  sho
    request: #112502
    note:    Повинно викликатись в колбеку верифікації
    */
    PROCEDURE Save_Person_Wares2act (p_Scdi_Id   IN NUMBER,
                                     p_Scv_St    IN VARCHAR2)
    IS
        l_Scdi        Uss_Person.v_Sc_Pfu_Data_Ident%ROWTYPE;
        l_At_Id       NUMBER;
        l_At_Org      Act.At_Org%TYPE;
        l_Pc_Id       NUMBER;
        l_Atp_Id      NUMBER;
        l_Atd_Id      NUMBER;
        l_Kaot_Code   Uss_Ndi.v_Ndi_Katottg.Kaot_Code%TYPE;
        l_Kaot_Id     NUMBER;
        l_Kaot_Name   VARCHAR2 (4000);
        l_Scpo_Id     NUMBER;
        l_Addr        Uss_Person.v_Sc_Pfu_Address%ROWTYPE;
        l_Attrs       Api$act.t_At_Document_Attrs;
        l_Hs_Id       NUMBER := Tools.Gethistsession;

        PROCEDURE Add_Attr (p_Nda_Id    IN NUMBER,
                            p_Val_Str   IN VARCHAR2 DEFAULT NULL,
                            p_Val_Id    IN NUMBER DEFAULT NULL,
                            p_Val_Dt    IN DATE DEFAULT NULL)
        IS
        BEGIN
            IF p_Val_Str IS NULL AND p_Val_Id IS NULL AND p_Val_Dt IS NULL
            THEN
                RETURN;
            END IF;

            Api$act.Add_Attr (p_Attrs     => l_Attrs,
                              p_Nda_Id    => p_Nda_Id,
                              p_Val_Str   => p_Val_Str,
                              p_Val_Dt    => p_Val_Dt,
                              p_Val_Id    => p_Val_Id);
        END Add_Attr;
    BEGIN
        --Якщо верифікація отриманих даних неуспішна
        IF NVL (p_Scv_St, '-') <> 'X'
        THEN
            --Нічого не зберігаємо
            RETURN;
        END IF;

        --Вичитуємо основні реквізити особи
        SELECT *
          INTO l_Scdi
          FROM Uss_Person.v_Sc_Pfu_Data_Ident i
         WHERE i.Scdi_Id = p_Scdi_Id;

        --Якщо СРКО не визначено
        IF l_Scdi.Scdi_Sc IS NULL
        THEN
            --Нічого не зберігаємо
            RETURN;
        END IF;

        --Визначаємо ІД ЕОС
        SELECT MAX (c.Pc_Id)
          INTO l_Pc_Id
          FROM Personalcase c
         WHERE c.Pc_Sc = l_Scdi.Scdi_Sc AND c.Pc_St <> 'Z';

        --Визначаємо ІД технічного документа з додатковими атрибутами
        SELECT MAX (d.Scpo_Id)
          INTO l_Scpo_Id
          FROM Uss_Person.v_Sc_Pfu_Document d
         WHERE d.Scpo_Scdi = p_Scdi_Id AND d.Scpo_Ndt = c_Req_Ndt;

        SELECT MAX (N2d_Org_Nsss)
          INTO l_At_Org
          FROM Uss_Ndi.v_Ndi_Nsss2dszn   n,
               Uss_Ndi.v_Ndi_Org2kaot    Ok,
               Uss_Ndi.v_Ndi_Katottg     k,
               Uss_Ndi.v_Ndi_Pay_Person  p,
               v_Opfu                    o
         WHERE     Ok.History_Status = 'A'
               AND Ok.Nok_Org = N2d_Org_Dszn
               AND Ok.Nok_Kaot = k.Kaot_Id
               AND k.Kaot_Kaot_L1 = p.Dpp_Kaot
               AND p.Dpp_Tp = 'ISPF'
               AND p.Dpp_Tax_Code =
                   Uss_Person.Api$socialcard_Ext.Get_Attr_Val_Str (
                       p_Scpda_Scpo   => l_Scpo_Id,
                       p_Scpda_Nda    => с_Req_Nda_Fond_Code)
               AND n.N2d_Org_Nsss = o.Org_Id
               AND o.Org_To = 81;

        --Створюємо акт
        Api$act.Save_Act (
            p_At_Id          => NULL,
            p_At_Tp          => 'NDZR',
            p_At_Num         =>
                Uss_Person.Api$socialcard_Ext.Get_Attr_Val_Str (
                    p_Scpda_Scpo   => l_Scpo_Id,
                    p_Scpda_Nda    => c_Req_Nda_At_Num),
            p_At_Pc          => l_Pc_Id,
            p_At_Dt          =>
                Uss_Person.Api$socialcard_Ext.Get_Attr_Val_Dt (
                    p_Scpda_Scpo   => l_Scpo_Id,
                    p_Scpda_Nda    => c_Req_Nda_At_Dt),
            p_At_Org         => l_At_Org,
            p_At_Sc          => l_Scdi.Scdi_Sc,
            p_At_Rnspm       => NULL,
            p_At_Ap          => NULL,
            p_At_St          => 'R',
            p_At_Src         => 'CBI',
            p_At_Ext_Ident   => l_Scdi.Scdi_Ext_Ident,
            p_New_Id         => l_At_Id);

        --Створюємо особу в акті
        Api$act.Save_Person (p_Atp_Id                => NULL,
                             p_Atp_At                => l_At_Id,
                             p_Atp_Sc                => l_Scdi.Scdi_Sc,
                             p_Atp_Fn                => Tools.Clear_Name (l_Scdi.Scdi_Fn),
                             p_Atp_Mn                => Tools.Clear_Name (l_Scdi.Scdi_Mn),
                             p_Atp_Ln                => Tools.Clear_Name (l_Scdi.Scdi_Ln),
                             p_Atp_Birth_Dt          => l_Scdi.Scdi_Birthday,
                             p_Atp_Relation_Tp       => NULL,
                             p_Atp_Is_Disabled       => NULL,
                             p_Atp_Is_Capable        => NULL,
                             p_Atp_Work_Place        => NULL,
                             p_Atp_Is_Adr_Matching   => NULL,
                             p_Atp_Phone             => l_Scdi.Scdi_Phone_Num,
                             p_Atp_Notes             => NULL,
                             p_Atp_Live_Address      => NULL,
                             p_Atp_Tp                => NULL,
                             p_Atp_Cu                => NULL,
                             p_Atp_App_Tp            => NULL,
                             p_Atp_Fact_Address      => NULL,
                             p_Atp_Is_Disordered     => NULL,
                             p_Atp_Disorder_Record   => NULL,
                             p_Atp_Disable_Record    => NULL,
                             p_Atp_Capable_Record    => NULL,
                             p_Atp_Sex               => l_Scdi.Scdi_Sex,
                             p_Atp_Citizenship       => NULL,
                             p_Atp_Is_Selfservice    => NULL,
                             p_Atp_Is_Vpo            => NULL,
                             p_Atp_Is_Orphan         => NULL,
                             p_Atp_Email             => l_Scdi.Scdi_Email,
                             p_Atp_Num               => 1,
                             p_New_Id                => l_Atp_Id);

        --Створбємо технічний документ в акті
        INSERT INTO At_Document (Atd_Id,
                                 Atd_At,
                                 Atd_Ndt,
                                 History_Status,
                                 Atd_Atp)
             VALUES (0,
                     l_At_Id,
                     c_Req_Ndt,
                     'A',
                     l_Atp_Id)
          RETURNING Atd_Id
               INTO l_Atd_Id;

        --Визначаємо ІД та назву КАТОТТГ
        IF l_Kaot_Code IS NOT NULL
        THEN
            SELECT k.Kaot_Id,
                   Uss_Ndi.Api$dic_Common.Get_Katottg_Name (k.Kaot_Id)
              INTO l_Kaot_Id, l_Kaot_Name
              FROM Uss_Ndi.v_Ndi_Katottg k
             WHERE k.Kaot_Code = l_Kaot_Code;
        END IF;

        --Вичитуємо адресу
        SELECT a.*
          INTO l_Addr
          FROM Uss_Person.v_Sc_Pfu_Address a
         WHERE a.Scpa_Scdi = p_Scdi_Id;

        --Формуємо масив атрибутів технічного документа в акті
        --Адреса
        Add_Attr (8688, p_Val_Str => l_Addr.Scpa_Postcode);
        Add_Attr (8689, p_Val_Str => l_Kaot_Name, p_Val_Id => l_Kaot_Id);
        Add_Attr (8690, p_Val_Str => l_Addr.Scpa_Street);
        Add_Attr (8691, p_Val_Str => l_Addr.Scpa_Building);
        Add_Attr (8692, p_Val_Str => l_Addr.Scpa_Block);
        Add_Attr (8693, p_Val_Str => l_Addr.Scpa_Apartment);

        --ТВ ФСЗОІ
        Add_Attr (
            8684,
            p_Val_Str   =>
                Uss_Person.Api$socialcard_Ext.Get_Attr_Val_Str (
                    p_Scpda_Scpo   => l_Scpo_Id,
                    p_Scpda_Nda    => 8684));
        --Статус особи
        Add_Attr (
            8687,
            p_Val_Str   =>
                Uss_Person.Api$socialcard_Ext.Get_Attr_Val_Str (
                    p_Scpda_Scpo   => l_Scpo_Id,
                    p_Scpda_Nda    => 8687));

        --Зберігаємо атрибути
        Api$act.Save_Attributes (p_At_Id    => l_At_Id,
                                 p_Atd_Id   => l_Atd_Id,
                                 p_Attrs    => l_Attrs);

        --Зберігаємо інформацію про ДЗРи в акт
        FOR Rec IN (SELECT w.Sccw_Id,
                           w.Sccw_Scdi,
                           w.Sccw_Wrn,
                           w.Sccw_Ext_Id
                      FROM Uss_Person.v_Sc_Cbi_Wares w
                     WHERE w.Sccw_Scdi = p_Scdi_Id)
        LOOP
            DECLARE
                l_Lock     Ikis_Sys.Ikis_Lock.t_Lockhandler;
                l_Atw_Id   NUMBER;
                l_Sccw     Uss_Person.v_Sc_Cbi_Wares%ROWTYPE;
            BEGIN
                --Встановлюємо блокування на ідентифікатор ЦБІ, на випадок,
                --якщо в цей момент виконується запит від ЦБІ на зміну статуса ДЗР
                l_Lock := Lock_Cbi_Ware (Rec.Sccw_Ext_Id);

                --Вичитуємо поточний стан ДЗР з тимчасової струкутри
                SELECT *
                  INTO l_Sccw
                  FROM Uss_Person.v_Sc_Cbi_Wares w
                 WHERE w.Sccw_Id = Rec.Sccw_Id;

                --Зберігаємо інформацію про ДЗР в акт
                Api$act_Ndzr.Save_Wares (
                    p_Atw_Id              => l_Atw_Id,
                    p_Atw_At              => l_At_Id,
                    p_Atw_Wrn             => l_Sccw.Sccw_Wrn,
                    p_Atw_Ext_Ident       => l_Sccw.Sccw_Ext_Id,
                    p_Atw_St              => NVL (l_Sccw.Sccw_Cbi_St, 'ZA'),
                    p_Atw_Issue_Dt        => l_Sccw.Sccw_Issue_Dt,
                    p_Atw_End_Exp_Dt      => l_Sccw.Sccw_End_Exp_Dt,
                    p_Atw_Ref_Num         => l_Sccw.Sccw_Ref_Num,
                    p_Atw_Ref_Dt          => l_Sccw.Sccw_Ref_Dt,
                    p_Atw_Ref_Exp_Dt      => l_Sccw.Sccw_Ref_Exp_Dt,
                    p_Atw_Reject_Reason   => l_Sccw.Sccw_Reject_Reason);

                --Копіємо "тимчасовий" лог в "постійний"
                INSERT INTO Atw_Log (Atwl_Id,
                                     Atwl_Atw,
                                     Atwl_Hs,
                                     Atwl_St,
                                     Atwl_Message,
                                     Atwl_St_Old,
                                     Atwl_Tp)
                    SELECT 0,
                           l_Atw_Id,
                           l_Hs_Id,
                           l.Sccwl_St,
                           CHR (38) || '363#' || l.Sccwl_Rn,
                           l.Sccwl_St_Old,
                           'SYS'
                      FROM Uss_Person.v_Sccw_Log l
                     WHERE l.Sccwl_Sccw = Rec.Sccw_Id;
            END;
        END LOOP;
    END Save_Person_Wares2act;

    /*
    info:    Отримання статусу ДЗР для особи
    author:  sho
    request: #112502
    note:
    */
    FUNCTION Put_Person_Wares_Status (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Req           Ikis_Rbm.Api$request_Cbi.r_Wares_Status_Req;
        l_At_Id         NUMBER;
        l_Atw_Id        NUMBER;
        l_Atw_St_Old    VARCHAR2 (10);
        l_Atw_Wrn       At_Wares.Atw_Wrn%TYPE;
        l_Lock          Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_Scww_Id       NUMBER;
        l_Sccw_Cbi_St   VARCHAR2 (10);
    BEGIN
        BEGIN
            l_Req :=
                Ikis_Rbm.Api$request_Cbi.Parse_Wares_Status_Req (
                    p_Request_Body);
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                       'Помилка парсингу запиту: '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM);
        END;

        IF l_Req.Ware_Id_Uss IS NULL AND l_Req.Ware_Id_Cbi IS NULL
        THEN
            Raise_Application_Error (-20000,
                                     'Не вказано жодного ідентифікатора ДЗР');
        END IF;

        ---Якщо запит на зміну статуса по направленню від ЦБІ
        IF l_Req.Ware_Id_Uss IS NULL AND l_Req.Ware_Id_Cbi IS NOT NULL
        THEN
            --Встановлюємо блокування на ідентифікатор ЦБІ, на випадок,
            --якщо в цей момент виконується копіювання даних в акти після верифікації направлення від ЦБІ
            l_Lock := Lock_Cbi_Ware (l_Req.Ware_Id_Cbi);              --ignore

            --Шукаємо запис про ДЗР в тимчасовії структурі
            BEGIN
                  SELECT w.Sccw_Id, w.Sccw_Cbi_St
                    INTO l_Scww_Id, l_Sccw_Cbi_St
                    FROM Uss_Person.v_Sc_Cbi_Wares w
                         JOIN Uss_Person.v_Sc_Pfu_Data_Ident i
                             ON w.Sccw_Scdi = i.Scdi_Id
                         JOIN Ikis_Rbm.v_Request_Journal j
                             ON i.Scdi_Rn = j.Rn_Id
                   WHERE w.Sccw_Ext_Id = l_Req.Ware_Id_Cbi
                ORDER BY j.Rn_Ins_Dt DESC
                   FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Не знайдено направлення по ДЗР(wareIdCbi='
                        || l_Req.Ware_Id_Cbi
                        || ')');
            END;

            --Оновлюємо інформацію про ДЗР в тимчасовій структурі
            Uss_Person.Api$socialcard_Ext.Save_Cbi_Wares (
                p_Sccw_Id              => l_Scww_Id,
                p_Sccw_Ref_Num         => l_Req.Ref_Num,
                p_Sccw_Ref_Dt          => l_Req.Ref_Dt,
                p_Sccw_Ref_Exp_Dt      => l_Req.Ref_Exp_Dt,
                p_Sccw_Issue_Dt        => l_Req.Ware_Issue_Dt,
                p_Sccw_End_Exp_Dt      => l_Req.Ware_End_Exp_Dt,
                p_Sccw_Reject_Reason   => l_Req.Reject_Reason,
                p_Sccw_Cbi_St          => l_Req.Status);

            --Пишемо в тимчасовий лог інформацію про запит
            Uss_Person.Api$socialcard_Ext.Write_Cbi_Ware_Log (
                p_Sccwl_Rn       =>
                    Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Request_Id),
                p_Sccwl_Sccw     => l_Scww_Id,
                p_Sccwl_Cbi_Dt   => l_Req.Cbi_Date,
                p_Sccwl_St_Old   => l_Sccw_Cbi_St,
                p_Sccwl_St       => l_Req.Status);
        END IF;

        BEGIN
              SELECT w.Atw_At,
                     w.Atw_Id,
                     w.Atw_St,
                     w.Atw_Wrn
                INTO l_At_Id,
                     l_Atw_Id,
                     l_Atw_St_Old,
                     l_Atw_Wrn
                FROM At_Wares w JOIN Act a ON w.Atw_At = a.At_Id
               WHERE    w.Atw_Id = l_Req.Ware_Id_Uss
                     OR w.Atw_Ext_Ident = l_Req.Ware_Id_Cbi
            ORDER BY a.At_Dt DESC NULLS LAST
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF l_Atw_Id IS NULL
        THEN
            IF l_Req.Ware_Id_Uss IS NOT NULL
            THEN
                --Якщо запит на зміну статуса по заяві від ЄІССС/Порталу, повертаємо помилку у разі, якщо не знайшли ДЗР в актах
                Raise_Application_Error (
                    -20000,
                       'Не знайдено направлення по ДЗР(wareIdUss='
                    || l_Req.Ware_Id_Uss
                    || ')');
            ELSE
                --Якщо запит на зміну статуса по направленню від ЦБІ і ДЗР в актах не знайдено -
                --це означає, що дані направлення ще не верифіковані та не перенсені в акти
                RETURN NULL;
            END IF;
        END IF;

        Api$act_Ndzr.Save_Wares (p_Atw_Id              => l_Atw_Id,
                                 p_Atw_St              => l_Req.Status,
                                 p_Atw_Issue_Dt        => l_Req.Ware_Issue_Dt,
                                 p_Atw_End_Exp_Dt      => l_Req.Ware_End_Exp_Dt,
                                 p_Atw_Ref_Num         => l_Req.Ref_Num,
                                 p_Atw_Ref_Dt          => l_Req.Ref_Dt,
                                 p_Atw_Ref_Exp_Dt      => l_Req.Ref_Exp_Dt,
                                 p_Atw_Reject_Reason   => l_Req.Reject_Reason);

        Api$act_Ndzr.Write_Atw_Log (
            p_Atwl_Atw       => l_Atw_Id,
            p_Atwl_Hs        => Tools.Gethistsession,
            p_Atwl_St        => l_Req.Status,
            p_Atwl_Message   => CHR (38) || '363#' || p_Request_Id,
            p_Atwl_St_Old    => l_Atw_St_Old,
            p_Atwl_Tp        => 'SYS');

        IF l_Req.Reject_Reason IS NOT NULL
        THEN
            Api$esr_Action.Preparewrite_Visit_At_Log (
                p_Atl_At   => l_At_Id,
                p_Atl_Message   =>
                       CHR (38)
                    || '367#@6601@'
                    || l_Atw_Wrn
                    || '#@6781@'
                    || l_Req.Status
                    || '#'
                    || TO_CHAR (l_Req.Cbi_Date, 'dd.mm.yyyy')
                    || '#'
                    || l_Req.Reject_Reason);
        ELSE
            Api$esr_Action.Preparewrite_Visit_At_Log (
                p_Atl_At   => l_At_Id,
                p_Atl_Message   =>
                       CHR (38)
                    || '366#@6601@'
                    || l_Atw_Wrn
                    || '#@6781@'
                    || l_Req.Status
                    || '#'
                    || TO_CHAR (l_Req.Cbi_Date, 'dd.mm.yyyy'));
        END IF;

        RETURN NULL;
    END Put_Person_Wares_Status;

    /*
    info:    реєстрація запиту для передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    PROCEDURE Reg_Get_Wares_Need_Request (p_At_Id IN NUMBER, p_Rbm_Hs NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rn_Id     NUMBER;
        l_Atrq_Id   NUMBER;
    BEGIN
        INSERT INTO At_Request (Atrq_Id, Atrq_At, Atrq_St)
             VALUES (0, p_At_Id, 'R')
          RETURNING Atrq_Id
               INTO l_Atrq_Id;

        Ikis_Rbm.Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => 126,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => l_Atrq_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => 126,
            p_Rn_Src         => 'USS',
            p_Rn_Hs_Ins      => p_Rbm_Hs,
            p_New_Rn_Id      => l_Rn_Id);

        UPDATE At_Request r
           SET r.Atrq_Rn = l_Rn_Id
         WHERE r.Atrq_Id = l_Atrq_Id;

        Api$esr_Action.Preparewrite_Visit_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Message   => CHR (38) || '323#@6502@126');
    END Reg_Get_Wares_Need_Request;

    /*
    info:    Отримання даних запиту для передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Get_Wares_Need_Request (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Req          Ikis_Rbm.Api$request_Cbi.r_Need_Req;
        l_Atrq_Id      NUMBER;
        l_At_Id        NUMBER;
        l_At_Org       NUMBER;
        l_Appeal_Apd   NUMBER;
        l_Passp_Apd    NUMBER;
        l_Passp_Ndt    NUMBER;
        l_App_Id       NUMBER;
        l_App_Sc       NUMBER;
        l_Kaot_Id      NUMBER;
        l_Kaot_Code    Uss_Ndi.v_Ndi_Katottg.Kaot_Code%TYPE;

        --Значення атрибута "ІД"
        FUNCTION Get_Attr_Id (p_Nda_Id NUMBER, p_Apd_Id NUMBER)
            RETURN NUMBER
        IS
            l_Val   NUMBER;
        BEGIN
            SELECT MAX (a.Apda_Val_Id)
              INTO l_Val
              FROM Ap_Document_Attr a
             WHERE     a.Apda_Apd = p_Apd_Id
                   AND a.Apda_Nda = p_Nda_Id
                   AND a.History_Status = 'A';

            RETURN l_Val;
        END Get_Attr_Id;

        --Значення атрибута "рядок"
        FUNCTION Get_Attr_Str (p_Nda_Id NUMBER, p_Apd_Id NUMBER)
            RETURN VARCHAR2
        IS
            l_Val   VARCHAR2 (4000);
        BEGIN
            SELECT MAX (a.Apda_Val_String)
              INTO l_Val
              FROM Ap_Document_Attr a
             WHERE     a.Apda_Apd = p_Apd_Id
                   AND a.Apda_Nda = p_Nda_Id
                   AND a.History_Status = 'A';

            RETURN l_Val;
        END Get_Attr_Str;

        --Значення атрибута "рядок"
        FUNCTION Get_Attr_Str (p_Nda_Class VARCHAR2, p_Apd_Id NUMBER)
            RETURN VARCHAR2
        IS
            l_Val   VARCHAR2 (4000);
        BEGIN
            SELECT MAX (a.Apda_Val_String)
              INTO l_Val
              FROM Ap_Document_Attr  a
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
             WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

            RETURN l_Val;
        END Get_Attr_Str;

        --Значення атрибута "дата"
        FUNCTION Get_Attr_Dt (p_Nda_Class VARCHAR2, p_Apd_Id NUMBER)
            RETURN DATE
        IS
            l_Val   DATE;
        BEGIN
            SELECT MAX (a.Apda_Val_Dt)
              INTO l_Val
              FROM Ap_Document_Attr  a
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
             WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

            RETURN l_Val;
        END Get_Attr_Dt;
    BEGIN
        l_Atrq_Id := Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id);

        --Визначаємо ІД акту
        SELECT r.Atrq_At
          INTO l_At_Id
          FROM At_Request r
         WHERE r.Atrq_Id = l_Atrq_Id;

        --Вичитуємо основні реквізити особи
        SELECT Ap.Ap_Id,
               p.App_Id,
               p.App_Sc,
               --
               d.Apd_Id,
               p.App_Sc,
               Ap.Ap_Num,
               Ap.Ap_Reg_Dt,
               Uss_Person.Api$sc_Tools.Get_Numident (p.App_Sc),
               Sci.Sci_Ln,
               Sci.Sci_Fn,
               Sci.Sci_Mn,
               Sci.Sci_Gender,
               101,
               --Поки хардкод(узгоджено з Т.Ніконова)
               Ap.Ap_Src,
               At.At_Org
          INTO l_Req.Req_Id,
               l_App_Id,
               l_App_Sc,
               l_Appeal_Apd,
               l_Req.Pers_Id,
               l_Req.Req_Number,
               l_Req.Req_Date,
               l_Req.Numident,
               l_Req.Last_Name,
               l_Req.First_Name,
               l_Req.Second_Name,
               l_Req.Sex,
               l_Req.Pers_State,
               l_Req.Src,
               l_At_Org
          FROM Act  At
               JOIN Appeal Ap ON At.At_Ap = Ap.Ap_Id
               JOIN Ap_Person p
                   ON     Ap.Ap_Id = p.App_Ap
                      AND p.App_Tp = 'Z'
                      AND p.History_Status = 'A'
               JOIN Ap_Document d
                   ON     p.App_Id = d.Apd_App
                      AND d.Apd_Ndt = 10344                            --Заява
                      AND d.History_Status = 'A'
               JOIN Uss_Person.v_Sc_Change c ON p.App_Scc = c.Scc_Id
               JOIN Uss_Person.v_Sc_Identity Sci ON c.Scc_Sci = Sci.Sci_Id
         WHERE At.At_Id = l_At_Id
         FETCH FIRST 1 ROW ONLY;

        --Визначаємо ІД КАТОТТГ
        l_Kaot_Id := Get_Attr_Id (8634, l_Appeal_Apd);

        --Визначаємо код КАТОТТГ
        SELECT MAX (k.Kaot_Code)
          INTO l_Kaot_Code
          FROM Uss_Ndi.v_Ndi_Katottg k
         WHERE k.Kaot_Id = l_Kaot_Id;

        --115974
        SELECT MAX (Nok_Kaot)
          INTO l_Kaot_Id
          FROM Uss_Ndi.v_Ndi_Nsss2dszn, Uss_Ndi.v_Ndi_Org2kaot k
         WHERE     N2d_Org_Nsss = l_At_Org
               AND k.History_Status = 'A'
               AND k.Nok_Org = N2d_Org_Dszn;

        --Визначаємо ІД ФСЗОІ
        SELECT p.Dpp_Tax_Code
          INTO l_Req.Fond_Code
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Pay_Person p
                   ON k.Kaot_Kaot_L1 = p.Dpp_Kaot AND p.Dpp_Tp = 'ISPF'
         WHERE k.Kaot_Id = l_Kaot_Id;

        --Визначаємо код КАТОТТГ


        --Визначаємо наявність позначки "Відмова від РНОКПП"
        SELECT DECODE (COUNT (*), 0, 'F', 'T')
          INTO l_Req.Numident_Check
          FROM Ap_Document d
         WHERE     d.Apd_App = l_App_Id
               AND d.History_Status = 'A'
               AND d.Apd_Ndt = 10117;

        --Отримуємо ІД та тип документа, що посвідчує особу
        SELECT MAX (Apd_Id), MAX (Apd_Ndt)
          INTO l_Passp_Apd, l_Passp_Ndt
          FROM (  SELECT d.Apd_Id, d.Apd_Ndt
                    FROM Ap_Document d
                         JOIN Uss_Ndi.v_Ndi_Document_Type t
                             ON d.Apd_Ndt = t.Ndt_Id AND t.Ndt_Ndc = 13
                   WHERE d.Apd_App = l_App_Id AND d.History_Status = 'A'
                ORDER BY t.Ndt_Sc_Srch_Priority NULLS LAST
                   FETCH FIRST ROW ONLY);

        --Розбиваємо на серію та номер
        IF l_Passp_Apd IS NOT NULL
        THEN
            l_Req.Birth_Date := Get_Attr_Dt ('BDT', l_Passp_Apd);

            l_Req.Passport.Type_ :=
                Uss_Ndi.Tools.Decode_Dict_Reverse (
                    p_Nddc_Tp          => 'NDT_ID',
                    p_Nddc_Src         => 'CBI',
                    p_Nddc_Dest        => 'USS',
                    p_Nddc_Code_Dest   => l_Passp_Ndt);
            l_Req.Passport.Issue_Date := Get_Attr_Dt ('DGVDT', l_Passp_Apd);
            l_Req.Passport.Issue_Org := Get_Attr_Str ('DORG', l_Passp_Apd);
            l_Req.Passport.Number_ :=
                UPPER (REPLACE (Get_Attr_Str ('DSN', l_Passp_Apd), ' ', ''));

            IF l_Passp_Ndt = 6
            THEN
                l_Req.Passport.Seria :=
                    TRANSLATE (
                        SUBSTR (l_Req.Passport.Number_,
                                1,
                                LENGTH (l_Req.Passport.Number_) - 6),
                        'ABCIETOPHKXM',
                        'АВСІЕТОРНКХМ');
                l_Req.Passport.Number_ :=
                    SUBSTR (l_Req.Passport.Number_,
                            LENGTH (l_Req.Passport.Number_) - 5,
                            6);
            ELSIF l_Passp_Ndt IN (37, 11)
            THEN
                l_Req.Passport.Seria :=
                    SUBSTR (l_Req.Passport.Number_,
                            1,
                            LENGTH (l_Req.Passport.Number_) - 6);
                l_Req.Passport.Number_ :=
                    SUBSTR (l_Req.Passport.Number_,
                            LENGTH (l_Req.Passport.Number_) - 5,
                            6);
            ELSE
                l_Req.Passport.Seria := NULL;
                l_Req.Passport.Number_ := l_Req.Passport.Number_;
            END IF;

            l_Req.Passport.Seria := TRIM ('-' FROM l_Req.Passport.Seria);
        END IF;

        --Контакти
        l_Req.Phone := Get_Attr_Str (8639, l_Appeal_Apd);
        l_Req.Email := Get_Attr_Str (8683, l_Appeal_Apd);

        --Адреса
        l_Req.Actual_Address.Post_Index := Get_Attr_Str (8682, l_Appeal_Apd);
        l_Req.Actual_Address.Katottg := l_Kaot_Code;
        l_Req.Actual_Address.Street := Get_Attr_Str (8635, l_Appeal_Apd);
        l_Req.Actual_Address.House :=
            SUBSTR (Get_Attr_Str (8636, l_Appeal_Apd), 1, 10);
        l_Req.Actual_Address.Block :=
            SUBSTR (Get_Attr_Str (8637, l_Appeal_Apd), 1, 10);
        l_Req.Actual_Address.Appartment :=
            SUBSTR (Get_Attr_Str (8638, l_Appeal_Apd), 1, 10);

        --Отримуємо перелік ДЗР
        SELECT w.Atw_Id,
               NULL,
               c.Wrn_Shifr,
               c.Wrn_Name
          BULK COLLECT INTO l_Req.Wares
          FROM At_Wares  w
               JOIN Uss_Ndi.v_Ndi_Cbi_Wares c ON w.Atw_Wrn = c.Wrn_Id
         WHERE w.Atw_At = l_At_Id AND w.History_Status = 'A';

        --Отримуємо перелік вкладень документів
        SELECT f.File_Name, f.File_Mime_Type, f.File_Code
          BULK COLLECT INTO l_Req.Files
          FROM Ap_Person  p
               JOIN Ap_Document d
                   ON p.App_Id = d.Apd_App AND d.History_Status = 'A'
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Apd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE p.App_Ap = l_Req.Req_Id AND p.History_Status = 'A';

        --Вичитуємо реквізити уповноваженої особи
        BEGIN
            SELECT Sci.Sci_Ln,
                   Sci.Sci_Fn,
                   Sci.Sci_Mn,
                   NVL (
                       Uss_Person.Api$sc_Tools.Get_Numident (p.App_Sc),
                       REPLACE (
                           Uss_Person.Api$sc_Tools.Get_Doc_Num (p.App_Sc),
                           ' '))
              INTO l_Req.Auth_Person.Auth_Last_Name,
                   l_Req.Auth_Person.Auth_First_Name,
                   l_Req.Auth_Person.Auth_Second_Name,
                   l_Req.Auth_Person.Auth_Numident
              FROM Act  At
                   JOIN Ap_Person p
                       ON     At.At_Ap = p.App_Ap
                          AND p.App_Tp = 'P'          /*Представник заявника*/
                          AND p.History_Status = 'A'
                   JOIN Uss_Person.v_Sc_Change c ON p.App_Scc = c.Scc_Id
                   JOIN Uss_Person.v_Sc_Identity Sci
                       ON c.Scc_Sci = Sci.Sci_Id
             WHERE At.At_Id = l_At_Id
             FETCH FIRST 1 ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо актуальні рішення від МОЗ
        DECLARE
            l_Scdi_Id         NUMBER;
            l_Add_Diagnoses   Uss_Person.v_Sc_Moz_Assessment.Scma_Main_Diagnosis%TYPE;
        BEGIN
            SELECT MAX (Scma_Scdi)
              INTO l_Scdi_Id
              FROM Uss_Person.v_Sc_Moz_Assessment d
             WHERE Scma_Sc = l_App_Sc AND Scma_St = 'VO';

            IF l_Scdi_Id IS NOT NULL
            THEN
                SELECT a.Scma_Decision_Num,
                       a.Scma_Decision_Dt,
                       a.Scma_Eval_Dt,
                       a.Scma_Start_Dt,
                       SUBSTR (a.Scma_Group, 1, 1),
                       SUBSTR (a.Scma_Group, 2, 1),
                       a.Scma_Is_Endless,
                       a.Scma_End_Dt,
                       TRIM (
                           TO_CHAR (a.Scma_Loss_Prof_Ability_Perc,
                                    '9999999999990D99',
                                    'NLS_NUMERIC_CHARACTERS=''. ''')),
                       a.Scma_Main_Diagnosis,
                       a.Scma_Add_Diagnoses,
                       Uss_Ndi.Tools.Decode_Dict_Reverse (
                           p_Nddc_Tp     => 'INV_REASON',
                           p_Nddc_Src    => 'CBI',
                           p_Nddc_Dest   => 'USS',
                           p_Nddc_Code_Dest   =>
                               CASE
                                   WHEN INSTR (a.Scma_Reasons, ',') > 0
                                   THEN
                                       SUBSTR (
                                           a.Scma_Reasons,
                                           0,
                                           INSTR (a.Scma_Reasons, ',') - 1)
                                   ELSE
                                       a.Scma_Reasons
                               END),
                       z.Scmz_Org_Name,
                       z.Scmz_Org_Id,
                       COALESCE (z.Scmz_City_Id,
                                 z.Scmz_Community_Id,
                                 z.Scmz_District_Id,
                                 z.Scmz_Region_Id),
                       z.Scmz_Region_Name,
                       z.Scmz_District_Name,
                       z.Scmz_Community_Name,
                       z.Scmz_City_Name,
                       z.Scmz_Street_Name,
                       z.Scmz_Building,
                       z.Scmz_Room,
                       z.Scmz_Post_Code
                  INTO l_Req.Disability.Decision_Num,
                       l_Req.Disability.Decision_Dt,
                       l_Req.Disability.Eval_Dt,
                       l_Req.Disability.Start_Dt,
                       l_Req.Disability.Group_,
                       l_Req.Disability.Sub_Group,
                       l_Req.Disability.Is_Endless,
                       l_Req.Disability.End_Dt,
                       l_Req.Disability.Loss_Prof_Ability_Perc,
                       l_Req.Disability.Main_Diagnosis,
                       l_Add_Diagnoses,
                       l_Req.Disability.Reason,
                       l_Req.Disability.Org_Data.Org_Name,
                       l_Req.Disability.Org_Data.Org_Id,
                       l_Req.Disability.Org_Data.Katottg,
                       l_Req.Disability.Org_Data.Region_Name,
                       l_Req.Disability.Org_Data.District_Name,
                       l_Req.Disability.Org_Data.Community_Name,
                       l_Req.Disability.Org_Data.City_Name,
                       l_Req.Disability.Org_Data.Street_Name,
                       l_Req.Disability.Org_Data.Building,
                       l_Req.Disability.Org_Data.Room,
                       l_Req.Disability.Org_Data.Post_Code
                  FROM Uss_Person.v_Sc_Moz_Assessment  a
                       JOIN Uss_Person.v_Sc_Moz_Zoz z
                           ON z.Scmz_Scdi = a.Scma_Scdi
                 WHERE a.Scma_Scdi = l_Scdi_Id;

                    SELECT REGEXP_SUBSTR (l_Add_Diagnoses,
                                          '[^,]+',
                                          1,
                                          LEVEL)
                      BULK COLLECT INTO l_Req.Disability.Add_Diagnoses
                      FROM DUAL
                CONNECT BY LEVEL <=
                             LENGTH (l_Add_Diagnoses)
                           - LENGTH (REPLACE (l_Add_Diagnoses, ','))
                           + 1;
            END IF;
        END;

        --Формуємо запит
        RETURN Ikis_Rbm.Api$request_Cbi.Build_Need_Req (l_Req);
    END Get_Wares_Need_Request;

    /*
    info:   Обробка відповіді на запит передачі заяви потреби в ЦБІ
    author:  sho
    request: #112501
    */
    PROCEDURE Handle_Wares_Need_Response (p_Ur_Id      IN     NUMBER,
                                          p_Response   IN     CLOB,
                                          p_Error      IN OUT VARCHAR2)
    IS
        l_Resp                               Ikis_Rbm.Api$request_Cbi.r_Need_Resp;
        l_Atrq_Id                            NUMBER;
        l_Atrq_At                            NUMBER;
        l_At_St                              Act.At_St%TYPE;

        c_Result_Code_Ok            CONSTANT NUMBER := 1;
        c_Result_Code_Bad_Req       CONSTANT NUMBER := 102;
        c_Result_Code_Technical     CONSTANT NUMBER := 103;
        c_Result_Code_Unavailable   CONSTANT NUMBER := 104;
        c_Result_Code_Repeat        CONSTANT NUMBER := 105;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        l_Resp := Ikis_Rbm.Api$request_Cbi.Parse_Need_Resp (p_Response);

        IF l_Resp.Result_Code IN
               (c_Result_Code_Technical, c_Result_Code_Unavailable)
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => 'Сервіс на боці ЦБІ недоступний');
        END IF;

        IF l_Resp.Result_Code = c_Result_Code_Bad_Req
        THEN
            p_Error := 'Некоректні параметри запиту';
        ELSIF l_Resp.Result_Code IS NULL
        THEN
            p_Error := 'Код відповіді порожній';
        END IF;

        l_Atrq_Id := Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id);

           UPDATE At_Request r
              SET r.Atrq_St =
                      CASE
                          WHEN l_Resp.Result_Code IN
                                   (c_Result_Code_Ok, c_Result_Code_Repeat)
                          THEN
                              'D'
                          ELSE
                              'E'
                      END
            WHERE r.Atrq_Id = l_Atrq_Id
        RETURNING Atrq_At
             INTO l_Atrq_At;

        Api$esr_Action.Preparewrite_Visit_At_Log (
            p_Atl_At   => l_Atrq_At,
            p_Atl_Message   =>
                   CHR (38)
                || CASE
                       WHEN l_Resp.Result_Code IN
                                (c_Result_Code_Ok, c_Result_Code_Repeat)
                       THEN
                           '368'
                       ELSE
                           '369#' || p_Error || '#' || l_Atrq_Id
                   END);

        SELECT MAX (At_St)
          INTO l_At_St
          FROM Act a
         WHERE a.At_Id = l_Atrq_At;

        Api$act.Write_At_Log (
            l_Atrq_At,
            Tools.Gethistsession,
            l_At_St,
               CHR (38)
            || CASE
                   WHEN l_Resp.Result_Code IN
                            (c_Result_Code_Ok, c_Result_Code_Repeat)
                   THEN
                       '368'
                   ELSE
                       '369#' || p_Error || '#' || l_Atrq_Id
               END,
            l_At_St);
    END Handle_Wares_Need_Response;
END Dnet$exch_Cbi;
/